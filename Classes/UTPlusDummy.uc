class UTPlusDummy extends Actor;

var Pawn Actual;
var float LatestClientTimeStamp;
var float DuckFraction;
var bool bHistoryCleared;
var bool bLastHeld;

// One snapshot for every tick a move ran in. 128 of them reach back one second
// at 128 ticks a second and 0.64 s at 200. A shot is rewound by the shooter's
// ping, plus the delay their screen draws others with, plus the delay
// Adaptive Buffering runs their own moves with: 450 ms for a 300 ping player.
// (48 reached back 380 ms at 126 ticks a second, and a rewind past the oldest
// snapshot took the oldest one.)
var UTPlusSnapshot Data[128];
var int DataIndex;

var bool bCompActive;
// The last rewind by the shown tick: how old the snapshot was at the time
// the shooter saw, and for how long it was carried on (for the [DET-HIT] line).
var float CompGap, CompCarry;
// The last rewind by a tick position: the ticks of the two snapshots used (the second is 0 for a carry).
var int CompTickA, CompTickB;
// The last rewind pointed at a moment in which the player could not be hit,
// and the first snapshot in which they could was taken (CompSwap).
var bool bCompFirstHittable;
// A rewind by a tick position (CompStartTick). A client with Tick
// Interpolation knows no holds, it draws between the updates it got. So the
// held mark is left out. And the spots it got are in quarters of a unit, so
// ours are rounded the same way (bbPlayer.IGPlus_TI_WireLoc).
var bool bCompTick;

var bool ActualWasColliding;
var bool ActualWasBlockingActors;
var bool ActualWasBlockingPlayers;
var bool ActualWasProjTarget;

var vector AccumulatedMomentum;

var UTPlusDummy Next;

var IGPlus_WeaponImplementation WImp;

var name  CurrentAnimSequence;
var float CurrentAnimFrame;
var vector CurrentHeadDrawn;
var bool   bCurrentHeadDrawn;
// Where Actual's head is drawn through tweens, kept every tick (shared with
// bbPlayer.IGPlus_HeadTween for the live head check).
var IGPlus_HeadTween HeadTween;

// What our player stood on when this compensation started, before any lift
// was moved back. Moving a lift takes everyone standing on it off it.
var Actor IGPlus_CompBase;

// Tick Interpolation, a shot: the lift whose travel the shooter's screen drew
// our player with, how much of it (0 to 1), and that lift's travel over the
// time that screen had it ahead of the players (NoteLift).
var Mover CompLift;
var float CompLiftShare;
var float CompLiftRise;

simulated function PostBeginPlay()
{

	if (ROLE == ROLE_Authority)
	{
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
	}

	Super.PostBeginPlay();
}

function FillData(UTPlusSnapshot D) {
	D.Loc = Actual.Location;
	D.Vel = Actual.Velocity;
	D.Rot = Actual.Rotation;
	// Same value the unrewound hit check reads (GetPawnDuckFraction)
	if (bbPlayer(Actual) != None)
		D.DuckFraction = bbPlayer(Actual).DuckFraction;
	else if (Actual.default.BaseEyeHeight > 0.0)
		D.DuckFraction = FClamp(1.0 - Actual.EyeHeight / Actual.default.BaseEyeHeight, 0.0, 1.0);
	else
		D.DuckFraction = 0.0;
	D.CollisionRadius = Actual.CollisionRadius;
	D.CollisionHeight = Actual.CollisionHeight;
	D.bBasedOnMover = Mover(Actual.Base) != None;
	if (D.bBasedOnMover)
	{
		D.BaseMover = Actual.Base;
		D.MoverZ = Actual.Base.Location.Z;
	}
	D.bSnapCollideActors = Actual.bCollideActors;
	D.bSnapBlockActors = Actual.bBlockActors;
	D.bSnapBlockPlayers = Actual.bBlockPlayers;
	D.bSnapProjTarget = Actual.bProjTarget;
	D.ServerTimeStamp = Level.TimeSeconds;
	D.bHeld = bbPlayer(Actual) != None && bbPlayer(Actual).IGPlus_ABHeld;
	D.bNoMove = false;
	if (bbPlayer(Actual) != None && bbPlayer(Actual).zzUTPure != None)
		D.Tick = bbPlayer(Actual).zzUTPure.IGPlus_GlobalTick;

	D.AnimSequence = Actual.AnimSequence;
	D.AnimFrame = Actual.AnimFrame;
	D.bHeadDrawn = HeadTween != None && HeadTween.bCur;
	if (HeadTween != None)
		D.HeadDrawn = HeadTween.Cur;
}

