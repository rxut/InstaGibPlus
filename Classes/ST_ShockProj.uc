class ST_ShockProj extends ShockProj;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

// For ShockProjectileTakeDamage
var float Health;

var PlayerPawn InstigatingPlayer;

var ST_ProjectileDummy Dummy;

// Client-side shock balls: the owner's client draws its own ball at its age
// since the owner fired, which is where the server tests the owner's beam.
var bool IGPlus_bOwnTimeline;
var bool IGPlus_bLocalBall;   // the owner's own copy, until the server's arrives
var float IGPlus_SpawnTS;     // client: when the local copy was fired
var float IGPlus_ComboTS;     // client: when a predicted combo hid this ball
var Pawn IGPlus_ComboBy;      // server: whose beam set off SuperExplosion
var float IGPlus_FireTS;      // server: the owner's move timestamp at the shot
var float IGPlus_FireTime;    // server: Level.TimeSeconds at the shot
var vector IGPlus_FireLoc;    // server: where the shot left from

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

simulated function PostBeginPlay() {
	local UTPure PureRef;
	local bbPlayer bbP;
	local WeaponSettingsRepl WS;

	if (Role == ROLE_Authority) {

		bbP = bbPlayer(Instigator);
		WS = GetWeaponSettings();

		// Every ball, whatever its owner's settings, so every beam is tested
		// where its shooter saw the ball (UTPure.CompensateFor tests an owner's
		// own client-side ball live instead).
		if (Level.NetMode != NM_Client && bbP != None && WS != None && WS.bEnablePingCompensation)
			PureRef = bbP.zzUTPure;
		if (bbP != None) {
			IGPlus_FireTS = bbP.CurrentTimeStamp;
			IGPlus_FireTime = Level.TimeSeconds;
			IGPlus_FireLoc = Location;
		}
		if (PureRef != None)
			PureRef.RegisterProjectile(self);

		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break; // Find master :D

		if (WImp != none && WImp.WeaponSettings != None && WImp.WeaponSettings.ShockProjectileTakeDamage) {
			Health = WImp.WeaponSettings.ShockProjectileHealth;
		}
	}

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay() {
	local PlayerPawn In;
	local bbPlayer bbP;

	bbP = bbPlayer(Instigator);

	super.PostNetBeginPlay();

	if (bbP != None && bbP.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations
		&& bbP.zzbDemoPlayback == false
	) {
		In = PlayerPawn(Instigator);
		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;
		if (InstigatingPlayer != none) {
			IGPlus_TakeOverLocalBall();
			return;
		}
	}
	Disable('Tick');
}

// Client: the server's copy of our ball has arrived. Carry on from our own
// copy (same shot, same age); without one, catch up by the round trip it is
// behind (sent a one-way after our shot, received a one-way after that).
simulated function IGPlus_TakeOverLocalBall() {
	local ST_ShockProj P, Mine;
	local vector Start, Delta;
	local bool bOldCollideWorld;

	IGPlus_bOwnTimeline = true;

	foreach AllActors(class'ST_ShockProj', P)
		if (P.IGPlus_bLocalBall && P.bDeleteMe == false && P.Instigator == Instigator
			&& (Mine == None || P.IGPlus_SpawnTS < Mine.IGPlus_SpawnTS))
			Mine = P;

	if (Mine == None) {
		Start = Location;
		Delta = Velocity * (0.001 * Level.TimeDilation * InstigatingPlayer.PlayerReplicationInfo.Ping);
		Move(Delta);
		if (VSize(Location - Start) < VSize(Delta) - 1.0)
			SetPhysics(PHYS_None); // reached a wall: stop there like our own copy
		return;
	}

	bOldCollideWorld = bCollideWorld;
	bCollideWorld = false;
	SetLocation(Mine.Location);
	bCollideWorld = bOldCollideWorld;
	Velocity = Mine.Velocity;
	if (Mine.Physics == PHYS_None)
		SetPhysics(PHYS_None);
	IGPlus_ComboTS = Mine.IGPlus_ComboTS;
	if (Mine.bHidden)
		IGPlus_HideBall();
	Mine.Destroy();
}

simulated event Tick(float Delta) {
	super.Tick(Delta);

	// A combo we drew that the server didn't make: the ball is still here.
	if (IGPlus_ComboTS > 0.0 && InstigatingPlayer != None
		&& Level.TimeSeconds - IGPlus_ComboTS > InstigatingPlayer.PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation + 0.25
	) {
		IGPlus_ComboTS = 0.0;
		IGPlus_ShowBall();
		bbPlayer(InstigatingPlayer).ClientDebugMessage("Shock combo: drawn here but the server missed, ball shown again");
	}
}

// The owner's own ball stops at a wall like the server's does, which is
// exploding there; its explosion reaches the owner a round trip later.
simulated function HitWall(vector HitNormal, actor Wall) {
	if (IGPlus_bOwnTimeline == false) {
		Super.HitWall(HitNormal, Wall);
		return;
	}
	SetPhysics(PHYS_None);
	if (ExplosionDecal != None && Level.NetMode != NM_DedicatedServer)
		Spawn(ExplosionDecal, self,, Location, rotator(HitNormal));
}

// Client: our own beam set this ball off. The server's ring for it is dropped
// when it gets here (IGPlus_OwnerComboRing), so this is the combo we see.
simulated function IGPlus_PredictCombo() {
	Spawn(class'ut_ComboRing',,'', Location, Instigator.ViewRotation);
	PlaySound(ExploSound,,20.0,,2000,0.6);
	IGPlus_ComboTS = Level.TimeSeconds;
	IGPlus_HideBall();
	if (bbPlayer(Instigator) != None) {
		bbPlayer(Instigator).IGPlus_PredComboTS = Level.TimeSeconds;
		bbPlayer(Instigator).IGPlus_PredComboLoc = Location;
		bbPlayer(Instigator).ClientDebugMessage("Shock combo: drawn on the beam's frame");
	}
}

simulated function IGPlus_HideBall() {
	bHidden = true;
	LightType = LT_None;
}

simulated function IGPlus_ShowBall() {
	bHidden = false;
	if (Level.bDropDetail == false)
		LightType = default.LightType;
}

// Server: where the owner's screen has this ball for the owner's move being
// processed: its age since the shot in the owner's own timestamps, along its
// straight path. Not the live ball, which is off by up to a server frame of
// packet timing. False when the owner's screen has it stopped at a wall it
// hasn't reached here yet: it is gone at that age.
function bool IGPlus_OwnerSeesBall(bbPlayer P, out vector Loc) {
	local float Live, Age;

	Loc = Location;
	// Input replication stamps a packet's inputs with its newest time: test live.
	if (P.IGPlus_EnableInputReplication)
		return true;

	Live = Level.TimeSeconds - IGPlus_FireTime;
	// ponytail: +-0.2s bounds how far a client clock can move the ball
	Age = FClamp(P.CurrentTimeStamp - IGPlus_FireTS, FMax(0.0, Live - 0.2), Live + 0.2);
	Loc = IGPlus_FireLoc + Velocity * Age;
	return Age <= Live || FastTrace(Loc, Location);
}

// Server: the owner's own beam, with the conditions under which the owner's
// client draws its own combos (ST_ShockRifle.ClientTraceFire).
function bool IGPlus_OwnerMayDrawCombo() {
	local bbPlayer P;

	P = bbPlayer(Instigator);
	return P != None && IGPlus_ComboBy == P && P.RemoteRole == ROLE_AutonomousProxy
		&& GetWeaponSettings() != None && GetWeaponSettings().bEnablePingCompensation
		&& P.ClientWeaponSettingsData.bShockBeamUseClientSideAnimations
		&& P.ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations;
}

function SuperExplosion() {
	local float ComboDamage, ComboRadius, ComboMomentum;
	local Actor Ring;

	ComboDamage = WImp.WeaponSettings.ShockComboDamage;
	ComboRadius = WImp.WeaponSettings.ShockComboHurtRadius;
	ComboMomentum = WImp.WeaponSettings.ShockComboMomentum * MomentumTransfer * 2;

	// Register explosion for translocator simulation tracking
	IGPlus_WeaponImplementationBase(WImp).RegisterExplosion(
		Location,
		ComboRadius,
		ComboDamage,
		ComboMomentum,
		Instigator
	);

	if (WImp.WeaponSettings.bEnableEnhancedSplashShockCombo) {
		WImp.EnhancedHurtRadius(
			self,
			ComboDamage,
			ComboRadius,
			MyDamageType,
			ComboMomentum,
			Location);
	} else {
		HurtRadius(
			ComboDamage,
			ComboRadius,
			MyDamageType,
			ComboMomentum,
			Location);
	}

	if (IGPlus_OwnerMayDrawCombo()) {
		// The owner's client plays the sound itself if it didn't draw this one.
		Ring = Spawn(class'IGPlus_OwnerComboRing', Instigator,'', Location, Instigator.ViewRotation);
		if (Ring != None)
			Ring.PlayOwnedSound(ExploSound,,20.0,,2000,0.6);
	} else {
		Spawn(Class'ut_ComboRing',,'',Location, Instigator.ViewRotation);
		PlaySound(ExploSound,,20.0,,2000,0.6);
	}

	Destroy();
}

function Explode(vector HitLocation,vector HitNormal) {
	PlaySound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());
	if (WImp.WeaponSettings.bEnableEnhancedSplashShockProjectile) {
		WImp.EnhancedHurtRadius(
			self,
			WImp.WeaponSettings.ShockProjectileDamage,
			WImp.WeaponSettings.ShockProjectileHurtRadius,
			MyDamageType,
			WImp.WeaponSettings.ShockProjectileMomentum * MomentumTransfer,
			Location);
	} else {
		HurtRadius(
			WImp.WeaponSettings.ShockProjectileDamage,
			WImp.WeaponSettings.ShockProjectileHurtRadius,
			MyDamageType,
			WImp.WeaponSettings.ShockProjectileMomentum * MomentumTransfer,
			Location);
	}
	if (WImp.WeaponSettings.ShockProjectileDamage > 60)
		Spawn(class'ut_RingExplosion3',,, HitLocation+HitNormal*8,rotator(HitNormal));
	else
		Spawn(class'ut_RingExplosion',,, HitLocation+HitNormal*8,rotator(Velocity));		

	Destroy();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
	if (WImp.WeaponSettings.ShockProjectileTakeDamage == false)
		return;

	if (DamageType == 'Pulsed'|| DamageType == 'Corroded') {
		Health -= Damage;
		if (Health <= 0) {
			Spawn(class'ut_RingExplosion',,, Location + Momentum * 0.1, rotator(Momentum));
			Destroy();
		}
	}
}

defaultproperties {
}
