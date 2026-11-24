class bbBaseCylinder extends Actor;

var Pawn PawnRef;
var PlayerPawn CachedLocalPlayerPawn;
var bool bLocalPlayerPawnCached;
var bool bRegistered;   // with the local player, to be placed after the players are drawn

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
	// On a client it is placed again where the model is drawn (bbPlayer.IGPlus_LocationOffsetFix_AfterAll).
	if (bRegistered == false && Role < ROLE_Authority && bbPlayer(GetLocalPlayerPawn()) != none) {
		bbPlayer(GetLocalPlayerPawn()).IGPlus_AddDebugHitbox(self);
		bRegistered = true;
	}

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
			// The full hitbox is the collision cylinder.
			class'IGPlus_HitboxCylinderMesh'.static.Place(self, PawnRef.Location, PawnRef.CollisionRadius, PawnRef.CollisionHeight);
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
	DrawType=DT_Mesh
	Mesh=Mesh'IGPlus_HitboxCylinder'
	AnimSequence=All
	Texture=Texture'CylinderRed'
	DrawScale=1.0
	bUnlit=True
	RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
    bOwnerNoSee=True
}