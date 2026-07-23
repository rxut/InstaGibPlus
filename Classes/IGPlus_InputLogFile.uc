class IGPlus_InputLogFile extends StatLogFile;

var string LogId;
var bool bStarted;
var bbPlayer PlayerRef;

var int Line;

// Trailing columns shared by every row type: the pawn's equipped/pending
// weapon at log time plus the row's v4 binding info. V4Data is
// "index,FP,FR,AP,AR" for client SavedMoves, "index,f=<flags>" for server
// moves, and the bare index for input-replication nodes.
function string PawnCols(bool bDetReady, string V4Data) {
	local string WeaponName;
	local string PendingName;
	local string SwitchState;

	if (PlayerRef == none)
		return "||||"$bDetReady$"|"$V4Data$"|";
	if (PlayerRef.Weapon != none)
		WeaponName = string(PlayerRef.Weapon.Class);
	if (PlayerRef.PendingWeapon != none)
		PendingName = string(PlayerRef.PendingWeapon.Class);
	// Switch-state snapshot: holster hold, tap latch, switch guard, client
	// entry gate, server window gate, ClientPending, weapon state name.
	SwitchState = "h="$PlayerRef.IGPlus_V4HolsterHoldUntilTS
		$",t="$PlayerRef.IGPlus_V4PendingFireTapTS
		$",g="$PlayerRef.IGPlus_DeterministicSwitchGuardUntil
		$",e="$PlayerRef.IGPlus_V4ClientEntryGateTS
		$",w="$PlayerRef.IGPlus_V4WeaponGateTS;
	if (PlayerRef.ClientPending != none)
		SwitchState = SwitchState$",cp="$PlayerRef.ClientPending.Class;
	if (PlayerRef.Weapon != none)
		SwitchState = SwitchState$",ws="$PlayerRef.Weapon.GetStateName();
	return "|"$WeaponName$"|"$PendingName$"|"$bDetReady$"|"$V4Data$"|"$SwitchState;
}

event BeginPlay() {
    // empty to override StatLog
}

function string PadTo2Digits(int A) {
    if (A < 10)
        return "0"$A;
    return string(A);
}

function StartLog() {
    local string FileName;

    bWorld = false;
    FileName = "../Logs/"$LogId$"_"$Level.Year$PadTo2Digits(Level.Month)$PadTo2Digits(Level.Day)$"_"$PadTo2Digits(Level.Hour)$PadTo2Digits(Level.Minute)$PadTo2Digits(Level.Second);
    StatLogFile = FileName$".tmp.csv";
    StatLogFinal = FileName$".csv";

    OpenLog();

    // header
    FileLog("Line|Type|TimeStamp|Delta|Forw|Back|Left|Right|Walk|Duck|Jump|Dodge|Fire|AltFire|ForceFire|ForceAltFire|ViewRot|Location|Velocity|bDodging|DodgeDir|DodgeTimer|Weapon|Pending|DetReady|V4Data|SwitchState");

    bStarted = true;
}

function StopLog() {
	if (bStarted == false)
		return;
	FlushLog();
	CloseLog();
	bStarted = false;
}

function LogInputGeneric(string Type, IGPlus_SavedInput I) {
	if (bStarted == false)
		StartLog();

	FileLog(++Line$"|"$Type$"|"$I.TimeStamp$"|"$I.Delta$"|"$I.bForw$"|"$I.bBack$"|"$I.bLeft$"|"$I.bRigh$"|"$I.bWalk$"|"$I.bDuck$"|"$I.bJump$"|"$I.bDodg$"|"$I.bFire$"|"$I.bAFir$"|"$I.bForceFireTap$"|"$I.bForceAltTap$"|"$(I.SavedViewRotation.Pitch&0xFFFF)$","$(I.SavedViewRotation.Yaw&0xFFFF)$"|"$I.SavedLocation$"|"$I.SavedVelocity$"|"$I.SavedDodging$"|"$I.SavedDodgeDir$"|"$I.SavedDodgeClickTimer$PawnCols(I.bDetReady, string(I.V4WeaponIndex)));
}

function LogInput(IGPlus_SavedInput I) {
	LogInputGeneric("Input", I);
}

function LogCAP(float TimeStamp, vector Loc, vector Vel, Actor NewBase) {
	if (bStarted == false)
		StartLog();
	
	if (Mover(NewBase) != none)
		Loc += NewBase.Location;

	FileLog(++Line$"|"$"CAP|"$TimeStamp$"|||||||||||||||"$Loc$"|"$Vel$"|||");
}

function LogInputReplay(IGPlus_SavedInput I) {
	LogInputGeneric("Replay", I);
}

function LogSavedMove(IGPlus_SavedMove M) {
	local string Row;

	if (bStarted == false)
		StartLog();

		Row =
			++Line$"|SavedMove|"$M.TimeStamp$"|"$M.Delta$
			"|||||"$M.bRun$"|"$M.bDuck$"|"$M.bPressedJump$
			"|"$M.DodgeMove$"|"$M.bFire$"|"$M.bAltFire$
			"|"$M.bForceFire$"|"$M.bForceAltFire$
		"|"$(M.IGPlus_SavedViewRotation.Pitch & 0xFFFF)$","$(M.IGPlus_SavedViewRotation.Yaw & 0xFFFF)$
		"|"$M.IGPlus_SavedLocation$
		"|"$M.IGPlus_SavedVelocity$
		"|"$M.SavedDodging$
		"|"$M.DodgeMove$
		"|"$PawnCols(M.bDetReady,
			M.V4WeaponIndex$","$M.V4FirePressIndex$","$M.V4FireReleaseIndex
			$","$M.V4AltPressIndex$","$M.V4AltReleaseIndex);

	FileLog(Row);
}

// v4 ServerMove transport rows (server side). Fire/AltFire show the packed
// end-held bits; V4Data carries the raw flags word for offline edge decoding.
function LogServerMove(IGPlus_ServerMove SM) {
	local string RowType;

	if (bStarted == false)
		StartLog();

	if (SM.bRedundantReplay)
		RowType = "ServerMoveR";
	else
		RowType = "ServerMove";

	FileLog(++Line$"|"$RowType$"|"$SM.TimeStamp$"|"$SM.MoveDeltaTime
		$"||||||||"
		$"|"$((SM.V4Flags & 0x2) != 0)$"|"$((SM.V4Flags & 0x8) != 0)$"||"
		$"||"$SM.ClientLocation$"|"$SM.ClientVelocity$"|||"
		$PawnCols(SM.bDetReady, SM.V4WeaponIndex$",f="$SM.V4Flags));
}
