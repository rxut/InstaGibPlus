// ===============================================================
// Stats.ST_UT_Eightball
// Det deterministic fire for Eightball rocket launcher.
// Edge-only design: server spawns rockets from rising/falling edge
// detection in steps; client runs the same edge logic as a
// shared duration-based controller while the legacy
// ClientFiring state machine handles animations.
// ===============================================================

class ST_UT_Eightball extends UT_Eightball;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

// Server-side deterministic fire data (from ServerMove_v4 step)
var vector DetServerFireLoc;
var rotator DetServerFireRot;
var bool bUseDetServerFireData;

// Det deterministic fire — shared between client and server
var float DetCooldownRemaining;
var float DetPrimaryLoadElapsed;
var float DetAltLoadElapsed;
var float DetLastStepTS;
var float DetLastStepDelta;
var bool bDetWasFireHeld;
var bool bDetWasAltHeld;
var int DetCachedChargeData;
var bool bDetPendingAltHeld;
var bool bDetPendingAltTap;
// Stock ForceFire parity (bJustFired): a tap that lands inside the post-fire
// cooldown banks here and replays as a force edge on the first free slice.
var bool bDetCooldownFireTap;
var bool bDetCooldownAltTap;

// Client ammo consumption reconstruction logic
var int DetClientConsumedAmmo;
var int DetClientAmmoSpentSinceDown;
var float DetClientLastDownTS;
var int DetInternalBudget;
var bool bDetSuppressPrimaryFirstBudgetAuto;

// Primary deterministic cycle controller (server-authoritative, client-predicted)
var int DetPrimaryCycleId;
var bool bDetPrimaryCycleActive;
var int DetPrimaryCycleStartBudget;
var int DetPrimaryPredictedLoaded;
var bool bDetPrimaryLatchedInstant;
var int DetPrimaryLastPredictedCycleId;
var int DetPrimaryLastPredictedRockets;
var bool bDetPrimaryLastPredictedInstant;
var bool bDetPrimaryLastPredictedAuto;
var bool bDetPrimaryTightLatched;
var int DetServerShotSerial;
var int DetServerLastShotKind;
var bool bDetSwitchSettlementPending;

const IGPLUS_EB_SHOT_KIND_ALT = 0;
const IGPLUS_EB_SHOT_KIND_PRIMARY_LOADED = 1;
const IGPLUS_EB_SHOT_KIND_PRIMARY_INSTANT = 2;

simulated function bool DetOwnerInstantEnabled() {
	local TournamentPlayer TP;

	if (bAlwaysInstant)
		return true;

	TP = TournamentPlayer(Owner);
	if (TP != none)
		return TP.bInstantRocket;

	return bInstantRocket;
}

simulated function bool DetShouldBypassLegacyClientInput() {
	bInstantRocket = DetOwnerInstantEnabled();
	// Client prediction runs whenever the deterministic system is active,
	// on both the v4 and fallback transports — legacy input must stand down.
	return IsDetActive();
}

function DetClearPendingServerFireState() {
	bUseDetServerFireData = false;
	bTightWad = false;
	RocketsLoaded = 0;
}

function DetResetFireRocketsState() {
	DetClearPendingServerFireState();
	DetResetPrimaryCycle(false);
	DetResetAltCycle(false);
}

function bool DetPrepareServerFireContext(
	rotator StepView,
	vector StepLoc,
	out int NumRockets,
	out PlayerPawn P
) {
	P = PlayerPawn(Owner);
	if (P == none)
		return false;

	DetServerFireLoc = StepLoc;
	if (bbPlayer(Owner) != none)
		DetServerFireLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	DetServerFireRot = StepView;
	bUseDetServerFireData = true;

	if (AmmoType == none)
		GiveAmmo(P);
	if (AmmoType != none) {
		if (AmmoType.AmmoAmount < NumRockets)
			NumRockets = AmmoType.AmmoAmount;
		AmmoType.UseAmmo(NumRockets);
	}

	if (NumRockets <= 0) {
		DetClearPendingServerFireState();
		return false;
	}

	return true;
}

function DetArmServerFireState(int NumRockets, bool bPrimary, optional bool bTight) {
	RocketsLoaded = NumRockets;
	bFireLoad = bPrimary;
	bTightWad = bPrimary && bTight;
	if (bPrimary)
		bInstantRocket = bDetPrimaryLatchedInstant;

	bCanClientFire = true;
	bPointing = true;
}

simulated function DetResetClientAmmoTracking() {
	if (Role == ROLE_Authority)
		return;
	DetClientConsumedAmmo = 0;
}

simulated function DetResetPrimaryCycle(optional bool bClearHeld) {
	if (bClearHeld) {
		bDetWasFireHeld = false;
	}
	bDetSuppressPrimaryFirstBudgetAuto = false;
	bDetPrimaryCycleActive = false;
	DetPrimaryCycleStartBudget = 0;
	DetPrimaryPredictedLoaded = 0;
	bDetPrimaryLatchedInstant = false;
	bDetPrimaryTightLatched = false;
	DetPrimaryLoadElapsed = 0.0;
	DetResetClientAmmoTracking();
}

simulated function DetResetAltCycle(optional bool bClearHeld) {
	if (bClearHeld) {
		bDetWasAltHeld = false;
	}
	DetAltLoadElapsed = 0.0;
	DetResetClientAmmoTracking();
}

simulated function DetClearPendingAltInput() {
	bDetPendingAltHeld = false;
	bDetPendingAltTap = false;
	bDetCooldownFireTap = false;
	bDetCooldownAltTap = false;
}

// Preserve an honest AltFire tap that reaches the server after the bring-up
// gate but before ChangedWeapon equips Eightball. Nothing may fire while pending.
function bool DetTrackPendingAltInput(
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt
) {
	if (bFireHeld || bForceFire)
		return false;
	if (bForceAlt) {
		bDetPendingAltHeld = false;
		bDetPendingAltTap = true;
		return true;
	}
	if (bAltHeld) {
		bDetPendingAltHeld = true;
		return true;
	}
	if (bDetPendingAltHeld) {
		bDetPendingAltHeld = false;
		bDetPendingAltTap = true;
		return true;
	}
	return bDetPendingAltTap;
}

