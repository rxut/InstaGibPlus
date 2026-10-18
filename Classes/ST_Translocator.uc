// ===============================================================
// Stats.ST_Translocator: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_Translocator extends Translocator;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var ST_TranslocatorTarget TTarget_Client;

var float ServerTimeSinceLastFire;
var float ServerTimeSinceTargetSpawn;

var float LastClientDiscSpawnTime;
var float LastClientFireSoundTime;
// Client: the local disc was thrown with margin on the server's 0.5s gate,
// so predicted translocation may land on it.
var bool IGPlus_bClientDiscConfident;

// Server, predicted translocation: timestamp of the move that threw the disc.
var float IGPlus_ThrowTS;
// The owner's disc, so the client finds it even when Instigator isn't
// replicated (a disc that lands during the fast-forward is a DumbProxy).
var ST_TranslocatorTarget IGPlus_DiscRepl;

// Deterministic translocator (bEnableDeterministicTranslocator). Throw, recall
// and translocate follow the same rules on both machines, on move
// timestamps: throw 0.5s after the last throw or recall, recall 0.8s after
// the throw, 0.1s between attempts (stock NormalFire). The client acts on its
// own frame and puts what it did in the move (DetChargeData, unused by the
// translocator otherwise); the server repeats that on the same move when its
// state allows, and never acts on its own. The thrower watches its own disc
// for the whole flight; the server's copy is hidden on its screen.
const IGPLUS_DETTLOC_THROW = 1;
const IGPLUS_DETTLOC_RECALL = 2;
const IGPLUS_DETTLOC_TRANSLOCATE = 3;
const IGPLUS_DETTLOC_REFUSED = 4; // with TRANSLOCATE: the thrower didn't fit at its disc

var float IGPlus_DetLastAttemptTS;
var float IGPlus_DetLastFireTS;               // last throw or recall
var bool IGPlus_bDetExpectOut;                // server: a disc the client knows about is out
var float IGPlus_DetThrowTS;                  // client: throw of the disc that is out
var bool IGPlus_bDetOut;                      // client: our disc is out
var ST_TranslocatorTarget IGPlus_DetLocalDisc; // client: the disc we watch
var bool IGPlus_bDetShowServerDisc;           // client: no own disc, show the server's
// Client: the server's disc was knocked; apply once ours reaches that age.
var bool IGPlus_bDetKnockPending;
var vector IGPlus_DetKnockLoc, IGPlus_DetKnockVel;
var bool IGPlus_bDetKnockLanded;
var bool IGPlus_bDetKnockBounce, IGPlus_bDetKnockHit; // its bBounce, bAlreadyHit (bounces left)
var float IGPlus_DetKnockAge;
var float IGPlus_DetLastActionTS;              // client: move time of our last action
var float IGPlus_DetLastSyncAskTS;             // client: last time our disc's bounce asked for the server's
var float IGPlus_DetPredictTS;                 // client: move time of our last predicted disc boost
var int IGPlus_DetLatchedPress;                // client: 1 fire, 2 alt pressed during bring-up
var float IGPlus_DetLatchTS;
// Server: throw time of the disc that is out (0 if none), and the last move
// it processed. Once that move is past the client's last action, the client
// matches the disc state (its safety net).
// One struct, so both always arrive together: a lone property lost in a
// packet is resent about a round trip later, while the move time (new every
// tick) keeps arriving. The client then saw "server is past my throw, no disc
// out", dropped its disc, and showed the server's a moment later.
struct IGPlus_DetServerState {
	var float DiscTS;
	var float MoveTS;
};
var IGPlus_DetServerState IGPlus_DetServer;

// Client: a translocate we didn't make ourselves (no prediction): our disc
// stays in view until the server's teleport reaches us.
var ST_TranslocatorTarget IGPlus_DetLingerDisc;
var float IGPlus_DetLingerUntil;
var int IGPlus_DetLingerTloc;

replication
{
    // Replicate server timing for synchronization
    unreliable if( Role==ROLE_Authority )
        ServerTimeSinceLastFire, ServerTimeSinceTargetSpawn;
    reliable if (bNetOwner && Role == ROLE_Authority)
        IGPlus_DiscRepl, IGPlus_DetServer;
    reliable if (Role == ROLE_Authority)
        IGPlus_ClientDetSync, IGPlus_ClientDetKnock;
}

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

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;		// Find master :D

}

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (Role == ROLE_Authority)
    {
        ServerTimeSinceLastFire += DeltaTime;
        
        // Only increment if target is out
        if (TTarget != None)
        {
            ServerTimeSinceTargetSpawn += DeltaTime;
        }

        // Picked up, gibbed, destroyed: anything the client didn't do itself.
        if (IGPlus_bDetExpectOut && TTarget == None)
        {
            IGPlus_bDetExpectOut = false;
            IGPlus_ClientDetSync(false, IGPlus_ThrowTS, 0.0);
        }

        if (TTarget == None || ST_TranslocatorTarget(TTarget) == None || ST_TranslocatorTarget(TTarget).bIGPlusFullHistory == false)
            IGPlus_DetServer.DiscTS = 0.0;
        else
            IGPlus_DetServer.DiscTS = IGPlus_ThrowTS;
        if (bbPlayer(Owner) != None) {
            IGPlus_DetServer.MoveTS = bbPlayer(Owner).CurrentTimeStamp;
            // An action held back (pause, warp fix) is not past yet: the
            // client's safety net must not take our disc state for its answer.
            if (bbPlayer(Owner).IGPlus_DetHeldCount > 0)
                IGPlus_DetServer.MoveTS = FMin(IGPlus_DetServer.MoveTS, bbPlayer(Owner).IGPlus_DetHeldTS[0] - 0.0001);
        }
    }
}

simulated function bool ClientFire(float Value)
{
	local bbPlayer bbP;
	local float CompensatedTime, PingCompensation;
	local bool bOut;

	bbP = bbPlayer(Owner);

	if (bbP == None)
		return false;

    CheckDualButtonSetting();

	// Deterministic: xxReplicateMove's step decides. Returning true keeps the
	// press in the move (PlayerPawn.Fire sets bJustFired from this).
	if (bbP.IGPlus_DetTranslocator && Role < ROLE_Authority)
		return true;

	// PingAverage is real time; the timer runs in game time.
	PingCompensation = bbP.PingAverage * 0.001 * Level.TimeDilation;
	CompensatedTime = ServerTimeSinceLastFire + PingCompensation;

	// A predicted translocation already used the disc up; the server's
	// bTTargetOut=false is still a ping away. Without this, a throw right
	// after a translocate gets no client-side throw.
	bOut = bTTargetOut;
	if (bOut && bbP.IGPlus_TlocPredictTS > LastClientFireSoundTime
		&& Level.TimeSeconds - bbP.IGPlus_TlocPredictTS < bbP.PlayerReplicationInfo.Ping * 0.002 * Level.TimeDilation + 0.25)
		bOut = false;
    
    if ( !bOut && bCanClientFire && (CompensatedTime > 0.45) )
    {
		// Prevent duplicate firing sounds on client
		if ((Level.TimeSeconds - LastClientFireSoundTime) < 0.45)
			return false;

		// Predicted translocation only lands on a local disc the server surely
		// threw too (its gate is ServerTimeSinceLastFire > 0.5).
		IGPlus_bClientDiscConfident = CompensatedTime > 0.55;
		if (Role < ROLE_Authority && GetWeaponSettings().TranslocatorCompensatePing && bbP != none && bbP.ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations == true)
			ClientThrowTarget();

		LastClientFireSoundTime = Level.TimeSeconds;
        PlayFiring();
        return true;
    }
	else if ( bOut && bCanClientFire && (ServerTimeSinceTargetSpawn > 0.8) )
	{
		return false;
	}

    return false;
}

