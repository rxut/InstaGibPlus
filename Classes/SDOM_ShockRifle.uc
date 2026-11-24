class SDOM_ShockRifle extends ST_ShockRifle;

// NextSDOM's rifle. It is ST_ShockRifle with the rules of the NewNet sDOM
// rifle (NN_ShockDOMRifle), kept here so the shock rifle of the other modes
// does not change with them.
//
// - Alt fire shoots the beam too. There are no shock balls, so no combos.
// - It comes with 50 sDOM cores (ST_ShockCoreSDOM).
// - No select animation and no select sound. It fires 0.3 seconds into a
//   life, as the NewNet weapons (bbPlayer.IGPlus_DetSelectTimeFor).
// - The shooter's own trace plays the hit sound and marker at the click,
//   where the player's Hit Source is Client. The server's trace still decides.
// - The shooter's client always draws its own beam at the click, with no
//   client setting: the NewNet sDOM rifle has no such setting.
// - The ring shows as the NextIG rifle's does: at the click, or on a player
//   once the server has counted the hit, by the player's Hit Effect Source.

// Both buttons fire the beam, at the beam's rate.
simulated function bool DetProcessStep(
	float StepTS,
	rotator StepView,
	vector StepLoc,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	bool bServerSide,
	optional bool bClientPredictedStep
) {
	return Super.DetProcessStep(StepTS, StepView, StepLoc,
		bFireHeld || bAltHeld, false, bForceFire || bForceAlt, false,
		bServerSide, bClientPredictedStep);
}

// Our own trace of the beam, against the other players where the server will
// test them (bbPlayer.IGPlus_ClientShotTrace). A hit plays the hit sound and
// marker now, and the server's hit message for it does not play them again
// (bbPlayer.IGPlus_TakeClientHit). The ring goes where the trace ended, now,
// or on a player with Hit Effect Source on Server once the server's hit
// message is here (bbPlayer.IGPlus_RingHold). A ring that still waits from
// the shot before is dropped: the server did not count that hit.
simulated function HandleDetClientFire(bool bAlt, rotator StepView, vector StepLoc) {
	local bbPlayer BP;
	local WeaponSettingsRepl WS;
	local IGPlus_WeaponImplementationBase WB;
	local vector X, Y, Z, StartTrace, HitLocation, HitNormal, HitOffset;
	local Actor Other;

	Super.HandleDetClientFire(bAlt, StepView, StepLoc);

	BP = bbPlayer(Owner);
	WS = GetWeaponSettings();
	if (BP == None || WS == None)
		return;

	yModInit();
	GetAxes(StepView, X, Y, Z);
	StartTrace = StepLoc + CDO + yMod * Y + FireOffset.Z * Z;
	if (WS.ShockBeamUseReducedHitbox)
		WB = BP.IGPlus_GetWeaponImplementationBase();
	Other = BP.IGPlus_ClientShotTrace(HitLocation, HitNormal, HitOffset, StartTrace + 10000 * X, StartTrace, WB);
	BP.IGPlus_RingVictimPRI = None;
	if (Other == None || Other == BP)
		return;

	if (Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None) {
		BP.IGPlus_ClientHitPlayedTS = Level.TimeSeconds;
		class'bbPlayerStatics'.static.PlayClientHitResponse(BP, Other, WS.ShockBeamDamage, MyDamageType);
		if (BP.Settings != None && BP.Settings.HitEffectSource == HESRC_Server) {
			BP.IGPlus_RingHold(Pawn(Other), StartTrace, vect(0,0,0), HitLocation, HitOffset, HitNormal, class'ShockRifleSDOMRingEffect');
			return;
		}
	}
	BP.SendWeaponEffect(class'ShockRifleSDOMRingEffect', BP.PlayerReplicationInfo,
		StartTrace, vect(0,0,0), Other, HitLocation, HitOffset, HitNormal);
}

// The shooter's client drew its own ring (HandleDetClientFire): everyone
// else gets it here, and a server demo one record of it.
function IGPlus_ServerRing(vector HitLocation, vector HitNormal) {
	if (IsDetActive() == false) {
		Super.IGPlus_ServerRing(HitLocation, HitNormal);
		return;
	}
	class'WeaponEffect'.static.Send(Level, class'ShockRifleSDOMRingEffect', Pawn(Owner).PlayerReplicationInfo,
		HitLocation, vect(0,0,0), None, HitLocation, HitLocation, HitNormal, Pawn(Owner));
}

simulated function bool IGPlus_ClientBeam(bbPlayer BP) {
	return BP != None;
}

// Without ping compensation, offline and for bots. Global: a held button
// refires from inside the firing states, whose own Fire and ClientFire do
// nothing.
function AltFire(float Value) {
	Global.Fire(Value);
}

simulated function bool ClientAltFire(float Value) {
	return Global.ClientFire(Value);
}

simulated function PlaySelect() {
	bForceFire = false;
	bForceAltFire = false;
	bCanClientFire = true;
}

// Nothing to wait for: the weapon is up as it comes in.
state ClientActive {
	simulated function BeginState() {
		Super.BeginState();
		bWeaponUp = true;
		PlayIdleAnim();
		GotoState('');
	}
}

defaultproperties {
	PickupAmmoCount=50
	AmmoName=Class'ST_ShockCoreSDOM'
}
