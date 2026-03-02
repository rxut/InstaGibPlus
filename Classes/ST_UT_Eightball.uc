// ===============================================================
// Stats.ST_UT_Eightball: put your comment here
//
// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_UT_Eightball extends UT_Eightball;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

// Server-side deterministic fire data (from ServerMove_v4 step)
var vector V4ServerFireLoc;
var rotator V4ServerFireRot;
var bool bUseV4ServerFireData;

const V4_PHASELOCK_MAX_OVERSHOOT = 0.060;

// Rate limiting to prevent rapid fire exploits
var float LastClientFireTime;
const FIRE_RATE_LIMIT = 0.25;


// V4 deterministic fire
var float NextV4FireTS;
var float V4LoadStartTS;
var bool bV4WasFireHeld;
var int V4CachedChargeData;
var float NextClientFireTS;

// Client-side offset correction
var float yMod;
var vector CDO;

simulated function V4Log(coerce string S) {
	if (!V4ShouldDebug())
		return;
	Log("[EB]"@S);
}

simulated function bool V4ShouldDebug() {
	local bbPlayer bbP;
	bbP = bbPlayer(Owner);
	return bbP != none && bbP.bTraceInput;
}

replication
{
	unreliable if(Role < ROLE_Authority)
		ServerStartedLoading, ServerPlayLoadSound;
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
	return WS != None && WS.RocketCompensatePing;
}

simulated function bool IsV4Active() {
	if (!IsPingCompEnabled())
		return false;
	if (bbPlayer(Owner) == none)
		return false;
	return true;
}

simulated function bool UsesServerMoveV4() {
	local bbPlayer P;

	P = bbPlayer(Owner);
	if (P == none)
		return false;
	return !P.IGPlus_EnableInputReplication && int(Level.ServerMoveVersion) >= 4;
}

// Mark a deterministic fire pulse exactly when a client-side shot is executed.
// This keeps ServerMove_v4 fire events tied to real shot time instead of
// animation/input transitions that may not actually fire.
simulated function V4MarkClientShot(bool bAlt) {
	local bbPlayer P;

	if (Role == ROLE_Authority || !IsV4Active() || !UsesServerMoveV4())
		return;

	P = bbPlayer(Owner);
	if (P == none)
		return;

	V4Log("[CLI] ShotPulse alt="$bAlt$" Time="$Level.TimeSeconds$" State="$GetStateName());

	if (bAlt)
		P.bJustAltFired = true;
	else
		P.bJustFired = true;
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

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;
}

// =========================================================================
// V4 Deterministic Fire — Primary (Rockets) Only
// =========================================================================

// Charge weapon pattern: server tracks bFireHeld rising/falling edges.
// Rising edge → start loading (stop lock‑on timer).
// Falling edge → fire rockets using V4ChargeData count.
// bInstantRocket → fire immediately on rising edge.
// Alt fire (grenades) returns false to let legacy move-event handling run.

// Post-fire cooldown matching the client's animation-driven cycle:
// PlayRFiring tween (0.05s) + fire anim + PlayLoading tween (0.05s) + Load1 reload.
//
// From execPlayAnim: AnimEnd fires at AnimLast = 1.0 - 1.0/NumFrames.
// Play duration = (NumFrames - 1) / (PlayAnimRate * Seq->Rate).
// Tween duration = TweenTime (always exactly, per engine source).
//
// Fire frame counts from FireAnim[] → MESH SEQUENCE declarations:
//   [0]=Fire1(8f), [1]=Fire2(11f), [2]=Fire3(10f), [3]=Fire4(11f), [4]=Fire2(11f), [5]=Fire3(10f)
//   All Fire anims: default Rate=30 (no RATE in MESH SEQUENCE).
//   PlayRFiring TweenTime=0.05, PlayRate=0.54 (instant) / 0.6 (normal).
//
// Load1 reload: 7 frames, RATE=15, PlayAnimRate=1.0, TweenTime=0.05.
//   Play duration = (7-1)/15 = 0.4s.  Total = 0.05 + 0.4 = 0.45s.
simulated function float V4PostFireInterval(int NumRockets) {
	local float FireFrames;
	local float FirePlayRate;

	if (NumRockets == 1) FireFrames = 8;
	else if (NumRockets == 3 || NumRockets == 6) FireFrames = 10;
	else FireFrames = 11; // 2, 4, 5 rockets

	if (bInstantRocket)
		FirePlayRate = 0.54;
	else
		FirePlayRate = 0.6;

	// fire tween + fire play + load tween + load play
	return 0.05 + (FireFrames - 1) / (30.0 * FirePlayRate) + 0.05 + 6.0 / 15.0;
}

