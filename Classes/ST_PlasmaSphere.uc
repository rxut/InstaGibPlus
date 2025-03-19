class ST_PlasmaSphere extends PlasmaSphere;

var IGPlus_WeaponImplementation WImp;

var bool bClientVisualOnly;
var int PlasmaSphereID;

replication
{
    reliable if ( Role == ROLE_Authority )
        PlasmaSphereID;
}

simulated function PostBeginPlay()
{

	if (ROLE == ROLE_Authority)
	{
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
	}

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local bbPlayer bbP;
	local ST_PlasmaSphere OtherPlasmaSphere;

	super.PostNetBeginPlay();

	if (Level.NetMode == NM_Client && Role == ROLE_Authority) return;

	bbP = bbPlayer(Owner);

    foreach AllActors(class'ST_PlasmaSphere', OtherPlasmaSphere)
    {
        if (OtherPlasmaSphere != self && OtherPlasmaSphere.PlasmaSphereID == PlasmaSphereID && OtherPlasmaSphere.bClientVisualOnly)
        {
			OtherPlasmaSphere.bHidden = true;
            SetTimer(0.0, false);
            return;
        }
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
				DrawScale = 0.2;
		}
		else
			DrawScale = 0.2;

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
		
	// For client visual spheres, destroy without any effect
	if (bClientVisualOnly || Other == Instigator)
	{
		bHidden = true;
		Destroy();
		return;
	}
	
	If (PlasmaSphere(Other) == None)
	{
		if (Other.bIsPawn)
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
