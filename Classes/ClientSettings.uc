class ClientSettings extends Object
	config(InstaGibPlus)
	perobjectconfig;

struct PIDControllerSettings {
	var() float p;
	var() float i;
	var() float d;
};

enum EHitSoundSource {
	HSSRC_Server,
	HSSRC_Client
};
// When the ring of the InstaGib rifle shows on a player we hit: at the click,
// from our own trace (Client), or once the server has counted the hit (Server).
enum EHitEffectSource {
	HESRC_Server,
	HESRC_Client
};

// What to draw when a player's model would blend slowly out of the
// turned-over part of a flip and collapse into a lump (bbPlayer.IGPlus_FlipFix_Apply).
enum EFlipAnimationFix {
	FAF_Off,
	FAF_Instant,
	FAF_FinishFlip
};

var config bool   bInitialized;
var config bool   bForceModels; // if Client wishes models forced to his own. (default false)
var config bool   bDemoShowRealModels; // restore real player models during demo playback
var config bool   bTeamInfo;    // if Client wants extra team info.
var config bool   bShootDead;
var config bool   bDoEndShot;   // if Client wants Screenshot at end of match.
var config bool   bAutoDemo;    // if Client wants demo or not.
var config string DemoMask; // The options for creating demo filename.
var config string DemoPath; // The path for creating the demo.
var config string DemoChar; // Character to use instead of illegal ones.
var config int    DesiredSkin;
var config int    DesiredSkinFemale;
var config int    DesiredTeamSkin;
var config int    DesiredTeamSkinFemale;
var config int    SkinEnemyIndexMap[16];
var config int    SkinTeamIndexMap[16];
var config bool   bSkinEnemyUseIndexMap;
var config bool   bSkinTeamUseIndexMap;
var config bool   bUnlitSkins;
var config bool   bEnableHitSounds;
var config bool   bEnableTeamHitSounds;
var config bool   bHitSoundPitchShift;
var config bool   bHitSoundTeamPitchShift;
var config EHitSoundSource HitSoundSource;
var config int    SelectedHitSound;
var config int    SelectedTeamHitSound;
var config float  HitSoundVolume;
var config float  HitSoundTeamVolume;
var config string sHitSound[16];
var config int    cShockBeam;
var config bool   bHideOwnBeam;
var config bool   bBeamEnableLight;
var config float  BeamScale;
var config float  BeamFadeCurve;
var config float  BeamDuration;
var config int    BeamOriginMode;
var config int    BeamDestinationMode;
var config int    SSRRingType;
var config EHitEffectSource HitEffectSource;
var config float  DesiredNetUpdateRate;
var config int    DesiredNetspeed;
var config bool   bNoOwnFootsteps;
var config bool   bLogClientMessages;
var config bool   bDemoShowClientMessages;
var config bool   bDebugMovement;
var config bool   bShowDebugDataOnScreen; // enableDebugData 1: also draw the debug block and the debug lines on the HUD
var config EFlipAnimationFix FlipAnimationFix;
var config bool   bEnableKillCam;
var config float  FakeCAPInterval; // Send a FakeCAP after no CAP has been sent for this amount of time
var config bool   bCameraCorrectionSmoothing; // Apply corrections to the simulation at once, ease only the camera
var config float  CameraCorrectionSmoothingTime; // Seconds until ~95% of a correction is gone from the camera
var config bool   bSmoothLiftJump; // Leaving a moving lift: move to the server's spot at once, camera eased
var config bool   bPredictedSwitching;     // Our own say on the server's predictions (the server's setting must allow them too)
var config bool   bPredictedTranslocation;
var config bool   bPredictedDiscBoost;
var config bool   bSmoothDiscCorrections; // Our own deterministic disc: a server correction up to 64uu (320uu after a hit) glides over 0.1s instead of a jump
var config bool   bSmoothDiscCorrectionsDefaulted; // bSmoothDiscCorrections was turned on once, when it became the default
var config float  MinDodgeClickTime; // Minimum time between two presses of the same direction for them to count as a dodge
var config bool   bUseOldMouseInput;
var config PIDControllerSettings SmoothVRController;
var config bool   bShowFPS;
var config float  FPSLocationX;
var config float  FPSLocationY;
var config int    FPSDetail;
var config int    FPSCounterSmoothingStrength;
var config bool   bSpectatorShowDamageNumbers;
var config float  DamageNumberDuration;
var config float  DamageNumberFade;
var config float  KillCamMinDelay;
var config bool   bReduceEyeHeightInAir;
var config bool   bAllowWeaponShake;
var config bool   bAutoReady;
var config bool   bShowDeathReport;
var config bool   bSmoothFOVChanges;
var config bool   bEnableLocationOffsetFix;
var config bool   bEnableKillFeed;
var config float  KillFeedX;
var config float  KillFeedY;
var config float  KillFeedSpeed;
var config float  KillFeedScale;

