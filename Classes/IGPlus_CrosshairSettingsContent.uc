class IGPlus_CrosshairSettingsContent extends UMenuPageWindow;

var IGPlus_CrosshairSettingsDialog ParentDialog;
var ClientSettings Settings;
var bool bUpdatingControls;

var IGPlus_Button Btn_AddLayer;
var IGPlus_Button Btn_RemLayer;

var IGPlus_CrosshairLayersListBox LB_Layers;
var UWindowList LastSelected;

// Presets: the list, + for a new one, - to delete the picked one, and its name.
var IGPlus_Button Btn_AddPreset;
var IGPlus_Button Btn_RemPreset;
var IGPlus_Label Lbl_Presets;
var localized string PresetsText;
var IGPlus_CrosshairPresetsListBox LB_Presets;
var IGPlus_EditControl Edit_PresetName;
var localized string PresetNameText;

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

var IGPlus_EditControl Edit_Texture;
var localized string TextureText;

var IGPlus_EditControl Edit_OffsetX;
var localized string OffsetXText;
var IGPlus_EditControl Edit_OffsetY;
var localized string OffsetYText;

var IGPlus_EditControl Edit_ScaleX;
var localized string ScaleXText;
var IGPlus_EditControl Edit_ScaleY;
var localized string ScaleYText;

var IGPlus_EditControl Edit_ColorRed;
var localized string ColorRedText;
var IGPlus_EditControl Edit_ColorGreen;
var localized string ColorGreenText;
var IGPlus_EditControl Edit_ColorBlue;
var localized string ColorBlueText;
var IGPlus_EditControl Edit_ColorAlpha;
var localized string ColorAlphaText;

var IGPlus_ComboBox Cmb_Style;
var localized string StyleText;
var localized string StyleNormal;
var localized string StyleMasked;
var localized string StyleTranslucent;
var localized string StyleModulated;

var IGPlus_Checkbox Chk_Smooth;
var localized string SmoothText;

var IGPlus_ComboBox Cmb_Shape;
var localized string ShapeText;
var IGPlus_EditControl Edit_Thickness;
var localized string ThicknessText;

var UWindowSmallCloseButton Btn_Close;
var UwindowSmallButton Btn_Save;

function CopyCrosshairLayers() {
	local bbPlayer P;
	local bbCHSpectator Spec;
	local int i;
	local IGPlus_CrosshairLayersListItem Item;

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

	for (i = 0; i < MaxLayers(); ++i) {
		if (Settings.GetCrosshairLayer(i).bUse == false)
			continue;

		Item = IGPlus_CrosshairLayersListItem(LB_Layers.Items.CreateItem(LB_Layers.ListClass));
		if (Item == none)
			continue;

		Item.Index   = i;
		Item.Texture = Settings.GetCrosshairLayer(i).Texture;
		Item.ScaleX  = Settings.GetCrosshairLayer(i).ScaleX;
		Item.ScaleY  = Settings.GetCrosshairLayer(i).ScaleY;
		Item.OffsetX = Settings.GetCrosshairLayer(i).OffsetX;
		Item.OffsetY = Settings.GetCrosshairLayer(i).OffsetY;
		Item.Color   = Settings.GetCrosshairLayer(i).Color;
		Item.Style   = Settings.GetCrosshairLayer(i).Style;
		Item.bSmooth = Settings.GetCrosshairLayer(i).bSmooth;
		Item.Shape   = Settings.GetCrosshairLayer(i).Shape;
		Item.Thickness = Settings.GetCrosshairLayer(i).Thickness;

		if (Item.Style == 0)
			Item.Style = 1;

		LB_Layers.Items.AppendItem(Item);
	}
}

