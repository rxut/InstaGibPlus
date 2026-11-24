class WeaponSettingsRepl extends Actor;

var float HeadHalfHeight;
var float HeadRadius;

var float WarheadSelectTime;
var float WarheadDownTime;

var float SniperSelectTime;
var float SniperDownTime;
var float SniperDamage;
var float SniperHeadshotDamage;
var float SniperMomentum;
var float SniperHeadshotMomentum;
var float SniperReloadTime;
var bool  SniperUseReducedHitbox;

var float EightballSelectTime;
var float EightballDownTime;
var float RocketHurtRadius;
var float RocketMomentum;
var float RocketSpreadSpacingDegrees;
var float RocketSpeed;
var bool  RocketCompensatePing;
var bool  bEnableEnhancedSplashRockets; // predicted self-knockback mirrors the server's splash
var bool  bEnableEnhancedSplashFlakSlug;
var bool  bEnableEnhancedSplashShockProjectile;
var bool  bEnableEnhancedSplashRipperSecondary;
var bool  bEnableEnhancedSplashShockCombo; // predicted disc push from our own combo

var float FlakSelectTime;
var float FlakPostSelectTime;
var float FlakDownTime;
var bool  FlakChunkRandomSpread;
var float FlakChunkRandomSpreadSize;
var float FlakSlugHurtRadius;
var float FlakSlugMomentum;
var bool  FlakCompensatePing;

var float RipperSelectTime;
var float RipperDownTime;
var float RipperSecondaryHurtRadius;
var float RipperSecondaryMomentum;
var bool  RipperCompensatePing;

var float MinigunSelectTime;
var float MinigunDownTime;
var float MinigunUnwindTime;

var float PulseSelectTime;
var float PulseDownTime;
var float PulseSphereSpeed;
var float PulseSphereFireRate;
var float PulseSphereCollisionRadius;
var float PulseSphereCollisionHeight;
var float PulseBoltDPS;
var float PulseBoltMomentum;
var bool  PulseCompensatePing;

var float ShockSelectTime;
var float ShockDownTime;
var float ShockBeamDamage;
var float ShockBeamMomentum;
var bool  ShockBeamUseReducedHitbox;

var float ShockProjectileHurtRadius;
var float ShockProjectileMomentum;
var bool  ShockProjectileBlockBullets;
var bool  ShockProjectileBlockFlakSlug;
var float ShockComboMomentum;
var float ShockComboHurtRadius;

var float BioSelectTime;
var float BioDownTime;
var bool  BioCompensatePing;

var float EnforcerSelectTime;
var float EnforcerDownTime;
var float EnforcerReloadTime;
var float EnforcerReloadTimeAlt;
var float EnforcerReloadTimeRepeat;
var bool  EnforcerUseReducedHitbox;

var bool  EnforcerAllowDouble;
var float EnforcerShotOffsetDouble;
var float EnforcerReloadTimeDouble;
var float EnforcerReloadTimeAltDouble;
var float EnforcerReloadTimeRepeatDouble;

var float HammerSelectTime;
var float HammerDownTime;
var float HammerSelfMomentum;

var float TranslocatorSelectTime;
var float TranslocatorOutSelectTime;
var float TranslocatorDownTime;
var float TranslocatorHealth;
var bool  TranslocatorCompensatePing;


var bool  bEnablePingCompensation;

var bool  bEnableTrades;
var bool  bEnableFireTimeOrder;
var int   PreciseRewindTimeMaxDeviationMs;

var int   PingCompensationMax;

var bool  bEnableAnimationAdaptiveHeadHitbox;