enum EFraggerScopeChoice {
	FSC_None,
	FSC_Moveable,
	FSC_Static
};
var config EFraggerScopeChoice FraggerScopeChoice;

var config bool   bEnableNetStats;
var config bool   bNetStatsUnconfirmedTime;
var config bool   bNetStatsLocationError;
var config bool   bNetStatsFrameTime;
var config float  NetStatsLocationX;
var config float  NetStatsLocationY;
var config int    NetStatsWidth;

enum EHitMarkerSource {
	HMSRC_Server,
	HMSRC_Client
};
enum EHitMarkerColorMode {
	HMCM_FriendOrFoe,
	HMCM_TeamColor
};

var config bool   bEnableHitMarker;
var config bool   bEnableTeamHitMarker;
var config EHitMarkerColorMode HitMarkerColorMode;
var config color  HitMarkerColor;
var config color  HitMarkerTeamColor;
var config float  HitMarkerSize;
var config float  HitMarkerOffset;
var config float  HitMarkerDuration;
var config float  HitMarkerDecayExponent;
var config EHitMarkerSource HitMarkerSource;

struct CrosshairLayerDescr {
	var() config string Texture;
	var() config int    OffsetX, OffsetY;
	var() config float  ScaleX, ScaleY;
	var() config color  Color;
	var() config byte   Style;
	var() config bool   bSmooth;
	var() config bool   bUse;
	var() config byte   Shape;     // 0: the texture, else a shape drawn row by row (CrosshairLayer.Shape)
	var() config int    Thickness; // of a shape's outline in pixels, 0 fills it
};
var config bool bUseCrosshairFactory;
var config CrosshairLayerDescr CrosshairLayers[32]; // the picked preset: what is drawn and what the Crosshair Factory edits
var config int CrosshairPreset; // the slot of the picked preset, 0 to 15
var IGPlus_CrosshairPreset CrosshairPresets[16];
var CrosshairLayer BottomLayer;
var CrosshairLayer TopLayer;

var config bool   bBioUseClientSideAnimations;
var config bool   bShockBeamUseClientSideAnimations;
var config bool   bShockProjectileUseClientSideAnimations;
var config bool   bPredictiveShockCombos;
var config bool   bPulseUseClientSideAnimations;
var config bool   bRipperUseClientSideAnimations;
var config bool   bFlakUseClientSideAnimations;
var config bool   bRocketUseClientSideAnimations;
var config bool   bSniperUseClientSideAnimations;
var config bool   bTranslocatorUseClientSideAnimations;

var config float MenuX, MenuY, MenuWidth, MenuHeight;
var config string ServerAdminPasswords[16];

var Sound DefaultHitSound[16];
var Sound LoadedHitSound[16];

simulated function AppendLayer(CrosshairLayer L) {
	if (BottomLayer == none) {
		BottomLayer = L;
		TopLayer = L;
	} else {
		TopLayer.Next = L;
		TopLayer = L;
	}
}

