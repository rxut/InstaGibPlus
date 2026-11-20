class WeaponSettingsNext extends WeaponSettings perobjectconfig;

// The weapon settings of NextIG and NextSA. Same settings and the same ini
// section (the object's name), with other starting values: their players come
// from the NewNet weapons and have never played without ping compensation, so
// a new server starts with all of it on. A value saved in the ini wins.

defaultproperties {
	bEnableFireTimeOrder=True
	PingCompensationMax=250
}
