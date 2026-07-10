// ===============================================================
// UTPureStats7A.ST_ripper: Ripper with V4 deterministic fire
// ===============================================================

class ST_ripper extends ripper;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var ST_Razor2 LocalRazor2Dummy;
var ST_Razor2Alt LocalRazor2AltDummy;

var float NextV4FireTS;

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
	return WS != None && WS.RipperCompensatePing;
}

simulated function bool IsV4Active() {
	if (!IsPingCompEnabled())
		return false;
	if (bbPlayer(Owner) == none)
		return false;
	return true;
}

// One owner's deterministic state must never transfer to the next.
simulated function V4ResetDeterministicState() {
	NextV4FireTS = 0.0;
}

function GiveTo(Pawn Other) {
	V4ResetDeterministicState();
	Super.GiveTo(Other);
}

function DropFrom(vector StartLocation) {
	V4ResetDeterministicState();
	Super.DropFrom(StartLocation);
}

// Ripper 'Fire' anim: NumFrames=15, Rate=30fps (default)
// Unreal play duration is based on the last frame index, so use
// (NumFrames - 1) / (Rate * PlayRate) to match stock refire timing.
simulated function float PrimaryShotInterval() {
	local float RateScale;
	RateScale = 0.7 + 0.6 * FireAdjust;
	if (RateScale <= 0.001)
		return 0.50;
	return FClamp(14.0 / (30.0 * RateScale), 0.05, 2.0);
}

simulated function float AltShotInterval() {
	local float RateScale;
	RateScale = 0.4 + 0.3 * FireAdjust;
	if (RateScale <= 0.001)
		return 0.50;
	return FClamp(14.0 / (30.0 * RateScale), 0.05, 2.0);
}

simulated function V4PlayFireAnim(bool bAlt) {
	if (bAlt) {
		PlayAnim('Fire', 0.4 + 0.3 * FireAdjust, 0.05);
		PlayOwnedSound(class'Razor2Alt'.Default.SpawnSound, SLOT_None, Pawn(Owner).SoundDampening * 4.2);
	} else {
		PlayAnim('Fire', 0.7 + 0.6 * FireAdjust, 0.05);
		PlayOwnedSound(class'Razor2'.Default.SpawnSound, SLOT_None, Pawn(Owner).SoundDampening * 4.2);
	}
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
	optional bool bClientPredictedStep
) {
	local bool bAlt;
	local bbPlayer BP;
	local int FireMode;
	local float Interval;

	if (!bClientPredictedStep)
		return true;

	if (!bFireHeld && !bForceFire && !bAltHeld && !bForceAlt) {
		if (!bServerSide && AnimSequence == 'Fire')
			PlayIdleAnim();
		return true;
	}

	BP = bbPlayer(Owner);
	if (BP == none)
		return true;
	FireMode = BP.IGPlus_V4IntervalShotDue(
		StepTS, bFireHeld, bAltHeld, bForceFire, bForceAlt,
		PrimaryShotInterval(), AltShotInterval(), NextV4FireTS, Interval);
	if (FireMode == 0)
		return true;
	bAlt = FireMode == 2;

	if (AmmoType != none && AmmoType.AmmoAmount > 0) {
		if (bServerSide)
			HandleV4ServerFire(bAlt, StepView, StepLoc);
		else
			HandleV4ClientFire(bAlt, StepView, StepLoc);
	} else if (bServerSide) {
		bbPlayer(Owner).IGPlus_V4HandleOutOfAmmo(self);
	}

	NextV4FireTS = StepTS + Interval;
	return true;
}

