class ST_TranslocatorTarget extends TranslocatorTarget;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var PlayerPawn InstigatingPlayer;

var int MaxHistorySteps;             // cap for the throw-time fast-forward
var vector SimulationHistory[256];
var float SimulationTimes[256];
var byte SimulationLanded[256];     // 1 if Physics == PHYS_None at that entry
var int HistoryCount;
// Predicted translocation: keep recording the disc's path after the
// fast-forward, for its whole life, so any age can be looked up.
var bool bIGPlusFullHistory;
var float IGPlus_HistoryAnchor; // Level.TimeSeconds of age TotalSimulationTime, set on the first tick
var float IGPlus_AgeBias;       // fast-forward shortfall when ping exceeded PingCompensationMax
// Server, deterministic translocator: the thrower's hitscan was just tested
// against this disc where its screen had it (this server frame, at this age).
var float IGPlus_OwnShotFrame;
var float IGPlus_OwnShotAge;
var bool IGPlus_bChangedEarly;  // shot/stuck/bounced before full history (fast-forward)
var bool IGPlus_bRebasing;      // re-flying: server after the thrower's own hit, client catching up to a knock
var bool IGPlus_bLocalDisc;     // client: the thrower's own deterministic disc
var vector IGPlus_EaseFrom;     // client: draw offset a server correction left (bSmoothDiscCorrections)
var float IGPlus_EaseStart;
var float IGPlus_SyncAge;       // server: send our state to the thrower once this old (0: none)
var float IGPlus_LastSyncAge;   // server: age of the last state sent from Tick
var bool IGPlus_bResyncAfterHit; // server: a hit sent it flying, send our state every 0.05s until it lands
var bool IGPlus_bDamageOnly;     // server: TakeDamage leaves its speed alone (IGPlus_ChunkDamageOnly)
// Server, for the [DET-TLOC] log: our bounces/landings/door pushes, and the
// thrower's (from its sync asks).
var float IGPlus_DetPathAges[4];
var int IGPlus_DetServerPathEvents;
var int IGPlus_DetClientPathEvents;
var Actor IGPlus_DetLastEncroacher;
var string IGPlus_DetLastTouch;
// Server, deterministic: where the last Tick had the disc, and the player who
// last stopped it (IGPlus_DetRewoundStop).
var vector IGPlus_DetPrevLoc;
var bool IGPlus_bDetPrevLoc;
var Pawn IGPlus_DetStoppedBy;
var bool IGPlus_bDetSweeping;   // server: inside IGPlus_DetRewoundStop's own rewind
var float SimulationStartTime;     // When simulation began
var float TotalSimulationTime;     // Total ping time simulated

// For temporary position changes during translocation
var vector PreTranslocateLocation;
var bool bUsingHistoricalPosition;
var EPhysics IGPlus_PreTranslocatePhysics;
var vector IGPlus_PreTranslocateVelocity;
var bool IGPlus_PreCollideActors, IGPlus_PreBlockActors, IGPlus_PreBlockPlayers;

simulated final function WeaponSettingsRepl FindWeaponSettings() {
	local WeaponSettingsRepl S;

	foreach AllActors(class'WeaponSettingsRepl', S)
		return S;

	return none;
}

simulated final function WeaponSettingsRepl GetWeaponSettings() {
	if (WSettings != none)
		return WSettings;

	WSettings = FindWeaponSettings();
	return WSettings;
}