simulated function ClientThrowTarget()
{
    local vector Start, X,Y,Z;
    local bbPlayer bbP;
	local float Hand;

    bbP = bbPlayer(Owner);

    if (bbP == None)
     	return;
	
	// Don't spawn if we already have a recent client disc
	if ((Level.TimeSeconds - LastClientDiscSpawnTime) < 0.5)
	{
		return;
	}

	if (TTarget_Client != None)
	{
		TTarget_Client.Destroy();
		TTarget_Client = None;
	}

	if (Owner.IsA('PlayerPawn'))
				Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
			else
				Hand = 1.0;

	if (bHideWeapon)
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
	else
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;

	bbP.ViewRotation = bbP.AdjustToss(TossForce, Start, 0, true, true);

	GetAxes(bbP.ViewRotation,X,Y,Z);

	TTarget_Client = Spawn(class'ST_TranslocatorTarget', Owner,, Start, IGPlus_ClientDiscRotation());

	LastClientDiscSpawnTime = Level.TimeSeconds;

	if (TTarget_Client != None)
	{
		TTarget_Client.Master = self;
		TTarget_Client.RemoteRole = ROLE_None;
		TTarget_Client.bCollideWorld = false;
		TTarget_Client.SetCollision(false, false, false);
		TTarget_Client.Throw(bbP, MaxTossForce, Start);
		// Predicted translocation lands on this disc until the server's arrives,
		// so it must bounce off the world like the server's does. Only after
		// Throw: its SetLocation must not fail on world collision (eaf4d45).
		TTarget_Client.bCollideWorld = bbP.IGPlus_PredictedTranslocation;

		// Backup removal of client disc
		TTarget_Client.LifeSpan = Pawn(Owner).PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
		if (bbP.IGPlus_PredictedTranslocation)
			TTarget_Client.LifeSpan = FMax(TTarget_Client.LifeSpan, Pawn(Owner).PlayerReplicationInfo.Ping * 0.002 * Level.TimeDilation + 0.1);
	}
}

// Keep both press and release boundaries: combining disjoint holds must
// never activate the stock return-to-previous-weapon shortcut.
static final function bool CanMergeFireInput(bool OldFire, bool OldAltFire, bool NewFire, bool NewAltFire) {
	return OldFire == NewFire && OldAltFire == NewAltFire;
}

function ReturnToPreviousWeapon()
{
	if (Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_EnableDualButtonSwitch == false)
		return;
	Super.ReturnToPreviousWeapon();
}

function Translocate()
{
	local ST_TranslocatorTarget STTarget;
	local vector OriginalLocation;
	local bbPlayer bbP;

	bbP = bbPlayer(Owner);

	STTarget = ST_TranslocatorTarget(TTarget);
	
	// Store original location in case we need to restore it
	if (STTarget != None && STTarget.bUsingHistoricalPosition)
	{
		OriginalLocation = STTarget.PreTranslocateLocation;
	}
	
	if (Owner.IsA('bbPlayer'))
		bbPlayer(Owner).IGPlus_BeforeTranslocate();
		
	// Call base translocate - this will use whatever location TTarget is currently at
	Super.Translocate();
	
	// If we used a historical position, restore the target's original location
	// (although it's likely destroyed by now)
	if (STTarget != None && !STTarget.bDeleteMe && STTarget.bUsingHistoricalPosition)
	{
		STTarget.SetLocation(OriginalLocation);
		if (STTarget.bIGPlusFullHistory) {
			STTarget.SetCollision(STTarget.IGPlus_PreCollideActors, STTarget.IGPlus_PreBlockActors, STTarget.IGPlus_PreBlockPlayers);
			if (STTarget.Physics != STTarget.IGPlus_PreTranslocatePhysics) {
				STTarget.SetPhysics(STTarget.IGPlus_PreTranslocatePhysics);
				STTarget.Velocity = STTarget.IGPlus_PreTranslocateVelocity;
			}
		}
		STTarget.bUsingHistoricalPosition = false;
	}
	
	if (Owner.IsA('bbPlayer'))
		bbPlayer(Owner).IGPlus_AfterTranslocate();
}

function ThrowTarget()
{
	local Vector Start, X,Y,Z;
	local bbPlayer bbP;

	bbP = bbPlayer(Owner);

	if (Level.Game.LocalLog != None)
		Level.Game.LocalLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	if (Level.Game.WorldLog != None)
		Level.Game.WorldLog.LogSpecialEvent("throw_translocator", Pawn(Owner).PlayerReplicationInfo.PlayerID);

	if ( Owner.IsA('Bot') )
		bBotMoveFire = true;
	Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	Pawn(Owner).ViewRotation = Pawn(Owner).AdjustToss(TossForce, Start, 0, true, true);
	GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	TTarget = Spawn(class'ST_TranslocatorTarget',,, Start);

	if (TTarget!=None)
	{
		bTTargetOut = true;
		TTarget.Master = self;
		TTarget.DisruptionThreshold = GetWeaponSettings().TranslocatorHealth;
		if ( Owner.IsA('Bot') )
			TTarget.SetCollisionSize(0,0);
		TTarget.Throw(Pawn(Owner), MaxTossForce, Start);

		ServerTimeSinceTargetSpawn = 0.0;
		
		// Apply ping compensation with position history. Not for the
		// deterministic translocator: its disc already follows the thrower's
		// own moves, and a fast-forward would put the server's disc a ping
		// ahead of the thrower's (others see it pop out ahead, it lands early).
		if (bbP != none && GetWeaponSettings().TranslocatorCompensatePing && IGPlus_IsDetMode() == false) {
			// Cast to ST_TranslocatorTarget to access history functions
			ST_TranslocatorTarget(TTarget).SimulateWithHistory(WImp, bbP.PingAverage);
		}

		// Without ping comp the deterministic translocator still looks the
		// disc up by age: start its history at the throw.
		if (IGPlus_IsDetMode() && TTarget != None
			&& ST_TranslocatorTarget(TTarget).HistoryCount == 0)
			ST_TranslocatorTarget(TTarget).InitSimulationHistory(TTarget.Location, 0.0, 0.0);

		if (bbP != none && (GetWeaponSettings().TranslocatorCompensatePing || IGPlus_IsDetMode())) {
			// Fragger's Translocate() has no restore path: stock lookup only.
			if ((bbP.IGPlus_PredictedTranslocation || IGPlus_IsDetMode())
				&& TTarget != None && Class == class'ST_Translocator') {
				IGPlus_ThrowTS = bbP.CurrentTimeStamp;
				IGPlus_DiscRepl = ST_TranslocatorTarget(TTarget);
				IGPlus_DiscRepl.bIGPlusFullHistory = true;
				// Ping over PingCompensationMax: the thrower sees a younger
				// server disc. Not without ping comp (nothing fast-forwarded),
				// nor deterministic (the thrower watches its own disc).
				if (GetWeaponSettings().TranslocatorCompensatePing && IGPlus_IsDetMode() == false)
					IGPlus_DiscRepl.IGPlus_AgeBias = FMax(0.0,
						float(bbP.PingAverage) * 0.001 * Level.TimeDilation - IGPlus_DiscRepl.TotalSimulationTime);
				// Landed during the fast-forward: Tick is off until a knock.
				if (IGPlus_DiscRepl.Physics == PHYS_None)
					IGPlus_DiscRepl.IGPlus_HistoryAnchor = Level.TimeSeconds;
				// Shot, stuck or bounced during the fast-forward: tell the thrower.
				if (IGPlus_DiscRepl.IGPlus_bChangedEarly)
					IGPlus_DetServerDiscChanged(IGPlus_DiscRepl);
			}
		}
	}
	else GotoState('Idle');
}

