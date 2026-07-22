// ===============================================================
// Stats.ST_UT_Eightball
// V4 deterministic fire for Eightball rocket launcher.
// Edge-only design: server spawns rockets from rising/falling edge
// detection in input slices; client runs the same edge logic as a
// shared duration-based controller while the legacy
// ClientFiring state machine handles animations.
// ===============================================================

class ST_UT_Eightball extends UT_Eightball;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

// Server-side deterministic fire data (from ServerMove_v4 step)
var vector V4ServerFireLoc;
var rotator V4ServerFireRot;
var bool bUseV4ServerFireData;

// V4 deterministic fire — shared between client and server
var float V4CooldownRemaining;
var float V4PrimaryLoadElapsed;
var float V4AltLoadElapsed;
var float V4LastStepTS;
var float V4LastStepDelta;
var bool bV4WasFireHeld;
var bool bV4WasAltHeld;
var int V4CachedChargeData;
var bool bV4PendingAltHeld;
var bool bV4PendingAltTap;
// Stock ForceFire parity (bJustFired): a tap that lands inside the post-fire
// cooldown banks here and replays as a force edge on the first free slice.
var bool bV4CooldownFireTap;
var bool bV4CooldownAltTap;

// Client ammo consumption reconstruction logic
var int V4ClientConsumedAmmo;
var int V4ClientAmmoSpentSinceDown;
var float V4ClientLastDownTS;
var int V4InternalBudget;
var bool bV4SuppressPrimaryFirstBudgetAuto;

// Primary deterministic cycle controller (server-authoritative, client-predicted)
var int V4PrimaryCycleId;
var bool bV4PrimaryCycleActive;
var int V4PrimaryCycleStartBudget;
var int V4PrimaryPredictedLoaded;
var bool bV4PrimaryLatchedInstant;
var int V4PrimaryLastPredictedCycleId;
var int V4PrimaryLastPredictedRockets;
var bool bV4PrimaryLastPredictedInstant;
var bool bV4PrimaryLastPredictedAuto;
var bool bV4PrimaryTightLatched;
var int V4ServerShotSerial;
var int V4ServerLastShotKind;
var bool bV4SwitchSettlementPending;

const IGPLUS_EB_SHOT_KIND_ALT = 0;
const IGPLUS_EB_SHOT_KIND_PRIMARY_LOADED = 1;
const IGPLUS_EB_SHOT_KIND_PRIMARY_INSTANT = 2;

simulated function bool V4OwnerInstantEnabled() {
	local TournamentPlayer TP;

	if (bAlwaysInstant)
		return true;

	TP = TournamentPlayer(Owner);
	if (TP != none)
		return TP.bInstantRocket;

	return bInstantRocket;
}

simulated function bool V4ShouldBypassLegacyClientInput() {
	bInstantRocket = V4OwnerInstantEnabled();
	// Client prediction runs whenever the deterministic system is active,
	// on both the v4 and fallback transports — legacy input must stand down.
	return IsV4Active();
}

function V4ClearPendingServerFireState() {
	bUseV4ServerFireData = false;
	bTightWad = false;
	RocketsLoaded = 0;
}

function V4ResetFireRocketsState() {
	V4ClearPendingServerFireState();
	V4ResetPrimaryCycle(false);
	V4ResetAltCycle(false);
}

function bool V4PrepareServerFireContext(
	rotator StepView,
	vector StepLoc,
	out int NumRockets,
	out PlayerPawn P
) {
	P = PlayerPawn(Owner);
	if (P == none)
		return false;

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
		V4ClearPendingServerFireState();
		return false;
	}

	return true;
}

function V4ArmServerFireState(int NumRockets, bool bPrimary, optional bool bTight) {
	RocketsLoaded = NumRockets;
	bFireLoad = bPrimary;
	bTightWad = bPrimary && bTight;
	if (bPrimary)
		bInstantRocket = bV4PrimaryLatchedInstant;

	bCanClientFire = true;
	bPointing = true;
}

simulated function V4ResetClientAmmoTracking() {
	if (Role == ROLE_Authority)
		return;
	V4ClientConsumedAmmo = 0;
}

simulated function V4ResetPrimaryCycle(optional bool bClearHeld) {
	if (bClearHeld) {
		bV4WasFireHeld = false;
	}
	bV4SuppressPrimaryFirstBudgetAuto = false;
	bV4PrimaryCycleActive = false;
	V4PrimaryCycleStartBudget = 0;
	V4PrimaryPredictedLoaded = 0;
	bV4PrimaryLatchedInstant = false;
	bV4PrimaryTightLatched = false;
	V4PrimaryLoadElapsed = 0.0;
	V4ResetClientAmmoTracking();
}

simulated function V4ResetAltCycle(optional bool bClearHeld) {
	if (bClearHeld) {
		bV4WasAltHeld = false;
	}
	V4AltLoadElapsed = 0.0;
	V4ResetClientAmmoTracking();
}

simulated function V4ClearPendingAltInput() {
	bV4PendingAltHeld = false;
	bV4PendingAltTap = false;
	bV4CooldownFireTap = false;
	bV4CooldownAltTap = false;
}