replication {
	reliable if (Role == ROLE_Authority)
		HeadHalfHeight,
		HeadRadius,
		
		WarheadSelectTime,
		WarheadDownTime,

		SniperSelectTime,
		SniperDownTime,
		SniperDamage,
		SniperHeadshotDamage,
		SniperMomentum,
		SniperHeadshotMomentum,
		SniperReloadTime,
		SniperUseReducedHitbox,

		EightballSelectTime,
		EightballDownTime,
		RocketHurtRadius,
		RocketMomentum,
		RocketSpreadSpacingDegrees,
		RocketSpeed,
		RocketCompensatePing,
		bEnableEnhancedSplashRockets,
		bEnableEnhancedSplashFlakSlug,
		bEnableEnhancedSplashShockProjectile,
		bEnableEnhancedSplashRipperSecondary,
		bEnableEnhancedSplashShockCombo,
		FlakSelectTime,
		FlakPostSelectTime,
		FlakDownTime,
		FlakChunkRandomSpread,
		FlakChunkRandomSpreadSize,
		FlakSlugHurtRadius,
		FlakSlugMomentum,
		FlakCompensatePing,

		RipperSelectTime,
		RipperDownTime,
		RipperSecondaryHurtRadius,
		RipperSecondaryMomentum,
		RipperCompensatePing,

		MinigunSelectTime,
		MinigunDownTime,
		MinigunUnwindTime,

		PulseSelectTime,
		PulseDownTime,
		PulseSphereSpeed,
		PulseSphereFireRate,
		PulseSphereCollisionRadius,
		PulseSphereCollisionHeight,
		PulseBoltDPS,
		PulseBoltMomentum,
		PulseCompensatePing,

		ShockSelectTime,
		ShockDownTime,
		ShockBeamDamage,
		ShockBeamMomentum,
		ShockBeamUseReducedHitbox,
		ShockProjectileHurtRadius,
		ShockProjectileMomentum,
		ShockProjectileBlockBullets,
		ShockProjectileBlockFlakSlug,
		ShockComboMomentum,
		ShockComboHurtRadius,

		BioSelectTime,
		BioDownTime,
		BioCompensatePing,

		EnforcerSelectTime,
		EnforcerDownTime,
		EnforcerReloadTime,
		EnforcerReloadTimeAlt,
		EnforcerReloadTimeRepeat,
		EnforcerUseReducedHitbox,

		EnforcerAllowDouble,
		EnforcerShotOffsetDouble,
		EnforcerReloadTimeDouble,
		EnforcerReloadTimeAltDouble,
		EnforcerReloadTimeRepeatDouble,

		HammerSelectTime,
		HammerDownTime,
		HammerSelfMomentum,

		TranslocatorSelectTime,
		TranslocatorOutSelectTime,
		TranslocatorDownTime,
		TranslocatorHealth,
		TranslocatorCompensatePing,



		


		bEnablePingCompensation,
		bEnableTrades,
		bEnableFireTimeOrder,
		PreciseRewindTimeMaxDeviationMs,
		PingCompensationMax,
		bEnableAnimationAdaptiveHeadHitbox;
}

simulated final function float WarheadSelectAnimSpeed() {
	if (WarheadSelectTime > 0.0)
		return FMin(100.0, default.WarheadSelectTime / WarheadSelectTime);
	return 100.0;
}

simulated final function float WarheadDownAnimSpeed() {
	if (WarheadDownTime > 0.0)
		return FMin(100.0, default.WarheadDownTime / WarheadDownTime);
	return 100.0;
}

simulated final function float SniperSelectAnimSpeed() {
	if (SniperSelectTime > 0.0)
		return FMin(100.0, default.SniperSelectTime / SniperSelectTime);
	return 100.0;
}

simulated final function float SniperDownAnimSpeed() {
	if (SniperDownTime > 0.0)
		return FMin(100.0, default.SniperDownTime / SniperDownTime);
	return 100.0;
}

simulated final function float SniperReloadAnimSpeed() {
	if (SniperReloadTime > 0.0)
		return FMin(100.0, default.SniperReloadTime / SniperReloadTime);
	return 100.0;
}

simulated final function float EightballSelectAnimSpeed() {
	if (EightballSelectTime > 0.0)
		return FMin(100.0, default.EightballSelectTime / EightballSelectTime);
	return 100.0;
}

simulated final function float EightballDownAnimSpeed() {
	if (EightballDownTime > 0.0)
		return FMin(100.0, default.EightballDownTime / EightballDownTime);
	return 100.0;
}

