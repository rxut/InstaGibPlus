class ST_RocketMk2 extends RocketMk2;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;
var PlayerPawn InstigatingPlayer;
var vector ExtrapolationDelta;
var int RocketIndex;
// Server, predicted self-knockback: the shooter's fire step and launch.
var float IGPlus_FireTS;
var vector IGPlus_SpawnLoc;
var float IGPlus_Speed;
// Push-Safe Aim from a moving lift (IGPlus_LiftShot): server, the flight
// near the lift; clients, its speed, as it was sent held still.
var IGPlus_LiftShot IGPlus_Lift;
var vector IGPlus_HeldVelocity;
var bool IGPlus_bTookOver;      // client: carries on from our own copy

replication
{
	reliable if (Role == ROLE_Authority && bNetInitial)
		RocketIndex, IGPlus_HeldVelocity;
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
	local ST_RocketMk2 FakeRocket;
	local vector FakeLocation;

	super.PostNetBeginPlay();

	if (Instigator != None && bbPlayer(Instigator) != None && bbPlayer(Instigator).ClientWeaponSettingsData.bRocketUseClientSideAnimations)
	{
		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			foreach AllActors(class'ST_RocketMk2', FakeRocket)
			{
				if (FakeRocket != self && FakeRocket.bClientVisualOnly && FakeRocket.RocketIndex == RocketIndex && FakeRocket.Instigator == InstigatingPlayer)
				{
					FakeLocation = FakeRocket.Location;
					FakeRocket.Destroy();
					SetLocation(FakeLocation);
					IGPlus_bTookOver = true;
					ExtrapolationDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
					break;
				}
			}
		}
	}
}

simulated event Tick(float Delta) {
    local vector NewXPolDelta;
    super.Tick(Delta);

	// Sent held still from a moving lift (IGPlus_LiftShot): its speed came
	// with it. Here, after the net code has set what it received: fly it.
	if (IGPlus_HeldVelocity != vect(0,0,0) && Role < ROLE_Authority) {
		if (Velocity == vect(0,0,0)) {
			Velocity = IGPlus_HeldVelocity;
			Acceleration = Normal(Velocity) * 50; // Flying.BeginState
			if (IGPlus_bTookOver && InstigatingPlayer != None)
				ExtrapolationDelta = Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping);
		}
		IGPlus_HeldVelocity = vect(0,0,0);
		if (bCollideActors == false)
			SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);
	}

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
		PlayAnim( 'Wing', 0.2 );
		if (Region.Zone.bWaterZone)
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
	}

	function ProcessTouch(Actor Other, Vector HitLocation)
	{
		// A rewound ball's stand-in (ping compensation): the ball it stands for.
		if (ST_ProjectileDummy(Other) != None && ST_ProjectileDummy(Other).Actual != None)
			Other = ST_ProjectileDummy(Other).Actual;
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

		if (IGPlus_Lift != None && IGPlus_Lift.PassHitWall(Wall))
			return;

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
		local bbPlayer bbP;

		bbP = bbPlayer(Instigator);
		if (IGPlus_FireTS > 0.0 && bbP != none && bbP.IGPlus_PredictedSelfKnockback)
			bbP.IGPlus_SKBeginCapture();
		else
			bbP = none;

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

		// Rocket age is its travel over launch speed, same as the client's guess.
		if (bbP != none)
			bbP.IGPlus_SKEndCapture(
				IGPlus_FireTS + VSize(Location - IGPlus_SpawnLoc) / FMax(IGPlus_Speed, 1.0),
				RocketIndex,
				HitLocation,
				Location,
				CollisionRadius,
				WImp.WeaponSettings.RocketHurtRadius,
				WImp.WeaponSettings.RocketMomentum * MomentumTransfer,
				WImp.WeaponSettings.bEnableEnhancedSplashRockets
			);

		MakeNoise(1.0);
	}
}

defaultproperties {
	bNetTemporary=False
}
