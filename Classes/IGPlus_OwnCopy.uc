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
// (IGPlus_LiftShot), else zero. Such a one came without collision.
static function bool TakeOver(Projectile Real, Projectile Fake, vector HeldVelocity) {
	local vector Loc, Vel;
	local EPhysics Phys;

	Loc = Fake.Location;
	Vel = Fake.Velocity;
	Phys = Fake.Physics;
	Fake.Destroy();
	Real.SetLocation(Loc);
	if (Phys == PHYS_None)
		return false;
	Real.Velocity = Vel;
	if (Real.Physics != Phys)
		Real.SetPhysics(Phys);
	if (HeldVelocity != vect(0,0,0) && Real.bCollideActors == false)
		Real.SetCollision(Real.default.bCollideActors, Real.default.bBlockActors, Real.default.bBlockPlayers);
	return true;
}

defaultproperties {
	bHidden=True
	DrawType=DT_None
	RemoteRole=ROLE_None
}
