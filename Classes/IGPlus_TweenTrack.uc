// Follows one pawn's animation as a client draws it, for the tween freeze fix.
// Other players' models could stand still and then snap when an animation
// started again, for example on loop ends, in crouch spam or after firing on
// the run. This marks the first frame of such a blend, and that frame is drawn
// with another sequence (bPlaceholder, bbPlayer.IGPlus_TweenPlaceholder).
// It sees every frame, also while the pawn is out of view.
class IGPlus_TweenTrack extends Object;

var name  LastSeq;
var float LastFrame;
// The sequence the tracker drew last while blending.
var name  LastTweenSeq;
// Draw this frame with PlaceholderSeq.
var bool bPlaceholder;
var name PlaceholderSeq;

// Call once per frame with the animation as it is drawn.
function Update(name Seq, float Frame) {
	bPlaceholder = false;
	if (Frame < 0.0) {
		// A tween that needs the placeholder frame.
		if (Seq == LastTweenSeq && (Seq != LastSeq || LastFrame >= 0.0 || Frame < LastFrame)) {
			if (Seq == 'Breath1')
				PlaceholderSeq = 'Breath2';
			else
				PlaceholderSeq = 'Breath1';
			bPlaceholder = true;
			LastTweenSeq = PlaceholderSeq;
		} else {
			LastTweenSeq = Seq;
		}
	}
	LastSeq = Seq;
	LastFrame = Frame;
}
