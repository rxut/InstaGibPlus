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
var RecentExplosion RecentExplosions[16];  // Ring buffer of recent explosions
var int ExplosionWriteIndex;                // Next write position

function PostBeginPlay() {
	super.PostBeginPlay();

	HitTestHelper = Spawn(class'ST_HitTestHelper');
	CollChecker = Spawn(class'ST_HitTestHelper');
	CollChecker.SetCollision(true, false, false);
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

final simulated function float GetPawnDuckFraction(Pawn P) {
	local bbPlayer bbP;
	bbP = bbPlayer(P);
	if (bbP != none) {
		if (Role < ROLE_Authority)
			return FClamp(bbP.DuckFractionRepl/255.0, 0.0, 1.0);
		else
			return FClamp(bbP.DuckFraction, 0.0, 1.0);
	} else {
		return FClamp(1.0 - (P.EyeHeight / P.default.BaseEyeHeight), 0.0, 1.0);
	}
}

final simulated function float GetPawnBodyHalfHeight(Pawn P, float DuckFrac) {
	return Lerp(DuckFrac,
		P.CollisionHeight - WSettingsRepl.HeadHalfHeight,
		(1.3 * 0.5)*P.CollisionHeight
	);
}

final simulated function float GetPawnBodyOffsetZ(Pawn P, float DuckFrac) {
	return Lerp(DuckFrac,
		-WSettingsRepl.HeadHalfHeight,
		-(0.7 * 0.5)*P.CollisionHeight
	);
}

simulated function vector GetAnimationHeadOffset(Pawn P) {
	local vector BaseOffset;
	local vector WorldOffset;

	if (P == none) {
		return vect(0,0,0);
	}

	switch (P.AnimSequence) {

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
	
	// Rotate the base offset according to the pawn's current rotation
	WorldOffset = BaseOffset >> P.Rotation;

	return WorldOffset;
}

simulated function bool CheckHeadShot(Pawn P, vector HitLocation, vector Direction) {
    local float DuckFrac;
    local float BodyOffsetZ;
    local float BodyHalfHeight, HeadHalfHeight;
    local vector BasePosition;
    local ST_HitTestHelper HitActor;
    local vector HitLoc, HitNorm;
    local bool Result;
	local vector EndTrace;
	local vector StartTrace;
	local vector BackwardHitLoc, BackwardHitNorm;
	local vector HitboxTraceStart;
	local vector AnimOffset;

    if (P == none)
        return false;

    BasePosition = P.Location;

    if (HitLocation.Z - P.Location.Z <= 0.3 * P.CollisionHeight)
        return false;

    if (CollChecker == none || CollChecker.bDeleteMe) {
        CollChecker = Spawn(class'ST_HitTestHelper',self, , P.Location);
    }

    DuckFrac = GetPawnDuckFraction(P);
    BodyOffsetZ = GetPawnBodyOffsetZ(P, DuckFrac);
    BodyHalfHeight = GetPawnBodyHalfHeight(P, DuckFrac);
    HeadHalfHeight = Lerp(DuckFrac,
        WSettingsRepl.HeadHalfHeight,
        0
    );

    if (HeadHalfHeight <= 0.0)
        return false;

	if (WSettingsRepl.bEnableAnimationAdaptiveHeadHitbox) {
		AnimOffset = GetAnimationHeadOffset(P);
	} else {
		AnimOffset = vect(0,0,0);
	}

    CollChecker.SetCollision(true, false, false);
    CollChecker.SetCollisionSize(WSettingsRepl.HeadRadius, HeadHalfHeight); // Use HeadRadius here
    CollChecker.SetLocation(BasePosition + AnimOffset + vect(0,0,1)*(BodyOffsetZ + BodyHalfHeight + HeadHalfHeight));

    Result = false;

	EndTrace = HitLocation + Direction * (P.CollisionRadius + P.CollisionHeight);
	StartTrace = HitLocation - Direction * (P.CollisionRadius + P.CollisionHeight);

	// Trace backwards from HitLocation against world geometry only
	if (Trace(BackwardHitLoc, BackwardHitNorm, StartTrace, HitLocation, false) == None) {
        HitboxTraceStart = StartTrace;
    } else {
        HitboxTraceStart = BackwardHitLoc;
    }

    foreach TraceActors(
        class'ST_HitTestHelper',
        HitActor, HitLoc, HitNorm,
        EndTrace,
        HitboxTraceStart
    ) {
        if (HitActor == CollChecker) {
            Result = true;
            break;
        }
    }

    CollChecker.SetCollision(false, false, false);

    return Result;
}

simulated function bool CheckBodyShot(Pawn P, vector HitLocation, vector Direction, optional vector PositionOverride) {
    local float DuckFrac;
    local float HalfHeight;
    local float OffsetZ;
    local vector BasePosition;
    local ST_HitTestHelper HitActor;
    local vector HitLoc, HitNorm;
    local bool Result;
	local vector EndTrace;
	local vector StartTrace;
	local vector BackwardHitLoc, BackwardHitNorm;
	local vector HitboxTraceStart;

    if (P == none)
        return false;

    if (CollChecker == none || CollChecker.bDeleteMe) {
        CollChecker = Spawn(class'ST_HitTestHelper',self, , P.Location);
    }

    DuckFrac = GetPawnDuckFraction(P);
    HalfHeight = GetPawnBodyHalfHeight(P, DuckFrac);
    OffsetZ = GetPawnBodyOffsetZ(P, DuckFrac);

    // Use the override position if provided, otherwise use the pawn's current position
    if (PositionOverride != vect(0,0,0))
        BasePosition = PositionOverride;
    else
        BasePosition = P.Location;

    CollChecker.SetCollision(true, false, false);
    CollChecker.SetCollisionSize(P.CollisionRadius, HalfHeight);
    CollChecker.SetLocation(BasePosition + vect(0,0,1)*OffsetZ);

    Result = false;

	EndTrace = HitLocation + Direction * (P.CollisionRadius + P.CollisionHeight);
	StartTrace = HitLocation - Direction * (P.CollisionRadius + P.CollisionHeight);

	// Trace backwards from HitLocation against world geometry only
	if (Trace(BackwardHitLoc, BackwardHitNorm, StartTrace, HitLocation, false) == None) {
        HitboxTraceStart = StartTrace;
    } else {
        HitboxTraceStart = BackwardHitLoc;
    }

    foreach TraceActors(
        class'ST_HitTestHelper',
        HitActor, HitLoc, HitNorm,
        EndTrace,
        HitboxTraceStart
    ) {
        if (HitActor == CollChecker) {
            Result = true;
            break;
        }
    }

    CollChecker.SetCollision(false, false, false);

    return Result;
}

final simulated function float GetDummyDuckFraction(UTPlusDummy D) {
        if (D.BaseEyeHeight <= 0)
            return 0.0;
        return FClamp(1.0 - (D.EyeHeight / D.BaseEyeHeight), 0.0, 1.0);
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
	local float BodyOffsetZ;
	local float BodyHalfHeight, HeadHalfHeight;
	local vector BasePosition;
	local ST_HitTestHelper HitActor;
	local vector HitLoc, HitNorm;
	local bool Result;
	local vector EndTrace;
	local vector StartTrace;
	local vector BackwardHitLoc, BackwardHitNorm;
	local vector HitboxTraceStart;

	local vector AnimOffset; // Variable for animation offset
	local vector HorizontalAnimOffset;
	local vector FinalHeadCenter;
	local vector X, Y, Z; // For rotation
	local rotator PawnYawRot; // Rotator for pawn's yaw only

	 if (D == none || D.Actual == none)
        return false;

	DuckFrac = GetDummyDuckFraction(D);
	BodyOffsetZ = Lerp(DuckFrac,
		-WSettingsRepl.HeadHalfHeight,
		-(0.7 * 0.5) * D.CollisionHeight
	);
	BodyHalfHeight = Lerp(DuckFrac,
		D.CollisionHeight - WSettingsRepl.HeadHalfHeight,
		(1.3 * 0.5) * D.CollisionHeight
	);

	HeadHalfHeight = Lerp(DuckFrac,
		WSettingsRepl.HeadHalfHeight,
		0
	);

	if (HeadHalfHeight <= 0.0)
		return false;

	BasePosition = D.Location;

	AnimOffset = GetAnimationHeadOffsetFromState(D.Actual.class.name, D.CurrentAnimSequence, D.CurrentAnimFrame);

	// Start with the base position
	FinalHeadCenter = BasePosition;

	if (WSettingsRepl.bEnableAnimationAdaptiveHeadHitbox)
	{
		AnimOffset = GetAnimationHeadOffsetFromState(D.Actual.class.name, D.CurrentAnimSequence, D.CurrentAnimFrame);

		if (Abs(AnimOffset.X) > 0.1 || Abs(AnimOffset.Y) > 0.1 || Abs(AnimOffset.Z) > 0.1) {
			// Isolate the horizontal component of the local animation offset
			HorizontalAnimOffset = AnimOffset * vect(1,1,0);
			
			PawnYawRot = D.Rotation;
			PawnYawRot.Pitch = 0;
			PawnYawRot.Roll = 0;

			GetAxes(PawnYawRot, X, Y, Z); 

			FinalHeadCenter += (HorizontalAnimOffset.X * X) + (HorizontalAnimOffset.Y * Y);
		}
	}

	// Apply the calculated vertical offset for head position (always uses world Z-axis)
	FinalHeadCenter += vect(0,0,1)*(BodyOffsetZ + BodyHalfHeight + HeadHalfHeight);

	CollChecker.SetCollision(true, false, false);
	CollChecker.SetCollisionSize(WSettingsRepl.HeadRadius, HeadHalfHeight);
	CollChecker.SetLocation(FinalHeadCenter);

	Result = false;

	EndTrace = HitLocation + Direction * (D.CollisionRadius + D.CollisionHeight);
	StartTrace = HitLocation - Direction * (D.CollisionRadius + D.CollisionHeight);

	// Trace backwards from HitLocation against world geometry only
	if (Trace(BackwardHitLoc, BackwardHitNorm, StartTrace, HitLocation, false) == None) {
		HitboxTraceStart = StartTrace;
	} else {
		HitboxTraceStart = BackwardHitLoc;
	}

	foreach TraceActors(
		class'ST_HitTestHelper',
		HitActor, HitLoc, HitNorm,
		EndTrace,
		HitboxTraceStart
	) {
		if (HitActor == CollChecker) {
			Result = true;
			break;
		}
	}

	CollChecker.SetCollision(false, false, false);
	return Result;
}

simulated function bool CheckBodyShotCompensated(UTPlusDummy D, vector HitLocation, vector Direction) {
        local float DuckFrac;
        local float HalfHeight;
        local float OffsetZ;
        local vector BasePosition;
        local ST_HitTestHelper HitActor;
        local vector HitLoc, HitNorm;
        local bool Result;
		local vector EndTrace;
		local vector StartTrace;
		local vector BackwardHitLoc, BackwardHitNorm;
		local vector HitboxTraceStart;

        if (D == none || D.Actual == none)
            return false;

        if (CollChecker == none || CollChecker.bDeleteMe) {
            CollChecker = Spawn(class'ST_HitTestHelper', self, , D.Location);
            CollChecker.bCollideWorld = false;
        }

        DuckFrac = GetDummyDuckFraction(D);
        HalfHeight = Lerp(DuckFrac,
            D.CollisionHeight - WSettingsRepl.HeadHalfHeight,
            (1.3 * 0.5) * D.CollisionHeight
        );
        OffsetZ = Lerp(DuckFrac,
            -WSettingsRepl.HeadHalfHeight,
            -(0.7 * 0.5) * D.CollisionHeight
        );

        BasePosition = D.Location;

        CollChecker.SetCollision(true, false, false);
        CollChecker.SetCollisionSize(D.CollisionRadius, HalfHeight);
        CollChecker.SetLocation(BasePosition + vect(0,0,1)*OffsetZ);

        Result = false;

		EndTrace = HitLocation + Direction * (D.CollisionRadius + D.CollisionHeight);
		StartTrace = HitLocation - Direction * (D.CollisionRadius + D.CollisionHeight);

		// Trace backwards from HitLocation against world geometry only
		if (Trace(BackwardHitLoc, BackwardHitNorm, StartTrace, HitLocation, false) == None) {
			HitboxTraceStart = StartTrace;
		} else {
			HitboxTraceStart = BackwardHitLoc;
		}

        foreach TraceActors(
            class'ST_HitTestHelper',
            HitActor, HitLoc, HitNorm,
            EndTrace,
            HitboxTraceStart
        ) {
            if (HitActor == CollChecker) {
                Result = true;
                break;
            }
        }

        CollChecker.SetCollision(false, false, false);

        return Result;
}

function float GetAverageTickRate() {
  if (Level.NetMode == NM_DedicatedServer)
    return int(ConsoleCommand("get ini:Engine.Engine.NetworkDevice NetServerMaxTickRate"));
  return 120.0;
}

// Helper function for cylinder vs cylinder collision check
function bool CylinderOverlap(Actor A, Actor B) {
    local vector Delta;
    local float CombinedRadius, CombinedHeight;
    local float DistXY, DistZ;

    Delta = A.Location - B.Location;
    CombinedRadius = A.CollisionRadius + B.CollisionRadius;
    CombinedHeight = A.CollisionHeight + B.CollisionHeight;

    DistXY = Sqrt(Delta.X * Delta.X + Delta.Y * Delta.Y);
    DistZ = Abs(Delta.Z);

    return (DistXY <= CombinedRadius && DistZ <= CombinedHeight);
}

// Helper function to check if a line segment intersects a cylinder
// Returns true if the line from Start to End passes within Radius of CylinderCenter
function bool LineIntersectsCylinder(vector Start, vector End, vector CylinderCenter, float Radius, float HalfHeight) {
    local vector ClosestPoint, LineDir, ToCenter;
    local float LineLength, T, DistXY, DistZ;

    LineDir = End - Start;
    LineLength = VSize(LineDir);
    if (LineLength < 0.001)
        return false;

    LineDir = LineDir / LineLength;

    // Project cylinder center onto line
    ToCenter = CylinderCenter - Start;
    T = ToCenter dot LineDir;
    T = FClamp(T, 0.0, LineLength);

    ClosestPoint = Start + LineDir * T;

    // Check distance from closest point to cylinder center
    DistXY = Sqrt(Square(ClosestPoint.X - CylinderCenter.X) + Square(ClosestPoint.Y - CylinderCenter.Y));
    DistZ = Abs(ClosestPoint.Z - CylinderCenter.Z);

    return (DistXY <= Radius && DistZ <= HalfHeight);
}

// Check for beam weapon (PBolt/Pulse Gun) collisions during simulation
// Returns true if the translocator was hit
function bool CheckSimulationBeamCollisions(ST_TranslocatorTarget TTarget) {
    local PBolt Bolt;
    local vector BeamStart, BeamEnd, BeamDir;
    local float BeamSize;
    local float DamageAmount;

    if (TTarget == None || TTarget.bDeleteMe)
        return true;

    // Find all active PBolt beams
    foreach AllActors(class'PBolt', Bolt) {
        if (Bolt == None || Bolt.bDeleteMe)
            continue;

        // Skip bolts from the same player
        if (Bolt.Instigator == TTarget.Instigator)
            continue;

        // Get beam direction from rotation
        BeamDir = vector(Bolt.Rotation);
        BeamSize = 81.0; // Default PBolt.BeamSize
        BeamStart = Bolt.Location;
        BeamEnd = Bolt.Location + BeamDir * BeamSize;

        // Check if the beam intersects the translocator
        if (LineIntersectsCylinder(BeamStart, BeamEnd, TTarget.Location,
                                   TTarget.CollisionRadius, TTarget.CollisionHeight)) {
            // Apply pulse gun damage
            DamageAmount = 72.0 * 0.1; // Damage per tick approximation
            TTarget.TakeDamage(
                DamageAmount,
                Bolt.Instigator,
                TTarget.Location,
                BeamDir * 8500 * 0.1, // MomentumTransfer scaled
                'zapped'
            );

            if (TTarget == None || TTarget.bDeleteMe)
                return true;
        }
    }

    return false;
}

// Check for collisions between translocator and projectiles during ping simulation
// Returns true if the translocator was destroyed or should stop simulating
function bool CheckSimulationProjectileCollisions(ST_TranslocatorTarget TTarget, UTPure PureRef) {
    local ST_ProjectileDummy PD;
    local ST_ShockProj ShockProj;
    local Projectile P;
    local ST_RocketMk2 Rocket;
    local ST_UT_SeekingRocket SeekingRocket;
    local ST_Razor2 Razor;
    local ST_Razor2Alt RazorAlt;
    local ST_FlakSlug FlakSlug;
    local vector Delta;
    local float CombinedRadius;
    local float CombinedHeight;
    local float DistXY, DistZ;
    local float SearchRadius;

    if (TTarget == None || TTarget.bDeleteMe)
        return true;

    // PART 1: Check compensated projectile dummies (historical positions)
    // This handles shock projectiles that are registered with the dummy system
    for (PD = PureRef.ProjDummies; PD != None; PD = PD.Next) {
        if (!PD.bCompActive || PD.Actual == None || PD.Actual.bDeleteMe)
            continue;

        // Check for shock projectiles
        ShockProj = ST_ShockProj(PD.Actual);
        if (ShockProj == None)
            continue;

        // Cylinder vs cylinder collision check
        Delta = TTarget.Location - PD.Location;
        CombinedRadius = TTarget.CollisionRadius + PD.CollisionRadius;
        CombinedHeight = TTarget.CollisionHeight + PD.CollisionHeight;

        DistXY = Sqrt(Delta.X * Delta.X + Delta.Y * Delta.Y);
        DistZ = Abs(Delta.Z);

        if (DistXY <= CombinedRadius && DistZ <= CombinedHeight) {
            // Collision detected - trigger shock projectile explosion at dummy location
            ShockProj.SetLocation(PD.Location);
            ShockProj.Explode(PD.Location, Normal(TTarget.Location - PD.Location));

            if (TTarget == None || TTarget.bDeleteMe)
                return true;
        }
    }

    // PART 2: Check non-registered projectiles at their current positions
    // This handles rockets, ripper, flak that aren't in the dummy system
    SearchRadius = TTarget.CollisionRadius + 100; // Search a reasonable radius

    foreach TTarget.RadiusActors(class'Projectile', P, SearchRadius) {
        if (P == None || P.bDeleteMe || P == TTarget)
            continue;

        // Skip projectiles owned by the same player
        if (P.Instigator == TTarget.Instigator)
            continue;

        // Skip shock projectiles (handled above via dummies)
        if (P.IsA('ST_ShockProj') || P.IsA('ShockProj'))
            continue;

        // Skip other translocator targets
        if (P.IsA('TranslocatorTarget'))
            continue;

        // Check for rockets
        Rocket = ST_RocketMk2(P);
        if (Rocket != None && CylinderOverlap(TTarget, Rocket)) {
            Rocket.Explode(Rocket.Location, Normal(TTarget.Location - Rocket.Location));
            if (TTarget == None || TTarget.bDeleteMe)
                return true;
            continue;
        }

        // Check for seeking rockets
        SeekingRocket = ST_UT_SeekingRocket(P);
        if (SeekingRocket != None && CylinderOverlap(TTarget, SeekingRocket)) {
            SeekingRocket.Explode(SeekingRocket.Location, Normal(TTarget.Location - SeekingRocket.Location));
            if (TTarget == None || TTarget.bDeleteMe)
                return true;
            continue;
        }

        // Check for ripper primary
        Razor = ST_Razor2(P);
        if (Razor != None && CylinderOverlap(TTarget, Razor)) {
            // Ripper does direct damage, not explosion
            TTarget.TakeDamage(
                30, // Standard ripper damage
                Razor.Instigator,
                TTarget.Location,
                Normal(Razor.Velocity) * 10000,
                'shredded'
            );
            Razor.Destroy();
            if (TTarget == None || TTarget.bDeleteMe)
                return true;
            continue;
        }

        // Check for ripper alt (exploding blade)
        RazorAlt = ST_Razor2Alt(P);
        if (RazorAlt != None && CylinderOverlap(TTarget, RazorAlt)) {
            RazorAlt.Explode(RazorAlt.Location, Normal(TTarget.Location - RazorAlt.Location));
            if (TTarget == None || TTarget.bDeleteMe)
                return true;
            continue;
        }

        // Check for flak slug
        FlakSlug = ST_FlakSlug(P);
        if (FlakSlug != None && CylinderOverlap(TTarget, FlakSlug)) {
            FlakSlug.Explode(FlakSlug.Location, Normal(TTarget.Location - FlakSlug.Location));
            if (TTarget == None || TTarget.bDeleteMe)
                return true;
            continue;
        }

        // Check for base game rockets (RocketMk2, UT_SeekingRocket)
        if (P.IsA('RocketMk2') || P.IsA('UT_SeekingRocket')) {
            if (CylinderOverlap(TTarget, P)) {
                P.Explode(P.Location, Normal(TTarget.Location - P.Location));
                if (TTarget == None || TTarget.bDeleteMe)
                    return true;
            }
            continue;
        }

        // Check for base game ripper
        if (P.IsA('Razor2')) {
            if (CylinderOverlap(TTarget, P)) {
                TTarget.TakeDamage(30, P.Instigator, TTarget.Location, Normal(P.Velocity) * 10000, 'shredded');
                P.Destroy();
                if (TTarget == None || TTarget.bDeleteMe)
                    return true;
            }
            continue;
        }

        // Check for base game ripper alt
        if (P.IsA('Razor2Alt')) {
            if (CylinderOverlap(TTarget, P)) {
                P.Explode(P.Location, Normal(TTarget.Location - P.Location));
                if (TTarget == None || TTarget.bDeleteMe)
                    return true;
            }
            continue;
        }

        // Check for base game flak
        if (P.IsA('FlakSlug')) {
            if (CylinderOverlap(TTarget, P)) {
                P.Explode(P.Location, Normal(TTarget.Location - P.Location));
                if (TTarget == None || TTarget.bDeleteMe)
                    return true;
            }
            continue;
        }

        // Check for flak chunks (ut_Chunk)
        if (P.IsA('ut_Chunk') || P.IsA('ST_UTChunk1') || P.IsA('ST_UTChunk2') ||
            P.IsA('ST_UTChunk3') || P.IsA('ST_UTChunk4')) {
            if (CylinderOverlap(TTarget, P)) {
                // Chunks do direct damage
                TTarget.TakeDamage(17, P.Instigator, TTarget.Location, Normal(P.Velocity) * 12000, 'shredded');
                P.Destroy();
                if (TTarget == None || TTarget.bDeleteMe)
                    return true;
            }
            continue;
        }

        // Check for bio globs (ST_BioGlob, ST_UT_BioGel, UT_BioGel, BioGlob)
        if (P.IsA('UT_BioGel') || P.IsA('BioGlob')) {
            if (CylinderOverlap(TTarget, P)) {
                // Bio does direct damage on touch, then explodes
                TTarget.TakeDamage(P.Damage, P.Instigator, TTarget.Location, Normal(P.Velocity) * P.MomentumTransfer, 'Corroded');
                P.Destroy();
                if (TTarget == None || TTarget.bDeleteMe)
                    return true;
            }
            continue;
        }

        // Check for plasma spheres (pulse gun alt-fire)
        if (P.IsA('PlasmaSphere')) {
            if (CylinderOverlap(TTarget, P)) {
                // PlasmaSphere does 20 damage with 'Pulsed' type
                TTarget.TakeDamage(P.Damage, P.Instigator, TTarget.Location, Normal(P.Velocity) * P.MomentumTransfer, 'Pulsed');
                P.Explode(P.Location, Normal(TTarget.Location - P.Location));
                if (TTarget == None || TTarget.bDeleteMe)
                    return true;
            }
            continue;
        }
    }

    return false;
}

function SimulateProjectileWithHistory(ST_TranslocatorTarget TTarget, int Ping) {
    local float GameDeltaTime;
    local float RealDeltaTime;
    local float SimPing;
    local float RealTimeRemaining;
    local float AccumulatedGameTime;
    local int HistoryInterval;
    local UTPure PureRef;
    local vector CurrentPos;
    local vector Delta;
    local float MinMovementSquared;
    local float TotalGameTime;

    if (TTarget == None || TTarget.bDeleteMe)
        return;

    PureRef = bbPlayer(TTarget.Instigator).zzUTPure;

    SimPing = float(Ping);

    // Cap ping compensation
    if (SimPing > WeaponSettings.PingCompensationMax)
        SimPing = WeaponSettings.PingCompensationMax;

    if (SimPing <= 0.0)
        return;

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

    // Calculate storage interval based on SimPing
    HistoryInterval = Max(1, int(SimPing / 49.0));
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
        if (CheckSimulationBeamCollisions(TTarget)) {
            PureRef.EndCompensation();
            return; // Translocator was destroyed by beam
        }

        // Check for recent shock combo explosions
        // MaxAge covers the simulation window plus a small buffer
        if (CheckRecentExplosions(TTarget, SimPing * 0.002)) {
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
                TTarget.HistoryCount < 50) {
                TTarget.AddSimulationHistoryStep(TTarget.Location, AccumulatedGameTime * 0.001);
            }
        }

        PureRef.EndCompensation();
    }

    // Store final simulated position
    if (TTarget != None && TTarget.HistoryCount < 50) {
        TTarget.AddSimulationHistoryStep(TTarget.Location, TTarget.TotalSimulationTime);
    }
}

