// Transition frames for blends the engine would fold (bbPlayer.IGPlus_TransitionLayout,
// IGPlus_TransitionModel). One mesh for each model and source animation: Frames[model * 5 +
// source], models Commando, Soldier, Boss, FCommando, FCommando (InstaGibPlusAssets copy),
// SGirl, SGirl (InstaGibPlusAssets copy), sources StrafeR, StrafeL, StillFrRp, LandLgFr,
// DuckWlkL. Each has its model's own vertices and triangles, imported as the model it stands
// in for is (same origin, scale and LOD style: the female InstaGibPlusAssets copies have
// another origin). Frame 0 is the stock frame 0, so the far-away LOD is built the same.
// Each sequence is named as the target animation (bbPlayer.IGPlus_TransitionFrame for the
// order). Made offline from the stock frames (Docs-private/strafe-turn-frames/gen_frames.py):
// the legs, and on strafe flips, stopping a strafe and landing into one the chest and arms,
// turn (an as-rigid-as-possible interpolation on a nearest-neighbour graph, the feet kept at
// the blend's height). Starting a strafe from standing turns the legs and only the free arm,
// which passes in front of the chest, the change fading out toward the shoulder. The head,
// the weapon and the hand on it stay on the engine's straight-line blend everywhere.
class IGPlus_TransitionMesh extends Object;


#exec MESH IMPORT MESH=IGPlus_TF_Commando_StrafeR ANIVFILE=Models\IGPlus_TF_Commando_StrafeR_a.3d DATAFILE=Models\IGPlus_TF_Commando_StrafeR_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Commando_StrafeR X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_StrafeR SEQ=All STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_StrafeR SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Commando_StrafeR X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Commando_StrafeL ANIVFILE=Models\IGPlus_TF_Commando_StrafeL_a.3d DATAFILE=Models\IGPlus_TF_Commando_StrafeL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Commando_StrafeL X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_StrafeL SEQ=All STARTFRAME=0 NUMFRAMES=141
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_StrafeL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_StrafeL SEQ=StillFrRp STARTFRAME=9 NUMFRAMES=132
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Commando_StrafeL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Commando_StillFrRp ANIVFILE=Models\IGPlus_TF_Commando_StillFrRp_a.3d DATAFILE=Models\IGPlus_TF_Commando_StillFrRp_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Commando_StillFrRp X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_StillFrRp SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_StillFrRp SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Commando_StillFrRp X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Commando_LandLgFr ANIVFILE=Models\IGPlus_TF_Commando_LandLgFr_a.3d DATAFILE=Models\IGPlus_TF_Commando_LandLgFr_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Commando_LandLgFr X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_LandLgFr SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_LandLgFr SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Commando_LandLgFr X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Commando_DuckWlkL ANIVFILE=Models\IGPlus_TF_Commando_DuckWlkL_a.3d DATAFILE=Models\IGPlus_TF_Commando_DuckWlkL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Commando_DuckWlkL X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_DuckWlkL SEQ=All STARTFRAME=0 NUMFRAMES=161
#exec MESH SEQUENCE MESH=IGPlus_TF_Commando_DuckWlkL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=160
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Commando_DuckWlkL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Soldier_StrafeR ANIVFILE=Models\IGPlus_TF_Soldier_StrafeR_a.3d DATAFILE=Models\IGPlus_TF_Soldier_StrafeR_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Soldier_StrafeR X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_StrafeR SEQ=All STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_StrafeR SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Soldier_StrafeR X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Soldier_StrafeL ANIVFILE=Models\IGPlus_TF_Soldier_StrafeL_a.3d DATAFILE=Models\IGPlus_TF_Soldier_StrafeL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Soldier_StrafeL X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_StrafeL SEQ=All STARTFRAME=0 NUMFRAMES=141
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_StrafeL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_StrafeL SEQ=StillFrRp STARTFRAME=9 NUMFRAMES=132
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Soldier_StrafeL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Soldier_StillFrRp ANIVFILE=Models\IGPlus_TF_Soldier_StillFrRp_a.3d DATAFILE=Models\IGPlus_TF_Soldier_StillFrRp_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Soldier_StillFrRp X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_StillFrRp SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_StillFrRp SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Soldier_StillFrRp X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Soldier_LandLgFr ANIVFILE=Models\IGPlus_TF_Soldier_LandLgFr_a.3d DATAFILE=Models\IGPlus_TF_Soldier_LandLgFr_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Soldier_LandLgFr X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_LandLgFr SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_LandLgFr SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Soldier_LandLgFr X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Soldier_DuckWlkL ANIVFILE=Models\IGPlus_TF_Soldier_DuckWlkL_a.3d DATAFILE=Models\IGPlus_TF_Soldier_DuckWlkL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Soldier_DuckWlkL X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_DuckWlkL SEQ=All STARTFRAME=0 NUMFRAMES=161
#exec MESH SEQUENCE MESH=IGPlus_TF_Soldier_DuckWlkL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=160
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Soldier_DuckWlkL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_Boss_StrafeR ANIVFILE=Models\IGPlus_TF_Boss_StrafeR_a.3d DATAFILE=Models\IGPlus_TF_Boss_StrafeR_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Boss_StrafeR X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_StrafeR SEQ=All STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_StrafeR SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Boss_StrafeR X=0.0585 Y=0.0585 Z=0.117