simulated function CrosshairLayer MakeCrosshairLayer(CrosshairLayerDescr D) {
	local CrosshairLayer L;

	L = new(none) class'CrosshairLayer';
	if (D.Texture != "")
		L.Texture = Texture(DynamicLoadObject(D.Texture, class'Texture'));
	L.OffsetX = D.OffsetX;
	L.OffsetY = D.OffsetY;
	L.ScaleX = D.ScaleX;
	L.ScaleY = D.ScaleY;
	L.Color = D.Color;
	L.Style = Max(1, D.Style);
	L.bSmooth = D.bSmooth;
	L.Shape = D.Shape;
	L.Thickness = D.Thickness;
	return L;
}

simulated function CreateCrosshairLayers() {
	local int i;

	BottomLayer = none;
	TopLayer = none;

	for (i = 0; i < arraycount(CrosshairLayers); i++)
		if (CrosshairLayers[i].bUse)
			AppendLayer(MakeCrosshairLayer(CrosshairLayers[i]));
}

// Crosshair presets. CrosshairLayers stays what is drawn, so an older IG+
// version on another server, which reads the same ini, draws the picked
// crosshair too. Every preset also has its own section in the ini, and
// picking one copies its layers into CrosshairLayers.
simulated function LoadCrosshairPresets() {
	local int i;
	local StringUtils SU;

	SU = class'StringUtils'.static.Instance();
	for (i = 0; i < arraycount(CrosshairPresets); i++)
		CrosshairPresets[i] = new(Outer, SU.StringToName("CrosshairPreset"$(i + 1))) class'IGPlus_CrosshairPreset';

	// A player from before the presets has their crosshair in CrosshairLayers
	// and CrosshairPreset 0: it becomes the first preset here. Nothing is
	// written to the ini until the player saves, adds, picks or deletes a
	// preset, so a dedicated server's ini gets no preset section.
	CrosshairPreset = Clamp(CrosshairPreset, 0, arraycount(CrosshairPresets) - 1);
	CopyLayersToCrosshairPreset();
}

// CrosshairLayers into the picked preset, which gets a name if it has none.
simulated function CopyLayersToCrosshairPreset(optional string NewName) {
	local int i;
	local IGPlus_CrosshairPreset P;

	P = CrosshairPresets[CrosshairPreset];
	if (NewName != "")
		P.PresetName = NewName;
	else if (P.PresetName == "")
		P.PresetName = "Crosshair"@(CrosshairPreset + 1);
	for (i = 0; i < arraycount(CrosshairLayers); i++)
		P.SetLayer(i, CrosshairLayers[i]);
}

// The same, and into the picked preset's own section of the ini.
simulated function StoreCrosshairPreset(optional string NewName) {
	CopyLayersToCrosshairPreset(NewName);
	CrosshairPresets[CrosshairPreset].SaveConfig();
}

// The name of the preset in a slot, empty for a free slot.
simulated function string GetCrosshairPresetName(int Slot) {
	if (Slot < 0 || Slot >= arraycount(CrosshairPresets))
		return "";
	return CrosshairPresets[Slot].PresetName;
}

// A preset's layers as drawn layers, bottom first, for its picture in the
// Crosshair Factory.
simulated function CrosshairLayer CreateCrosshairPresetLayers(int Slot) {
	local int i;
	local CrosshairLayerDescr D;
	local CrosshairLayer First, Last, L;

	for (i = 0; i < arraycount(CrosshairLayers); i++) {
		D = CrosshairPresets[Slot].GetLayer(i);
		if (D.bUse == false)
			continue;
		L = MakeCrosshairLayer(D);
		if (First == none)
			First = L;
		else
			Last.Next = L;
		Last = L;
	}
	return First;
}

// A preset's layers into CrosshairLayers.
simulated function UseCrosshairPreset(int Slot) {
	local int i;

	CrosshairPreset = Slot;
	for (i = 0; i < arraycount(CrosshairLayers); i++)
		CrosshairLayers[i] = CrosshairPresets[Slot].GetLayer(i);
	CreateCrosshairLayers();
	SaveConfig();
}

