class ST_UT_BioGel extends UT_BioGel;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;
var vector ExtrapolationDelta;

var float R1, R2, R3;

replication
{
	reliable if ( Role == ROLE_Authority )
		R1, R2, R3;
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

simulated function float GetFRandValues()
{
	local bbPlayer bbP;
	local float RandValue;
	local int OldIndex;
	
	bbP = bbPlayer(Owner);
	if (bbP == None)
		return FRand();
	
	OldIndex = bbP.FRandValuesIndex;
	bbP.FRandValuesIndex++;
	
	if (bbP.FRandValuesIndex == bbP.FRandValuesLength)
		bbP.FRandValuesIndex = 0;
		
	if (Level.NetMode == NM_Client && Role < ROLE_Authority)
	{
		bbP.FRandValuesIndex = OldIndex;
	}
	
	RandValue = bbP.GetFRandValues(bbP.FRandValuesIndex);
	return RandValue;
}

function PostBeginPlay()
{
	R1 = GetFRandValues();
	R2 = GetFRandValues();
	R3 = GetFRandValues();

	Super.PostBeginPlay();
	
	if (Role == ROLE_Authority)
	{
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
		
		// Add null check before accessing WImp properties
		if (WImp != None && WImp.WeaponSettings != None)
		{
			Damage = WImp.WeaponSettings.BioDamage;
			MomentumTransfer = default.MomentumTransfer * WImp.WeaponSettings.BioMomentum;
		}
	}
}

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
    local ST_ut_biorifle br;
	local vector FakeLocation;

	super.PostNetBeginPlay();

	if (Level.NetMode != NM_DedicatedServer)
	{
		RotationRate.Yaw = 100000 * 2 * R1 - 100000;
		RotationRate.Pitch = 100000 * 2 * R2 - 100000;
		RotationRate.Roll = 100000 * 2 * R3 - 100000;
	}

	if (GetWeaponSettings().BioCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bBioUseClientSideAnimations == true) {

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			br = ST_ut_biorifle(InstigatingPlayer.Weapon);
			if (br != none && br.LocalBioGelDummy != none && br.LocalBioGelDummy.bDeleteMe == false)
			{
				// Store fake's current position for smooth hand-off
				FakeLocation = br.LocalBioGelDummy.Location;

				// Destroy the fake projectile
				br.LocalBioGelDummy.Destroy();

				// Teleport real projectile to where the fake was
				// This prevents the visual "jump" on high ping
				SetLocation(FakeLocation);

				// Pre-initialize ExtrapolationDelta so the first Tick doesn't cause a jump
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
    // Stop extrapolation when bOnGround is true
    if (IsInState('Flying') && !bOnGround) {
        NewXPolDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
        Move(NewXPolDelta - ExtrapolationDelta);
        ExtrapolationDelta = NewXPolDelta;
    }
}

function Timer()
{
	local ut_GreenGelPuff f;

	if (bClientVisualOnly)
	{
		bHidden = true;
		Destroy();
		return;
	}

	f = spawn(class'ut_GreenGelPuff',,,Location + SurfaceNormal*8); 
	f.numBlobs = numBio;
	if ( numBio > 0 )
		f.SurfaceNormal = SurfaceNormal;	
	PlaySound (MiscSound,,3.0*DrawScale);	
	if ( (Mover(Base) != None) && Mover(Base).bDamageTriggered )	// A Base ain't a pawn, so don't worry.
		Base.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

	if (WImp != None && WImp.WeaponSettings != None) {
		if (WImp.WeaponSettings.bEnableEnhancedSplashBio) {
			WImp.EnhancedHurtRadius(
				self,
			Damage * DrawScale,
			FMin(WImp.WeaponSettings.BioHurtRadiusMax, DrawScale * WImp.WeaponSettings.BioHurtRadiusBase),
			MyDamageType,
			MomentumTransfer * DrawScale,
			Location);
		} else {
			HurtRadius(
				Damage * DrawScale,
				FMin(WImp.WeaponSettings.BioHurtRadiusMax, DrawScale * WImp.WeaponSettings.BioHurtRadiusBase),
				MyDamageType,
				MomentumTransfer * DrawScale,
				Location);
		}
	}
	Destroy();	
}

state OnSurface
{

	function BeginState()
	{
		if (bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		if (WImp != None && WImp.WeaponSettings != None && WImp.WeaponSettings.BioPrimaryInstantExplosion)
			global.Timer();
		else
			super.BeginState();
	}

}

state Exploding
{
	ignores Touch, TakeDamage;

	function BeginState()
	{
		if (bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}

		SetTimer(0.2, False); // Make explosions after touch not random
	}
}


auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation) 
	{
		if (bClientVisualOnly)
		{
			bHidden = true;
			Destroy();
			return;
		}
		
		if ( Pawn(Other)!=Instigator || bOnGround) 
		{
			Global.Timer(); 
		}
	}

	function BeginState()
	{	
		if ( Role == ROLE_Authority )
		{
			Velocity = Vector(Rotation) * Speed;
			Velocity.z += 120;
			if( Region.zone.bWaterZone )
				Velocity=Velocity*0.7;

			RotationRate.Yaw = 100000 * 2 * R1 - 100000;
			RotationRate.Pitch = 100000 * 2 * R2 - 100000;
			RotationRate.Roll = 100000 * 2 * R3 - 100000;
		}
		
		LoopAnim('Flying',0.4);
		bOnGround=False;
		PlaySound(SpawnSound);
	}
}