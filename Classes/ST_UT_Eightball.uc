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

// Rate limiting to prevent rapid fire exploits
var float LastClientFireTime;
const FIRE_RATE_LIMIT = 0.25;

// V4 deterministic fire — shared between client and server
var float NextV4FireTS;
var float V4LoadStartTS;
var float V4AltLoadStartTS;
var bool bV4WasFireHeld;
var bool bV4WasAltHeld;
var bool bV4MoveInstantValid;
var bool bV4MoveInstant;
var int V4CachedChargeData;
var bool bV4PrimaryTightWad;
var bool bV4PrimaryCycleInstant;
var int V4PrimaryCycleCharge;
var int V4AltCycleCharge;
var int V4PrimaryCycleAmmoBudget;
var int V4AltCycleAmmoBudget;
var bool bV4PrimaryReleaseArmed;
var bool bV4AltReleaseArmed;
var float V4PrimaryReleaseTS;
var float V4AltReleaseTS;


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

simulated function V4SetMoveInstantMode(bool bValid, bool bInstant) {
	bV4MoveInstantValid = bValid;
	bV4MoveInstant = bInstant;
}

simulated function int V4HintCharge(optional int ChargeHint) {
	return Clamp(ChargeHint, 0, 6);
}

simulated function int V4ResolveShotCharge(int CycleCharge, int ChargeHint) {
	local int Hint;
	Hint = V4HintCharge(ChargeHint);
	if (CycleCharge > Hint)
		Hint = CycleCharge;
	return Clamp(Hint, 1, 6);
}

simulated function V4ResetPrimaryCycle(optional bool bClearHeld) {
	if (bClearHeld)
		bV4WasFireHeld = false;
	bV4PrimaryCycleInstant = false;
	V4PrimaryCycleCharge = 0;
	V4PrimaryCycleAmmoBudget = 0;
	bV4PrimaryTightWad = false;
	bV4PrimaryReleaseArmed = false;
	V4PrimaryReleaseTS = 0.0;
}

simulated function V4ResetAltCycle(optional bool bClearHeld) {
	if (bClearHeld)
		bV4WasAltHeld = false;
	V4AltCycleCharge = 0;
	V4AltCycleAmmoBudget = 0;
	bV4AltReleaseArmed = false;
	V4AltReleaseTS = 0.0;
}

simulated function int V4GetChargeDataForMove() {
	local int Charge;
	Charge = Clamp(V4CachedChargeData, 0, 7);
	if ((IsInState('ClientFiring') || IsInState('ClientAltFiring')) && ClientRocketsLoaded > Charge)
		Charge = Clamp(ClientRocketsLoaded, 0, 7);
	return Charge;
}

