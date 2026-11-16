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
var byte IGPlus_SKKind[6];     // bbPlayer.IGPLUS_SK_*
var vector IGPlus_SKPush[6];   // a direct push (hammer), not from a splash
var int IGPlus_SKPushCount;
// Predicted translocation at the start of this move.
var bool bIGPlusTloc;
var vector IGPlusTlocDest;
var vector IGPlus_LiftExitShift; // left a moving lift: moved to the server's spot after the move
var float IGPlus_LiftExitVelZ;
// Own boarding: the lift moved for this move and where it was put (bbPlayer.IGPlus_OBBegin).
var Mover IGPlus_OBLift;
var vector IGPlus_OBLoc;
// Precise Rewind Time: what our last frame showed (bbPlayer.SendSavedMove).
var int IGPlus_PRTData;
// The eye height this move's hitscan shot was traced from (bbPlayer.IGPlus_EyePack). 0: none.
var int IGPlus_ShotEye;

function Clear2() {
    Clear();
    IGPlus_SavedWeapon = none;
    IGPlus_MergeCount = 0;
    IGPlus_SKPushCount = 0;
    bIGPlusTloc = false;
    IGPlus_LiftExitShift = vect(0,0,0);
    IGPlus_LiftExitVelZ = 0.0;
    IGPlus_OBLift = none;
    IGPlus_ShotEye = 0;
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
