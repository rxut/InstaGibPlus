// ===============================================================
// Stats.ST_ShockRifle: ShockRifle with ping compensation
// ===============================================================

class ST_ShockRifle extends ShockRifle;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var float yMod;
var vector CDO;

var ST_ShockProj LocalDummy;
var vector PendingSmokeLocation;

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
	return WS != None && WS.bEnablePingCompensation;
}

simulated function bool IsV4Active() {
	return Level.NetMode != NM_Standalone
		&& IsPingCompEnabled()
		&& bbPlayer(Owner) != none;
}

// One owner's deterministic state must never transfer to the next
// (dropped weapons are reused as pickups — SpawnCopy returns self).
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

simulated function float PrimaryShotInterval() {
	return FClamp(10.0 / (21.0 * (0.30 + 0.30 * FireAdjust)), 0.05, 2.0);
}

simulated function float AltShotInterval() {
	return FClamp(10.0 / (24.0 * (0.40 + 0.40 * FireAdjust)), 0.05, 2.0);
}

// V4 input-slice processing — called from bbPlayer.IGPlus_V4ProcessWeaponInputSlice.
// Returns true to suppress legacy fire, even if no shot is produced.
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
		// Primary is capped at 0.5: legacy IG+ NormalFire ran a 0.5s fallback
		// timer that always beat the 0.71s Fire1 anim, so 0.5 is the old feel.
		if (bAlt)
			BP.IGPlus_V4NoteShot(StepTS, 0.52);
		else
			BP.IGPlus_V4NoteShot(StepTS, 0.50);
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
	if (bRapidFire || (FiringSpeed > 0))
		BP.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();
	BP.ClientInstantFlash(-0.4, vect(450, 190, 650));

	if (bAlt) {
		PlayAltFiring();
		if (BP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations)
			ClientSpawnAltProjectileEffects(true, StepView, StepLoc);
	} else {
		PlayFiring();
		if (BP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations)
			ClientTraceFire(true, StepView, StepLoc);
	}
}

function HandleV4ServerFire(bool bAlt, rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	AmmoType.UseAmmo(1);

	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();

	// A mid-switch shot (in-flight allowance) must not play fire anims: they
	// hijack DownWeapon's AnimEnd and restart the holster server-side only
	// (the client's ClientDown tween is unaffected by its own shot).
	if (bAlt) {
		if (!bChangeWeapon && !IsInState('DownWeapon'))
			PlayAltFiring();
		DeterministicProjectileFire(AltProjectileClass, StepLoc, StepView);
	} else {
		if (!bChangeWeapon && !IsInState('DownWeapon'))
			PlayFiring();
		DeterministicTraceFire(0.0, StepView, StepLoc);
	}
}

function Projectile DeterministicProjectileFire(class<projectile> ProjClass, vector ShotLoc, rotator ShotRot) {
	local vector Start, X, Y, Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);

	GetAxes(ShotRot, X, Y, Z);
	Start = ShotLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = ShotRot;
	return Spawn(ProjClass, , , Start, AdjustedAim);
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

