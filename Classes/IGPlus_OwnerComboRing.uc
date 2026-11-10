// The server's ring for a combo whose owner's client may already have drawn
// it, on the beam's frame (ST_ShockProj.IGPlus_PredictCombo). The owner's
// client drops it if so. If not, it shows it and plays the sound the server
// played for everyone else.
class IGPlus_OwnerComboRing extends UT_ComboRing;

// The owner's screen has the ball this far off the server's (fired from a
// moving lift): the owner sees the ring there.
var vector IGPlus_OwnerShift;

// The owner's client drew a combo and this ring is the server's for it: it
// got here within a round trip and a quarter second (the weapon can't fire
// again inside half a second, so it isn't the next beam's), anywhere near.
// One combo is one ring and one sound, where the client drew it, even when
// the two machines had the ball some way apart.
const IGPLUS_SAME_COMBO_DIST = 400.0;

simulated function float IGPlus_SameComboTime(bbPlayer P) {
	if (P.PlayerReplicationInfo == None)
		return 0.25;
	return P.PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation + 0.25;
}

replication {
	unreliable if (Role == ROLE_Authority)
		IGPlus_OwnerShift;
}

simulated function PostBeginPlay() {
	// A client learns the owner only once the initial properties are in.
	if (Level.NetMode != NM_Client)
		Super.PostBeginPlay();
}

simulated function PostNetBeginPlay() {
	local bbPlayer P;
	local UT_ComboRing R;

	if (Level.NetMode != NM_Client)
		return; // PostBeginPlay did it
	P = bbPlayer(Owner);
	if (P != None && P.Role == ROLE_AutonomousProxy && P.IGPlus_InDemoPlayback()) {
		// The owner's own demo (udemo gives the recorded owner a stand-in
		// viewport, so test this first). Only the player who recorded the
		// demo plays back as AutonomousProxy: other players' rings, and all
		// rings in a server demo, are drawn as recorded. The client's own ring,
		// if it drew one, is in the demo: drop this one like the client did.
		// Else the sound below was played before the demo had this ring, so
		// play it.
		if (IGPlus_OwnerShift != vect(0,0,0))
			SetLocation(Location + IGPlus_OwnerShift);
		foreach RadiusActors(class'UT_ComboRing', R, IGPLUS_SAME_COMBO_DIST)
			if (R != self && IGPlus_OwnerComboRing(R) == None
				&& R.default.LifeSpan - R.LifeSpan < IGPlus_SameComboTime(P)
			) {
				Destroy();
				return;
			}
		PlaySound(class'ShockProj'.default.ExploSound,,20.0,,2000,0.6);
	} else if (P != None && Viewport(P.Player) != None) {
		if (IGPlus_OwnerShift != vect(0,0,0))
			SetLocation(Location + IGPlus_OwnerShift);
		if (P.IGPlus_PredComboTS > 0.0
			&& Level.TimeSeconds - P.IGPlus_PredComboTS < IGPlus_SameComboTime(P)
			&& VSize(Location - P.IGPlus_PredComboLoc) < IGPLUS_SAME_COMBO_DIST
		) {
			P.IGPlus_PredComboTS = 0.0;
			P.ClientDebugMessage("Shock combo: server agreed ("$int(VSize(Location - P.IGPlus_PredComboLoc))$"uu apart)");
			Destroy();
			return;
		}
		P.ClientDebugMessage("Shock combo: server made one this client didn't draw, shown late");
		PlaySound(class'ShockProj'.default.ExploSound,,20.0,,2000,0.6);
	}
	Super.PostBeginPlay();
}

defaultproperties {
}
