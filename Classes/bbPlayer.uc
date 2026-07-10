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
var int		zzForceSettingsLevel;	// The Anti-Default/Ini check force.
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
var float IGPlus_GameEndedTime;

// Stuff
var float	zzDesiredFOV;		// Needed ?
var float	zzOrigFOV;		// Original FOV for TrackFOV = 1
var string	FakeClass;		// Class that the model replaces
var string	zzMyPacks;		// Defined only for defaults
var bool	zzbBadGuy;		// BadGuy! (Avoid kick spamming)
var int		zzOldForceSettingsLevel;	// Kept to see if things change.
var int     zzRecentDmgGiven, zzRecentTeamDmgGiven, TeleRadius;
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
// Server-side v4 binding invariants: weapon switched away from (grace window
// for in-flight steps, move-timestamp domain) and the last move's held state
// (fire continuity when switching to a weapon the v4 path does not drive).
var Weapon IGPlus_V4PrevWeapon;
var float IGPlus_V4PrevWeaponUntilTS;
var bool IGPlus_LastFireEndHeld;
var bool IGPlus_LastAltEndHeld;
// v5 fire-window state (server-side, move-timestamp domain).
var float IGPlus_V4WeaponGateTS;
var Weapon IGPlus_V4PendingSeen;
var float IGPlus_V4PendingSeenTS;
var float IGPlus_V4PrevWeaponStepTS; // grace weapon: last valid step time
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
var float FakeCAPInterval; // Send a FakeCAP after no CAP has been sent for this amount of time
var float ExtrapolationDelta;
var bool bExtrapolatedLastUpdate;
struct SavedData {
	var() vector Location;
	var() vector Velocity;
	var() vector Acceleration;
	var() name State;
	var() EPhysics Physics;
	var() EDodgeDir DodgeDir;
};
var SavedData Saved;
var bool bIs469Server;
var bool bIs469Client;

// Clientside smoothing of position adjustment.
var vector IGPlus_PreAdjustLocation;
var vector IGPlus_AdjustLocationOffset;
var float IGPlus_AdjustLocationAlpha;
var bool IGPlus_AdjustLocationOverride;

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
var bool IGPlus_DidTranslocate;
var bool IGPlus_NotifiedTranslocate;
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
var IGPlus_WeaponImplementationBase IGPlus_WImpBase;
const IGPLUS_V4FLAG_FIRE_START_HELD = 0x00000001;
const IGPLUS_V4FLAG_FIRE_END_HELD = 0x00000002;
const IGPLUS_V4FLAG_ALT_START_HELD = 0x00000004;
const IGPLUS_V4FLAG_ALT_END_HELD = 0x00000008;
const IGPLUS_V4FLAG_HAS_FIRE_PRESS = 0x00000010;
const IGPLUS_V4FLAG_HAS_FIRE_RELEASE = 0x00000020;
const IGPLUS_V4FLAG_HAS_ALT_PRESS = 0x00000040;
const IGPLUS_V4FLAG_HAS_ALT_RELEASE = 0x00000080;
const IGPLUS_V4FLAG_FIRE_PRESS_SHIFT = 8;
const IGPLUS_V4FLAG_FIRE_RELEASE_SHIFT = 13;
const IGPLUS_V4FLAG_ALT_PRESS_SHIFT = 18;
	const IGPLUS_V4FLAG_ALT_RELEASE_SHIFT = 23;
	const IGPLUS_V4FLAG_INDEX_MASK = 0x1F;
	const IGPLUS_V4FLAG_TIMELINE_VALID = 0x10000000;
	const IGPLUS_V4FLAG_EB_INSTANT = 0x20000000;
	const IGPLUS_V4FLAG_EB_SHOTPACK_PRESENT = 0x40000000;
	const IGPLUS_EB_SHOT_QUEUE_SIZE = 32;
	const IGPLUS_EB_SHOT_RESEND_INTERVAL = 0.03;
	const IGPLUS_EB_SHOT_TIMEOUT = 1.0;
	const IGPLUS_V4WEAPON_None = 0;
	const IGPLUS_V4WEAPON_ShockRifle = 1;
	const IGPLUS_V4WEAPON_Ripper = 2;
	const IGPLUS_V4WEAPON_FlakCannon = 3;
	const IGPLUS_V4WEAPON_BioRifle = 4;
	const IGPLUS_V4WEAPON_Eightball = 5;

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

var IGPlus_DamageEvent IGPlus_DamageEvent_First;
var IGPlus_DamageEvent IGPlus_DamageEvent_Latest;
var IGPlus_DamageEvent IGPlus_DamageEvent_FreeList;
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
var bool IGPlus_WeaponSettingsMenuCanEdit;

struct IGPlus_WarpFix {
	var vector OldLocation;
	var int Counter;
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
var bool IGPlus_PressedJumpSave;
var IGPlus_SavedInputChain IGPlus_SavedInputChain;
var IGPlus_DataBuffer IGPlus_InputReplicationBuffer;
var float IGPlus_LastInputSendTime;
var float MinDodgeClickTime;
var IGPlus_InputLogFile IGPlus_InputLogFile;
var bool bTraceInput;

struct IGPlus_EightballShotPendingEntry {
	var bool bActive;
	var int Seq;
	var float ShotTS;
	var int Charge;
	var float LastSendTS;
};
var IGPlus_EightballShotPendingEntry IGPlus_EBShotPending[IGPLUS_EB_SHOT_QUEUE_SIZE];
var int IGPlus_EBShotNextSeq;
var bool IGPlus_EBShotRecvInit;
var int IGPlus_EBShotRecvBase;
var int IGPlus_EBShotRecvMask;

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
	var bool bPulseUseClientSideAnimations;
	var bool bRipperUseClientSideAnimations;
	var bool bFlakUseClientSideAnimations;
	var bool bRocketUseClientSideAnimations;
	var bool bSniperUseClientSideAnimations;
	var bool bTranslocatorUseClientSideAnimations;
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
		IGPlus_EnableInputReplication,
		IGPlus_EnableWarpFix,
		IGPlus_WarpFixDelay,
		IGPlus_UseFastWeaponSwitch,
		KillCamDelay,
		KillCamDuration,
		LastKiller,
		RespawnDelay,
		TimeBetweenNetUpdates,
		zzbForceDemo,
		zzbGameStarted,
		zzbForceModels,
		zzbIsWarmingUp,
		zzCVDelay,
		zzCVDeny,
		zzForceSettingsLevel,
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
		FakeCAPInterval,
		IGPlus_DamageEvent_ShowOnDeath,
		IGPlus_EnableDualButtonSwitch,
		IGPlus_ClientSnapInterpDelayMs,
		IGPlus_ClientSnapInterpDelaySampleCount,
		IGPlus_ClientSnapInterpDelaySpreadMs,
		PingAverage,
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
// Functions Server -> Client
	reliable if ( Role == ROLE_Authority )
		IGPlusMenu,
		Ready,
		xxClientKicker,
		xxClientSwJumpPad,
		xxSetDefaultWeapon,
		xxSetPendingWeapon,
		xxSetTeleRadius,
		xxSetTimes,
		FRandValues,
		FRandValuesIndex;

	reliable if ( RemoteRole == ROLE_AutonomousProxy && !bDemoRecording )
		xxCheatFound,
		xxClientDoEndShot,
		xxClientDoScreenshot;

	reliable if ((Role == ROLE_Authority) && !bClientDemoRecording)
		xxNN_ClientProjExplode;

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
		IGPlus_ClientReStart,
		IGPlus_NotifyPlayerRestart;

	unreliable if (RemoteRole == ROLE_AutonomousProxy)
		xxCAP,
		xxCAPLevelBase,
		xxCAPWalking,
		xxCAPWalkingWalking,
		xxCAPWalkingWalkingLevelBase,
		IGPlus_ClientEightballShotAck,
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
		xxServerMove_v4,
		xxServerMoveDead;

