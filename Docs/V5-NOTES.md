# Deterministic weapons

This document describes the current system. Development chronology belongs in
Git history; the production contract, known policy choices, and release checks
live here.

## Architecture

Supported ST_ weapons use one deterministic model on client and server:

1. The stock v3 `xxServerMove` carries the bound weapon, readiness bit, view,
   and charge data in its existing bit fields.
2. The client predicts the weapon step before movement and move merging.
3. The server resolves the bound weapon and runs one whole-move weapon step
   with the move's timestamp and view.
4. Fresh fire starts only on a client-predicted step. Non-hinted steps may
   advance or settle an already committed cycle, but cannot start one.

Ping compensation off uses legacy weapon fire. NewNet client-authoritative
weapons are a separate system.

Supported weapons are:

- `ST_ShockRifle`
- `ST_ripper`
- `ST_UT_FlakCannon`
- `ST_ut_biorifle`
- `ST_UT_Eightball`
- `ST_SniperRifle`

## Trust boundaries

### Binding and activation

`IGPlus_DetResolveBoundWeapon` requires a supported, active ST_ weapon. In
server context, `IGPlus_DetServerBindingValid` further restricts it to:

- the equipped weapon;
- the incoming `PendingWeapon`; or
- the weapon just switched away from, during its timestamped grace window.

The readiness bit is a prediction hint, not authority. A pending weapon cannot
be client-vouched before `ChangedWeapon` equips it.

Both transports retain weapon identity and charge data when readiness is
false. Index None means no deterministic weapon, including Impact Hammer;
it never resolves to the server's equipped weapon. With ping compensation
enabled, rejected deterministic bindings cannot fall through to legacy fire.

### Fire windows

`IGPlus_DetFireWindowOpen` decides when a valid binding may step:

- bring-up is gated by the incoming weapon's replicated `SelectTime`
  (effective anim duration, speed-cap floored). The server computes the gate
  once in `ChangedWeapon` and replicates the exact timestamp to the owning
  client (`xxClientDetEntryGate`), so both sides hold the same number and any
  configured select time is safe. `IGPlus_DetEntryGateSeconds` (0.12/0.25) is
  the conservative fallback for the pending-weapon pre-equip window and
  cancel re-arm;
- starting a switch closes the equipped weapon after the in-flight allowance;
- previous-weapon grace accepts only pre-switch timestamped steps; and
- canceling a pending switch re-arms the equipped weapon's gate.

Closed windows do not synthesize edges. Charge weapons receive only the
no-input settlement step required to release or cancel committed state.

### Charge validation

- Eightball release/cancel count is capped by server-observed load time. The
  client report may only lower it. Boundary slack is the larger of 60 ms and
  the current move delta.
- Bio charge is derived from server-observed hold time at stock 0.5-second
  cadence. Client charge data may only lower it.

### Clock lead

Refire intervals and windows compare move timestamps, which are the client's
clock. Per move the server takes offset = move timestamp - server time. Network
delay only lowers it, so the baseline is the best offset seen (learned freely for
the first 2 s, then allowed to rise by 1% of elapsed server time for drift).
`IGPlus_DetFireClockLead` = offset - baseline. Lag spikes and bunched catch-up
never raise it; a fast clock does, steadily. While it exceeds
`DetFireClockMargin` (default 0.5 s), steps are treated as unhinted: no fresh
shots, committed cycles still resolve, and taps stay queued.

## Recovery behavior

- Redundancy is the stock `OldMoveData` movement heuristic. A lost fire-bearing
  move is lost, same as stock.
- A fire tap sets `bForceFire`, and `CanMergeMove` refuses to merge a move that
  carries one, so a tap always ends its move. Double-taps faster than one net
  update still produce two moves.
- A tap on a not-ready step is queued on the client for 0.8 s, bound to the
  equipped weapon it was pressed on (never one going down). On the first ready
  frame the client replays it as that move's force bit, so the server fires it
  on the same step; the server keeps no parallel queue on the ServerMove path
  (input replication still uses a server queue). A click on the outgoing weapon
  never fires the incoming one.
- The client is told of every pending switch on a Det weapon right away
  (`xxClientSwitchPending` from `IGPlus_DetTrackPendingWeapon`), not only when
  the holster starts, so a weapon that latches the request (Eightball in
  FireRockets) stops being predicted. The client also never predicts a weapon
  before the server's tagged entry gate for it arrives (`xxClientDetEntryGate`
  carries the weapon), so it can't fire the incoming weapon while the server
  is still holstering the old one.
- Eightball loads and bio charges are cancelled on switch-away, never fired:
  the client stops predicting once it knows of the switch, so a switch-time
  shot would exist only on the server.
- Merging splits on weapon identity and deterministic readiness, so an
  outgoing weapon's held input cannot be relabeled as the incoming weapon.
- Manual switch commands record pending transitions immediately, including
  cancellation between received moves. Both transports resume deferred
  holsters once the shot-animation hold expires.
- The stock-move transport also splits on the actual weapon object, including
  Hammer and Translocator, which both have deterministic index None.
- Translocator moves split on either fire button's press or release. Separate
  throw and teleport inputs cannot merge into a false two-button hold that
  returns to the previous weapon. Intentional two-button switching is retained.
