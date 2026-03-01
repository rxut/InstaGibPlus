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
const FIRE_RATE_LIMIT = 0.65;
var int DebugClientShotSeq;
var int DebugServerShotSeq;

// Deterministic input-loop firing state (InputReplication path)
var bool bDeterministicPrimaryHeld;
var bool bDeterministicAltHeld;
var float DeterministicNextPrimaryTS;
var float DeterministicNextAltTS;
var float DeterministicPrimaryInterval;
var float DeterministicAltInterval;
var int DeterministicPredPrimarySeq;
var int DeterministicPredAltSeq;
var int DeterministicAckPrimarySeq;
var int DeterministicAckAltSeq;
var int DeterministicServerPrimarySeq;
var int DeterministicServerAltSeq;
var bool bDeterministicRuntimeFallback;
var float DeterministicLastShotTS;
var float DeterministicLastShotInterval;
var bool bDeterministicWasReady;

// Deterministic shot data consumed by TraceFire
var bool bUseDeterministicData;
var vector DeterministicShotLoc;
var rotator DeterministicShotRot;

var transient bool bDeterministicReadyOverride;

replication
{
	// Replicate deterministic shot acknowledgments to clients that have this weapon actor.
	// bNetOwner proved too strict for some switch/hold-fire cases and dropped owner acks.
	reliable if (Role == ROLE_Authority)
		ClientAckPrimaryShot, ClientAckAltShot;
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

simulated function bool ShouldDebugShots() {
	local bbPlayer BP;

	BP = bbPlayer(Owner);
	if (BP == none)
		return false;

	if (BP.bDrawDebugData)
		return true;

	// During deterministic bring-up, always emit ST shock debug lines, including fallback transitions.
	if (IsPingCompEnabled() && (UseDeterministicInputLoop() || bDeterministicRuntimeFallback))
		return true;

	return false;
}

simulated function bool ShouldLogShotEvent(coerce string EventName) {
	if (EventName ~= "DetClientPrimary")
		return true;
	if (EventName ~= "DetClientAlt")
		return true;
	if (EventName ~= "DetServerPrimary")
		return true;
	if (EventName ~= "DetServerAlt")
		return true;
	if (EventName ~= "ServerTraceFire-Deterministic")
		return true;
	if (EventName ~= "AckPrimary")
		return true;
	if (EventName ~= "AckAlt")
		return true;
	if (EventName ~= "DetOutOfAmmo")
		return true;
	if (Left(EventName, 12) ~= "DetFallback-")
		return true;

	return false;
}

simulated function DebugShotEvent(coerce string EventName, optional rotator EventRot, optional vector EventLoc) {
	local bbPlayer BP;
	local Pawn PawnOwner;
	local string Msg;
	local string PlayerName;
	local string ModeTag;

	if (!ShouldDebugShots())
		return;
	if (!ShouldLogShotEvent(EventName))
		return;

	BP = bbPlayer(Owner);
	PawnOwner = Pawn(Owner);
	if (BP == None || PawnOwner == None)
		return;

	if (UseDeterministicInputLoop())
		ModeTag = "DET";
	else
		ModeTag = "STD";

	Msg = "STSR"@EventName
		@"SeqC="$DebugClientShotSeq
		@"SeqS="$DebugServerShotSeq
		@"Mode="$ModeTag
		@"Key="$ModeTag$":"$DebugServerShotSeq
		@"Pred="$DeterministicPredPrimarySeq$"/"$DeterministicPredAltSeq
		@"Ack="$DeterministicAckPrimarySeq$"/"$DeterministicAckAltSeq
		@"Next="$DeterministicNextPrimaryTS$"/"$DeterministicNextAltTS
		@"LTS="$Level.TimeSeconds
		@"CTS="$BP.CurrentTimeStamp
		@"State="$GetStateName()
		@"bF="$PawnOwner.bFire
		@"bAF="$PawnOwner.bAltFire
		@"VR="$int(EventRot.Pitch & 65535)$","$int(EventRot.Yaw & 65535)
		@"Loc="$int(EventLoc.X)$","$int(EventLoc.Y)$","$int(EventLoc.Z);

	// Use ClientMessage for both client and server contexts so local owner always sees debug lines.
	BP.ClientMessage(Msg);

	if (Level.NetMode != NM_Client) {
		if (BP.PlayerReplicationInfo != None)
			PlayerName = BP.PlayerReplicationInfo.PlayerName;
		else
			PlayerName = "UnknownPlayer";
		Log("["$Level.TimeSeconds$"]"@PlayerName@Msg, 'IGPlus');
	}
}

simulated function bool IsDeterministicInputLoopEnabled() {
	return true;
}

simulated function bool UseServerMoveV4DeterministicPath() {
	local bbPlayer BP;

	BP = bbPlayer(Owner);
	if (BP == none)
		return false;
	if (BP.IGPlus_EnableInputReplication)
		return false;

	return int(Level.ServerMoveVersion) >= 4;
}

simulated function bool UseDeterministicInputLoop() {
	local bbPlayer BP;

	if (!IsPingCompEnabled())
		return false;
	if (UseServerMoveV4DeterministicPath())
		return true;
	if (!IsDeterministicInputLoopEnabled())
		return false;

	BP = bbPlayer(Owner);
	if (BP == none)
		return false;

	return !bDeterministicRuntimeFallback;
}

simulated function bool IsDeterministicReady() {
	local Pawn PawnOwner;
	local TournamentPlayer TP;
	local bbPlayer BP;

	if (bDeterministicReadyOverride)
		return true;

	if (!UseDeterministicInputLoop())
		return false;
	if (Owner == none)
		return false;
	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;
	BP = bbPlayer(PawnOwner);
	if (BP != none && BP.IGPlus_IsDeterministicSwitchGuardActive())
		return false;
	TP = TournamentPlayer(PawnOwner);
	// Local switch intent is visible via ClientPending before server-side PendingWeapon
	// catches up. Treat this as not-ready to avoid client-only predicted beams.
	if (TP != none && TP.ClientPending != none && TP.ClientPending != self)
		return false;
	if (PawnOwner.Weapon != self)
		return false;
	if (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		return false;
	if (bChangeWeapon || IsInState('Pickup') || IsInState('DownWeapon') || IsInState('ClientDown'))
		return false;
	if (!bCanClientFire)
		return false;
	return true;
}

simulated function ResetDeterministicState(optional bool bResetFallback) {
	bDeterministicPrimaryHeld = false;
	bDeterministicAltHeld = false;
	DeterministicNextPrimaryTS = 0.0;
	DeterministicNextAltTS = 0.0;
	DeterministicPrimaryInterval = PrimaryShotInterval();
	DeterministicAltInterval = AltShotInterval();
	DeterministicLastShotTS = 0.0;
	DeterministicLastShotInterval = 0.0;
	bDeterministicWasReady = false;
	DeterministicPredPrimarySeq = 0;
	DeterministicPredAltSeq = 0;
	DeterministicAckPrimarySeq = 0;
	DeterministicAckAltSeq = 0;
	DeterministicServerPrimarySeq = 0;
	DeterministicServerAltSeq = 0;
	bUseDeterministicData = false;

	if (bResetFallback)
		bDeterministicRuntimeFallback = false;
}

simulated function rotator QuantizeInputView(rotator InRot) {
	local rotator Q;
	local int PitchSigned;

	PitchSigned = InRot.Pitch << 16 >> 16;
	PitchSigned = Clamp(PitchSigned, -16384, 16383);

	Q.Pitch = PitchSigned;
	Q.Yaw = InRot.Yaw & 0xFFFF;
	Q.Roll = 0;
	return Q;
}

simulated function float CurrentAnimCycleDuration(float Fallback) {
	if (AnimRate > 0.0001 && AnimLast > 0.0001)
		return FClamp(AnimLast / AnimRate, 0.05, 2.0);
	return Fallback;
}

simulated function float PrimaryShotInterval() {
	local float RateScale;

	// Stock ShockRifle primary:
	// Fire1 NUMFRAMES=10, RATE=21, LoopAnim scale=(0.30 + 0.30 * FireAdjust)
	RateScale = 0.30 + 0.30 * FireAdjust;
	if (RateScale <= 0.001)
		return FIRE_RATE_LIMIT;
	return FClamp(9.0 / (21.0 * RateScale), 0.05, 2.0);
}

simulated function float AltShotInterval() {
	local float RateScale;

	// Stock ShockRifle alt:
	// Fire2 NUMFRAMES=10, RATE=24, LoopAnim scale=(0.40 + 0.40 * FireAdjust)
	RateScale = 0.40 + 0.40 * FireAdjust;
	if (RateScale <= 0.001)
		return FIRE_RATE_LIMIT;
	return FClamp(9.0 / (24.0 * RateScale), 0.05, 2.0);
}

simulated function TriggerDeterministicRuntimeFallback(coerce string Reason, optional rotator ReasonRot, optional vector ReasonLoc) {
	bDeterministicRuntimeFallback = true;
	bDeterministicPrimaryHeld = false;
	bDeterministicAltHeld = false;
	DebugShotEvent("DetFallback-"$Reason, ReasonRot, ReasonLoc);
}

simulated function ClientAckPrimaryShot(int Seq, float ShotTS, rotator ShotView, vector ShotOrigin) {
	local int SeqDelta;
	local int PrevPredSeq;
	local float TargetNextTS;
	local bool bFirstAck;
	local bbPlayer BP;

	if (Role == ROLE_Authority)
		return;

	if (!UseDeterministicInputLoop())
		return;

	PrevPredSeq = DeterministicPredPrimarySeq;
	bFirstAck = (DeterministicAckPrimarySeq == 0 && Seq > 0);
	SeqDelta = Seq - DeterministicPredPrimarySeq;

	if (Abs(SeqDelta) > 4) {
		TriggerDeterministicRuntimeFallback("PrimarySeq", ShotView, ShotOrigin);
		return;
	}

	DeterministicAckPrimarySeq = Max(DeterministicAckPrimarySeq, Seq);
	if (Seq >= DeterministicPredPrimarySeq)
		DeterministicPredPrimarySeq = Seq;

	TargetNextTS = ShotTS + FMax(0.01, DeterministicPrimaryInterval);
	if (DeterministicNextPrimaryTS <= 0.0)
		DeterministicNextPrimaryTS = TargetNextTS;
	else if (TargetNextTS > DeterministicNextPrimaryTS + 0.003)
		DeterministicNextPrimaryTS = TargetNextTS;
	if (ShotTS + 0.0001 >= DeterministicLastShotTS) {
		DeterministicLastShotTS = ShotTS;
		DeterministicLastShotInterval = FMax(0.01, DeterministicPrimaryInterval);
	}

	// Bootstrap only when client has not already predicted a shot.
	if (bFirstAck && PrevPredSeq <= 0) {
		PlayFiring();
		BP = bbPlayer(Owner);
		if (BP != none && BP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations)
			ClientTraceFire(true, ShotView, ShotOrigin);
	}

	DebugShotEvent("AckPrimary", ShotView, ShotOrigin);
}

simulated function ClientAckAltShot(int Seq, float ShotTS, rotator ShotView, vector ShotOrigin) {
	local int SeqDelta;
	local int PrevPredSeq;
	local float TargetNextTS;
	local bool bFirstAck;
	local bbPlayer BP;

	if (Role == ROLE_Authority)
		return;

	if (!UseDeterministicInputLoop())
		return;

	PrevPredSeq = DeterministicPredAltSeq;
	bFirstAck = (DeterministicAckAltSeq == 0 && Seq > 0);
	SeqDelta = Seq - DeterministicPredAltSeq;

	if (Abs(SeqDelta) > 4) {
		TriggerDeterministicRuntimeFallback("AltSeq", ShotView, ShotOrigin);
		return;
	}

	DeterministicAckAltSeq = Max(DeterministicAckAltSeq, Seq);
	if (Seq >= DeterministicPredAltSeq)
		DeterministicPredAltSeq = Seq;

	TargetNextTS = ShotTS + FMax(0.01, DeterministicAltInterval);
	if (DeterministicNextAltTS <= 0.0)
		DeterministicNextAltTS = TargetNextTS;
	else if (TargetNextTS > DeterministicNextAltTS + 0.003)
		DeterministicNextAltTS = TargetNextTS;
	if (ShotTS + 0.0001 >= DeterministicLastShotTS) {
		DeterministicLastShotTS = ShotTS;
		DeterministicLastShotInterval = FMax(0.01, DeterministicAltInterval);
	}

	// Bootstrap only when client has not already predicted a shot.
	if (bFirstAck && PrevPredSeq <= 0) {
		PlayAltFiring();
		BP = bbPlayer(Owner);
		if (BP != none && BP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations)
			ClientSpawnAltProjectileEffects(true, ShotView, ShotOrigin);
	}

	DebugShotEvent("AckAlt", ShotView, ShotOrigin);
}

simulated function bool CanDeterministicPrimaryShot(bool bServerSide) {
	local Pawn PawnOwner;

	if (!IsDeterministicReady())
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;

	if ((AmmoType == none) && (AmmoName != none) && bServerSide)
		GiveAmmo(PawnOwner);
	if (AmmoType != none && AmmoType.AmmoAmount <= 0)
		return false;

	return true;
}

simulated function bool CanDeterministicAltShot(bool bServerSide) {
	return CanDeterministicPrimaryShot(bServerSide);
}

simulated function bool ClientDoDeterministicPrimaryShot(float ShotTS, rotator ShotView, vector ShotLoc) {
	local Pawn PawnOwner;
	local bbPlayer BP;

	if (!CanDeterministicPrimaryShot(false))
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;

	BP = bbPlayer(PawnOwner);
	DeterministicPredPrimarySeq += 1;
	DebugClientShotSeq += 1;
	DebugShotEvent("DetClientPrimary", ShotView, ShotLoc);

	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	PlayFiring();
	DeterministicPrimaryInterval = PrimaryShotInterval();

	if (Affector != none)
		Affector.FireEffect();

	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(450, 190, 650));

	if (BP != none && BP.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations)
		ClientTraceFire(true, ShotView, ShotLoc);

	return true;
}

simulated function bool ClientDoDeterministicAltShot(float ShotTS, rotator ShotView, vector ShotLoc) {
	local Pawn PawnOwner;
	local bbPlayer BP;

	if (!CanDeterministicAltShot(false))
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;

	BP = bbPlayer(PawnOwner);
	DeterministicPredAltSeq += 1;
	DebugClientShotSeq += 1;
	DebugShotEvent("DetClientAlt", ShotView, ShotLoc);

	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	PlayAltFiring();
	DeterministicAltInterval = AltShotInterval();

	if (Affector != none)
		Affector.FireEffect();

	if (BP != none && BP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations)
		ClientSpawnAltProjectileEffects(true, ShotView, ShotLoc);

	return true;
}

function bool ServerDoDeterministicPrimaryShot(float ShotTS, rotator ShotView, vector ShotLoc) {
	local Pawn PawnOwner;

	if (!CanDeterministicPrimaryShot(true))
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;

	DeterministicServerPrimarySeq += 1;

	DeterministicShotRot = ShotView;
	DeterministicShotLoc = ShotLoc;
	bUseDeterministicData = true;

	AmmoType.UseAmmo(1);

	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	PlayFiring();
	DeterministicPrimaryInterval = PrimaryShotInterval();

	if (Affector != none)
		Affector.FireEffect();

	TraceFire(0.0);
	bUseDeterministicData = false;
	DebugShotEvent("DetServerPrimary", ShotView, ShotLoc);

	DebugShotEvent("AckPrimaryTx", ShotView, ShotLoc);
	ClientAckPrimaryShot(DeterministicServerPrimarySeq, ShotTS, ShotView, ShotLoc);
	HandleDeterministicServerOutOfAmmo(ShotView, ShotLoc);

	return true;
}

function Projectile DeterministicProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn) {
	local vector Start, X, Y, Z;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	Owner.MakeNoise(PawnOwner.SoundDampening);

	GetAxes(DeterministicShotRot, X, Y, Z);
	Start = DeterministicShotLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = DeterministicShotRot;
	return Spawn(ProjClass, , , Start, AdjustedAim);
}

