// ===============================================================
// Stats.ST_ImpactHammer: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class ST_ImpactHammer extends ImpactHammer;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;
// Predicted self-knockback (bbPlayer.IGPlus_PredictHammer): the charge is
// timed on the owner's moves and the release happens on its move, on both
// machines, with its push at the end of that move.
var float IGPlus_ChargeTS;
var float IGPlus_ReleaseTS;
var bool IGPlus_bQueuePush;
// A bring-up is up on the owner's moves at IGPlus_ReadyTS on both machines
// (stock: the server's select end, a round trip before our client may charge).
// Fire held during it charges from then, a tap goes off then, as stock does at
// its select end (IGPlus_MoveEnd).
var float IGPlus_ReadyTS;
var bool IGPlus_bPressQueued;

replication
{
	reliable if (Role == ROLE_Authority)
		IGPlus_ClientReadyAt;
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

simulated function Tick(float deltaTime)
{	// This fixes the really annoying issue regarding IH sound
	if (Pawn(Owner) == None || Pawn(Owner).Weapon != Self)
		AmbientSound = None;
}

// The owner's moves drive this hammer: theirs on the server, ours on the client.
simulated function bool IGPlus_OnMoves() {
	local bbPlayer P;

	P = bbPlayer(Owner);
	if (P == None || P.IGPlus_PredictHammer() == false)
		return false;
	if (Level.NetMode == NM_Client)
		return Role < ROLE_Authority;
	return P.RemoteRole == ROLE_AutonomousProxy;
}

simulated function float IGPlus_SelectTime() {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	if (WS == None)
		return class'WeaponSettingsRepl'.default.HammerSelectTime;
	return class'bbPlayer'.static.IGPlus_DetEffectiveAnimTime(WS.HammerSelectTime, WS.default.HammerSelectTime);
}

function BringUp() {
	Super.BringUp();
	if (bbPlayer(Owner) == None)
		return;
	IGPlus_ReadyTS = bbPlayer(Owner).CurrentTimeStamp + IGPlus_SelectTime();
	IGPlus_bPressQueued = false;
	if (bbPlayer(Owner).RemoteRole == ROLE_AutonomousProxy)
		IGPlus_ClientReadyAt(IGPlus_ReadyTS);
}

simulated function IGPlus_ClientReadyAt(float TS) {
	IGPlus_ReadyTS = TS;
}

function Fire(float Value) {
	// Not up on the owner's moves yet: IGPlus_MoveEnd charges it then.
	if (IGPlus_OnMoves() && bbPlayer(Owner).CurrentTimeStamp < IGPlus_ReadyTS)
		return;
	Super.Fire(Value);
}

simulated function bool ClientFire(float Value) {
	if (Level.NetMode == NM_Client && IGPlus_OnMoves()) {
		// Not before IGPlus_ReadyTS (IGPlus_MoveEnd charges it then), and only
		// with fire held: no charge from the server's late select end.
		if (Level.TimeSeconds < IGPlus_ReadyTS || Pawn(Owner).bFire == 0)
			return false;
		if (IsInState('ClientFiring'))
			return true;
		bCanClientFire = true;
	}
	return Super.ClientFire(Value);
}

simulated function bool IGPlus_Idle() {
	if (Level.NetMode == NM_Client)
		return !(IsInState('ClientFiring') || IsInState('ClientFireBlast') || IsInState('ClientAltFiring') || IsInState('ClientDown'));
	return !(IsInState('Firing') || IsInState('FireBlast') || IsInState('AltFiring') || IsInState('DownWeapon') || bChangeWeapon);
}

// Both machines, at the end of each of the owner's moves (bbPlayer), with
// fire as the move carries it: a bring-up charges from IGPlus_ReadyTS if fire
// was held during it, and a let-go releases.
simulated function IGPlus_MoveEnd(float TS, bool bHeld) {
	if (IGPlus_OnMoves() == false)
		return;
	if (TS < IGPlus_ReadyTS) {
		if (bHeld)
			IGPlus_bPressQueued = true;
		return;
	}
	if ((bHeld || IGPlus_bPressQueued) && IGPlus_Idle()) {
		bWeaponUp = true;
		if (Level.NetMode == NM_Client) {
			bCanClientFire = true;
			Super.ClientFire(0);
		} else {
			Super.Fire(0);
		}
	}
	IGPlus_bPressQueued = false;
	if (bHeld == false) {
		if (Level.NetMode == NM_Client)
			IGPlus_ClientRelease(TS);
		else
			IGPlus_ServerRelease(TS);
	}
}

state ClientActive
{
	simulated function BeginState()
	{
		Super.BeginState();
		// Our own guess until the server's IGPlus_ClientReadyAt arrives.
		if (IGPlus_ReadyTS <= Level.TimeSeconds)
			IGPlus_ReadyTS = Level.TimeSeconds + IGPlus_SelectTime();
		IGPlus_bPressQueued = false;
	}
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
				Enable('Tick');
				T.NeedActivate();
			}
		}
	}

	simulated function BeginState()
	{
		AmbientSound = None; // kill the charge hum; the stock Disable('Tick') would otherwise leave it
		Super.BeginState();
	}
}

