class IGPlus_ServerMove extends Actor;

var float TimeStamp;
var float MoveDeltaTime;
var vector ClientAcceleration;
var vector ClientLocation;
var vector ClientVelocity;
var int MiscData;
var int MiscData2;
var int View;
var int ViewStart;
var int V4Flags;
var int V4AuxData;
var Actor ClientBase;
var int OldMoveData1;
var int OldMoveData2;

var bool bDetReady;
var int V4WeaponIndex;
var int V4ChargeData;
var bool bUseV4;
var bool bRedundantReplay;
var IGPlus_ServerMove Next;

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
}
