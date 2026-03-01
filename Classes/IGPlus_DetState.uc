// ===============================================================
// IGPlus_DetState: Per-weapon deterministic firing state.
//
// Lightweight Object (not Actor) holding cadence tracking,
// sequence numbers, and debug counters for the deterministic
// input-loop firing system.  Each ST weapon that supports
// deterministic firing owns one instance.  The generic cadence
// engine on IGPlus_WeaponImplementationBase operates on this
// state, keeping the weapon class itself thin.
// ===============================================================

class IGPlus_DetState extends Object;

// Cadence tracking
var bool bPrimaryHeld;
var bool bAltHeld;
var float NextPrimaryTS;
var float NextAltTS;
var float PrimaryInterval;
var float AltInterval;
var float LastShotTS;
var float LastShotInterval;
var bool bWasReady;

// Sequence tracking
var int PredPrimarySeq;
var int PredAltSeq;
var int AckPrimarySeq;
var int AckAltSeq;
var int ServerPrimarySeq;
var int ServerAltSeq;

// Fallback flag (weapon-level, disables deterministic path)
var bool bRuntimeFallback;

// Transient readiness override (set per-step by engine)
var bool bReadyOverride;

// Debug counters
var int DebugClientSeq;
var int DebugServerSeq;

function Reset(optional bool bResetFallback) {
	bPrimaryHeld = false;
	bAltHeld = false;
	NextPrimaryTS = 0.0;
	NextAltTS = 0.0;
	LastShotTS = 0.0;
	LastShotInterval = 0.0;
	bWasReady = false;
	PredPrimarySeq = 0;
	PredAltSeq = 0;
	AckPrimarySeq = 0;
	AckAltSeq = 0;
	ServerPrimarySeq = 0;
	ServerAltSeq = 0;
	DebugClientSeq = 0;
	DebugServerSeq = 0;
	bReadyOverride = false;

	if (bResetFallback)
		bRuntimeFallback = false;
}
