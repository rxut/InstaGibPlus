class IGPlus_PasswordComboBox extends IGPlus_ComboBox;

var bool bMaskInput;

function Created() {
	Super(UWindowDialogControl).Created();

	EditBox = UWindowEditBox(CreateWindow(class'IGPlus_PasswordEditBox', 0, 0, WinWidth-12, WinHeight));
	EditBox.NotifyOwner = Self;
	EditBoxWidth = WinWidth / 2;
	EditBox.bTransient = True;

	Button = UWindowComboButton(CreateWindow(class'UWindowComboButton', WinWidth-12, 0, 12, 10));
	Button.Owner = Self;

	List = UWindowComboList(Root.CreateWindow(ListClass, 0, 0, 100, 100));
	List.LookAndFeel = LookAndFeel;
	List.Owner = Self;
	List.Setup();

	List.HideWindow();
	bListVisible = False;

	SetEditTextColor(LookAndFeel.EditBoxTextColor);

	IGPlus_PasswordEditBox(EditBox).bMaskInput = bMaskInput;
}

function SetMaskInput(bool bNew) {
	bMaskInput = bNew;
	if (EditBox != none)
		IGPlus_PasswordEditBox(EditBox).bMaskInput = bNew;
}

function ToggleMaskInput() {
	SetMaskInput(!bMaskInput);
}

defaultproperties {
	ListClass=class'IGPlus_PasswordComboList'
	bMaskInput=True
}
