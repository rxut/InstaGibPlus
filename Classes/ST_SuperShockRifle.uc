// ===============================================================
// Stats.ST_SuperShockRifle: SuperShockRifle with ping compensation
// ===============================================================

class ST_SuperShockRifle extends SuperShockRifle;

var IGPlus_WeaponImplementation WImp;

var WeaponSettingsRepl WSettings;

var float yMod;

var float NextDetFireTS;
// The time the last shot was due, for the shot clock the server corrects
// (bbPlayer.IGPlus_DetSyncShotClock).
var float DetShotDueTS;

// Server: this shot is a deterministic one (DeterministicTraceFire), and
// where this shot's beam starts (set by both trace functions).
var bool IGPlus_bDetShot;
var vector IGPlus_DetSmokeLocation;

// The instagib rifle has no range limit: a clear line across the whole map is
// a hit. Stock stops the beam at 10000.
const IGPLUS_BEAM_RANGE = 100000.0;

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
	return WS != None && WS.bEnablePingCompensation;
}

simulated function bool IsDetActive() {
	return Level.NetMode != NM_Standalone
		&& IsPingCompEnabled()
		&& bbPlayer(Owner) != none;
}

// One owner's deterministic state must never transfer to the next
// (dropped weapons are reused as pickups: SpawnCopy returns self).
simulated function DetResetDeterministicState() {
	NextDetFireTS = 0.0;
	DetShotDueTS = 0.0;
}

function GiveTo(Pawn Other) {
	DetResetDeterministicState();
	Super.GiveTo(Other);
}

function DropFrom(vector StartLocation) {
	DetResetDeterministicState();
	Super.DropFrom(StartLocation);
}

// The NewNet rifle refires when its fire anim is over, and holds a weapon
// switch for the same time. That is the 0.05 tween plus
// (frames-1)/(seqRate*playRate) of sshockm's Fire1, 10 frames at 22 a second:
// 1.07 s for a player. Both buttons play Fire1. Stock's own rifle loops the
// anim and refires once a loop with the button held, 1.14 s.
simulated function float ShotInterval() {
	return FClamp(0.05 + 9.0 / (22.0 * (0.20 + 0.20 * FireAdjust)), 0.05, 2.0);
}

// Deterministic step processing, called from bbPlayer.IGPlus_DetProcessStep.
// Returns true to suppress legacy fire, even if no shot is produced.
// Both buttons fire the same beam. The rifle uses no ammo (stock Fire never
// calls UseAmmo).
simulated function bool DetProcessStep(
	float StepTS,
	rotator StepView,
	vector StepLoc,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	bool bServerSide,
	optional bool bClientPredictedStep
) {
	local bbPlayer BP;
	local float Interval;

	if (!bClientPredictedStep)
		return true;

	BP = bbPlayer(Owner);
	if (BP == none)
		return true;
	if (BP.IGPlus_DetIntervalShotDue(
			StepTS, bFireHeld || bAltHeld, false, bForceFire || bForceAlt, false,
			ShotInterval(), ShotInterval(), NextDetFireTS, Interval) == 0)
		return true;

	// Holster hold equals the fire anim, whose length is the interval.
	BP.IGPlus_DetNoteShot(StepTS, Interval);
	if (bServerSide)
		HandleDetServerFire(StepView, StepLoc);
	else
		HandleDetClientFire(StepView, StepLoc);

	DetShotDueTS = NextDetFireTS;
	NextDetFireTS = class'bbPlayer'.static.IGPlus_DetNextShotTS(StepTS, NextDetFireTS, Interval);
	return true;
}

simulated function HandleDetClientFire(rotator StepView, vector StepLoc) {
	local bbPlayer BP;

	BP = bbPlayer(Owner);

	Instigator = BP;
	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		BP.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();
	// As stock's ClientFire: the flash and the view shake.
	BP.ClientInstantFlash(InstFlash, InstFog);
	BP.ShakeView(ShakeTime, ShakeMag, ShakeVert);

	PlayFiring();
	// Always, with no client setting. With ping compensation off no shot is
	// deterministic, and the beam comes from the server (TraceFire).
	ClientTraceFire(StepView, StepLoc);
}