simulated function bool ClientFire(float Value) {
	local Pawn PawnOwner;
	local bbPlayer bbP;
	local TournamentPlayer TP;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	
	if (PawnOwner == None) 
		return false;
	TP = TournamentPlayer(PawnOwner);
	if (bChangeWeapon
		|| (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		|| (TP != none && TP.ClientPending != none && TP.ClientPending != self))
		return false;

	bbP = bbPlayer(PawnOwner);

	if (IsPingCompEnabled() && Owner.Role == ROLE_AutonomousProxy && bbP != None) {
		if (IsV4Active()) {
			return true;
		}

		if (!Super.ClientFire(Value))
			return false;

		if (bbP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations)
			ClientTraceFire();
		return true;
	}
	
	return Super.ClientFire(Value);
}

// Client-side shock beam tracing and effect spawning
simulated function ClientTraceFire(
	optional bool bUseShotData,
	optional rotator ShotView,
	optional vector ShotLoc
) {
    local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
    local actor Other;
    local Pawn PawnOwner;
    local vector SmokeLocation;
	local bbPlayer bbP;
	local rotator AimRot;
	local vector AimLoc;

    PawnOwner = Pawn(Owner);
	
    if (PawnOwner == None)
        return;

	bbP = bbPlayer(PawnOwner);

	if (IsPingCompEnabled() == false || bbP == None || bbP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations == false)
     	return;

	yModInit();

	if (bUseShotData) {
		AimRot = ShotView;
		AimLoc = ShotLoc;
	} else {
		AimRot = PawnOwner.ViewRotation;
		AimLoc = Owner.Location;
	}

	GetAxes(AimRot, X, Y, Z);

	StartTrace = AimLoc + CDO + yMod * Y + FireOffset.Z * Z;

	EndTrace = StartTrace + (10000 * X);
	
	SmokeLocation = AimLoc + CDO + (FireOffset.X + 20) * X + yMod * Y + FireOffset.Z * Z;

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
	local TournamentPlayer TP;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	
	if (PawnOwner == None)
		return false;
	TP = TournamentPlayer(PawnOwner);
	if (bChangeWeapon
		|| (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		|| (TP != none && TP.ClientPending != none && TP.ClientPending != self))
		return false;

	bbP = bbPlayer(PawnOwner);

	if (IsPingCompEnabled() && Owner.Role == ROLE_AutonomousProxy && bbP != None) {
		if (IsV4Active()) {
			return true;
		}

		if (!Super.ClientAltFire(Value))
			return false;

		if (bbP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations)
			ClientSpawnAltProjectileEffects();
		return true;
	}
	
	return Super.ClientAltFire(Value); 
}

simulated function ClientSpawnAltProjectileEffects(
	optional bool bUseShotData,
	optional rotator ShotView,
	optional vector ShotLoc
) {
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;
	local bbPlayer bbP;
	local rotator AimRot;
	local vector AimLoc;

	PawnOwner = Pawn(Owner);

	bbP = bbPlayer(PawnOwner);

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

	LocalDummy = ST_ShockProj(Spawn(AltProjectileClass,,, Start, AimRot));
	if (LocalDummy != None) {
		LocalDummy.RemoteRole = ROLE_None;
		LocalDummy.Instigator = PawnOwner;
		LocalDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
		LocalDummy.bCollideWorld = false;
		LocalDummy.SetCollision(false, false, false);
	}
}

function TraceFire(float Accuracy) {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	if (Role == ROLE_Authority
		&& Level.NetMode != NM_Client
		&& IsV4Active())
		return;

	TraceFireAt(Accuracy, PawnOwner.ViewRotation, Owner.Location, CalcDrawOffset());
}

function DeterministicTraceFire(float Accuracy, rotator ShotRot, vector ShotLoc) {
	local Pawn PawnOwner;
	local vector DrawOffsetLoc;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	DrawOffsetLoc = PawnOwner.BaseEyeHeight * vect(0,0,1) + ((0.01 * PlayerViewOffset) >> ShotRot);
	TraceFireAt(Accuracy, ShotRot, ShotLoc, DrawOffsetLoc);
}

function TraceFireAt(float Accuracy, rotator AimRot, vector AimLoc, vector DrawOffsetLoc) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;
	local vector SmokeLocation;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	Owner.MakeNoise(PawnOwner.SoundDampening);

	GetAxes(AimRot,X,Y,Z);
	StartTrace = AimLoc + DrawOffsetLoc + FireOffset.Y * Y + FireOffset.Z * Z; 
	SmokeLocation = AimLoc + DrawOffsetLoc + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z;

	EndTrace = StartTrace + (Accuracy * (FRand() - 0.5 )* Y * 1000) + (Accuracy * (FRand() - 0.5 ) * Z * 1000);

	if (bBotSpecialMove && (Tracked != None) && (
			((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
			(Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)
		)
	) {
		EndTrace += 10000 * Normal(Tracked.Location - StartTrace);
	} else {
		// Keep bot/legacy auto-aim only when ping comp deterministic view is not in effect.
		if (!(IsPingCompEnabled() && PlayerPawn(Owner) != None))
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
		
	PendingSmokeLocation = SmokeLocation;
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
		
	if (PendingSmokeLocation == vect(0,0,0))
		PendingSmokeLocation = Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z;

	// Server-side beam spawning
	SpawnEffect(HitLocation, PendingSmokeLocation);
	PendingSmokeLocation = vect(0,0,0);

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
	local bbPlayer bbP;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if (NumPoints < 1) {
		return;
	}
		
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	bbP = bbPlayer(Owner);

	if (IsPingCompEnabled() && bbP != None && bbP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations) {

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

function bool PutDown()
{
	local bbPlayer BP;

	BP = bbPlayer(Owner);
	if (BP != none)
		BP.IGPlus_MarkDeterministicSwitchGuard();

	bCanClientFire = false;
	return Super.PutDown();
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
	bCanClientFire = false;

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

// Bounce pending switches to DownWeapon before the inherited Idle label
// clobbers a manual weapon choice.
state Idle
{
	function BeginState()
	{
		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
		{
			GotoState('DownWeapon');
			return;
		}
		Super.BeginState();
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
		if (IsV4Active()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}

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
		if (IsV4Active()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}

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

function Fire(float Value)
{
	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.Fire(Value);
}

function AltFire(float Value)
{
	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.AltFire(Value);
}

defaultproperties {
	AltProjectileClass=Class'ST_ShockProj'
}
