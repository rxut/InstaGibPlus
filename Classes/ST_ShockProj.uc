class ST_ShockProj extends ShockProj;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

// For ShockProjectileTakeDamage
var float Health;

var PlayerPawn InstigatingPlayer;
var vector ExtrapolationDelta;

var ST_ProjectileDummy Dummy;

// Client-side shock balls: the owner's client draws its own ball at its age
// since the owner fired, which is where the server tests the owner's beam.
var bool IGPlus_bOwnTimeline;
var bool IGPlus_bLocalBall;   // the owner's own copy, until the server's arrives
var float IGPlus_SpawnTS;     // client: when the local copy was fired
var bool IGPlus_bFromMover;   // client: fired from a lift (positions disagree there)
var float IGPlus_ComboTS;     // client: when a predicted combo hid this ball
var vector IGPlus_WallNormal; // client: hidden ball stopped at a wall, mark not made yet. Server: the wall it waits at
var float IGPlus_WallHoldTime; // server: since when it waits for its owner's moves, at a wall (IGPlus_WallWait) or on something it touched (IGPlus_TouchWait), 0: not waiting
var float IGPlus_WallAge;     // server: its flight time to that wall, or to the touch
var Actor IGPlus_HeldWall;    // server: that wall
var vector IGPlus_HeldVel;    // server: its velocity when it got there
var bool IGPlus_bTouchHold;   // server: it waits on something it touched, not at a wall (IGPlus_TouchWait)
var Actor IGPlus_HeldTouch;   // server: what it touched
var vector IGPlus_HeldTouchLoc; // server: where that was at the touch
var vector IGPlus_HeldHitLoc; // server: where it was touched
var bool IGPlus_bTouched;     // client: on our screen it touched something the server's ball dies on
var vector IGPlus_TouchFrom;  // client: its path is tested for that from here (IGPlus_ClientTouchCheck)
var string IGPlus_EndWhat;    // server, debug data: what ended it, for its owner's log (IGPlus_NoteEnd)
var Pawn IGPlus_ComboBy;      // server: whose beam set off SuperExplosion
var float IGPlus_FireTS;      // server: the owner's move timestamp at the shot
var float IGPlus_FireTime;    // server: Level.TimeSeconds at the shot
var vector IGPlus_FireLoc;    // server: where the shot left from
var vector IGPlus_FireLiftLead; // server: the owner's lift lead at the shot (bbPlayer.IGPlus_OwnLiftLead)
var float IGPlus_FireDelta;   // server: the length of the owner's frame the shot was made in (bbPlayer.IGPlus_MoveFrameDelta)

simulated final function WeaponSettingsRepl FindWeaponSettings() {
	local WeaponSettingsRepl S;

	foreach AllActors(class'WeaponSettingsRepl', S)
		return S;

	return none;
}

simulated final function WeaponSettingsRepl GetWeaponSettings() {
	if (WSettings != none)
		return WSettings;

	WSettings = FindWeaponSettings();
	return WSettings;
}

simulated function PostBeginPlay() {
	local UTPure PureRef;
	local bbPlayer bbP;
	local WeaponSettingsRepl WS;

	if (Role == ROLE_Authority) {

		bbP = bbPlayer(Instigator);
		WS = GetWeaponSettings();

		// Every ball, whatever its owner's settings, so every beam is tested
		// where its shooter saw the ball (UTPure.CompensateFor tests an owner's
		// own client-side ball live instead).
		if (Level.NetMode != NM_Client && bbP != None && WS != None && WS.bEnablePingCompensation)
			PureRef = bbP.zzUTPure;
		if (bbP != None) {
			IGPlus_FireTS = bbP.CurrentTimeStamp;
			IGPlus_FireTime = Level.TimeSeconds;
			IGPlus_FireLoc = Location;
			if (Level.NetMode != NM_Client) {
				IGPlus_FireLiftLead = bbP.IGPlus_OwnLiftLead();
				IGPlus_FireDelta = bbP.IGPlus_MoveFrameDelta;
			}
			if (Level.NetMode != NM_Client && bbP.bDrawDebugData)
				bbP.ClientDebugMessage("Shock ball (server) from "$IGPlus_Vec(Location)$" aim "$(Rotation.Pitch & 65535)$","$(Rotation.Yaw & 65535));
		}
		if (PureRef != None)
			PureRef.RegisterProjectile(self);

		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break; // Find master :D

		if (WImp != none && WImp.WeaponSettings != None && WImp.WeaponSettings.ShockProjectileTakeDamage) {
			Health = WImp.WeaponSettings.ShockProjectileHealth;
		}
	}

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay() {
	local PlayerPawn In;
	local bbPlayer bbP;
	local ST_ShockRifle SR;

	bbP = bbPlayer(Instigator);

	super.PostNetBeginPlay();

	if (bbP != None && bbP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations) {
		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none && (bbPlayer(In) == none || bbPlayer(In).IGPlus_InDemoPlayback() == false))
			InstigatingPlayer = In;
		if (InstigatingPlayer != none) {
			// Own timeline only for a ball that came over the network: offline
			// and on a listen host this is the real ball.
			if (bbP.IGPlus_PredictiveShockCombos() && bbP.IGPlus_InDemoPlayback() == false
				&& Level.NetMode == NM_Client
			) {
				IGPlus_TakeOverLocalBall();
			} else {
				// The old client-side animation: our copy gives way, and Tick
				// extrapolates this one.
				SR = ST_ShockRifle(InstigatingPlayer.Weapon);
				if (SR != none && SR.LocalDummy != none && SR.LocalDummy.bDeleteMe == false)
					SR.LocalDummy.Destroy();
			}
			return;
		}
	}
	Disable('Tick');
}

