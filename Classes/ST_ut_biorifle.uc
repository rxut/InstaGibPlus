// ===============================================================
// UTPureStats7A.ST_ut_biorifle: put your comment here
//
// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_ut_biorifle extends ut_biorifle;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var ST_UT_BioGel LocalBioGelDummy;
var ST_BioGlob LocalBioGlobDummy;

// Explicit client aim data (sent via ServerExplicitFire)
var vector ExplicitClientLoc;
var rotator ExplicitClientRot;
var bool bUseExplicitData;

// Server-side position validation
const MAX_POSITION_ERROR_SQ = 1250.0;

// V4 deterministic fire
var float NextV4FireTS;
var bool bV4WasAltHeld;
var int V4CachedChargeData;

replication
{
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
	return WS != None && WS.BioCompensatePing;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;
}

function bool IsPositionReasonable(vector ClientLoc)
{
	local vector Diff;

	if (IsPingCompEnabled() && Mover(Owner.Base) != None)
		return true;

	Diff = ClientLoc - Owner.Location;
	return (Diff dot Diff) < MAX_POSITION_ERROR_SQ;
}

// =========================================================================
// V4 Deterministic Fire — Primary (Interval) + Alt (Charge)
// =========================================================================

simulated function bool IsV4Active() {
	if (!IsPingCompEnabled())
		return false;
	if (bbPlayer(Owner) == none)
		return false;
	return true;
}

simulated function bool IsDeterministicReady() {
	local Pawn PawnOwner;

	if (!IsV4Active())
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;
	if (bbPlayer(PawnOwner).IGPlus_IsDeterministicSwitchGuardActive())
		return false;
	if (TournamentPlayer(PawnOwner) != none
		&& TournamentPlayer(PawnOwner).ClientPending != none
		&& TournamentPlayer(PawnOwner).ClientPending != self)
		return false;
	if (PawnOwner.Weapon != self)
		return false;
	if (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		return false;
	if (bChangeWeapon)
		return false;
	if (IsInState('Pickup'))
		return false;
	if (IsInState('DownWeapon'))
		return false;
	if (IsInState('ClientDown'))
		return false;
	if (!bCanClientFire)
		return false;
	return true;
}

// Primary fire interval: Fire anim = 9 frames at 30fps base, PlayRate = 0.65+0.4*FireAdjust.
simulated function float PrimaryShotInterval() {
	return 9.0 / (30.0 * (0.65 + 0.4 * FireAdjust));
}

simulated function bool V4ProcessStep(
	float StepTS,
	rotator StepView,
	vector StepLoc,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	bool bServerSide,
	optional bool bStepReadyHint,
	optional int V4ChargeData
) {
	local bool bWantsAlt, bWantsPrimary;
	local float CS;
	local int AmmoToConsume, ActualCharge;

	if (!bStepReadyHint && !IsDeterministicReady())
		return true;

	bWantsAlt = bAltHeld || bForceAlt;
	bWantsPrimary = bFireHeld || bForceFire;

	// --- Alt fire charge tracking (higher priority during active charge) ---
	if (bV4WasAltHeld) {
		if (!bWantsAlt) {
			// Falling edge: alt released → fire charged glob
			bV4WasAltHeld = false;
			if (bServerSide) {
				ActualCharge = V4ChargeData;
				AmmoToConsume = ActualCharge + 1;
				if (AmmoType != none) {
					AmmoToConsume = Min(AmmoToConsume, AmmoType.AmmoAmount);
					ActualCharge = Max(AmmoToConsume - 1, 0);
				}
				CS = float(ActualCharge) * 0.5;
				if (AmmoType != none && AmmoType.AmmoAmount > 0) {
					AmmoType.UseAmmo(AmmoToConsume);
					HandleV4ServerAltFire(StepView, StepLoc, CS);
				} else {
					V4HandleOutOfAmmo();
				}
			}
			NextV4FireTS = StepTS + 0.25;
			return true;
		}
		// Still charging
		return true;
	}

	// Alt rising edge: start charging
	if (bWantsAlt) {
		bV4WasAltHeld = true;
		return true;
	}

	// --- Primary fire (interval-based) ---
	if (!bWantsPrimary)
		return true;

	if (StepTS + 0.0001 < NextV4FireTS)
		return true;

	if (bServerSide) {
		if (AmmoType != none && AmmoType.AmmoAmount > 0) {
			AmmoType.UseAmmo(1);
			HandleV4ServerFire(StepView, StepLoc);
		} else {
			V4HandleOutOfAmmo();
		}
	} else {
		HandleV4ClientFire(StepView, StepLoc);
	}

	NextV4FireTS = StepTS + PrimaryShotInterval();
	return true;
}

function HandleV4ServerFire(rotator StepView, vector StepLoc) {
	local PlayerPawn P;

	P = PlayerPawn(Owner);
	if (P == none)
		return;

	ExplicitClientLoc = StepLoc;
	if (bbPlayer(Owner) != none)
		ExplicitClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	ExplicitClientRot = StepView;
	bUseExplicitData = true;

	bCanClientFire = true;
	bPointing = true;

	P.PlayRecoil(FiringSpeed);
	PlayFiring();
	if (Affector != none)
		Affector.FireEffect();
	ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
	GoToState('NormalFire');

	bUseExplicitData = false;
}

function HandleV4ServerAltFire(rotator StepView, vector StepLoc, float CS) {
	local PlayerPawn P;
	local Projectile Gel;

	P = PlayerPawn(Owner);
	if (P == none)
		return;

	ExplicitClientLoc = StepLoc;
	if (bbPlayer(Owner) != none)
		ExplicitClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	ExplicitClientRot = StepView;
	bUseExplicitData = true;

	Owner.MakeNoise(P.SoundDampening);
	Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	if (Gel != none)
		Gel.DrawScale = 1.0 + 0.8 * CS;
	if (Affector != none)
		Affector.FireEffect();
	PlayAltBurst();
	GotoState('NormalFire');

	bUseExplicitData = false;
}

simulated function HandleV4ClientFire(rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;
	local bbPlayer BP;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;
	BP = bbPlayer(PawnOwner);

	bPointing = true;
	if (FiringSpeed > 0)
		PawnOwner.PlayRecoil(FiringSpeed);
	PlayFiring();
	if (Affector != none)
		Affector.FireEffect();
	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).ClientInstantFlash(InstFlash, InstFog);
	if (BP != none && BP.ClientWeaponSettingsData.bBioUseClientSideAnimations)
		SpawnClientDummyBioGel();
}

