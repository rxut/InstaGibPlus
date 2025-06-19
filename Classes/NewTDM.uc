class NewTDM extends BotPack.TeamGamePlus;

var int NumValidSpawns;
var PlayerStart ValidSpawns[64];

var IGPlus_WeaponImplementation WImp;

function PostBeginPlay()
{
    local PlayerStart Dest;
    local NavigationPoint N;

	Super.PostBeginPlay();

    for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint) {
        Dest = PlayerStart(N);
        if (Dest != None && Dest.bEnabled) {
            if (NumValidSpawns < 64) {
                ValidSpawns[NumValidSpawns] = Dest;
                NumValidSpawns++;
            }
        }
    }

	ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
		break;		// Find master :D
}

function NavigationPoint FindPlayerStart(Pawn Player, optional byte InTeam, optional string IncomingName) {
    local NavigationPoint Start;
    
    if (WImp.WeaponSettings.bAdvancedSpawns && !bStartMatch && bbPlayer(Player) != None && bbPlayer(Player).StartSpot != None)
    {
        log("Using advanced spawns.");
        Start = FindPlayerStartAdvanced(Player, InTeam, IncomingName);
    }
    else
    {
        log("Using default spawns.");
        Start = Super.FindPlayerStart(Player, InTeam, IncomingName);
    }

    return Start;
}

function NavigationPoint FindPlayerStartAdvanced(Pawn Player, optional byte InTeam, optional string IncomingName)
{
    local byte Team;
    local bool bInvalid, bLineOfSight, bIsRelevantDist, bIsMinZVariance;
    local int i, CurrentScore, BestScore, StartScore;
    local float CollisionDist, PlayerDist, SpawnDist, EnemyZVariance;
	local PlayerStart Best;
	local Pawn OtherPlayer;
	local Teleporter Tel;

    if (NumValidSpawns == 0)
	{
		log("NewTDM.FindPlayerStartAdvanced: No valid spawns found, falling back to default.");

	}

    if (Player == None)
        return ValidSpawns[0];

	if (Player != None && Player.PlayerReplicationInfo != None)
		Team = Player.PlayerReplicationInfo.Team;
	else
		Team = InTeam;

	if (IncomingName != "") {
		ForEach AllActors(class 'Teleporter', Tel) {
			if (string(Tel.Tag) ~= IncomingName)
				return Tel;
        }
    }

	if (Team == 255)
	    Team = 0;

	CollisionDist = 2 * (CollisionRadius + CollisionHeight);
    BestScore = 0;
    Best = ValidSpawns[Rand(NumValidSpawns)];
    if (Team == 0)
        StartScore = Teams[1].Size * WImp.WeaponSettings.SpawnRelevantDistance;
    else
        StartScore = Teams[0].Size * WImp.WeaponSettings.SpawnRelevantDistance;

	for (i = 0; i < NumValidSpawns; i++) {
	    bInvalid = False;
	    CurrentScore = StartScore;
	    if (bbPlayer(Player) != None) {
	        if (ValidSpawns[i] == bbPlayer(Player).StartSpot) {
	            bInvalid = True;
	            continue;
            } else {
                if (bbPlayer(Player).LastStartSpot2 == ValidSpawns[i] || bbPlayer(Player).LastStartSpot3 == ValidSpawns[i]) {
                    CurrentScore *= WImp.WeaponSettings.SpawnRecentPenalty;
                }
                SpawnDist = VSize(bbPlayer(Player).StartSpot.Location - ValidSpawns[i].Location);
                if (SpawnDist < WImp.WeaponSettings.SpawnRelevantDistance) {
                    CurrentScore -= (SpawnDist * WImp.WeaponSettings.SpawnNearLastPenalty);
                }
            }
        }

        for (OtherPlayer = Level.PawnList; OtherPlayer != None; OtherPlayer = OtherPlayer.NextPawn) {
            if (OtherPlayer == Player)
                continue;
            if (OtherPlayer.bIsPlayer && !OtherPlayer.IsA('Spectator') && OtherPlayer.Health > 0) {
                PlayerDist = VSize(OtherPlayer.Location - ValidSpawns[i].Location);
                if (PlayerDist < CollisionDist) {
                    bInvalid = True;
                    break;
                }
                bIsRelevantDist = (PlayerDist < WImp.WeaponSettings.SpawnRelevantDistance);
                bLineOfSight = FastTrace(ValidSpawns[i].Location, OtherPlayer.Location);
                if (OtherPlayer.PlayerReplicationInfo.Team != Team) {
                    EnemyZVariance = OtherPlayer.Location.Z - ValidSpawns[i].Location.Z;
                    bIsMinZVariance = (EnemyZVariance <= WImp.WeaponSettings.MinSpawnZVariance);
                    if (PlayerDist < WImp.WeaponSettings.MinSpawnDistance && (!bIsMinZVariance || bLineOfSight)) {
                        bInvalid = True;
                        break;
                    }
                    if (WImp.WeaponSettings.bSafeSpawns && !bIsMinZVariance && bIsRelevantDist) {
                        PlayerDist = WImp.WeaponSettings.SpawnRelevantDistance - PlayerDist;
                        if (bLineOfSight)
                            CurrentScore -= (PlayerDist * WImp.WeaponSettings.SpawnLOSPenalty);
                        else
                            CurrentScore -= PlayerDist;
                    }
                }
            }
        }

        if (!bInvalid) {
            CurrentScore = Rand(Max(WImp.WeaponSettings.DefaultSpawnWeight + CurrentScore, 0));
            if (CurrentScore > BestScore) {
                BestScore = CurrentScore;
                Best = ValidSpawns[i];
            }
        } else
            continue;
	}

	if (Player.IsA('bbPlayer')) {
        bbPlayer(Player).LastStartSpot3 = bbPlayer(Player).LastStartSpot2;
        bbPlayer(Player).LastStartSpot2 = bbPlayer(Player).StartSpot;
    }
    LastStartSpot = Best;
	return Best;
}

