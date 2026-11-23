class IGPlus_CarcassSpawnNotify extends SpawnNotify;

var bool bEnableCarcassCollision;

// Client: recent corpses (bbPlayer.ApplyForcedSkinsToCorpses).
var Carcass Corpse[16];
var int NextCorpse;

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
