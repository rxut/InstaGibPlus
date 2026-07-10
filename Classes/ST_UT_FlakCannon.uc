// ===============================================================
// Stats.ST_UT_FlakCannon: FlakCannon with V4 deterministic fire
// ===============================================================

class ST_UT_FlakCannon extends UT_FlakCannon;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var class<ST_UTChunk> ChunkClasses[4];

var ST_FlakSlug LocalSlugDummy;

// V4 deterministic fire state
var float NextV4FireTS;
var bool bUseDeterministicData;
var vector DeterministicShotLoc;
var rotator DeterministicShotRot;

simulated final function WeaponSettingsRepl FindWeaponSettings() {
	local WeaponSettingsRepl S;

	foreach AllActors(class'WeaponSettingsRepl', S)
		return S;

	return none;
}

simulated final function WeaponSettingsRepl GetWeaponSettings() {
	if (WSettings != none)
		return WSettings;

	WSettings = FindWeaponSettings();
	return WSettings;
}

simulated function bool IsPingCompEnabled() {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	return WS != None && WS.FlakCompensatePing;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;
}


simulated function bool IsV4Active() {
	if (!IsPingCompEnabled())
		return false;
	if (bbPlayer(Owner) == none)
		return false;
	return true;
}

// One owner's deterministic state must never transfer to the next.
simulated function V4ResetDeterministicState() {
	NextV4FireTS = 0.0;
	bUseDeterministicData = false;
}

function GiveTo(Pawn Other) {
	V4ResetDeterministicState();
	Super.GiveTo(Other);
}

function DropFrom(vector StartLocation) {
	V4ResetDeterministicState();
	Super.DropFrom(StartLocation);
}

simulated function bool IsDeterministicReady() {
	local Pawn PawnOwner;

	if (!IsV4Active())
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return false;
	if (bbPlayer(PawnOwner).IGPlus_IsDeterministicSwitchGuardActive())
		return false;
	if (TournamentPlayer(PawnOwner) != none
		&& TournamentPlayer(PawnOwner).ClientPending != none
		&& TournamentPlayer(PawnOwner).ClientPending != self)
		return false;
	if (PawnOwner.Weapon != self)
		return false;
	if (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		return false;
	if (bChangeWeapon)
		return false;
	if (IsInState('Pickup'))
		return false;
	if (IsInState('DownWeapon'))
		return false;
	if (IsInState('ClientDown'))
		return false;
	if (!bCanClientFire)
		return false;
	return true;
}

// Flakm mesh: 'Fire'    = 10 frames, base rate 30fps (no RATE directive, default)
// Flakm mesh: 'AltFire' = 10 frames, base rate 24fps (RATE=24)
// Flakm mesh: 'Loading' = 15 frames, base rate 30fps (no RATE directive, default)
// Duration = NumFrames / (BaseRate * PlayRate)
//
// Primary cycle: Fire(0.9) + Loading(1.4 via PlayFastReloading)
// Alt cycle:     AltFire(1.3) + Loading(0.7 via PlayReloading)

simulated function float PrimaryShotInterval() {
	// Fire: 10 / (30 * 0.9) = 0.370s
	// Loading: 15 / (30 * 1.4) = 0.357s
	// Total: 0.727s
	return 10.0 / (30.0 * 0.9) + 15.0 / (30.0 * 1.4);
}

simulated function float AltShotInterval() {
	// AltFire: 10 / (24 * 1.3) = 0.321s
	// Loading: 15 / (30 * 0.7) = 0.714s
	// Total: 1.035s
	return 10.0 / (24.0 * 1.3) + 15.0 / (30.0 * 0.7);
}

simulated function float V4FireInterval(bool bAlt) {
	if (bAlt)
		return AltShotInterval();
	return PrimaryShotInterval();
}

function V4HandleOutOfAmmo() {
	local Pawn P;
	P = Pawn(Owner);
	if (P == none)
		return;
	P.StopFiring();
	if (P.PendingWeapon == none || P.PendingWeapon == self)
		P.SwitchToBestWeapon();
}

// V4 step processing — called from bbPlayer.IGPlus_V4ProcessWeaponStep.
// Returns true to suppress legacy fire, even if no shot is produced.
simulated function bool V4ProcessStep(
	float StepTS,
	rotator StepView,
	vector StepLoc,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	bool bServerSide,
	optional bool bStepReadyHint
) {
	local bool bWantsPrimary, bWantsAlt, bAlt;
	local float Interval;

	// Client-anchored: the shot lands on the step the client predicted.
	if (!bStepReadyHint)
		return true;

	bWantsPrimary = bFireHeld || bForceFire;
	bWantsAlt = bAltHeld || bForceAlt;
	if (!bWantsPrimary && !bWantsAlt)
		return true;

	if (StepTS + 0.0001 < NextV4FireTS)
		return true;

	bAlt = bWantsAlt && !bWantsPrimary;
	Interval = V4FireInterval(bAlt);

	if (AmmoType != none && AmmoType.AmmoAmount > 0) {
		if (bServerSide)
			HandleV4ServerFire(bAlt, StepView, StepLoc);
		else
			HandleV4ClientFire(bAlt, StepView, StepLoc);
	} else if (bServerSide) {
		V4HandleOutOfAmmo();
	}

	NextV4FireTS = StepTS + Interval;
	return true;
}

simulated function HandleV4ClientFire(bool bAlt, rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;
	local bbPlayer BP;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;
	BP = bbPlayer(PawnOwner);

	bPointing = true;
	if (FiringSpeed > 0)
		PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();
	if (PlayerPawn(Owner) != none)
		PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(650, 450, 190));

	if (bAlt) {
		PlayAltFiring();
		if (BP != none && BP.ClientWeaponSettingsData.bFlakUseClientSideAnimations)
			SpawnClientSideSlug();
	} else {
		PlayFiring();
		if (BP != none && BP.ClientWeaponSettingsData.bFlakUseClientSideAnimations)
			SpawnClientSideChunks();
	}
}