event Tick(float DeltaTime) {
    local int i;
    local PlayerPawn PP;
    local bool bNowHeld, bNoMoveSnap;
    super.Tick(DeltaTime);

    if (Actual == none || Actual.bDeleteMe) {
		Disable('Tick');
		if (!bHistoryCleared) {
			for (i = 0; i < arraycount(Data); i++) {
				Data[i] = None;
			}
			DataIndex = 0;
			bHistoryCleared = true;
		}
		return;
	}

	// Every tick, before a snapshot is taken: the head blends through tweens.
	if (HeadTween == None) {
		HeadTween = new class'IGPlus_HeadTween';
		if (bbPlayer(Actual) != None)
			bbPlayer(Actual).IGPlus_HeadTween = HeadTween;
	}
	HeadTween.Update(Actual.AnimSequence, Actual.AnimFrame);

    PP = PlayerPawn(Actual);

    if (PP != None) {
		if (PP.Health <= 0 || PP.GetStateName() == 'Dying') {
			if (PP.Player != None && !bHistoryCleared) {
				// The snapshots are emptied, not dropped: the engine only frees
				// objects at a map change, so a new list for every life left
				// one list of dead objects behind for every death on the map.
				// (A snapshot with no time is skipped by every rewind.)
				for (i = 0; i < arraycount(Data); i++) {
					if (Data[i] != None)
						Data[i].ServerTimeStamp = 0.0;
				}
				DataIndex = 0;
				if (bCompActive)
					CompEnd();
				bHistoryCleared = true;
				return;
			}
            else if (bHistoryCleared) {
                 return;
            }

		} else {
			bHistoryCleared = false;
		}

		// A snapshot for every tick a move ran in, and one for the tick Adaptive
		// Buffering starts to hold the player still (no move runs then).
		bNowHeld = bbPlayer(PP) != None && bbPlayer(PP).IGPlus_ABHeld;
		if (PP.CurrentTimeStamp > LatestClientTimeStamp || bNowHeld != bLastHeld) {
			bLastHeld = bNowHeld;
			bNoMoveSnap = PP.CurrentTimeStamp <= LatestClientTimeStamp;
			LatestClientTimeStamp = PP.CurrentTimeStamp;
			if (Data[DataIndex] == None)
				Data[DataIndex] = new class'UTPlusSnapshot';
			FillData(Data[DataIndex]);
			Data[DataIndex].bNoMove = bNoMoveSnap;
			DataIndex = (DataIndex + 1) % arraycount(Data);
		}
	} else { // Handle non-PlayerPawn Actual
		if (Data[DataIndex] == None)
			Data[DataIndex] = new class'UTPlusSnapshot';
		FillData(Data[DataIndex]);
		DataIndex = (DataIndex + 1) % arraycount(Data);
	}
}

function vector LerpVector(float Alpha, vector A, vector B) {
    return A + (B - A) * Alpha;
}

