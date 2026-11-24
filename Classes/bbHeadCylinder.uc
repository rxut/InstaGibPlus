class bbHeadCylinder extends Actor;

var Pawn PawnRef;
var PlayerPawn CachedLocalPlayerPawn;
var bool bLocalPlayerPawnCached;
var bool bRegistered;   // with the local player, to be placed after the players are drawn

var IGPlus_WeaponImplementationBase WImpBase;   // found on the client too
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

simulated function IGPlus_WeaponImplementationBase FindWImpBase() {
	if (WImpBase == none)
		foreach AllActors(class'IGPlus_WeaponImplementationBase', WImpBase)
			break;
	return WImpBase;
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
	local bool bShowThisCylinder;
	local vector BodyCenter, HeadCenter;
	local float BodyHH, HeadHH;

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

	bShowThisCylinder = false;

	if (Role < ROLE_Authority) {
		LocalP = GetLocalPlayerPawn();

		if (LocalP != none && LocalP.Weapon != none) {
			if (LocalP.Weapon.IsA('SniperRifle') && WSettings.SniperUseReducedHitbox)
				bShowThisCylinder = true;
			else if (LocalP.Weapon.IsA('ShockRifle') && WSettings.ShockBeamUseReducedHitbox)
				bShowThisCylinder = true;
			else if (LocalP.Weapon.IsA('Enforcer') && WSettings.EnforcerUseReducedHitbox)
				bShowThisCylinder = true;
		}

		if (!bShowThisCylinder) {
			bHidden = true;
		} else {
			bHidden = false;
			if (LocalP != none && LocalP.ViewTarget == PawnRef && !LocalP.bBehindView) {
				bHidden = true;
			}
		}

		if (!bHidden) {
			// Where and how big the hit checks make the head: HeadRadius,
			// HeadHalfHeight, the adaptive head and crouching.
			if (FindWImpBase() == none) {
				bHidden = true;
				return;
			}
			WImpBase.ReducedHitboxCylinders(PawnRef, BodyCenter, BodyHH, HeadCenter, HeadHH);
			if (HeadHH <= 0.0) {
				bHidden = true;
				return;
			}
			class'IGPlus_HitboxCylinderMesh'.static.Place(self, HeadCenter, WSettings.HeadRadius, HeadHH);
			
			NewRot = rot(0,0,0);
			NewRot.Yaw = PawnRef.Rotation.Yaw;
			SetRotation(NewRot);
		}
	} else {
		bHidden = true;
	}
}

simulated event PostNetBeginPlay() {
	local bool bShowThisCylinder;
	local PlayerPawn LocalP;
	Super.PostNetBeginPlay();

	GetWeaponSettings(); // Get WSettings

	if (PawnRef == none || PawnRef.bHidden || WSettings == none || PawnRef.PlayerReplicationInfo == none || PawnRef.PlayerReplicationInfo.bIsSpectator) {
		bHidden = true;
        return;
	}

	bShowThisCylinder = false;
	LocalP = GetLocalPlayerPawn();
	if (LocalP != none && LocalP.Weapon != none) {
		if (LocalP.Weapon.IsA('SniperRifle') && WSettings.SniperUseReducedHitbox)
			bShowThisCylinder = true;
		else if (LocalP.Weapon.IsA('ShockRifle') && WSettings.ShockBeamUseReducedHitbox)
			bShowThisCylinder = true;
		else if (LocalP.Weapon.IsA('Enforcer') && WSettings.EnforcerUseReducedHitbox)
			bShowThisCylinder = true;
	}
	bHidden = !bShowThisCylinder;
}

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=Mesh'IGPlus_HitboxCylinder'
	AnimSequence=All
	Texture=Texture'CylinderWhite'
	DrawScale=1.0
	bUnlit=True
	RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
    bOwnerNoSee=True
}