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
    local int I;
    local int NextI; // Renamed for clarity
    local float Alpha;
    local float TimeDelta;
    local float Distance;
    local vector TargetLoc;
    local float TargetCR, TargetCH;
    local ProjectileData SnapI, SnapNext;

    if (Actual == none || Actual.bDeleteMe)
        return;

    TargetTimeStamp = Level.TimeSeconds - 0.001*Ping*Level.TimeDilation;

    I = DataIndex - 1;
    if (I < 0)
        I += arraycount(Data);
    do {
        NextI = I - 1;
        if (NextI < 0)
            NextI += arraycount(Data);

        SnapI = Data[I];
        SnapNext = Data[NextI];

        if (SnapI.ServerTimeStamp <= 0) {
             I = NextI;
             continue;
        }

        if (SnapI.ServerTimeStamp <= TargetTimeStamp) {
            TargetLoc = SnapI.Loc + SnapI.Vel * (TargetTimeStamp - SnapI.ServerTimeStamp);
            TargetCR = SnapI.CollisionRadius;
            TargetCH = SnapI.CollisionHeight;
            CompSwap(TargetLoc, TargetCR, TargetCH, I); // Pass index I
            return;
        }
        else if (SnapNext.ServerTimeStamp > 0 && SnapNext.ServerTimeStamp <= TargetTimeStamp) {
            TimeDelta = SnapI.ServerTimeStamp - SnapNext.ServerTimeStamp;
            if (TimeDelta > 0.001) {
                 Distance = VSize(SnapI.Loc - SnapNext.Loc);
                 if (Distance / TimeDelta <= 5000) {
                    Alpha = (TargetTimeStamp - SnapNext.ServerTimeStamp) / TimeDelta;
                    TargetLoc = LerpVector(Alpha, SnapNext.Loc, SnapI.Loc);
                    TargetCR = SnapNext.CollisionRadius;
                    TargetCH = SnapNext.CollisionHeight;
                    CompSwap(TargetLoc, TargetCR, TargetCH, NextI);
                    return;
                 }
            }
            TargetLoc = SnapNext.Loc + SnapNext.Vel * (TargetTimeStamp - SnapNext.ServerTimeStamp);
            TargetCR = SnapNext.CollisionRadius;
            TargetCH = SnapNext.CollisionHeight;
            CompSwap(TargetLoc, TargetCR, TargetCH, NextI);
            return;
        }

        I = NextI;
    } until(I == DataIndex);

    I = DataIndex - 1;
    if (I < 0) I += arraycount(Data);
    while(Data[I].ServerTimeStamp <= 0 && I != DataIndex) {
        I = I - 1;
        if (I < 0) I += arraycount(Data);
    }
    if (Data[I].ServerTimeStamp > 0) {
        TargetLoc = Data[I].Loc;
        TargetCR = Data[I].CollisionRadius;
        TargetCH = Data[I].CollisionHeight;
        CompSwap(TargetLoc, TargetCR, TargetCH, I);
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
    }
}

defaultproperties {
    bHidden=True
    RemoteRole=ROLE_None
} 