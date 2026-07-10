# Deterministic weapon netcode

InstaGibPlus adds a new weapon networking system called **deterministic weapon
netcode**. It uses **ServerMove v4** to keep the client and server on the same
weapon timeline while preserving the fast feel of local prediction.

## Why it is needed

Unreal Tournament was built for the hardware and internet connections of the
late 1990s. To save bandwidth, it can combine several rendered frames into one
movement update before sending it to the server.

That works well for movement, but weapon input is more sensitive to timing. A
player can press fire, turn, release fire, or switch weapons during those
combined frames. The original update does not contain the complete timeline
needed to reproduce every one of those actions at its exact moment.

This can leave the client and server slightly out of step:

- the client displays a shot that the server does not fire;
- the server fires using a later position or view angle;
- a quick tap is missed or delayed;
- a release reaches the wrong part of a charged shot;
- or an old input is applied after a weapon switch.

Higher frame rates make this easier to notice because more local frames may
happen between network updates.

## The goal

The client should react immediately when the player fires, but the server must
remain in control of ammo, projectiles, hits, and damage.

To achieve both, the client and server run the same weapon rules from the same
timed input. The client predicts the result for responsiveness. The server
repeats it authoritatively when the movement update arrives.

If both sides begin with the same weapon state and receive the same input at
the same point in time, they make the same decision: fire, keep charging,
release, wait for cooldown, or do nothing. That is what “deterministic” means
in this system.

## How it works

The client records weapon input in small slices alongside movement. It keeps
not only whether fire is held at the end of an update, but also when primary or
alt fire was pressed and released inside it.

The client still combines movement slices to avoid sending a packet every
frame. ServerMove v4 adds enough information to preserve the important weapon
timeline:

- the weapon that owned the input;
- fire and alt-fire edges;
- the start and end view;
- whether the weapon appeared ready;
- and limited charge or recovery data when needed.

The client predicts the weapon step immediately, so firing and animations do
not wait for a network round trip.

When the update reaches the server, the server divides the combined movement
back into the same smaller steps. It reconstructs the time and aim for each
step, advances movement in the same order, and runs the same weapon state
machine.

The server then performs the real shot. It spends authoritative ammo, creates
gameplay projectiles, traces hits, and awards damage. Client-side projectiles
or effects are visual predictions only.

## Keeping client and server in sync

The important improvement is not simply sending more fire commands. It is
giving both sides a shared timeline.

UT does not use a modern fixed weapon tick in the same way as Source. Here,
being “in sync” means that the client and server advance weapon state at the
same reconstructed movement sub-step, with the same held input, aim, weapon,
charge, and cooldown state.

For example, imagine a player presses and releases Shock primary while turning
during one combined movement update.

In the base-style path, the server has less information about where those
actions belonged inside the update. The shot may be evaluated from the end of
the move, after the player has already turned.

With ServerMove v4, the server knows where the press and release occurred. It
reconstructs the matching sub-step and interpolates the player's aim between
the start and end of the move. The predicted client beam and authoritative
server beam are therefore based on the same moment.

This same ordering also matters for weapon switches. Input is tied to the
weapon that produced it. A late packet cannot freely turn an old press into a
shot from the newly selected weapon. Short switch windows allow valid
in-flight input while rejecting impossible early or holstered-weapon shots.

Charged weapons use the same principle. The client can report its predicted
charge, but the server limits the result using time and ammo it observed
itself. The client may reduce a charge prediction, but cannot create extra
rockets or Bio charge.

## Prediction without giving up authority

The system is designed to feel responsive without trusting the client with
gameplay results.

The client is allowed to predict:

- weapon timing and animations;
- local muzzle flashes, beams, and visual projectiles;
- and expected ammo presentation.

The server controls:

- whether the weapon was owned, equipped, and ready;
- whether switch timing was valid;
- authoritative ammo and charge;
- gameplay projectiles and traces;
- and all hits and damage.

If prediction disagrees with the server, the server wins and replicated state
corrects the client. Eightball also carries small recovery and confirmation
data so a lost packet does not permanently desynchronize a resolved volley.

## Benefits over the base game

- **More immediate firing:** local prediction does not wait for ping.
- **More consistent aim:** shots use the reconstructed view and position from
  the relevant movement step.
- **Reliable quick input:** short presses and releases survive move merging.
- **Safer switching:** input stays associated with the correct weapon.
- **Consistent charging:** client visuals and server charge follow the same
  timed cycle.
- **Better loss recovery:** important Eightball shot state can be confirmed and
  resent.
- **Server authority:** clients never decide hits, damage, or authoritative
  projectile state.
- **Compatibility:** unsupported weapons or disabled ping compensation can
  continue through the legacy path.

The result is not zero latency. It is a more consistent interpretation of the
same player input on both machines.

## Other games

Quake III and Source use the same broad philosophy: predict the local player's
actions for responsiveness while an authoritative server decides the real game
state.

Quake III was designed around client prediction and server snapshots at engine
level. Source sends timed user commands, predicts shared gameplay code, and can
rewind other players for server-side lag compensation.

InstaGibPlus is a smaller retrofit inside Unreal Tournament. It does not
replace the engine with a new snapshot or rollback system. It adds the timing,
weapon binding, validation, and shared weapon simulation needed to make UT's
existing ServerMove design behave more like a modern predicted,
server-authoritative shooter.

## Scope and fallback

The deterministic model currently covers:

- Shock Rifle;
- Ripper;
- Flak Cannon;
- Bio Rifle; and
- Eightball.

It operates through ServerMove v4 or the input-replication path. When the
required transport is unavailable, a reduced whole-move fallback can be used.
When ping compensation is disabled, or a weapon is unsupported, legacy weapon
handling remains available.

The system is intentionally focused. It improves weapon input, timing, and
authoritative shot creation without attempting to replace every part of
Unreal Tournament's networking.
