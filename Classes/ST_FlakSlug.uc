class ST_FlakSlug extends flakslug;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;

var vector ExtrapolationDelta;
// Server, predicted self-knockback: the shooter's fire step and launch.
var float IGPlus_FireTS;
var vector IGPlus_SpawnLoc;
var vector IGPlus_SpawnVel;

// Push-Safe Aim from a moving lift (IGPlus_LiftShot): server, the flight
// near the lift; clients, its speed, as it was sent held still.
var IGPlus_LiftShot IGPlus_Lift;
var vector IGPlus_HeldVelocity;

replication
{
	reliable if (Role == ROLE_Authority && bNetInitial)
		IGPlus_HeldVelocity;
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

// ChunkTrail is its own actor -- destroying the owner only orphans it.
// Debug (enableDebugData): where the shooter's own slug goes, on each side.
simulated function IGPlus_Debug(string What) {
	local string Side;

	if (bClientVisualOnly || bbPlayer(Instigator) == None || bbPlayer(Instigator).bDrawDebugData == false)
		return;
	if (Level.NetMode == NM_Client && Viewport(bbPlayer(Instigator).Player) == None)
		return;
	Side = "server";
	if (Level.NetMode == NM_Client)
		Side = "client";
	bbPlayer(Instigator).ClientDebugMessage("Flak slug ("$Side$") "$What$" at "$class'ST_ShockProj'.static.IGPlus_Vec(Location));
}

simulated function Destroyed()
{
	IGPlus_Debug("gone");
	if (bClientVisualOnly && Trail != None)
		Trail.Destroy();
	Super.Destroyed();
}

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
	local ST_UT_FlakCannon FC;
	local vector FakeLocation;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().FlakCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bFlakUseClientSideAnimations == true) {

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			FC = ST_UT_FlakCannon(InstigatingPlayer.Weapon);
			if (FC != none && FC.LocalSlugDummy != none && FC.LocalSlugDummy.bDeleteMe == false)
			{
				// Store fake's current position for smooth hand-off
				FakeLocation = FC.LocalSlugDummy.Location;

				// Destroy the fake projectile
				FC.LocalSlugDummy.Destroy();

				// Teleport real projectile to where the fake was
				// This prevents the visual "jump" on high ping
				SetLocation(FakeLocation);
				IGPlus_Debug("took over from our own copy");
				// Our copy already hit something: so did the server's. Its
				// explosion follows.
				if (FC.IGPlus_bLocalSlugGone)
					IGPlus_ClientGone();

				// Pre-initialize ExtrapolationDelta so the first Tick doesn't cause a jump
				ExtrapolationDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
			}
		}
	} else if (IGPlus_HeldVelocity == vect(0,0,0)) {
		Disable('Tick');
	}
}

simulated event Tick(float Delta) {
    local vector NewXPolDelta;
    super.Tick(Delta);

	// Sent held still from a moving lift (IGPlus_LiftShot): its speed came
	// with it. A zero speed is not sent at all, so what is here is this
	// class's own start-up guess (from its rotation): replace it.
	if (IGPlus_HeldVelocity != vect(0,0,0) && Role < ROLE_Authority) {
		if (Physics != PHYS_None) {
			Velocity = IGPlus_HeldVelocity;
			if (InstigatingPlayer != None)
				ExtrapolationDelta = Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping);
		}
		IGPlus_HeldVelocity = vect(0,0,0);
		if (bCollideActors == false && bClientVisualOnly == false)
			SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);
	}

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

function ProcessTouch (Actor Other, vector HitLocation)
{
	// A rewound copy (ping fast-forward) gets the crouch cut-off stock Touch gives real players
	if (UTPlusDummy(Other) != None && UTPlusDummy(Other).AdjustHitLocation(HitLocation, Velocity) == false)
		return;
	// A rewound ball's stand-in (ping compensation): the ball it stands for.
	if (ST_ProjectileDummy(Other) != None && ST_ProjectileDummy(Other).Actual != None)
		Other = ST_ProjectileDummy(Other).Actual;

    if (Other == Instigator)
        return;

    if (Other.IsA('ShockProj') && GetWeaponSettings().ShockProjectileBlockFlakSlug == false)
        return; // If ShockProjectileBlockFlakSlug is False, we do nothing and the flak slug passes through

	if (bClientVisualOnly)
	{
		bHidden = true;
		return;
	}

    NewExplode(HitLocation, Normal(HitLocation-Other.Location));
}