function V4HandleOutOfAmmo() {
	local Pawn P;
	P = Pawn(Owner);
	if (P == none)
		return;
	P.StopFiring();
	if (P.PendingWeapon == none || P.PendingWeapon == self)
		P.SwitchToBestWeapon();
}

// Server function called by client when firing
function ServerExplicitFire(vector ClientLoc, rotator ClientRot, optional bool bIsSwitching)
{
	local PlayerPawn P;
	
	P = PlayerPawn(Owner);
	if (P == None)
		return;

	if (!IsPingCompEnabled())
		return;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) &&
         (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self)) )
	{
		AmmoType.UseAmmo(1);

		// Position validation - use server position if client position is unreasonable
		if (bbPlayer(Owner) != None)
			ClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
		if (IsPositionReasonable(ClientLoc))
			ExplicitClientLoc = ClientLoc;
		else
			ExplicitClientLoc = Owner.Location;
		
		ExplicitClientRot = ClientRot;
		bUseExplicitData = true;

		P.PlayRecoil(FiringSpeed);
		PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 4.0);
		if (Affector != None)
			Affector.FireEffect();
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		
		bUseExplicitData = false;
		bChangeWeapon = true;
		GotoState('DownWeapon'); // Manually trigger the transition
		return;
	}
	
	if (bChangeWeapon || IsInState('DownWeapon') || P.Weapon != self)
 		return;

	// Position validation - use server position if client position is unreasonable
	if (bbPlayer(Owner) != None)
		ClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	if (IsPositionReasonable(ClientLoc))
		ExplicitClientLoc = ClientLoc;
	else
		ExplicitClientLoc = Owner.Location;
	
	ExplicitClientRot = ClientRot;
	bUseExplicitData = true;

	if (AmmoType == None)
		GiveAmmo(P);

	if (AmmoType != None && AmmoType.AmmoAmount > 0)
	{
		AmmoType.UseAmmo(1);
		
		bCanClientFire = true;
		bPointing = True;
		
		P.PlayRecoil(FiringSpeed);
		PlayFiring();
		if (Affector != None)
			Affector.FireEffect();
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		GoToState('NormalFire');
	}

	bUseExplicitData = false;
}