function AltFire( float Value )
{
    local bbPlayer bbP;
    local float TimeSinceThrow;
    local vector HistoricalLocation;
    local ST_TranslocatorTarget STTarget;
    
    if ( bBotMoveFire )
        return;
    if (IGPlus_IsDetMode())
        return;

    GotoState('NormalFire');

    if ( TTarget != None )
    {
        bbP = bbPlayer(Owner);
        STTarget = ST_TranslocatorTarget(TTarget);
        
        // Predicted translocation: the disc where it was at this move's age
        // since the throw, in the client's own timeline (what its screen showed).
        if (STTarget != None && STTarget.bIGPlusFullHistory && bbP != none)
        {
            IGPlus_MoveDiscToSeenAge(STTarget, bbP);
        }
         // CHECK 1: Are we inside the recorded history? (Standard High-Ping Behavior)
        else if (STTarget != None && STTarget.HistoryCount > 0 && ServerTimeSinceTargetSpawn < STTarget.TotalSimulationTime)
        {
            TimeSinceThrow = ServerTimeSinceTargetSpawn;
            HistoricalLocation = STTarget.GetHistoricalPosition(TimeSinceThrow);
            
            STTarget.PreTranslocateLocation = STTarget.Location;
            STTarget.SetLocation(HistoricalLocation);
            STTarget.bUsingHistoricalPosition = true;
        }
        // CHECK 2: Are we OUTSIDE the history? (Fix for Low-Ping to maintain LAN behavior)
        else if (STTarget != None && bbP != none && GetWeaponSettings().TranslocatorCompensatePing)
        {
            // Convert real ping time to game time by multiplying by TimeDilation
            HistoricalLocation = STTarget.Location - (STTarget.Velocity * (float(bbP.PingAverage) * 0.5 * 0.001 * Level.TimeDilation));

            STTarget.PreTranslocateLocation = STTarget.Location;
            STTarget.SetLocation(HistoricalLocation);
            STTarget.bUsingHistoricalPosition = true;
        }

        if (TTarget == None)
            return;

        if (IGPlus_GibIfDisrupted())
            return;
        
        // Translocate() clears TTarget itself when the disc is used up. When
        // translocation is refused (AllowTranslocation, e.g. CTF flag carrier)
        // the disc stays out, so keep the reference or the next Fire throws a
        // second disc while the first is still in the world.
        Translocate();
    }
}

function Fire( float Value )
{
    local bbPlayer bbP;
    local float TimeSinceThrow;
    local vector HistoricalLocation;
    local ST_TranslocatorTarget STTarget;

    bbP = bbPlayer(Owner);

    if (bbP == None)
        return;

    if ( bBotMoveFire )
        return;
    if (IGPlus_IsDetMode())
        return;

    if (  TTarget == None )
    {
        if ( ServerTimeSinceLastFire > 0.5 )
        {
            bPointing=True;
            bCanClientFire = true;
            ClientFire(value);
            Pawn(Owner).PlayRecoil(FiringSpeed);
            ThrowTarget();
            
            // Reset fire timer
            ServerTimeSinceLastFire = 0.0;
        }
    }
    else if ( ServerTimeSinceTargetSpawn > 0.8 )
    {
        STTarget = ST_TranslocatorTarget(TTarget);
        
        // Check if we should use position history
         // CHECK 1: Are we inside the recorded history? (Standard High-Ping Behavior)
        if (STTarget != None && STTarget.HistoryCount > 0 && ServerTimeSinceTargetSpawn < STTarget.TotalSimulationTime)
        {
            TimeSinceThrow = ServerTimeSinceTargetSpawn;
            HistoricalLocation = STTarget.GetHistoricalPosition(TimeSinceThrow);
            
            STTarget.PreTranslocateLocation = STTarget.Location;
            STTarget.SetLocation(HistoricalLocation);
            STTarget.bUsingHistoricalPosition = true;
        }
        // CHECK 2: Are we OUTSIDE the history? (Fix for Low-Ping to maintain LAN behavior)
        else if (STTarget != None && bbP != none && GetWeaponSettings().TranslocatorCompensatePing)
        {
            // Convert real ping time to game time by multiplying by TimeDilation
            HistoricalLocation = STTarget.Location - (STTarget.Velocity * (float(bbP.PingAverage) * 0.5 * 0.001 * Level.TimeDilation));

            STTarget.PreTranslocateLocation = STTarget.Location;
            STTarget.SetLocation(HistoricalLocation);
            STTarget.bUsingHistoricalPosition = true;
        }

        if ( TTarget.Disrupted() )
        {
            if (Level.Game.LocalLog != None)
                Level.Game.LocalLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);
            if (Level.Game.WorldLog != None)
                Level.Game.WorldLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);

            Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_None, 4.0);
            Pawn(Owner).gibbedBy(TTarget.disruptor);
            return;
        }
        Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
        bTTargetOut = false;
        TTarget.Destroy();
        TTarget = None;
        
        // Reset both timers
        ServerTimeSinceLastFire = 0.0;
        ServerTimeSinceTargetSpawn = 0.0;
    }

    GotoState('NormalFire');
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	IGPlus_DetLatchedPress = 0;
	if ( bTTargetOut )
		TweenAnim('ThrownFrame', GetWeaponSettings().TranslocatorOutSelectTime);
	else
		PlayAnim('Select',GetWeaponSettings().TranslocatorSelectAnimSpeed(), 0.0);
	PlaySound(SelectSound, SLOT_Misc,Pawn(Owner).SoundDampening);		
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().TranslocatorDownTime );
	else if ( bTTargetOut )
		PlayAnim('Down2', GetWeaponSettings().TranslocatorDownAnimSpeed(), TweenTime);
	else
		PlayAnim('Down', GetWeaponSettings().TranslocatorDownAnimSpeed(), TweenTime);
}

simulated function vector CalcDrawOffsetClient() {
	local vector DrawOffset;
	local Pawn PawnOwner;
	local vector WeaponBob;
	
	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return vect(0,0,0);

	DrawOffset = CalcDrawOffset();
	
	// On client, make adjustments to match server
	if (Level.NetMode == NM_Client) {
		// Correct for EyeHeight differences
		DrawOffset -= (PawnOwner.EyeHeight * vect(0,0,1));
		DrawOffset += (PawnOwner.BaseEyeHeight * vect(0,0,1));
	
		// Remove WeaponBob, not applied on server
		WeaponBob = BobDamping * PawnOwner.WalkBob;
		WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
		DrawOffset -= WeaponBob;
	}
	
	return DrawOffset;
}

// --- Shared translocation helpers ----------------------------------------------

// Server, predicted translocation: move the disc to where it was at this
// move's age since the throw, in the client's own timeline (what its screen
// showed). Translocate() restores it if the disc survives.
// Late: how late a resent translocate runs (our disc is that much older now).
function IGPlus_MoveDiscToSeenAge(ST_TranslocatorTarget STTarget, bbPlayer bbP, optional float Late) {
	local float TimeSinceThrow;
	local vector HistoricalLocation;
	local byte HistoricalLanded;

	// ponytail: +-0.2s bounds how far a client clock can move the lookup
	TimeSinceThrow = FClamp(
		bbP.CurrentTimeStamp - IGPlus_ThrowTS,
		ServerTimeSinceTargetSpawn - Late - 0.2,
		ServerTimeSinceTargetSpawn - Late + 0.2);
	if (IGPlus_IsDetMode()) {
		bbP.IGPlus_DetTlocInfo = "clientAge="$(bbP.CurrentTimeStamp - IGPlus_ThrowTS)
			@"usedAge="$TimeSinceThrow@"discAge="$STTarget.IGPlus_CurrentAge()@STTarget.IGPlus_DetPathSummary();
		// The disc is younger here than on the thrower's screen past what the
		// lookup flies it on (50ms): the throw's move came in late.
		if (TimeSinceThrow != bbP.CurrentTimeStamp - IGPlus_ThrowTS
			|| TimeSinceThrow - STTarget.IGPlus_AgeBias > STTarget.IGPlus_CurrentAge() + 0.05)
			IGPlus_DetLog("translocate-age", bbP.IGPlus_DetTlocInfo);
	}
	HistoricalLocation = STTarget.IGPlus_GetHistoryAt(FMax(TimeSinceThrow - STTarget.IGPlus_AgeBias, 0.0), HistoricalLanded);

	STTarget.PreTranslocateLocation = STTarget.Location;
	STTarget.IGPlus_PreTranslocatePhysics = STTarget.Physics;
	STTarget.IGPlus_PreTranslocateVelocity = STTarget.Velocity;
	STTarget.IGPlus_PreCollideActors = STTarget.bCollideActors;
	STTarget.IGPlus_PreBlockActors = STTarget.bBlockActors;
	STTarget.IGPlus_PreBlockPlayers = STTarget.bBlockPlayers;
	// No touches while moved back: picking the disc up or sticking it
	// to someone here would be a translocation the client never saw.
	STTarget.SetCollision(false, false, false);
	STTarget.SetLocation(HistoricalLocation);
	// Translocate() adds 40 up for a landed disc: use the landed state at that age.
	if ((HistoricalLanded != 0) != (STTarget.Physics == PHYS_None)) {
		if (HistoricalLanded != 0)
			STTarget.SetPhysics(PHYS_None);
		else
			STTarget.SetPhysics(PHYS_Falling);
	}
	STTarget.bUsingHistoricalPosition = true;
}

