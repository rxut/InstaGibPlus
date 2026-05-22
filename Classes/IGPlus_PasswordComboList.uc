class IGPlus_PasswordComboList extends UWindowComboList;

function string GetDisplayLabel(string V) {
	local int L;
	local int i;
	local string Middle;
	local IGPlus_PasswordComboBox Cmb;

	Cmb = IGPlus_PasswordComboBox(Owner);
	if (Cmb == none || Cmb.bMaskInput == false)
		return V;

	L = Len(V);
	if (L == 0)
		return V;

	Middle = "";

	if (L < 4) {
		for (i = 0; i < L; i++)
			Middle = Middle $ "*";
		return Middle;
	}

	for (i = 0; i < L - 2; i++)
		Middle = Middle $ "*";

	return Left(V, 1) $ Middle $ Right(V, 1);
}

function BeforePaint(Canvas C, float X, float Y) {
	local float W, H, MaxWidth;
	local int Count;
	local UWindowComboListItem I;
	local float ListX, ListY;
	local float ExtraWidth;

	C.Font = Root.Fonts[F_Normal];
	C.SetPos(0, 0);

	MaxWidth = Owner.EditBoxWidth;
	ExtraWidth = ((HBorder + TextBorder) * 2);

	Count = Items.Count();
	if (Count > MaxVisible) {
		ExtraWidth += LookAndFeel.Size_ScrollbarWidth;
		WinHeight = (ItemHeight * MaxVisible) + (VBorder * 2);
	} else {
		VertSB.Pos = 0;
		WinHeight = (ItemHeight * Count) + (VBorder * 2);
	}

	for (I = UWindowComboListItem(Items.Next); I != None; I = UWindowComboListItem(I.Next)) {
		TextSize(C, RemoveAmpersand(GetDisplayLabel(I.Value)), W, H);
		if (W + ExtraWidth > MaxWidth)
			MaxWidth = W + ExtraWidth;
	}

	WinWidth = MaxWidth;

	ListX = Owner.EditAreaDrawX + Owner.EditBoxWidth - WinWidth;
	ListY = Owner.Button.WinTop + Owner.Button.WinHeight;

	if (Count > MaxVisible) {
		VertSB.ShowWindow();
		VertSB.SetRange(0, Count, MaxVisible);
		VertSB.WinLeft = WinWidth - LookAndFeel.Size_ScrollbarWidth - HBorder;
		VertSB.WinTop = HBorder;
		VertSB.WinWidth = LookAndFeel.Size_ScrollbarWidth;
		VertSB.WinHeight = WinHeight - 2*VBorder;
	} else {
		VertSB.HideWindow();
	}

	Owner.WindowToGlobal(ListX, ListY, WinLeft, WinTop);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	LookAndFeel.ComboList_DrawItem(Self, C, X, Y, W, H, GetDisplayLabel(UWindowComboListItem(Item).Value), Selected == Item);
}
