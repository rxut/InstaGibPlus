// Keeps IG+'s references into its assets package (and the few stock models
// it names) working when the engine loaded IG+ with them broken.
//
// UT 469f: opening a demo from udemo's demo manager first checks every
// package the demo uses. Afterwards IG+'s class defaults and baked-in
// references into InstaGibPlusAssets can be None or point at the wrong
// object (players invisible in playback; console demoplay is fine, 469e is
// fine). Objects are looked up by name instead when a reference is broken,
// and the class defaults are repaired once per level (RepairDefaults).
class IGPlus_Assets extends Object;

// The assets package these classes were compiled against (BuildSettings.bat).
const AssetsPackage = "InstaGibPlusAssets_v3";

var LevelInfo RepairedLevel;   // default only: the level RepairDefaults last ran in

// Obj if it is the object named ObjName (no package: the assets package),
// else that object looked up by name. None only if it doesn't exist.
static function Object Fix(Object Obj, string ObjName, class<Object> ObjClass) {
	local string ShortName;
	local int Dot;

	ShortName = ObjName;
	Dot = InStr(ObjName, ".");
	if (Dot >= 0)
		ShortName = Mid(ObjName, Dot + 1);
	else
		ObjName = AssetsPackage $ "." $ ObjName;

	if (Obj != none && string(Obj.Name) ~= ShortName && ClassIsChildOf(Obj.Class, ObjClass))
		return Obj;
	return DynamicLoadObject(ObjName, ObjClass, true);
}

static function Texture Tex(Texture T, string ObjName) {
	return Texture(Fix(T, ObjName, class'Texture'));
}

static function Sound Snd(Sound S, string ObjName) {
	return Sound(Fix(S, ObjName, class'Sound'));
}

static function Mesh Msh(Mesh M, string ObjName) {
	return Mesh(Fix(M, ObjName, class'Mesh'));
}

// The model forced models use for skin Skin (IGPlus_ModelImport defaults).
static function string ForcedMeshName(int Skin, bool bRateCorrected) {
	if (Skin <= 3)
		return Eval(bRateCorrected, "IGPlus_FCommandoM", "IGPlus_FCommando");
	if (Skin <= 8)
		return Eval(bRateCorrected, "IGPlus_FSoldierM", "IGPlus_FSoldier");
	if (Skin <= 11)
		return Eval(bRateCorrected, "IGPlus_MCommandoF", "Botpack.Commando");
	if (Skin <= 16)
		return Eval(bRateCorrected, "IGPlus_MSoldierF", "Botpack.Soldier");
	return Eval(bRateCorrected, "IGPlus_BossF", "Botpack.Boss");
}

static function string Eval(bool bFirst, string First, string Second) {
	if (bFirst)
		return First;
	return Second;
}

