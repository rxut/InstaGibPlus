// The Crosshair Factory window: the layers of a crosshair on the left with a
// large preview under them, the selected layer's values in the middle, the
// presets on the right.
//
// Every preset has its own list of layers here (IGPlus_CrosshairPresetsListItem.Layers),
// loaded when the window opens. The player's changes go into these lists and
// nowhere else, so they stay when another preset is clicked. Save writes every
// preset that changed. Opening the window again loads everything anew, so
// closing it drops what was not saved.
//
// Only the values that do something for the selected layer are shown.
class IGPlus_CrosshairSettingsContent extends UMenuPageWindow
	dependson(ClientSettings);

var IGPlus_CrosshairSettingsDialog ParentDialog;
var ClientSettings Settings;
var bool bUpdatingControls;

var IGPlus_Button Btn_AddLayer;
var IGPlus_Button Btn_RemLayer;
var localized string LayersText;
var localized string LayersHelp;
var localized string AddLayerHelp;
var localized string RemLayerHelp;

var IGPlus_CrosshairLayersListBox LB_Layers;
var UWindowList LastSelected;
var bool bRefill; // the boxes get the selected layer's values again

var IGPlus_Label Lbl_NoLayer;
var localized string NoLayerText;

// Presets: the list, + for a new one, - to delete the picked one, and its name.
var IGPlus_Button Btn_AddPreset;
var IGPlus_Button Btn_RemPreset;
var localized string PresetsText;
var localized string PresetsHelp;
var localized string AddPresetHelp;
var localized string RemPresetHelp;
var IGPlus_CrosshairPresetsListBox LB_Presets;
var IGPlus_CrosshairPresetsListItem CurPreset; // the one whose layers are shown
var IGPlus_EditControl Edit_PresetName;
var localized string PresetNameText;
var localized string PresetNameHelp;

var IGPlus_Label Lbl_Scale;
var localized string ScaleText;
var IGPlus_BtnUp Btn_ScaleUp;
var IGPlus_BtnDown Btn_ScaleDown;
var IGPlus_BtnLeft Btn_ScaleLeft;
var IGPlus_BtnRight Btn_ScaleRight;

var IGPlus_Label Lbl_Offset;
var localized string OffsetText;
var IGPlus_BtnUp Btn_OffsetUp;
var IGPlus_BtnDown Btn_OffsetDown;
var IGPlus_BtnLeft Btn_OffsetLeft;
var IGPlus_BtnRight Btn_OffsetRight;

var IGPlus_ComboBox Cmb_Shape;
var localized string ShapeText;
var localized string ShapeHelp;

var IGPlus_EditControl Edit_Texture;
var localized string TextureText;
var localized string TextureHelp;

var IGPlus_Checkbox Chk_Smooth;
var localized string SmoothText;
var localized string SmoothHelp;

// A shape and a filled rectangle have a width and a height in pixels. An
// image has a scale, as multiples of its own size.
var IGPlus_EditControl Edit_ScaleX;
var localized string ScaleXText;
var localized string ScaleXHelp;
var localized string WidthText;
var localized string WidthHelp;
var IGPlus_EditControl Edit_ScaleY;
var localized string ScaleYText;
var localized string ScaleYHelp;
var localized string HeightText;
var localized string HeightHelp;

var IGPlus_EditControl Edit_OffsetX;
var localized string OffsetXText;
var localized string OffsetXHelp;
var IGPlus_EditControl Edit_OffsetY;
var localized string OffsetYText;
var localized string OffsetYHelp;

var IGPlus_EditControl Edit_Thickness;
var localized string ThicknessText;
var localized string ThicknessHelp;

var IGPlus_ComboBox Cmb_Style;
var localized string StyleText;
var localized string StyleHelp;
var localized string StyleNormal;
var localized string StyleTranslucent;
var localized string StyleModulated;

var IGPlus_EditControl Edit_ColorRed;
var localized string ColorRedText;
var IGPlus_EditControl Edit_ColorGreen;
var localized string ColorGreenText;
var IGPlus_EditControl Edit_ColorBlue;
var localized string ColorBlueText;
var localized string ColorHelp;
var IGPlus_EditControl Edit_ColorAlpha;
var localized string ColorAlphaText;
var localized string ColorAlphaHelp;

var localized string ZoomText;

var UWindowSmallCloseButton Btn_Close;
var UWindowSmallButton Btn_Save;
var localized string SaveHelp;
var localized string CloseHelp;

function int MaxLayers() {
	if (Settings == none)
		return 0;
	return Settings.CrosshairLayerCount();
}

function IGPlus_CrosshairLayersListItem Sel() {
	return IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem);
}

