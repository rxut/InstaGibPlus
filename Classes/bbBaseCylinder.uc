class bbBaseCylinder extends BaseCylinder;

var Pawn PawnRef;
var PlayerPawn CachedLocalPlayerPawn;
var bool bLocalPlayerPawnCached;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

replication
{
	reliable if (Role == ROLE_Authority)
		PawnRef;
}

simulated final function WeaponSettingsRepl FindWeaponSettings() {
	local WeaponSettingsRepl S;

	foreach AllActors(class'WeaponSettingsRepl', S)
		return S;

	return none;
}

simulated final function WeaponSettingsRepl GetWeaponSettings() {
	if (WSettings != none)
		return WSettings;

	WSettings = FindWeaponSettings();
	return WSettings;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;		// Find master :D
}

simulated function PlayerPawn GetLocalPlayerPawn()
{
	local PlayerPawn P;

	if (bLocalPlayerPawnCached)
		return CachedLocalPlayerPawn;

	foreach AllActors(class'PlayerPawn', P)
	{
		if ( Viewport(P.Player) != none )
		{
			CachedLocalPlayerPawn = P;
			bLocalPlayerPawnCached = true;
			return P;
		}
	}

	bLocalPlayerPawnCached = true;
	CachedLocalPlayerPawn = none;
	return none;
}

simulated event Tick(float DeltaTime) {
	local rotator NewRot;
	local PlayerPawn LocalP;
	local bool bHideThisCylinder;

	Super.Tick(DeltaTime);

	if (PawnRef == none || PawnRef.bHidden || WSettings == none || PawnRef.PlayerReplicationInfo == none || PawnRef.PlayerReplicationInfo.bIsSpectator) {
		bHidden = true;
        return;
	}

	bHideThisCylinder = false;

	if (Role < ROLE_Authority) {
		LocalP = GetLocalPlayerPawn();

		if (LocalP != none && LocalP.Weapon != none) {
			if (LocalP.Weapon.IsA('SniperRifle') && WSettings.SniperUseReducedHitbox)
				bHideThisCylinder = true;
			else if (LocalP.Weapon.IsA('ShockRifle') && WSettings.ShockBeamUseReducedHitbox)
				bHideThisCylinder = true;
			else if (LocalP.Weapon.IsA('Enforcer') && WSettings.EnforcerUseReducedHitbox)
				bHideThisCylinder = true;
		}

		if (bHideThisCylinder) {
			bHidden = true;
		} else {
			bHidden = false;
			if (LocalP != none && LocalP.ViewTarget == PawnRef && !LocalP.bBehindView) {
				bHidden = true;
			}
		}

		if (!bHidden) {
			SetLocation(PawnRef.Location);
			NewRot = rot(0,0,0);
			NewRot.Yaw = PawnRef.Rotation.Yaw;
			SetRotation(NewRot);
		}
	} else {
		bHidden = true;
	}
}

simulated event PostNetBeginPlay() {
	local bool bHideThisCylinder;
	local PlayerPawn LocalP;
	Super.PostNetBeginPlay();

	GetWeaponSettings(); // Get WSettings

	if (PawnRef == none || PawnRef.bHidden || WSettings == none || PawnRef.PlayerReplicationInfo == none || PawnRef.PlayerReplicationInfo.bIsSpectator) {
		bHidden = true;
        return;
	}

	bHideThisCylinder = false;
	LocalP = GetLocalPlayerPawn();
	if (LocalP != none && LocalP.Weapon != none) {
		if (LocalP.Weapon.IsA('SniperRifle') && WSettings.SniperUseReducedHitbox)
			bHideThisCylinder = true;
		else if (LocalP.Weapon.IsA('ShockRifle') && WSettings.ShockBeamUseReducedHitbox)
			bHideThisCylinder = true;
		else if (LocalP.Weapon.IsA('Enforcer') && WSettings.EnforcerUseReducedHitbox)
			bHideThisCylinder = true;
	}
	bHidden = bHideThisCylinder;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
    bOwnerNoSee=True
}