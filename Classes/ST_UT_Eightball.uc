// ===============================================================
// Stats.ST_UT_Eightball
// V4 deterministic fire for Eightball rocket launcher.
// Edge-only design: server spawns rockets from rising/falling edge
// detection in sub-steps; client runs the same edge logic as a
// cooldown calculator (shared NextV4FireTS) while the legacy
// ClientFiring state machine handles animations.
// ===============================================================

class ST_UT_Eightball extends UT_Eightball;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

// Server-side deterministic fire data (from ServerMove_v4 step)
var vector V4ServerFireLoc;
var rotator V4ServerFireRot;
var bool bUseV4ServerFireData;

const V4_PHASELOCK_MAX_OVERSHOOT = 0.060;
const IGPLUS_EB_SHOT_KIND_ALT_RELEASE = 2;
const IGPLUS_EB_SHOT_KIND_ALT_AUTO6 = 3;
const IGPLUS_EB_RELEASE_DEBOUNCE = 0.150;
const IGPLUS_EB_PRIMARY_RELEASE_DEBOUNCE = 0.150;
const IGPLUS_EB_PRIMARY_END_RELEASE = 1;
const IGPLUS_EB_PRIMARY_END_AUTO_6 = 2;
const IGPLUS_EB_PRIMARY_END_AUTO_BUDGET = 3;

// Rate limiting to prevent rapid fire exploits
var float LastClientFireTime;
const FIRE_RATE_LIMIT = 0.25;

// V4 deterministic fire — shared between client and server
var float NextV4FireTS;
var float V4LoadStartTS;
var bool bV4WasFireHeld;
var bool bV4WasAltHeld;
var bool bV4MoveInstantValid;
var bool bV4MoveInstant;
var int V4CachedChargeData;

// Client ammo consumption reconstruction logic
var int V4LastSeenAmmo;
var int V4ClientConsumedAmmo;
var int V4InternalBudget;
var bool bV4SuppressPrimaryFirstBudgetAuto;
var bool bV4SuppressAltFirstBudgetAuto;

// Primary deterministic cycle controller (server-authoritative, client-predicted)
var int V4PrimaryCycleId;
var int V4PrimaryWeaponEpoch;
var int V4PrimaryCycleEpoch;
var bool bV4PrimaryCycleActive;
var float V4PrimaryCycleStartTS;
var int V4PrimaryCycleStartBudget;
var int V4PrimaryPredictedLoaded;
var bool bV4PrimaryLatchedInstant;
var int V4PrimaryLastEndReason;
var bool bV4PrimaryReleasePending;
var float V4PrimaryReleasePendingTS;
var int V4PrimaryLastPredictedCycleId;
var int V4PrimaryLastPredictedRockets;
var bool bV4PrimaryLastPredictedInstant;
var int V4PrimaryLastPredictedReason;

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

