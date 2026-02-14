class ST_MoverDummy extends Actor;

var Mover Actual;
var ST_MoverDummy Next;

var ST_MoverSnapshot Data[48];
var int DataIndex;

var bool bCompActive;
var vector SavedMoverLoc;

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

function CompStart(int Ping, Pawn Instigator) {
	local float TargetTimeStamp;
	local int Idx, Scans;
	local int BufSize;
	local ST_MoverSnapshot OlderSnap;
	local ST_MoverSnapshot NewerSnap;
	local float TimeDelta, Alpha;
	local vector TargetLoc;
	
	if (Actual == None || Actual.bDeleteMe || bCompActive)
		return;

	if (Instigator == None || Instigator.Base != Actual)
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
						ApplyRewind(TargetLoc, Instigator);
						return;
					}
				}
				ApplyRewind(OlderSnap.Loc, Instigator);
				return;
			}
			NewerSnap = OlderSnap;
		}

		Idx = (Idx - 1 + BufSize) % BufSize;
	}

	if (NewerSnap != None)
		ApplyRewind(NewerSnap.Loc, Instigator);
}

function ApplyRewind(vector HistoricalLoc, Pawn Instigator) {
	SavedMoverLoc = Actual.Location;
	Actual.SetLocation(HistoricalLoc);
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
	if (bCompActive) {
		bCompActive = false;

		if (Actual != None && !Actual.bDeleteMe)
			Actual.SetLocation(SavedMoverLoc);
	}
}

defaultproperties {
	bHidden=True
	RemoteRole=ROLE_None
}