// ExtraMs: what the shooter's own delays add on top of PingCompensationMax
// (bbPlayer.IGPlus_RewindExtraMs). The cap holds the ping.
function CompStart(int Ping, optional int ExtraMs)
{
    local float TargetTimeStamp;
    local bool  bSubTickCompensation;
    local int   Idx, Scans;
    local int   BufSize;
    local UTPlusSnapshot OlderSnap;
    local UTPlusSnapshot NewerSnap;
    local float TimeDelta, Alpha;
    local vector SnapDelta;
    local float MaxTravelDistanceSq;

	bCompFirstHittable = false;
    if (Actual == none || Actual.bDeleteMe || WImp == None || Actual.Health <= 0)
		return;

    if (Ping > WImp.WeaponSettings.PingCompensationMax + ExtraMs)
		Ping = WImp.WeaponSettings.PingCompensationMax + ExtraMs;
	if (Ping < 0)
		Ping = 0;

    bSubTickCompensation = WImp.WSettingsRepl != None && WImp.WSettingsRepl.bEnablePingCompensation;
    TargetTimeStamp = Level.TimeSeconds - 0.001 * Ping * Level.TimeDilation;

	BufSize = arraycount(Data);
    Idx = (DataIndex - 1 + BufSize) % BufSize;
	NewerSnap = None;

    for (Scans = 0; Scans < BufSize; Scans++)
    {
        OlderSnap = Data[Idx];

        if (OlderSnap != None && OlderSnap.ServerTimeStamp > 0)
        {
            // Have we found a snapshot older than our target time?
            if (OlderSnap.ServerTimeStamp <= TargetTimeStamp)
            {
                // If we have a newer snapshot, we can interpolate between them.
                if (bSubTickCompensation && NewerSnap != None)
                {
                    TimeDelta = NewerSnap.ServerTimeStamp - OlderSnap.ServerTimeStamp;
                    if (TimeDelta > 0.001) {
                        SnapDelta = NewerSnap.Loc - OlderSnap.Loc;
                        MaxTravelDistanceSq = Square(3000.0 * TimeDelta);
                        if ((SnapDelta dot SnapDelta) < MaxTravelDistanceSq) {
                            Alpha = (TargetTimeStamp - OlderSnap.ServerTimeStamp) / TimeDelta;
                            CompSwap(OlderSnap, NewerSnap, FClamp(Alpha, 0.0, 1.0), TargetTimeStamp);
                            return;
                        }
                    }
                }
                
                // Otherwise, we must snap to or extrapolate from this older snapshot.
                if (bSubTickCompensation)
                    CompSwap(OlderSnap, None, -1.0, TargetTimeStamp);
                else
                    CompSwap(OlderSnap, None, 1.0, TargetTimeStamp);
                return;
            }
            
            // This snapshot was too new, so it becomes the "NewerSnap" for the next iteration.
            NewerSnap = OlderSnap;
        }

        Idx = (Idx - 1 + BufSize) % BufSize; // Move to the next older snapshot
    }

    if (NewerSnap != None)
    {
        if (bSubTickCompensation)
            CompSwap(NewerSnap, None, -1.0, TargetTimeStamp); // Extrapolate from oldest
        else
            CompSwap(NewerSnap, None, 1.0, TargetTimeStamp); // Snap to oldest
    }
}

// Precise Rewind Time: the shooter's screen showed the update the server
// sent at SeenTime and kept moving players forward from it until ViewTime.
// Same here: the newest snapshot the shooter had, carried to ViewTime.
function CompStartSeen(float SeenTime, float ViewTime) {
	local int Idx, Scans;
	local UTPlusSnapshot Snap, Oldest;

	bCompFirstHittable = false;
	if (Actual == none || Actual.bDeleteMe || Actual.Health <= 0)
		return;

	Idx = DataIndex;
	for (Scans = 0; Scans < arraycount(Data); Scans++) {
		Idx = (Idx - 1 + arraycount(Data)) % arraycount(Data);
		Snap = Data[Idx];
		if (Snap == None || Snap.ServerTimeStamp <= 0)
			continue;
		// (A report from before its update, bbPlayer.IGPlus_PRTDrawnLag: this
		// snapshot carried back, as the shooter's own trace does it.)
		if (Snap.ServerTimeStamp <= SeenTime) {
			CompSwap(Snap, None, -1.0, ViewTime);
			return;
		}
		Oldest = Snap;
	}
	if (Oldest != None)
		CompSwap(Oldest, None, -1.0, ViewTime);
}

