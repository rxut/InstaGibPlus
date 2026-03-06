class IGPlus_SavedInput extends Actor;

var IGPlus_SavedInput Next;
var IGPlus_SavedInput Prev;

var float TimeStamp;
var float Delta;
var vector SavedLocation;
var vector SavedVelocity;
var rotator SavedRotation;
var rotator SavedViewRotation;

var bool SavedDodging;
var EDodgeDir SavedDodgeDir;
var float SavedDodgeClickTimer;
var float SavedLastTimeForward;
var float SavedLastTimeBack;
var float SavedLastTimeLeft;
var float SavedLastTimeRight;

var bool bLive;
var bool bForw;
var bool bBack;
var bool bLeft;
var bool bRigh;
var bool bWalk;
var bool bDuck;
var bool bJump;
var bool bDodg;
var bool bFire;
var bool bAFir;
var bool bFFir;
var bool bFAFr;
var bool bDetReady;
var bool bDetPredictedLocal;
var int V4WeaponIndex;
var int V4ChargeData;

var int SerializedBits;

function Initialize() {
	Next = none;
	Prev = none;
}

function CopyFrom(float Delta, bbPlayer P) {
	local bool bForceFirePulse;
	local bool bForceAltPulse;
	local ST_UT_Eightball EB;

	TimeStamp = Level.TimeSeconds;
	self.Delta = Delta;
	SavedLocation = P.Location;
	SavedVelocity = P.Velocity;
	SavedRotation = P.Rotation;
	SavedViewRotation = P.ViewRotation;

	SavedDodging = P.bDodging;
	SavedDodgeDir = P.DodgeDir;
	SavedDodgeClickTimer = P.DodgeClickTimer;
	SavedLastTimeForward = P.LastTimeForward;
	SavedLastTimeBack = P.LastTimeBack;
	SavedLastTimeLeft = P.LastTimeLeft;
	SavedLastTimeRight = P.LastTimeRight;

	bLive = P.IsInState('Dying') == false;
	bForw = P.bWasForward;
	bBack = P.bWasBack;
	bLeft = P.bWasLeft;
	bRigh = P.bWasRight;
	bWalk = P.bRun != 0;
	bDuck = P.bDuck != 0;
	bJump = (P.aUp > 1.0) || P.IGPlus_PressedJumpSave;
	bDodg = P.bPressedDodge;
	EB = ST_UT_Eightball(P.Weapon);
	if (EB != none && EB.IsV4Active()) {
		bForceFirePulse = false;
		bForceAltPulse = false;
		if (P.bTraceInput && (P.bJustFired || P.bJustAltFired))
			Log("[EB] [CLI-INPACK] TS="$TimeStamp$" Src=det-hold RawBlocked JustFire="$P.bJustFired$" JustAlt="$P.bJustAltFired);
	} else {
		bForceFirePulse = P.bJustFired;
		bForceAltPulse = P.bJustAltFired;
		if (P.bTraceInput && (bForceFirePulse || bForceAltPulse) && EB != none)
			Log("[EB] [CLI-INPACK] TS="$TimeStamp$" Src=raw ForceFire="$bForceFirePulse$" ForceAlt="$bForceAltPulse);
	}
	bFire = (P.bFire != 0) || bForceFirePulse;
	bAFir = (P.bAltFire != 0) || bForceAltPulse;
	bFFir = bForceFirePulse;
	bFAFr = bForceAltPulse;
	bDetReady = P.IGPlus_V4IsWeaponReady(P.Weapon);
	V4WeaponIndex = P.IGPlus_GetV4WeaponIndex(P.Weapon);
	V4ChargeData = P.IGPlus_GetV4ChargeData();
	bDetPredictedLocal = false;

	P.bJustFired = false;
	P.bJustAltFired = false;
}

