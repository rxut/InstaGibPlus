class IGPlus_ServerSettingsContent extends UMenuPageWindow;

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

var UWindowLabelControl Lbl_General;
var localized string GeneralText;
var UWindowCheckbox Chk_bAutoPause;
var localized string bAutoPauseText;
var localized string bAutoPauseHelp;
var IGPlus_EditControl Edit_PauseTotalTime;
var localized string PauseTotalTimeText;
var localized string PauseTotalTimeHelp;
var IGPlus_EditControl Edit_PauseTime;
var localized string PauseTimeText;
var localized string PauseTimeHelp;
var UWindowCheckbox Chk_bForceDemo;
var localized string bForceDemoText;
var localized string bForceDemoHelp;
var UWindowCheckbox Chk_bRestrictTrading;
var localized string bRestrictTradingText;
var localized string bRestrictTradingHelp;
var IGPlus_EditControl Edit_MaxTradeTimeMargin;
var localized string MaxTradeTimeMarginText;
var localized string MaxTradeTimeMarginHelp;
var IGPlus_EditControl Edit_TradePingMargin;
var localized string TradePingMarginText;
var localized string TradePingMarginHelp;
var IGPlus_EditControl Edit_KillCamDelay;
var localized string KillCamDelayText;
var localized string KillCamDelayHelp;
var IGPlus_EditControl Edit_KillCamDuration;
var localized string KillCamDurationText;
var localized string KillCamDurationHelp;
var IGPlus_ComboBox Cmb_BrightskinMode;
var localized string BrightskinModeText;
var localized string BrightskinModeHelp;
var localized string BrightskinModeDisabled;
var localized string BrightskinModeUnlit;
var IGPlus_EditControl Edit_PlayerScale;
var localized string PlayerScaleText;
var localized string PlayerScaleHelp;
var UWindowCheckbox Chk_bAlwaysRenderFlagCarrier;
var localized string bAlwaysRenderFlagCarrierText;
var localized string bAlwaysRenderFlagCarrierHelp;
var UWindowCheckbox Chk_bAlwaysRenderDroppedFlags;
var localized string bAlwaysRenderDroppedFlagsText;
var localized string bAlwaysRenderDroppedFlagsHelp;
var IGPlus_ComboBox Cmb_HitFeedbackMode;
var localized string HitFeedbackModeText;
var localized string HitFeedbackModeHelp;
var localized string HitFeedbackModeDisabled;
var localized string HitFeedbackModeVisibleOnly;
var localized string HitFeedbackModeAlways;
var localized string bEnablePingCompensatedSpawnHelp;

var UWindowLabelControl Lbl_Movement;
var localized string MovementText;
var UWindowCheckbox Chk_bJumpingPreservesMomentum;
var localized string bJumpingPreservesMomentumText;
var localized string bJumpingPreservesMomentumHelp;
var UWindowCheckbox Chk_bOldLandingMomentum;
var localized string bOldLandingMomentumText;
var localized string bOldLandingMomentumHelp;
var UWindowCheckbox Chk_bEnableSingleButtonDodge;
var localized string bEnableSingleButtonDodgeText;
var localized string bEnableSingleButtonDodgeHelp;
var UWindowCheckbox Chk_bUseFlipAnimation;
var localized string bUseFlipAnimationText;
var localized string bUseFlipAnimationHelp;
var UWindowCheckbox Chk_bEnableWallDodging;
var localized string bEnableWallDodgingText;
var localized string bEnableWallDodgingHelp;
var UWindowCheckbox Chk_bDodgePreserveZMomentum;
var localized string bDodgePreserveZMomentumText;
var localized string bDodgePreserveZMomentumHelp;
var IGPlus_EditControl Edit_MaxMultiDodges;
var localized string MaxMultiDodgesText;
var localized string MaxMultiDodgesHelp;
var UWindowCheckbox Chk_bEnablePingCompensatedSpawn;
var localized string bEnablePingCompensatedSpawnText;

