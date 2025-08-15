class ST_Razor2 extends Razor2;

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
    local ST_ripper R;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().RipperCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bRipperUseClientSideAnimations == true)
	{

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			R = ST_ripper(InstigatingPlayer.Weapon);
			if (R != none && R.LocalRazor2Dummy != none && R.LocalRazor2Dummy.bDeleteMe == false)
				R.LocalRazor2Dummy.Destroy();
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
        MoveSmooth(NewXPolDelta - ExtrapolationDelta);
		ExtrapolationDelta = NewXPolDelta;
    }
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

		if (bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		bCanHitInstigator = true;
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
		SetRoll(Velocity);
	}
}

defaultproperties {
	bNetTemporary=False
}