// Client: the server's copy of our ball has arrived. Carry on from our own
// copy (same shot, same age); without one, catch up by the round trip it is
// behind (sent a one-way after our shot, received a one-way after that).
simulated function IGPlus_TakeOverLocalBall() {
	local ST_ShockProj P, Mine;
	local vector Start, Delta;
	local bool bOldCollideWorld;

	IGPlus_bOwnTimeline = true;

	foreach AllActors(class'ST_ShockProj', P)
		if (P.IGPlus_bLocalBall && P.bDeleteMe == false && P.Instigator == Instigator
			&& (Mine == None || P.IGPlus_SpawnTS < Mine.IGPlus_SpawnTS))
			Mine = P;

	if (Mine == None) {
		// Our copy ran out (late packet): this catch-up is only rough, so no
		// combo is drawn on this ball. The server decides it.
		IGPlus_bFromMover = true;
		IGPlus_TouchFrom = Location;
		Start = Location;
		Delta = Velocity * (0.001 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping);
		Move(Delta);
		if (VSize(Location - Start) < VSize(Delta) - 1.0)
			SetPhysics(PHYS_None); // reached a wall: stop there like our own copy
		return;
	}

	bOldCollideWorld = bCollideWorld;
	bCollideWorld = false;
	SetLocation(Mine.Location);
	bCollideWorld = bOldCollideWorld;
	Velocity = Mine.Velocity;
	if (Mine.Physics == PHYS_None)
		SetPhysics(PHYS_None);
	IGPlus_SpawnTS = Mine.IGPlus_SpawnTS;
	IGPlus_ComboTS = Mine.IGPlus_ComboTS;
	IGPlus_WallNormal = Mine.IGPlus_WallNormal;
	IGPlus_bFromMover = Mine.IGPlus_bFromMover;
	IGPlus_bTouched = Mine.IGPlus_bTouched;
	IGPlus_TouchFrom = Mine.IGPlus_TouchFrom;
	if (Mine.bHidden)
		IGPlus_HideBall();
	Mine.Destroy();
}

simulated event Tick(float Delta) {
	local vector NewXPolDelta;

	super.Tick(Delta);

	// Server, waiting at a wall or on something it touched: the owner's move
	// that gets there ends it (bbPlayer), this is its time limit.
	if (IGPlus_WallHoldTime > 0.0) {
		IGPlus_WallWaitCheck();
		return;
	}

	if (IGPlus_bOwnTimeline && Level.NetMode == NM_Client)
		IGPlus_ClientTouchCheck();

	if (InstigatingPlayer == None)
		return;

	// The old client-side animation (Predictive Shock Combos off).
	if (IGPlus_bOwnTimeline == false) {
		if (bbPlayer(InstigatingPlayer) != none && bbPlayer(InstigatingPlayer).IGPlus_InDemoPlayback())
			return;
		// Catch up to server
		if (OldLocation == Location)
			MoveSmooth(Velocity * class'bbPlayer'.static.IGPlus_OwnProjLead(InstigatingPlayer));
		// Extrapolate locally to compensate for ping
		NewXPolDelta = (Velocity * class'bbPlayer'.static.IGPlus_OwnProjLead(InstigatingPlayer));
		Move(NewXPolDelta - ExtrapolationDelta);
		ExtrapolationDelta = NewXPolDelta;
		return;
	}

	// A combo we drew that the server didn't make: the ball is still here.
	if (IGPlus_ComboTS > 0.0 && InstigatingPlayer != None
		&& Level.TimeSeconds - IGPlus_ComboTS > InstigatingPlayer.PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation + 0.25
	) {
		IGPlus_ComboTS = 0.0;
		IGPlus_ShowBall();
		if (IGPlus_WallNormal != vect(0,0,0))
			IGPlus_WallMark(IGPlus_WallNormal);
		bbPlayer(InstigatingPlayer).ClientDebugMessage("Shock combo: drawn here but the server missed, ball shown again");
	}
}

