class SA_SniperRifle extends ST_SniperRifle;

// NextSA's rifle. It is ST_SniperRifle with three rules of its own, kept here
// so the sniper of the other modes does not change with them. They hold for
// client and server alike, because both read them off the weapon's class.
//
// - Client-side shell case and muzzle flash always, with no client setting:
//   NextSA's players come from the NewNet rifle, which has no such setting.
// - Instant hit feedback: the shooter's own trace plays the hit sound and
//   marker at the click (ST_SniperRifle.ClientTraceFire). The sniper is the
//   only weapon here, which the matching of the server's hit message needs.
//   With Headshot Source on Client it plays the "Head Shot" message too
//   (bbPlayer.IGPlus_ClientHeadshot).
// - It comes up after a spawn as the NewNet sniper arena rifle does, with no
//   setting: the Select animation at 1.35, and the Down animation at 1.35
//   with a 0.05 tween (bbPlayer.IGPlus_DetNewNetAnimTime has the entry gate).

simulated function bool IGPlus_ClientAnims(bbPlayer BP) {
	return BP != None;
}

simulated function bool IGPlus_InstantHitFeedback() {
	return true;
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = false;
	if ( !IsAnimating() || (AnimSequence != 'Select') )
		PlayAnim('Select', 1.35, 0.0);
	Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

simulated function TweenDown() {
	local float TweenTime;

	TweenTime = 0.05;
	bCanClientFire = false;
	if (Owner != none && Owner.IsA('bbPlayer') && bbPlayer(Owner).IGPlus_UseFastWeaponSwitch)
		TweenTime = 0.00;

	if ( IsAnimating() && (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
		PlayAnim('Down', 1.35, TweenTime);

	if (Owner.IsA('PlayerPawn') && PlayerPawn(Owner).Player.IsA('ViewPort')) {
		ZoomState = ZS_None;
		PlayerPawn(Owner).EndZoom();
	}
}

defaultproperties {
}
