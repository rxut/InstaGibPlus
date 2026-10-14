class IGPlus_SavedMove extends SavedMove;

// Player attributes after applying this move
var vector IGPlus_SavedLocation;
var vector IGPlus_SavedVelocity;
var rotator IGPlus_SavedViewRotation;
var int IGPlus_MergeCount;
var int JumpIndex;
var int DodgeIndex;
var int RunChangeIndex;
var int DuckChangeIndex;
var int FireIndex;
var int AltFireIndex;

var bool SavedDodging;
var bool bDetReady;
var int DetWeaponIndex;
var int DetChargeData;
// Local merge boundary, including weapons with no deterministic index.
var Weapon IGPlus_SavedWeapon;
// Predicted self-knockback explosions applied at the end of this move, in order.
var vector IGPlus_SKHit[6];
var int IGPlus_SKPushCount;
// Predicted translocation at the start of this move.
var bool bIGPlusTloc;
var vector IGPlusTlocDest;

function Clear2() {
    Clear();
    IGPlus_SavedWeapon = none;
    IGPlus_MergeCount = 0;
    IGPlus_SKPushCount = 0;
    bIGPlusTloc = false;
    JumpIndex = -1;
    DodgeIndex = -1;
    RunChangeIndex = -1;
    DuckChangeIndex = -1;
    FireIndex = -1;
    AltFireIndex = -1;
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
}