function HandleV4ServerFire(bool bAlt, rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	DeterministicShotRot = StepView;
	DeterministicShotLoc = StepLoc;
	if (bbPlayer(Owner) != none)
		DeterministicShotLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	bUseDeterministicData = true;

	AmmoType.UseAmmo(1);

	bPointing = true;
	PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();

	if (bAlt) {
		PlayAltFiring();
		SpawnServerSlug();
	} else {
		PlayFiring();
		SpawnServerChunks();
	}
	bUseDeterministicData = false;
}

// Server-side chunk spawning (uses deterministic V4 data when available)
function SpawnServerChunks()
{
	local Vector Start, X, Y, Z;
	local vector R;
	local Bot B;
	local ST_UTChunkInfo CI;
	local Pawn PawnOwner;
	local rotator AimRot;
	local ST_UTChunk C;

	PawnOwner = Pawn(Owner);
	B = Bot(PawnOwner);

	if (bUseDeterministicData)
	{
		AimRot = DeterministicShotRot;
		Start = DeterministicShotLoc + CalcDrawOffset();
	}
	else
	{
		Start = PawnOwner.Location + CalcDrawOffset();
		AimRot = PawnOwner.AdjustAim(AltProjectileSpeed, Start, AimError, True, bWarnTarget);
	}

	PawnOwner.MakeNoise(2.0 * PawnOwner.SoundDampening);
	GetAxes(AimRot, X, Y, Z);
	Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));
	Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	
	CI = Spawn(class'ST_UTChunkInfo', PawnOwner);
	CI.WImp = WImp;

	if (GetWeaponSettings().FlakChunkRandomSpread) {
		C = Spawn(class'ST_UTChunk1', Owner, '', Start, AimRot);
		C.ChunkIndex = 0;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk2', Owner, '', Start - Z, AimRot);
		C.ChunkIndex = 1;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk3', Owner, '', Start + 2 * Y + Z, AimRot);
		C.ChunkIndex = 2;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk4', Owner, '', Start - Y, AimRot);
		C.ChunkIndex = 3;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk1', Owner, '', Start + 2 * Y - Z, AimRot);
		C.ChunkIndex = 4;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk2', Owner, '', Start, AimRot);
		C.ChunkIndex = 5;
		CI.AddChunk(C);

		// lower skill bots fire less flak chunks
		if ( (B == None) || !B.bNovice || ((B.Enemy != None) && (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon) )
		{
			C = Spawn(class'ST_UTChunk3', Owner, '', Start + Y - Z, AimRot);
			C.ChunkIndex = 6;
			CI.AddChunk(C);

			C = Spawn(class'ST_UTChunk4', Owner, '', Start + 2 * Y + Z, AimRot);
			C.ChunkIndex = 7;
			CI.AddChunk(C);
		}
		else if ( B.Skill > 1 )
		{
			C = Spawn(class'ST_UTChunk3', Owner, '', Start + Y - Z, AimRot);
			C.ChunkIndex = 6;
			CI.AddChunk(C);
		}
	} else {
		R = X / Tan(3.0*Pi/180.0);

		C = Spawn(class'ST_UTChunk1', Owner, '', Start, rotator(R));
		C.ChunkIndex = 0;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk2', Owner, '', Start + Y*Cos(0.0) + Z*Sin(0.0), rotator(R + Y*Cos(0.0) + Z*Sin(0.0)));
		C.ChunkIndex = 1;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk3', Owner, '', Start + Y*Cos(Pi/3.0) + Z*Sin(Pi/3.0), rotator(R + Y*Cos(Pi/3.0) + Z*Sin(Pi/3.0)));
		C.ChunkIndex = 2;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk4', Owner, '', Start + Y*Cos(2.0*Pi/3.0) + Z*Sin(2.0*Pi/3.0), rotator(R + Y*Cos(2.0*Pi/3.0) + Z*Sin(2.0*Pi/3.0)));
		C.ChunkIndex = 3;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk1', Owner, '', Start + Y*Cos(Pi) + Z*Sin(Pi), rotator(R + Y*Cos(Pi) + Z*Sin(Pi)));
		C.ChunkIndex = 4;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk2', Owner, '', Start + Y*Cos(4.0*Pi/3.0) + Z*Sin(4.0*Pi/3.0), rotator(R + Y*Cos(4.0*Pi/3.0) + Z*Sin(4.0*Pi/3.0)));
		C.ChunkIndex = 5;
		CI.AddChunk(C);

		C = Spawn(class'ST_UTChunk3', Owner, '', Start + Y*Cos(5.0*Pi/3.0) + Z*Sin(5.0*Pi/3.0), rotator(R + Y*Cos(5.0*Pi/3.0) + Z*Sin(5.0*Pi/3.0)));
		C.ChunkIndex = 6;
		CI.AddChunk(C);
	}
}

