class IGPlus_HitFeedbackTracker extends TournamentPickup;

var int LastDamage;

// Pulse beam damage whose hit message is held back (IGPlus_HitFeedback).
var int IGPlus_BeamPending;
var Pawn IGPlus_BeamFrom;
var bool IGPlus_bBeamPending;

// As the shooter (IGPlus_HitFeedback.IGPlus_BeamLead): for the last few
// players this player's pulse beam damaged, when it last did, and how many
// more pieces may send their hit message at once.
var Pawn IGPlus_BeamOutVictim[4];
var float IGPlus_BeamOutLast[4];
var float IGPlus_BeamOutLead[4];
// The damage the beam dealt to each of them whose hit message is still held
// (before the game scales it), and when the oldest held piece was dealt.
var int IGPlus_BeamOutRaw[4];
var float IGPlus_BeamOutSince[4];

function bool HandlePickupQuery(Inventory Item) {
	if (Inventory != none)
		return Inventory.HandlePickupQuery(Item);
	return false;
}

function Inventory PrioritizeArmor(int Damage, name DamageType, vector HitLocation) {
	LastDamage = Damage;
	return super.PrioritizeArmor(Damage, DamageType, HitLocation);
}