// Keep cadence only when overshoot is tiny (sub-step/frame jitter).
// Larger overshoots are real delays and must reset cooldown from fire time.
simulated function float V4AdvanceCooldown(float PrevNextTS, float FireTS, float Interval) {
	local float Overshoot;

	if (PrevNextTS > 0) {
		Overshoot = FireTS - PrevNextTS;
		if (Overshoot >= -0.001 && Overshoot <= V4_PHASELOCK_MAX_OVERSHOOT) {
			if (V4ShouldDebug())
				V4Log("[DBG] Cooldown anchor prev="$PrevNextTS$" fire="$FireTS$" over="$Overshoot$" next="$(PrevNextTS + Interval));
			return PrevNextTS + Interval;
		}
	}
	if (V4ShouldDebug())
		V4Log("[DBG] Cooldown reset prev="$PrevNextTS$" fire="$FireTS$" over="$(FireTS - PrevNextTS)$" next="$(FireTS + Interval));
	return FireTS + Interval;
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
	local bool bWantsFire;
	local int NumRockets;

	if (!bStepReadyHint && !IsDeterministicReady())
		return true;

	// Client state machine (ClientFiring) handles all client-side fire
	// visuals and animation timing. V4 only controls server-side fire.
	// Running V4 on both sides causes timestamp divergence because the
	// server fires at sub-step granularity while the client fires at
	// move-end granularity, compounding a ~22ms drift per fire cycle.
	if (!bServerSide)
		return true;

	if (TournamentPlayer(Owner) != none)
		bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

	bWantsFire = bFireHeld || bForceFire;

	// Alt-only fire (not during a rocket loading sequence) → legacy move-event path
	if (!bWantsFire && !bV4WasFireHeld && (bAltHeld || bForceAlt))
		return false;

	// Rate limit: prevent re-fire during cooldown.
	// Don't log here — this fires on every sub-step while the player
	// holds fire during cooldown, producing 80-100 Log() calls per
	// cycle and causing server-side I/O stalls (movement rubber-banding).
	if (bWantsFire && !bV4WasFireHeld && StepTS + 0.0001 < NextV4FireTS)
		return true;

	// Client emits bForceFire exactly when rockets are actually fired
	// (FiringRockets). Consume that pulse directly for non-instant mode so
	// server fire time doesn't depend on receiving a later falling-edge move.
	if (!bInstantRocket && bForceFire && !bFireHeld)
	{
		if (StepTS + 0.0001 < NextV4FireTS)
			return true;

		NumRockets = Clamp(V4ChargeData, 1, 6);
		if (AmmoType != none && AmmoType.AmmoAmount > 0) {
			NumRockets = Min(NumRockets, AmmoType.AmmoAmount);
			V4Log("[SRV] ForcePulse FIRE StepTS="$StepTS$" V4Charge="$V4ChargeData$" rockets="$NumRockets$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw);
			HandleV4ServerFire(Pawn(Owner).ViewRotation, StepLoc, NumRockets, bAltHeld);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			V4Log("[SRV] NextV4FireTS set to "$NextV4FireTS$" (interval="$V4PostFireInterval(NumRockets)$")");
		} else {
			V4Log("[SRV] ForcePulse NO AMMO StepTS="$StepTS);
			V4HandleOutOfAmmo();
		}
		bV4WasFireHeld = false;
		return true;
	}

	// Rising edge: fire button pressed
	if (bWantsFire && !bV4WasFireHeld) {
		if (bInstantRocket) {
			// Instant mode: fire 1 rocket immediately
			V4Log("[SRV] Rising INSTANT fire StepTS="$StepTS$" View="$StepView.Pitch$","$StepView.Yaw$" NextV4Fire="$NextV4FireTS$" Ammo="$AmmoType.AmmoAmount);
			if (AmmoType != none && AmmoType.AmmoAmount > 0)
				HandleV4ServerFire(StepView, StepLoc, 1, bAltHeld);
			else
				V4HandleOutOfAmmo();
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(1));
			V4Log("[SRV] NextV4FireTS set to "$NextV4FireTS$" (interval="$V4PostFireInterval(1)$")");
		} else {
			// Normal mode: stop acquiring new lock-on targets, record load start.
			// NextV4FireTS is set at the falling edge (when rockets fire), not
			// here, so it uses the actual rocket count for the interval and
			// anchors at the same point as the client's FiringRockets().
			V4Log("[SRV] Rising LOAD start StepTS="$StepTS$" V4Charge="$V4ChargeData);
			SetTimer(0, false);
			V4LoadStartTS = StepTS;
		}
		bV4WasFireHeld = true;
		return true;
	}

	// Held fire: re-fire at intervals for instant rockets
	if (bWantsFire && bV4WasFireHeld && bInstantRocket) {
		if (StepTS + 0.0001 < NextV4FireTS)
			return true;
		V4Log("[SRV] Held INSTANT fire StepTS="$StepTS$" View="$StepView.Pitch$","$StepView.Yaw$" Ammo="$AmmoType.AmmoAmount);
		if (AmmoType != none && AmmoType.AmmoAmount > 0)
			HandleV4ServerFire(StepView, StepLoc, 1, bAltHeld);
		else
			V4HandleOutOfAmmo();
		NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(1));
		V4Log("[SRV] NextV4FireTS set to "$NextV4FireTS);
		return true;
	}

	// Held fire: non-instant, auto-fire when max rockets loaded.
	// Client auto-fires via AnimEnd when ClientRocketsLoaded==6 even
	// while fire is still held, so the server must also fire when
	// V4ChargeData signals a full load.
	// Timestamp guard: loading 6 rockets takes ~4.4s on the client
	// (9 rotate/load anims at 0.45s each + Load6 at 0.38s).
	// Require at least 3.0s since the rising edge to reject stale
	// V4ChargeData left over from a previous fire cycle.
	if (bWantsFire && bV4WasFireHeld && !bInstantRocket
		&& V4ChargeData >= 6 && (StepTS - V4LoadStartTS) > 3.0) {
		NumRockets = 6;
		if (AmmoType != none)
			NumRockets = Min(6, AmmoType.AmmoAmount);
		V4Log("[SRV] Auto-fire 6pack StepTS="$StepTS$" V4Charge="$V4ChargeData$" LoadStart="$V4LoadStartTS$" elapsed="$(StepTS - V4LoadStartTS)$" rockets="$NumRockets);
		if (NumRockets > 0)
			HandleV4ServerFire(StepView, StepLoc, NumRockets, bAltHeld);
		else
			V4HandleOutOfAmmo();
		bV4WasFireHeld = false;
		NextV4FireTS = StepTS + V4PostFireInterval(NumRockets);
		return true;
	}

	// Falling edge: fire button released → fire loaded rockets
	if (!bWantsFire && bV4WasFireHeld) {
		bV4WasFireHeld = false;
		// Instant mode already fired on press
		if (bInstantRocket) {
			V4Log("[SRV] Falling edge INSTANT (skip) StepTS="$StepTS);
			return true;
		}

		NumRockets = Clamp(V4ChargeData, 1, 6);
		if (AmmoType != none && AmmoType.AmmoAmount > 0) {
			NumRockets = Min(NumRockets, AmmoType.AmmoAmount);
			// Use the move's end-of-frame ViewRotation instead of the
			// interpolated sub-step view.  The falling edge fires at
			// the first sub-step (T=0 → ViewStart = previous move's
			// end view), but the client fires at Tick time using the
			// current frame's ViewRotation (≈ move's end view).
			// Pawn.ViewRotation is set to SM.View before sub-step
			// processing, so it matches the client's fire-time view.
			V4Log("[SRV] Falling edge FIRE StepTS="$StepTS$" V4Charge="$V4ChargeData$" rockets="$NumRockets$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw$" StepV="$StepView.Pitch$","$StepView.Yaw);
			HandleV4ServerFire(Pawn(Owner).ViewRotation, StepLoc, NumRockets, bAltHeld);
			// Set cooldown using the actual rocket count. This matches
			// the client's FiringRockets(ClientRocketsLoaded) interval.
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			V4Log("[SRV] NextV4FireTS set to "$NextV4FireTS$" (interval="$V4PostFireInterval(NumRockets)$")");
		} else {
			V4Log("[SRV] Falling edge NO AMMO StepTS="$StepTS);
			V4HandleOutOfAmmo();
		}
		return true;
	}

	// Held or idle — no action
	return true;
}

