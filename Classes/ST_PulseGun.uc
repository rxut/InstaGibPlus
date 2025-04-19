// ===============================================================
// UTPureStats7A.ST_PulseGun: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_PulseGun extends PulseGun;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var ST_PlasmaSphere LocalPlasmaSphereDummy;

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

simulated function SpawnClientDummyProjectile() {
	local Pawn PawnOwner;
	local vector Start, X, Y, Z;
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

	Start = Start - Sin(Angle)*Y*4 + (Cos(Angle)*4 - 10.78)*Z;

	LocalPlasmaSphereDummy = Spawn(class'ST_PlasmaSphere', Owner,, Start, PawnOwner.ViewRotation);
	LocalPlasmaSphereDummy.RemoteRole = ROLE_None;
	LocalPlasmaSphereDummy.bClientVisualOnly = true;
	LocalPlasmaSphereDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	LocalPlasmaSphereDummy.bCollideWorld = false;
	LocalPlasmaSphereDummy.SetCollision(false, false, false);
	LocalPlasmaSphereDummy.Velocity = vector(PawnOwner.ViewRotation) * LocalPlasmaSphereDummy.Speed;
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
		local bbPlayer bbP;

		super.BeginState();
		
		// Reset Angle when firing starts (matches server NormalFire.BeginState)
		Angle = 0;

		if (Role < ROLE_Authority)
		{
			bbP = bbPlayer(Owner);

			if (bbP != none && bbP.ClientWeaponSettingsData.bPulseUseClientSideAnimations)
			{
				SpawnClientDummyProjectile();
			}
		}
		
		Angle += 1.8; // Increment angle AFTER the first shot is spawned

		RateOfFire = GetWeaponSettings().PulseSphereFireRate;
	}

	simulated event Tick(float DeltaTime) {
		local bbPlayer bbP;
		RateOfFire -= DeltaTime; // Count down timer

		if (RateOfFire <= 0) {
			if ((Pawn(Owner) != none) && (Pawn(Owner).bFire != 0)) {

				if (Role < ROLE_Authority)
				{
					bbP = bbPlayer(Owner);

					if (bbP != none && bbP.ClientWeaponSettingsData.bPulseUseClientSideAnimations)
					{
						// Spawn next dummy using the CURRENT angle
						SpawnClientDummyProjectile();
					}
				}

				Angle += 1.8; // Increment angle AFTER spawning

				RateOfFire = GetWeaponSettings().PulseSphereFireRate; // Reset timer
			} else {
				AnimEnd();
			}
		}
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