simulated function PostBeginPlay() {
	local UTPure PureRef;
	local bbPlayer bbP;

	if (Instigator != none && Instigator.Role == ROLE_Authority) {

		bbP = bbPlayer(Instigator);
		if (bbP != none) {
			PureRef = bbP.zzUTPure;
		}
		
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
		
		if (PureRef != None) {
			PureRef.RegisterProjectile(self);
		}
	}
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
    local ST_Translocator TL;
	local bbPlayer bbP;

	if (Instigator != none) {
		bbP = bbPlayer(Instigator);
	}

	super.PostNetBeginPlay();

	if (bbP != none && (bbP.IGPlus_DetTranslocator || (GetWeaponSettings().TranslocatorCompensatePing
		&& (bbP.ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations || bbP.IGPlus_PredictsTranslocation())))) {

		In = PlayerPawn(Instigator);

		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none && bbP.IGPlus_DetTranslocator && Level.NetMode == NM_Client
			&& IGPlus_InDemoPlayback() == false) {
			// Deterministic translocator: the thrower watches its own disc;
			// ST_Translocator.IGPlus_DetClientTick keeps this copy hidden.
			class'ST_Translocator'.static.IGPlus_DetSetCopyHidden(self, true);
			return;
		}

		if (InstigatingPlayer != none) {
			// Predicted translocation already used our local disc: this one is gone too.
			if (bbP.IGPlus_TlocHideArrivingUntil > Level.TimeSeconds) {
				bbP.IGPlus_TlocHideArrivingUntil = 0.0;
				bbP.IGPlus_TlocHideDisc(self);
				return;
			}

			TL = ST_Translocator(InstigatingPlayer.Weapon);
			if (TL != none && TL.TTarget_Client != none && TL.TTarget_Client.bDeleteMe == false)
			{
				// Merge: teleport server disc to where client disc is for seamless hand-off
				SetLocation(TL.TTarget_Client.Location);

				TL.TTarget_Client.Destroy();
				TL.TTarget_Client = None;
			}
		}
	}
}

function InitSimulationHistory(vector StartPos, float StartTime, float TotalTime) {
    SimulationHistory[0] = StartPos;
    SimulationTimes[0] = StartTime;
    SimulationLanded[0] = byte(Physics == PHYS_None);
    HistoryCount = 1;
    SimulationStartTime = Level.TimeSeconds;
    TotalSimulationTime = TotalTime;
}

function AddSimulationHistoryStep(vector NewPos, float TimeStamp) {
    if (HistoryCount < MaxHistorySteps) {
        SimulationHistory[HistoryCount] = NewPos;
        SimulationTimes[HistoryCount] = TimeStamp;
        SimulationLanded[HistoryCount] = byte(Physics == PHYS_None);
        HistoryCount++;
    }
}

function SimulateWithHistory(IGPlus_WeaponImplementation WImpl, int Ping)
{
    if (WImpl != None)
        WImpl.SimulateProjectileWithHistory(self, Ping);
}

// Server: append the current position at Age (seconds since the throw).
// bAtRest: the disc has come to rest (from Landed).
function IGPlus_RecordHistory(float Age, optional bool bAtRest) {
    local int i;
    local byte bLanded;

    if (HistoryCount <= 0)
        return;

    i = HistoryCount - 1;
    if (Age <= SimulationTimes[i])
        return;

    bLanded = byte(Physics == PHYS_None || bAtRest);
    // A resting disc adds nothing: the first tick after a knock records the
    // rest spot (not landed) at the right age. 10ms spacing while flying.
    if (bLanded == SimulationLanded[i]
        && (Location == SimulationHistory[i] || Age - SimulationTimes[i] < 0.01))
        return;

    if (HistoryCount >= arraycount(SimulationHistory))
        IGPlus_HalveHistory();
    i = HistoryCount++;

    SimulationHistory[i] = Location;
    SimulationTimes[i] = Age;
    SimulationLanded[i] = bLanded;
}

// Server: something only the server saw changed the disc's path.
function IGPlus_NoteChanged() {
    if (bIGPlusFullHistory == false)
        IGPlus_bChangedEarly = true;
    else if (ST_Translocator(Master) != None)
        ST_Translocator(Master).IGPlus_DetServerDiscChanged(self);
}

// Age since the throw now (server). Within a server frame of the truth.
function float IGPlus_CurrentAge() {
    if (IGPlus_HistoryAnchor == 0.0)
        return TotalSimulationTime;
    return TotalSimulationTime + (Level.TimeSeconds - IGPlus_HistoryAnchor);
}

// Forget the path after Age (it is about to be flown again).
function IGPlus_TruncateHistory(float Age) {
    while (HistoryCount > 1 && SimulationTimes[HistoryCount - 1] > Age)
        HistoryCount--;
}

