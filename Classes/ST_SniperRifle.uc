// ===============================================================
// Stats.ST_SniperRifle: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_SniperRifle extends SniperRifle;

var IGPlus_WeaponImplementation WImp;

enum EZoomState {
	ZS_None,
	ZS_Zooming,
	ZS_Zoomed,
	ZS_Reset
};
var EZoomState ZoomState;

var WeaponSettingsRepl WSettings;

// Variables for client-side animations
var Rotator GV;
var float yMod; // For handedness calculations

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

// The legacy path refires at fire-anim end, and SniperReloadAnimSpeed scales
// the anim so its duration equals the configured SniperReloadTime (stock 2/3s).
simulated function float PrimaryShotInterval() {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	if (WS == none)
		return class'WeaponSettingsRepl'.default.SniperReloadTime;
	return FClamp(WS.SniperReloadTime, 0.05, 2.0);
}

// V4 input-slice processing — called from bbPlayer.IGPlus_V4ProcessWeaponInputSlice.
// Returns true to suppress legacy fire, even if no shot is produced.
// Alt-fire is client-side zoom and must never produce a shot.
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
	local bbPlayer BP;
	local int FireMode;
	local float Interval;

	if (!bClientPredictedStep)
		return true;

	BP = bbPlayer(Owner);
	if (BP == none)
		return true;
	FireMode = BP.IGPlus_V4IntervalShotDue(
		StepTS, bFireHeld, false, bForceFire, false,
		PrimaryShotInterval(), PrimaryShotInterval(), NextV4FireTS, Interval);
	if (FireMode == 0)
		return true;

	if (AmmoType != none && AmmoType.AmmoAmount > 0) {
		// Holster hold equals the reload anim, whose duration is the interval.
		BP.IGPlus_V4NoteShot(StepTS, Interval);
		if (bServerSide)
			HandleV4ServerFire(StepView, StepLoc);
		else
			HandleV4ClientFire(StepView, StepLoc);
	} else if (bServerSide) {
		BP.IGPlus_V4HandleOutOfAmmo(self);
	}

	NextV4FireTS = StepTS + Interval;
	return true;
}

simulated function HandleV4ClientFire(rotator StepView, vector StepLoc) {
	local bbPlayer BP;
	local PlayerPawn P;
	local vector X, Y, Z;

	BP = bbPlayer(Owner);
	P = PlayerPawn(Owner);

	Instigator = Pawn(Owner);
	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		BP.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();

	PlayFiring();

	if (P != none && BP.ClientWeaponSettingsData.bSniperUseClientSideAnimations) {
		yModInit();
		GetAxes(GV, X, Y, Z);
		DoClientShellCase(P, Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * yMod + 5.0) * Y - Z * 1, X, Y, Z);
	}
}

function HandleV4ServerFire(rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	AmmoType.UseAmmo(1);

	Instigator = PawnOwner; // ProcessTraceHit's headshot check reads Instigator
	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();

	PlayFiring();
	DeterministicTraceFire(StepView, StepLoc);
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;		// Find master :D
}

simulated function yModInit()
{
	if (bbPlayer(Owner) != None && Owner.Role == ROLE_AutonomousProxy)
		GV = bbPlayer(Owner).ViewRotation;

	if (PlayerPawn(Owner) == None)
		return;

	yMod = PlayerPawn(Owner).Handedness;
	if (yMod != 2.0)
		yMod *= Default.FireOffset.Y;
	else
		yMod = 0;
}

simulated function DoClientShellCase(PlayerPawn Pwner, vector HitLoc, Vector X, Vector Y, Vector Z)
{
	local UT_ShellCase s;

	if (Level.NetMode == NM_Client || Level.NetMode == NM_Standalone) {
		s = Spawn(class'UT_ShellCase', Pwner,, HitLoc);
		if (s != None) 
		{
			s.DrawScale = 2.0;
			s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
			s.RemoteRole = ROLE_None;
		}
	}
}

simulated function bool ClientFire(float Value)
{
	local bbPlayer bbP;
	local TournamentPlayer TP;

	if (!bCanClientFire)
		return false;

	if (Owner.IsA('Bot'))
		return Super.ClientFire(Value);

	TP = TournamentPlayer(Owner);
	if (bChangeWeapon
		|| (Pawn(Owner) != none && Pawn(Owner).PendingWeapon != none && Pawn(Owner).PendingWeapon != self)
		|| (TP != none && TP.ClientPending != none && TP.ClientPending != self))
		return false;

	bbP = bbPlayer(Owner);

	// Under V4 the predicted input slices drive fire anims; nothing to do here.
	if (IsV4Active() && Owner.Role == ROLE_AutonomousProxy && bbP != None)
		return true;

	if (bbP != None && GetWeaponSettings().bEnablePingCompensation)
	{
		if (Role < ROLE_Authority && bbP.ClientWeaponSettingsData.bSniperUseClientSideAnimations)
		{
			if (bbP.ClientCannotShoot() || bbP.Weapon != Self) {
					return false;
			}
			
			if ((AmmoType == None) && (AmmoName != None))
			{
				// ammocheck
				GiveAmmo(Pawn(Owner));
			}
			
			if (AmmoType.AmmoAmount > 0)
			{
				Instigator = Pawn(Owner);
				GotoState('ClientFiring');
				bPointing = True;
				if (bRapidFire || (FiringSpeed > 0))
					Pawn(Owner).PlayRecoil(FiringSpeed);
				
				ClientPlayEffects();
			}
		}
	}
	
	return Super.ClientFire(Value);
}

