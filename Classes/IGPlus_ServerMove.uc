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
var int V4PulseData;
var Actor ClientBase;
var int OldMoveData1;
var int OldMoveData2;
var bool bV4EightballShotPack;
var int V4ShotSeq;
var int V4ShotSliceIndex;
var int V4ShotKind;
var int V4ShotCharge;
var bool bV4ShotInstant;
var bool bV4ShotTight;
var rotator V4ShotView;
var int V4ShotDX;
var int V4ShotDY;
var int V4ShotDZ;

var bool bDetReady;
var int V4WeaponIndex;
var int V4ChargeData;
var bool bUseV4;
var IGPlus_ServerMove Next;

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
}
