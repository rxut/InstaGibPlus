// ===============================================================
// UTPureStats7A.ST_ripper: put your comment here
//
// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_ripper extends ripper;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var ST_Razor2 LocalRazor2Dummy;
var ST_Razor2Alt LocalRazor2AltDummy;

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
	return WS != None && WS.RipperCompensatePing;
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

	if (IsPingCompEnabled() && Mover(Owner.Base) != None)
		return true;

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

	if (!IsPingCompEnabled())
		return;
	
	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) &&
         (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self) || P.Weapon != self) )
	{
		AmmoType.UseAmmo(1);

		// Position validation - use server position if client position is unreasonable
		if (bbPlayer(Owner) != None)
			ClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
		if (IsPositionReasonable(ClientLoc))
			ExplicitClientLoc = ClientLoc;
		else
			ExplicitClientLoc = Owner.Location;
		
		ExplicitClientRot = ClientRot;
		bUseExplicitData = true;

		P.PlayRecoil(FiringSpeed);
		PlayOwnedSound(class'Razor2'.Default.SpawnSound, SLOT_None, Pawn(Owner).SoundDampening * 4.2);
		if (Affector != None)
			Affector.FireEffect();
		SpawnServerRazor();
		
		bUseExplicitData = false;
		bChangeWeapon = true;
		GotoState('DownWeapon');
		return;
	}

	if (bChangeWeapon || IsInState('DownWeapon'))
 		return;

	// Position validation - use server position if client position is unreasonable
	if (bbPlayer(Owner) != None)
		ClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
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
		SpawnServerRazor();
		GoToState('NormalFire');
	}

	bUseExplicitData = false;
}

// Server function called by client when alt firing
function ServerExplicitAltFire(vector ClientLoc, rotator ClientRot, optional bool bIsSwitching)
{
	local PlayerPawn P;
	
	P = PlayerPawn(Owner);
	if (P == None)
		return;

	if (!IsPingCompEnabled())
		return;
	
	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) &&
         (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self) || P.Weapon != self) )
	{
		AmmoType.UseAmmo(1);

		// Position validation - use server position if client position is unreasonable
		if (bbPlayer(Owner) != None)
			ClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
		if (IsPositionReasonable(ClientLoc))
			ExplicitClientLoc = ClientLoc;
		else
			ExplicitClientLoc = Owner.Location;
		
		ExplicitClientRot = ClientRot;
		bUseExplicitData = true;

		P.PlayRecoil(FiringSpeed);
		PlayOwnedSound(class'Razor2Alt'.Default.SpawnSound, SLOT_None, Pawn(Owner).SoundDampening * 4.2);
		if (Affector != None)
			Affector.FireEffect();
		SpawnServerRazorAlt();
		
		bUseExplicitData = false;
		bChangeWeapon = true;
		GotoState('DownWeapon');
		return;
	}

	if (bChangeWeapon || IsInState('DownWeapon'))
 		return;

	// Position validation - use server position if client position is unreasonable
	if (bbPlayer(Owner) != None)
		ClientLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
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
		SpawnServerRazorAlt();
		GoToState('AltFiring');
	}

	bUseExplicitData = false;
}

// Server-side razor spawning (uses explicit client data when available)
function SpawnServerRazor()
{
	local Vector Start, X, Y, Z;
	local Pawn PawnOwner;
	local rotator AimRot;
	local ST_Razor2 Razor;
	local bbPlayer bbP;
	local float Hand;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	// Use explicit client data if available
	if (bUseExplicitData)
	{
		AimRot = ExplicitClientRot;
		if (Owner.IsA('PlayerPawn'))
			Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
		else
			Hand = 1.0;

		GetAxes(AimRot, X, Y, Z);
		if (bHideWeapon)
			Start = ExplicitClientLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z;
		else
			Start = ExplicitClientLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	}
	else
	{
		AimRot = PawnOwner.AdjustAim(ProjectileSpeed, Owner.Location, AimError, True, bWarnTarget);
		if (Owner.IsA('PlayerPawn'))
			Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
		else
			Hand = 1.0;

		GetAxes(PawnOwner.ViewRotation, X, Y, Z);
		if (bHideWeapon)
			Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z;
		else
			Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	}

	PawnOwner.MakeNoise(PawnOwner.SoundDampening);

	Razor = Spawn(class'ST_Razor2', Owner,, Start, AimRot);

	// Apply ping compensation if enabled
	if (bbP != None && IsPingCompEnabled()) {
		WImp.SimulateProjectile(Razor, bbP.PingAverage);
	}
}

