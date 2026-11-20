class PureHUDHelper extends Actor;

var bool bInOvertime;
var int OvertimeOffset;
var int EndOfGameTime;
var bool bPaused;
var float GRISecondCountOffset;

// Dead: the server keeps our weapons and inventory for the trade window
// (2 x MaxTradeTimeMargin, bbPlayer state Dying) and they keep reaching us
// until it discards them. Stock discards them in Died. So for one HUD draw,
// the dead pawn the HUD is about to show (ChallengeHUD.HUDSetup's PawnOwner)
// goes without them: no ammo count, weapon bar or its pending switch, armor
// or boots once the health reads 0. Someone else's armor and boots come from
// their PRI (spectators, demos), which updates once a second, so those go
// too. RestoreDead puts it all back after the draw (traded shots still need
// the weapons). Returns None for the living and for spectators.
static function Pawn HideDead(HUD H, out Weapon W, out Weapon Pending, out Inventory Inv, out int Armor, out int Boots) {
	local PlayerPawn PP;
	local Pawn P;
	local bbPlayerReplicationInfo PRI;

	PP = PlayerPawn(H.Owner);
	if (PP == none)
		return none;
	P = PP;
	if (PP.ViewTarget != none && PP.ViewTarget.bIsPawn)
		P = Pawn(PP.ViewTarget);
	if (P.Health > 0 || P.PlayerReplicationInfo == none || P.PlayerReplicationInfo.bIsSpectator)
		return none;

	W = P.Weapon;
	Pending = P.PendingWeapon;
	Inv = P.Inventory;
	P.Weapon = none;
	P.PendingWeapon = none;
	P.Inventory = none;
	PRI = bbPlayerReplicationInfo(P.PlayerReplicationInfo);
	if (PRI != none) {
		Armor = PRI.Armor;
		Boots = PRI.Boots;
		PRI.Armor = 0;
		PRI.Boots = 0;
	}
	return P;
}

static function RestoreDead(Pawn P, Weapon W, Weapon Pending, Inventory Inv, int Armor, int Boots) {
	local bbPlayerReplicationInfo PRI;

	if (P == none)
		return;
	if (P.Weapon == none)
		P.Weapon = W;
	if (P.PendingWeapon == none)
		P.PendingWeapon = Pending;
	if (P.Inventory == none)
		P.Inventory = Inv;
	PRI = bbPlayerReplicationInfo(P.PlayerReplicationInfo);
	if (PRI != none) {
		if (PRI.Armor == 0)
			PRI.Armor = Armor;
		if (PRI.Boots == 0)
			PRI.Boots = Boots;
	}
}

static function int GetClockTime(HUD H) {
	local int Rem;
	local TournamentGameReplicationInfo TGRI;

	TGRI = TournamentGameReplicationInfo(H.PlayerOwner.GameReplicationInfo);

	if (TGRI != none && (default.bPaused ^^ (H.Level.Pauser != ""))) {
		default.bPaused = !default.bPaused;
		if (default.bPaused) {
			default.GRISecondCountOffset = H.Level.TimeSeconds - TGRI.SecondCount;
		} else {
			TGRI.SecondCount = H.Level.TimeSeconds - default.GRISecondCountOffset;
		}
	}

	if (TGRI != none && TGRI.GameEndedComments == "") {
		// game hasnt ended yet
		Rem = TGRI.RemainingTime;
		if (Rem == 0) {
			if (TGRI.TimeLimit <= 0) {
				// playing with score limit
				default.EndOfGameTime = TGRI.ElapsedTime;
			} else {
				// regular play-time is over
				if (default.bInOvertime == false)
					default.OvertimeOffset = TGRI.ElapsedTime;

				default.bInOvertime = true;
				default.EndOfGameTime = TGRI.ElapsedTime - default.OvertimeOffset;
			}
		} else {
			// playing with time limit
			default.bInOvertime = false;
			default.EndOfGameTime = Rem;
		}
	}

	return default.EndOfGameTime;
}

static function DrawTime(ChallengeHUD H, Canvas C) {
	local int Min, Sec;
	local float FullSize;
	local float X, Y;
	local float XL;
	local int Seconds;
	local float CharX, CharY;
	local float CharXScaled, CharYScaled;

	CharX = 25.0;
	CharY = 64.0;
	CharXScaled = CharX * H.Scale * 1.03;
	CharYScaled = CharY * H.Scale * 1.03;

	C.DrawColor = H.HUDColor;

	Seconds = GetClockTime(H);
	Min = Seconds / 60;
	Sec = Seconds % 60;

	if (Min >= 200)
		XL = 25; // extra full 7-Seg char
	else if (Min >= 100)
		XL = 15; // extra 1 as 7-Seg char
	else
		XL = 0;

	if (H.bHideStatus) {
		if (H.bHideAllWeapons) {
			X = 0.5*C.ClipX - 384*H.Scale - XL*H.Scale;
			Y = C.ClipY - 64*H.Scale;
		} else {
			X = C.ClipX - 160*H.Scale - XL*H.Scale;
			Y = 128*H.Scale;
		}
	} else {
		X = C.ClipX - 128*H.StatusScale*H.Scale - 160*H.Scale - XL*H.Scale;
		Y = 128*H.Scale;
	}

	C.SetPos(X,Y);
	C.DrawTile(class'IGPlus_Assets'.static.Tex(Texture'PureTimeBG', "PureTimeBG"), 148*H.Scale + XL * H.Scale, 64*H.Scale, 0, 0, 128.0, 64.0);
	C.Style = H.Style;
	C.DrawColor = H.WhiteColor;

	X += XL * H.Scale;

	if (H.Level.bHighDetailMode)
		C.Style = ERenderStyle.STY_Translucent;

	FullSize = CharXScaled * 4 + 12 * H.Scale; //At least 4 digits and : (extra size not counted)

	C.SetPos( X + 70 * H.Scale, Y + 14 * H.Scale);
	C.CurX -= (FullSize / 2);
	if (Min >= 100) {
		C.CurX -= XL * H.Scale;
		C.DrawTile(Texture'BotPack.HudElements1', H.Scale*XL, CharYScaled, ((Min/100)%10)*CharX + (CharX - XL), 0, XL, CharY);
		Min = Min%100;
	}
	C.DrawTile(Texture'BotPack.HudElements1', CharXScaled, CharYScaled, (Min/10)*CharX, 0, CharX, CharY);
	C.DrawTile(Texture'BotPack.HudElements1', CharXScaled, CharYScaled, (Min%10)*CharX, 0, CharX, CharY);
	C.CurX -= 7 * H.Scale;
	C.DrawTile(Texture'BotPack.HudElements1', CharXScaled, CharYScaled, 25, 64, CharX, CharY); //DOUBLE DOT HERE
	C.CurX -= 6 * H.Scale;
	C.DrawTile(Texture'BotPack.HudElements1', CharXScaled, CharYScaled, (Sec/10)*CharX, 0, CharX, CharY);
	C.DrawTile(Texture'BotPack.HudElements1', CharXScaled, CharYScaled, (Sec%10)*CharX, 0, CharX, CharY);
}
