class UTPlusSnapshot extends Object;

var vector Loc, Vel;
var rotator Rot;
var float DuckFraction;
var float CollisionRadius;
var float CollisionHeight;
var bool bBasedOnMover;
var Actor BaseMover;
var float MoverZ;

var bool bSnapCollideActors;
var bool bSnapBlockActors;
var bool bSnapBlockPlayers;
var bool bSnapProjTarget;

var float ServerTimeStamp;
// Adaptive Buffering held the player still from this snapshot on (their
// move queue ran empty), and the other clients drew them standing there.
var bool bHeld;
// The number of the server tick this snapshot was taken in (UTPure.IGPlus_GlobalTick),
// and whether it was taken with no move having run (the start of a hold).
var int Tick;
var bool bNoMove;

var name  AnimSequence;
var float AnimFrame;
// The middle of the head as drawn (IGPlus_HeadTween.Cur), for the adaptive head hitbox.
var vector HeadDrawn;
var bool   bHeadDrawn;

defaultproperties
{
}