// The owner's own ball stops at a wall like the server's does, which is
// exploding there; its explosion reaches the owner a round trip later.
simulated function HitWall(vector HitNormal, actor Wall) {
	if (IGPlus_bOwnTimeline == false) {
		if (IGPlus_WallWait(HitNormal, Wall) == false) {
			IGPlus_NoteEnd("it hit a wall", None);
			Super.HitWall(HitNormal, Wall);
		}
		return;
	}
	SetPhysics(PHYS_None);
	// A combo we drew hid it: it never got here unless the server says so.
	if (bHidden)
		IGPlus_WallNormal = HitNormal;
	else
		IGPlus_WallMark(HitNormal);
}

// Server: this ball is at a wall, but its owner's moves are not there yet
// (they come in a packet's wobble and up to a server frame late), so the
// owner's screen still has it flying. The owner's beam is tested where that
// screen has the ball (IGPlus_OwnerSeesBall), and a ball that exploded here
// already is not there to be hit: the owner's client drew a combo the server
// never made. So the ball waits here for its owner's moves, like the owner's
// own copy waits at the wall for the server. True if it waits.
function bool IGPlus_WallWait(vector HitNormal, Actor Wall) {
	if (IGPlus_StartHold(VSize(Location - IGPlus_FireLoc)) == false)
		return false;
	IGPlus_WallNormal = HitNormal;
	IGPlus_HeldWall = Wall;
	return true;
}

// Server: this ball touched something (a player, a disc, another ball), but
// its owner's moves are not there yet, as at a wall (IGPlus_WallWait). A beam
// the owner fired before the touch on its own screen comes in one of those
// moves, and a ball that exploded here already is not there to be hit: the
// owner's client drew a combo the server never made. So the ball waits here
// for its owner's moves and then explodes on what it touched, which takes
// the same damage as at the touch (IGPlus_TouchExplode). True if it waits.
// The touch was somewhere on this tick's way (OldLocation to Location): the
// owner's beam counts up to that spot, not to the end of the tick.
function bool IGPlus_TouchWait(Actor Other, vector HitLocation) {
	local vector TouchLoc;

	TouchLoc = OldLocation + (Location - OldLocation) * IGPlus_TouchFraction(OldLocation, Location, Other.Location,
		CollisionRadius + Other.CollisionRadius, CollisionHeight + Other.CollisionHeight);
	IGPlus_bTouchHold = true; // before the wait is tested: its slack is a touch's (IGPlus_WallSlack)
	if (IGPlus_StartHold(VSize(TouchLoc - IGPlus_FireLoc)) == false) {
		IGPlus_bTouchHold = false;
		return false;
	}
	IGPlus_HeldTouch = Other;
	IGPlus_HeldTouchLoc = Other.Location;
	IGPlus_HeldHitLoc = HitLocation;
	IGPlus_NoteEnd("it hit ", Other);
	return true;
}

// The share of the way from Start to End at which a body first overlaps
// another, as the engine tests a touch: cylinders, R and H the two radii and
// the two half heights added up, C the other one's middle. 0: it overlaps at
// Start already. 1: nowhere on this way.
static function float IGPlus_TouchFraction(vector Start, vector End, vector C, float R, float H) {
	local vector P, D;
	local float A, B, Disc, T0, T1, Z0, Z1;

	P = Start - C;
	D = End - Start;
	T0 = 0.0;
	T1 = 1.0;
	A = D.X * D.X + D.Y * D.Y;
	if (A < 0.000001) {
		if (P.X * P.X + P.Y * P.Y > R * R)
			return 1.0;
	} else {
		B = 2.0 * (P.X * D.X + P.Y * D.Y);
		Disc = B * B - 4.0 * A * (P.X * P.X + P.Y * P.Y - R * R);
		if (Disc < 0.0)
			return 1.0;
		Disc = Sqrt(Disc);
		T0 = FMax(T0, (-B - Disc) / (2.0 * A));
		T1 = FMin(T1, (-B + Disc) / (2.0 * A));
	}
	if (Abs(D.Z) < 0.000001) {
		if (Abs(P.Z) > H)
			return 1.0;
	} else {
		Z0 = (-H - P.Z) / D.Z;
		Z1 = (H - P.Z) / D.Z;
		T0 = FMax(T0, FMin(Z0, Z1));
		T1 = FMin(T1, FMax(Z0, Z1));
	}
	if (T0 > T1)
		return 1.0;
	return T0;
}

// Server: stops this ball where it is to wait for its owner's moves, if its
// owner's beam is tested on the owner's own timeline (UTPure.IGPlus_CompOwnBall)
// and those moves are not here yet. Not from a moving lift: the owner's ball
// flies another path there. Flight: how far it flew to what stops it.
function bool IGPlus_StartHold(float Flight) {
	local bbPlayer P;

	P = bbPlayer(Instigator);
	if (Level.NetMode == NM_Client || P == None || P.RemoteRole != ROLE_AutonomousProxy
		|| P.zzUTPure == None || P.IGPlus_EnableInputReplication
		|| GetWeaponSettings() == None || GetWeaponSettings().bEnablePingCompensation == false
		|| P.IGPlus_PredictiveShockCombos() == false
		|| IGPlus_FireTS <= 0.0 || Speed <= 0.0 || IGPlus_FireLiftLead != vect(0,0,0))
		return false;

	IGPlus_WallAge = Flight / Speed;
	if (IGPlus_OwnerFlown(P) >= IGPlus_WallAge + IGPlus_WallSlack())
		return false;

	IGPlus_WallHoldTime = Level.TimeSeconds;
	IGPlus_HeldVel = Velocity; // the wall ring's facing (Explode)
	SetPhysics(PHYS_None);
	Enable('Tick');
	// One at a time: an earlier ball still waiting is left to its own Tick.
	P.IGPlus_WallBall = self;
	return true;
}

