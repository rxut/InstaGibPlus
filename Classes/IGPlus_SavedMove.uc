class IGPlus_SavedMove extends SavedMove;

// Player attributes after applying this move
var vector IGPlus_SavedLocation;
var vector IGPlus_SavedVelocity;
var rotator IGPlus_SavedViewRotation;
var rotator IGPlus_SavedViewRotationStart;
var int IGPlus_MergeCount;
var int JumpIndex;
var int DodgeIndex;
var int RunChangeIndex;
var int DuckChangeIndex;
var int FireIndex;
var int AltFireIndex;
var int V4FirePressIndex;
var int V4FireReleaseIndex;
var int V4AltPressIndex;
var int V4AltReleaseIndex;

var bool SavedDodging;
var bool bV4FireStartHeld;
var bool bV4FireEndHeld;
var bool bV4AltStartHeld;
var bool bV4AltEndHeld;
var bool bV4EightballInstant;
var bool bDetReady;
var int V4WeaponIndex;
var int V4ChargeData;
var bool bUseServerMoveV4;
var bool bV4PackedForResend;
var int V4PackedMoveDeltaTime;
var int V4PackedMiscData;
var int V4PackedMiscData2;
var int V4PackedView;
var int V4PackedViewStart;
var int V4PackedFlags;
var int V4PackedAuxData;

function Clear2() {
    Clear();
    IGPlus_SavedViewRotationStart = rot(0,0,0);
    IGPlus_MergeCount = 0;
    JumpIndex = -1;
    DodgeIndex = -1;
    RunChangeIndex = -1;
    DuckChangeIndex = -1;
    FireIndex = -1;
    AltFireIndex = -1;
    V4FirePressIndex = -1;
    V4FireReleaseIndex = -1;
    V4AltPressIndex = -1;
    V4AltReleaseIndex = -1;
    bV4FireStartHeld = false;
    bV4FireEndHeld = false;
    bV4AltStartHeld = false;
    bV4AltEndHeld = false;
    bV4EightballInstant = false;
    bUseServerMoveV4 = false;
    bV4PackedForResend = false;
    V4PackedMoveDeltaTime = 0;
    V4PackedMiscData = 0;
    V4PackedMiscData2 = 0;
    V4PackedView = 0;
    V4PackedViewStart = 0;
    V4PackedFlags = 0;
    V4PackedAuxData = 0;
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     JumpIndex=-1
     DodgeIndex=-1
     RunChangeIndex=-1
     DuckChangeIndex=-1
     FireIndex=-1
     AltFireIndex=-1
     V4FirePressIndex=-1
     V4FireReleaseIndex=-1
     V4AltPressIndex=-1
     V4AltReleaseIndex=-1
}
