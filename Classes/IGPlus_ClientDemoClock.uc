// Client demos only. The recording client writes its own clock into the
// demo every frame (bbPlayer and bbCHSpectator spawn this while recording).
// Playback uses it to show each projectile where the recording client had it.
//
// In playback the engine puts a projectile from the demo on its recorded
// spot and then moves it by the whole playback frame before it is drawn.
// Its location is sent once (bNetInitial), so it stayed that far ahead for
// its whole flight. This actor ticks before every projectile that arrives
// after it (actors tick in list order, new ones last), and its Tick runs
// before the projectile's physics. On the frame a projectile arrives it
// moves it by the recorded time since the projectile's own demo frame, and
// stops it for that frame's physics. From the next frame on it flies as
// before.
//
// It also marks the recorded player as playing back from the first frame
// (bbPlayer.IGPlus_InDemoPlayback otherwise finds out within a second), so
// our own projectiles fired in the first second show as on our screen.
//
// Live: only the clock. Server demos never contain this actor. In console
// demoplay the recorder (player or spectator) spawns one too (the demo driver
// is set while playing): that one is Authority and only writes its clock.
class IGPlus_ClientDemoClock extends SpawnNotify;

var float RecTime;          // recording client: Level.TimeSeconds of this frame

// Playback
var bool bRecorderFound;
var Projectile HoldP[32];
var vector HoldLoc[32];
var float HoldTime[32];
var vector HoldVel[32];
var byte HoldState[32];     // 1: arrived this frame, 2: held, flies on next frame

replication {
	// The engine sets bClientDemoRecording only while it records this actor.
	unreliable if (bClientDemoRecording)
		RecTime;
}

// Live: the clock only. Playback: also a SpawnNotify.
simulated function PostBeginPlay() {
	if (Role < ROLE_Authority)
		super.PostBeginPlay();
}

simulated function PostNetBeginPlay() {
	MarkRecorder();
}

// The recorded player plays back as AutonomousProxy, the others as
// SimulatedProxy. That role can come after us, so Tick retries until the
// recorder shows up. In a spectator's demo that is the spectator
// (bbCHSpectator spawns this too): nothing to mark.
// Pawns from the demo are not in Level.PawnList (AddPawn is not simulated).
simulated function MarkRecorder() {
	local Pawn P;

	if (Role == ROLE_Authority)
		return;
	foreach AllActors(class'Pawn', P)
		if (P.Role == ROLE_AutonomousProxy) {
			if (bbPlayer(P) != none)
				bbPlayer(P).zzbDemoPlayback = true;
			bRecorderFound = true;
			return;
		}
}

// Projectiles from the demo only: one spawned here in playback is Authority.
// Velocity and Physics arrive after this, Location is the recorded spot.
simulated event Actor SpawnNotification(Actor A) {
	local int i;

	if (A.Role != ROLE_SimulatedProxy)
		return A;
	for (i = 0; i < ArrayCount(HoldP); i++)
		if (HoldState[i] == 0) {
			HoldP[i] = Projectile(A);
			HoldLoc[i] = A.Location;
			HoldTime[i] = RecTime;
			HoldState[i] = 1;
			break;
		}
	// ponytail: 32 arrivals in one frame (a flak volley is 8), more fly as before
	return A;
}

simulated event Tick(float DeltaTime) {
	local int i;
	local Projectile P;
	local float D;

	if (Role == ROLE_Authority) {
		RecTime = Level.TimeSeconds;
		return;
	}
	if (bRecorderFound == false)
		MarkRecorder();
	for (i = 0; i < ArrayCount(HoldP); i++) {
		if (HoldState[i] == 0)
			continue;
		P = HoldP[i];
		if (P == none || P.bDeleteMe) {
			HoldState[i] = 0;
		} else if (HoldState[i] == 2) {
			P.Velocity = HoldVel[i];
			HoldState[i] = 0;
		} else {
			HoldState[i] = 0;
			// Falling ones (grenades, bio, flak slug) fly as before: gravity
			// still moves them at zero velocity. One something else moved since
			// it spawned is left alone. Under 1 uu is its location arriving
			// rounded to whole units.
			if (P.Physics != PHYS_Projectile || P.Velocity == vect(0,0,0) || VSize(P.Location - HoldLoc[i]) > 1.0)
				continue;
			// The recorded time between its demo frame and the newest one read.
			D = FClamp(RecTime - HoldTime[i], 0.0, DeltaTime);
			// A wall in the way: Move stops there without HitWall, so this
			// frame's physics bounces or explodes it as before.
			if (P.FastTrace(P.Location + P.Velocity * D, P.Location) == false)
				continue;
			// Moved with its own velocity, so Touch and ZoneChange (water slows
			// rockets and blades) see it as they would in physics.
			P.Move(P.Velocity * D);
			if (P.bDeleteMe)
				continue;
			HoldVel[i] = P.Velocity;
			P.Velocity = vect(0,0,0);
			HoldState[i] = 2;
		}
	}
}

defaultproperties {
	ActorClass=class'Projectile'
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=False
	bAlwaysRelevant=False
}