// Full: keep the first and last entries, drop every other one between.
function IGPlus_HalveHistory() {
    local int i, j;

    j = 1;
    for (i = 2; i < HistoryCount - 1; i += 2) {
        SimulationHistory[j] = SimulationHistory[i];
        SimulationTimes[j] = SimulationTimes[i];
        SimulationLanded[j] = SimulationLanded[i];
        j++;
    }
    SimulationHistory[j] = SimulationHistory[HistoryCount - 1];
    SimulationTimes[j] = SimulationTimes[HistoryCount - 1];
    SimulationLanded[j] = SimulationLanded[HistoryCount - 1];
    HistoryCount = j + 1;
}

// Position and landed state at Age seconds after the throw.
function vector IGPlus_GetHistoryAt(float Age, out byte bLanded) {
    local int i;
    local float Alpha, Now, T;
    local vector End;

    if (HistoryCount <= 0) {
        bLanded = byte(Physics == PHYS_None);
        return Location;
    }

    if (Age <= SimulationTimes[0]) {
        bLanded = SimulationLanded[0];
        return SimulationHistory[0];
    }

    for (i = 1; i < HistoryCount; i++) {
        if (Age < SimulationTimes[i]) {
            Alpha = (Age - SimulationTimes[i-1]) / FMax(SimulationTimes[i] - SimulationTimes[i-1], 0.0001);
            bLanded = SimulationLanded[i-1];
            return SimulationHistory[i-1] + Alpha * (SimulationHistory[i] - SimulationHistory[i-1]);
        }
    }

    // A resting disc records nothing more, but may ride a lift: use it as is
    // (Location is still the rest spot right after a hit sets it falling).
    i = HistoryCount - 1;
    if (SimulationLanded[i] != 0) {
        bLanded = 1;
        return Location;
    }
    bLanded = 0;
    if (bIGPlusFullHistory == false)
        return SimulationHistory[i];

    // Entries are 10ms apart and taken before each frame's physics, so the
    // newest can be two server frames old: the live disc is the newest point.
    Now = IGPlus_CurrentAge();
    if (Age < Now && Now > SimulationTimes[i]) {
        Alpha = (Age - SimulationTimes[i]) / (Now - SimulationTimes[i]);
        return SimulationHistory[i] + Alpha * (Location - SimulationHistory[i]);
    }
    // Past the live disc: a move that arrived early (jitter). Fly it on briefly.
    bLanded = byte(Physics == PHYS_None);
    if (Physics != PHYS_Falling)
        return Location;
    T = FMin(Age - Now, 0.05);
    End = Location + Velocity * T + 0.5 * T * T * Region.Zone.ZoneGravity;
    if (FastTrace(End, Location))
        return End;
    return Location;
}

function vector GetHistoricalPosition(float RequestTime) {
    local int i;
    local float Alpha;
    local vector InterpolatedPos;
    
    if (HistoryCount <= 1)
        return Location;
    
    // Clamp request time
    RequestTime = FClamp(RequestTime, 0.0, TotalSimulationTime);
    
    // If before first time, return first position
    if (RequestTime <= SimulationTimes[0])
        return SimulationHistory[0];
        
    // If after last time, return last position
    if (RequestTime >= SimulationTimes[HistoryCount-1])
        return SimulationHistory[HistoryCount-1];
    
    // Find the time bracket (backward search for efficiency)
    for (i = HistoryCount - 1; i > 0; i--) {
        if (SimulationTimes[i-1] <= RequestTime && RequestTime <= SimulationTimes[i]) {
            Alpha = (RequestTime - SimulationTimes[i-1]) / 
                    (SimulationTimes[i] - SimulationTimes[i-1]);
            InterpolatedPos = SimulationHistory[i-1] + 
                             Alpha * (SimulationHistory[i] - SimulationHistory[i-1]);
            return InterpolatedPos;
        }
    }
    
    // Fallback (shouldn't reach here with valid data)
    return Location;
}

// Demo playback: udemo's spectator, or UT's own playback through the
// recorder's eyes (bbPlayer.IGPlus_InDemoPlayback knows both).
simulated function bool IGPlus_InDemoPlayback() {
	local Pawn P;

	if (Level.NetMode != NM_Client)
		return false;
	if (bbPlayer(Instigator) != None && bbPlayer(Instigator).IGPlus_InDemoPlayback())
		return true;
	for (P = Level.PawnList; P != None; P = P.NextPawn)
		if (P.IsA('DemoPlaybackSpec'))
			return true;
	return false;
}