function ServerExplicitAltFire(vector ClientLoc, rotator ClientRot, float ClientChargeSize)
{
	local PlayerPawn P;
	local Projectile Gel;
	local bbPlayer bbP;

	P = PlayerPawn(Owner);
	if (P == None)
		return;

	if (!IsPingCompEnabled())
		return;

	if (bChangeWeapon || IsInState('DownWeapon') || P.Weapon != self)
		return;

	ClientChargeSize = FClamp(ClientChargeSize, 0.0, 4.1);

	if (bbPlayer(Owner) != None)
		ClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	if (IsPositionReasonable(ClientLoc))
		ExplicitClientLoc = ClientLoc;
	else
		ExplicitClientLoc = Owner.Location;

	ExplicitClientRot = ClientRot;
	bUseExplicitData = true;

	if (AmmoType == None)
		GiveAmmo(P);

	if (AmmoType != None && AmmoType.AmmoAmount > 0)
	{
		bbP = bbPlayer(P);

		Owner.MakeNoise(P.SoundDampening);
		Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
		if (Gel != None)
			Gel.DrawScale = 1.0 + 0.8 * ClientChargeSize;

		if (Affector != None)
			Affector.FireEffect();

		PlayAltBurst();
		GotoState('NormalFire');
	}

	bUseExplicitData = false;
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
	if (Role == ROLE_Authority && IsV4Active())
		return;
	if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
		return;

	Super.Fire(Value);
}

function AltFire( float Value )
{
	if (Role == ROLE_Authority && IsV4Active())
		return;

	Super.AltFire(Value);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local Projectile P;
    local bbPlayer bbP;
    local Vector Start, X, Y, Z;

    if (bUseExplicitData)
    {
        // Explicit Fire Logic using client data
        Owner.MakeNoise(Pawn(Owner).SoundDampening);
        GetAxes(ExplicitClientRot, X, Y, Z);
        Start = ExplicitClientLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
        
        // Direct spawn using explicit rotation
        P = Spawn(ProjClass,,, Start, ExplicitClientRot);
    }
    else
    {
        // Standard Logic (original behavior)
        P = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
    }
    
    // Check if we should apply ping compensation (for both explicit and standard fire)
    if (P != None && IsPingCompEnabled()) {
        bbP = bbPlayer(Owner);
        if (bbP != None && bbP.PingAverage > 0 && WImp != None) {
            // Simulate projectile forward by player's ping time
            WImp.SimulateProjectile(P, bbP.PingAverage);
        }
    }
    
    return P;
}

simulated function bool ClientFire(float Value)
{
	local Pawn PawnOwner;
	local bbPlayer bbP;

	// V4 handles primary fire visuals through HandleV4ClientFire.
	if (IsV4Active())
		return true;

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
			if (AmmoType == None && AmmoName != None)
				GiveAmmo(PawnOwner);
			
			if (AmmoType != None && AmmoType.AmmoAmount > 0)
			{
				Instigator = PawnOwner;
				
				if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
				{
					ServerExplicitFire(PawnOwner.Location, PawnOwner.ViewRotation, true);
					return true;
				}

				GotoState('ClientFiring');
				bPointing = True;

				// Always play weapon animations
				PawnOwner.PlayRecoil(FiringSpeed);
				PlayFiring();

				if (Affector != None)
					Affector.FireEffect();

				if (PlayerPawn(Owner) != None)
					PlayerPawn(Owner).ClientInstantFlash(InstFlash, InstFog);

				// Spawn client-side visual
				if (bbP.ClientWeaponSettingsData.bBioUseClientSideAnimations)
				{
					SpawnClientDummyBioGel();
				}

				// Send explicit fire data to server
				ServerExplicitFire(PawnOwner.Location, PawnOwner.ViewRotation);

				return true;
			}
			return false;
		}
	}
	
	return Super.ClientFire(Value);
}

simulated function SpawnClientDummyBioGel()
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return;

	if (Owner.IsA('PlayerPawn'))
		Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
	else
		Hand = 1.0;

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	if (bHideWeapon)
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
	else
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	if (bbPlayer(Owner) != None)
		Start.Z += bbPlayer(Owner).GetMoverFireZOffset();

	LocalBioGelDummy = Spawn(class'ST_UT_BioGel', Owner,, Start, PawnOwner.ViewRotation);
	LocalBioGelDummy.RemoteRole = ROLE_None;
	LocalBioGelDummy.Instigator = PawnOwner;
	LocalBioGelDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	LocalBioGelDummy.bClientVisualOnly = true;
	LocalBioGelDummy.bCollideWorld = false;
	LocalBioGelDummy.SetCollision(false, false, false);
}