// Server: how long this ball has flown on its owner's screen once the frame
// of the owner's last move is over (it is moved in the frame it is fired in).
function float IGPlus_OwnerFlown(bbPlayer P) {
	return P.CurrentTimeStamp - IGPlus_FireTS + IGPlus_FireDelta;
}

// Server: the two machines stop the ball a unit or two apart, so the owner's
// screen may have it flying for a frame longer than our sums say: it waits
// that much longer. Never a whole frame, or our push on our owner is late.
function float IGPlus_WallSlack() {
	if (IGPlus_bTouchHold)
		return FMin(IGPLUS_TOUCH_SLACK, IGPlus_FireDelta);
	return FMin(0.004, IGPlus_FireDelta);
}

// After a touch the slack is half the wall's. At a wall the owner's own ball
// stops a unit or two from ours, so its screen can have it flying on. A touch
// does not stop the owner's ball: its client only stops drawing combos on it
// (IGPlus_ClientTouchCheck), and on a test rig every combo it still drew was
// fired before the touch here (26 of 26, the closest by 0.2 ms). So this
// slack only decides how long after the touch a beam still makes the combo.
const IGPLUS_TOUCH_SLACK = 0.002;

// Server: done waiting once the owner's moves are at the wall too, or after
// MaxJitterTime. Then it explodes against the wall as it would have. bbPlayer
// calls this at the end of each of the owner's moves: the move that gets
// there is the frame the ball stops in on the owner's screen, so a beam on it
// was still tested (IGPlus_OwnerSeesBall), and our push on our owner is queued
// in time to land on that move, as its client predicted it.
function IGPlus_WallWaitCheck() {
	local bbPlayer P;
	local float Waited, MaxWait;

	if (IGPlus_WallHoldTime <= 0.0)
		return;
	P = bbPlayer(Instigator);
	Waited = Level.TimeSeconds - IGPlus_WallHoldTime;
	if (P != None && P.zzUTPure != None) {
		MaxWait = P.zzUTPure.Settings.MaxJitterTime;
		if (IGPlus_bTouchHold)
			MaxWait = FMin(MaxWait, IGPLUS_TOUCH_WAIT_MAX);
		if (IGPlus_OwnerFlown(P) < IGPlus_WallAge + IGPlus_WallSlack() && Waited < MaxWait)
			return;
		if (P.IGPlus_WallBall == self)
			P.IGPlus_WallBall = None;
		if (P.bDrawDebugData && IGPlus_bTouchHold && IGPlus_HeldTouch != None)
			P.ClientDebugMessage("Shock ball (server) waited "$int(Waited * 1000.0 / Level.TimeDilation)$"ms for our moves after it touched "$IGPlus_ActorName(IGPlus_HeldTouch)
				$", which moved "$int(VSize(IGPlus_HeldTouch.Location - IGPlus_HeldTouchLoc))$"uu meanwhile, no beam came");
		else if (P.bDrawDebugData && IGPlus_bTouchHold)
			P.ClientDebugMessage("Shock ball (server) waited "$int(Waited * 1000.0 / Level.TimeDilation)$"ms for our moves after it touched "$IGPlus_ActorName(None)$", no beam came");
		else if (P.bDrawDebugData)
			P.ClientDebugMessage("Shock ball (server) waited "$int(Waited * 1000.0 / Level.TimeDilation)$"ms at the wall for our moves, no beam came");
	}
	Velocity = IGPlus_HeldVel;
	if (IGPlus_bTouchHold) {
		IGPlus_TouchExplode();
		return;
	}
	IGPlus_WallHoldTime = 0.0;
	IGPlus_NoteEnd("it hit a wall", None);
	Super.HitWall(IGPlus_WallNormal, IGPlus_HeldWall);
}

// A ball waiting on a player it touched keeps that player's blast waiting, and
// the player's own screen has the ball flying on meanwhile. The owner's moves
// are a server frame or two behind at most (the wall waits in players' logs
// never passed 7 ms).
// ponytail: fixed 30 ms cap, tie it to the tick length if a slow-ticking server needs more
const IGPLUS_TOUCH_WAIT_MAX = 0.03;