// Spawn rockets on the server using the deterministic data path in FireRockets.BeginState.
function HandleV4ServerFire(rotator StepView, vector StepLoc, int NumRockets, bool bTight) {
	local PlayerPawn P;

	P = PlayerPawn(Owner);
	if (P == none)
		return;

	V4Log("[SRV] HandleV4ServerFire rockets="$NumRockets$" tight="$bTight$" View="$StepView.Pitch$","$StepView.Yaw$" Loc="$int(StepLoc.X)$","$int(StepLoc.Y)$","$int(StepLoc.Z));

	// Feed FireRockets.BeginState with deterministic step loc/view.
	V4ServerFireLoc = StepLoc;
	if (bbPlayer(Owner) != none)
		V4ServerFireLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	V4ServerFireRot = StepView;
	bUseV4ServerFireData = true;

	if (AmmoType == none)
		GiveAmmo(P);
	if (AmmoType != none) {
		if (AmmoType.AmmoAmount < NumRockets)
			NumRockets = AmmoType.AmmoAmount;
		AmmoType.UseAmmo(NumRockets);
	}

	RocketsLoaded = NumRockets;
	bFireLoad = true;
	bTightWad = bTight;

	if (TournamentPlayer(P) != none)
		bInstantRocket = TournamentPlayer(P).bInstantRocket;

	bCanClientFire = true;
	bPointing = true;

	if (NumRockets > 0) {
		if (P.PendingWeapon != none && P.PendingWeapon != self) {
			P.PlayRecoil(FiringSpeed);
			bChangeWeapon = true;
		}
		GoToState('FireRockets');
	}
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

// Called by client when loading starts to stop server lock-on checks
function ServerStartedLoading()
{
	// Only stop the timer to prevent acquiring NEW locks
	// Don't clear existing lock - player may have locked before pressing fire
	SetTimer(0, false);
}

// Called by client to play loading sounds on server so other players can hear
function ServerPlayLoadSound(int RocketNum, bool bIsRotate)
{
	if (Owner == None || Pawn(Owner) == None)
		return;
		
	if (bIsRotate)
		Owner.PlaySound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
	else
		Owner.PlaySound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
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
	// V4 handles primary fire (rockets) on server via deterministic step processing.
	// Client still needs standard Fire logic to set bCanClientFire and enter ClientFiring.
	if (Role == ROLE_Authority && IsV4Active() && UsesServerMoveV4())
		return;
		
	Super.Fire(Value);
}

function AltFire( float Value )
{
	Super.AltFire(Value);
}

simulated function bool ClientFire( float Value )
{
	local Pawn PawnOwner;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	// if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
	//	return false;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		// Update bInstantRocket from owner on client to ensure correct firing mode
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
			// Client-side rate limiting
			if (Level.TimeSeconds - LastClientFireTime < FIRE_RATE_LIMIT)
				return false;

			LastClientFireTime = Level.TimeSeconds;
			GotoState('ClientFiring');
			return true;
		}
	}
	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire( float Value )
{
	local Pawn PawnOwner;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	// if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
	//	return false;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		// Update bInstantRocket from owner on client to ensure correct firing mode
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
			// Client-side rate limiting
			if (Level.TimeSeconds - LastClientFireTime < FIRE_RATE_LIMIT)
				return false;

			LastClientFireTime = Level.TimeSeconds;
			GotoState('ClientAltFiring');
			return true;
		}
	}
	return Super.ClientAltFire(Value);
}

