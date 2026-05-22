class IGPlus_WeaponSettingsContent extends UMenuPageWindow;

enum EEditControlType {
	ECT_Text,
	ECT_Integer,
	ECT_Real
};

var UWindowLabelControl Lbl_Header;
var localized string HeaderText;
var UWindowLabelControl Lbl_Status;
var localized string StatusAdminText;
var localized string StatusLoginText;
var localized string StatusLoadingText;
var localized string StatusLoginPendingText;
var UWindowLabelControl Lbl_MoreInformation;
var localized string MoreInformationText;
var UWindowLabelControl Lbl_Login;
var localized string LoginText;
var IGPlus_ComboBox Cmb_AdminPassword;
var localized string AdminPasswordText;
var localized string AdminPasswordHelp;
var IGPlus_Button Btn_DeletePassword;
var localized string DeletePasswordButtonText;
var localized string DeletePasswordButtonHelp;
var IGPlus_Button Btn_AdminAuth;
var localized string LoginButtonText;
var localized string LoginButtonHelp;
var localized string LogoutButtonText;
var localized string LogoutButtonHelp;
var localized string LoginRequiredText;

var UWindowLabelControl Lbl_EnhancedSplash;
var localized string EnhancedSplashText;
var UWindowCheckbox Chk_bEnableEnhancedSplashBio;
var localized string bEnableEnhancedSplashBioText;
var localized string bEnableEnhancedSplashBioHelp;
var UWindowCheckbox Chk_bEnableEnhancedSplashShockCombo;
var localized string bEnableEnhancedSplashShockComboText;
var localized string bEnableEnhancedSplashShockComboHelp;
var UWindowCheckbox Chk_bEnableEnhancedSplashShockProjectile;
var localized string bEnableEnhancedSplashShockProjectileText;
var localized string bEnableEnhancedSplashShockProjectileHelp;
var UWindowCheckbox Chk_bEnableEnhancedSplashRipperSecondary;
var localized string bEnableEnhancedSplashRipperSecondaryText;
var localized string bEnableEnhancedSplashRipperSecondaryHelp;
var UWindowCheckbox Chk_bEnableEnhancedSplashFlakSlug;
var localized string bEnableEnhancedSplashFlakSlugText;
var localized string bEnableEnhancedSplashFlakSlugHelp;
var UWindowCheckbox Chk_bEnableEnhancedSplashRockets;
var localized string bEnableEnhancedSplashRocketsText;
var localized string bEnableEnhancedSplashRocketsHelp;
var UWindowCheckbox Chk_bEnhancedSplashIgnoreStationaryPawns;
var localized string bEnhancedSplashIgnoreStationaryPawnsText;
var localized string bEnhancedSplashIgnoreStationaryPawnsHelp;
var IGPlus_EditControl Edit_SplashMaxDiffraction;
var localized string SplashMaxDiffractionText;
var localized string SplashMaxDiffractionHelp;
var IGPlus_EditControl Edit_SplashMinDiffractionDistance;
var localized string SplashMinDiffractionDistanceText;
var localized string SplashMinDiffractionDistanceHelp;
var IGPlus_EditControl Edit_SplashWraparoundRadiusScale;
var localized string SplashWraparoundRadiusScaleText;
var localized string SplashWraparoundRadiusScaleHelp;

var UWindowLabelControl Lbl_Global;
var localized string GlobalText;
var IGPlus_EditControl Edit_HeadHalfHeight;
var localized string HeadHalfHeightText;
var localized string HeadHalfHeightHelp;
var IGPlus_EditControl Edit_HeadRadius;
var localized string HeadRadiusText;
var localized string HeadRadiusHelp;
var UWindowCheckbox Chk_bEnablePingCompensation;
var localized string bEnablePingCompensationText;
var localized string bEnablePingCompensationHelp;
var UWindowCheckbox Chk_bEnableSubTickCompensation;
var localized string bEnableSubTickCompensationText;
var localized string bEnableSubTickCompensationHelp;
var IGPlus_EditControl Edit_PingCompensationMax;
var localized string PingCompensationMaxText;
var localized string PingCompensationMaxHelp;
var UWindowCheckbox Chk_bEnableAnimationAdaptiveHeadHitbox;
var localized string bEnableAnimationAdaptiveHeadHitboxText;
var localized string bEnableAnimationAdaptiveHeadHitboxHelp;

var UWindowLabelControl Lbl_Pickups;
var localized string PickupsText;
var IGPlus_EditControl Edit_InvisibilityDuration;
var localized string InvisibilityDurationText;
var localized string InvisibilityDurationHelp;
var IGPlus_EditControl Edit_ShieldBeltCharge;
var localized string ShieldBeltChargeText;
var localized string ShieldBeltChargeHelp;
var IGPlus_EditControl Edit_ArmorCharge;
var localized string ArmorChargeText;
var localized string ArmorChargeHelp;
var IGPlus_EditControl Edit_ThighPadsCharge;
var localized string ThighPadsChargeText;
var localized string ThighPadsChargeHelp;
var IGPlus_EditControl Edit_HealthPackHealingAmount;
var localized string HealthPackHealingAmountText;
var localized string HealthPackHealingAmountHelp;

var UWindowLabelControl Lbl_Warhead;
var localized string WarheadText;
var IGPlus_EditControl Edit_WarheadSelectTime;
var localized string WarheadSelectTimeText;
var localized string WarheadSelectTimeHelp;
var IGPlus_EditControl Edit_WarheadDownTime;
var localized string WarheadDownTimeText;
var localized string WarheadDownTimeHelp;

var UWindowLabelControl Lbl_Sniper;
var localized string SniperText;
var IGPlus_EditControl Edit_SniperSelectTime;
var localized string SniperSelectTimeText;
var localized string SniperSelectTimeHelp;
var IGPlus_EditControl Edit_SniperDownTime;
var localized string SniperDownTimeText;
var localized string SniperDownTimeHelp;
var IGPlus_EditControl Edit_SniperDamage;
var localized string SniperDamageText;
var localized string SniperDamageHelp;
var IGPlus_EditControl Edit_SniperHeadshotDamage;
var localized string SniperHeadshotDamageText;
var localized string SniperHeadshotDamageHelp;
var IGPlus_EditControl Edit_SniperMomentum;
var localized string SniperMomentumText;
var localized string SniperMomentumHelp;
var IGPlus_EditControl Edit_SniperHeadshotMomentum;
var localized string SniperHeadshotMomentumText;
var localized string SniperHeadshotMomentumHelp;
var IGPlus_EditControl Edit_SniperReloadTime;
var localized string SniperReloadTimeText;
var localized string SniperReloadTimeHelp;
var UWindowCheckbox Chk_SniperUseReducedHitbox;
var localized string SniperUseReducedHitboxText;
var localized string SniperUseReducedHitboxHelp;

var UWindowLabelControl Lbl_Rocket;
var localized string RocketText;
var IGPlus_EditControl Edit_EightballSelectTime;
var localized string EightballSelectTimeText;
var localized string EightballSelectTimeHelp;
var IGPlus_EditControl Edit_EightballDownTime;
var localized string EightballDownTimeText;
var localized string EightballDownTimeHelp;
var IGPlus_EditControl Edit_RocketDamage;
var localized string RocketDamageText;
var localized string RocketDamageHelp;
var IGPlus_EditControl Edit_RocketSelfDamage;
var localized string RocketSelfDamageText;
var localized string RocketSelfDamageHelp;
var IGPlus_EditControl Edit_RocketHurtRadius;
var localized string RocketHurtRadiusText;
var localized string RocketHurtRadiusHelp;
var IGPlus_EditControl Edit_RocketMomentum;
var localized string RocketMomentumText;
var localized string RocketMomentumHelp;
var IGPlus_EditControl Edit_RocketSpreadSpacingDegrees;
var localized string RocketSpreadSpacingDegreesText;
var localized string RocketSpreadSpacingDegreesHelp;
var IGPlus_EditControl Edit_RocketSpeed;
var localized string RocketSpeedText;
var localized string RocketSpeedHelp;
var IGPlus_EditControl Edit_GrenadeDamage;
var localized string GrenadeDamageText;
var localized string GrenadeDamageHelp;
var IGPlus_EditControl Edit_GrenadeHurtRadius;
var localized string GrenadeHurtRadiusText;
var localized string GrenadeHurtRadiusHelp;
var IGPlus_EditControl Edit_GrenadeMomentum;
var localized string GrenadeMomentumText;
var localized string GrenadeMomentumHelp;
var UWindowCheckbox Chk_RocketCompensatePing;
var localized string RocketCompensatePingText;
var localized string RocketCompensatePingHelp;

var UWindowLabelControl Lbl_Flak;
var localized string FlakText;
var IGPlus_EditControl Edit_FlakSelectTime;
var localized string FlakSelectTimeText;
var localized string FlakSelectTimeHelp;
var IGPlus_EditControl Edit_FlakPostSelectTime;
var localized string FlakPostSelectTimeText;
var localized string FlakPostSelectTimeHelp;
var IGPlus_EditControl Edit_FlakDownTime;
var localized string FlakDownTimeText;
var localized string FlakDownTimeHelp;
var IGPlus_EditControl Edit_FlakChunkDamage;
var localized string FlakChunkDamageText;
var localized string FlakChunkDamageHelp;
var IGPlus_EditControl Edit_FlakChunkMomentum;
var localized string FlakChunkMomentumText;
var localized string FlakChunkMomentumHelp;
var IGPlus_EditControl Edit_FlakChunkLifespan;
var localized string FlakChunkLifespanText;
var localized string FlakChunkLifespanHelp;
var IGPlus_EditControl Edit_FlakChunkDropOffStart;
var localized string FlakChunkDropOffStartText;
var localized string FlakChunkDropOffStartHelp;
var IGPlus_EditControl Edit_FlakChunkDropOffEnd;
var localized string FlakChunkDropOffEndText;
var localized string FlakChunkDropOffEndHelp;
var IGPlus_EditControl Edit_FlakChunkDropOffDamageRatio;
var localized string FlakChunkDropOffDamageRatioText;
var localized string FlakChunkDropOffDamageRatioHelp;
var UWindowCheckbox Chk_FlakChunkRandomSpread;
var localized string FlakChunkRandomSpreadText;
var localized string FlakChunkRandomSpreadHelp;
var IGPlus_EditControl Edit_FlakChunkRandomSpreadSize;
var localized string FlakChunkRandomSpreadSizeText;
var localized string FlakChunkRandomSpreadSizeHelp;
var IGPlus_EditControl Edit_FlakSlugDamage;
var localized string FlakSlugDamageText;
var localized string FlakSlugDamageHelp;
var IGPlus_EditControl Edit_FlakSlugHurtRadius;
var localized string FlakSlugHurtRadiusText;
var localized string FlakSlugHurtRadiusHelp;
var IGPlus_EditControl Edit_FlakSlugMomentum;
var localized string FlakSlugMomentumText;
var localized string FlakSlugMomentumHelp;
var UWindowCheckbox Chk_FlakCompensatePing;
var localized string FlakCompensatePingText;
var localized string FlakCompensatePingHelp;

var UWindowLabelControl Lbl_Ripper;
var localized string RipperText;
var IGPlus_EditControl Edit_RipperSelectTime;
var localized string RipperSelectTimeText;
var localized string RipperSelectTimeHelp;
var IGPlus_EditControl Edit_RipperDownTime;
var localized string RipperDownTimeText;
var localized string RipperDownTimeHelp;
var IGPlus_EditControl Edit_RipperHeadshotDamage;
var localized string RipperHeadshotDamageText;
var localized string RipperHeadshotDamageHelp;
var IGPlus_EditControl Edit_RipperHeadShotDamageWallMultiplier;
var localized string RipperHeadShotDamageWallMultiplierText;
var localized string RipperHeadShotDamageWallMultiplierHelp;
var IGPlus_EditControl Edit_RipperHeadshotMomentum;
var localized string RipperHeadshotMomentumText;
var localized string RipperHeadshotMomentumHelp;
var IGPlus_EditControl Edit_RipperPrimaryDamage;
var localized string RipperPrimaryDamageText;
var localized string RipperPrimaryDamageHelp;
var IGPlus_EditControl Edit_RipperPrimaryDamageWallMultiplier;
var localized string RipperPrimaryDamageWallMultiplierText;
var localized string RipperPrimaryDamageWallMultiplierHelp;
var IGPlus_EditControl Edit_RipperPrimaryMomentum;
var localized string RipperPrimaryMomentumText;
var localized string RipperPrimaryMomentumHelp;
var IGPlus_EditControl Edit_RipperSecondaryHurtRadius;
var localized string RipperSecondaryHurtRadiusText;
var localized string RipperSecondaryHurtRadiusHelp;
var IGPlus_EditControl Edit_RipperSecondaryDamage;
var localized string RipperSecondaryDamageText;
var localized string RipperSecondaryDamageHelp;
var IGPlus_EditControl Edit_RipperSecondaryMomentum;
var localized string RipperSecondaryMomentumText;
var localized string RipperSecondaryMomentumHelp;
var UWindowCheckbox Chk_RipperCompensatePing;
var localized string RipperCompensatePingText;
var localized string RipperCompensatePingHelp;

var UWindowLabelControl Lbl_Minigun;
var localized string MinigunText;
var IGPlus_EditControl Edit_MinigunSelectTime;
var localized string MinigunSelectTimeText;
var localized string MinigunSelectTimeHelp;
var IGPlus_EditControl Edit_MinigunDownTime;
var localized string MinigunDownTimeText;
var localized string MinigunDownTimeHelp;
var IGPlus_EditControl Edit_MinigunSpinUpTime;
var localized string MinigunSpinUpTimeText;
var localized string MinigunSpinUpTimeHelp;
var IGPlus_EditControl Edit_MinigunUnwindTime;
var localized string MinigunUnwindTimeText;
var localized string MinigunUnwindTimeHelp;
var IGPlus_EditControl Edit_MinigunBulletInterval;
var localized string MinigunBulletIntervalText;
var localized string MinigunBulletIntervalHelp;
var IGPlus_EditControl Edit_MinigunAlternateBulletInterval;
var localized string MinigunAlternateBulletIntervalText;
var localized string MinigunAlternateBulletIntervalHelp;
var IGPlus_EditControl Edit_MinigunMinDamage;
var localized string MinigunMinDamageText;
var localized string MinigunMinDamageHelp;
var IGPlus_EditControl Edit_MinigunMaxDamage;
var localized string MinigunMaxDamageText;
var localized string MinigunMaxDamageHelp;
var IGPlus_EditControl Edit_MinigunAltMinDamage;
var localized string MinigunAltMinDamageText;
var localized string MinigunAltMinDamageHelp;
var IGPlus_EditControl Edit_MinigunAltMaxDamage;
var localized string MinigunAltMaxDamageText;
var localized string MinigunAltMaxDamageHelp;

var UWindowLabelControl Lbl_Pulse;
var localized string PulseText;
var IGPlus_EditControl Edit_PulseSelectTime;
var localized string PulseSelectTimeText;
var localized string PulseSelectTimeHelp;
var IGPlus_EditControl Edit_PulseDownTime;
var localized string PulseDownTimeText;
var localized string PulseDownTimeHelp;
var IGPlus_EditControl Edit_PulseSphereDamage;
var localized string PulseSphereDamageText;
var localized string PulseSphereDamageHelp;
var IGPlus_EditControl Edit_PulseSphereMomentum;
var localized string PulseSphereMomentumText;
var localized string PulseSphereMomentumHelp;
var IGPlus_EditControl Edit_PulseSphereSpeed;
var localized string PulseSphereSpeedText;
var localized string PulseSphereSpeedHelp;
var IGPlus_EditControl Edit_PulseSphereFireRate;
var localized string PulseSphereFireRateText;
var localized string PulseSphereFireRateHelp;
var IGPlus_EditControl Edit_PulseSphereCollisionRadius;
var localized string PulseSphereCollisionRadiusText;
var localized string PulseSphereCollisionRadiusHelp;
var IGPlus_EditControl Edit_PulseSphereCollisionHeight;
var localized string PulseSphereCollisionHeightText;
var localized string PulseSphereCollisionHeightHelp;
var IGPlus_EditControl Edit_PulseBoltDPS;
var localized string PulseBoltDPSText;
var localized string PulseBoltDPSHelp;
var IGPlus_EditControl Edit_PulseBoltMomentum;
var localized string PulseBoltMomentumText;
var localized string PulseBoltMomentumHelp;
var IGPlus_EditControl Edit_PulseBoltMaxAccumulate;
var localized string PulseBoltMaxAccumulateText;
var localized string PulseBoltMaxAccumulateHelp;
var IGPlus_EditControl Edit_PulseBoltGrowthDelay;
var localized string PulseBoltGrowthDelayText;
var localized string PulseBoltGrowthDelayHelp;
var IGPlus_EditControl Edit_PulseBoltMaxSegments;
var localized string PulseBoltMaxSegmentsText;
var localized string PulseBoltMaxSegmentsHelp;
var UWindowCheckbox Chk_PulseCompensatePing;
var localized string PulseCompensatePingText;
var localized string PulseCompensatePingHelp;

