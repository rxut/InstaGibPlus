// ===============================================================
// UTPureStats7A.ST_PulseGun: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_PulseGun extends PulseGun;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var Rotator GV;
var Vector CDO;
var float yMod;

var int PlasmaSphereCounter;
var int LastFiredPlasmaSphereID;

var float RateOfFire; // For the PulseSphereFireRate IG+ setting
var bool bClientAllowedToFire;

replication
{
    reliable if (Role == ROLE_Authority)
        PlasmaSphereCounter, bClientAllowedToFire;
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
	
	PlasmaSphereCounter = 0;
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

function SetSwitchPriority(pawn Other)
{	// Make sure "old" priorities are kept.
	local int i;
	local name temp, carried;

	if ( PlayerPawn(Other) != None )
	{
		for ( i=0; i<ArrayCount(PlayerPawn(Other).WeaponPriority); i++)
			if ( IsA(PlayerPawn(Other).WeaponPriority[i]) )
			{
				AutoSwitchPriority = i;
				return;
			}
		// else, register this weapon
		carried = 'PulseGun';
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

simulated function PlayFiring()
{
	FlashCount++;
	AmbientSound = FireSound;
	SoundVolume = Pawn(Owner).SoundDampening*255;
	PlayAnim('shootLOOP', (1 + 0.5 * FireAdjust) * GetWeaponSettings().PulseFiringAnimSpeed(), 0.0);
	bWarnTarget = (FRand() < 0.2);
}

simulated function bool ClientFire(float Value)
{
	local Vector Start, X, Y, Z;
	local ST_PlasmaSphere ClientPlasma;
	local bbPlayer bbP;
	
	if (Owner.IsA('Bot'))
		return Super.ClientFire(Value);
	
	bbP = bbPlayer(Owner);
	if (bClientAllowedToFire && Role < ROLE_Authority && bbP != None && GetWeaponSettings().PulseUseClientSideAnimations && Mover(bbP.Base) == None)
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
			bPointing = True;
			bCanClientFire = true;

			if ( bRapidFire || (FiringSpeed > 0) )
				Pawn(Owner).PlayRecoil(FiringSpeed);
			
			GetAxes(GV, X, Y, Z);
			Start = Owner.Location + CDO + FireOffset.X * X + yMod * Y + FireOffset.Z * Z; 
			AdjustedAim = Pawn(owner).AdjustAim(ProjectileSpeed, Start, AimError, True, bWarnTarget);	
			Angle += 1.8;

			Start = Start - Sin(Angle)*Y*4 + (Cos(Angle)*4 - 10.78)*Z;

			ClientPlasma = Spawn(Class'ST_PlasmaSphere', Owner,, Start, AdjustedAim);
			ClientPlasma.Velocity = Vector(AdjustedAim) * ProjectileSpeed;
			
			ClientPlasma.bClientVisualOnly = true;
			ClientPlasma.PlasmaSphereID = PlasmaSphereCounter;
			
		}
	}
	return Super.ClientFire(Value);
}

state NormalFire
{
    ignores AnimEnd;

    function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
    {
        local Projectile P;
        local bbPlayer bbP;
        
        P = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
		bClientAllowedToFire = true;

		if (P != None && ST_PlasmaSphere(P) != None)
        {
            ST_PlasmaSphere(P).PlasmaSphereID = PlasmaSphereCounter;
        }
        
        if (P != None && GetWeaponSettings().PulseCompensatePing) {
            bbP = bbPlayer(Owner);
            if (bbP != None) {
                WImp.SimulateProjectile(P, bbP.PingAverage);
            }
        }
        
        if (Role == ROLE_Authority)
   	 	{
			PlasmaSphereCounter++;
		}
        
        return P;
    }

    function Tick(float DeltaTime)
    {
        if (Owner == None) 
            GotoState('Pickup');
    }

    function BeginState()
    {
        Super.BeginState();
        Angle = 0;
        AmbientGlow = 200;
    }

    function EndState()
    {
        PlaySpinDown();
        AmbientSound = None;
        AmbientGlow = 0;
        OldFlashCount = FlashCount;
        Super.EndState();
    }

Begin:
    Sleep(0.18);
    Finish();
}

simulated state ClientFiring
{
	simulated function AnimEnd()
	{
		if (Owner.IsA('Bot'))
		{
			Super.AnimEnd();
			return;
		}
		
		if ( (AmmoType != None) && (AmmoType.AmmoAmount <= 0) )
		{
			PlaySpinDown();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlaySpinDown();
			GotoState('');
		}
	}

	simulated function BeginState() {
		super.BeginState();

		RateOfFire = GetWeaponSettings().PulseSphereFireRate;
	}

	simulated event Tick(float DeltaTime) {
		super.Tick(DeltaTime);

		RateOfFire -= DeltaTime;
		if (RateOfFire < 0) {
			if ((Pawn(Owner) == none) || (Pawn(Owner).bFire == 0)) {
				AnimEnd();
				RateOfFire = 0;
			} else {
				RateOfFire += GetWeaponSettings().PulseSphereFireRate;
			}
		}

		if (Owner.IsA('Bot'))
		{
			Super.Tick(DeltaTime);
			return;
		}
		
		if (Owner==None) 
			GotoState('Pickup');
			
		if ( (Pawn(Owner) != None) && (Pawn(Owner).bFire != 0) )
			AmbientSound = FireSound;
		else
			AmbientSound = None;
	}
Begin:
	if (!Owner.IsA('Bot'))
	{
		Sleep(0.18);
		ClientFinish();
	}
}

simulated function ClientFinish()
{
	local Pawn PawnOwner;
	local bool bForce, bForceAlt;
	local bbPlayer bbP;
	
	if (Owner.IsA('Bot'))
		return;
	
	bbP = bbPlayer(Owner);
	bForce = bForceFire;
	bForceAlt = bForceAltFire;
	bForceFire = false;
	bForceAltFire = false;

	if ( bChangeWeapon )
	{
		GotoState('DownWeapon');
		return;
	}

	PawnOwner = Pawn(Owner);
	if ( PawnOwner == None )
		return;
		
	AnimEnd();
	if ( ((AmmoType != None) && (AmmoType.AmmoAmount<=0)) || (PawnOwner.Weapon != self) )
		GotoState('Idle');
	else if ( (PawnOwner.bFire!=0) || bForce )
		Global.ClientFire(0);
	else if ( (PawnOwner.bAltFire!=0) || bForceAlt )
		Global.ClientAltFire(0);
	else 
		GotoState('Idle');
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().PulseSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
	
	AmbientSound = none;
}

simulated function TweenDown() {
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().PulseDownTime );
	else
		TweenAnim('Down', GetWeaponSettings().PulseDownTime);
}

function bool PutDown()
{
    bClientAllowedToFire = false;	
    return Super.PutDown();
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

			if ((bForceFire || (PlayerPawn(Owner).bFire != 0)) && Global.ClientFire(1))
				return;
			else if ((bForceAltFire || (PlayerPawn(Owner).bAltFire != 0)) && Global.ClientAltFire(1))
				return;
		}
	}
}

defaultproperties {
	ProjectileClass=Class'ST_PlasmaSphere'
	AltProjectileClass=Class'ST_StarterBolt'
	CollisionRadius=50
}
