# ServerMove v4/v5 deterministic weapons

This document describes the current system. Development chronology belongs in
Git history; the production contract, known policy choices, and release checks
live here.

## Architecture

Supported ST_ weapons use one deterministic model on client and server:

1. The client records physical fire/alt edges for each input slice.
2. `xxServerMove_v4` carries the edge timeline, bound weapon, view data,
   charge data, and optional Eightball shot pack.
3. The client predicts each slice before movement and move merging.
4. The server resolves the bound weapon and replays the same input slices.
5. Fresh fire starts only on a client-predicted step. Non-hinted steps may
   advance or settle an already committed cycle, but cannot start one.

The whole-move path remains the fallback for v3 transport. Ping compensation
off uses legacy weapon fire. NewNet client-authoritative weapons are a separate
system.

Supported weapons are:

- `ST_ShockRifle`
- `ST_ripper`
- `ST_UT_FlakCannon`
- `ST_ut_biorifle`
- `ST_UT_Eightball`

## Trust boundaries

### Binding and activation

`IGPlus_V4ResolveBoundWeapon` requires a supported, active ST_ weapon. In
server context, `IGPlus_V4ServerBindingValid` further restricts it to:

- the equipped weapon;
- the incoming `PendingWeapon`; or
- the weapon just switched away from, during its timestamped grace window.

The readiness bit is a prediction hint, not authority. A pending weapon cannot
be client-vouched before `ChangedWeapon` equips it.

### Fire windows

`IGPlus_V4FireWindowOpen` decides when a valid binding may step:

- bring-up is gated for 0.12 seconds with fast switch and 0.25 seconds
  otherwise;
- starting a switch closes the equipped weapon after the in-flight allowance;
- previous-weapon grace accepts only pre-switch timestamped steps; and
- canceling a pending switch re-arms the equipped weapon's gate.

Closed windows do not synthesize edges. Charge weapons receive only the
no-input settlement step required to release or cancel committed state.

### Charge validation

- Eightball release/cancel count is capped by server-observed load time. The
  client report may only lower it. Boundary slack is the larger of 60 ms and
  the current input-slice delta.
- Bio charge is derived from server-observed hold time at stock 0.5-second
  cadence. Client charge data may only lower it.

## Recovery behavior

- Edge state self-heals a lost release on the next move.
- Fire-bearing v4 moves resend one complete packed timeline before the next
  move, preserving the original binding, edges, aim, charge data, and shot pack.
- After a movement gap, missing movement is advanced first and the received
  move's input slices replay only across that move's packed duration.
- Eightball shot packs carry sequence, charge, shot kind, and tight-spread state in `V4AuxData`
  without replacing the carrying move's weapon/readiness data.
- A pack on a move bound to another weapon runs deduplicated Eightball recovery
  only inside the normal current/previous-weapon firing window.
- Shot-producing Eightball edges flush immediately, and packs cannot attach to
  a movement sample older than the predicted shot. The newest eligible marker
  takes the shot-producing carrier; older unacknowledged markers retry later.
- Rejected movement and rejected recovery do not mutate or acknowledge the
  shot sequence; acknowledgement follows an authoritative shot only.
- Old-move replay remains enabled on shot-pack moves.
- Primary shot confirmation is reliable so client rocket/load visuals
  reconcile after a volley.
- A rejected switch-race prediction receives a reliable, refund-only ammo
  correction on the player channel; settlement also retires pre-switch markers.
- A merged move contains at most one press and one release of each fire type;
  another edge forces a packet split.
- Input-slice timestamps end at the move timestamp, view interpolation reaches
  both packed endpoints, and paired edges are not collapsed by legacy resampling.

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
- Grenade and rocket loads settle through switch-away and keep committed ammo
  spent.
- Charge rotation/load sounds are replayed by the server for non-owning clients.
- The complete volley is consumed at fire time from a frozen cycle budget.
  Mid-load ammo pickups intentionally do not extend that volley.

### Bio

- Alt charge has levels 0..9 and reaches the stock 4.1 glob at roughly 4.5
  seconds / 10 ammo.
- Switching away cancels the paid charge, keeps committed ammo spent, and
  clears the cycle without spawning a glob from the outgoing weapon.

### Stock parity notes

- Held fire is restored when switching from a deterministic weapon to a legacy
  weapon, avoiding a false fresh edge during select.
- Resolved grenade volleys spawn before a pending switch completes.
- Shock/Flak interval constants intentionally remain as currently measured;
  change them only after an in-engine timestamp trace.

## Transport deployment

Movement rides the stock v3 `xxServerMove`; deterministic weapons run
whole-move dispatch (`bDetWholeMove`). The v4 slice transport (edge
timelines, interpolated slice views, shot packs) is dormant behind
`UsesServerMoveV4()` returning false — re-enable it there plus the two
`bUseServerMoveV4` assignment sites in bbPlayer, after the slice-replay
movement glitches get their own investigation. `Level.ServerMoveVersion`
cannot carry the signal: the 469 engine owns that variable and resets
script writes (clients always saw 3). No negotiation is needed anyway —
both sides always run the same package. Client fire gates must depend on
readiness, never the transport.

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
- Repeat Eightball tests with loss and a simulated lag spike; verify shot-pack
  recovery, confirmation, and boundary counts.
- Release a rocket volley, immediately switch, and fire the new weapon under
  loss; verify no misrouted edge or under-fired volley.
- Charge/release Bio at every level, including full charge and out-of-ammo;
  switch away mid-charge and verify the paid glob resolves once.
- Run every weapon dry while manually selecting another weapon; verify the
  manual choice is not replaced by impact hammer.
- Double-tap faster than one net update; both shots must register.
- Exercise high-FPS/low-net-update flick shots and verify prediction matches
  the server-replayed input-slice position and view.
- Die holding fire, release while dead, and respawn; verify no phantom shot.
- Drop each weapon mid-cycle and let another player pick it up; verify no
  inherited charge, cooldown, or held edge.
- Disable ping compensation per weapon and globally; legacy fire must remain
  active.
- Run the 469a-e client matrix plus a spectator on a version-4 server.

## Future automation

The deterministic state machines are suitable for replay tests. A future
`IGPlus_TestCommandlet` suite should feed recorded input timelines and assert
shot timestamps, counts, switch gates, loss recovery, and stock cadence. Until
that exists, the checklist above is the release gate.
