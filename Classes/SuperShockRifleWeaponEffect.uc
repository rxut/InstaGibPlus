class SuperShockRifleWeaponEffect extends WeaponEffect
	abstract;

// Which parts this effect draws. SuperShockRifleBeamEffect draws the beam
// only and SuperShockRifleRingEffect the ring only, for a shooter whose Hit
// Effect Source is Server (ST_SuperShockRifle.ClientTraceFire).
var bool bPlayBeam, bPlayRing;

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
	local vector SmokeLocation;
	local vector HitLocation;

	if (Player.Level.NetMode == NM_DedicatedServer) return;

	if (SourcePRI != none && SourcePRI.Owner != none && Settings.BeamOriginMode == 1) {
		SmokeLocation = GetPlayerLocation(SourcePRI.Owner) + SourceOffset;
	} else {
		SmokeLocation = SourceLocation;
	}

	if (Target != none && Settings.BeamDestinationMode == 1) {
		HitLocation = GetPlayerLocation(Target) + TargetOffset;
	} else {
		HitLocation = TargetLocation;
	}

	if (default.bPlayBeam)
		PlayBeam(Player, Settings, SourcePRI, SmokeLocation, HitLocation, HitNormal);
	if (default.bPlayRing)
		PlayRing(Player, Settings, SourcePRI, HitLocation, HitNormal);
}

static function PlayBeam(
	PlayerPawn Player,
	ClientSettings Settings,
	PlayerReplicationInfo SourcePRI,
	vector SmokeLocation,
	vector HitLocation,
	vector HitNormal
) {
	local ClientSuperShockBeam Smoke;
	local Vector DVector;
	local int NumPoints;
	local rotator SmokeRotation;
	local vector MoveAmount;
	local int Team;

	// The shooter's scoreboard entry can be missing: a beam that arrives in the
	// first moment after joining a running match names an entry this client
	// has not received yet. Its team then read 0, and a team coloured beam
	// showed red whoever fired it. Such a beam gets the default look.
	Team = -1;
	if (SourcePRI != none)
		Team = SourcePRI.Team;

	DVector = HitLocation - SmokeLocation;
	NumPoints = VSize(DVector) / 135.0;
	if ( NumPoints < 1 )
		return;
	SmokeRotation = rotator(DVector);
	SmokeRotation.roll = Rand(65535);

	if (Settings.cShockBeam == 3) return;
	if (Settings.bHideOwnBeam && SourcePRI != none &&
		(SourcePRI.Owner == Player || SourcePRI.Owner == Player.ViewTarget) &&
		Player.bBehindView == false)
		return;

	Smoke = class'ClientSuperShockBeam'.static.AllocBeam(Player);
	if (Smoke == none) return;
	Smoke.SetLocation(SmokeLocation);
	Smoke.SetRotation(SmokeRotation);
	MoveAmount = DVector / NumPoints;

	if (Settings.cShockBeam == 1) {
		Smoke.SetProperties(
			-1,
			1,
			1,
			0.27,
			MoveAmount,
			NumPoints - 1,
			Settings.bBeamEnableLight);

	} else if (Settings.cShockBeam == 2) {
		Smoke.SetProperties(
			Team,
			Settings.BeamScale,
			Settings.BeamFadeCurve,
			Settings.BeamDuration,
			MoveAmount,
			NumPoints - 1,
			Settings.bBeamEnableLight);

	} else if (Settings.cShockBeam == 4) {
		Smoke.SetProperties(
			Team,
			Settings.BeamScale,
			Settings.BeamFadeCurve,
			Settings.BeamDuration,
			MoveAmount,
			0,
			Settings.bBeamEnableLight);

		for (NumPoints = NumPoints - 1; NumPoints > 0; NumPoints--) {
			SmokeLocation += MoveAmount;
			Smoke = class'ClientSuperShockBeam'.static.AllocBeam(Player);
			if (Smoke == None) break;
			Smoke.SetLocation(SmokeLocation);
			Smoke.SetRotation(SmokeRotation);
			Smoke.SetProperties(
				Team,
				Settings.BeamScale,
				Settings.BeamFadeCurve,
				Settings.BeamDuration,
				MoveAmount,
				0,
				Settings.bBeamEnableLight);
		}
	}
}

static function PlayRing(
	PlayerPawn Player,
	ClientSettings Settings,
	PlayerReplicationInfo SourcePRI,
	vector HitLocation,
	vector HitNormal
) {
	local Actor A;

	switch(Settings.SSRRingType) {
		case 0:
			A = Player.Spawn(class'EnergyImpact',,, HitLocation,rotator(HitNormal));
			if (A != none) {
				A.RemoteRole = ROLE_None;
				A.PlayOwnedSound(Sound'UnrealShare.General.Explo1',,12.0,,2200);
			}
			break;
		case 1:
			A = Player.Spawn(class'UT_Superring2',,, HitLocation+HitNormal*8,rotator(HitNormal));
			A.RemoteRole = ROLE_None;
			break;
		case 2:
			if (SourcePRI != none && SourcePRI.Team == 1) {
				A = Player.Spawn(class'NN_UT_RingExplosion',,, HitLocation+HitNormal*8,rotator(HitNormal));
				A.RemoteRole = ROLE_None;
				A = Player.Spawn(class'EnergyImpact',,, HitLocation,rotator(HitNormal));
				if (A != none) A.RemoteRole = ROLE_None;
			} else {
				A = Player.Spawn(class'UT_Superring2',,, HitLocation+HitNormal*8,rotator(HitNormal));
				A.RemoteRole = ROLE_None;
			}
			breaK;
	}
}

defaultproperties
{
	bPlayBeam=True
	bPlayRing=True
}
