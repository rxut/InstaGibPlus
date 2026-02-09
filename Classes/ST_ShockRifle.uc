// ===============================================================
// Stats.ST_ShockRifle: ShockRifle with ping compensation
// ===============================================================

class ST_ShockRifle extends ShockRifle;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var float yMod;
var vector CDO;

var ST_ShockProj LocalDummy;

// Explicit client aim data (sent via ServerExplicitFire/AltFire)
var vector ExplicitClientLoc;
var rotator ExplicitClientRot;
var bool bUseExplicitData;
var bool bClientShownVisuals;

// Server-side rate limiting and position validation
var float LastServerFireTime;
const FIRE_RATE_LIMIT = 0.65;
const MAX_POSITION_ERROR_SQ = 1250.0;

// Client-side rate limiting
var float LastClientFireTime;

replication
{
    // Replicate the explicit fire function to the server
    reliable if(Role < ROLE_Authority)
        ServerExplicitFire, ServerExplicitAltFire;
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

simulated function bool IsPingCompEnabled() {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	return WS != None && WS.bEnablePingCompensation;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;
}

simulated function yModInit() {
	if (PlayerPawn(Owner) == None)
		return;

	yMod = PlayerPawn(Owner).Handedness;
	if (yMod != 2.0)
		yMod *= Default.FireOffset.Y;
	else
		yMod = 0;

	CDO = CalcDrawOffsetClient();
}

function bool IsPositionReasonable(vector ClientLoc)
{
    local vector Diff;
    
    Diff = ClientLoc - Owner.Location;
    return (Diff dot Diff) < MAX_POSITION_ERROR_SQ;
}

// Called by ClientFire. Sends exact Client data to server.
function ServerExplicitFire(vector ClientLoc, rotator ClientRot, bool bClientVisuals, optional bool bIsSwitching)
{
    local PlayerPawn P;
    
	P = PlayerPawn(Owner);
    if (P == None)
        return;
	
	// Handle Switching Fire (High Priority)
	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) && (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self) || P.Weapon != self) )
	{
		// Rate limit check
		if (Level.TimeSeconds - LastServerFireTime < FIRE_RATE_LIMIT)
			return;

		AmmoType.UseAmmo(1);
		LastServerFireTime = Level.TimeSeconds;

		// Position validation
		if (IsPositionReasonable(ClientLoc))
			ExplicitClientLoc = ClientLoc;
		else
			ExplicitClientLoc = Owner.Location;
		
		ExplicitClientRot = ClientRot;
		bUseExplicitData = true;
		bClientShownVisuals = bClientVisuals;

		if ( bRapidFire || (FiringSpeed > 0) )
			P.PlayRecoil(FiringSpeed);
		
		PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);

		if (Affector != None) {
			Affector.FireEffect();
		}

		TraceFire(0.0);
		
		bUseExplicitData = false;
		bClientShownVisuals = false;

		bChangeWeapon = true;
		GotoState('DownWeapon'); // Manually trigger the transition
		return;
	}

	if (bChangeWeapon || IsInState('DownWeapon'))
 		return;

    // Rate limit check (anti-cheat)
    if (Level.TimeSeconds - LastServerFireTime < FIRE_RATE_LIMIT)
        return;

    // Position validation - use server position if client position is unreasonable
    if (IsPositionReasonable(ClientLoc))
        ExplicitClientLoc = ClientLoc;
    else
        ExplicitClientLoc = Owner.Location;
    
    ExplicitClientRot = ClientRot;
    bUseExplicitData = true;
    bClientShownVisuals = bClientVisuals;

    if (AmmoType != None && AmmoType.AmmoAmount > 0)
    {
        AmmoType.UseAmmo(1);
        LastServerFireTime = Level.TimeSeconds;
        
		bPointing = true;
		GotoState('NormalFire');
		
		if ( bRapidFire || (FiringSpeed > 0) )
			P.PlayRecoil(FiringSpeed);
		
		PlayFiring();

		if (Affector != None) {
			Affector.FireEffect();
		}

		TraceFire(0.0);
    }

    bUseExplicitData = false;
    bClientShownVisuals = false;
}

