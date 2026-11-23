class ST_Razor2 extends Razor2;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;

var vector ExtrapolationDelta;

// Push-Safe Aim from a moving lift (IGPlus_LiftShot): server, the flight
// near the lift; clients, its speed, as it was sent held still.
var IGPlus_LiftShot IGPlus_Lift;
var vector IGPlus_HeldVelocity;
// Where the server spawned it before the ping catch-up: other players draw it
// from there (IGPlus_Glide).
var vector IGPlus_SkipStart;
// The shooter's client: our own blade against our own lift (IGPlus_SweepLift).
var Mover IGPlus_SweepMover;
var vector IGPlus_SweepMoverLoc, IGPlus_SweepLoc;

replication
{
	reliable if (Role == ROLE_Authority && bNetInitial)
		IGPlus_HeldVelocity, IGPlus_SkipStart;
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
	local ST_Razor2 Raz;
	local vector Held;

	super.PostNetBeginPlay();

	class'IGPlus_Glide'.static.Begin(self, IGPlus_SkipStart,
		bbPlayer(Instigator) != None && bbPlayer(Instigator).ClientWeaponSettingsData.bRipperUseClientSideAnimations);

	if (GetWeaponSettings().RipperCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bRipperUseClientSideAnimations == true)
	{
		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none && (bbPlayer(In) == none || bbPlayer(In).IGPlus_InDemoPlayback() == false))
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			foreach AllActors(class'ST_Razor2', Raz)
			{
				if (Raz.bClientVisualOnly && Raz.Owner == InstigatingPlayer && !Raz.bDeleteMe)
				{
					// On from our copy's spot, as our copy flew (IGPlus_OwnCopy):
					// with its bounces too. Fired from a lift, and the server's
					// blade flies the same way as our copy (both before a
					// bounce or both after it): moved onto the server's path.
					// After a bounce off the lift that path lies as far above
					// or below ours as the real lift is from our screen's.
					NumWallHits = Raz.NumWallHits;
					bCanHitInstigator = Raz.bCanHitInstigator;
					Held = IGPlus_HeldVelocity;
					if (Held == vect(0,0,0))
						Held = Velocity;
					if (Raz.IGPlus_SweepMover == None || (Normal(Raz.Velocity) dot Normal(Held)) < 0.999)
						Held = vect(0,0,0);
					class'IGPlus_OwnCopy'.static.TakeOver(self, Raz, Held);
					// Sent held still from a moving lift (IGPlus_LiftShot):
					// the speed is our copy's now.
					if (IGPlus_HeldVelocity != vect(0,0,0)) {
						IGPlus_HeldVelocity = vect(0,0,0);
						if (bCollideActors == false)
							SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);
					}
					ExtrapolationDelta = (Velocity * class'bbPlayer'.static.IGPlus_OwnProjLead(InstigatingPlayer));
					// As after a bounce of its own (HitWall): no lead.
					if (NumWallHits > 0)
						Disable('Tick');
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
				ExtrapolationDelta = Velocity * class'bbPlayer'.static.IGPlus_OwnProjLead(InstigatingPlayer);
		}
		IGPlus_HeldVelocity = vect(0,0,0);
		if (bCollideActors == false && bClientVisualOnly == false)
			SetCollision(default.bCollideActors, default.bBlockActors, default.bBlockPlayers);
	}

	// Our own blade, the local copy and the server's: against our own lift.
	if (Level.NetMode == NM_Client && (bClientVisualOnly || InstigatingPlayer != none)) {
		IGPlus_SweepLift();
		if (NumWallHits > 0)
			return;
	}

	if (InstigatingPlayer == none)
		return;

	if (bbPlayer(InstigatingPlayer) != none && bbPlayer(InstigatingPlayer).IGPlus_InDemoPlayback())
		return;

	// Extrapolate locally to compensate for ping
	if (Physics != PHYS_None) {
		NewXPolDelta = (Velocity * class'bbPlayer'.static.IGPlus_OwnProjLead(InstigatingPlayer));
		Move(NewXPolDelta - ExtrapolationDelta);
		ExtrapolationDelta = NewXPolDelta;
	}
}

