// Strafe flip transition frames for the stock models (bbPlayer.IGPlus_StrafeTurnMeshFor).
// Each mesh has its model's own vertices and triangles, imported as the model it
// stands in for is (same origin, scale and LOD style): the stock Botpack import,
// or InstaGibPlusAssets' copy for the female models (the IG suffix, another origin).
// Frame 0 is the stock frame 0, so the far-away LOD is built the same. StrafeL:
// StrafeR's last key frame into StrafeL's first, StrafeR: the other way, 8 frames
// each. The upper body follows the engine's straight-line blend, the legs turn
// (made offline from the stock frames: an as-rigid-as-possible interpolation of
// the legs on a nearest-neighbour graph, the feet kept at the blend's height).
class IGPlus_StrafeTurnMesh extends Object;

#exec MESH IMPORT MESH=IGPlus_StrafeTurnCommando ANIVFILE=Models\IGPlus_StrafeTurnCommando_a.3d DATAFILE=Models\IGPlus_StrafeTurnCommando_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_StrafeTurnCommando X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnCommando SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnCommando SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnCommando SEQ=StrafeR STARTFRAME=9 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_StrafeTurnCommando X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_StrafeTurnSoldier ANIVFILE=Models\IGPlus_StrafeTurnSoldier_a.3d DATAFILE=Models\IGPlus_StrafeTurnSoldier_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_StrafeTurnSoldier X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSoldier SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSoldier SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSoldier SEQ=StrafeR STARTFRAME=9 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_StrafeTurnSoldier X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_StrafeTurnBoss ANIVFILE=Models\IGPlus_StrafeTurnBoss_a.3d DATAFILE=Models\IGPlus_StrafeTurnBoss_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_StrafeTurnBoss X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnBoss SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnBoss SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnBoss SEQ=StrafeR STARTFRAME=9 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_StrafeTurnBoss X=0.0585 Y=0.0585 Z=0.117

#exec MESH IMPORT MESH=IGPlus_StrafeTurnFCommando ANIVFILE=Models\IGPlus_StrafeTurnFCommando_a.3d DATAFILE=Models\IGPlus_StrafeTurnFCommando_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_StrafeTurnFCommando X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnFCommando SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnFCommando SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnFCommando SEQ=StrafeR STARTFRAME=9 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_StrafeTurnFCommando X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_StrafeTurnFCommandoIG ANIVFILE=Models\IGPlus_StrafeTurnFCommando_a.3d DATAFILE=Models\IGPlus_StrafeTurnFCommando_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_StrafeTurnFCommandoIG X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnFCommandoIG SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnFCommandoIG SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnFCommandoIG SEQ=StrafeR STARTFRAME=9 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_StrafeTurnFCommandoIG X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_StrafeTurnSGirl ANIVFILE=Models\IGPlus_StrafeTurnSGirl_a.3d DATAFILE=Models\IGPlus_StrafeTurnSGirl_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_StrafeTurnSGirl X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSGirl SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSGirl SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSGirl SEQ=StrafeR STARTFRAME=9 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_StrafeTurnSGirl X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_StrafeTurnSGirlIG ANIVFILE=Models\IGPlus_StrafeTurnSGirl_a.3d DATAFILE=Models\IGPlus_StrafeTurnSGirl_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_StrafeTurnSGirlIG X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSGirlIG SEQ=All STARTFRAME=0 NUMFRAMES=17
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSGirlIG SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_StrafeTurnSGirlIG SEQ=StrafeR STARTFRAME=9 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_StrafeTurnSGirlIG X=0.0625 Y=0.0625 Z=0.125

var Mesh Commando;
var Mesh Soldier;
var Mesh Boss;
var Mesh FCommando;
var Mesh FCommandoIG;
var Mesh SGirl;
var Mesh SGirlIG;

defaultproperties
{
	Commando=LodMesh'IGPlus_StrafeTurnCommando'
	Soldier=LodMesh'IGPlus_StrafeTurnSoldier'
	Boss=LodMesh'IGPlus_StrafeTurnBoss'
	FCommando=LodMesh'IGPlus_StrafeTurnFCommando'
	FCommandoIG=LodMesh'IGPlus_StrafeTurnFCommandoIG'
	SGirl=LodMesh'IGPlus_StrafeTurnSGirl'
	SGirlIG=LodMesh'IGPlus_StrafeTurnSGirlIG'
}