// Server: done waiting on what it touched (IGPlus_TouchWait), no beam of its
// owner's came: the explosion of the touch. What it touched has moved on
// while the ball stood still, and the blast falls off with distance, so the
// ball goes along by as much: the same damage as at the touch.
function IGPlus_TouchExplode() {
	local vector Shift, HitNormal;
	local bool bOldCollideWorld;

	HitNormal = Normal(IGPlus_HeldHitLoc - IGPlus_HeldTouchLoc);
	if (IGPlus_HeldTouch != None && IGPlus_HeldTouch.bDeleteMe == false)
		Shift = IGPlus_HeldTouch.Location - IGPlus_HeldTouchLoc;
	if (Shift != vect(0,0,0)) {
		// Still waiting (IGPlus_WallHoldTime) while it moves: it touches nothing.
		bOldCollideWorld = bCollideWorld;
		bCollideWorld = false;
		SetCollision(false, false, false);
		SetLocation(Location + Shift);
		bCollideWorld = bOldCollideWorld;
	}
	IGPlus_WallHoldTime = 0.0;
	Explode(IGPlus_HeldHitLoc + Shift, HitNormal);
}

// Debug data: a player's name, any other actor's class.
static function string IGPlus_ActorName(Actor A) {
	if (A == None)
		return "something that is gone";
	// Location Offset Fix: it stands where a player is drawn while they are parked.
	if (IGPlus_CollisionDummy(A) != None)
		return "a player's body";
	if (Pawn(A) != None && Pawn(A).PlayerReplicationInfo != None)
		return Pawn(A).PlayerReplicationInfo.PlayerName;
	return "a "$A.Class.Name;
}

// Server, debug data: what ended this ball and when on its owner's screen
// (its flight to here, its wait is not part of that), for its owner's log
// when a beam of the owner's finds it gone (bbPlayer.IGPlus_OwnBallGoneText).
// A later cause replaces an earlier one: a ball waiting on a touch can still
// be set off.
function IGPlus_NoteEnd(string What, Actor Other) {
	local bbPlayer P;
	local float Age;

	P = bbPlayer(Instigator);
	if (Level.NetMode == NM_Client || P == None || P.bDrawDebugData == false)
		return;
	if (Other != None)
		What = What$IGPlus_ActorName(Other);
	if (IGPlus_WallHoldTime > 0.0)
		Age = IGPlus_WallAge;
	else if (Speed > 0.0)
		Age = VSize(Location - IGPlus_FireLoc) / Speed;
	IGPlus_EndWhat = What;
	P.IGPlus_NoteOwnBallEnd(self, What, IGPlus_FireTS + Age);
}

// Every way this ball can end passes here: one that noted no cause.
simulated event Destroyed() {
	if (IGPlus_EndWhat == "")
		IGPlus_NoteEnd("it ran out, or something else removed it", None);
	Super.Destroyed();
}

// Client: has our own ball touched something on our screen that the server's
// ball dies on (Projectile.Touch and ShockProj.ProcessTouch, which only run
// on the server)? Its path since the last check, against where things are
// drawn now. From then on no combo is drawn on it ahead of the server
// (ST_ShockRifle.IGPlus_ClientOwnBall): the server's ball may be gone there,
// and a combo shown that didn't happen is worse than one shown a ping late.
// Our ball flies on as before, the server says what became of it.
// The server has other players a ping ahead of where we draw them, so a
// moving one it can meet where our screen shows nothing: not known here.
// The engine's trace skips a body the ball is already inside and leaving
// (UPrimitive::LineCheck), so a ball fired from inside one is not caught.
// With Location Offset Fix the other players are parked during the frame and
// an IGPlus_CollisionDummy stands where each is drawn: that is their body here.
simulated function IGPlus_ClientTouchCheck() {
	local Actor A;
	local vector HitLoc, HitNorm, From;

	From = IGPlus_TouchFrom;
	IGPlus_TouchFrom = Location;
	if (IGPlus_bTouched || From == Location || From == vect(0,0,0))
		return;
	foreach TraceActors(class'Actor', A, HitLoc, HitNorm, Location, From,
		CollisionRadius * vect(1,1,0) + CollisionHeight * vect(0,0,1)
	) {
		if (IGPlus_ServerBallDiesOn(A) == false)
			continue;
		IGPlus_bTouched = true;
		if (bbPlayer(Instigator) != None && bbPlayer(Instigator).bDrawDebugData)
			bbPlayer(Instigator).ClientDebugMessage("Shock ball (client): on our screen it touched "$IGPlus_ActorName(A)$", the server decides a combo on it");
		break;
	}
}

// Client: the server's rule for what its ball explodes on. Walls and movers
// stop our ball itself (HitWall). What is hidden here the server no longer
// has there: a player who died (bbPlayer's trace guard), a ball of ours that
// a combo we drew took away.
simulated function bool IGPlus_ServerBallDiesOn(Actor A) {
	if (A == None || A == self || A == Instigator || A == Level || A.bDeleteMe || A.bHidden || Mover(A) != None)
		return false;
	if (Projectile(A) != None && A.CollisionRadius <= 0.0)
		return false;
	return A.bProjTarget || (A.bBlockActors && A.bBlockPlayers);
}

