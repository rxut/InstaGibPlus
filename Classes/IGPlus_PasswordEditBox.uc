class IGPlus_PasswordEditBox extends IGPlus_EditBox;

var bool bMaskInput;
var float LastInsertTime;
var int LastInsertCaret;
var const float RevealSeconds;

function bool Insert(byte C) {
	if (Super.Insert(C)) {
		LastInsertTime = GetLevel().TimeSeconds;
		LastInsertCaret = CaretOffset - 1;
		return True;
	}
	return False;
}

function bool IsRevealActive() {
	if (LastInsertTime <= 0)
		return false;
	if (LastInsertCaret < 0 || LastInsertCaret >= Len(Value))
		return false;
	return (GetLevel().TimeSeconds - LastInsertTime) < RevealSeconds;
}

function string GetDisplayValue() {
	local int L;
	local int i;
	local string Result;
	local bool bHint;
	local bool bReveal;

	if (bMaskInput == false)
		return Value;

	L = Len(Value);
	if (L == 0)
		return Value;

	bReveal = IsRevealActive();
	bHint = (L >= 4);

	Result = "";
	for (i = 0; i < L; i++) {
		if (bHint && (i == 0 || i == L - 1))
			Result = Result $ Mid(Value, i, 1);
		else if (bReveal && i == LastInsertCaret)
			Result = Result $ Mid(Value, i, 1);
		else
			Result = Result $ "*";
	}

	return Result;
}

function Paint(Canvas C, float X, float Y) {
	local float W, H, FullW;
	local float TextY;
	local string Display;

	Display = GetDisplayValue();

	C.Font = Root.Fonts[Font];

	TextSize(C, "A", W, H);
	TextY = (WinHeight - H) / 2;

	TextSize(C, Display, FullW, H);
	TextSize(C, Left(Display, CaretOffset), W, H);

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	if (Offset < 0 && FullW <= WinWidth - 2)
		Offset = 0;
	else if (W + Offset < 0 || (Offset < 0 && FullW > WinWidth - 2 && W - H + Offset < 0))
		Offset = Min(0, -W + H);

	if (W + Offset > (WinWidth - 2)) {
		Offset = (WinWidth - 2) - W;
		if (Offset > 0) Offset = 0;
	}

	C.DrawColor = TextColor;

	if (bAllSelected) {
		DrawStretchedTexture(C, Offset + 1, TextY, W, H, Texture'UWindow.WhiteTexture');

		C.DrawColor.R = 255 ^ C.DrawColor.R;
		C.DrawColor.G = 255 ^ C.DrawColor.G;
		C.DrawColor.B = 255 ^ C.DrawColor.B;
	}

	ClipText(C, Offset + 1, TextY, Display);

	if ((!bHasKeyboardFocus) || (!bCanEdit))
		bShowCaret = False;
	else {
		if ((GetLevel().TimeSeconds > LastDrawTime + 0.3) || (GetLevel().TimeSeconds < LastDrawTime)) {
			LastDrawTime = GetLevel().TimeSeconds;
			bShowCaret = !bShowCaret;
		}
	}

	if (bShowCaret)
		ClipText(C, Offset + W - 1, TextY, "|");
}

defaultproperties {
	bMaskInput=True
	LastInsertTime=-1.0
	LastInsertCaret=-1
	RevealSeconds=1.5
}
