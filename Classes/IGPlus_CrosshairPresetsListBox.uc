// The presets of the Crosshair Factory: one row for each, with a picture of
// the crosshair and the preset's name. A preset with changes that are not
// saved has a * after its name.
class IGPlus_CrosshairPresetsListBox extends UWindowListBox;

var byte BackgroundBrightness; // of the picture, as in the large preview

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local IGPlus_CrosshairPresetsListItem P;
	local Region Rows, Pic;
	local float Reach, Fit;
	local string Label;

	P = IGPlus_CrosshairPresetsListItem(Item);
	if (P == none)
		return;

	C.Style = 1;
	if (SelectedItem == Item) {
		C.DrawColor.R = 160;
		C.DrawColor.G = 160;
		C.DrawColor.B = 160;
		DrawStretchedTexture(C, X, Y, W, H, Texture'WhiteTexture');
	}

	C.DrawColor.R = BackgroundBrightness;
	C.DrawColor.G = BackgroundBrightness;
	C.DrawColor.B = BackgroundBrightness;
	DrawStretchedTexture(C, X+1, Y+1, H-2, H-2, Texture'WhiteTexture');

	// The crosshair at its own size, or as much smaller as it takes to fit.
	Fit = 1.0;
	Reach = class'IGPlus_CrosshairLayersListBox'.static.Reach(P.Layers);
	if (Reach > 0.5*H - 1)
		Fit = (0.5*H - 1) / Reach;

	// Nothing is drawn outside the picture.
	Rows = ClippingRegion;
	Pic.X = Max(Rows.X, X+1);
	Pic.Y = Max(Rows.Y, Y+1);
	Pic.W = Min(Rows.X + Rows.W, X+H-1) - Pic.X;
	Pic.H = Min(Rows.Y + Rows.H, Y+H-1) - Pic.Y;
	if (Pic.W > 0 && Pic.H > 0) {
		ClippingRegion = Pic;
		class'IGPlus_CrosshairLayersListBox'.static.DrawLayers(C, Self, P.Layers, X + 0.5*H, Y + 0.5*H, Fit, none);
		ClippingRegion = Rows;
	}

	Label = P.PresetName;
	if (P.bDirty)
		Label = Label @ "*";
	C.Style = 1;
	C.bNoSmooth = true;
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Font = Root.Fonts[F_Normal];
	ClipText(C, X+H+4, Y + 0.5*H - 5, Label);
}

defaultproperties {
	ListClass=class'IGPlus_CrosshairPresetsListItem'
	ItemHeight=34
	BackgroundBrightness=48
}