var UWindowLabelControl Lbl_Networking;
var localized string NetworkingText;
var IGPlus_EditControl Edit_MaxPosError;
var localized string MaxPosErrorText;
var localized string MaxPosErrorHelp;
var IGPlus_EditControl Edit_MaxHitError;
var localized string MaxHitErrorText;
var localized string MaxHitErrorHelp;
var IGPlus_EditControl Edit_MaxJitterTime;
var localized string MaxJitterTimeText;
var localized string MaxJitterTimeHelp;
var IGPlus_EditControl Edit_WarpFixDelay;
var localized string WarpFixDelayText;
var localized string WarpFixDelayHelp;
var IGPlus_EditControl Edit_FireTimeout;
var localized string FireTimeoutText;
var localized string FireTimeoutHelp;
var IGPlus_EditControl Edit_MinNetUpdateRate;
var localized string MinNetUpdateRateText;
var localized string MinNetUpdateRateHelp;
var IGPlus_EditControl Edit_MaxNetUpdateRate;
var localized string MaxNetUpdateRateText;
var localized string MaxNetUpdateRateHelp;
var UWindowCheckbox Chk_bEnableInputReplication;
var localized string bEnableInputReplicationText;
var localized string bEnableInputReplicationHelp;
var UWindowCheckbox Chk_bEnableServerExtrapolation;
var localized string bEnableServerExtrapolationText;
var localized string bEnableServerExtrapolationHelp;
var UWindowCheckbox Chk_bEnableServerPacketReordering;
var localized string bEnableServerPacketReorderingText;
var localized string bEnableServerPacketReorderingHelp;
var UWindowCheckbox Chk_bEnableLoosePositionCheck;
var localized string bEnableLoosePositionCheckText;
var localized string bEnableLoosePositionCheckHelp;
var UWindowCheckbox Chk_bPlayersAlwaysRelevant;
var localized string bPlayersAlwaysRelevantText;
var localized string bPlayersAlwaysRelevantHelp;
var UWindowCheckbox Chk_bEnableJitterBounding;
var localized string bEnableJitterBoundingText;
var localized string bEnableJitterBoundingHelp;
var IGPlus_EditControl Edit_LooseCheckCorrectionFactor;
var localized string LooseCheckCorrectionFactorText;
var localized string LooseCheckCorrectionFactorHelp;
var IGPlus_EditControl Edit_LooseCheckCorrectionFactorOnMover;
var localized string LooseCheckCorrectionFactorOnMoverText;
var localized string LooseCheckCorrectionFactorOnMoverHelp;
var UWindowCheckbox Chk_bEnableSnapshotInterpolation;
var localized string bEnableSnapshotInterpolationText;
var localized string bEnableSnapshotInterpolationHelp;
var IGPlus_EditControl Edit_SnapshotInterpSendHz;
var localized string SnapshotInterpSendHzText;
var localized string SnapshotInterpSendHzHelp;
var IGPlus_EditControl Edit_SnapshotInterpRewindMs;
var localized string SnapshotInterpRewindMsText;
var localized string SnapshotInterpRewindMsHelp;
var UWindowCheckbox Chk_bEnableWarpFix;
var localized string bEnableWarpFixText;
var localized string bEnableWarpFixHelp;

var UWindowLabelControl Lbl_Debug;
var localized string DebugText;
var UWindowCheckbox Chk_ShowTouchedPackage;
var localized string ShowTouchedPackageText;
var localized string ShowTouchedPackageHelp;
var UWindowCheckbox Chk_bEnableDamageDebugMode;
var localized string bEnableDamageDebugModeText;
var localized string bEnableDamageDebugModeHelp;
var UWindowCheckbox Chk_bEnableDamageDebugConsoleMessages;
var localized string bEnableDamageDebugConsoleMessagesText;
var localized string bEnableDamageDebugConsoleMessagesHelp;
var UWindowCheckbox Chk_bEnableHitboxDebugMode;
var localized string bEnableHitboxDebugModeText;
var localized string bEnableHitboxDebugModeHelp;

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

function ServerSettings FindServerSettingsObject() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none)
		return P.IGPlus_GetServerSettingsObject();

	S = ResolveOwnerBBSpectator();
	if (S != none)
		return S.IGPlus_GetServerSettingsObject();

	return none;
}

function ResetLocalServerSettingsCache() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none) {
		P.IGPlus_ServerSettingsInit();
		return;
	}

	S = ResolveOwnerBBSpectator();
	if (S != none)
		S.IGPlus_ServerSettingsInit();
}

function bool AreServerSettingsLoaded() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none)
		return P.IGPlus_ServerSettingsMenuLoaded;

	S = ResolveOwnerBBSpectator();
	if (S != none)
		return S.IGPlus_ServerSettingsMenuLoaded;

	return false;
}

function bool HasServerAdminAccess() {
	local bbPlayer P;
	local bbCHSpectator S;

	P = ResolveOwnerBBPlayer();
	if (P != none)
		return P.IGPlus_ServerSettingsMenuCanEdit;

	S = ResolveOwnerBBSpectator();
	if (S != none)
		return S.IGPlus_ServerSettingsMenuCanEdit;

	return false;
}

function float GetNowTimeSeconds() {
	local LevelInfo L;

	L = GetLevel();
	if (L == none)
		return 0;

	return L.TimeSeconds;
}

function bool IsAdmin() {
	local PlayerPawn P;

	P = ResolveOwnerPawn();
	if (P == none)
		return false;

	if (P.bAdmin)
		return true;

	if (P.PlayerReplicationInfo != none && P.PlayerReplicationInfo.bAdmin)
		return true;

	return false;
}

function RequestServerSettings(optional bool bForce) {
	local bbPlayer P;
	local bbCHSpectator S;
	local float NowTime;

	NowTime = GetNowTimeSeconds();
	if (bForce == false && NowTime < NextRefreshRequestTime)
		return;

	P = ResolveOwnerBBPlayer();
	if (P != none) {
		P.IGPlus_ServerRequestSettings();
		NextRefreshRequestTime = NowTime + 1.0;
		return;
	}

	S = ResolveOwnerBBSpectator();
	if (S != none) {
		S.IGPlus_ServerRequestSettings();
		NextRefreshRequestTime = NowTime + 1.0;
	}
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
	} else if (AreServerSettingsLoaded() == false)
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

function SendServerSetting(string Key, string Value, optional bool bSendFeedback) {
	if (bSendFeedback)
		SendMutateCommand("IGPlusServerSet "$Key$" "$Value);
	else
		SendMutateCommand("IGPlusServerSetSilent "$Key$" "$Value);
}