simulated final function float FlakSelectAnimSpeed() {
	if (FlakSelectTime > 0.0)
		return FMin(100.0, default.FlakSelectTime / FlakSelectTime);
	return 100.0;
}

simulated final function float FlakPostSelectAnimSpeed() {
	if (FlakPostSelectTime > 0.0)
		return FMin(100.0, 1.3 * default.FlakPostSelectTime / FlakPostSelectTime);
	return 100.0;
}

simulated final function float FlakDownAnimSpeed() {
	if (FlakDownTime > 0.0)
		return FMin(100.0, default.FlakDownTime / FlakDownTime);
	return 100.0;
}

simulated final function float RipperSelectAnimSpeed() {
	if (RipperSelectTime > 0.0)
		return FMin(100.0, default.RipperSelectTime / RipperSelectTime);
	return 100.0;
}

simulated final function float RipperDownAnimSpeed() {
	if (RipperDownTime > 0.0)
		return FMin(100.0, default.RipperDownTime / RipperDownTime);
	return 100.0;
}

simulated final function float MinigunSelectAnimSpeed() {
	if (MinigunSelectTime > 0.0)
		return FMin(100.0, default.MinigunSelectTime / MinigunSelectTime);
	return 100.0;
}

simulated final function float MinigunDownAnimSpeed() {
	if (MinigunDownTime > 0.0)
		return FMin(100.0, default.MinigunDownTime / MinigunDownTime);
	return 100.0;
}

simulated final function float MinigunUnwindAnimSpeed() {
	if (MinigunUnwindTime > 0.0)
		return FMin(100.0, 1.5 * default.MinigunUnwindTime / MinigunUnwindTime);
	return 100.0;
}

simulated final function float PulseSelectAnimSpeed() {
	if (PulseSelectTime > 0.0)
		return FMin(100.0, default.PulseSelectTime / PulseSelectTime);
	return 100.0;
}

simulated final function float PulseFiringAnimSpeed() {
	if (PulseSphereFireRate > 0.0)
		return FMin(100.0, default.PulseSphereFireRate / PulseSphereFireRate);
	return 100.0;
}

simulated final function float ShockSelectAnimSpeed() {
	if (ShockSelectTime > 0.0)
		return FMin(100.0, default.ShockSelectTime / ShockSelectTime);
	return 100.0;
}

simulated final function float ShockDownAnimSpeed() {
	if (ShockDownTime > 0.0)
		return FMin(100.0, default.ShockDownTime / ShockDownTime);
	return 100.0;
}

simulated final function float BioSelectAnimSpeed() {
	if (BioSelectTime > 0.0)
		return FMin(100.0, default.BioSelectTime / BioSelectTime);
	return 100.0;
}

simulated final function float BioDownAnimSpeed() {
	if (BioDownTime > 0.0)
		return FMin(100.0, default.BioDownTime / BioDownTime);
	return 100.0;
}

simulated final function float EnforcerSelectAnimSpeed() {
	if (EnforcerSelectTime > 0.0)
		return FMin(100.0, default.EnforcerSelectTime / EnforcerSelectTime);
	return 100.0;
}

simulated final function float EnforcerDownAnimSpeed() {
	if (EnforcerDownTime > 0.0)
		return FMin(100.0, default.EnforcerDownTime / EnforcerDownTime);
	return 100.0;
}

simulated final function float EnforcerReloadAnimSpeed() {
	if (EnforcerReloadTime > 0.0)
		return FMin(100.0, default.EnforcerReloadTime / EnforcerReloadTime);
	return 100.0;
}

simulated final function float EnforcerReloadAltAnimSpeed() {
	if (EnforcerReloadTimeAlt > 0.0)
		return FMin(100.0, default.EnforcerReloadTimeAlt / EnforcerReloadTimeAlt);
	return 100.0;
}

simulated final function float EnforcerReloadRepeatAnimSpeed() {
	if (EnforcerReloadTimeRepeat > 0.0)
		return FMin(100.0, default.EnforcerReloadTimeRepeat / EnforcerReloadTimeRepeat);
	return 100.0;
}