simulated function ClientWeaponEvent(name EventType) {
	if (EventType == 'FireBlast' && GetStateName() != 'ClientFireBlast') {
		PlayFiring();
		GotoState('ClientFireBlast');
	}
}

state ClientFiring {
	simulated function BeginState() {
		ChargeSize = 0.0;
		IGPlus_ChargeTS = Level.TimeSeconds;
		// This move ends here, so the server starts the charge on it too.
		if (bbPlayer(Owner) != None && bbPlayer(Owner).IGPlus_PredictHammer())
			bbPlayer(Owner).bForcePacketSplit = true;
	}

	simulated function Tick(float Delta) {
		global.Tick(Delta);

		if (Owner == none || Owner.IsA('bbPlayer') == false)
			return;

		ChargeSize += 0.75*Delta;

		// Released on the move instead (IGPlus_ClientRelease).
		if (bbPlayer(Owner).IGPlus_PredictHammer())
			return;

		if (Pawn(Owner).bFire == 0) {
			ClientTraceFire(0);
			PlayFiring();
			GotoState('ClientFireBlast');
		}
	}
}

simulated function ClientTraceFire(float Accuracy) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local bbPlayer P;
	local WeaponSettingsRepl WS;
	local vector Momentum;

	P = bbPlayer(Owner);
	WS = GetWeaponSettings();
	if (P == none || WS == none)
		return;

	GetAxes(P.ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + vect(0,0,1)*P.EyeHeight;
	AdjustedAim = P.ViewRotation;
	EndTrace = StartTrace + 120.0 * vector(AdjustedAim);
	Other = P.NN_TraceShot(HitLocation, HitNormal, EndTrace, StartTrace, P);

	if ((Other == Level) || (Other != none && Other.IsA('Mover'))) {
		P.bForcePacketSplit = true;
		Momentum = WS.HammerSelfMomentum * -69000.0 * FClamp(ChargeSize, 1.0, 1.5) * X;
		if (P.Physics == PHYS_Walking)
			Momentum.Z = FMax(Momentum.Z, 0.4 * VSize(Momentum));
		Momentum = Momentum * 0.6 / P.Mass;
		P.AddVelocity(Momentum);
	}
}

// Client: fire was let go in the move just made (bbPlayer.xxReplicateMove).
// The push off a wall lands at the end of this move, where the server's does.
simulated function IGPlus_ClientRelease(float TS) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local bbPlayer P;
	local WeaponSettingsRepl WS;
	local vector Push;

	P = bbPlayer(Owner);
	WS = GetWeaponSettings();
	if (IsInState('ClientFiring') == false || P == none || WS == none || P.IGPlus_PredictHammer() == false)
		return;

	ChargeSize = 0.75 * (TS - IGPlus_ChargeTS);
	GetAxes(P.ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + vect(0,0,1)*P.EyeHeight;
	AdjustedAim = P.ViewRotation;
	EndTrace = StartTrace + 120.0 * vector(AdjustedAim);
	Other = P.NN_TraceShot(HitLocation, HitNormal, EndTrace, StartTrace, P);
	if ((Other == Level) || (Other != none && Other.IsA('Mover'))) {
		Push = WS.HammerSelfMomentum * -69000.0 * FClamp(ChargeSize, 1.0, 1.5) * X;
		P.IGPlus_SKQueueHammer(TS, Push * 0.6 / P.Mass);
	}
	// Ends here, so the server releases on this very move too.
	P.bForcePacketSplit = true;
	PlayFiring();
	GotoState('ClientFireBlast');
}

