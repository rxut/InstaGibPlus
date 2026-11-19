class NextSA extends ST_Mutator;
// Description="SniperArena with the deterministic SniperRifle"

// Sniper Arena on the IG+ weapons: everyone gets SA_SniperRifle, which is
// ST_SniperRifle with two rules of its own. It fires on the server with ping
// compensation (and Precise Rewind Time, if on) and follows the sniper
// settings (reduced hitbox, reload time, damage).
//
// The rules are NewNetSA's (an Arena with no weapon string):
// - The rifle comes with full ammo and uses one bullet a shot. No other
//   mutator can take the rifle or a bullet box away (AlwaysKeep).
// - Every weapon in the map is removed, rifles too.
// - All other ammo becomes a bullet box, and a bullet box holds full ammo.
// - No translocator, whatever the game setting says.
// - Armor, health and other pickups stay as the map made them.
//
// Load this in place of ST_Mutator, not together with it: each brings its own
// weapon settings.

function InitializeWeapons() {
	WImp = Spawn(class'IGPlus_WeaponImplementationBase');
	WImp.InitWeaponSettings("WeaponSettingsSniperArena", 2);
}

// As Arena.AlwaysKeep.
function bool AlwaysKeep(Actor Other) {
	if (Other.IsA('ST_SniperRifle')) {
		Weapon(Other).PickupAmmoCount = Weapon(Other).AmmoName.Default.MaxAmmo;
		return true;
	}
	if (Other.IsA('BulletBox')) {
		Ammo(Other).AmmoAmount = Ammo(Other).MaxAmmo;
		return true;
	}
	return Super.AlwaysKeep(Other);
}

// No weapon is swapped: the only one left is the rifle we hand out.
function bool CheckReplaceWeapon(Actor A) {
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
	// The rifle and bullet boxes never get here (AlwaysKeep).
	if (Other.IsA('Weapon'))
		return false;
	if (Other.IsA('Ammo')) {
		// The stock swap: ST_Mutator's keeps the old item's look.
		Super(Mutator).ReplaceWith(Other, "Botpack.BulletBox");
		return false;
	}

	// Armor, belts, health and the rest stay as the map made them, as in
	// NewNetSA. ST_Mutator's swap would break map scripts that spawn and hand
	// out armor (Spawn returns None) and drop a map's per-box HealingAmount.
	return true;
}

defaultproperties {
	DefaultWeapon=Class'SA_SniperRifle'
}