// Draws another preset from now on. What CrosshairLayers held goes back to
// its own preset first, since an older IG+ version edits it there.
simulated function PickCrosshairPreset(int Slot) {
	if (Slot == CrosshairPreset || GetCrosshairPresetName(Slot) == "")
		return;
	StoreCrosshairPreset();
	UseCrosshairPreset(Slot);
}

// The console command CrosshairPreset: the number of a saved preset (1 to 16),
// next or prev. Without a word after it, it names the picked one. Returns the
// line for the player.
simulated function string CrosshairPresetCommand(string Which) {
	local int i, Slot, Step;
	local string Line;

	Which = Caps(Which);
	Slot = CrosshairPreset;
	if (Which == "NEXT" || Which == "PREV" || Which == "PREVIOUS") {
		Step = 1;
		if (Which != "NEXT")
			Step = arraycount(CrosshairPresets) - 1;
		for (i = 0; i < arraycount(CrosshairPresets); i++) {
			Slot = (Slot + Step) % arraycount(CrosshairPresets);
			if (GetCrosshairPresetName(Slot) != "")
				break;
		}
	} else if (Which != "") {
		Slot = int(Which) - 1;
		if (Slot < 0 || Slot >= arraycount(CrosshairPresets) || GetCrosshairPresetName(Slot) == "")
			return "No crosshair preset"@Which$". Use the number of a saved preset (1 to 16), next or prev.";
	}
	PickCrosshairPreset(Slot);

	Line = "Crosshair preset"@(CrosshairPreset + 1)$":"@GetCrosshairPresetName(CrosshairPreset);
	if (bUseCrosshairFactory == false)
		Line = Line$" (the Crosshair Factory is off, so the game draws its own crosshair)";
	return Line;
}

// A new preset in the first free slot, picked, as a copy of the one picked
// before. False when all slots are taken.
simulated function bool NewCrosshairPreset() {
	local int i;

	for (i = 0; i < arraycount(CrosshairPresets); i++)
		if (CrosshairPresets[i].PresetName == "") {
			StoreCrosshairPreset();
			CrosshairPreset = i;
			StoreCrosshairPreset();
			SaveConfig();
			return true;
		}
	return false;
}

// Deletes the picked preset and picks the first one left. False for the last
// preset, which stays.
simulated function bool DeleteCrosshairPreset() {
	local int i, Next;
	local CrosshairLayerDescr Empty;
	local IGPlus_CrosshairPreset P;

	Next = -1;
	for (i = arraycount(CrosshairPresets) - 1; i >= 0; i--)
		if (i != CrosshairPreset && CrosshairPresets[i].PresetName != "")
			Next = i;
	if (Next < 0)
		return false;

	P = CrosshairPresets[CrosshairPreset];
	P.PresetName = "";
	for (i = 0; i < arraycount(CrosshairLayers); i++)
		P.SetLayer(i, Empty);
	P.SaveConfig();
	UseCrosshairPreset(Next);
	return true;
}

simulated function LoadHitSounds() {
	local int i;

	for (i = 0; i < arraycount(sHitSound); i++) {
		if (sHitSound[i] != "" && (sHitSound[i] ~= "none") == false)
			LoadedHitSound[i] = Sound(DynamicLoadObject(sHitSound[i], class'Sound', true));
		else
			LoadedHitSound[i] = none;
		
		if (LoadedHitSound[i] == none && DefaultHitSound[i] != none)
			LoadedHitSound[i] = DefaultHitSound[i];
	}
}

simulated function CheckConfig() {
	LoadHitSounds();
	LoadCrosshairPresets();
	CreateCrosshairLayers();

	if (FPSCounterSmoothingStrength <= 0)
		FPSCounterSmoothingStrength = 1;

	// Smooth Disc Corrections shipped off, and every client saved that. Now
	// it defaults to on: turn it on once for them too.
	if (bSmoothDiscCorrectionsDefaulted == false) {
		bSmoothDiscCorrections = true;
		bSmoothDiscCorrectionsDefaulted = true;
	}

	SaveConfig();
}