// Server: a disrupted disc gibs the player that uses it.
function bool IGPlus_GibIfDisrupted() {
	local Pawn Disruptor;

	if (TTarget == None || TTarget.Disrupted() == false)
		return false;

	if (Level.Game.LocalLog != None)
		Level.Game.LocalLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);
	if (Level.Game.WorldLog != None)
		Level.Game.WorldLog.LogSpecialEvent("translocate_gib", Pawn(Owner).PlayerReplicationInfo.PlayerID);

	Pawn(Owner).PlaySound(sound'TDisrupt', SLOT_None, 4.0);

	// Clean up the target BEFORE gibbing the player
	Disruptor = TTarget.Disruptor;
	bTTargetOut = false;
	TTarget.Destroy();
	TTarget = None;

	// Reset both timers
	ServerTimeSinceLastFire = 0.0;
	ServerTimeSinceTargetSpawn = 0.0;

	Pawn(Owner).gibbedBy(Disruptor);
	return true;
}

// --- Deterministic translocator -------------------------------------------------

// Server: deterministic for remote players only; a listen server's own or an
// offline player has no moves and keeps the stock translocator.
function bool IGPlus_IsDetMode() {
	return bbPlayer(Owner) != None && bbPlayer(Owner).IGPlus_DetTranslocator
		&& Owner.RemoteRole == ROLE_AutonomousProxy && Class == class'ST_Translocator';
}

// Client, at the start of its frame (before movement): decide and act.
// Returns the action for the move, 0 for none.
simulated function int IGPlus_DetClientStep(bbPlayer P, float TS, bool bFirePress, bool bFireHeld, bool bAltPress, bool bAltHeld) {
	local bool bFireIn, bAltIn;
	local int Action;

	if (P.Weapon != self || P.ClientPending != None || IsInState('ClientDown'))
		return 0;
	// Stock remembers a click during bring-up (bForceFire) and fires once up.
	if (IsInState('ClientActive')) {
		// Stock's bring-up keeps both and fires first (bForceFire wins).
		if (bFirePress || (bAltPress && IGPlus_DetLatchedPress != 1)) {
			if (bFirePress)
				IGPlus_DetLatchedPress = 1;
			else
				IGPlus_DetLatchedPress = 2;
			IGPlus_DetLatchTS = TS;
		}
		return 0;
	}
	if (IGPlus_DetLatchedPress != 0) {
		if (bFirePress == false && bAltPress == false && TS - IGPlus_DetLatchTS < 0.5) {
			bFirePress = (IGPlus_DetLatchedPress == 1);
			bAltPress = (IGPlus_DetLatchedPress == 2);
		}
		IGPlus_DetLatchedPress = 0;
	}

	bFireIn = bFirePress || bFireHeld;
	bAltIn = bAltPress || bAltHeld;
	if (bFireIn == false && bAltIn == false)
		return 0;
	// Both with the two-button switch on: the server's call. Off, stock's Idle
	// tries Fire first and its NormalFire skips the alt-fire, so fire wins
	// (a throw right after a translocate while alt is still held).
	if (bFireIn && bAltIn && P.IGPlus_EnableDualButtonSwitch)
		return 0;
	// Stock NormalFire ignores fire and alt-fire for 0.1s after either; held
	// buttons retry every 0.1s (Idle.Begin).
	if (TS - IGPlus_DetLastAttemptTS < 0.1)
		return 0;
	IGPlus_DetLastAttemptTS = TS;

	if (bFireIn) {
		if (IGPlus_bDetOut == false) {
			if (TS - IGPlus_DetLastFireTS >= 0.5)
				Action = IGPLUS_DETTLOC_THROW;
		} else if (TS - IGPlus_DetThrowTS >= 0.8) {
			Action = IGPLUS_DETTLOC_RECALL;
		}
	} else if (IGPlus_bDetOut) {
		Action = IGPLUS_DETTLOC_TRANSLOCATE;
	}

	if (Action != 0) {
		IGPlus_DetLastActionTS = TS;
	}
	if (Action == IGPLUS_DETTLOC_THROW) {
		IGPlus_DetClientThrow(P, TS);
	} else if (Action == IGPLUS_DETTLOC_RECALL) {
		IGPlus_DetLastFireTS = TS; // a recall restarts the throw timer
		IGPlus_DetClientDiscGone();
	}
	return Action;
}

// Client: a disc spawns with our rotation, which here is the first-person
// weapon's (view pitch and weapon roll, set each frame by RenderOverlays).
// The server's disc gets the server weapon's level one: fly flat like it.
simulated function rotator IGPlus_ClientDiscRotation() {
	local rotator R;

	R = Rotation;
	R.Pitch = 0;
	R.Roll = 0;
	return R;
}

// Client: our own disc, from the same start, aim and frame as the server's.
simulated function IGPlus_DetClientThrow(bbPlayer P, float TS) {
	local vector Start;

	IGPlus_DetClientDiscGone();
	IGPlus_DetEndLinger();
	IGPlus_bDetOut = true;
	IGPlus_DetThrowTS = TS;
	IGPlus_DetLastFireTS = TS;
	P.IGPlus_DetTloc = self;

	// Same start as ThrowTarget (whose X/Y/Z are unset there as well).
	Start = Owner.Location + CalcDrawOffsetClient();
	P.ViewRotation = P.AdjustToss(TossForce, Start, 0, true, true);

	IGPlus_DetLocalDisc = Spawn(class'ST_TranslocatorTarget', Owner,, Start, IGPlus_ClientDiscRotation());
	if (IGPlus_DetLocalDisc != None) {
		IGPlus_DetLocalDisc.IGPlus_bLocalDisc = true;
		IGPlus_DetLocalDisc.Instigator = P;
		IGPlus_DetLocalDisc.Master = self;
		IGPlus_DetLocalDisc.RemoteRole = ROLE_None;
		IGPlus_DetLocalDisc.bCollideWorld = false;
		IGPlus_DetLocalDisc.SetCollision(false, false, false);
		IGPlus_DetLocalDisc.Throw(P, MaxTossForce, Start);
		// Only after Throw, so DropFrom's SetLocation can't fail (eaf4d45).
		// Then collide like the server's disc, so lifts and doors stop it too
		// (its Touch ignores everything; nothing here may shoot it).
		IGPlus_DetLocalDisc.bCollideWorld = true;
		IGPlus_DetLocalDisc.bProjTarget = false;
		IGPlus_DetLocalDisc.SetCollision(true, false, false);
	}

	PlayFiring();
}

