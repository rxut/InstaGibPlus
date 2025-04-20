class ST_PlasmaSphere extends PlasmaSphere;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;

simulated function PostBeginPlay()
{
	if (ROLE == ROLE_Authority)
	{
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
	}

	Super.PostBeginPlay();
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

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
    local ST_PulseGun PG;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().PulseCompensatePing) {
		if (bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bPulseUseClientSideAnimations == false){
			return;
		}

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			PG = ST_PulseGun(InstigatingPlayer.Weapon);
			if (PG != none && PG.LocalPlasmaSphereDummy != none && PG.LocalPlasmaSphereDummy.bDeleteMe == false)
				PG.LocalPlasmaSphereDummy.Destroy();
		}
	} else {
		Disable('Tick');
	}
}
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bClientVisualOnly)
	{
		bHidden = true;
		Destroy();
		return;
	}

	if ( !bExplosionEffect )
	{
		if ( Role == ROLE_Authority )
			BlowUp(HitLocation);
		bExplosionEffect = true;
		if ( !Level.bHighDetailMode || bHitPawn || Level.bDropDetail )
		{
			if ( bExploded )
			{
				Destroy();
				return;
			}
			else
				DrawScale = 0.2;
		}
		else
			DrawScale = 0.2;

	    LightType = LT_Steady;
		LightRadius = 5;
		SetCollision(false,false,false);
		LifeSpan = 0.5;
		Texture = ExpType;
		DrawType = DT_SpriteAnimOnce;
		Style = STY_Translucent;
		if ( Region.Zone.bMoveProjectiles && (Region.Zone.ZoneVelocity != vect(0,0,0)) )
		{
			bBounce = true;
			Velocity = Region.Zone.ZoneVelocity;
		}
		else
			SetPhysics(PHYS_None);
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if (Other == Instigator)
        return;

	if (bClientVisualOnly)
		bHidden = true;
	
	If (PlasmaSphere(Other) == None)
	{
		if (Other.bIsPawn || Other.IsA('UTPlusDummy'))
		{
			bHitPawn = true;
			bExploded = !Level.bHighDetailMode || Level.bDropDetail;
		}
		
		if (Role == ROLE_Authority)
		{
			Other.TakeDamage(
				WImp.WeaponSettings.PulseSphereDamage,
				instigator,
				HitLocation,
				WImp.WeaponSettings.PulseSphereMomentum * MomentumTransfer * Vector(Rotation),
				MyDamageType);
		}
		Explode(HitLocation, vect(0,0,1));
	}
}


defaultproperties {
}
