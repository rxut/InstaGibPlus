// ===============================================================
// Stats.ST_UT_FlakCannon: put your comment here
//
// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_UT_FlakCannon extends UT_FlakCannon;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var class<ST_UTChunk> ChunkClasses[4];

var ST_FlakSlug LocalSlugDummy;
var ST_UTChunk LocalChunkDummy;

// Explicit client aim data (sent via ServerExplicitFire/AltFire)
var vector ExplicitClientLoc;
var rotator ExplicitClientRot;
var bool bUseExplicitData;

// Server-side position validation
const MAX_POSITION_ERROR_SQ = 1250.0;

replication
{
	reliable if(Role < ROLE_Authority)
		ServerExplicitFire, ServerExplicitAltFire;
}

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


function bool IsPositionReasonable(vector ClientLoc)
{
	local vector Diff;
	
	Diff = ClientLoc - Owner.Location;
	return (Diff dot Diff) < MAX_POSITION_ERROR_SQ;
}

// Server function called by client when firing
function ServerExplicitFire(vector ClientLoc, rotator ClientRot, optional bool bIsSwitching)
{
	local PlayerPawn P;
	
	P = PlayerPawn(Owner);
	if (P == None)
		return;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) && (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self) || P.Weapon != self) )
	{
		AmmoType.UseAmmo(1);

		// Position validation - use server position if client position is unreasonable
		if (IsPositionReasonable(ClientLoc))
			ExplicitClientLoc = ClientLoc;
		else
			ExplicitClientLoc = Owner.Location;
		
		ExplicitClientRot = ClientRot;
		bUseExplicitData = true;

		P.PlayRecoil(FiringSpeed);
		PlayOwnedSound(FireSound, SLOT_Misc, Pawn(Owner).SoundDampening * 4.0);
		if (Affector != None)
			Affector.FireEffect();
		SpawnServerChunks();
		
		bUseExplicitData = false;

		bChangeWeapon = true;
		GotoState('DownWeapon'); // Manually trigger the transition
		return;
	}

	if (bChangeWeapon || IsInState('DownWeapon'))
		return;

	// Position validation - use server position if client position is unreasonable
	if (IsPositionReasonable(ClientLoc))
		ExplicitClientLoc = ClientLoc;
	else
		ExplicitClientLoc = Owner.Location;
	
	ExplicitClientRot = ClientRot;
	bUseExplicitData = true;

	if (AmmoType == None)
		GiveAmmo(P);

	if (AmmoType != None && AmmoType.AmmoAmount > 0)
	{
		AmmoType.UseAmmo(1);
		
		bCanClientFire = true;
		bPointing = True;
		
		P.PlayRecoil(FiringSpeed);
		PlayFiring();
		if (Affector != None)
			Affector.FireEffect();
		SpawnServerChunks();
		GoToState('NormalFire');
	}

	bUseExplicitData = false;
}

function ServerExplicitAltFire(vector ClientLoc, rotator ClientRot, optional bool bIsSwitching)
{
	local PlayerPawn P;
	
	P = PlayerPawn(Owner);
	if (P == None)
		return;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) && (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self) || P.Weapon != self) )
	{
		AmmoType.UseAmmo(1);

		// Position validation - use server position if client position is unreasonable
		if (IsPositionReasonable(ClientLoc))
			ExplicitClientLoc = ClientLoc;
		else
			ExplicitClientLoc = Owner.Location;
		
		ExplicitClientRot = ClientRot;
		bUseExplicitData = true;

		P.PlayRecoil(FiringSpeed);
		Owner.PlaySound(Misc1Sound, SLOT_None, 0.6 * Pawn(Owner).SoundDampening);
		PlayOwnedSound(AltFireSound, SLOT_Misc, Pawn(Owner).SoundDampening * 4.0);
		if (Affector != None)
			Affector.FireEffect();
		SpawnServerSlug();
		
		bUseExplicitData = false;
		bChangeWeapon = true;
		GotoState('DownWeapon'); // Manually trigger the transition
		return;
	}
	
	if (bChangeWeapon || IsInState('DownWeapon'))
		return;
	
	// Position validation - use server position if client position is unreasonable
	if (IsPositionReasonable(ClientLoc))
		ExplicitClientLoc = ClientLoc;
	else
		ExplicitClientLoc = Owner.Location;

	ExplicitClientRot = ClientRot;
	bUseExplicitData = true;

	if (AmmoType == None)
		GiveAmmo(P);

	if (AmmoType != None && AmmoType.AmmoAmount > 0)
	{
		AmmoType.UseAmmo(1);
		
		bCanClientFire = true;
		bPointing = True;
		
		P.PlayRecoil(FiringSpeed);
		PlayAltFiring();
		if (Affector != None)
			Affector.FireEffect();
		SpawnServerSlug();
		GoToState('AltFiring');
	}

	bUseExplicitData = false;
}

