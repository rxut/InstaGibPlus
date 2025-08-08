class UTPlusDummy extends Actor;

var Pawn Actual;
var float LatestClientTimeStamp;
var float EyeHeight;
var float BaseEyeHeight;
var bool bHistoryCleared;

var UTPlusSnapshot Data[48];
var int DataIndex;

var bool bCompActive;

var bool ActualWasColliding;
var bool ActualWasBlockingActors;
var bool ActualWasBlockingPlayers;
var bool ActualWasProjTarget;

var vector AccumulatedMomentum;

var UTPlusDummy Next;

var IGPlus_WeaponImplementation WImp;

var name  CurrentAnimSequence;
var float CurrentAnimFrame;

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
	D.Acc = Actual.Acceleration;
	D.Rot = Actual.Rotation;
	D.VR = Actual.ViewRotation;
	D.BaseEyeHeight = Actual.BaseEyeHeight;
	D.EyeHeight = Actual.EyeHeight;
	D.CollisionRadius = Actual.CollisionRadius;
	D.CollisionHeight = Actual.CollisionHeight;
	D.bSnapCollideActors = Actual.bCollideActors;
	D.bSnapBlockActors = Actual.bBlockActors;
	D.bSnapBlockPlayers = Actual.bBlockPlayers;
	D.bSnapProjTarget = Actual.bProjTarget;
	D.ServerTimeStamp = Level.TimeSeconds;

	D.AnimSequence = Actual.AnimSequence;
	D.AnimFrame = Actual.AnimFrame;

	if (Actual.IsA('PlayerPawn'))
		D.ClientTimeStamp = PlayerPawn(Actual).CurrentTimeStamp;
	else
		D.ClientTimeStamp = 0;
}