state ClientActive
{
	simulated function AnimEnd()
	{
		bCanClientFire = true;
		Super.AnimEnd();
	}
}

// Hook into the client-side release trigger
simulated function FiringRockets()
{
    local bbPlayer bbP;
    local bool bAlt;
    local float CInterval;
    
    // Determine fire mode based on current state
    if (IsInState('ClientAltFiring'))
        bAlt = true;
    else
        bAlt = false;

	if (Role < ROLE_Authority)
		V4Log("[CLI] FiringRockets: rockets="$ClientRocketsLoaded$" alt="$bAlt$" Time="$Level.TimeSeconds$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw);

	// Emit one fire pulse for movement serialization at the exact shot moment.
	V4MarkClientShot(bAlt);

    // Set client-side cooldown with self-correcting anchor.
    // This mirrors the server's NextV4FireTS logic so both sides
    // derive fire timing from the same deterministic cooldown chain
    // instead of the client relying on animation-boundary timing.
    if (Role < ROLE_Authority && IsV4Active()) {
        CInterval = V4PostFireInterval(ClientRocketsLoaded);
        NextClientFireTS = V4AdvanceCooldown(NextClientFireTS, Level.TimeSeconds, CInterval);
        V4Log("[CLI] NextClientFireTS="$NextClientFireTS$" (interval="$CInterval$")");
    }

    // Call super to handle animations and cleanup
    Super.FiringRockets();

	bbP = bbPlayer(Owner);
	if (Role < ROLE_Authority && bbP != None && IsPingCompEnabled())
	{
			// Spawn client-side visuals only for Primary Fire (Rockets)
			if (!bAlt && !bLockedOn && bbP.ClientWeaponSettingsData.bRocketUseClientSideAnimations)
			{
				SpawnClientSideRockets(ClientRocketsLoaded);
			}
	}
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

simulated function SpawnClientSideRockets(int NumRockets)
{
	local vector FireLocation, StartLoc, X,Y,Z;
	local rotator FireRot, AimRot;
	local ST_RocketMk2 r;
	local float Angle, RocketRad;
	local pawn PawnOwner;
	local float Spread;
	local int i;
	local bool bTightWad;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None) return;

	// Update offset calculations
	yModInit();

	// Calculate aim
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	
	// Use CDO and yMod for correct positioning (especially when hidden)
	StartLoc = Owner.Location + CDO + FireOffset.X * X + yMod * Y + FireOffset.Z * Z;
	if (bbPlayer(Owner) != None)
		StartLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	AimRot = PawnOwner.ViewRotation;

	Angle = 0;
	// Calculate bTightWad client-side
	if ( PawnOwner.bAltFire != 0 )
		bTightWad = true;
	
	if (bTightWad || NumRockets == 1) 
		RocketRad = 7;
	else
		RocketRad = 4;

	for (i = 0; i < NumRockets; i++)
	{
		Spread = (-0.5 * (NumRockets-1) + i);

		if (NumRockets == 1) {
			FireLocation = StartLoc;
		} else if (bTightWad) {
			FireLocation = StartLoc - (Sin(Angle)*RocketRad - 7.5)*Y + (Cos(Angle)*RocketRad - 7)*Z;
		} else {
			FireLocation = StartLoc + (Spread*4.0*Y);
		}
		
		if (bTightWad) {
			FireRot.Yaw = AimRot.Yaw;
		} else {
			FireRot.Yaw = AimRot.Yaw + Spread*WSettings.RocketSpreadSpacingDegrees*(65536.0/360.0);
		}
		FireRot.Pitch = AimRot.Pitch;
		FireRot.Roll = AimRot.Roll;

		r = Spawn(class'ST_RocketMk2', PawnOwner, '', FireLocation, FireRot);
		if (r != None)
		{
			r.Instigator = PawnOwner;
			r.WImp = WImp;
			r.NumExtraRockets = 0; 
			r.RemoteRole = ROLE_None;
			r.bClientVisualOnly = true;
			r.RocketIndex = i;
			r.bCollideWorld = true; 
			r.SetCollision(true, false, false);
			r.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
		}

		Angle += 1.04719755;
	}
}