var UWindowLabelControl Lbl_Shock;
var localized string ShockText;
var IGPlus_EditControl Edit_ShockSelectTime;
var localized string ShockSelectTimeText;
var localized string ShockSelectTimeHelp;
var IGPlus_EditControl Edit_ShockDownTime;
var localized string ShockDownTimeText;
var localized string ShockDownTimeHelp;
var IGPlus_EditControl Edit_ShockBeamDamage;
var localized string ShockBeamDamageText;
var localized string ShockBeamDamageHelp;
var IGPlus_EditControl Edit_ShockBeamMomentum;
var localized string ShockBeamMomentumText;
var localized string ShockBeamMomentumHelp;
var UWindowCheckbox Chk_ShockBeamUseReducedHitbox;
var localized string ShockBeamUseReducedHitboxText;
var localized string ShockBeamUseReducedHitboxHelp;
var IGPlus_EditControl Edit_ShockProjectileDamage;
var localized string ShockProjectileDamageText;
var localized string ShockProjectileDamageHelp;
var IGPlus_EditControl Edit_ShockProjectileHurtRadius;
var localized string ShockProjectileHurtRadiusText;
var localized string ShockProjectileHurtRadiusHelp;
var IGPlus_EditControl Edit_ShockProjectileMomentum;
var localized string ShockProjectileMomentumText;
var localized string ShockProjectileMomentumHelp;
var UWindowCheckbox Chk_ShockProjectileBlockBullets;
var localized string ShockProjectileBlockBulletsText;
var localized string ShockProjectileBlockBulletsHelp;
var UWindowCheckbox Chk_ShockProjectileBlockFlakChunk;
var localized string ShockProjectileBlockFlakChunkText;
var localized string ShockProjectileBlockFlakChunkHelp;
var UWindowCheckbox Chk_ShockProjectileBlockFlakSlug;
var localized string ShockProjectileBlockFlakSlugText;
var localized string ShockProjectileBlockFlakSlugHelp;
var UWindowCheckbox Chk_ShockProjectileTakeDamage;
var localized string ShockProjectileTakeDamageText;
var localized string ShockProjectileTakeDamageHelp;
var IGPlus_EditControl Edit_ShockProjectileHealth;
var localized string ShockProjectileHealthText;
var localized string ShockProjectileHealthHelp;
var IGPlus_EditControl Edit_ShockComboDamage;
var localized string ShockComboDamageText;
var localized string ShockComboDamageHelp;
var IGPlus_EditControl Edit_ShockComboMomentum;
var localized string ShockComboMomentumText;
var localized string ShockComboMomentumHelp;
var IGPlus_EditControl Edit_ShockComboHurtRadius;
var localized string ShockComboHurtRadiusText;
var localized string ShockComboHurtRadiusHelp;

var UWindowLabelControl Lbl_Bio;
var localized string BioText;
var IGPlus_EditControl Edit_BioSelectTime;
var localized string BioSelectTimeText;
var localized string BioSelectTimeHelp;
var IGPlus_EditControl Edit_BioDownTime;
var localized string BioDownTimeText;
var localized string BioDownTimeHelp;
var IGPlus_EditControl Edit_BioDamage;
var localized string BioDamageText;
var localized string BioDamageHelp;
var IGPlus_EditControl Edit_BioMomentum;
var localized string BioMomentumText;
var localized string BioMomentumHelp;
var UWindowCheckbox Chk_BioPrimaryInstantExplosion;
var localized string BioPrimaryInstantExplosionText;
var localized string BioPrimaryInstantExplosionHelp;
var IGPlus_EditControl Edit_BioAltDamage;
var localized string BioAltDamageText;
var localized string BioAltDamageHelp;
var IGPlus_EditControl Edit_BioAltMomentum;
var localized string BioAltMomentumText;
var localized string BioAltMomentumHelp;
var IGPlus_EditControl Edit_BioHurtRadiusBase;
var localized string BioHurtRadiusBaseText;
var localized string BioHurtRadiusBaseHelp;
var IGPlus_EditControl Edit_BioHurtRadiusMax;
var localized string BioHurtRadiusMaxText;
var localized string BioHurtRadiusMaxHelp;
var UWindowCheckbox Chk_BioCompensatePing;
var localized string BioCompensatePingText;
var localized string BioCompensatePingHelp;

var UWindowLabelControl Lbl_Enforcer;
var localized string EnforcerText;
var IGPlus_EditControl Edit_EnforcerSelectTime;
var localized string EnforcerSelectTimeText;
var localized string EnforcerSelectTimeHelp;
var IGPlus_EditControl Edit_EnforcerDownTime;
var localized string EnforcerDownTimeText;
var localized string EnforcerDownTimeHelp;
var IGPlus_EditControl Edit_EnforcerDamage;
var localized string EnforcerDamageText;
var localized string EnforcerDamageHelp;
var IGPlus_EditControl Edit_EnforcerMomentum;
var localized string EnforcerMomentumText;
var localized string EnforcerMomentumHelp;
var IGPlus_EditControl Edit_EnforcerReloadTime;
var localized string EnforcerReloadTimeText;
var localized string EnforcerReloadTimeHelp;
var IGPlus_EditControl Edit_EnforcerReloadTimeAlt;
var localized string EnforcerReloadTimeAltText;
var localized string EnforcerReloadTimeAltHelp;
var IGPlus_EditControl Edit_EnforcerReloadTimeRepeat;
var localized string EnforcerReloadTimeRepeatText;
var localized string EnforcerReloadTimeRepeatHelp;
var UWindowCheckbox Chk_EnforcerUseReducedHitbox;
var localized string EnforcerUseReducedHitboxText;
var localized string EnforcerUseReducedHitboxHelp;
var UWindowCheckbox Chk_EnforcerAllowDouble;
var localized string EnforcerAllowDoubleText;
var localized string EnforcerAllowDoubleHelp;
var IGPlus_EditControl Edit_EnforcerDamageDouble;
var localized string EnforcerDamageDoubleText;
var localized string EnforcerDamageDoubleHelp;
var IGPlus_EditControl Edit_EnforcerMomentumDouble;
var localized string EnforcerMomentumDoubleText;
var localized string EnforcerMomentumDoubleHelp;
var IGPlus_EditControl Edit_EnforcerShotOffsetDouble;
var localized string EnforcerShotOffsetDoubleText;
var localized string EnforcerShotOffsetDoubleHelp;
var IGPlus_EditControl Edit_EnforcerReloadTimeDouble;
var localized string EnforcerReloadTimeDoubleText;
var localized string EnforcerReloadTimeDoubleHelp;
var IGPlus_EditControl Edit_EnforcerReloadTimeAltDouble;
var localized string EnforcerReloadTimeAltDoubleText;
var localized string EnforcerReloadTimeAltDoubleHelp;
var IGPlus_EditControl Edit_EnforcerReloadTimeRepeatDouble;
var localized string EnforcerReloadTimeRepeatDoubleText;
var localized string EnforcerReloadTimeRepeatDoubleHelp;

var UWindowLabelControl Lbl_Hammer;
var localized string HammerText;
var IGPlus_EditControl Edit_HammerSelectTime;
var localized string HammerSelectTimeText;
var localized string HammerSelectTimeHelp;
var IGPlus_EditControl Edit_HammerDownTime;
var localized string HammerDownTimeText;
var localized string HammerDownTimeHelp;
var IGPlus_EditControl Edit_HammerDamage;
var localized string HammerDamageText;
var localized string HammerDamageHelp;
var IGPlus_EditControl Edit_HammerMomentum;
var localized string HammerMomentumText;
var localized string HammerMomentumHelp;
var IGPlus_EditControl Edit_HammerSelfDamage;
var localized string HammerSelfDamageText;
var localized string HammerSelfDamageHelp;
var IGPlus_EditControl Edit_HammerSelfMomentum;
var localized string HammerSelfMomentumText;
var localized string HammerSelfMomentumHelp;
var IGPlus_EditControl Edit_HammerAltDamage;
var localized string HammerAltDamageText;
var localized string HammerAltDamageHelp;
var IGPlus_EditControl Edit_HammerAltMomentum;
var localized string HammerAltMomentumText;
var localized string HammerAltMomentumHelp;
var IGPlus_EditControl Edit_HammerAltSelfDamage;
var localized string HammerAltSelfDamageText;
var localized string HammerAltSelfDamageHelp;
var IGPlus_EditControl Edit_HammerAltSelfMomentum;
var localized string HammerAltSelfMomentumText;
var localized string HammerAltSelfMomentumHelp;

var UWindowLabelControl Lbl_Translocator;
var localized string TranslocatorText;
var IGPlus_EditControl Edit_TranslocatorSelectTime;
var localized string TranslocatorSelectTimeText;
var localized string TranslocatorSelectTimeHelp;
var IGPlus_EditControl Edit_TranslocatorOutSelectTime;
var localized string TranslocatorOutSelectTimeText;
var localized string TranslocatorOutSelectTimeHelp;
var IGPlus_EditControl Edit_TranslocatorDownTime;
var localized string TranslocatorDownTimeText;
var localized string TranslocatorDownTimeHelp;
var IGPlus_EditControl Edit_TranslocatorHealth;
var localized string TranslocatorHealthText;
var localized string TranslocatorHealthHelp;
var UWindowCheckbox Chk_TranslocatorCompensatePing;
var localized string TranslocatorCompensatePingText;
var localized string TranslocatorCompensatePingHelp;

var float PaddingX;
var float PaddingY;
var float LineSpacing;
var float SeparatorSpacing;
var float ControlOffset;
var bool bLastAdminState;
var bool bLoadSucceeded;
var bool bPendingAdminLogin;
var float LoginPendingUntilTime;
var float NextRefreshRequestTime;


function ClientSettings FindSettingsObject() {
	local bbPlayer P;
	local bbCHSpectator S;

	if (GetPlayerOwner().IsA('bbPlayer') && bbPlayer(GetPlayerOwner()).Settings != none)
		return bbPlayer(GetPlayerOwner()).Settings;

	if (GetPlayerOwner().IsA('bbCHSpectator') && bbCHSpectator(GetPlayerOwner()).Settings != none)
		return bbCHSpectator(GetPlayerOwner()).Settings;

	foreach GetPlayerOwner().AllActors(class'bbPlayer', P)
		if (P.Settings != none)
			return P.Settings;

	foreach GetPlayerOwner().AllActors(class'bbCHSpectator', S)
		if (S.Settings != none)
			return S.Settings;

	return none;
}

function PlayerPawn ResolveOwnerPawn() {
	return GetPlayerOwner();
}

function bbPlayer ResolveOwnerBBPlayer() {
	return bbPlayer(ResolveOwnerPawn());
}

function bbCHSpectator ResolveOwnerBBSpectator() {
	return bbCHSpectator(ResolveOwnerPawn());
}

function WeaponSettings FindWeaponSettingsObject() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none)
		return P.IGPlus_GetWeaponSettingsObject();

	S = ResolveOwnerBBSpectator();
	if (S != none)
		return S.IGPlus_GetWeaponSettingsObject();

	return none;
}

function ResetLocalWeaponSettingsCache() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none) {
		P.IGPlus_WeaponSettingsInit();
		return;
	}

	S = ResolveOwnerBBSpectator();
	if (S != none)
		S.IGPlus_WeaponSettingsInit();
}

function bool AreWeaponSettingsLoaded() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none)
		return P.IGPlus_WeaponSettingsMenuLoaded;

	S = ResolveOwnerBBSpectator();
	if (S != none)
		return S.IGPlus_WeaponSettingsMenuLoaded;

	return false;
}

function bool HasServerAdminAccess() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none)
		return P.IGPlus_WeaponSettingsMenuCanEdit;

	S = ResolveOwnerBBSpectator();
	if (S != none)
		return S.IGPlus_WeaponSettingsMenuCanEdit;

	return false;
}

function float GetNowTimeSeconds() {
	local LevelInfo L;

	L = GetLevel();
	if (L == none)
		return 0;

	return L.TimeSeconds;
}

function SetStatusText(string Text) {
	Lbl_Status.SetText(Text);
}

function UpdateStatusText() {
	if (HasServerAdminAccess() == false) {
		if (bPendingAdminLogin && GetNowTimeSeconds() <= LoginPendingUntilTime)
			SetStatusText(StatusLoginPendingText);
		else
			SetStatusText(StatusLoginText);
	} else if (AreWeaponSettingsLoaded() == false)
		SetStatusText(StatusLoadingText);
	else
		SetStatusText(StatusAdminText);
}

function UpdateAuthButton() {
	if (Btn_AdminAuth == none)
		return;

	if (HasServerAdminAccess()) {
		Btn_AdminAuth.SetText(LogoutButtonText);
		Btn_AdminAuth.SetHelpText(LogoutButtonHelp);
	} else {
		Btn_AdminAuth.SetText(LoginButtonText);
		Btn_AdminAuth.SetHelpText(LoginButtonHelp);
	}
}

function string BoolToString(bool B) {
	if (B)
		return "True";
	return "False";
}

function SendMutateCommand(string Cmd) {
	local PlayerPawn P;

	P = ResolveOwnerPawn();
	if (P == none)
		return;

	P.Mutate(Cmd);
}

function SendWeaponSetting(string Key, string Value, optional bool bSendFeedback) {
	if (bSendFeedback)
		SendMutateCommand("IGPlusWeaponSet "$Key$" "$Value);
	else
		SendMutateCommand("IGPlusWeaponSetSilent "$Key$" "$Value);
}

function bool AreWeaponSettingValuesEqual(string ValueA, string ValueB) {
	return Caps(class'StringUtils'.static.Trim(ValueA)) == Caps(class'StringUtils'.static.Trim(ValueB));
}

function bool SaveWeaponSettingIfChanged(WeaponSettings S, string Key, string Value) {
	local string CurrentValue;

	if (S != none)
		CurrentValue = S.GetPropertyText(Key);

	if (S == none || AreWeaponSettingValuesEqual(CurrentValue, Value) == false) {
		SendWeaponSetting(Key, Value, true);
		if (S != none)
			S.SetPropertyText(Key, Value);
		return true;
	}

	return false;
}

function RequestWeaponSettings(optional bool bForce) {
	local bbPlayer P;
	local bbCHSpectator S;
	local float NowTime;

	NowTime = GetNowTimeSeconds();
	if (bForce == false && NowTime < NextRefreshRequestTime)
		return;

	P = ResolveOwnerBBPlayer();
	if (P != none) {
		P.IGPlus_WeaponRequestSettings();
		NextRefreshRequestTime = NowTime + 1.0;
		return;
	}

	S = ResolveOwnerBBSpectator();
	if (S != none) {
		S.IGPlus_WeaponRequestSettings();
		NextRefreshRequestTime = NowTime + 1.0;
	}
}

function PopulatePasswordHistory() {
	local ClientSettings Settings;
	local int i;
	local string FirstPassword;

	if (Cmb_AdminPassword == none)
		return;

	Settings = FindSettingsObject();
	Cmb_AdminPassword.Clear();
	if (Settings == none)
		return;

	for (i = 0; i < arraycount(Settings.ServerAdminPasswords); i++) {
		if (Settings.ServerAdminPasswords[i] != "") {
			Cmb_AdminPassword.AddItem(Settings.ServerAdminPasswords[i]);
			if (FirstPassword == "")
				FirstPassword = Settings.ServerAdminPasswords[i];
		}
	}

	if (FirstPassword != "")
		Cmb_AdminPassword.SetValue(FirstPassword);
	else
		Cmb_AdminPassword.SetValue("");
}

