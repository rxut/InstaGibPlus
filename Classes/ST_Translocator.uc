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
var float IGPlus_DetKnockAge;

replication
{
    // Replicate server timing for synchronization
    unreliable if( Role==ROLE_Authority )
        ServerTimeSinceLastFire, ServerTimeSinceTargetSpawn;
    reliable if (bNetOwner && Role == ROLE_Authority)
        IGPlus_DiscRepl;
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
            IGPlus_ClientDetSync(false, IGPlus_ThrowTS);
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

	PingCompensation = bbP.PingAverage * 0.001;
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

	TTarget_Client = Spawn(class'ST_TranslocatorTarget', Owner,, Start);

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
		
		// Apply ping compensation with position history
		if (bbP != none && GetWeaponSettings().TranslocatorCompensatePing) {
			// Cast to ST_TranslocatorTarget to access history functions
			ST_TranslocatorTarget(TTarget).SimulateWithHistory(WImp, bbP.PingAverage);
		}

		// Without ping comp the deterministic translocator still looks the
		// disc up by age: start its history at the throw.
		if (bbP != none && bbP.IGPlus_DetTranslocator && TTarget != None
			&& ST_TranslocatorTarget(TTarget).HistoryCount == 0)
			ST_TranslocatorTarget(TTarget).InitSimulationHistory(TTarget.Location, 0.0, 0.0);

		if (bbP != none && (GetWeaponSettings().TranslocatorCompensatePing || bbP.IGPlus_DetTranslocator)) {
			// Fragger's Translocate() has no restore path: stock lookup only.
			if ((bbP.IGPlus_PredictedTranslocation || bbP.IGPlus_DetTranslocator)
				&& TTarget != None && Class == class'ST_Translocator') {
				IGPlus_ThrowTS = bbP.CurrentTimeStamp;
				IGPlus_DiscRepl = ST_TranslocatorTarget(TTarget);
				IGPlus_DiscRepl.bIGPlusFullHistory = true;
				// Ping over PingCompensationMax: the thrower sees a younger disc.
				// (Without ping comp nothing was fast-forwarded: no bias.)
				if (GetWeaponSettings().TranslocatorCompensatePing)
					IGPlus_DiscRepl.IGPlus_AgeBias = FMax(0.0,
						float(bbP.PingAverage) * 0.001 * Level.TimeDilation - IGPlus_DiscRepl.TotalSimulationTime);
				// Landed during the fast-forward: Tick is off until a knock.
				if (IGPlus_DiscRepl.Physics == PHYS_None)
					IGPlus_DiscRepl.IGPlus_HistoryAnchor = Level.TimeSeconds;
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
function IGPlus_MoveDiscToSeenAge(ST_TranslocatorTarget STTarget, bbPlayer bbP) {
	local float TimeSinceThrow;
	local vector HistoricalLocation;
	local byte HistoricalLanded;

	// ponytail: +-0.2s bounds how far a client clock can move the lookup
	TimeSinceThrow = FClamp(
		bbP.CurrentTimeStamp - IGPlus_ThrowTS,
		ServerTimeSinceTargetSpawn - 0.2,
		ServerTimeSinceTargetSpawn + 0.2);
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

simulated function bool IGPlus_IsDetMode() {
	return bbPlayer(Owner) != None && bbPlayer(Owner).IGPlus_DetTranslocator && Class == class'ST_Translocator';
}

// Client, at the start of its frame (before movement): decide and act.
// Returns the action for the move, 0 for none.
simulated function int IGPlus_DetClientStep(bbPlayer P, float TS, bool bFirePress, bool bFireHeld, bool bAltPress, bool bAltHeld) {
	local bool bFireIn, bAltIn;
	local int Action;

	bFireIn = bFirePress || bFireHeld;
	bAltIn = bAltPress || bAltHeld;
	if (bFireIn == bAltIn)
		return 0; // nothing, or both: the two-button switch is the server's call
	if (P.Weapon != self || P.ClientPending != None || IsInState('ClientDown') || IsInState('ClientActive'))
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

	if (Action == IGPLUS_DETTLOC_THROW) {
		IGPlus_DetClientThrow(P, TS);
	} else if (Action == IGPLUS_DETTLOC_RECALL) {
		IGPlus_DetLastFireTS = TS; // a recall restarts the throw timer
		IGPlus_DetClientDiscGone();
	}
	return Action;
}

// Client: our own disc, from the same start, aim and frame as the server's.
simulated function IGPlus_DetClientThrow(bbPlayer P, float TS) {
	local vector Start;

	IGPlus_DetClientDiscGone();
	IGPlus_bDetOut = true;
	IGPlus_DetThrowTS = TS;
	IGPlus_DetLastFireTS = TS;
	P.IGPlus_DetTloc = self;

	// Same start as ThrowTarget (whose X/Y/Z are unset there as well).
	Start = Owner.Location + CalcDrawOffsetClient();
	P.ViewRotation = P.AdjustToss(TossForce, Start, 0, true, true);

	IGPlus_DetLocalDisc = Spawn(class'ST_TranslocatorTarget', Owner,, Start);
	if (IGPlus_DetLocalDisc != None) {
		IGPlus_DetLocalDisc.Master = self;
		IGPlus_DetLocalDisc.RemoteRole = ROLE_None;
		IGPlus_DetLocalDisc.bCollideWorld = false;
		IGPlus_DetLocalDisc.SetCollision(false, false, false);
		IGPlus_DetLocalDisc.Throw(P, MaxTossForce, Start);
		// Only after Throw, so DropFrom's SetLocation can't fail (eaf4d45).
		IGPlus_DetLocalDisc.bCollideWorld = true;
	}

	PlayFiring();
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

	S = IGPlus_DiscRepl;
	if (S != None && S.bDeleteMe == false) {
		S.bHidden = (IGPlus_bDetShowServerDisc == false);
		if (S.Glow != None)
			S.Glow.bHidden = S.bHidden;
		if (S.bHidden && S.Shadow != None) {
			S.Shadow.Destroy();
			S.Shadow = None;
		}
	}

	if (IGPlus_bDetKnockPending && Level.TimeSeconds - IGPlus_DetThrowTS >= IGPlus_DetKnockAge)
		IGPlus_DetApplyKnock();
}

// Server, on the move's step (before its movement): repeat the client's
// action if our state allows it, else tell the client how things are.
function IGPlus_DetServerStep(bbPlayer P, float TS, int Action, bool bFireHeld, bool bAltHeld) {
	local ST_TranslocatorTarget STTarget;

	if (bFireHeld && bAltHeld) {
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
		IGPlus_DetReject(Action, TS);
		return;
	}

	if (Action == IGPLUS_DETTLOC_THROW) {
		if (TTarget != None || TS - IGPlus_DetLastFireTS < 0.499) {
			IGPlus_DetReject(Action, TS);
			return;
		}
		IGPlus_DetLastAttemptTS = TS;
		IGPlus_DetLastFireTS = TS;
		bPointing = true;
		bCanClientFire = true;
		Pawn(Owner).PlayRecoil(FiringSpeed);
		ThrowTarget();
		ServerTimeSinceLastFire = 0.0;
		if (TTarget == None) {
			IGPlus_ClientDetSync(false, TS);
			return;
		}
		IGPlus_bDetExpectOut = true;
		return;
	}

	if (TTarget == None || (Action == IGPLUS_DETTLOC_RECALL && TS - IGPlus_ThrowTS < 0.799)) {
		IGPlus_DetReject(Action, TS);
		return;
	}
	IGPlus_DetLastAttemptTS = TS;
	IGPlus_bDetExpectOut = false;

	if (Action == IGPLUS_DETTLOC_RECALL) {
		IGPlus_DetLastFireTS = TS;
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
		IGPlus_MoveDiscToSeenAge(STTarget, P);
	if (TTarget == None || IGPlus_GibIfDisrupted())
		return;
	Translocate();
	// Refused (AllowTranslocation): the disc stays out, show it again.
	if (TTarget != None) {
		IGPlus_bDetExpectOut = true;
		IGPlus_ClientDetSync(true, IGPlus_ThrowTS);
	}
}

function IGPlus_DetReject(int Action, float TS) {
	if (Action == IGPLUS_DETTLOC_THROW)
		IGPlus_ClientDetSync(false, TS); // the disc it threw doesn't exist
	if (TTarget != None)
		IGPlus_ClientDetSync(true, IGPlus_ThrowTS); // ours is still out
}

// Client: the server's truth about our disc. DiscTS names the throw it means,
// so a sync about an old disc can't remove a newer one.
simulated function IGPlus_ClientDetSync(bool bOut, float DiscTS) {
	if (bOut) {
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
function IGPlus_DetServerDiscChanged(ST_TranslocatorTarget STTarget) {
	local float Age;

	if (IGPlus_IsDetMode() == false || STTarget != TTarget || STTarget.bIGPlusFullHistory == false)
		return;

	Age = STTarget.TotalSimulationTime;
	if (STTarget.IGPlus_HistoryAnchor != 0.0)
		Age += Level.TimeSeconds - STTarget.IGPlus_HistoryAnchor;
	IGPlus_ClientDetKnock(STTarget.Location, STTarget.Velocity, STTarget.Physics == PHYS_None, Age, IGPlus_ThrowTS);
}

simulated function IGPlus_ClientDetKnock(vector Loc, vector Vel, bool bLanded, float Age, float DiscTS) {
	if (IGPlus_bDetOut == false || IGPlus_DetThrowTS != DiscTS)
		return;
	IGPlus_bDetKnockPending = true;
	IGPlus_DetKnockLoc = Loc;
	IGPlus_DetKnockVel = Vel;
	IGPlus_bDetKnockLanded = bLanded;
	IGPlus_DetKnockAge = Age;
	if (Level.TimeSeconds - IGPlus_DetThrowTS >= Age)
		IGPlus_DetApplyKnock();
}

// Client: put our disc where the server's was at the knock, then fly it on
// to our own age.
simulated function IGPlus_DetApplyKnock() {
	local ST_TranslocatorTarget D;
	local float Remaining, Step;

	IGPlus_bDetKnockPending = false;
	D = IGPlus_DetLocalDisc;
	if (D == None || D.bDeleteMe)
		return;

	D.bCollideWorld = false;
	D.SetLocation(IGPlus_DetKnockLoc);
	D.bCollideWorld = true;
	D.Velocity = IGPlus_DetKnockVel;
	if (IGPlus_bDetKnockLanded) {
		D.SetPhysics(PHYS_None);
		return;
	}
	D.SetPhysics(PHYS_Falling);

	Remaining = (Level.TimeSeconds - IGPlus_DetThrowTS) - IGPlus_DetKnockAge;
	while (Remaining > 0.0 && D != None && D.bDeleteMe == false && D.Physics != PHYS_None) {
		Step = FMin(Remaining, 0.02);
		D.AutonomousPhysics(Step);
		Remaining -= Step;
	}
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