// A bounce, a landing or a door pushing the disc. An edge (a window frame)
// can stop the thrower's disc and not the server's, and a door can move
// differently on the client than on the server. The server's disc tells the
// thrower what it did, the thrower's asks the server what its own did.
simulated function IGPlus_PathEvent(bool bLanded) {
	if (IGPlus_bRebasing || ST_Translocator(Master) == None)
		return;
	if (IGPlus_bLocalDisc)
		ST_Translocator(Master).IGPlus_DetLocalDiscBounced();
	else if (bIGPlusFullHistory && Role == ROLE_Authority) {
		IGPlus_DetPathAges[IGPlus_DetServerPathEvents % ArrayCount(IGPlus_DetPathAges)] = IGPlus_CurrentAge();
		IGPlus_DetServerPathEvents++;
		if (bLanded) { // at rest: where it ends this frame
			IGPlus_SyncAge = 0.0;
			ST_Translocator(Master).IGPlus_DetServerDiscChanged(self, 0.0, true);
		}
		else { // where it ends this frame, from the next Tick
			// ponytail: 50ms apart, a disc rattling in a corner bounces every frame
			IGPlus_SyncAge = FMax(IGPlus_SyncAge, FMax(IGPlus_CurrentAge(), IGPlus_LastSyncAge + 0.05));
			Enable('Tick'); // a resting disc pushed by a door: Landed switched it off
		}
	}
}

// Client, our own disc hit a door moving on our screen. The server's disc
// meets that door a round trip further along (we see it half a ping late,
// and the server's disc gets there half a ping after ours). Will the spot we
// hit be clear of it by then? A door moved by Delta covers what it covers
// now shifted by Delta: look for it now, Delta back from our spot. Sliding
// doors only: a turning one has no Delta (IGPlus_LiftAhead), so it never clears.
simulated function bool IGPlus_DetDoorClearsInTime(Mover M, vector HitNormal) {
	local float D;
	local vector Delta, VelLead, Start, End, HitLoc, HitNorm, Extent;
	local Mover A;
	local bbPlayer P;

	P = bbPlayer(Instigator);
	if (P == None || P.IGPlus_LiftAhead(M, float(P.PingAverage) * 0.001 * Level.TimeDilation, Delta, VelLead) == false)
		return false;
	D = Delta dot HitNormal;
	if (D > 0.0)
		return false; // coming at us: it blocks sooner, not later
	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	Start = Location - Delta + HitNormal * 4.0;
	End = Start - HitNormal * (20.0 - D);
	foreach TraceActors(class'Mover', A, HitLoc, HitNorm, End, Start, Extent)
		if (A == M)
			return false;
	return true;
}

// Client, our own disc was put where the server's is: draw it where it was
// (Drawn) and glide it there over 0.1s. A short way only: a long glide
// would cross the air, worse than the jump. A hit (bShot) really launched
// the disc a round trip ago: its longer glide follows close to the launch
// we missed. Never through a wall or door: those jump.
simulated function IGPlus_EaseFromSpot(vector Drawn, optional bool bShot) {
	local float MaxGlide;
	local vector HitLocation, HitNormal;

	MaxGlide = 64.0;
	if (bShot)
		MaxGlide = 320.0; // ponytail: direct hits at ~150 ping correct 170-300uu
	IGPlus_EaseFrom = Drawn - Location;
	if (VSize(IGPlus_EaseFrom) > MaxGlide || Trace(HitLocation, HitNormal, Drawn, Location, false) != None)
		IGPlus_EaseFrom = vect(0,0,0);
	IGPlus_EaseStart = Level.TimeSeconds;
	IGPlus_DrawAt(IGPlus_EaseFrom);
}

simulated function IGPlus_EaseStep() {
	local float A;

	if (IGPlus_EaseFrom == vect(0,0,0))
		return;
	A = (Level.TimeSeconds - IGPlus_EaseStart) / 0.1;
	if (A >= 1.0)
		IGPlus_EaseFrom = vect(0,0,0);
	IGPlus_DrawAt(IGPlus_EaseFrom * (1.0 - FMin(A, 1.0)));
}

