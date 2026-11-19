// A flak chunk that hit something during the server's ping catch-up
// (IGPlus_WeaponImplementationBase.SimulateProjectile) is never sent to
// anyone but the shooter, and one that hit a player while the rest of the
// volley is still drawn behind (IGPlus_Glide) must not be hidden before its
// drawn copy gets there. This actor sits at the hit spot. Other players then
// draw that chunk on to there: the glide they already have gets the spot as its
// end, or a client-only chunk leaves the gun on the same curve as the rest of
// the volley. Not drawn for the shooter, who has his own copy.
class IGPlus_SkippedPath extends Actor;

var vector PathStart;
var float PathSpeed;
var class<Projectile> PathClass;
// The catch-up's length in seconds: how far ahead the rest of the volley was
// sent (PathSpeed * PathCatchUp).
var float PathCatchUp;
// The chunk itself, if it was sent before it hit.
var Projectile PathActor;

replication {
	reliable if (Role == ROLE_Authority && bNetInitial)
		PathStart, PathSpeed, PathClass, PathCatchUp, PathActor;
}

simulated function PostNetBeginPlay() {
	super.PostNetBeginPlay();
	if (Role < ROLE_Authority)
		IGPlus_Show();
	Destroy();
}

simulated function IGPlus_Show() {
	local IGPlus_Glide G;
	local vector Dir, Sent;
	local ST_UTChunk C;

	if (PathClass == None || ClassIsChildOf(PathClass, class'ST_UTChunk') == false)
		return;
	if (class'IGPlus_Glide'.static.IsOwnCopy(self, Pawn(Owner),
		bbPlayer(Owner) != None && bbPlayer(Owner).ClientWeaponSettingsData.bFlakUseClientSideAnimations))
		return;

	if (PathActor != None) {
		// Sent before it hit: if it is still drawn behind, on to the hit
		// spot. If not, it is at its real spot and the server's hide is right.
		G = class'IGPlus_Glide'.static.Of(PathActor);
		if (G != None)
			G.EndAt(Location);
		return;
	}

	Dir = Normal(Location - PathStart);
	if (VSize(Location - PathStart) < 8.0)
		return;
	// Where it would have been sent, with the rest of the volley: the same
	// glide draws it back at the gun and on to the hit spot. The chunk itself
	// stays at the gun (that spot is open), only its drawing flies.
	Sent = PathStart + Dir * FMax(PathSpeed * PathCatchUp, 16.0);
	C = ST_UTChunk(Spawn(PathClass, None, '', PathStart, rotator(Dir)));
	if (C == None)
		return;
	C.RemoteRole = ROLE_None;
	C.bClientVisualOnly = true;
	C.SetCollision(false, false, false);
	C.bCollideWorld = false;
	C.SetPhysics(PHYS_None);
	C.Velocity = vect(0,0,0);
	C.LifeSpan = 1.0;
	G = class'IGPlus_Glide'.static.BeginReplay(C, PathStart, Sent, Dir * FMax(PathSpeed, 100.0), PathCatchUp);
	if (G == None) {
		if (C.Trail != None)
			C.Trail.Destroy();
		C.Destroy();
		return;
	}
	G.EndAt(Location);
	class'IGPlus_Glide'.static.CountGlide(self, 0, 1);
}

defaultproperties {
	bNetTemporary=True
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_None
	bHidden=False
	NetPriority=3.0
	LifeSpan=0.5
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
}
