// Client: the debug lines (enableDebugData), as shown in the console, in
// Logs/IGPlusDebug_<date>_<time>.log so a tester can send the whole file.
class IGPlus_DebugLogFile extends StatLogFile;

var bool bStarted;
var int Lines;
var string FileName;

event BeginPlay() {
	// empty to override StatLog
}

function string PadTo2Digits(int A) {
	if (A < 10)
		return "0"$A;
	return string(A);
}

function StartLog() {
	if (bStarted)
		return;
	bWorld = false;
	FileName = "IGPlusDebug_"$Level.Year$PadTo2Digits(Level.Month)$PadTo2Digits(Level.Day)
		$"_"$PadTo2Digits(Level.Hour)$PadTo2Digits(Level.Minute)$PadTo2Digits(Level.Second);
	StatLogFile = "../Logs/"$FileName$".tmp.log";
	StatLogFinal = "../Logs/"$FileName$".log";
	OpenLog();
	FileLog("IG+ debug log, map "$Level.Title$", "$Level.Year$"-"$PadTo2Digits(Level.Month)$"-"$PadTo2Digits(Level.Day)
		$" "$PadTo2Digits(Level.Hour)$":"$PadTo2Digits(Level.Minute)$":"$PadTo2Digits(Level.Second));
	bStarted = true;
}

function StopLog() {
	if (bStarted == false)
		return;
	FlushLog();
	CloseLog();
	bStarted = false;
}

function WriteLine(string S) {
	if (bStarted == false)
		StartLog();
	FileLog(S);
	// ponytail: flush every 20 lines, a crash loses at most those
	if (++Lines % 20 == 0)
		FlushLog();
}

event Destroyed() {
	StopLog();
	Super.Destroyed();
}

defaultproperties {
	RemoteRole=ROLE_None
}
