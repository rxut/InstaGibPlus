// ===============================================================
// Stats.ST_UT_SeekingRocket: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_UT_SeekingRocket extends UT_SeekingRocket;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;
// Where the server spawned it before the ping catch-up: other players draw it
// from there (IGPlus_Glide).
var vector IGPlus_SkipStart;

replication {
	reliable if (Role == ROLE_Authority && bNetInitial)
		IGPlus_SkipStart;
}

simulated function PostNetBeginPlay() {
	super.PostNetBeginPlay();
	class'IGPlus_Glide'.static.Begin(self, IGPlus_SkipStart,
		bbPlayer(Instigator) != None && bbPlayer(Instigator).ClientWeaponSettingsData.bRocketUseClientSideAnimations);
}

// Stock UT_SeekingRocket.Timer, with the smoke where the rocket is drawn
// (IGPlus_Glide draws it behind its real spot for a moment).
simulated function Timer()
{
	local ut_SpriteSmokePuff b;
	local vector SeekingDir;
	local float MagnitudeVel;

	if ( InitialDir == vect(0,0,0) )
		InitialDir = Normal(Velocity);

	if ( (Seeking != None) && (Seeking != Instigator) )
	{
		SeekingDir = Normal(Seeking.Location - Location);
		if ( (SeekingDir Dot InitialDir) > 0 )
		{
			MagnitudeVel = VSize(Velocity);
			SeekingDir = Normal(SeekingDir * 0.5 * MagnitudeVel + Velocity);
			Velocity =  MagnitudeVel * SeekingDir;
			Acceleration = 25 * SeekingDir;
			SetRotation(rotator(Velocity));
		}
	}
	if ( bHitWater || (Level.NetMode == NM_DedicatedServer) )
		Return;

	if ( (Level.bHighDetailMode && !Level.bDropDetail) || (FRand() < 0.5) )
	{
		b = Spawn(class'ut_SpriteSmokePuff',,, class'IGPlus_Glide'.static.DrawnSpot(self));
		if (b != None)
			b.RemoteRole = ROLE_None;
	}
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

auto state Flying
{
	simulated function ProcessTouch(Actor Other, Vector HitLocation)
	{
		// A rewound copy (ping fast-forward) gets the crouch cut-off stock Touch gives real players
		if (UTPlusDummy(Other) != None && UTPlusDummy(Other).AdjustHitLocation(HitLocation, Velocity) == false)
			return;
		super.ProcessTouch(Other, HitLocation);
	}

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
