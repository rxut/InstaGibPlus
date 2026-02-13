class ST_BioGlob extends ST_UT_BioGel;

var int NumSplash;
var vector SpawnPoint;

function PostBeginPlay() {
	super.PostBeginPlay();
	Damage = WImp.WeaponSettings.BioAltDamage;
	MomentumTransfer = default.MomentumTransfer * WImp.WeaponSettings.BioAltMomentum;
}

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
	local ST_ut_biorifle br;
	local vector FakeLocation;

	super(Projectile).PostNetBeginPlay();

	if (GetWeaponSettings().BioCompensatePing && bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bBioUseClientSideAnimations == true) {

		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			br = ST_ut_biorifle(InstigatingPlayer.Weapon);
			if (br != none && br.LocalBioGlobDummy != none && br.LocalBioGlobDummy.bDeleteMe == false)
			{
				FakeLocation = br.LocalBioGlobDummy.Location;
				br.LocalBioGlobDummy.Destroy();
				SetLocation(FakeLocation);
				ExtrapolationDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
			}
		}
	} else {
		Disable('Tick');
	}
}

auto state Flying
{
	function ProcessTouch (Actor Other, vector HitLocation) 
	{ 
		if ( Other.IsA('ST_BioSplash') )
			return;
		if (bClientVisualOnly) {
			Destroy();
			return;
		}
		if ( Pawn(Other)!=Instigator || bOnGround) 
			Global.Timer(); 
	}
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		if (bClientVisualOnly) {
			Destroy();
			return;
		}

		SetPhysics(PHYS_None);		
		MakeNoise(1);	
		bOnGround = True;
		PlaySound(ImpactSound);	
		SetWall(HitNormal, Wall);
		if ( DrawScale > 1 )
			NumSplash = int(2 * DrawScale) - 1;
		SpawnPoint = Location + 5 * HitNormal;
		DrawScale= FMin(DrawScale, 3.0);
		if ( NumSplash > 0 )
		{
			SpawnSplash();
			if ( NumSplash > 0 )
				SpawnSplash();
		}
		GoToState('OnSurface');
	}
}

function SpawnSplash()
{
	local vector Start;

	NumSplash--;
	Start = SpawnPoint + 4 * VRand(); 
	Spawn(class'ST_BioSplash',,,Start,Rotator(Start - Location));
}

state OnSurface
{
	function Tick(float DeltaTime)
	{
		if ( NumSplash > 0 )
		{
			SpawnSplash();
			if ( NumSplash > 0 )
				SpawnSplash();
			else
				Disable('Tick');
		}
		else
			Disable('Tick');
	}

	function ProcessTouch (Actor Other, vector HitLocation)
	{
		if ( Other.IsA('ST_BioSplash') )
			return;
		GotoState('Exploding');
	}

	function BeginState()
	{
		super(UT_BioGel).BeginState();
	}
}

defaultproperties
{
     speed=700.000000
     Damage=75.000000
     MomentumTransfer=30000
}