function ServerExplicitAltFire(vector ClientLoc, rotator ClientRot, bool bClientVisuals, optional bool bIsSwitching)
{
    local PlayerPawn P;
    
	P = PlayerPawn(Owner);
    if (P == None)
        return;

	// Handle Switching Fire (High Priority)
	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) && (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self) || P.Weapon != self) )
	{
		AmmoType.UseAmmo(1);
		
		// Position validation
		if (IsPositionReasonable(ClientLoc))
			ExplicitClientLoc = ClientLoc;
		else
			ExplicitClientLoc = Owner.Location;
		
		ExplicitClientRot = ClientRot;
		bUseExplicitData = true;
		bClientShownVisuals = bClientVisuals;

		if ( bRapidFire || (FiringSpeed > 0) )
			P.PlayRecoil(FiringSpeed);
			
		PlayOwnedSound(AltFireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
		
		if (Affector != None) {
			Affector.FireEffect();
		}

		ExplicitProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);

		bUseExplicitData = false;
		bClientShownVisuals = false;
		
		bChangeWeapon = true;
		GotoState('DownWeapon'); // Manually trigger the transition
		return;
	}

	if (bChangeWeapon || IsInState('DownWeapon'))
 		return;

    // Position validation - use server position if client position is unreasonable
    if (IsPositionReasonable(ClientLoc))
        ExplicitClientLoc = ClientLoc;
    else
        ExplicitClientLoc = Owner.Location;

    ExplicitClientRot = ClientRot;
    bUseExplicitData = true;
    bClientShownVisuals = bClientVisuals;

    if (AmmoType != None && AmmoType.AmmoAmount > 0)
    {
        AmmoType.UseAmmo(1);
        
		bPointing = true;
		GotoState('AltFiring');
		
		if ( bRapidFire || (FiringSpeed > 0) )
			P.PlayRecoil(FiringSpeed);
			
		PlayAltFiring();
		
		if (Affector != None) {
			Affector.FireEffect();
		}

		ExplicitProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
    }

    bUseExplicitData = false;
    bClientShownVisuals = false;
}

function Projectile ExplicitProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local Vector Start, X,Y,Z;

    Owner.MakeNoise(Pawn(Owner).SoundDampening);
    
    // Use Explicit Client Rotation
    GetAxes(ExplicitClientRot,X,Y,Z);
    Start = ExplicitClientLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 

    AdjustedAim = ExplicitClientRot; 
    
    return Spawn(ProjClass,,, Start, AdjustedAim);  
}

simulated function bool ClientFire(float Value) {
	local Pawn PawnOwner;
	local bbPlayer bbP;
	local bool bVisualsPlayed;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	
	if (PawnOwner == None) 
		return false;

	if (IsPingCompEnabled())
	{
		bbP = bbPlayer(PawnOwner);

		if (Owner.Role == ROLE_AutonomousProxy && bbP != None)
		{
			// Client-side rate limiting
			if (Level.TimeSeconds - LastClientFireTime < FIRE_RATE_LIMIT)
				return false;

			if ((AmmoType == None) && (AmmoName != None)) {
				GiveAmmo(PawnOwner);
			}
			
			if (AmmoType != None && AmmoType.AmmoAmount > 0)
			{
				LastClientFireTime = Level.TimeSeconds;
				Instigator = PawnOwner;

				if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
				{
					// Still send RPC (server will handle it correctly), but don't show visuals
					ServerExplicitFire(PawnOwner.Location, PawnOwner.ViewRotation, false, true);
					return true;
				}

				GotoState('ClientFiring');
				bPointing = True;

				bVisualsPlayed = false;
				
				// Always play weapon animations to keep state machine working
				if (bRapidFire || (FiringSpeed > 0))
					PawnOwner.PlayRecoil(FiringSpeed);
				PlayFiring();

				if ( Affector != None )
					Affector.FireEffect();

				if (PlayerPawn(Owner) != None)
					PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(450, 190, 650));

				// Spawn beam effect ONLY if setting is enabled
				if (bbP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations)
				{
					ClientTraceFire();
					bVisualsPlayed = true;
				}

				// ALWAYS send the exact aim to server if compensation is on
				ServerExplicitFire(PawnOwner.Location, PawnOwner.ViewRotation, bVisualsPlayed);

				return true;
			}
			return false; // No ammo
		}
	}
	
	return Super.ClientFire(Value);
}