function bool AreServerSettingValuesEqual(string ValueA, string ValueB) {
	return Caps(class'StringUtils'.static.Trim(ValueA)) == Caps(class'StringUtils'.static.Trim(ValueB));
}

function bool SaveServerSettingIfChanged(ServerSettings S, string Key, string Value) {
	local string CurrentValue;

	if (S != none)
		CurrentValue = S.GetPropertyText(Key);

	if (S == none || AreServerSettingValuesEqual(CurrentValue, Value) == false) {
		// Use the non-silent command only for changed values so admins get a concise confirmation.
		SendServerSetting(Key, Value, true);
		if (S != none)
			S.SetPropertyText(Key, Value);
		return true;
	}

	return false;
}

function string HitFeedbackModeIndexToValue(int Index) {
	switch (Clamp(Index, 0, 2)) {
		case 0: return "HFM_Disabled";
		case 1: return "HFM_VisibleOnly";
		case 2: return "HFM_Always";
	}

	return "HFM_Disabled";
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

function SaveServerSettings() {
	local ServerSettings S;

	S = FindServerSettingsObject();

	SaveServerSettingIfChanged(S, "bAutoPause", BoolToString(Chk_bAutoPause.bChecked));
	SaveServerSettingIfChanged(S, "PauseTotalTime", Edit_PauseTotalTime.GetValue());
	SaveServerSettingIfChanged(S, "PauseTime", Edit_PauseTime.GetValue());
	SaveServerSettingIfChanged(S, "bForceDemo", BoolToString(Chk_bForceDemo.bChecked));
	SaveServerSettingIfChanged(S, "bRestrictTrading", BoolToString(Chk_bRestrictTrading.bChecked));
	SaveServerSettingIfChanged(S, "MaxTradeTimeMargin", Edit_MaxTradeTimeMargin.GetValue());
	SaveServerSettingIfChanged(S, "TradePingMargin", Edit_TradePingMargin.GetValue());
	SaveServerSettingIfChanged(S, "KillCamDelay", Edit_KillCamDelay.GetValue());
	SaveServerSettingIfChanged(S, "KillCamDuration", Edit_KillCamDuration.GetValue());
	SaveServerSettingIfChanged(S, "BrightskinMode", string(Cmb_BrightskinMode.GetSelectedIndex()));
	SaveServerSettingIfChanged(S, "PlayerScale", Edit_PlayerScale.GetValue());
	SaveServerSettingIfChanged(S, "bAlwaysRenderFlagCarrier", BoolToString(Chk_bAlwaysRenderFlagCarrier.bChecked));
	SaveServerSettingIfChanged(S, "bAlwaysRenderDroppedFlags", BoolToString(Chk_bAlwaysRenderDroppedFlags.bChecked));
	SaveServerSettingIfChanged(S, "HitFeedbackMode", HitFeedbackModeIndexToValue(Cmb_HitFeedbackMode.GetSelectedIndex()));
	SaveServerSettingIfChanged(S, "bEnablePingCompensatedSpawn", BoolToString(Chk_bEnablePingCompensatedSpawn.bChecked));

	SaveServerSettingIfChanged(S, "bJumpingPreservesMomentum", BoolToString(Chk_bJumpingPreservesMomentum.bChecked));
	SaveServerSettingIfChanged(S, "bOldLandingMomentum", BoolToString(Chk_bOldLandingMomentum.bChecked));
	SaveServerSettingIfChanged(S, "bEnableSingleButtonDodge", BoolToString(Chk_bEnableSingleButtonDodge.bChecked));
	SaveServerSettingIfChanged(S, "bUseFlipAnimation", BoolToString(Chk_bUseFlipAnimation.bChecked));
	SaveServerSettingIfChanged(S, "bEnableWallDodging", BoolToString(Chk_bEnableWallDodging.bChecked));
	SaveServerSettingIfChanged(S, "bDodgePreserveZMomentum", BoolToString(Chk_bDodgePreserveZMomentum.bChecked));
	SaveServerSettingIfChanged(S, "MaxMultiDodges", Edit_MaxMultiDodges.GetValue());

	SaveServerSettingIfChanged(S, "MaxPosError", Edit_MaxPosError.GetValue());
	SaveServerSettingIfChanged(S, "MaxHitError", Edit_MaxHitError.GetValue());
	SaveServerSettingIfChanged(S, "FireTimeout", Edit_FireTimeout.GetValue());
	SaveServerSettingIfChanged(S, "MinNetUpdateRate", Edit_MinNetUpdateRate.GetValue());
	SaveServerSettingIfChanged(S, "MaxNetUpdateRate", Edit_MaxNetUpdateRate.GetValue());
	SaveServerSettingIfChanged(S, "bEnableServerExtrapolation", BoolToString(Chk_bEnableServerExtrapolation.bChecked));
	SaveServerSettingIfChanged(S, "bEnableServerPacketReordering", BoolToString(Chk_bEnableServerPacketReordering.bChecked));
	SaveServerSettingIfChanged(S, "bPlayersAlwaysRelevant", BoolToString(Chk_bPlayersAlwaysRelevant.bChecked));
	SaveServerSettingIfChanged(S, "bEnableJitterBounding", BoolToString(Chk_bEnableJitterBounding.bChecked));
	SaveServerSettingIfChanged(S, "MaxJitterTime", Edit_MaxJitterTime.GetValue());
	SaveServerSettingIfChanged(S, "bEnableInputReplication", BoolToString(Chk_bEnableInputReplication.bChecked));
	SaveServerSettingIfChanged(S, "bEnableSnapshotInterpolation", BoolToString(Chk_bEnableSnapshotInterpolation.bChecked));
	SaveServerSettingIfChanged(S, "SnapshotInterpSendHz", Edit_SnapshotInterpSendHz.GetValue());
	SaveServerSettingIfChanged(S, "SnapshotInterpRewindMs", Edit_SnapshotInterpRewindMs.GetValue());
	SaveServerSettingIfChanged(S, "bEnableLoosePositionCheck", BoolToString(Chk_bEnableLoosePositionCheck.bChecked));
	SaveServerSettingIfChanged(S, "LooseCheckCorrectionFactor", Edit_LooseCheckCorrectionFactor.GetValue());
	SaveServerSettingIfChanged(S, "LooseCheckCorrectionFactorOnMover", Edit_LooseCheckCorrectionFactorOnMover.GetValue());
	SaveServerSettingIfChanged(S, "bEnableWarpFix", BoolToString(Chk_bEnableWarpFix.bChecked));
	SaveServerSettingIfChanged(S, "WarpFixDelay", Edit_WarpFixDelay.GetValue());

	SaveServerSettingIfChanged(S, "ShowTouchedPackage", BoolToString(Chk_ShowTouchedPackage.bChecked));
	SaveServerSettingIfChanged(S, "bEnableDamageDebugMode", BoolToString(Chk_bEnableDamageDebugMode.bChecked));
	SaveServerSettingIfChanged(S, "bEnableDamageDebugConsoleMessages", BoolToString(Chk_bEnableDamageDebugConsoleMessages.bChecked));
	SaveServerSettingIfChanged(S, "bEnableHitboxDebugMode", BoolToString(Chk_bEnableHitboxDebugMode.bChecked));
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
	ResetLocalServerSettingsCache();
	RequestServerSettings(true);
}

function AdminLogoutFromUI() {
	local PlayerPawn P;

	P = ResolveOwnerPawn();
	if (P == none)
		return;

	P.AdminLogout();
	bLoadSucceeded = false;
	bPendingAdminLogin = false;
	ResetLocalServerSettingsCache();
	RequestServerSettings(true);
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

function ConfigureResponsiveServerControls(Canvas C, float ControlWidth) {
	ConfigureFixedWidthCombo(Cmb_BrightskinMode, C, ControlWidth, 180);
	ConfigureFixedWidthCombo(Cmb_HitFeedbackMode, C, ControlWidth, 180);

	ConfigureFixedWidthEdit(Edit_PauseTotalTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PauseTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MaxTradeTimeMargin, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_TradePingMargin, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_KillCamDelay, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_KillCamDuration, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_PlayerScale, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MaxMultiDodges, C, ControlWidth, 80);

	ConfigureFixedWidthEdit(Edit_MaxPosError, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MaxHitError, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_FireTimeout, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MinNetUpdateRate, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MaxNetUpdateRate, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_MaxJitterTime, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SnapshotInterpSendHz, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_SnapshotInterpRewindMs, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_LooseCheckCorrectionFactor, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_LooseCheckCorrectionFactorOnMover, C, ControlWidth, 80);
	ConfigureFixedWidthEdit(Edit_WarpFixDelay, C, ControlWidth, 80);
}

function LoadServerSettings() {
	local ServerSettings S;

	S = FindServerSettingsObject();
	if (S == none)
		return;

	Chk_bAutoPause.bChecked = S.bAutoPause;
	Edit_PauseTotalTime.SetValue(string(S.PauseTotalTime));
	Edit_PauseTime.SetValue(string(S.PauseTime));
	Chk_bForceDemo.bChecked = S.bForceDemo;
	Chk_bRestrictTrading.bChecked = S.bRestrictTrading;
	Edit_MaxTradeTimeMargin.SetValue(string(S.MaxTradeTimeMargin));
	Edit_TradePingMargin.SetValue(string(S.TradePingMargin));
	Edit_KillCamDelay.SetValue(string(S.KillCamDelay));
	Edit_KillCamDuration.SetValue(string(S.KillCamDuration));
	Cmb_BrightskinMode.SetSelectedIndex(Clamp(int(S.BrightskinMode), 0, 1));
	Edit_PlayerScale.SetValue(string(S.PlayerScale));
	Chk_bAlwaysRenderFlagCarrier.bChecked = S.bAlwaysRenderFlagCarrier;
	Chk_bAlwaysRenderDroppedFlags.bChecked = S.bAlwaysRenderDroppedFlags;
	Cmb_HitFeedbackMode.SetSelectedIndex(Clamp(int(S.HitFeedbackMode), 0, 2));

	Chk_bJumpingPreservesMomentum.bChecked = S.bJumpingPreservesMomentum;
	Chk_bOldLandingMomentum.bChecked = S.bOldLandingMomentum;
	Chk_bEnableSingleButtonDodge.bChecked = S.bEnableSingleButtonDodge;
	Chk_bUseFlipAnimation.bChecked = S.bUseFlipAnimation;
	Chk_bEnableWallDodging.bChecked = S.bEnableWallDodging;
	Chk_bDodgePreserveZMomentum.bChecked = S.bDodgePreserveZMomentum;
	Edit_MaxMultiDodges.SetValue(string(S.MaxMultiDodges));
	Chk_bEnablePingCompensatedSpawn.bChecked = S.bEnablePingCompensatedSpawn;

	Edit_MaxPosError.SetValue(string(S.MaxPosError));
	Edit_MaxHitError.SetValue(string(S.MaxHitError));
	Edit_MaxJitterTime.SetValue(string(S.MaxJitterTime));
	Edit_WarpFixDelay.SetValue(string(S.WarpFixDelay));
	Edit_FireTimeout.SetValue(string(S.FireTimeout));
	Edit_MinNetUpdateRate.SetValue(string(S.MinNetUpdateRate));
	Edit_MaxNetUpdateRate.SetValue(string(S.MaxNetUpdateRate));
	Chk_bEnableInputReplication.bChecked = S.bEnableInputReplication;
	Chk_bEnableServerExtrapolation.bChecked = S.bEnableServerExtrapolation;
	Chk_bEnableServerPacketReordering.bChecked = S.bEnableServerPacketReordering;
	Chk_bEnableLoosePositionCheck.bChecked = S.bEnableLoosePositionCheck;
	Chk_bPlayersAlwaysRelevant.bChecked = S.bPlayersAlwaysRelevant;
	Chk_bEnableJitterBounding.bChecked = S.bEnableJitterBounding;
	Edit_LooseCheckCorrectionFactor.SetValue(string(S.LooseCheckCorrectionFactor));
	Edit_LooseCheckCorrectionFactorOnMover.SetValue(string(S.LooseCheckCorrectionFactorOnMover));
	Chk_bEnableSnapshotInterpolation.bChecked = S.bEnableSnapshotInterpolation;
	Edit_SnapshotInterpSendHz.SetValue(string(S.SnapshotInterpSendHz));
	Edit_SnapshotInterpRewindMs.SetValue(string(S.SnapshotInterpRewindMs));
	Chk_bEnableWarpFix.bChecked = S.bEnableWarpFix;

	Chk_ShowTouchedPackage.bChecked = S.ShowTouchedPackage;
	Chk_bEnableDamageDebugMode.bChecked = S.bEnableDamageDebugMode;
	Chk_bEnableDamageDebugConsoleMessages.bChecked = S.bEnableDamageDebugConsoleMessages;
	Chk_bEnableHitboxDebugMode.bChecked = S.bEnableHitboxDebugMode;

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

	Lbl_General = CreateSeparator(GeneralText);
	Chk_bAutoPause = CreateCheckbox(bAutoPauseText, bAutoPauseHelp);
	Edit_PauseTotalTime = CreateEdit(ECT_Integer, PauseTotalTimeText, PauseTotalTimeHelp, 6, 80);
	Edit_PauseTime = CreateEdit(ECT_Integer, PauseTimeText, PauseTimeHelp, 6, 80);
	Chk_bForceDemo = CreateCheckbox(bForceDemoText, bForceDemoHelp);
	Chk_bRestrictTrading = CreateCheckbox(bRestrictTradingText, bRestrictTradingHelp);
	Edit_MaxTradeTimeMargin = CreateEdit(ECT_Real, MaxTradeTimeMarginText, MaxTradeTimeMarginHelp, 16, 80);
	Edit_TradePingMargin = CreateEdit(ECT_Real, TradePingMarginText, TradePingMarginHelp, 16, 80);
	Edit_KillCamDelay = CreateEdit(ECT_Real, KillCamDelayText, KillCamDelayHelp, 16, 80);
	Edit_KillCamDuration = CreateEdit(ECT_Real, KillCamDurationText, KillCamDurationHelp, 16, 80);
	Cmb_BrightskinMode = CreateComboBox(BrightskinModeText, BrightskinModeHelp, false, 180);
	Cmb_BrightskinMode.AddItem(BrightskinModeDisabled);
	Cmb_BrightskinMode.AddItem(BrightskinModeUnlit);
	Edit_PlayerScale = CreateEdit(ECT_Real, PlayerScaleText, PlayerScaleHelp, 16, 80);
	Chk_bAlwaysRenderFlagCarrier = CreateCheckbox(bAlwaysRenderFlagCarrierText, bAlwaysRenderFlagCarrierHelp);
	Chk_bAlwaysRenderDroppedFlags = CreateCheckbox(bAlwaysRenderDroppedFlagsText, bAlwaysRenderDroppedFlagsHelp);
	Cmb_HitFeedbackMode = CreateComboBox(HitFeedbackModeText, HitFeedbackModeHelp, false, 180);
	Cmb_HitFeedbackMode.AddItem(HitFeedbackModeDisabled);
	Cmb_HitFeedbackMode.AddItem(HitFeedbackModeVisibleOnly);
	Cmb_HitFeedbackMode.AddItem(HitFeedbackModeAlways);
	Chk_bEnablePingCompensatedSpawn = CreateCheckbox(bEnablePingCompensatedSpawnText, bEnablePingCompensatedSpawnHelp);

	Lbl_Movement = CreateSeparator(MovementText);
	Chk_bJumpingPreservesMomentum = CreateCheckbox(bJumpingPreservesMomentumText, bJumpingPreservesMomentumHelp);
	Chk_bOldLandingMomentum = CreateCheckbox(bOldLandingMomentumText, bOldLandingMomentumHelp);
	Chk_bEnableSingleButtonDodge = CreateCheckbox(bEnableSingleButtonDodgeText, bEnableSingleButtonDodgeHelp);
	Chk_bUseFlipAnimation = CreateCheckbox(bUseFlipAnimationText, bUseFlipAnimationHelp);
	Chk_bEnableWallDodging = CreateCheckbox(bEnableWallDodgingText, bEnableWallDodgingHelp);
	Chk_bDodgePreserveZMomentum = CreateCheckbox(bDodgePreserveZMomentumText, bDodgePreserveZMomentumHelp);
	Edit_MaxMultiDodges = CreateEdit(ECT_Integer, MaxMultiDodgesText, MaxMultiDodgesHelp, 6, 80);

	Lbl_Networking = CreateSeparator(NetworkingText);
	Edit_MaxPosError = CreateEdit(ECT_Integer, MaxPosErrorText, MaxPosErrorHelp, 8, 80);
	Edit_MaxHitError = CreateEdit(ECT_Integer, MaxHitErrorText, MaxHitErrorHelp, 8, 80);
	Edit_FireTimeout = CreateEdit(ECT_Real, FireTimeoutText, FireTimeoutHelp, 16, 80);
	Edit_MinNetUpdateRate = CreateEdit(ECT_Real, MinNetUpdateRateText, MinNetUpdateRateHelp, 16, 80);
	Edit_MaxNetUpdateRate = CreateEdit(ECT_Real, MaxNetUpdateRateText, MaxNetUpdateRateHelp, 16, 80);
	Chk_bEnableServerExtrapolation = CreateCheckbox(bEnableServerExtrapolationText, bEnableServerExtrapolationHelp);
	Chk_bEnableServerPacketReordering = CreateCheckbox(bEnableServerPacketReorderingText, bEnableServerPacketReorderingHelp);
	Chk_bPlayersAlwaysRelevant = CreateCheckbox(bPlayersAlwaysRelevantText, bPlayersAlwaysRelevantHelp);
	Chk_bEnableJitterBounding = CreateCheckbox(bEnableJitterBoundingText, bEnableJitterBoundingHelp);
	Edit_MaxJitterTime = CreateEdit(ECT_Real, MaxJitterTimeText, MaxJitterTimeHelp, 16, 80);
	Chk_bEnableInputReplication = CreateCheckbox(bEnableInputReplicationText, bEnableInputReplicationHelp);
	Chk_bEnableSnapshotInterpolation = CreateCheckbox(bEnableSnapshotInterpolationText, bEnableSnapshotInterpolationHelp);
	Edit_SnapshotInterpSendHz = CreateEdit(ECT_Real, SnapshotInterpSendHzText, SnapshotInterpSendHzHelp, 16, 80);
	Edit_SnapshotInterpRewindMs = CreateEdit(ECT_Real, SnapshotInterpRewindMsText, SnapshotInterpRewindMsHelp, 16, 80);
	Chk_bEnableLoosePositionCheck = CreateCheckbox(bEnableLoosePositionCheckText, bEnableLoosePositionCheckHelp);
	Edit_LooseCheckCorrectionFactor = CreateEdit(ECT_Real, LooseCheckCorrectionFactorText, LooseCheckCorrectionFactorHelp, 16, 80);
	Edit_LooseCheckCorrectionFactorOnMover = CreateEdit(ECT_Real, LooseCheckCorrectionFactorOnMoverText, LooseCheckCorrectionFactorOnMoverHelp, 16, 80);
	Chk_bEnableWarpFix = CreateCheckbox(bEnableWarpFixText, bEnableWarpFixHelp);
	Edit_WarpFixDelay = CreateEdit(ECT_Real, WarpFixDelayText, WarpFixDelayHelp, 16, 80);

	Lbl_Debug = CreateSeparator(DebugText);
	Chk_ShowTouchedPackage = CreateCheckbox(ShowTouchedPackageText, ShowTouchedPackageHelp);
	Chk_bEnableDamageDebugMode = CreateCheckbox(bEnableDamageDebugModeText, bEnableDamageDebugModeHelp);
	Chk_bEnableDamageDebugConsoleMessages = CreateCheckbox(bEnableDamageDebugConsoleMessagesText, bEnableDamageDebugConsoleMessagesHelp);
	Chk_bEnableHitboxDebugMode = CreateCheckbox(bEnableHitboxDebugModeText, bEnableHitboxDebugModeHelp);

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

	if (bPendingAdminLogin || AreServerSettingsLoaded() == false)
		RequestServerSettings();

	bAdmin = HasServerAdminAccess();
	if (bAdmin)
		bPendingAdminLogin = false;
	if (bLastAdminState != bAdmin) {
		bLastAdminState = bAdmin;
		bLoadSucceeded = false;
	}

	if (bAdmin && AreServerSettingsLoaded() && bLoadSucceeded == false)
		LoadServerSettings();

	UpdateStatusText();
	UpdateAuthButton();
	if (Btn_DeletePassword != none && Cmb_AdminPassword != none)
		Btn_DeletePassword.bDisabled = (class'StringUtils'.static.Trim(Cmb_AdminPassword.GetValue()) == "");

	WndWidth = WinWidth - 2*PaddingX;
	ConfigureResponsiveServerControls(C, WndWidth);
	Top = PaddingY;
	bShowSettings = bAdmin && AreServerSettingsLoaded();

	LayoutControl(Lbl_Header, true, WndWidth, Top);
	LayoutControl(Lbl_Status, true, WndWidth, Top);
	LayoutControl(Lbl_MoreInformation, bAdmin, WndWidth, Top);
	LayoutControl(Btn_AdminAuth, true, WndWidth, Top);

	LayoutControl(Lbl_Login, !bAdmin, WndWidth, Top);
	LayoutPasswordControls(C, !bAdmin, WndWidth, Top);

	LayoutControl(Lbl_General, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bAutoPause, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PauseTotalTime, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PauseTime, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bForceDemo, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bRestrictTrading, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MaxTradeTimeMargin, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_TradePingMargin, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_KillCamDelay, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_KillCamDuration, bShowSettings, WndWidth, Top);
	LayoutControl(Cmb_BrightskinMode, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_PlayerScale, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bAlwaysRenderFlagCarrier, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bAlwaysRenderDroppedFlags, bShowSettings, WndWidth, Top);
	LayoutControl(Cmb_HitFeedbackMode, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnablePingCompensatedSpawn, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Movement, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bJumpingPreservesMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bOldLandingMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableSingleButtonDodge, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bUseFlipAnimation, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableWallDodging, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bDodgePreserveZMomentum, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MaxMultiDodges, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Networking, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MaxPosError, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MaxHitError, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_FireTimeout, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MinNetUpdateRate, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MaxNetUpdateRate, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableServerExtrapolation, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableServerPacketReordering, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bPlayersAlwaysRelevant, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableJitterBounding, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_MaxJitterTime, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableInputReplication, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableSnapshotInterpolation, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SnapshotInterpSendHz, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_SnapshotInterpRewindMs, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableLoosePositionCheck, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_LooseCheckCorrectionFactor, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_LooseCheckCorrectionFactorOnMover, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableWarpFix, bShowSettings, WndWidth, Top);
	LayoutControl(Edit_WarpFixDelay, bShowSettings, WndWidth, Top);

	LayoutControl(Lbl_Debug, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_ShowTouchedPackage, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableDamageDebugMode, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableDamageDebugConsoleMessages, bShowSettings, WndWidth, Top);
	LayoutControl(Chk_bEnableHitboxDebugMode, bShowSettings, WndWidth, Top);

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
	ResetLocalServerSettingsCache();
	RequestServerSettings(true);
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

	if (AreServerSettingsLoaded() == false) {
		ResetLocalServerSettingsCache();
		RequestServerSettings(true);
		return;
	}

	SaveServerSettings();
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
	HeaderText="Server Settings"
	StatusAdminText="Admin access granted. Edit settings and click Save."
	StatusLoginText="Admin access required. Enter password and click Login."
	StatusLoadingText="Loading server settings..."
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

	GeneralText="General"
	bAutoPauseText="Enable Auto Pause"
	bAutoPauseHelp="If checked, teams can use match pause functionality in tournament mode"
	PauseTotalTimeText="Total Pause Time"
	PauseTotalTimeHelp="Total pause time in seconds available to each team"
	PauseTimeText="Pause Time"
	PauseTimeHelp="Maximum duration in seconds of a single pause"
	bForceDemoText="Force Demo Recording"
	bForceDemoHelp="If checked, players are forced to record demos"
	bRestrictTradingText="Restrict Trading"
	bRestrictTradingHelp="If checked, trade kills are only accepted within limited timing margins"
	MaxTradeTimeMarginText="Max Trade Time Margin"
	MaxTradeTimeMarginHelp="Maximum allowed trade window in seconds"
	TradePingMarginText="Trade Ping Margin"
	TradePingMarginHelp="Additional trade allowance scaled by player ping"
	KillCamDelayText="Kill Cam Delay"
	KillCamDelayHelp="Delay in seconds before kill cam starts"
	KillCamDurationText="Kill Cam Duration"
	KillCamDurationHelp="How long kill cam runs in seconds"
	BrightskinModeText="Brightskin Mode"
	BrightskinModeHelp="Select how player skins are rendered on clients"
	BrightskinModeDisabled="Disabled"
	BrightskinModeUnlit="Unlit"
	PlayerScaleText="Player Scale"
	PlayerScaleHelp="Scale multiplier applied to player models"
	bAlwaysRenderFlagCarrierText="Always Render Flag Carrier"
	bAlwaysRenderFlagCarrierHelp="If checked, flag carriers are always rendered"
	bAlwaysRenderDroppedFlagsText="Always Render Dropped Flags"
	bAlwaysRenderDroppedFlagsHelp="If checked, dropped flags are always rendered"
	HitFeedbackModeText="Hit Feedback Mode"
	HitFeedbackModeHelp="Controls when hit feedback events are allowed"
	HitFeedbackModeDisabled="Disabled"
	HitFeedbackModeVisibleOnly="Visible Only"
	HitFeedbackModeAlways="Always"
	bEnablePingCompensatedSpawnHelp="If checked, enables ping-compensated spawn behavior"

	MovementText="Movement"
	bJumpingPreservesMomentumText="Jumping Preserves Momentum"
	bJumpingPreservesMomentumHelp="If checked, jumping keeps horizontal momentum more aggressively"
	bOldLandingMomentumText="Old Landing Momentum"
	bOldLandingMomentumHelp="If checked, uses legacy landing momentum handling"
	bEnableSingleButtonDodgeText="Enable Single Button Dodge"
	bEnableSingleButtonDodgeHelp="If checked, allows dodging from single key press input"
	bUseFlipAnimationText="Use Flip Animation"
	bUseFlipAnimationHelp="If checked, uses flip animation for dodge-style movement"
	bEnableWallDodgingText="Enable Wall Dodging"
	bEnableWallDodgingHelp="If checked, allows players to wall dodge"
	bDodgePreserveZMomentumText="Preserve Dodge Z Momentum"
	bDodgePreserveZMomentumHelp="If checked, dodge keeps more vertical momentum"
	MaxMultiDodgesText="Max Multi Dodges"
	MaxMultiDodgesHelp="Maximum allowed chained dodges before touching ground"
	bEnablePingCompensatedSpawnText="Enable Ping Compensated Spawn"

	NetworkingText="Networking"
	MaxPosErrorText="Max Position Error"
	MaxPosErrorHelp="Maximum position error before server correction is forced"
	MaxHitErrorText="Max Hit Error"
	MaxHitErrorHelp="Maximum tolerated hit registration error"
	MaxJitterTimeText="Max Jitter Time"
	MaxJitterTimeHelp="Maximum jitter time in seconds used for movement correction"
	WarpFixDelayText="Warp Fix Delay"
	WarpFixDelayHelp="Delay in seconds before warp-fix smoothing is applied"
	FireTimeoutText="Fire Timeout"
	FireTimeoutHelp="Time in seconds before queued fire input expires"
	MinNetUpdateRateText="Min Net Update Rate"
	MinNetUpdateRateHelp="Minimum per-client update rate the server allows"
	MaxNetUpdateRateText="Max Net Update Rate"
	MaxNetUpdateRateHelp="Maximum per-client update rate the server allows"
	bEnableInputReplicationText="Enable Input Replication"
	bEnableInputReplicationHelp="If checked, replicates movement input data for validation"
	bEnableServerExtrapolationText="Enable Server Extrapolation"
	bEnableServerExtrapolationHelp="If checked, server extrapolates movement between updates"
	bEnableServerPacketReorderingText="Enable Packet Reordering"
	bEnableServerPacketReorderingHelp="If checked, server tries to reorder delayed movement packets"
	bEnableLoosePositionCheckText="Enable Loose Position Check"
	bEnableLoosePositionCheckHelp="If checked, uses looser position validation rules"
	bPlayersAlwaysRelevantText="Players Always Relevant"
	bPlayersAlwaysRelevantHelp="If checked, players stay network relevant regardless of distance"
	bEnableJitterBoundingText="Enable Jitter Bounding"
	bEnableJitterBoundingHelp="If checked, bounds movement jitter spikes"
	LooseCheckCorrectionFactorText="Loose Check Correction Factor"
	LooseCheckCorrectionFactorHelp="Correction strength used by loose position checks"
	LooseCheckCorrectionFactorOnMoverText="Loose Check Correction On Mover"
	LooseCheckCorrectionFactorOnMoverHelp="Loose check correction strength while standing on movers"
	bEnableSnapshotInterpolationText="Enable Snapshot Interpolation"
	bEnableSnapshotInterpolationHelp="If checked, clients smooth movement using snapshot interpolation"
	SnapshotInterpSendHzText="Snapshot Send Hz"
	SnapshotInterpSendHzHelp="Snapshot transmission frequency in Hz"
	SnapshotInterpRewindMsText="Snapshot Rewind (ms)"
	SnapshotInterpRewindMsHelp="Interpolation rewind delay in milliseconds"
	bEnableWarpFixText="Enable Warp Fix"
	bEnableWarpFixHelp="If checked, enables warp correction smoothing"

	DebugText="Debug"
	ShowTouchedPackageText="Show Touched Package"
	ShowTouchedPackageHelp="If checked, logs touched-package details for diagnostics"
	bEnableDamageDebugModeText="Enable Damage Debug Mode"
	bEnableDamageDebugModeHelp="If checked, enables server-side damage debug tracing"
	bEnableDamageDebugConsoleMessagesText="Damage Debug Console Messages"
	bEnableDamageDebugConsoleMessagesHelp="If checked, prints damage debug messages to client consoles"
	bEnableHitboxDebugModeText="Enable Hitbox Debug Mode"
	bEnableHitboxDebugModeHelp="If checked, enables hitbox debug diagnostics"

	PaddingX=20
	PaddingY=12
	LineSpacing=22
	SeparatorSpacing=30
}
