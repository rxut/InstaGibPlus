class ST_StarterBolt extends ST_PBolt;

var float OldError, NewError, StartError, AimError; //used for bot aiming
var rotator AimRotation;
var float AnimTime;

// Count "shots" using this.
var float ShootAccum;

var float DamageCarry;
var float DecalInterval;
var float DecalMinInterval;

var WeaponSettingsRepl WSettings;

// Client: the player whose screen this is (IGPlus_SeenFromShooterEyes).
var PlayerPawn IGPlus_LocalPlayer;
var bool IGPlus_bLocalPlayerFound;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		AimError,
		NewError,
		AimRotation;
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

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( instigator == None )
		return;
	if ( Instigator.IsA('Bot') && Bot(Instigator).bNovice )
		aimerror = 2200 + (3 - instigator.skill) * 300;
	else
		aimerror = 1000 + (3 - instigator.skill) * 400;

	if ( FRand() < 0.5 )
		aimerror *= -1;

	if (ROLE == ROLE_Authority)
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;		// Find master :D

	GrowthDelay = WImp.WeaponSettings.PulseBoltGrowthDelay;
	MaxSegments = WImp.WeaponSettings.PulseBoltMaxSegments;
}

simulated function Tick(float DeltaTime)
{
	local vector X,Y,Z, AimSpot, DrawOffset, AimStart;
	local int YawErr;
	local float dAdjust;
	local Bot MyBot;
	local vector Origin;

	if (ROLE == ROLE_Authority)
	{
		// Sent to whoever gets its shooter (bPlayersAlwaysRelevant), not only to
		// those who can see the gun: a beam fired from behind cover stays visible.
		if (Instigator != None)
			bAlwaysRelevant = Instigator.bAlwaysRelevant;

		ShootAccum -= DeltaTime;
		while (ShootAccum <= 0.0)
		{	// Handle stats this way.
			ShootAccum += 0.05;		// TR 20 = 0.05s
		}
	}

	AnimTime += DeltaTime;
	if ( AnimTime > 0.05 )
	{
		AnimTime -= 0.05;
		SpriteFrame++;
		if ( SpriteFrame == ArrayCount(SpriteAnim) )
			SpriteFrame = 0;
		Skin = SpriteAnim[SpriteFrame];
	}

	// orient with respect to instigator
	if ( Instigator != None )
	{
		if ( (Level.NetMode == NM_Client) && (!Instigator.IsA('PlayerPawn') || (PlayerPawn(Instigator).Player == None)) )
		{
			SetRotation(AimRotation); 
			Instigator.ViewRotation = AimRotation;
			DrawOffset = ((0.01 * class'PulseGun'.Default.PlayerViewOffset) >> Rotation);
			DrawOffset += (Instigator.EyeHeight * vect(0,0,1));
		}
		else 
		{
			MyBot = Bot(instigator);
			if ( MyBot != None  )
			{
				if ( Instigator.Target == None )
					Instigator.Target = Instigator.Enemy;
				if ( Instigator.Target == Instigator.Enemy )
				{
					if (MyBot.bNovice )
						dAdjust = DeltaTime * (4 + instigator.Skill) * 0.075;
					else
						dAdjust = DeltaTime * (4 + instigator.Skill) * 0.12;
					if ( OldError > NewError )
						OldError = FMax(OldError - dAdjust, NewError);
					else
						OldError = FMin(OldError + dAdjust, NewError);

					if ( OldError == NewError )
						NewError = FRand() - 0.5;
					if ( StartError > 0 )
						StartError -= DeltaTime;
					else if ( MyBot.bNovice && (Level.TimeSeconds - MyBot.LastPainTime < 0.2) )
						StartError = MyBot.LastPainTime;
					else
						StartError = 0;
					AimSpot = 1.25 * Instigator.Target.Velocity + 0.75 * Instigator.Velocity;
					if ( Abs(AimSpot.Z) < 120 )
						AimSpot.Z *= 0.25;
					else
						AimSpot.Z *= 0.5;
					if ( Instigator.Target.Physics == PHYS_Falling )
						AimSpot = Instigator.Target.Location - 0.0007 * AimError * OldError * AimSpot;
					else
						AimSpot = Instigator.Target.Location - 0.0005 * AimError * OldError * AimSpot;
					if ( (Instigator.Physics == PHYS_Falling) && (Instigator.Velocity.Z > 0) )
						AimSpot = AimSpot - 0.0003 * AimError * OldError * AimSpot;

					AimStart = Instigator.Location + FireOffset.X * X + FireOffset.Y * Y + (1.2 * FireOffset.Z - 2) * Z; 
					if ( FastTrace(AimSpot - vect(0,0,10), AimStart) )
						AimSpot	= AimSpot - vect(0,0,10);
					GetAxes(Instigator.Rotation,X,Y,Z);
					AimRotation = Rotator(AimSpot - AimStart);
					AimRotation.Yaw = AimRotation.Yaw + (OldError + StartError) * 0.75 * aimerror;
					YawErr = (AimRotation.Yaw - (Instigator.Rotation.Yaw & 65535)) & 65535;
					if ( (YawErr > 3000) && (YawErr < 62535) )
					{
						if ( YawErr < 32768 )
							AimRotation.Yaw = Instigator.Rotation.Yaw + 3000;
						else
							AimRotation.Yaw = Instigator.Rotation.Yaw - 3000;
					}
				}
				else if ( Instigator.Target != None )
					AimRotation = Rotator(Instigator.Target.Location - Instigator.Location);
				else
					AimRotation = Instigator.ViewRotation;
				Instigator.ViewRotation = AimRotation;
				SetRotation(AimRotation);
			}
			else
			{
				AimRotation = Instigator.ViewRotation;
				SetRotation(AimRotation);
			}
			DrawOffset = Instigator.Weapon.CalcDrawOffset();
		}
		GetAxes(Instigator.ViewRotation,X,Y,Z);

		if ( bCenter )
		{
			FireOffset.Z = Default.FireOffset.Z * 1.5;
			FireOffset.Y = 0;
		}
		else 
		{
			FireOffset.Z = Default.FireOffset.Z;
			if ( bRight )
				FireOffset.Y = Default.FireOffset.Y;
			else
				FireOffset.Y = -1 * Default.FireOffset.Y;
		}
		if (Instigator.IsA('PlayerPawn')) {
			Origin = Instigator.Location + PlayerPawn(Instigator).EyeHeight * vect(0,0,1);
		} else {
			Origin = Instigator.Location + DrawOffset;
		}
		SetLocation(Instigator.Location + DrawOffset + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z);
	}
	else {
		GetAxes(Rotation,X,Y,Z);
		Origin = Location;
	}

	TraceBeam(Origin, X, DeltaTime);
}

