// The layers of the crosshair in the Crosshair Factory window, bottom layer
// first. Also draws a list of layers as a crosshair, for the window's large
// preview and for the small pictures in the list of presets.
class IGPlus_CrosshairLayersListBox extends UWindowListBox;

// A layer's image: the texture named, or the white pixel for no name and for
// a name that does not exist.
static function Texture LayerTex(IGPlus_CrosshairLayersListItem L) {
	if (L.bTexLooked == false || L.TexName != L.Texture) {
		L.bTexLooked = true;
		L.TexName = L.Texture;
		L.Tex = none;
		if (L.Texture != "")
			L.Tex = Texture(DynamicLoadObject(L.Texture, class'Texture', true));
		if (L.Tex == none)
			L.Tex = class'IGPlus_Assets'.static.Tex(Texture'CrossHairBase', "CrossHairBase");
	}
	return L.Tex;
}

// An image layer with a texture of its own. Without one it is a filled
// rectangle, ScaleX by ScaleY pixels.
static function bool HasImage(IGPlus_CrosshairLayersListItem L) {
	return L.Shape == 0 && L.Texture != "";
}

// A layer's width and height in pixels of the game.
static function LayerSize(IGPlus_CrosshairLayersListItem L, out float W, out float H) {
	local Texture T;

	if (L.Shape != 0) {
		W = int(FClamp(L.ScaleX, 0.0, 1024.0) + 0.5);
		H = int(FClamp(L.ScaleY, 0.0, 1024.0) + 0.5);
	} else {
		T = LayerTex(L);
		W = L.ScaleX * T.USize;
		H = L.ScaleY * T.VSize;
	}
}

// How far a crosshair reaches from its middle, in pixels of the game.
static function float Reach(UWindowList Layers) {
	local IGPlus_CrosshairLayersListItem L;
	local float W, H, R;

	for (L = IGPlus_CrosshairLayersListItem(Layers.Next); L != none; L = IGPlus_CrosshairLayersListItem(L.Next)) {
		LayerSize(L, W, H);
		R = FMax(R, FMax(Abs(L.OffsetX) + 0.5 * Abs(W), Abs(L.OffsetY) + 0.5 * Abs(H)));
	}
	return R;
}

// Draws a crosshair in a window with its middle at CX, CY, Zoom pixels of the
// window for one pixel of the game. Marked gets a frame around it.
static function DrawLayers(Canvas C, UWindowWindow Win, UWindowList Layers, float CX, float CY, float Zoom, UWindowList Marked) {
	local IGPlus_CrosshairLayersListItem L;
	local float W, H, X, Y;

	for (L = IGPlus_CrosshairLayersListItem(Layers.Next); L != none; L = IGPlus_CrosshairLayersListItem(L.Next)) {
		class'CrosshairLayer'.static.SetupCanvas(C, L.Style, L.Color, L.bSmooth);
		if (L.Shape != 0) {
			class'CrosshairLayer'.static.DrawShape(C, Win, L.Shape, L.Thickness, L.ScaleX, L.ScaleY, CX + L.OffsetX*Zoom, CY + L.OffsetY*Zoom, Zoom);
		} else {
			LayerSize(L, W, H);
			Win.DrawStretchedTexture(C, CX + (L.OffsetX - 0.5*W)*Zoom, CY + (L.OffsetY - 0.5*H)*Zoom, W*Zoom, H*Zoom, LayerTex(L));
		}
	}

	L = IGPlus_CrosshairLayersListItem(Marked);
	if (L == none)
		return;
	// A frame one pixel outside the layer, in the opposite of its colour.
	LayerSize(L, W, H);
	W = Abs(W) * Zoom;
	H = Abs(H) * Zoom;
	X = CX + L.OffsetX*Zoom - 0.5*W;
	Y = CY + L.OffsetY*Zoom - 0.5*H;
	C.Style = 1;
	C.bNoSmooth = true;
	C.DrawColor.R = L.Color.R ^ 0xFF;
	C.DrawColor.G = L.Color.G ^ 0xFF;
	C.DrawColor.B = L.Color.B ^ 0xFF;
	C.DrawColor.A = 255;
	Win.DrawStretchedTexture(C, X - 1, Y - 1, W + 2, 1, Texture'WhiteTexture');
	Win.DrawStretchedTexture(C, X - 1, Y + H, W + 2, 1, Texture'WhiteTexture');
	Win.DrawStretchedTexture(C, X - 1, Y, 1, H, Texture'WhiteTexture');
	Win.DrawStretchedTexture(C, X + W, Y, 1, H, Texture'WhiteTexture');
}

// A number without the zeros a float is printed with: 5 and 2.5, not 5.000000.
static function string Num(float F) {
	local string S;

	if (F == int(F))
		return string(int(F));
	S = string(F);
	while (Right(S, 1) == "0")
		S = Left(S, Len(S) - 1);
	return S;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local IGPlus_CrosshairLayersListItem L;
	local UWindowList Before;
	local string Descr;
	local int N;

	if(SelectedItem == Item) {
		C.DrawColor.r = 160;
		C.DrawColor.g = 160;
		C.DrawColor.b = 160;
		DrawStretchedTexture(C, X, Y, W, H, Texture'WhiteTexture');
	}

	L = IGPlus_CrosshairLayersListItem(Item);
	if (L == none)
		return;

	// Its place in the drawing order, 1 for the bottom layer.
	for (Before = Item.Prev; Before != none; Before = Before.Prev)
		N++;

	if (L.Shape == 0 && L.Texture != "")
		Descr = L.Texture;
	else
		Descr = class'CrosshairLayer'.default.ShapeNames[Min(L.Shape, 5)];
	Descr = N $ ": " $ Descr @ Num(L.ScaleX) $ "x" $ Num(L.ScaleY);

	if (L.OffsetX != 0 || L.OffsetY != 0)
		Descr = Descr @ "@" @ L.OffsetX $ "," $ L.OffsetY;

	C.DrawColor = L.Color;
	C.DrawColor.A = 255;
	DrawStretchedTexture(C, X+1, Y+1, 14, H-2, Texture'WhiteTexture');

	C.DrawColor.R = 0;
	C.DrawColor.G = 0;
	C.DrawColor.B = 0;
	C.Font = Root.Fonts[F_Normal];
	ClipText(C, X+18, Y, Descr);
}

defaultproperties {
	ListClass=class'IGPlus_CrosshairLayersListItem'
	bCanDrag=True
	ItemHeight=13
}
