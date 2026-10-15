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
// Server, Push-Safe Aim from a moving lift: the rocket left from where the
// shooter's screen had them. That screen has the lift a round trip of travel
// behind, so near it the rocket meets the lift there instead.
var Mover IGPlus_OwnLift;
var ST_MoverDummy IGPlus_OwnLiftMD;
var float IGPlus_OwnLiftLagMs;  // how far behind, after the fast-forward
var float IGPlus_OwnLiftUntil;

replication
{
	reliable if (Role == ROLE_Authority && bNetInitial)
		RocketIndex;
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

	// The server moves a lift rocket itself for a while (IGPlus_OwnLiftHold).
	if (Role < ROLE_Authority && Physics == PHYS_None)
		SetPhysics(PHYS_Projectile);
	if (Role < ROLE_Authority && bCollideActors == false)
		SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);

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

	if (IGPlus_OwnLift != None) {
		IGPlus_OwnLiftStep(Delta);
		return;
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

		IGPlus_OwnLiftHit(Wall);
		if (bDeleteMe)
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

		if (IGPlus_OwnLift != None)
			IGPlus_OwnLiftRestore();

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

// Server: P fired this from a moving lift with Push-Safe Aim.
function IGPlus_OwnLiftStart(bbPlayer P) {
	IGPlus_OwnLift = Mover(P.Base);
	if (IGPlus_OwnLift == None || P.zzUTPure == None)
		return;
	IGPlus_OwnLiftMD = P.zzUTPure.FindMoverDummy(IGPlus_OwnLift);
	IGPlus_OwnLiftLagMs = P.IGPlus_OwnLiftLagMs();
	// ponytail: 0.5s covers clearing the lift; past that the live lift counts
	IGPlus_OwnLiftUntil = Level.TimeSeconds + 0.5;
}

// Server: put our lift where the shooter's screen has it while this rocket is
// AheadMs further along than its lag allows for (the fast-forward).
function IGPlus_OwnLiftRewind(float AheadMs) {
	if (IGPlus_OwnLift != None && IGPlus_OwnLiftMD != None && IGPlus_OwnLiftLagMs - AheadMs >= 1.0)
		IGPlus_OwnLiftMD.CompStart(int(IGPlus_OwnLiftLagMs - AheadMs));
}

function IGPlus_OwnLiftRestore() {
	if (IGPlus_OwnLiftMD != None)
		IGPlus_OwnLiftMD.CompEnd();
}

// Server: one tick of flight against our lift where the shooter's screen has
// it. Between these the rocket holds still for the engine (IGPlus_OwnLiftHold).
function IGPlus_OwnLiftStep(float Delta) {
	SetPhysics(PHYS_Projectile);
	SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);
	if (Level.TimeSeconds > IGPlus_OwnLiftUntil || IGPlus_OwnLiftLagMs < 1.0
		|| IGPlus_OwnLift.bDeleteMe || IGPlus_OwnLiftMD == None
	) {
		IGPlus_OwnLift = None;
		return;
	}
	IGPlus_OwnLiftRewind(0.0);
	AutonomousPhysics(Delta);
	IGPlus_OwnLiftRestore();
	if (bDeleteMe == false)
		IGPlus_OwnLiftHold();
}

// Server: no engine physics, and no collision, so the real lift (ahead of the
// one this rocket meets) never runs into it: a lift returns when it does.
// Clients undo both (PostNetBeginPlay).
function IGPlus_OwnLiftHold() {
	if (IGPlus_OwnLift == None)
		return;
	SetPhysics(PHYS_None);
	SetCollision(false, false, false);
}

// Server: a hit on our lift where the shooter's screen has it lands on the
// same spot of the real lift, so a rocket jump off it pushes as it did there.
function IGPlus_OwnLiftHit(Actor Wall) {
	local vector Shift;

	if (Wall == None || Wall != IGPlus_OwnLift || IGPlus_OwnLiftMD == None || IGPlus_OwnLiftMD.bCompActive == false)
		return;
	Shift = IGPlus_OwnLiftMD.SavedMoverLoc - IGPlus_OwnLift.Location;
	IGPlus_OwnLiftRestore();
	IGPlus_SpawnLoc += Shift; // same travel for the self-knockback timing
	SetLocation(Location + Shift);
}

defaultproperties {
	bNetTemporary=False
}