function bool RestartPlayer(Pawn aPlayer)
{
	local bool bResult, bFoundStart;
	local Bot B;
	local NavigationPoint StartSpot;

	aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
	B = Bot(aPlayer);
	if (B != None && Level.NetMode != NM_Standalone && TooManyBots()) {
		aPlayer.Destroy();
		return False;
	}

    if (bRestartLevel && Level.NetMode != NM_DedicatedServer && Level.NetMode != NM_ListenServer)
        bResult = True;

    StartSpot = FindPlayerStart(aPlayer, 255);
    if (StartSpot == None) {
        Log("Player start not found!!!");
        bResult = False;
    }
    bFoundStart = aPlayer.SetLocation(StartSpot.Location);
    if (bFoundStart) {
        StartSpot.PlayTeleportEffect(aPlayer, True);
        aPlayer.SetRotation(StartSpot.Rotation);
        aPlayer.ViewRotation = aPlayer.Rotation;
        aPlayer.Acceleration = vect(0,0,0);
        aPlayer.Velocity = vect(0,0,0);
        aPlayer.Health = aPlayer.Default.Health;
        aPlayer.SetCollision(aPlayer.Default.bCollideActors, aPlayer.Default.bBlockActors, aPlayer.Default.bBlockPlayers);
        aPlayer.ClientSetLocation(StartSpot.Location, StartSpot.Rotation);
        aPlayer.bHidden = False;
        aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
        aPlayer.SoundDampening = aPlayer.Default.SoundDampening;
        AddDefaultInventory(aPlayer);
    } else
        Log(StartSpot$" Player start not use-able!!!");
    bResult = bFoundStart;

	if (aPlayer.IsA('TournamentPlayer'))
		TournamentPlayer(aPlayer).StartSpot = LastStartSpot;
	return bResult;
}

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if (injured.Region.Zone.bNeutralZone)
		return 0;

	if (instigatedBy == None)
		return Damage;

	if (bNoviceMode && !bThreePlus)
	{
		if (instigatedBy.bIsPlayer && (injured == instigatedby) && (Level.NetMode == NM_Standalone))
			Damage *= 0.5;

		if (instigatedBy.IsA('Bot') && injured.IsA('PlayerPawn'))
		{
			if ( ((instigatedBy.Weapon != None) && instigatedBy.Weapon.bMeleeWeapon)
				|| ((injured.Weapon != None) && injured.Weapon.bMeleeWeapon && (VSize(injured.location - instigatedBy.Location) < 600)) )
				Damage = Damage * (0.76 + 0.08 * instigatedBy.skill);
			else
				Damage = Damage * (0.25 + 0.15 * instigatedBy.skill);
		}
	}

	Damage = Damage * instigatedBy.DamageScaling;

	if ((instigatedBy != injured) && injured.bIsPlayer && instigatedBy.bIsPlayer
	    && injured.PlayerReplicationInfo != none
		&& instigatedBy.PlayerReplicationInfo != none
		&& (injured.PlayerReplicationInfo.Team == instigatedBy.PlayerReplicationInfo.Team))
	{
		if (injured.IsA('Bot'))
			Bot(Injured).YellAt(instigatedBy);
		return (Damage * FriendlyFireScale);
	}
	else
		return Damage;
} 