// Tick Interpolation: stand the player where a client drew them at tick
// position R (a tick number and a part of the way to the next snapshot). The
// client draws between the two updates around R, and the updates it got are
// our snapshots of the ticks a move ran in. Past the newest snapshot the
// client carries the player on for at most 2 ticks, and so do we. bPast: the
// client had no update after R when it drew, so a snapshot we took later is
// left out. bHeld: the client drew them standing still there, because we had
// told it that we hold them (Adaptive Buffering). That is only taken when a
// hold of ours did follow that snapshot.
// Span: the two updates the client drew between (bbPlayer.IGPlus_TI_Span).
// Its older one is Span & 3 ticks before R's tick, its newer one
// (Span >> 2) & 3 ticks after the tick that follows. A snapshot of ours
// between those two never reached that client (two updates in one of its
// frames, or a lost packet), so it is left out here too. 0: the snapshot of
// R's tick and the next one.
// DelayTicks: the delay that screen drew players with, in ticks. LeadTicks:
// how far ahead of them it had the lifts (bbPlayer.IGPlus_TI_Lead).
function CompStartTick(float R, float TickLen, optional bool bPast, optional bool bHeld, optional int Span, optional float DelayTicks, optional float LeadTicks) {
	local int Idx, Scans, TickA, TickB;
	local UTPlusSnapshot Snap, A, B;
	local bool bHoldAfter;

	bCompFirstHittable = false;
	if (Actual == none || Actual.bDeleteMe || Actual.Health <= 0)
		return;

	NoteLift(R + DelayTicks, TickLen, DelayTicks, LeadTicks);

	TickA = int(R) - (Span & 3);
	TickB = int(R) + 1 + ((Span >> 2) & 3);

	Idx = DataIndex;
	for (Scans = 0; Scans < arraycount(Data); Scans++) {
		Idx = (Idx - 1 + arraycount(Data)) % arraycount(Data);
		Snap = Data[Idx];
		if (Snap == None || Snap.ServerTimeStamp <= 0)
			continue;
		if (Snap.bNoMove) {
			// A snapshot with no move: a hold started or ended. Going back in
			// time, the last one seen before A tells what followed A.
			bHoldAfter = Snap.bHeld;
			continue;
		}
		if (Snap.Tick <= TickA) {
			A = Snap;
			break;
		}
		if (Snap.Tick >= TickB)
			B = Snap;
		bHoldAfter = false;
	}
	CompTickA = 0;
	CompTickB = 0;
	if (A != None)
		CompTickA = A.Tick;
	bCompTick = true;
	if (A == None) {
		// Older than everything we kept: the oldest snapshot.
		if (B != None)
			CompSwap(B, None, 0.0, 0.0);
	} else if (bPast == false && B != None && B.Tick > A.Tick) {
		CompTickB = B.Tick;
		// Not between the two ends of a teleport: at the older one, as the client draws it.
		if (class'bbPlayer'.static.IGPlus_TI_IsJump(class'bbPlayer'.static.IGPlus_TI_WireLoc(A.Loc),
				class'bbPlayer'.static.IGPlus_TI_WireLoc(B.Loc), B.Tick - A.Tick, TickLen))
			CompSwap(A, None, 0.0, 0.0);
		else
			CompSwap(A, B, (R - float(A.Tick)) / float(B.Tick - A.Tick), 0.0);
	} else {
		// Held after A: a hold snapshot followed it, or the hold began in A's
		// own tick. Adaptive Buffering holds a player in the tick their last
		// queued move ran (bbPlayer.IGPlus_ABPlayout), and that tick's snapshot
		// is the move's, with bHeld set and no hold snapshot after it. The
		// clients stop the player there, so the rewind does not carry them on.
		CompSwap(A, None, -1.0, A.ServerTimeStamp
			+ class'bbPlayer'.static.IGPlus_TI_CarryTicks(R - float(A.Tick), bHeld && (bHoldAfter || A.bHeld)) * TickLen);
	}
	bCompTick = false;
}