function Save() {
	local int i;
	local IGPlus_CrosshairLayersListItem L;
	local color White;

	White.R = 255;
	White.G = 255;
	White.B = 255;
	White.A = 255;

	i = 0;
	for (L = IGPlus_CrosshairLayersListItem(LB_Layers.Items.Next); L != none && i < MaxLayers(); L = IGPlus_CrosshairLayersListItem(L.Next)) {
		Settings.SetCrosshairLayerUse(i, true);

		Settings.SetCrosshairLayerTexture(i, L.Texture);
		Settings.SetCrosshairLayerOffsetX(i, L.OffsetX);
		Settings.SetCrosshairLayerOffsetY(i, L.OffsetY);
		Settings.SetCrosshairLayerScaleX(i, L.ScaleX);
		Settings.SetCrosshairLayerScaleY(i, L.ScaleY);
		Settings.SetCrosshairLayerColor(i, L.Color);
		Settings.SetCrosshairLayerStyle(i, L.Style);
		Settings.SetCrosshairLayerSmooth(i, L.bSmooth);
		Settings.SetCrosshairLayerShape(i, L.Shape);
		Settings.SetCrosshairLayerThickness(i, L.Thickness);

		i++;
	}

	while(i < MaxLayers()) {
		Settings.SetCrosshairLayerUse(i, false);

		Settings.SetCrosshairLayerTexture(i, "");
		Settings.SetCrosshairLayerOffsetX(i, 0);
		Settings.SetCrosshairLayerOffsetY(i, 0);
		Settings.SetCrosshairLayerScaleX(i, 1);
		Settings.SetCrosshairLayerScaleY(i, 1);
		Settings.SetCrosshairLayerColor(i, White);
		Settings.SetCrosshairLayerStyle(i, 0);
		Settings.SetCrosshairLayerSmooth(i, false);
		Settings.SetCrosshairLayerShape(i, 0);
		Settings.SetCrosshairLayerThickness(i, 0);

		i++;
	}

	Settings.CreateCrosshairLayers();
	Settings.StoreCrosshairPreset(Edit_PresetName.GetValue());
	Settings.SaveConfig();
}

// The list of presets, with the picked one selected and its name in the box.
function LoadPresets() {
	local int i;
	local string PresetName;
	local IGPlus_CrosshairPresetsListItem Item;

	if (Settings == none)
		return;

	bUpdatingControls = true;
	LB_Presets.Items.Clear();
	LB_Presets.SelectedItem = none;
	for (i = 0; i < arraycount(Settings.CrosshairPresets); ++i) {
		PresetName = Settings.GetCrosshairPresetName(i);
		if (PresetName == "")
			continue;

		Item = IGPlus_CrosshairPresetsListItem(LB_Presets.Items.CreateItem(LB_Presets.ListClass));
		if (Item == none)
			continue;

		Item.Slot = i;
		Item.PresetName = PresetName;
		Item.Layers = Settings.CreateCrosshairPresetLayers(i);
		LB_Presets.Items.AppendItem(Item);

		if (i == Settings.CrosshairPreset) {
			LB_Presets.SetSelectedItem(Item);
			Edit_PresetName.SetValue(PresetName);
		}
	}
	bUpdatingControls = false;
}

function Load() {
	LB_Layers.Items.Clear();
	LB_Layers.SelectedItem = none;
	LastSelected = none;
	CopyCrosshairLayers();
	LoadPresets();
}