#exec MESH IMPORT MESH=IGPlus_TF_Boss_StrafeL ANIVFILE=Models\IGPlus_TF_Boss_StrafeL_a.3d DATAFILE=Models\IGPlus_TF_Boss_StrafeL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Boss_StrafeL X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_StrafeL SEQ=All STARTFRAME=0 NUMFRAMES=141
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_StrafeL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_StrafeL SEQ=StillFrRp STARTFRAME=9 NUMFRAMES=132
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Boss_StrafeL X=0.0585 Y=0.0585 Z=0.117

#exec MESH IMPORT MESH=IGPlus_TF_Boss_StillFrRp ANIVFILE=Models\IGPlus_TF_Boss_StillFrRp_a.3d DATAFILE=Models\IGPlus_TF_Boss_StillFrRp_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Boss_StillFrRp X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_StillFrRp SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_StillFrRp SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Boss_StillFrRp X=0.0585 Y=0.0585 Z=0.117

#exec MESH IMPORT MESH=IGPlus_TF_Boss_LandLgFr ANIVFILE=Models\IGPlus_TF_Boss_LandLgFr_a.3d DATAFILE=Models\IGPlus_TF_Boss_LandLgFr_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Boss_LandLgFr X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_LandLgFr SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_LandLgFr SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Boss_LandLgFr X=0.0585 Y=0.0585 Z=0.117

#exec MESH IMPORT MESH=IGPlus_TF_Boss_DuckWlkL ANIVFILE=Models\IGPlus_TF_Boss_DuckWlkL_a.3d DATAFILE=Models\IGPlus_TF_Boss_DuckWlkL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_Boss_DuckWlkL X=-150 Y=40 Z=0 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_DuckWlkL SEQ=All STARTFRAME=0 NUMFRAMES=161
#exec MESH SEQUENCE MESH=IGPlus_TF_Boss_DuckWlkL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=160
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_Boss_DuckWlkL X=0.0585 Y=0.0585 Z=0.117

