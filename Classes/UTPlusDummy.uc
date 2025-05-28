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

function CompStart(int Ping) {
	local float TargetTimeStamp;
	local int I;
	local int Next;
	local float TimeDelta;
	local float Distance;
	local bool bSubTickCompensation;
	local float TargetAlpha;
	local UTPlusSnapshot SnapI, SnapNext;

	if (Actual == none || Actual.bDeleteMe || WImp == None)
		return;

	// Cap ping compensation
	if (Ping > WImp.WeaponSettings.PingCompensationMax)
		Ping = WImp.WeaponSettings.PingCompensationMax;
	if (Ping < 0)
		Ping = 0;

	bSubTickCompensation = WImp.WeaponSettings.bEnableSubTickCompensation;

	TargetTimeStamp = Level.TimeSeconds - 0.001 * Ping * Level.TimeDilation;

	I = DataIndex - 1;
	if (I < 0)
		I += arraycount(Data);

	do {
		Next = I - 1;
		if (Next < 0)
			Next += arraycount(Data);

		SnapI = Data[I];
		SnapNext = Data[Next];

		// Ensure the primary snapshot for this iteration is valid
		if (SnapI == None || SnapI.ServerTimeStamp <= 0) {
			I = Next;
			continue; // Try the next older snapshot
		}

		if (bSubTickCompensation) {
			if (SnapI.ServerTimeStamp <= TargetTimeStamp) {
				CompSwap(SnapI, None, -1.0, TargetTimeStamp); // Alpha -1.0 signifies extrapolation
				return;
			}
			else if (SnapNext != None && SnapNext.ServerTimeStamp > 0 && SnapNext.ServerTimeStamp <= TargetTimeStamp) {
				TimeDelta = SnapI.ServerTimeStamp - SnapNext.ServerTimeStamp;
                // Check for valid TimeDelta to avoid division by zero or huge velocities
				if (TimeDelta > 0.001) {
                    Distance = VSize(SnapI.Loc - SnapNext.Loc);
                    if (Distance / TimeDelta <= 2500) {
                        TargetAlpha = (TargetTimeStamp - SnapNext.ServerTimeStamp) / TimeDelta;
                        TargetAlpha = FClamp(TargetAlpha, 0.0, 1.0);
                        CompSwap(SnapNext, SnapI, TargetAlpha, TargetTimeStamp);
                    } else {
                        CompSwap(SnapNext, None, -1.0, TargetTimeStamp);
                    }
                } else {
                    CompSwap(SnapNext, None, -1.0, TargetTimeStamp);
                }
				return;
			}
		}
        else // No sub-tick compensation
        {
			if (SnapI.ServerTimeStamp <= TargetTimeStamp) {
				CompSwap(SnapI, None, 1.0, TargetTimeStamp);
				return;
			}
		}

		I = Next;

	} until (I == DataIndex);

	I = DataIndex;
	do {
		if (Data[I] != None && Data[I].ServerTimeStamp > 0) {
			CompSwap(Data[I], None, 1.0, TargetTimeStamp);
			return;
		}
		I = (I + 1) % arraycount(Data);
	} until (I == DataIndex);
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