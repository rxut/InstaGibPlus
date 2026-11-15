class CrosshairLayer extends Object;

var Texture Texture;
var int OffsetX;
var int OffsetY;
var float ScaleX;
var float ScaleY;
var color Color;
var byte Style;
var bool bSmooth;
// 0: the texture. Else a shape ScaleX by ScaleY pixels, drawn one pixel row at a time:
// 1 circle, 2 square, 3 diamond, 4 triangle pointing up, 5 triangle pointing down.
var byte Shape;
var int Thickness; // of a shape's outline in pixels, 0 fills the shape

var CrosshairLayer Next;

var localized string ShapeNames[6];

// Half the width of a shape on the row at height Y (from the middle, down is
// positive), for half sizes A and B, with every edge moved in by Inset pixels.
// Below 0: the row is outside the shape.
static function float ShapeHalfWidth(byte Shape, float A, float B, float Inset, float Y) {
	if (A <= 0 || B <= 0)
		return -1;

	switch (Shape) {
	case 1:
		A -= Inset;
		B -= Inset;
		if (A <= 0 || B <= 0 || Abs(Y) > B + 0.001)
			return -1;
		return A * Sqrt(FMax(0, 1 - Square(Y / B)));
	case 2:
		if (Abs(Y) > B - Inset + 0.001)
			return -1;
		return A - Inset;
	case 3:
		return (A*B - Inset*Sqrt(A*A + B*B) - A*Abs(Y)) / B;
	case 5:
		Y = -Y;
		// as 4, upside down
	case 4:
		if (Y > B - Inset + 0.001)
			return -1;
		return (A*B - Inset*Sqrt(4*B*B + A*A) + A*Y) / (2*B);
	}
	return -1;
}

// The pixels of one row of a shape W by H pixels: First to Last, except the
// hole from HoleFirst to HoleLast (no hole when HoleFirst > HoleLast).
// A pixel belongs to the shape when its centre does. False: nothing on this row.
static function bool ShapeRow(byte Shape, int W, int H, int Thickness, int Row, out int First, out int Last, out int HoleFirst, out int HoleLast) {
	local float A, B, Y, Half;

	A = 0.5 * W;
	B = 0.5 * H;
	Y = Row + 0.5 - B;
	HoleFirst = 0;
	HoleLast = -1;

	Half = ShapeHalfWidth(Shape, A, B, 0, Y);
	if (Half < 0)
		return false;
	Last = Min(W - 1, int(A + Half - 0.5 + 0.001));
	First = W - 1 - Last;
	if (Last < First)
		return false;

	if (Thickness > 0) {
		Half = ShapeHalfWidth(Shape, A, B, Thickness, Y);
		if (Half >= 0) {
			HoleLast = Min(Last, int(A + Half - 0.5 + 0.001));
			HoleFirst = W - 1 - HoleLast;
		}
	}
	return true;
}

static function DrawShapeTile(Canvas C, UWindowWindow Win, Texture T, float X, float Y, float W, float H) {
	if (Win != none) {
		Win.DrawStretchedTexture(C, X, Y, W, H, T);
	} else {
		C.SetPos(X, Y);
		C.DrawTile(T, W, H, 0, 0, T.USize, T.VSize);
	}
}

// Draws a shape centred on CX, CY, with Scale screen pixels for one pixel of
// the shape, in the Canvas's colour and style. Win: the window to draw in, none for the HUD.
static function DrawShape(Canvas C, UWindowWindow Win, byte Shape, int Thickness, float ScaleX, float ScaleY, float CX, float CY, float Scale) {
	local Texture T;
	local int W, H, Row, First, Last, HoleFirst, HoleLast;
	local float Left, Top;

	T = class'IGPlus_Assets'.static.Tex(Texture'CrossHairBase', "CrossHairBase");
	W = int(ScaleX + 0.5);
	H = int(ScaleY + 0.5);
	Left = CX - 0.5 * W * Scale;
	Top = CY - 0.5 * H * Scale;

	for (Row = 0; Row < H; Row++) {
		if (ShapeRow(Shape, W, H, Thickness, Row, First, Last, HoleFirst, HoleLast) == false)
			continue;
		if (HoleFirst > HoleLast) {
			DrawShapeTile(C, Win, T, Left + First*Scale, Top + Row*Scale, (Last - First + 1)*Scale, Scale);
		} else {
			if (HoleFirst > First)
				DrawShapeTile(C, Win, T, Left + First*Scale, Top + Row*Scale, (HoleFirst - First)*Scale, Scale);
			if (Last > HoleLast)
				DrawShapeTile(C, Win, T, Left + (HoleLast + 1)*Scale, Top + Row*Scale, (Last - HoleLast)*Scale, Scale);
		}
	}
}

DefaultProperties
{
	Texture=Texture'CrossHairBase'
	OffsetX=0
	OffsetY=0
	ScaleX=1
	ScaleY=1
	Color=(R=255,G=255,B=255,A=255)
	Style=1
	bSmooth=false
	Shape=0
	Thickness=0
	ShapeNames(0)="Texture"
	ShapeNames(1)="Circle"
	ShapeNames(2)="Square"
	ShapeNames(3)="Diamond"
	ShapeNames(4)="Triangle Up"
	ShapeNames(5)="Triangle Down"
}