// Tick Interpolation: a client draws a player on a moving lift with the
// lift's travel over the time it runs ahead of them on top, so they stand on
// the lift it draws (bbPlayer.IGPlus_TI_LiftShift). That travel comes in over a few ticks
// after they get on and goes out over a few after they leave. The same here,
// by the same rule (bbPlayer.IGPlus_TI_LiftWalk) over our snapshots, up to
// tick position C: the newest moment that screen had of them.
function NoteLift(float C, float TickLen, float DelayTicks, float Lead) {
	local int Idx, Scans;
	local UTPlusSnapshot Snap, Newer;
	local float Hi, Now, Fade;
	local bbPlayer BP;
	local ST_MoverDummy MD;
	local bool bDone;

	CompLift = None;
	CompLiftShare = 0.0;
	CompLiftRise = 0.0;
	BP = bbPlayer(Actual);
	if (DelayTicks <= 0.0 || BP == None || BP.zzUTPure == None)
		return;

	Hi = C;
	Fade = class'bbPlayer'.static.IGPlus_TI_LiftFade(DelayTicks);
	Idx = DataIndex;
	for (Scans = 0; Scans < arraycount(Data); Scans++) {
		Idx = (Idx - 1 + arraycount(Data)) % arraycount(Data);
		Snap = Data[Idx];
		if (Snap == None || Snap.ServerTimeStamp <= 0 || Snap.bNoMove || float(Snap.Tick) > C)
			continue;
		// A teleport after this snapshot: it was somewhere else.
		if (Newer != None && class'bbPlayer'.static.IGPlus_TI_IsJump(class'bbPlayer'.static.IGPlus_TI_WireLoc(Snap.Loc),
				class'bbPlayer'.static.IGPlus_TI_WireLoc(Newer.Loc), Newer.Tick - Snap.Tick, TickLen)) {
			bDone = true;
			break;
		}
		if (CompLift == None && Snap.bBasedOnMover)
			CompLift = Mover(Snap.BaseMover);
		Newer = Snap;
		if (class'bbPlayer'.static.IGPlus_TI_LiftWalk(float(Snap.Tick), Hi, C, Fade,
				CompLift != None && Snap.bBasedOnMover && Snap.BaseMover == CompLift, CompLiftShare) == false) {
			bDone = true;
			break;
		}
	}
	// Before the oldest snapshot they count as in it.
	if (bDone == false && Newer != None)
		class'bbPlayer'.static.IGPlus_TI_LiftWalk(Hi - 1000.0, Hi, C, Fade,
			CompLift != None && Newer.bBasedOnMover && Newer.BaseMover == CompLift, CompLiftShare);
	if (CompLift == None || CompLiftShare <= 0.0)
		return;

	// The lift's travel over the time that screen had it ahead of the players
	// (Lead ticks, bbPlayer.IGPlus_TI_Lead), from its own history. For a player who
	// stands on it at both ends CompSwap takes the lift as the trace sees it.
	MD = BP.zzUTPure.FindMoverDummy(CompLift);
	if (MD == None)
		return;
	Now = Level.TimeSeconds - (float(BP.zzUTPure.IGPlus_GlobalTick) - C) * TickLen;
	CompLiftRise = MD.GetHistoricalLocation(Now - (DelayTicks - Lead) * TickLen).Z - MD.GetHistoricalLocation(Now - DelayTicks * TickLen).Z;
}

function TakeDamage(
    int Damage,
    Pawn InstigatedBy,
    Vector Hitlocation,
    Vector Momentum,
    name DamageType
) {
    
    if (bCompActive && Actual != none) {
        AccumulatedMomentum += Momentum;
        Actual.TakeDamage(Damage, InstigatedBy, HitLocation, vect(0,0,0), DamageType);
    }
}

// The first snapshot after From in which the player could be hit.
function UTPlusSnapshot FirstHittableAfter(UTPlusSnapshot From) {
	local int i;
	local UTPlusSnapshot S, Best;

	for (i = 0; i < arraycount(Data); i++) {
		S = Data[i];
		if (S == None || S.ServerTimeStamp <= From.ServerTimeStamp || S.bSnapCollideActors == false)
			continue;
		if (Best == None || S.ServerTimeStamp < Best.ServerTimeStamp)
			Best = S;
	}
	return Best;
}