simulated function ClientPlayEffects()
{
	local vector X, Y, Z;
	local PlayerPawn P;

	P = PlayerPawn(Owner);
	if (P == None)
		return;
	
	yModInit();
	GetAxes(GV, X, Y, Z);
	
	DoClientShellCase(P, Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * yMod + 5.0) * Y - Z * 1, X, Y, Z);
	
	PlayAnim(FireAnims[Rand(5)], GetWeaponSettings().SniperReloadAnimSpeed(), 0.05);
	
	if (P.DesiredFOV == P.DefaultFOV)
		bMuzzleFlash++;
}

function TraceFire(float Accuracy) {
	if (Role == ROLE_Authority && Level.NetMode != NM_Client && IsV4Active())
		return;
	TraceFireAt(Pawn(Owner).ViewRotation, Owner.Location, true);
}

function DeterministicTraceFire(rotator ShotRot, vector ShotLoc) {
	TraceFireAt(ShotRot, ShotLoc, false);
}

function TraceFireAt(rotator AimRot, vector BaseLoc, bool bUseAdjustAim) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;
	local float RewindMs;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(AimRot,X,Y,Z);
	StartTrace = BaseLoc + PawnOwner.Eyeheight * vect(0,0,1);
	if (WImp != None && WImp.WeaponSettings.bEnablePingCompensation)
	{
		RewindMs = WImp.IGPlus_GetHitscanRewindMs(PawnOwner);
		StartTrace = WImp.IGPlus_AdjustLocationToHistoricalMoverFrame(PawnOwner, StartTrace, RewindMs);
	}
	if (bUseAdjustAim)
		AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2*AimError, False, False);
	else
		AdjustedAim = AimRot;
	X = vector(AdjustedAim);
	EndTrace = StartTrace + 100000 * X;
	if (WImp.WeaponSettings.SniperUseReducedHitbox)
		Other = WImp.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner);
	else
		Other = PawnOwner.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local UT_Shellcase s;
	local Pawn PawnOwner;
	local vector Momentum;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);

	bbP = bbPlayer(PawnOwner);
	
	// Only spawn shell case on server if compensation is disabled and if player
	if (bbP != None)
	{
		if(WImp.WeaponSettings.bEnablePingCompensation && bbP.ClientWeaponSettingsData.bSniperUseClientSideAnimations) {
			s = Spawn(class'ST_UT_ShellCaseOwnerHidden',Owner, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);

			s.RemoteRole = ROLE_None;

			if (s != None) {
				s.DrawScale = 2.0;
				s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
			}
		}
	}
	else {
		s = Spawn(class'UT_ShellCase',, '', Owner.Location + CalcDrawOffset() + 30 * X + (2.8 * FireOffset.Y+5.0) * Y - Z * 1);

		if (s != None) {
			s.DrawScale = 2.0;
			s.Eject(((FRand()*0.3+0.4)*X + (FRand()*0.2+0.2)*Y + (FRand()*0.3+1.0) * Z)*160);
		}
	}

	// Wall hit effects - always spawn on server for Level and Mover hits
	if (Other == Level) {
		Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	} else if ((Other != self) && (Other != Owner) && (Other != None)) {
		if (Other.IsA('Mover')) {
			Spawn(class'UT_HeavyWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
		}

		// Headshot handling
		if (Other.bIsPawn && CheckHeadShot(Pawn(Other), HitLocation, X) &&
			(instigator.IsA('PlayerPawn') || (instigator.IsA('Bot') && !Bot(Instigator).bNovice))
		) {
			Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
			Other.TakeDamage(
				WImp.WeaponSettings.SniperHeadshotDamage,
				PawnOwner,
				HitLocation,
				WImp.WeaponSettings.SniperHeadshotMomentum * 35000 * X,
				AltDamageType);
		} else {
			// Regular hit handling
			if (Other.bIsPawn) {
				Other.PlaySound(Sound 'ChunkHit',, 4.0,,100);
				Momentum = WImp.WeaponSettings.SniperMomentum * 30000.0*X;
				
				// Always spawn hit effects on players on the server
				Spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
			} else {
				Momentum = 30000.0*X;
				if (Other.IsA('Carcass') == false)
					Spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
			}

			Other.TakeDamage(
				WImp.WeaponSettings.SniperDamage,
				PawnOwner,
				HitLocation,
				Momentum,
				MyDamageType);
		}
	}
}