// Client: we pressed translocate. bMoved: we teleported ourselves (predicted
// translocation). Else our disc stays in view until the server's teleport
// reaches us (its correction changes our translocate count), a ping and a bit
// at most, instead of vanishing a ping before we move.
simulated function IGPlus_DetClientTranslocated(bool bMoved) {
	IGPlus_DetEndLinger();
	if (bMoved == false && bbPlayer(Owner) != None
		&& IGPlus_DetLocalDisc != None && IGPlus_DetLocalDisc.bDeleteMe == false) {
		IGPlus_DetLingerDisc = IGPlus_DetLocalDisc;
		IGPlus_DetLocalDisc = None;
		IGPlus_DetLingerTloc = bbPlayer(Owner).TlocCounter;
		IGPlus_DetLingerUntil = Level.TimeSeconds
			+ bbPlayer(Owner).PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation + 0.15;
	}
	IGPlus_DetClientDiscGone();
}

simulated function IGPlus_DetEndLinger() {
	if (IGPlus_DetLingerDisc != None && IGPlus_DetLingerDisc.bDeleteMe == false)
		IGPlus_DetLingerDisc.Destroy();
	IGPlus_DetLingerDisc = None;
}

// Client: our disc is no more (recall, translocate, the server said so).
simulated function IGPlus_DetClientDiscGone() {
	IGPlus_bDetOut = false;
	IGPlus_bDetShowServerDisc = false;
	IGPlus_bDetKnockPending = false;
	if (IGPlus_DetLocalDisc != None) {
		IGPlus_DetLocalDisc.Destroy();
		IGPlus_DetLocalDisc = None;
	}
}

// Client: the disc a translocation goes to.
simulated function ST_TranslocatorTarget IGPlus_DetClientDisc() {
	if (IGPlus_DetLocalDisc != None && IGPlus_DetLocalDisc.bDeleteMe == false)
		return IGPlus_DetLocalDisc;
	if (IGPlus_bDetShowServerDisc && IGPlus_DiscRepl != None && IGPlus_DiscRepl.bDeleteMe == false)
		return IGPlus_DiscRepl;
	return None;
}

// Client, every frame: keep the server's copy of our disc hidden (unless it
// is the only one we have), and apply a knock once our disc reaches its age.
simulated function IGPlus_DetClientTick() {
	local ST_TranslocatorTarget S;

	if (IGPlus_DetLingerDisc != None && (Level.TimeSeconds > IGPlus_DetLingerUntil
		|| bbPlayer(Owner) == None || bbPlayer(Owner).TlocCounter != IGPlus_DetLingerTloc))
		IGPlus_DetEndLinger();

	// A disc out but ours gone some other way (not through DiscGone):
	// show the server's rather than nothing.
	if (IGPlus_bDetOut && IGPlus_bDetShowServerDisc == false
		&& (IGPlus_DetLocalDisc == None || IGPlus_DetLocalDisc.bDeleteMe))
		IGPlus_bDetShowServerDisc = true;

	S = IGPlus_DiscRepl;
	if (S != None && S.bDeleteMe == false) {
		// Not in demo playback: the disc shows itself there (ST_TranslocatorTarget).
		if (S.IGPlus_InDemoPlayback() == false)
			IGPlus_DetSetCopyHidden(S, IGPlus_bDetShowServerDisc == false);
		// Recording a demo: this hidden copy is all the demo has of our disc.
		// Keep it on our own disc, so the demo shows it where we saw it, and
		// at no size once ours is gone (translocated, recalled): only the
		// demo sees that on a hidden copy.
		if (S.bHidden && bbPlayer(Owner) != None && bbPlayer(Owner).zzbDemoRecording) {
			if (IGPlus_DetLocalDisc != None && IGPlus_DetLocalDisc.bDeleteMe == false) {
				S.SetLocation(IGPlus_DetLocalDisc.Location);
				S.SetRotation(IGPlus_DetLocalDisc.Rotation);
				S.Velocity = IGPlus_DetLocalDisc.Velocity;
				S.DrawScale = S.default.DrawScale;
			} else {
				S.DrawScale = 0.0;
			}
		}
	}

	if (IGPlus_bDetKnockPending && Level.TimeSeconds - IGPlus_DetThrowTS >= IGPlus_DetKnockAge)
		IGPlus_DetApplyKnock();

	// Safety net for lost actions and missed syncs: once the server has
	// processed past our last action, its disc state is the truth.
	if (IGPlus_DetServer.MoveTS > IGPlus_DetLastActionTS) {
		if (IGPlus_DetServer.DiscTS == 0.0) {
			if (IGPlus_bDetOut) {
				if (bbPlayer(Owner) != None)
					bbPlayer(Owner).ClientDebugMessage("Tloc safety net: the server has no disc out");
				IGPlus_DetClientDiscGone();
			}
		} else if (IGPlus_bDetOut == false || IGPlus_DetThrowTS != IGPlus_DetServer.DiscTS) {
			if (bbPlayer(Owner) != None)
				bbPlayer(Owner).ClientDebugMessage("Tloc safety net: showing the server's disc (ours out="$IGPlus_bDetOut
					@"throw="$IGPlus_DetThrowTS@"server's="$IGPlus_DetServer.DiscTS$")");
			IGPlus_DetClientDiscGone();
			IGPlus_bDetOut = true;
			IGPlus_DetThrowTS = IGPlus_DetServer.DiscTS;
			IGPlus_bDetShowServerDisc = true;
		}
	}
}

// Client: the server's copy of our disc, hidden (inert: nothing here may hit,
// hear or stop at it) or shown as it normally is.
static function IGPlus_DetSetCopyHidden(ST_TranslocatorTarget S, bool bHide) {
	if (S.Glow != None)
		S.Glow.bHidden = bHide;
	if (S.bHidden == bHide)
		return;
	S.bHidden = bHide;
	if (bHide) {
		// Still recorded by a client demo, hidden: playback shows it
		// (ST_TranslocatorTarget's Pickup.Tick). Only our demo recorder reads this here.
		S.bAlwaysRelevant = true;
		if (S.Shadow != None) {
			S.Shadow.Destroy();
			S.Shadow = None;
		}
		S.SetCollision(false, false, false);
		S.bProjTarget = false;
		S.AmbientSound = None;
		S.ImpactSound = None;
	} else {
		S.DrawScale = S.default.DrawScale;
		S.SetCollision(S.default.bCollideActors, S.default.bBlockActors, S.default.bBlockPlayers);
		S.bProjTarget = S.default.bProjTarget;
		S.AmbientSound = S.default.AmbientSound;
		S.ImpactSound = S.default.ImpactSound;
	}
}

