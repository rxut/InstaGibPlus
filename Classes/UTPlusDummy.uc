class UTPlusDummy extends Actor;

var Pawn Actual;
var float LatestClientTimeStamp;
var float EyeHeight;
var float BaseEyeHeight;
var bool bHistoryCleared;

var bool WasColliding;
var bool WasBlockingActors;
var bool WasBlockingPlayers;
var bool WasProjTarget;

struct DummyData {
	var vector Loc, Vel, Acc;
	var rotator Rot, VR;
	var float BaseEyeHeight;
	var float EyeHeight;
	var float CollisionRadius;
	var float CollisionHeight;
	var float ServerTimeStamp;
	var float ClientTimeStamp;
};

var DummyData Data[32];
var int DataIndex;

var bool bCompActive;

var UTPlusDummy Next;

var IGPlus_WeaponImplementation WImp;

simulated function PostBeginPlay()
{

	if (ROLE == ROLE_Authority)
	{
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
	}

	Super.PostBeginPlay();
}

function FillData(out DummyData D) {
	D.Loc = Actual.Location;
	D.Vel = Actual.Velocity;
	D.Acc = Actual.Acceleration;
	D.Rot = Actual.Rotation;
	D.VR = Actual.ViewRotation;
	D.BaseEyeHeight = Actual.BaseEyeHeight;
	D.EyeHeight = Actual.EyeHeight;
	D.CollisionRadius = Actual.CollisionRadius;
	D.CollisionHeight = Actual.CollisionHeight;
	D.ServerTimeStamp = Level.TimeSeconds;
	if (bCompActive && Actual.IsA('PlayerPawn'))
		D.ClientTimeStamp = PlayerPawn(Actual).CurrentTimeStamp;
}

event Tick(float DeltaTime) {
    local int i;
    local PlayerPawn PP;
    super.Tick(DeltaTime);

    if (Actual == none || Actual.bDeleteMe) {
        Disable('Tick');
    }

    PP = PlayerPawn(Actual);

    if (PP != None) {
        if (PP.GetStateName() == 'Dying') {
            if (PP.Player != None && !bHistoryCleared) {
                for (i = 0; i < arraycount(Data); i++) {
                    Data[i].ServerTimeStamp = 0;
                }
                DataIndex = 0;
                CompEnd();
                bHistoryCleared = true;
                return;
            }
        } else {
            bHistoryCleared = false;
        }
        
        if (PP.CurrentTimeStamp > LatestClientTimeStamp) {
            LatestClientTimeStamp = PP.CurrentTimeStamp;
            FillData(Data[DataIndex]);
            DataIndex = (DataIndex + 1) % arraycount(Data);
        }
    } else {
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
    local float Alpha;
    local float TimeDelta;
    local float Distance;

	if (Actual == none || Actual.bDeleteMe)
    	return;

   // Cap ping compensation
   if (Ping > WImp.WeaponSettings.PingCompensationMax)
        Ping = WImp.WeaponSettings.PingCompensationMax;

    TargetTimeStamp = Level.TimeSeconds - 0.001*Ping*Level.TimeDilation;

    I = DataIndex - 1;
    if (I < 0)
        I += arraycount(Data);
    do {
        Next = I - 1;
        if (Next < 0)
            Next += arraycount(Data);

        if (Data[I].ServerTimeStamp <= TargetTimeStamp) {
            CompSwap(
                Data[I].Loc + Data[I].Vel * (TargetTimeStamp - Data[I].ServerTimeStamp),
                Data[I].EyeHeight,
                Data[I].BaseEyeHeight,
                Data[I].CollisionRadius,
                Data[I].CollisionHeight
            );
            return;
        } else if (Data[Next].ServerTimeStamp <= TargetTimeStamp) {
            // Calculate time and distance for continuity check
            TimeDelta = Data[I].ServerTimeStamp - Data[Next].ServerTimeStamp;
            Distance = VSize(Data[I].Loc - Data[Next].Loc);

            // Continuity check
            if (TimeDelta > 0 && Distance / TimeDelta <= 2500) { // Threshold for continuous motion
                Alpha = (TargetTimeStamp - Data[Next].ServerTimeStamp) / TimeDelta;
                CompSwap(
                    LerpVector(Alpha, Data[Next].Loc, Data[I].Loc),
                    Data[Next].EyeHeight,
                    Data[Next].BaseEyeHeight,
                    Data[Next].CollisionRadius,
                    Data[Next].CollisionHeight
                );
            } else {
                // Use original velocity extrapolation
                CompSwap(
                    Data[Next].Loc + Data[Next].Vel * (TargetTimeStamp - Data[Next].ServerTimeStamp),
                    Data[Next].EyeHeight,
                    Data[Next].BaseEyeHeight,
                    Data[Next].CollisionRadius,
                    Data[Next].CollisionHeight
                );
            }
            return;
        }

        I = Next;
    } until(I == DataIndex);

    // Fallback to last known info
    CompSwap(
        Data[I].Loc,
        Data[I].EyeHeight,
        Data[I].BaseEyeHeight,
        Data[I].CollisionRadius,
        Data[I].CollisionHeight
    );
}

function TakeDamage(
    int Damage,
    Pawn InstigatedBy,
    Vector Hitlocation,
    Vector Momentum,
    name DamageType
) {
    if (bCompActive && Actual != none)
        Actual.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

function CompSwap(vector Loc, float EH, float BEH, float CR, float CH) {

    if (bCompActive)
        return;
    
    WasColliding = Actual.bCollideActors;
    WasBlockingActors = Actual.bBlockActors;
    WasBlockingPlayers = Actual.bBlockPlayers;
    WasProjTarget = Actual.bProjTarget;
        
    Actual.SetCollision(false, false, false);
    Actual.bProjTarget = false;
    
    EyeHeight = EH;
    BaseEyeHeight = BEH;
    
    // Only change collision size if needed
    if (CollisionRadius != CR || CollisionHeight != CH)
        SetCollisionSize(CR, CH);
    
    // Only set collision if it's different from current state
    if (bCollideActors != WasColliding || bBlockActors != WasBlockingActors || bBlockPlayers != WasBlockingPlayers)
        SetCollision(WasColliding, WasBlockingActors, WasBlockingPlayers);
    
    SetLocation(Loc);

    if (bProjTarget != WasProjTarget)
        bProjTarget = WasProjTarget;
    
    bCompActive = true;
}

function CompEnd() {
    if (bCompActive) {
        bCompActive = false;
        
        SetCollision(false, false, false);
        bProjTarget = false;
        
        // Restore the actual pawn's original collision state
        Actual.SetCollision(WasColliding, WasBlockingActors, WasBlockingPlayers);
        Actual.bProjTarget = WasProjTarget;
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