auto state Flying {
	// Server (stock's rule, and stock runs it only there): a touch explodes
	// this ball, once its owner's moves are here too (IGPlus_TouchWait).
	function ProcessTouch(Actor Other, vector HitLocation) {
		if (Other == Instigator || (Other.IsA('Projectile') && Other.CollisionRadius <= 0.0))
			return;
		if (IGPlus_WallHoldTime > 0.0) {
			// Waiting on a touch already: it explodes there. Waiting at a
			// wall: this touch sets it off at once, as before.
			if (IGPlus_bTouchHold)
				return;
		} else if (IGPlus_TouchWait(Other, HitLocation)) {
			return;
		}
		IGPlus_NoteEnd("it hit ", Other);
		Explode(HitLocation, Normal(HitLocation - Other.Location));
	}
}

simulated function IGPlus_WallMark(vector HitNormal) {
	if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)
		Spawn(ExplosionDecal, self,, Location, rotator(HitNormal));
}

// Client: our own beam set this ball off. The server's ring for it is dropped
// when it gets here (IGPlus_OwnerComboRing), so this is the combo we see.
simulated function IGPlus_PredictCombo() {
	// Not against the wall after all: no push from that.
	if (bbPlayer(Instigator) != None)
		bbPlayer(Instigator).IGPlus_SKCancelShockBall();
	Spawn(class'ut_ComboRing',,'', Location, Instigator.ViewRotation);
	PlaySound(ExploSound,,20.0,,2000,0.6);
	IGPlus_ComboTS = Level.TimeSeconds;
	IGPlus_HideBall();
	if (bbPlayer(Instigator) != None) {
		// A client demo records this ring without its rotation, and the
		// sound not at all when this is our own copy of the ball (its demo
		// copy plays it, IGPlus_DemoTrack).
		bbPlayer(Instigator).xxClientDemoFix(None, class'ut_ComboRing', Location,,, Instigator.ViewRotation);
		bbPlayer(Instigator).IGPlus_DemoTrackSound(self, ExploSound, 20.0, 2000, 0.6);
		bbPlayer(Instigator).IGPlus_PredComboTS = Level.TimeSeconds;
		bbPlayer(Instigator).IGPlus_PredComboLoc = Location;
		bbPlayer(Instigator).ClientDebugMessage("Shock combo: drawn on the beam's frame");
		bbPlayer(Instigator).IGPlus_SKPredictComboOnDisc(self);
	}
}

static function string IGPlus_Vec(vector V) {
	return int(V.X)$","$int(V.Y)$","$int(V.Z);
}

simulated function IGPlus_HideBall() {
	bHidden = true;
	LightType = LT_None;
}

simulated function IGPlus_ShowBall() {
	bHidden = false;
	if (Level.bDropDetail == false)
		LightType = default.LightType;
}

// Server: where the owner's screen has this ball for the owner's move being
// processed: its age since the shot in the owner's own timestamps, along its
// straight path. Not the live ball, which is off by up to a server frame of
// packet timing. False when the owner's screen has it stopped at a wall it
// hasn't reached here yet: it is gone at that age.
// The owner's beam leaves at the start of its frame, before that frame moves
// the ball, and the ball was already moved in the frame it was fired in. So
// on that screen the ball has flown the time between the two moves, plus the
// shot's frame, less the beam's frame (each a single-frame move).
function bool IGPlus_OwnerSeesBall(bbPlayer P, out vector Loc) {
	local float Live, Age;
	local bool bSeen;

	Loc = Location;
	bSeen = true;
	// Input replication stamps a packet's inputs with its newest time: test live.
	if (P.IGPlus_EnableInputReplication == false) {
		Live = Level.TimeSeconds - IGPlus_FireTime;
		// ponytail: +-0.2s bounds how far a client clock can move the ball
		Age = FClamp(P.CurrentTimeStamp - IGPlus_FireTS + IGPlus_FireDelta - P.IGPlus_MoveFrameDelta,
			FMax(0.0, Live - 0.2), Live + 0.2);
		// Waiting at a wall for its owner (IGPlus_WallWait): the owner's
		// screen has it on its way there, on the line from its start to where
		// it stopped (its velocity isn't its path any more), or at the wall
		// within IGPlus_WallSlack. It is gone at the end of the move that
		// stops it on that screen (IGPlus_WallWaitCheck).
		// Waiting on something it touched (IGPlus_TouchWait): the same, but
		// the owner's own ball flies on through that, so here the ball is
		// gone for a beam that left after the touch.
		if (IGPlus_WallHoldTime > 0.0) {
			if (IGPlus_bTouchHold) {
				// It stands at the end of the touch's tick, the touch was before that.
				if (Age >= IGPlus_WallAge + IGPlus_WallSlack())
					return false;
				Loc = IGPlus_FireLoc + (Location - IGPlus_FireLoc)
					* FMin(1.0, Age * Speed / FMax(1.0, VSize(Location - IGPlus_FireLoc)));
				return true;
			}
			if (Age < IGPlus_WallAge)
				Loc = IGPlus_FireLoc + (Location - IGPlus_FireLoc) * (Age / IGPlus_WallAge);
			return true;
		}
		Loc = IGPlus_FireLoc + Velocity * Age;
		bSeen = Age <= Live || FastTrace(Loc, Location);
	}
	// The owner fired it from a round trip of lift travel behind the server's
	// spot (a moving lift): the owner's beam leaves from the owner's own spot
	// (ST_ShockRifle.TraceFireAt), so the ball is tested where the owner's
	// screen has it too.
	Loc -= IGPlus_FireLiftLead;
	return bSeen;
}