simulated function HandleV4ClientFire(bool bAlt, rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;
	local bbPlayer BP;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;
	BP = bbPlayer(PawnOwner);

	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();
	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(450, 190, 650));

	if (bAlt) {
		V4PlayFireAnim(true);
		if (BP != none && BP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
			SpawnClientSideRazorAlt(true, StepView, StepLoc);
	} else {
		V4PlayFireAnim(false);
		if (BP != none && BP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
			SpawnClientSideRazor(true, StepView, StepLoc);
	}
}

function HandleV4ServerFire(bool bAlt, rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	AmmoType.UseAmmo(1);

	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();

	if (bAlt) {
		V4PlayFireAnim(true);
	} else {
		V4PlayFireAnim(false);
	}
	SpawnServerRazorAt(bAlt, StepLoc, StepView, StepView);
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;
}

function SpawnServerRazor()
{
	local Pawn PawnOwner;
	local rotator AimRot;

	PawnOwner = Pawn(Owner);
	AimRot = PawnOwner.AdjustAim(ProjectileSpeed, Owner.Location, AimError, True, bWarnTarget);
	SpawnServerRazorAt(false, Owner.Location, AimRot, PawnOwner.ViewRotation);
}

function SpawnServerRazorAlt()
{
	local Pawn PawnOwner;
	local rotator AimRot;

	PawnOwner = Pawn(Owner);
	AimRot = PawnOwner.AdjustAim(AltProjectileSpeed, Owner.Location, AimError, True, bAltWarnTarget);
	SpawnServerRazorAt(true, Owner.Location, AimRot, PawnOwner.ViewRotation);
}

function SpawnServerRazorAt(bool bAlt, vector ShotLoc, rotator AimRot, rotator OffsetRot)
{
	local Vector Start, X, Y, Z;
	local Pawn PawnOwner;
	local Projectile Razor;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	// SetHand already mirrors FireOffset.Y; applying Handedness again flips Right back to Left.
	GetAxes(OffsetRot, X, Y, Z);
	if (bHideWeapon)
		Start = ShotLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z;
	else
		Start = ShotLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	PawnOwner.MakeNoise(PawnOwner.SoundDampening);

	if (bAlt)
		Razor = Spawn(class'ST_Razor2Alt', Owner,, Start, AimRot);
	else
		Razor = Spawn(class'ST_Razor2', Owner,, Start, AimRot);

	if (bbP != None && IsPingCompEnabled()) {
		WImp.SimulateProjectile(Razor, bbP.PingAverage);
	}
}

function Finish()
{
	if (IsV4Active() && PlayerPawn(Owner) != None)
	{
		if (bChangeWeapon)
			GotoState('DownWeapon');
		else if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
		{
			bbPlayer(Owner).IGPlus_V4HandleOutOfAmmo(self);
			if (bChangeWeapon)
				GotoState('DownWeapon');
			else
				GotoState('Idle');
		}
		else
			GotoState('Idle');
		return;
	}
	Super.Finish();
}

function Fire(float Value)
{
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	if (AmmoType == None)
		GiveAmmo(PawnOwner);

	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing = True;
		PawnOwner.PlayRecoil(FiringSpeed);
		PlayFiring();
		SpawnServerRazor();
		ClientFire(Value);
		GoToState('NormalFire');
	}
}

function AltFire(float Value)
{
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	if (AmmoType == None)
		GiveAmmo(PawnOwner);

	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing = True;
		PawnOwner.PlayRecoil(FiringSpeed);
		PlayAltFiring();
		SpawnServerRazorAlt();
		ClientAltFire(Value);
		GoToState('AltFiring');
	}
}

