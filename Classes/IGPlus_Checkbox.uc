class IGPlus_Checkbox extends UWindowCheckbox;

var color EnabledTextColor;

// Grayed out (UWindowCheckbox ignores clicks while disabled, and draws its
// disabled box), text too.
function SetDisabled(bool bNewDisabled) {
	if (bNewDisabled == bDisabled)
		return;
	if (bNewDisabled) {
		EnabledTextColor = TextColor;
		TextColor.R = 128;
		TextColor.G = 128;
		TextColor.B = 128;
	} else {
		TextColor = EnabledTextColor;
	}
	bDisabled = bNewDisabled;
}

// Admin windows: a setting that another setting turns on or off. Locked, the
// box shows what the game uses, grayed out, with LockHelp as its help. Open
// again, it shows Stored, the value the window loaded, and its own help.
// Save leaves a grayed-out box's key alone.
function SetLock(bool bLock, bool bLockedValue, bool bStored, string Help, string LockHelp) {
	if (bLock) {
		bChecked = bLockedValue;
		SetHelpText(LockHelp);
		ToolTipString = LockHelp;
		SetDisabled(true);
	} else {
		if (bDisabled)
			bChecked = bStored;
		SetHelpText(Help);
		ToolTipString = Help;
		SetDisabled(false);
	}
}

function MouseLeave() {
	super(UWindowDialogControl).MouseLeave();

	if(ToolTipString != "")
		ToolTip("");
}

simulated function MouseEnter() {
	local int CutPos;
	local int CutPos2;

	super(UWindowDialogControl).MouseEnter();

	if(ToolTipString != "") {
		CutPos = InStr(ToolTipString, "\\n");

		CutPos2 = InStr(ToolTipString, Chr(13));
		if ((CutPos == -1 && CutPos2 >= 0) || (CutPos >= 0 && CutPos2 >= 0 && CutPos2 < CutPos))
			CutPos = CutPos2;

		CutPos2 = InStr(ToolTipString, Chr(10));
		if ((CutPos == -1 && CutPos2 >= 0) || (CutPos >= 0 && CutPos2 >= 0 && CutPos2 < CutPos))
			CutPos = CutPos2;

		if (CutPos >= 0)
			ToolTip(Left(ToolTipString, CutPos));
		else
			ToolTip(ToolTipString);
	}

	if (!bDisabled && (OverSound != None))
		GetPlayerOwner().PlaySound( OverSound, SLOT_Interface );
}

function RClick(float X, float Y)
{
	local UWindowMessageBox W;
	if (HelpText == "") return;
	W = MessageBox(Text, HelpText, MB_OK, MR_OK);
	W.bLeaveOnscreen = true;
}