// Server-side razor alt spawning (uses explicit client data when available)
function SpawnServerRazorAlt()
{
	local Vector Start, X, Y, Z;
	local Pawn PawnOwner;
	local rotator AimRot;
	local ST_Razor2Alt RazorAlt;
	local bbPlayer bbP;
	local float Hand;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	// Use explicit client data if available
	if (bUseExplicitData)
	{
		AimRot = ExplicitClientRot;
		if (Owner.IsA('PlayerPawn'))
			Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
		else
			Hand = 1.0;

		GetAxes(AimRot, X, Y, Z);
		if (bHideWeapon)
			Start = ExplicitClientLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z;
		else
			Start = ExplicitClientLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	}
	else
	{
		AimRot = PawnOwner.AdjustAim(AltProjectileSpeed, Owner.Location, AimError, True, bAltWarnTarget);
		if (Owner.IsA('PlayerPawn'))
			Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
		else
			Hand = 1.0;

		GetAxes(PawnOwner.ViewRotation, X, Y, Z);
		if (bHideWeapon)
			Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Z * Z;
		else
			Start = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
	}

	PawnOwner.MakeNoise(PawnOwner.SoundDampening);

	RazorAlt = Spawn(class'ST_Razor2Alt', Owner,, Start, AimRot);

	// Apply ping compensation if enabled
	if (bbP != None && IsPingCompEnabled()) {
		WImp.SimulateProjectile(RazorAlt, bbP.PingAverage);
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

function Fire(float Value)
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
		PlayFiring();
		SpawnServerRazor();
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
		SpawnServerRazorAlt();
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

				PawnOwner.PlayRecoil(FiringSpeed);
				PlayFiring();

				if (Affector != None)
					Affector.FireEffect();

				if (PlayerPawn(Owner) != None)
					PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(450, 190, 650));

				// Spawn client-side visuals if setting enabled
				if (bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
				{
					SpawnClientSideRazor();
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

				PawnOwner.PlayRecoil(FiringSpeed);
				PlayAltFiring();

				if (Affector != None)
					Affector.FireEffect();

				if (PlayerPawn(Owner) != None)
					PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(450, 190, 650));

				// Spawn client-side visuals if setting enabled
				if (bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
				{
					SpawnClientSideRazorAlt();
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
}

simulated function SpawnClientSideRazor()
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	if (Role < ROLE_Authority && bbP != None && bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
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

		LocalRazor2Dummy = Spawn(class'ST_Razor2', Owner,, Start, PawnOwner.ViewRotation);
		LocalRazor2Dummy.RemoteRole = ROLE_None;
		LocalRazor2Dummy.bClientVisualOnly = true;
		LocalRazor2Dummy.SetCollision(false, false, false);
		LocalRazor2Dummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	}
}

simulated function SpawnClientSideRazorAlt()
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	if (Role < ROLE_Authority && bbP != None && bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations)
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

		LocalRazor2AltDummy = Spawn(class'ST_Razor2Alt', Owner,, Start, PawnOwner.ViewRotation);
		LocalRazor2AltDummy.RemoteRole = ROLE_None;
		LocalRazor2AltDummy.bClientVisualOnly = true;
		LocalRazor2AltDummy.SetCollision(false, false, false);
		LocalRazor2AltDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	}
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
		carried = 'ripper';
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

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().RipperSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().RipperDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().RipperDownAnimSpeed(), TweenTime);
}

defaultproperties {
	ProjectileClass=Class'ST_Razor2'
	AltProjectileClass=Class'ST_Razor2Alt'
}
