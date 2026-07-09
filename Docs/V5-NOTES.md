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
  binding constrains *which* weapon a move may drive; the fire-window
  invariants from the second hardening pass (below) constrain *when* — only
  with both is the `bStepReadyHint` bypass inside the weapons reduced to
  bridging soft timing skew (select-anim completion, switch-guard timer)
  for honest clients.

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
  exactly that case; since the second hardening pass it rides self-contained
  in `V4AuxData` (it no longer rewrites the move's DetReady/weapon-index/
  charge bits), and when it lands on a move bound to another weapon the
  server feeds the eightball one no-input recovery step instead. With the
  server-side time cap it can only lower the count, so the layers compose
  safely.
- **Server-side `FRand()` in multi-grenade/flak spread**: server-authoritative
  cosmetics; the client does not predict those trajectories.

## Second hardening pass (July 2026)

An independent review of the first pass confirmed all of its claims except
one: "the `bStepReadyHint` bypass is now safe" was overstated. The binding
invariant constrained which weapon a move may drive but not when — the hint
still skipped the switch guard and the equipped-weapon check for the
`PendingWeapon`/grace weapons the binding deliberately admits, leaving a
modified client zero-bring-up switch-fire and sustained two-weapon fire via
ping-ponged switches. This pass closes that, plus the honest-client edge
cases the review surfaced.

### Fire-window invariants (server-side, move-timestamp domain)
- **Bring-up gate** (`bbPlayer.IGPlus_V4FireWindowOpen`): a weapon entering
  the valid-binding set (equipped via `ChangedWeapon`, or pending as first
  observed from move processing) runs no deterministic steps until 0.12s
  (fast switch — the client-side guard floor) / 0.25s (normal — conservative
  fraction of any select anim) later. Canceling a pending switch re-arms the
  equipped weapon's gate, so toggling `PendingWeapon` is never free.
- **Switch exclusivity**: initiating a switch closes the equipped weapon's
  window 0.12s after the `PendingWeapon` change is observable in the move
  stream, and the prev-weapon grace now accepts only steps *timestamped* at
  or before (about) the switch — the in-flight case it exists for. At any
  step timestamp, at most one weapon of a switch pair has an open window.
- A closed window skips dispatch exactly like the dormancy an honest
  client's `bDetReady=false` produces around switches: no edges are
  synthesized, machines self-heal as after a lost move. Enforced once, at
  the `IGPlus_V4ProcessWeaponStep` funnel.
- **Residual bound**: a modified client can still alternate two weapons at
  the gate cadence — approximately what an honest player achieves under
  fast weapon switch, but faster than honest under normal switch settings
  (the server cannot yet know exact per-weapon select time; that lands with
  move-stream switching, roadmap item 3).
- **Lifecycle**: all switch trust state (grace, gates, pending tracking,
  held-fire snapshot) is cleared on death and respawn. The stale held-fire
  snapshot could previously restore `bFire=1` on the respawn
  `ChangedWeapon` after the player had already released while dead.

### Honest-client fixes
- **Shot pack self-contained** (`V4AuxData` bits 0-7 seq, 8-11 charge): the
  pack no longer rewrites the carrying move's DetReady/weapon-index/charge
  bits. That rewrite hijacked moves bound to another weapon for ~1 RTT
  after a volley (misrouting their fire edges into the eightball machine)
  and clobbered a primary release's charge report landing in the same
  window (under-firing it). Lost-release recovery on a move bound to
  another weapon now runs as one no-input eightball step; packs are only
  acked when applicable.
- **Release-cap slack scales with the sub-step** (`FMax(0.06s, step
  delta)`): under a lag hitch or the coarse 469 sub-step path, the fixed
  60ms slack could shave a rocket off an honest volley when the release
  landed on a boundary lagging the client's true load time by a whole step.