simulated final function float EnforcerReloadDoubleAnimSpeed() {
	if (EnforcerReloadTimeDouble > 0.0)
		return FMin(100.0, default.EnforcerReloadTimeDouble / EnforcerReloadTimeDouble);
	return 100.0;
}

simulated final function float EnforcerReloadAltDoubleAnimSpeed() {
	if (EnforcerReloadTimeAltDouble > 0.0)
		return FMin(100.0, default.EnforcerReloadTimeAltDouble / EnforcerReloadTimeAltDouble);
	return 100.0;
}

simulated final function float EnforcerReloadRepeatDoubleAnimSpeed() {
	if (EnforcerReloadTimeRepeatDouble > 0.0)
		return FMin(100.0, default.EnforcerReloadTimeRepeatDouble / EnforcerReloadTimeRepeatDouble);
	return 100.0;
}

simulated final function float HammerSelectAnimSpeed() {
	if (HammerSelectTime > 0.0)
		return FMin(100.0, default.HammerSelectTime / HammerSelectTime);
	return 100.0;
}

simulated final function float HammerDownAnimSpeed() {
	if (HammerDownTime > 0.0)
		return FMin(100.0, default.HammerDownTime / HammerDownTime);
	return 100.0;
}

simulated final function float TranslocatorSelectAnimSpeed() {
	if (TranslocatorSelectTime > 0.0)
		return FMin(100.0, 1.1 * default.TranslocatorSelectTime / TranslocatorSelectTime);
	return 100.0;
}

simulated final function float TranslocatorDownAnimSpeed() {
	if (TranslocatorDownTime > 0.0)
		return FMin(100.0, 1.1 * default.TranslocatorDownTime / TranslocatorDownTime);
	return 100.0;
}

