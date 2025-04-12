class ST_FlakSlug extends flakslug;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var bool bClientVisualOnly;

var float SlugUniqueID;

replication
{
    reliable if ( Role == ROLE_Authority )
        SlugUniqueID;
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
		return 0;
	
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

simulated function PostBeginPlay() {
	local bbPlayer bbP;

	bbP = bbPlayer(Owner);

	if (bbP != None)
	{
		SlugUniqueID = GetFRandValues();
	}
	else
	{
		SlugUniqueID = FRand();
	}

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
    local ST_FlakSlug OtherSlug;

	super.PostNetBeginPlay();

	if (Level.NetMode == NM_Client && Role == ROLE_Authority) return;

    foreach AllActors(class'ST_FlakSlug', OtherSlug)
    {
        if (OtherSlug != self && OtherSlug.SlugUniqueID == SlugUniqueID && OtherSlug.bClientVisualOnly)
        {
                OtherSlug.bHidden = true;
				
                if (OtherSlug.Trail != None)
                {
                    OtherSlug.Trail.Destroy();
                    OtherSlug.Trail = None;
                }

                SetTimer(0.0, false);
                return;
        }
    }
}

function ProcessTouch (Actor Other, vector HitLocation)
{

    if (Other == Instigator)
        return;

    if (Other.IsA('ShockProj') && GetWeaponSettings().ShockProjectileBlockFlakSlug == false)
        return; // If ShockProjectileBlockFlakSlug is False, we do nothing and the flak slug passes through

	if (bClientVisualOnly)
		bHidden = true;

    NewExplode(HitLocation, Normal(HitLocation-Other.Location));
}

simulated function Landed( vector HitNormal )
{
	local DirectionalBlast D;

	if (bClientVisualOnly)
		{
			bHidden = true;
			return;
		}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'Botpack.DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}
	Explode(Location,HitNormal);
}


simulated function HitWall (vector HitNormal, actor Wall)
{
	local DirectionalBlast D;

	if (bClientVisualOnly)
		{
			bHidden = true;
			return;
		}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		D = Spawn(class'Botpack.DirectionalBlast',self);
		if ( D != None )
			D.DirectionalAttach(initialDir, HitNormal);
	}
	Super.HitWall(HitNormal, Wall);
}

function NewExplode(vector HitLocation, vector HitNormal)
{
	local vector start;
	local ST_UTChunkInfo CI;

	if (bClientVisualOnly)
		return;

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
	start = Location + 10 * HitNormal;
 	Spawn( class'ut_FlameExplosion',,,Start);
	CI = Spawn(Class'ST_UTChunkInfo', Instigator);
	CI.WImp = WImp;
	CI.AddChunk(Spawn( class 'ST_UTChunk2',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk3',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk4',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk1',, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk2',, '', Start));
 	Destroy();
}

function Explode(vector HitLocation, vector HitNormal)
{
	NewExplode(HitLocation, HitNormal);
}

defaultproperties {
}