function Created() {
	local int i;

	super.Created();

	ParentDialog = IGPlus_CrosshairSettingsDialog(ParentWindow);

	LB_Layers = IGPlus_CrosshairLayersListBox(CreateControl(class'IGPlus_CrosshairLayersListBox', 10, 30, 256, 150));

	Btn_AddLayer = IGPlus_Button(CreateControl(class'IGPlus_Button', 10, 10, 16, 16));
	Btn_AddLayer.SetText("+");
	Btn_RemLayer = IGPlus_Button(CreateControl(class'IGPlus_Button', 30, 10, 16, 16));
	Btn_RemLayer.SetText("-");

	Lbl_Scale = IGPlus_Label(CreateControl(class'IGPlus_Label', 276, 10, 64, 16));
	Lbl_Scale.SetText(ScaleText);
	Lbl_Scale.SetHelpText("");
	Lbl_Scale.SetFont(F_Normal);
	Lbl_Scale.Align = TA_Center;

	Btn_ScaleUp = IGPlus_BtnUp(CreateControl(class'IGPlus_BtnUp', 302, 30, 12, 10));
	Btn_ScaleDown = IGPlus_BtnDown(CreateControl(class'IGPlus_BtnDown', 302, 60, 12, 10));
	Btn_ScaleLeft = IGPlus_BtnLeft(CreateControl(class'IGPlus_BtnLeft', 288, 44, 10, 12));
	Btn_ScaleRight = IGPlus_BtnRight(CreateControl(class'IGPlus_BtnRight', 318, 44, 10, 12));

	Lbl_Offset = IGPlus_Label(CreateControl(class'IGPlus_Label', 344, 10, 64, 16));
	Lbl_Offset.SetText(OffsetText);
	Lbl_Offset.SetHelpText("");
	Lbl_Offset.SetFont(F_Normal);
	Lbl_Offset.Align = TA_Center;

	Btn_OffsetUp = IGPlus_BtnUp(CreateControl(class'IGPlus_BtnUp', 370, 30, 12, 10));
	Btn_OffsetDown = IGPlus_BtnDown(CreateControl(class'IGPlus_BtnDown', 370, 60, 12, 10));
	Btn_OffsetLeft = IGPlus_BtnLeft(CreateControl(class'IGPlus_BtnLeft', 356, 44, 10, 12));
	Btn_OffsetRight = IGPlus_BtnRight(CreateControl(class'IGPlus_BtnRight', 386, 44, 10, 12));

	Edit_Texture = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 80, 150, 16));
	Edit_Texture.SetText(TextureText);
	Edit_Texture.SetFont(F_Normal);
	Edit_Texture.Align = TA_Left;
	Edit_Texture.SetHistory(true);
	Edit_Texture.SetDelayedNotify(true);
	Edit_Texture.SetNumericOnly(false);
	Edit_Texture.SetNumericFloat(false);
	Edit_Texture.EditBoxWidthFraction = (2.0/3.0);
	Edit_Texture.EditBoxWidth = 100;

	Edit_OffsetX = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 100, 150, 16));
	Edit_OffsetX.SetText(OffsetXText);
	Edit_OffsetX.SetFont(F_Normal);
	Edit_OffsetX.Align = TA_Left;
	Edit_OffsetX.SetHistory(true);
	Edit_OffsetX.SetDelayedNotify(true);
	Edit_OffsetX.SetNumericOnly(true);
	Edit_OffsetX.SetNumericFloat(false);
	Edit_OffsetX.SetNumericNegative(true);
	Edit_OffsetX.EditBoxWidthFraction = (1.0/3.0);
	Edit_OffsetX.EditBoxWidth = 50;

	Edit_OffsetY = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 120, 150, 16));
	Edit_OffsetY.SetText(OffsetYText);
	Edit_OffsetY.SetFont(F_Normal);
	Edit_OffsetY.Align = TA_Left;
	Edit_OffsetY.SetHistory(true);
	Edit_OffsetY.SetDelayedNotify(true);
	Edit_OffsetY.SetNumericOnly(true);
	Edit_OffsetY.SetNumericFloat(false);
	Edit_OffsetY.SetNumericNegative(true);
	Edit_OffsetY.EditBoxWidthFraction = (1.0/3.0);
	Edit_OffsetY.EditBoxWidth = 50;

	Edit_ScaleX = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 140, 150, 16));
	Edit_ScaleX.SetText(ScaleXText);
	Edit_ScaleX.SetFont(F_Normal);
	Edit_ScaleX.Align = TA_Left;
	Edit_ScaleX.SetHistory(true);
	Edit_ScaleX.SetDelayedNotify(true);
	Edit_ScaleX.SetNumericOnly(true);
	Edit_ScaleX.SetNumericFloat(true);
	Edit_ScaleX.EditBoxWidthFraction = (1.0/3.0);
	Edit_ScaleX.EditBoxWidth = 50;

	Edit_ScaleY = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 160, 150, 16));
	Edit_ScaleY.SetText(ScaleYText);
	Edit_ScaleY.SetFont(F_Normal);
	Edit_ScaleY.Align = TA_Left;
	Edit_ScaleY.SetHistory(true);
	Edit_ScaleY.SetDelayedNotify(true);
	Edit_ScaleY.SetNumericOnly(true);
	Edit_ScaleY.SetNumericFloat(true);
	Edit_ScaleY.EditBoxWidthFraction = (1.0/3.0);
	Edit_ScaleY.EditBoxWidth = 50;

	Edit_ColorRed = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 180, 150, 16));
	Edit_ColorRed.SetText(ColorRedText);
	Edit_ColorRed.SetFont(F_Normal);
	Edit_ColorRed.Align = TA_Left;
	Edit_ColorRed.SetHistory(true);
	Edit_ColorRed.SetDelayedNotify(true);
	Edit_ColorRed.SetNumericOnly(true);
	Edit_ColorRed.SetNumericFloat(false);
	Edit_ColorRed.SetMaxLength(3);
	Edit_ColorRed.EditBoxWidthFraction = (1.0/6.0);
	Edit_ColorRed.EditBoxWidth = 25;

	Edit_ColorGreen = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 200, 150, 16));
	Edit_ColorGreen.SetText(ColorGreenText);
	Edit_ColorGreen.SetFont(F_Normal);
	Edit_ColorGreen.Align = TA_Left;
	Edit_ColorGreen.SetHistory(true);
	Edit_ColorGreen.SetDelayedNotify(true);
	Edit_ColorGreen.SetNumericOnly(true);
	Edit_ColorGreen.SetNumericFloat(false);
	Edit_ColorGreen.SetMaxLength(3);
	Edit_ColorGreen.EditBoxWidthFraction = (1.0/6.0);
	Edit_ColorGreen.EditBoxWidth = 25;

	Edit_ColorBlue = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 220, 150, 16));
	Edit_ColorBlue.SetText(ColorBlueText);
	Edit_ColorBlue.SetFont(F_Normal);
	Edit_ColorBlue.Align = TA_Left;
	Edit_ColorBlue.SetHistory(true);
	Edit_ColorBlue.SetDelayedNotify(true);
	Edit_ColorBlue.SetNumericOnly(true);
	Edit_ColorBlue.SetNumericFloat(false);
	Edit_ColorBlue.SetMaxLength(3);
	Edit_ColorBlue.EditBoxWidthFraction = (1.0/6.0);
	Edit_ColorBlue.EditBoxWidth = 25;

	Edit_ColorAlpha = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 240, 150, 16));
	Edit_ColorAlpha.SetText(ColorAlphaText);
	Edit_ColorAlpha.SetFont(F_Normal);
	Edit_ColorAlpha.Align = TA_Left;
	Edit_ColorAlpha.SetHistory(true);
	Edit_ColorAlpha.SetDelayedNotify(true);
	Edit_ColorAlpha.SetNumericOnly(true);
	Edit_ColorAlpha.SetNumericFloat(false);
	Edit_ColorAlpha.SetMaxLength(3);
	Edit_ColorAlpha.EditBoxWidthFraction = (1.0/6.0);
	Edit_ColorAlpha.EditBoxWidth = 25;

	Cmb_Style = IGPlus_ComboBox(CreateControl(class'IGPlus_ComboBox', 276, 260, 150, 16));
	Cmb_Style.SetText(StyleText);
	Cmb_Style.SetFont(F_Normal);
	Cmb_Style.Align = TA_Left;
	Cmb_Style.SetEditable(false);
	Cmb_Style.EditBoxWidthFraction = (2.0/3.0);
	Cmb_Style.EditBoxWidth = 100;
	Cmb_Style.AddItem(StyleNormal, "1");
	Cmb_Style.AddItem(StyleMasked, "2");
	Cmb_Style.AddItem(StyleTranslucent, "3");
	Cmb_Style.AddItem(StyleModulated, "4");

	Chk_Smooth = IGPlus_Checkbox(CreateControl(class'IGPlus_Checkbox', 276, 280, 150, 16));
	Chk_Smooth.SetText(SmoothText);
	Chk_Smooth.SetFont(F_Normal);
	Chk_Smooth.Align = TA_Left;

	Cmb_Shape = IGPlus_ComboBox(CreateControl(class'IGPlus_ComboBox', 276, 300, 150, 16));
	Cmb_Shape.SetText(ShapeText);
	Cmb_Shape.SetFont(F_Normal);
	Cmb_Shape.Align = TA_Left;
	Cmb_Shape.SetEditable(false);
	Cmb_Shape.EditBoxWidthFraction = (2.0/3.0);
	Cmb_Shape.EditBoxWidth = 100;
	for (i = 0; i < arraycount(class'CrosshairLayer'.default.ShapeNames); i++)
		Cmb_Shape.AddItem(class'CrosshairLayer'.default.ShapeNames[i], string(i));

	Edit_Thickness = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 276, 320, 150, 16));
	Edit_Thickness.SetText(ThicknessText);
	Edit_Thickness.SetFont(F_Normal);
	Edit_Thickness.Align = TA_Left;
	Edit_Thickness.SetDelayedNotify(true);
	Edit_Thickness.SetNumericOnly(true);
	Edit_Thickness.SetNumericFloat(false);
	Edit_Thickness.SetMaxLength(2);
	Edit_Thickness.EditBoxWidthFraction = (1.0/6.0);
	Edit_Thickness.EditBoxWidth = 25;

	Btn_AddPreset = IGPlus_Button(CreateControl(class'IGPlus_Button', 436, 10, 16, 16));
	Btn_AddPreset.SetText("+");
	Btn_RemPreset = IGPlus_Button(CreateControl(class'IGPlus_Button', 456, 10, 16, 16));
	Btn_RemPreset.SetText("-");

	Lbl_Presets = IGPlus_Label(CreateControl(class'IGPlus_Label', 480, 10, 106, 16));
	Lbl_Presets.SetText(PresetsText);
	Lbl_Presets.SetHelpText("");
	Lbl_Presets.SetFont(F_Normal);
	Lbl_Presets.Align = TA_Left;

	LB_Presets = IGPlus_CrosshairPresetsListBox(CreateControl(class'IGPlus_CrosshairPresetsListBox', 436, 30, 150, 374));
	LB_Presets.BackgroundBrightness = ParentDialog.BackgroundBrightness;

	Edit_PresetName = IGPlus_EditControl(CreateControl(class'IGPlus_EditControl', 436, 408, 150, 16));
	Edit_PresetName.SetText(PresetNameText);
	Edit_PresetName.SetFont(F_Normal);
	Edit_PresetName.Align = TA_Left;
	Edit_PresetName.SetDelayedNotify(true);
	Edit_PresetName.SetNumericOnly(false);
	Edit_PresetName.SetNumericFloat(false);
	Edit_PresetName.SetMaxLength(32);
	Edit_PresetName.EditBoxWidthFraction = (3.0/4.0);
	Edit_PresetName.EditBoxWidth = 112;

	Btn_Close = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 554, 430, 32, 16));
	Btn_Save = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 518, 430, 32, 16));
	Btn_Save.SetText(class'IGPlus_SettingsScroll'.default.SaveButtonText);
}