function CompSwap(UTPlusSnapshot SnapA, UTPlusSnapshot SnapB, float Alpha, float TargetTimeStamp) {
	local vector TargetLoc, LocA, LocB;
	local vector TargetVel;
	local bbPlayer BP;
	local Mover BaseMover;
	local float SnapshotMoverZ, Rise;
	local float XpolTime;
	local bool bOnLift;

	if (Actual == None || Actual.bDeleteMe || SnapA == None || bCompActive)
		return;

	// A player is never put back to a moment in which they could not be hit.
	// With Ping Compensated Spawn a respawned player is hidden and without
	// collision until their first move as alive, and the moves their client
	// still sends as dead make snapshots in that time. A shot at a player the
	// shooter's screen had just begun to show can report a moment before that
	// first move: a screen with Tick Interpolation draws a new player at once,
	// 2 to 3 ticks ahead of its drawing clock. The stand-in then stood there
	// with no collision, and the shot missed a player the shooter saw. The
	// first snapshot after it in which they can be hit is taken, as it is.
	// With none yet, the player stays where they are and is tested there.
	if (SnapA.bSnapCollideActors == false) {
		SnapA = FirstHittableAfter(SnapA);
		if (SnapA == None)
			return;
		SnapB = None;
		Alpha = 0.0;
		bCompFirstHittable = true;
	}

	LocA = SnapA.Loc;
	if (SnapB != None)
		LocB = SnapB.Loc;
	// The spots as a client with Tick Interpolation got them.
	if (bCompTick) {
		LocA = class'bbPlayer'.static.IGPlus_TI_WireLoc(LocA);
		LocB = class'bbPlayer'.static.IGPlus_TI_WireLoc(LocB);
	}

	// Compute position/velocity based on compensation mode
	if (SnapA.bHeld && bCompTick == false) {
		// Held still by Adaptive Buffering from this snapshot until the next
		// one. The other clients drew the player standing here
		// (bbPlayer.IGPlus_ApplyWarpFix), so nothing carries them on.
		CompGap = TargetTimeStamp - SnapA.ServerTimeStamp;
		CompCarry = 0;
		TargetLoc = LocA;
		TargetVel = SnapA.Vel;
	} else if (Alpha == -1.0) {
		// Extrapolation from SnapA. Capped: a player whose packets stall has
		// no newer snapshot, and an uncapped velocity carries them through walls.
		// With warp fix on, clients hold a player stalled that long at this
		// snapshot (bbPlayer.IGPlus_ApplyWarpFix): so do we.
		XpolTime = FClamp(TargetTimeStamp - SnapA.ServerTimeStamp, -0.2, 0.2);
		BP = bbPlayer(Actual);
		if (BP != None && BP.IGPlus_EnableWarpFix && TargetTimeStamp - SnapA.ServerTimeStamp > BP.IGPlus_WarpFixDelay)
			XpolTime = 0;
		CompGap = TargetTimeStamp - SnapA.ServerTimeStamp;
		CompCarry = XpolTime;
		TargetLoc = LocA + SnapA.Vel * XpolTime;
		TargetVel = SnapA.Vel;
	} else if (SnapB != None) {
		// Interpolation between SnapA and SnapB
		TargetLoc = LerpVector(Alpha, LocA, LocB);
		TargetVel = LerpVector(Alpha, SnapA.Vel, SnapB.Vel);
	} else {
		// Direct snap to SnapA
		TargetLoc = LocA;
		TargetVel = SnapA.Vel;
	}

	if (SnapA.bBasedOnMover && IGPlus_CompBase == SnapA.BaseMover) {
		BaseMover = Mover(SnapA.BaseMover);
		if (BaseMover != None) {
			// If sub-tick interpolation is active and both snapshots are from the
			// same mover base, interpolate the mover snapshot Z consistently.
			SnapshotMoverZ = SnapA.MoverZ;
			if (SnapB != None && SnapB.bBasedOnMover && SnapB.BaseMover == SnapA.BaseMover)
				SnapshotMoverZ = SnapA.MoverZ + (SnapB.MoverZ - SnapA.MoverZ) * FClamp(Alpha, 0.0, 1.0);

			// Stand on the lift where the trace sees it: rewound while it moves,
			// live once it has stopped (UTPure.CompensateFor).
			Rise = BaseMover.Location.Z - SnapshotMoverZ;
			bOnLift = true;
		}
	}
	if (bCompTick == false) {
		if (bOnLift)
			TargetLoc.Z += Rise;
	} else if (CompLift != None) {
		// Tick Interpolation: the share of the lift's travel the shooter's
		// screen drew them with (NoteLift). Off the lift at either end, the
		// travel is the one NoteLift took from the lift's own history.
		if (bOnLift == false || BaseMover != CompLift)
			Rise = CompLiftRise;
		TargetLoc.Z += CompLiftShare * Rise;
	}

	ActualWasColliding = Actual.bCollideActors;
	ActualWasBlockingActors = Actual.bBlockActors;
	ActualWasBlockingPlayers = Actual.bBlockPlayers;
	ActualWasProjTarget = Actual.bProjTarget;

	Actual.SetCollision(false, false, false);
	Actual.bProjTarget = false;

	SetLocation(TargetLoc);
	SetRotation(SnapA.Rot);
	Velocity = TargetVel;
	DuckFraction = SnapA.DuckFraction;

	if (CollisionRadius != SnapA.CollisionRadius || CollisionHeight != SnapA.CollisionHeight)
		SetCollisionSize(SnapA.CollisionRadius, SnapA.CollisionHeight);

	CurrentAnimSequence = SnapA.AnimSequence;
	CurrentAnimFrame = SnapA.AnimFrame;
	CurrentHeadDrawn = SnapA.HeadDrawn;
	bCurrentHeadDrawn = SnapA.bHeadDrawn;

	SetCollision(SnapA.bSnapCollideActors, SnapA.bSnapBlockActors, SnapA.bSnapBlockPlayers);
	bProjTarget = SnapA.bSnapProjTarget;

	AccumulatedMomentum = vect(0,0,0);
	bCompActive = true;
}