function bool ServerDoDeterministicAltShot(float ShotTS, rotator ShotView, vector ShotLoc) {
	local Pawn PawnOwner;

	if (!CanDeterministicAltShot(true))
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;

	DeterministicServerAltSeq += 1;

	DeterministicShotRot = ShotView;
	DeterministicShotLoc = ShotLoc;
	bUseDeterministicData = true;

	AmmoType.UseAmmo(1);

	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	PlayAltFiring();
	DeterministicAltInterval = AltShotInterval();

	if (Affector != none)
		Affector.FireEffect();

	DeterministicProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
	bUseDeterministicData = false;
	DebugShotEvent("DetServerAlt", ShotView, ShotLoc);

	DebugShotEvent("AckAltTx", ShotView, ShotLoc);
	ClientAckAltShot(DeterministicServerAltSeq, ShotTS, ShotView, ShotLoc);
	HandleDeterministicServerOutOfAmmo(ShotView, ShotLoc);

	return true;
}

function HandleDeterministicServerOutOfAmmo(optional rotator EventRot, optional vector EventLoc) {
	local Pawn PawnOwner;

	if (Role < ROLE_Authority || Level.NetMode == NM_Client)
		return;
	if (AmmoType == none || AmmoType.AmmoAmount > 0)
		return;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	bDeterministicPrimaryHeld = false;
	bDeterministicAltHeld = false;
	DeterministicNextPrimaryTS = 0.0;
	DeterministicNextAltTS = 0.0;

	if (PawnOwner.Weapon == self) {
		PawnOwner.StopFiring();
		if (PawnOwner.PendingWeapon == none || PawnOwner.PendingWeapon == self)
			PawnOwner.SwitchToBestWeapon();
	}

	DebugShotEvent("DetOutOfAmmo", EventRot, EventLoc);
}