// The shooter's client: a lift that rises into our blade does not turn it
// here, the blade just ends up inside the lift and flies on. The server
// bounces it off the lift where our screen has it (IGPlus_LiftShot). Swept
// against our lift in the lift's own frame, as ST_UT_BioGel does, it bounces
// here at the same spot.
simulated function IGPlus_SweepLift() {
	local vector D, HL, HN;
	local bbPlayer BP;

	// Our local copy has no Instigator, its owner is us.
	BP = bbPlayer(Instigator);
	if (BP == None)
		BP = bbPlayer(Owner);
	if (BP == None || BP.IGPlus_InDemoPlayback())
		return;
	if (IGPlus_SweepMover == None) {
		IGPlus_SweepMover = Mover(BP.Base);
		if (IGPlus_SweepMover == None)
			return;
	} else {
		D = IGPlus_SweepMover.Location - IGPlus_SweepMoverLoc;
		if (D != vect(0,0,0) && BP.IGPlus_TraceMover(IGPlus_SweepMover, IGPlus_SweepLoc + D, Location, HL, HN,
			vect(1,1,0) * CollisionRadius + vect(0,0,1) * CollisionHeight)) {
			// Off the surface, as the server puts it: left on it, it
			// would meet the lift again in every move.
			SetLocation(HL + 2.0 * HN);
			HitWall(HN, IGPlus_SweepMover);
		}
	}
	IGPlus_SweepMoverLoc = IGPlus_SweepMover.Location;
	IGPlus_SweepLoc = Location;
}

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation) {
		local vector Dir;
		local float DamageToApply;

		if (Other != Instigator && bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		// A rewound copy (ping fast-forward) gets the crouch cut-off stock Touch gives real players
		if (UTPlusDummy(Other) != None && UTPlusDummy(Other).AdjustHitLocation(HitLocation, Velocity) == false)
			return;

		Dir = Normal(Velocity);
		if (bCanHitInstigator || (Other != Instigator)) {
			if (Role == ROLE_Authority) {
				if ((Other.bIsPawn || Other.IsA('UTPlusDummy')) &&
					(HitLocation.Z - Other.Location.Z > 0.62 * Other.CollisionHeight) &&
					(!Instigator.IsA('Bot') || !Bot(Instigator).bNovice)
				) {

					DamageToApply = WImp.WeaponSettings.RipperHeadshotDamage;
					
					if (NumWallHits > 0)
						DamageToApply = DamageToApply * WImp.WeaponSettings.RipperHeadShotDamageWallMultiplier;

					Other.TakeDamage(
						DamageToApply,
						Instigator,
						HitLocation,
						WImp.WeaponSettings.RipperHeadshotMomentum * MomentumTransfer * Dir,
						'decapitated'
					);
				} else {

					DamageToApply = WImp.WeaponSettings.RipperPrimaryDamage;
					if (NumWallHits > 0)
						DamageToApply = DamageToApply * WImp.WeaponSettings.RipperPrimaryDamageWallMultiplier;

					Other.TakeDamage(
						DamageToApply,
						Instigator,
						HitLocation,
						WImp.WeaponSettings.RipperPrimaryMomentum * MomentumTransfer * Dir,
						'shredded'
					);
				}
			}
			if (Other.bIsPawn || Other.IsA('UTPlusDummy'))
				PlaySound(MiscSound, SLOT_Misc, 2.0);
			else
				PlaySound(ImpactSound, SLOT_Misc, 2.0);
			
			if (Role == ROLE_Authority)
				Destroy();
		}
	}

	simulated function HitWall (vector HitNormal, actor Wall) {
		local vector Vel2D, Norm2D;

		if (IGPlus_Lift != None && IGPlus_Lift.PassHitWall(Wall))
			return;

		bCanHitInstigator = true;
		if (!bClientVisualOnly)
			PlaySound(ImpactSound, SLOT_Misc, 2.0);
		LoopAnim('Spin',1.0);
		if ((Mover(Wall) != none) && Mover(Wall).bDamageTriggered) {
			if (Role == ROLE_Authority) {
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				Destroy();
			}
			return;
		}
		NumWallHits++;
		SetTimer(0, False);
		MakeNoise(0.3);
		if (NumWallHits > 6 && Role == ROLE_Authority)
			Destroy();

		if (NumWallHits == 1) {
			if (!bClientVisualOnly)
				Spawn(class'WallCrack',,,Location, rotator(HitNormal));
			Vel2D = Velocity;
			Vel2D.Z = 0;
			Norm2D = HitNormal;
			Norm2D.Z = 0;
			Norm2D = Normal(Norm2D);
			Vel2D = Normal(Vel2D);
			if ((Vel2D Dot Norm2D) < -0.999) {
				HitNormal = Normal(HitNormal + 0.6 * Vel2D);
				Norm2D = HitNormal;
				Norm2D.Z = 0;
				Norm2D = Normal(Norm2D);
				if ((Vel2D Dot Norm2D) < -0.999) {
					if ( Rand(1) == 0 )
						HitNormal = HitNormal + vect(0.05,0,0);
					else
						HitNormal = HitNormal - vect(0.05,0,0);
					if ( Rand(1) == 0 )
						HitNormal = HitNormal + vect(0,0.05,0);
					else
						HitNormal = HitNormal - vect(0,0.05,0);
					HitNormal = Normal(HitNormal);
				}
			}
		}
		Velocity -= 2 * (Velocity dot HitNormal) * HitNormal;
		// Disable extrapolation after bouncing - trajectory is now server-authoritative
		Disable('Tick');
		SetRoll(Velocity);
	}
}

defaultproperties {
	bNetTemporary=False
}
