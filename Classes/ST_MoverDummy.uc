class ST_MoverDummy extends Actor;

var Mover Actual;
var ST_MoverDummy Next;

var ST_MoverSnapshot Data[48];
var int DataIndex;

var bool bCompActive;
var vector SavedMoverLoc;
var bool SavedCollideActors, SavedBlockActors, SavedBlockPlayers;
var Actor Riders[16];
var int NumRiders;

event Tick(float DeltaTime) {
	super.Tick(DeltaTime);

	if (Actual == None || Actual.bDeleteMe) {
		Disable('Tick');
		return;
	}

	if (Data[DataIndex] == None)
		Data[DataIndex] = new class'ST_MoverSnapshot';

	Data[DataIndex].Loc = Actual.Location;
	Data[DataIndex].ServerTimeStamp = Level.TimeSeconds;

	DataIndex = (DataIndex + 1) % arraycount(Data);
}

function vector LerpVector(float Alpha, vector A, vector B) {
	return A + (B - A) * Alpha;
}

// Rewind the mover to where it was Ping ms ago so compensated traces see the
// lift the target was actually standing on, not the live one.
function CompStart(int Ping) {
	local float TargetTimeStamp;
	local int Idx, Scans;
	local int BufSize;
	local ST_MoverSnapshot OlderSnap;
	local ST_MoverSnapshot NewerSnap;
	local float TimeDelta, Alpha;
	local vector TargetLoc;
	
	if (Actual == None || Actual.bDeleteMe || bCompActive)
		return;

	TargetTimeStamp = Level.TimeSeconds - 0.001 * Ping * Level.TimeDilation;

	BufSize = arraycount(Data);
	Idx = (DataIndex - 1 + BufSize) % BufSize;
	NewerSnap = None;

	for (Scans = 0; Scans < BufSize; Scans++) {
		OlderSnap = Data[Idx];

		if (OlderSnap != None && OlderSnap.ServerTimeStamp > 0) {
			if (OlderSnap.ServerTimeStamp <= TargetTimeStamp) {
				if (NewerSnap != None) {
					TimeDelta = NewerSnap.ServerTimeStamp - OlderSnap.ServerTimeStamp;
					if (TimeDelta > 0.001) {
						Alpha = (TargetTimeStamp - OlderSnap.ServerTimeStamp) / TimeDelta;
						TargetLoc = LerpVector(FClamp(Alpha, 0.0, 1.0), OlderSnap.Loc, NewerSnap.Loc);
						ApplyRewind(TargetLoc);
						return;
					}
				}
				ApplyRewind(OlderSnap.Loc);
				return;
			}
			NewerSnap = OlderSnap;
		}

		Idx = (Idx - 1 + BufSize) % BufSize;
	}

	if (NewerSnap != None)
		ApplyRewind(NewerSnap.Loc);
}

// Collision is dropped around SetLocation: a colliding mover moved onto a
// rider runs encroachment (crush / return-when-encroach) and may refuse the
// move. The rewound mover collides again at the historical position.
// SetLocation also takes everything standing on the mover off it, so we note
// who stood on it and CompEnd puts them back on.
function ApplyRewind(vector HistoricalLoc) {
	local Actor A;

	if (VSize(HistoricalLoc - Actual.Location) < 1.0)
		return;
	NumRiders = 0;
	foreach Actual.BasedActors(class'Actor', A) {
		if (NumRiders == arraycount(Riders))
			break;
		Riders[NumRiders] = A;
		NumRiders++;
	}
	SavedMoverLoc = Actual.Location;
	SavedCollideActors = Actual.bCollideActors;
	SavedBlockActors = Actual.bBlockActors;
	SavedBlockPlayers = Actual.bBlockPlayers;
	Actual.SetCollision(false, false, false);
	Actual.SetLocation(HistoricalLoc);
	Actual.SetCollision(SavedCollideActors, SavedBlockActors, SavedBlockPlayers);
	bCompActive = true;
}

function vector GetHistoricalLocation(float TargetTimeStamp) {
	local int Idx, Scans;
	local int BufSize;
	local ST_MoverSnapshot OlderSnap;
	local ST_MoverSnapshot NewerSnap;
	local float TimeDelta, Alpha;

	if (Actual == None || Actual.bDeleteMe)
		return vect(0,0,0);

	BufSize = arraycount(Data);
	Idx = (DataIndex - 1 + BufSize) % BufSize;
	NewerSnap = None;

	for (Scans = 0; Scans < BufSize; Scans++) {
		OlderSnap = Data[Idx];

		if (OlderSnap != None && OlderSnap.ServerTimeStamp > 0) {
			if (OlderSnap.ServerTimeStamp <= TargetTimeStamp) {
				if (NewerSnap != None) {
					TimeDelta = NewerSnap.ServerTimeStamp - OlderSnap.ServerTimeStamp;
					if (TimeDelta > 0.001) {
						Alpha = (TargetTimeStamp - OlderSnap.ServerTimeStamp) / TimeDelta;
						return LerpVector(FClamp(Alpha, 0.0, 1.0), OlderSnap.Loc, NewerSnap.Loc);
					}
				}
				return OlderSnap.Loc;
			}
			NewerSnap = OlderSnap;
		}

		Idx = (Idx - 1 + BufSize) % BufSize;
	}

	if (NewerSnap != None)
		return NewerSnap.Loc;

	return Actual.Location;
}

function CompEnd() {
	local int i;

	if (bCompActive) {
		bCompActive = false;

		if (Actual != None && !Actual.bDeleteMe) {
			Actual.SetCollision(false, false, false);
			Actual.SetLocation(SavedMoverLoc);
			Actual.SetCollision(SavedCollideActors, SavedBlockActors, SavedBlockPlayers);
			for (i = 0; i < NumRiders; i++)
				if (Riders[i] != None && Riders[i].bDeleteMe == false && Riders[i].Base == None)
					Riders[i].SetBase(Actual);
		}
		for (i = 0; i < NumRiders; i++)
			Riders[i] = None;
		NumRiders = 0;
	}
}

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
}