function SelectLayer(IGPlus_CrosshairLayersListItem L) {
	if (L != none)
		LB_Layers.SetSelectedItem(L);
	else
		LB_Layers.SelectedItem = none;
}

function IGPlus_CrosshairLayersListItem NewLayer() {
	local IGPlus_CrosshairLayersListItem L;

	L = new class'IGPlus_CrosshairLayersListItem';
	L.ScaleX = 1;
	L.ScaleY = 1;
	L.Color.R = 255;
	L.Color.G = 255;
	L.Color.B = 255;
	L.Color.A = 255;
	L.Style = 1;
	return L;
}

// A layer of the window as it is saved. None: a layer that is not used, as
// Save has always written it.
function ClientSettings.CrosshairLayerDescr Descr(IGPlus_CrosshairLayersListItem L) {
	local ClientSettings.CrosshairLayerDescr D;

	if (L == none) {
		D.ScaleX = 1;
		D.ScaleY = 1;
		D.Color.R = 255;
		D.Color.G = 255;
		D.Color.B = 255;
		D.Color.A = 255;
		return D;
	}
	D.bUse = true;
	D.Texture = L.Texture;
	D.OffsetX = L.OffsetX;
	D.OffsetY = L.OffsetY;
	D.ScaleX = L.ScaleX;
	D.ScaleY = L.ScaleY;
	D.Color = L.Color;
	D.Style = L.Style;
	D.bSmooth = L.bSmooth;
	D.Shape = L.Shape;
	D.Thickness = L.Thickness;
	return D;
}

// A preset's row, with its layers as they are saved.
function IGPlus_CrosshairPresetsListItem NewPresetItem(int Slot) {
	local IGPlus_CrosshairPresetsListItem P;
	local IGPlus_CrosshairLayersListItem L;
	local ClientSettings.CrosshairLayerDescr D;
	local int i;

	P = new class'IGPlus_CrosshairPresetsListItem';
	P.Slot = Slot;
	P.PresetName = Settings.GetCrosshairPresetName(Slot);
	P.Layers = new class'IGPlus_CrosshairLayersListItem';
	P.Layers.SetupSentinel();
	for (i = 0; i < MaxLayers(); ++i) {
		D = Settings.CrosshairPresets[Slot].GetLayer(i);
		if (D.bUse == false)
			continue;

		L = NewLayer();
		L.Texture = D.Texture;
		L.OffsetX = D.OffsetX;
		L.OffsetY = D.OffsetY;
		L.ScaleX = D.ScaleX;
		L.ScaleY = D.ScaleY;
		L.Color = D.Color;
		L.Style = D.Style;
		L.bSmooth = D.bSmooth;
		L.Shape = D.Shape;
		L.Thickness = D.Thickness;
		P.Layers.AppendItem(L);
	}
	return P;
}

// Is a preset in the window not what is saved?
function bool IsDirty(IGPlus_CrosshairPresetsListItem P) {
	local IGPlus_CrosshairLayersListItem L;
	local ClientSettings.CrosshairLayerDescr D;
	local int i;

	if (P.PresetName != Settings.GetCrosshairPresetName(P.Slot))
		return true;

	L = IGPlus_CrosshairLayersListItem(P.Layers.Next);
	for (i = 0; i < MaxLayers(); ++i) {
		D = Settings.CrosshairPresets[P.Slot].GetLayer(i);
		if (D.bUse == false)
			continue;
		if (L == none || D != Descr(L))
			return true;
		L = IGPlus_CrosshairLayersListItem(L.Next);
	}
	return L != none;
}

// Writes every preset that changed, the picked one and the others.
function Save() {
	local IGPlus_CrosshairPresetsListItem P;
	local IGPlus_CrosshairLayersListItem L;
	local int i;

	for (P = IGPlus_CrosshairPresetsListItem(LB_Presets.Items.Next); P != none; P = IGPlus_CrosshairPresetsListItem(P.Next)) {
		if (IsDirty(P) == false)
			continue;

		i = 0;
		for (L = IGPlus_CrosshairLayersListItem(P.Layers.Next); L != none && i < MaxLayers(); L = IGPlus_CrosshairLayersListItem(L.Next))
			Settings.SetCrosshairPresetLayer(P.Slot, i++, Descr(L));
		while (i < MaxLayers())
			Settings.SetCrosshairPresetLayer(P.Slot, i++, Descr(none));

		Settings.SaveCrosshairPreset(P.Slot, P.PresetName);
		P.PresetName = Settings.GetCrosshairPresetName(P.Slot); // an empty name was not taken
		P.bDirty = false;
	}
	Settings.SaveConfig();

	if (CurPreset != none && Edit_PresetName.GetValue() != CurPreset.PresetName) {
		bUpdatingControls = true;
		Edit_PresetName.SetValue(CurPreset.PresetName);
		bUpdatingControls = false;
	}
}

