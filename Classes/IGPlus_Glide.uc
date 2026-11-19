// Client only. The server flies a projectile ahead by the shooter's latency
// before it sends it (IGPlus_WeaponImplementationBase.SimulateProjectile),
// so other players get it that far out of the gun. This draws it (PrePivot,
// its trail sprites by SetLocation) back at the spot the server spawned it and
// closes the gap over GlideTimeFor(): it leaves the gun, goes a little faster
// than it flies and is on its real spot after that. Collision and hits stay
// where the server has them.
// A chunk that hit something while it was drawn behind gets an end spot
// (IGPlus_SkippedPath): it is drawn on to there and hidden then, so it
// neither stops short of the player it hit nor shows past him.
class IGPlus_Glide extends Actor;

var Projectile P;
var vector Off;
var float T0;
var float Dur;            // seconds to close the gap (GlideTimeFor)
// End spot, along the projectile's path from PathStart.
var bool bEnd;
var bool bDestroyAtEnd;     // a client-only replay, gone at its end
var vector PathStart, PathDir;
var float EndDist;
// A replay (IGPlus_SkippedPath): the chunk itself stays at the gun, where it
// can't end up inside a wall, and only its drawing flies, from a spot that
// moves as the real chunk would have (VirtLoc at T0, VirtVel).
var bool bVirtual;
var vector VirtLoc, VirtVel;

// 1: the gap closes along a smooth curve (no jump in speed at the gun or
// when it is closed). 0: at an even pace.
const IGPLUS_GLIDE_SMOOTH = 1;
const IGPLUS_GLIDE_TIME_SMOOTH = 0.12;
const IGPLUS_GLIDE_TIME_EVEN = 0.1;
// Longest a glide with an end spot waits for it.
const IGPLUS_GLIDE_END_MAX = 0.5;

static function float GlideTime() {
	if (IGPLUS_GLIDE_SMOOTH == 1)
		return IGPLUS_GLIDE_TIME_SMOOTH;
	return IGPLUS_GLIDE_TIME_EVEN;
}

// Seconds to close the gap of a projectile sent CatchUp seconds ahead: at
// least GlideTime(), and no shorter than the catch-up, so it never goes more
// than 2.5 times its speed (a long catch-up: high ping, Adaptive Buffering,
// Tick Interpolation).
static function float GlideTimeFor(float CatchUp) {
	return FMax(GlideTime(), CatchUp);
}

// The part of the gap still open, A from 0 (at the gun) to 1 (closed).
static function float GapLeft(float A) {
	if (A <= 0.0)
		return 1.0;
	if (A >= 1.0)
		return 0.0;
	if (IGPLUS_GLIDE_SMOOTH == 1)
		return 1.0 - A * A * (3.0 - 2.0 * A);
	return 1.0 - A;
}

// The shooter's client draws its own copy from the gun (client-side
// animations), so its own projectiles are left alone. The same in a client
// demo of the shooter, which has those copies recorded.
static function bool IsOwnCopy(Actor Ctx, Pawn Shooter, bool bShooterHasCopy) {
	local PlayerPawn Me;

	if (bShooterHasCopy == false || Shooter == None)
		return false;
	foreach Ctx.AllActors(class'PlayerPawn', Me)
		if (Viewport(Me.Player) != None)
			break;
	return Me != None && Me == Shooter;
}

static function IGPlus_Glide Begin(Projectile Proj, vector SkipStart, bool bShooterHasCopy) {
	local IGPlus_Glide G;

	if (Proj == None || Proj.Level.NetMode != NM_Client || SkipStart == vect(0,0,0))
		return None;
	if (VSize(SkipStart - Proj.Location) < 8.0)
		return None;
	if (IsOwnCopy(Proj, Proj.Instigator, bShooterHasCopy))
		return None;
	G = Proj.Spawn(class'IGPlus_Glide', Proj,, Proj.Location);
	if (G == None)
		return None;
	G.P = Proj;
	G.Off = SkipStart - Proj.Location;
	G.T0 = Proj.Level.TimeSeconds;
	G.Dur = GlideTimeFor(VSize(G.Off) / FMax(VSize(Proj.Velocity), 1.0) / Proj.Level.TimeDilation);
	G.PathStart = SkipStart;
	G.PathDir = Normal(-G.Off);
	G.Apply(G.Off);
	CountGlide(Proj, 1, 0);
	return G;
}

