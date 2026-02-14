// ===============================================================
// Stats.ST_UT_Eightball: put your comment here
//
// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_UT_Eightball extends UT_Eightball;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

// Explicit client aim data
var vector ExplicitClientLoc;
var rotator ExplicitClientRot;
var bool bUseExplicitData;

// Server-side position validation
const MAX_POSITION_ERROR_SQ = 1250.0;

// Rate limiting to prevent rapid fire exploits
var float LastServerFireTime;
var float LastClientFireTime;
const FIRE_RATE_LIMIT = 0.25;


// Client-side offset correction
var float yMod;
var vector CDO;

replication
{
	reliable if(Role < ROLE_Authority)
		ServerExplicitFire, ServerStartedLoading, ServerPlayLoadSound;
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
	return WS != None && WS.RocketCompensatePing;
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

// Called by client when loading starts to stop server lock-on checks
function ServerStartedLoading()
{
	// Only stop the timer to prevent acquiring NEW locks
	// Don't clear existing lock - player may have locked before pressing fire
	SetTimer(0, false);
}

// Called by client to play loading sounds on server so other players can hear
function ServerPlayLoadSound(int RocketNum, bool bIsRotate)
{
	if (Owner == None || Pawn(Owner) == None)
		return;
		
	if (bIsRotate)
		Owner.PlaySound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
	else
		Owner.PlaySound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

// Explicit RPC called when client triggers FiringRockets
function ServerExplicitFire(vector ClientLoc, rotator ClientRot, int NumRockets, bool bAlt, bool bTight)
{
	local PlayerPawn P;
	
	P = PlayerPawn(Owner);
	if (P == None)
		return;

	if (!IsPingCompEnabled())
		return;

	// Rate limit check
	if (Level.TimeSeconds - LastServerFireTime < FIRE_RATE_LIMIT)
		return;

	LastServerFireTime = Level.TimeSeconds;

	NumRockets = Clamp(NumRockets, 1, 6);

	// Position validation
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

	if (AmmoType != None)
	{
		// Consuming ammo all at once since we skipped the gradual loading on server
		if (AmmoType.AmmoAmount < NumRockets)
			NumRockets = AmmoType.AmmoAmount;
            
		AmmoType.UseAmmo(NumRockets);
	}
    
    // Set State Variables used by FireRockets.BeginState
    RocketsLoaded = NumRockets;
    bFireLoad = !bAlt; // Primary fire uses bFireLoad=True
    bTightWad = bTight;

	// Sync bInstantRocket from owner to ensure correct animation speed on server
	if ( TournamentPlayer(P) != None )
		bInstantRocket = TournamentPlayer(P).bInstantRocket;

	if (NumRockets > 0)
	{

		bCanClientFire = true; 

		if (P.PendingWeapon != None && P.PendingWeapon != self)
		{
			P.PlayRecoil(FiringSpeed);
			bChangeWeapon = true;
		}
		else
		{
			bCanClientFire = true;
			bPointing = True;
		}
		
		// Always transition to firing state to spawn projectiles
		GoToState('FireRockets');
	}

	bUseExplicitData = false;
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
	// Only block logic on server. 
	// Client needs to run standard Fire logic to set bCanClientFire=true and transition to ClientFiring.
	if (Role == ROLE_Authority && IsPingCompEnabled() && PlayerPawn(Owner) != None)
		return;
		
	Super.Fire(Value);
}

function AltFire( float Value )
{
	if (Role == ROLE_Authority && IsPingCompEnabled() && PlayerPawn(Owner) != None)
		return;

	Super.AltFire(Value);
}

simulated function bool ClientFire( float Value )
{
	local Pawn PawnOwner;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	// if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
	//	return false;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		// Update bInstantRocket from owner on client to ensure correct firing mode
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
			// Client-side rate limiting
			if (Level.TimeSeconds - LastClientFireTime < FIRE_RATE_LIMIT)
				return false;

			LastClientFireTime = Level.TimeSeconds;
			GotoState('ClientFiring');
			return true;
		}
	}
	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire( float Value )
{
	local Pawn PawnOwner;

	if (!bCanClientFire)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	// if (PawnOwner.PendingWeapon != None && PawnOwner.PendingWeapon != self)
	//	return false;

	if ( (AmmoType != None) && (AmmoType.AmmoAmount > 0) )
	{
		// Update bInstantRocket from owner on client to ensure correct firing mode
		if ( TournamentPlayer(Owner) != None )
			bInstantRocket = TournamentPlayer(Owner).bInstantRocket;

		if ( IsPingCompEnabled() && PlayerPawn(Owner) != None )
		{
			// Client-side rate limiting
			if (Level.TimeSeconds - LastClientFireTime < FIRE_RATE_LIMIT)
				return false;

			LastClientFireTime = Level.TimeSeconds;
			GotoState('ClientAltFiring');
			return true;
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

// Hook into the client-side release trigger
simulated function FiringRockets()
{
    local bbPlayer bbP;
    local bool bAlt;
    
    // Determine fire mode based on current state
    if (IsInState('ClientAltFiring'))
        bAlt = true;
    else
        bAlt = false;

    // Call super to handle animations and cleanup
    Super.FiringRockets();

    bbP = bbPlayer(Owner);
    if (Role < ROLE_Authority && bbP != None && IsPingCompEnabled())
    {
		// Spawn client-side visuals only for Primary Fire (Rockets)
		if (!bAlt && !bLockedOn && bbP.ClientWeaponSettingsData.bRocketUseClientSideAnimations)
		{
			SpawnClientSideRockets(ClientRocketsLoaded);
		}

        // Send the explicit command
        ServerExplicitFire(Pawn(Owner).Location, Pawn(Owner).ViewRotation, ClientRocketsLoaded, bAlt, Pawn(Owner).bAltFire != 0);
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

simulated function SpawnClientSideRockets(int NumRockets)
{
	local vector FireLocation, StartLoc, X,Y,Z;
	local rotator FireRot, AimRot;
	local ST_RocketMk2 r;
	local float Angle, RocketRad;
	local pawn PawnOwner;
	local float Spread;
	local int i;
	local bool bTightWad;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None) return;

	// Update offset calculations
	yModInit();

	// Calculate aim
	GetAxes(PawnOwner.ViewRotation,X,Y,Z);
	
	// Use CDO and yMod for correct positioning (especially when hidden)
	StartLoc = Owner.Location + CDO + FireOffset.X * X + yMod * Y + FireOffset.Z * Z;
	if (bbPlayer(Owner) != None)
		StartLoc.Z += bbPlayer(Owner).GetMoverFireZOffset();
	AimRot = PawnOwner.ViewRotation;

	Angle = 0;
	// Calculate bTightWad client-side
	if ( PawnOwner.bAltFire != 0 )
		bTightWad = true;
	
	if (bTightWad || NumRockets == 1) 
		RocketRad = 7;
	else
		RocketRad = 4;

	for (i = 0; i < NumRockets; i++)
	{
		Spread = (-0.5 * (NumRockets-1) + i);

		if (NumRockets == 1) {
			FireLocation = StartLoc;
		} else if (bTightWad) {
			FireLocation = StartLoc - (Sin(Angle)*RocketRad - 7.5)*Y + (Cos(Angle)*RocketRad - 7)*Z;
		} else {
			FireLocation = StartLoc + (Spread*4.0*Y);
		}
		
		if (bTightWad) {
			FireRot.Yaw = AimRot.Yaw;
		} else {
			FireRot.Yaw = AimRot.Yaw + Spread*WSettings.RocketSpreadSpacingDegrees*(65536.0/360.0);
		}
		FireRot.Pitch = AimRot.Pitch;
		FireRot.Roll = AimRot.Roll;

		r = Spawn(class'ST_RocketMk2', PawnOwner, '', FireLocation, FireRot);
		if (r != None)
		{
			r.Instigator = PawnOwner;
			r.WImp = WImp;
			r.NumExtraRockets = 0; 
			r.RemoteRole = ROLE_None;
			r.bClientVisualOnly = true;
			r.RocketIndex = i;
			r.bCollideWorld = true; 
			r.SetCollision(true, false, false);
			r.LifeSpan = PawnOwner.PlayerReplicationInfo.Ping * 0.00125 * Level.TimeDilation;
		}

		Angle += 1.04719755;
	}
}

///////////////////////////////////////////////////////
state FireRockets
{
	function Fire(float F) {}
	function AltFire(float F) {}

	function ForceFire()
	{
		bForceFire = true;
	}

	function ForceAltFire()
	{
		bForceAltFire = true;
	}

	function bool SplashJump()
	{
		return false;
	}

	function BeginState()
	{
		local vector FireLocation, StartLoc, X,Y,Z;
		local rotator FireRot, RandRot;
		local ST_RocketMk2 r;
		local ST_UT_SeekingRocket s;
		local ST_UT_Grenade g;
		local float Angle, RocketRad;
		local pawn BestTarget, PawnOwner;
		local PlayerPawn PlayerOwner;
		local int DupRockets;
		local float Spread;
		local int i;
		local bbPlayer bbP;
		local Projectile SpawnedRockets[6];
		local int NumSpawnedRockets;
		local rotator AimRot;

		if (bCanClientFire == false)
			return;
			
		PawnOwner = Pawn(Owner);
		if (PawnOwner == None)
			return;
		
		bbP = bbPlayer(PawnOwner);

		PawnOwner.PlayRecoil(FiringSpeed);
		PlayerOwner = PlayerPawn(Owner);
		Angle = 0;
		DupRockets = RocketsLoaded - 1;
		if (DupRockets < 0) DupRockets = 0;
		if ( PlayerOwner == None )
			bTightWad = ( FRand() * 4 < PawnOwner.skill );
			
		if ( !bUseExplicitData && PawnOwner.bAltFire != 0 )
			bTightWad = true;

		// --- EXPLICIT DATA HANDLING ---
		if (bUseExplicitData)
		{
			// Use Client's exact rotation and location
			AimRot = ExplicitClientRot;
			StartLoc = ExplicitClientLoc + CalcDrawOffset(); 
			GetAxes(AimRot, X, Y, Z);
			// Apply FireOffset relative to the explicit aim
			StartLoc = StartLoc + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
			AdjustedAim = AimRot;
		}
		else
		{
			// Standard Server Logic
			GetAxes(PawnOwner.ViewRotation,X,Y,Z);
			StartLoc = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 

			if ( bFireLoad ) 		
				AdjustedAim = PawnOwner.AdjustAim(ProjectileSpeed, StartLoc, AimError, True, bWarnTarget);
			else 
				AdjustedAim = PawnOwner.AdjustToss(AltProjectileSpeed, StartLoc, AimError, True, bAltWarnTarget);	
				
			if ( PlayerOwner != None )
				AdjustedAim = PawnOwner.ViewRotation;
		}
		// ------------------------------
		
		PlayRFiring(RocketsLoaded-1);		
		Owner.MakeNoise(PawnOwner.SoundDampening);
		if ( !bFireLoad )
		{
			LockedTarget = None;
			bLockedOn = false;
		}
		else if ( LockedTarget != None )
		{
			BestTarget = Pawn(CheckTarget());
			if ( (LockedTarget!=None) && (LockedTarget != BestTarget) ) 
			{
				LockedTarget = None;
				bLockedOn=False;
			}
		}
		else 
			BestTarget = None;
		bPendingLock = false;
		bPointing = true;
		FireRot = AdjustedAim;
		if (bTightWad || !bFireLoad)
			RocketRad = 7;
		else
			RocketRad = 4;

		NumSpawnedRockets = 0;
		
		for (i = 0; i < RocketsLoaded; i++)
		{
			Spread = (-0.5 * (RocketsLoaded-1) + i);

			if (RocketsLoaded == 1) {
				FireLocation = StartLoc;
			} else if (bTightWad || bFireLoad == false) {
				FireLocation = StartLoc - (Sin(Angle)*RocketRad - 7.5)*Y + (Cos(Angle)*RocketRad - 7)*Z;
			} else {
				FireLocation = StartLoc + (Spread*4.0*Y);
			}
			
			if (bFireLoad)
			{
				if (bTightWad) {
					FireRot.Yaw = AdjustedAim.Yaw;
				} else {
					FireRot.Yaw = AdjustedAim.Yaw + Spread*WSettings.RocketSpreadSpacingDegrees*(65536.0/360.0);
				}

				// Spawn rockets and collect them for batch simulation
				if (LockedTarget != None)
				{
					s = Spawn(class'ST_UT_SeekingRocket',, '', FireLocation, FireRot);
					s.WImp = WImp;
					s.Seeking = LockedTarget;
					s.NumExtraRockets = DupRockets;
					SpawnedRockets[NumSpawnedRockets] = s;
					NumSpawnedRockets++;
				}
				else 
				{
					r = Spawn(class'ST_RocketMk2',, '', FireLocation, FireRot);
					r.WImp = WImp;
					r.NumExtraRockets = DupRockets;
					r.RocketIndex = i;
					SpawnedRockets[NumSpawnedRockets] = r;
					NumSpawnedRockets++;
				}
			}
			else // Grenades
			{
				g = Spawn(class'ST_UT_Grenade',, '', FireLocation, AdjustedAim);
				g.WImp = WImp;
				g.NumExtraGrenades = DupRockets;
				
				// Apply randomization for multiple grenades
				if (DupRockets > 0)
				{
					RandRot.Pitch = FRand() * 1500 - 750;
					RandRot.Yaw = FRand() * 1500 - 750;
					RandRot.Roll = FRand() * 1500 - 750;
					g.Velocity = g.Velocity >> RandRot;
				}

				// Add to batch simulation
				SpawnedRockets[NumSpawnedRockets] = g;
				NumSpawnedRockets++;
			}

			Angle += 1.04719755; //2*Pi/6;
		}
		
		RocketsLoaded = 0;

		// Apply ping compensation to all rockets at once if enabled
		if (bbP != none && IsPingCompEnabled() && NumSpawnedRockets > 0)
		{
			WImp.BatchSimulateProjectiles(SpawnedRockets, NumSpawnedRockets, bbP.PingAverage);
		}
		
		bTightWad=False;
		bRotated = false;
	}

	function AnimEnd()
	{

		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
		{
			LockedTarget = None;
			GotoState('DownWeapon');
			return;
		}
		// We do NOT want to start loading a new rocket automatically on the server.
		if (IsPingCompEnabled() && PlayerPawn(Owner) != None)
		{
			LockedTarget = None;
			// Use GotoState('Idle') instead of Finish() because Finish() might call Fire(),
			// which is empty/returns in our override, causing the server to get stuck in FireRockets state.
			GotoState('Idle');
			return;
		}

		if ( !bRotated && (AmmoType.AmmoAmount > 0) ) 
		{	
			PlayLoading(1.5,0);
			RocketsLoaded = 1;
			bRotated = true;
			return;
		}
		LockedTarget = None;
		Finish();
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
		carried = 'UT_Eightball';
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

state NormalFire
{

	function bool SplashJump()
	{
		return true;
	}

	function Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		if (bChangeWeapon)
		{
			RocketsLoaded = 0;
			bRotated = false;
			GotoState('DownWeapon');
		}
	}

	function AnimEnd()
	{
		if ( bRotated )
		{
			bRotated = false;
			PlayLoading(1.1, RocketsLoaded);
		}
		else
		{
			if ( RocketsLoaded == 6 )
			{
				GotoState('FireRockets');
				return;
			}
			RocketsLoaded++;
			AmmoType.UseAmmo(1);
			if (pawn(Owner).bAltFire!=0) bTightWad=True;
			// Lock-on check removed: you should only lock on before you fire or load
			bPointing = true;
			Owner.MakeNoise(0.6 * Pawn(Owner).SoundDampening);		
			RotateRocket();
		}
	}

	function BeginState()
	{
		bFireLoad = True;
		RocketsLoaded = 1;
		RotateRocket();
	}

	function RotateRocket()
	{
		if ( PlayerPawn(Owner) == None )
		{
			if ( FRand() > 0.33 )
				Pawn(Owner).bFire = 0;
			if ( Pawn(Owner).bFire == 0 )
			{
	 			GoToState('FireRockets');
				return;
			}
		}
		if ( AmmoType.AmmoAmount <= 0 ) 
		{
			GotoState('FireRockets');
			return;
		}
		if ( AmmoType.AmmoAmount == 1 )
			Owner.PlaySound(Misc2Sound, SLOT_None, Pawn(Owner).SoundDampening); 
		PlayRotating(RocketsLoaded-1);
		bRotated = true;
	}
}

state AltFiring
{
	function Tick( float DeltaTime )
	{
		if (bChangeWeapon)
		{
			RocketsLoaded = 0;
			bRotated = false;
			GotoState('DownWeapon');
		}

		Super.Tick(DeltaTime);
	}
	
	function AnimEnd()
	{
		if ( bRotated )
		{
			bRotated = false;
			PlayLoading(1.1, RocketsLoaded);
		}
		else
		{
			if ( RocketsLoaded == 6 )
			{
				GotoState('FireRockets');
				return;
			}
			RocketsLoaded++;
			AmmoType.UseAmmo(1);		
			if ( (PlayerPawn(Owner) == None) && ((FRand() > 0.5) || (Pawn(Owner).Enemy == None)) )
				Pawn(Owner).bAltFire = 0;
			bPointing = true;
			Owner.MakeNoise(0.6 * Pawn(Owner).SoundDampening);		
			RotateRocket();
		}
	}

	function RotateRocket()
	{
		if (AmmoType.AmmoAmount<=0)
		{ 
			GotoState('FireRockets');
			return;
		}		
		PlayRotating(RocketsLoaded-1);
		bRotated = true;
	}

	function BeginState()
	{
		RocketsLoaded = 1;
		bFireLoad = False;
		RotateRocket();
	}

Begin:
	bLockedOn = False;
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
			// Don't check for bFire/bAltFire to trigger server-side firing
			bPointing = false;
			
			// Fix: Check for empty ammo and switch weapon
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

	function Timer()
	{
		NewTarget = CheckTarget();
		if ( NewTarget == OldTarget )
		{
			LockedTarget = NewTarget;
			If (LockedTarget != None) 
			{
				bLockedOn=True;			
				Owner.MakeNoise(Pawn(Owner).SoundDampening);
				Owner.PlaySound(Misc1Sound, SLOT_None,Pawn(Owner).SoundDampening);
				if ( (Pawn(LockedTarget) != None) && (FRand() < 0.7) )
					Pawn(LockedTarget).WarnTarget(Pawn(Owner), ProjectileSpeed, vector(Pawn(Owner).ViewRotation));	
				if ( bPendingLock )
				{
					OldTarget = NewTarget;
					Pawn(Owner).bFire = 0;
					bFireLoad = True;
					RocketsLoaded = 1;
					GotoState('FireRockets', 'Begin');
					return;
				}
			}
		}
		else if( (OldTarget != None) && (NewTarget == None) ) 
		{
			Owner.PlaySound(Misc2Sound, SLOT_None,Pawn(Owner).SoundDampening);
			bLockedOn = False;
		}
		else 
		{
			LockedTarget = None;
			bLockedOn = False;
		}
		OldTarget = NewTarget;
		bPendingLock = false;
	}

Begin:
	if (Pawn(Owner).bFire!=0) Fire(0.0);
	if (Pawn(Owner).bAltFire!=0) AltFire(0.0);	
	bPointing=False;
	if (AmmoType.AmmoAmount<=0) 
		Pawn(Owner).SwitchToBestWeapon();  //Goto Weapon that has Ammo
	PlayIdleAnim();
	OldTarget = CheckTarget();
	SetTimer(1.25,True);
	LockedTarget = None;
	bLockedOn = False;
PendingLock:
	if ( bPendingLock )
		bPointing = true;
	if ( TimerRate <= 0 )
		SetTimer(1.0, true);
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select',GetWeaponSettings().EightballSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().EightballDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().EightballDownAnimSpeed(), TweenTime);
}

simulated function PlayLoading(float rate, int num)
{
	if (Owner == None)
		return;
	
	PlayAnim(LoadAnim[num],, 0.05);
	
	if (Role < ROLE_Authority && IsPingCompEnabled() && PlayerPawn(Owner) != None)
		ServerPlayLoadSound(num, false);
	else
		Owner.PlayOwnedSound(CockingSound, SLOT_None, Pawn(Owner).SoundDampening);
}

simulated function PlayRotating(int num)
{
	if (Owner == None)
		return;
	
	PlayAnim(RotateAnim[num],, 0.05);
	
	if (Role < ROLE_Authority && IsPingCompEnabled() && PlayerPawn(Owner) != None)
		ServerPlayLoadSound(num, true);
	else
		Owner.PlayOwnedSound(Misc3Sound, SLOT_None, 0.1 * Pawn(Owner).SoundDampening);
}

// =========================================================================
// Fixes for Client Side State Management
// =========================================================================

state ClientFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function Tick(float DeltaTime)
	{
		if ( (Pawn(Owner).bFire == 0) || (Ammotype.AmmoAmount <= 0) )
			FiringRockets();
	}
	
	simulated function AnimEnd()
	{
		if ( !bCanClientFire || (Pawn(Owner) == None) )
			GotoState('');
		else if ( bClientDone )
		{
			PlayLoading(1.5,0);
			GotoState('ClientReload');
		}
		else if ( bRotated )
		{
			PlayLoading(1.1, ClientRocketsLoaded);
			bRotated = false;
			ClientRocketsLoaded++;
		}
		else
		{
			if ( bInstantRocket || (ClientRocketsLoaded == 6) )
			{
				FiringRockets();
				return;
			}
			Enable('Tick');
			PlayRotating(ClientRocketsLoaded - 1);
			bRotated = true;
			if (AmmoType != None)
				AmmoType.AmmoAmount--;
		}
	}

	simulated function BeginState()
	{
		bFireLoad = true;
		
		// Notify server to stop lock-on checking - can only lock before loading
		if (Role < ROLE_Authority && IsPingCompEnabled())
			ServerStartedLoading();

		if (AmmoType != None)
        	AmmoType.AmmoAmount--;
		
		if ( bInstantRocket )
		{
			ClientRocketsLoaded = 1;
			FiringRockets();
		}
		else
		{
			ClientRocketsLoaded = 1;
			PlayRotating(ClientRocketsLoaded - 1);
			bRotated = true;
		}
	}

	simulated function EndState()
	{
		ClientRocketsLoaded = 0;
		bClientDone = false;
		bRotated = false;
	}
}

state ClientAltFiring
{
	simulated function bool ClientFire(float Value) { return false; }
	simulated function bool ClientAltFire(float Value) { return false; }

	simulated function Tick(float DeltaTime)
	{
		if ( (Pawn(Owner).bAltFire == 0) || (Ammotype.AmmoAmount <= 0) )
			FiringRockets();
	}
	
	simulated function AnimEnd()
	{
		if ( !bCanClientFire || (Pawn(Owner) == None) )
			GotoState('');
		else if ( bClientDone )
		{
			PlayLoading(1.5,0);
			GotoState('ClientReload');
		}
		else if ( bRotated )
		{
			PlayLoading(1.1, ClientRocketsLoaded);
			bRotated = false;
			ClientRocketsLoaded++;
		}
		else
		{
			if ( ClientRocketsLoaded == 6 )
			{
				FiringRockets();
				return;
			}
			Enable('Tick');
			PlayRotating(ClientRocketsLoaded - 1);
			bRotated = true;
			if (AmmoType != None)
				AmmoType.AmmoAmount--;
		}
	}

	simulated function BeginState()
	{
		bFireLoad = false;
		
		// Notify server to stop lock-on checking - can only lock before loading
		if (Role < ROLE_Authority && IsPingCompEnabled())
			ServerStartedLoading();
		
		if (AmmoType != None)
        	AmmoType.AmmoAmount--;

		ClientRocketsLoaded = 1;
		PlayRotating(ClientRocketsLoaded - 1);
		bRotated = true;
	}

	simulated function EndState()
	{
		ClientRocketsLoaded = 0;
		bClientDone = false;
		bRotated = false;
	}
}

state ClientReload
{
	simulated function bool ClientFire(float Value)
	{
		bForceFire = bForceFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceFire;
	}

	simulated function bool ClientAltFire(float Value)
	{
		bForceAltFire = bForceAltFire || ( bCanClientFire && (Pawn(Owner) != None) && (AmmoType.AmmoAmount > 0) );
		return bForceAltFire;
	}

	simulated function AnimEnd()
	{
		if ( bCanClientFire && (PlayerPawn(Owner) != None) && (AmmoType.AmmoAmount > 0) )
		{
			if ( bForceFire || (Pawn(Owner).bFire != 0) )
			{
				Global.ClientFire(0);
				return;
			}
			else if ( bForceAltFire || (Pawn(Owner).bAltFire != 0) )
			{
				Global.ClientAltFire(0);
				return;
			}
		}
		
		// Switch weapon if out of ammo
		if ( (AmmoType == None) || (AmmoType.AmmoAmount <= 0) )
		{
			GotoState('');
			if ( Pawn(Owner) != None )
				Pawn(Owner).SwitchToBestWeapon();
			return;
		}
		
		GotoState('');
		Global.AnimEnd();
	}

	simulated function EndState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}

	simulated function BeginState()
	{
		bForceFire = false;
		bForceAltFire = false;
	}
}

defaultproperties {
}