simulated function DetRefreshInternalBudget() {
	if (AmmoType == none) {
		DetInternalBudget = 0;
		return;
	}

	// Keep budget stable for the whole primary cycle. This mirrors the
	// server's deterministic load budget even if replicated ammo updates
	// arrive while client-side load animations are running.
	if (bDetPrimaryCycleActive && DetPrimaryCycleStartBudget > 0) {
		DetInternalBudget = DetPrimaryCycleStartBudget;
		return;
	}

	DetInternalBudget = AmmoType.AmmoAmount;
}

simulated function DetPrimaryStartCycle(bool bMoveInstant, bool bServerSide) {
	DetPrimaryCycleId = (DetPrimaryCycleId + 1) & 255;
	DetPrimaryCycleStartBudget = Max(1, DetInternalBudget);
	DetPrimaryPredictedLoaded = 1;
	bDetPrimaryLatchedInstant = bMoveInstant;
	bDetPrimaryTightLatched = false;
	bDetSuppressPrimaryFirstBudgetAuto = (DetPrimaryCycleStartBudget <= 1);

	bInstantRocket = bDetPrimaryLatchedInstant;
	bDetPrimaryCycleActive = !bDetPrimaryLatchedInstant;
	DetPrimaryLoadElapsed = 0.0;
	if (bDetPrimaryCycleActive && !bServerSide) {
		// Deterministic primary cycle owns the first-rocket consume; reset
		// tracking first so finalize doesn't synthesize an extra consume.
		DetResetClientAmmoTracking();
		DetConsumeClientAmmo(1);
	}
}

simulated function DetPrimaryRecordPrediction(int NumRockets, bool bAutoEnded) {
	DetPrimaryLastPredictedCycleId = DetPrimaryCycleId;
	DetPrimaryLastPredictedRockets = Clamp(NumRockets, 1, 6);
	bDetPrimaryLastPredictedInstant = bDetPrimaryLatchedInstant;
	bDetPrimaryLastPredictedAuto = bAutoEnded;
	DetPrimaryPredictedLoaded = DetPrimaryLastPredictedRockets;
}

simulated function DetPrimarySendServerConfirm(int NumRockets, bool bAutoEnded) {
	if (Role != ROLE_Authority)
		return;

	ClientDetPrimaryShotConfirm(
		byte(DetPrimaryCycleId),
		byte(Clamp(NumRockets, 1, 6)),
		bAutoEnded,
		bDetPrimaryLatchedInstant
	);
}

simulated function ClientDetPrimaryShotConfirm(
	byte CycleId,
	byte Rockets,
	bool bAutoEnded,
	bool bInstant
) {
	local int ConfirmedRockets;
	local bool bMismatch;

	if (Role == ROLE_Authority)
		return;
	if (!IsDetActive())
		return;

	ConfirmedRockets = Clamp(int(Rockets), 1, 6);

	// Ignore confirms for a finished cycle once a newer primary cycle is
	// already loading. Applying those confirms here would reset local ammo
	// tracking mid-load and can cause an extra client-side consume.
	if (bDetPrimaryCycleActive && int(CycleId) != DetPrimaryCycleId)
		return;

	bMismatch = DetPrimaryLastPredictedCycleId != int(CycleId)
		|| DetPrimaryLastPredictedRockets != ConfirmedRockets
		|| bDetPrimaryLastPredictedInstant != bInstant
		|| bDetPrimaryLastPredictedAuto != bAutoEnded;

	// Base UT behavior: client HUD ammo follows replicated server ammo.
	// Do not mutate client ammo here for primary confirm.
	DetResetClientAmmoTracking();

	bDetPrimaryLatchedInstant = bInstant;
	DetPrimaryPredictedLoaded = ConfirmedRockets;
	DetCachedChargeData = ConfirmedRockets;
	ClientRocketsLoaded = ConfirmedRockets;
	if (bDetPrimaryCycleActive) {
		bDetPrimaryCycleActive = false;
		DetPrimaryLoadElapsed = 0.0;
	}

	// Snap to post-fire path when client prediction drifted from authoritative shot.
	if (bMismatch && IsInState('ClientFiring')) {
		bClientDone = true;
		bRotated = false;
	}
}

simulated function DetApplyClientAmmoRefund(int ServerAmmo) {
	local int RefundFloor;

	if (Role == ROLE_Authority || AmmoType == none)
		return;

	// This correction follows ClientPutDown on the owning player's reliable
	// channel. Only refund missing ammo; never overwrite a newer pickup or shot.
	RefundFloor = Max(0, ServerAmmo - DetClientAmmoSpentSinceDown);
	AmmoType.AmmoAmount = Max(AmmoType.AmmoAmount, RefundFloor);
}

simulated function int DetGetChargeDataForMove() {
	local int Charge;
	Charge = Clamp(DetCachedChargeData, 0, 7);
	if ((IsInState('ClientFiring') || IsInState('ClientAltFiring')) && ClientRocketsLoaded > Charge)
		Charge = Clamp(ClientRocketsLoaded, 0, 7);
	return Charge;
}

simulated function bool DetConsumeClientAmmo(int Amount) {
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
	DetClientConsumedAmmo += ActualAmount;
	DetClientAmmoSpentSinceDown += ActualAmount;
	return true;
}

// Client load animation can be one rocket behind local ammo consumption at
// the exact deterministic fire step. Snap consumption at fire-time so ammo
// HUD and fire SFX timing stay aligned.
simulated function DetFinalizeClientLoadedAmmo(int NumRockets) {
	local int Missing;

	if (Role == ROLE_Authority || !IsDetActive())
		return;

	Missing = Clamp(NumRockets - DetClientConsumedAmmo, 0, 6);
	if (Missing > 0)
		DetConsumeClientAmmo(Missing);
}

