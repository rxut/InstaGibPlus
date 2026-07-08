# v5 — Production hardening of the ServerMove_v4 deterministic weapon system

This branch takes `xxServerMove_v4` and closes the gaps found in a full review
of the deterministic fire system, aiming for a production-ready state. The
architecture (input edge timelines + server-side deterministic weapon state
machines + client prediction of the same machines) is kept unchanged — the
review concluded it is the right long-term model. What changes is the trust
boundary, loss robustness, and a few stock-parity details.

## Changes on this branch

### Server-side trust enforcement
- **Eightball release charge** (`ST_UT_Eightball.V4ResolvePrimaryEdgeCharge`):
  the client-reported charge on a release/cancel edge can now only *lower*
  the rocket count. It is capped by the server-accumulated load time (with a
  60ms slack for step quantization at load boundaries). Previously a modified
  client could fire 6 rockets with zero load time.
- **Bio alt charge** (`ST_ut_biorifle.V4ProcessStep`): charge is derived from
  the server-tracked hold duration (`StepTS - V4AltChargeStartTS`, one level
  per 0.5s, matching stock). The client-sent `V4ChargeData` can only lower
  it. Previously the server consumed ammo straight from the client value,
  allowing an instant max-charge glob.
- **Weapon binding invariants** (`bbPlayer.IGPlus_V4ServerBindingValid`):
  deterministic dispatch now requires the move's `V4WeaponIndex` to resolve
  to the equipped weapon, the incoming `PendingWeapon`, or the weapon
  switched away from within a 0.25s grace window (move-timestamp domain,
  recorded in `ChangedWeapon`). Previously `bDetReady` let a client fire any
  owned, holstered v4 weapon and bypass all switch/readiness guards. The
  `bStepReadyHint` bypass inside the weapons is now safe because these hard
  invariants run before dispatch; the hint only bridges soft timing skew
  (select-anim completion, switch-guard timer) for honest clients.

### Robustness
- **`ClientV4PrimaryShotConfirm` is reliable.** It was `unreliable`; one lost
  packet left client rocket-count/load visuals diverged until the next
  volley. One RPC per volley is cheap.
- **Old-move replay stays active on shot-pack moves.** The pack rides in
  `V4AuxData`, not `OldMoveData`, so there was no wire conflict — the skip
  only sacrificed movement-loss recovery during rocket volleys.
- **Extra fire edges force a packet split.** The edge timeline encodes one
  press + one release per merged move; a second edge of the same kind used
  to be silently dropped. The client now sets `bForcePacketSplit` so the
  next slice starts a fresh move and rapid double-taps survive.

### Stock-parity fixes
- **Held fire is continuous across switches to non-v4 weapons.** v4-handled
  steps clear `bFire/bAltFire`; switching to a legacy weapon (translocator,
  hammer, pulse) while holding made the flags look like a fresh press edge —
  firing the new weapon mid-select and mistiming the translocator's
  dual-button check (the "switch to trans, piston comes out" family of
  reports). `ChangedWeapon` now restores the flags from the last move's
  timeline end-held state. This is the v4-native port of the master-branch
  fix (`master` commit "Fix spurious fire edge when switching away from
  ping-compensated weapons").
- **Out-of-ammo auto-switch no longer clobbers a manual choice.** The
  stock-derived `Finish()`/`Idle` paths in all five v4 weapons called
  `SwitchToBestWeapon()` unconditionally; with ping-comp's late ammo
  consumption this could override a `PendingWeapon` the player had just
  selected ("you switch to a weapon and it switches to impact hammer").
  They now skip the auto-switch when `PendingWeapon` is already set, and
  `Finish` always resolves to a state when the switch is declined.
- **Suppress-until-release latches removed.** They cleared after a single
  move regardless of release, were bypassed whenever a v4 edge timeline was
  present, and their client-side half sat in an unreachable `NM_Client`
  branch of a server-replicated exec. With the binding invariants in place,
  stale fire intent cannot reach another weapon — and held fire resuming
  after a throw/switch is stock UT behavior.

## Findings from the review that turned out to be fine (no change)
- **Instant-rocket flag**: already validated in the correct direction (a
  stale move flag can never force instant mode on); the wire bit is the
  deterministic per-move intent and the owner setting caps it.
- **Tightwad sampling**: alt is sampled per rocket-load step, mirroring
  stock's per-AnimEnd sample. Suppressing the primary rising edge while an
  alt (grenade) cycle is active also matches stock priority (alt held first
  = grenades).
- **Lost release moves self-heal**: the weapon machines detect falling edges
  from their own `bV4Was*Held` state vs the next move's start-held bit, so a
  lost release fires at the next move's first step with server-accumulated
  charge. The eightball shot-pack layer is the charge/context retransmit for
  exactly that case (it rewrites the packed DetReady/weapon-index/charge
  bits on later moves); with the server-side time cap it can only lower the
  count, so the layers now compose safely.
- **Server-side `FRand()` in multi-grenade/flak spread**: server-authoritative
  cosmetics; the client does not predict those trajectories.

## Deliberately deferred (roadmap, in suggested order)
1. **Collapse the mode matrix.** `bDetReady` is still a per-move client
   assertion selecting between deterministic / fallback / strict handling.
   With the binding invariants it is no longer exploitable, but the
   legacy/fallback paths triple the test surface. Target: negotiate v4
   support once per session, run supported weapons deterministically always,
   delete the fallback paths.
2. **Per-tick client prediction.** The client predicts once per *sent* move
   with end-of-move state while the server replays per sub-step; a mid-move
   press fires server-side with an interpolated view the client never
   rendered. Predicting per input slice (each slice is what the timeline
   encodes) would close most of the remaining divergence.
3. **Weapon switching in the input stream.** Switching still travels as
   stock RPC execs outside the move timeline — this is where the remaining
   wall-clock guard (`IGPlus_MarkDeterministicSwitchGuard`, 0.12s of
   `Level.TimeSeconds`) lives, and it is evaluated at different absolute
   times on client and server. A desired-weapon field per move (server
   switches at move-time, client predicts) would eliminate the guard class
   entirely, the same way the edge timeline eliminated the SendFire class.
4. **Replay-based tests.** The deterministic machines are pure functions of
   input timelines; a `IGPlus_TestCommandlet` harness feeding recorded
   timelines and asserting shot timestamps/counts would lock in stock parity
   per weapon (shock 0.794s, load 0.9s/rocket, bio 0.5s/charge, ...).

## Testing checklist for this branch
- Hold fire / hold alt through switches between every v4 weapon pair, and
  v4 → translocator / hammer / pulse (no mid-select fire, dual-button
  timing back to stock feel).
- Rocket loading: full 6-load, early release at each count, cancel by
  switch mid-load, tightwad (alt held during load), grenades, instant mode —
  under clean and lossy connections (confirm reliability, shot-pack path).
- Bio: alt charge levels 1–9 by hold time, release timing, out-of-ammo
  during charge.
- Run dry on each weapon while spamming a manual switch (no hammer
  surprise).
- Double-tap fire faster than one net update (both shots register).
- Rapid A↔B↔A switch spam while holding fire (binding grace: no eaten
  shots, no shots from holstered weapons).
