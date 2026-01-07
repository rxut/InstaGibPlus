// ===============================================================
// UTPureStats7A.ST_ut_biorifle: put your comment here
//
// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_ut_biorifle extends ut_biorifle;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var ST_UT_BioGel LocalBioGelDummy;
var ST_BioGlob LocalBioGlobDummy;

// Explicit client aim data (sent via ServerExplicitFire)
var vector ExplicitClientLoc;
var rotator ExplicitClientRot;
var bool bUseExplicitData;

// Server-side position validation
const MAX_POSITION_ERROR_SQ = 1250.0;

replication
{
	reliable if(Role < ROLE_Authority)
		ServerExplicitFire;
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

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) &&
         (bIsSwitching || (P.PendingWeapon != None && P.PendingWeapon != self)) )
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
		PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening * 4.0);
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		
		bUseExplicitData = false;
		bChangeWeapon = true;
		return;
	}
	
	if (bChangeWeapon || IsInState('DownWeapon') || P.Weapon != self)
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
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
		GoToState('NormalFire');
	}

	bUseExplicitData = false;
}

function Fire( float Value )
{
	local Pawn PawnOwner;
	PawnOwner = Pawn(Owner);

	// If this is a player with explicit firing enabled, wait for ServerExplicitFire
	if (GetWeaponSettings().BioCompensatePing && PlayerPawn(Owner) != None)
	{
        // Still need to go to Idle if called from Finish()
        if (IsInState('NormalFire'))
            GotoState('Idle');
        return;
    }

	Super.Fire(Value);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local Projectile P;
    local bbPlayer bbP;
    local Vector Start, X, Y, Z;

    if (bUseExplicitData)
    {
        // Explicit Fire Logic using client data
        Owner.MakeNoise(Pawn(Owner).SoundDampening);
        GetAxes(ExplicitClientRot, X, Y, Z);
        Start = ExplicitClientLoc + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
        
        // Direct spawn using explicit rotation
        P = Spawn(ProjClass,,, Start, ExplicitClientRot);
    }
    else
    {
        // Standard Logic (original behavior)
        P = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
    }
    
    // Check if we should apply ping compensation (for both explicit and standard fire)
    if (P != None && GetWeaponSettings().BioCompensatePing) {
        bbP = bbPlayer(Owner);
        if (bbP != None && bbP.PingAverage > 0 && WImp != None) {
            // Simulate projectile forward by player's ping time
            WImp.SimulateProjectile(P, bbP.PingAverage);
        }
    }
    
    return P;
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

	if (GetWeaponSettings().BioCompensatePing)
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
					PlayerPawn(Owner).ClientInstantFlash(InstFlash, InstFog);

				// Spawn client-side visual
				if (bbP.ClientWeaponSettingsData.bBioUseClientSideAnimations)
				{
					SpawnClientDummyBioGel();
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

simulated function SpawnClientDummyBioGel()
{
	local Pawn PawnOwner;
	local vector X, Y, Z;
	local vector Start;
	local float Hand;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
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

	LocalBioGelDummy = Spawn(class'ST_UT_BioGel', Owner,, Start, PawnOwner.ViewRotation);
	LocalBioGelDummy.RemoteRole = ROLE_None;
	LocalBioGelDummy.Instigator = PawnOwner;
	LocalBioGelDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	LocalBioGelDummy.bClientVisualOnly = true;
	LocalBioGelDummy.bCollideWorld = false;
	LocalBioGelDummy.SetCollision(false, false, false);
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
		Super.BeginState();
	}
}

simulated state ClientFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function AnimEnd()
	{
		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
		{
			GotoState('DownWeapon');
			return;
		}
		
		Super.AnimEnd();
	}

	simulated function BeginState()
	{
		Super.BeginState();
	}
}

state ShootLoad
{
    function ForceFire() { Super.ForceFire(); }
    function ForceAltFire() { Super.ForceAltFire(); }
    function Fire(float F) { Super.Fire(F); }
    function AltFire(float F) { Super.AltFire(F); }
    function Timer() { Super.Timer(); }
    function AnimEnd() { Super.AnimEnd(); }

    function BeginState()
    {
        Local Projectile Gel;
        local bbPlayer bbP;

        Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
        
        if (Gel != None) {
            Gel.DrawScale = 1.0 + 0.8 * ChargeSize;
            
            // Check if we should apply ping compensation
            if (GetWeaponSettings().BioCompensatePing) {
                bbP = bbPlayer(Owner);
                if (bbP != None) {
                    WImp.SimulateProjectile(Gel, bbP.PingAverage);
                }
            }
        }
        
        if (Affector != None)
            Affector.FireEffect();
        
        PlayAltBurst();
    }

Begin:
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
		carried = 'ut_biorifle';
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
		PlayAnim('Select',GetWeaponSettings().BioSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().BioDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().BioDownAnimSpeed(), TweenTime);
}


defaultproperties {
	ProjectileClass=Class'ST_UT_BioGel'
	AltProjectileClass=Class'ST_BioGlob'
}