// Preserve an honest AltFire tap that reaches the server after the bring-up
// gate but before ChangedWeapon equips Eightball. Nothing may fire while pending.
function bool V4TrackPendingAltInput(
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt
) {
	if (bFireHeld || bForceFire)
		return false;
	if (bForceAlt) {
		bV4PendingAltHeld = false;
		bV4PendingAltTap = true;
		return true;
	}
	if (bAltHeld) {
		bV4PendingAltHeld = true;
		return true;
	}
	if (bV4PendingAltHeld) {
		bV4PendingAltHeld = false;
		bV4PendingAltTap = true;
		return true;
	}
	return bV4PendingAltTap;
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

simulated function V4PrimaryStartCycle(bool bMoveInstant, bool bServerSide) {
	V4PrimaryCycleId = (V4PrimaryCycleId + 1) & 255;
	V4PrimaryCycleStartBudget = Max(1, V4InternalBudget);
	V4PrimaryPredictedLoaded = 1;
	bV4PrimaryLatchedInstant = bMoveInstant;
	bV4PrimaryTightLatched = false;
	bV4SuppressPrimaryFirstBudgetAuto = (V4PrimaryCycleStartBudget <= 1);

	bInstantRocket = bV4PrimaryLatchedInstant;
	bV4PrimaryCycleActive = !bV4PrimaryLatchedInstant;
	V4PrimaryLoadElapsed = 0.0;
	if (bV4PrimaryCycleActive && !bServerSide) {
		// Deterministic primary cycle owns the first-rocket consume; reset
		// tracking first so finalize doesn't synthesize an extra consume.
		V4ResetClientAmmoTracking();
		V4ConsumeClientAmmo(1);
	}
}

simulated function V4PrimaryRecordPrediction(int NumRockets, bool bAutoEnded) {
	V4PrimaryLastPredictedCycleId = V4PrimaryCycleId;
	V4PrimaryLastPredictedRockets = Clamp(NumRockets, 1, 6);
	bV4PrimaryLastPredictedInstant = bV4PrimaryLatchedInstant;
	bV4PrimaryLastPredictedAuto = bAutoEnded;
	V4PrimaryPredictedLoaded = V4PrimaryLastPredictedRockets;
}

simulated function V4PrimarySendServerConfirm(int NumRockets, bool bAutoEnded) {
	if (Role != ROLE_Authority)
		return;

	ClientV4PrimaryShotConfirm(
		byte(V4PrimaryCycleId),
		byte(Clamp(NumRockets, 1, 6)),
		bAutoEnded,
		bV4PrimaryLatchedInstant
	);
}

simulated function ClientV4PrimaryShotConfirm(
	byte CycleId,
	byte Rockets,
	bool bAutoEnded,
	bool bInstant
) {
	local int ConfirmedRockets;
	local bool bMismatch;

	if (Role == ROLE_Authority)
		return;
	if (!IsV4Active())
		return;

	ConfirmedRockets = Clamp(int(Rockets), 1, 6);

	// Ignore confirms for a finished cycle once a newer primary cycle is
	// already loading. Applying those confirms here would reset local ammo
	// tracking mid-load and can cause an extra client-side consume.
	if (bV4PrimaryCycleActive && int(CycleId) != V4PrimaryCycleId)
		return;

	bMismatch = V4PrimaryLastPredictedCycleId != int(CycleId)
		|| V4PrimaryLastPredictedRockets != ConfirmedRockets
		|| bV4PrimaryLastPredictedInstant != bInstant
		|| bV4PrimaryLastPredictedAuto != bAutoEnded;

	// Base UT behavior: client HUD ammo follows replicated server ammo.
	// Do not mutate client ammo here for primary confirm.
	V4ResetClientAmmoTracking();

	bV4PrimaryLatchedInstant = bInstant;
	V4PrimaryPredictedLoaded = ConfirmedRockets;
	V4CachedChargeData = ConfirmedRockets;
	ClientRocketsLoaded = ConfirmedRockets;
	if (bV4PrimaryCycleActive) {
		bV4PrimaryCycleActive = false;
		V4PrimaryLoadElapsed = 0.0;
	}

	// Snap to post-fire path when client prediction drifted from authoritative shot.
	if (bMismatch && IsInState('ClientFiring')) {
		bClientDone = true;
		bRotated = false;
	}
}

simulated function V4ApplyClientAmmoRefund(int ServerAmmo) {
	local int RefundFloor;

	if (Role == ROLE_Authority || AmmoType == none)
		return;

	// This correction follows ClientPutDown on the owning player's reliable
	// channel. Only refund missing ammo; never overwrite a newer pickup or shot.
	RefundFloor = Max(0, ServerAmmo - V4ClientAmmoSpentSinceDown);
	AmmoType.AmmoAmount = Max(AmmoType.AmmoAmount, RefundFloor);
	if (bbPlayer(Owner) != none)
		bbPlayer(Owner).IGPlus_PruneEightballShotQueueThrough(V4ClientLastDownTS);
}

simulated function int V4GetChargeDataForMove() {
	local int Charge;
	Charge = Clamp(V4CachedChargeData, 0, 7);
	if ((IsInState('ClientFiring') || IsInState('ClientAltFiring')) && ClientRocketsLoaded > Charge)
		Charge = Clamp(ClientRocketsLoaded, 0, 7);
	return Charge;
}

simulated function bool V4ConsumeClientAmmo(int Amount) {
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
	V4ClientAmmoSpentSinceDown += ActualAmount;
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
		V4ConsumeClientAmmo(Missing);
}

simulated function V4EnsureClientLoadState(bool bAltLoad) {
	if (Role == ROLE_Authority || !IsV4Active())
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

// True only when the v4 move transport carries weapon data (edge timelines,
// shot packs). Currently off: movement rides the proven v3 ServerMove and the
// deterministic weapons run whole-move dispatch, so packs have no carrier.
simulated function bool UsesServerMoveV4() {
	return false;
}

simulated function bool V4HasSwitchAwayRequest() {
	return bbPlayer(Owner) != none && bbPlayer(Owner).IGPlus_V4SwitchAwayFrom(self);
}

simulated function bool V4HasCommittedPrimary() {
	return bV4PrimaryCycleActive || bV4WasFireHeld;
}

simulated function V4CancelDeterministicLoad(bool bServerSide, optional int MoveChargeData) {
	local int CancelCount;
	local bbPlayer bbP;
	local bool bHadCommittedState;

	// A settlement with nothing committed has nothing to charge or refund;
	// skip the reliable refund RPC that would otherwise fire on every switch.
	bHadCommittedState = bV4PrimaryCycleActive || bV4WasFireHeld || bV4WasAltHeld
		|| V4CachedChargeData > 0 || ClientRocketsLoaded > 0;

	if (bServerSide && AmmoType != none && AmmoType.AmmoAmount > 0) {
		if (bV4PrimaryCycleActive || bV4WasFireHeld) {
			CancelCount = Clamp(V4ResolvePrimaryEdgeCharge(MoveChargeData), 1, 6);
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

	V4ClearPendingServerFireState();
	V4CachedChargeData = 0;
	ClientRocketsLoaded = 0;
	bClientDone = false;
	bV4CooldownFireTap = false;
	bV4CooldownAltTap = false;
	bRotated = false;
	bForceFire = false;
	bForceAltFire = false;
	V4ResetPrimaryCycle(true);
	V4ResetAltCycle(true);
	V4ClearPendingAltInput();
	bV4SwitchSettlementPending = false;
	if (bServerSide && AmmoType != none && bHadCommittedState) {
		bbP = bbPlayer(Owner);
		if (bbP != none)
			bbP.IGPlus_ClientEightballAmmoRefund(self, AmmoType.AmmoAmount);
	}

	if (!bServerSide && (IsInState('ClientFiring') || IsInState('ClientAltFiring') || IsInState('ClientReload')))
		GotoState('');
}

function V4FinalizeSwitchSettlement() {
	if (Role != ROLE_Authority || !bV4SwitchSettlementPending)
		return;

	V4CancelDeterministicLoad(true, V4GetChargeDataForMove());
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

simulated function V4AdvanceStepClock(float StepTS) {
	local float StepDelta;

	V4LastStepDelta = 0.0;

	if (V4LastStepTS < 0.0) {
		V4LastStepTS = StepTS;
		return;
	}

	StepDelta = StepTS - V4LastStepTS;
	if (StepDelta < -0.001) {
		V4LastStepTS = StepTS;
		return;
	}

	V4LastStepTS = StepTS;

	StepDelta = FMax(StepDelta, 0.0);
	V4LastStepDelta = StepDelta;

	V4CooldownRemaining = FMax(0.0, V4CooldownRemaining - StepDelta);

	if (bV4PrimaryCycleActive)
		V4PrimaryLoadElapsed += StepDelta;
	if (bV4WasAltHeld)
		V4AltLoadElapsed += StepDelta;
}

simulated function V4StartCooldown(float Interval) {
	V4CooldownRemaining = FMax(0.0, Interval);
}

simulated function V4PlayServerChargeSound(bool bRotate) {
	if (Role != ROLE_Authority || Owner == none || Pawn(Owner) == none)
		return;

	if (bRotate)
		Owner.PlayOwnedSound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
	else
		Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

// V4ProcessInputSlice runs on both sides: the server spawns authoritative
// rockets; the client tracks edges/clocks and drives animation states only.
const V4ChargeInterval = 0.9;

simulated function int V4CalculateCharge(float LoadElapsed) {
	V4RefreshInternalBudget();
	return Min(Clamp(1 + int(LoadElapsed / V4ChargeInterval), 1, 6), Max(1, V4InternalBudget));
}

simulated function int V4ResolvePrimaryEdgeCharge(optional int MoveChargeData) {
	local int BudgetLimit;
	local int NumRockets;
	local int MoveCharge;
	local int TimeAllowedCharge;

	NumRockets = V4CalculateCharge(V4PrimaryLoadElapsed);
	BudgetLimit = Max(1, V4InternalBudget);
	MoveCharge = Clamp(MoveChargeData, 0, 6);

	// Client report may only lower the count; input-slice-sized slack so coarse
	// steps don't shave a rocket off an honest volley.
	TimeAllowedCharge = V4CalculateCharge(V4PrimaryLoadElapsed + FMax(0.06, V4LastStepDelta));
	if (MoveCharge > 0)
		return Min(Min(MoveCharge, TimeAllowedCharge), BudgetLimit);

	if (V4PrimaryPredictedLoaded > 0)
		NumRockets = Max(NumRockets, V4PrimaryPredictedLoaded);
	NumRockets = Min(NumRockets, TimeAllowedCharge);

	return Min(Clamp(NumRockets, 1, 6), BudgetLimit);
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
	optional int V4ChargeData,
	optional bool bMoveInstantValid,
	optional bool bMoveInstantValue
) {
	local int NumRockets;
	local bool bMoveInstant;
	local bool bOwnerInstantSetting;
	local bool bBudgetLimitReached;

	V4AdvanceStepClock(StepTS);

	// Predicted steps were recorded before the client committed to the switch
	// (det-ready stamping stops the moment ClientPending is set), so they must
	// keep a live cycle alive: the release edge right behind them fires the
	// volley the client already predicted. Only unpredicted steps — or a fresh
	// force tap — prove the player is still holding through the switch.
	if (V4HasSwitchAwayRequest()
		&& (IsInState('ClientAltFiring')
			|| bV4PendingAltHeld || bV4PendingAltTap
			|| ((bV4WasAltHeld || bAltHeld || V4HasCommittedPrimary())
				&& (!bClientPredictedStep || bForceFire || bForceAlt)))) {
		V4CancelDeterministicLoad(bServerSide, V4ChargeData);
		return true;
	}

	// Resolve input queued during the server's final pending-weapon window.
	if (bServerSide && Pawn(Owner) != none && Pawn(Owner).Weapon == self) {
		if (bV4PendingAltHeld) {
			if (bFireHeld || bForceFire) {
				// Stock precedence: a new primary press supersedes queued alt hold.
				bV4PendingAltHeld = false;
			} else if (!bAltHeld) {
				bV4PendingAltHeld = false;
				bV4PendingAltTap = true;
			} else {
				bV4PendingAltHeld = false;
				bClientPredictedStep = true;
			}
		}
		if (bV4PendingAltTap) {
			if (V4CooldownRemaining > 0.0001)
				return true;
			bV4PendingAltTap = false;
			V4CachedChargeData = 1;
			if (AmmoType != none && AmmoType.AmmoAmount > 0)
				V4PlayServerChargeSound(true);
			HandleV4ServerAltFire(StepView, StepLoc, 1);
			V4StartCooldown(V4PostFireInterval(1));
			return true;
		}
	}

	// Committed state returns from the held/falling branches before the
	// rising edges, so unpredicted steps can only continue a cycle.
	if (!bClientPredictedStep && !bV4WasFireHeld && !bV4WasAltHeld) {
		return true;
	}

	if (bMoveInstantValid)
		bMoveInstant = bMoveInstantValue;
	else if (TournamentPlayer(Owner) != none)
		bMoveInstant = TournamentPlayer(Owner).bInstantRocket;
	else
		bMoveInstant = bInstantRocket;

	if (V4CooldownRemaining > 0.0001) {
		// Stock banks a press EVENT that lands during the reload leg (the
		// ClientReload ForceFire latch) and fires it at reload-end. Taps in
		// the fire-anim leg drop, and a held button banks nothing. The move
		// force bits carry exactly the press events (bJustFired), so bank on
		// those alone, only within the reload leg (0.05 tween + 0.4 Load1
		// anim). Primary press supersedes a banked alt, stock precedence.
		if (V4CooldownRemaining <= 0.45) {
			if (bForceFire) {
				bV4CooldownFireTap = true;
				bV4CooldownAltTap = false;
			} else if (bForceAlt)
				bV4CooldownAltTap = true;
		}
		return true;
	}

	// Replay a banked tap as a force edge; the rising edge starts the cycle
	// and, with the button already released, the next slice's falling edge
	// fires the single rocket/grenade — reload-end timing, like stock.
	if (bV4CooldownFireTap) {
		bV4CooldownFireTap = false;
		bV4CooldownAltTap = false;
		bForceFire = true;
	} else if (bV4CooldownAltTap) {
		bV4CooldownAltTap = false;
		bForceAlt = true;
	}

		if (AmmoType == none || AmmoType.AmmoAmount <= 0) {
			if (!bV4WasFireHeld && !bV4WasAltHeld) {
				if (bServerSide && (bFireHeld || bAltHeld) && Pawn(Owner) != none) {
					Pawn(Owner).StopFiring();
					if (Pawn(Owner).PendingWeapon == none || Pawn(Owner).PendingWeapon == self)
						Pawn(Owner).SwitchToBestWeapon();
				}
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

	// ── PRIMARY FIRE ──
	// Skip the rising edge while an alt (grenade) cycle is loading so the
	// alt branches below keep updating charge and can auto-fire at 6.
	// Stock precedence: primary wins a simultaneous idle edge.
	if ((bFireHeld || bForceFire) && !bV4WasFireHeld && !bV4WasAltHeld) {
		V4RefreshInternalBudget();
		V4PrimaryStartCycle(bMoveInstant, bServerSide);
		bV4WasFireHeld = true;
		if (bV4PrimaryLatchedInstant) {
			if (bServerSide) {
				HandleV4ServerFire(StepView, StepLoc, 1, bAltHeld);
				V4PrimarySendServerConfirm(1, false);
			} else {
				V4PrimaryRecordPrediction(1, false);
				HandleV4ClientFire();
			}
			V4StartCooldown(V4PostFireInterval(1));
			bV4WasFireHeld = false;
			V4ResetPrimaryCycle(false);
		} else {
			if (bServerSide)
				V4PlayServerChargeSound(true);
			else
				V4EnsureClientLoadState(false);
		}
		return true;
	}

	if (bFireHeld && bV4WasFireHeld) {
		if (!bV4PrimaryCycleActive) {
			bV4WasFireHeld = false;
			return true;
		}

			NumRockets = V4CalculateCharge(V4PrimaryLoadElapsed);
			// Sample alt only on the input slice where a new rocket actually loads,
			// mirroring base UT99's per-AnimEnd sample so a brief tap doesn't latch.
			if (NumRockets > V4PrimaryPredictedLoaded && bAltHeld)
				bV4PrimaryTightLatched = true;
			if (bServerSide && NumRockets > V4PrimaryPredictedLoaded)
				V4PlayServerChargeSound(false);
			V4PrimaryPredictedLoaded = NumRockets;
			if (!bServerSide && ClientRocketsLoaded > NumRockets)
				ClientRocketsLoaded = NumRockets;
		V4CachedChargeData = NumRockets;

		if (!bServerSide)
			V4EnsureClientLoadState(false);

			bBudgetLimitReached = NumRockets >= V4InternalBudget;
			if (bV4SuppressPrimaryFirstBudgetAuto
				&& bBudgetLimitReached
				&& NumRockets <= 1
				&& V4PrimaryLoadElapsed < V4ChargeInterval)
				bBudgetLimitReached = false;
		if (V4InternalBudget > 1 || NumRockets > 1)
			bV4SuppressPrimaryFirstBudgetAuto = false;

		if (NumRockets >= 6 || bBudgetLimitReached) {
			if (bServerSide) {
				HandleV4ServerFire(StepView, StepLoc, NumRockets, bV4PrimaryTightLatched || bAltHeld);
				V4PrimarySendServerConfirm(NumRockets, true);
			} else {
				V4PrimaryRecordPrediction(NumRockets, true);
				HandleV4ClientLoadedFire(false, NumRockets, bV4PrimaryTightLatched || bAltHeld);
			}
			V4StartCooldown(V4PostFireInterval(NumRockets));
			bV4WasFireHeld = false;
			V4ResetPrimaryCycle(false);
		}
		return true;
	}

	if (!bFireHeld && bV4WasFireHeld) {
		bV4WasFireHeld = false;
		if (bV4PrimaryCycleActive) {
			NumRockets = V4ResolvePrimaryEdgeCharge(V4ChargeData);
			if (bServerSide && NumRockets > V4PrimaryPredictedLoaded)
				V4PlayServerChargeSound(false);
			if (bServerSide) {
				HandleV4ServerFire(StepView, StepLoc, NumRockets, bV4PrimaryTightLatched || bAltHeld);
				V4PrimarySendServerConfirm(NumRockets, false);
			} else {
				V4PrimaryRecordPrediction(NumRockets, false);
				HandleV4ClientLoadedFire(false, NumRockets, bV4PrimaryTightLatched || bAltHeld);
			}
			V4StartCooldown(V4PostFireInterval(NumRockets));
		}
		V4ResetPrimaryCycle(false);
		return true;
	}

	// ── ALT FIRE (GRENADES) ──
	if ((bAltHeld || bForceAlt) && !bV4WasAltHeld) {
		V4AltLoadElapsed = 0.0;
		V4CachedChargeData = 1;
		if (bServerSide)
			V4PlayServerChargeSound(true);
		else {
			// Mirror primary: deterministic cycle owns initial consume.
			V4ResetClientAmmoTracking();
			V4ConsumeClientAmmo(1);
			V4EnsureClientLoadState(true);
		}
		bV4WasAltHeld = true;
		return true;
	}

	if (bAltHeld && bV4WasAltHeld) {
		NumRockets = V4CalculateCharge(V4AltLoadElapsed);
		if (bServerSide && NumRockets > V4CachedChargeData)
			V4PlayServerChargeSound(false);
		if (!bServerSide && ClientRocketsLoaded > NumRockets)
				ClientRocketsLoaded = NumRockets;
		V4CachedChargeData = NumRockets;

		if (!bServerSide)
			V4EnsureClientLoadState(true);

		bBudgetLimitReached = NumRockets >= V4InternalBudget;
			if (bBudgetLimitReached && NumRockets <= 1 && V4AltLoadElapsed < V4ChargeInterval)
				bBudgetLimitReached = false;

		if (NumRockets >= 6 || bBudgetLimitReached) {
				if (bServerSide) HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
				else HandleV4ClientLoadedFire(true, NumRockets, false);
				V4StartCooldown(V4PostFireInterval(NumRockets));
				bV4WasAltHeld = false;
				V4AltLoadElapsed = 0.0;
			}

		return true;
	}

		if (!bAltHeld && bV4WasAltHeld) {
			bV4WasAltHeld = false;
			NumRockets = V4CalculateCharge(V4AltLoadElapsed);
			if (V4ChargeData > 0)
				NumRockets = Min(NumRockets, Clamp(V4ChargeData, 1, 6));
			if (bServerSide && NumRockets > V4CachedChargeData)
				V4PlayServerChargeSound(false);
			if (bServerSide) HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
			else HandleV4ClientLoadedFire(true, NumRockets, false);
			V4StartCooldown(V4PostFireInterval(NumRockets));
			V4AltLoadElapsed = 0.0;
			return true;
		}

	return true;
}

simulated function V4EmitClientAuthoritativeShot(int ShotKind, int NumRockets, optional bool bTight) {
	local bbPlayer bbP;
	local Pawn PawnOwner;

	if (Role == ROLE_Authority)
		return;
	if (!UsesServerMoveV4())
		return;

	bbP = bbPlayer(Owner);
	PawnOwner = Pawn(Owner);
	if (bbP == none || PawnOwner == none || NumRockets <= 0)
		return;
	if (bbP.IGPlus_EnableInputReplication) {
		bbP.IGPlus_PruneEightballShotQueue(true);
		return;
	}

	bbP.IGPlus_QueueEightballAuthoritativeShot(
		ShotKind,
		Level.TimeSeconds,
		Clamp(NumRockets, 1, 6),
		bTight
	);
}

function bool V4RecoverPackedShot(
	int ShotKind,
	float StepTS,
	rotator StepView,
	vector StepLoc,
	int NumRockets,
	optional bool bTight
) {
	local int ShotSerial;
	local int RecoveredRockets;
	local bool bHadAltCycle;

	if (Role != ROLE_Authority || !UsesServerMoveV4())
		return false;
	if (AmmoType == none || AmmoType.AmmoAmount <= 0)
		return false;

	ShotSerial = V4ServerShotSerial;
	if (ShotKind == IGPLUS_EB_SHOT_KIND_ALT) {
		// bbPlayer already validated the normal current/previous fire window.
		// Resolve the packed release directly so live switch-cancel input does
		// not discard a release that was predicted before the switch.
		V4AdvanceStepClock(StepTS);
		if (V4CooldownRemaining > 0.0001)
			return false;
		bHadAltCycle = bV4WasAltHeld;
		V4RefreshInternalBudget();
		if (bHadAltCycle)
			RecoveredRockets = V4CalculateCharge(V4AltLoadElapsed);
		else
			RecoveredRockets = 1;
		RecoveredRockets = Min(RecoveredRockets, Clamp(NumRockets, 1, 6));
		if (!bHadAltCycle)
			V4PlayServerChargeSound(true);
		else if (RecoveredRockets > V4CachedChargeData)
			V4PlayServerChargeSound(false);
		bV4WasAltHeld = false;
		V4AltLoadElapsed = 0.0;
		V4CachedChargeData = RecoveredRockets;
		HandleV4ServerAltFire(StepView, StepLoc, RecoveredRockets);
		if (V4ServerShotSerial != ShotSerial)
			V4StartCooldown(V4PostFireInterval(RecoveredRockets));
	} else if (ShotKind == IGPLUS_EB_SHOT_KIND_PRIMARY_LOADED) {
		if (!V4HasCommittedPrimary())
			V4ProcessInputSlice(
				StepTS, StepView, StepLoc,
				true, false, false, false,
				true, true, 0, true, false);
		if (bTight)
			bV4PrimaryTightLatched = true;
		if (V4HasCommittedPrimary())
			V4ProcessInputSlice(
				StepTS, StepView, StepLoc,
				false, false, false, false,
				true, true, NumRockets, true, false);
	} else if (ShotKind == IGPLUS_EB_SHOT_KIND_PRIMARY_INSTANT) {
		if (!V4OwnerInstantEnabled() || V4HasCommittedPrimary())
			return false;
		V4ProcessInputSlice(
			StepTS, StepView, StepLoc,
			true, false, false, false,
			true, true, 1, true, true);
	} else {
		return false;
	}

	return V4ServerShotSerial != ShotSerial;
}

// Client-side instant rocket fire driven by V4ProcessInputSlice.
// Plays the fire animation and spawns visual-only rockets, then the
// ClientV4InstantFire state handles the reload anim before going idle.
// V4ProcessInputSlice calls this again when the next cooldown expires.
simulated function HandleV4ClientFire() {
	local bbPlayer bbP;

	V4EmitClientAuthoritativeShot(IGPLUS_EB_SHOT_KIND_PRIMARY_INSTANT, 1);

	V4ConsumeClientAmmo(1);

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

// Client-side loaded rocket fire driven by V4ProcessInputSlice's falling edge.
// Syncs ClientRocketsLoaded to the server's count before firing so both
// sides agree on the number of rockets/grenades spawned.
simulated function HandleV4ClientLoadedFire(bool bAlt, int NumRockets, optional bool bTight) {
	if (bAlt && V4HasSwitchAwayRequest()) {
		V4CancelDeterministicLoad(false);
		return;
	}

	// Primary-only: if authoritative auto-fire interrupts during rotate,
	// the final load sound may never be reached via AnimEnd.
	if (Role < ROLE_Authority && !bAlt && IsV4Active() && IsInState('ClientFiring')
		&& bRotated && NumRockets > ClientRocketsLoaded
		&& Owner != None && Pawn(Owner) != None)
		Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);

	if (bAlt)
		V4EmitClientAuthoritativeShot(IGPLUS_EB_SHOT_KIND_ALT, NumRockets);
	else
		V4EmitClientAuthoritativeShot(IGPLUS_EB_SHOT_KIND_PRIMARY_LOADED, NumRockets, bTight);

	V4FinalizeClientLoadedAmmo(NumRockets);

	ClientRocketsLoaded = NumRockets;
	V4CachedChargeData = NumRockets;

	// Use the same tightwad edge decision as the server step.
	bTightWad = !bAlt && bTight;
	FiringRockets();
	bTightWad = false;
}

// Spawn rockets on the server using the deterministic data path in FireRockets.BeginState.
function HandleV4ServerFire(rotator StepView, vector StepLoc, int NumRockets, bool bTight) {
	local PlayerPawn P;

	if (!V4PrepareServerFireContext(StepView, StepLoc, NumRockets, P))
		return;

	V4ServerShotSerial = (V4ServerShotSerial + 1) & 0x7FFFFFFF;
	if (bV4PrimaryLatchedInstant)
		V4ServerLastShotKind = IGPLUS_EB_SHOT_KIND_PRIMARY_INSTANT;
	else
		V4ServerLastShotKind = IGPLUS_EB_SHOT_KIND_PRIMARY_LOADED;
	bV4SwitchSettlementPending = false;
	V4ArmServerFireState(NumRockets, true, bTight);
	if (P.PendingWeapon != none && P.PendingWeapon != self) {
		P.PlayRecoil(FiringSpeed);
		bChangeWeapon = true;
	}
	GoToState('FireRockets');
}

// Spawn grenades on the server using deterministic step loc/view.
function HandleV4ServerAltFire(rotator StepView, vector StepLoc, int NumRockets) {
	local PlayerPawn P;

	if (!V4PrepareServerFireContext(StepView, StepLoc, NumRockets, P))
		return;

	V4ServerShotSerial = (V4ServerShotSerial + 1) & 0x7FFFFFFF;
	V4ServerLastShotKind = IGPLUS_EB_SHOT_KIND_ALT;
	bV4SwitchSettlementPending = false;
	V4ArmServerFireState(NumRockets, false);
	// Ammo is already consumed: spawn the volley, then switch (stock order).
	if (P.PendingWeapon != none && P.PendingWeapon != self)
		bChangeWeapon = true;
	GoToState('FireRockets');
}

// One owner's deterministic state must never transfer to the next.
simulated function V4ResetDeterministicState() {
	V4ClearPendingServerFireState();
	V4ResetPrimaryCycle(true);
	V4ResetAltCycle(true);
	V4CooldownRemaining = 0.0;
	V4LastStepTS = 0.0;
	V4LastStepDelta = 0.0;
	V4CachedChargeData = 0;
	V4InternalBudget = 0;
	V4ClientAmmoSpentSinceDown = 0;
	V4ClientLastDownTS = 0.0;
	ClientRocketsLoaded = 0;
	bClientDone = false;
	bRotated = false;
	V4ClearPendingAltInput();
	bV4SwitchSettlementPending = false;
	V4ServerShotSerial = 0;
	V4ServerLastShotKind = -1;
}

function GiveTo(Pawn Other)
{
	V4ResetDeterministicState();
	Super.GiveTo(Other);
}

function DropFrom(vector StartLocation)
{
	local int DropCharge;
	local bool bShouldCancel;

	DropCharge = V4GetChargeDataForMove();
	bShouldCancel = Role == ROLE_Authority
		&& IsV4Active()
		&& (bV4PrimaryCycleActive || bV4WasFireHeld || bV4WasAltHeld);

	// Mirror switch-away behavior: rockets/grenades committed into an active
	// deterministic load stay spent when the weapon is thrown.
	if (bShouldCancel)
		V4CancelDeterministicLoad(true, DropCharge);

	V4ResetDeterministicState();
	Super.DropFrom(StartLocation);
}

function Finish()
{
	V4ResetPrimaryCycle(true);
	V4ResetAltCycle(true);

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
	if (IsV4Active()) {
		return;
	}

	Super.Fire(Value);
}

function AltFire( float Value )
{
	if (IsV4Active()) {
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
	// Instant rockets: V4ProcessInputSlice drives fire timing via HandleV4ClientFire.
	if (V4ShouldBypassLegacyClientInput())
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
	if (V4ShouldBypassLegacyClientInput())
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

	// V4 cooldown is owned by the per-step duration clock.

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
			V4ResetFireRocketsState();
			return;
		}

		PawnOwner = Pawn(Owner);
		if (PawnOwner == None)
		{
			V4ResetFireRocketsState();
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

		if ( !bUseV4ServerFireData && PawnOwner.bAltFire != 0 )
			bTightWad = true;

		if (bUseV4ServerFireData)
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
	if (IsV4Active() && (Pawn(Owner).bFire != 0 || Pawn(Owner).bAltFire != 0)) {
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
	if (IsV4Active()) {
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
	if (Role == ROLE_Authority && bV4SwitchSettlementPending)
		V4FinalizeSwitchSettlement();
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	// A tap banked during cooldown must not survive into a fresh equip —
	// stock clears its force latches here too.
	bV4CooldownFireTap = false;
	bV4CooldownAltTap = false;
	V4ResetPrimaryCycle(true);
	V4ResetAltCycle(true);
	bV4SwitchSettlementPending = false;
	if (Pawn(Owner) != none) {
		if (Pawn(Owner).bFire != 0 && !V4OwnerInstantEnabled())
			bV4SuppressPrimaryFirstBudgetAuto = true;
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

	if (Role < ROLE_Authority || !IsV4Active())
		V4ResetPrimaryCycle(true);
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

simulated function bool V4HandleClientLoadAnimEnd(bool bAltLoad) {
	local int LoadBudget;
	local int TargetLoaded;
	local int ConsumeDelta;

	if (!IsV4Active())
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
		V4RefreshInternalBudget();
		LoadBudget = Min(6, Max(1, V4InternalBudget));
		TargetLoaded = Clamp(V4CachedChargeData, 1, LoadBudget);
	} else {
		LoadBudget = Min(6, Max(1, V4PrimaryCycleStartBudget));
		TargetLoaded = Clamp(V4PrimaryPredictedLoaded, 1, LoadBudget);
	}

	if (bRotated) {
		PlayLoading(1.1, ClientRocketsLoaded);
		bRotated = false;
		if (ClientRocketsLoaded > TargetLoaded) {
			ClientRocketsLoaded = TargetLoaded;
		} else if (TargetLoaded > ClientRocketsLoaded) {
			ConsumeDelta = TargetLoaded - ClientRocketsLoaded;
			if (!V4ConsumeClientAmmo(ConsumeDelta))
				return true;
			ClientRocketsLoaded = TargetLoaded;
		}
		V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
		return true;
	}

	V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
	if (ClientRocketsLoaded >= LoadBudget)
		return true;

	PlayRotating(ClientRocketsLoaded - 1);
	bRotated = true;
	return true;
}

// =========================================================================
// Client State Management
// =========================================================================

// Lightweight state for instant rocket V4 fire+reload animation cycle.
// V4ProcessInputSlice drives fire timing via HandleV4ClientFire; this state
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
	simulated function Tick(float DeltaTime)
	{
		local Pawn P;

		P = Pawn(Owner);
		if (P == none)
			return;

		if ((P.bFire == 0) || (AmmoType == none) || (AmmoType.AmmoAmount <= 0)) {
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		if (V4HandleClientLoadAnimEnd(false))
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
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
		}
		else
		{
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
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
		if (IsV4Active())
			Disable('Tick');

		// Instant V4: HandleV4ClientFire drives fire, not ClientFiring.
		if (bInstantRocket && IsV4Active()) {
			GotoState('');
			return;
		}

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
		V4CachedChargeData = 0;
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
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			FiringRockets();
		}
	}
	
	simulated function AnimEnd()
	{
		if (V4HandleClientLoadAnimEnd(true))
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
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
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
		if (IsV4Active())
			Disable('Tick');
		
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
		if (IsV4Active())
			return bCanClientFire && (Pawn(Owner) != None) && ((AmmoType == None) || (AmmoType.AmmoAmount > 0));

		return Super.ClientFire(Value);
	}

	simulated function bool ClientAltFire(float Value)
	{
		if (IsV4Active())
			return bCanClientFire && (Pawn(Owner) != None) && ((AmmoType == None) || (AmmoType.AmmoAmount > 0));

		return Super.ClientAltFire(Value);
	}

	simulated function AnimEnd()
	{
		if (IsV4Active()) {
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
		if (Role == ROLE_Authority && IsV4Active())
			bV4SwitchSettlementPending = true;
		else
			V4ResetPrimaryCycle(true);
		Super.BeginState();
	}
}

state ClientDown
{
	simulated function BeginState()
	{
		if (Level != none)
			V4ClientLastDownTS = Level.TimeSeconds;
		V4ResetPrimaryCycle(true);
		V4ResetAltCycle(true);
		V4ClientAmmoSpentSinceDown = 0;
		Super.BeginState();
	}
}

defaultproperties {
	V4LastStepTS=-1.0
}
