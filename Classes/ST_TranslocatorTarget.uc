class ST_TranslocatorTarget extends TranslocatorTarget;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var PlayerPawn InstigatingPlayer;

var int MaxHistorySteps;             // cap for the throw-time fast-forward
var vector SimulationHistory[256];
var float SimulationTimes[256];
var byte SimulationLanded[256];     // 1 if Physics == PHYS_None at that entry
var int HistoryCount;
// Predicted translocation: keep recording the disc's path after the
// fast-forward, for its whole life, so any age can be looked up.
var bool bIGPlusFullHistory;
var float IGPlus_HistoryAnchor; // Level.TimeSeconds of age TotalSimulationTime, set on the first tick
var float SimulationStartTime;     // When simulation began
var float TotalSimulationTime;     // Total ping time simulated

// For temporary position changes during translocation
var vector PreTranslocateLocation;
var bool bUsingHistoricalPosition;
var EPhysics IGPlus_PreTranslocatePhysics;
var vector IGPlus_PreTranslocateVelocity;

simulated final function WeaponSettingsRepl FindWeaponSettings() {
	local WeaponSettingsRepl S;

	foreach AllActors(class'WeaponSettingsRepl', S)
		return S;

	return none;
}

simulated final function WeaponSettingsRepl GetWeaponSettings() {
	if (WSettings != none)
		return WSettings;

	WSettings = FindWeaponSettings();
	return WSettings;
}

simulated function PostBeginPlay() {
	local UTPure PureRef;
	local bbPlayer bbP;

	if (Instigator != none && Instigator.Role == ROLE_Authority) {

		bbP = bbPlayer(Instigator);
		if (bbP != none) {
			PureRef = bbP.zzUTPure;
		}
		
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
		
		if (PureRef != None) {
			PureRef.RegisterProjectile(self);
		}
	}
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local PlayerPawn In;
    local ST_Translocator TL;
	local bbPlayer bbP;

	if (Instigator != none) {
		bbP = bbPlayer(Instigator);
	}

	super.PostNetBeginPlay();

	if (GetWeaponSettings().TranslocatorCompensatePing && bbP != none
		&& (bbP.ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations || bbP.IGPlus_PredictedTranslocation)) {

		In = PlayerPawn(Instigator);

		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			TL = ST_Translocator(InstigatingPlayer.Weapon);
			if (TL != none && TL.TTarget_Client != none && TL.TTarget_Client.bDeleteMe == false)
			{
				// Merge: teleport server disc to where client disc is for seamless hand-off
				SetLocation(TL.TTarget_Client.Location);

				TL.TTarget_Client.Destroy();
				TL.TTarget_Client = None;
			}
		}
	}
}

function InitSimulationHistory(vector StartPos, float StartTime, float TotalTime) {
    SimulationHistory[0] = StartPos;
    SimulationTimes[0] = StartTime;
    SimulationLanded[0] = byte(Physics == PHYS_None);
    HistoryCount = 1;
    SimulationStartTime = Level.TimeSeconds;
    TotalSimulationTime = TotalTime;
}

function AddSimulationHistoryStep(vector NewPos, float TimeStamp) {
    if (HistoryCount < MaxHistorySteps) {
        SimulationHistory[HistoryCount] = NewPos;
        SimulationTimes[HistoryCount] = TimeStamp;
        SimulationLanded[HistoryCount] = byte(Physics == PHYS_None);
        HistoryCount++;
    }
}

function SimulateWithHistory(IGPlus_WeaponImplementation WImpl, int Ping)
{
    if (WImpl != None)
        WImpl.SimulateProjectileWithHistory(self, Ping);
}

// Server: append the current position at Age (seconds since the throw).
function IGPlus_RecordHistory(float Age) {
    local int i;
    local byte bLanded;

    if (HistoryCount <= 0)
        return;

    i = HistoryCount - 1;
    if (Age <= SimulationTimes[i])
        return;

    bLanded = byte(Physics == PHYS_None);
    // ponytail: 50ms heartbeat while resting so a later knock lerps from
    // the right time; 256 entries hold ~2s of flight at 120Hz
    if (Location == SimulationHistory[i] && bLanded == SimulationLanded[i] && Age - SimulationTimes[i] < 0.05)
        return;

    if (HistoryCount < arraycount(SimulationHistory))
        i = HistoryCount++;
    // else: full, keep refreshing the newest entry

    SimulationHistory[i] = Location;
    SimulationTimes[i] = Age;
    SimulationLanded[i] = bLanded;
}

// Position and landed state at Age seconds after the throw.
function vector IGPlus_GetHistoryAt(float Age, out byte bLanded) {
    local int i;
    local float Alpha;

    if (HistoryCount <= 0) {
        bLanded = byte(Physics == PHYS_None);
        return Location;
    }

    if (Age <= SimulationTimes[0]) {
        bLanded = SimulationLanded[0];
        return SimulationHistory[0];
    }

    for (i = 1; i < HistoryCount; i++) {
        if (Age < SimulationTimes[i]) {
            Alpha = (Age - SimulationTimes[i-1]) / FMax(SimulationTimes[i] - SimulationTimes[i-1], 0.0001);
            bLanded = SimulationLanded[i-1];
            return SimulationHistory[i-1] + Alpha * (SimulationHistory[i] - SimulationHistory[i-1]);
        }
    }

    bLanded = SimulationLanded[HistoryCount-1];
    return SimulationHistory[HistoryCount-1];
}

