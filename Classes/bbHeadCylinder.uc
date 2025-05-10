class bbHeadCylinder extends HeadCylinder;

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
	local bool bShowThisCylinder;
	local vector BaseOffset, WorldOffset, FinalLocation;
	local vector X, Y, Z;
	local name PawnAnimSequence;

	Super.Tick(DeltaTime);

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
			FinalLocation = PawnRef.Location;

			// Only calculate and apply animation offset if the setting is enabled
			if (WSettings.bEnableAnimationAdaptiveHeadHitbox) {
				PawnAnimSequence = PawnRef.AnimSequence;
				switch (PawnAnimSequence) {
					case 'Breath1L': case 'Breath2L': case 'Breath1': case 'Breath2': BaseOffset = vect(2, 0, 0); break;
					case 'CockGun': case 'CockGunL': BaseOffset = vect(-2.5, 0, 0); break;
					case 'StrafeL': BaseOffset = vect(0, -3.5, 0); break;
					case 'StrafeR': BaseOffset = vect(0, 3.5, 0); break;
					case 'RunLg': case 'RunSm': case 'RunLgFr': case 'RunSmFr': case 'WalkLg': case 'WalkSm': case 'WalkLgFr': case 'WalkSmFr': BaseOffset = vect(3.5, 0, 0); break;
					case 'BackRun': BaseOffset = vect(-2.5, 0, 0); break;
					case 'DodgeL': BaseOffset = vect(0, -3, 0); break;
					case 'DodgeR': BaseOffset = vect(0, 3, 0); break;
					case 'DodgeF': BaseOffset = vect(2.5, 0, 0); break;
					case 'DodgeB': BaseOffset = vect(-4, 0, 0); break;
					case 'AimDnLg': BaseOffset = vect(6, 0, 0); break;
					case 'AimDnSm': BaseOffset = vect(6, 0, 0); break;
					case 'AimUpLg': BaseOffset = vect(-6, 0, 0); break;
					case 'AimUpSm': BaseOffset = vect(-6, 0, 0); break;
					default: BaseOffset = vect(0,0,0); break;
				}
				if (Abs(BaseOffset.X) > 0.1 || Abs(BaseOffset.Y) > 0.1 || Abs(BaseOffset.Z) > 0.1) {
					GetAxes(PawnRef.Rotation, X, Y, Z);
					WorldOffset = BaseOffset.X * X + BaseOffset.Y * Y + BaseOffset.Z * Z;
					FinalLocation += WorldOffset; // Add the calculated world offset
				}
			}
			SetLocation(FinalLocation);
			
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
	RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
    bOwnerNoSee=True
    Texture=Texture'HeadCylinder.Colors.White'
}