simulated function string GetSetting(string Name) {
	return Name$":"@GetPropertyText(Name)$Chr(10);
}

simulated function string DumpSkinIndexMaps() {
	local int i;
	local string Result;

	Result = "";
	for (i = 0; i < arraycount(SkinEnemyIndexMap); ++i)
		Result = Result$"SkinEnemyIndexMap["$i$"]:"@SkinEnemyIndexMap[i]$Chr(10);
	for (i = 0; i < arraycount(SkinTeamIndexMap); ++i)
		Result = Result$"SkinTeamIndexMap["$i$"]:"@SkinTeamIndexMap[i]$Chr(10);

	return Result;
}

simulated function string DumpHitSounds() {
	local int i;
	local string Result;

	Result = "";
	for (i = 0; i < arraycount(sHitSound); i++)
		if (sHitSound[i] != "")
			Result = Result$"sHitSound["$i$"]:"@sHitSound[i]$Chr(10);

	return Result;
}

static function string DumpColor(out Color C) {
	return "(R="$C.R$",G="$C.G$",B="$C.B$",A="$C.A$")";
}

static function string DumpCrosshairLayer(out CrosshairLayerDescr L) {
	return "(Texture="$L.Texture$",OffsetX="$L.OffsetX$",OffsetY="$L.OffsetY$",ScaleX="$L.ScaleX$",ScaleY="$L.ScaleY$",Color="$DumpColor(L.Color)$",Style="$L.Style$",bSmooth="$L.bSmooth$",bUse="$L.bUse$",Shape="$L.Shape$",Thickness="$L.Thickness$")";
}

// How many layers a crosshair can have. (For other classes: arraycount needs the array itself.)
simulated function int CrosshairLayerCount() {
	return arraycount(CrosshairLayers);
}

simulated function string DumpCrosshairLayers() {
	local int i;
	local string Result;

	Result = "";
	for (i = 0; i < arraycount(CrosshairLayers); i++)
		if (CrosshairLayers[i].bUse)
			Result = Result$"CrosshairLayers["$i$"]:"@DumpCrosshairLayer(CrosshairLayers[i])$Chr(10);

	return Result;
}

// The presets: one line for each with its name, then the layers of every
// preset that is not picked. The picked one's are CrosshairLayers above.
simulated function string DumpCrosshairPresets() {
	local int i, j;
	local string Result;
	local IGPlus_CrosshairPreset P;
	local CrosshairLayerDescr L;

	Result = "";
	for (i = 0; i < arraycount(CrosshairPresets); i++) {
		P = CrosshairPresets[i];
		if (P == none || P.PresetName == "")
			continue;
		Result = Result$"CrosshairPresets["$i$"]:"@P.PresetName$Chr(10);
		if (i == CrosshairPreset)
			continue;
		for (j = 0; j < arraycount(CrosshairLayers); j++) {
			L = P.GetLayer(j);
			if (L.bUse)
				Result = Result$"CrosshairPresets["$i$"].Layers["$j$"]:"@DumpCrosshairLayer(L)$Chr(10);
		}
	}

	return Result;
}

simulated function CrosshairLayerDescr GetCrosshairLayer(int i) {
	return CrosshairLayers[i];
}

simulated function SetCrosshairLayerTexture(int i, coerce string T) {
	CrosshairLayers[i].Texture = T;
}

simulated function SetCrosshairLayerOffsetX(int i, int O) {
	CrosshairLayers[i].OffsetX = O;
}

simulated function SetCrosshairLayerOffsetY(int i, int O) {
	CrosshairLayers[i].OffsetY = O;
}

simulated function SetCrosshairLayerScaleX(int i, float S) {
	CrosshairLayers[i].ScaleX = S;
}

simulated function SetCrosshairLayerScaleY(int i, float S) {
	CrosshairLayers[i].ScaleY = S;
}