// Server, on the move's step (before its movement): repeat the client's
// action if our state allows it, else tell the client how things are.
// Late: how late a resent action runs (its move was lost).
function IGPlus_DetServerStep(bbPlayer P, float TS, int Action, bool bFireHeld, bool bAltHeld, optional float Late) {
	local ST_TranslocatorTarget STTarget;
	local string Reason;
	local bool bRefused;
	local vector Dest;

	bRefused = (Action & IGPLUS_DETTLOC_REFUSED) != 0;
	Action = Action & 3;

	if (bFireHeld && bAltHeld && P.IGPlus_EnableDualButtonSwitch) {
		// Stock two-button shortcut (NormalFire's check).
		if (P.PendingWeapon == None)
			ReturnToPreviousWeapon();
		return;
	}
	if (Action < IGPLUS_DETTLOC_THROW || Action > IGPLUS_DETTLOC_TRANSLOCATE)
		return;

	// The client's attempt clock never lags ours (we only see its actions),
	// so these checks are never stricter than its own. 1ms for float noise.
	if (P.Weapon != self || IsInState('DownWeapon') || TS - IGPlus_DetLastAttemptTS < 0.099) {
		if (P.Weapon != self)
			Reason = "not-held";
		else if (IsInState('DownWeapon'))
			Reason = "holstering";
		else
			Reason = "0.1s-lockout";
		IGPlus_DetReject(Action, TS, Reason);
		return;
	}

	if (Action == IGPLUS_DETTLOC_THROW) {
		if (TTarget != None || TS - IGPlus_DetLastFireTS < 0.499) {
			if (TTarget != None)
				Reason = "disc-already-out";
			else
				Reason = "0.5s-throw-timer";
			IGPlus_DetReject(Action, TS, Reason);
			return;
		}
		IGPlus_DetLastAttemptTS = TS;
		IGPlus_DetLastFireTS = TS;
		bPointing = true;
		bCanClientFire = true;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		PlayFiring(); // others hear it (PlayOwnedSound skips the thrower)
		ThrowTarget();
		ServerTimeSinceLastFire = 0.0;
		// A late throw: our disc is as old as the thrower's, as if on time.
		if (Late > 0.005 && ST_TranslocatorTarget(TTarget) != None)
			IGPlus_DetFlyAhead(ST_TranslocatorTarget(TTarget), Late);
		if (TTarget == None) {
			IGPlus_DetLog("reject", "throw spawn-failed");
			IGPlus_ClientDetSync(false, TS, TS);
			return;
		}
		IGPlus_bDetExpectOut = true;
		return;
	}

	if (TTarget == None || (Action == IGPLUS_DETTLOC_RECALL && TS - IGPlus_ThrowTS < 0.799)) {
		if (TTarget == None)
			Reason = "no-disc";
		else
			Reason = "0.8s-recall-timer";
		IGPlus_DetReject(Action, TS, Reason);
		return;
	}
	IGPlus_DetLastAttemptTS = TS;
	IGPlus_bDetExpectOut = false;

	if (Action == IGPLUS_DETTLOC_RECALL) {
		IGPlus_DetLastFireTS = TS;
		if (TTarget.Disrupted())
			IGPlus_DetLog("gib", "recall of a disrupted disc");
		if (IGPlus_GibIfDisrupted())
			return;
		Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
		ServerTimeSinceLastFire = 0.0;
		ServerTimeSinceTargetSpawn = 0.0;
		return;
	}

	// Translocate
	STTarget = ST_TranslocatorTarget(TTarget);
	if (STTarget != None && STTarget.bIGPlusFullHistory)
		IGPlus_MoveDiscToSeenAge(STTarget, P, Late);
	if (TTarget != None && TTarget.Disrupted())
		IGPlus_DetLog("gib", "translocate to a disrupted disc");
	if (TTarget == None || IGPlus_GibIfDisrupted())
		return;
	// The thrower didn't fit at its disc (Predicted Translocation), so it
	// fails here too, as stock fails: refusing only ever costs the thrower.
	if (bRefused) {
		// Stock asks the game first (a CTF flag carrier drops the flag even
		// when it then doesn't fit).
		Dest = TTarget.Location;
		if (TTarget.Physics == PHYS_None)
			Dest += vect(0,0,40);
		if (DeathMatchPlus(Level.Game) != None && DeathMatchPlus(Level.Game).AllowTranslocation(Pawn(Owner), Dest) == false) {
			IGPlus_DetLog("reject", "translocate refused");
			IGPlus_bDetExpectOut = true;
			IGPlus_ClientDetSync(true, IGPlus_ThrowTS, TS);
			return;
		}
		IGPlus_DetLog("client-refused", "");
		Owner.PlaySound(AltFireSound, SLOT_Misc, 4 * Pawn(Owner).SoundDampening);
		bTTargetOut = false;
		TTarget.Destroy();
		TTarget = None;
		bPointing = true;
		return;
	}
	Translocate();
	// Refused (AllowTranslocation): the disc stays out, show it again.
	if (TTarget != None) {
		IGPlus_DetLog("reject", "translocate refused");
		IGPlus_bDetExpectOut = true;
		IGPlus_ClientDetSync(true, IGPlus_ThrowTS, TS);
	}
}

function IGPlus_DetReject(int Action, float TS, string Reason) {
	IGPlus_DetLog("reject", IGPlus_DetActionName(Action)@Reason);
	if (Action == IGPLUS_DETTLOC_THROW)
		IGPlus_ClientDetSync(false, TS, TS); // the disc it threw doesn't exist
	if (TTarget != None)
		IGPlus_ClientDetSync(true, IGPlus_ThrowTS, TS); // ours is still out
}

static function string IGPlus_DetActionName(int Action) {
	switch (Action & 3) {
		case IGPLUS_DETTLOC_THROW: return "throw";
		case IGPLUS_DETTLOC_RECALL: return "recall";
		case IGPLUS_DETTLOC_TRANSLOCATE: return "translocate";
	}
	return "action"$Action;
}

// Server: a disc thrown Late seconds late (its move was lost) flies on to
// the age the thrower's has, as IGPlus_DetRebaseDisc flies (world only).
function IGPlus_DetFlyAhead(ST_TranslocatorTarget T, float Late) {
	local float Done, Step;
	local bool bColActors, bBlkActors, bBlkPlayers;

	// ponytail: 0.5s at most, the resend's own limit is 1s
	Late = FMin(Late, 0.5);
	bColActors = T.bCollideActors;
	bBlkActors = T.bBlockActors;
	bBlkPlayers = T.bBlockPlayers;
	T.SetCollision(false, false, false);
	T.IGPlus_bRebasing = true;
	while (Done < Late && T.bDeleteMe == false && T.Physics != PHYS_None) {
		Step = FMin(Late - Done, 0.02);
		T.AutonomousPhysics(Step);
		Done += Step;
		T.IGPlus_RecordHistory(Done);
	}
	if (T.bDeleteMe)
		return;
	T.IGPlus_bRebasing = false;
	T.SetCollision(bColActors, bBlkActors, bBlkPlayers);
	T.TotalSimulationTime = Late;
	// Landed on the way: Tick is off, so its age counts from now.
	if (T.Physics == PHYS_None)
		T.IGPlus_HistoryAnchor = Level.TimeSeconds;
	ServerTimeSinceTargetSpawn = Late;
}

// Server: a [DET-TLOC] line about our disc (see bbPlayer.IGPlus_DetTlocLog).
function IGPlus_DetLog(string Event, string Details) {
	local ST_TranslocatorTarget T;

	if (bbPlayer(Owner) == None || IGPlus_IsDetMode() == false)
		return;
	T = ST_TranslocatorTarget(TTarget);
	if (T != None && T.bIGPlusFullHistory)
		Details = Details@"discAge="$T.IGPlus_CurrentAge()@T.IGPlus_DetPathSummary();
	bbPlayer(Owner).IGPlus_DetTlocLog(Event, Details);
}

// Client: the server's truth about our disc. DiscTS names the throw it means,
// so a sync about an old disc can't remove a newer one; ActionTS is the move
// it answers, so an answer older than our latest action can't undo it.
simulated function IGPlus_ClientDetSync(bool bOut, float DiscTS, float ActionTS) {
	if (bOut) {
		if (IGPlus_DetLastActionTS > ActionTS)
			return; // we acted since; the safety net settles it
		if (IGPlus_bDetOut && IGPlus_DetThrowTS >= DiscTS)
			return; // agree, or ours is newer and its own sync will follow
		IGPlus_DetClientDiscGone();
		IGPlus_bDetOut = true;
		IGPlus_DetThrowTS = DiscTS;
		IGPlus_bDetShowServerDisc = true;
		if (bbPlayer(Owner) != None)
			bbPlayer(Owner).IGPlus_DetTloc = self;
	} else if (IGPlus_bDetOut && IGPlus_DetThrowTS <= DiscTS) {
		IGPlus_DetClientDiscGone();
	}
}

