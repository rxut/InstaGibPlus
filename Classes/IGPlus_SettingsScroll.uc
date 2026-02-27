class IGPlus_SettingsScroll extends UWindowScrollingDialogClient;

enum ESettingsTab {
	ST_Client,
	ST_Server
};

var UWindowSmallButton Btn_Close;
var UWindowSmallButton Btn_Save;
var UWindowSmallButton Btn_TabToggle;
var localized string SaveButtonText;
var localized string SaveButtonToolTip;
var localized string ClientTabText;
var localized string ClientTabToolTip;
var localized string ServerTabText;
var localized string ServerTabToolTip;

var class<UWindowDialogClientWindow> ClientTabClass;
var class<UWindowDialogClientWindow> ServerTabClass;
var ESettingsTab ActiveTab;
var UWindowDialogClientWindow ClientTabArea;
var UWindowDialogClientWindow ServerTabArea;

var float FixedPaddingX;
var float FixedPaddingY;

function UpdateTabToggleButton() {
	if (Btn_TabToggle == none)
		return;

	if (ActiveTab == ST_Client) {
		Btn_TabToggle.SetText(ServerTabText);
		Btn_TabToggle.ToolTipString = ServerTabToolTip;
	} else {
		Btn_TabToggle.SetText(ClientTabText);
		Btn_TabToggle.ToolTipString = ClientTabToolTip;
	}
}

function EnsureServerTabArea() {
	if (ServerTabArea != none)
		return;

	if (ServerTabClass == none)
		return;

	ServerTabArea = UWindowDialogClientWindow(CreateWindow(ServerTabClass, 0, 0, WinWidth, WinHeight, OwnerWindow));
	if (ServerTabArea != none)
		ServerTabArea.HideWindow();
}

function SetActiveTab(ESettingsTab NewTab) {
	if (NewTab == ActiveTab && ClientArea != none)
		return;

	EnsureServerTabArea();

	ActiveTab = NewTab;
	if (ActiveTab == ST_Server && ServerTabArea != none) {
		if (ClientTabArea != none && ClientTabArea.bWindowVisible)
			ClientTabArea.HideWindow();
		if (ServerTabArea.bWindowVisible == false)
			ServerTabArea.ShowWindow();
		ClientArea = ServerTabArea;
	} else {
		if (ServerTabArea != none && ServerTabArea.bWindowVisible)
			ServerTabArea.HideWindow();
		if (ClientTabArea != none && ClientTabArea.bWindowVisible == false)
			ClientTabArea.ShowWindow();
		ClientArea = ClientTabArea;
		ActiveTab = ST_Client;
	}

	UpdateTabToggleButton();

	Load();
}

function Created() {
	super.Created();

	Btn_TabToggle = UWindowSmallButton(FixedArea.CreateControl(
		class'UWindowSmallButton',
		FixedPaddingX,
		FixedPaddingY,
		32,
		16
	));
	Btn_TabToggle.Register(self);

	Btn_Save = UWindowSmallButton(FixedArea.CreateControl(
		class'UWindowSmallButton',
		FixedArea.WinWidth-FixedPaddingX-72,
		FixedPaddingY,
		32,
		16
	));
	Btn_Save.SetText(SaveButtonText);
	Btn_Save.ToolTipString = SaveButtonToolTip;
	Btn_Save.Register(self);

	Btn_Close = UWindowSmallButton(FixedArea.CreateControl(
		class'UWindowSmallCloseButton',
		FixedArea.WinWidth-FixedPaddingX-32,
		FixedPaddingY,
		32,
		16
	));

	FixedArea.WinHeight = 2*FixedPaddingY + 16;

	ClientTabArea = ClientArea;
	EnsureServerTabArea();

	// Force first SetActiveTab call to run initialization path.
	ActiveTab = ST_Server;
	SetActiveTab(ST_Client);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (E == DE_Click && C == Btn_TabToggle) {
		if (ActiveTab == ST_Client)
			SetActiveTab(ST_Server);
		else
			SetActiveTab(ST_Client);
	} else if (E == DE_Click && C == Btn_Save) {
		Save();
		if (IGPlus_SettingsContent(ClientArea) != none)
			Load();
	}
}

function BeforePaint(Canvas C, float X, float Y) {
	super.BeforePaint(C, X, Y);

	Btn_TabToggle.AutoWidth(C);
	Btn_TabToggle.WinLeft = FixedPaddingX;

	Btn_Close.AutoWidth(C);
	Btn_Close.WinLeft = FixedArea.WinWidth-FixedPaddingX-Btn_Close.WinWidth;

	Btn_Save.AutoWidth(C);
	Btn_Save.WinLeft = FixedArea.WinWidth-FixedPaddingX-Btn_Close.WinWidth-5-Btn_Save.WinWidth;
}

function Load() {
	if (IGPlus_SettingsContent(ClientArea) != none)
		IGPlus_SettingsContent(ClientArea).Load();
	else if (IGPlus_ServerSettingsContent(ClientArea) != none)
		IGPlus_ServerSettingsContent(ClientArea).Load();
}

function Save() {
	if (IGPlus_SettingsContent(ClientArea) != none)
		IGPlus_SettingsContent(ClientArea).Save();
	else if (IGPlus_ServerSettingsContent(ClientArea) != none)
		IGPlus_ServerSettingsContent(ClientArea).Save();
}

defaultproperties
{
	ClientClass=class'IGPlus_SettingsContent'
	FixedAreaClass=class'UWindowDialogClientWindow'
	ClientTabClass=class'IGPlus_SettingsContent'
	ServerTabClass=class'IGPlus_ServerSettingsContent'

	SaveButtonText="Save"
	SaveButtonToolTip="Saves the current settings to InstaGibPlus.ini"
	ClientTabText="Client"
	ClientTabToolTip="Open client settings"
	ServerTabText="Server"
	ServerTabToolTip="Open server settings"

	FixedPaddingX=20
	FixedPaddingY=5
}