#exec MESH IMPORT MESH=IGPlus_TF_FCommando_StrafeR ANIVFILE=Models\IGPlus_TF_FCommando_StrafeR_a.3d DATAFILE=Models\IGPlus_TF_FCommando_StrafeR_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommando_StrafeR X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_StrafeR SEQ=All STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_StrafeR SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommando_StrafeR X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommando_StrafeL ANIVFILE=Models\IGPlus_TF_FCommando_StrafeL_a.3d DATAFILE=Models\IGPlus_TF_FCommando_StrafeL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommando_StrafeL X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_StrafeL SEQ=All STARTFRAME=0 NUMFRAMES=141
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_StrafeL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_StrafeL SEQ=StillFrRp STARTFRAME=9 NUMFRAMES=132
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommando_StrafeL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommando_StillFrRp ANIVFILE=Models\IGPlus_TF_FCommando_StillFrRp_a.3d DATAFILE=Models\IGPlus_TF_FCommando_StillFrRp_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommando_StillFrRp X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_StillFrRp SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_StillFrRp SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommando_StillFrRp X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommando_LandLgFr ANIVFILE=Models\IGPlus_TF_FCommando_LandLgFr_a.3d DATAFILE=Models\IGPlus_TF_FCommando_LandLgFr_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommando_LandLgFr X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_LandLgFr SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_LandLgFr SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommando_LandLgFr X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommando_DuckWlkL ANIVFILE=Models\IGPlus_TF_FCommando_DuckWlkL_a.3d DATAFILE=Models\IGPlus_TF_FCommando_DuckWlkL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommando_DuckWlkL X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_DuckWlkL SEQ=All STARTFRAME=0 NUMFRAMES=161
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommando_DuckWlkL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=160
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommando_DuckWlkL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommandoIG_StrafeR ANIVFILE=Models\IGPlus_TF_FCommando_StrafeR_a.3d DATAFILE=Models\IGPlus_TF_FCommando_StrafeR_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommandoIG_StrafeR X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_StrafeR SEQ=All STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_StrafeR SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommandoIG_StrafeR X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommandoIG_StrafeL ANIVFILE=Models\IGPlus_TF_FCommando_StrafeL_a.3d DATAFILE=Models\IGPlus_TF_FCommando_StrafeL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommandoIG_StrafeL X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_StrafeL SEQ=All STARTFRAME=0 NUMFRAMES=141
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_StrafeL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_StrafeL SEQ=StillFrRp STARTFRAME=9 NUMFRAMES=132
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommandoIG_StrafeL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommandoIG_StillFrRp ANIVFILE=Models\IGPlus_TF_FCommando_StillFrRp_a.3d DATAFILE=Models\IGPlus_TF_FCommando_StillFrRp_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommandoIG_StillFrRp X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_StillFrRp SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_StillFrRp SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommandoIG_StillFrRp X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommandoIG_LandLgFr ANIVFILE=Models\IGPlus_TF_FCommando_LandLgFr_a.3d DATAFILE=Models\IGPlus_TF_FCommando_LandLgFr_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommandoIG_LandLgFr X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_LandLgFr SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_LandLgFr SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommandoIG_LandLgFr X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_FCommandoIG_DuckWlkL ANIVFILE=Models\IGPlus_TF_FCommando_DuckWlkL_a.3d DATAFILE=Models\IGPlus_TF_FCommando_DuckWlkL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_FCommandoIG_DuckWlkL X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_DuckWlkL SEQ=All STARTFRAME=0 NUMFRAMES=161
#exec MESH SEQUENCE MESH=IGPlus_TF_FCommandoIG_DuckWlkL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=160
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_FCommandoIG_DuckWlkL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirl_StrafeR ANIVFILE=Models\IGPlus_TF_SGirl_StrafeR_a.3d DATAFILE=Models\IGPlus_TF_SGirl_StrafeR_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirl_StrafeR X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_StrafeR SEQ=All STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_StrafeR SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirl_StrafeR X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirl_StrafeL ANIVFILE=Models\IGPlus_TF_SGirl_StrafeL_a.3d DATAFILE=Models\IGPlus_TF_SGirl_StrafeL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirl_StrafeL X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_StrafeL SEQ=All STARTFRAME=0 NUMFRAMES=141
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_StrafeL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_StrafeL SEQ=StillFrRp STARTFRAME=9 NUMFRAMES=132
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirl_StrafeL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirl_StillFrRp ANIVFILE=Models\IGPlus_TF_SGirl_StillFrRp_a.3d DATAFILE=Models\IGPlus_TF_SGirl_StillFrRp_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirl_StillFrRp X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_StillFrRp SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_StillFrRp SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirl_StillFrRp X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirl_LandLgFr ANIVFILE=Models\IGPlus_TF_SGirl_LandLgFr_a.3d DATAFILE=Models\IGPlus_TF_SGirl_LandLgFr_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirl_LandLgFr X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_LandLgFr SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_LandLgFr SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirl_LandLgFr X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirl_DuckWlkL ANIVFILE=Models\IGPlus_TF_SGirl_DuckWlkL_a.3d DATAFILE=Models\IGPlus_TF_SGirl_DuckWlkL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirl_DuckWlkL X=-30 Y=-115 Z=20 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_DuckWlkL SEQ=All STARTFRAME=0 NUMFRAMES=161
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirl_DuckWlkL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=160
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirl_DuckWlkL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirlIG_StrafeR ANIVFILE=Models\IGPlus_TF_SGirl_StrafeR_a.3d DATAFILE=Models\IGPlus_TF_SGirl_StrafeR_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirlIG_StrafeR X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_StrafeR SEQ=All STARTFRAME=0 NUMFRAMES=9
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_StrafeR SEQ=StrafeL STARTFRAME=1 NUMFRAMES=8
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirlIG_StrafeR X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirlIG_StrafeL ANIVFILE=Models\IGPlus_TF_SGirl_StrafeL_a.3d DATAFILE=Models\IGPlus_TF_SGirl_StrafeL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirlIG_StrafeL X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_StrafeL SEQ=All STARTFRAME=0 NUMFRAMES=141
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_StrafeL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=8
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_StrafeL SEQ=StillFrRp STARTFRAME=9 NUMFRAMES=132
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirlIG_StrafeL X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirlIG_StillFrRp ANIVFILE=Models\IGPlus_TF_SGirl_StillFrRp_a.3d DATAFILE=Models\IGPlus_TF_SGirl_StillFrRp_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirlIG_StillFrRp X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_StillFrRp SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_StillFrRp SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirlIG_StillFrRp X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirlIG_LandLgFr ANIVFILE=Models\IGPlus_TF_SGirl_LandLgFr_a.3d DATAFILE=Models\IGPlus_TF_SGirl_LandLgFr_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirlIG_LandLgFr X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_LandLgFr SEQ=All STARTFRAME=0 NUMFRAMES=11
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_LandLgFr SEQ=StrafeL STARTFRAME=1 NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirlIG_LandLgFr X=0.0625 Y=0.0625 Z=0.125