// Server-side slug spawning (uses deterministic V4 data when available)
function SpawnServerSlug()
{
	local Vector Start, X, Y, Z;
	local ST_FlakSlug Slug;
	local Pawn PawnOwner;
	local bbPlayer bbP;
	local rotator AimRot;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	if (bUseDeterministicData)
	{
		AimRot = DeterministicShotRot;
		GetAxes(AimRot, X, Y, Z);
		Start = DeterministicShotLoc + CalcDrawOffset();
	}
	else
	{
		GetAxes(PawnOwner.ViewRotation, X, Y, Z);
		Start = PawnOwner.Location + CalcDrawOffset();
		AimRot = PawnOwner.AdjustToss(AltProjectileSpeed, Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z, AimError, True, bAltWarnTarget);
	}

	PawnOwner.MakeNoise(PawnOwner.SoundDampening);
	Spawn(class'WeaponLight',,'',Start+X*20,rot(0,0,0));
	Start = Start + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	
	Slug = Spawn(class'ST_FlakSlug', Owner,, Start, AimRot);
	Slug.WImp = WImp;

	// Apply ping compensation for flak slug if enabled
	if (bbP != None && IsPingCompEnabled()) {
		WImp.SimulateProjectile(Slug, bbP.PingAverage);
	}
}

function Finish()
{
	if (IsV4Active() && PlayerPawn(Owner) != None)
	{
		if (bChangeWeapon)
			GotoState('DownWeapon');
		else if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
		{
			V4HandleOutOfAmmo();
			if (bChangeWeapon)
				GotoState('DownWeapon');
			else
				GotoState('Idle');
		}
		else
			GotoState('Idle');
		return;
	}
	Super.Finish();
}