simulated function TraceBeam(vector Origin, vector X, float DeltaTime)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, Momentum;
	local int BeamLen;
	local vector BeamJoin, BeamEnd;
	local PBolt Last;
	local bool bHit;

	CheckBeam(X, DeltaTime); // potentially lengthens the beam

	BeamLen = BeamLength();

	if (GetWeaponSettings().PulseCompensatePing) {
		HitActor = Instigator.TraceShot(HitLocation, HitNormal, Origin + BeamLen * BeamSize * X, Origin);
		// Clients only, for the beam's look: TraceShot does not run on other players there.
		// The server hits only where the shooter saw the target, not its live spot too.
		if (HitActor == None && Level.NetMode == NM_Client) {
			HitActor = Trace(HitLocation, HitNormal, Origin + BeamLen * BeamSize * X, Origin, true);
		}
	} else {
		HitActor = Trace(HitLocation, HitNormal, Origin + BeamLen * BeamSize * X, Origin, true);
	}
	
	if ( (HitActor != None)    && (HitActor != Instigator) && (HitActor.bProjTarget || (HitActor == Level) || (HitActor.bBlockActors && HitActor.bBlockPlayers)) )
	{
		if ( Level.Netmode != NM_Client )
		{
			if ( DamagedActor == None )
			{
				AccumulatedDamage = FMin(
					0.5 * (Level.TimeSeconds - LastHitTime),
					WImp.WeaponSettings.PulseBoltMaxAccumulate
				);
				if (Level.Game.GetPropertyText("NoLockdown") == "1")
					Momentum = vect(0,0,0);
				else
					Momentum = MomentumTransfer * X * AccumulatedDamage;
				HitActor.TakeDamage(
					CalcDamage(WImp.WeaponSettings.PulseBoltDPS * AccumulatedDamage),
					instigator,
					HitLocation,
					WImp.WeaponSettings.PulseBoltMomentum * Momentum,
					MyDamageType);
				AccumulatedDamage = 0;
			}
			else if ( DamagedActor != HitActor )
			{
				if (Level.Game.GetPropertyText("NoLockdown") == "1")
					Momentum = vect(0,0,0);
				else
					Momentum = MomentumTransfer * X * AccumulatedDamage;
				DamagedActor.TakeDamage(
					CalcDamage(WImp.WeaponSettings.PulseBoltDPS * AccumulatedDamage),
					instigator,
					HitLocation,
					WImp.WeaponSettings.PulseBoltMomentum * Momentum,
					MyDamageType);
				AccumulatedDamage = 0;
			}
			LastHitTime = Level.TimeSeconds;
			DamagedActor = HitActor;
			AccumulatedDamage += DeltaTime;
			if ( AccumulatedDamage > 0.22 )
			{
				if ( DamagedActor.IsA('Carcass') && (FRand() < 0.09) )
					AccumulatedDamage = 35/damage;
				if (int(Level.Game.GetPropertyText("NoLockdown")) > 0)
					Momentum = vect(0,0,0);
				else
					Momentum = MomentumTransfer * X * AccumulatedDamage;
				DamagedActor.TakeDamage(
					CalcDamage(WImp.WeaponSettings.PulseBoltDPS * AccumulatedDamage),
					instigator,
					HitLocation,
					WImp.WeaponSettings.PulseBoltMomentum * Momentum,
					MyDamageType);
				AccumulatedDamage = 0;
			}
		}
		if ( HitActor.bIsPawn && Pawn(HitActor).bIsPlayer )
		{
			if ( WallEffect != None )
				WallEffect.Destroy();
		}
		else if ( (WallEffect == None) || WallEffect.bDeleteMe )
			WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
		else if ( !WallEffect.IsA('PlasmaHit') )
		{
			WallEffect.Destroy();
			WallEffect = Spawn(class'PlasmaHit',,, HitLocation - 5 * X);
		}
		else
			WallEffect.SetLocation(HitLocation - 5 * X);

		if ( (WallEffect != None) && (Level.NetMode != NM_DedicatedServer) ) {
			DecalInterval -= DeltaTime;
			if (DecalInterval <= 0) {
				Spawn(ExplosionDecal,,,HitLocation,rotator(HitNormal));
				DecalInterval = FClamp(DecalInterval + DecalMinInterval, -DecalMinInterval, DecalMinInterval);
			}
		}

		bHit = true;
	} else {
		HitLocation = Location + BeamLen * BeamSize * X;

		if (DamagedActor != None && Level.Netmode != NM_Client) {
			if (Level.Game.GetPropertyText("NoLockdown") == "1")
				Momentum = vect(0,0,0);
			else
				Momentum = MomentumTransfer * X * AccumulatedDamage;

			DamagedActor.TakeDamage(
				CalcDamage(WImp.WeaponSettings.PulseBoltDPS * AccumulatedDamage),
				instigator,
				DamagedActor.Location - X * 1.2 * DamagedActor.CollisionRadius,
				WImp.WeaponSettings.PulseBoltMomentum * Momentum,
				MyDamageType);
			AccumulatedDamage = 0;
			DamagedActor = None;
		}

		if (BeamLen == MaxSegments) {
			if ( (WallEffect == None) || WallEffect.bDeleteMe )
				WallEffect = Spawn(class'PlasmaCap',,, HitLocation - 4 * X);
			else if ( WallEffect.IsA('PlasmaHit') )
			{
				WallEffect.Destroy();
				WallEffect = Spawn(class'PlasmaCap',,, HitLocation - 4 * X);
			}
			else
				WallEffect.SetLocation(HitLocation - 4 * X);
		}
	}

	// reposition beam
	// Drawing only, the hit stays on the eye line. The gun sits below the eyes,
	// so where the straight line from the gun to the end would cut through a
	// floor or wall that the eye line clears:
	// - seen from the shooter's eyes, the beam runs straight to the furthest
	//   point on the eye line the gun can see (IGPlus_BendPoint) and on to the
	//   end from there. That bend can't be seen from the eyes.
	// - watching someone else, the beam starts a little higher, between the
	//   gun and the eyes, just enough to clear it (IGPlus_RaisedStart).
	// Barely blocked, it barely bends or rises.
	BeamEnd = HitLocation;
	BeamJoin = HitLocation;
	if (Level.NetMode != NM_DedicatedServer) {
		if (bHit == false)
			BeamEnd = Origin + BeamLen * BeamSize * X; // the eye line was traced this far
		BeamJoin = BeamEnd;
		if (PlasmaBeam != None && FastTrace(BeamEnd - 4 * Normal(BeamEnd - Location), Location) == false) {
			if (IGPlus_SeenFromShooterEyes())
				BeamJoin = IGPlus_BendPoint(Origin, X, BeamEnd);
			else
				SetLocation(IGPlus_RaisedStart(Origin, BeamEnd)); // Tick puts it back at the gun
		}
	}
	SetRotation(rotator(BeamJoin - Location));
	if (bHit)
		CutDownBeam(VSize(BeamJoin - Location) + VSize(HitLocation - BeamJoin)); // potentially shortens beam
	if (ST_PBolt(PlasmaBeam) != none)
		ST_PBolt(PlasmaBeam).IGPlus_AimBeam(self, BeamJoin, BeamEnd);

	// Nothing hit: the cap sits at the end of the last segment.
	if (bHit == false && BeamLen == MaxSegments && WallEffect != None && Level.NetMode != NM_DedicatedServer) {
		Last = self;
		while (Last.PlasmaBeam != None)
			Last = Last.PlasmaBeam;
		WallEffect.SetLocation(Last.Location + (BeamSize - 4) * vector(Last.Rotation));
	}
}