// Server-side chunk spawning (uses explicit client data when available)
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

	// Use explicit client data if available
	if (bUseExplicitData)
	{
		AimRot = ExplicitClientRot;
		Start = ExplicitClientLoc + CalcDrawOffset();
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

// Server-side slug spawning (uses explicit client data when available)
function SpawnServerSlug()
{
	local Vector Start, X, Y, Z;
	local ST_FlakSlug Slug;
	local Pawn PawnOwner;
	local bbPlayer bbP;
	local rotator AimRot;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	// Use explicit client data if available
	if (bUseExplicitData)
	{
		AimRot = ExplicitClientRot;
		GetAxes(AimRot, X, Y, Z);
		Start = ExplicitClientLoc + CalcDrawOffset();
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
	if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
	{
		if (bChangeWeapon)
			GotoState('DownWeapon');
		else if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
		{
			Pawn(Owner).StopFiring();
			Pawn(Owner).SwitchToBestWeapon();
			if (bChangeWeapon)
				GotoState('DownWeapon');
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

	if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
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

	if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
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
	local bbPlayer bbP;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	
	if (PawnOwner == None) 
		return false;

	// if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
	//	return false;

	if (IsPingCompEnabled())
	{
		bbP = bbPlayer(PawnOwner);

		if (Owner.Role == ROLE_AutonomousProxy && bbP != None)
		{
			if (AmmoType == None && AmmoName != None)
				GiveAmmo(PawnOwner);
			
			if (AmmoType != None && AmmoType.AmmoAmount > 0)
			{
				Instigator = PawnOwner;
				
				if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
				{
					ServerExplicitFire(PawnOwner.Location, PawnOwner.ViewRotation, true);
					return true;
				}

				GotoState('ClientFiring');
				bPointing = True;

				// Always play weapon animations
				PawnOwner.PlayRecoil(FiringSpeed);
				PlayFiring();

				if (Affector != None)
					Affector.FireEffect();

				if (PlayerPawn(Owner) != None)
					PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(650, 450, 190));

				// Spawn client-side visuals if setting enabled
				if (bbP.ClientWeaponSettingsData.bFlakUseClientSideAnimations)
				{
					SpawnClientSideChunks();
				}

				// Send explicit fire data to server
				ServerExplicitFire(PawnOwner.Location, PawnOwner.ViewRotation);

				return true;
			}
			return false;
		}
	}
	
	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire(float Value)
{
	local Pawn PawnOwner;
	local bbPlayer bbP;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	
	if (PawnOwner == None)
		return false;

	// if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
	//	return false;

	if (IsPingCompEnabled())
	{
		bbP = bbPlayer(PawnOwner);

		if (Owner.Role == ROLE_AutonomousProxy && bbP != None)
		{
			if (AmmoType == None && AmmoName != None)
				GiveAmmo(PawnOwner);
			
			if (AmmoType != None && AmmoType.AmmoAmount > 0)
			{
				Instigator = PawnOwner;
				
				if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
				{
					ServerExplicitAltFire(PawnOwner.Location, PawnOwner.ViewRotation, true);
					return true;
				}

				GotoState('ClientAltFiring');
				bPointing = True;

				// Always play weapon animations
				PawnOwner.PlayRecoil(FiringSpeed);
				PlayAltFiring();

				if (Affector != None)
					Affector.FireEffect();

				if (PlayerPawn(Owner) != None)
					PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(650, 450, 190));

				// Spawn client-side visuals if setting enabled
				if (bbP.ClientWeaponSettingsData.bFlakUseClientSideAnimations)
				{
					SpawnClientSideSlug();
				}

				// Send explicit fire data to server
				ServerExplicitAltFire(PawnOwner.Location, PawnOwner.ViewRotation);

				return true;
			}
			return false;
		}
	}
	
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

simulated function SpawnClientSideChunks()
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector R;
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

		if (GetWeaponSettings().FlakChunkRandomSpread) {
			LocalChunkDummy = Spawn(class'ST_UTChunk1', Owner, '', Start, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 0;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk2', Owner, '', Start - Z, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 1;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk3', Owner, '', Start + 2 * Y + Z, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 2;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk4', Owner, '', Start - Y, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 3;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk1', Owner, '', Start + 2 * Y - Z, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 4;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk2', Owner, '', Start, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 5;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk3', Owner, '', Start + Y - Z, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 6;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk4', Owner, '', Start + 2 * Y + Z, PawnOwner.ViewRotation);
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 7;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);
		}
		else {
			R = X / Tan(3.0*Pi/180.0);
		
			LocalChunkDummy = Spawn(class'ST_UTChunk1', Owner, '', Start, rotator(R));
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 0;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk2', Owner, '', Start + Y*Cos(0.0) + Z*Sin(0.0), rotator(R + Y*Cos(0.0) + Z*Sin(0.0)));
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 1;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk3', Owner, '', Start + Y*Cos(Pi/3.0) + Z*Sin(Pi/3.0), rotator(R + Y*Cos(Pi/3.0) + Z*Sin(Pi/3.0)));
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 2;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk4', Owner, '', Start + Y*Cos(2.0*Pi/3.0) + Z*Sin(2.0*Pi/3.0), rotator(R + Y*Cos(2.0*Pi/3.0) + Z*Sin(2.0*Pi/3.0)));
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 3;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk1', Owner, '', Start + Y*Cos(Pi) + Z*Sin(Pi), rotator(R + Y*Cos(Pi) + Z*Sin(Pi)));
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 4;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk2', Owner, '', Start + Y*Cos(4.0*Pi/3.0) + Z*Sin(4.0*Pi/3.0), rotator(R + Y*Cos(4.0*Pi/3.0) + Z*Sin(4.0*Pi/3.0)));
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 5;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);

			LocalChunkDummy = Spawn(class'ST_UTChunk3', Owner, '', Start + Y*Cos(5.0*Pi/3.0) + Z*Sin(5.0*Pi/3.0), rotator(R + Y*Cos(5.0*Pi/3.0) + Z*Sin(5.0*Pi/3.0)));
			LocalChunkDummy.RemoteRole = ROLE_None;
			LocalChunkDummy.bClientVisualOnly = true;
			LocalChunkDummy.ChunkIndex = 6;
			LocalChunkDummy.bCollideWorld = true;
			LocalChunkDummy.SetCollision(false, false, false);
		}
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

        LocalSlugDummy = Spawn(class'ST_FlakSlug', Owner,, Start, PawnOwner.ViewRotation);
        LocalSlugDummy.RemoteRole = ROLE_None;
        LocalSlugDummy.Instigator = PawnOwner;
        //LocalSlugDummy.bMeshEnviroMap = true;
        //LocalSlugDummy.Texture = Texture'UWindow.Icons.MenuHighlight';
        LocalSlugDummy.bClientVisualOnly = true;
        LocalSlugDummy.bCollideWorld = false;
        LocalSlugDummy.SetCollision(false, false, false);
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

		if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
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
		if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
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