function HandleDetServerFire(rotator StepView, vector StepLoc) {
	local Pawn PawnOwner;

	PawnOwner = Pawn(Owner);

	Instigator = PawnOwner;
	bPointing = true;
	if (bRapidFire || (FiringSpeed > 0))
		PawnOwner.PlayRecoil(FiringSpeed);
	if (Affector != none)
		Affector.FireEffect();

	// The shooter's client played the sound, so the others get it too.
	PlayOwnedSound(FireSound, SLOT_None, PawnOwner.SoundDampening*4.0);
	// Mid-switch shot: no fire anim, or it hijacks the holster schedule
	// (see ST_ShockRifle.HandleDetServerFire). One pass, not the stock loop:
	// the server's weapon stays in Idle, where nothing ends a loop.
	if (!bChangeWeapon && !IsInState('DownWeapon'))
		PlayAnim('Fire1', 0.20 + 0.20 * FireAdjust, 0.05);

	// Traced once the tick's packets are all read, in the order the shots
	// were fired (bbPlayer.IGPlus_QueueShot). Now, where that can't be done.
	if (bbPlayer(PawnOwner) == None || bbPlayer(PawnOwner).IGPlus_QueueShot(self, StepView, StepLoc) == false)
		DeterministicTraceFire(StepView, StepLoc);
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;		// Find master :D
}

simulated function yModInit() {
	if (PlayerPawn(Owner) == None)
		return;

	yMod = PlayerPawn(Owner).Handedness;
	if (yMod != 2.0)
		yMod *= Default.FireOffset.Y;
	else
		yMod = 0;
}

// The deterministic step decides the shot. A click only has to be let through
// to it (PlayerPawn.Fire turns our answer into bJustFired).
simulated function bool DetClientMayFire() {
	local TournamentPlayer TP;

	if (!bCanClientFire || bChangeWeapon)
		return false;
	TP = TournamentPlayer(Owner);
	if (TP == none)
		return false;
	if ((TP.PendingWeapon != none && TP.PendingWeapon != self)
		|| (TP.ClientPending != none && TP.ClientPending != self))
		return false;
	return true;
}

simulated function bool ClientFire(float Value) {
	if (IsDetActive() && Owner.Role == ROLE_AutonomousProxy)
		return DetClientMayFire();
	return Super.ClientFire(Value);
}

simulated function bool ClientAltFire(float Value) {
	if (IsDetActive() && Owner.Role == ROLE_AutonomousProxy)
		return DetClientMayFire();
	return Super.ClientAltFire(Value);
}

// Client: our own beam and ring, at once. The trace tests the other players
// where the server will test them (bbPlayer.IGPlus_ClientShotTrace).
// The server sends this shot's beam to everyone but us (ProcessTraceHit).
simulated function ClientTraceFire(rotator AimRot, vector AimLoc) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local vector SmokeOffset, HitOffset;
	local class<WeaponEffect> Effect;
	local Actor Other;
	local bbPlayer bbP;
	local WeaponSettingsRepl WS;
	local IGPlus_WeaponImplementationBase WB;

	bbP = bbPlayer(Owner);
	if (bbP == None)
		return;
	// The server's hitbox rule: the reduced one when its setting is on.
	WS = GetWeaponSettings();
	if (WS != None && WS.ShockBeamUseReducedHitbox)
		WB = bbP.IGPlus_GetWeaponImplementationBase();

	yModInit();
	GetAxes(AimRot, X, Y, Z);
	// The hit line starts at the eye, as the NewNet rifle's and the sniper's
	// do, so it is the crosshair's line. Stock starts it at the gun, about
	// 10 uu below and beside the crosshair. No walk bob: the server has none.
	// The eye height goes to the server with the shot, so both trace from
	// the same one (bbPlayer.IGPlus_ClientShotEye).
	StartTrace = AimLoc + bbP.IGPlus_ClientShotEye() * vect(0,0,1);
	EndTrace = StartTrace + IGPLUS_BEAM_RANGE * X;
	// The drawn beam starts as the NewNet rifle's does: at the gun under our
	// camera (real eye height and walk bob).
	SmokeOffset = class'NN_WeaponFunctions'.static.IGPlus_CalcDrawOffset(bbP, self)
		+ (FireOffset.X + 20) * X + yMod * Y + FireOffset.Z * Z;

	// Against the other players where the server will test them, and the
	// hit point on the body while it stands there: afterwards the others are
	// parked far outside the map again (bbPlayer.IGPlus_ClientShotTrace).
	Other = bbP.IGPlus_ClientShotTrace(HitLocation, HitNormal, HitOffset, EndTrace, StartTrace, WB);
	if (Other == None) {
		HitLocation = EndTrace;
		HitNormal = -X;
		HitOffset = HitLocation;
	}
	// The hit sound and marker now, where Hit Source is Client, and our
	// verdict for the server's count (bbPlayer.IGPlus_ClientShotVerdict).
	bbP.IGPlus_ClientShotVerdict(Other, HitDamage, MyDamageType, false);

	// Hit Effect Source on Server: on a player the beam shows now and the
	// ring only once the server has counted the hit (bbPlayer.IGPlus_RingHold).
	// A ring on a wall needs no answer and shows now. A ring that still
	// waits from the shot before is dropped: the server did not count that
	// hit, and its answer to this shot must not bring that ring back.
	Effect = class'SuperShockRifleWeaponEffect';
	bbP.IGPlus_RingVictimPRI = None;
	if (Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None
		&& bbP.Settings != None && bbP.Settings.HitEffectSource == HESRC_Server) {
		Effect = class'SuperShockRifleBeamEffect';
		bbP.IGPlus_RingHold(Pawn(Other), AimLoc + SmokeOffset, SmokeOffset, HitLocation, HitOffset, HitNormal);
	}
	bbP.SendWeaponEffect(
		Effect,
		bbP.PlayerReplicationInfo,
		AimLoc + SmokeOffset,
		SmokeOffset,
		Other,
		HitLocation,
		HitOffset,
		HitNormal);
}