// Once per level, on clients (bbPlayer.InitSettings). Context finds the
// actors spawned with a broken default before this ran.
static function RepairDefaults(Actor Context) {
	local int i, Repaired;
	local Mesh M;
	local Object O;

	if (Context == none || default.RepairedLevel == Context.Level)
		return;
	default.RepairedLevel = Context.Level;

	// Player models
	Repaired += RepairPawnMesh(Context, class'bbTFemale1', "IGPlus_FCommando");
	Repaired += RepairPawnMesh(Context, class'bbTFemale2', "IGPlus_FSoldier");
	Repaired += RepairPawnMesh(Context, class'bbTMale1', "Botpack.Commando");
	Repaired += RepairPawnMesh(Context, class'bbTMale2', "Botpack.Soldier");
	Repaired += RepairPawnMesh(Context, class'bbTBoss', "Botpack.Boss");

	// Forced models
	for (i = 0; i < 18; i++) {
		M = Msh(class'IGPlus_ModelImport'.default.DefaultMesh[i], ForcedMeshName(i, false));
		if (M != none && M != class'IGPlus_ModelImport'.default.DefaultMesh[i]) {
			class'IGPlus_ModelImport'.default.DefaultMesh[i] = M;
			Repaired++;
		}
		M = Msh(class'IGPlus_ModelImport'.default.RateCorrectedMesh[i], ForcedMeshName(i, true));
		if (M != none && M != class'IGPlus_ModelImport'.default.RateCorrectedMesh[i]) {
			class'IGPlus_ModelImport'.default.RateCorrectedMesh[i] = M;
			Repaired++;
		}
	}

	// Hitbox cylinders
	Repaired += RepairCylinder(Context, class'bbBaseCylinder', "IGPlus_BaseCylinder", "CylinderRed");
	Repaired += RepairCylinder(Context, class'bbBaseCylinderReduced', "IGPlus_BaseCylinderReduced", "CylinderRed");
	Repaired += RepairCylinder(Context, class'bbHeadCylinder', "IGPlus_HeadCylinder", "CylinderWhite");

	// Hit sounds (copied into each ClientSettings when it is made)
	O = Snd(class'ClientSettings'.default.DefaultHitSound[0], "HitSound");
	if (O != none && O != class'ClientSettings'.default.DefaultHitSound[0]) {
		class'ClientSettings'.default.DefaultHitSound[0] = Sound(O);
		Repaired++;
	}
	O = Snd(class'ClientSettings'.default.DefaultHitSound[2], "HitSoundFriendly");
	if (O != none && O != class'ClientSettings'.default.DefaultHitSound[2]) {
		class'ClientSettings'.default.DefaultHitSound[2] = Sound(O);
		Repaired++;
	}
	O = Snd(class'ClientSettings'.default.DefaultHitSound[3], "HitSound1");
	if (O != none && O != class'ClientSettings'.default.DefaultHitSound[3]) {
		class'ClientSettings'.default.DefaultHitSound[3] = Sound(O);
		Repaired++;
	}

	// Textures
	O = Tex(class'CrosshairLayer'.default.Texture, "CrossHairBase");
	if (O != none && O != class'CrosshairLayer'.default.Texture) {
		class'CrosshairLayer'.default.Texture = Texture(O);
		Repaired++;
	}
	O = Tex(class'IGPlus_FlagSprite'.default.Texture, "Flag");
	if (O != none && O != class'IGPlus_FlagSprite'.default.Texture) {
		class'IGPlus_FlagSprite'.default.Texture = Texture(O);
		Repaired++;
	}
	O = Fix(class'IGPlus_NetStats'.default.OldTex, "NetStats0", class'ScriptedTexture');
	if (O != none && O != class'IGPlus_NetStats'.default.OldTex) {
		class'IGPlus_NetStats'.default.OldTex = ScriptedTexture(O);
		Repaired++;
	}
	O = Fix(class'IGPlus_NetStats'.default.NewTex, "NetStats1", class'ScriptedTexture');
	if (O != none && O != class'IGPlus_NetStats'.default.NewTex) {
		class'IGPlus_NetStats'.default.NewTex = ScriptedTexture(O);
		Repaired++;
	}
	O = Tex(class'PureFlag'.default.Skin, "PureFlag");
	if (O != none && O != class'PureFlag'.default.Skin) {
		class'PureFlag'.default.Skin = Texture(O);
		Repaired++;
	}

	if (Repaired > 0)
		Log("Repaired"@Repaired@"broken references into"@AssetsPackage@"(the engine loaded them broken, e.g. udemo's demo manager on 469f)", 'IGPlus');
}

// A player class's model. Players already spawned with the broken one get
// the right one, unless they are hidden on purpose (waiting or spectating:
// stock PlayerWaiting sets Mesh None). Without their PlayerReplicationInfo
// yet that can't be told: bbPlayer decides once it arrives
// (IGPlus_MeshRepairPending).
static function int RepairPawnMesh(Actor Context, class<Pawn> PawnClass, string MeshName) {
	local Mesh Old, M;
	local Actor A;
	local Pawn P;

	Old = PawnClass.default.Mesh;
	M = Msh(Old, MeshName);
	if (M == none || M == Old)
		return 0;
	PawnClass.default.Mesh = M;
	foreach Context.AllActors(PawnClass, A) {
		P = Pawn(A);
		if (P == none || P.Class != PawnClass || P.Mesh != Old)
			continue;
		if (P.PlayerReplicationInfo == none) {
			if (bbPlayer(P) != none) {
				bbPlayer(P).IGPlus_MeshRepairPending = true;
				bbPlayer(P).IGPlus_MeshRepairOld = Old;
			}
		} else if (P.PlayerReplicationInfo.bIsSpectator == false && P.PlayerReplicationInfo.bWaitingPlayer == false) {
			P.Mesh = M;
		}
	}
	return 1;
}

static function int RepairCylinder(Actor Context, class<Actor> CylClass, string MeshName, string TexName) {
	local Mesh OldMesh, M;
	local Texture OldTex, T;
	local Actor A;
	local int Repaired;

	OldMesh = CylClass.default.Mesh;
	OldTex = CylClass.default.Texture;
	M = Msh(OldMesh, MeshName);
	T = Tex(OldTex, TexName);
	if (M != none && M != OldMesh) {
		CylClass.default.Mesh = M;
		Repaired++;
	}
	if (T != none && T != OldTex) {
		CylClass.default.Texture = T;
		Repaired++;
	}
	if (Repaired > 0)
		foreach Context.AllActors(CylClass, A) {
			if (M != none && A.Mesh == OldMesh)
				A.Mesh = M;
			if (T != none && A.Texture == OldTex)
				A.Texture = T;
		}
	return Repaired;
}