simulated function bool V4ConsumeClientAmmo(int Amount) {
	if (Amount <= 0)
		return true;
	if (AmmoType == none)
		return false;
	if (AmmoType.AmmoAmount <= 0) {
		AmmoType.AmmoAmount = 0;
		return false;
	}
	AmmoType.AmmoAmount = Max(0, AmmoType.AmmoAmount - Amount);
	return true;
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

// No-op stub: bbPlayer still calls this when decoding shot-packs from moves.
// Eightball no longer uses the auth-shot queue; edge detection handles fire.
simulated function V4QueueAuthoritativeShot(
	int Seq, int ShotKind, float ShotTS, rotator ShotView,
	vector ShotLoc, int Charge, bool bInstant, bool bTight
) {}

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
	local int MaxCycleRockets;
	local bool bMoveInstant;

	if (!bStepReadyHint && !IsDeterministicReady())
		return true;

	if (TournamentPlayer(Owner) != none)
		bMoveInstant = TournamentPlayer(Owner).bInstantRocket;
	else if (bV4MoveInstantValid)
		bMoveInstant = bV4MoveInstant;
	else
		bMoveInstant = bInstantRocket;
	if (bV4MoveInstantValid && TournamentPlayer(Owner) != none && bMoveInstant != bV4MoveInstant && V4ShouldDebug())
		V4Log("[DBG] Instant mismatch move="$bV4MoveInstant$" owner="$bMoveInstant$" StepTS="$StepTS);
	bInstantRocket = bMoveInstant;

	// ── PRIMARY FIRE ──

	if (bFireHeld && !bV4WasFireHeld && StepTS + 0.0001 < NextV4FireTS)
		return true;

	if (bFireHeld && !bV4WasFireHeld) {
		V4ResetPrimaryCycle(false);
		bV4WasAltHeld = false;
		bV4PrimaryCycleInstant = bMoveInstant;
		if (bV4PrimaryCycleInstant) {
			V4PrimaryCycleCharge = 1;
			if (bServerSide) {
				V4Log("[SRV] Rising INSTANT fire StepTS="$StepTS$" View="$StepView.Pitch$","$StepView.Yaw$" NextV4Fire="$NextV4FireTS$" Ammo="$AmmoType.AmmoAmount);
				if (AmmoType != none && AmmoType.AmmoAmount > 0)
					HandleV4ServerFire(StepView, StepLoc, 1, bAltHeld);
				else
					V4HandleOutOfAmmo();
			} else {
				HandleV4ClientFire();
			}
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(1));
			} else {
				if (AmmoType == none || AmmoType.AmmoAmount <= 0) {
					if (bServerSide)
						V4HandleOutOfAmmo();
					V4ResetPrimaryCycle(false);
					return true;
				}
				V4LoadStartTS = StepTS;
				V4PrimaryCycleAmmoBudget = Clamp(AmmoType.AmmoAmount, 0, 6);
				V4PrimaryCycleCharge = V4ResolveShotCharge(0, V4ChargeData);
				bV4PrimaryTightWad = bAltHeld;
				if (!bServerSide)
					V4EnsureClientLoadState(false);
				if (bServerSide) {
					V4Log("[SRV] Rising LOAD start StepTS="$StepTS$" V4Charge="$V4ChargeData$" Budget="$V4PrimaryCycleAmmoBudget);
					SetTimer(0, false);
				}
			}
		bV4WasFireHeld = true;
		return true;
	}

	if (bFireHeld && bV4WasFireHeld && bV4PrimaryCycleInstant) {
		if (StepTS + 0.0001 < NextV4FireTS)
			return true;
		if (bServerSide) {
			V4Log("[SRV] Held INSTANT fire StepTS="$StepTS$" View="$StepView.Pitch$","$StepView.Yaw$" Ammo="$AmmoType.AmmoAmount);
			if (AmmoType != none && AmmoType.AmmoAmount > 0)
				HandleV4ServerFire(StepView, StepLoc, 1, bAltHeld);
			else
				V4HandleOutOfAmmo();
		} else {
			HandleV4ClientFire();
		}
		NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(1));
		return true;
	}

	if (bFireHeld && bV4WasFireHeld && !bV4PrimaryCycleInstant) {
		if (!bServerSide)
			V4EnsureClientLoadState(false);
		if (bV4PrimaryReleaseArmed)
			bV4PrimaryReleaseArmed = false;

		if (bAltHeld)
			bV4PrimaryTightWad = true;
		if (V4HintCharge(V4ChargeData) > V4PrimaryCycleCharge)
			V4PrimaryCycleCharge = V4HintCharge(V4ChargeData);
		bV4WasAltHeld = false;

		MaxCycleRockets = Clamp(V4PrimaryCycleAmmoBudget, 0, 6);
		if (MaxCycleRockets <= 0 && AmmoType != none)
			MaxCycleRockets = Clamp(AmmoType.AmmoAmount, 0, 6);

		if (MaxCycleRockets <= 0) {
			NumRockets = V4ResolveShotCharge(V4PrimaryCycleCharge, V4ChargeData);
			if (bServerSide) {
				V4Log("[SRV] Auto-fire EMPTY StepTS="$StepTS$" V4Charge="$V4ChargeData$" rockets="$NumRockets$" tight="$bV4PrimaryTightWad);
				if (NumRockets > 0)
					HandleV4ServerFire(StepView, StepLoc, NumRockets, bV4PrimaryTightWad);
				else
					V4HandleOutOfAmmo();
			} else {
				HandleV4ClientLoadedFire(false, NumRockets, bV4PrimaryTightWad);
			}
			V4ResetPrimaryCycle(true);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			return true;
		}

		if (MaxCycleRockets < 6 && V4PrimaryCycleCharge >= MaxCycleRockets) {
			NumRockets = MaxCycleRockets;
			if (bServerSide) {
				V4Log("[SRV] Auto-fire CAP StepTS="$StepTS$" cap="$MaxCycleRockets$" V4Charge="$V4ChargeData$" rockets="$NumRockets$" tight="$bV4PrimaryTightWad);
				if (NumRockets > 0)
					HandleV4ServerFire(StepView, StepLoc, NumRockets, bV4PrimaryTightWad);
				else
					V4HandleOutOfAmmo();
			} else {
				HandleV4ClientLoadedFire(false, NumRockets, bV4PrimaryTightWad);
			}
			V4ResetPrimaryCycle(true);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			return true;
		}

			if ((V4PrimaryCycleCharge >= 6 || V4HintCharge(V4ChargeData) >= 6)
				&& (StepTS - V4LoadStartTS) > 3.0) {
				NumRockets = 6;
				if (MaxCycleRockets > 0)
					NumRockets = Min(6, MaxCycleRockets);
				if (bServerSide) {
					V4Log("[SRV] Auto-fire 6pack StepTS="$StepTS$" V4Charge="$V4ChargeData$" LoadStart="$V4LoadStartTS$" elapsed="$(StepTS - V4LoadStartTS)$" rockets="$NumRockets$" tight="$bV4PrimaryTightWad);
					if (NumRockets > 0)
						HandleV4ServerFire(StepView, StepLoc, NumRockets, bV4PrimaryTightWad);
				else
					V4HandleOutOfAmmo();
			} else {
				HandleV4ClientLoadedFire(false, NumRockets, bV4PrimaryTightWad);
			}
			V4ResetPrimaryCycle(true);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			return true;
		}
		return true;
	}

	if (!bFireHeld && bV4WasFireHeld) {
		if (bV4PrimaryCycleInstant) {
			// Instant release should end held-edge tracking so a later
			// release frame cannot execute non-instant falling-edge fire.
			V4ResetPrimaryCycle(true);
			return true;
		}
		// Ignore single-step held-input dips.
		if (!bV4PrimaryReleaseArmed) {
			bV4PrimaryReleaseArmed = true;
			V4PrimaryReleaseTS = StepTS;
			return true;
		}
		if (StepTS <= V4PrimaryReleaseTS + 0.0001)
			return true;
		bV4PrimaryReleaseArmed = false;
		bV4WasFireHeld = false;
		NumRockets = V4ResolveShotCharge(V4PrimaryCycleCharge, V4ChargeData);
		if (V4PrimaryCycleAmmoBudget > 0)
			NumRockets = Min(NumRockets, Clamp(V4PrimaryCycleAmmoBudget, 1, 6));
		if (bServerSide) {
			if (AmmoType != none && AmmoType.AmmoAmount > 0) {
				NumRockets = Min(NumRockets, AmmoType.AmmoAmount);
				V4Log("[SRV] Falling edge FIRE StepTS="$StepTS$" V4Charge="$V4ChargeData$" rockets="$NumRockets$" tight="$bV4PrimaryTightWad$" View="$StepView.Pitch$","$StepView.Yaw);
				HandleV4ServerFire(StepView, StepLoc, NumRockets, bV4PrimaryTightWad);
			} else {
				V4HandleOutOfAmmo();
			}
		} else {
			HandleV4ClientLoadedFire(false, NumRockets, bV4PrimaryTightWad);
		}
		V4ResetPrimaryCycle(false);
		NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
		return true;
	}

	// ── ALT FIRE (GRENADES) ──

	if (bAltHeld && !bV4WasAltHeld && StepTS + 0.0001 < NextV4FireTS)
		return true;

	if (bAltHeld && !bV4WasAltHeld) {
		V4ResetAltCycle(false);
		if (AmmoType == none || AmmoType.AmmoAmount <= 0) {
			if (bServerSide)
				V4HandleOutOfAmmo();
			V4ResetAltCycle(false);
			return true;
		}
		V4AltLoadStartTS = StepTS;
		V4AltCycleAmmoBudget = Clamp(AmmoType.AmmoAmount, 0, 6);
		V4AltCycleCharge = V4ResolveShotCharge(0, V4ChargeData);
		if (!bServerSide)
			V4EnsureClientLoadState(true);
		if (bServerSide) {
			V4Log("[SRV] Rising ALT LOAD start StepTS="$StepTS$" V4Charge="$V4ChargeData$" Budget="$V4AltCycleAmmoBudget);
			SetTimer(0, false);
		}
		bV4WasAltHeld = true;
		return true;
	}

	if (bAltHeld && bV4WasAltHeld) {
		if (!bServerSide)
			V4EnsureClientLoadState(true);
		if (bV4AltReleaseArmed)
			bV4AltReleaseArmed = false;
		if (V4HintCharge(V4ChargeData) > V4AltCycleCharge)
			V4AltCycleCharge = V4HintCharge(V4ChargeData);

		MaxCycleRockets = Clamp(V4AltCycleAmmoBudget, 0, 6);
		if (MaxCycleRockets <= 0 && AmmoType != none)
			MaxCycleRockets = Clamp(AmmoType.AmmoAmount, 0, 6);

		if (MaxCycleRockets <= 0) {
			NumRockets = V4ResolveShotCharge(V4AltCycleCharge, V4ChargeData);
			if (bServerSide) {
				V4Log("[SRV] Auto-fire ALT EMPTY StepTS="$StepTS$" V4Charge="$V4ChargeData$" grenades="$NumRockets);
				if (NumRockets > 0)
					HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
				else
					V4HandleOutOfAmmo();
			} else {
				HandleV4ClientLoadedFire(true, NumRockets, false);
			}
			V4ResetAltCycle(true);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			return true;
		}

		if (MaxCycleRockets < 6 && V4AltCycleCharge >= MaxCycleRockets) {
			NumRockets = MaxCycleRockets;
			if (bServerSide) {
				V4Log("[SRV] Auto-fire ALT CAP StepTS="$StepTS$" cap="$MaxCycleRockets$" V4Charge="$V4ChargeData$" grenades="$NumRockets);
				if (NumRockets > 0)
					HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
				else
					V4HandleOutOfAmmo();
			} else {
				HandleV4ClientLoadedFire(true, NumRockets, false);
			}
			V4ResetAltCycle(true);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			return true;
		}

		if ((V4AltCycleCharge >= 6 || V4HintCharge(V4ChargeData) >= 6)
			&& (StepTS - V4AltLoadStartTS) > 3.0) {
			NumRockets = 6;
			if (MaxCycleRockets > 0)
				NumRockets = Min(6, MaxCycleRockets);
			if (bServerSide) {
				V4Log("[SRV] Auto-fire ALT 6pack StepTS="$StepTS$" V4Charge="$V4ChargeData$" LoadStart="$V4AltLoadStartTS$" elapsed="$(StepTS - V4AltLoadStartTS)$" grenades="$NumRockets);
				if (NumRockets > 0)
					HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
				else
					V4HandleOutOfAmmo();
			} else {
				HandleV4ClientLoadedFire(true, NumRockets, false);
			}
			V4ResetAltCycle(true);
			NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
			return true;
		}
		return true;
	}

	if (!bAltHeld && bV4WasAltHeld) {
		if (!bV4AltReleaseArmed) {
			bV4AltReleaseArmed = true;
			V4AltReleaseTS = StepTS;
			return true;
		}
		if (StepTS <= V4AltReleaseTS + 0.0001)
			return true;
		bV4AltReleaseArmed = false;
		bV4WasAltHeld = false;
		NumRockets = V4ResolveShotCharge(V4AltCycleCharge, V4ChargeData);
		if (V4AltCycleAmmoBudget > 0)
			NumRockets = Min(NumRockets, Clamp(V4AltCycleAmmoBudget, 1, 6));
		if (bServerSide) {
			if (AmmoType != none && AmmoType.AmmoAmount > 0) {
				NumRockets = Min(NumRockets, AmmoType.AmmoAmount);
				V4Log("[SRV] Falling edge ALT FIRE StepTS="$StepTS$" V4Charge="$V4ChargeData$" grenades="$NumRockets$" View="$StepView.Pitch$","$StepView.Yaw);
				HandleV4ServerAltFire(StepView, StepLoc, NumRockets);
			} else {
				V4HandleOutOfAmmo();
			}
		} else {
			HandleV4ClientLoadedFire(true, NumRockets, false);
		}
		V4ResetAltCycle(false);
		NextV4FireTS = V4AdvanceCooldown(NextV4FireTS, StepTS, V4PostFireInterval(NumRockets));
		return true;
	}

	return true;
}