// Client-side shock beam tracing and effect spawning
simulated function ClientTraceFire() {
    local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
    local actor Other;
    local Pawn PawnOwner;
    local vector SmokeLocation;
	local bbPlayer bbP;

    PawnOwner = Pawn(Owner);
	
    if (PawnOwner == None)
        return;

	bbP = bbPlayer(PawnOwner);

	if (IsPingCompEnabled() == false || bbP == None || bbP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations == false)
     	return;

	yModInit();

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	StartTrace = Owner.Location + CDO + yMod * Y + FireOffset.Z * Z;

	EndTrace = StartTrace + (10000 * X);
	
	SmokeLocation = Owner.Location + CDO + (FireOffset.X + 20) * X + yMod * Y + FireOffset.Z * Z;

	if (Trace(HitLocation, HitNormal, EndTrace, StartTrace, true) != None) {
		Other = Level;
		EndTrace = HitLocation;
	}

	if (Other == None) {
		if (GetWeaponSettings().ShockBeamUseReducedHitbox) {
			Other = WImp.TraceShotClient(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner);
		} else {
			Other = bbP.TraceShotClient(HitLocation, HitNormal, EndTrace, StartTrace);
		}
	}
	
	if (Other == PawnOwner) {
		Other = None;
		HitLocation = EndTrace;
	}
		
	if (Other == None) {
		HitLocation = EndTrace;
	}

	ClientSpawnBeam(HitLocation, SmokeLocation);
}

simulated function ClientSpawnBeam(vector HitLocation, vector SmokeLocation) {
	local ShockBeam Smoke;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;
	
	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if (NumPoints < 1) {
		return;
	}
		
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);
	
	Smoke = Spawn(class'ShockBeam', Owner,, SmokeLocation, SmokeRotation);

	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;

	if (bbPlayer(Owner) != None)
		bbPlayer(Owner).xxClientDemoFix(None, class'ShockBeam', SmokeLocation, , , SmokeRotation, , , DVector/NumPoints, NumPoints-1);
}

simulated function bool ClientAltFire(float Value) {
	local Pawn PawnOwner;
	local bbPlayer bbP;
	local bool bVisualsPlayed;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	
	if (PawnOwner == None)
		return false;

	bbP = bbPlayer(PawnOwner);

	if (IsPingCompEnabled() && Owner.Role == ROLE_AutonomousProxy && bbP != None)
	{
		if ((AmmoType == None && AmmoName != None)) {
			GiveAmmo(PawnOwner);
		}
		
		if (AmmoType != None && AmmoType.AmmoAmount > 0) {
			Instigator = PawnOwner;
			
			if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
			{
				ServerExplicitAltFire(PawnOwner.Location, PawnOwner.ViewRotation, false, true);
				return true;
			}
			
			bPointing = True;

			GotoState('ClientAltFiring');

			bVisualsPlayed = false;

			// Always play weapon animations to keep state machine working
			if (bRapidFire || (FiringSpeed > 0))
				PawnOwner.PlayRecoil(FiringSpeed);
			PlayAltFiring();

			if ( Affector != None )
				Affector.FireEffect();

			// Spawn projectile effect ONLY if setting is enabled
			if (bbP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations)
			{
				ClientSpawnAltProjectileEffects();
				bVisualsPlayed = true;
			}

			// ALWAYS Send the exact aim to server
			ServerExplicitAltFire(PawnOwner.Location, PawnOwner.ViewRotation, bVisualsPlayed);

			return true;
		}
		return false; // No ammo
	}
	
	return Super.ClientAltFire(Value); 
}