function vector GetHistoricalPosition(float RequestTime) {
    local int i;
    local float Alpha;
    local vector InterpolatedPos;
    
    if (HistoryCount <= 1)
        return Location;
    
    // Clamp request time
    RequestTime = FClamp(RequestTime, 0.0, TotalSimulationTime);
    
    // If before first time, return first position
    if (RequestTime <= SimulationTimes[0])
        return SimulationHistory[0];
        
    // If after last time, return last position
    if (RequestTime >= SimulationTimes[HistoryCount-1])
        return SimulationHistory[HistoryCount-1];
    
    // Find the time bracket (backward search for efficiency)
    for (i = HistoryCount - 1; i > 0; i--) {
        if (SimulationTimes[i-1] <= RequestTime && RequestTime <= SimulationTimes[i]) {
            Alpha = (RequestTime - SimulationTimes[i-1]) / 
                    (SimulationTimes[i] - SimulationTimes[i-1]);
            InterpolatedPos = SimulationHistory[i-1] + 
                             Alpha * (SimulationHistory[i] - SimulationHistory[i-1]);
            return InterpolatedPos;
        }
    }
    
    // Fallback (shouldn't reach here with valid data)
    return Location;
}

auto state Pickup {
	simulated function Tick(float DeltaTime) {
		// Full history needs every tick; the stock Tick switches itself off
		// for player discs, and has nothing else to do for them.
		if (bIGPlusFullHistory && Role == ROLE_Authority) {
			// Tick runs before this frame's physics: the disc has flown until
			// Level.TimeSeconds - DeltaTime.
			if (IGPlus_HistoryAnchor == 0.0)
				IGPlus_HistoryAnchor = Level.TimeSeconds - DeltaTime;
			IGPlus_RecordHistory(TotalSimulationTime + (Level.TimeSeconds - DeltaTime - IGPlus_HistoryAnchor));
			if (DesiredTarget == None || Master == None)
				return;
		}
		super.Tick(DeltaTime);
	}

	simulated event Landed(vector HitNormal) {
		super.Landed(HitNormal);

		// Record where it came to rest, and keep ticking for the heartbeat.
		if (bIGPlusFullHistory && Role == ROLE_Authority && IGPlus_HistoryAnchor != 0.0) {
			IGPlus_RecordHistory(TotalSimulationTime + (Level.TimeSeconds - IGPlus_HistoryAnchor));
			Enable('Tick');
		}
	}

	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
		local float OldDisruption;

		OldDisruption = Disruption;

		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

		// Landed() switched Tick off; a knocked disc flies again.
		if (bIGPlusFullHistory)
			Enable('Tick');

		if (Disruption == OldDisruption)
			return;

		if (Master != none && Master.Owner != none && Master.Owner.IsA('bbPlayer'))
			bbPlayer(Master.Owner).ClientDebugMessage("TTarget took"@Damage@"damage (Total"@int(Disruption)$")");
	}

	singular function Touch(Actor Other) {
		local bool bMasterTouch;
		local vector NewPos;
		local UTPlusDummy Dummy;
		local Pawn ActualPawn;
		
		if (Other.IsA('ST_HitTestHelper'))
			return;
			
		// Handle UTPlusDummy touches during lag compensation
		if (Other.IsA('UTPlusDummy')) {
			Dummy = UTPlusDummy(Other);
			if (Dummy.Actual != None) {
				ActualPawn = Dummy.Actual;
				
				// Check if it's the master (owner) touching their own disc
				bMasterTouch = (ActualPawn == Instigator);
				
				if (Physics == PHYS_None) {
					if (bMasterTouch) {
						PlaySound(Sound'Botpack.Pickups.AmmoPick',,2.0);
						Master.TTarget = None;
						Master.bTTargetOut = false;
						if (ActualPawn.IsA('PlayerPawn'))
							PlayerPawn(ActualPawn).ClientWeaponEvent('TouchTarget');
						destroy();
					}
					return;
				}
				
				if (bMasterTouch)
					return;
					
				// Stick to the dummy's location
				NewPos = Dummy.Location;
				NewPos.Z = Location.Z;
				SetLocation(NewPos);
				Velocity = vect(0,0,0);
				
				// Check team game rules
				if (Level.Game.bTeamGame && 
					ActualPawn.PlayerReplicationInfo != None &&
					Instigator.PlayerReplicationInfo != None &&
					(Instigator.PlayerReplicationInfo.Team == ActualPawn.PlayerReplicationInfo.Team))
					return;
					
				// Bot auto-translocate
				if (Instigator.IsA('Bot'))
					Master.Translocate();
					
				return;
			}
		}
		
		// Original touch handling for non-dummy actors
		super.Touch(Other);
	}
}

defaultproperties {
	MaxHistorySteps=50
	bSimFall=True
}