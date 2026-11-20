// The mesh of the hitbox debug cylinders (bbBaseCylinder, bbBaseCylinderReduced,
// bbHeadCylinder): the old cylinder of InstaGibPlusAssets with two frames, so a
// cylinder can be drawn at any radius and height, the way the hit checks size
// it (a crouching player's head shrinks away, for one). Radius 1 at DrawScale
// 1, so DrawScale sets the radius. Frame 0 is flat and frame 1 reaches
// MaxHalfHeight radii above and below the middle, so AnimFrame from 0 to 0.5
// sets the height. Made by Docs-private/debug-cylinder/gen_hitboxcylinder.py.
class IGPlus_HitboxCylinderMesh extends Object;

#exec MESH IMPORT MESH=IGPlus_HitboxCylinder ANIVFILE=Models\IGPlus_HitboxCylinder_a.3d DATAFILE=Models\IGPlus_HitboxCylinder_d.3d X=0 Y=0 Z=0 MLOD=False
#exec MESH ORIGIN MESH=IGPlus_HitboxCylinder X=0 Y=0 Z=0 YAW=-64 PITCH=0 ROLL=0
#exec MESH SEQUENCE MESH=IGPlus_HitboxCylinder SEQ=All STARTFRAME=0 NUMFRAMES=2
#exec MESHMAP NEW MESHMAP=IGPlus_HitboxCylinder MESH=IGPlus_HitboxCylinder
#exec MESHMAP SCALE MESHMAP=IGPlus_HitboxCylinder X=0.01 Y=0.01 Z=0.02

const MaxHalfHeight = 4.0;

// Draws A as an upright cylinder with its middle at Center.
static function Place(Actor A, vector Center, float Radius, float HalfHeight) {
	A.SetLocation(Center);
	A.DrawScale = FMax(Radius, 0.01);
	A.AnimFrame = 0.5 * FClamp(HalfHeight / (MaxHalfHeight * A.DrawScale), 0.0, 1.0);
}

defaultproperties
{
}
