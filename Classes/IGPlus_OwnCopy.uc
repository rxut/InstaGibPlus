// Client only. With client-side animations the shooter's weapon spawns a
// local copy of its projectile at once. The server's projectile arrives a
// ping later and takes over from that copy (PostNetBeginPlay of the flak
// slug, the flak chunks, the bio gel and the charged glob).
class IGPlus_OwnCopy extends Actor abstract;

// Real (the server's) takes over from Fake (our copy): it goes on Fake's
// spot and Fake is gone. True if Fake was still in flight. Real then flies
// on as Fake did, with Fake's speed and physics: the speed Real came with is
// from another point of the arc. The caller gives it no lead move on top,
// Fake's spot is already ahead by the ping (on a falling projectile the lead
// move sinks it by gravity x lead).
// HeldVelocity: Real's launch speed if it came held still from a moving lift
// (IGPlus_LiftShot), else zero. Such a one came without collision. The
// server started it where it worked out our screen had the gun, a few units
// above or below where our copy started (no steady bias; the size fits the
// lift's travel in part of a server tick). Real is put on the server's path,
// that step to the side of Fake's spot, and drawn over to there (IGPlus_Glide).
static function bool TakeOver(Projectile Real, Projectile Fake, vector HeldVelocity) {
	local vector Loc, Vel, Sent, Gravity, Step;
	local EPhysics Phys;
	local bool bSamePath;

	Loc = Fake.Location;
	Vel = Fake.Velocity;
	Phys = Fake.Physics;
	Fake.Destroy();
	Sent = Real.Location;
	// A chunk copy that already bounced is on another path than the spot
	// the server sent.
	bSamePath = Phys == Real.Physics;
	Real.SetLocation(Loc);
	if (Phys == PHYS_None)
		return false;
	Real.Velocity = Vel;
	if (Real.Physics != Phys)
		Real.SetPhysics(Phys);
	if (HeldVelocity == vect(0,0,0))
		return true;
	if (Real.bCollideActors == false)
		Real.SetCollision(Real.default.bCollideActors, Real.default.bBlockActors, Real.default.bBlockPlayers);
	if (bSamePath) {
		if (Phys == PHYS_Falling && Real.Region.Zone != None)
			Gravity = Real.Region.Zone.ZoneGravity;
		Step = PathStep(Loc, Vel, Sent, HeldVelocity, Gravity);
		// Not under a unit: one already on the path stays where it is.
		if (VSize(Step) >= 1.0 && Real.SetLocation(Loc + Step)) {
			class'IGPlus_Glide'.static.BeginFrom(Real, Loc);
			if (bbPlayer(Real.Instigator) != None && bbPlayer(Real.Instigator).bDrawDebugData)
				bbPlayer(Real.Instigator).ClientDebugMessage(Real.Class.Name$" (client) moved "
					$class'ST_ShockProj'.static.IGPlus_Vec(Step)$" onto the server's path");
		}
	}
	return true;
}

// How far the server's path lies to the side of our copy's. C, V: our copy's
// spot and speed now. S, SV: a spot on the server's path and its speed there.
// Both left the gun at the same speed, so the two paths have the same shape
// and lie a fixed step apart. Gravity: zero for one that flies straight.
// How far along its path our copy is stays as it is.
static function vector PathStep(vector C, vector V, vector S, vector SV, vector Gravity) {
	local float Dt;
	local vector D, Dir;

	if (V dot V < 1.0)
		return vect(0,0,0);
	// The server's spot is Dt seconds further along the path than our copy:
	// a falling one's speed tells (it changes by gravity alone), a straight
	// one's spot.
	if (Gravity.Z != 0.0)
		Dt = (SV.Z - V.Z) / Gravity.Z;
	else
		Dt = ((S - C) dot V) / (V dot V);
	D = S - (C + V * Dt + 0.5 * Gravity * Dt * Dt);
	Dir = Normal(V);
	return D - Dir * (D dot Dir);
}

defaultproperties {
	bHidden=True
	DrawType=DT_None
	RemoteRole=ROLE_None
}