///////////////////////////////////////////////////////
state FireRockets
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function bool SplashJump()
	{
		return false;
	}

	function BeginState()
	{
		local vector FireLocation, StartLoc, X,Y,Z;
		local rotator FireRot, RandRot;
		local ST_RocketMk2 r;
		local ST_UT_SeekingRocket s;
		local ST_UT_Grenade g;
		local float Angle, RocketRad;
		local pawn BestTarget, PawnOwner;
		local PlayerPawn PlayerOwner;
		local int DupRockets;
		local float Spread;
		local int i;
		local bbPlayer bbP;
			local Projectile SpawnedRockets[6];
			local int NumSpawnedRockets;
			local rotator AimRot;
			local bool bUseStepFireData;

		if (bCanClientFire == false)
			return;
			
		PawnOwner = Pawn(Owner);
		if (PawnOwner == None)
			return;
		
		bbP = bbPlayer(PawnOwner);

		PawnOwner.PlayRecoil(FiringSpeed);
		PlayerOwner = PlayerPawn(Owner);
			Angle = 0;
			DupRockets = RocketsLoaded - 1;
			if (DupRockets < 0) DupRockets = 0;
			if ( PlayerOwner == None )
				bTightWad = ( FRand() * 4 < PawnOwner.skill );

			bUseStepFireData = bUseV4ServerFireData;
			if ( !bUseStepFireData && PawnOwner.bAltFire != 0 )
				bTightWad = true;

			// --- DETERMINISTIC STEP DATA ---
			if (bUseStepFireData)
			{
				// Use server step rotation/location from v4 move processing.
				AimRot = V4ServerFireRot;
				StartLoc = V4ServerFireLoc + CalcDrawOffset();
				GetAxes(AimRot, X, Y, Z);
				// Apply FireOffset relative to the step aim.
				StartLoc = StartLoc + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
				AdjustedAim = AimRot;
			}
			else
			{
				// Standard Server Logic
				GetAxes(PawnOwner.ViewRotation,X,Y,Z);
				StartLoc = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 

				if ( bFireLoad ) 		
					AdjustedAim = PawnOwner.AdjustAim(ProjectileSpeed, StartLoc, AimError, True, bWarnTarget);
				else 
					AdjustedAim = PawnOwner.AdjustToss(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);	
				
				if ( PlayerOwner != None )
					AdjustedAim = PawnOwner.ViewRotation;
			}
			bUseV4ServerFireData = false;
			// ------------------------------
		
		PlayRFiring(RocketsLoaded-1);		
		Owner.MakeNoise(PawnOwner.SoundDampening);
		if ( !bFireLoad )
		{
			LockedTarget = None;
			bLockedOn = false;
		}
		else if ( LockedTarget != None )
		{
			BestTarget = Pawn(CheckTarget());
			if ( (LockedTarget!=None) && (LockedTarget != BestTarget) ) 
			{
				LockedTarget = None;
				bLockedOn=False;
			}
		}
		else 
			BestTarget = None;
		bPendingLock = false;
		bPointing = true;
		FireRot = AdjustedAim;
		if (bTightWad || !bFireLoad)
			RocketRad = 7;
		else
			RocketRad = 4;

		NumSpawnedRockets = 0;
		
		for (i = 0; i < RocketsLoaded; i++)
		{
			Spread = (-0.5 * (RocketsLoaded-1) + i);

			if (RocketsLoaded == 1) {
				FireLocation = StartLoc;
			} else if (bTightWad || bFireLoad == false) {
				FireLocation = StartLoc - (Sin(Angle)*RocketRad - 7.5)*Y + (Cos(Angle)*RocketRad - 7)*Z;
			} else {
				FireLocation = StartLoc + (Spread*4.0*Y);
			}
			
			if (bFireLoad)
			{
				if (bTightWad) {
					FireRot.Yaw = AdjustedAim.Yaw;
				} else {
					FireRot.Yaw = AdjustedAim.Yaw + Spread*WSettings.RocketSpreadSpacingDegrees*(65536.0/360.0);
				}

				// Spawn rockets and collect them for batch simulation
				if (LockedTarget != None)
				{
					s = Spawn(class'ST_UT_SeekingRocket',, '', FireLocation, FireRot);
					s.WImp = WImp;
					s.Seeking = LockedTarget;
					s.NumExtraRockets = DupRockets;
					SpawnedRockets[NumSpawnedRockets] = s;
					NumSpawnedRockets++;
				}
				else 
				{
					r = Spawn(class'ST_RocketMk2',, '', FireLocation, FireRot);
					r.WImp = WImp;
					r.NumExtraRockets = DupRockets;
					r.RocketIndex = i;
					SpawnedRockets[NumSpawnedRockets] = r;
					NumSpawnedRockets++;
				}
			}
			else // Grenades
			{
				g = Spawn(class'ST_UT_Grenade',, '', FireLocation, AdjustedAim);
				g.WImp = WImp;
				g.NumExtraGrenades = DupRockets;
				
				// Apply randomization for multiple grenades
				if (DupRockets > 0)
				{
					RandRot.Pitch = FRand() * 1500 - 750;
					RandRot.Yaw = FRand() * 1500 - 750;
					RandRot.Roll = FRand() * 1500 - 750;
					g.Velocity = g.Velocity >> RandRot;
				}

				// Add to batch simulation
				SpawnedRockets[NumSpawnedRockets] = g;
				NumSpawnedRockets++;
			}

			Angle += 1.04719755; //2*Pi/6;
		}
		
		RocketsLoaded = 0;

		// Apply ping compensation to all rockets at once if enabled
		if (bbP != none && IsPingCompEnabled() && NumSpawnedRockets > 0)
		{
			WImp.BatchSimulateProjectiles(SpawnedRockets, NumSpawnedRockets, bbP.PingAverage);
		}
		
		bTightWad=False;
		bRotated = false;
	}

	function AnimEnd()
	{

		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
		{
			LockedTarget = None;
			GotoState('DownWeapon');
			return;
		}
		// We do NOT want to start loading a new rocket automatically on the server.
		if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
		{
			LockedTarget = None;
			// Use GotoState('Idle') instead of Finish() because Finish() might call Fire(),
			// which is empty/returns in our override, causing the server to get stuck in FireRockets state.
			GotoState('Idle');
			return;
		}

		if ( !bRotated && (AmmoType.AmmoAmount > 0) ) 
		{	
			PlayLoading(1.5,0);
			RocketsLoaded = 1;
			bRotated = true;
			return;
		}
		LockedTarget = None;
		Finish();
	}
