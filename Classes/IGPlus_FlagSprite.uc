class IGPlus_FlagSprite extends Actor;

simulated function ConfigureForTeam(byte Team) {
	switch(Team) {
		case 0:
			Texture = class'IGPlus_Assets'.static.Tex(Texture'FlagRed', "FlagRed");
			break;

		case 1:
			Texture = class'IGPlus_Assets'.static.Tex(Texture'FlagBlue', "FlagBlue");
			break;

		case 2:
			Texture = class'IGPlus_Assets'.static.Tex(Texture'FlagGreen', "FlagGreen");
			break;

		case 3:
			Texture = class'IGPlus_Assets'.static.Tex(Texture'FlagGold', "FlagGold");
			break;

		default:
			Texture = class'IGPlus_Assets'.static.Tex(Texture'Flag', "Flag");
			break;
	}
}

defaultproperties {
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'Flag'

	RemoteRole=ROLE_None
	bHidden=True
}
