class IGPlus_HitFeedback extends Mutator;
// Description="<Internal>"

var bool bCheckVisibility;

// The pulse beam's marked damage call (see MutatorTakeDamage).
const IGPLUS_BEAM_NONE = 0;
const IGPLUS_BEAM_HOLD = 1;
const IGPLUS_BEAM_RELEASE = 2;
var int IGPlus_BeamMode;
var Pawn IGPlus_BeamInstigator;
var Pawn IGPlus_BeamVictim;
// Time the beam spends off a player earns its next pieces on that player a
// hit message of their own, one per steady-beam hit time, up to this many: the
// piece on reaching the player and the piece on leaving, as in stock.
const IGPLUS_BEAM_LEADMAX = 2.0;

event PostBeginPlay() {
	if (Level == none || Level.Game == none) {
		Destroy(); // spawned client-side? wtf?
		return;
	}

	if (Level.Game.BaseMutator == none)
		Level.Game.BaseMutator = self;
	else
		Level.Game.BaseMutator.AddMutator(self);

	Level.Game.RegisterDamageMutator(self);
}

function AddMutator(Mutator M) {
	if (M.Class != Class)
		super.AddMutator(M);
}

function IGPlus_HitFeedbackTracker FindTracker(Pawn P) {
	local Inventory I;

	for (I = P.Inventory; I != none; I = I.Inventory)
		if (I.IsA('IGPlus_HitFeedbackTracker'))
			return IGPlus_HitFeedbackTracker(I);

	return none;
}

function CreateTracker(Pawn P) {
	local IGPlus_HitFeedbackTracker T;
	T = Spawn(class'IGPlus_HitFeedbackTracker');
	T.GiveTo(P);
}

function ModifyPlayer(Pawn P) {
	super.ModifyPlayer(P);

	if (FindTracker(P) == none)
		CreateTracker(P);
}

function bool CheckVisibility(Pawn Orig, Pawn Dest) {
	local vector Start;
	local rotator DirYaw;
	local vector X,Y,Z;
	local vector End[7];
	local int i;

	local Pawn P;
	local vector HitLocation;
	local vector HitNormal;

	if (bCheckVisibility == false)
		return true;

	Start = Orig.Location + vect(0,0,1)*Orig.BaseEyeHeight;
	DirYaw = rotator(Dest.Location - Start);
	DirYaw.Pitch = 0;
	DirYaw.Roll = 0;

	GetAxes(DirYaw,X,Y,Z);

	End[0] = Dest.Location;                                            // center
	End[1] = End[0] + Y*Dest.CollisionRadius + Z*Dest.CollisionHeight; // top left
	End[2] = End[0] - Y*Dest.CollisionRadius + Z*Dest.CollisionHeight; // top right
	End[3] = End[0] + Y*Dest.CollisionRadius;                          // center left
	End[4] = End[0] - Y*Dest.CollisionRadius;                          // center right
	End[5] = End[0] + Y*Dest.CollisionRadius - Z*Dest.CollisionHeight; // bottom left
	End[6] = End[0] - Y*Dest.CollisionRadius - Z*Dest.CollisionHeight; // bottom right

	for (i = 0; i < arraycount(End); ++i)
		if (FastTrace(End[i], Start))
			return true;

	foreach TraceActors(class'Pawn', P, HitLocation, HitNormal, Start + vector(Orig.ViewRotation)*100000.0, Start)
		if (P == Dest)
			return true;

	return false;
}

// The pulse beam pays its damage out in pieces: a small one whenever it leaves a
// player and another when it comes back. A hit message for each piece made a
// beam shaken across a player sound like 10 to 20 hits a second, for less
// damage than a steady beam's 4 to 5. The beam marks each of its damage calls
// (ST_StarterBolt.IGPlus_BeamDamage): held pieces are added up here and go out
// as one message with the next released piece, so the hit sounds follow the
// damage dealt. Pieces the beam's time off the player has paid for are not
// held (IGPlus_BeamLead).
// The damage itself is not touched.
// The shooter's record of this victim (IGPlus_HitFeedbackTracker.IGPlus_BeamOut*):
// its slot, else a free one, else the one unused the longest.
function int IGPlus_BeamSlot(IGPlus_HitFeedbackTracker Tracker, Pawn Victim) {
	local int i, Slot;

	for (i = 0; i < arraycount(Tracker.IGPlus_BeamOutVictim); i++)
		if (Tracker.IGPlus_BeamOutVictim[i] == Victim)
			return i;
	Slot = 0;
	for (i = 0; i < arraycount(Tracker.IGPlus_BeamOutVictim); i++) {
		if (Tracker.IGPlus_BeamOutVictim[i] == none) {
			Slot = i;
			break;
		}
		if (Tracker.IGPlus_BeamOutLast[i] < Tracker.IGPlus_BeamOutLast[Slot])
			Slot = i;
	}
	Tracker.IGPlus_BeamOutVictim[Slot] = Victim;
	Tracker.IGPlus_BeamOutLast[Slot] = Level.TimeSeconds;
	Tracker.IGPlus_BeamOutLead[Slot] = IGPLUS_BEAM_LEADMAX;
	Tracker.IGPlus_BeamOutRaw[Slot] = 0;
	Tracker.IGPlus_BeamOutSince[Slot] = 0;
	return Slot;
}

