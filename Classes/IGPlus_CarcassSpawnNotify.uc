class IGPlus_CarcassSpawnNotify extends SpawnNotify;

var bool bEnableCarcassCollision;

// Client: recent corpses (bbPlayer.ApplyForcedSkinsToCorpses).
var Carcass Corpse[16];
var int NextCorpse;

// Client: the last frame of a sequence on a model, as a fraction of the
// sequence (FitCorpseAnim).
var IGPlus_AnimProbe Probe;
var Mesh LastMesh[16];
var name LastSeq[16];
var float LastFrac[16];
var int NextLast;

replication {
	reliable if (Role == ROLE_Authority)
		bEnableCarcassCollision;
}

simulated event Actor SpawnNotification(Actor A) {
	if (bEnableCarcassCollision == false) {
		A.SetCollision(false, false, false);
		A.bProjTarget = false;
	}
	// Player corpses only. Their owner is the dead player (bbPlayer.SpawnCarcass).
	if (UTHumanCarcass(A) != none) {
		if (Level.NetMode == NM_Client) {
			Corpse[NextCorpse] = Carcass(A);
			NextCorpse = (NextCorpse + 1) % ArrayCount(Corpse);
		} else {
			A.SetOwner(DeadBotAt(A.Location));
		}
	}
	return A;
}

// The last frame of Seq on model M, as a fraction of the sequence. 0 if the
// model has no such sequence or it has one frame.
simulated function float DrawnAnimLast(Mesh M, name Seq) {
	local int i;
	local float F;

	for (i = 0; i < ArrayCount(LastMesh); i++)
		if (LastMesh[i] == M && LastSeq[i] == Seq)
			return LastFrac[i];
	if (Probe == none)
		Probe = Spawn(class'IGPlus_AnimProbe');
	if (Probe == none)
		return 0;
	Probe.Mesh = M;
	if (Probe.HasAnim(Seq)) {
		Probe.PlayAnim(Seq, 1.0, 0.0);
		F = Probe.AnimLast;
		Probe.AnimRate = 0;
	}
	LastMesh[NextLast] = M;
	LastSeq[NextLast] = Seq;
	LastFrac[NextLast] = F;
	NextLast = (NextLast + 1) % ArrayCount(LastMesh);
	return F;
}

// A corpse drawn with another model than its player's (a forced skin, or the
// real one in a client demo) keeps its place in the death animation. The
// server sends that place as a fraction of the sequence on the player's own
// model, and male and female models have other frame counts for most death
// sequences. Unscaled, a female corpse drawn as Boss stops past Boss's last
// frame and is drawn part way back to standing, floating and folded above the
// floor. Runs every frame: the server's values come back with each update.
simulated function FitCorpseAnim(Carcass C) {
	local float Drawn;

	if (C.AnimLast <= 0)
		return;
	Drawn = DrawnAnimLast(C.Mesh, C.AnimSequence);
	if (Drawn <= 0 || Abs(C.AnimLast - Drawn) < 0.0001)
		return;
	if (C.AnimFrame > 0)
		C.AnimFrame = C.AnimFrame / C.AnimLast * Drawn;
	C.AnimRate = C.AnimRate * Drawn / C.AnimLast;
	C.AnimLast = Drawn;
}

// Server: the nearest dead bot within 64 units.
function Pawn DeadBotAt(vector Loc) {
	local Pawn P, Best;
	local float D, BestD;

	BestD = 64;
	for (P = Level.PawnList; P != none; P = P.NextPawn) {
		if (P.Health > 0 || PlayerPawn(P) != none || P.PlayerReplicationInfo == none)
			continue;
		D = VSize(P.Location - Loc);
		if (D < BestD) {
			BestD = D;
			Best = P;
		}
	}
	return Best;
}

defaultproperties {
	bEnableCarcassCollision=True
	RemoteRole=ROLE_SimulatedProxy
	ActorClass=class'Carcass'
}
