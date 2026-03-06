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
var int AddVelocityId;
var vector Momentum;

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
    Momentum = vect(0,0,0);
    bUseServerMoveV4 = false;
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
