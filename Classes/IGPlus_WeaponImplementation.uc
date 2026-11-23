class IGPlus_WeaponImplementation extends Actor
	abstract;

var WeaponSettings WeaponSettings;
var WeaponSettingsRepl WSettingsRepl;
// Server: 1 NextIG, 2 NextSA: this mode's ini section keeps only the
// settings the mode uses (WeaponSettings.TrimConfigTo). 0: all of them.
var int IGPlus_TrimMode;
// Server: NextIG or NextSA runs, whatever section its settings come from.
var bool IGPlus_bNextMode;
// Server: the projectile SimulateProjectile is catching up now, and how much
// of that catch-up is left after this step (ST_FlakSlug.NewExplode).
var Projectile IGPlus_CatchUpProjectile;
var float IGPlus_CatchUpLeftMs;

replication {
	reliable if (Role == ROLE_Authority)
		WSettingsRepl;
}

// Writes the settings to the ini, and for NextIG and NextSA takes the unused
// ones out again. Every other mode loses the ones only those two read.
// ClearConfig is a 469 function.
function SaveWeaponSettings() {
	WeaponSettings.SaveConfig();
	if (int(Level.EngineVersion) >= 469 && (IGPlus_TrimMode != 0 || IGPlus_bNextMode == false))
		WeaponSettings.TrimConfigTo(IGPlus_TrimMode);
}

final function InitWeaponSettings(string DefaultSectionName, optional int TrimMode) {
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
	// NextIG and NextSA start a new section with sub-tick compensation and
	// Precise Rewind Time on (WeaponSettingsNext).
	IGPlus_bNextMode = TrimMode != 0;
	if (IGPlus_bNextMode)
		WeaponSettings = new(Helper, SU.StringToName(SettingsName)) class'WeaponSettingsNext';
	else
		WeaponSettings = new(Helper, SU.StringToName(SettingsName)) class'WeaponSettings';
	// Only the mode's own section is trimmed. With ?IGPlusWeaponSettings=
	// pointing at another one, that section may hold another mode's values.
	if (SettingsName ~= DefaultSectionName)
		IGPlus_TrimMode = TrimMode;
	SaveWeaponSettings();
	Log("WeaponSettingsName="$SettingsName, 'IGPlus');
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

function float IGPlus_GetOneWayLatencyMs(Pawn Instigator);

function float IGPlus_GetHitscanRewindMs(Pawn Instigator);

function vector IGPlus_AdjustLocationToCurrentMoverFrame(
	Pawn Instigator,
	vector FireLoc,
	float SampleLatencyMs,
	optional Mover BaseMover
);

function SimulateProjectileWithHistory(ST_TranslocatorTarget TTarget, int Ping);

function float SimulateProjectile(Projectile P, int Ping, optional float CatchUpMs);

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
