// ===============================================================
// Stats.ST_UTChunk: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_UTChunk extends UTChunk;

var ST_UTChunkInfo Chunkie;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var int ChunkIndex;

var bool RandomSpread;
var float R1, R2, R3, R4;

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

replication
{
	reliable if ( Role == ROLE_Authority )
		R1, R2, R3, R4;
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

simulated function PostBeginPlay() {
	local rotator RandRot;
	local bbPlayer bbP;

	if (Level.NetMode != NM_DedicatedServer) {
		if (!Region.Zone.bWaterZone)
			Trail = Spawn(class'ChunkTrail',self);
		SetTimer(0.1, true);
	}
	bbP = bbPlayer(Owner);

	if (bbP != None)
	{
		R1 = GetFRandValues();
		R2 = GetFRandValues();
		R3 = GetFRandValues();
		R4 = GetFRandValues();
		
	}
	else
	{
		R1 = FRand();
		R2 = FRand();
		R3 = FRand();
		R4 = FRand();
	}

	if (Role == ROLE_Authority) {
		Chunkie = ST_UTChunkInfo(Owner);
		
		if (GetWeaponSettings().FlakChunkRandomSpread || (Chunkie != None && Chunkie.RandomSpread == True)) {
			RandRot = Rotation;
			RandRot.Pitch += R1 * 2000 - 1000;
			RandRot.Yaw += R2 * 2000 - 1000;
			RandRot.Roll += R3 * 2000 - 1000;
			Velocity = Vector(RandRot) * (Speed + (R4 * 200 - 100));
		} else {
			Velocity = vector(Rotation) * Speed;
			RandRot = Rotation;
			RandRot.Roll = Rand(65536);
			SetRotation(RandRot);
		}

		if (Region.zone.bWaterZone)
			Velocity *= 0.65;
	}

	super(Projectile).PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;		// Find master :D
}

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
	local ST_UTChunk OtherChunk;

	super.PostNetBeginPlay();

	if (GetWeaponSettings().FlakCompensatePing) {

		if (bbPlayer(Instigator) != none && bbPlayer(Instigator).ClientWeaponSettingsData.bFlakUseClientSideAnimations == false){
			return;
		}

		In = PlayerPawn(Instigator);
        if (In != none && Viewport(In.Player) != none)
            InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			foreach AllActors(class'ST_UTChunk', OtherChunk)
			{	
				if (OtherChunk != self && OtherChunk.bClientVisualOnly)
				{
					OtherChunk.bHidden = true;
					
					if (OtherChunk.Trail != None)
					{
						OtherChunk.Trail.Destroy();
						OtherChunk.Trail = None;
					}

					OtherChunk.Destroy();
				}
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
	if (Physics == PHYS_Projectile) {
		NewXPolDelta = (Velocity * (0.0005 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping));
		MoveSmooth(NewXPolDelta - ExtrapolationDelta);
		ExtrapolationDelta = NewXPolDelta;
	}
}

function ProcessTouch (Actor Other, vector HitLocation)
{
	// Physics for chunks is split into 3 phases:
	// PHYS_Projectile -- immediately after being fired, default physics
	// PHYS_Falling -- after hitting surface while in PHYS_Projectile
	// PHYS_None -- after touching standable ground while in PHYS_Falling

	if (Physics == PHYS_None || bHidden)
		return;
	
	// For ShockProjectileBlockFlakChunk
    if (ShockProj(Other) != None && !Chunkie.WImp.WeaponSettings.ShockProjectileBlockFlakChunk)
        return;
	
	if (bClientVisualOnly && (Other != Instigator))
	{
		bHidden = true;
		return;
	}

	if ((Chunk(Other) == None) && ((Physics == PHYS_Falling) || (Other != Instigator))) {
		speed = VSize(Velocity);
		if (speed > 200) {
			if (Role == ROLE_Authority) {
				Other.TakeDamage(
					CalcDamage(),
					instigator,
					HitLocation,
					Chunkie.WImp.WeaponSettings.FlakChunkMomentum * (MomentumTransfer * Velocity/speed),
					MyDamageType);
			}
			if (FRand() < 0.5)
				PlaySound(Sound 'ChunkHit',, 4.0,,200);
		}
		bHidden = true;
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
		local float Rand;
		local SmallSpark s;

		if (bClientVisualOnly)
		{
			bHidden = true;

			if (Trail != None)
			{
				Trail.Destroy();
				Trail = None;
			}
			SetTimer(0.0, false);
			Destroy();
			return;
		}

		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
		{
			if ( Level.NetMode != NM_Client )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			Destroy();
			return;
		}
		if ( Physics != PHYS_Falling ) 
		{
			SetPhysics(PHYS_Falling);
			if ( !Level.bDropDetail && (Level.Netmode != NM_DedicatedServer) && !Region.Zone.bWaterZone ) 
			{
				if ( FRand() < 0.5 )
				{
					s = Spawn(Class'SmallSpark',,,Location+HitNormal*5,rotator(HitNormal));
					s.RemoteRole = ROLE_None;
				}
				else
					Spawn(class'WallCrack',,,Location, rotator(HitNormal));
			}
		}
		Velocity = 0.8*(( Velocity dot HitNormal ) * HitNormal * (-1.8 + FRand()*0.8) + Velocity);   // Reflect off Wall w/damping
		SetRotation(rotator(Velocity));
		speed = VSize(Velocity);
		if ( speed > 100 ) 
		{
			MakeNoise(0.3);
			Rand = FRand();
			if (Rand < 0.33)	PlaySound(sound 'Hit1', SLOT_Misc,0.6,,1000);	
			else if (Rand < 0.66) PlaySound(sound 'Hit3', SLOT_Misc,0.6,,1000);
			else PlaySound(sound 'Hit5', SLOT_Misc,0.6,,1000);
		}
}

function float CalcDamage() {
	local float Base, Reduced;
	local float T1, T2;
	local float Time;

	Base = Chunkie.WImp.WeaponSettings.FlakChunkDamage;
	Reduced = Base * Chunkie.WImp.WeaponSettings.FlakChunkDropOffDamageRatio;
	T1 = Chunkie.WImp.WeaponSettings.FlakChunkDropOffStart;
	T2 = Chunkie.WImp.WeaponSettings.FlakChunkDropOffEnd;
	Time = Chunkie.WImp.WeaponSettings.FlakChunkLifespan - Lifespan;

	if (Time <= T1)
		return Base;

	if (Time >= T2)
		return Reduced;

	return Lerp((Time - T1) / (T2 - T1), Base, Reduced);
}


defaultproperties {
	bNetTemporary=False
}