// Server: something the client can't see moved our disc (a shot, sticking
// to a player). Its state now, at its age since the throw.
// Age: when the caller knows it better (the disc's Tick, before this frame's
// physics), else its age at the end of this frame. bAtRest: the disc has
// come to rest (from Landed).
function IGPlus_DetServerDiscChanged(ST_TranslocatorTarget STTarget, optional float Age, optional bool bAtRest) {
	local vector Vel;

	if (IGPlus_IsDetMode() == false || STTarget != TTarget || STTarget.bIGPlusFullHistory == false)
		return;

	if (Age <= 0.0) {
		Age = STTarget.TotalSimulationTime;
		if (STTarget.IGPlus_HistoryAnchor != 0.0)
			Age += Level.TimeSeconds - STTarget.IGPlus_HistoryAnchor;
	}
	if (bAtRest == false)
		Vel = STTarget.Velocity;
	// Location as floats, exact: the disc may be right against a window frame.
	IGPlus_ClientDetKnock(STTarget.Location.X, STTarget.Location.Y, STTarget.Location.Z, Vel,
		STTarget.Physics == PHYS_None || bAtRest, Age, IGPlus_ThrowTS, STTarget.Disrupted(),
		STTarget.bBounce, STTarget.bAlreadyHit, bbPlayer(Owner).CurrentTimeStamp);
}

// Server: the thrower's disc bounced or landed at Age on its screen. An edge
// (a window frame) can stop one disc and not the other: send ours once it is
// that old, so the thrower's follows it from there.
function IGPlus_DetSyncAfter(float DiscTS, float Age) {
	local ST_TranslocatorTarget T;

	T = ST_TranslocatorTarget(TTarget);
	if (IGPlus_IsDetMode() == false || T == None || T.bIGPlusFullHistory == false || DiscTS != IGPlus_ThrowTS)
		return;
	T.IGPlus_DetClientPathEvents++;
	// Our disc is past that age and met nothing then: the thrower's hit an
	// edge (a window frame) ours missed.
	if (T.Physics != PHYS_None && T.IGPlus_CurrentAge() >= Age + 0.05 && T.IGPlus_DetHadPathEventNear(Age, 0.05) == false)
		IGPlus_DetLog("client-only-bounce", "clientBounceAge="$Age);
	if (T.Physics == PHYS_None || T.IGPlus_CurrentAge() >= Age)
		IGPlus_DetServerDiscChanged(T);
	else // ponytail: waits at most 0.2s for a client clock running ahead
		T.IGPlus_SyncAge = FMax(T.IGPlus_SyncAge, FMin(Age, T.IGPlus_CurrentAge() + 0.2));
}

// Client: our mover moved into our disc. Our movers stop touching it (it
// still hits the world) and we ask the server for its disc's state now: the
// knock puts ours there (pushed by the server's door, or not at all), and
// IGPlus_DetApplyKnock lets our movers touch it again.
simulated function IGPlus_DetIgnoreOurMovers(ST_TranslocatorTarget D, string Why) {
	if (D == None || D != IGPlus_DetLocalDisc || D.bCollideActors == false)
		return;
	if (bbPlayer(Owner) != None)
		bbPlayer(Owner).ClientDebugMessage("Tloc disc ignores our movers:"@Why@"age="$(Level.TimeSeconds - IGPlus_DetThrowTS));
	D.SetCollision(false, false, false);
	IGPlus_DetLastSyncAskTS = 0.0; // now, not 50ms after the last ask
	IGPlus_DetLocalDiscBounced();
}

// Client: our disc bounced or landed (ST_TranslocatorTarget.IGPlus_PathEvent).
simulated function IGPlus_DetLocalDiscBounced() {
	// ponytail: one ask per 50ms, a disc grinding along a ledge bounces every frame
	if (bbPlayer(Owner) == None || Level.TimeSeconds - IGPlus_DetLastSyncAskTS < 0.05)
		return;
	IGPlus_DetLastSyncAskTS = Level.TimeSeconds;
	bbPlayer(Owner).IGPlus_ServerDetDiscSync(IGPlus_DetThrowTS, Level.TimeSeconds - IGPlus_DetThrowTS);
}

simulated function IGPlus_ClientDetKnock(float LocX, float LocY, float LocZ, vector Vel, bool bLanded, float Age, float DiscTS,
	bool bDisrupted, bool bBounce, bool bAlreadyHit, float MoveTS) {
	if (IGPlus_bDetOut == false || IGPlus_DetThrowTS != DiscTS)
		return;
	// Disruption is a state, not a path: show it now, so the player sees the
	// warning (and isn't moved onto a disc that gibs them).
	if (bDisrupted)
		IGPlus_DetMarkDisrupted();
	// Sent before the server had our last predicted boost: that boost is newer.
	if (MoveTS < IGPlus_DetPredictTS)
		return;
	IGPlus_bDetKnockPending = true;
	IGPlus_DetKnockLoc.X = LocX;
	IGPlus_DetKnockLoc.Y = LocY;
	IGPlus_DetKnockLoc.Z = LocZ;
	IGPlus_DetKnockVel = Vel;
	IGPlus_bDetKnockLanded = bLanded;
	IGPlus_bDetKnockBounce = bBounce;
	IGPlus_bDetKnockHit = bAlreadyHit;
	IGPlus_DetKnockAge = Age;
	if (Level.TimeSeconds - IGPlus_DetThrowTS >= Age)
		IGPlus_DetApplyKnock();
}

// Client: put our disc where the server's was at the knock, then fly it on
// to our own age.
simulated function IGPlus_DetApplyKnock() {
	local ST_TranslocatorTarget D;
	local float Remaining, Step;
	local vector OldLoc;

	IGPlus_bDetKnockPending = false;
	D = IGPlus_DetLocalDisc;
	if (D == None || D.bDeleteMe)
		return;
	OldLoc = D.Location;

	D.bCollideWorld = false;
	D.SetLocation(IGPlus_DetKnockLoc);
	D.bCollideWorld = true;
	D.Velocity = IGPlus_DetKnockVel;
	D.bBounce = IGPlus_bDetKnockBounce;
	D.bAlreadyHit = IGPlus_bDetKnockHit;
	if (IGPlus_bDetKnockLanded) {
		D.SetPhysics(PHYS_None);
		IGPlus_DetLogKnock(D, OldLoc);
		D.SetCollision(true, false, false);
		return;
	}
	D.SetPhysics(PHYS_Falling);

	// Bounces in the catch-up are in the past: no sound, no asking the server.
	D.ImpactSound = None;
	D.IGPlus_bRebasing = true;
	Remaining = (Level.TimeSeconds - IGPlus_DetThrowTS) - IGPlus_DetKnockAge;
	while (Remaining > 0.0 && D != None && D.bDeleteMe == false && D.Physics != PHYS_None) {
		Step = FMin(Remaining, 0.02);
		D.AutonomousPhysics(Step);
		Remaining -= Step;
	}
	if (D != None && D.bDeleteMe == false) {
		D.ImpactSound = D.default.ImpactSound;
		D.IGPlus_bRebasing = false;
		IGPlus_DetLogKnock(D, OldLoc);
		// On the server's state now: our movers may stop it again (lifts).
		D.SetCollision(true, false, false);
	}
}

// Client debug line: how far the knock moved our disc on screen, both spots
// at our disc's age now (the server's state flown on from the knock's age).
simulated function IGPlus_DetLogKnock(ST_TranslocatorTarget D, vector OldLoc) {
	if (bbPlayer(Owner) == None)
		return;
	bbPlayer(Owner).ClientDebugMessage("Tloc disc knocked to the server's: jump="$int(VSize(D.Location - OldLoc))
		@"knockAge="$IGPlus_DetKnockAge@"late="$(Level.TimeSeconds - IGPlus_DetThrowTS - IGPlus_DetKnockAge)
		@"landed="$IGPlus_bDetKnockLanded);
}

// Client: our disc sparks like the server's (its stock Timer does the effect).
simulated function IGPlus_DetMarkDisrupted() {
	local ST_TranslocatorTarget D;

	D = IGPlus_DetLocalDisc;
	if (D == None || D.bDeleteMe || D.Disruption > D.DisruptionThreshold)
		return;
	D.Disruption = D.DisruptionThreshold + 1;
	if (D.Glow != None)
		D.Glow.Destroy();
	D.SetTimer(0.05, false);
}