#exec MESH IMPORT MESH=IGPlus_TF_SGirlIG_DuckWlkL ANIVFILE=Models\IGPlus_TF_SGirl_DuckWlkL_a.3d DATAFILE=Models\IGPlus_TF_SGirl_DuckWlkL_d.3d UNMIRROR=1 LODSTYLE=12
#exec MESH ORIGIN MESH=IGPlus_TF_SGirlIG_DuckWlkL X=23 Y=-115 Z=62 YAW=64 ROLL=-64
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_DuckWlkL SEQ=All STARTFRAME=0 NUMFRAMES=161
#exec MESH SEQUENCE MESH=IGPlus_TF_SGirlIG_DuckWlkL SEQ=StrafeR STARTFRAME=1 NUMFRAMES=160
#exec MESHMAP SCALE MESHMAP=IGPlus_TF_SGirlIG_DuckWlkL X=0.0625 Y=0.0625 Z=0.125

var Mesh Frames[35];

defaultproperties
{
	Frames(0)=LodMesh'IGPlus_TF_Commando_StrafeR'
	Frames(1)=LodMesh'IGPlus_TF_Commando_StrafeL'
	Frames(2)=LodMesh'IGPlus_TF_Commando_StillFrRp'
	Frames(3)=LodMesh'IGPlus_TF_Commando_LandLgFr'
	Frames(4)=LodMesh'IGPlus_TF_Commando_DuckWlkL'
	Frames(5)=LodMesh'IGPlus_TF_Soldier_StrafeR'
	Frames(6)=LodMesh'IGPlus_TF_Soldier_StrafeL'
	Frames(7)=LodMesh'IGPlus_TF_Soldier_StillFrRp'
	Frames(8)=LodMesh'IGPlus_TF_Soldier_LandLgFr'
	Frames(9)=LodMesh'IGPlus_TF_Soldier_DuckWlkL'
	Frames(10)=LodMesh'IGPlus_TF_Boss_StrafeR'
	Frames(11)=LodMesh'IGPlus_TF_Boss_StrafeL'
	Frames(12)=LodMesh'IGPlus_TF_Boss_StillFrRp'
	Frames(13)=LodMesh'IGPlus_TF_Boss_LandLgFr'
	Frames(14)=LodMesh'IGPlus_TF_Boss_DuckWlkL'
	Frames(15)=LodMesh'IGPlus_TF_FCommando_StrafeR'
	Frames(16)=LodMesh'IGPlus_TF_FCommando_StrafeL'
	Frames(17)=LodMesh'IGPlus_TF_FCommando_StillFrRp'
	Frames(18)=LodMesh'IGPlus_TF_FCommando_LandLgFr'
	Frames(19)=LodMesh'IGPlus_TF_FCommando_DuckWlkL'
	Frames(20)=LodMesh'IGPlus_TF_FCommandoIG_StrafeR'
	Frames(21)=LodMesh'IGPlus_TF_FCommandoIG_StrafeL'
	Frames(22)=LodMesh'IGPlus_TF_FCommandoIG_StillFrRp'
	Frames(23)=LodMesh'IGPlus_TF_FCommandoIG_LandLgFr'
	Frames(24)=LodMesh'IGPlus_TF_FCommandoIG_DuckWlkL'
	Frames(25)=LodMesh'IGPlus_TF_SGirl_StrafeR'
	Frames(26)=LodMesh'IGPlus_TF_SGirl_StrafeL'
	Frames(27)=LodMesh'IGPlus_TF_SGirl_StillFrRp'
	Frames(28)=LodMesh'IGPlus_TF_SGirl_LandLgFr'
	Frames(29)=LodMesh'IGPlus_TF_SGirl_DuckWlkL'
	Frames(30)=LodMesh'IGPlus_TF_SGirlIG_StrafeR'
	Frames(31)=LodMesh'IGPlus_TF_SGirlIG_StrafeL'
	Frames(32)=LodMesh'IGPlus_TF_SGirlIG_StillFrRp'
	Frames(33)=LodMesh'IGPlus_TF_SGirlIG_LandLgFr'
	Frames(34)=LodMesh'IGPlus_TF_SGirlIG_DuckWlkL'
}
