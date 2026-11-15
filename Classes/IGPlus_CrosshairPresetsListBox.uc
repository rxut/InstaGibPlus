// The presets of the Crosshair Factory: one row for each, with a picture of
// the crosshair and the preset's name.
class IGPlus_CrosshairPresetsListBox extends UWindowListBox;

var byte BackgroundBrightness; // of the picture, as in the large preview

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local IGPlus_CrosshairPresetsListItem P;
	local CrosshairLayer L;
	local Region Rows, Pic;
	local float LenX, LenY, Reach, Fit;

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
	for (L = P.Layers; L != none; L = L.Next) {
		if (L.Texture == none)
			continue;
		if (L.Shape != 0)
			Reach = FMax(Abs(L.OffsetX) + 0.5 * Abs(L.ScaleX), Abs(L.OffsetY) + 0.5 * Abs(L.ScaleY));
		else
			Reach = FMax(Abs(L.OffsetX) + 0.5 * Abs(L.ScaleX) * L.Texture.USize, Abs(L.OffsetY) + 0.5 * Abs(L.ScaleY) * L.Texture.VSize);
		if (Reach * Fit > 0.5*H - 1)
			Fit = (0.5*H - 1) / Reach;
	}

	// Nothing is drawn outside the picture.
	Rows = ClippingRegion;
	Pic.X = Max(Rows.X, X+1);
	Pic.Y = Max(Rows.Y, Y+1);
	Pic.W = Min(Rows.X + Rows.W, X+H-1) - Pic.X;
	Pic.H = Min(Rows.Y + Rows.H, Y+H-1) - Pic.Y;
	if (Pic.W > 0 && Pic.H > 0) {
		ClippingRegion = Pic;
		for (L = P.Layers; L != none; L = L.Next) {
			if (L.Texture == none)
				continue;
			C.Style = L.Style;
			C.DrawColor = L.Color;
			C.bNoSmooth = (L.bSmooth == false);
			if (L.Shape != 0) {
				class'CrosshairLayer'.static.DrawShape(C, Self, L.Shape, L.Thickness, L.ScaleX, L.ScaleY, X + 0.5*H + Fit*L.OffsetX, Y + 0.5*H + Fit*L.OffsetY, Fit);
				continue;
			}
			LenX = Fit * L.ScaleX * L.Texture.USize;
			LenY = Fit * L.ScaleY * L.Texture.VSize;
			DrawStretchedTexture(C, X + 0.5*(H - LenX) + Fit*L.OffsetX, Y + 0.5*(H - LenY) + Fit*L.OffsetY, LenX, LenY, L.Texture);
		}
		ClippingRegion = Rows;
	}

	C.Style = 1;
	C.bNoSmooth = true;
	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Font = Root.Fonts[F_Normal];
	ClipText(C, X+H+4, Y + 0.5*H - 5, P.PresetName);
}

defaultproperties {
	ListClass=class'IGPlus_CrosshairPresetsListItem'
	ItemHeight=34
	BackgroundBrightness=48
}
