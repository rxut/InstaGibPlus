// ===============================================================
// UTPureStats7A.ST_PulseGun: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_PulseGun extends PulseGun;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

// For the PulseSphereFireRate setting
var float RateOfFire;

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
	
	ProjectileSpeed = WImp.WeaponSettings.PulseSphereSpeed;
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

state NormalFire
{
    ignores AnimEnd;

    function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
    {
        local Projectile P;
        local bbPlayer bbP;
        
        // Call the parent ProjectileFire to spawn the projectile
        P = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
        
        // Check if we should apply ping compensation
        if (P != None && GetWeaponSettings().PulseCompensatePing) {
            bbP = bbPlayer(Owner);
            if (bbP != None) {
                // Simulate projectile forward by player's ping time
                WImp.SimulateProjectile(P, bbP.PingAverage);
            }
        }
        
        return P;
    }

    // Include the rest of the original NormalFire state
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
	}
Begin:
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

defaultproperties {
	ProjectileClass=Class'ST_PlasmaSphere'
	AltProjectileClass=Class'ST_StarterBolt'
}