// Client-side instant rocket fire driven by V4ProcessStep.
// Plays the fire animation and spawns visual-only rockets, then the
// ClientV4InstantFire state handles the reload anim before going idle.
// V4ProcessStep calls this again when the next cooldown expires.
simulated function HandleV4ClientFire() {
	local bbPlayer bbP;

	if (IsV4Active())
		V4ConsumeClientAmmo(1);
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
	V4ResetPrimaryCycle(true);
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

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
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

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
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
	if (Pawn(Owner).bFire!=0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0) AltFire(0.0);	
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
	V4ResetPrimaryCycle(true);
	V4ResetAltCycle(true);
	bTightWad = false;
	V4CachedChargeData = 0;
	ClientRocketsLoaded = 0;
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
		if ( (Pawn(Owner).bFire == 0) || (Ammotype.AmmoAmount <= 0) ) {
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			if (IsV4Active()) {
				V4Log("[CLI] Tick: release fire (V4 pending) rockets="$ClientRocketsLoaded$" V4Cached="$V4CachedChargeData$" Time="$Level.TimeSeconds);
				return;
			}
			V4Log("[CLI] Tick: release fire, rockets="$ClientRocketsLoaded$" V4Cached="$V4CachedChargeData$" Time="$Level.TimeSeconds);
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
				if (IsV4Active()) {
					V4Log("[CLI] AnimEnd: auto-fire (V4 pending) rockets="$ClientRocketsLoaded$" Time="$Level.TimeSeconds);
					return;
				}
				FiringRockets();
				return;
			}
			if (IsV4Active()) {
				if (!V4ConsumeClientAmmo(1))
					return;
				if (AmmoType != None && AmmoType.AmmoAmount <= 0)
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

		if (IsV4Active()) {
			if (!V4ConsumeClientAmmo(1)) {
				ClientRocketsLoaded = 0;
				V4CachedChargeData = 0;
				GotoState('');
				return;
			}
		} else if (AmmoType != None) {
			AmmoType.AmmoAmount--;
		}
		
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
		if ( (Pawn(Owner).bAltFire == 0) || (Ammotype.AmmoAmount <= 0) ) {
			V4CachedChargeData = Clamp(ClientRocketsLoaded, 0, 7);
			if (IsV4Active())
				return;
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
				if (!V4ConsumeClientAmmo(1))
					return;
				if (AmmoType != None && AmmoType.AmmoAmount <= 0)
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
		
		if (IsV4Active()) {
			if (!V4ConsumeClientAmmo(1)) {
				ClientRocketsLoaded = 0;
				V4CachedChargeData = 0;
				GotoState('');
				return;
			}
		} else if (AmmoType != None) {
			AmmoType.AmmoAmount--;
		}

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

defaultproperties {
}
