class ST_Razor2Alt extends Razor2Alt;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;
var vector ExtrapolationDelta;
// Server, predicted self-knockback: the shooter's fire step and launch.
var float IGPlus_FireTS;
var vector IGPlus_SpawnLoc;
var float IGPlus_Speed;

// Push-Safe Aim from a moving lift (IGPlus_LiftShot): server, the flight
// near the lift; clients, its speed, as it was sent held still.
var IGPlus_LiftShot IGPlus_Lift;
var vector IGPlus_HeldVelocity;

replication
{
	reliable if (Role == ROLE_Authority && bNetInitial)
		IGPlus_HeldVelocity;
}

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
	local vector FakeLocation;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().RipperCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bRipperUseClientSideAnimations == true)
	{
		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			foreach AllActors(class'ST_Razor2Alt', RazAlt)
			{
				if (RazAlt.bClientVisualOnly && RazAlt.Owner == InstigatingPlayer && !RazAlt.bDeleteMe)
				{
					FakeLocation = RazAlt.Location;
					RazAlt.Destroy();
					SetLocation(FakeLocation);
					ExtrapolationDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
					break;
				}
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

auto state Flying
{
	simulated function HitWall(vector HitNormal, actor Wall)
	{
		if (IGPlus_Lift != None && IGPlus_Lift.PassHitWall(Wall))
			return;
		Super.HitWall(HitNormal, Wall);
	}

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
		local bbPlayer bbP;

		if (bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		// Predicted self-knockback: its age is its travel over its speed.
		bbP = bbPlayer(Instigator);
		if (IGPlus_FireTS > 0.0 && IGPlus_Speed > 0.0 && bbP != none && bbP.IGPlus_PredictedSelfKnockback)
			bbP.IGPlus_SKBeginCapture();
		else
			bbP = none;

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
		if (bbP != none)
			bbP.IGPlus_SKEndCaptureFor(self,
				IGPlus_FireTS + VSize(Location - IGPlus_SpawnLoc) / IGPlus_Speed, HitLocation);
		MakeNoise(1.0);
	}
}


defaultproperties {
	bNetTemporary=False
}