function int MaxLayers() {
	if (Settings == none)
		return 0;
	return Settings.CrosshairLayerCount();
}

function int FindHighestIndex() {
	local int i;
	local IGPlus_CrosshairLayersListItem Item;

	i = -1;
	for (Item = IGPlus_CrosshairLayersListItem(LB_Layers.Items.Next); Item != none; Item = IGPlus_CrosshairLayersListItem(Item.Next))
		i = Max(i, Item.Index);

	return i;
}

function AddLayer() {
	local IGPlus_CrosshairLayersListItem Item;

	Item = IGPlus_CrosshairLayersListItem(LB_Layers.Items.CreateItem(LB_Layers.ListClass));
	if (Item == none)
		return;

	Item.Index   = FindHighestIndex()+1;
	Item.Texture = "";
	Item.ScaleX  = 1;
	Item.ScaleY  = 1;
	Item.OffsetX = 0;
	Item.OffsetY = 0;
	Item.Color.R = 255;
	Item.Color.G = 255;
	Item.Color.B = 255;
	Item.Color.A = 255;
	Item.Style   = 1;
	Item.bSmooth = false;
	Item.Shape   = 0;
	Item.Thickness = 0;

	LB_Layers.Items.AppendItem(Item);
}

function RemLayer() {
	LB_Layers.SelectedItem.Remove();
	LB_Layers.SelectedItem = none;
}

