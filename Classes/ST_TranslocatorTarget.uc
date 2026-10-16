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
var bool IGPlus_bRebasing;      // re-flying after the thrower's own hit
var bool IGPlus_bLocalDisc;     // client: the thrower's own deterministic disc
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
		&& (bbP.ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations || bbP.IGPlus_PredictedTranslocation)))) {

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
function IGPlus_RecordHistory(float Age) {
    local int i;
    local byte bLanded;

    if (HistoryCount <= 0)
        return;

    i = HistoryCount - 1;
    if (Age <= SimulationTimes[i])
        return;

    bLanded = byte(Physics == PHYS_None);
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

auto state Pickup {
	simulated function Tick(float DeltaTime) {
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
			IGPlus_RecordHistory(TotalSimulationTime + (Level.TimeSeconds - DeltaTime - IGPlus_HistoryAnchor));
			if (DesiredTarget == None || Master == None)
				return;
		}
		super.Tick(DeltaTime);
	}

	simulated event Landed(vector HitNormal) {
		super.Landed(HitNormal);

		// Record where it came to rest (Landed switched Tick off). A re-fly
		// records its own steps.
		if (bIGPlusFullHistory && Role == ROLE_Authority && IGPlus_HistoryAnchor != 0.0 && IGPlus_bRebasing == false)
			IGPlus_RecordHistory(TotalSimulationTime + (Level.TimeSeconds - IGPlus_HistoryAnchor));
	}

	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
		local float OldDisruption;

		OldDisruption = Disruption;

		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

		// Landed() switched Tick off; a knocked disc flies again.
		if (bIGPlusFullHistory)
			Enable('Tick');
		if (bIGPlusFullHistory == false)
			IGPlus_bChangedEarly = true;
		if (ST_Translocator(Master) != None) {
			// The thrower's own hitscan: push the disc at the point of its
			// path the thrower saw, not where it is now.
			if (EventInstigator == Instigator && IGPlus_OwnShotFrame == Level.TimeSeconds) {
				IGPlus_OwnShotFrame = 0.0;
				ST_Translocator(Master).IGPlus_DetRebaseDisc(self, IGPlus_OwnShotAge);
			}
			ST_Translocator(Master).IGPlus_DetServerDiscChanged(self);
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
		
		// The thrower's own client disc only collides to be stopped by lifts.
		if (IGPlus_bLocalDisc)
			return;
		if (Other.IsA('ST_HitTestHelper'))
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
		// Stock sticks the disc to pawns and bounces it off other actors.
		if (bDeleteMe == false && Velocity != OldVelocity)
			IGPlus_NoteChanged();
	}
}

defaultproperties {
	MaxHistorySteps=50
	bSimFall=True
}