function InitFromWeaponSettings(WeaponSettings S) {
	HeadHalfHeight = S.HeadHalfHeight;
	HeadRadius = S.HeadRadius;

	WarheadSelectTime = S.WarheadSelectTime;
	WarheadDownTime = S.WarheadDownTime;

	SniperSelectTime = S.SniperSelectTime;
	SniperDownTime = S.SniperDownTime;
	SniperDamage = S.SniperDamage;
	SniperHeadshotDamage = S.SniperHeadshotDamage;
	SniperMomentum = S.SniperMomentum;
	SniperHeadshotMomentum = S.SniperHeadshotMomentum;
	SniperReloadTime = S.SniperReloadTime;
	SniperUseReducedHitbox = S.SniperUseReducedHitbox;

	EightballSelectTime = S.EightballSelectTime;
	EightballDownTime = S.EightballDownTime;
	RocketHurtRadius = S.RocketHurtRadius;
	RocketMomentum = S.RocketMomentum;
	RocketSpreadSpacingDegrees = S.RocketSpreadSpacingDegrees;
	RocketSpeed = S.RocketSpeed;
	RocketCompensatePing = S.RocketCompensatePing;
	bEnableEnhancedSplashRockets = S.bEnableEnhancedSplashRockets;
	bEnableEnhancedSplashFlakSlug = S.bEnableEnhancedSplashFlakSlug;
	bEnableEnhancedSplashShockProjectile = S.bEnableEnhancedSplashShockProjectile;
	bEnableEnhancedSplashRipperSecondary = S.bEnableEnhancedSplashRipperSecondary;
	bEnableEnhancedSplashShockCombo = S.bEnableEnhancedSplashShockCombo;

	FlakSelectTime = S.FlakSelectTime;
	FlakPostSelectTime = S.FlakPostSelectTime;
	FlakDownTime = S.FlakDownTime;
	FlakChunkRandomSpread = S.FlakChunkRandomSpread;
	FlakChunkRandomSpreadSize = S.FlakChunkRandomSpreadSize;
	FlakSlugHurtRadius = S.FlakSlugHurtRadius;
	FlakSlugMomentum = S.FlakSlugMomentum;
	FlakCompensatePing = S.FlakCompensatePing;

	RipperSelectTime = S.RipperSelectTime;
	RipperDownTime = S.RipperDownTime;
	RipperSecondaryHurtRadius = S.RipperSecondaryHurtRadius;
	RipperSecondaryMomentum = S.RipperSecondaryMomentum;
	RipperCompensatePing = S.RipperCompensatePing;

	MinigunSelectTime = S.MinigunSelectTime;
	MinigunDownTime = S.MinigunDownTime;
	MinigunUnwindTime = S.MinigunUnwindTime;

	PulseSelectTime = S.PulseSelectTime;
	PulseDownTime = S.PulseDownTime;
	PulseSphereSpeed = S.PulseSphereSpeed;
	PulseSphereFireRate = S.PulseSphereFireRate;
	PulseSphereCollisionRadius = S.PulseSphereCollisionRadius;
	PulseSphereCollisionHeight = S.PulseSphereCollisionHeight;
	PulseBoltDPS = S.PulseBoltDPS;
	PulseBoltMomentum = S.PulseBoltMomentum;
	PulseCompensatePing = S.PulseCompensatePing;

	ShockSelectTime = S.ShockSelectTime;
	ShockDownTime = S.ShockDownTime;
	ShockBeamDamage = S.ShockBeamDamage;
	ShockBeamMomentum = S.ShockBeamMomentum;
	ShockBeamUseReducedHitbox = S.ShockBeamUseReducedHitbox;
	ShockProjectileHurtRadius = S.ShockProjectileHurtRadius;
	ShockProjectileMomentum = S.ShockProjectileMomentum;
	ShockProjectileBlockBullets = S.ShockProjectileBlockBullets;
	ShockProjectileBlockFlakSlug = S.ShockProjectileBlockFlakSlug;
	ShockComboMomentum = S.ShockComboMomentum;
	ShockComboHurtRadius = S.ShockComboHurtRadius;

	BioSelectTime = S.BioSelectTime;
	BioDownTime = S.BioDownTime;
	BioCompensatePing = S.BioCompensatePing;

	EnforcerSelectTime = S.EnforcerSelectTime;
	EnforcerDownTime = S.EnforcerDownTime;
	EnforcerReloadTime = S.EnforcerReloadTime;
	EnforcerReloadTimeAlt = S.EnforcerReloadTimeAlt;
	EnforcerReloadTimeRepeat = S.EnforcerReloadTimeRepeat;
	EnforcerUseReducedHitbox = S.EnforcerUseReducedHitbox;

	EnforcerAllowDouble = S.EnforcerAllowDouble;
	EnforcerShotOffsetDouble = S.EnforcerShotOffsetDouble;
	EnforcerReloadTimeDouble = S.EnforcerReloadTimeDouble;
	EnforcerReloadTimeAltDouble = S.EnforcerReloadTimeAltDouble;
	EnforcerReloadTimeRepeatDouble = S.EnforcerReloadTimeRepeatDouble;
	
	HammerSelectTime = S.HammerSelectTime;
	HammerDownTime = S.HammerDownTime;
	HammerSelfMomentum = S.HammerSelfMomentum;

	TranslocatorSelectTime = S.TranslocatorSelectTime;
	TranslocatorOutSelectTime = S.TranslocatorOutSelectTime;
	TranslocatorDownTime = S.TranslocatorDownTime;
	TranslocatorHealth = S.TranslocatorHealth;
	TranslocatorCompensatePing = S.TranslocatorCompensatePing;






	bEnablePingCompensation = S.bEnablePingCompensation;

	bEnableTrades = S.bEnableTrades;
	bEnableFireTimeOrder = S.bEnableFireTimeOrder;
	PreciseRewindTimeMaxDeviationMs = S.PreciseRewindTimeMaxDeviationMs;

	PingCompensationMax = S.PingCompensationMax;

	bEnableAnimationAdaptiveHeadHitbox = S.bEnableAnimationAdaptiveHeadHitbox;

	IGPlus_ApplyTickInterpLocks();
}

