// ===============================================================
// UTPureStats7A.ST_ripper: Ripper with V4 deterministic fire
// ===============================================================

class ST_ripper extends ripper;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;


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
	return Level.NetMode != NM_Standalone
		&& IsPingCompEnabled()
		&& bbPlayer(Owner) != none;
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

// 'Fire' anim: 15 frames at 30fps; UE plays to the last frame index, so refire = 14/(30*PlayRate).
simulated function float PrimaryShotInterval() {
	return FClamp(14.0 / (30.0 * (0.7 + 0.6 * FireAdjust)), 0.05, 2.0);
}

simulated function float AltShotInterval() {
	return FClamp(14.0 / (30.0 * (0.4 + 0.3 * FireAdjust)), 0.05, 2.0);
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

simulated function bool V4ProcessInputSlice(
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
		// Fire-anim length from stock mesh data; see bbPlayer.IGPlus_V4NoteShot.
		if (bAlt)
			BP.IGPlus_V4NoteShot(StepTS, 0.72);
		else
			BP.IGPlus_V4NoteShot(StepTS, 0.41);
		if (bServerSide)
			HandleV4ServerFire(bAlt, StepView, StepLoc);
		else
			HandleV4ClientFire(bAlt, StepView, StepLoc);
	} else if (bServerSide) {
		BP.IGPlus_V4HandleOutOfAmmo(self);
	}

	NextV4FireTS = StepTS + Interval;
	return true;
}

simulated function HandleV4ClientFire(bool bAlt, rotator StepView, vector StepLoc) {
	local bbPlayer BP;

	BP = bbPlayer(Owner);

	bPointing = true;
	BP.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();
	BP.ClientInstantFlash(-0.4, vect(450, 190, 650));

	V4PlayFireAnim(bAlt);
	if (BP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
		SpawnClientSideRazorAt(bAlt, StepView, StepLoc);
}

function HandleV4ServerFire(bool bAlt, rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	AmmoType.UseAmmo(1);

	bPointing = true;
	PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();

	// Mid-switch shot: no fire anim, or it hijacks the holster schedule
	// (see ST_ShockRifle.HandleV4ServerFire).
	if (!bChangeWeapon && !IsInState('DownWeapon'))
		V4PlayFireAnim(bAlt);
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
	if (IsV4Active())
	{
		if (!bChangeWeapon && AmmoType != None && AmmoType.AmmoAmount <= 0)
			bbPlayer(Owner).IGPlus_V4HandleOutOfAmmo(self);
		if (bChangeWeapon)
			GotoState('DownWeapon');
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

simulated function SpawnClientSideRazorAt(bool bAlt, rotator ShotView, vector ShotLoc)
{
	local vector X, Y, Z;
	local vector Start;
	local float Hand;
	local bbPlayer bbP;
	local ST_Razor2 Dummy;
	local ST_Razor2Alt AltDummy;
	local Projectile Razor;

	bbP = bbPlayer(Owner);
	if (Role >= ROLE_Authority || bbP == None || !bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
		return;

	// SetHand never runs on the client instance, so FireOffset.Y is still
	// the unmirrored default here and must be multiplied by Handedness.
	Hand = FClamp(bbP.Handedness, -1.0, 1.0);

	GetAxes(ShotView, X, Y, Z);
	if (bHideWeapon)
		Start = ShotLoc + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
	else
		Start = ShotLoc + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	Start.Z += bbP.GetMoverFireZOffset();

	if (bAlt) {
		AltDummy = Spawn(class'ST_Razor2Alt', Owner,, Start, ShotView);
		AltDummy.bClientVisualOnly = true;
		Razor = AltDummy;
	} else {
		Dummy = Spawn(class'ST_Razor2', Owner,, Start, ShotView);
		Dummy.bClientVisualOnly = true;
		Razor = Dummy;
	}
	Razor.RemoteRole = ROLE_None;
	Razor.SetCollision(false, false, false);
	Razor.LifeSpan = bbP.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
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
		if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
			Pawn(Owner).SwitchToBestWeapon();
		if (!IsV4Active())
		{
			if ( Pawn(Owner).bFire != 0 ) Fire(0.0);
			if ( Pawn(Owner).bAltFire != 0 ) AltFire(0.0);
		}
		Disable('AnimEnd');
		PlayIdleAnim();
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
