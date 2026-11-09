class WeaponEffect extends Object
	abstract;

static function Play(
	PlayerPawn Player,
	ClientSettings Settings,
	PlayerReplicationInfo SourcePRI,
	vector SourceLocation,
	vector SourceOffset,
	Actor Target,
	vector TargetLocation,
	vector TargetOffset,
	vector HitNormal
);

static function Send(
	LevelInfo Level,
	class<WeaponEffect> Effect,
	PlayerReplicationInfo SourcePRI,
	vector SourceLocation,
	vector SourceOffset,
	Actor Target,
	vector TargetLocation,
	vector TargetOffset,
	vector HitNormal,
	optional Pawn Exclude
) {
	local Pawn P;
	local bbPlayer DemoSender;

	for (P = Level.PawnList; P != none; P = P.NextPawn) {
		if (DemoSender == none && bbPlayer(P) != none)
			DemoSender = bbPlayer(P);
		if (P == Exclude) continue;
		if (bbPlayer(P) != none)
			bbPlayer(P).SendWeaponEffect(
				Effect,
				SourcePRI,
				SourceLocation,
				SourceOffset,
				Target,
				TargetLocation,
				TargetOffset,
				HitNormal);
		else if (bbCHSpectator(P) != none)
			bbCHSpectator(P).SendWeaponEffect(
				Effect,
				SourcePRI,
				SourceLocation,
				SourceOffset,
				Target,
				TargetLocation,
				TargetOffset,
				HitNormal);
	}

	// A server demo gets none of the calls above (they are for live clients
	// and client demos). One player records it once for the server demo.
	if (DemoSender != none && Level.NetMode != NM_Client)
		DemoSender.IGPlus_DemoWeaponEffect(
			Effect,
			SourcePRI,
			SourceLocation,
			SourceOffset,
			Target,
			TargetLocation,
			TargetOffset,
			HitNormal * 32767);
}

static final function vector GetPlayerLocation(Actor PotentialPlayer) {
	if (PotentialPlayer.IsA('bbPlayer'))
		return bbPlayer(PotentialPlayer).IGPlus_CurrentLocation();
	return PotentialPlayer.Location;
}