// Server: the same release, on the owner's move that let go of fire
// (bbPlayer.IGPlus_ApplyServerMove).
function IGPlus_ServerRelease(float TS) {
	local bbPlayer P;

	P = bbPlayer(Owner);
	if (IsInState('Firing') == false || P == none || P.RemoteRole != ROLE_AutonomousProxy || P.IGPlus_PredictHammer() == false)
		return;

	ChargeSize = 0.75 * (TS - IGPlus_ChargeTS);
	IGPlus_ReleaseTS = TS;
	IGPlus_bQueuePush = true;
	TraceFire(0);
	IGPlus_bQueuePush = false;
	PlayFiring();
	GoToState('FireBlast');
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Pawn PawnOwner;
	local vector Momentum;

	PawnOwner = Pawn(Owner);

	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None))
		return;

	ChargeSize = FMin(ChargeSize, 1.5);
	if ( (Other == Level) || Other.IsA('Mover') )
	{
		ChargeSize = FMax(ChargeSize, 1.0);
		if ( VSize(HitLocation - Owner.Location) < 80 )
			Spawn(class'ImpactMark',,, HitLocation+HitNormal, Rotator(HitNormal));
		Owner.TakeDamage(
			WImp.WeaponSettings.HammerSelfDamage,
			PawnOwner,
			HitLocation,
			vect(0,0,0),
			MyDamageType
		);

		// On the owner's move timeline: the push lands at the end of the
		// release's move, as on the owner's screen (IGPlus_ClientRelease).
		if (IGPlus_bQueuePush && bbPlayer(Owner) != None) {
			Momentum = GetWeaponSettings().HammerSelfMomentum * -69000.0 * ChargeSize * X;
			bbPlayer(Owner).IGPlus_SKQueueHammer(IGPlus_ReleaseTS, Momentum * 0.6 / PawnOwner.Mass);
		} else {
			// Manually do what PawnOwner.AddVelocity from PawnOwner.TakeDamage would do.
			// Cant use AddVelocity because it takes an additional round trip.
			// Client does the same manual modification of PawnOwner.Velocity in parallel, so it should all work out.
			Momentum = GetWeaponSettings().HammerSelfMomentum * -69000.0 * ChargeSize * X;
			if (PawnOwner.Physics == PHYS_Walking)
				Momentum.Z = FMax(Momentum.Z, 0.4 * VSize(Momentum));
			Momentum = Momentum * 0.6 / PawnOwner.Mass;
			if (PawnOwner.Physics == PHYS_Walking)
				PawnOwner.SetPhysics(PHYS_Falling);
			if ((PawnOwner.Velocity.Z > 380) && (Momentum.Z > 0))
				Momentum.Z *= 0.5;
			PawnOwner.Velocity += Momentum;
		}
	}
	if ( Other != Level )
	{
		if ( Other.bIsPawn && (VSize(HitLocation - Owner.Location) > 90) )
			return;

		Momentum = 66000.0 * ChargeSize * X;
		if (Other.bIsPawn)
			Momentum *= WImp.WeaponSettings.HammerMomentum;

		Other.TakeDamage(
			WImp.WeaponSettings.HammerDamage * ChargeSize,
			PawnOwner,
			HitLocation,
			Momentum,
			MyDamageType
		);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
	}
}

function TraceAltFire()
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local Projectile P;
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
	AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, AimError, False, False);
	EndTrace = StartTrace + 180 * vector(AdjustedAim);
	Other = PawnOwner.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	ProcessAltTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);

	// push aside projectiles
	ForEach VisibleCollidingActors(class'Projectile', P, 550, Owner.Location)
		if ( ((P.Physics == PHYS_Projectile) || (P.Physics == PHYS_Falling))
			&& (Normal(P.Location - Owner.Location) Dot X) > 0.9 )
		{
			P.speed = VSize(P.Velocity);
			if ( P.Velocity Dot Y > 0 )
				P.Velocity = P.Speed * Normal(P.Velocity + (750 - VSize(P.Location - Owner.Location)) * Y);
			else
				P.Velocity = P.Speed * Normal(P.Velocity - (750 - VSize(P.Location - Owner.Location)) * Y);
		}
}

function ProcessAltTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local vector realLoc;
	local float scale;
	local Pawn PawnOwner;
	local vector Momentum;

	if ( (Other == None) || (Other == Owner) || (Other == self) || (Owner == None) )
		return;

	PawnOwner = Pawn(Owner);

	realLoc = Owner.Location + CalcDrawOffset();
	scale = VSize(realLoc - HitLocation)/180;
	if ( (Other == Level) || Other.IsA('Mover') )
	{
		Owner.TakeDamage(
			WImp.WeaponSettings.HammerAltSelfDamage * scale,
			Pawn(Owner),
			HitLocation,
			WImp.WeaponSettings.HammerAltSelfMomentum * -40000.0 * X * scale,
			MyDamageType
		);
	}
	else
	{
		Momentum = 30000.0 * X * scale;
		if (Other.bIsPawn)
			Momentum *= WImp.WeaponSettings.HammerAltMomentum;

		Other.TakeDamage(
			WImp.WeaponSettings.HammerAltDamage * scale,
			Pawn(Owner),
			HitLocation,
			Momentum,
			MyDamageType
		);
		if ( !Other.bIsPawn && !Other.IsA('Carcass') )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9);
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
		carried = 'ImpactHammer';
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
		PlayAnim('Select',GetWeaponSettings().HammerSelectAnimSpeed(),0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);	
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().HammerDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().HammerDownAnimSpeed(), TweenTime);
}