Begin:	
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
		carried = 'UT_Eightball';
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

state NormalFire
{

	function bool SplashJump()
	{
		return true;
	}

	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if (bChangeWeapon)
		{
			RocketsLoaded = 0;
			bRotated = false;
			GotoState('DownWeapon');
		}
	}

	function AnimEnd()
	{
		if ( bRotated )
		{
			bRotated = false;
			PlayLoading(1.1, RocketsLoaded);
		}
		else
		{
			if ( RocketsLoaded == 6 )
			{
				GotoState('FireRockets');
				return;
			}
			RocketsLoaded++;
			AmmoType.UseAmmo(1);
			if (pawn(Owner).bAltFire!=0) bTightWad=True;
			// Lock-on check removed: you should only lock on before you fire or load
			bPointing = true;
			Owner.MakeNoise(0.6 * Pawn(Owner).SoundDampening);		
			RotateRocket();
		}
	}

	function BeginState()
	{
		bFireLoad = True;
		RocketsLoaded = 1;
		RotateRocket();
	}

	function RotateRocket()
	{
		if ( PlayerPawn(Owner) == None )
		{
			if ( FRand() > 0.33 )
				Pawn(Owner).bFire = 0;
			if ( Pawn(Owner).bFire == 0 )
			{
	 			GoToState('FireRockets');
				return;
			}
		}
		if ( AmmoType.AmmoAmount <= 0 ) 
		{
			GotoState('FireRockets');
			return;
		}
		if ( AmmoType.AmmoAmount == 1 )
			Owner.PlaySound(Misc2Sound, SLOT_None, Pawn(Owner).SoundDampening); 
		PlayRotating(RocketsLoaded-1);
		bRotated = true;
	}
}

state AltFiring
{
	function Tick( float DeltaTime )
	{
		if (bChangeWeapon)
		{
			RocketsLoaded = 0;
			bRotated = false;
			GotoState('DownWeapon');
		}

		Super.Tick(DeltaTime);
	}
	
	function AnimEnd()
	{
		if ( bRotated )
		{
			bRotated = false;
			PlayLoading(1.1, RocketsLoaded);
		}
		else
		{
			if ( RocketsLoaded == 6 )
			{
				GotoState('FireRockets');
				return;
			}
			RocketsLoaded++;
			AmmoType.UseAmmo(1);		
			if ( (PlayerPawn(Owner) == None) && ((FRand() > 0.5) || (Pawn(Owner).Enemy == None)) )
				Pawn(Owner).bAltFire = 0;
			bPointing = true;
			Owner.MakeNoise(0.6 * Pawn(Owner).SoundDampening);		
			RotateRocket();
		}
	}

	function RotateRocket()
	{
		if (AmmoType.AmmoAmount<=0)
		{ 
			GotoState('FireRockets');
			return;
		}		
		PlayRotating(RocketsLoaded-1);
		bRotated = true;
	}

	function BeginState()
	{
		RocketsLoaded = 1;
		bFireLoad = False;
		RotateRocket();
	}

Begin:
	bLockedOn = False;
}