// Server: where the thrower's screen had its disc for the move being
// processed (its own age since the throw), for its own hitscan; marks the
// disc so a hit there pushes it at that age.
function vector IGPlus_DetOwnShotLocation(ST_TranslocatorTarget T, bbPlayer P) {
	T.IGPlus_OwnShotAge = IGPlus_DetSeenAge(P);
	T.IGPlus_OwnShotFrame = Level.TimeSeconds;
	return IGPlus_DetSeenLocation(T, P);
}

// Server: the disc's age and spot on the thrower's screen for the move
// being processed.
function float IGPlus_DetSeenAge(bbPlayer P) {
	return FMax(0.0, FClamp(
		P.CurrentTimeStamp - IGPlus_ThrowTS,
		ServerTimeSinceTargetSpawn - 0.2,
		ServerTimeSinceTargetSpawn + 0.2));
}

function vector IGPlus_DetSeenLocation(ST_TranslocatorTarget T, bbPlayer P) {
	local byte bLanded;
	return T.IGPlus_GetHistoryAt(IGPlus_DetSeenAge(P), bLanded);
}

// Server, the thrower's own shock beam, before it hits anything: what the
// beam met, following the thrower's own verdict on its disc (its move's
// IGPlus_DetOwnBeamMode). A miss already left the disc out of the trace. A
// hit our trace missed by a few units (its predicted position and ours, each
// machine's frame rate) still hits, where its screen had the disc. Otherwise
// the client is told where the disc really is.
function Actor IGPlus_DetOwnBeam(bbPlayer P, Actor Other, vector Start, out vector HitLocation, vector Dir) {
	local ST_TranslocatorTarget T;
	local vector SeenLoc;
	local float MaxDist;

	T = ST_TranslocatorTarget(TTarget);
	if (P.IGPlus_DetOwnBeamMode != 2 || IGPlus_IsDetMode() == false || T == None || Other == T
		|| T.bIGPlusFullHistory == false)
		return Other;

	MaxDist = 10000.0;
	if (Other != None)
		MaxDist = VSize(HitLocation - Start);
	SeenLoc = IGPlus_DetSeenLocation(T, P);
	// ponytail: 8uu of slack around the disc, so a cheat gains 8uu on its own disc only
	if (IGPlus_RayHitsCylinder(Start, Dir, MaxDist, SeenLoc, T.CollisionRadius + 8.0, T.CollisionHeight + 8.0)) {
		T.IGPlus_OwnShotAge = IGPlus_DetSeenAge(P);
		T.IGPlus_OwnShotFrame = Level.TimeSeconds;
		HitLocation = SeenLoc;
		return T;
	}
	if (P.IGPlus_PredictedDiscBoost)
		IGPlus_DetServerDiscChanged(T);
	return Other;
}

// Server: the thrower's own hitscan pushed its disc at Age (its screen).
// Fly the disc again from there with the new velocity up to now, so the
// push lands at the same point of its path on both machines. Comp off this
// is a few ms; comp on it is the fast-forward.
function IGPlus_DetRebaseDisc(ST_TranslocatorTarget T, float Age) {
	local vector V, Pos;
	local float Now, Remaining, Step;
	local byte bLanded;
	local bool bColActors, bBlkActors, bBlkPlayers;

	Now = T.IGPlus_CurrentAge();
	if (Now <= Age)
		return;

	V = T.Velocity;
	Pos = T.IGPlus_GetHistoryAt(Age, bLanded);
	T.IGPlus_TruncateHistory(Age);

	// No touches while flying it again: only the world shapes this path.
	bColActors = T.bCollideActors;
	bBlkActors = T.bBlockActors;
	bBlkPlayers = T.bBlockPlayers;
	T.SetCollision(false, false, false);
	T.IGPlus_bRebasing = true;
	T.SetLocation(Pos);
	T.SetPhysics(PHYS_Falling);
	T.Velocity = V;
	T.IGPlus_RecordHistory(Age);

	Remaining = Now - Age;
	while (Remaining > 0.0 && T.bDeleteMe == false && T.Physics != PHYS_None) {
		Step = FMin(Remaining, 0.02);
		T.AutonomousPhysics(Step);
		Remaining -= Step;
		T.IGPlus_RecordHistory(Now - Remaining);
	}

	T.IGPlus_bRebasing = false;
	if (T.bDeleteMe == false)
		T.SetCollision(bColActors, bBlkActors, bBlkPlayers);
}

// Client, Predicted Disc Boost: our own beam met our own disc, push it now,
// as TranslocatorTarget.TakeDamage will on the server for this move.
simulated function IGPlus_DetPredictBoost(vector Momentum) {
	local ST_TranslocatorTarget D;
	local vector V;

	D = IGPlus_DetLocalDisc;
	if (D == None || D.bDeleteMe || D.Mass <= 0.0)
		return;

	// A knock still waiting for our age predates this boost.
	IGPlus_DetPredictTS = Level.TimeSeconds;
	IGPlus_bDetKnockPending = false;
	V = Momentum / D.Mass;
	V.Z = FMax(V.Z, 0.7 * VSize(V));
	D.SetPhysics(PHYS_Falling);
	D.Velocity = V;
	D.SetTimer(0.3, false);
}

// Does the ray Start + t*Dir (t in [0, MaxDist], Dir normalized) pass through
// the upright cylinder at C?
static function bool IGPlus_RayHitsCylinder(vector Start, vector Dir, float MaxDist, vector C, float R, float H) {
	local vector P;
	local float A, B, Disc, T0, T1, Z0, Z1, Tmp;

	P = Start - C;

	A = Dir.X * Dir.X + Dir.Y * Dir.Y;
	if (A < 0.000001) {
		if (P.X * P.X + P.Y * P.Y > R * R)
			return false;
		T0 = 0.0;
		T1 = MaxDist;
	} else {
		B = 2.0 * (P.X * Dir.X + P.Y * Dir.Y);
		Disc = B * B - 4.0 * A * (P.X * P.X + P.Y * P.Y - R * R);
		if (Disc < 0.0)
			return false;
		Disc = Sqrt(Disc);
		T0 = (-B - Disc) / (2.0 * A);
		T1 = (-B + Disc) / (2.0 * A);
	}

	if (Abs(Dir.Z) < 0.000001) {
		if (Abs(P.Z) > H)
			return false;
		Z0 = 0.0;
		Z1 = MaxDist;
	} else {
		Z0 = (-H - P.Z) / Dir.Z;
		Z1 = (H - P.Z) / Dir.Z;
		if (Z0 > Z1) {
			Tmp = Z0;
			Z0 = Z1;
			Z1 = Tmp;
		}
	}

	return FMax(FMax(T0, Z0), 0.0) <= FMin(FMin(T1, Z1), MaxDist);
}

simulated function Destroyed() {
	if (IGPlus_DetLocalDisc != None)
		IGPlus_DetLocalDisc.Destroy();
	Super.Destroyed();
}

// Client, predicted translocation: the disc this client sees as its own,
// the local client disc until the server's arrives, then the server's.
// Without client-side animations there is no local disc, so translocating
// within a ping of the throw is left to the server.
simulated function ST_TranslocatorTarget IGPlus_PredictionDisc() {
	local ST_TranslocatorTarget T, Found;

	if (TTarget_Client != None && !TTarget_Client.bDeleteMe && TTarget_Client.bCollideWorld) {
		if (IGPlus_bClientDiscConfident)
			return TTarget_Client;
		return None;
	}

	if (IGPlus_DiscRepl != None && !IGPlus_DiscRepl.bDeleteMe && !IGPlus_DiscRepl.bHidden)
		return IGPlus_DiscRepl;

	foreach AllActors(class'ST_TranslocatorTarget', T)
		if (T.Instigator == Owner && T.Role < ROLE_Authority && !T.bDeleteMe && !T.bHidden)
			Found = T;

	return Found;
}

defaultproperties {
}