// Draw the disc Offset from where it is. Its glow (a sprite trailing the
// disc's real spot) goes with it.
simulated function IGPlus_DrawAt(vector Offset) {
	PrePivot = default.PrePivot + Offset;
	if (Glow != None)
		Glow.PrePivot = Glow.default.PrePivot + Offset;
}

// Server: a chunk of the thrower's own flak slug hit the thrower's own
// deterministic disc (Predicted Disc Boost). It damages the disc but leaves
// its speed to the slug's push, which the thrower's client predicted. In
// stock a chunk sets the disc's speed to its own small push, so whether the
// slug's push counts depends on the chunks' random spread. True if handled.
function bool IGPlus_ChunkDamageOnly(int Damage, Pawn ChunkInstigator, vector HitLocation, name DamageType) {
	local ST_Translocator TL;

	TL = ST_Translocator(Master);
	if (ChunkInstigator != Instigator || bbPlayer(Instigator) == None || bbPlayer(Instigator).IGPlus_PredictsDiscBoost() == false
		|| TL == None || TL.TTarget != self || TL.IGPlus_IsDetMode() == false || bIGPlusFullHistory == false)
		return false;
	IGPlus_bDamageOnly = true;
	TakeDamage(Damage, ChunkInstigator, HitLocation, vect(0,0,0), DamageType);
	IGPlus_bDamageOnly = false;
	return true;
}

// Server: did our disc bounce, land or get pushed within Slack of Age?
function bool IGPlus_DetHadPathEventNear(float Age, float Slack) {
	local int i;

	for (i = 0; i < ArrayCount(IGPlus_DetPathAges) && i < IGPlus_DetServerPathEvents; i++)
		if (Abs(IGPlus_DetPathAges[i] - Age) <= Slack)
			return true;
	return false;
}

function string IGPlus_DetPathSummary() {
	local string Touched;

	Touched = IGPlus_DetLastTouch;
	if (Touched == "")
		Touched = "none";
	return "bounces(server/client)="$IGPlus_DetServerPathEvents$"/"$IGPlus_DetClientPathEvents@"lastTouch="$Touched;
}

// Server: a [DET-TLOC] line about something only our copy met (the
// thrower's disc touches nothing).
function IGPlus_DetLogTouch(string Event, Actor Other) {
	local string By;

	if (Level.NetMode == NM_Client || IGPlus_bLocalDisc || bIGPlusFullHistory == false || ST_Translocator(Master) == None)
		return;
	By = string(Other.Class.Name);
	if (Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None) {
		By = Pawn(Other).PlayerReplicationInfo.PlayerName;
		if (Level.Game.bTeamGame && Instigator != None && Instigator.PlayerReplicationInfo != None) {
			if (Pawn(Other).PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team)
				By = By$"(team)";
			else
				By = By$"(enemy)";
		}
	}
	IGPlus_DetLastTouch = Event$":"$By;
	ST_Translocator(Master).IGPlus_DetLog(Event, "by="$By);
}

// Server, deterministic translocator with ping compensation: other players
// stop the disc where its thrower saw them, as the thrower's own disc stops on
// the players on its screen.
function bool IGPlus_DetJudgesRewound() {
	local bbPlayer P;

	P = bbPlayer(Instigator);
	return Role == ROLE_Authority && IGPlus_bLocalDisc == false && bIGPlusFullHistory
		&& ST_Translocator(Master) != None && ST_Translocator(Master).IGPlus_IsDetMode()
		&& P != None && P.zzUTPure != None && P.GetWeaponSettings() != None
		&& P.GetWeaponSettings().bEnablePingCompensation;
}