// Tick Interpolation draws the other players later and reports what the
// screen drew with every shot. Without ping compensation and Precise Rewind
// Time the server tests the present instead, so both are on while it is,
// whatever the weapon section says. The ini keeps its own values. The server
// settings load after the weapon settings at map start: UTPure.PostBeginPlay
// calls InitFromWeaponSettings again, and so does a change of either.
function IGPlus_ApplyTickInterpLocks() {
	local UTPure Pure;

	foreach AllActors(class'UTPure', Pure)
		break;
	if (Pure == None || Pure.Settings == None || Pure.Settings.TickInterpolationActive() == false)
		return;
	bEnablePingCompensation = true;
}

defaultproperties
{
	RemoteRole=ROLE_DumbProxy
	bHidden=True
	bAlwaysRelevant=True
	DrawType=DT_None

	HeadHalfHeight=7.5
	HeadRadius=11.0

	WarheadSelectTime=0.5
	WarheadDownTime=0.233333

	SniperSelectTime=0.607143
	SniperDownTime=0.233333
	SniperDamage=45
	SniperHeadshotDamage=100
	SniperMomentum=1.0
	SniperHeadshotMomentum=1.0
	SniperReloadTime=0.6666666666
	SniperUseReducedHitbox=False

	EightballSelectTime=0.606061
	EightballDownTime=0.366667
	RocketHurtRadius=220
	RocketMomentum=1.0
	RocketSpreadSpacingDegrees=3.6
	RocketSpeed=900.0
	RocketCompensatePing=True

	FlakSelectTime=0.625
	FlakPostSelectTime=0.384615
	FlakDownTime=0.333333
	FlakChunkRandomSpread=True
	FlakChunkRandomSpreadSize=2000
	FlakSlugHurtRadius=150
	FlakSlugMomentum=1.0
	FlakCompensatePing=True

	RipperSelectTime=0.75
	RipperDownTime=0.2
	RipperSecondaryHurtRadius=180
	RipperSecondaryMomentum=1.0
	RipperCompensatePing=True

	MinigunSelectTime=0.555556
	MinigunDownTime=0.333333
	MinigunUnwindTime=0.866666

	PulseSelectTime=0.444444
	PulseDownTime=0.26
	PulseSphereFireRate=0.18
	PulseSphereSpeed=1450.0
	PulseSphereCollisionRadius=6.0
	PulseSphereCollisionHeight=6.0
	PulseBoltDPS=72
	PulseBoltMomentum=1.0
	PulseCompensatePing=True

	ShockSelectTime=0.5
	ShockDownTime=0.259259
	ShockBeamDamage=40
	ShockBeamMomentum=1.0
	ShockBeamUseReducedHitbox=False
	ShockProjectileHurtRadius=70
	ShockProjectileMomentum=1.0
	ShockProjectileBlockBullets=True
	ShockProjectileBlockFlakSlug=True
	ShockComboHurtRadius=250
	ShockComboMomentum=1.0

	BioSelectTime=0.488889
	BioDownTime=0.333333
	BioCompensatePing=True

	EnforcerSelectTime=0.777778
	EnforcerDownTime=0.266667
	EnforcerReloadTime=0.27
	EnforcerReloadTimeAlt=0.26
	EnforcerReloadTimeRepeat=0.266667
	EnforcerUseReducedHitbox=False

	EnforcerAllowDouble=True
	EnforcerShotOffsetDouble=0.2
	EnforcerReloadTimeDouble=0.27
	EnforcerReloadTimeAltDouble=0.26
	EnforcerReloadTimeRepeatDouble=0.266667

	HammerSelectTime=0.566667
	HammerDownTime=0.166667
	HammerSelfMomentum=1.0

	TranslocatorSelectTime=0.363636
	TranslocatorOutSelectTime=0.27
	TranslocatorDownTime=0.212121
	TranslocatorHealth=65.0
	TranslocatorCompensatePing=False






	bEnablePingCompensation=True

	bEnableTrades=False
	bEnableFireTimeOrder=False
	PreciseRewindTimeMaxDeviationMs=60
	
	PingCompensationMax=200

	bEnableAnimationAdaptiveHeadHitbox=False
}