simulated function bool IGPlus_OnInputStep(
	float InputTS,
	rotator InputView,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	optional vector InputLoc,
	optional bool bStepReadyHint
) {
	local bool bServerSide;
	local rotator ShotView;
	local vector ShotLoc;
	local bool bDidShot;
	local bool bReady;
	local float Interval;

	if (!UseDeterministicInputLoop())
		return false;
	if (Owner == none || Pawn(Owner) == none)
		return false;

	bServerSide = (Role == ROLE_Authority && Level.NetMode != NM_Client);
	if (bServerSide && bStepReadyHint)
		bDeterministicReadyOverride = true;

	bReady = IsDeterministicReady();
	if (!bReady) {
		bDeterministicReadyOverride = false;
		// Soft-pause deterministic loop during transient switch/not-ready windows.
		// Keep timeline anchors so client/server don't reseed differently.
		bDeterministicPrimaryHeld = false;
		bDeterministicAltHeld = false;
		bDeterministicWasReady = false;
		return false;
	}

	if (!bDeterministicWasReady) {
		bDeterministicWasReady = true;
		// Do not reset Next*/Last* here; preserving cadence across short readiness
		// gaps avoids client/server schedule drift under rapid switch spam.
		bDeterministicPrimaryHeld = false;
		bDeterministicAltHeld = false;
	}

	bServerSide = (Role == ROLE_Authority && Level.NetMode != NM_Client);
	ShotView = QuantizeInputView(InputView);
	ShotLoc = InputLoc;
	if (ShotLoc == vect(0,0,0))
		ShotLoc = Owner.Location;

	if (bFireHeld || bForceFire) {
		if (!bDeterministicPrimaryHeld) {
			bDeterministicPrimaryHeld = true;
			if (DeterministicNextPrimaryTS <= 0.0 || DeterministicNextPrimaryTS < InputTS)
				DeterministicNextPrimaryTS = FMax(InputTS, DeterministicLastShotTS + FMax(0.01, DeterministicLastShotInterval));
		}
	} else {
		bDeterministicPrimaryHeld = false;
	}

	if (bAltHeld || bForceAlt) {
		if (!bDeterministicAltHeld) {
			bDeterministicAltHeld = true;
			if (DeterministicNextAltTS <= 0.0 || DeterministicNextAltTS < InputTS)
				DeterministicNextAltTS = FMax(InputTS, DeterministicLastShotTS + FMax(0.01, DeterministicLastShotInterval));
		}
	} else {
		bDeterministicAltHeld = false;
	}

	if (bDeterministicPrimaryHeld) {
		if (InputTS + 0.0001 >= DeterministicNextPrimaryTS) {
			if (bServerSide)
				bDidShot = ServerDoDeterministicPrimaryShot(DeterministicNextPrimaryTS, ShotView, ShotLoc);
			else
				bDidShot = ClientDoDeterministicPrimaryShot(DeterministicNextPrimaryTS, ShotView, ShotLoc);

			Interval = FMax(0.01, DeterministicPrimaryInterval);
			if (bDidShot) {
				DeterministicLastShotTS = DeterministicNextPrimaryTS;
				DeterministicLastShotInterval = Interval;
				DeterministicNextPrimaryTS += Interval;
				if (DeterministicNextPrimaryTS < InputTS)
					DeterministicNextPrimaryTS = InputTS + Interval;
			} else {
				if (bServerSide)
					HandleDeterministicServerOutOfAmmo(ShotView, ShotLoc);
				DeterministicNextPrimaryTS = InputTS + Interval;
			}
		}
		bDeterministicReadyOverride = false;
		return true;
	}

	if (bDeterministicAltHeld) {
		if (InputTS + 0.0001 >= DeterministicNextAltTS) {
			if (bServerSide)
				bDidShot = ServerDoDeterministicAltShot(DeterministicNextAltTS, ShotView, ShotLoc);
			else
				bDidShot = ClientDoDeterministicAltShot(DeterministicNextAltTS, ShotView, ShotLoc);

			Interval = FMax(0.01, DeterministicAltInterval);
			if (bDidShot) {
				DeterministicLastShotTS = DeterministicNextAltTS;
				DeterministicLastShotInterval = Interval;
				DeterministicNextAltTS += Interval;
				if (DeterministicNextAltTS < InputTS)
					DeterministicNextAltTS = InputTS + Interval;
			} else {
				if (bServerSide)
					HandleDeterministicServerOutOfAmmo(ShotView, ShotLoc);
				DeterministicNextAltTS = InputTS + Interval;
			}
		}
		bDeterministicReadyOverride = false;
		return true;
	}

	bDeterministicReadyOverride = false;
	return false;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	ResetDeterministicState();

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
		if (UseDeterministicInputLoop()) {
			DebugShotEvent("ClientFire-DetInput", PawnOwner.ViewRotation, PawnOwner.Location);
			return true;
		}

		if (!Super.ClientFire(Value))
			return false;

		DebugShotEvent("ClientFire-NoDet", PawnOwner.ViewRotation, PawnOwner.Location);
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
	DebugClientShotSeq += 1;
	DebugShotEvent("ClientBeamTrace", AimRot, AimLoc);

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
		if (UseDeterministicInputLoop()) {
			DebugShotEvent("ClientAlt-DetInput", PawnOwner.ViewRotation, PawnOwner.Location);
			return true;
		}

		if (!Super.ClientAltFire(Value))
			return false;

		DebugShotEvent("ClientAlt-NoDet", PawnOwner.ViewRotation, PawnOwner.Location);
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
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;
	local rotator AimRot;
	local vector AimLoc;
	local vector SmokeLocation;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	// Deterministic path is authoritative for server primary shots.
	// If legacy fire state slips through (NormalFire/Finish), drop that trace
	// so we never spawn duplicate server beams.
	if (Role == ROLE_Authority
		&& Level.NetMode != NM_Client
		&& UseDeterministicInputLoop()
		&& !bUseDeterministicData)
		return;

	Owner.MakeNoise(PawnOwner.SoundDampening);

	if (Role == ROLE_Authority && Level.NetMode != NM_Client) {
		DebugServerShotSeq += 1;
		if (bUseDeterministicData)
			DebugShotEvent("ServerTraceFire-Deterministic", DeterministicShotRot, DeterministicShotLoc);
		else
			DebugShotEvent("ServerTraceFire-Standard", PawnOwner.ViewRotation, Owner.Location);
	}

	if (bUseDeterministicData)
	{
		AimRot = DeterministicShotRot;
		AimLoc = DeterministicShotLoc;
	}
	else
	{
		AimRot = PawnOwner.ViewRotation;
		AimLoc = Owner.Location;
	}

	GetAxes(AimRot,X,Y,Z);
	StartTrace = AimLoc + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 
	SmokeLocation = AimLoc + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z;

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

function bool PutDown()
{
	local bbPlayer BP;

	BP = bbPlayer(Owner);
	if (BP != none)
		BP.IGPlus_MarkDeterministicSwitchGuard();

	// Invalidate deterministic readiness immediately when switch is requested.
	bCanClientFire = false;
	bDeterministicPrimaryHeld = false;
	bDeterministicAltHeld = false;
	DeterministicNextPrimaryTS = 0.0;
	DeterministicNextAltTS = 0.0;
	bDeterministicWasReady = false;
	return Super.PutDown();
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;

	if (UseDeterministicInputLoop()) {
		// Keep seq/timestamps across select transitions. Resetting here causes
		// client/server schedule re-seed while holding fire during switch.
		bDeterministicPrimaryHeld = false;
		bDeterministicAltHeld = false;
	} else {
		ResetDeterministicState(true);
	}

	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().ShockSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	// Clear fire-ready latch as soon as we start switching away to avoid stale
	// ready state bleeding into the next rapid switch-in epoch.
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

state ClientFiring {

	simulated function bool ClientFire(float Value) {
		return false;
	}

	simulated function bool ClientAltFire(float Value) {
		return false;
	}

	simulated function AnimEnd()
	{
		if (UseDeterministicInputLoop()) {
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
		if (UseDeterministicInputLoop()) {
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

function Fire(float Value)
{
	// Deterministic/v4 path owns authoritative server shots for this weapon.
	// Block legacy Fire() entry to prevent duplicate server traces.
	if (UseDeterministicInputLoop() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.Fire(Value);
}

function AltFire(float Value)
{
	// Deterministic/v4 path owns authoritative server shots for this weapon.
	// Block legacy AltFire() entry to prevent duplicate server traces.
	if (UseDeterministicInputLoop() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.AltFire(Value);
}

defaultproperties {
	AltProjectileClass=Class'ST_ShockProj'
}