simulated function SetCrosshairLayerColor(int i, color C) {
	CrosshairLayers[i].Color = C;
}

simulated function SetCrosshairLayerStyle(int i, int S) {
	CrosshairLayers[i].Style = S;
}

simulated function SetCrosshairLayerSmooth(int i, bool S) {
	CrosshairLayers[i].bSmooth = S;
}

simulated function SetCrosshairLayerUse(int i, bool U) {
	CrosshairLayers[i].bUse = U;
}

simulated function SetCrosshairLayerShape(int i, int S) {
	CrosshairLayers[i].Shape = S;
}

simulated function SetCrosshairLayerThickness(int i, int T) {
	CrosshairLayers[i].Thickness = T;
}

static function EHitSoundSource IntToHitSoundSource(int A) {
	switch(A) {
		case 0: return HSSRC_Server;
		case 1: return HSSRC_Client;
	}
	return HSSRC_Server;
}

static function EFlipAnimationFix IntToFlipAnimationFix(int A) {
	switch(A) {
		case 1: return FAF_Instant;
		case 2: return FAF_FinishFlip;
	}
	return FAF_Off;
}

static function EHitEffectSource IntToHitEffectSource(int A) {
	switch(A) {
		case 0: return HESRC_Server;
		case 1: return HESRC_Client;
	}
	return HESRC_Client;
}

static function EHitMarkerSource IntToHitMarkerSource(int A) {
	switch(A) {
		case 0: return HMSRC_Server;
		case 1: return HMSRC_Client;
	}
	return HMSRC_Server;
}

static function EHitMarkerColorMode IntToHitMarkerColorMode(int A) {
	switch(A) {
		case 0: return HMCM_FriendOrFoe;
		case 1: return HMCM_TeamColor;
	}
	return HMCM_FriendOrFoe;
}

simulated function CycleFraggerScope() {
	switch(FraggerScopeChoice) {
		case FSC_None:     FraggerScopeChoice = FSC_Moveable; break;
		case FSC_Moveable: FraggerScopeChoice = FSC_Static; break;
		case FSC_Static:   FraggerScopeChoice = FSC_None; break;
	}
	SaveConfig();
}

