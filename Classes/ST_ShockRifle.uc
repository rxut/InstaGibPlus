// ===============================================================
// Stats.ST_ShockRifle: ShockRifle with ping compensation
// ===============================================================

class ST_ShockRifle extends ShockRifle;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var float yMod;
var vector CDO;
var rotator LastSentFireRotation;

var ST_ShockProj LocalDummy;

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

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp) {
		break;
	}
}

simulated function yModInit() {
	if (PlayerPawn(Owner) == None)
		return;

	yMod = PlayerPawn(Owner).Handedness;
	if (yMod != 2.0)
		yMod *= Default.FireOffset.Y;
	else
		yMod = 0;

	CDO = CalcDrawOffsetClient();
}

simulated function bool ClientFire(float Value) {
	local Pawn PawnOwner;
	local bool Result;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);
	
	if (PawnOwner == None) 
		return false;

	if (GetWeaponSettings().bEnablePingCompensation)
	{
		bbP = bbPlayer(PawnOwner);

		if (Owner.Role == ROLE_AutonomousProxy && bbP != None && bbP.ClientWeaponSettingsData.bShockUseClientSideAnimations)
		{

			if ((AmmoType == None) && (AmmoName != None)) {
				GiveAmmo(PawnOwner);
			}
			
			if (AmmoType != None && AmmoType.AmmoAmount > 0) // Check ammo
			{
				Instigator = PawnOwner;
				GotoState('ClientFiring');
				bPointing = True;
				bCanClientFire = true;

				if (bRapidFire || (FiringSpeed > 0))
					PawnOwner.PlayRecoil(FiringSpeed);
					
				PlayFiring();

				if ( Affector != None )
					Affector.FireEffect();

				if (PlayerPawn(Owner) != None)
					PlayerPawn(Owner).ClientInstantFlash(-0.4, vect(450, 190, 650));

				return true;
			}
			return false; // No ammo
		}
	}
	
	Result = Super.ClientFire(Value);
	return Result;
}

// Client-side shock beam tracing and effect spawning
simulated function ClientTraceFire() {
    local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
    local actor Other;
    local Pawn PawnOwner;
    local vector SmokeLocation;
	local bbPlayer bbP;
	local vector TargetOffset;

    PawnOwner = Pawn(Owner);
	
    if (PawnOwner == None)
        return;

	bbP = bbPlayer(PawnOwner);

	if ( GetWeaponSettings().bEnablePingCompensation == false
      || bbP == None
      || !bbP.ClientWeaponSettingsData.bShockUseClientSideAnimations )
    {
        return;
    }

	yModInit();

	GetAxes(PawnOwner.ViewRotation, X, Y, Z);

	StartTrace = Owner.Location + CDO + yMod * Y + FireOffset.Z * Z;

	EndTrace = StartTrace + (10000 * X);
	
	SmokeLocation = Owner.Location + CDO + (FireOffset.X + 20) * X + yMod * Y + FireOffset.Z * Z;

	if (Trace(HitLocation, HitNormal, EndTrace, StartTrace, true) != None) {
		Other = Level;
		EndTrace = HitLocation;
	}

	if (Other == None) {
		if (GetWeaponSettings().ShockBeamUseReducedHitbox) {
			Other = WImp.TraceShotClient(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner);
		} else {
			Other = bbP.TraceShotClient(HitLocation, HitNormal, EndTrace, StartTrace);
		}
	}
	
	if (Other == PawnOwner) {
		Other = None;
		HitLocation = EndTrace;
	}
		
	if (Other == None) {
		HitLocation = EndTrace;
	}

	if (Other != None)
        TargetOffset = HitLocation - Other.Location;
    else
        TargetOffset = HitLocation;

	ClientSpawnBeam(HitLocation, SmokeLocation); // Spawn client-side beam effect
}

simulated function ClientSpawnBeam(vector HitLocation, vector SmokeLocation) {
	local ShockBeam Smoke;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;
	
	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if (NumPoints < 1) {
		return;
	}
		
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);
	
	Smoke = Spawn(class'ShockBeam', Owner,, SmokeLocation, SmokeRotation);

	Smoke.MoveAmount = DVector/NumPoints;
	Smoke.NumPuffs = NumPoints - 1;

	if (bbPlayer(Owner) != None)
		bbPlayer(Owner).xxClientDemoFix(None, class'ShockBeam', SmokeLocation, , , SmokeRotation, , , DVector/NumPoints, NumPoints-1);
}