// Not deterministic (a bot, a standalone game, ping compensation off): stock's
// ShockRifle.TraceFire with the rifle's own range.
function TraceFire(float Accuracy) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Actor Other;
	local Pawn PawnOwner;

	if (Role == ROLE_Authority && Level.NetMode != NM_Client && IsDetActive())
		return;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;

	Owner.MakeNoise(PawnOwner.SoundDampening);
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	if (PlayerPawn(Owner) != None)
		StartTrace = Owner.Location + PawnOwner.EyeHeight * vect(0,0,1); // as a deterministic shot
	else
		StartTrace = Owner.Location + CalcDrawOffset() + FireOffset.Y * Y + FireOffset.Z * Z;
	EndTrace = StartTrace + Accuracy * (FRand() - 0.5) * Y * 1000
		+ Accuracy * (FRand() - 0.5) * Z * 1000;

	if (bBotSpecialMove && (Tracked != None)
		&& (((Owner.Acceleration == vect(0,0,0)) && (VSize(Owner.Velocity) < 40))
			|| (Normal(Owner.Velocity) Dot Normal(Tracked.Velocity) > 0.95))) {
		EndTrace += IGPLUS_BEAM_RANGE * Normal(Tracked.Location - StartTrace);
	} else {
		AdjustedAim = PawnOwner.AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
		EndTrace += IGPLUS_BEAM_RANGE * vector(AdjustedAim);
	}

	Tracked = None;
	bBotSpecialMove = false;

	Other = PawnOwner.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);
	if (Other == None) {
		HitLocation = EndTrace;
		HitNormal = -vector(AdjustedAim);
	}
	IGPlus_DetSmokeLocation = Owner.Location + CalcDrawOffset() + (FireOffset.X + 20) * vector(AdjustedAim) + FireOffset.Y * Y + FireOffset.Z * Z;
	ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim), Y, Z);
}