function SerializeTo(IGPlus_DataBuffer B, out float DeltaError) {
	local int Temp;
	// store delta with 20 bits precision between 0.0 and 0.4
	// 2621437.5 = ((1 << 20) - 1) / 0.4
	// int(x + 0.5) is appropriate rounding here because were only dealing with positive numbers
	Temp = int(FClamp(Delta+DeltaError, 0.0, 0.4) * 2621437.5 + 0.5); 
	DeltaError += (Delta - Temp * 0.00000038147009);
	B.AddBits(20, Temp);
	B.AddBit(bLive);
	B.AddBit(bForw);
	B.AddBit(bBack);
	B.AddBit(bLeft);
	B.AddBit(bRigh);
	B.AddBit(bWalk);
	B.AddBit(bDuck);
	B.AddBit(bJump);
	B.AddBit(bDodg);
	B.AddBit(bFire);
	B.AddBit(bAFir);
	B.AddBit(bFFir);
	B.AddBit(bFAFr);
	B.AddBit(bDetReady);
	B.AddBits(3, V4WeaponIndex);
	B.AddBits(4, V4ChargeData);
	Temp = SavedViewRotation.Pitch << 16 >> 16;
	Temp = Clamp(Temp, -16384, 16383);
	B.AddBits(15, Temp);
	B.AddBits(16, SavedViewRotation.Yaw);
}

function DeserializeFrom(IGPlus_DataBuffer B) {
	local int Temp;
	// 0.00000038147009 = 0.4 / ((1 << 20) - 1)
	B.ConsumeBits(20, Temp); Delta = Temp * 0.00000038147009;
	B.ConsumeBit(Temp); bLive = Temp != 0;
	B.ConsumeBit(Temp); bForw = Temp != 0;
	B.ConsumeBit(Temp); bBack = Temp != 0;
	B.ConsumeBit(Temp); bLeft = Temp != 0;
	B.ConsumeBit(Temp); bRigh = Temp != 0;
	B.ConsumeBit(Temp); bWalk = Temp != 0;
	B.ConsumeBit(Temp); bDuck = Temp != 0;
	B.ConsumeBit(Temp); bJump = Temp != 0;
	B.ConsumeBit(Temp); bDodg = Temp != 0;
	B.ConsumeBit(Temp); bFire = Temp != 0;
	B.ConsumeBit(Temp); bAFir = Temp != 0;
	B.ConsumeBit(Temp); bFFir = Temp != 0;
	B.ConsumeBit(Temp); bFAFr = Temp != 0;
	B.ConsumeBit(Temp); bDetReady = Temp != 0;
	B.ConsumeBits(3, V4WeaponIndex);
	B.ConsumeBits(4, V4ChargeData);
	B.ConsumeBits(15, SavedViewRotation.Pitch); SavedViewRotation.Pitch = SavedViewRotation.Pitch << 17 >> 17;
	B.ConsumeBits(16, SavedViewRotation.Yaw);
	SavedViewRotation.Roll = 0;
}

function bool IsSimilarTo(IGPlus_SavedInput Other) {
	return
		bLive == Other.bLive &&
		bForw == Other.bForw &&
		bBack == Other.bBack &&
		bLeft == Other.bLeft &&
		bRigh == Other.bRigh &&
		bWalk == Other.bWalk &&
		bDuck == Other.bDuck &&
		bJump == Other.bJump &&
		bDodg == Other.bDodg &&
		bFire == Other.bFire &&
		bAFir == Other.bAFir &&
		bFFir == Other.bFFir &&
		bFAFr == Other.bFAFr &&
		bDetReady == Other.bDetReady &&
		V4WeaponIndex == Other.V4WeaponIndex &&
		V4ChargeData == Other.V4ChargeData &&
		SavedViewRotation.Pitch == Other.SavedViewRotation.Pitch &&
		SavedViewRotation.Yaw == Other.SavedViewRotation.Yaw;
}

defaultproperties {
	bHidden=True
	DrawType=DT_None
	RemoteRole=ROLE_None
	SerializedBits=72
}
