// ===============================================================
// UTPureStats7A.ST_ripper: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_ripper extends ripper;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var Rotator GV;
var Vector CDO;
var float yMod;

var int Razor2Counter;
var int Razor2AltCounter;

var bool bClientAllowedToFire;	
var bool bClientAllowedToAltFire;
var int LastFiredRazor2ID;
var int LastFiredRazor2AltID;

replication
{
    reliable if (Role == ROLE_Authority)
        Razor2Counter, Razor2AltCounter, bClientAllowedToFire, bClientAllowedToAltFire;
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

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;		// Find master :D

	Razor2Counter = 0;
	Razor2AltCounter = 0;
}

simulated function yModInit()
{
	if (bbPlayer(Owner) != None && Owner.Role == ROLE_AutonomousProxy)
		GV = bbPlayer(Owner).ViewRotation;
	
	if (PlayerPawn(Owner) == None)
		return;
		
	yMod = PlayerPawn(Owner).Handedness;
	if (yMod != 2.0)
		yMod *= Default.FireOffset.Y;
	else
		yMod = 0;

	CDO = CalcDrawOffsetClient();
}

simulated function bool ClientFire(float Value)
{
	local Vector Start, X,Y,Z;
	local ST_Razor2 ClientRazor2;
	local bbPlayer bbP;
	
	if (Owner.IsA('Bot'))
		return Super.ClientFire(Value);
	
	bbP = bbPlayer(Owner);

	if (bbP != None && GetWeaponSettings().RipperCompensatePing)
	{
		if (Role < ROLE_Authority &&
			bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations &&
			Mover(bbP.Base) == None &&
			bClientAllowedToFire &&
			Razor2Counter != LastFiredRazor2ID)
		{
			if (bbP.ClientCannotShoot() || bbP.Weapon != Self)
				return false;
			
			yModInit();

			if ( (AmmoType == None) && (AmmoName != None) )
			{
				GiveAmmo(Pawn(Owner));
			}
			if ( AmmoType.AmmoAmount > 0 )
			{

				Instigator = Pawn(Owner);
				GotoState('ClientFiring');
				bPointing=True;
				bCanClientFire = true;
				
				GetAxes(GV,X,Y,Z);
				Start = Owner.Location + CDO + FireOffset.X * X + yMod * Y + FireOffset.Z * Z; 
				AdjustedAim = Pawn(owner).AdjustAim(ProjectileSpeed, Start, AimError, True, bWarnTarget);	
				
				ClientRazor2 = Spawn(Class'ST_Razor2', Owner,, Start, AdjustedAim);
				ClientRazor2.RemoteRole = ROLE_None;
				ClientRazor2.bClientVisualOnly = true;
				ClientRazor2.LifeSpan = bbPlayer(Owner).PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
				ClientRazor2.bCollideWorld = false;

				ClientRazor2.Razor2ID = Razor2Counter;
				LastFiredRazor2ID = Razor2Counter;
			}
		}
	}
	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire(float Value)
{
	local Vector Start, X,Y,Z;
	local ST_Razor2Alt ClientRazor2Alt;
	local bbPlayer bbP;

	if (Owner.IsA('Bot'))
		return Super.ClientAltFire(Value);
	
	bbP = bbPlayer(Owner);

	if (bbP != None && GetWeaponSettings().RipperCompensatePing)
	{
		if (Role < ROLE_Authority &&
			bbP.ClientWeaponSettingsData.bRipperUseClientSideAnimations &&
			Mover(bbP.Base) == None && // Lifts cause client projectiles to have a different origin
			bClientAllowedToAltFire &&
			Razor2AltCounter != LastFiredRazor2AltID)
		{
			if (bbP.ClientCannotShoot() || bbP.Weapon != Self)
				return false;

			if ( (AmmoType == None) && (AmmoName != None) )
			{
				// ammocheck
				GiveAmmo(Pawn(Owner));
			}

			if ( AmmoType.AmmoAmount > 0 )
			{
				yModInit();

				Instigator = Pawn(Owner);
				GotoState('ClientFiring');
				bPointing=True;
				bCanClientFire = true;
				
				GetAxes(GV,X,Y,Z);
				Start = Owner.Location + CDO + FireOffset.X * X + yMod * Y + FireOffset.Z * Z; 
				AdjustedAim = Pawn(owner).AdjustAim(ProjectileSpeed, Start, AimError, True, bWarnTarget);	
				
				ClientRazor2Alt = Spawn(Class'ST_Razor2Alt', Owner,, Start, AdjustedAim);
				ClientRazor2Alt.RemoteRole = ROLE_None;
				ClientRazor2Alt.bClientVisualOnly = true;
				ClientRazor2Alt.LifeSpan = bbPlayer(Owner).PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
				ClientRazor2Alt.bCollideWorld = false;

				ClientRazor2Alt.Razor2AltID = Razor2AltCounter;
				LastFiredRazor2AltID = Razor2AltCounter;
			}
		}
	}
	
	return Super.ClientAltFire(Value);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local Projectile P;
    local bbPlayer bbP;

    // Call original ProjectileFire to spawn the projectile
    P = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
	
    	if (ST_Razor2(P) != None)
        {
            ST_Razor2(P).Razor2ID = Razor2Counter;
        }
        else if (ST_Razor2Alt(P) != None)
        {
            ST_Razor2Alt(P).Razor2AltID = Razor2AltCounter;
        }
        
    if (P != None && GetWeaponSettings().RipperCompensatePing) {
        bbP = bbPlayer(Owner);
        if (bbP != None) {
            WImp.SimulateProjectile(P, bbP.PingAverage);
        }
    }
    
    if (Role == ROLE_Authority)
    {
        if (ProjClass == class'ST_Razor2')
        {
            bClientAllowedToFire = false;
            Razor2Counter++;
            bClientAllowedToFire = true;
        }
        else if (ProjClass == class'ST_Razor2Alt')
        {
            bClientAllowedToAltFire = false; 
            Razor2AltCounter++;
            bClientAllowedToAltFire = true;
        }
    }
    return P;
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

State ClientActive
{
	simulated function bool ClientFire(float Value)
	{
		if (Owner.IsA('Bot'))
			return Super.ClientFire(Value);
		bForceFire = bbPlayer(Owner) == None || !bbPlayer(Owner).ClientCannotShoot();
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		if (Owner.IsA('Bot'))
			return Super.ClientAltFire(Value);
		bForceAltFire = bbPlayer(Owner) == None || !bbPlayer(Owner).ClientCannotShoot();
		return bForceAltFire;
	}
	
	simulated function AnimEnd()
	{
		if ( Owner == None )
		{
			Global.AnimEnd();
			GotoState('');
		}
		else if ( Owner.IsA('TournamentPlayer') 
			&& (TournamentPlayer(Owner).PendingWeapon != None || TournamentPlayer(Owner).ClientPending != None) )
			GotoState('ClientDown');
		else if ( bWeaponUp )
		{
			if ( (bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(1) )
				return;
			else if ( (bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(1) )
				return;
			PlayIdleAnim();
			GotoState('');
		}
		else
		{
			PlayPostSelect();
			bWeaponUp = true;
		}
	}
}

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

function bool PutDown()
{
    bClientAllowedToFire = false;	
	bClientAllowedToAltFire = false;
    return Super.PutDown();
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