- **Bio and shock guarded `Idle`**: the out-of-ammo auto-switch guard in
  `Finish()` was only backed by a pending-aware `Idle` on flak, ripper, and
  eightball. Bio (inheriting `Engine.Weapon.Idle`) re-clobbered the manual
  choice from the inherited `Begin` label; shock could leave a pending
  switch sitting in Idle with fast switch off. Both now bounce pending
  switches to `DownWeapon` in `BeginState`, like flak/ripper.

## Roadmap status (July 2026 — third pass)

1. **Collapse the mode matrix — DONE.** The per-move `bDetReady` bit no
   longer selects code paths on either transport. The server resolves the
   bound weapon and steps its deterministic machine for every move;
   `bDetReady` survives only as the readiness hint bridging honest
   client/server timing skew, and non-hinted moves fall back to the
   weapon's own server-side readiness for stock-like timing. Machines'
   clocks and edge state now advance through switches and bring-up, so
   self-heal no longer waits for the next hinted move. The whole-move
   dispatch remains solely as the transport fallback (v3 moves under ping
   comp). Deployment policy: rewind ping comp on → v5 deterministic for
   supported weapons; ping comp off → legacy base ServerMove on standard
   tick; NewNet client-authoritative weapons are a separate system.

2. **Per-slice client prediction — DONE.** The client predicts each input
   slice at its own timestamp with pre-movement location and current view
   (in `xxReplicateMove`, before the slice is merged), matching the
   server's per-sub-step replay. Input replication already predicted per
   input node.

3. **Weapon switching in the input stream — SUPERSEDED.** The original
   plan assumed the client could stamp switch intent into moves, but stock
   switching execs (`SwitchWeapon`, `NextWeapon`, `GetWeapon`, ...) are
   server-replicated: their bodies never run client-side (the same reason
   ThrowWeapon's old `NM_Client` branch was unreachable), so the server
   always learns of a switch *first* and its switch state is the
   authoritative timeline — there is no client-side moment to encode. The
   goals the item existed for are covered elsewhere: the trust/skew hole is
   closed by the binding + fire-window invariants (move-timestamp domain),
   and the eightball's switch-away cancel is delivered even through closed
   windows via a no-input, no-hint step. What a literal implementation
   would still buy — exact per-weapon select-time gates instead of the
   conservative 0.12s/0.25s floor — is blocked on reliable per-weapon
   select-anim durations, and would require client-side switch origination
   (input rebinding) to be meaningful. Revisit only if the residual bound
   (cheater switch-fire ≈ honest fast-switch cadence) proves to matter on
   normal-switch servers.

4. **Replay-based tests — SKIPPED (manual testing instead).** The
   deterministic machines remain pure functions of input timelines, so a
   `IGPlus_TestCommandlet` harness (feeding recorded timelines, asserting
   shot timestamps/counts against stock parity: shock 0.794s, load
   0.9s/rocket, bio 0.5s/charge, ...) stays the right shape if automated
   coverage is ever wanted. For now the checklist below is the gate, run
   manually per release.

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
- Fire immediately after every kind of switch completion, fast switch on
  and off (bring-up gate: first shot lands at the honest floor, none eaten).
- Rocket volley → instant switch → fire the new weapon, on a lossy
  connection (self-contained pack: no misrouted edges, no under-fired
  volley, recovery volley still lands).
- Rocket release during a simulated lag spike (sub-step slack: full count).
- Run bio and shock dry with a manual switch pending, fast switch off
  (guarded Idle: the chosen weapon comes up, no auto-switch override).
- Die while holding fire, release while dead, respawn (no phantom shot).
- Mid-move press/release at high fps and low net update rate (per-slice
  prediction: client shot direction/timing matches the server's, no
  interpolated-view divergence on fast flicks).
- Hold fire through a switch to a v4 weapon and wait (always-on machines:
  fire resumes at server-side readiness — stock feel — without the client
  re-asserting; no early fire during bring-up).
- Grenade load → switch away at various pings (switch-away cancel still
  consumes the committed load; no frozen load resuming on switch-back).