// Server: a deterministic shot, with the view and the spot of the shooter's
// own move. The trace rewinds the other players (bbPlayer.TraceShot), by the
// average ping or by Precise Rewind Time.
function DeterministicTraceFire(rotator ShotRot, vector ShotLoc) {
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local vector DrawOffsetLoc;
	local vector LiftLead, LiftHitLoc, LiftHitNormal;
	local bool bLiftHit;
	local Actor Other;
	local Pawn PawnOwner;
	local bbPlayer bbP;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == none)
		return;
	bbP = bbPlayer(PawnOwner);

	Owner.MakeNoise(PawnOwner.SoundDampening);

	GetAxes(ShotRot, X, Y, Z);
	DrawOffsetLoc = PawnOwner.BaseEyeHeight * vect(0,0,1) + ((0.01 * PlayerViewOffset) >> ShotRot);
	// From the eye, as on the shooter's client (ClientTraceFire). The beam
	// the others see still leaves the gun.
	if (bbP != None)
		StartTrace = ShotLoc + bbP.IGPlus_ServerShotEye() * vect(0,0,1);
	else
		StartTrace = ShotLoc + PawnOwner.EyeHeight * vect(0,0,1);
	IGPlus_DetSmokeLocation = ShotLoc + DrawOffsetLoc + (FireOffset.X + 20) * X + FireOffset.Y * Y + FireOffset.Z * Z;

	// On a moving lift the shot leaves from where the shooter's screen had the
	// shooter, and the shooter's own lift counts where that screen had it
	// (see ST_ShockRifle.TraceFireAt).
	if (bbP != None)
		LiftLead = bbP.IGPlus_OwnLiftLead();
	if (LiftLead != vect(0,0,0))
		StartTrace -= LiftLead;

	AdjustedAim = ShotRot;
	EndTrace = StartTrace + IGPLUS_BEAM_RANGE * X;

	if (LiftLead != vect(0,0,0)) {
		bLiftHit = bbP.IGPlus_TraceMover(Mover(PawnOwner.Base), StartTrace + LiftLead, EndTrace + LiftLead, LiftHitLoc, LiftHitNormal);
		if (bLiftHit) {
			LiftHitLoc -= LiftLead;
			EndTrace = LiftHitLoc;
		}
		bbP.IGPlus_OwnLiftShotShift = LiftLead;
	}

	if (WImp != None && WImp.WeaponSettings.ShockBeamUseReducedHitbox)
		Other = WImp.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner);
	else
		Other = PawnOwner.TraceShot(HitLocation, HitNormal, EndTrace, StartTrace);

	if (LiftLead != vect(0,0,0)) {
		bbP.IGPlus_OwnLiftShotShift = vect(0,0,0);
		if (bLiftHit && Other == None) {
			Other = PawnOwner.Base;
			HitLocation = LiftHitLoc;
			HitNormal = LiftHitNormal;
		}
	}

	if (Other == None) {
		HitLocation = EndTrace;
		HitNormal = -X;
	}

	// Against the shooter's own trace, before the damage.
	if (bbP != None) {
		bbP.IGPlus_SDNoteShot(Other, false, StartTrace, ShotRot, HitLocation, 0);
		bbP.IGPlus_HitCompare(Other, false, StartTrace, X, HitLocation);
	}

	IGPlus_bDetShot = true;
	ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
	IGPlus_bDetShot = false;
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local Pawn PawnOwner;
	local bbPlayer bbP;
	local vector SmokeLocation, HitOffset;
	local UTPlusDummy Dummy;
	local Pawn Exclude;

	PawnOwner = Pawn(Owner);
	bbP = bbPlayer(PawnOwner);

	// Both callers (TraceFire, DeterministicTraceFire) give the end of a
	// miss and where the beam starts.
	SmokeLocation = IGPlus_DetSmokeLocation;

	// For a viewer who attaches the beam's end to the player hit: the hit
	// point on that player's body. A rewound player was hit where the shooter
	// saw them, so the body is the rewound one.
	if (Other == None) {
		HitOffset = HitLocation;
	} else {
		HitOffset = HitLocation - Other.Location;
		if (Pawn(Other) != None) {
			if (IGPlus_bDetShot && bbP != None && bbP.zzUTPure != None)
				Dummy = bbP.zzUTPure.FindDummy(Pawn(Other));
			if (Dummy != None)
				HitOffset = HitLocation - Dummy.Location;
			if (VSize(HitOffset) > Other.CollisionRadius + Other.CollisionHeight)
				HitOffset = vect(0,0,0);
		}
	}

	SpawnEffect(HitLocation, SmokeLocation);

	// Beam and ring are drawn by each client with its own beam settings, and
	// one copy goes into a server demo (WeaponEffect.Send). The shooter of a
	// deterministic shot always drew them already (ClientTraceFire).
	if (IGPlus_bDetShot)
		Exclude = PawnOwner;
	class'WeaponEffect'.static.Send(
		Level,
		class'SuperShockRifleWeaponEffect',
		PawnOwner.PlayerReplicationInfo,
		SmokeLocation,
		SmokeLocation - Owner.Location,
		Other,
		HitLocation,
		HitOffset,
		HitNormal,
		Exclude);

	if ( (Other != self) && (Other != Owner) && (Other != None) )
	{
		Other.TakeDamage(HitDamage, PawnOwner, HitLocation, 60000.0*X, MyDamageType);
	}
}

function SpawnEffect(vector HitLocation, vector SmokeLocation)
{
	local SuperShockBeam SSB;

	// Stats count the SuperShockBeams that were spawned. Nobody sees this one:
	// the beam everyone sees is the WeaponEffect.
	SSB = Spawn(class'SuperShockBeam',,, SmokeLocation);
	if (SSB != None) {
		SSB.bHidden = true;
		SSB.RemoteRole = ROLE_None;
	}
}