function SavePasswordHistory(string Password) {
	local ClientSettings Settings;
	local int i;
	local int FoundIndex;

	if (Password == "")
		return;

	Settings = FindSettingsObject();
	if (Settings == none)
		return;

	FoundIndex = -1;
	for (i = 0; i < arraycount(Settings.ServerAdminPasswords); i++) {
		if (Settings.ServerAdminPasswords[i] == Password) {
			FoundIndex = i;
			break;
		}
	}

	if (FoundIndex >= 0) {
		for (i = FoundIndex + 1; i < arraycount(Settings.ServerAdminPasswords); i++)
			Settings.ServerAdminPasswords[i - 1] = Settings.ServerAdminPasswords[i];
	}

	for (i = arraycount(Settings.ServerAdminPasswords) - 1; i > 0; i--)
		Settings.ServerAdminPasswords[i] = Settings.ServerAdminPasswords[i - 1];

	Settings.ServerAdminPasswords[0] = Password;
	Settings.SaveConfig();

	PopulatePasswordHistory();
	if (Cmb_AdminPassword != none)
		Cmb_AdminPassword.SetValue(Password);
}

function DeletePasswordFromHistory(string Password) {
	local ClientSettings Settings;
	local int i;
	local int WriteIndex;
	local string CurrentPassword;

	if (Password == "")
		return;

	Settings = FindSettingsObject();
	if (Settings == none)
		return;

	WriteIndex = 0;
	for (i = 0; i < arraycount(Settings.ServerAdminPasswords); i++) {
		CurrentPassword = Settings.ServerAdminPasswords[i];
		if (CurrentPassword != "" && CurrentPassword != Password) {
			Settings.ServerAdminPasswords[WriteIndex] = CurrentPassword;
			WriteIndex++;
		}
	}

	for (i = WriteIndex; i < arraycount(Settings.ServerAdminPasswords); i++)
		Settings.ServerAdminPasswords[i] = "";

	Settings.SaveConfig();
	PopulatePasswordHistory();
}

function DeletePasswordFromUI() {
	local string Password;

	if (Cmb_AdminPassword == none)
		return;

	Password = class'StringUtils'.static.Trim(Cmb_AdminPassword.GetValue());
	DeletePasswordFromHistory(Password);
}