simulated function string DumpSettings() {
	return "IG+ Client Settings:"$Chr(10)$
		GetSetting("bForceModels")$
		GetSetting("bDemoShowRealModels")$
		GetSetting("bTeamInfo")$
		GetSetting("bShootDead")$
		GetSetting("bDoEndShot")$
		GetSetting("bAutoDemo")$
		GetSetting("DemoMask")$
		GetSetting("DemoPath")$
		GetSetting("DemoChar")$
		GetSetting("DesiredSkin")$
		GetSetting("DesiredSkinFemale")$
		GetSetting("DesiredTeamSkin")$
		GetSetting("DesiredTeamSkinFemale")$
		DumpSkinIndexMaps()$
		GetSetting("bSkinEnemyUseIndexMap")$
		GetSetting("bSkinTeamUseIndexMap")$
		GetSetting("bUnlitSkins")$
		GetSetting("bEnableHitSounds")$
		GetSetting("bEnableTeamHitSounds")$
		GetSetting("bHitSoundPitchShift")$
		GetSetting("bHitSoundTeamPitchShift")$
		GetSetting("HitSoundSource")$
		GetSetting("SelectedHitSound")$
		GetSetting("SelectedTeamHitSound")$
		GetSetting("HitSoundVolume")$
		GetSetting("HitSoundTeamVolume")$
		DumpHitSounds()$
		GetSetting("cShockBeam")$
		GetSetting("bHideOwnBeam")$
		GetSetting("bBeamEnableLight")$
		GetSetting("BeamScale")$
		GetSetting("BeamFadeCurve")$
		GetSetting("BeamDuration")$
		GetSetting("BeamOriginMode")$
		GetSetting("BeamDestinationMode")$
		GetSetting("SSRRingType")$
		GetSetting("HitEffectSource")$
		GetSetting("DesiredNetUpdateRate")$
		GetSetting("bNoOwnFootsteps")$
		GetSetting("bLogClientMessages")$
		GetSetting("bDemoShowClientMessages")$
		GetSetting("bDebugMovement")$
		GetSetting("bShowDebugDataOnScreen")$
		GetSetting("FlipAnimationFix")$
		GetSetting("bEnableKillCam")$
		GetSetting("FakeCAPInterval")$
		GetSetting("bCameraCorrectionSmoothing")$
		GetSetting("CameraCorrectionSmoothingTime")$
		GetSetting("bSmoothLiftJump")$
		GetSetting("bPredictedSwitching")$
		GetSetting("bPredictedTranslocation")$
		GetSetting("bPredictedDiscBoost")$
		GetSetting("bSmoothDiscCorrections")$
		GetSetting("MinDodgeClickTime")$
		GetSetting("bUseOldMouseInput")$
		GetSetting("SmoothVRController")$
		GetSetting("bShowFPS")$
		GetSetting("FPSLocationX")$
		GetSetting("FPSLocationY")$
		GetSetting("FPSDetail")$
		GetSetting("FPSCounterSmoothingStrength")$
		GetSetting("bSpectatorShowDamageNumbers")$
		GetSetting("DamageNumberDuration")$
		GetSetting("DamageNumberFade")$
		GetSetting("KillCamMinDelay")$
		GetSetting("bReduceEyeHeightInAir")$
		GetSetting("bAllowWeaponShake")$
		GetSetting("bAutoReady")$
		GetSetting("bShowDeathReport")$
		GetSetting("bSmoothFOVChanges")$
		GetSetting("bEnableLocationOffsetFix")$
		GetSetting("bEnableKillFeed")$
		GetSetting("KillFeedX")$
		GetSetting("KillFeedY")$
		GetSetting("KillFeedSpeed")$
		GetSetting("KillFeedScale")$
		GetSetting("FraggerScopeChoice")$
		GetSetting("bEnableNetStats")$
		GetSetting("bNetStatsUnconfirmedTime")$
		GetSetting("bNetStatsLocationError")$
		GetSetting("bNetStatsFrameTime")$
		GetSetting("NetStatsLocationX")$
		GetSetting("NetStatsLocationY")$
		GetSetting("NetStatsWidth")$
		GetSetting("bEnableHitMarker")$
		GetSetting("bEnableTeamHitMarker")$
		GetSetting("HitMarkerColorMode")$
		GetSetting("HitMarkerColor")$
		GetSetting("HitMarkerTeamColor")$
		GetSetting("HitMarkerSize")$
		GetSetting("HitMarkerOffset")$
		GetSetting("HitMarkerDuration")$
		GetSetting("HitMarkerDecayExponent")$
		GetSetting("HitMarkerSource")$
		GetSetting("bUseCrosshairFactory")$
		GetSetting("CrosshairPreset")$
		GetSetting("bBioUseClientSideAnimations")$
		GetSetting("bShockBeamUseClientSideAnimations")$
		GetSetting("bShockProjectileUseClientSideAnimations")$
		GetSetting("bPredictiveShockCombos")$
		GetSetting("bPulseUseClientSideAnimations")$
		GetSetting("bRipperUseClientSideAnimations")$
		GetSetting("bFlakUseClientSideAnimations")$
		GetSetting("bRocketUseClientSideAnimations")$
		GetSetting("bSniperUseClientSideAnimations")$
		GetSetting("bTranslocatorUseClientSideAnimations")$
		DumpCrosshairLayers()$
		DumpCrosshairPresets();
}