// Client: is this screen looking out of the shooter's eyes (its own, or
// someone watching through them in first person)?
simulated function bool IGPlus_SeenFromShooterEyes() {
	local PlayerPawn P;

	if (IGPlus_bLocalPlayerFound == false) {
		IGPlus_bLocalPlayerFound = true;
		foreach AllActors(class'PlayerPawn', P)
			if (Viewport(P.Player) != None) {
				IGPlus_LocalPlayer = P;
				break;
			}
	}
	P = IGPlus_LocalPlayer;
	if (P == None || P.bBehindView)
		return false;
	return P.ViewTarget == Instigator || (P == Instigator && P.ViewTarget == None);
}

// The lowest start between the gun (Location) and the eyes (Origin) from
// which a straight line to End is clear. From the eyes it always is: the hit
// was traced from there.
simulated function vector IGPlus_RaisedStart(vector Origin, vector End) {
	local float Lo, Hi, Mid;
	local vector S;
	local int i;

	Lo = 0.0;
	Hi = 1.0;
	for (i = 0; i < 6; i++) {
		Mid = 0.5 * (Lo + Hi);
		S = Location + Mid * (Origin - Location);
		if (FastTrace(End - 4 * Normal(End - S), S))
			Hi = Mid;
		else
			Lo = Mid;
	}
	return Location + Hi * (Origin - Location);
}

