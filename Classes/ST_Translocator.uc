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

replication
{
    // Replicate server timing for synchronization
    unreliable if( Role==ROLE_Authority )
        ServerTimeSinceLastFire, ServerTimeSinceTargetSpawn;
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
    }
}

simulated function bool ClientFire(float Value)
{
	local bbPlayer bbP;
	local float CompensatedTime, PingCompensation;

	bbP = bbPlayer(Owner);

	if (bbP == None)
		return false;

    CheckDualButtonSetting();

	PingCompensation = bbP.PingAverage * 0.001;
	CompensatedTime = ServerTimeSinceLastFire + PingCompensation;
    
    if ( !bTTargetOut && bCanClientFire && (CompensatedTime > 0.45) )
    {
		if (Role < ROLE_Authority && GetWeaponSettings().TranslocatorCompensatePing && bbP != none && bbP.ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations == true)
			ClientThrowTarget();

        PlayFiring();
        return true;
    }
	else if ( bTTargetOut && bCanClientFire && (ServerTimeSinceTargetSpawn > 0.8) )
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
		TTarget_Client.Throw(bbP, MaxTossForce, Start);
		TTarget_Client.bCollideWorld = false;
		TTarget_Client.SetCollision(false, false, false);

		// Backup removal of client disc
		TTarget_Client.LifeSpan = Pawn(Owner).PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	}
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

    GotoState('NormalFire');

    if ( TTarget != None )
    {
        bbP = bbPlayer(Owner);
        STTarget = ST_TranslocatorTarget(TTarget);
        
        // Apply same position history logic as in Fire()
        if (bbP != None && STTarget != None && STTarget.HistoryCount > 0 && 
            ServerTimeSinceTargetSpawn < STTarget.TotalSimulationTime)
        {
            // Calculate historical position based on time since throw
            TimeSinceThrow = ServerTimeSinceTargetSpawn;
            HistoricalLocation = STTarget.GetHistoricalPosition(TimeSinceThrow);
            
            // Store original location and temporarily move to historical position
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
            
            // Clean up the target BEFORE gibbing the player
            bTTargetOut = false;
            TTarget.Destroy();
            TTarget = None;
            
            // Reset both timers
            ServerTimeSinceLastFire = 0.0;
            ServerTimeSinceTargetSpawn = 0.0;
            
            Pawn(Owner).gibbedBy(STTarget.disruptor);
            return;
        }
        
        Translocate();
		TTarget = None;
        bTTargetOut = false;
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
        if (STTarget != None && STTarget.HistoryCount > 0 && ServerTimeSinceTargetSpawn < STTarget.TotalSimulationTime)
        {
            // Calculate historical position based on time since throw
            TimeSinceThrow = ServerTimeSinceTargetSpawn;
            HistoricalLocation = STTarget.GetHistoricalPosition(TimeSinceThrow);
            
            // Store original location and temporarily move to historical position
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

defaultproperties {
}