function FillControlsFor(IGPlus_CrosshairLayersListItem L) {
	if (L == none) {
		Edit_Texture.Clear();

		Edit_OffsetX.Clear();
		Edit_OffsetY.Clear();
		Edit_ScaleX.Clear();
		Edit_ScaleY.Clear();

		Edit_ColorRed.Clear();
		Edit_ColorGreen.Clear();
		Edit_ColorBlue.Clear();
		Edit_ColorAlpha.Clear();

		Cmb_Style.ClearValue();
		Cmb_Shape.ClearValue();
		Edit_Thickness.Clear();
	} else {
		Edit_Texture.SetValue(L.Texture);

		Edit_OffsetX.SetValue(string(L.OffsetX));
		Edit_OffsetY.SetValue(string(L.OffsetY));
		Edit_ScaleX.SetValue(string(L.ScaleX));
		Edit_ScaleY.SetValue(string(L.ScaleY));

		Edit_ColorRed.SetValue(string(L.Color.R));
		Edit_ColorGreen.SetValue(string(L.Color.G));
		Edit_ColorBlue.SetValue(string(L.Color.B));
		Edit_ColorAlpha.SetValue(string(L.Color.A));

		Cmb_Style.SetSelectedIndex(L.Style - 1);
		Chk_Smooth.bChecked = L.bSmooth;
		Cmb_Shape.SetSelectedIndex(Min(L.Shape, 5));
		Edit_Thickness.SetValue(string(L.Thickness));
	}
}

// A colour box holds 0 to 255. A larger number typed in becomes 255, in the box too.
function byte ColorValue(IGPlus_EditControl E) {
	local int V;
	local bool bWas;

	V = Clamp(int(E.GetValue()), 0, 255);
	if (string(V) != E.GetValue()) {
		bWas = bUpdatingControls;
		bUpdatingControls = true;
		E.SetValue(string(V));
		bUpdatingControls = bWas;
	}
	return V;
}

