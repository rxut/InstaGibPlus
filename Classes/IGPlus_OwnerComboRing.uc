// The server's ring for a combo whose owner's client may already have drawn
// it, on the beam's frame (ST_ShockProj.IGPlus_PredictCombo). The owner's
// client drops it if so. If not, it shows it and plays the sound the server
// played for everyone else.
class IGPlus_OwnerComboRing extends UT_ComboRing;

simulated function PostBeginPlay() {
	// A client learns the owner only once the initial properties are in.
	if (Level.NetMode != NM_Client)
		Super.PostBeginPlay();
}

simulated function PostNetBeginPlay() {
	local bbPlayer P;

	P = bbPlayer(Owner);
	if (P != None && Viewport(P.Player) != None) {
		if (P.IGPlus_PredComboTS > 0.0
			&& Level.TimeSeconds - P.IGPlus_PredComboTS < P.PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation + 0.5
			&& VSize(Location - P.IGPlus_PredComboLoc) < 64.0
		) {
			P.IGPlus_PredComboTS = 0.0;
			Destroy();
			return;
		}
		PlaySound(class'ShockProj'.default.ExploSound,,20.0,,2000,0.6);
	}
	Super.PostBeginPlay();
}

defaultproperties {
}