// Idle state - prevents server from auto-firing when client is in control
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
			// Don't check for bFire/bAltFire to trigger server-side firing
			bPointing = false;
			
			// Fix: Check for empty ammo and switch weapon
			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) ) 
				Pawn(Owner).SwitchToBestWeapon();

			Disable('AnimEnd');
			PlayIdleAnim();
		}
		else
		{
			bPointing = False;
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

	function Timer()
	{
		NewTarget = CheckTarget();
		if ( NewTarget == OldTarget )
		{
			LockedTarget = NewTarget;
			If (LockedTarget != None) 
			{
				bLockedOn=True;			
				Owner.MakeNoise(Pawn(Owner).SoundDampening);
				Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening);
				if ( (Pawn(LockedTarget) != None) && (FRand() < 0.7) )
					Pawn(LockedTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));	
				if ( bPendingLock )
				{
					OldTarget = NewTarget;
					Pawn(Owner).bFire = 0;
					bFireLoad = True;
					RocketsLoaded = 1;
					GotoState('FireRockets', 'Begin');
					return;
				}
			}
		}
		else if( (OldTarget != None) && (NewTarget == None) ) 
		{
			Owner.PlaySound(Misc2Sound, SLOT_None,Pawn(Owner).SoundDampening);
			bLockedOn = False;
		}
		else 
		{
			LockedTarget = None;
			bLockedOn = False;
		}
		OldTarget = NewTarget;
		bPendingLock = false;
	}

Begin:
	if (Pawn(Owner).bFire!=0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0) AltFire(0.0);	
	bPointing=False;
	if (AmmoType.AmmoAmount<=0) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	PlayIdleAnim();
	OldTarget = CheckTarget();
	SetTimer(1.25,True);
	LockedTarget = None;
	bLockedOn = False;
PendingLock:
	if ( bPendingLock )
		bPointing = true;
	if ( TimerRate <= 0 )
		SetTimer(1.0, true);
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().EightballSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().EightballDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().EightballDownAnimSpeed(), TweenTime);
}

