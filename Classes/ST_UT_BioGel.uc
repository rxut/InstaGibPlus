class ST_UT_BioGel extends UT_BioGel;

var IGPlus_WeaponImplementation WImp;

var int BioGelID;
var bool bClientVisualOnly;

replication
{
    reliable if ( Role == ROLE_Authority )
        BioGelID;
}

function PostBeginPlay()
{
	// Call Super.PostBeginPlay() first to ensure proper initialization
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
	local bbPlayer bbP;
	local ST_UT_BioGel OtherBioGel;

	super.PostNetBeginPlay();

	if (Level.NetMode == NM_Client && Role == ROLE_Authority) return;

	bbP = bbPlayer(Owner);

    foreach AllActors(class'ST_UT_BioGel', OtherBioGel)
    {
        if (OtherBioGel != self && OtherBioGel.BioGelID == BioGelID && OtherBioGel.bClientVisualOnly)
        {
			OtherBioGel.bHidden = true;
            SetTimer(0.0, false);
            return;
        }
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