function IGPlus_CrosshairPresetsListItem FindPreset(int Slot) {
	local IGPlus_CrosshairPresetsListItem P;

	for (P = IGPlus_CrosshairPresetsListItem(LB_Presets.Items.Next); P != none; P = IGPlus_CrosshairPresetsListItem(P.Next))
		if (P.Slot == Slot)
			return P;
	return none;
}

// Shows a preset's layers and its name. What the window showed before stays
// in the list of the preset it belongs to.
function ShowPreset(IGPlus_CrosshairPresetsListItem P) {
	if (P == none)
		return;

	bUpdatingControls = true;
	CurPreset = P;
	LB_Presets.SetSelectedItem(P);
	LB_Layers.Items = P.Layers;
	LB_Layers.VertSB.Pos = 0;
	SelectLayer(IGPlus_CrosshairLayersListItem(P.Layers.Next));
	bRefill = true;
	Edit_PresetName.SetValue(P.PresetName);
	bUpdatingControls = false;
}

// The window was opened: every preset as it is saved.
function Load() {
	local bbPlayer P;
	local bbCHSpectator Spec;
	local int i;

	P = bbPlayer(GetPlayerOwner());
	if (P == none) {
		Spec = bbCHSpectator(GetPlayerOwner());
		if (Spec == none)
			return;
		Settings = Spec.Settings;
	} else {
		Settings = P.Settings;
	}
	if (Settings == none)
		return;

	LB_Presets.Items.Clear();
	LB_Presets.SelectedItem = none;
	CurPreset = none;
	for (i = 0; i < arraycount(Settings.CrosshairPresets); ++i)
		if (Settings.GetCrosshairPresetName(i) != "")
			LB_Presets.Items.AppendItem(NewPresetItem(i));

	ShowPreset(FindPreset(Settings.CrosshairPreset));

	// The keyboard goes to the list of layers (arrow keys walk through it).
	// Left alone it goes to the topmost box, and the first key typed would
	// replace what is in it.
	LB_Layers.ActivateWindow(0, false);
}

// A new preset in the first free slot. It starts as a copy of the one shown,
// with the changes that are not saved yet.
function AddPreset() {
	local IGPlus_CrosshairPresetsListItem P, After;
	local IGPlus_CrosshairLayersListItem L, Copy;

	if (CurPreset == none || Settings.NewCrosshairPreset() == false)
		return;

	P = NewPresetItem(Settings.CrosshairPreset);
	P.Layers.Clear();
	for (L = IGPlus_CrosshairLayersListItem(CurPreset.Layers.Next); L != none; L = IGPlus_CrosshairLayersListItem(L.Next)) {
		Copy = NewLayer();
		Copy.Texture = L.Texture;
		Copy.OffsetX = L.OffsetX;
		Copy.OffsetY = L.OffsetY;
		Copy.ScaleX = L.ScaleX;
		Copy.ScaleY = L.ScaleY;
		Copy.Color = L.Color;
		Copy.Style = L.Style;
		Copy.bSmooth = L.bSmooth;
		Copy.Shape = L.Shape;
		Copy.Thickness = L.Thickness;
		P.Layers.AppendItem(Copy);
	}
	P.bDirty = IsDirty(P);

	// The rows are in the order of the slots.
	for (After = IGPlus_CrosshairPresetsListItem(LB_Presets.Items.Next); After != none; After = IGPlus_CrosshairPresetsListItem(After.Next))
		if (After.Slot > P.Slot)
			break;
	if (After != none)
		After.InsertItemBefore(P);
	else
		LB_Presets.Items.AppendItem(P);

	ShowPreset(P);
}

function RemPreset() {
	if (CurPreset == none || Settings.DeleteCrosshairPreset() == false)
		return;

	CurPreset.Remove();
	LB_Presets.SelectedItem = none;
	CurPreset = none;
	ShowPreset(FindPreset(Settings.CrosshairPreset));
}

function AddLayer() {
	local IGPlus_CrosshairLayersListItem L;

	L = NewLayer();
	LB_Layers.Items.AppendItem(L);
	SelectLayer(L);
	LB_Layers.MakeSelectedVisible();
}

// The layer after the removed one is selected next, or the one before it.
function RemLayer() {
	local IGPlus_CrosshairLayersListItem L, Next;

	L = Sel();
	if (L == none)
		return;
	Next = IGPlus_CrosshairLayersListItem(L.Next);
	if (Next == none && L.Prev != LB_Layers.Items)
		Next = IGPlus_CrosshairLayersListItem(L.Prev);
	L.Remove();
	LB_Layers.SelectedItem = none;
	SelectLayer(Next);
}