function SaveWeaponSettings() {
	local WeaponSettings S;

	S = FindWeaponSettingsObject();

	SaveWeaponSettingIfChanged(S, "bEnableEnhancedSplashBio", BoolToString(Chk_bEnableEnhancedSplashBio.bChecked));
	SaveWeaponSettingIfChanged(S, "bEnableEnhancedSplashShockCombo", BoolToString(Chk_bEnableEnhancedSplashShockCombo.bChecked));
	SaveWeaponSettingIfChanged(S, "bEnableEnhancedSplashShockProjectile", BoolToString(Chk_bEnableEnhancedSplashShockProjectile.bChecked));
	SaveWeaponSettingIfChanged(S, "bEnableEnhancedSplashRipperSecondary", BoolToString(Chk_bEnableEnhancedSplashRipperSecondary.bChecked));
	SaveWeaponSettingIfChanged(S, "bEnableEnhancedSplashFlakSlug", BoolToString(Chk_bEnableEnhancedSplashFlakSlug.bChecked));
	SaveWeaponSettingIfChanged(S, "bEnableEnhancedSplashRockets", BoolToString(Chk_bEnableEnhancedSplashRockets.bChecked));
	SaveWeaponSettingIfChanged(S, "bEnhancedSplashIgnoreStationaryPawns", BoolToString(Chk_bEnhancedSplashIgnoreStationaryPawns.bChecked));
	SaveWeaponSettingIfChanged(S, "SplashMaxDiffraction", Edit_SplashMaxDiffraction.GetValue());
	SaveWeaponSettingIfChanged(S, "SplashMinDiffractionDistance", Edit_SplashMinDiffractionDistance.GetValue());
	SaveWeaponSettingIfChanged(S, "SplashWraparoundRadiusScale", Edit_SplashWraparoundRadiusScale.GetValue());
	SaveWeaponSettingIfChanged(S, "HeadHalfHeight", Edit_HeadHalfHeight.GetValue());
	SaveWeaponSettingIfChanged(S, "HeadRadius", Edit_HeadRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "bEnablePingCompensation", BoolToString(Chk_bEnablePingCompensation.bChecked));
	SaveWeaponSettingIfChanged(S, "bEnableSubTickCompensation", BoolToString(Chk_bEnableSubTickCompensation.bChecked));
	SaveWeaponSettingIfChanged(S, "PingCompensationMax", Edit_PingCompensationMax.GetValue());
	SaveWeaponSettingIfChanged(S, "bEnableAnimationAdaptiveHeadHitbox", BoolToString(Chk_bEnableAnimationAdaptiveHeadHitbox.bChecked));
	SaveWeaponSettingIfChanged(S, "InvisibilityDuration", Edit_InvisibilityDuration.GetValue());
	SaveWeaponSettingIfChanged(S, "ShieldBeltCharge", Edit_ShieldBeltCharge.GetValue());
	SaveWeaponSettingIfChanged(S, "ArmorCharge", Edit_ArmorCharge.GetValue());
	SaveWeaponSettingIfChanged(S, "ThighPadsCharge", Edit_ThighPadsCharge.GetValue());
	SaveWeaponSettingIfChanged(S, "HealthPackHealingAmount", Edit_HealthPackHealingAmount.GetValue());
	SaveWeaponSettingIfChanged(S, "WarheadSelectTime", Edit_WarheadSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "WarheadDownTime", Edit_WarheadDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperSelectTime", Edit_SniperSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperDownTime", Edit_SniperDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperDamage", Edit_SniperDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperHeadshotDamage", Edit_SniperHeadshotDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperMomentum", Edit_SniperMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperHeadshotMomentum", Edit_SniperHeadshotMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperReloadTime", Edit_SniperReloadTime.GetValue());
	SaveWeaponSettingIfChanged(S, "SniperUseReducedHitbox", BoolToString(Chk_SniperUseReducedHitbox.bChecked));
	SaveWeaponSettingIfChanged(S, "EightballSelectTime", Edit_EightballSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "EightballDownTime", Edit_EightballDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "RocketDamage", Edit_RocketDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "RocketSelfDamage", Edit_RocketSelfDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "RocketHurtRadius", Edit_RocketHurtRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "RocketMomentum", Edit_RocketMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "RocketSpreadSpacingDegrees", Edit_RocketSpreadSpacingDegrees.GetValue());
	SaveWeaponSettingIfChanged(S, "RocketSpeed", Edit_RocketSpeed.GetValue());
	SaveWeaponSettingIfChanged(S, "GrenadeDamage", Edit_GrenadeDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "GrenadeHurtRadius", Edit_GrenadeHurtRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "GrenadeMomentum", Edit_GrenadeMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "RocketCompensatePing", BoolToString(Chk_RocketCompensatePing.bChecked));
	SaveWeaponSettingIfChanged(S, "FlakSelectTime", Edit_FlakSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakPostSelectTime", Edit_FlakPostSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakDownTime", Edit_FlakDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakChunkDamage", Edit_FlakChunkDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakChunkMomentum", Edit_FlakChunkMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakChunkLifespan", Edit_FlakChunkLifespan.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakChunkDropOffStart", Edit_FlakChunkDropOffStart.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakChunkDropOffEnd", Edit_FlakChunkDropOffEnd.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakChunkDropOffDamageRatio", Edit_FlakChunkDropOffDamageRatio.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakChunkRandomSpread", BoolToString(Chk_FlakChunkRandomSpread.bChecked));
	SaveWeaponSettingIfChanged(S, "FlakChunkRandomSpreadSize", Edit_FlakChunkRandomSpreadSize.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakSlugDamage", Edit_FlakSlugDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakSlugHurtRadius", Edit_FlakSlugHurtRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakSlugMomentum", Edit_FlakSlugMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "FlakCompensatePing", BoolToString(Chk_FlakCompensatePing.bChecked));
	SaveWeaponSettingIfChanged(S, "RipperSelectTime", Edit_RipperSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperDownTime", Edit_RipperDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperHeadshotDamage", Edit_RipperHeadshotDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperHeadShotDamageWallMultiplier", Edit_RipperHeadShotDamageWallMultiplier.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperHeadshotMomentum", Edit_RipperHeadshotMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperPrimaryDamage", Edit_RipperPrimaryDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperPrimaryDamageWallMultiplier", Edit_RipperPrimaryDamageWallMultiplier.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperPrimaryMomentum", Edit_RipperPrimaryMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperSecondaryHurtRadius", Edit_RipperSecondaryHurtRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperSecondaryDamage", Edit_RipperSecondaryDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperSecondaryMomentum", Edit_RipperSecondaryMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "RipperCompensatePing", BoolToString(Chk_RipperCompensatePing.bChecked));
	SaveWeaponSettingIfChanged(S, "MinigunSelectTime", Edit_MinigunSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunDownTime", Edit_MinigunDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunSpinUpTime", Edit_MinigunSpinUpTime.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunUnwindTime", Edit_MinigunUnwindTime.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunBulletInterval", Edit_MinigunBulletInterval.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunAlternateBulletInterval", Edit_MinigunAlternateBulletInterval.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunMinDamage", Edit_MinigunMinDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunMaxDamage", Edit_MinigunMaxDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunAltMinDamage", Edit_MinigunAltMinDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "MinigunAltMaxDamage", Edit_MinigunAltMaxDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseSelectTime", Edit_PulseSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseDownTime", Edit_PulseDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseSphereDamage", Edit_PulseSphereDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseSphereMomentum", Edit_PulseSphereMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseSphereSpeed", Edit_PulseSphereSpeed.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseSphereFireRate", Edit_PulseSphereFireRate.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseSphereCollisionRadius", Edit_PulseSphereCollisionRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseSphereCollisionHeight", Edit_PulseSphereCollisionHeight.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseBoltDPS", Edit_PulseBoltDPS.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseBoltMomentum", Edit_PulseBoltMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseBoltMaxAccumulate", Edit_PulseBoltMaxAccumulate.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseBoltGrowthDelay", Edit_PulseBoltGrowthDelay.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseBoltMaxSegments", Edit_PulseBoltMaxSegments.GetValue());
	SaveWeaponSettingIfChanged(S, "PulseCompensatePing", BoolToString(Chk_PulseCompensatePing.bChecked));
	SaveWeaponSettingIfChanged(S, "ShockSelectTime", Edit_ShockSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockDownTime", Edit_ShockDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockBeamDamage", Edit_ShockBeamDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockBeamMomentum", Edit_ShockBeamMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockBeamUseReducedHitbox", BoolToString(Chk_ShockBeamUseReducedHitbox.bChecked));
	SaveWeaponSettingIfChanged(S, "ShockProjectileDamage", Edit_ShockProjectileDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockProjectileHurtRadius", Edit_ShockProjectileHurtRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockProjectileMomentum", Edit_ShockProjectileMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockProjectileBlockBullets", BoolToString(Chk_ShockProjectileBlockBullets.bChecked));
	SaveWeaponSettingIfChanged(S, "ShockProjectileBlockFlakChunk", BoolToString(Chk_ShockProjectileBlockFlakChunk.bChecked));
	SaveWeaponSettingIfChanged(S, "ShockProjectileBlockFlakSlug", BoolToString(Chk_ShockProjectileBlockFlakSlug.bChecked));
	SaveWeaponSettingIfChanged(S, "ShockProjectileTakeDamage", BoolToString(Chk_ShockProjectileTakeDamage.bChecked));
	SaveWeaponSettingIfChanged(S, "ShockProjectileHealth", Edit_ShockProjectileHealth.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockComboDamage", Edit_ShockComboDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockComboMomentum", Edit_ShockComboMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "ShockComboHurtRadius", Edit_ShockComboHurtRadius.GetValue());
	SaveWeaponSettingIfChanged(S, "BioSelectTime", Edit_BioSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "BioDownTime", Edit_BioDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "BioDamage", Edit_BioDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "BioMomentum", Edit_BioMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "BioPrimaryInstantExplosion", BoolToString(Chk_BioPrimaryInstantExplosion.bChecked));
	SaveWeaponSettingIfChanged(S, "BioAltDamage", Edit_BioAltDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "BioAltMomentum", Edit_BioAltMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "BioHurtRadiusBase", Edit_BioHurtRadiusBase.GetValue());
	SaveWeaponSettingIfChanged(S, "BioHurtRadiusMax", Edit_BioHurtRadiusMax.GetValue());
	SaveWeaponSettingIfChanged(S, "BioCompensatePing", BoolToString(Chk_BioCompensatePing.bChecked));
	SaveWeaponSettingIfChanged(S, "EnforcerSelectTime", Edit_EnforcerSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerDownTime", Edit_EnforcerDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerDamage", Edit_EnforcerDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerMomentum", Edit_EnforcerMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerReloadTime", Edit_EnforcerReloadTime.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerReloadTimeAlt", Edit_EnforcerReloadTimeAlt.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerReloadTimeRepeat", Edit_EnforcerReloadTimeRepeat.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerUseReducedHitbox", BoolToString(Chk_EnforcerUseReducedHitbox.bChecked));
	SaveWeaponSettingIfChanged(S, "EnforcerAllowDouble", BoolToString(Chk_EnforcerAllowDouble.bChecked));
	SaveWeaponSettingIfChanged(S, "EnforcerDamageDouble", Edit_EnforcerDamageDouble.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerMomentumDouble", Edit_EnforcerMomentumDouble.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerShotOffsetDouble", Edit_EnforcerShotOffsetDouble.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerReloadTimeDouble", Edit_EnforcerReloadTimeDouble.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerReloadTimeAltDouble", Edit_EnforcerReloadTimeAltDouble.GetValue());
	SaveWeaponSettingIfChanged(S, "EnforcerReloadTimeRepeatDouble", Edit_EnforcerReloadTimeRepeatDouble.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerSelectTime", Edit_HammerSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerDownTime", Edit_HammerDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerDamage", Edit_HammerDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerMomentum", Edit_HammerMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerSelfDamage", Edit_HammerSelfDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerSelfMomentum", Edit_HammerSelfMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerAltDamage", Edit_HammerAltDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerAltMomentum", Edit_HammerAltMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerAltSelfDamage", Edit_HammerAltSelfDamage.GetValue());
	SaveWeaponSettingIfChanged(S, "HammerAltSelfMomentum", Edit_HammerAltSelfMomentum.GetValue());
	SaveWeaponSettingIfChanged(S, "TranslocatorSelectTime", Edit_TranslocatorSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "TranslocatorOutSelectTime", Edit_TranslocatorOutSelectTime.GetValue());
	SaveWeaponSettingIfChanged(S, "TranslocatorDownTime", Edit_TranslocatorDownTime.GetValue());
	SaveWeaponSettingIfChanged(S, "TranslocatorHealth", Edit_TranslocatorHealth.GetValue());
	SaveWeaponSettingIfChanged(S, "TranslocatorCompensatePing", BoolToString(Chk_TranslocatorCompensatePing.bChecked));
}


function AdminLoginFromUI() {
	local string Password;
	local PlayerPawn P;

	P = ResolveOwnerPawn();
	if (P == none)
		return;

	Password = class'StringUtils'.static.Trim(Cmb_AdminPassword.GetValue());
	if (Password == "") {
		SetStatusText(LoginRequiredText);
		return;
	}

	SavePasswordHistory(Password);
	P.AdminLogin(Password);
	bLoadSucceeded = false;
	bPendingAdminLogin = true;
	LoginPendingUntilTime = GetNowTimeSeconds() + 6.0;
	ResetLocalWeaponSettingsCache();
	RequestWeaponSettings(true);
}

function AdminLogoutFromUI() {
	local PlayerPawn P;

	P = ResolveOwnerPawn();
	if (P == none)
		return;

	P.AdminLogout();
	bLoadSucceeded = false;
	bPendingAdminLogin = false;
	ResetLocalWeaponSettingsCache();
	RequestWeaponSettings(true);
}

function UWindowCheckbox CreateCheckbox(string T, optional string HT) {
	local UWindowCheckbox Chk;

	Chk = UWindowCheckbox(CreateControl(class'IGPlus_Checkbox', PaddingX, ControlOffset, 200, 1));
	Chk.SetText(T);
	Chk.SetHelpText(HT);
	Chk.ToolTipString = HT;
	Chk.SetFont(F_Normal);
	Chk.Align = TA_Left;
	ControlOffset += LineSpacing;

	return Chk;
}

function IGPlus_EditControl CreateEdit(
	EEditControlType ECT,
	string T,
	optional string HT,
	optional int MaxLength,
	optional float EditBoxWidth
) {
	local IGPlus_EditControl Edit;

	Edit = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', PaddingX, ControlOffset, 200, 1));
	Edit.SetText(T);
	Edit.SetHelpText(HT);
	Edit.SetFont(F_Normal);
	Edit.Align = TA_Left;
	if (MaxLength > 0)
		Edit.SetMaxLength(MaxLength);

	if (EditBoxWidth > 0) {
		Edit.EditBoxWidthFraction = 0.5;
		Edit.EditBoxMinWidth = EditBoxWidth;
		Edit.EditBoxMaxWidth = EditBoxWidth;
	}

	switch(ECT) {
		case ECT_Text:
			Edit.SetNumericOnly(false);
			Edit.SetNumericFloat(false);
			break;
		case ECT_Integer:
			Edit.SetNumericOnly(true);
			Edit.SetNumericFloat(false);
			break;
		case ECT_Real:
			Edit.SetNumericOnly(true);
			Edit.SetNumericFloat(true);
			break;
	}

	ControlOffset += LineSpacing;

	return Edit;
}

function UWindowLabelControl CreateLabel(string T, optional string HT) {
	local UWindowLabelControl Lbl;

	Lbl = UWindowLabelControl(CreateControl(class'IGPlus_Label', PaddingX, ControlOffset, 200, 1));
	Lbl.SetText(T);
	Lbl.SetHelpText(HT);
	Lbl.SetFont(F_Normal);
	Lbl.Align = TA_Left;
	ControlOffset += LineSpacing;

	return Lbl;
}

function UWindowLabelControl CreateSeparator(string T, optional string HT) {
	local UWindowLabelControl Lbl;

	if (ControlOffset > PaddingY)
		ControlOffset += (SeparatorSpacing - LineSpacing);

	Lbl = UWindowLabelControl(CreateControl(class'IGPlus_Separator', PaddingX, ControlOffset, 200, 1));
	Lbl.SetText(T);
	Lbl.SetHelpText(HT);
	Lbl.SetFont(F_Normal);
	Lbl.Align = TA_Left;
	ControlOffset += LineSpacing;

	return Lbl;
}

function IGPlus_ComboBox CreateComboBox(
	string T,
	optional string HT,
	optional bool bCanEdit,
	optional float EditBoxWidth
) {
	local IGPlus_ComboBox Cmb;

	Cmb = IGPlus_ComboBox(CreateControl(class'IGPlus_ComboBox', PaddingX, ControlOffset, 200, 1));
	Cmb.SetText(T);
	Cmb.SetHelpText(HT);
	Cmb.SetFont(F_Normal);
	Cmb.Align = TA_Left;
	Cmb.SetEditable(bCanEdit);

	if (EditBoxWidth > 0) {
		Cmb.EditBoxWidthFraction = 0.5;
		Cmb.EditBoxMinWidth = EditBoxWidth;
		Cmb.EditBoxMaxWidth = EditBoxWidth;
	}

	ControlOffset += LineSpacing;

	return Cmb;
}

function IGPlus_Button CreateButton(string T, optional string HT) {
	local IGPlus_Button Btn;

	Btn = IGPlus_Button(CreateControl(class'IGPlus_Button', PaddingX, ControlOffset, 200, 1));
	Btn.SetText(T);
	Btn.SetHelpText(HT);
	Btn.Align = TA_Left;
	ControlOffset += LineSpacing;

	return Btn;
}

function LayoutControl(UWindowDialogControl C, bool bVisible, float Width, out float Y) {
	local float Height;

	if (C == none)
		return;

	if (bVisible) {
		if (C.bWindowVisible == false)
			C.ShowWindow();
		C.WinLeft = PaddingX;
		C.WinTop = Y;
		Height = FMax(C.WinHeight, 1);
		C.SetSize(Width, Height);
		Y += LineSpacing;
		return;
	}

	if (C.bWindowVisible)
		C.HideWindow();
}

function LayoutPasswordControls(Canvas C, bool bVisible, float Width, out float Y) {
	local float Height;
	local float Gap;
	local float DeleteButtonWidth;
	local float ComboWidth;

	if (Cmb_AdminPassword == none || Btn_DeletePassword == none)
		return;

	if (bVisible) {
		if (Cmb_AdminPassword.bWindowVisible == false)
			Cmb_AdminPassword.ShowWindow();
		if (Btn_DeletePassword.bWindowVisible == false)
			Btn_DeletePassword.ShowWindow();

		Gap = 4;
		DeleteButtonWidth = 20;
		ComboWidth = FMax(Width - DeleteButtonWidth - Gap, 40);
		ConfigurePasswordCombo(C, ComboWidth);

		Cmb_AdminPassword.WinLeft = PaddingX;
		Cmb_AdminPassword.WinTop = Y;
		Height = FMax(Cmb_AdminPassword.WinHeight, 1);
		Cmb_AdminPassword.SetSize(ComboWidth, Height);

		Btn_DeletePassword.WinLeft = PaddingX + ComboWidth + Gap;
		Btn_DeletePassword.WinTop = Y;
		Height = FMax(Btn_DeletePassword.WinHeight, 1);
		Btn_DeletePassword.SetSize(DeleteButtonWidth, Height);

		Y += LineSpacing;
		return;
	}

	if (Cmb_AdminPassword.bWindowVisible)
		Cmb_AdminPassword.HideWindow();
	if (Btn_DeletePassword.bWindowVisible)
		Btn_DeletePassword.HideWindow();
}

function ConfigurePasswordCombo(Canvas C, float ControlWidth) {
	local float LabelWidth;
	local float LabelHeight;
	local float MaxWidth;

	if (Cmb_AdminPassword == none)
		return;

	Cmb_AdminPassword.TextSize(C, Cmb_AdminPassword.Text, LabelWidth, LabelHeight);

	// Keep the editable area as wide as possible while preserving label visibility.
	MaxWidth = FMax(ControlWidth - LabelWidth - 8, 40);
	Cmb_AdminPassword.EditBoxMinWidth = FMin(70, MaxWidth);
	Cmb_AdminPassword.EditBoxMaxWidth = MaxWidth;
	Cmb_AdminPassword.EditBoxWidth = FClamp(
		ControlWidth * Cmb_AdminPassword.EditBoxWidthFraction,
		Cmb_AdminPassword.EditBoxMinWidth,
		Cmb_AdminPassword.EditBoxMaxWidth
	);
}

function float GetLabeledInputMaxWidth(UWindowDialogControl Control, Canvas C, float ControlWidth, optional float MinWidth) {
	local float LabelWidth;
	local float LabelHeight;

	if (Control == none)
		return 0;

	if (MinWidth <= 0)
		MinWidth = 40;

	Control.TextSize(C, Control.Text, LabelWidth, LabelHeight);
	return FMax(ControlWidth - LabelWidth - 8, MinWidth);
}

function ConfigureFixedWidthEdit(IGPlus_EditControl Edit, Canvas C, float ControlWidth, float PreferredWidth) {
	local float MaxWidth;

	if (Edit == none)
		return;

	MaxWidth = GetLabeledInputMaxWidth(Edit, C, ControlWidth, 40);
	PreferredWidth = FClamp(PreferredWidth, 40, MaxWidth);
	Edit.EditBoxMinWidth = PreferredWidth;
	Edit.EditBoxMaxWidth = PreferredWidth;
	Edit.EditBoxWidth = PreferredWidth;
}

function ConfigureFixedWidthCombo(IGPlus_ComboBox Cmb, Canvas C, float ControlWidth, float PreferredWidth) {
	local float MaxWidth;

	if (Cmb == none)
		return;

	MaxWidth = GetLabeledInputMaxWidth(Cmb, C, ControlWidth, 40);
	PreferredWidth = FClamp(PreferredWidth, 40, MaxWidth);
	Cmb.EditBoxMinWidth = PreferredWidth;
	Cmb.EditBoxMaxWidth = PreferredWidth;
	Cmb.EditBoxWidth = PreferredWidth;
}


function ConfigureResponsiveWeaponControls(Canvas C, float ControlWidth) {
	ConfigureFixedWidthEdit(Edit_SplashMaxDiffraction, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SplashMinDiffractionDistance, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SplashWraparoundRadiusScale, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HeadHalfHeight, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HeadRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PingCompensationMax, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_InvisibilityDuration, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShieldBeltCharge, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ArmorCharge, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ThighPadsCharge, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HealthPackHealingAmount, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_WarheadSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_WarheadDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SniperSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SniperDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SniperDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SniperHeadshotDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SniperMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SniperHeadshotMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SniperReloadTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EightballSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EightballDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RocketDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RocketSelfDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RocketHurtRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RocketMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RocketSpreadSpacingDegrees, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RocketSpeed, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_GrenadeDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_GrenadeHurtRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_GrenadeMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakPostSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakChunkDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakChunkMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakChunkLifespan, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakChunkDropOffStart, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakChunkDropOffEnd, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakChunkDropOffDamageRatio, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakChunkRandomSpreadSize, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakSlugDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakSlugHurtRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FlakSlugMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperHeadshotDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperHeadShotDamageWallMultiplier, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperHeadshotMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperPrimaryDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperPrimaryDamageWallMultiplier, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperPrimaryMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperSecondaryHurtRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperSecondaryDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_RipperSecondaryMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunSpinUpTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunUnwindTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunBulletInterval, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunAlternateBulletInterval, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunMinDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunMaxDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunAltMinDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinigunAltMaxDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseSphereDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseSphereMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseSphereSpeed, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseSphereFireRate, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseSphereCollisionRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseSphereCollisionHeight, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseBoltDPS, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseBoltMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseBoltMaxAccumulate, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseBoltGrowthDelay, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PulseBoltMaxSegments, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockBeamDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockBeamMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockProjectileDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockProjectileHurtRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockProjectileMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockProjectileHealth, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockComboDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockComboMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_ShockComboHurtRadius, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioAltDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioAltMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioHurtRadiusBase, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_BioHurtRadiusMax, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerReloadTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerReloadTimeAlt, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerReloadTimeRepeat, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerDamageDouble, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerMomentumDouble, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerShotOffsetDouble, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerReloadTimeDouble, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerReloadTimeAltDouble, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_EnforcerReloadTimeRepeatDouble, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerSelfDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerSelfMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerAltDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerAltMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerAltSelfDamage, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_HammerAltSelfMomentum, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_TranslocatorSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_TranslocatorOutSelectTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_TranslocatorDownTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_TranslocatorHealth, C, ControlWidth, 80);
}

function LoadWeaponSettings() {
	local WeaponSettings S;

	S = FindWeaponSettingsObject();
	if (S == none)
		return;

	Chk_bEnableEnhancedSplashBio.bChecked = S.bEnableEnhancedSplashBio;
	Chk_bEnableEnhancedSplashShockCombo.bChecked = S.bEnableEnhancedSplashShockCombo;
	Chk_bEnableEnhancedSplashShockProjectile.bChecked = S.bEnableEnhancedSplashShockProjectile;
	Chk_bEnableEnhancedSplashRipperSecondary.bChecked = S.bEnableEnhancedSplashRipperSecondary;
	Chk_bEnableEnhancedSplashFlakSlug.bChecked = S.bEnableEnhancedSplashFlakSlug;
	Chk_bEnableEnhancedSplashRockets.bChecked = S.bEnableEnhancedSplashRockets;
	Chk_bEnhancedSplashIgnoreStationaryPawns.bChecked = S.bEnhancedSplashIgnoreStationaryPawns;
	Edit_SplashMaxDiffraction.SetValue(string(S.SplashMaxDiffraction));
	Edit_SplashMinDiffractionDistance.SetValue(string(S.SplashMinDiffractionDistance));
	Edit_SplashWraparoundRadiusScale.SetValue(string(S.SplashWraparoundRadiusScale));
	Edit_HeadHalfHeight.SetValue(string(S.HeadHalfHeight));
	Edit_HeadRadius.SetValue(string(S.HeadRadius));
	Chk_bEnablePingCompensation.bChecked = S.bEnablePingCompensation;
	Chk_bEnableSubTickCompensation.bChecked = S.bEnableSubTickCompensation;
	Edit_PingCompensationMax.SetValue(string(S.PingCompensationMax));
	Chk_bEnableAnimationAdaptiveHeadHitbox.bChecked = S.bEnableAnimationAdaptiveHeadHitbox;
	Edit_InvisibilityDuration.SetValue(string(S.InvisibilityDuration));
	Edit_ShieldBeltCharge.SetValue(string(S.ShieldBeltCharge));
	Edit_ArmorCharge.SetValue(string(S.ArmorCharge));
	Edit_ThighPadsCharge.SetValue(string(S.ThighPadsCharge));
	Edit_HealthPackHealingAmount.SetValue(string(S.HealthPackHealingAmount));
	Edit_WarheadSelectTime.SetValue(string(S.WarheadSelectTime));
	Edit_WarheadDownTime.SetValue(string(S.WarheadDownTime));
	Edit_SniperSelectTime.SetValue(string(S.SniperSelectTime));
	Edit_SniperDownTime.SetValue(string(S.SniperDownTime));
	Edit_SniperDamage.SetValue(string(S.SniperDamage));
	Edit_SniperHeadshotDamage.SetValue(string(S.SniperHeadshotDamage));
	Edit_SniperMomentum.SetValue(string(S.SniperMomentum));
	Edit_SniperHeadshotMomentum.SetValue(string(S.SniperHeadshotMomentum));
	Edit_SniperReloadTime.SetValue(string(S.SniperReloadTime));
	Chk_SniperUseReducedHitbox.bChecked = S.SniperUseReducedHitbox;
	Edit_EightballSelectTime.SetValue(string(S.EightballSelectTime));
	Edit_EightballDownTime.SetValue(string(S.EightballDownTime));
	Edit_RocketDamage.SetValue(string(S.RocketDamage));
	Edit_RocketSelfDamage.SetValue(string(S.RocketSelfDamage));
	Edit_RocketHurtRadius.SetValue(string(S.RocketHurtRadius));
	Edit_RocketMomentum.SetValue(string(S.RocketMomentum));
	Edit_RocketSpreadSpacingDegrees.SetValue(string(S.RocketSpreadSpacingDegrees));
	Edit_RocketSpeed.SetValue(string(S.RocketSpeed));
	Edit_GrenadeDamage.SetValue(string(S.GrenadeDamage));
	Edit_GrenadeHurtRadius.SetValue(string(S.GrenadeHurtRadius));
	Edit_GrenadeMomentum.SetValue(string(S.GrenadeMomentum));
	Chk_RocketCompensatePing.bChecked = S.RocketCompensatePing;
	Edit_FlakSelectTime.SetValue(string(S.FlakSelectTime));
	Edit_FlakPostSelectTime.SetValue(string(S.FlakPostSelectTime));
	Edit_FlakDownTime.SetValue(string(S.FlakDownTime));
	Edit_FlakChunkDamage.SetValue(string(S.FlakChunkDamage));
	Edit_FlakChunkMomentum.SetValue(string(S.FlakChunkMomentum));
	Edit_FlakChunkLifespan.SetValue(string(S.FlakChunkLifespan));
	Edit_FlakChunkDropOffStart.SetValue(string(S.FlakChunkDropOffStart));
	Edit_FlakChunkDropOffEnd.SetValue(string(S.FlakChunkDropOffEnd));
	Edit_FlakChunkDropOffDamageRatio.SetValue(string(S.FlakChunkDropOffDamageRatio));
	Chk_FlakChunkRandomSpread.bChecked = S.FlakChunkRandomSpread;
	Edit_FlakChunkRandomSpreadSize.SetValue(string(S.FlakChunkRandomSpreadSize));
	Edit_FlakSlugDamage.SetValue(string(S.FlakSlugDamage));
	Edit_FlakSlugHurtRadius.SetValue(string(S.FlakSlugHurtRadius));
	Edit_FlakSlugMomentum.SetValue(string(S.FlakSlugMomentum));
	Chk_FlakCompensatePing.bChecked = S.FlakCompensatePing;
	Edit_RipperSelectTime.SetValue(string(S.RipperSelectTime));
	Edit_RipperDownTime.SetValue(string(S.RipperDownTime));
	Edit_RipperHeadshotDamage.SetValue(string(S.RipperHeadshotDamage));
	Edit_RipperHeadShotDamageWallMultiplier.SetValue(string(S.RipperHeadShotDamageWallMultiplier));
	Edit_RipperHeadshotMomentum.SetValue(string(S.RipperHeadshotMomentum));
	Edit_RipperPrimaryDamage.SetValue(string(S.RipperPrimaryDamage));
	Edit_RipperPrimaryDamageWallMultiplier.SetValue(string(S.RipperPrimaryDamageWallMultiplier));
	Edit_RipperPrimaryMomentum.SetValue(string(S.RipperPrimaryMomentum));
	Edit_RipperSecondaryHurtRadius.SetValue(string(S.RipperSecondaryHurtRadius));
	Edit_RipperSecondaryDamage.SetValue(string(S.RipperSecondaryDamage));
	Edit_RipperSecondaryMomentum.SetValue(string(S.RipperSecondaryMomentum));
	Chk_RipperCompensatePing.bChecked = S.RipperCompensatePing;
	Edit_MinigunSelectTime.SetValue(string(S.MinigunSelectTime));
	Edit_MinigunDownTime.SetValue(string(S.MinigunDownTime));
	Edit_MinigunSpinUpTime.SetValue(string(S.MinigunSpinUpTime));
	Edit_MinigunUnwindTime.SetValue(string(S.MinigunUnwindTime));
	Edit_MinigunBulletInterval.SetValue(string(S.MinigunBulletInterval));
	Edit_MinigunAlternateBulletInterval.SetValue(string(S.MinigunAlternateBulletInterval));
	Edit_MinigunMinDamage.SetValue(string(S.MinigunMinDamage));
	Edit_MinigunMaxDamage.SetValue(string(S.MinigunMaxDamage));
	Edit_MinigunAltMinDamage.SetValue(string(S.MinigunAltMinDamage));
	Edit_MinigunAltMaxDamage.SetValue(string(S.MinigunAltMaxDamage));
	Edit_PulseSelectTime.SetValue(string(S.PulseSelectTime));
	Edit_PulseDownTime.SetValue(string(S.PulseDownTime));
	Edit_PulseSphereDamage.SetValue(string(S.PulseSphereDamage));
	Edit_PulseSphereMomentum.SetValue(string(S.PulseSphereMomentum));
	Edit_PulseSphereSpeed.SetValue(string(S.PulseSphereSpeed));
	Edit_PulseSphereFireRate.SetValue(string(S.PulseSphereFireRate));
	Edit_PulseSphereCollisionRadius.SetValue(string(S.PulseSphereCollisionRadius));
	Edit_PulseSphereCollisionHeight.SetValue(string(S.PulseSphereCollisionHeight));
	Edit_PulseBoltDPS.SetValue(string(S.PulseBoltDPS));
	Edit_PulseBoltMomentum.SetValue(string(S.PulseBoltMomentum));
	Edit_PulseBoltMaxAccumulate.SetValue(string(S.PulseBoltMaxAccumulate));
	Edit_PulseBoltGrowthDelay.SetValue(string(S.PulseBoltGrowthDelay));
	Edit_PulseBoltMaxSegments.SetValue(string(S.PulseBoltMaxSegments));
	Chk_PulseCompensatePing.bChecked = S.PulseCompensatePing;
	Edit_ShockSelectTime.SetValue(string(S.ShockSelectTime));
	Edit_ShockDownTime.SetValue(string(S.ShockDownTime));
	Edit_ShockBeamDamage.SetValue(string(S.ShockBeamDamage));
	Edit_ShockBeamMomentum.SetValue(string(S.ShockBeamMomentum));
	Chk_ShockBeamUseReducedHitbox.bChecked = S.ShockBeamUseReducedHitbox;
	Edit_ShockProjectileDamage.SetValue(string(S.ShockProjectileDamage));
	Edit_ShockProjectileHurtRadius.SetValue(string(S.ShockProjectileHurtRadius));
	Edit_ShockProjectileMomentum.SetValue(string(S.ShockProjectileMomentum));
	Chk_ShockProjectileBlockBullets.bChecked = S.ShockProjectileBlockBullets;
	Chk_ShockProjectileBlockFlakChunk.bChecked = S.ShockProjectileBlockFlakChunk;
	Chk_ShockProjectileBlockFlakSlug.bChecked = S.ShockProjectileBlockFlakSlug;
	Chk_ShockProjectileTakeDamage.bChecked = S.ShockProjectileTakeDamage;
	Edit_ShockProjectileHealth.SetValue(string(S.ShockProjectileHealth));
	Edit_ShockComboDamage.SetValue(string(S.ShockComboDamage));
	Edit_ShockComboMomentum.SetValue(string(S.ShockComboMomentum));
	Edit_ShockComboHurtRadius.SetValue(string(S.ShockComboHurtRadius));
	Edit_BioSelectTime.SetValue(string(S.BioSelectTime));
	Edit_BioDownTime.SetValue(string(S.BioDownTime));
	Edit_BioDamage.SetValue(string(S.BioDamage));
	Edit_BioMomentum.SetValue(string(S.BioMomentum));
	Chk_BioPrimaryInstantExplosion.bChecked = S.BioPrimaryInstantExplosion;
	Edit_BioAltDamage.SetValue(string(S.BioAltDamage));
	Edit_BioAltMomentum.SetValue(string(S.BioAltMomentum));
	Edit_BioHurtRadiusBase.SetValue(string(S.BioHurtRadiusBase));
	Edit_BioHurtRadiusMax.SetValue(string(S.BioHurtRadiusMax));
	Chk_BioCompensatePing.bChecked = S.BioCompensatePing;
	Edit_EnforcerSelectTime.SetValue(string(S.EnforcerSelectTime));
	Edit_EnforcerDownTime.SetValue(string(S.EnforcerDownTime));
	Edit_EnforcerDamage.SetValue(string(S.EnforcerDamage));
	Edit_EnforcerMomentum.SetValue(string(S.EnforcerMomentum));
	Edit_EnforcerReloadTime.SetValue(string(S.EnforcerReloadTime));
	Edit_EnforcerReloadTimeAlt.SetValue(string(S.EnforcerReloadTimeAlt));
	Edit_EnforcerReloadTimeRepeat.SetValue(string(S.EnforcerReloadTimeRepeat));
	Chk_EnforcerUseReducedHitbox.bChecked = S.EnforcerUseReducedHitbox;
	Chk_EnforcerAllowDouble.bChecked = S.EnforcerAllowDouble;
	Edit_EnforcerDamageDouble.SetValue(string(S.EnforcerDamageDouble));
	Edit_EnforcerMomentumDouble.SetValue(string(S.EnforcerMomentumDouble));
	Edit_EnforcerShotOffsetDouble.SetValue(string(S.EnforcerShotOffsetDouble));
	Edit_EnforcerReloadTimeDouble.SetValue(string(S.EnforcerReloadTimeDouble));
	Edit_EnforcerReloadTimeAltDouble.SetValue(string(S.EnforcerReloadTimeAltDouble));
	Edit_EnforcerReloadTimeRepeatDouble.SetValue(string(S.EnforcerReloadTimeRepeatDouble));
	Edit_HammerSelectTime.SetValue(string(S.HammerSelectTime));
	Edit_HammerDownTime.SetValue(string(S.HammerDownTime));
	Edit_HammerDamage.SetValue(string(S.HammerDamage));
	Edit_HammerMomentum.SetValue(string(S.HammerMomentum));
	Edit_HammerSelfDamage.SetValue(string(S.HammerSelfDamage));
	Edit_HammerSelfMomentum.SetValue(string(S.HammerSelfMomentum));
	Edit_HammerAltDamage.SetValue(string(S.HammerAltDamage));
	Edit_HammerAltMomentum.SetValue(string(S.HammerAltMomentum));
	Edit_HammerAltSelfDamage.SetValue(string(S.HammerAltSelfDamage));
	Edit_HammerAltSelfMomentum.SetValue(string(S.HammerAltSelfMomentum));
	Edit_TranslocatorSelectTime.SetValue(string(S.TranslocatorSelectTime));
	Edit_TranslocatorOutSelectTime.SetValue(string(S.TranslocatorOutSelectTime));
	Edit_TranslocatorDownTime.SetValue(string(S.TranslocatorDownTime));
	Edit_TranslocatorHealth.SetValue(string(S.TranslocatorHealth));
	Chk_TranslocatorCompensatePing.bChecked = S.TranslocatorCompensatePing;

	bLoadSucceeded = true;
}

function Created() {
	super.Created();

	ControlOffset = PaddingY;

	Lbl_Header = CreateLabel(HeaderText);
	Lbl_Header.Align = TA_Center;
	Lbl_Header.SetFont(F_Bold);
	Lbl_Status = CreateLabel("");
	Lbl_Status.Align = TA_Center;
	Lbl_MoreInformation = CreateLabel(MoreInformationText);
	Lbl_MoreInformation.Align = TA_Center;
	Lbl_MoreInformation.SetFont(F_Bold);
	Lbl_Login = CreateSeparator(LoginText);
	Cmb_AdminPassword = CreateComboBox(AdminPasswordText, AdminPasswordHelp, true);
	Cmb_AdminPassword.SetMaxLength(64);
	Cmb_AdminPassword.SetNumericOnly(false);
	Cmb_AdminPassword.EditBoxWidthFraction = 0.85;
	Cmb_AdminPassword.EditBoxMinWidth = 70;
	Cmb_AdminPassword.EditBoxMaxWidth = 65535;
	Btn_DeletePassword = CreateButton(DeletePasswordButtonText, DeletePasswordButtonHelp);
	ControlOffset -= LineSpacing;
	Btn_AdminAuth = CreateButton(LoginButtonText, LoginButtonHelp);

	Lbl_EnhancedSplash = CreateSeparator(EnhancedSplashText);
	Chk_bEnableEnhancedSplashBio = CreateCheckbox(bEnableEnhancedSplashBioText, bEnableEnhancedSplashBioHelp);
	Chk_bEnableEnhancedSplashShockCombo = CreateCheckbox(bEnableEnhancedSplashShockComboText, bEnableEnhancedSplashShockComboHelp);
	Chk_bEnableEnhancedSplashShockProjectile = CreateCheckbox(bEnableEnhancedSplashShockProjectileText, bEnableEnhancedSplashShockProjectileHelp);
	Chk_bEnableEnhancedSplashRipperSecondary = CreateCheckbox(bEnableEnhancedSplashRipperSecondaryText, bEnableEnhancedSplashRipperSecondaryHelp);
	Chk_bEnableEnhancedSplashFlakSlug = CreateCheckbox(bEnableEnhancedSplashFlakSlugText, bEnableEnhancedSplashFlakSlugHelp);
	Chk_bEnableEnhancedSplashRockets = CreateCheckbox(bEnableEnhancedSplashRocketsText, bEnableEnhancedSplashRocketsHelp);
	Chk_bEnhancedSplashIgnoreStationaryPawns = CreateCheckbox(bEnhancedSplashIgnoreStationaryPawnsText, bEnhancedSplashIgnoreStationaryPawnsHelp);
	Edit_SplashMaxDiffraction = CreateEdit(ECT_Real, SplashMaxDiffractionText, SplashMaxDiffractionHelp, 16, 80);
	Edit_SplashMinDiffractionDistance = CreateEdit(ECT_Real, SplashMinDiffractionDistanceText, SplashMinDiffractionDistanceHelp, 16, 80);
	Edit_SplashWraparoundRadiusScale = CreateEdit(ECT_Real, SplashWraparoundRadiusScaleText, SplashWraparoundRadiusScaleHelp, 16, 80);

	Lbl_Global = CreateSeparator(GlobalText);
	Edit_HeadHalfHeight = CreateEdit(ECT_Real, HeadHalfHeightText, HeadHalfHeightHelp, 16, 80);
	Edit_HeadRadius = CreateEdit(ECT_Real, HeadRadiusText, HeadRadiusHelp, 16, 80);
	Chk_bEnablePingCompensation = CreateCheckbox(bEnablePingCompensationText, bEnablePingCompensationHelp);
	Chk_bEnableSubTickCompensation = CreateCheckbox(bEnableSubTickCompensationText, bEnableSubTickCompensationHelp);
	Edit_PingCompensationMax = CreateEdit(ECT_Integer, PingCompensationMaxText, PingCompensationMaxHelp, 8, 80);
	Chk_bEnableAnimationAdaptiveHeadHitbox = CreateCheckbox(bEnableAnimationAdaptiveHeadHitboxText, bEnableAnimationAdaptiveHeadHitboxHelp);

	Lbl_Pickups = CreateSeparator(PickupsText);
	Edit_InvisibilityDuration = CreateEdit(ECT_Integer, InvisibilityDurationText, InvisibilityDurationHelp, 8, 80);
	Edit_ShieldBeltCharge = CreateEdit(ECT_Integer, ShieldBeltChargeText, ShieldBeltChargeHelp, 8, 80);
	Edit_ArmorCharge = CreateEdit(ECT_Integer, ArmorChargeText, ArmorChargeHelp, 8, 80);
	Edit_ThighPadsCharge = CreateEdit(ECT_Integer, ThighPadsChargeText, ThighPadsChargeHelp, 8, 80);
	Edit_HealthPackHealingAmount = CreateEdit(ECT_Integer, HealthPackHealingAmountText, HealthPackHealingAmountHelp, 8, 80);

	Lbl_Warhead = CreateSeparator(WarheadText);
	Edit_WarheadSelectTime = CreateEdit(ECT_Real, WarheadSelectTimeText, WarheadSelectTimeHelp, 16, 80);
	Edit_WarheadDownTime = CreateEdit(ECT_Real, WarheadDownTimeText, WarheadDownTimeHelp, 16, 80);

	Lbl_Sniper = CreateSeparator(SniperText);
	Edit_SniperSelectTime = CreateEdit(ECT_Real, SniperSelectTimeText, SniperSelectTimeHelp, 16, 80);
	Edit_SniperDownTime = CreateEdit(ECT_Real, SniperDownTimeText, SniperDownTimeHelp, 16, 80);
	Edit_SniperDamage = CreateEdit(ECT_Real, SniperDamageText, SniperDamageHelp, 16, 80);
	Edit_SniperHeadshotDamage = CreateEdit(ECT_Real, SniperHeadshotDamageText, SniperHeadshotDamageHelp, 16, 80);
	Edit_SniperMomentum = CreateEdit(ECT_Real, SniperMomentumText, SniperMomentumHelp, 16, 80);
	Edit_SniperHeadshotMomentum = CreateEdit(ECT_Real, SniperHeadshotMomentumText, SniperHeadshotMomentumHelp, 16, 80);
	Edit_SniperReloadTime = CreateEdit(ECT_Real, SniperReloadTimeText, SniperReloadTimeHelp, 16, 80);
	Chk_SniperUseReducedHitbox = CreateCheckbox(SniperUseReducedHitboxText, SniperUseReducedHitboxHelp);

	Lbl_Rocket = CreateSeparator(RocketText);
	Edit_EightballSelectTime = CreateEdit(ECT_Real, EightballSelectTimeText, EightballSelectTimeHelp, 16, 80);
	Edit_EightballDownTime = CreateEdit(ECT_Real, EightballDownTimeText, EightballDownTimeHelp, 16, 80);
	Edit_RocketDamage = CreateEdit(ECT_Real, RocketDamageText, RocketDamageHelp, 16, 80);
	Edit_RocketSelfDamage = CreateEdit(ECT_Real, RocketSelfDamageText, RocketSelfDamageHelp, 16, 80);
	Edit_RocketHurtRadius = CreateEdit(ECT_Real, RocketHurtRadiusText, RocketHurtRadiusHelp, 16, 80);
	Edit_RocketMomentum = CreateEdit(ECT_Real, RocketMomentumText, RocketMomentumHelp, 16, 80);
	Edit_RocketSpreadSpacingDegrees = CreateEdit(ECT_Real, RocketSpreadSpacingDegreesText, RocketSpreadSpacingDegreesHelp, 16, 80);
	Edit_RocketSpeed = CreateEdit(ECT_Real, RocketSpeedText, RocketSpeedHelp, 16, 80);
	Edit_GrenadeDamage = CreateEdit(ECT_Real, GrenadeDamageText, GrenadeDamageHelp, 16, 80);
	Edit_GrenadeHurtRadius = CreateEdit(ECT_Real, GrenadeHurtRadiusText, GrenadeHurtRadiusHelp, 16, 80);
	Edit_GrenadeMomentum = CreateEdit(ECT_Real, GrenadeMomentumText, GrenadeMomentumHelp, 16, 80);
	Chk_RocketCompensatePing = CreateCheckbox(RocketCompensatePingText, RocketCompensatePingHelp);

	Lbl_Flak = CreateSeparator(FlakText);
	Edit_FlakSelectTime = CreateEdit(ECT_Real, FlakSelectTimeText, FlakSelectTimeHelp, 16, 80);
	Edit_FlakPostSelectTime = CreateEdit(ECT_Real, FlakPostSelectTimeText, FlakPostSelectTimeHelp, 16, 80);
	Edit_FlakDownTime = CreateEdit(ECT_Real, FlakDownTimeText, FlakDownTimeHelp, 16, 80);
	Edit_FlakChunkDamage = CreateEdit(ECT_Real, FlakChunkDamageText, FlakChunkDamageHelp, 16, 80);
	Edit_FlakChunkMomentum = CreateEdit(ECT_Real, FlakChunkMomentumText, FlakChunkMomentumHelp, 16, 80);
	Edit_FlakChunkLifespan = CreateEdit(ECT_Real, FlakChunkLifespanText, FlakChunkLifespanHelp, 16, 80);
	Edit_FlakChunkDropOffStart = CreateEdit(ECT_Real, FlakChunkDropOffStartText, FlakChunkDropOffStartHelp, 16, 80);
	Edit_FlakChunkDropOffEnd = CreateEdit(ECT_Real, FlakChunkDropOffEndText, FlakChunkDropOffEndHelp, 16, 80);
	Edit_FlakChunkDropOffDamageRatio = CreateEdit(ECT_Real, FlakChunkDropOffDamageRatioText, FlakChunkDropOffDamageRatioHelp, 16, 80);
	Chk_FlakChunkRandomSpread = CreateCheckbox(FlakChunkRandomSpreadText, FlakChunkRandomSpreadHelp);
	Edit_FlakChunkRandomSpreadSize = CreateEdit(ECT_Real, FlakChunkRandomSpreadSizeText, FlakChunkRandomSpreadSizeHelp, 16, 80);
	Edit_FlakSlugDamage = CreateEdit(ECT_Real, FlakSlugDamageText, FlakSlugDamageHelp, 16, 80);
	Edit_FlakSlugHurtRadius = CreateEdit(ECT_Real, FlakSlugHurtRadiusText, FlakSlugHurtRadiusHelp, 16, 80);
	Edit_FlakSlugMomentum = CreateEdit(ECT_Real, FlakSlugMomentumText, FlakSlugMomentumHelp, 16, 80);
	Chk_FlakCompensatePing = CreateCheckbox(FlakCompensatePingText, FlakCompensatePingHelp);

	Lbl_Ripper = CreateSeparator(RipperText);
	Edit_RipperSelectTime = CreateEdit(ECT_Real, RipperSelectTimeText, RipperSelectTimeHelp, 16, 80);
	Edit_RipperDownTime = CreateEdit(ECT_Real, RipperDownTimeText, RipperDownTimeHelp, 16, 80);
	Edit_RipperHeadshotDamage = CreateEdit(ECT_Real, RipperHeadshotDamageText, RipperHeadshotDamageHelp, 16, 80);
	Edit_RipperHeadShotDamageWallMultiplier = CreateEdit(ECT_Real, RipperHeadShotDamageWallMultiplierText, RipperHeadShotDamageWallMultiplierHelp, 16, 80);
	Edit_RipperHeadshotMomentum = CreateEdit(ECT_Real, RipperHeadshotMomentumText, RipperHeadshotMomentumHelp, 16, 80);
	Edit_RipperPrimaryDamage = CreateEdit(ECT_Real, RipperPrimaryDamageText, RipperPrimaryDamageHelp, 16, 80);
	Edit_RipperPrimaryDamageWallMultiplier = CreateEdit(ECT_Real, RipperPrimaryDamageWallMultiplierText, RipperPrimaryDamageWallMultiplierHelp, 16, 80);
	Edit_RipperPrimaryMomentum = CreateEdit(ECT_Real, RipperPrimaryMomentumText, RipperPrimaryMomentumHelp, 16, 80);
	Edit_RipperSecondaryHurtRadius = CreateEdit(ECT_Real, RipperSecondaryHurtRadiusText, RipperSecondaryHurtRadiusHelp, 16, 80);
	Edit_RipperSecondaryDamage = CreateEdit(ECT_Real, RipperSecondaryDamageText, RipperSecondaryDamageHelp, 16, 80);
	Edit_RipperSecondaryMomentum = CreateEdit(ECT_Real, RipperSecondaryMomentumText, RipperSecondaryMomentumHelp, 16, 80);
	Chk_RipperCompensatePing = CreateCheckbox(RipperCompensatePingText, RipperCompensatePingHelp);

	Lbl_Minigun = CreateSeparator(MinigunText);
	Edit_MinigunSelectTime = CreateEdit(ECT_Real, MinigunSelectTimeText, MinigunSelectTimeHelp, 16, 80);
	Edit_MinigunDownTime = CreateEdit(ECT_Real, MinigunDownTimeText, MinigunDownTimeHelp, 16, 80);
	Edit_MinigunSpinUpTime = CreateEdit(ECT_Real, MinigunSpinUpTimeText, MinigunSpinUpTimeHelp, 16, 80);
	Edit_MinigunUnwindTime = CreateEdit(ECT_Real, MinigunUnwindTimeText, MinigunUnwindTimeHelp, 16, 80);
	Edit_MinigunBulletInterval = CreateEdit(ECT_Real, MinigunBulletIntervalText, MinigunBulletIntervalHelp, 16, 80);
	Edit_MinigunAlternateBulletInterval = CreateEdit(ECT_Real, MinigunAlternateBulletIntervalText, MinigunAlternateBulletIntervalHelp, 16, 80);
	Edit_MinigunMinDamage = CreateEdit(ECT_Real, MinigunMinDamageText, MinigunMinDamageHelp, 16, 80);
	Edit_MinigunMaxDamage = CreateEdit(ECT_Real, MinigunMaxDamageText, MinigunMaxDamageHelp, 16, 80);
	Edit_MinigunAltMinDamage = CreateEdit(ECT_Real, MinigunAltMinDamageText, MinigunAltMinDamageHelp, 16, 80);
	Edit_MinigunAltMaxDamage = CreateEdit(ECT_Real, MinigunAltMaxDamageText, MinigunAltMaxDamageHelp, 16, 80);

	Lbl_Pulse = CreateSeparator(PulseText);
	Edit_PulseSelectTime = CreateEdit(ECT_Real, PulseSelectTimeText, PulseSelectTimeHelp, 16, 80);
	Edit_PulseDownTime = CreateEdit(ECT_Real, PulseDownTimeText, PulseDownTimeHelp, 16, 80);
	Edit_PulseSphereDamage = CreateEdit(ECT_Real, PulseSphereDamageText, PulseSphereDamageHelp, 16, 80);
	Edit_PulseSphereMomentum = CreateEdit(ECT_Real, PulseSphereMomentumText, PulseSphereMomentumHelp, 16, 80);
	Edit_PulseSphereSpeed = CreateEdit(ECT_Real, PulseSphereSpeedText, PulseSphereSpeedHelp, 16, 80);
	Edit_PulseSphereFireRate = CreateEdit(ECT_Real, PulseSphereFireRateText, PulseSphereFireRateHelp, 16, 80);
	Edit_PulseSphereCollisionRadius = CreateEdit(ECT_Real, PulseSphereCollisionRadiusText, PulseSphereCollisionRadiusHelp, 16, 80);
	Edit_PulseSphereCollisionHeight = CreateEdit(ECT_Real, PulseSphereCollisionHeightText, PulseSphereCollisionHeightHelp, 16, 80);
	Edit_PulseBoltDPS = CreateEdit(ECT_Real, PulseBoltDPSText, PulseBoltDPSHelp, 16, 80);
	Edit_PulseBoltMomentum = CreateEdit(ECT_Real, PulseBoltMomentumText, PulseBoltMomentumHelp, 16, 80);
	Edit_PulseBoltMaxAccumulate = CreateEdit(ECT_Real, PulseBoltMaxAccumulateText, PulseBoltMaxAccumulateHelp, 16, 80);
	Edit_PulseBoltGrowthDelay = CreateEdit(ECT_Real, PulseBoltGrowthDelayText, PulseBoltGrowthDelayHelp, 16, 80);
	Edit_PulseBoltMaxSegments = CreateEdit(ECT_Integer, PulseBoltMaxSegmentsText, PulseBoltMaxSegmentsHelp, 8, 80);
	Chk_PulseCompensatePing = CreateCheckbox(PulseCompensatePingText, PulseCompensatePingHelp);

	Lbl_Shock = CreateSeparator(ShockText);
	Edit_ShockSelectTime = CreateEdit(ECT_Real, ShockSelectTimeText, ShockSelectTimeHelp, 16, 80);
	Edit_ShockDownTime = CreateEdit(ECT_Real, ShockDownTimeText, ShockDownTimeHelp, 16, 80);
	Edit_ShockBeamDamage = CreateEdit(ECT_Real, ShockBeamDamageText, ShockBeamDamageHelp, 16, 80);
	Edit_ShockBeamMomentum = CreateEdit(ECT_Real, ShockBeamMomentumText, ShockBeamMomentumHelp, 16, 80);
	Chk_ShockBeamUseReducedHitbox = CreateCheckbox(ShockBeamUseReducedHitboxText, ShockBeamUseReducedHitboxHelp);
	Edit_ShockProjectileDamage = CreateEdit(ECT_Real, ShockProjectileDamageText, ShockProjectileDamageHelp, 16, 80);
	Edit_ShockProjectileHurtRadius = CreateEdit(ECT_Real, ShockProjectileHurtRadiusText, ShockProjectileHurtRadiusHelp, 16, 80);
	Edit_ShockProjectileMomentum = CreateEdit(ECT_Real, ShockProjectileMomentumText, ShockProjectileMomentumHelp, 16, 80);
	Chk_ShockProjectileBlockBullets = CreateCheckbox(ShockProjectileBlockBulletsText, ShockProjectileBlockBulletsHelp);
	Chk_ShockProjectileBlockFlakChunk = CreateCheckbox(ShockProjectileBlockFlakChunkText, ShockProjectileBlockFlakChunkHelp);
	Chk_ShockProjectileBlockFlakSlug = CreateCheckbox(ShockProjectileBlockFlakSlugText, ShockProjectileBlockFlakSlugHelp);
	Chk_ShockProjectileTakeDamage = CreateCheckbox(ShockProjectileTakeDamageText, ShockProjectileTakeDamageHelp);
	Edit_ShockProjectileHealth = CreateEdit(ECT_Real, ShockProjectileHealthText, ShockProjectileHealthHelp, 16, 80);
	Edit_ShockComboDamage = CreateEdit(ECT_Real, ShockComboDamageText, ShockComboDamageHelp, 16, 80);
	Edit_ShockComboMomentum = CreateEdit(ECT_Real, ShockComboMomentumText, ShockComboMomentumHelp, 16, 80);
	Edit_ShockComboHurtRadius = CreateEdit(ECT_Real, ShockComboHurtRadiusText, ShockComboHurtRadiusHelp, 16, 80);

	Lbl_Bio = CreateSeparator(BioText);
	Edit_BioSelectTime = CreateEdit(ECT_Real, BioSelectTimeText, BioSelectTimeHelp, 16, 80);
	Edit_BioDownTime = CreateEdit(ECT_Real, BioDownTimeText, BioDownTimeHelp, 16, 80);
	Edit_BioDamage = CreateEdit(ECT_Real, BioDamageText, BioDamageHelp, 16, 80);
	Edit_BioMomentum = CreateEdit(ECT_Real, BioMomentumText, BioMomentumHelp, 16, 80);
	Chk_BioPrimaryInstantExplosion = CreateCheckbox(BioPrimaryInstantExplosionText, BioPrimaryInstantExplosionHelp);
	Edit_BioAltDamage = CreateEdit(ECT_Real, BioAltDamageText, BioAltDamageHelp, 16, 80);
	Edit_BioAltMomentum = CreateEdit(ECT_Real, BioAltMomentumText, BioAltMomentumHelp, 16, 80);
	Edit_BioHurtRadiusBase = CreateEdit(ECT_Real, BioHurtRadiusBaseText, BioHurtRadiusBaseHelp, 16, 80);
	Edit_BioHurtRadiusMax = CreateEdit(ECT_Real, BioHurtRadiusMaxText, BioHurtRadiusMaxHelp, 16, 80);
	Chk_BioCompensatePing = CreateCheckbox(BioCompensatePingText, BioCompensatePingHelp);

	Lbl_Enforcer = CreateSeparator(EnforcerText);
	Edit_EnforcerSelectTime = CreateEdit(ECT_Real, EnforcerSelectTimeText, EnforcerSelectTimeHelp, 16, 80);
	Edit_EnforcerDownTime = CreateEdit(ECT_Real, EnforcerDownTimeText, EnforcerDownTimeHelp, 16, 80);
	Edit_EnforcerDamage = CreateEdit(ECT_Real, EnforcerDamageText, EnforcerDamageHelp, 16, 80);
	Edit_EnforcerMomentum = CreateEdit(ECT_Real, EnforcerMomentumText, EnforcerMomentumHelp, 16, 80);
	Edit_EnforcerReloadTime = CreateEdit(ECT_Real, EnforcerReloadTimeText, EnforcerReloadTimeHelp, 16, 80);
	Edit_EnforcerReloadTimeAlt = CreateEdit(ECT_Real, EnforcerReloadTimeAltText, EnforcerReloadTimeAltHelp, 16, 80);
	Edit_EnforcerReloadTimeRepeat = CreateEdit(ECT_Real, EnforcerReloadTimeRepeatText, EnforcerReloadTimeRepeatHelp, 16, 80);
	Chk_EnforcerUseReducedHitbox = CreateCheckbox(EnforcerUseReducedHitboxText, EnforcerUseReducedHitboxHelp);
	Chk_EnforcerAllowDouble = CreateCheckbox(EnforcerAllowDoubleText, EnforcerAllowDoubleHelp);
	Edit_EnforcerDamageDouble = CreateEdit(ECT_Real, EnforcerDamageDoubleText, EnforcerDamageDoubleHelp, 16, 80);
	Edit_EnforcerMomentumDouble = CreateEdit(ECT_Real, EnforcerMomentumDoubleText, EnforcerMomentumDoubleHelp, 16, 80);
	Edit_EnforcerShotOffsetDouble = CreateEdit(ECT_Real, EnforcerShotOffsetDoubleText, EnforcerShotOffsetDoubleHelp, 16, 80);
	Edit_EnforcerReloadTimeDouble = CreateEdit(ECT_Real, EnforcerReloadTimeDoubleText, EnforcerReloadTimeDoubleHelp, 16, 80);
	Edit_EnforcerReloadTimeAltDouble = CreateEdit(ECT_Real, EnforcerReloadTimeAltDoubleText, EnforcerReloadTimeAltDoubleHelp, 16, 80);
	Edit_EnforcerReloadTimeRepeatDouble = CreateEdit(ECT_Real, EnforcerReloadTimeRepeatDoubleText, EnforcerReloadTimeRepeatDoubleHelp, 16, 80);

	Lbl_Hammer = CreateSeparator(HammerText);
	Edit_HammerSelectTime = CreateEdit(ECT_Real, HammerSelectTimeText, HammerSelectTimeHelp, 16, 80);
	Edit_HammerDownTime = CreateEdit(ECT_Real, HammerDownTimeText, HammerDownTimeHelp, 16, 80);
	Edit_HammerDamage = CreateEdit(ECT_Real, HammerDamageText, HammerDamageHelp, 16, 80);
	Edit_HammerMomentum = CreateEdit(ECT_Real, HammerMomentumText, HammerMomentumHelp, 16, 80);
	Edit_HammerSelfDamage = CreateEdit(ECT_Real, HammerSelfDamageText, HammerSelfDamageHelp, 16, 80);
	Edit_HammerSelfMomentum = CreateEdit(ECT_Real, HammerSelfMomentumText, HammerSelfMomentumHelp, 16, 80);
	Edit_HammerAltDamage = CreateEdit(ECT_Real, HammerAltDamageText, HammerAltDamageHelp, 16, 80);
	Edit_HammerAltMomentum = CreateEdit(ECT_Real, HammerAltMomentumText, HammerAltMomentumHelp, 16, 80);
	Edit_HammerAltSelfDamage = CreateEdit(ECT_Real, HammerAltSelfDamageText, HammerAltSelfDamageHelp, 16, 80);
	Edit_HammerAltSelfMomentum = CreateEdit(ECT_Real, HammerAltSelfMomentumText, HammerAltSelfMomentumHelp, 16, 80);

	Lbl_Translocator = CreateSeparator(TranslocatorText);
	Edit_TranslocatorSelectTime = CreateEdit(ECT_Real, TranslocatorSelectTimeText, TranslocatorSelectTimeHelp, 16, 80);
	Edit_TranslocatorOutSelectTime = CreateEdit(ECT_Real, TranslocatorOutSelectTimeText, TranslocatorOutSelectTimeHelp, 16, 80);
	Edit_TranslocatorDownTime = CreateEdit(ECT_Real, TranslocatorDownTimeText, TranslocatorDownTimeHelp, 16, 80);
	Edit_TranslocatorHealth = CreateEdit(ECT_Real, TranslocatorHealthText, TranslocatorHealthHelp, 16, 80);
	Chk_TranslocatorCompensatePing = CreateCheckbox(TranslocatorCompensatePingText, TranslocatorCompensatePingHelp);

	ControlOffset += PaddingY - 4;
	Load();
}

function AfterCreate() {
	super.AfterCreate();
	DesiredWidth = 180;
	DesiredHeight = ControlOffset;
}

function BeforePaint(Canvas C, float X, float Y) {
	local float WndWidth;
	local float Top;
	local bool bAdmin;
	local bool bShowSettings;

	super.BeforePaint(C, X, Y);

	if (bPendingAdminLogin && GetNowTimeSeconds() > LoginPendingUntilTime)
		bPendingAdminLogin = false;

	if (bPendingAdminLogin || AreWeaponSettingsLoaded() == false)
		RequestWeaponSettings();

	bAdmin = HasServerAdminAccess();
	if (bAdmin)
		bPendingAdminLogin = false;
	if (bLastAdminState != bAdmin) {
		bLastAdminState = bAdmin;
		bLoadSucceeded = false;
	}

	if (bAdmin && AreWeaponSettingsLoaded() && bLoadSucceeded == false)
		LoadWeaponSettings();

	UpdateStatusText();
	UpdateAuthButton();
	if (Btn_DeletePassword != none && Cmb_AdminPassword != none)
		Btn_DeletePassword.bDisabled = (class'StringUtils'.static.Trim(Cmb_AdminPassword.GetValue()) == "");

	WndWidth = WinWidth - 2*PaddingX;
	ConfigureResponsiveWeaponControls(C, WndWidth);
	Top = PaddingY;
	bShowSettings = bAdmin && AreWeaponSettingsLoaded();

	LayoutControl(Lbl_Header, true, WndWidth, Top);
	LayoutControl(Lbl_Status, true, WndWidth, Top);
	LayoutControl(Lbl_MoreInformation, bAdmin, WndWidth, Top);
	LayoutControl(Btn_AdminAuth, true, WndWidth, Top);
	LayoutControl(Lbl_Login, !bAdmin, WndWidth, Top);
	LayoutPasswordControls(C, !bAdmin, WndWidth, Top);

	LayoutControl(Lbl_EnhancedSplash, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableEnhancedSplashBio, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableEnhancedSplashShockCombo, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableEnhancedSplashShockProjectile, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableEnhancedSplashRipperSecondary, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableEnhancedSplashFlakSlug, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableEnhancedSplashRockets, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnhancedSplashIgnoreStationaryPawns, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SplashMaxDiffraction, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SplashMinDiffractionDistance, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SplashWraparoundRadiusScale, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Global, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HeadHalfHeight, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HeadRadius, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnablePingCompensation, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableSubTickCompensation, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PingCompensationMax, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableAnimationAdaptiveHeadHitbox, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Pickups, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_InvisibilityDuration, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShieldBeltCharge, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ArmorCharge, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ThighPadsCharge, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HealthPackHealingAmount, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Warhead, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_WarheadSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_WarheadDownTime, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Sniper, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SniperSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SniperDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SniperDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SniperHeadshotDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SniperMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SniperHeadshotMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SniperReloadTime, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_SniperUseReducedHitbox, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Rocket, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EightballSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EightballDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RocketDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RocketSelfDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RocketHurtRadius, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RocketMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RocketSpreadSpacingDegrees, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RocketSpeed, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_GrenadeDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_GrenadeHurtRadius, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_GrenadeMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_RocketCompensatePing, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Flak, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakPostSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakChunkDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakChunkMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakChunkLifespan, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakChunkDropOffStart, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakChunkDropOffEnd, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakChunkDropOffDamageRatio, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_FlakChunkRandomSpread, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakChunkRandomSpreadSize, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakSlugDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakSlugHurtRadius, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FlakSlugMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_FlakCompensatePing, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Ripper, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperHeadshotDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperHeadShotDamageWallMultiplier, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperHeadshotMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperPrimaryDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperPrimaryDamageWallMultiplier, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperPrimaryMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperSecondaryHurtRadius, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperSecondaryDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_RipperSecondaryMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_RipperCompensatePing, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Minigun, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunSpinUpTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunUnwindTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunBulletInterval, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunAlternateBulletInterval, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunMinDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunMaxDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunAltMinDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinigunAltMaxDamage, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Pulse, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseSphereDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseSphereMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseSphereSpeed, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseSphereFireRate, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseSphereCollisionRadius, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseSphereCollisionHeight, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseBoltDPS, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseBoltMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseBoltMaxAccumulate, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseBoltGrowthDelay, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PulseBoltMaxSegments, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_PulseCompensatePing, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Shock, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockBeamDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockBeamMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_ShockBeamUseReducedHitbox, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockProjectileDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockProjectileHurtRadius, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockProjectileMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_ShockProjectileBlockBullets, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_ShockProjectileBlockFlakChunk, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_ShockProjectileBlockFlakSlug, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_ShockProjectileTakeDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockProjectileHealth, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockComboDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockComboMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_ShockComboHurtRadius, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Bio, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_BioPrimaryInstantExplosion, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioAltDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioAltMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioHurtRadiusBase, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_BioHurtRadiusMax, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_BioCompensatePing, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Enforcer, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerReloadTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerReloadTimeAlt, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerReloadTimeRepeat, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_EnforcerUseReducedHitbox, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_EnforcerAllowDouble, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerDamageDouble, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerMomentumDouble, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerShotOffsetDouble, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerReloadTimeDouble, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerReloadTimeAltDouble, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_EnforcerReloadTimeRepeatDouble, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Hammer, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerSelfDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerSelfMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerAltDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerAltMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerAltSelfDamage, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_HammerAltSelfMomentum, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Translocator, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_TranslocatorSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_TranslocatorOutSelectTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_TranslocatorDownTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_TranslocatorHealth, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_TranslocatorCompensatePing, bShowSettings, WndWidth, Top);

	DesiredHeight = Top + PaddingY;
}

function Notify(UWindowDialogControl C, byte E) {
	super.Notify(C, E);
	if (E == DE_Click && C == Btn_AdminAuth) {
		if (HasServerAdminAccess())
			AdminLogoutFromUI();
		else
			AdminLoginFromUI();
	} else if (E == DE_Click && C == Btn_DeletePassword) {
		DeletePasswordFromUI();
	}
}

function Load() {
	bLastAdminState = HasServerAdminAccess();
	bLoadSucceeded = false;
	bPendingAdminLogin = false;
	ResetLocalWeaponSettingsCache();
	RequestWeaponSettings(true);
	PopulatePasswordHistory();
	UpdateStatusText();
	UpdateAuthButton();
}

function Save() {
	if (HasServerAdminAccess() == false) {
		bPendingAdminLogin = false;
		SetStatusText(StatusLoginText);
		return;
	}
	if (AreWeaponSettingsLoaded() == false) {
		ResetLocalWeaponSettingsCache();
		RequestWeaponSettings(true);
		return;
	}
	SaveWeaponSettings();
	bPendingAdminLogin = false;
	SetStatusText(StatusAdminText);
}

function SaveConfigs() {
	local ClientSettings Settings;
	local UWindowWindow Dialog;
	super.SaveConfigs();
	Settings = FindSettingsObject();
	if (Settings == none)
		return;
	Dialog = GetParent(class'UWindowFramedWindow');
	if (Dialog == none)
		return;
	Settings.MenuX = Dialog.WinLeft;
	Settings.MenuY = Dialog.WinTop;
	Settings.MenuWidth = Dialog.WinWidth;
	Settings.MenuHeight = Dialog.WinHeight;
	Settings.SaveConfig();
}

defaultproperties
{
	HeaderText="Weapon Settings"
	StatusAdminText="Admin access granted. Edit settings and click Save."
	StatusLoginText="Admin access required. Enter password and click Login."
	StatusLoadingText="Loading weapon settings..."
	StatusLoginPendingText="Login requested..."
	MoreInformationText="Right-click on settings to get more information"
	LoginText="Admin Login"
	AdminPasswordText="Password"
	AdminPasswordHelp="Enter password"
	DeletePasswordButtonText="X"
	DeletePasswordButtonHelp="Delete this password from saved history"
	LoginButtonText="Login"
	LoginButtonHelp="Log in as admin"
	LogoutButtonText="Logout"
	LogoutButtonHelp="Log out of admin account"
	LoginRequiredText="Please enter admin password first."

	EnhancedSplashText="Enhanced Splash"
	bEnableEnhancedSplashBioText="Enable Enhanced Splash Bio"
	bEnableEnhancedSplashBioHelp="Weapon setting: Enable Enhanced Splash Bio"
	bEnableEnhancedSplashShockComboText="Enable Enhanced Splash Shock Combo"
	bEnableEnhancedSplashShockComboHelp="Weapon setting: Enable Enhanced Splash Shock Combo"
	bEnableEnhancedSplashShockProjectileText="Enable Enhanced Splash Shock Projectile"
	bEnableEnhancedSplashShockProjectileHelp="Weapon setting: Enable Enhanced Splash Shock Projectile"
	bEnableEnhancedSplashRipperSecondaryText="Enable Enhanced Splash Ripper Secondary"
	bEnableEnhancedSplashRipperSecondaryHelp="Weapon setting: Enable Enhanced Splash Ripper Secondary"
	bEnableEnhancedSplashFlakSlugText="Enable Enhanced Splash Flak Slug"
	bEnableEnhancedSplashFlakSlugHelp="Weapon setting: Enable Enhanced Splash Flak Slug"
	bEnableEnhancedSplashRocketsText="Enable Enhanced Splash Rockets"
	bEnableEnhancedSplashRocketsHelp="Weapon setting: Enable Enhanced Splash Rockets"
	bEnhancedSplashIgnoreStationaryPawnsText="Enhanced Splash Ignore Stationary Pawns"
	bEnhancedSplashIgnoreStationaryPawnsHelp="Weapon setting: Enhanced Splash Ignore Stationary Pawns"
	SplashMaxDiffractionText="Splash Max Diffraction"
	SplashMaxDiffractionHelp="Weapon setting: Splash Max Diffraction"
	SplashMinDiffractionDistanceText="Splash Min Diffraction Distance"
	SplashMinDiffractionDistanceHelp="Weapon setting: Splash Min Diffraction Distance"
	SplashWraparoundRadiusScaleText="Splash Wraparound Radius Scale"
	SplashWraparoundRadiusScaleHelp="Weapon setting: Splash Wraparound Radius Scale"

	GlobalText="Global"
	HeadHalfHeightText="Head Half Height"
	HeadHalfHeightHelp="Weapon setting: Head Half Height"
	HeadRadiusText="Head Radius"
	HeadRadiusHelp="Weapon setting: Head Radius"
	bEnablePingCompensationText="Enable Ping Compensation"
	bEnablePingCompensationHelp="Weapon setting: Enable Ping Compensation"
	bEnableSubTickCompensationText="Enable Sub Tick Compensation"
	bEnableSubTickCompensationHelp="Weapon setting: Enable Sub Tick Compensation"
	PingCompensationMaxText="Ping Compensation Max"
	PingCompensationMaxHelp="Weapon setting: Ping Compensation Max"
	bEnableAnimationAdaptiveHeadHitboxText="Enable Animation Adaptive Head Hitbox"
	bEnableAnimationAdaptiveHeadHitboxHelp="Weapon setting: Enable Animation Adaptive Head Hitbox"

	PickupsText="Pickups"
	InvisibilityDurationText="Invisibility Duration"
	InvisibilityDurationHelp="Weapon setting: Invisibility Duration"
	ShieldBeltChargeText="Shield Belt Charge"
	ShieldBeltChargeHelp="Weapon setting: Shield Belt Charge"
	ArmorChargeText="Armor Charge"
	ArmorChargeHelp="Weapon setting: Armor Charge"
	ThighPadsChargeText="Thigh Pads Charge"
	ThighPadsChargeHelp="Weapon setting: Thigh Pads Charge"
	HealthPackHealingAmountText="Health Pack Healing Amount"
	HealthPackHealingAmountHelp="Weapon setting: Health Pack Healing Amount"

	WarheadText="Warhead"
	WarheadSelectTimeText="Warhead Select Time"
	WarheadSelectTimeHelp="Weapon setting: Warhead Select Time"
	WarheadDownTimeText="Warhead Down Time"
	WarheadDownTimeHelp="Weapon setting: Warhead Down Time"

	SniperText="Sniper"
	SniperSelectTimeText="Sniper Select Time"
	SniperSelectTimeHelp="Weapon setting: Sniper Select Time"
	SniperDownTimeText="Sniper Down Time"
	SniperDownTimeHelp="Weapon setting: Sniper Down Time"
	SniperDamageText="Sniper Damage"
	SniperDamageHelp="Weapon setting: Sniper Damage"
	SniperHeadshotDamageText="Sniper Headshot Damage"
	SniperHeadshotDamageHelp="Weapon setting: Sniper Headshot Damage"
	SniperMomentumText="Sniper Momentum"
	SniperMomentumHelp="Weapon setting: Sniper Momentum"
	SniperHeadshotMomentumText="Sniper Headshot Momentum"
	SniperHeadshotMomentumHelp="Weapon setting: Sniper Headshot Momentum"
	SniperReloadTimeText="Sniper Reload Time"
	SniperReloadTimeHelp="Weapon setting: Sniper Reload Time"
	SniperUseReducedHitboxText="Sniper Use Reduced Hitbox"
	SniperUseReducedHitboxHelp="Weapon setting: Sniper Use Reduced Hitbox"

	RocketText="Rocket"
	EightballSelectTimeText="Eightball Select Time"
	EightballSelectTimeHelp="Weapon setting: Eightball Select Time"
	EightballDownTimeText="Eightball Down Time"
	EightballDownTimeHelp="Weapon setting: Eightball Down Time"
	RocketDamageText="Rocket Damage"
	RocketDamageHelp="Weapon setting: Rocket Damage"
	RocketSelfDamageText="Rocket Self Damage"
	RocketSelfDamageHelp="Weapon setting: Rocket Self Damage"
	RocketHurtRadiusText="Rocket Hurt Radius"
	RocketHurtRadiusHelp="Weapon setting: Rocket Hurt Radius"
	RocketMomentumText="Rocket Momentum"
	RocketMomentumHelp="Weapon setting: Rocket Momentum"
	RocketSpreadSpacingDegreesText="Rocket Spread Spacing Degrees"
	RocketSpreadSpacingDegreesHelp="Weapon setting: Rocket Spread Spacing Degrees"
	RocketSpeedText="Rocket Speed"
	RocketSpeedHelp="Weapon setting: Rocket Speed"
	GrenadeDamageText="Grenade Damage"
	GrenadeDamageHelp="Weapon setting: Grenade Damage"
	GrenadeHurtRadiusText="Grenade Hurt Radius"
	GrenadeHurtRadiusHelp="Weapon setting: Grenade Hurt Radius"
	GrenadeMomentumText="Grenade Momentum"
	GrenadeMomentumHelp="Weapon setting: Grenade Momentum"
	RocketCompensatePingText="Rocket Compensate Ping"
	RocketCompensatePingHelp="Weapon setting: Rocket Compensate Ping"

	FlakText="Flak"
	FlakSelectTimeText="Flak Select Time"
	FlakSelectTimeHelp="Weapon setting: Flak Select Time"
	FlakPostSelectTimeText="Flak Post Select Time"
	FlakPostSelectTimeHelp="Weapon setting: Flak Post Select Time"
	FlakDownTimeText="Flak Down Time"
	FlakDownTimeHelp="Weapon setting: Flak Down Time"
	FlakChunkDamageText="Flak Chunk Damage"
	FlakChunkDamageHelp="Weapon setting: Flak Chunk Damage"
	FlakChunkMomentumText="Flak Chunk Momentum"
	FlakChunkMomentumHelp="Weapon setting: Flak Chunk Momentum"
	FlakChunkLifespanText="Flak Chunk Lifespan"
	FlakChunkLifespanHelp="Weapon setting: Flak Chunk Lifespan"
	FlakChunkDropOffStartText="Flak Chunk Drop Off Start"
	FlakChunkDropOffStartHelp="Weapon setting: Flak Chunk Drop Off Start"
	FlakChunkDropOffEndText="Flak Chunk Drop Off End"
	FlakChunkDropOffEndHelp="Weapon setting: Flak Chunk Drop Off End"
	FlakChunkDropOffDamageRatioText="Flak Chunk Drop Off Damage Ratio"
	FlakChunkDropOffDamageRatioHelp="Weapon setting: Flak Chunk Drop Off Damage Ratio"
	FlakChunkRandomSpreadText="Flak Chunk Random Spread"
	FlakChunkRandomSpreadHelp="Weapon setting: Flak Chunk Random Spread"
	FlakChunkRandomSpreadSizeText="Flak Chunk Random Spread Size"
	FlakChunkRandomSpreadSizeHelp="Weapon setting: Flak Chunk Random Spread Size"
	FlakSlugDamageText="Flak Slug Damage"
	FlakSlugDamageHelp="Weapon setting: Flak Slug Damage"
	FlakSlugHurtRadiusText="Flak Slug Hurt Radius"
	FlakSlugHurtRadiusHelp="Weapon setting: Flak Slug Hurt Radius"
	FlakSlugMomentumText="Flak Slug Momentum"
	FlakSlugMomentumHelp="Weapon setting: Flak Slug Momentum"
	FlakCompensatePingText="Flak Compensate Ping"
	FlakCompensatePingHelp="Weapon setting: Flak Compensate Ping"

	RipperText="Ripper"
	RipperSelectTimeText="Ripper Select Time"
	RipperSelectTimeHelp="Weapon setting: Ripper Select Time"
	RipperDownTimeText="Ripper Down Time"
	RipperDownTimeHelp="Weapon setting: Ripper Down Time"
	RipperHeadshotDamageText="Ripper Headshot Damage"
	RipperHeadshotDamageHelp="Weapon setting: Ripper Headshot Damage"
	RipperHeadShotDamageWallMultiplierText="Ripper Head Shot Damage Wall Multiplier"
	RipperHeadShotDamageWallMultiplierHelp="Weapon setting: Ripper Head Shot Damage Wall Multiplier"
	RipperHeadshotMomentumText="Ripper Headshot Momentum"
	RipperHeadshotMomentumHelp="Weapon setting: Ripper Headshot Momentum"
	RipperPrimaryDamageText="Ripper Primary Damage"
	RipperPrimaryDamageHelp="Weapon setting: Ripper Primary Damage"
	RipperPrimaryDamageWallMultiplierText="Ripper Primary Damage Wall Multiplier"
	RipperPrimaryDamageWallMultiplierHelp="Weapon setting: Ripper Primary Damage Wall Multiplier"
	RipperPrimaryMomentumText="Ripper Primary Momentum"
	RipperPrimaryMomentumHelp="Weapon setting: Ripper Primary Momentum"
	RipperSecondaryHurtRadiusText="Ripper Secondary Hurt Radius"
	RipperSecondaryHurtRadiusHelp="Weapon setting: Ripper Secondary Hurt Radius"
	RipperSecondaryDamageText="Ripper Secondary Damage"
	RipperSecondaryDamageHelp="Weapon setting: Ripper Secondary Damage"
	RipperSecondaryMomentumText="Ripper Secondary Momentum"
	RipperSecondaryMomentumHelp="Weapon setting: Ripper Secondary Momentum"
	RipperCompensatePingText="Ripper Compensate Ping"
	RipperCompensatePingHelp="Weapon setting: Ripper Compensate Ping"

	MinigunText="Minigun"
	MinigunSelectTimeText="Minigun Select Time"
	MinigunSelectTimeHelp="Weapon setting: Minigun Select Time"
	MinigunDownTimeText="Minigun Down Time"
	MinigunDownTimeHelp="Weapon setting: Minigun Down Time"
	MinigunSpinUpTimeText="Minigun Spin Up Time"
	MinigunSpinUpTimeHelp="Weapon setting: Minigun Spin Up Time"
	MinigunUnwindTimeText="Minigun Unwind Time"
	MinigunUnwindTimeHelp="Weapon setting: Minigun Unwind Time"
	MinigunBulletIntervalText="Minigun Bullet Interval"
	MinigunBulletIntervalHelp="Weapon setting: Minigun Bullet Interval"
	MinigunAlternateBulletIntervalText="Minigun Alternate Bullet Interval"
	MinigunAlternateBulletIntervalHelp="Weapon setting: Minigun Alternate Bullet Interval"
	MinigunMinDamageText="Minigun Min Damage"
	MinigunMinDamageHelp="Weapon setting: Minigun Min Damage"
	MinigunMaxDamageText="Minigun Max Damage"
	MinigunMaxDamageHelp="Weapon setting: Minigun Max Damage"
	MinigunAltMinDamageText="Minigun Alt Min Damage"
	MinigunAltMinDamageHelp="Weapon setting: Minigun Alt Min Damage"
	MinigunAltMaxDamageText="Minigun Alt Max Damage"
	MinigunAltMaxDamageHelp="Weapon setting: Minigun Alt Max Damage"

	PulseText="Pulse"
	PulseSelectTimeText="Pulse Select Time"
	PulseSelectTimeHelp="Weapon setting: Pulse Select Time"
	PulseDownTimeText="Pulse Down Time"
	PulseDownTimeHelp="Weapon setting: Pulse Down Time"
	PulseSphereDamageText="Pulse Sphere Damage"
	PulseSphereDamageHelp="Weapon setting: Pulse Sphere Damage"
	PulseSphereMomentumText="Pulse Sphere Momentum"
	PulseSphereMomentumHelp="Weapon setting: Pulse Sphere Momentum"
	PulseSphereSpeedText="Pulse Sphere Speed"
	PulseSphereSpeedHelp="Weapon setting: Pulse Sphere Speed"
	PulseSphereFireRateText="Pulse Sphere Fire Rate"
	PulseSphereFireRateHelp="Weapon setting: Pulse Sphere Fire Rate"
	PulseSphereCollisionRadiusText="Pulse Sphere Collision Radius"
	PulseSphereCollisionRadiusHelp="Weapon setting: Pulse Sphere Collision Radius"
	PulseSphereCollisionHeightText="Pulse Sphere Collision Height"
	PulseSphereCollisionHeightHelp="Weapon setting: Pulse Sphere Collision Height"
	PulseBoltDPSText="Pulse Bolt DPS"
	PulseBoltDPSHelp="Weapon setting: Pulse Bolt DPS"
	PulseBoltMomentumText="Pulse Bolt Momentum"
	PulseBoltMomentumHelp="Weapon setting: Pulse Bolt Momentum"
	PulseBoltMaxAccumulateText="Pulse Bolt Max Accumulate"
	PulseBoltMaxAccumulateHelp="Weapon setting: Pulse Bolt Max Accumulate"
	PulseBoltGrowthDelayText="Pulse Bolt Growth Delay"
	PulseBoltGrowthDelayHelp="Weapon setting: Pulse Bolt Growth Delay"
	PulseBoltMaxSegmentsText="Pulse Bolt Max Segments"
	PulseBoltMaxSegmentsHelp="Weapon setting: Pulse Bolt Max Segments"
	PulseCompensatePingText="Pulse Compensate Ping"
	PulseCompensatePingHelp="Weapon setting: Pulse Compensate Ping"

	ShockText="Shock"
	ShockSelectTimeText="Shock Select Time"
	ShockSelectTimeHelp="Weapon setting: Shock Select Time"
	ShockDownTimeText="Shock Down Time"
	ShockDownTimeHelp="Weapon setting: Shock Down Time"
	ShockBeamDamageText="Shock Beam Damage"
	ShockBeamDamageHelp="Weapon setting: Shock Beam Damage"
	ShockBeamMomentumText="Shock Beam Momentum"
	ShockBeamMomentumHelp="Weapon setting: Shock Beam Momentum"
	ShockBeamUseReducedHitboxText="Shock Beam Use Reduced Hitbox"
	ShockBeamUseReducedHitboxHelp="Weapon setting: Shock Beam Use Reduced Hitbox"
	ShockProjectileDamageText="Shock Projectile Damage"
	ShockProjectileDamageHelp="Weapon setting: Shock Projectile Damage"
	ShockProjectileHurtRadiusText="Shock Projectile Hurt Radius"
	ShockProjectileHurtRadiusHelp="Weapon setting: Shock Projectile Hurt Radius"
	ShockProjectileMomentumText="Shock Projectile Momentum"
	ShockProjectileMomentumHelp="Weapon setting: Shock Projectile Momentum"
	ShockProjectileBlockBulletsText="Shock Projectile Block Bullets"
	ShockProjectileBlockBulletsHelp="Weapon setting: Shock Projectile Block Bullets"
	ShockProjectileBlockFlakChunkText="Shock Projectile Block Flak Chunk"
	ShockProjectileBlockFlakChunkHelp="Weapon setting: Shock Projectile Block Flak Chunk"
	ShockProjectileBlockFlakSlugText="Shock Projectile Block Flak Slug"
	ShockProjectileBlockFlakSlugHelp="Weapon setting: Shock Projectile Block Flak Slug"
	ShockProjectileTakeDamageText="Shock Projectile Take Damage"
	ShockProjectileTakeDamageHelp="Weapon setting: Shock Projectile Take Damage"
	ShockProjectileHealthText="Shock Projectile Health"
	ShockProjectileHealthHelp="Weapon setting: Shock Projectile Health"
	ShockComboDamageText="Shock Combo Damage"
	ShockComboDamageHelp="Weapon setting: Shock Combo Damage"
	ShockComboMomentumText="Shock Combo Momentum"
	ShockComboMomentumHelp="Weapon setting: Shock Combo Momentum"
	ShockComboHurtRadiusText="Shock Combo Hurt Radius"
	ShockComboHurtRadiusHelp="Weapon setting: Shock Combo Hurt Radius"

	BioText="Bio"
	BioSelectTimeText="Bio Select Time"
	BioSelectTimeHelp="Weapon setting: Bio Select Time"
	BioDownTimeText="Bio Down Time"
	BioDownTimeHelp="Weapon setting: Bio Down Time"
	BioDamageText="Bio Damage"
	BioDamageHelp="Weapon setting: Bio Damage"
	BioMomentumText="Bio Momentum"
	BioMomentumHelp="Weapon setting: Bio Momentum"
	BioPrimaryInstantExplosionText="Bio Primary Instant Explosion"
	BioPrimaryInstantExplosionHelp="Weapon setting: Bio Primary Instant Explosion"
	BioAltDamageText="Bio Alt Damage"
	BioAltDamageHelp="Weapon setting: Bio Alt Damage"
	BioAltMomentumText="Bio Alt Momentum"
	BioAltMomentumHelp="Weapon setting: Bio Alt Momentum"
	BioHurtRadiusBaseText="Bio Hurt Radius Base"
	BioHurtRadiusBaseHelp="Weapon setting: Bio Hurt Radius Base"
	BioHurtRadiusMaxText="Bio Hurt Radius Max"
	BioHurtRadiusMaxHelp="Weapon setting: Bio Hurt Radius Max"
	BioCompensatePingText="Bio Compensate Ping"
	BioCompensatePingHelp="Weapon setting: Bio Compensate Ping"

	EnforcerText="Enforcer"
	EnforcerSelectTimeText="Enforcer Select Time"
	EnforcerSelectTimeHelp="Weapon setting: Enforcer Select Time"
	EnforcerDownTimeText="Enforcer Down Time"
	EnforcerDownTimeHelp="Weapon setting: Enforcer Down Time"
	EnforcerDamageText="Enforcer Damage"
	EnforcerDamageHelp="Weapon setting: Enforcer Damage"
	EnforcerMomentumText="Enforcer Momentum"
	EnforcerMomentumHelp="Weapon setting: Enforcer Momentum"
	EnforcerReloadTimeText="Enforcer Reload Time"
	EnforcerReloadTimeHelp="Weapon setting: Enforcer Reload Time"
	EnforcerReloadTimeAltText="Enforcer Reload Time Alt"
	EnforcerReloadTimeAltHelp="Weapon setting: Enforcer Reload Time Alt"
	EnforcerReloadTimeRepeatText="Enforcer Reload Time Repeat"
	EnforcerReloadTimeRepeatHelp="Weapon setting: Enforcer Reload Time Repeat"
	EnforcerUseReducedHitboxText="Enforcer Use Reduced Hitbox"
	EnforcerUseReducedHitboxHelp="Weapon setting: Enforcer Use Reduced Hitbox"
	EnforcerAllowDoubleText="Enforcer Allow Double"
	EnforcerAllowDoubleHelp="Weapon setting: Enforcer Allow Double"
	EnforcerDamageDoubleText="Enforcer Damage Double"
	EnforcerDamageDoubleHelp="Weapon setting: Enforcer Damage Double"
	EnforcerMomentumDoubleText="Enforcer Momentum Double"
	EnforcerMomentumDoubleHelp="Weapon setting: Enforcer Momentum Double"
	EnforcerShotOffsetDoubleText="Enforcer Shot Offset Double"
	EnforcerShotOffsetDoubleHelp="Weapon setting: Enforcer Shot Offset Double"
	EnforcerReloadTimeDoubleText="Enforcer Reload Time Double"
	EnforcerReloadTimeDoubleHelp="Weapon setting: Enforcer Reload Time Double"
	EnforcerReloadTimeAltDoubleText="Enforcer Reload Time Alt Double"
	EnforcerReloadTimeAltDoubleHelp="Weapon setting: Enforcer Reload Time Alt Double"
	EnforcerReloadTimeRepeatDoubleText="Enforcer Reload Time Repeat Double"
	EnforcerReloadTimeRepeatDoubleHelp="Weapon setting: Enforcer Reload Time Repeat Double"

	HammerText="Hammer"
	HammerSelectTimeText="Hammer Select Time"
	HammerSelectTimeHelp="Weapon setting: Hammer Select Time"
	HammerDownTimeText="Hammer Down Time"
	HammerDownTimeHelp="Weapon setting: Hammer Down Time"
	HammerDamageText="Hammer Damage"
	HammerDamageHelp="Weapon setting: Hammer Damage"
	HammerMomentumText="Hammer Momentum"
	HammerMomentumHelp="Weapon setting: Hammer Momentum"
	HammerSelfDamageText="Hammer Self Damage"
	HammerSelfDamageHelp="Weapon setting: Hammer Self Damage"
	HammerSelfMomentumText="Hammer Self Momentum"
	HammerSelfMomentumHelp="Weapon setting: Hammer Self Momentum"
	HammerAltDamageText="Hammer Alt Damage"
	HammerAltDamageHelp="Weapon setting: Hammer Alt Damage"
	HammerAltMomentumText="Hammer Alt Momentum"
	HammerAltMomentumHelp="Weapon setting: Hammer Alt Momentum"
	HammerAltSelfDamageText="Hammer Alt Self Damage"
	HammerAltSelfDamageHelp="Weapon setting: Hammer Alt Self Damage"
	HammerAltSelfMomentumText="Hammer Alt Self Momentum"
	HammerAltSelfMomentumHelp="Weapon setting: Hammer Alt Self Momentum"

	TranslocatorText="Translocator"
	TranslocatorSelectTimeText="Translocator Select Time"
	TranslocatorSelectTimeHelp="Weapon setting: Translocator Select Time"
	TranslocatorOutSelectTimeText="Translocator Out Select Time"
	TranslocatorOutSelectTimeHelp="Weapon setting: Translocator Out Select Time"
	TranslocatorDownTimeText="Translocator Down Time"
	TranslocatorDownTimeHelp="Weapon setting: Translocator Down Time"
	TranslocatorHealthText="Translocator Health"
	TranslocatorHealthHelp="Weapon setting: Translocator Health"
	TranslocatorCompensatePingText="Translocator Compensate Ping"
	TranslocatorCompensatePingHelp="Weapon setting: Translocator Compensate Ping"

	PaddingX=20
	PaddingY=12
	LineSpacing=22
	SeparatorSpacing=30
}