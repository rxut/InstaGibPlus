// ===============================================================
// Stats.ST_UT_SeekingRocket: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_UT_SeekingRocket extends UT_SeekingRocket;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

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

auto state Flying
{
	function BeginState()
	{
		local vector Dir;
		local WeaponSettingsRepl WS;

		WS = GetWeaponSettings();
		if (WS != none)
			Speed = WS.RocketSpeed;

		Dir = vector(Rotation);
		Velocity = Speed * Dir;
		Acceleration = Dir * 50;
		PlayAnim('Wing', 0.2);
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity = 0.6 * Velocity;
		}
	}
	function HitWall (vector HitNormal, actor Wall)
	{
		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');

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
		Spawn(class'UT_SpriteBallExplosion',,,HitLocation + HitNormal*16);	

		BlowUp(HitLocation);

 		Destroy();
	}

	function BlowUp(vector HitLocation)
	{
		WImp.SplashDamageWithSelfDamage(
			self,
			WImp.WeaponSettings.RocketDamage,
			WImp.WeaponSettings.RocketSelfDamage,
			WImp.WeaponSettings.RocketHurtRadius,
			MyDamageType,
			WImp.WeaponSettings.RocketMomentum * MomentumTransfer,
			WImp.WeaponSettings.RocketMomentum * MomentumTransfer,
			HitLocation,
			WImp.WeaponSettings.bEnableEnhancedSplashRockets
		);

		MakeNoise(1.0);
	}
}

defaultproperties {
	bNetTemporary=False
}
