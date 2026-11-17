class IGPlus_CrosshairSettingsDialog extends UWindowFramedWindow
	config(InstaGibPlus)
	perobjectconfig;

var config byte BackgroundBrightness;

function Created() {
	super.Created();

	MinWinWidth = default.MinWinWidth;
	MinWinHeight = default.MinWinHeight;
}

function Resized() {
	WinWidth = FMax(WinWidth, MinWinWidth);
	WinHeight = FMax(WinHeight, MinWinHeight);

	super.Resized();
}

function Close(optional bool bByParent) {
	super.Close(bByParent);

	if (Root.Console.IsInState('UWindow') && Root.Console.bShowConsole == false)
		Root.Console.CloseUWindow();

	SaveConfig();
}

function Load() {
	IGPlus_CrosshairSettingsContent(ClientArea).Load();
}

defaultproperties
{
	BackgroundBrightness=48

	ClientClass=class'IGPlus_CrosshairSettingsContent'
	WindowTitle="IG+ Crosshair Factory"
	bSizable=False
	bStatusBar=True
	WinWidth=602
	WinHeight=489
	MinWinWidth=602
	MinWinHeight=489
}