class ShockRifleSDOMRingEffect extends ShockRifleSDOMWeaponEffect
	abstract;

// The sDOM beam's ring with no beam: NextSDOM's rifle draws its beam on its
// own (SDOM_ShockRifle).

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
) {
	if (Player.Level.NetMode == NM_DedicatedServer) return;

	PlayRing(Player, Settings, SourcePRI, TargetLocation, HitNormal);
}
