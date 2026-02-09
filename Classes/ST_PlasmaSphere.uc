class ST_PlasmaSphere extends PlasmaSphere;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;

var vector ExtrapolationDelta;

simulated function PostBeginPlay()
{
	local WeaponSettingsRepl WS;

	if (ROLE == ROLE_Authority)
	{
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
	}

	WS = GetWeaponSettings();
	if (WS != none) {
		Speed = WS.PulseSphereSpeed;
		SetCollisionSize(WS.PulseSphereCollisionRadius, WS.PulseSphereCollisionHeight);
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
	local ST_PulseGun PG;
	local vector FakeLocation;
	local vector MyDir;
	local ST_PlasmaSphere MatchedDummy;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().PulseCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bPulseUseClientSideAnimations == true) {

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			PG = ST_PulseGun(InstigatingPlayer.Weapon);
			if (PG != none)
			{
				MyDir = Normal(Velocity);
				MatchedDummy = PG.FindBestMatchingDummy(MyDir);

				if (MatchedDummy != none)
				{
					FakeLocation = MatchedDummy.Location;
					PG.ClearDummyFromArray(MatchedDummy);
					MatchedDummy.Destroy();
					SetLocation(FakeLocation);
				}

				ExtrapolationDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
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

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bClientVisualOnly)
	{
		bHidden = true;
		Destroy();
		return;
	}

	if ( !bExplosionEffect )
	{
		if ( Role == ROLE_Authority )
			BlowUp(HitLocation);
		bExplosionEffect = true;
		if ( !Level.bHighDetailMode || bHitPawn || Level.bDropDetail )
		{
			if ( bExploded )
			{
				Destroy();
				return;
			}
			else
				DrawScale = 0.4;
		}
		else
			DrawScale = 0.4;

	    LightType = LT_Steady;
		LightRadius = 5;
		SetCollision(false,false,false);
		LifeSpan = 0.5;
		Texture = ExpType;
		DrawType = DT_SpriteAnimOnce;
		Style = STY_Translucent;
		if ( Region.Zone.bMoveProjectiles && (Region.Zone.ZoneVelocity != vect(0,0,0)) )
		{
			bBounce = true;
			Velocity = Region.Zone.ZoneVelocity;
		}
		else
			SetPhysics(PHYS_None);
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	if (Other == Instigator)
        return;

	if (bClientVisualOnly)
		bHidden = true;
	
	If (PlasmaSphere(Other) == None)
	{
		if (Other.bIsPawn || Other.IsA('UTPlusDummy'))
		{
			bHitPawn = true;
			bExploded = !Level.bHighDetailMode || Level.bDropDetail;
		}
		
		if (Role == ROLE_Authority)
		{
			Other.TakeDamage(
				WImp.WeaponSettings.PulseSphereDamage,
				instigator,
				HitLocation,
				WImp.WeaponSettings.PulseSphereMomentum * MomentumTransfer * Vector(Rotation),
				MyDamageType);
		}
		Explode(HitLocation, vect(0,0,1));
	}
}


defaultproperties {
}
