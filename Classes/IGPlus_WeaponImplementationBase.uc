class IGPlus_WeaponImplementationBase extends IGPlus_WeaponImplementation;

var ST_HitTestHelper CollChecker;
var ST_HitTestHelper HitTestHelper;

// Shock combo explosion tracking for translocator simulation
struct RecentExplosion {
    var vector Location;
    var float TimeStamp;
    var float Radius;
    var float Damage;
    var float Momentum;
    var Pawn Instigator;
};
var RecentExplosion RecentExplosions[16];
var int ExplosionWriteIndex;

var float CachedTickRate;

function float IGPlus_GetSnapshotInterpRewindMs(Pawn Instigator) {
    local bbPlayer bbP;
    local float AcceptedAge;

    if (Instigator == None)
        return 0.0;

    bbP = bbPlayer(Instigator);
    if (bbP == None || bbP.IGPlus_EnableSnapshotInterpolation == false)
        return 0.0;

    AcceptedAge = bbP.Level.TimeSeconds - bbP.IGPlus_ServerSnapInterpLastAcceptedTime;
    if (AcceptedAge < 0.0)
        AcceptedAge = 0.0;

    if (bbP.IGPlus_ServerSnapInterpDelayValid &&
        bbP.IGPlus_ServerSnapInterpTrusted &&
        AcceptedAge <= 1.0
    ) {
        return FMax(0.0, bbP.IGPlus_ServerSnapInterpDelayMsSmoothed);
    }

    if (bbP.zzUTPure != None && bbP.zzUTPure.Settings != None)
        return FMax(0.0, bbP.zzUTPure.Settings.SnapshotInterpRewindMs);

    return 0.0;
}

function PostBeginPlay() {
	super.PostBeginPlay();

	HitTestHelper = Spawn(class'ST_HitTestHelper');
	CollChecker = Spawn(class'ST_HitTestHelper');
	CollChecker.SetCollision(true, false, false);

	if (Level.NetMode == NM_DedicatedServer)
		CachedTickRate = float(int(ConsoleCommand("get ini:Engine.Engine.NetworkDevice NetServerMaxTickRate")));
	else
		CachedTickRate = 120.0;

	if (CachedTickRate <= 0.0)
		CachedTickRate = 30.0;
}

// Register a shock combo explosion for translocator simulation tracking
function RegisterExplosion(vector ExpLocation, float ExpRadius, float ExpDamage, float ExpMomentum, Pawn ExpInstigator) {
    RecentExplosions[ExplosionWriteIndex].Location = ExpLocation;
    RecentExplosions[ExplosionWriteIndex].TimeStamp = Level.TimeSeconds;
    RecentExplosions[ExplosionWriteIndex].Radius = ExpRadius;
    RecentExplosions[ExplosionWriteIndex].Damage = ExpDamage;
    RecentExplosions[ExplosionWriteIndex].Momentum = ExpMomentum;
    RecentExplosions[ExplosionWriteIndex].Instigator = ExpInstigator;

    ExplosionWriteIndex = (ExplosionWriteIndex + 1) % 16;
}

// Check if a location is within any recent explosion radius
// MaxAge is how far back in time to check (in seconds)
function bool CheckRecentExplosions(ST_TranslocatorTarget TTarget, float MaxAge) {
    local int i;
    local float Age;
    local vector Delta;
    local float Dist;
    local vector MomentumDir;

    if (TTarget == None || TTarget.bDeleteMe)
        return true;

    for (i = 0; i < 16; i++) {
        // Skip empty or old entries
        if (RecentExplosions[i].TimeStamp <= 0)
            continue;

        Age = Level.TimeSeconds - RecentExplosions[i].TimeStamp;
        if (Age > MaxAge)
            continue;

        // Skip explosions from the same player
        if (RecentExplosions[i].Instigator == TTarget.Instigator)
            continue;

        // Check distance to explosion
        Delta = TTarget.Location - RecentExplosions[i].Location;
        Dist = VSize(Delta);

        if (Dist <= RecentExplosions[i].Radius) {
            // Apply damage scaled by distance (like HurtRadius)
            MomentumDir = Normal(Delta);
            TTarget.TakeDamage(
                RecentExplosions[i].Damage * (1.0 - Dist / RecentExplosions[i].Radius),
                RecentExplosions[i].Instigator,
                TTarget.Location,
                MomentumDir * RecentExplosions[i].Momentum * (1.0 - Dist / RecentExplosions[i].Radius),
                'jolted'
            );

            if (TTarget == None || TTarget.bDeleteMe)
                return true;
        }
    }

    return false;
}