// A client-only replay chunk Proj (at the gun, held still): drawn as if it
// had been sent at Sent with velocity Vel, back at Start and on from there.
static function IGPlus_Glide BeginReplay(Projectile Proj, vector Start, vector Sent, vector Vel, float CatchUp) {
	local IGPlus_Glide G;

	G = Proj.Spawn(class'IGPlus_Glide', Proj,, Proj.Location);
	if (G == None)
		return None;
	G.P = Proj;
	G.bVirtual = true;
	G.VirtLoc = Sent;
	G.VirtVel = Vel;
	G.Off = Start - Sent;
	G.T0 = Proj.Level.TimeSeconds;
	G.Dur = GlideTimeFor(CatchUp / Proj.Level.TimeDilation);
	G.PathStart = Start;
	G.PathDir = Normal(Sent - Start);
	G.bDestroyAtEnd = true;
	G.Apply(G.Off);
	return G;
}

// The glide drawing this projectile, if any.
static function IGPlus_Glide Of(Projectile Proj) {
	local IGPlus_Glide G;

	if (Proj == None)
		return None;
	foreach Proj.ChildActors(class'IGPlus_Glide', G)
		if (G.P == Proj)
			return G;
	return None;
}

// Debug data counts on the local player (bbPlayer.IGPlus_SkipLogStats).
static function CountGlide(Actor Ctx, int Glides, int Replays) {
	local PlayerPawn Me;

	foreach Ctx.AllActors(class'PlayerPawn', Me)
		if (Viewport(Me.Player) != None)
			break;
	if (bbPlayer(Me) != None) {
		bbPlayer(Me).IGPlus_SkipGlides += Glides;
		bbPlayer(Me).IGPlus_SkipReplays += Replays;
	}
}

// Where the projectile is drawn now.
static function vector DrawnSpot(Projectile Proj) {
	return Proj.Location + Proj.PrePivot - Proj.default.PrePivot;
}

// Drawn on to Spot (along its path), hidden there.
simulated function EndAt(vector Spot) {
	bEnd = true;
	EndDist = (Spot - PathStart) dot PathDir;
}

// Where the projectile really is (or, for a replay, would be).
simulated function vector RealSpot() {
	if (bVirtual)
		return VirtLoc + VirtVel * (Level.TimeSeconds - T0);
	return P.Location;
}

simulated function Apply(vector O) {
	local Actor A;
	local vector Drawn;

	Drawn = RealSpot() + O;
	P.PrePivot = P.default.PrePivot + Drawn - P.Location;
	// Its trails (rocket flare, flak glow) are sprites, which are drawn
	// without PrePivot: put them on the drawn spot. Their physics put them on
	// the real one each tick before ours (they were spawned before us).
	foreach P.ChildActors(class'Actor', A) {
		if (A == self || A == P || A.Physics != PHYS_Trailer)
			continue;
		if (A.DrawType == DT_Sprite && A.bTrailerSameRotation)
			A.SetLocation(Drawn - A.Mass * vector(P.Rotation));
		else
			A.SetLocation(Drawn);
	}
}

simulated function Finish(bool bHide) {
	local Actor A;

	if (P != None && P.bDeleteMe == false) {
		if (bHide == false)
			Apply(vect(0,0,0));
		else {
			P.bHidden = true;
			foreach P.ChildActors(class'Actor', A)
				if (A != self && A != P && A.Physics == PHYS_Trailer)
					A.Destroy();
			if (ST_UTChunk(P) != None)
				ST_UTChunk(P).Trail = None;
			if (bDestroyAtEnd)
				P.Destroy();
		}
	}
	Destroy();
}

simulated function Tick(float DeltaTime) {
	local float A;
	local vector O;

	if (P == None || P.bDeleteMe) {
		Destroy();
		return;
	}
	A = (Level.TimeSeconds - T0) / (Dur * Level.TimeDilation);
	O = Off * GapLeft(A);
	if (bEnd) {
		if (Level.TimeSeconds - T0 > IGPLUS_GLIDE_END_MAX * Level.TimeDilation)
		if (((RealSpot() + O - PathStart) dot PathDir) >= EndDist
			|| Level.TimeSeconds - T0 > IGPLUS_GLIDE_END_MAX * Level.TimeDilation) {
			Finish(true);
			return;
		}
		// The server hid it when it hit: drawn on until it gets there.
		P.bHidden = false;
	} else if (A >= 1.0) {
		Finish(false);
		return;
	}
	Apply(O);
}

defaultproperties {
	bHidden=True
	DrawType=DT_None
	RemoteRole=ROLE_None
	bCollideActors=False
	bCollideWorld=False
}