// Server: the conditions under which the owner's client draws its own combos
// on its own balls (ST_ShockRifle.ClientTraceFire). Whoever set this one off:
// the owner may have drawn one on it with a beam of its own.
function bool IGPlus_OwnerMayDrawCombo() {
	local bbPlayer P;

	P = bbPlayer(Instigator);
	return P != None && P.RemoteRole == ROLE_AutonomousProxy
		&& GetWeaponSettings() != None && GetWeaponSettings().bEnablePingCompensation
		&& P.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations
		&& P.IGPlus_PredictiveShockCombos();
}

// Server: a combo on its owner's own ball goes off where the owner saw the
// ball already (no fast-forward, the same moves). Players are hurt where the
// owner saw them, rewound by the owner's ping up to ShockComboRewindMax (and
// PingCompensationMax). 0: where they are now.
function int IGPlus_ComboRewindMs() {
	local bbPlayer P;

	P = bbPlayer(Instigator);
	if (P == None || IGPlus_ComboBy != P || P.RemoteRole != ROLE_AutonomousProxy || P.zzUTPure == None
		|| WImp.WSettingsRepl.bEnablePingCompensation == false || WImp.WeaponSettings.ShockComboRewindMax <= 0)
		return 0;
	return Min(int(IGPlus_WeaponImplementationBase(WImp).IGPlus_GetHitscanRewindMs(P)), WImp.WeaponSettings.ShockComboRewindMax);
}