simulated function V4MaybePlayClientLoadCatchupSound(bool bAlt, int NumRockets) {
	local int MissingLoadNum;

	// Primary-only: if authoritative auto-fire interrupts during rotate,
	// the final load sound may never be reached via AnimEnd.
	if (Role == ROLE_Authority || bAlt || !IsV4Active())
		return;
	if (!IsInState('ClientFiring'))
		return;
	if (!bRotated)
		return;
	if (NumRockets <= ClientRocketsLoaded)
		return;

	if (Owner == None || Pawn(Owner) == None)
		return;

	MissingLoadNum = Clamp(NumRockets - 1, 0, 5);
	Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

simulated function V4SetMoveInstantMode(bool bValid, bool bInstant) {
	bV4MoveInstantValid = bValid;
	bV4MoveInstant = bInstant;
}

simulated function V4InvalidateMoveInstantMode() {
	bV4MoveInstantValid = false;
	bV4MoveInstant = false;
}

simulated function bool V4OwnerInstantEnabled() {
	local TournamentPlayer TP;

	if (bAlwaysInstant)
		return true;

	TP = TournamentPlayer(Owner);
	if (TP != none)
		return TP.bInstantRocket;

	return bInstantRocket;
}

simulated function V4ResetClientAmmoTracking() {
	if (Role == ROLE_Authority)
		return;
	V4ClientConsumedAmmo = 0;
	if (AmmoType != none)
		V4LastSeenAmmo = AmmoType.AmmoAmount;
}

simulated function V4ResetPrimaryCycle(optional bool bClearHeld) {
	if (bClearHeld) {
		bV4WasFireHeld = false;
	}
	bV4SuppressPrimaryFirstBudgetAuto = false;
	bV4PrimaryCycleActive = false;
	V4PrimaryCycleStartTS = 0.0;
	V4PrimaryCycleStartBudget = 0;
	V4PrimaryPredictedLoaded = 0;
	bV4PrimaryLatchedInstant = false;
	V4PrimaryLastEndReason = 0;
	bV4PrimaryReleasePending = false;
	V4PrimaryReleasePendingTS = 0.0;
	V4LoadStartTS = 0.0;
	V4ResetClientAmmoTracking();
}

simulated function V4ResetAltCycle(optional bool bClearHeld) {
	if (bClearHeld) {
		bV4WasAltHeld = false;
		bV4SuppressAltFirstBudgetAuto = false;
	}
	V4ResetClientAmmoTracking();
}

simulated function V4BumpPrimaryWeaponEpoch(optional coerce string Reason) {
	V4PrimaryWeaponEpoch = (V4PrimaryWeaponEpoch + 1) & 65535;
	if (V4PrimaryWeaponEpoch == 0)
		V4PrimaryWeaponEpoch = 1;
	V4PrimaryCycleEpoch = V4PrimaryWeaponEpoch;
	V4ResetPrimaryCycle(true);
	if (V4ShouldDebug())
		V4Log("[PRI] Epoch++ "$V4PrimaryWeaponEpoch$" reason="$Reason$" Time="$Level.TimeSeconds);
}

simulated function V4RefreshInternalBudget() {
	if (AmmoType == none) {
		V4InternalBudget = 0;
		return;
	}

	// Keep budget stable for the whole primary cycle. This mirrors the
	// server's deterministic load budget even if replicated ammo updates
	// arrive while client-side load animations are running.
	if (bV4PrimaryCycleActive && V4PrimaryCycleStartBudget > 0) {
		V4InternalBudget = V4PrimaryCycleStartBudget;
		return;
	}

	V4InternalBudget = AmmoType.AmmoAmount;
}

simulated function V4PrimaryStartCycle(float StepTS, bool bMoveInstant, bool bServerSide) {
	V4PrimaryCycleId = (V4PrimaryCycleId + 1) & 255;
	V4PrimaryCycleEpoch = V4PrimaryWeaponEpoch;
	V4PrimaryCycleStartTS = StepTS;
	V4PrimaryCycleStartBudget = Max(1, V4InternalBudget);
	V4PrimaryPredictedLoaded = 1;
	bV4PrimaryLatchedInstant = bMoveInstant;
	V4PrimaryLastEndReason = 0;
	bV4SuppressPrimaryFirstBudgetAuto = (V4PrimaryCycleStartBudget <= 1);
	bV4PrimaryReleasePending = false;
	V4PrimaryReleasePendingTS = 0.0;

	bInstantRocket = bV4PrimaryLatchedInstant;
	if (!bV4PrimaryLatchedInstant) {
		bV4PrimaryCycleActive = true;
		V4LoadStartTS = StepTS;
		if (!bServerSide) {
			// Deterministic primary cycle owns the first-rocket consume.
			// This must happen after tracking reset so finalize doesn't
			// synthesize an extra missing consume.
			V4ResetClientAmmoTracking();
			V4ConsumeClientAmmo(1, "PrimaryStartCycle initial");
		}
	} else {
		bV4PrimaryCycleActive = false;
		V4LoadStartTS = 0.0;
	}
}

simulated function V4PrimaryRecordPrediction(int NumRockets, int EndReason) {
	V4PrimaryLastPredictedCycleId = V4PrimaryCycleId & 255;
	V4PrimaryLastPredictedRockets = Clamp(NumRockets, 1, 6);
	bV4PrimaryLastPredictedInstant = bV4PrimaryLatchedInstant;
	V4PrimaryLastPredictedReason = EndReason;
	V4PrimaryPredictedLoaded = V4PrimaryLastPredictedRockets;
}

simulated function V4PrimarySendServerConfirm(int NumRockets, int EndReason, float ShotTS) {
	if (Role != ROLE_Authority)
		return;

	ClientV4PrimaryShotConfirm(
		byte(V4PrimaryCycleId & 255),
		byte(Clamp(NumRockets, 1, 6)),
		byte(EndReason & 255),
		bV4PrimaryLatchedInstant,
		ShotTS
	);
}

simulated function ClientV4PrimaryShotConfirm(
	byte CycleId,
	byte Rockets,
	byte EndReason,
	bool bInstant,
	float ShotTS
) {
	local int ConfirmedRockets;
	local int ConfirmCycleId;
	local int ActiveCycleId;
	local bool bMismatch;
	local bool bCycleMatch;

	if (Role == ROLE_Authority)
		return;
	if (!IsV4Active())
		return;

	ConfirmedRockets = Clamp(int(Rockets), 1, 6);
	ConfirmCycleId = int(CycleId) & 255;
	ActiveCycleId = V4PrimaryCycleId & 255;

	// Ignore confirms for a finished cycle once a newer primary cycle is
	// already loading. Applying those confirms here would reset local ammo
	// tracking mid-load and can cause an extra client-side consume.
	if (bV4PrimaryCycleActive && ConfirmCycleId != ActiveCycleId) {
		if (V4ShouldDebug())
			V4Log("[CLI] Ignore stale confirm cycle="$ConfirmCycleId$" active="$ActiveCycleId$" consumed="$V4ClientConsumedAmmo$" Time="$Level.TimeSeconds);
		return;
	}

	bCycleMatch = ((V4PrimaryLastPredictedCycleId & 255) == ConfirmCycleId);
	bMismatch = false;
	if (!bCycleMatch)
		bMismatch = true;
	if (V4PrimaryLastPredictedRockets != ConfirmedRockets)
		bMismatch = true;
	if (bV4PrimaryLastPredictedInstant) {
		if (!bInstant)
			bMismatch = true;
	} else if (bInstant) {
		bMismatch = true;
	}
	if (V4PrimaryLastPredictedReason != int(EndReason))
		bMismatch = true;

	if (V4ShouldDebug()) {
		V4Log(
			"[CLI-CONFIRM] cycle="$int(CycleId)$
			" rockets="$ConfirmedRockets$
			" reason="$int(EndReason)$
			" instant="$bInstant$
			" ts="$ShotTS$
			" mismatch="$bMismatch$
				" predCycle="$V4PrimaryLastPredictedCycleId$
				" predRockets="$V4PrimaryLastPredictedRockets$
				" predReason="$V4PrimaryLastPredictedReason$
				" predInstant="$bV4PrimaryLastPredictedInstant
			);
	}

	// Base UT behavior: client HUD ammo follows replicated server ammo.
	// Do not mutate client ammo here for primary confirm.
	V4ResetClientAmmoTracking();

	V4PrimaryLastEndReason = int(EndReason) & 255;
	bV4PrimaryLatchedInstant = bInstant;
	V4PrimaryPredictedLoaded = ConfirmedRockets;
	V4CachedChargeData = ConfirmedRockets;
	ClientRocketsLoaded = ConfirmedRockets;
	if (bV4PrimaryCycleActive && ConfirmCycleId == ActiveCycleId) {
		bV4PrimaryCycleActive = false;
		V4LoadStartTS = 0.0;
	}

	// Snap to post-fire path when client prediction drifted from authoritative shot.
	if (bMismatch && IsInState('ClientFiring')) {
		bClientDone = true;
		bRotated = false;
	}
}

simulated function int V4GetChargeDataForMove() {
	local int Charge;
	Charge = Clamp(V4CachedChargeData, 0, 7);
	if ((IsInState('ClientFiring') || IsInState('ClientAltFiring')) && ClientRocketsLoaded > Charge)
		Charge = Clamp(ClientRocketsLoaded, 0, 7);
	return Charge;
}

simulated function bool V4ConsumeClientAmmo(int Amount, optional coerce string Context) {
	local int ActualAmount;

	if (Amount <= 0)
		return true;
	if (AmmoType == none)
		return false;
	if (AmmoType.AmmoAmount <= 0) {
		AmmoType.AmmoAmount = 0;
		return false;
	}
	ActualAmount = Min(Amount, AmmoType.AmmoAmount);
	AmmoType.AmmoAmount -= ActualAmount;
	V4ClientConsumedAmmo += ActualAmount;
	return true;
}

// Client load animation can be one rocket behind local ammo consumption at
// the exact deterministic fire step. Snap consumption at fire-time so ammo
// HUD and fire SFX timing stay aligned.
simulated function V4FinalizeClientLoadedAmmo(int NumRockets) {
	local int Missing;

	if (Role == ROLE_Authority || !IsV4Active())
		return;

	Missing = Clamp(NumRockets - V4ClientConsumedAmmo, 0, 6);
	if (Missing > 0)
		V4ConsumeClientAmmo(Missing, "FinalizeLoaded rockets="$NumRockets);
}

simulated function V4EnsureClientLoadState(bool bAltLoad) {
	if (Role == ROLE_Authority || !IsV4Active())
		return;
	if (!bCanClientFire || Pawn(Owner) == none)
		return;

	if (bAltLoad) {
		if (!IsInState('ClientAltFiring')) {
			V4Log("[CLI] Kick ClientAltFiring Time="$Level.TimeSeconds);
			GotoState('ClientAltFiring');
		}
		return;
	}

	if (!IsInState('ClientFiring')) {
		V4Log("[CLI] Kick ClientFiring Time="$Level.TimeSeconds);
		GotoState('ClientFiring');
	}
}

replication
{
	unreliable if(Role < ROLE_Authority)
		ServerStartedLoading, ServerPlayLoadSound;
	unreliable if(Role == ROLE_Authority)
		ClientV4PrimaryShotConfirm;
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
	if (Level != none && Level.NetMode == NM_Standalone)
		return false;
	if (!IsPingCompEnabled())
		return false;
	if (bbPlayer(Owner) == none)
		return false;
	return true;
}

simulated function bool UsesServerMoveV4() {
	local bbPlayer P;

	if (!IsV4Active())
		return false;

	P = bbPlayer(Owner);
	if (P == none)
		return false;

	// Deterministic Eightball authority must stay active for both
	// ServerMove_v4 and input-replication transport modes.
	return int(Level.ServerMoveVersion) >= 4;
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

simulated function bool V4HasSwitchAwayRequest() {
	local Pawn PawnOwner;

	if (!IsV4Active())
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return true;
	if (bbPlayer(PawnOwner).IGPlus_IsDeterministicSwitchGuardActive())
		return true;
	if (TournamentPlayer(PawnOwner) != none
		&& TournamentPlayer(PawnOwner).ClientPending != none
		&& TournamentPlayer(PawnOwner).ClientPending != self)
		return true;
	if (PawnOwner.Weapon != self)
		return true;
	if (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		return true;
	if (bChangeWeapon)
		return true;
	if (IsInState('DownWeapon') || IsInState('ClientDown'))
		return true;
	return false;
}

simulated function V4CancelDeterministicLoad(float StepTS, bool bServerSide) {
	local int CancelCount;

	if (bServerSide && AmmoType != none && AmmoType.AmmoAmount > 0) {
		if (bV4PrimaryCycleActive || bV4WasFireHeld) {
			CancelCount = Clamp(V4CalculateCharge(StepTS), 1, 6);
			AmmoType.UseAmmo(Min(CancelCount, AmmoType.AmmoAmount));
		} else if (bV4WasAltHeld) {
			// Base UT style: consume what is currently loaded, not a
			// time-recomputed charge that can overshoot on switch.
			CancelCount = 1;
			if (V4CachedChargeData > 0)
				CancelCount = Clamp(V4CachedChargeData, 1, 6);
			else if (ClientRocketsLoaded > 0)
				CancelCount = Clamp(ClientRocketsLoaded, 1, 6);
			AmmoType.UseAmmo(Min(CancelCount, AmmoType.AmmoAmount));
		}
	}

	bUseV4ServerFireData = false;
	bTightWad = false;
	RocketsLoaded = 0;
	V4CachedChargeData = 0;
	ClientRocketsLoaded = 0;
	bClientDone = false;
	bRotated = false;
	bForceFire = false;
	bForceAltFire = false;
	V4ResetPrimaryCycle(true);
	V4ResetAltCycle(true);

	if (!bServerSide && (IsInState('ClientFiring') || IsInState('ClientAltFiring') || IsInState('ClientReload')))
		GotoState('');
}



function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;
}

// =========================================================================
// V4 Deterministic Fire — Primary + Alt (Rockets + Grenades)
// =========================================================================

// Post-fire cooldown matching the client's animation-driven cycle:
// PlayRFiring tween (0.05s) + fire anim + PlayLoading tween (0.05s) + Load1 reload.
//
// From execPlayAnim: AnimEnd fires at AnimLast = 1.0 - 1.0/NumFrames.
// Play duration = (NumFrames - 1) / (PlayAnimRate * Seq->Rate).
//
// Fire frame counts from FireAnim[] mesh sequences:
//   [0]=Fire1(8f), [1]=Fire2(11f), [2]=Fire3(10f), [3]=Fire4(11f), [4]=Fire2(11f), [5]=Fire3(10f)
//   All Fire anims: Rate=30. PlayRFiring TweenTime=0.05, PlayRate=0.54 (instant) / 0.6 (normal).
//
// Load1 reload: 7 frames, RATE=15, PlayAnimRate=1.0, TweenTime=0.05.
//   Play duration = (7-1)/15 = 0.4s.
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

	return 0.05 + (FireFrames - 1) / (30.0 * FirePlayRate) + 0.05 + 6.0 / 15.0;
}

// Advance cooldown with phase-lock for small overshoots (sub-step jitter).
// Larger overshoots reset cooldown from the actual fire time.
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

// =========================================================================
// V4ProcessStep — runs on BOTH client and server
//
// Server (bServerSide=true): spawns authoritative rockets via HandleV4ServerFire.
// Client (bServerSide=false): only tracks edge state and sets NextV4FireTS.
//   The client state machine (ClientFiring/ClientReload) handles animations
//   and visual rockets. NextV4FireTS gates re-fire in ClientReload.
// =========================================================================
simulated function float GetV4ChargeInterval() {
	return 0.9;
}

simulated function int V4CalculateCharge(float StepTS) {
	local int Charge;
	local int FinalCharge;

	V4RefreshInternalBudget();

	Charge = 1 + int((StepTS - V4LoadStartTS) / GetV4ChargeInterval());
	FinalCharge = Min(Clamp(Charge, 1, 6), Max(1, V4InternalBudget));
	return FinalCharge;
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
	local int NumRockets;
	local bool bMoveInstant;
	local bool bOwnerInstantSetting;
	local bool bBudgetLimitReached;
	local int PrimaryEndReason;

	if (V4HasSwitchAwayRequest() && (bV4WasAltHeld || bAltHeld || IsInState('ClientAltFiring'))) {
		V4CancelDeterministicLoad(StepTS, bServerSide);
		return true;
	}

	if (!bStepReadyHint && !IsDeterministicReady()) {
		return true;
	}

	if (bV4MoveInstantValid)
		bMoveInstant = bV4MoveInstant;
	else if (TournamentPlayer(Owner) != none)
		bMoveInstant = TournamentPlayer(Owner).bInstantRocket;
	else
		bMoveInstant = bInstantRocket;

	if (StepTS + 0.0001 < NextV4FireTS)
		return true;

	if (!bAltHeld)
		bV4SuppressAltFirstBudgetAuto = false;

	if (AmmoType == none || AmmoType.AmmoAmount <= 0) {
		if (!bV4WasFireHeld && !bV4WasAltHeld) {
			if (bAltHeld)
				bV4SuppressAltFirstBudgetAuto = true;
			if (bServerSide && (bFireHeld || bAltHeld))
				V4HandleOutOfAmmo();
			V4ResetPrimaryCycle(true);
			V4ResetAltCycle(true);
			return true;
		}
	}

	bOwnerInstantSetting = V4OwnerInstantEnabled();

	// Never let a stale move flag force instant mode while the owner's
	// current setting says instant rockets are off.
	if (!bOwnerInstantSetting)
		bMoveInstant = false;

	if (bV4PrimaryCycleActive && V4PrimaryCycleEpoch != V4PrimaryWeaponEpoch) {
		if (V4ShouldDebug())
			V4Log("[PRI] Cancel cycle "$V4PrimaryCycleId$" epoch mismatch cycle="$V4PrimaryCycleEpoch$" current="$V4PrimaryWeaponEpoch$" Time="$Level.TimeSeconds);
		V4ResetPrimaryCycle(true);
	}

	// ── PRIMARY FIRE ──
	if (bFireHeld && !bV4WasFireHeld) {
		V4RefreshInternalBudget();
		V4PrimaryStartCycle(StepTS, bMoveInstant, bServerSide);
		bV4WasFireHeld = true;
		if (bV4PrimaryLatchedInstant) {
			V4PrimaryLastEndReason = IGPLUS_EB_PRIMARY_END_RELEASE;
			if (bServerSide) {
				HandleV4ServerFire(StepView, StepLoc, 1, bAltHeld);
				V4PrimarySendServerConfirm(1, IGPLUS_EB_PRIMARY_END_RELEASE, StepTS);
			} else {
				V4PrimaryRecordPrediction(1, IGPLUS_EB_PRIMARY_END_RELEASE);
				HandleV4ClientFire();
			}
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(1));
			bV4WasFireHeld = false;
			V4ResetPrimaryCycle(false);
		} else if (!bServerSide) {
			V4EnsureClientLoadState(false);
		}
		return true;
	}

	if (bFireHeld && bV4WasFireHeld) {
		if (!bV4PrimaryCycleActive) {
			bV4WasFireHeld = false;
			return true;
		}
		if (bV4PrimaryReleasePending) {
			if (V4ShouldDebug())
				V4Log("[PRI] Cancel pending release cycle="$V4PrimaryCycleId$" Time="$Level.TimeSeconds);
			bV4PrimaryReleasePending = false;
			V4PrimaryReleasePendingTS = 0.0;
		}

				NumRockets = V4CalculateCharge(StepTS);
				V4PrimaryPredictedLoaded = NumRockets;
					if (!bServerSide && ClientRocketsLoaded > NumRockets) {
						V4Log("[CLI] Clamp primary loaded "$ClientRocketsLoaded$" -> "$NumRockets$" Time="$Level.TimeSeconds);
						ClientRocketsLoaded = NumRockets;
					}
		V4CachedChargeData = NumRockets;

		if (!bServerSide)
			V4EnsureClientLoadState(false);

		bBudgetLimitReached = NumRockets >= V4InternalBudget;
		if (bV4SuppressPrimaryFirstBudgetAuto
			&& bBudgetLimitReached
			&& NumRockets <= 1
			&& V4LoadStartTS > 0.0
			&& (StepTS - V4LoadStartTS) < GetV4ChargeInterval()) {
			if (V4ShouldDebug())
				V4Log("[PRI] Suppress early budget auto cycle="$V4PrimaryCycleId$" budget="$V4InternalBudget$" elapsed="$(StepTS - V4LoadStartTS)$" Time="$Level.TimeSeconds);
			bBudgetLimitReached = false;
		}
		if (V4InternalBudget > 1 || NumRockets > 1)
			bV4SuppressPrimaryFirstBudgetAuto = false;

		if (NumRockets >= 6 || bBudgetLimitReached) {
			if (NumRockets >= 6)
				PrimaryEndReason = IGPLUS_EB_PRIMARY_END_AUTO_6;
			else
				PrimaryEndReason = IGPLUS_EB_PRIMARY_END_AUTO_BUDGET;
			V4PrimaryLastEndReason = PrimaryEndReason;
			if (bServerSide) {
				HandleV4ServerFire(StepView, StepLoc, NumRockets, bAltHeld);
				V4PrimarySendServerConfirm(NumRockets, PrimaryEndReason, StepTS);
			} else {
				V4PrimaryRecordPrediction(NumRockets, PrimaryEndReason);
				HandleV4ClientLoadedFire(false, NumRockets, bAltHeld);
			}
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			bV4WasFireHeld = false;
			V4ResetPrimaryCycle(false);
		}
		return true;
	}

	if (!bFireHeld && bV4WasFireHeld) {
		if (bV4PrimaryCycleActive) {
			if (!bV4PrimaryReleasePending) {
				bV4PrimaryReleasePending = true;
				V4PrimaryReleasePendingTS = StepTS;
				if (V4ShouldDebug())
					V4Log("[PRI] Pending release cycle="$V4PrimaryCycleId$" elapsed="$(StepTS - V4LoadStartTS)$" Time="$Level.TimeSeconds);
				if (!bServerSide)
					V4EnsureClientLoadState(false);
				return true;
			}
				if ((StepTS - V4PrimaryReleasePendingTS) < IGPLUS_EB_PRIMARY_RELEASE_DEBOUNCE)
					return true;
			}

			bV4WasFireHeld = false;
			if (bV4PrimaryCycleActive) {
				NumRockets = V4CalculateCharge(StepTS);
				V4PrimaryLastEndReason = IGPLUS_EB_PRIMARY_END_RELEASE;
				if (bServerSide) {
					HandleV4ServerFire(StepView, StepLoc, NumRockets, bAltHeld);
					V4PrimarySendServerConfirm(NumRockets, IGPLUS_EB_PRIMARY_END_RELEASE, StepTS);
			} else {
				V4PrimaryRecordPrediction(NumRockets, IGPLUS_EB_PRIMARY_END_RELEASE);
				HandleV4ClientLoadedFire(false, NumRockets, bAltHeld);
			}
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
		}
		V4ResetPrimaryCycle(false);
		return true;
	}

	// ── ALT FIRE (GRENADES) ──
	if (bAltHeld && !bV4WasAltHeld) {
		V4LoadStartTS = StepTS;
		V4CachedChargeData = 1;
		if (!bServerSide) {
			// Mirror primary: deterministic cycle owns initial consume.
			V4ResetClientAmmoTracking();
			V4ConsumeClientAmmo(1, "AltStartCycle initial");
			V4EnsureClientLoadState(true);
		}
		bV4WasAltHeld = true;
		return true;
	}

		if (bAltHeld && bV4WasAltHeld) {
			NumRockets = V4CalculateCharge(StepTS);
			if (!bServerSide && ClientRocketsLoaded > NumRockets) {
				V4Log("[CLI] Clamp alt loaded "$ClientRocketsLoaded$" -> "$NumRockets$" Time="$Level.TimeSeconds);
				ClientRocketsLoaded = NumRockets;
			}
		V4CachedChargeData = NumRockets;
		
		if (!bServerSide) {
			V4EnsureClientLoadState(true);
		}

		bBudgetLimitReached = NumRockets >= V4InternalBudget;
		if (bBudgetLimitReached && NumRockets <= 1 && (StepTS - V4LoadStartTS) < GetV4ChargeInterval())
			bBudgetLimitReached = false;

		if (NumRockets >= 6 || bBudgetLimitReached) {
			if (bServerSide) HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
			else HandleV4ClientLoadedFire(true, NumRockets, false);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			bV4WasAltHeld = false;
			bV4SuppressAltFirstBudgetAuto = false;
		}

		return true;
	}

	if (!bAltHeld && bV4WasAltHeld) {
		if (bV4SuppressAltFirstBudgetAuto
			&& V4LoadStartTS > 0.0
			&& (StepTS - V4LoadStartTS) < IGPLUS_EB_RELEASE_DEBOUNCE) {
			if (!bServerSide)
				V4EnsureClientLoadState(true);
			return true;
		}
		bV4WasAltHeld = false;
		bV4SuppressAltFirstBudgetAuto = false;
		NumRockets = V4CalculateCharge(StepTS);
		if (bServerSide) HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
		else HandleV4ClientLoadedFire(true, NumRockets, false);
		NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
		return true;
	}

	return true;
}