function IGPlus_EditControl NewEdit(string Label, string Help, float BoxWidth, int MaxLength) {
	local IGPlus_EditControl E;

	E = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 80, 150, 16));
	E.SetText(Label);
	E.SetHelpText(Help);
	E.SetFont(F_Normal);
	E.Align = TA_Left;
	E.SetNumericOnly(true);
	E.SetMaxLength(MaxLength);
	E.EditBoxWidthFraction = BoxWidth / 150.0;
	E.EditBoxMinWidth = BoxWidth;
	E.EditBoxMaxWidth = BoxWidth;
	E.EditBoxWidth = BoxWidth;
	return E;
}

function IGPlus_ComboBox NewCombo(string Label, string Help) {
	local IGPlus_ComboBox Cmb;

	Cmb = IGPlus_ComboBox(CreateControl(class'IGPlus_ComboBox', 276, 80, 150, 16));
	Cmb.SetText(Label);
	Cmb.SetHelpText(Help);
	Cmb.SetFont(F_Normal);
	Cmb.Align = TA_Left;
	Cmb.SetEditable(false);
	Cmb.EditBoxWidthFraction = (2.0/3.0);
	Cmb.EditBoxMinWidth = 100;
	Cmb.EditBoxMaxWidth = 100;
	Cmb.EditBoxWidth = 100;
	return Cmb;
}

function IGPlus_Label NewLabel(float X, float Y, float W, string Label, string Help) {
	local IGPlus_Label Lbl;

	Lbl = IGPlus_Label(CreateControl(class'IGPlus_Label', X, Y, W, 16));
	Lbl.SetText(Label);
	Lbl.SetHelpText(Help);
	Lbl.SetFont(F_Normal);
	return Lbl;
}

function IGPlus_Button NewButton(float X, float Y, string Label, string Help) {
	local IGPlus_Button B;

	B = IGPlus_Button(CreateControl(class'IGPlus_Button', X, Y, 16, 16));
	B.SetText(Label);
	B.SetHelpText(Help);
	return B;
}