function SimulateProjectile(Projectile P, int Ping) {
  local float DeltaTime;
  local float SimPing;
  local UTPure PureRef;

  // Early exit if the projectile is already destroyed
  if (P == None || P.bDeleteMe)
    return;

  PureRef = bbPlayer(P.Instigator).zzUTPure;

  SimPing = Ping * 0.5;

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
  local UTPure PureRef;
  local int i;
  local bool bAnyAlive;
  
  if (NumProjectiles == 0 || Projectiles[0] == None)
    return;
    
  PureRef = bbPlayer(Projectiles[0].Instigator).zzUTPure;

  SimPing = Ping * 0.5; // Simulate only 1-way latency
  
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

simulated function Actor TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace, Pawn PawnOwner)
{
	local Actor A, Other;
	local Pawn P;
	local bool bSProjBlocks;
	local bool bWeaponShock;
	local vector Dir;
	local UTPlusDummy D;
	local ST_ProjectileDummy PD;
	local bbPlayer bbP;
	local int Ping;
	local UTPure PureRef;
	
	Ping = 0;
	
	if (PawnOwner != None) {

		bbP = bbPlayer(PawnOwner);
	
		if (bbP != None) {
			PureRef = bbP.zzUTPure;
			Ping = bbP.PingAverage;

			// Cap hitscan ping compensation
			if (Ping > WSettingsRepl.PingCompensationMax)
				Ping = WSettingsRepl.PingCompensationMax;
		}
		
		bWeaponShock = (PawnOwner.Weapon != none && PawnOwner.Weapon.IsA('ShockRifle'));
	}
	
	bSProjBlocks = WSettingsRepl.ShockProjectileBlockBullets;
	Dir = Normal(EndTrace - StartTrace);

	if (WSettingsRepl.bEnablePingCompensation && bbP != none)
	{
		PureRef.CompensateFor(Ping, PawnOwner);

		foreach TraceActors( class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {
			if (A == PawnOwner) {
				continue;
			}
			if (A.IsA('UTPlusDummy')) {
				D = UTPlusDummy(A);
				
				if (D.Actual != PawnOwner) {
					if (D.AdjustHitLocation(HitLocation, EndTrace - StartTrace)) {
						if (CheckBodyShotCompensated(D, HitLocation, Dir) == false && CheckHeadShotCompensated(D, HitLocation, Dir) == false) {
    							continue;
    						}
						
						Other = D.Actual;
						break;
					}
				}
			}
			else if (A.IsA('ST_ProjectileDummy')) {
				PD = ST_ProjectileDummy(A);
				if (PD.Actual != None) {
					if (PD.Actual.IsA('ST_ShockProj')) {
						if (bWeaponShock || bSProjBlocks) {
							Other = PD.Actual; // Return the actual shock projectile
							break;
						}
					}
					else if (PD.Actual.IsA('ST_TranslocatorTarget')) {
						Other = PD.Actual; // Return the actual translocator target
						break;
					}
				}
			}
			else if ((A == Level) || (Mover(A) != None) || A.bProjTarget || (A.bBlockPlayers && A.bBlockActors)) {
				if (bSProjBlocks || A.IsA('ShockProj') == false || bWeaponShock) {
					Other = A;
					break;
				}
			}
		}
		
		PureRef.EndCompensation();
		
		return Other;
	}
	else {
		foreach TraceActors(class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {
			P = Pawn(A);
			if (P != none) {
				if (P == PawnOwner) {
					continue;
				}
				
				if (P.AdjustHitLocation(HitLocation, EndTrace - StartTrace) == false) {
					continue;
				}
				
				if (CheckBodyShot(P, HitLocation, Dir) == false && CheckHeadShot(P, HitLocation, Dir) == false) {
					continue;
				}

				Other = A;
				break;
			} else if ((A == Level) || (Mover(A) != None) || A.bProjTarget || (A.bBlockPlayers && A.bBlockActors)) {
				if (bSProjBlocks || A.IsA('ShockProj') == false || bWeaponShock) {
					Other = A;
					break;
				}
			}
		}
		
		return Other;
	}
}

simulated function Actor TraceShotClient(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace, Pawn PawnOwner)
{
	local Actor A, Other;
	local Pawn P;
	local bool bSProjBlocks;
	local bool bWeaponShock;
	local vector Dir;

	bSProjBlocks = WSettingsRepl.ShockProjectileBlockBullets;

	bWeaponShock = (PawnOwner.Weapon != none && PawnOwner.Weapon.IsA('ShockRifle'));

	Dir = Normal(EndTrace - StartTrace);

	foreach TraceActors(class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {
		P = Pawn(A);
		if (P != none) {
			if (P == PawnOwner) {
				continue;
			}
			
			if (P.AdjustHitLocation(HitLocation, EndTrace - StartTrace) == false) {
				continue;
			}
			
			if (CheckBodyShot(P, HitLocation, Dir) == false && CheckHeadShot(P, HitLocation, Dir) == false) {
				continue;
			}

			Other = A;
			break;
		} else if ((A == Level) || (Mover(A) != None) || A.bProjTarget || (A.bBlockPlayers && A.bBlockActors)) {
			if (bSProjBlocks || A.IsA('ShockProj') == false || bWeaponShock) {
				Other = A;
				break;
			}
		}
	}
		
	return Other;
}

defaultproperties {

}