simulated function V4EmitClientAuthoritativeShot(int NumRockets) {
	local bbPlayer bbP;
	local Pawn PawnOwner;
	local int ShotKind;

	if (Role == ROLE_Authority)
		return;
	if (!IsV4Active() || !UsesServerMoveV4())
		return;

	bbP = bbPlayer(Owner);
	PawnOwner = Pawn(Owner);
	if (bbP == none || PawnOwner == none || NumRockets <= 0)
		return;

	if (NumRockets >= 6)
		ShotKind = IGPLUS_EB_SHOT_KIND_ALT_AUTO6;
	else
		ShotKind = IGPLUS_EB_SHOT_KIND_ALT_RELEASE;

	bbP.IGPlus_QueueEightballAuthoritativeShot(
		ShotKind,
		Level.TimeSeconds,
		PawnOwner.ViewRotation,
		PawnOwner.Location,
		Clamp(NumRockets, 1, 6),
		false,
		false
	);

	if (bbP.bTraceInput)
		V4Log("[CLI-SHOT] emit kind="$ShotKind$" rockets="$Clamp(NumRockets, 1, 6)$" ts="$Level.TimeSeconds);
}

// Client-side instant rocket fire driven by V4ProcessStep.
// Plays the fire animation and spawns visual-only rockets, then the
// ClientV4InstantFire state handles the reload anim before going idle.
// V4ProcessStep calls this again when the next cooldown expires.
simulated function HandleV4ClientFire() {
	local bbPlayer bbP;

	if (IsV4Active())
		V4ConsumeClientAmmo(1, "HandleV4ClientFire instant");
	else if (AmmoType != None)
		AmmoType.AmmoAmount--;

	V4CachedChargeData = 1;
	ClientRocketsLoaded = 1;
	bFireLoad = true;
	PlayRFiring(0);
	bClientDone = true;
	bRotated = false;

	bbP = bbPlayer(Owner);
	if (bbP != None && IsPingCompEnabled()
		&& !bLockedOn && bbP.ClientWeaponSettingsData.bRocketUseClientSideAnimations)
		SpawnClientSideRockets(1);

	if (!IsInState('ClientV4InstantFire'))
		GotoState('ClientV4InstantFire');
}