function Created() {
	local int i;

	super.Created();

	ParentDialog = IGPlus_CrosshairSettingsDialog(ParentWindow);

	// Left: the layers.
	Btn_AddLayer = NewButton(10, 10, "+", AddLayerHelp);
	Btn_RemLayer = NewButton(30, 10, "-", RemLayerHelp);
	NewLabel(54, 10, 212, LayersText, LayersHelp);
	LB_Layers = IGPlus_CrosshairLayersListBox(CreateControl(class'IGPlus_CrosshairLayersListBox', 10, 30, 256, 150));
	LB_Layers.SetHelpText(LayersHelp);

	// Middle: the selected layer.
	Lbl_NoLayer = NewLabel(276, 10, 150, NoLayerText, "");

	Lbl_Scale = NewLabel(276, 10, 64, ScaleText, "");
	Lbl_Scale.Align = TA_Center;
	Btn_ScaleUp = IGPlus_BtnUp(CreateControl(class'IGPlus_BtnUp', 302, 30, 12, 10));
	Btn_ScaleDown = IGPlus_BtnDown(CreateControl(class'IGPlus_BtnDown', 302, 60, 12, 10));
	Btn_ScaleLeft = IGPlus_BtnLeft(CreateControl(class'IGPlus_BtnLeft', 288, 44, 10, 12));
	Btn_ScaleRight = IGPlus_BtnRight(CreateControl(class'IGPlus_BtnRight', 318, 44, 10, 12));

	Lbl_Offset = NewLabel(344, 10, 64, OffsetText, "");
	Lbl_Offset.Align = TA_Center;
	Btn_OffsetUp = IGPlus_BtnUp(CreateControl(class'IGPlus_BtnUp', 370, 30, 12, 10));
	Btn_OffsetDown = IGPlus_BtnDown(CreateControl(class'IGPlus_BtnDown', 370, 60, 12, 10));
	Btn_OffsetLeft = IGPlus_BtnLeft(CreateControl(class'IGPlus_BtnLeft', 356, 44, 10, 12));
	Btn_OffsetRight = IGPlus_BtnRight(CreateControl(class'IGPlus_BtnRight', 386, 44, 10, 12));

	// (PlaceRows puts these under each other, the ones the layer uses.)
	Cmb_Shape = NewCombo(ShapeText, ShapeHelp);
	for (i = 0; i < arraycount(class'CrosshairLayer'.default.ShapeNames); i++)
		Cmb_Shape.AddItem(class'CrosshairLayer'.default.ShapeNames[i], string(i));

	Edit_Texture = NewEdit(TextureText, TextureHelp, 100, 255);
	Edit_Texture.SetNumericOnly(false);

	Chk_Smooth = IGPlus_Checkbox(CreateControl(class'IGPlus_Checkbox', 276, 80, 150, 16));
	Chk_Smooth.SetText(SmoothText);
	Chk_Smooth.SetHelpText(SmoothHelp);
	Chk_Smooth.SetFont(F_Normal);
	Chk_Smooth.Align = TA_Left;

	Edit_ScaleX = NewEdit(WidthText, WidthHelp, 50, 9);
	Edit_ScaleX.SetNumericFloat(true);
	Edit_ScaleY = NewEdit(HeightText, HeightHelp, 50, 9);
	Edit_ScaleY.SetNumericFloat(true);

	Edit_OffsetX = NewEdit(OffsetXText, OffsetXHelp, 50, 6);
	Edit_OffsetX.SetNumericNegative(true);
	Edit_OffsetY = NewEdit(OffsetYText, OffsetYHelp, 50, 6);
	Edit_OffsetY.SetNumericNegative(true);

	Edit_Thickness = NewEdit(ThicknessText, ThicknessHelp, 50, 2);

	// The engine's Canvas draws Masked as Normal, so the list has no Masked. A
	// layer saved with it keeps it and shows as the first entry.
	Cmb_Style = NewCombo(StyleText, StyleHelp);
	Cmb_Style.AddItem(StyleNormal, "1");
	Cmb_Style.AddItem(StyleTranslucent, "3");
	Cmb_Style.AddItem(StyleModulated, "4");

	Edit_ColorRed = NewEdit(ColorRedText, ColorHelp, 50, 3);
	Edit_ColorGreen = NewEdit(ColorGreenText, ColorHelp, 50, 3);
	Edit_ColorBlue = NewEdit(ColorBlueText, ColorHelp, 50, 3);
	Edit_ColorAlpha = NewEdit(ColorAlphaText, ColorAlphaHelp, 50, 3);

	// Right: the presets.
	Btn_AddPreset = NewButton(436, 10, "+", AddPresetHelp);
	Btn_RemPreset = NewButton(456, 10, "-", RemPresetHelp);
	NewLabel(480, 10, 106, PresetsText, PresetsHelp);

	LB_Presets = IGPlus_CrosshairPresetsListBox(CreateControl(class'IGPlus_CrosshairPresetsListBox', 436, 30, 150, 374));
	LB_Presets.BackgroundBrightness = ParentDialog.BackgroundBrightness;
	LB_Presets.SetHelpText(PresetsHelp);

	Edit_PresetName = NewEdit(PresetNameText, PresetNameHelp, 112, 32);
	Edit_PresetName.WinLeft = 436;
	Edit_PresetName.WinTop = 408;
	Edit_PresetName.SetNumericOnly(false);

	Btn_Close = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 554, 430, 32, 16));
	Btn_Close.SetHelpText(CloseHelp);
	Btn_Save = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 518, 430, 32, 16));
	Btn_Save.SetText(class'IGPlus_SettingsScroll'.default.SaveButtonText);
	Btn_Save.SetHelpText(SaveHelp);
}

function ShowControl(UWindowWindow W, bool bShow) {
	if (bShow && W.bWindowVisible == false)
		W.ShowWindow();
	else if (bShow == false && W.bWindowVisible)
		W.HideWindow();
}

function PlaceRow(UWindowDialogControl C, bool bShow, out float Y) {
	ShowControl(C, bShow);
	if (bShow) {
		C.WinTop = Y;
		Y += 20;
	}
}

function SetLabel(UWindowDialogControl C, string Label, string Help) {
	if (C.Text != Label) {
		C.SetText(Label);
		C.SetHelpText(Help);
	}
}

