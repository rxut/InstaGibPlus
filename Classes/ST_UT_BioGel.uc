class ST_UT_BioGel extends UT_BioGel;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var PlayerPawn InstigatingPlayer;
var vector ExtrapolationDelta;

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

function PostBeginPlay()
{
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

	super.PostNetBeginPlay();

	if (GetWeaponSettings().BioCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bBioUseClientSideAnimations == true) {

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			br = ST_ut_biorifle(InstigatingPlayer.Weapon);
			if (br != none && br.LocalBioGelDummy != none && br.LocalBioGelDummy.bDeleteMe == false)

				br.LocalBioGelDummy.Destroy();
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
   if (IsInState('Flying')) {
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
		
		if ( Pawn(Other)!=Instigator || bOnGround) 
		{
			if (bClientVisualOnly)
			{
				bHidden = true;
				return;
			}
			Global.Timer(); 
		}
	}
}