function bool CheckHeadShot(Pawn P, vector HitLocation, vector BulletDir) {
    local UTPlusDummy Dummy;
    local bbPlayer bbP;
    local vector Loc;

    Loc = P.Location;
	
    if (WImp.WeaponSettings.bEnablePingCompensation) {
        bbP = bbPlayer(Owner);
        if (bbP != none)
            Dummy = bbP.zzUTPure.FindDummy(P);
        if (Dummy != none)
            Loc = Dummy.Location;
    }

    if (WImp.WeaponSettings.SniperUseReducedHitbox == false)
        return (HitLocation.Z - Loc.Z > 0.62 * P.CollisionHeight);

	if (WImp.WeaponSettings.bEnablePingCompensation)
		return WImp.CheckHeadShotCompensated(Dummy, HitLocation, BulletDir);

    return WImp.CheckHeadShot(P, HitLocation, BulletDir);
}

function Fire(float Value) {
	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.Fire(Value);
}

function AltFire(float Value) {
	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.AltFire(Value);
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
		carried = 'SniperRifle';
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

simulated function PlayFiring() {

	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*3.0);
	PlayAnim(FireAnims[Rand(5)], GetWeaponSettings().SniperReloadAnimSpeed(), 0.05);

	if ((PlayerPawn(Owner) != None) && 
		(PlayerPawn(Owner).DesiredFOV == PlayerPawn(Owner).DefaultFOV)) {
		// If compensation is enabled, only show muzzle flash on client side
		if (!bbPlayer(Owner).ClientWeaponSettingsData.bSniperUseClientSideAnimations || 
			(Level.NetMode == NM_Standalone) || 
			(PlayerPawn(Owner).RemoteRole != ROLE_AutonomousProxy)) {
			bMuzzleFlash++;
		}
	}
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().SniperSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	bCanClientFire = false;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().SniperDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().SniperDownAnimSpeed(), TweenTime);

	if (Owner.IsA('PlayerPawn') && PlayerPawn(Owner).Player.IsA('ViewPort')) {
		ZoomState = ZS_None;
		PlayerPawn(Owner).EndZoom();
	}
}

simulated function bool ClientAltFire(float Value) {
	if (Owner.IsA('PlayerPawn') == false) {
		Pawn(Owner).bFire = 1;
		Pawn(Owner).bAltFire = 0;
		Global.Fire(0);
	} else {
		GotoState('Idle');
	}

	return true;
}

simulated function Tick(float DeltaTime) {
	local PlayerPawn P;

	P = PlayerPawn(Owner);
	if (P != none &&
		P.Weapon == self &&
		bCanClientFire
	) {
		switch (ZoomState) {
		case ZS_None:
			if (P.bAltFire != 0) {
				if (P.Player.IsA('ViewPort'))
					P.StartZoom();
				SetTimer(0.2, true);
				ZoomState = ZS_Zooming;
			}
			break;
		case ZS_Zooming:
			if (P.bAltFire == 0) {
				if (P.Player.IsA('ViewPort'))
					P.StopZoom();
				ZoomState = ZS_Zoomed;
			}
			break;
		case ZS_Zoomed:
			if (P.bAltFire != 0) {
				if (P.Player.IsA('ViewPort'))
					P.EndZoom();
				SetTimer(0.0, false);
				ZoomState = ZS_Reset;
			}
			break;
		case ZS_Reset:
			if (P.bAltFire == 0) {
				ZoomState = ZS_None;
			}
			break;
		}
	}
}

// Add state for client-side firing
state ClientFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function AnimEnd() {
		if (IsV4Active()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}

		if ((Pawn(Owner) == None) || ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))) {
			PlayIdleAnim();
			GotoState('');
		}
		else if (!bCanClientFire) {
			GotoState('');
		}
		else if (Pawn(Owner).bFire != 0) {
			Global.ClientFire(0);
		}
		else {
			PlayIdleAnim();
			GotoState('');
		}
	}
}

// Client-active state to handle client-side firing
state ClientActive
{
	// Check if client can fire
	simulated function bool ClientFire(float Value)
	{
		if (Owner.IsA('Bot'))
			return Super.ClientFire(Value);
		bForceFire = bbPlayer(Owner) == None || !bbPlayer(Owner).ClientCannotShoot();
		return bForceFire;
	}

	// Check if client can alt-fire (for zoom functionality)
	simulated function bool ClientAltFire(float Value)
	{
		if (Owner.IsA('Bot'))
			return Super.ClientAltFire(Value);
		bForceAltFire = bbPlayer(Owner) == None || !bbPlayer(Owner).ClientCannotShoot();
		return bForceAltFire;
	}

	// Handle animation end in client active state
	simulated function AnimEnd()
	{
		bCanClientFire = true;

		if (Owner == None) {
			Global.AnimEnd();
			GotoState('');
		}
		else if (Owner.IsA('TournamentPlayer')
			&& (TournamentPlayer(Owner).PendingWeapon != None || TournamentPlayer(Owner).ClientPending != None)) {
			GotoState('ClientDown');
		}
		else if (bWeaponUp) {
			if ((bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(1))
				return;
			else if ((bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(1))
				return;
			PlayIdleAnim();
			GotoState('');
		}
		else {
			PlayPostSelect();
			bWeaponUp = true;
		}
	}
}

defaultproperties {
}