// Shows the values the selected layer uses, under each other.
//   Texture: only without a shape. Smooth: only for an image, a filled
//   rectangle and a shape have no pixels to smooth.
//   Thickness: only for a shape.
//   Colour: not for Modulated, which is drawn without it.
//   Alpha: only for Translucent, the one style it does something for.
function PlaceRows(IGPlus_CrosshairLayersListItem L) {
	local bool bLayer, bImage;
	local float Y;

	bLayer = L != none;
	bImage = bLayer && class'IGPlus_CrosshairLayersListBox'.static.HasImage(L);

	ShowControl(Lbl_NoLayer, bLayer == false);
	ShowControl(Lbl_Scale, bLayer);
	ShowControl(Btn_ScaleUp, bLayer);
	ShowControl(Btn_ScaleDown, bLayer);
	ShowControl(Btn_ScaleLeft, bLayer);
	ShowControl(Btn_ScaleRight, bLayer);
	ShowControl(Lbl_Offset, bLayer);
	ShowControl(Btn_OffsetUp, bLayer);
	ShowControl(Btn_OffsetDown, bLayer);
	ShowControl(Btn_OffsetLeft, bLayer);
	ShowControl(Btn_OffsetRight, bLayer);

	if (bImage) {
		SetLabel(Edit_ScaleX, ScaleXText, ScaleXHelp);
		SetLabel(Edit_ScaleY, ScaleYText, ScaleYHelp);
	} else {
		SetLabel(Edit_ScaleX, WidthText, WidthHelp);
		SetLabel(Edit_ScaleY, HeightText, HeightHelp);
	}

	Y = 80;
	PlaceRow(Cmb_Shape, bLayer, Y);
	PlaceRow(Edit_Texture, bLayer && L.Shape == 0, Y);
	PlaceRow(Chk_Smooth, bImage, Y);
	PlaceRow(Edit_ScaleX, bLayer, Y);
	PlaceRow(Edit_ScaleY, bLayer, Y);
	PlaceRow(Edit_OffsetX, bLayer, Y);
	PlaceRow(Edit_OffsetY, bLayer, Y);
	PlaceRow(Edit_Thickness, bLayer && L.Shape != 0, Y);
	PlaceRow(Cmb_Style, bLayer, Y);
	PlaceRow(Edit_ColorRed, bLayer && L.Style != 4, Y);
	PlaceRow(Edit_ColorGreen, bLayer && L.Style != 4, Y);
	PlaceRow(Edit_ColorBlue, bLayer && L.Style != 4, Y);
	PlaceRow(Edit_ColorAlpha, bLayer && L.Style == 3, Y);
}

function FillControlsFor(IGPlus_CrosshairLayersListItem L) {
	if (L == none)
		return;

	bUpdatingControls = true;

	Cmb_Shape.SetSelectedIndex(Min(L.Shape, 5));
	Edit_Texture.SetValue(L.Texture);
	Chk_Smooth.bChecked = L.bSmooth;

	Edit_ScaleX.SetValue(class'IGPlus_CrosshairLayersListBox'.static.Num(L.ScaleX));
	Edit_ScaleY.SetValue(class'IGPlus_CrosshairLayersListBox'.static.Num(L.ScaleY));
	Edit_OffsetX.SetValue(string(L.OffsetX));
	Edit_OffsetY.SetValue(string(L.OffsetY));
	Edit_Thickness.SetValue(string(L.Thickness));

	if (L.Style == 3)
		Cmb_Style.SetSelectedIndex(1);
	else if (L.Style == 4)
		Cmb_Style.SetSelectedIndex(2);
	else
		Cmb_Style.SetSelectedIndex(0);

	Edit_ColorRed.SetValue(string(L.Color.R));
	Edit_ColorGreen.SetValue(string(L.Color.G));
	Edit_ColorBlue.SetValue(string(L.Color.B));
	if (L.Color.A == 0) // drawn as 255, see CrosshairLayer.SetupCanvas
		Edit_ColorAlpha.SetValue("255");
	else
		Edit_ColorAlpha.SetValue(string(L.Color.A));

	bUpdatingControls = false;
}

// A colour box holds 0 to 255. A larger number typed in becomes 255, in the
// box too. (Nothing else is written back: the box is being typed in.)
function byte ColorValue(IGPlus_EditControl E) {
	local bool bWas;

	if (int(E.GetValue()) > 255) {
		bWas = bUpdatingControls;
		bUpdatingControls = true;
		E.SetValue("255");
		bUpdatingControls = bWas;
	}
	return Clamp(int(E.GetValue()), 0, 255);
}