state Firing
{
	function AltFire(float F) 
	{
	}

	function Tick( float DeltaTime )
	{
		local Pawn P;
		local Rotator EnemyRot;
		local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
		local actor HitActor;
		local ST_ProjectileDummy ProjDummy;
		local Actor ActualTarget;

		if ( bChangeWeapon )
			GotoState('DownWeapon');

		if (  Bot(Owner) != None )
		{
			if ( Bot(Owner).Enemy == None )
				Bot(Owner).bFire = 0;
			else
				Bot(Owner).bFire = 1;
		}
		P = Pawn(Owner);
		if ( P == None ) 
		{
			AmbientSound = None;
			GotoState('');
			return;
		}
		else if( P.bFire==0 ) 
		{
			TraceFire(0);
			PlayFiring();
			GoToState('FireBlast');
			return;
		}

		ChargeSize += 0.75 * DeltaTime;

		Count += DeltaTime;
		if ( Count > 0.2 )
		{
			Count = 0;
			Owner.MakeNoise(1.0);
		}
		if (ChargeSize > 1) 
		{
			if ( !P.IsA('PlayerPawn') && (P.Enemy != None) )
			{
				EnemyRot = Rotator(P.Enemy.Location - P.Location);
				EnemyRot.Yaw = EnemyRot.Yaw & 65535;
				if ( (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) > 8000)
					&& (abs(EnemyRot.Yaw - (P.Rotation.Yaw & 65535)) < 57535) )
					return;
				GetAxes(EnemyRot,X,Y,Z);
			}
			else
				GetAxes(P.ViewRotation, X, Y, Z);
			StartTrace = P.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
			if ( (Level.NetMode == NM_Standalone) && P.IsA('PlayerPawn') )
				EndTrace = StartTrace + 25 * X; 
			else
				EndTrace = StartTrace + 60 * X; 

			if (GetWeaponSettings().bEnablePingCompensation) { // Ping compensation logic

				HitActor = P.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
				
				if ( (HitActor != None) && (HitActor != P) ) // Basic valid hit check
				{
					// Is it a Pawn
					if ( HitActor.bIsPawn )
					{
						ProcessTraceHit(HitActor, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
						PlayFiring();
						GoToState('FireBlast');
					}
					// Is it the ST_ProjectileDummy
					else if ( HitActor.IsA('ST_ProjectileDummy') )
					{
						ProjDummy = ST_ProjectileDummy(HitActor);
						ActualTarget = ProjDummy.Actual;

						if ( ActualTarget != None && ActualTarget.IsA('TranslocatorTarget') )
						{
							ProcessTraceHit(ActualTarget, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
							PlayFiring();
							GoToState('FireBlast');
						}
					}
					// Is it a direct TranslocatorTarget hit (not through dummy)
					else if ( HitActor.IsA('TranslocatorTarget') )
					{
						ProcessTraceHit(HitActor, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
						PlayFiring();
						GoToState('FireBlast');
					}
				}
			}
			else { // Regular base game trace
				
				HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

				if ( (HitActor != None) && (HitActor.DrawType == DT_Mesh) )
				{
					ProcessTraceHit(HitActor, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
						PlayFiring();
					GoToState('FireBlast');
				}
			}
		}
	}

	function BeginState()
	{
		ChargeSize = 0.0;
		Count = 0.0;
		// The owner's press move (IGPlus_ServerRelease).
		if (bbPlayer(Owner) != None)
			IGPlus_ChargeTS = bbPlayer(Owner).CurrentTimeStamp;
	}

	function EndState()
	{
		Super.EndState();
		AmbientSound = None;
	}

Begin:
	FinishAnim();
	AmbientSound = TensionSound;
	SoundVolume = 255*Pawn(Owner).SoundDampening;		
	LoopAnim('Shake', 0.9);
}

defaultproperties {
}