function TraceFire(float Accuracy) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X,Y,Z;
	local actor Other;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z; 

	EndTrace = StartTrace + (Accuracy * (FRand() - 0.5 )* Y * 1000) + (Accuracy * (FRand() - 0.5 ) * Z * 1000);

	if (bBotSpecialMove && (Tracked != None) && (
			((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40)) ||
			(Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95)
		)
	) {
		EndTrace += 10000 * Normal(Tracked.Location - StartTrace);
	} else {
		AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);	
		EndTrace += (10000 * vector(AdjustedAim)); 
	}

	Tracked = None;
	bBotSpecialMove = false;

	if (WImp.WeaponSettings.ShockBeamUseReducedHitbox)
		Other = WImp.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner);
	else
		Other = PawnOwner.TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
		
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local PlayerPawn PlayerOwner;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	if (Other==None)
	{
		HitNormal = -X;
		HitLocation = Owner.Location + X*10000.0;
	}

	PlayerOwner = PlayerPawn(Owner);
	if (PlayerOwner != None)
		PlayerOwner.ClientInstantFlash(-0.4, vect(450, 190, 650));
		
	// Server-side beam spawning
	SpawnEffect(HitLocation, Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z);
	
	if (ST_ShockProj(Other)!=None)
	{ 
		AmmoType.UseAmmo(2);
		ST_ShockProj(Other).SuperExplosion();
		return;
	}
	else
		Spawn(class'ut_RingExplosion5',,, HitLocation+HitNormal*8,rotator(HitNormal));

	if ((Other != self) && (Other != Owner) && (Other != None)) 
	{
		Other.TakeDamage(
			WImp.WeaponSettings.ShockBeamDamage,
			PawnOwner,
			HitLocation,
			WImp.WeaponSettings.ShockBeamMomentum*60000.0*X,
			MyDamageType);
	}
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local ST_ShockBeamOwnerHidden ServerBeamHidden;
	local ShockBeam ServerBeamVisible;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;
	local PlayerPawn PlayerOwner;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector)/135.0;
	if (NumPoints < 1) {
		return;
	}
		
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);
	
	PlayerOwner = PlayerPawn(Owner);

	// If compensation is active and this is the owner's client, use the hidden beam
	if (GetWeaponSettings().bEnablePingCompensation && PlayerOwner == Owner && bbPlayer(PlayerOwner).ClientWeaponSettingsData.bShockUseClientSideAnimations) {

		ServerBeamHidden = Spawn(class'ST_ShockBeamOwnerHidden', Owner,, SmokeLocation, SmokeRotation);
		ServerBeamHidden.bOwnerNoSee = true;
		ServerBeamHidden.bAlreadyHidden = false;

		ServerBeamHidden.MoveAmount = DVector/NumPoints;
		ServerBeamHidden.NumPuffs = NumPoints - 1;

	} else {
		
		ServerBeamVisible = Spawn(class'ShockBeam',, , SmokeLocation, SmokeRotation);
		ServerBeamVisible.MoveAmount = DVector/NumPoints;
		ServerBeamVisible.NumPuffs = NumPoints - 1;
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
		carried = 'ShockRifle';
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

simulated function PlayFiring() {
	local bbPlayer bbP;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	LoopAnim('Fire1', 0.30 + 0.30 * FireAdjust,0.05);

	bbP = bbPlayer(PawnOwner);

	if (Owner.Role == ROLE_AutonomousProxy &&
	GetWeaponSettings().bEnablePingCompensation &&
	bbP != None &&
	bbP.ClientWeaponSettingsData.bShockUseClientSideAnimations)
    {
        ClientTraceFire();
    }
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().ShockSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().ShockDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().ShockDownAnimSpeed(), TweenTime);
}

state ClientFiring {

	simulated function bool ClientFire(float Value) {
		return false;
	}

	simulated function bool ClientAltFire(float Value) {
		return false;
	}

	simulated function AnimEnd()
    {
        if (Owner.Role == ROLE_AutonomousProxy &&
		GetWeaponSettings().bEnablePingCompensation &&
		bbPlayer(Owner) != None &&
		bbPlayer(Owner).ClientWeaponSettingsData.bShockUseClientSideAnimations)
        {
            if ( (Pawn(Owner) == None)
                || ((AmmoType != None) && (AmmoType.AmmoAmount <= 0)) )
            {
                PlayIdleAnim();
                GotoState('');
                return;
            }

            if ( Pawn(Owner).bFire != 0 ) 
            {
                Global.ClientFire(0); 
            }
            else if ( Pawn(Owner).bAltFire != 0 ) 
            {
                 Global.ClientAltFire(0);
            }
            else
            {
                PlayIdleAnim();
                GotoState('');
            }
        }
        else
        {
            Super.AnimEnd();
        }
    }
}

state ClientAltFiring {
	simulated function BeginState() {
		local Pawn PawnOwner;
		local vector X, Y, Z;
		local vector Start;
		local float Hand;

		if (GetWeaponSettings().ShockProjectileCompensatePing == false)
			return;

		PawnOwner = Pawn(Owner);

		if (Owner.IsA('PlayerPawn'))
			Hand = FClamp(PlayerPawn(Owner).Handedness, -1.0, 1.0);
		else
			Hand = 1.0;

		GetAxes(PawnOwner.ViewRotation,X,Y,Z);
		if (bHideWeapon)
			Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Z * Z;
		else
			Start = Owner.Location + CalcDrawOffsetClient() + FireOffset.X * X + FireOffset.Y * Hand * Y + FireOffset.Z * Z;
		
		LocalDummy = ST_ShockProj(Spawn(AltProjectileClass,,, Start,PawnOwner.ViewRotation));
		LocalDummy.RemoteRole = ROLE_None;
		LocalDummy.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
		LocalDummy.bCollideWorld = false;
		LocalDummy.SetCollision(false, false, false);
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

defaultproperties {
	AltProjectileClass=Class'ST_ShockProj'
}