simulated function ClientSpawnAltProjectileEffects() {
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);

	bbP = bbPlayer(PawnOwner);

	if (Owner.IsA('PlayerPawn'))
		Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
	else
		Hand = 1.0;

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	
	if (bHideWeapon)
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
	else
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	
	LocalDummy = ST_ShockProj(Spawn(AltProjectileClass,,, Start, PawnOwner.ViewRotation));
	LocalDummy.RemoteRole = ROLE_None;
	LocalDummy.Instigator = PawnOwner;
	LocalDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	LocalDummy.bCollideWorld = false;
	LocalDummy.SetCollision(false, false, false);
}

function TraceFire(float Accuracy) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;
	local rotator AimRot;
	local vector AimLoc;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);

	// Use Explicit Client Data if provided, otherwise fallback to standard
	if (bUseExplicitData)
	{
		AimRot = ExplicitClientRot;
		AimLoc = ExplicitClientLoc;
	}
	else
	{
		AimRot = PawnOwner.ViewRotation;
		AimLoc = Owner.Location;
	}

	GetAxes(AimRot,X,Y,Z);
	StartTrace = AimLoc + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 

	EndTrace = StartTrace + (Accuracy * (FRand() - 0.5 )* Y * 1000) + (Accuracy * (FRand() - 0.5 ) * Z * 1000);

	if (bBotSpecialMove && (Tracked != None) && (
			((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
			(Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)
		)
	) {
		EndTrace += 10000 * Normal(Tracked.Location - StartTrace);
	} else {
		// Only allow auto-aim helper for bots or legacy mode
		if (!bUseExplicitData)
			AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
		else
			AdjustedAim = AimRot;
		
		EndTrace += (10000 * vector(AdjustedAim)); 
	}

	Tracked = None;
	bBotSpecialMove = false;

	if (WImp.WeaponSettings.ShockBeamUseReducedHitbox)
		Other = WImp.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner);
	else
		Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
		
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local PlayerPawn PlayerOwner;
	local Pawn PawnOwner;
	local ST_ProjectileDummy Dummy;
	local ST_ShockProj Proj;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);

	bbP = bbPlayer(PawnOwner);

	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	PlayerOwner = PlayerPawn(Owner);

	if (PlayerOwner != None)
		PlayerOwner.ClientInstantFlash(-0.4, vect(450, 190, 650));
		
	// Server-side beam spawning
	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);

	if (IsPingCompEnabled() && bbP != None && bbP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations == false) {
		Dummy = ST_ProjectileDummy(Other);
	}

	if (Dummy != none)
		Proj = ST_ShockProj(Dummy.Actual);
	else
		Proj = ST_ShockProj(Other);
	
	if (Proj != None)
	{ 
		AmmoType.UseAmmo(2);
		Proj.SuperExplosion();
		return;
	}
	else
		Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ((Other != self) && (Other != Owner) && (Other != None)) 
	{
		Other.TakeDamage(
			WImp.WeaponSettings.ShockBeamDamage,
			PawnOwner,
			HitLocation,
			WImp.WeaponSettings.ShockBeamMomentum*60000.0*X,
			MyDamageType);
	}
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local ST_ShockBeamOwnerHidden ServerBeamHidden;
	local ShockBeam ServerBeamVisible;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if (NumPoints < 1) {
		return;
	}
		
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	// If client already showed visuals, use the hidden beam
	if (IsPingCompEnabled() && bClientShownVisuals) {

		ServerBeamHidden = Spawn(class'ST_ShockBeamOwnerHidden', Owner,, SmokeLocation, SmokeRotation);
		ServerBeamHidden.bOwnerNoSee = true;
		ServerBeamHidden.bAlreadyHidden = false;

		ServerBeamHidden.MoveAmount = DVector/NumPoints;
		ServerBeamHidden.NumPuffs = NumPoints - 1;

	} else {
		
		ServerBeamVisible = Spawn(class'ShockBeam',, , SmokeLocation, SmokeRotation);
		ServerBeamVisible.MoveAmount = DVector/NumPoints;
		ServerBeamVisible.NumPuffs = NumPoints - 1;
	}
}