simulated function DetEnsureClientLoadState(bool bAltLoad) {
	if (Role == ROLE_Authority || !IsDetActive())
		return;
	if (!bCanClientFire || Pawn(Owner) == none)
		return;

	if (bAltLoad) {
		if (!IsInState('ClientAltFiring'))
			GotoState('ClientAltFiring');
		return;
	}

	if (!IsInState('ClientFiring'))
		GotoState('ClientFiring');
}

replication
{
	// Reliable: a lost confirm leaves predicted load state stale.
	reliable if(Role == ROLE_Authority)
		ClientDetPrimaryShotConfirm;
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

simulated function bool IsDetActive() {
	if (Level != none && Level.NetMode == NM_Standalone)
		return false;
	if (!IsPingCompEnabled())
		return false;
	if (bbPlayer(Owner) == none)
		return false;
	return true;
}

// True only when the v4 move transport carries weapon data (edge timelines,
// shot packs). Currently off: movement rides the proven v3 ServerMove and the
// deterministic weapons run whole-move dispatch, so packs have no carrier.
simulated function bool DetHasSwitchAwayRequest() {
	return bbPlayer(Owner) != none && bbPlayer(Owner).IGPlus_DetSwitchAwayFrom(self);
}

simulated function bool DetHasCommittedPrimary() {
	return bDetPrimaryCycleActive || bDetWasFireHeld;
}

simulated function DetCancelDeterministicLoad(bool bServerSide, optional int MoveChargeData) {
	local int CancelCount;
	local bbPlayer bbP;
	local bool bHadCommittedState;

	// A settlement with nothing committed has nothing to charge or refund;
	// skip the reliable refund RPC that would otherwise fire on every switch.
	bHadCommittedState = bDetPrimaryCycleActive || bDetWasFireHeld || bDetWasAltHeld
		|| DetCachedChargeData > 0 || ClientRocketsLoaded > 0;

	if (bServerSide && AmmoType != none && AmmoType.AmmoAmount > 0) {
		if (bDetPrimaryCycleActive || bDetWasFireHeld) {
			CancelCount = Clamp(DetResolvePrimaryEdgeCharge(MoveChargeData), 1, 6);
			AmmoType.UseAmmo(Min(CancelCount, AmmoType.AmmoAmount));
		} else if (bDetWasAltHeld) {
			// Base UT style: consume what is currently loaded, not a
			// time-recomputed charge that can overshoot on switch.
			CancelCount = 1;
			if (DetCachedChargeData > 0)
				CancelCount = Clamp(DetCachedChargeData, 1, 6);
			else if (ClientRocketsLoaded > 0)
				CancelCount = Clamp(ClientRocketsLoaded, 1, 6);
			AmmoType.UseAmmo(Min(CancelCount, AmmoType.AmmoAmount));
		}
	}

	DetClearPendingServerFireState();
	DetCachedChargeData = 0;
	ClientRocketsLoaded = 0;
	bClientDone = false;
	bDetCooldownFireTap = false;
	bDetCooldownAltTap = false;
	bRotated = false;
	bForceFire = false;
	bForceAltFire = false;
	DetResetPrimaryCycle(true);
	DetResetAltCycle(true);
	DetClearPendingAltInput();
	bDetSwitchSettlementPending = false;
	if (bServerSide && AmmoType != none && bHadCommittedState) {
		bbP = bbPlayer(Owner);
		if (bbP != none)
			bbP.IGPlus_ClientEightballAmmoRefund(self, AmmoType.AmmoAmount);
	}

	if (!bServerSide && (IsInState('ClientFiring') || IsInState('ClientAltFiring') || IsInState('ClientReload')))
		GotoState('');
}

function DetFinalizeSwitchSettlement() {
	if (Role != ROLE_Authority || !bDetSwitchSettlementPending)
		return;

	DetCancelDeterministicLoad(true, DetGetChargeDataForMove());
}



function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;
}

