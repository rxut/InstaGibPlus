// ===============================================================
// UTPureStats7A.ST_PulseGun: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_PulseGun extends PulseGun;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var ST_PlasmaSphere LocalPlasmaSphereDummies[16];

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

simulated function int FindFreeDummySlot() {
	local int i;

	for (i = 0; i < ArrayCount(LocalPlasmaSphereDummies); i++) {
		if (LocalPlasmaSphereDummies[i] == none || LocalPlasmaSphereDummies[i].bDeleteMe)
			return i;
	}
	return -1;
}

simulated function ST_PlasmaSphere FindBestMatchingDummy(vector Direction) {
	local int i;
	local float BestMatch, DirMatch;
	local int BestIndex;
	local vector DummyDir;

	BestMatch = 0.9;
	BestIndex = -1;

	for (i = 0; i < ArrayCount(LocalPlasmaSphereDummies); i++) {
		if (LocalPlasmaSphereDummies[i] != none && !LocalPlasmaSphereDummies[i].bDeleteMe) {
			DummyDir = Normal(LocalPlasmaSphereDummies[i].Velocity);
			DirMatch = Direction dot DummyDir;
			if (DirMatch > BestMatch) {
				BestMatch = DirMatch;
				BestIndex = i;
			}
		}
	}

	if (BestIndex >= 0)
		return LocalPlasmaSphereDummies[BestIndex];

	return none;
}

simulated function ClearDummyFromArray(ST_PlasmaSphere Dummy) {
	local int i;

	for (i = 0; i < ArrayCount(LocalPlasmaSphereDummies); i++) {
		if (LocalPlasmaSphereDummies[i] == Dummy) {
			LocalPlasmaSphereDummies[i] = none;
			return;
		}
	}
}

simulated function SpawnClientDummyProjectile() {
	local Pawn PawnOwner;
	local vector Start, X, Y, Z;
	local float Hand;
	local int Slot;
	local ST_PlasmaSphere NewDummy;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return;

	Slot = FindFreeDummySlot();
	if (Slot < 0)
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

	NewDummy = Spawn(class'ST_PlasmaSphere', Owner,, Start, PawnOwner.ViewRotation);
	NewDummy.RemoteRole = ROLE_None;
	NewDummy.Instigator = PawnOwner;
	NewDummy.bClientVisualOnly = true;
	NewDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
	NewDummy.bCollideWorld = false;
	NewDummy.SetCollision(false, false, false);
	NewDummy.Velocity = vector(PawnOwner.ViewRotation) * NewDummy.Speed;

	LocalPlasmaSphereDummies[Slot] = NewDummy;
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
    Sleep(GetWeaponSettings().PulseSphereFireRate);
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
		local TournamentPlayer T;
		local bbPlayer bbP;

		T = TournamentPlayer(Owner);
		if (T != None && T.ClientPending != None) {
			GotoState('ClientDown');
			return;
		}

		RateOfFire -= DeltaTime;

		if (RateOfFire <= 0) {
			if ((Pawn(Owner) != none) && (Pawn(Owner).bFire != 0)) {

				if (Role < ROLE_Authority)
				{
					bbP = bbPlayer(Owner);

					if (bbP != none && bbP.ClientWeaponSettingsData.bPulseUseClientSideAnimations)
					{
						SpawnClientDummyProjectile();
					}
				}

				Angle += 1.8;

				RateOfFire = GetWeaponSettings().PulseSphereFireRate;
			} else {
				AnimEnd();
			}
		}
	}

	simulated function AnimEnd() {
		local TournamentPlayer T;

		T = TournamentPlayer(Owner);
		if (T != None && T.ClientPending != None) {
			GotoState('ClientDown');
			return;
		}
		Super.AnimEnd();
	}
Begin:
}

simulated state ClientAltFiring
{
	simulated event BeginState()
	{
		Super.BeginState();
		Count = 0;
		AmbientGlow = 200;
	}
	
	simulated event EndState()
	{
		Super.EndState();
		AmbientSound = None;
		AmbientGlow = 0;
	}

	simulated event Tick( float DeltaTime)
	{
		local TournamentPlayer T;

		T = TournamentPlayer(Owner);
		if (T != None && T.ClientPending != None) {
			GotoState('ClientDown');
			return;
		}

		if ( Pawn(Owner) == None || Pawn(Owner).bAltFire == 0 )
			AnimEnd();

		Count += DeltaTime;
		if ( Count > 0.24 )
		{
			if ( Affector != None )
				Affector.FireEffect();
			Count -= 0.24;
		}
	}

	simulated event AnimEnd()
	{
		local TournamentPlayer T;

		T = TournamentPlayer(Owner);
		if (T != None && T.ClientPending != None) {
			GotoState('ClientDown');
			return;
		}

		if ( AmmoType.AmmoAmount <= 0 )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( !bCanClientFire )
			GotoState('');
		else if ( Pawn(Owner) == None )
		{
			PlayIdleAnim();
			GotoState('');
		}
		else if ( Pawn(Owner).bAltFire != 0 )
			LoopAnim('BoltLoop');
		else if ( Pawn(Owner).bFire != 0 )
			Global.ClientFire(0);
		else
		{
			PlayIdleAnim();
			GotoState('');
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

State ClientDown
{
	simulated function AnimEnd()
	{
		local TournamentPlayer T;

		T = TournamentPlayer(Owner);
		if ( T != None )
		{
			if ( (T.ClientPending != None)
				&& (T.ClientPending.Owner == Owner) )
			{
				T.Weapon = T.ClientPending;
				T.Weapon.GotoState('ClientActive');
				T.ClientPending = None;
				GotoState('');
			}
			else
			{
				T.NeedActivate();
			}
		}
	}

	simulated function BeginState()
	{
		TweenDown();
	}
}

defaultproperties {
	ProjectileClass=Class'ST_PlasmaSphere'
	AltProjectileClass=Class'ST_StarterBolt'
}