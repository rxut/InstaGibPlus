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
var PlayerPawn PBViewer; // the local viewer (udemo's DemoPlaybackSpec)
var float PBViewerSearchTime;
var bool PBTimerFixed;   // the match timer's stale minute mark is cleared

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

	IGPlus_UsePureHUD();
	if (PBTimerFixed == false)
		IGPlus_FixMatchTimer();

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

// The server keeps the last minute mark in RemainingMinute and never clears
// it. A demo started mid-game gets it in its first frame, and within a second
// the GRI's Timer sets RemainingTime back to that mark (15:00 counting down at
// 14:23), until the next mark or a spectator's 10 s time sync. RemainingTime
// in that first frame is current: clear the mark before the Timer uses it.
simulated function IGPlus_FixMatchTimer() {
	local GameReplicationInfo GRI;

	foreach AllActors(class'GameReplicationInfo', GRI) {
		GRI.RemainingMinute = 0;
		PBTimerFixed = true;
	}
}

// udemo gives a server demo the game type's default HUD class (stock).
// UTPure swaps the HUD only on the running server (Level.Game.HUDType), so
// playback had no Pure HUD: no match timer, no boots. Swapped here.
simulated function IGPlus_UsePureHUD() {
	local PlayerPawn P;
	local class<HUD> PureClass;
	local HUD NewHUD;

	if (PBViewer == none || PBViewer.bDeleteMe) {
		PBViewer = none;
		if (Level.TimeSeconds < PBViewerSearchTime)
			return;
		PBViewerSearchTime = Level.TimeSeconds + 1.0;
		foreach AllActors(class'PlayerPawn', P)
			if (P.Role == ROLE_Authority && Viewport(P.Player) != none) {
				PBViewer = P;
				break;
			}
		if (PBViewer == none)
			return;
	}
	if (PBViewer.myHUD == none)
		return;

	PureClass = IGPlus_PureHUDFor(PBViewer.myHUD.Class);
	if (PureClass == none)
		return;
	NewHUD = PBViewer.Spawn(PureClass, PBViewer);
	if (NewHUD == none)
		return;
	// HUD mutators (kill feed) that already hooked into the old HUD.
	NewHUD.HUDMutator = PBViewer.myHUD.HUDMutator;
	PBViewer.myHUD.Destroy();
	PBViewer.myHUD = NewHUD;
	PBViewer.HUDType = PureClass;
	if (PBViewer.Scoring != none)
		PBViewer.Scoring.OwnerHUD = NewHUD;
}

// The Pure HUD UTPure uses for a stock HUD class (UTPure.PreBeginPlay).
// Console demoplay gives the viewer a stock CHSpectator with CHSpectatorHUD:
// that gets the Pure HUD of the game type.
simulated function class<HUD> IGPlus_PureHUDFor(class<HUD> C) {
	local GameReplicationInfo GRI;
	local class<GameInfo> G;

	if (C == class'CHSpectatorHUD') {
		GRI = PBViewer.GameReplicationInfo;
		if (GRI == none)
			foreach AllActors(class'GameReplicationInfo', GRI)
				break;
		if (GRI == none || GRI.GameClass == "")
			return none;
		G = class<GameInfo>(DynamicLoadObject(GRI.GameClass, class'Class', true));
		if (G == none || G.default.HUDType == class'CHSpectatorHUD')
			return none;
		return IGPlus_PureHUDFor(G.default.HUDType);
	}
	if (C == class'ChallengeDominationHUD')
		return class'PureDOMHUD';
	if (C == class'ChallengeCTFHUD')
		return class'PureCTFHUD';
	if (C == class'AssaultHUD')
		return class'PureAssaultHUD';
	if (C == class'ChallengeTeamHUD')
		return class'PureTDMHUD';
	if (C == class'ChallengeHUD')
		return class'PureDMHUD';
	return none;
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