function EnhancedHurtRadius(
	Actor  Source,
	float  DamageAmount,
	float  DamageRadius,
	name   DamageName,
	float  Momentum,
	vector HitLocation,
	optional bool bIsRazor2Alt,
	optional float SelfDamageAmount,
	optional float SelfMomentum
) {
	local actor Victim;
	local float damageScale, dist;
	local float DamageDiffraction;
	local float MomentumScale;
	local vector MomentumDelta, MomentumDir;
	local vector Delta, DeltaXY;
	local vector Closest;
	local vector dir;
	local float ActualDamage, ActualMomentum;
	local bool bIsInstigator;

	local vector SourceGeoLocation, SourceGeoNormal;
	local vector VictimGeoLocation, VictimGeoNormal;

	local UTPure PureRef;
	local bbPlayer bbP;

	bbP = bbPlayer(Source.Instigator);
	
	if (bbP != None)
		PureRef = bbP.zzUTPure;

	if (Source.bHurtEntry)
		return;

	Source.bHurtEntry = true;

	if (CollChecker == none || CollChecker.bDeleteMe) {
		CollChecker = Spawn(class'ST_HitTestHelper',self, , Source.Location);
	}

	CollChecker.SetCollision(true, false, false);
	CollChecker.SetCollisionSize(DamageRadius, DamageRadius);
	CollChecker.SetLocation(HitLocation);

	foreach Source.VisibleCollidingActors(class'Actor', Victim, DamageRadius, HitLocation, , true) {
		if (Victim.IsA('Brush') == false)
			continue;

		dir = Victim.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir / dist; 
		damageScale = 1 - FMax(0, (dist - Victim.CollisionRadius) / DamageRadius);
		Victim.TakeDamage(
			damageScale * DamageAmount,
			Instigator, 
			Victim.Location - 0.5 * (Victim.CollisionHeight + Victim.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageName
		);
	}

	foreach CollChecker.TouchingActors(class'Actor', Victim) {
		if (Victim == Source)
			continue;

		bIsInstigator = (Victim == Source.Instigator);

		if (Victim.IsA('StationaryPawn') && WeaponSettings.bEnhancedSplashIgnoreStationaryPawns) {
			// Revert to legacy handling
			dir = Victim.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			damageScale = 1 - FMax(0,(dist - Victim.CollisionRadius)/DamageRadius);
		} else {
			Delta = Victim.Location - HitLocation;
			DeltaXY = Delta * vect(1.0, 1.0, 0.0);
			dist = VSize(Delta);
			dir = Normal(Delta);

			if (Abs(Delta.Z) <= Victim.CollisionHeight) {
				Closest = HitLocation + Normal(DeltaXY) * (VSize(DeltaXY) - Victim.CollisionRadius);
			} else if (VSize(DeltaXY) <= Victim.CollisionRadius) {
				if (Delta.Z > 0.0)
					Closest = HitLocation + FMax(Delta.Z - Victim.CollisionHeight, 0.0) * vect(0.0, 0.0, 1.0);
				else
					Closest = HitLocation + FMin(Delta.Z + Victim.CollisionHeight, 0.0) * vect(0.0, 0.0, 1.0);
			} else {
				// Closest point must be on the cylinder rims, find out where
				Closest = Victim.Location + dir * (Source.CollisionRadius / VSize(dir * vect(1.0, 1.0, 0.0)));
				if (Delta.Z > 0.0)
					Closest.Z = Victim.Location.Z - Victim.CollisionHeight;
				else
					Closest.Z = Victim.Location.Z + Victim.CollisionHeight;
			}

			Delta = Closest - HitLocation;
			if (VSize(Delta) > CollChecker.CollisionRadius)
				continue;

			dist = VSize(Delta);
			dir = Normal(Delta);

			if (FastTrace(Victim.Location, Source.Location) == false) {

				if (PureRef != None && PureRef.bCompensationIsActive)
				{	
					// Only UTPlusDummy gets a second chance trace
                    if (Victim.IsA('UTPlusDummy') == false)
                        continue;
                }
				else
                {
                    // Only actual Pawns get a second chance trace.
                    if (Victim.IsA('Pawn') == false)
                        continue;
                }

				// give Pawns a second chance to be hit
				if (HitTestHelper == none || HitTestHelper.bDeleteMe)
					HitTestHelper = Spawn(class'ST_HitTestHelper', self, , Source.Location);
				
				HitTestHelper.bCollideWorld = true;
				HitTestHelper.SetLocation(Source.Location);

				HitTestHelper.FlyTowards(Victim.Location, DamageRadius);
				if (FastTrace(Victim.Location, HitTestHelper.Location) == false)
					continue;

				Trace(SourceGeoLocation, SourceGeoNormal, Closest, HitLocation, false);
				Trace(VictimGeoLocation, VictimGeoNormal, HitLocation, Closest, false);

				DamageDiffraction =
					FClamp(WeaponSettings.SplashMaxDiffraction, 0.0, 1.0) *
					FClamp((VSize(VictimGeoLocation - SourceGeoLocation) - WeaponSettings.SplashMinDiffractionDistance) / dist, 0.0, 1.0);
			}

			MomentumDelta = Victim.Location - HitLocation;
			MomentumDir = Normal(MomentumDelta);

			if (bIsRazor2Alt)
				MomentumDir.Z = FMin(0.45, MomentumDir.Z);

			damageScale = FMin(1.0 - dist/DamageRadius, 1.0); // apply upper bound to damage
			damageScale *= (1.0 - DamageDiffraction);
			MomentumScale = FClamp(1.0 - (VSize(MomentumDelta) - Victim.CollisionRadius)/DamageRadius, 0.0, 1.0);
			MomentumScale *= (1.0 - DamageDiffraction);
		}
		
		if (damageScale <= 0.0)
			continue;

		if (bIsInstigator && SelfDamageAmount > 0) {
			ActualDamage = SelfDamageAmount;
			ActualMomentum = SelfMomentum;
		} else {
			ActualDamage = DamageAmount;
			ActualMomentum = Momentum;
		}

		Victim.TakeDamage(
			damageScale * ActualDamage,
			Source.Instigator,
			Victim.Location - 0.5 * (Victim.CollisionRadius + Victim.CollisionHeight) * dir,
			(MomentumScale * ActualMomentum * MomentumDir),
			DamageName
		);
	}

	CollChecker.SetCollision(false, false, false);

	Source.bHurtEntry = false;
}

function SplashDamageWithSelfDamage(
	Actor Source,
	float DamageAmount,
	float SelfDamageAmount,
	float DamageRadius,
	name DamageName,
	float Momentum,
	float SelfMomentum,
	vector HitLocation,
	optional bool bUseEnhancedSplash
) {
	if (bUseEnhancedSplash) {
		EnhancedHurtRadius(Source, DamageAmount, DamageRadius, DamageName, Momentum, HitLocation, false, SelfDamageAmount, SelfMomentum);
	} else {
		HurtRadiusWithSelfDamage(Source, DamageAmount, SelfDamageAmount, DamageRadius, DamageName, Momentum, SelfMomentum, HitLocation);
	}
}

function HurtRadiusWithSelfDamage(
	Actor Source,
	float DamageAmount,
	float SelfDamageAmount,
	float DamageRadius,
	name DamageName,
	float Momentum,
	float SelfMomentum,
	vector HitLocation
) {
	local Actor Victim;
	local float damageScale, dist;
	local vector dir;
	local float ActualDamage, ActualMomentum;
	local bool bIsInstigator;

	if (Source.bHurtEntry)
		return;

	Source.bHurtEntry = true;

	foreach Source.VisibleCollidingActors(class'Actor', Victim, DamageRadius, HitLocation) {
		if (Victim == Source)
			continue;

		bIsInstigator = (Victim == Source.Instigator);

		dir = Victim.Location - HitLocation;
		dist = FMax(1, VSize(dir));
		dir = dir / dist;
		damageScale = 1.0 - FMax(0, (dist - Victim.CollisionRadius) / DamageRadius);

		if (damageScale <= 0.0)
			continue;

		if (bIsInstigator) {
			ActualDamage = SelfDamageAmount;
			ActualMomentum = SelfMomentum;
		} else {
			ActualDamage = DamageAmount;
			ActualMomentum = Momentum;
		}

		Victim.TakeDamage(
			damageScale * ActualDamage,
			Source.Instigator,
			Victim.Location - 0.5 * (Victim.CollisionHeight + Victim.CollisionRadius) * dir,
			damageScale * ActualMomentum * dir,
			DamageName
		);
	}

	Source.bHurtEntry = false;
}

final simulated function float CalcDuckFraction(float CurrentEyeHeight, float DefaultBaseEyeHeight) {
	if (DefaultBaseEyeHeight <= 0.0)
		return 0.0;
	return FClamp(1.0 - (CurrentEyeHeight / DefaultBaseEyeHeight), 0.0, 1.0);
}

final simulated function float GetPawnDuckFraction(Pawn P) {
	local bbPlayer bbP;
	bbP = bbPlayer(P);
	if (bbP != none) {
		if (Role < ROLE_Authority)
			return FClamp(bbP.DuckFractionRepl/255.0, 0.0, 1.0);
		else
			return FClamp(bbP.DuckFraction, 0.0, 1.0);
	} else {
		return CalcDuckFraction(P.EyeHeight, P.default.BaseEyeHeight);
	}
}

final simulated function float GetDummyDuckFraction(UTPlusDummy D) {
	return CalcDuckFraction(D.EyeHeight, D.BaseEyeHeight);
}

final simulated function float GetHeadHalfHeight(float DuckFrac) {
	return Lerp(DuckFrac, WSettingsRepl.HeadHalfHeight, 0);
}

final simulated function float GetBodyHalfHeight(float CollHeight, float DuckFrac) {
	return Lerp(DuckFrac,
		CollHeight - WSettingsRepl.HeadHalfHeight,
		(1.3 * 0.5) * CollHeight
	);
}

final simulated function float GetBodyOffsetZ(float CollHeight, float DuckFrac) {
	return Lerp(DuckFrac,
		-WSettingsRepl.HeadHalfHeight,
		-(0.7 * 0.5) * CollHeight
	);
}

simulated function vector GetAnimationHeadOffset(Pawn P) {
	local vector BaseOffset;
	if (P == none)
		return vect(0,0,0);
	BaseOffset = GetAnimationHeadOffsetFromState(P.class.name, P.AnimSequence, P.AnimFrame);
	return BaseOffset >> P.Rotation;
}

final simulated function bool CheckHitboxInternal(
	vector HitLocation,
	vector Direction,
	vector HitboxCenter,
	float HitboxRadius,
	float HitboxHalfHeight,
	float TraceExtent
) {
	local ST_HitTestHelper HitActor;
	local vector HitLoc, HitNorm;
	local vector EndTrace, StartTrace;
	local vector BackwardHitLoc, BackwardHitNorm;
	local vector HitboxTraceStart;

	if (CollChecker == none || CollChecker.bDeleteMe)
		CollChecker = Spawn(class'ST_HitTestHelper', self, , HitboxCenter);

	CollChecker.SetCollision(true, false, false);
	CollChecker.SetCollisionSize(HitboxRadius, HitboxHalfHeight);
	CollChecker.SetLocation(HitboxCenter);

	EndTrace = HitLocation + Direction * TraceExtent;
	StartTrace = HitLocation - Direction * TraceExtent;

	if (Trace(BackwardHitLoc, BackwardHitNorm, StartTrace, HitLocation, false) == None)
		HitboxTraceStart = StartTrace;
	else
		HitboxTraceStart = BackwardHitLoc;

	foreach TraceActors(class'ST_HitTestHelper', HitActor, HitLoc, HitNorm, EndTrace, HitboxTraceStart) {
		if (HitActor == CollChecker) {
			CollChecker.SetCollision(false, false, false);
			return true;
		}
	}

	CollChecker.SetCollision(false, false, false);
	return false;
}

simulated function bool CheckHeadShot(Pawn P, vector HitLocation, vector Direction) {
	local float DuckFrac;
	local float BodyOffsetZ, BodyHalfHeight, HeadHH;
	local vector AnimOffset, HitboxCenter;

	if (P == none)
		return false;

	if (HitLocation.Z - P.Location.Z <= 0.3 * P.CollisionHeight)
		return false;

	DuckFrac = GetPawnDuckFraction(P);
	BodyOffsetZ = GetBodyOffsetZ(P.CollisionHeight, DuckFrac);
	BodyHalfHeight = GetBodyHalfHeight(P.CollisionHeight, DuckFrac);
	HeadHH = GetHeadHalfHeight(DuckFrac);

	if (HeadHH <= 0.0)
		return false;

	if (WSettingsRepl.bEnableAnimationAdaptiveHeadHitbox)
		AnimOffset = GetAnimationHeadOffset(P);
	else
		AnimOffset = vect(0,0,0);

	HitboxCenter = P.Location + AnimOffset + vect(0,0,1) * (BodyOffsetZ + BodyHalfHeight + HeadHH);

	return CheckHitboxInternal(HitLocation, Direction, HitboxCenter,
		WSettingsRepl.HeadRadius, HeadHH, P.CollisionRadius + P.CollisionHeight);
}

simulated function bool CheckBodyShot(Pawn P, vector HitLocation, vector Direction, optional vector PositionOverride) {
	local float DuckFrac, HalfHeight, OffsetZ;
	local vector BasePosition;

	if (P == none)
		return false;

	DuckFrac = GetPawnDuckFraction(P);
	HalfHeight = GetBodyHalfHeight(P.CollisionHeight, DuckFrac);
	OffsetZ = GetBodyOffsetZ(P.CollisionHeight, DuckFrac);

	if (PositionOverride != vect(0,0,0))
		BasePosition = PositionOverride;
	else
		BasePosition = P.Location;

	return CheckHitboxInternal(HitLocation, Direction,
		BasePosition + vect(0,0,1) * OffsetZ,
		P.CollisionRadius, HalfHeight, P.CollisionRadius + P.CollisionHeight);
}

simulated function vector GetAnimationHeadOffsetFromState(name PClassName, name AnimSequence, float AnimFrame) {
	local vector BaseOffset;

	// Potential to use the class name and animframe to improve offset accuracy

	switch (AnimSequence) {
		// Breathing standing still
		case 'Breath1L':
        case 'Breath2L':
        case 'Breath1':
        case 'Breath2':
             BaseOffset = vect(2, 0, 0); // Move hitbox forward (relative X)
             break;

		// Cocking gun standing still
		case 'CockGun':
        case 'CockGunL':
             BaseOffset = vect(-2.5, 0, 0); // Move hitbox backward (relative X)
             break;

		// Strafing
		case 'StrafeL':
			BaseOffset = vect(0, -3.5, 0); // Move hitbox left (relative Y)
			break;
		case 'StrafeR':
			BaseOffset = vect(0, 3.5, 0);  // Move hitbox right (relative Y)
			break;

		// Forward movement
		case 'RunLg':
		case 'RunSm':
		case 'RunLgFr':
		case 'RunSmFr':
		case 'WalkLg':
		case 'WalkSm':
		case 'WalkLgFr':
		case 'WalkSmFr':
			BaseOffset = vect(3.5, 0, 0); // Move hitbox slightly forward (relative X)
			break;

		// Backwards movement
		case 'BackRun':
			BaseOffset = vect(-2.5, 0, 0); // Move hitbox slightly backward (relative X)
			break;

		// Dodging
		case 'DodgeL':
				BaseOffset = vect(0, -3, 0);
				break;
		case 'DodgeR':
				BaseOffset = vect(0, 3, 0);
				break;
		case 'DodgeF':
				BaseOffset = vect(2.5, 0, 0);
				break;
		case 'DodgeB':
				BaseOffset = vect(-4, 0, 0);
				break;

		case 'AimDnLg':
			BaseOffset = vect(6, 0, 0); // Move hitbox forward
			break;
		case 'AimDnSm':
			BaseOffset = vect(6, 0, 0); // Move hitbox forward
			break;
		case 'AimUpLg':
			BaseOffset = vect(-6, 0, 0); // Move hitbox backward
			break;
		case 'AimUpSm':
			BaseOffset = vect(-6, 0, 0); // Move hitbox backward
			break;

		default:
			BaseOffset = vect(0,0,0);
			break;
	}

	return BaseOffset;
}

simulated function bool CheckHeadShotCompensated(UTPlusDummy D, vector HitLocation, vector Direction) {
	local float DuckFrac;
	local float BodyOffsetZ, BodyHalfHeight, HeadHH;
	local vector AnimOffset, HorizontalAnimOffset;
	local vector FinalHeadCenter;
	local vector X, Y, Z;
	local rotator PawnYawRot;

	if (D == none || D.Actual == none)
		return false;

	DuckFrac = GetDummyDuckFraction(D);
	BodyOffsetZ = GetBodyOffsetZ(D.CollisionHeight, DuckFrac);
	BodyHalfHeight = GetBodyHalfHeight(D.CollisionHeight, DuckFrac);
	HeadHH = GetHeadHalfHeight(DuckFrac);

	if (HeadHH <= 0.0)
		return false;

	FinalHeadCenter = D.Location;

	if (WSettingsRepl.bEnableAnimationAdaptiveHeadHitbox) {
		AnimOffset = GetAnimationHeadOffsetFromState(D.Actual.class.name, D.CurrentAnimSequence, D.CurrentAnimFrame);

		if (Abs(AnimOffset.X) > 0.1 || Abs(AnimOffset.Y) > 0.1 || Abs(AnimOffset.Z) > 0.1) {
			HorizontalAnimOffset = AnimOffset * vect(1,1,0);

			PawnYawRot = D.Rotation;
			PawnYawRot.Pitch = 0;
			PawnYawRot.Roll = 0;

			GetAxes(PawnYawRot, X, Y, Z);
			FinalHeadCenter += (HorizontalAnimOffset.X * X) + (HorizontalAnimOffset.Y * Y);
		}
	}

	FinalHeadCenter += vect(0,0,1) * (BodyOffsetZ + BodyHalfHeight + HeadHH);

	return CheckHitboxInternal(HitLocation, Direction, FinalHeadCenter,
		WSettingsRepl.HeadRadius, HeadHH, D.CollisionRadius + D.CollisionHeight);
}

simulated function bool CheckBodyShotCompensated(UTPlusDummy D, vector HitLocation, vector Direction) {
	local float DuckFrac, HalfHeight, OffsetZ;

	if (D == none || D.Actual == none)
		return false;

	DuckFrac = GetDummyDuckFraction(D);
	HalfHeight = GetBodyHalfHeight(D.CollisionHeight, DuckFrac);
	OffsetZ = GetBodyOffsetZ(D.CollisionHeight, DuckFrac);

	return CheckHitboxInternal(HitLocation, Direction,
		D.Location + vect(0,0,1) * OffsetZ,
		D.CollisionRadius, HalfHeight, D.CollisionRadius + D.CollisionHeight);
}

function float GetAverageTickRate() {
  return CachedTickRate;
}

// Helper function to check if a line segment intersects a cylinder
// Returns true if the line from Start to End passes within Radius of CylinderCenter
function bool LineIntersectsCylinder(vector Start, vector End, vector CylinderCenter, float Radius, float HalfHeight) {
    local vector ClosestPoint, LineDelta, ToCenter;
    local float LineLengthSq, T, DistXYSq, DistZ;

    LineDelta = End - Start;
    LineLengthSq = LineDelta dot LineDelta;
    if (LineLengthSq < 0.000001)
        return false;

    // Project cylinder center onto line
    ToCenter = CylinderCenter - Start;
    T = (ToCenter dot LineDelta) / LineLengthSq;
    T = FClamp(T, 0.0, 1.0);

    ClosestPoint = Start + LineDelta * T;

    // Check distance from closest point to cylinder center
    DistXYSq = Square(ClosestPoint.X - CylinderCenter.X) + Square(ClosestPoint.Y - CylinderCenter.Y);
    DistZ = Abs(ClosestPoint.Z - CylinderCenter.Z);

    return (DistXYSq <= Square(Radius) && DistZ <= HalfHeight);
}

// Check for beam weapon (PBolt/Pulse Gun) collisions during simulation
// Returns true if the translocator was hit
function bool CheckSimulationBeamCollisions(ST_TranslocatorTarget TTarget, float DeltaTime) {
    local PBolt Bolt;
    local vector BeamStart, BeamEnd, BeamDir;
    local float BeamSize;
    local vector TargetDelta;
    local float TargetExtent;
    local float MaxReach;
    local float MaxReachSq;
    local float MomentumAmount;
    local int DamageAmount;
    local name BeamDamageType;

    if (TTarget == None || TTarget.bDeleteMe)
        return true;

    if (WSettingsRepl == none || DeltaTime <= 0.0)
        return false;

    TargetExtent = FMax(TTarget.CollisionRadius, TTarget.CollisionHeight);
    DamageAmount = Max(1, int(WSettingsRepl.PulseBoltDPS * DeltaTime));

    // Find all active PBolt beams
    foreach AllActors(class'PBolt', Bolt) {
        if (Bolt == None || Bolt.bDeleteMe)
            continue;

        // Skip bolts from the same player
        if (Bolt.Instigator == TTarget.Instigator)
            continue;

        BeamSize = Bolt.BeamSize;
        if (BeamSize <= 0.0)
            continue;

        MaxReach = BeamSize + TargetExtent;
        MaxReachSq = MaxReach * MaxReach;

        // Get beam direction from rotation
        BeamDir = vector(Bolt.Rotation);
        BeamStart = Bolt.Location;
        BeamEnd = Bolt.Location + BeamDir * BeamSize;
        TargetDelta = TTarget.Location - BeamStart;
        if ((TargetDelta dot TargetDelta) > MaxReachSq)
            continue;

        // Check if the beam intersects the translocator
        if (LineIntersectsCylinder(BeamStart, BeamEnd, TTarget.Location,
                                   TTarget.CollisionRadius, TTarget.CollisionHeight)) {
            // Apply pulse gun damage using current weapon settings.
            MomentumAmount = WSettingsRepl.PulseBoltMomentum * Bolt.MomentumTransfer * DeltaTime;
            if (Bolt.MyDamageType == '')
                BeamDamageType = 'zapped';
            else
                BeamDamageType = Bolt.MyDamageType;

            TTarget.TakeDamage(
                DamageAmount,
                Bolt.Instigator,
                TTarget.Location,
                BeamDir * MomentumAmount,
                BeamDamageType
            );

            if (TTarget == None || TTarget.bDeleteMe)
                return true;
        }
    }

    return false;
}

function bool CheckSimulationProjectileCollisions(ST_TranslocatorTarget TTarget, UTPure PureRef) {
    local ST_ProjectileDummy PD;
    local ST_ShockProj ShockProj;
    local Projectile P;
    local vector Delta, HitNormal;
    local float CombinedRadius, CombinedHeight, CombinedRadiusSq;
    local float DistXYSq, DistZ;

    if (TTarget == None || TTarget.bDeleteMe)
        return true;

    // Check compensated shock projectile dummies at historical positions
    for (PD = PureRef.ProjDummies; PD != None; PD = PD.Next) {
        if (!PD.bCompActive || PD.Actual == None || PD.Actual.bDeleteMe)
            continue;

        ShockProj = ST_ShockProj(PD.Actual);
        if (ShockProj == None)
            continue;

        Delta = TTarget.Location - PD.Location;
        CombinedRadius = TTarget.CollisionRadius + PD.CollisionRadius;
        CombinedHeight = TTarget.CollisionHeight + PD.CollisionHeight;
        CombinedRadiusSq = CombinedRadius * CombinedRadius;
        DistXYSq = Delta.X * Delta.X + Delta.Y * Delta.Y;
        DistZ = Abs(Delta.Z);

        if (DistXYSq <= CombinedRadiusSq && DistZ <= CombinedHeight) {
            ShockProj.SetLocation(PD.Location);
            ShockProj.Explode(PD.Location, Normal(Delta));
            if (TTarget == None || TTarget.bDeleteMe)
                return true;
        }
    }

    // Check non-registered projectiles at current positions
    foreach TTarget.RadiusActors(class'Projectile', P, TTarget.CollisionRadius + 100) {
        if (P == None || P.bDeleteMe || P == TTarget)
            continue;
        if (P.Instigator == TTarget.Instigator)
            continue;
        if (P.IsA('ShockProj') || P.IsA('TranslocatorTarget'))
            continue;

        Delta = TTarget.Location - P.Location;
        CombinedRadius = TTarget.CollisionRadius + P.CollisionRadius;
        CombinedHeight = TTarget.CollisionHeight + P.CollisionHeight;
        CombinedRadiusSq = CombinedRadius * CombinedRadius;
        DistXYSq = Delta.X * Delta.X + Delta.Y * Delta.Y;
        DistZ = Abs(Delta.Z);

        if (DistXYSq > CombinedRadiusSq || DistZ > CombinedHeight)
            continue;

        HitNormal = Normal(Delta);

        // Splash projectiles — let their Explode() handle damage via HurtRadius
        if (P.IsA('RocketMk2') || P.IsA('Razor2Alt') || P.IsA('FlakSlug')) {
            P.Explode(P.Location, HitNormal);
        }
        // Direct-damage projectiles — apply damage from projectile properties, then clean up
        else {
            TTarget.TakeDamage(P.Damage, P.Instigator, TTarget.Location,
                Normal(P.Velocity) * P.MomentumTransfer, P.MyDamageType);
            if (P.IsA('PlasmaSphere'))
                P.Explode(P.Location, HitNormal);
            else
                P.Destroy();
        }

        if (TTarget == None || TTarget.bDeleteMe)
            return true;
    }

    return false;
}

function SimulateProjectileWithHistory(ST_TranslocatorTarget TTarget, int Ping) {
    local float GameDeltaTime;
    local float RealDeltaTime;
    local float SimPing;
    local float InterpMs;
    local float RealTimeRemaining;
    local float AccumulatedGameTime;
    local int HistoryInterval;
    local UTPure PureRef;
    local vector CurrentPos;
    local vector Delta;
    local float MinMovementSquared;
    local float TotalGameTime;
    local float ExplosionMaxAge;
    local int HistorySize;

    if (TTarget == None || TTarget.bDeleteMe)
        return;

    PureRef = bbPlayer(TTarget.Instigator).zzUTPure;

    InterpMs = IGPlus_GetSnapshotInterpRewindMs(TTarget.Instigator);
    SimPing = float(Ping) + InterpMs;

    // Cap ping compensation
    if (SimPing > WeaponSettings.PingCompensationMax)
        SimPing = WeaponSettings.PingCompensationMax;

    if (SimPing <= 0.0)
        return;
    
    ExplosionMaxAge = SimPing * 0.002;

    // Pre-calculate squared threshold
    MinMovementSquared = 0.01;

    // Store initial position BEFORE simulation
    CurrentPos = TTarget.Location;

    // TotalSimulationTime is in game time (for comparison with ServerTimeSinceTargetSpawn)
    TotalGameTime = SimPing * 0.001 * Level.TimeDilation;
    TTarget.InitSimulationHistory(CurrentPos, 0.0, TotalGameTime);

    // Calculate time steps
    // RealDeltaTime: how much real time passes per iteration (undilated)
    // GameDeltaTime: how much game time passes per iteration (dilated)
    RealDeltaTime = SimPing * 0.001;
    RealDeltaTime = RealDeltaTime / (int(RealDeltaTime * GetAverageTickRate()) + 1);
    GameDeltaTime = RealDeltaTime * Level.TimeDilation;

    HistorySize = TTarget.MaxHistorySteps;
    HistoryInterval = Max(1, int(SimPing / float(HistorySize - 1)));
    RealTimeRemaining = SimPing;
    AccumulatedGameTime = 0.0;

    while (RealTimeRemaining > 0.0 && TTarget != None && !TTarget.bDeleteMe) {
        PureRef.CompensateFor(int(RealTimeRemaining), TTarget.Instigator);

        CurrentPos = TTarget.Location;

        TTarget.AutonomousPhysics(GameDeltaTime);

        // Check for collisions with compensated projectiles (shock balls, etc.)
        if (CheckSimulationProjectileCollisions(TTarget, PureRef)) {
            PureRef.EndCompensation();
            return; // Translocator was destroyed or affected
        }

        // Check for beam weapon collisions (pulse gun)
        if (CheckSimulationBeamCollisions(TTarget, GameDeltaTime)) {
            PureRef.EndCompensation();
            return; // Translocator was destroyed by beam
        }

        // Check for recent shock combo explosions
        // MaxAge covers the simulation window plus a small buffer
        if (CheckRecentExplosions(TTarget, ExplosionMaxAge)) {
            PureRef.EndCompensation();
            return; // Translocator was destroyed by explosion
        }

        // Decrement by real time (undilated)
        RealTimeRemaining -= RealDeltaTime * 1000.0;
        // Track game time for history (dilated)
        AccumulatedGameTime += GameDeltaTime * 1000.0;

        Delta = TTarget.Location - CurrentPos;
        if ((Delta.X * Delta.X + Delta.Y * Delta.Y + Delta.Z * Delta.Z) > MinMovementSquared) {
            if (AccumulatedGameTime >= HistoryInterval * (TTarget.HistoryCount - 1) &&
                TTarget.HistoryCount < HistorySize) {
                TTarget.AddSimulationHistoryStep(TTarget.Location, AccumulatedGameTime * 0.001);
            }
        }

        PureRef.EndCompensation();
    }

    // Store final simulated position
    if (TTarget != None && TTarget.HistoryCount < HistorySize) {
        TTarget.AddSimulationHistoryStep(TTarget.Location, TTarget.TotalSimulationTime);
    }
}

function SimulateProjectile(Projectile P, int Ping) {
  local float DeltaTime;
  local float SimPing;
  local float InterpMs;
  local UTPure PureRef;

  // Early exit if the projectile is already destroyed
  if (P == None || P.bDeleteMe)
    return;

  PureRef = bbPlayer(P.Instigator).zzUTPure;

  InterpMs = IGPlus_GetSnapshotInterpRewindMs(P.Instigator);
  SimPing = Ping * 0.5 + InterpMs;

  // Cap ping compensation
  if (SimPing > WeaponSettings.PingCompensationMax)
        SimPing = WeaponSettings.PingCompensationMax;

  if (SimPing <= 0.0)
    return;

  DeltaTime = 0.001*SimPing*Level.TimeDilation;

  DeltaTime = DeltaTime / (int(DeltaTime * GetAverageTickRate()) + 1);

  if (DeltaTime <= 0.0)
    return;
  
  while (SimPing > 0.0) {
    if (P == None || P.bDeleteMe) {
        break;
      }

    PureRef.CompensateFor(int(SimPing), P.Instigator);
    P.AutonomousPhysics(DeltaTime);
    SimPing -= DeltaTime * 1000.0;
    PureRef.EndCompensation();
  }
}

function BatchSimulateProjectiles(Projectile Projectiles[6], int NumProjectiles, int Ping) {
  local float DeltaTime;
  local float SimPing;
  local float InterpMs;
  local UTPure PureRef;
  local int i;
  local bool bAnyAlive;
  
  if (NumProjectiles == 0 || Projectiles[0] == None)
    return;
    
  PureRef = bbPlayer(Projectiles[0].Instigator).zzUTPure;

  InterpMs = IGPlus_GetSnapshotInterpRewindMs(Projectiles[0].Instigator);
  SimPing = Ping * 0.5 + InterpMs; // Simulate only 1-way latency
  
  if (SimPing > WeaponSettings.PingCompensationMax)
    SimPing = WeaponSettings.PingCompensationMax;
    
  if (SimPing <= 0.0)
    return;

  DeltaTime = 0.001*SimPing*Level.TimeDilation;

  DeltaTime = DeltaTime / (int(DeltaTime * GetAverageTickRate()) + 1);

  if (DeltaTime <= 0.0)
    return;
  
  while (SimPing > 0.0) {
    bAnyAlive = false;
    
    for (i = 0; i < NumProjectiles; i++) {
      if (Projectiles[i] != None && !Projectiles[i].bDeleteMe) {
        bAnyAlive = true;
        break;
      }
    }
    
    if (!bAnyAlive)
      break;
    
    PureRef.CompensateFor(int(SimPing), Projectiles[0].Instigator);
    
    for (i = 0; i < NumProjectiles; i++) {
      if (Projectiles[i] != None && !Projectiles[i].bDeleteMe) {
        Projectiles[i].AutonomousPhysics(DeltaTime);
      }
    }
    
    SimPing -= DeltaTime * 1000.0;
    PureRef.EndCompensation();
  }
}

simulated function Actor TraceShotInternal(
	out vector HitLocation,
	out vector HitNormal,
	vector EndTrace,
	vector StartTrace,
	Pawn PawnOwner,
	bool bWeaponShock,
	bool bSProjBlocks,
	bool bCompensated
) {
	local Actor A, Other;
	local Pawn P;
	local vector Dir;
	local UTPlusDummy D;
	local ST_ProjectileDummy PD;

	Dir = Normal(EndTrace - StartTrace);

	foreach TraceActors(class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {
		if (A == PawnOwner)
			continue;

		if (bCompensated && A.IsA('UTPlusDummy')) {
			D = UTPlusDummy(A);
			if (D.Actual != PawnOwner) {
				if (D.AdjustHitLocation(HitLocation, EndTrace - StartTrace)) {
					if (CheckBodyShotCompensated(D, HitLocation, Dir) == false &&
						CheckHeadShotCompensated(D, HitLocation, Dir) == false)
						continue;
					Other = D.Actual;
					break;
				}
			}
			continue;
		}

		if (bCompensated && A.IsA('ST_ProjectileDummy')) {
			PD = ST_ProjectileDummy(A);
			if (PD.Actual != None) {
				if (PD.Actual.IsA('ST_ShockProj')) {
					if (bWeaponShock || bSProjBlocks) {
						Other = PD.Actual;
						break;
					}
				} else if (PD.Actual.IsA('ST_TranslocatorTarget')) {
					Other = PD.Actual;
					break;
				}
			}
			continue;
		}

		if (!bCompensated) {
			P = Pawn(A);
			if (P != none) {
				if (P.AdjustHitLocation(HitLocation, EndTrace - StartTrace) == false)
					continue;
				if (CheckBodyShot(P, HitLocation, Dir) == false &&
					CheckHeadShot(P, HitLocation, Dir) == false)
					continue;
				Other = A;
				break;
			}
		}

		if ((A == Level) || (Mover(A) != None) || A.bProjTarget || (A.bBlockPlayers && A.bBlockActors)) {
			if (bSProjBlocks || A.IsA('ShockProj') == false || bWeaponShock) {
				Other = A;
				break;
			}
		}
	}

	return Other;
}

simulated function Actor TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace, Pawn PawnOwner)
{
	local Actor Other;
	local bool bSProjBlocks;
	local bool bWeaponShock;
	local bbPlayer bbP;
	local int Ping;
	local UTPure PureRef;
	local float EffectivePing;

	Ping = 0;

	if (PawnOwner != None) {
		bbP = bbPlayer(PawnOwner);

		if (bbP != None) {
			PureRef = bbP.zzUTPure;
			EffectivePing = float(bbP.PingAverage) + IGPlus_GetSnapshotInterpRewindMs(PawnOwner);

			if (EffectivePing > WSettingsRepl.PingCompensationMax)
				EffectivePing = WSettingsRepl.PingCompensationMax;
			if (EffectivePing < 0.0)
				EffectivePing = 0.0;
			Ping = int(EffectivePing);
		}

		bWeaponShock = (PawnOwner.Weapon != none && PawnOwner.Weapon.IsA('ShockRifle'));
	}

	bSProjBlocks = WSettingsRepl.ShockProjectileBlockBullets;

	if (WSettingsRepl.bEnablePingCompensation && bbP != none) {
		PureRef.CompensateFor(Ping, PawnOwner);
		Other = TraceShotInternal(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner, bWeaponShock, bSProjBlocks, true);
		PureRef.EndCompensation();
		return Other;
	}

	return TraceShotInternal(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner, bWeaponShock, bSProjBlocks, false);
}

simulated function Actor TraceShotClient(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace, Pawn PawnOwner)
{
	local bool bSProjBlocks;
	local bool bWeaponShock;

	bSProjBlocks = WSettingsRepl.ShockProjectileBlockBullets;
	bWeaponShock = (PawnOwner.Weapon != none && PawnOwner.Weapon.IsA('ShockRifle'));

	return TraceShotInternal(HitLocation, HitNormal, EndTrace, StartTrace, PawnOwner, bWeaponShock, bSProjBlocks, false);
}

defaultproperties {

}
