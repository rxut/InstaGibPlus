class ST_TranslocatorTarget extends TranslocatorTarget;

var IGPlus_WeaponImplementation WImp;
var WeaponSettingsRepl WSettings;

var PlayerPawn InstigatingPlayer;

var vector SimulationHistory[50];  // Store up to 50 positions
var float SimulationTimes[50];     // Timestamps for each position
var int HistoryCount;              // Number of valid history entries
var float SimulationStartTime;     // When simulation began
var float TotalSimulationTime;     // Total ping time simulated

// For temporary position changes during translocation
var vector PreTranslocateLocation;
var bool bUsingHistoricalPosition;

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

	if (GetWeaponSettings().TranslocatorCompensatePing && bbP != none && bbP.ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations == true) {

		In = PlayerPawn(Instigator);

		if (In != none && Viewport(In.Player) != none)
			InstigatingPlayer = In;

		if (InstigatingPlayer != none) {
			TL = ST_Translocator(InstigatingPlayer.Weapon);
			if (TL != none && TL.TTarget_Client != none && TL.TTarget_Client.bDeleteMe == false)
			{
				TL.TTarget_Client.Destroy();
				TL.TTarget_Client = None;
			}
		}
	}
}

function InitSimulationHistory(vector StartPos, float StartTime, float TotalTime) {
    SimulationHistory[0] = StartPos;
    SimulationTimes[0] = StartTime;
    HistoryCount = 1;
    SimulationStartTime = Level.TimeSeconds;
    TotalSimulationTime = TotalTime;
}

function AddSimulationHistoryStep(vector NewPos, float TimeStamp) {
    if (HistoryCount < 50) {
        SimulationHistory[HistoryCount] = NewPos;
        SimulationTimes[HistoryCount] = TimeStamp;
        HistoryCount++;
    }
}

function SimulateWithHistory(IGPlus_WeaponImplementation WImpl, int Ping)
{
    if (WImpl != None)
        WImpl.SimulateProjectileWithHistory(self, Ping);
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
	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
		local float OldDisruption;

		OldDisruption = Disruption;

		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

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
	bSimFall=True
}