function Fire( float Value )
{
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	if ( AmmoType == None )
		GiveAmmo(PawnOwner);

	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing = True;
		PawnOwner.PlayRecoil(FiringSpeed);
		PlayFiring();
		SpawnServerChunks();
		ClientFire(Value);
		GoToState('NormalFire');
	}
}

function AltFire(float Value)
{
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	if (IsV4Active() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;

	if (AmmoType == None)
		GiveAmmo(PawnOwner);

	if (AmmoType.UseAmmo(1))
	{
		bCanClientFire = true;
		bPointing = True;
		PawnOwner.PlayRecoil(FiringSpeed);
		PlayAltFiring();
		SpawnServerSlug();
		ClientAltFire(Value);
		GoToState('AltFiring');
	}
}

simulated function bool ClientFire(float Value)
{
	local Pawn PawnOwner;
	local TournamentPlayer TP;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	TP = TournamentPlayer(PawnOwner);
	if (bChangeWeapon
		|| (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		|| (TP != none && TP.ClientPending != none && TP.ClientPending != self))
		return false;

	if (IsV4Active())
		return true;

	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire(float Value)
{
	local Pawn PawnOwner;
	local TournamentPlayer TP;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	TP = TournamentPlayer(PawnOwner);
	if (bChangeWeapon
		|| (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != self)
		|| (TP != none && TP.ClientPending != none && TP.ClientPending != self))
		return false;

	if (IsV4Active())
		return true;

	return Super.ClientAltFire(Value);
}

state ClientActive
{
    simulated function AnimEnd()
    {
        bCanClientFire = true;
        Super.AnimEnd();
    }

    simulated function BeginState()
    {
        bCanClientFire = false;
        Super.BeginState();
    }
}

state ClientFiring {

	simulated function AnimEnd()
	{
		if (IsV4Active()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}

		if ( (Pawn(Owner) == None) || (AmmoType != None && AmmoType.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else
		{
			// Play reload sequence like base game (Eject + Loading)
			PlayFastReloading();
			GotoState('ClientReload');
		}
	}
}

state ClientAltFiring {

	simulated function AnimEnd()
	{
		if (IsV4Active()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}

		if ( (Pawn(Owner) == None) || (AmmoType != None && AmmoType.AmmoAmount <= 0) )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else
		{
			// Play reload sequence like base game (Loading)
			PlayReloading();
			GotoState('ClientReload');
		}
	}
}

simulated function SpawnClientChunk(class<ST_UTChunk> ChunkClass, vector Pos, rotator Rot, int Index) {
	local ST_UTChunk C;
	C = Spawn(ChunkClass, Owner, '', Pos, Rot);
	if (C == None)
		return;
	C.RemoteRole = ROLE_None;
	C.bClientVisualOnly = true;
	C.ChunkIndex = Index;
	C.bCollideWorld = true;
	C.SetCollision(false, false, false);
}

simulated function SpawnClientSideChunks() {
	local Pawn PawnOwner;
	local vector X, Y, Z, R, Start;
	local float Hand;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	if (Role >= ROLE_Authority || bbP == None || !bbP.ClientWeaponSettingsData.bFlakUseClientSideAnimations)
		return;

	if (Owner.IsA('PlayerPawn'))
		Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
	else
		Hand = 1.0;

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	if (bHideWeapon)
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
	else
		Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	if (bbP != None)
		Start.Z += bbP.GetMoverFireZOffset();

	if (GetWeaponSettings().FlakChunkRandomSpread) {
		SpawnClientChunk(class'ST_UTChunk1', Start,            PawnOwner.ViewRotation, 0);
		SpawnClientChunk(class'ST_UTChunk2', Start - Z,        PawnOwner.ViewRotation, 1);
		SpawnClientChunk(class'ST_UTChunk3', Start + 2*Y + Z,  PawnOwner.ViewRotation, 2);
		SpawnClientChunk(class'ST_UTChunk4', Start - Y,         PawnOwner.ViewRotation, 3);
		SpawnClientChunk(class'ST_UTChunk1', Start + 2*Y - Z,  PawnOwner.ViewRotation, 4);
		SpawnClientChunk(class'ST_UTChunk2', Start,            PawnOwner.ViewRotation, 5);
		SpawnClientChunk(class'ST_UTChunk3', Start + Y - Z,    PawnOwner.ViewRotation, 6);
		SpawnClientChunk(class'ST_UTChunk4', Start + 2*Y + Z,  PawnOwner.ViewRotation, 7);
	} else {
		R = X / Tan(3.0*Pi/180.0);
		SpawnClientChunk(class'ST_UTChunk1', Start,                                          rotator(R),                                          0);
		SpawnClientChunk(class'ST_UTChunk2', Start + Y*Cos(0.0) + Z*Sin(0.0),               rotator(R + Y*Cos(0.0) + Z*Sin(0.0)),               1);
		SpawnClientChunk(class'ST_UTChunk3', Start + Y*Cos(Pi/3.0) + Z*Sin(Pi/3.0),         rotator(R + Y*Cos(Pi/3.0) + Z*Sin(Pi/3.0)),         2);
		SpawnClientChunk(class'ST_UTChunk4', Start + Y*Cos(2.0*Pi/3.0) + Z*Sin(2.0*Pi/3.0), rotator(R + Y*Cos(2.0*Pi/3.0) + Z*Sin(2.0*Pi/3.0)), 3);
		SpawnClientChunk(class'ST_UTChunk1', Start + Y*Cos(Pi) + Z*Sin(Pi),                 rotator(R + Y*Cos(Pi) + Z*Sin(Pi)),                 4);
		SpawnClientChunk(class'ST_UTChunk2', Start + Y*Cos(4.0*Pi/3.0) + Z*Sin(4.0*Pi/3.0), rotator(R + Y*Cos(4.0*Pi/3.0) + Z*Sin(4.0*Pi/3.0)), 5);
		SpawnClientChunk(class'ST_UTChunk3', Start + Y*Cos(5.0*Pi/3.0) + Z*Sin(5.0*Pi/3.0), rotator(R + Y*Cos(5.0*Pi/3.0) + Z*Sin(5.0*Pi/3.0)), 6);
	}
}

function SetSwitchPriority(pawn Other)
{	// Make sure "old" priorities are kept.
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( IsA(PlayerPawn(Other).WeaponPriority[i]) )		// <- The fix...
			{
				AutoSwitchPriority = i;
				return;
			}
		// else, register this weapon
		carried = 'UT_FlakCannon';
		for ( i=AutoSwitchPriority; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++ )
		{
			if ( PlayerPawn(Other).WeaponPriority[i] == '' )
			{
				PlayerPawn(Other).WeaponPriority[i] = carried;
				return;
			}
			else if ( i<ArrayCount(PlayerPawn(Other).WeaponPriority)-1 )
			{
				temp = PlayerPawn(Other).WeaponPriority[i];
				PlayerPawn(Other).WeaponPriority[i] = carried;
				carried = temp;
			}
		}
	}		
}

// Compatibility between client and server logic
simulated function vector CalcDrawOffsetClient() {
	local vector DrawOffset;
	local Pawn PawnOwner;
	local vector WeaponBob;
	
	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return vect(0,0,0);

	DrawOffset = CalcDrawOffset();
	
	// On client, make adjustments to match server
	if (Level.NetMode == NM_Client) {
		// Correct for EyeHeight differences
		DrawOffset -= (PawnOwner.EyeHeight * vect(0,0,1));
		DrawOffset += (PawnOwner.BaseEyeHeight * vect(0,0,1));
	
		// Remove WeaponBob, not applied on server
		WeaponBob = BobDamping * PawnOwner.WalkBob;
		WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
		DrawOffset -= WeaponBob;
	}
	
	return DrawOffset;
}

simulated function SpawnClientSideSlug()
{
    local Pawn PawnOwner;
    local vector X, Y, Z;
    local vector Start;
    local float Hand;
    local bbPlayer bbP;

    PawnOwner = Pawn(Owner);
    bbP = bbPlayer(PawnOwner);

    if (Role < ROLE_Authority && bbP != None && bbP.ClientWeaponSettingsData.bFlakUseClientSideAnimations)
    {
        if (Owner.IsA('PlayerPawn'))
            Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
        else
            Hand = 1.0;

        GetAxes(PawnOwner.ViewRotation,X,Y,Z);
        if (bHideWeapon)
            Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
        else
            Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
        if (bbP != None)
            Start.Z += bbP.GetMoverFireZOffset();

        LocalSlugDummy = Spawn(class'ST_FlakSlug', Owner,, Start, PawnOwner.ViewRotation);
        LocalSlugDummy.RemoteRole = ROLE_None;
        LocalSlugDummy.Instigator = PawnOwner;
        //LocalSlugDummy.bMeshEnviroMap = true;
        //LocalSlugDummy.Texture = Texture'UWindow.Icons.MenuHighlight';
        LocalSlugDummy.bClientVisualOnly = true;
        LocalSlugDummy.bCollideWorld = false;
        LocalSlugDummy.SetCollision(false, false, false);
        LocalSlugDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
    }
}

simulated function PlayFiring()
{
	PlayAnim('Fire', 0.9, 0.05);
	PlayOwnedSound(FireSound, SLOT_Misc, Pawn(Owner).SoundDampening*4.0);
}

simulated function PlayAltFiring()
{
	PlayAnim('AltFire', 1.3, 0.05);
	Owner.PlaySound(Misc1Sound, SLOT_None, 0.6*Pawn(Owner).SoundDampening);
	PlayOwnedSound(AltFireSound, SLOT_Misc, Pawn(Owner).SoundDampening*4.0);
}

// Idle state - prevents server from auto-firing when client is in control
state Idle
{
	function BeginState()
	{

		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
		{
			GotoState('DownWeapon');
			return;
		}

		if (IsV4Active() && PlayerPawn(Owner) != None)
		{
			bPointing = false;

			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
				Pawn(Owner).SwitchToBestWeapon();

			Disable('AnimEnd');
			PlayIdleAnim();
		}
		else
		{
			bPointing = False;
			if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) ) 
				Pawn(Owner).SwitchToBestWeapon();
			if ( Pawn(Owner).bFire != 0 ) Fire(0.0);
			if ( Pawn(Owner).bAltFire != 0 ) AltFire(0.0);	
			Disable('AnimEnd');
			PlayIdleAnim();
		}
	}

	function AnimEnd()
	{
		if (IsV4Active() && PlayerPawn(Owner) != None)
			PlayIdleAnim();
		else
			Super.AnimEnd();
	}

	function bool PutDown()
    {
        GotoState('DownWeapon');
        return True;
    }
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().FlakDownTime );
	else if ( AmmoType.AmmoAmount < 1 )
		TweenAnim('Select', GetWeaponSettings().FlakDownTime + TweenTime);
	else
		PlayAnim('Down',GetWeaponSettings().FlakDownAnimSpeed(), TweenTime);
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().FlakSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function PlayPostSelect() {
	PlayAnim('Loading', GetWeaponSettings().FlakPostSelectAnimSpeed(), 0.05);
	Owner.PlayOwnedSound(Misc2Sound, SLOT_None,1.3*Pawn(Owner).SoundDampening);
}

defaultproperties {
	ChunkClasses(0)=class'ST_UTChunk1'
	ChunkClasses(1)=class'ST_UTChunk2'
	ChunkClasses(2)=class'ST_UTChunk3'
	ChunkClasses(3)=class'ST_UTChunk4'
}