function Notify(UWindowDialogControl C, byte E) {
	local int Slot;

	if (bUpdatingControls)
		return;

	if (E == DE_Click) {
		if (C == Btn_AddLayer && Btn_AddLayer.bDisabled == false) {
			AddLayer();
		} else if (C == Btn_RemLayer && Btn_RemLayer.bDisabled == false) {
			RemLayer();
		} else if (C == Btn_AddPreset && Btn_AddPreset.bDisabled == false) {
			// The new preset is a copy. The layers shown stay as they are,
			// and Save writes them into the new preset.
			if (Settings.NewCrosshairPreset())
				LoadPresets();
		} else if (C == Btn_RemPreset && Btn_RemPreset.bDisabled == false) {
			if (Settings.DeleteCrosshairPreset())
				Load();
		} else if (C == LB_Presets && LB_Presets.SelectedItem != none) {
			// Another preset: drawn in the game from this click on.
			Slot = IGPlus_CrosshairPresetsListItem(LB_Presets.SelectedItem).Slot;
			if (Slot != Settings.CrosshairPreset) {
				Settings.PickCrosshairPreset(Slot);
				Load();
			}
		} else if (C == Btn_ScaleUp && Btn_ScaleUp.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleY += 1;
			bUpdatingControls = true;
			Edit_ScaleY.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleY));
			bUpdatingControls = false;
		} else if (C == Btn_ScaleDown && Btn_ScaleDown.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleY -= 1;
			bUpdatingControls = true;
			Edit_ScaleY.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleY));
			bUpdatingControls = false;
		} else if (C == Btn_ScaleLeft && Btn_ScaleLeft.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleX -= 1;
			bUpdatingControls = true;
			Edit_ScaleX.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleX));
			bUpdatingControls = false;
		} else if (C == Btn_ScaleRight && Btn_ScaleRight.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleX += 1;
			bUpdatingControls = true;
			Edit_ScaleX.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleX));
			bUpdatingControls = false;
		} else if (C == Btn_OffsetUp && Btn_OffsetUp.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetY -= 1;
			bUpdatingControls = true;
			Edit_OffsetY.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetY));
			bUpdatingControls = false;
		} else if (C == Btn_OffsetDown && Btn_OffsetDown.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetY += 1;
			bUpdatingControls = true;
			Edit_OffsetY.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetY));
			bUpdatingControls = false;
		} else if (C == Btn_OffsetLeft && Btn_OffsetLeft.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetX -= 1;
			bUpdatingControls = true;
			Edit_OffsetX.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetX));
			bUpdatingControls = false;
		} else if (C == Btn_OffsetRight && Btn_OffsetRight.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetX += 1;
			bUpdatingControls = true;
			Edit_OffsetX.SetValue(string(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetX));
			bUpdatingControls = false;
		} else if (C == LB_Layers && LastSelected != LB_Layers.SelectedItem) {
			bUpdatingControls = true;
			FillControlsFor(IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem));
			LastSelected = LB_Layers.SelectedItem;
			bUpdatingControls = false;
		} else if (C == Btn_Save) {
			Save();
			Load();
		}
	} else if (E == DE_Change) {
		if (C == Edit_Texture && Edit_Texture.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Texture = Edit_Texture.GetValue();
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Tex = none;
		} else if (C == Edit_OffsetX && Edit_OffsetX.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetX = int(Edit_OffsetX.GetValue());
		} else if (C == Edit_OffsetY && Edit_OffsetY.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).OffsetY = int(Edit_OffsetY.GetValue());
		} else if (C == Edit_ScaleX && Edit_ScaleX.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleX = float(Edit_ScaleX.GetValue());
		} else if (C == Edit_ScaleY && Edit_ScaleY.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).ScaleY = float(Edit_ScaleY.GetValue());
		} else if (C == Edit_ColorRed && Edit_ColorRed.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Color.R = ColorValue(Edit_ColorRed);
		} else if (C == Edit_ColorGreen && Edit_ColorGreen.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Color.G = ColorValue(Edit_ColorGreen);
		} else if (C == Edit_ColorBlue && Edit_ColorBlue.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Color.B = ColorValue(Edit_ColorBlue);
		} else if (C == Edit_ColorAlpha && Edit_ColorAlpha.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Color.A = ColorValue(Edit_ColorAlpha);
		} else if (C == Cmb_Style && LB_Layers.SelectedItem != none) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Style = int(Cmb_Style.GetValue2()); // the entry's style, 1 to 4
		} else if (C == Chk_Smooth && Chk_Smooth.bDisabled == false) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).bSmooth = Chk_Smooth.bChecked;
		} else if (C == Cmb_Shape && LB_Layers.SelectedItem != none) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Shape = Max(0, Cmb_Shape.GetSelectedIndex());
		} else if (C == Edit_Thickness && Edit_Thickness.EditBox.bCanEdit) {
			IGPlus_CrosshairLayersListItem(LB_Layers.SelectedItem).Thickness = Max(0, int(Edit_Thickness.GetValue()));
		}
	}
}

