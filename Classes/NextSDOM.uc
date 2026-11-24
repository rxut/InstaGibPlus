class NextSDOM extends ST_Mutator;
// Description="ShockArena with the deterministic sDOM Shock Rifle"

// sDOM on the IG+ weapons: everyone gets SDOM_ShockRifle, which fires on the
// server with ping compensation (and Precise Rewind Time, if on).
//
// The rules are NewNetShockDOM's (an Arena with the sDOM rifle):
// - Everyone spawns with the rifle and 50 sDOM cores. No other mutator can
//   take the rifle, a core or the two armor pieces below away (AlwaysKeep).
//   A rifle pickup and a core always hold 50.
// - Every weapon in the map becomes a rifle pickup, one to a spot.
// - All ammo becomes a sDOM core.
// - No translocator: the game spawns it at the origin, where nothing replaces it.
// - Body armor becomes NN_Armor2 and thigh pads NN_ThighPads (150 armor at most).
// - Health vial 7, med box 100, health pack 199. The damage amplifier lasts
//   1500 seconds.
// - Belts, invisibility and the other pickups stay as the map made them.
//
// NewNetShockDOM spawned a second rifle where a shock rifle stood and a second
// core where stock ammo lay. This does not.
//
// Load this in place of ST_Mutator, not together with it: each brings its own
// weapon settings.

function InitializeWeapons() {
	WImp = Spawn(class'IGPlus_WeaponImplementationBase');
	WImp.InitWeaponSettings("WeaponSettingsShockDOM");
}

// As Arena.AlwaysKeep.
function bool AlwaysKeep(Actor Other) {
	if (Other.IsA('SDOM_ShockRifle')) {
		Weapon(Other).PickupAmmoCount = Weapon(Other).AmmoName.Default.MaxAmmo;
		return true;
	}
	if (Other.IsA('ST_ShockCoreSDOM')) {
		Ammo(Other).AmmoAmount = Ammo(Other).MaxAmmo;
		return true;
	}
	if (Other.IsA('NN_Armor2') || Other.IsA('NN_ThighPads'))
		return true;
	return Super.AlwaysKeep(Other);
}

// No weapon is swapped here: CheckReplacement turns them all into the rifle.
function bool CheckReplaceWeapon(Actor A) {
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
	// The rifle, the cores and the two armor pieces never get here (AlwaysKeep).
	// The stock swaps, as Arena and NewNetShockDOM made them.
	if (Other.IsA('Weapon')) {
		Level.Game.bCoopWeaponMode = false;
		Super(Mutator).ReplaceWith(Other, PreFix$".SDOM_ShockRifle");
		return false;
	}
	if (Other.IsA('Ammo')) {
		Super(Mutator).ReplaceWith(Other, PreFix$".ST_ShockCoreSDOM");
		return false;
	}
	if (Other.IsA('Armor2') || Other.IsA('Armor')) {
		Super(Mutator).ReplaceWith(Other, PreFix$".NN_Armor2");
		return false;
	}
	if (Other.IsA('ThighPads') || Other.IsA('KevlarSuit')) {
		Super(Mutator).ReplaceWith(Other, PreFix$".NN_ThighPads");
		return false;
	}

	if (Other.Class == class'HealthVial') return DoReplacePickup(Pickup(Other), class'ST_HealthVialSDOM') == false;
	if (Other.Class == class'MedBox')     return DoReplacePickup(Pickup(Other), class'ST_MedBoxSDOM') == false;
	if (Other.Class == class'HealthPack') return DoReplacePickup(Pickup(Other), class'ST_HealthPackSDOM') == false;
	if (Other.Class == class'UDamage')    return DoReplacePickup(Pickup(Other), class'ST_UDamageSDOM') == false;

	return true;
}

// NewNetShockDOM's pickup swap: the new one respawns after its own class's
// time. It also takes over the bots' marker, which NewNetShockDOM left behind.
function bool DoReplacePickup(Pickup Other, class<Pickup> ReplacementClass) {
	local Pickup P;

	P = Other.Spawn(ReplacementClass, Other.Owner, Other.Tag);
	if (P == none)
		return false;
	if (Other.MyMarker != none) {
		P.MyMarker = Other.MyMarker;
		P.MyMarker.markedItem = P;
		Other.MyMarker = none;
	}
	return true;
}

defaultproperties {
	DefaultWeapon=Class'SDOM_ShockRifle'
}