function SuperExplosion() {
	local float ComboDamage, ComboRadius, ComboMomentum;
	local IGPlus_OwnerComboRing Ring;
	local vector OwnerLoc, DiscBlast;
	local int RewindMs;
	local UTPure PureRef;
	local ST_ProjectileDummy PD;
	local bbPlayer DiscOwner;

	ComboDamage = WImp.WeaponSettings.ShockComboDamage;
	ComboRadius = WImp.WeaponSettings.ShockComboHurtRadius;
	ComboMomentum = WImp.WeaponSettings.ShockComboMomentum * MomentumTransfer * 2;

	if (IGPlus_ComboBy == Instigator)
		IGPlus_NoteEnd("an earlier beam of ours set it off", None);
	else if (IGPlus_ComboBy != None)
		IGPlus_NoteEnd("set off by a beam of ", IGPlus_ComboBy);
	else
		IGPlus_NoteEnd("a beam set it off", None);

	// Waiting at a wall for its owner (IGPlus_WallWait): the owner's own combo
	// goes off where the owner's screen had the ball, short of the wall. It
	// touches nothing on its way back there.
	if (IGPlus_WallHoldTime > 0.0 && IGPlus_ComboBy == Instigator && bbPlayer(Instigator) != None
		&& IGPlus_OwnerSeesBall(bbPlayer(Instigator), OwnerLoc)
	) {
		if (bbPlayer(Instigator).bDrawDebugData && IGPlus_bTouchHold)
			bbPlayer(Instigator).ClientDebugMessage("Shock combo (server): our ball had waited "
				$int((Level.TimeSeconds - IGPlus_WallHoldTime) * 1000.0 / Level.TimeDilation)$"ms after it touched "
				$IGPlus_ActorName(IGPlus_HeldTouch)$", set off "$int(VSize(OwnerLoc - Location))$"uu short of there");
		else if (bbPlayer(Instigator).bDrawDebugData)
			bbPlayer(Instigator).ClientDebugMessage("Shock combo (server): our ball had waited "
				$int((Level.TimeSeconds - IGPlus_WallHoldTime) * 1000.0 / Level.TimeDilation)$"ms at the wall, set off "
				$int(VSize(OwnerLoc - Location))$"uu short of it");
		SetCollision(false, false, false);
		SetLocation(OwnerLoc);
		IGPlus_WallAge = 0.0; // it is there now: IGPlus_OwnerSeesBall gives this spot from here on
	}

	// Register explosion for translocator simulation tracking
	IGPlus_WeaponImplementationBase(WImp).RegisterExplosion(
		Location,
		ComboRadius,
		ComboDamage,
		ComboMomentum,
		Instigator
	);

	// Each combo rewinds on its own and is undone before anything else runs:
	// combos going off together are each judged from their own owner's view.
	RewindMs = IGPlus_ComboRewindMs();
	if (RewindMs > 0) {
		PureRef = bbPlayer(Instigator).zzUTPure;
		PureRef.CompensateFor(RewindMs, Instigator, true);
		// This ball's own stand-in is here too: not a victim of its own blast.
		for (PD = PureRef.ProjDummies; PD != None; PD = PD.Next)
			if (PD.Actual == self) {
				PD.SetCollision(false, false, false);
				PD.bProjTarget = false;
			}
	}

	// The owner's own combo by its own deterministic disc: the blast here only
	// damages that disc. Its push comes after, from where the owner's screen
	// had the ball, as the owner's client pushed its own disc.
	DiscOwner = bbPlayer(Instigator);
	if (DiscOwner != None && IGPlus_ComboBy == DiscOwner && DiscOwner.IGPlus_PredictsDiscBoost()) {
		if (IGPlus_OwnerSeesBall(DiscOwner, DiscBlast) == false)
			DiscBlast = Location;
		DiscOwner.IGPlus_SKComboDisc = true;
	} else {
		DiscOwner = None;
	}

	if (WImp.WeaponSettings.bEnableEnhancedSplashShockCombo) {
		WImp.EnhancedHurtRadius(
			self,
			ComboDamage,
			ComboRadius,
			MyDamageType,
			ComboMomentum,
			Location);
	} else {
		HurtRadius(
			ComboDamage,
			ComboRadius,
			MyDamageType,
			ComboMomentum,
			Location);
	}

	if (RewindMs > 0)
		PureRef.EndCompensation();

	if (DiscOwner != None) {
		DiscOwner.IGPlus_SKComboDisc = false;
		DiscOwner.IGPlus_SKComboOnDisc(DiscBlast, CollisionRadius, ComboRadius, ComboMomentum,
			WImp.WeaponSettings.bEnableEnhancedSplashShockCombo);
	}

	if (IGPlus_OwnerMayDrawCombo()) {
		// The owner's client plays the sound itself if it didn't draw this one.
		Ring = Spawn(class'IGPlus_OwnerComboRing', Instigator,'', Location, Instigator.ViewRotation);
		if (Ring != None) {
			// The owner sees the ring where its beam met the ball on its own
			// screen, which is where its client drew it. Another player's
			// beam: where it went off.
			if (IGPlus_ComboBy == Instigator) {
				IGPlus_OwnerSeesBall(bbPlayer(Instigator), OwnerLoc);
				Ring.IGPlus_OwnerShift = OwnerLoc - Location;
			}
			Ring.PlayOwnedSound(ExploSound,,20.0,,2000,0.6);
		}
	} else {
		Spawn(Class'ut_ComboRing',,'',Location, Instigator.ViewRotation);
		PlaySound(ExploSound,,20.0,,2000,0.6);
	}

	Destroy();
}

function Explode(vector HitLocation,vector HitNormal) {
	local bbPlayer bbP;

	PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
	// Predicted self-knockback: its age is its travel over its speed.
	bbP = bbPlayer(Instigator);
	if (IGPlus_FireTS > 0.0 && Speed > 0.0 && bbP != none && bbP.IGPlus_PredictedSelfKnockback)
		bbP.IGPlus_SKBeginCapture();
	else
		bbP = none;
	if (WImp.WeaponSettings.bEnableEnhancedSplashShockProjectile) {
		WImp.EnhancedHurtRadius(
			self,
			WImp.WeaponSettings.ShockProjectileDamage,
			WImp.WeaponSettings.ShockProjectileHurtRadius,
			MyDamageType,
			WImp.WeaponSettings.ShockProjectileMomentum * MomentumTransfer,
			Location);
	} else {
		HurtRadius(
			WImp.WeaponSettings.ShockProjectileDamage,
			WImp.WeaponSettings.ShockProjectileHurtRadius,
			MyDamageType,
			WImp.WeaponSettings.ShockProjectileMomentum * MomentumTransfer,
			Location);
	}
	if (bbP != none)
		bbP.IGPlus_SKEndCaptureFor(self, IGPlus_FireTS + VSize(Location - IGPlus_FireLoc) / Speed, Location);
	if (WImp.WeaponSettings.ShockProjectileDamage > 60)
		Spawn(class'ut_RingExplosion3',,, HitLocation+HitNormal*8,rotator(HitNormal));
	else
		Spawn(class'ut_RingExplosion',,, HitLocation+HitNormal*8,rotator(Velocity));		

	Destroy();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
	if (WImp.WeaponSettings.ShockProjectileTakeDamage == false)
		return;

	if (DamageType == 'Pulsed'|| DamageType == 'Corroded') {
		Health -= Damage;
		if (Health <= 0) {
			IGPlus_NoteEnd("shot down by ", EventInstigator);
			Spawn(class'ut_RingExplosion',,, Location + Momentum * 0.1, rotator(Momentum));
			Destroy();
		}
	}
}

defaultproperties {
}