simulated function bool ClientFire(float Value) {
	if (!bCanClientFire)
		return false;
	if (Pawn(Owner) == none)
		return false;
	if (IsV4Active())
		return true;
	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire(float Value) {
	if (!bCanClientFire)
		return false;
	if (Pawn(Owner) == none)
		return false;
	if (IsV4Active())
		return true;
	return Super.ClientAltFire(Value);
}

function bool PutDown() {
	local bbPlayer BP;
	BP = bbPlayer(Owner);
	if (BP != none)
		BP.IGPlus_MarkDeterministicSwitchGuard();
	bCanClientFire = false;
	return Super.PutDown();
}

state ClientActive
{
	simulated function AnimEnd()
	{
		bCanClientFire = true;
		Super.AnimEnd();
	}
}

state ClientFiring
{
	simulated function AnimEnd()
	{
		if (IsV4Active()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}
		Super.AnimEnd();
	}
}

state ClientAltFiring
{
	simulated function AnimEnd()
	{
		if (IsV4Active()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}
		Super.AnimEnd();
	}
}

simulated function SpawnClientSideRazor(
	optional bool bUseShotData,
	optional rotator ShotView,
	optional vector ShotLoc
)
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;
	local bbPlayer bbP;
	local rotator AimRot;
	local vector AimLoc;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	if (Role < ROLE_Authority && bbP != None && bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
	{
		// SetHand never runs on the client instance, so FireOffset.Y is still
		// the unmirrored default here and must be multiplied by Handedness.
		if (Owner.IsA('PlayerPawn'))
			Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
		else
			Hand = 1.0;

		if (bUseShotData) {
			AimRot = ShotView;
			AimLoc = ShotLoc;
		} else {
			AimRot = PawnOwner.ViewRotation;
			AimLoc = Owner.Location;
		}

		GetAxes(AimRot, X, Y, Z);
		if (bHideWeapon)
			Start = AimLoc + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
		else
			Start = AimLoc + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
		if (bbP != None)
			Start.Z += bbP.GetMoverFireZOffset();

		LocalRazor2Dummy = Spawn(class'ST_Razor2', Owner,, Start, AimRot);
		LocalRazor2Dummy.RemoteRole = ROLE_None;
		LocalRazor2Dummy.bClientVisualOnly = true;
		LocalRazor2Dummy.SetCollision(false, false, false);
		LocalRazor2Dummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	}
}

simulated function SpawnClientSideRazorAlt(
	optional bool bUseShotData,
	optional rotator ShotView,
	optional vector ShotLoc
)
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;
	local bbPlayer bbP;
	local rotator AimRot;
	local vector AimLoc;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	if (Role < ROLE_Authority && bbP != None && bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
	{
		// SetHand never runs on the client instance, so FireOffset.Y is still
		// the unmirrored default here and must be multiplied by Handedness.
		if (Owner.IsA('PlayerPawn'))
			Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
		else
			Hand = 1.0;

		if (bUseShotData) {
			AimRot = ShotView;
			AimLoc = ShotLoc;
		} else {
			AimRot = PawnOwner.ViewRotation;
			AimLoc = Owner.Location;
		}

		GetAxes(AimRot, X, Y, Z);
		if (bHideWeapon)
			Start = AimLoc + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
		else
			Start = AimLoc + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
		if (bbP != None)
			Start.Z += bbP.GetMoverFireZOffset();

		LocalRazor2AltDummy = Spawn(class'ST_Razor2Alt', Owner,, Start, AimRot);
		LocalRazor2AltDummy.RemoteRole = ROLE_None;
		LocalRazor2AltDummy.bClientVisualOnly = true;
		LocalRazor2AltDummy.SetCollision(false, false, false);
		LocalRazor2AltDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
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

		bPointing = false;

		if (IsV4Active())
		{
			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
				Pawn(Owner).SwitchToBestWeapon();

			Disable('AnimEnd');
			PlayIdleAnim();
		}
		else
		{
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
		if (IsV4Active())
			PlayIdleAnim();
		else
			Super.AnimEnd();
	}

	function bool PutDown()
	{
		GotoState('DownWeapon');
		return True;
	}
}

simulated function vector CalcDrawOffsetClient() {
	local vector DrawOffset;
	local Pawn PawnOwner;
	local vector WeaponBob;
	
	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return vect(0,0,0);

	DrawOffset = CalcDrawOffset();
	
	if (Level.NetMode == NM_Client) {
		DrawOffset -= (PawnOwner.EyeHeight * vect(0,0,1));
		DrawOffset += (PawnOwner.BaseEyeHeight * vect(0,0,1));
	
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
		carried = 'ripper';
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
		PlayAnim('Select',GetWeaponSettings().RipperSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().RipperDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().RipperDownAnimSpeed(), TweenTime);
}

defaultproperties {
	ProjectileClass=Class'ST_Razor2'
	AltProjectileClass=Class'ST_Razor2Alt'
}