// =========================================================================
// Det Deterministic Fire — Primary + Alt (Rockets + Grenades)
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
simulated function float DetPostFireInterval(int NumRockets) {
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

simulated function DetAdvanceStepClock(float StepTS) {
	local float StepDelta;

	DetLastStepDelta = 0.0;

	if (DetLastStepTS < 0.0) {
		DetLastStepTS = StepTS;
		return;
	}

	StepDelta = StepTS - DetLastStepTS;
	if (StepDelta < -0.001) {
		DetLastStepTS = StepTS;
		return;
	}

	DetLastStepTS = StepTS;

	StepDelta = FMax(StepDelta, 0.0);
	DetLastStepDelta = StepDelta;

	DetCooldownRemaining = FMax(0.0, DetCooldownRemaining - StepDelta);

	if (bDetPrimaryCycleActive)
		DetPrimaryLoadElapsed += StepDelta;
	if (bDetWasAltHeld)
		DetAltLoadElapsed += StepDelta;
}

simulated function DetStartCooldown(float Interval) {
	DetCooldownRemaining = FMax(0.0, Interval);
}

simulated function DetPlayServerChargeSound(bool bRotate) {
	if (Role != ROLE_Authority || Owner == none || Pawn(Owner) == none)
		return;

	if (bRotate)
		Owner.PlayOwnedSound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
	else
		Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

// DetProcessStep runs on both sides: the server spawns authoritative
// rockets; the client tracks edges/clocks and drives animation states only.
const DetChargeInterval = 0.9;

simulated function int DetCalculateCharge(float LoadElapsed) {
	DetRefreshInternalBudget();
	return Min(Clamp(1 + int(LoadElapsed / DetChargeInterval), 1, 6), Max(1, DetInternalBudget));
}

simulated function int DetResolvePrimaryEdgeCharge(optional int MoveChargeData) {
	local int BudgetLimit;
	local int NumRockets;
	local int MoveCharge;
	local int TimeAllowedCharge;

	NumRockets = DetCalculateCharge(DetPrimaryLoadElapsed);
	BudgetLimit = Max(1, DetInternalBudget);
	MoveCharge = Clamp(MoveChargeData, 0, 6);

	// Client report may only lower the count; step-sized slack so coarse
	// steps don't shave a rocket off an honest volley.
	TimeAllowedCharge = DetCalculateCharge(DetPrimaryLoadElapsed + FMax(0.06, DetLastStepDelta));
	if (MoveCharge > 0)
		return Min(Min(MoveCharge, TimeAllowedCharge), BudgetLimit);

	if (DetPrimaryPredictedLoaded > 0)
		NumRockets = Max(NumRockets, DetPrimaryPredictedLoaded);
	NumRockets = Min(NumRockets, TimeAllowedCharge);

	return Min(Clamp(NumRockets, 1, 6), BudgetLimit);
}

simulated function bool DetProcessStep(
	float StepTS,
	rotator StepView,
	vector StepLoc,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	bool bServerSide,
	optional bool bClientPredictedStep,
	optional int DetChargeData,
	optional bool bMoveInstantValid,
	optional bool bMoveInstantValue
) {
	local int NumRockets;
	local bool bMoveInstant;
	local bool bOwnerInstantSetting;
	local bool bBudgetLimitReached;

	DetAdvanceStepClock(StepTS);

	// Predicted steps were recorded before the client committed to the switch
	// (det-ready stamping stops the moment ClientPending is set), so they must
	// keep a live cycle alive: the release edge right behind them fires the
	// volley the client already predicted. Only unpredicted steps — or a fresh
	// force tap — prove the player is still holding through the switch.
	if (DetHasSwitchAwayRequest()
		&& (IsInState('ClientAltFiring')
			|| bDetPendingAltHeld || bDetPendingAltTap
			|| ((bDetWasAltHeld || bAltHeld || DetHasCommittedPrimary())
				&& (!bClientPredictedStep || bForceFire || bForceAlt)))) {
		DetCancelDeterministicLoad(bServerSide, DetChargeData);
		return true;
	}

	// Resolve input queued during the server's final pending-weapon window.
	if (bServerSide && Pawn(Owner) != none && Pawn(Owner).Weapon == self) {
		if (bDetPendingAltHeld) {
			if (bFireHeld || bForceFire) {
				// Stock precedence: a new primary press supersedes queued alt hold.
				bDetPendingAltHeld = false;
			} else if (!bAltHeld) {
				bDetPendingAltHeld = false;
				bDetPendingAltTap = true;
			} else {
				bDetPendingAltHeld = false;
				bClientPredictedStep = true;
			}
		}
		if (bDetPendingAltTap) {
			if (DetCooldownRemaining > 0.0001)
				return true;
			bDetPendingAltTap = false;
			DetCachedChargeData = 1;
			if (AmmoType != none && AmmoType.AmmoAmount > 0)
				DetPlayServerChargeSound(true);
			HandleDetServerAltFire(StepView, StepLoc, 1);
			DetStartCooldown(DetPostFireInterval(1));
			return true;
		}
	}

	// Committed state returns from the held/falling branches before the
	// rising edges, so unpredicted steps can only continue a cycle.
	if (!bClientPredictedStep && !bDetWasFireHeld && !bDetWasAltHeld) {
		return true;
	}

	if (bMoveInstantValid)
		bMoveInstant = bMoveInstantValue;
	else if (TournamentPlayer(Owner) != none)
		bMoveInstant = TournamentPlayer(Owner).bInstantRocket;
	else
		bMoveInstant = bInstantRocket;

	if (DetCooldownRemaining > 0.0001) {
		// Stock banks a press EVENT that lands during the reload leg (the
		// ClientReload ForceFire latch) and fires it at reload-end. Taps in
		// the fire-anim leg drop, and a held button banks nothing. The move
		// force bits carry exactly the press events (bJustFired), so bank on
		// those alone, only within the reload leg (0.05 tween + 0.4 Load1
		// anim). Primary press supersedes a banked alt, stock precedence.
		if (DetCooldownRemaining <= 0.45) {
			if (bForceFire) {
				bDetCooldownFireTap = true;
				bDetCooldownAltTap = false;
			} else if (bForceAlt)
				bDetCooldownAltTap = true;
		}
		return true;
	}

	// Replay a banked tap as a force edge; the rising edge starts the cycle
	// and, with the button already released, the next slice's falling edge
	// fires the single rocket/grenade — reload-end timing, like stock.
	if (bDetCooldownFireTap) {
		bDetCooldownFireTap = false;
		bDetCooldownAltTap = false;
		bForceFire = true;
	} else if (bDetCooldownAltTap) {
		bDetCooldownAltTap = false;
		bForceAlt = true;
	}

		if (AmmoType == none || AmmoType.AmmoAmount <= 0) {
			if (!bDetWasFireHeld && !bDetWasAltHeld) {
				if (bServerSide && (bFireHeld || bAltHeld) && Pawn(Owner) != none) {
					Pawn(Owner).StopFiring();
					if (Pawn(Owner).PendingWeapon == none || Pawn(Owner).PendingWeapon == self)
						Pawn(Owner).SwitchToBestWeapon();
				}
				DetResetPrimaryCycle(true);
				DetResetAltCycle(true);
				return true;
		}
	}

	bOwnerInstantSetting = DetOwnerInstantEnabled();

	// Never let a stale move flag force instant mode while the owner's
	// current setting says instant rockets are off.
	if (!bOwnerInstantSetting)
		bMoveInstant = false;

	// ── PRIMARY FIRE ──
	// Skip the rising edge while an alt (grenade) cycle is loading so the
	// alt branches below keep updating charge and can auto-fire at 6.
	// Stock precedence: primary wins a simultaneous idle edge.
	if ((bFireHeld || bForceFire) && !bDetWasFireHeld && !bDetWasAltHeld) {
		DetRefreshInternalBudget();
		DetPrimaryStartCycle(bMoveInstant, bServerSide);
		bDetWasFireHeld = true;
		if (bDetPrimaryLatchedInstant) {
			if (bServerSide) {
				HandleDetServerFire(StepView, StepLoc, 1, bAltHeld);
				DetPrimarySendServerConfirm(1, false);
			} else {
				DetPrimaryRecordPrediction(1, false);
				HandleDetClientFire();
			}
			DetStartCooldown(DetPostFireInterval(1));
			bDetWasFireHeld = false;
			DetResetPrimaryCycle(false);
		} else {
			if (bServerSide)
				DetPlayServerChargeSound(true);
			else
				DetEnsureClientLoadState(false);
		}
		return true;
	}

	if (bFireHeld && bDetWasFireHeld) {
		if (!bDetPrimaryCycleActive) {
			bDetWasFireHeld = false;
			return true;
		}

			NumRockets = DetCalculateCharge(DetPrimaryLoadElapsed);
			// Sample alt only on the step where a new rocket actually loads,
			// mirroring base UT99's per-AnimEnd sample so a brief tap doesn't latch.
			if (NumRockets > DetPrimaryPredictedLoaded && bAltHeld)
				bDetPrimaryTightLatched = true;
			if (bServerSide && NumRockets > DetPrimaryPredictedLoaded)
				DetPlayServerChargeSound(false);
			DetPrimaryPredictedLoaded = NumRockets;
			if (!bServerSide && ClientRocketsLoaded > NumRockets)
				ClientRocketsLoaded = NumRockets;
		DetCachedChargeData = NumRockets;

		if (!bServerSide)
			DetEnsureClientLoadState(false);

			bBudgetLimitReached = NumRockets >= DetInternalBudget;
			if (bDetSuppressPrimaryFirstBudgetAuto
				&& bBudgetLimitReached
				&& NumRockets <= 1
				&& DetPrimaryLoadElapsed < DetChargeInterval)
				bBudgetLimitReached = false;
		if (DetInternalBudget > 1 || NumRockets > 1)
			bDetSuppressPrimaryFirstBudgetAuto = false;

		if (NumRockets >= 6 || bBudgetLimitReached) {
			if (bServerSide) {
				HandleDetServerFire(StepView, StepLoc, NumRockets, bDetPrimaryTightLatched || bAltHeld);
				DetPrimarySendServerConfirm(NumRockets, true);
			} else {
				DetPrimaryRecordPrediction(NumRockets, true);
				HandleDetClientLoadedFire(false, NumRockets, bDetPrimaryTightLatched || bAltHeld);
			}
			DetStartCooldown(DetPostFireInterval(NumRockets));
			bDetWasFireHeld = false;
			DetResetPrimaryCycle(false);
		}
		return true;
	}

	if (!bFireHeld && bDetWasFireHeld) {
		bDetWasFireHeld = false;
		if (bDetPrimaryCycleActive) {
			NumRockets = DetResolvePrimaryEdgeCharge(DetChargeData);
			if (bServerSide && NumRockets > DetPrimaryPredictedLoaded)
				DetPlayServerChargeSound(false);
			if (bServerSide) {
				HandleDetServerFire(StepView, StepLoc, NumRockets, bDetPrimaryTightLatched || bAltHeld);
				DetPrimarySendServerConfirm(NumRockets, false);
			} else {
				DetPrimaryRecordPrediction(NumRockets, false);
				HandleDetClientLoadedFire(false, NumRockets, bDetPrimaryTightLatched || bAltHeld);
			}
			DetStartCooldown(DetPostFireInterval(NumRockets));
		}
		DetResetPrimaryCycle(false);
		return true;
	}

	// ── ALT FIRE (GRENADES) ──
	if ((bAltHeld || bForceAlt) && !bDetWasAltHeld) {
		// Stock's AltFiring.Begin drops the icon here; LockedTarget itself dies
		// in FireRockets on the !bFireLoad path.
		bLockedOn = false;
		DetAltLoadElapsed = 0.0;
		DetCachedChargeData = 1;
		if (bServerSide)
			DetPlayServerChargeSound(true);
		else {
			// Mirror primary: deterministic cycle owns initial consume.
			DetResetClientAmmoTracking();
			DetConsumeClientAmmo(1);
			DetEnsureClientLoadState(true);
		}
		bDetWasAltHeld = true;
		return true;
	}

	if (bAltHeld && bDetWasAltHeld) {
		NumRockets = DetCalculateCharge(DetAltLoadElapsed);
		if (bServerSide && NumRockets > DetCachedChargeData)
			DetPlayServerChargeSound(false);
		if (!bServerSide && ClientRocketsLoaded > NumRockets)
				ClientRocketsLoaded = NumRockets;
		DetCachedChargeData = NumRockets;

		if (!bServerSide)
			DetEnsureClientLoadState(true);

		bBudgetLimitReached = NumRockets >= DetInternalBudget;
			if (bBudgetLimitReached && NumRockets <= 1 && DetAltLoadElapsed < DetChargeInterval)
				bBudgetLimitReached = false;

		if (NumRockets >= 6 || bBudgetLimitReached) {
				if (bServerSide) HandleDetServerAltFire(StepView, StepLoc, NumRockets);
				else HandleDetClientLoadedFire(true, NumRockets, false);
				DetStartCooldown(DetPostFireInterval(NumRockets));
				bDetWasAltHeld = false;
				DetAltLoadElapsed = 0.0;
			}

		return true;
	}

		if (!bAltHeld && bDetWasAltHeld) {
			bDetWasAltHeld = false;
			NumRockets = DetCalculateCharge(DetAltLoadElapsed);
			if (DetChargeData > 0)
				NumRockets = Min(NumRockets, Clamp(DetChargeData, 1, 6));
			if (bServerSide && NumRockets > DetCachedChargeData)
				DetPlayServerChargeSound(false);
			if (bServerSide) HandleDetServerAltFire(StepView, StepLoc, NumRockets);
			else HandleDetClientLoadedFire(true, NumRockets, false);
			DetStartCooldown(DetPostFireInterval(NumRockets));
			DetAltLoadElapsed = 0.0;
			return true;
		}

	return true;
}

// Client-side instant rocket fire driven by DetProcessStep.
// Plays the fire animation and spawns visual-only rockets, then the
// ClientDetInstantFire state handles the reload anim before going idle.
// DetProcessStep calls this again when the next cooldown expires.
simulated function HandleDetClientFire() {
	local bbPlayer bbP;

	DetConsumeClientAmmo(1);

	DetCachedChargeData = 1;
	ClientRocketsLoaded = 1;
	bFireLoad = true;
	PlayRFiring(0);
	bClientDone = true;
	bRotated = false;

	bbP = bbPlayer(Owner);
	if (bbP != None && IsPingCompEnabled()
		&& !bLockedOn && bbP.ClientWeaponSettingsData.bRocketUseClientSideAnimations)
		SpawnClientSideRockets(1);

	if (!IsInState('ClientDetInstantFire'))
		GotoState('ClientDetInstantFire');
}

// Client-side loaded rocket fire driven by DetProcessStep's falling edge.
// Syncs ClientRocketsLoaded to the server's count before firing so both
// sides agree on the number of rockets/grenades spawned.
simulated function HandleDetClientLoadedFire(bool bAlt, int NumRockets, optional bool bTight) {
	if (bAlt && DetHasSwitchAwayRequest()) {
		DetCancelDeterministicLoad(false);
		return;
	}

	// Primary-only: if authoritative auto-fire interrupts during rotate,
	// the final load sound may never be reached via AnimEnd.
	if (Role < ROLE_Authority && !bAlt && IsDetActive() && IsInState('ClientFiring')
		&& bRotated && NumRockets > ClientRocketsLoaded
		&& Owner != None && Pawn(Owner) != None)
		Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);

	DetFinalizeClientLoadedAmmo(NumRockets);

	ClientRocketsLoaded = NumRockets;
	DetCachedChargeData = NumRockets;

	// Use the same tightwad edge decision as the server step.
	bTightWad = !bAlt && bTight;
	FiringRockets();
	bTightWad = false;
}

// Spawn rockets on the server using the deterministic data path in FireRockets.BeginState.
function HandleDetServerFire(rotator StepView, vector StepLoc, int NumRockets, bool bTight) {
	local PlayerPawn P;

	if (!DetPrepareServerFireContext(StepView, StepLoc, NumRockets, P))
		return;

	DetServerShotSerial = (DetServerShotSerial + 1) & 0x7FFFFFFF;
	if (bDetPrimaryLatchedInstant)
		DetServerLastShotKind = IGPLUS_EB_SHOT_KIND_PRIMARY_INSTANT;
	else
		DetServerLastShotKind = IGPLUS_EB_SHOT_KIND_PRIMARY_LOADED;
	bDetSwitchSettlementPending = false;
	DetArmServerFireState(NumRockets, true, bTight);
	if (P.PendingWeapon != none && P.PendingWeapon != self) {
		P.PlayRecoil(FiringSpeed);
		bChangeWeapon = true;
	}
	GoToState('FireRockets');
}

// Spawn grenades on the server using deterministic step loc/view.
function HandleDetServerAltFire(rotator StepView, vector StepLoc, int NumRockets) {
	local PlayerPawn P;

	if (!DetPrepareServerFireContext(StepView, StepLoc, NumRockets, P))
		return;

	DetServerShotSerial = (DetServerShotSerial + 1) & 0x7FFFFFFF;
	DetServerLastShotKind = IGPLUS_EB_SHOT_KIND_ALT;
	bDetSwitchSettlementPending = false;
	DetArmServerFireState(NumRockets, false);
	// Ammo is already consumed: spawn the volley, then switch (stock order).
	if (P.PendingWeapon != none && P.PendingWeapon != self)
		bChangeWeapon = true;
	GoToState('FireRockets');
}

// One owner's deterministic state must never transfer to the next.
simulated function DetResetDeterministicState() {
	DetClearPendingServerFireState();
	DetResetPrimaryCycle(true);
	DetResetAltCycle(true);
	DetCooldownRemaining = 0.0;
	DetLastStepTS = 0.0;
	DetLastStepDelta = 0.0;
	DetCachedChargeData = 0;
	DetInternalBudget = 0;
	DetClientAmmoSpentSinceDown = 0;
	DetClientLastDownTS = 0.0;
	ClientRocketsLoaded = 0;
	bClientDone = false;
	bRotated = false;
	DetClearPendingAltInput();
	bDetSwitchSettlementPending = false;
	DetServerShotSerial = 0;
	DetServerLastShotKind = -1;
}

function GiveTo(Pawn Other)
{
	DetResetDeterministicState();
	Super.GiveTo(Other);
}

function DropFrom(vector StartLocation)
{
	local int DropCharge;
	local bool bShouldCancel;

	DropCharge = DetGetChargeDataForMove();
	bShouldCancel = Role == ROLE_Authority
		&& IsDetActive()
		&& (bDetPrimaryCycleActive || bDetWasFireHeld || bDetWasAltHeld);

	// Mirror switch-away behavior: rockets/grenades committed into an active
	// deterministic load stay spent when the weapon is thrown.
	if (bShouldCancel)
		DetCancelDeterministicLoad(true, DropCharge);

	DetResetDeterministicState();
	Super.DropFrom(StartLocation);
}

function Finish()
{
	DetResetPrimaryCycle(true);
	DetResetAltCycle(true);

	if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
	{
		if (bChangeWeapon)
			GotoState('DownWeapon');
		else if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
		{
			Pawn(Owner).StopFiring();
			// Never clobber a weapon choice the player already made
			if (Pawn(Owner).PendingWeapon == None || Pawn(Owner).PendingWeapon == self)
				Pawn(Owner).SwitchToBestWeapon();
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

function Fire( float Value )
{
	if (IsDetActive()) {
		return;
	}

	Super.Fire(Value);
}

function AltFire( float Value )
{
	if (IsDetActive()) {
		return;
	}

	Super.AltFire(Value);
}

simulated function bool ClientFire( float Value )
{
	if (!bCanClientFire)
		return false;
	if (Pawn(Owner) == None)
		return false;

	// Deterministic primary load/fire is driven only by step processing.
	// Instant rockets: DetProcessStep drives fire timing via HandleDetClientFire.
	if (DetShouldBypassLegacyClientInput())
		return true;

	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire( float Value )
{
	if (!bCanClientFire)
		return false;
	if (Pawn(Owner) == None)
		return false;

	// Deterministic alt load/fire is driven only by step processing.
	if (DetShouldBypassLegacyClientInput())
		return true;

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

	// Det cooldown is owned by the per-step duration clock.

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
	local float LocalYMod;
	local pawn PawnOwner;
	local float Spread;
	local vector ClientDrawOffset;
	local int i;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None) return;
	if (PlayerPawn(Owner) == None)
		return;

	LocalYMod = PlayerPawn(Owner).Handedness;
	if (LocalYMod != 2.0)
		LocalYMod *= Default.FireOffset.Y;
	else
		LocalYMod = 0;

	ClientDrawOffset = CalcDrawOffsetClient();

	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	
	StartLoc = Owner.Location + ClientDrawOffset + FireOffset.X * X + LocalYMod * Y + FireOffset.Z * Z;
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

		if (bCanClientFire == false)
		{
			DetResetFireRocketsState();
			return;
		}

		PawnOwner = Pawn(Owner);
		if (PawnOwner == None)
		{
			DetResetFireRocketsState();
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

		if ( !bUseDetServerFireData && PawnOwner.bAltFire != 0 )
			bTightWad = true;

		if (bUseDetServerFireData)
		{
			AimRot = DetServerFireRot;
			StartLoc = DetServerFireLoc + CalcDrawOffset();
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
		bUseDetServerFireData = false;
		
		PlayRFiring(RocketsLoaded-1);		
		Owner.MakeNoise(PawnOwner.SoundDampening);
		if ( !bFireLoad )
		{
			LockedTarget = None;
			bLockedOn = false;
		}
		else if ( LockedTarget != None )
		{
			// No seeker without the icon: Idle.Timer can clear bLockedOn and leave
			// LockedTarget set, and Det has no NormalFire.AnimEnd to clean it up.
			BestTarget = Pawn(CheckTarget());
			if ( !bLockedOn || (LockedTarget != BestTarget) )
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
	bCanClientFire = true;
	// Stock Active tail (TournamentWeapon): tell the owning client which weapon
	// is really up. Without it a client that dropped its Weapon pointer never
	// gets it back — feign death blanks it every tick. The v4 path syncs
	// without the fire kick, which would be the eager auto-fire we suppress.
	if ( (Level.Netmode != NM_Standalone) && Owner != None && Owner.IsA('TournamentPlayer')
		&& (PlayerPawn(Owner).Player != None)
		&& !PlayerPawn(Owner).Player.IsA('ViewPort') )
	{
		if ( !IsDetActive() && (bForceFire || (Pawn(Owner).bFire != 0)) )
			TournamentPlayer(Owner).SendFire(self);
		else if ( !IsDetActive() && (bForceAltFire || (Pawn(Owner).bAltFire != 0)) )
			TournamentPlayer(Owner).SendAltFire(self);
		else if ( !bChangeWeapon )
			TournamentPlayer(Owner).UpdateRealWeapon(self);
	}
	if (IsDetActive() && (Pawn(Owner).bFire != 0 || Pawn(Owner).bAltFire != 0)) {
		// Suppress eager auto-fire when weapon comes up deterministic style
		GotoState('Idle');
	} else {
		Finish(); // Triggers global Fire block implicitly based on triggers
	}
}

state Idle
{
	// The only place a lock is acquired. Stock leaves Idle for NormalFire the
	// instant Fire is pressed so it can't run mid-load; Det stays in Idle, so
	// gate it on the load cycle instead. A load may lose a lock, never gain one.
	function Timer()
	{
		if (IsDetActive() && (DetHasCommittedPrimary() || bDetWasAltHeld)) {
			// The revalidation stock does per rocket loaded in NormalFire.AnimEnd.
			if (LockedTarget != None && CheckTarget() != LockedTarget) {
				if (bLockedOn)
					Owner.PlaySound(Misc2Sound, SLOT_None, Pawn(Owner).SoundDampening);
				LockedTarget = None;
				bLockedOn = False;
			}
			// Loads that never reach FireRockets (fire with no ammo) skip Idle's
			// Begin refresh; a stale candidate would lock in one tick, not two.
			OldTarget = None;
			return;
		}

		Super.Timer();
	}

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

			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0)
				&& (Pawn(Owner).PendingWeapon == None || Pawn(Owner).PendingWeapon == self) )
				Pawn(Owner).SwitchToBestWeapon();

			Disable('AnimEnd');
			PlayIdleAnim();
		}
		else
		{
			bPointing = False;
			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0)
				&& (Pawn(Owner).PendingWeapon == None || Pawn(Owner).PendingWeapon == self) )
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

Begin:
	if (IsDetActive()) {
		if (Pawn(Owner) != none && Pawn(Owner).bFire != 0) bPointing = true;
		if (Pawn(Owner) != none && Pawn(Owner).bAltFire != 0) bPointing = true;
	} else {
		if (Pawn(Owner).bFire!=0) Fire(0.0);
		if (Pawn(Owner).bAltFire!=0) AltFire(0.0);
	}
	bPointing=False;
	if (AmmoType.AmmoAmount<=0
		&& (Pawn(Owner).PendingWeapon == None || Pawn(Owner).PendingWeapon == self))
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
	if (Role == ROLE_Authority && bDetSwitchSettlementPending)
		DetFinalizeSwitchSettlement();
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	// A tap banked during cooldown must not survive into a fresh equip —
	// stock clears its force latches here too.
	bDetCooldownFireTap = false;
	bDetCooldownAltTap = false;
	DetResetPrimaryCycle(true);
	DetResetAltCycle(true);
	bDetSwitchSettlementPending = false;
	if (Pawn(Owner) != none) {
		if (Pawn(Owner).bFire != 0 && !DetOwnerInstantEnabled())
			bDetSuppressPrimaryFirstBudgetAuto = true;
	}
	bTightWad = false;
	DetCachedChargeData = 0;
	ClientRocketsLoaded = 0;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().EightballSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	if (Role < ROLE_Authority || !IsDetActive())
		DetResetPrimaryCycle(true);
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

	PlayAnim(LoadAnim[num], rate, 0.05);
	Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

simulated function PlayRotating(int num)
{
	if (Owner == None)
		return;

	PlayAnim(RotateAnim[num],, 0.05);
	Owner.PlayOwnedSound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
}

simulated function bool DetHandleClientLoadAnimEnd(bool bAltLoad) {
	local int LoadBudget;
	local int TargetLoaded;
	local int ConsumeDelta;

	if (!IsDetActive())
		return false;

	if (!bCanClientFire || Pawn(Owner) == None) {
		GotoState('');
		return true;
	}

	if (bClientDone) {
		PlayLoading(1.5, 0);
		GotoState('ClientReload');
		return true;
	}

	if (bAltLoad) {
		DetRefreshInternalBudget();
		LoadBudget = Min(6, Max(1, DetInternalBudget));
		TargetLoaded = Clamp(DetCachedChargeData, 1, LoadBudget);
	} else {
		LoadBudget = Min(6, Max(1, DetPrimaryCycleStartBudget));
		TargetLoaded = Clamp(DetPrimaryPredictedLoaded, 1, LoadBudget);
	}

	if (bRotated) {
		PlayLoading(1.1, ClientRocketsLoaded);
		bRotated = false;
		if (ClientRocketsLoaded > TargetLoaded) {
			ClientRocketsLoaded = TargetLoaded;
		} else if (TargetLoaded > ClientRocketsLoaded) {
			ConsumeDelta = TargetLoaded - ClientRocketsLoaded;
			if (!DetConsumeClientAmmo(ConsumeDelta))
				return true;
			ClientRocketsLoaded = TargetLoaded;
		}
		DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
		return true;
	}

	DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
	if (ClientRocketsLoaded >= LoadBudget)
		return true;

	PlayRotating(ClientRocketsLoaded - 1);
	bRotated = true;
	return true;
}

// =========================================================================
// Client State Management
// =========================================================================

// Lightweight state for instant rocket Det fire+reload animation cycle.
// DetProcessStep drives fire timing via HandleDetClientFire; this state
// just sequences fire anim → reload anim → idle.
state ClientDetInstantFire
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
	simulated function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if (P == none)
			return;

		if ((P.bFire == 0) || (AmmoType == none) || (AmmoType.AmmoAmount <= 0)) {
			DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		if (DetHandleClientLoadAnimEnd(false))
			return;

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
			DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
		}
		else
		{
			DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			if ( bInstantRocket || (ClientRocketsLoaded == 6) )
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
		bFireLoad = true;
		if (IsDetActive())
			Disable('Tick');

		// Instant Det: HandleDetClientFire drives fire, not ClientFiring.
		if (bInstantRocket && IsDetActive()) {
			GotoState('');
			return;
		}

		if (!IsDetActive() && AmmoType != None)
			AmmoType.AmmoAmount--;

		if ( bInstantRocket )
		{
			ClientRocketsLoaded = 1;
			DetCachedChargeData = 1;
			FiringRockets();
		}
		else
		{
			ClientRocketsLoaded = 1;
			DetCachedChargeData = 1;
			PlayRotating(ClientRocketsLoaded - 1);
			bRotated = true;
		}
	}

	simulated function EndState()
	{
		DetCachedChargeData = 0;
		ClientRocketsLoaded = 0;
		bClientDone = false;
		bRotated = false;
	}
}

state ClientAltFiring
{
	simulated function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if (P == none)
			return;

		if ((P.bAltFire == 0) || (AmmoType == none) || (AmmoType.AmmoAmount <= 0)) {
			DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		if (DetHandleClientLoadAnimEnd(true))
			return;

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
			DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
		}
		else
		{
			DetCachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
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
		if (IsDetActive())
			Disable('Tick');
		
		if (!IsDetActive() && AmmoType != None)
			AmmoType.AmmoAmount--;

		ClientRocketsLoaded = 1;
		DetCachedChargeData = 1;
		PlayRotating(ClientRocketsLoaded - 1);
		bRotated = true;
	}

	simulated function EndState()
	{
		DetCachedChargeData = 0;
		ClientRocketsLoaded = 0;
		bClientDone = false;
		bRotated = false;
	}
}

state ClientReload
{
	simulated function bool ClientFire(float Value)
	{
		if (IsDetActive())
			return bCanClientFire && (Pawn(Owner) != None) && ((AmmoType == None) || (AmmoType.AmmoAmount > 0));

		return Super.ClientFire(Value);
	}

	simulated function bool ClientAltFire(float Value)
	{
		if (IsDetActive())
			return bCanClientFire && (Pawn(Owner) != None) && ((AmmoType == None) || (AmmoType.AmmoAmount > 0));

		return Super.ClientAltFire(Value);
	}

	simulated function AnimEnd()
	{
		if (IsDetActive()) {
			if (!bCanClientFire || Pawn(Owner) == None) {
				GotoState('');
				return;
			}
			if ((AmmoType == None) || (AmmoType.AmmoAmount <= 0)) {
				GotoState('');
				Pawn(Owner).SwitchToBestWeapon();
				return;
			}
			GotoState('');
			Global.AnimEnd();
			return;
		}

		Super.AnimEnd();
	}
}

state DownWeapon
{
	function BeginState()
	{
		// Authority guard, not transport: the deterministic cycle must survive
		// the switch on the fallback (v3) transport too, or in-flight releases
		// find no committed cycle and the volley is lost/undercounted.
		if (Role == ROLE_Authority && IsDetActive())
			bDetSwitchSettlementPending = true;
		else
			DetResetPrimaryCycle(true);
		Super.BeginState();
	}
}

state ClientDown
{
	simulated function BeginState()
	{
		if (Level != none)
			DetClientLastDownTS = Level.TimeSeconds;
		DetResetPrimaryCycle(true);
		DetResetAltCycle(true);
		DetClientAmmoSpentSinceDown = 0;
		Super.BeginState();
	}
}

defaultproperties {
	DetLastStepTS=-1.0
}
