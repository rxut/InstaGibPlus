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

// V4 deterministic fire
var float NextV4FireTS;
var bool bV4WasAltHeld;
var int V4CachedChargeData;
var int V4AltAmmoSpent;
var int V4ClientPredictedAmmo;
var float V4AltChargeStartTS;

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

// V4 deterministic fire — primary (interval) + alt (charge).

simulated function bool IsV4Active() {
	return Level.NetMode != NM_Standalone
		&& IsPingCompEnabled()
		&& bbPlayer(Owner) != none;
}

// One owner's deterministic state must never transfer to the next.
simulated function V4ResetDeterministicState() {
	NextV4FireTS = 0.0;
	bV4WasAltHeld = false;
	V4CachedChargeData = 0;
	V4AltAmmoSpent = 0;
	V4ClientPredictedAmmo = 0;
	V4AltChargeStartTS = 0.0;
}

function GiveTo(Pawn Other) {
	V4ResetDeterministicState();
	Super.GiveTo(Other);
}

function DropFrom(vector StartLocation) {
	V4ResetDeterministicState();
	Super.DropFrom(StartLocation);
}

// Primary fire interval: Fire anim = 9 frames at 30fps base, but Unreal play
// duration lands on the last frame index, so stock timing is 8 / (30 * rate).
simulated function float PrimaryShotInterval() {
	return 8.0 / (30.0 * (0.65 + 0.4 * FireAdjust));
}

// Stock alt burst: 9-frame Fire sequence at 30 fps, played at rate 0.4.
simulated function float AltShotInterval() {
	return 8.0 / (30.0 * 0.4);
}

// Half-step charge ticks: 0..8 = 0.0..4.0, 9 = the 4.1 stock max (~4.5s).
simulated final function int EncodeV4ChargeData(float ClientChargeSize) {
	if (ClientChargeSize >= 4.05)
		return 9;
	return Clamp(int(ClientChargeSize * 2.0 + 0.0001), 0, 8);
}

function IGPlus_ApplyProjectilePingComp(Projectile P) {
	local bbPlayer bbP;

	if (P == none || !IsPingCompEnabled())
		return;

	bbP = bbPlayer(Owner);
	if (bbP != none && bbP.PingAverage > 0 && WImp != none)
		WImp.SimulateProjectile(P, bbP.PingAverage);
}

function Projectile IGPlus_V4ProjectileFire(class<projectile> ProjClass, vector StepLoc, rotator StepView) {
	local Projectile P;
	local vector Start, X, Y, Z;

	StepLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	Owner.MakeNoise(Pawn(Owner).SoundDampening);
	GetAxes(StepView, X, Y, Z);
	Start = StepLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	P = Spawn(ProjClass,,, Start, StepView);
	IGPlus_ApplyProjectilePingComp(P);
	return P;
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
	optional bool bClientPredictedStep,
	optional int V4ChargeData
) {
	local bool bWantsAlt, bWantsPrimary;
	local int TargetAmmoSpent;

	// Switching cancels the paid charge. Spawning a forwarded glob while the
	// weapon is going down can collide at the owner's new weapon position.
	if (bV4WasAltHeld
		&& bbPlayer(Owner) != none
		&& bbPlayer(Owner).IGPlus_V4SwitchAwayFrom(self)) {
		if (!bServerSide)
			StopChargeSound();
		bV4WasAltHeld = false;
		V4AltAmmoSpent = 0;
		V4CachedChargeData = 0;
		V4AltChargeStartTS = 0.0;
		NextV4FireTS = StepTS + AltShotInterval();
		return true;
	}

	if (!bClientPredictedStep && !bV4WasAltHeld)
		return true;

	bWantsAlt = bAltHeld || bForceAlt;
	bWantsPrimary = bFireHeld || bForceFire;

	// --- Alt fire charge tracking (higher priority during active charge) ---
	if (bV4WasAltHeld) {
		if (bServerSide) {
			// Stock cadence: 1 ammo + 1 per 0.5s; client report may only lower it.
			TargetAmmoSpent = 1 + Clamp(int((StepTS - V4AltChargeStartTS) / 0.5), 0, 9);
			TargetAmmoSpent = Min(TargetAmmoSpent, 1 + Clamp(V4ChargeData, 0, 9));
			while (V4AltAmmoSpent < TargetAmmoSpent
				&& AmmoType != none
				&& AmmoType.AmmoAmount > 0) {
				AmmoType.UseAmmo(1);
				V4AltAmmoSpent++;
			}
		}

		if (!bWantsAlt) {
			// Falling edge: alt released → fire charged glob
			bV4WasAltHeld = false;
			if (bServerSide) {
				if (V4AltAmmoSpent > 0) {
					bbPlayer(Owner).IGPlus_V4NoteShot(StepTS, 0.30);
					HandleV4ServerAltFire(StepView, StepLoc, FMin(Clamp(V4AltAmmoSpent - 1, 0, 9) * 0.5, 4.1));
				}
				else
					bbPlayer(Owner).IGPlus_V4HandleOutOfAmmo(self);
				V4AltAmmoSpent = 0;
			}
			NextV4FireTS = StepTS + AltShotInterval();
			return true;
		}
		// Still charging
		return true;
	}

	// Alt rising edge; stock precedence: primary wins a simultaneous edge.
	if (bWantsAlt && !bWantsPrimary) {
		if (StepTS + 0.0001 < NextV4FireTS)
			return true;

		V4AltChargeStartTS = StepTS;
		if (bServerSide) {
			if (AmmoType != none && AmmoType.AmmoAmount > 0) {
				AmmoType.UseAmmo(1);
				V4AltAmmoSpent = 1;
			} else {
				V4AltAmmoSpent = 0;
				bbPlayer(Owner).IGPlus_V4HandleOutOfAmmo(self);
				return true;
			}
		} else {
			HandleV4ClientAltStart();
		}
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
			bbPlayer(Owner).IGPlus_V4NoteShot(StepTS, 0.30);
			HandleV4ServerFire(StepView, StepLoc);
		} else {
			bbPlayer(Owner).IGPlus_V4HandleOutOfAmmo(self);
		}
	} else {
		bbPlayer(Owner).IGPlus_V4NoteShot(StepTS, 0.30);
		HandleV4ClientFire(StepView, StepLoc);
	}

	NextV4FireTS = StepTS + PrimaryShotInterval();
	return true;
}

