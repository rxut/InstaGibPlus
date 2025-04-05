class UTPlusSnapshot extends Object;

var vector Loc, Vel, Acc;
var rotator Rot, VR;
var float BaseEyeHeight;
var float EyeHeight;
var float CollisionRadius;
var float CollisionHeight;

var bool bSnapCollideActors;
var bool bSnapBlockActors;
var bool bSnapBlockPlayers;
var bool bSnapProjTarget;

var float ServerTimeStamp;
var float ClientTimeStamp;

defaultproperties
{
    bSnapCollideActors=true;
    bSnapBlockActors=true;
    bSnapBlockPlayers=true;
    bSnapProjTarget=true;
}