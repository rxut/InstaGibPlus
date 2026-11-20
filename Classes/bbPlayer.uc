class bbPlayer extends TournamentPlayer
	config(User) abstract;

var int bReason;
// Client Config
var bool bNewNet;	// if Client wants new or old netcode. (default true)

// Replicated settings Client -> Server
var int		zzNetspeed;		// The netspeed this client is using
var bool	zzbDemoRecording;	// True if client is recording demos.
var bool bIsFinishedLoading;

// Replicated settings Server -> Client
var int		zzTrackFOV;		// Track FOV ?
var bool	zzCVDeny;		// Deny CenterView ?
var float	zzCVDelay;		// Delay for CenterView usage
var int		zzMinimumNetspeed;	// Default 10000, it's the minimum netspeed a client may have.
var int		zzMaximumNetspeed;	// Default 25000, it's the maximum netspeed a client may have.
var float	zzWaitTime;		// Used for diverse waiting.
var bool	zzbForceModels;		// Allow/Enable/Force Models for clients.
var bool	zzbForceDemo;		// Set true by server to force client to do demo.
var bool	zzbGameStarted;	// Set to true when Pawn spawns first time (ModifyPlayer)
var byte	HUDInfo;		// 0 = Off, 1 = boots/timer, 2 = Team Info too.

// Debug Stuff
var bool bDrawDebugData;
var vector debugNewAccel;
var vector debugPlayerLocation;
var vector debugClientHitLocation;
var vector debugClientHitNormal;
var vector debugClientHitDiff;
var vector debugClientEnemyHitLocation;
var vector clientForcedPosition;
var bool bClientPawnHit;
var float debugClientLocError;
var bool debugClientForceUpdate;
var int debugNumOfForcedUpdates;
var float clientLastUpdateTime;
var int debugServerMoveCallsSent;
var int debugServerMoveCallsReceived;

// Control stuff
var float	zzTick;			// The Length of Last Tick
var bool	zzbNoMultiWeapon;	// Server-Side only! tells if multiweapon bug can be used.
var int     zzThrowVelocity;
var bool	zzbDemoPlayback;	// Is currently a demo playback (via xxServerMove detection)
var bool	zzbGotDemoPlaybackSpec;
var CHSpectator zzDemoPlaybackSpec;
var bbClientDemoSN zzDemoPlaybackSN;
var bool bDemoStarted;
var bool IGPlus_IsDemoPlayback;
var float IGPlus_DemoCheckTime;
var string IGPlus_DemoRealSkinKey;
var Texture IGPlus_DemoRealMultiSkins[8];
var float IGPlus_GameEndedTime;
var bool IGPlus_AutoDebugData;    // server: Settings.bAutoDebugData, set after the warmup countdown (as zzbForceDemo)
var bool IGPlus_AutoDebugStarted; // Auto Debug Data ran this map
var float IGPlus_AutoDebugEndTime;

// Stuff
var float	zzDesiredFOV;		// Needed ?
var float	zzOrigFOV;		// Original FOV for TrackFOV = 1
var string	FakeClass;		// Class that the model replaces
var string	zzMyPacks;		// Defined only for defaults
var bool	zzbBadGuy;		// BadGuy! (Avoid kick spamming)
var int     zzRecentDmgGiven, zzRecentTeamDmgGiven;
var name    zzDefaultWeapon;
var float   zzLastHitSound, zzLastTeamHitSound;
var Projectile zzNN_Projectiles[256];
var vector zzNN_ProjLocations[256];
var int     zzFRVI, zzNN_FRVI, FRVI_length, zzVRVI, zzNN_VRVI, VRVI_length, zzNN_ProjIndex, NN_ProjLength, zzEdgeCount, zzCheckedCount;
var rotator zzNN_ViewRot;
var actor   zzNN_HitActor, zzOldBase;
var Vector  zzNN_HitLoc, zzClientHitNormal, zzClientHitLocation, zzNN_HitDiff, zzNN_HitLocLast, zzNN_HitNormalLast, zzNN_ClientLoc, zzNN_ClientVel;
var bool    zzbIsWarmingUp, zzbFakeUpdate, zzbForceUpdate, zzbNN_Special, zzbNN_ReleasedFire, zzbNN_ReleasedAltFire;
var float   zzNN_Accuracy, zzLastStuffUpdate, zzNextTimeTime, zzForceUpdateUntil, zzLastLocDiff, zzSpawnedTime;
var TournamentWeapon zzGrappling;
var float zzGrappleTime;
var float LastFireTimeStamp;
var float LastAltFireTimeStamp;
var float IGPlus_DeterministicSwitchGuardUntil;
var Weapon IGPlus_DetClientPendingSeen;
// Switch requested server-side but not yet holstered (deferral window). Kept
// apart from stock ClientPending: stock ClientActive/ClientDown self-holster
// on that field, which must only happen once the server sends ClientPutDown.
var Weapon IGPlus_DetClientSwitchPending;
// Client: a switch away from the deterministic translocator went to the
// server unpredicted; its translocator is going down when that arrives.
var float IGPlus_DetTlocSwitchSentUntil;
// Bring-up entry gate replicated from the server (move-timestamp domain,
// which is the client's own clock). Client prediction may not fire before it.
var float IGPlus_DetClientEntryGateTS;
// Client: the weapon the server last sent a bring-up gate for, i.e. the weapon
// the server has actually equipped. Never predict a weapon before that.
var Weapon IGPlus_DetClientGateWeapon;
var float IGPlus_DetPendingFireTapTS;
// Weapon the queued tap belongs to; it never fires a different weapon.
var Weapon IGPlus_DetPendingFireTapWeapon;
// PendingWeapon picked by the out-of-ammo handler during the holster hold.
var Weapon IGPlus_DetAutoSwitchPending;
// Server: move timestamp minus server time, against the client's best
// (least delayed) offset. Lead = how far the client clock runs ahead.
var float IGPlus_DetFireClockLead;
var float IGPlus_DetClockBaseline;
var float IGPlus_DetClockLearnUntil;
var float IGPlus_DetLastClockLogTS;
// Server: how long after a switch the client may still predict the old weapon
// (it learns of the switch one round trip later). Set when the switch is seen.
var float IGPlus_DetInFlightSlack;
var float IGPlus_DetLastRejectLogTS;
// Predicted switching (Docs/predicted-weapon-switching.md). Both sides run the
// same timeline from the press timestamp TS (move clock):
//   holster = max(TS, post-shot hold), equip = holster + down, gate = equip + select.
var bool IGPlus_PredictedSwitching;   // server setting, replicated to the owner
var bool IGPlus_PredictedTranslocation; // server setting, replicated to the owner
var bool IGPlus_PredictedSelfKnockback; // server setting, replicated to the owner
var bool IGPlus_PushSafeAim;            // server setting, replicated to the owner
var bool IGPlus_DetTranslocator;        // server setting, replicated to the owner
var bool IGPlus_PredictedDiscBoost;     // server setting, replicated to the owner
var float IGPlus_PredComboTS;           // client: our last drawn shock combo (IGPlus_OwnerComboRing)
var vector IGPlus_PredComboLoc;
var ST_ShockProj IGPlus_WallBall;       // server: our shock ball waiting for our moves, at a wall (ST_ShockProj.IGPlus_WallWait) or on something it touched (IGPlus_TouchWait)
// Our shock beam and our own balls, as our client's screen had them: 0 no
// verdict (the server's own trace decides), 1 the beam met none of them, 2 it
// set off our newest ball, 3 the one before (ST_ShockRifle.IGPlus_ClientOwnBall).
// It rides the shot's move with IGPlus_DetOwnBeamMode, and the server follows it
// where its own record of the ball agrees (ST_ShockRifle.IGPlus_VerdictBall).
var int IGPlus_OwnBallVerdict;
var float IGPlus_OwnBallTS[2];          // client: when we fired our two newest shock balls, newest first
var ST_ShockProj IGPlus_OwnBalls[2];    // server: our two newest shock balls, newest first (None: that shot made none)
var string IGPlus_OwnBallEnd[2];        // server, debug data: what ended each of them (ST_ShockProj.IGPlus_NoteEnd)
var float IGPlus_OwnBallEndTS[2];       // server, debug data: and when, in our move timestamps
var float IGPlus_MoveFrameDelta;        // server: the length of the client's frame the move being run ends in (a shot's move is that one frame)
// Client demos: what our client draws itself before the server's copy
// arrives (our own projectiles) is not in a client demo. Those copies are
// RemoteRole None, and the engine records an actor a client spawned with
// only its class and spawn spot. IGPlus_DemoTrack sends a copy of each into
// the demo: playback spawns it, puts it where ours was every frame and
// removes it when ours goes.
var Actor IGPlus_DemoCopy[32];          // recording client: ours; playback: the copies
var byte IGPlus_DemoCopyOn[32];         // recording client: slot in use
var int IGPlus_DemoCopies;              // recording client: slots in use
var IGPlus_ClientDemoClock IGPlus_DemoRecClock; // recording client: our clock in the demo
var ST_Translocator IGPlus_DetTloc;     // client: translocator whose disc we own
// A shock beam's verdict on our own deterministic disc, as our screen had
// it: 0 none, 1 missed, 2 hit. The client sets it on the shot and the
// shot's move carries it (DetChargeData); the server follows it
// (ST_Translocator.IGPlus_DetOwnBeam).
var int IGPlus_DetOwnBeamMode;
var bool IGPlus_PSActive;
var int IGPlus_PSSerial;
var Weapon IGPlus_PSFrom;
var Weapon IGPlus_PSTarget;
var float IGPlus_PSTS;
var float IGPlus_PSHolsterTS;
var float IGPlus_PSEquipTS;
var float IGPlus_PSGate;
var float IGPlus_PSPrevGate;          // client: From's gate, restored on cancel
var bool bPSHolsterStarted;
var bool bPSForcing;                  // server: the timeline's own ChangedWeapon
var float IGPlus_PSSpawnTS;           // our client's timestamp the server had reached when it respawned us (both sides)
var Weapon IGPlus_PSKeep;             // client: weapon the timeline put up (vs stale echoes)
var Weapon IGPlus_PSFiltFrom[8];      // client: server ClientPutDowns to drop (see IGPlus_PSFilterDrops)
var Weapon IGPlus_PSFiltT1[8];
var Weapon IGPlus_PSFiltT2[8];
var float IGPlus_PSFiltUntil[8];
var Weapon IGPlus_NextTrans;          // server: next life's translocator, already on our client (IGPlus_PrepareNextTrans)
var float IGPlus_InvHeadAddTS;        // server: when AddInventory last put an item at the head of our chain
// Predicted switching (server, log only): presses that went to the stock command.
var float IGPlus_PredSwitchLastLogTS;
var int IGPlus_MovesHeld;            // server: moves the speed-hack check held since the last [TIMEMARGIN] line
var float IGPlus_MovesHeldLogTS;
var float IGPlus_MovesHeldLastTS;
var float IGPlus_PSLastLogTS;         // server: IGPlus_PSLog's own throttle (a pipe bind's next command lands in the same tick)
// Client: frame timestamp of the latest locally predicted Det shot.
var float IGPlus_DetClientShotTS;
// Server, sent to our client: the move time our last interval shot ran on
// (IGPlus_DetNoteShot). Client: the last value it acted on.
var float IGPlus_DetServerShotTS;
var float IGPlus_DetServerShotSeen;
var float IGPlus_DetLastShotTS;
var float IGPlus_DetHolsterHoldUntilTS;
var float IGPlus_DetPendingStuckSince;
var float IGPlus_DetLastWedgeDumpTS;
// Server-side v4 binding invariants: weapon switched away from (grace window
// for in-flight steps, move-timestamp domain) and the last move's held state
// (fire continuity when switching to a weapon the v4 path does not drive).
var Weapon IGPlus_DetPrevWeapon;
var float IGPlus_DetPrevWeaponUntilTS;
var bool IGPlus_LastFireEndHeld;
var bool IGPlus_LastAltEndHeld;
// Feign death: a button already held when the feign began (server-side), and
// the weapon we went down holding (client-side).
var bool IGPlus_FeignFireHeld;
var bool IGPlus_FeignAltFireHeld;
var Weapon IGPlus_FeignWeapon;
// ServerMove v4 deterministic fire-window state (move-timestamp domain).
var float IGPlus_DetWeaponGateTS;
var Weapon IGPlus_DetPendingSeen;
var float IGPlus_DetPendingSeenTS;
var float IGPlus_DetPrevWeaponStepTS; // grace weapon: last valid step time
var Weapon zzKilledWithWeapon;
var Pawn zzLastKilled;
var vector zzLast10Positions[10];	// every 50ms for half a second of backtracking
var bbOldMovementInfo OldestMI, NewestMI;
var int zzPositionIndex;
var float zzNextPositionTime;
var bool zzbNN_Tracing;
var Weapon zzPendingWeapon;
var float LastCAPTime; // ServerTime when last CAP was sent
var decoration carriedFlag;
var WeaponSettingsRepl WSettings;

// HUD stuff
var Mutator	zzHudMutes[50];		// Accepted Hud Mutators
var Mutator	zzWaitMutes[50];	// Hud Mutes waiting to be accepted
var float	zzWMCheck[50];		// Key value
var int		zzFailedMutes;		// How many denied Mutes have been tried to add
var int		zzHMCnt;		// Counts of HudMutes and WaitMutes
var int		zzHUDWarnings;		// Counts the # of times the HUD has been changed

// Logo Display
var bool	zzbLogoDone;		// Are we done with the logo ?
var float	zzLogoStart;		// Start of logo display

var int		zzSMCnt;		// ServerMove Count
var bool	bMenuFixed;		// Fixed Menu item
var float	zzCVTO;			// CenterView Time out.

// Avoiding spam:		// How many times has name been changed
var Class<ChallengeVoicePack> zzDelayedVoice;
var float zzDelayedStartTime;
var float zzLastSpeech;
var float zzLastTaunt;
var float zzLastView,zzLastView2;
var int zzKickReady;
var int zzAdminLoginTries;
var int zzOldNetspeed,zzNetspeedChanges;

// Fixing demo visual stuff
var int zzRepVRYaw, zzRepVRPitch;
var float zzRepVREye;
var bool zzbRepVRData;

// Server demos (prefix IGPlus_SD). A server demo stores the server's view of
// each player once per server tick. The server turns its moves back into the
// player's own move timing (client timestamps) and records that, plus their
// exact view, FOV and the delay they saw the others at. Playback (udemo
// following a player) draws the camera from it.
// The server acknowledges a client's moves at least this often (seconds), with a FakeCAP when no correction went out.
const IGPLUS_FAKE_CAP_INTERVAL = 0.1;
const IGPLUS_SD_RECSIZE = 48;
const IGPLUS_SD_HISTSIZE = 128;
// Server: the player's recent moves, by client timestamp.
var float IGPlus_SDRecTS[48];
var vector IGPlus_SDRecLoc[48];
var int IGPlus_SDRecView[48];
var float IGPlus_SDRecEye[48];
var Actor IGPlus_SDRecBase[48];  // lift we stood on
var vector IGPlus_SDRecRel[48];  // where on it
var byte IGPlus_SDRecBreak[48];  // first move after a teleport/translocate
var int IGPlus_SDRecHead;
var int IGPlus_SDRecCount;
var float IGPlus_SDLastMoveTS;
var float IGPlus_SDLastSampleTime;
var float IGPlus_SDOffset;      // lowest (server time - client timestamp) seen
var bool IGPlus_SDHaveOffset;
var float IGPlus_SDMinCur;      // lowest offset this second
var float IGPlus_SDMinPrev[3];  // and in the 3 seconds before
var float IGPlus_SDMinBucketEnd;
var float IGPlus_SDJitter;      // average arrival lateness over the lowest
var float IGPlus_SDWinMin;      // the lowest offset of the last 3-4 seconds
var float IGPlus_SDDelay;       // playout delay behind the newest move
var float IGPlus_SDRewindTime;  // what the player saw the others behind by
var float IGPlus_SDRewindTarget;
var float IGPlus_SDNextRewindRead;
var int IGPlus_SDLastTloc;
// Client -> server: our current FOV, and whether we are zoomed.
var byte IGPlus_ClientFOV;
var bool IGPlus_ClientZoomed;
// Server -> server demo only (never live clients, never client demos).
var vector IGPlus_DemoPos;       // where the player was at their own move timing
var vector IGPlus_DemoRawOff;    // server Location minus IGPlus_DemoPos
var float IGPlus_DemoEye;
var int IGPlus_DemoOthersDelayMs;
var byte IGPlus_DemoFlags;       // 1 = written by a server with this code
var byte IGPlus_DemoFOV;
var bool IGPlus_DemoZoomed;
var Sound IGPlus_DemoWeaponAmbient;
// Server -> server demo only, for tools that measure aim. The view of the
// newest move the server ran for this player and that move's client time
// stamp, as they arrived (DemoViewPitch/Yaw are re-timed and blended for
// watching, 10 to 100 ms behind). A tick with no new move leaves both as
// they were. The time stamp is the client's Level.TimeSeconds (it runs with
// the game speed), the same clock as a shot record's (IGPlus_DemoShot).
var int IGPlus_DemoRawView;      // (Pitch << 16) | Yaw, 16 bits each
var float IGPlus_DemoRawTS;
// The newest shot record of this player (IGPlus_DemoShot), in playback and on
// the server. A tool reads these when IGPlus_DemoShotCount changes. Stats
// mutators read them by name (GetPropertyText) on the server, where the
// record of a shot is written before its damage: keep the names.
var int IGPlus_DemoShotCount;
var float IGPlus_DemoShotTS;
var int IGPlus_DemoShotView;     // (Pitch << 16) | Yaw
var vector IGPlus_DemoShotOrigin;
var vector IGPlus_DemoShotHit;
var PlayerReplicationInfo IGPlus_DemoShotTarget;
var int IGPlus_DemoShotData;
var vector IGPlus_DemoShotBodyOff;
var int IGPlus_DemoShotBody;
// Playback: this player's server positions by server time.
var float IGPlus_SDHistTime[128];
var vector IGPlus_SDHistLoc[128];
var byte IGPlus_SDHistHidden[128];
var Actor IGPlus_SDHistBase[128];
var vector IGPlus_SDHistRel[128];
var vector IGPlus_SDHistPos[128];   // IGPlus_DemoPos (the camera spot)
var int IGPlus_SDHistView[128];
var float IGPlus_SDHistEye[128];
// Playback: our projectiles, drawn a fixed time behind the server's copy
// (the server spawned them ahead by the ping), so they leave our gun and fly
// at their own speed, as our client showed them. A short path history each.
const IGPLUS_SD_PROJ = 24;
const IGPLUS_SD_PROJEASE = 0.4;
const IGPLUS_SD_PROJHIST = 32;
var Projectile IGPlus_SDProj[24];
var float IGPlus_SDProjStart[24];
var float IGPlus_SDProjDelay[24];
var vector IGPlus_SDProjMuzzle[24];
var int IGPlus_SDProjHead[24];
var int IGPlus_SDProjCount[24];
var float IGPlus_SDProjHT[768];   // slot * 32 + i
var EDrawType IGPlus_SDProjDrawType[24];
var vector IGPlus_SDProjHL[768];
var float IGPlus_SDGlideUpdateTime;
var float IGPlus_SDFollowStart;   // when the viewer started following us
// Playback: the others moved for a pulse beam trace.
var vector IGPlus_SDTraceSaved;
var bool IGPlus_SDTraceMoved;
var int IGPlus_SDHistHead;
var int IGPlus_SDHistCount;
var float IGPlus_SDHistLastTime;
// Playback: drawn somewhere else for one frame (followed player's own move
// timing, or the others where the followed player saw them).
var bool IGPlus_SDDisplaced;
var bool IGPlus_SDHiddenByDisplace;
var bool IGPlus_SDSavedCollideActors;
var bool IGPlus_SDSavedBlockActors;
var bool IGPlus_SDSavedBlockPlayers;
var bool IGPlus_SDSavedCollideWorld;
var vector IGPlus_SDTrueLoc;
var vector IGPlus_SDDisplacedTo;
var Actor IGPlus_SDAttached[8];
var vector IGPlus_SDAttachedLoc[8];
var int IGPlus_SDNumAttached;
var bool IGPlus_SDDisplacedOthers;
var byte IGPlus_SDLastFlashCount;
var Weapon IGPlus_SDFlashWeapon;
var bool IGPlus_SDAmbientSet;
var float IGPlus_SDLastOverlayTime;
var PlayerPawn IGPlus_SDViewer;
var Inventory IGPlus_SDPickupItem[4];       // server: items this player asked to pick up (UTPure.HandlePickupQuery)
var class<Inventory> IGPlus_SDPickupClass[4];
var byte IGPlus_SDPickupTicks[4];          // server ticks left to see the pickup happen, 0 = free slot
var float IGPlus_SDViewerSearchTime;
var IGPlus_DemoClock IGPlus_SDClock;
// IGPlus_Assets repaired our class's broken model before our
// PlayerReplicationInfo arrived: we get it once we know we're not hidden.
var bool IGPlus_MeshRepairPending;
var Mesh IGPlus_MeshRepairOld;
var float IGPlus_SDClockSearchTime;

// ConsoleCommand/INT Reader/Key+Alias Handling
var string zzRemResult;		// Temporary Variable to store ConsoleCommands
var string zzRemCmd;		// The command the server sent.
var bool bRemValid;		// True when valid.

var UTPure zzUTPure;		// The UTPure mutator.

var bool zzbDoScreenshot;	// True when we are about to do screenshot
var bool zzbReportScreenshot;	// True when reporting the screenshot.
var string zzMagicCode;		// The magic code to display.

var string zzPrevClientMessage;	// To log client messages...

var PureLevelBase PureLevel;	// And Level.
var bool bDeterminedLocalPlayer;
var PlayerPawn LocalPlayer;

var TranslocatorTarget zzClientTTarget, TTarget;
var float LastTick, AvgTickDiff;

// Net Updates
var float TimeBetweenNetUpdates;
var bool bForcePacketSplit;
var int PingAverage;
var int PingCurrentAveragingSecond;
var float PingRunningAverage;
var int PingRunningAverageCount;

// Precise Rewind Time (on with WeaponSettings.bEnablePingCompensation): a hitscan
// shot rewinds players to what the shooter's screen showed.
var int IGPlus_PRTServerTick;        // server: counts ticks, sent to our client
var float IGPlus_PRTTickTime[128];   // server: the time of each recent tick (as far back as UTPlusDummy's snapshots)
var int IGPlus_PRTSeenTick;          // client: the newest tick we got
var float IGPlus_PRTSeenAt;          // client: our time when it arrived
var int IGPlus_PRTShownTick;         // client: the update our last frame showed
var float IGPlus_PRTShownAge;        // client: how far past it that frame was
var float IGPlus_PRTShotLead;        // client: added to it for this frame's shot (IGPlus_PRTShotTarget)
var float IGPlus_PRTSeenLead;        // client: the length of the frame the newest update arrived in
var float IGPlus_PRTShownLead;       // client: the same for the update the last frame showed
var float IGPlus_PRTShownTime;       // client: that frame's time
var float IGPlus_PRTNoteTS;          // server: when the last shot's report arrived
var int IGPlus_PRTNoteTick;          // server: our tick count then
var float IGPlus_PRTSeenTime;        // server: the update the shooter's screen showed
var float IGPlus_PRTViewTime;        // server: carried forward to this time
var float IGPlus_PRTLagMs;           // server: now minus ViewTime, real ms
var string IGPlus_PRTReason;         // server: why the report isn't used ("" = used)
var float IGPlus_PRTServerPing;      // server: our own ping measurement (GETPING)
var float IGPlus_PRTPingReadTS;
var float ExtrapolationDelta;
var bool bIs469Server;
var bool bIs469Client;

// Clientside smoothing of position adjustment.
var vector IGPlus_PreAdjustLocation;
var vector IGPlus_AdjustLocationOffset;
var float IGPlus_AdjustLocationAlpha;
var bool IGPlus_AdjustLocationOverride;
// Camera-only correction smoothing (Settings.bCameraCorrectionSmoothing):
// corrections land in the simulation at once, the camera eases after them.
var vector IGPlus_CameraCorrectionOffset;  // camera lag behind the corrected position
var vector IGPlus_CameraCorrectionApplied; // part of it used this frame, after wall clipping
var vector IGPlus_CameraOffsetDrawn;       // the same, kept until the next frame's view (Push-Safe Aim)
var vector IGPlus_LiftExitCamOffset;        // camera lag after leaving a moving lift (always eased)
var vector IGPlus_PushCamOffset;            // camera lag after a push our client couldn't predict (always eased)
var bool IGPlus_CAPPushed;                  // client: a correction since the last replay says a push made it
var float IGPlus_PushEaseTS;                // server: move time of the last push the client couldn't predict
// Own boarding (client): a moving lift we do not ride is moved, for the length of
// one of our own moves, to where the server has it when it runs that move, then put
// back where it is drawn (IGPlus_OBBegin, IGPlus_OBEnd).
var Mover IGPlus_OBLift;                    // moved for the move running now
var vector IGPlus_OBDrawn;                  // where it is drawn
var Actor IGPlus_OBRiders[8];               // what stood on it, put back on it after
var int IGPlus_OBNumRiders;
var Mover IGPlus_OBMovers[64];              // the level's movers, found once
var int IGPlus_OBNumMovers;
var bool IGPlus_OBMoversFound;
var Mover IGPlus_OBLastBase;                // the lift we last rode, and when
var float IGPlus_OBLastBaseTS;
var float IGPlus_LiftExitTS;                // when we last left a moving lift
var bool IGPlus_DbgLiftJump;                // debug: watching for the top of a lift jump
var Actor IGPlus_DbgLastBase;               // debug: base before the last change
var vector IGPlus_OwnLiftShotShift;         // server: a shot leaves from our screen's spot on a lift (TraceShot skips the real lift)
var bool IGPlus_DbgLiftRising;
var float IGPlus_DbgLiftExitZ;
var bool IGPlus_CameraCorrectionSnap;      // a CAP changed our state (respawn etc.): don't ease

// Push-Safe Aim (bEnablePushSafeAim), server side: pushes the client has not
// seen yet (move timeline), and where the client last said it was.
var float IGPlus_PSAPushTS[8];
var vector IGPlus_PSAPushDV[8];
var int IGPlus_PSAPushNext;
var vector IGPlus_PSALastClientLoc;
var float IGPlus_PSALastClientTS;
// Server: for the shot being run, how far the client's own spot was from ours
// when it fired (-1: not known), and which of the two the shot left from
// (IGPlus_PSAShotOrigin). 0 ours, 1 the client's because the two were close,
// 2 the client's after a push it had not seen.
var float IGPlus_ShotOriginGap;
var int IGPlus_ShotOriginFrom;
var int IGPlus_HitStatOriginFar;     // rifle and sniper shots fired while the two were further apart than close
var float IGPlus_HitStatOriginGapMax;

struct ServerMoveParams {
	var vector Location;
	var Actor Base;
	var EPhysics Physics;
	var int TlocCounter;
};
var bool bHaveReceivedServerMove;
var ServerMoveParams LastServerMoveParams;
var int TlocCounter;
var vector TlocPrevLocation;
var int IGPlus_PreAdjustTlocCounter;          // TlocCounter before the first CAP of an update
var ST_TranslocatorTarget IGPlus_TlocHiddenDisc; // disc hidden by a predicted translocation
var float IGPlus_TlocHiddenUntil;
var float IGPlus_TlocHideArrivingUntil; // our local disc was used: hide the server's when it arrives
var float IGPlus_TlocLastPressTS;       // last translocator fire/alt press (move timeline)
var float IGPlus_TlocPredictTS;         // when a predicted translocation used the disc up
var bool IGPlus_DidTranslocate;
var bool IGPlus_NotifiedTranslocate;
// Server: [DET-TLOC] log lines (deterministic translocator disagreements).
var float IGPlus_DetTlocLogWindowTS;
var int IGPlus_DetTlocLogCount;
var int IGPlus_DetLostMoves;          // moves that never arrived (time gaps), this map
var float IGPlus_DetLastLossTS;       // Level.TimeSeconds of the last gap
var bool IGPlus_bDetTlocMismatch;     // translocate counts differ (logged once)
var bool IGPlus_bDetTlocCheckLanding; // compare the client's spot after our translocate
var vector IGPlus_DetClientVel, IGPlus_DetPrevClientVel; // server: the client's velocity after its last two moves
var byte IGPlus_DetClientPhys, IGPlus_DetPrevClientPhys;
var float IGPlus_DetTlocPreVZ, IGPlus_DetTlocPreClientVZ;  // server: fall speeds going into our last translocate
var byte IGPlus_DetTlocPrePhys, IGPlus_DetTlocPreClientPhys;
var string IGPlus_DetTlocInfo;        // the last translocate's disc details
// Server: during a throw's step, where its disc leaves from
// (IGPlus_DetThrowOrigin), and which rule took the client's spot
// (0 none: our own spot, 1 Push-Safe Aim, 2 the 32uu bubble).
var vector IGPlus_DetThrowSpot;
var bool IGPlus_bDetThrowSpot;
var int IGPlus_DetThrowRule;
var string IGPlus_DetThrowGapInfo;    // [DET-TLOC]: how far apart the two discs of the last throw started
// Server: this map's deterministic translocator counts, for one [DET-SUMMARY]
// line when the match ends or the player's pawn goes (IGPlus_DetLogSummary).
var int IGPlus_DetStatThrows, IGPlus_DetStatTlocs;
var int IGPlus_DetStatApart, IGPlus_DetStatAbsorbed; // landings over 8uu apart: corrected, taken by the 16uu bubble
var int IGPlus_DetStatThrowApart, IGPlus_DetStatRejects, IGPlus_DetStatLate;
var int IGPlus_DetStatJumpDropped; // jumps at a landing that only the server took, dropped
var int IGPlus_DetStatLateSpot;    // late throws that left from the thrower's own spot (IGPlus_DetLateSpotTaken)
// Shots the client showed and the server did not fire (refused: the fire
// window was closed, unbound: the server held another weapon), switch
// commands the two sides resolved differently, and seconds with shots held
// by the fire clock margin. The first two together at most one a second.
var int IGPlus_StatShotRefused, IGPlus_StatShotUnbound, IGPlus_StatSwitchMismatch, IGPlus_StatClockHolds;
// Instant hit feedback (NextIG's rifle, NextSA's sniper). The client's own
// trace plays the hit sound and marker at the click, and what it said rides
// the shot's move (DetChargeData). The server's trace still decides the hit,
// and counts how often the two disagree ([DET-SUMMARY], [DET-HIT]).
// Above 7, so never taken for a translocator action.
const IGPLUS_HIT_MISS = 8;
const IGPLUS_HIT_BODY = 9;
const IGPLUS_HIT_HEAD = 10;
// Added to the verdict: the same shot against the bodies as the screen drew
// them said the opposite (IGPlus_ClientShotTrace).
const IGPLUS_HIT_DRAWNDIFF = 4;
var bool IGPlus_bShotDrawnDiffers;  // client: the last trace's. Server: the running move's
var bool IGPlus_bShotHead;          // client: the last trace hit a head
var int IGPlus_HitStatDrawnDiff, IGPlus_HitStatDrawnRight;
var int IGPlus_HitStatDeadShots, IGPlus_HitStatDeadHits;
var int IGPlus_ClientHitVerdict;    // client: the last shot's, until its move takes it. Server: the running move's. 0: none
var float IGPlus_ClientHitPlayedTS; // client: when our own trace last hit a player. 0: none waiting for the server's message
var int IGPlus_HitStatShots, IGPlus_HitStatBoth, IGPlus_HitStatClientOnly, IGPlus_HitStatServerOnly, IGPlus_HitStatHeadDiff;
var int IGPlus_HitStatNoData; // rifle and sniper shots the server ran with no data from the client's shot
// Fire order inside one tick (UTPure.IGPlus_FlushShots). Server: a rifle or
// sniper shot is not traced the moment its move is read. It waits here until
// the tick's packets are all in, with everything its trace takes from us.
var bool IGPlus_bShotPending;
var Weapon IGPlus_PendShotWeapon;
var rotator IGPlus_PendShotView;
var vector IGPlus_PendShotLoc;
var float IGPlus_PendShotAgo;        // how long before now the shot was fired, by our estimate
var float IGPlus_PendShotTS;         // the shot's client time stamp (IGPlus_DetLastShotTS is the newest shot's)
var float IGPlus_SDShotTS;           // server: the same for the shot being traced now. 0: not a waiting shot
var float IGPlus_PendPRTNoteTS, IGPlus_PendPRTSeenTime, IGPlus_PendPRTViewTime, IGPlus_PendPRTLagMs;
var int IGPlus_PendPRTNoteTick;
var string IGPlus_PendPRTReason;
var int IGPlus_PendVerdict, IGPlus_PendEyeByte;
var float IGPlus_PendShotOriginGap;
var int IGPlus_PendShotOriginFrom;
var bool IGPlus_bPendPRTInterp, IGPlus_bPendPRTInterpPast, IGPlus_bPendPRTInterpHeld;
var float IGPlus_PendPRTInterpR;
var int IGPlus_PendPRTInterpSpan;
var bool IGPlus_bPendDrawnDiffers;
var int IGPlus_StatFireShared;       // our shots that waited with another player's shot
var int IGPlus_StatFireMoved;        // of those, the ones that ran in another place than they arrived in
var float IGPlus_PingRing[4];        // the last readings of our own ping measure
var int IGPlus_PingRingAt;
// The eye height a deterministic hitscan shot starts at (ST_SuperShockRifle,
// ST_SniperRifle). Each side works out EyeHeight on its own: the server once
// a tick and never with view shake, the client once a frame. A sniper hit
// drops the client's camera about 15 units for a moment, and the server then
// fired from above the crosshair's line. So the client's eye height rides the
// shot's move in half units, and both sides trace from that one number. The
// server takes it only within IGPLUS_EYE_MAX_DIFF of its own (one step
// height: more than shake and smoothing make, little for a client that lies).
const IGPLUS_EYE_MAX_DIFF = 24.0;
// A deterministic shot that ran within this long after it was due was waited
// for with the button held (IGPlus_DetNextShotTS). Longer than a frame at 20
// frames a second, far shorter than any weapon's interval.
const IGPLUS_DET_CARRY_MAX = 0.06;
var int IGPlus_ShotEyeByte;       // client: the last shot's, until its move takes it. Server: the running move's. 0: none
// Client, Hit Effect Source on Server: the ring that waits for the server's
// hit message (IGPlus_RingHold, IGPlus_RingConfirm).
var PlayerReplicationInfo IGPlus_RingVictimPRI;
var vector IGPlus_RingSourceLoc, IGPlus_RingSourceOffset, IGPlus_RingLoc, IGPlus_RingNormal;
var float IGPlus_RingTS;
const IGPLUS_RING_WAIT = 2.0;     // seconds a ring waits for the server's word
var float IGPlus_ShotEyeDiff;     // server: the client's eye minus ours for the shot being run
var bool IGPlus_bShotEyeRefused;  // server: that shot's eye was too far from ours
var int IGPlus_HitStatEyeUsed, IGPlus_HitStatEyeRefused;
var float IGPlus_HitStatEyeDiffSum, IGPlus_HitStatEyeDiffMax;
var bool IGPlus_bDetStatLogged;
var bool IGPlus_bDetTradeLogged; // dead: this death's Traded! line is written
// Server: the translocate count the move being run carries (the client's,
// after anything it predicted in that move). One ahead of ours when a
// translocate runs: the client made it too, and played its sound
// (ST_Translocator.Translocate).
var int IGPlus_DetMoveTlocCounter;
// Server: our client picked its disc (thrown at DiscTS) up on the move at TS,
// standing at Loc (IGPlus_ServerDetPickedUp). 0: none waiting.
var float IGPlus_DetPickupTS, IGPlus_DetPickupDiscTS;
var vector IGPlus_DetPickupLoc;
// Deterministic translocator actions survive a lost move: the client sends
// its last action again with the next moves until the server is past it.
var int IGPlus_DetRedoAction;         // client: last action (0: none to resend)
var float IGPlus_DetRedoTS;           // client: its move's time stamp
var int IGPlus_DetRedoView;           // client: its move's view (a throw aims with it)
var ST_Translocator IGPlus_DetRedoTloc;
// The action before the last one, while the server may have neither: a throw
// and the translocate after it can both be lost in one burst, and the second
// then took the first one's place here.
var int IGPlus_DetRedo2Action;        // client
var float IGPlus_DetRedo2TS;
var int IGPlus_DetRedo2View;
var float IGPlus_DetRedoMoreTS;       // server: as it came in, for the move that follows (xxServerDetRedoMore)
var int IGPlus_DetRedoMoreData;
// A throw's own move tells the server where the thrower stood, and the
// server's disc leaves from there (IGPlus_DetThrowOrigin). A resent throw
// brings that spot along, or the two discs start apart by as far as the
// thrower moved since the last move the server has.
var vector IGPlus_DetThrowLoc;        // client: where we stood at our last throw
var float IGPlus_DetRedoSpotTS;       // client: the throw it belongs to (0: none on its way)
var vector IGPlus_DetRedoSpot;
var float IGPlus_DetRedoMoreSpotTS;   // server: as it came in, for the move that follows
var vector IGPlus_DetRedoMoreSpot;
var float IGPlus_DetLateSpotTS;       // server: the spot of the move being run, for IGPlus_DetRunAction
var vector IGPlus_DetLateSpot;
// Deterministic translocator without a predicted switch: the server brings
// the translocator up a round trip before we see it. A click in that time
// is for the translocator (on master the server's own bring-up keeps it),
// but our translocator's step is not running yet. We keep it here and the
// step takes it once the weapon is up (ST_Translocator.IGPlus_DetClientStep).
var ST_Translocator IGPlus_DetTlocAsked; // client: the translocator our last switch command asked for
var float IGPlus_DetTlocAskedTS;
var int IGPlus_DetEarlyPress;            // client: 1 fire, 2 alt, pressed while that switch was on its way
var bool IGPlus_bDetEarlyFireWas, IGPlus_bDetEarlyAltWas; // client: the buttons a frame ago
var float IGPlus_DetLastActionSeenTS; // server: newest action handled
// Server: actions from moves we didn't run (paused, warp fix), oldest first.
var int IGPlus_DetHeldCount;
var int IGPlus_DetHeldAction[4];
var float IGPlus_DetHeldTS[4];
var byte IGPlus_DetHeldFlags[4];      // 4: held by the warp fix (else a pause)
var int IGPlus_DetHeldView[4];
// Server: a translocator action held until our switch to the translocator
// finishes (IGPlus_DetNotHeld). 0: none.
var int IGPlus_DetSwitchHeldAction;
var float IGPlus_DetSwitchHeldTS;
var int IGPlus_DetSwitchHeldView;
var bool IGPlus_WantCAP;
var bool IGPlus_SkipMovesUntilNextTick;

// SSR Beam
var float LastWeaponEffectCreated;
var bool bWasPaused;

// EyeHeight related variables
var bool bForceZSmoothing;
var int IgnoreZChangeTicks;
var EPhysics OldPhysics;
var float OldZ;
var float OldShakeVert;
var float OldBaseEyeHeight;
var float EyeHeightOffset;

var bool bEnableSingleButtonDodge;
var input byte bDodge;
var byte bOldDodge;
var bool bPressedDodge;
var transient float LastTimeForward, LastTimeBack, LastTimeLeft, LastTimeRight;
var transient float TurnFractionalPart, LookUpFractionalPart;
var float DuckFraction; // 0 = Not Ducking, 1 = Ducking
const DuckStartTransitionTime = 0.25;// Time to go from non-ducking to ducking
const DuckEndTransitionTime = 0.1; // Time to go from ducking to not-ducking
var byte DuckFractionRepl; // Replicated to all players

var float AverageServerDeltaTime;
var float TimeDead;
var float RealTimeDead;
var bool IGPlus_bDetTradeClosed; // dead: no more trades for the deterministic weapons (IGPlus_DetTradeAllowed)
var vector IGPlus_TradeLoc;      // dead: where we died, the last move we had then and our speed
var float IGPlus_TradeTS;        // before the killing push (IGPlus_TradeShotOrigin)
var float IGPlus_TradeSpeed;
var Pawn LastKiller;
var rotator KillCamTargetRotation;
var float KillCamDelay;
var float KillCamDuration;
var bool bKillCamWanted;
var float RespawnDelay;

var float DodgeSpeedXY;
var float DodgeSpeedZ;
var float SecondaryDodgeSpeedXY;
var float SecondaryDodgeSpeedZ;
var float DodgeEndVelocity;
var float JumpEndVelocity;
var bool bJumpingPreservesMomentum;
var bool bOldLandingMomentum;
var bool bUseFlipAnimation;
var bool bCanWallDodge;
var bool bDodging;
var bool bDodgePreserveZMomentum;
var int MultiDodgesRemaining;

var bool bAppearanceChanged;
var bool bClientDead;

var Object ClientSettingsHelper;
var ClientSettings Settings;

var int IGPlus_FrameCount;

var int BrightskinMode;
var NavigationPoint DelayedNavPoint;

var float IGPlus_TPFix_OffsetZ;
var vector IGPlus_TPFix_Velocity;
var rotator IGPlus_TPFix_Rotation;
var Teleporter IGPlus_TPFix_LastTouched;
var string IGPlus_TPFix_URL;

var int HitMarkerTestDamage;
var int HitMarkerTestTeam;

var IGPlus_ServerMove IGPlus_ServerMove_FreeList;

// Adaptive Buffering (bEnableAdaptiveBuffering), server side: a move queue
// for a player whose packets arrive late or in clumps. See IGPlus_ABIntercept.
// The tuning numbers, all in one place. A slack is a number of the client's
// move intervals plus a number of server ticks. They are first guesses: the
// [JITTER-SUMMARY] line is there to replace them with measured ones.
const IGPLUS_AB_ENTER_FRAMES = 1.0; // a move later than this queues the player
const IGPLUS_AB_ENTER_TICKS = 2.0;
const IGPLUS_AB_LEAVE_FRAMES = 0.5; // lateness under this counts as on time again
const IGPLUS_AB_LEAVE_TICKS = 1.5;
// With Tick Interpolation the other clients draw a player 2 ticks behind
// their newest update and carry them on for 2 more, so a move up to 4 ticks
// late shows as nothing on anyone's screen. Queueing the player for less only
// costs them delay: in a player test on 126 ticks a second, players with good
// lines (moves 5 ms late on average, none over 50) were queued for a third of
// the match, each time for a single move 22 to 26 ms late (IGPlus_ABSlack).
const IGPLUS_AB_ENTER_TICKS_TI = 4.0;
const IGPLUS_AB_LEAVE_TICKS_TI = 3.5;
const IGPLUS_AB_LEAVE_DELAY_TICKS = 1.0; // the queue is left with no more delay than this
const IGPLUS_AB_PEAK_TIME = 4.0;    // seconds until a late packet is mostly forgotten
const IGPLUS_AB_DRAIN = 0.05;       // the clock runs at most this much fast
const IGPLUS_AB_GRACE = 1.5;        // the next move is late after this many move intervals
const IGPLUS_AB_MAXQUEUE = 128;     // moves kept for one player
const IGPLUS_AB_WARMUP = 5.0;        // seconds a new arrival measure runs before it counts
var bool IGPlus_ABPlaying;          // a queued move is running (IGPlus_ABRunHead)
var bool IGPlus_ABKept;             // IGPlus_ABIntercept kept the move it was just shown
var bool IGPlus_ABSeen;             // a state's xxServerMove already showed this move to IGPlus_ABIntercept
var bool IGPlus_ABQueued;           // our moves wait in the queue
var bool IGPlus_ABHeld;             // no move will run for a while: the other clients hold us still (IGPlus_ABHold)
var IGPlus_ServerMove IGPlus_ABHead; // the queue, oldest first
var int IGPlus_ABCount;
var float IGPlus_ABDelay;           // how far the playout clock is behind the client's clock
var float IGPlus_ABClockTime;       // Level.TimeSeconds of the clock's last advance
var float IGPlus_ABLastRun;         // Level.TimeSeconds a queued move last ran
var float IGPlus_ABOverNow;         // time above the cap in the stall going on
var float IGPlus_ABNewestTS;        // newest move that arrived
var float IGPlus_ABMoveLen;         // the client's usual move interval (average move length)
var float IGPlus_ABMeasureStart;    // Level.TimeSeconds the arrival measure (re)started
var float IGPlus_ABPeak;            // usual lateness: the latest packets of the last seconds
var int IGPlus_ABDelayMs;           // IGPlus_ABDelay in real ms, 0 when not queued. Sent to our client.
var float IGPlus_ABLogTS;
var float IGPlus_ABEnterTime;
// The arrival measure. It runs for every player, whatever the setting.
var bool IGPlus_ABHaveMin;
var float IGPlus_ABMinCur;          // lowest (arrival time - timestamp) this second
var float IGPlus_ABMinPrev[3];      // and in the 3 seconds before
var float IGPlus_ABMinBucketEnd;
var float IGPlus_ABWinMin;          // the lowest of those: the client's clock seen from here
var float IGPlus_ABTickMaxTS;       // newest timestamp among this tick's arrivals
var float IGPlus_ABTickLen;         // average server tick (AverageServerDeltaTime starts at 0 and takes seconds to get there)
var float IGPlus_ABLastArrival;     // Level.TimeSeconds of the last move that arrived
var float IGPlus_ABLastArrivalTS;
// This map's numbers for the [JITTER-SUMMARY] line (IGPlus_ABLogSummary).
var bool IGPlus_ABStatLogged;
var int IGPlus_ABStatMoves;
var int IGPlus_ABStatUnder1;
var int IGPlus_ABStatUnder2;
var int IGPlus_ABStatOver50;
// Moves later than the slack that queues a player, the times such a move came
// with none in the 3 seconds before it, and the slack itself added up.
var int IGPlus_ABStatOverSlack, IGPlus_ABStatSlackEvents;
var float IGPlus_ABStatSlackTS, IGPlus_ABStatSlackSum;
var float IGPlus_ABStatLateSum;
var float IGPlus_ABStatLateMax;
var float IGPlus_ABStatTickSum;
var float IGPlus_ABStatTickMax;
var float IGPlus_ABStatGapMax;
var int IGPlus_ABStatGap50;
var int IGPlus_ABStatGap100;
var int IGPlus_ABStatLongMoves;
var int IGPlus_ABStatQueuedMoves;
var int IGPlus_ABStatEnters;
var int IGPlus_ABStatStalls;
var float IGPlus_ABStatQueuedTime;
var float IGPlus_ABStatDelayMax;
var float IGPlus_ABStatOverCap;
var IGPlus_WeaponImplementationBase IGPlus_WImpBase;
	const IGPLUS_DetWEAPON_None = 0;
	const IGPLUS_DetWEAPON_ShockRifle = 1;
	const IGPLUS_DetWEAPON_Ripper = 2;
	const IGPLUS_DetWEAPON_FlakCannon = 3;
	const IGPLUS_DetWEAPON_BioRifle = 4;
	const IGPLUS_DetWEAPON_Eightball = 5;
	const IGPLUS_DetWEAPON_SniperRifle = 6;
	const IGPLUS_DetWEAPON_SuperShockRifle = 7; // wire format caps indices at 7 (3 bits)

	// Predicted self-knockback: what pushed us. Splashes are recomputed from
	// where we are when they land, the hammer's push is direct.
	const IGPLUS_SK_ROCKET = 0;
	const IGPLUS_SK_FLAKSLUG = 1;
	const IGPLUS_SK_SHOCKBALL = 2;
	const IGPLUS_SK_RIPPERALT = 3;
	const IGPLUS_SK_HAMMER = 4;

var Utilities Utils;
var StringUtils StringUtils;
var bbPlayerStatics PlayerStatics;
var Info VersionInfo;

struct IGPlus_ForcedSettings_Entry {
	var int Mode;
	var string Key;
	var string NewValue;
	var string OldValue;
};

var IGPlus_ForcedSettings_Entry IGPlus_ForcedSettings[128];
var int IGPlus_ForcedSettings_Counter;
var int IGPlus_ForcedSettings_Index;
var bool IGPlus_ForcedSettings_Initialized;
var bool IGPlus_ForcedSettings_Applied;
var float IGPlus_ForcedSettings_EnforceAt;

var IGPlus_DamageEvent IGPlus_DamageEvent_First;
var IGPlus_DamageEvent IGPlus_DamageEvent_Latest;
var IGPlus_DamageEvent IGPlus_DamageEvent_FreeList;

// Predicted rocket self-knockback (bEnablePredictedSelfKnockback). An own
// rocket's push lands on the shooter's move timeline at fire step + rocket age,
// at the end of the first move at or past that time, on both machines. The
// server queues real explosions here, the client queues predicted ones.
struct IGPlus_SelfKnockback {
	var float TargetTS;
	var int RocketIndex;
	var vector HitLocation;
	var vector SourceLocation;
	var float SourceRadius;
	var float Radius;
	var float Momentum;
	var bool bEnhanced;
	var bool bHasFallback;
	var vector FallbackPush; // server: what TakeDamage computed at the explosion; hammer: the push
	var byte Kind;           // IGPLUS_SK_*
	var bool bDiscOnly;      // server: only our own disc's push (ours went the stock way)
};
var IGPlus_SelfKnockback IGPlus_SKQueue[16];
var ST_HitTestHelper IGPlus_SKBall; // client: stands in for our own shock ball (IGPlus_SKFly)
var int IGPlus_SKQueueCount;
var bool IGPlus_SKCapturing;
var bool IGPlus_SKComboDisc;        // server: our own combo going off, our disc's push comes after (IGPlus_SKComboOnDisc)
var bool IGPlus_SKCapturedHit;
var vector IGPlus_SKCaptured;
var float IGPlus_DamageEvent_PrevHealth;
var bool IGPlus_DamageEvent_ShowOnDeath;

var float IGPlus_ZoomToggle_RestoreFOV;
var float IGPlus_ZoomToggle_SensitivityFactorX;
var float IGPlus_ZoomToggle_SensitivityFactorY;

var ReplicationInfo IGPlus_AdditionalReplicationInfo;
var bool IGPlus_TryOpenSettingsMenu;
var IGPlus_SettingsDialog IGPlus_SettingsMenu;
var Object IGPlus_ServerSettingsHelper;
var ServerSettings IGPlus_ServerSettingsMenuData;
var bool IGPlus_ServerSettingsMenuLoaded;
var bool IGPlus_ServerSettingsMenuCanEdit;

var Object IGPlus_WeaponSettingsHelper;
var WeaponSettings IGPlus_WeaponSettingsMenuData;
var bool IGPlus_WeaponSettingsMenuLoaded;
// The ini sections this match's server and weapon settings come from, for
// the settings menu's headers.
var string IGPlus_ServerSettingsName;
var string IGPlus_WeaponSettingsName;
var byte IGPlus_WeaponSettingsMode; // 0 every weapon, 1 NextIG, 2 NextSA: what the menu's Weapon tab shows
var bool IGPlus_WeaponSettingsMenuCanEdit;

struct IGPlus_WarpFix {
	var vector OldLocation;
	var int Counter;
	// Adaptive Buffering: the server holds this player still at OldLocation
	// (the move queue ran empty). Other clients stop moving them along at once.
	var bool bHold;
};

struct IGPlus_WarpFixClient {
	var IGPlus_WarpFix Last;
	var float TimeStamp;
};

struct IGPlus_SnapData {
	var vector Location;
	var vector Velocity;
	var rotator Rotation;
	var name AnimSequence;
	var byte AnimFrameByte;
	var byte AnimIntentBits;
	var byte AnimDodgeDir;
	var byte AnimPhysics;
	var vector MoverLocation;
	var int Counter;
	var bool bHardSnap;
	var bool bBasedOnMover;
	var Actor BaseMover;
};

var bool IGPlus_EnableWarpFix;
var bool IGPlus_WarpFixUpdate;
var float IGPlus_WarpFixDelay;
var IGPlus_WarpFix IGPlus_WarpFixData;
var IGPlus_WarpFixClient IGPlus_WarpFixClientData;
var IGPlus_SnapData IGPlus_SnapReplicatedData;
var IGPlus_SnapData IGPlus_SnapReplicatedDataPrev;

const IGPlus_LocationOffsetFix_DummyVel = vect(4.56,4.56,0.0);

var bool IGPlus_LocationOffsetFix_Moved;
var bool IGPlus_LocationOffsetFix_Restored;
var bool IGPlus_LocationOffsetFix_PredCompatMode;
var vector IGPlus_LocationOffsetFix_OldLocation;
var vector IGPlus_LocationOffsetFix_ExtrapolationOffset;
var vector IGPlus_LocationOffsetFix_PredictionOffset;
var vector IGPlus_LocationOffsetFix_Velocity;
var vector IGPlus_LocationOffsetFix_GroundNormal;
var bool IGPlus_LocationOffsetFix_OnGround;
var bool IGPlus_LocationOffsetFix_WasOnMover;
var byte IGPlus_LocationOffsetFix_MoverTransitionFrames;
var bool IGPlus_LocationOffsetFix_FootstepQueued;
var vector IGPlus_LocationOffsetFix_SafeLocation;
var IGPlus_CollisionDummy IGPlus_LocationOffsetFix_CollisionDummy;
var vector IGPlus_LocationOffsetFix_ServerLocation;
var float IGPlus_LocationOffsetFix_ServerLocationTime;
// The velocity that came with that update, and the update before it (what
// the last frame showed while this frame's update is already in).
var vector IGPlus_LocationOffsetFix_ServerVelocity;
var vector IGPlus_LocationOffsetFix_PrevServerLocation;
var vector IGPlus_LocationOffsetFix_PrevServerVelocity;
var float IGPlus_LocationOffsetFix_PrevServerLocationTime;
// The server tick our client knew when each of the two arrived (IGPlus_PRTServerTick).
var int IGPlus_LocationOffsetFix_ServerLocationTick;
var int IGPlus_LocationOffsetFix_PrevServerLocationTick;
// How far the engine had moved the player on already when we noted each of
// the two, as a time. The engine moves a simulated pawn by its velocity for
// the frame's length before the pawn's Tick runs (AActor::Tick). An update
// that brings a velocity is noted one frame's movement past the spot the
// server sent. One without a velocity is not: the parked pawn has next to none.
var float IGPlus_LocationOffsetFix_ServerLocationLead;
var float IGPlus_LocationOffsetFix_PrevServerLocationLead;
// Client, on another player's pawn: moved for our own trace (IGPlus_PRTRulePlace).
var bool IGPlus_bPRTRulePlaced;
// Client, on another player's pawn: where our last frame drew them, and which frame that was (PreRender).
var vector IGPlus_ShownLoc;
var int IGPlus_ShownFrame;
// Client, on another player's pawn: that frame drew them (they were not hidden then).
var bool IGPlus_bShownVisible;
// Client, on another player's pawn: the last frame drew them held still, and where (IGPlus_ApplyWarpFix).
var bool IGPlus_bPRTRuleHeld;
var vector IGPlus_PRTRuleHeldLoc;
var vector IGPlus_PRTRuleSavedLoc;
// What the last placement used, for the shooter's "Own trace" debug line.
var bool IGPlus_bPRTRuleDbgValid, IGPlus_bPRTRuleDbgPrev;
var vector IGPlus_PRTRuleDbgLoc, IGPlus_PRTRuleDbgVel;
var float IGPlus_PRTRuleDbgAge, IGPlus_PRTRuleDbgLead;
var int IGPlus_PRTRuleDbgLag;
var bool IGPlus_LocationOffsetFix_DrawServerLocation;
var Actor IGPlus_LocationOffsetFix_DrawDummy;
var IGPlus_CollisionDummy IGPlus_LocationOffsetFix_DummyList;

var float LocalExtrapolationOwnPingFactor;
var float LocalExtrapolationOtherPingFactor;

var IGPlus_InterpSnapshot IGPlus_SnapInterp_Data[16];
var int   IGPlus_SnapInterp_DataIndex;
var int   IGPlus_SnapInterp_Count;
var float IGPlus_SnapInterp_InterpDelay;
var float IGPlus_SnapInterp_LastArrivalTime;
var float IGPlus_SnapInterp_MeanInterval;
var float IGPlus_SnapInterp_JitterEstimate;
var bool  IGPlus_SnapInterp_NetDebug;
var float IGPlus_SnapInterp_NetDebugNextTime;
var int   IGPlus_SnapInterp_LastCounter;
var byte  IGPlus_SnapInterp_LastInterpMode;
var int   IGPlus_SnapInterp_LastHintAgeMs;
var string IGPlus_SnapInterp_LastHintSource;
var float IGPlus_SnapInterp_ServerNextTime;
var vector IGPlus_SnapInterp_ServerLastLocation;
var float IGPlus_SnapInterp_ServerLastTime;
var bool  IGPlus_SnapInterp_ServerHasLast;
var bool  IGPlus_SnapInterp_EnabledLast;
var int   IGPlus_SnapInterp_StatSnapPackets;
var int   IGPlus_SnapInterp_StatInterp;
var int   IGPlus_SnapInterp_StatExtrap;
var int   IGPlus_SnapInterp_StatClamp;
var int   IGPlus_SnapInterp_StatFail;
var int   IGPlus_SnapInterp_StatHardSnap;
var int   IGPlus_ClientSnapInterpDelayMs;
var int   IGPlus_ClientSnapInterpDelaySampleCount;
var int   IGPlus_ClientSnapInterpDelayMedianMs;
var int   IGPlus_ClientSnapInterpDelaySpreadMs;
var float IGPlus_ServerSnapInterpDelayMsSmoothed;
var bool  IGPlus_ServerSnapInterpDelayValid;
var bool  IGPlus_ServerSnapInterpTrusted;
var float IGPlus_ServerSnapInterpLastAcceptedTime;
var float IGPlus_NextSnapInterpDelayReportTime;
var float IGPlus_NextSnapInterpDelayClientReportTime;
var int   IGPlus_ServerSnapInterpDelayReportedMsEcho;
var int   IGPlus_ServerSnapInterpDelayClampedMsEcho;
var int   IGPlus_ServerSnapInterpDelaySmoothedMsEcho;
var bool  IGPlus_ServerSnapInterpDelayValidEcho;
var bool  IGPlus_ServerSnapInterpTrustedEcho;
var float IGPlus_ServerSnapInterpDelayEchoTime;
var float IGPlus_ServerSnapInterpLastAcceptedTimeEcho;
var bool  IGPlus_SnapInterp_CheckActive;
var float IGPlus_SnapInterp_CheckDuration;
var float IGPlus_SnapInterp_CheckEndTime;
var string IGPlus_SnapInterp_CheckProfile;
var bbPlayer IGPlus_SnapInterp_CheckTarget;
var int   IGPlus_SnapInterp_CheckBaseSnapPackets;
var int   IGPlus_SnapInterp_CheckBaseInterp;
var int   IGPlus_SnapInterp_CheckBaseExtrap;
var int   IGPlus_SnapInterp_CheckBaseClamp;
var int   IGPlus_SnapInterp_CheckBaseFail;
var int   IGPlus_SnapInterp_CheckBaseHardSnap;

var bool IGPlus_AlwaysRenderFlagCarrier;
var bool IGPlus_AlwaysRenderDroppedFlags;
var bool IGPlus_InitFlagSprites;
var IGPlus_FlagSprite IGPlus_TeamFlagSprite[4];

var bool IGPlus_EnableDualButtonSwitch;
var bool IGPlus_UseFastWeaponSwitch;

var bool IGPlus_EnableInputReplication;
var bool IGPlus_EnableSnapshotInterpolation;
// Tick Interpolation (server setting bEnableTickInterpolation). Other players
// are drawn between two real updates, a little in the past, and a shot is
// tested against the exact spot the shooter's screen drew.
var bool IGPlus_EnableTickInterp;    // server: the setting is active. Sent with every pawn.
var byte IGPlus_NetTick;             // server: the low 8 bits of the tick our last move ran in. Sent with every pawn.
// Server: where we stood at the end of that tick. Sent with every pawn, in a
// value of its own: the engine blends a pawn's Location into the client's
// copy (AActor::PostNetReceive, 15% of the way when the pawn is near), so a
// client that gets two updates in one frame never sees the second spot.
// In quarters of a unit (IGPlus_TI_WireLoc): the whole units here, rounded
// down, and the quarters in IGPlus_NetLocFrac.
var vector IGPlus_NetLoc;
var byte IGPlus_NetLocFrac;
var float IGPlus_TI_MoveTS;          // server: the move time that stamp belongs to
// Server: the low 8 bits of that move time in half milliseconds. Sent with
// every pawn. A tick's spot is where our last move ended, and how much move
// time a tick ran varies, so the spots of two ticks are an uneven time apart.
// With this a client knows how far apart (IGPlus_TI_Pace).
var byte IGPlus_NetMoveT;
var int IGPlus_TI_ServerTick;        // server: the number of the current tick. Sent to our own client.
// Client, on our own pawn: the server's tick clock as we see it.
var int IGPlus_TI_SeenTick;          // the newest tick number that arrived
var float IGPlus_TI_SeenAt;          // our time when it arrived
var float IGPlus_TI_TickLen;         // our estimate of one server tick, in our seconds
var int IGPlus_TI_TickLenSkips;      // tick numbers in a row that were not used for it
var float IGPlus_TI_Clock;           // the server tick position now, smoothed
// The same clock on a client whose own download comes late at times
// (xxPlayerTickEvents): it is held behind the newest tick number, so the next
// late update finds the other players still short of their newest spot.
var bool IGPlus_TI_bRecv;            // it is held
var float IGPlus_TI_Recv;            // how many ticks behind the newest tick number, this frame. 0 while it is not held
var float IGPlus_TI_RecvMin;         // the least it was behind in this stretch of IGPLUS_TI_RECV_TIME
var float IGPlus_TI_RecvMinPrev;     // and in the stretch before
var float IGPlus_TI_RecvTop;         // the most in this stretch
var float IGPlus_TI_RecvTopPrev;     // and in the stretch before
var float IGPlus_TI_RecvAt;          // when this stretch began
var float IGPlus_TI_RecvAnim;        // the most of the last two stretches, followed evenly: the other players' animation is shown that much later too
var float IGPlus_PRTShotR;           // the tick position this frame's shot reports (its target's)
var bool IGPlus_bPRTShotPast;        // and whether the target was drawn past its newest update
var bool IGPlus_bPRTShotHeld;        // and whether it stood still there, held by the server
var float IGPlus_PRTShotDelay;       // and how many ticks behind its newest update it was drawn
var int IGPlus_PRTShotSpan;          // and the two updates it was drawn between
// Client, on another player's pawn: its last 16 updates with their tick numbers, oldest first from IGPlus_TI_Head - IGPlus_TI_Num.
// 16 covers the longest delay (IGPLUS_TI_MAX_DELAY) with an update in every tick.
var int IGPlus_TI_Tick[16];
var vector IGPlus_TI_Loc[16];
var vector IGPlus_TI_Vel[16];
var int IGPlus_TI_Head, IGPlus_TI_Num;
var bool IGPlus_TI_bHasByte;
var byte IGPlus_TI_LastByte;
// The move time of each update in seconds, counted on from its first update
// (IGPlus_NetMoveT), and how far the newest update's move time is from an
// even pace, in seconds (IGPlus_TI_Pace).
var float IGPlus_TI_MT[16];
var byte IGPlus_TI_LastMT;
var float IGPlus_TI_Dev;
// The moment this player is drawn at, as a move time (IGPlus_TI_Pace), and
// the two updates and the part of the way between them it fell on this frame.
var float IGPlus_TI_Mu;
var bool IGPlus_TI_bMu;
var int IGPlus_TI_PaceA;
var float IGPlus_TI_PaceAlpha;
var float IGPlus_TI_Gap;             // ticks between its updates, of late
var float IGPlus_TI_Delay;           // how many ticks behind the clock it is drawn
var float IGPlus_TI_DrawnR;          // the tick position it was drawn at this frame
var bool IGPlus_TI_bDrawnPast;       // that was past its newest update: it was carried on or stood still
var float IGPlus_ShownR;             // the same two for the last frame that was drawn (PreRender)
var bool IGPlus_bShownPast;
var int IGPlus_TI_DrawnSpan;         // the two updates it was drawn between this frame (IGPlus_TI_Span)
var int IGPlus_ShownSpan;            // and in the last frame that was drawn
var bool IGPlus_TI_bDrawnHeld;       // drawn past its newest update while the server holds it still: not carried on
var bool IGPlus_bShownHeld;
var bool IGPlus_TI_bStopped;         // the body stands still this frame: held, or the carry has run out
// The crouch that came with each update, and the one that goes with the tick
// position drawn: the older update's, as the server takes the older snapshot's.
var byte IGPlus_TI_Duck[16];
var byte IGPlus_TI_DrawnDuck;
var byte IGPlus_ShownDuck;
// The animation as the engine plays it (the newest the server sent), noted
// frame by frame, so the body's animation is drawn from the same moment as its spot.
var name IGPlus_TI_AnimSeqH[64];
var float IGPlus_TI_AnimFrameH[64];
var float IGPlus_TI_AnimTimeH[64];
var float IGPlus_TI_AnimTweenH[64];  // the blend rate that went with it (IGPlus_FlipFix_Apply)
var int IGPlus_TI_AnimHead, IGPlus_TI_AnimNum;
var name IGPlus_TI_RawSeq, IGPlus_TI_ShownSeq;
var float IGPlus_TI_RawFrame, IGPlus_TI_ShownFrame, IGPlus_TI_ShownTween;
var bool IGPlus_TI_bAnimSwapped;
// Client, on a pawn that may be drawn (client setting FlipAnimationFix, IGPlus_FlipFix_Apply):
// how much of the pose the engine last drew is a turned-over one (1 all of
// it, 0 none), the animation shown last frame, and the flip that plays on or
// the blend that takes over from it.
var float IGPlus_FlipFix_Flipped;
var name IGPlus_FlipFix_Seq;
var float IGPlus_FlipFix_Last, IGPlus_FlipFix_Time;
var name IGPlus_FlipFix_BlendSeq;         // the blend the game is in
var float IGPlus_FlipFix_BlendFirst;      // and the frame it started with
var byte IGPlus_FlipFix_State;            // 1: the flip plays on. 2: the game's blend takes over
var float IGPlus_FlipFix_FlipFrame, IGPlus_FlipFix_FlipRate, IGPlus_FlipFix_Ramp;
var float IGPlus_FlipFix_FlipAt, IGPlus_FlipFix_FlipTime; // the flip frame shown last, and when
var bool IGPlus_FlipFix_bLogged;
// The part of the Flip animation the model is turned over in. Measured on
// the stock male model (20 frames): 50 degrees off upright at frame 3, 170 at
// frame 12, 59 at frame 18. A dodge on level ground lands at frames 15 to 17.
const IGPLUS_FLIPFIX_FLIP_FROM = 0.15;
const IGPLUS_FLIPFIX_FLIP_TO = 0.92;
const IGPLUS_FLIPFIX_FLIP_END = 0.95;     // the flip's last frame
const IGPLUS_FLIPFIX_MIN_FLIPPED = 0.2;   // how much of the drawn pose has to be a turned-over one
const IGPLUS_FLIPFIX_MIN_BLEND = 0.25;    // seconds a blend has to have left
const IGPLUS_FLIPFIX_FLIP_MEMORY = 0.2; // seconds a flip counts as just shown
const IGPLUS_FLIPFIX_RAMP_TIME = 0.06;    // seconds: how fast the blend that takes over catches up
// Client, with enableDebugData on: how Tick Interpolation drew this player
// since the last "Tick Interpolation:" line (IGPlus_TI_Stat, IGPlus_TI_LogStats).
var int IGPlus_TI_StFrames, IGPlus_TI_StPast, IGPlus_TI_StStopped, IGPlus_TI_StHeld;
var int IGPlus_TI_StUpdates, IGPlus_TI_StResets, IGPlus_TI_StBack1, IGPlus_TI_StBack3;
var float IGPlus_TI_StDelaySum, IGPlus_TI_StDelayMax, IGPlus_TI_StGapMax, IGPlus_TI_StBackMax;
var float IGPlus_TI_StDevMax;        // the furthest an update's move time was off the even pace, in seconds
var vector IGPlus_TI_StPrevLoc, IGPlus_TI_StPrevStep;
var float IGPlus_TI_StPrevTime, IGPlus_TI_StPrevDt;
var bool IGPlus_TI_StHavePrev;
// On our own pawn: clock jumps since the last line, and when the next line is due.
var int IGPlus_TI_StClockSnaps;
// enableDebugData: projectiles this client drew from the gun because the
// server sent them flown ahead (IGPlus_Glide), and of those, flak chunks it
// got only as a replay (IGPlus_SkippedPath). One line every 30 seconds.
var int IGPlus_SkipGlides, IGPlus_SkipReplays;
var float IGPlus_SkipNextLine;
var float IGPlus_TI_StNextLine, IGPlus_TI_StSince;
// And how far the clock was held behind the newest tick number, in ticks: summed over the frames, and the most.
var int IGPlus_TI_StRecvFrames;
var float IGPlus_TI_StRecvSum, IGPlus_TI_StRecvMax;
var int IGPlus_TI_StFreezes;         // and times our download stopped for longer than a hold covers (IGPLUS_TI_RECV_FREEZE)
// Server: the last report was a tick position (IGPlus_PRTNoteInterp).
var bool IGPlus_bPRTInterp, IGPlus_bPRTInterpPast, IGPlus_bPRTInterpHeld;
var float IGPlus_PRTInterpR;
var int IGPlus_PRTInterpSpan;        // and the two updates the target was drawn between (IGPlus_TI_Span)
// Server: how far behind their newest update the shooter's screen drew the
// player they aimed at, from the same report. New projectiles of theirs are
// moved ahead by this as well (IGPlus_WeaponImplementationBase.IGPlus_GetTickInterpDelayMs).
var float IGPlus_PRTInterpDelayMs;
const IGPLUS_TI_EXTRA = 1.0;         // ticks of delay on top of the gap between a player's updates
const IGPLUS_TI_MIN_DELAY = 2.0;
const IGPLUS_TI_MAX_DELAY = 10.0;
const IGPLUS_TI_MAX_CARRY = 2.0;     // ticks a player is carried on past their newest update
const IGPLUS_TI_MT_UNIT = 0.0005;    // seconds in one step of IGPlus_NetMoveT
const IGPLUS_TI_MT_WRAP = 0.128;     // seconds until IGPlus_NetMoveT comes round again
const IGPLUS_REWIND_TI_EXTRA_MS = 100.0; // most of the drawing delay that goes on top of PingCompensationMax (IGPlus_RewindExtraMs)
const IGPLUS_TI_PACE_RATE = 0.05;    // how fast the even pace follows a player's updates, per update
const IGPLUS_TI_MU_TIME = 0.5;       // seconds: the drawn moment is 63% of the way to the asked one after this
const IGPLUS_TI_MU_SLEW = 0.03;      // and it runs at most this much faster or slower than real time on the way
const IGPLUS_TI_MU_SLEW_FAR = 0.15;  // or this much: when it is over a tick off, has to fall back, or runs low
const IGPLUS_TI_MU_TIME_BACK = 0.1;  // seconds for falling back
const IGPLUS_TI_MU_RESERVE = 0.75;   // ticks before the newest update under which it runs slower
const IGPLUS_TI_MU_SNAP = 5.0;       // ticks behind at which it is set at once
const IGPLUS_TI_MU_LEAD = 2.5;       // ticks past the newest update it goes at most (the carry ends at IGPLUS_TI_MAX_CARRY)
const IGPLUS_TI_RECV_SNAP = 5.0;     // ticks the tick clock is off the newest tick number at which a hold starts
const IGPLUS_TI_RECV_LATE = 2.0;     // ticks early or late over which a tick number is not used to measure how long a tick is
const IGPLUS_TI_RECV_FAR = 60.0;     // ticks off at which it is set at once, with no hold
const IGPLUS_TI_RECV_MAX = 8.0;      // ticks it is held behind the newest tick number at most
const IGPLUS_TI_RECV_GIVE = 0.03;    // how much faster than real time it runs while it gives a hold back
const IGPLUS_TI_RECV_TIME = 10.0;    // seconds in a stretch: a hold stays for as long as one of the last two needed it
const IGPLUS_TI_RECV_LEAVE = 3.0;    // ticks: after a stretch that never had more than this in hand the hold is over
const IGPLUS_TI_RECV_FREEZE = 13.0;  // ticks off (IGPLUS_TI_RECV_MAX plus IGPLUS_TI_RECV_SNAP) at which it is a freeze of our download: set at once, no hold
var bool IGPlus_PressedJumpSave;
var IGPlus_SavedInputChain IGPlus_SavedInputChain;
var IGPlus_DataBuffer IGPlus_InputReplicationBuffer;
var float IGPlus_LastInputSendTime;
var float MinDodgeClickTime;
var IGPlus_InputLogFile IGPlus_InputLogFile;
var IGPlus_DebugLogFile IGPlus_DebugLogFile; // client: debug lines to a file while enableDebugData is on
var bool bTraceInput;

var IGPlus_NetStats NetStatsElem;

struct ReplBuffer {
	var int Data[20];
};

var string IGPlus_LogoVersionText;

// rX Added

var float FRandValues[47];
var int FRandValuesIndex;
var int FRandValuesLength;

struct ClientWeaponSettings {
	var bool bBioUseClientSideAnimations;
	var bool bShockBeamUseClientSideAnimations;
	var bool bShockProjectileUseClientSideAnimations;
	var bool bPredictiveShockCombos;
	var bool bPulseUseClientSideAnimations;
	var bool bRipperUseClientSideAnimations;
	var bool bFlakUseClientSideAnimations;
	var bool bRocketUseClientSideAnimations;
	var bool bSniperUseClientSideAnimations;
	var bool bTranslocatorUseClientSideAnimations;
	// Predictions the player turned off (ClientSettings.bPredicted*). Negated,
	// so the server's copy allows them until the client's arrives.
	var bool bNoPredictedSwitching;
	var bool bNoPredictedTranslocation;
	var bool bNoPredictedDiscBoost;
	// ClientSettings.bReduceEyeHeightInAir: the server fires from the same lowered eye
	var bool bReduceEyeHeightInAir;
};

var ClientWeaponSettings ClientWeaponSettingsData;

var int ShowDamageNumberMode;

replication
{
// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Variables Server -> Client
	unreliable if ( bNetOwner && Role == ROLE_Authority )
		bCanWallDodge,
		bDodgePreserveZMomentum,
		bEnableSingleButtonDodge,
		bIs469Server,
		bJumpingPreservesMomentum,
		bOldLandingMomentum,
		BrightskinMode,
		bUseFlipAnimation,
		HUDInfo,
		IGPlus_AlwaysRenderDroppedFlags,
		IGPlus_AlwaysRenderFlagCarrier,
		IGPlus_ServerSettingsName,
		IGPlus_WeaponSettingsName,
		IGPlus_WeaponSettingsMode,
		IGPlus_EnableInputReplication,
		IGPlus_EnableWarpFix,
		IGPlus_WarpFixDelay,
		IGPlus_UseFastWeaponSwitch,
		IGPlus_PredictedSwitching,
		IGPlus_PredictedTranslocation,
		IGPlus_PredictedSelfKnockback,
		IGPlus_PushSafeAim,
		IGPlus_DetTranslocator,
		IGPlus_PredictedDiscBoost,
		IGPlus_PRTServerTick,
		IGPlus_DetServerShotTS,
		IGPlus_TI_ServerTick,
		IGPlus_ABDelayMs,
		KillCamDelay,
		KillCamDuration,
		LastKiller,
		RespawnDelay,
		TimeBetweenNetUpdates,
		zzbForceDemo,
		IGPlus_AutoDebugData,
		zzbGameStarted,
		zzbForceModels,
		zzbIsWarmingUp,
		zzCVDelay,
		zzCVDeny,
		zzMaximumNetspeed,
		zzMinimumNetspeed,
		zzTrackFOV,
		zzWaitTime,
		IGPlus_ServerSnapInterpDelayReportedMsEcho,
			IGPlus_ServerSnapInterpDelayClampedMsEcho,
			IGPlus_ServerSnapInterpDelaySmoothedMsEcho,
			IGPlus_ServerSnapInterpDelayValidEcho,
			IGPlus_ServerSnapInterpTrustedEcho,
			IGPlus_ServerSnapInterpDelayEchoTime,
			IGPlus_ServerSnapInterpLastAcceptedTimeEcho,
			ShowDamageNumberMode;

	unreliable if ( Role == ROLE_Authority )
		DuckFractionRepl,
		IGPlus_AdditionalReplicationInfo,
		IGPlus_WarpFixData,
		IGPlus_EnableSnapshotInterpolation,
		IGPlus_EnableTickInterp,
		IGPlus_NetTick,
		IGPlus_NetLoc,
		IGPlus_NetLocFrac,
		IGPlus_NetMoveT,
		IGPlus_SnapReplicatedData,
		IGPlus_SnapReplicatedDataPrev;

	unreliable if ( bDrawDebugData && RemoteRole == ROLE_AutonomousProxy )
		clientForcedPosition,
		clientLastUpdateTime,
		debugClientForceUpdate,
		debugClientLocError,
		debugNumOfForcedUpdates,
		debugServerMoveCallsReceived,
		ExtrapolationDelta;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Variables Client -> Server
	unreliable if ( Role == ROLE_AutonomousProxy )
		bDrawDebugData,
		bIsFinishedLoading,
		IGPlus_DamageEvent_ShowOnDeath,
		IGPlus_EnableDualButtonSwitch,
		IGPlus_ClientSnapInterpDelayMs,
		IGPlus_ClientSnapInterpDelaySampleCount,
		IGPlus_ClientSnapInterpDelaySpreadMs,
		PingAverage,
		IGPlus_ClientFOV,
		IGPlus_ClientZoomed,
		zzbDemoRecording,
		zzNetspeed,
		ClientWeaponSettingsData;

	unreliable if (Role == ROLE_AutonomousProxy || RemoteRole <= ROLE_SimulatedProxy)
		bIs469Client;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Variables Client -> Demo
	unreliable if (bClientDemoRecording)
		IGPlus_LocationOffsetFix_ServerLocation;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Variables Server -> Server Demo (a server only sets bDemoRecording for its
// demo recording, so live clients and client demos never get these)
	unreliable if (bDemoRecording && !bClientDemoRecording && Role == ROLE_Authority)
		IGPlus_DemoPos,
		IGPlus_DemoRawOff,
		IGPlus_DemoEye,
		IGPlus_DemoOthersDelayMs,
		IGPlus_DemoFlags,
		IGPlus_DemoFOV,
		IGPlus_DemoZoomed,
		IGPlus_DemoWeaponAmbient,
		IGPlus_DemoRawView,
		IGPlus_DemoRawTS;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Functions Server -> Client
	reliable if ( Role == ROLE_Authority )
		IGPlusMenu,
		Ready,
		xxClientSwJumpPad,
		xxSetDefaultWeapon,
		xxSetPendingWeapon,
		xxClientDetEntryGate,
		xxSetTimes,
		FRandValues,
		FRandValuesIndex;

	reliable if ( RemoteRole == ROLE_AutonomousProxy && !bDemoRecording )
		xxCheatFound,
		xxClientDoEndShot,
		xxClientDoScreenshot;

	// Not in server demos: these are simulated, so playback would run them
	// again on every recorded player (a local kicker per player, predicted
	// switch state on proxies). Client demos keep them.
	reliable if (Role == ROLE_Authority && (!bDemoRecording || bClientDemoRecording))
		xxClientKicker,
		xxClientSwitchPending,
		xxClientPSReject,
		xxClientPSResume,
		xxClientPSTimes,
		xxClientPSFilterDone,
		xxClientPSSpawn;

	reliable if ((Role == ROLE_Authority) && !bDemoRecording)
		xxNN_ClientProjExplode;

	// Server demos only: one record of a WeaponEffect (rocket scorch marks),
	// and copies of the messages and chat this player got (stock
	// ReceiveLocalizedMessage, ClientMessage and TeamMessage are kept out of
	// server demos).
	reliable if (bDemoRecording && !bClientDemoRecording && Role == ROLE_Authority)
		IGPlus_DemoLocalizedMessage,
		IGPlus_DemoClientMessage,
		IGPlus_DemoTeamMessage,
		IGPlus_DemoWeaponEffect,
		IGPlus_DemoShot;

	reliable if (RemoteRole == ROLE_AutonomousProxy)
		IGPlus_ForcedSettingsInit,
		IGPlus_ForcedSettingRegister,
		IGPlus_ForcedSettingsApply,
		IGPlus_ServerSettingsInit,
		IGPlus_ServerSettingsSet,
		IGPlus_ServerSettingsDone,
		IGPlus_WeaponSettingsInit,
		IGPlus_WeaponSettingsSet,
		IGPlus_WeaponSettingsDone,
		IGPlus_ClientEightballAmmoRefund,
		IGPlus_ClientReStart,
		IGPlus_NotifyPlayerRestart;

	unreliable if (RemoteRole == ROLE_AutonomousProxy)
		xxCAP,
		xxCAPLevelBase,
		xxCAPWalking,
		xxCAPWalkingWalking,
		xxCAPWalkingWalkingLevelBase,
		xxClientResetPlayer,
		xxFakeCAP;

	unreliable if (bDrawDebugData && RemoteRole == ROLE_AutonomousProxy)
		ClientDebugMessage;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Functions Client -> Server
	unreliable if ( Role < ROLE_Authority )
		ServerApplyInput,
		xxServerCheater,
		xxServerMove,
		xxServerMoveDead,
		xxServerDetRedoMore;

	reliable if ( Role < ROLE_Authority )
		xxServerWeaponCommand,
		xxServerPredictedSwitch,
		xxServerPSCommand,
		IGPlus_ServerDetDiscSync,
		IGPlus_ServerDetPickedUp,
		DropFlag,
		Go,
		Hold,
		ServerSetTraceInput,
		IGPlus_ForcedSettingsRetry,
		IGPlus_ForcedSettingsOK,
		IGPlus_ForcedSettings_InitOK,
		PrintWeaponState,
		IGPlus_ServerNetcodeHelp,
		IGPlus_ServerSetNetcodeSetting,
		IGPlus_ServerRequestSettings,
		IGPlus_WeaponRequestSettings,
		ServerSetDodgeSettings,
		xxExplodeOther,
		xxNN_AltFire,
		xxNN_Fire,
		xxSendDeathMessageToSpecs,
		xxSendHeadshotToSpecs,
		xxSendMultiKillToSpecs,
		xxSendSpreeToSpecs,
		xxServerAckScreenshot,
		xxServerDemoReply,
		xxServerSetForceModels,
		xxServerSetReadyToPlay,
		xxServerSetTeamInfo,
		xxSetNetUpdateRate;

	reliable if ((Role < ROLE_Authority) && !bClientDemoRecording)
		xxNN_ProjExplode,
		xxNN_ReleaseAltFire,
		xxNN_ReleaseFire;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Functions Client -> Demo
	// Client->Demo
	unreliable if ( bClientDemoRecording )
		ClientDemoMessage,
		xxClientLogToDemo,
		xxReplicateVRToDemo;

	reliable if (bClientDemoRecording && !bClientDemoNetFunc)
		xxClientDemoFix,
		IGPlus_DemoCopyBegin,
		IGPlus_DemoCopyEnd,
		IGPlus_DemoCopySound;
	unreliable if (bClientDemoRecording && !bClientDemoNetFunc)
		IGPlus_DemoCopyMove;

	reliable if ( (!bDemoRecording || (bClientDemoRecording && bClientDemoNetFunc) || (Level.NetMode==NM_Standalone)) && Role == ROLE_Authority )
		ReceiveWeaponEffect;
	reliable if (bClientDemoRecording)
		DemoReceiveWeaponEffect;
}

static final operator(34) int or_eq (out int A, int B) {
	A = A | B;
	return A;
}

static final operator(34) int and_eq (out int A, int B) {
	A = A & B;
	return A;
}

function ReceiveWeaponEffect(
	class<WeaponEffect> Effect,
	PlayerReplicationInfo SourcePRI,
	vector SourceLocation,
	vector SourceOffset,
	Actor Target,
	vector TargetLocation,
	vector TargetOffset,
	vector HitNormal
) {
	Effect.static.Play(
		self,
		Settings,
		SourcePRI,
		SourceLocation,
		SourceOffset,
		Target,
		TargetLocation,
		TargetOffset,
		Normal(HitNormal / 32767)
	);
}

simulated function DemoReceiveWeaponEffect(
	class<WeaponEffect> Effect,
	PlayerReplicationInfo SourcePRI,
	vector SourceLocation,
	vector SourceOffset,
	Actor Target,
	vector TargetLocation,
	vector TargetOffset,
	vector HitNormal
) {
	if (LastWeaponEffectCreated >= 0) return;
	Effect.static.Play(
		self,
		Settings,
		SourcePRI,
		SourceLocation,
		SourceOffset,
		Target,
		TargetLocation,
		TargetOffset,
		Normal(HitNormal / 32767)
	);
}

function SendWeaponEffect(
	class<WeaponEffect> Effect,
	PlayerReplicationInfo SourcePRI,
	vector SourceLocation,
	vector SourceOffset,
	Actor Target,
	vector TargetLocation,
	vector TargetOffset,
	vector HitNormal
) {
	ReceiveWeaponEffect(
		Effect,
		SourcePRI,
		SourceLocation,
		SourceOffset,
		Target,
		TargetLocation,
		TargetOffset,
		HitNormal * 32767
	);

	LastWeaponEffectCreated = Level.TimeSeconds;
	DemoReceiveWeaponEffect(
		Effect,
		SourcePRI,
		SourceLocation,
		SourceOffset,
		Target,
		TargetLocation,
		TargetOffset,
		HitNormal * 32767
	);
}

/* More crash fix bs */
simulated function bool xxGarbageLocation(actor Other)
{
	return (InStr(Caps(string(Other.Location.X)), "N") > -1 ||
		InStr(Caps(string(Other.Location.Y)), "N") > -1 ||
		InStr(Caps(string(Other.Location.Z)), "N") > -1);
}

exec function Fly()
{
	zzForceUpdateUntil = Level.TimeSeconds + 0.5;
	zzbForceUpdate = true;
	Super.Fly();
}

exec function Ghost()
{
	zzForceUpdateUntil = Level.TimeSeconds + 0.5;
	zzbForceUpdate = true;
	Super.Ghost();
}

simulated event Destroyed() {
	// Server demo playback: our projectiles back on their real spots.
	if (Role == ROLE_SimulatedProxy)
		IGPlus_SDEndAllGlides();
	if (Role == ROLE_Authority && zzUTPure != none) {
		zzUTPure.ModifyLogout(self);
	}
	if (Role == ROLE_Authority && IGPlus_NextTrans != none)
		IGPlus_NextTrans.Destroy();
	if ((Level.NetMode == NM_Client && Role == ROLE_AutonomousProxy) || Role == ROLE_Authority) {
		IGPlus_ForcedSettingsRestore();
	}
	if (Role == ROLE_SimulatedProxy && IGPlus_LocationOffsetFix_CollisionDummy != none) {
		IGPlus_LocationOffsetFix_DestroyCollisionDummy();
	}
	if (Role == ROLE_SimulatedProxy)
		IGPlus_SnapInterp_Reset();

	if (bTraceInput && IGPlus_InputLogFile != none)
		IGPlus_InputLogFile.StopLog();
	if (IGPlus_DebugLogFile != none)
		IGPlus_DebugLogFile.Destroy();
	if (IGPlus_SKBall != none)
		IGPlus_SKBall.Destroy();
	if (Role == ROLE_Authority)
		IGPlus_DetLogSummary();
	IGPlus_ABDropQueue();
	super.Destroyed();
}

// Return true to override Teleporter
simulated event bool PreTeleport(Teleporter T) {
	local vector D;
	D = Location - T.Location;
	if (Region.Zone.IsA('TeleporterZone') == false &&
		(
			VSize(D * vect(1,1,0)) > CollisionRadius + T.CollisionRadius ||
			Abs(D.Z) > CollisionHeight + T.CollisionHeight
		)
	) {
		// Were not touching the teleporter just yet.
		// Do nothing and
		return true;
	}

	if (T.URL != "") {
		IGPlus_TPFix_OffsetZ = Location.Z - T.Location.Z;
		IGPlus_TPFix_Velocity = Velocity;
		IGPlus_TPFix_Rotation = Rotation;
		IGPlus_TPFix_LastTouched = T;
		IGPlus_TPFix_URL = T.URL;
		bForcePacketSplit = true;
	}
	return false;
}

simulated function Touch( actor Other )
{
	if(Level.NetMode != NM_Client)
	{
		if (zzUTPure.Settings.ShowTouchedPackage)
		{
			ClientMessage(StringUtils.PackageOfObject(Other));
		}

		if ((Other.IsA('Kicker') && Other.Class.Name != 'NN_Kicker')) {
			ClientDebugMessage("Touch forced updates");
			zzForceUpdateUntil = Level.TimeSeconds + 0.15 + float(Other.GetPropertyText("ToggleTime"));
			zzbForceUpdate = true;
		} else if (Other.IsA('JumpPadDM')) {
			ClientDebugMessage("Touch forced updates");
			zzForceUpdateUntil = Level.TimeSeconds + 0.0011*PlayerReplicationInfo.Ping*Level.TimeDilation;
		}
	}
	if (Other.IsA('Kicker') || Other.IsA('NN_swJumpPad'))
		bForcePacketSplit = true;
	if (Other.IsA('Teleporter'))
		IgnoreZChangeTicks = 2;
	Super.Touch(Other);
}


simulated function bool xxNewSetLocation(vector NewLoc, vector NewVel)
{
	if (!SetLocation(NewLoc))
		return false;
	Velocity = NewVel;
	return true;
}

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

simulated final function IGPlus_WeaponImplementationBase IGPlus_GetWeaponImplementationBase() {
	if (IGPlus_WImpBase != none && !IGPlus_WImpBase.bDeleteMe)
		return IGPlus_WImpBase;

	foreach AllActors(class'IGPlus_WeaponImplementationBase', IGPlus_WImpBase)
		return IGPlus_WImpBase;

	return none;
}

simulated function xxClientKicker(
	float KCollisionRadius,
	float KCollisionHeight,
	vector KLocation,
	int KRotationYaw,
	int KRotationPitch,
	int KRotationRoll,
	name KTag,
	name KEvent,
	float KKickVelocityX,
	float KKickVelocityY,
	float KKickVelocityZ,
	name KKickedClasses,
	bool KbKillVelocity,
	bool KbRandomize
) {
	local Kicker K;
	local AttachMover AM;
	local rotator KRotation;
	local vector KKickVelocity;

	if(Level.NetMode != NM_Client)
		return;

	KRotation.Yaw = KRotationYaw;
	KRotation.Pitch = KRotationPitch;
	KRotation.Roll = KRotationRoll;
	KKickVelocity.X = KKickVelocityX;
	KKickVelocity.Y = KKickVelocityY;
	KKickVelocity.Z = KKickVelocityZ;

	K = Spawn(class'NN_Kicker', Self, , KLocation, KRotation);
	K.SetCollisionSize(KCollisionRadius, KCollisionHeight);
	K.Tag = KTag;
	K.Event = KEvent;
	K.KickVelocity = KKickVelocity;
	K.KickedClasses = KKickedClasses;
	K.bKillVelocity = KbKillVelocity;
	K.bRandomize = KbRandomize;

	if(K.Tag != '')
		foreach AllActors(class'AttachMover', AM)
			if(AM.AttachTag == K.Tag) {
				K.SetBase(AM);
				break;
			}
}

function xxClientSwJumpPad(
	name TTag,
	name TEvent,
	vector TLocation,
	vector TRotation,
	vector TCollJA,
	string TURL,
	int MiscData,
	vector MiscData2,
	vector TTargetRand,
	string JumpEffect,
	string JumpPlayerEffect,
	string JumpEvent,
	string JumpSound,
	vector TargetLocation,
	vector TargetCollision
) {
	local NN_swJumpPad J;
	local AttachMover AM;
	local rotator TRot;
	local NN_swJumpPad_DestinationDummy Target;

	if (Level.NetMode != NM_Client)
		return;

	TRot.Pitch = int(TRotation.X) & 0xFFFF;
	TRot.Yaw = int(TRotation.Y) & 0xFFFF;
	TRot.Roll = int(TRotation.Z) & 0xFFFF;
	J = Spawn(class'NN_swJumpPad', Self, TTag, TLocation, TRot);
	J.SetCollisionSize(TCollJA.X / 10.0, TCollJA.Y / 10.0);
	J.Event = TEvent;
	J.URL = TURL;
	J.JumpAngle = TCollJA.Z / 256.0;
	J.TeamNumber = MiscData & 0xFF;
	J.bTeamOnly = (MiscData & 0x100) != 0;
	J.TargetZOffset = MiscData2.X;
	J.TargetRand = TTargetRand;
	J.bTraceGround = (MiscData & 0x200) != 0;
	J.bDisabled = (MiscData & 0x400) != 0;
	J.AngleRand = MiscData2.Y / 256.0;
	J.SetPropertyText("AngleRandMode", string((MiscData >> 12) & 3));
	J.SetPropertyText("JumpEffect", JumpEffect);
	J.SetPropertyText("JumpPlayerEffect", JumpPlayerEffect);
	J.SetPropertyText("JumpEvent", JumpEvent);
	J.SetPropertyText("JumpSound", JumpSound);
	J.bClientSideEffects = false;
	J.JumpWait = MiscData2.Z / 50.0;

	Target = Spawn(class'NN_swJumpPad_DestinationDummy', self,, TargetLocation);
	Target.SetCollisionSize(TargetCollision.X*0.1, TargetCollision.Y*0.1);
	J.JumpTarget = Target;

	if(J.Tag != '')
		foreach AllActors(class'AttachMover', AM)
			if(AM.AttachTag == J.Tag) {
				J.SetBase(AM);
				break;
			}
}

function vector ParseVector(string s) {
	local vector V;

	s = Mid(s, InStr(s, "=")+1, Len(s));
	V.X = float(s);
	s = Mid(s, InStr(s, "=")+1, Len(s));
	V.Y = float(s);
	s = Mid(s, InStr(s, "=")+1, Len(s));
	V.Z = float(s);

	return V;
}

function ReplicateSwJumpPad(Teleporter T) {
	local vector RotV;
	local vector CollJA;
	local int MiscData;
	local vector MiscData2;
	local Actor Target;
	local vector TargetCollision;

	RotV.X = T.Rotation.Pitch << 16 >> 16;
	RotV.Y = T.Rotation.Yaw << 16 >> 16;
	RotV.Z = T.Rotation.Roll << 16 >> 16;

	CollJA.X = T.CollisionRadius * 10;
	CollJA.Y = T.CollisionHeight * 10;

	CollJA.Z = float(T.GetPropertyText("JumpAngle")) * 256;

	MiscData = MiscData | (int(T.GetPropertyText("TeamNumber")) & 0xFF);
	if (T.GetPropertyText("bTeamOnly") ~= "true")
		MiscData = MiscData | 0x100;
	if (T.GetPropertyText("bTraceGround") ~= "true")
		MiscData = MiscData | 0x200;
	if (T.GetPropertyText("bDisabled") ~= "true")
		MiscData = MiscData | 0x400;
	if (T.GetPropertyText("bClientSideEffects") ~= "true")
		MiscData = MiscData | 0x800;
	MiscData = MiscData | (int(T.GetPropertyText("AngleRandMode")) << 12);

	MiscData2.X = float(T.GetPropertyText("TargetZOffset"));
	MiscData2.Y = float(T.GetPropertyText("AngleRand")) * 256.0;
	MiscData2.Z = float(T.GetPropertyText("JumpWait")) * 50.0;

	foreach AllActors(class'Actor', Target)
		if (string(Target.Tag) ~= T.URL && Target != T)
			break;

	if (Target != none && string(Target.Tag) ~= T.URL && Target != T) {}
	else {
		// invalid target for swJumpPad
		return;
	}

	TargetCollision.X = Target.CollisionRadius*10;
	TargetCollision.Y = Target.CollisionHeight*10;

	xxClientSwJumpPad(
		T.Tag,
		T.Event,
		T.Location,
		RotV,
		CollJA,
		T.URL,
		MiscData,
		MiscData2,
		ParseVector(T.GetPropertyText("TargetRand")),
		T.GetPropertyText("JumpEffect"),
		T.GetPropertyText("JumpPlayerEffect"),
		T.GetPropertyText("JumpEvent"),
		T.GetPropertyText("JumpSound"),
		Target.Location,
		TargetCollision
	);
}

function float GetFRandValues(int Index)
{
	return FRandValues[Index];
}

simulated function InitSettings() {
	local bbPlayer P;
	local bbCHSpectator S;

	// Assets references the engine may have loaded broken (IGPlus_Assets).
	if (Level.NetMode != NM_DedicatedServer)
		class'IGPlus_Assets'.static.RepairDefaults(self);

	if (Settings != none) return;

	foreach AllActors(class'bbPlayer', P)
		if (P.Settings != none) {
			Settings = P.Settings;
			break;
		}

	foreach AllActors(class'bbCHSpectator', S)
		if (S.Settings != none) {
			Settings = S.Settings;
			break;
		}

	if (Settings == none) {
		ClientSettingsHelper = new(none, StringUtils.StringToName(VersionInfo.GetPropertyText("PackageBaseName"))) class'Object'; // object name = INI file name
		Settings = new(ClientSettingsHelper, 'ClientSettings') class'ClientSettings'; // object name = Section name
		Settings.CheckConfig();
	}
}

event PostBeginPlay()
{
	local int TickRate;
	local class<Info> VersionInfoClass;
	local int i;

	local bbBaseCylinder BaseCyl; // Variable for the base cylinder
	local bbBaseCylinderReduced BaseCylReduced; // Variable for the base cylinder
	local bbHeadCylinder HeadCyl; // Variable for the head cylinder

	for (i = 0; i < FRandValuesLength; i++)
		FRandValues[i] = FRand();

	Super.PostBeginPlay();

	Utils = new(none) class'Utilities';
	StringUtils = class'StringUtils'.static.Instance();
	PlayerStatics = Spawn(class'bbPlayerStatics');
	VersionInfoClass = class<Info>(DynamicLoadObject(StringUtils.GetPackage()$".VersionInfo", class'class', true));
	VersionInfo = Spawn(VersionInfoClass);
	IGPlus_SavedInputChain = Spawn(class'IGPlus_SavedInputChain');
	IGPlus_InputReplicationBuffer = new(XLevel) class'IGPlus_DataBuffer';

	InitSettings();

	if (zzUTPure.Settings.bEnableHitboxDebugMode)
	{
		ConsoleCommand("mlmode 0"); // disable mlmode to prevent culling of triangles due to distance

		BaseCyl = Spawn(class'bbBaseCylinder', self);

		if (BaseCyl != none)
				BaseCyl.PawnRef = self;

		BaseCylReduced = Spawn(class'bbBaseCylinderReduced', self);

		if (BaseCylReduced != none)
				BaseCylReduced.PawnRef = self;

		HeadCyl = Spawn(class'bbHeadCylinder', self);

		if (HeadCyl != none)
				HeadCyl.PawnRef = self;
	}

	if ( Level.NetMode != NM_Client )
	{
		zzMinimumNetspeed = zzUTPure.Settings.MinClientRate;
		zzMaximumNetspeed = zzUTPure.Settings.MaxClientRate;
		zzWaitTime = 5.0;
	}

	TickRate = int(ConsoleCommand("get ini:Engine.Engine.NetworkDevice NetServerMaxTickRate"));
	TickRate = ++TickRate / 2;
	while(TickRate > 0) {
		if (OldestMI == none) {
			OldestMI = new(none) class'bbOldMovementInfo';
			NewestMI = OldestMI;
		} else {
			NewestMI.Next = new(none) class'bbOldMovementInfo';
			NewestMI = NewestMI.Next;
		}
		NewestMI.Save(self);
		TickRate--;
	}
}

// called after PostBeginPlay on net client
simulated event PostNetBeginPlay()
{
	local class<Info> VersionInfoClass;

	Utils = new(none) class'Utilities';
	StringUtils = class'StringUtils'.static.Instance();
	PlayerStatics = Spawn(class'bbPlayerStatics');
	VersionInfoClass = class<Info>(DynamicLoadObject(StringUtils.GetPackage()$".VersionInfo", class'class', true));
	VersionInfo = Spawn(VersionInfoClass);
	IGPlus_SavedInputChain = Spawn(class'IGPlus_SavedInputChain');
	IGPlus_InputReplicationBuffer = new(XLevel) class'IGPlus_DataBuffer';

	InitSettings();

	ClientWeaponSettingsData.bBioUseClientSideAnimations = Settings.bBioUseClientSideAnimations;
	ClientWeaponSettingsData.bShockBeamUseClientSideAnimations = Settings.bShockBeamUseClientSideAnimations;
	ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations = Settings.bShockProjectileUseClientSideAnimations;
	ClientWeaponSettingsData.bPredictiveShockCombos = Settings.bPredictiveShockCombos;
	ClientWeaponSettingsData.bPulseUseClientSideAnimations = Settings.bPulseUseClientSideAnimations;
	ClientWeaponSettingsData.bRipperUseClientSideAnimations = Settings.bRipperUseClientSideAnimations;
	ClientWeaponSettingsData.bFlakUseClientSideAnimations = Settings.bFlakUseClientSideAnimations;
	ClientWeaponSettingsData.bRocketUseClientSideAnimations = Settings.bRocketUseClientSideAnimations;
	ClientWeaponSettingsData.bSniperUseClientSideAnimations = Settings.bSniperUseClientSideAnimations;
	ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations = Settings.bTranslocatorUseClientSideAnimations;
	ClientWeaponSettingsData.bNoPredictedSwitching = !Settings.bPredictedSwitching;
	ClientWeaponSettingsData.bNoPredictedTranslocation = !Settings.bPredictedTranslocation;
	ClientWeaponSettingsData.bNoPredictedDiscBoost = !Settings.bPredictedDiscBoost;
	ClientWeaponSettingsData.bReduceEyeHeightInAir = Settings.bReduceEyeHeightInAir;

	if ( Role != ROLE_SimulatedProxy )	// Other players are Simulated, local player is Autonomous or Authority (if listen server which pure doesn't support anyway :P)
	{
		return;
	}

	if ( bIsMultiSkinned )
	{
		if ( MultiSkins[1] == None )
		{
			if ( bIsPlayer && PlayerReplicationInfo != None)
				SetMultiSkin(self, "","", PlayerReplicationInfo.team);
			else
				SetMultiSkin(self, "","", 0);
		}
	}
	else if ( Skin == None )
		Skin = Default.Skin;


	if ( (PlayerReplicationInfo != None)
		&& (PlayerReplicationInfo.Owner == None) )
		PlayerReplicationInfo.SetOwner(self);
}

static function SetMultiSkin(Actor SkinActor, string SkinName, string FaceName, byte TeamNum) {
	local PlayerPawn P;
	local bbPlayerReplicationInfo bbPRI;
	P = PlayerPawn(SkinActor);
	if (P != none) {
		bbPRI = bbPlayerReplicationInfo(P.PlayerReplicationInfo);
		if (P.Role == ROLE_Authority && bbPRI != none) {

			bbPRI.SkinName = SkinName;
			bbPRI.FaceName = FaceName;
		}
	}
	super.SetMultiSkin(SkinActor, SkinName, FaceName, TeamNum);
}

function ServerSetDodgeSettings(float MaxTime, float MinTime) {
	DodgeClickTime = MaxTime;
	MinDodgeClickTime = MinTime;
}

event Possess()
{
	local class<Info> VersionInfoClass;
	local Kicker K;

	Utils = new(none) class'Utilities';
	StringUtils = class'StringUtils'.static.Instance();
	PlayerStatics = Spawn(class'bbPlayerStatics');
	VersionInfoClass = class<Info>(DynamicLoadObject(StringUtils.GetPackage()$".VersionInfo", class'class', true));
	VersionInfo = Spawn(VersionInfoClass);

	InitSettings();

	if ( Level.Netmode == NM_Client )
	{	// Only do this for clients.
		SetTimer(3, false);
		Log("Possessed PlayerPawn (bbPlayer) by InstaGib Plus");
		SetNetUpdateRate(Settings.DesiredNetUpdateRate);
		xxServerSetForceModels(Settings.bForceModels);
		xxServerSetTeamInfo(Settings.bTeamInfo);
		ServerSetDodgeSettings(DodgeClickTime, Settings.MinDodgeClickTime);
		if (class'UTPlayerClientWindow'.default.PlayerSetupClass != class'UTPureSetupScrollClient')
			class'UTPlayerClientWindow'.default.PlayerSetupClass = class'UTPureSetupScrollClient';
		// This blocks silly set commands by kicking player, after resetting them.
		if (	Class'ZoneInfo'.Default.AmbientBrightness != 0		||
			Class'ZoneInfo'.Default.AmbientSaturation != 255	||
			Class'LevelInfo'.Default.AmbientBrightness != 0		||
			Class'LevelInfo'.Default.AmbientSaturation != 255	||
			Class'WaterZone'.Default.AmbientBrightness != 0		||
			Class'WaterZone'.Default.AmbientSaturation != 255)
		{
			Class'ZoneInfo'.Default.AmbientBrightness = 0;
			Class'ZoneInfo'.Default.AmbientSaturation = 255;
			Class'LevelInfo'.Default.AmbientBrightness = 0;
			Class'LevelInfo'.Default.AmbientSaturation = 255;
			Class'WaterZone'.Default.AmbientBrightness = 0;
			Class'WaterZone'.Default.AmbientSaturation = 255;
			xxServerCheater(chr(90)$chr(68));		// ZD
		}
		if (	Class'WaterTexture'.Default.bInvisible		||
			Class'Actor'.Default.Fatness != 128		||
			Class'PlayerShadow'.Default.DrawScale != 0.5	||
			Class'PlayerShadow'.Default.Texture != Texture'Botpack.EnergyMark')
		{
			Class'WaterTexture'.Default.bInvisible = False;
			Class'Actor'.Default.Fatness = 128;
			Class'PlayerShadow'.Default.DrawScale = 0.5;
			Class'PlayerShadow'.Default.Texture = Texture'Botpack.EnergyMark';
			xxServerCheater(chr(90)$chr(69));		// ZE
		}
		// The following doesnt work
		//SetPropertyText("PureLevel", "\""$GetPropertyText("xLevel")$"\"");
		// it was intended to maybe support ][ in map names
		// it does not. As a result, AutoDemo does not work on maps with ][ in
		// their name.
		SetPropertyText("PureLevel", GetPropertyText("xLevel"));
		IGPlus_DamageEvent_ShowOnDeath = Settings.bShowDeathReport;
		ClientSetMusic( Level.Song, Level.SongSection, Level.CdTrack, MTRAN_Fade );

		bIs469Client = int(Level.EngineVersion) >= 469;
	}
	else
	{
		BrightskinMode = zzUTPure.Settings.BrightskinMode;

		xxSetDefaultWeapon(Level.Game.BaseMutator.MutatedDefaultWeapon().name);

		GameReplicationInfo.RemainingTime = DeathMatchPlus(Level.Game).RemainingTime;
		GameReplicationInfo.ElapsedTime = DeathMatchPlus(Level.Game).ElapsedTime;
		xxSetTimes(GameReplicationInfo.RemainingTime, GameReplicationInfo.ElapsedTime);

		KillCamDelay = FMax(0.0, zzUTPure.Settings.KillCamDelay);
		KillCamDuration = zzUTPure.Settings.KillCamDuration;
		bJumpingPreservesMomentum = zzUTPure.Settings.bJumpingPreservesMomentum;
		bOldLandingMomentum = zzUTPure.Settings.bOldLandingMomentum;
		bEnableSingleButtonDodge = zzUTPure.Settings.bEnableSingleButtonDodge;
		bUseFlipAnimation = zzUTPure.Settings.bUseFlipAnimation;
		bCanWallDodge = zzUTPure.Settings.bEnableWallDodging;
		bDodgePreserveZMomentum = zzUTPure.Settings.bDodgePreserveZMomentum;
		bAlwaysRelevant = zzUTPure.Settings.bPlayersAlwaysRelevant;
		IGPlus_EnableWarpFix = zzUTPure.Settings.bEnableWarpFix;
		IGPlus_WarpFixDelay = zzUTPure.Settings.WarpFixDelay;
		IGPlus_AlwaysRenderFlagCarrier = zzUTPure.Settings.bAlwaysRenderFlagCarrier;
		IGPlus_AlwaysRenderDroppedFlags = zzUTPure.Settings.bAlwaysRenderDroppedFlags;
		IGPlus_UseFastWeaponSwitch = zzUTPure.Settings.bUseFastWeaponSwitch;
		IGPlus_PredictedSwitching = zzUTPure.Settings.PredictedSwitchingActive();
		IGPlus_PredictedTranslocation = zzUTPure.Settings.PredictedTranslocationActive();
		IGPlus_PredictedSelfKnockback = zzUTPure.Settings.PredictedSelfKnockbackActive();
		IGPlus_PushSafeAim = zzUTPure.Settings.PushSafeAimActive();
		IGPlus_DetTranslocator = zzUTPure.Settings.DeterministicTranslocatorActive();
		IGPlus_PredictedDiscBoost = zzUTPure.Settings.bEnablePredictedDiscBoost;
		IGPlus_EnableInputReplication = zzUTPure.Settings.bEnableInputReplication;
		IGPlus_ServerSettingsName = string(zzUTPure.Settings.Name);
		IGPlus_WeaponSettingsName = zzUTPure.IGPlus_WeaponSettingsName();
		IGPlus_WeaponSettingsMode = zzUTPure.IGPlus_WeaponSettingsMode();
		IGPlus_EnableSnapshotInterpolation = zzUTPure.Settings.SnapshotInterpolationActive();
		IGPlus_EnableTickInterp = zzUTPure.Settings.TickInterpolationActive();

		ShowDamageNumberMode = zzUTPure.IGPlus_DamageNumberMode();

		if(!zzUTPure.bExludeKickers)
		{
			ForEach AllActors(class'Kicker', K)
			{
				if (K.Class.Name != 'Kicker')
					continue;

				xxClientKicker(
					K.CollisionRadius, K.CollisionHeight,
					K.Location,
					K.Rotation.Yaw, K.Rotation.Pitch, K.Rotation.Roll,
					K.Tag, K.Event,
					K.KickVelocity.X, K.KickVelocity.Y, K.KickVelocity.Z,
					K.KickedClasses,
					K.bKillVelocity,
					K.bRandomize
				);
			}

			DelayedNavPoint = Level.NavigationPointList;
		}

		bIs469Server = int(Level.EngineVersion) >= 469;
		if (RemoteRole != ROLE_AutonomousProxy) {
			bIs469Client = bIs469Server;
			IGPlus_DamageEvent_ShowOnDeath = Settings.bShowDeathReport;
		}

		IGPlus_ForcedSettingsInit();
		ClientMessage("Sending ForcedSettingsInit");
	}

	if (Role == ROLE_AutonomousProxy || (Role == ROLE_Authority && RemoteRole != ROLE_AutonomousProxy)) {
		IGPlus_EnableDualButtonSwitch = IGPlus_DetermineDualButtonSwitchSetting();
	}

	class'ClientSuperShockBeam'.static.Cleanup();

	IGPlus_InputLogFile = Spawn(class'IGPlus_InputLogFile');
	IGPlus_InputLogFile.PlayerRef = self;
	if (Level.NetMode == NM_Client)
		IGPlus_InputLogFile.LogId = "ClientInput";
	else
		IGPlus_InputLogFile.LogId = "ServerInput"$"_"$PlayerReplicationInfo.PlayerId;
	if (bTraceInput)
		IGPlus_InputLogFile.StartLog();

	if (Level.NetMode != NM_DedicatedServer) {
		NetStatsElem = Spawn(class'IGPlus_NetStats');
		IGPlus_LogoVersionText = IGPlus_DetermineLogoVersionText();
	}

	Super.Possess();
}

function string IGPlus_DetermineLogoVersionText() {
	return VersionInfo.GetPropertyText("PackageBaseName")@VersionInfo.GetPropertyText("PackageVersion");
}

function bool IGPlus_DetermineDualButtonSwitchSetting() {
	local Translocator T;
	local bool Result;
	
	T = Spawn(class'Translocator');
	if (T == none)
		return true;

	T.RemoteRole = ROLE_None;
	T.bHidden = true;

	Result = true;
	if (T.GetPropertyText("bEnableDualButtonSwitch") ~= "False")
		Result = false;
	
	T.Destroy();

	return Result;
}

function IGPlus_ForcedSettingsInit() {
	IGPlus_ForcedSettings_Counter = 0;
	ClientMessage("Forced Settings initialized", 'IGPlus');
	IGPlus_ForcedSettings_InitOK();
}

function IGPlus_ForcedSettings_InitOK() {
	IGPlus_ForcedSettings_Initialized = true;
}

function IGPlus_ForcedSettingRegister(string Key, string Value, int Mode) {
	IGPlus_ForcedSettings[IGPlus_ForcedSettings_Counter].Mode = Mode;
	IGPlus_ForcedSettings[IGPlus_ForcedSettings_Counter].Key = Key;
	IGPlus_ForcedSettings[IGPlus_ForcedSettings_Counter].NewValue = Value;
	IGPlus_ForcedSettings_Counter++;
	ClientMessage("Forcing ("$Mode$")"@Key$"="$Value, 'IGPlus');
}

function IGPlus_ForcedSettingRestore(int Index) {
	local string Key;
	local bool bValue;

	switch(IGPlus_ForcedSettings[Index].Mode) {
	case 0:
		// dont restore
		break;
	case 1:
		Settings.SetPropertyText(IGPlus_ForcedSettings[Index].Key, IGPlus_ForcedSettings[Index].OldValue);
		Key = IGPlus_ForcedSettings[Index].Key;
		bValue = (IGPlus_ForcedSettings[Index].OldValue ~= "True");

		// Call helper function to update replicated ClientWeaponSettingsData
		UpdateReplicatedWeaponSetting(Key, bValue);
		break;
	case 2:
		// dick move ...
		break;
	}
}

function IGPlus_ForcedSettingsRestore() {
	local int i;
	for (i = 0; i < IGPlus_ForcedSettings_Counter; ++i) {
		IGPlus_ForcedSettingRestore(i);
	}
}

function IGPlus_ForcedSettingApply(int Index) {
	local string Key;
	local bool bValue;
	
	IGPlus_ForcedSettings[Index].OldValue = Settings.GetPropertyText(IGPlus_ForcedSettings[Index].Key);
	switch(IGPlus_ForcedSettings[Index].Mode) {
	case 0:
		if (Settings.bInitialized) break;
	case 1:
	case 2:
		Settings.SetPropertyText(IGPlus_ForcedSettings[Index].Key, IGPlus_ForcedSettings[Index].NewValue);
		break;
	}

	Key = IGPlus_ForcedSettings[Index].Key;
	bValue = (IGPlus_ForcedSettings[Index].NewValue ~= "True"); // Convert string "True"/"False" to bool

	// Call helper function to update replicated ClientWeaponSettingsData
	UpdateReplicatedWeaponSetting(Key, bValue);
}

function IGPlus_ForcedSettingsApply(int Counter) {
	local int i;
	local bool bInitialized;

	if (IGPlus_ForcedSettings_Counter != Counter) {
		IGPlus_ForcedSettingsRetry();
		return;
	}

	bInitialized = Settings.bInitialized;
	Settings.bInitialized = true;
	Settings.SaveConfig();
	Settings.bInitialized = bInitialized;

	for (i = 0; i < IGPlus_ForcedSettings_Counter; ++i) {
		IGPlus_ForcedSettingApply(i);
	}
	Settings.bInitialized = true;
	IGPlus_ForcedSettings_Applied = true;

	IGPlus_ForcedSettingsOK();
}

function IGPlus_ForcedSettingsRetry() {
	IGPlus_ForcedSettings_Index = 0;
	IGPlus_ForcedSettings_Counter = 0;
	ClientMessage("Retrying Forced Settings ...", 'IGPlus');
	IGPlus_ForcedSettingsInit();
}

function IGPlus_ForcedSettingsOK() {
	IGPlus_ForcedSettings_Applied = true;
	ClientMessage("Forced Settings applied!", 'IGPlus');
}

// Mode 1 and 2 lock the setting while connected; mode 0 is only a default.
function bool IGPlus_IsForcedSetting(string Key) {
	local int i;

	for (i = 0; i < IGPlus_ForcedSettings_Counter; ++i)
		if ((IGPlus_ForcedSettings[i].Mode == 1 || IGPlus_ForcedSettings[i].Mode == 2)
			&& IGPlus_ForcedSettings[i].Key ~= Key)
			return true;
	return false;
}

// Puts the forced values back after a console 'set' or anything else that
// changed them. OldValue is left alone, so leaving still restores the
// player's own value.
function IGPlus_ForcedSettingsEnforce() {
	local int i;
	local string Old;

	if (IGPlus_ForcedSettings_Applied == false)
		return;
	for (i = 0; i < IGPlus_ForcedSettings_Counter; ++i)
		if (IGPlus_ForcedSettings[i].Mode == 1 || IGPlus_ForcedSettings[i].Mode == 2) {
			Old = Settings.GetPropertyText(IGPlus_ForcedSettings[i].Key);
			Settings.SetPropertyText(IGPlus_ForcedSettings[i].Key, IGPlus_ForcedSettings[i].NewValue);
			// Only when it actually put a value back (a console 'set'), so no spam.
			if (Settings.GetPropertyText(IGPlus_ForcedSettings[i].Key) != Old)
				ClientMessage("Cannot change" @ IGPlus_ForcedSettings[i].Key $ ": Setting is forced by the server to '" $ IGPlus_ForcedSettings[i].NewValue $ "'.", 'IGPlus');
		}
}

// Console commands: refuse a setting the server locks (mode 1 or 2).
function bool IGPlus_RefuseForced(string Key, string Name) {
	local int i;

	for (i = 0; i < IGPlus_ForcedSettings_Counter; ++i)
		if ((IGPlus_ForcedSettings[i].Mode == 1 || IGPlus_ForcedSettings[i].Mode == 2)
			&& IGPlus_ForcedSettings[i].Key ~= Key) {
			ClientMessage("Cannot change" @ Name $ ": Setting is forced by the server to '" $ IGPlus_ForcedSettings[i].NewValue $ "'.", 'IGPlus');
			return true;
		}
	return false;
}

function IGPlus_SaveSettings() {
	local int i;

	if (IGPlus_ForcedSettings_Applied) {
		IGPlus_ForcedSettingsRestore();
	}

	Settings.SaveConfig();

	if (IGPlus_ForcedSettings_Applied) {
		for (i = 0; i < IGPlus_ForcedSettings_Counter; ++i) {
			IGPlus_ForcedSettingApply(i);
		}
	}
}

function Timer() {

	if (bReason == 1) {
		bReason = 0;
		reconnectClient();
		return;
	}

	if (bIsFinishedLoading == false) {
		bIsFinishedLoading = true;
		ClientMessage("[IG+] To view available commands type 'mutate playerhelp' in the console");
		ClientMessage("[IG+] Server Using Ping Compensation: " $ GetWeaponSettings().bEnablePingCompensation);
		if (GetWeaponSettings().bEnablePingCompensation) {
			ClientMessage("[IG+] For Ping Compensation Settings type 'mutate PingCompSettings' in the console");
		}
	}
}

function ClientSetLocation( vector zzNewLocation, rotator zzNewRotation )
{
	local IGPlus_SavedMove M;
	local int Pitch;

	zzNewRotation.Roll = 0;
	Pitch = Clamp(Utils.RotU2S(zzNewRotation.Pitch), -16384, 16383);
	zzNewRotation.Pitch = Utils.RotS2U(Pitch);
	ViewRotation = zzNewRotation;
	zzNewRotation.Pitch = Utils.RotS2U(Clamp(Pitch, -RotationRate.Pitch, RotationRate.Pitch));
	SetRotation( zzNewRotation );
	SetLocation( zzNewLocation );

	// Clean up moves
	if (PendingMove != none) {
		PendingMove.NextMove = FreeMoves;
		IGPlus_SavedMove(PendingMove).Clear2();
		FreeMoves = PendingMove;
		PendingMove = none;
	}

	while(SavedMoves != none) {
		M = IGPlus_SavedMove(SavedMoves);
		SavedMoves = M.NextMove;
		M.NextMove = FreeMoves;
		M.Clear2();
		FreeMoves = M;
	}
}

// Server, on death: a fresh translocator of the kind we hold, owned by us but
// outside the inventory chain, so it reaches our client during the respawn
// delay. A respawn's translocator heads the chain, and a held weapon that
// isn't the current one replicates at most 4 times a second (469
// AInventory::UpdateFrequency): the client knew none of its new weapons for
// up to 0.25s and its switch presses went to the server, a round trip late.
function IGPlus_PrepareNextTrans() {
	local Inventory Inv;
	local int Guard;

	if (RemoteRole != ROLE_AutonomousProxy || IGPlus_NextTrans != none)
		return;
	for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
		Guard++;
		if (Translocator(Inv) != none)
			break;
	}
	if (Inv == none)
		return;
	IGPlus_NextTrans = Spawn(class<Weapon>(Inv.Class), self);
	if (IGPlus_NextTrans == none)
		return;
	IGPlus_NextTrans.Instigator = self;
	IGPlus_NextTrans.BecomeItem();
	IGPlus_NextTrans.GotoState('');
	// Its timers wait for the respawn, as fresh as the game's would be.
	IGPlus_NextTrans.Disable('Tick');
}

// Server, right after the respawn handed out our weapons: the game's new
// translocator (added last, so the head of the chain) gives way to the one
// our client already has. Anything else at the head (no translocator this
// life, another kind, the spawn weapon itself) keeps the game's.
function IGPlus_UseNextTrans() {
	local Weapon N, T;

	N = IGPlus_NextTrans;
	IGPlus_NextTrans = none;
	if (N == none || N.bDeleteMe)
		return;
	T = Weapon(Inventory);
	if (T == none || T.Class != N.Class || T == Weapon) {
		N.Destroy();
		return;
	}
	N.bHeldItem = T.bHeldItem;
	N.RespawnTime = T.RespawnTime;
	N.PickupAmmoCount = T.PickupAmmoCount;
	N.Tag = T.Tag;
	N.Event = T.Event;
	if (PendingWeapon == T)
		PendingWeapon = N; // the stock auto-switch to it (WeaponSet)
	T.Destroy(); // spawned this tick: never sent to anyone
	AddInventory(N);
	N.GiveAmmo(self);
	N.SetSwitchPriority(self);
	N.Enable('Tick');
}

// Server: stock puts a new item at the head of the chain, linked to the
// previous head. A held item that isn't the current weapon reaches our client
// at most 4 times a second, and a link to an item the client doesn't have yet
// arrives as none (469 holds back only our own Inventory link). A weapon pickup
// adds the weapon, then its new ammo linked to it: when the ammo arrived first,
// our client's chain ended at the ammo for up to another 0.25s, so it knew none
// of its other weapons and every switch key went to the server. New ammo added
// while the head is that new goes to the end instead, where the link was none
// anyway. Everything else keeps stock order: weapons, and armor, whose ties
// (body armor and thigh pads) absorb in chain order.
// ponytail: 0.5s is a guess at "not on the client yet", and an item picked up
// within 0.5s of another still links to it. Move it behind the new items if
// that shows up in logs.
function bool AddInventory(Inventory NewItem) {
	local Inventory Inv, Last;
	local int Guard;

	if (NewItem == none || Ammo(NewItem) == none || Inventory == none
		|| Level.NetMode == NM_Client || Level.TimeSeconds - IGPlus_InvHeadAddTS > 0.5
	) {
		if (!Super.AddInventory(NewItem))
			return false;
		IGPlus_InvHeadAddTS = Level.TimeSeconds;
		return true;
	}
	for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
		Guard++;
		if (Inv == NewItem)
			return false;
		Last = Inv;
	}
	NewItem.SetOwner(self);
	NewItem.Inventory = none;
	Last.Inventory = NewItem;
	return true;
}

function IGPlus_ClientReStart(EPhysics phys, vector NewLocation, rotator NewRotation, optional bool bNoEffect) {
	ClientSetLocation(NewLocation, NewRotation);
	ClientReStart();
	SetPhysics(phys);

	SetFOVAngle(135);
	if (bNoEffect == false)
		IGPlus_NotifyPlayerRestart(NewLocation, NewRotation, self);
}

// At match start, DeathMatchPlus.StartMatch takes us out of CountdownDying,
// whose EndState restarts us, then calls RestartPlayer and moves us to a new
// start. Only that second start may show a spawn effect, or the light and
// sound play where nobody is. In standalone RestartPlayer returns without
// moving us (bRestartLevel), so the first restart keeps its effect there.
function bool IGPlus_RestartedAgainByStartMatch() {
	local DeathMatchPlus DMP;

	DMP = DeathMatchPlus(Level.Game);
	return DMP != none && DMP.bStartMatch
		&& (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || DMP.bRestartLevel == false);
}

// Stock's "has one already" test (DeathMatchPlus.AddDefaultInventory and
// GiveWeapon) asks for the stock class, and we hold IG+'s subclass of it
// (ST_Translocator for Translocator, ST_enforcer for Enforcer). The second
// restart at match start doesn't clear our weapons, so it gave us a second
// translocator and a second Enforcer for the first life. While StartMatch
// runs, a held subclass counts. The exact class still comes first.
function Inventory FindInventoryType(class DesiredClass) {
	local Inventory Inv;
	local int Guard;

	Inv = Super.FindInventoryType(DesiredClass);
	if (Inv != none || IGPlus_RestartedAgainByStartMatch() == false || ClassIsChildOf(DesiredClass, class'Weapon') == false)
		return Inv;
	for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
		Guard++;
		if (ClassIsChildOf(Inv.Class, DesiredClass))
			return Inv;
	}
	return none;
}

// Notification of other player respawning, play effects locally
function IGPlus_NotifyPlayerRestart(vector Loc, rotator Dir, bbPlayer Other) {
	local UTTeleportEffect PTE;

	PTE = Spawn(class'UTTeleportEffect', self, , Loc, Dir);
	if (Level.bHighDetailMode == false) {
		PTE.bOwnerNoSee = (Other == self);
		PTE.Disable('Tick');
	}
	PTE.Initialize(Other, true);
	PTE.PlaySound(sound'Resp2A',, 10.0);
	PTE.RemoteRole = ROLE_None;

	// dont show light if you cant see the effect
	if (FastTrace(PTE.Location) == false)
		PTE.LightType = LT_None;
}

function IGPlus_SendRespawnNoficiation() {
	local bbPlayer P;
	local bbCHSpectator S;

	foreach AllActors(class'bbPlayer', P)
		if (P != self)
			P.IGPlus_NotifyPlayerRestart(Location, Rotation, self);

	foreach AllActors(class'bbCHSpectator', S)
		S.IGPlus_NotifyPlayerRestart(Location, Rotation, self);
}

// The countdown at match start. TournamentPlayer replicates TimeMessage to
// the player's client, and its condition lets the engine write it into a
// server demo as well. In playback the recorded player is a simulated proxy,
// which runs only simulated functions, so stock code drops the call there.
// Every player carries the same countdown, so one of them shows it to the
// viewer: the player the viewer follows, else the first recorded player.
simulated function TimeMessage(int Num) {
	local PlayerPawn V;
	local bbPlayer P, Shower;

	if (IGPlus_SDIsServerDemoProxy() == false) {
		Super.TimeMessage(Num);
		return;
	}
	V = IGPlus_SDGetViewer();
	if (V == none)
		return;
	Shower = bbPlayer(V.ViewTarget);
	if (Shower == none || Shower.IGPlus_SDIsServerDemoProxy() == false) {
		Shower = none;
		foreach AllActors(class'bbPlayer', P)
			if (P.IGPlus_SDIsServerDemoProxy()) {
				Shower = P;
				break;
			}
	}
	if (Shower == self)
		V.ReceiveLocalizedMessage(class'TimeMessage', 16 - Num);
}

// The "You have won the match" / "You have lost the match" announcer at the
// end of a match. Like TimeMessage, TournamentPlayer replicates it to the
// player's client, the engine writes it into a server demo too, and playback
// absorbs it on the recorded player. It is this player's own result, so it
// plays only for a viewer following us.
simulated function PlayWinMessage(bool bWinner) {
	local PlayerPawn V;
	local sound Announcement;

	if (IGPlus_SDIsServerDemoProxy() == false) {
		Super.PlayWinMessage(bWinner);
		return;
	}
	V = IGPlus_SDFollowingViewer();
	if (V == none)
		return;
	if (bWinner)
		Announcement = Sound(DynamicLoadObject("Announcer.Winner", class'Sound'));
	else
		Announcement = Sound(DynamicLoadObject("Announcer.LostMatch", class'Sound'));
	V.ClientPlaySound(Announcement, true, true);
}

// Server: the spree ends go to every player through ReceiveLocalizedMessage,
// which a server demo misses. UTPure writes one copy into the demo.
function EndSpree(PlayerReplicationInfo Killer, PlayerReplicationInfo Other) {
	Super.EndSpree(Killer, Other);
	if (zzUTPure == none)
		return;
	if (Killer == Other || Killer == none)
		zzUTPure.IGPlus_DemoGlobalMessage(class'KillingSpreeMessage', 1, none, Other);
	else
		zzUTPure.IGPlus_DemoGlobalMessage(class'KillingSpreeMessage', 0, Other, Killer);
}

event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Sw, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if (Message == class'CTFMessage2' && PureFlag(PlayerReplicationInfo.HasFlag) != None)
		return;

	if (Message == class'DecapitationMessage')
	{
		xxSendHeadshotToSpecs(Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}

	// We know exactly what Botpack.DeathMessagePlus does, so replace it with our own
	if (Message == class'Botpack.DeathMessagePlus')
		Message = class'IGPlus_DeathMessagePlus';

	// This is here to deal with mods that change the messages we receive, and
	// gracefully (or not) fall back to something that kind of works for
	// spectators.
	if (RelatedPRI_1 == PlayerReplicationInfo || RelatedPRI_2 == PlayerReplicationInfo)
	{
		if (ClassIsChildOf(Message, class'Botpack.DeathMessagePlus') || Message.Name == 'DDeathMessagePlus')
			xxSendDeathMessageToSpecs(Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		else if (ClassIsChildOf(Message, class'Botpack.MultiKillMessage') || Message.Name == 'MMultiKillMessage')
			xxSendMultiKillToSpecs(Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
		else if (ClassIsChildOf(Message, class'Botpack.KillingSpreeMessage'))
			xxSendSpreeToSpecs(Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	}

	Super.ReceiveLocalizedMessage(Message, Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

function xxSendHeadshotToSpecs(optional int Sw, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local Pawn P;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (P.IsA('bbCHSpectator') && bbCHSpectator(P).ViewTarget == Self)
			P.ReceiveLocalizedMessage( class'DecapitationMessage', Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

function xxSendDeathMessageToSpecs(optional int Sw, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local Pawn P;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (P.IsA('bbCHSpectator') && bbCHSpectator(P).ViewTarget == Self)
			P.ReceiveLocalizedMessage( class'SpecMessagePlus', Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

function xxSendMultiKillToSpecs(optional int Sw, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local Pawn P;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (P.IsA('bbCHSpectator') && bbCHSpectator(P).ViewTarget == Self)
			P.ReceiveLocalizedMessage( class'MultiKillMessage', Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

function xxSendSpreeToSpecs(optional int Sw, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local Pawn P;
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (P.IsA('bbCHSpectator') && bbCHSpectator(P).ViewTarget == Self)
			P.ReceiveLocalizedMessage( class'SpecSpreeMessage', Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event PlayerTick( float Time )
{
	xxPlayerTickEvents(Time);
	zzTick = Time;
}

simulated function ClientDemoMessage(coerce string S, optional name Type, optional bool bBeep)
{
	if (Settings != none && !Settings.bDemoShowClientMessages)
		return;
	
	if (S == zzPrevClientMessage)
		return;
	ClientMessage(S, Type, bBeep);
}

event ClientMessage(coerce string zzS, optional Name zzType, optional bool zzbBeep)
{
	zzPrevClientMessage = zzS;
	Super.ClientMessage(zzS, zzType, zzbBeep);
	zzPrevClientMessage = "";
	if (Settings != none && Settings.bLogClientMessages) {
		if (zzType == 'IGPlusDebug') {
			Log(zzS, zzType);
		} else {
			Log("["$IGPlus_FrameCount@Level.TimeSeconds$"]"@zzS, zzType);
		}
	}
}

// Movement debug (enableDebugData 1): one line for a dodge, a jump or a
// landing. The client writes what it did itself, the server what it did with
// the same move. The two sides each decide on their own copy of the player
// whether a dodge or a jump is possible, and the move carries the key press
// only. Where a pair of lines differs, one side dodged or jumped alone, and a
// burst of corrections follows (Send CAP) until the client has the server's
// state again, a ping later.
simulated function IGPlus_MoveDebug(string What) {
	if (bUpdating) // the replay of saved moves after a correction
		return;
	if (Level.NetMode == NM_Client) {
		if (bDrawDebugData)
			ClientDebugMessage(What@"(client)"@Level.TimeSeconds@"physics="$Physics
				@"vel="$int(Velocity.X)$","$int(Velocity.Y)$","$int(Velocity.Z));
	} else if (bDrawDebugData && Role == ROLE_Authority) {
		ClientDebugMessage(What@"(server)"@CurrentTimeStamp@"physics="$Physics
			@"vel="$int(Velocity.X)$","$int(Velocity.Y)$","$int(Velocity.Z));
	}
}

function ClientDebugMessage(coerce string S, optional name Type, optional bool bBeep) {
	local HUD H;

	if (Level.NetMode == NM_DedicatedServer || Role < ROLE_AutonomousProxy)
		return;

	if (Type == '')
		Type = 'IGPlusDebug';

	if (bDrawDebugData) {
		// The debug log file gets every line. ClientSettings.DebugDataDisplay
		// decides where else: 0 nowhere (a client demo still gets it, as with
		// debug data off), 1 the console and UnrealTournament.log, 2 also the
		// message area of the HUD. Without a HUD, ClientMessage skips that
		// part and does the rest as always.
		if (Settings != none && Settings.DebugDataDisplay <= 0) {
			zzPrevClientMessage = "["$IGPlus_FrameCount@Level.TimeSeconds$"] "$S;
			ClientDemoMessage(zzPrevClientMessage, Type, bBeep);
			zzPrevClientMessage = "";
		} else {
			H = myHUD;
			if (Settings != none && Settings.DebugDataDisplay < 2)
				myHUD = none;
			ClientMessage("["$IGPlus_FrameCount@Level.TimeSeconds$"] "$S, Type, bBeep);
			myHUD = H;
		}
		if (Level.NetMode != NM_DedicatedServer) {
			if (IGPlus_DebugLogFile == none)
				IGPlus_DebugLogFile = Spawn(class'IGPlus_DebugLogFile');
			if (IGPlus_DebugLogFile != none)
				IGPlus_DebugLogFile.WriteLine("["$IGPlus_FrameCount@Level.TimeSeconds$"] "$S);
		}
	} else {
		zzPrevClientMessage = "["$IGPlus_FrameCount@Level.TimeSeconds$"] "$S;
		ClientDemoMessage(zzPrevClientMessage, Type, bBeep);
		zzPrevClientMessage = "";
	}
}

function rotator GR()
{
	return ViewRotation;
}

event UpdateEyeHeight(float DeltaTime)
{
	local float DeltaZ;

	// smooth up/down stairs, landing, dont smooth ramps
	if ((Physics == PHYS_Walking && bJustLanded == false) ||
		// Smooth out stepping up onto unwalkable ramps
		(OldPhysics == PHYS_Walking && Physics == PHYS_Falling)
	) {
		DeltaZ = Location.Z - OldZ;

		// remove lifts from the equation.
		if (Base != none)
			DeltaZ -= DeltaTime * Base.Velocity.Z;

		// stair detection heuristic
		if (IgnoreZChangeTicks == 0 && (Abs(DeltaZ) > DeltaTime * GroundSpeed || bForceZSmoothing))
			EyeHeightOffset += FClamp(DeltaZ, -MaxStepHeight, MaxStepHeight);
		bForceZSmoothing = false;
	} else if (bJustLanded) {
		// Always smooth out landing, because you apparently are not considered
		// to have landed until you penetrate the ground by at least 1% of Velocity.Z.
		bForceZSmoothing = true;
	}

	if (IgnoreZChangeTicks > 0) IgnoreZChangeTicks--;
	bJustLanded = false;
	OldPhysics = Physics;
	OldZ = Location.Z;

	EyeHeightOffset += ShakeVert - OldShakeVert;
	OldShakeVert = ShakeVert;

	EyeHeightOffset += BaseEyeHeight - OldBaseEyeHeight;
	OldBaseEyeHeight = BaseEyeHeight;

	EyeHeightOffset = EyeHeightOffset * Exp(-9.0 * DeltaTime);
	EyeHeight = ShakeVert + BaseEyeHeight - EyeHeightOffset;

	if (Settings.bSmoothFOVChanges) {
		// The following events change your FOV:
		//   - Spawning
		//   - Zooming with Sniper Rifle
		//   - Teleporters
		// This smooths out FOV changes so they arent as jarring
		FOVAngle = DesiredFOV - (Exp(-9.0 * DeltaTime) * (DesiredFOV-FOVAngle));
	} else {
		FOVAngle = DesiredFOV;
	}

	// adjust FOV for weapon zooming
	if (bZooming) {
		ZoomLevel += DeltaTime * 1.0;
		if (ZoomLevel > 0.9)
			ZoomLevel = 0.9;
		DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);
	}

	xxCheckFOV();
}

event Landed(vector HitNormal)
{
	//Note - physics changes type to PHYS_Walking by default for landed pawns
	if ( bUpdating )
		return;
	PlayLanded(Velocity.Z);
	LandBob = FMin(50, Bob * Velocity.Z);
	TakeFallingDamage();
	bJustLanded = true;
}

function xxCheckFOV()
{
	if (zzTrackFOV == 1)
	{
		if (zzOrigFOV < 80)
		{
			if (DesiredFOV < 80)
				DesiredFOV = 90;
			zzOrigFOV = DesiredFOV;
		}
		if (zzOrigFOV != DesiredFOV && (Weapon == None || !Weapon.IsA('SniperRifle')))
		{
			DesiredFOV = zzOrigFOV;
			FOVAngle = zzOrigFOV;
		}
	}
	else if (zzTrackFOV == 2)
	{
		if ((DesiredFOV < 80 || FOVAngle < 80) && (Weapon == None || !Weapon.IsA('SniperRifle')))
		{
			if (zzOrigFOV < 80)
			{
				if (DesiredFOV < 80)
					DesiredFOV = 90;
				zzOrigFOV = DesiredFOV;
			}
			DesiredFOV = zzOrigFOV;
			FOVAngle = zzOrigFOV;
		}
	}
}

function TraceMarker_LongFrame() {}
function TraceMarker_FrameBegin() {}

event PlayerInput( float DeltaTime )
{
	local float FOVScale, MouseScale;
	local bool bOldWasForward, bOldWasBack, bOldWasLeft, bOldWasRight;

	if (DeltaTime > 0.02)
		TraceMarker_LongFrame();
	TraceMarker_FrameBegin();

	if ( bUpdatePosition && IGPlus_EnableInputReplication )
		ClientUpdatePositionWithInput();

	// Check for Dodge move
	// flag transitions
	bOldWasForward = bWasForward;
	bOldWasBack = bWasBack;
	bOldWasLeft = bWasLeft;
	bOldWasRight = bWasRight;
	bWasForward = (aBaseY >= 1);
	bWasBack = (aBaseY <= -1);
	bWasLeft = (aStrafe >= 1);
	bWasRight = (aStrafe <= -1);
	bEdgeForward = bOldWasForward != bWasForward;
	bEdgeBack = bOldWasBack != bWasBack;
	bEdgeLeft = bOldWasLeft != bWasLeft;
	bEdgeRight = bOldWasRight != bWasRight;
	if (Settings.bDebugMovement && (bEdgeForward || bEdgeBack || bEdgeLeft || bEdgeRight))
		ClientDebugMessage("BaseY:"@aBaseY@"Strafe:"@aStrafe@bWasForward@bWasBack@bWasLeft@bWasRight);

	IGPlus_PressedJumpSave = bPressedJump;
	bPressedDodge = (bDodge != bOldDodge) && (bDodge > 0);
	bOldDodge = bDodge;

	// Smooth and amplify mouse movement
	FOVScale = DesiredFOV * 0.01111;
	MouseScale = MouseSensitivity * FOVScale;

	aMouseX *= MouseScale;
	aMouseY *= MouseScale;

//************************************************************************

	// Mouse movement counts in the frame it comes in, never spread over the next.
	SmoothMouseX = aMouseX;
	SmoothMouseY = aMouseY;

	// adjust keyboard and joystick movements
	aLookUp *= FOVScale;
	aTurn   *= FOVScale;

	// Remap raw x-axis movement.
	if( bStrafe!=0 )
	{
		// Strafe.
		aStrafe += aBaseX + SmoothMouseX;
		aBaseX   = 0;
	}
	else
	{
		// Turning.
		aTurn  += aBaseX * FOVScale + SmoothMouseX;
		aBaseX  = 0;
	}

	// Remap mouse y-axis movement.
	if( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= SmoothMouseY;
		else
			aLookUp += SmoothMouseY;
	}
	else
	{
		// Move forward/backward.
		aForward += SmoothMouseY;
	}

	if ( bSnapLevel != 0 && !bAlwaysMouseLook && !zzCVDeny && (Level.TimeSeconds - zzCVTO) > zzCVDelay )
	{
		zzCVTO = Level.TimeSeconds;
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * FOVScale;
	}
	else
		aForward += aBaseY;

	aBaseY = 0;

	// Handle walking.
	HandleWalking();
}

function ServerMove
(
	float TimeStamp,
	vector InAccel,
	vector ClientLoc,
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	bool bFired,
	bool bAltFired,
	bool bForceFire,
	bool bForceAltFire,
	eDodgeDir DodgeMove,
	byte ClientRoll,
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	if (zzSMCnt == 0)
		Log("SM Attempt to cheat by"@PlayerReplicationInfo.PlayerName, 'UTCheat');

	zzSMCnt++;
	if (zzSMCnt > 30)
	{
		xxServerCheater("SM");
	}
}

// ClientAdjustPosition - pass newloc and newvel in components so they don't get rounded

function ClientAdjustPosition
(
	float TimeStamp,
	name newState,
	EPhysics newPhysics,
	float NewLocX,
	float NewLocY,
	float NewLocZ,
	float NewVelX,
	float NewVelY,
	float NewVelZ,
	Actor NewBase
)
{
}

// OLD STYLE (3xfloat) CAP

function xxCAP(float TimeStamp, name newState, int MiscData,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp, newState, MiscData,Loc,Vel,NewBase);
}

function xxCAPLevelBase(float TimeStamp, name newState, int MiscData,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp,newState,MiscData,Loc,Vel,Level);
}

function xxCAPWalking(float TimeStamp, int MiscData,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	xxPureCAP(TimeStamp,'PlayerWalking',MiscData,Loc,Vel,NewBase);
}

function xxCAPWalkingWalkingLevelBase(float TimeStamp, int MiscData,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	MiscData = MiscData | (/*PHYS_Walking*/(1) << 2);
	xxPureCAP(TimeStamp,'PlayerWalking',MiscData,Loc,Vel,Level);
}

function xxCAPWalkingWalking(float TimeStamp, int MiscData,
			float NewLocX, float NewLocY, float NewLocZ, float NewVelX, float NewVelY, float NewVelZ, Actor NewBase)
{
	local vector Loc,Vel;
	Loc.X = NewLocX; Loc.Y = NewLocY; Loc.Z = NewLocZ;
	Vel.X = NewVelX; Vel.Y = NewVelY; Vel.Z = NewVelZ;
	MiscData = MiscData | (/*PHYS_Walking*/(1) << 2);
	xxPureCAP(TimeStamp,'PlayerWalking',MiscData,Loc,Vel,NewBase);
}

simulated function xxPureCAP(float TimeStamp, name newState, int MiscData, vector NewLoc, vector NewVel, Actor NewBase)
{
	local Decoration Carried;
	local vector OldLoc;
	local bool bOldCollWorld;
	local bool bOldActCol, bOldBlockAct, bOldBlockPlayer;

	if (bDeleteMe)
		return;

	if (IGPlus_EnableInputReplication) {
		if (IGPlus_SavedInputChain.Oldest.TimeStamp - 0.5*IGPlus_SavedInputChain.Oldest.Delta > TimeStamp) {
			ClientDebugMessage("Ignore CAP"@TimeStamp@IGPlus_SavedInputChain.Oldest.TimeStamp);
			return;
		}

		if (bTraceInput && IGPlus_InputLogFile != none)
			IGPlus_InputLogFile.LogCAP(TimeStamp, NewLoc, NewVel, NewBase);
	} else {
		if ( CurrentTimeStamp > TimeStamp )
			return;
	}
	CurrentTimeStamp = TimeStamp;

	// Higor: keep track of Position prior to adjustment
	// and stop current smoothed adjustment (if in progress).
	if (bUpdatePosition == false) {
		IGPlus_PreAdjustLocation = Location;
		IGPlus_PreAdjustTlocCounter = TlocCounter;
		IGPlus_CAPPushed = false;
	}
	// The server pushed us lately and we couldn't know (IGPlus_SendCAP).
	if ((MiscData & IGPLUS_CAP_PUSHED) != 0)
		IGPlus_CAPPushed = true;
	if ( VSize(IGPlus_AdjustLocationOffset) > 0 )
	{
		IGPlus_AdjustLocationAlpha = 0;
		IGPlus_AdjustLocationOffset = vect(0,0,0);
	}
	IGPlus_AdjustLocationOverride = (TlocCounter != (MiscData&3));
	// The server translocated us: same as above, no step smoothing.
	if (IGPlus_AdjustLocationOverride)
		IgnoreZChangeTicks = 2;

	SetPhysics(GetPhysics((MiscData >> 2) & 0xF));
	TlocCounter = MiscData & 3;

	SetBase(NewBase);
	if ( Mover(NewBase) != None )
		NewLoc += NewBase.Location;

	if (GetStateName() != NewState) {
		IGPlus_CameraCorrectionSnap = true;
		GotoState(newState);
	}

	Carried = CarriedDecoration;
	OldLoc = Location;

	bCanTeleport = false;
	bOldActCol = bCollideActors;
	bOldBlockAct = bBlockActors;
	bOldBlockPlayer = bBlockPlayers;
	bOldCollWorld = bCollideWorld;
	bCollideWorld = false;
	SetCollision(false, false, false);
	SetLocation(NewLoc);
	bCollideWorld = bOldCollWorld;
	SetCollision(bOldActCol, bOldBlockAct, bOldBlockPlayer);
	bCanTeleport = true;
	Velocity = NewVel;

	if ( Carried != None )
	{
		CarriedDecoration = Carried;
		CarriedDecoration.SetLocation(NewLoc + CarriedDecoration.Location - OldLoc);
		CarriedDecoration.SetPhysics(PHYS_None);
		CarriedDecoration.SetBase(self);
	}

	zzbFakeUpdate = false;
	bUpdatePosition = true;
}

function xxFakeCAP(float TimeStamp)
{
	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	IGPlus_AdjustLocationAlpha = 0;
	IGPlus_AdjustLocationOffset = vect(0,0,0);

	// A real CAP later this frame skips this; keep it current for it.
	if (bUpdatePosition == false) {
		IGPlus_PreAdjustLocation = Location;
		IGPlus_PreAdjustTlocCounter = TlocCounter;
		IGPlus_CAPPushed = false;
	}
	bUpdatePosition = true;
}

function IGPlus_ClientReplayMove(IGPlus_SavedMove M) {
	local int MergeCount, MoveIndex;
	local IGPlus_SelfKnockback K;
	local vector Push;
	local float dt;
	local bool bDoJump;
	local EDodgeDir DoDodge;
	local bool bDoRun;
	local bool bDoDuck;

	SetRotation(M.Rotation);
	ViewRotation = M.IGPlus_SavedViewRotation;
	bDodging = M.SavedDodging;

	if (M.bIGPlusTloc)
		IGPlus_ReplayTranslocate(M.IGPlusTlocDest);

	// Own boarding: the lift where it was put for this move the first time.
	if (M.IGPlus_OBLift != None && M.IGPlus_OBLift.bDeleteMe == false && M.IGPlus_OBLift != Base)
		IGPlus_OBPut(M.IGPlus_OBLift, M.IGPlus_OBLoc);

	MergeCount = M.IGPlus_MergeCount + 1;
	dt = M.Delta / MergeCount;
	for (MoveIndex = 0; MoveIndex < MergeCount; MoveIndex++) {
		if (MoveIndex == M.JumpIndex)
			bDoJump = M.bPressedJump;
		else
			bDoJump = false;

		if (MoveIndex == M.DodgeIndex)
			DoDodge = M.DodgeMove;
		else
			DoDodge = DODGE_None;

		bDoRun = (MoveIndex < M.RunChangeIndex) ^^ M.bRun;
		bDoDuck = (MoveIndex < M.DuckChangeIndex) ^^ M.bDuck;

		IGPlus_MoveAutonomous(dt, bDoRun, bDoDuck, bDoJump, DoDodge, M.Acceleration, rot(0,0,0));
	}
	IGPlus_OBEnd(true);

	if (M.IGPlus_LiftExitShift != vect(0,0,0))
		MoveSmooth(M.IGPlus_LiftExitShift);
	Velocity.Z += M.IGPlus_LiftExitVelZ;

	for (MoveIndex = 0; MoveIndex < M.IGPlus_SKPushCount; MoveIndex++) {
		if (M.IGPlus_SKKind[MoveIndex] == IGPLUS_SK_HAMMER) {
			IGPlus_SKAddVelocity(M.IGPlus_SKPush[MoveIndex]);
			continue;
		}
		IGPlus_SKPredictedEntry(M.IGPlus_SKHit[MoveIndex], K, M.IGPlus_SKKind[MoveIndex]);
		if (IGPlus_SKCompute(K, Push))
			IGPlus_SKAddVelocity(Push);
	}

	M.IGPlus_SavedLocation = Location;
	M.IGPlus_SavedVelocity = Velocity;
}

function IGPlus_FreeAcknowledgedMoves(float TimeStamp) {
	local SavedMove FirstMove;
	local SavedMove CurrentMove;

	if (SavedMoves == none) return;
	if (SavedMoves.TimeStamp > TimeStamp) return;

	CurrentMove = SavedMoves;
	FirstMove = CurrentMove;

	while (CurrentMove.NextMove != none && CurrentMove.NextMove.TimeStamp <= TimeStamp) {
		CurrentMove = CurrentMove.NextMove;
	}

	SavedMoves = CurrentMove.NextMove;
	CurrentMove.NextMove = FreeMoves;
	FreeMoves = FirstMove;
}

// Camera-only correction smoothing. Delta is where the view was minus where
// the corrected simulation now is. Teleports (translocation, respawn) and
// anything too large to be a smoothing case snap instead.
function IGPlus_CameraCorrectionAdd(vector Delta) {
	IGPlus_CameraCorrectionOffset += Delta;
	// Shots leave from the real position, so while the camera lags they land
	// off the crosshair by the offset. 50uu matches the old smoothing limit:
	// anything bigger snaps so aim is right at once.
	if (IGPlus_AdjustLocationOverride || IGPlus_CameraCorrectionSnap
		|| VSize(IGPlus_CameraCorrectionOffset) > 50
		|| Settings.CameraCorrectionSmoothingTime <= 0.0
	) {
		IGPlus_CameraCorrectionOffset = vect(0,0,0);
		if (VSize(Delta) > 1)
			NetStatsElem.bInstantRelocation = true;
	}
	IGPlus_CameraCorrectionSnap = false;
}

simulated function IGPlus_CameraCorrectionDecay(float DeltaTime) {
	if (IGPlus_LiftExitCamOffset != vect(0,0,0)) {
		// ~95% gone after IGPLUS_LIFT_EXIT_EASE seconds
		IGPlus_LiftExitCamOffset *= Exp(-3.0 * (DeltaTime / Level.TimeDilation) / IGPLUS_LIFT_EXIT_EASE);
		if (VSize(IGPlus_LiftExitCamOffset) < 0.05)
			IGPlus_LiftExitCamOffset = vect(0,0,0);
	}
	if (IGPlus_PushCamOffset != vect(0,0,0)) {
		// ~95% gone after IGPLUS_PUSH_EASE seconds
		IGPlus_PushCamOffset *= Exp(-3.0 * (DeltaTime / Level.TimeDilation) / IGPLUS_PUSH_EASE);
		if (VSize(IGPlus_PushCamOffset) < 0.05)
			IGPlus_PushCamOffset = vect(0,0,0);
	}
	if (IGPlus_CameraCorrectionOffset == vect(0,0,0))
		return;

	if (Settings.bCameraCorrectionSmoothing == false || Settings.CameraCorrectionSmoothingTime <= 0.0) {
		IGPlus_CameraCorrectionOffset = vect(0,0,0);
		return;
	}

	// ~95% gone after CameraCorrectionSmoothingTime seconds
	IGPlus_CameraCorrectionOffset *= Exp(-3.0 * (DeltaTime / Level.TimeDilation) / Settings.CameraCorrectionSmoothingTime);
	if (VSize(IGPlus_CameraCorrectionOffset) < 0.05)
		IGPlus_CameraCorrectionOffset = vect(0,0,0);
}

// Moves the first-person camera by the remaining correction offset, stopping
// short of walls so the view never ends up inside geometry.
simulated function IGPlus_ApplyCameraCorrection(out vector CameraLocation) {
	IGPlus_CameraCorrectionApplied = vect(0,0,0);
	if (Settings.bCameraCorrectionSmoothing == false)
		IGPlus_CameraCorrectionOffset = vect(0,0,0);
	if (IGPlus_CameraCorrectionOffset == vect(0,0,0) && IGPlus_LiftExitCamOffset == vect(0,0,0)
		&& IGPlus_PushCamOffset == vect(0,0,0))
		return;

	IGPlus_CameraCorrectionApplied = IGPlus_ClippedCameraOffset(CameraLocation);
	IGPlus_CameraOffsetDrawn = IGPlus_CameraCorrectionApplied;
	CameraLocation += IGPlus_CameraCorrectionApplied;
}

// Camera offset as rendered from Eye: the remaining correction (and lift exit
// and push eases), stopped short of walls.
simulated function vector IGPlus_ClippedCameraOffset(vector Eye) {
	local vector Offset, Desired, HitLocation, HitNormal;

	Offset = IGPlus_CameraCorrectionOffset + IGPlus_LiftExitCamOffset + IGPlus_PushCamOffset;
	Desired = Eye + Offset;
	if (Trace(HitLocation, HitNormal, Desired, Eye, false) != none)
		Desired = HitLocation - 2.0 * Normal(Offset);
	return Desired - Eye;
}

// --- Predicted lift exit --------------------------------------------------------

// A rider's client has its lift a round trip of travel behind the server's
// (lift updates arrive a one-way late, moves reach the server a one-way late),
// so the server has the rider that much further along the lift's path. While
// riding, positions are compared on the lift and agree. On leaving it the
// server's correction arrives a ping later as one jump (90uu measured).

const IGPLUS_LIFT_EXIT_EASE = 0.1;

// --- Push ease -------------------------------------------------------------------

// A push our client can't predict (another player's hit: a teammate's beam
// does no damage but pushes) lands on the server at once. The client finds
// out with the server's correction a ping later, as one jump of the push's
// speed times the ping (about 90uu at 136 ping). The simulation takes the
// correction at once, the camera eases the jump out, like the lift exit.
const IGPLUS_PUSH_EASE = 0.1;           // seconds until ~95% of it is gone
const IGPLUS_PUSH_EASE_MAX = 150.0;     // a larger jump snaps
const IGPLUS_PUSH_EASE_WINDOW = 0.5;    // move time after the push its corrections are marked
const IGPLUS_CAP_PUSHED = 64;           // the mark, a bit of the correction's MiscData

// The jump a push's correction makes (plus what is still easing from one
// before) goes on the camera when it is an ordinary move: not a teleport or
// a state change, not too far, nothing between the two spots.
static function bool IGPlus_PushEaseTakes(vector Jump, bool bTeleport, bool bClearLine) {
	return bTeleport == false && bClearLine && VSize(Jump) <= IGPLUS_PUSH_EASE_MAX;
}

// Client: how far Lift moves over the next Ahead seconds of its current
// keyframe move (eased like the engine's physMovingBrush), and how much faster
// it is going then. False when it is not moving here.
simulated function bool IGPlus_LiftAhead(Mover Lift, float Ahead, out vector Lead, out vector VelLead) {
	local vector Path;
	local float A0, A1, G0, G1, D0, D1;

	if (Lift == None || Lift.Physics != PHYS_MovingBrush || Lift.bInterpolating == false || Lift.PhysRate <= 0.0)
		return false;

	Path = Lift.BasePos + Lift.KeyPos[Lift.KeyNum] - Lift.OldPos;
	A0 = FClamp(Lift.PhysAlpha, 0.0, 1.0);
	A1 = FClamp(Lift.PhysAlpha + Lift.PhysRate * Ahead, 0.0, 1.0);
	if (Lift.MoverGlideType == MV_GlideByTime) {
		G0 = A0 * A0 * (3.0 - 2.0 * A0);
		G1 = A1 * A1 * (3.0 - 2.0 * A1);
		D0 = 6.0 * A0 * (1.0 - A0);
		D1 = 6.0 * A1 * (1.0 - A1);
	} else {
		G0 = A0;
		G1 = A1;
		D0 = 1.0;
		D1 = 1.0;
		if (A1 >= 1.0)
			D1 = 0.0;
	}
	Lead = Path * (G1 - G0);
	VelLead = Path * Lift.PhysRate * (D1 - D0);
	return true;
}

// Client, after the move in which we left Lift (moving here): go where the
// server has us, ease the camera over it, and keep it in the move for replays.
simulated function IGPlus_LeftMovingLift(Mover Lift, IGPlus_SavedMove Move) {
	local vector Lead, VelLead, Before;

	IGPlus_LiftExitTS = Level.TimeSeconds;
	if (IGPlus_LiftAhead(Lift, float(PingAverage) * 0.001 * Level.TimeDilation, Lead, VelLead) == false)
		return;
	// Down: our lift is still above where the server has us, in the way. The
	// server's correction is eased on the camera instead (ClientUpdatePosition).
	if (Lead.Z < 0.0)
		return;
	// Walked onto a floor: the floor decides our height on both sides.
	if (Physics != PHYS_Falling)
		return;

	Before = Location;
	MoveSmooth(Lead);
	Move.IGPlus_LiftExitShift = Location - Before;
	// A jump (or a dodge that keeps Z momentum) took the lift's speed: the
	// server's lift is further along, at another speed.
	if (Move.bPressedJump
		|| (bDodgePreserveZMomentum && Move.DodgeMove > DODGE_None && Move.DodgeMove < DODGE_Active))
		Move.IGPlus_LiftExitVelZ = VelLead.Z;
	Velocity.Z += Move.IGPlus_LiftExitVelZ;

	IGPlus_LiftExitCamOffset -= Move.IGPlus_LiftExitShift;
	IgnoreZChangeTicks = 2; // not a step up: no eye-height smoothing on top
	ClientDebugMessage("Left a moving lift: moved "$int(Move.IGPlus_LiftExitShift.Z)$"uu to the server's spot, speed "$int(Move.IGPlus_LiftExitVelZ));
}

// Own boarding, client: the level's movers, found once (they are level actors).
simulated function IGPlus_OBFindMovers() {
	local Mover M;

	IGPlus_OBMoversFound = true;
	IGPlus_OBNumMovers = 0;
	foreach AllActors(class'Mover', M)
		if (IGPlus_OBNumMovers < arraycount(IGPlus_OBMovers)) {
			IGPlus_OBMovers[IGPlus_OBNumMovers] = M;
			IGPlus_OBNumMovers++;
		}
}

// Own boarding, client, before one of our own moves (Move: the saved move it goes in).
// Our copy of a moving lift is behind the server's: its updates come a one-way late and
// our moves reach the server a one-way late. The server runs our move before its lift
// moves in that tick. We take our ping (PingAverage, the age of our newest acknowledged
// move) as the lead: on a test rig at 10 to 172 ping that had us on the lift on the move
// the server did or one tick before it in most boardings, which cost no corrections.
// Two ticks early or one tick late cost a correction every tick for a round trip.
// Walking at a lift in the last part of its way down, our screen had it 15 to 30 uu
// higher than the server: we slid along its edge while the server had us on it, and got
// a correction every tick until our copy came low enough. Now our move is tested against
// the lift where the server has it, so we step on, bump into and land on it on the move
// the server does. Only for our own moves: the lift is drawn where it was, the server
// runs the lift and decides as before, and other players see us from the server.
// Not the lift we ride (positions on it are compared on the lift), not one we left
// within a ping and a bit (Smooth Lift Jump has us there already), and not when the
// moved lift would be inside us.
simulated function IGPlus_OBBegin(IGPlus_SavedMove Move) {
	local Mover M, Best;
	local vector Lead, VelLead, BestLead, D;
	local float Ahead, Dist, BestDist;
	local int i;

	if (Move != None)
		Move.IGPlus_OBLift = None;
	IGPlus_OBLift = None;
	if (Level.NetMode != NM_Client)
		return;
	if (IGPlus_OBMoversFound == false)
		IGPlus_OBFindMovers();
	Ahead = float(PingAverage) * 0.001 * Level.TimeDilation;
	if (Mover(Base) != None) {
		IGPlus_OBLastBase = Mover(Base);
		IGPlus_OBLastBaseTS = Level.TimeSeconds;
		// The lift we ride stays where it is drawn, but the move notes where the
		// server has it: a correction may put us back off it (we got on a move or
		// two before the server), and the replay must meet that lift, not the drawn one.
		if (Move != None && IGPlus_LiftAhead(Mover(Base), Ahead, Lead, VelLead) && VSize(Lead) >= 0.5) {
			Move.IGPlus_OBLift = Mover(Base);
			Move.IGPlus_OBLoc = Base.Location + Lead;
		}
	}
	BestDist = 768.0;
	for (i = 0; i < IGPlus_OBNumMovers; i++) {
		M = IGPlus_OBMovers[i];
		if (M == None || M.bDeleteMe || M == Base)
			continue;
		if (M == IGPlus_OBLastBase && Level.TimeSeconds - IGPlus_OBLastBaseTS < Ahead + 0.3 * Level.TimeDilation)
			continue;
		D = M.Location - Location;
		D.Z = 0;
		Dist = VSize(D);
		if (Dist >= BestDist)
			continue;
		if (IGPlus_LiftAhead(M, Ahead, Lead, VelLead) == false || VSize(Lead) < 0.5)
			continue;
		// Lifts and gates that go up and down only: our test for a mover cutting
		// through us looks along our height, not across it.
		if (Abs(Lead.Z) < 2.0 * VSize(Lead * vect(1,1,0)))
			continue;
		Best = M;
		BestDist = Dist;
		BestLead = Lead;
	}
	if (Best == None)
		return;
	IGPlus_OBPut(Best, Best.Location + BestLead);
	if (IGPlus_OBInside(Best)) {
		IGPlus_OBEnd(true);
		return;
	}
	if (Move != None) {
		Move.IGPlus_OBLift = Best;
		Move.IGPlus_OBLoc = Best.Location;
	}
}

// Own boarding: move our copy of M to Loc with its collision off (a mover moved onto
// something runs encroachment), noting what stood on it: moving it takes them off.
simulated function IGPlus_OBPut(Mover M, vector Loc) {
	local Actor A;
	local bool bC, bA, bP;

	IGPlus_OBNumRiders = 0;
	foreach M.BasedActors(class'Actor', A)
		if (A != self && IGPlus_OBNumRiders < arraycount(IGPlus_OBRiders)) {
			IGPlus_OBRiders[IGPlus_OBNumRiders] = A;
			IGPlus_OBNumRiders++;
		}
	IGPlus_OBLift = M;
	IGPlus_OBDrawn = M.Location;
	bC = M.bCollideActors;
	bA = M.bBlockActors;
	bP = M.bBlockPlayers;
	M.SetCollision(false, false, false);
	M.SetLocation(Loc);
	M.SetCollision(bC, bA, bP);
}

// Own boarding: the moved lift cuts through our body (we are under it, or just off it).
simulated function bool IGPlus_OBInside(Mover M) {
	local Actor A;
	local vector HL, HN, Top, Bottom;

	Top = Location + vect(0,0,1) * CollisionHeight;
	Bottom = Location - vect(0,0,1) * (CollisionHeight - 2.0);
	foreach TraceActors(class'Actor', A, HL, HN, Bottom, Top)
		if (A == M)
			return true;
	foreach TraceActors(class'Actor', A, HL, HN, Top, Bottom)
		if (A == M)
			return true;
	return false;
}

// Own boarding, after the move: the lift goes back where it is drawn and whatever stood
// on it is set on it again. If we got on it in this move we ride back with it, as a rider
// does, and (not in a replay) the view follows over 0.1 s (IGPlus_LiftExitCamOffset).
simulated function IGPlus_OBEnd(bool bReplay) {
	local Mover M;
	local vector D;
	local bool bOn, bC, bA, bP, bW;
	local bool bOldActCol, bOldBlockAct, bOldBlockPlayer;
	local int i;

	M = IGPlus_OBLift;
	if (M == None)
		return;
	IGPlus_OBLift = None;
	bOn = Base == M;
	D = IGPlus_OBDrawn - M.Location;
	bC = M.bCollideActors;
	bA = M.bBlockActors;
	bP = M.bBlockPlayers;
	M.SetCollision(false, false, false);
	M.SetLocation(IGPlus_OBDrawn);
	M.SetCollision(bC, bA, bP);
	for (i = 0; i < IGPlus_OBNumRiders; i++) {
		if (IGPlus_OBRiders[i] != None && IGPlus_OBRiders[i].bDeleteMe == false && IGPlus_OBRiders[i].Base == None)
			IGPlus_OBRiders[i].SetBase(M);
		IGPlus_OBRiders[i] = None;
	}
	IGPlus_OBNumRiders = 0;
	if (bOn == false || VSize(D) < 0.01)
		return;
	bW = bCollideWorld;
	bOldActCol = bCollideActors;
	bOldBlockAct = bBlockActors;
	bOldBlockPlayer = bBlockPlayers;
	bCollideWorld = false;
	SetCollision(false, false, false);
	SetLocation(Location + D);
	bCollideWorld = bW;
	SetCollision(bOldActCol, bOldBlockAct, bOldBlockPlayer);
	SetBase(M);
	if (bReplay)
		return;
	IGPlus_LiftExitCamOffset -= D;
	IgnoreZChangeTicks = 2;
	if (bDrawDebugData)
		ClientDebugMessage("Own boarding: got on "$M.Name$" where the server has it, "$int(-D.Z)$"uu from where it is drawn");
}

// Debug (enableDebugData): stepping on or off a lift, on each side. A lift
// that waits for riders starts again when one lands on it.
singular event BaseChange() {
	local string Side;

	if (bDrawDebugData && (Mover(Base) != None || Mover(IGPlus_DbgLastBase) != None)) {
		Side = "server";
		if (Level.NetMode == NM_Client)
			Side = "client";
		ClientDebugMessage("Base ("$Side$"): "$IGPlus_DbgLastBase$" -> "$Base$" at Z="$int(Location.Z)
			$" velZ="$int(Velocity.Z)$" "$GetEnum(enum'EPhysics', Physics));
	}
	IGPlus_DbgLastBase = Base;
	super.BaseChange();
}

// Debug (enableDebugData): where we left a moving lift and the top of the
// jump, on each side (the server decides the jump from our inputs).
simulated function IGPlus_DebugLiftJumpTop(Actor OldBase) {
	local string Side;

	if (bDrawDebugData == false)
		return;
	if (Mover(OldBase) != None && OldBase.Velocity != vect(0,0,0) && Base != OldBase) {
		IGPlus_DbgLiftJump = true;
		IGPlus_DbgLiftExitZ = Location.Z;
		IGPlus_DbgLiftRising = Velocity.Z > 0.0;
		return;
	}
	if (IGPlus_DbgLiftJump == false)
		return;
	if (Physics != PHYS_Falling) {
		IGPlus_DbgLiftJump = false;
		return;
	}
	if (IGPlus_DbgLiftRising && Velocity.Z <= 0.0) {
		IGPlus_DbgLiftJump = false;
		Side = "server";
		if (Level.NetMode == NM_Client)
			Side = "client";
		ClientDebugMessage("Lift jump ("$Side$"): left the lift at Z="$int(IGPlus_DbgLiftExitZ)$", top Z="$int(Location.Z));
		return;
	}
	IGPlus_DbgLiftRising = Velocity.Z > 0.0;
}

// Client: the server's corrections for leaving a lift are still arriving.
simulated function bool IGPlus_InLiftExitWindow() {
	return IGPlus_LiftExitTS > 0.0
		&& Level.TimeSeconds - IGPlus_LiftExitTS < PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation + 0.3;
}

// Push-Safe Aim, client: the view that sends a shot from the real position
// through the point under the crosshair of the (offset) rendered camera. The
// unshifted shot would hit D*Dir + Offset from the real origin.
// The offset is the one the last frame drew, where the player aimed. The
// offset now has eased on since: by 6 of 30 units in the first frame of a
// correction at 110 fps. With it the shot left that far beside the crosshair,
// and on a rig, 30 uu corrections, a click on the first frame, aimed at the
// middle of a running target 600 uu away, it missed 9 of 64 shots, all where
// the target turned (drawn up to 13 uu from where the server has them). With
// the drawn offset 128 of 128 hit.
simulated function bool IGPlus_PSAAimView(out rotator AimView) {
	local vector Dir, Eye, Offset, HitLocation, HitNormal;
	local float D;

	Eye = Location + EyeHeight * vect(0,0,1) + WalkBob;
	Offset = IGPlus_CameraOffsetDrawn;
	if (Offset == vect(0,0,0))
		return false;

	Dir = vector(ViewRotation);
	if (Trace(HitLocation, HitNormal, Eye + Offset + 30000.0 * Dir, Eye + Offset, true) == none)
		return false; // nothing under the crosshair: parallel is right

	D = (HitLocation - (Eye + Offset)) dot Dir;
	// Any distance: the shot still goes through the point under the
	// crosshair. This was 50, and a player whose front was closer than that
	// (27 uu at 40 uu apart on a rig, a 25 uu correction) was missed 32 of 32
	// times with the crosshair on their middle. Now 32 of 32 hit.
	if (D < 1.0)
		return false;

	AimView = rotator(D * Dir + Offset);
	AimView.Roll = ViewRotation.Roll;
	return true;
}

// Push-Safe Aim, server: a push we applied that the client hasn't seen yet,
// stamped on the move timeline.
function IGPlus_PSANotePush(vector DV) {
	IGPlus_PSAPushTS[IGPlus_PSAPushNext] = CurrentTimeStamp;
	IGPlus_PSAPushDV[IGPlus_PSAPushNext] = DV;
	IGPlus_PSAPushNext = (IGPlus_PSAPushNext + 1) % arraycount(IGPlus_PSAPushTS);
}

simulated function bool IGPlus_PSAClear(vector A, vector B) {
	local vector HitLocation, HitNormal;
	return Trace(HitLocation, HitNormal, A, B, false) == none;
}

// Push-Safe Aim, server: where a Det shot leaves from. The client fired from
// the start of this (single-frame) move. Use that when the gap to our
// position is the drift of pushes it hadn't seen (each push's speed change
// times its age), and the line between both bodies and eyes is clear.
// Dead (a trade), always: IGPlus_TradeShotOrigin.
function vector IGPlus_PSAShotOrigin(IGPlus_ServerMove SM, float PrevTS, int MergeCount) {
	local vector ClientStart, Gap, Expected;
	local float ShotTS, Age, MaxAge, Drift, Window, Slack;
	local int i;
	local bool bExact;

	IGPlus_ShotOriginGap = -1.0;
	IGPlus_ShotOriginFrom = 0;
	if (MergeCount != 0 || Mover(SM.ClientBase) != none)
		return Location;

	ClientStart = SM.ClientLocation - SM.ClientVelocity * SM.MoveDeltaTime;
	if (SM.ClientBase != none)
		ClientStart += SM.ClientBase.Location;
	// Exact when the previous move (and nothing between) reported it.
	if (IGPlus_PSALastClientTS == PrevTS
		&& Abs(SM.TimeStamp - PrevTS - SM.MoveDeltaTime) < 0.5 * SM.MoveDeltaTime
		&& VSize(IGPlus_PSALastClientLoc - ClientStart) < 4.0) {
		ClientStart = IGPlus_PSALastClientLoc;
		bExact = true;
	}

	if (IsInState('Dying'))
		return IGPlus_TradeShotOrigin(SM, ClientStart);

	Gap = Location - ClientStart;
	IGPlus_ShotOriginGap = VSize(Gap);
	// Close: the shot leaves from the client's spot. Its screen fired from
	// there, and we take that spot for its movement without a correction
	// (xxServerMove's MaxLocError). From our own spot a beam that grazed a
	// player by less than the gap could hit on its screen and miss here.
	// Only where the move before this one reported that spot: worked back
	// from this move's end it can be off by more than the gap at a low
	// frame rate.
	if (bExact && IGPlus_ShotOriginIsNear(IGPlus_ShotOriginGap)) {
		IGPlus_ShotOriginFrom = 1;
		return ClientStart;
	}
	if (IGPlus_PushSafeAim == false || IGPlus_ShotOriginGap < 0.5)
		return Location;

	ShotTS = SM.TimeStamp - SM.MoveDeltaTime;
	Window = (FMax(0.1, PlayerReplicationInfo.Ping * 0.0015) + 0.1) * Level.TimeDilation;
	for (i = 0; i < arraycount(IGPlus_PSAPushTS); i++) {
		if (IGPlus_PSAPushTS[i] <= 0.0)
			continue;
		Age = ShotTS - IGPlus_PSAPushTS[i];
		if (Age <= 0.0 || Age > Window)
			continue;
		Expected += IGPlus_PSAPushDV[i] * Age;
		Drift += VSize(IGPlus_PSAPushDV[i]) * Age;
		MaxAge = FMax(MaxAge, Age);
	}
	if (Drift <= 0.0)
		return Location;

	// ponytail: 25% of the drift, plus what ground vs air acceleration and
	// gravity can add since the push, plus 8uu
	Slack = 0.25 * Drift + 0.5 * (AccelRate + VSize(Region.Zone.ZoneGravity)) * MaxAge * MaxAge + 8.0;
	if (VSize(Gap - Expected) > Slack)
		return Location;

	if (IGPlus_PSAClear(ClientStart, Location) == false
		|| IGPlus_PSAClear(ClientStart + BaseEyeHeight * vect(0,0,1), Location + BaseEyeHeight * vect(0,0,1)) == false)
		return Location;

	IGPlus_ShotOriginFrom = 2;
	return ClientStart;
}

// The client's own spot counts as ours for a shot when the two are no
// further apart than the movement code lets them be without a correction:
// MaxLocError is 3.0 for the square of the distance.
static function bool IGPlus_ShotOriginIsNear(float Gap) {
	return Gap >= 0.0 && Gap * Gap <= 3.0;
}

// A trade (bEnableAllWeaponTrades), server: the dead client fired from where
// its screen had it. Our body stopped following it when we died: it took the
// killing push and no dodge or jump since (Dying has no ProcessMove). So the
// shot leaves from the client's spot, if it could have got there from where
// we died, in a clear line. Else from our body.
function vector IGPlus_TradeShotOrigin(IGPlus_ServerMove SM, vector ClientStart) {
	local float DT, Reach, Dist;
	local bool bFireInput;

	// Client time since then, no more than the server's (plus jitter).
	DT = FClamp(SM.TimeStamp - SM.MoveDeltaTime - IGPlus_TradeTS, 0.0, (RealTimeDead + 0.1) * Level.TimeDilation);
	Reach = IGPlus_TradeReach(IGPlus_TradeSpeed, FMax(DodgeSpeedXY, GroundSpeed), FMax(DodgeSpeedZ, JumpZ),
		AccelRate, VSize(Region.Zone.ZoneGravity), DT);
	Dist = VSize(ClientStart - IGPlus_TradeLoc);
	// Debug lines only for moves with fire (Dying.xxServerMove kept it for a trade).
	bFireInput = (SM.MiscData & 0x03000000) != 0 || (SM.MiscData2 & 0xC0000000) != 0;
	if (Dist > Reach
		|| IGPlus_PSAClear(ClientStart, IGPlus_TradeLoc) == false
		|| IGPlus_PSAClear(ClientStart + BaseEyeHeight * vect(0,0,1), IGPlus_TradeLoc + BaseEyeHeight * vect(0,0,1)) == false
	) {
		if (bFireInput)
			ClientDebugMessage("Trade shot (server): from our body, the client's spot is"@int(Dist)$"uu from where we died (reach"@int(Reach)$"uu, or blocked)");
		return Location;
	}
	if (bFireInput)
		ClientDebugMessage("Trade shot (server): from the client's spot,"@int(Dist)$"uu from where we died, our body"@int(VSize(Location - ClientStart))$"uu off");
	return ClientStart;
}

// How far a player can get in DT: his speed plus a full dodge and jump,
// with acceleration and gravity on top, plus 16uu.
// ponytail: adds the speeds up, a cheat gets that much room for after-death shots
static function float IGPlus_TradeReach(float Speed, float DodgeXY, float JumpUp, float Accel, float Gravity, float DT) {
	return (Speed + DodgeXY + JumpUp) * DT + 0.5 * (Accel + Gravity) * DT * DT + 16.0;
}

// PlayerViewOffset change that moves the first-person weapon by WorldOffset.
// CalcDrawOffset's scale depends on FOVFix and screen size (469), so probe it
// instead of re-deriving it: the offset term is linear, X may scale apart
// from Y/Z (FOVFix 2).
simulated function vector IGPlus_WeaponViewOffsetFor(Weapon W, vector WorldOffset) {
	local vector SavedPVO, D0, DX, DY, LocalOffset, Result;

	SavedPVO = W.PlayerViewOffset;
	D0 = W.CalcDrawOffset();
	W.PlayerViewOffset = SavedPVO + vect(1,0,0);
	DX = (W.CalcDrawOffset() - D0) << ViewRotation;
	W.PlayerViewOffset = SavedPVO + vect(0,1,0);
	DY = (W.CalcDrawOffset() - D0) << ViewRotation;
	W.PlayerViewOffset = SavedPVO;

	if (Abs(DX.X) < 0.0001 || Abs(DY.Y) < 0.0001)
		return vect(0,0,0);

	LocalOffset = WorldOffset << ViewRotation;
	Result.X = LocalOffset.X / DX.X;
	Result.Y = LocalOffset.Y / DY.Y;
	Result.Z = LocalOffset.Z / DY.Y;
	return Result;
}

function ClientUpdatePosition()
{
	local IGPlus_SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;
	local rotator RealViewRotation, RealRotation;
	local EDodgeDir RealDodgeDir;
	local float RealDodgeClickTimer;

	local float AdjustDistance;
	local vector PostAdjustLocation;

	bUpdatePosition = false;
	realbRun = bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	RealRotation = Rotation;
	RealViewRotation = ViewRotation;
	RealDodgeDir = DodgeDir;
	RealDodgeClickTimer = DodgeClickTimer;
	bUpdating = true;

	IGPlus_FreeAcknowledgedMoves(CurrentTimeStamp);

	if (zzbFakeUpdate == false) {
		CurrentMove = IGPlus_SavedMove(SavedMoves);
		while (CurrentMove != none) {
			IGPlus_ClientReplayMove(CurrentMove);
			CurrentMove = IGPlus_SavedMove(CurrentMove.NextMove);
		}

		// stijn: The original code was not replaying the pending move
		// here. This was a huge oversight and caused non-stop resynchronizations
		// because the playerpawn position would be off constantly until the player
		// stopped moving!
		if (PendingMove != none) {
			IGPlus_ClientReplayMove(IGPlus_SavedMove(PendingMove));
		}

		// Replay redid predicted translocations: only a counter that still
		// differs means the shown and corrected states are a teleport apart.
		if (IGPlus_PredictsTranslocation())
			IGPlus_AdjustLocationOverride = (TlocCounter != IGPlus_PreAdjustTlocCounter);
		// A teleport: nothing of an earlier push is left to ease.
		if (IGPlus_AdjustLocationOverride)
			IGPlus_PushCamOffset = vect(0,0,0);

		if (IGPlus_InLiftExitWindow() && IGPlus_AdjustLocationOverride == false
			&& IGPlus_CameraCorrectionSnap == false
			&& VSize(IGPlus_PreAdjustLocation - Location) < 150.0
		) {
			// Just left a moving lift: what the prediction missed (all of it
			// from a lift going down) eases on the camera instead of a snap.
			IGPlus_AdjustLocationOffset = vect(0,0,0);
			IGPlus_AdjustLocationAlpha = 0;
			IGPlus_LiftExitCamOffset += IGPlus_PreAdjustLocation - Location;
		} else if (IGPlus_CAPPushed && IGPlus_PushEaseTakes(IGPlus_PushCamOffset + IGPlus_PreAdjustLocation - Location,
				IGPlus_AdjustLocationOverride || IGPlus_CameraCorrectionSnap,
				FastTrace(Location, IGPlus_PreAdjustLocation))
		) {
			// A push we couldn't predict (another player's hit), found out a
			// ping late: the simulation takes it now, the camera eases out
			// the jump, whatever the smoothing settings. The later corrections
			// of the same push add next to nothing, so it is one ease.
			if (VSize(IGPlus_PreAdjustLocation - Location) > 1.0)
				ClientDebugMessage("Push eased:"@int(VSize(IGPlus_PreAdjustLocation - Location))@"uu");
			IGPlus_AdjustLocationOffset = vect(0,0,0);
			IGPlus_AdjustLocationAlpha = 0;
			IGPlus_PushCamOffset += IGPlus_PreAdjustLocation - Location;
		} else if (Settings.bCameraCorrectionSmoothing) {
			// Keep the corrected simulation; only the camera eases toward it.
			IGPlus_AdjustLocationOffset = vect(0,0,0);
			IGPlus_AdjustLocationAlpha = 0;
			IGPlus_CameraCorrectionAdd(IGPlus_PreAdjustLocation - Location);
		} else {
			// Higor: evaluate location adjustment and see if we should either
			// - Discard it
			// - Negate and process over a certain amount of time.
			// - Keep adjustment as is (instant relocation)
			// Deaod: On second thought, lets never discard adjustments.
			IGPlus_AdjustLocationOffset = (Location - IGPlus_PreAdjustLocation);
			AdjustDistance = VSize(IGPlus_AdjustLocationOffset);
			IGPlus_AdjustLocationAlpha = 0;
			if ((AdjustDistance < 50) &&
				FastTrace(Location,IGPlus_PreAdjustLocation) &&
				IGPlus_AdjustLocationOverride == false
			) {
				// Undo adjustment and re-enact smoothly
				PostAdjustLocation = Location;
				MoveSmooth(-IGPlus_AdjustLocationOffset);
				IGPlus_AdjustLocationAlpha = FMax(0.1, PlayerReplicationInfo.Ping*0.001);
				IGPlus_AdjustLocationOffset = (PostAdjustLocation - Location) / IGPlus_AdjustLocationAlpha;
			} else {
				NetStatsElem.bInstantRelocation = true;
			}
		}
		// Only the update that came with a state change skips the eases. It
		// was cleared only by camera correction smoothing, so without that
		// setting the lift exit ease stayed off after the first such update.
		IGPlus_CameraCorrectionSnap = false;
	}
	IGPlus_CAPPushed = false;

	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
	SetRotation( RealRotation);
	ViewRotation = RealViewRotation;
	DodgeDir = RealDodgeDir;
	DodgeClickTimer = RealDodgeClickTimer;
	zzbFakeUpdate = true;

	UpdatePing();
}

function ClientUpdatePositionWithInput() {
	local IGPlus_SavedInput In;
	local bool bRealJump;
	local float AdjustDistance;
	local vector PostAdjustLocation;
	local rotator SavedViewRotation;

	local bool RealDodging;
	local EDodgeDir RealDodgeDir;
	local float RealDodgeClickTimer;

	// These variables may have been changed due to xxPureCAP forcing our State
	// to change. We need to preserve the new values, otherwise respawns will
	// desync.
	RealDodging = bDodging;
	RealDodgeDir = DodgeDir;
	RealDodgeClickTimer = DodgeClickTimer;

	bUpdatePosition = false;
	bRealJump = bPressedJump;
	bUpdating = true;

	IGPlus_SavedInputChain.RemoveOutdatedNodes(CurrentTimeStamp);
	if (zzbFakeUpdate == false) {
		SavedViewRotation = ViewRotation;

		In = IGPlus_SavedInputChain.Oldest;
		if (In != none) {
			debugClientLocError = VSize(In.SavedLocation - Location);
			clientForcedPosition = In.SavedVelocity - Velocity;
			while(In.Next != none) {
				PlayBackInput(In, In.Next);
				if (bTraceInput && IGPlus_InputLogFile != none)
					IGPlus_InputLogFile.LogInputReplay(In.Next);
				In = In.Next;
			}
		}

		ViewRotation = SavedViewRotation;

		// Higor: evaluate location adjustment and see if we should either
		// - Discard it
		// - Negate and process over a certain amount of time.
		// - Keep adjustment as is (instant relocation)
		// Deaod: Use exponential decay on offset instead
		IGPlus_AdjustLocationOffset = (Location - IGPlus_PreAdjustLocation);
		AdjustDistance = VSize(IGPlus_AdjustLocationOffset);
		if ((AdjustDistance < 50) &&
			FastTrace(Location,IGPlus_PreAdjustLocation) &&
			IGPlus_AdjustLocationOverride == false &&
			IsInState('Dying') == false
		) {
			// Undo adjustment and re-enact smoothly
			PostAdjustLocation = Location;
			MoveSmooth(-IGPlus_AdjustLocationOffset);
			if (AdjustDistance > 2) {
				IGPlus_AdjustLocationOffset = (PostAdjustLocation - Location);
			}
		} else {
			if (AdjustDistance >= 1.0) {
				NetStatsElem.bInstantRelocation = true;
			}
			IGPlus_AdjustLocationOffset = vect(0,0,0);
		}
	}

	bUpdating = false;
	bPressedJump = bRealJump;
	zzbFakeUpdate = true;

	bDodging = RealDodging;
	DodgeDir = RealDodgeDir;
	DodgeClickTimer = RealDodgeClickTimer;

	UpdatePing();
}

function UpdatePing() {
	local int CurrentSecond;

	CurrentSecond = int(Level.TimeSeconds);

	if (CurrentSecond != PingCurrentAveragingSecond) {
		PingCurrentAveragingSecond = CurrentSecond;
		PingAverage = int(1000 * PingRunningAverage / Level.TimeDilation);
		PingRunningAverage = Level.TimeSeconds - CurrentTimeStamp;
		PingRunningAverageCount = 1;
	} else {
		PingRunningAverage = (PingRunningAverage * PingRunningAverageCount) + (Level.TimeSeconds - CurrentTimeStamp);
		PingRunningAverageCount++;
		PingRunningAverage = PingRunningAverage / PingRunningAverageCount;
	}
}

// Precise Rewind Time report, one int on a move: bits 0-14 the tick of the
// update our screen showed, bit 15 set, bits 16-31 how far past it, in 0.1 ms.
static function int IGPlus_PRTPack(int Tick, float Age) {
	// (The top bit stays clear: it marks a tick position, IGPlus_TI_Pack.)
	return (Tick & 0x7FFF) | 0x8000 | (Clamp(int(Age * 10000.0), 0, 0x7FFF) << 16);
}
// Tick Interpolation: the tick position the screen drew at. 11 bits of the
// tick number, 8 bits of the way to the next tick, and the top bit as mark.
// Span, bits 11 to 14: the two updates the player was drawn between
// (IGPlus_TI_SpanAt). A client reads a player's update once per frame, so two
// updates in one frame, or a lost packet, leave a tick out of the updates it
// has, and it draws across the gap. The server then stands the player between
// the same two snapshots (UTPlusDummy.CompStartTick), not the two next to
// each other.
// bPast: the player was drawn past their newest update (carried on, or
// standing still). The server then has to do the same, and not use an update
// that reached us later.
// bHeld: and there they stood still, because the server said it holds them.
// Delay: how many ticks behind their newest update that player was drawn, in
// half ticks in bits 26 to 30. The server moves our new projectiles ahead by it.
static function int IGPlus_TI_Pack(float R, optional bool bPast, optional bool bHeld, optional float Delay, optional int Span) {
	local int T, D;

	if (R < 0.0)
		R = 0.0;
	T = int(R);
	D = (T & 0x7FF) | ((Span & 15) << 11) | 0x8000 | ((Clamp(int((R - float(T)) * 256.0), 0, 255)) << 16) | (1 << 31);
	if (bPast)
		D = D | (1 << 24);
	if (bPast && bHeld)
		D = D | (1 << 25);
	D = D | (Clamp(int(Delay * 2.0 + 0.5), 0, 31) << 26);
	return D;
}
// The server's reading of the delay, in ticks.
static function float IGPlus_TI_UnpackDelay(int Data) {
	return float((Data >>> 26) & 0x1F) * 0.5;
}
// The two updates a player was drawn between at tick position R, as one
// number: in the low 2 bits how many ticks before R's tick the older one is,
// in the next 2 bits how many ticks after the tick that follows R's the newer
// one is. 3 stands for 3 or more. 0 is the usual case: an update for R's tick
// and one for the next.
static function int IGPlus_TI_Span(int RTick, int TickA, int TickB) {
	return Clamp(RTick - TickA, 0, 3) | (Clamp(TickB - RTick - 1, 0, 3) << 2);
}
static function int IGPlus_TI_UnpackSpan(int Data) {
	return (Data >>> 11) & 15;
}
// How many ticks a player is carried on by their velocity, Past ticks after
// their newest update. None while the server holds them still (Adaptive
// Buffering, their queue ran empty): it says so, and a guess would have to be
// taken back when their next update comes. Client and server both use this.
// Two updates too far apart to be movement: a teleporter, a translocation or
// a respawn. The player is not drawn sliding from one to the other. They stay
// at the older one until the newer one's tick. Client and server both use this.
static function bool IGPlus_TI_IsJump(vector A, vector B, int Ticks, float TickLen) {
	return VSize(B - A) > 100.0 + 4000.0 * float(Ticks) * TickLen;
}
// A spot as a client gets it: in quarters of a unit. The engine sends a
// vector rounded to whole units (UStructProperty::NetSerializeItem) and takes
// no number over 65535, so the whole units go in IGPlus_NetLoc and the
// quarters in IGPlus_NetLocFrac. The client draws and tests a player between
// these spots, and the server tests a Tick Interpolation shot against the
// same rounded spots (UTPlusDummy.CompSwap). Tested against its exact spots,
// a shot that grazed a player by less than the rounding could go either way.
// Whole units alone left a walking player drawn unevenly: each spot was up to
// half a unit off, with a step of 2 to 3 units between two ticks.
static function vector IGPlus_TI_WireLoc(vector V) {
	V.X = class'Utilities'.static.Round(V.X * 4.0) / 4.0;
	V.Y = class'Utilities'.static.Round(V.Y * 4.0) / 4.0;
	V.Z = class'Utilities'.static.Round(V.Z * 4.0) / 4.0;
	return V;
}
// The whole units of a spot from IGPlus_TI_WireLoc, rounded down.
static function vector IGPlus_TI_LocWhole(vector V) {
	local vector W;

	W.X = float(int(V.X));
	if (W.X > V.X) W.X -= 1.0;
	W.Y = float(int(V.Y));
	if (W.Y > V.Y) W.Y -= 1.0;
	W.Z = float(int(V.Z));
	if (W.Z > V.Z) W.Z -= 1.0;
	return W;
}
// The quarters on top of them: 2 bits for X, 2 for Y, 2 for Z.
static function byte IGPlus_TI_LocFrac(vector V) {
	local vector W;

	W = IGPlus_TI_LocWhole(V);
	return byte((int((V.X - W.X) * 4.0 + 0.5) & 3)
		| ((int((V.Y - W.Y) * 4.0 + 0.5) & 3) << 2)
		| ((int((V.Z - W.Z) * 4.0 + 0.5) & 3) << 4));
}
// The spot back from the two.
static function vector IGPlus_TI_LocJoin(vector Whole, byte Frac) {
	Whole.X += float(Frac & 3) * 0.25;
	Whole.Y += float((Frac >> 2) & 3) * 0.25;
	Whole.Z += float((Frac >> 4) & 3) * 0.25;
	return Whole;
}
static function float IGPlus_TI_CarryTicks(float Past, bool bHeld) {
	if (bHeld || Past <= 0.0)
		return 0.0;
	return FMin(Past, IGPLUS_TI_MAX_CARRY);
}
// The tick clock of a client while it is held (IGPlus_TI_bRecv): how far it
// moves in a frame on top of its own running. Gap: how many ticks the newest
// tick number is ahead of it. MinGap: the least it was ahead in the last
// seconds. Step: the ticks this frame took.
// Behind the newest tick number is where it is meant to be: it stays there,
// and only what the last seconds never needed is given back, slowly. Over the
// most it holds it catches up, faster. Ahead of the newest tick number it
// falls back as the clock always did: a late update needs more than was held.
static function float IGPlus_TI_HeldMove(float Gap, float MinGap, float Step) {
	if (Gap < -IGPLUS_TI_RECV_SNAP)
		return Gap;
	if (Gap < 0.0)
		return Gap * 0.1;
	// Never more than the most it holds: the server takes a shot's report
	// only up to that age (IGPlus_PRTNoteInterp). The pace of each player
	// drawn (IGPlus_TI_Pace) takes a step of a few ticks without a jump.
	if (Gap > IGPLUS_TI_RECV_MAX)
		return Gap - IGPLUS_TI_RECV_MAX;
	return FClamp(FMin(MinGap, Gap), 0.0, IGPLUS_TI_RECV_GIVE * Step);
}
// A move time as IGPlus_NetMoveT carries it.
static function byte IGPlus_TI_MoveByte(float TS) {
	return byte(int(TS / IGPLUS_TI_MT_UNIT) & 255);
}
// The move time between two updates, from their two bytes. The byte comes
// round every 128 ms, so the count of whole rounds is the one that brings the
// result nearest to Expected, the time their tick numbers are apart.
static function float IGPlus_TI_MoveDelta(byte Older, byte Newer, float Expected) {
	local float D;

	D = float((int(Newer) - int(Older)) & 255) * IGPLUS_TI_MT_UNIT;
	return FMax(0.0, D + IGPLUS_TI_MT_WRAP * class'Utilities'.static.Round((Expected - D) / IGPLUS_TI_MT_WRAP));
}
// The server's reading of it. NowTick is the server's newest tick number.
static function float IGPlus_TI_Unpack(int Data, int NowTick) {
	return float(NowTick - ((NowTick - (Data & 0x7FF)) & 0x7FF)) + float((Data >>> 16) & 0xFF) / 256.0;
}

// How many of our ticks ago the report's update was sent (the newest tick
// with those low bits). 0x7FFF-ish for a tick we haven't sent yet.
static function int IGPlus_PRTTicksBack(int ServerTick, int Data) {
	return (ServerTick - (Data & 0x7FFF)) & 0x7FFF;
}

static function float IGPlus_PRTAge(int Data) {
	return 0.0001 * (Data >>> 16);
}

// Precise Rewind Time: a move's report of what its shots saw, checked
// against our own clock and ping. A failed check leaves its shots on the
// average-ping rewind. Reason says why.
function IGPlus_PRTNote(int Data) {
	local WeaponSettingsRepl WS;
	local int Back;

	WS = GetWeaponSettings();
	IGPlus_bPRTInterp = false;
	if (Data < 0 && IGPlus_EnableTickInterp && zzUTPure != None) {
		IGPlus_PRTNoteInterp(Data, WS);
		return;
	}
	// We keep the times of our last 128 ticks.
	Back = IGPlus_PRTTicksBack(IGPlus_PRTServerTick, Data);
	IGPlus_PRTNoteTS = Level.TimeSeconds;
	IGPlus_PRTNoteTick = IGPlus_PRTServerTick;
	IGPlus_PRTSeenTime = IGPlus_PRTTickTime[(IGPlus_PRTServerTick - Back) & 127];
	IGPlus_PRTViewTime = IGPlus_PRTSeenTime + IGPlus_PRTAge(Data);
	IGPlus_PRTLagMs = 1000.0 * (Level.TimeSeconds - IGPlus_PRTViewTime) / Level.TimeDilation;
	IGPlus_PRTReason = "";
	if (WS == none || WS.bEnablePingCompensation == false)
		IGPlus_PRTReason = "off";
	else if (IGPlus_EnableSnapshotInterpolation)
		IGPlus_PRTReason = "snapshot interpolation";
	else if (Back >= 128 || IGPlus_PRTSeenTime <= 0)
		IGPlus_PRTReason = "update too old";
	// On a LAN a frame can reach us before our next tick, and a shot's report
	// is later by one client frame when the engine had moved its target on
	// already (IGPlus_PRTShotTargetLead): up to 50 ms ahead is fine.
	else if (IGPlus_PRTLagMs < -50)
		IGPlus_PRTReason = "report ahead of our clock";
	else if (IGPlus_PRTLagMs > WS.PingCompensationMax + IGPlus_RewindExtraMs(1.0))
		IGPlus_PRTReason = "above PingCompensationMax";
	// (A queued move ran IGPlus_ABDelayMs after it arrived, Adaptive
	// Buffering: the report is that much older than our ping.)
	// Older than our ping says by more than the deviation: more rewind than
	// the line can explain. Younger: checked against the lowest of our last
	// readings, as a moment of lag raises the readings after it for a while
	// while the player's screen is current again. A younger picture gives
	// a shot nothing.
	else if (IGPlus_PRTServerPing > 0
		&& (IGPlus_PRTLagMs > IGPlus_PRTServerPing + IGPlus_ABDelayMs + WS.PreciseRewindTimeMaxDeviationMs
			|| IGPlus_PRTLagMs < IGPlus_PingLowMs() + IGPlus_ABDelayMs - WS.PreciseRewindTimeMaxDeviationMs))
		IGPlus_PRTReason = "server ping"@int(IGPlus_PRTServerPing)@"ms";
	IGPlus_PRTLagMs = FMax(0, IGPlus_PRTLagMs);
}

// Server: PingCompensationMax holds the shooter's ping. What our own features
// add on top of that ping goes on top of the cap as well: the delay Adaptive
// Buffering queued the shooter's moves by (ABShare of it, 1 for a rewind of
// the whole way and 0.5 for a projectile's one way), and the delay Tick
// Interpolation drew players with, at most IGPLUS_REWIND_TI_EXTRA_MS so a
// server with slow ticks stays bounded. Counted against the cap, a player
// under it was refused with these features on: at 155 ping and a cap of 200,
// every report on a CTF test server.
function float IGPlus_RewindExtraMs(float ABShare) {
	local float Ms;

	Ms = ABShare * float(IGPlus_ABDelayMs);
	if (IGPlus_EnableTickInterp && IGPlus_bPRTInterp)
		Ms += FClamp(IGPlus_PRTInterpDelayMs, 0.0, IGPLUS_REWIND_TI_EXTRA_MS);
	return Ms;
}

// Server, Tick Interpolation: the report is the tick position the shooter's
// screen drew the shot's target at.
function IGPlus_PRTNoteInterp(int Data, WeaponSettingsRepl WS) {
	local int G;
	local float TickLen, MaxLag;

	G = zzUTPure.IGPlus_GlobalTick;
	TickLen = FMax(AverageServerDeltaTime, 0.001);
	IGPlus_bPRTInterp = true;
	IGPlus_bPRTInterpPast = (Data & (1 << 24)) != 0;
	IGPlus_bPRTInterpHeld = (Data & (1 << 25)) != 0;
	IGPlus_PRTInterpR = IGPlus_TI_Unpack(Data, G);
	IGPlus_PRTInterpSpan = IGPlus_TI_UnpackSpan(Data);
	IGPlus_PRTInterpDelayMs = 1000.0 * FMin(IGPlus_TI_UnpackDelay(Data), IGPLUS_TI_MAX_DELAY) * TickLen / Level.TimeDilation;
	IGPlus_PRTNoteTS = Level.TimeSeconds;
	IGPlus_PRTNoteTick = IGPlus_PRTServerTick;
	IGPlus_PRTSeenTime = Level.TimeSeconds - (float(G) - IGPlus_PRTInterpR) * TickLen;
	IGPlus_PRTViewTime = IGPlus_PRTSeenTime;
	IGPlus_PRTLagMs = 1000.0 * (float(G) - IGPlus_PRTInterpR) * TickLen / Level.TimeDilation;
	IGPlus_PRTReason = "";
	// The screen is our ping behind, plus the delay it draws a player with.
	MaxLag = IGPlus_PRTServerPing + 1000.0 * (IGPLUS_TI_MAX_DELAY + 2.0) * TickLen / Level.TimeDilation;
	if (WS == none || WS.bEnablePingCompensation == false)
		IGPlus_PRTReason = "off";
	else if (float(G) - IGPlus_PRTInterpR > 1000.0)
		IGPlus_PRTReason = "update too old";
	else if (IGPlus_PRTLagMs < -50)
		IGPlus_PRTReason = "report ahead of our clock";
	else if (IGPlus_PRTLagMs > WS.PingCompensationMax + IGPlus_RewindExtraMs(1.0))
		IGPlus_PRTReason = "above PingCompensationMax";
	// (Younger: against the lowest of our last readings, see IGPlus_PRTNote.)
	else if (IGPlus_PRTServerPing > 0
		&& (IGPlus_PRTLagMs < IGPlus_PingLowMs() + IGPlus_ABDelayMs - WS.PreciseRewindTimeMaxDeviationMs
			|| IGPlus_PRTLagMs > MaxLag + IGPlus_ABDelayMs + WS.PreciseRewindTimeMaxDeviationMs))
		IGPlus_PRTReason = "server ping"@int(IGPlus_PRTServerPing)@"ms";
	IGPlus_PRTLagMs = FMax(0, IGPlus_PRTLagMs);
}

// A report from a move this tick. Shots traced later in the tick than the
// moves arrive (minigun, pulse beam, enforcer refire) use it too.
function bool IGPlus_PRTFresh() {
	return IGPlus_PRTNoteTS > 0 && IGPlus_PRTServerTick - IGPlus_PRTNoteTick <= 1
		&& Level.TimeSeconds - IGPlus_PRTNoteTS < 0.1;
}

// Does a hitscan shot now use Precise Rewind Time? Only with a fresh,
// checked report.
function bool IGPlus_PRTUsable() {
	return IGPlus_PRTFresh() && IGPlus_PRTReason == "";
}

// Server: we took the report of a move with time stamp TS while our
// deterministic disc flies. The report shows the frame before the move's, and
// our client's disc there had flown TS minus the throw's time stamp (it flies
// in the frame of the throw too), as for its shots at it (ST_Translocator.IGPlus_DetSeenAge).
// It meets the other players in that picture, on the path it flew on our
// screen up to that frame (ST_TranslocatorTarget.IGPlus_DetReportSweep).
function IGPlus_DetReportSweep(float TS) {
	local ST_Translocator TL;

	if (IGPlus_DetTranslocator == false || IGPlus_PRTUsable() == false)
		return;
	TL = ST_Translocator(FindInventoryType(class'ST_Translocator'));
	if (TL != None && ST_TranslocatorTarget(TL.TTarget) != None && TL.TTarget.bDeleteMe == false)
		ST_TranslocatorTarget(TL.TTarget).IGPlus_DetReportSweep(TS - TL.IGPlus_ThrowTS);
}

// The report's view time for a shot traced now: as far past it as the
// tick has run since the report arrived (the rewind stays the same).
function float IGPlus_PRTViewTimeNow() {
	return IGPlus_PRTViewTime + (Level.TimeSeconds - IGPlus_PRTNoteTS);
}

function TakeFallingDamage()
{
	if (Velocity.Z < -1.4 * JumpZ)
	{
		if (JumpZ != 0)
			MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
		if (Velocity.Z <= -750 - JumpZ)
		{
			if ( (Velocity.Z < -1650 - JumpZ) && (ReducedDamageType != 'All') )
				TakeDamage(1000, None, Location, vect(0,0,0), 'Fell');
			else if ( Role == ROLE_Authority )
				TakeDamage(-0.15 * (Velocity.Z + 700 + JumpZ), None, Location, vect(0,0,0), 'Fell');
			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
		}
	}
	else if ( Velocity.Z > 0.5 * Default.JumpZ )
		MakeNoise(0.35);
}

// The switch execs run server-side only and PendingWeapon never replicates,
// so during a deferred holster the client's sole switch notification (stock
// ClientPutDown from DownWeapon.BeginState) arrives after the deferral —
// leaving the client predicting fire from a weapon the server is holstering.
// Tell the owning client immediately: block prediction until the flip-gate
// takes over.
// GuardSecs must cover only the holster hold plus the standard pulse.
// IGPlus_DetClientSwitchPending blocks readiness for the rest of the
// transition and the replicated entry gate covers bring-up; a guard that
// outlasts the incoming weapon's down+select over-gates its first shot past
// master timing. Never write stock ClientPending here: the server has not
// started the holster yet and stock client states would holster on their own.
simulated function xxClientSwitchPending(Weapon PendW, float GuardSecs) {
	if (Role == ROLE_Authority && Level.NetMode != NM_Standalone)
		return;
	// Our predicted switch owns the pending state until its equip point.
	if (IGPlus_PSRunning())
		return;
	if (PendW == Weapon)
		IGPlus_DetClientSwitchPending = none; // switch cancelled back to equipped
	else
		IGPlus_DetClientSwitchPending = PendW;
	IGPlus_MarkDeterministicSwitchGuard(GuardSecs);
}

function xxSetPendingWeapon(Weapon W)
{
	PendingWeapon = W;
}

/**
 * Corrects velocity after going through Teleporters
 */
function CorrectTeleporterVelocity() {
	local rotator Delta;
	local Teleporter T;
	local float Dist;
	local Teleporter Best;
	local float MinDist;

	if (IGPlus_TPFix_LastTouched != none &&
		(
			IGPlus_TPFix_LastTouched.Class == class'Teleporter' ||
			IGPlus_TPFix_LastTouched.Class == class'VisibleTeleporter'
		)
	) {
		// only deal with base game teleporters
		// other classes might do weird custom stuff

		// find destination
		foreach AllActors(class'Teleporter', T) {
			if (string(T.Tag) ~= IGPlus_TPFix_URL) {
				if (Best == none) {
					Best = T;
					MinDist = VSize(T.Location - Location);
				} else {
					Dist = VSize(T.Location - Location);
					if (Dist < MinDist) {
						MinDist = Dist;
						Best = T;
					}
				}
			}
		}

		if (Best == none) {
			if (Level.NetMode == NM_Client) {
				ClientMessage("Teleporter target could not be determined (bNoDelete not set to True?)");
			} else {
				ClientMessage("No teleporter found with tag '"$IGPlus_TPFix_URL$"'");
			}
			return;
		}

		Best.Disable('Touch');
		MoveSmooth(vect(0,0,1)*IGPlus_TPFix_OffsetZ);
		Best.Enable('Touch');

		if (Best.bChangesVelocity) {
			Velocity = Best.TargetVelocity;
		} else {
			Delta = rotator(IGPlus_TPFix_Velocity) - IGPlus_TPFix_Rotation;
			// Teleporter doesnt change velocity, so we can do it ourselves
			Velocity = vector(Rotation+Delta) * VSize(IGPlus_TPFix_Velocity*vect(1,1,0)) * vect(1,1,0);
			Velocity.Z = IGPlus_TPFix_Velocity.Z;
		}
	}
}

function IGPlus_MoveAutonomous(
	float DeltaTime,
	bool NewbRun,
	bool NewbDuck,
	bool NewbPressedJump,
	eDodgeDir DodgeMove,
	vector newAccel,
	rotator DeltaRot
) {
	IGPlus_TPFix_LastTouched = none;
	MoveAutonomous(DeltaTime, NewbRun, NewbDuck, NewbPressedJump, DodgeMove, newAccel, DeltaRot);
	CorrectTeleporterVelocity();
}

function bool IGPlus_IsFlagCarrier() {
	local CTFFlag F;

	if (PlayerReplicationInfo == none)
		return false;

	F = CTFFlag(PlayerReplicationInfo.HasFlag);

	return F != none && F.Holder == self;
}

function bool IGPlus_ShouldJitterBound() {
	if (zzUTPure == none || zzUTPure.Settings == none)
		return false;
	// Adaptive Buffering replaces jitter bounding.
	if (zzUTPure.Settings.AdaptiveBufferingActive())
		return false;

	switch (zzUTPure.Settings.JitterBoundingMode) {
		case JB_All:         return true;
		case JB_CarrierOnly: return IGPlus_IsFlagCarrier();
	}

	return false;
}

/**
 * Splits a large DeltaTime into chunks reasonable enough for MoveAutonomous,
 * so players dont warp through walls
 */
function SimMoveAutonomous(float DeltaTime) {
	local int SimSteps;
	local float SimTime;

	SimSteps = Max(1, int(DeltaTime / AverageServerDeltaTime)); // handle (DeltaTime < AverageServerDeltaTime)
	SimTime = DeltaTime / SimSteps;
	while(SimSteps > 0) {
		IGPlus_MoveAutonomous(SimTime, bRun>0, bDuck>0, false, DODGE_None, Acceleration, rot(0,0,0));
		SimSteps--;
	}
}

function WarpCompensation(float DeltaTime) {
	if (Level.Pauser == "" && !bWasPaused) {
		ExtrapolationDelta *= Exp(-2.0 * DeltaTime);
	} else {
		bWasPaused = true;
	}
}

function ClearLastServerMoveParams() {
	bHaveReceivedServerMove = false;
	LastServerMoveParams.Location = vect(0.0, 0.0, 0.0);
	LastServerMoveParams.Physics = PHYS_None;
	LastServerMoveParams.Base = none;
	LastServerMoveParams.TlocCounter = 0;
}

function IGPlus_ProcessRemoteMovement() {
	if (IGPlus_EnableInputReplication)
		IGPlus_AcknowledgeInput();
	else
		IGPlus_CheckClientError();

	IGPlus_SkipMovesUntilNextTick = false;

	if (((ServerTimeStamp - LastCAPTime) / Level.TimeDilation) > IGPLUS_FAKE_CAP_INTERVAL) {
		xxFakeCAP(CurrentTimeStamp);
		LastCAPTime = ServerTimeStamp;
	}
}

simulated function float GetMoverFireZOffset(optional bool bFullPing) {
	local float Latency;
	local float TargetTimeStamp;
	local ST_MoverDummy MD;
	local vector HistoricalLoc;
	local float Lead;

	if (Mover(Base) == None || PlayerReplicationInfo == None)
		return 0.0;
	if (bFullPing == false)
		Lead = IGPlus_ClientLiftLeadZ();

	if (bFullPing)
		Latency = PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation;
	else // one way: plus the other half of the Adaptive Buffering delay
		Latency = (PlayerReplicationInfo.Ping + IGPlus_ABDelayMs) * 0.0005 * Level.TimeDilation;

	if (zzUTPure != None) {
		MD = zzUTPure.FindMoverDummy(Mover(Base));
		if (MD != None) {
			TargetTimeStamp = Level.TimeSeconds - Latency;
			HistoricalLoc = MD.GetHistoricalLocation(TargetTimeStamp);
			ClientDebugMessage("MoverZOffset: history="$int(Base.Location.Z - HistoricalLoc.Z)$" linear="$int(Base.Velocity.Z * Latency)$" ping="$PlayerReplicationInfo.Ping$" velZ="$int(Base.Velocity.Z));
			return Base.Location.Z - HistoricalLoc.Z + Lead;
		}
	}

	ClientDebugMessage("MoverZOffset: fallback linear="$int(Base.Velocity.Z * Latency)$" lift lead="$int(Lead)$" ping="$PlayerReplicationInfo.Ping);
	return Base.Velocity.Z * Latency + Lead;
}

// Client: how much higher the server has us on a moving lift, a round trip
// of its travel (IGPlus_LiftAhead). The server fires projectiles from there,
// so our own copies start there too and fly the server's path.
simulated function float IGPlus_ClientLiftLeadZ() {
	local vector Lead, VelLead;

	if (Level.NetMode == NM_Client && IGPlus_OnMovingLift()
		&& IGPlus_LiftAhead(Mover(Base), float(PingAverage) * 0.001 * Level.TimeDilation, Lead, VelLead))
		return Lead.Z;
	return 0.0;
}

// Server: how far our lift is ahead along its path of where our client's
// screen has it for the move being processed. The client sees the lift a
// one-way late and its moves arrive a one-way late: a round trip of travel
// (measured 40-90uu on a fast lift). Zero off a lift or on a resting one.
function vector IGPlus_OwnLiftLead() {
	local ST_MoverDummy MD;

	if (Mover(Base) == None || zzUTPure == None || IGPlus_OwnLiftLagMs() <= 0)
		return vect(0,0,0);
	MD = zzUTPure.FindMoverDummy(Mover(Base));
	if (MD == None)
		return vect(0,0,0);
	return Base.Location - MD.GetHistoricalLocation(Level.TimeSeconds - float(IGPlus_OwnLiftLagMs()) * 0.001 * Level.TimeDilation);
}

// Server, Push-Safe Aim: on a moving lift our projectile shots leave from
// where our screen has us, this far behind (IGPlus_LiftShot). Zero otherwise.
function vector IGPlus_LiftAimLead() {
	local vector Lead;

	if (IGPlus_PushSafeAim == false || GetWeaponSettings() == None || GetWeaponSettings().bEnablePingCompensation == false)
		return vect(0,0,0);
	Lead = IGPlus_OwnLiftLead();
	if (VSize(Lead) <= 2.0)
		return vect(0,0,0);
	return Lead;
}

// Server: how long ago our screen's lift was where it is now, capped like the
// rest of ping compensation.
function int IGPlus_OwnLiftLagMs() {
	return Min(PingAverage, GetWeaponSettings().PingCompensationMax);
}

// Where Start->End first meets Lift, nothing else counted. Our lift where our
// screen has it is the real one moved back by its lead: a shot moved forward
// by the lead meets the real one at the same spots. The real lift is never
// moved for this: a rider set down on it again restarts a waiting lift.
simulated function bool IGPlus_TraceMover(Mover Lift, vector Start, vector End, out vector HitLoc, out vector HitNormal, optional vector Extent) {
	local Actor A;

	foreach TraceActors(class'Actor', A, HitLoc, HitNormal, End, Start, Extent)
		if (A == Lift)
			return true;
	return false;
}

// Debug (enableDebugData): where a projectile shot starts, on each side.
simulated function IGPlus_DebugProjStart(string What, vector Start) {
	local string Side;

	if (bDrawDebugData == false)
		return;
	Side = "server";
	if (Level.NetMode == NM_Client)
		Side = "client";
	ClientDebugMessage(What$" ("$Side$") from "$class'ST_ShockProj'.static.IGPlus_Vec(Start)
		$" lift lead "$int(IGPlus_DebugLiftLead().Z));
}

simulated function vector IGPlus_DebugLiftLead() {
	if (Level.NetMode == NM_Client)
		return vect(0,0,0);
	return IGPlus_OwnLiftLead();
}

// Client: on a lift that is moving here. The server's test of our own beam
// against our own ball allows for the lift (ST_ShockProj.IGPlus_OwnerSeesBall),
// but only roughly while it moves, so no combo is drawn early then.
simulated function bool IGPlus_OnMovingLift() {
	return Mover(Base) != None && Base.Velocity != vect(0,0,0);
}

// Client-side shock balls on our own timeline, with predicted combos
// (ST_ShockProj); off is the old client-side animation.
simulated function bool IGPlus_PredictiveShockCombos() {
	return ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations
		&& ClientWeaponSettingsData.bPredictiveShockCombos;
}

// --- Predicted rocket self-knockback -----------------------------------------

simulated function IGPlus_SKQueueAdd(
	float TargetTS,
	int RocketIndex,
	vector HitLocation,
	vector SourceLocation,
	float SourceRadius,
	float Radius,
	float Momentum,
	bool bEnhanced,
	bool bHasFallback,
	vector FallbackPush,
	optional byte Kind,
	optional bool bDiscOnly
) {
	local int i, j;

	// Pushes due in the same move apply in (TargetTS, RocketIndex) order on
	// both machines; sequential AddVelocity is order-sensitive.
	if (IGPlus_SKQueueCount >= arraycount(IGPlus_SKQueue))
		IGPlus_SKQueueCount = arraycount(IGPlus_SKQueue) - 1; // drop the latest-due entry

	for (i = 0; i < IGPlus_SKQueueCount; i++)
		if (TargetTS < IGPlus_SKQueue[i].TargetTS
			|| (TargetTS == IGPlus_SKQueue[i].TargetTS && RocketIndex < IGPlus_SKQueue[i].RocketIndex))
			break;

	for (j = IGPlus_SKQueueCount; j > i; j--)
		IGPlus_SKQueue[j] = IGPlus_SKQueue[j - 1];

	IGPlus_SKQueue[i].TargetTS = TargetTS;
	IGPlus_SKQueue[i].RocketIndex = RocketIndex;
	IGPlus_SKQueue[i].HitLocation = HitLocation;
	IGPlus_SKQueue[i].SourceLocation = SourceLocation;
	IGPlus_SKQueue[i].SourceRadius = SourceRadius;
	IGPlus_SKQueue[i].Radius = Radius;
	IGPlus_SKQueue[i].Momentum = Momentum;
	IGPlus_SKQueue[i].bEnhanced = bEnhanced;
	IGPlus_SKQueue[i].bHasFallback = bHasFallback;
	IGPlus_SKQueue[i].FallbackPush = FallbackPush;
	IGPlus_SKQueue[i].Kind = Kind;
	IGPlus_SKQueue[i].bDiscOnly = bDiscOnly;
	IGPlus_SKQueueCount++;
}

// Own-rocket push on this pawn at its current location: the instigator case
// of EnhancedHurtRadius / HurtRadiusWithSelfDamage, then TakeDamage's self
// scaling. False when the server's wraparound (blocked line) path would decide.
simulated function bool IGPlus_SKCompute(IGPlus_SelfKnockback K, out vector Push) {
	// The hammer pushes us directly (already scaled).
	if (K.Kind == IGPLUS_SK_HAMMER) {
		Push = K.FallbackPush;
		return true;
	}
	if (IGPlus_SKSplash(K, Location, CollisionRadius, CollisionHeight, Push) == false)
		return false;

	// TakeDamage: own momentum is scaled by 0.6, then divided by mass.
	Push *= 0.6;
	if (Mass != 0)
		Push = Push / Mass;
	return true;
}

// The momentum an own explosion gives a cylinder of radius R, half height H
// at Loc: EnhancedHurtRadius / HurtRadiusWithSelfDamage (and stock
// HurtRadius), before the victim's TakeDamage. Zero out of reach. False when
// the line from the explosion is blocked: the server's wraparound path
// decides then, for pawns only.
simulated function bool IGPlus_SKSplash(IGPlus_SelfKnockback K, vector Loc, float R, float H, out vector Push) {
	local vector Delta, DeltaXY, Closest, Dir, MomentumDelta;
	local float Dist, DamageScale, MomentumScale;

	Push = vect(0,0,0);
	Delta = Loc - K.HitLocation;
	DeltaXY = Delta * vect(1,1,0);

	if (K.bEnhanced) {
		// CollChecker (cylinder of Radius at HitLocation) must touch it.
		if (Abs(Delta.Z) > H + K.Radius || VSize(DeltaXY) > R + K.Radius)
			return true;

		Dir = Normal(Delta);
		if (Abs(Delta.Z) <= H) {
			Closest = K.HitLocation + Normal(DeltaXY) * (VSize(DeltaXY) - R);
		} else if (VSize(DeltaXY) <= R) {
			if (Delta.Z > 0.0)
				Closest = K.HitLocation + FMax(Delta.Z - H, 0.0) * vect(0,0,1);
			else
				Closest = K.HitLocation + FMin(Delta.Z + H, 0.0) * vect(0,0,1);
		} else {
			// Same as EnhancedHurtRadius (uses the source's radius here).
			Closest = Loc + Dir * (K.SourceRadius / VSize(Dir * vect(1,1,0)));
			if (Delta.Z > 0.0)
				Closest.Z = Loc.Z - H;
			else
				Closest.Z = Loc.Z + H;
		}

		Dist = VSize(Closest - K.HitLocation);
		if (Dist > K.Radius)
			return true;

		// In sight of the blast, or of the spot 16 uu above it when that spot
		// is open (EnhancedHurtRadius, SightOrigin).
		if (FastTrace(Loc, K.SourceLocation) == false && (
			FastTrace(K.SourceLocation + vect(0,0,16), K.SourceLocation) == false ||
			FastTrace(Loc, K.SourceLocation + vect(0,0,16)) == false))
			return false;

		MomentumDelta = Loc - K.HitLocation;
		// The server's damage scale is this same push scale: no push at 0.
		MomentumScale = FClamp(1.0 - (VSize(MomentumDelta) - R) / K.Radius, 0.0, 1.0);
		Dir = Normal(MomentumDelta);
		// The ripper's alt pushes no steeper than 0.45 up (Razor2Alt.BlowUp).
		if (K.Kind == IGPLUS_SK_RIPPERALT)
			Dir.Z = FMin(0.45, Dir.Z);
		Push = MomentumScale * K.Momentum * Dir;
	} else {
		// VisibleCollidingActors: the cylinder within Radius, and visible from
		// HitLocation.
		if (VSize(Delta) >= K.Radius + R || FastTrace(Loc, K.HitLocation) == false)
			return true;

		Dist = FMax(1, VSize(Delta));
		DamageScale = 1.0 - FMax(0, (Dist - R) / K.Radius);
		if (DamageScale <= 0.0)
			return true;
		Dir = Delta / Dist;
		if (K.Kind == IGPLUS_SK_RIPPERALT)
			Dir.Z = FMin(0.45, Dir.Z);
		Push = DamageScale * K.Momentum * Dir;
	}
	return true;
}

// ServerAddMomentum followed by Pawn.AddVelocity.
simulated function IGPlus_SKAddVelocity(vector Push) {
	if (Push == vect(0,0,0))
		return;

	if (Physics == PHYS_Walking) {
		Push.Z = FMax(Push.Z, 0.4 * VSize(Push));
		SetPhysics(PHYS_Falling);
	}
	if ((Velocity.Z > 380) && (Push.Z > 0))
		Push.Z *= 0.5;
	Velocity += Push;
}

// Applies every push due at or before TS. On the client, Move records them for
// replay. Returns true if any push was applied.
simulated function bool IGPlus_SKApplyDue(float TS, IGPlus_SavedMove Move) {
	local int i;
	local vector Push, DiscPush;
	local bool bApplied;
	local byte DiscKind;

	while (IGPlus_SKQueueCount > 0 && IGPlus_SKQueue[0].TargetTS <= TS) {
		// ponytail: 0.25s staleness drop covers death/respawn; a move gap that
		// long just costs a correction
		if (IGPlus_SKQueue[0].TargetTS >= TS - 0.25 && IGPlus_SKQueue[0].bDiscOnly == false) {
			if (IGPlus_SKCompute(IGPlus_SKQueue[0], Push) == false) {
				if (IGPlus_SKQueue[0].bHasFallback)
					Push = IGPlus_SKQueue[0].FallbackPush;
				else
					Push = vect(0,0,0);
			}

			if (Push != vect(0,0,0)) {
				IGPlus_SKDebug("lands on move "$TS, IGPlus_SKQueue[0], Push);
				IGPlus_SKAddVelocity(Push);
				bApplied = true;
				// Replays recompute it from the replayed position.
				if (Move != none && Move.IGPlus_SKPushCount < arraycount(Move.IGPlus_SKHit)) {
					Move.IGPlus_SKHit[Move.IGPlus_SKPushCount] = IGPlus_SKQueue[0].HitLocation;
					Move.IGPlus_SKKind[Move.IGPlus_SKPushCount] = IGPlus_SKQueue[0].Kind;
					Move.IGPlus_SKPush[Move.IGPlus_SKPushCount] = Push;
					Move.IGPlus_SKPushCount++;
				}
			}
		}
		// Our own disc, on the same move (its explosion's push was kept back
		// for this, IGPlus_SKDefersDisc). Not one from before a death.
		if (IGPlus_SKQueue[0].TargetTS >= TS - 0.25
			&& IGPlus_SKOwnDiscPush(IGPlus_SKQueue[0], Push) && VSize(Push) > VSize(DiscPush)) {
			DiscPush = Push;
			DiscKind = IGPlus_SKQueue[0].Kind;
		}

		for (i = 1; i < IGPlus_SKQueueCount; i++)
			IGPlus_SKQueue[i - 1] = IGPlus_SKQueue[i];
		IGPlus_SKQueueCount--;
	}

	// A push sets the disc's speed, it doesn't add to it: of several due on
	// one move, one counts. A rocket volley's land microseconds apart, in a
	// different order on each machine. The strongest is the same on both.
	if (DiscPush != vect(0,0,0) && IGPlus_SKApplyOwnDiscPush(DiscPush, IGPlus_SKKindName(DiscKind)))
		bApplied = true;

	return bApplied;
}

// Server: around an own rocket's splash damage.
function IGPlus_SKBeginCapture() {
	IGPlus_SKCapturing = true;
	IGPlus_SKCapturedHit = false;
	IGPlus_SKCaptured = vect(0,0,0);
}

function IGPlus_SKEndCapture(
	float TargetTS,
	int RocketIndex,
	vector HitLocation,
	vector SourceLocation,
	float SourceRadius,
	float Radius,
	float Momentum,
	bool bEnhanced,
	optional byte Kind
) {
	local IGPlus_SelfKnockback K;
	local vector Push;

	IGPlus_SKCapturing = false;

	// A DamageMutator changed our push: the client can't predict that, so
	// keep the stock timing.
	if (IGPlus_SKCapturedHit) {
		K.HitLocation = HitLocation;
		K.SourceLocation = SourceLocation;
		K.SourceRadius = SourceRadius;
		K.Radius = Radius;
		K.Momentum = Momentum;
		K.bEnhanced = bEnhanced;
		K.Kind = Kind;
		if (IGPlus_SKCompute(K, Push) && VSize(Push - IGPlus_SKCaptured) > 1.0) {
			IGPlus_SKDebug("changed by a mod, stock timing, worked out "$class'ST_ShockProj'.static.IGPlus_Vec(Push), K, IGPlus_SKCaptured);
			ServerAddMomentum(IGPlus_SKCaptured);
			// Our disc's push still waits for our moves (IGPlus_SKDefersDisc).
			IGPlus_SKQueueAdd(FMax(TargetTS, CurrentTimeStamp), RocketIndex, HitLocation, SourceLocation,
				SourceRadius, Radius, Momentum, bEnhanced, false, vect(0,0,0), Kind, true);
			return;
		}
	}
	K.TargetTS = FMax(TargetTS, CurrentTimeStamp);
	K.HitLocation = HitLocation;
	K.Kind = Kind;
	IGPlus_SKDebug("queued", K, IGPlus_SKCaptured);

	// Explosions past their time (move gaps) land on the next move.
	IGPlus_SKQueueAdd(
		FMax(TargetTS, CurrentTimeStamp),
		RocketIndex, HitLocation, SourceLocation, SourceRadius, Radius, Momentum, bEnhanced,
		IGPlus_SKCapturedHit, IGPlus_SKCaptured, Kind);
}

// Client: can our own shots' pushes be predicted? Non-469 servers merge short
// moves regardless of bForcePacketSplit, so a push would not end its move. On
// a lift the lift is somewhere else on each machine.
simulated function bool IGPlus_SKCanPredict() {
	return IGPlus_PredictedSelfKnockback && Level.NetMode == NM_Client && bIs469Server
		&& Mover(Base) == none && Region.Zone.bWaterZone == false && GetWeaponSettings() != none;
}

// Client: predict an own rocket's explosion from its launch.
simulated function IGPlus_SKPredictRocket(vector Start, rotator FireRot, int RocketIndex) {
	if (IGPlus_SKCanPredict())
		IGPlus_SKPredictShot(IGPLUS_SK_ROCKET, RocketIndex, Start, vector(FireRot), GetWeaponSettings().RocketSpeed);
}

// Client: predict an own projectile's explosion from its launch, flying
// straight. Only world hits close enough to push us are predicted; anything
// else (pawns, far walls) is left to the server's correction. The server
// times it by its travel over its launch speed, as here.
simulated function IGPlus_SKPredictShot(byte Kind, int Index, vector Start, vector Dir, float Speed) {
	local IGPlus_SelfKnockback K;
	local vector End, HitLocation, HitNormal;
	local Actor HitActor;

	if (IGPlus_SKCanPredict() == false || Speed <= 0.0)
		return;
	IGPlus_SKPredictedEntry(Start, K, Kind);

	if (K.SourceRadius > 0.0) {
		// With a size (the shock ball): flown like the server's.
		if (IGPlus_SKFly(Kind, K.SourceRadius, Start, Dir, IGPlus_SKReach(K.Radius, Start), Speed * 0.01, HitLocation) == false)
			return;
	} else {
		End = Start + Dir * IGPlus_SKReach(K.Radius, Start);
		HitActor = IGPlus_SKTrace(Kind, Start, End, K.SourceRadius, HitLocation, HitNormal);
		if (HitActor == none || (HitActor != Level && Mover(HitActor) == none))
			return;

		// The server's projectile stops 2uu short of the surface (MoveActor's
		// TestAdjust) and explodes there.
		HitLocation -= 2.0 * Dir;
		if (((HitLocation - Start) dot Dir) < 0.0)
			HitLocation = Start;
	}

	IGPlus_SKQueuePredicted(Level.TimeSeconds + VSize(HitLocation - Start) / Speed, Kind * 8 + Index, HitLocation, Kind);
}

// Client: our own projectile with a size (the shock ball) flown through the
// world as the server's flies, by the same collision code: placed as a spawn
// places it (out of a wall it overlaps), then moved a physics step at a time.
// A long box trace stopped it 30uu above the floor where the server's went on.
// True if it stopped on the world within Dist, at HitLocation (its centre
// there), with Start where it really started. Anything else on its way (a
// pawn, a lift) is the server's correction.
simulated function bool IGPlus_SKFly(byte Kind, float Radius, out vector Start, vector Dir, float Dist, float StepSize, out vector HitLocation) {
	local vector Extent, Before, HL, HN;
	local Actor A;
	local float Flown;

	if (IGPlus_SKBall == None || IGPlus_SKBall.bDeleteMe)
		IGPlus_SKBall = Spawn(class'ST_HitTestHelper', self);
	if (IGPlus_SKBall == None)
		return false;
	Extent = vect(1,1,0) * Radius + vect(0,0,1) * IGPlus_SKSourceHeight(Kind);
	IGPlus_SKBall.SetCollisionSize(Extent.X, Extent.Z);
	IGPlus_SKBall.bCollideWorld = true;
	// No room for it: the server's spawn fails as well.
	if (IGPlus_SKBall.SetLocation(Start) == false) {
		IGPlus_SKBall.bCollideWorld = false;
		return false;
	}
	Start = IGPlus_SKBall.Location;
	StepSize = FMax(StepSize, 1.0);
	while (Flown < Dist) {
		Before = IGPlus_SKBall.Location;
		IGPlus_SKBall.Move(Dir * StepSize);
		if (VSize(IGPlus_SKBall.Location - Before) < StepSize - 0.01)
			break;
		Flown += StepSize;
	}
	HitLocation = IGPlus_SKBall.Location;
	IGPlus_SKBall.bCollideWorld = false;
	if (Flown >= Dist)
		return false;

	foreach TraceActors(class'Actor', A, HL, HN, HitLocation, Start, Extent) {
		if (A == self || A == Level)
			continue;
		// Our own disc too: the server's ball goes off on it.
		if (Pawn(A) != none || Mover(A) != none || (IGPlus_DetTloc != None && A == IGPlus_DetTloc.IGPlus_DetLocalDisc)) {
			IGPlus_SKDebugNote("not predicted, "$A$" on its way at "$class'ST_ShockProj'.static.IGPlus_Vec(A.Location));
			return false;
		}
	}
	return true;
}

simulated function IGPlus_SKDebugNote(string S) {
	if (bDrawDebugData)
		ClientDebugMessage("Self-push (client) "$S);
}

// What our own projectile of this kind stops on from Start to End: what a
// trace with actors finds, but never us.
simulated function Actor IGPlus_SKTrace(byte Kind, vector Start, vector End, float Radius, out vector HitLocation, out vector HitNormal) {
	local Actor A;

	foreach TraceActors(class'Actor', A, HitLocation, HitNormal, End, Start, vect(1,1,0) * Radius + vect(0,0,1) * IGPlus_SKSourceHeight(Kind)) {
		if (A == self)
			continue;
		// A rocket flies through projectiles, a disc too (ST_RocketMk2.ProcessTouch).
		if (Kind == IGPLUS_SK_ROCKET && Projectile(A) != none)
			continue;
		if (A == Level || Mover(A) != none || Pawn(A) != none || A.bProjTarget || (A.bBlockActors && A.bBlockPlayers))
			return A;
		// Our own disc: nothing here may shoot it (bProjTarget off), but the
		// server's copy of our shot goes off on the server's disc.
		if (IGPlus_DetTloc != None && A == IGPlus_DetTloc.IGPlus_DetLocalDisc)
			return A;
	}
	return none;
}

// A lobbed shot's flight time over Travel from launch velocity V0, falling at
// GZ, with upward speed VzHit where it ended: its level travel over its level
// speed, or for a steep shot its climb or drop under gravity, whichever tells
// it better. Both machines time a flak slug's push with this.
static function float IGPlus_SKArcTime(vector Travel, vector V0, float VzHit, float GZ) {
	local float LevelSpeed, Root;

	if (GZ == 0.0)
		return VSize(Travel) / FMax(VSize(V0), 1.0);
	LevelSpeed = VSize(V0 * vect(1,1,0));
	if (LevelSpeed > 0.0 && LevelSpeed >= Abs(VzHit))
		return VSize(Travel * vect(1,1,0)) / LevelSpeed;
	// Travel.Z = V0.Z t + GZ t^2 / 2: rising the earlier root, falling the later.
	Root = Sqrt(FMax(Square(V0.Z) + 2.0 * GZ * Travel.Z, 0.0));
	if (VzHit > 0.0)
		return (Root - V0.Z) / GZ;
	return (-V0.Z - Root) / GZ;
}

simulated function float IGPlus_SKSourceHeight(byte Kind) {
	switch (Kind) {
		case IGPLUS_SK_FLAKSLUG:	return class'ST_FlakSlug'.default.CollisionHeight;
		case IGPLUS_SK_SHOCKBALL:	return class'ST_ShockProj'.default.CollisionHeight;
		case IGPLUS_SK_RIPPERALT:	return class'ST_Razor2Alt'.default.CollisionHeight;
	}
	return class'ST_RocketMk2'.default.CollisionHeight;
}

// Client: the same for a lobbed shot, stepped along its arc. Both machines
// time it with IGPlus_SKArcTime.
simulated function IGPlus_SKPredictArc(byte Kind, int Index, vector Start, vector V0) {
	local IGPlus_SelfKnockback K;
	local vector P0, P1, V, G, HitLocation, HitNormal;
	local Actor HitActor;
	local float Dt, VzHit;
	local int i;

	if (IGPlus_SKCanPredict() == false || VSize(V0) < 50.0)
		return;
	IGPlus_SKPredictedEntry(Start, K, Kind);

	G = Region.Zone.ZoneGravity;
	Dt = 0.025;
	P0 = Start;
	V = V0;
	// ponytail: 2s of flight within reach covers jumps and most discs
	for (i = 0; i < 80; i++) {
		P1 = P0 + V * Dt + 0.5 * G * Dt * Dt;
		HitActor = IGPlus_SKTrace(Kind, P0, P1, K.SourceRadius, HitLocation, HitNormal);
		if (HitActor != none) {
			if (HitActor != Level && Mover(HitActor) == none)
				return;
			VzHit = V.Z + G.Z * Dt * VSize(HitLocation - P0) / FMax(VSize(P1 - P0), 0.01);
			HitLocation -= 2.0 * Normal(P1 - P0);
			IGPlus_SKQueuePredicted(Level.TimeSeconds + IGPlus_SKArcTime(HitLocation - Start, V0, VzHit, G.Z),
				Kind * 8 + Index, HitLocation, Kind);
			return;
		}
		if (VSize(P1 - Start) > IGPlus_SKReach(K.Radius, Start))
			return;
		P0 = P1;
		V += G * Dt;
	}
}

// Client: a predicted push of this kind that will not happen after all (our
// shock ball went off in a combo instead): the earliest one still to come.
simulated function IGPlus_SKCancelNext(byte Kind) {
	local int i, j;

	for (i = 0; i < IGPlus_SKQueueCount; i++) {
		if (IGPlus_SKQueue[i].Kind == Kind && IGPlus_SKQueue[i].TargetTS > Level.TimeSeconds) {
			for (j = i + 1; j < IGPlus_SKQueueCount; j++)
				IGPlus_SKQueue[j - 1] = IGPlus_SKQueue[j];
			IGPlus_SKQueueCount--;
			return;
		}
	}
}

// An own explosion of this kind at HitLocation, with today's settings.
simulated function IGPlus_SKPredictedEntry(vector HitLocation, out IGPlus_SelfKnockback K, optional byte Kind) {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	K.HitLocation = HitLocation;
	K.SourceLocation = HitLocation;
	K.bHasFallback = false;
	K.Kind = Kind;
	switch (Kind) {
		case IGPLUS_SK_FLAKSLUG:
			K.SourceRadius = class'ST_FlakSlug'.default.CollisionRadius;
			K.Radius = WS.FlakSlugHurtRadius;
			K.Momentum = WS.FlakSlugMomentum * class'ST_FlakSlug'.default.MomentumTransfer;
			K.bEnhanced = WS.bEnableEnhancedSplashFlakSlug;
			break;
		case IGPLUS_SK_SHOCKBALL:
			K.SourceRadius = class'ST_ShockProj'.default.CollisionRadius;
			K.Radius = WS.ShockProjectileHurtRadius;
			K.Momentum = WS.ShockProjectileMomentum * class'ST_ShockProj'.default.MomentumTransfer;
			K.bEnhanced = WS.bEnableEnhancedSplashShockProjectile;
			break;
		case IGPLUS_SK_RIPPERALT:
			K.SourceRadius = class'ST_Razor2Alt'.default.CollisionRadius;
			K.Radius = WS.RipperSecondaryHurtRadius;
			K.Momentum = WS.RipperSecondaryMomentum * class'ST_Razor2Alt'.default.MomentumTransfer;
			K.bEnhanced = WS.bEnableEnhancedSplashRipperSecondary;
			break;
		default:
			K.SourceRadius = class'ST_RocketMk2'.default.CollisionRadius;
			K.Radius = WS.RocketHurtRadius;
			K.Momentum = WS.RocketMomentum * class'ST_RocketMk2'.default.MomentumTransfer;
			K.bEnhanced = WS.bEnableEnhancedSplashRockets;
	}
}

simulated function IGPlus_SKQueuePredicted(float TargetTS, int RocketIndex, vector HitLocation, optional byte Kind) {
	local IGPlus_SelfKnockback K;

	IGPlus_SKPredictedEntry(HitLocation, K, Kind);
	K.TargetTS = TargetTS;
	IGPlus_SKDebug("predicted", K);
	IGPlus_SKQueueAdd(TargetTS, RocketIndex, K.HitLocation, K.SourceLocation, K.SourceRadius,
		K.Radius, K.Momentum, K.bEnhanced, false, vect(0,0,0), Kind);
}

// Debug (enableDebugData): our own pushes, on each side.
simulated function IGPlus_SKDebug(string What, IGPlus_SelfKnockback K, optional vector Push) {
	local string Side, Kind, Phys;

	if (bDrawDebugData == false)
		return;
	Side = "server";
	if (Level.NetMode == NM_Client)
		Side = "client";
	Kind = IGPlus_SKKindName(K.Kind);
	Phys = "falling";
	if (Physics == PHYS_Walking)
		Phys = "walking";
	ClientDebugMessage("Self-push ("$Side$") "$Kind$" "$What$" due "$K.TargetTS$" from "$class'ST_ShockProj'.static.IGPlus_Vec(K.HitLocation)
		$" push "$class'ST_ShockProj'.static.IGPlus_Vec(Push)$" us "$Phys$" at "$class'ST_ShockProj'.static.IGPlus_Vec(Location));
}

static function string IGPlus_SKKindName(byte Kind) {
	switch (Kind) {
		case IGPLUS_SK_FLAKSLUG:	return "flak slug";
		case IGPLUS_SK_SHOCKBALL:	return "shock ball";
		case IGPLUS_SK_RIPPERALT:	return "ripper alt";
		case IGPLUS_SK_HAMMER:		return "hammer/chunks";
	}
	return "rocket";
}

// How far along an own shot's path its explosion is predicted: near us
// (hurt radius + 300uu covers jumps, farther walls correct), or as far as our
// own deterministic disc, which it may push (IGPlus_SKPushOwnDisc).
simulated function float IGPlus_SKReach(float Radius, vector Start) {
	local ST_TranslocatorTarget D;

	if (IGPlus_DetTloc != None && IGPlus_PredictsDiscBoost()) {
		D = IGPlus_DetTloc.IGPlus_DetLocalDisc;
		if (D != None && D.bDeleteMe == false)
			return Radius + 300.0 + VSize(D.Location - Start);
	}
	return Radius + 300.0;
}

// Our own explosion and our own deterministic disc (Predicted Disc Boost):
// the disc's push lands on the same move as our own push, from where each
// machine has the disc on that move. The client pushes its own disc, the
// server its disc where our screen had it, flown again from there
// (ST_Translocator.IGPlus_DetServerPush). True when the client pushed: that
// move goes to the server on its own, as for our own push.
simulated function bool IGPlus_SKPushOwnDisc(IGPlus_SelfKnockback K, optional string What) {
	local vector Push;

	if (IGPlus_SKOwnDiscPush(K, Push) == false)
		return false;
	if (What == "")
		What = IGPlus_SKKindName(K.Kind);
	return IGPlus_SKApplyOwnDiscPush(Push, What);
}

// The momentum our own explosion K gives our own deterministic disc, where
// this machine has the disc on this move. False when it doesn't reach it.
simulated function bool IGPlus_SKOwnDiscPush(IGPlus_SelfKnockback K, out vector Push) {
	local ST_Translocator TL;
	local ST_TranslocatorTarget D;
	local vector Loc;

	if (K.Kind == IGPLUS_SK_HAMMER || IGPlus_PredictsDiscBoost() == false)
		return false;
	if (Level.NetMode == NM_Client) {
		TL = IGPlus_DetTloc;
		if (IGPlus_DetTranslocator == false || TL == None || TL.bDeleteMe)
			return false;
		D = TL.IGPlus_DetLocalDisc;
		if (D == None || D.bDeleteMe)
			return false;
		Loc = D.Location;
	} else {
		TL = ST_Translocator(FindInventoryType(class'ST_Translocator'));
		if (TL == None || TL.IGPlus_IsDetMode() == false)
			return false;
		D = ST_TranslocatorTarget(TL.TTarget);
		if (D == None || D.bIGPlusFullHistory == false)
			return false;
		Loc = TL.IGPlus_DetSeenLocation(D, self);
	}
	return IGPlus_SKSplash(K, Loc, D.CollisionRadius, D.CollisionHeight, Push) && Push != vect(0,0,0);
}

simulated function bool IGPlus_SKApplyOwnDiscPush(vector Push, string What) {
	local ST_Translocator TL;
	local ST_TranslocatorTarget D;

	if (Level.NetMode == NM_Client) {
		TL = IGPlus_DetTloc;
		ClientDebugMessage("Tloc disc pushed by our own "$What$" (predicted) age="$(Level.TimeSeconds - TL.IGPlus_DetThrowTS));
		TL.IGPlus_DetPredictBoost(Push);
		TL.IGPlus_DetConfirmAfterPush();
		return true;
	}
	TL = ST_Translocator(FindInventoryType(class'ST_Translocator'));
	if (TL != None && TL.IGPlus_IsDetMode())
		D = ST_TranslocatorTarget(TL.TTarget);
	if (D != None && D.bIGPlusFullHistory)
		TL.IGPlus_DetServerPush(D, self, Push);
	return false;
}

// Server: our own rocket, shock ball, flak slug or ripper blade going off
// (IGPlus_SKBeginCapture) by our own deterministic disc. Our projectile runs
// on our screen's time, our disc a ping behind it: its push waits for our
// moves (IGPlus_SKPushOwnDisc), as our own push does, so it lands where our
// client pushed its own disc.
function bool IGPlus_SKDefersDisc(ST_TranslocatorTarget D) {
	local ST_Translocator TL;

	TL = ST_Translocator(D.Master);
	return (IGPlus_SKCapturing || IGPlus_SKComboDisc)
		&& IGPlus_PredictsDiscBoost() && TL != None && TL.TTarget == D
		&& TL.IGPlus_IsDetMode() && D.bIGPlusFullHistory;
}

// Server: our own combo (ST_ShockProj.SuperExplosion) pushes our own disc
// from where our screen had the ball, as our client worked it out
// (IGPlus_SKPredictComboOnDisc). The server's ball is up to a server frame
// of packet timing off that spot, which turned the disc's push by a few degrees.
function IGPlus_SKComboOnDisc(vector Blast, float BallRadius, float Radius, float Momentum, bool bEnhanced) {
	local IGPlus_SelfKnockback K;

	K.HitLocation = Blast;
	K.SourceLocation = Blast;
	K.SourceRadius = BallRadius;
	K.Radius = Radius;
	K.Momentum = Momentum;
	K.bEnhanced = bEnhanced;
	K.Kind = IGPLUS_SK_SHOCKBALL;
	IGPlus_SKPushOwnDisc(K);
}

// Client: our own predicted combo (ST_ShockProj.IGPlus_PredictCombo) pushes
// our own disc on the beam's move, as the server's combo pushes its disc
// where our screen had it.
simulated function IGPlus_SKPredictComboOnDisc(ST_ShockProj Ball) {
	local IGPlus_SelfKnockback K;
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	if (WS == None)
		return;
	K.HitLocation = Ball.Location;
	K.SourceLocation = Ball.Location;
	K.SourceRadius = Ball.CollisionRadius;
	K.Radius = WS.ShockComboHurtRadius;
	K.Momentum = WS.ShockComboMomentum * Ball.MomentumTransfer * 2;
	K.bEnhanced = WS.bEnableEnhancedSplashShockCombo;
	K.Kind = IGPLUS_SK_SHOCKBALL;
	IGPlus_SKPushOwnDisc(K, "combo");
}

// Client: our own flak slug, shock ball and ripper alt blade.
simulated function IGPlus_SKPredictFlakSlug(vector Start, rotator Aim) {
	// flakslug.PostBeginPlay: launch speed along the aim, then 200 up.
	IGPlus_SKPredictArc(IGPLUS_SK_FLAKSLUG, 0, Start,
		vector(Aim) * class'ST_FlakSlug'.default.Speed + vect(0,0,200));
}

simulated function IGPlus_SKPredictShockBall(vector Start, rotator Aim) {
	IGPlus_SKPredictShot(IGPLUS_SK_SHOCKBALL, 0, Start, vector(Aim), class'ST_ShockProj'.default.Speed);
}

simulated function IGPlus_SKPredictRipperAlt(vector Start, rotator Aim) {
	IGPlus_SKPredictShot(IGPLUS_SK_RIPPERALT, 0, Start, vector(Aim), class'ST_Razor2Alt'.default.Speed);
}

// Our shock balls in the order we fired them, for our beam's verdict on them
// (IGPlus_OwnBallVerdict). Both machines note every alt shot, also one that
// made no ball, so "our newest ball" is the same shot on both.
simulated function IGPlus_NoteOwnBall(ST_ShockProj Ball, float TS) {
	IGPlus_OwnBalls[1] = IGPlus_OwnBalls[0];
	IGPlus_OwnBalls[0] = Ball;
	IGPlus_OwnBallTS[1] = IGPlus_OwnBallTS[0];
	IGPlus_OwnBallTS[0] = TS;
	IGPlus_OwnBallEnd[1] = IGPlus_OwnBallEnd[0];
	IGPlus_OwnBallEnd[0] = "";
	IGPlus_OwnBallEndTS[1] = IGPlus_OwnBallEndTS[0];
}

// Server, debug data: one of our two newest balls ended (ST_ShockProj.IGPlus_NoteEnd).
function IGPlus_NoteOwnBallEnd(ST_ShockProj Ball, string What, float TS) {
	local int i;

	for (i = 0; i < 2; i++)
		if (IGPlus_OwnBalls[i] == Ball) {
			IGPlus_OwnBallEnd[i] = What;
			IGPlus_OwnBallEndTS[i] = TS;
		}
}

// Server, debug data: why the ball our client's beam named is not there for
// it, and how long before this beam's move it ended on our own screen.
function string IGPlus_OwnBallGoneText(int i) {
	if (IGPlus_OwnBallEnd[i] == "")
		return "the ball is gone here (it hit something, or was set off)";
	return "the ball is gone here: "$IGPlus_OwnBallEnd[i]$" "
		$int((CurrentTimeStamp - IGPlus_OwnBallEndTS[i]) * 1000.0 / Level.TimeDilation)$"ms before this beam";
}

// Client: our shock ball went off in a combo, not against the wall.
simulated function IGPlus_SKCancelShockBall() {
	IGPlus_SKCancelNext(IGPLUS_SK_SHOCKBALL);
}

// Server: around an own flak slug's, shock ball's or ripper alt blade's
// splash (IGPlus_SKBeginCapture first), due TargetTS on our moves.
function IGPlus_SKEndCaptureFor(Projectile P, float TargetTS, vector HitLocation) {
	local IGPlus_SelfKnockback K;
	local byte Kind;

	if (ST_FlakSlug(P) != None)
		Kind = IGPLUS_SK_FLAKSLUG;
	else if (ST_ShockProj(P) != None)
		Kind = IGPLUS_SK_SHOCKBALL;
	else if (ST_Razor2Alt(P) != None)
		Kind = IGPLUS_SK_RIPPERALT;
	IGPlus_SKPredictedEntry(HitLocation, K, Kind);
	IGPlus_SKEndCapture(TargetTS, Kind * 8, HitLocation, P.Location,
		K.SourceRadius, K.Radius, K.Momentum, K.bEnhanced, Kind);
}

// Server: our own flak chunks hitting us on their fast-forward
// (ST_UTChunkInfo.AddChunk) push us right after our slug does, as in stock.
// Before it, they would knock us off the floor, and the slug's push would
// lose the upward kick a push from the floor gets. The client does not
// predict them: a small correction.
function IGPlus_SKEndCaptureAfter(float TargetTS) {
	IGPlus_SKCapturing = false;
	if (IGPlus_SKCapturedHit)
		IGPlus_SKQueueHammer(FMax(TargetTS, CurrentTimeStamp), IGPlus_SKCaptured);
}

// Client: our own hammer's push off a wall, at the end of this move (where
// the server applies its own, IGPlus_ServerHammerRelease). Also any push
// already worked out (IGPlus_SKEndCaptureAfter).
simulated function IGPlus_SKQueueHammer(float TS, vector Push) {
	IGPlus_SKQueueAdd(TS, IGPLUS_SK_HAMMER * 8, Location, Location, 0, 0, 0, false, true, Push, IGPLUS_SK_HAMMER);
}

// Hammer release on the move timeline: no input replication (the client's
// release rides its own move), and the push needs the self-knockback queue.
simulated function bool IGPlus_PredictHammer() {
	return IGPlus_PredictedSelfKnockback && IGPlus_EnableInputReplication == false
		&& (Level.NetMode != NM_Client || bIs469Server);
}

// --- Predicted translocation -------------------------------------------------

// Replay of a predicted translocation: land where the prediction did, then
// the rest of Translocator.Translocate's success path.
function IGPlus_ReplayTranslocate(vector Dest) {
	local bool bOldCollWorld, bOldActCol, bOldBlockAct, bOldBlockPlayer;

	bCanTeleport = false;
	bOldActCol = bCollideActors;
	bOldBlockAct = bBlockActors;
	bOldBlockPlayer = bBlockPlayers;
	bOldCollWorld = bCollideWorld;
	bCollideWorld = false;
	SetCollision(false, false, false);
	SetLocation(Dest);
	bCollideWorld = bOldCollWorld;
	SetCollision(bOldActCol, bOldBlockAct, bOldBlockPlayer);
	bCanTeleport = true;

	if (Region.Zone.bWaterZone == false && Physics != PHYS_Flying)
		SetPhysics(PHYS_Falling);
	Velocity.X = 0;
	Velocity.Y = 0;
	TlocCounter = (TlocCounter + 1) & 3;
}

// Client, on the alt-fire press frame before its movement: the server
// translocates at the same point, to where this client saw the disc (the
// disc history at this move's age since the throw). Anything the client
// cannot see (disruption, an enemy knocking the disc) is left to the server.
function IGPlus_PredictTranslocate(IGPlus_SavedMove Move) {
	local ST_Translocator TL;
	local ST_TranslocatorTarget Disc;
	local WeaponSettingsRepl WS;

	if (Level.NetMode != NM_Client)
		return;

	TL = ST_Translocator(Weapon);
	if (TL == none || TL.Class != class'ST_Translocator' || bFire != 0)
		return;
	// Bring-up holds the press; NormalFire ignores alt-fire for 0.1s after any
	// fire or alt-fire (server time, so keep a margin).
	if (ClientPending != none || TL.IsInState('ClientDown') || TL.IsInState('ClientActive'))
		return;
	if (Level.TimeSeconds - IGPlus_TlocLastPressTS < 0.15)
		return;

	WS = GetWeaponSettings();
	if (WS == none || WS.TranslocatorCompensatePing == false)
		return;

	// Our own client disc counts before the server's bTTargetOut arrives.
	Disc = TL.IGPlus_PredictionDisc();
	if (Disc == none || (TL.bTTargetOut == false && Disc != TL.TTarget_Client))
		return;

	IGPlus_TlocPredictTo(Disc, Move);

	IGPlus_TlocPredictTS = Level.TimeSeconds;
	if (Disc == TL.TTarget_Client) {
		TL.TTarget_Client = none;
		Disc.Destroy();
		// The server's disc is still on its way to us: hide it on arrival.
		IGPlus_TlocHideArrivingUntil = Level.TimeSeconds + PlayerReplicationInfo.Ping * 0.002 * Level.TimeDilation + 0.25;
	} else {
		IGPlus_TlocHideDisc(Disc);
	}
}

// Client: Translocator.Translocate's effect on us, toward Disc, before this
// frame's movement (where the server translocates too). Every outcome uses
// the disc up on the server; the caller deals with the disc.
function IGPlus_TlocPredictTo(ST_TranslocatorTarget Disc, IGPlus_SavedMove Move) {
	local vector Dest, Start;

	Dest = Disc.Location;
	if (Disc.Physics == PHYS_None)
		Dest += vect(0,0,40);

	Start = Location;
	// As stock's Translocate: landing 40uu above our own disc (we reach 39 down,
	// it 3 up) is no pickup. The caller ends the disc either way.
	if (Disc.IGPlus_bLocalDisc)
		Disc.SetCollision(false, false, false);
	if (SetLocation(Dest) == false) {
		ClientDebugMessage("Tloc not predicted: we don't fit at the disc"@Dest@"landed="$(Disc.Physics == PHYS_None)
			@"server's="$(Disc != ST_Translocator(Weapon).IGPlus_DetLocalDisc));
		return;
	}
	if (Region.Zone.bWaterZone == false && Physics != PHYS_Flying)
		SetPhysics(PHYS_Falling);
	if (FastTrace(Location, Disc.Location) == false) {
		// The server puts us back too, keeping the falling physics.
		ClientDebugMessage("Tloc not predicted: no line from the spot to the disc"@Disc.Location
			@"server's="$(Disc != ST_Translocator(Weapon).IGPlus_DetLocalDisc));
		SetLocation(Start);
		return;
	}

	Velocity.X = 0;
	Velocity.Y = 0;
	TlocCounter = (TlocCounter + 1) & 3;
	// A teleport, not a step: UpdateEyeHeight would otherwise take the height
	// change as stepping onto a ramp (walking -> falling) and ease the camera
	// through up to MaxStepHeight, a visible dip/hop after every translocate.
	IgnoreZChangeTicks = 2;

	Move.bIGPlusTloc = true;
	Move.IGPlusTlocDest = Location;

	// A teleport, not a correction: nothing left to ease.
	IGPlus_CameraCorrectionOffset = vect(0,0,0);
	IGPlus_LiftExitCamOffset = vect(0,0,0);
	IGPlus_PushCamOffset = vect(0,0,0);
	IGPlus_AdjustLocationOffset = vect(0,0,0);
	IGPlus_AdjustLocationAlpha = 0;
}

// Hide a disc the server is about to destroy; shown again if it stays.
simulated function IGPlus_TlocHideDisc(ST_TranslocatorTarget Disc) {
	Disc.bHidden = true;
	if (Disc.Glow != none)
		Disc.Glow.bHidden = true;
	if (Disc.Shadow != none) {
		Disc.Shadow.Destroy();
		Disc.Shadow = none;
	}
	IGPlus_TlocHiddenDisc = Disc;
	IGPlus_TlocHiddenUntil = Level.TimeSeconds + PlayerReplicationInfo.Ping * 0.002 * Level.TimeDilation + 0.25;
}

// Server: our deterministic disc bounced or landed on our screen
// (ST_Translocator.IGPlus_DetLocalDiscBounced). bConfirm: our client pushed
// its own disc and wants ours once it is Age old (IGPlus_DetConfirmAfterPush).
function IGPlus_ServerDetDiscSync(float DiscTS, float Age, optional bool bConfirm) {
	local ST_Translocator TL;

	TL = ST_Translocator(FindInventoryType(class'ST_Translocator'));
	if (TL != None)
		TL.IGPlus_DetSyncAfter(DiscTS, Age, bConfirm);
}

// Server: our client walked onto its landed disc on the move at TS, standing
// at Loc, and picked it up (ST_Translocator.IGPlus_DetClientPickedUp). This
// gets here before that move: IGPlus_DetPickupDue acts at its end.
function IGPlus_ServerDetPickedUp(float DiscTS, float TS, vector Loc) {
	if (TS > CurrentTimeStamp + 2.0)
		return;
	IGPlus_DetPickupDiscTS = DiscTS;
	IGPlus_DetPickupTS = TS;
	IGPlus_DetPickupLoc = Loc;
}

// Server: the move our client picked its disc up on has run. Stock picked
// ours up too if we touched it there (ST_TranslocatorTarget.Touch). We
// didn't (a push the client hadn't seen had us elsewhere): ours goes the
// same way when it lies where the client stood. It doesn't (shot away, still
// flying): the client gets our disc back.
function IGPlus_DetPickupDue() {
	local ST_Translocator TL;
	local ST_TranslocatorTarget T;
	local vector D;
	local float TS;
	local string Why;

	TS = IGPlus_DetPickupTS;
	IGPlus_DetPickupTS = 0.0;
	TL = ST_Translocator(FindInventoryType(class'ST_Translocator'));
	if (TL == None || TL.IGPlus_IsDetMode() == false)
		return;
	T = ST_TranslocatorTarget(TL.TTarget);
	if (T == None || TL.IGPlus_ThrowTS != IGPlus_DetPickupDiscTS)
		return; // picked up here as well, or a newer disc by now

	D = T.Location - IGPlus_DetPickupLoc;
	// ponytail: 8uu past touching, and the client within 200uu of us; a
	// recall does the same from anywhere 0.8s after the throw
	if (T.Physics != PHYS_None)
		Why = "flying";
	else if (Abs(D.Z) > T.CollisionHeight + CollisionHeight + 8.0
		|| VSize(D * vect(1,1,0)) > T.CollisionRadius + CollisionRadius + 8.0)
		Why = "disc-not-there";
	else if (VSize(IGPlus_DetPickupLoc - Location) > 200.0)
		Why = "client-far";
	if (Why != "") {
		TL.IGPlus_DetLog("reject", "pickup"@Why@"discDist="$int(VSize(D))@"bodyGap="$int(VSize(IGPlus_DetPickupLoc - Location)));
		TL.IGPlus_ClientDetSync(true, TL.IGPlus_ThrowTS, TS);
		return;
	}
	TL.IGPlus_DetServerPickedUp(T);
}

function IGPlus_BeforeTranslocate() {
	TlocPrevLocation = Location;
	// The client's side is its move before this one (it translocates first thing in this one).
	IGPlus_DetTlocPreVZ = Velocity.Z;
	IGPlus_DetTlocPrePhys = Physics;
	IGPlus_DetTlocPreClientVZ = IGPlus_DetPrevClientVel.Z;
	IGPlus_DetTlocPreClientPhys = IGPlus_DetPrevClientPhys;
}

function IGPlus_AfterTranslocate() {
	IGPlus_DidTranslocate = (VSize(Location - TlocPrevLocation) > 1);
	if (IGPlus_DidTranslocate) {
		// A teleport, not a step: no eye-height smoothing (as for teleporters).
		IgnoreZChangeTicks = 2;
		IGPlus_NotifiedTranslocate = false;
		if (ST_Translocator(Weapon) != none && ST_Translocator(Weapon).IGPlus_IsDetMode()) {
			IGPlus_bDetTlocCheckLanding = true;
			IGPlus_DetStatTlocs++;
			// A jump right at landing that only we took: we come out rising,
			// the client walking (stock keeps the vertical speed). The client
			// walked into its translocate, so keep its speed. Never faster up.
			// (Physics bytes: 1 PHYS_Walking, 2 PHYS_Falling.)
			if (IGPlus_DetTlocPreClientPhys == 1 && IGPlus_DetTlocPrePhys == 2
				&& Velocity.Z > 0.0 && Velocity.Z <= JumpZ + 1.0 && IGPlus_DetTlocPreClientVZ < Velocity.Z) {
				IGPlus_DetStatJumpDropped++;
				Velocity.Z = IGPlus_DetTlocPreClientVZ;
			}
		}
	}
}

// Server: one [DET-TLOC] line, each a way the thrower's screen and the server
// parted. At most 8 a second per player.
function IGPlus_DetTlocLog(string Event, string Details) {
	local string LossAgo;

	if (Event == "reject")
		IGPlus_DetStatRejects++;
	if (Level.TimeSeconds - IGPlus_DetTlocLogWindowTS > 1.0) {
		IGPlus_DetTlocLogWindowTS = Level.TimeSeconds;
		IGPlus_DetTlocLogCount = 0;
	}
	if (IGPlus_DetTlocLogCount >= 8)
		return;
	IGPlus_DetTlocLogCount++;
	LossAgo = "never";
	if (IGPlus_DetLastLossTS > 0.0)
		LossAgo = string(Level.TimeSeconds - IGPlus_DetLastLossTS);
	IGPlus_EventLog("[DET-TLOC]"@Event@PlayerReplicationInfo.PlayerName@Details
		@"ping="$PlayerReplicationInfo.Ping@"lostMoves="$IGPlus_DetLostMoves
		@"lastLossAgo="$LossAgo@"ts="$CurrentTimeStamp);
}

// Server: the speed-hack check (TimeMargin over MaxTimeMargin) threw a move's
// time away, so the player stays put. It only ever told that player, and only
// with debug data on. A player stuck in place for 2 s after a match start
// (MEER TDM 2, Nov 14 2026) left no trace in the server log. At most one line
// a second, with the moves held since the last line, the move held and the
// time stamps the check compared.
function IGPlus_LogMoveHeld(float MoveDelta, float ServerDelta, float MoveTS) {
	if (Level.TimeSeconds - IGPlus_MovesHeldLastTS > 1.0)
		IGPlus_MovesHeld = 0;
	IGPlus_MovesHeldLastTS = Level.TimeSeconds;
	IGPlus_MovesHeld++;
	if (Level.TimeSeconds - IGPlus_MovesHeldLogTS < 1.0)
		return;
	IGPlus_MovesHeldLogTS = Level.TimeSeconds;
	IGPlus_EventLog("[TIMEMARGIN]"@PlayerReplicationInfo.PlayerName@"held="$IGPlus_MovesHeld
		@"timeMargin="$TimeMargin@"max="$MaxTimeMargin@"moveDelta="$MoveDelta@"serverDelta="$ServerDelta
		@"moveTS="$MoveTS@"lastTS="$CurrentTimeStamp@"serverTS="$ServerTimeStamp
		@"ping="$PlayerReplicationInfo.Ping@"state="$GetStateName());
	IGPlus_MovesHeld = 0;
}

// A line in the log with the machine's clock time at the end (on the server:
// the server's), so a player's report ("around 21:15") or a demo can be
// matched to it.
function IGPlus_EventLog(string S) {
	Log(S@"at="$PadNumberToTwoDigits(Level.Hour)$":"$PadNumberToTwoDigits(Level.Minute)
		$":"$PadNumberToTwoDigits(Level.Second), 'IGPlus');
}

// Server: one [DET-SUMMARY] line with this player's counts for the map, when
// the match ends (UTPure.Tick) or the player's pawn goes (Destroyed: the
// player left, or the map changed and the engine closed the connections).
// On a full server the rates say more than the single lines. Translocator:
// landedApart are landings the player saw corrected, absorbed those within
// the 16uu bubble (nobody saw them), late the actions that came through the
// resend or were held back, jumpDropped the jumps at a landing that only the
// server took. Weapons: see IGPlus_StatShotRefused, whose single lines are
// written only while TraceInput is on. Hits: shots that carried the client's
// own verdict, those both traces counted as a hit, those only the client's
// did (it played a hit sound for nothing) and only the server's did (the
// sound came a ping late), see IGPlus_HitCompare. Not for a player with all
// at zero.
function IGPlus_DetLogSummary() {
	local float EyeAvg;

	IGPlus_ABLogSummary();

	if (IGPlus_bDetStatLogged || PlayerReplicationInfo == None)
		return;
	if (IGPlus_DetStatThrows + IGPlus_DetStatRejects + IGPlus_StatShotRefused + IGPlus_StatShotUnbound
		+ IGPlus_StatSwitchMismatch + IGPlus_StatClockHolds + IGPlus_HitStatShots + IGPlus_HitStatNoData
		+ IGPlus_HitStatEyeUsed + IGPlus_HitStatEyeRefused + IGPlus_HitStatDeadShots == 0)
		return;
	if (IGPlus_HitStatEyeUsed > 0)
		EyeAvg = IGPlus_HitStatEyeDiffSum / IGPlus_HitStatEyeUsed;
	IGPlus_bDetStatLogged = true;
	IGPlus_EventLog("[DET-SUMMARY]"@PlayerReplicationInfo.PlayerName
		@"throws="$IGPlus_DetStatThrows@"translocates="$IGPlus_DetStatTlocs
		@"landedApart="$IGPlus_DetStatApart@"absorbed="$IGPlus_DetStatAbsorbed
		@"throwApart="$IGPlus_DetStatThrowApart@"rejects="$IGPlus_DetStatRejects@"late="$IGPlus_DetStatLate
		@"jumpDropped="$IGPlus_DetStatJumpDropped@"lateSpot="$IGPlus_DetStatLateSpot
		@"shotRefused="$IGPlus_StatShotRefused@"shotUnbound="$IGPlus_StatShotUnbound
		@"switchMismatch="$IGPlus_StatSwitchMismatch@"clockHolds="$IGPlus_StatClockHolds
		@"hitShots="$IGPlus_HitStatShots@"hitNoData="$IGPlus_HitStatNoData@"hitBoth="$IGPlus_HitStatBoth
		@"hitClientOnly="$IGPlus_HitStatClientOnly@"hitServerOnly="$IGPlus_HitStatServerOnly
		@"hitHeadDiff="$IGPlus_HitStatHeadDiff
		@"hitDrawnDiff="$IGPlus_HitStatDrawnDiff@"hitDrawnRight="$IGPlus_HitStatDrawnRight
		@"deadShots="$IGPlus_HitStatDeadShots@"deadShotHits="$IGPlus_HitStatDeadHits
		@"fireShared="$IGPlus_StatFireShared@"fireMoved="$IGPlus_StatFireMoved
		@"eyeUsed="$IGPlus_HitStatEyeUsed@"eyeRefused="$IGPlus_HitStatEyeRefused
		@"eyeDiffAvg="$EyeAvg@"eyeDiffMax="$IGPlus_HitStatEyeDiffMax
		@"originFar="$IGPlus_HitStatOriginFar@"originGapMax="$IGPlus_HitStatOriginGapMax
		@"ping="$PlayerReplicationInfo.Ping@"lostMoves="$IGPlus_DetLostMoves);
}

// Server: the client's spot at the start of move SM (before its movement),
// as IGPlus_PSAShotOrigin has it: exact when the previous move (and nothing
// between) reported it. Not from the previous move on a lift, which has
// moved on since.
function vector IGPlus_ClientMoveStart(IGPlus_ServerMove SM, float PrevTS) {
	local vector ClientStart;

	ClientStart = SM.ClientLocation - SM.ClientVelocity * SM.MoveDeltaTime;
	if (SM.ClientBase != none)
		ClientStart += SM.ClientBase.Location;
	if (Mover(SM.ClientBase) == none && IGPlus_PSALastClientTS == PrevTS
		&& Abs(SM.TimeStamp - PrevTS - SM.MoveDeltaTime) < 0.5 * SM.MoveDeltaTime
		&& VSize(IGPlus_PSALastClientLoc - ClientStart) < 4.0)
		ClientStart = IGPlus_PSALastClientLoc;
	return ClientStart;
}

// Server: where a deterministic throw's disc leaves from. The thrower's own
// disc left from its spot at the start of this move. Ours leaves from there
// too, so both fly one path and the translocate lands both in one place,
// when Push-Safe Aim takes that spot (a push the client hadn't seen yet), or
// when it is within 32uu of ours with a clear line (like a landing,
// IGPlus_DetTakeClientLanding). Else from our own spot, and the thrower gets
// our disc's path (IGPlus_DetAfterThrow). Not on a lift: there the client's
// spot is inside our lift.
function vector IGPlus_DetThrowOrigin(IGPlus_ServerMove SM, float PrevTS, int MergeCount) {
	local vector Origin, ClientStart, Eye;
	local float Dist;

	IGPlus_DetThrowRule = 0;
	if (IsInState('Dying') || MergeCount != 0 || Mover(Base) != none || Mover(SM.ClientBase) != none)
		return Location;
	Origin = IGPlus_PSAShotOrigin(SM, PrevTS, MergeCount);
	if (Origin != Location) {
		IGPlus_DetThrowRule = 1;
		return Origin;
	}
	ClientStart = IGPlus_ClientMoveStart(SM, PrevTS);
	Dist = VSize(ClientStart - Location);
	// ponytail: a fixed 32uu, twice the landing bubble; under fire Push-Safe
	// Aim leaves gaps of 17 to 43uu it has no push for
	if (Dist < 0.5 || Dist > 32.0)
		return Location;
	Eye = BaseEyeHeight * vect(0,0,1);
	if (IGPlus_PSAClear(ClientStart, Location) == false || IGPlus_PSAClear(ClientStart + Eye, Location + Eye) == false)
		return Location;
	IGPlus_DetThrowRule = 2;
	return ClientStart;
}

// Server: after a move's translocator step. It threw, our disc left from our
// own spot, and the client's spot (where its disc left from) is more than
// 4uu off: the thrower gets our disc's path at once, so its own follows ours
// from the start instead of landing that far off, and a [DET-TLOC] line says
// so. Not sent on a lift (left as it was), where the client's spot rides our
// lift and its screen has the lift, and itself, a round trip back.
function IGPlus_DetAfterThrow(IGPlus_ServerMove SM, float PrevTS) {
	local ST_Translocator TL;
	local vector Gap;
	local bool bLift;

	TL = ST_Translocator(Weapon);
	// (1: a throw. ThrowTarget stamps the one this step made.)
	if ((SM.DetChargeData & 3) != 1 || SM.DetChargeData > 7
		|| TL == None || ST_TranslocatorTarget(TL.TTarget) == None || TL.IGPlus_ThrowTS != SM.TimeStamp)
		return;

	bLift = Mover(Base) != none || Mover(SM.ClientBase) != none;
	if (IGPlus_DetThrowRule == 0) {
		Gap = Location - IGPlus_ClientMoveStart(SM, PrevTS);
		if (SM.ClientBase == Base)
			Gap += IGPlus_OwnLiftLead();
	}
	// Kept for the translocate's lines: a landing that far apart began here.
	IGPlus_DetThrowGapInfo = "throwGap="$class'ST_ShockProj'.static.IGPlus_Vec(Gap);
	if (VSize(Gap) <= 4.0)
		return;
	if (bLift == false)
		TL.IGPlus_DetServerDiscChanged(ST_TranslocatorTarget(TL.TTarget));
	IGPlus_DetStatThrowApart++;
	IGPlus_DetTlocLog("throw-apart", "dist="$int(VSize(Gap))@"onLift="$bLift);
}

// Server: a deterministic translocator action from a lost or held-back move,
// once, on the client's timeline: at its move's time stamp, aimed with that
// move's view (packed like xxServerMove's View). MoveTS: the move we are
// running now; the action is that much late. bHeld: from the held queue
// (checked once already when held).
function IGPlus_DetRunAction(int Action, float TS, int View, float MoveTS, optional bool bHeld) {
	local float SavedTS;
	local rotator SavedView;
	local ST_Translocator TL;
	local bool bSpotKnown;
	local vector Gap;

	if ((Action & 3) == 0 || Action > 7 || (bHeld == false && TS <= IGPlus_DetLastActionSeenTS) || IsInState('Dying'))
		return;
	IGPlus_DetLastActionSeenTS = FMax(IGPlus_DetLastActionSeenTS, TS);
	TL = ST_Translocator(Weapon);
	if (TL == none) {
		IGPlus_DetNotHeld(Action, TS, View);
		return;
	}
	if (TL.IGPlus_IsDetMode() == false)
		return;
	IGPlus_DetStatLate++; // (for the summary: no line each, a lossy link has many)
	SavedTS = CurrentTimeStamp;
	SavedView = ViewRotation;
	// A late throw whose spot came along: our disc leaves from there by the
	// rule of a throw on time (IGPlus_DetThrowOrigin), so both fly one path.
	bSpotKnown = (Action & 3) == 1 && bHeld == false && IGPlus_DetLateSpotTS == TS;
	if (bSpotKnown) {
		Gap = Location - IGPlus_DetLateSpot;
		IGPlus_DetThrowRule = 0;
		if (IGPlus_DetLateSpotTaken(IGPlus_DetLateSpot)) {
			IGPlus_DetThrowSpot = IGPlus_DetLateSpot;
			IGPlus_bDetThrowSpot = true;
			IGPlus_DetThrowRule = 2;
		}
	}
	CurrentTimeStamp = TS; // the throw time, the disc's age at a translocate
	ViewRotation.Pitch = View >>> 16;
	ViewRotation.Yaw = View & 0xFFFF;
	ViewRotation.Roll = 0;
	TL.IGPlus_DetServerStep(self, TS, Action, false, false, MoveTS - TS);
	IGPlus_bDetThrowSpot = false;
	if ((Action & 3) == 1 && TL.TTarget != None && TL.IGPlus_ThrowTS == TS) {
		if (bSpotKnown == false) {
			// Its move is gone and no spot came: nothing tells where the client stood.
			IGPlus_DetThrowGapInfo = "throwGap=unknown";
		} else {
			if (IGPlus_DetThrowRule != 0) {
				Gap = vect(0,0,0);
				IGPlus_DetStatLateSpot++;
			}
			IGPlus_DetThrowGapInfo = "throwGap="$class'ST_ShockProj'.static.IGPlus_Vec(Gap);
			// From our own spot after all, more than 4uu off: the thrower gets
			// our disc's path, as after a throw on time (IGPlus_DetAfterThrow).
			if (VSize(Gap) > 4.0) {
				if (Mover(Base) == none && ST_TranslocatorTarget(TL.TTarget) != None)
					TL.IGPlus_DetServerDiscChanged(ST_TranslocatorTarget(TL.TTarget));
				IGPlus_DetStatThrowApart++;
				IGPlus_DetTlocLog("throw-apart", "dist="$int(VSize(Gap))@"late="$(MoveTS - TS));
			}
		}
	}
	CurrentTimeStamp = SavedTS;
	ViewRotation = SavedView;
}

// Server: do we take the spot a late throw's thrower stood at? Within 32uu of
// ours with a clear line for body and eyes, as for a throw on time. Not on a
// lift, where that spot is inside our lift.
// ponytail: the fixed 32uu of IGPlus_DetThrowOrigin. A throw late in a long
// burst is further off (the thrower ran on) and leaves from our own spot.
function bool IGPlus_DetLateSpotTaken(vector Spot) {
	local vector Eye;
	local float Dist;

	if (IsInState('Dying') || Mover(Base) != none)
		return false;
	Dist = VSize(Spot - Location);
	if (Dist < 0.5 || Dist > 32.0)
		return false;
	Eye = BaseEyeHeight * vect(0,0,1);
	return IGPlus_PSAClear(Spot, Location) && IGPlus_PSAClear(Spot + Eye, Location + Eye);
}

// Server: a translocator action while our translocator isn't up. The
// client's was, so our switch to it is still finishing: hold the action until
// ours is up (IGPlus_DetRunSwitchHeld). Not switching to it: refuse it now, so
// the client drops the disc it threw at once, not at its next translocate.
function IGPlus_DetNotHeld(int Action, float TS, int View) {
	if (ST_Translocator(PendingWeapon) != None && IGPlus_DetSwitchHeldAction == 0 && IsInState('Dying') == false) {
		IGPlus_DetSwitchHeldAction = Action;
		IGPlus_DetSwitchHeldTS = TS;
		IGPlus_DetSwitchHeldView = View;
		// ponytail: one held action, a second during the same switch is refused
		IGPlus_DetTlocLog("held-for-switch", class'ST_Translocator'.static.IGPlus_DetActionName(Action)@"weapon="$string(Weapon));
		return;
	}
	IGPlus_DetRefuseNotHeld(Action, TS);
}

function IGPlus_DetRefuseNotHeld(int Action, float TS) {
	local Inventory Inv;

	for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
		if (ST_Translocator(Inv) != None && ST_Translocator(Inv).IGPlus_IsDetMode()) {
			ST_Translocator(Inv).IGPlus_DetReject(Action & 3, TS, "not-held weapon="$string(Weapon)@"pending="$string(PendingWeapon));
			return;
		}
}

// Server: the held action runs once our translocator is up, as late as it
// waited (a throw's disc flies ahead that far).
function IGPlus_DetRunSwitchHeld(float MoveTS) {
	local int Action;

	if (IGPlus_DetSwitchHeldAction == 0)
		return;
	Action = IGPlus_DetSwitchHeldAction;
	if (ST_Translocator(Weapon) != None) {
		IGPlus_DetSwitchHeldAction = 0;
		IGPlus_DetRunAction(Action, IGPlus_DetSwitchHeldTS, IGPlus_DetSwitchHeldView, MoveTS, true);
		return;
	}
	// ponytail: half a second for our switch, a longer one refuses
	if (ST_Translocator(PendingWeapon) != None && MoveTS - IGPlus_DetSwitchHeldTS < 0.5 && IsInState('Dying') == false)
		return;
	IGPlus_DetSwitchHeldAction = 0;
	IGPlus_DetRefuseNotHeld(Action, IGPlus_DetSwitchHeldTS);
}

function IGPlus_DetRunHeld(float MoveTS) {
	local int i, N;

	N = IGPlus_DetHeldCount;
	IGPlus_DetHeldCount = 0;
	// Held through a pause: no time passed for our disc meanwhile, none is late.
	for (i = 0; i < N; i++) {
		if ((IGPlus_DetHeldFlags[i] & 4) != 0)
			IGPlus_DetRunAction(IGPlus_DetHeldAction[i], IGPlus_DetHeldTS[i], IGPlus_DetHeldView[i], MoveTS, true);
		else
			IGPlus_DetRunAction(IGPlus_DetHeldAction[i], IGPlus_DetHeldTS[i], IGPlus_DetHeldView[i], IGPlus_DetHeldTS[i], true);
	}
}

// bWarp: the warp fix skips this move, and the client is put back to where we
// have it: a throw from there would not be the one it made, so refuse it now.
function IGPlus_DetHoldAction(int Action, float TS, int View, bool bWarp) {
	local int i;

	if ((Action & 3) == 0 || Action > 7 || TS <= IGPlus_DetLastActionSeenTS)
		return;
	for (i = 0; i < IGPlus_DetHeldCount; i++)
		if (IGPlus_DetHeldTS[i] >= TS)
			return; // held already (or older than what is)
	IGPlus_DetTlocLog("held", class'ST_Translocator'.static.IGPlus_DetActionName(Action)@"warp="$bWarp);
	// (No resend can bring it back: this move put us past it.)
	if (bWarp && Action == 1) {
		if (ST_Translocator(Weapon) != none)
			ST_Translocator(Weapon).IGPlus_ClientDetSync(false, TS, TS);
		return;
	}
	// ponytail: 4 held actions (0.4s of them); a longer stall loses the newest
	if (IGPlus_DetHeldCount >= ArrayCount(IGPlus_DetHeldAction))
		return;
	i = IGPlus_DetHeldCount++;
	IGPlus_DetHeldAction[i] = Action;
	IGPlus_DetHeldTS[i] = TS;
	IGPlus_DetHeldFlags[i] = 0;
	if (bWarp)
		IGPlus_DetHeldFlags[i] = 4;
	IGPlus_DetHeldView[i] = View;
}

// Server: the time stamp of the old move this move carries (0: none).
static final function float IGPlus_OldMoveTimeStamp(float TimeStamp, int OldMoveData1) {
	local int Offset;

	Offset = OldMoveData1 & 0x3FF;
	if (Offset == 0 || Offset == 0x3FF)
		return 0.0;
	return TimeStamp - float(Offset) * 0.001;
}

// Server: will the time margin check below throttle this move (DeltaTime 0)?
// MoveDelta: the move's own length (after a pause the check uses no more).
function bool IGPlus_DetWouldThrottle(float MoveTS, float ServerDeltaTime, float StartTS, float MoveDelta) {
	local float Delta;

	if (ServerTimeStamp <= 0.0)
		return false;
	Delta = MoveTS - StartTS;
	if (bWasPaused)
		Delta = FMin(Delta, MoveDelta);
	return TimeMargin + Delta - 1.01 * ServerDeltaTime > MaxTimeMargin;
}

// The resent action's view, 12 bits each (DetRedoData bits 8-19 yaw, 20-31 pitch).
static final function int IGPlus_DetUnpackRedoView(int RedoData) {
	return ((((RedoData >>> 20) & 0xFFF) << 4) << 16) | (((RedoData >>> 8) & 0xFFF) << 4);
}

// Server, at each client error check: did the client translocate when we
// did, and land where we did?
// LandGap: our spot minus the client's (before a taken landing moved us).
function IGPlus_DetTlocCheck(int ClientTlocCounter, float ClientLocError, bool bLandingTaken, vector LandGap) {
	local int Diff;

	if (IGPlus_DetTranslocator == false)
		return;
	// A dead player's moves carry no count (state Dying strips it), so there
	// is nothing to compare: it read as diff=2 whenever our own count was 2.
	if (Health <= 0) {
		IGPlus_bDetTlocCheckLanding = false;
		return;
	}
	Diff = (ClientTlocCounter - TlocCounter) & 3;
	if (Diff == 0) {
		// Over 8uu apart. Within the bubble we took the client's spot and
		// nobody saw a thing: counted for the summary, no line.
		if (IGPlus_bDetTlocCheckLanding && ClientLocError > 64.0) {
			if (bLandingTaken) {
				IGPlus_DetStatAbsorbed++;
			} else {
				IGPlus_DetStatApart++;
				IGPlus_DetTlocLog("landed-apart", "dist="$int(Sqrt(ClientLocError))
					@"landGap="$class'ST_ShockProj'.static.IGPlus_Vec(LandGap)@IGPlus_DetTlocInfo);
			}
		}
		// Speeds (server/client) after the translocate and going into it: a
		// fall speed one side carried in and the other didn't widens the gap.
		if (IGPlus_bDetTlocCheckLanding && Abs(Velocity.Z - IGPlus_DetClientVel.Z) > 50.0)
			IGPlus_DetTlocLog("velocity-apart", "vz="$int(Velocity.Z)$"/"$int(IGPlus_DetClientVel.Z)
				@"vxy="$int(VSize((Velocity - IGPlus_DetClientVel) * vect(1,1,0)))
				@"beforeVz="$int(IGPlus_DetTlocPreVZ)$"/"$int(IGPlus_DetTlocPreClientVZ)
				@"beforePhys="$IGPlus_DetTlocPrePhys$"/"$IGPlus_DetTlocPreClientPhys
				@"phys="$int(Physics)$"/"$IGPlus_DetClientPhys
				@"dist="$int(Sqrt(ClientLocError))@"taken="$bLandingTaken);
		IGPlus_bDetTlocCheckLanding = false;
		IGPlus_bDetTlocMismatch = false;
		return;
	}
	IGPlus_bDetTlocCheckLanding = false;
	if (IGPlus_bDetTlocMismatch)
		return; // still the same one: the client hasn't had our correction yet
	IGPlus_bDetTlocMismatch = true;
	// Counts apart but both within 16uu: nothing on screen parted (over 90%
	// of these lines were that).
	if (Diff != 2 && ClientLocError <= 256.0)
		return;
	if (Diff == 1)
		IGPlus_DetTlocLog("client-only-translocate", "dist="$int(Sqrt(ClientLocError)));
	else if (Diff == 3) {
		// Without predicted translocation the client always waits for us.
		if (IGPlus_PredictsTranslocation())
			IGPlus_DetTlocLog("server-only-translocate", "dist="$int(Sqrt(ClientLocError))@IGPlus_DetTlocInfo);
	}
	else
		IGPlus_DetTlocLog("translocate-count-mismatch", "diff=2");
}

// Server: right after a translocate both sides made, the client's spot stands
// if it is within 16uu and we can move there from ours (the discs a few uu
// apart, not worth a correction). Like movement: within a small bubble, on
// our map.
function bool IGPlus_DetTakeClientLanding(int ClientTlocCounter, EPhysics ClientPhysics, vector ClientLocAbs, float ClientLocError) {
	local vector OldLoc;

	if (IGPlus_bDetTlocCheckLanding == false || ClientTlocCounter != TlocCounter || ClientPhysics != Physics
		|| ClientLocError <= 3.0 || ClientLocError > 256.0)
		return false;
	// A swept move: never through a wall or a player.
	OldLoc = Location;
	Move(ClientLocAbs - Location);
	if (VSize(Location - ClientLocAbs) < 0.5)
		return true;
	SetLocation(OldLoc);
	return false;
}

function IGPlus_ApplyServerMove(IGPlus_ServerMove SM) {
	local float ServerDeltaTime;
	local Actor DbgOldBase;
	local float DeltaTime;
	local float SimTime;
	local float SimStep;
	local rotator DeltaRot;
	local rotator Rot;
	local int maxPitch;
	local int ViewPitch;
	local int ViewYaw;
	local int ClientTlocCounter;
	local bool NewbPressedJump;
	local bool NewbRun;
	local bool NewbDuck;
	local bool NewbJumpStatus;

	local EDodgeDir DodgeMove;
	local EPhysics ClientPhysics;
	local byte ClientRoll;
	local int MergeCount;
	local int MoveIndex;

	local int JumpIndex;
	local float JumpPos;
	local bool bDoJump;

	local int DodgeIndex;
	local float DodgePos;
	local EDodgeDir DoDodge;

	local int RunChangeIndex;
	local float RunChangePos;
	local bool bRunActual;

	local int DuckChangeIndex;
	local float DuckChangePos;
	local bool bDuckActual;

	local int FireIndex;
	local float FirePos;
	local bool bFired;
	local bool bForceFire;

	local int AltFireIndex;
	local float AltFirePos;
	local bool bAltFired;
	local bool bForceAltFire;

	local bool bDetWholeMove;
	local IGPlus_WeaponImplementationBase WImpBase;
	local bool bDetBlockLegacyFire;
	local bool bDetCarryFire;
	local Weapon DetWeapon;
	local bool bDetMoveAcceptedForFire;
	local bool bDetFirePress;
	local float PSAPrevTS;
	local int RedoAction;
	local int Redo2Action;
	local float OldTS;

	debugServerMoveCallsReceived += 1;

	if (bDeleteMe) {
		ClientDebugMessage("Reject Irrelevant Move");
		return;
	}

	if (Role < ROLE_Authority) {
		zzbLogoDone = True;
		zzTrackFOV = 0;
		zzbDemoPlayback = True;
		return;
	}

	zzKickReady = Max(zzKickReady - 1,0);

	if (CurrentTimeStamp >= SM.TimeStamp) {
		ClientDebugMessage("Reject Outdated Move:"@CurrentTimeStamp@SM.TimeStamp);
		return;
	}
	// A gap before this move: moves that never arrived, with any throw or
	// translocate in them. Context for the [DET-TLOC] lines.
	if (ServerTimeStamp > 0.0 && SM.TimeStamp - SM.MoveDeltaTime > CurrentTimeStamp + 0.003) {
		IGPlus_DetLostMoves++;
		IGPlus_DetLastLossTS = Level.TimeSeconds;
	}

	ClientTlocCounter =          (SM.MiscData & 0x0C000000) >> 26;
	IGPlus_DetMoveTlocCounter = ClientTlocCounter;
	bFired         =             (SM.MiscData & 0x02000000) != 0;
	bAltFired      =             (SM.MiscData & 0x01000000) != 0;
	MergeCount     =             (SM.MiscData & 0x00F80000) >> 19;
	NewbRun        =             (SM.MiscData & 0x00040000) != 0;
	NewbDuck       =             (SM.MiscData & 0x00020000) != 0;
	NewbJumpStatus =             (SM.MiscData & 0x00010000) != 0;
	ClientPhysics  =  GetPhysics((SM.MiscData & 0x0000F000) >> 12);
	DodgeMove      = GetDodgeDir((SM.MiscData & 0x00000F00) >> 8);
	ClientRoll     =             (SM.MiscData & 0x000000FF);

	bForceFire      = (SM.MiscData2 & 0x80000000) != 0;
	bForceAltFire   = (SM.MiscData2 & 0x40000000) != 0;
	FireIndex       = (SM.MiscData2 & 0x3E000000) >> 25;
	AltFireIndex    = (SM.MiscData2 & 0x01F00000) >> 20;
	DuckChangeIndex = (SM.MiscData2 & 0x000F8000) >> 15;
	RunChangeIndex  = (SM.MiscData2 & 0x00007C00) >> 10;
	DodgeIndex      = (SM.MiscData2 & 0x000003E0) >> 5;
	JumpIndex       = (SM.MiscData2 & 0x0000001F);

	if (DodgeMove > DODGE_None && DodgeMove < DODGE_Active)
		ClientDebugMessage("Received Dodge"@DodgeMove@SM.TimeStamp);

	if (ServerTimeStamp == 0.0) {
		ServerDeltaTime = SM.MoveDeltaTime;
	} else {
		ServerDeltaTime = Level.TimeSeconds - ServerTimeStamp;
		if (Level.Pauser == "" && bWasPaused)
			ServerDeltaTime = FMin(ServerDeltaTime, SM.MoveDeltaTime);
	}
	// (A queued move was measured when it arrived, IGPlus_ABIntercept.)
	if (Level.Pauser == "" && !bWasPaused && IGPlus_ABPlaying == false)
		IGPlus_DetUpdateFireClockLead(SM.TimeStamp, ServerDeltaTime);

	if (zzUTPure.Settings.bEnableWarpFix && ServerDeltaTime > zzUTPure.Settings.WarpFixDelay) {
		IGPlus_SkipMovesUntilNextTick = true;
	}

	// Deterministic translocator: an action whose own move was lost (or that
	// we held back), at its own time and where the client did it, in time
	// order with the old move below (the gap's movement after both). Only for
	// a move we run: a throttled one (too far ahead) loses its actions.
	RedoAction = 0;
	Redo2Action = 0;
	IGPlus_DetLateSpotTS = SM.DetRedoSpotTS;
	IGPlus_DetLateSpot = SM.DetRedoSpot;
	if (IGPlus_DetTranslocator) {
		// A resend is for a move between the last one we had and this one.
		if (IGPlus_DetRedoDue(SM.DetRedoData, SM.DetRedoTS, CurrentTimeStamp, SM.TimeStamp))
			RedoAction = SM.DetRedoData & 7;
		// So is the action before it, lost with it. That one runs first.
		if (IGPlus_DetRedoDue(SM.DetRedo2Data, SM.DetRedo2TS, CurrentTimeStamp, SM.TimeStamp)
			&& (RedoAction == 0 || SM.DetRedo2TS < SM.DetRedoTS))
			Redo2Action = SM.DetRedo2Data & 7;
		OldTS = IGPlus_OldMoveTimeStamp(SM.TimeStamp, SM.OldMoveData1);
		if (RedoAction != 0 || Redo2Action != 0 || IGPlus_DetHeldCount > 0) {
			if (Level.Pauser != "" || IGPlus_SkipMovesUntilNextTick) {
				if (Redo2Action != 0)
					IGPlus_DetHoldAction(Redo2Action, SM.DetRedo2TS, IGPlus_DetUnpackRedoView(SM.DetRedo2Data), Level.Pauser == "");
				if (RedoAction != 0)
					IGPlus_DetHoldAction(RedoAction, SM.DetRedoTS, IGPlus_DetUnpackRedoView(SM.DetRedoData), Level.Pauser == "");
				RedoAction = 0;
				Redo2Action = 0;
			} else if (IGPlus_DetWouldThrottle(SM.TimeStamp, ServerDeltaTime, FMax(CurrentTimeStamp, OldTS), SM.MoveDeltaTime)) {
				RedoAction = 0;
				Redo2Action = 0;
			} else {
				IGPlus_DetRunHeld(SM.TimeStamp);
				if (Redo2Action != 0 && (OldTS <= CurrentTimeStamp || SM.DetRedo2TS < OldTS)) {
					IGPlus_DetRunAction(Redo2Action, SM.DetRedo2TS, IGPlus_DetUnpackRedoView(SM.DetRedo2Data), SM.TimeStamp);
					Redo2Action = 0;
				}
				if (RedoAction != 0 && Redo2Action == 0 && (OldTS <= CurrentTimeStamp || SM.DetRedoTS < OldTS)) {
					IGPlus_DetRunAction(RedoAction, SM.DetRedoTS, IGPlus_DetUnpackRedoView(SM.DetRedoData), SM.TimeStamp);
					RedoAction = 0;
				}
			}
		}
	}

	if (bWasPaused == false && IGPlus_SkipMovesUntilNextTick == false) {
		if (IGPlus_OldServerMove(SM.TimeStamp, SM.OldMoveData1, SM.OldMoveData2)) {
			xxFakeCAP(CurrentTimeStamp);
			LastCAPTime = Level.TimeSeconds;
		}
	}
	// A resent action that came after the old move: now, the older one first.
	if (Redo2Action != 0)
		IGPlus_DetRunAction(Redo2Action, SM.DetRedo2TS, IGPlus_DetUnpackRedoView(SM.DetRedo2Data), SM.TimeStamp);
	if (RedoAction != 0)
		IGPlus_DetRunAction(RedoAction, SM.DetRedoTS, IGPlus_DetUnpackRedoView(SM.DetRedoData), SM.TimeStamp);

	if (ServerTimeStamp == 0.0) {
		DeltaTime = SM.MoveDeltaTime;
	} else {
		DeltaTime = SM.TimeStamp - CurrentTimeStamp;
		if (Level.Pauser == "" && bWasPaused)
			DeltaTime = FMin(DeltaTime, SM.MoveDeltaTime);
	}

	ExtrapolationDelta += (ServerDeltaTime - DeltaTime);

	if (ServerTimeStamp > 0) {
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * ServerDeltaTime;
		if ( TimeMargin > MaxTimeMargin ) {
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			IGPlus_LogMoveHeld(DeltaTime, ServerDeltaTime, SM.TimeStamp);
			DeltaTime = 0;
			ClientDebugMessage("["$Level.TimeSeconds$"]"@PlayerReplicationInfo.PlayerName@"MaxTimeMargin exceeded ("$TimeMargin$")", 'IGPlus');
		}
	}
	bDetMoveAcceptedForFire = Level.Pauser == ""
		&& DeltaTime > 0
		&& !IGPlus_SkipMovesUntilNextTick;

	IGPlus_MoveFrameDelta = SM.MoveDeltaTime / float(MergeCount + 1);

	bHaveReceivedServerMove = true;
	LastServerMoveParams.Location = SM.ClientLocation;
	LastServerMoveParams.Base = SM.ClientBase;
	LastServerMoveParams.Physics = ClientPhysics;
	LastServerMoveParams.TlocCounter = ClientTlocCounter;
	// Precise Rewind Time: when this move's shots saw the other players.
	if ((SM.PRTData & 0x8000) != 0) {
		IGPlus_PRTNote(SM.PRTData);
		IGPlus_DetReportSweep(SM.TimeStamp);
	}
	IGPlus_DetPrevClientVel = IGPlus_DetClientVel;
	IGPlus_DetPrevClientPhys = IGPlus_DetClientPhys;
	IGPlus_DetClientVel = SM.ClientVelocity;
	IGPlus_DetClientPhys = ClientPhysics;

	// View components
	ViewPitch = (SM.View >>> 16);
	ViewYaw = (SM.View & 0xFFFF);

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	if ((Level.Pauser == "") && (DeltaTime > 0)) {
		if (RemoteRole == ROLE_AutonomousProxy && zzUTPure.Settings.bEnablePingCompensatedSpawn) {
			if (bHidden && (IsInState('PlayerWalking') || IsInState('PlayerSwimming'))) {
				bClientDead = false;
				bHidden = false;
				SetCollision(true, true, true);
				IGPlus_SendRespawnNoficiation();
			}
		}
	}

	PSAPrevTS = CurrentTimeStamp;
	CurrentTimeStamp = SM.TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = ClientRoll << 8;
	Rot.Yaw = ViewYaw;
	if ((Physics == PHYS_Swimming) || (Physics == PHYS_Flying))
		maxPitch = 2 * RotationRate.Pitch;
	else
		maxPitch = RotationRate.Pitch;

	Rot.Pitch = Clamp((ViewPitch << 16) >> 16, -maxPitch, maxPitch) & 0xFFFF;

	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);

	IGPlus_DetTrackPendingWeapon(CurrentTimeStamp);
	IGPlus_DetCheckSwitchWedge();

	// The v4 ServerMove transport bypasses ServerApplyInput, so trace here or
	// server captures stay header-only on non-input-replication presets.
	if (bTraceInput && IGPlus_InputLogFile != none)
		IGPlus_InputLogFile.LogServerMove(SM);

	// Predicted switch: holster/equip on this move's timestamp, before binding.
	IGPlus_PSServerAdvance(SM.TimeStamp);

	WImpBase = IGPlus_GetWeaponImplementationBase();
	// bDetReady marks client-predicted steps; trust is the binding/window gates.
	DetWeapon = IGPlus_DetResolveBoundWeapon(SM.DetWeaponIndex, true);
	// Hard-block legacy fire fallback for deterministic weapons.
	// A resolved DetWeapon is active by construction.
	bDetCarryFire = IGPlus_DetCarriesFire(DetWeapon);
	bDetBlockLegacyFire = bDetCarryFire == false && ((DetWeapon != none) || IGPlus_IsDetActiveWeapon(Weapon)
		|| IGPlus_DetStaleBindingBlocks(SM.DetWeaponIndex)
		|| (ST_Translocator(Weapon) != none && ST_Translocator(Weapon).IGPlus_IsDetMode()));

	// A new fire press: for the deterministic translocator's pose below.
	bDetFirePress = bFired && IGPlus_LastFireEndHeld == false;
	IGPlus_LastFireEndHeld = bFired;
	IGPlus_LastAltEndHeld = bAltFired;

	// Whole-move dispatch: one weapon step per v3 ServerMove.
	bDetWholeMove = (DetWeapon != none);
	// A ready hint with fire input but no valid binding: the client showed a
	// shot from a weapon the server is not holding. Counted for the summary,
	// logged while TraceInput is on.
	if (!bDetWholeMove && SM.bDetReady && SM.DetWeaponIndex != IGPLUS_DetWEAPON_None
		&& (bFired || bAltFired || bForceFire || bForceAltFire)
		&& Level.TimeSeconds - IGPlus_DetLastRejectLogTS > 1.0) {
		IGPlus_DetLastRejectLogTS = Level.TimeSeconds;
		IGPlus_StatShotUnbound++;
		if (bTraceInput)
			IGPlus_EventLog("[DET-UNBOUND]"@PlayerReplicationInfo.PlayerName@"index="$SM.DetWeaponIndex
				@"step="$SM.TimeStamp@"weapon="$Weapon@"pending="$PendingWeapon
				@"prev="$IGPlus_DetPrevWeapon@"prevStep="$IGPlus_DetPrevWeaponStepTS);
	}

	if (bDetWholeMove) {
		// A shock move's charge data is the client's verdict on its own disc.
		// and on its own balls (IGPlus_OwnBallVerdict).
		if (ST_ShockRifle(DetWeapon) != none) {
			IGPlus_DetOwnBeamMode = SM.DetChargeData & 3;
			IGPlus_OwnBallVerdict = (SM.DetChargeData >> 2) & 3;
		} else if (SM.DetChargeData >= IGPLUS_HIT_MISS && (SM.DetChargeData & 3) != 3
			&& (ST_SuperShockRifle(DetWeapon) != none || ST_SniperRifle(DetWeapon) != none)) {
			// The client's verdict on this shot (IGPlus_HitCompare), and
			// whether its drawn bodies said the opposite.
			IGPlus_ClientHitVerdict = SM.DetChargeData & 11;
			IGPlus_bShotDrawnDiffers = (SM.DetChargeData & IGPLUS_HIT_DRAWNDIFF) != 0;
		}
		// The eye height the client traced this move's shot from.
		if (ST_SuperShockRifle(DetWeapon) != none || ST_SniperRifle(DetWeapon) != none)
			IGPlus_ShotEyeByte = SM.ShotEye;
		IGPlus_DetProcessStep(
			DetWeapon,
			SM.TimeStamp,
			ViewRotation,
			IGPlus_PSAShotOrigin(SM, PSAPrevTS, MergeCount),
			bFired,
			bAltFired,
			bForceFire,
			bForceAltFire,
			true,
			SM.bDetReady && IGPlus_DetFireClockOK(),
			SM.DetChargeData,
			false,
			false
		);
		IGPlus_DetOwnBeamMode = 0;
		IGPlus_OwnBallVerdict = 0;
		IGPlus_ClientHitVerdict = 0;
		IGPlus_bShotDrawnDiffers = false;
		IGPlus_ShotEyeByte = 0;
		// Deterministic weapons execute shots directly from step processing.
		// Keep fire latches cleared to avoid legacy state-machine refire.
		// (Not when the buttons also go to the classic weapon in hand.)
		if (bDetCarryFire == false) {
			bFire = 0;
			bAltFire = 0;
		}
	}

	// Deterministic translocator: the client's action, before this move's
	// movement like on the client.
	// A move we don't run keeps its action for the next one we do (paused,
	// warp fix); a throttled one (too far ahead) loses it, as before.
	if (bDetMoveAcceptedForFire == false && SM.DetChargeData <= 7 && (SM.DetChargeData & 3) != 0
		&& IGPlus_DetTranslocator && SM.DetWeaponIndex == IGPLUS_DetWEAPON_None) {
		if (Level.Pauser != "" || IGPlus_SkipMovesUntilNextTick)
			IGPlus_DetHoldAction(SM.DetChargeData, SM.TimeStamp, SM.View, Level.Pauser == "");
		else
			IGPlus_DetTlocLog("dropped", class'ST_Translocator'.static.IGPlus_DetActionName(SM.DetChargeData)@"reason=time-margin");
	}
	// Handled here (or not, on another weapon) like before: never again from a resend.
	if (bDetMoveAcceptedForFire && IGPlus_DetTranslocator && SM.DetWeaponIndex == IGPLUS_DetWEAPON_None
		&& SM.DetChargeData <= 7 && (SM.DetChargeData & 3) != 0)
		IGPlus_DetLastActionSeenTS = FMax(IGPlus_DetLastActionSeenTS, SM.TimeStamp);
	if (bDetMoveAcceptedForFire && IGPlus_DetTranslocator && SM.DetWeaponIndex == IGPLUS_DetWEAPON_None) {
		IGPlus_DetRunSwitchHeld(SM.TimeStamp);
		if (ST_Translocator(Weapon) != none && ST_Translocator(Weapon).IGPlus_IsDetMode()) {
			// (1: a throw.) Its disc leaves from where the thrower's did.
			IGPlus_DetThrowRule = 0;
			if ((SM.DetChargeData & 3) == 1 && SM.DetChargeData <= 7) {
				IGPlus_DetThrowSpot = IGPlus_DetThrowOrigin(SM, PSAPrevTS, MergeCount);
				IGPlus_bDetThrowSpot = true;
			}
			// Stock's server puts the model in the firing pose on a fire press
			// the client did not throw on (PlayerPawn.Fire: bPointing, then
			// PlayFiring), so a recall raises the arm and a throw does not. A
			// throw and every alt-fire press reach stock's server as forced
			// taps, which skip that call. Our step skips it for every press.
			if (bDetFirePress && ((SM.DetChargeData & 3) != 1 || SM.DetChargeData > 7)) {
				Weapon.bPointing = true;
				ST_Translocator(Weapon).IGPlus_DetPosePressTS = SM.TimeStamp;
				PlayFiring();
			}
			ST_Translocator(Weapon).IGPlus_DetServerStep(self, SM.TimeStamp, SM.DetChargeData, bFired, bAltFired);
			IGPlus_bDetThrowSpot = false;
			IGPlus_DetAfterThrow(SM, PSAPrevTS);
		} else if (SM.DetChargeData <= 7 && (SM.DetChargeData & 3) != 0)
			IGPlus_DetNotHeld(SM.DetChargeData, SM.TimeStamp, SM.View);
	}

	// Complete fast weapon switch after Det dispatch so Det targets the
	// pre-switch weapon the client was actually firing.
	if (IGPlus_UseFastWeaponSwitch && PendingWeapon != None) {
		ChangedWeapon();
		// A translocator action held for this very switch runs now.
		if (bDetMoveAcceptedForFire)
			IGPlus_DetRunSwitchHeld(SM.TimeStamp);
	}

	DbgOldBase = Base;

	// Predict new position
	if ((Level.Pauser == "") && (DeltaTime > 0) && (IGPlus_SkipMovesUntilNextTick == false)) {
		if (IGPlus_ShouldJitterBound() && DeltaTime > zzUTPure.Settings.MaxJitterTime) {
			SimTime = DeltaTime - zzUTPure.Settings.MaxJitterTime;
			if (SimTime >= 0.005 || bIs469Server) {
				SimMoveAutonomous(SimTime);
				DeltaTime = zzUTPure.Settings.MaxJitterTime;
			}
		}

		MergeCount++;

		SimStep = DeltaTime / float(MergeCount);

		if (bIs469Server == false && SimStep < 0.005) {
			JumpPos = float(JumpIndex) / float(MergeCount);
			DodgePos = float(DodgeIndex) / float(MergeCount);
			RunChangePos = float(RunChangeIndex) / float(MergeCount);
			DuckChangePos = float(DuckChangeIndex) / float(MergeCount);
			FirePos = float(FireIndex) / float(MergeCount);
			AltFirePos = float(AltFireIndex) / float(MergeCount);

			MergeCount = int(DeltaTime * 100) + 1;
			SimStep = DeltaTime / float(MergeCount);

			JumpIndex = int(JumpPos * MergeCount);
			DodgeIndex = int(DodgePos * MergeCount);
			RunChangeIndex = int(RunChangePos * MergeCount);
			DuckChangeIndex = int(DuckChangePos * MergeCount);
			FireIndex = int(FirePos * MergeCount);
			AltFireIndex = int(AltFirePos * MergeCount);
		}

			for (MoveIndex = 0; MoveIndex < MergeCount; MoveIndex++) {
			if (MoveIndex == JumpIndex)
				bDoJump = NewbPressedJump;
			else
				bDoJump = false;

			if (MoveIndex == DodgeIndex)
				DoDodge = DodgeMove;
			else
				DoDodge = DODGE_None;

			if (MoveIndex == FireIndex && (!bDetWholeMove || bDetCarryFire)) {
				if (bDetBlockLegacyFire) {
					bFire = 0;
				} else {
					if (bFired) {
						if (bForceFire && (Weapon != None))
							Weapon.ForceFire();
						else if (bFire == 0)
							Fire(0);
						bFire = 1;
					} else {
						bFire = 0;
					}
				}
			}

				if (MoveIndex == AltFireIndex && (!bDetWholeMove || bDetCarryFire)) {
					if (bDetBlockLegacyFire) {
						bAltFire = 0;
					} else {
						if (bAltFired || bForceAltFire) {
						if (bForceAltFire && (Weapon != None))
							Weapon.ForceAltFire();
						else if (bAltFire == 0)
							AltFire(0);
						if (bAltFired)
							bAltFire = 1;
						else
							bAltFire = 0;
					} else {
						bAltFire = 0;
						}
					}
				}
					bRunActual = (MoveIndex < RunChangeIndex) ^^ NewbRun;
				bDuckActual = (MoveIndex < DuckChangeIndex) ^^ NewbDuck;

			IGPlus_MoveAutonomous(SimStep, bRunActual, bDuckActual, bDoJump, DoDodge, SM.ClientAcceleration, DeltaRot / MergeCount);
		}

		if (IGPlus_DidTranslocate) {
			TlocCounter = (TlocCounter + 1) & 3;
			IGPlus_DidTranslocate = false;
		}
		IGPlus_DebugLiftJumpTop(DbgOldBase);

		bWasPaused = false;
	}

	// Hammer charged and let go on this move: its push lands at the end of it,
	// as on the client (ST_ImpactHammer.IGPlus_MoveEnd). bFire is cleared on a
	// move bound to a deterministic weapon, bFired is the move's button.
	// Not on the press's own move when a predicted switch brings the hammer up
	// on it (fast weapon switch): the client made that move with the weapon
	// before, its hammer starts on the next one. A fire key in the same frame
	// as the switch key is then held at the bring-up on both sides, no press.
	if (ST_ImpactHammer(Weapon) != None && (Weapon != IGPlus_PSTarget || CurrentTimeStamp > IGPlus_PSTS))
		ST_ImpactHammer(Weapon).IGPlus_MoveEnd(CurrentTimeStamp, bFire != 0, bFired);

	// Our shock ball waiting at a wall for our moves (ST_ShockProj.IGPlus_WallWait)
	// explodes at the end of the move that gets there, as it stops on our
	// screen in that frame: a beam on this move was still tested against it,
	// and its push on us lands on this move, as our client predicted.
	// One waiting on something it touched (IGPlus_TouchWait) is let go here too.
	if (IGPlus_WallBall != None) {
		if (IGPlus_WallBall.bDeleteMe)
			IGPlus_WallBall = None;
		else
			IGPlus_WallBall.IGPlus_WallWaitCheck();
	}

	if (IGPlus_SKQueueCount > 0)
		IGPlus_SKApplyDue(CurrentTimeStamp, none);

	IGPlus_PSALastClientLoc = SM.ClientLocation;
	if (SM.ClientBase != none)
		IGPlus_PSALastClientLoc += SM.ClientBase.Location;
	IGPlus_PSALastClientTS = SM.TimeStamp;

	// Our client picked its disc up on this move (or one before it).
	if (IGPlus_DetPickupTS > 0.0 && SM.TimeStamp >= IGPlus_DetPickupTS)
		IGPlus_DetPickupDue();

	if (bDetMoveAcceptedForFire)
		IGPlus_DetFinalizeExpiredPrevWeapon();
}

function IGPlus_CheckClientError() {
	local vector ClientLoc;
	local EPhysics ClientPhysics;
	local vector ClientLocAbs;
	local int ClientTlocCounter;
	local vector LocDelta;
	local float ClientLocError;
	local float MaxLocError;
	local bool bForceUpdate;
	local bool bLandingTaken;
	local bool bTlocHeld;

	if (bHaveReceivedServerMove == false)
		return;

	ClientLoc = LastServerMoveParams.Location;
	ClientPhysics = LastServerMoveParams.Physics;
	ClientLocAbs = ClientLoc;
	if (LastServerMoveParams.Base != none)
		ClientLocAbs += LastServerMoveParams.Base.Location;
	ClientTlocCounter = LastServerMoveParams.TlocCounter;

	LocDelta = Location - ClientLocAbs;
	ClientLocError = LocDelta Dot LocDelta;
	debugClientLocError = ClientLocError;
	bLandingTaken = IGPlus_DetTakeClientLanding(ClientTlocCounter, ClientPhysics, ClientLocAbs, ClientLocError);
	// A translocate we hold for our switch to the translocator
	// (IGPlus_DetNotHeld): the client is at its disc already. We follow when
	// ours is up, or refuse and correct then. A correction now put the client
	// back for those moves and our own translocate sent it there again.
	bTlocHeld = IGPlus_DetHoldsTloc(IGPlus_DetSwitchHeldAction, ClientTlocCounter, TlocCounter);
	if (bTlocHeld == false)
		IGPlus_DetTlocCheck(ClientTlocCounter, ClientLocError, bLandingTaken, LocDelta);
	if (bLandingTaken)
		ClientLocError = 0.0;

	// Calculate how far off we allow the client to be from the predicted position
	MaxLocError = 3.0;

	clientLastUpdateTime = ServerTimeStamp;
	ClearLastServerMoveParams();

	bForceUpdate = zzbForceUpdate || (zzForceUpdateUntil >= ServerTimeStamp) ||
		(ClientLocError > MaxLocError) ||
		(ClientTlocCounter != TlocCounter && IGPlus_NotifiedTranslocate == false);

	debugClientForceUpdate = bForceUpdate;

	if (bForceUpdate && bTlocHeld == false) {
		// (sv, cv: our speed and the one the client's last move reported.)
		if (bDrawDebugData)
			ClientDebugMessage("Send CAP:"@CurrentTimeStamp@Physics@ClientPhysics@ClientLocError@MaxLocError
				@"sv="$int(Velocity.X)$","$int(Velocity.Y)$","$int(Velocity.Z)
				@"cv="$int(IGPlus_DetClientVel.X)$","$int(IGPlus_DetClientVel.Y)$","$int(IGPlus_DetClientVel.Z));
		IGPlus_SendCAP();
	}
}

function IGPlus_SendCAP() {
	local vector ClientLoc;
	local int CAPMiscData;

	debugNumOfForcedUpdates++;
	zzbForceUpdate = false;

	if ( Mover(Base) != None )
		ClientLoc = Location - Base.Location;
	else
		ClientLoc = Location;

	CAPMiscData = TlocCounter & 0x0003;
	// A push the client couldn't predict landed lately: the jump this
	// correction makes is eased on its camera (ClientUpdatePosition).
	if (IGPlus_PushEaseTS > 0.0 && CurrentTimeStamp - IGPlus_PushEaseTS < IGPLUS_PUSH_EASE_WINDOW)
		CAPMiscData = CAPMiscData | IGPLUS_CAP_PUSHED;

	if (GetStateName() == 'PlayerWalking') {
		if (Physics == PHYS_Walking) {
			if (Base == Level) {
				xxCAPWalkingWalkingLevelBase(CurrentTimeStamp, CAPMiscData, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z);
			} else {
				xxCAPWalkingWalking(CurrentTimeStamp, CAPMiscData, ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z, Base);
			}
		} else {
			xxCAPWalking(CurrentTimeStamp, CAPMiscData | (Physics << 2), ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z, Base);
		}
	} else if (Base == Level)
		xxCAPLevelBase(CurrentTimeStamp, GetStateName(), CAPMiscData | (Physics << 2), ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z);
	else
		xxCAP(CurrentTimeStamp, GetStateName(), CAPMiscData | (Physics << 2), ClientLoc.X, ClientLoc.Y, ClientLoc.Z, Velocity.X, Velocity.Y, Velocity.Z, Base);

	LastCAPTime = ServerTimeStamp;
	IGPlus_WantCAP = false;
	IGPlus_NotifiedTranslocate = true;
}

function EDodgeDir GetDodgeDir(int dir) {
	switch(dir) {
		case 0: return DODGE_None;
		case 1: return DODGE_Left;
		case 2: return DODGE_Right;
		case 3: return DODGE_Forward;
		case 4: return DODGE_Back;
		case 5: return DODGE_Active;
		case 6: return DODGE_Done;
	}
	return DODGE_None;
}

function EPhysics GetPhysics(int phys) {
	switch(phys) {
		case 0: return PHYS_None;
		case 1: return PHYS_Walking;
		case 2: return PHYS_Falling;
		case 3: return PHYS_Swimming;
		case 4: return PHYS_Flying;
		case 5: return PHYS_Rotating;
		case 6: return PHYS_Projectile;
		case 7: return PHYS_Rolling;
		case 8: return PHYS_Interpolating;
		case 9: return PHYS_MovingBrush;
		case 10: return PHYS_Spider;
		case 11: return PHYS_Trailer;
	}
	return PHYS_None;
}

function bool IGPlus_OldServerMove(float TimeStamp, int OldMoveData1, int OldMoveData2) {
	local int OldTimeStampOffset;
	local vector Accel;
	local float OldTimeStamp;
	local float DeltaTime;
	local bool OldRun;
	local bool OldDuck;
	local bool OldJump;
	local EDodgeDir DodgeMove;
	local float SimTime;

	OldTimeStampOffset = OldMoveData1 & 0x3FF;
	if (OldTimeStampOffset == 0 || OldTimeStampOffset == 0x3FF)
		return false;

	OldTimeStamp = TimeStamp - (float(OldTimeStampOffset) * 0.001);
	if (CurrentTimeStamp + 0.001 >= OldTimeStamp)
		return false;

	DeltaTime = OldTimeStamp - CurrentTimeStamp;
	if (zzUTPure.Settings.bEnableWarpFix && DeltaTime > zzUTPure.Settings.WarpFixDelay) {
		return false;
	}

	OldJump   = (OldMoveData1 & 0x0400) != 0;
	OldRun    = (OldMoveData1 & 0x0800) != 0;
	OldDuck   = (OldMoveData1 & 0x1000) != 0;
	DodgeMove = GetDodgeDir((OldMoveData1 >> 13) & 7);
	Accel.X   = (OldMoveData1 >> 16) * 0.1;
	Accel.Y   = (OldMoveData2 << 16 >> 16) * 0.1;
	Accel.Z   = (OldMoveData2 >> 16) * 0.1;

	if (DodgeMove > DODGE_None && DodgeMove < DODGE_Active)
		ClientDebugMessage("Received Old Dodge"@DodgeMove@CurrentTimeStamp@OldTimeStamp);

	if (IGPlus_ShouldJitterBound() && DeltaTime > zzUTPure.Settings.MaxJitterTime) {
		SimTime = DeltaTime - zzUTPure.Settings.MaxJitterTime;
		if (SimTime >= 0.005 || bIs469Server) {
			SimMoveAutonomous(SimTime);
			DeltaTime = zzUTPure.Settings.MaxJitterTime;
		}
	}

	IGPlus_MoveAutonomous(DeltaTime, OldRun, OldDuck, OldJump, DodgeMove, Accel, rot(0,0,0));
	CurrentTimeStamp = OldTimeStamp;

	return true;
}

// =============================================================================
// Adaptive Buffering (bEnableAdaptiveBuffering, IGPlus_AB...)
//
// A move runs the moment its packet arrives. Packets that come late and
// together make the player stand still on the server and then cover all that
// time in one tick. With Adaptive Buffering the moves of such a player wait
// in a queue and run on a clock of their own: the player's time (the move
// timestamps), advancing with server time. A player whose packets arrive on
// time is not queued and runs through the code as before.
//
// Arrival (xxServerMove in any state): IGPlus_ABIntercept measures how late
// the move is and keeps it for a queued player.
// Playout (CheckClientError: the engine calls it right after it took in this
// tick's packets, which is where arriving moves run too): IGPlus_ABPlayout
// advances the clock and runs the moves it has reached, through xxServerMove
// of the state the player is in by then.
//
// The delay (IGPlus_ABDelay) is how far the clock is behind the client's own
// clock. It grows when the next move is late: the clock stands still and the
// player with it (no guessed input, so no corrections). It shrinks with the
// clock running up to 5% fast, down to the player's usual lateness. Above
// AdaptiveBufferingMax the moves run at once, as without the queue.
// All times are game time (real seconds * Level.TimeDilation).
// =============================================================================

function bool IGPlus_ABActive() {
	return zzUTPure != none && zzUTPure.Settings != none && bIs469Server
		&& zzUTPure.Settings.AdaptiveBufferingActive() && zzUTPure.Settings.AdaptiveBufferingMax > 0;
}

// The timestamp a move in this tick's packets carries when nothing held it
// up. The engine advances Level.TimeSeconds after it takes in the packets, so
// they arrive one tick later than it says there.
function float IGPlus_ABBase() {
	return Level.TimeSeconds + IGPlus_ABTickLen - IGPlus_ABWinMin;
}

function float IGPlus_ABMaxDelay() {
	return zzUTPure.Settings.AdaptiveBufferingMax * 0.001 * Level.TimeDilation;
}

function IGPlus_ABSetDelayMs() {
	if (IGPlus_ABQueued)
		IGPlus_ABDelayMs = int(1000.0 * FMax(0.0, IGPlus_ABDelay) / Level.TimeDilation + 0.5);
	else
		IGPlus_ABDelayMs = 0;
}

// A number with one decimal, for the log lines.
static function string IGPlus_ABFmt(float F) {
	local int T;

	T = int(F * 10.0 + 0.5);
	return (T / 10)$"."$(T - (T / 10) * 10);
}

// How late a move may be before it queues the player (bEnter), or how late
// the usual lateness may be and still count as on time (IGPLUS_AB_ENTER_TICKS_TI).
function float IGPlus_ABSlack(bool bEnter, float Tick) {
	if (bEnter) {
		if (IGPlus_EnableTickInterp)
			return IGPLUS_AB_ENTER_FRAMES * IGPlus_ABMoveLen + IGPLUS_AB_ENTER_TICKS_TI * Tick;
		return IGPLUS_AB_ENTER_FRAMES * IGPlus_ABMoveLen + IGPLUS_AB_ENTER_TICKS * Tick;
	}
	if (IGPlus_EnableTickInterp)
		return IGPLUS_AB_LEAVE_FRAMES * IGPlus_ABMoveLen + IGPLUS_AB_LEAVE_TICKS_TI * Tick;
	return IGPLUS_AB_LEAVE_FRAMES * IGPlus_ABMoveLen + IGPLUS_AB_LEAVE_TICKS * Tick;
}

// One [BUFFER] line when a player enters or leaves the queue, at most one a
// second for each player.
function IGPlus_ABLog(string What) {
	if (PlayerReplicationInfo == none)
		return;
	if (IGPlus_ABLogTS > 0.0 && Level.TimeSeconds - IGPlus_ABLogTS < Level.TimeDilation)
		return;
	IGPlus_ABLogTS = Level.TimeSeconds;
	IGPlus_EventLog("[BUFFER]"@PlayerReplicationInfo.PlayerName@What
		@"delayMs="$IGPlus_ABDelayMs
		@"usualLateMs="$int(1000.0 * IGPlus_ABPeak / Level.TimeDilation)
		@"tickMs="$IGPlus_ABFmt(1000.0 * IGPlus_ABTickLen / Level.TimeDilation)
		@"ping="$PlayerReplicationInfo.Ping);
}

// Server: this map's numbers for one arriving move. Late: how far behind the
// client's clock it arrived. Gap: server time since the move before it.
function IGPlus_ABNoteArrival(float Late, float Gap, float MoveLen, float Tick) {
	local float Ms, Ticks, Slack;

	Ms = 1000.0 * Late / Level.TimeDilation;
	Ticks = Late / Tick;
	IGPlus_ABStatMoves++;
	IGPlus_ABStatLateSum += Ms;
	IGPlus_ABStatLateMax = FMax(IGPlus_ABStatLateMax, Ms);
	IGPlus_ABStatTickSum += Ticks;
	IGPlus_ABStatTickMax = FMax(IGPlus_ABStatTickMax, Ticks);
	if (Ticks < 1.0)
		IGPlus_ABStatUnder1++;
	if (Ticks < 2.0)
		IGPlus_ABStatUnder2++;
	if (Ms > 50.0)
		IGPlus_ABStatOver50++;
	// Would this move have queued the player (IGPlus_ABIntercept)? Counted
	// with the setting off too, to set the slack from real connections.
	Slack = IGPlus_ABSlack(true, Tick);
	IGPlus_ABStatSlackSum += 1000.0 * Slack / Level.TimeDilation;
	if (Late > Slack) {
		IGPlus_ABStatOverSlack++;
		if (IGPlus_ABStatSlackTS <= 0.0 || Level.TimeSeconds - IGPlus_ABStatSlackTS > 3.0 * Level.TimeDilation)
			IGPlus_ABStatSlackEvents++;
		IGPlus_ABStatSlackTS = Level.TimeSeconds;
	}
	Ms = 1000.0 * Gap / Level.TimeDilation;
	IGPlus_ABStatGapMax = FMax(IGPlus_ABStatGapMax, Ms);
	if (Ms > 50.0)
		IGPlus_ABStatGap50++;
	if (Ms > 100.0)
		IGPlus_ABStatGap100++;
	if (1000.0 * MoveLen / Level.TimeDilation > 50.0)
		IGPlus_ABStatLongMoves++;
}

// Server: one [JITTER-SUMMARY] line with how this player's moves arrived on
// this map, written with the [DET-SUMMARY] line (IGPlus_DetLogSummary) and
// whatever the Adaptive Buffering setting. Lateness is how far behind the
// client's clock a move arrived (the lowest arrival offset of the last 3 to 4
// seconds), in real ms and in server ticks. A gap is the server time between
// two arrivals. lostMoves are the holes lost moves left (the [DET-SUMMARY]
// count). longMoves are moves over 50 ms (a hitch on the client). The last
// fields are the queue's: moves that waited in it, time spent queued, times
// entered, times the clock stood still, the highest delay, and the time above
// AdaptiveBufferingMax that ran at once.
function IGPlus_ABLogSummary() {
	local float N;

	if (IGPlus_ABStatLogged || PlayerReplicationInfo == none || IGPlus_ABStatMoves == 0)
		return;
	IGPlus_ABStatLogged = true;
	N = float(IGPlus_ABStatMoves);
	IGPlus_EventLog("[JITTER-SUMMARY]"@PlayerReplicationInfo.PlayerName
		@"moves="$IGPlus_ABStatMoves
		@"lateMsAvg="$IGPlus_ABFmt(IGPlus_ABStatLateSum / N)@"lateMsMax="$int(IGPlus_ABStatLateMax)
		@"lateTicksAvg="$IGPlus_ABFmt(IGPlus_ABStatTickSum / N)@"lateTicksMax="$IGPlus_ABFmt(IGPlus_ABStatTickMax)
		@"under1Tick="$IGPlus_ABFmt(100.0 * IGPlus_ABStatUnder1 / N)$"%"
		@"under2Ticks="$IGPlus_ABFmt(100.0 * IGPlus_ABStatUnder2 / N)$"%"
		@"over50ms="$IGPlus_ABFmt(100.0 * IGPlus_ABStatOver50 / N)$"%"
		@"slackMs="$IGPlus_ABFmt(IGPlus_ABStatSlackSum / N)@"overSlack="$IGPlus_ABStatOverSlack@"overSlackEvents="$IGPlus_ABStatSlackEvents
		@"gapMsMax="$int(IGPlus_ABStatGapMax)@"gaps50="$IGPlus_ABStatGap50@"gaps100="$IGPlus_ABStatGap100
		@"lostMoves="$IGPlus_DetLostMoves@"longMoves="$IGPlus_ABStatLongMoves
		@"tickMs="$IGPlus_ABFmt(1000.0 * IGPlus_ABTickLen / Level.TimeDilation)
		@"queuedMoves="$IGPlus_ABStatQueuedMoves
		@"queuedSec="$IGPlus_ABFmt(IGPlus_ABStatQueuedTime / Level.TimeDilation)
		@"queueEntries="$IGPlus_ABStatEnters@"stalls="$IGPlus_ABStatStalls
		@"delayMsMax="$int(IGPlus_ABStatDelayMax)
		@"overCapMs="$int(1000.0 * IGPlus_ABStatOverCap / Level.TimeDilation)
		@"ping="$PlayerReplicationInfo.Ping);
}

// Server: this player stands still from here on. The other clients stop
// moving them along (bHold in IGPlus_WarpFixData, sent with this tick's
// position) until a move runs again (IGPlus_ABRunHead).
function IGPlus_ABHold() {
	if (IGPlus_ABHeld)
		return;
	IGPlus_ABHeld = true;
	IGPlus_ABStatStalls++;
}

// Server: a move just arrived (called first thing by xxServerMove in every
// state). Measures its lateness. Sets IGPlus_ABKept when the player is queued
// and the move waits: the caller then does nothing more with it. (A variable
// and not a return value: 16 parameters is all a function can have.)
function IGPlus_ABIntercept(
	float TimeStamp,
	int MoveDeltaTime,
	vector Accel,
	float ClientLocX,
	float ClientLocY,
	float ClientLocZ,
	vector ClientVel,
	int MiscData,
	int MiscData2,
	int View,
	Actor ClientBase,
	int OldMoveData1,
	int OldMoveData2,
	float DetRedoTS,
	int DetRedoData,
	int PRTData
) {
	local float MoveLen, Gap, Late, Tick;
	local IGPlus_ServerMove SM, Prev;

	IGPlus_ABKept = false;
	// A queued move being run, or a move a state's xxServerMove showed us
	// already and now passes on to the global one.
	if (IGPlus_ABPlaying)
		return;
	if (IGPlus_ABSeen) {
		IGPlus_ABSeen = false;
		return;
	}
	if (Role < ROLE_Authority || bDeleteMe)
		return;

	MoveLen = IGPlus_UnpackDelta(MoveDeltaTime); // the top byte is a shot's eye height
	Gap = Level.TimeSeconds - IGPlus_ABLastArrival;
	// Paused, the first move, a long silence, or a client clock that went
	// back: nothing to measure against. Start over, this move runs now.
	if (Level.Pauser != "" || bWasPaused || IGPlus_ABHaveMin == false || Gap > 2.0
		|| TimeStamp < IGPlus_ABLastArrivalTS - 0.5) {
		if (IGPlus_ABQueued)
			IGPlus_ABLeave("reset");
		IGPlus_ABHaveMin = false;
		IGPlus_ABMeasureStart = Level.TimeSeconds;
		IGPlus_ABPeak = 0.0;
		IGPlus_ABTickMaxTS = TimeStamp;
		IGPlus_ABLastArrival = Level.TimeSeconds;
		IGPlus_ABLastArrivalTS = TimeStamp;
		IGPlus_ABNewestTS = TimeStamp;
		return;
	}

	IGPlus_ABTickMaxTS = FMax(IGPlus_ABTickMaxTS, TimeStamp);
	IGPlus_ABLastArrival = Level.TimeSeconds;
	IGPlus_ABLastArrivalTS = FMax(IGPlus_ABLastArrivalTS, TimeStamp);
	IGPlus_ABNewestTS = FMax(IGPlus_ABNewestTS, TimeStamp);
	if (IGPlus_ABMoveLen <= 0.0)
		IGPlus_ABMoveLen = FMin(MoveLen, 0.1);
	else
		IGPlus_ABMoveLen += (FMin(MoveLen, 0.1) - IGPlus_ABMoveLen) * 0.05;
	// A new measure counts once its window is full: a join or a freeze
	// leaves stray arrival times behind, which read as lateness.
	if (Level.TimeSeconds - IGPlus_ABMeasureStart < IGPLUS_AB_WARMUP)
		return;

	Tick = FMax(IGPlus_ABTickLen, 0.001);
	Late = FMax(0.0, IGPlus_ABBase() - TimeStamp);
	IGPlus_ABNoteArrival(Late, Gap, MoveLen, Tick);
	IGPlus_ABPeak = FMax(IGPlus_ABPeak, FMin(Late, 0.25));

	if (IGPlus_ABActive() == false) {
		if (IGPlus_ABQueued)
			IGPlus_ABLeave("off");
		return;
	}
	if (IGPlus_ABQueued == false) {
		// On time: this move runs now, through the code as before.
		if (ServerTimeStamp <= 0.0 || Late <= IGPlus_ABSlack(true, Tick))
			return;
		// Late: from here this player's moves are queued. The delay is how
		// late this move came. After a stall the player stood still that
		// long already, and the clock starts at this move: it runs this
		// tick and the ones behind it at their own pace. A late move that
		// newer ones overtook is lost as before, and the player stands
		// still once, for the delay, so that the next one like it is not.
		IGPlus_ABQueued = true;
		IGPlus_ABHeld = false;
		IGPlus_ABDelay = FMin(Late, IGPlus_ABMaxDelay());
		// (Overtaken: the clock starts that far behind the moves that ran
		// already, so nothing runs for about the delay. Held from now.)
		if (TimeStamp <= CurrentTimeStamp)
			IGPlus_ABHold();
		IGPlus_ABClockTime = Level.TimeSeconds;
		IGPlus_ABLastRun = ServerTimeStamp;
		IGPlus_ABOverNow = 0.0;
		IGPlus_ABEnterTime = Level.TimeSeconds;
		IGPlus_ABStatEnters++;
		IGPlus_ABSetDelayMs();
		IGPlus_ABLog("queued lateMs="$int(1000.0 * Late / Level.TimeDilation)
			@"slackMs="$int(1000.0 * IGPlus_ABSlack(true, Tick) / Level.TimeDilation));
	} else if (TimeStamp <= CurrentTimeStamp && Late > IGPlus_ABDelay) {
		// Too late even for the queue: newer moves ran over its time. The
		// delay grows to this lateness, so the next move this late is in
		// time. The player stands still for the difference, as in a stall,
		// and is held from now when that is longer than moves are apart.
		if (FMin(Late, IGPlus_ABMaxDelay()) - IGPlus_ABDelay > IGPLUS_AB_GRACE * IGPlus_ABMoveLen)
			IGPlus_ABHold();
		IGPlus_ABDelay = FMin(Late, IGPlus_ABMaxDelay());
	}
	// Already run or passed (out of order, twice): rejected as before.
	if (TimeStamp <= CurrentTimeStamp)
		return;

	// The fire clock check measures at arrival (not when the move runs).
	IGPlus_DetUpdateFireClockLead(TimeStamp, Gap);

	if (IGPlus_ABCount >= IGPLUS_AB_MAXQUEUE)
		IGPlus_ABRunHead();

	SM = IGPlus_CreateServerMove();
	SM.TimeStamp = TimeStamp;
	SM.RawDelta = MoveDeltaTime;
	SM.MoveDeltaTime = MoveLen;
	SM.ClientAcceleration = Accel;
	SM.ClientLocation.X = ClientLocX;
	SM.ClientLocation.Y = ClientLocY;
	SM.ClientLocation.Z = ClientLocZ;
	SM.ClientVelocity = ClientVel;
	SM.MiscData = MiscData;
	SM.MiscData2 = MiscData2;
	SM.View = View;
	SM.ClientBase = ClientBase;
	SM.OldMoveData1 = OldMoveData1;
	SM.OldMoveData2 = OldMoveData2;
	SM.DetRedoTS = DetRedoTS;
	SM.DetRedoData = DetRedoData;
	SM.PRTData = PRTData;
	IGPlus_DetTakeRedoMore(SM);

	// Oldest first: packets can arrive out of order.
	if (IGPlus_ABHead == none || TimeStamp < IGPlus_ABHead.TimeStamp) {
		SM.Next = IGPlus_ABHead;
		IGPlus_ABHead = SM;
	} else {
		// ponytail: walks the queue (a few dozen moves at most). A tail
		// pointer if queues ever get long.
		Prev = IGPlus_ABHead;
		while (Prev.Next != none && Prev.Next.TimeStamp <= TimeStamp)
			Prev = Prev.Next;
		if (Prev.TimeStamp == TimeStamp) {
			// The same move twice.
			IGPlus_DestroyServerMove(SM);
			IGPlus_ABKept = true;
			return;
		}
		SM.Next = Prev.Next;
		Prev.Next = SM;
	}
	IGPlus_ABCount++;
	IGPlus_ABStatQueuedMoves++;
	IGPlus_ABKept = true;
}

// Server: run the oldest queued move, as if it arrived now.
function IGPlus_ABRunHead() {
	local IGPlus_ServerMove SM;

	SM = IGPlus_ABHead;
	if (SM == none)
		return;
	IGPlus_ABHead = SM.Next;
	SM.Next = none;
	IGPlus_ABCount--;
	IGPlus_ABHeld = false;
	IGPlus_ABLastRun = Level.TimeSeconds;
	IGPlus_ABPlaying = true;
	IGPlus_DetRedoMoreTS = SM.DetRedo2TS;
	IGPlus_DetRedoMoreData = SM.DetRedo2Data;
	IGPlus_DetRedoMoreSpotTS = SM.DetRedoSpotTS;
	IGPlus_DetRedoMoreSpot = SM.DetRedoSpot;
	xxServerMove(
		SM.TimeStamp,
		SM.RawDelta,
		SM.ClientAcceleration,
		SM.ClientLocation.X,
		SM.ClientLocation.Y,
		SM.ClientLocation.Z,
		SM.ClientVelocity,
		SM.MiscData,
		SM.MiscData2,
		SM.View,
		SM.ClientBase,
		SM.OldMoveData1,
		SM.OldMoveData2,
		SM.DetRedoTS,
		SM.DetRedoData,
		SM.PRTData);
	IGPlus_ABPlaying = false;
	IGPlus_DestroyServerMove(SM);
}

// Server: this player's moves run on arrival again. What is still queued
// runs now.
function IGPlus_ABLeave(string Why) {
	while (IGPlus_ABHead != none && bDeleteMe == false)
		IGPlus_ABRunHead();
	IGPlus_ABQueued = false;
	IGPlus_ABHeld = false;
	IGPlus_ABDelay = 0.0;
	IGPlus_ABSetDelayMs();
	IGPlus_ABLog("unqueued reason="$Why@"queuedSec="$IGPlus_ABFmt((Level.TimeSeconds - IGPlus_ABEnterTime) / Level.TimeDilation));
}

function IGPlus_ABDropQueue() {
	local IGPlus_ServerMove SM;

	while (IGPlus_ABHead != none) {
		SM = IGPlus_ABHead;
		IGPlus_ABHead = SM.Next;
		SM.Destroy();
	}
	IGPlus_ABCount = 0;
}

// Server, once a tick for a queued player, after this tick's moves arrived
// (CheckClientError): advance the playout clock and run the moves it reached.
function IGPlus_ABPlayout() {
	local float dt, MaxDelay, Target, Clock, Limit;
	local bool bStopped;

	if (IGPlus_ABQueued == false)
		return;
	if (IGPlus_ABActive() == false || Level.Pauser != "") {
		IGPlus_ABLeave("off");
		return;
	}
	// Nothing for 2 seconds: the arrival measure starts over with the next
	// move anyway (IGPlus_ABIntercept).
	if (Level.TimeSeconds - IGPlus_ABLastArrival > 2.0) {
		// (Nothing ran at once after all: not time above the cap.)
		IGPlus_ABStatOverCap = FMax(0.0, IGPlus_ABStatOverCap - IGPlus_ABOverNow);
		IGPlus_ABLeave("silent");
		return;
	}
	dt = FMax(0.0, Level.TimeSeconds - IGPlus_ABClockTime);
	IGPlus_ABClockTime = Level.TimeSeconds;
	MaxDelay = IGPlus_ABMaxDelay();

	// The delay to keep is the player's usual lateness. Lateness within the
	// leave slack is a connection that arrives on time: no delay to keep.
	Target = 0.0;
	if (IGPlus_ABPeak > IGPlus_ABSlack(false, IGPlus_ABTickLen))
		Target = FMin(IGPlus_ABPeak, MaxDelay);

	// More delay than that: the clock runs up to 5% fast. The delay is time
	// the clock stood still before (or packets that began to arrive sooner,
	// a ping drop), so this never runs more of the player's time than
	// server time has passed. TimeMargin still checks every move as it runs.
	if (IGPlus_ABDelay > Target)
		IGPlus_ABDelay -= FMin(IGPLUS_AB_DRAIN * dt, IGPlus_ABDelay - Target);

	// The next move is late: the clock stops and the player stands still.
	// The time it stands is delay from here on, so play goes on from this
	// spot at normal pace when moves arrive.
	Clock = IGPlus_ABBase() - IGPlus_ABDelay;
	Limit = IGPlus_ABNewestTS + IGPLUS_AB_GRACE * IGPlus_ABMoveLen;
	if (Clock > Limit) {
		IGPlus_ABDelay += Clock - Limit;
		bStopped = true;
	}
	// Time above the cap runs at once, as without the queue. (Counted once
	// for a stall: the delay is cut back to the cap every tick of it.)
	if (IGPlus_ABDelay > MaxDelay) {
		IGPlus_ABStatOverCap += FMax(0.0, IGPlus_ABDelay - MaxDelay - IGPlus_ABOverNow);
		IGPlus_ABOverNow = FMax(IGPlus_ABOverNow, IGPlus_ABDelay - MaxDelay);
		IGPlus_ABDelay = MaxDelay;
	} else {
		IGPlus_ABOverNow = 0.0;
	}
	IGPlus_ABSetDelayMs();
	IGPlus_ABStatDelayMax = FMax(IGPlus_ABStatDelayMax, float(IGPlus_ABDelayMs));

	Clock = IGPlus_ABBase() - IGPlus_ABDelay;
	while (IGPlus_ABHead != none && IGPlus_ABHead.TimeStamp <= Clock && bDeleteMe == false)
		IGPlus_ABRunHead();

	// The player stands still on the server from here: the other clients
	// hold them too, until a move runs. The queue lets us see it coming.
	// When it has just run out and no move arrived for longer than moves
	// are apart, the stall has outlasted the delay. Held in this same tick,
	// so the hold reaches the others with the last real position and they
	// never move the player past it. If the next move comes a moment later
	// after all, they showed a stop of one tick.
	if (IGPlus_ABHead == none
		&& (bStopped || Level.TimeSeconds - IGPlus_ABLastArrival > IGPLUS_AB_GRACE * IGPlus_ABMoveLen))
		IGPlus_ABHold();
	// Whatever else kept moves from running for longer than they are apart.
	else if (Level.TimeSeconds - IGPlus_ABLastRun > IGPLUS_AB_GRACE * IGPlus_ABMoveLen + IGPlus_ABTickLen)
		IGPlus_ABHold();

	// On time again and the delay made up: back to running on arrival.
	if (Target <= 0.0 && IGPlus_ABHeld == false
		&& IGPlus_ABDelay <= IGPLUS_AB_LEAVE_DELAY_TICKS * IGPlus_ABTickLen)
		IGPlus_ABLeave("on-time");
}

// The engine (469) calls this for every connection right after it took in
// this tick's packets. Stock uses it for its own ServerMove, which we replace.
event CheckClientError() {
	// The tick's packets are all read: the shots that waited run now, in
	// the order they were fired. Again after the playout, which can run a
	// queued player's shot.
	if (zzUTPure != None) {
		zzUTPure.IGPlus_bShotOrderReady = true;
		zzUTPure.IGPlus_FlushShots();
	}
	IGPlus_ABPlayout();
	if (zzUTPure != None)
		zzUTPure.IGPlus_FlushShots();
}

// Is the shot that arrived later run first? Only when it was fired earlier
// by more than the margin. Closer together than that, our estimate can't
// tell them apart, and the order they arrived in stays.
static function bool IGPlus_ShotRunsFirst(float AgoArrivedLater, float AgoArrivedFirst, float Margin) {
	return AgoArrivedLater > AgoArrivedFirst + Margin;
}

// Server: the lowest of our last readings of this player's ping (two a
// second, IGPlus_PingRing), in ms. 0 before the first one. A client can't
// make it lower than its line is, and a moment of lag (a stop of its
// download) raises the readings that follow it for a while but not this.
function float IGPlus_PingLowMs() {
	local float PingMs;
	local int i;

	for (i = 0; i < arraycount(IGPlus_PingRing); i++)
		if (IGPlus_PingRing[i] > 0.0 && (PingMs == 0.0 || IGPlus_PingRing[i] < PingMs))
			PingMs = IGPlus_PingRing[i];
	return PingMs;
}

// Server: how long before now the shot of the move stamped StepTS was fired.
// The move's stamp is the client's clock. The arrival measure of Adaptive
// Buffering maps it to ours (it runs with the setting off too): Late is
// how far behind the best case this move arrived. The best case still has
// the upload on top, half of our own ping measure, the lowest of the last 2
// seconds. A client can't make that ping lower, and delaying its packets
// only makes its shots look later.
function float IGPlus_ShotAgo(float StepTS) {
	local float Late, PingMs;

	if (IGPlus_ABMeasureStart > 0.0 && Level.TimeSeconds - IGPlus_ABMeasureStart >= IGPLUS_AB_WARMUP)
		Late = FClamp(IGPlus_ABBase() - StepTS, 0.0, 0.25);
	PingMs = IGPlus_PingLowMs();
	if (PingMs == 0.0 && PlayerReplicationInfo != None)
		PingMs = PlayerReplicationInfo.Ping;
	return Late + 0.0005 * PingMs * Level.TimeDilation;
}

// Server: a rifle or sniper shot waits for the end of the tick's packets.
// False: it can't wait, the weapon traces it now.
function bool IGPlus_QueueShot(Weapon W, rotator View, vector Loc) {
	local WeaponSettingsRepl WS;

	if (zzUTPure == None || zzUTPure.IGPlus_bShotOrderReady == false)
		return false;
	// Fire Time Order off (the mode's weapon setting bEnableFireTimeOrder): the
	// shot runs now, in the order its packet arrived.
	WS = GetWeaponSettings();
	if (WS == None || WS.bEnableFireTimeOrder == false)
		return false;
	// One at a time: a second shot of ours runs the first one now.
	if (IGPlus_bShotPending)
		IGPlus_RunPendingShot();
	if (zzUTPure.IGPlus_QueueShooter(self) == false)
		return false;
	IGPlus_bShotPending = true;
	IGPlus_PendShotWeapon = W;
	IGPlus_PendShotView = View;
	IGPlus_PendShotLoc = Loc;
	IGPlus_PendShotAgo = IGPlus_ShotAgo(IGPlus_DetLastShotTS);
	IGPlus_PendShotTS = IGPlus_DetLastShotTS;
	IGPlus_PendPRTNoteTS = IGPlus_PRTNoteTS;
	IGPlus_PendPRTNoteTick = IGPlus_PRTNoteTick;
	IGPlus_PendPRTSeenTime = IGPlus_PRTSeenTime;
	IGPlus_PendPRTViewTime = IGPlus_PRTViewTime;
	IGPlus_PendPRTLagMs = IGPlus_PRTLagMs;
	IGPlus_PendPRTReason = IGPlus_PRTReason;
	IGPlus_bPendPRTInterp = IGPlus_bPRTInterp;
	IGPlus_bPendPRTInterpPast = IGPlus_bPRTInterpPast;
	IGPlus_bPendPRTInterpHeld = IGPlus_bPRTInterpHeld;
	IGPlus_PendPRTInterpR = IGPlus_PRTInterpR;
	IGPlus_PendPRTInterpSpan = IGPlus_PRTInterpSpan;
	IGPlus_PendVerdict = IGPlus_ClientHitVerdict;
	IGPlus_bPendDrawnDiffers = IGPlus_bShotDrawnDiffers;
	IGPlus_PendEyeByte = IGPlus_ShotEyeByte;
	IGPlus_PendShotOriginGap = IGPlus_ShotOriginGap;
	IGPlus_PendShotOriginFrom = IGPlus_ShotOriginFrom;
	return true;
}

// Server: trace the shot that waited, with what its own move brought (a later
// move of ours in the same tick has replaced those values by now).
function IGPlus_RunPendingShot() {
	local Weapon W;
	local float NoteTS, SeenTime, ViewTime, LagMs;
	local int NoteTick, Verdict, EyeByte, InterpSpan, OriginFrom;
	local string Reason;
	local bool bDrawnDiffers, bInterp, bInterpPast, bInterpHeld;
	local float InterpR, OriginGap;

	if (IGPlus_bShotPending == false)
		return;
	IGPlus_bShotPending = false;
	W = IGPlus_PendShotWeapon;
	IGPlus_PendShotWeapon = None;
	if (W == None || W.bDeleteMe || W.Owner != self)
		return;
	// A shot fired before ours in this tick killed us: ours is a shot from
	// the dead, as if its move had arrived a tick later.
	if ((Health <= 0 || IsInState('Dying')) && IGPlus_DetTradesEnabled() == false) {
		IGPlus_HitStatDeadShots++;
		if (IGPlus_PendVerdict == IGPLUS_HIT_BODY || IGPlus_PendVerdict == IGPLUS_HIT_HEAD)
			IGPlus_HitStatDeadHits++;
		IGPlus_EventLog("[DET-HIT]"@PlayerReplicationInfo.PlayerName@"deadShot clientHit="$(IGPlus_PendVerdict == IGPLUS_HIT_BODY || IGPlus_PendVerdict == IGPLUS_HIT_HEAD)
			@"sameTick=True trades=False ping="$PlayerReplicationInfo.Ping);
		return;
	}

	NoteTS = IGPlus_PRTNoteTS;
	NoteTick = IGPlus_PRTNoteTick;
	SeenTime = IGPlus_PRTSeenTime;
	ViewTime = IGPlus_PRTViewTime;
	LagMs = IGPlus_PRTLagMs;
	Reason = IGPlus_PRTReason;
	bInterp = IGPlus_bPRTInterp;
	bInterpPast = IGPlus_bPRTInterpPast;
	bInterpHeld = IGPlus_bPRTInterpHeld;
	InterpR = IGPlus_PRTInterpR;
	InterpSpan = IGPlus_PRTInterpSpan;
	Verdict = IGPlus_ClientHitVerdict;
	bDrawnDiffers = IGPlus_bShotDrawnDiffers;
	EyeByte = IGPlus_ShotEyeByte;
	OriginGap = IGPlus_ShotOriginGap;
	OriginFrom = IGPlus_ShotOriginFrom;

	IGPlus_PRTNoteTS = IGPlus_PendPRTNoteTS;
	IGPlus_PRTNoteTick = IGPlus_PendPRTNoteTick;
	IGPlus_PRTSeenTime = IGPlus_PendPRTSeenTime;
	IGPlus_PRTViewTime = IGPlus_PendPRTViewTime;
	IGPlus_PRTLagMs = IGPlus_PendPRTLagMs;
	IGPlus_PRTReason = IGPlus_PendPRTReason;
	IGPlus_bPRTInterp = IGPlus_bPendPRTInterp;
	IGPlus_bPRTInterpPast = IGPlus_bPendPRTInterpPast;
	IGPlus_bPRTInterpHeld = IGPlus_bPendPRTInterpHeld;
	IGPlus_PRTInterpR = IGPlus_PendPRTInterpR;
	IGPlus_PRTInterpSpan = IGPlus_PendPRTInterpSpan;
	IGPlus_ClientHitVerdict = IGPlus_PendVerdict;
	IGPlus_bShotDrawnDiffers = IGPlus_bPendDrawnDiffers;
	IGPlus_ShotEyeByte = IGPlus_PendEyeByte;
	IGPlus_ShotOriginGap = IGPlus_PendShotOriginGap;
	IGPlus_ShotOriginFrom = IGPlus_PendShotOriginFrom;

	IGPlus_SDShotTS = IGPlus_PendShotTS;
	if (ST_SuperShockRifle(W) != None)
		ST_SuperShockRifle(W).DeterministicTraceFire(IGPlus_PendShotView, IGPlus_PendShotLoc);
	else if (ST_SniperRifle(W) != None)
		ST_SniperRifle(W).DeterministicTraceFire(IGPlus_PendShotView, IGPlus_PendShotLoc);
	IGPlus_SDShotTS = 0.0;

	IGPlus_PRTNoteTS = NoteTS;
	IGPlus_PRTNoteTick = NoteTick;
	IGPlus_PRTSeenTime = SeenTime;
	IGPlus_PRTViewTime = ViewTime;
	IGPlus_PRTLagMs = LagMs;
	IGPlus_PRTReason = Reason;
	IGPlus_bPRTInterp = bInterp;
	IGPlus_bPRTInterpPast = bInterpPast;
	IGPlus_bPRTInterpHeld = bInterpHeld;
	IGPlus_PRTInterpR = InterpR;
	IGPlus_PRTInterpSpan = InterpSpan;
	IGPlus_ClientHitVerdict = Verdict;
	IGPlus_bShotDrawnDiffers = bDrawnDiffers;
	IGPlus_ShotEyeByte = EyeByte;
	IGPlus_ShotOriginGap = OriginGap;
	IGPlus_ShotOriginFrom = OriginFrom;
}

// Server, every tick (ServerTick), for every player.
function IGPlus_ABTick(float DeltaTime) {
	local float Off, Old;

	if (IGPlus_ABTickLen <= 0.0)
		IGPlus_ABTickLen = DeltaTime;
	else
		IGPlus_ABTickLen += (DeltaTime - IGPlus_ABTickLen) * 0.02;

	// The client's clock seen from here: the lowest (arrival - timestamp) of
	// the last 3 to 4 seconds. Taken here, where Level.TimeSeconds is the
	// time this tick's packets were taken in.
	if (IGPlus_ABTickMaxTS > 0.0) {
		Off = Level.TimeSeconds - IGPlus_ABTickMaxTS;
		IGPlus_ABTickMaxTS = 0.0;
		Old = IGPlus_ABWinMin;
		if (IGPlus_ABHaveMin == false) {
			IGPlus_ABMinCur = Off;
			IGPlus_ABMinPrev[0] = Off;
			IGPlus_ABMinPrev[1] = Off;
			IGPlus_ABMinPrev[2] = Off;
			IGPlus_ABMinBucketEnd = Level.TimeSeconds + 1.0;
			IGPlus_ABHaveMin = true;
			Old = Off;
		} else if (Level.TimeSeconds >= IGPlus_ABMinBucketEnd) {
			IGPlus_ABMinPrev[2] = IGPlus_ABMinPrev[1];
			IGPlus_ABMinPrev[1] = IGPlus_ABMinPrev[0];
			IGPlus_ABMinPrev[0] = IGPlus_ABMinCur;
			IGPlus_ABMinCur = Off;
			IGPlus_ABMinBucketEnd = Level.TimeSeconds + 1.0;
		} else {
			IGPlus_ABMinCur = FMin(IGPlus_ABMinCur, Off);
		}
		IGPlus_ABWinMin = FMin(FMin(IGPlus_ABMinCur, IGPlus_ABMinPrev[0]), FMin(IGPlus_ABMinPrev[1], IGPlus_ABMinPrev[2]));
		// The measure moved, the playout clock did not.
		if (IGPlus_ABQueued)
			IGPlus_ABDelay = FMax(0.0, IGPlus_ABDelay + Old - IGPlus_ABWinMin);
	}

	// The usual lateness forgets.
	IGPlus_ABPeak -= IGPlus_ABPeak * FMin(1.0, DeltaTime / (IGPLUS_AB_PEAK_TIME * Level.TimeDilation));

	if (IGPlus_ABQueued)
		IGPlus_ABStatQueuedTime += DeltaTime;
	IGPlus_ABSetDelayMs();

	// The other clients hold us still while our clock stands still
	// (IGPlus_ApplyWarpFix), and let go when a move ran.
	if (IGPlus_WarpFixData.bHold != IGPlus_ABHeld) {
		IGPlus_WarpFixData.bHold = IGPlus_ABHeld;
		IGPlus_WarpFixData.OldLocation = Location;
		IGPlus_WarpFixData.Counter += 1;
	}
}

function IGPlus_ServerMove IGPlus_CreateServerMove() {
	local IGPlus_ServerMove F;
	if (IGPlus_ServerMove_FreeList != none) {
		F = IGPlus_ServerMove_FreeList;
		IGPlus_ServerMove_FreeList = F.Next;
		F.Next = none;
		return F;
	}

	return Spawn(class'IGPlus_ServerMove', self);
}

function IGPlus_DestroyServerMove(IGPlus_ServerMove SM) {
	if (SM == none) return;
	SM.Next = IGPlus_ServerMove_FreeList;
	IGPlus_ServerMove_FreeList = SM;
}

//  MiscData
//  0                      7 8         11 12        15 16  17  18  19           23 24  25  26  27 28        31
// +------------------------+------------+------------+---+---+---+---------------+---+---+------+------------+
// |          Roll          |    Dodge   |   Physics  |Ju |Du |Run|  MergeCount   |Fi |Alt| Tloc |   Unused   |
// |                        |    Move    |            | mp| ck|   |               | re|Fir| Count|            |
// +------------------------+------------+------------+---+---+---+---------------+---+---+------+------------+
//
//  MiscData2
//  0             4 5             9 10           14 15           19 20           24 25           29 30  31
// +---------------+---------------+---------------+---------------+---------------+---------------+---+---+
// |     Jump      |     Dodge     |      Run      |     Duck      |    AltFire    |     Fire      |FFi|FAF|
// |     Index     |     Index     |     Index     |     Index     |     Index     |     Index     |re |ire|
// +---------------+---------------+---------------+---------------+---------------+---------------+---+---+
//
//  View
//  0                                             15 16                                            31
// +------------------------------------------------+------------------------------------------------+
// |                      Yaw                       |                     Pitch                      |
// +------------------------------------------------+------------------------------------------------+
//
//  OldMoveData1
//  0                            9 10  11  12  13     15 16                                            31
// +------------------------------+---+---+---+---------+------------------------------------------------+
// |           TimeStamp          |Ju |Run|Du |  Dodge  |                Acceleration X                  |
// |                              | mp|   | ck|  Move   |                                                |
// +------------------------------+---+---+---+---------+------------------------------------------------+
//
//  OldMoveData2
//  0                                             15 16                                            31
// +------------------------------------------------+------------------------------------------------+
// |                Acceleration Y                  |                Acceleration Z                  |
// +------------------------------------------------+------------------------------------------------+
function xxServerMove(
	float TimeStamp,
	int MoveDeltaTime,
	vector Accel,
	float ClientLocX,
	float ClientLocY,
	float ClientLocZ,
	vector ClientVel,
	int MiscData,
	int MiscData2,
	int View,
	Actor ClientBase,
	optional int OldMoveData1,
	optional int OldMoveData2,
	optional float DetRedoTS,
	optional int DetRedoData,
	optional int PRTData
) {
	local IGPlus_ServerMove SM;

	// Adaptive Buffering: a queued player's move waits for its turn.
	IGPlus_ABIntercept(TimeStamp, MoveDeltaTime, Accel, ClientLocX, ClientLocY, ClientLocZ, ClientVel,
		MiscData, MiscData2, View, ClientBase, OldMoveData1, OldMoveData2, DetRedoTS, DetRedoData, PRTData);
	if (IGPlus_ABKept)
		return;

	SM = IGPlus_CreateServerMove();

	SM.TimeStamp = TimeStamp;
	SM.bDetReady = (MoveDeltaTime & 0x01) != 0;
	SM.DetWeaponIndex = (MoveDeltaTime & 0x0E) >> 1;
	SM.DetChargeData = (MoveDeltaTime & 0xF0) >> 4;
	SM.MoveDeltaTime = IGPlus_UnpackDelta(MoveDeltaTime);
	SM.ShotEye = MoveDeltaTime >>> 24;
	SM.ClientAcceleration = Accel * 0.1;
	SM.ClientLocation.X = ClientLocX;
	SM.ClientLocation.Y = ClientLocY;
	SM.ClientLocation.Z = ClientLocZ;
	SM.ClientVelocity = ClientVel;
	SM.MiscData = MiscData;
	SM.MiscData2 = MiscData2;
	SM.View = View;
	SM.ClientBase = ClientBase;
	SM.OldMoveData1 = OldMoveData1;
	SM.OldMoveData2 = OldMoveData2;
	SM.DetRedoTS = DetRedoTS;
	SM.DetRedoData = DetRedoData;
	SM.PRTData = PRTData;
	IGPlus_DetTakeRedoMore(SM);

	IGPlus_ApplyServerMove(SM);
	IGPlus_DestroyServerMove(SM);

	IGPlus_WarpFixUpdate = true;
}

// Client to server, just ahead of a move: the deterministic translocator
// action before the last one (SendSavedMove). xxServerMove has no room for
// it, 16 parameters are all a function can have. We keep it for the move
// that follows. It can get here without its move or the move without it:
// only its time stamp decides whether it still runs (IGPlus_ApplyServerMove).
// SpotTS and the three after it: where we stood at the throw with that time
// stamp (as floats: a vector would arrive rounded to whole units).
function xxServerDetRedoMore(float OlderTS, int OlderData, optional float SpotTS, optional float SpotX, optional float SpotY, optional float SpotZ) {
	IGPlus_DetRedoMoreTS = OlderTS;
	IGPlus_DetRedoMoreData = OlderData;
	IGPlus_DetRedoMoreSpotTS = SpotTS;
	IGPlus_DetRedoMoreSpot.X = SpotX;
	IGPlus_DetRedoMoreSpot.Y = SpotY;
	IGPlus_DetRedoMoreSpot.Z = SpotZ;
}

// Server: the move that follows takes it along (through the Adaptive
// Buffering queue too), and it is used up.
function IGPlus_DetTakeRedoMore(IGPlus_ServerMove SM) {
	SM.DetRedo2TS = IGPlus_DetRedoMoreTS;
	SM.DetRedo2Data = IGPlus_DetRedoMoreData;
	SM.DetRedoSpotTS = IGPlus_DetRedoMoreSpotTS;
	SM.DetRedoSpot = IGPlus_DetRedoMoreSpot;
	IGPlus_DetRedoMoreTS = 0.0;
	IGPlus_DetRedoMoreData = 0;
	IGPlus_DetRedoMoreSpotTS = 0.0;
}

// Which press a click is for the translocator: 1 fire, 2 alt-fire, 0 none.
// Fire first, as stock's bring-up does (bForceFire).
// The deterministic translocator's first throw of a life waits 0.5s from the
// respawn, as master's does: its throw timer (ServerTimeSinceLastFire > 0.5)
// starts when the weapon is made. Ours ran from the last throw, and a new
// translocator has none, so a respawn click still down threw at once.
// ponytail: the stamp comes from ServerReStartPlayer only. A match start
// (no stamp sent) has no wait.
// Server: is a translocate held for a switch (3: translocate) and the client
// one translocate ahead of us?
static final function bool IGPlus_DetHoldsTloc(int HeldAction, int ClientCount, int ServerCount) {
	return (HeldAction & 3) == 3 && ((ClientCount - ServerCount) & 3) == 1;
}

static final function bool IGPlus_DetSpawnWaitOver(float TS, float SpawnTS, float Need) {
	return SpawnTS <= 0.0 || TS - SpawnTS >= Need;
}

static final function int IGPlus_DetPressOf(bool bFirePress, bool bAltPress) {
	if (bFirePress)
		return 1;
	if (bAltPress)
		return 2;
	return 0;
}

// A resent action as it travels: bits 0-2 the action (bit 2: refused), bits
// 8-19 the yaw and 20-31 the pitch of its move's view, 12 bits each
// (IGPlus_DetUnpackRedoView).
static final function int IGPlus_DetPackRedo(int Action, int ViewPacked) {
	return (Action & 7)
		| (((ViewPacked & 0xFFFF) >>> 4) << 8)
		| ((((ViewPacked >>> 16) & 0xFFFF) >>> 4) << 20);
}

// Server: is a resent action for a move between the last one we ran and
// this one?
static final function bool IGPlus_DetRedoDue(int Data, float TS, float LastTS, float MoveTS) {
	return (Data & 3) != 0 && TS > LastTS && TS < MoveTS;
}

function xxServerMoveDead(
	float TimeStamp,
	float MoveDeltaTime,
	int View
) {
	local float ServerDeltaTime;
	local float DeltaTime;

	if (bDeleteMe)
		return;

	if (Role < ROLE_Authority) {
		zzbLogoDone = True;
		zzTrackFOV = 0;
		zzbDemoPlayback = True;
		return;
	}

	zzKickReady = Max(zzKickReady - 1,0);

	// Adaptive Buffering: our client knows it is dead. The moves it made
	// before that run now, ahead of this one. Not a gap in the arrivals.
	if (IGPlus_ABQueued)
		IGPlus_ABLeave("dead");
	IGPlus_ABLastArrival = Level.TimeSeconds;

	if (TimeStamp > Level.TimeSeconds)
		TimeStamp = Level.TimeSeconds;

	if (CurrentTimeStamp >= TimeStamp)
		return;

	ServerDeltaTime = Level.TimeSeconds - ServerTimeStamp;
	if (ServerDeltaTime > 0.9)
		ServerDeltaTime = FMin(ServerDeltaTime, MoveDeltaTime);
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if (DeltaTime > 0.9)
		DeltaTime = FMin(DeltaTime, MoveDeltaTime);

	ExtrapolationDelta += (ServerDeltaTime - DeltaTime);

	if ( ServerTimeStamp > 0 ) {
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * ServerDeltaTime;
		if ( TimeMargin > MaxTimeMargin ) {
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			IGPlus_LogMoveHeld(DeltaTime, ServerDeltaTime, TimeStamp);
			DeltaTime = 0;
			ClientDebugMessage("["$Level.TimeSeconds$"]"@PlayerReplicationInfo.PlayerName@"MaxTimeMargin exceeded ("$TimeMargin$")", 'IGPlus');
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	IGPlus_WarpFixUpdate = true;

	LastUpdateTime = ServerTimeStamp;
	clientLastUpdateTime = LastUpdateTime;

	if (bClientDead == false) {
		bClientDead = true;
		bFire = 0;
		bAltFire = 0;
	}

	Acceleration = vect(0,0,0);
	Velocity = vect(0,0,0);

	if (IsInState('Dying')) {
		ViewRotation.Yaw = View & 0xFFFF;
		ViewRotation.Pitch = View >>> 16;
	}
}

function ServerApplyInput(float RefTimeStamp, int NumBits, ReplBuffer B) {
	local int i;
	local IGPlus_SavedInput Node;
	local IGPlus_SavedInput Old;
	local float DeltaTime;
	local float ServerDeltaTime;
	local float LostTime;

	if (Role < ROLE_Authority) {
		zzbLogoDone = True;
		zzTrackFOV = 0;
		zzbDemoPlayback = True;
		return;
	}

	if (bDeleteMe) {
		ClientDebugMessage("Reject Irrelevant Move");
		return;
	}

	zzKickReady = Max(zzKickReady - 1,0);

	IGPlus_InputReplicationBuffer.NumBitsConsumed = 0;
	IGPlus_InputReplicationBuffer.NumBits = NumBits;
	for (i = 0; i < arraycount(B.Data); i++)
		IGPlus_InputReplicationBuffer.BitsData[i] = B.Data[i];

	debugServerMoveCallsReceived += 1;

	Old = IGPlus_SavedInputChain.Newest;
	if (Old == none) {
		Old = IGPlus_SavedInputChain.AllocateNode();
		Old.DeserializeFrom(IGPlus_InputReplicationBuffer);
		Old.TimeStamp = RefTimeStamp + Old.Delta;
		RefTimeStamp = Old.TimeStamp;
		if (IGPlus_SavedInputChain.AppendNode(Old) == false)
			IGPlus_SavedInputChain.FreeNode(Old);
	}

	while(IGPlus_InputReplicationBuffer.IsDataSufficient(class'IGPlus_SavedInput'.default.SerializedBits)) {
		Node = IGPlus_SavedInputChain.AllocateNode();
		Node.DeserializeFrom(IGPlus_InputReplicationBuffer);
		DeltaTime += Node.Delta;
		Node.TimeStamp = RefTimeStamp + DeltaTime;
		if (IGPlus_SavedInputChain.AppendNode(Node) == false)
			IGPlus_SavedInputChain.FreeNode(Node);
	}

	DeltaTime        = IGPlus_SavedInputChain.Newest.TimeStamp - CurrentTimeStamp;
	CurrentTimeStamp = IGPlus_SavedInputChain.Newest.TimeStamp;

	if (ServerTimeStamp != 0.0) {
		ServerDeltaTime = Level.TimeSeconds - ServerTimeStamp;
		ServerTimeStamp = Level.TimeSeconds;
		if (Level.Pauser == "")
			IGPlus_DetUpdateFireClockLead(CurrentTimeStamp, ServerDeltaTime);

		ExtrapolationDelta += (ServerDeltaTime - DeltaTime);
	} else {
		ServerTimeStamp = Level.TimeSeconds;
		ExtrapolationDelta = 0.0;
	}

	if (IGPlus_ShouldJitterBound()) {
		LostTime = -Old.TimeStamp;
		IGPlus_SavedInputChain.RemoveOutdatedNodes(CurrentTimeStamp + ExtrapolationDelta - zzUTPure.Settings.MaxJitterTime);
		Old = IGPlus_SavedInputChain.Oldest;
		LostTime += Old.TimeStamp;

		if (LostTime > 0.001)
			ClientDebugMessage("SAI LostTime"@Old.TimeStamp@CurrentTimeStamp@ExtrapolationDelta);
	}

	// Defer fast weapon switch until after PlayBackInput loop so Det
	// dispatch targets the pre-switch weapon the client was actually firing.

	// simulate lost time to match extrapolation done by all clients
	LostTime = RefTimeStamp - Old.TimeStamp; // typically <= 0
	LostTime = zzUTPure.RealPlayTime(ServerTimeStamp, LostTime); // this removed time spent paused
	if (LostTime > 0.001)
		SimMoveAutonomous(LostTime);

	while(Old.Next != none) {
		PlayBackInput(Old, Old.Next);
		if (bTraceInput && IGPlus_InputLogFile != none)
			IGPlus_InputLogFile.LogInput(Old.Next);
		Old = Old.Next;
	}

	IGPlus_DetCheckSwitchWedge();
	if (IGPlus_UseFastWeaponSwitch && PendingWeapon != None)
		ChangedWeapon();

	// clean up
	IGPlus_SavedInputChain.RemoveOutdatedNodes(Old.TimeStamp);
	IGPlus_DetFinalizeExpiredPrevWeapon();

	IGPlus_WarpFixUpdate = true;
	IGPlus_WantCAP = true;
}

function IGPlus_AcknowledgeInput() {
	if (IGPlus_WantCAP == false)
		return;

	IGPlus_SendCAP();
	IGPlus_WantCAP = false;
}

function xxRememberPosition()
{
	local float Now;

	NewestMI.Next = OldestMI;
	OldestMI = OldestMI.Next;
	NewestMI = NewestMI.Next;
	NewestMI.Next = none;

	NewestMI.Save(self);

	Now = Level.TimeSeconds;
	if (Now < zzNextPositionTime)
		return;

	zzLast10Positions[zzPositionIndex] = Location;
	zzPositionIndex++;
	if (zzPositionIndex >= arraycount(zzLast10Positions))
		zzPositionIndex = 0;
	zzNextPositionTime = Now + 0.05;

}

function bool xxCloseEnough(vector HitLoc, optional int HitRadius)
{
	local int i, MaxHitError;
	local vector Loc;
	local bbOldMovementInfo MI;

	MaxHitError = zzUTPure.Settings.MaxHitError + HitRadius;

	if (VSize(HitLoc - Location) < MaxHitError)
		return true;

	for (i = 0; i < 10; i++)
	{
		Loc = zzLast10Positions[i];
		if (VSize(HitLoc - Loc) < MaxHitError)
			return true;
	}

	MI = OldestMI;
	while (MI != none) {
		if (VSize(HitLoc - MI.Loc) < MaxHitError)
			return true;
		MI = MI.Next;
	}

	return false;

}

// Eye height in half units: 1 to 255 for -47.5 to 79.5. 0 means none.
static function int IGPlus_EyePack(float Eye) {
	return Clamp(int((Eye + 48.0) * 2.0 + 0.5), 1, 255);
}

static function float IGPlus_EyeUnpack(int B) {
	return 0.5 * (B & 0xFF) - 48.0;
}

// A move's time and its shot's eye height in one int, above the low byte
// (bDetReady, DetWeaponIndex, DetChargeData). The time has 16 bits of
// 1/65536 s: the engine never runs a frame longer than 0.4 s.
static function int IGPlus_PackDeltaEye(float Delta, int EyeByte) {
	return (Clamp(int(Delta * 65536), 0, 0xFFFF) << 8) | ((EyeByte & 0xFF) << 24);
}

static function float IGPlus_UnpackDelta(int Packed) {
	return ((Packed >>> 8) & 0xFFFF) * 0.0000152587890625;
}

// Client: the eye height this shot is traced from, as the server will get it,
// noted for the shot's move.
simulated function float IGPlus_ClientShotEye() {
	IGPlus_ShotEyeByte = IGPlus_EyePack(EyeHeight);
	return IGPlus_EyeUnpack(IGPlus_ShotEyeByte);
}

// Server: the eye height of the deterministic shot being run. The client's,
// where its move brought one and it is close enough to ours.
function float IGPlus_ServerShotEye() {
	local float Eye, Diff;

	IGPlus_ShotEyeDiff = 0.0;
	IGPlus_bShotEyeRefused = false;
	if (IGPlus_ShotEyeByte == 0)
		return EyeHeight;
	Eye = IGPlus_EyeUnpack(IGPlus_ShotEyeByte);
	IGPlus_ShotEyeDiff = Eye - EyeHeight;
	Diff = Abs(IGPlus_ShotEyeDiff);
	if (Diff > IGPLUS_EYE_MAX_DIFF) {
		IGPlus_bShotEyeRefused = true;
		IGPlus_HitStatEyeRefused++;
		return EyeHeight;
	}
	IGPlus_HitStatEyeUsed++;
	IGPlus_HitStatEyeDiffSum += Diff;
	IGPlus_HitStatEyeDiffMax = FMax(IGPlus_HitStatEyeDiffMax, Diff);
	return Eye;
}

// Where the server stands a player for a Precise Rewind Time shot: at the
// update the shooter's screen showed, carried on by that update's velocity
// for as long as the screen was past it (UTPlusDummy.CompSwap, and
// IGPlus_PRTRuleAge for that time on the client). Held at the update where
// warp fix holds a stalled player.
static function vector IGPlus_PRTRulePos(vector Loc, vector Vel, float Age, bool bHold) {
	if (bHold)
		return Loc;
	return Loc + Vel * FClamp(Age, -0.2, 0.2);
}

// How long a player's update has to be carried on to stand where the server
// stands them. The server carries its snapshot of the shown tick for
// ShownAge. Our update of this player is that snapshot when both arrived in
// one frame, and then the two times are the same. A player's update and the
// tick counter do not always arrive together: the counter can be a tick ahead
// of the update we have, or behind it. The player has moved on in that tick,
// so the update is carried for its own time (first match test, Nov 13 2026:
// carried for ShownAge, the trace was a tick's movement off on 15 of 1111
// shots, where the drawn bodies were right). A player whose packets stall
// gets no new snapshot on the server (UTPlusDummy takes one when a move
// ran), so the server carries the old one for the whole stall, and so do we
// (rig test, Nov 13 2026: carried for ShownAge only, the trace was up to 10
// units off during stalls of 40 to 80 ms).
static function float IGPlus_PRTRuleAge(float ShownTime, float UpdateTime) {
	return FMax(0.0, ShownTime - UpdateTime);
}

// Client, on another player's pawn: stand it there for our own trace. Called
// with the pawn where the last frame drew it (IGPlus_LocationOffsetFix_RestoreAll).
// Not on a lift (the server lines riders up with the lift) and not before the
// first update.
simulated function IGPlus_PRTRulePlace(float ShownTime, int ShownTick, bool bWarpFix, float WarpFixDelay) {
	local vector Loc, Vel;
	local float UpdateTime, Age, Lead;
	local int UpdateTick;

	IGPlus_bPRTRulePlaced = false;
	IGPlus_bPRTRuleDbgValid = false;
	IGPlus_bPRTRuleDbgPrev = false;
	IGPlus_PRTRuleDbgLead = 0.0;
	// (Not by Health: it arrives up to four updates after a respawn, see IGPlus_ClientShotTrace.)
	if (IGPlus_LocationOffsetFix_ServerLocationTime <= 0.0 || bHidden || IGPlus_bShownVisible == false
		|| IGPlus_LocationOffsetFix_WasOnMover || IGPlus_LocationOffsetFix_IsOnMover())
		return;
	Loc = IGPlus_LocationOffsetFix_ServerLocation;
	Vel = IGPlus_LocationOffsetFix_ServerVelocity;
	UpdateTime = IGPlus_LocationOffsetFix_ServerLocationTime;
	UpdateTick = IGPlus_LocationOffsetFix_ServerLocationTick;
	Lead = IGPlus_LocationOffsetFix_ServerLocationLead;
	// Held still by Adaptive Buffering in the last frame: the server stands
	// them at the spot that frame drew them at (UTPlusDummy.CompSwap). They
	// are put there, since this frame's update may have moved them on already.
	if (IGPlus_bPRTRuleHeld) {
		Loc = IGPlus_PRTRuleHeldLoc;
		Vel = vect(0,0,0);
		UpdateTime = ShownTime;
		UpdateTick = ShownTick;
		Lead = 0.0;
	// This frame's update is in already: the last frame showed the one before.
	} else if (UpdateTime == Level.TimeSeconds) {
		if (IGPlus_LocationOffsetFix_PrevServerLocationTime <= 0.0)
			return;
		Loc = IGPlus_LocationOffsetFix_PrevServerLocation;
		Vel = IGPlus_LocationOffsetFix_PrevServerVelocity;
		UpdateTime = IGPlus_LocationOffsetFix_PrevServerLocationTime;
		UpdateTick = IGPlus_LocationOffsetFix_PrevServerLocationTick;
		Lead = IGPlus_LocationOffsetFix_PrevServerLocationLead;
		IGPlus_bPRTRuleDbgPrev = true;
	}
	Age = IGPlus_PRTRuleAge(ShownTime, UpdateTime);
	IGPlus_PRTRuleSavedLoc = Location;
	IGPlus_PRTRuleDbgLoc = IGPlus_PRTRulePos(Loc, Vel, Age, bWarpFix && Age > WarpFixDelay);
	IGPlus_PRTRuleDbgVel = Vel;
	IGPlus_PRTRuleDbgAge = Age;
	IGPlus_PRTRuleDbgLead = Lead;
	IGPlus_PRTRuleDbgLag = ShownTick - UpdateTick;
	IGPlus_bPRTRuleDbgValid = true;
	bCollideWorld = false;
	SetLocation(IGPlus_PRTRuleDbgLoc);
	bCollideWorld = true;
	IGPlus_bPRTRulePlaced = true;
}

// Client, on another player's pawn: stand it where our frame number Frame
// drew it, for our own trace (Location Offset Fix off). A player held still
// by Adaptive Buffering was drawn at the held spot, so that is covered.
simulated function IGPlus_PRTPicturePlace(int Frame, float Lead) {
	IGPlus_bPRTRulePlaced = false;
	IGPlus_bPRTRuleDbgValid = false;
	IGPlus_bPRTRuleDbgPrev = false;
	IGPlus_PRTRuleDbgLead = 0.0;
	// (Not by Health: it arrives up to four updates after a respawn, see IGPlus_ClientShotTrace.)
	if (IGPlus_ShownFrame != Frame || bHidden || IGPlus_bShownVisible == false)
		return;
	IGPlus_PRTRuleSavedLoc = Location;
	IGPlus_PRTRuleDbgLoc = IGPlus_ShownLoc;
	IGPlus_PRTRuleDbgVel = Velocity;
	IGPlus_PRTRuleDbgAge = 0.0;
	IGPlus_PRTRuleDbgLead = Lead;
	IGPlus_PRTRuleDbgLag = 0;
	IGPlus_bPRTRuleDbgValid = true;
	bCollideWorld = false;
	SetLocation(IGPlus_ShownLoc);
	bCollideWorld = true;
	IGPlus_bPRTRulePlaced = true;
}

simulated function IGPlus_PRTRuleUndo() {
	if (IGPlus_bPRTRulePlaced == false)
		return;
	IGPlus_bPRTRulePlaced = false;
	bCollideWorld = false;
	SetLocation(IGPlus_PRTRuleSavedLoc);
	bCollideWorld = true;
}

// Client: does the server place players by our Precise Rewind Time report
// for the shot we are about to trace? The same conditions as the report
// itself (xxReplicateMove, SendSavedMove).
function bool IGPlus_PRTTraceUsable() {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	return WS != None && WS.bEnablePingCompensation
		&& IGPlus_EnableSnapshotInterpolation == false && IGPlus_EnableInputReplication == false
		&& Settings != None && IGPlus_PRTSeenAt > 0 && IGPlus_PRTShownTick != 0;
}
// Our own trace stands the others where the server will (IGPlus_PRTRulePlace).
// That needs the record of each player's updates, which Location Offset Fix keeps.
function bool IGPlus_PRTRuleUsable() {
	return IGPlus_PRTTraceUsable() && Settings.bEnableLocationOffsetFix && IGPlus_EnableTickInterp == false;
}
// With Location Offset Fix off there is no such record: the engine blends
// each update into the pawn's spot (AActor::PostNetReceive moves a simulated
// pawn 15% of the way), so script never sees the spot the server sent. Our
// own trace then tests the others where the last frame drew them
// (IGPlus_PRTPicturePlace). The engine carries a player on every frame, also
// in the frame an update arrives, so in steady movement that picture is the
// server's spot once the shot counts that frame (IGPlus_PRTShownLead).
// Tick Interpolation uses it too: there the picture is a spot the server can
// stand the player at exactly, from the tick position the shot reports.
function bool IGPlus_PRTPictureUsable() {
	return IGPlus_PRTTraceUsable() && (Settings.bEnableLocationOffsetFix == false || IGPlus_EnableTickInterp);
}

function IGPlus_PRTRuleAll(bool bPlace, optional bool bPicture) {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;

	if (GameReplicationInfo == None)
		return;
	for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
		PRI = GameReplicationInfo.PRIArray[i];
		if (PRI == None) break;
		P = bbPlayer(PRI.Owner);
		if (P == None || P.Role != ROLE_SimulatedProxy) continue;
		if (bPlace == false)
			P.IGPlus_PRTRuleUndo();
		else if (bPicture)
			P.IGPlus_PRTPicturePlace(IGPlus_FrameCount - 1, IGPlus_PRTShownLead * float(int(IGPlus_EnableTickInterp == false)));
		else
			P.IGPlus_PRTRulePlace(IGPlus_PRTShownTime, IGPlus_PRTShownTick,
				IGPlus_EnableWarpFix, IGPlus_WarpFixDelay);
	}
}

// One decimal, for log lines.
static function string IGPlus_Fmt1(float F) {
	local int T;
	local string S;

	T = int(Abs(F) * 10.0 + 0.5);
	S = (T / 10)$"."$(T - (T / 10) * 10);
	if (F < 0 && T != 0)
		return "-"$S;
	return S;
}

static function string IGPlus_FmtVec1(vector V) {
	return IGPlus_Fmt1(V.X)$","$IGPlus_Fmt1(V.Y)$","$IGPlus_Fmt1(V.Z);
}

// How far a line passes a standing cylinder: what is missing to its side and
// to its top or bottom, at the line's closest point to the centre.
static function float IGPlus_LineCylinderGap(vector Start, vector Dir, vector Loc, float Radius, float Height) {
	local vector Closest;

	Closest = Start + Dir * FMax(0.0, (Loc - Start) dot Dir);
	return FMax(0.0, VSize((Closest - Loc) * vect(1,1,0)) - Radius) + FMax(0.0, Abs(Closest.Z - Loc.Z) - Height);
}

// Client, enableDebugData 1: one "Own trace" line a shot, for the player the
// trace hit or passed closest. It says what the trace against the server's
// placement said, what the one against the drawn bodies said, and what the
// placement was made of: how old that player's update was (updAge), how many
// ticks it was behind the tick counter (tickLag), whether the update before
// the newest one was used (prev), how much that player's velocity changed
// between the last two updates (velChange), the smoothing offset of the
// drawn body (smooth), and both spots. The server's [DET-HIT] line for the
// same shot has its own spot (srvLoc), so the three can be laid side by side.
// Called with the others where the last frame drew them.
function IGPlus_ClientShotTraceDebug(Actor Other, Actor Drawn, bool bRule, vector StartTrace, vector EndTrace, optional bool bPicture) {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P, Best;
	local vector Dir;
	local float Gap, RuleGap, BestGap, BestRuleGap;
	local string S;

	Dir = Normal(EndTrace - StartTrace);
	Best = bbPlayer(Other);
	if (Best == None)
		Best = bbPlayer(Drawn);
	if (GameReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == None) break;
			P = bbPlayer(PRI.Owner);
			if (P == None || P.Role != ROLE_SimulatedProxy || P.bHidden || PRI.bIsSpectator) continue;
			if (bbPlayer(Other) != None || bbPlayer(Drawn) != None) {
				if (P != Best) continue;
			}
			Gap = IGPlus_LineCylinderGap(StartTrace, Dir, P.Location, P.CollisionRadius, P.CollisionHeight);
			RuleGap = Gap;
			if (bRule && P.IGPlus_bPRTRuleDbgValid)
				RuleGap = IGPlus_LineCylinderGap(StartTrace, Dir, P.IGPlus_PRTRuleDbgLoc, P.CollisionRadius, P.CollisionHeight);
			if (P == Best || Best == None || FMin(Gap, RuleGap) < FMin(BestGap, BestRuleGap)) {
				Best = P;
				BestGap = Gap;
				BestRuleGap = RuleGap;
			}
		}
	}

	// rule=picture: Location Offset Fix is off and the trace tested the
	// others where the last frame drew them (ruleLoc is that spot).
	if (bPicture)
		S = "rule=picture hit="$(Pawn(Other) != None);
	else if (bRule)
		S = "rule="$(Pawn(Other) != None)@"drawn="$(Pawn(Drawn) != None);
	else if (Settings != None && Settings.bEnableLocationOffsetFix == false)
		S = "rule=off(LocationOffsetFix off) drawn="$(Pawn(Other) != None);
	else
		S = "rule=off drawn="$(Pawn(Other) != None);
	if (Best == None || Best.PlayerReplicationInfo == None || (Pawn(Other) == None && Pawn(Drawn) == None && FMin(BestGap, BestRuleGap) > 150.0)) {
		ClientDebugMessage("Own trace:"@S@"target=none");
		return;
	}
	S = S@"target="$Best.PlayerReplicationInfo.PlayerName@"drawnGap="$IGPlus_Fmt1(BestGap)@"drawnLoc="$IGPlus_FmtVec1(Best.Location);
	if (bRule && Best.IGPlus_bPRTRuleDbgValid)
		S = S@"ruleGap="$IGPlus_Fmt1(BestRuleGap)@"ruleLoc="$IGPlus_FmtVec1(Best.IGPlus_PRTRuleDbgLoc)
			@"apart="$IGPlus_Fmt1(VSize(Best.IGPlus_PRTRuleDbgLoc - Best.Location))
			@"updAge="$IGPlus_Fmt1(1000.0 * Best.IGPlus_PRTRuleDbgAge)@"lead="$IGPlus_Fmt1(1000.0 * Best.IGPlus_PRTRuleDbgLead)@"tickLag="$Best.IGPlus_PRTRuleDbgLag
			@"prev="$Best.IGPlus_bPRTRuleDbgPrev@"vel="$IGPlus_FmtVec1(Best.IGPlus_PRTRuleDbgVel)
			@"velChange="$int(VSize(Best.IGPlus_LocationOffsetFix_ServerVelocity - Best.IGPlus_LocationOffsetFix_PrevServerVelocity))
			@"smooth="$IGPlus_Fmt1(VSize(Best.IGPlus_LocationOffsetFix_PredictionOffset));
	else if (bRule)
		S = S@"notPlaced";
	S = S@"shownAge="$IGPlus_Fmt1(1000.0 * IGPlus_PRTShownAge)@"shownTick="$(IGPlus_PRTShownTick & 0x7FFF);
	// Tick Interpolation: the tick position that player was drawn at, whether
	// that was past their newest update, that update's tick, and their delay.
	if (IGPlus_EnableTickInterp)
		S = S@"shownR="$Best.IGPlus_ShownR@"past="$Best.IGPlus_bShownPast@"held="$Best.IGPlus_bShownHeld@"duck="$Best.IGPlus_ShownDuck
			@"ticks="$(int(Best.IGPlus_ShownR) - (Best.IGPlus_ShownSpan & 3))$"-"$(int(Best.IGPlus_ShownR) + 1 + ((Best.IGPlus_ShownSpan >> 2) & 3))
			@"newTick="$Best.IGPlus_TI_Tick[(Best.IGPlus_TI_Head - 1) & 15]@"delay="$IGPlus_Fmt1(Best.IGPlus_TI_Delay)
			@"tickMs="$IGPlus_Fmt1(1000.0 * IGPlus_TI_TickLen);
	ClientDebugMessage("Own trace:"@S);
}

function Actor IGPlus_ClientShotTraceOnce(
	out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace, IGPlus_WeaponImplementationBase WB
) {
	if (WB != None)
		return WB.TraceShotClient(HitLocation, HitNormal, EndTrace, StartTrace, self);
	return NN_TraceShot(HitLocation, HitNormal, EndTrace, StartTrace, self);
}

// Client: our own trace of a deterministic hitscan shot. WB is set where the
// server's reduced hitbox setting is on. HitOffset is the hit point on the
// body that was hit, IGPlus_bShotHead whether that was the head.
//
// The trace tests the other players where the server will test them, not
// where the screen draws them. The screen draws a player at the last update
// carried on by its velocity, plus a smoothing offset that fades after the
// player changes direction. The server has no such offset, so a trace against
// the drawn bodies said hit for shots the server counts as a miss, a few
// units off the edge. Nothing here decides a hit: the server's trace does.
// With Precise Rewind Time not in use the server's spot can't be worked out
// here, and the drawn bodies are tested as before.
//
// Where the two differ on whether a player was hit, IGPlus_bShotDrawnDiffers
// says so and the server counts it (hitDrawnDiff).
// Client, with the others standing where IGPlus_PRTRulePlace put them: the
// player this shot is at (the one it hit, or else the one it passed
// closest, within 100 units). The shot's move adds that player's lead to the age it
// reports, so the server carries that player on by the frame the engine had
// moved them already. The server carries every player by the one reported
// age, so only the shot's own target is exact (rig test, Nov 13 2026: with
// no lead the server stood a target who was changing speed one client frame
// of movement behind the spot our trace used, about 10 ms). With Tick
// Interpolation the shot reports the tick position that player was drawn at.
function bbPlayer IGPlus_PRTShotTarget(Actor Other, vector Start, vector Dir) {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P, Best;
	local float Gap, BestGap;

	if (bbPlayer(Other) != None && bbPlayer(Other).IGPlus_bPRTRulePlaced)
		return bbPlayer(Other);
	if (GameReplicationInfo == None)
		return None;
	BestGap = 100.0;
	for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
		PRI = GameReplicationInfo.PRIArray[i];
		if (PRI == None) break;
		P = bbPlayer(PRI.Owner);
		if (P == None || P.Role != ROLE_SimulatedProxy || P.IGPlus_bPRTRulePlaced == false) continue;
		Gap = IGPlus_LineCylinderGap(Start, Dir, P.Location, P.CollisionRadius, P.CollisionHeight);
		if (Gap < BestGap) {
			Best = P;
			BestGap = Gap;
		}
	}
	return Best;
}

// Client, Tick Interpolation: the other player nearest our line of sight, where
// the last frame drew them. Every move reports the tick position that player
// was drawn at, so a weapon with no trace of its own on this client (the
// shock rifle, the minigun, a projectile) is still tested against the moment
// the screen showed its target. Players are drawn with different delays, and
// the server stands them all at the one reported moment, so it has to be the
// moment of the one we aim at (rig, Nov 14 2026: with "2 ticks back" for
// everyone, 31 of 88 shock rifle shots at a target with a bad connection
// looked different from what the server decided).
function bbPlayer IGPlus_TI_AimTarget() {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P, Best;
	local vector Start, Dir;
	local float Gap, BestGap;

	if (GameReplicationInfo == None)
		return None;
	Start = Location + EyeHeight * vect(0,0,1);
	Dir = vector(ViewRotation);
	for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
		PRI = GameReplicationInfo.PRIArray[i];
		if (PRI == None) break;
		P = bbPlayer(PRI.Owner);
		if (P == None || P == self || P.Role != ROLE_SimulatedProxy || P.IGPlus_TI_Use() == false) continue;
		if (P.bHidden || P.Health <= 0 || P.IGPlus_TI_Num == 0) continue;
		// Drawn in the last frame, and in front of us.
		if (P.IGPlus_ShownFrame < IGPlus_FrameCount - 1 || ((P.IGPlus_ShownLoc - Start) dot Dir) <= 0.0) continue;
		Gap = IGPlus_LineCylinderGap(Start, Dir, P.IGPlus_ShownLoc, P.CollisionRadius, P.CollisionHeight);
		if (Best == None || Gap < BestGap) {
			Best = P;
			BestGap = Gap;
		}
	}
	return Best;
}

function Actor IGPlus_ClientShotTrace(
	out vector HitLocation, out vector HitNormal, out vector HitOffset,
	vector EndTrace, vector StartTrace, IGPlus_WeaponImplementationBase WB
) {
	local Actor Other, Drawn;
	local vector DrawnLoc, DrawnNormal;
	local bool bRule, bPicture;
	local bbPlayer ShotTarget;
	local int i, NumSwitched, SwitchedFlags[32];
	local PlayerReplicationInfo PRI;
	local Pawn P, Switched[32];

	IGPlus_bShotDrawnDiffers = false;
	IGPlus_PRTShotR = 0.0;
	IGPlus_bShotHead = false;
	bRule = IGPlus_PRTRuleUsable();
	bPicture = bRule == false && IGPlus_PRTPictureUsable();

	IGPlus_LocationOffsetFix_RestoreAll();
	// For the traces below a player's collision follows what this client
	// shows: hidden, it can not be hit, and shown, it can. The server hides a
	// killed player and takes their collision away in one tick, and shows a
	// respawned one and gives it back in one tick. But the engine sends another
	// player's bHidden with every update and bCollideActors and Health only
	// with every fifth (APawn::GetOptimizedRepList). So for up to four updates
	// after a kill the body is hidden here and still collides, and our trace
	// hit it: a hit sound and marker on a player someone else had just killed,
	// and the server refused the hit. And for up to four updates after a
	// respawn the player is drawn here and has no collision: our beam went
	// through them and the server's hit came a ping late. Hidden bodies are out
	// of the trace, so the beam goes on to what is behind them, as the
	// server's does. Players our last frame drew are in it.
	if (GameReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == None) break;
			P = Pawn(PRI.Owner);
			if (P == None || P == self) continue;
			if (P.bHidden) {
				if (P.bCollideActors == false) continue;
				if (bDrawDebugData)
					ClientDebugMessage("Hidden body left out of our trace:"@PRI.PlayerName
						@"gap="$IGPlus_Fmt1(IGPlus_LineCylinderGap(StartTrace, Normal(EndTrace - StartTrace), P.Location, P.CollisionRadius, P.CollisionHeight)));
			} else {
				// Shown: with a mesh (a waiting player has none), no spectator, and
				// drawn by the frame this shot was aimed in.
				if (P.bCollideActors || P.Mesh == None || PRI.bIsSpectator || PRI.bWaitingPlayer)
					continue;
				if (bbPlayer(P) != None && (bbPlayer(P).IGPlus_ShownFrame != IGPlus_FrameCount - 1 || bbPlayer(P).IGPlus_bShownVisible == false))
					continue;
				if (bDrawDebugData)
					ClientDebugMessage("Shown body taken into our trace:"@PRI.PlayerName);
			}
			Switched[NumSwitched] = P;
			SwitchedFlags[NumSwitched] = int(P.bCollideActors) + 2 * int(P.bBlockActors) + 4 * int(P.bBlockPlayers);
			NumSwitched++;
			if (P.bHidden)
				P.SetCollision(false, P.bBlockActors, P.bBlockPlayers);
			else
				P.SetCollision(true, true, true);
		}
	}
	if (bRule) {
		// First against the bodies as drawn, for the count only.
		Drawn = IGPlus_ClientShotTraceOnce(DrawnLoc, DrawnNormal, EndTrace, StartTrace, WB);
		IGPlus_PRTRuleAll(true);
	} else if (bPicture) {
		IGPlus_PRTRuleAll(true, true);
	}
	Other = IGPlus_ClientShotTraceOnce(HitLocation, HitNormal, EndTrace, StartTrace, WB);
	if (Other != None)
		HitOffset = HitLocation - Other.Location;
	if (Pawn(Other) != None) {
		if (WB != None)
			IGPlus_bShotHead = WB.CheckHeadShot(Pawn(Other), HitLocation, Normal(EndTrace - StartTrace));
		else
			IGPlus_bShotHead = HitOffset.Z > 0.62 * Other.CollisionHeight;
	}
	IGPlus_PRTShotLead = 0.0;
	if (bRule) {
		ShotTarget = IGPlus_PRTShotTarget(Other, StartTrace, Normal(EndTrace - StartTrace));
		if (ShotTarget != None)
			IGPlus_PRTShotLead = ShotTarget.IGPlus_PRTRuleDbgLead;
		IGPlus_PRTRuleAll(false);
		IGPlus_bShotDrawnDiffers = (Pawn(Drawn) != None) != (Pawn(Other) != None);
	} else if (bPicture) {
		if (IGPlus_EnableTickInterp) {
			// The tick position the shot's target was drawn at.
			ShotTarget = IGPlus_PRTShotTarget(Other, StartTrace, Normal(EndTrace - StartTrace));
			if (ShotTarget != None) {
				IGPlus_PRTShotR = ShotTarget.IGPlus_ShownR;
				IGPlus_bPRTShotPast = ShotTarget.IGPlus_bShownPast;
				IGPlus_bPRTShotHeld = ShotTarget.IGPlus_bShownHeld;
				IGPlus_PRTShotDelay = ShotTarget.IGPlus_TI_Delay + IGPlus_TI_Recv;
				IGPlus_PRTShotSpan = ShotTarget.IGPlus_ShownSpan;
			}
		} else {
			// The same frame for every player: the engine moves them all on.
			IGPlus_PRTShotLead = IGPlus_PRTShownLead;
		}
		IGPlus_PRTRuleAll(false);
		Drawn = Other;
	}
	if (bDrawDebugData)
		IGPlus_ClientShotTraceDebug(Other, Drawn, bRule || bPicture, StartTrace, EndTrace, bPicture);
	for (i = 0; i < NumSwitched; ++i)
		Switched[i].SetCollision((SwitchedFlags[i] & 1) != 0, (SwitchedFlags[i] & 2) != 0, (SwitchedFlags[i] & 4) != 0);
	IGPlus_LocationOffsetFix_UndoRestoreAll();
	return Other;
}

// Client: our own trace of a deterministic hitscan shot (ST_SuperShockRifle,
// SA_SniperRifle). A hit on a player plays the hit sound and marker now, where
// the player's Hit Source is Client, and the verdict goes into the shot's move
// for the server to compare (IGPlus_HitCompare).
simulated function IGPlus_ClientShotVerdict(Actor Other, float Damage, name DamageType, bool bHead) {
	local Pawn Victim;

	Victim = Pawn(Other);
	if (Victim == None || Victim.PlayerReplicationInfo == None || PlayerReplicationInfo == None) {
		IGPlus_ClientHitVerdict = IGPLUS_HIT_MISS;
		if (IGPlus_bShotDrawnDiffers)
			IGPlus_ClientHitVerdict += IGPLUS_HIT_DRAWNDIFF;
		IGPlus_ClientHitPlayedTS = 0.0;
		return;
	}
	if (bHead)
		IGPlus_ClientHitVerdict = IGPLUS_HIT_HEAD;
	else
		IGPlus_ClientHitVerdict = IGPLUS_HIT_BODY;
	if (IGPlus_bShotDrawnDiffers)
		IGPlus_ClientHitVerdict += IGPLUS_HIT_DRAWNDIFF;
	IGPlus_ClientHitPlayedTS = Level.TimeSeconds;
	class'bbPlayerStatics'.static.PlayClientHitResponse(self, Victim, Damage, DamageType);
}

// Client, Hit Effect Source on Server: our beam ended on this player at the
// click and its ring waits for the server's word. The ring goes where the
// beam ended, so that spot is worked out now: with Beam Destination Mode on
// Attached the beam's end is the player's drawn spot plus the hit offset.
simulated function IGPlus_RingHold(Pawn Victim, vector SourceLocation, vector SourceOffset, vector HitLocation, vector HitOffset, vector HitNormal) {
	IGPlus_RingVictimPRI = Victim.PlayerReplicationInfo;
	IGPlus_RingSourceLoc = SourceLocation;
	IGPlus_RingSourceOffset = SourceOffset;
	if (Settings != None && Settings.BeamDestinationMode == 1)
		IGPlus_RingLoc = class'WeaponEffect'.static.GetPlayerLocation(Victim) + HitOffset;
	else
		IGPlus_RingLoc = HitLocation;
	IGPlus_RingNormal = HitNormal;
	IGPlus_RingTS = Level.TimeSeconds;
}

// Client: the server's hit message for a hit of ours on this player
// (IGPlus_HitFeedbackMessage). The ring that waited for it shows now, at the
// end of the beam. No message, no ring: the server did not count the hit.
// ponytail: one ring waits at a time. The rifle fires slower than a ping.
simulated function IGPlus_RingConfirm(PlayerReplicationInfo VictimPRI) {
	if (IGPlus_RingVictimPRI == None || VictimPRI != IGPlus_RingVictimPRI)
		return;
	IGPlus_RingVictimPRI = None;
	if (Level.TimeSeconds - IGPlus_RingTS > IGPLUS_RING_WAIT * Level.TimeDilation)
		return;
	SendWeaponEffect(
		class'SuperShockRifleRingEffect',
		PlayerReplicationInfo,
		IGPlus_RingSourceLoc,
		IGPlus_RingSourceOffset,
		None,
		IGPlus_RingLoc,
		IGPlus_RingLoc,
		IGPlus_RingNormal);
}

// Client: the server's hit message is here (IGPlus_HitFeedbackMessage). Did
// our own trace already play this hit? One shot, one message: these weapons
// fire slower than a ping.
// ponytail: one time stamp. A weapon that fires faster than the ping, or one
// carried next to other weapons, needs a shot id in the message.
simulated function bool IGPlus_TakeClientHit() {
	if (IGPlus_ClientHitPlayedTS <= 0.0 || Level.TimeSeconds - IGPlus_ClientHitPlayedTS > 0.6)
		return false;
	IGPlus_ClientHitPlayedTS = 0.0;
	return true;
}

// Server: this deterministic shot's trace against what the shooter's own
// trace said (IGPlus_ClientHitVerdict, from the shot's move). Called before
// the damage. Nothing is decided here: the server's trace stands. A
// difference is counted, and gets one [DET-HIT] line. For a hit only the
// client saw, the line names the nearest rewound body and what the server's
// line was missing to its cylinder (gapXY, gapZ). blocked=True is a body
// behind something solid.
function IGPlus_HitCompare(Actor Other, bool bHead, vector Start, vector Dir, vector HitLocation) {
	local bool bServerHit, bClientHit, bDrawnHit, bBlocked, bBestBlocked;
	local Pawn P, Best;
	local UTPlusDummy D;
	local vector Loc, Closest;
	local float Reach, T, GapXY, GapZ, BestXY, BestZ, BestT;
	local IGPlus_WeaponImplementationBase WB;
	local string S;

	if (IGPlus_ClientHitVerdict == 0) {
		// The client made no trace for this shot, or the shot ran on another
		// move than the client's (the shot's own move was lost).
		IGPlus_HitStatNoData++;
		return;
	}
	bServerHit = Pawn(Other) != None && Pawn(Other).PlayerReplicationInfo != None;
	bClientHit = IGPlus_ClientHitVerdict != IGPLUS_HIT_MISS;
	// The client's trace against the bodies as its screen drew them. The
	// verdict is from the trace on our own rule (IGPlus_ClientShotTrace).
	bDrawnHit = bClientHit != IGPlus_bShotDrawnDiffers;
	IGPlus_HitStatShots++;
	// How far the shooter's own spot was from ours when it fired.
	if (IGPlus_ShotOriginGap >= 0.0) {
		if (IGPlus_ShotOriginFrom != 1)
			IGPlus_HitStatOriginFar++;
		IGPlus_HitStatOriginGapMax = FMax(IGPlus_HitStatOriginGapMax, IGPlus_ShotOriginGap);
	}
	if (IGPlus_bShotDrawnDiffers) {
		IGPlus_HitStatDrawnDiff++;
		if (bDrawnHit == bServerHit)
			IGPlus_HitStatDrawnRight++;
	}
	if (bServerHit == bClientHit) {
		if (bServerHit) {
			IGPlus_HitStatBoth++;
			if (bHead != (IGPlus_ClientHitVerdict == IGPLUS_HIT_HEAD))
				IGPlus_HitStatHeadDiff++;
		}
		// (A player with enableDebugData 1 gets the line for every shot.)
		if (IGPlus_bShotDrawnDiffers == false && bDrawDebugData == false)
			return;
	} else if (bServerHit) {
		IGPlus_HitStatServerOnly++;
	} else {
		IGPlus_HitStatClientOnly++;
	}

	Reach = VSize(HitLocation - Start);
	if (bServerHit) {
		Best = Pawn(Other);
		BestT = Reach;
	} else {
		for (P = Level.PawnList; P != None; P = P.NextPawn) {
			if (P == self || P.PlayerReplicationInfo == None || P.PlayerReplicationInfo.bIsSpectator
				|| P.Health <= 0 || P.bHidden)
				continue;
			Loc = P.Location;
			if (zzUTPure != None)
				D = zzUTPure.FindDummy(P);
			else
				D = None;
			if (D != None)
				Loc = D.Location;
			T = FMax(0.0, (Loc - Start) dot Dir);
			bBlocked = T > Reach + P.CollisionRadius;
			Closest = Start + Dir * T;
			GapXY = FMax(0.0, VSize((Closest - Loc) * vect(1,1,0)) - P.CollisionRadius);
			GapZ = FMax(0.0, Abs(Closest.Z - Loc.Z) - P.CollisionHeight);
			if (Best == None || GapXY + GapZ < BestXY + BestZ) {
				Best = P;
				BestXY = GapXY;
				BestZ = GapZ;
				BestT = T;
				bBestBlocked = bBlocked;
			}
		}
	}

	// drawnOnly: only the drawn bodies said hit, so the old trace would have
	// played a hit sound for nothing. drawnMissed: only they said miss.
	if (bServerHit == bClientHit) {
		if (IGPlus_bShotDrawnDiffers == false)
			S = "agree";
		else if (bDrawnHit)
			S = "drawnOnly";
		else
			S = "drawnMissed";
	} else if (bServerHit)
		S = "serverOnly";
	else
		S = "clientOnly";
	S = S@"hit="$bServerHit@"drawnHit="$bDrawnHit;
	if (Weapon != None)
		S = S@"weapon="$Weapon.Class.Name;
	if (Best != None && Best.PlayerReplicationInfo != None) {
		S = S@"nearest="$Best.PlayerReplicationInfo.PlayerName@"dist="$int(BestT)@"speed="$int(VSize(Best.Velocity));
		if (bServerHit == false)
			S = S@"gapXY="$BestXY@"gapZ="$BestZ@"blocked="$bBestBlocked;
		// Where we stood that player for this shot, to lay beside the
		// shooter's "Own trace" line (ruleLoc, drawnLoc).
		D = None;
		if (zzUTPure != None)
			D = zzUTPure.FindDummy(Best);
		if (D != None)
			S = S@"srvLoc="$IGPlus_FmtVec1(D.Location)@"srvVel="$IGPlus_FmtVec1(D.Velocity)@"srvDuck="$int(255.0 * D.DuckFraction);
		// The shot pointed at a moment that player could not be hit in, and
		// we stood them at the first one they could (UTPlusDummy.CompSwap).
		if (D != None && D.bCompFirstHittable)
			S = S@"firstHittable";
		// srvGap: how old our snapshot of that player was at the time the
		// shooter saw. srvCarry: for how long we carried it on.
		if (IGPlus_PRTUsable()) {
			S = S@"srvAge="$IGPlus_Fmt1(1000.0 * (IGPlus_PRTViewTimeNow() - IGPlus_PRTSeenTime));
			if (D != None)
				S = S@"srvGap="$IGPlus_Fmt1(1000.0 * D.CompGap)@"srvCarry="$IGPlus_Fmt1(1000.0 * D.CompCarry);
			// Tick Interpolation: the tick position we read from the report,
			// and the ticks of the two snapshots we stood that player between.
			if (D != None && IGPlus_bPRTInterp)
				S = S@"srvR="$IGPlus_PRTInterpR@"srvPast="$IGPlus_bPRTInterpPast@"srvHeld="$IGPlus_bPRTInterpHeld@"srvDelayMs="$IGPlus_Fmt1(IGPlus_PRTInterpDelayMs)@"srvTicks="$D.CompTickA$"-"$D.CompTickB;
		}
	}
	WB = IGPlus_GetWeaponImplementationBase();
	if (WB != None)
		S = S@"rewindMs="$int(WB.IGPlus_GetHitscanRewindMs(self))@"prt="$IGPlus_PRTUsable();
	// The client's eye height minus ours for this shot, and whether we used it.
	S = S@"eyeDiff="$IGPlus_ShotEyeDiff;
	if (IGPlus_bShotEyeRefused)
		S = S@"eyeRefused";
	// The shooter's own spot against ours when it fired, and which one the
	// shot left from (IGPlus_PSAShotOrigin).
	if (IGPlus_ShotOriginGap >= 0.0) {
		S = S@"originGap="$IGPlus_ShotOriginGap;
		if (IGPlus_ShotOriginFrom == 1)
			S = S@"origin=client";
		else if (IGPlus_ShotOriginFrom == 2)
			S = S@"origin=push";
		else
			S = S@"origin=server";
	}
	S = S@"ping="$PlayerReplicationInfo.Ping;
	// The server log gets the disagreements only.
	if (bServerHit != bClientHit || IGPlus_bShotDrawnDiffers)
		IGPlus_EventLog("[DET-HIT]"@PlayerReplicationInfo.PlayerName@S);
	// The shooter's own line (enableDebugData 1).
	if (bDrawDebugData)
		ClientDebugMessage("Hit check (server):"@S);
}

// Server, dead: a move we take no shot from. Its client fired the rifle or
// the sniper on it (the move carries that shot's verdict), with its beam and,
// where its own trace hit, its hit sound. No trace is wrong here: the shooter
// was dead first and the shot does not trade. Counted (deadShots,
// deadShotHits), with one [DET-HIT] line and a line for the shooter.
function IGPlus_NoteDeadShot(int MoveDeltaTime) {
	local int Verdict, WeaponIndex;
	local string S;

	Verdict = (MoveDeltaTime & 0xF0) >> 4;
	WeaponIndex = (MoveDeltaTime & 0x0E) >> 1;
	if (Verdict < IGPLUS_HIT_MISS || (Verdict & 3) == 3
		|| (WeaponIndex != IGPLUS_DetWEAPON_SuperShockRifle && WeaponIndex != IGPLUS_DetWEAPON_SniperRifle))
		return;
	IGPlus_HitStatDeadShots++;
	if ((Verdict & 3) != 0)
		IGPlus_HitStatDeadHits++;
	S = "deadShot clientHit="$((Verdict & 3) != 0)@"deadFor="$RealTimeDead@"trades="$IGPlus_DetTradesEnabled()
		@"ping="$PlayerReplicationInfo.Ping;
	IGPlus_EventLog("[DET-HIT]"@PlayerReplicationInfo.PlayerName@S);
	if (bDrawDebugData)
		ClientDebugMessage("Hit check (server):"@S);
}

// Do the deterministic weapons trade here? NextIG and NextSA have their own
// switch in the weapon settings (bEnableTrades, off by default: InstaGib and
// Sniper Arena are played without trades). Everywhere else the server setting
// decides (bEnableAllWeaponTrades).
function bool IGPlus_DetTradesEnabled() {
	local WeaponSettingsRepl WS;

	if (IGPlus_WeaponSettingsMode != 0) {
		WS = GetWeaponSettings();
		return WS != None && WS.bEnableTrades;
	}
	return zzUTPure.Settings.bEnableAllWeaponTrades;
}

// Client: we carry a weapon that plays its hit sound and marker from our own
// trace (bbPlayerStatics.PlayClientHitResponse). Only then may the server's be
// skipped (IGPlus_HitFeedbackMessage). Carried, not held: the server's message
// comes a ping after the shot, and by then we may hold the translocator.
simulated function bool IGPlus_HasClientHitResponse() {
	local Inventory I;
	local int n;

	for (I = Inventory; I != none && n < 100; I = I.Inventory) {
		n++;
		if (NN_SuperShockRifle(I) != none && NN_SuperShockRifle(I).bNewNet)
			return true;
		if (NN_ShockRifle(I) != none && NN_ShockRifle(I).bNewNet)
			return true;
		if (NN_SniperRifle(I) != none && NN_SniperRifle(I).bNewNet)
			return true;
	}
	return false;
}

function bool xxWeaponIsNewNet( optional bool bAlt )
{
	if (Weapon == None)
		return false;

	return (Weapon.IsA('NN_ShockRifle')
		|| Weapon.IsA('NN_SuperShockRifle')
		|| Weapon.IsA('NN_SniperRifle')
		|| Weapon.IsA('NN_ASMD')
		|| Weapon.IsA('NN_ShockDOMRifle')
	);
}

simulated function actor NN_TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace, Pawn TheOwner)
{
	local vector realHit;
	local actor Other;
	if (!zzbNN_Tracing)
	{
		zzbNN_Tracing = true;
		xxEnableCarcasses();
	}
	Other = TheOwner.Trace(HitLocation,HitNormal,EndTrace,StartTrace,True);
	if ( Pawn(Other) != None )
	{
		realHit = HitLocation;
		if ( bbPlayer(Other) != None && !bbPlayer(Other).ClientAdjustHitLocation(HitLocation, EndTrace - StartTrace) )
			Other = NN_TraceShot(HitLocation,HitNormal,EndTrace,realHit,Pawn(Other));
	}
	if (zzbNN_Tracing)
	{
		zzbNN_Tracing = false;
		xxDisableCarcasses();
	}
	return Other;
}

function bool IGPlus_LineIntersectsCylinder(
	vector Start,
	vector End,
	vector CylinderCenter,
	float Radius,
	float HalfHeight
) {
	local vector ClosestPoint, LineDelta, ToCenter;
	local float LineLengthSq, T, DistXYSq, DistZ;

	LineDelta = End - Start;
	LineLengthSq = LineDelta dot LineDelta;
	if (LineLengthSq < 0.000001)
		return false;

	ToCenter = CylinderCenter - Start;
	T = (ToCenter dot LineDelta) / LineLengthSq;
	T = FClamp(T, 0.0, 1.0);

	ClosestPoint = Start + LineDelta * T;

	DistXYSq =
		(ClosestPoint.X - CylinderCenter.X) * (ClosestPoint.X - CylinderCenter.X) +
		(ClosestPoint.Y - CylinderCenter.Y) * (ClosestPoint.Y - CylinderCenter.Y);
	DistZ = Abs(ClosestPoint.Z - CylinderCenter.Z);

	return (DistXYSq <= Radius * Radius && DistZ <= HalfHeight);
}

function bool IGPlus_PointInsideCylinder(
	vector P,
	vector CylinderCenter,
	float Radius,
	float HalfHeight
) {
	local float DistXYSq;

	DistXYSq =
		(P.X - CylinderCenter.X) * (P.X - CylinderCenter.X) +
		(P.Y - CylinderCenter.Y) * (P.Y - CylinderCenter.Y);
	return (DistXYSq <= Radius * Radius && Abs(P.Z - CylinderCenter.Z) <= HalfHeight);
}

// Client: how far ahead of the server's copy we draw our own projectile, in
// game seconds: the way back from the server, half our ping. Our ping value
// also holds our Adaptive Buffering delay (the server acknowledges a move
// when it runs it). That delay all lies on the way there, so it is taken out.
static function float IGPlus_OwnProjLead(PlayerPawn P) {
	local int Ms;

	Ms = P.PlayerReplicationInfo.Ping;
	if (bbPlayer(P) != none)
		Ms = Max(0, Ms - bbPlayer(P).IGPlus_ABDelayMs);
	return 0.0005 * P.Level.TimeDilation * Ms;
}

function float IGPlus_GetLatencyMs(optional bool bOneWay) {
	local float PingMs;

	if (PingAverage > 0)
		PingMs = float(PingAverage);
	else if (PlayerReplicationInfo != None && PlayerReplicationInfo.Ping > 0)
		PingMs = float(PlayerReplicationInfo.Ping);

	// (One way: plus the other half of the Adaptive Buffering delay, see
	// IGPlus_WeaponImplementationBase.IGPlus_GetLatencyMs.)
	if (bOneWay)
		return FMax(0.0, 0.5 * (PingMs + float(IGPlus_ABDelayMs)));
	return FMax(0.0, PingMs);
}

function float IGPlus_GetOneWayLatencyMs() {
	return IGPlus_GetLatencyMs(true);
}

function bool IGPlus_GetHistoricalMoverLocationByLatency(
	Mover M,
	float SampleLatencyMs,
	out vector HistoricalMoverLoc
) {
	local ST_MoverDummy MD;
	local float TargetTimeStamp;

	if (M == None || zzUTPure == None || SampleLatencyMs <= 0.0)
		return false;

	MD = zzUTPure.FindMoverDummy(M);
	if (MD == None)
		return false;

	TargetTimeStamp = Level.TimeSeconds - 0.001 * SampleLatencyMs * Level.TimeDilation;
	HistoricalMoverLoc = MD.GetHistoricalLocation(TargetTimeStamp);
	return true;
}

function bool IGPlus_ShouldIgnoreOwnBaseHit(
	vector StartTrace,
	vector HitLocation
) {
	local Mover BaseMover;
	local vector HistoricalMoverLoc;
	local bool bHasHistorical;
	local vector ShotDir;
	local float SampleLatencyMs;

	BaseMover = Mover(Base);
	if (BaseMover == None)
		return false;

	// Self-base occlusion should match shooter view time (one-way latency).
	SampleLatencyMs = IGPlus_GetOneWayLatencyMs();
	bHasHistorical = IGPlus_GetHistoricalMoverLocationByLatency(BaseMover, SampleLatencyMs, HistoricalMoverLoc);
	if (!bHasHistorical)
		return false;

	ShotDir = Normal(HitLocation - StartTrace);
	if (ShotDir.Z >= 0.0 &&
		IGPlus_PointInsideCylinder(
			StartTrace,
			HistoricalMoverLoc,
			BaseMover.CollisionRadius,
			BaseMover.CollisionHeight
		)
	) {
		return true;
	}

	// Ignore a self-base hit only if the shot segment does not intersect the
	// mover at the same historical rewind frame.
	return !IGPlus_LineIntersectsCylinder(
		StartTrace,
		HitLocation,
		HistoricalMoverLoc,
		BaseMover.CollisionRadius,
		BaseMover.CollisionHeight
	);
}

function Actor TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace)
{
	local Actor A, Other;
	local bool bSProjBlocks;
	local bool bWeaponShock;
	local WeaponSettingsRepl WS;
	local UTPlusDummy D;
	local ST_ProjectileDummy PD;
	local IGPlus_WeaponImplementationBase WImpBase;
	local int RewindMs;

	WS = GetWeaponSettings();

	bSProjBlocks = true;
	if (WS != none)
		bSProjBlocks = GetWeaponSettings().ShockProjectileBlockBullets;

	bWeaponShock = (Weapon != none && Weapon.IsA('ShockRifle'));

	if (WS != none && WS.bEnablePingCompensation && zzUTPure != None)
	{
		RewindMs = PingAverage;
		WImpBase = IGPlus_GetWeaponImplementationBase();
		if (WImpBase != None)
			RewindMs = int(WImpBase.IGPlus_GetHitscanRewindMs(self));
		zzUTPure.CompensateFor(RewindMs, self, true);
		
		foreach TraceActors( class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {	
			if (A == self) {
				continue;
			}

				if (A.IsA('UTPlusDummy')) {
					D = UTPlusDummy(A);
					if (D != none && D.Actual != none && D.Actual != self) {
						if (D.AdjustHitLocation(HitLocation, EndTrace - StartTrace)) {
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
				} else if ((A == Level) || (Mover(A) != None) || A.bProjTarget || (A.bBlockPlayers && A.bBlockActors)) {
					if (A == Base && Mover(A) != None
						&& (IGPlus_OwnLiftShotShift != vect(0,0,0) || IGPlus_ShouldIgnoreOwnBaseHit(StartTrace, HitLocation)))
						continue;
					if (bSProjBlocks || !A.IsA('ShockProj') || bWeaponShock) {
						Other = A;
						break;
					}
				}
			if (Other != none)
				break;
		}
		zzUTPure.EndCompensation();
	}
	else
	{
		foreach TraceActors(class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {
			if (Pawn(A) != none) {
				if ((A != self) && Pawn(A).AdjustHitLocation(HitLocation, EndTrace - StartTrace))
					Other = A;
			} else if ((A == Level) || (Mover(A) != None) || A.bProjTarget || (A.bBlockPlayers && A.bBlockActors)) {
				if (bSProjBlocks || !A.IsA('ShockProj') || bWeaponShock)
					Other = A;
			}

			if (Other != none)
				break;
		}
	}
	return Other;
}

function Actor TraceShotClient(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace)
{
	local Actor A, Other;
	local bool bSProjBlocks;
	local bool bWeaponShock;
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	bSProjBlocks = true;
	if (WS != none)
		bSProjBlocks = GetWeaponSettings().ShockProjectileBlockBullets;
		
	bWeaponShock = (Weapon != none && Weapon.IsA('ShockRifle'));

	foreach TraceActors(class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {
		if (Pawn(A) != none) {
			if ((A != self) && Pawn(A).AdjustHitLocation(HitLocation, EndTrace - StartTrace))
				Other = A;
		} else if ((A == Level) || (Mover(A) != None) || A.bProjTarget || (A.bBlockPlayers && A.bBlockActors)) {
			if (bSProjBlocks || A.IsA('ShockProj') == false || bWeaponShock)
				Other = A;
		}

		if (Other != none)
			break;
	}
	return Other;
}

simulated function xxEnableCarcasses()
{
	local Carcass C;

	if (!Settings.bShootDead)
		return;

	ForEach AllActors(class'Carcass', C)
		if (C.Physics != PHYS_Falling)
		{
			C.SetCollision(C.Default.bCollideActors, C.Default.bBlockActors, false);
			C.SetCollisionSize(C.Default.CollisionRadius, C.Default.CollisionHeight);
		}
}

simulated function xxDisableCarcasses()
{
	local Carcass C;

	if (!Settings.bShootDead)
		return;

	ForEach AllActors(class'Carcass', C)
		if (C.Physics != PHYS_Falling)
			C.SetCollision(false, false, false);

}

exec function Fire( optional float F )
{
	local bool bRouteClientNN;

	xxEnableCarcasses();
	bRouteClientNN = Role < ROLE_Authority && GameReplicationInfo.GameEndedComments == "" && bNewNet && xxWeaponIsNewNet();
	if (Weapon != none) {
		if (Level.NetMode == NM_Client)
			ClientDebugMessage("Client Fire"@Weapon.Name@ViewRotation);
		else
			ClientDebugMessage("Server Fire"@Weapon.Name@ViewRotation);
	}

	if (bRouteClientNN) {
		if (Weapon != none)
			Weapon.ClientFire(1);
	} else {
		Super.Fire(F);
	}
	xxDisableCarcasses();
}

function xxNN_Fire( float TimeStamp, int ProjIndex, vector ClientLoc, vector ClientVel, rotator ViewRot, optional actor HitActor, optional vector HitLoc, optional vector HitDiff, optional bool bSpecial, optional int ClientFRVI, optional float ClientAccuracy )
{
	local ImpactHammer IH;
	local float TradeTimeMargin;

	if (!bNewNet || !xxWeaponIsNewNet() || Role < ROLE_Authority)
		return;

	if (TimeStamp <= LastFireTimeStamp)
		return;
	LastFireTimeStamp = TimeStamp;
	
	if (TimeStamp + zzUTPure.Settings.FireTimeout < CurrentTimeStamp) {
		IGPlus_EventLog("Rejected Shot"@PlayerReplicationInfo.PlayerName@TimeStamp@CurrentTimeStamp);
		return;
	}

	xxEnableCarcasses();
	zzNN_ProjIndex = ProjIndex;
	zzNN_ClientLoc = ClientLoc;
	zzNN_ClientVel = ClientVel;
	zzNN_ViewRot = ViewRot;
	zzNN_HitActor = HitActor;
	zzNN_HitLoc = HitLoc;
	zzNN_HitDiff = HitDiff;
	zzNN_FRVI = ClientFRVI;
	zzFRVI = ClientFRVI;
	zzNN_Accuracy = ClientAccuracy;
	zzbNN_ReleasedFire = false;
	zzbNN_ReleasedAltFire = false;
	zzbNN_Special = bSpecial;

	IH = ImpactHammer(Weapon);

	if (IH != None)
	{
		if (bSpecial)
			IH.TraceFire(1);
		else
			IH.TraceFire(2);
		IH.PlayFiring();
		IH.GoToState('FireBlast');
	}
	else
	{
		if (zzUTPure.Settings.bRestrictTrading && IsInState('Dying')) {
			TradeTimeMargin = IGPlus_TradeTimeMargin();

			if (RealTimeDead < TradeTimeMargin) {
				IGPlus_EventLog("["$Level.TimeSeconds$"]"@PlayerReplicationInfo.PlayerName@"Traded! TradeTimeMargin="$TradeTimeMargin@"RealTimeDead="$RealTimeDead);
				Super.Fire(1);
			} else {
				IGPlus_EventLog("["$Level.TimeSeconds$"]"@PlayerReplicationInfo.PlayerName@"Rejected Trade! TradeTimeMargin="$TradeTimeMargin@"RealTimeDead="$RealTimeDead);
			}
		} else {
			if (IsInState('Dying'))
				IGPlus_EventLog("["$Level.TimeSeconds$"]"@PlayerReplicationInfo.PlayerName@"Traded! RealTimeDead="$RealTimeDead);
			Super.Fire(1);
		}
	}
	zzNN_HitActor = None;
	zzbNN_Special = false;
	xxDisableCarcasses();
}

exec function AltFire( optional float F )
{
	local bool bRouteClientNN;

	xxEnableCarcasses();
	bRouteClientNN = Role < ROLE_Authority && GameReplicationInfo.GameEndedComments == "" && bNewNet && xxWeaponIsNewNet(true);

	if (Weapon != none) {
		if (Level.NetMode == NM_Client)
			ClientDebugMessage("Client AltFire"@Weapon.Name@ViewRotation);
		else
			ClientDebugMessage("Server AltFire"@Weapon.Name@ViewRotation);
	}

	if (bRouteClientNN)
	{
		if (Weapon != none)
			Weapon.ClientAltFire(1);
	}
	else
	{
		Super.AltFire(F);
	}
	xxDisableCarcasses();
}

function xxNN_AltFire( float TimeStamp, int ProjIndex, vector ClientLoc, vector ClientVel, rotator ViewRot, optional actor HitActor, optional vector HitLoc, optional vector HitDiff, optional bool bSpecial, optional int ClientFRVI, optional float ClientAccuracy )
{
	if (!bNewNet || !xxWeaponIsNewNet(true) || Role < ROLE_Authority)
		return;

	if (TimeStamp <= LastAltFireTimeStamp)
		return;
	LastAltFireTimeStamp = TimeStamp;

	if (TimeStamp + zzUTPure.Settings.FireTimeout < CurrentTimeStamp) {
		IGPlus_EventLog("Rejected Shot"@PlayerReplicationInfo.PlayerName@TimeStamp@CurrentTimeStamp);
		return;
	}

	xxEnableCarcasses();
	zzNN_ProjIndex = ProjIndex;
	zzNN_ClientLoc = ClientLoc;
	zzNN_ClientVel = ClientVel;
	zzNN_ViewRot = ViewRot;
	zzNN_HitActor = HitActor;
	zzNN_HitLoc = HitLoc;
	zzNN_HitDiff = HitDiff;
	zzNN_FRVI = ClientFRVI;
	zzFRVI = ClientFRVI;
	zzNN_Accuracy = ClientAccuracy;
	zzbNN_ReleasedFire = false;
	zzbNN_ReleasedAltFire = false;
	zzbNN_Special = bSpecial;

	Super.AltFire(1);

	zzNN_HitActor = None;
	zzbNN_Special = false;
	xxDisableCarcasses();
}

function xxNN_ReleaseFire( int ProjIndex, vector ClientLoc, vector ClientVel, rotator ViewRot, optional int ClientFRVI )
{
	if (!bNewNet || !xxWeaponIsNewNet() || Role < ROLE_Authority)
		return;

	zzNN_ProjIndex = ProjIndex;
	zzNN_ClientLoc = ClientLoc;
	zzNN_ClientVel = ClientVel;
	zzNN_ViewRot = ViewRot;
	zzNN_FRVI = ClientFRVI;
	zzFRVI = ClientFRVI;
	zzbNN_ReleasedFire = true;
}

function xxNN_ReleaseAltFire( int ProjIndex, vector ClientLoc, vector ClientVel, rotator ViewRot, optional int ClientFRVI )
{
	if (!bNewNet || !xxWeaponIsNewNet(true) || Role < ROLE_Authority)
		return;

	zzNN_ProjIndex = ProjIndex;
	zzNN_ClientLoc = ClientLoc;
	zzNN_ClientVel = ClientVel;
	zzNN_ViewRot = ViewRot;
	zzNN_FRVI = ClientFRVI;
	zzFRVI = ClientFRVI;
	zzbNN_ReleasedAltFire = true;
}

simulated function int xxNN_AddProj(Projectile Proj)
{
	local int ProjIndex;

	if (Proj == None || zzNN_ProjIndex < 0)
		return -1;

	zzNN_Projectiles[zzNN_ProjIndex] = Proj;

	ProjIndex = zzNN_ProjIndex;
	zzNN_ProjIndex++;
	if (zzNN_ProjIndex >= NN_ProjLength)
		zzNN_ProjIndex = 0;

	return ProjIndex;
}

simulated function xxNN_RemoveProj(int ProjIndex, optional vector HitLocation, optional vector HitNormal, optional bool bCombo)
{
	if (zzNN_Projectiles[ProjIndex] == None || xxGarbageLocation(zzNN_Projectiles[ProjIndex]))
		return;

	zzNN_ProjLocations[ProjIndex] = zzNN_Projectiles[ProjIndex].Location;
	zzNN_Projectiles[ProjIndex] = None;

	if (Level.NetMode == NM_Client)
		xxNN_ProjExplode(ProjIndex, HitLocation, HitNormal, bCombo);
	else
		xxNN_ClientProjExplode(ProjIndex, HitLocation, HitNormal, bCombo);
}

simulated function xxNN_ProjExplode( int ProjIndex, optional vector HitLocation, optional vector HitNormal, optional bool bCombo )
{
	local Projectile Proj;

	if (Level.NetMode == NM_Client)
		return;

	xxEnableCarcasses();
	if (ProjIndex < 0)
	{
		ProjIndex = -1*(ProjIndex + 1);
		Proj = zzNN_Projectiles[ProjIndex];
		if (Proj != None && !xxGarbageLocation(Proj))
		{
			zzNN_ProjLocations[ProjIndex] = Proj.Location;
			Proj.Destroy();
		}
	}
	else
	{
		Proj = zzNN_Projectiles[ProjIndex];
		if (Proj != None && !xxGarbageLocation(Proj))
		{
			zzNN_ProjLocations[ProjIndex] = Proj.Location;
			if (bCombo && Proj.IsA('ShockProj'))
			{
				if (IsInState('Dying'))
					ShockProj(Proj).SuperExplosion();
			}
			else
			{
				Proj.Explode(HitLocation, HitNormal);
			}
		}
	}
	xxDisableCarcasses();
}

simulated function xxNN_ClientProjExplode( int ProjIndex, optional vector HitLocation, optional vector HitNormal, optional bool bCombo )
{
	local Projectile Proj;

	if (Level.NetMode != NM_Client)
		return;

	xxEnableCarcasses();
	if (ProjIndex < 0)
	{
		ProjIndex = -1*(ProjIndex + 1);
		Proj = zzNN_Projectiles[ProjIndex];
		if (Proj != None && !xxGarbageLocation(Proj))
		{
			zzNN_ProjLocations[ProjIndex] = Proj.Location;
			Proj.Destroy();
		}
	}
	else
	{
		Proj = zzNN_Projectiles[ProjIndex];
		if (Proj != None && !xxGarbageLocation(Proj))
		{
			zzNN_ProjLocations[ProjIndex] = Proj.Location;
			if (bCombo && Proj.IsA('ShockProj'))
			{
				if (IsInState('Dying'))
					ShockProj(Proj).SuperExplosion();
			}
			else
			{
				Proj.Explode(HitLocation, HitNormal);
			}
		}
	}
	xxDisableCarcasses();
}

// Think about what you're doing.  Look at the bigger picture of it all, if you're able to.  This is a 15+ year old video game.
// Is this really the legacy you want to leave behind?  You'll never amount to anything if you keep this up.
// Seriously.  Do something good with your time.  Build something that improves lives.
// I understand that you are bitter, but you'll feel better if you listen to me.
// Doing good things will make you feel good.

simulated function xxSetDefaultWeapon(name W)
{
	zzDefaultWeapon = W;
}

simulated function xxSetTimes(int RemainingTime, int ElapsedTime)
{
	if (GameReplicationInfo == None)
		return;
	GameReplicationInfo.RemainingTime = RemainingTime;
	GameReplicationInfo.ElapsedTime = ElapsedTime;
}

function PlayerMove(float Delta) {
	ClientMessage("Help Im Stuck In Global Function");
}

function PlayBackInput(IGPlus_SavedInput Old, IGPlus_SavedInput I) {
	local float OldBaseX, OldBaseY, OldBaseZ;
	local float OldMouseX, OldMouseY;
	local float OldForward, OldStrafe, OldUp, OldLookUp, OldTurn;
	local byte OldRun, OldDuck;
	local bool bDetDispatch;
	local bool bBlockLegacyFire;
	local bool bDetCarryFire;
	local bool bInputFireHeld;
	local bool bInputAltHeld;
	local bool bInputForceFire;
	local bool bInputForceAltFire;
	local Weapon DetWeapon;

	OldBaseX = aBaseX;
	OldBaseY = aBaseY;
	OldBaseZ = aBaseZ;
	OldMouseX = aMouseX;
	OldMouseY = aMouseY;
	OldForward = aForward;
	OldStrafe = aStrafe;
	OldUp = aUp;
	OldLookUp = aLookUp;
	OldTurn = aTurn;
	OldRun = bRun;
	OldDuck = bDuck;

	aBaseX = 0;
	aBaseY = 0;
	aBaseZ = 0;
	aMouseX = 0;
	aMouseY = 0;
	aForward = 0;
	aStrafe = 0;
	aUp = 0;
	aLookUp = 0;
	aTurn = 0;

	bWasForward    = I.bForw;
	bWasBack       = I.bBack;
	bWasLeft       = I.bLeft;
	bWasRight      = I.bRigh;
	bEdgeForward   = Old.bForw != bWasForward;
	bEdgeBack      = Old.bBack != bWasBack;
	bEdgeLeft      = Old.bLeft != bWasLeft;
	bEdgeRight     = Old.bRigh != bWasRight;

	if (I.bLive) {
		if (I.bForw) aForward += 6000.0;
		if (I.bBack) aForward -= 6000.0;
		if (I.bLeft) aStrafe  += 6000.0;
		if (I.bRigh) aStrafe  -= 6000.0;
		if (I.bDuck) aUp      -= 6000.0;
		if (I.bJump) aUp      += 6000.0;

		if (I.bWalk) bRun = 1; else bRun = 0;
		if (I.bDuck) bDuck = 1; else bDuck = 0;

		bPressedJump = I.bJump && (I.bJump != Old.bJump);
		bPressedDodge = I.bDodg && (I.bDodg != Old.bDodg);
	}

	ViewRotation = I.SavedViewRotation;
	bInputFireHeld = I.bFire;
	bInputAltHeld = I.bAFir;
	bInputForceFire = I.bForceFireTap;
	bInputForceAltFire = I.bForceAltTap;

	DetWeapon = IGPlus_DetResolveBoundWeapon(I.DetWeaponIndex, RemoteRole == ROLE_AutonomousProxy);
	bDetDispatch = DetWeapon != none;
	bDetCarryFire = IGPlus_DetCarriesFire(DetWeapon);
	bBlockLegacyFire = bDetCarryFire == false && (bDetDispatch || IGPlus_IsDetActiveWeapon(Weapon)
		|| IGPlus_DetStaleBindingBlocks(I.DetWeaponIndex));

	if (RemoteRole == ROLE_AutonomousProxy) {

		if (zzUTPure.Settings.bEnablePingCompensatedSpawn) {
			if (bHidden && I.bLive && (IsInState('PlayerWalking') || IsInState('PlayerSwimming'))) {
				bClientDead = false;
				bHidden = false;
				SetCollision(true, true, true);
				IGPlus_SendRespawnNoficiation();
			}
		}

		if (Old.bLive == false) {
			bDodging = false;
			DodgeDir = DODGE_None;
			DodgeClickTimer = DodgeClickTime;
		}

		IGPlus_LastFireEndHeld = I.bFire;
		IGPlus_LastAltEndHeld = I.bAFir;

		IGPlus_DetTrackPendingWeapon(I.TimeStamp);

		if (bDetDispatch) {
			IGPlus_DetProcessStep(
				DetWeapon,
				I.TimeStamp,
				I.SavedViewRotation,
				Location,
				bInputFireHeld,
				bInputAltHeld,
				bInputForceFire,
				bInputForceAltFire,
				true,
				I.bDetReady && IGPlus_DetFireClockOK(),
				I.DetChargeData,
				IGPlus_IsDetWeaponIndexEightball(I.DetWeaponIndex),
				I.bDetEightballInstant
			);
			// Keep legacy fire latches clear; the step path is authoritative.
			if (bDetCarryFire == false) {
				bFire = 0;
				bAltFire = 0;
			}
		}
		if (bDetDispatch == false || bDetCarryFire) {
					// handle firing and alt-firing on server
					if (bInputFireHeld) {
						if (bFire == 0) {
							if (bBlockLegacyFire) {
								bFire = 0;
							} else if (I.bLive && bInputForceFire && Weapon != none) {
								Weapon.ForceFire();
							} else {
								Fire(0);
							}
						}
					if (!bBlockLegacyFire)
						bFire = 1;
				} else {
					bFire = 0;
				}

					if (bInputAltHeld) {
						if (bAltFire == 0) {
							if (bBlockLegacyFire) {
								bAltFire = 0;
							} else if (I.bLive && bInputForceAltFire && Weapon != none) {
								Weapon.ForceAltFire();
							} else {
								AltFire(0);
							}
					}
					if (!bBlockLegacyFire)
						bAltFire = 1;
				} else {
					bAltFire = 0;
				}
		}
	} else if (RemoteRole == ROLE_Authority) {
		// this assumes that you always replay up until the present, otherwise
		// youd have to save and restore these values
		SetRotation(Old.SavedRotation);
		bDodging = Old.SavedDodging;
		DodgeDir = Old.SavedDodgeDir;
		DodgeClickTimer = Old.SavedDodgeClickTimer;
		LastTimeForward = Old.SavedLastTimeForward;
		LastTimeBack = Old.SavedLastTimeBack;
		LastTimeLeft = Old.SavedLastTimeLeft;
		LastTimeRight = Old.SavedLastTimeRight;
	}

	IGPlus_TPFix_LastTouched = none;
	HandleWalking();
	PlayerMove(I.Delta);
	AutonomousPhysics(I.Delta);
	CorrectTeleporterVelocity();

	I.SavedLocation = Location;
	I.SavedVelocity = Velocity;

	aBaseX = OldBaseX;
	aBaseY = OldBaseY;
	aBaseZ = OldBaseZ;
	aMouseX = OldMouseX;
	aMouseY = OldMouseY;
	aForward = OldForward;
	aStrafe = OldStrafe;
	aUp = OldUp;
	aLookUp = OldLookUp;
	aTurn = OldTurn;
	bRun = OldRun;
	bDuck = OldDuck;
}

function ReplicateMove
(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
)
{
	xxServerCheater("RM");
}

function IGPlus_SavedMove xxGetFreeMove() {
	local IGPlus_SavedMove s;

	if ( FreeMoves == None )
		return Spawn(class'IGPlus_SavedMove');
	else
	{
		s = IGPlus_SavedMove(FreeMoves);
		FreeMoves = FreeMoves.NextMove;
		s.NextMove = None;
		s.Clear2();
		return s;
	}
}

	// Det Weapon Dispatch — add one cast block per weapon to each function.

		// Encode which Det weapon was ready for deterministic dispatch.
	simulated function int IGPlus_GetDetWeaponIndex(Weapon W) {
		if (W == none)
			return IGPLUS_DetWEAPON_None;
		if (ST_ShockRifle(W) != none)
			return IGPLUS_DetWEAPON_ShockRifle;
		if (ST_ripper(W) != none)
			return IGPLUS_DetWEAPON_Ripper;
		if (ST_UT_FlakCannon(W) != none)
			return IGPLUS_DetWEAPON_FlakCannon;
		if (ST_ut_biorifle(W) != none)
			return IGPLUS_DetWEAPON_BioRifle;
		if (ST_UT_Eightball(W) != none)
			return IGPLUS_DetWEAPON_Eightball;
		if (ST_SniperRifle(W) != none)
			return IGPLUS_DetWEAPON_SniperRifle;
		if (ST_SuperShockRifle(W) != none)
			return IGPLUS_DetWEAPON_SuperShockRifle;
		return IGPLUS_DetWEAPON_None;
	}

// Return charge/load state for current weapon (4 bits, 0-15).
// Eightball: ClientRocketsLoaded (1-6).
// BioRifle: quantized ChargeSize (0-8 -> 0.0-4.1 in ~0.5 steps).
simulated function int IGPlus_GetDetChargeData() {
	local ST_UT_Eightball EB;
	local ST_ut_biorifle BR;
	EB = ST_UT_Eightball(Weapon);
	if (EB != none)
		return EB.DetGetChargeDataForMove();
	BR = ST_ut_biorifle(Weapon);
	if (BR != none)
		return BR.DetCachedChargeData;
	return 0;
}

	simulated function bool IGPlus_IsEightballInstantMode(optional Weapon W) {
		local ST_UT_Eightball EB;
		local Weapon UseW;

		UseW = W;
		if (UseW == none)
			UseW = Weapon;
		EB = ST_UT_Eightball(UseW);
		if (EB == none)
			return false;
		if (EB.bAlwaysInstant)
			return true;
		return bInstantRocket;
	}

	simulated function bool IGPlus_IsDetWeaponIndexEightball(int Index) {
		return Index == IGPLUS_DetWEAPON_Eightball;
	}

function IGPlus_ClientEightballAmmoRefund(ST_UT_Eightball Eightball, int ServerAmmo) {
	if (Role == ROLE_Authority || Eightball == none || Eightball.Owner != self)
		return;
	Eightball.DetApplyClientAmmoRefund(ServerAmmo);
}

	// Decode Det weapon index back to the actual weapon in inventory.
	simulated function Weapon IGPlus_DetWeaponByIndex(int Index) {
		local Inventory Inv;
		if (Index <= IGPLUS_DetWEAPON_None)
			return none;
		for (Inv = Inventory; Inv != none; Inv = Inv.Inventory) {
			if (Index == IGPLUS_DetWEAPON_ShockRifle && ST_ShockRifle(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_DetWEAPON_Ripper && ST_ripper(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_DetWEAPON_FlakCannon && ST_UT_FlakCannon(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_DetWEAPON_BioRifle && ST_ut_biorifle(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_DetWEAPON_Eightball && ST_UT_Eightball(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_DetWEAPON_SniperRifle && ST_SniperRifle(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_DetWEAPON_SuperShockRifle && ST_SuperShockRifle(Inv) != none)
				return Weapon(Inv);
		}
		return none;
	}

// The move's binding must be the equipped weapon, the pending weapon, or the
// grace weapon just switched away from. This is the hard trust boundary.
function bool IGPlus_DetServerBindingValid(Weapon W) {
	if (W == none)
		return false;
	if (W.Owner != self)
		return false;
	if (W == Weapon || W == PendingWeapon)
		return true;
	return W == IGPlus_DetPrevWeapon && CurrentTimeStamp <= IGPlus_DetPrevWeaponUntilTS;
}

// Whether a weapon of this kind (IGPLUS_DetWEAPON_) runs deterministic with
// these settings: the rifle, the shock rifle and the sniper by the main ping
// compensation setting, the ripper, flak cannon, bio rifle and rocket
// launcher each by its own, as their IsPingCompEnabled says.
static final function bool IGPlus_DetKindRuns(int Index, bool bMain, bool bRipper, bool bFlak, bool bBio, bool bRocket) {
	if (Index == IGPLUS_DetWEAPON_None)
		return false;
	if (Index == IGPLUS_DetWEAPON_Ripper)
		return bRipper;
	if (Index == IGPLUS_DetWEAPON_FlakCannon)
		return bFlak;
	if (Index == IGPLUS_DetWEAPON_BioRifle)
		return bBio;
	if (Index == IGPLUS_DetWEAPON_Eightball)
		return bRocket;
	return bMain;
}

// Server: a move names the kind of weapon its fire input was for. When that
// kind runs deterministic the input must not reach the classic fire path of
// whatever weapon is up now. This used to ask the main setting alone, so with
// it on and a projectile weapon's own setting off the weapon was not
// deterministic, its classic fire path was blocked all the same, and the
// server never fired it while the client showed every shot.
function bool IGPlus_DetKindEnabled(int Index) {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	if (WS == none)
		return false;
	return IGPlus_DetKindRuns(Index, WS.bEnablePingCompensation, WS.RipperCompensatePing,
		WS.FlakCompensatePing, WS.BioCompensatePing, WS.RocketCompensatePing);
}

// Server: a move names a deterministic weapon and its binding did not resolve,
// so we hold another weapon by now. May that move's fire input reach the
// classic fire path of the weapon we hold?
// With Predicted Switching the client can be ahead of us: its input is for a
// weapon we do not hold yet and must not fire the one we still have.
// Without it the client only follows our switch, a round trip later. Until
// then its moves name the old weapon, and its held button is for the weapon
// we have, as on master. This used to block those moves too, so a
// translocator switched to with fire held threw one round trip late.
// The hammer stays blocked: it fires on the release, and a hold let go
// before the client's own hammer is up must not blast.
static final function bool IGPlus_DetStaleBlockRule(bool bPredictedSwitching, bool bHammer) {
	return bPredictedSwitching || bHammer;
}

function bool IGPlus_DetStaleBindingBlocks(int Index) {
	if (IGPlus_DetKindEnabled(Index) == false)
		return false;
	return IGPlus_DetStaleBlockRule(IGPlus_PredictedSwitching, ImpactHammer(Weapon) != none);
}

// Server: this move steps the weapon we just switched away from (the grace
// of IGPlus_DetServerBindingValid, about one round trip), and the weapon in
// hand is of the classic kind. Its buttons go to the weapon in hand as well,
// by the rule above: the step alone used to keep them from it, so the new
// weapon got no fire input until the client's own switch had come back.
function bool IGPlus_DetCarriesFire(Weapon StepWeapon) {
	if (StepWeapon == none || StepWeapon == Weapon || StepWeapon != IGPlus_DetPrevWeapon)
		return false;
	if (Weapon == none || IGPlus_IsDetActiveWeapon(Weapon))
		return false;
	if (ST_Translocator(Weapon) != none && ST_Translocator(Weapon).IGPlus_IsDetMode())
		return false;
	return IGPlus_DetStaleBlockRule(IGPlus_PredictedSwitching, ImpactHammer(Weapon) != none) == false;
}

// Binding, then activation; none if any gate fails.
simulated function Weapon IGPlus_DetResolveBoundWeapon(int DetIndex, bool bServerContext) {
	local Weapon W;

	// None is also the Hammer's binding. Never reinterpret its held buttons
	// as input for whatever deterministic weapon the server still has up.
	W = IGPlus_DetWeaponByIndex(DetIndex);
	if (bServerContext && !IGPlus_DetServerBindingValid(W))
		W = none;
	if (!IGPlus_IsDetActiveWeapon(W))
		W = none;
	return W;
}

// The player has committed to switching away from W (or W is going down).
simulated function bool IGPlus_DetSwitchAwayFrom(Weapon W) {
	if (!IGPlus_IsDetActiveWeapon(W))
		return false;
	if (IGPlus_IsDeterministicSwitchGuardActive())
		return true;
	if (ClientPending != none && ClientPending != W)
		return true;
	if (IGPlus_DetClientSwitchPending != none && IGPlus_DetClientSwitchPending != W)
		return true;
	if (Weapon != W)
		return true;
	if (PendingWeapon != none && PendingWeapon != W)
		return true;
	if (W.bChangeWeapon)
		return true;
	return W.IsInState('DownWeapon') || W.IsInState('ClientDown');
}

// Conservative fallback gate for paths without a replicated entry gate:
// the pending-weapon pre-equip window and cancel re-arm.
simulated function float IGPlus_DetEntryGateSeconds() {
	if (IGPlus_UseFastWeaponSwitch)
		return 0.12;
	return 0.25;
}

// Anim playback speed is FMin(100, Default/Config), so the effective
// duration is FMax(Config, Default/100); Config <= 0 plays at the speed cap.
static final function float IGPlus_DetEffectiveAnimTime(float ConfigTime, float DefaultTime) {
	if (ConfigTime <= 0.0)
		return DefaultTime * 0.01;
	return FMax(ConfigTime, DefaultTime * 0.01);
}

// How long a weapon's Select animation takes. IG+ plays it with no tween at
// FMin(100, Default/Config), and Default is the sequence's frame count over
// its rate. An animation played once ends on its last frame, one frame short
// of that, so the weapon is up after Config * (Frames - 1) / Frames. Stock and
// IG+ without ping compensation fire a held button at that moment (the Active
// state's FinishAnim), measured on a test rig: 0.565 s for a shock rifle with
// ShockSelectTime 0.6, not 0.6.
static final function float IGPlus_DetSelectAnimTime(float ConfigTime, float DefaultTime, int Frames) {
	return IGPlus_DetEffectiveAnimTime(ConfigTime, DefaultTime) * float(Frames - 1) / float(Frames);
}

// The flak cannon's Loading animation after its select (PlayPostSelect): a
// 0.05 tween and 14 of its 15 frames at 30 a second, at FlakPostSelectAnimSpeed.
// The cannon is up only once this has played too, also with FlakPostSelectTime 0
// (the tween is not sped up).
static final function float IGPlus_DetFlakPostSelectTime(float AnimSpeed) {
	return 0.05 + 14.0 / (30.0 * FMax(AnimSpeed, 0.01));
}

// NextIG and NextSA have one weapon, like NewNetIG and NewNetSA, and their
// rifle comes up after a spawn as the NewNet rifles do, with no setting: the
// Select animation at 1.35 (NN_WeaponFunctions.PlaySelect). NewNet passes a
// 0.05 tween with it, which the engine drops on a weapon that has played no
// animation yet (execPlayAnim), and a weapon from a spawn has played none. So
// the select has no tween here. The Down animation has its 0.05. The NewNet
// rifles also add the player's ping in seconds to the speed. That part is
// left out here: client and server would not get the same number, and the
// gate has to be the same on both.
static final function float IGPlus_DetNewNetAnimTime(int Frames, float Rate, float Tween) {
	return Tween + float(Frames - 1) / (Rate * 1.35);
}

// The NextIG rifle. ST_Mutator also puts ST_SuperShockRifle in place of a
// stock instagib rifle in a game with other weapons: there it switches like
// them, by the shock settings.
simulated function bool IGPlus_NewNetRifleTiming(Weapon W) {
	if (SA_SniperRifle(W) != none)
		return true;
	return ST_SuperShockRifle(W) != none && IGPlus_WeaponSettingsMode == 1;
}

// Select duration of a v4 weapon from replicated config — the entry gate is
// computed once server-side from this and replicated verbatim, so client and
// server hold the same timestamp instead of re-deriving it from each side's
// own anim state machine. It is the time the weapon's own select animation
// takes (frame counts of the first-person meshes' Select sequences), so the
// gate opens when the gun on screen is up.
simulated function float IGPlus_DetSelectTimeFor(Weapon W) {
	local WeaponSettingsRepl WS;

	// Rifle2m's and sshockm's Select: 17 frames at 28 a second, 15 at 30.
	if (IGPlus_NewNetRifleTiming(W)) {
		if (SA_SniperRifle(W) != none)
			return IGPlus_DetNewNetAnimTime(17, 28.0, 0.0);
		return IGPlus_DetNewNetAnimTime(15, 30.0, 0.0);
	}
	WS = GetWeaponSettings();
	if (WS == none)
		return IGPlus_DetEntryGateSeconds();
	if (ST_ShockRifle(W) != none)
		return IGPlus_DetSelectAnimTime(WS.ShockSelectTime, WS.default.ShockSelectTime, 15);
	if (ST_ripper(W) != none)
		return IGPlus_DetSelectAnimTime(WS.RipperSelectTime, WS.default.RipperSelectTime, 30);
	if (ST_UT_FlakCannon(W) != none)
		return IGPlus_DetSelectAnimTime(WS.FlakSelectTime, WS.default.FlakSelectTime, 30)
			+ IGPlus_DetFlakPostSelectTime(WS.FlakPostSelectAnimSpeed());
	if (ST_ut_biorifle(W) != none)
		return IGPlus_DetSelectAnimTime(WS.BioSelectTime, WS.default.BioSelectTime, 22);
	if (ST_UT_Eightball(W) != none)
		return IGPlus_DetSelectAnimTime(WS.EightballSelectTime, WS.default.EightballSelectTime, 20);
	if (ST_SniperRifle(W) != none)
		return IGPlus_DetSelectAnimTime(WS.SniperSelectTime, WS.default.SniperSelectTime, 17);
	// The instagib rifle among other weapons plays its select and down anims
	// by the shock settings.
	if (ST_SuperShockRifle(W) != none)
		return IGPlus_DetSelectAnimTime(WS.ShockSelectTime, WS.default.ShockSelectTime, 15);
	return IGPlus_DetEntryGateSeconds();
}

// Server -> client: the authoritative bring-up entry gate for the weapon just
// equipped. Reliable and ordered after the switch RPCs that precede it.
function xxClientDetEntryGate(float GateTS, optional Weapon W) {
	IGPlus_DetClientEntryGateTS = FMax(IGPlus_DetClientEntryGateTS, GateTS);
	// A late tag for the weapon we already switched away from must not
	// overwrite the tag our predicted switch set.
	// W arrives as none when the server equipped a weapon this client has no
	// copy of yet (a pickup spawned this tick). Clear the tag then, as after a
	// respawn: keeping the previous weapon's tag blocks the new one for good.
	if (!(IGPlus_PSActive && W != IGPlus_PSTarget))
		IGPlus_DetClientGateWeapon = W;
}

function IGPlus_DetFinalizeExpiredPrevWeapon(optional bool bForce) {
	local ST_UT_Eightball Eightball;

	if (IGPlus_DetPrevWeapon == none)
		return;
	if (!bForce && CurrentTimeStamp <= IGPlus_DetPrevWeaponUntilTS)
		return;

	Eightball = ST_UT_Eightball(IGPlus_DetPrevWeapon);
	if (Eightball != none)
		Eightball.DetFinalizeSwitchSettlement();
	IGPlus_DetPrevWeapon = none;
	IGPlus_DetPrevWeaponUntilTS = 0.0;
	IGPlus_DetPrevWeaponStepTS = 0.0;
}

// Drop switch-related v4 trust state (called on death and respawn).
// How long after dying (server, real time) a shot may still count: the dead
// player fired first if he is late by no more than his one-way delay is
// longer than his killer's, plus an allowance for ping uncertainty.
function float IGPlus_TradeTimeMargin() {
	if (bbPlayer(LastKiller) != none)
		return FMin(
			zzUTPure.Settings.MaxTradeTimeMargin,
			((AverageServerDeltaTime + TimeBetweenNetUpdates)/Level.TimeDilation +
			0.0005 * PlayerReplicationInfo.Ping * zzUTPure.Settings.TradePingMargin +
			// (one-way delays: each with the other half of its Adaptive Buffering delay)
			0.0005 * (PlayerReplicationInfo.Ping + IGPlus_ABDelayMs
				- bbPlayer(LastKiller).PlayerReplicationInfo.Ping - bbPlayer(LastKiller).IGPlus_ABDelayMs))
		);
	return zzUTPure.Settings.MaxTradeTimeMargin;
}

// Dead (state Dying): does this move's deterministic shot still count as a
// trade (bEnableAllWeaponTrades)? The same rule as the NewNet weapons; the
// weapons stay ours until DiscardInventory at twice MaxTradeTimeMargin.
function bool IGPlus_DetTradeAllowed() {
	if (IGPlus_DetTradesEnabled() == false || IGPlus_bDetTradeClosed)
		return false;
	if (zzUTPure.Settings.bRestrictTrading)
		return RealTimeDead < IGPlus_TradeTimeMargin();
	return RealTimeDead <= 2 * zzUTPure.Settings.MaxTradeTimeMargin;
}

// Dead, with fire input on a move: what IGPlus_DetTradeAllowed decided, in
// the server log (like the NewNet weapons' trades) and our debug lines.
function IGPlus_DetTradeLog(string What) {
	local string S;

	S = What@"(all-weapon)"@Weapon@"TradeTimeMargin="$IGPlus_TradeTimeMargin()@"RealTimeDead="$RealTimeDead
		@"ping="$PlayerReplicationInfo.Ping;
	if (bbPlayer(LastKiller) != none)
		S = S@"killer="$LastKiller.PlayerReplicationInfo.PlayerName@"killerPing="$LastKiller.PlayerReplicationInfo.Ping;
	IGPlus_EventLog("["$Level.TimeSeconds$"]"@PlayerReplicationInfo.PlayerName@S);
	ClientDebugMessage("Trade (server):"@S);
}

// Dead: the trade window is over. Drop what our deterministic weapons were
// in the middle of (a rocket load), or a release after it would still fire.
function IGPlus_DetCloseTradeWindow() {
	if (IGPlus_bDetTradeClosed)
		return;
	IGPlus_bDetTradeClosed = true;
	IGPlus_DetResetWeaponStates();
}

function IGPlus_DetResetWeaponStates() {
	local Inventory Item;

	for (Item = Inventory; Item != none; Item = Item.Inventory) {
		if (ST_ShockRifle(Item) != none)
			ST_ShockRifle(Item).DetResetDeterministicState();
		else if (ST_ripper(Item) != none)
			ST_ripper(Item).DetResetDeterministicState();
		else if (ST_UT_FlakCannon(Item) != none)
			ST_UT_FlakCannon(Item).DetResetDeterministicState();
		else if (ST_ut_biorifle(Item) != none)
			ST_ut_biorifle(Item).DetResetDeterministicState();
		else if (ST_UT_Eightball(Item) != none)
			ST_UT_Eightball(Item).DetResetDeterministicState();
		else if (ST_SniperRifle(Item) != none)
			ST_SniperRifle(Item).DetResetDeterministicState();
		else if (ST_SuperShockRifle(Item) != none)
			ST_SuperShockRifle(Item).DetResetDeterministicState();
	}
}

// bKeepWeapons (dying with bEnableAllWeaponTrades): the weapons keep what
// they were doing for a trade; IGPlus_DetCloseTradeWindow drops it later.
function IGPlus_DetClearSwitchTrustState(optional bool bKeepWeapons) {
	IGPlus_DetPrevWeapon = none;
	IGPlus_DetPrevWeaponUntilTS = 0;
	IGPlus_DetPrevWeaponStepTS = 0;
	IGPlus_DetWeaponGateTS = 0;
	IGPlus_DetPendingSeen = none;
	IGPlus_DetPendingSeenTS = 0;
	IGPlus_LastFireEndHeld = false;
	IGPlus_LastAltEndHeld = false;
	IGPlus_DetPendingFireTapTS = 0.0;
	IGPlus_DetPendingFireTapWeapon = none;
	IGPlus_DetAutoSwitchPending = none;
	IGPlus_PSActive = false;
	IGPlus_DetLastShotTS = 0.0;
	IGPlus_DetHolsterHoldUntilTS = 0.0;

	if (bKeepWeapons == false)
		IGPlus_DetResetWeaponStates();
}

// Observe PendingWeapon transitions from move processing.
function IGPlus_DetTrackPendingWeapon(float NowTS) {
	local ST_UT_Eightball PendingEightball;

	if (PendingWeapon == IGPlus_DetPendingSeen)
		return;
	PendingEightball = ST_UT_Eightball(IGPlus_DetPendingSeen);
	if (PendingEightball != none
		&& PendingWeapon != PendingEightball
		&& !(PendingWeapon == none && Weapon == PendingEightball))
		PendingEightball.DetClearPendingAltInput();
	// Canceling a switch re-arms the bring-up; toggling is never free.
	if (IGPlus_DetPendingSeen != none && PendingWeapon == none) {
		IGPlus_DetWeaponGateTS = FMax(IGPlus_DetWeaponGateTS, NowTS + IGPlus_DetEntryGateSeconds());
		xxClientDetEntryGate(IGPlus_DetWeaponGateTS, Weapon);
		// Retract a deferred switch the client was already told about
		// (GetWeapon on an empty weapon, Next/PrevWeapon with no candidate),
		// or the client stays holstered while the server keeps this weapon
		// and its load cycle live.
		xxClientSwitchPending(none, 0.0);
	}
	IGPlus_DetPendingSeen = PendingWeapon;
	if (PendingWeapon != none && PendingWeapon != Weapon) {
		IGPlus_DetPendingSeenTS = NowTS;
		IGPlus_DetInFlightSlack = IGPlus_DetComputeInFlightSlack();
		// The client only hears of a switch from ClientPutDown, which waits for
		// the holster. A weapon that latches the request instead (Eightball in
		// FireRockets, a deferred hold) would keep predicting shots the server
		// no longer accepts, so tell it now.
		if (IGPlus_IsDetActiveWeapon(Weapon) && !Weapon.IsInState('DownWeapon')
			&& RemoteRole == ROLE_AutonomousProxy)
			xxClientSwitchPending(PendingWeapon, 0.0);
	}
}

// Det refire and windows run on move timestamps, i.e. the client's clock.
// Bound how far that clock may run ahead of the server's. Offset = move
// timestamp - server time. Network delay only ever lowers it, so the baseline
// is the best (highest) offset seen, allowed to rise by 1% of elapsed server
// time (clock drift). A fast clock (speed hack) pulls ahead of it steadily;
// lag spikes and bunched catch-up never do. The first 2 s only learn the
// baseline, so a hitch while connecting can't pin it low. While over the cap a
// step counts as unhinted: no fresh shots, committed cycles still resolve.
static final function float IGPlus_DetNextClockBaseline(float Baseline, float Offset, float ServerDelta, bool bLearning) {
	if (bLearning)
		return FMax(Baseline, Offset);
	if (Offset > Baseline)
		return FMin(Offset, Baseline + 0.01 * ServerDelta);
	return Baseline;
}

function IGPlus_DetUpdateFireClockLead(float MoveTimeStamp, float ServerDelta) {
	local float Offset;

	Offset = MoveTimeStamp - Level.TimeSeconds;
	if (IGPlus_DetClockLearnUntil <= 0.0) {
		IGPlus_DetClockBaseline = Offset;
		IGPlus_DetClockLearnUntil = Level.TimeSeconds + 2.0;
	} else {
		IGPlus_DetClockBaseline = IGPlus_DetNextClockBaseline(IGPlus_DetClockBaseline, Offset,
			FMax(0.0, ServerDelta), Level.TimeSeconds < IGPlus_DetClockLearnUntil);
	}
	IGPlus_DetFireClockLead = Offset - IGPlus_DetClockBaseline;
}

function bool IGPlus_DetFireClockOK() {
	local bool bOK;

	if (zzUTPure == none || zzUTPure.Settings.DetFireClockMargin <= 0.0)
		return true;
	bOK = IGPlus_DetFireClockLead <= zzUTPure.Settings.DetFireClockMargin;
	// A blocked step skips a server shot; log it, at most once a second.
	if (!bOK && Level.TimeSeconds - IGPlus_DetLastClockLogTS > 1.0) {
		IGPlus_DetLastClockLogTS = Level.TimeSeconds;
		IGPlus_StatClockHolds++;
		IGPlus_EventLog("[DET-CLOCK]"@PlayerReplicationInfo.PlayerName@"lead="$IGPlus_DetFireClockLead
			@"margin="$zzUTPure.Settings.DetFireClockMargin@"- fresh Det shots held");
	}
	return bOK;
}

// The switch execs run on the server; the client keeps predicting the old
// weapon until xxClientSwitchPending/ClientPutDown arrives, one round trip
// after its key press. Honour those predicted steps instead of a flat 0.12 s,
// or every shot in that gap is client-only above ~120 ms ping.
function float IGPlus_DetComputeInFlightSlack() {
	// PingAverage is real time; windows run in game time.
	return FClamp(0.001 * IGPlus_GetLatencyMs() * Level.TimeDilation + 0.03, 0.12, 0.35);
}

// WHEN the bound weapon may step; binding validity covers WHICH.
simulated function bool IGPlus_DetFireWindowOpen(Weapon W, float StepTS) {
	if (W == none)
		return false;
	if (W == Weapon) {
		if (StepTS < IGPlus_DetWeaponGateTS)
			return false;
		// Predicted switch: the client stopped predicting this weapon at TS.
		if (IGPlus_PSActive && W == IGPlus_PSFrom && IGPlus_PSTarget != W && StepTS > IGPlus_PSTS)
			return false;
		// A pending switch closes the equipped window once the client can
		// have learned of it (one round trip, see IGPlus_DetComputeInFlightSlack).
		if (PendingWeapon != none && PendingWeapon != W
			&& StepTS > IGPlus_DetPendingSeenTS + FMax(0.12, IGPlus_DetInFlightSlack))
			return false;
		return true;
	}
	if (W == PendingWeapon)
		return StepTS >= IGPlus_DetPendingSeenTS + IGPlus_DetEntryGateSeconds();
	if (W == IGPlus_DetPrevWeapon) {
		// Grace accepts in-flight pre-switch steps only.
		return StepTS < IGPlus_DetPrevWeaponStepTS;
	}
	// Fail closed; unreachable after binding validation.
	return false;
}

simulated function bool IGPlus_DetSupportsWeapon(Weapon W) {
	return IGPlus_GetDetWeaponIndex(W) != IGPLUS_DetWEAPON_None;
}

function IGPlus_DetHandleOutOfAmmo(Weapon W) {
	local float Rating;
	local int UseAlt;

	// A late step for the weapon just switched away from must not re-switch.
	if (W != Weapon)
		return;
	// The player already started a predicted switch away from it.
	if (IGPlus_PSActive && IGPlus_PSFrom == W)
		return;

	StopFiring();
	if (PendingWeapon != none && PendingWeapon != W)
		return;

	// Stock switches out of an empty weapon from Idle's Begin — after the fire
	// anim. SwitchToBestWeapon holsters immediately, which would beat a manual
	// switch pressed at the same moment, so while the deferral is up only pick
	// the weapon; IGPlus_DetCheckSwitchWedge holsters once the anim ends.
	if (IGPlus_DetSwitchDeferActive() && Inventory != none) {
		PendingWeapon = Inventory.RecommendWeapon(Rating, UseAlt);
		if (PendingWeapon == Weapon)
			PendingWeapon = none;
		IGPlus_DetAutoSwitchPending = PendingWeapon;
		return;
	}

	SwitchToBestWeapon();
}

// 0 = no shot, 1 = primary, 2 = alt.
simulated function int IGPlus_DetIntervalShotDue(
	float StepTS,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	float PrimaryInterval,
	float AltInterval,
	float NextFireTS,
	out float ShotInterval
) {
	local bool bWantsPrimary;
	local bool bWantsAlt;

	bWantsPrimary = bFireHeld || bForceFire;
	bWantsAlt = bAltHeld || bForceAlt;
	if (!bWantsPrimary && !bWantsAlt)
		return 0;
	if (StepTS + 0.0001 < NextFireTS)
		return 0;

	if (bWantsAlt && !bWantsPrimary) {
		ShotInterval = AltInterval;
		return 2;
	}
	ShotInterval = PrimaryInterval;
	return 1;
}

// When the next shot is due, after a shot that ran on the step at StepTS and
// was due at DueTS. With the button held a shot runs on the first step at or
// after its due time, up to one client frame late. The interval then counts
// from the due time, so that frame's leftover time is not lost and the rate
// is the same at every frame rate. Stock and IG+ without ping compensation
// time a held refire by the fire animation, and the engine carries a frame's
// leftover time into the next animation. A shot that ran later than
// IGPLUS_DET_CARRY_MAX after its due time (a press on a weapon that was
// ready, the first shot) counts from its own step. Only these two times
// decide it, and client and server have the same two: the shot's frame ends
// its move (bForcePacketSplit in xxReplicateMove).
static final function float IGPlus_DetNextShotTS(float StepTS, float DueTS, float Interval) {
	if (DueTS > 0.0 && StepTS - DueTS < IGPLUS_DET_CARRY_MAX)
		return DueTS + Interval;
	return StepTS + Interval;
}

simulated function bool IGPlus_DetIsWeaponReady(Weapon W) {
	local Pawn PawnOwner;
	local TournamentPlayer TP;
	local TournamentWeapon TW;
	local bbPlayer BP;

	if (!IGPlus_IsDetActiveWeapon(W))
		return false;

	PawnOwner = Pawn(W.Owner);
	if (PawnOwner == none)
		return false;

	BP = bbPlayer(PawnOwner);
	if (BP != none && BP.IGPlus_IsDeterministicSwitchGuardActive())
		return false;
	// Server-replicated bring-up gate (set only on owning clients; stays 0
	// server-side, where FireWindowOpen enforces the same timestamp).
	if (BP != none && BP.Level.TimeSeconds < BP.IGPlus_DetClientEntryGateTS)
		return false;
	// Not equipped on the server yet (client finished its select first, e.g.
	// while the server still plays a holstering weapon's fire anim). Only once
	// a tagged gate arrived: a spawn equip inside Login sends none.
	if (BP != none && BP.Level.NetMode == NM_Client
		&& BP.IGPlus_DetClientGateWeapon != none && BP.IGPlus_DetClientGateWeapon != W)
		return false;

	TP = TournamentPlayer(PawnOwner);
	if (TP != none && TP.ClientPending != none && TP.ClientPending != W)
		return false;
	if (BP != none && BP.IGPlus_DetClientSwitchPending != none && BP.IGPlus_DetClientSwitchPending != W)
		return false;
	if (PawnOwner.Weapon != W)
		return false;
	if (PawnOwner.PendingWeapon != none && PawnOwner.PendingWeapon != W)
		return false;
	if (W.bChangeWeapon || W.IsInState('Pickup') || W.IsInState('DownWeapon') || W.IsInState('ClientDown'))
		return false;
	TW = TournamentWeapon(W);
	return TW != none && TW.bCanClientFire;
}

simulated function bool IGPlus_IsDetActiveWeapon(optional Weapon W) {
	local ST_ShockRifle SR;
	local ST_ripper RP;
	local ST_UT_FlakCannon FC;
	local ST_ut_biorifle BR;
	local ST_UT_Eightball EB;
	local ST_SniperRifle SN;

	if (W == none)
		return false;

	SR = ST_ShockRifle(W);
	if (SR != none)
		return SR.IsDetActive();
	RP = ST_ripper(W);
	if (RP != none)
		return RP.IsDetActive();
	FC = ST_UT_FlakCannon(W);
	if (FC != none)
		return FC.IsDetActive();
	BR = ST_ut_biorifle(W);
	if (BR != none)
		return BR.IsDetActive();
	EB = ST_UT_Eightball(W);
	if (EB != none)
		return EB.IsDetActive();
	SN = ST_SniperRifle(W);
	if (SN != none)
		return SN.IsDetActive();
	if (ST_SuperShockRifle(W) != none)
		return ST_SuperShockRifle(W).IsDetActive();

	return false;
}

simulated function bool IGPlus_DetProcessStep(
	Weapon W,
	float StepTS,
	rotator StepView,
	vector StepLoc,
	bool bFireHeld,
	bool bAltHeld,
	bool bForceFire,
	bool bForceAlt,
	bool bServerSide,
	optional bool bClientPredictedStep,
	optional int DetChargeData,
	optional bool bHasEightballInstant,
	optional bool bEightballInstant
) {
	local ST_ShockRifle SR;
	local ST_ripper RP;
	local ST_UT_FlakCannon FC;
	local ST_ut_biorifle BR;
	local ST_UT_Eightball EB;
	local ST_SniperRifle SN;
	local IGPlus_WeaponImplementationBase WImpBase;

	if (W == none)
		return false;

	// Inactive weapon: not handled here, legacy fire must run.
	if (!IGPlus_IsDetActiveWeapon(W))
		return false;

	// Closed window: no fire intent; switched-away charge weapons get one
	// no-input step to settle an in-flight load.
	if (bServerSide && !IGPlus_DetFireWindowOpen(W, StepTS)) {
		// A hinted step that wants to fire means the client predicted a shot
		// here; rejecting it leaves a client-only shot. Counted for the
		// summary, logged while TraceInput is on.
		if (bClientPredictedStep && (bFireHeld || bAltHeld || bForceFire || bForceAlt)
			&& Level.TimeSeconds - IGPlus_DetLastRejectLogTS > 1.0) {
			IGPlus_DetLastRejectLogTS = Level.TimeSeconds;
			IGPlus_StatShotRefused++;
			if (bTraceInput)
				IGPlus_EventLog("[DET-REJECT]"@PlayerReplicationInfo.PlayerName@W.Name
					@"step="$StepTS@"gate="$IGPlus_DetWeaponGateTS
					@"pendingSeen="$IGPlus_DetPendingSeenTS@"slack="$IGPlus_DetInFlightSlack
					@"prevStep="$IGPlus_DetPrevWeaponStepTS@"weapon="$Weapon
					@"pending="$PendingWeapon);
		}
		if (bForceFire && IGPlus_EnableInputReplication)
			IGPlus_DetLatchFireTap(StepTS, W);
		EB = ST_UT_Eightball(W);
		if (EB != none && EB.DetHasSwitchAwayRequest())
			return EB.DetProcessStep(
				StepTS, StepView, StepLoc,
				false, false, false, false,
				true, false, DetChargeData,
				bHasEightballInstant, bEightballInstant);
		BR = ST_ut_biorifle(W);
		if (BR != none && BR.bDetWasAltHeld && IGPlus_DetSwitchAwayFrom(BR))
			return BR.DetProcessStep(
				StepTS, StepView, StepLoc,
				false, false, false, false,
				true, false, DetChargeData);
		return true;
	}

	// Pending Eightball may remember AltFire edges, but may not fire until equipped.
	if (bServerSide && W != Weapon && W == PendingWeapon) {
		EB = ST_UT_Eightball(W);
		if (EB != none && bClientPredictedStep
			&& EB.DetTrackPendingAltInput(bFireHeld, bAltHeld, bForceFire, bForceAlt))
			return true;

		// Other pending fire intent remains untrusted until actual equip.
		bClientPredictedStep = false;
	}

	// Input replication only: queue a tap that arrives on an untrusted step
	// (select anim in progress) and replay it on the first trusted step. On the
	// ServerMove path the client owns the queue and sends the replayed tap in
	// the move's force bit, so both sides fire it on the same step.
	if (bServerSide && IGPlus_EnableInputReplication) {
		if (!bClientPredictedStep) {
			if (bForceFire)
				IGPlus_DetLatchFireTap(StepTS, W);
		} else if (W == Weapon && IGPlus_DetConsumePendingFireTap(StepTS, W)) {
			bForceFire = true;
		}
	}

	WImpBase = IGPlus_GetWeaponImplementationBase();
	if (WImpBase != none)
		StepView = WImpBase.IGPlus_DetQuantizeView(StepView);

	SR = ST_ShockRifle(W);
	if (SR != none)
		return SR.DetProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	RP = ST_ripper(W);
	if (RP != none)
		return RP.DetProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	SN = ST_SniperRifle(W);
	if (SN != none)
		return SN.DetProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	if (ST_SuperShockRifle(W) != none)
		return ST_SuperShockRifle(W).DetProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	FC = ST_UT_FlakCannon(W);
	if (FC != none)
		return FC.DetProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	BR = ST_ut_biorifle(W);
	if (BR != none)
		return BR.DetProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep, DetChargeData);

	EB = ST_UT_Eightball(W);
	if (EB != none)
		return EB.DetProcessStep(
			StepTS,
			StepView,
			StepLoc,
			bFireHeld,
			bAltHeld,
			bForceFire,
			bForceAlt,
			bServerSide,
			bClientPredictedStep,
			DetChargeData,
			bHasEightballInstant,
			bEightballInstant
		);

	return false;
}

simulated function Weapon IGPlus_FindDetSupportedWeapon(optional Weapon Preferred) {
	if (IGPlus_DetSupportsWeapon(Preferred))
		return Preferred;
	return none;
}

// Client-side switch bookkeeping. The bring-up entry gate is replicated
// (xxClientDetEntryGate); the client does not re-derive it from the flip.
simulated function IGPlus_DetTrackClientPendingSwitch() {
	if (PendingWeapon != none && Weapon != none && !Weapon.bChangeWeapon
		&& !Weapon.IsInState('DownWeapon') && !IGPlus_DetSwitchDeferActive())
		Weapon.PutDown();
	if (ClientPending == IGPlus_DetClientPendingSeen)
		return;
	if (ClientPending != none && ClientPending == Weapon)
		IGPlus_MarkDeterministicSwitchGuard();
	IGPlus_DetClientPendingSeen = ClientPending;
}

// Watchdog for pending switches: completes holsters deferred past the
// fire-anim window, and self-heals a weapon stranded outside its state
// machine (which could never honor bChangeWeapon and would otherwise hang
// the switch until death). Runs once per received move.
function IGPlus_DetCheckSwitchWedge() {
	if (PendingWeapon == none) {
		IGPlus_DetPendingStuckSince = 0.0;
		return;
	}
	// Out-of-ammo pick made during the hold: drop it if ammo was picked up
	// meanwhile (stock re-checks ammo in Idle after the fire anim). Clear it
	// without a cancel re-arm, but retract the xxClientSwitchPending that
	// IGPlus_DetTrackPendingWeapon already sent, or the client's readiness
	// stays blocked on the auto pick and this weapon never fires again.
	if (IGPlus_DetAutoSwitchPending != none) {
		if (PendingWeapon != IGPlus_DetAutoSwitchPending) {
			IGPlus_DetAutoSwitchPending = none; // player chose another weapon
		} else if (!IGPlus_DetSwitchDeferActive() && Weapon != none
			&& !Weapon.bChangeWeapon && !Weapon.IsInState('DownWeapon')
			&& Weapon.AmmoType != none && Weapon.AmmoType.AmmoAmount > 0) {
			PendingWeapon = none;
			IGPlus_DetPendingSeen = none;
			IGPlus_DetAutoSwitchPending = none;
			IGPlus_DetPendingStuckSince = 0.0;
			if (RemoteRole == ROLE_AutonomousProxy)
				xxClientSwitchPending(none, 0.0);
			IGPlus_DetClearPendingFireTap(); // a click on the empty gun was never shown
			return;
		}
	}
	// Complete a holster that was deferred for the fire-anim window.
	if (Weapon != none && !Weapon.bChangeWeapon
		&& !Weapon.IsInState('DownWeapon') && !IGPlus_DetSwitchDeferActive())
		Weapon.PutDown();
	if (IGPlus_DetPendingStuckSince <= 0.0) {
		IGPlus_DetPendingStuckSince = Level.TimeSeconds;
		return;
	}
	if (Weapon == none || TournamentWeapon(Weapon) == none
		|| Level.TimeSeconds - IGPlus_DetPendingStuckSince < 1.0
		|| Level.TimeSeconds - IGPlus_DetLastWedgeDumpTS < 1.0)
		return;

	IGPlus_DetLastWedgeDumpTS = Level.TimeSeconds;

	// Self-heal: a weapon stranded outside its state machine (state '') can
	// never honor bChangeWeapon, so the pending switch would hang until death.
	// Re-enter the machine at DownWeapon; its Begin completes the switch.
	if (!Weapon.IsInState('DownWeapon')) {
		IGPlus_EventLog("[EB-WEDGE]"@PlayerReplicationInfo.PlayerName@"recover: forcing "$Weapon.Name$" ("$Weapon.GetStateName()
			$") to DownWeapon for pending "$PendingWeapon.Name);
		Weapon.bChangeWeapon = true;
		Weapon.GotoState('DownWeapon');
	}
}

// Stock holster parity: a weapon cannot start going down while its fire
// animation still plays. Stock's global PutDown latches bChangeWeapon and the
// fire state's AnimEnd completes the switch, so the wait equals the fire-anim
// remainder. FireAnimTime per weapon is derived from the stock mesh sequences
// (tween 0.05 + (frames-1)/(seqRate*playRate), FireAdjust=1). The Eightball
// already defers via its FireRockets state; this covers the interval weapons.
simulated function IGPlus_DetNoteShot(float TS, float FireAnimTime) {
	IGPlus_DetLastShotTS = TS;
	IGPlus_DetHolsterHoldUntilTS = TS + FireAnimTime;
	if (Role < ROLE_Authority)
		IGPlus_DetClientShotTS = TS;
	else
		IGPlus_DetServerShotTS = TS;
}

// Client: the server ran our last shot on another move than we did, later by
// Delta (the rifle, the sniper, and the shock rifle, flak cannon, ripper and
// bio rifle, whose own shot and the server's then leave at different times.
// The rocket launcher has its own: ST_UT_Eightball.ClientDetVolleyReady). That
// happens when the shot's own move is lost: with
// the button held the server fires on the next move that arrives. Its refire
// clock then runs Delta behind ours, and it stays there for as long as the
// button is held: every later shot runs a move late on the server, on a move
// that carries none of the shot's own data (what our trace said, the eye
// height, the frame its target was carried on by). A rig with 5% of the
// shooter's packets lost showed 23 shots in a row like that (Nov 13 2026).
// The server decides when a shot runs, so we take over its clock: the same
// sum from the same numbers as on the server (IGPlus_DetNextShotTS, with the
// server's step and the time the shot was due), so both sides find the next
// shot due on the same move. A shot the server ran a move late but still
// within IGPLUS_DET_CARRY_MAX of its due time leaves the clock where it is:
// both sides count the next interval from the due time. A shot it ran later
// than that counts from the server's step there, and without this it would
// stay that much behind us for as long as the button is held.
function IGPlus_DetSyncShotClock(float ServerTS) {
	local float Delta, Due, Interval, OldNext, NewNext;
	local ST_SuperShockRifle SSR;
	local ST_SniperRifle SN;
	local ST_ShockRifle SR;
	local ST_UT_FlakCannon FC;
	local ST_ripper RP;
	local ST_ut_biorifle BR;

	Delta = ServerTS - IGPlus_DetClientShotTS;
	if (Abs(Delta) < 0.0008 || Abs(Delta) > 0.25)
		return;
	SSR = ST_SuperShockRifle(Weapon);
	SN = ST_SniperRifle(Weapon);
	SR = ST_ShockRifle(Weapon);
	FC = ST_UT_FlakCannon(Weapon);
	RP = ST_ripper(Weapon);
	BR = ST_ut_biorifle(Weapon);
	if (SSR != None) {
		Due = SSR.DetShotDueTS;
		Interval = SSR.ShotInterval();
		OldNext = SSR.NextDetFireTS;
	} else if (SN != None) {
		Due = SN.DetShotDueTS;
		Interval = SN.PrimaryShotInterval();
		OldNext = SN.NextDetFireTS;
	} else if (SR != None) {
		Due = SR.DetShotDueTS;
		Interval = SR.DetShotInterval;
		OldNext = SR.NextDetFireTS;
	} else if (FC != None) {
		Due = FC.DetShotDueTS;
		Interval = FC.DetShotInterval;
		OldNext = FC.NextDetFireTS;
	} else if (RP != None) {
		Due = RP.DetShotDueTS;
		Interval = RP.DetShotInterval;
		OldNext = RP.NextDetFireTS;
	} else if (BR != None && BR.DetShotInterval > 0.0) {
		// The bio rifle's primary and its glob at the release. Not while an
		// alt charge is under way: its start is no shot.
		Due = BR.DetShotDueTS;
		Interval = BR.DetShotInterval;
		OldNext = BR.NextDetFireTS;
	} else {
		return;
	}
	// The server's word on the shot before our last one, come in after we
	// fired again: it can not have run our last shot before that was due.
	if (ServerTS + 0.001 < Due)
		return;
	NewNext = IGPlus_DetNextShotTS(ServerTS, Due, Interval);
	if (SSR != None)
		SSR.NextDetFireTS = NewNext;
	else if (SN != None)
		SN.NextDetFireTS = NewNext;
	else if (SR != None)
		SR.NextDetFireTS = NewNext;
	else if (FC != None)
		FC.NextDetFireTS = NewNext;
	else if (RP != None)
		RP.NextDetFireTS = NewNext;
	else
		BR.NextDetFireTS = NewNext;
	// The switch hold after the shot starts at the server's step too. For the
	// rifle and the sniper that is the interval, as before.
	IGPlus_DetClientShotTS = ServerTS;
	IGPlus_DetLastShotTS = ServerTS;
	IGPlus_DetHolsterHoldUntilTS += Delta;
	if (bDrawDebugData) {
		if (NewNext == OldNext)
			ClientDebugMessage("Shot clock: the server ran the last shot"@IGPlus_Fmt1(1000.0 * Delta)@"ms off our move, clock kept");
		else
			ClientDebugMessage("Shot clock: the server ran the last shot"@IGPlus_Fmt1(1000.0 * Delta)@"ms off our move, clock moved");
	}
}

simulated function bool IGPlus_DetSwitchDeferActive() {
	local float NowTS;

	// Fast weapon switch force-completes switches in move processing and has
	// never waited for fire states in any era — the holster deferral is a
	// non-FWS (slow-path) behavior only. Without this, the deferral's client
	// guard would delay post-fire switch fire on FWS servers.
	if (IGPlus_UseFastWeaponSwitch)
		return false;
	if (!IGPlus_IsDetActiveWeapon(Weapon))
		return false;
	if (Role == ROLE_Authority && Level.NetMode != NM_Standalone)
		NowTS = CurrentTimeStamp;
	else
		NowTS = Level.TimeSeconds;
	return NowTS >= IGPlus_DetLastShotTS
		&& NowTS < IGPlus_DetHolsterHoldUntilTS;
}

// Stock ForceFire parity for deterministic weapons: a fire tap that lands
// while the weapon is not ready (select anim, bring-up gate) is queued and
// replayed as a force tap on the first accepted step, instead of being
// silently dropped. One slot, short expiry — matches bJustFired semantics.
// The tap is bound to the weapon it was pressed on: a click on the outgoing
// weapon must never come out of the incoming one (stock drops it).
simulated function IGPlus_DetLatchFireTap(float NowTS, Weapon W) {
	IGPlus_DetPendingFireTapTS = NowTS;
	IGPlus_DetPendingFireTapWeapon = W;
}

simulated function bool IGPlus_DetConsumePendingFireTap(float NowTS, Weapon W) {
	local float TapTS;

	TapTS = IGPlus_DetPendingFireTapTS;
	if (TapTS <= 0.0)
		return false;
	if (W != IGPlus_DetPendingFireTapWeapon)
		return false;
	IGPlus_DetClearPendingFireTap();
	return NowTS - TapTS <= 0.8;
}

simulated function IGPlus_DetClearPendingFireTap() {
	IGPlus_DetPendingFireTapTS = 0.0;
	IGPlus_DetPendingFireTapWeapon = none;
}

simulated function IGPlus_MarkDeterministicSwitchGuard(optional float GuardSeconds) {
	if (GuardSeconds <= 0.0)
		GuardSeconds = 0.12;
	IGPlus_DeterministicSwitchGuardUntil = FMax(
		IGPlus_DeterministicSwitchGuardUntil,
		Level.TimeSeconds + GuardSeconds
	);
}

simulated function bool IGPlus_IsDeterministicSwitchGuardActive() {
	return Level.TimeSeconds < IGPlus_DeterministicSwitchGuardUntil;
}

simulated function bool IGPlus_IsDetReady(optional Weapon Preferred) {
	return IGPlus_DetIsWeaponReady(Preferred);
}

function IGPlus_DetFillMoveBinding(IGPlus_SavedMove M) {
	M.IGPlus_SavedWeapon = Weapon;
	M.bDetReady = IGPlus_IsDetReady(Weapon);
	// A holstering launcher still needs its own release/settlement input.
	// Readiness gates new shots; it must not erase which weapon sent input.
	M.DetWeaponIndex = IGPlus_GetDetWeaponIndex(Weapon);
	M.DetChargeData = IGPlus_GetDetChargeData();
}

function IGPlus_SavedMove PickRedundantMove(IGPlus_SavedMove Old, IGPlus_SavedMove M, vector Accel, EDodgeDir DodgeMove) {
	if (M.bPressedJump || (bDodging && M.DodgeMove >= DODGE_Left && M.DodgeMove <= DODGE_Back)) {
		return M;
	}
	if (VSize(Accel - M.Acceleration) > 0.125 * AccelRate) {
		if (Old == none || (Old.bPressedJump == false && (Old.DodgeMove < DODGE_Left || Old.DodgeMove > DODGE_Back)))
			return M;
	}
	return Old;
}

function bool CanMergeMove(IGPlus_SavedMove Pending, vector Accel) {
	local vector OldAccel, NewAccel;
	local vector OldAccelNorm, NewAccelNorm;
	local bool bCurrentDetReady;

	if (Pending.IGPlus_MergeCount >= 31)
		return false;
	// Hammer and Translocator both have index None. Their input must still
	// stay in separate moves when the equipped weapon changes.
	if (Pending.IGPlus_SavedWeapon != Weapon)
		return false;
	// Translocator's stock two-button shortcut checks simultaneous holds.
	// OR-merging separate throw/teleport presses can invent that shortcut.
	if (ST_Translocator(Weapon) != none
		&& !class'ST_Translocator'.static.CanMergeFireInput(
			Pending.bFire, Pending.bAltFire,
			bFire != 0 || bJustFired, bAltFire != 0 || bJustAltFired))
		return false;
	// Readiness can stay the same across a switch. Keep the weapon identity
	// too, or MergeMove would relabel the outgoing weapon's held input.
	if (Pending.DetWeaponIndex != IGPlus_GetDetWeaponIndex(Weapon))
		return false;
	// Held bits are OR-merged, so a release folded into a held move resolves
	// as still held (primary->alt would fire primary on the server while the
	// client predicted alt). Det weapons end the move on a release edge, and
	// so does the hammer when its release rides the move (IGPlus_PredictHammer).
	if ((IGPlus_FindDetSupportedWeapon(Weapon) != none || (ST_ImpactHammer(Weapon) != none && IGPlus_PredictHammer()))
		&& ((Pending.bFire && bFire == 0 && !bJustFired)
			|| (Pending.bAltFire && bAltFire == 0 && !bJustAltFired)))
		return false;

	// Keep deterministic-ready epochs isolated per move. Merging across a
	// ready<->not-ready transition can produce client-only predicted shock shots
	// when switching away during fire spam.
	if (Pending.bDetReady || IGPlus_FindDetSupportedWeapon(Weapon) != none) {
		bCurrentDetReady = IGPlus_IsDetReady(Weapon);
		if (bCurrentDetReady != Pending.bDetReady)
			return false;
	}

	if (bIs469Server || Pending.Delta >= 0.005) { // only 469 servers like updates for <5ms
		OldAccelNorm = Normal(Pending.Acceleration);
		NewAccelNorm = Normal(Accel);
		OldAccel = OldAccelNorm * Min(VSize(Pending.Acceleration), AccelRate);
		NewAccel = NewAccelNorm * Min(VSize(Accel), AccelRate);
		return bForcePacketSplit == false &&
			(VSize(NewAccel - OldAccel) < 1 || NewAccelNorm dot OldAccelNorm > 0.95) &&
			Pending.bForceFire == false && Pending.bForceAltFire == false &&
			Pending.bPressedJump == false && (Pending.DodgeMove == DODGE_None || Pending.DodgeMove >= DODGE_Active);
	}

	return true;
}

function IGPlus_MergeMove(IGPlus_SavedMove PendMove, float DeltaTime, vector NewAccel, EDodgeDir DodgeMove) {
	local float TotalTime;
	local bool bFireNew;
	local bool bAltFireNew;
	local bool bCurrentFireHeld;
	local bool bCurrentAltHeld;
	local bool bForceFireTap;
	local bool bForceAltTap;

	PendMove.TimeStamp = Level.TimeSeconds;
	PendMove.IGPlus_MergeCount += 1;
	// v4 move transport disabled: movement rides the proven v3 ServerMove;
	// deterministic weapons run whole-move dispatch server-side.

	TotalTime = PendMove.Delta + DeltaTime;
	if (TotalTime != 0)
		PendMove.Acceleration = (DeltaTime * NewAccel + PendMove.Delta * PendMove.Acceleration)/TotalTime;

	// Set this move's data.
	if ( PendMove.DodgeMove == DODGE_None ) {
		PendMove.DodgeMove = DodgeMove;
		if (DodgeMove > DODGE_None && DodgeMove < DODGE_Active && PendMove.DodgeIndex < 0) {
			PendMove.DodgeIndex = PendMove.IGPlus_MergeCount;
		}
	}

	if (PendMove.bPressedJump == false && bPressedJump && PendMove.JumpIndex < 0)
		PendMove.JumpIndex = PendMove.IGPlus_MergeCount;
	PendMove.bPressedJump = bPressedJump || PendMove.bPressedJump;

	if ((bRun > 0) != PendMove.bRun) {
		if (PendMove.RunChangeIndex < 0)
			PendMove.RunChangeIndex = PendMove.IGPlus_MergeCount;
		else
			// if we changed bRun before, ignore running/walking for a very short time
			PendMove.RunChangeIndex = -1;
	}
	PendMove.bRun = (bRun > 0);

	if ((bDuck > 0) != PendMove.bDuck) {
		if (PendMove.DuckChangeIndex < 0)
			PendMove.DuckChangeIndex = PendMove.IGPlus_MergeCount;
		else
			// if we changed bDuck before, ignore ducking/standing for a very short time
			PendMove.DuckChangeIndex = -1;
	}
	PendMove.bDuck = (bDuck > 0);

	bForceFireTap = bJustFired;
	bForceAltTap = bJustAltFired;

	// Keep merged hold bits aligned with suppression-aware effective held state.
	bCurrentFireHeld = (bFire != 0);
	bCurrentAltHeld = (bAltFire != 0);

	bFireNew = PendMove.bFire || bForceFireTap || bCurrentFireHeld;
	if (bFireNew != PendMove.bFire && PendMove.FireIndex < 0) {
		PendMove.FireIndex = PendMove.IGPlus_MergeCount;
	}
	PendMove.bFire = bFireNew;
	PendMove.bForceFire = PendMove.bForceFire || bForceFireTap;

	bAltFireNew = PendMove.bAltFire || bForceAltTap || bCurrentAltHeld;
	if (bAltFireNew != PendMove.bAltFire && PendMove.AltFireIndex < 0) {
		PendMove.AltFireIndex = PendMove.IGPlus_MergeCount;
	}
	PendMove.bAltFire = bAltFireNew;
	PendMove.bForceAltFire = PendMove.bForceAltFire || bForceAltTap;

	// Maintain deterministic-ready based on current merged slice state.
	IGPlus_DetFillMoveBinding(PendMove);

	PendMove.Delta = TotalTime;
}

function IGPlus_ReplicateInput(float Delta) {
	local float RealDelta;
	local IGPlus_SavedInput ReferenceInput;
	local IGPlus_SavedInput NewestInput;
	local IGPlus_SavedInput SerializedInput;
	local Weapon DetWeapon;
	local vector NewOffset, TargetLoc;
	local ReplBuffer B;
	local int i;
	local bool bPredForceFire;

	IGPlus_DetTrackClientPendingSwitch();

	// Higor: process smooth adjustment.
	if (VSize(IGPlus_AdjustLocationOffset) > 0) {
		TargetLoc = Location + IGPlus_AdjustLocationOffset;
		NewOffset = IGPlus_AdjustLocationOffset * Exp(-20*Delta);
		MoveSmooth(IGPlus_AdjustLocationOffset - NewOffset);
		IGPlus_AdjustLocationOffset = TargetLoc - Location;
	} else {
		IGPlus_AdjustLocationOffset = vect(0,0,0);
	}

	IGPlus_TPFix_LastTouched = none;
	AutonomousPhysics(Delta);
	CorrectTeleporterVelocity();

	IGPlus_SavedInputChain.Add(Delta, self);
	NewestInput = IGPlus_SavedInputChain.Newest;

	if (bTraceInput && IGPlus_InputLogFile != none)
		IGPlus_InputLogFile.LogInput(IGPlus_SavedInputChain.Newest);

	NetStatsElem.LocationError = VSize(IGPlus_AdjustLocationOffset);
	NetStatsElem.UnconfirmedTime = (Level.TimeSeconds - IGPlus_SavedInputChain.Oldest.TimeStamp) / Level.TimeDilation;

	RealDelta = (Level.TimeSeconds - IGPlus_LastInputSendTime) / Level.TimeDilation;
	if (RealDelta < TimeBetweenNetUpdates - ClientUpdateTime)
		return;

	ClientUpdateTime = FClamp(RealDelta - TimeBetweenNetUpdates + ClientUpdateTime, -TimeBetweenNetUpdates, TimeBetweenNetUpdates);
	IGPlus_LastInputSendTime = Level.TimeSeconds;

	IGPlus_InputReplicationBuffer.Reset();
	ReferenceInput = IGPlus_SavedInputChain.SerializeNodes(10, IGPlus_InputReplicationBuffer);

	// Predict only serialized inputs, resolving the weapon per-input — protects
	// against unsent slices and mid-batch switches.
		if (ReferenceInput != none) {
			for (SerializedInput = ReferenceInput.Next; SerializedInput != none; SerializedInput = SerializedInput.Next) {
				if (!SerializedInput.bDetPredictedLocal) {
					if (SerializedInput.bDetReady) {
						DetWeapon = IGPlus_DetWeaponByIndex(SerializedInput.DetWeaponIndex);
						if (DetWeapon != none) {
							bPredForceFire = SerializedInput.bForceFireTap
								|| IGPlus_DetConsumePendingFireTap(SerializedInput.TimeStamp, DetWeapon);
							IGPlus_DetProcessStep(
								DetWeapon,
								SerializedInput.TimeStamp,
								SerializedInput.SavedViewRotation,
								SerializedInput.SavedLocation,
								SerializedInput.bFire,
								SerializedInput.bAFir,
								bPredForceFire,
								SerializedInput.bForceAltTap,
								false,
								SerializedInput.bDetReady,
								SerializedInput.DetChargeData,
								IGPlus_IsDetWeaponIndexEightball(SerializedInput.DetWeaponIndex),
								SerializedInput.bDetEightballInstant
							);
						}
					} else if (SerializedInput.bForceFireTap) {
						// Tap on a not-ready input frame: queue for first ready frame.
						IGPlus_DetLatchFireTap(SerializedInput.TimeStamp,
							IGPlus_DetWeaponByIndex(SerializedInput.DetWeaponIndex));
					}
				}
				SerializedInput.bDetPredictedLocal = true;
			}
		}

	if (IGPlus_InputReplicationBuffer.NumBits > 0) {
		for (i = 0; i < arraycount(B.Data); i++)
			B.Data[i] = IGPlus_InputReplicationBuffer.BitsData[i];
		ServerApplyInput(ReferenceInput.TimeStamp, IGPlus_InputReplicationBuffer.NumBits, B);
	}

	// Not in demo playback: the recording holds our weapon's anims and sounds.
	if (!IGPlus_InDemoPlayback() && IGPlus_ClientWeaponSettled())
	{
		if ( (Weapon == ClientPending) || (Weapon != OldClientWeapon) )
		{
			if ( Weapon.Owner != self ) //Non-respawnable weapon was picked up and Owner wasn't replicated yet
				Weapon.SetOwner(self); //Simulate owner change locally
			if ( Weapon.IsInState('ClientActive') )
				AnimEnd();
			else
				Weapon.GotoState('ClientActive');
			if ( (Weapon != ClientPending) && (myHUD != None) && myHUD.IsA('ChallengeHUD') )
				ChallengeHUD(myHUD).WeaponNameFade = 1.3;
			if ( (Weapon != OldClientWeapon) && (OldClientWeapon != None) )
				OldClientWeapon.GotoState('');

			ClientPending = None;
			IGPlus_DetClientSwitchPending = none;
			bNeedActivate = false;
		}
		else
		{
			Weapon.GotoState('');
			Weapon.TweenToStill();
		}
	}
	OldClientWeapon = Weapon;
}

// Client: our weapon may be brought up (or stood still) by the stock check
// in ReplicateMove, which waits for its animation to end. A weapon still on
// its world pickup state can't wait: a dropped one keeps the last looping
// anim its dead owner's copy replicated, so it never ends and the weapon
// never came up (stuck unable to fire, Pickup state, until a switch).
simulated function bool IGPlus_ClientWeaponSettled() {
	if (Weapon == None)
		return false;
	return !Weapon.IsAnimating() || (Weapon != OldClientWeapon && Weapon.IsInState('Pickup'));
}

function xxReplicateMove(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
) {
	local int TlocBefore;
	local IGPlus_SavedMove NewMove, OldMove, LastMove, PendMove;
	local EPhysics OldPhys;
	local Mover ExitLift;
	local Actor DbgOldBase;
	local float AdjustAlpha;
	local float RealDelta;
	local vector OldAccel;
	local Weapon DetLocalWeapon;
	local bool bLocalEightball;
	local bool bMoveFireHeld;
	local bool bMoveAltHeld;
	local bool bForceFireTap;
	local bool bForceAltTap;
	local bool bDetLocalShot;
	local bool bDetReplayedTap;
	local rotator PSARealView, PSAAimView;
	local bool bPSAAimFix;
	local int TlocAction;
	local ST_TranslocatorTarget TlocDisc;
	local bbPlayer AimTarget;

	// Higor: process smooth adjustment.
	if (IGPlus_AdjustLocationAlpha > 0)
	{
		AdjustAlpha = FMin(IGPlus_AdjustLocationAlpha, DeltaTime);
		MoveSmooth(IGPlus_AdjustLocationOffset * AdjustAlpha);
		IGPlus_AdjustLocationAlpha -= AdjustAlpha;
	}

	if ( VSize(NewAccel) > 3072.0)
		NewAccel = 3072.0 * Normal(NewAccel);
	OldAccel = Acceleration;

	if (bDrawDebugData) {
		debugNewAccel = Normal(NewAccel);
		debugPlayerLocation = Location;
	}

	// Push-Safe Aim: while the camera still eases after a correction, shots
	// leave from the real position; aim them through the crosshair point.
	if (IGPlus_PushSafeAim
		&& ((IGPlus_CameraCorrectionOffset != vect(0,0,0) && Settings.bCameraCorrectionSmoothing)
			|| IGPlus_LiftExitCamOffset != vect(0,0,0) || IGPlus_PushCamOffset != vect(0,0,0))
		&& (DodgeMove <= DODGE_None || DodgeMove >= DODGE_Active)
		&& (bFire != 0 || bAltFire != 0 || bJustFired || bJustAltFired)
	) {
		PSARealView = ViewRotation;
		bPSAAimFix = IGPlus_PSAAimView(PSAAimView);
		if (bPSAAimFix)
			ViewRotation = PSAAimView;
	}

	// Predict per slice, gated on readiness only (input-rep predicts per node).
	if (IGPlus_EnableInputReplication == false) {
		IGPlus_PSClientTick();
		IGPlus_DetTrackClientPendingSwitch();
		DetLocalWeapon = IGPlus_FindDetSupportedWeapon(Weapon);
		if (DetLocalWeapon != none && IGPlus_DetIsWeaponReady(DetLocalWeapon)) {
			bLocalEightball = ST_UT_Eightball(DetLocalWeapon) != none;
			bMoveFireHeld = (bFire != 0);
			bMoveAltHeld = (bAltFire != 0);
			bForceFireTap = bJustFired;
			if (bJustFired)
				IGPlus_DetClearPendingFireTap(); // a fresh click supersedes a queued one
			bDetReplayedTap = !bJustFired
				&& IGPlus_DetConsumePendingFireTap(Level.TimeSeconds, DetLocalWeapon);
			if (bDetReplayedTap)
				bForceFireTap = true;
			bForceAltTap = bJustAltFired;
			IGPlus_DetProcessStep(
				DetLocalWeapon,
				Level.TimeSeconds,
				ViewRotation,
				Location,
				bMoveFireHeld,
				bMoveAltHeld,
				bForceFireTap,
				bForceAltTap,
				false,
				true,
				IGPlus_GetDetChargeData(),
				bLocalEightball,
				IGPlus_IsEightballInstantMode(Weapon)
			);
			bDetLocalShot = IGPlus_DetClientShotTS == Level.TimeSeconds;
			// Predicted self-knockback: a rocket shot also starts its move, so
			// the server's step location is this frame's start, like the client's.
			// Push-Safe Aim: the server reads the shot origin off the previous move.
			// Client-side shock balls: the ball and the beam leave from this
			// frame's start on the server too (a merged move's step starts at
			// the move's start), or the client's own ball and the server's fly
			// apart by however far it moved in the merged frames.
			// A beam with a verdict on our own disc: the verdict rides its own move.
			if (bDetLocalShot && ((IGPlus_PredictedSelfKnockback && (bLocalEightball
					|| ST_UT_FlakCannon(DetLocalWeapon) != none || ST_ripper(DetLocalWeapon) != none
					|| ST_ShockRifle(DetLocalWeapon) != none))
				|| IGPlus_PushSafeAim
				|| (ST_ShockRifle(DetLocalWeapon) != none && IGPlus_PredictiveShockCombos())
				|| IGPlus_DetOwnBeamMode != 0 || IGPlus_ClientHitVerdict != 0 || IGPlus_ShotEyeByte != 0))
				bForcePacketSplit = true;
			// Send the replayed tap as this frame's press: the move then carries
			// the force bit and ends here, and the server fires it on this step.
			if (bDetReplayedTap)
				bJustFired = true;
		} else if (bJustFired && DetLocalWeapon != none
			&& (ClientPending == none || ClientPending == DetLocalWeapon)
			&& (IGPlus_DetClientSwitchPending == none || IGPlus_DetClientSwitchPending == DetLocalWeapon)
			&& !DetLocalWeapon.IsInState('ClientDown')) {
			// Tap during select/bring-up: queue for the first ready frame,
			// bound to the weapon it was pressed on (the move's binding).
			// Never for a weapon going down: stock drops those clicks.
			IGPlus_DetLatchFireTap(Level.TimeSeconds, DetLocalWeapon);
		}
	}

	if (bPSAAimFix)
		ViewRotation = PSARealView;

	// Deterministic translocator: decide now, before the merge, so an action
	// starts its own move (and ends it, below).
	if (IGPlus_DetTranslocator && IGPlus_EnableInputReplication == false && Level.NetMode == NM_Client
		&& ST_Translocator(Weapon) != none && Weapon.Class == class'ST_Translocator'
	) {
		TlocAction = ST_Translocator(Weapon).IGPlus_DetClientStep(
			self, Level.TimeSeconds, bJustFired, bFire != 0, bJustAltFired, bAltFire != 0);
		if (TlocAction != 0)
			bForcePacketSplit = true;
	} else if (IGPlus_DetTranslocator && Level.NetMode == NM_Client
		&& IGPlus_DetTlocAsked != none && Weapon != IGPlus_DetTlocAsked
		&& Level.TimeSeconds - IGPlus_DetTlocAskedTS < 2.0 && IGPlus_DetEarlyPress != 1) {
		// A click while our switch to the translocator is on its way. The
		// button itself counts, not what the weapon in hand made of it: one
		// that is going down already takes no click (bJustFired stays false).
		TlocAction = IGPlus_DetPressOf(bJustFired || (bFire != 0 && IGPlus_bDetEarlyFireWas == false),
			bJustAltFired || (bAltFire != 0 && IGPlus_bDetEarlyAltWas == false));
		if (TlocAction != 0)
			IGPlus_DetEarlyPress = TlocAction;
		TlocAction = 0;
	}
	IGPlus_bDetEarlyFireWas = bFire != 0;
	IGPlus_bDetEarlyAltWas = bAltFire != 0;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
	{
		PendMove = IGPlus_SavedMove(PendingMove);
		if (CanMergeMove(PendMove, NewAccel)) {
			IGPlus_MergeMove(PendMove, DeltaTime, NewAccel, DodgeMove);
		} else {
			SendSavedMove(PendMove);
			ClientUpdateTime = FClamp((PendMove.Delta/Level.TimeDilation) - TimeBetweenNetUpdates + ClientUpdateTime, -TimeBetweenNetUpdates, TimeBetweenNetUpdates);;

			if (SavedMoves == none) {
				SavedMoves = PendingMove;
			} else {
				LastMove = IGPlus_SavedMove(SavedMoves);
				while(LastMove.NextMove != none)
					LastMove = IGPlus_SavedMove(LastMove.NextMove);

				LastMove.NextMove = PendingMove;
			}
			PendingMove = none;
		}
	}
	if ( SavedMoves != None )
	{
		LastMove = IGPlus_SavedMove(SavedMoves);
		while (LastMove.NextMove != none) {
			OldMove = PickRedundantMove(OldMove, LastMove, NewAccel, DodgeMove);
			LastMove = IGPlus_SavedMove(LastMove.NextMove);
		}
		OldMove = PickRedundantMove(OldMove, LastMove, NewAccel, DodgeMove);
	}

	if ( PendingMove == None ) {
		NewMove = xxGetFreeMove();
		NewMove.Delta = DeltaTime;
		NewMove.Acceleration = NewAccel;

		// Set this move's data.
		NewMove.TimeStamp = Level.TimeSeconds;

		NewMove.SavedDodging = bDodging;
		NewMove.DodgeMove = DodgeMove;
		if (DodgeMove > DODGE_None && DodgeMove < DODGE_Active)
			NewMove.DodgeIndex = 0;

		NewMove.bRun = (bRun > 0);
		if (LastMove == none || LastMove.bRun != NewMove.bRun)
			NewMove.RunChangeIndex = 0;

		NewMove.bDuck = (bDuck > 0);
		if (LastMove == none || LastMove.bDuck != NewMove.bDuck)
			NewMove.DuckChangeIndex = 0;

		NewMove.bPressedJump = bPressedJump;
		if (bPressedJump)
			NewMove.JumpIndex = 0;

			bMoveFireHeld = (bFire != 0);
			bMoveAltHeld = (bAltFire != 0);
			bForceFireTap = bJustFired;
			bForceAltTap = bJustAltFired;

			NewMove.bFire = (bForceFireTap || bMoveFireHeld);
			NewMove.bForceFire = bForceFireTap;
			if (LastMove == none || LastMove.bFire != NewMove.bFire)
				NewMove.FireIndex = 0;

			NewMove.bAltFire = (bForceAltTap || bMoveAltHeld);
			NewMove.bForceAltFire = bForceAltTap;
			if (LastMove == none || LastMove.bAltFire != NewMove.bAltFire)
				NewMove.AltFireIndex = 0;

			IGPlus_DetFillMoveBinding(NewMove);

			if (bForceAltTap && IGPlus_PredictsTranslocation() && IGPlus_DetTranslocator == false)
				IGPlus_PredictTranslocate(NewMove);
			if ((bForceFireTap || bForceAltTap) && ST_Translocator(Weapon) != none)
				IGPlus_TlocLastPressTS = Level.TimeSeconds;

		if ( Weapon != None ) // approximate pointing so don't have to replicate
			Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));

		PendingMove = NewMove;
	} else {
		NewMove = IGPlus_SavedMove(PendingMove);
	}

	if (TlocAction != 0) {
		// The server repeats exactly this on the move (translocator moves
		// carry no Det charge).
		NewMove.DetChargeData = TlocAction;
		if (TlocAction == 3) { // translocate
			TlocDisc = ST_Translocator(Weapon).IGPlus_DetClientDisc();
			TlocBefore = TlocCounter;
			// The server gibs us where we stand on a disrupted disc.
			if (IGPlus_PredictsTranslocation() && TlocDisc != none
				&& TlocDisc.Disruption <= TlocDisc.DisruptionThreshold) {
				IGPlus_TlocPredictTo(TlocDisc, NewMove);
				// We didn't fit at the disc: the server fails it too (stock's
				// failed translocate, the disc gone on both sides).
				// Either way its sound plays now, and the server's skips us
				// (PlayOwnedSound): the failed one below, the teleport's when
				// this move's translocate count says we made it too
				// (ST_Translocator.Translocate).
				if (TlocCounter == TlocBefore) {
					NewMove.DetChargeData = TlocAction | 4;
					PlaySound(Weapon.AltFireSound, SLOT_Misc, 4 * SoundDampening);
				} else {
					PlaySound(Sound'Botpack.Resp2A', SLOT_None, 10.0);
				}
			} else if (IGPlus_PredictsTranslocation() && TlocDisc == none)
				ClientDebugMessage("Tloc not predicted: no disc here (ours out="$ST_Translocator(Weapon).IGPlus_bDetOut
					@"local="$ST_Translocator(Weapon).IGPlus_DetLocalDisc@"server's="$ST_Translocator(Weapon).IGPlus_DiscRepl$")");
			else if (IGPlus_PredictsTranslocation())
				ClientDebugMessage("Tloc not predicted: disc disrupted");
			ST_Translocator(Weapon).IGPlus_DetClientTranslocated(TlocCounter != TlocBefore || NewMove.DetChargeData != TlocAction);
		}
	}
	// The shot's verdict on our own disc and on our own balls (shock moves
	// carry no other charge).
	if (IGPlus_DetOwnBeamMode != 0 || IGPlus_OwnBallVerdict != 0) {
		NewMove.DetChargeData = (IGPlus_DetOwnBeamMode & 3) | ((IGPlus_OwnBallVerdict & 3) << 2);
		IGPlus_DetOwnBeamMode = 0;
		IGPlus_OwnBallVerdict = 0;
	}
	// What our own trace said about this frame's shot (instant hit feedback).
	if (IGPlus_ClientHitVerdict != 0) {
		NewMove.DetChargeData = IGPlus_ClientHitVerdict;
		IGPlus_ClientHitVerdict = 0;
	}
	// The eye height this frame's hitscan shot was traced from. Moves are
	// reused, so every move gets its value.
	NewMove.IGPlus_ShotEye = IGPlus_ShotEyeByte;
	IGPlus_ShotEyeByte = 0;

	bJustFired = false;
	bJustAltFired = false;
	OldPhys = Physics;

	IGPlus_TPFix_LastTouched = none;

	ExitLift = None;
	if (Settings.bSmoothLiftJump && IGPlus_OnMovingLift())
		ExitLift = Mover(Base);
	DbgOldBase = Base;

	// Own boarding: a moving lift by us where the server has it, for this move.
	IGPlus_OBBegin(NewMove);
	// Simulate the movement locally.
	ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
	AutonomousPhysics(DeltaTime);
	IGPlus_OBEnd(false);

	CorrectTeleporterVelocity();

	// Left a moving lift: go where the server has us now, not a ping later.
	if (ExitLift != None && Base != ExitLift) {
		IGPlus_LeftMovingLift(ExitLift, NewMove);
		bForcePacketSplit = true;
	}
	IGPlus_DebugLiftJumpTop(DbgOldBase);

	// Hammer charged and let go in this move, with fire as the move carries
	// it: its push lands at the end of it, as on the server
	// (ST_ImpactHammer.IGPlus_MoveEnd).
	if (ST_ImpactHammer(Weapon) != None)
		ST_ImpactHammer(Weapon).IGPlus_MoveEnd(Level.TimeSeconds, NewMove.bFire);

	// A predicted push lands at the end of a move, like on the server.
	if (IGPlus_SKQueueCount > 0 && IGPlus_SKApplyDue(Level.TimeSeconds, NewMove))
		bForcePacketSplit = true;

	NewMove.SetRotation( Rotation );
	NewMove.IGPlus_SavedViewRotation = ViewRotation;
	// Precise Rewind Time: what our last frame showed of the others.
	NewMove.IGPlus_PRTData = 0;
	if (IGPlus_EnableTickInterp && IGPlus_TI_Clock > 0.0) {
		// The tick position the shot's target was drawn at (the rifle and
		// the NextSA sniper find it with their own trace). Every other move
		// reports the one of the player nearest our line of sight, for the
		// weapons that have no trace here or trace later in the tick.
		AimTarget = None;
		if ((bDetLocalShot && IGPlus_PRTShotR > 0.0) == false)
			AimTarget = IGPlus_TI_AimTarget();
		if (bDetLocalShot && IGPlus_PRTShotR > 0.0)
			NewMove.IGPlus_PRTData = IGPlus_TI_Pack(IGPlus_PRTShotR, IGPlus_bPRTShotPast, IGPlus_bPRTShotHeld, IGPlus_PRTShotDelay, IGPlus_PRTShotSpan);
		else if (AimTarget != None)
			NewMove.IGPlus_PRTData = IGPlus_TI_Pack(AimTarget.IGPlus_ShownR, AimTarget.IGPlus_bShownPast, AimTarget.IGPlus_bShownHeld, AimTarget.IGPlus_TI_Delay + IGPlus_TI_Recv, AimTarget.IGPlus_ShownSpan);
		else
			NewMove.IGPlus_PRTData = IGPlus_TI_Pack(IGPlus_TI_Clock - IGPLUS_TI_MIN_DELAY, false, false, IGPLUS_TI_MIN_DELAY + IGPlus_TI_Recv);
	} else if (IGPlus_PRTSeenAt > 0 && IGPlus_PRTShownTick != 0) {
		if (bDetLocalShot)
			NewMove.IGPlus_PRTData = IGPlus_PRTPack(IGPlus_PRTShownTick, IGPlus_PRTShownAge + IGPlus_PRTShotLead);
		else
			NewMove.IGPlus_PRTData = IGPlus_PRTPack(IGPlus_PRTShownTick, IGPlus_PRTShownAge);
	}
	IGPlus_PRTShotLead = 0.0;
	IGPlus_PRTShotR = 0.0;
	IGPlus_bPRTShotPast = false;
	IGPlus_bPRTShotHeld = false;
	IGPlus_PRTShotDelay = 0.0;
	IGPlus_PRTShotSpan = 0;
	// Only the shot frame's move (a single frame) carries the aimed view, so
	// nothing else (dodges, other weapons) sees it.
	if (bPSAAimFix && bDetLocalShot)
		NewMove.IGPlus_SavedViewRotation = PSAAimView;
	NewMove.IGPlus_SavedLocation = Location;
	NewMove.IGPlus_SavedVelocity = Velocity;

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	RealDelta = PendingMove.Delta / Level.TimeDilation;

	if (Settings.bCameraCorrectionSmoothing)
		NetStatsElem.LocationError = VSize(IGPlus_CameraCorrectionOffset);
	else
		NetStatsElem.LocationError = VSize(IGPlus_AdjustLocationOffset * AdjustAlpha);
	NetStatsElem.UnconfirmedTime = (Level.TimeSeconds - CurrentTimeStamp) / Level.TimeDilation;

	// The server steps once per move, at the move's last timestamp and view.
	// A shot predicted on this frame must end the move here, or the server
	// fires a few ms later with a later view and its refire cadence drifts
	// behind the client's for as long as fire is held (merges at >200 fps).
	if (bDetLocalShot)
		bForcePacketSplit = true;

	if (RealDelta < TimeBetweenNetUpdates - ClientUpdateTime
		&& CanMergeMove(NewMove, OldAccel))
		return;

	bForcePacketSplit = false;
	ClientUpdateTime = FClamp(RealDelta - TimeBetweenNetUpdates + ClientUpdateTime, -TimeBetweenNetUpdates, TimeBetweenNetUpdates);
	if ( SavedMoves == None )
		SavedMoves = PendingMove;
	else
		LastMove.NextMove = PendingMove;
	PendingMove = None;

	SendSavedMove(NewMove, OldMove);

	// Not in demo playback: the recording holds our weapon's anims and sounds.
	if (!IGPlus_InDemoPlayback() && IGPlus_ClientWeaponSettled())
	{
		if ( (Weapon == ClientPending) || (Weapon != OldClientWeapon) )
		{
			if ( Weapon.Owner != self ) //Non-respawnable weapon was picked up and Owner wasn't replicated yet
				Weapon.SetOwner(self); //Simulate owner change locally
			if ( Weapon.IsInState('ClientActive') )
				AnimEnd();
			else
				Weapon.GotoState('ClientActive');
			if ( (Weapon != ClientPending) && (myHUD != None) && myHUD.IsA('ChallengeHUD') )
				ChallengeHUD(myHUD).WeaponNameFade = 1.3;
			if ( (Weapon != OldClientWeapon) && (OldClientWeapon != None) )
				OldClientWeapon.GotoState('');

			ClientPending = None;
			IGPlus_DetClientSwitchPending = none;
			bNeedActivate = false;
		}
		else
		{
			Weapon.GotoState('');
			Weapon.TweenToStill();
		}
	}
	OldClientWeapon = Weapon;
}

function SendSavedMove(IGPlus_SavedMove Move, optional IGPlus_SavedMove OldMove) {
	local int MiscData, MiscData2;
	local int MoveDeltaTime;
	local vector RelLoc;
	local int OldMoveData1, OldMoveData2;
	local int ViewPacked;
	local float RedoTS;
	local int RedoData;
	local int PRTData;
	local WeaponSettingsRepl WS;

	if (Move.bPressedJump) bJumpStatus = !bJumpStatus;

	if (Base == none)
		RelLoc = Location;
	else
		RelLoc = Location - Base.Location;

	MoveDeltaTime or_eq IGPlus_PackDeltaEye(Move.Delta, Move.IGPlus_ShotEye);
	if (Move.bDetReady) MoveDeltaTime or_eq 0x01;
	MoveDeltaTime or_eq (Move.DetWeaponIndex & 0x07) << 1;
	MoveDeltaTime or_eq (Move.DetChargeData & 0x0F) << 4;

	                   MiscData or_eq (TlocCounter << 26);
	if (Move.bFire)    MiscData or_eq 0x02000000;
	if (Move.bAltFire) MiscData or_eq 0x01000000;
	                   MiscData or_eq ((Move.IGPlus_MergeCount & 0x1F) << 19);
	if (Move.bRun)     MiscData or_eq 0x00040000;
	if (Move.bDuck)    MiscData or_eq 0x00020000;
	if (bJumpStatus)   MiscData or_eq 0x00010000;
	                   MiscData or_eq (int(Physics) << 12);
	                   MiscData or_eq (int(Move.DodgeMove) << 8);
	                   MiscData or_eq ((Rotation.Roll >> 8) & 0xFF);

	if (Move.JumpIndex > 0)       MiscData2 or_eq (Move.JumpIndex & 0x1F);
	if (Move.DodgeIndex > 0)      MiscData2 or_eq (Move.DodgeIndex & 0x1F) << 5;
	if (Move.RunChangeIndex > 0)  MiscData2 or_eq (Move.RunChangeIndex & 0x1F) << 10;
	if (Move.DuckChangeIndex > 0) MiscData2 or_eq (Move.DuckChangeIndex & 0x1F) << 15;
	if (Move.AltFireIndex > 0)    MiscData2 or_eq (Move.AltFireIndex & 0x1F) << 20;
	if (Move.FireIndex > 0)       MiscData2 or_eq (Move.FireIndex & 0x1F) << 25;
	if (Move.bForceAltFire)       MiscData2 or_eq 0x40000000;
	if (Move.bForceFire)          MiscData2 or_eq 0x80000000;


	if (OldMove != none && OldMove != Move) {
		                          OldMoveData1 = Min(0x3FF, int((Move.TimeStamp - OldMove.TimeStamp) * 1000.0));
		if (OldMove.bPressedJump) OldMoveData1 or_eq 0x0400;
		if (OldMove.bRun)         OldMoveData1 or_eq 0x0800;
		if (OldMove.bDuck)        OldMoveData1 or_eq 0x1000;
		                          OldMoveData1 or_eq (int(OldMove.DodgeMove) << 13);
		                          OldMoveData1 or_eq (int(OldMove.Acceleration.X * 10.0) << 16);
		                          OldMoveData2 or_eq (int(OldMove.Acceleration.Y * 10.0) & 0xFFFF);
		                          OldMoveData2 or_eq (int(OldMove.Acceleration.Z * 10.0) << 16);
	}

	ViewPacked = ((Move.IGPlus_SavedViewRotation.Pitch & 0xFFFF) << 16) | (Move.IGPlus_SavedViewRotation.Yaw & 0xFFFF);
	if (bTraceInput && IGPlus_InputLogFile != none)
		IGPlus_InputLogFile.LogSavedMove(Move);

	// Deterministic translocator: a lost packet must not lose a throw, recall
	// or translocate the client already showed. The last action rides along
	// again until the server is past its move (it runs each action once).
	// DetRedoData: bits 0-2 the action (bit 2: refused), 8-31 its move's view (12 bits each).
	if (IGPlus_DetRedoAction != 0 && (IGPlus_DetRedoTloc == none || IGPlus_DetRedoTloc.bDeleteMe
		|| IGPlus_DetRedoTloc.IGPlus_DetServer.MoveTS >= IGPlus_DetRedoTS || Move.TimeStamp - IGPlus_DetRedoTS > 1.0))
		IGPlus_DetRedoAction = 0;
	if (IGPlus_DetRedo2Action != 0 && (IGPlus_DetRedoTloc == none || IGPlus_DetRedoTloc.bDeleteMe
		|| IGPlus_DetRedoTloc.IGPlus_DetServer.MoveTS >= IGPlus_DetRedo2TS || Move.TimeStamp - IGPlus_DetRedo2TS > 1.0))
		IGPlus_DetRedo2Action = 0;
	if (IGPlus_DetRedoAction != 0 && IGPlus_DetRedoTS < Move.TimeStamp) {
		RedoTS = IGPlus_DetRedoTS;
		RedoData = IGPlus_DetPackRedo(IGPlus_DetRedoAction, IGPlus_DetRedoView);
	}
	// The spot of a throw rides along while that throw does.
	if (IGPlus_DetRedoSpotTS != 0.0
		&& !(IGPlus_DetRedoAction != 0 && IGPlus_DetRedoTS == IGPlus_DetRedoSpotTS)
		&& !(IGPlus_DetRedo2Action != 0 && IGPlus_DetRedo2TS == IGPlus_DetRedoSpotTS))
		IGPlus_DetRedoSpotTS = 0.0;
	// The action before that one, and the spot, go ahead of the move in a call of their own.
	if (IGPlus_DetRedo2Action != 0)
		xxServerDetRedoMore(IGPlus_DetRedo2TS, IGPlus_DetPackRedo(IGPlus_DetRedo2Action, IGPlus_DetRedo2View),
			IGPlus_DetRedoSpotTS, IGPlus_DetRedoSpot.X, IGPlus_DetRedoSpot.Y, IGPlus_DetRedoSpot.Z);
	else if (IGPlus_DetRedoSpotTS != 0.0)
		xxServerDetRedoMore(0.0, 0, IGPlus_DetRedoSpotTS, IGPlus_DetRedoSpot.X, IGPlus_DetRedoSpot.Y, IGPlus_DetRedoSpot.Z);
	if (Move.DetChargeData <= 7 && (Move.DetChargeData & 3) != 0 && Move.DetWeaponIndex == IGPLUS_DetWEAPON_None
		&& ST_Translocator(Move.IGPlus_SavedWeapon) != none) {
		// The last action keeps riding along until the server is past it:
		// this one's own move may be lost with it.
		if (IGPlus_DetRedoAction != 0) {
			IGPlus_DetRedo2Action = IGPlus_DetRedoAction;
			IGPlus_DetRedo2TS = IGPlus_DetRedoTS;
			IGPlus_DetRedo2View = IGPlus_DetRedoView;
		}
		IGPlus_DetRedoAction = Move.DetChargeData;
		IGPlus_DetRedoTS = Move.TimeStamp;
		if ((Move.DetChargeData & 3) == 1) {
			IGPlus_DetRedoSpotTS = Move.TimeStamp;
			IGPlus_DetRedoSpot = IGPlus_DetThrowLoc;
		}
		IGPlus_DetRedoTloc = ST_Translocator(Move.IGPlus_SavedWeapon);
		IGPlus_DetRedoView = ViewPacked;
	}

	// Precise Rewind Time: only moves that can shoot carry what we saw, and
	// those while our own deterministic disc flies: the server stops its copy
	// on the other players where we saw them (ST_TranslocatorTarget.IGPlus_DetRewoundStop).
	WS = GetWeaponSettings();
	if ((Move.bFire || Move.bAltFire
			|| (IGPlus_DetTloc != none && IGPlus_DetTloc.IGPlus_bDetOut && IGPlus_DetTloc.IGPlus_DetLocalDisc != none
				&& IGPlus_DetTloc.IGPlus_DetLocalDisc.Physics != PHYS_None))
		&& WS != none
		&& WS.bEnablePingCompensation && IGPlus_EnableSnapshotInterpolation == false)
		PRTData = Move.IGPlus_PRTData;

	xxServerMove(
		Move.TimeStamp,
		MoveDeltaTime,
		Move.Acceleration * 10.0,
		RelLoc.X,
		RelLoc.Y,
		RelLoc.Z,
		Velocity,
		MiscData,
		MiscData2,
		ViewPacked,
		Base,
		OldMoveData1,
		OldMoveData2,
		RedoTS,
		RedoData,
		PRTData
	);

	debugServerMoveCallsSent += 1;
}

simulated function bool xxUsingDefaultWeapon()
{
	local int x;
	local name W;

	if (Weapon == None || zzUTPure == None)
		return false;

	if (Weapon.IsA(zzDefaultWeapon))
		return true;

	for (x = 0; x < 8; x++)
	{
		W = zzUTPure.zzDefaultWeapons[x];
		if (W == '')
			continue;
		if (Weapon.Class.Name == W)
			return true;
	}

	return false;
}

exec function ThrowWeapon()
{
	if( Weapon==None || (Weapon.Class==Level.Game.BaseMutator.MutatedDefaultWeapon())
		|| !Weapon.bCanThrow || (IGPlus_UseFastWeaponSwitch == false && Weapon.IsInState('Idle') == false) )
		return;

	// Switch guard covers the toss; held fire resuming on the next weapon is stock.
	IGPlus_MarkDeterministicSwitchGuard();
	bForcePacketSplit = true;
	bFire = 0;
	bAltFire = 0;
	bJustFired = false;
	bJustAltFired = false;

	Weapon.Velocity = Normal(Vector(ViewRotation) * vect(1,1,0)) * zzThrowVelocity + vect(0,0,220);
	Weapon.bTossedOut = true;
	TossWeapon();
	if ( Weapon == None )
		SwitchToBestWeapon();
}

// toss out the weapon currently held
function TossWeapon()
{
	local vector X,Y,Z;
	if ( Weapon == None )
		return;
	GetAxes(Rotation.Yaw*rot(0,1,0),X,Y,Z);
	Weapon.DropFrom(Location + (CollisionRadius+Weapon.CollisionRadius) * X - 0.5 * CollisionRadius * Y);
}


function string forcedModelToString(int fm) {
	switch(fm) {
		case 0:
			return "Class: Female Commando, Skin: Aphex, Face: Idina";
		case 1:
			return "Class: Female Commando, Skin: Commando, Face: Anna";
		case 2:
			return "Class: Female Commando, Skin: Mercenary, Face: Jayce";
		case 3:
			return "Class: Female Commando, Skin: Necris, Face: Cryss";
		case 4:
			return "Class: Female Soldier, Skin: Marine, Face: Annaka";
		case 5:
			return "Class: Female Soldier, Skin: Metal Guard, Face: Isis";
		case 6:
			return "Class: Female Soldier, Skin: Soldier, Face: Lauren";
		case 7:
			return "Class: Female Soldier, Skin: Venom, Face: Athena";
		case 8:
			return "Class: Female Soldier, Skin: War Machine, Face: Cathode";
		case 9:
			return "Class: Male Commando, Skin: Commando, Face: Blake";
		case 10:
			return "Class: Male Commando, Skin: Mercenary, Face: Boris";
		case 11:
			return "Class: Male Commando, Skin: Necris, Face: Grail";
		case 12:
			return "Class: Male Soldier, Skin: Marine, Face: Malcolm";
		case 13:
			return "Class: Male Soldier, Skin: Metal Guard, Face: Drake";
		case 14:
			return "Class: Male Soldier, Skin: RawSteel, Face: Arkon";
		case 15:
			return "Class: Male Soldier, Skin: Soldier, Face: Brock";
		case 16:
			return "Class: Male Soldier, Skin: War Machine, Face: Matrix";
		case 17:
			return "Class: Boss, Skin: Boss, Face: Xan";
	}
}

// Debug data on or off, with one line to confirm it. On collects the debug
// lines and writes them to a file in Logs. ClientSettings.DebugDataDisplay
// decides whether the console or the screen shows them too.
exec function enableDebugData(bool b) {
	bDrawDebugData = b;
	if (b) {
		if (IGPlus_DebugLogFile == none)
			IGPlus_DebugLogFile = Spawn(class'IGPlus_DebugLogFile');
		if (IGPlus_DebugLogFile != none) {
			IGPlus_DebugLogFile.StartLog();
			ClientMessage("Debug data: on, written to Logs/"$IGPlus_DebugLogFile.FileName$".log");
		} else {
			ClientMessage("Debug data: on");
		}
	} else {
		if (IGPlus_DebugLogFile != none) {
			ClientMessage("Debug data: off, saved Logs/"$IGPlus_DebugLogFile.FileName$".log");
			IGPlus_DebugLogFile.Destroy();
			IGPlus_DebugLogFile = none;
		} else {
			ClientMessage("Debug data: off");
		}
	}
}

exec function EnableHitSound(bool b) {
	if (IGPlus_RefuseForced("bEnableHitSounds", "hit sounds"))
		return;
	Settings.bEnableHitSounds = b;
	IGPlus_SaveSettings();
	if (b) {
		ClientMessage("HitSound: on");
	} else {
		ClientMessage("HitSound: off");
	}
}

exec function EnableTeamHitSound(bool b) {
	if (IGPlus_RefuseForced("bEnableTeamHitSounds", "team hit sounds"))
		return;
	Settings.bEnableTeamHitSounds = b;
	IGPlus_SaveSettings();
	if (b) {
		ClientMessage("Team HitSound: on");
	} else {
		ClientMessage("Team HitSound: off");
	}
}

exec function setForcedSkins(int maleSkin, int femaleSkin) {
	local bool error;
	if (IGPlus_RefuseForced("desiredSkin", "forced skins") || IGPlus_RefuseForced("desiredSkinFemale", "forced skins"))
		return;
	if (maleSkin < -1 || maleSkin == 0 || maleSkin > 18) {
		ClientMessage("Invalid maleSkin, please input a value between 1 and 18, or -1 to disable");
		error = true;
	}
	if (femaleSkin < -1 || femaleSkin == 0 || femaleSkin > 18) {
		ClientMessage("Invalid femaleSkin, please input a value between 1 and 18, or -1 to disable");
		error = true;
	}

	if (error) {
		ClientMessage("Usage: setForcedSkins <maleSkin> <femaleSkin>");
		return;
	}

	Settings.desiredSkin = maleSkin - 1;
	Settings.desiredSkinFemale = femaleSkin - 1;
	IGPlus_SaveSettings();
	ClientMessage("Forced enemy skin set!");
}

exec function setForcedTeamSkins(int maleSkin, int femaleSkin) {
	local bool error;
	if (IGPlus_RefuseForced("desiredTeamSkin", "forced team skins") || IGPlus_RefuseForced("desiredTeamSkinFemale", "forced team skins"))
		return;
	if (maleSkin < -1 || maleSkin == 0 || maleSkin > 18) {
		ClientMessage("Invalid maleSkin, please input a value between 1 and 18, or -1 to disable");
		error = true;
	}
	if (femaleSkin < -1 || femaleSkin == 0 || femaleSkin > 18) {
		ClientMessage("Invalid femaleSkin, please input a value between 1 and 18, or -1 to disable");
		error = true;
	}

	if (error) {
		ClientMessage("Usage: setForcedTeamSkins <maleSkin> <femaleSkin>");
		return;
	}

	Settings.desiredTeamSkin = maleSkin - 1;
	Settings.desiredTeamSkinFemale = femaleSkin - 1;
	IGPlus_SaveSettings();
	ClientMessage("Forced team skin set!");
}

exec function SetHitSound(byte hs) {
	if (IGPlus_RefuseForced("SelectedHitSound", "hit sound"))
		return;
	if (hs >= 0 && hs < 16) {
		Settings.SelectedHitSound = hs;
		IGPlus_SaveSettings();
		ClientMessage("HitSound set!");
	} else {
		ClientMessage("Please input a value from 0 to 15");
	}
}

exec function SetTeamHitSound(byte hs) {
	if (IGPlus_RefuseForced("SelectedTeamHitSound", "team hit sound"))
		return;
	if (hs >= 0 && hs < 16) {
		Settings.SelectedTeamHitSound = hs;
		IGPlus_SaveSettings();
		ClientMessage("Team HitSound set!");
	} else {
		ClientMessage("Please input a value from 0 to 15");
	}
}

exec function EnableClientSideAnimations() {
    local string ForcedValue;
    local string UpdatedSettings, ForcedSettingsInfo;
    local bool bMadeChanges;

    // --- Bio ---
    ForcedValue = GetForcedSettingValue("bBioUseClientSideAnimations");
    if (ForcedValue == "") { // Not forced
        if (!Settings.bBioUseClientSideAnimations) { // Check if already enabled
            Settings.bBioUseClientSideAnimations = true;
            ClientWeaponSettingsData.bBioUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Bio,";
            bMadeChanges = true;
        }
    } else { // Forced
        ForcedSettingsInfo = ForcedSettingsInfo $ " Bio (Forced:" $ ForcedValue $ "),";
    }

    // --- Shock Beam---
    ForcedValue = GetForcedSettingValue("bShockBeamUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bShockBeamUseClientSideAnimations) {
            Settings.bShockBeamUseClientSideAnimations = true;
            ClientWeaponSettingsData.bShockBeamUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Shock Beam,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Shock Beam (Forced:" $ ForcedValue $ "),";
    }

	// --- Shock Projectile ---
    ForcedValue = GetForcedSettingValue("bShockProjectileUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bShockProjectileUseClientSideAnimations) {
            Settings.bShockProjectileUseClientSideAnimations = true;
            ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Shock Projectile,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Shock Projectile (Forced:" $ ForcedValue $ "),";
    }

    // --- Pulse ---
    ForcedValue = GetForcedSettingValue("bPulseUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bPulseUseClientSideAnimations) {
            Settings.bPulseUseClientSideAnimations = true;
            ClientWeaponSettingsData.bPulseUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Pulse,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Pulse (Forced:" $ ForcedValue $ "),";
    }

    // --- Ripper ---
    ForcedValue = GetForcedSettingValue("bRipperUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bRipperUseClientSideAnimations) {
            Settings.bRipperUseClientSideAnimations = true;
            ClientWeaponSettingsData.bRipperUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Ripper,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Ripper (Forced:" $ ForcedValue $ "),";
    }

	// --- Flak ---
    ForcedValue = GetForcedSettingValue("bFlakUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bFlakUseClientSideAnimations) {
            Settings.bFlakUseClientSideAnimations = true;
            ClientWeaponSettingsData.bFlakUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Flak,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Flak (Forced:" $ ForcedValue $ "),";
    }

	// --- Rocket ---
    ForcedValue = GetForcedSettingValue("bRocketUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bRocketUseClientSideAnimations) {
            Settings.bRocketUseClientSideAnimations = true;
            ClientWeaponSettingsData.bRocketUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Rocket,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Rocket (Forced:" $ ForcedValue $ "),";
    }

    // --- Sniper ---
    ForcedValue = GetForcedSettingValue("bSniperUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bSniperUseClientSideAnimations) {
            Settings.bSniperUseClientSideAnimations = true;
            ClientWeaponSettingsData.bSniperUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Sniper,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Sniper (Forced:" $ ForcedValue $ "),";
    }

	// --- Translocator ---
    ForcedValue = GetForcedSettingValue("bTranslocatorUseClientSideAnimations");
    if (ForcedValue == "") {
        if (!Settings.bTranslocatorUseClientSideAnimations) {
            Settings.bTranslocatorUseClientSideAnimations = true;
            ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations = true;
            UpdatedSettings = UpdatedSettings $ " Translocator,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Translocator (Forced:" $ ForcedValue $ "),";
    }

    // --- Report Results ---
    if (bMadeChanges) {
        IGPlus_SaveSettings();
        if (Right(UpdatedSettings, 1) == ",")
            UpdatedSettings = Left(UpdatedSettings, Len(UpdatedSettings)-1);
        ClientMessage("Enabled client-side animations for:" @ UpdatedSettings, 'IGPlus');
    } else if (ForcedSettingsInfo == "") {
         ClientMessage("All client-side animations were already enabled.", 'IGPlus');
    }

    if (ForcedSettingsInfo != "") {
        if (Right(ForcedSettingsInfo, 1) == ",")
            ForcedSettingsInfo = Left(ForcedSettingsInfo, Len(ForcedSettingsInfo)-1);
        ClientMessage("Could not enable (server forced):" @ ForcedSettingsInfo, 'IGPlus');
    }
}

exec function DisableClientSideAnimations() {
    local string ForcedValue;
    local string UpdatedSettings, ForcedSettingsInfo;
    local bool bMadeChanges;

    // --- Bio ---
    ForcedValue = GetForcedSettingValue("bBioUseClientSideAnimations");
    if (ForcedValue == "") { // Not forced
        if (Settings.bBioUseClientSideAnimations) { // Check if already disabled
            Settings.bBioUseClientSideAnimations = false;
            ClientWeaponSettingsData.bBioUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Bio,";
            bMadeChanges = true;
        }
    } else { // Forced
        ForcedSettingsInfo = ForcedSettingsInfo $ " Bio (Forced:" $ ForcedValue $ "),";
    }

    // --- Shock Beam ---
    ForcedValue = GetForcedSettingValue("bShockBeamUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bShockBeamUseClientSideAnimations) {
            Settings.bShockBeamUseClientSideAnimations = false;
            ClientWeaponSettingsData.bShockBeamUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Shock Beam,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Shock Beam (Forced:" $ ForcedValue $ "),";
    }

	// --- Shock Projectile ---
    ForcedValue = GetForcedSettingValue("bShockProjectileUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bShockProjectileUseClientSideAnimations) {
            Settings.bShockProjectileUseClientSideAnimations = false;
            ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Shock Projectile,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Shock Projectile (Forced:" $ ForcedValue $ "),";
    }

    // --- Pulse ---
    ForcedValue = GetForcedSettingValue("bPulseUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bPulseUseClientSideAnimations) {
            Settings.bPulseUseClientSideAnimations = false;
            ClientWeaponSettingsData.bPulseUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Pulse,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Pulse (Forced:" $ ForcedValue $ "),";
    }

    // --- Ripper ---
    ForcedValue = GetForcedSettingValue("bRipperUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bRipperUseClientSideAnimations) {
            Settings.bRipperUseClientSideAnimations = false;
            ClientWeaponSettingsData.bRipperUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Ripper,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Ripper (Forced:" $ ForcedValue $ "),";
    }

	// --- Flak ---
    ForcedValue = GetForcedSettingValue("bFlakUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bFlakUseClientSideAnimations) {
            Settings.bFlakUseClientSideAnimations = false;
            ClientWeaponSettingsData.bFlakUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Flak,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Flak (Forced:" $ ForcedValue $ "),";
    }

	// --- Rocket ---
    ForcedValue = GetForcedSettingValue("bRocketUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bRocketUseClientSideAnimations) {
            Settings.bRocketUseClientSideAnimations = false;
            ClientWeaponSettingsData.bRocketUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Rocket,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Rocket (Forced:" $ ForcedValue $ "),";
    }

    // --- Sniper ---
    ForcedValue = GetForcedSettingValue("bSniperUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bSniperUseClientSideAnimations) {
            Settings.bSniperUseClientSideAnimations = false;
            ClientWeaponSettingsData.bSniperUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Sniper,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Sniper (Forced:" $ ForcedValue $ "),";
    }

	// --- Translocator ---
    ForcedValue = GetForcedSettingValue("bTranslocatorUseClientSideAnimations");
    if (ForcedValue == "") {
        if (Settings.bTranslocatorUseClientSideAnimations) {
            Settings.bTranslocatorUseClientSideAnimations = false;
            ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations = false;
            UpdatedSettings = UpdatedSettings $ " Translocator,";
            bMadeChanges = true;
        }
    } else {
        ForcedSettingsInfo = ForcedSettingsInfo $ " Translocator (Forced:" $ ForcedValue $ "),";
    }

    // --- Report Results ---
    if (bMadeChanges) {
        IGPlus_SaveSettings();
        if (Right(UpdatedSettings, 1) == ",")
            UpdatedSettings = Left(UpdatedSettings, Len(UpdatedSettings)-1);
        ClientMessage("Disabled client-side animations for:" @ UpdatedSettings, 'IGPlus');
    } else if (ForcedSettingsInfo == "") {
         ClientMessage("All client-side animations were already disabled.", 'IGPlus');
    }

    if (ForcedSettingsInfo != "") {
        if (Right(ForcedSettingsInfo, 1) == ",")
            ForcedSettingsInfo = Left(ForcedSettingsInfo, Len(ForcedSettingsInfo)-1);
        ClientMessage("Could not disable (server forced):" @ ForcedSettingsInfo, 'IGPlus');
    }
}
// Helper function to update the replicated weapon settings struct
simulated function UpdateReplicatedWeaponSetting(string Key, bool bValue) {
    if (Key ~= "bBioUseClientSideAnimations") {
        ClientWeaponSettingsData.bBioUseClientSideAnimations = bValue;
    } else if (Key ~= "bShockBeamUseClientSideAnimations") {
        ClientWeaponSettingsData.bShockBeamUseClientSideAnimations = bValue;
    } else if (Key ~= "bShockProjectileUseClientSideAnimations") {
        ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations = bValue;
    } else if (Key ~= "bPredictiveShockCombos") {
        ClientWeaponSettingsData.bPredictiveShockCombos = bValue;
    } else if (Key ~= "bPulseUseClientSideAnimations") {
        ClientWeaponSettingsData.bPulseUseClientSideAnimations = bValue;
    } else if (Key ~= "bRipperUseClientSideAnimations") {
        ClientWeaponSettingsData.bRipperUseClientSideAnimations = bValue;
    } else if (Key ~= "bFlakUseClientSideAnimations") {
        ClientWeaponSettingsData.bFlakUseClientSideAnimations = bValue;
    } else if (Key ~= "bRocketUseClientSideAnimations") {
        ClientWeaponSettingsData.bRocketUseClientSideAnimations = bValue;
    } else if (Key ~= "bSniperUseClientSideAnimations") {
        ClientWeaponSettingsData.bSniperUseClientSideAnimations = bValue;
    } else if (Key ~= "bTranslocatorUseClientSideAnimations") {
        ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations = bValue;
    } else if (Key ~= "bPredictedSwitching") {
        ClientWeaponSettingsData.bNoPredictedSwitching = !bValue;
    } else if (Key ~= "bPredictedTranslocation") {
        ClientWeaponSettingsData.bNoPredictedTranslocation = !bValue;
    } else if (Key ~= "bPredictedDiscBoost") {
        ClientWeaponSettingsData.bNoPredictedDiscBoost = !bValue;
    } else if (Key ~= "bReduceEyeHeightInAir") {
        ClientWeaponSettingsData.bReduceEyeHeightInAir = bValue;
    }
}

// Predictions the server allows and the player didn't turn off. The same
// answer on both machines (ClientWeaponSettingsData reaches the server).
simulated function bool IGPlus_PredictsSwitching() {
	return IGPlus_PredictedSwitching && !ClientWeaponSettingsData.bNoPredictedSwitching;
}

simulated function bool IGPlus_PredictsTranslocation() {
	return IGPlus_PredictedTranslocation && !ClientWeaponSettingsData.bNoPredictedTranslocation;
}

simulated function bool IGPlus_PredictsDiscBoost() {
	return IGPlus_PredictedDiscBoost && !ClientWeaponSettingsData.bNoPredictedDiscBoost;
}

simulated function string GetForcedSettingValue(string Key) {
    local int i;
    if (IGPlus_ForcedSettings_Applied) {
        for (i = 0; i < IGPlus_ForcedSettings_Counter; ++i) {
            if (IGPlus_ForcedSettings[i].Key ~= Key) {
                // Return the forced value if the key is found and settings are applied
                return IGPlus_ForcedSettings[i].NewValue;
            }
        }
    }
    // Return an empty string if the setting is not forced or not found
    return "";
}

exec function BioClientSideAnimations(bool b) {
	local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bBioUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Bio animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bBioUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Bio client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Bio client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bBioUseClientSideAnimations = b;
	ClientWeaponSettingsData.bBioUseClientSideAnimations = b;
	
	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Bio client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Bio client-side animations disabled!", 'IGPlus');
}

exec function ShockBeamClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bShockBeamUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Shock Beam animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bShockBeamUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Shock Beam client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Shock Beam client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bShockBeamUseClientSideAnimations = b;
	ClientWeaponSettingsData.bShockBeamUseClientSideAnimations = b;

	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Shock Beam client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Shock Beam client-side animations disabled!", 'IGPlus');
}

exec function ShockProjectileClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bShockProjectileUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Shock Projectile animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bShockProjectileUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Shock Projectile client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Shock Projectile client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bShockProjectileUseClientSideAnimations = b;
	ClientWeaponSettingsData.bShockProjectileUseClientSideAnimations = b;

	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Shock Projectile client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Shock Projectile client-side animations disabled!", 'IGPlus');
}

exec function PulseClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bPulseUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Pulse animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

    if (Settings.bPulseUseClientSideAnimations == b) {
        if (b)
            ClientMessage("Pulse client-side animations are already enabled.", 'IGPlus');
        else
            ClientMessage("Pulse client-side animations are already disabled.", 'IGPlus');
        return;
    }

	Settings.bPulseUseClientSideAnimations = b;
	ClientWeaponSettingsData.bPulseUseClientSideAnimations = b;
	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Pulse client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Pulse client-side animations disabled!", 'IGPlus');
}

exec function RipperClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bRipperUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Ripper animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bRipperUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Ripper client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Ripper client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bRipperUseClientSideAnimations = b;
	ClientWeaponSettingsData.bRipperUseClientSideAnimations = b;
	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Ripper client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Ripper client-side animations disabled!", 'IGPlus');
}

exec function FlakClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bFlakUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Flak animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bFlakUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Flak client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Flak client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bFlakUseClientSideAnimations = b;
	ClientWeaponSettingsData.bFlakUseClientSideAnimations = b;

	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Flak client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Flak client-side animations disabled!", 'IGPlus');
}

exec function RocketClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bRocketUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Rocket animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bRocketUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Rocket client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Rocket client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bRocketUseClientSideAnimations = b;
	ClientWeaponSettingsData.bRocketUseClientSideAnimations = b;

	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Rocket client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Rocket client-side animations disabled!", 'IGPlus');
}


exec function SniperClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bSniperUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Sniper animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bSniperUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Sniper client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Sniper client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bSniperUseClientSideAnimations = b;
	ClientWeaponSettingsData.bSniperUseClientSideAnimations = b;

	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Sniper client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Sniper client-side animations disabled!", 'IGPlus');
}

exec function TranslocatorClientSideAnimations(bool b) {
    local string ForcedValue;

    ForcedValue = GetForcedSettingValue("bTranslocatorUseClientSideAnimations");
	if (ForcedValue != "") {
        ClientMessage("Cannot change Translocator animations: Setting is forced by the server to '" $ ForcedValue $ "'.", 'IGPlus');
        return;
    }

	if (Settings.bTranslocatorUseClientSideAnimations == b) {
		if (b)
			ClientMessage("Translocator client-side animations are already enabled.", 'IGPlus');
		else
			ClientMessage("Translocator client-side animations are already disabled.", 'IGPlus');
		return;
	}

	Settings.bTranslocatorUseClientSideAnimations = b;
	ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations = b;

	IGPlus_SaveSettings();

	if (b)
		ClientMessage("Translocator client-side animations enabled!", 'IGPlus');
	else
		ClientMessage("Translocator client-side animations disabled!", 'IGPlus');
}

exec function setShockBeam(int sb) {
	if (IGPlus_RefuseForced("cShockBeam", "shock beam"))
		return;
	if (sb > 0 && sb <= 4) {
		Settings.cShockBeam = sb;
		IGPlus_SaveSettings();
		ClientMessage("Shock beam set!");
	} else
		ClientMessage("Please input a value between 1 and 4");
}

exec function setBeamScale(float bs) {
	if (IGPlus_RefuseForced("BeamScale", "beam scale"))
		return;
	if (bs >= 0.1 && bs <= 1.0) {
		Settings.BeamScale = bs;
		IGPlus_SaveSettings();
		ClientMessage("Beam scale set!");
	} else
		ClientMessage("Please input a value between 0.1 and 1.0");
}

exec function listSkins() {
	ClientMessage("Skin List:");
	ClientMessage("Input the desired number with the SetForcedSkins command");
	ClientMessage("-1 - Dont force this type of skin");
	ClientMessage("1 - Class: Female Commando, Skin: Aphex, Face: Idina");
	ClientMessage("2 - Class: Female Commando, Skin: Commando, Face: Anna");
	ClientMessage("3 - Class: Female Commando, Skin: Mercenary, Face: Jayce");
	ClientMessage("4 - Class: Female Commando, Skin: Necris, Face: Cryss");
	ClientMessage("5 - Class: Female Soldier, Skin: Marine, Face: Annaka");
	ClientMessage("6 - Class: Female Soldier, Skin: Metal Guard, Face: Isis");
	ClientMessage("7 - Class: Female Soldier, Skin: Soldier, Face: Lauren");
	ClientMessage("8 - Class: Female Soldier, Skin: Venom, Face: Athena");
	ClientMessage("9 - Class: Female Soldier, Skin: War Machine, Face: Cathode");
	ClientMessage("10 - Class: Male Commando, Skin: Commando, Face: Blake");
	ClientMessage("11 - Class: Male Commando, Skin: Mercenary, Face: Boris");
	ClientMessage("12 - Class: Male Commando, Skin: Necris, Face: Grail");
	ClientMessage("13 - Class: Male Soldier, Skin: Marine, Face: Malcolm");
	ClientMessage("14 - Class: Male Soldier, Skin: Metal Guard, Face: Drake");
	ClientMessage("15 - Class: Male Soldier, Skin: RawSteel, Face: Arkon");
	ClientMessage("16 - Class: Male Soldier, Skin: Soldier, Face: Brock");
	ClientMessage("17 - Class: Male Soldier, Skin: War Machine, Face: Matrix");
	ClientMessage("18 - Class: Boss, Skin: Boss, Face: Xan");
}

exec function MyIGSettings() {
	local string Dump;
	local int lf;
	Dump = Settings.DumpSettings();

	lf = InStr(Dump, Chr(10));
	while(lf >= 0) {
		ClientMessage(Left(Dump, lf), 'IGPlus');
		Dump = Mid(Dump, lf+1, Len(Dump));
		lf = InStr(Dump, Chr(10));
	}

	ClientMessage(Dump, 'IGPlus');
}

function xxCalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
	local vector View,HitLocation,HitNormal;
	local float ViewDist;

	CameraRotation = ViewRotation;
	View = vect(1,0,0) >> CameraRotation;
	if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
		ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
	else
		ViewDist = Dist;
	CameraLocation -= (ViewDist - 30) * View;
}

simulated event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

	IGPlus_CameraOffsetDrawn = vect(0,0,0); // set again by IGPlus_ApplyCameraCorrection

	// Only demo playback calls this on a recorded player (udemo following
	// them). Before this was simulated the call was dropped, and udemo showed
	// the pawn's Rotation. Server demos now carry the real view; anything
	// else keeps udemo's values.
	if (Role == ROLE_SimulatedProxy) {
		IGPlus_SDCalcView(CameraRotation);
		return;
	}

	if ( ViewTarget != None )
	{
		ViewActor = ViewTarget;
		CameraLocation = ViewTarget.Location;
		CameraRotation = ViewTarget.Rotation;
		PTarget = Pawn(ViewTarget);
		if ( PTarget != None )
		{
			if ( Level.NetMode == NM_Client )
			{
				if ( PTarget.bIsPlayer ) {
					PTarget.ViewRotation = TargetViewRotation;
				}
				PTarget.EyeHeight = TargetEyeHeight;
				if ( PTarget.Weapon != None )
					PTarget.Weapon.PlayerViewOffset = TargetWeaponViewOffset;
			}
			if ( PTarget.bIsPlayer )
				CameraRotation = PTarget.ViewRotation;
			CameraLocation.Z += PTarget.EyeHeight;
		}
		if ( bBehindView )
			xxCalcBehindView(CameraLocation, CameraRotation, 180);
		return;
	}

	ViewActor = Self;
	CameraLocation = Location;
	CameraLocation.Z += EyeHeight;

	if( bBehindView ) { //up and behind
		xxCalcBehindView(CameraLocation, CameraRotation, 150);
	} else {
		if (zzbRepVRData) {
			// Received data through demo replication.
			CameraRotation.Yaw = zzRepVRYaw;
			CameraRotation.Pitch = zzRepVRPitch;
			CameraRotation.Roll = 0;
			EyeHeight = zzRepVREye;
		} else {
			CameraRotation = ViewRotation;
		}
		CameraLocation += WalkBob;
		IGPlus_ApplyCameraCorrection(CameraLocation);
	}
}

function ViewShake(float DeltaTime)
{
	local int Roll;

	if (shaketimer > 0.0) //shake view
	{
		shaketimer -= DeltaTime;
		if ( verttimer == 0 )
		{
			verttimer = 0.1;
			ShakeVert = -1.1 * maxshake;
		}
		else
		{
			verttimer -= DeltaTime;
			if ( verttimer < 0 )
			{
				verttimer = 0.2 * FRand();
				shakeVert = (2 * FRand() - 1) * maxshake;
			}
		}
		ViewRotation.Roll = ViewRotation.Roll & 65535;
		if (bShakeDir)
		{
			ViewRotation.Roll += Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) || (ViewRotation.Roll < (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll < 32768) && (ViewRotation.Roll > 1.3 * shakemag) )
			{
				ViewRotation.Roll = 1.3 * shakemag;
				bShakeDir = false;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
		else
		{
			ViewRotation.Roll -= Int( 10 * shakemag * FMin(0.1, DeltaTime));
			bShakeDir = (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - (0.5 + FRand()) * shakemag);
			if ( (ViewRotation.Roll > 32768) && (ViewRotation.Roll < 65535 - 1.3 * shakemag) )
			{
				ViewRotation.Roll = 65535 - 1.3 * shakemag;
				bShakeDir = true;
			}
			else if (FRand() < 3 * DeltaTime)
				bShakeDir = !bShakeDir;
		}
	}
	else
	{
		ShakeVert = 0;
		Roll = Utils.RotU2S(ViewRotation.Roll);
		if (Roll > 0) {
			Roll -= Max(Roll, 500) * 10 * FMin(0.1, DeltaTime);
			if (Roll < 0) Roll = 0;
		} else if (Roll < 0) {
			Roll -= Min(Roll, -500) * 10 * FMin(0.1, DeltaTime);
			if (Roll > 0) Roll = 0;
		}
		ViewRotation.Roll = Utils.RotS2U(Roll);
	}
}

function UpdateRotation(float DeltaTime, float maxPitch);

function xxUpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation;
	local float PitchDelta, YawDelta;

	DesiredRotation = ViewRotation; //save old rotation

	PitchDelta = 32.0 * DeltaTime * aLookUp * IGPlus_ZoomToggle_SensitivityFactorY + LookUpFractionalPart;
	ViewRotation.Pitch += int(PitchDelta);
	if (!Settings.bUseOldMouseInput)
		LookUpFractionalPart = PitchDelta - int(PitchDelta);

	ViewRotation.Pitch = Utils.RotS2U(Clamp(Utils.RotU2S(ViewRotation.Pitch), -16384, 16383));

	YawDelta = 32.0 * DeltaTime * aTurn * IGPlus_ZoomToggle_SensitivityFactorX + TurnFractionalPart;
	ViewRotation.Yaw += int(YawDelta);
	if (!Settings.bUseOldMouseInput)
		TurnFractionalPart = YawDelta - int(YawDelta);

	if (bUpdating == false) {
		if (Settings.bDebugMovement && (Abs(PitchDelta) > 1 || Abs(YawDelta) > 1))
			ClientDebugMessage("PitchDelta:"@PitchDelta@"YawDelta:"@YawDelta);

		ViewShake(deltaTime);		// ViewRotation is fuked in here.
		ViewFlash(deltaTime);
	}

	newRotation = Rotation;
	newRotation.Yaw = ViewRotation.Yaw;
	newRotation.Pitch = Utils.RotS2U(Clamp(
		Utils.RotU2S(ViewRotation.Pitch),
		-maxPitch * RotationRate.Pitch,
		maxPitch * RotationRate.Pitch));
	setRotation(newRotation);

	if (!zzbRepVRData)
	{
		xxReplicateVRToDemo(ViewRotation.Yaw, ViewRotation.Pitch, EyeHeight);
		zzbRepVRData = False;		// When xxReplicateVRToDemo is executed, this var is set to true
	}
}

function xxReplicateVRToDemo(int zzYaw, int zzPitch, float zzEye)
{	// This is called before tick in a demo, but in xxUpdateRotation during creating.
	zzRepVRYaw = zzYaw;
	zzRepVRPitch = zzPitch;
	zzRepVREye = zzEye;
	zzbRepVRData = True;
}

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype)
{
	if (Sender == PlayerReplicationInfo)
		super.SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID,broadcasttype);  //lame anti-cheat :P
}

function ServerTaunt(name Sequence )
{
	if (Level.TimeSeconds - zzLastTaunt > 1.0)
	{
		if ( GetAnimGroup(Sequence) == 'Gesture' )
			PlayAnim(Sequence, 0.7, 0.2);
	}
	else
		zzKickReady++;
	zzLastTaunt = Level.TimeSeconds;
}

simulated function bool AdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	local float adjZ, maxZ;

	// This rejects shots where theres geometry going through the collision
	// cylinder. This is possible in networked play where Location is rounded to
	// the nearest Integer for each axis, if rubbing up against really thin
	// walls.
	if (FastTrace(Location, HitLocation) == false)
		return false;

	TraceDir = Normal(TraceDir);
	HitLocation = HitLocation + 0.5 * CollisionRadius * TraceDir;

	maxZ = Location.Z + (1.0 - 0.7 * IGPlus_HitDuckFraction()) * CollisionHeight;
	if ( HitLocation.Z <= maxZ )
		return true;

	if ( TraceDir.Z >= 0 )
		return false;

	adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
	HitLocation.Z = maxZ;
	HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
	HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;

	if ( VSize((HitLocation - Location)*vect(1,1,0)) > CollisionRadius )
		return false;

	return true;
}

simulated function bool ClientAdjustHitLocation(out vector HitLocation, vector TraceDir)
{
	local float adjZ, maxZ;
	local vector delta;

	// This rejects shots where theres geometry going through the collision
	// cylinder. This is possible in networked play where Location is rounded to
	// the nearest Integer for each axis, if rubbing up against really thin
	// walls.
	if (FastTrace(Location, HitLocation) == false)
		return false;

	maxZ = Location.Z + (1.0 - 0.7 * IGPlus_HitDuckFraction()) * CollisionHeight; // default game is 0.25

	if (HitLocation.Z <= maxZ)
		return true;

	if (TraceDir.Z >= 0)
		return false;

	TraceDir = Normal(TraceDir);
	adjZ = (maxZ - HitLocation.Z)/TraceDir.Z;
	HitLocation.Z = maxZ;
	HitLocation.X = HitLocation.X + TraceDir.X * adjZ;
	HitLocation.Y = HitLocation.Y + TraceDir.Y * adjZ;
	delta = (HitLocation - Location) * vect(1,1,0);
	if (delta dot delta > CollisionRadius * CollisionRadius)
		return false;

	return true;
}

simulated function AddVelocity( vector NewVelocity )
{
	if (!bNewNet || Level.NetMode == NM_Client)
		Super.AddVelocity(NewVelocity);
	else if (Level.NetMode != NM_Client)
		ServerAddMomentum(NewVelocity);
}

function ServerAddMomentum(vector Momentum) {
	local vector OldVelocity;

	OldVelocity = Velocity;
	if (Physics == PHYS_Walking)
		Momentum.Z = FMax(Momentum.Z, 0.4 * VSize(Momentum));
	Super.AddVelocity(Momentum);

	if (IGPlus_PushSafeAim && Velocity != OldVelocity)
		IGPlus_PSANotePush(Velocity - OldVelocity);
	// Pushes our client predicts go through IGPlus_SKAddVelocity, not here.
	if (Velocity != OldVelocity)
		IGPlus_PushEaseTS = CurrentTimeStamp;
}

simulated function NN_Momentum( Vector momentum, name DamageType )
{
	local bool bPreventLockdown;		// Avoid the lockdown effect.

	if (DamageType == 'shot' || DamageType == 'zapped')
		bPreventLockdown = true;

	if (Base != None)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));

	if (Mass != 0)
		momentum = momentum/Mass;

	if (!bPreventLockdown)	// FIX BY LordHypnos, http://forums.prounreal.com/viewtopic.php?t=34676&postdays=0&postorder=asc&start=0
		AddVelocity( momentum );
}

final function IGPlus_DamageEvent IGPlus_DamageEvent_Alloc() {
	local IGPlus_DamageEvent DE;

	if (IGPlus_DamageEvent_FreeList == none) {
		DE = Spawn(class'IGPlus_DamageEvent', self);
	} else {
		DE = IGPlus_DamageEvent_FreeList;
		IGPlus_DamageEvent_FreeList = DE.Next;
		DE.Next = none;
	}

	return DE;
}

final function IGPlus_DamageEvent_Free(IGPlus_DamageEvent First, optional IGPlus_DamageEvent Last) {
	if (First == none) return;
	if (Last == none) {
		Last = First;
		while (Last.Next != none)
			Last = Last.Next;
	}

	Last.Next = IGPlus_DamageEvent_FreeList;
	IGPlus_DamageEvent_FreeList = First;
}

final function IGPlus_DamageEvent_Insert(IGPlus_DamageEvent Event) {
	if (IGPlus_DamageEvent_Latest == none) {
		IGPlus_DamageEvent_First = Event;
		IGPlus_DamageEvent_Latest = Event;
	} else {
		IGPlus_DamageEvent_Latest.Next = Event;
		IGPlus_DamageEvent_Latest = Event;
	}
}

final function float IGPlus_DamageEvent_GetHealth() {
	local float CurrentHealth;
	local Inventory I;
	local int Count;

	CurrentHealth += Health;
	for (I = Inventory; I != none; I = I.Inventory) {
		if (I.bIsAnArmor)
			CurrentHealth += I.Charge;

		if (Count++ > 255) break;
	}

	return CurrentHealth;
}

final function IGPlus_DamageEvent_CheckHealth() {
	local float CurrentHealth;

	CurrentHealth = IGPlus_DamageEvent_GetHealth();

	if (IGPlus_DamageEvent_PrevHealth < CurrentHealth) {
		IGPlus_DamageEvent_Free(IGPlus_DamageEvent_First, IGPlus_DamageEvent_Latest);
		IGPlus_DamageEvent_First = none;
		IGPlus_DamageEvent_Latest = none;
	}
}

final function IGPlus_DamageEvent_SaveHealth() {
	IGPlus_DamageEvent_PrevHealth = IGPlus_DamageEvent_GetHealth();
}

final function IGPlus_DamageEvent_Add(PlayerReplicationInfo Enemy, int Damage, name DamageType) {
	local IGPlus_DamageEvent Event;

	Event = IGPlus_DamageEvent_Alloc();

	Event.Enemy = Enemy;
	Event.Damage = Damage;
	Event.DamageType = DamageType;
	Event.TimeStamp = Level.TimeSeconds;

	IGPlus_DamageEvent_Insert(Event);
}

final function IGPlus_DamageEvent_ReportLine(PlayerReplicationInfo Enemy, name DamageType, int Damage, int Merges) {
	if (Enemy == none) return;
	if (DamageType == '') return;
	if (Damage <= 0) return;

	if (Merges > 0)
		ClientMessage(Enemy.PlayerName@DamageType@"(x"$(Merges+1)$")"@Damage);
	else
		ClientMessage(Enemy.PlayerName@DamageType@Damage);
}

final function IGPlus_DamageEvent_SendReport() {
	local IGPlus_DamageEvent DE;

	local int DamageSum;
	local name CurrentType;
	local PlayerReplicationInfo Enemy;
	local int Merges;

	DE = IGPlus_DamageEvent_First;

	while (DE != none) {
		if (DE.Enemy != Enemy || DE.DamageType != CurrentType) {
			IGPlus_DamageEvent_ReportLine(Enemy, CurrentType, DamageSum, Merges);
			DamageSum = DE.Damage;
			CurrentType = DE.DamageType;
			Enemy = DE.Enemy;
			Merges = 0;
		} else { // merge
			DamageSum += DE.Damage;
			Merges += 1;
		}

		DE = DE.Next;
	}

	IGPlus_DamageEvent_ReportLine(Enemy, CurrentType, DamageSum, Merges);

	IGPlus_DamageEvent_Free(IGPlus_DamageEvent_First, IGPlus_DamageEvent_Latest);
	IGPlus_DamageEvent_First = none;
	IGPlus_DamageEvent_Latest = none;
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local int ModifiedDamage1, ModifiedDamage2;

	if ( Role < ROLE_Authority )
	{
		Log(Self@"client damage type"@damageType@"by"@InstigatedBy);
		return;
	}

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if ( InstigatedBy == self )
		momentum *= 0.6;
	if (Mass != 0)
		momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, InstigatedBy);
						// ReduceDamage handles HardCore mode (*1.5) and Damage Scaling (Amp, etc)
	ModifiedDamage1 = actualDamage;		// In team games it also handles team scaling.

	IGPlus_DamageEvent_CheckHealth();

	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') ||
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	ModifiedDamage2 = actualDamage;		// This is post-armor and such.

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );
	if (InstigatedBy != none)
		IGPlus_DamageEvent_Add(InstigatedBy.PlayerReplicationInfo, ModifiedDamage1, DamageType);

	if (IGPlus_SKCapturing && InstigatedBy == self && Health - actualDamage > 0) {
		// Own predicted rocket: the push goes onto the move timeline instead.
		IGPlus_SKCaptured += momentum;
		IGPlus_SKCapturedHit = true;
	} else {
		ServerAddMomentum(momentum);
	}
	Health -= actualDamage;

	IGPlus_DamageEvent_SaveHealth();

	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (InstigatedBy != None) && (InstigatedBy != Self) )
			damageAttitudeTo(InstigatedBy);
		PlayHit(actualDamage, HitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		NextState = '';
		PlayDeathHit(actualDamage, HitLocation, damageType, Momentum);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (InstigatedBy != None) && (InstigatedBy != Self) )
			damageAttitudeTo(InstigatedBy);
		Died(InstigatedBy, damageType, HitLocation);
	}
	else
	{
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

function GiveHealth( int Damage, bbPlayer InstigatedBy, Vector HitLocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local int ModifiedDamage1, ModifiedDamage2;
	local bool bPreventLockdown;		// Avoid the lockdown effect.

	if ( Role < ROLE_Authority )
	{
		Log(Self@"client damage type (GiveHealth)"@damageType@"by"@InstigatedBy);
		return;
	}

	if (InstigatedBy == Self || InstigatedBy.Health <= 0 || Health >= 199)
		return;

	if (DamageType == 'shot' || DamageType == 'zapped')
		bPreventLockdown = true;

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( InstigatedBy == self )
		momentum *= 0.6;
	if (Mass != 0)
		momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, InstigatedBy);
						// ReduceDamage handles HardCore mode (*1.5) and Damage Scaling (Amp, etc)
	ModifiedDamage1 = actualDamage;		// In team games it also handles team scaling.

	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else
			actualDamage = Damage;
	}

	ModifiedDamage2 = actualDamage;		// This is post-armor and such.

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	if (!bPreventLockdown && InstigatedBy != self && (momentum dot momentum) > 0)	// FIX BY LordHypnos, http://forums.prounreal.com/viewtopic.php?t=34676&postdays=0&postorder=asc&start=0
	{
		if (bNewNet)
			AddVelocity( momentum );
		else
			AddVelocity( momentum );
	}
	if (actualDamage > InstigatedBy.Health)
		actualDamage = InstigatedBy.Health;
	if (Health + actualDamage > 199)
		actualDamage = 199 - Health;
	Health += actualDamage;
	InstigatedBy.Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (InstigatedBy.Health > 0)
	{
	}
	else if ( !bAlreadyDead )
	{
		InstigatedBy.NextState = '';
		if ( actualDamage > InstigatedBy.mass )
			InstigatedBy.Health = -1 * actualDamage;
		InstigatedBy.Died(InstigatedBy, damageType, HitLocation);
	}
	else
	{
		if ( InstigatedBy.bIsPlayer )
		{
			InstigatedBy.HidePlayer();
			InstigatedBy.GotoState('Dying');
		}
		else
			InstigatedBy.Destroy();
	}
	MakeNoise(1.0);
}

function StealHealth( int Damage, bbPlayer InstigatedBy, Vector HitLocation,
						Vector momentum, name damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local int ModifiedDamage1, ModifiedDamage2;
	local bool bPreventLockdown;		// Avoid the lockdown effect.

	if ( Role < ROLE_Authority )
	{
		Log(Self@"client damage type (StealHealth)"@damageType@"by"@InstigatedBy);
		return;
	}

	if (InstigatedBy == Self)
		return;

	if (DamageType == 'shot' || DamageType == 'zapped')
		bPreventLockdown = true;

	bAlreadyDead = (Health <= 0);

	if (Physics == PHYS_None)
		SetMovementPhysics();
	if (Physics == PHYS_Walking)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( InstigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, InstigatedBy);
						// ReduceDamage handles HardCore mode (*1.5) and Damage Scaling (Amp, etc)
	ModifiedDamage1 = actualDamage;		// In team games it also handles team scaling.

	if ( bIsPlayer )
	{
		if (ReducedDamageType == 'All') //God mode
			actualDamage = 0;
		else if (Inventory != None) //then check if carrying armor
			actualDamage = Inventory.ReduceDamage(actualDamage, DamageType, HitLocation);
		else
			actualDamage = Damage;
	}
	else if ( (InstigatedBy != None) &&
				(InstigatedBy.IsA(Class.Name) || self.IsA(InstigatedBy.Class.Name)) )
		ActualDamage = ActualDamage * FMin(1 - ReducedDamagePct, 0.35);
	else if ( (ReducedDamageType == 'All') ||
		((ReducedDamageType != '') && (ReducedDamageType == damageType)) )
		actualDamage = float(actualDamage) * (1 - ReducedDamagePct);

	ModifiedDamage2 = actualDamage;		// This is post-armor and such.

	if ( Level.Game.DamageMutator != None )
		Level.Game.DamageMutator.MutatorTakeDamage( ActualDamage, Self, InstigatedBy, HitLocation, Momentum, DamageType );

	if (!bPreventLockdown && InstigatedBy != self && (momentum dot momentum) > 0)	// FIX BY LordHypnos, http://forums.prounreal.com/viewtopic.php?t=34676&postdays=0&postorder=asc&start=0
	{
		if (bNewNet)
			AddVelocity( momentum );
		else
			AddVelocity( momentum );
	}
	if (actualDamage > Health)
		actualDamage = Health;
	Health -= actualDamage;
	InstigatedBy.Health += actualDamage;
	if (InstigatedBy.Health > 199)
		InstigatedBy.Health = 199;
	if (CarriedDecoration != None)
		DropDecoration();
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if (Health > 0)
	{
		if ( (InstigatedBy != None) && (InstigatedBy != Self) )
			damageAttitudeTo(InstigatedBy);
		PlayHit(actualDamage, HitLocation, damageType, Momentum);
	}
	else if ( !bAlreadyDead )
	{
		NextState = '';
		PlayDeathHit(actualDamage, HitLocation, damageType, Momentum);
		if ( actualDamage > mass )
			Health = -1 * actualDamage;
		if ( (InstigatedBy != None) && (InstigatedBy != Self) )
			damageAttitudeTo(InstigatedBy);
		Died(InstigatedBy, damageType, HitLocation);
	}
	else
	{
		if ( bIsPlayer )
		{
			HidePlayer();
			GotoState('Dying');
		}
		else
			Destroy();
	}
	MakeNoise(1.0);
}

function bool Gibbed(name damageType)
{
	if ( (damageType == 'decapitated') || (damageType == 'shot') )
		return false;
	if ( (Health < -80) || ((Health < -40) && (FRand() < 0.6)) || (damageType == 'Suicided') )
		return true;
	return false;
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
	local pawn OtherPawn;
	local actor A;

	// mutator hook to prevent deaths
	// WARNING - don't prevent bot suicides - they suicide when really needed
	if ( Level.Game.BaseMutator.PreventDeath(self, Killer, damageType, HitLocation) )
	{
		Health = max(Health, 1); //mutator should set this higher
		return;
	}
	if ( bDeleteMe )
		return; //already destroyed
	StopZoom();
	Health = Min(0, Health);

	for ( OtherPawn=Level.PawnList; OtherPawn!=None; OtherPawn=OtherPawn.nextPawn )
		OtherPawn.Killed(Killer, self, damageType);
	if ( CarriedDecoration != None )
		DropDecoration();
	level.game.Killed(Killer, self, damageType);
	// DeathMatchPlus.Killed just told the killer, which a server demo misses.
	if (damageType == 'Decapitated' && Killer != self && bbPlayer(Killer) != none && Level.Game.IsA('DeathMatchPlus'))
		bbPlayer(Killer).IGPlus_DemoLocalizedMessage(class'DecapitationMessage', 0, none, none, none);
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );
	if (Weapon.IsA('TournamentWeapon'))
		TournamentWeapon(Weapon).bCanClientFire = false;
	IGPlus_DetClearSwitchTrustState(IGPlus_DetTradesEnabled());
	IGPlus_bDetTradeClosed = IGPlus_DetTradesEnabled() == false;
	IGPlus_bDetTradeLogged = false;
	// Velocity has the killing push, which our client never saw.
	IGPlus_TradeLoc = Location;
	IGPlus_TradeTS = CurrentTimeStamp;
	IGPlus_TradeSpeed = FMin(VSize(IGPlus_DetClientVel), VSize(Velocity));
	Velocity.Z *= 1.3;
	if (Gibbed(DamageType)) {
		SpawnGibbedCarcass();
		if ( bIsPlayer )
			HidePlayer();
		else
			Destroy();
	}
	PlayDying(DamageType, HitLocation);
	if ( Level.Game.bGameEnded )
		return;

	if ( RemoteRole == ROLE_AutonomousProxy )
		ClientDying(DamageType, HitLocation);
	LastKiller = Killer;
	GotoState('Dying');

	if (IGPlus_DamageEvent_ShowOnDeath)
		IGPlus_DamageEvent_SendReport();
}

event ServerTick(float DeltaTime) {
	local bool bSendSnapshot;
	local bool bHardSnap;
	local bool bOnMover;
	local byte SnapshotIntentBits;
	local byte SnapshotDodgeDir;
	local byte SnapshotPhysics;
	local float SnapshotDeltaTime;
	local float SnapshotSendHz;
	local float SnapshotInterval;

	AverageServerDeltaTime = (AverageServerDeltaTime*99 + DeltaTime) * 0.01;
	IGPlus_ABTick(DeltaTime);
	// Precise Rewind Time: stamp what this tick sends our client, and read
	// our own measure of its ping to check its reports against.
	if (RemoteRole == ROLE_AutonomousProxy && GetWeaponSettings() != none
		&& GetWeaponSettings().bEnablePingCompensation) {
		IGPlus_PRTServerTick++;
		IGPlus_PRTTickTime[IGPlus_PRTServerTick & 127] = Level.TimeSeconds;
		if (Level.TimeSeconds >= IGPlus_PRTPingReadTS) {
			IGPlus_PRTServerPing = float(ConsoleCommand("GETPING"));
			IGPlus_PRTPingReadTS = Level.TimeSeconds + 0.5;
			IGPlus_PingRing[IGPlus_PingRingAt & 3] = IGPlus_PRTServerPing;
			IGPlus_PingRingAt++;
		}
	}
	// Tick Interpolation: our client learns the tick's number, and everyone
	// learns which tick our last move ran in. UTPlusDummy takes its snapshot
	// in the same ticks, so a client's updates of us line up with them.
	// Not while we are dead: UTPlusDummy takes no snapshot then, and a
	// client would keep the spot we died at as our newest one. The first tick
	// of the next life gives a stamp at once, as it gives a snapshot.
	if (IGPlus_EnableTickInterp && zzUTPure != None) {
		IGPlus_TI_ServerTick = zzUTPure.IGPlus_GlobalTick;
		if (CurrentTimeStamp > IGPlus_TI_MoveTS && Health > 0 && IsInState('Dying') == false) {
			IGPlus_TI_MoveTS = CurrentTimeStamp;
			IGPlus_NetTick = byte(zzUTPure.IGPlus_GlobalTick & 255);
			IGPlus_NetLoc = IGPlus_TI_LocWhole(IGPlus_TI_WireLoc(Location));
			IGPlus_NetLocFrac = IGPlus_TI_LocFrac(IGPlus_TI_WireLoc(Location));
			IGPlus_NetMoveT = IGPlus_TI_MoveByte(CurrentTimeStamp);
		}
	}
	IGPlus_ProcessRemoteMovement();
	xxRememberPosition();
	IGPlus_SDServerRecord(DeltaTime);
	IGPlus_SDCheckPickups();
	IGPlus_UpdateServerSnapInterpDelayEstimate();

	if (IGPlus_EnableSnapshotInterpolation) {
		SnapshotSendHz = 30.0;
		if (zzUTPure != None && zzUTPure.Settings.SnapshotInterpSendHz > 0.0)
			SnapshotSendHz = zzUTPure.Settings.SnapshotInterpSendHz;
		SnapshotInterval = 1.0 / FMax(SnapshotSendHz, 1.0);

		if (IGPlus_SnapInterp_ServerNextTime <= 0)
			IGPlus_SnapInterp_ServerNextTime = Level.TimeSeconds;

		bSendSnapshot = Level.TimeSeconds >= IGPlus_SnapInterp_ServerNextTime;
		if (bSendSnapshot) {
			bHardSnap = false;
			if (IGPlus_SnapInterp_ServerHasLast) {
				SnapshotDeltaTime = FMax(Level.TimeSeconds - IGPlus_SnapInterp_ServerLastTime, 0.016);
				if (VSize(Location - IGPlus_SnapInterp_ServerLastLocation) > 3000.0 * SnapshotDeltaTime)
					bHardSnap = true;
			} else {
				bHardSnap = true;
			}

				bOnMover = Mover(Base) != none;
				IGPlus_SnapReplicatedDataPrev = IGPlus_SnapReplicatedData;
					IGPlus_SnapReplicatedData.Location = Location;
					IGPlus_SnapReplicatedData.Velocity = Velocity;
					IGPlus_SnapReplicatedData.Rotation = Rotation;
					IGPlus_SnapReplicatedData.Rotation.Roll = 0;
					IGPlus_SnapReplicatedData.AnimSequence = AnimSequence;
					IGPlus_SnapReplicatedData.AnimFrameByte = byte(FClamp(AnimFrame * 255.0, 0.0, 255.0));
					SnapshotIntentBits = 0;
					if ((bIsCrouching && Physics == PHYS_Walking) || DuckFraction > 0.25)
						SnapshotIntentBits = SnapshotIntentBits | 1;
					if (bDodging || DodgeDir == DODGE_Active)
						SnapshotIntentBits = SnapshotIntentBits | 2;

					SnapshotDodgeDir = 0;
					if (DodgeDir == DODGE_Left)
						SnapshotDodgeDir = 1;
					else if (DodgeDir == DODGE_Right)
						SnapshotDodgeDir = 2;
					else if (DodgeDir == DODGE_Forward)
						SnapshotDodgeDir = 3;
					else if (DodgeDir == DODGE_Back)
						SnapshotDodgeDir = 4;
					else if (DodgeDir == DODGE_Active) {
						if (AnimSequence == 'DodgeL')
							SnapshotDodgeDir = 1;
						else if (AnimSequence == 'DodgeR')
							SnapshotDodgeDir = 2;
						else if (AnimSequence == 'DodgeB')
							SnapshotDodgeDir = 4;
						else if (AnimSequence == 'DodgeF' || AnimSequence == 'Flip')
							SnapshotDodgeDir = 3;
					}
					// Bit 2 tags forward dodge visual intent: Flip vs DodgeF.
					// Keep this strictly source-accurate: set only when the sampled
					// sequence is actually Flip at snapshot time.
					if (SnapshotDodgeDir == 3 && AnimSequence == 'Flip')
						SnapshotIntentBits = SnapshotIntentBits | 4;

					switch (Physics) {
						case PHYS_None: SnapshotPhysics = 0; break;
						case PHYS_Walking: SnapshotPhysics = 1; break;
						case PHYS_Falling: SnapshotPhysics = 2; break;
						case PHYS_Swimming: SnapshotPhysics = 3; break;
						case PHYS_Flying: SnapshotPhysics = 4; break;
						case PHYS_Rotating: SnapshotPhysics = 5; break;
						case PHYS_Projectile: SnapshotPhysics = 6; break;
						case PHYS_Rolling: SnapshotPhysics = 7; break;
						case PHYS_Interpolating: SnapshotPhysics = 8; break;
						case PHYS_MovingBrush: SnapshotPhysics = 9; break;
						case PHYS_Spider: SnapshotPhysics = 10; break;
						case PHYS_Trailer: SnapshotPhysics = 11; break;
						default: SnapshotPhysics = 0; break;
					}
					IGPlus_SnapReplicatedData.AnimIntentBits = SnapshotIntentBits;
					IGPlus_SnapReplicatedData.AnimDodgeDir = SnapshotDodgeDir;
					IGPlus_SnapReplicatedData.AnimPhysics = SnapshotPhysics;
					IGPlus_SnapReplicatedData.Counter += 1;
					IGPlus_SnapReplicatedData.bHardSnap = bHardSnap;
					IGPlus_SnapReplicatedData.bBasedOnMover = bOnMover;
				if (bOnMover) {
					IGPlus_SnapReplicatedData.MoverLocation = Base.Location;
					IGPlus_SnapReplicatedData.BaseMover = Base;
				} else {
					IGPlus_SnapReplicatedData.MoverLocation = vect(0,0,0);
					IGPlus_SnapReplicatedData.BaseMover = None;
				}

			IGPlus_SnapInterp_ServerLastLocation = Location;
			IGPlus_SnapInterp_ServerLastTime = Level.TimeSeconds;
			IGPlus_SnapInterp_ServerHasLast = true;

			while (IGPlus_SnapInterp_ServerNextTime <= Level.TimeSeconds)
				IGPlus_SnapInterp_ServerNextTime += SnapshotInterval;
		}

		// Snapshot interpolation uses a fixed send cadence and does not
		// depend on per-move WarpFix update flags.
		IGPlus_WarpFixUpdate = false;
	} else {
		IGPlus_SnapInterp_ServerNextTime = 0;
		IGPlus_SnapInterp_ServerHasLast = false;

		if (IGPlus_WarpFixUpdate && IGPlus_EnableWarpFix) {
			IGPlus_WarpFixData.OldLocation = Location;
			IGPlus_WarpFixData.Counter += 1;
			IGPlus_WarpFixUpdate = false;
		}
	}

	if (DelayedNavPoint != none) {
		if (DelayedNavPoint.Class.Name == 'swJumpPad')
			ReplicateSwJumpPad(Teleporter(DelayedNavPoint));

		DelayedNavPoint = DelayedNavPoint.NextNavigationPoint;
	}

	if (IGPlus_ForcedSettings_Initialized) {
		if (IGPlus_ForcedSettings_Index < Min(zzUTPure.Settings.ForcedSettings.Length, arraycount(IGPlus_ForcedSettings))) {
			if (zzUTPure.GetForcedSettingKey(IGPlus_ForcedSettings_Index) != "") {
				IGPlus_ForcedSettings_Counter++;
				IGPlus_ForcedSettingRegister(
					zzUTPure.GetForcedSettingKey(IGPlus_ForcedSettings_Index),
					zzUTPure.GetForcedSettingValue(IGPlus_ForcedSettings_Index),
					zzUTPure.GetForcedSettingMode(IGPlus_ForcedSettings_Index));
			}
			IGPlus_ForcedSettings_Index++;
		} else if (IGPlus_ForcedSettings_Index == Min(zzUTPure.Settings.ForcedSettings.Length, arraycount(IGPlus_ForcedSettings))) {
			IGPlus_ForcedSettingsApply(IGPlus_ForcedSettings_Counter);
			IGPlus_ForcedSettings_Index++;
		}
	}

	// bIsCrouching survives leaving the ground (walking off a ledge, knockback),
	// but the model plays its in-air animation, so the hitbox goes back to full size like stock
	if (bIsCrouching && Physics == PHYS_Walking) {
		DuckFraction = FClamp(DuckFraction + DeltaTime/DuckStartTransitionTime, 0.0, 1.0);
	} else {
		DuckFraction = FClamp(DuckFraction - DeltaTime/DuckEndTransitionTime, 0.0, 1.0);
	}
	DuckFractionRepl = byte(DuckFraction * 255.0);

	bAlwaysRelevant = zzUTPure.Settings.bPlayersAlwaysRelevant || (PlayerReplicationInfo.HasFlag != none);
}

/** STATES
 * @Author: spect
 * @Date: 2020-02-19 02:13:05
 * @Desc: PlayerPawn States (This is where movement, compensation and position adjustment is controlled)
 */

state FeigningDeath
{
	// Fix: Base PlayerPawn.AltFire() incorrectly sets bJustFired instead of bJustAltFired
	// A button already held when the feign began is not a press: ServerMove
	// calls Fire() on the 0 -> held edge of the server's bFire latch, and that
	// latch is cleared both on entry (multiweapon guard below) and by every v4
	// step. Ignore it until the client reports the button released.
	exec function Fire(optional float F)
	{
		if (IGPlus_FeignFireHeld)
			return;
		bJustFired = true;
	}

	exec function AltFire(optional float F)
	{
		if (IGPlus_FeignAltFireHeld)
			return;
		bJustAltFired = true;
	}

	// Fix: Base ProcessMove only checks bJustFired, need to also check bJustAltFired
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		if (!IGPlus_LastFireEndHeld)
			IGPlus_FeignFireHeld = false;
		if (!IGPlus_LastAltEndHeld)
			IGPlus_FeignAltFireHeld = false;
		if (bJustFired || bJustAltFired || bPressedJump || (NewAccel.Z > 0))
			Rise();
		Acceleration = vect(0,0,0);
	}

	function xxServerMove
	(
		float TimeStamp,
		int MoveDeltaTime,
		vector Accel,
		float ClientLocX,
		float ClientLocY,
		float ClientLocZ,
		vector ClientVel,
		int MiscData,
		int MiscData2,
		int View,
		Actor ClientBase,
		optional int OldMoveData1,
		optional int OldMoveData2,
		optional float DetRedoTS,
		optional int DetRedoData,
		optional int PRTData
	)
	{
		// Adaptive Buffering: a queued player's move waits for its turn, and
		// runs through the xxServerMove of the state we are in by then.
		IGPlus_ABIntercept(TimeStamp, MoveDeltaTime, Accel, ClientLocX, ClientLocY, ClientLocZ, ClientVel,
			MiscData, MiscData2, View, ClientBase, OldMoveData1, OldMoveData2, DetRedoTS, DetRedoData, PRTData);
		if (IGPlus_ABKept)
			return;
		IGPlus_ABSeen = IGPlus_ABPlaying == false;

		Global.xxServerMove(
			TimeStamp,
			MoveDeltaTime,
			Accel,
			ClientLocX,
			ClientLocY,
			ClientLocZ,
			ClientVel,
			MiscData,
			MiscData2,
			((Rotation.Pitch & 0xFFFF) << 16) | (Rotation.Yaw & 0xFFFF),
			ClientBase,
			OldMoveData1,
			OldMoveData2,
			DetRedoTS,
			DetRedoData,
			PRTData);
	}

	function PlayerMove( float DeltaTime)
	{
		local rotator currentRot;
		local vector NewAccel;

		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		if ( !FeignAnimCheck()  && (aForward != 0) || (aStrafe != 0) )
			NewAccel = vect(0,0,1);
		else
			NewAccel = vect(0,0,0);

		// Update view rotation.
		currentRot = Rotation;
		xxUpdateRotation(DeltaTime, 1);
		SetRotation(currentRot);

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, Rot(0,0,0));
		bPressedJump = false;
	}

	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function BeginState()
	{
		if (Weapon != none)
			IGPlus_FeignWeapon = Weapon;
		// Remote clients only. A locally controlled pawn (listen host, offline)
		// calls Fire() straight from the keypress and never reports held state
		// back through IGPlus_LastFireEndHeld — latching here would lock it out
		// of rising by fire entirely.
		IGPlus_FeignFireHeld = RemoteRole == ROLE_AutonomousProxy
			&& (bFire != 0 || IGPlus_LastFireEndHeld);
		IGPlus_FeignAltFireHeld = RemoteRole == ROLE_AutonomousProxy
			&& (bAltFire != 0 || IGPlus_LastAltEndHeld);
		Super.BeginState();
		// Stop weapon firing
		//UsAaR33: prevent weapon from firing (brought on by missing bchangedweapon checks)
		if (zzbNoMultiWeapon && Weapon != none && (baltfire>0||bfire>0) )
		{ //could only be true on server
			baltfire=0;
			bfire=0;
			//additional hacks to stop weapons:
			if (Weapon.Isa('Minigun2'))
				Minigun2(Weapon).bFiredShot=true;
			if (Weapon.IsA('Chainsaw'))   //Saw uses sleep delays in states.
				Weapon.Finish();
			Weapon.Tick(0);
			Weapon.AnimEnd();
		}
	}

	function EndState()
	{
		// The client blanks Weapon every tick while feigning (stock
		// PlayerPawn.FeigningDeath.PlayerTick). The server's restored Weapon
		// can replicate before the state change reaches us — then it is
		// blanked again and, being unchanged server-side, never resent.
		if (Role < ROLE_Authority && Weapon == none
			&& IGPlus_FeignWeapon != none && IGPlus_FeignWeapon.Owner == self)
			Weapon = IGPlus_FeignWeapon;
		IGPlus_FeignWeapon = none;
		IGPlus_FeignFireHeld = false;
		IGPlus_FeignAltFireHeld = false;
		zzbForceUpdate = true;
		Super.EndState();
	}
}
//==========================================

state PlayerSwimming
{
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
		local vector X,Y,Z, Temp;

		GetAxes(ViewRotation,X,Y,Z);
		Acceleration = NewAccel;

		SwimAnimUpdate( (X Dot Acceleration) <= 0 );

		bUpAndOut = ((X Dot Acceleration) > 0) && ((Acceleration.Z > 0) || (ViewRotation.Pitch > 2048));

		if ( bUpAndOut && !Region.Zone.bWaterZone && CheckWaterJump(Temp) ) //check for waterjump
		{
			velocity.Z = 330 + 2 * CollisionRadius; //set here so physics uses this for remainder of tick
			PlayDuck();
			GotoState('PlayerWalking');
		}
	}

	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		//add bobbing when swimming
		if ( !bShowMenu )
		{
			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			WalkBob = Y * Bob *  0.5 * Speed2D * sin(4.0 * Level.TimeSeconds);
			WalkBob.Z = Bob * 1.5 * Speed2D * sin(8.0 * Level.TimeSeconds);
		}

		// Update rotation.
		oldRotation = Rotation;
		xxUpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
		bPressedJump = false;
	}

	event ServerTick(float DeltaTime) {
		IGPlus_ProcessRemoteMovement();
		WarpCompensation(DeltaTime);
		global.ServerTick(DeltaTime);
	}

	event UpdateEyeHeight(float DeltaTime)
	{
		Super.UpdateEyeHeight(DeltaTime);
		xxCheckFOV();
	}

	function Timer()
	{
		if ( !Region.Zone.bWaterZone && (Role == ROLE_Authority) )
		{
			GotoState('PlayerWalking');
			AnimEnd();
		}

		Disable('Timer');
	}

	function BeginState()
	{
		Disable('Timer');
		if ( !IsAnimating() )
			TweenToWaiting(0.3);
	}
}

state PlayerFlying
{
	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.2;
		aStrafe  *= 0.2;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		Acceleration = aForward*X + aStrafe*Y;
		// Update rotation.
		xxUpdateRotation(DeltaTime, 2);

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}
}

// ==================================================================

state CheatFlying
{
	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		xxUpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}
}

state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;
	event Landed(vector HitNormal)
	{
		local float Vel;

		Global.Landed(HitNormal);

		if (bJumpingPreservesMomentum == false) {
			Velocity *= vect(1,1,0);

			if (bOldLandingMomentum) {
				if (bDodging)
					Velocity *= DodgeEndVelocity;
				Velocity = Normal(Velocity) * FMin(VSize(Velocity), GroundSpeed);
			} else {
				if (bDodging)
					Vel = VSize(Velocity) * DodgeEndVelocity;
				else
					Vel = VSize(Velocity) * JumpEndVelocity;

				Velocity = (Normal(Velocity) + Normal(Acceleration)) * 0.5 * HitNormal.Z * FMin(Vel, GroundSpeed);
			}
		} else if (bDodging) {
			Velocity *= DodgeEndVelocity;
		} else {
			Velocity *= JumpEndVelocity;
		}

		if (bDodging || DodgeDir == DODGE_Done) {
			DodgeDir = DODGE_Done;
			DodgeClickTimer = 0.0;
			bDodging = false;
		} else {
			DodgeDir = DODGE_None;
		}

		MultiDodgesRemaining = bbPlayerReplicationInfo(PlayerReplicationInfo).MaxMultiDodges;

		IGPlus_MoveDebug("Landed");
		if (Settings.bDebugMovement && Level.NetMode == NM_Client)
			ClientDebugMessage("Landed");
	}

	simulated function Dodge(eDodgeDir DodgeMove)
	{
		local vector X,Y,Z;
		local vector HitLocation;
		local vector HitNormal;
		local Actor  HitActor;
		local vector TraceStart;
		local vector TraceEnd;
		local float VelocityZ;
		local float DodgeXY;
		local float DodgeZ;
		local vector OldVel;

		if ( bIsCrouching || (Physics != PHYS_Walking && Physics != PHYS_Falling) ) {
			IGPlus_MoveDebug("Dodge refused"@DodgeMove);
			return;
		}
		if (Physics == PHYS_Falling && bCanWallDodge == false) {
			IGPlus_MoveDebug("Dodge refused"@DodgeMove);
			return;
		}

		OldVel = Velocity;
		GetAxes(Rotation.Yaw*rot(0,1,0),X,Y,Z);

		if (Physics == PHYS_Falling) {
			if (DodgeMove == DODGE_Forward)
				TraceEnd = -X;
			else if (DodgeMove == DODGE_Back)
				TraceEnd = X;
			else if (DodgeMove == DODGE_Left)
				TraceEnd = -Y;
			else if (DodgeMove == DODGE_Right)
				TraceEnd = Y;
			TraceStart = Location - CollisionHeight*vect(0,0,1) + TraceEnd*CollisionRadius;
			TraceEnd = TraceStart + TraceEnd*32.0;
			HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, false, vect(1,1,1));
			if ((HitActor == none) || (HitActor != Level && Mover(HitActor) == none)) {
				IGPlus_MoveDebug("Dodge refused"@DodgeMove);
				return;
			}

			TakeFallingDamage();
		}

		if (bDodging) {
			DodgeXY = SecondaryDodgeSpeedXY;
			DodgeZ = SecondaryDodgeSpeedZ;
		} else {
			DodgeXY = DodgeSpeedXY;
			DodgeZ = DodgeSpeedZ;
		}

		if (bDodgePreserveZMomentum) {
			VelocityZ = Velocity.Z;
			if (Base != none)
				VelocityZ += Base.Velocity.Z;
		}

		if (DodgeMove == DODGE_Forward)
			Velocity = DodgeXY*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Back)
			Velocity = -DodgeXY*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Left)
			Velocity = DodgeXY*Y + (Velocity Dot X)*X;
		else if (DodgeMove == DODGE_Right)
			Velocity = -DodgeXY*Y + (Velocity Dot X)*X;

		Velocity.Z = FMax(DodgeZ, VelocityZ + DodgeZ);
		PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, bUpdating, 800, 1.0 );
		PlayDodge(DodgeMove);
		DodgeDir = DODGE_Active;
		bDodging = true;
		SetPhysics(PHYS_Falling);
		IGPlus_MoveDebug("Dodge done"@DodgeMove);
		if (Settings.bDebugMovement && Level.NetMode == NM_Client && bUpdating == false)
			ClientDebugMessage("Dodged"@DodgeMove@bUpdating@(Rotation.Yaw&0xFFFF)@"|"@int(Location.X)@int(Location.Y)@int(Location.Z)@"|"@int(Velocity.X)@int(Velocity.Y)@int(Velocity.Z)@"|"@int(OldVel.X)@int(OldVel.Y)@int(OldVel.Z));
	}

	function PlayerMove( float DeltaTime )
	{
		local vector X,Y,Z, NewAccel;
		local EDodgeDir OldDodge;
		local eDodgeDir DodgeMove;
		local rotator OldRotation;
		local float Speed2D;
		local bool	bSaveJump;
		local name AnimGroupName;
		local float MinTime;

		if (Mesh == None)
		{
			SetMesh();
			return;		// WHY???
		}

		GetAxes(Rotation,X,Y,Z);

		aForward *= 0.4;
		aStrafe  *= 0.4;
		aLookup  *= 0.24;
		aTurn    *= 0.24;

		// Update acceleration.
		NewAccel = aForward*X + aStrafe*Y;
		NewAccel.Z = 0;
		// Check for Dodge move
		if ( DodgeDir == DODGE_Active )
			DodgeMove = DODGE_Active;
		else
			DodgeMove = DODGE_None;

		LastTimeForward -= DeltaTime;
		LastTimeBack    -= DeltaTime;
		LastTimeLeft    -= DeltaTime;
		LastTimeRight   -= DeltaTime;

		if (DodgeClickTime > 0.0)
		{
			if ( DodgeDir < DODGE_Active )
			{
				MinTime = MinDodgeClickTime;
				if (Player != none && Player.IsA('Viewport'))
					MinTime = Settings.MinDodgeClickTime;

				OldDodge = DodgeDir;
				DodgeDir = DODGE_None;

				if (bEdgeForward && bWasForward)
				{
					if (LastTimeForward <= 0.0) {
						DodgeDir = DODGE_Forward;
						LastTimeForward = MinTime;
					}
				}
				else if (bEdgeBack && bWasBack)
				{
					if (LastTimeBack <= 0.0) {
						DodgeDir = DODGE_Back;
						LastTimeBack = MinTime;
					}
				}
				else if (bEdgeLeft && bWasLeft)
				{
					if (LastTimeLeft <= 0.0) {
						DodgeDir = DODGE_Left;
						LastTimeLeft = MinTime;
					}
				}
				else if (bEdgeRight && bWasRight)
				{
					if (LastTimeRight <= 0.0) {
						DodgeDir = DODGE_Right;
						LastTimeRight = MinTime;
					}
				}

				if ( DodgeDir == DODGE_None)
					DodgeDir = OldDodge;
				else if ( DodgeDir != OldDodge )
					DodgeClickTimer = DodgeClickTime + 0.5 * DeltaTime;
				else
					DodgeMove = DodgeDir;
			}

			if ((DodgeDir != DODGE_None) && (DodgeDir < DODGE_Active))
			{
				DodgeClickTimer -= DeltaTime;
				if (DodgeClickTimer < 0)
				{
					DodgeDir = DODGE_None;
					DodgeClickTimer = DodgeClickTime;
				}
			}
		}

		if (bEnableSingleButtonDodge && bPressedDodge && DodgeDir < DODGE_Active && DodgeMove == DODGE_None) {
			if (aStrafe > 1)
				DodgeMove = DODGE_Left;
			else if (aStrafe < -1)
				DodgeMove = DODGE_Right;
			else if (aForward > 1)
				DodgeMove = DODGE_Forward;
			else if (aForward < -1)
				DodgeMove = DODGE_Back;
		}

		if (DodgeDir == DODGE_Done || (bDodging && (Base != None || Physics == PHYS_Walking)))
		{
			DodgeClickTimer = FMin(-DeltaTime, DodgeClickTimer - DeltaTime);
			if (DodgeClickTimer < -0.35)
			{
				bDodging = false;
				DodgeDir = DODGE_None;
				DodgeClickTimer = DodgeClickTime;
				MultiDodgesRemaining = bbPlayerReplicationInfo(PlayerReplicationInfo).MaxMultiDodges;
			}
		}

		// Fix by DB
		if (AnimSequence != '')
			AnimGroupName = GetAnimGroup(AnimSequence);

		if ( (Physics == PHYS_Walking) && (AnimGroupName != 'Dodge') )
		{
			//if walking, look up/down stairs - unless player is rotating view
			if ( !bKeyboardLook && (bLook == 0) )
			{
				if ( bLookUpStairs )
					ViewRotation.Pitch = FindStairRotation(deltaTime);
				else if ( bCenterView )
				{
					ViewRotation.Pitch = ViewRotation.Pitch & 65535;
					if (ViewRotation.Pitch > 32768)
						ViewRotation.Pitch -= 65536;
					ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
					if ( Abs(ViewRotation.Pitch) < 1000 )
						ViewRotation.Pitch = 0;
				}
			}

			Speed2D = Sqrt(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y);
			//add bobbing when walking
			if ( !bShowMenu && bUpdating == false ) {
				CheckBob(DeltaTime, Speed2D, Y);
			}
		}
		else if ( !bShowMenu && bUpdating == false )
		{
			BobTime = 0;
			WalkBob = WalkBob * (1 - FMin(1, 8 * deltatime));
		}

		// Update rotation.
		OldRotation = Rotation;
		xxUpdateRotation(DeltaTime, 1);

		if ( bPressedJump && (AnimGroupName == 'Dodge') )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DodgeMove, OldRotation - Rotation);
		bPressedJump = bSaveJump;

		if (bCanWallDodge && DodgeDir == DODGE_Active && MultiDodgesRemaining > 0) {
			MultiDodgesRemaining -= 1;
			DodgeDir = DODGE_None;
		}
	}

	event ServerTick(float DeltaTime) {
		IGPlus_ProcessRemoteMovement();
		WarpCompensation(DeltaTime);
		global.ServerTick(DeltaTime);
	}

	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;

		if ( bUpdatePosition && IGPlus_EnableInputReplication == false )
			ClientUpdatePosition();

		//
		// stijn: if the server corrected our position in the middle of
		// a dodge, we might end up in DODGE_Active state with our
		// Physics set to PHYS_Walking. If this happened before 469,
		// the player would not be able to dodge again until triggering
		// a landed event (which usually meant you had to jump).
		// Here, we just wait for the dodge animation to play out and
		// then manually force a dodgedir reset.
		// 
		if (DodgeDir == DODGE_Active &&
		    Physics != PHYS_Falling &&
			GetAnimGroup(AnimSequence) != 'Dodge' &&
			GetAnimGroup(AnimSequence) != 'Jumping')
		{
			bDodging = false;
			DodgeDir = DODGE_None;
			DodgeClickTimer = DodgeClickTime;
		}	

		PlayerMove(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function BeginState()
	{
		if ( Mesh == None )
			SetMesh();
		WalkBob = vect(0,0,0);
		bDodging = false;
		DodgeDir = DODGE_None;
		DodgeClickTimer = DodgeClickTime;
		bIsCrouching = false;
		bIsTurning = false;
		bPressedJump = false;
		if (Physics != PHYS_Falling) SetPhysics(PHYS_Walking);
		if ( !IsAnimating() )
			PlaySpawn();
	}

	function EndState()
	{
		WalkBob = vect(0,0,0);
		bIsCrouching = false;
	}
}

//==========================================

function bool FeignAnimCheck() //for VA compatibility
{
	return IsAnimating();
}

// ==============================================
state PlayerWaiting
{
	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.12; // 0.1
		aStrafe  *= 0.12;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.12;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		xxUpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

	exec function Fire(optional float F)
	{
		if (!bIsFinishedLoading)
			return;
		xxServerSetReadyToPlay();
		if (Settings.bAutoReady)
			bReadyToPlay = true;
	}

	exec function AltFire(optional float F)
	{
		Fire(F);
	}

}

simulated function PlayerPawn GetLocalPlayer() {
	local PlayerPawn P;

	if (bDeterminedLocalPlayer) return LocalPlayer;

	foreach AllActors(class'PlayerPawn', P) {
		if (Viewport(P.Player) != none) {
			LocalPlayer = P;
			break;
		}
	}
	bDeterminedLocalPlayer = true;
	return LocalPlayer;
}

simulated function PlayDodge(eDodgeDir DodgeMove)
{
	if ( DodgeMove == DODGE_Left )
		TweenAnim('DodgeL', 0.1);
	else if (DodgeMove == DODGE_Right )
		TweenAnim('DodgeR', 0.1);
	else if (DodgeMove == DODGE_Back )
		TweenAnim('DodgeB', 0.1);
	else if (bUseFlipAnimation == false)
		TweenAnim('DodgeF', 0.1);
	else
		PlayAnim('Flip', 1.35 * FMax(0.35, Region.Zone.ZoneGravity.Z/Region.Zone.Default.ZoneGravity.Z), 0.065);
}

function xxServerSetReadyToPlay()
{
	if (zzUTPure.zzDMP == None)
		return;

	if (zzUTPure.zzDMP.bTournament && zzUTPure.Settings.bWarmup && zzUTPure.zzDMP.bRequireReady && (zzUTPure.zzDMP.CountDown >= 10))
	{
		zzbForceUpdate = true;

		PlayerRestartState = 'PlayerWarmup';
		GotoState('PlayerWarmup');
		zzUTPure.zzDMP.ReStartPlayer(Self);
		zzUTPure.zzbWarmupPlayers = True;
	}
}

function GiveMeWeapons()
{
	local Inventory Inv;
	local Weapon w, Best;
	local float Current, Highest;
	local DeathMatchPlus DMP;
	local string WeaponList[32], s;
	local int WeapCnt, x;				// Grr, wish UT had dyn arrays :P
	local bool bAlready;
	local bool bSavedRequireReady;

	DMP = DeathMatchPlus(Level.Game);
	if (DMP == None) return;			// If DMP is none, I would never be here, so darnit really? :P

	bSavedRequireReady = DMP.bRequireReady;
	DMP.bRequireReady = false;
	Level.Game.AddDefaultInventory(self);
	DMP.bRequireReady = bSavedRequireReady;

	ForEach AllActors(Class'Weapon', w)
	{	// Find the rest of the weapons around the map.
		s = string(w.Class);
		bAlready = False;
		for (x = 0; x < WeapCnt; x++)
		{
			if (WeaponList[x] ~= s)
			{
				bAlready = True;
				break;
			}
		}
		if (!bAlready)
			WeaponList[WeapCnt++] = s;
	}

	for (x = 0; x < WeapCnt; x++)
	{	// Distribute weapons.
		DMP.GiveWeapon(Self, WeaponList[x]);
	}

	for ( Inv = Inventory; Inv != None; Inv = Inv.Inventory )
	{	// This gives max ammo.
		w = Weapon(Inv);
		if (w != None)
		{
			w.WeaponSet(Self);
			if ( w.AmmoType != None )
			{
				w.AmmoType.AmmoAmount = w.AmmoType.MaxAmmo;
				if (w.AmmoType != None && w.AmmoType.AmmoAmount <= 0)
					continue;
				w.SetSwitchPriority(self);
				Current = w.AutoSwitchPriority;
				if ( Current > Highest )
				{
					Best = w;
					Highest = Current;
				}
			}
		}
	}

	// GiveWeapon and WeaponSet leave every weapon in state '', the current one
	// too, where PutDown only sets bChangeWeapon and a switch hangs. Raise the
	// pick through ChangedWeapon, which skips the raise if PendingWeapon is
	// already the current weapon: then clear it, so the current one comes up.
	PendingWeapon = Best;
	if (PendingWeapon == Weapon)
		PendingWeapon = none;
	ChangedWeapon();
}

state PlayerWarmup extends PlayerWalking
{
	function BeginState()
	{
		local float NewJumpZ;

		if (zzUTPure != none && zzUTPure.zzDMP != none && zzUTPure.zzDMP.Role == ROLE_Authority) {
			NewJumpZ = Default.JumpZ * zzUTPure.zzDMP.PlayerJumpZScaling();
			if (NewJumpZ > 0)
				JumpZ = NewJumpZ;
		}

		zzbIsWarmingUp = true;
		GiveMeWeapons();
		Super.BeginState();
	}

	exec function SetProgressMessage( string S, int Index )
	{	// Bugly hack. But why not :/ It's only used during warmup anyway.
		// This also means that admins may not use say # >:|
		if (S == Class'DeathMatchPlus'.Default.ReadyMessage || S == Class'TeamGamePlus'.Default.TeamChangeMessage)
		{
			ClearProgressMessages();
			return;
		}
		Super.SetProgressMessage( S, Index );
	}

	function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
							Vector momentum, name damageType)
	{
		Global.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	}

}



// =======================
state PlayerSpectating
{
	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);

		aForward *= 0.1;
		aStrafe  *= 0.1;
		aLookup  *= 0.24;
		aTurn    *= 0.24;
		aUp		 *= 0.1;

		Acceleration = aForward*X + aStrafe*Y + aUp*vect(0,0,1);

		xxUpdateRotation(DeltaTime, 1);

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Acceleration, DODGE_None, rot(0,0,0));
	}

}
//===============================================================================
state PlayerWaking
{

	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function PlayerMove(Float DeltaTime)
	{
		ViewFlash(deltaTime * 0.5);
		if ( TimerRate == 0 )
		{
			ViewRotation.Pitch -= DeltaTime * 12000;
			if ( ViewRotation.Pitch < 0 )
			{
				ViewRotation.Pitch = 0;
				GotoState('PlayerWalking');
			}
		}

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
	}

	function BeginState()
	{
		zzbForceUpdate = false;
		if ( bWokeUp )
		{
			ViewRotation.Pitch = 0;
			SetTimer(0, false);
			return;
		}
		BaseEyeHeight = 0;
		EyeHeight = 0;
		SetTimer(3.0, false);
		bWokeUp = true;
	}
}

state Dying
{
	function bool GameRestartPlayer() {
		local bool bDeathMatchSave;
		local bool bNoEffect;
		local bool Result;

		bNoEffect = (RemoteRole == ROLE_AutonomousProxy && zzUTPure.Settings.bEnablePingCompensatedSpawn)
			|| IGPlus_RestartedAgainByStartMatch();
		if (bNoEffect) {
			bDeathMatchSave = Level.Game.bDeathMatch;
			Level.Game.bDeathMatch = false; // no stock spawn effect or sound: ping comp spawn plays its own later, match start shows them on the second restart
			// see DeathMatchPlus.PlayTeleportEffect()
		}

		IGPlus_DetCloseTradeWindow();
		Level.Game.DiscardInventory(self); // last possible place to rid ourselves of old inventory
		Result = Level.Game.RestartPlayer(self);
		if (Result)
			IGPlus_UseNextTrans();

		if (bNoEffect)
			Level.Game.bDeathMatch = bDeathMatchSave;

		return Result;
	}

	function ServerReStartPlayer()
	{
		if ( Level.NetMode == NM_Client || bFrozen && (TimerRate>0.0) )
			return;

		if ( GameRestartPlayer() )
		{
			if (IGPlus_EnableInputReplication == false) {
				ServerTimeStamp = 0;
			}
			TimeMargin = 0;
			Enemy = None;
			Level.Game.StartPlayer(self);
			if ( Mesh != None )
				PlaySpawn();

			IGPlus_ClientReStart(Physics, Location, Rotation, IGPlus_RestartedAgainByStartMatch());
			IGPlus_PSSpawnTS = CurrentTimeStamp;
			xxClientPSSpawn(CurrentTimeStamp);

			IGPlus_DetClearSwitchTrustState();
			ChangedWeapon();
			// Our client gets the spawn weapon with the respawn, not up to
			// 0.1s later (default 10 updates a second): until then it has no
			// weapon to switch from and its presses go to the server.
			if (Weapon != none)
				Weapon.NetUpdateFrequency = FMax(Weapon.NetUpdateFrequency, 200);
			zzSpawnedTime = Level.TimeSeconds;
		}
		else
		{
			log("Restartplayer failed");
		}

	}

	event ServerTick(float DeltaTime) {
		RealTimeDead += (DeltaTime / Level.TimeDilation); // counting real time, undo dilation
		if (Level.Pauser == "")
			TimeDead += DeltaTime;

		global.ServerTick(DeltaTime);

		if (RealTimeDead > 2*zzUTPure.Settings.MaxTradeTimeMargin) {
			IGPlus_DetCloseTradeWindow();
			Level.Game.DiscardInventory(self);
		}
	}

	event PlayerTick( float DeltaTime )
	{
		local rotator DeltaRotation;

		RealTimeDead += (DeltaTime / Level.TimeDilation); // counting real time, undo dilation
		if (Level.Pauser == "")
			TimeDead += DeltaTime;

		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		if (bUpdatePosition && IGPlus_EnableInputReplication == false)
			ClientUpdatePosition();

		PlayerMove(DeltaTime);

		if ((Settings.bEnableKillCam && LastKiller != none) &&
			(TimeDead >= FMax(KillCamDelay, Settings.KillCamMinDelay) && TimeDead < KillCamDelay + KillCamDuration) &&
			bKillCamWanted
		) {
			if (LastKiller != self) {
				if (FastTrace(LastKiller.Location, Location))
					KillCamTargetRotation = rotator(LastKiller.Location - Location);
				DeltaRotation = Normalize(KillCamTargetRotation - ViewRotation);
				ViewRotation = Normalize(ViewRotation + DeltaRotation * (1 - Exp(-3.0 * DeltaTime)));
			}
		}

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	simulated function BeginState() {
		local Carcass C;

		bJumpStatus = false;
		if (zzClientTTarget != None)
			zzClientTTarget.Destroy();

		// BEGIN PlayerPawn.Dying.BeginState
		BaseEyeheight = Default.BaseEyeHeight;
		EyeHeight = BaseEyeHeight;
		if ( Carcass(ViewTarget) == None )
			bBehindView = true;
		bFrozen = true;
		bPressedJump = false;
		bJustFired = false;
		bJustAltFired = false;
		FindGoodView();
		if ( (Role == ROLE_Authority) && !bHidden ) {
			bHidden = true;
			C = SpawnCarcass();
			if (C != none)
				C.LifeSpan = 30.0;
			if ( bIsPlayer )
				HidePlayer();
			else
				Destroy();
		}
		if (Role == ROLE_Authority)
			IGPlus_PrepareNextTrans();
		SetTimer(RespawnDelay, false);

		// clean out saved moves
		while ( SavedMoves != None )
		{
			SavedMoves.Destroy();
			SavedMoves = SavedMoves.NextMove;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}
		// END PlayerPawn.Dying.BeginState

		TimeDead = 0.0;
		RealTimeDead = 0.0;
		RotationRate = rot(0,0,0);
		bKillCamWanted = true;
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);

		if ( TimeDead >= 1.0 )
		{
			if ( bPressedJump )
			{
				Fire(0);
				bPressedJump = false;
			}
			GetAxes(ViewRotation,X,Y,Z);
			// Update view rotation.
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			if (aLookup != 0.0 || aTurn != 0.0)
				bKillCamWanted = false;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
		}
		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication == false) {
			ClientUpdateTime += DeltaTime;
			if (ClientUpdateTime > TimeBetweenNetUpdates) {
				ClientUpdateTime = 0;
				IGPlus_AdjustLocationAlpha = 0; // avoid adjustments persisting until respawn
				xxServerMoveDead(Level.TimeSeconds, DeltaTime, ((ViewRotation.Pitch << 16) | (ViewRotation.Yaw & 0xFFFF)));
			}
		} else {
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		}
	}

	function xxServerMove
	(
		float TimeStamp,
		int MoveDeltaTime,
		vector Accel,
		float ClientLocX,
		float ClientLocY,
		float ClientLocZ,
		vector ClientVel,
		int MiscData,
		int MiscData2,
		int View,
		Actor ClientBase,
		optional int OldMoveData1,
		optional int OldMoveData2,
		optional float DetRedoTS,
		optional int DetRedoData,
		optional int PRTData
	)
	{
		local int KeepData, KeepData2, KeepDelta;
		local bool bFireInput;

		// Adaptive Buffering: a queued player's move waits for its turn, and
		// runs through the xxServerMove of the state we are in by then.
		IGPlus_ABIntercept(TimeStamp, MoveDeltaTime, Accel, ClientLocX, ClientLocY, ClientLocZ, ClientVel,
			MiscData, MiscData2, View, ClientBase, OldMoveData1, OldMoveData2, DetRedoTS, DetRedoData, PRTData);
		if (IGPlus_ABKept)
			return;
		IGPlus_ABSeen = IGPlus_ABPlaying == false;

		KeepData = MiscData & 0xFFFF;      // drop held fire
		KeepData2 = MiscData2 & 0x3FFFFFFF; // drop force taps too, or Det weapons shoot from the grave
		bFireInput = (MiscData & 0x03000000) != 0 || (MiscData2 & 0xC0000000) != 0;
		// A trade (bEnableAllWeaponTrades): this shot was fired before we
		// died, by the NewNet weapons' rule. Its fire and merge bits stay.
		if (IGPlus_DetTradeAllowed()) {
			KeepData = MiscData & 0x03F8FFFF;
			KeepData2 = MiscData2;
			// One line a death: held fire sends this on every move.
			if (bFireInput && IGPlus_bDetTradeLogged == false) {
				IGPlus_bDetTradeLogged = true;
				IGPlus_DetTradeLog("Traded!");
			}
		} else {
			if (bFireInput && IGPlus_bDetTradeClosed == false)
				IGPlus_DetTradeLog("Rejected Trade!");
			IGPlus_DetCloseTradeWindow();
			IGPlus_NoteDeadShot(MoveDeltaTime);
		}
		// No translocator actions from the dead (their translocator is still
		// held for a while): not this move's, nor a resent or held one.
		KeepDelta = MoveDeltaTime;
		if ((MoveDeltaTime & 0x0E) == 0)
			KeepDelta = MoveDeltaTime & ~0xF0;
		IGPlus_DetHeldCount = 0;
		Global.xxServerMove(
			TimeStamp,
			KeepDelta,
			Accel,
			ClientLocX,
			ClientLocY,
			ClientLocZ,
			ClientVel,
			KeepData,
			KeepData2,
			View,
			ClientBase,
			OldMoveData1,
			OldMoveData2,
			0.0,
			0,
			PRTData);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local actor ViewActor;

		//fixme - try to pick view with killer visible
		//fixme - also try varying starting pitch

		if (Settings.bEnableKillCam == false || KillCamDuration <= 0.0 || KillCamDelay > 0.0) {
			ViewRotation.Pitch = 56000;

			cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
		} else {
			KillCamTargetRotation = ViewRotation;
		}
	}

	function EndState()
	{
		RotationRate = default.RotationRate;
		SetPhysics(PHYS_None);
		Super.EndState();
		LastKillTime = 0;
		LastKiller = none;
		ClientUpdateTime = 0;
		bDodging = false;
		MultiDodgesRemaining = bbPlayerReplicationInfo(PlayerReplicationInfo).MaxMultiDodges;
	}

}

state CountdownDying extends Dying
{

	exec function Fire( optional float F ) {}

	function EndState() {
		// Dying.BeginState zeroed it and this EndState replaces Dying's, which
		// puts it back. Without this nobody's body tilted with their aim in
		// the first life after warm-up.
		RotationRate = default.RotationRate;
		bBehindView = false;
		if (Player != none)
			ServerReStartPlayer();
		bShowScores = false;
		ClientUpdateTime = 0;
	}

}

state GameEnded
{
ignores SeePlayer, HearNoise, KilledBy, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, TakeDamage, PainTimer, Died;

	function ServerReStartGame();

	event PlayerTick( float DeltaTime )
	{
		xxPlayerTickEvents(DeltaTime);
		zzTick = DeltaTime;
		Super.PlayerTick(DeltaTime);

		if (Role < ROLE_Authority && IGPlus_EnableInputReplication)
			IGPlus_ReplicateInput(DeltaTime);
	}

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;

		GetAxes(ViewRotation,X,Y,Z);
		// Update view rotation.

		if ( !bFixedCamera )
		{
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0)
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
		}
		else if ( ViewTarget != None )
			ViewRotation = ViewTarget.Rotation;

		ViewShake(DeltaTime);
		ViewFlash(DeltaTime);

		if ( Role < ROLE_Authority && IGPlus_EnableInputReplication == false ) // then save this move and replicate it
			xxReplicateMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, vect(0,0,0), DODGE_None, rot(0,0,0));
		bPressedJump = false;
	}

	function xxServerMove
	(
		float TimeStamp,
		int MoveDeltaTime,
		vector Accel,
		float ClientLocX,
		float ClientLocY,
		float ClientLocZ,
		vector ClientVel,
		int MiscData,
		int MiscData2,
		int View,
		Actor ClientBase,
		optional int OldMoveData1,
		optional int OldMoveData2,
		optional float DetRedoTS,
		optional int DetRedoData,
		optional int PRTData
	)
	{
		// Adaptive Buffering: a queued player's move waits for its turn, and
		// runs through the xxServerMove of the state we are in by then.
		IGPlus_ABIntercept(TimeStamp, MoveDeltaTime, Accel, ClientLocX, ClientLocY, ClientLocZ, ClientVel,
			MiscData, MiscData2, View, ClientBase, OldMoveData1, OldMoveData2, DetRedoTS, DetRedoData, PRTData);
		if (IGPlus_ABKept)
			return;
		IGPlus_ABSeen = IGPlus_ABPlaying == false;

		Global.xxServerMove(
			TimeStamp,
			MoveDeltaTime,
			Accel,
			ClientLocX,
			ClientLocY,
			ClientLocZ,
			ClientVel,
			MiscData,
			MiscData2,
			((ViewRotation.Pitch & 0xFFFF) << 16) | (ViewRotation.Yaw & 0xFFFF),
			ClientBase,
			OldMoveData1,
			OldMoveData2,
			DetRedoTS,
			DetRedoData,
			PRTData);
	}

	function FindGoodView()
	{
		local vector cameraLoc;
		local rotator cameraRot;
		local int tries, besttry;
		local float bestdist, newdist;
		local int startYaw;
		local actor ViewActor;

		ViewRotation.Pitch = 56000;
		tries = 0;
		besttry = 0;
		bestdist = 0.0;
		startYaw = ViewRotation.Yaw;

		for (tries=0; tries<16; tries++)
		{
			if ( ViewTarget != None )
				cameraLoc = ViewTarget.Location;
			else
				cameraLoc = Location;
			PlayerCalcView(ViewActor, cameraLoc, cameraRot);
			newdist = VSize(cameraLoc - Location);
			if (newdist > bestdist)
			{
				bestdist = newdist;
				besttry = tries;
			}
			ViewRotation.Yaw += 4096;
		}

		ViewRotation.Yaw = startYaw + besttry * 4096;
	}
}

simulated function FootStepping()
{
	if (Settings != none && Settings.bNoOwnFootsteps)
		if (Role == ROLE_AutonomousProxy || (Player != none && Player.IsA('Viewport')) || GetLocalPlayer().ViewTarget == self)
			return;

	if (IGPlus_LocationOffsetFix_Moved) {
		IGPlus_LocationOffsetFix_FootstepQueued = true;
		return;
	}

	super.FootStepping();
}

function xxDoShot()
{
	local string zzS;

	zzS = ConsoleCommand("shot");

	if (zzMagicCode != "")
	{
		xxServerAckScreenshot(zzS, zzMagicCode);
		zzMagicCode = "";
	}
	zzbReportScreenshot = false;
}

simulated function bool ClientCannotShoot(optional Weapon W, optional byte Mode, optional bool bIgnoreFireTime)
{
	local bool bCant;
	local name WeapState;

	if (Level.TimeSeconds - zzSpawnedTime <= 0.3)
	{
		bCant = true;
	}
	else if (PendingWeapon != None)
	{
		PendingWeapon.bChangeWeapon = false;
		bCant = true;
	}
	else if (Weapon.IsInState('ClientDown'))
	{
		bCant = true;
	}
	else if (Weapon.AnimSequence == 'Down')
	{
		bCant = true;
	}
	else if (!Weapon.bWeaponUp)
	{
		WeapState = Weapon.GetStateName();
		if (WeapState == 'ClientFiring' || WeapState == 'ClientAltFiring' || WeapState == 'Idle' || WeapState == '' || WeapState == Weapon.Class.Name || Weapon.AnimSequence == 'Still')
			Weapon.bWeaponUp = true;
		else
			bCant = true;
	}
	else if (IsInState('Dying'))
	{
		bCant = true;
	}
	else if (Player == None)
	{
		bCant = true;
	}
	else if ((Weapon != None) && Weapon.IsInState('ClientActive'))
	{
		Weapon.GotoState('');
		Weapon.TweenAnim('Still', 0);
	}
	return bCant;
}

function xxPlayerTickEvents(float DeltaTime)
{
	local float TITarget, TIGap, TIMove;
	local float CurrentTime;

	CurrentTime = Level.TimeSeconds;
	NetStatsElem.FrameTime = DeltaTime / Level.TimeDilation;

	if (Role == ROLE_AutonomousProxy) {
		IGPlus_CameraCorrectionDecay(DeltaTime);
		if (bDrawDebugData && CurrentTime >= IGPlus_SkipNextLine) {
			if (IGPlus_SkipNextLine > 0.0 && IGPlus_SkipGlides > 0)
				ClientDebugMessage("Skipped paths drawn from the gun:"@"glides="$IGPlus_SkipGlides@"replays="$IGPlus_SkipReplays);
			IGPlus_SkipGlides = 0;
			IGPlus_SkipReplays = 0;
			IGPlus_SkipNextLine = CurrentTime + 30.0 * Level.TimeDilation;
		}
		// For server demos (the server records it demo-only).
		IGPlus_ClientFOV = byte(Clamp(int(FOVAngle + 0.5), 1, 255));
		IGPlus_ClientZoomed = bZooming || DesiredFOV != DefaultFOV;

		// A console 'set' can't be refused: put locked settings back twice a second.
		if (IGPlus_ForcedSettings_Applied && CurrentTime >= IGPlus_ForcedSettings_EnforceAt) {
			IGPlus_ForcedSettings_EnforceAt = CurrentTime + 0.5;
			IGPlus_ForcedSettingsEnforce();
		}

		// Precise Rewind Time: what the last frame showed (the one a click
		// now was aimed at), then this frame's newest update. Players are
		// drawn from their newest update, carried forward since it arrived.
		if (IGPlus_PRTSeenAt > 0) {
			IGPlus_PRTShownTick = IGPlus_PRTSeenTick;
			IGPlus_PRTShownAge = FMax(0, CurrentTime - DeltaTime - IGPlus_PRTSeenAt);
			IGPlus_PRTShownTime = CurrentTime - DeltaTime;
			IGPlus_PRTShownLead = IGPlus_PRTSeenLead;
		}
		if (IGPlus_PRTServerTick != IGPlus_PRTSeenTick) {
			IGPlus_PRTSeenTick = IGPlus_PRTServerTick;
			IGPlus_PRTSeenAt = CurrentTime;
			IGPlus_PRTSeenLead = DeltaTime;
		}
		// Tick Interpolation: the server's tick position now. It runs with our
		// own clock and is pulled toward the newest tick number a little each
		// frame, so that the uneven arrival of the updates does not show.
		//
		// Our own download can come late for a while and then catch up (wifi,
		// a busy line): a tick number arrives over IGPLUS_TI_RECV_SNAP ticks
		// later or earlier than the clock says. The clock used to be set at
		// once both times, and every player on screen stepped back and then
		// jumped ahead. Now such a moment starts a hold (IGPlus_TI_bRecv). A
		// late tick number still sets the clock back at once, but the players
		// do not step back for it (IGPlus_TI_Pace). When the line catches up
		// the clock stays where it is, behind the newest tick number by what
		// the line was late, at most IGPLUS_TI_RECV_MAX ticks: the next time
		// the line is that late the players are drawn on from updates that
		// are already here. What no late update needed for a few seconds is
		// given back slowly, and with nothing in hand the hold is over
		// (IGPlus_TI_HeldMove). The shot reports the tick position its target
		// was drawn at, as always, so the server tests the same picture. A
		// client that never sees a tick number that late runs none of this.
		if (IGPlus_EnableTickInterp) {
			if (IGPlus_TI_TickLen <= 0.0)
				IGPlus_TI_TickLen = 0.01;
			if (IGPlus_TI_ServerTick != IGPlus_TI_SeenTick) {
				// (A tick number that came over IGPLUS_TI_RECV_LATE ticks early or
				// late says how our line is, not how long a tick is. Counted, one
				// late tick number of 5 ticks makes the estimate 10% too long, and
				// a clock that runs on it loses those 5 ticks until it is pulled
				// back. A steady line has none: its tick numbers come within about
				// a tick of their time at any frame rate. Twenty in a row are the
				// estimate being wrong, on a server with long ticks: then one counts.)
				if (IGPlus_TI_SeenAt > 0.0 && IGPlus_TI_ServerTick > IGPlus_TI_SeenTick && IGPlus_TI_ServerTick - IGPlus_TI_SeenTick < 20) {
					if (IGPlus_TI_TickLenSkips >= 20
						|| Abs((CurrentTime - IGPlus_TI_SeenAt) / IGPlus_TI_TickLen - float(IGPlus_TI_ServerTick - IGPlus_TI_SeenTick)) <= IGPLUS_TI_RECV_LATE) {
						IGPlus_TI_TickLen += ((CurrentTime - IGPlus_TI_SeenAt) / float(IGPlus_TI_ServerTick - IGPlus_TI_SeenTick) - IGPlus_TI_TickLen) * 0.02;
						IGPlus_TI_TickLenSkips = 0;
					} else {
						IGPlus_TI_TickLenSkips++;
					}
				}
				IGPlus_TI_SeenTick = IGPlus_TI_ServerTick;
				IGPlus_TI_SeenAt = CurrentTime;
			}
			TITarget = float(IGPlus_TI_SeenTick) + (CurrentTime - IGPlus_TI_SeenAt) / IGPlus_TI_TickLen;
			IGPlus_TI_Clock += DeltaTime / IGPlus_TI_TickLen;
			TIGap = TITarget - IGPlus_TI_Clock;
			if (Abs(TIGap) > IGPLUS_TI_RECV_FREEZE) {
				// Our download stopped for longer than a hold can cover (a full
				// line, a short outage, a freeze of our own game, a join): when it
				// comes back the clock is set at once, and a hold ends. Drawn that
				// far behind, the other players would stay old for seconds, and no
				// shot aimed at them could be taken by the server. The players
				// stand still while nothing comes (IGPLUS_TI_MAX_CARRY), and jump
				// to the present once their updates are here.
				IGPlus_TI_Clock = TITarget;
				IGPlus_TI_StClockSnaps++;
				if (Abs(TIGap) <= IGPLUS_TI_RECV_FAR)
					IGPlus_TI_StFreezes++;
				IGPlus_TI_bRecv = false;
				IGPlus_TI_Recv = 0.0;
			} else {
				if (IGPlus_TI_bRecv == false && Abs(TIGap) > IGPLUS_TI_RECV_SNAP) {
					IGPlus_TI_bRecv = true;
					IGPlus_TI_RecvMin = 0.0;
					IGPlus_TI_RecvMinPrev = 0.0;
					IGPlus_TI_RecvTop = 0.0;
					IGPlus_TI_RecvTopPrev = 0.0;
					IGPlus_TI_RecvAt = CurrentTime;
				}
				if (IGPlus_TI_bRecv) {
					TIMove = IGPlus_TI_HeldMove(TIGap, FMin(IGPlus_TI_RecvMin, IGPlus_TI_RecvMinPrev), DeltaTime / IGPlus_TI_TickLen);
					if (Abs(TIMove) > IGPLUS_TI_RECV_SNAP)
						IGPlus_TI_StClockSnaps++;
					IGPlus_TI_Clock += TIMove;
					TIGap -= TIMove;
					// What the stretches noted was measured from where the clock was.
					// (Only when it gave some back: set back by a late tick number
					// it holds no more than before, the line is that much later.)
					if (TIMove > 0.0) {
						IGPlus_TI_RecvMin -= TIMove;
						IGPlus_TI_RecvMinPrev -= TIMove;
						IGPlus_TI_RecvTop -= TIMove;
						IGPlus_TI_RecvTopPrev -= TIMove;
					}
					IGPlus_TI_RecvMin = FMin(IGPlus_TI_RecvMin, TIGap);
					IGPlus_TI_RecvTop = FMax(IGPlus_TI_RecvTop, TIGap);
					IGPlus_TI_Recv = FMax(0.0, TIGap);
					if (CurrentTime - IGPlus_TI_RecvAt >= IGPLUS_TI_RECV_TIME || CurrentTime < IGPlus_TI_RecvAt) {
						if (IGPlus_TI_RecvTop < IGPLUS_TI_RECV_LEAVE) {
							IGPlus_TI_bRecv = false;
							IGPlus_TI_Recv = 0.0;
						}
						IGPlus_TI_RecvMinPrev = IGPlus_TI_RecvMin;
						IGPlus_TI_RecvMin = TIGap;
						IGPlus_TI_RecvTopPrev = IGPlus_TI_RecvTop;
						IGPlus_TI_RecvTop = TIGap;
						IGPlus_TI_RecvAt = CurrentTime;
					}
				} else {
					IGPlus_TI_Clock += TIGap * 0.1;
				}
			}
			// The animation of the other players is shown later by what is held
			// when our line is at its best, not by what is held this frame: that
			// drops and comes back with every late moment, and their legs would
			// skip each time. It follows evenly, 15% at most.
			TIMove = 0.0;
			if (IGPlus_TI_bRecv)
				TIMove = FMax(0.0, FMax(IGPlus_TI_RecvTop, IGPlus_TI_RecvTopPrev));
			IGPlus_TI_RecvAnim += FClamp(TIMove - IGPlus_TI_RecvAnim,
				-IGPLUS_TI_MU_SLEW_FAR * DeltaTime / IGPlus_TI_TickLen, IGPLUS_TI_MU_SLEW_FAR * DeltaTime / IGPlus_TI_TickLen);
			IGPlus_TI_StRecvFrames++;
			IGPlus_TI_StRecvSum += IGPlus_TI_Recv;
			IGPlus_TI_StRecvMax = FMax(IGPlus_TI_StRecvMax, IGPlus_TI_Recv);
			// enableDebugData: one line per other player every 30 seconds.
			if (bDrawDebugData && Level.TimeSeconds >= IGPlus_TI_StNextLine) {
				IGPlus_TI_LogStats(IGPlus_TI_StNextLine > 0.0);
				IGPlus_TI_StNextLine = Level.TimeSeconds + 30.0 * Level.TimeDilation;
				IGPlus_TI_StSince = Level.TimeSeconds;
			} else if (bDrawDebugData == false) {
				IGPlus_TI_StNextLine = 0.0;
			}
		}
		if (IGPlus_DetServerShotTS != IGPlus_DetServerShotSeen) {
			IGPlus_DetServerShotSeen = IGPlus_DetServerShotTS;
			IGPlus_DetSyncShotClock(IGPlus_DetServerShotTS);
		}

		if (IGPlus_DetTloc != none) {
			if (IGPlus_DetTloc.bDeleteMe)
				IGPlus_DetTloc = none;
			else
				IGPlus_DetTloc.IGPlus_DetClientTick();
		}

		// A disc the server kept after all (refused translocation) shows again.
		if (IGPlus_TlocHiddenDisc != none && CurrentTime > IGPlus_TlocHiddenUntil) {
			if (IGPlus_TlocHiddenDisc.bDeleteMe == false) {
				IGPlus_TlocHiddenDisc.bHidden = false;
				if (IGPlus_TlocHiddenDisc.Glow != none)
					IGPlus_TlocHiddenDisc.Glow.bHidden = false;
			}
			IGPlus_TlocHiddenDisc = none;
		}
	}

	if (Level.NetMode == NM_Client)
	{
		if (ConsoleCommand("get ini:engine.engine.gamerenderdevice SmoothMaskedTextures") ~= "true") {
			// SmoothMaskedTextures makes certain textures see-through
			// --> force it off
			ConsoleCommand("set ini:engine.engine.gamerenderdevice SmoothMaskedTextures False");
		}

		if (Player.CurrentNetSpeed != 0 && CurrentTime - zzLastStuffUpdate > 500.0/Player.CurrentNetSpeed)
		{
			xxGetDemoPlaybackSpec();
			zzLastStuffUpdate = CurrentTime;
		}
	}

	if (zzbIsWarmingUp)
		ClearProgressMessages();

	if (zzbReportScreenshot)
		xxDoShot();

	if (PureLevel != None)	// Why would this be None?!
		zzbDemoRecording = PureLevel.zzDemoRecDriver != None;

	// Here: our own player gets PlayerTick, never Tick. And before the demo
	// records this frame, so a copy ends in the same demo frame as the
	// server's copy that replaced it arrives, as on our screen.
	if (IGPlus_DemoCopies > 0)
		IGPlus_DemoCopiesTick();

	if (!bDemoStarted && zzbGameStarted && (zzbForceDemo || Settings.bAutoDemo && (DeathMatchPlus(Level.Game) == none || DeathMatchPlus(Level.Game).CountDown < 1)))
		xxClientDemoRec();
	if (bDemoStarted && (zzbForceDemo || Settings.bAutoDemo) && GameReplicationInfo.GameEndedComments != "") {
		if (IGPlus_GameEndedTime == 0)
			IGPlus_GameEndedTime = Level.TimeSeconds;
		else if (Level.TimeSeconds >= IGPlus_GameEndedTime + 2.0)
			ConsoleCommand("StopDemo");
	}

	// Auto Debug Data (server setting): on once per map when the server says
	// the match runs, off 2 s after it ends, which saves the file. Once per
	// map, so enableDebugData 0 during the match stays off.
	if (IGPlus_AutoDebugData && IGPlus_AutoDebugStarted == false
		&& Viewport(Player) != none && IGPlus_InDemoPlayback() == false
	) {
		IGPlus_AutoDebugStarted = true;
		if (bDrawDebugData == false)
			enableDebugData(true);
	}
	if (IGPlus_AutoDebugStarted && bDrawDebugData && GameReplicationInfo.GameEndedComments != "") {
		if (IGPlus_AutoDebugEndTime == 0)
			IGPlus_AutoDebugEndTime = Level.TimeSeconds;
		else if (Level.TimeSeconds >= IGPlus_AutoDebugEndTime + 2.0)
			enableDebugData(false);
	}

	// Recording a client demo: our clock goes into it from its first frame
	// (IGPlus_ClientDemoClock). After AutoDemo, which may just have started one.
	if (IGPlus_DemoRecClock == none && Level.NetMode == NM_Client && PureLevel != None && PureLevel.zzDemoRecDriver != None)
		IGPlus_DemoRecClock = Spawn(class'IGPlus_ClientDemoClock');
}

static function SetForcedSkin(Actor SkinActor, int selectedSkin, bool bTeamGame, int TeamNum) {
	local string suffix;
	local bbPlayer P;
	local bbPlayerReplicationInfo PRI;
	/**
	* @Author: spect
	* @Date: 2020-02-21 01:17:00
	* @Desc: Sets the selected forced skin client side
	*/

	if (selectedSkin > 17)
		selectedSkin = 12;

	suffix = "";
	if (bTeamGame)
		suffix = "t_"$TeamNum;

	P = bbPlayer(SkinActor);

	switch (selectedSkin) {
		case 0: // Female Commando Aphex
			SetSkinElement(SkinActor, 0, "FCommandoSkins.aphe1"$suffix, "FCommandoSkins.aphe");
			SetSkinElement(SkinActor, 1, "FCommandoSkins.aphe2"$suffix, "FCommandoSkins.aphe");
			// Set the face
			SetSkinElement(SkinActor, 3, "FCommandoSkins.aphe4Indina", "FCommandoSkins.aphe");
			break;
		case 1: // Female Commando Anna
			SetSkinElement(SkinActor, 0, "FCommandoSkins.cmdo1"$suffix, "FCommandoSkins.cmdo");
			SetSkinElement(SkinActor, 1, "FCommandoSkins.cmdo2"$suffix, "FCommandoSkins.cmdo");
			// Set the face
			SetSkinElement(SkinActor, 3, "FCommandoSkins.cmdo4Anna", "FCommandoSkins.anna");
			break;
		case 2: // Female Commando Mercenary
			SetSkinElement(SkinActor, 0, "FCommandoSkins.daco1"$suffix, "FCommandoSkins.daco");
			SetSkinElement(SkinActor, 1, "FCommandoSkins.daco2"$suffix, "FCommandoSkins.daco");
			// Set the face
			SetSkinElement(SkinActor, 3, "FCommandoSkins.daco4Jayce", "FCommandoSkins.daco");
			break;
		case 3: // Female Commando Necris
			SetSkinElement(SkinActor, 0, "FCommandoSkins.goth1"$suffix, "FCommandoSkins.goth");
			SetSkinElement(SkinActor, 1, "FCommandoSkins.goth2"$suffix, "FCommandoSkins.goth");
			// Set the face
			SetSkinElement(SkinActor, 3, "FCommandoSkins.goth4Cryss", "FCommandoSkins.goth");
			break;
		case 4: // Female Soldier Marine
			SetSkinElement(SkinActor, 0, "SGirlSkins.fbth1"$suffix, "SGirlSkins.fbth");
			SetSkinElement(SkinActor, 1, "SGirlSkins.fbth2"$suffix, "SGirlSkins.fbth");
			SetSkinElement(SkinActor, 2, "SGirlSkins.fbth3", "SGirlSkins.fbth");
			// Set the face
			SetSkinElement(SkinActor, 3, "SGirlSkins.fbth4Annaka", "SGirlSkins.fbth");
			break;
		case 5: // Female Soldier Metal Guard
			SetSkinElement(SkinActor, 0, "SGirlSkins.Garf1"$suffix, "SGirlSkins.Garf");
			SetSkinElement(SkinActor, 1, "SGirlSkins.Garf2"$suffix, "SGirlSkins.Garf");
			SetSkinElement(SkinActor, 2, "SGirlSkins.Garf3", "SGirlSkins.Garf");
			// Set the face
			SetSkinElement(SkinActor, 3, "SGirlSkins.Garf4Isis", "SGirlSkins.Garf");
			break;
		case 6: // Female Soldier Soldier
			SetSkinElement(SkinActor, 0, "SGirlSkins.army1"$suffix, "SGirlSkins.army");
			SetSkinElement(SkinActor, 1, "SGirlSkins.army2"$suffix, "SGirlSkins.army");
			SetSkinElement(SkinActor, 2, "SGirlSkins.army3", "SGirlSkins.army");
			// Set the face
			SetSkinElement(SkinActor, 3, "SGirlSkins.army4Lauren", "SGirlSkins.army");
			break;
		case 7: // Female Soldier Venom
			SetSkinElement(SkinActor, 0, "SGirlSkins.Venm1"$suffix, "SGirlSkins.Venm");
			SetSkinElement(SkinActor, 1, "SGirlSkins.Venm2"$suffix, "SGirlSkins.Venm");
			SetSkinElement(SkinActor, 2, "SGirlSkins.Venm3", "SGirlSkins.Venm");
			// Set the face
			SetSkinElement(SkinActor, 3, "SGirlSkins.Venm4Athena", "SGirlSkins.Venm");
			break;
		case 8: // Female Soldier War Machine
			SetSkinElement(SkinActor, 0, "SGirlSkins.fwar1"$suffix, "SGirlSkins.fwar");
			SetSkinElement(SkinActor, 1, "SGirlSkins.fwar2"$suffix, "SGirlSkins.fwar");
			SetSkinElement(SkinActor, 2, "SGirlSkins.fwar3", "SGirlSkins.fwar");
			// Set the face
			SetSkinElement(SkinActor, 3, "SGirlSkins.fwar4Cathode", "SGirlSkins.fwar");
			break;
		case 9: // Male Commando Commando
			SetSkinElement(SkinActor, 3, "CommandoSkins.cmdo4"$suffix, "CommandoSkins.cmdo");
			SetSkinElement(SkinActor, 2, "CommandoSkins.cmdo3"$suffix, "CommandoSkins.cmdo");
			SetSkinElement(SkinActor, 0, "CommandoSkins.cmdo1", "CommandoSkins.cmdo");
			// Set the face
			SetSkinElement(SkinActor, 1, "CommandoSkins.cmdo2Blake", "CommandoSkins.cmdo");
			break;
		case 10: // Male Commando Mercenary
			SetSkinElement(SkinActor, 3, "CommandoSkins.daco4"$suffix, "CommandoSkins.daco");
			SetSkinElement(SkinActor, 2, "CommandoSkins.daco3"$suffix, "CommandoSkins.daco");
			SetSkinElement(SkinActor, 0, "CommandoSkins.daco1", "CommandoSkins.daco");
			// Set the face
			SetSkinElement(SkinActor, 1, "CommandoSkins.daco2Boris", "CommandoSkins.daco");
			break;
		case 11: // Male Commando Necris
			SetSkinElement(SkinActor, 3, "CommandoSkins.goth4"$suffix, "CommandoSkins.goth");
			SetSkinElement(SkinActor, 2, "CommandoSkins.goth3"$suffix, "CommandoSkins.goth");
			SetSkinElement(SkinActor, 0, "CommandoSkins.goth1", "CommandoSkins.goth");
			// Set the face
			SetSkinElement(SkinActor, 1, "CommandoSkins.goth2Grail", "CommandoSkins.goth");
			break;
		case 12: // Male Soldier Marine
			SetSkinElement(SkinActor, 0, "SoldierSkins.blkt1"$suffix, "SoldierSkins.blkt");
			SetSkinElement(SkinActor, 1, "SoldierSkins.blkt2"$suffix, "SoldierSkins.blkt");
			SetSkinElement(SkinActor, 2, "SoldierSkins.blkt3", "SoldierSkins.blkt");
			// Set the face
			SetSkinElement(SkinActor, 3, "SoldierSkins.blkt4Malcom", "SoldierSkins.blkt");
			break;
		case 13: // Male Soldier Metal Guard
			SetSkinElement(SkinActor, 0, "SoldierSkins.Gard1"$suffix, "SoldierSkins.Gard");
			SetSkinElement(SkinActor, 1, "SoldierSkins.Gard2"$suffix, "SoldierSkins.Gard");
			SetSkinElement(SkinActor, 2, "SoldierSkins.Gard3", "SoldierSkins.Gard");
			// Set the face
			SetSkinElement(SkinActor, 3, "SoldierSkins.Gard4Drake", "SoldierSkins.Gard");
			break;
		case 14: // Male Soldier Raw Steel
			SetSkinElement(SkinActor, 0, "SoldierSkins.RawS1"$suffix, "SoldierSkins.RawS");
			SetSkinElement(SkinActor, 1, "SoldierSkins.RawS2"$suffix, "SoldierSkins.RawS");
			SetSkinElement(SkinActor, 2, "SoldierSkins.RawS3", "SoldierSkins.RawS");
			// Set the face
			SetSkinElement(SkinActor, 3, "SoldierSkins.RawS4Arkon", "SoldierSkins.RawS");
			break;
		case 15: // Male Soldier Soldier
			SetSkinElement(SkinActor, 0, "SoldierSkins.sldr1"$suffix, "SoldierSkins.sldr");
			SetSkinElement(SkinActor, 1, "SoldierSkins.sldr2"$suffix, "SoldierSkins.sldr");
			SetSkinElement(SkinActor, 2, "SoldierSkins.sldr3", "SoldierSkins.sldr");
			// Set the face
			SetSkinElement(SkinActor, 3, "SoldierSkins.sldr4Brock", "SoldierSkins.sldr");
			break;
		case 16: // Male Soldier War Machine
			SetSkinElement(SkinActor, 0, "SoldierSkins.hkil1"$suffix, "SoldierSkins.hkil");
			SetSkinElement(SkinActor, 1, "SoldierSkins.hkil2"$suffix, "SoldierSkins.hkil");
			SetSkinElement(SkinActor, 2, "SoldierSkins.hkil3", "SoldierSkins.hkil");
			// Set the face
			SetSkinElement(SkinActor, 3, "SoldierSkins.hkil4Matrix", "SoldierSkins.hkil");
			break;
		case 17: // Boss
			SetSkinElement(SkinActor, 0, "BossSkins.Boss1"$suffix, "BossSkins.Boss");
			SetSkinElement(SkinActor, 1, "BossSkins.Boss2"$suffix, "BossSkins.Boss");
			SetSkinElement(SkinActor, 2, "BossSkins.Boss3"$suffix, "BossSkins.Boss");
			// Set the face (Xan has different head colours? Makes sense, he's a robot.)
			SetSkinElement(SkinActor, 3, "BossSkins.Boss4"$suffix, "BossSkins.Boss");
			break;
		default:
			if (P != none && P.bAppearanceChanged) {
				PRI = bbPlayerReplicationInfo(P.PlayerReplicationInfo);
				P.static.SetMultiSkin(SkinActor, PRI.SkinName, PRI.FaceName, TeamNum);
				P.bAppearanceChanged = false;
			}
			return;
	}
	if (P != none)
		P.bAppearanceChanged = true;
}

function int GetForcedSkinForPlayer(PlayerReplicationInfo PRI) {
	local string Anim;
	local bbPlayerReplicationInfo bbPRI;

	Anim = string(PRI.Owner.AnimSequence);
	if (Left(Anim, 8) ~= "DeathEnd") {
		// Dont force skin when feigning death to match actual death animations
		return -1;
	}

	if (GameReplicationInfo.bTeamGame && PRI.Team == PlayerReplicationInfo.Team) {
		if (Settings.bSkinTeamUseIndexMap) {
			bbPRI = bbPlayerReplicationInfo(PRI);
			if (bbPRI != none && bbPRI.SkinIndex >= 0) {
				return Settings.SkinTeamIndexMap[bbPRI.SkinIndex];
			}
		}
		if (PRI.bIsFemale) {
			return Settings.DesiredTeamSkinFemale;
		} else {
			return Settings.DesiredTeamSkin;
		}
	} else {
		if (Settings.bSkinEnemyUseIndexMap) {
			bbPRI = bbPlayerReplicationInfo(PRI);
			if (bbPRI != none && bbPRI.SkinIndex >= 0) {
				return Settings.SkinEnemyIndexMap[bbPRI.SkinIndex];
			}
		}
		if (PRI.bIsFemale) {
			return Settings.DesiredSkinFemale;
		} else {
			return Settings.DesiredSkin;
		}
	}

	return -1;
}

// Team Color and Enemy Color. Every stock forced skin comes in red, blue,
// green and gold (t_0 to t_3). A player's own skin keeps their team's color,
// it may not have the other two.
function int GetForcedSkinColor(PlayerReplicationInfo PRI, int Skin) {
	local int C;

	if (Skin < 0 || Skin > 17)
		return PRI.Team;
	if (PRI.Team == PlayerReplicationInfo.Team)
		C = Settings.TeamColor;
	else
		C = Settings.EnemyColor;
	if (C < 0 || C > 3)
		return PRI.Team;
	return C;
}

function bool IsForcedSkinFemale(int Skin) {
	return Skin >= 0 && Skin <= 8;
}

function bool IsForcedSkinMale(int Skin) {
	return Skin > 8 && Skin <= 17;
}

function SetForcedMesh(PlayerReplicationInfo PRI, int Skin) {
	local Mesh NewMesh;

	if (PRI.Owner == none) return;

	if (Skin >= 0 && Skin <= 17) {
		if (PRI.bIsFemale == IsForcedSkinFemale(Skin)) {
			NewMesh = class'IGPlus_Assets'.static.Msh(class'IGPlus_ModelImport'.default.DefaultMesh[Skin], class'IGPlus_Assets'.static.ForcedMeshName(Skin, false));
		} else {
			NewMesh = class'IGPlus_Assets'.static.Msh(class'IGPlus_ModelImport'.default.RateCorrectedMesh[Skin], class'IGPlus_Assets'.static.ForcedMeshName(Skin, true));
		}
	} else {
		NewMesh = PRI.Owner.default.Mesh;
	}

	// Never no model (a broken default): keep what the player has.
	if (NewMesh == none)
		return;

	if (PRI.Owner.Mesh != NewMesh)
		PRI.Owner.Mesh = NewMesh;
}

function ApplyForcedSkins(PlayerReplicationInfo PRI) {
	local int Skin;

	/**
	 * @Author: spect
	 * @Date: 2020-02-18 02:20:22
	 * @Desc: Applies the forced skin client side if force models is enabled.
	 */

	// udemo calls the recorder's PreRender during playback, so this runs there too
	if (zzbForceModels && IGPlus_ShowRealModelsInDemo() == false) {
		Skin = GetForcedSkinForPlayer(PRI);
		SetForcedMesh(PRI, Skin);
		SetForcedSkin(PRI.Owner, Skin, GameReplicationInfo.bTeamGame, GetForcedSkinColor(PRI, Skin));
	} else if (bbPlayer(PRI.Owner) != none && IGPlus_ShowRealModelsInDemo()) {
		bbPlayer(PRI.Owner).IGPlus_DemoRestoreRealModel();
	}
}

function ApplyBrightskins(PlayerReplicationInfo PRI) {
	local string Anim;
	local Pawn P;

	P = Pawn(PRI.Owner);
	if (P == none) return;

	if (BrightskinMode >= 1 && Settings.bUnlitSkins) {
		Anim = string(P.AnimSequence);
		if (Left(Anim, 8) ~= "DeathEnd") {
			//
		} else {
			P.bUnlit = true;
			if (P.Weapon != none)
				P.Weapon.bUnlit = true;
			return;
		}
	}

	P.bUnlit = false;
	if (P.Weapon != none)
		P.Weapon.bUnlit = false;
}

simulated function bool IGPlus_TI_Use() {
	return Role == ROLE_SimulatedProxy && IGPlus_EnableTickInterp && IGPlus_EnableSnapshotInterpolation == false;
}

simulated function bool IGPlus_ShouldUseSnapshotInterpForProxy(optional bbPlayer P) {
	if (P == none)
		P = self;

	return P != none &&
		P.Role == ROLE_SimulatedProxy &&
		P.IGPlus_EnableSnapshotInterpolation;
}

function IGPlus_ApplyWarpFix(PlayerReplicationInfo PRI) {
	local bbPlayer P;
	if (PRI == PlayerReplicationInfo)
		return;

	if (PRI.Owner.IsA('bbPlayer') == false)
		return;

	P = bbPlayer(PRI.Owner);
	if (IGPlus_ShouldUseSnapshotInterpForProxy(P))
		return;
	// Tick Interpolation draws a player only where an update had them. A
	// held player gets no update, so they stop by themselves.
	if (P.IGPlus_TI_Use()) {
		P.IGPlus_bPRTRuleHeld = false;
		return;
	}

	// Adaptive Buffering: the server holds this player still, their next
	// move is late. Stop moving them along now, not after IGPlus_WarpFixDelay.
	// Never set for a player who is not queued.
	P.IGPlus_bPRTRuleHeld = false;
	if (P.IGPlus_WarpFixData.bHold && Level.Pauser == "") {
		P.SetLocation(P.IGPlus_WarpFixData.OldLocation);
		P.IGPlus_bPRTRuleHeld = true;
		P.IGPlus_PRTRuleHeldLoc = P.IGPlus_WarpFixData.OldLocation;
		return;
	}

	if (IGPlus_EnableWarpFix == false)
		return;

	if (Level.Pauser != "") {
		P.IGPlus_WarpFixClientData.TimeStamp = Level.TimeSeconds;
		return;
	}

	if (P.IGPlus_WarpFixData.Counter != P.IGPlus_WarpFixClientData.Last.Counter) {
		P.IGPlus_WarpFixClientData.Last = P.IGPlus_WarpFixData;
		P.IGPlus_WarpFixClientData.TimeStamp = Level.TimeSeconds;
	}

	if (P.IGPlus_WarpFixClientData.TimeStamp + IGPlus_WarpFixDelay >= Level.TimeSeconds)
		return;

	P.SetLocation(P.IGPlus_WarpFixClientData.Last.OldLocation);
}

simulated function IGPlus_UpdateClientSnapInterpDelayReport() {
	local int i;
	local int j;
	local int SampleCount;
	local int MedianDelayMs;
	local float Sample;
	local float DelaySamples[32];
	local PlayerReplicationInfo PRI;
	local bbPlayer P;

	if (Role != ROLE_AutonomousProxy || Level.NetMode != NM_Client)
		return;

	if (IGPlus_EnableSnapshotInterpolation == false) {
		IGPlus_ClientSnapInterpDelayMs = -1;
		IGPlus_ClientSnapInterpDelaySampleCount = 0;
		IGPlus_ClientSnapInterpDelayMedianMs = -1;
		IGPlus_ClientSnapInterpDelaySpreadMs = -1;
		return;
	}

	if (Level.TimeSeconds < IGPlus_NextSnapInterpDelayClientReportTime)
		return;

	IGPlus_NextSnapInterpDelayClientReportTime = Level.TimeSeconds + 0.25;
	SampleCount = 0;

	if (GameReplicationInfo != None && PlayerReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == none)
				break;

			P = bbPlayer(PRI.Owner);
			if (P == none || P == self)
				continue;
			if (P.Role != ROLE_SimulatedProxy)
				continue;
			if (P.IGPlus_EnableSnapshotInterpolation == false)
				continue;
			if (P.IGPlus_SnapInterp_Count < 2)
				continue;
			if (SampleCount >= arraycount(DelaySamples))
				break;

			DelaySamples[SampleCount] = FClamp(P.IGPlus_SnapInterp_InterpDelay * 1000.0, 0.0, 200.0);
			SampleCount++;
		}
	}

	if (SampleCount <= 0) {
		IGPlus_ClientSnapInterpDelayMs = -1;
		IGPlus_ClientSnapInterpDelaySampleCount = 0;
		IGPlus_ClientSnapInterpDelayMedianMs = -1;
		IGPlus_ClientSnapInterpDelaySpreadMs = -1;
		return;
	}

	for (i = 1; i < SampleCount; ++i) {
		Sample = DelaySamples[i];
		j = i - 1;
		while (j >= 0 && DelaySamples[j] > Sample) {
			DelaySamples[j + 1] = DelaySamples[j];
			j--;
		}
		DelaySamples[j + 1] = Sample;
	}

	if ((SampleCount & 1) == 1)
		MedianDelayMs = int(DelaySamples[SampleCount / 2]);
	else
		MedianDelayMs = int(0.5 * (DelaySamples[(SampleCount / 2) - 1] + DelaySamples[SampleCount / 2]));

	IGPlus_ClientSnapInterpDelaySampleCount = SampleCount;
	IGPlus_ClientSnapInterpDelayMedianMs = MedianDelayMs;
	IGPlus_ClientSnapInterpDelaySpreadMs = int(DelaySamples[SampleCount - 1] - DelaySamples[0]);
	IGPlus_ClientSnapInterpDelayMs = Clamp(MedianDelayMs, 0, 200);
}

function IGPlus_UpdateServerSnapInterpDelayEstimate() {
	local float BaselineMs;
	local float MinAllowedMs;
	local float MaxAllowedMs;
	local float ReportedMs;
	local float SmoothedTargetMs;
	local float SmoothedDeltaMs;
	local int MinSampleCount;
	local int MaxSpreadMs;
	local float TrustTimeout;

	if (Role != ROLE_Authority)
		return;

	MinSampleCount = 1;
	MaxSpreadMs = 35;
	TrustTimeout = 1.0;

	if (IGPlus_EnableSnapshotInterpolation == false || zzUTPure == None || zzUTPure.Settings == None) {
		IGPlus_ServerSnapInterpDelayValid = false;
		IGPlus_ServerSnapInterpTrusted = false;
		IGPlus_ServerSnapInterpLastAcceptedTime = 0.0;
		IGPlus_ServerSnapInterpDelayMsSmoothed = 0.0;
		IGPlus_ServerSnapInterpDelayReportedMsEcho = -1;
		IGPlus_ServerSnapInterpDelayClampedMsEcho = -1;
		IGPlus_ServerSnapInterpDelaySmoothedMsEcho = 0;
		IGPlus_ServerSnapInterpDelayValidEcho = false;
		IGPlus_ServerSnapInterpTrustedEcho = false;
		IGPlus_ServerSnapInterpDelayEchoTime = Level.TimeSeconds;
		IGPlus_ServerSnapInterpLastAcceptedTimeEcho = 0.0;
		return;
	}

	if (IGPlus_ServerSnapInterpTrusted &&
		(Level.TimeSeconds - IGPlus_ServerSnapInterpLastAcceptedTime > TrustTimeout)
	) {
		IGPlus_ServerSnapInterpTrusted = false;
	}

	if (Level.TimeSeconds < IGPlus_NextSnapInterpDelayReportTime)
		return;

	IGPlus_NextSnapInterpDelayReportTime = Level.TimeSeconds + 0.25;
	IGPlus_ServerSnapInterpDelayReportedMsEcho = IGPlus_ClientSnapInterpDelayMs;
	if (IGPlus_ClientSnapInterpDelayMs < 0 ||
		IGPlus_ClientSnapInterpDelaySampleCount < MinSampleCount ||
		IGPlus_ClientSnapInterpDelaySpreadMs < 0 ||
		IGPlus_ClientSnapInterpDelaySpreadMs > MaxSpreadMs
	) {
		IGPlus_ServerSnapInterpTrusted = false;
		IGPlus_ServerSnapInterpDelayClampedMsEcho = -1;
		IGPlus_ServerSnapInterpDelaySmoothedMsEcho = int(IGPlus_ServerSnapInterpDelayMsSmoothed + 0.5);
		IGPlus_ServerSnapInterpDelayValidEcho = false;
		IGPlus_ServerSnapInterpTrustedEcho = false;
		IGPlus_ServerSnapInterpDelayEchoTime = Level.TimeSeconds;
		IGPlus_ServerSnapInterpLastAcceptedTimeEcho = IGPlus_ServerSnapInterpLastAcceptedTime;
		return;
	}

	BaselineMs = FMax(0.0, zzUTPure.Settings.SnapshotInterpRewindMs);
	MinAllowedMs = FMax(0.0, BaselineMs - 30.0);
	MaxAllowedMs = FMin(200.0, BaselineMs + 60.0);
	ReportedMs = FClamp(float(IGPlus_ClientSnapInterpDelayMs), MinAllowedMs, MaxAllowedMs);
	IGPlus_ServerSnapInterpDelayClampedMsEcho = int(ReportedMs + 0.5);

	if (IGPlus_ServerSnapInterpDelayValid == false) {
		IGPlus_ServerSnapInterpDelayMsSmoothed = ReportedMs;
		IGPlus_ServerSnapInterpDelayValid = true;
		IGPlus_ServerSnapInterpTrusted = true;
		IGPlus_ServerSnapInterpLastAcceptedTime = Level.TimeSeconds;
		IGPlus_ServerSnapInterpDelaySmoothedMsEcho = int(IGPlus_ServerSnapInterpDelayMsSmoothed + 0.5);
		IGPlus_ServerSnapInterpDelayValidEcho = true;
		IGPlus_ServerSnapInterpTrustedEcho = true;
		IGPlus_ServerSnapInterpDelayEchoTime = Level.TimeSeconds;
		IGPlus_ServerSnapInterpLastAcceptedTimeEcho = IGPlus_ServerSnapInterpLastAcceptedTime;
		return;
	}

	SmoothedTargetMs = IGPlus_ServerSnapInterpDelayMsSmoothed + 0.2 * (ReportedMs - IGPlus_ServerSnapInterpDelayMsSmoothed);
	SmoothedDeltaMs = FClamp(SmoothedTargetMs - IGPlus_ServerSnapInterpDelayMsSmoothed, -10.0, 10.0);
	IGPlus_ServerSnapInterpDelayMsSmoothed = FClamp(
		IGPlus_ServerSnapInterpDelayMsSmoothed + SmoothedDeltaMs,
		MinAllowedMs,
		MaxAllowedMs
	);
	IGPlus_ServerSnapInterpTrusted = true;
	IGPlus_ServerSnapInterpLastAcceptedTime = Level.TimeSeconds;
	IGPlus_ServerSnapInterpDelaySmoothedMsEcho = int(IGPlus_ServerSnapInterpDelayMsSmoothed + 0.5);
	IGPlus_ServerSnapInterpDelayValidEcho = true;
	IGPlus_ServerSnapInterpTrustedEcho = true;
	IGPlus_ServerSnapInterpDelayEchoTime = Level.TimeSeconds;
	IGPlus_ServerSnapInterpLastAcceptedTimeEcho = IGPlus_ServerSnapInterpLastAcceptedTime;
}

exec simulated function SnapInterpNetStatus(optional string TargetFilter) {
	local int EchoAgeMs;
	local int AcceptedAgeMs;

	EchoAgeMs = int((Level.TimeSeconds - IGPlus_ServerSnapInterpDelayEchoTime) * 1000.0);
	if (EchoAgeMs < 0)
		EchoAgeMs = 0;
	AcceptedAgeMs = int((Level.TimeSeconds - IGPlus_ServerSnapInterpLastAcceptedTimeEcho) * 1000.0);
	if (AcceptedAgeMs < 0)
		AcceptedAgeMs = 0;

	ClientMessage(
		"SnapInterpNet client reportMs="$IGPlus_ClientSnapInterpDelayMs$
		" medianMs="$IGPlus_ClientSnapInterpDelayMedianMs$
		" samples="$IGPlus_ClientSnapInterpDelaySampleCount$
		" spreadMs="$IGPlus_ClientSnapInterpDelaySpreadMs$
		" snapEnabled="$IGPlus_EnableSnapshotInterpolation
	);

	ClientMessage(
		"SnapInterpNet server valid="$IGPlus_ServerSnapInterpDelayValidEcho$
		" trusted="$IGPlus_ServerSnapInterpTrustedEcho$
		" reportedMs="$IGPlus_ServerSnapInterpDelayReportedMsEcho$
		" clampedMs="$IGPlus_ServerSnapInterpDelayClampedMsEcho$
		" smoothedMs="$IGPlus_ServerSnapInterpDelaySmoothedMsEcho$
		" ageMs="$EchoAgeMs$
		" acceptedAgeMs="$AcceptedAgeMs
	);

	SnapInterpStatus(TargetFilter);
}

event PreRender( canvas zzCanvas )
{
	local int i;
	local PlayerReplicationInfo zzPRI;
	local WindowConsole C;

	if (PureLevel != None)
		zzbDemoRecording = PureLevel.zzDemoRecDriver != None;

	Super.PreRender(zzCanvas);

	// Tick does not get called when the game is paused, so this is here to
	// ensure players are visible during pauses
	IGPlus_LocationOffsetFix_AfterAll(0);
	// Our own model, drawn in behind view (FlipAnimationFix). PostRender puts the
	// engine's animation back.
	if (Level.NetMode == NM_Client && Role == ROLE_AutonomousProxy)
		IGPlus_FlipFix_Plain();

	if (Role == ROLE_AutonomousProxy && Level.NetMode == NM_Client)
		IGPlus_UpdateClientSnapInterpDelayReport();

	if (IGPlus_SnapInterp_CheckActive && Level.TimeSeconds >= IGPlus_SnapInterp_CheckEndTime)
		IGPlus_SnapInterp_FinishCheck(false);

	if (IGPlus_SnapInterp_NetDebug && Level.TimeSeconds >= IGPlus_SnapInterp_NetDebugNextTime) {
		IGPlus_SnapInterp_NetDebugNextTime = Level.TimeSeconds + 1.0;
		SnapInterpNetStatus();
	}

	if (GameReplicationInfo != None && PlayerReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			zzPRI = GameReplicationInfo.PRIArray[i];
			if (zzPRI == none) break;
			if (zzPRI.Owner == none) continue;
			if (zzPRI.bIsSpectator) continue;

			ApplyForcedSkins(zzPRI);
			ApplyBrightskins(zzPRI);
			IGPlus_ApplyWarpFix(zzPRI);
			// Where this frame draws them: a shot in the next frame was aimed at this.
			if (zzPRI.Owner != self && bbPlayer(zzPRI.Owner) != none && zzPRI.Owner.Role == ROLE_SimulatedProxy) {
				bbPlayer(zzPRI.Owner).IGPlus_ShownLoc = zzPRI.Owner.Location;
				bbPlayer(zzPRI.Owner).IGPlus_ShownFrame = IGPlus_FrameCount;
				bbPlayer(zzPRI.Owner).IGPlus_bShownVisible = zzPRI.Owner.bHidden == false;
				bbPlayer(zzPRI.Owner).IGPlus_ShownR = bbPlayer(zzPRI.Owner).IGPlus_TI_DrawnR;
				bbPlayer(zzPRI.Owner).IGPlus_bShownPast = bbPlayer(zzPRI.Owner).IGPlus_TI_bDrawnPast;
				bbPlayer(zzPRI.Owner).IGPlus_ShownSpan = bbPlayer(zzPRI.Owner).IGPlus_TI_DrawnSpan;
				bbPlayer(zzPRI.Owner).IGPlus_bShownHeld = bbPlayer(zzPRI.Owner).IGPlus_TI_bDrawnHeld;
				bbPlayer(zzPRI.Owner).IGPlus_ShownDuck = bbPlayer(zzPRI.Owner).IGPlus_TI_DrawnDuck;
			}
		}
	}

	if (IGPlus_TryOpenSettingsMenu) {
		IGPlus_TryOpenSettingsMenu = false;

		if (Player != none)
			C = WindowConsole(Player.Console);

		if (C == none)
			return;

		C.bQuickKeyEnable = True;
		C.LaunchUWindow();

		IGPlus_OpenSettingsMenu();
	}
}

simulated function RenderFlagSprite(Canvas C, IGPlus_FlagSprite S, vector Where) {
	local vector Delta;
	Delta = Where - Location;

	S.SetLocation(Where);
	S.DrawScale = FClamp(500/VSize(Delta), 0.125, 0.5);
	S.ScaleGlow = Lerp(1-(Normal(Delta) dot vector(ViewRotation)), 0.5, 4.0);
	C.DrawActor(S, false, true);
}

simulated function RenderDroppedFlags(Canvas C) {
	local CTFReplicationInfo CRI;
	local byte Team;
	local CTFFlag F;

	CRI = CTFReplicationInfo(GameReplicationInfo);
	if (CRI == none)
		return;

	if (PlayerReplicationInfo == none)
		return;

	Team = PlayerReplicationInfo.Team;
	if (Team >= arraycount(CRI.FlagList))
		return;

	F = CRI.FlagList[Team];
	if (F == none)
		return;

	if (F.bHome == false && F.bHeld == false) {
		RenderFlagSprite(C, IGPlus_TeamFlagSprite[Team], F.Location);
	}
}

simulated function RenderFlagCarrier(Canvas C) {
	local CTFReplicationInfo CRI;
	local int i;
	local PlayerReplicationInfo PRI;
	local CTFFlag F;

	CRI = CTFReplicationInfo(GameReplicationInfo);
	if (CRI == none)
		return;

	if (PlayerReplicationInfo == none)
		return;

	for (i = 0; i < arraycount(CRI.PRIArray); i++) {
		PRI = CRI.PRIArray[i];
		if (PRI == none) break; // end of PRIArray
		if (PRI == PlayerReplicationInfo) continue;
		if (PRI.Team != PlayerReplicationInfo.Team) continue;
		if (PRI.HasFlag == none) continue;
		F = CTFFlag(PRI.HasFlag);
		if (F == none) continue;
		if (F != CRI.FlagList[F.Team]) continue;
		if (PRI.Owner == none) continue;

		RenderFlagSprite(C, IGPlus_TeamFlagSprite[F.Team], PRI.Owner.Location);
	}
}

function InitFlagSprites() {
	local int i;

	if (IGPlus_InitFlagSprites == false) {
		IGPlus_InitFlagSprites = true;
		for(i = 0; i < arraycount(IGPlus_TeamFlagSprite); i++) {
			IGPlus_TeamFlagSprite[i] = Spawn(class'IGPlus_FlagSprite', self);
			IGPlus_TeamFlagSprite[i].ConfigureForTeam(i);
		}
	}
}

simulated function IGPlus_DrawServerLocation(Canvas C) {
	if (IGPlus_LocationOffsetFix_DrawDummy == none) {
		IGPlus_LocationOffsetFix_DrawDummy = Spawn(class'IGPlus_CollisionDummy');
		IGPlus_LocationOffsetFix_DrawDummy.bCollideWorld = false;
		IGPlus_LocationOffsetFix_DrawDummy.SetCollision(false, false, false);
		IGPlus_LocationOffsetFix_DrawDummy.SetCollisionSize(0.0, 0.0);
		IGPlus_LocationOffsetFix_DrawDummy.DrawType = DT_Mesh;
	}

	IGPlus_LocationOffsetFix_DrawDummy.bHidden = false;
	IGPlus_LocationOffsetFix_DrawDummy.SetLocation(IGPlus_LocationOffsetFix_ServerLocation);
	IGPlus_LocationOffsetFix_DrawDummy.SetRotation(Rotation);
	IGPlus_LocationOffsetFix_DrawDummy.Mesh = Mesh;
	IGPlus_LocationOffsetFix_DrawDummy.AnimSequence = AnimSequence;
	IGPlus_LocationOffsetFix_DrawDummy.AnimFrame = AnimFrame;

	C.DrawActor(IGPlus_LocationOffsetFix_DrawDummy, true);

	IGPlus_LocationOffsetFix_DrawDummy.bHidden = true;
}

function IGPlus_DrawServerLocations(Canvas C) {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;

	for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); i++) {
		PRI = GameReplicationInfo.PRIArray[i];
		if (PRI == none) break;
		if (PRI.Owner == none) continue;
		P = bbPlayer(PRI.Owner);
		if (P == none) continue;
		if (P.bHidden) continue;
		if (P.Role != ROLE_SimulatedProxy) continue;

		P.IGPlus_DrawServerLocation(C);
	}

}

simulated event RenderOverlays(Canvas C) {
	local Weapon W;
	local vector SavedPVO;
	local bool bShiftWeapon;
	local bool bServerDemoView;

	// Server demo playback: the engine calls this on the followed player.
	bServerDemoView = IGPlus_SDIsServerDemoProxy();
	if (bServerDemoView)
		IGPlus_SDBeforeOverlays();

	// Keep the first-person weapon on the smoothed camera.
	W = Weapon;
	bShiftWeapon = W != none && IGPlus_CameraCorrectionApplied != vect(0,0,0)
		&& ViewTarget == none && bBehindView == false;
	if (bShiftWeapon) {
		SavedPVO = W.PlayerViewOffset;
		W.PlayerViewOffset += IGPlus_WeaponViewOffsetFor(W, IGPlus_CameraCorrectionApplied);
	}

	super.RenderOverlays(C);

	if (bShiftWeapon && W != none)
		W.PlayerViewOffset = SavedPVO;
	IGPlus_CameraCorrectionApplied = vect(0,0,0);

	InitFlagSprites();

	if (IGPlus_AlwaysRenderDroppedFlags)
		RenderDroppedFlags(C);

	if (IGPlus_AlwaysRenderFlagCarrier)
		RenderFlagCarrier(C);

	if (IGPlus_LocationOffsetFix_DrawServerLocation)
		IGPlus_DrawServerLocations(C);

	if (bServerDemoView)
		IGPlus_SDAfterOverlays(C);
}

simulated function vector IGPlus_CurrentLocation() {
	if (IGPlus_LocationOffsetFix_Moved)
		return IGPlus_LocationOffsetFix_OldLocation;
	else
		return Location;
}

simulated function bool IGPlus_LocationOffsetFix_WasVelocityReplicated() {
	if (Abs(Velocity.X - int(Velocity.X)) > 0.0001 || Abs(Velocity.Y - int(Velocity.Y)) > 0.0001)
		return false;

	return true;
}

simulated function IGPlus_LocationOffsetFix_After(float DeltaTime) {
	local float ExtrapolationTime;
	local bool bReplicatedLocation;
	local bool bReplicatedVelocity;
	local bool bMoverTransitionSmoothing;
	local vector VelXpol;
	local float CosAlpha;
	local float SinAlpha;
	local vector LocDelta;
	local vector MaxMove;

	if (IGPlus_LocationOffsetFix_Moved == false)
		return;

	if (IGPlus_LocationOffsetFix_CollisionDummy != none) {
		IGPlus_LocationOffsetFix_CollisionDummy.bCollideWorld = false;
		IGPlus_LocationOffsetFix_CollisionDummy.SetCollision(false, false, false);
	}

	bReplicatedVelocity = IGPlus_LocationOffsetFix_WasVelocityReplicated();

	LocDelta = Location - IGPlus_LocationOffsetFix_SafeLocation;
	MaxMove = 2.0*DeltaTime*Velocity;

	if (bReplicatedVelocity == false) {
		Velocity = IGPlus_LocationOffsetFix_Velocity;

		if (IGPlus_LocationOffsetFix_OnGround == false)
			Velocity += 0.5 * Region.Zone.ZoneGravity * DeltaTime;
	}

	// detect whether server replicated new location
	if (VSize(LocDelta) > VSize(MaxMove) + MaxStepHeight) {
		IGPlus_LocationOffsetFix_PredictionOffset = IGPlus_LocationOffsetFix_OldLocation - Location - IGPlus_LocationOffsetFix_ExtrapolationOffset;
		IGPlus_LocationOffsetFix_OldLocation = Location;
		IGPlus_LocationOffsetFix_PrevServerLocation = IGPlus_LocationOffsetFix_ServerLocation;
		IGPlus_LocationOffsetFix_PrevServerVelocity = IGPlus_LocationOffsetFix_ServerVelocity;
		IGPlus_LocationOffsetFix_PrevServerLocationTime = IGPlus_LocationOffsetFix_ServerLocationTime;
		IGPlus_LocationOffsetFix_PrevServerLocationTick = IGPlus_LocationOffsetFix_ServerLocationTick;
		IGPlus_LocationOffsetFix_PrevServerLocationLead = IGPlus_LocationOffsetFix_ServerLocationLead;
		IGPlus_LocationOffsetFix_ServerLocationLead = 0.0;
		if (bReplicatedVelocity)
			IGPlus_LocationOffsetFix_ServerLocationLead = DeltaTime;
		IGPlus_LocationOffsetFix_ServerLocation = Location;
		IGPlus_LocationOffsetFix_ServerVelocity = Velocity;
		IGPlus_LocationOffsetFix_ServerLocationTime = Level.TimeSeconds;
		if (bbPlayer(GetLocalPlayer()) != None)
			IGPlus_LocationOffsetFix_ServerLocationTick = bbPlayer(GetLocalPlayer()).IGPlus_PRTServerTick;
		bReplicatedLocation = true;
	} else {
		IGPlus_LocationOffsetFix_OldLocation -= IGPlus_LocationOffsetFix_PredictionOffset;
		bReplicatedLocation = false;
	}

	VelXpol = Velocity;
	if (Base != none)
		VelXpol += Base.Velocity;
	if (IGPlus_LocationOffsetFix_OnGround && bCanFly == false && Region.Zone.bWaterZone == false) {
		// Without the following if-else-statement VelXpol will contain a small
		// downward Z velocity (gravity?) after players stand still. This will
		// cause significant mispredictions as players just slide down slopes.
		if (Base != none)
			VelXpol.Z = Base.Velocity.Z;
		else
			VelXpol.Z = 0;

		// Deal with predicting movement up/down ramps
		CosAlpha = Normal(VelXpol*vect(1,1,0)) dot IGPlus_LocationOffsetFix_GroundNormal;
		SinAlpha = Sqrt(1.0 - CosAlpha*CosAlpha); // sin(a)² + cos(a)² = 1 // sin(a) = sqrt(1 - cos(a)²)
		
		// Given the following:
		// sin(Gamma + 90°) = cos(Gamma)
		// sin(Gamma + 180°) = -sin(Gamma)
		// sin(Gamma + 270°) = -cos(Gamma)
		// 
		// cos(Gamma + 90°) = -sin(Gamma)
		// cos(Gamma + 180°) = -cos(Gamma)
		// cos(Gamma + 270°) = sin(Gamma)

		// Because Alpha is the angle between the ground normal and Velocity, we
		// need to subtract 90° in order to get the right angle between the ramp
		// and velocity.
		// Alpha* = Alpha - 90° = Alpha + 270°
		// tan(Alpha*) = -cos(Alpha)/sin(Alpha)
		VelXpol.Z += (-CosAlpha / SinAlpha) * VSize(VelXpol*vect(1,1,0));
	}

	// The offset above compares the new update with the drawn body as if the
	// body had stood still for this frame, so the drawn body trails its real
	// spot while it moves (two players' logs, Nov 13 2026: by a median 10 and
	// 12 ms of movement at 480 frames a second). Carrying the body on by this
	// frame first puts it on the server's spot, but then it snaps back by up
	// to 12 units when the player turns (rig, Nov 14 2026: 31 to 33 steps of
	// over 3 units in 55 s, against 2 without). So the trailing stays here.
	// Tick Interpolation draws the exact spot without a snap.

	// dont let misprediction grow too large
	// also, dont smoothly relocate teleporting players
	if (VSize(IGPlus_LocationOffsetFix_PredictionOffset) > 100 || VSize(Velocity) < 0.0001)
		IGPlus_LocationOffsetFix_PredictionOffset = vect(0,0,0);

	if (IGPlus_LocationOffsetFix_WasOnMover && IGPlus_LocationOffsetFix_IsOnMover() == false)
		IGPlus_LocationOffsetFix_MoverTransitionFrames = 4;
	else if (IGPlus_LocationOffsetFix_MoverTransitionFrames > 0)
		IGPlus_LocationOffsetFix_MoverTransitionFrames--;

	bMoverTransitionSmoothing = IGPlus_LocationOffsetFix_MoverTransitionFrames > 0;

	// 
	if (IGPlus_LocationOffsetFix_PredCompatMode) {
		if (bReplicatedLocation || bMoverTransitionSmoothing) {
			if (bMoverTransitionSmoothing)
				IGPlus_LocationOffsetFix_PredictionOffset *= 0.96;
			else if (VSize(IGPlus_LocationOffsetFix_PredictionOffset) > 40)
				IGPlus_LocationOffsetFix_PredictionOffset *= 0.65;
			else
				IGPlus_LocationOffsetFix_PredictionOffset *= 0.85;
		}
	} else {
		if (bMoverTransitionSmoothing)
			IGPlus_LocationOffsetFix_PredictionOffset *= Exp(-5 * DeltaTime);
		else
			IGPlus_LocationOffsetFix_PredictionOffset *= Exp(-25 * DeltaTime);
	}

	bCollideWorld = false;
	SetLocation(IGPlus_LocationOffsetFix_OldLocation+IGPlus_LocationOffsetFix_PredictionOffset);
	bCollideWorld = true;
	if (bReplicatedLocation == false) {
		MoveSmooth(VelXpol*DeltaTime);
	} else {
		IGPlus_LocationOffsetFix_ExtrapolationOffset = Location;
		ExtrapolationTime = GetLocalPlayer().PlayerReplicationInfo.Ping * 0.001 * LocalExtrapolationOwnPingFactor;
		if (PlayerReplicationInfo != none)
			ExtrapolationTime += PlayerReplicationInfo.Ping * 0.001 * LocalExtrapolationOtherPingFactor;

		if (ExtrapolationTime > 0) {
			MoveSmooth(VelXpol * ExtrapolationTime);
			IGPlus_LocationOffsetFix_ExtrapolationOffset = Location - IGPlus_LocationOffsetFix_ExtrapolationOffset;
		} else {
			IGPlus_LocationOffsetFix_ExtrapolationOffset = vect(0,0,0);
		}
	}

	IGPlus_LocationOffsetFix_Moved = false;

	if (IGPlus_LocationOffsetFix_FootstepQueued) {
		FootStepping();
		IGPlus_LocationOffsetFix_FootstepQueued = false;
	}
}

function IGPlus_LocationOffsetFix_AfterAll(float DeltaTime) {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;
	local IGPlus_CollisionDummy D;

	if (GameReplicationInfo != None && PlayerReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == none) break;
			P = bbPlayer(PRI.Owner);
			if (P == none) continue;
			if (P.Role != ROLE_SimulatedProxy) continue;

			if (IGPlus_ShouldUseSnapshotInterpForProxy(P))
				P.IGPlus_SnapInterp_After(DeltaTime);
			else if (P.IGPlus_TI_Use())
				P.IGPlus_TI_After(DeltaTime);
			else
				P.IGPlus_LocationOffsetFix_After(DeltaTime);
		}
	}

	for (D = IGPlus_LocationOffsetFix_DummyList; D != none; D = D.NextCollDummy) {
		D.bCollideWorld = false;
		D.SetCollision(false, false, false);
	}

	// Everyone stands where they are drawn: our own deterministic disc meets them there.
	if (IGPlus_DetTloc != none && IGPlus_DetTloc.bDeleteMe == false)
		IGPlus_DetTloc.IGPlus_DetClientSweep();
}

// This event is only executed on Pawns with Role=ROLE_SimulatedProxy
// PlayerTick is used if Role=ROLE_AutonomousProxy or ROLE_Authority
simulated event Tick(float DeltaTime) {
	if (IGPlus_MeshRepairPending && PlayerReplicationInfo != none) {
		IGPlus_MeshRepairPending = false;
		if (Mesh == IGPlus_MeshRepairOld && default.Mesh != none
			&& PlayerReplicationInfo.bIsSpectator == false && PlayerReplicationInfo.bWaitingPlayer == false)
			Mesh = default.Mesh;
		IGPlus_MeshRepairOld = none;
	}

	if (IGPlus_SDIsServerDemoProxy())
		IGPlus_SDPlaybackTick(DeltaTime);

	super.Tick(DeltaTime);

	if (IGPlus_ShowRealModelsInDemo())
		IGPlus_DemoRestoreRealModel();

	// Reset on both enable and disable transitions for simulated proxies.
	if (Role == ROLE_SimulatedProxy && IGPlus_SnapInterp_EnabledLast != IGPlus_EnableSnapshotInterpolation) {
		IGPlus_SnapInterp_Reset();
	}

	if (IGPlus_ShouldUseSnapshotInterpForProxy()) {
		if (IGPlus_LocationOffsetFix_Moved)
			IGPlus_SnapInterp_After(DeltaTime);
	} else if (IGPlus_TI_Use()) {
		if (IGPlus_LocationOffsetFix_Moved)
			IGPlus_TI_After(DeltaTime);
	} else if (Settings.bEnableLocationOffsetFix || IGPlus_LocationOffsetFix_Moved) {
		IGPlus_LocationOffsetFix_After(DeltaTime);
	}
	// With Tick Interpolation on a player's client IGPlus_TI_AnimAfter has done this.
	if (Role == ROLE_SimulatedProxy && Level.NetMode == NM_Client)
		IGPlus_FlipFix_Plain();
}

// Client, on another player's pawn (Tick Interpolation): the tick number of
// an update whose low 8 bits are B. NowTick is the server's newest tick
// number as our own pawn got it.
static function int IGPlus_TI_FullTick(int B, int NowTick) {
	local int Back;

	Back = (NowTick - B) & 255;
	// The stamp can be a tick ahead of the number our own pawn has.
	if (Back > 200)
		return NowTick + ((B - NowTick) & 255);
	return NowTick - Back;
}

// Client, on another player's pawn (Tick Interpolation): the tick position
// to draw them at, so that they move at an even pace. R is the tick position
// the clock asks for. A tick's spot is where the player's last move ended, and
// one tick runs more of their move time than the next, so drawn by tick
// number a player who moves evenly speeds up and slows down from tick to tick
// (more the faster they move: a jump pad shows it most). Each update's move
// time is known (IGPlus_NetMoveT). The moment drawn is taken on an even
// clock of that move time, and the result is the tick position between the
// two updates around it that stands for the same spot. Everything after this
// uses that tick position as before, and so does the shot's report: the
// server stands the player at the same part of the way between the same two
// snapshots, with nothing new to trust.
//
// The moment drawn runs on our own frame time (IGPlus_TI_Mu): each frame it
// moves on by exactly the time the frame took, as the other player's own
// clock does. It follows the moment the tick clock asks for only slowly,
// because that one is nudged by every update that comes early or late, by the
// drawing delay as it adapts and by the estimate of the tick length, about a
// millisecond from frame to frame in all. At 1000 units a second that is a
// unit a frame. Only a difference of several ticks is taken at once.
// IGPlus_TI_PaceA and IGPlus_TI_PaceAlpha keep the two updates and the part
// of the way between them, so the spot is drawn from those and not from the
// tick position, which as a float is too coarse late in a long map.
simulated function float IGPlus_TI_Pace(float R, float TickLen, float DeltaTime) {
	local int i, A, B;
	local float Mu, Err, Slew;

	IGPlus_TI_PaceA = -1;
	if (IGPlus_TI_Num == 0) {
		IGPlus_TI_bMu = false;
		return R;
	}
	B = (IGPlus_TI_Head - 1) & 15;
	// The move time that goes with R: the newest update's, moved by the ticks
	// between, less what that update is off the even pace.
	Mu = IGPlus_TI_MT[B] + (R - float(IGPlus_TI_Tick[B])) * TickLen - IGPlus_TI_Dev;
	// (Only when it is behind. Ahead of the asked moment it falls back, however
	// far: the tick clock is set back at once when our own download comes
	// late, and the player is not to step back for that.)
	if (IGPlus_TI_bMu == false || Mu - IGPlus_TI_Mu - DeltaTime > IGPLUS_TI_MU_SNAP * TickLen) {
		IGPlus_TI_Mu = Mu;
		IGPlus_TI_bMu = true;
	} else {
		IGPlus_TI_Mu += DeltaTime;
		Err = Mu - IGPlus_TI_Mu;
		if (Err < 0.0) {
			// Ahead of the asked moment: there is less in hand than the delay
			// wants, and the next late update would leave nothing to draw
			// from. Falling back is quick.
			Err = FMax(Err * DeltaTime / IGPLUS_TI_MU_TIME_BACK, -IGPLUS_TI_MU_SLEW_FAR * DeltaTime);
		} else {
			// Behind it: only more delay for a moment. Faster when it is over
			// a tick off, so a real change in a player's line is caught up
			// with in a few tenths of a second.
			if (Err > TickLen)
				Slew = IGPLUS_TI_MU_SLEW_FAR * DeltaTime;
			else
				Slew = IGPLUS_TI_MU_SLEW * DeltaTime;
			Err = FMin(Err * DeltaTime / IGPLUS_TI_MU_TIME, Slew);
		}
		// Close to the newest update: run slower, so a late one is met with a
		// slightly slower body and not with one that stops.
		if (IGPlus_TI_MT[B] - IGPlus_TI_Mu < IGPLUS_TI_MU_RESERVE * TickLen)
			Err = FMin(Err, -IGPLUS_TI_MU_SLEW_FAR * DeltaTime);
		IGPlus_TI_Mu += Err;
		// No further past the newest update than the carry reaches: the spot
		// drawn is the same, and the way back to the asked moment is short.
		IGPlus_TI_Mu = FMin(IGPlus_TI_Mu, IGPlus_TI_MT[B] + IGPLUS_TI_MU_LEAD * TickLen);
	}
	Mu = IGPlus_TI_Mu;
	if (Mu >= IGPlus_TI_MT[B])
		return float(IGPlus_TI_Tick[B]) + (Mu - IGPlus_TI_MT[B]) / TickLen;
	for (i = IGPlus_TI_Num - 1; i > 0; i--) {
		B = (IGPlus_TI_Head - IGPlus_TI_Num + i) & 15;
		A = (B - 1) & 15;
		if (Mu >= IGPlus_TI_MT[A]) {
			if (IGPlus_TI_Tick[B] <= IGPlus_TI_Tick[A] || IGPlus_TI_MT[B] <= IGPlus_TI_MT[A])
				return float(IGPlus_TI_Tick[A]);
			IGPlus_TI_PaceA = A;
			IGPlus_TI_PaceAlpha = (Mu - IGPlus_TI_MT[A]) / (IGPlus_TI_MT[B] - IGPlus_TI_MT[A]);
			return float(IGPlus_TI_Tick[A]) + float(IGPlus_TI_Tick[B] - IGPlus_TI_Tick[A]) * IGPlus_TI_PaceAlpha;
		}
	}
	return float(IGPlus_TI_Tick[(IGPlus_TI_Head - IGPlus_TI_Num) & 15]);
}

// The spot IGPlus_TI_Pace found, drawn from the two updates and the part of
// the way between them. The same spot as IGPlus_TI_Sample gives for the tick
// position, to the precision of a float. With no two updates around the
// moment (past the newest one, or before the oldest) it is IGPlus_TI_Sample.
simulated function vector IGPlus_TI_SamplePaced(float TickLen) {
	local int A, B;

	if (IGPlus_TI_PaceA < 0)
		return IGPlus_TI_Sample(IGPlus_TI_DrawnR, TickLen, IGPlus_TI_bDrawnHeld);
	A = IGPlus_TI_PaceA;
	B = (A + 1) & 15;
	if (IGPlus_TI_IsJump(IGPlus_TI_Loc[A], IGPlus_TI_Loc[B], IGPlus_TI_Tick[B] - IGPlus_TI_Tick[A], TickLen))
		return IGPlus_TI_Loc[A];
	return IGPlus_TI_Loc[A] + (IGPlus_TI_Loc[B] - IGPlus_TI_Loc[A]) * IGPlus_TI_PaceAlpha;
}

// Where the player was at tick position R: between the two updates around
// it. Past the newest one they are carried on by its velocity for at most
// IGPLUS_TI_MAX_CARRY ticks (the next update is on its way), then they stop.
// bHeld: the server holds them still, so they are not carried on at all.
// The server stands them the same way for a shot (UTPlusDummy.CompStartTick).
simulated function vector IGPlus_TI_Sample(float R, float TickLen, optional bool bHeld) {
	local int i, A, B;

	if (IGPlus_TI_Num == 0)
		return IGPlus_LocationOffsetFix_OldLocation;
	B = (IGPlus_TI_Head - 1) & 15;
	if (R >= float(IGPlus_TI_Tick[B]))
		return IGPlus_TI_Loc[B] + IGPlus_TI_Vel[B] * (IGPlus_TI_CarryTicks(R - float(IGPlus_TI_Tick[B]), bHeld) * TickLen);
	for (i = IGPlus_TI_Num - 1; i > 0; i--) {
		B = (IGPlus_TI_Head - IGPlus_TI_Num + i) & 15;
		A = (B - 1) & 15;
		if (R >= float(IGPlus_TI_Tick[A])) {
			if (IGPlus_TI_Tick[B] <= IGPlus_TI_Tick[A])
				return IGPlus_TI_Loc[B];
			if (IGPlus_TI_IsJump(IGPlus_TI_Loc[A], IGPlus_TI_Loc[B], IGPlus_TI_Tick[B] - IGPlus_TI_Tick[A], TickLen))
				return IGPlus_TI_Loc[A];
			return IGPlus_TI_Loc[A] + (IGPlus_TI_Loc[B] - IGPlus_TI_Loc[A])
				* ((R - float(IGPlus_TI_Tick[A])) / float(IGPlus_TI_Tick[B] - IGPlus_TI_Tick[A]));
		}
	}
	return IGPlus_TI_Loc[(IGPlus_TI_Head - IGPlus_TI_Num) & 15];
}

// The two updates IGPlus_TI_Sample draws between at tick position R, for the
// shot's report (IGPlus_TI_Span). Past the newest update there is only the
// older one, the one the player is carried on from.
simulated function int IGPlus_TI_SpanAt(float R) {
	local int i, A, B;

	if (IGPlus_TI_Num == 0)
		return 0;
	B = (IGPlus_TI_Head - 1) & 15;
	if (R >= float(IGPlus_TI_Tick[B]))
		return IGPlus_TI_Span(int(R), IGPlus_TI_Tick[B], int(R) + 1);
	for (i = IGPlus_TI_Num - 1; i > 0; i--) {
		B = (IGPlus_TI_Head - IGPlus_TI_Num + i) & 15;
		A = (B - 1) & 15;
		if (R >= float(IGPlus_TI_Tick[A]))
			return IGPlus_TI_Span(int(R), IGPlus_TI_Tick[A], IGPlus_TI_Tick[B]);
	}
	return 0;
}

// The crouch at tick position R: the one that came with the older of the two
// updates around R. The server takes it from the older snapshot too
// (UTPlusDummy.CompSwap), so a hit near the top of a crouching player is
// tested against the same height on both sides.
simulated function byte IGPlus_TI_DuckAt(float R) {
	local int i, A;

	if (IGPlus_TI_Num == 0)
		return DuckFractionRepl;
	for (i = IGPlus_TI_Num - 1; i >= 0; i--) {
		A = (IGPlus_TI_Head - IGPlus_TI_Num + i) & 15;
		if (R >= float(IGPlus_TI_Tick[A]))
			return IGPlus_TI_Duck[A];
	}
	return IGPlus_TI_Duck[(IGPlus_TI_Head - IGPlus_TI_Num) & 15];
}

// The crouch a hit test uses for this player. On a client with Tick
// Interpolation it is the one that goes with the spot the last frame drew
// them at, not the newest one the server sent.
simulated function float IGPlus_HitDuckFraction() {
	if (Role == ROLE_Authority)
		return DuckFraction;
	if (IGPlus_TI_Use() && IGPlus_TI_Num > 0)
		return float(IGPlus_ShownDuck) / 255.0;
	return float(DuckFractionRepl) / 255.0;
}

// Client, on another player's pawn, with enableDebugData on: counts for the
// "Tick Interpolation:" line. A backward step is a frame that moves the drawn
// body against its movement of the frame before, measured in units along it.
simulated function IGPlus_TI_Stat() {
	local vector Step;
	local float Dt, Len, S;

	if (bHidden || Health <= 0) {
		IGPlus_TI_StHavePrev = false;
		return;
	}
	IGPlus_TI_StFrames++;
	if (IGPlus_TI_bDrawnPast)
		IGPlus_TI_StPast++;
	if (IGPlus_TI_bStopped)
		IGPlus_TI_StStopped++;
	if (IGPlus_TI_bDrawnHeld)
		IGPlus_TI_StHeld++;
	IGPlus_TI_StDelaySum += IGPlus_TI_Delay;
	IGPlus_TI_StDevMax = FMax(IGPlus_TI_StDevMax, Abs(IGPlus_TI_Dev));
	IGPlus_TI_StDelayMax = FMax(IGPlus_TI_StDelayMax, IGPlus_TI_Delay);
	IGPlus_TI_StGapMax = FMax(IGPlus_TI_StGapMax, IGPlus_TI_Gap);

	Dt = Level.TimeSeconds - IGPlus_TI_StPrevTime;
	Step = Location - IGPlus_TI_StPrevLoc;
	Step.Z = 0;
	// Not across a long frame, a respawn or a translocation.
	if (IGPlus_TI_StHavePrev && Dt > 0.0 && Dt < 0.05 && VSize(Step) < 60.0) {
		Len = VSize(IGPlus_TI_StPrevStep);
		// Only while they were moving, at over 100 units a second.
		if (Len > 100.0 * IGPlus_TI_StPrevDt && Len > 0.0) {
			S = (Step dot IGPlus_TI_StPrevStep) / Len;
			if (S < -1.0)
				IGPlus_TI_StBack1++;
			if (S < -3.0)
				IGPlus_TI_StBack3++;
			IGPlus_TI_StBackMax = FMax(IGPlus_TI_StBackMax, -S);
		}
		IGPlus_TI_StPrevStep = Step;
		IGPlus_TI_StPrevDt = Dt;
	} else {
		IGPlus_TI_StPrevStep = vect(0,0,0);
		IGPlus_TI_StPrevDt = 0.0;
	}
	IGPlus_TI_StPrevLoc = Location;
	IGPlus_TI_StPrevTime = Level.TimeSeconds;
	IGPlus_TI_StHavePrev = true;
}

// Client, on our own pawn: writes the "Tick Interpolation:" line of every
// other player to the debug log and starts their counts again. bWrite false
// only starts them again (debug data was just turned on).
function IGPlus_TI_LogStats(bool bWrite) {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;
	local float F, Ms;

	if (GameReplicationInfo == None)
		return;
	Ms = 1000.0 * IGPlus_TI_TickLen;
	for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
		PRI = GameReplicationInfo.PRIArray[i];
		if (PRI == None)
			break;
		P = bbPlayer(PRI.Owner);
		if (P == None || P == self || P.Role != ROLE_SimulatedProxy)
			continue;
		if (bWrite && P.IGPlus_TI_StFrames > 0) {
			F = float(P.IGPlus_TI_StFrames);
			ClientDebugMessage("Tick Interpolation:"@"player="$PRI.PlayerName
				@"secs="$IGPlus_Fmt1((Level.TimeSeconds - IGPlus_TI_StSince) / Level.TimeDilation)
				@"frames="$P.IGPlus_TI_StFrames@"updates="$P.IGPlus_TI_StUpdates
				@"past="$IGPlus_Fmt1(100.0 * float(P.IGPlus_TI_StPast) / F)$"%"
				@"stopped="$IGPlus_Fmt1(100.0 * float(P.IGPlus_TI_StStopped) / F)$"%"
				@"held="$IGPlus_Fmt1(100.0 * float(P.IGPlus_TI_StHeld) / F)$"%"
				@"delayMsAvg="$IGPlus_Fmt1(Ms * P.IGPlus_TI_StDelaySum / F)
				@"delayMsMax="$IGPlus_Fmt1(Ms * P.IGPlus_TI_StDelayMax)
				@"gapTicksMax="$IGPlus_Fmt1(P.IGPlus_TI_StGapMax)
				@"back1="$P.IGPlus_TI_StBack1@"back3="$P.IGPlus_TI_StBack3
				@"backMax="$IGPlus_Fmt1(P.IGPlus_TI_StBackMax)
				@"paceMsMax="$IGPlus_Fmt1(1000.0 * P.IGPlus_TI_StDevMax)
				@"resets="$P.IGPlus_TI_StResets@"clockSnaps="$IGPlus_TI_StClockSnaps
				@"recvMsAvg="$IGPlus_Fmt1(Ms * IGPlus_TI_StRecvSum / FMax(1.0, float(IGPlus_TI_StRecvFrames)))
				@"recvMsMax="$IGPlus_Fmt1(Ms * IGPlus_TI_StRecvMax)
				@"freezes="$IGPlus_TI_StFreezes
				@"tickMs="$IGPlus_Fmt1(Ms));
		}
		P.IGPlus_TI_StFrames = 0;
		P.IGPlus_TI_StPast = 0;
		P.IGPlus_TI_StStopped = 0;
		P.IGPlus_TI_StHeld = 0;
		P.IGPlus_TI_StUpdates = 0;
		P.IGPlus_TI_StResets = 0;
		P.IGPlus_TI_StBack1 = 0;
		P.IGPlus_TI_StBack3 = 0;
		P.IGPlus_TI_StDelaySum = 0.0;
		P.IGPlus_TI_StDelayMax = 0.0;
		P.IGPlus_TI_StGapMax = 0.0;
		P.IGPlus_TI_StBackMax = 0.0;
		P.IGPlus_TI_StDevMax = 0.0;
	}
	IGPlus_TI_StClockSnaps = 0;
	IGPlus_TI_StRecvFrames = 0;
	IGPlus_TI_StRecvSum = 0.0;
	IGPlus_TI_StRecvMax = 0.0;
	IGPlus_TI_StFreezes = 0;
}

// Client, every frame, on any player's pawn that may be drawn: the animation
// to draw it with (client setting FlipAnimationFix). It reads AnimSequence and
// AnimFrame as the game would show them and may put others in their place for
// this frame. Rate is the speed of the blend they belong to.
//
// The engine blends into a new animation by moving every vertex of the model
// in a straight line from where it was last drawn (ULodMesh::GetFrame, a
// frame below 0). From the turned-over part of the forward dodge's flip to an
// upright pose the lines cross in the middle, and the model is a small lump
// for as long as the blend takes: the "pancake". The usual way there: a
// forward dodge lands in the middle of its flip, and a jump in that moment
// swaps the 0.12 s landing blend for one of 0.35 or 0.7 s (PlayInAir). A jump
// pad does the same, with 2 s.
//
// IGPlus_FlipFix_Flipped follows how much of the pose the engine last drew is a
// turned-over one, with the engine's own sum. It only changes in frames the
// model is drawn in, as far as a script can tell (IGPlus_FlipFix_Seen): a model
// that left the screen in the middle of a flip keeps that pose in the engine
// until it is drawn again. When a blend with more than IGPLUS_FLIPFIX_MIN_BLEND
// seconds to go would be drawn from such a pose:
//   FAF_Instant: the pose the blend goes to is drawn once, as a played frame.
//     The engine keeps it from there, and the game's air logic goes on.
//   FAF_FinishFlip: when the flip was what the model showed, it plays on to
//     its end at its own speed, and then the blend the game is in by then
//     takes over from its start and catches up. Every frame drawn is a stock
//     frame. A model that comes into view with an old turned-over pose gets
//     the pose its blend goes to, as with FAF_Instant.
//   FAF_Off: nothing is changed.
// Everything else is drawn as it came: the flip itself, short blends, and
// slow ones from an upright pose.
simulated function IGPlus_FlipFix_Apply(float Rate) {
	local name Seq;
	local float Frame, Dt, Left;
	local int Mode;
	local bool bStart;

	Seq = AnimSequence;
	Frame = AnimFrame;
	Dt = FClamp(Level.TimeSeconds - IGPlus_FlipFix_Time, 0.0, 0.1);
	IGPlus_FlipFix_Time = Level.TimeSeconds;

	// The blend the game is in, and the frame it had when it started.
	if (Frame >= 0.0) {
		IGPlus_FlipFix_BlendSeq = '';
	} else if (Seq != IGPlus_FlipFix_BlendSeq) {
		IGPlus_FlipFix_BlendSeq = Seq;
		IGPlus_FlipFix_BlendFirst = Frame;
	}

	if (IGPlus_FlipFix_State == 1) {
		// The flip plays on to its end.
		IGPlus_FlipFix_FlipFrame += IGPlus_FlipFix_FlipRate * Dt;
		if (Frame < 0.0 && IGPlus_FlipFix_FlipFrame < IGPLUS_FLIPFIX_FLIP_END) {
			AnimSequence = 'Flip';
			AnimFrame = IGPlus_FlipFix_FlipFrame;
			IGPlus_FlipFix_Seq = 'Flip';
			IGPlus_FlipFix_Last = IGPlus_FlipFix_FlipFrame;
			return;
		}
		IGPlus_FlipFix_State = 0;
		IGPlus_FlipFix_Flipped = 0.0;
		IGPlus_FlipFix_Seq = 'Flip';
		IGPlus_FlipFix_Last = IGPLUS_FLIPFIX_FLIP_END;
		if (Frame < 0.0 && IGPlus_FlipFix_BlendFirst < 0.0) {
			// The blend the game is in takes over, from its own start.
			IGPlus_FlipFix_State = 2;
			IGPlus_FlipFix_Ramp = FMax(0.0, IGPlus_FlipFix_BlendFirst / Frame - 1.0);
		}
	}
	if (IGPlus_FlipFix_State == 2) {
		// It catches up with the game's blend.
		IGPlus_FlipFix_Ramp *= Exp(-Dt / IGPLUS_FLIPFIX_RAMP_TIME);
		if (Frame < 0.0 && Seq == IGPlus_FlipFix_BlendSeq && IGPlus_FlipFix_Ramp > 0.02
			&& (IGPlus_FlipFix_Seq != Seq || Frame * (1.0 + IGPlus_FlipFix_Ramp) >= IGPlus_FlipFix_Last)) {
			AnimFrame = Frame * (1.0 + IGPlus_FlipFix_Ramp);
			IGPlus_FlipFix_Seq = Seq;
			IGPlus_FlipFix_Last = AnimFrame;
			return;
		}
		IGPlus_FlipFix_State = 0;
	}

	if (Frame >= 0.0) {
		// A played animation: the model has this pose and no other, once it is drawn.
		if (Seq == 'Flip') {
			IGPlus_FlipFix_FlipAt = Frame;
			IGPlus_FlipFix_FlipTime = Level.TimeSeconds;
		}
		if (Seq == 'Flip' && Frame > IGPLUS_FLIPFIX_FLIP_FROM && Frame < IGPLUS_FLIPFIX_FLIP_TO) {
			if (IGPlus_FlipFix_Flipped < 1.0 && IGPlus_FlipFix_Seen())
				IGPlus_FlipFix_Flipped = 1.0;
		} else if (IGPlus_FlipFix_Flipped > 0.0 && IGPlus_FlipFix_Seen()) {
			IGPlus_FlipFix_Flipped = 0.0;
		}
		IGPlus_FlipFix_Seq = Seq;
		IGPlus_FlipFix_Last = Frame;
		IGPlus_FlipFix_bLogged = false;
		return;
	}

	// A blend. It starts this frame when the animation is a new one, or the
	// same one was played until now.
	bStart = Seq != IGPlus_FlipFix_Seq || IGPlus_FlipFix_Last >= 0.0;
	if (bStart)
		IGPlus_FlipFix_bLogged = false;
	if (IGPlus_FlipFix_Flipped > 0.1 && IGPlus_FlipFix_Seen()) {
		if (Rate > 0.0)
			Left = -Frame / Rate;
		if (Left > IGPLUS_FLIPFIX_MIN_BLEND) {
			Mode = IGPlus_FlipFix_Setting();
			// The flip was on screen a moment ago, with at most a short blend
			// since (the 0.12 s one of a landing): it plays on from where it
			// would be by now.
			if (Mode == 2 && bStart && IGPlus_FlipFix_Flipped > 0.5
				&& Level.TimeSeconds - IGPlus_FlipFix_FlipTime < IGPLUS_FLIPFIX_FLIP_MEMORY) {
				IGPlus_FlipFix_Note(Seq, Left, "flip", bStart);
				if (IGPlus_FlipFix_FlipRate <= 0.0)
					IGPlus_FlipFix_FlipRate = 2.0;
				IGPlus_FlipFix_State = 1;
				IGPlus_FlipFix_FlipFrame = FMin(IGPLUS_FLIPFIX_FLIP_END, IGPlus_FlipFix_FlipAt
					+ IGPlus_FlipFix_FlipRate * (Level.TimeSeconds - IGPlus_FlipFix_FlipTime));
				AnimSequence = 'Flip';
				AnimFrame = IGPlus_FlipFix_FlipFrame;
				IGPlus_FlipFix_Seq = 'Flip';
				IGPlus_FlipFix_Last = IGPlus_FlipFix_FlipFrame;
				return;
			}
			if (Mode != 0 && IGPlus_FlipFix_Flipped > IGPLUS_FLIPFIX_MIN_FLIPPED) {
				IGPlus_FlipFix_Note(Seq, Left, "instant", bStart);
				AnimFrame = 0.0;
				IGPlus_FlipFix_Flipped = 0.0;
				IGPlus_FlipFix_Seq = Seq;
				IGPlus_FlipFix_Last = Frame;
				return;
			}
			IGPlus_FlipFix_Note(Seq, Left, "off", bStart);
		}
		// The engine moves the model new frame / old frame of the way left.
		if (bStart == false && IGPlus_FlipFix_Last < 0.0)
			IGPlus_FlipFix_Flipped *= FClamp(Frame / IGPlus_FlipFix_Last, 0.0, 1.0);
	}
	IGPlus_FlipFix_Seq = Seq;
	IGPlus_FlipFix_Last = Frame;
}

// The client's FlipAnimationFix setting: 0 off, 1 instant, 2 finish the flip.
simulated function int IGPlus_FlipFix_Setting() {
	local PlayerPawn LP;

	LP = GetLocalPlayer();
	if (bbPlayer(LP) != None && bbPlayer(LP).Settings != None)
		return bbPlayer(LP).Settings.FlipAnimationFix;
	if (bbCHSpectator(LP) != None && bbCHSpectator(LP).Settings != None)
		return bbCHSpectator(LP).Settings.FlipAnimationFix;
	return 0;
}

// enableDebugData 1: one line for every slow blend out of a turned-over pose,
// with the setting on any value, so a log shows how often it happens and what
// was done. bStart false: the model came into view in the middle of the blend.
simulated function IGPlus_FlipFix_Note(name Seq, float Left, string What, bool bStart) {
	local bbPlayer LP;
	local string S;

	if (IGPlus_FlipFix_bLogged)
		return;
	IGPlus_FlipFix_bLogged = true;
	LP = bbPlayer(GetLocalPlayer());
	if (LP == None || LP.bDrawDebugData == false || PlayerReplicationInfo == None)
		return;
	if (bStart)
		S = "blend to";
	else
		S = "seen again in a blend to";
	LP.ClientDebugMessage("Flip fix: player="$PlayerReplicationInfo.PlayerName@S@Seq
		@"ms="$int(1000.0 * Left)@"flipped="$IGPlus_Fmt1(IGPlus_FlipFix_Flipped)@"fix="$What);
}

// Is this pawn drawn on our screen this frame? A script cannot ask the engine,
// so this is an estimate: inside the view cone, and a clear line from the
// camera to the middle, the head or the feet. Our own pawn is drawn in behind
// view only. Where the estimate is wrong, a model keeps a stock blend it
// should not have, or takes its next pose a moment early.
simulated function bool IGPlus_FlipFix_Seen() {
	local PlayerPawn LP;
	local vector Cam, To, Up;

	LP = GetLocalPlayer();
	if (LP == None)
		return true;
	if (LP == self)
		return bBehindView;
	// The eye of whoever we look through. Read here and not asked of
	// PlayerCalcView: that one also sets what the camera correction applied
	// this frame, which a shot reads.
	if (LP.ViewTarget != None) {
		Cam = LP.ViewTarget.Location;
		if (Pawn(LP.ViewTarget) != None)
			Cam.Z += Pawn(LP.ViewTarget).EyeHeight;
	} else {
		Cam = LP.Location;
		Cam.Z += LP.EyeHeight;
	}
	To = Location - Cam;
	if (VSize(To) > 1.0 && (Normal(To) dot vector(LP.ViewRotation)) < Cos(LP.FOVAngle * 0.5 * Pi / 180.0))
		return false;
	Up = vect(0,0,0.8) * CollisionHeight;
	return FastTrace(Location, Cam) || FastTrace(Location + Up, Cam) || FastTrace(Location - Up, Cam);
}

// The pawn has the engine's own animation here (no Tick Interpolation, a
// spectator's view, or our own pawn). What IGPlus_FlipFix_Apply changes is drawn
// this frame, and IGPlus_AnimRestore puts the engine's back after it.
simulated function IGPlus_FlipFix_Plain() {
	local name S;
	local float F;

	if (IGPlus_TI_bAnimSwapped)
		return;
	S = AnimSequence;
	F = AnimFrame;
	if (S == 'Flip' && AnimRate > 0.0)
		IGPlus_FlipFix_FlipRate = AnimRate;
	IGPlus_FlipFix_Apply(TweenRate);
	if (AnimSequence != S || AnimFrame != F) {
		IGPlus_TI_RawSeq = S;
		IGPlus_TI_RawFrame = F;
		IGPlus_TI_bAnimSwapped = true;
	}
}

// After the frame is drawn: the engine plays on from its own animation.
simulated function IGPlus_AnimRestore() {
	if (IGPlus_TI_bAnimSwapped) {
		AnimSequence = IGPlus_TI_RawSeq;
		AnimFrame = IGPlus_TI_RawFrame;
		IGPlus_TI_bAnimSwapped = false;
	}
}


// Client, on another player's pawn (Tick Interpolation). Between frames the
// pawn holds the animation as the engine plays it, and that is the newest one
// the server sent. The body is drawn Delay seconds behind the newest update,
// so the animation is drawn from Delay seconds ago as well: the engine's own
// playback, looked up in the frames noted here. The pawn gets the engine's
// animation back after the frame (IGPlus_LocationOffsetFix_Before).
// While the body stands still (IGPlus_TI_bStopped) the animation stands still
// with it, so a player whose updates stopped does not run on the spot.
simulated function IGPlus_TI_AnimAfter(float Delay) {
	local int i, A, B;
	local float T, Span;

	if (IGPlus_TI_bAnimSwapped)
		return;
	T = Level.TimeSeconds;
	// A dead player is hidden, and what their body played until the respawn is not
	// drawn after it: the notes start again with the first frame they are shown, as
	// their spots do (IGPlus_TI_After). Kept, the first drawing delay after a respawn
	// showed the hidden body's pose at the spawn spot.
	if (bHidden || (IGPlus_TI_AnimNum > 0 && T < IGPlus_TI_AnimTimeH[(IGPlus_TI_AnimHead - 1) & 63]))
		IGPlus_TI_AnimNum = 0;
	// At most one note every 2 ms, so 64 of them cover the longest delay at any frame rate.
	if (bHidden == false
		&& (IGPlus_TI_AnimNum == 0 || T - IGPlus_TI_AnimTimeH[(IGPlus_TI_AnimHead - 1) & 63] >= 0.002)) {
		IGPlus_TI_AnimSeqH[IGPlus_TI_AnimHead & 63] = AnimSequence;
		IGPlus_TI_AnimFrameH[IGPlus_TI_AnimHead & 63] = AnimFrame;
		IGPlus_TI_AnimTimeH[IGPlus_TI_AnimHead & 63] = T;
		IGPlus_TI_AnimTweenH[IGPlus_TI_AnimHead & 63] = TweenRate;
		IGPlus_TI_AnimHead = (IGPlus_TI_AnimHead + 1) & 63;
		if (IGPlus_TI_AnimNum < 64)
			IGPlus_TI_AnimNum++;
	}
	IGPlus_TI_RawSeq = AnimSequence;
	IGPlus_TI_RawFrame = AnimFrame;
	IGPlus_TI_bAnimSwapped = true;
	if (AnimSequence == 'Flip' && AnimRate > 0.0)
		IGPlus_FlipFix_FlipRate = AnimRate;

	if (IGPlus_TI_AnimNum == 0) {
		IGPlus_TI_ShownSeq = AnimSequence;
		IGPlus_TI_ShownFrame = AnimFrame;
		IGPlus_TI_ShownTween = TweenRate;
	} else if (IGPlus_TI_bStopped == false || IGPlus_TI_ShownSeq == '') {
		T -= Delay;
		A = -1;
		for (i = IGPlus_TI_AnimNum - 1; i >= 0; i--) {
			B = (IGPlus_TI_AnimHead - IGPlus_TI_AnimNum + i) & 63;
			if (IGPlus_TI_AnimTimeH[B] <= T) {
				A = B;
				break;
			}
		}
		if (A < 0)
			A = (IGPlus_TI_AnimHead - IGPlus_TI_AnimNum) & 63;
		IGPlus_TI_ShownSeq = IGPlus_TI_AnimSeqH[A];
		IGPlus_TI_ShownFrame = IGPlus_TI_AnimFrameH[A];
		IGPlus_TI_ShownTween = IGPlus_TI_AnimTweenH[A];
		// Between two notes of one animation running on: the part of the way.
		B = (A + 1) & 63;
		if (A != ((IGPlus_TI_AnimHead - 1) & 63)
			&& IGPlus_TI_AnimSeqH[B] == IGPlus_TI_ShownSeq
			&& IGPlus_TI_AnimFrameH[B] > IGPlus_TI_ShownFrame
			&& (IGPlus_TI_ShownFrame >= 0.0 || IGPlus_TI_AnimFrameH[B] <= 0.0)) {
			Span = IGPlus_TI_AnimTimeH[B] - IGPlus_TI_AnimTimeH[A];
			if (Span > 0.0)
				IGPlus_TI_ShownFrame += (IGPlus_TI_AnimFrameH[B] - IGPlus_TI_ShownFrame)
					* FClamp((T - IGPlus_TI_AnimTimeH[A]) / Span, 0.0, 1.0);
		}
	}
	AnimSequence = IGPlus_TI_ShownSeq;
	AnimFrame = IGPlus_TI_ShownFrame;
	IGPlus_FlipFix_Apply(IGPlus_TI_ShownTween);
}

// Client, on another player's pawn, every frame (Tick Interpolation). The
// pawn is parked outside the map between frames, as for Location Offset Fix,
// and is drawn here. An update is a new tick stamp. Its spot is IGPlus_NetLoc,
// the one the server's snapshot of that tick has.
simulated function IGPlus_TI_After(float DeltaTime) {
	local bbPlayer LP;
	local int Full, Prev, Delta, i;
	local float Target, TickLen, Newest, MoveT;

	if (IGPlus_LocationOffsetFix_Moved == false)
		return;
	if (IGPlus_LocationOffsetFix_CollisionDummy != none) {
		IGPlus_LocationOffsetFix_CollisionDummy.bCollideWorld = false;
		IGPlus_LocationOffsetFix_CollisionDummy.SetCollision(false, false, false);
	}
	LP = bbPlayer(GetLocalPlayer());
	if (LP == None)
		return;

	// The parked pawn has a stand-in velocity until an update brings one.
	if (IGPlus_LocationOffsetFix_WasVelocityReplicated() == false)
		Velocity = IGPlus_LocationOffsetFix_Velocity;

	TickLen = FMax(LP.IGPlus_TI_TickLen, 0.001);
	// A dead player is hidden. Their updates from before are dropped: after
	// the respawn they are drawn from their first update at the new spot,
	// where the server stands them too (it drops its snapshots at the death).
	// Kept, the body showed at the death spot for one drawing delay after the
	// respawn, and could be hit there.
	if (bHidden)
		IGPlus_TI_Num = 0;
	if (IGPlus_TI_bHasByte == false || IGPlus_NetTick != IGPlus_TI_LastByte) {
		// A move of theirs ran in a new tick: an update.
		Full = IGPlus_TI_FullTick(IGPlus_NetTick, LP.IGPlus_TI_ServerTick);
		if (IGPlus_TI_Num > 0) {
			Prev = IGPlus_TI_Tick[(IGPlus_TI_Head - 1) & 15];
			Delta = Full - Prev;
			// A stamp from far off (they were out of sight): start again.
			if (Delta <= 0 || Delta > 60) {
				IGPlus_TI_Num = 0;
				IGPlus_TI_bMu = false;
				IGPlus_TI_StResets++;
			}
			else if (float(Delta) > IGPlus_TI_Gap)
				IGPlus_TI_Gap = float(Delta);
			else
				IGPlus_TI_Gap += (float(Delta) - IGPlus_TI_Gap) * 0.02;
		}
		IGPlus_TI_bHasByte = true;
		IGPlus_TI_LastByte = IGPlus_NetTick;
		if (bHidden == false) {
			if (IGPlus_TI_Num == 0) {
				IGPlus_TI_Gap = 1.0;
				IGPlus_TI_Delay = IGPLUS_TI_MIN_DELAY;
				IGPlus_TI_Dev = 0.0;
				MoveT = 0.0;
			} else {
				// How much move time this update is on from the one before, and
				// how far that leaves it from an even pace (IGPlus_TI_Pace).
				MoveT = IGPlus_TI_MoveDelta(IGPlus_TI_LastMT, IGPlus_NetMoveT, float(Delta) * TickLen);
				IGPlus_TI_Dev = (IGPlus_TI_Dev + MoveT - float(Delta) * TickLen) * (1.0 - IGPLUS_TI_PACE_RATE);
				MoveT += IGPlus_TI_MT[(IGPlus_TI_Head - 1) & 15];
				// Kept small, so half a millisecond stays exact in a float.
				if (MoveT > 64.0) {
					for (i = 0; i < 16; i++)
						IGPlus_TI_MT[i] -= 64.0;
					MoveT -= 64.0;
					IGPlus_TI_Mu -= 64.0;
				}
			}
			IGPlus_TI_LastMT = IGPlus_NetMoveT;
			IGPlus_TI_MT[IGPlus_TI_Head & 15] = MoveT;
			IGPlus_TI_Tick[IGPlus_TI_Head & 15] = Full;
			IGPlus_TI_Loc[IGPlus_TI_Head & 15] = IGPlus_TI_LocJoin(IGPlus_NetLoc, IGPlus_NetLocFrac);
			IGPlus_TI_Vel[IGPlus_TI_Head & 15] = Velocity;
			IGPlus_TI_Duck[IGPlus_TI_Head & 15] = DuckFractionRepl;
			IGPlus_TI_Head = (IGPlus_TI_Head + 1) & 15;
			if (IGPlus_TI_Num < 16)
				IGPlus_TI_Num++;
			IGPlus_TI_StUpdates++;
			// Drawn far enough back that the next update is in before it is needed.
			Target = FClamp(IGPlus_TI_Gap + IGPLUS_TI_EXTRA, IGPLUS_TI_MIN_DELAY, IGPLUS_TI_MAX_DELAY);
			IGPlus_TI_Delay += FClamp(Target - IGPlus_TI_Delay, -0.02, 0.05);
		}
	}

	IGPlus_TI_DrawnR = IGPlus_TI_Pace(LP.IGPlus_TI_Clock - IGPlus_TI_Delay, TickLen, DeltaTime);
	Newest = float(IGPlus_TI_Tick[(IGPlus_TI_Head - 1) & 15]);
	IGPlus_TI_bDrawnPast = IGPlus_TI_Num > 0 && IGPlus_TI_DrawnR >= Newest;
	// Adaptive Buffering holds this player still on the server and says so
	// (their queue ran empty). They stand still here too, with no carrying on.
	IGPlus_TI_bDrawnHeld = IGPlus_TI_bDrawnPast && IGPlus_WarpFixData.bHold;
	IGPlus_TI_bStopped = IGPlus_TI_bDrawnPast
		&& (IGPlus_TI_bDrawnHeld || IGPlus_TI_DrawnR - Newest >= IGPLUS_TI_MAX_CARRY);
	IGPlus_TI_DrawnDuck = IGPlus_TI_DuckAt(IGPlus_TI_DrawnR);
	IGPlus_TI_DrawnSpan = IGPlus_TI_SpanAt(IGPlus_TI_DrawnR);
	// With no update to draw from (hidden, or the first one after a respawn
	// is still on its way) the pawn stays parked outside the map.
	if (IGPlus_TI_Num > 0) {
		bCollideWorld = false;
		SetLocation(IGPlus_TI_SamplePaced(TickLen));
		bCollideWorld = true;
	} else if (VSize(Location - IGPlus_LocationOffsetFix_SafeLocation) > 1.0) {
		// An update of the engine's own has moved the pawn back into the map.
		bCollideWorld = false;
		SetLocation(IGPlus_LocationOffsetFix_SafeLocation);
		bCollideWorld = true;
	}
	IGPlus_TI_AnimAfter((IGPlus_TI_Delay + LP.IGPlus_TI_RecvAnim) * TickLen);
	if (LP.bDrawDebugData)
		IGPlus_TI_Stat();

	IGPlus_LocationOffsetFix_Moved = false;
	if (IGPlus_LocationOffsetFix_FootstepQueued) {
		// No footsteps from a body that stands still.
		if (IGPlus_TI_bStopped == false)
			FootStepping();
		IGPlus_LocationOffsetFix_FootstepQueued = false;
	}
}

simulated function IGPlus_LocationOffsetFix_Restore() {
	if (IGPlus_LocationOffsetFix_Moved == false)
		return;

	if (IGPlus_LocationOffsetFix_CollisionDummy != none) {
		IGPlus_LocationOffsetFix_CollisionDummy.bCollideWorld = false;
		IGPlus_LocationOffsetFix_CollisionDummy.SetCollision(false, false, false);
	}

	if (VSize(Location - IGPlus_LocationOffsetFix_SafeLocation) < CollisionRadius+CollisionHeight) {
		bCollideWorld = false;
		SetLocation(IGPlus_LocationOffsetFix_OldLocation);
		bCollideWorld = true;
	}
	Velocity = IGPlus_LocationOffsetFix_Velocity;

	IGPlus_LocationOffsetFix_Restored = true;
	IGPlus_LocationOffsetFix_Moved = false;
}

function IGPlus_LocationOffsetFix_RestoreAll() {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;

	if (GameReplicationInfo != None && PlayerReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == none) break;
			P = bbPlayer(PRI.Owner);
			if (P == none) continue;
			if (P.Role != ROLE_SimulatedProxy) continue;

			P.IGPlus_LocationOffsetFix_Restore();
		}
	}
}

simulated function IGPlus_LocationOffsetFix_UndoRestore() {
	if (IGPlus_LocationOffsetFix_Restored == false)
		return;

	IGPlus_LocationOffsetFix_Restored = false;
	IGPlus_LocationOffsetFix_Before();
}

function IGPlus_LocationOffsetFix_UndoRestoreAll() {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;

	if (GameReplicationInfo != None && PlayerReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == none) break;
			P = bbPlayer(PRI.Owner);
			if (P == none) continue;
			if (P.Role != ROLE_SimulatedProxy) continue;

			P.IGPlus_LocationOffsetFix_UndoRestore();
		}
	}
}

simulated function IGPlus_LocationOffsetFix_SpawnCollisionDummy() {
	local bbPlayer P;

	IGPlus_LocationOffsetFix_CollisionDummy = Spawn(class'IGPlus_CollisionDummy');

	P = bbPlayer(GetLocalPlayer());
	if (P == none)
		return;

	IGPlus_LocationOffsetFix_CollisionDummy.NextCollDummy = P.IGPlus_LocationOffsetFix_DummyList;
	P.IGPlus_LocationOffsetFix_DummyList = IGPlus_LocationOffsetFix_CollisionDummy;
}

simulated function IGPlus_LocationOffsetFix_DestroyCollisionDummy() {
	local bbPlayer P;
	local IGPlus_CollisionDummy D;

	P = bbPlayer(GetLocalPlayer());
	if (P == none)
		goto Destruction;

	if (IGPlus_LocationOffsetFix_CollisionDummy == P.IGPlus_LocationOffsetFix_DummyList) {
		P.IGPlus_LocationOffsetFix_DummyList = IGPlus_LocationOffsetFix_CollisionDummy.NextCollDummy;
		goto Destruction;
	}

	for (D = P.IGPlus_LocationOffsetFix_DummyList; D != none; D = D.NextCollDummy)
		if (D.NextCollDummy == IGPlus_LocationOffsetFix_CollisionDummy)
			break;
	
	if (D != none)
		D.NextCollDummy = IGPlus_LocationOffsetFix_CollisionDummy.NextCollDummy;

Destruction:
	IGPlus_LocationOffsetFix_CollisionDummy.Destroy();
	IGPlus_LocationOffsetFix_CollisionDummy = none;
}

simulated function bool IGPlus_LocationOffsetFix_IsOnGround(out vector HitNormal) {
	local Actor HitActor;
	local vector HitLocation;
	local vector Extent;

	HitNormal = vect(0.0, 0.0, 0.0);

	if (bCanFly || Region.Zone.bWaterZone)
		return true;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,8), Location, false, Extent);

	return (HitActor != none)
		&& (HitActor == Level || HitActor.IsA('Mover'))
		&& (HitNormal.Z >= 0.7);
}

simulated function float IGPlus_SnapInterp_GetFallbackInterval() {
	local float SnapshotSendHz;
	local bbPlayer LP;

	SnapshotSendHz = 30.0;
	if (zzUTPure != None && zzUTPure.Settings != None && zzUTPure.Settings.SnapshotInterpSendHz > 0.0)
		SnapshotSendHz = zzUTPure.Settings.SnapshotInterpSendHz;
	else {
		LP = bbPlayer(GetLocalPlayer());
		if (LP != None &&
			LP.zzUTPure != None &&
			LP.zzUTPure.Settings != None &&
			LP.zzUTPure.Settings.SnapshotInterpSendHz > 0.0
		) {
			SnapshotSendHz = LP.zzUTPure.Settings.SnapshotInterpSendHz;
		}
	}

	return 1.0 / FMax(SnapshotSendHz, 1.0);
}

simulated function float IGPlus_SnapInterp_GetExpectedInterval() {
	return FMax(IGPlus_SnapInterp_MeanInterval, IGPlus_SnapInterp_GetFallbackInterval());
}

simulated function IGPlus_SnapInterp_UpdateTargetDelay(float ExpectedInterval) {
	local float TargetDelay;
	local float DelayDelta;

	ExpectedInterval = FMax(ExpectedInterval, 0.001);
	TargetDelay = (2.5 * ExpectedInterval) + IGPlus_SnapInterp_JitterEstimate;
	TargetDelay = FClamp(TargetDelay, 0.020, 0.200);
	DelayDelta = FClamp(TargetDelay - IGPlus_SnapInterp_InterpDelay, -0.010, 0.020);
	IGPlus_SnapInterp_InterpDelay = FClamp(IGPlus_SnapInterp_InterpDelay + DelayDelta, 0.020, 0.200);
}

simulated function IGPlus_SnapInterp_BoostDelayForStress(optional float Scale) {
	local float ExpectedInterval;

	if (Scale <= 0.0)
		Scale = 0.5;

	ExpectedInterval = IGPlus_SnapInterp_GetExpectedInterval();
	IGPlus_SnapInterp_InterpDelay = FMin(0.200, IGPlus_SnapInterp_InterpDelay + Scale * ExpectedInterval);
}

simulated function IGPlus_SnapInterp_Push(
	vector Pos,
	vector Vel,
	rotator SnapRot,
	name SnapAnimSeq,
	byte SnapAnimFrameByte,
	byte SnapAnimIntentBits,
	byte SnapAnimDodgeDir,
	byte SnapAnimPhysics,
	float SnapTime,
	float ArrivalTime,
	optional bool bFromServerMoverState,
	optional bool bBasedOnMover,
	optional vector BaseMoverLocation,
	optional Actor BaseMoverActor,
	optional bool bUpdateDelayStats
) {
	local int BufSize;
	local int PrevIdx;
	local float Interval;
	local float ExpectedInterval;
	local IGPlus_InterpSnapshot Snap;
	local IGPlus_InterpSnapshot PrevSnap;

	BufSize = arraycount(IGPlus_SnapInterp_Data);

	if (IGPlus_SnapInterp_Data[IGPlus_SnapInterp_DataIndex] == None)
		IGPlus_SnapInterp_Data[IGPlus_SnapInterp_DataIndex] = new class'IGPlus_InterpSnapshot';

	Snap = IGPlus_SnapInterp_Data[IGPlus_SnapInterp_DataIndex];
	Snap.Loc = Pos;
	Snap.Vel = Vel;
	Snap.Rot = SnapRot;
	Snap.Rot.Roll = 0;
	Snap.AnimSeq = SnapAnimSeq;
	Snap.AnimFrameByte = SnapAnimFrameByte;
	Snap.AnimIntentBits = SnapAnimIntentBits;
	Snap.AnimDodgeDir = SnapAnimDodgeDir;
	Snap.AnimPhysics = SnapAnimPhysics;
	Snap.Time = SnapTime;
	if (bFromServerMoverState) {
		Snap.bBasedOnMover = bBasedOnMover;
		if (Snap.bBasedOnMover) {
			Snap.MoverLoc = BaseMoverLocation;
			Snap.RelLoc = Pos - BaseMoverLocation;
			Snap.BaseMover = BaseMoverActor;
			if (Snap.BaseMover == None) {
				Snap.bBasedOnMover = false;
				Snap.RelLoc = vect(0,0,0);
				Snap.MoverLoc = vect(0,0,0);
			}
		} else {
			Snap.RelLoc = vect(0,0,0);
			Snap.MoverLoc = vect(0,0,0);
			Snap.BaseMover = None;
		}
	} else {
		Snap.bBasedOnMover = Mover(Base) != None;
		if (Snap.bBasedOnMover) {
			Snap.MoverLoc = Base.Location;
			Snap.RelLoc = Pos - Base.Location;
			Snap.BaseMover = Base;
		} else {
			Snap.RelLoc = vect(0,0,0);
			Snap.MoverLoc = vect(0,0,0);
			Snap.BaseMover = None;
		}
	}

	// Teleport detection: if distance to previous snapshot is unreasonably large, reset
	if (IGPlus_SnapInterp_Count > 0) {
		PrevIdx = (IGPlus_SnapInterp_DataIndex - 1 + BufSize) % BufSize;
		PrevSnap = IGPlus_SnapInterp_Data[PrevIdx];
			if (PrevSnap != None && VSize(Pos - PrevSnap.Loc) > 3000.0 * FMax(SnapTime - PrevSnap.Time, 0.016)) {
				IGPlus_SnapInterp_Reset();
				IGPlus_SnapInterp_Data[0] = Snap;
				IGPlus_SnapInterp_DataIndex = 1 % BufSize;
				IGPlus_SnapInterp_Count = 1;
				if (bUpdateDelayStats)
					IGPlus_SnapInterp_LastArrivalTime = ArrivalTime;
				return;
			}
		}

	IGPlus_SnapInterp_DataIndex = (IGPlus_SnapInterp_DataIndex + 1) % BufSize;
	if (IGPlus_SnapInterp_Count < BufSize)
		IGPlus_SnapInterp_Count++;

	// Update adaptive interpolation delay.
	if (bUpdateDelayStats && IGPlus_SnapInterp_LastArrivalTime > 0) {
		Interval = ArrivalTime - IGPlus_SnapInterp_LastArrivalTime;
		if (Interval > 0 && Interval < 1.0) {
			IGPlus_SnapInterp_MeanInterval += 0.1 * (Interval - IGPlus_SnapInterp_MeanInterval);
			IGPlus_SnapInterp_JitterEstimate += 0.1 * (Abs(Interval - IGPlus_SnapInterp_MeanInterval) - IGPlus_SnapInterp_JitterEstimate);
			ExpectedInterval = IGPlus_SnapInterp_GetExpectedInterval();
			IGPlus_SnapInterp_UpdateTargetDelay(ExpectedInterval);
		}
	}
	if (bUpdateDelayStats)
		IGPlus_SnapInterp_LastArrivalTime = ArrivalTime;
}

simulated function int IGPlus_SnapInterp_LerpAxis(int A, int B, float Alpha) {
	local int AS;
	local int BS;
	local int Delta;
	local int Out;

	AS = Utils.RotU2S(A);
	BS = Utils.RotU2S(B);
	Delta = ((BS - AS + 32768) & 65535) - 32768;
	Out = AS + int(float(Delta) * Alpha);
	return Utils.RotS2U(Out);
}

simulated function rotator IGPlus_SnapInterp_LerpRot(rotator A, rotator B, float Alpha) {
	local rotator R;
	R.Yaw = IGPlus_SnapInterp_LerpAxis(A.Yaw, B.Yaw, Alpha);
	R.Pitch = IGPlus_SnapInterp_LerpAxis(A.Pitch, B.Pitch, Alpha);
	R.Roll = 0;
	return R;
}

simulated function bool IGPlus_SnapInterp_Interpolate(
	float RenderTime,
	out vector OutPos,
	out vector OutVel,
	out rotator OutRot,
	out name OutAnimSeq,
	out byte OutAnimFrameByte,
	out byte OutAnimIntentBits,
	out byte OutAnimDodgeDir,
	out byte OutAnimPhysics,
	out float OutHintTime,
	out byte InterpMode
) {
	local int BufSize;
	local int Idx, Scans;
	local IGPlus_InterpSnapshot OlderSnap;
	local IGPlus_InterpSnapshot NewerSnap;
	local float TimeDelta, Alpha;
	local float ExtrapolationTime;
	local vector MoverOffset;

	InterpMode = 0;
	OutAnimSeq = '';
	OutAnimFrameByte = 0;
	OutAnimIntentBits = 0;
	OutAnimDodgeDir = 0;
	OutAnimPhysics = 0;
	OutHintTime = 0.0;

	if (IGPlus_SnapInterp_Count < 1)
		return false;

	BufSize = arraycount(IGPlus_SnapInterp_Data);
	Idx = (IGPlus_SnapInterp_DataIndex - 1 + BufSize) % BufSize;
	NewerSnap = None;

	for (Scans = 0; Scans < IGPlus_SnapInterp_Count; Scans++) {
		OlderSnap = IGPlus_SnapInterp_Data[Idx];

		if (OlderSnap != None && OlderSnap.Time > 0) {
			if (OlderSnap.Time <= RenderTime) {
				if (NewerSnap != None) {
					TimeDelta = NewerSnap.Time - OlderSnap.Time;
					if (TimeDelta > 0.001) {
						Alpha = (RenderTime - OlderSnap.Time) / TimeDelta;
						if (Alpha > 1.0) Alpha = 1.0;

						// World-space base interpolation
						OutPos = OlderSnap.Loc + (NewerSnap.Loc - OlderSnap.Loc) * Alpha;

						// Mover compensation: shifts each on-mover endpoint from its
						// historical server-sampled mover position to the live client
						// mover position. Alpha-weighting naturally fades the offset
						// during mount/dismount transitions, avoiding velocity pops.
						if (OlderSnap.bBasedOnMover && OlderSnap.BaseMover != None) {
							MoverOffset = OlderSnap.BaseMover.Location - OlderSnap.MoverLoc;
							if (VSize(MoverOffset) < 256.0)
								OutPos += MoverOffset * (1.0 - Alpha);
						}
						if (NewerSnap.bBasedOnMover && NewerSnap.BaseMover != None) {
							MoverOffset = NewerSnap.BaseMover.Location - NewerSnap.MoverLoc;
							if (VSize(MoverOffset) < 256.0)
								OutPos += MoverOffset * Alpha;
						}

							OutVel = OlderSnap.Vel + (NewerSnap.Vel - OlderSnap.Vel) * Alpha;
							OutRot = IGPlus_SnapInterp_LerpRot(OlderSnap.Rot, NewerSnap.Rot, Alpha);
							if (Alpha < 0.5) {
								OutAnimSeq = OlderSnap.AnimSeq;
								OutAnimFrameByte = OlderSnap.AnimFrameByte;
								OutAnimIntentBits = OlderSnap.AnimIntentBits;
								OutAnimDodgeDir = OlderSnap.AnimDodgeDir;
								OutAnimPhysics = OlderSnap.AnimPhysics;
								OutHintTime = OlderSnap.Time;
							} else {
								OutAnimSeq = NewerSnap.AnimSeq;
								OutAnimFrameByte = NewerSnap.AnimFrameByte;
								OutAnimIntentBits = NewerSnap.AnimIntentBits;
								OutAnimDodgeDir = NewerSnap.AnimDodgeDir;
								OutAnimPhysics = NewerSnap.AnimPhysics;
								OutHintTime = NewerSnap.Time;
							}
							InterpMode = 1;
							return true;
						}
				}
				ExtrapolationTime = FClamp(RenderTime - OlderSnap.Time, 0.0, 0.050);
				if (OlderSnap.bBasedOnMover && OlderSnap.BaseMover != None) {
					MoverOffset = OlderSnap.BaseMover.Location - OlderSnap.MoverLoc;
					if (VSize(MoverOffset) < 256.0)
						OutPos = OlderSnap.BaseMover.Location + OlderSnap.RelLoc;
					else
						OutPos = OlderSnap.Loc + OlderSnap.Vel * ExtrapolationTime;
				} else {
					OutPos = OlderSnap.Loc + OlderSnap.Vel * ExtrapolationTime;
				}
					OutVel = OlderSnap.Vel;
					OutRot = OlderSnap.Rot;
					OutRot.Roll = 0;
					OutAnimSeq = OlderSnap.AnimSeq;
					OutAnimFrameByte = OlderSnap.AnimFrameByte;
					OutAnimIntentBits = OlderSnap.AnimIntentBits;
					OutAnimDodgeDir = OlderSnap.AnimDodgeDir;
					OutAnimPhysics = OlderSnap.AnimPhysics;
					OutHintTime = OlderSnap.Time;
					InterpMode = 2;
					return true;
				}
			NewerSnap = OlderSnap;
		}

		Idx = (Idx - 1 + BufSize) % BufSize;
	}

	if (NewerSnap != None) {
		if (NewerSnap.bBasedOnMover && NewerSnap.BaseMover != None) {
			MoverOffset = NewerSnap.BaseMover.Location - NewerSnap.MoverLoc;
			if (VSize(MoverOffset) < 256.0)
				OutPos = NewerSnap.BaseMover.Location + NewerSnap.RelLoc;
			else
				OutPos = NewerSnap.Loc;
		} else {
			OutPos = NewerSnap.Loc;
		}
			OutVel = NewerSnap.Vel;
			OutRot = NewerSnap.Rot;
			OutRot.Roll = 0;
			OutAnimSeq = NewerSnap.AnimSeq;
			OutAnimFrameByte = NewerSnap.AnimFrameByte;
			OutAnimIntentBits = NewerSnap.AnimIntentBits;
			OutAnimDodgeDir = NewerSnap.AnimDodgeDir;
			OutAnimPhysics = NewerSnap.AnimPhysics;
			OutHintTime = NewerSnap.Time;
			InterpMode = 3;
			return true;
		}

	return false;
}

simulated function bool IGPlus_SnapInterp_ApplyIntentHint(
	byte SnapAnimIntentBits,
	byte SnapAnimDodgeDir,
	byte SnapAnimPhysics,
	optional byte InterpMode,
	optional float SnapshotAgeSec
) {
	local name TargetSeq;
	local float TweenTime;
	local float MaxIntentAgeSec;

	// Intent hints are only used in stressed modes.
	if (InterpMode <= 1)
		return false;

	// Ignore stale intent under heavy loss/clamp to avoid wrong transient pose hints.
	MaxIntentAgeSec = 0.150;
	if (SnapshotAgeSec > MaxIntentAgeSec)
		return false;

	// Bit 1: dodging
	if ((SnapAnimIntentBits & 2) != 0) {
		switch (GetDodgeDir(SnapAnimDodgeDir)) {
			case DODGE_Left:
				TargetSeq = 'DodgeL';
				break;
			case DODGE_Right:
				TargetSeq = 'DodgeR';
				break;
			case DODGE_Back:
				TargetSeq = 'DodgeB';
				break;
			case DODGE_Forward:
			case DODGE_Active:
				if ((SnapAnimIntentBits & 4) != 0)
					TargetSeq = 'Flip';
				else
					TargetSeq = 'DodgeF';
				break;
			default:
				TargetSeq = 'DodgeF';
				break;
		}

		if (AnimSequence != TargetSeq)
			TweenAnim(TargetSeq, 0.08);
		return true;
	}

	// Bit 0: ducking/crouch.
	if ((SnapAnimIntentBits & 1) != 0) {
		if (GetAnimGroup(AnimSequence) != 'Ducking') {
			TweenTime = 0.12;
			if (GetPhysics(int(SnapAnimPhysics)) == PHYS_Falling)
				TweenTime = 0.08;
			TweenAnim('DuckWlkS', TweenTime);
		}
		return true;
	}

	return false;
}

simulated function bool IGPlus_SnapInterp_IsTransientAnim(name SnapAnimSeq, name SnapAnimGroup) {
	if (SnapAnimGroup == 'Jumping' || SnapAnimGroup == 'Landing')
		return true;

	if (SnapAnimSeq == 'DodgeL' ||
		SnapAnimSeq == 'DodgeR' ||
		SnapAnimSeq == 'DodgeF' ||
		SnapAnimSeq == 'DodgeB' ||
		SnapAnimSeq == 'Flip')
		return true;

	return false;
}

simulated function float IGPlus_SnapInterp_GetAnimDurationSec(name SnapAnimSeq, name SnapAnimGroup) {
	// Based on UT99 sequence data:
	// - Jump/Land/Dodge are mostly 1-frame transients
	// - Flip is 20 (male/boss) to 31 (female) frames.
	if (SnapAnimSeq == 'Flip')
		return 0.50;
	if (SnapAnimSeq == 'DodgeL' ||
		SnapAnimSeq == 'DodgeR' ||
		SnapAnimSeq == 'DodgeF' ||
		SnapAnimSeq == 'DodgeB')
		return 0.10;
	if (SnapAnimSeq == 'JumpLgFr' || SnapAnimSeq == 'JumpSmFr')
		return 0.08;
	if (SnapAnimSeq == 'LandLgFr' || SnapAnimSeq == 'LandSmFr')
		return 0.06;

	if (SnapAnimGroup == 'Landing')
		return 0.08;
	if (SnapAnimGroup == 'Jumping')
		return 0.20;
	if (SnapAnimGroup == 'Ducking')
		return 1.00;

	return 0.25;
}

simulated function bool IGPlus_SnapInterp_IsAnimHintFresh(
	name SnapAnimSeq,
	name SnapAnimGroup,
	byte SnapAnimFrameByte,
	float SnapshotAgeSec,
	optional float FreshnessMarginSec
) {
	local float SequenceDuration;
	local float FrameAlpha;
	local float RemainingDuration;
	local float FreshnessLimit;

	SequenceDuration = IGPlus_SnapInterp_GetAnimDurationSec(SnapAnimSeq, SnapAnimGroup);
	FrameAlpha = FClamp(float(SnapAnimFrameByte) / 255.0, 0.0, 1.0);
	RemainingDuration = SequenceDuration * FClamp(1.0 - FrameAlpha, 0.0, 1.0);
	FreshnessLimit = FMin(0.300, FMax(0.040, RemainingDuration + FreshnessMarginSec));

	return SnapshotAgeSec <= FreshnessLimit;
}

simulated function bool IGPlus_SnapInterp_ApplyAnimHint(
	name SnapAnimSeq,
	byte SnapAnimFrameByte,
	optional byte InterpMode,
	optional float SnapshotAgeSec
) {
	local bool bTransient;
	local float TweenTime;
	local name SnapAnimGroup;
	local float FreshnessMarginSec;

	// InterpMode 0 means no usable interpolation output.
	if (InterpMode <= 0)
		return false;

	if (SnapAnimSeq == '')
		return false;

	SnapAnimGroup = GetAnimGroup(SnapAnimSeq);
	bTransient = IGPlus_SnapInterp_IsTransientAnim(SnapAnimSeq, SnapAnimGroup);

	// In normal interpolation mode, only allow transient sequence hints.
	if (InterpMode == 1 && bTransient == false)
		return false;

	// Expire hints based on sequence duration + frame position.
	FreshnessMarginSec = 0.060;
	if (InterpMode > 1)
		FreshnessMarginSec = 0.090;
	if (IGPlus_SnapInterp_IsAnimHintFresh(
		SnapAnimSeq,
		SnapAnimGroup,
		SnapAnimFrameByte,
		SnapshotAgeSec,
		FreshnessMarginSec
	) == false)
		return false;

	// Jumping sequences are highly transient; only use while proxy is actually airborne.
	if (SnapAnimGroup == 'Jumping') {
		if (Physics != PHYS_Falling && Velocity.Z <= 0.0)
			return false;
	}

	if (AnimSequence != SnapAnimSeq) {
		TweenTime = 0.06;
		if (SnapAnimGroup == 'Jumping')
			TweenTime = 0.08;
		else if (SnapAnimGroup == 'Ducking')
			TweenTime = 0.12;

		TweenAnim(SnapAnimSeq, TweenTime);
	}

	AnimFrame = FClamp(float(SnapAnimFrameByte) / 255.0, 0.0, 1.0);
	return true;
}

simulated function IGPlus_SnapInterp_Reset() {
	local int i;

	for (i = 0; i < arraycount(IGPlus_SnapInterp_Data); i++)
		IGPlus_SnapInterp_Data[i] = None;

	IGPlus_SnapInterp_DataIndex = 0;
	IGPlus_SnapInterp_Count = 0;
	IGPlus_SnapInterp_InterpDelay = 0.050;
	IGPlus_SnapInterp_LastArrivalTime = 0;
	IGPlus_SnapInterp_MeanInterval = 0;
	IGPlus_SnapInterp_JitterEstimate = 0;
	IGPlus_SnapInterp_LastCounter = 0;
	IGPlus_SnapInterp_EnabledLast = IGPlus_EnableSnapshotInterpolation;
}

simulated function IGPlus_SnapInterp_After(float DeltaTime) {
	local bool bReplicatedLocation;
	local bool bCanRecoverPrev;
	local bool bHasInterpolated;
	local bool bAppliedIntentHint;
	local bool bAppliedAnimHint;
	local int RepCounter;
	local int PrevCounter;
	local byte InterpMode;
	local float RenderTime;
	local float ArrivalTime;
	local float SnapshotTime;
	local float PrevSnapshotTime;
	local float ExpectedInterval;
	local float OutHintTime;
	local float HintAgeSec;
	local name OutAnimSeq;
	local byte OutAnimFrameByte;
	local byte OutAnimIntentBits;
	local byte OutAnimDodgeDir;
	local byte OutAnimPhysics;
	local vector OutPos;
	local vector OutVel;
	local rotator OutRot;
	local vector FloorSnapLoc;
	local vector FloorHitLoc;
	local vector FloorHitNorm;
	local Actor FloorActor;
	local vector TraceExtent;

	RepCounter = IGPlus_SnapReplicatedData.Counter;
	PrevCounter = IGPlus_SnapReplicatedDataPrev.Counter;
	bHasInterpolated = false;
	bAppliedIntentHint = false;
	bAppliedAnimHint = false;
	InterpMode = 0;
	OutHintTime = 0.0;
	HintAgeSec = 0.0;
	IGPlus_SnapInterp_LastInterpMode = 0;
	IGPlus_SnapInterp_LastHintAgeMs = 0;
	IGPlus_SnapInterp_LastHintSource = "none";
	bReplicatedLocation = (RepCounter > IGPlus_SnapInterp_LastCounter)
		|| (IGPlus_SnapInterp_LastCounter == 0 && RepCounter != 0);

	if (bReplicatedLocation) {
		ArrivalTime = Level.TimeSeconds;
		// Use arrival time for interpolation to avoid server clock quantization issues.
		SnapshotTime = ArrivalTime;
		bCanRecoverPrev = true;

		if (IGPlus_SnapReplicatedData.bHardSnap) {
			IGPlus_SnapInterp_StatHardSnap += 1;
			IGPlus_SnapInterp_Reset();
			bCanRecoverPrev = false;
		}

		if (bCanRecoverPrev &&
			IGPlus_SnapInterp_LastCounter > 0 &&
			PrevCounter > IGPlus_SnapInterp_LastCounter &&
			PrevCounter < RepCounter
		) {
			ExpectedInterval = IGPlus_SnapInterp_GetExpectedInterval();
			PrevSnapshotTime = ArrivalTime - ExpectedInterval;
				IGPlus_SnapInterp_Push(
					IGPlus_SnapReplicatedDataPrev.Location,
					IGPlus_SnapReplicatedDataPrev.Velocity,
					IGPlus_SnapReplicatedDataPrev.Rotation,
					IGPlus_SnapReplicatedDataPrev.AnimSequence,
					IGPlus_SnapReplicatedDataPrev.AnimFrameByte,
					IGPlus_SnapReplicatedDataPrev.AnimIntentBits,
					IGPlus_SnapReplicatedDataPrev.AnimDodgeDir,
					IGPlus_SnapReplicatedDataPrev.AnimPhysics,
					PrevSnapshotTime,
					ArrivalTime,
				true,
				IGPlus_SnapReplicatedDataPrev.bBasedOnMover,
				IGPlus_SnapReplicatedDataPrev.MoverLocation,
				IGPlus_SnapReplicatedDataPrev.BaseMover,
				false);
		}

		IGPlus_SnapInterp_LastCounter = RepCounter;
		IGPlus_SnapInterp_StatSnapPackets += 1;
			IGPlus_SnapInterp_Push(
				IGPlus_SnapReplicatedData.Location,
				IGPlus_SnapReplicatedData.Velocity,
				IGPlus_SnapReplicatedData.Rotation,
				IGPlus_SnapReplicatedData.AnimSequence,
				IGPlus_SnapReplicatedData.AnimFrameByte,
				IGPlus_SnapReplicatedData.AnimIntentBits,
				IGPlus_SnapReplicatedData.AnimDodgeDir,
				IGPlus_SnapReplicatedData.AnimPhysics,
				SnapshotTime,
				ArrivalTime,
			true,
			IGPlus_SnapReplicatedData.bBasedOnMover,
			IGPlus_SnapReplicatedData.MoverLocation,
			IGPlus_SnapReplicatedData.BaseMover,
			true);
	}

	if (IGPlus_SnapInterp_Count >= 2) {
		RenderTime = Level.TimeSeconds - IGPlus_SnapInterp_InterpDelay;
		bHasInterpolated = IGPlus_SnapInterp_Interpolate(
			RenderTime,
			OutPos,
			OutVel,
			OutRot,
			OutAnimSeq,
			OutAnimFrameByte,
			OutAnimIntentBits,
			OutAnimDodgeDir,
			OutAnimPhysics,
			OutHintTime,
			InterpMode
		);
		if (bHasInterpolated) {
			IGPlus_SnapInterp_LastInterpMode = InterpMode;
			HintAgeSec = FMax(0.0, Level.TimeSeconds - OutHintTime);
			IGPlus_SnapInterp_LastHintAgeMs = int(HintAgeSec * 1000.0 + 0.5);
		}
	}

	if (IGPlus_LocationOffsetFix_Moved == false)
		return;

	if (IGPlus_LocationOffsetFix_CollisionDummy != none) {
		IGPlus_LocationOffsetFix_CollisionDummy.bCollideWorld = false;
		IGPlus_LocationOffsetFix_CollisionDummy.SetCollision(false, false, false);
	}

	// Stats and stress-boost only when the result is actually applied;
	// the PreRender fallback call would otherwise double-count every frame.
	if (IGPlus_SnapInterp_Count >= 2) {
		if (bHasInterpolated) {
			if (InterpMode == 1)
				IGPlus_SnapInterp_StatInterp += 1;
			else if (InterpMode == 2) {
				IGPlus_SnapInterp_StatExtrap += 1;
				IGPlus_SnapInterp_BoostDelayForStress();
			} else if (InterpMode == 3) {
				IGPlus_SnapInterp_StatClamp += 1;
				IGPlus_SnapInterp_BoostDelayForStress();
			}
		} else {
			IGPlus_SnapInterp_StatFail += 1;
			IGPlus_SnapInterp_BoostDelayForStress();
		}
	}

	if (IGPlus_SnapInterp_Count < 2) {
		if (bReplicatedLocation) {
			bCollideWorld = false;
			SetLocation(IGPlus_SnapReplicatedData.Location);
			bCollideWorld = true;
			OutRot = IGPlus_SnapReplicatedData.Rotation;
			OutRot.Roll = 0;
			SetRotation(OutRot);
			DesiredRotation = OutRot;
			InterpMode = 2;
			HintAgeSec = 0.0;
			IGPlus_SnapInterp_LastInterpMode = InterpMode;
			IGPlus_SnapInterp_LastHintAgeMs = 0;
			bAppliedIntentHint = IGPlus_SnapInterp_ApplyIntentHint(
				IGPlus_SnapReplicatedData.AnimIntentBits,
				IGPlus_SnapReplicatedData.AnimDodgeDir,
				IGPlus_SnapReplicatedData.AnimPhysics,
				InterpMode,
				HintAgeSec
			);
			if (bAppliedIntentHint == false) {
				bAppliedAnimHint = IGPlus_SnapInterp_ApplyAnimHint(
					IGPlus_SnapReplicatedData.AnimSequence,
					IGPlus_SnapReplicatedData.AnimFrameByte,
					InterpMode,
					HintAgeSec
				);
			}
			if (bAppliedIntentHint)
				IGPlus_SnapInterp_LastHintSource = "intent";
			else if (bAppliedAnimHint)
				IGPlus_SnapInterp_LastHintSource = "seq";
		} else {
			bCollideWorld = false;
			SetLocation(IGPlus_LocationOffsetFix_OldLocation);
			bCollideWorld = true;
		}
		IGPlus_LocationOffsetFix_Moved = false;
		return;
	}

	if (bHasInterpolated) {
		bCollideWorld = false;
		SetLocation(OutPos);
		bCollideWorld = true;
		SetRotation(OutRot);
		DesiredRotation = OutRot;
		Velocity = OutVel;
		bAppliedIntentHint = IGPlus_SnapInterp_ApplyIntentHint(
			OutAnimIntentBits,
			OutAnimDodgeDir,
			OutAnimPhysics,
			InterpMode,
			HintAgeSec
		);
		if (bAppliedIntentHint == false) {
			bAppliedAnimHint = IGPlus_SnapInterp_ApplyAnimHint(
				OutAnimSeq,
				OutAnimFrameByte,
				InterpMode,
				HintAgeSec
			);
		}
		if (bAppliedIntentHint)
			IGPlus_SnapInterp_LastHintSource = "intent";
		else if (bAppliedAnimHint)
			IGPlus_SnapInterp_LastHintSource = "seq";
	} else {
		bCollideWorld = false;
		SetLocation(IGPlus_LocationOffsetFix_OldLocation);
		bCollideWorld = true;
	}

	// Floor-snap: SetLocation with bCollideWorld=false bypasses UE1 floor tracing.
	// Use an extent trace so slope/ramp contact uses cylinder geometry and
	// returns a center position we can snap to directly.
	// Do not floor-snap while moving upward, otherwise jump ascent can look like
	// discrete vertical snapping for simulated proxies.
	if (!bCanFly && !Region.Zone.bWaterZone && Velocity.Z <= 0.0) {
		TraceExtent.X = CollisionRadius;
		TraceExtent.Y = CollisionRadius;
		TraceExtent.Z = CollisionHeight;
		FloorActor = Trace(FloorHitLoc, FloorHitNorm,
			Location - vect(0,0,1) * (CollisionHeight + MaxStepHeight + 2),
			Location + vect(0,0,1) * (MaxStepHeight + 2),
			false,
			TraceExtent);
		if (FloorActor != None && FloorHitNorm.Z >= 0.7 && Mover(FloorActor) == None) {
			// Preserve interpolated X/Y motion. Only correct Z when the proxy
			// is slightly below the floor to avoid movement snapping.
			if (FloorHitLoc.Z > Location.Z + 0.01 && FloorHitLoc.Z - Location.Z <= MaxStepHeight + 2) {
				FloorSnapLoc = Location;
				FloorSnapLoc.Z = FloorHitLoc.Z;
				bCollideWorld = false;
				SetLocation(FloorSnapLoc);
				bCollideWorld = true;
			}
		}
	}

	IGPlus_LocationOffsetFix_Moved = false;

	if (IGPlus_LocationOffsetFix_FootstepQueued) {
		FootStepping();
		IGPlus_LocationOffsetFix_FootstepQueued = false;
	}
}

simulated function bool IGPlus_LocationOffsetFix_IsOnMover() {
	local Actor HitActor;
	local vector HitLocation;
	local vector HitNormal;
	local vector Extent;

	if (Mover(Base) != none)
		return true;

	if (bCanFly || Region.Zone.bWaterZone)
		return false;

	Extent.X = CollisionRadius;
	Extent.Y = CollisionRadius;
	Extent.Z = CollisionHeight;
	HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,8), Location, false, Extent);

	return (HitActor != none)
		&& HitActor.IsA('Mover')
		&& (HitNormal.Z >= 0.7);
}

simulated function IGPlus_LocationOffsetFix_Before() {
	if (IGPlus_LocationOffsetFix_Moved)
		return;

	// Tick Interpolation drew an earlier moment of the animation
	// (IGPlus_TI_AnimAfter). The engine plays on from its own.
	IGPlus_AnimRestore();

	if (IGPlus_LocationOffsetFix_CollisionDummy == none)
		IGPlus_LocationOffsetFix_SpawnCollisionDummy();

	IGPlus_LocationOffsetFix_OldLocation = Location;
	IGPlus_LocationOffsetFix_Velocity = Velocity;
	IGPlus_LocationOffsetFix_OnGround = IGPlus_LocationOffsetFix_IsOnGround(IGPlus_LocationOffsetFix_GroundNormal);
	IGPlus_LocationOffsetFix_WasOnMover = IGPlus_LocationOffsetFix_IsOnMover();

	SetLocation(
		vect(65535, 65535, 65535) +  // edge of the playable area
		// Separate players by some distance
		// Guarantee its always outside the playable area (+1)
		vect(512.0,512.0,512.0)*(PlayerReplicationInfo.PlayerID+1)
	);
	Velocity = IGPlus_LocationOffsetFix_DummyVel;
	IGPlus_LocationOffsetFix_SafeLocation = Location;

	if (bHidden == false &&
		Mesh != none &&
		Health > 0 &&
		PlayerReplicationInfo.bIsSpectator == false
	) {
		IGPlus_LocationOffsetFix_CollisionDummy.SetLocation(IGPlus_LocationOffsetFix_OldLocation);
		IGPlus_LocationOffsetFix_CollisionDummy.SetCollisionSize(CollisionRadius, CollisionHeight);
		IGPlus_LocationOffsetFix_CollisionDummy.bCollideWorld = true;
		IGPlus_LocationOffsetFix_CollisionDummy.SetCollision(bCollideActors, bBlockActors, bBlockPlayers);
	}

	IGPlus_LocationOffsetFix_Moved = true;
}

function IGPlus_LocationOffsetFix_TickBefore() {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;

	if (Level.Pauser != "")
		return;

	if (GameReplicationInfo != None && PlayerReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == none) break;
			P = bbPlayer(PRI.Owner);
			if (P == none) continue;
			if (P.bDeleteMe) continue;
			if (P.Role != ROLE_SimulatedProxy) continue;

			P.IGPlus_AnimRestore();
			if (IGPlus_ShouldUseSnapshotInterpForProxy(P))
				P.IGPlus_LocationOffsetFix_Before();
			else if (P.IGPlus_TI_Use())
				P.IGPlus_LocationOffsetFix_Before();
			else if (Settings.bEnableLocationOffsetFix)
				P.IGPlus_LocationOffsetFix_Before();
			else if (P.IGPlus_LocationOffsetFix_ShouldRunMoverOnly())
				P.IGPlus_LocationOffsetFix_Before();
		}
	}
}

simulated function bool IGPlus_LocationOffsetFix_ShouldRunMoverOnly() {
	local bool bOnMoverNow;

	if (IGPlus_LocationOffsetFix_Moved)
		return true;

	bOnMoverNow = IGPlus_LocationOffsetFix_IsOnMover();
	if (bOnMoverNow)
		return true;

	if (IGPlus_LocationOffsetFix_WasOnMover)
		return true;

	return VSize(IGPlus_LocationOffsetFix_PredictionOffset) > 0.01;
}

function IGPlus_FixNetspeed() {
	local int NetspeedTarget;
	local int Netspeed;

	if (IGPlus_ForcedSettings_Applied && Player.CurrentNetspeed != zzNetspeed) {
		Netspeed = int(ConsoleCommand("get ini:Engine.Engine.NetworkDevice MaxClientRate"));
		if (Netspeed < Settings.DesiredNetspeed) {
			ConsoleCommand("set ini:Engine.Engine.NetworkDevice MaxClientRate"@Settings.DesiredNetspeed);
			Netspeed = Settings.DesiredNetspeed;
		}
		if (zzMinimumNetspeed > 0 && Netspeed < zzMinimumNetspeed) {
			xxServerCheater("NS");
			return;
		}
		if (zzMaximumNetspeed > 0 && Netspeed < zzMaximumNetspeed)
			zzMaximumNetspeed = Netspeed;

		NetspeedTarget = Settings.DesiredNetspeed;
		if (zzMinimumNetspeed != 0 && NetspeedTarget < zzMinimumNetspeed)
			NetspeedTarget = zzMinimumNetspeed;
		if (zzMaximumNetspeed != 0 && NetspeedTarget > zzMaximumNetspeed)
			NetspeedTarget = zzMaximumNetspeed;

		ConsoleCommand("Netspeed"@NetspeedTarget);
		zzNetspeed = Player.CurrentNetspeed;
	}
}

event PostRender( canvas zzCanvas )
{
	local int CH;

	// Our own model was drawn with FlipAnimationFix's animation (PreRender).
	IGPlus_AnimRestore();

	if (Settings.bUseCrosshairFactory) {
		CH = MyHud.Crosshair;
		MyHud.Crosshair = ChallengeHUD(MyHud).CrosshairCount;
	}
	Super.PostRender(zzCanvas);
	if (Settings.bUseCrosshairFactory) {
		if (ChallengeHUD(MyHud).bShowInfo == false &&
			bShowScores == false &&
			ChallengeHUD(MyHud).bForceScores == false &&
			bBehindView == false &&
			Level.LevelAction == LEVACT_None &&
			Weapon != none &&
			Weapon.bOwnsCrossHair == false
		) {
			PlayerStatics.DrawCrosshair(zzCanvas, Settings);
		}
		MyHud.Crosshair = CH;
	}

	// Render our UTPure Logo
	xxRenderLogo(zzCanvas);

	IGPlus_FixNetspeed();

	if (zzDelayedStartTime != 0.0)
	{
		if (Level.TimeSeconds - zzDelayedStartTime > zzWaitTime)
		{
			if (zzDelayedVoice != None)
			{
				PlayerReplicationInfo.VoiceType = zzDelayedVoice;
				UpdateURL("Voice", string(zzDelayedVoice), True);
				ServerSetVoice(zzDelayedVoice);
				zzDelayedVoice = None;
			}
			zzDelayedStartTime = 0.0;
		}
	}

	if (bDrawDebugData && Settings.DebugDataDisplay >= 2) {
		xxDrawDebugData(zzCanvas, 10, 120);
	}

	PlayerStatics.DrawFPS(zzCanvas, MyHud, Settings, zzTick);

	PlayerStatics.DrawHitMarker(zzCanvas, Settings, zzTick);
	if (HitMarkerTestDamage > 0 && PlayerStatics.default.HitMarkerLifespan == 0) {
		PlayerStatics.PlayHitMarker(self, Settings, HitMarkerTestDamage, PlayerReplicationInfo.Team, HitMarkerTestTeam);
		++HitMarkerTestTeam;
		if (HitMarkerTestTeam >= 4)
			HitMarkerTestTeam = 0;
	}

	PlayerStatics.DrawDamageNumbers(zzCanvas, Settings, zzTick);
	if (HitMarkerTestDamage > 0 && PlayerStatics.HasActiveDamageFloater() == false) {
		PlayerStatics.PlayDamageMarker(self, HitMarkerTestDamage, PlayerReplicationInfo.Team, HitMarkerTestTeam, PlayerReplicationInfo);
		++HitMarkerTestTeam;
		if (HitMarkerTestTeam >= 4)
			HitMarkerTestTeam = 0;
	}

	if (Level.Pauser != "") {
		if (PendingMove != none) {
			PendingMove.Destroy();
			PendingMove = none;
		}
		IGPlus_SavedInputChain.RemoveOutdatedNodes(Level.TimeSeconds);
	}

	if (ChallengeHUD(MyHud).bShowInfo == false &&
		bShowScores == false &&
		ChallengeHUD(MyHud).bForceScores == false
	) {
		NetStatsElem.PostRender(zzCanvas, Settings);
	}

	IGPlus_LocationOffsetFix_TickBefore();

	IGPlus_FrameCount += 1;
}

exec simulated Function TellConsole()
{
	Log("Console class:"@player.console.class);
}

simulated function xxClientDoScreenshot(string zzMagic)
{
	zzMagicCode = zzMagic;
	zzbDoScreenshot = true;
}

simulated function xxDrawLogo(canvas zzC, float zzx, float zzY, float zzFadeValue)
{
	if (myHUD == None)
		return;

	zzC.Style = ERenderStyle.STY_Translucent;
	zzC.DrawColor = ChallengeHud(MyHud).WhiteColor * zzFadeValue;
	zzC.SetPos(zzx,zzY);
	zzC.DrawIcon(class'IGPlus_Assets'.static.Tex(texture'NewNetLogo', "NewNetLogo"),1.0);
	zzC.DrawColor = ChallengeHud(MyHud).CyanColor * zzFadeValue;
	zzC.SetPos(zzx+70,zzY+8);
	zzC.Font = ChallengeHud(MyHud).MyFonts.GetBigFont(zzC.ClipX);
	zzC.DrawText(IGPlus_LogoVersionText);
	zzC.SetPos(zzx+70,zzY+35);
	zzC.Font = ChallengeHud(MyHud).MyFonts.GetBigFont(zzC.ClipX);
	if (zzbDoScreenshot)
		zzC.DrawText(PlayerReplicationInfo.PlayerName@zzMagicCode);
	else
		zzC.DrawText("Type 'PlayerHelp' into console for commands!");
	zzC.Style = ERenderStyle.STY_Normal;
}

simulated function xxRenderLogo(canvas zzC)
{
	local float zzFadeValue, zzTimeUsed;

	if (zzbDoScreenshot)
	{
		if (zzMagicCode != "")
			xxDrawLogo(zzC, 10, zzC.ClipY - 128, 0.75);
		zzbDoScreenshot = false;
		zzbReportScreenshot = true;
	}

	if (zzbLogoDone) {
		return;
	}

	zzTimeUsed = Level.TimeSeconds - zzLogoStart;
	if (zzTimeUsed > 5.0)
	{
		zzbLogoDone = True;
		PlaySound(sound'SpeechWindowClick', SLOT_Interact);
	}

	if (zzTimeUsed > 3.0)
	{
		zzFadeValue = (5.0 - zzTimeUsed) / 2.0;
	}
	else
		zzFadeValue = 1.0;

	xxDrawLogo(zzC, 10, zzC.ClipY - 128, zzFadeValue);
}

exec function ShowFPS() {
	if (IGPlus_RefuseForced("bShowFPS", "FPS display"))
		return;
	Settings.bShowFPS = !Settings.bShowFPS;
	IGPlus_SaveSettings();
	if (Settings.bShowFPS)
		ClientMessage("FPS shown!", 'IGPlus');
	else
		ClientMessage("FPS hidden!", 'IGPlus');
}

// Picks a crosshair preset: CrosshairPreset 3, CrosshairPreset next, CrosshairPreset prev.
exec function CrosshairPreset(optional string Which) {
	ClientMessage(Settings.CrosshairPresetCommand(Which), 'IGPlus');
}

simulated function xxDrawDebugData(canvas zzC, float zzx, float zzY) {
	local Pawn P;
	local int y;
	local float Rate;

	/**
	 * @Author: spect
	 * @Date: 2020-03-07 19:56:32
	 * @Desc: Draw Debug Data
	 */

	if (MyHUD == None)
		return;

	zzC.Style = ERenderStyle.STY_Translucent;
	zzC.DrawColor = ChallengeHud(MyHud).WhiteColor;
	zzC.SetPos(zzx,zzY);
	zzC.Font = ChallengeHud(MyHud).MyFonts.GetSmallFont(zzC.ClipX);
	zzC.DrawText("ViewRot:"@ViewRotation);
	zzC.SetPos(zzx, zzY + 20);
	zzC.DrawText("NewAccel:"@debugNewAccel);
	zzC.SetPos(zzx, zzY + 40);
	zzC.DrawText("Velocity:"@Velocity);
	zzC.SetPos(zzx, zzY + 60);
	zzC.DrawText("ClientLoc:"@debugPlayerLocation);
	zzC.SetPos(zzx, zzY + 80);
	zzC.DrawText("Adaptive Buffering delay:"@IGPlus_ABDelayMs@"ms");
	zzC.SetPos(zzx, zzY + 100);
	zzC.DrawText("HitLocation:"@debugClientHitLocation);
	zzC.SetPos(zzx, zzY + 120);
	zzC.DrawText("HitNormal:"@debugClientHitNormal);
	zzC.SetPos(zzx + 20, zzY + 140);
	zzC.DrawText("Pawn?"@bClientPawnHit);
	zzC.SetPos(zzx + 20, zzY + 160);
	zzC.DrawText("HitDiff:"@debugClientHitDiff);
	zzC.SetPos(zzx, zzY + 180);
	zzC.DrawText("Other.Location:"@debugClientEnemyHitLocation);
	zzC.SetPos(zzx, zzY + 200);
	zzC.DrawText("ClientLocErr:"@debugClientLocError);
	zzC.SetPos(zzx, zzY + 220);
	zzC.DrawText("zzbForceUpdate:"@debugClientForceUpdate);
	zzC.SetPos(zzx, zzY + 240);
	zzC.DrawText("ForcedUpdates:"@debugNumOfForcedUpdates);
	if (Weapon != none) {
		zzC.SetPos(zzx, zzY + 260);
		zzC.DrawText("Weapon:"@Weapon.Name@"Class:"@Weapon.Class);
		zzC.SetPos(zzx, zzY + 280);
		zzC.DrawText("    State:"@Weapon.GetStateName());
	}
	if (PendingWeapon != none) {
		zzC.SetPos(zzx, zzY + 300);
		zzC.DrawText("PendingWeapon:"@PendingWeapon.Name@"Class:"@PendingWeapon.Class);
	}
	zzC.SetPos(zzx, zzY + 320);
	zzC.DrawText("LastUpdateTime:"@clientLastUpdateTime);
	zzC.SetPos(zzx, zzY + 340);
	zzC.DrawText("MaxTimeMargin:"@MaxTimeMargin);
	zzC.SetPos(zzx, zzY + 360);
	zzC.DrawText("finishedLoading?:"@bIsFinishedLoading);
	zzC.SetPos(zzx, zzY + 380);
	zzC.DrawText("NetUpdateRate:"@Settings.DesiredNetUpdateRate@TimeBetweenNetUpdates);
	zzC.SetPos(zzx, zzY + 400);
	zzC.DrawText("UpdatedPosition:"@clientForcedPosition);
	zzC.SetPos(zzx+20, zzY + 420);
	zzC.DrawText("Physics:"@Physics@"Anim:"@AnimSequence);
	zzC.SetPos(zzx, zzY + 440);
	zzC.DrawText("AnimRate:"@AnimRate@"TweenRate:"@TweenRate);
	zzC.SetPos(zzx+500, zzY);
	zzC.DrawText("Players:");
	y = zzY + 20;
	foreach AllActors(class'Pawn', P) {
		if (P.PlayerReplicationInfo == none) continue;
		if (P.PlayerReplicationInfo.bIsSpectator) continue;
		if (P.PlayerReplicationInfo.bIsABot) continue;

		if (P.AnimFrame >= 0.0)
			Rate = P.AnimRate;
		else
			Rate = P.TweenRate;

		zzC.SetPos(zzx+500, y);
		zzC.DrawText(
			"Player"$P.PlayerReplicationInfo.PlayerID@
			"Anim:"@P.AnimSequence@
			"Frame:"@P.AnimFrame@
			"Rate:"@Rate@
			"Duck:"@bbPlayer(P).DuckFractionRepl@
			"Loc:"@P.Location@
			"Vel:"@int(P.Velocity.X)@int(P.Velocity.Y)@int(P.Velocity.Z)
		);
		y += 20;
	}
	zzC.SetPos(zzx, zzY + 460);
	zzC.DrawText("Base:"@Base);
	zzC.SetPos(zzx+20, zzY + 480);
	if (Base != none)
		zzC.DrawText("Velocity:"@Base.Velocity@"State:"@Base.GetStateName());
	else
		zzC.DrawText("Velocity:"@vect(0,0,0)@"State:");

	zzC.SetPos(zzx, zzY + 500);
	zzC.DrawText("ExtrapolationDelta:"@ExtrapolationDelta);
	zzC.SetPos(zzx, zzY + 520);
	zzC.DrawText("EyeHeight:"@EyeHeight);
	zzC.SetPos(zzx, zzY + 540);
	zzC.DrawText("ServerMove calls"@debugServerMoveCallsSent@debugServerMoveCallsReceived);
	zzC.SetPos(zzx, zzY + 560);
	zzC.DrawText("bDodging"@bDodging@"DodgeDir"@DodgeDir);

	zzC.Style = ERenderStyle.STY_Normal;
}

exec function PureLogo()
{
	zzbLogoDone = False;
	zzLogoStart = Level.TimeSeconds;
}

function xxServerCheater(string zzCode)
{
	local string zzS;
	local Pawn zzP;

	if (zzbBadGuy)
		return;

	if (Len(zzCode) == 2)
	{
		if (zzCode == "BC")
			zzS = "Bad Console!";
		else if (zzCode == "BA")
			zzS = "Bad Canvas!";
		else if (zzCode == "SM")
			zzS = "Should not happen!";
		else if (zzCode == "TF")
			zzS = "Possible heavy ping/packetloss!";
		else if (zzCode == "IC")
			zzS = "Console not responding!";
		else if (zzCode == "HR")
			zzS = "HUD Replaced!";
		else if (zzCode == "FM")
			zzS = "Failed Mutator!";
		else if (zzCode == "AV" || zzCode == "TB" || zzCode == "FF")
			zzS = "Hacked Pure?";
		else if (zzCode == "PT")
			zzS = "Should not happen!";
		else if (zzCode == "AL")
			zzS = "Failed Adminlogin 5 times!";
		else if (zzCode == "NC")
			zzS = "Excess netspeed changes!";
		else if (zzCode == "NS")
			zzS = "MaxClientRate too low!";
		else if (zzCode == "S1" || zzCode == "S2")
			zzS = "Client Tampering!";
		else if (zzCode == "ZD")
			zzS = "Noshadow TCCs!";
		else if (zzCode == "ZE")
			zzS = "Other TCCs!";
		else if (zzCode == "HA")
			zzS = "Bloody not good (Pure messed up??)";
		else if (zzCode == "MT")
			zzS = "Mutator Kick!";
		else if (zzCode == "TD")
			zzS = "Bad TimeDilation!";
		else
			zzS = "UNKNOWN!";
		zzCode = zzCode@"-"@zzS;
	}
	xxCheatFound(zzCode);
	zzS = GetPlayerNetworkAddress();
	zzS = Left(zzS, InStr(zzS, ":"));
	zzUTPure.xxLogDate("UTPureCheat:"@PlayerReplicationInfo.PlayerName@"("$zzS$") had an impurity ("$zzCode$")", Level);
	if (zzUTPure.Settings.bTellSpectators)
	{
		for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
		{
			if (zzP.IsA('MessagingSpectator'))
				zzP.ClientMessage(PlayerReplicationInfo.PlayerName@zzS@"Pure:"@zzCode);
		}
	}
	Destroy();
	zzbBadGuy = True;
}

// ==================================================================================
// CheatFound
// ==================================================================================
simulated function xxCheatFound(string zzCode)
{
	local UTConsole C;

	if (zzbBadGuy)
		return;
	zzbBadGuy = True;

	C = UTConsole(Player.Console);
	C.AddString( "=====================================================================" );
	C.AddString( "  UTPure has detected an impurity hiding in your client!" );
	C.AddString( "  ID:"@zzCode );
	C.AddString( "=====================================================================" );
	C.AddString( "Because of this you have been removed from the" );
	C.AddString( "server.  Fair play is important, remove the impurity" );
	C.AddString( "and you can return!");
	C.AddString( " ");
	C.AddString( "If you feel this was in error, please contact the admin" );
	C.AddString( "at: "$GameReplicationInfo.AdminEmail);
	C.AddString( " ");
	C.AddString( "Please visit http://forums.utpure.com" );
	C.AddString( "You can read info regarding what UTPure is and maybe find a fix there!" );

	if (int(Level.EngineVersion) < 436)
	{
		C.AddString(" ");
		C.AddString("You currently have UT version"@Level.EngineVersion$"!");
		C.AddString("In order to play on this server, you must have version 436 or greater!");
		C.AddString("To download newest patch, go to: http://unreal.epicgames.com/Downloads.htm");
	}

	C.bQuickKeyEnable = True;
	C.LaunchUWindow();
	C.ShowConsole();
}

simulated function String GetItemName( string FullName )	// Originally not Simulated .. wtf!
{
	local int pos;

	pos = InStr(FullName, ".");
	While ( pos != -1 )
	{
		FullName = Right(FullName, Len(FullName) - pos - 1);
		pos = InStr(FullName, ".");
	}

	return FullName;
}

static function bool SetSkinElement(Actor SkinActor, int SkinNo, string SkinName, string DefaultSkinName)
{
local Texture NewSkin;
local bool bProscribed;
local string pkg, SkinItem, MeshName;

	if ( (SkinActor.Level.NetMode != NM_Standalone)	&& (SkinActor.Level.NetMode != NM_Client) && (DefaultSkinName != "") )
	{
		// make sure that an illegal skin package is not used
		// ignore if already have skins set
		if ( SkinActor.Mesh != None )
			MeshName = SkinActor.GetItemName(string(SkinActor.Mesh));
		else
			MeshName = SkinActor.GetItemName(string(SkinActor.Default.Mesh));
		SkinItem = SkinActor.GetItemName(SkinName);
		pkg = Left(SkinName, Len(SkinName) - Len(SkinItem) - 1);
		bProscribed = !CheckValidSkinPackage(pkg, MeshName);
		if ( bProscribed )
			log("Attempted to use illegal skin from package "$pkg$" for "$MeshName);
	}

	NewSkin = Texture(DynamicLoadObject(SkinName, class'Texture'));
	if ( !bProscribed && (NewSkin != None) )
	{
		SkinActor.Multiskins[SkinNo] = NewSkin;
		return True;
	}
	else
	{
		log("Failed to load "$SkinName$" so load "$DefaultSkinName);
		if(DefaultSkinName != "")
		{
			NewSkin = Texture(DynamicLoadObject(DefaultSkinName, class'Texture'));
			SkinActor.Multiskins[SkinNo] = NewSkin;
		}
		return False;
	}
}

static function string xxGetClass(string zzClassname)
{
	local string zzcls;
	local int zzP;

	zzcls = Caps(zzClassname);
	zzP = instr(zzcls,".");
	return left(zzcls,zzP);
}

simulated function xxClientDoEndShot()
{
	if (Settings.bDoEndShot)
	{
		bShowScores = True;
		zzbDoScreenshot = True;
	}
}

// Try to set the pause state; returns success indicator.
function bool SetPause( BOOL bPause )
{	// Added to avoid accessed nones in demos
	if (Level.Game != None)
		return Level.Game.SetPause(bPause, self);
	return false;
}

function SetVoice(class<ChallengeVoicePack> V)
{
	zzDelayedVoice = V;
	zzDelayedStartTime = Level.TimeSeconds;
}

function ServerSetVoice(class<ChallengeVoicePack> V)
{
	if (Level.TimeSeconds - zzDelayedStartTime > 2.5)
	{
		PlayerReplicationInfo.VoiceType = V;
		zzDelayedStartTime = Level.TimeSeconds;
	}
	else
		zzKickReady++;
}

// Send a voice message of a certain type to a certain player.
exec function Speech( int Type, int Index, int Callsign )
{
	local VoicePack V;

	if (Level.TimeSeconds - zzLastSpeech > 1.0)
	{
		V = Spawn( PlayerReplicationInfo.VoiceType, Self );
		if (V != None)
			V.PlayerSpeech( Type, Index, Callsign );
		zzLastSpeech = Level.TimeSeconds;
	}
	else
		zzKickReady++;
}

exec function ViewPlayerNum(optional int num)
{
	if (zzLastView != Level.TimeSeconds)
	{
		DoViewPlayerNum(num);
		zzLastView = Level.TimeSeconds;
	}
}

function DoViewPlayerNum(int num)
{
	local Pawn P;

	if ( !PlayerReplicationInfo.bIsSpectator && !Level.Game.bTeamGame )
		return;
	if ( num >= 0 )
	{
		P = Pawn(ViewTarget);
		if ( (P != None) && P.bIsPlayer && (P.PlayerReplicationInfo.PlayerID == num) )
		{
			ViewTarget = None;
			bBehindView = false;
			return;
		}
		for ( P=Level.PawnList; P!=None; P=P.NextPawn )
			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team)
				&& !P.PlayerReplicationInfo.bIsSpectator
				&& (P.PlayerReplicationInfo.PlayerID == num) )
			{
				if ( P != self )
				{
					ViewTarget = P;
					bBehindView = true;
				}
				return;
			}
		return;
	}
	if ( Role == ROLE_Authority )
	{
		DoViewClass(class'Pawn', true);
		While ( (ViewTarget != None)
				&& (!Pawn(ViewTarget).bIsPlayer || Pawn(ViewTarget).PlayerReplicationInfo.bIsSpectator) )
			DoViewClass(class'Pawn', true);

		if ( ViewTarget != None )
			ClientMessage(ViewingFrom@Pawn(ViewTarget).PlayerReplicationInfo.PlayerName, 'Event', true);
		else
			ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
	}
}

exec function ViewPlayer( string S )
{
	if (zzLastView != Level.TimeSeconds)
	{
		Super.ViewPlayer(S);
		zzLastView = Level.TimeSeconds;
	}
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet )
{
	if (zzLastView2 != Level.TimeSeconds)
	{
		DoViewClass(aClass,bQuiet);
		zzLastView2 = Level.TimeSeconds;
	}
}

function DoViewClass( class<actor> aClass, optional bool bQuiet )
{
	local actor other, first;
	local bool bFound;

	if ( (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;
	ForEach AllActors( aClass, other )
	{
		if ( (first == None) && (other != self)
			 && ( (bAdmin && Level.Game==None) || Level.Game.CanSpectate(self, other) ) )
		{
			first = other;
			bFound = true;
		}
		if ( other == ViewTarget )
			first = None;
	}

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( first.IsA('Pawn') && Pawn(first).bIsPlayer && (Pawn(first).PlayerReplicationInfo.PlayerName != "") )
				ClientMessage(ViewingFrom@Pawn(first).PlayerReplicationInfo.PlayerName, 'Event', true);
			else
				ClientMessage(ViewingFrom@first, 'Event', true);
		}
		ViewTarget = first;
	}
	else
	{
		if ( !bQuiet )
		{
			if ( bFound )
				ClientMessage(ViewingFrom@OwnCamera, 'Event', true);
			else
				ClientMessage(FailedView, 'Event', true);
		}
		ViewTarget = None;
	}

	bBehindView = ( ViewTarget != None );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function BehindView( Bool B )
{
	if (zzUTPure.Settings.bAllowBehindView)
		bBehindView = B;
	else if (ViewTarget != None && ViewTarget != Self)
		bBehindView = B;
	else
		bBehindView = False;
}

// Wiped due to lack of unusefulness
exec function ShowPath();

exec function ShowInventory();

exec function ToggleInstantRocket()
{
	bInstantRocket = !bInstantRocket;
	ServerSetInstantRocket(bInstantRocket);
	ClientMessage("Instant Rockets :"@bInstantRocket);
}

exec function ToggleSmoothDiscCorrections()
{
	if (IGPlus_RefuseForced("bSmoothDiscCorrections", "smooth disc corrections"))
		return;
	Settings.bSmoothDiscCorrections = !Settings.bSmoothDiscCorrections;
	IGPlus_SaveSettings();
	ClientMessage("Smooth Disc Corrections:"@Settings.bSmoothDiscCorrections, 'IGPlus');
}

exec function NeverSwitchOnPickup( bool B )
{
	bNeverAutoSwitch = B;
	bNeverSwitchOnPickup = B;
	ServerNeverSwitchOnPickup(B);
}

// Administrator functions
exec function Admin( string CommandLine )
{
	local string Result;
	if( bAdmin )
		Result = ConsoleCommand( CommandLine );

	if( Result!="" )
		ClientMessage( Result );
}

exec function AdminLogin( string Password )
{
	zzAdminLoginTries++;
	Level.Game.AdminLogin( Self, Password );
	if (bAdmin)
	{
		zzAdminLoginTries = 0;
		zzUTPure.xxLog("Admin is"@PlayerReplicationInfo.PlayerName);
	}
	else if (zzAdminLoginTries == 5)
		xxServerCheater("AL");
}

exec function AdminLogout()
{
	Level.Game.AdminLogout( Self );
	zzUTPure.xxLog("Admin was"@PlayerReplicationInfo.PlayerName);
}


exec function Sens(float F)
{
	UpdateSensitivity(F);
	ClientMessage("Sensitivity :"@F);
}

exec function ForceModels(bool b)
{

	if (IGPlus_RefuseForced("bForceModels", "forced models"))
		return;
	/**
	 * @Author: spect
	 * @Date: 2020-02-21 02:28:03
	 * @Desc: Console command to force models client side
	 */

	Settings.bForceModels = b;
	xxServerSetForceModels(b);
	IGPlus_SaveSettings();
	ClientMessage("ForceModels :"@b);
	if (!b) {
		ClientMessage("You will be reconnected in 3 seconds...");
		SetTimer(5, false);
		bReason = 1;
	}
}

simulated function reconnectClient() {
	ConsoleCommand("disconnect");
	ConsoleCommand("reconnect");
}

exec function TeamInfo(bool b)
{
	if (IGPlus_RefuseForced("bTeamInfo", "team info"))
		return;
	Settings.bTeamInfo = b;
	xxServerSetTeamInfo(b);
	IGPlus_SaveSettings();
	ClientMessage("TeamInfo :"@b);
}

exec function mdct( float f )
{
	SetMinDodgeClickTime(f);
}

exec function SetMinDodgeClickTime( float f )
{
	if (IGPlus_RefuseForced("MinDodgeClickTime", "min dodge click time"))
		return;
	Settings.MinDodgeClickTime = f;
	IGPlus_SaveSettings();
	ClientMessage("MinDodgeClickTime:"@f);
}

function xxServerSetForceModels(bool b)
{
	local int zzPureSetting;

	if (zzUTPure != None)
		zzPureSetting = zzUTPure.Settings.ForceModels;

	if (zzPureSetting == 2)			// Server Forces all clients
		zzbForceModels = True;
	else if (zzPureSetting == 1)		// Server allows client to select
		zzbForceModels = b;
	else					// Server always disallows
		zzbForceModels = False;
}

function xxServerSetTeamInfo(bool b)
{
	if (zzUTPure != None && zzUTPure.Settings.ImprovedHUD > 0)
	{
		if (b)				// Show team info as well if server allows
			HUDInfo = zzUTPure.Settings.ImprovedHUD;
		else				// Show improved hud. (Forced by server)
			HUDInfo = 1;
	}
	else
		HUDInfo = 0;
}

function xxServerSetMinDodgeClickTime(float f)
{
	Settings.MinDodgeClickTime = f;
}

exec function SetKillCamEnabled(bool b) {
	if (IGPlus_RefuseForced("bEnableKillCam", "kill cam"))
		return;
	Settings.bEnableKillCam = b;
	IGPlus_SaveSettings();
	if (b)
		ClientMessage("KillCam enabled!", 'IGPlus');
	else
		ClientMessage("KillCam disabled!", 'IGPlus');
}

exec function EndShot(optional bool b)
{
	if (IGPlus_RefuseForced("bDoEndShot", "end shot"))
		return;
	Settings.bDoEndShot = b;
	ClientMessage("Screenshot at end of match:"@b);
	IGPlus_SaveSettings();
}

exec function Hold()
{
	if (zzUTPure.zzAutoPauser != None)
		zzUTPure.zzAutoPauser.PlayerHold(PlayerReplicationInfo);
}

exec function Go()
{
	if (zzUTPure.zzAutoPauser != None)
		zzUTPure.zzAutoPauser.PlayerGo(PlayerReplicationInfo);
}

function xxServerAckScreenshot(string zzResult, string zzMagic)
{
	local Pawn zzP;
	local PlayerPawn zzPP;

	for (zzP = Level.PawnList; zzP != None; zzP = zzP.NextPawn)
	{
		zzPP = PlayerPawn(zzP);
		if (zzPP != None && zzPP.bAdmin)
			zzPP.ClientMessage(PlayerReplicationInfo.PlayerName@"successfully took screenshot!");
	}
	zzUTPure.xxLog("Screenshot from"@zzPP.PlayerReplicationInfo.PlayerName@"->"@zzResult@"Text"@zzMagicCode@"Valid"@(zzMagic == zzMagicCode));
}

simulated function xxClientLogToDemo(string zzS)
{
	Log(zzS, 'DevGarbage');
}

function xxClientResetPlayer() {
	GoToState('CountdownDying');
}

function ClientReStart()
{
	zzSpawnedTime = Level.TimeSeconds;
	IGPlus_CameraCorrectionOffset = vect(0,0,0);
	IGPlus_LiftExitCamOffset = vect(0,0,0);
	IGPlus_PushCamOffset = vect(0,0,0);
	IGPlus_LiftExitTS = 0.0;
	IGPlus_DetClientSwitchPending = none;
	IGPlus_DetClientGateWeapon = none; // the respawn equip sends a fresh tagged gate
	IGPlus_PSActive = false;
	IGPlus_PSKeep = none;
	IGPlus_PSFilterClear();

	Super.ClientReStart();
	PlaySpawn();

	if (PendingTouch != none) {
		PendingTouch.PendingTouch = none;
		PendingTouch = none;
	}

	IgnoreZChangeTicks = 1;
	if (PlayerReplicationInfo != none)
		MultiDodgesRemaining = bbPlayerReplicationInfo(PlayerReplicationInfo).MaxMultiDodges;
}

// ---------------------------------------------------------------------------
// Predicted weapon switching, phase 1: logging only.
// The IG+ HUDs catch the switch binds on the client (UPlayer::Exec offers a
// command to myHUD before the PlayerPawn) and route them here. The client
// predicts the outcome with the same rules as the server execs below, then the
// server runs the unchanged exec and logs whether the prediction held.
// Docs/predicted-weapon-switching.md
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Predicted weapon switching, phase 2 (bEnablePredictedSwitching).
// The client resolves the switch, starts it at the press timestamp TS and
// tells the server which weapon and when. Both sides then run one timeline in
// move-timestamp time: the old weapon stops at TS, holsters at
// max(TS, post-shot hold), the new weapon is equipped DownTime later and may
// fire SelectTime after that. The server validates, applies it on the moves
// whose timestamps cross those points, and rejects what it can't honour.
// ---------------------------------------------------------------------------

// Holster duration: PlayAnim('Down', DownAnimSpeed, 0.05) = 0.05 tween + DownTime.
// Fast weapon switch swaps on the spot.
simulated function float IGPlus_PSDownTimeFor(Weapon W) {
	local WeaponSettingsRepl WS;
	local float T;

	if (IGPlus_UseFastWeaponSwitch)
		return 0.0;
	// Rifle2m's and sshockm's Down: 7 frames at 30 a second, 7 at 27.
	if (IGPlus_NewNetRifleTiming(W)) {
		if (SA_SniperRifle(W) != none)
			return IGPlus_DetNewNetAnimTime(7, 30.0, 0.05);
		return IGPlus_DetNewNetAnimTime(7, 27.0, 0.05);
	}
	WS = GetWeaponSettings();
	if (WS == none)
		return 0.1;
	if (ST_ShockRifle(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.ShockDownTime, WS.default.ShockDownTime);
	else if (ST_ripper(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.RipperDownTime, WS.default.RipperDownTime);
	else if (ST_UT_FlakCannon(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.FlakDownTime, WS.default.FlakDownTime);
	else if (ST_ut_biorifle(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.BioDownTime, WS.default.BioDownTime);
	else if (ST_UT_Eightball(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.EightballDownTime, WS.default.EightballDownTime);
	else if (ST_SniperRifle(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.SniperDownTime, WS.default.SniperDownTime);
	else if (ST_SuperShockRifle(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.ShockDownTime, WS.default.ShockDownTime);
	else if (ST_minigun2(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.MinigunDownTime, WS.default.MinigunDownTime);
	else if (ST_PulseGun(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.PulseDownTime, WS.default.PulseDownTime);
	else if (ST_enforcer(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.EnforcerDownTime, WS.default.EnforcerDownTime);
	else if (ST_ImpactHammer(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.HammerDownTime, WS.default.HammerDownTime);
	else if (ST_Translocator(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.TranslocatorDownTime, WS.default.TranslocatorDownTime);
	else if (ST_WarheadLauncher(W) != none)
		T = IGPlus_DetEffectiveAnimTime(WS.WarheadDownTime, WS.default.WarheadDownTime);
	else
		T = 0.05;
	return T + 0.05;
}

// Same rule as IGPlus_DetSwitchDeferActive, evaluated at TS: a Det weapon
// holds the holster until its last shot's fire anim ends, the Eightball until
// its volley anim ends (stock holds it in FireRockets). Identical on both sides.
simulated function float IGPlus_PSHolsterStart(Weapon From, float TS) {
	local ST_UT_Eightball EB;

	// Fast weapon switch never waits for fire anims (IGPlus_DetSwitchDeferActive).
	if (IGPlus_UseFastWeaponSwitch)
		return TS;
	EB = ST_UT_Eightball(From);
	if (EB != none && TS < EB.DetVolleyHoldUntil)
		return EB.DetVolleyHoldUntil;
	if (IGPlus_IsDetActiveWeapon(From) && TS >= IGPlus_DetLastShotTS && TS < IGPlus_DetHolsterHoldUntilTS)
		return IGPlus_DetHolsterHoldUntilTS;
	return TS;
}

// Client: one of our switches has not reached its equip point yet (inclusive:
// with fast weapon switch a second press in the press frame retargets).
simulated function bool IGPlus_PSRunning() {
	return IGPlus_PSActive && Level.TimeSeconds <= IGPlus_PSEquipTS;
}

// Server -> client, with the respawn: our timestamp the server had reached
// when it respawned us. The spawn weapon's select started there.
simulated function xxClientPSSpawn(float TS) {
	IGPlus_PSSpawnTS = TS;
}

// Client: the spawn Enforcer is still in its select, here and on the server.
// The server's select started a round trip before ours (IGPlus_PSSpawnTS)
// and fires a held respawn click when it ends, so a switch is only safe if
// the press gets there first: before the anim's last frame (27 of 28), with
// 0.05 s for the press's trip. Any later select of it started later still.
simulated function bool IGPlus_PSSpawnSelectRunning() {
	local WeaponSettingsRepl WS;

	WS = GetWeaponSettings();
	if (WS == none || ST_enforcer(Weapon) == none
		|| !Weapon.IsInState('ClientActive') || Weapon.bWeaponUp)
		return false;
	return Level.TimeSeconds + 0.05 < IGPlus_PSSpawnTS
		+ IGPlus_DetEffectiveAnimTime(WS.EnforcerSelectTime, WS.default.EnforcerSelectTime) * 27.0 / 28.0;
}

simulated function bool IGPlus_PSClientCanPredict() {
	if (!IGPlus_PredictsSwitching() || Level.NetMode != NM_Client)
		return false;
	if (Weapon == none || TournamentWeapon(Weapon) == none)
		return false;
	if (IsInState('Dying') || IsInState('FeigningDeath') || Level.Pauser != ""
		|| (GameReplicationInfo != none && GameReplicationInfo.GameEndedComments != ""))
		return false;
	if (IGPlus_PSRunning())
		return true;
	// A server-driven switch is in flight; leave this press to the stock path.
	if (ClientPending != none
		|| (IGPlus_DetClientSwitchPending != none && IGPlus_DetClientSwitchPending != Weapon))
		return false;
	// Legacy weapons mid-fire hold the holster on their server fire state, and
	// the warhead may be guiding: keep stock timing for those. A respawn click
	// still held on the spawn Enforcer's select hasn't fired yet.
	if (ST_WarheadLauncher(Weapon) != none)
		return false;
	if (!IGPlus_IsDetActiveWeapon(Weapon) && (bFire != 0 || bAltFire != 0
		|| Weapon.IsInState('ClientFiring') || Weapon.IsInState('ClientAltFiring')))
		return IGPlus_PSSpawnSelectRunning();
	return true;
}

// Client: remember which ClientPutDown the server will send for a switch we
// already ran locally (From plus the targets it went through). One record per
// switch still awaiting its echo (fast weapon switch: one per key press).
simulated function IGPlus_PSFilterNew(Weapon From, Weapon T, float Until) {
	local int i;

	for (i = ArrayCount(IGPlus_PSFiltFrom) - 1; i > 0; i--) {
		IGPlus_PSFiltFrom[i] = IGPlus_PSFiltFrom[i - 1];
		IGPlus_PSFiltT1[i] = IGPlus_PSFiltT1[i - 1];
		IGPlus_PSFiltT2[i] = IGPlus_PSFiltT2[i - 1];
		IGPlus_PSFiltUntil[i] = IGPlus_PSFiltUntil[i - 1];
	}
	IGPlus_PSFiltFrom[0] = From;
	IGPlus_PSFiltT1[0] = T;
	IGPlus_PSFiltT2[0] = T;
	IGPlus_PSFiltUntil[0] = Until;
}

simulated function IGPlus_PSFilterRetarget(Weapon T, float Until) {
	IGPlus_PSFiltT2[0] = IGPlus_PSFiltT1[0];
	IGPlus_PSFiltT1[0] = T;
	IGPlus_PSFiltUntil[0] = Until;
}

simulated function IGPlus_PSFilterClear() {
	local int i;

	for (i = 0; i < ArrayCount(IGPlus_PSFiltFrom); i++)
		IGPlus_PSFiltFrom[i] = none;
}

// Drops only the server's announcement of our own switch: same outgoing
// weapon (or its slave enforcer) AND a target we chose. A server-driven switch
// of the same weapon to anything else gets through.
simulated function bool IGPlus_PSFilterDrops(Weapon Current, Weapon Next) {
	local int i;
	local Weapon F;

	if (Next == none)
		return false;
	for (i = 0; i < ArrayCount(IGPlus_PSFiltFrom); i++) {
		F = IGPlus_PSFiltFrom[i];
		if (F == none || Level.TimeSeconds > IGPlus_PSFiltUntil[i])
			continue;
		if (Next != IGPlus_PSFiltT1[i] && Next != IGPlus_PSFiltT2[i])
			continue;
		if (Current == F || (Enforcer(F) != none && Current == Enforcer(F).SlaveEnforcer))
			return true;
	}
	return false;
}

simulated function IGPlus_PSClientCommand(byte Kind, byte F, class<Weapon> C) {
	local Weapon Cur, Pend, Target;
	local float TS;
	local bool bEquipped;

	TS = Level.TimeSeconds;
	bEquipped = !IGPlus_PSRunning();
	if (bEquipped) {
		Cur = Weapon;
		Pend = none;
	} else {
		Cur = IGPlus_PSFrom;
		Pend = IGPlus_PSTarget;
	}
	if (!IGPlus_ResolveWeaponCommand(Kind, F, C, Cur, Pend, Target)) {
		// Not knowable here (Next/Prev with nothing up): stock path, unless a
		// prediction is running, which the stock exec would fight.
		if (bEquipped)
			xxServerWeaponCommand(Kind, F, C, false, none, Weapon, none);
		else
			xxServerPSCommand(IGPlus_PSSerial, Kind, F, C, TS);
		return;
	}
	// Stock ignores pressing back to the weapon still up during a switch; a
	// predicted switch treats it as "go back". Not in the frame the switch
	// started: that is the next command of a pipe bind ("getweapon A |
	// getweapon B" held on B), which stock ignores so the bind toggles.
	if (Target == none && Pend != none && Cur != none && IGPlus_WeaponHasAmmo(Cur)
		&& TS > IGPlus_PSTS
		&& ((Kind == 2 && C != none && Cur.IsA(C.Name)) || (Kind == 1 && Cur.InventoryGroup == F)))
		Target = Cur;
	// Nothing to switch to, as far as we know. Just after a respawn or a
	// pickup our new weapons or their ammo may not have reached us yet: the
	// server decides, as stock does (its exec prints any no-ammo message).
	if (Target == none && bEquipped) {
		xxServerWeaponCommand(Kind, F, C, false, none, Weapon, none);
		return;
	}
	// Stock SwitchWeapon's two WeaponChange passes print the no-ammo messages.
	if (Kind == 1 && Inventory != none
		&& !(Cur != none && Cur.Inventory != none && IGPlus_PSGroupWalk(Cur.Inventory, F)))
		IGPlus_PSGroupWalk(Inventory, F);
	if (Target == none) {
		if (Kind == 2)
			IGPlus_PSNoAmmoMessage(Cur, C);
		// Same as above mid-switch ("SwitchWeapon 2 | SwitchWeapon 4" just
		// after picking up a shock): the server may know a later target.
		xxServerPSCommand(IGPlus_PSSerial, Kind, F, C, TS);
		return;
	}

	if (!bEquipped) {
		if (Target == IGPlus_PSTarget)
			return;
		if (Target == IGPlus_PSFrom) {
			// Back to the old weapon. Started or not is decided by TS > HolsterTS
			// on both sides (a press runs between ticks, before this tick's
			// holster). The filter stays until the server's xxClientPSFilterDone:
			// it may already have sent this switch's ClientPutDown.
			if (!bPSHolsterStarted && TS > IGPlus_PSHolsterTS)
				IGPlus_PSClientTick();
			IGPlus_PSSerial++;
			IGPlus_PSActive = false;
			IGPlus_PSKeep = none;
			IGPlus_DetClientSwitchPending = none;
			IGPlus_DetClientGateWeapon = IGPlus_PSFrom;
			if (!bPSHolsterStarted) {
				IGPlus_DetClientEntryGateTS = IGPlus_PSPrevGate; // nothing moved yet
			} else {
				// Mid-holster: bring it straight back up from TS (stock BringUp).
				IGPlus_DetClientEntryGateTS = TS + IGPlus_DetSelectTimeFor(IGPlus_PSFrom);
				ClientPending = none;
				if (Weapon == IGPlus_PSFrom)
					Weapon.GotoState('ClientActive');
				else if (TournamentWeapon(Weapon) != none)
					IGPlus_PSClientHolster(IGPlus_PSFrom); // already swapped locally
			}
		} else {
			// Retarget: the holster timing stays, only the incoming weapon changes.
			IGPlus_PSSerial++;
			IGPlus_PSApplyTarget(Target, IGPlus_PSEquipTS + IGPlus_DetSelectTimeFor(Target));
		}
	} else {
		if (Target == Weapon)
			return;
		IGPlus_PSSerial++;
		IGPlus_PSActive = true;
		IGPlus_PSFrom = Weapon;
		IGPlus_PSTarget = Target;
		IGPlus_PSTS = TS;
		IGPlus_PSHolsterTS = IGPlus_PSHolsterStart(Weapon, TS);
		IGPlus_PSEquipTS = IGPlus_PSHolsterTS + IGPlus_PSDownTimeFor(Weapon);
		IGPlus_PSGate = IGPlus_PSEquipTS + IGPlus_DetSelectTimeFor(Target);
		bPSHolsterStarted = false;
		IGPlus_PSPrevGate = IGPlus_DetClientEntryGateTS;
		IGPlus_PSKeep = Weapon;
		IGPlus_PSFilterNew(Weapon, Target, IGPlus_PSEquipTS + 1.0);
		// The old weapon stops predicting now; the new one is ready at the gate.
		IGPlus_DetClientSwitchPending = Target;
		IGPlus_DetClientGateWeapon = Target;
		IGPlus_DetClientEntryGateTS = IGPlus_PSGate;
		if (IGPlus_DetPendingFireTapWeapon == Weapon)
			IGPlus_DetClearPendingFireTap();
	}
	xxServerPredictedSwitch(IGPlus_PSSerial, Target, IGPlus_PSFrom, TS, IGPlus_PSHolsterTS);
}

// Client: stock GetWeapon's "<weapon> has no ammo" message; the server never
// sees a predicted press that resolved to nothing.
simulated function IGPlus_PSNoAmmoMessage(Weapon Cur, class<Weapon> C) {
	local Inventory Inv;
	local Weapon W;
	local int Guard;

	if (C == none || (Cur != none && Cur.IsA(C.Name)))
		return;
	for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
		Guard++;
		if (Inv.IsA(C.Name)) {
			W = Weapon(Inv);
			if (W != none && !IGPlus_WeaponHasAmmo(W))
				ClientMessage(W.ItemName$W.MessageNoAmmo);
			return;
		}
	}
}

// Client: one stock Weapon.WeaponChange(F) pass from Start. True if it finds a
// loaded weapon of group F; otherwise every empty one it passed prints its
// no-ammo message, deepest first, as the stock recursion does.
simulated function bool IGPlus_PSGroupWalk(Inventory Start, byte F) {
	local Inventory Inv;
	local Weapon W, Empty[8];
	local int Guard, N;

	for (Inv = Start; Inv != none && Guard < 100; Inv = Inv.Inventory) {
		Guard++;
		W = Weapon(Inv);
		if (W == none || W.InventoryGroup != F)
			continue;
		if (IGPlus_WeaponHasAmmo(W))
			return true;
		if (N < ArrayCount(Empty)) {
			Empty[N] = W;
			N++;
		}
	}
	while (N > 0) {
		N--;
		ClientMessage(Empty[N].ItemName$Empty[N].MessageNoAmmo);
	}
	return false;
}

// Client: point the running switch at Target (retarget, or the server's
// target on a resume).
simulated function IGPlus_PSApplyTarget(Weapon Target, float Gate) {
	IGPlus_PSTarget = Target;
	IGPlus_PSGate = Gate;
	IGPlus_PSFilterRetarget(Target, IGPlus_PSEquipTS + 1.0);
	if (bPSHolsterStarted) {
		// Already swapped to the previous target locally: holster that one.
		if (Weapon != IGPlus_PSFrom && Weapon != Target && TournamentWeapon(Weapon) != none)
			IGPlus_PSClientHolster(Target);
		else if (Weapon != Target)
			ClientPending = Target;
	}
	// Always: a stale previous target here blocks the new weapon's readiness
	// for good (stock only clears it on a non-animating swap frame).
	IGPlus_DetClientSwitchPending = Target;
	IGPlus_DetClientGateWeapon = Target;
	IGPlus_DetClientEntryGateTS = Gate;
}

// Client: the holster just started; with fast weapon switch finish it on the
// spot, as the server does (ClientDown.AnimEnd's swap without the anim).
simulated function IGPlus_PSClientHolster(Weapon Next) {
	local Weapon Old;

	Old = Weapon;
	// A weapon that just reached us (the spawn weapon) isn't up yet: still
	// on its pickup mesh, its holster wouldn't animate and the move code
	// (ReplicateMove) would then bring it up, dropping ClientPending. Set it
	// up as ClientActive.BeginState does and count it as the current one.
	if (Old != OldClientWeapon) {
		if (Old.Mesh == Old.default.Mesh && Old.Mesh != Old.PlayerViewMesh)
			Old.Mesh = Old.PlayerViewMesh;
		OldClientWeapon = Old;
	}
	TournamentWeapon(Old).ClientPutDown(Next);
	if (!IGPlus_UseFastWeaponSwitch || Next == none)
		return;
	ClientPending = none;
	Weapon = Next;
	Old.GotoState('');
	Next.GotoState('ClientActive');
}

// Client, every frame: start the local holster when the timeline says so (the
// stock ClientDown state then swaps to ClientPending and plays the select), and
// hold the weapon the timeline put up against late server echoes of an earlier
// switch (replicated Weapon, RealWeapon).
simulated function IGPlus_PSClientTick() {
	if (!IGPlus_PSActive)
		return;
	if (Level.TimeSeconds > IGPlus_PSEquipTS + 1.0) {
		IGPlus_PSActive = false;
		IGPlus_PSKeep = none;
		return;
	}
	if (!bPSHolsterStarted && Level.TimeSeconds >= IGPlus_PSHolsterTS) {
		bPSHolsterStarted = true;
		if (Weapon == IGPlus_PSFrom && TournamentWeapon(Weapon) != none)
			IGPlus_PSClientHolster(IGPlus_PSTarget);
	}
	// The local swap (ClientDown.AnimEnd, after this in the frame) puts the
	// target in ClientActive: hold it from then on, even if an echo already
	// replaced Weapon (the spawn weapon's is resent until its channel is acked).
	if (bPSHolsterStarted && (Weapon == IGPlus_PSTarget
		|| (IGPlus_PSTarget != none && IGPlus_PSTarget.IsInState('ClientActive'))))
		IGPlus_PSKeep = IGPlus_PSTarget;
	if (IGPlus_PSKeep != none && Weapon != IGPlus_PSKeep
		&& IGPlus_PSKeep.Owner == self && !IGPlus_PSKeep.bDeleteMe)
		Weapon = IGPlus_PSKeep;
}

// Server -> client: the server's holster starts later than the client thought
// (later shot hold, or a late or backdated press); move the timeline with it.
simulated function xxClientPSTimes(int Serial, float HolsterTS) {
	if (Serial != IGPlus_PSSerial || !IGPlus_PSActive)
		return;
	IGPlus_PSHolsterTS = HolsterTS;
	IGPlus_PSEquipTS = HolsterTS + IGPlus_PSDownTimeFor(IGPlus_PSFrom);
	IGPlus_PSGate = IGPlus_PSEquipTS + IGPlus_DetSelectTimeFor(IGPlus_PSTarget);
	IGPlus_DetClientEntryGateTS = IGPlus_PSGate;
	IGPlus_PSFiltUntil[0] = IGPlus_PSEquipTS + 1.0;
}

// Server -> client: the server's switch keeps going to Target (a retarget it
// refused, or a press only it could resolve). Follow it instead of rolling back.
simulated function xxClientPSResume(int Serial, Weapon Target, float Gate) {
	if (Serial != IGPlus_PSSerial || !IGPlus_PSActive)
		return;
	if (Target == none)
		IGPlus_PSAwaitServerWeapon(Gate);
	else if (Target != IGPlus_PSTarget)
		IGPlus_PSApplyTarget(Target, Gate);
}

// Client: the server's switch goes to a weapon we don't have yet. A pickup
// reaches us up to 0.25s after its sound (a held weapon that isn't the current
// one replicates at most 4 times a second), so it arrives here as none and we
// can't bring it up. Holding our own target instead left us on another weapon
// than the server's until the next switch. Stop predicting and put ours down,
// as for the server's own switch to it: its Weapon brings the new one up once
// it gets here.
simulated function IGPlus_PSAwaitServerWeapon(float ServerGate) {
	ClientPutDown(Weapon, none);
	IGPlus_DetClientGateWeapon = none;
	IGPlus_DetClientEntryGateTS = ServerGate;
}

// Server -> client: the prediction was refused or overtaken; follow the server.
simulated function xxClientPSReject(int Serial, Weapon ServerWeapon, float ServerGate) {
	if (Serial != IGPlus_PSSerial)
		return; // superseded by a later press
	IGPlus_PSActive = false;
	IGPlus_PSKeep = none;
	// Going on to our own target: its holster echo is still to be dropped.
	if (ServerWeapon == none || (ServerWeapon != IGPlus_PSFiltT1[0] && ServerWeapon != IGPlus_PSFiltT2[0]))
		IGPlus_PSFilterClear();
	IGPlus_DetClientSwitchPending = none;
	IGPlus_DetClientGateWeapon = ServerWeapon;
	IGPlus_DetClientEntryGateTS = ServerGate;
	if (ServerWeapon == none) {
		// A pickup's auto-switch under way on the server, or no weapon there.
		IGPlus_PSAwaitServerWeapon(ServerGate);
		return;
	}
	if (Weapon != ServerWeapon) {
		if (ClientPending != ServerWeapon)
			Super.ClientPutDown(Weapon, ServerWeapon);
	} else if (ClientPending != none || Weapon.IsInState('ClientDown')) {
		// Still on the server's weapon but mid local holster: stand it back up.
		ClientPending = none;
		Weapon.GotoState('');
		Weapon.PlayIdleAnim();
		if (TournamentWeapon(Weapon) != none)
			TournamentWeapon(Weapon).bCanClientFire = true;
	}
}

function IGPlus_PSLog(string What) {
	if (Level.TimeSeconds - IGPlus_PSLastLogTS > 0.25) {
		IGPlus_PSLastLogTS = Level.TimeSeconds;
		IGPlus_EventLog("[PRED-SWITCH]"@What@PlayerReplicationInfo.PlayerName@"serverW="$Weapon@"pending="$PendingWeapon);
	}
}

function IGPlus_PSReject(int Serial, string Reason, Weapon ServerWeapon) {
	IGPlus_PSLog("reject"@Reason);
	// A server-driven switch under way: send the client where it's going.
	if (ServerWeapon == Weapon && PendingWeapon != none)
		ServerWeapon = PendingWeapon;
	xxClientPSReject(Serial, ServerWeapon, IGPlus_DetWeaponGateTS);
}

// The weapon must really be in this player's inventory (not just owned, e.g.
// a slave enforcer), have ammo, and not be a slave.
function bool IGPlus_PSValidTarget(Weapon T) {
	local Inventory Inv;
	local int Guard;

	if (T == none || T.Owner != self || !IGPlus_WeaponHasAmmo(T))
		return false;
	if (Enforcer(T) != none && Enforcer(T).bIsSlave)
		return false;
	for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
		Guard++;
		if (Inv == T)
			return true;
	}
	return false;
}

// Stop the outgoing weapon's DownWeapon (and its slave's) so the anim end
// can't call ChangedWeapon again after the timeline has equipped.
function IGPlus_PSStopDownState(Weapon W) {
	if (W == none)
		return;
	W.GotoState('');
	if (Enforcer(W) != none && Enforcer(W).SlaveEnforcer != none)
		Enforcer(W).SlaveEnforcer.GotoState('');
}

function xxServerPredictedSwitch(int Serial, Weapon Target, Weapon From, float TS, float ClientHolsterTS) {
	local bool bTargetOK;

	// Demo playback replays our own calls to the server: the recorded server
	// switches the weapon there, a second switch here would play it twice.
	if (Role < ROLE_Authority)
		return;

	if (!IGPlus_PredictsSwitching() || IsInState('Dying') || IsInState('FeigningDeath')
		|| Level.Game.bGameEnded || Level.Pauser != "") {
		IGPlus_PSReject(Serial, "state", Weapon);
		return;
	}
	if (TS > CurrentTimeStamp + 1.0) {
		IGPlus_PSReject(Serial, "future-ts", Weapon);
		return;
	}
	bTargetOK = IGPlus_PSValidTarget(Target);

	// Retarget / cancel of the switch in progress.
	if (IGPlus_PSActive && TS <= IGPlus_PSEquipTS && From == IGPlus_PSFrom) {
		IGPlus_PSSerial = Serial;
		if (!bTargetOK) {
			// A refused "back" already ended the client's switch: send it on to ours.
			if (Target == IGPlus_PSFrom) {
				IGPlus_PSLog("reject back="$Target);
				xxClientPSReject(Serial, IGPlus_PSTarget, IGPlus_PSGate);
				return;
			}
			xxClientPSResume(Serial, IGPlus_PSTarget, IGPlus_PSGate);
			IGPlus_PSLog("resume target="$Target);
			return;
		}
		if (Target == IGPlus_PSFrom) {
			IGPlus_PSBringBack(Serial, TS, ClientHolsterTS);
			return;
		}
		IGPlus_PSServerRetarget(Target);
		return;
	}

	// Finish our previous switch first: the client already counts it as done
	// (its press came after its equip point, or its hold ended earlier).
	if (IGPlus_PSActive) {
		if (From == IGPlus_PSTarget)
			IGPlus_PSServerAdvance(FMax(TS, IGPlus_PSEquipTS));
		else
			IGPlus_PSServerAdvance(TS);
	}
	if (IGPlus_PSActive) {
		IGPlus_PSReject(Serial, "overlap", Weapon);
		return;
	}
	if (!bTargetOK) {
		IGPlus_PSReject(Serial, "target="$Target, Weapon);
		return;
	}
	// An out-of-ammo pick that hasn't started holstering loses to the
	// player's own choice, as with the stock execs.
	if (PendingWeapon != none && PendingWeapon == IGPlus_DetAutoSwitchPending
		&& Weapon != none && !Weapon.bChangeWeapon && !Weapon.IsInState('DownWeapon')) {
		PendingWeapon = none;
		IGPlus_DetAutoSwitchPending = none;
		IGPlus_DetPendingSeen = none;
		// Retract the auto pick if the client already heard of it and it lands
		// after our predicted switch's timeline ends.
		xxClientSwitchPending(none, 0.0);
	}
	if (Weapon == none || From != Weapon || Target == Weapon || PendingWeapon != none) {
		IGPlus_PSReject(Serial, "from="$From, Weapon);
		return;
	}

	// No backdating: a press can't start before the moves already processed,
	// so holds and select time can't be skipped. A late press is moved and the
	// client told.
	TS = FMax(TS, CurrentTimeStamp);
	IGPlus_PSSerial = Serial;
	IGPlus_PSActive = true;
	IGPlus_PSFrom = Weapon;
	IGPlus_PSTarget = Target;
	IGPlus_PSTS = TS;
	IGPlus_PSHolsterTS = FMin(FMax(IGPlus_PSHolsterStart(Weapon, TS), ClientHolsterTS), TS + 1.0);
	IGPlus_PSEquipTS = IGPlus_PSHolsterTS + IGPlus_PSDownTimeFor(Weapon);
	IGPlus_PSGate = IGPlus_PSEquipTS + IGPlus_DetSelectTimeFor(Target);
	bPSHolsterStarted = false;
	IGPlus_DetAutoSwitchPending = none;
	if (IGPlus_PSHolsterTS > ClientHolsterTS + 0.001)
		xxClientPSTimes(Serial, IGPlus_PSHolsterTS);
}

function IGPlus_PSServerRetarget(Weapon Target) {
	IGPlus_PSTarget = Target;
	IGPlus_PSGate = IGPlus_PSEquipTS + IGPlus_DetSelectTimeFor(Target);
	if (bPSHolsterStarted) {
		PendingWeapon = Target;
		IGPlus_DetPendingSeen = Target; // no announcement; the client did this
	}
}

// Server: a press the client resolved to nothing during its predicted switch.
// Its copy of a just-picked-up weapon (or its ammo) may not have arrived yet:
// resolve it here, as stock would, and send the client to the new target.
// Back to From is never taken here (stock ignores it; the client knows From).
function xxServerPSCommand(int Serial, byte Kind, byte F, class<Weapon> C, float TS) {
	local Weapon Target;

	if (Role < ROLE_Authority)
		return; // demo playback (see xxServerPredictedSwitch)
	if (!IGPlus_PSActive || Serial != IGPlus_PSSerial || TS > IGPlus_PSEquipTS
		|| IsInState('Dying') || IsInState('FeigningDeath') || Level.Game.bGameEnded || Level.Pauser != "")
		return;
	if (!IGPlus_ResolveWeaponCommand(Kind, F, C, IGPlus_PSFrom, IGPlus_PSTarget, Target))
		return;
	if (Target == none || Target == IGPlus_PSFrom || Target == IGPlus_PSTarget || !IGPlus_PSValidTarget(Target))
		return;
	IGPlus_PSServerRetarget(Target);
	xxClientPSResume(Serial, Target, IGPlus_PSGate);
	IGPlus_PSLog("server-resolved target="$Target);
}

// Server: the client went back to From before the equip point, deciding
// "holster started" by TS > its HolsterTS. Not started: cancel (if our holster
// raced ahead, undo it keeping the gate the client kept). Started: From comes
// back up at TS with a fresh select (stock BringUp out of DownWeapon).
function IGPlus_PSBringBack(int Serial, float TS, float ClientHolsterTS) {
	// A server-driven switch took over during the holster: it wins.
	if (bPSHolsterStarted && (PendingWeapon != IGPlus_PSTarget || Weapon != IGPlus_PSFrom)) {
		IGPlus_PSAbort("back-overtaken");
		return;
	}
	IGPlus_PSActive = false;
	if (TS <= ClientHolsterTS) {
		if (bPSHolsterStarted)
			IGPlus_PSBringUpFrom(IGPlus_DetWeaponGateTS);
	} else {
		if (!bPSHolsterStarted) {
			// Run the holster the client ran (settles the weapon's fire state).
			IGPlus_PSActive = true;
			IGPlus_PSServerAdvance(IGPlus_PSHolsterTS);
			if (!IGPlus_PSActive)
				return; // aborted, client already told
			IGPlus_PSActive = false;
		}
		// No backdating past processed moves; ChangedWeapon sends the gate and
		// the client takes the later one.
		IGPlus_PSBringUpFrom(FMax(TS, CurrentTimeStamp) + IGPlus_DetSelectTimeFor(IGPlus_PSFrom));
	}
	// Ordered after any ClientPutDown our holster sent: the client may drop
	// its filter for this switch now.
	xxClientPSFilterDone(Serial);
}

function IGPlus_PSBringUpFrom(float Gate) {
	local Weapon TransPrev;

	IGPlus_PSGate = Gate;
	PendingWeapon = IGPlus_PSFrom;
	// Translocator.BringUp forgets the weapon it returns to; this isn't a new equip.
	if (Translocator(IGPlus_PSFrom) != none)
		TransPrev = Translocator(IGPlus_PSFrom).PreviousWeapon;
	bPSForcing = true;
	ChangedWeapon(); // Weapon == PendingWeapon in DownWeapon: BringUp
	bPSForcing = false;
	if (Translocator(IGPlus_PSFrom) != none)
		Translocator(IGPlus_PSFrom).PreviousWeapon = TransPrev;
}

simulated function xxClientPSFilterDone(int Serial) {
	if (Serial == IGPlus_PSSerial)
		IGPlus_PSFilterClear();
}

// Server: drop the prediction (a server-driven switch took over, or From is
// gone). Finish a holster already under way first (its anim-end call to
// ChangedWeapon was swallowed), then tell the client where the server is going.
function IGPlus_PSAbort(string Reason) {
	local Weapon Dest;

	IGPlus_PSActive = false;
	if (bPSHolsterStarted && Weapon != none && Weapon.IsInState('DownWeapon') && PendingWeapon != none) {
		IGPlus_PSStopDownState(Weapon);
		ChangedWeapon();
	}
	Dest = Weapon;
	if (PendingWeapon != none)
		Dest = PendingWeapon;
	IGPlus_PSReject(IGPlus_PSSerial, Reason, Dest);
}

// Server, every received move (before binding and Det steps).
function IGPlus_PSServerAdvance(float StepTS) {
	local Weapon Old;

	if (!IGPlus_PSActive)
		return;
	if (!bPSHolsterStarted) {
		if (PendingWeapon != none) {
			IGPlus_PSAbort("server-switch");
			return;
		}
		if (StepTS < IGPlus_PSHolsterTS)
			return;
		if (Weapon != IGPlus_PSFrom) {
			IGPlus_PSAbort("from-gone");
			return;
		}
		bPSHolsterStarted = true;
		PendingWeapon = IGPlus_PSTarget;
		// Keep the pending-weapon tracker from announcing what the client did.
		IGPlus_DetPendingSeen = PendingWeapon;
		IGPlus_DetPendingSeenTS = IGPlus_PSTS;
		Old = Weapon;
		Old.bChangeWeapon = true;
		if (!Old.IsInState('DownWeapon')) {
			Old.GotoState('DownWeapon');
			// Its Begin code (TweenDown) runs next tick; a bring-back or a fast
			// switch leaves DownWeapon before that. The client ran it at holster.
			Old.TweenDown();
		}
	}
	if (StepTS < IGPlus_PSEquipTS)
		return;
	if (PendingWeapon != IGPlus_PSTarget) {
		IGPlus_PSAbort("pending-changed");
		return;
	}
	Old = Weapon;
	if (Old != IGPlus_PSTarget)
		IGPlus_PSStopDownState(Old);
	bPSForcing = true;
	ChangedWeapon();
	bPSForcing = false;
	IGPlus_PSActive = false;
}

// Kind: 1 = SwitchWeapon(F), 2 = GetWeapon(C), 3 = NextWeapon, 4 = PrevWeapon.
// Entry point for the IG+ HUDs' exec stubs; falls back to the stock command for
// any non-bbPlayer owner (spectators).
static function IGPlus_HUDWeaponCommand(Actor HUDOwner, byte Kind, byte F, class<Weapon> C) {
	local PlayerPawn P;

	P = PlayerPawn(HUDOwner);
	if (bbPlayer(P) != none) {
		bbPlayer(P).IGPlus_ClientWeaponCommand(Kind, F, C);
		return;
	}
	if (P == none)
		return;
	switch (Kind) {
		case 1: P.SwitchWeapon(F); break;
		case 2: P.GetWeapon(C); break;
		case 3: P.NextWeapon(); break;
		case 4: P.PrevWeapon(); break;
	}
}

simulated function IGPlus_ClientWeaponCommand(byte Kind, byte F, class<Weapon> C) {
	local Weapon Predicted, ClientPend;
	local bool bKnown;

	if (Level.NetMode != NM_Client) {
		IGPlus_RunWeaponCommand(Kind, F, C);
		return;
	}
	if (IGPlus_PSClientCanPredict()) {
		IGPlus_PSClientCommand(Kind, F, C);
		return;
	}
	ClientPend = ClientPending;
	if (ClientPend == none)
		ClientPend = IGPlus_DetClientSwitchPending;
	bKnown = IGPlus_ResolveWeaponCommand(Kind, F, C, Weapon, ClientPend, Predicted);
	// The server puts the translocator down as this arrives and refuses its
	// actions from then: take none either until our switch comes back (a
	// translocate held back by the 0.1s lockout would land, then be undone).
	if (IGPlus_DetTranslocator && ST_Translocator(Weapon) != none
		&& !(bKnown && (Predicted == none || Predicted == Weapon)))
		IGPlus_DetTlocSwitchSentUntil = Level.TimeSeconds
			+ PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation + 0.25;
	IGPlus_DetTlocAsked = none;
	IGPlus_DetEarlyPress = 0;
	if (IGPlus_DetTranslocator && bKnown && ST_Translocator(Predicted) != none && Predicted != Weapon) {
		IGPlus_DetTlocAsked = ST_Translocator(Predicted);
		IGPlus_DetTlocAskedTS = Level.TimeSeconds;
	}
	xxServerWeaponCommand(Kind, F, C, bKnown, Predicted, Weapon, ClientPend);
}

function IGPlus_RunWeaponCommand(byte Kind, byte F, class<Weapon> C) {
	switch (Kind) {
		case 1: SwitchWeapon(F); break;
		case 2: GetWeapon(C); break;
		case 3: NextWeapon(); break;
		case 4: PrevWeapon(); break;
	}
}

function xxServerWeaponCommand(byte Kind, byte F, class<Weapon> C, bool bClientKnown,
	Weapon ClientTarget, Weapon ClientWeapon, Weapon ClientPend
) {
	local Weapon W0, P0, LogicTarget, ServerTarget;
	local bool bLogicKnown, bUnchanged, bClientMatch, bLogicMatch;

	// Demo playback (see xxServerPredictedSwitch).
	if (Role < ROLE_Authority)
		return;

	W0 = Weapon;
	P0 = PendingWeapon;
	bLogicKnown = IGPlus_ResolveWeaponCommand(Kind, F, C, W0, P0, LogicTarget);
	IGPlus_RunWeaponCommand(Kind, F, C);

	// The execs bail out here without switching; nothing to compare.
	if (IsInState('Dying') || Level.Game.bGameEnded || Level.Pauser != "")
		return;

	if (Weapon != W0)
		ServerTarget = Weapon;
	else if (PendingWeapon != P0)
		ServerTarget = PendingWeapon;
	bUnchanged = Weapon == W0 && PendingWeapon == P0;

	bClientMatch = bClientKnown && IGPlus_PredSwitchMatches(ClientTarget, ServerTarget, bUnchanged, P0);
	bLogicMatch = bLogicKnown && IGPlus_PredSwitchMatches(LogicTarget, ServerTarget, bUnchanged, P0);

	// A key for the weapon already up, or for one neither side has: nothing to
	// say (over half of these lines were that).
	if (bUnchanged && ClientWeapon == W0 && ClientPend == P0)
		return;
	if (!bClientMatch || !bLogicMatch)
		IGPlus_StatSwitchMismatch++;
	if ((!bClientMatch || !bLogicMatch) && Level.TimeSeconds - IGPlus_PredSwitchLastLogTS > 0.25) {
		IGPlus_PredSwitchLastLogTS = Level.TimeSeconds;
		IGPlus_EventLog("[PRED-SWITCH] mismatch"@PlayerReplicationInfo.PlayerName
			@"cmd="$IGPlus_WeaponCommandName(Kind, F, C)
			@"client="$ClientTarget$"(known="$bClientKnown$")"
			@"logic="$LogicTarget$"(known="$bLogicKnown$")"
			@"server="$ServerTarget$"(unchanged="$bUnchanged$")"
			@"clientW="$ClientWeapon@"clientPend="$ClientPend
			@"serverW="$W0@"serverPend="$P0);
	}
}

// An unchanged outcome also matches predicting the weapon already pending
// (re-selecting it rewrites PendingWeapon with the same value).
static final function bool IGPlus_PredSwitchMatches(Weapon Predicted, Weapon ServerTarget, bool bUnchanged, Weapon PendBefore) {
	if (Predicted == ServerTarget)
		return true;
	return bUnchanged && Predicted != none && Predicted == PendBefore;
}

static final function string IGPlus_WeaponCommandName(byte Kind, byte F, class<Weapon> C) {
	switch (Kind) {
		case 1: return "SwitchWeapon"@F;
		case 2: return "GetWeapon"@C;
		case 3: return "NextWeapon";
		case 4: return "PrevWeapon";
	}
	return "?";
}

static final function bool IGPlus_WeaponHasAmmo(Weapon W) {
	return W.AmmoType == none || W.AmmoType.AmmoAmount > 0;
}

// First weapon of group F with ammo at or after Start. Stock
// Weapon.WeaponChange does this recursively but is not simulated, so it does
// nothing on the client.
static final function Weapon IGPlus_FindGroupWeapon(Inventory Start, byte F) {
	local Inventory Inv;
	local Weapon W;
	local int Guard;

	for (Inv = Start; Inv != none && Guard < 100; Inv = Inv.Inventory) {
		Guard++;
		W = Weapon(Inv);
		if (W != none && W.InventoryGroup == F && IGPlus_WeaponHasAmmo(W))
			return W;
	}
	return none;
}

// Mirrors the switch execs below: Target = the weapon the command switches to,
// none if it changes nothing. Returns false when the outcome is not knowable
// from here (Next/Prev with no weapon up fall back to SwitchToBestWeapon).
simulated function bool IGPlus_ResolveWeaponCommand(byte Kind, byte F, class<Weapon> C,
	Weapon Cur, Weapon Pend, out Weapon Target
) {
	local Inventory Inv;
	local Weapon Base, W, Prev;
	local int Group, Guard;
	local bool bFound;

	Target = none;
	switch (Kind) {
	case 1: // SwitchWeapon(F)
		if (Inventory == none)
			return true;
		if (Cur != none && Cur.Inventory != none)
			W = IGPlus_FindGroupWeapon(Cur.Inventory, F);
		if (W == none)
			W = IGPlus_FindGroupWeapon(Inventory, F);
		if (W != Cur)
			Target = W;
		return true;

	case 2: // GetWeapon(C)
		if (Inventory == none || C == none || (Cur != none && Cur.IsA(C.Name)))
			return true;
		for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
			Guard++;
			if (Inv.IsA(C.Name)) {
				W = Weapon(Inv);
				if (W != none && IGPlus_WeaponHasAmmo(W))
					Target = W;
				return true;
			}
		}
		return true;

	case 3: // NextWeapon
		if (Cur == none)
			return false;
		Base = Cur;
		if (Pend != none)
			Base = Pend;
		Group = 100;
		for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
			Guard++;
			W = Weapon(Inv);
			if (W == none)
				continue;
			if (W.InventoryGroup == Base.InventoryGroup) {
				if (W == Base)
					bFound = true;
				else if (bFound && IGPlus_WeaponHasAmmo(W)) {
					Target = W;
					break;
				}
			} else if (W.InventoryGroup > Base.InventoryGroup && IGPlus_WeaponHasAmmo(W)
				&& W.InventoryGroup < Group) {
				Group = W.InventoryGroup;
				Target = W;
			}
		}
		// Base isn't in our chain yet (the rest of a new chain arrives behind
		// its head, a weapon we just got): the server knows the order.
		if (!bFound)
			return false;
		bFound = false;
		Group = Base.InventoryGroup;
		Guard = 0;
		if (Target == none)
			for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
				Guard++;
				W = Weapon(Inv);
				if (W == none)
					continue;
				if (W.InventoryGroup == Base.InventoryGroup) {
					if (W == Base) {
						bFound = true;
						if (Prev != none)
							Target = Prev;
					} else if (!bFound && Target == none && IGPlus_WeaponHasAmmo(W))
						Prev = W;
				} else if (W.InventoryGroup < Group && IGPlus_WeaponHasAmmo(W)) {
					Group = W.InventoryGroup;
					Target = W;
				}
			}
		return true;

	case 4: // PrevWeapon
		if (Cur == none)
			return false;
		Base = Cur;
		if (Pend != none)
			Base = Pend;
		Group = 0;
		for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
			Guard++;
			W = Weapon(Inv);
			if (W == none)
				continue;
			if (W.InventoryGroup == Base.InventoryGroup) {
				if (W == Base) {
					bFound = true;
					if (Prev != none) {
						Target = Prev;
						break;
					}
				} else if (!bFound && IGPlus_WeaponHasAmmo(W))
					Prev = W;
			} else if (W.InventoryGroup < Base.InventoryGroup && IGPlus_WeaponHasAmmo(W)
				&& W.InventoryGroup >= Group) {
				Group = W.InventoryGroup;
				Target = W;
			}
		}
		// Base isn't in our chain yet (the rest of a new chain arrives behind
		// its head, a weapon we just got): the server knows the order.
		if (!bFound)
			return false;
		bFound = false;
		Group = Base.InventoryGroup;
		Guard = 0;
		if (Target == none)
			for (Inv = Inventory; Inv != none && Guard < 100; Inv = Inv.Inventory) {
				Guard++;
				W = Weapon(Inv);
				if (W == none)
					continue;
				if (W.InventoryGroup == Base.InventoryGroup) {
					if (W == Base)
						bFound = true;
					else if (bFound && Target == none && IGPlus_WeaponHasAmmo(W))
						Target = W;
				} else if (W.InventoryGroup > Group && IGPlus_WeaponHasAmmo(W)) {
					Group = W.InventoryGroup;
					Target = W;
				}
			}
		return true;
	}
	return false;
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{	// Slightly improved GetWeapon
	local Inventory Inv;

	IGPlus_DetAutoSwitchPending = none; // a player's pick is never the auto pick
	if ( (Inventory == None) || (NewWeaponClass == None)
		|| ((Weapon != None) && Weapon.IsA(NewWeaponClass.Name))
		|| IsInState('Dying') || Level.Game.bGameEnded )
		return;

	for ( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
		if ( Inv.IsA(NewWeaponClass.Name) )
		{
			PendingWeapon = Weapon(Inv);
			if ( PendingWeapon != None && (PendingWeapon.AmmoType != None) && (PendingWeapon.AmmoType.AmmoAmount <= 0) )
			{
				ClientMessage( PendingWeapon.ItemName$PendingWeapon.MessageNoAmmo );
				PendingWeapon = None;
				IGPlus_DetTrackPendingWeapon(CurrentTimeStamp);
				return;
			}
			if (Weapon != None)
			{
				IGPlus_DetTrackPendingWeapon(CurrentTimeStamp);
				IGPlus_MarkDeterministicSwitchGuard();
				if (IGPlus_DetSwitchDeferActive())
					xxClientSwitchPending(PendingWeapon,
						IGPlus_DetHolsterHoldUntilTS - CurrentTimeStamp + 0.12);
				else
					Weapon.PutDown();
			}
			return;
		}
}

exec function SwitchWeapon(byte F)
{
	local weapon newWeapon;

	IGPlus_DetAutoSwitchPending = none; // a player's pick is never the auto pick
	if ( bShowMenu || Level.Pauser!="" || IsInState('Dying') || Level.Game.bGameEnded )
		return;
	
	if ( Inventory == None )
		return;

	if ( (Weapon != None) && (Weapon.Inventory != None) )
		newWeapon = Weapon.Inventory.WeaponChange(F);
	else
		newWeapon = None;

	if ( newWeapon == None )
		newWeapon = Inventory.WeaponChange(F);

	if ( newWeapon == None )
		return;

	if ( Weapon == none ) {
		PendingWeapon = newWeapon;
		ChangedWeapon();
	} else if ( Weapon != newWeapon ) {
		PendingWeapon = newWeapon;
		IGPlus_DetTrackPendingWeapon(CurrentTimeStamp);
		IGPlus_MarkDeterministicSwitchGuard();
		if ( Weapon != None ) {
			if (IGPlus_DetSwitchDeferActive())
				xxClientSwitchPending(PendingWeapon,
					IGPlus_DetHolsterHoldUntilTS - CurrentTimeStamp + 0.12);
			else if (!Weapon.PutDown()) {
				PendingWeapon = None;
				IGPlus_DetTrackPendingWeapon(CurrentTimeStamp);
			}
		}
	}
}

exec function PrevWeapon()
{
	local int prevGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	IGPlus_DetAutoSwitchPending = none; // a player's pick is never the auto pick
	if( bShowMenu || Level.Pauser!="" || IsInState('Dying') )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	prevGroup = 0;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;

	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
				{
					bFoundWeapon = true;
					if ( Prev != None )
					{
						PendingWeapon = Prev;
						break;
					}
				}
				else if ( !bFoundWeapon && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
					Prev = W;
			}
			else if ( (w.InventoryGroup < Weapon.InventoryGroup)
					&& ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0))
					&& (w.InventoryGroup >= prevGroup) )
			{
				prevGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}
	bFoundWeapon = false;
	prevGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
						bFoundWeapon = true;
					else if ( bFoundWeapon && (PendingWeapon == None) && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
						PendingWeapon = W;
				}
				else if ( (w.InventoryGroup > PrevGroup)
						&& ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
				{
					prevGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	Weapon = realWeapon;
	IGPlus_DetTrackPendingWeapon(CurrentTimeStamp);
	if ( PendingWeapon == None )
		return;

	IGPlus_MarkDeterministicSwitchGuard();
	if (IGPlus_DetSwitchDeferActive())
		xxClientSwitchPending(PendingWeapon,
			IGPlus_DetHolsterHoldUntilTS - CurrentTimeStamp + 0.12);
	else
		Weapon.PutDown();
}

exec function NextWeapon()
{
	local int nextGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

	IGPlus_DetAutoSwitchPending = none; // a player's pick is never the auto pick
	if( bShowMenu || Level.Pauser!="" || IsInState('Dying') )
		return;
	if ( Weapon == None )
	{
		SwitchToBestWeapon();
		return;
	}
	nextGroup = 100;
	realWeapon = Weapon;
	if ( PendingWeapon != None )
		Weapon = PendingWeapon;
	PendingWeapon = None;

	for (inv=Inventory; inv!=None; inv=inv.Inventory)
	{
		w = Weapon(inv);
		if ( w != None )
		{
			if ( w.InventoryGroup == Weapon.InventoryGroup )
			{
				if ( w == Weapon )
					bFoundWeapon = true;
				else if ( bFoundWeapon && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
				{
					PendingWeapon = W;
					break;
				}
			}
			else if ( (w.InventoryGroup > Weapon.InventoryGroup)
					&& ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0))
					&& (w.InventoryGroup < nextGroup) )
			{
				nextGroup = w.InventoryGroup;
				PendingWeapon = w;
			}
		}
	}

	bFoundWeapon = false;
	nextGroup = Weapon.InventoryGroup;
	if ( PendingWeapon == None )
		for (inv=Inventory; inv!=None; inv=inv.Inventory)
		{
			w = Weapon(Inv);
			if ( w != None )
			{
				if ( w.InventoryGroup == Weapon.InventoryGroup )
				{
					if ( w == Weapon )
					{
						bFoundWeapon = true;
						if ( Prev != None )
							PendingWeapon = Prev;
					}
					else if ( !bFoundWeapon && (PendingWeapon == None) && ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
						Prev = W;
				}
				else if ( (w.InventoryGroup < nextGroup)
					&& ((w.AmmoType == None) || (w.AmmoType.AmmoAmount>0)) )
				{
					nextGroup = w.InventoryGroup;
					PendingWeapon = w;
				}
			}
		}

	Weapon = realWeapon;
	IGPlus_DetTrackPendingWeapon(CurrentTimeStamp);
	if ( PendingWeapon == None )
		return;

	IGPlus_MarkDeterministicSwitchGuard();
	if (IGPlus_DetSwitchDeferActive())
		xxClientSwitchPending(PendingWeapon,
			IGPlus_DetHolsterHoldUntilTS - CurrentTimeStamp + 0.12);
	else
		Weapon.PutDown();
}

simulated function ChangedWeapon() {
	// Predicted switch: the old weapon's DownWeapon anim ending calls this on
	// server time; the timeline equips at IGPlus_PSEquipTS instead.
	if (Role == ROLE_Authority && IGPlus_PSActive && bPSHolsterStarted && !bPSForcing
		&& PendingWeapon == IGPlus_PSTarget)
		return;

	// (Not for a predicted bring-back: stock BringUp needs DownWeapon.)
	if (Weapon != None && IGPlus_UseFastWeaponSwitch && !(bPSForcing && Weapon == PendingWeapon)) {
		Weapon.GotoState('');
		IGPlus_MarkDeterministicSwitchGuard();
		if (!bPSForcing) // a predicted switch: the client already swapped
			ClientPutDown(none, PendingWeapon);
	}

	// Grace for in-flight steps still targeting the outgoing weapon.
	if (Role == ROLE_Authority && Weapon != None && Weapon != PendingWeapon) {
		IGPlus_DetFinalizeExpiredPrevWeapon(true);
		IGPlus_DetPrevWeapon = Weapon;
		IGPlus_DetAutoSwitchPending = none;
		IGPlus_DetInFlightSlack = IGPlus_DetComputeInFlightSlack();
		IGPlus_DetPrevWeaponStepTS = CurrentTimeStamp + IGPlus_DetInFlightSlack;
		IGPlus_DetPrevWeaponUntilTS = CurrentTimeStamp + FMax(0.25, IGPlus_DetInFlightSlack + 0.13);
		if (bPSForcing) {
			// The client stopped predicting the old weapon after TS (a step
			// stamped TS was built before the press).
			IGPlus_DetPrevWeaponStepTS = IGPlus_PSTS + 0.0001;
			IGPlus_DetPrevWeaponUntilTS = CurrentTimeStamp + 0.25;
		}
		// Drop only a click queued for the outgoing weapon. A click on the
		// incoming one (client already in its select) must survive, or the
		// client fires it alone. Client mirrors this in ClientPutDown.
		if (IGPlus_DetPendingFireTapWeapon != PendingWeapon)
			IGPlus_DetClearPendingFireTap();
	}

	Super.ChangedWeapon();

	if (Role == ROLE_Authority && Level.NetMode != NM_Standalone
		&& RemoteRole == ROLE_AutonomousProxy) {
		if (IGPlus_DetSupportsWeapon(Weapon)) {
			// Gate from the real select duration, not a floor; replicate the
			// post-FMax value so the client holds the server's exact gate.
			IGPlus_DetWeaponGateTS = FMax(IGPlus_DetWeaponGateTS, CurrentTimeStamp + IGPlus_DetSelectTimeFor(Weapon));
			if (bPSForcing)
				IGPlus_DetWeaponGateTS = IGPlus_PSGate; // the gate the client already holds
			xxClientDetEntryGate(IGPlus_DetWeaponGateTS, Weapon);
		} else {
			// v4 steps clear bFire/bAltFire; restore held state for legacy weapons.
			bFire = byte(IGPlus_LastFireEndHeld);
			bAltFire = byte(IGPlus_LastAltEndHeld);
		}
		IGPlus_DetPendingSeen = PendingWeapon;
	}
}

// Demo playback: the recording holds our own weapon's animations and sounds
// as our screen had them (DemoPlaySound, AnimSequence). The recorded server
// calls below drove them while recording, so here they would play them again:
// the select of a switch, a hammer blast. With predicted switching and
// self-knockback our screen ran them a ping before these calls came in, so the
// second copy is heard apart from the first.
function ClientWeaponEvent(name EventType)
{
	if (IGPlus_InDemoPlayback())
		return;
	Super.ClientWeaponEvent(EventType);
}

function SendClientFire(Weapon W, int N)
{
	if (IGPlus_InDemoPlayback() || IGPlus_PSDropsSelectFire(W, N))
		return;
	Super.SendClientFire(W, N);
}

function SendClientAltFire(Weapon W, int N)
{
	if (IGPlus_InDemoPlayback() || IGPlus_PSDropsSelectFire(W, N))
		return;
	Super.SendClientAltFire(W, N);
}

// The server's select of the weapon our predicted switch is putting down
// ended with fire held before our press got there (a late press packet), and
// fired there. Stock would fire whatever we hold now, mid-holster or already
// the new weapon. The server takes the switch on; keep showing it.
function bool IGPlus_PSDropsSelectFire(Weapon W, int N) {
	if (!IGPlus_PSActive || W != IGPlus_PSFrom)
		return false;
	if (N > WeaponUpdate)
		WeaponUpdate = N;
	return true;
}

// Stock: the server's select-end "this weapon is really up". During a predicted
// switch a late one for the previous weapon would undo the local switch.
function RealWeapon(Weapon Real, int N)
{
	if (IGPlus_InDemoPlayback())
		return;
	if (IGPlus_PSActive && (IGPlus_PSRunning() || Real != IGPlus_PSKeep)) {
		if (N > WeaponUpdate)
			WeaponUpdate = N;
		return;
	}
	Super.RealWeapon(Real, N);
}

function ClientPutDown(Weapon Current, Weapon Next)
{
	if (IGPlus_InDemoPlayback())
		return;
	// The server's holster announcement for a switch this client predicted:
	// it already ran the holster and select locally.
	if (IGPlus_PSFilterDrops(Current, Next))
		return;
	// Anything else is a server-driven switch: it overrides our prediction.
	IGPlus_PSActive = false;
	IGPlus_PSKeep = none;
	IGPlus_MarkDeterministicSwitchGuard();
	IGPlus_DetClientSwitchPending = none; // the real holster has started
	if (IGPlus_DetPendingFireTapWeapon != Next)
		IGPlus_DetClearPendingFireTap(); // server mirrors this in ChangedWeapon
	Super.ClientPutDown(Current, Next);
}

exec function Say(string Msg) {
	if (Msg ~= "r" ||
		Msg ~= "rdy" ||
		Msg ~= "ready" ||
		Msg ~= "!rdy" ||
		Msg ~= "!ready"
	) {
		Ready();
	} else if (Msg ~= "!IGPlusMenu") {
		IGPlusMenu();
	}
	super.Say(Msg);
}

//enhanced teamsay:
exec function TeamSay( string Msg )
{
	local string OutMsg;
	local string cmd;
	local int pos, zzi;
	local int ArmorAmount;
	local inventory inv;

	local int x;
	local int zone;  // 0=Offense, 1 = Defense, 2= float
	local flagbase Red_FB, Blue_FB;
	local CTFFlag F,Red_F, Blue_F;
	local float dRed_b, dBlue_b, dRed_f, dBlue_f;

	if (!zzUTPure.Settings.bAdvancedTeamSay || PlayerReplicationInfo.Team == 255) {
		Super.TeamSay(Msg);
		return;
	}

	pos = InStr(Msg, "%");
	while (pos >= 0) {
		if (pos > 0) {
			OutMsg = OutMsg$Left(Msg,pos);
			Msg = Mid(Msg,pos);
			pos = 0;
		}

		x = len(Msg);
		if (x >= 2) {
			cmd = Left(Msg, 2);
			Msg = Right(Msg,x-2);
		} else {
			// A lone % at the end. break, not continue: continue skips the
			// InStr at the bottom, pos stays 0 and the loop never ends.
			OutMsg = OutMsg$Msg;
			Msg = "";
			break;
		}

		if (cmd == "%H") {
			OutMsg = OutMsg$Health$" Health";
		} else if (cmd == "%h") {
			OutMsg = OutMsg$Health$"%";
		} else if (cmd ~= "%W") {
			if (Weapon == None)
				OutMsg = OutMsg$"Empty hands";
			else
				OutMsg = OutMsg$Weapon.GetHumanName();
		} else if (cmd == "%A") {
			ArmorAmount = 0;
			for( Inv=Inventory; Inv != None; Inv = Inv.Inventory ) {
				if (Inv.bIsAnArmor) {
					if ( Inv.IsA('UT_Shieldbelt') )
						OutMsg = OutMsg$Inv.Charge@"Shieldbelt and ";
					else
						ArmorAmount += Inv.Charge;
				}
			}
			OutMsg = OutMsg$ArmorAmount$" Armor";
		} else if (cmd == "%a") {
			ArmorAmount = 0;
			for( Inv=Inventory; Inv != None; Inv = Inv.Inventory ) {
				if (Inv.bIsAnArmor) {
					if ( Inv.IsA('UT_Shieldbelt') )
						OutMsg = OutMsg$Inv.Charge$"SB ";
					else
						ArmorAmount += Inv.Charge;
				}
			}
			OutMsg = OutMsg$ArmorAmount$"A";
		} else if (cmd ~= "%P" && GameReplicationInfo.IsA('CTFReplicationInfo')) {
			// CTF only
			// Figure out Posture.

			for (zzi=0; zzi < 4; zzi++) {
				f = CTFReplicationInfo(GameReplicationInfo).FlagList[zzi];
				if (f == None)
					break;
				if (F.HomeBase.Team == 0)
					Red_FB = F.HomeBase;
				else if (F.HomeBase.Team == 1)
					Blue_FB = F.HomeBase;
				if (F.Team == 0)
					Red_F = F;
				else if (F.Team == 1)
					Blue_F = F;
			}

			dRed_b = VSize(Location - Red_FB.Location);
			dBlue_b = VSize(Location - Blue_FB.Location);
			dRed_f = VSize(Location - Red_F.Position().Location);
			dBlue_f = VSize(Location - Blue_F.Position().Location);

			if (PlayerReplicationInfo.Team == 0) {
				if (dRed_f < 2048 && Red_F.Holder != None && (Blue_f.Holder == None || dRed_f < dBlue_f))
					zone = 0;
				else if (dBlue_f < 2048 && Blue_F.Holder != None && (Red_f.Holder == None || dRed_f > dBlue_f))
					zone = 1;
				else if (dBlue_b < 2049)
					zone = 2;
				else if (dRed_b < 2048)
					zone = 3;
				else
					zone = 4;
			} else if (PlayerReplicationInfo.Team == 1) {
				if (dBlue_f < 2048 && Blue_f.Holder != None && (Red_f.Holder == None || dRed_f >= dBlue_f))
					zone = 0;
				else if (dRed_f < 2048 && Red_f.Holder != None && (Blue_f.Holder == None || dRed_f < dBlue_f))
					zone = 1;
				else if (dRed_b < 2048)
					zone = 2;
				else if (dBlue_b < 2048)
					zone = 3;
				else
					zone = 4;
			}

			if ( (Blue_f.Holder == Self) || (Red_f.Holder == Self) )
				zone = 5;

			Switch(zone) {
				Case 0:	OutMsg = OutMsg$"Attacking Enemy Flag Carrier";
					break;
				Case 1: OutMsg = OutMsg$"Supporting Our Flag Carrier";
					break;
				Case 2: OutMsg = OutMsg$"Attacking";
					break;
				Case 3: OutMsg = OutMsg$"Defending";
					break;
				Case 4: OutMsg = OutMsg$"Floating";
					break;
				Case 5: OutMsg = OutMsg$"Carrying Flag";
					break;
			}
		} else if (cmd == "%%") {
			OutMsg = OutMsg$"%";
		} else {
			OutMsg = OutMsg$cmd;
		}

		pos = InStr(Msg, "%");
	}

	OutMsg = OutMsg$Msg;

	Super.TeamSay(OutMsg);
}

function Typing( bool bTyping )
{
	bIsTyping = bTyping;
	if (bTyping)
	{
		PlayChatting();
	}
}

////////////////////////////
// Tracebot stopper: By DB
////////////////////////////

simulated function bool IGPlus_DetectDemoPlayback() {
	local Pawn P;

	if (Level.NetMode != NM_Client)
		return false;

	// udemo spawns its spectator before any demo actors arrive
	for (P = Level.PawnList; P != none; P = P.NextPawn)
		if (P.IsA('DemoPlaybackSpec'))
			return true;

	return false;
}

simulated function bool IGPlus_InDemoPlayback() {
	// Recheck once a second so we never depend on the demo spectator spawning first
	if (IGPlus_IsDemoPlayback == false && Level.NetMode == NM_Client && Level.TimeSeconds >= IGPlus_DemoCheckTime) {
		IGPlus_IsDemoPlayback = IGPlus_DetectDemoPlayback();
		IGPlus_DemoCheckTime = Level.TimeSeconds + 1.0;
	}

	return IGPlus_IsDemoPlayback || zzbDemoPlayback;
}

// =============================================================================
// Server demos (IGPlus_SD...)
//
// A server demo writes every player once per server tick, as the server has
// them. That is not what the player saw: moves run when their packets arrive,
// so the recorded path steps with network jitter, the view is the pawn's
// pitch-clamped Rotation, and the others are at server time.
//
// The server records, demo-only (live clients and client demos never get it):
// - IGPlus_DemoPos/DemoViewPitch/DemoViewYaw/IGPlus_DemoEye: the player's
//   location, exact view and eye height re-timed to their own move clock
//   (client timestamps), a short playout delay behind their newest move.
// - IGPlus_DemoRawOff: the server Location, as an offset from IGPlus_DemoPos.
// - IGPlus_DemoOthersDelayMs: how far behind the server the player saw the
//   others (their hitscan rewind), on the same clock as IGPlus_DemoPos.
// - IGPlus_DemoFOV/IGPlus_DemoZoomed, IGPlus_DemoWeaponAmbient, and the
//   personal messages (IGPlus_DemoLocalizedMessage).
// Playback (udemo following a recorded player) draws the camera from it, and
// the others where that player saw them.
// =============================================================================

// Server, every tick, after this tick's moves (ServerTick).
function IGPlus_SDServerRecord(float DeltaTime) {
	local float Now, ArrivalOffset, WinMin, TargetDelay, Tc, Alpha, NewRewind;
	local int k, Idx, NewerIdx, OlderIdx;
	local vector Pos, Loc;
	local int View, PitchA, PitchB, YawA, YawB, Pitch, Yaw;
	local float Eye;
	local IGPlus_WeaponImplementationBase WImpBase;

	if (RemoteRole != ROLE_AutonomousProxy)
		return;

	Now = Level.TimeSeconds;

	// A client clock that went back (reconnect, reset), or a long silence:
	// start over.
	if (CurrentTimeStamp < IGPlus_SDLastMoveTS - 0.5
		|| (CurrentTimeStamp > IGPlus_SDLastMoveTS && Now - IGPlus_SDLastSampleTime > 2.0)) {
		IGPlus_SDRecCount = 0;
		IGPlus_SDHaveOffset = false;
		if (CurrentTimeStamp < IGPlus_SDLastMoveTS)
			IGPlus_SDLastMoveTS = 0;
	}

	if (CurrentTimeStamp > IGPlus_SDLastMoveTS) {
		// The earliest a move arrives, relative to its timestamp, is the
		// client clock seen from here. A later arrival waited in the network.
		ArrivalOffset = Now - CurrentTimeStamp;
		if (IGPlus_SDHaveOffset == false) {
			IGPlus_SDMinCur = ArrivalOffset;
			IGPlus_SDMinPrev[0] = ArrivalOffset;
			IGPlus_SDMinPrev[1] = ArrivalOffset;
			IGPlus_SDMinPrev[2] = ArrivalOffset;
			IGPlus_SDMinBucketEnd = Now + 1.0;
			IGPlus_SDOffset = ArrivalOffset;
			IGPlus_SDWinMin = ArrivalOffset;
			IGPlus_SDJitter = 0;
			IGPlus_SDRecCount = 0;
			IGPlus_SDHaveOffset = true;
		}
		IGPlus_SDMinCur = FMin(IGPlus_SDMinCur, ArrivalOffset);
		WinMin = FMin(FMin(IGPlus_SDMinCur, IGPlus_SDMinPrev[0]), FMin(IGPlus_SDMinPrev[1], IGPlus_SDMinPrev[2]));
		IGPlus_SDJitter += (FClamp(ArrivalOffset - WinMin, 0.0, 0.25) - IGPlus_SDJitter) * 0.05;

		// Where the move put us.
		Loc = Location;

		// A translocation, teleport or respawn: no gliding across the map.
		// The jump shows at its own move's time.
		IGPlus_SDRecBreak[IGPlus_SDRecHead] = 0;
		if (IGPlus_SDRecCount > 0) {
			Idx = IGPlus_SDRecHead - 1;
			if (Idx < 0)
				Idx += IGPLUS_SD_RECSIZE;
			if (TlocCounter != IGPlus_SDLastTloc
				|| VSize(Loc - IGPlus_SDRecLoc[Idx]) > 64 + 3000 * FClamp(CurrentTimeStamp - IGPlus_SDRecTS[Idx], 0.0, 0.1))
				IGPlus_SDRecBreak[IGPlus_SDRecHead] = 1;
		}
		IGPlus_SDLastTloc = TlocCounter;

		IGPlus_SDRecTS[IGPlus_SDRecHead] = CurrentTimeStamp;
		IGPlus_SDRecLoc[IGPlus_SDRecHead] = Loc;
		// On a lift, also where on the lift: the lift moves in server time.
		if (Mover(Base) != none) {
			IGPlus_SDRecBase[IGPlus_SDRecHead] = Base;
			IGPlus_SDRecRel[IGPlus_SDRecHead] = Loc - Base.Location;
		} else {
			IGPlus_SDRecBase[IGPlus_SDRecHead] = none;
		}
		IGPlus_SDRecView[IGPlus_SDRecHead] = ((ViewRotation.Pitch & 0xFFFF) << 16) | (ViewRotation.Yaw & 0xFFFF);
		IGPlus_SDRecEye[IGPlus_SDRecHead] = EyeHeight;
		// The same move as it arrived, for tools that measure aim.
		IGPlus_DemoRawView = IGPlus_SDRecView[IGPlus_SDRecHead];
		IGPlus_DemoRawTS = CurrentTimeStamp;
		IGPlus_SDRecHead++;
		if (IGPlus_SDRecHead >= IGPLUS_SD_RECSIZE)
			IGPlus_SDRecHead = 0;
		IGPlus_SDRecCount = Min(IGPlus_SDRecCount + 1, IGPLUS_SD_RECSIZE);
		IGPlus_SDLastMoveTS = CurrentTimeStamp;
		IGPlus_SDLastSampleTime = Now;
	}

	// The client clock: the lowest arrival offset of the last 3-4 seconds.
	// A lasting ping rise is taken in within seconds (at most 10% slower
	// playback while it catches up). A ping drop only shrinks the margin, so
	// it is taken in slowly.
	if (IGPlus_SDHaveOffset) {
		if (Now >= IGPlus_SDMinBucketEnd) {
			IGPlus_SDMinPrev[2] = IGPlus_SDMinPrev[1];
			IGPlus_SDMinPrev[1] = IGPlus_SDMinPrev[0];
			IGPlus_SDMinPrev[0] = IGPlus_SDMinCur;
			IGPlus_SDMinCur = 1000000.0;
			IGPlus_SDMinBucketEnd = Now + 1.0;
		}
		WinMin = FMin(FMin(IGPlus_SDMinCur, IGPlus_SDMinPrev[0]), FMin(IGPlus_SDMinPrev[1], IGPlus_SDMinPrev[2]));
		if (WinMin < 1000.0) {
			IGPlus_SDWinMin = WinMin;
			if (WinMin > IGPlus_SDOffset)
				IGPlus_SDOffset += FMin(WinMin - IGPlus_SDOffset, 0.1 * DeltaTime);
			else
				IGPlus_SDOffset -= FMin(IGPlus_SDOffset - WinMin, 0.02 * DeltaTime);
		}
	}

	// Playout delay: enough to cover the usual lateness, changed slowly
	// (at most 2% faster or slower than real time).
	TargetDelay = FClamp(2.5 * IGPlus_SDJitter + 0.005, 0.01, 0.1);
	if (IGPlus_SDDelay <= 0)
		IGPlus_SDDelay = TargetDelay;
	else
		IGPlus_SDDelay += FClamp(TargetDelay - IGPlus_SDDelay, -0.02 * DeltaTime, 0.02 * DeltaTime);

	if (IGPlus_SDRecCount == 0 || Now - IGPlus_SDLastSampleTime > 0.25 * Level.TimeDilation) {
		// No recent moves (dead, paused, lost): the server's own values.
		Pos = Location;
		View = ((ViewRotation.Pitch & 0xFFFF) << 16) | (ViewRotation.Yaw & 0xFFFF);
		Eye = EyeHeight;
	} else {
		Tc = Now - IGPlus_SDOffset - IGPlus_SDDelay;
		NewerIdx = -1;
		OlderIdx = -1;
		for (k = 0; k < IGPlus_SDRecCount; k++) {
			Idx = IGPlus_SDRecHead - 1 - k;
			if (Idx < 0)
				Idx += IGPLUS_SD_RECSIZE;
			if (IGPlus_SDRecTS[Idx] <= Tc) {
				OlderIdx = Idx;
				break;
			}
			NewerIdx = Idx;
		}
		if (OlderIdx < 0 || NewerIdx < 0) {
			// Older than all we have (the oldest move), or past the newest
			// (a late packet: hold the newest).
			Idx = OlderIdx;
			if (Idx < 0)
				Idx = NewerIdx;
			Pos = IGPlus_SDRecPos(Idx);
			View = IGPlus_SDRecView[Idx];
			Eye = IGPlus_SDRecEye[Idx];
		} else if (IGPlus_SDRecBreak[NewerIdx] != 0) {
			// A jump comes next: still at the old spot until its time.
			Pos = IGPlus_SDRecPos(OlderIdx);
			View = IGPlus_SDRecView[OlderIdx];
			Eye = IGPlus_SDRecEye[OlderIdx];
		} else {
			Alpha = FClamp((Tc - IGPlus_SDRecTS[OlderIdx]) / FMax(IGPlus_SDRecTS[NewerIdx] - IGPlus_SDRecTS[OlderIdx], 0.0001), 0.0, 1.0);
			Pos = IGPlus_SDRecPos(OlderIdx) + (IGPlus_SDRecPos(NewerIdx) - IGPlus_SDRecPos(OlderIdx)) * Alpha;
			Eye = IGPlus_SDRecEye[OlderIdx] + (IGPlus_SDRecEye[NewerIdx] - IGPlus_SDRecEye[OlderIdx]) * Alpha;
			PitchA = IGPlus_SDRecView[OlderIdx] >>> 16;
			PitchB = IGPlus_SDRecView[NewerIdx] >>> 16;
			YawA = IGPlus_SDRecView[OlderIdx] & 0xFFFF;
			YawB = IGPlus_SDRecView[NewerIdx] & 0xFFFF;
			Pitch = (PitchA + int(float(((PitchB - PitchA + 32768) & 0xFFFF) - 32768) * Alpha)) & 0xFFFF;
			Yaw = (YawA + int(float(((YawB - YawA + 32768) & 0xFFFF) - 32768) * Alpha)) & 0xFFFF;
			View = (Pitch << 16) | Yaw;
		}
	}

	IGPlus_DemoPos = Pos;
	IGPlus_DemoRawOff = Location - Pos;
	DemoViewPitch = View >>> 16;
	DemoViewYaw = View & 0xFFFF;
	IGPlus_DemoEye = Eye;
	IGPlus_DemoFOV = IGPlus_ClientFOV;
	IGPlus_DemoZoomed = IGPlus_ClientZoomed;
	if (Weapon != none)
		IGPlus_DemoWeaponAmbient = Weapon.AmbientSound;
	else
		IGPlus_DemoWeaponAmbient = none;
	IGPlus_DemoFlags = 1;

	// The others' delay: the rewind hit detection used, changed slowly (it
	// switches between Precise Rewind Time and the average ping).
	if (Now >= IGPlus_SDNextRewindRead) {
		IGPlus_SDNextRewindRead = Now + 0.1;
		WImpBase = IGPlus_GetWeaponImplementationBase();
		if (WImpBase != none)
			IGPlus_SDRewindTarget = 0.001 * WImpBase.IGPlus_GetHitscanRewindMs(self) * Level.TimeDilation;
	}
	NewRewind = IGPlus_SDRewindTarget;
	if (IGPlus_SDRewindTime <= 0)
		IGPlus_SDRewindTime = NewRewind;
	else
		IGPlus_SDRewindTime += FClamp(NewRewind - IGPlus_SDRewindTime, -0.02 * DeltaTime, 0.02 * DeltaTime);
	// The camera shows a move IGPlus_SDOffset + IGPlus_SDDelay after its
	// timestamp. Hit detection rewound from when the move really arrived:
	// IGPlus_SDWinMin + IGPlus_SDJitter after it, on average.
	IGPlus_DemoOthersDelayMs = int(1000.0 * FMax(IGPlus_SDRewindTime + IGPlus_SDDelay + IGPlus_SDOffset - IGPlus_SDWinMin - IGPlus_SDJitter, 0.0) + 0.5);
}

// A recorded move's position. On a lift: where on the lift, with the lift
// where it is now (it moves in server time).
function vector IGPlus_SDRecPos(int Idx) {
	if (IGPlus_SDRecBase[Idx] != none && IGPlus_SDRecBase[Idx].bDeleteMe == false)
		return IGPlus_SDRecRel[Idx] + IGPlus_SDRecBase[Idx].Location;
	return IGPlus_SDRecLoc[Idx];
}

// Server: one record of a deterministic rifle or sniper shot for the server
// demo, hit or miss, called before the damage. For tools that measure aim:
// nothing in the game reads it. View is the exact view the shot left with,
// Start where its trace began, WeaponId 0 the rifle (ST_SuperShockRifle) and
// 1 the sniper (ST_SniperRifle).
function IGPlus_SDNoteShot(Actor Other, bool bHead, vector Start, rotator View, vector HitLocation, int WeaponId) {
	local PlayerReplicationInfo TargetPRI;
	local IGPlus_WeaponImplementationBase WB;
	local WeaponSettingsRepl WS;
	local int Result, Client, RewindMs, PingMs;
	local float TS;
	local Pawn TP;
	local UTPlusDummy BD;
	local vector BodyOff;
	local int Body;

	if (Pawn(Other) != None)
		TargetPRI = Pawn(Other).PlayerReplicationInfo;
	if (TargetPRI != None) {
		if (bHead)
			Result = 2;
		else
			Result = 1;
	}
	// What the shooter's own trace said (IGPLUS_HIT_MISS, _BODY, _HEAD).
	if (IGPlus_ClientHitVerdict >= IGPLUS_HIT_MISS && IGPlus_ClientHitVerdict <= IGPLUS_HIT_HEAD)
		Client = IGPlus_ClientHitVerdict - IGPLUS_HIT_MISS + 1;
	// Nothing is rewound with ping compensation off.
	WS = GetWeaponSettings();
	WB = IGPlus_GetWeaponImplementationBase();
	if (WS != None && WS.bEnablePingCompensation && WB != None)
		RewindMs = Clamp(int(WB.IGPlus_GetHitscanRewindMs(self) + 0.5), 0, 1023);
	if (PlayerReplicationInfo != None)
		PingMs = Clamp(PlayerReplicationInfo.Ping, 0, 1023);
	// A shot that waited for the end of the tick has its own time stamp with
	// it: a later shot of ours has replaced IGPlus_DetLastShotTS by then.
	TS = IGPlus_SDShotTS;
	if (TS == 0.0)
		TS = IGPlus_DetLastShotTS;

	// Where the hit sits on the body the server tested: the target's rewound
	// copy if the hit lies on it, else the target where it stands now (a
	// target with no history yet). Neither: the fields stay 0.
	TP = Pawn(Other);
	if (TP != None) {
		if (WS != None && WS.bEnablePingCompensation && zzUTPure != None)
			BD = zzUTPure.FindDummy(TP);
		if (BD != None && IGPlus_SDOnBody(HitLocation - BD.Location, BD)) {
			BodyOff = HitLocation - BD.Location;
			Body = 1 | (int(FClamp(BD.DuckFraction, 0.0, 1.0) * 255.0) << 2) | ((BD.Rotation.Yaw & 0xFFFF) << 16);
		} else if (IGPlus_SDOnBody(HitLocation - TP.Location, TP)) {
			BodyOff = HitLocation - TP.Location;
			Body = 2 | ((TP.Rotation.Yaw & 0xFFFF) << 16);
			if (WB != None)
				Body = Body | (int(FClamp(WB.GetPawnDuckFraction(TP), 0.0, 1.0) * 255.0) << 2);
		}
	}

	IGPlus_DemoShot(
		TS,
		((View.Pitch & 0xFFFF) << 16) | (View.Yaw & 0xFFFF),
		Start.X, Start.Y, Start.Z,
		HitLocation,
		TargetPRI,
		(WeaponId & 1) | (Result << 1) | (Client << 3) | (RewindMs << 5) | (PingMs << 15),
		BodyOff.X, BodyOff.Y, BodyOff.Z,
		Body);
}

// Whether a hit point lies on this body. The game pushes a hit point half a
// radius into the body along the shot (AdjustHitLocation), so it can sit
// that far outside the cylinder.
function bool IGPlus_SDOnBody(vector Off, Actor A) {
	local float R;

	R = 1.5 * A.CollisionRadius + 1.0;
	return Abs(Off.Z) <= A.CollisionHeight + 0.5 * A.CollisionRadius + 1.0 && Off.X * Off.X + Off.Y * Off.Y <= R * R;
}

// A shot record, written to a server demo only (IGPlus_SDNoteShot). This
// format is in every demo recorded from here on, so it only grows at the end.
//   TS       the shot's client time stamp, the clock of IGPlus_DemoRawTS
//   View     (Pitch << 16) | Yaw, 16 bits each
//   Origin   where the trace began, exact (a vector goes in whole units)
//   HitLoc   where the trace ended, in whole units
//   Target   the player the server hit, None for a miss
//   Data     bit 0      weapon: 0 rifle, 1 sniper
//            bits 1-2   server: 0 miss, 1 body, 2 head
//            bits 3-4   the shooter's own trace: 0 none sent, 1 miss, 2 body, 3 head
//            bits 5-14  the server's rewind figure, ms (0 to 1023): what
//                       IGPlus_GetHitscanRewindMs gave, the number [DET-HIT]
//                       prints. 0 with ping compensation off
//            bits 15-24 the shooter's ping, ms (0 to 1023)
//   BodyX/Y/Z  a hit on a player: the hit point minus the middle of the
//            body the server tested, in world axes, exact. The hit point
//            sits half a radius inside that body along the shot
//            (AdjustHitLocation). Turned by the yaw below it gives where
//            on the body the hit sits
//   Body     bits 0-1   which body: 0 no player hit, 1 the target's
//                       rewound copy, 2 the target where it stood
//            bits 2-9   that body's crouch, 0 to 255 (255 fully crouched)
//            bits 16-31 that body's yaw
// Playback and the server keep the newest one and count them.
// ponytail: one record held, not a list. These weapons fire slower than a
// tick, so a tool that looks every frame sees each one.
simulated function IGPlus_DemoShot(
	float TS,
	int View,
	float OriginX,
	float OriginY,
	float OriginZ,
	vector HitLoc,
	PlayerReplicationInfo Target,
	int Data,
	float BodyX,
	float BodyY,
	float BodyZ,
	int Body
) {
	IGPlus_DemoShotTS = TS;
	IGPlus_DemoShotView = View;
	IGPlus_DemoShotOrigin.X = OriginX;
	IGPlus_DemoShotOrigin.Y = OriginY;
	IGPlus_DemoShotOrigin.Z = OriginZ;
	IGPlus_DemoShotHit = HitLoc;
	IGPlus_DemoShotTarget = Target;
	IGPlus_DemoShotData = Data;
	IGPlus_DemoShotBodyOff.X = BodyX;
	IGPlus_DemoShotBodyOff.Y = BodyY;
	IGPlus_DemoShotBodyOff.Z = BodyZ;
	IGPlus_DemoShotBody = Body;
	IGPlus_DemoShotCount++;
}

// Server: a personal message, written to a server demo only. Stock
// ReceiveLocalizedMessage is never recorded in a server demo.
simulated function IGPlus_DemoLocalizedMessage(
	class<LocalMessage> Message,
	int Sw,
	PlayerReplicationInfo RelatedPRI_1,
	PlayerReplicationInfo RelatedPRI_2,
	Object OptionalObject
) {
	if (Role == ROLE_Authority || Level.NetMode != NM_Client || Message == none)
		return;
	IGPlus_SDPersonalMessage(Message, Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

// Server: every pickup asks GameInfo.PickupQuery first, and UTPure's
// HandlePickupQuery tells us. Whether it is taken is decided after that
// (inventory chain, full health, Touch), so IGPlus_SDCheckPickups looks later.
function IGPlus_SDNotePickupQuery(Inventory Item) {
	local int i, Free;

	if (Item == none || Item.bHidden)
		return;
	Free = -1;
	for (i = 0; i < ArrayCount(IGPlus_SDPickupItem); i++) {
		if (IGPlus_SDPickupTicks[i] > 0 && IGPlus_SDPickupItem[i] == Item)
			return;
		if (Free < 0 && IGPlus_SDPickupTicks[i] == 0)
			Free = i;
	}
	if (Free < 0)
		return;
	IGPlus_SDPickupItem[Free] = Item;
	IGPlus_SDPickupClass[Free] = Item.Class;
	IGPlus_SDPickupTicks[Free] = 2;
}

// Server, every tick after the moves: a noted item that is now taken (gone to
// its respawn wait, destroyed, or ours) gets the pickup message stock code
// sent it, copied for a server demo, which never records the stock call.
function IGPlus_SDCheckPickups() {
	local int i;
	local Inventory Item;
	local class<Inventory> C;

	for (i = 0; i < ArrayCount(IGPlus_SDPickupItem); i++) {
		if (IGPlus_SDPickupTicks[i] == 0)
			continue;
		Item = IGPlus_SDPickupItem[i];
		if (Item != none && Item.bDeleteMe == false && Item.bHidden == false && Item.Owner != self) {
			IGPlus_SDPickupTicks[i]--;
			continue;
		}
		IGPlus_SDPickupTicks[i] = 0;
		IGPlus_SDPickupItem[i] = none;
		C = IGPlus_SDPickupClass[i];
		if (C == none)
			continue;
		if (ClassIsChildOf(C, class'TournamentHealth'))
			IGPlus_DemoLocalizedMessage(class'PickupMessageHealthPlus', 0, none, none, C);
		else if (C.default.PickupMessageClass != none)
			IGPlus_DemoLocalizedMessage(C.default.PickupMessageClass, 0, none, none, C);
		else
			IGPlus_DemoClientMessage(C.default.PickupMessage, 'Pickup', false);
	}
}

// Server: a text message only this player got (a pickup message without a
// message class), written to a server demo only. Playback shows it to a viewer
// following us. Broadcast text needs no copy: the engine's DemoRecSpectator
// gets it.
simulated function IGPlus_DemoClientMessage(string S, name Type, bool bBeep) {
	local PlayerPawn V;

	if (Role == ROLE_Authority || Level.NetMode != NM_Client)
		return;
	V = IGPlus_SDFollowingViewer();
	if (V != none)
		V.ClientMessage(S, Type, bBeep);
}

// Server: a team chat line this player got, written to a server demo only.
// Playback shows it to a viewer following us.
simulated function IGPlus_DemoTeamMessage(PlayerReplicationInfo PRI, string S, name Type) {
	local PlayerPawn V;

	if (Role == ROLE_Authority || Level.NetMode != NM_Client)
		return;
	V = IGPlus_SDFollowingViewer();
	if (V != none)
		V.TeamMessage(PRI, S, Type, true);
}

// Server demo playback: a recorded player written by a server with this code.
simulated function bool IGPlus_SDIsServerDemoProxy() {
	return Role == ROLE_SimulatedProxy && IGPlus_DemoFlags != 0 && Level.NetMode == NM_Client;
}

simulated function PlayerPawn IGPlus_SDGetViewer() {
	local PlayerPawn P;

	if (IGPlus_SDViewer != none && IGPlus_SDViewer.bDeleteMe == false)
		return IGPlus_SDViewer;
	IGPlus_SDViewer = none;
	if (Level.TimeSeconds < IGPlus_SDViewerSearchTime)
		return none;
	IGPlus_SDViewerSearchTime = Level.TimeSeconds + 0.5;

	foreach AllActors(class'PlayerPawn', P)
		if (P.IsA('DemoPlaybackSpec')) {
			IGPlus_SDViewer = P;
			return P;
		}
	foreach AllActors(class'PlayerPawn', P)
		if (P != self && P.Role == ROLE_Authority && Viewport(P.Player) != none) {
			IGPlus_SDViewer = P;
			return P;
		}
	return none;
}

// The viewer, if they are following us.
simulated function PlayerPawn IGPlus_SDFollowingViewer() {
	local PlayerPawn V;

	V = IGPlus_SDGetViewer();
	if (V != none && V.ViewTarget == self)
		return V;
	return none;
}

simulated function IGPlus_DemoClock IGPlus_SDGetClock() {
	local IGPlus_DemoClock C;

	if (IGPlus_SDClock != none && IGPlus_SDClock.bDeleteMe == false)
		return IGPlus_SDClock;
	IGPlus_SDClock = none;
	if (Level.TimeSeconds < IGPlus_SDClockSearchTime)
		return none;
	IGPlus_SDClockSearchTime = Level.TimeSeconds + 1.0;
	foreach AllActors(class'IGPlus_DemoClock', C) {
		IGPlus_SDClock = C;
		break;
	}
	return IGPlus_SDClock;
}

// Our server Location in this demo frame.
simulated function vector IGPlus_SDServerLocation() {
	return IGPlus_DemoPos + IGPlus_DemoRawOff;
}

// Playback, every frame (simulated Tick), after this frame's demo data.
simulated function IGPlus_SDPlaybackTick(float DeltaTime) {
	local IGPlus_DemoClock C;
	local int Idx;

	// Still drawn elsewhere (behind view has no RenderOverlays to put us
	// back): back to the demo's position for this frame.
	if (IGPlus_SDDisplaced)
		IGPlus_SDRestore();

	// Our projectile glides only while someone follows us.
	if (IGPlus_SDGlideUpdateTime > 0
		&& (Level.TimeSeconds - IGPlus_SDGlideUpdateTime > 0.1 || IGPlus_SDFollowingViewer() == none)) {
		IGPlus_SDEndAllGlides();
		IGPlus_SDGlideUpdateTime = 0;
	}

	// Server positions by server time, for drawing us where someone else saw us.
	C = IGPlus_SDGetClock();
	if (C != none && C.ServerTime != IGPlus_SDHistLastTime) {
		if (C.ServerTime < IGPlus_SDHistLastTime || C.ServerTime > IGPlus_SDHistLastTime + 1.0)
			IGPlus_SDHistCount = 0; // seek
		IGPlus_SDHistLastTime = C.ServerTime;
		Idx = IGPlus_SDHistHead;
		IGPlus_SDHistTime[Idx] = C.ServerTime;
		IGPlus_SDHistLoc[Idx] = IGPlus_SDServerLocation();
		IGPlus_SDHistPos[Idx] = IGPlus_DemoPos;
		IGPlus_SDHistView[Idx] = ((DemoViewPitch & 0xFFFF) << 16) | (DemoViewYaw & 0xFFFF);
		IGPlus_SDHistEye[Idx] = IGPlus_DemoEye;
		if (Mover(Base) != none) {
			IGPlus_SDHistBase[Idx] = Base;
			IGPlus_SDHistRel[Idx] = IGPlus_SDHistLoc[Idx] - Base.Location;
		} else {
			IGPlus_SDHistBase[Idx] = none;
		}
		if (bHidden)
			IGPlus_SDHistHidden[Idx] = 1;
		else
			IGPlus_SDHistHidden[Idx] = 0;
		IGPlus_SDHistHead++;
		if (IGPlus_SDHistHead >= IGPLUS_SD_HISTSIZE)
			IGPlus_SDHistHead = 0;
		IGPlus_SDHistCount = Min(IGPlus_SDHistCount + 1, IGPLUS_SD_HISTSIZE);
	}

	// Weapon loops (minigun, pulse gun). A server demo drops the weapon's
	// AmbientSound (owner and bClientAnim), so it plays from us instead.
	if (IGPlus_DemoWeaponAmbient != none) {
		if (AmbientSound != IGPlus_DemoWeaponAmbient) {
			AmbientSound = IGPlus_DemoWeaponAmbient;
			if (Weapon != none) {
				SoundRadius = Weapon.default.SoundRadius;
				SoundPitch = Weapon.default.SoundPitch;
			}
			SoundVolume = 255;
		}
		IGPlus_SDAmbientSet = true;
	} else if (IGPlus_SDAmbientSet) {
		AmbientSound = default.AmbientSound;
		SoundRadius = default.SoundRadius;
		SoundVolume = default.SoundVolume;
		SoundPitch = default.SoundPitch;
		IGPlus_SDAmbientSet = false;
	}
}

// Draw us at NewLoc for this frame. What rides on us (shield belt, carried
// flag) comes along. Collision is off while we are there: we are only drawn
// there, nothing should touch us.
simulated function IGPlus_SDDisplace(vector NewLoc, bool bHide) {
	local Actor A;
	local Decoration Flag;
	local vector Delta;
	local int i;

	if (IGPlus_SDDisplaced == false) {
		IGPlus_SDDisplaced = true;
		IGPlus_SDNumAttached = 0;
		// Only PHYS_Trailer actors (shield belt, UDamage glow), not our
		// projectiles. ChildActors lists us too.
		foreach ChildActors(class'Actor', A) {
			if (A == self || A.bHidden || A.Physics != PHYS_Trailer)
				continue;
			if (IGPlus_SDNumAttached >= arraycount(IGPlus_SDAttached))
				break;
			IGPlus_SDAttached[IGPlus_SDNumAttached] = A;
			IGPlus_SDAttachedLoc[IGPlus_SDNumAttached] = A.Location;
			IGPlus_SDNumAttached++;
		}
		if (PlayerReplicationInfo != none)
			Flag = PlayerReplicationInfo.HasFlag;
		if (Flag != none && Flag.Owner != self && Flag.bHidden == false
			&& IGPlus_SDNumAttached < arraycount(IGPlus_SDAttached)) {
			IGPlus_SDAttached[IGPlus_SDNumAttached] = Flag;
			IGPlus_SDAttachedLoc[IGPlus_SDNumAttached] = Flag.Location;
			IGPlus_SDNumAttached++;
		}
		IGPlus_SDTrueLoc = Location;
		IGPlus_SDSavedCollideActors = bCollideActors;
		IGPlus_SDSavedBlockActors = bBlockActors;
		IGPlus_SDSavedBlockPlayers = bBlockPlayers;
		IGPlus_SDSavedCollideWorld = bCollideWorld;
		SetCollision(false, false, false);
		bCollideWorld = false;
		if (bHide && bHidden == false) {
			bHidden = true;
			IGPlus_SDHiddenByDisplace = true;
		}
	}

	Delta = NewLoc - IGPlus_SDTrueLoc;
	SetLocation(NewLoc);
	IGPlus_SDDisplacedTo = Location;
	for (i = 0; i < IGPlus_SDNumAttached; i++)
		if (IGPlus_SDAttached[i] != none && IGPlus_SDAttached[i].bDeleteMe == false)
			IGPlus_SDAttached[i].SetLocation(IGPlus_SDAttachedLoc[i] + Delta);
}

// Back to the demo's position for this frame (not a saved spot: the demo
// may have sent a new one since).
simulated function IGPlus_SDRestore() {
	local int i;

	if (IGPlus_SDDisplaced == false)
		return;

	SetLocation(IGPlus_SDServerLocation());
	for (i = 0; i < IGPlus_SDNumAttached; i++) {
		if (IGPlus_SDAttached[i] != none && IGPlus_SDAttached[i].bDeleteMe == false)
			IGPlus_SDAttached[i].SetLocation(IGPlus_SDAttachedLoc[i]);
		IGPlus_SDAttached[i] = none;
	}
	IGPlus_SDNumAttached = 0;

	// Collision back, unless the demo changed it meanwhile or we died (the
	// server turns it off then, and the demo won't send that again).
	if (Health > 0 && bCollideActors == false && bBlockActors == false && bBlockPlayers == false)
		SetCollision(IGPlus_SDSavedCollideActors, IGPlus_SDSavedBlockActors, IGPlus_SDSavedBlockPlayers);
	bCollideWorld = IGPlus_SDSavedCollideWorld;

	// Visible again, unless we died meanwhile (the demo then has us hidden
	// already and won't send it again).
	if (IGPlus_SDHiddenByDisplace) {
		if (Health > 0)
			bHidden = false;
		IGPlus_SDHiddenByDisplace = false;
	}
	IGPlus_SDDisplaced = false;
}

// Our server position at server time T. False if we don't have T.
simulated function bool IGPlus_SDHistAt(float T, out vector L, out byte bWasHidden) {
	local int k, Idx, NewerIdx;
	local float Alpha;
	local vector LA, LB;

	NewerIdx = -1;
	for (k = 0; k < IGPlus_SDHistCount; k++) {
		Idx = IGPlus_SDHistHead - 1 - k;
		if (Idx < 0)
			Idx += IGPLUS_SD_HISTSIZE;
		if (IGPlus_SDHistTime[Idx] <= T) {
			bWasHidden = IGPlus_SDHistHidden[Idx];
			// Riding a lift we still ride: on the lift where it is now (the
			// lift is drawn at server time, hit detection moved it back too).
			LA = IGPlus_SDHistLoc[Idx];
			if (IGPlus_SDHistBase[Idx] != none && IGPlus_SDHistBase[Idx].bDeleteMe == false)
				LA = IGPlus_SDHistRel[Idx] + IGPlus_SDHistBase[Idx].Location;
			L = LA;
			// Between two frames, unless we jumped (teleport, respawn): then
			// we were still at the old spot.
			if (NewerIdx >= 0 && VSize(IGPlus_SDHistLoc[NewerIdx] - IGPlus_SDHistLoc[Idx]) < 256) {
				LB = IGPlus_SDHistLoc[NewerIdx];
				if (IGPlus_SDHistBase[NewerIdx] != none && IGPlus_SDHistBase[NewerIdx].bDeleteMe == false)
					LB = IGPlus_SDHistRel[NewerIdx] + IGPlus_SDHistBase[NewerIdx].Location;
				Alpha = FClamp((T - IGPlus_SDHistTime[Idx]) / FMax(IGPlus_SDHistTime[NewerIdx] - IGPlus_SDHistTime[Idx], 0.0001), 0.0, 1.0);
				L = LA + (LB - LA) * Alpha;
			}
			return true;
		}
		NewerIdx = Idx;
	}
	// Older than all we have (just after a seek): the oldest.
	if (NewerIdx >= 0) {
		L = IGPlus_SDHistLoc[NewerIdx];
		if (IGPlus_SDHistBase[NewerIdx] != none && IGPlus_SDHistBase[NewerIdx].bDeleteMe == false)
			L = IGPlus_SDHistRel[NewerIdx] + IGPlus_SDHistBase[NewerIdx].Location;
		bWasHidden = IGPlus_SDHistHidden[NewerIdx];
		return true;
	}
	return false;
}

simulated function GameReplicationInfo IGPlus_SDGetGRI() {
	local PlayerPawn V;

	if (GameReplicationInfo != none)
		return GameReplicationInfo;
	V = IGPlus_SDGetViewer();
	if (V != none)
		return V.GameReplicationInfo;
	return none;
}

// The followed player's screen: the others where they saw them.
simulated function IGPlus_SDDisplaceOthers() {
	local IGPlus_DemoClock C;
	local GameReplicationInfo GRI;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;
	local float T;
	local vector L;
	local byte bWasHidden;
	local int i;

	C = IGPlus_SDGetClock();
	GRI = IGPlus_SDGetGRI();
	if (C == none || GRI == none)
		return;

	T = C.IGPlus_DisplayTime() - 0.001 * float(IGPlus_DemoOthersDelayMs);
	for (i = 0; i < arraycount(GRI.PRIArray); i++) {
		PRI = GRI.PRIArray[i];
		if (PRI == none)
			break;
		P = bbPlayer(PRI.Owner);
		if (P == none || P == self || P.IGPlus_SDIsServerDemoProxy() == false)
			continue;
		// Dead now: the carcass is the server's. Not shown alive again here.
		if (P.bHidden && P.IGPlus_SDHiddenByDisplace == false)
			continue;
		if (P.IGPlus_SDHistAt(T, L, bWasHidden))
			P.IGPlus_SDDisplace(L, bWasHidden != 0);
	}
	IGPlus_SDDisplacedOthers = true;
}

simulated function IGPlus_SDRestoreOthers() {
	local GameReplicationInfo GRI;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;
	local int i;

	IGPlus_SDDisplacedOthers = false;
	GRI = IGPlus_SDGetGRI();
	if (GRI == none)
		return;
	for (i = 0; i < arraycount(GRI.PRIArray); i++) {
		PRI = GRI.PRIArray[i];
		if (PRI == none)
			break;
		P = bbPlayer(PRI.Owner);
		if (P != none && P != self && P.IGPlus_SDDisplaced)
			P.IGPlus_SDRestore();
	}
}

// The camera at server time T: our own move timing, between two demo frames.
simulated function IGPlus_SDCameraAt(float T, out vector Pos, out rotator View, out float Eye) {
	local int k, Idx, NewerIdx;
	local float Alpha;
	local int PA, PB, YA, YB;

	Pos = IGPlus_DemoPos;
	View.Pitch = DemoViewPitch & 0xFFFF;
	View.Yaw = DemoViewYaw & 0xFFFF;
	View.Roll = 0;
	Eye = IGPlus_DemoEye;

	NewerIdx = -1;
	for (k = 0; k < IGPlus_SDHistCount; k++) {
		Idx = IGPlus_SDHistHead - 1 - k;
		if (Idx < 0)
			Idx += IGPLUS_SD_HISTSIZE;
		if (IGPlus_SDHistTime[Idx] <= T) {
			Pos = IGPlus_SDHistPos[Idx];
			PA = IGPlus_SDHistView[Idx] >>> 16;
			YA = IGPlus_SDHistView[Idx] & 0xFFFF;
			Eye = IGPlus_SDHistEye[Idx];
			// Not across a jump (teleport, respawn).
			if (NewerIdx >= 0 && VSize(IGPlus_SDHistPos[NewerIdx] - IGPlus_SDHistPos[Idx]) < 256) {
				Alpha = FClamp((T - IGPlus_SDHistTime[Idx]) / FMax(IGPlus_SDHistTime[NewerIdx] - IGPlus_SDHistTime[Idx], 0.0001), 0.0, 1.0);
				Pos += (IGPlus_SDHistPos[NewerIdx] - IGPlus_SDHistPos[Idx]) * Alpha;
				Eye += (IGPlus_SDHistEye[NewerIdx] - Eye) * Alpha;
				PB = IGPlus_SDHistView[NewerIdx] >>> 16;
				YB = IGPlus_SDHistView[NewerIdx] & 0xFFFF;
				PA = (PA + int(float(((PB - PA + 32768) & 0xFFFF) - 32768) * Alpha)) & 0xFFFF;
				YA = (YA + int(float(((YB - YA + 32768) & 0xFFFF) - 32768) * Alpha)) & 0xFFFF;
			}
			View.Pitch = PA;
			View.Yaw = YA;
			return;
		}
		NewerIdx = Idx;
	}
	// Older than all we have: the oldest.
	if (NewerIdx >= 0) {
		Pos = IGPlus_SDHistPos[NewerIdx];
		View.Pitch = IGPlus_SDHistView[NewerIdx] >>> 16;
		View.Yaw = IGPlus_SDHistView[NewerIdx] & 0xFFFF;
		Eye = IGPlus_SDHistEye[NewerIdx];
	}
}

// The camera for this rendered frame (also used by our pulse beam).
simulated function IGPlus_SDCameraNow(out vector Pos, out rotator View, out float Eye) {
	local IGPlus_DemoClock C;

	C = IGPlus_SDGetClock();
	if (C != none)
		IGPlus_SDCameraAt(C.IGPlus_DisplayTime(), Pos, View, Eye);
	else
		IGPlus_SDCameraAt(1000000.0, Pos, View, Eye);
}

// Where our shots leave the gun, seen from the camera: the hand the gun is
// drawn with (the viewer's, hidden is the middle).
simulated function vector IGPlus_SDMuzzle(vector CamLoc, rotator View, Weapon W) {
	local vector X, Y, Z, Offset, DrawOffset;
	local float Hand;

	if (W == none)
		return CamLoc;
	Hand = Handedness;
	Offset = W.default.FireOffset;
	DrawOffset = W.default.PlayerViewOffset;
	if (Hand > 1.5) {
		Offset.Y = 0;
		DrawOffset.Y = 0;
	} else {
		Offset.Y *= Hand;
		DrawOffset.Y *= Hand;
	}
	GetAxes(View, X, Y, Z);
	return CamLoc + (DrawOffset >> View) + Offset.X * X + Offset.Y * Y + Offset.Z * Z;
}

// Our new projectiles: the server spawned them ahead along their path (half
// the ping plus the playout delay ahead of our camera), and the demo only
// has that copy. Each is drawn (PrePivot, collision unchanged) where it was
// that much earlier, so it leaves our gun as our client showed it. The delay
// eases to 0 over IGPLUS_SD_PROJEASE (a mild speed-up near the gun), so
// impacts, bounces and the smoke and light it leaves line up with it after
// that.
// bNetTemporary projectiles (pulse spheres) are simulated by the client alone
// once spawned, so they get what our client did live with its own copy: the
// server's one is moved to our gun once and flies on from there (its hits and
// explosion stay where it is drawn). Not shock balls: a combo explodes where
// the ball really is.
simulated function IGPlus_SDGlideOwnProjectiles(vector CamLoc, rotator View) {
	local Projectile P;
	local int i, Free, Base, Idx, k;
	local bool bKnown;
	local float Speed, Now, T, Alpha, Along, Age, D, NewerT;
	local vector NewerL;
	local vector Muzzle, Dir, Drawn;
	local Actor A;

	Now = Level.TimeSeconds;
	// Just started following us: what we fired before is left alone.
	if (IGPlus_SDGlideUpdateTime <= 0 || Now - IGPlus_SDGlideUpdateTime > 0.1)
		IGPlus_SDFollowStart = Now;
	IGPlus_SDGlideUpdateTime = Now;
	Muzzle = IGPlus_SDMuzzle(CamLoc, View, Weapon);

	foreach RadiusActors(class'Projectile', P, 800, CamLoc) {
		if (P.Instigator != self || P.bDeleteMe || P.Physics == PHYS_None
			|| ShockProj(P) != none || (P.DrawType != DT_Mesh && P.bNetTemporary == false)
			|| P.default.LifeSpan <= 0)
			continue;
		// Only new ones. Pulse spheres set their own LifeSpan of 2 on clients.
		Age = P.default.LifeSpan - P.LifeSpan;
		if (PlasmaSphere(P) != none)
			Age = 2.0 - P.LifeSpan;
		if (Age > 0.2 || Age > Now - IGPlus_SDFollowStart)
			continue;
		// A flak slug's blast chunks did not leave the gun.
		if (ST_UTChunk(P) != none && ST_UTChunk(P).IGPlus_bFromSlug)
			continue;
		Speed = VSize(P.Velocity);
		if (Speed < 1)
			continue;
		Dir = P.Velocity / Speed;
		// Only shots on their way out of the gun, at most a quarter second
		// ahead of it.
		Along = (P.Location - Muzzle) dot Dir;
		if (Along <= 0 || Along / Speed > 0.25 || (Dir dot vector(View)) < 0.7)
			continue;
		bKnown = false;
		Free = -1;
		for (i = 0; i < IGPLUS_SD_PROJ; i++) {
			if (IGPlus_SDProj[i] == P)
				bKnown = true;
			else if (Free < 0 && (IGPlus_SDProj[i] == none || IGPlus_SDProj[i].bDeleteMe))
				Free = i;
		}
		if (bKnown || Free < 0)
			continue;
		IGPlus_SDProj[Free] = P;
		IGPlus_SDProjStart[Free] = Now;
		IGPlus_SDProjDelay[Free] = Along / Speed;
		// Its start: back along its own path to the gun. That keeps the
		// weapon's own offset for this shot (pulse barrels turn, height).
		IGPlus_SDProjMuzzle[Free] = P.Location - Dir * Along;
		IGPlus_SDProjHead[Free] = 0;
		IGPlus_SDProjCount[Free] = 0;
		IGPlus_SDProjDrawType[Free] = P.DrawType;
		if (P.bNetTemporary) {
			// Kept in its slot (delay -1) so it is not moved back again.
			IGPlus_SDProjDelay[Free] = -1;
			IGPlus_SDHandOver(P, IGPlus_SDProjMuzzle[Free]);
		}
	}

	for (i = 0; i < IGPLUS_SD_PROJ; i++) {
		P = IGPlus_SDProj[i];
		if (P == none)
			continue;
		if (P.bDeleteMe) {
			IGPlus_SDEndGlide(i);
			continue;
		}
		// Handed over: flying on its own. Forgotten once it is too far out to
		// be taken again (more than a quarter second ahead of the gun).
		if (IGPlus_SDProjDelay[i] < 0) {
			if (Now - IGPlus_SDProjStart[i] > 0.5)
				IGPlus_SDProj[i] = none;
			continue;
		}
		Base = i * IGPLUS_SD_PROJHIST;
		// Its path, at most every 8 ms.
		Idx = IGPlus_SDProjHead[i] - 1;
		if (Idx < 0)
			Idx += IGPLUS_SD_PROJHIST;
		if (IGPlus_SDProjCount[i] == 0 || Now - IGPlus_SDProjHT[Base + Idx] >= 0.008) {
			IGPlus_SDProjHT[Base + IGPlus_SDProjHead[i]] = Now;
			IGPlus_SDProjHL[Base + IGPlus_SDProjHead[i]] = P.Location;
			IGPlus_SDProjHead[i]++;
			if (IGPlus_SDProjHead[i] >= IGPLUS_SD_PROJHIST)
				IGPlus_SDProjHead[i] = 0;
			IGPlus_SDProjCount[i] = Min(IGPlus_SDProjCount[i] + 1, IGPLUS_SD_PROJHIST);
		}
		// It exploded or stopped (a pulse sphere becomes its own explosion):
		// on its real spot.
		if (P.DrawType != IGPlus_SDProjDrawType[i] || P.Physics == PHYS_None) {
			IGPlus_SDEndGlide(i);
			continue;
		}
		// The delay eases out: on its real spot from then on.
		Age = Now - IGPlus_SDProjStart[i];
		D = IGPlus_SDProjDelay[i] * (1.0 - Age / IGPLUS_SD_PROJEASE);
		if (D <= 0) {
			IGPlus_SDEndGlide(i);
			continue;
		}

		T = Now - D;
		if (T <= IGPlus_SDProjStart[i]) {
			// Not out yet then: from the gun (where it was a full delay
			// before we first saw it) to where we first saw it.
			Alpha = FClamp((T - IGPlus_SDProjStart[i] + IGPlus_SDProjDelay[i]) / IGPlus_SDProjDelay[i], 0.0, 1.0);
			Drawn = IGPlus_SDProjMuzzle[i] + (IGPlus_SDProjHL[Base] - IGPlus_SDProjMuzzle[i]) * Alpha;
		} else {
			// Between two points of its path; the newest is where it is now.
			Drawn = P.Location;
			NewerT = Now;
			NewerL = P.Location;
			for (k = 0; k < IGPlus_SDProjCount[i]; k++) {
				Idx = IGPlus_SDProjHead[i] - 1 - k;
				if (Idx < 0)
					Idx += IGPLUS_SD_PROJHIST;
				Drawn = IGPlus_SDProjHL[Base + Idx];
				if (IGPlus_SDProjHT[Base + Idx] <= T) {
					Alpha = FClamp((T - IGPlus_SDProjHT[Base + Idx]) / FMax(NewerT - IGPlus_SDProjHT[Base + Idx], 0.0001), 0.0, 1.0);
					Drawn += (NewerL - Drawn) * Alpha;
					break;
				}
				NewerT = IGPlus_SDProjHT[Base + Idx];
				NewerL = IGPlus_SDProjHL[Base + Idx];
			}
		}
		P.PrePivot = P.default.PrePivot + Drawn - P.Location;
		// Its trails (rocket flare, flak glow) follow its real spot each
		// tick: put them on the drawn one for this frame.
		foreach P.ChildActors(class'Actor', A)
			if (A != P && A.Physics == PHYS_Trailer)
				A.SetLocation(Drawn);
	}
}

simulated function IGPlus_SDEndGlide(int i) {
	local Projectile P;

	P = IGPlus_SDProj[i];
	if (P != none && P.bDeleteMe == false)
		P.PrePivot = P.default.PrePivot;
	IGPlus_SDProj[i] = none;
}

// Moved to our gun once, the way our client handed its own copy over to the
// server's: no touching on the way, same speed and direction.
simulated function IGPlus_SDHandOver(Projectile P, vector Muzzle) {
	local bool bCA, bBA, bBP, bCW;

	bCA = P.bCollideActors;
	bBA = P.bBlockActors;
	bBP = P.bBlockPlayers;
	bCW = P.bCollideWorld;
	P.SetCollision(false, false, false);
	P.bCollideWorld = false;
	P.SetLocation(Muzzle);
	P.SetCollision(bCA, bBA, bBP);
	P.bCollideWorld = bCW;
}

// Not followed any more (or udemo stopped asking): back on their real spots.
simulated function IGPlus_SDEndAllGlides() {
	local int i;

	for (i = 0; i < IGPLUS_SD_PROJ; i++)
		if (IGPlus_SDProj[i] != none)
			IGPlus_SDEndGlide(i);
}

// A pulse beam traced from the followed player's camera hits the others where
// they are drawn (Player View: where the followed player saw them).
simulated function IGPlus_SDTraceOthersBegin() {
	local IGPlus_DemoClock C;
	local GameReplicationInfo GRI;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;
	local float T;
	local vector L;
	local byte bWasHidden;
	local int i;

	C = IGPlus_SDGetClock();
	GRI = IGPlus_SDGetGRI();
	if (C == none || GRI == none)
		return;
	T = C.IGPlus_DisplayTime() - 0.001 * float(IGPlus_DemoOthersDelayMs);
	for (i = 0; i < arraycount(GRI.PRIArray); i++) {
		PRI = GRI.PRIArray[i];
		if (PRI == none)
			break;
		P = bbPlayer(PRI.Owner);
		if (P == none || P == self || P.IGPlus_SDIsServerDemoProxy() == false || P.bHidden)
			continue;
		if (P.IGPlus_SDDisplaced)
			P.IGPlus_SDRestore();
		if (P.IGPlus_SDHistAt(T, L, bWasHidden) && bWasHidden == 0)
			P.IGPlus_SDTraceMove(L);
	}
}

simulated function IGPlus_SDTraceOthersEnd() {
	local GameReplicationInfo GRI;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;
	local int i;

	GRI = IGPlus_SDGetGRI();
	if (GRI == none)
		return;
	for (i = 0; i < arraycount(GRI.PRIArray); i++) {
		PRI = GRI.PRIArray[i];
		if (PRI == none)
			break;
		P = bbPlayer(PRI.Owner);
		if (P != none && P.IGPlus_SDTraceMoved)
			P.IGPlus_SDTraceMoveBack();
	}
}

// Moved for a trace only: no touching on the way, collision on while there.
simulated function IGPlus_SDTraceMove(vector L) {
	local bool bCA, bBA, bBP, bCW;

	bCA = bCollideActors;
	bBA = bBlockActors;
	bBP = bBlockPlayers;
	bCW = bCollideWorld;
	IGPlus_SDTraceSaved = Location;
	SetCollision(false, false, false);
	bCollideWorld = false;
	SetLocation(L);
	SetCollision(bCA, bBA, bBP);
	bCollideWorld = bCW;
	IGPlus_SDTraceMoved = true;
}

simulated function IGPlus_SDTraceMoveBack() {
	local bool bCA, bBA, bBP, bCW;

	bCA = bCollideActors;
	bBA = bBlockActors;
	bBP = bBlockPlayers;
	bCW = bCollideWorld;
	SetCollision(false, false, false);
	bCollideWorld = false;
	SetLocation(IGPlus_SDTraceSaved);
	SetCollision(bCA, bBA, bBP);
	bCollideWorld = bCW;
	IGPlus_SDTraceMoved = false;
}

// Where we are drawn for the player the viewer follows (Player View draws
// us where they saw us). False if we are drawn at our own Location.
simulated function bool IGPlus_SDDrawnLocation(out vector L) {
	local PlayerPawn V;
	local bbPlayer F;
	local IGPlus_DemoClock C;
	local byte bWasHidden;

	V = IGPlus_SDGetViewer();
	if (V == none)
		return false;
	F = bbPlayer(V.ViewTarget);
	if (F == none || F == self || F.IGPlus_SDIsServerDemoProxy() == false)
		return false;
	C = IGPlus_SDGetClock();
	if (C == none)
		return false;
	return IGPlus_SDHistAt(C.IGPlus_DisplayTime() - 0.001 * float(F.IGPlus_DemoOthersDelayMs), L, bWasHidden);
}

// udemo following us: the camera. udemo reads Location and EyeHeight after
// this, and copies DesiredFOV to the viewer.
simulated function IGPlus_SDCalcView(out rotator CameraRotation) {
	local vector TrueLoc, Pos;
	local rotator View;
	local float Eye;

	if (IGPlus_SDIsServerDemoProxy() == false)
		return;

	IGPlus_SDCameraNow(Pos, View, Eye);
	CameraRotation = View;

	TrueLoc = Location;
	if (IGPlus_SDDisplaced)
		TrueLoc = IGPlus_SDTrueLoc;
	if (VSize(Pos - TrueLoc) < 256)
		IGPlus_SDDisplace(Pos, false);

	EyeHeight = Eye;
	// Zoom (udemo copies it to the viewer). Not the player's normal FOV:
	// DesiredFOV != DefaultFOV here means zoomed to stock code (the weapon
	// hides, the sniper draws its scope).
	if (IGPlus_DemoZoomed && IGPlus_DemoFOV > 0)
		DesiredFOV = IGPlus_DemoFOV;
	else
		DesiredFOV = DefaultFOV;

	IGPlus_SDGlideOwnProjectiles(Pos + Eye * vect(0,0,1), View);

	IGPlus_SDDisplaceOthers();
}

// Before our weapon draws: muzzle flash from the server's FlashCount.
simulated function IGPlus_SDBeforeOverlays() {
	local Weapon W;

	W = Weapon;
	if (W == none)
		return;
	if (W != IGPlus_SDFlashWeapon) {
		IGPlus_SDFlashWeapon = W;
		IGPlus_SDLastFlashCount = W.FlashCount;
	} else if (W.FlashCount != IGPlus_SDLastFlashCount) {
		IGPlus_SDLastFlashCount = W.FlashCount;
		W.bMuzzleFlash = 1;
		W.bSetFlashTime = false;
	}
	if (W.bSteadyFlash3rd) {
		W.bMuzzleFlash = 1;
		W.bSetFlashTime = false;
	}
}

// After the world and our weapon are drawn (first person): hit feedback,
// then everyone back.
simulated function IGPlus_SDAfterOverlays(Canvas C) {
	local float DeltaTime;

	DeltaTime = FClamp((Level.TimeSeconds - IGPlus_SDLastOverlayTime) / FMax(Level.TimeDilation, 0.01), 0.0, 0.1);
	IGPlus_SDLastOverlayTime = Level.TimeSeconds;
	if (Settings != none) {
		class'bbPlayerStatics'.static.DrawHitMarker(C, Settings, DeltaTime);
		class'bbPlayerStatics'.static.DrawDamageNumbers(C, Settings, DeltaTime);
	}

	if (IGPlus_SDDisplacedOthers)
		IGPlus_SDRestoreOthers();
	IGPlus_SDRestore();
}

// A personal message to us (hit feedback), for a viewer following us.
simulated function IGPlus_SDPersonalMessage(
	class<LocalMessage> Message,
	int Sw,
	PlayerReplicationInfo RelatedPRI_1,
	PlayerReplicationInfo RelatedPRI_2,
	Object OptionalObject
) {
	local PlayerPawn V;
	local PlayerPawn Me;

	V = IGPlus_SDFollowingViewer();
	if (V == none || Message == none)
		return;

	if (Message == class'IGPlus_HitFeedbackMessage') {
		// Drawn in our RenderOverlays, with the viewer's hit marker settings.
		if (Settings == none || RelatedPRI_1 == none || RelatedPRI_2 == none
			|| RelatedPRI_1 == RelatedPRI_2 || RelatedPRI_2 != PlayerReplicationInfo)
			return;
		Me = self;
		if (GameReplicationInfo == none)
			Me = V;
		if (Me.GameReplicationInfo == none)
			return;
		class'bbPlayerStatics'.static.PlayHitMarker(Me, Settings, Abs(Sw), RelatedPRI_2.Team, RelatedPRI_1.Team);
		if (ShowDamageNumberMode == 2 || ShowDamageNumberMode == 3)
			class'bbPlayerStatics'.static.PlayDamageMarker(Me, Abs(Sw), RelatedPRI_2.Team, RelatedPRI_1.Team, RelatedPRI_1);
		class'bbPlayerStatics'.static.PlayHitSound(Me, Settings, Abs(Sw), RelatedPRI_2.Team, RelatedPRI_1.Team);
		return;
	}

	// What our ReceiveLocalizedMessage does: its death message also gives a
	// viewer following the killer or the victim their own lines.
	if (Message == class'Botpack.DeathMessagePlus')
		Message = class'IGPlus_DeathMessagePlus';
	V.ReceiveLocalizedMessage(Message, Sw, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

// Server demo record of WeaponEffect.Send (rocket scorch marks, the instagib
// rifle's beam and ring).
simulated function IGPlus_DemoWeaponEffect(
	class<WeaponEffect> Effect,
	PlayerReplicationInfo SourcePRI,
	vector SourceLocation,
	vector SourceOffset,
	Actor Target,
	vector TargetLocation,
	vector TargetOffset,
	vector HitNormal
) {
	local PlayerPawn V;
	local bbPlayer Shooter;
	local vector CamPos, NewStart;
	local rotator View;
	local float Eye;

	if (Role == ROLE_Authority || Level.NetMode != NM_Client || Effect == none)
		return;
	// Played as the viewer, so the effect's own-beam rules (Hide Own Beam)
	// look at who is watching, not at the player who carried the record.
	V = IGPlus_SDGetViewer();
	if (V == none)
		V = self;
	// Following the shooter in first person (the NewNet rifles' beam): start
	// it at the gun where the camera is, as on the shooter's client and as
	// ST_ShockBeamOwnerHidden does for the shock rifle.
	if (SourcePRI != none)
		Shooter = bbPlayer(SourcePRI.Owner);
	if (Shooter != none && Shooter.IGPlus_SDIsServerDemoProxy() && Shooter.IGPlus_SDFollowingViewer() != none) {
		Shooter.IGPlus_SDCameraNow(CamPos, View, Eye);
		NewStart = Shooter.IGPlus_SDMuzzle(CamPos + Eye * vect(0,0,1), View, Shooter.Weapon) + 20 * vector(View);
		if (VSize(NewStart - SourceLocation) <= 150) {
			SourceLocation = NewStart;
			SourceOffset = NewStart - class'WeaponEffect'.static.GetPlayerLocation(Shooter);
		}
	}
	Effect.static.Play(
		V,
		Settings,
		SourcePRI,
		SourceLocation,
		SourceOffset,
		Target,
		TargetLocation,
		TargetOffset,
		Normal(HitNormal / 32767));
}

simulated function bool IGPlus_ShowRealModelsInDemo() {
	return IGPlus_InDemoPlayback() && IGPlus_IsDemoPlayback && Settings != none && Settings.bDemoShowRealModels;
}

// Client demos record the recording player's forced skins.
// The real skin is still replicated through bbPlayerReplicationInfo, so put it back.
// Runs every tick because the demo re-sends forced skins whenever they change.
simulated function IGPlus_DemoRestoreRealModel() {
	local bbPlayerReplicationInfo PRI;
	local string Key;
	local int i;

	PRI = bbPlayerReplicationInfo(PlayerReplicationInfo);
	if (PRI == none || PRI.SkinName == "")
		return;

	// No mesh: the server hid this player (waiting or spectating in warmup,
	// PlayerWaiting sets Mesh None). Giving it one back drew a body there.
	if (Mesh == none)
		return;

	if (default.Mesh != none && Mesh != default.Mesh)
		Mesh = default.Mesh;

	Key = PRI.SkinName$"/"$PRI.FaceName$"/"$PRI.Team;
	if (Key == IGPlus_DemoRealSkinKey) {
		for (i = 0; i < arraycount(MultiSkins); i++)
			if (MultiSkins[i] != IGPlus_DemoRealMultiSkins[i])
				break;
		if (i == arraycount(MultiSkins))
			return;
	}

	SetMultiSkin(self, PRI.SkinName, PRI.FaceName, PRI.Team);
	IGPlus_DemoRealSkinKey = Key;
	for (i = 0; i < arraycount(MultiSkins); i++)
		IGPlus_DemoRealMultiSkins[i] = MultiSkins[i];
}

simulated function xxGetDemoPlaybackSpec()
{
	local Pawn P;

	if (zzbGotDemoPlaybackSpec)
		return;
	zzbGotDemoPlaybackSpec = true;

	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
		if (Caps(string(P.Class.Name)) == "DEMOPLAYBACKSPEC")
			zzDemoPlaybackSpec = CHSpectator(P);

	if (zzDemoPlaybackSpec != None)
		zzDemoPlaybackSN = zzDemoPlaybackSpec.Spawn(class'bbClientDemoSN', zzDemoPlaybackSpec);

}

simulated function xxClientDemoFix(Actor zzA, class<Actor> C, Vector L, optional Vector V, optional vector A, optional Rotator R, optional float DS, optional Actor S, optional Vector MoveAmount, optional int NumPuffs)
{
    xxGetDemoPlaybackSpec();
    if (zzDemoPlaybackSpec == none)
        return;

    if (zzA == None)
    {
        zzDemoPlaybackSN.xxFixActor(C, L, V, A, R, DS, S, MoveAmount, NumPuffs);
        return;
    }

    zzA.Velocity = V;
    zzA.Acceleration = A;
    zzA.SetRotation(R);
    if(DS != 0)
        zzA.DrawScale = DS;
    if((S != none) && UT_SeekingRocket(zzA) != none)
        UT_SeekingRocket(zzA).Seeking = S;
    if(ShockBeam(zzA) != none && MoveAmount != vect(0,0,0))
    {
        ShockBeam(zzA).MoveAmount = MoveAmount;
        if(NumPuffs > 0)
            ShockBeam(zzA).NumPuffs = NumPuffs;
    }
}

// Recording a client demo: put our own client-side copy A in it
// (IGPlus_DemoCopy). Call once A is set up.
simulated function IGPlus_DemoTrack(Actor A) {
	local int i;

	if (A == None || zzbDemoRecording == false || Level.NetMode != NM_Client)
		return;
	for (i = 0; i < arraycount(IGPlus_DemoCopy); i++) {
		if (IGPlus_DemoCopyOn[i] != 0)
			continue;
		IGPlus_DemoCopy[i] = A;
		IGPlus_DemoCopyOn[i] = 1;
		IGPlus_DemoCopies++;
		IGPlus_DemoCopyBegin(i, A.Class, A.Location, A.Rotation, A.Velocity, A.DrawScale);
		return;
	}
	// ponytail: 32 in flight at once, more than any weapon fires in a round trip
}

// Recording: a sound our tracked copy A played. The demo has no channel for
// A, so the sound would be lost.
simulated function IGPlus_DemoTrackSound(Actor A, sound S, float Volume, float Radius, float Pitch) {
	local int i;

	for (i = 0; i < arraycount(IGPlus_DemoCopy); i++)
		if (IGPlus_DemoCopyOn[i] != 0 && IGPlus_DemoCopy[i] == A) {
			IGPlus_DemoCopySound(i, S, Volume, Radius, Pitch);
			return;
		}
}

// Recording: every frame, where each of ours is now, or that it is gone.
simulated function IGPlus_DemoCopiesTick() {
	local int i;
	local Actor A;

	for (i = 0; i < arraycount(IGPlus_DemoCopy); i++) {
		if (IGPlus_DemoCopyOn[i] == 0)
			continue;
		A = IGPlus_DemoCopy[i];
		if (A == None || A.bDeleteMe || zzbDemoRecording == false) {
			IGPlus_DemoCopy[i] = None;
			IGPlus_DemoCopyOn[i] = 0;
			IGPlus_DemoCopies--;
			if (zzbDemoRecording)
				IGPlus_DemoCopyEnd(i);
		} else {
			IGPlus_DemoCopyMove(i, A.Location, A.Velocity, A.Rotation, A.bHidden);
		}
	}
}

// The IGPlus_DemoCopy* calls below go into the demo and also run on the
// recording client, where they must do nothing. In playback the recorded
// player has no viewport, except under udemo, which gives it a stand-in one.
simulated function bool IGPlus_DemoCopySlot(int Slot) {
	return Level.NetMode == NM_Client
		&& (IGPlus_InDemoPlayback() || Viewport(Player) == None)
		&& Slot >= 0 && Slot < arraycount(IGPlus_DemoCopy);
}

// Playback: a copy that only shows, flying where ours was until removed.
// Nothing touches it, so none of its hit code runs.
simulated function IGPlus_DemoCopyBegin(int Slot, class<Actor> C, vector Loc, rotator Rot, vector Vel, float DS) {
	local Actor A;

	if (IGPlus_DemoCopySlot(Slot) == false || C == None)
		return;
	IGPlus_DemoCopyKill(IGPlus_DemoCopy[Slot]);
	A = Spawn(C,,, Loc, Rot);
	IGPlus_DemoCopy[Slot] = A;
	if (A == None)
		return;
	A.RemoteRole = ROLE_None;
	A.SetPropertyText("bClientVisualOnly", "True");
	A.SetCollision(false, false, false);
	A.bCollideWorld = false;
	// Only where ours was, frame by frame: on its own it ran ahead between
	// demo frames and was pulled back at each one (jitter).
	A.SetPhysics(PHYS_None);
	A.Velocity = Vel;
	A.DrawScale = DS;
}

simulated function IGPlus_DemoCopyMove(int Slot, vector Loc, vector Vel, rotator Rot, bool bHide) {
	local Actor A;

	if (IGPlus_DemoCopySlot(Slot) == false)
		return;
	A = IGPlus_DemoCopy[Slot];
	if (A == None || A.bDeleteMe)
		return;
	A.SetLocation(Loc);
	A.Velocity = Vel;
	A.SetRotation(Rot);
	if (A.bHidden != bHide) {
		A.bHidden = bHide;
		if (bHide)
			A.LightType = LT_None;
		else
			A.LightType = A.default.LightType;
	}
}

simulated function IGPlus_DemoCopyEnd(int Slot) {
	if (IGPlus_DemoCopySlot(Slot) == false)
		return;
	IGPlus_DemoCopyKill(IGPlus_DemoCopy[Slot]);
	IGPlus_DemoCopy[Slot] = None;
}

// Playback: remove a copy with what it spawned on itself (a flak chunk's
// glow trail is its own actor and would stay behind, glowing like a hit),
// as the live hand-over does.
simulated function IGPlus_DemoCopyKill(Actor A) {
	local Actor E;

	if (A == None || A.bDeleteMe)
		return;
	// ChildActors lists A itself too: destroying A first would orphan the rest.
	foreach A.ChildActors(class'Actor', E)
		if (E != A)
			E.Destroy();
	A.Destroy();
}

simulated function IGPlus_DemoCopySound(int Slot, sound S, float Volume, float Radius, float Pitch) {
	if (IGPlus_DemoCopySlot(Slot) && IGPlus_DemoCopy[Slot] != None)
		IGPlus_DemoCopy[Slot].PlaySound(S,, Volume,, Radius, Pitch);
}

function string xxFindClanTags() {
	local PlayerReplicationInfo PRI;
	local string PrefixTags[4];
	local string SuffixTags[4];
	local string Tags[4];
	local int TeamSize[4];
	local int MaxTeams;
	local int Team;
	local int MixCount;
	local string Result;

	if (GameReplicationInfo.bTeamGame == false)
		return "FFA";

	foreach AllActors(class'PlayerReplicationInfo', PRI) {
		if (PRI.bIsSpectator == true || PRI.bIsABot == true)
			continue;

		if (TeamSize[PRI.Team] == 0) {
			PrefixTags[PRI.Team] = PRI.PlayerName;
			SuffixTags[PRI.Team] = PRI.PlayerName;
		} else {
			PrefixTags[PRI.Team] = class'StringUtils'.static.CommonPrefix(PrefixTags[PRI.Team], PRI.PlayerName);
			SuffixTags[PRI.Team] = class'StringUtils'.static.CommonSuffix(SuffixTags[PRI.Team], PRI.PlayerName);
		}

		++TeamSize[PRI.Team];
	}

	for (MaxTeams = 0; MaxTeams < 4; ++MaxTeams)
		if (TeamSize[MaxTeams] == 0)
			break;

	for (Team = 0; Team < MaxTeams; ++Team) {
		Tags[Team] = class'StringUtils'.static.MergeAffixes(PrefixTags[Team], SuffixTags[Team]);
		if (Len(Tags[Team]) == 0) {
			Tags[Team] = "Mix";
			++MixCount;
		}
	}

	if (MaxTeams <= 1 || MixCount > 1)
		return "Unknown";

	Result = Tags[0];
	for (Team = 1; Team < MaxTeams; ++Team)
		Result = Result$"_"$Tags[Team];

	return xxFixFileName(Result, Settings.DemoChar);
}


function string xxFixFileName(string zzS, string zzReplaceChar)
{
	local int zzx;
	local string zzs2,zzs3;

	zzs3 = "";
	for (zzx = 0; zzx < Len(zzS); zzx++)
	{
		zzs2 = Mid(zzS,zzx,1);
		if (asc(zzs2) < 32 || asc(zzs2) > 128)
			zzs2 = zzReplaceChar;
		else
		{
			switch(zzs2)
			{
				Case "|":
				Case ".":
				Case ":":
				Case "%":
				Case "\\":
				Case "/":
				Case "*":
				Case "?":
				Case ">":
				Case "<":
				Case "(":	//
				Case ")":	//
				Case "`":	//
				Case "'":	//
				Case "�":	//
				Case "&":	// Weak Linux, Weak
				Case " ":	zzs2 = zzReplaceChar;
						break;
			}
		}
		zzs3 = zzs3$zzs2;
	}
	return zzs3;
}

function string PadNumberToTwoDigits(int Val) {
	if (Val < 10)
		return "0"$string(Val);
	else
		return string(Val);
}

function string xxCreateDemoName(string zzDemoName)
{
	local int zzx;
	local string zzS;
	local string result;

	if (zzDemoName == "")
		zzDemoName = "%l_[%y_%m_%d_%t]_[%c]_%e";	// Incase admin messes up :/

	while(true) {
		zzx = InStr(zzDemoName, "%");
		if (zzx < 0) break;

		zzS = Mid(zzDemoName,zzx+1,1);
		switch(Caps(zzS)) {
			case "E":
				zzS = string(Level);
				zzS = Left(zzS,InStr(zzS,"."));
				break;
			case "F":
				zzS = Level.Title;
				break;
			case "D":
				zzS = PadNumberToTwoDigits(Level.Day);
				break;
			case "M":
				zzS = PadNumberToTwoDigits(Level.Month);
				break;
			case "Y":
				zzS = string(Level.Year);
				break;
			case "H":
				zzS = PadNumberToTwoDigits(Level.Hour);
				break;
			case "N":
				zzS = PadNumberToTwoDigits(Level.Minute);
				break;
			case "T":
				zzS = PadNumberToTwoDigits(Level.Hour) $ PadNumberToTwoDigits(Level.Minute);
				break;
			case "C":	// Try to find 2 unique tags within the 2 teams. If only 2 players exists, add their names.
				zzS = xxFindClanTags();
				break;
			case "L":
				zzS = PlayerReplicationInfo.PlayerName;
				break;
			case "%":
				break;
			default:
				zzS = "%"$zzS;
				break;
		}
		result = result $ Left(zzDemoName, zzx) $ zzS;
		zzDemoName = Mid(zzDemoName, zzx + 2);
	}

	return Settings.DemoPath $ xxFixFileName(result $ zzDemoName, Settings.DemoChar);
}

exec function AutoDemo(bool zzb)
{
	if (IGPlus_RefuseForced("bAutoDemo", "auto demo"))
		return;
	Settings.bAutoDemo = zzb;
	ClientMessage("Record demos automatically after countdown:"@zzb);
	IGPlus_SaveSettings();
}

exec function ShootDead()
{
	if (IGPlus_RefuseForced("bShootDead", "shoot dead"))
		return;
	Settings.bShootDead = !Settings.bShootDead;
	if (Settings.bShootDead)
		ClientMessage("Shooting carcasses enabled.");
	else
		ClientMessage("Shooting carcasses disabled.");
	IGPlus_SaveSettings();
}

exec function SetDemoMask(optional string zzMask)
{
	if (IGPlus_RefuseForced("DemoMask", "demo mask"))
		return;
	if (zzMask != "")
	{
		Settings.DemoMask = zzMask;
		IGPlus_SaveSettings();
	}

	ClientMessage("Current demo mask:"@Settings.DemoMask);
}

exec function DemoStart()
{
	if (zzbDemoRecording)
	{
		ClientMessage("Already recording!");
		return;
	}

	xxClientDemoRec();
}

simulated function xxClientDemoRec()
{
	local string zzS;

	if (bDemoStarted) return;
	bDemoStarted = true;
	zzS = ConsoleCommand("DemoRec"@xxCreateDemoName(Settings.DemoMask));
	ClientMessage(zzS);
	if (zzbForceDemo)
		xxServerDemoReply(zzS);
}

function xxSetNetUpdateRate(float NewVal, int netspeed) {
	local float max;
	max = FMin(zzUTPure.Settings.MaxNetUpdateRate, netspeed/100.0);
	TimeBetweenNetUpdates = 1.0 / FClamp(NewVal, zzUTPure.Settings.MinNetUpdateRate, max);
}

exec function SetNetUpdateRate(float NewVal) {
	if (IGPlus_RefuseForced("DesiredNetUpdateRate", "net update rate"))
		return;
	Settings.DesiredNetUpdateRate = NewVal;
	xxSetNetUpdateRate(NewVal, Player.CurrentNetSpeed);
	IGPlus_SaveSettings();
}

function xxServerDemoReply(string zzS)
{
	zzUTPure.xxLog("Forced Demo:"@PlayerReplicationInfo.PlayerName@zzS);
}

function xxExplodeOther(Projectile Other)
{
	if (Other != None)
		Other.Explode(Other.Location, Normal(Location-Other.Location));
}

exec function DropFlag() {
	local Decoration Flag;
	if (PlayerReplicationInfo.HasFlag != none) {
		Flag = PlayerReplicationInfo.HasFlag;
		Flag.Drop(Velocity + 10 * VRand());
		Flag.SetLocation(Location + Normal(Velocity) * -60.0);
	}
}

function DoJump( optional float F )
{
	local UT_JumpBoots zzBoots;

	if ( CarriedDecoration != None )
		return;

	if (Level.NetMode == NM_Client)
	{
		zzBoots = UT_JumpBoots(FindInventoryType(class'UT_JumpBoots'));
		if (zzBoots != None && zzBoots.Charge <= 0)
			JumpZ = Default.JumpZ;
	}

	if ( !bIsCrouching && (Physics == PHYS_Walking) )
	{
		if ( !bUpdating )
			PlayOwnedSound(JumpSound, SLOT_None, 1.5, true, 1200, 1.0 );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);
		PlayInAir();
		if ( bCountJumps && (Role == ROLE_Authority) && (Inventory != None) )
			Inventory.OwnerJumped();
		if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != Level) && (Base != None) )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);
		IGPlus_MoveDebug("Jump done");
	}
	else
		IGPlus_MoveDebug("Jump refused");
}

function PlayInAir() {
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	if (ClientWeaponSettingsData.bReduceEyeHeightInAir)
		BaseEyeHeight = 0.7 * default.BaseEyeHeight;
	else
		BaseEyeHeight = default.BaseEyeHeight;

	if ( (GetAnimGroup(AnimSequence) == 'Landing') && !bLastJumpAlt )
	{
		GetAxes(Rotation, X,Y,Z);
		Dir = Normal(Acceleration);
		f = Dir dot Y;
		if ( f > 0.7 )
			TweenAnim('DodgeL', 0.35);
		else if ( f < -0.7 )
			TweenAnim('DodgeR', 0.35);
		else if ( Dir dot X > 0 )
			TweenAnim('DodgeF', 0.35);
		else
			TweenAnim('DodgeB', 0.35);
		bLastJumpAlt = true;
		return;
	}
	bLastJumpAlt = false;
	if ( GetAnimGroup(AnimSequence) == 'Jumping' )
	{
		if ( (Weapon == None) || (Weapon.Mass < 20) )
			TweenAnim('DuckWlkS', 2);
		else
			TweenAnim('DuckWlkL', 2);
		return;
	}
	else if ( GetAnimGroup(AnimSequence) == 'Ducking' )
		TweenTime = 2;
	else
		TweenTime = 0.7;

	if ( AnimSequence == 'StrafeL' )
		TweenAnim('DodgeR', TweenTime);
	else if ( AnimSequence == 'StrafeR' )
		TweenAnim('DodgeL', TweenTime);
	else if ( AnimSequence == 'BackRun' )
		TweenAnim('DodgeB', TweenTime);
	else if ( (Weapon == None) || (Weapon.Mass < 20) )
		TweenAnim('JumpSMFR', TweenTime);
	else
		TweenAnim('JumpLGFR', TweenTime);
}

function PlaySpawn() {
	local name NextSeq;

	if (Mesh == none) return;

	BaseEyeHeight = Default.BaseEyeHeight;

	if ((Weapon == None) || (Weapon.Mass < 20)) {
		NextSeq = 'Breath1';
	} else {
		NextSeq = 'Breath1L';
	}
	PlayAnim(NextSeq, 0.6);
}

exec function ShowOwnBeam() {
	if (IGPlus_RefuseForced("bHideOwnBeam", "own beam"))
		return;
	Settings.bHideOwnBeam = !Settings.bHideOwnBeam;
	IGPlus_SaveSettings();
	if (Settings.bHideOwnBeam)
		ClientMessage("Own beam hidden!", 'IGPlus');
	else
		ClientMessage("Own beam shown!", 'IGPlus');
}

function ClientShake(vector shake) {
	if (Settings.bAllowWeaponShake)
		super.ClientShake(shake);
}

// Server demo playback: the server's personal calls to this player are in the
// demo. Simulated so they run there, and passed to a viewer following us.
simulated function ClientFlash(float Scale, vector Fog) {
	local PlayerPawn V;

	if (Role == ROLE_SimulatedProxy) {
		if (IGPlus_SDIsServerDemoProxy()) {
			V = IGPlus_SDFollowingViewer();
			if (V != none)
				V.ClientFlash(Scale, Fog);
		}
		return;
	}
	super.ClientFlash(Scale, Fog);
}

simulated function ClientInstantFlash(float Scale, vector Fog) {
	local PlayerPawn V;

	if (Role == ROLE_SimulatedProxy) {
		if (IGPlus_SDIsServerDemoProxy()) {
			V = IGPlus_SDFollowingViewer();
			if (V != none)
				V.ClientInstantFlash(Scale, Fog);
		}
		return;
	}
	super.ClientInstantFlash(Scale, Fog);
}

function string GetReadyMessage() {
	if (Level.Game.IsA('DeathMatchPlus'))
		return DeathMatchPlus(Level.Game).ReadyMessage;

	return class'DeathMatchPlus'.default.ReadyMessage;
}

function string GetNotReadyMessage() {
	if (Level.Game.IsA('DeathMatchPlus'))
		return DeathMatchPlus(Level.Game).NotReadyMessage;

	return class'DeathMatchPlus'.default.NotReadyMessage;
}

exec function Ready() {
	bReadyToPlay = !bReadyToPlay;
	if (bReadyToPlay)
		ClientMessage(GetReadyMessage());
	else
		ClientMessage(GetNotReadyMessage());
}

exec function TestHitMarker(optional int Dmg) {
	HitMarkerTestDamage = Dmg;
}

exec function TestHitSound(optional int Dmg) {
	class'bbPlayerStatics'.static.PlayHitSound(self, Settings, Dmg, PlayerReplicationInfo.Team, HitMarkerTestTeam);
	HitMarkerTestTeam += 1;
	if (HitMarkerTestTeam >= 4)
		HitMarkerTestTeam = 0;
}

exec function ZoomToggle(float SensitivityX, optional float SensitivityY) {
	if (IGPlus_ZoomToggle_RestoreFOV != 0) {
		DefaultFOV = IGPlus_ZoomToggle_RestoreFOV;
		DesiredFOV = DefaultFOV;
		IGPlus_ZoomToggle_RestoreFOV = 0;
		IGPlus_ZoomToggle_SensitivityFactorX = 1.0;
		IGPlus_ZoomToggle_SensitivityFactorY = 1.0;
	} else {
		IGPlus_ZoomToggle_RestoreFOV = DefaultFOV;
		DefaultFOV = 80;
		DesiredFOV = DefaultFOV;

		IGPlus_ZoomToggle_SensitivityFactorX = SensitivityX * IGPlus_ZoomToggle_RestoreFOV/DefaultFOV;
		if (SensitivityY == 0)
			IGPlus_ZoomToggle_SensitivityFactorY = IGPlus_ZoomToggle_SensitivityFactorX;
		else
			IGPlus_ZoomToggle_SensitivityFactorY = SensitivityY * IGPlus_ZoomToggle_RestoreFOV/DefaultFOV;
	}
}

exec function IGPlus_FOV(float NewFov) {
	local ENetRole Saved;
	local float FovLimit;
	if( (NewFov >= 80.0) || Level.bAllowFOV || bAdmin || (Level.Netmode==NM_Standalone) )
	{
		Saved = Role;
		Role = ROLE_Authority;
		FovLimit = float(GetPropertyText("MaxFOV"));
		FovLimit = FClamp(FovLimit, 130.0, 360.0);
		SetPropertyText("MaxFOV", string(FovLimit));
		Role = Saved;
		
		DefaultFOV = FClamp(NewFov, 80.0, FovLimit);
		DesiredFOV = DefaultFOV;
	}
}

exec function IGPlusMenu() {
	local WindowConsole C;

	if (Player != none)
		C = WindowConsole(Player.Console);

	if (C == none) {
		ClientMessage("Failed to create Settings window (Console not a WindowConsole)");
		return;
	}

	if (C.IsInState('Typing')) {
		IGPlus_TryOpenSettingsMenu = true; // delay until processing of this command is over
	} else if (C.bShowConsole) {
		// console is already open, no need to do anything
	} else {
		// probably a hotkey that called this function
		C.bQuickKeyEnable = True;
		C.LaunchUWindow();
	}

	IGPlus_OpenSettingsMenu();
}

function IGPlus_OpenSettingsMenu() {
	local WindowConsole C;

	if (Player != none)
		C = WindowConsole(Player.Console);

	if (C == none) {
		ClientMessage("Failed to create Settings window (Console not a WindowConsole)");
		return;
	}

	if (IGPlus_SettingsMenu == none) {
		if (C.Root == none) {
			ClientMessage("Failed to create Settings window (Root does not exist)");
			return;
		}

		IGPlus_SettingsMenu = IGPlus_SettingsDialog(C.Root.CreateWindow(
			class'IGPlus_SettingsDialog',
			Settings.MenuX,
			Settings.MenuY,
			Settings.MenuWidth,
			Settings.MenuHeight
		));

		if (IGPlus_SettingsMenu == none) {
			ClientMessage("Failed to create Settings window (Could not create Dialog)");
			return;
		}
	}

	IGPlus_SettingsMenu.bLeaveOnscreen = true;
	IGPlus_SettingsMenu.ShowWindow();
	IGPlus_SettingsMenu.Load();
}

exec function PrintWeaponState() {
	if (Weapon != none) ClientMessage(Weapon.Name@Weapon.GetStateName());
}

exec function SnapInterpDebug() {
	IGPlus_SnapInterp_NetDebug = !IGPlus_SnapInterp_NetDebug;
	IGPlus_SnapInterp_NetDebugNextTime = 0;

	if (IGPlus_SnapInterp_NetDebug)
		ClientMessage("SnapInterp debug enabled (client report + server echo + proxy status)");
	else
		ClientMessage("SnapInterp debug disabled");
}

simulated function bbPlayer IGPlus_SnapInterp_FindTarget(optional string TargetFilter) {
	local int i;
	local PlayerReplicationInfo PRI;
	local bbPlayer P;
	local bbPlayer Target;
	local string FilterCaps;

	if (TargetFilter != "")
		FilterCaps = Caps(TargetFilter);

	P = bbPlayer(ViewTarget);
	if (P != none &&
		P.Role == ROLE_SimulatedProxy &&
		(FilterCaps == "" || (P.PlayerReplicationInfo != none && InStr(Caps(P.PlayerReplicationInfo.PlayerName), FilterCaps) >= 0))
		) {
		Target = P;
	}

	if (Target == none && GameReplicationInfo != None && PlayerReplicationInfo != None) {
		for (i = 0; i < arraycount(GameReplicationInfo.PRIArray); ++i) {
			PRI = GameReplicationInfo.PRIArray[i];
			if (PRI == none)
				break;
			P = bbPlayer(PRI.Owner);
			if (P == none)
				continue;
			if (P == self)
				continue;
			if (P.Role != ROLE_SimulatedProxy)
				continue;
			if (FilterCaps != "" && (P.PlayerReplicationInfo == none || InStr(Caps(P.PlayerReplicationInfo.PlayerName), FilterCaps) < 0))
				continue;
			Target = P;
			break;
		}
	}

	return Target;
}

simulated function string IGPlus_SnapInterp_NormalizeCheckProfile(optional string Profile) {
	if (Profile ~= "lossy" || Profile ~= "loss" || Profile ~= "jitter")
		return "lossy";

	return "clean";
}

simulated function IGPlus_SnapInterp_GetCheckThresholds(
	string Profile,
	out float MinInterpPct,
	out float MaxExtrapPct,
	out float MaxClampPct,
	out float MaxFailPct,
	out float MaxHardSnapPerMin
) {
	if (Profile ~= "lossy") {
		MinInterpPct = 80.0;
		MaxExtrapPct = 15.0;
		MaxClampPct = 10.0;
		MaxFailPct = 2.0;
		MaxHardSnapPerMin = 3.0;
	} else {
		MinInterpPct = 95.0;
		MaxExtrapPct = 4.0;
		MaxClampPct = 3.0;
		MaxFailPct = 0.5;
		MaxHardSnapPerMin = 1.0;
	}
}

simulated function IGPlus_SnapInterp_FinishCheck(bool bStopped) {
	local bbPlayer Target;
	local string TargetName;
	local float DurationSec;
	local int DeltaSnapPackets;
	local int DeltaInterp;
	local int DeltaExtrap;
	local int DeltaClamp;
	local int DeltaFail;
	local int DeltaHardSnap;
	local int TotalModes;
	local float InterpPct;
	local float ExtrapPct;
	local float ClampPct;
	local float FailPct;
	local float HardSnapPerMin;
	local float MinInterpPct;
	local float MaxExtrapPct;
	local float MaxClampPct;
	local float MaxFailPct;
	local float MaxHardSnapPerMin;
	local bool bPass;
	local string FailReasons;

	if (IGPlus_SnapInterp_CheckActive == false)
		return;

	IGPlus_SnapInterp_CheckActive = false;
	Target = IGPlus_SnapInterp_CheckTarget;

	if (bStopped) {
		ClientMessage("SnapInterpCheck stopped");
		return;
	}

	if (Target == none || Target.bDeleteMe) {
		ClientMessage("SnapInterpCheck aborted: target unavailable");
		return;
	}

	TargetName = "Unknown";
	if (Target.PlayerReplicationInfo != none)
		TargetName = Target.PlayerReplicationInfo.PlayerName;

	DurationSec = FMax(IGPlus_SnapInterp_CheckDuration, 0.001);
	DeltaSnapPackets = Max(0, Target.IGPlus_SnapInterp_StatSnapPackets - IGPlus_SnapInterp_CheckBaseSnapPackets);
	DeltaInterp = Max(0, Target.IGPlus_SnapInterp_StatInterp - IGPlus_SnapInterp_CheckBaseInterp);
	DeltaExtrap = Max(0, Target.IGPlus_SnapInterp_StatExtrap - IGPlus_SnapInterp_CheckBaseExtrap);
	DeltaClamp = Max(0, Target.IGPlus_SnapInterp_StatClamp - IGPlus_SnapInterp_CheckBaseClamp);
	DeltaFail = Max(0, Target.IGPlus_SnapInterp_StatFail - IGPlus_SnapInterp_CheckBaseFail);
	DeltaHardSnap = Max(0, Target.IGPlus_SnapInterp_StatHardSnap - IGPlus_SnapInterp_CheckBaseHardSnap);
	TotalModes = DeltaInterp + DeltaExtrap + DeltaClamp + DeltaFail;

	if (TotalModes > 0) {
		InterpPct = 100.0 * float(DeltaInterp) / float(TotalModes);
		ExtrapPct = 100.0 * float(DeltaExtrap) / float(TotalModes);
		ClampPct = 100.0 * float(DeltaClamp) / float(TotalModes);
		FailPct = 100.0 * float(DeltaFail) / float(TotalModes);
	} else {
		InterpPct = 0.0;
		ExtrapPct = 0.0;
		ClampPct = 0.0;
		FailPct = 0.0;
	}

	HardSnapPerMin = 60.0 * float(DeltaHardSnap) / DurationSec;
	IGPlus_SnapInterp_GetCheckThresholds(
		IGPlus_SnapInterp_CheckProfile,
		MinInterpPct,
		MaxExtrapPct,
		MaxClampPct,
		MaxFailPct,
		MaxHardSnapPerMin
	);

	bPass = true;
	if (DeltaSnapPackets <= 0 || TotalModes <= 0) {
		bPass = false;
		FailReasons = "no_samples";
	}
	if (InterpPct < MinInterpPct) {
		bPass = false;
		if (FailReasons != "")
			FailReasons = FailReasons$",";
		FailReasons = FailReasons$"interp";
	}
	if (ExtrapPct > MaxExtrapPct) {
		bPass = false;
		if (FailReasons != "")
			FailReasons = FailReasons$",";
		FailReasons = FailReasons$"extrap";
	}
	if (ClampPct > MaxClampPct) {
		bPass = false;
		if (FailReasons != "")
			FailReasons = FailReasons$",";
		FailReasons = FailReasons$"clamp";
	}
	if (FailPct > MaxFailPct) {
		bPass = false;
		if (FailReasons != "")
			FailReasons = FailReasons$",";
		FailReasons = FailReasons$"fail";
	}
	if (HardSnapPerMin > MaxHardSnapPerMin) {
		bPass = false;
		if (FailReasons != "")
			FailReasons = FailReasons$",";
		FailReasons = FailReasons$"hardsnap";
	}

	ClientMessage(
		"SnapInterpCheck result target="$TargetName$
		" profile="$IGPlus_SnapInterp_CheckProfile$
		" durS="$int(DurationSec + 0.5)$
		" packets="$DeltaSnapPackets$
		" interpPct="$int(InterpPct + 0.5)$
		" extrapPct="$int(ExtrapPct + 0.5)$
		" clampPct="$int(ClampPct + 0.5)$
		" failPct="$int(FailPct + 0.5)$
		" hardPerMin="$int(HardSnapPerMin + 0.5)$
		" pass="$bPass
	);
	if (bPass == false)
		ClientMessage("SnapInterpCheck thresholds failed: "$FailReasons);
}

exec simulated function SnapInterpCheck(optional string Profile, optional float DurationSeconds, optional string TargetFilter) {
	local bbPlayer Target;
	local string TargetName;

	if (DurationSeconds <= 0.0)
		DurationSeconds = 30.0;
	DurationSeconds = FClamp(DurationSeconds, 5.0, 180.0);
	Profile = IGPlus_SnapInterp_NormalizeCheckProfile(Profile);

	Target = IGPlus_SnapInterp_FindTarget(TargetFilter);
	if (Target == none) {
		ClientMessage("SnapInterpCheck: no simulated proxy target found");
		return;
	}

	if (Target.PlayerReplicationInfo != none)
		TargetName = Target.PlayerReplicationInfo.PlayerName;
	else
		TargetName = "Unknown";

	if (IGPlus_SnapInterp_CheckActive)
		IGPlus_SnapInterp_FinishCheck(true);

	IGPlus_SnapInterp_CheckActive = true;
	IGPlus_SnapInterp_CheckDuration = DurationSeconds;
	IGPlus_SnapInterp_CheckEndTime = Level.TimeSeconds + DurationSeconds;
	IGPlus_SnapInterp_CheckProfile = Profile;
	IGPlus_SnapInterp_CheckTarget = Target;
	IGPlus_SnapInterp_CheckBaseSnapPackets = Target.IGPlus_SnapInterp_StatSnapPackets;
	IGPlus_SnapInterp_CheckBaseInterp = Target.IGPlus_SnapInterp_StatInterp;
	IGPlus_SnapInterp_CheckBaseExtrap = Target.IGPlus_SnapInterp_StatExtrap;
	IGPlus_SnapInterp_CheckBaseClamp = Target.IGPlus_SnapInterp_StatClamp;
	IGPlus_SnapInterp_CheckBaseFail = Target.IGPlus_SnapInterp_StatFail;
	IGPlus_SnapInterp_CheckBaseHardSnap = Target.IGPlus_SnapInterp_StatHardSnap;

	ClientMessage(
		"SnapInterpCheck start target="$TargetName$
		" profile="$Profile$
		" durS="$int(DurationSeconds + 0.5)
	);
}

exec simulated function SnapInterpCheckStop() {
	if (IGPlus_SnapInterp_CheckActive == false) {
		ClientMessage("SnapInterpCheck is not running");
		return;
	}

	IGPlus_SnapInterp_FinishCheck(true);
}

exec simulated function SnapInterpStatus(optional string TargetFilter) {
	local bbPlayer Target;
	local string TargetName;
	local string DebugMode;

	Target = IGPlus_SnapInterp_FindTarget(TargetFilter);
	if (Target == none) {
		ClientMessage("SnapInterp status: no simulated proxy target found");
		return;
	}

	TargetName = "Unknown";
	if (Target.PlayerReplicationInfo != none)
		TargetName = Target.PlayerReplicationInfo.PlayerName;

	if (ViewTarget == Target)
		DebugMode = "spectate";
	else
		DebugMode = "play";

	ClientMessage(
		"SnapInterp status target="$TargetName$
		" mode="$DebugMode$
		" snapEnabled="$Target.IGPlus_EnableSnapshotInterpolation$
		" count="$Target.IGPlus_SnapInterp_Count$
		" rep="$Target.IGPlus_SnapReplicatedData.Counter$
		" last="$Target.IGPlus_SnapInterp_LastCounter$
		" moved="$Target.IGPlus_LocationOffsetFix_Moved$
		" delayMs="$int(Target.IGPlus_SnapInterp_InterpDelay * 1000.0)$
		" interpMode="$Target.IGPlus_SnapInterp_LastInterpMode$
		" hint="$Target.IGPlus_SnapInterp_LastHintSource$
		" hintAgeMs="$Target.IGPlus_SnapInterp_LastHintAgeMs
	);
}

exec function bEnableInputReplication(optional string Value) {
	IGPlus_SetNetcodeSetting("bEnableInputReplication", Value);
}

exec function bEnableSnapshotInterpolation(optional string Value) {
	IGPlus_SetNetcodeSetting("bEnableSnapshotInterpolation", Value);
}

exec function SnapshotInterpSendHz(optional string Value) {
	IGPlus_SetNetcodeSetting("SnapshotInterpSendHz", Value);
}

exec function SnapshotInterpRewindMs(optional string Value) {
	IGPlus_SetNetcodeSetting("SnapshotInterpRewindMs", Value);
}

exec function MaxJitterTime(optional string Value) {
	IGPlus_SetNetcodeSetting("MaxJitterTime", Value);
}

exec function JitterBoundingMode(optional string Value) {
	IGPlus_SetNetcodeSetting("JitterBoundingMode", Value);
}

exec function NetcodeHelp() {
	if (Role < ROLE_Authority) {
		IGPlus_ServerNetcodeHelp();
		return;
	}

	IGPlus_PrintNetcodeHelp();
}

function IGPlus_ServerNetcodeHelp() {
	IGPlus_PrintNetcodeHelp();
}

function IGPlus_PrintNetcodeHelp() {
	local ServerSettings S;

	S = None;
	if (zzUTPure != None)
		S = zzUTPure.Settings;

	ClientMessage("Netcode settings (use '<Setting> <Value>'):");
	if (S == None) {
		ClientMessage("Settings unavailable");
		return;
	}

	ClientMessage("bEnableInputReplication="$S.GetPropertyText("bEnableInputReplication"));
	ClientMessage("bEnableSnapshotInterpolation="$S.GetPropertyText("bEnableSnapshotInterpolation"));
	ClientMessage("SnapshotInterpSendHz="$S.GetPropertyText("SnapshotInterpSendHz"));
	ClientMessage("SnapshotInterpRewindMs="$S.GetPropertyText("SnapshotInterpRewindMs"));
	ClientMessage("MaxJitterTime="$S.GetPropertyText("MaxJitterTime"));
	ClientMessage("JitterBoundingMode="$S.GetPropertyText("JitterBoundingMode")$" (JB_None|JB_CarrierOnly|JB_All)");
	ClientMessage("SnapInterpDebug (toggle client report + server echo + proxy status)");
	ClientMessage("SnapInterpStatus [NameFilter] (one-shot proxy runtime status)");
	ClientMessage("SnapInterpNetStatus [NameFilter] (client report + server echo + proxy status)");
	ClientMessage("SnapInterpCheck [clean|lossy] [DurationSec] [NameFilter]");
	ClientMessage("SnapInterpCheckStop");
}

exec function IGPlus_SetNetcodeSetting(string Key, optional string Value) {
	if (Role < ROLE_Authority) {
		IGPlus_ServerSetNetcodeSetting(Key, Value);
		return;
	}

	if (bAdmin == false) {
		ClientMessage("Admin only");
		return;
	}

	IGPlus_ApplyNetcodeSetting(Key, Value);
}

function IGPlus_ServerSetNetcodeSetting(string Key, string Value) {
	if (bAdmin == false) {
		ClientMessage("Admin only");
		return;
	}

	IGPlus_ApplyNetcodeSetting(Key, Value);
}

function string IGPlus_NormalizeNetcodeKey(string Key) {
	if (Key ~= "bEnableInputReplication") return "bEnableInputReplication";
	if (Key ~= "bEnableSnapshotInterpolation") return "bEnableSnapshotInterpolation";
	if (Key ~= "SnapshotInterpSendHz") return "SnapshotInterpSendHz";
	if (Key ~= "SnapshotInterpRewindMs") return "SnapshotInterpRewindMs";
	if (Key ~= "MaxJitterTime") return "MaxJitterTime";
	if (Key ~= "JitterBoundingMode") return "JitterBoundingMode";
	return "";
}

function IGPlus_ApplyNetcodeSettingsToPlayers() {
	local Pawn P;
	local bbPlayer BP;
	local bool bOldSnap;

	for (P = Level.PawnList; P != None; P = P.NextPawn) {
		BP = bbPlayer(P);
		if (BP == None)
			continue;

		BP.IGPlus_EnableInputReplication = zzUTPure.Settings.bEnableInputReplication;
		BP.IGPlus_PredictedSwitching = zzUTPure.Settings.PredictedSwitchingActive();
		BP.IGPlus_PredictedTranslocation = zzUTPure.Settings.PredictedTranslocationActive();
		BP.IGPlus_PredictedSelfKnockback = zzUTPure.Settings.PredictedSelfKnockbackActive();
		BP.IGPlus_PushSafeAim = zzUTPure.Settings.PushSafeAimActive();
		BP.IGPlus_DetTranslocator = zzUTPure.Settings.DeterministicTranslocatorActive();
		BP.IGPlus_PredictedDiscBoost = zzUTPure.Settings.bEnablePredictedDiscBoost;
		bOldSnap = BP.IGPlus_EnableSnapshotInterpolation;
		BP.IGPlus_EnableSnapshotInterpolation = zzUTPure.Settings.SnapshotInterpolationActive();
		BP.IGPlus_EnableTickInterp = zzUTPure.Settings.TickInterpolationActive();

		if (bOldSnap != BP.IGPlus_EnableSnapshotInterpolation) {
			BP.IGPlus_SnapInterp_ServerNextTime = 0;
			BP.IGPlus_SnapInterp_ServerHasLast = false;
			BP.IGPlus_SnapInterp_CheckActive = false;
			BP.IGPlus_ServerSnapInterpDelayMsSmoothed = 0.0;
			BP.IGPlus_ServerSnapInterpDelayValid = false;
			BP.IGPlus_ServerSnapInterpTrusted = false;
			BP.IGPlus_ServerSnapInterpLastAcceptedTime = 0.0;
			BP.IGPlus_NextSnapInterpDelayReportTime = 0.0;
			BP.IGPlus_NextSnapInterpDelayClientReportTime = 0.0;
			BP.IGPlus_ClientSnapInterpDelayMs = -1;
			BP.IGPlus_ClientSnapInterpDelaySampleCount = 0;
			BP.IGPlus_ClientSnapInterpDelayMedianMs = -1;
			BP.IGPlus_ClientSnapInterpDelaySpreadMs = -1;
			BP.IGPlus_ServerSnapInterpDelayReportedMsEcho = -1;
			BP.IGPlus_ServerSnapInterpDelayClampedMsEcho = -1;
			BP.IGPlus_ServerSnapInterpDelaySmoothedMsEcho = 0;
			BP.IGPlus_ServerSnapInterpDelayValidEcho = false;
			BP.IGPlus_ServerSnapInterpTrustedEcho = false;
			BP.IGPlus_ServerSnapInterpDelayEchoTime = 0.0;
			BP.IGPlus_ServerSnapInterpLastAcceptedTimeEcho = 0.0;
		}
	}
}

function IGPlus_ApplyNetcodeSetting(string Key, string Value) {
	local string NormalKey;

	if (zzUTPure == None || zzUTPure.Settings == None) {
		ClientMessage("No server settings loaded");
		return;
	}

	NormalKey = IGPlus_NormalizeNetcodeKey(Key);
	if (NormalKey == "") {
		ClientMessage("Unknown netcode setting: " $ Key);
		return;
	}

	if (Value == "") {
		ClientMessage(NormalKey $ "=" $ zzUTPure.Settings.GetPropertyText(NormalKey));
		return;
	}

	zzUTPure.Settings.SetPropertyText(NormalKey, Value);
	zzUTPure.Settings.SaveConfig();
	IGPlus_ApplyNetcodeSettingsToPlayers();
	ClientMessage(NormalKey $ "=" $ zzUTPure.Settings.GetPropertyText(NormalKey));
}

simulated function ServerSettings IGPlus_GetServerSettingsObject() {
	if (IGPlus_ServerSettingsMenuData != none)
		return IGPlus_ServerSettingsMenuData;

	IGPlus_ServerSettingsHelper = new(none, 'InstaGibPlus') class'Object';
	IGPlus_ServerSettingsMenuData = new(IGPlus_ServerSettingsHelper, 'IGPlus_ServerSettingsMenu') class'ServerSettings';
	return IGPlus_ServerSettingsMenuData;
}

function IGPlus_ServerSettingsInit() {
	IGPlus_ServerSettingsMenuLoaded = false;
	IGPlus_ServerSettingsMenuCanEdit = false;
	IGPlus_ServerSettingsMenuData = none;
}

function IGPlus_ServerSettingsSet(string Key, string Value) {
	local ServerSettings S;

	S = IGPlus_GetServerSettingsObject();
	if (S == none)
		return;

	S.SetPropertyText(Key, Value);
}

function IGPlus_ServerSettingsDone(bool bCanEdit) {
	IGPlus_ServerSettingsMenuLoaded = true;
	IGPlus_ServerSettingsMenuCanEdit = bCanEdit;
}

function IGPlus_ServerSendSetting(string Key) {
	if (zzUTPure == none || zzUTPure.Settings == none)
		return;

	IGPlus_ServerSettingsSet(Key, zzUTPure.Settings.GetPropertyText(Key));
}

function IGPlus_ServerRequestSettings() {
	if (bAdmin == false || zzUTPure == none || zzUTPure.Settings == none) {
		IGPlus_ServerSettingsInit();
		IGPlus_ServerSettingsDone(false);
		return;
	}

	IGPlus_ServerSettingsInit();

	IGPlus_ServerSendSetting("bAutoPause");
	IGPlus_ServerSendSetting("PauseTotalTime");
	IGPlus_ServerSendSetting("PauseTime");
	IGPlus_ServerSendSetting("bForceDemo");
	IGPlus_ServerSendSetting("bAutoDebugData");
	IGPlus_ServerSendSetting("bRestrictTrading");
	IGPlus_ServerSendSetting("MaxTradeTimeMargin");
	IGPlus_ServerSendSetting("TradePingMargin");
	IGPlus_ServerSendSetting("bEnableAllWeaponTrades");
	IGPlus_ServerSendSetting("KillCamDelay");
	IGPlus_ServerSendSetting("KillCamDuration");

	IGPlus_ServerSendSetting("bWarmup");
	IGPlus_ServerSendSetting("bCoaches");
	IGPlus_ServerSendSetting("Timeouts");
	IGPlus_ServerSendSetting("bFastTeams");
	IGPlus_ServerSendSetting("bUseClickboard");
	IGPlus_ServerSendSetting("bAdvancedTeamSay");
	IGPlus_ServerSendSetting("bAllowMultiWeapon");
	IGPlus_ServerSendSetting("bDelayedPickupSpawn");
	IGPlus_ServerSendSetting("bUseFastWeaponSwitch");
	IGPlus_ServerSendSetting("bEnablePredictedSwitching");
	IGPlus_ServerSendSetting("bEnablePredictedTranslocation");
	IGPlus_ServerSendSetting("bEnablePredictedSelfKnockback");
	IGPlus_ServerSendSetting("bEnablePushSafeAim");
	IGPlus_ServerSendSetting("bEnableDeterministicTranslocator");
	IGPlus_ServerSendSetting("bEnablePredictedDiscBoost");
	IGPlus_ServerSendSetting("bTellSpectators");

	IGPlus_ServerSendSetting("bJumpingPreservesMomentum");
	IGPlus_ServerSendSetting("bOldLandingMomentum");
	IGPlus_ServerSendSetting("bEnableSingleButtonDodge");
	IGPlus_ServerSendSetting("bUseFlipAnimation");
	IGPlus_ServerSendSetting("bEnableWallDodging");
	IGPlus_ServerSendSetting("bDodgePreserveZMomentum");
	IGPlus_ServerSendSetting("MaxMultiDodges");
	IGPlus_ServerSendSetting("BrightskinMode");
	IGPlus_ServerSendSetting("PlayerScale");
	IGPlus_ServerSendSetting("bAlwaysRenderFlagCarrier");
	IGPlus_ServerSendSetting("bAlwaysRenderDroppedFlags");

	IGPlus_ServerSendSetting("MaxHitError");
	IGPlus_ServerSendSetting("MaxJitterTime");
	IGPlus_ServerSendSetting("WarpFixDelay");
	IGPlus_ServerSendSetting("FireTimeout");
	IGPlus_ServerSendSetting("MinNetUpdateRate");
	IGPlus_ServerSendSetting("MaxNetUpdateRate");
	IGPlus_ServerSendSetting("bEnableInputReplication");
	IGPlus_ServerSendSetting("bPlayersAlwaysRelevant");
	IGPlus_ServerSendSetting("bEnablePingCompensatedSpawn");
	IGPlus_ServerSendSetting("JitterBoundingMode");
	IGPlus_ServerSendSetting("bEnableSnapshotInterpolation");
	IGPlus_ServerSendSetting("SnapshotInterpSendHz");
	IGPlus_ServerSendSetting("SnapshotInterpRewindMs");
	IGPlus_ServerSendSetting("bEnableWarpFix");
	IGPlus_ServerSendSetting("bEnableAdaptiveBuffering");
	IGPlus_ServerSendSetting("bEnableTickInterpolation");
	IGPlus_ServerSendSetting("AdaptiveBufferingMax");

	IGPlus_ServerSendSetting("MinClientRate");
	IGPlus_ServerSendSetting("MaxClientRate");

	IGPlus_ServerSendSetting("ShowTouchedPackage");
	IGPlus_ServerSendSetting("HitFeedbackMode");
	IGPlus_ServerSendSetting("ShowDamageNumberMode");
	IGPlus_ServerSendSetting("bEnableHitboxDebugMode");

	IGPlus_ServerSettingsDone(true);
}

simulated function WeaponSettings IGPlus_GetWeaponSettingsObject() {
	if (IGPlus_WeaponSettingsMenuData != none)
		return IGPlus_WeaponSettingsMenuData;

	IGPlus_WeaponSettingsHelper = new(none, 'InstaGibPlus') class'Object';
	IGPlus_WeaponSettingsMenuData = new(IGPlus_WeaponSettingsHelper, 'IGPlus_WeaponSettingsMenu') class'WeaponSettings';
	return IGPlus_WeaponSettingsMenuData;
}

function IGPlus_WeaponSettingsInit() {
	IGPlus_WeaponSettingsMenuLoaded = false;
	IGPlus_WeaponSettingsMenuCanEdit = false;
	IGPlus_WeaponSettingsMenuData = none;
}

function IGPlus_WeaponSettingsSet(string Key, string Value) {
	local WeaponSettings S;

	S = IGPlus_GetWeaponSettingsObject();
	if (S == none)
		return;

	S.SetPropertyText(Key, Value);
}

function IGPlus_WeaponSettingsDone(bool bCanEdit) {
	IGPlus_WeaponSettingsMenuLoaded = true;
	IGPlus_WeaponSettingsMenuCanEdit = bCanEdit;
}

function IGPlus_WeaponSendSetting(string Key) {
	local IGPlus_WeaponImplementation WImp;

	if (zzUTPure == none)
		return;

	WImp = zzUTPure.GetWeaponImpl();
	if (WImp == none || WImp.WeaponSettings == none)
		return;

	IGPlus_WeaponSettingsSet(Key, WImp.WeaponSettings.GetPropertyText(Key));
}

function IGPlus_WeaponRequestSettings() {
	local IGPlus_WeaponImplementation WImp;

	if (bAdmin == false || zzUTPure == none) {
		IGPlus_WeaponSettingsInit();
		IGPlus_WeaponSettingsDone(false);
		return;
	}

	WImp = zzUTPure.GetWeaponImpl();
	if (WImp == none || WImp.WeaponSettings == none) {
		IGPlus_WeaponSettingsInit();
		IGPlus_WeaponSettingsDone(false);
		return;
	}

	IGPlus_WeaponSettingsInit();

	IGPlus_WeaponSendSetting("bEnableEnhancedSplashBio");
	IGPlus_WeaponSendSetting("bEnableEnhancedSplashShockCombo");
	IGPlus_WeaponSendSetting("bEnableEnhancedSplashShockProjectile");
	IGPlus_WeaponSendSetting("bEnableEnhancedSplashRipperSecondary");
	IGPlus_WeaponSendSetting("bEnableEnhancedSplashFlakSlug");
	IGPlus_WeaponSendSetting("bEnableEnhancedSplashRockets");
	IGPlus_WeaponSendSetting("bEnhancedSplashIgnoreStationaryPawns");
	IGPlus_WeaponSendSetting("SplashMaxDiffraction");
	IGPlus_WeaponSendSetting("SplashMinDiffractionDistance");
	IGPlus_WeaponSendSetting("SplashWraparoundRadiusScale");
	IGPlus_WeaponSendSetting("HeadHalfHeight");
	IGPlus_WeaponSendSetting("HeadRadius");
	IGPlus_WeaponSendSetting("bEnablePingCompensation");
	IGPlus_WeaponSendSetting("bEnableTrades");
	IGPlus_WeaponSendSetting("bEnableFireTimeOrder");
	IGPlus_WeaponSendSetting("PreciseRewindTimeMaxDeviationMs");
	IGPlus_WeaponSendSetting("PingCompensationMax");
	IGPlus_WeaponSendSetting("bEnableAnimationAdaptiveHeadHitbox");
	IGPlus_WeaponSendSetting("InvisibilityDuration");
	IGPlus_WeaponSendSetting("ShieldBeltCharge");
	IGPlus_WeaponSendSetting("ArmorCharge");
	IGPlus_WeaponSendSetting("ThighPadsCharge");
	IGPlus_WeaponSendSetting("HealthPackHealingAmount");
	IGPlus_WeaponSendSetting("WarheadSelectTime");
	IGPlus_WeaponSendSetting("WarheadDownTime");
	IGPlus_WeaponSendSetting("SniperSelectTime");
	IGPlus_WeaponSendSetting("SniperDownTime");
	IGPlus_WeaponSendSetting("SniperDamage");
	IGPlus_WeaponSendSetting("SniperHeadshotDamage");
	IGPlus_WeaponSendSetting("SniperMomentum");
	IGPlus_WeaponSendSetting("SniperHeadshotMomentum");
	IGPlus_WeaponSendSetting("SniperReloadTime");
	IGPlus_WeaponSendSetting("SniperUseReducedHitbox");
	IGPlus_WeaponSendSetting("EightballSelectTime");
	IGPlus_WeaponSendSetting("EightballDownTime");
	IGPlus_WeaponSendSetting("RocketDamage");
	IGPlus_WeaponSendSetting("RocketSelfDamage");
	IGPlus_WeaponSendSetting("RocketHurtRadius");
	IGPlus_WeaponSendSetting("RocketMomentum");
	IGPlus_WeaponSendSetting("RocketSpreadSpacingDegrees");
	IGPlus_WeaponSendSetting("RocketSpeed");
	IGPlus_WeaponSendSetting("GrenadeDamage");
	IGPlus_WeaponSendSetting("GrenadeHurtRadius");
	IGPlus_WeaponSendSetting("GrenadeMomentum");
	IGPlus_WeaponSendSetting("RocketCompensatePing");
	IGPlus_WeaponSendSetting("FlakSelectTime");
	IGPlus_WeaponSendSetting("FlakPostSelectTime");
	IGPlus_WeaponSendSetting("FlakDownTime");
	IGPlus_WeaponSendSetting("FlakChunkDamage");
	IGPlus_WeaponSendSetting("FlakChunkMomentum");
	IGPlus_WeaponSendSetting("FlakChunkLifespan");
	IGPlus_WeaponSendSetting("FlakChunkDropOffStart");
	IGPlus_WeaponSendSetting("FlakChunkDropOffEnd");
	IGPlus_WeaponSendSetting("FlakChunkDropOffDamageRatio");
	IGPlus_WeaponSendSetting("FlakChunkRandomSpread");
	IGPlus_WeaponSendSetting("FlakChunkRandomSpreadSize");
	IGPlus_WeaponSendSetting("FlakSlugDamage");
	IGPlus_WeaponSendSetting("FlakSlugHurtRadius");
	IGPlus_WeaponSendSetting("FlakSlugMomentum");
	IGPlus_WeaponSendSetting("FlakCompensatePing");
	IGPlus_WeaponSendSetting("RipperSelectTime");
	IGPlus_WeaponSendSetting("RipperDownTime");
	IGPlus_WeaponSendSetting("RipperHeadshotDamage");
	IGPlus_WeaponSendSetting("RipperHeadShotDamageWallMultiplier");
	IGPlus_WeaponSendSetting("RipperHeadshotMomentum");
	IGPlus_WeaponSendSetting("RipperPrimaryDamage");
	IGPlus_WeaponSendSetting("RipperPrimaryDamageWallMultiplier");
	IGPlus_WeaponSendSetting("RipperPrimaryMomentum");
	IGPlus_WeaponSendSetting("RipperSecondaryHurtRadius");
	IGPlus_WeaponSendSetting("RipperSecondaryDamage");
	IGPlus_WeaponSendSetting("RipperSecondaryMomentum");
	IGPlus_WeaponSendSetting("RipperCompensatePing");
	IGPlus_WeaponSendSetting("MinigunSelectTime");
	IGPlus_WeaponSendSetting("MinigunDownTime");
	IGPlus_WeaponSendSetting("MinigunSpinUpTime");
	IGPlus_WeaponSendSetting("MinigunUnwindTime");
	IGPlus_WeaponSendSetting("MinigunBulletInterval");
	IGPlus_WeaponSendSetting("MinigunAlternateBulletInterval");
	IGPlus_WeaponSendSetting("MinigunMinDamage");
	IGPlus_WeaponSendSetting("MinigunMaxDamage");
	IGPlus_WeaponSendSetting("MinigunAltMinDamage");
	IGPlus_WeaponSendSetting("MinigunAltMaxDamage");
	IGPlus_WeaponSendSetting("PulseSelectTime");
	IGPlus_WeaponSendSetting("PulseDownTime");
	IGPlus_WeaponSendSetting("PulseSphereDamage");
	IGPlus_WeaponSendSetting("PulseSphereMomentum");
	IGPlus_WeaponSendSetting("PulseSphereSpeed");
	IGPlus_WeaponSendSetting("PulseSphereFireRate");
	IGPlus_WeaponSendSetting("PulseSphereCollisionRadius");
	IGPlus_WeaponSendSetting("PulseSphereCollisionHeight");
	IGPlus_WeaponSendSetting("PulseBoltDPS");
	IGPlus_WeaponSendSetting("PulseBoltMomentum");
	IGPlus_WeaponSendSetting("PulseBoltMaxAccumulate");
	IGPlus_WeaponSendSetting("PulseBoltGrowthDelay");
	IGPlus_WeaponSendSetting("PulseBoltMaxSegments");
	IGPlus_WeaponSendSetting("PulseCompensatePing");
	IGPlus_WeaponSendSetting("ShockSelectTime");
	IGPlus_WeaponSendSetting("ShockDownTime");
	IGPlus_WeaponSendSetting("ShockBeamDamage");
	IGPlus_WeaponSendSetting("ShockBeamMomentum");
	IGPlus_WeaponSendSetting("ShockBeamUseReducedHitbox");
	IGPlus_WeaponSendSetting("ShockProjectileDamage");
	IGPlus_WeaponSendSetting("ShockProjectileHurtRadius");
	IGPlus_WeaponSendSetting("ShockProjectileMomentum");
	IGPlus_WeaponSendSetting("ShockProjectileBlockBullets");
	IGPlus_WeaponSendSetting("ShockProjectileBlockFlakChunk");
	IGPlus_WeaponSendSetting("ShockProjectileBlockFlakSlug");
	IGPlus_WeaponSendSetting("ShockProjectileTakeDamage");
	IGPlus_WeaponSendSetting("ShockProjectileHealth");
	IGPlus_WeaponSendSetting("ShockComboDamage");
	IGPlus_WeaponSendSetting("ShockComboMomentum");
	IGPlus_WeaponSendSetting("ShockComboHurtRadius");
	IGPlus_WeaponSendSetting("ShockComboRewindMax");
	IGPlus_WeaponSendSetting("BioSelectTime");
	IGPlus_WeaponSendSetting("BioDownTime");
	IGPlus_WeaponSendSetting("BioDamage");
	IGPlus_WeaponSendSetting("BioMomentum");
	IGPlus_WeaponSendSetting("BioPrimaryInstantExplosion");
	IGPlus_WeaponSendSetting("BioAltDamage");
	IGPlus_WeaponSendSetting("BioAltMomentum");
	IGPlus_WeaponSendSetting("BioHurtRadiusBase");
	IGPlus_WeaponSendSetting("BioHurtRadiusMax");
	IGPlus_WeaponSendSetting("BioCompensatePing");
	IGPlus_WeaponSendSetting("EnforcerSelectTime");
	IGPlus_WeaponSendSetting("EnforcerDownTime");
	IGPlus_WeaponSendSetting("EnforcerDamage");
	IGPlus_WeaponSendSetting("EnforcerMomentum");
	IGPlus_WeaponSendSetting("EnforcerReloadTime");
	IGPlus_WeaponSendSetting("EnforcerReloadTimeAlt");
	IGPlus_WeaponSendSetting("EnforcerReloadTimeRepeat");
	IGPlus_WeaponSendSetting("EnforcerUseReducedHitbox");
	IGPlus_WeaponSendSetting("EnforcerAllowDouble");
	IGPlus_WeaponSendSetting("EnforcerDamageDouble");
	IGPlus_WeaponSendSetting("EnforcerMomentumDouble");
	IGPlus_WeaponSendSetting("EnforcerShotOffsetDouble");
	IGPlus_WeaponSendSetting("EnforcerReloadTimeDouble");
	IGPlus_WeaponSendSetting("EnforcerReloadTimeAltDouble");
	IGPlus_WeaponSendSetting("EnforcerReloadTimeRepeatDouble");
	IGPlus_WeaponSendSetting("HammerSelectTime");
	IGPlus_WeaponSendSetting("HammerDownTime");
	IGPlus_WeaponSendSetting("HammerDamage");
	IGPlus_WeaponSendSetting("HammerMomentum");
	IGPlus_WeaponSendSetting("HammerSelfDamage");
	IGPlus_WeaponSendSetting("HammerSelfMomentum");
	IGPlus_WeaponSendSetting("HammerAltDamage");
	IGPlus_WeaponSendSetting("HammerAltMomentum");
	IGPlus_WeaponSendSetting("HammerAltSelfDamage");
	IGPlus_WeaponSendSetting("HammerAltSelfMomentum");
	IGPlus_WeaponSendSetting("TranslocatorSelectTime");
	IGPlus_WeaponSendSetting("TranslocatorOutSelectTime");
	IGPlus_WeaponSendSetting("TranslocatorDownTime");
	IGPlus_WeaponSendSetting("TranslocatorHealth");
	IGPlus_WeaponSendSetting("TranslocatorCompensatePing");

	IGPlus_WeaponSettingsDone(true);
}


exec function DrawServerLocation() {
	IGPlus_LocationOffsetFix_DrawServerLocation = !IGPlus_LocationOffsetFix_DrawServerLocation;
}

simulated function SetMesh() {
	if (bDeleteMe)
		return;
	super.SetMesh();
}

exec function TraceInput() {
	if (IGPlus_InputLogFile == none) {
		ClientMessage("Input trace unavailable (log actor not ready)");
		return;
	}

	if (bTraceInput) {
		ClientMessage("Stop tracing input");
		IGPlus_InputLogFile.StopLog();
	} else {
		ClientMessage("Start tracing input");
		IGPlus_InputLogFile.StartLog();
	}
	bTraceInput = !bTraceInput;
	if (Role < ROLE_Authority)
		ServerSetTraceInput(bTraceInput);
}

function ServerSetTraceInput(bool bEnable) {
	// Server-side tracing writes ~7.5 MB/min per traced player; do not let
	// an unprivileged client start it.
	if (bAdmin == false) {
		ClientMessage("Admin only");
		return;
	}
	bTraceInput = bEnable;
	if (IGPlus_InputLogFile != none) {
		if (bEnable)
			IGPlus_InputLogFile.StartLog();
		else
			IGPlus_InputLogFile.StopLog();
	}
	Log("[IGP] TraceInput server="$bEnable$" player="$PlayerReplicationInfo.PlayerName);
}

function PreCacheReferences() {
	local IGPlus_ModelImport MI;
	super.PreCacheReferences();

	MI = new(none) class'IGPlus_ModelImport';
}

defaultproperties
{
	bNewNet=True
	HUDInfo=1
	NN_ProjLength=256
	bIsFinishedLoading=False
	bDrawDebugData=False
	TimeBetweenNetUpdates=0.01
	DodgeSpeedXY=600
	DodgeSpeedZ=210
	SecondaryDodgeSpeedXY=500
	SecondaryDodgeSpeedZ=180
	DodgeEndVelocity=0.1
	JumpEndVelocity=1.0
	LastWeaponEffectCreated=-1
	RespawnDelay=1.0
	NetUpdateFrequency=200
	PlayerReplicationInfoClass=Class'bbPlayerReplicationInfo'

	FRandValuesLength=47

	IGPlus_ZoomToggle_SensitivityFactorX=1.0
	IGPlus_ZoomToggle_SensitivityFactorY=1.0

	LocalExtrapolationOwnPingFactor=0.0
	LocalExtrapolationOtherPingFactor=0.0

	IGPlus_EnableDualButtonSwitch=True

	IGPlus_LocationOffsetFix_PredCompatMode=True
	IGPlus_EnableInputReplication=True
	IGPlus_ClientSnapInterpDelayMs=-1
	IGPlus_ClientSnapInterpDelayMedianMs=-1
	IGPlus_ServerSnapInterpDelayReportedMsEcho=-1
	IGPlus_ServerSnapInterpDelayClampedMsEcho=-1
}