function BeforePaint(Canvas C, float X, float Y) {
	local bool HaveSelectedItem;
	local bool HaveNoSelectedItem;

	super.BeforePaint(C, X, Y);

	HaveSelectedItem = LB_Layers.SelectedItem != none;
	HaveNoSelectedItem = LB_Layers.SelectedItem == none;

	Btn_AddLayer.bDisabled = LB_Layers.Items.Count() >= MaxLayers();
	Btn_RemLayer.bDisabled = (LB_Layers.Items.Count() <= 0 || HaveNoSelectedItem);

	Btn_AddPreset.bDisabled = LB_Presets.Items.Count() >= 16;
	Btn_RemPreset.bDisabled = LB_Presets.Items.Count() <= 1;

	Btn_ScaleUp.bDisabled = HaveNoSelectedItem;
	Btn_ScaleDown.bDisabled = HaveNoSelectedItem;
	Btn_ScaleLeft.bDisabled = HaveNoSelectedItem;
	Btn_ScaleRight.bDisabled = HaveNoSelectedItem;

	Btn_OffsetUp.bDisabled = HaveNoSelectedItem;
	Btn_OffsetDown.bDisabled = HaveNoSelectedItem;
	Btn_OffsetLeft.bDisabled = HaveNoSelectedItem;
	Btn_OffsetRight.bDisabled = HaveNoSelectedItem;

	Edit_Texture.EditBox.bCanEdit = HaveSelectedItem;

	Edit_OffsetX.EditBox.bCanEdit = HaveSelectedItem;
	Edit_OffsetY.EditBox.bCanEdit = HaveSelectedItem;
	Edit_ScaleX.EditBox.bCanEdit = HaveSelectedItem;
	Edit_ScaleY.EditBox.bCanEdit = HaveSelectedItem;

	Edit_ColorRed.EditBox.bCanEdit = HaveSelectedItem;
	Edit_ColorGreen.EditBox.bCanEdit = HaveSelectedItem;
	Edit_ColorBlue.EditBox.bCanEdit = HaveSelectedItem;
	Edit_ColorAlpha.EditBox.bCanEdit = HaveSelectedItem;
	Edit_Thickness.EditBox.bCanEdit = HaveSelectedItem;

	if (Edit_Texture.EditBox.bCanEdit == false)
		Edit_Texture.Clear();

	if (Edit_OffsetX.EditBox.bCanEdit == false)
		Edit_OffsetX.Clear();
	if (Edit_OffsetY.EditBox.bCanEdit == false)
		Edit_OffsetY.Clear();
	if (Edit_ScaleX.EditBox.bCanEdit == false)
		Edit_ScaleX.Clear();
	if (Edit_ScaleY.EditBox.bCanEdit == false)
		Edit_ScaleY.Clear();

	if (Edit_ColorRed.EditBox.bCanEdit == false)
		Edit_ColorRed.Clear();
	if (Edit_ColorGreen.EditBox.bCanEdit == false)
		Edit_ColorGreen.Clear();
	if (Edit_ColorBlue.EditBox.bCanEdit == false)
		Edit_ColorBlue.Clear();
	if (Edit_ColorAlpha.EditBox.bCanEdit == false)
		Edit_ColorAlpha.Clear();
	if (Edit_Thickness.EditBox.bCanEdit == false)
		Edit_Thickness.Clear();

	Chk_Smooth.bDisabled = HaveNoSelectedItem;
}

