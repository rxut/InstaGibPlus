class IGPlus_SettingsScroll extends UWindowScrollingDialogClient;

enum ESettingsTab {
	ST_Client,
	ST_Server,
	ST_Weapon
};

var UWindowSmallButton Btn_Close;
var UWindowSmallButton Btn_Save;
var UWindowSmallButton Btn_ClientTab;
var UWindowSmallButton Btn_ServerTab;
var UWindowSmallButton Btn_WeaponTab;
var localized string SaveButtonText;
var localized string SaveButtonToolTip;
var localized string ClientTabText;
var localized string ClientTabToolTip;
var localized string ServerTabText;
var localized string ServerTabToolTip;
var localized string WeaponTabText;
var localized string WeaponTabToolTip;

var class<UWindowDialogClientWindow> ClientTabClass;
var class<UWindowDialogClientWindow> ServerTabClass;
var class<UWindowDialogClientWindow> WeaponTabClass;
var ESettingsTab ActiveTab;
var UWindowDialogClientWindow ClientTabArea;
var UWindowDialogClientWindow ServerTabArea;
var UWindowDialogClientWindow WeaponTabArea;

var float FixedPaddingX;
var float FixedPaddingY;
var float TabButtonGap;

function UpdateTabButtons() {
	if (Btn_ClientTab == none || Btn_ServerTab == none || Btn_WeaponTab == none)
		return;

	Btn_ClientTab.SetText(ClientTabText);
	Btn_ClientTab.ToolTipString = ClientTabToolTip;
	Btn_ServerTab.SetText(ServerTabText);
	Btn_ServerTab.ToolTipString = ServerTabToolTip;
	Btn_WeaponTab.SetText(WeaponTabText);
	Btn_WeaponTab.ToolTipString = WeaponTabToolTip;

	if (ActiveTab == ST_Client) {
		if (Btn_ClientTab.bWindowVisible)
			Btn_ClientTab.HideWindow();
		if (Btn_ServerTab.bWindowVisible == false)
			Btn_ServerTab.ShowWindow();
		if (Btn_WeaponTab.bWindowVisible == false)
			Btn_WeaponTab.ShowWindow();
	} else if (ActiveTab == ST_Server) {
		if (Btn_ServerTab.bWindowVisible)
			Btn_ServerTab.HideWindow();
		if (Btn_ClientTab.bWindowVisible == false)
			Btn_ClientTab.ShowWindow();
		if (Btn_WeaponTab.bWindowVisible == false)
			Btn_WeaponTab.ShowWindow();
	} else {
		if (Btn_WeaponTab.bWindowVisible)
			Btn_WeaponTab.HideWindow();
		if (Btn_ServerTab.bWindowVisible == false)
			Btn_ServerTab.ShowWindow();
		if (Btn_ClientTab.bWindowVisible == false)
			Btn_ClientTab.ShowWindow();
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

function EnsureWeaponTabArea() {
	if (WeaponTabArea != none)
		return;

	if (WeaponTabClass == none)
		return;

	WeaponTabArea = UWindowDialogClientWindow(CreateWindow(WeaponTabClass, 0, 0, WinWidth, WinHeight, OwnerWindow));
	if (WeaponTabArea != none)
		WeaponTabArea.HideWindow();
}

function HideAllTabAreas() {
	if (ClientTabArea != none && ClientTabArea.bWindowVisible)
		ClientTabArea.HideWindow();
	if (ServerTabArea != none && ServerTabArea.bWindowVisible)
		ServerTabArea.HideWindow();
	if (WeaponTabArea != none && WeaponTabArea.bWindowVisible)
		WeaponTabArea.HideWindow();
}

function SetActiveTab(ESettingsTab NewTab) {
	if (NewTab == ActiveTab && ClientArea != none)
		return;

	EnsureServerTabArea();
	EnsureWeaponTabArea();
	HideAllTabAreas();

	ActiveTab = NewTab;
	if (ActiveTab == ST_Server && ServerTabArea != none) {
		if (ServerTabArea.bWindowVisible == false)
			ServerTabArea.ShowWindow();
		ClientArea = ServerTabArea;
	} else if (ActiveTab == ST_Weapon && WeaponTabArea != none) {
		if (WeaponTabArea.bWindowVisible == false)
			WeaponTabArea.ShowWindow();
		ClientArea = WeaponTabArea;
	} else {
		if (ClientTabArea != none && ClientTabArea.bWindowVisible == false)
			ClientTabArea.ShowWindow();
		ClientArea = ClientTabArea;
		ActiveTab = ST_Client;
	}

	UpdateTabButtons();
	Load();
}

function Created() {
	super.Created();

	Btn_ClientTab = UWindowSmallButton(FixedArea.CreateControl(
		class'UWindowSmallButton',
		FixedPaddingX,
		FixedPaddingY,
		32,
		16
	));
	Btn_ClientTab.Register(self);

	Btn_ServerTab = UWindowSmallButton(FixedArea.CreateControl(
		class'UWindowSmallButton',
		FixedPaddingX,
		FixedPaddingY,
		32,
		16
	));
	Btn_ServerTab.Register(self);

	Btn_WeaponTab = UWindowSmallButton(FixedArea.CreateControl(
		class'UWindowSmallButton',
		FixedPaddingX,
		FixedPaddingY,
		32,
		16
	));
	Btn_WeaponTab.Register(self);

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
	EnsureWeaponTabArea();

	ActiveTab = ST_Weapon;
	SetActiveTab(ST_Client);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	if (E == DE_Click && C == Btn_ClientTab) {
		SetActiveTab(ST_Client);
	} else if (E == DE_Click && C == Btn_ServerTab) {
		SetActiveTab(ST_Server);
	} else if (E == DE_Click && C == Btn_WeaponTab) {
		SetActiveTab(ST_Weapon);
	} else if (E == DE_Click && C == Btn_Save) {
		Save();
		if (IGPlus_SettingsContent(ClientArea) != none)
			Load();
	}
}

function LayoutTabButton(UWindowSmallButton Btn, Canvas C, out float Left) {
	if (Btn == none || Btn.bWindowVisible == false)
		return;

	Btn.AutoWidth(C);
	Btn.WinLeft = Left;
	Btn.WinTop = FixedPaddingY;
	Left += Btn.WinWidth + TabButtonGap;
}

function BeforePaint(Canvas C, float X, float Y) {
	local float TabLeft;

	super.BeforePaint(C, X, Y);

	TabLeft = FixedPaddingX;
	LayoutTabButton(Btn_ServerTab, C, TabLeft);
	LayoutTabButton(Btn_WeaponTab, C, TabLeft);
	LayoutTabButton(Btn_ClientTab, C, TabLeft);

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
	else if (IGPlus_WeaponSettingsContent(ClientArea) != none)
		IGPlus_WeaponSettingsContent(ClientArea).Load();
}

function Save() {
	if (IGPlus_SettingsContent(ClientArea) != none)
		IGPlus_SettingsContent(ClientArea).Save();
	else if (IGPlus_ServerSettingsContent(ClientArea) != none)
		IGPlus_ServerSettingsContent(ClientArea).Save();
	else if (IGPlus_WeaponSettingsContent(ClientArea) != none)
		IGPlus_WeaponSettingsContent(ClientArea).Save();
}

defaultproperties
{
	ClientClass=class'IGPlus_SettingsContent'
	FixedAreaClass=class'UWindowDialogClientWindow'
	ClientTabClass=class'IGPlus_SettingsContent'
	ServerTabClass=class'IGPlus_ServerSettingsContent'
	WeaponTabClass=class'IGPlus_WeaponSettingsContent'

	SaveButtonText="Save"
	SaveButtonToolTip="Saves the current settings to InstaGibPlus.ini"
	ClientTabText="Client"
	ClientTabToolTip="Open client settings"
	ServerTabText="Server"
	ServerTabToolTip="Open server settings"
	WeaponTabText="Weapon"
	WeaponTabToolTip="Open weapon settings"

	FixedPaddingX=20
	FixedPaddingY=5
	TabButtonGap=4
}
