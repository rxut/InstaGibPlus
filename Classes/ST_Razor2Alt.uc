class ST_Razor2Alt extends Razor2Alt;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;
var vector ExtrapolationDelta;

simulated function PostBeginPlay()
{
	if (ROLE == ROLE_Authority)
	{
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;		// Find master :D
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
	local ST_Razor2Alt RazAlt;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().RipperCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bRipperUseClientSideAnimations == true)
	{
		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			// Find the oldest client-side dummy and destroy it
			foreach AllActors(class'ST_Razor2Alt', RazAlt)
			{
				if (RazAlt.bClientVisualOnly && RazAlt.Owner == InstigatingPlayer && !RazAlt.bDeleteMe)
				{
					RazAlt.Destroy();
					break;
				}
			}
		}
	} else {
		Disable('Tick');
	}
}

simulated event Tick(float Delta) {
	local vector NewXPolDelta;
	super.Tick(Delta);

	if (InstigatingPlayer == none)
		return;

	if (bbPlayer(InstigatingPlayer) != none && bbPlayer(InstigatingPlayer).zzbDemoPlayback)
		return;

	// Extrapolate locally to compensate for ping
	if (Physics != PHYS_None) {
		NewXPolDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
		Move(NewXPolDelta - ExtrapolationDelta);
		ExtrapolationDelta = NewXPolDelta;
	}
}

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (Other != Instigator && bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		if ( Other != Instigator ) 
		{
			Other.TakeDamage(
				WImp.WeaponSettings.RipperSecondaryDamage,
				instigator,
				HitLocation,
				WImp.WeaponSettings.RipperSecondaryMomentum * MomentumTransfer * Normal(Velocity),
				MyDamageType
			);
			Spawn(class'RipperPulse',,,HitLocation);
			MakeNoise(1.0);
 			Destroy();
		}
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		if (bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		Spawn(class'RipperPulse',,,HitLocation + HitNormal*16);

		BlowUp(HitLocation);

 		Destroy();
	}

	function BlowUp(vector HitLocation)
	{
		local actor Victims;
		local float damageScale, dist;
		local vector dir;

		if (bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		if (WImp.WeaponSettings.bEnableEnhancedSplashRipperSecondary) {
			WImp.EnhancedHurtRadius(
				self,
				WImp.WeaponSettings.RipperSecondaryDamage,
				WImp.WeaponSettings.RipperSecondaryHurtRadius,
				MyDamageType,
				WImp.WeaponSettings.RipperSecondaryMomentum * MomentumTransfer,
				HitLocation,
				True); // special case for Razor2Alt
		} else {
			if( bHurtEntry )
				return;

			bHurtEntry = true;
			foreach VisibleCollidingActors( class 'Actor', Victims, WImp.WeaponSettings.RipperSecondaryHurtRadius, HitLocation )
			{
				if( Victims != self )
				{
					dir = Victims.Location - HitLocation;
					dist = FMax(1,VSize(dir));
					dir = dir/dist;
					dir.Z = FMin(0.45, dir.Z); 
					damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/WImp.WeaponSettings.RipperSecondaryHurtRadius);
					Victims.TakeDamage (
						damageScale * WImp.WeaponSettings.RipperSecondaryDamage,
						Instigator, 
						Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
						WImp.WeaponSettings.RipperSecondaryMomentum * damageScale * MomentumTransfer * dir,
						MyDamageType
					);
				} 
			}
			bHurtEntry = false;
		}
		MakeNoise(1.0);
	}
}


defaultproperties {
	bNetTemporary=False
}