function DrawCrosshairLayer(Canvas C, IGPlus_CrosshairLayersListItem L) {
	local float Scal;
	local float LenX, LenY;

	Scal = 4;

	if (L.Tex == none) {
		if (L.Texture == "")
			L.Tex = class'IGPlus_Assets'.static.Tex(Texture'CrossHairBase', "CrossHairBase");
		else
			L.Tex = Texture(DynamicLoadObject(L.Texture, class'Texture'));
	}

	if (L.Style == 0)
		L.Style = 1;

	C.Style = L.Style;
	C.DrawColor = L.Color;
	C.bNoSmooth = (L.bSmooth == false);

	if (L.Shape != 0) {
		class'CrosshairLayer'.static.DrawShape(C, Self, L.Shape, L.Thickness, L.ScaleX, L.ScaleY, 128 + L.OffsetX*Scal, 128 + L.OffsetY*Scal, Scal);
		if (L == LB_Layers.SelectedItem) {
			// The selected one gets a frame in the opposite colour around its square.
			LenX = int(L.ScaleX + 0.5) * Scal;
			LenY = int(L.ScaleY + 0.5) * Scal;
			C.DrawColor.R = L.Color.R ^ 0xFF;
			C.DrawColor.G = L.Color.G ^ 0xFF;
			C.DrawColor.B = L.Color.B ^ 0xFF;
			C.DrawColor.A = 255;
			C.Style = 1;
			DrawStretchedTexture(C, 128 - 0.5*LenX + L.OffsetX*Scal, 128 - 0.5*LenY + L.OffsetY*Scal, LenX, 1, L.Tex);
			DrawStretchedTexture(C, 128 - 0.5*LenX + L.OffsetX*Scal, 128 + 0.5*LenY + L.OffsetY*Scal - 1, LenX, 1, L.Tex);
			DrawStretchedTexture(C, 128 - 0.5*LenX + L.OffsetX*Scal, 128 - 0.5*LenY + L.OffsetY*Scal, 1, LenY, L.Tex);
			DrawStretchedTexture(C, 128 + 0.5*LenX + L.OffsetX*Scal - 1, 128 - 0.5*LenY + L.OffsetY*Scal, 1, LenY, L.Tex);
		}
		return;
	}

	LenX = L.ScaleX * L.Tex.USize * Scal;
	LenY = L.ScaleY * L.Tex.VSize * Scal;

	if (L == LB_Layers.SelectedItem) {
		C.DrawColor = L.Color;
		C.DrawColor.R = C.DrawColor.R ^ 0xFF;
		C.DrawColor.G = C.DrawColor.G ^ 0xFF;
		C.DrawColor.B = C.DrawColor.B ^ 0xFF;
		C.DrawColor.A = C.DrawColor.A ^ 0xFF;
		DrawStretchedTexture(C, 128 - 0.5*LenX + (L.OffsetX*Scal), 128 - 0.5*LenY + (L.OffsetY*Scal), LenX, LenY, L.Tex);

		C.DrawColor = L.Color;
		DrawStretchedTexture(C, 128 - 0.5*LenX + (L.OffsetX*Scal) + 1, 128 - 0.5*LenY + (L.OffsetY*Scal) + 1, LenX-2, LenY-2, L.Tex);
	} else {
		DrawStretchedTexture(C, 128 - 0.5*LenX + (L.OffsetX*Scal), 128 - 0.5*LenY + (L.OffsetY*Scal), LenX, LenY, L.Tex);
	}
}

function DrawCrosshair(Canvas C) {
	local IGPlus_CrosshairLayersListItem L;

	for (L = IGPlus_CrosshairLayersListItem(LB_Layers.Items.Next); L != none; L = IGPlus_CrosshairLayersListItem(L.Next))
		DrawCrosshairLayer(C, L);
}

function Paint(Canvas C, float X, float Y) {
	super.Paint(C, X, Y);

	class'CanvasUtils'.static.SaveCanvas(C);

	C.OrgX += int(10 * Root.GUIScale);
	C.OrgY += int(190 * Root.GUIScale);

	C.ClipX = 256 * Root.GUIScale;
	C.ClipY = 256 * Root.GUIScale;

	C.DrawColor.R = ParentDialog.BackgroundBrightness;
	C.DrawColor.G = ParentDialog.BackgroundBrightness;
	C.DrawColor.B = ParentDialog.BackgroundBrightness;
	C.DrawColor.A = 255;
	DrawStretchedTexture(C, 0, 0, 256, 256, Texture'WhiteTexture');

	C.DrawColor.R = C.DrawColor.R ^ 0xFF;
	C.DrawColor.G = C.DrawColor.G ^ 0xFF;
	C.DrawColor.B = C.DrawColor.B ^ 0xFF;
	C.DrawColor.A = 255;
	DrawStretchedTexture(C, 127, 0, 2, 256, class'IGPlus_Assets'.static.Tex(Texture'CrossHairBase', "CrossHairBase"));
	DrawStretchedTexture(C, 0, 127, 256, 2, class'IGPlus_Assets'.static.Tex(Texture'CrossHairBase', "CrossHairBase"));

	DrawCrosshair(C);

	class'CanvasUtils'.static.RestoreCanvas(C);
}

defaultproperties {
	ScaleText="Scale"
	OffsetText="Offset"
	TextureText="Texture"

	OffsetXText="Offset X"
	OffsetYText="Offset Y"
	ScaleXText="Scale X"
	ScaleYText="Scale Y"

	ColorRedText="Red"
	ColorGreenText="Green"
	ColorBlueText="Blue"
	ColorAlphaText="Alpha"

	StyleText="Style"
	StyleNormal="Normal"
	StyleMasked="Masked"
	StyleTranslucent="Translucent"
	StyleModulated="Modulated"

	SmoothText="Smooth"
	ShapeText="Shape"
	ThicknessText="Thickness"

	PresetsText="Presets"
	PresetNameText="Name"
}