// The furthest point on the eye line, between one segment from the gun
// (Location) and End, that the gun reaches in a clear straight line.
simulated function vector IGPlus_BendPoint(vector Origin, vector X, vector End) {
	local vector D;
	local float B, Disc, Lo, Hi, Mid;
	local int i;

	D = Origin - Location;
	B = D dot X;
	Disc = B * B - (D dot D) + BeamSize * BeamSize;
	if (Disc < 0.0)
		return End;
	Lo = Sqrt(Disc) - B;
	Hi = (End - Origin) dot X;
	if (Lo <= 0.0 || Lo >= Hi)
		return End;
	for (i = 0; i < 8; i++) {
		Mid = 0.5 * (Lo + Hi);
		if (FastTrace(Origin + Mid * X, Location))
			Lo = Mid;
		else
			Hi = Mid;
	}
	return Origin + Lo * X;
}

simulated function int BeamLength() {
	local int Result;
	local PBolt Beam;

	Result = 1;
	Beam = PlasmaBeam;

	while(Beam != none) {
		Result++;
		Beam = Beam.PlasmaBeam;
	}

	return Result;
}

// This function makes sure only even amounts of damage are applied
// Level.Game.ReduceDamage multiplies damage by 1.5
// The problem is that damage is applied on potentially every Tick, and rounding
// losses become significant at that frequency.
simulated function int CalcDamage(float Damage) {
	local float Temp;
	local int Result;

	Temp = Damage + DamageCarry;
	Result = int(Temp) & ~1;
	DamageCarry = Temp - float(Result);

	return Result;
}

simulated function CutDownBeam(float Length) {
	local PBolt Beam;

	Beam = self;

	while (Beam.PlasmaBeam != none && Length >= BeamSize) {
		Length -= BeamSize;
		Beam = Beam.PlasmaBeam;
	}
	ST_PBolt(Beam).GrowthAccumulator = 0.0;

	if (Beam.PlasmaBeam != none) {
		Beam.PlasmaBeam.Destroy();
		Beam.PlasmaBeam = none;
	}
}

defaultproperties
{
     StartError=0.500000
     SpriteAnim(0)=Texture'Botpack.Skins.sbolt0'
     SpriteAnim(1)=Texture'Botpack.Skins.sbolt1'
     SpriteAnim(2)=Texture'Botpack.Skins.sbolt2'
     SpriteAnim(3)=Texture'Botpack.Skins.sbolt3'
     SpriteAnim(4)=Texture'Botpack.Skins.sbolt4'
     RemoteRole=ROLE_SimulatedProxy
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=83
     LightSaturation=50
     LightRadius=5
     DecalMinInterval=0.02
}