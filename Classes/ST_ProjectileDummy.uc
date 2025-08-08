class ST_ProjectileDummy extends Actor;

var Projectile Actual;
var float LatestServerTimeStamp;

struct ProjectileData {
    var vector Loc, Vel, Acc;
    var rotator Rot;
    var float CollisionRadius;
    var float CollisionHeight;
    var float ServerTimeStamp;
    var bool bSnapCollideActors;
    var bool bSnapBlockActors;
    var bool bSnapBlockPlayers;
    var bool bSnapProjTarget;
};

var ProjectileData Data[32];
var int DataIndex;

var bool bCompActive;

var ST_ProjectileDummy Next;

var bool bHistoryCleared;

var bool WasColliding;
var bool WasBlockingActors;
var bool WasBlockingPlayers;
var bool WasProjTarget;

function FillData(out ProjectileData D) {
    D.Loc = Actual.Location;
    D.Vel = Actual.Velocity;
    D.Acc = Actual.Acceleration;
    D.Rot = Actual.Rotation;
    D.CollisionRadius = Actual.CollisionRadius;
    D.CollisionHeight = Actual.CollisionHeight;
    D.ServerTimeStamp = Level.TimeSeconds;
    D.bSnapCollideActors = Actual.bCollideActors;
    D.bSnapBlockActors = Actual.bBlockActors;
    D.bSnapBlockPlayers = Actual.bBlockPlayers;
    D.bSnapProjTarget = Actual.bProjTarget;
}

event Tick(float DeltaTime) {
    local int i;
    super.Tick(DeltaTime);

    if (Actual == none || Actual.bDeleteMe) {
        if (!bHistoryCleared) {
            for (i = 0; i < arraycount(Data); i++) {
                Data[i].ServerTimeStamp = 0;
            }
            DataIndex = 0;

            if (bCompActive) {
                CompEnd();
            }

            bHistoryCleared = true;
        }
        Destroy();
        return;
    } else {
        bHistoryCleared = false;
    }

    FillData(Data[DataIndex]);
    DataIndex += 1;
    if (DataIndex == arraycount(Data))
        DataIndex = 0;
}

function vector LerpVector(float Alpha, vector A, vector B) {
    return A + (B - A) * Alpha;
}

function CompStart(int Ping) {
    local float TargetTimeStamp;
    local int   Idx, Scans;
    local int   BufSize;
    
    local ProjectileData OlderSnap;
    local ProjectileData NewerSnap;
    local int NewerIdx;
    
    local float TimeDelta, Distance, Alpha;
    local vector TargetLoc;
    local float TargetCR, TargetCH;

    if (Actual == none || Actual.bDeleteMe)
        return;

    TargetTimeStamp = Level.TimeSeconds - 0.001 * Ping * Level.TimeDilation;
    
    BufSize = arraycount(Data);
    Idx = (DataIndex - 1 + BufSize) % BufSize;
    NewerIdx = -1;

    for (Scans = 0; Scans < BufSize; Scans++)
    {
        OlderSnap = Data[Idx];
        
        if (OlderSnap.ServerTimeStamp > 0)
        {
            // Found a snapshot older than our target time?
            if (OlderSnap.ServerTimeStamp <= TargetTimeStamp)
            {
                // Can we interpolate with a newer snapshot?
                if (NewerIdx >= 0)
                {
                    NewerSnap = Data[NewerIdx];
                    TimeDelta = NewerSnap.ServerTimeStamp - OlderSnap.ServerTimeStamp;
                    
                    if (TimeDelta > 0.001 && VSize(NewerSnap.Loc - OlderSnap.Loc) / TimeDelta <= 5000)
                    {
                        Alpha = (TargetTimeStamp - OlderSnap.ServerTimeStamp) / TimeDelta;
                        TargetLoc = LerpVector(FClamp(Alpha, 0.0, 1.0), OlderSnap.Loc, NewerSnap.Loc);
                        TargetCR = OlderSnap.CollisionRadius;
                        TargetCH = OlderSnap.CollisionHeight;
                        CompSwap(TargetLoc, TargetCR, TargetCH, Idx);
                        return;
                    }
                }
                
                // Extrapolate from this older snapshot
                TargetLoc = OlderSnap.Loc + OlderSnap.Vel * (TargetTimeStamp - OlderSnap.ServerTimeStamp);
                TargetCR = OlderSnap.CollisionRadius;
                TargetCH = OlderSnap.CollisionHeight;
                CompSwap(TargetLoc, TargetCR, TargetCH, Idx);
                return;
            }
            
            // This snapshot is newer than target
            NewerIdx = Idx;
        }
        
        Idx = (Idx - 1 + BufSize) % BufSize;
    }
    
    // Fallback: Extrapolate from oldest valid snapshot
    if (NewerIdx >= 0)
    {
        NewerSnap = Data[NewerIdx];
        TargetLoc = NewerSnap.Loc;
        TargetCR = NewerSnap.CollisionRadius;
        TargetCH = NewerSnap.CollisionHeight;
        CompSwap(TargetLoc, TargetCR, TargetCH, NewerIdx);
    }
}

function TakeDamage(
    int Damage,
    Pawn InstigatedBy,
    Vector Hitlocation,
    Vector Momentum,
    name DamageType
) {
    if (Actual != none && !Actual.bDeleteMe)
        Actual.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

function CompSwap(vector Loc, float CR, float CH, int HistoricalIndex) {
    local ProjectileData HistData; // To hold the historical snapshot

    if (Actual == None || Actual.bDeleteMe || bCompActive) {
        return;
    }
    HistData = Data[HistoricalIndex];
    if (HistData.ServerTimeStamp <= 0) {
         return;
    }

    WasColliding = Actual.bCollideActors;
    WasBlockingActors = Actual.bBlockActors;
    WasBlockingPlayers = Actual.bBlockPlayers;
    WasProjTarget = Actual.bProjTarget;

    Actual.SetCollision(false, false, false);
    Actual.bProjTarget = false;

    SetLocation(Loc);
    if (CollisionRadius != CR || CollisionHeight != CH) {
        SetCollisionSize(CR, CH);
    }
    
    SetCollision(HistData.bSnapCollideActors, HistData.bSnapBlockActors, HistData.bSnapBlockPlayers);
    bProjTarget = HistData.bSnapProjTarget;

    bCompActive = true;
}

function CompEnd() {
    if (bCompActive) {
        bCompActive = false;

        // Hide the Dummy
        SetCollision(false, false, false);
        bProjTarget=false;

        // Restore Actual's state saved just before CompSwap
        if (Actual != None && !Actual.bDeleteMe) {
            Actual.SetCollision(WasColliding, WasBlockingActors, WasBlockingPlayers);
            Actual.bProjTarget = WasProjTarget;
        }
    }
}

event Touch(Actor Other) {
    if (Actual != none && !Actual.bDeleteMe && bCompActive) {
        if (Actual.IsA('ShockProj') && Other.IsA('ShockProj')) {
            Actual.TakeDamage(100, Other.Instigator, Actual.Location, vect(0,0,0), 'exploded');
            Other.TakeDamage(100, Actual.Instigator, Other.Location, vect(0,0,0), 'exploded');
        }
        else if (Other.IsA('Projectile') && !Other.IsA('ST_ProjectileDummy')) {
            Actual.Touch(Other);
        }
        // Forward touch events for translocator to handle pawns
        else if (Actual.IsA('ST_TranslocatorTarget') && Other.IsA('Pawn')) {
            Actual.Touch(Other);
        }
    }
}

defaultproperties {
    bHidden=True
    RemoteRole=ROLE_None
} 