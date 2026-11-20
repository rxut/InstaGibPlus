// Follows one pawn's animation as a client draws it, to keep the engine's tween
// from holding a pose (ULodMesh.cpp, the tween branch of GetFrame).
// While AnimFrame is below 0 the engine moves the pose it last drew toward the
// new animation's first frame on every draw. It keeps a TweenIndicator for
// that, reset to 0 only when the tween's sequence differs from CachedSeq, the
// sequence of the last tween it drew. Once the indicator passes 0.97 it stops
// blending and holds the pose until AnimFrame reaches 0, then snaps.
// So a tween into the same sequence as the last tween holds from its first
// frame. On a client that happens at every loop of a player who keeps running,
// strafing or walking: at the end of each loop the server calls LoopAnim on the
// same sequence, which only changes SimAnim.W, and the client then starts the
// first tween into that sequence again from its old start frame
// (AActor::PostNetReceive). It also happens to a tween that starts again into
// the same animation (crouch spam, StillFrRp), and to RunLG after stock
// PlayFiring swapped in RunLGFR without a tween.
// Such a tween's first frame is drawn with another sequence (bPlaceholder,
// bbPlayer.IGPlus_TweenPlaceholder). The engine resets its indicator, blends
// nothing that frame (so the pose drawn does not change) and the tween then
// blends from the next frame on.
// The engine does not draw a pawn that is out of view, but this sees every
// frame. A tween missed that way is drawn as before this fix.
class IGPlus_TweenTrack extends Object;

var name  LastSeq;
var float LastFrame;
// The engine's CachedSeq: the sequence drawn on the last tween frame.
var name  CachedSeq;
// Draw this frame with PlaceholderSeq.
var bool bPlaceholder;
var name PlaceholderSeq;

// Call once per frame with the animation as it is drawn.
function Update(name Seq, float Frame) {
	bPlaceholder = false;
	if (Frame < 0.0) {
		// A tween that starts into the sequence of the last tween.
		if (Seq == CachedSeq && (Seq != LastSeq || LastFrame >= 0.0 || Frame < LastFrame)) {
			if (Seq == 'Breath1')
				PlaceholderSeq = 'Breath2';
			else
				PlaceholderSeq = 'Breath1';
			bPlaceholder = true;
			CachedSeq = PlaceholderSeq;
		} else {
			CachedSeq = Seq;
		}
	}
	LastSeq = Seq;
	LastFrame = Frame;
}
