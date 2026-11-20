// Where one player's head is drawn while the model blends into a new animation
// (a tween), for the adaptive head hitbox (IGPlus_HeadHitbox).
//
// The engine draws a tween the way ULodMesh.cpp does in the tween branch of
// GetFrame. While AnimFrame is below 0 it moves its cached pose (the pose it
// drew last, which may itself be mid-tween) toward the new animation's first
// frame by Alpha = 1 - AnimFrame / CachedFrame every time it draws. It also
// keeps a TweenIndicator. That is reset to 0 only when a tween starts into
// another sequence than the last tween's (CachedSeq). Once it passes 0.97 the
// engine stops blending and holds the pose until AnimFrame reaches 0.
// A tween into the same sequence as the last tween (RunLG after a RunLGFR swap,
// or a tween restarted into the same animation) would hold from its first frame
// and then snap. The client draws that tween's first frame with another
// sequence, so the engine resets its indicator and blends normally. This
// follows that rule (ESeq), so client and server blend the same way.
//
// The head middle is a mean of the head's vertices, and the engine blends every
// vertex the same way, so the head middle blends the same way too. Cur is the
// middle of the head as drawn now, in pawn space (before the pawn's rotation).
// On a client this follows the animation as drawn
// (bbPlayer.IGPlus_LocationOffsetFix_AfterAll), on the server the pawn's own
// as a client draws it (UpdateRaw, from UTPlusDummy), and the rewind snapshots
// keep Cur.
class IGPlus_HeadTween extends Object;

var name   LastSeq;
var float  LastFrame;
var vector Cur;     // the middle of the head as drawn, in pawn space
var bool   bCur;    // false: no head data for this animation, Cur is unknown
var vector From;    // the middle of the head when the tween started
var float  W;       // weight of From in the drawn pose
// The engine's own tween state, changed only on tween frames.
var name   CachedSeq;
var float  CachedFrame;
var float  Indicator;
// Server (UpdateRaw): the pawn's own animation last tick, and the blend a
// client draws as stock frames instead (bbPlayer.IGPlus_FoldSnap) and how.
var name   RawSeq;
var float  RawFrame;
var name   FoldSeq;
var byte   FoldMode;

// Server, every tick: the animation as a client draws it, then Update. A blend
// that would fold the model is drawn as stock frames of the new animation
// (bbPlayer.IGPlus_FlipFix_Apply), so the head is where the client draws it.
// LoopRate: how much of the loop plays in a second (bbPlayer.IGPlus_LoopRate).
function UpdateRaw(name Seq, float Frame, float TweenRate, float LoopRate) {
	local float Drawn;

	Drawn = Frame;
	if (Frame >= 0.0) {
		FoldSeq = '';
	} else {
		if (Seq != RawSeq || RawFrame >= 0.0) {
			FoldSeq = Seq;
			FoldMode = class'bbPlayer'.static.IGPlus_FoldSnap(RawSeq, Seq);
		}
		if (Seq == FoldSeq && FoldMode == 1)
			Drawn = class'bbPlayer'.static.IGPlus_FoldStrideFrame(Frame, TweenRate, LoopRate);
		else if (Seq == FoldSeq && FoldMode == 2)
			Drawn = 0.0;
	}
	RawSeq = Seq;
	RawFrame = Frame;
	Update(Seq, Drawn);
}

// Call every frame (or tick) with the pawn's AnimSequence and AnimFrame.
function Update(name Seq, float Frame) {
	local float Alpha;
	local name ESeq;
	local vector C;
	local bool bData;

	bData = class'IGPlus_HeadHitbox'.static.DataCenter(Seq, Frame, C);
	if (Frame < 0.0) {
		// The sequence the engine sees: another one on a tween's first frame
		// when the last tween had this sequence, so it does not hold.
		ESeq = Seq;
		if (Seq == CachedSeq && (Seq != LastSeq || LastFrame >= 0.0 || Frame < LastFrame)) {
			if (Seq == 'Breath1')
				ESeq = 'Breath2';
			else
				ESeq = 'Breath1';
		}
		// A new tween blends from the head as it was drawn last. A tween
		// restarted into the same animation goes on from where it was.
		if (Seq != LastSeq || LastFrame >= 0.0) {
			From = Cur;
			if (bCur)
				W = 1.0;
			else
				W = 0.0;
		}
		if (CachedFrame < 0.0)
			Alpha = 1.0 - Frame / CachedFrame;
		else
			Alpha = -1.0;
		if (ESeq != CachedSeq)
			Indicator = 0.0;
		if (ESeq != CachedSeq || Alpha < 0.0 || Alpha > 1.0) {
			Alpha = 0.0;
			CachedSeq = ESeq;
		}
		Indicator += (1.0 - Indicator) * Alpha;
		if (Indicator > 0.97)
			Alpha = 0.0;
		W *= 1.0 - Alpha;
		CachedFrame = Frame;
		if (bData)
			C += (From - C) * W;
	}
	Cur = C;
	bCur = bData;
	LastSeq = Seq;
	LastFrame = Frame;
}

defaultproperties
{
	Indicator=1.0
}
