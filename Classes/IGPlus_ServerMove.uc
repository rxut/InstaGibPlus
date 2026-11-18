class IGPlus_ServerMove extends Actor;

var float TimeStamp;
var float MoveDeltaTime;
var vector ClientAcceleration;
var vector ClientLocation;
var vector ClientVelocity;
var int MiscData;
var int MiscData2;
var int View;
var Actor ClientBase;
var int OldMoveData1;
var int OldMoveData2;

var bool bDetReady;
var int DetWeaponIndex;
var int DetChargeData;
// Deterministic translocator: the last action again (its move may be lost),
// see bbPlayer.SendSavedMove.
var float DetRedoTS;
var int DetRedoData;
// The action before that one, while the server may have neither. It comes in
// a call of its own just ahead of the move (bbPlayer.xxServerDetRedoMore).
var float DetRedo2TS;
var int DetRedo2Data;
// Precise Rewind Time: what the shooter's screen showed (bbPlayer.IGPlus_PRTNote).
var int PRTData;
// The eye height the client traced this move's hitscan shot from (bbPlayer.IGPlus_EyePack). 0: none.
var int ShotEye;
// Adaptive Buffering: a move waiting in the queue keeps the call as it came
// (bbPlayer.IGPlus_ABIntercept). RawDelta is xxServerMove's MoveDeltaTime.
var int RawDelta;
var IGPlus_ServerMove Next;

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
}
