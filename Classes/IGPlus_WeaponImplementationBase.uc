class IGPlus_WeaponImplementationBase extends IGPlus_WeaponImplementation;

var ST_HitTestHelper CollChecker;
var ST_HitTestHelper HitTestHelper;

function PostBeginPlay() {
	super.PostBeginPlay();

	HitTestHelper = Spawn(class'ST_HitTestHelper');
	CollChecker = Spawn(class'ST_HitTestHelper');
	CollChecker.SetCollision(true, false, false);
}

function EnhancedHurtRadius(
	Actor  Source,
	float  DamageAmount,
	float  DamageRadius,
	name   DamageName,
	float  Momentum,
	vector HitLocation,
	optional bool bIsRazor2Alt
) {
	local actor Victim;
	local float damageScale, dist;
	local float DamageDiffraction;
	local float MomentumScale;
	local vector MomentumDelta, MomentumDir;
	local vector Delta, DeltaXY;
	local vector Closest;
	local vector dir;

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

		Victim.TakeDamage(
			damageScale * DamageAmount,
			Source.Instigator,
			Victim.Location - 0.5 * (Victim.CollisionRadius + Victim.CollisionHeight) * dir,
			(MomentumScale * Momentum * MomentumDir),
			DamageName
		);
	}

	CollChecker.SetCollision(false, false, false);

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

function SimulateProjectileWithHistory(ST_TranslocatorTarget TTarget, int Ping) {
    local float DeltaTime;
    local float SimPing;
    local float AccumulatedTime;
    local int HistoryInterval;
    local UTPure PureRef;
    local vector CurrentPos;
    local vector Delta;
    local float MinMovementSquared;
    
    if (TTarget == None || TTarget.bDeleteMe)
        return;
        
    PureRef = bbPlayer(TTarget.Instigator).zzUTPure;
    SimPing = float(Ping) * 0.5;
    
    // Cap ping compensation
    if (SimPing > WeaponSettings.PingCompensationMax)
        SimPing = WeaponSettings.PingCompensationMax;
        
    if (SimPing <= 0.0)
        return;
        
    // Pre-calculate squared threshold
    MinMovementSquared = 0.01;
        
    // Store initial position BEFORE simulation
    CurrentPos = TTarget.Location;
    
    TTarget.InitSimulationHistory(CurrentPos, 0.0, float(Ping) * 0.001);
    
    // Calculate time step based on SimPing (Half-Ping)
    DeltaTime = 0.001 * SimPing * Level.TimeDilation;
    DeltaTime = DeltaTime / (int(DeltaTime * GetAverageTickRate()) + 1);
    
    // Calculate storage interval based on SimPing
    HistoryInterval = Max(1, int(SimPing / 49.0));
    AccumulatedTime = 0.0;
    
    while (SimPing > 0.0 && TTarget != None && !TTarget.bDeleteMe) {
        PureRef.CompensateFor(int(SimPing), TTarget.Instigator);
        
        CurrentPos = TTarget.Location;
        
        TTarget.AutonomousPhysics(DeltaTime);
        
        SimPing -= DeltaTime * 1000.0;
        AccumulatedTime += DeltaTime * 1000.0;
        
        Delta = TTarget.Location - CurrentPos;
        if ((Delta.X * Delta.X + Delta.Y * Delta.Y + Delta.Z * Delta.Z) > MinMovementSquared) {
            if (AccumulatedTime >= HistoryInterval * (TTarget.HistoryCount - 1) && 
                TTarget.HistoryCount < 50) {
                TTarget.AddSimulationHistoryStep(TTarget.Location, AccumulatedTime * 0.001);
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