// Asked by the beam for every piece it deals. True: this piece sends its hit
// message now, with whatever is held. False: it is held.
//
// The aim: never more hit messages than a steady beam would send, and no late
// ones where it can be helped.
// - A steady beam's own hit always goes out. It costs nothing.
// - Time the beam was off the player earns leads, one per Period (a steady
//   beam's time between hits), counted when the beam reaches the player again.
// - A small piece goes out at once for one lead: the pass across a player, the
//   start of a steady beam, the piece on leaving after a steady beam.
// - Without a lead it is held, until the held damage reaches a steady hit
//   (SteadyDmg). That message costs a lead too and may run one into debt, so a
//   beam shaken on and off a player faster than a steady beam hits earns no
//   leads and sounds no faster than its damage.
// Kept per shooter and victim, so a beam swept across two players is counted
// for each of them on their own.
// bContact: the piece dealt on reaching the player. bSteady: a steady beam's
// hit. Dmg: the piece's damage, before the game scales it.
function bool IGPlus_BeamLead(
	Pawn InstigatedBy, Pawn Victim,
	bool bContact, bool bSteady,
	int Dmg, float SteadyDmg, float Period
) {
	local IGPlus_HitFeedbackTracker Tracker;
	local int Slot;
	local bool bSend;

	// Nowhere to keep count: every piece sends its message, as in stock.
	if (InstigatedBy == none || Victim == none)
		return true;
	Tracker = FindTracker(InstigatedBy);
	if (Tracker == none)
		return true;

	Slot = IGPlus_BeamSlot(Tracker, Victim);

	if (bContact && Period > 0.0)
		Tracker.IGPlus_BeamOutLead[Slot] = FMin(
			IGPLUS_BEAM_LEADMAX,
			Tracker.IGPlus_BeamOutLead[Slot] + (Level.TimeSeconds - Tracker.IGPlus_BeamOutLast[Slot]) / Period
		);
	Tracker.IGPlus_BeamOutLast[Slot] = Level.TimeSeconds;

	Tracker.IGPlus_BeamOutRaw[Slot] += Dmg;
	if (bSteady) {
		bSend = true;
	} else if (Tracker.IGPlus_BeamOutRaw[Slot] >= SteadyDmg) {
		Tracker.IGPlus_BeamOutLead[Slot] = FMax(-1.0, Tracker.IGPlus_BeamOutLead[Slot] - 1.0);
		bSend = true;
	} else if (Dmg > 0 && Tracker.IGPlus_BeamOutLead[Slot] >= 1.0) {
		Tracker.IGPlus_BeamOutLead[Slot] -= 1.0;
		bSend = true;
	}

	if (bSend) {
		Tracker.IGPlus_BeamOutRaw[Slot] = 0;
		Tracker.IGPlus_BeamOutSince[Slot] = 0;
	} else if (Tracker.IGPlus_BeamOutRaw[Slot] > 0 && Tracker.IGPlus_BeamOutSince[Slot] == 0) {
		Tracker.IGPlus_BeamOutSince[Slot] = Level.TimeSeconds;
	}
	return bSend;
}

// Held damage waits for the beam's next hit on that player, but no longer than
// MaxAge. Below 0: all of it goes out now (the beam ended).
function IGPlus_BeamFlushHeld(Pawn InstigatedBy, float MaxAge) {
	local IGPlus_HitFeedbackTracker Tracker;
	local int i;

	if (InstigatedBy == none)
		return;
	Tracker = FindTracker(InstigatedBy);
	if (Tracker == none)
		return;
	for (i = 0; i < arraycount(Tracker.IGPlus_BeamOutVictim); i++) {
		if (Tracker.IGPlus_BeamOutRaw[i] <= 0)
			continue;
		if (MaxAge >= 0.0 && Level.TimeSeconds - Tracker.IGPlus_BeamOutSince[i] <= MaxAge)
			continue;
		IGPlus_BeamFlush(InstigatedBy, Tracker.IGPlus_BeamOutVictim[i]);
		Tracker.IGPlus_BeamOutRaw[i] = 0;
		Tracker.IGPlus_BeamOutSince[i] = 0;
	}
}

