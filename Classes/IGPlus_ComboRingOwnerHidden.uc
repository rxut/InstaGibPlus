// The combo ring everyone but its owner sees: the owner's client drew it
// already, where and when its beam hit (ST_ShockProj.IGPlus_PredictCombo).
class IGPlus_ComboRingOwnerHidden extends UT_ComboRing;

simulated function PostBeginPlay() {
	// A client learns the owner only once the initial properties are in.
	if (Level.NetMode != NM_Client)
		Super.PostBeginPlay();
}

simulated function PostNetBeginPlay() {
	local PlayerPawn P;

	P = PlayerPawn(Owner);
	if (P != None && Viewport(P.Player) != None) {
		Destroy();
		return;
	}
	Super.PostBeginPlay();
}

defaultproperties {
}
