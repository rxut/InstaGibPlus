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
	if (ST_UT_BioGel(Proj) != None)
		return ST_UT_BioGel(Proj).IGPlus_Lift;
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
	else if (ST_UT_BioGel(Proj) != None)
		ST_UT_BioGel(Proj).IGPlus_Lift = LS;
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
	else if (ST_UT_BioGel(P) != None)
		ST_UT_BioGel(P).IGPlus_HeldVelocity = V;
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
	Fly(Delta, 0.0, true);
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

// How far ahead the real lift is of where it was LagAgoMs ago.
function vector LeadOver(float LagAgoMs) {
	if (LagAgoMs < 1.0 || MD == None)
		return vect(0,0,0);
	return Lift.Location - MD.GetHistoricalLocation(Level.TimeSeconds - LagAgoMs * 0.001 * Level.TimeDilation);
}

// Delta of flight. In the fast-forward it starts AheadMs further along than
// LagMs allows for; live (bLive) it is the tick that just passed.
// The screen's lift moves during it too: the move is tested from where that
// lift was at its start to where it is at its end, else a lift rising past
// the projectile between two moves never meets it.
function Fly(float Delta, float AheadMs, optional bool bLive) {
	local vector D0, D1, D, S, E, V, HL, HN, At;
	local float DtMs, Lag0, Frac;
	local bool bHit;

	DtMs = Delta * 1000.0 / Level.TimeDilation;
	if (bLive)
		Lag0 = LagMs + DtMs;
	else
		Lag0 = LagMs - AheadMs;
	D0 = LeadOver(Lag0);
	D1 = LeadOver(Lag0 - DtMs);
	S = P.Location;
	V = P.Velocity + P.Acceleration * Delta;
	if (P.Physics == PHYS_Falling)
		V += P.Region.Zone.ZoneGravity * Delta;
	E = S + V * Delta;
	if (D0 != vect(0,0,0) || D1 != vect(0,0,0))
		bHit = Shooter.IGPlus_TraceMover(Lift, S + D0, E + D1, HL, HN, Extent());
	Frac = 1.0;
	if (bHit)
		Frac = FClamp(VSize(HL - (S + D0)) / FMax(VSize((E + D1) - (S + D0)), 0.001), 0.0, 1.0);
	D = D0 + (D1 - D0) * Frac;
	At = S + (E - S) * Frac;

	bMoving = true;
	bLandingPassed = false;
	MoveEnd = At;
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
	if (bHit && VSize(P.Location - At) < 8.0)
		Contact(HL, HN, D);
}

// The projectile's collision size, as the engine moves it.
function vector Extent() {
	local vector E;

	E.X = P.CollisionRadius;
	E.Y = P.CollisionRadius;
	E.Z = P.CollisionHeight;
	return E;
}

// The screen's lift is hit at HL - D: the same spot of the real lift is HL.
// It hits it there as a wall (a rocket jump off it pushes as on the
// shooter's screen, a gel sticks to the lift), and flies on its own after.
// Projectiles here have no Landed of their own worth more: a wall hit is how
// they explode, bounce or stick.
function Contact(vector HL, vector HN, vector D) {
	local Mover L;

	if (Shooter.bDrawDebugData)
		Shooter.ClientDebugMessage(P.Class.Name$" (server) hit our lift where our screen has it at "
			$class'ST_ShockProj'.static.IGPlus_Vec(HL - D)$", real lift spot "$class'ST_ShockProj'.static.IGPlus_Vec(HL));
	if (ST_RocketMk2(P) != None)
		ST_RocketMk2(P).IGPlus_SpawnLoc += D; // same travel for the self-knockback timing
	P.SetLocation(HL + 2.0 * HN);
	L = Lift;
	bContact = true;
	bMoving = true;
	P.HitWall(HN, L);
	// Resting on it now: ride it, so it never runs into this.
	if (P != None && P.bDeleteMe == false && P.Physics == PHYS_None && P.Base != L)
		P.SetBase(L);
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

	if (Shooter.bDrawDebugData)
		Shooter.ClientDebugMessage(P.Class.Name$" (server) goes through the real lift at "$class'ST_ShockProj'.static.IGPlus_Vec(P.Location));
	bOldCollideWorld = P.bCollideWorld;
	foreach TraceActors(class'Actor', A, HL, HN, MoveEnd, P.Location, Extent()) {
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