function Notify(UWindowDialogControl C, byte E) {
	local IGPlus_CrosshairLayersListItem L;
	local IGPlus_CrosshairPresetsListItem P;

	// The help of the control under the mouse, in the window's bottom line.
	if (E == DE_MouseEnter)
		ToolTip(C.HelpText);
	else if (E == DE_MouseLeave)
		ToolTip("");

	if (bUpdatingControls || Settings == none)
		return;

	L = Sel();
	if (E == DE_Click) {
		if (C == Btn_AddLayer) {
			if (Btn_AddLayer.bDisabled == false)
				AddLayer();
		} else if (C == Btn_RemLayer) {
			if (Btn_RemLayer.bDisabled == false)
				RemLayer();
		} else if (C == Btn_AddPreset) {
			if (Btn_AddPreset.bDisabled == false)
				AddPreset();
		} else if (C == Btn_RemPreset) {
			if (Btn_RemPreset.bDisabled == false)
				RemPreset();
		} else if (C == LB_Presets) {
			// Another preset: drawn in the game from this click on.
			P = IGPlus_CrosshairPresetsListItem(LB_Presets.SelectedItem);
			if (P != none && P != CurPreset) {
				Settings.PickCrosshairPreset(P.Slot);
				ShowPreset(P);
			}
		} else if (C == Btn_Save) {
			Save();
		} else if (L != none) {
			if (C == Btn_ScaleUp)
				L.ScaleY += 1;
			else if (C == Btn_ScaleDown)
				L.ScaleY -= 1;
			else if (C == Btn_ScaleLeft)
				L.ScaleX -= 1;
			else if (C == Btn_ScaleRight)
				L.ScaleX += 1;
			else if (C == Btn_OffsetUp)
				L.OffsetY -= 1;
			else if (C == Btn_OffsetDown)
				L.OffsetY += 1;
			else if (C == Btn_OffsetLeft)
				L.OffsetX -= 1;
			else if (C == Btn_OffsetRight)
				L.OffsetX += 1;
			else
				return;
			bRefill = true;
		}
		// After a button the keyboard would go to whichever box is topmost,
		// marked as if it were being typed in. It goes to the list of layers.
		if (UWindowButton(C) != none && C != Btn_Close)
			LB_Layers.ActivateWindow(0, false);
	} else if (E == DE_Change) {
		if (C == Edit_PresetName) {
			if (CurPreset != none)
				CurPreset.PresetName = Edit_PresetName.GetValue();
		} else if (L == none) {
			return;
		} else if (C == Cmb_Shape) {
			L.Shape = Max(0, Cmb_Shape.GetSelectedIndex());
		} else if (C == Edit_Texture) {
			L.Texture = Edit_Texture.GetValue();
		} else if (C == Chk_Smooth) {
			L.bSmooth = Chk_Smooth.bChecked;
		} else if (C == Edit_ScaleX) {
			L.ScaleX = float(Edit_ScaleX.GetValue());
		} else if (C == Edit_ScaleY) {
			L.ScaleY = float(Edit_ScaleY.GetValue());
		} else if (C == Edit_OffsetX) {
			L.OffsetX = int(Edit_OffsetX.GetValue());
		} else if (C == Edit_OffsetY) {
			L.OffsetY = int(Edit_OffsetY.GetValue());
		} else if (C == Edit_Thickness) {
			L.Thickness = Max(0, int(Edit_Thickness.GetValue()));
		} else if (C == Cmb_Style) {
			L.Style = int(Cmb_Style.GetValue2()); // the entry's style: 1, 3 or 4
			bRefill = true; // Alpha comes into view with its value
		} else if (C == Edit_ColorRed) {
			L.Color.R = ColorValue(Edit_ColorRed);
		} else if (C == Edit_ColorGreen) {
			L.Color.G = ColorValue(Edit_ColorGreen);
		} else if (C == Edit_ColorBlue) {
			L.Color.B = ColorValue(Edit_ColorBlue);
		} else if (C == Edit_ColorAlpha) {
			L.Color.A = Max(1, ColorValue(Edit_ColorAlpha)); // 0 would count as 255
		}
	}
}

function BeforePaint(Canvas C, float X, float Y) {
	local IGPlus_CrosshairLayersListItem L;

	super.BeforePaint(C, X, Y);

	if (Settings == none)
		return;

	// The console command CrosshairPreset can pick another preset while the window is open.
	if (CurPreset != none && CurPreset.Slot != Settings.CrosshairPreset)
		ShowPreset(FindPreset(Settings.CrosshairPreset));

	// A layer is always selected when there is one, so the boxes are never dead.
	L = Sel();
	if (L == none && LB_Layers.Items.Next != none) {
		SelectLayer(IGPlus_CrosshairLayersListItem(LB_Layers.Items.Next));
		L = Sel();
	}
	if (L != LastSelected || bRefill) {
		LastSelected = L;
		bRefill = false;
		FillControlsFor(L);
	}
	PlaceRows(L);

	Btn_AddLayer.bDisabled = LB_Layers.Items.Count() >= MaxLayers();
	Btn_RemLayer.bDisabled = L == none;
	Btn_AddPreset.bDisabled = LB_Presets.Items.Count() >= arraycount(Settings.CrosshairPresets);
	Btn_RemPreset.bDisabled = LB_Presets.Items.Count() <= 1;

	// Only the preset shown can change, the others keep their mark.
	if (CurPreset != none)
		CurPreset.bDirty = IsDirty(CurPreset);
}