function SetSwitchPriority(pawn Other)
{	// Make sure "old" priorities are kept.
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( IsA(PlayerPawn(Other).WeaponPriority[i]) )		// <- The fix...
			{
				AutoSwitchPriority = i;
				return;
			}
		// else, register this weapon
		carried = 'ShockRifle';
		for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
		{
			if ( PlayerPawn(Other).WeaponPriority[i] == '' )
			{
				PlayerPawn(Other).WeaponPriority[i] = carried;
				return;
			}
			else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
			{
				temp = PlayerPawn(Other).WeaponPriority[i];
				PlayerPawn(Other).WeaponPriority[i] = carried;
				carried = temp;
			}
		}
	}		
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().ShockSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().ShockDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().ShockDownAnimSpeed(), TweenTime);
}

simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.30 + 0.30 * FireAdjust, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(AltFireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire2', 0.4 + 0.4 * FireAdjust, 0.05);
}

state NormalFire
{
    function AnimEnd()
    {
        Finish();
    }
    
    function Timer()
    {
        // Fallback if AnimEnd doesn't fire
        Finish();
    }
    
    function BeginState()
    {
        // Safety net: if AnimEnd doesn't fire within expected time, Timer will
        SetTimer(0.5, false);
    }
    
    function EndState()
    {
        SetTimer(0.0, false);
    }
}

state AltFiring
{
    function AnimEnd()
    {
        Finish();
    }
    
    function Timer()
    {
        Finish();
    }
    
    function BeginState()
    {
        SetTimer(0.6, false);
    }
    
    function EndState()
    {
        SetTimer(0.0, false);
    }
}

state ClientFiring {

	simulated function bool ClientFire(float Value) {
		return false;
	}

	simulated function bool ClientAltFire(float Value) {
		return false;
	}

	simulated function AnimEnd()
	{
		if ( (Pawn(Owner) == None) || ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else if ( Pawn(Owner).bAltFire != 0 )
			Global.ClientAltFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
		}
	}
}

state ClientAltFiring {
	simulated function bool ClientFire(float Value) {
		return false;
	}

	simulated function bool ClientAltFire(float Value) {
		return false;
	}

	simulated function AnimEnd()
    {
        if ( (Pawn(Owner) == None) || ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
        {
            PlayIdleAnim();
            GotoState('');
        }
        else if ( !bCanClientFire )
            GotoState('');
        else if ( Pawn(Owner).bFire != 0 )
            Global.ClientFire(0);
        else if ( Pawn(Owner).bAltFire != 0 )
            Global.ClientAltFire(0);
        else
        {
            PlayIdleAnim();
            GotoState('');
        }
    }
}

// Compatibility between client and server logic
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

state ClientActive
{
	simulated function AnimEnd()
	{
		bCanClientFire = true;
		Super.AnimEnd();
	}
}

state Idle
{

	function BeginState()
	{	
		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
        {
            GotoState('DownWeapon');
            return;
        }

		if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
		{
			bPointing = false;
			SetTimer(0.5 + 2 * FRand(), false);

			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
				Pawn(Owner).SwitchToBestWeapon();

			Disable('AnimEnd');
			PlayIdleAnim();
		}
		else
		{
			bPointing = false;
			SetTimer(0.5 + 2 * FRand(), false);
			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) ) 
				Pawn(Owner).SwitchToBestWeapon();
			if ( Pawn(Owner).bFire != 0 ) Fire(0.0);
			if ( Pawn(Owner).bAltFire != 0 ) AltFire(0.0);	
			Disable('AnimEnd');
			PlayIdleAnim();
		}
	}

	function AnimEnd()
	{
		if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
			PlayIdleAnim();
		else
			Super.AnimEnd();
	}

	function EndState()
	{
		SetTimer(0.0, false);
		Super.EndState();
	}
	
	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}
}

function Finish()
{
    if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
    {
        if (bChangeWeapon)
            GotoState('DownWeapon');
        else if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
        {
            Pawn(Owner).StopFiring();
            Pawn(Owner).SwitchToBestWeapon();
            if (bChangeWeapon)
                GotoState('DownWeapon');
        }
        else
            GotoState('Idle');
        return;
    }
    Super.Finish();
}

function Fire( float Value )
{
    if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
        return;
    Super.Fire(Value);
}

function AltFire( float Value )
{
    if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
        return;
    Super.AltFire(Value);
}

defaultproperties {
	AltProjectileClass=Class'ST_ShockProj'
}