simulated function bool ClientAltFire(float Value)
{
	local Pawn PawnOwner;
	local bbPlayer bbP;

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
			if (AmmoType == None && AmmoName != None)
				GiveAmmo(PawnOwner);

			if (AmmoType != None && AmmoType.AmmoAmount > 0)
			{
				Instigator = PawnOwner;
				AmmoType.UseAmmo(1);
				bPointing = true;
				bCanClientFire = true;
				GotoState('ClientAltFiring');
				PlayAltFiring();
				return true;
			}
			return false;
		}
	}

	return Super.ClientAltFire(Value);
}

simulated function SpawnClientDummyBioGlob(float ClientChargeSize)
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return;

	if (Owner.IsA('PlayerPawn'))
		Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
	else
		Hand = 1.0;

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	if (bHideWeapon)
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
	else
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	if (bbPlayer(Owner) != None)
		Start.Z += bbPlayer(Owner).GetMoverFireZOffset();

	LocalBioGlobDummy = Spawn(class'ST_BioGlob', Owner,, Start, PawnOwner.ViewRotation);
	if (LocalBioGlobDummy != None) {
		LocalBioGlobDummy.RemoteRole = ROLE_None;
		LocalBioGlobDummy.Instigator = PawnOwner;
		LocalBioGlobDummy.DrawScale = 1.0 + 0.8 * ClientChargeSize;
		LocalBioGlobDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
		LocalBioGlobDummy.bClientVisualOnly = true;
		LocalBioGlobDummy.bCollideWorld = false;
		LocalBioGlobDummy.SetCollision(false, false, false);
	}
}

state ClientAltFiring
{
	simulated function Tick(float DeltaTime)
	{
		local Pawn PawnOwner;
		local bbPlayer bbP;

		PawnOwner = Pawn(Owner);
		if (PawnOwner == None) {
			GotoState('');
			return;
		}

		if (!bCanClientFire) {
			GotoState('');
			return;
		}

		if (ChargeSize < 4.1) {
			Count += DeltaTime;
			if (Count > 0.5 && AmmoType != None && AmmoType.AmmoAmount > 0) {
				AmmoType.UseAmmo(1);
				ChargeSize += Count;
				Count = 0;
			}
		}

		// Update V4 charge data every tick for tick-order-safe capture.
		V4CachedChargeData = Clamp(int(FMin(ChargeSize, 4.1) * 2.0), 0, 7);

		if (PawnOwner.bAltFire == 0) {
			ChargeSize = FMin(ChargeSize, 4.1);

			bbP = bbPlayer(PawnOwner);
			if (bbP != None && bbP.ClientWeaponSettingsData.bBioUseClientSideAnimations)
				SpawnClientDummyBioGlob(ChargeSize);

			// V4 handles alt fire deterministically; skip RPC.
			if (!IsV4Active())
				ServerExplicitAltFire(PawnOwner.Location, PawnOwner.ViewRotation, ChargeSize);

			if (Affector != None)
				Affector.FireEffect();
			PlayAltBurst();

			ChargeSize = 0.0;
			Count = 0.0;
			GotoState('ClientFiring');
		}
	}

	simulated function AnimEnd()
	{
		TweenAnim('Loaded', 0.5);
	}

	simulated function bool ClientFire(float Value)
	{
		return false;
	}

	simulated function bool ClientAltFire(float Value)
	{
		return false;
	}

	simulated function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
		V4CachedChargeData = 0;
	}
}

state ClientActive
{
	simulated function AnimEnd()
	{
		bCanClientFire = true;
		Super.AnimEnd();
	}
}

state ShootLoad
{

    function BeginState()
    {
        Local Projectile Gel;

        Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
        
        if (Gel != None)
            Gel.DrawScale = 1.0 + 0.8 * ChargeSize;
        
        if (Affector != None)
            Affector.FireEffect();
        
        PlayAltBurst();
    }

Begin:
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
		carried = 'ut_biorifle';
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
		PlayAnim('Select',GetWeaponSettings().BioSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().BioDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().BioDownAnimSpeed(), TweenTime);
}


defaultproperties {
	ProjectileClass=Class'ST_UT_BioGel'
	AltProjectileClass=Class'ST_BioGlob'
}
