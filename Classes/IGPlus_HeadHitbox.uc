// Where the head of a player is, for the adaptive head hitbox.
//
// IGPlus_HeadData holds the middle of the head for every frame of every player
// animation: one standard track, the average of the four stock models, used for
// every model so that no model is easier or harder to hit. The engine draws a
// player turned by its whole rotation (pitch and roll lean the model too), so
// the head is turned the same way. Only the head's forward, back and sideways
// place is used: the hitbox keeps its height. Animations the data does not have
// (custom models) use the old table of offsets, turned by yaw only.
// While the model blends into a new animation (a tween) the head blends with it
// (IGPlus_HeadTween).
class IGPlus_HeadHitbox extends Object;

// The middle of the head in pawn space (before the pawn's rotation), or false
// if there is no data for this animation.
static function bool DataCenter(name Seq, float Frame, out vector C) {
	local int i, Num, Start, N, F0, F1;
	local float F, Alpha;
	local class<IGPlus_HeadData> D;

	D = class'IGPlus_HeadData';
	Num = D.static.NumAnims();
	for (i = 0; i < Num; i++)
		if (D.static.Anim(i) == Seq)
			break;
	if (i >= Num)
		return false;

	Start = D.static.Start(i);
	N = D.static.Frames(i);
	// AnimFrame runs from 0 up to (N-1)/N over the animation. A tween into the
	// animation has a negative AnimFrame: use its first frame (the pose the
	// tween blends into, IGPlus_HeadTween blends the rest).
	F = FMax(Frame, 0.0) * N;
	F0 = Clamp(int(F), 0, N - 1);
	F1 = (F0 + 1) % N;
	Alpha = FClamp(F - F0, 0.0, 1.0);
	C = D.static.Center(Start + F0);
	C += (D.static.Center(Start + F1) - C) * Alpha;
	return true;
}

// The old offsets, for models without data.
static function vector LegacyOffset(name Seq) {
	switch (Seq) {
		case 'Breath1L': case 'Breath2L': case 'Breath1': case 'Breath2': return vect(2,0,0);
		case 'CockGun': case 'CockGunL': return vect(-2.5,0,0);
		case 'StrafeL': return vect(0,-3.5,0);
		case 'StrafeR': return vect(0,3.5,0);
		case 'RunLg': case 'RunSm': case 'RunLgFr': case 'RunSmFr':
		case 'WalkLg': case 'WalkSm': case 'WalkLgFr': case 'WalkSmFr': return vect(3.5,0,0);
		case 'BackRun': return vect(-2.5,0,0);
		case 'DodgeL': return vect(0,-3,0);
		case 'DodgeR': return vect(0,3,0);
		case 'DodgeF': return vect(2.5,0,0);
		case 'DodgeB': return vect(-4,0,0);
		case 'AimDnLg': case 'AimDnSm': return vect(6,0,0);
		case 'AimUpLg': case 'AimUpSm': return vect(-6,0,0);
	}
	return vect(0,0,0);
}

// The middle of the head hitbox relative to the pawn's location.
// The hitbox keeps its height (StandZ, its top on the
// top of the collision cylinder) and only moves forward, back and to the sides
// with the head, leaning included. A shot has to hit the collision cylinder
// before the head is tested, so the move is kept to MaxMove: a head further out
// would stick out of the cylinder, and that part could not be hit.
// With bDrawn, Drawn is the middle of the head as the model is drawn
// (IGPlus_HeadTween.Cur, mid-tween too), and Seq and Frame are not used.
static function vector HeadOffset(rotator Rot, name Seq, float Frame, float StandZ, float MaxMove,
	optional bool bDrawn, optional vector Drawn
) {
	local vector C;
	local rotator YawRot;
	local float Move;

	C = Drawn;
	if (bDrawn || DataCenter(Seq, Frame, C)) {
		C = C >> Rot;
		C.Z = 0;
		Move = VSize(C);
		if (Move > MaxMove)
			C *= FMax(MaxMove, 0.0) / Move;
		C.Z = StandZ;
		return C;
	}

	YawRot.Yaw = Rot.Yaw;
	return ((LegacyOffset(Seq) * vect(1,1,0)) >> YawRot) + vect(0,0,1) * StandZ;
}

defaultproperties
{
}
