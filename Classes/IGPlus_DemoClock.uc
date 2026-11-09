// Server demos only. The server's clock, written every tick, so playback
// knows the server time of each demo frame (bbPlayer keeps a short history
// of every player by it). Live clients never get this actor: it is hidden and
// not always relevant, and a demo recording ignores relevancy.
//
// Playback: udemo's time-based mode reads 0, 1 or 2 demo frames per rendered
// frame, so anything drawn straight from the newest frame steps unevenly.
// IGPlus_DisplayTime is a server time that moves smoothly with the rendered
// frames, one demo frame behind the newest, to draw in between two frames.
class IGPlus_DemoClock extends Info;

var float ServerTime;

// Playback
var float PBLatest;      // newest demo frame's server time
var float PBOffset;      // lowest (playback time - server time) at arrival, last 0.5 s
var bool PBHaveOffset;
var float PBFrameDT;     // average time between demo frames
var float PBMin[4];      // lowest arrival offset per 0.125 s, newest first
var float PBBucketEnd;

replication {
	unreliable if (bDemoRecording && !bClientDemoRecording && Role == ROLE_Authority)
		ServerTime;
}

simulated event Tick(float DeltaTime) {
	local float A;

	if (Role == ROLE_Authority) {
		ServerTime = Level.TimeSeconds;
		return;
	}

	if (ServerTime != PBLatest) {
		if (ServerTime > PBLatest && ServerTime - PBLatest < 0.1) {
			if (PBFrameDT <= 0)
				PBFrameDT = ServerTime - PBLatest;
			else
				PBFrameDT += (ServerTime - PBLatest - PBFrameDT) * 0.1;
		}
		// A frame arrives once playback time passes it: the earliest arrival
		// of the last 0.5 s is the playback clock. Going back or a long jump
		// starts over.
		A = Level.TimeSeconds - ServerTime;
		if (PBHaveOffset == false || ServerTime < PBLatest || ServerTime > PBLatest + 1.0) {
			PBMin[0] = A;
			PBMin[1] = A;
			PBMin[2] = A;
			PBMin[3] = A;
			PBBucketEnd = Level.TimeSeconds + 0.125;
			PBHaveOffset = true;
		}
		PBMin[0] = FMin(PBMin[0], A);
		PBLatest = ServerTime;
	}
	if (PBHaveOffset) {
		if (Level.TimeSeconds >= PBBucketEnd) {
			PBMin[3] = PBMin[2];
			PBMin[2] = PBMin[1];
			PBMin[1] = PBMin[0];
			PBMin[0] = 1000000.0;
			PBBucketEnd = Level.TimeSeconds + 0.125;
		}
		PBOffset = FMin(FMin(PBMin[0], PBMin[1]), FMin(PBMin[2], PBMin[3]));
	}
}

simulated function float IGPlus_DisplayTime() {
	local float FrameDT;

	FrameDT = FClamp(PBFrameDT, 0.004, 0.05);
	if (PBHaveOffset == false)
		return PBLatest;
	return FClamp(Level.TimeSeconds - PBOffset - FrameDT, PBLatest - 2 * FrameDT, PBLatest);
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=False
	bHidden=True
	NetUpdateFrequency=200
}