	reliable if ( Role < ROLE_Authority )
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
		xxClientDemoFix;

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
	if (Role == ROLE_Authority && zzUTPure != none) {
		zzUTPure.ModifyLogout(self);
	}
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

simulated function bool xxNewMoveSmooth(vector NewLoc)
{
	return MoveSmooth(NewLoc - Location);
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
		Log("Loaded Settings!", 'IGPlus');
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
	Log("Creating"@TickRate@"MovementInfo blocks", 'IGPlus');
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
	ClientWeaponSettingsData.bPulseUseClientSideAnimations = Settings.bPulseUseClientSideAnimations;
	ClientWeaponSettingsData.bRipperUseClientSideAnimations = Settings.bRipperUseClientSideAnimations;
	ClientWeaponSettingsData.bFlakUseClientSideAnimations = Settings.bFlakUseClientSideAnimations;
	ClientWeaponSettingsData.bRocketUseClientSideAnimations = Settings.bRocketUseClientSideAnimations;
	ClientWeaponSettingsData.bSniperUseClientSideAnimations = Settings.bSniperUseClientSideAnimations;
	ClientWeaponSettingsData.bTranslocatorUseClientSideAnimations = Settings.bTranslocatorUseClientSideAnimations;

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
		FakeCAPInterval = Settings.FakeCAPInterval;
		IGPlus_DamageEvent_ShowOnDeath = Settings.bShowDeathReport;
		ClientSetMusic( Level.Song, Level.SongSection, Level.CdTrack, MTRAN_Fade );

		bIs469Client = int(Level.EngineVersion) >= 469;
	}
	else
	{
		TeleRadius = zzUTPure.Settings.TeleRadius;
		xxSetTeleRadius(TeleRadius);

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
		IGPlus_EnableInputReplication = zzUTPure.Settings.bEnableInputReplication;
		IGPlus_EnableSnapshotInterpolation = zzUTPure.Settings.bEnableSnapshotInterpolation;

		ShowDamageNumberMode = int(zzUTPure.Settings.ShowDamageNumberMode);

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

function IGPlus_ClientReStart(EPhysics phys, vector NewLocation, rotator NewRotation) {
	ClientSetLocation(NewLocation, NewRotation);
	ClientReStart();
	SetPhysics(phys);

	SetFOVAngle(135);
	IGPlus_NotifyPlayerRestart(NewLocation, NewRotation, self);
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

function ClientDebugMessage(coerce string S, optional name Type, optional bool bBeep) {
	if (Level.NetMode == NM_DedicatedServer || Role < ROLE_AutonomousProxy)
		return;

	if (Type == '')
		Type = 'IGPlusDebug';

	if (bDrawDebugData) {
		ClientMessage("["$IGPlus_FrameCount@Level.TimeSeconds$"] "$S, Type, bBeep);
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
	local float SmoothTime, FOVScale, MouseScale, AbsSmoothX, AbsSmoothY, MouseTime;
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
	SmoothTime = FMin(0.2, 3 * DeltaTime * Level.TimeDilation);
	FOVScale = DesiredFOV * 0.01111;
	MouseScale = MouseSensitivity * FOVScale;

	aMouseX *= MouseScale;
	aMouseY *= MouseScale;

//************************************************************************

	AbsSmoothX = SmoothMouseX;
	AbsSmoothY = SmoothMouseY;
	if (Settings.bNoSmoothing) {
		SmoothMouseX = aMouseX;
		SmoothMouseY = aMouseY;
		BorrowedMouseX = 0;
		BorrowedMouseY = 0;
	} else {
		MouseTime = (Level.TimeSeconds - MouseZeroTime)/Level.TimeDilation;
		if ( bMaxMouseSmoothing && (aMouseX == 0) && (MouseTime < MouseSmoothThreshold) )
		{
			SmoothMouseX = 0.5 * (MouseSmoothThreshold - MouseTime) * AbsSmoothX/MouseSmoothThreshold;
			BorrowedMouseX += SmoothMouseX;
		}
		else
		{
			if ( (SmoothMouseX == 0) || (aMouseX == 0)
					|| ((SmoothMouseX > 0) != (aMouseX > 0)) )
			{
				SmoothMouseX = aMouseX;
				BorrowedMouseX = 0;
			}
			else
			{
				SmoothMouseX = 0.5 * (SmoothMouseX + aMouseX - BorrowedMouseX);
				if ( (SmoothMouseX > 0) != (aMouseX > 0) )
				{
					if ( AMouseX > 0 )
						SmoothMouseX = 1;
					else
						SmoothMouseX = -1;
				}
				BorrowedMouseX = SmoothMouseX - aMouseX;
			}
			AbsSmoothX = SmoothMouseX;
		}
		if ( bMaxMouseSmoothing && (aMouseY == 0) && (MouseTime < MouseSmoothThreshold) )
		{
			SmoothMouseY = 0.5 * (MouseSmoothThreshold - MouseTime) * AbsSmoothY/MouseSmoothThreshold;
			BorrowedMouseY += SmoothMouseY;
		}
		else
		{
			if ( (SmoothMouseY == 0) || (aMouseY == 0)
					|| ((SmoothMouseY > 0) != (aMouseY > 0)) )
			{
				SmoothMouseY = aMouseY;
				BorrowedMouseY = 0;
			}
			else
			{
				SmoothMouseY = 0.5 * (SmoothMouseY + aMouseY - BorrowedMouseY);
				if ( (SmoothMouseY > 0) != (aMouseY > 0) )
				{
					if ( AMouseY > 0 )
						SmoothMouseY = 1;
					else
						SmoothMouseY = -1;
				}
				BorrowedMouseY = SmoothMouseY - aMouseY;
			}
			AbsSmoothY = SmoothMouseY;
		}
	}
	if ( (aMouseX != 0) || (aMouseY != 0) )
		MouseZeroTime = Level.TimeSeconds;

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
	SmoothMouseX = AbsSmoothX;
	SmoothMouseY = AbsSmoothY;

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
	if (bUpdatePosition == false)
		IGPlus_PreAdjustLocation = Location;
	if ( VSize(IGPlus_AdjustLocationOffset) > 0 )
	{
		IGPlus_AdjustLocationAlpha = 0;
		IGPlus_AdjustLocationOffset = vect(0,0,0);
	}
	IGPlus_AdjustLocationOverride = (TlocCounter != (MiscData&3));

	SetPhysics(GetPhysics((MiscData >> 2) & 0xF));
	TlocCounter = MiscData & 3;

	SetBase(NewBase);
	if ( Mover(NewBase) != None )
		NewLoc += NewBase.Location;

	if (GetStateName() != NewState)
		GotoState(newState);

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

	bUpdatePosition = true;
}

function IGPlus_ClientReplayMove(IGPlus_SavedMove M) {
	local int MergeCount, MoveIndex;
	local float dt;
	local bool bDoJump;
	local EDodgeDir DoDodge;
	local bool bDoRun;
	local bool bDoDuck;

	SetRotation(M.Rotation);
	ViewRotation = M.IGPlus_SavedViewRotation;
	bDodging = M.SavedDodging;

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

function ExtrapolationSaveData() {
	Saved.Location = Location;
	Saved.Velocity = Velocity;
	Saved.Acceleration = Acceleration;
	Saved.State = GetStateName();
	Saved.Physics = Physics;
	Saved.DodgeDir = DodgeDir;
}

function ExtrapolationRestoreData() {
	local vector OldLoc;
	local Decoration Carried;

	if (FastTrace(Saved.Location)) {
		xxNewMoveSmooth(Saved.Location);
	} else {
		Carried = CarriedDecoration;
		OldLoc = Location;

		bCanTeleport = false;
		xxNewSetLocation(Saved.Location, Saved.Velocity);
		bCanTeleport = true;

		if (Carried != None) {
			CarriedDecoration = Carried;
			CarriedDecoration.SetLocation(Saved.Location + CarriedDecoration.Location - OldLoc);
			CarriedDecoration.SetPhysics(PHYS_None);
			CarriedDecoration.SetBase(self);
		}
	}
	Velocity = Saved.Velocity;
	Acceleration = Saved.Acceleration;
	if (Saved.State == GetStateName()) {
		SetPhysics(Saved.Physics);
		DodgeDir = Saved.DodgeDir;
	}
}

function ExtrapolationDiscardData() {
	bExtrapolatedLastUpdate = false;
}

function WarpCompensation(float DeltaTime) {
	if (Level.Pauser == "" && !bWasPaused) {
		if (zzUTPure.Settings.bEnableServerExtrapolation &&
			bExtrapolatedLastUpdate == false && ExtrapolationDelta > AverageServerDeltaTime
		) {
			bExtrapolatedLastUpdate = true;
			ExtrapolationSaveData();
			SimMoveAutonomous(ExtrapolationDelta);
			ClientDebugMessage("Extrapolation"@ExtrapolationDelta);
		}
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

	if (((ServerTimeStamp - LastCAPTime) / Level.TimeDilation) > FakeCAPInterval) {
		xxFakeCAP(CurrentTimeStamp);
		LastCAPTime = ServerTimeStamp;
	}
}

simulated function float GetMoverFireZOffset(optional bool bFullPing) {
	local float Latency;
	local float TargetTimeStamp;
	local ST_MoverDummy MD;
	local vector HistoricalLoc;

	if (Mover(Base) == None || PlayerReplicationInfo == None)
		return 0.0;

	if (bFullPing)
		Latency = PlayerReplicationInfo.Ping * 0.001 * Level.TimeDilation;
	else
		Latency = PlayerReplicationInfo.Ping * 0.0005 * Level.TimeDilation;

	if (zzUTPure != None) {
		MD = zzUTPure.FindMoverDummy(Mover(Base));
		if (MD != None) {
			TargetTimeStamp = Level.TimeSeconds - Latency;
			HistoricalLoc = MD.GetHistoricalLocation(TargetTimeStamp);
			ClientDebugMessage("MoverZOffset: history="$int(Base.Location.Z - HistoricalLoc.Z)$" linear="$int(Base.Velocity.Z * Latency)$" ping="$PlayerReplicationInfo.Ping$" velZ="$int(Base.Velocity.Z));
			return Base.Location.Z - HistoricalLoc.Z;
		}
	}

	ClientDebugMessage("MoverZOffset: fallback linear="$int(Base.Velocity.Z * Latency)$" ping="$PlayerReplicationInfo.Ping);
	return Base.Velocity.Z * Latency;
}

function IGPlus_BeforeTranslocate() {
	TlocPrevLocation = Location;
}

function IGPlus_AfterTranslocate() {
	IGPlus_DidTranslocate = (VSize(Location - TlocPrevLocation) > 1);
	if (IGPlus_DidTranslocate) {
		ExtrapolationDiscardData();
		IGPlus_NotifiedTranslocate = false;
	}
}

function IGPlus_ApplyServerMove(IGPlus_ServerMove SM) {
	local float ServerDeltaTime;
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
	local float V4FirePressPos;
	local float V4FireReleasePos;
	local bool bFired;
	local bool bForceFire;

	local int AltFireIndex;
	local float AltFirePos;
	local float V4AltPressPos;
	local float V4AltReleasePos;
	local bool bAltFired;
	local bool bForceAltFire;

	local bool bDetFallback;
	local IGPlus_WeaponImplementationBase WImpBase;
	local bool bV4WeaponSupported;
	local bool bV4WeaponIsEightball;
	local bool bV4MoveHasEightballInstant;
	local bool bV4EightballInstant;
	local bool bV4HandledStep;
	local bool bV4BlockLegacyFire;
	local bool bStepFireHeld;
	local bool bStepAltHeld;
	local bool bStepForceFire;
	local bool bStepForceAltFire;
	local float StepTS;
	local rotator StepView;
	local vector StepLoc;
	local Weapon V4Weapon;
	local int V4Flags;
	local bool bV4HasEdgeTimeline;
	local bool bV4FireStartHeld;
	local bool bV4FireEndHeld;
	local bool bV4AltStartHeld;
	local bool bV4AltEndHeld;
	local int V4FirePressIndex;
	local int V4FireReleaseIndex;
	local int V4AltPressIndex;
	local int V4AltReleaseIndex;
	local bool bV4HasShotPack;
	local ST_UT_Eightball V4PackEightball;

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

	ClientTlocCounter =          (SM.MiscData & 0x0C000000) >> 26;
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

	if (zzUTPure.Settings.bEnableWarpFix && ServerDeltaTime > zzUTPure.Settings.WarpFixDelay) {
		IGPlus_SkipMovesUntilNextTick = true;
	}

	bV4HasShotPack = SM.bUseV4 && ((SM.V4Flags & IGPLUS_V4FLAG_EB_SHOTPACK_PRESENT) != 0);
	if (bWasPaused == false && IGPlus_SkipMovesUntilNextTick == false) {
		// Old-move data is populated on shot-pack moves too (pack rides V4AuxData).
		if (IGPlus_OldServerMove(SM.TimeStamp, SM.OldMoveData1, SM.OldMoveData2)) {
			xxFakeCAP(CurrentTimeStamp);
			LastCAPTime = Level.TimeSeconds;
		}
	}

	if (ServerTimeStamp == 0.0) {
		DeltaTime = SM.MoveDeltaTime;
	} else {
		DeltaTime = SM.TimeStamp - CurrentTimeStamp;
		if (Level.Pauser == "" && bWasPaused)
			DeltaTime = FMin(DeltaTime, SM.MoveDeltaTime);
	}

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
			DeltaTime = 0;
			ClientDebugMessage("["$Level.TimeSeconds$"]"@PlayerReplicationInfo.PlayerName@"MaxTimeMargin exceeded ("$TimeMargin$")", 'IGPlus');
		}
	}

	bHaveReceivedServerMove = true;
	LastServerMoveParams.Location = SM.ClientLocation;
	LastServerMoveParams.Base = SM.ClientBase;
	LastServerMoveParams.Physics = ClientPhysics;
	LastServerMoveParams.TlocCounter = ClientTlocCounter;

	// View components
	ViewPitch = (SM.View >>> 16);
	ViewYaw = (SM.View & 0xFFFF);

	NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	bJumpStatus = NewbJumpStatus;

	if ((Level.Pauser == "") && (DeltaTime > 0)) {
		UndoExtrapolation();

		if (RemoteRole == ROLE_AutonomousProxy && zzUTPure.Settings.bEnablePingCompensatedSpawn) {
			if (bHidden && (IsInState('PlayerWalking') || IsInState('PlayerSwimming'))) {
				bClientDead = false;
				bHidden = false;
				SetCollision(true, true, true);
				IGPlus_SendRespawnNoficiation();
			}
		}
	}

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

	IGPlus_V4TrackPendingWeapon(CurrentTimeStamp);

	WImpBase = IGPlus_GetWeaponImplementationBase();
	// bDetReady marks client-predicted steps; trust is the binding/window gates.
	V4Weapon = IGPlus_V4ResolveBoundWeapon(SM.V4WeaponIndex, true);
	bV4WeaponSupported = SM.bUseV4 && WImpBase != none && V4Weapon != none;
	bV4WeaponIsEightball = bV4WeaponSupported && ST_UT_Eightball(V4Weapon) != none;
	// The instant bit is only encoded on eightball-bound moves.
	bV4MoveHasEightballInstant = SM.bUseV4
		&& IGPlus_IsV4WeaponIndexEightball(SM.V4WeaponIndex)
		&& ST_UT_Eightball(V4Weapon) != none;
	// Hard-block legacy fire fallback for deterministic v4 weapons.
	// A resolved V4Weapon is active by construction.
	bV4BlockLegacyFire = (V4Weapon != none) || IGPlus_IsV4ActiveWeapon(Weapon);
	bV4HasEdgeTimeline = false;
	bV4FireStartHeld = bFired && FireIndex < 0;
	bV4FireEndHeld = bFired;
	bV4AltStartHeld = bAltFired && AltFireIndex < 0;
	bV4AltEndHeld = bAltFired;
	V4FirePressIndex = -1;
	V4FireReleaseIndex = -1;
	V4AltPressIndex = -1;
	V4AltReleaseIndex = -1;
	bV4EightballInstant = false;
	if (bFired && FireIndex >= 0)
		V4FirePressIndex = FireIndex;
	if (bAltFired && AltFireIndex >= 0)
		V4AltPressIndex = AltFireIndex;

	if (SM.bUseV4) {
		V4Flags = SM.V4Flags;
		bV4EightballInstant = (V4Flags & IGPLUS_V4FLAG_EB_INSTANT) != 0;
		bV4HasEdgeTimeline = (V4Flags & IGPLUS_V4FLAG_TIMELINE_VALID) != 0;
		if (bV4HasEdgeTimeline) {
			bV4FireStartHeld = (V4Flags & IGPLUS_V4FLAG_FIRE_START_HELD) != 0;
			bV4FireEndHeld = (V4Flags & IGPLUS_V4FLAG_FIRE_END_HELD) != 0;
			bV4AltStartHeld = (V4Flags & IGPLUS_V4FLAG_ALT_START_HELD) != 0;
			bV4AltEndHeld = (V4Flags & IGPLUS_V4FLAG_ALT_END_HELD) != 0;

			V4FirePressIndex = IGPlus_V4FlagDecodeIndex(V4Flags, IGPLUS_V4FLAG_HAS_FIRE_PRESS, IGPLUS_V4FLAG_FIRE_PRESS_SHIFT);
			V4FireReleaseIndex = IGPlus_V4FlagDecodeIndex(V4Flags, IGPLUS_V4FLAG_HAS_FIRE_RELEASE, IGPLUS_V4FLAG_FIRE_RELEASE_SHIFT);
			V4AltPressIndex = IGPlus_V4FlagDecodeIndex(V4Flags, IGPLUS_V4FLAG_HAS_ALT_PRESS, IGPLUS_V4FLAG_ALT_PRESS_SHIFT);
			V4AltReleaseIndex = IGPlus_V4FlagDecodeIndex(V4Flags, IGPLUS_V4FLAG_HAS_ALT_RELEASE, IGPLUS_V4FLAG_ALT_RELEASE_SHIFT);
		}
		if (bV4HasShotPack) {
			// Resolve the pack's eightball via binding rules; ack only applied packs.
			if (!bV4WeaponIsEightball) {
				V4PackEightball = ST_UT_Eightball(IGPlus_V4WeaponByIndex(IGPLUS_V4WEAPON_Eightball));
				if (!IGPlus_V4ServerBindingValid(V4PackEightball)
					|| !IGPlus_IsV4ActiveWeapon(V4PackEightball))
					V4PackEightball = none;
			}
			if (bV4WeaponIsEightball || V4PackEightball != none) {
				IGPlus_ServerRegisterEightballShotSeq(SM.V4AuxData & 0xFF);
				IGPlus_ClientEightballShotAck(byte(IGPlus_EBShotRecvBase & 255), IGPlus_EBShotRecvMask);
			}
		}
	}

	IGPlus_LastFireEndHeld = bV4FireEndHeld;
	IGPlus_LastAltEndHeld = bV4AltEndHeld;

	// Whole-move dispatch for transports without sub-step data (v3 moves).
	bDetFallback = !bV4WeaponSupported && V4Weapon != none;

	if (bDetFallback) {
			IGPlus_V4ProcessWeaponStep(
				V4Weapon,
				SM.TimeStamp,
				ViewRotation,
				Location,
			bFired,
			bAltFired,
			bForceFire,
				bForceAltFire,
				true,
				SM.bDetReady,
				SM.V4ChargeData,
				bV4MoveHasEightballInstant,
				bV4EightballInstant
			);
		// Deterministic weapons execute shots directly from step processing.
		// Keep fire latches cleared to avoid legacy state-machine refire.
		bFire = 0;
		bAltFire = 0;
	}

	// Complete fast weapon switch after V4 dispatch so V4 targets the
	// pre-switch weapon the client was actually firing.
	if (IGPlus_UseFastWeaponSwitch && PendingWeapon != None)
		ChangedWeapon();

	// Predict new position
	if ((Level.Pauser == "") && (DeltaTime > 0) && (IGPlus_SkipMovesUntilNextTick == false)) {
		if (zzUTPure.Settings.bEnableJitterBounding && DeltaTime > zzUTPure.Settings.MaxJitterTime) {
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
			if (V4FirePressIndex >= 0)
				V4FirePressPos = float(V4FirePressIndex) / float(MergeCount);
			if (V4FireReleaseIndex >= 0)
				V4FireReleasePos = float(V4FireReleaseIndex) / float(MergeCount);
			if (V4AltPressIndex >= 0)
				V4AltPressPos = float(V4AltPressIndex) / float(MergeCount);
			if (V4AltReleaseIndex >= 0)
				V4AltReleasePos = float(V4AltReleaseIndex) / float(MergeCount);

			MergeCount = int(DeltaTime * 100) + 1;
			SimStep = DeltaTime / float(MergeCount);

			JumpIndex = int(JumpPos * MergeCount);
			DodgeIndex = int(DodgePos * MergeCount);
			RunChangeIndex = int(RunChangePos * MergeCount);
			DuckChangeIndex = int(DuckChangePos * MergeCount);
			FireIndex = int(FirePos * MergeCount);
			AltFireIndex = int(AltFirePos * MergeCount);
			if (V4FirePressIndex >= 0)
				V4FirePressIndex = int(V4FirePressPos * MergeCount);
			if (V4FireReleaseIndex >= 0)
				V4FireReleaseIndex = int(V4FireReleasePos * MergeCount);
			if (V4AltPressIndex >= 0)
				V4AltPressIndex = int(V4AltPressPos * MergeCount);
			if (V4AltReleaseIndex >= 0)
				V4AltReleaseIndex = int(V4AltReleasePos * MergeCount);
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

			bV4HandledStep = false;
			if (bV4WeaponSupported) {
				StepTS = WImpBase.IGPlus_V4ComputeStepTimestamp(SM.TimeStamp, DeltaTime, MoveIndex, MergeCount);
				StepView = WImpBase.IGPlus_V4InterpolateStepView(SM.ViewStart, SM.View, MoveIndex, MergeCount);
				StepLoc = Location;
				if (bV4HasEdgeTimeline) {
					bStepFireHeld = IGPlus_V4HeldAtStep(
						bV4FireStartHeld,
						V4FirePressIndex,
						V4FireReleaseIndex,
						MoveIndex
					);
					bStepAltHeld = IGPlus_V4HeldAtStep(
						bV4AltStartHeld,
						V4AltPressIndex,
						V4AltReleaseIndex,
						MoveIndex
					);
				} else {
					bStepFireHeld = bFired && (FireIndex < 0 || MoveIndex >= FireIndex);
					bStepAltHeld = bAltFired && (AltFireIndex < 0 || MoveIndex >= AltFireIndex);
				}

				if (bV4HasEdgeTimeline) {
					bStepForceFire = bForceFire
						&& ((V4FirePressIndex >= 0 && MoveIndex == V4FirePressIndex)
							|| (V4FirePressIndex < 0 && MoveIndex == FireIndex));
					bStepForceAltFire = bForceAltFire
						&& ((V4AltPressIndex >= 0 && MoveIndex == V4AltPressIndex)
							|| (V4AltPressIndex < 0 && MoveIndex == AltFireIndex));
				} else {
					bStepForceFire = bForceFire && (MoveIndex == FireIndex);
					bStepForceAltFire = bForceAltFire && (MoveIndex == AltFireIndex);
				}

				if (bV4HasShotPack && bV4WeaponIsEightball) {
					bStepForceFire = false;
					bStepForceAltFire = false;
				}

						bV4HandledStep = IGPlus_V4ProcessWeaponStep(
							V4Weapon,
							StepTS,
							StepView,
							StepLoc,
						bStepFireHeld,
						bStepAltHeld,
						bStepForceFire,
							bStepForceAltFire,
							true,
							SM.bDetReady,
							SM.V4ChargeData,
							bV4MoveHasEightballInstant,
							bV4EightballInstant
						);
					if (bV4HandledStep) {
						// Deterministic shot execution is already handled in v4 step.
						// Do not feed held-fire into legacy weapon state machine.
						bFire = 0;
						bAltFire = 0;
					}
				}

			if (!bV4HandledStep && MoveIndex == FireIndex && !bDetFallback) {
				if (bV4BlockLegacyFire) {
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

				if (!bV4HandledStep && MoveIndex == AltFireIndex && !bDetFallback) {
					if (bV4BlockLegacyFire) {
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

		// Pack on a foreign-bound move: one no-input step lets falling-edge
		// self-heal resolve a lost release (charge still passes the time cap).
		if (bV4HasShotPack && !bV4WeaponIsEightball && V4PackEightball != none) {
			StepView = ViewRotation;
			if (WImpBase != none)
				StepView = WImpBase.IGPlus_V4QuantizeView(StepView);
			V4PackEightball.V4ProcessStep(
				SM.TimeStamp, StepView, Location,
				false, false, false, false,
				true, true,
				(SM.V4AuxData >>> 8) & 0x0F,
				false, false);
		}

		if (IGPlus_DidTranslocate) {
			TlocCounter = (TlocCounter + 1) & 3;
			IGPlus_DidTranslocate = false;
		}

		bWasPaused = false;
	}
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

	// Calculate how far off we allow the client to be from the predicted position
	MaxLocError = 3.0;

	clientLastUpdateTime = ServerTimeStamp;
	ClearLastServerMoveParams();

	bForceUpdate = zzbForceUpdate || (zzForceUpdateUntil >= ServerTimeStamp) ||
		(ClientLocError > MaxLocError) ||
		(ClientTlocCounter != TlocCounter && IGPlus_NotifiedTranslocate == false);

	debugClientForceUpdate = bForceUpdate;

	if (bForceUpdate) {
		ClientDebugMessage("Send CAP:"@CurrentTimeStamp@Physics@ClientPhysics@ClientLocError@MaxLocError);
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

function UndoExtrapolation() {
	if (bExtrapolatedLastUpdate) {
		bExtrapolatedLastUpdate = false;

		ExtrapolationRestoreData();
	}
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

	UndoExtrapolation();

	if (zzUTPure.Settings.bEnableJitterBounding && DeltaTime > zzUTPure.Settings.MaxJitterTime) {
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
	optional int OldMoveData2
) {
	local IGPlus_ServerMove SM;

	SM = IGPlus_CreateServerMove();

	SM.TimeStamp = TimeStamp;
	SM.bDetReady = (MoveDeltaTime & 0x01) != 0;
	SM.V4WeaponIndex = (MoveDeltaTime & 0x0E) >> 1;
	SM.V4ChargeData = (MoveDeltaTime & 0xF0) >> 4;
	SM.MoveDeltaTime = (MoveDeltaTime >>> 8) * 0.0000152587890625;
	SM.ClientAcceleration = Accel * 0.1;
	SM.ClientLocation.X = ClientLocX;
	SM.ClientLocation.Y = ClientLocY;
	SM.ClientLocation.Z = ClientLocZ;
	SM.ClientVelocity = ClientVel;
	SM.MiscData = MiscData;
	SM.MiscData2 = MiscData2;
	SM.View = View;
	SM.ViewStart = View;
	SM.V4Flags = 0;
	SM.V4AuxData = 0;
	SM.ClientBase = ClientBase;
	SM.OldMoveData1 = OldMoveData1;
	SM.OldMoveData2 = OldMoveData2;
	SM.bUseV4 = false;

	IGPlus_ApplyServerMove(SM);
	IGPlus_DestroyServerMove(SM);

	IGPlus_WarpFixUpdate = true;
}

function xxServerMove_v4(
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
	int ViewStart,
	Actor ClientBase,
	optional int V4Flags,
	optional int V4AuxData,
	optional int OldMoveData1,
	optional int OldMoveData2
) {
	local IGPlus_ServerMove SM;

	SM = IGPlus_CreateServerMove();

	SM.TimeStamp = TimeStamp;
	SM.bDetReady = (MoveDeltaTime & 0x01) != 0;
	SM.V4WeaponIndex = (MoveDeltaTime & 0x0E) >> 1;
	SM.V4ChargeData = (MoveDeltaTime & 0xF0) >> 4;
	SM.MoveDeltaTime = (MoveDeltaTime >>> 8) * 0.0000152587890625;
	SM.ClientAcceleration = Accel * 0.1;
	SM.ClientLocation.X = ClientLocX;
	SM.ClientLocation.Y = ClientLocY;
	SM.ClientLocation.Z = ClientLocZ;
	SM.ClientVelocity = ClientVel;
	SM.MiscData = MiscData;
	SM.MiscData2 = MiscData2;
	SM.View = View;
	SM.ViewStart = ViewStart;
	SM.V4Flags = V4Flags;
	SM.V4AuxData = V4AuxData;
	SM.ClientBase = ClientBase;
	SM.OldMoveData1 = OldMoveData1;
	SM.OldMoveData2 = OldMoveData2;
	SM.bUseV4 = true;

	IGPlus_ApplyServerMove(SM);
	IGPlus_DestroyServerMove(SM);

	IGPlus_WarpFixUpdate = true;
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

	if (Level.Pauser == "")
		UndoExtrapolation();

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

		ExtrapolationDelta += (ServerDeltaTime - DeltaTime);
	} else {
		ServerTimeStamp = Level.TimeSeconds;
		ExtrapolationDelta = 0.0;
	}

	if (zzUTPure.Settings.bEnableJitterBounding) {
		LostTime = -Old.TimeStamp;
		IGPlus_SavedInputChain.RemoveOutdatedNodes(CurrentTimeStamp + ExtrapolationDelta - zzUTPure.Settings.MaxJitterTime);
		Old = IGPlus_SavedInputChain.Oldest;
		LostTime += Old.TimeStamp;

		if (LostTime > 0.001)
			ClientDebugMessage("SAI LostTime"@Old.TimeStamp@CurrentTimeStamp@ExtrapolationDelta);
	}

	// Defer fast weapon switch until after PlayBackInput loop so V4
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

	if (IGPlus_UseFastWeaponSwitch && PendingWeapon != None)
		ChangedWeapon();

	// clean up
	IGPlus_SavedInputChain.RemoveOutdatedNodes(Old.TimeStamp);

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

function bool xxWeaponIsNewNet( optional bool bAlt )
{
	if (Weapon == None)
		return false;

	return (Weapon.IsA('NN_ShockRifle')
		|| Weapon.IsA('NN_SuperShockRifle')
		|| Weapon.IsA('NN_SniperRifle')
		|| Weapon.IsA('NN_ASMD')
		|| Weapon.IsA('ST_SniperRifle')
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

function bool IGPlus_IsTraceBlockedByTargetMover(
	UTPlusDummy TargetDummy,
	vector StartTrace,
	vector HitLocation
) {
	local Mover BaseMover;
	local vector HistoricalMoverLoc;

	if (TargetDummy == None || TargetDummy.Actual == None)
		return false;

	BaseMover = Mover(TargetDummy.Actual.Base);
	if (BaseMover == None)
		return false;

	// Same-base shots should not be blocked by this protection.
	if (Base == BaseMover)
		return false;

	HistoricalMoverLoc = BaseMover.Location;
	IGPlus_GetHistoricalMoverLocation(BaseMover, HistoricalMoverLoc);

	// Only guard "from below through mover" shots.
	if (StartTrace.Z >= HistoricalMoverLoc.Z || HitLocation.Z <= HistoricalMoverLoc.Z)
		return false;

	return IGPlus_LineIntersectsCylinder(
		StartTrace,
		HitLocation,
		HistoricalMoverLoc,
		BaseMover.CollisionRadius,
		BaseMover.CollisionHeight
	);
}

function float IGPlus_GetLatencyMs(optional bool bOneWay) {
	local float PingMs;

	if (PingAverage > 0)
		PingMs = float(PingAverage);
	else if (PlayerReplicationInfo != None && PlayerReplicationInfo.Ping > 0)
		PingMs = float(PlayerReplicationInfo.Ping);

	if (bOneWay)
		return FMax(0.0, 0.5 * PingMs);
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

function bool IGPlus_GetHistoricalMoverLocation(Mover M, out vector HistoricalMoverLoc) {
	// Target mover blocking uses the full compensation timeline.
	return IGPlus_GetHistoricalMoverLocationByLatency(M, IGPlus_GetLatencyMs(false), HistoricalMoverLoc);
}

function Actor TraceShot(out vector HitLocation, out vector HitNormal, vector EndTrace, vector StartTrace)
{
	local Actor A, Other;
	local bool bSProjBlocks;
	local bool bWeaponShock;
	local WeaponSettingsRepl WS;
	local UTPlusDummy D;
	local ST_ProjectileDummy PD;

	WS = GetWeaponSettings();
	
	bSProjBlocks = true;
	if (WS != none)
		bSProjBlocks = GetWeaponSettings().ShockProjectileBlockBullets;

	bWeaponShock = (Weapon != none && Weapon.IsA('ShockRifle'));

	if (WS != none && WS.bEnablePingCompensation && zzUTPure != None)
	{
		zzUTPure.CompensateFor(PingAverage, self);
		
		foreach TraceActors( class'Actor', A, HitLocation, HitNormal, EndTrace, StartTrace) {	
			if (A == self) {
				continue;
			}

				if (A.IsA('UTPlusDummy')) {
					D = UTPlusDummy(A);
					if (D != none && D.Actual != none && D.Actual != self) {
						if (D.AdjustHitLocation(HitLocation, EndTrace - StartTrace)) {
							if (IGPlus_IsTraceBlockedByTargetMover(D, StartTrace, HitLocation))
								continue;
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
					if (A == Base && Mover(A) != None && IGPlus_ShouldIgnoreOwnBaseHit(StartTrace, HitLocation))
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
		Log("Rejected Shot"@self@TimeStamp@CurrentTimeStamp, 'IGPlus');
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
			if (bbPlayer(LastKiller) != none)
				TradeTimeMargin = FMin(
					zzUTPure.Settings.MaxTradeTimeMargin,
					((AverageServerDeltaTime + TimeBetweenNetUpdates)/Level.TimeDilation +
					0.0005 * PlayerReplicationInfo.Ping * zzUTPure.Settings.TradePingMargin +
					0.0005 * (PlayerReplicationInfo.Ping - bbPlayer(LastKiller).PlayerReplicationInfo.Ping))
				);
			else
				TradeTimeMargin = zzUTPure.Settings.MaxTradeTimeMargin;

			if (RealTimeDead < TradeTimeMargin) {
				Log("["$Level.TimeSeconds$"] Traded! TradeTimeMargin="$TradeTimeMargin@"RealTimeDead="$RealTimeDead, 'IGPlus');
				Super.Fire(1);
			} else {
				Log("["$Level.TimeSeconds$"] Rejected Trade! TradeTimeMargin="$TradeTimeMargin@"RealTimeDead="$RealTimeDead, 'IGPlus');
			}
		} else {
			if (IsInState('Dying'))
				Log("["$Level.TimeSeconds$"] Traded! RealTimeDead="$RealTimeDead, 'IGPlus');
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
		Log("Rejected Shot"@self@TimeStamp@CurrentTimeStamp, 'IGPlus');
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

simulated function xxSetTeleRadius(int newRadius)
{
	TeleRadius = newRadius;
}

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
	local bool bV4Dispatch;
	local bool bBlockLegacyFire;
	local bool bInputFireHeld;
	local bool bInputAltHeld;
	local bool bInputForceFire;
	local bool bInputForceAltFire;
	local Weapon V4Weapon;

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

	V4Weapon = IGPlus_V4ResolveBoundWeapon(I.V4WeaponIndex, RemoteRole == ROLE_AutonomousProxy);
	bV4Dispatch = V4Weapon != none;
	bBlockLegacyFire = bV4Dispatch || IGPlus_IsV4ActiveWeapon(Weapon);

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

		IGPlus_V4TrackPendingWeapon(I.TimeStamp);

		if (bV4Dispatch) {
			IGPlus_V4ProcessWeaponStep(
				V4Weapon,
				I.TimeStamp,
				I.SavedViewRotation,
				Location,
				bInputFireHeld,
				bInputAltHeld,
				bInputForceFire,
				bInputForceAltFire,
				true,
				I.bDetReady,
				I.V4ChargeData,
				IGPlus_IsV4WeaponIndexEightball(I.V4WeaponIndex),
				I.bV4EightballInstant
			);
			// Keep legacy fire latches clear; the step path is authoritative.
			bFire = 0;
			bAltFire = 0;
		} else {
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

	// V4 Weapon Dispatch — add one cast block per weapon to each function.

		// Encode which V4 weapon was ready for deterministic dispatch.
	simulated function int IGPlus_GetV4WeaponIndex(Weapon W) {
		if (W == none)
			return IGPLUS_V4WEAPON_None;
		if (ST_ShockRifle(W) != none)
			return IGPLUS_V4WEAPON_ShockRifle;
		if (ST_ripper(W) != none)
			return IGPLUS_V4WEAPON_Ripper;
		if (ST_UT_FlakCannon(W) != none)
			return IGPLUS_V4WEAPON_FlakCannon;
		if (ST_ut_biorifle(W) != none)
			return IGPLUS_V4WEAPON_BioRifle;
		if (ST_UT_Eightball(W) != none)
			return IGPLUS_V4WEAPON_Eightball;
		return IGPLUS_V4WEAPON_None;
	}

// Return charge/load state for current weapon (4 bits, 0-15).
// Eightball: ClientRocketsLoaded (1-6).
// BioRifle: quantized ChargeSize (0-8 -> 0.0-4.1 in ~0.5 steps).
simulated function int IGPlus_GetV4ChargeData() {
	local ST_UT_Eightball EB;
	local ST_ut_biorifle BR;
	EB = ST_UT_Eightball(Weapon);
	if (EB != none)
		return EB.V4GetChargeDataForMove();
	BR = ST_ut_biorifle(Weapon);
	if (BR != none)
		return BR.V4CachedChargeData;
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

	simulated function bool IGPlus_IsV4WeaponIndexEightball(int Index) {
		return Index == IGPLUS_V4WEAPON_Eightball;
	}

simulated function int IGPlus_SeqForward8(int FromSeq, int ToSeq) {
	return (ToSeq - FromSeq) & 255;
}

simulated function int IGPlus_SeqBackward8(int BaseSeq, int Seq) {
	return (BaseSeq - Seq) & 255;
}

simulated function bool IGPlus_IsEightballShotAcked(int Seq, int AckBaseSeq, int AckMask) {
	local int Back;
	local int BitMask;

	Seq = Seq & 255;
	AckBaseSeq = AckBaseSeq & 255;
	if (Seq == AckBaseSeq)
		return true;

	Back = IGPlus_SeqBackward8(AckBaseSeq, Seq);
	if (Back < 1 || Back > 32)
		return false;
	BitMask = 1 << (Back - 1);
	return (AckMask & BitMask) != 0;
}

simulated function IGPlus_ClearEightballShotEntry(int Index) {
	if (Index < 0 || Index >= IGPLUS_EB_SHOT_QUEUE_SIZE)
		return;

	IGPlus_EBShotPending[Index].bActive = false;
	IGPlus_EBShotPending[Index].Seq = 0;
	IGPlus_EBShotPending[Index].ShotTS = 0.0;
	IGPlus_EBShotPending[Index].Charge = 0;
	IGPlus_EBShotPending[Index].LastSendTS = 0.0;
}

simulated function IGPlus_PruneEightballShotQueue(optional bool bForceClear) {
	local int i;
	local float NowTS;

	NowTS = 0.0;
	if (Level != none)
		NowTS = Level.TimeSeconds;

	for (i = 0; i < IGPLUS_EB_SHOT_QUEUE_SIZE; i++) {
		if (!IGPlus_EBShotPending[i].bActive)
			continue;
		if (bForceClear || (NowTS > 0.0 && NowTS - IGPlus_EBShotPending[i].ShotTS > IGPLUS_EB_SHOT_TIMEOUT))
			IGPlus_ClearEightballShotEntry(i);
	}
}

simulated function bool IGPlus_HasPendingEightballShots() {
	local int i;

	for (i = 0; i < IGPLUS_EB_SHOT_QUEUE_SIZE; i++) {
		if (IGPlus_EBShotPending[i].bActive)
			return true;
	}
	return false;
}

simulated function int IGPlus_QueueEightballAuthoritativeShot(
	float ShotTS,
	int Charge
) {
	local int i;
	local int SlotIdx;
	local int Seq;
	local int Age;
	local int OldestAge;

	IGPlus_PruneEightballShotQueue();

	Seq = IGPlus_EBShotNextSeq & 255;
	IGPlus_EBShotNextSeq = (IGPlus_EBShotNextSeq + 1) & 255;

	SlotIdx = -1;
	for (i = 0; i < IGPLUS_EB_SHOT_QUEUE_SIZE; i++) {
		if (!IGPlus_EBShotPending[i].bActive) {
			SlotIdx = i;
			break;
		}
	}

	if (SlotIdx < 0) {
		OldestAge = -1;
		for (i = 0; i < IGPLUS_EB_SHOT_QUEUE_SIZE; i++) {
			Age = IGPlus_SeqBackward8(IGPlus_EBShotNextSeq, IGPlus_EBShotPending[i].Seq);
			if (Age > OldestAge) {
				OldestAge = Age;
				SlotIdx = i;
			}
		}
	}

	if (SlotIdx < 0)
		return -1;

	IGPlus_EBShotPending[SlotIdx].bActive = true;
	IGPlus_EBShotPending[SlotIdx].Seq = Seq;
	IGPlus_EBShotPending[SlotIdx].ShotTS = ShotTS;
	IGPlus_EBShotPending[SlotIdx].Charge = Clamp(Charge, 0, 7);
	IGPlus_EBShotPending[SlotIdx].LastSendTS = 0.0;

	return Seq;
}

simulated function bool IGPlus_SelectEightballShotForMove(
	out int OutShotSeq,
	out int OutChargeBits
) {
	local int i;
	local int BestIdx;
	local int BestAge;
	local int Age;
	local float NowTS;

	OutShotSeq = 0;
	OutChargeBits = 0;

	IGPlus_PruneEightballShotQueue();

	NowTS = 0.0;
	if (Level != none)
		NowTS = Level.TimeSeconds;

	BestIdx = -1;
	BestAge = -1;
	for (i = 0; i < IGPLUS_EB_SHOT_QUEUE_SIZE; i++) {
		if (!IGPlus_EBShotPending[i].bActive)
			continue;
		if (IGPlus_EBShotPending[i].LastSendTS > 0.0 && (NowTS - IGPlus_EBShotPending[i].LastSendTS) < IGPLUS_EB_SHOT_RESEND_INTERVAL)
			continue;
		Age = IGPlus_SeqBackward8(IGPlus_EBShotNextSeq, IGPlus_EBShotPending[i].Seq);
		if (Age > BestAge) {
			BestAge = Age;
			BestIdx = i;
		}
	}

	if (BestIdx < 0)
		return false;

	OutShotSeq = IGPlus_EBShotPending[BestIdx].Seq & 255;
	OutChargeBits = Clamp(IGPlus_EBShotPending[BestIdx].Charge, 0, 7);
	IGPlus_EBShotPending[BestIdx].LastSendTS = NowTS;

	return true;
}

simulated function IGPlus_ClientEightballShotAck(byte AckBaseSeq, int AckMask) {
	local int i;
	local int Seq;

	if (Role == ROLE_Authority)
		return;

	for (i = 0; i < IGPLUS_EB_SHOT_QUEUE_SIZE; i++) {
		if (!IGPlus_EBShotPending[i].bActive)
			continue;
		Seq = IGPlus_EBShotPending[i].Seq & 255;
		if (IGPlus_IsEightballShotAcked(Seq, int(AckBaseSeq), AckMask)) {
			IGPlus_ClearEightballShotEntry(i);
		}
	}
}

function IGPlus_ServerRegisterEightballShotSeq(int Seq) {
	local int Back;
	local int Forward;
	local int BitMask;

	Seq = Seq & 255;

	if (!IGPlus_EBShotRecvInit) {
		IGPlus_EBShotRecvInit = true;
		IGPlus_EBShotRecvBase = Seq;
		IGPlus_EBShotRecvMask = 0;
		return;
	}

	if (Seq == (IGPlus_EBShotRecvBase & 255))
		return;

	Back = IGPlus_SeqBackward8(IGPlus_EBShotRecvBase, Seq);
	if (Back >= 1 && Back <= 32) {
		BitMask = 1 << (Back - 1);
		if ((IGPlus_EBShotRecvMask & BitMask) != 0)
			return;
		IGPlus_EBShotRecvMask or_eq BitMask;
		return;
	}

	if (Back > 127) {
		Forward = IGPlus_SeqForward8(IGPlus_EBShotRecvBase, Seq);
		if (Forward >= 32)
			IGPlus_EBShotRecvMask = 0;
		else
			IGPlus_EBShotRecvMask = IGPlus_EBShotRecvMask << Forward;

		if (Forward >= 1 && Forward <= 32)
				IGPlus_EBShotRecvMask or_eq 1 << (Forward - 1);

		IGPlus_EBShotRecvBase = Seq;
		return;
	}
}

// Returns the effective held state used for ServerMove_v4 fire timeline.
// Keep this bound to physical held input only. Eightball shot-time pulses
// carry queued refire intent explicitly.
simulated function bool IGPlus_V4EffectiveFireHeld() {
	return bFire != 0;
}

simulated function bool IGPlus_V4EffectiveAltHeld() {
	return bAltFire != 0;
}

	// Decode V4 weapon index back to the actual weapon in inventory.
	simulated function Weapon IGPlus_V4WeaponByIndex(int Index) {
		local Inventory Inv;
		if (Index <= IGPLUS_V4WEAPON_None)
			return none;
		for (Inv = Inventory; Inv != none; Inv = Inv.Inventory) {
			if (Index == IGPLUS_V4WEAPON_ShockRifle && ST_ShockRifle(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_V4WEAPON_Ripper && ST_ripper(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_V4WEAPON_FlakCannon && ST_UT_FlakCannon(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_V4WEAPON_BioRifle && ST_ut_biorifle(Inv) != none)
				return Weapon(Inv);
			if (Index == IGPLUS_V4WEAPON_Eightball && ST_UT_Eightball(Inv) != none)
				return Weapon(Inv);
		}
		return none;
	}

// The move's binding must be the equipped weapon, the pending weapon, or the
// grace weapon just switched away from. This is the hard trust boundary.
function bool IGPlus_V4ServerBindingValid(Weapon W) {
	if (W == none)
		return false;
	if (W.Owner != self)
		return false;
	if (W == Weapon || W == PendingWeapon)
		return true;
	return W == IGPlus_V4PrevWeapon && CurrentTimeStamp <= IGPlus_V4PrevWeaponUntilTS;
}

// Binding, then activation; none if any gate fails.
simulated function Weapon IGPlus_V4ResolveBoundWeapon(int V4Index, bool bServerContext) {
	local Weapon W;

	if (V4Index != IGPLUS_V4WEAPON_None)
		W = IGPlus_V4WeaponByIndex(V4Index);
	else
		W = IGPlus_FindV4SupportedWeapon(Weapon);
	if (bServerContext && !IGPlus_V4ServerBindingValid(W))
		W = none;
	if (!IGPlus_IsV4ActiveWeapon(W))
		W = none;
	return W;
}

// The player has committed to switching away from W (or W is going down).
simulated function bool IGPlus_V4SwitchAwayFrom(Weapon W) {
	if (!IGPlus_IsV4ActiveWeapon(W))
		return false;
	if (IGPlus_IsDeterministicSwitchGuardActive())
		return true;
	if (ClientPending != none && ClientPending != W)
		return true;
	if (Weapon != W)
		return true;
	if (PendingWeapon != none && PendingWeapon != W)
		return true;
	if (W.bChangeWeapon)
		return true;
	return W.IsInState('DownWeapon') || W.IsInState('ClientDown');
}

// Bring-up gate, honest-client floor: 0.12s fast-switch guard, else a
// conservative fraction of any select anim.
simulated function float IGPlus_V4EntryGateSeconds() {
	if (IGPlus_UseFastWeaponSwitch)
		return 0.12;
	return 0.25;
}

// Drop switch-related v4 trust state (called on death and respawn).
function IGPlus_V4ClearSwitchTrustState() {
	local Inventory Item;

	IGPlus_V4PrevWeapon = none;
	IGPlus_V4PrevWeaponUntilTS = 0;
	IGPlus_V4PrevWeaponStepTS = 0;
	IGPlus_V4WeaponGateTS = 0;
	IGPlus_V4PendingSeen = none;
	IGPlus_V4PendingSeenTS = 0;
	IGPlus_LastFireEndHeld = false;
	IGPlus_LastAltEndHeld = false;

	for (Item = Inventory; Item != none; Item = Item.Inventory) {
		if (ST_ShockRifle(Item) != none)
			ST_ShockRifle(Item).V4ResetDeterministicState();
		else if (ST_ripper(Item) != none)
			ST_ripper(Item).V4ResetDeterministicState();
		else if (ST_UT_FlakCannon(Item) != none)
			ST_UT_FlakCannon(Item).V4ResetDeterministicState();
		else if (ST_ut_biorifle(Item) != none)
			ST_ut_biorifle(Item).V4ResetDeterministicState();
		else if (ST_UT_Eightball(Item) != none)
			ST_UT_Eightball(Item).V4ResetDeterministicState();
	}
}

// Observe PendingWeapon transitions from move processing.
function IGPlus_V4TrackPendingWeapon(float NowTS) {
	if (PendingWeapon == IGPlus_V4PendingSeen)
		return;
	// Canceling a switch re-arms the bring-up; toggling is never free.
	if (IGPlus_V4PendingSeen != none && PendingWeapon == none)
		IGPlus_V4WeaponGateTS = FMax(IGPlus_V4WeaponGateTS, NowTS + IGPlus_V4EntryGateSeconds());
	IGPlus_V4PendingSeen = PendingWeapon;
	if (PendingWeapon != none && PendingWeapon != Weapon)
		IGPlus_V4PendingSeenTS = NowTS;
}

// WHEN the bound weapon may step; binding validity covers WHICH.
simulated function bool IGPlus_V4FireWindowOpen(Weapon W, float StepTS) {
	if (W == none)
		return false;
	if (W == Weapon) {
		if (StepTS < IGPlus_V4WeaponGateTS)
			return false;
		// A pending switch closes the equipped window (0.12s in-flight slack).
		if (PendingWeapon != none && PendingWeapon != W
			&& StepTS > IGPlus_V4PendingSeenTS + 0.12)
			return false;
		return true;
	}
	if (W == PendingWeapon)
		return StepTS >= IGPlus_V4PendingSeenTS + IGPlus_V4EntryGateSeconds();
	if (W == IGPlus_V4PrevWeapon) {
		// Grace accepts in-flight pre-switch steps only.
		return StepTS < IGPlus_V4PrevWeaponStepTS;
	}
	// Fail closed; unreachable after binding validation.
	return false;
}

simulated function bool IGPlus_V4SupportsWeapon(Weapon W) {
	return IGPlus_GetV4WeaponIndex(W) != IGPLUS_V4WEAPON_None;
}

function IGPlus_V4HandleOutOfAmmo(Weapon W) {
	StopFiring();
	if (PendingWeapon == none || PendingWeapon == W)
		SwitchToBestWeapon();
}

// 0 = no shot, 1 = primary, 2 = alt.
simulated function int IGPlus_V4IntervalShotDue(
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
	local bool bAlt;

	bWantsPrimary = bFireHeld || bForceFire;
	bWantsAlt = bAltHeld || bForceAlt;
	if (!bWantsPrimary && !bWantsAlt)
		return 0;
	if (StepTS + 0.0001 < NextFireTS)
		return 0;

	bAlt = bWantsAlt && !bWantsPrimary;
	if (bAlt)
		ShotInterval = AltInterval;
	else
		ShotInterval = PrimaryInterval;
	if (bAlt)
		return 2;
	return 1;
}

simulated function bool IGPlus_V4IsWeaponReady(Weapon W) {
	local Pawn PawnOwner;
	local TournamentPlayer TP;
	local TournamentWeapon TW;
	local bbPlayer BP;

	if (!IGPlus_IsV4ActiveWeapon(W))
		return false;

	PawnOwner = Pawn(W.Owner);
	if (PawnOwner == none)
		return false;

	BP = bbPlayer(PawnOwner);
	if (BP != none && BP.IGPlus_IsDeterministicSwitchGuardActive())
		return false;

	TP = TournamentPlayer(PawnOwner);
	if (TP != none && TP.ClientPending != none && TP.ClientPending != W)
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

simulated function bool IGPlus_IsV4ActiveWeapon(optional Weapon W) {
	local ST_ShockRifle SR;
	local ST_ripper RP;
	local ST_UT_FlakCannon FC;
	local ST_ut_biorifle BR;
	local ST_UT_Eightball EB;

	if (W == none)
		return false;

	SR = ST_ShockRifle(W);
	if (SR != none)
		return SR.IsV4Active();
	RP = ST_ripper(W);
	if (RP != none)
		return RP.IsV4Active();
	FC = ST_UT_FlakCannon(W);
	if (FC != none)
		return FC.IsV4Active();
	BR = ST_ut_biorifle(W);
	if (BR != none)
		return BR.IsV4Active();
	EB = ST_UT_Eightball(W);
	if (EB != none)
		return EB.IsV4Active();

	return false;
}

simulated function bool IGPlus_V4ProcessWeaponStep(
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
	optional int V4ChargeData,
	optional bool bHasEightballInstant,
	optional bool bEightballInstant
) {
	local ST_ShockRifle SR;
	local ST_ripper RP;
	local ST_UT_FlakCannon FC;
	local ST_ut_biorifle BR;
	local ST_UT_Eightball EB;
	local IGPlus_WeaponImplementationBase WImpBase;

	if (W == none)
		return false;

	// Inactive weapon: not handled here, legacy fire must run.
	if (!IGPlus_IsV4ActiveWeapon(W))
		return false;

	// Closed window: no fire intent; switched-away charge weapons get one
	// no-input step to settle an in-flight load.
	if (bServerSide && !IGPlus_V4FireWindowOpen(W, StepTS)) {
		EB = ST_UT_Eightball(W);
		if (EB != none && EB.V4HasSwitchAwayRequest())
			return EB.V4ProcessStep(
				StepTS, StepView, StepLoc,
				false, false, false, false,
				true, false, V4ChargeData,
				bHasEightballInstant, bEightballInstant);
		BR = ST_ut_biorifle(W);
		if (BR != none && BR.bV4WasAltHeld && IGPlus_V4SwitchAwayFrom(BR))
			return BR.V4ProcessStep(
				StepTS, StepView, StepLoc,
				false, false, false, false,
				true, false, V4ChargeData);
		return true;
	}

	// A pending weapon cannot be client-vouched until it is equipped.
	if (bServerSide && W != Weapon && W == PendingWeapon)
		bClientPredictedStep = false;

	WImpBase = IGPlus_GetWeaponImplementationBase();
	if (WImpBase != none)
		StepView = WImpBase.IGPlus_V4QuantizeView(StepView);

	SR = ST_ShockRifle(W);
	if (SR != none)
		return SR.V4ProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	RP = ST_ripper(W);
	if (RP != none)
		return RP.V4ProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	FC = ST_UT_FlakCannon(W);
	if (FC != none)
		return FC.V4ProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep);

	BR = ST_ut_biorifle(W);
	if (BR != none)
		return BR.V4ProcessStep(StepTS, StepView, StepLoc, bFireHeld, bAltHeld, bForceFire, bForceAlt, bServerSide, bClientPredictedStep, V4ChargeData);

	EB = ST_UT_Eightball(W);
	if (EB != none)
		return EB.V4ProcessStep(
			StepTS,
			StepView,
			StepLoc,
			bFireHeld,
			bAltHeld,
			bForceFire,
			bForceAlt,
			bServerSide,
			bClientPredictedStep,
			V4ChargeData,
			bHasEightballInstant,
			bEightballInstant
		);

	return false;
}

simulated function int IGPlus_V4FlagDecodeIndex(int V4Flags, int PresenceMask, int Shift) {
	if ((V4Flags & PresenceMask) == 0)
		return -1;
	return (V4Flags >>> Shift) & IGPLUS_V4FLAG_INDEX_MASK;
}

simulated function bool IGPlus_V4HeldAtStep(
	bool bStartHeld,
	int PressIndex,
	int ReleaseIndex,
	int MoveIndex
) {
	local bool bHeld;

	bHeld = bStartHeld;

	if (PressIndex >= 0 && ReleaseIndex >= 0) {
		if (PressIndex < ReleaseIndex) {
			if (MoveIndex >= PressIndex && MoveIndex < ReleaseIndex)
				return true;
			if (MoveIndex >= ReleaseIndex)
				return false;
			return bHeld;
		}
		if (ReleaseIndex < PressIndex) {
			if (MoveIndex >= ReleaseIndex && MoveIndex < PressIndex)
				return false;
			if (MoveIndex >= PressIndex)
				return true;
			return bHeld;
		}
		return bHeld;
	}

	if (PressIndex >= 0 && MoveIndex >= PressIndex)
		bHeld = true;
	if (ReleaseIndex >= 0 && MoveIndex >= ReleaseIndex)
		bHeld = false;
	return bHeld;
}

simulated function Weapon IGPlus_FindV4SupportedWeapon(optional Weapon Preferred) {
	if (IGPlus_V4SupportsWeapon(Preferred))
		return Preferred;
	return none;
}

simulated function IGPlus_MarkDeterministicSwitchGuard(optional float GuardSeconds) {
	if (Level == none)
		return;
	if (GuardSeconds <= 0.0)
		GuardSeconds = 0.12;
	IGPlus_DeterministicSwitchGuardUntil = FMax(
		IGPlus_DeterministicSwitchGuardUntil,
		Level.TimeSeconds + GuardSeconds
	);
}

simulated function bool IGPlus_IsDeterministicSwitchGuardActive() {
	return Level != none && Level.TimeSeconds < IGPlus_DeterministicSwitchGuardUntil;
}

simulated function bool IGPlus_IsV4DetReady(optional Weapon Preferred) {
	local Weapon Candidate;

	Candidate = IGPlus_FindV4SupportedWeapon(Preferred);
	if (Candidate == none)
		return false;

	return IGPlus_V4IsWeaponReady(Candidate);
}

function IGPlus_V4FillMoveBinding(IGPlus_SavedMove M) {
	M.bDetReady = IGPlus_IsV4DetReady(Weapon);
	if (M.bDetReady) {
		M.V4WeaponIndex = IGPlus_GetV4WeaponIndex(Weapon);
		M.V4ChargeData = IGPlus_GetV4ChargeData();
		M.bV4EightballInstant = IGPlus_IsV4WeaponIndexEightball(M.V4WeaponIndex)
			&& IGPlus_IsEightballInstantMode(Weapon);
	} else {
		M.V4WeaponIndex = IGPLUS_V4WEAPON_None;
		M.V4ChargeData = 0;
		M.bV4EightballInstant = false;
	}
}

simulated function int IGPlus_V4EncodeEdgeIndex(
	int Flags,
	int EdgeIndex,
	int PresenceMask,
	int Shift
) {
	if (EdgeIndex < 0)
		return Flags;
	return Flags | PresenceMask | ((EdgeIndex & IGPLUS_V4FLAG_INDEX_MASK) << Shift);
}

simulated function bool IGPlus_V4RecordEdge(
	bool bWasHeld,
	bool bHeld,
	int EdgeIndex,
	out int PressIndex,
	out int ReleaseIndex
) {
	if (bWasHeld == bHeld)
		return false;
	if (bWasHeld) {
		if (ReleaseIndex >= 0)
			return true;
		ReleaseIndex = EdgeIndex;
	} else {
		if (PressIndex >= 0)
			return true;
		PressIndex = EdgeIndex;
	}
	return false;
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
	local bool bCurrentFireHeld;
	local bool bCurrentAltHeld;
	local bool bCurrentEightballInstant;

	if (Pending.IGPlus_MergeCount >= 31)
		return false;

	// Keep deterministic-ready epochs isolated per move. Merging across a
	// ready<->not-ready transition can produce client-only predicted shock shots
	// when switching away during fire spam.
	if (Pending.bDetReady || IGPlus_FindV4SupportedWeapon(Weapon) != none) {
		bCurrentDetReady = IGPlus_IsV4DetReady(Weapon);
		if (bCurrentDetReady != Pending.bDetReady)
			return false;
	}

	// V4 step processing requires accurate fire/alt hold intervals. Allow at
	// most two transitions per merged move (press and release). Split before a
	// third transition would make edge timing ambiguous.
	if (Pending.bUseServerMoveV4 && Pending.bDetReady) {
		bCurrentFireHeld = IGPlus_V4EffectiveFireHeld();
		bCurrentAltHeld = IGPlus_V4EffectiveAltHeld();

		// Eightball timing is edge-sensitive (load start/release fire).
		// Never merge across a hold-state transition so edge timestamps are
		// quantized to a single frame instead of an arbitrarily long merged move.
			if (IGPlus_IsV4WeaponIndexEightball(Pending.V4WeaponIndex)) {
				bCurrentEightballInstant = IGPlus_IsEightballInstantMode(Weapon);
				if (Pending.bV4EightballInstant != bCurrentEightballInstant)
					return false;
			if (Pending.bV4FireEndHeld != bCurrentFireHeld)
				return false;
			if (Pending.bV4AltEndHeld != bCurrentAltHeld)
				return false;
		}

		if (Pending.bV4FireEndHeld != bCurrentFireHeld
			&& Pending.V4FirePressIndex >= 0
			&& Pending.V4FireReleaseIndex >= 0)
			return false;

		if (Pending.bV4AltEndHeld != bCurrentAltHeld
			&& Pending.V4AltPressIndex >= 0
			&& Pending.V4AltReleaseIndex >= 0)
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
	local bool bCurrentEightballInstant;
	local int EdgeIndex;

	PendMove.TimeStamp = Level.TimeSeconds;
	PendMove.IGPlus_MergeCount += 1;
	PendMove.bUseServerMoveV4 = PendMove.bUseServerMoveV4
		|| ((IGPlus_EnableInputReplication == false) && (int(Level.ServerMoveVersion) >= 4));

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

	if (ST_UT_Eightball(Weapon) != none && PendMove.bUseServerMoveV4) {
		bForceFireTap = false;
		bForceAltTap = false;
	} else {
		bForceFireTap = bJustFired;
		bForceAltTap = bJustAltFired;
	}

	// Keep merged hold bits aligned with suppression-aware effective held state.
	bCurrentFireHeld = IGPlus_V4EffectiveFireHeld();
	bCurrentAltHeld = IGPlus_V4EffectiveAltHeld();

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
	EdgeIndex = PendMove.IGPlus_MergeCount;

	if (PendMove.bUseServerMoveV4) {
		bCurrentEightballInstant = IGPlus_IsEightballInstantMode(Weapon);
			if (IGPlus_IsV4WeaponIndexEightball(PendMove.V4WeaponIndex))
				PendMove.bV4EightballInstant = bCurrentEightballInstant;
			else
				PendMove.bV4EightballInstant = false;

		if (bForceFireTap)
			PendMove.bV4FireStartHeld = false;
		if (bForceAltTap)
			PendMove.bV4AltStartHeld = false;

		if (IGPlus_V4RecordEdge(PendMove.bV4FireEndHeld, bCurrentFireHeld, EdgeIndex, PendMove.V4FirePressIndex, PendMove.V4FireReleaseIndex))
			bForcePacketSplit = true;
		PendMove.bV4FireEndHeld = bCurrentFireHeld;

		if (IGPlus_V4RecordEdge(PendMove.bV4AltEndHeld, bCurrentAltHeld, EdgeIndex, PendMove.V4AltPressIndex, PendMove.V4AltReleaseIndex))
			bForcePacketSplit = true;
		PendMove.bV4AltEndHeld = bCurrentAltHeld;
	}

	// Maintain deterministic-ready based on current merged slice state.
	IGPlus_V4FillMoveBinding(PendMove);

	PendMove.Delta = TotalTime;
}

function IGPlus_ReplicateInput(float Delta) {
	local float RealDelta;
	local IGPlus_SavedInput ReferenceInput;
	local IGPlus_SavedInput NewestInput;
	local IGPlus_SavedInput SerializedInput;
	local Weapon V4Weapon;
	local vector NewOffset, TargetLoc;
	local ReplBuffer B;
	local int i;

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

	// Run deterministic local prediction only for inputs that are actually
	// Serialized/sent. This prevents client-only predicted shots from unsent
	// local slices during rapid switch/fire races.
	// Resolve V4Weapon per-input using V4WeaponIndex so that a weapon switch
	// mid-batch doesn't cause the wrong weapon to fire (e.g. Ripper razor
	// predicted when the input was actually for ShockRifle).
		if (ReferenceInput != none) {
			for (SerializedInput = ReferenceInput.Next; SerializedInput != none; SerializedInput = SerializedInput.Next) {
				if (!SerializedInput.bDetPredictedLocal && SerializedInput.bDetReady) {
						if (SerializedInput.V4WeaponIndex != IGPLUS_V4WEAPON_None)
							V4Weapon = IGPlus_V4WeaponByIndex(SerializedInput.V4WeaponIndex);
					else
						V4Weapon = IGPlus_FindV4SupportedWeapon(Weapon);
					if (V4Weapon != none) {
						IGPlus_V4ProcessWeaponStep(
							V4Weapon,
							SerializedInput.TimeStamp,
							SerializedInput.SavedViewRotation,
							SerializedInput.SavedLocation,
						SerializedInput.bFire,
						SerializedInput.bAFir,
							SerializedInput.bForceFireTap,
								SerializedInput.bForceAltTap,
							false,
							SerializedInput.bDetReady,
							SerializedInput.V4ChargeData,
							IGPlus_IsV4WeaponIndexEightball(SerializedInput.V4WeaponIndex),
							SerializedInput.bV4EightballInstant
						);
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

	if ( (Weapon != None) && !Weapon.IsAnimating() )
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

function xxReplicateMove(
	float DeltaTime,
	vector NewAccel,
	eDodgeDir DodgeMove,
	rotator DeltaRot
) {
	local IGPlus_SavedMove NewMove, OldMove, LastMove, PendMove;
	local EPhysics OldPhys;
	local float AdjustAlpha;
	local float RealDelta;
	local vector OldAccel;
	local Weapon V4LocalWeapon;
	local bool bLocalEightball;
	local bool bMoveFireHeld;
	local bool bMoveAltHeld;
	local bool bForceFireTap;
	local bool bForceAltTap;

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

	// Predict per slice, gated on readiness only — a ServerMoveVersion gate
	// here kills client effects on v3 servers (input-rep predicts per node).
	if (IGPlus_EnableInputReplication == false) {
		V4LocalWeapon = IGPlus_FindV4SupportedWeapon(Weapon);
		if (V4LocalWeapon != none && IGPlus_V4IsWeaponReady(V4LocalWeapon)) {
			bLocalEightball = ST_UT_Eightball(V4LocalWeapon) != none;
			bMoveFireHeld = IGPlus_V4EffectiveFireHeld();
			bMoveAltHeld = IGPlus_V4EffectiveAltHeld();
			// Merge tap rule: eightball taps ride the edge timeline.
			bForceFireTap = bJustFired && !bLocalEightball;
			bForceAltTap = bJustAltFired && !bLocalEightball;
			IGPlus_V4ProcessWeaponStep(
				V4LocalWeapon,
				Level.TimeSeconds,
				ViewRotation,
				Location,
				bMoveFireHeld,
				bMoveAltHeld,
				bForceFireTap,
				bForceAltTap,
				false,
				true,
				IGPlus_GetV4ChargeData(),
				bLocalEightball,
				IGPlus_IsEightballInstantMode(Weapon)
			);
		}
	}

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
		NewMove.IGPlus_SavedViewRotationStart = ViewRotation;
		NewMove.bUseServerMoveV4 = (IGPlus_EnableInputReplication == false) && (int(Level.ServerMoveVersion) >= 4);

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

			bMoveFireHeld = IGPlus_V4EffectiveFireHeld();
			bMoveAltHeld = IGPlus_V4EffectiveAltHeld();
			if (ST_UT_Eightball(Weapon) != none && NewMove.bUseServerMoveV4) {
				bForceFireTap = false;
				bForceAltTap = false;
			} else {
				bForceFireTap = bJustFired;
				bForceAltTap = bJustAltFired;
			}

			NewMove.bFire = (bForceFireTap || bMoveFireHeld);
			NewMove.bForceFire = bForceFireTap;
			if (LastMove == none || LastMove.bFire != NewMove.bFire)
				NewMove.FireIndex = 0;

			NewMove.bAltFire = (bForceAltTap || bMoveAltHeld);
			NewMove.bForceAltFire = bForceAltTap;
			if (LastMove == none || LastMove.bAltFire != NewMove.bAltFire)
				NewMove.AltFireIndex = 0;

			if (LastMove != none) {
				NewMove.bV4FireStartHeld = LastMove.bV4FireEndHeld;
				NewMove.bV4AltStartHeld = LastMove.bV4AltEndHeld;
			} else {
				NewMove.bV4FireStartHeld = bMoveFireHeld;
				NewMove.bV4AltStartHeld = bMoveAltHeld;
			}
				if (bForceFireTap)
					NewMove.bV4FireStartHeld = false;
				if (bForceAltTap)
					NewMove.bV4AltStartHeld = false;

			NewMove.bV4FireEndHeld = bMoveFireHeld;
			NewMove.bV4AltEndHeld = bMoveAltHeld;

		if (!NewMove.bV4FireStartHeld && NewMove.bV4FireEndHeld)
			NewMove.V4FirePressIndex = 0;
		else if (NewMove.bV4FireStartHeld && !NewMove.bV4FireEndHeld)
			NewMove.V4FireReleaseIndex = 0;

		if (!NewMove.bV4AltStartHeld && NewMove.bV4AltEndHeld)
			NewMove.V4AltPressIndex = 0;
		else if (NewMove.bV4AltStartHeld && !NewMove.bV4AltEndHeld)
			NewMove.V4AltReleaseIndex = 0;

			IGPlus_V4FillMoveBinding(NewMove);

		if ( Weapon != None ) // approximate pointing so don't have to replicate
			Weapon.bPointing = ((bFire != 0) || (bAltFire != 0));

		PendingMove = NewMove;
	} else {
		NewMove = IGPlus_SavedMove(PendingMove);
	}

	bJustFired = false;
	bJustAltFired = false;
	OldPhys = Physics;

	IGPlus_TPFix_LastTouched = none;

	// Simulate the movement locally.
	ProcessMove(DeltaTime, NewAccel, DodgeMove, DeltaRot);
	AutonomousPhysics(DeltaTime);

	CorrectTeleporterVelocity();

	NewMove.SetRotation( Rotation );
	NewMove.IGPlus_SavedViewRotation = ViewRotation;
	NewMove.IGPlus_SavedLocation = Location;
	NewMove.IGPlus_SavedVelocity = Velocity;

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	RealDelta = PendingMove.Delta / Level.TimeDilation;

	NetStatsElem.LocationError = VSize(IGPlus_AdjustLocationOffset * AdjustAlpha);
	NetStatsElem.UnconfirmedTime = (Level.TimeSeconds - CurrentTimeStamp) / Level.TimeDilation;

	if (RealDelta < TimeBetweenNetUpdates - ClientUpdateTime && CanMergeMove(NewMove, OldAccel))
		return;

	bForcePacketSplit = false;
	ClientUpdateTime = FClamp(RealDelta - TimeBetweenNetUpdates + ClientUpdateTime, -TimeBetweenNetUpdates, TimeBetweenNetUpdates);
	if ( SavedMoves == None )
		SavedMoves = PendingMove;
	else
		LastMove.NextMove = PendingMove;
	PendingMove = None;

	SendSavedMove(NewMove, OldMove);

	if ( (Weapon != None) && !Weapon.IsAnimating() )
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
	local int ViewStartPacked;
	local int V4Flags;
	local int V4AuxData;
	local int V4ShotSeq;
	local int V4ShotChargeBits;

	if (Move.bPressedJump) bJumpStatus = !bJumpStatus;

	if (Base == none)
		RelLoc = Location;
	else
		RelLoc = Location - Base.Location;

	MoveDeltaTime or_eq Clamp(int(Move.Delta * 65536), 0, 0xFFFFFF) << 8;
	if (Move.bDetReady) MoveDeltaTime or_eq 0x01;
	MoveDeltaTime or_eq (Move.V4WeaponIndex & 0x07) << 1;
	MoveDeltaTime or_eq (Move.V4ChargeData & 0x0F) << 4;

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
	ViewStartPacked = ((Move.IGPlus_SavedViewRotationStart.Pitch & 0xFFFF) << 16) | (Move.IGPlus_SavedViewRotationStart.Yaw & 0xFFFF);
	V4Flags = 0;
	V4AuxData = 0;
	V4ShotSeq = 0;
	V4ShotChargeBits = 0;
	if (bTraceInput && IGPlus_InputLogFile != none)
		IGPlus_InputLogFile.LogSavedMove(Move);
	if (Move.bUseServerMoveV4) {
		V4Flags or_eq IGPLUS_V4FLAG_TIMELINE_VALID;
			if (IGPlus_IsV4WeaponIndexEightball(Move.V4WeaponIndex) && Move.bV4EightballInstant)
				V4Flags or_eq IGPLUS_V4FLAG_EB_INSTANT;
		if (Move.bV4FireStartHeld) V4Flags or_eq IGPLUS_V4FLAG_FIRE_START_HELD;
		if (Move.bV4FireEndHeld) V4Flags or_eq IGPLUS_V4FLAG_FIRE_END_HELD;
		if (Move.bV4AltStartHeld) V4Flags or_eq IGPLUS_V4FLAG_ALT_START_HELD;
		if (Move.bV4AltEndHeld) V4Flags or_eq IGPLUS_V4FLAG_ALT_END_HELD;

		V4Flags = IGPlus_V4EncodeEdgeIndex(V4Flags, Move.V4FirePressIndex, IGPLUS_V4FLAG_HAS_FIRE_PRESS, IGPLUS_V4FLAG_FIRE_PRESS_SHIFT);
		V4Flags = IGPlus_V4EncodeEdgeIndex(V4Flags, Move.V4FireReleaseIndex, IGPLUS_V4FLAG_HAS_FIRE_RELEASE, IGPLUS_V4FLAG_FIRE_RELEASE_SHIFT);
		V4Flags = IGPlus_V4EncodeEdgeIndex(V4Flags, Move.V4AltPressIndex, IGPLUS_V4FLAG_HAS_ALT_PRESS, IGPLUS_V4FLAG_ALT_PRESS_SHIFT);
		V4Flags = IGPlus_V4EncodeEdgeIndex(V4Flags, Move.V4AltReleaseIndex, IGPLUS_V4FLAG_HAS_ALT_RELEASE, IGPLUS_V4FLAG_ALT_RELEASE_SHIFT);

			if (IGPlus_IsV4WeaponIndexEightball(Move.V4WeaponIndex) || ST_UT_Eightball(Weapon) != none || IGPlus_HasPendingEightballShots()) {
				if (IGPlus_SelectEightballShotForMove(
					V4ShotSeq,
					V4ShotChargeBits
			)) {
				V4Flags or_eq IGPLUS_V4FLAG_EB_SHOTPACK_PRESENT;
				// Pack rides V4AuxData; never touch the move's own binding/charge bits.
				V4AuxData = (V4ShotSeq & 0xFF) | ((V4ShotChargeBits & 0x0F) << 8);
			}
		}
	}

	if (Move.bUseServerMoveV4) {
		xxServerMove_v4(
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
				ViewStartPacked,
				Base,
				V4Flags,
				V4AuxData,
				OldMoveData1,
				OldMoveData2
			);
	} else {
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
			OldMoveData2
		);
	}

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

	// Stale deterministic fire intent cannot leak to another weapon: dispatch
	// requires the equipped/grace weapon binding, and the switch guard covers
	// the toss itself. Held fire resuming on the next weapon is stock behavior.
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

exec function enableDebugData(bool b) {
	bDrawDebugData = b;
	if (b) {
		ClientMessage("Debug data: on");
	} else {
		ClientMessage("Debug data: off");
	}
}

exec function EnableHitSound(bool b) {
	Settings.bEnableHitSounds = b;
	IGPlus_SaveSettings();
	if (b) {
		ClientMessage("HitSound: on");
	} else {
		ClientMessage("HitSound: off");
	}
}

exec function EnableTeamHitSound(bool b) {
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
	if (hs >= 0 && hs < 16) {
		Settings.SelectedHitSound = hs;
		IGPlus_SaveSettings();
		ClientMessage("HitSound set!");
	} else {
		ClientMessage("Please input a value from 0 to 15");
	}
}

exec function SetTeamHitSound(byte hs) {
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
    }
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
	if (sb > 0 && sb <= 4) {
		Settings.cShockBeam = sb;
		IGPlus_SaveSettings();
		ClientMessage("Shock beam set!");
	} else
		ClientMessage("Please input a value between 1 and 4");
}

exec function setBeamScale(float bs) {
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

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local Pawn PTarget;

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

	if (Role != ROLE_Authority)
		maxZ = Location.Z + (1.0 - 0.7 * DuckFractionRepl/255.0) * CollisionHeight;
	else
		maxZ = Location.Z + (1.0 - 0.7 * DuckFraction) * CollisionHeight;
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

	if (Role != ROLE_Authority)
		maxZ = Location.Z + (1.0 - 0.7 * DuckFractionRepl/255.0) * CollisionHeight;
	else
		maxZ = Location.Z + (1.0 - 0.7 * DuckFraction) * CollisionHeight; // default game is 0.25

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
	if (Physics == PHYS_Walking)
		Momentum.Z = FMax(Momentum.Z, 0.4 * VSize(Momentum));
	Super.AddVelocity(Momentum);
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

	ServerAddMomentum(momentum);
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
	if( Event != '' )
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, Killer );
	if (Weapon.IsA('TournamentWeapon'))
		TournamentWeapon(Weapon).bCanClientFire = false;
	IGPlus_V4ClearSwitchTrustState();
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
	IGPlus_ProcessRemoteMovement();
	xxRememberPosition();
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
					if (bIsCrouching || DuckFraction > 0.25)
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

	if (bIsCrouching) {
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
	exec function Fire(optional float F)
	{
		bJustFired = true;
	}

	exec function AltFire(optional float F)
	{
		bJustAltFired = true;
	}

	// Fix: Base ProcessMove only checks bJustFired, need to also check bJustAltFired
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
	{
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
		optional int OldMoveData2
	)
	{
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
			OldMoveData2);
	}

	function xxServerMove_v4
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
		int ViewStart,
		Actor ClientBase,
		optional int V4Flags,
		optional int V4AuxData,
		optional int OldMoveData1,
		optional int OldMoveData2
	)
	{
		Global.xxServerMove_v4(
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
				((Rotation.Pitch & 0xFFFF) << 16) | (Rotation.Yaw & 0xFFFF),
				ClientBase,
				V4Flags,
				V4AuxData,
				OldMoveData1,
				OldMoveData2);
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

		if ( bIsCrouching || (Physics != PHYS_Walking && Physics != PHYS_Falling) )
			return;
		if (Physics == PHYS_Falling && bCanWallDodge == false)
			return;

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
			if ((HitActor == none) || (HitActor != Level && Mover(HitActor) == none))
				return;

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
		bExtrapolatedLastUpdate = false;
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

	if (!bNewNet)
		SwitchToBestWeapon();
	else if (Best != None)
	{
		PendingWeapon = Best;
		ChangedWeapon();
	}
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
		local bool Result;

		if (RemoteRole == ROLE_AutonomousProxy && zzUTPure.Settings.bEnablePingCompensatedSpawn) {
			bDeathMatchSave = Level.Game.bDeathMatch;
			Level.Game.bDeathMatch = false; // this avoids the sound respawns generate, we will play our own later
			// see DeathMatchPlus.PlayTeleportEffect()
		}

		Level.Game.DiscardInventory(self); // last possible place to rid ourselves of old inventory
		Result = Level.Game.RestartPlayer(self);

		if (RemoteRole == ROLE_AutonomousProxy && zzUTPure.Settings.bEnablePingCompensatedSpawn)
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

			IGPlus_ClientReStart(Physics, Location, Rotation);

			IGPlus_V4ClearSwitchTrustState();
			ChangedWeapon();
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

		if (RealTimeDead > 2*zzUTPure.Settings.MaxTradeTimeMargin)
			Level.Game.DiscardInventory(self);
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
		optional int OldMoveData2
	)
	{
		Global.xxServerMove(
			TimeStamp,
			MoveDeltaTime,
			Accel,
			ClientLocX,
			ClientLocY,
			ClientLocZ,
			ClientVel,
			MiscData & 0xFFFF,
			MiscData2,
			View,
			ClientBase,
			OldMoveData1,
			OldMoveData2);
	}

	function xxServerMove_v4
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
		int ViewStart,
		Actor ClientBase,
		optional int V4Flags,
		optional int V4AuxData,
		optional int OldMoveData1,
		optional int OldMoveData2
	)
	{
		Global.xxServerMove_v4(
			TimeStamp,
			MoveDeltaTime,
			Accel,
			ClientLocX,
			ClientLocY,
			ClientLocZ,
			ClientVel,
			MiscData & 0xFFFF,
			MiscData2,
			View,
				ViewStart,
				ClientBase,
				V4Flags,
					V4AuxData,
					OldMoveData1,
					OldMoveData2);
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
		optional int OldMoveData2
	)
	{
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
			OldMoveData2);
	}

	function xxServerMove_v4
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
		int ViewStart,
		Actor ClientBase,
		optional int V4Flags,
		optional int V4AuxData,
		optional int OldMoveData1,
		optional int OldMoveData2
	)
	{
		Global.xxServerMove_v4(
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
				((ViewRotation.Pitch & 0xFFFF) << 16) | (ViewRotation.Yaw & 0xFFFF),
				ClientBase,
				V4Flags,
					V4AuxData,
					OldMoveData1,
					OldMoveData2);
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
	local float CurrentTime;

	CurrentTime = Level.TimeSeconds;
	NetStatsElem.FrameTime = DeltaTime / Level.TimeDilation;

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

	if (zzForceSettingsLevel != zzOldForceSettingsLevel)
	{
		zzOldForceSettingsLevel = zzForceSettingsLevel;
	}

	if (PureLevel != None)	// Why would this be None?!
		zzbDemoRecording = PureLevel.zzDemoRecDriver != None;

	if (!bDemoStarted && zzbGameStarted && (zzbForceDemo || Settings.bAutoDemo && (DeathMatchPlus(Level.Game) == none || DeathMatchPlus(Level.Game).CountDown < 1)))
		xxClientDemoRec();
	if (bDemoStarted && (zzbForceDemo || Settings.bAutoDemo) && GameReplicationInfo.GameEndedComments != "") {
		if (IGPlus_GameEndedTime == 0)
			IGPlus_GameEndedTime = Level.TimeSeconds;
		else if (Level.TimeSeconds >= IGPlus_GameEndedTime + 2.0)
			ConsoleCommand("StopDemo");
	}
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
			NewMesh = class'IGPlus_ModelImport'.default.DefaultMesh[Skin];
		} else {
			NewMesh = class'IGPlus_ModelImport'.default.RateCorrectedMesh[Skin];
		}
	} else {
		NewMesh = PRI.Owner.default.Mesh;
	}

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

	if (zzbForceModels) {
		Skin = GetForcedSkinForPlayer(PRI);
		SetForcedMesh(PRI, Skin);
		SetForcedSkin(PRI.Owner, Skin, GameReplicationInfo.bTeamGame, PRI.Team);
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

function bool IGPlus_ShouldUseSnapshotInterpForProxy(optional bbPlayer P) {
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

	if (IGPlus_EnableWarpFix == false)
		return;

	P = bbPlayer(PRI.Owner);
	if (IGPlus_ShouldUseSnapshotInterpForProxy(P))
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
	super.RenderOverlays(C);

	InitFlagSprites();

	if (IGPlus_AlwaysRenderDroppedFlags)
		RenderDroppedFlags(C);

	if (IGPlus_AlwaysRenderFlagCarrier)
		RenderFlagCarrier(C);

	if (IGPlus_LocationOffsetFix_DrawServerLocation)
		IGPlus_DrawServerLocations(C);
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
		IGPlus_LocationOffsetFix_ServerLocation = Location;
		IGPlus_LocationOffsetFix_ServerLocationTime = Level.TimeSeconds;
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
			else
				P.IGPlus_LocationOffsetFix_After(DeltaTime);
		}
	}

	for (D = IGPlus_LocationOffsetFix_DummyList; D != none; D = D.NextCollDummy) {
		D.bCollideWorld = false;
		D.SetCollision(false, false, false);
	}
}

// This event is only executed on Pawns with Role=ROLE_SimulatedProxy
// PlayerTick is used if Role=ROLE_AutonomousProxy or ROLE_Authority
simulated event Tick(float DeltaTime) {
	super.Tick(DeltaTime);

	// Reset on both enable and disable transitions for simulated proxies.
	if (Role == ROLE_SimulatedProxy && IGPlus_SnapInterp_EnabledLast != IGPlus_EnableSnapshotInterpolation) {
		IGPlus_SnapInterp_Reset();
	}

	if (IGPlus_ShouldUseSnapshotInterpForProxy()) {
		if (IGPlus_LocationOffsetFix_Moved)
			IGPlus_SnapInterp_After(DeltaTime);
	} else if (Settings.bEnableLocationOffsetFix || IGPlus_LocationOffsetFix_Moved) {
		IGPlus_LocationOffsetFix_After(DeltaTime);
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

	if (IGPlus_LocationOffsetFix_Moved == false)
		return;

	if (IGPlus_LocationOffsetFix_CollisionDummy != none) {
		IGPlus_LocationOffsetFix_CollisionDummy.bCollideWorld = false;
		IGPlus_LocationOffsetFix_CollisionDummy.SetCollision(false, false, false);
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

			if (IGPlus_ShouldUseSnapshotInterpForProxy(P))
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

	if (bDrawDebugData) {
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
	zzC.DrawIcon(texture'NewNetLogo',1.0);
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
	Settings.bShowFPS = !Settings.bShowFPS;
	IGPlus_SaveSettings();
	if (Settings.bShowFPS)
		ClientMessage("FPS shown!", 'IGPlus');
	else
		ClientMessage("FPS hidden!", 'IGPlus');
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
	// empty line
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
	Settings.MinDodgeClickTime = f;
	IGPlus_SaveSettings();
	ClientMessage("MinDodgeClickTime:"@f);
}

exec function SetMouseSmoothing(bool b)
{
	Settings.bNoSmoothing = !b;
	IGPlus_SaveSettings();
	if (b) ClientMessage("Mouse Smoothing enabled!");
	else   ClientMessage("Mouse Smoothing disabled!");
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
	Settings.bEnableKillCam = b;
	IGPlus_SaveSettings();
	if (b)
		ClientMessage("KillCam enabled!", 'IGPlus');
	else
		ClientMessage("KillCam disabled!", 'IGPlus');
}

exec function EndShot(optional bool b)
{
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

exec function GetWeapon(class<Weapon> NewWeaponClass )
{	// Slightly improved GetWeapon
	local Inventory Inv;

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
				return;
			}
			if (Weapon != None)
			{
				IGPlus_MarkDeterministicSwitchGuard();
				Weapon.PutDown();
			}
			return;
		}
}

exec function SwitchWeapon(byte F)
{
	local weapon newWeapon;

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
		IGPlus_MarkDeterministicSwitchGuard();
		if ( Weapon != None && !Weapon.PutDown() )
			PendingWeapon = None;
	}
}

exec function PrevWeapon()
{
	local int prevGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

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
	if ( PendingWeapon == None )
		return;

	IGPlus_MarkDeterministicSwitchGuard();
	Weapon.PutDown();
}

exec function NextWeapon()
{
	local int nextGroup;
	local Inventory inv;
	local Weapon realWeapon, w, Prev;
	local bool bFoundWeapon;

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
	if ( PendingWeapon == None )
		return;

	IGPlus_MarkDeterministicSwitchGuard();
	Weapon.PutDown();
}

simulated function ChangedWeapon() {
	if (Weapon != None && IGPlus_UseFastWeaponSwitch) {
		Weapon.GotoState('');
		IGPlus_MarkDeterministicSwitchGuard();
		ClientPutDown(none, PendingWeapon);
	}

	// Grace for in-flight steps still targeting the outgoing weapon.
	if (Role == ROLE_Authority && Weapon != None && Weapon != PendingWeapon) {
		IGPlus_V4PrevWeapon = Weapon;
		IGPlus_V4PrevWeaponUntilTS = CurrentTimeStamp + 0.25;
		IGPlus_V4PrevWeaponStepTS = CurrentTimeStamp + 0.12; // reorder jitter slack
	}

	Super.ChangedWeapon();

	if (Role == ROLE_Authority && Level.NetMode != NM_Standalone
		&& RemoteRole == ROLE_AutonomousProxy) {
		if (IGPlus_V4SupportsWeapon(Weapon)) {
			IGPlus_V4WeaponGateTS = FMax(IGPlus_V4WeaponGateTS, CurrentTimeStamp + IGPlus_V4EntryGateSeconds());
		} else {
			// v4 steps clear bFire/bAltFire; restore held state for legacy weapons.
			if (IGPlus_LastFireEndHeld)
				bFire = 1;
			else
				bFire = 0;
			if (IGPlus_LastAltEndHeld)
				bAltFire = 1;
			else
				bAltFire = 0;
		}
		IGPlus_V4PendingSeen = PendingWeapon;
	}
}

function ClientPutDown(Weapon Current, Weapon Next)
{
	IGPlus_MarkDeterministicSwitchGuard();
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
			OutMsg = OutMsg$Msg;
			Msg = "";
			continue;
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
	Settings.bAutoDemo = zzb;
	ClientMessage("Record demos automatically after countdown:"@zzb);
	IGPlus_SaveSettings();
}

exec function ShootDead()
{
	Settings.bShootDead = !Settings.bShootDead;
	if (Settings.bShootDead)
		ClientMessage("Shooting carcasses enabled.");
	else
		ClientMessage("Shooting carcasses disabled.");
	IGPlus_SaveSettings();
}

exec function SetDemoMask(optional string zzMask)
{
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
	}
}

function PlayInAir() {
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	if (Level.NetMode != NM_DedicatedServer && Settings.bReduceEyeHeightInAir)
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

exec function bEnableJitterBounding(optional string Value) {
	IGPlus_SetNetcodeSetting("bEnableJitterBounding", Value);
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
	ClientMessage("bEnableJitterBounding="$S.GetPropertyText("bEnableJitterBounding"));
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
	if (Key ~= "bEnableJitterBounding") return "bEnableJitterBounding";
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
		bOldSnap = BP.IGPlus_EnableSnapshotInterpolation;
		BP.IGPlus_EnableSnapshotInterpolation = zzUTPure.Settings.bEnableSnapshotInterpolation;

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
	IGPlus_ServerSendSetting("bRestrictTrading");
	IGPlus_ServerSendSetting("MaxTradeTimeMargin");
	IGPlus_ServerSendSetting("TradePingMargin");
	IGPlus_ServerSendSetting("KillCamDelay");
	IGPlus_ServerSendSetting("KillCamDuration");

	IGPlus_ServerSendSetting("bWarmup");
	IGPlus_ServerSendSetting("WarmupTimeLimit");
	IGPlus_ServerSendSetting("bCoaches");
	IGPlus_ServerSendSetting("Timeouts");
	IGPlus_ServerSendSetting("bFastTeams");
	IGPlus_ServerSendSetting("bUseClickboard");
	IGPlus_ServerSendSetting("bAdvancedTeamSay");
	IGPlus_ServerSendSetting("bAllowMultiWeapon");
	IGPlus_ServerSendSetting("bDelayedPickupSpawn");
	IGPlus_ServerSendSetting("bUseFastWeaponSwitch");
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
	IGPlus_ServerSendSetting("bEnableServerExtrapolation");
	IGPlus_ServerSendSetting("bPlayersAlwaysRelevant");
	IGPlus_ServerSendSetting("bEnablePingCompensatedSpawn");
	IGPlus_ServerSendSetting("bEnableJitterBounding");
	IGPlus_ServerSendSetting("bEnableSnapshotInterpolation");
	IGPlus_ServerSendSetting("SnapshotInterpSendHz");
	IGPlus_ServerSendSetting("SnapshotInterpRewindMs");
	IGPlus_ServerSendSetting("bEnableWarpFix");

	IGPlus_ServerSendSetting("MinClientRate");
	IGPlus_ServerSendSetting("MaxClientRate");
	IGPlus_ServerSendSetting("ForceSettingsLevel");

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
	IGPlus_WeaponSendSetting("bEnableSubTickCompensation");
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
	TeleRadius=210
	NN_ProjLength=256
	bIsFinishedLoading=False
	bDrawDebugData=False
	TimeBetweenNetUpdates=0.01
	FakeCAPInterval=0.1
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