// Client-side loaded rocket fire driven by V4ProcessStep's falling edge.
// Syncs ClientRocketsLoaded to the server's count before firing so both
// sides agree on the number of rockets/grenades spawned.
simulated function HandleV4ClientLoadedFire(bool bAlt, int NumRockets, optional bool bTight) {
	if (bAlt && V4HasSwitchAwayRequest()) {
		V4CancelDeterministicLoad(Level.TimeSeconds, false);
		return;
	}

	V4MaybePlayClientLoadCatchupSound(bAlt, NumRockets);

	if (bAlt)
		V4EmitClientAuthoritativeShot(NumRockets);

	V4FinalizeClientLoadedAmmo(NumRockets);

	ClientRocketsLoaded = NumRockets;
	V4CachedChargeData = NumRockets;

	// Use the same tightwad edge decision as the server step.
	bTightWad = !bAlt && bTight;

	V4Log("[CLI] V4LoadedFire alt="$bAlt$" rockets="$NumRockets$" tight="$bTightWad$" stepTight="$bTight$" Time="$Level.TimeSeconds);
	FiringRockets();
	bTightWad = false;
}

// Spawn rockets on the server using the deterministic data path in FireRockets.BeginState.
function HandleV4ServerFire(rotator StepView, vector StepLoc, int NumRockets, bool bTight) {
	local PlayerPawn P;

	P = PlayerPawn(Owner);
	if (P == none)
		return;

	V4Log("[SRV] HandleV4ServerFire rockets="$NumRockets$" tight="$bTight$" View="$StepView.Pitch$","$StepView.Yaw$" Loc="$int(StepLoc.X)$","$int(StepLoc.Y)$","$int(StepLoc.Z));

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
	if (NumRockets <= 0) {
		bUseV4ServerFireData = false;
		bTightWad = false;
		RocketsLoaded = 0;
		return;
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

// Spawn grenades on the server using deterministic step loc/view.
function HandleV4ServerAltFire(rotator StepView, vector StepLoc, int NumRockets) {
	local PlayerPawn P;

	P = PlayerPawn(Owner);
	if (P == none)
		return;

	V4Log("[SRV] HandleV4ServerAltFire grenades="$NumRockets$" View="$StepView.Pitch$","$StepView.Yaw$" Loc="$int(StepLoc.X)$","$int(StepLoc.Y)$","$int(StepLoc.Z));

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
	if (NumRockets <= 0) {
		bUseV4ServerFireData = false;
		bTightWad = false;
		RocketsLoaded = 0;
		return;
	}

	RocketsLoaded = NumRockets;
	bFireLoad = false;
	bTightWad = false;
	bCanClientFire = true;
	bPointing = true;

	if (NumRockets > 0) {
		if (P.PendingWeapon != none && P.PendingWeapon != self) {
			bChangeWeapon = true;
			bUseV4ServerFireData = false;
			bTightWad = false;
			RocketsLoaded = 0;
			return;
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
	V4BumpPrimaryWeaponEpoch("Finish");
	V4ResetAltCycle(true);

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
	if (IsV4Active() && UsesServerMoveV4()) {
		return;
	}
		
	Super.Fire(Value);
}

function AltFire( float Value )
{
	if (IsV4Active() && UsesServerMoveV4()) {
		return;
	}

	Super.AltFire(Value);
}

simulated function bool ClientFire( float Value )
{
	local Pawn PawnOwner;

	if (!bCanClientFire) {
		return false;
	}

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None) {
		return false;
	}

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
			// In ServerMove_v4 mode, primary load/fire is driven only by
			// deterministic step processing.
			if (IsV4Active() && UsesServerMoveV4()) {
				return true;
			}

			// Instant rockets: V4ProcessStep drives fire timing via
			// HandleV4ClientFire. Don't enter ClientFiring.
			if (IsV4Active() && bInstantRocket)
				return true;

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

	if (!bCanClientFire) {
		return false;
	}

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None) {
		return false;
	}

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
			// In ServerMove_v4 mode, alt load/fire is driven only by
			// deterministic step processing.
			if (IsV4Active() && UsesServerMoveV4()) {
				return true;
			}

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

simulated function FiringRockets()
{
	local bbPlayer bbP;
	local bool bAlt;

	if (IsInState('ClientAltFiring'))
		bAlt = true;
	else
		bAlt = false;

	if (Role < ROLE_Authority)
		V4Log("[CLI] FiringRockets: rockets="$ClientRocketsLoaded$" alt="$bAlt$" Time="$Level.TimeSeconds$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw);

	// NextV4FireTS is set by V4ProcessStep from StepTS (both sides).
	// No Level.TimeSeconds-based cooldown here.

	Super.FiringRockets();

	bbP = bbPlayer(Owner);
	if (Role < ROLE_Authority && bbP != None && IsPingCompEnabled())
	{
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

simulated function SpawnClientSideRockets(int NumRockets)
{
	local vector FireLocation, StartLoc, X,Y,Z;
	local rotator FireRot, AimRot;
	local ST_RocketMk2 r;
	local float Angle, RocketRad;
	local pawn PawnOwner;
	local float Spread;
	local int i;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None) return;

	yModInit();

	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	
	StartLoc = Owner.Location + CDO + FireOffset.X * X + yMod * Y + FireOffset.Z * Z;
	if (bbPlayer(Owner) != None)
		StartLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	AimRot = PawnOwner.ViewRotation;

	Angle = 0;
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
			{
				bUseV4ServerFireData = false;
				bTightWad = false;
				RocketsLoaded = 0;
				V4ResetPrimaryCycle(false);
				V4ResetAltCycle(false);
				return;
			}
			
		PawnOwner = Pawn(Owner);
			if (PawnOwner == None)
			{
				bUseV4ServerFireData = false;
				bTightWad = false;
				RocketsLoaded = 0;
				V4ResetPrimaryCycle(false);
				V4ResetAltCycle(false);
				return;
			}
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

		if (bUseStepFireData)
		{
			AimRot = V4ServerFireRot;
			StartLoc = V4ServerFireLoc + CalcDrawOffset();
			GetAxes(AimRot, X, Y, Z);
			StartLoc = StartLoc + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
			AdjustedAim = AimRot;
		}
		else
		{
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
			else
			{
				g = Spawn(class'ST_UT_Grenade',, '', FireLocation, AdjustedAim);
				g.WImp = WImp;
				g.NumExtraGrenades = DupRockets;
				
				if (DupRockets > 0)
				{
					RandRot.Pitch = FRand() * 1500 - 750;
					RandRot.Yaw = FRand() * 1500 - 750;
					RandRot.Roll = FRand() * 1500 - 750;
					g.Velocity = g.Velocity >> RandRot;
				}

				SpawnedRockets[NumSpawnedRockets] = g;
				NumSpawnedRockets++;
			}

			Angle += 1.04719755;
		}
		
		RocketsLoaded = 0;

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
		if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
		{
			LockedTarget = None;
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
{
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( IsA(PlayerPawn(Other).WeaponPriority[i]) )
			{
				AutoSwitchPriority = i;
				return;
			}
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

state Active
{
Begin:
	FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	bWeaponUp = True;
	PlayPostSelect();
	FinishAnim();
	if (UsesServerMoveV4() && (Pawn(Owner).bFire != 0 || Pawn(Owner).bAltFire != 0)) {
		// Suppress eager auto-fire when weapon comes up deterministic style
		GotoState('Idle');
	} else {
		Finish(); // Triggers global Fire block implicitly based on triggers
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
	if (UsesServerMoveV4()) {
		if (Pawn(Owner) != none && Pawn(Owner).bFire != 0) bPointing = true;
		if (Pawn(Owner) != none && Pawn(Owner).bAltFire != 0) bPointing = true;
	} else {
		if (Pawn(Owner).bFire!=0) Fire(0.0);
		if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
	}
	bPointing=False;
	if (AmmoType.AmmoAmount<=0) 
		Pawn(Owner).SwitchToBestWeapon();
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
	V4BumpPrimaryWeaponEpoch("PlaySelect");
	V4InvalidateMoveInstantMode();
	V4ResetPrimaryCycle(true);
	V4ResetAltCycle(true);
	if (Pawn(Owner) != none) {
		if (Pawn(Owner).bFire != 0 && !V4OwnerInstantEnabled())
			bV4SuppressPrimaryFirstBudgetAuto = true;
		if (Pawn(Owner).bAltFire != 0)
			bV4SuppressAltFirstBudgetAuto = true;
	}
	bTightWad = false;
	V4CachedChargeData = 0;
	ClientRocketsLoaded = 0;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().EightballSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	V4BumpPrimaryWeaponEpoch("TweenDown");
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
	local bool bProxyToServer;

	if (Owner == None)
		return;
	
	// Match base UT_Eightball cadence: honor caller-supplied load rate.
	PlayAnim(LoadAnim[num], rate, 0.05);
	
	// In deterministic mode, owner always plays local load/rotate sounds.
	// Keep server proxy only for legacy non-deterministic path.
	bProxyToServer = (
		Role < ROLE_Authority
		&& IsPingCompEnabled()
		&& !IsV4Active()
		&& !UsesServerMoveV4()
		&& PlayerPawn(Owner) != None
	);
	if (bProxyToServer)
		ServerPlayLoadSound(num, false);

	// Always play locally for the owning client.
	Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

simulated function PlayRotating(int num)
{
	local bool bProxyToServer;

	if (Owner == None)
		return;
	
	PlayAnim(RotateAnim[num],, 0.05);
	
	// In deterministic mode, owner always plays local load/rotate sounds.
	// Keep server proxy only for legacy non-deterministic path.
	bProxyToServer = (
		Role < ROLE_Authority
		&& IsPingCompEnabled()
		&& !IsV4Active()
		&& !UsesServerMoveV4()
		&& PlayerPawn(Owner) != None
	);
	if (bProxyToServer)
		ServerPlayLoadSound(num, true);

	// Always play locally for the owning client.
	Owner.PlayOwnedSound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
}

// =========================================================================
// Client State Management
// =========================================================================

// Lightweight state for instant rocket V4 fire+reload animation cycle.
// V4ProcessStep drives fire timing via HandleV4ClientFire; this state
// just sequences fire anim → reload anim → idle.
state ClientV4InstantFire
{
	simulated function bool ClientFire(float Value) { return true; }
	simulated function bool ClientAltFire(float Value) { return false; }

		simulated function AnimEnd()
		{
			if (bClientDone) {
				PlayLoading(1.5, 0);
				bClientDone = false;
				return;
		}
		PlayIdleAnim();
		GotoState('');
	}

	simulated function EndState()
	{
		bClientDone = false;
		bRotated = false;
	}
}

state ClientFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if (P == none)
			return;

		if (IsV4Active()) {
			V4CachedChargeData = Clamp(Max(ClientRocketsLoaded, V4PrimaryPredictedLoaded), 0, 7);
			return;
		}

		if ((P.bFire == 0) || (AmmoType == none) || (AmmoType.AmmoAmount <= 0)) {
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			V4Log("[CLI] Tick: release fire, rockets="$ClientRocketsLoaded$" V4Cached="$V4CachedChargeData$" Time="$Level.TimeSeconds);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		local int TargetLoaded;
		local int ConsumeDelta;

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
				PlayLoading(1.1, ClientRocketsLoaded);
				bRotated = false;
				if (IsV4Active()) {
					TargetLoaded = Clamp(
						V4PrimaryPredictedLoaded,
						1,
						Min(6, Max(1, V4PrimaryCycleStartBudget))
					);
					if (ClientRocketsLoaded > TargetLoaded) {
						ClientRocketsLoaded = TargetLoaded;
					} else if (TargetLoaded > ClientRocketsLoaded) {
						ConsumeDelta = TargetLoaded - ClientRocketsLoaded;
					if (!V4ConsumeClientAmmo(ConsumeDelta, "ClientFiring.AnimEnd.sync-up"))
						return;
					ClientRocketsLoaded = TargetLoaded;
				}
			} else {
				ClientRocketsLoaded++;
			}
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
		}
			else
			{
				V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
				if ( bInstantRocket || (ClientRocketsLoaded == 6) )
			{
				if (IsV4Active()) {
					V4Log("[CLI] AnimEnd: auto-fire (V4 pending) rockets="$ClientRocketsLoaded$" Time="$Level.TimeSeconds);
					return;
				}
					FiringRockets();
					return;
				}
					if (IsV4Active()) {
						if (ClientRocketsLoaded >= Min(6, Max(1, V4PrimaryCycleStartBudget)))
							return;
					}
				Enable('Tick');
				PlayRotating(ClientRocketsLoaded - 1);
				bRotated = true;
		if (!IsV4Active() && AmmoType != None)
			AmmoType.AmmoAmount--;
		}
	}

	simulated function BeginState()
	{
		bFireLoad = true;
		
		V4Log("[CLI] ClientFiring.Begin instant="$bInstantRocket$" Time="$Level.TimeSeconds$" View="$Pawn(Owner).ViewRotation.Pitch$","$Pawn(Owner).ViewRotation.Yaw);

		// Instant V4: HandleV4ClientFire drives fire, not ClientFiring.
		if (bInstantRocket && IsV4Active()) {
			GotoState('');
			return;
		}

		if (Role < ROLE_Authority && IsPingCompEnabled() && !UsesServerMoveV4())
			ServerStartedLoading();

		if (!IsV4Active() && AmmoType != None)
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
		V4CachedChargeData = 0;
		ClientRocketsLoaded = 0;
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
		local Pawn P;

		P = Pawn(Owner);
		if (P == none)
			return;

		if (IsV4Active()) {
			if (P.bAltFire == 0)
				V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			return;
		}

		if ((P.bAltFire == 0) || (AmmoType == none) || (AmmoType.AmmoAmount <= 0)) {
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		local int TargetLoaded;
		local int ConsumeDelta;

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
			if (IsV4Active()) {
				V4RefreshInternalBudget();
				TargetLoaded = Clamp(
					V4CachedChargeData,
					1,
					Min(6, Max(1, V4InternalBudget))
				);
				if (ClientRocketsLoaded > TargetLoaded) {
					ClientRocketsLoaded = TargetLoaded;
				} else if (TargetLoaded > ClientRocketsLoaded) {
					ConsumeDelta = TargetLoaded - ClientRocketsLoaded;
					if (!V4ConsumeClientAmmo(ConsumeDelta, "ClientAltFiring.AnimEnd.sync-up"))
						return;
					ClientRocketsLoaded = TargetLoaded;
				}
			} else {
				ClientRocketsLoaded++;
			}
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
		}
			else
			{
				V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
				if ( ClientRocketsLoaded == 6 )
			{
				if (IsV4Active())
					return;
					FiringRockets();
					return;
				}
				if (IsV4Active()) {
					V4RefreshInternalBudget();
					if (ClientRocketsLoaded >= Min(6, Max(1, V4InternalBudget)))
						return;
				}
				Enable('Tick');
				PlayRotating(ClientRocketsLoaded - 1);
				bRotated = true;
			if (!IsV4Active() && AmmoType != None)
				AmmoType.AmmoAmount--;
		}
	}

	simulated function BeginState()
	{
		bFireLoad = false;
		
		if (Role < ROLE_Authority && IsPingCompEnabled() && !UsesServerMoveV4())
			ServerStartedLoading();
			
		if (!IsV4Active() && AmmoType != None)
			AmmoType.AmmoAmount--;

		ClientRocketsLoaded = 1;
		V4CachedChargeData = 1;
		PlayRotating(ClientRocketsLoaded - 1);
		bRotated = true;
	}

	simulated function EndState()
	{
		V4CachedChargeData = 0;
		ClientRocketsLoaded = 0;
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

	simulated function Tick(float DeltaTime)
	{
		if (!bForceFire && (Pawn(Owner) == None || Pawn(Owner).bFire == 0)
			&& !bForceAltFire && (Pawn(Owner) == None || Pawn(Owner).bAltFire == 0))
		{
			Disable('Tick');
			GotoState('');
			return;
		}

		if (Level.TimeSeconds >= NextV4FireTS) {
			Disable('Tick');
			if (bForceFire || (Pawn(Owner) != None && Pawn(Owner).bFire != 0)) {
				if (IsV4Active()) {
					V4Log("[CLI] Reload.Tick: primary pending deterministic step Time="$Level.TimeSeconds);
					return;
				}
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
					if (IsV4Active() && Level.TimeSeconds + 0.001 < NextV4FireTS) {
						V4Log("[CLI] Reload.AnimEnd: waiting for cooldown, need="$(NextV4FireTS - Level.TimeSeconds)$"s Time="$Level.TimeSeconds);
						Enable('Tick');
						return;
					}
					if (IsV4Active()) {
						V4Log("[CLI] Reload.AnimEnd: primary pending deterministic step Time="$Level.TimeSeconds);
						GotoState('');
						return;
					}
					V4Log("[CLI] Reload.AnimEnd: re-fire Time="$Level.TimeSeconds);
					Global.ClientFire(0);
					return;
				}
			else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			{
				if (IsV4Active() && Level.TimeSeconds + 0.001 < NextV4FireTS) {
					V4Log("[CLI] Reload.AnimEnd: waiting for cooldown, need="$(NextV4FireTS - Level.TimeSeconds)$"s Time="$Level.TimeSeconds);
					Enable('Tick');
					return;
				}
				V4Log("[CLI] Reload.AnimEnd: re-altfire Time="$Level.TimeSeconds);
				Global.ClientAltFire(0);
				return;
			}
		}
		
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

state DownWeapon
{
	function BeginState()
	{
		V4BumpPrimaryWeaponEpoch("DownWeapon");
		Super.BeginState();
	}
}

state ClientDown
{
	simulated function BeginState()
	{
		V4BumpPrimaryWeaponEpoch("ClientDown");
		Super.BeginState();
	}
}

defaultproperties {
}