// The large preview: the crosshair four times its size, or as much smaller as
// it takes to fit. Nothing is drawn outside the square.
function Paint(Canvas C, float X, float Y) {
	local Region All, Pic;
	local float Zoom, Reach;

	super.Paint(C, X, Y);

	class'CanvasUtils'.static.SaveCanvas(C);

	Pic.X = 10;
	Pic.Y = 190;
	Pic.W = 256;
	Pic.H = 256;
	All = ClippingRegion;
	ClippingRegion = Pic;

	C.Style = 1;
	C.DrawColor.R = ParentDialog.BackgroundBrightness;
	C.DrawColor.G = ParentDialog.BackgroundBrightness;
	C.DrawColor.B = ParentDialog.BackgroundBrightness;
	C.DrawColor.A = 255;
	DrawStretchedTexture(C, Pic.X, Pic.Y, Pic.W, Pic.H, Texture'WhiteTexture');

	// The middle of the screen.
	C.DrawColor.R = C.DrawColor.R ^ 0xFF;
	C.DrawColor.G = C.DrawColor.G ^ 0xFF;
	C.DrawColor.B = C.DrawColor.B ^ 0xFF;
	DrawStretchedTexture(C, Pic.X + 127, Pic.Y, 2, Pic.H, Texture'WhiteTexture');
	DrawStretchedTexture(C, Pic.X, Pic.Y + 127, Pic.W, 2, Texture'WhiteTexture');

	Zoom = 4;
	Reach = class'IGPlus_CrosshairLayersListBox'.static.Reach(LB_Layers.Items);
	while (Zoom > 1 && Reach * Zoom > 124)
		Zoom -= 1;
	if (Reach * Zoom > 124)
		Zoom = 124 / Reach;
	class'IGPlus_CrosshairLayersListBox'.static.DrawLayers(C, Self, LB_Layers.Items, Pic.X + 128, Pic.Y + 128, Zoom, LB_Layers.SelectedItem);

	C.Style = 1;
	C.DrawColor.R = ParentDialog.BackgroundBrightness ^ 0xFF;
	C.DrawColor.G = ParentDialog.BackgroundBrightness ^ 0xFF;
	C.DrawColor.B = ParentDialog.BackgroundBrightness ^ 0xFF;
	C.Font = Root.Fonts[F_Normal];
	if (Zoom >= 1)
		ClipText(C, Pic.X + 4, Pic.Y + Pic.H - 14, ZoomText @ int(Zoom) $ "x");
	else
		ClipText(C, Pic.X + 4, Pic.Y + Pic.H - 14, ZoomText @ class'StringUtils'.static.FormatFloat(Zoom, 2) $ "x");

	ClippingRegion = All;
	class'CanvasUtils'.static.RestoreCanvas(C);
}

defaultproperties {
	LayersText="Layers"
	LayersHelp="The game draws a lower row over the rows above it. Drag a row to move it."
	AddLayerHelp="Adds a layer."
	RemLayerHelp="Removes the selected layer."
	NoLayerText="Press + to add a layer."

	ScaleText="Size"
	OffsetText="Offset"

	ShapeText="Shape"
	ShapeHelp="What the layer draws. Every shape but Rectangle can be an outline."
	TextureText="Texture"
	TextureHelp="Draws an image in place of the rectangle. Type its name as Package.Texture. Example: Botpack.CHair1"
	SmoothText="Smooth"
	SmoothHelp="Smooths the image when the layer is larger than the image."

	WidthText="Width"
	WidthHelp="Width in pixels."
	HeightText="Height"
	HeightHelp="Height in pixels."
	ScaleXText="Scale X"
	ScaleXHelp="Width as a multiple of the width of the image."
	ScaleYText="Scale Y"
	ScaleYHelp="Height as a multiple of the height of the image."

	OffsetXText="Offset X"
	OffsetXHelp="Pixels to the right of the middle of the screen. A negative number moves it left."
	OffsetYText="Offset Y"
	OffsetYHelp="Pixels below the middle of the screen. A negative number moves it up."

	ThicknessText="Thickness"
	ThicknessHelp="Width of the outline in pixels. 0 fills the shape."

	StyleText="Style"
	StyleHelp="Solid covers the game. Translucent adds its color as light. Modulated makes the game behind it brighter."
	StyleNormal="Solid"
	StyleTranslucent="Translucent"
	StyleModulated="Modulated"

	ColorRedText="Red"
	ColorGreenText="Green"
	ColorBlueText="Blue"
	ColorHelp="0 to 255."
	ColorAlphaText="Alpha"
	ColorAlphaHelp="Strength of the light from 1 to 255. A lower number lets more of the game show through."

	PresetsText="Presets"
	PresetsHelp="Click a crosshair to use it. Changes you have not saved stay until you close the window."
	AddPresetHelp="Makes a new crosshair as a copy of this one."
	RemPresetHelp="Deletes this crosshair."
	PresetNameText="Name"
	PresetNameHelp="The name of this crosshair."

	ZoomText="Zoom"

	SaveHelp="Saves every crosshair marked with a *."
	CloseHelp="Closes the window. You lose the changes you have not saved."
}