function Fire(float Value)
{
	if (IsDetActive() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.Fire(Value);
}

function AltFire(float Value)
{
	if (IsDetActive() && Role == ROLE_Authority && Level.NetMode != NM_Client)
		return;
	Super.AltFire(Value);
}

function Finish()
{
	if (IsDetActive())
	{
		if (bChangeWeapon)
			GotoState('DownWeapon');
		else
			GotoState('Idle');
		return;
	}
	Super.Finish();
}

function bool PutDown()
{
	local bbPlayer BP;

	BP = bbPlayer(Owner);
	if (BP != none)
		BP.IGPlus_MarkDeterministicSwitchGuard();

	bCanClientFire = false;
	return Super.PutDown();
}

// One pass of the fire anim, not stock's loop. A held-fire refire comes at
// the moment the loop would end, and a loop that is still running on that
// frame ignores the restart, so the rifle would not move for that shot.
simulated function PlayFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	PlayAnim('Fire1', 0.20 + 0.20 * FireAdjust, 0.05);
}

simulated function PlayAltFiring()
{
	PlayOwnedSound(FireSound, SLOT_None, Pawn(Owner).SoundDampening*4.0);
	PlayAnim('Fire1', 0.20 + 0.20 * FireAdjust, 0.05);
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
		carried = 'SuperShockRifle';
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

// In NextIG the rifle is the only weapon and comes up as the NewNet rifle
// does (bbPlayer.IGPlus_NewNetRifleTiming): no select or down setting.
simulated function bool IGPlus_NewNetTiming() {
	if (bbPlayer(Owner) != none)
		return bbPlayer(Owner).IGPlus_NewNetRifleTiming(self);
	return WImp != none && WImp.IGPlus_bNextMode; // a bot's rifle, on the server
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') ) {
		if (IGPlus_NewNetTiming())
			PlayAnim('Select', 1.35, 0.0);
		else
			// Just joined: the weapon settings may not be here yet. A speed read
			// from none is 0, the animation never ends and the weapon never fires.
			if (GetWeaponSettings() != None)
				PlayAnim('Select', GetWeaponSettings().ShockSelectAnimSpeed(), 0.0);
			else
				PlayAnim('Select', 1.0, 0.0);
	}
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	bCanClientFire = false;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if (IGPlus_NewNetTiming()) {
		if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
			TweenAnim( AnimSequence, AnimFrame * 0.4 );
		else
			PlayAnim('Down', 1.35, TweenTime);
		return;
	}
	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * GetWeaponSettings().ShockDownTime );
	else
		PlayAnim('Down', GetWeaponSettings().ShockDownAnimSpeed(), TweenTime);
}

// Bounce pending switches to DownWeapon before the inherited Idle label
// clobbers a manual weapon choice.
state Idle
{
	function BeginState()
	{
		if ( bChangeWeapon || (Pawn(Owner) != None && Pawn(Owner).PendingWeapon != None && Pawn(Owner).PendingWeapon != self) )
		{
			GotoState('DownWeapon');
			return;
		}
		Super.BeginState();
	}
}

state ClientActive {
	// A click during the select animation queues no shot, as with the NewNet
	// rifle and ST_SniperRifle (ClientCannotShoot). Stock's state accepts it
	// (TournamentWeapon.ClientActive.ClientFire), and bbPlayer then keeps the
	// tap and fires it when the rifle is up: a player still clicking to
	// respawn got a shot right after every spawn. A state's function is
	// called before our global ClientFire, so the click has to be refused
	// here. A button still held when the rifle is up fires, as in stock.
	simulated function bool ClientFire(float Value) {
		if (IsDetActive() && Owner != none && Owner.Role == ROLE_AutonomousProxy)
			return false;
		return Super.ClientFire(Value);
	}

	simulated function bool ClientAltFire(float Value) {
		if (IsDetActive() && Owner != none && Owner.Role == ROLE_AutonomousProxy)
			return false;
		return Super.ClientAltFire(Value);
	}

	simulated function AnimEnd() {
		// PlaySelect clears this locally. The server's replicated true may
		// already have arrived, so selection must restore readiness locally.
		bCanClientFire = true;
		// Deterministic shots come from the per-move step, not this state
		// (see ST_ShockRifle.ClientActive).
		if (bWeaponUp && IsDetActive() && Owner != none
			&& (TournamentPlayer(Owner) == none || TournamentPlayer(Owner).ClientPending == none)) {
			PlayIdleAnim();
			GotoState('');
			return;
		}
		Super.AnimEnd();
	}
}

state ClientFiring {
	simulated function AnimEnd() {
		if (IsDetActive()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}
		Super.AnimEnd();
	}
}

state ClientAltFiring {
	simulated function AnimEnd() {
		if (IsDetActive()) {
			PlayIdleAnim();
			GotoState('');
			return;
		}
		Super.AnimEnd();
	}
}

defaultproperties {
}
