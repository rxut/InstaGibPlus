class IGPlus_WeaponImplementation extends Actor
	abstract;

var WeaponSettings WeaponSettings;
var WeaponSettingsRepl WSettingsRepl;

replication {
	reliable if (Role == ROLE_Authority)
		WSettingsRepl;
}

final function InitWeaponSettings(string DefaultSectionName) {
	local Object Helper;
	local string Options;
	local int Pos;
	local string SettingsName;
	local StringUtils SU;

	Options = Level.GetLocalURL();
	Pos = InStr(Options, "?");
	if (Pos < 0)
		Options = "";
	else
		Options = Mid(Options, Pos);

	SU = class'StringUtils'.static.Instance();

	SettingsName = Level.Game.ParseOption(Options, "IGPlusWeaponSettings");
	if (SettingsName == "")
		SettingsName = DefaultSectionName;

	Helper = new(XLevel, 'InstaGibPlus') class'Object';
	WeaponSettings = new(Helper, SU.StringToName(SettingsName)) class'WeaponSettings';
	WeaponSettings.SaveConfig();
	WSettingsRepl = Spawn(class'WeaponSettingsRepl');
	WSettingsRepl.InitFromWeaponSettings(WeaponSettings);
}

function EnhancedHurtRadius(
	Actor  Source,
	float  DamageAmount,
	float  DamageRadius,
	name   DamageName,
	float  Momentum,
	vector HitLocation,
	optional bool bIsRazor2Alt,
	optional float SelfDamageAmount,
	optional float SelfMomentum
);

function SplashDamageWithSelfDamage(
	Actor Source,
	float DamageAmount,
	float SelfDamageAmount,
	float DamageRadius,
	name DamageName,
	float Momentum,
	float SelfMomentum,
	vector HitLocation,
	optional bool bUseEnhancedSplash
);

simulated function bool CheckHeadShot(Pawn P, vector HitLocation, vector Direction);

simulated function bool CheckBodyShot(Pawn P, vector HitLocation, vector Direction, optional vector PositionOverride);

simulated function bool CheckHeadShotCompensated(UTPlusDummy D, vector HitLocation, vector Direction);

simulated function bool CheckBodyShotCompensated(UTPlusDummy D, vector HitLocation, vector Direction);

function float GetAverageTickRate();

function SimulateProjectileWithHistory(ST_TranslocatorTarget TTarget, int Ping);

function SimulateProjectile(Projectile P, int Ping);

function BatchSimulateProjectiles(Projectile Projectiles[6], int NumProjectiles, int Ping);

function Actor TraceShot(
	out vector HitLocation,
	out vector HitNormal,
	vector EndTrace,
	vector StartTrace,
	Pawn PawnOwner
);

simulated function Actor TraceShotClient(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace, Pawn PawnOwner);

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bHidden=True
	DrawType=DT_None
}
