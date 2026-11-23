// Server: a thrown copy goes back to stock once it lands.
class IGPlus_TossWatch extends Info;

var Weapon W;

event Tick(float Delta) {
	if (W == none || W.bDeleteMe || W.Owner != none) {
		Destroy();
		return;
	}
	if (W.Physics == PHYS_Falling)
		return;
	W.RemoteRole = ROLE_DumbProxy;
	Destroy();
}

defaultproperties {
	RemoteRole=ROLE_None
}
