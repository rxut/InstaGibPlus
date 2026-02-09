class ST_MedBox extends MedBox;

function PreBeginPlay() {
	local IGPlus_WeaponImplementation WImp;

	Super.PreBeginPlay();

	foreach AllActors(class'IGPlus_WeaponImplementation', WImp)
		break;
	if (WImp != none)
		HealingAmount = WImp.WeaponSettings.HealthPackHealingAmount;
}