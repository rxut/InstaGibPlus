// Server: a projectile fired with Push-Safe Aim from a moving lift. It left
// from where the shooter's screen had them, a round trip of lift travel
// behind the server. For half a second this flies it against the shooter's
// lift where that screen has it: the real lift (ahead by D) is gone through,
// and each move shifted by D is tested against the real lift instead
// (bbPlayer.IGPlus_TraceMover). The real lift is never moved: a rider set
// down on it again restarts a waiting lift.
// Between moves the projectile holds still for the engine: no speed (a
// PHYS_None would wipe it) and no collision (a lift that runs into it
// returns). Clients get the speed with the projectile (IGPlus_HeldVelocity).
class IGPlus_LiftShot extends Info;

var Projectile P;
var bbPlayer Shooter;
var Mover Lift;
var ST_MoverDummy MD;
var float LagMs;            // how far behind the shooter's screen has the lift
var float Until;
var bool bHeld;
var vector HeldVelocity, HeldAcceleration, HeldLocation;
var bool bMoving;           // inside Fly: contacts with the real lift go through it
var bool bContact;          // delivering the contact with the screen's lift
var vector MoveEnd;
var bool bLandingPassed;    // went through the real lift on landing
var vector PassVelocity;

// P (the shooter) fired Proj from a moving lift. The caller holds it after
// its fast-forward (Hold).
static function IGPlus_LiftShot Begin(Projectile Proj, bbPlayer Shooter) {
	local IGPlus_LiftShot LS;

	if (Proj == None || Mover(Shooter.Base) == None || Shooter.zzUTPure == None)
		return None;
	LS = Shooter.Spawn(class'IGPlus_LiftShot', Shooter);
	if (LS == None)
		return None;
	LS.P = Proj;
	LS.Shooter = Shooter;
	LS.Lift = Mover(Shooter.Base);
	LS.MD = Shooter.zzUTPure.FindMoverDummy(LS.Lift);
	LS.LagMs = Shooter.IGPlus_OwnLiftLagMs();
	// ponytail: 0.5s covers clearing the lift; past that the real lift counts
	LS.Until = Shooter.Level.TimeSeconds + 0.5;
	SetFor(Proj, LS);
	return LS;
}

static function IGPlus_LiftShot Of(Projectile Proj) {
	if (ST_RocketMk2(Proj) != None)
		return ST_RocketMk2(Proj).IGPlus_Lift;
	if (ST_Razor2(Proj) != None)
		return ST_Razor2(Proj).IGPlus_Lift;
	if (ST_Razor2Alt(Proj) != None)
		return ST_Razor2Alt(Proj).IGPlus_Lift;
	if (ST_FlakSlug(Proj) != None)
		return ST_FlakSlug(Proj).IGPlus_Lift;
	if (ST_UTChunk(Proj) != None)
		return ST_UTChunk(Proj).IGPlus_Lift;
	return None;
}

static function SetFor(Projectile Proj, IGPlus_LiftShot LS) {
	if (ST_RocketMk2(Proj) != None)
		ST_RocketMk2(Proj).IGPlus_Lift = LS;
	else if (ST_Razor2(Proj) != None)
		ST_Razor2(Proj).IGPlus_Lift = LS;
	else if (ST_Razor2Alt(Proj) != None)
		ST_Razor2Alt(Proj).IGPlus_Lift = LS;
	else if (ST_FlakSlug(Proj) != None)
		ST_FlakSlug(Proj).IGPlus_Lift = LS;
	else if (ST_UTChunk(Proj) != None)
		ST_UTChunk(Proj).IGPlus_Lift = LS;
}

function SetHeldVelocity(vector V) {
	if (ST_RocketMk2(P) != None)
		ST_RocketMk2(P).IGPlus_HeldVelocity = V;
	else if (ST_Razor2(P) != None)
		ST_Razor2(P).IGPlus_HeldVelocity = V;
	else if (ST_Razor2Alt(P) != None)
		ST_Razor2Alt(P).IGPlus_HeldVelocity = V;
	else if (ST_FlakSlug(P) != None)
		ST_FlakSlug(P).IGPlus_HeldVelocity = V;
	else if (ST_UTChunk(P) != None)
		ST_UTChunk(P).IGPlus_HeldVelocity = V;
}

function FastForwarded(float Ms) {
	LagMs -= Ms;
}

function Hold() {
	if (bHeld || P == None || P.bDeleteMe)
		return;
	HeldVelocity = P.Velocity;
	HeldAcceleration = P.Acceleration;
	HeldLocation = P.Location;
	SetHeldVelocity(HeldVelocity);
	P.Velocity = vect(0,0,0);
	P.Acceleration = vect(0,0,0);
	P.SetCollision(false, false, false);
	bHeld = true;
}

function Unhold() {
	local bool bOldCollideWorld;

	if (bHeld == false || P == None || P.bDeleteMe)
		return;
	// Gravity still nudges a falling one while held.
	if (P.Location != HeldLocation) {
		bOldCollideWorld = P.bCollideWorld;
		P.bCollideWorld = false;
		P.SetLocation(HeldLocation);
		P.bCollideWorld = bOldCollideWorld;
	}
	P.Velocity = HeldVelocity;
	P.Acceleration = HeldAcceleration;
	P.SetCollision(P.default.bCollideActors, P.default.bBlockActors, P.default.bBlockPlayers);
	bHeld = false;
}