function HandleV4ServerFire(rotator StepView, vector StepLoc) {
	bCanClientFire = true;
	bPointing = true;

	PlayerPawn(Owner).PlayRecoil(FiringSpeed);
	// Mid-switch shot: no fire anim or state change, or the holster schedule
	// is hijacked (see ST_ShockRifle.HandleV4ServerFire).
	if (!bChangeWeapon && !IsInState('DownWeapon'))
		V4PlayPrimaryFiringAnim();
	if (Affector != none)
		Affector.FireEffect();
	IGPlus_V4ProjectileFire(ProjectileClass, StepLoc, StepView);
	if (!bChangeWeapon && !IsInState('DownWeapon'))
		GoToState('NormalFire');
}

function HandleV4ServerAltFire(rotator StepView, vector StepLoc, float CS) {
	local Projectile Gel;

	Gel = IGPlus_V4ProjectileFire(AltProjectileClass, StepLoc, StepView);
	if (Gel != none)
		Gel.DrawScale = 1.0 + 0.8 * CS;
	if (Affector != none)
		Affector.FireEffect();
	// Mid-switch shot: no fire anim or state change, or the holster schedule
	// is hijacked (see ST_ShockRifle.HandleV4ServerFire).
	if (!bChangeWeapon && !IsInState('DownWeapon')) {
		PlayAltBurst();
		GotoState('NormalFire');
	}
}

simulated function V4PlayPrimaryFiringAnim() {
	PlayOwnedSound(AltFireSound, SLOT_None, 1.7 * Pawn(Owner).SoundDampening);
	PlayAnim('Fire', 0.65 + 0.4 * FireAdjust, 0.05);
}

simulated function HandleV4ClientFire(rotator StepView, vector StepLoc) {
	local bbPlayer BP;

	BP = bbPlayer(Owner);

	bPointing = true;
	if (FiringSpeed > 0)
		BP.PlayRecoil(FiringSpeed);
	V4PlayPrimaryFiringAnim();
	if (Affector != none)
		Affector.FireEffect();
	BP.ClientInstantFlash(InstFlash, InstFog);
	if (BP.ClientWeaponSettingsData.bBioUseClientSideAnimations)
		SpawnClientDummyBioGel();
}

simulated function HandleV4ClientAltStart() {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;
	if (AmmoType == none && AmmoName != none)
		GiveAmmo(PawnOwner);
	if (AmmoType == none || AmmoType.AmmoAmount <= 0)
		return;

	Instigator = PawnOwner;
	AmmoType.UseAmmo(1);
	bPointing = true;
	bCanClientFire = true;
	GotoState('ClientAltFiring');
	PlayAltFiring();
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

function Fire( float Value )
{
	if (Role == ROLE_Authority && IsV4Active())
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

	P = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
	IGPlus_ApplyProjectilePingComp(P);
	return P;
}

simulated function bool ClientFire(float Value)
{
	// V4 handles primary fire visuals through HandleV4ClientFire.
	if (IsV4Active())
		return true;

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

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	// The deterministic step owns cooldown, ammo prediction, and state entry.
	if (IsV4Active())
		return true;

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

// Bounce pending switches to DownWeapon before the inherited Idle label
// clobbers a manual weapon choice.
state Idle
{
	function BeginState()
	{
		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
			GotoState('DownWeapon');
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
				V4ClientPredictedAmmo = AmmoType.AmmoAmount;
				ChargeSize += Count;
				Count = 0;
			}
		}

		// Keep local HUD responsive while charging. Server ammo is authoritative,
		// but it can arrive slightly delayed and briefly overwrite local prediction.
		if (AmmoType != none && V4ClientPredictedAmmo >= 0 && AmmoType.AmmoAmount > V4ClientPredictedAmmo)
			AmmoType.AmmoAmount = V4ClientPredictedAmmo;

		// Update V4 charge data every tick for tick-order-safe capture.
		V4CachedChargeData = EncodeV4ChargeData(ChargeSize);

		if (PawnOwner.bAltFire == 0) {
			ChargeSize = FMin(ChargeSize, 4.1);

			bbP = bbPlayer(PawnOwner);
			if (bbP != None && bbP.ClientWeaponSettingsData.bBioUseClientSideAnimations)
				SpawnClientDummyBioGlob(ChargeSize);

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
		V4ClientPredictedAmmo = -1;
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

// Playing the looping charge sound at zero volume in its slot silences it.
simulated function StopChargeSound()
{
	PlayOwnedSound(Sound'Botpack.BioRifle.BioAltRep', SLOT_Misc, 0.0);
}

simulated function ClientPutDown(Weapon NextWeapon)
{
	if (IsInState('ClientAltFiring'))
		StopChargeSound();

	Super.ClientPutDown(NextWeapon);
}

state AltFiring
{
	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if (bChangeWeapon)
		{
			StopChargeSound();
			GotoState('DownWeapon');
		}
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

	V4ResetDeterministicState();
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