// Server: this frame's path from From against the other players, rewound to
// where the thrower saw them: a ping and their interp late, as for its
// hitscan. Stock stops a flying disc on the first player it touches, at that
// player's spot (TranslocatorTarget.Touch).
function IGPlus_DetRewoundStop(vector From) {
	local bbPlayer P;
	local IGPlus_WeaponImplementationBase WImpBase;
	local UTPlusDummy D, Hit;
	local vector HitLocation, HitNormal, Extent, NewPos;

	P = bbPlayer(Instigator);
	WImpBase = P.IGPlus_GetWeaponImplementationBase();
	if (WImpBase == None)
		return;
	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	// The rewind moves ridden lifts to their old spot and back, switching
	// their collision off and on: nothing it brings here touches the disc.
	IGPlus_bDetSweeping = true;
	P.zzUTPure.CompensateFor(int(WImpBase.IGPlus_GetAveragePingRewindMs(P)), P);
	foreach TraceActors(class'UTPlusDummy', D, HitLocation, HitNormal, Location, From, Extent) {
		// Not again by the one it just stopped on (it drops through them).
		if (D.Actual != None && D.Actual != Instigator && D.Actual != IGPlus_DetStoppedBy && D.Actual.Health > 0) {
			Hit = D;
			NewPos = D.Location;
			NewPos.Z = HitLocation.Z;
			break;
		}
	}
	P.zzUTPure.EndCompensation();
	IGPlus_bDetSweeping = false;
	if (Hit == None)
		return;
	IGPlus_DetStoppedBy = Hit.Actual;
	SetLocation(NewPos);
	Velocity = vect(0,0,0);
	IGPlus_DetLogTouch("stopped-by-rewound-player", Hit.Actual);
	IGPlus_NoteChanged();
}

