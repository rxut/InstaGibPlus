// ===============================================================
// UTPureStats7A.ST_ut_biorifle: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_ut_biorifle extends ut_biorifle;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var int BioGelIDCounter;
var bool bClientAllowedToFire;

replication
{
    reliable if ( Role == ROLE_Authority )
        BioGelIDCounter, bClientAllowedToFire;
}

var Rotator GV;
var Vector CDO;
var float yMod;

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

	// Initialize BioGelIDCounter
	BioGelIDCounter = 0;
}

simulated function RenderOverlays(Canvas Canvas)
{
	local bbPlayer bbP;
	
	Super.RenderOverlays(Canvas);
	yModInit();
	
	bbP = bbPlayer(Owner);
	if (Role < ROLE_Authority && bbP != None)
	{
		if (bbP.bFire != 0 && !IsInState('ClientFiring'))
			ClientFire(1);
		else if (bbP.bAltFire != 0 && !IsInState('ClientAltFiring'))
			ClientAltFire(1);
	}
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

	CDO = CalcDrawOffset();
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local Projectile P;
    local bbPlayer bbP;

    P = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);

	if (ST_UT_BioGel(P) != None)
        {
            ST_UT_BioGel(P).BioGelID = BioGelIDCounter;
        }
    
    if (P != None && GetWeaponSettings().BioCompensatePing) {
        bbP = bbPlayer(Owner);
        if (bbP != None && bbP.PingAverage > 0 && WImp != None) {
            WImp.SimulateProjectile(P, bbP.PingAverage);
        }
    }

	bClientAllowedToFire = true;
    
    return P;
}

simulated function bool ClientFire(float Value)
{
	local Vector Start, X,Y,Z;
	local ST_UT_BioGel BioGelProj;
	local bbPlayer bbP;
	
	if (Owner.IsA('Bot'))
		return Super.ClientFire(Value);
	
	bbP = bbPlayer(Owner);
	if (bClientAllowedToFire && Role < ROLE_Authority && bbP != None && GetWeaponSettings().BioUseClientSideAnimations && Mover(bbP.Base) == None)
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
			if ( bRapidFire || (FiringSpeed > 0) )
				Pawn(Owner).PlayRecoil(FiringSpeed);

			GetAxes(GV,X,Y,Z);
			Start = Owner.Location + CDO + FireOffset.X * X + yMod * Y + FireOffset.Z * Z; 
			AdjustedAim = pawn(owner).AdjustToss(ProjectileSpeed, Start, 0, True, bWarnTarget);	
			
			BioGelProj = Spawn(class'ST_UT_BioGel',Owner,, Start, AdjustedAim);
			BioGelProj.BioGelID = BioGelIDCounter;
			BioGelProj.bClientVisualOnly = true;
			BioGelProj.WImp = WImp;
		}
	}
		
	return Super.ClientFire(Value);
}

// Override the ShootLoad state to add ping compensation for alt-fire
state ShootLoad
{
    // Keep original state functionality
    function ForceFire() { Super.ForceFire(); }
    function ForceAltFire() { Super.ForceAltFire(); }
    function Fire(float F) { Super.Fire(F); }
    function AltFire(float F) { Super.AltFire(F); }
    function Timer() { Super.Timer(); }
    function AnimEnd() { Super.AnimEnd(); }

    // Override BeginState to add ping compensation for the alt-fire projectile
    function BeginState()
    {
        Local Projectile Gel;
        local bbPlayer bbP;

        // Spawn the projectile as in the original
        Gel = ProjectileFire(AltProjectileClass, AltProjectileSpeed, bAltWarnTarget);
        
        if (Gel != None) {
            // Set the draw scale as in the original
            Gel.DrawScale = 1.0 + 0.8 * ChargeSize;
            
            // Check if we should apply ping compensation
            if (GetWeaponSettings().BioCompensatePing) {
                bbP = bbPlayer(Owner);
                if (bbP != None) {
                    // Simulate projectile forward by player's ping time
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