simulated function Landed( vector HitNormal )
{
	local DirectionalBlast D;

	if (IGPlus_Lift != None && IGPlus_Lift.PassLanded(HitNormal))
		return;

	// Our own copy stops where it hits, as the server's explodes there.
	if (bClientVisualOnly)
		{
			IGPlus_ClientGone();
			return;
		}

	if ( bClientVisualOnly == false && Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'Botpack.DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}
	if (Role < ROLE_Authority) {
		IGPlus_Debug("landed");
		IGPlus_ClientGone();
		return;
	}
	Explode(Location,HitNormal);
}

// Clients: the server explodes it, a ping later. Meanwhile it neither slides
// along what it hit nor sits on it: it is gone from here.
simulated function IGPlus_ClientGone() {
	local ST_UT_FlakCannon FC;

	if (bClientVisualOnly && Pawn(Owner) != None) {
		FC = ST_UT_FlakCannon(Pawn(Owner).Weapon);
		if (FC != None && FC.LocalSlugDummy == self)
			FC.IGPlus_bLocalSlugGone = true;
	}
	bHidden = true;
	LightType = LT_None;
	AmbientSound = None;
	if (Trail != None)
		Trail.bHidden = true;
	SetPhysics(PHYS_None);
}


simulated function HitWall (vector HitNormal, actor Wall)
{
	local DirectionalBlast D;

	if (IGPlus_Lift != None && IGPlus_Lift.PassHitWall(Wall))
		return;

	// Our own copy stops where it hits, as the server's explodes there.
	if (bClientVisualOnly)
		{
			IGPlus_ClientGone();
			return;
		}

	if ( bClientVisualOnly == false && Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'Botpack.DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}
	if (Role < ROLE_Authority) {
		IGPlus_Debug("hit "$Wall);
		IGPlus_ClientGone();
		return;
	}
	Super.HitWall(HitNormal, Wall);
}

function NewExplode(vector HitLocation, vector HitNormal)
{
	local vector start;
	local ST_UTChunkInfo CI;
	local bbPlayer bbP;
	local float TargetTS;

	if (bClientVisualOnly)
		{
			bHidden = true;
			return;
		}

	// Predicted self-knockback: its age from its flight, as the shooter's
	// guess (bbPlayer.IGPlus_SKArcTime).
	bbP = bbPlayer(Instigator);
	if (IGPlus_FireTS > 0.0 && VSize(IGPlus_SpawnVel) >= 50.0 && bbP != none && bbP.IGPlus_PredictedSelfKnockback)
		bbP.IGPlus_SKBeginCapture();
	else
		bbP = none;

	if (WImp.WeaponSettings.bEnableEnhancedSplashFlakSlug) {
		WImp.EnhancedHurtRadius(
			self,
			WImp.WeaponSettings.FlakSlugDamage,
			WImp.WeaponSettings.FlakSlugHurtRadius,
			'FlakDeath',
			WImp.WeaponSettings.FlakSlugMomentum * MomentumTransfer,
			HitLocation);
	} else {
		HurtRadius(
			WImp.WeaponSettings.FlakSlugDamage,
			WImp.WeaponSettings.FlakSlugHurtRadius,
			'FlakDeath',
			WImp.WeaponSettings.FlakSlugMomentum * MomentumTransfer,
			HitLocation);
	}
	if (bbP != none) {
		TargetTS = IGPlus_FireTS + class'bbPlayer'.static.IGPlus_SKArcTime(
			Location - IGPlus_SpawnLoc, IGPlus_SpawnVel, Velocity.Z, Region.Zone.ZoneGravity.Z);
		bbP.IGPlus_SKEndCaptureFor(self, TargetTS, HitLocation);
	}
	start = Location + 10 * HitNormal;
 	Spawn( class'ut_FlameExplosion',,,Start);
	CI = Spawn(Class'ST_UTChunkInfo', Instigator);
	CI.WImp = WImp;
	CI.RandomSpread = True;
	CI.IGPlus_bSlugChunks = true;
	// Blown up while still being caught up for the ping (point blank): the
	// chunks get the rest of that catch-up, nothing more.
	if (WImp.IGPlus_CatchUpProjectile == self)
		CI.IGPlus_SlugCatchUpMs = FMax(WImp.IGPlus_CatchUpLeftMs, 0.0);
	
	// Our chunks hitting us on their fast-forward push us after the slug.
	// Our own disc they only damage (ST_UTChunk.ProcessTouch).
	if (bbP != none)
		bbP.IGPlus_SKBeginCapture();
	CI.AddChunk(Spawn( class 'ST_UTChunk2',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk3',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk4',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk1',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk2',CI, '', Start));
	if (bbP != none)
		bbP.IGPlus_SKEndCaptureAfter(TargetTS);
 	Destroy();
}

function Explode(vector HitLocation, vector HitNormal)
{
	NewExplode(HitLocation, HitNormal);
}

defaultproperties {
}