simulated function PlayLoading(float rate, int num)
{
	if (Owner == None)
		return;
	
	PlayAnim(LoadAnim[num],, 0.05);
	
	if (Role < ROLE_Authority && IsPingCompEnabled() && !UsesServerMoveV4() && PlayerPawn(Owner) != None)
		ServerPlayLoadSound(num, false);
	else
		Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

simulated function PlayRotating(int num)
{
	if (Owner == None)
		return;
	
	PlayAnim(RotateAnim[num],, 0.05);
	
	if (Role < ROLE_Authority && IsPingCompEnabled() && !UsesServerMoveV4() && PlayerPawn(Owner) != None)
		ServerPlayLoadSound(num, true);
	else
		Owner.PlayOwnedSound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
}

// =========================================================================
// Fixes for Client Side State Management
// =========================================================================

state ClientFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function Tick(float DeltaTime)
	{
		// Only update V4CachedChargeData when actually firing (falling edge).
		// During loading, V4CachedChargeData reflects the last FULLY loaded
		// rocket count, not the one currently being loaded. This prevents
		// the server from seeing V4ChargeData=6 before Load6 finishes.
		if ( (Pawn(Owner).bFire == 0) || (Ammotype.AmmoAmount <= 0) ) {
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			V4Log("[CLI] Tick: release fire, rockets="$ClientRocketsLoaded$" V4Cached="$V4CachedChargeData$" Time="$Level.TimeSeconds$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		if ( !bCanClientFire || (Pawn(Owner) == None) )
			GotoState('');
		else if ( bClientDone )
		{
			V4Log("[CLI] AnimEnd: done, -> ClientReload Time="$Level.TimeSeconds);
			PlayLoading(1.5,0);
			GotoState('ClientReload');
		}
		else if ( bRotated )
		{
			// Start loading the next rocket. DON'T update V4CachedChargeData
			// yet — the load animation hasn't finished. Server must not see
			// the new count until loading completes (prevents premature auto-fire).
			PlayLoading(1.1, ClientRocketsLoaded);
			bRotated = false;
			ClientRocketsLoaded++;
			V4Log("[CLI] AnimEnd: loading rocket #"$ClientRocketsLoaded$" V4Cached="$V4CachedChargeData$" (deferred) Time="$Level.TimeSeconds);
		}
		else
		{
			// Loading complete — rocket is fully loaded. Now update V4CachedChargeData.
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			if ( bInstantRocket || (ClientRocketsLoaded == 6) )
			{
				V4Log("[CLI] AnimEnd: auto-fire instant="$bInstantRocket$" rockets="$ClientRocketsLoaded$" V4Cached="$V4CachedChargeData$" Time="$Level.TimeSeconds$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw);
				FiringRockets();
				return;
			}
			V4Log("[CLI] AnimEnd: rocket #"$ClientRocketsLoaded$" ready V4Cached="$V4CachedChargeData$" Time="$Level.TimeSeconds);
			Enable('Tick');
			PlayRotating(ClientRocketsLoaded - 1);
			bRotated = true;
			if (AmmoType != None)
				AmmoType.AmmoAmount--;
		}
	}

		simulated function BeginState()
		{
			bFireLoad = true;
			
			V4Log("[CLI] ClientFiring.Begin instant="$bInstantRocket$" Time="$Level.TimeSeconds$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw);

			// Notify server to stop lock-on checking - can only lock before loading
			if (Role < ROLE_Authority && IsPingCompEnabled() && !UsesServerMoveV4())
				ServerStartedLoading();

		if (AmmoType != None)
        	AmmoType.AmmoAmount--;
		
		if ( bInstantRocket )
		{
			ClientRocketsLoaded = 1;
			V4CachedChargeData = 1;
			FiringRockets();
		}
		else
		{
			ClientRocketsLoaded = 1;
			V4CachedChargeData = 1;
			PlayRotating(ClientRocketsLoaded - 1);
			bRotated = true;
		}
	}

	simulated function EndState()
	{
		V4Log("[CLI] ClientFiring.End V4Cached was "$V4CachedChargeData$" -> 0 Time="$Level.TimeSeconds);
		// Reset V4CachedChargeData so the next input doesn't carry stale
		// rocket counts from this cycle. BeginState reinitializes to 1.
		V4CachedChargeData = 0;
		bClientDone = false;
		bRotated = false;
	}
}

state ClientAltFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function Tick(float DeltaTime)
	{
		if ( (Pawn(Owner).bAltFire == 0) || (Ammotype.AmmoAmount <= 0) ) {
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		if ( !bCanClientFire || (Pawn(Owner) == None) )
			GotoState('');
		else if ( bClientDone )
		{
			PlayLoading(1.5,0);
			GotoState('ClientReload');
		}
		else if ( bRotated )
		{
			PlayLoading(1.1, ClientRocketsLoaded);
			bRotated = false;
			ClientRocketsLoaded++;
		}
		else
		{
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			if ( ClientRocketsLoaded == 6 )
			{
				FiringRockets();
				return;
			}
			Enable('Tick');
			PlayRotating(ClientRocketsLoaded - 1);
			bRotated = true;
			if (AmmoType != None)
				AmmoType.AmmoAmount--;
		}
	}

		simulated function BeginState()
		{
			bFireLoad = false;
			
			// Notify server to stop lock-on checking - can only lock before loading
			if (Role < ROLE_Authority && IsPingCompEnabled() && !UsesServerMoveV4())
				ServerStartedLoading();
		
		if (AmmoType != None)
        	AmmoType.AmmoAmount--;

		ClientRocketsLoaded = 1;
		V4CachedChargeData = 1;
		PlayRotating(ClientRocketsLoaded - 1);
		bRotated = true;
	}

	simulated function EndState()
	{
		V4CachedChargeData = 0;
		bClientDone = false;
		bRotated = false;
	}
}

state ClientReload
{
	simulated function bool ClientFire(float Value)
	{
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	// Tick only enabled when AnimEnd fires before client cooldown expires.
	// Waits for NextClientFireTS then re-fires, keeping the client's fire
	// timing aligned with the server's deterministic cooldown chain.
	simulated function Tick(float DeltaTime)
	{
		// Player released fire while waiting — go idle
		if (!bForceFire && (Pawn(Owner) == None || Pawn(Owner).bFire == 0)
			&& !bForceAltFire && (Pawn(Owner) == None || Pawn(Owner).bAltFire == 0))
		{
			Disable('Tick');
			GotoState('');
			return;
		}

		if (Level.TimeSeconds >= NextClientFireTS) {
			Disable('Tick');
			if (bForceFire || (Pawn(Owner) != None && Pawn(Owner).bFire != 0)) {
				V4Log("[CLI] Reload.Tick: cooldown re-fire Time="$Level.TimeSeconds);
				Global.ClientFire(0);
			} else if (bForceAltFire || (Pawn(Owner) != None && Pawn(Owner).bAltFire != 0)) {
				V4Log("[CLI] Reload.Tick: cooldown re-altfire Time="$Level.TimeSeconds);
				Global.ClientAltFire(0);
			}
		}
	}

	simulated function AnimEnd()
	{
		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForceFire || (Pawn(Owner).bFire != 0) )
			{
				// When V4 is active, gate re-fire behind the cooldown timer
				// to match the server's deterministic fire timing.
				if (IsV4Active() && Level.TimeSeconds + 0.001 < NextClientFireTS) {
					V4Log("[CLI] Reload.AnimEnd: waiting for cooldown, need="$(NextClientFireTS - Level.TimeSeconds)$"s Time="$Level.TimeSeconds);
					Enable('Tick');
					return;
				}
				V4Log("[CLI] Reload.AnimEnd: re-fire Time="$Level.TimeSeconds);
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			{
				if (IsV4Active() && Level.TimeSeconds + 0.001 < NextClientFireTS) {
					V4Log("[CLI] Reload.AnimEnd: waiting for cooldown, need="$(NextClientFireTS - Level.TimeSeconds)$"s Time="$Level.TimeSeconds);
					Enable('Tick');
					return;
				}
				V4Log("[CLI] Reload.AnimEnd: re-altfire Time="$Level.TimeSeconds);
				Global.ClientAltFire(0);
				return;
			}
		}
		
		// Switch weapon if out of ammo
		if ( (AmmoType == None) || (AmmoType.AmmoAmount <= 0) )
		{
			GotoState('');
			if ( Pawn(Owner) != None )
				Pawn(Owner).SwitchToBestWeapon();
			return;
		}
		
		GotoState('');
		Global.AnimEnd();
	}

	simulated function EndState()
	{
		Disable('Tick');
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function BeginState()
	{
		Disable('Tick');
		bForceFire = false;
		bForceAltFire = false;
	}
}

defaultproperties {
}
