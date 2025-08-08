class ST_FlakSlug extends flakslug;

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

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
    local ST_UT_FlakCannon FC;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().FlakCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bFlakUseClientSideAnimations == true) {

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			FC = ST_UT_FlakCannon(InstigatingPlayer.Weapon);
			if (FC != none && FC.LocalSlugDummy != none && FC.LocalSlugDummy.bDeleteMe == false)

				FC.LocalSlugDummy.Destroy();

				if (FC.LocalSlugDummy.Trail != None)
                {
                    FC.LocalSlugDummy.Trail.Destroy();
                    FC.LocalSlugDummy.Trail = None;
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
		MoveSmooth(NewXPolDelta - ExtrapolationDelta);
		ExtrapolationDelta = NewXPolDelta;
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
	CI.RandomSpread = True;
	
	CI.AddChunk(Spawn( class 'ST_UTChunk2',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk3',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk4',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk1',CI, '', Start));
	CI.AddChunk(Spawn( class 'ST_UTChunk2',CI, '', Start));
 	Destroy();
}

function Explode(vector HitLocation, vector HitNormal)
{
	NewExplode(HitLocation, HitNormal);
}

defaultproperties {
}