event Tick(float DeltaTime) {
    local int i;
    local PlayerPawn PP;
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

    PP = PlayerPawn(Actual);

    if (PP != None) {
		if (PP.GetStateName() == 'Dying') {
			if (PP.Player != None && !bHistoryCleared) {
				for (i = 0; i < arraycount(Data); i++) {
					Data[i] = None;
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

		if (PP.CurrentTimeStamp > LatestClientTimeStamp) {
			LatestClientTimeStamp = PP.CurrentTimeStamp;
			if (Data[DataIndex] == None)
				Data[DataIndex] = new class'UTPlusSnapshot';
			FillData(Data[DataIndex]);
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

function CompStart(int Ping)
{
    local float TargetTimeStamp;
    local bool  bSubTickCompensation;
    local int   Idx, Scans;
    local int   BufSize;
    local UTPlusSnapshot OlderSnap;
    local UTPlusSnapshot NewerSnap;
    local float TimeDelta, Alpha;

    if (Actual == None || Actual.bDeleteMe || WImp == None)
        return;

    if (Ping > WImp.WeaponSettings.PingCompensationMax)
		Ping = WImp.WeaponSettings.PingCompensationMax;
	if (Ping < 0)
		Ping = 0;

    bSubTickCompensation = WImp.WeaponSettings.bEnableSubTickCompensation;
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
                    if (TimeDelta > 0.001 && VSize(NewerSnap.Loc - OlderSnap.Loc) / TimeDelta < 3000)
                    {
                        Alpha = (TargetTimeStamp - OlderSnap.ServerTimeStamp) / TimeDelta;
                        CompSwap(OlderSnap, NewerSnap, FClamp(Alpha, 0.0, 1.0), TargetTimeStamp);
                        return;
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

function CompSwap(UTPlusSnapshot SnapA, UTPlusSnapshot SnapB, float Alpha, float TargetTimeStamp) {
	local vector TargetLoc;
	local vector TargetVel;
	local rotator TargetRot;
	local float TargetEH;
	local float TargetBEH;
	local float TargetCR;
	local float TargetCH;

    local bool TargetCollideActors;
	local bool TargetBlockActors;
	local bool TargetBlockPlayers;
	local bool TargetProjTarget;

	local name TargetAnimSequence;
	local float TargetAnimFrame;

	if (Actual == None || Actual.bDeleteMe) {
		return;
	}
	if (SnapA == None) {
		return;
	}
	if (bCompActive) {
		return;
	}

	if (Alpha == -1.0) { // Extrapolation from SnapA
		TargetLoc = SnapA.Loc + SnapA.Vel * (TargetTimeStamp - SnapA.ServerTimeStamp);
		TargetVel = SnapA.Vel;
		TargetEH = SnapA.EyeHeight;
		TargetRot = SnapA.Rot;
		TargetBEH = SnapA.BaseEyeHeight;
		TargetCR = SnapA.CollisionRadius;
		TargetCH = SnapA.CollisionHeight;
		TargetCollideActors = SnapA.bSnapCollideActors;
		TargetBlockActors = SnapA.bSnapBlockActors;
		TargetBlockPlayers = SnapA.bSnapBlockPlayers;
		TargetProjTarget = SnapA.bSnapProjTarget;
		TargetAnimSequence = SnapA.AnimSequence;
		TargetAnimFrame = SnapA.AnimFrame;
	}
	else if (Alpha >= 0.0 && Alpha <= 1.0 && SnapB != None) { // Interpolation between SnapA and SnapB
		TargetLoc = LerpVector(Alpha, SnapA.Loc, SnapB.Loc);
		TargetVel = LerpVector(Alpha, SnapA.Vel, SnapB.Vel); 
		TargetRot = SnapA.Rot;
		TargetEH = SnapA.EyeHeight;
		TargetBEH = SnapA.BaseEyeHeight;
		TargetCR = SnapA.CollisionRadius;
		TargetCH = SnapA.CollisionHeight;
		TargetCollideActors = SnapA.bSnapCollideActors;
		TargetBlockActors = SnapA.bSnapBlockActors;
		TargetBlockPlayers = SnapA.bSnapBlockPlayers;
		TargetProjTarget = SnapA.bSnapProjTarget;
		TargetAnimSequence = SnapA.AnimSequence;
		TargetAnimFrame = SnapA.AnimFrame;
	}
	else if (Alpha == 1.0 && SnapB == None) { // Direct use of SnapA (no interpolation)
		TargetLoc = SnapA.Loc;
		TargetVel = SnapA.Vel;
		TargetRot = SnapA.Rot;
		TargetEH = SnapA.EyeHeight;
		TargetBEH = SnapA.BaseEyeHeight;
		TargetCR = SnapA.CollisionRadius;
		TargetCH = SnapA.CollisionHeight;
		TargetCollideActors = SnapA.bSnapCollideActors;
		TargetBlockActors = SnapA.bSnapBlockActors;
		TargetBlockPlayers = SnapA.bSnapBlockPlayers;
		TargetProjTarget = SnapA.bSnapProjTarget;
		TargetAnimSequence = SnapA.AnimSequence;
		TargetAnimFrame = SnapA.AnimFrame;
	}
	else {
		return; // Invalid state
	}
    
	// Store for CompEnd
	ActualWasColliding = Actual.bCollideActors;
	ActualWasBlockingActors = Actual.bBlockActors;
	ActualWasBlockingPlayers = Actual.bBlockPlayers;
	ActualWasProjTarget = Actual.bProjTarget;

	// Move the Actual pawn out of the way temporarily
	Actual.SetCollision(false, false, false);
	Actual.bProjTarget = false;

	SetLocation(TargetLoc);
	SetRotation(TargetRot);
	Velocity = TargetVel;
	EyeHeight = TargetEH;
	BaseEyeHeight = TargetBEH;

    if (CollisionRadius != TargetCR || CollisionHeight != TargetCH)
	    SetCollisionSize(TargetCR, TargetCH);

	
	CurrentAnimSequence = TargetAnimSequence;
	CurrentAnimFrame = TargetAnimFrame;
	
	SetCollision(TargetCollideActors, TargetBlockActors, TargetBlockPlayers);
	bProjTarget = TargetProjTarget;

	AccumulatedMomentum = vect(0,0,0);
	bCompActive = true;
}

function CompEnd() {
    if (bCompActive) {
        bCompActive = false;

        // Hide the dummy again
        SetCollision(false, false, false);
        bProjTarget = false;

        if (Actual != None && !Actual.bDeleteMe)
        {
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

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;
	if (BaseEyeHeight == Actual.Default.BaseEyeHeight)
		return true;

	maxZ = Location.Z + EyeHeight + 0.25 * CollisionHeight;
	if (HitLocation.Z > maxZ)	{
		if (TraceDir.Z >= 0)
			return false;
		adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
		HitLocation.Z = maxZ;
		HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
		HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
		if (VSize(vect(1,1,0) * (HitLocation - Location)) > CollisionRadius)
			return false;
	}
	return true;
}


defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None;
}