- Primary shot confirmation is reliable so client rocket/load visuals
  reconcile after a volley.
- A rejected switch-race prediction receives a reliable, refund-only ammo
  correction on the player channel.
- Det weapon moves split on a fire or alt-fire release edge (`CanMergeMove`).
  Held bits are OR-merged, so a release folded into a held move would resolve
  as still held: primary->alt would fire primary on the server while the client
  predicted alt, and a bio/eightball release would land at the move's end.

## Weapon behavior

### Shared rules

- Readiness requires an active supported weapon, no switch guard, no conflicting
  client/equipped/pending weapon, no down/pickup state, and client fire enabled.
- Shock, Ripper, and Flak share the same interval cadence controller.
- Deterministic spawn functions receive shot location and rotation explicitly;
  shared legacy entry points calculate legacy aim before using the spawn cores.
- Run-dry handling preserves an existing manual weapon choice.
- Deterministic state resets on give, drop, death, and respawn.
- Primary wins simultaneous primary/alt input from idle. Active charge cycles
  retain ownership until resolved.

### Eightball

- Primary rocket count and instant/tight state are latched for a cycle.
- Grenade and rocket loads settle through switch-away by firing the committed
  count at the settlement point while the launcher is still equipped or
  holstering. Stock keeps loading and fires on release; this is the cheap
  equivalent, so a switch never eats a load silently. Drops and throws still
  cancel with the ammo spent.
- Charge rotation/load sounds are replayed by the server for non-owning clients.
- The complete volley is consumed at fire time from a frozen cycle budget.
  Mid-load ammo pickups intentionally do not extend that volley.

### Bio

- Alt charge has levels 0..9 and reaches the stock 4.1 glob at roughly 4.5
  seconds / 10 ammo.
- Switching away fires the paid charge at its current size from the outgoing
  weapon, then clears the cycle. Stock fires on release before holstering.

### Stock parity notes

- Held fire is restored when switching from a deterministic weapon to a legacy
  weapon, avoiding a false fresh edge during select.
- Resolved grenade volleys spawn before a pending switch completes.
- Shock/Flak interval constants intentionally remain as currently measured;
  change them only after an in-engine timestamp trace.

## Transport

Movement and weapons both ride the stock v3 `xxServerMove`. Deterministic
weapons run whole-move dispatch (`bDetWholeMove`): one weapon step per move,
using the move's timestamp and end-of-move view.

The sub-step slice transport (`xxServerMove_v4`, edge timelines, interpolated
slice views, Eightball shot packs) was removed — it was permanently disabled,
and enabling it re-plumbed the movement path (splitting each move into a
catch-up sim plus slice replay, and skipping jitter bounding), which broke
movement in testing. It bought sub-move aim precision and shot-pack loss
recovery: an improvement over stock, not a fix for a regression. The code is
on the `xxServerMove_v4` branch if it is ever revisited.

If it is revisited, do not name it after a protocol version.
`Level.ServerMoveVersion` cannot carry the signal — the 469 engine owns that
variable and resets script writes, so clients always saw 3 — and no
negotiation is needed anyway, since both sides always run the same package.

Client fire gates must depend on readiness, never the transport.

Before broad deployment, test all supported 469 client revisions and a
spectator. Spectators force version 0 locally and exercise engine movement
protocol negotiation differently.

## Release checklist

- Hold primary and alt through every deterministic weapon pair and through
  switches to translocator, impact hammer, and pulse.
- Fire immediately after normal and fast switch completion; verify no early or
  eaten first shot and matching client/server direction during a turn.
- Spam A-B-A switching while holding fire; verify no holstered-weapon shots.
- Load/release Eightball at every count; test tightwad, grenades, instant mode,
  switch cancel, and drop/pickup state reset.
- Repeat Eightball tests with loss and a simulated lag spike; verify
  confirmation and boundary counts.
- Release a rocket volley, immediately switch, and fire the new weapon under
  loss; verify no misrouted edge or under-fired volley.
- Charge/release Bio at every level, including full charge and out-of-ammo;
  switch away mid-charge and verify one glob of the current charge spawns and
  the switch completes.
- Load rockets, switch away while still holding fire; verify the loaded count
  fires once and the switch completes. Repeat with a throw: no volley, ammo
  spent.
- Run every weapon dry while manually selecting another weapon; verify the
  manual choice is not replaced by impact hammer.
- Double-tap faster than one net update; both shots must register.
- Exercise high-FPS/low-net-update flick shots and verify prediction matches
  the server-replayed position and view. Aim resolves at the end-of-move view,
  same as stock.
- Die holding fire, release while dead, and respawn; verify no phantom shot.
- Drop each weapon mid-cycle and let another player pick it up; verify no
  inherited charge, cooldown, or held edge.
- Disable ping compensation per weapon and globally; legacy fire must remain
  active.
- Run the 469a-e client matrix plus a spectator.

## Future automation

The deterministic state machines are suitable for replay tests. A future
`IGPlus_TestCommandlet` suite should feed recorded input timelines and assert
shot timestamps, counts, switch gates, loss recovery, and stock cadence. Until
that exists, the checklist above is the release gate.