function CompEnd() {
    IGPlus_CompBase = None;
    if (bCompActive) {
        bCompActive = false;

        // Hide the dummy again
        SetCollision(false, false, false);
        bProjTarget = false;

        if (Actual != None && !Actual.bDeleteMe)
        {
            // Gibbed during the rewind (a projectile's ping catch-up, an own-ball
            // combo): HidePlayer hid them and turned their collision off, and
            // Dying.Timer won't call it again for a hidden player. Turning
            // collision back on here left an invisible body that blocked
            // players and shots until the respawn.
            if (!Actual.bHidden)
                Actual.SetCollision(ActualWasColliding, ActualWasBlockingActors, ActualWasBlockingPlayers);
            Actual.bProjTarget = ActualWasProjTarget;
            
            // Apply all accumulated momentum at once
            if (AccumulatedMomentum != vect(0,0,0)) {
                if (Actual.Mass != 0)
                    AccumulatedMomentum = AccumulatedMomentum / Actual.Mass;
                Actual.AddVelocity(AccumulatedMomentum);
                AccumulatedMomentum = vect(0,0,0);
            }
        }
    }
}

simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir) {
	local float adjZ, maxZ;
	local vector HitDeltaXY;
	local float RadiusSq;

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;
	if (DuckFraction <= 0.0)
		return true;

	// Same cut-off as bbPlayer.AdjustHitLocation: the top of the crouching hitbox
	maxZ = Location.Z + (1.0 - 0.7 * DuckFraction) * CollisionHeight;
	if (HitLocation.Z > maxZ)	{
		if (TraceDir.Z >= 0)
			return false;
		adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
		HitLocation.Z = maxZ;
		HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
		HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
		HitDeltaXY = vect(1,1,0) * (HitLocation - Location);
		RadiusSq = CollisionRadius * CollisionRadius;
		if ((HitDeltaXY dot HitDeltaXY) > RadiusSq)
			return false;
	}
	return true;
}


defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None;
}