event Tick(float Delta) {
	if (P == None || P.bDeleteMe) {
		Destroy();
		return;
	}
	Unhold();
	if (Level.TimeSeconds > Until || LagMs < 1.0 || MD == None || P.Physics == PHYS_None) {
		Finish();
		return;
	}
	Fly(Delta, 0.0);
	if (P != None && P.bDeleteMe == false && Of(P) == self)
		Hold();
}

// Flies on its own from here, against the real lift.
function Finish() {
	if (P != None && P.bDeleteMe == false) {
		Unhold();
		SetFor(P, None);
		if (Shooter != None && Shooter.bDrawDebugData)
			Shooter.ClientDebugMessage(P.Class.Name$" (server) flies on its own at "$class'ST_ShockProj'.static.IGPlus_Vec(P.Location));
	}
	P = None;
	Destroy();
}

// Delta of flight, AheadMs further along than LagMs allows for (in the
// fast-forward).
function Fly(float Delta, float AheadMs) {
	local vector D, S, E, V, HL, HN;
	local float Lag, Frac;
	local bool bHit;

	Lag = LagMs - AheadMs;
	if (Lag >= 1.0 && MD != None)
		D = Lift.Location - MD.GetHistoricalLocation(Level.TimeSeconds - Lag * 0.001 * Level.TimeDilation);
	S = P.Location;
	V = P.Velocity + P.Acceleration * Delta;
	if (P.Physics == PHYS_Falling)
		V += P.Region.Zone.ZoneGravity * Delta;
	E = S + V * Delta;
	if (D != vect(0,0,0))
		bHit = Shooter.IGPlus_TraceMover(Lift, S + D, E + D, HL, HN);
	Frac = 1.0;
	if (bHit)
		Frac = FClamp(VSize(HL - D - S) / FMax(VSize(E - S), 0.001), 0.0, 1.0);

	bMoving = true;
	bLandingPassed = false;
	MoveEnd = S + (E - S) * Frac;
	if (Frac > 0.0)
		P.AutonomousPhysics(Delta * Frac);
	bMoving = false;
	if (P == None || P.bDeleteMe)
		return;
	if (bLandingPassed) {
		P.SetPhysics(PHYS_Falling);
		P.Velocity = PassVelocity;
	}
	// Reached it, unless something else turned it first.
	if (bHit && VSize(P.Location - (HL - D)) < 8.0)
		Contact(HL, HN, D);
}

// The screen's lift is hit at HL - D: the same spot of the real lift is HL.
// It lands there (a rocket jump off it pushes as on the shooter's screen, a
// chunk rests on the lift), and flies on its own after that.
function Contact(vector HL, vector HN, vector D) {
	local Mover L;

	if (ST_RocketMk2(P) != None)
		ST_RocketMk2(P).IGPlus_SpawnLoc += D; // same travel for the self-knockback timing
	P.SetLocation(HL + 2.0 * HN);
	L = Lift;
	bContact = true;
	bMoving = true;
	if (P.Physics == PHYS_Falling && HN.Z > 0.7) {
		P.Landed(HN);
		if (P != None && P.bDeleteMe == false && P.Physics == PHYS_None)
			P.SetBase(L);
	} else {
		P.HitWall(HN, L);
	}
	bMoving = false;
	bContact = false;
	if (P != None && P.bDeleteMe == false)
		Finish();
}

// Projectile hooks: the real lift is ahead of the one the shooter's screen
// has. True: handled, the projectile carries on.
function bool PassHitWall(Actor Wall) {
	if (Wall == None || Wall != Lift || bMoving == false || bContact)
		return false;
	GoThrough();
	return true;
}

function bool PassLanded(vector HitNormal) {
	local vector HL, HN;

	if (bMoving == false || bContact)
		return false;
	if (P.Trace(HL, HN, P.Location - 16.0 * HitNormal, P.Location, false) != Lift)
		return false;
	// Not falling any more, so the engine does not stop it (Fly puts it back).
	PassVelocity = P.Velocity;
	bLandingPassed = true;
	P.SetPhysics(PHYS_Projectile);
	GoThrough();
	return true;
}

// Through the real lift, on to where this move ends; anything else in the way
// is hit.
function GoThrough() {
	local Actor A;
	local vector HL, HN;
	local bool bOldCollideWorld;

	bOldCollideWorld = P.bCollideWorld;
	foreach TraceActors(class'Actor', A, HL, HN, MoveEnd, P.Location) {
		if (A == Lift || A == P || A == P.Instigator || A == self)
			continue;
		if (A == Level || Mover(A) != None) {
			P.bCollideWorld = false;
			P.SetLocation(HL + 2.0 * HN);
			P.bCollideWorld = bOldCollideWorld;
			bMoving = false;
			if (bLandingPassed) {
				bLandingPassed = false;
				P.SetPhysics(PHYS_Falling);
				P.Velocity = PassVelocity;
			}
			if (P.Physics == PHYS_Falling && HN.Z > 0.7)
				P.Landed(HN);
			else
				P.HitWall(HN, A);
			return;
		}
	}
	P.bCollideWorld = false;
	P.SetLocation(MoveEnd);
	P.bCollideWorld = bOldCollideWorld;
}

defaultproperties {
	RemoteRole=ROLE_None
	bHidden=True
}