defaultproperties
{
	bForceModels=False
	bDemoShowRealModels=True
	bTeamInfo=True
	bDoEndShot=False
	bAutoDemo=False
	bShootDead=False
	DemoMask="%l_[%y_%m_%d_%t]_[%c]_%e"
	DemoPath=""
	DemoChar=""
	DesiredSkin=9
	DesiredSkinFemale=0
	DesiredTeamSkin=9
	DesiredTeamSkinFemale=0
	bUnlitSkins=True
	bEnableHitSounds=True
	bEnableTeamHitSounds=False
	bHitSoundPitchShift=True
	bHitSoundTeamPitchShift=False
	HitSoundSource=HSSRC_Server
	SelectedHitSound=0
	SelectedTeamHitSound=2
	HitSoundVolume=4
	HitSoundTeamVolume=4
	DefaultHitSound(0)=Sound'HitSound'
	DefaultHitSound(1)=Sound'StingerFire'
	DefaultHitSound(2)=Sound'HitSoundFriendly'
	DefaultHitSound(3)=Sound'HitSound1'
	cShockBeam=1
	bHideOwnBeam=False
	bBeamEnableLight=True
	BeamScale=0.45
	BeamFadeCurve=4
	BeamDuration=0.75
	BeamOriginMode=0
	BeamDestinationMode=0
	SSRRingType=1
	HitEffectSource=HESRC_Client
	DesiredNetUpdateRate=200.0
	DesiredNetspeed=25000
	bNoOwnFootsteps=False
	bLogClientMessages=True
	bDemoShowClientMessages=False
	bDebugMovement=False
	bShowDebugDataOnScreen=False
	FlipAnimationFix=FAF_FinishFlip
	bEnableKillCam=False
	FakeCAPInterval=0.1
	bCameraCorrectionSmoothing=False
	CameraCorrectionSmoothingTime=0.1
	bSmoothLiftJump=True
	bPredictedSwitching=True
	bPredictedTranslocation=True
	bPredictedDiscBoost=True
	bSmoothDiscCorrections=True
	MinDodgeClickTime=0
	bUseOldMouseInput=False
	SmoothVRController=(p=0.09,i=0.05,d=0.00)
	bShowFPS=False
	FPSLocationX=1.0
	FPSLocationY=0.0
	FPSDetail=0
	FPSCounterSmoothingStrength=1000
	bSpectatorShowDamageNumbers=False
	DamageNumberDuration=2.5
	DamageNumberFade=5.0
	KillCamMinDelay=0.0
	bReduceEyeHeightInAir=False
	bAllowWeaponShake=True
	bAutoReady=True
	bShowDeathReport=False
	bSmoothFOVChanges=False
	bEnableLocationOffsetFix=True
	bEnableKillFeed=True
	KillFeedX=0.0
	KillFeedY=0.5
	KillFeedSpeed=1.0
	KillFeedScale=1.0
	FraggerScopeChoice=FSC_Moveable
	bEnableNetStats=False
	bNetStatsUnconfirmedTime=True
	bNetStatsLocationError=True
	bNetStatsFrameTime=False
	NetStatsLocationX=0.5
	NetStatsLocationY=0.0
	NetStatsWidth=511
	bEnableHitMarker=False
	bEnableTeamHitMarker=False
	HitMarkerColorMode=HMCM_FriendOrFoe
	HitMarkerColor=(R=255,G=0,B=0,A=255)
	HitMarkerTeamColor=(R=0,G=0,B=255,A=255)
	HitMarkerSize=128.0
	HitMarkerOffset=32.0
	HitMarkerDuration=0.3
	HitMarkerDecayExponent=5.0
	HitMarkerSource=HMSRC_Server
	bUseCrosshairFactory=False
	bBioUseClientSideAnimations=True
	bShockBeamUseClientSideAnimations=True
	bShockProjectileUseClientSideAnimations=True
	bPredictiveShockCombos=True
	bPulseUseClientSideAnimations=True
	bRipperUseClientSideAnimations=True
	bFlakUseClientSideAnimations=True
	bRocketUseClientSideAnimations=True
	bSniperUseClientSideAnimations=True
	bTranslocatorUseClientSideAnimations=True

	MenuX=200
	MenuY=200
	MenuWidth=240
	MenuHeight=400
}