// The beam's next damage call, for this player only.
function IGPlus_BeamMark(Pawn InstigatedBy, Pawn Victim, bool bRelease) {
	IGPlus_BeamInstigator = InstigatedBy;
	IGPlus_BeamVictim = Victim;
	if (bRelease)
		IGPlus_BeamMode = IGPLUS_BEAM_RELEASE;
	else
		IGPlus_BeamMode = IGPLUS_BEAM_HOLD;
}

function IGPlus_BeamUnmark() {
	IGPlus_BeamMode = IGPLUS_BEAM_NONE;
	IGPlus_BeamInstigator = none;
	IGPlus_BeamVictim = none;
}

function IGPlus_SendFeedback(Pawn Victim, Pawn InstigatedBy, int TotalDamage) {
	local Pawn P;

	InstigatedBy.ReceiveLocalizedMessage(
		Class'IGPlus_HitFeedbackMessage',
		TotalDamage,
		Victim.PlayerReplicationInfo,
		InstigatedBy.PlayerReplicationInfo
	);
	// Server demos never record the call above.
	if (bbPlayer(InstigatedBy) != none)
		bbPlayer(InstigatedBy).IGPlus_DemoLocalizedMessage(
			Class'IGPlus_HitFeedbackMessage',
			TotalDamage,
			Victim.PlayerReplicationInfo,
			InstigatedBy.PlayerReplicationInfo,
			none
		);
	for (P = Level.PawnList; P != none; P = P.NextPawn)
		if (P.IsA('PlayerPawn') && PlayerPawn(P).ViewTarget == InstigatedBy)
			P.ReceiveLocalizedMessage(
				Class'IGPlus_HitFeedbackMessage',
				TotalDamage,
				Victim.PlayerReplicationInfo,
				InstigatedBy.PlayerReplicationInfo
			);
}

// The held beam damage on this player goes out as its own message.
function IGPlus_SendPending(IGPlus_HitFeedbackTracker Tracker, Pawn Victim) {
	local int Pending;
	local Pawn From;

	Pending = Tracker.IGPlus_BeamPending;
	From = Tracker.IGPlus_BeamFrom;
	Tracker.IGPlus_BeamPending = 0;
	Tracker.IGPlus_BeamFrom = none;
	Tracker.IGPlus_bBeamPending = false;
	if (From != none && From.bDeleteMe == false && CheckVisibility(From, Victim))
		IGPlus_SendFeedback(Victim, From, Pending);
}

// This shooter's held beam damage on this player goes out now.
function IGPlus_BeamFlush(Pawn InstigatedBy, Pawn Victim) {
	local IGPlus_HitFeedbackTracker Tracker;

	if (Victim == none || Victim.bDeleteMe)
		return;
	Tracker = FindTracker(Victim);
	if (Tracker != none && Tracker.IGPlus_bBeamPending && Tracker.IGPlus_BeamFrom == InstigatedBy)
		IGPlus_SendPending(Tracker, Victim);
}

function MutatorTakeDamage(
	out int ActualDamage,
	Pawn Victim,
	Pawn InstigatedBy,
	out Vector HitLocation,
	out Vector Momentum,
	name DamageType
) {
	local int TotalDamage;
	local int Mode;
	local IGPlus_HitFeedbackTracker Tracker;

	if (InstigatedBy != none && Victim != none) {
		Tracker = FindTracker(Victim);
		if (Tracker != none)
			TotalDamage = Tracker.LastDamage;

		// Only the call the beam marked: its damage can set off others.
		if (Victim == IGPlus_BeamVictim && InstigatedBy == IGPlus_BeamInstigator)
			Mode = IGPlus_BeamMode;

		// Held damage from someone else's beam, or a hit from another weapon
		// while beam damage is held: the held part goes out first, on its own.
		if (Tracker != none && Tracker.IGPlus_bBeamPending
			&& (Tracker.IGPlus_BeamFrom != InstigatedBy || Mode == IGPLUS_BEAM_NONE))
			IGPlus_SendPending(Tracker, Victim);

		// A piece that kills is never held.
		if (Mode == IGPLUS_BEAM_HOLD && Tracker != none && ActualDamage < Victim.Health) {
			Tracker.IGPlus_BeamPending += TotalDamage;
			Tracker.IGPlus_BeamFrom = InstigatedBy;
			Tracker.IGPlus_bBeamPending = true;
		} else {
			if (CheckVisibility(InstigatedBy, Victim) == false)
				return;

			if (Tracker != none && Tracker.IGPlus_bBeamPending) {
				TotalDamage += Tracker.IGPlus_BeamPending;
				Tracker.IGPlus_BeamPending = 0;
				Tracker.IGPlus_BeamFrom = none;
				Tracker.IGPlus_bBeamPending = false;
			}
			IGPlus_SendFeedback(Victim, InstigatedBy, TotalDamage);
		}
	}

	super.MutatorTakeDamage(ActualDamage, Victim, InstigatedBy, HitLocation, Momentum, DamageType);
}