auto state Pickup {
	simulated function Tick(float DeltaTime) {
		local float Age;

		// Demo playback: the recording player hid this copy of their own disc
		// and kept it on the disc they watched (ST_Translocator.IGPlus_DetClientTick):
		// show it, at no size once theirs was gone. Bounce sounds are in the
		// recording already. Keeps ticking (the stock Tick switches itself off).
		if (Role < ROLE_Authority && IGPlus_InDemoPlayback()) {
			bHidden = false;
			ImpactSound = None;
			if (Glow != None)
				Glow.bHidden = DrawScale == 0.0;
			return;
		}
		// The thrower's hidden copy (deterministic translocator): no shadow.
		if (bHidden && Role < ROLE_Authority) {
			Disable('Tick');
			return;
		}
		// Full history needs every tick; the stock Tick switches itself off
		// for player discs, and has nothing else to do for them.
		if (bIGPlusFullHistory && Role == ROLE_Authority) {
			// Tick runs before this frame's physics: the disc has flown until
			// Level.TimeSeconds - DeltaTime.
			if (IGPlus_HistoryAnchor == 0.0)
				IGPlus_HistoryAnchor = Level.TimeSeconds - DeltaTime;
			Age = TotalSimulationTime + (Level.TimeSeconds - DeltaTime - IGPlus_HistoryAnchor);
			IGPlus_RecordHistory(Age);
			// ponytail: 1ms for float error in the summed frame times
			if (IGPlus_SyncAge > 0.0 && Age >= IGPlus_SyncAge - 0.001) {
				IGPlus_SyncAge = 0.0;
				IGPlus_LastSyncAge = Age;
				if (ST_Translocator(Master) != None)
					ST_Translocator(Master).IGPlus_DetServerDiscChanged(self, Age);
				if (IGPlus_bResyncAfterHit)
					IGPlus_SyncAge = Age + 0.05;
			}
			// Other players stop it where the thrower saw them. Not across a
			// jump (a re-fly or correction moved it).
			if (Physics == PHYS_Falling && IGPlus_bRebasing == false && IGPlus_DetJudgesRewound()) {
				if (IGPlus_bDetPrevLoc && VSize(Location - IGPlus_DetPrevLoc) <= 2.0 * VSize(Velocity) * DeltaTime + 16.0)
					IGPlus_DetRewoundStop(IGPlus_DetPrevLoc);
				IGPlus_DetPrevLoc = Location;
				IGPlus_bDetPrevLoc = true;
			}
			if (DesiredTarget == None || Master == None)
				return;
		}
		super.Tick(DeltaTime);
	}

	simulated event Landed(vector HitNormal) {
		super.Landed(HitNormal);
		IGPlus_bDetPrevLoc = false; // a knock starts a new flight
		IGPlus_DetStoppedBy = None;

		// Record where it came to rest (Landed switched Tick off). A re-fly
		// records its own steps.
		if (bIGPlusFullHistory && Role == ROLE_Authority && IGPlus_HistoryAnchor != 0.0 && IGPlus_bRebasing == false)
			IGPlus_RecordHistory(TotalSimulationTime + (Level.TimeSeconds - IGPlus_HistoryAnchor), true);
		IGPlus_PathEvent(true); // a landing from a hit's flight still glides as far
		IGPlus_bResyncAfterHit = false;
	}

	// A door (a mover) pushed the disc, or ran over it.
	simulated event EncroachedBy(actor Other) {
		// Our own disc, and our copy of a door moved into it: doors are the
		// server's, and ours may be half a ping off (a door that reversed on
		// the server's disc keeps closing here until we hear, or the
		// server's never got there). It would push our disc into a wall or
		// close over it, out of sight. Let our movers pass through it and
		// ask the server where its disc is (IGPlus_DetIgnoreOurMovers).
		if (IGPlus_bLocalDisc) {
			if (Mover(Other) != None && ST_Translocator(Master) != None) {
				ST_Translocator(Master).IGPlus_DetIgnoreOurMovers(self, "pushed by"@Other.Name);
				return;
			}
			IGPlus_PathEvent(false);
			return;
		}
		if (Other != IGPlus_DetLastEncroacher) {
			IGPlus_DetLastEncroacher = Other;
			IGPlus_DetLogTouch("pushed-by-mover", Other);
		}
		IGPlus_PathEvent(false);
	}

	simulated function HitWall(vector HitNormal, actor Wall) {
		local bool bBounced;

		// Our own disc, against a door that is out of the way by the time
		// the server's disc gets there: fly on through our door and let the
		// server's disc decide, as when a door pushes ours.
		if (IGPlus_bLocalDisc && ST_Translocator(Master) != None && ST_Translocator(Master).IGPlus_DetLocalDisc == self
			&& IGPlus_DetDoorClearsInTime(Mover(Wall), HitNormal)) {
			ST_Translocator(Master).IGPlus_DetIgnoreOurMovers(self, "door clears in a round trip:"@Wall.Name);
			return;
		}
		if (IGPlus_bLocalDisc && Mover(Wall) != None && Wall.bInterpolating && bbPlayer(Instigator) != None)
			bbPlayer(Instigator).ClientDebugMessage("Tloc disc bounces off a moving door:"@Wall.Name
				@"age="$(Level.TimeSeconds - ST_Translocator(Master).IGPlus_DetThrowTS));

		// Stock bounces off the first hits only.
		bBounced = bAlreadyHit == false;
		super.HitWall(HitNormal, Wall);
		if (bBounced)
			IGPlus_PathEvent(false);
	}

	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
		local float OldDisruption;
		local EPhysics OldPhysics;
		local vector OldVelocity;

		OldDisruption = Disruption;

		// The thrower's own rocket, shock ball, flak slug or ripper blade: its
		// push lands on the thrower's moves, where its client pushes its own
		// disc (bbPlayer.IGPlus_SKDefersDisc). Only the damage now. Also the
		// slug's own chunks (IGPlus_ChunkDamageOnly), whose push never lands.
		if (IGPlus_bDamageOnly
			|| (EventInstigator == Instigator && bbPlayer(Instigator) != None && bbPlayer(Instigator).IGPlus_SKDefersDisc(self))) {
			OldPhysics = Physics;
			OldVelocity = Velocity;
			super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
			SetPhysics(OldPhysics);
			Velocity = OldVelocity;
			// Disrupted just now: the thrower sees it (and isn't moved onto it).
			if (Disrupted() && OldDisruption <= DisruptionThreshold)
				ST_Translocator(Master).IGPlus_DetServerDiscChanged(self);
			return;
		}

		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

		// Landed() switched Tick off; a knocked disc flies again. Fast, and
		// often with its bounce used up (no asking at walls): the two copies
		// can part at any ledge. Tick sends ours every 0.05s until it lands.
		if (bIGPlusFullHistory) {
			Enable('Tick');
			IGPlus_bResyncAfterHit = true;
			if (IGPlus_SyncAge == 0.0)
				IGPlus_SyncAge = IGPlus_CurrentAge() + 0.05;
		}
		if (bIGPlusFullHistory == false)
			IGPlus_bChangedEarly = true;
		if (ST_Translocator(Master) != None) {
			// The thrower's own hitscan: push the disc at the point of its
			// path the thrower saw, not where it is now.
			if (EventInstigator == Instigator && IGPlus_OwnShotFrame == Level.TimeSeconds) {
				IGPlus_OwnShotFrame = 0.0;
				ST_Translocator(Master).IGPlus_DetRebaseDisc(self, IGPlus_OwnShotAge);
			}
			ST_Translocator(Master).IGPlus_DetServerDiscChanged(self, 0.0, false, true);
		}

		if (Disruption == OldDisruption)
			return;

		if (Master != none && Master.Owner != none && Master.Owner.IsA('bbPlayer'))
			bbPlayer(Master.Owner).ClientDebugMessage("TTarget took"@Damage@"damage (Total"@int(Disruption)$")");
	}

	singular function Touch(Actor Other) {
		local bool bMasterTouch;
		local vector NewPos;
		local UTPlusDummy Dummy;
		local Pawn ActualPawn;
		local vector OldVelocity;
		
		// The thrower's own client disc: stopped by the players on its screen,
		// as stock stops a flying disc on any player but the thrower. The
		// server stops its copy on them where the thrower saw them
		// (IGPlus_DetRewoundStop). Nothing else here touches it.
		if (IGPlus_bLocalDisc) {
			if (Other.bIsPawn && Other != Instigator && Physics != PHYS_None && IGPlus_bRebasing == false) {
				NewPos = Other.Location;
				NewPos.Z = Location.Z;
				SetLocation(NewPos);
				Velocity = vect(0,0,0);
				IGPlus_PathEvent(false); // asks the server where its copy is
			}
			return;
		}
		if (Other.IsA('ST_HitTestHelper') || IGPlus_bDetSweeping)
			return;
		// Deterministic disc on the server: not where players are now, nor
		// where another player's shot just rewound them. The thrower still
		// picks it up.
		if ((Other.IsA('UTPlusDummy') || (Other.bIsPawn && Other != Instigator)) && IGPlus_DetJudgesRewound())
			return;
		OldVelocity = Velocity;
			
		// Handle UTPlusDummy touches during lag compensation
		if (Other.IsA('UTPlusDummy')) {
			Dummy = UTPlusDummy(Other);
			if (Dummy.Actual != None) {
				ActualPawn = Dummy.Actual;
				
				// Check if it's the master (owner) touching their own disc
				bMasterTouch = (ActualPawn == Instigator);
				
				if (Physics == PHYS_None) {
					if (bMasterTouch) {
						IGPlus_DetLogTouch("picked-up-by-thrower", ActualPawn);
						PlaySound(Sound'Botpack.Pickups.AmmoPick',,2.0);
						Master.TTarget = None;
						Master.bTTargetOut = false;
						if (ActualPawn.IsA('PlayerPawn'))
							PlayerPawn(ActualPawn).ClientWeaponEvent('TouchTarget');
						destroy();
					}
					return;
				}
				
				if (bMasterTouch)
					return;
					
				// Stick to the dummy's location
				NewPos = Dummy.Location;
				NewPos.Z = Location.Z;
				SetLocation(NewPos);
				Velocity = vect(0,0,0);
				IGPlus_DetLogTouch("stopped-by-rewound-player", ActualPawn);
				IGPlus_NoteChanged();
				
				// Check team game rules
				if (Level.Game.bTeamGame && 
					ActualPawn.PlayerReplicationInfo != None &&
					Instigator.PlayerReplicationInfo != None &&
					(Instigator.PlayerReplicationInfo.Team == ActualPawn.PlayerReplicationInfo.Team))
					return;
					
				// Bot auto-translocate
				if (Instigator.IsA('Bot'))
					Master.Translocate();
					
				return;
			}
		}
		
		// Original touch handling for non-dummy actors
		super.Touch(Other);
		if (bDeleteMe && Other == Instigator)
			IGPlus_DetLogTouch("picked-up-by-thrower", Other);
		// Stock sticks the disc to pawns and bounces it off other actors.
		if (bDeleteMe == false && Velocity != OldVelocity) {
			if (Other.bIsPawn)
				IGPlus_DetLogTouch("stopped-by-player", Other);
			else
				IGPlus_DetLogTouch("bounced-off-actor", Other);
			IGPlus_NoteChanged();
		}
	}
}

defaultproperties {
	MaxHistorySteps=50
	bSimFall=True
}