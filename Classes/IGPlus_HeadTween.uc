// Follows the middle of a player's head as it is drawn, for the head hitbox.
// The server and the client both update it once per frame with the player's animation.
// While the animation plays, the head is at that frame's position.
// During a blend it moves in a straight line to the first pose of the new animation.
// It stands still when a blend starts and whenever the animation drawn for the blend changes,
// which includes the frame after a placeholder. It also stands still at the very end of a blend.
class IGPlus_HeadTween extends Object;

// With less of a blend left than this, the head holds so the hitbox stays on the drawn model.
const MinBlendLeft = 0.03;

var vector Cur;		// head middle as drawn now
var bool bCur;		// whether Cur is known

var name LastSeq;
var float LastFrame;
var name DrawnSeq;	// drawn on the latest update with a negative frame, can be a placeholder
var float StillFrame;	// frame at which the blend last began, restarted or changed what is drawn

function Update(name Seq, float Frame)
{
	local vector Pose;
	local name NowDrawn;
	local bool bKnown, bBegins, bStandStill;

	bKnown = class'IGPlus_HeadHitbox'.static.DataCenter(Seq, Frame, Pose);

	if (Frame < 0)
	{
		bBegins = Seq != LastSeq || LastFrame >= 0 || Frame < LastFrame;
		NowDrawn = Seq;

		// A blend into the animation that was drawn last shows a placeholder first.
		if (bBegins && Seq == DrawnSeq)
		{
			NowDrawn = 'Breath1';
			if (Seq == 'Breath1')
				NowDrawn = 'Breath2';
		}

		bStandStill = bBegins || NowDrawn != DrawnSeq;
		DrawnSeq = NowDrawn;
		if (bStandStill)
			StillFrame = Frame;
	}

	if (bKnown)
	{
		if (Frame >= 0 || !bCur)
			Cur = Pose;
		// Scaling what is left by each step keeps the line and the rate of the whole blend.
		// LastFrame and StillFrame are below zero here, as any other case has just begun a blend.
		else if (!bStandStill && Frame != LastFrame && Frame / StillFrame >= MinBlendLeft)
			Cur = Pose + (Cur - Pose) * (Frame / LastFrame);
	}

	bCur = bKnown;
	LastSeq = Seq;
	LastFrame = Frame;
}
