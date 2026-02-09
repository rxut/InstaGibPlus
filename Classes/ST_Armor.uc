class ST_Armor extends Armor2;

function bool HandlePickupQuery(Inventory Item) {
	local inventory S;
	local IGPlus_WeaponImplementation WImp;
	local int MaxCharge;
	local int BeltMax;

	if (Item.Class == Class) {
		foreach AllActors(class'IGPlus_WeaponImplementation', WImp)
			break;
		if (WImp != none) {
			MaxCharge = WImp.WeaponSettings.ArmorCharge;
			BeltMax = WImp.WeaponSettings.ShieldBeltCharge;
		} else {
			MaxCharge = Item.Charge;
			BeltMax = class'UT_ShieldBelt'.default.Charge;
		}

		S = Pawn(Owner).FindInventoryType(class'ST_ShieldBelt');
		if (S == none)
			Charge = MaxCharge;
		else
			Charge = Clamp(BeltMax - S.Charge, Charge, MaxCharge);
		if (Level.Game.LocalLog != none)
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		if (Level.Game.WorldLog != none)
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		if ( PickupMessageClass == none )
			Pawn(Owner).ClientMessage(PickupMessage, 'Pickup');
		else
			Pawn(Owner).ReceiveLocalizedMessage(PickupMessageClass, 0, none, none, self.Class);
		Item.PlaySound(PickupSound,,2.0);
		Item.SetReSpawn();
		return true;
	}

	if (Inventory == none)
		return false;
	return Inventory.HandlePickupQuery(Item);
}

function inventory SpawnCopy(Pawn Other) {
	local Inventory Copy, S;
	local IGPlus_WeaponImplementation WImp;
	local int Armor;
	local int BeltMax;

	Copy = super(TournamentPickup).SpawnCopy(Other);

	foreach AllActors(class'IGPlus_WeaponImplementation', WImp)
		break;
	if (WImp != none) {
		Copy.Charge = WImp.WeaponSettings.ArmorCharge;
		BeltMax = WImp.WeaponSettings.ShieldBeltCharge;
	} else {
		BeltMax = class'UT_ShieldBelt'.default.Charge;
	}

	for (S = Other.Inventory; S != none; S = S.Inventory)
		if (S != Copy && S.bIsAnArmor)
			Armor += S.Charge;

	Copy.Charge = Min(Copy.Charge, BeltMax - Armor);
	if (Copy.Charge <= 0)
		Copy.Destroy();

	return Copy;
}
