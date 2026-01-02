class ST_RocketMk2 extends RocketMk2;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;
var PlayerPawn InstigatingPlayer;
var vector ExtrapolationDelta;

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
	local ST_UT_Eightball EB;

	super.PostNetBeginPlay();

	if (Instigator != None && bbPlayer(Instigator) != None && bbPlayer(Instigator).ClientWeaponSettingsData.bRocketUseClientSideAnimations)
	{
		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			EB = ST_UT_Eightball(InstigatingPlayer.Weapon);
			if (EB != None)
			{
				EB.CleanupClientSideRocket();
			}
		}
	}
}

simulated event Tick(float Delta) {
    local vector NewXPolDelta;
    super.Tick(Delta);

    if (InstigatingPlayer == none)
        return;

    if (bbPlayer(InstigatingPlayer) != none && bbPlayer(InstigatingPlayer).zzbDemoPlayback)
        return;

    // Extrapolate locally to compensate for ping (if this is the SERVER projectile on client)
	if (Physics != PHYS_None) {
		NewXPolDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
		Move(NewXPolDelta - ExtrapolationDelta);
		ExtrapolationDelta = NewXPolDelta;
	}
}

auto state Flying
{
	function ProcessTouch(Actor Other, Vector HitLocation)
	{
		if ( (Other != instigator) && !Other.IsA('Projectile') ) 
		{
			if (bClientVisualOnly)
			{
				// Just disappear on client, don't explode (server handles effects)
				Destroy();
				return;
			}
			
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (bClientVisualOnly)
		{
			// Just disappear on client, don't explode
			Destroy();
			return;
		}

		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');

		MakeNoise(1.0);
		Explode(Location + ExploWallOut * HitNormal, HitNormal);

		class'WeaponEffect'.static.Send(
			Level,
			class'ST_RocketBlastDecal',
			Instigator.PlayerReplicationInfo,
			vect(0,0,0),
			vect(0,0,0),
			none,
			Location,
			vect(0,0,0),
			HitNormal
		);
	}

	function Explode(vector HitLocation, vector HitNormal)
	{
		if (bClientVisualOnly)
		{
			Destroy();
			return;
		}

		Spawn(class'UT_SpriteBallExplosion',,,HitLocation + HitNormal*16);	

		BlowUp(HitLocation);

 		Destroy();
	}

	function BlowUp(vector HitLocation)
	{
		if (WImp.WeaponSettings.bEnableEnhancedSplashRockets) {
			WImp.EnhancedHurtRadius(
				self,
				WImp.WeaponSettings.RocketDamage,
				WImp.WeaponSettings.RocketHurtRadius,
				MyDamageType,
				WImp.WeaponSettings.RocketMomentum * MomentumTransfer,
				HitLocation);
		} else {
			HurtRadius(
				WImp.WeaponSettings.RocketDamage,
				WImp.WeaponSettings.RocketHurtRadius,
				MyDamageType,
				WImp.WeaponSettings.RocketMomentum * MomentumTransfer,
				HitLocation);
		}

		MakeNoise(1.0);
	}
}

defaultproperties {
	bNetTemporary=False
}
