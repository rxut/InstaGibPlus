# InstaGib+
An InstaGib focussed fork of TimTim's NewNet mutator for Unreal Tournament.

1. [Features](#features)
2. [Client Settings](#client-settings)
3. [Client Commands](#client-commands)
4. [Server Installation](#server-installation)
5. [Usage](#usage)
6. [Admin Commands](#admin-commands)
6. [Server Settings](#server-settings)
7. [Building](#building)
8. [Credits](#credits)

# Features

* Reworked netcode in order to drastically reduce visible glitches when observing players on bad connections
* Working client forced models for enemies and teammates
* Working client-side hitsounds with the option to use custom hitsound packages
* Different Shock beam types (team-colored, none, instant beam)
* InstaGib and Sniper Arena with server-side hit detection and ping compensation (NextIG, NextSA)
* Fixed pop-in of enemies around corners
* Fixed delay of visible flag pick-up
* Fixed stuttering on respawn with high ping
* Fixed Bunny Jumping

# Client Settings

These settings can be found in **InstaGibPlus.ini** under section **\[ClientSettings\]**.

1. [bForceModels](#bforcemodels)
1. [DesiredSkin](#desiredskin)
1. [DesiredSkinFemale](#desiredskinfemale)
1. [DesiredTeamSkin](#desiredteamskin)
1. [DesiredTeamSkinFemale](#desiredteamskinfemale)
1. [SkinEnemyIndexMap](#skinenemyindexmap)
1. [SkinTeamIndexMap](#skinteamindexmap)
1. [bSkinEnemyUseIndexMap](#bskinenemyuseindexmap)
1. [bSkinTeamUseIndexMap](#bskinteamuseindexmap)
1. [bUnlitSkins](#bunlitskins)
1. [bEnableHitSounds](#benablehitsounds)
1. [bEnableTeamHitSounds](#benableteamhitsounds)
1. [bHitSoundPitchShift](#bhitsoundpitchshift)
1. [bHitSoundTeamPitchShift](#bhitsoundteampitchshift)
1. [HitSoundSource](#hitsoundsource)
1. [SelectedHitSound](#selectedhitsound)
1. [SelectedTeamHitSound](#selectedteamhitsound)
1. [HitSoundVolume](#hitsoundvolume)
1. [HitSoundTeamVolume](#hitsoundteamvolume)
1. [sHitSound](#shitsound)
1. [bDoEndShot](#bdoendshot)
1. [bAutoDemo](#bautodemo)
1. [DemoMask](#demomask)
1. [DemoPath](#demopath)
1. [DemoChar](#demochar)
1. [bTeamInfo](#bteaminfo)
1. [bShootDead](#bshootdead)
1. [cShockBeam](#cshockbeam)
1. [bHideOwnBeam](#bhideownbeam)
1. [bBeamEnableLight](#bbeamenablelight)
1. [BeamScale](#beamscale)
1. [BeamFadeCurve](#beamfadecurve)
1. [BeamDuration](#beamduration)
1. [BeamOriginMode](#beamoriginmode)
1. [BeamDestinationMode](#beamdestinationmode)
1. [SSRRingType](#ssrringtype)
1. [HitEffectSource](#hiteffectsource)
1. [bNoOwnFootsteps](#bnoownfootsteps)
1. [DesiredNetUpdateRate](#desirednetupdaterate)
1. [DesiredNetspeed](#desirednetspeed)
1. [FakeCAPInterval](#fakecapinterval)
1. [bCameraCorrectionSmoothing](#bcameracorrectionsmoothing)
1. [CameraCorrectionSmoothingTime](#cameracorrectionsmoothingtime)
1. [bSmoothLiftJump](#bsmoothliftjump)
1. [bSpectatorShowDamageNumbers](#bspectatorshowdamagenumbers)
1. [DamageNumberDuration](#damagenumberduration)
1. [DamageNumberFade](#damagenumberfade)
1. [bDemoShowRealModels](#bdemoshowrealmodels)
1. [bPredictedSwitching](#bpredictedswitching)
1. [bPredictedTranslocation](#bpredictedtranslocation)
1. [bPredictedDiscBoost](#bpredicteddiscboost)
1. [bSmoothDiscCorrections](#bsmoothdisccorrections)
1. [bNoSmoothing](#bnosmoothing)
1. [bLogClientMessages](#blogclientmessages)
1. [bDemoShowClientMessages](#bdemoshowclientmessages)
1. [bDebugMovement](#bdebugmovement)
1. [bShowDebugDataOnScreen](#bshowdebugdataonscreen)
1. [FlipAnimationFix](#flipanimationfix)
1. [bEnableKillCam](#benablekillcam)
1. [MinDodgeClickTime](#mindodgeclicktime)
1. [bUseOldMouseInput](#buseoldmouseinput)
1. [SmoothVRController](#smoothvrcontroller)
1. [bShowFPS](#bshowfps)
1. [FPSLocationX](#fpslocationx)
1. [FPSLocationY](#fpslocationy)
1. [FPSDetail](#fpsdetail)
1. [FPSCounterSmoothingStrength](#fpscountersmoothingstrength)
1. [KillCamMinDelay](#killcammindelay)
1. [bReduceEyeHeightInAir](#breduceeyeheightinair)
1. [bAllowWeaponShake](#ballowweaponshake)
1. [bAutoReady](#bautoready)
1. [bShowDeathReport](#bshowdeathreport)
1. [bSmoothFOVChanges](#bsmoothfovchanges)
1. [bEnableLocationOffsetFix](#benablelocationoffsetfix)
1. [bEnableKillFeed](#benablekillfeed)
1. [KillFeedX](#killfeedx)
1. [KillFeedY](#killfeedy)
1. [KillFeedSpeed](#killfeedspeed)
1. [KillFeedScale](#killfeedscale)
1. [FraggerScopeChoice](#fraggerscopechoice)
1. [bEnableNetStats](#benablenetstats)
1. [bNetStatsUnconfirmedTime](#bnetstatsunconfirmedtime)
1. [bNetStatsLocationError](#bnetstatslocationerror)
1. [bNetStatsFrameTime](#bnetstatsframetime)
1. [NetStatsLocationX](#netstatslocationx)
1. [NetStatsLocationY](#netstatslocationy)
1. [NetStatsWidth](#netstatswidth)
1. [bEnableHitMarker](#benablehitmarker)
1. [bEnableTeamHitMarker](#benableteamhitmarker)
1. [HitMarkerColorMode](#hitmarkercolormode)
1. [HitMarkerColor](#hitmarkercolor)
1. [HitMarkerTeamColor](#hitmarkerteamcolor)
1. [HitMarkerSize](#hitmarkersize)
1. [HitMarkerOffset](#hitmarkeroffset)
1. [HitMarkerDuration](#hitmarkerduration)
1. [HitMarkerDecayExponent](#hitmarkerdecayexponent)
1. [HitMarkerSource](#hitmarkersource)
1. [bUseCrosshairFactory](#busecrosshairfactory)
1. [CrosshairLayers](#crosshairlayers)
1. [CrosshairPreset](#crosshairpreset)
1. [bBioUseClientSideAnimations](#bbiouseclientsideanimations)
1. [bShockBeamUseClientSideAnimations](#bshockbeamuseclientsideanimations)
1. [bShockProjectileUseClientSideAnimations](#bshockprojectileuseclientsideanimations)
1. [bPredictiveShockCombos](#bpredictiveshockcombos)
1. [bPulseUseClientSideAnimations](#bpulseuseclientsideanimations)
1. [bRipperUseClientSideAnimations](#bripperuseclientsideanimations)
1. [bFlakUseClientSideAnimations](#bflakuseclientsideanimations)
1. [bRocketUseClientSideAnimations](#brocketuseclientsideanimations)
1. [bSniperUseClientSideAnimations](#bsniperuseclientsideanimations)
1. [bTranslocatorUseClientSideAnimations](#btranslocatoruseclientsideanimations)

## bForceModels
**Type: bool**  
**Default: False**  

If set to `True`, forces all other players to use fixed models and skins (see DesiredSkin settings).
If set to `False`, all players will show as their chosen model and skin.

### List of Skins
Note that these numbers only apply when editing INI settings

0. Class: Female Commando, Skin: Aphex, Face: Idina
1. Class: Female Commando, Skin: Commando, Face: Anna
2. Class: Female Commando, Skin: Mercenary, Face: Jayce
3. Class: Female Commando, Skin: Necris, Face: Cryss
4. Class: Female Soldier, Skin: Marine, Face: Annaka
5. Class: Female Soldier, Skin: Metal Guard, Face: Isis
6. Class: Female Soldier, Skin: Soldier, Face: Lauren
7. Class: Female Soldier, Skin: Venom, Face: Athena
8. Class: Female Soldier, Skin: War Machine, Face: Cathode
9. Class: Male Commando, Skin: Commando, Face: Blake
10. Class: Male Commando, Skin: Mercenary, Face: Boris
11. Class: Male Commando, Skin: Necris, Face: Grail
12. Class: Male Soldier, Skin: Marine, Face: Malcolm
13. Class: Male Soldier, Skin: Metal Guard, Face: Drake
14. Class: Male Soldier, Skin: RawSteel, Face: Arkon
15. Class: Male Soldier, Skin: Soldier, Face: Brock
16. Class: Male Soldier, Skin: War Machine, Face: Matrix
17. Class: Boss, Skin: Boss, Face: Xan

Any value below zero disables forcing models. For example, if you set [DesiredSkin](#desiredskin) to `-1`, enemy players that have selected male skins will not be forced to another skin.

## DesiredSkin
**Type: int**  
**Default: 9**  

## DesiredSkinFemale
**Type: int**  
**Default: 0**  

## DesiredTeamSkin
**Type: int**  
**Default: 9**  

## DesiredTeamSkinFemale
**Type: int**  
**Default: 0**  

## SkinEnemyIndexMap
**Type: int\[16\]**  
**Default: 0**  

## SkinTeamIndexMap
**Type: int\[16\]**  
**Default: 0**  

## bSkinEnemyUseIndexMap
**Type: bool**  
**Default: False**  

* `False` ➜ Assign each enemy `DesiredSkin` or `DesiredSkinFemale`
* `True` ➜ Assigns each enemy a different skin, according to that players index into [SkinEnemyIndexMap](#skinenemyindexmap)

## bSkinTeamUseIndexMap
**Type: bool**  
**Default: False**

* `False` ➜ Assign each teammate `DesiredTeamSkin` or `DesiredTeamSkinFemale`
* `True` ➜ Assigns each teammate a different skin, according to that players index into [SkinTeamIndexMap](#skinteamindexmap)

## bUnlitSkins
**Type: bool**  
**Default: True**  

If `True`, player skins will not be affected by surrounding lighting, usually making them brighter.

## bEnableHitSounds
**Type: bool**  
**Default: True**  

If `True`, plays a sound when a weapon you fire hits an enemy on your client.
If `False`, no sound is played.

## bEnableTeamHitSounds
**Type: bool**  
**Default: False**  

If `True`, plays a sound when a weapon you fire hits a teammate on your client.
If `False`, no sound is played.

## bHitSoundPitchShift
**Type: bool**  
**Default: True**  

Whether the HitSound from hitting enemies should be pitch shifted depending on damage dealt or not.

## bHitSoundTeamPitchShift
**Type: bool**  
**Default: False**  

Whether the HitSound from hitting teammates should be pitch shifted depending on damage dealt or not.

## HitSoundSource
**Type: EHitSoundSource**  
**Default: HSSRC_Server**  

Selects where hit sound events come from.

* `HSSRC_Server` ➜ Use server-side hit confirmations (accurate but delayed by ping).
* `HSSRC_Client` ➜ Use client-side hit detection (instant but can be inaccurate).

`HSSRC_Client` applies while you carry a NewNet weapon, and to the rifles of NextIG and NextSA. With those two your own trace plays the sound at the click. With [bEnablePreciseRewindTime](#benablepreciserewindtime) on, that trace tests the other players where the server will place them for your shot, which can be a few units from where your screen draws a player who just changed direction. The server still decides the hit. A sound can play for a shot the server counts as a miss, and a hit only the server saw plays its sound a ping late. With every other weapon the hit sound is the server's.

## SelectedHitSound
**Type: int**  
**Default: 0**  

Index into sHitSound array for the sound to play when hitting an enemy.

## SelectedTeamHitSound
**Type: int**  
**Default: 2**  

Index into sHitSound array for the sound to play when hitting a teammate.

## HitSoundVolume
**Type: float**  
**Default: 4.0**  

Volume of the HitSound from hitting enemies.

## HitSoundTeamVolume
**Type: float**  
**Default: 4.0**  

Volume of the HitSound from hitting teammates.

## sHitSound
**Type: string\[16\]**  

Specifies sounds that can be played.

## bDoEndShot
**Type: bool**  
**Default: False**  

If `True`, automatically create a screenshot at the end of a match.
If `False`, no screenshot is automatically created.

## bAutoDemo
**Type: bool**  
**Default: False**  

If `True`, automatically start recording a demo when the game starts.

## DemoMask
**Type: string**  
**Default: %l\_\[%y\_%m\_%d\_%t\]\_\[%c\]\_%e**  

Template for the name of the demo started because of [bAutoDemo](#bautodemo).
The following (case-insensitive) placeholders will be replaced with match-specific details:

- `%E` ➜ Name of the map file
- `%F` ➜ Title of the map
- `%D` ➜ Day (two digits)
- `%M` ➜ Month (two digits)
- `%Y` ➜ Year
- `%H` ➜ Hour
- `%N` ➜ Minute
- `%T` ➜ Combined Hour and Minute (two digits each)
- `%C` ➜ Clan Tags (detected by determining common prefix of all players on a team, or "Unknown")
- `%L` ➜ Name of the recording player
- `%%` ➜ Replaced with a single %

## DemoPath
**Type: string**  
**Default: *empty***  

Prefix for name of the demo started because of [bAutoDemo](#bautodemo) or [DemoStart](#demostart).

## DemoChar
**Type: string**  
**Default: *empty***  

Characters filesystems can not handle are replaced with this.

## bTeamInfo
**Type: bool**  
**Default: True**  

if Client wants extra team info.

## bShootDead
**Type: bool**  
**Default: False**  

If `True`, client shots can collide with carcasses from dead players.
If `False`, client shots will not collide with carcasses.

## cShockBeam
**Type: int**  
**Default: 1**  

The style of beam to use for the SuperShockRifle.

1. Default beam
2. Team colored beam that looks like a projectile
3. No beam at all
4. Team colored, instant beam

## bHideOwnBeam
**Type: bool**  
**Default: False**  

If `True`, hides your own SuperShockRifle beams, no matter the value of [cShockBeam](#cshockbeam). 

## bBeamEnableLight
**Type: bool**  
**Default: True**  

If `True`, shock beams emit dynamic light.  
If `False`, dynamic light from beams is disabled.

## BeamScale
**Type: float**  
**Default: 0.45**  

Visuals for the beam are scaled with this factor.

## BeamFadeCurve
**Type: float**  
**Default: 4.0**  

Exponent of the polynomial curve the beam's visuals decay with.

## BeamDuration
**Type: float**  
**Default: 0.75**  
**Unit: s**  

The time the beam's visuals decay over.

## BeamOriginMode
**Type: int**  
**Default: 0**  

0. Originates where the player was when the shot was fired
1. Originates at an offset from where the player is on your screen.

## BeamDestinationMode
**Type: int**  
**Default: 0**  

0. Beam ends where it ended on server
1. Beam ends on target

## SSRRingType
**Type: int**  
**Default: 1**  

0. No Ring
1. Default Ring
2. Team-colored Ring

## HitEffectSource
**Type: EHitEffectSource**  
**Default: HESRC_Client**  

When the ring of your InstaGib rifle shows on a player you hit. It applies to the rifle of NextIG. Your beam always shows at the click.

* `HESRC_Client`: the ring shows at the click, where your own trace ended. When the server then counts no hit, the ring was shown for nothing.
* `HESRC_Server`: the ring shows at the end of your beam once the server has counted the hit, a ping later. It never shows for a hit the server did not count.

A ring on a wall shows at the click with both values. The NewNet rifle is not affected. There the game client decides the hit.

## bNoOwnFootsteps
**Type: bool**  
**Default: False**  

If `True`, footstep sounds are not played for your own footsteps.
If `False`, your own footstep sounds will be played.

## DesiredNetUpdateRate
**Type: float**  
**Default: 200**  
**Unit: Hz**  

How often you want your client to update the server on your movement. The server places upper and lower limits on this (see [MinNetUpdateRate](#minnetupdaterate), [MaxNetUpdateRate](#maxnetupdaterate)), and the actual update rate will never exceed your netspeed divided by 100.

This is here to provide players with constrained upload bandwidth a way to reduce the required upload bandwidth at the expense of greater susceptibility to packet loss, and glitches arising from it.

Players with high upload bandwidth can set this to a high value to lessen the impact of packet loss.

## DesiredNetspeed
**Type: int**  
**Default: 25000**  
**Unit: B/s**  

Always tries to keep your netspeed at the value of this variable, unless the server prevents this.

## FakeCAPInterval
**Type: float**  
**Default: 0.1**  
**Unit: s**  

Tells the server to send an acknowledgement of your movement updates (see [DesiredNetUpdateRate](#desirednetupdaterate)) after this amount of time has passed since the last acknowledgement. This saves download bandwidth and lessens server load.

Smaller values (closer to 0) result in acknowledgements being sent more frequently, negative values send an acknowledgement for every movement update.
Higher values result in less frequent acknowledgements which can result in degraded client performance (FPS), or even crashes.

## bCameraCorrectionSmoothing
**Type: bool**  
**Default: False**  

If set to `True`, a correction from the server moves you to the corrected spot at once, but your camera eases there over [CameraCorrectionSmoothingTime](#cameracorrectionsmoothingtime) instead of jumping. If [bEnablePushSafeAim](#benablepushsafeaim) is on, shots still go through your crosshair while the camera catches up.

## CameraCorrectionSmoothingTime
**Type: float**  
**Default: 0.1**  
**Unit: s**  

How long the camera takes to ease out a correction (about 95% of it is gone after this time). Only used with [bCameraCorrectionSmoothing](#bcameracorrectionsmoothing).

## bSmoothLiftJump
**Type: bool**  
**Default: True**  

If set to `True`, when you jump or step off a moving lift, you move straight to where the server has you and your view eases there, instead of snapping there a ping later.

## bSpectatorShowDamageNumbers
**Type: bool**  
**Default: False**  

If set to `True`, you see damage numbers for the player you watch as a spectator. The server has to allow it with [ShowDamageNumberMode](#showdamagenumbermode). The command [ShowDamageNumbers](#showdamagenumbers) turns it on and off.

## DamageNumberDuration
**Type: float**  
**Default: 2.5**  
**Unit: s**  

How long a damage number stays on screen. The game clamps values below 0.1 or above 10.

## DamageNumberFade
**Type: float**  
**Default: 5.0**  

How a damage number fades out. 1 is a steady fade, and higher values make it fade sooner. The game clamps values below 1 or above 10.

## bDemoShowRealModels
**Type: bool**  
**Default: True**  

If set to `True`, demos show the models and skins each player chose, also when the recording player had forced models on. In the menu this is Show Real Skins In Demos.

## bPredictedSwitching
**Type: bool**  
**Default: True**  

If set to `True`, your weapon switches start the moment you press, where the server's [bEnablePredictedSwitching](#benablepredictedswitching) allows it. If set to `False`, your switches start when the server answers, a ping later.

## bPredictedTranslocation
**Type: bool**  
**Default: True**  

If set to `True`, translocating moves you the moment you press, where the server's [bEnablePredictedTranslocation](#benablepredictedtranslocation) allows it. If set to `False`, you move when the server's teleport arrives, a ping later, and your disc stays in view until then.

## bPredictedDiscBoost
**Type: bool**  
**Default: True**  

If set to `True`, your own shock beam, shock combo, shock ball, rocket, flak slug and ripper alt blade push your own translocator disc on your screen right away, where the server's [bEnablePredictedDiscBoost](#benablepredicteddiscboost) allows it. If set to `False`, the push shows when the server's arrives, a ping later.

## bSmoothDiscCorrections
**Type: bool**  
**Default: True**  

If set to `True`, when the server moves your own translocator disc a little (up to 64 units), the disc glides there on your screen in a tenth of a second instead of jumping. After something hits your disc, its corrections glide up to 320 units until it lands: the hit reaches you a ping late, so the disc launches from where your screen had it. Bigger corrections, and any with a wall or door in the way, still jump. Only the drawing changes: where the disc is and where you translocate to stay the same. Only used with the server's [bEnableDeterministicTranslocator](#benabledeterministictranslocator). The settings menu grays it out on servers without it. Console: [ToggleSmoothDiscCorrections](#togglesmoothdisccorrections).

## bNoSmoothing
**Type: bool**  
**Default: True**  

The default mouse input smoothing algorithm always smears input over at least two frames, half the input being applied on one frame, the other half on the next frame. If set to `True`, the game will always apply all input on the current frame. If set to `False`, the default algorithm will be used.

This is a backport from UT99 client version 469, where the equivalent setting is called bNoMouseSmoothing.

## bLogClientMessages
**Type: bool**  
**Default: True**  

Causes all ClientMessages to be logged, if set to `True`

## bDemoShowClientMessages
**Type: bool**  
**Default: False**  

If `True`, ClientMessages are shown while playing demos.  
If `False`, ClientMessages are hidden while playing demos.

## bDebugMovement
**Type: bool**  
**Default: False**  

Causes IG+ to write movement debugging events to console/demo, depending on whether debug data is enabled at the moment (see [EnableDebugData](#enabledebugdata))

## bShowDebugDataOnScreen
**Type: bool**  
**Default: False**  

Decides whether debug data shows on your screen while it is on (see [EnableDebugData](#enabledebugdata)).

If `False`, the screen stays as it is. You get one line when you turn debug data on and one line when you turn it off. The debug lines still go to the console and to the debug log file.  
If `True`, the HUD shows the debug values and the message area shows the debug lines.

In the IG+ menu this is `Show Debug Data On Screen`, under `Advanced`.

## FlipAnimationFix
**Type: EFlipAnimationFix**  
**Default: FAF_FinishFlip**  

What to draw when a player's model would collapse into a small lump in the air (a "pancake").

The game blends a model into its next animation by moving every point of it in a straight line. The flip of a forward dodge turns the model over. When a blend of some length starts in that part of the flip, the lines cross in the middle and the model is a lump for as long as the blend takes. The usual way there is a forward dodge that lands in the middle of its flip, followed at once by a jump (a blend of 0.35 or 0.7 seconds) or by a jump pad (2 seconds).

- `FAF_Off`: models are drawn as the game draws them.
- `FAF_Instant`: the model takes the pose the blend ends in at once, and the game's air animations go on from there.
- `FAF_FinishFlip`: the model plays its flip to the end at the flip's own speed. Then the blend the game is in by then takes over from its start and catches up. Every frame drawn is a frame of the stock animations.

It acts on blends that start from the turned-over part of a flip and have more than a quarter of a second to go. The flip itself, short blends and slow blends from an upright pose are drawn as before. It works on other players, on your own model in behind view and for spectators.

A model that comes into view in the middle of such a blend is drawn in the pose the blend ends in, with `FAF_Instant` and with `FAF_FinishFlip`. The game would blend it from the pose it had when you last saw it. Whether a model was on your screen is an estimate: it is inside your view and the line to it is clear.

A player with [EnableDebugData](#enabledebugdata) on gets one `Flip fix:` line in the debug log for every such blend, with any value of this setting. It names the player, the animation the blend goes to, the milliseconds it had left, how much of the pose was a turned-over one (1.0 is all of it) and what was done (`off`, `instant` or `flip`). `seen again in a blend to` marks a model that came into view in the middle of the blend.

In the IG+ menu this is `Flip Animation Fix`, under `Advanced`.

## bEnableKillCam
**Type: bool**  
**Default: False**  

KillCam follows the player that killed you for two seconds.

## MinDodgeClickTime
**Type: float**  
**Default: 0.0**  
**Unit: s**  

Minimum time between two rising edges of movement in the same direction for them to count as a dodge.
## bUseOldMouseInput
**Type: bool**  
**Default: False**  

The old mouse input processing algorithm discards the fractional part before turning the view according to the mouse input. The new algorithm preserves fractional rotation across frames.

A players view is defined by yaw and pitch, which are quantized to 65536 degrees (a circle has 65536 degrees instead of 360). If a players mouse input sensitivity is set such that the players mouse input can result in some fraction of a degree, that fractional part must be discarded before the view is changed. The new algorithm preserves that fractional part and adds it to the next mouse input.

If `True`, two successive inputs of 1.5° change in yaw result in a 2° turn (int(1.5) + int(1.5) = 1 + 1 = 2).
If `False`, two successive inputs of 1.5° change in yaw result in a 3° turn.

## SmoothVRController
**Type: PIDControllerSettings**  
**Default: (p=0.09,i=0.05,d=0.00)**  

This holds the PID settings for the controller thats smoothing the view of players youre spectating as a spectator (see [PID controller](https://en.wikipedia.org/wiki/PID_controller)).

## bShowFPS
**Type: bool**  
**Default: False**  

If `True`, show averaged FPS information in top right corner. If `False`, show nothing.

## FPSLocationX

**Type: float**  
**Default: 1.0**  

Placement of the FPS information on the horizontal axis. `0.0` is left edge, `1.0` is right edge.

## FPSLocationY

**Type: float**  
**Default: 0.0**  

Placement of the FPS information on the vertical axis. `0.0` is top edge, `1.0` is bottom edge.

## FPSDetail
**Type: int**  
**Default: 0**  

How much detail to display about FPS

* 0 ➜ Average FPS only
* 1 ➜ Average Frame-Time
* 2 ➜ Standard deviation of Frame-Time
* 3 ➜ Min/Max Frame-Time over the last 3 seconds

## FPSCounterSmoothingStrength
**Type: int**  
**Default: 1000**  

How many samples to average FPS over.

## KillCamMinDelay
**Type: float**  
**Default: 0.0**  
**Unit: seconds**  

Minimum time between death and when KillCam starts rotating towards killer.

## bReduceEyeHeightInAir
**Type: bool**  
**Default: False**  

If `True`, reduces eye height while in air.  
If `False`, uses normal eye height while in air.
Your shots leave from the same eye height as your view, so they go where you aim while in air.

## bAllowWeaponShake
**Type: bool**  
**Default: True**  

If `True`, weapons can shake view. If `False` weapons can't shake view.

## bAutoReady
**Type: bool**  
**Default: True**  

If `True`, you ready up when spawning for the first time during warmup. If `False` you have to manually ready up using the [Ready](#ready) command, or using `mutate ready`, or by saying one of `ready`, `rdy`, `r`, `!ready`, `!rdy`.

## bShowDeathReport
**Type: bool**  
**Default: False**  

If `True`, show a report of damage taken that lead to death. The report starts from the last time you gained health or armor.

## bSmoothFOVChanges
**Type: bool**  
**Default: False**  

If `True`, smooth changes to your FOV, which can happen when spawning, teleporting or zooming.  
If `False`, your FOV immediately changes to the desired FOV without a smooth transition.

## bEnableLocationOffsetFix
**Type: bool**  
**Default: True**  

If `True`, enables client-side location offset correction to reduce visual jitter/offset artifacts.  
If `False`, disables that correction.

## bEnableKillFeed
**Type: bool**  
**Default: True**  

If `True` kills are reported in a separate list in condensed form, using symbols to represent the cause of death.  
If `False` nothing is shown.

## KillFeedX
**Type: float**  
**Default: 0.0**  

Horizontal position of the KillFeed. Left edge of screen is 0. Right edge of screen is 1.

## KillFeedY
**Type: float**  
**Default: 0.5**  

Vertical position of the KillFeed. Top of screen is 0. Bottom of screen is 1.

## KillFeedSpeed
**Type: float**  
**Default: 1.0**  

Linear factor on the speed at which individual lines in the KillFeed disappear.

Increase to make lines disappear sooner. Decrease to make lines disappear later. 0 and below mean the lines stay until they are rotated out by subsequent kills. Maximum of 4 lines at any time.

## KillFeedScale
**Type: float**  
**Default: 1.0**  

Scales the size of individual lines of the KillFeed.

## FraggerScopeChoice
**Type: EFraggerScopeChoice**  
**Default: `FSC_Moveable`**  

Which scope the FraggerRifle uses when zoming.

* `FSC_None` ➜ Keeps the default crosshair
* `FSC_Static` ➜ Few moving parts when zooming in
* `FSC_Moveable` ➜ More moving parts when zooming in

## bEnableNetStats
**Type: bool**  
**Default: False**  

If `True`, shows a graph containing statistics related to the netcode. for simulated game-time still unconfirmed by server (top), as well as a graph for the distance players are away from where the server has them (bottom).

## bNetStatsUnconfirmedTime
**Type: bool**  
**Default: True**  

If `True`, shows the netstats graph of the amount of simulated game-time still unconfirmed by the server. This graph will always be at the top.

## bNetStatsLocationError
**Type: bool**  
**Default: True**  

If `True`, the netstats graph will show the distance players are away from where the server has them.

## bNetStatsFrameTime
**Type: bool**  
**Default: False**  

If `True`, the netstats graph will show how long each frame took to render.

## NetStatsLocationX
**Type: float**  
**Default: 0.5**  

Horizontal position of the netstats graph. Left edge of screen is 0. Right edge of screen is 1.

## NetStatsLocationY
**Type: float**  
**Default: 0.0**  

Vertical position of the netstats graph. Top of screen is 0. Bottom of screen is 1.

## NetStatsWidth
**Type: int**  
**Default: 511**  

Controls how wide the netstats graph is in pixel. Maximum value is 511. Each pixel represents a single frame rendered.

## bEnableHitMarker
**Type: bool**  
**Default: False**  

If `True`, plays an animation on the hud whenever you damage an enemy.

## bEnableTeamHitMarker
**Type: bool**  
**Default: False**  

If `True`, plays an animation on the hud whenever you damage a teammate.

## HitMarkerColorMode
**Type: EHitMarkerColorMode**  
**Default: HMCM_FriendOrFoe** 

* `HMCM_FriendOrFoe` ➜ Use [HitMarkerColor](#hitmarkercolor) for enemies and [HitMarkerTeamColor](#hitmarkerteamcolor) for friends.
* `HMCM_TeamColor` ➜ Use team color in team games, [HitMarkerColor](#hitmarkercolor) in FFA games.

## HitMarkerColor
**Type: color**  
**Default: (R=255,G=0,B=0,A=255)** 

The color of the HitMarker when damaging enemies. Fades over [HitMarkerDuration](#hitmarkerduration) to completely transparent.

Note that transparency is based on color brightness, and black is completely transparent.

## HitMarkerTeamColor
**Type: color**  
**Default: (R=0,G=0,B=255,A=255)**  

The color of the HitMarker when damaging teammates. Fades over [HitMarkerDuration](#hitmarkerduration) to completely transparent.

Note that transparency is based on color brightness, and black is completely transparent.

## HitMarkerSize
**Type: float**  
**Default: 128.0**  
**Unit: pixel**  

The length of the arrows that the HitMarker places on screen.

## HitMarkerOffset
**Type: float**  
**Default: 32.0**  
**Unit: pixel**  

How far away from the center of the screen the arrows are placed.

## HitMarkerDuration
**Type: float**  
**Default: 0.3**  
**Unit: seconds**  

How long the HitMarker stays on screen. Negative values effectively disable HitMarker.

## HitMarkerDecayExponent
**Type: float**  
**Default: 5.0**  

How quickly the HitMarker becomes transparent. Higher values mean sharper drop-off. Values closer to zero make the HitMarker stay on screen at full brightness for longer until [HitMarkerDuration](#hitmarkerduration) is reached.

## HitMarkerSource
**Type: EHitMarkerSource**  
**Default: HMSRC_Server**  

* `HMSRC_Server` ➜ HitMarkers are triggered server-side, accurate but delayed by ping
* `HMSRC_Client` ➜ HitMarkers are triggered client-side, inaccurate but instant

`HMSRC_Client` applies while you carry a NewNet weapon, and to the rifles of NextIG and NextSA, as described under [HitSoundSource](#hitsoundsource). With every other weapon the hit marker is the server's.

## bUseCrosshairFactory
**Type: bool**  
**Default: False**  

If `True`, override default crosshair drawing with custom one, as described by [CrosshairLayers](#crosshairlayers).

## CrosshairLayers
**Type: CrosshairLayerDescr\[10\]**  
**Default: `(Texture="",OffsetX=0,OffsetY=0,ScaleX=0.000000,ScaleY=0.000000,Color=(R=0,G=0,B=0,A=0),Style=0,bSmooth=False,bUse=False)`**  

The type `CrosshairLayerDescr` is defined like this:
```unrealscript
struct CrosshairLayerDescr {
    var() config string Texture;
    var() config int    OffsetX, OffsetY;
    var() config float  ScaleX, ScaleY;
    var() config color  Color;
    var() config byte   Style;
    var() config bool   bSmooth;
    var() config bool   bUse;
};
```

A crosshair is made up of individual images that are drawn in a specific order potentially on top of each other, which are called layers. The current factory supports up to 10 layers for a single crosshair.

* `Texture` refers to the image to draw. If left empty, a 1x1 white pixel will be used.
* `OffsetX` and `OffsetY` is the offset from the center of the screen in pixels where the image should be drawn
* `ScaleX` and `ScaleY` represent how large the image should be
* `Color` is the color in RGB that should be used to draw the image
* `Style` is the drawing style to use for the image, one of
    * 0 (`STY_None`) - equivalent to 1 (`STY_Normal`) for our purposes here
    * 1 (`STY_Normal`) - RGB image (no transparency)
    * 2 (`STY_Masked`) - Paletted image, first color in palette is transparent (?)
    * 3 (`STY_Translucent`) - Greyscale image, brightness is opacity, used for default crosshairs
    * 4 (`STY_Modulated`) - ?
* `bSmooth` controls whether sharp edges should be smoothed out when `ScaleX` or `ScaleY` are greater than 1
* `bUse` controls whether this layer should be drawn, `True` to draw, `False` to ignore

`CrosshairLayers` holds the layers of the picked preset, see [CrosshairPreset](#crosshairpreset).

## CrosshairPreset
**Type: int**  
**Default: 0**  

The Crosshair Factory keeps up to 16 crosshairs, called presets. `CrosshairPreset` is the slot of the picked preset, from 0 to 15. The picked preset is the crosshair the game draws, and its layers are [CrosshairLayers](#crosshairlayers).

In the Crosshair Factory window the presets are in the list on the right, each with a small picture and its name.

* Click a preset to pick it. The game draws it from that click on.
* `+` makes a new preset. It starts as a copy of the picked one and becomes the picked one.
* `-` deletes the picked preset. You can not delete the last preset.
* `Name` is the name of the picked preset.
* `Save` writes the layers and the name into the picked preset. If you pick another preset before you save, your changes to the layers are gone.

A crosshair you made before presets existed is your first preset, named `Crosshair 1`.

Every preset has its own section in InstaGibPlus.ini, `[CrosshairPreset1]` to `[CrosshairPreset16]`, with `PresetName` and ten `Layers` in the format of [CrosshairLayers](#crosshairlayers). An empty `PresetName` means the slot is free. The picked preset is read from `CrosshairLayers` in `[ClientSettings]`. If you change it by hand, change it there and not in its own section. An older IG+ version on another server reads the same file and draws `CrosshairLayers`, so it draws the picked preset too.

## bBioUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Bio Rifle ping-compensated logic.

## bShockBeamUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Shock Beam ping-compensated logic. The InstaGib rifle of NextIG does not use this setting. It always draws its own beam at once.

## bShockProjectileUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Shock Projectile ping-compensated logic.

## bPredictiveShockCombos
**Type: bool**  
**Default: True**  

Only used with [bShockProjectileUseClientSideAnimations](#bshockprojectileuseclientsideanimations). If set to `True`, your own shock ball flies on your own timeline, where the server tests your beam against it, so a combo shows the moment you hit it. If set to `False`, the older client-side animation is used.

## bPulseUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Pulse Gun ping-compensated logic.

## bRipperUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Ripper ping-compensated logic.

## bFlakUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Flak ping-compensated logic.

## bRocketUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Rocket Launcher ping-compensated logic.

## bSniperUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Sniper ping-compensated logic. Not used in NextSA, where the rifle always has its client-side shell case and muzzle flash.

## bTranslocatorUseClientSideAnimations
**Type: bool**  
**Default: True**  

Enable client-side animation timing for Translocator ping-compensated logic. Not used with the server's [bEnableDeterministicTranslocator](#benabledeterministictranslocator), which always shows your own disc the moment you throw. The settings menu grays it out there.

# Client Commands
The following commands are additions by IG+ to the standard set of commands.

Types for parameters:

* bool: Binary value, `True`/`1` or `False`/`0`
* int: Whole number, e.g. `6`, `78`
* float: Real number, e.g. `1.35`, accurate up to 7 significant digits
* string: String of characters, e.g. `"Hello, World!"`

Parameters marked `optional` do not have to be supplied.

1. [EnableDebugData](#enabledebugdata)
1. [EnableHitSound](#enablehitsound)
1. [EnableTeamHitSound](#enableteamhitsound)
1. [SetHitSound](#sethitsound)
1. [SetTeamHitSound](#setteamhitsound)
1. [ForceModels](#forcemodels)
1. [ListSkins](#listskins)
1. [SetForcedSkins](#setforcedskins)
1. [SetForcedTeamSkins](#setforcedteamskins)
1. [SetShockBeam](#setshockbeam)
1. [SetBeamScale](#setbeamscale)
1. [MyIgSettings](#myigsettings)
1. [SetNetUpdateRate](#setnetupdaterate)
1. [SetMouseSmoothing](#setmousesmoothing)
1. [SetKillCamEnabled](#setkillcamenabled)
1. [DropFlag](#dropflag)
1. [PureLogo](#purelogo)
1. [TeamInfo](#teaminfo)
1. [SetMinDodgeClickTime](#setmindodgeclicktime)
1. [mdct](#mdct)
1. [EndShot](#endshot)
1. [Hold](#hold)
1. [Go](#go)
1. [AutoDemo](#autodemo)
1. [ShootDead](#shootdead)
1. [SetDemoMask](#setdemomask)
1. [DemoStart](#demostart)
1. [ShowFPS](#showfps)
1. [ShowOwnBeam](#showownbeam)
1. [Ready](#ready)
1. [ZoomToggle](#zoomtoggle)
1. [IGPlusMenu](#igplusmenu)
1. [EnableClientSideAnimations](#enableclientsideanimations)
1. [DisableClientSideAnimations](#disableclientsideanimations)
1. [BioClientSideAnimations](#bioclientsideanimations)
1. [ShockBeamClientSideAnimations](#shockbeamclientsideanimations)
1. [ShockProjectileClientSideAnimations](#shockprojectileclientsideanimations)
1. [PulseClientSideAnimations](#pulseclientsideanimations)
1. [RipperClientSideAnimations](#ripperclientsideanimations)
1. [FlakClientSideAnimations](#flakclientsideanimations)
1. [RocketClientSideAnimations](#rocketclientsideanimations)
1. [SniperClientSideAnimations](#sniperclientsideanimations)
1. [TranslocatorClientSideAnimations](#translocatorclientsideanimations)
1. [ToggleSmoothDiscCorrections](#togglesmoothdisccorrections)
1. [ShowDamageNumbers](#showdamagenumbers)
1. [TestHitMarker](#testhitmarker)
1. [TestHitSound](#testhitsound)
1. [IGPlus_FOV](#igplus_fov)
1. [DrawServerLocation](#drawserverlocation)
1. [PrintWeaponState](#printweaponstate)
1. [NetcodeHelp](#netcodehelp)
1. [bEnableInputReplication](#benableinputreplication-command)
1. [bEnableSnapshotInterpolation](#benablesnapshotinterpolation-command)
1. [SnapshotInterpSendHz](#snapshotinterpsendhz-command)
1. [SnapshotInterpRewindMs](#snapshotinterprewindms-command)
1. [MaxJitterTime](#maxjittertime-command)
1. [JitterBoundingMode](#jitterboundingmode-command)
1. [SnapInterpDebug](#snapinterpdebug)
1. [SnapInterpStatus](#snapinterpstatus)
1. [SnapInterpNetStatus](#snapinterpnetstatus)
1. [SnapInterpCheck](#snapinterpcheck)
1. [SnapInterpCheckStop](#snapinterpcheckstop)
1. [TraceInput](#traceinput)
1. [ShowTickrate / ShowNetSpeeds](#showtickrate--shownetspeeds)

## EnableDebugData
**Parameters: (bool b)**  

Collects debugging information about your own game. `EnableDebugData 1` turns it on and `EnableDebugData 0` turns it off. Each prints one line that confirms it and names the log file.

While on, the debug lines are written to the console and to a new file in your UT Logs folder, named IGPlusDebug_\<date\>_\<time\>.log. Turning it off closes the file. Nothing else shows on screen unless you turn on [bShowDebugDataOnScreen](#bshowdebugdataonscreen).
## EnableHitSound
**Parameters: (bool b)**

Enables/Disables hitsound when hitting enemies.

## EnableTeamHitSound
**Parameters: (bool b)**

Enables/Disables hitsound when hitting teammates.

## SetHitSound
**Parameters: (byte hs)**

Switches between the 16 slots available for enemy hitsounds (see [sHitSound](#shitsound)). `hs` must be a value between `0` and `15`.

## SetTeamHitSound
**Parameters: (byte hs)**

Switches between the 16 slots available for teammate hitsounds (see [sHitSound](#shitsound)). `hs` must be a value between `0` and `15`.


## ForceModels
**Parameters: (bool b)**

Enables/Disables forced models/skins for all players.

## ListSkins
Prints a list of models/skins you can force enemies and teammates to.

## SetForcedSkins
**Parameters: (int maleSkin, int femaleSkin)**

Sets the forced models/skins for opponents who are using male or female models respectively. Valid values for `maleSkin` and `femaleSkin` range from `1` to `18`. The [ListSkins](#listskins) command prints how those numbers map to models and skins.

### Examples
Forcing all opponents to Xan:

    SetForcedSkins 18 18

Forcing opponents to bright skins:

    SetForcedSkins 16 7
## SetForcedTeamSkins
**Parameters: (int maleSkin, int femaleSkin)**

Sets the forced models/skins for teammates who are using male or female models respectively. Valid values for `maleSkin` and `femaleSkin` range from `1` to `18`. The [ListSkins](#listskins) command prints how those numbers map to models and skins.
## SetShockBeam
**Parameters: (int sb)**

Changes the style of beam fired by the SuperShockRifle. See [cShockBeam setting](#cshockbeam-int-default-1).
## SetBeamScale
**Parameters: (float bs)**
Changes [BeamScale setting](#beamscale).
## MyIgSettings
Prints a selection of IG+ settings.
## SetNetUpdateRate
**Parameters: (float NewVal)**

Changes how often your client will send a movement update to the server. See [DesiredNetUpdateRate setting](#desirednetupdaterate).
## SetMouseSmoothing
**Parameters: (bool b)**

Changes [bNoSmoothing setting](#bnosmoothing).
## SetKillCamEnabled
**Parameters: (bool b)**

Changes [bEnableKillCam setting](#benablekillcam).
## DropFlag
Drops the currently held flag, if any.
## PureLogo
Shows IG+ version in the bottom left corner of the screen.
## TeamInfo
**Parameters: (bool b)**
## SetMinDodgeClickTime
**Parameters: (float f)**

Changes [MinDodgeClickTime setting](#mindodgeclicktime).
## mdct
**Parameters: (float f)**

Changes [MinDodgeClickTime setting](#mindodgeclicktime).
## EndShot
**Parameters: (optional bool b)**

Changes [bDoEndShot setting](#bdoendshot).
## Hold
Resets the AutoPause countdown. Can only be used if the AutoPause was triggered by an opponent leaving or switching sides.
## Go
Resumes the game immediately. Can only be used by the team that lost at least one of its players.
## AutoDemo
**Parameters: (bool b)**

Changes [bAutoDemo setting](#bautodemo).
## ShootDead
Toggles [bShootDead setting](#bshootdead) between `True` and `False`.
## SetDemoMask
**Parameters: (optional string Mask)**

Changes [DemoMask setting](#demomask).
## DemoStart
Starts recording a demo with the [DemoPath](#demopath) and [DemoMask](#demomask) that are currently configured.

## ShowFPS
Toggles displaying FPS information in the top right corner. See [bShowFPS](#bshowfps).

## ShowOwnBeam
Toggles showing your own beam when firing the SuperShockRifle. See [bHideOwnBeam](#bhideownbeam).

## Ready
Toggles ready state during warmup.

## ZoomToggle
**Parameters: (float SensitivityX, optional float SensitivityY)**

Toggles between FOV 80 and the players desired FOV.  
`SensitivityX` and `SensitivityY` are multiplicative factors on mouse sensitivity in their respective directions (X is side-to-side / yaw, Y is up-down / pitch) while zooming.

If `SensitivityY` is not provided by the user, it is assumed to be the same as `SensitivityX`.

### Examples
- Same sensitivity as un-zoomed: `ZoomToggle 1.0`
- Half the sensitivity as un-zoomed: `ZoomToggle 0.5`

## IGPlusMenu
Opens the IG+ settings window.

## EnableClientSideAnimations
Enables all per-weapon client-side animation toggles (unless forced by server).

## DisableClientSideAnimations
Disables all per-weapon client-side animation toggles (unless forced by server).

## BioClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Bio weapon behavior.

## ShockBeamClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Shock Beam behavior.

## ShockProjectileClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Shock Projectile behavior.

## PulseClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Pulse behavior.

## RipperClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Ripper behavior.

## FlakClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Flak behavior.

## RocketClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Rocket behavior.

## SniperClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Sniper behavior.

## TranslocatorClientSideAnimations
**Parameters: (bool b)**

Enable/disable client-side animations for Translocator behavior.

## ToggleSmoothDiscCorrections
Turns [bSmoothDiscCorrections](#bsmoothdisccorrections) on or off and says which.

## ShowDamageNumbers
Spectators only. Turns [bSpectatorShowDamageNumbers](#bspectatorshowdamagenumbers) on or off and says which.

## TestHitMarker
**Parameters: (optional int Damage)**

Shows a test hit marker and a test damage number for a hit of that much damage, again and again, in each team's colour in turn. `TestHitMarker 0` stops it.

## TestHitSound
**Parameters: (optional int Damage)**

Plays your hit sound for a hit of that much damage. Each call uses the next team, so you hear the enemy and the team sound.

## IGPlus_FOV
**Parameters: (float FOV)**

Sets your FOV. The value is kept between 80 and your `MaxFOV`, and `MaxFOV` itself is kept between 130 and 360.

## DrawServerLocation
Debug. Turns a second copy of each player on or off, drawn at the last position the server sent. It shows how far [bEnableLocationOffsetFix](#benablelocationoffsetfix) moves the players on your screen.

## PrintWeaponState
Debug. Prints the name and state of the weapon you hold.

## NetcodeHelp
Prints netcode runtime settings and available netcode debug commands.

## bEnableInputReplication (command)
**Parameters: (optional string Value)**

Read/set server setting [bEnableInputReplication](#benableinputreplication) (admin only).

## bEnableSnapshotInterpolation (command)
**Parameters: (optional string Value)**

Read/set server setting [bEnableSnapshotInterpolation](#benablesnapshotinterpolation) (admin only).

## SnapshotInterpSendHz (command)
**Parameters: (optional string Value)**

Read/set server setting [SnapshotInterpSendHz](#snapshotinterpsendhz) (admin only).

## SnapshotInterpRewindMs (command)
**Parameters: (optional string Value)**

Read/set server setting [SnapshotInterpRewindMs](#snapshotinterprewindms) (admin only).

## MaxJitterTime (command)
**Parameters: (optional string Value)**

Read/set server setting [MaxJitterTime](#maxjittertime) (admin only).

## JitterBoundingMode (command)
**Parameters: (optional string Value)**

Read/set server setting [JitterBoundingMode](#jitterboundingmode) (admin only).

## SnapInterpDebug
Toggles snapshot interpolation debug reporting.

## SnapInterpStatus
**Parameters: (optional string NameFilter)**

Prints one-shot proxy runtime status.

## SnapInterpNetStatus
**Parameters: (optional string NameFilter)**

Prints client report + server echo + proxy status.

## SnapInterpCheck
**Parameters: (optional string Profile, optional float DurationSec, optional string NameFilter)**

Runs an interpolation quality check against a simulated proxy target.

## SnapInterpCheckStop
Stops an active SnapInterpCheck run.

## TraceInput
Toggles logging of client input trace data.

## ShowTickrate / ShowNetSpeeds
These are mutate commands exposed by UTPure command handling:

* `mutate PureShowTickrate`
* `mutate PureShowNetspeeds`

# Server Installation

Extract the zipped files to your installation's folder.  
Remove any mention in your ServerPackages and ServerActors of TimTim's NewNet or Deepu's Ultimate NewNet.  
Add the following lines to your server's **UnrealTournament.ini** under **[Engine.GameEngine]**:

**ServerPackages=InstaGibPlus_11**
**ServerPackages=InstaGibPlusAssets_v3**

InstaGibPlus is a collection of mutators.

## InstaGibPlus_11.UTPure

Always required. Enables basic InstaGibPlus functionality.

ServerActor alternative is **InstaGibPlus_11.NewNetServer**.

## InstaGibPlus_11.ST_Mutator

Replaces all normal weapons with IG+ alternatives.

## InstaGibPlus_11.NewNetIG

InstaGib, but with a ping compensated custom weapon.

## InstaGibPlus_11.NextIG

InstaGib with the deterministic SuperShockRifle. The server traces every shot itself and rewinds the other players by the shooter's ping, or by [bEnablePreciseRewindTime](#benablepreciserewindtime) if that is on. The shooter's client draws its own beam and ring at once. No client setting turns that off. With ping compensation off, the beam comes from the server. With [HitSoundSource](#hitsoundsource) and [HitMarkerSource](#hitmarkersource) set to Client, the hit sound and hit marker play at the click from the shooter's own trace. The server's trace still decides the hit.

* Load it in place of ST_Mutator, not together with it.
* Its weapon settings are in the section `WeaponSettingsInstaGib`.
* There is no translocator, as in stock InstaGib and NewNetIG. The game's translocator setting does nothing here.
* The rifle has no range limit.
* A shot from a player who just died only counts with [bEnableTrades](#benabletrades) on in its weapon settings. It is off by default.
* A new server starts with ping compensation, [bEnableSubTickCompensation](#benablesubtickcompensation), [bEnablePreciseRewindTime](#benablepreciserewindtime) and [bEnableFireTimeOrder](#benablefiretimeorder) on, and with [PingCompensationMax](#pingcompensationmax) at 250.

## InstaGibPlus_11.NewNetSA

SniperArena, but with a ping compensated custom weapon.

## InstaGibPlus_11.NextSA

SniperArena with the deterministic SniperRifle. The server traces every shot itself and rewinds the other players by the shooter's ping, or by [bEnablePreciseRewindTime](#benablepreciserewindtime) if that is on. The sniper settings apply, such as the reduced hitbox, the reload time and the damage. Everyone gets `SA_SniperRifle`. It is the IG+ sniper with its client-side shell case and muzzle flash always on, and with the same hit sound and hit marker at the click as NextIG.

* Load it in place of ST_Mutator, not together with it.
* Its weapon settings are in the section `WeaponSettingsSniperArena`.
* The rules are those of NewNetSA. Everyone spawns with the rifle and 50 bullets, and a shot uses one.
* NextSA removes every weapon in the map. All other ammo becomes a bullet box, and a bullet box holds 50 bullets.
* There is no translocator, as in stock Sniper Arena and NewNetSA. The game's translocator setting does nothing here.
* A shot from a player who just died only counts with [bEnableTrades](#benabletrades) on in its weapon settings. It is off by default.
* A new server starts with ping compensation, [bEnableSubTickCompensation](#benablesubtickcompensation), [bEnablePreciseRewindTime](#benablepreciserewindtime) and [bEnableFireTimeOrder](#benablefiretimeorder) on, and with [PingCompensationMax](#pingcompensationmax) at 250.

## InstaGibPlus_11.MutFraggerArena

Similar to SniperArena, but with a Sniper Rifle that has custom zoom and is inaccurate when moving or not zoomed in, plus a translocator.

## InstaGibPlus_11.MutKillFeed

Allows players to replace the messages of players dying in the console with weapon icons in a configurable location on your screen.

# Usage
Load one weapon mutator for the mode you want, via your map vote configuration or during server launch.

| Mode | Mutator | Who decides a hit |
|---|---|---|
| Normal weapons | **InstaGibPlus_11.ST_Mutator** | The server, with ping compensation |
| InstaGib | **InstaGibPlus_11.NewNetIG** | The shooter's client |
| InstaGib | **InstaGibPlus_11.NextIG** | The server, with ping compensation |
| Sniper Arena | **InstaGibPlus_11.NewNetSA** | The shooter's client |
| Sniper Arena | **InstaGibPlus_11.NextSA** | The server, with ping compensation |

Load only one of them. With none of them loaded, players get the default UT weapons with no lag compensation.

When connected to the server type **'mutate playerhelp'** in the console to view the available commands and options.


# Admin Commands
- ShowIPs (Shows the IP of players)
- ShowID (Shows the ID of players)
- KickID x (Will Kick player with ID x)
- BanID x (Will Ban & Kick player with ID x)
- EnablePure/DisablePure
- ShowDemos (Will show who is recording demos)
- mutate IGPlusServerGet \<Setting\>
- mutate IGPlusServerSet \<Setting\> \<Value\>
- mutate IGPlusServerSetSilent \<Setting\> \<Value\>
- mutate PureShowTickrate
- mutate PureShowNetspeeds
- mutate PingCompSettings

As spectator, you may need to add 'mutate pure' + command (mutate pureshowtickrate)

# Server Settings
Server settings can be found inside InstaGibPlus.ini.

1. [NNAnnouncer](#nnannouncer)
1. [bUTPureEnabled](#butpureenabled)
1. [Advertise](#advertise)
1. [AdvertiseMsg](#advertisemsg)
1. [bAllowCenterView](#ballowcenterview)
1. [CenterViewDelay](#centerviewdelay)
1. [bAllowBehindView](#ballowbehindview)
1. [TrackFOV](#trackfov)
1. [bAllowMultiWeapon](#ballowmultiweapon)
1. [bFastTeams](#bfastteams)
1. [bUseClickboard](#buseclickboard)
1. [MinClientRate](#minclientrate)
1. [MaxClientRate](#maxclientrate)
1. [bAdvancedTeamSay](#badvancedteamsay)
1. [bWarmup](#bwarmup)
1. [WarmupTimeLimit](#warmuptimelimit)
1. [bCoaches](#bcoaches)
1. [bAutoPause](#bautopause)
1. [PauseTotalTime](#pausetotaltime)
1. [PauseTime](#pausetime)
1. [Timeouts](#timeouts)
1. [ForceModels](#forcemodels)
1. [ImprovedHUD](#improvedhud)
1. [bDelayedPickupSpawn](#bdelayedpickupspawn)
1. [bUseFastWeaponSwitch](#busefastweaponswitch)
1. [bTellSpectators](#btellspectators)
1. [PlayerPacks](#playerpacks)
1. [TeleRadius](#teleradius)
1. [ThrowVelocity](#throwvelocity)
1. [bForceDemo](#bforcedemo)
1. [bRestrictTrading](#brestricttrading)
1. [bEnableAllWeaponTrades](#benableallweapontrades)
1. [MaxTradeTimeMargin](#maxtradetimemargin)
1. [TradePingMargin](#tradepingmargin)
1. [KillCamDelay](#killcamdelay)
1. [KillCamDuration](#killcamduration)
1. [bJumpingPreservesMomentum](#bjumpingpreservesmomentum)
1. [bOldLandingMomentum](#boldlandingmomentum)
1. [bEnableSingleButtonDodge](#benablesinglebuttondodge)
1. [bUseFlipAnimation](#buseflipanimation)
1. [bEnableWallDodging](#benablewalldodging)
1. [bDodgePreserveZMomentum](#bdodgepreservezmomentum)
1. [MaxMultiDodges](#maxmultidodges)
1. [BrightskinMode](#brightskinmode)
1. [PlayerScale](#playerscale)
1. [bAlwaysRenderFlagCarrier](#balwaysrenderflagcarrier)
1. [bAlwaysRenderDroppedFlags](#balwaysrenderdroppedflags)
1. [MaxHitError](#maxhiterror)
1. [MaxJitterTime](#maxjittertime)
1. [MinNetUpdateRate](#minnetupdaterate)
1. [MaxNetUpdateRate](#maxnetupdaterate)
1. [bEnableInputReplication](#benableinputreplication)
1. [bEnableServerExtrapolation](#benableserverextrapolation)
1. [bPlayersAlwaysRelevant](#bplayersalwaysrelevant)
1. [bEnablePingCompensatedSpawn](#benablepingcompensatedspawn)
1. [JitterBoundingMode](#jitterboundingmode)
1. [bEnableSnapshotInterpolation](#benablesnapshotinterpolation)
1. [SnapshotInterpSendHz](#snapshotinterpsendhz)
1. [SnapshotInterpRewindMs](#snapshotinterprewindms)
1. [bEnableWarpFix](#benablewarpfix)
1. [WarpFixDelay](#warpfixdelay)
1. [bEnableAdaptiveBuffering](#benableadaptivebuffering)
1. [AdaptiveBufferingMax](#adaptivebufferingmax)
1. [bEnableTickInterpolation](#benabletickinterpolation)
1. [FireTimeout](#firetimeout)
1. [DetFireClockMargin](#detfireclockmargin)
1. [bEnablePredictedSwitching](#benablepredictedswitching)
1. [bEnablePushSafeAim](#benablepushsafeaim)
1. [bEnablePredictedSelfKnockback](#benablepredictedselfknockback)
1. [bEnableDeterministicTranslocator](#benabledeterministictranslocator)
1. [bEnablePredictedTranslocation](#benablepredictedtranslocation)
1. [bEnablePredictedDiscBoost](#benablepredicteddiscboost)
1. [bEnableCarcassCollision](#benablecarcasscollision)
1. [ShowTouchedPackage](#showtouchedpackage)
1. [ShowDamageNumberMode](#showdamagenumbermode)
1. [bEnableHitboxDebugMode](#benablehitboxdebugmode)
1. [ExcludeMapsForKickers](#excludemapsforkickers)
1. [HitFeedbackMode](#hitfeedbackmode)
1. [ForcedSettings](#forcedsettings)

## NNAnnouncer

**Type: bool**  
**Default: True**  

Whether to automatically add an announcer for multi-kills, or not.

## bUTPureEnabled

**Type: bool**  
**Default: True**  

Big switch to enable/disable IG+.

## Advertise

**Type: int**  
**Default: 1**  

Controls whether to add a tag to the server's name.

- `1` ➜ Add tag at the beginning of the server's name
- `2` ➜ Add tag at the end of the server's name
- anything else - Dont advertise

## AdvertiseMsg

**Type: int**  
**Default: 1**  

Controls the tag to add to the server's name

- `0` ➜ `[CSHP]`
- `1` ➜ `[IG+]`
- anything else ➜ `[PWND]`

## bAllowCenterView

**Type: bool**  
**Default: False**  

Whether to allow use of the bSnapLevel button or not.

## CenterViewDelay

**Type: float**  
**Default: 1**  
**Unit: s**  

If bAllowCenterView is True, controls how much time has to pass between uses of bSnapLevel.

## bAllowBehindView

**Type: bool**  
**Default: False**  

Whether to allow 3rd Person perspective or not.

## TrackFOV

**Type: int**  
**Default: 0**  

Controls how strictly the FOV is checked.

- `1` ➜ very strict, no zooming with sniper
- `2` ➜ looser, zooming with sniper possible
- anything else ➜ no restrictions

## bAllowMultiWeapon

**Type: bool**  
**Default: False**  

Whether to allow the multi-weapon bug to be (ab)used.

## bFastTeams

**Type: bool**  
**Default: True**  

Whether to allow the use of `mutate FixTeams`, `mutate NextTeam`, and `mutate ChangeTeam <Team>` or not. `True` enables the use of these commands, `False` disables.

## bUseClickboard

**Type: bool**  
**Default: True**  

Enables a set of alternative scoreboards that show the ready-status for players before the match has started.

## MinClientRate

**Type: int**  
**Default: 10000**  
**Unit: B/s**  

The server will force clients to use at least this netspeed.

## MaxClientRate

**Type: int**  
**Default: 25000**  
**Unit: B/s**  

Maximum netspeed allowed for clients.

## bAdvancedTeamSay

**Type: bool**  
**Default: True**  

Whether to allow the use of advanced TeamSay or not.
Advanced TeamSay allows showing game-information in your chat messages, by replacing the following with the corresponding information:

- `%H` ➜ "<Health> Health"
- `%h` ➜ "<Health>%"
- `%W` ➜ "<WeaponName>" or "Empty hands"
- `%A` ➜ "Shieldbelt and <Armor> Armor" or "<Armor> Armor"
- `%a` ➜ "SB <Armor>A" or "<Armor>A"
- `%P`, `%p` ➜ Current CTF objective

## bWarmup

**Type: bool**  
**Default: True**  

Whether to allow warmup in tournament games or not.

## WarmupTimeLimit

**Type: int**  
**Default: 0**  
**Unit: s**  

Maximum warmup length in seconds. `0` means no explicit warmup time limit.

### bCoaches

**Type: bool**  
**Default: False**  

Whether to allow spectators to coach teams in tournament games or not.

## bAutoPause

**Type: bool**  
**Default: True**  

Whether to automatically pause the game in tournament games or not.

## PauseTotalTime

**Type: int**  
**Default: 300**  

Maximum time a team may pause the game for.

## PauseTime

**Type: int**  
**Default: 60**  

Length of pause when a pause is triggered.

## Timeouts

**Type: int**  
**Default: 0**  

Maximum number of timeouts a team may take (used with coaches/tournament flow).

### ForceModels

**Type: int**  
**Default: 1**  

Force models mode.

- `1` ➜ Client controlled
- `2` ➜ Forced on
- anything else ➜ Disabled

## ImprovedHUD

**Type: int**  
**Default: 1**  

Enable various HUD improvements. Depends on PureClickBoard mutator (set [bUseClickboard](#buseclickboard) to `True`, or add mutator through configuration).

- `1` ➜ Show boots, Clock
- `2` ➜ In addition, show enhanced team info
- anything else ➜ dont show anything

## bDelayedPickupSpawn

**Type: bool**  
**Default: False**  

Enable or disable delayed first pickup spawn.

## bUseFastWeaponSwitch

**Type: bool**  
**Default: False**  

If `True`, use the fast weapon switch path.  
If `False`, use normal weapon switching behavior.

## bTellSpectators

**Type: bool**  
**Default: False**  

Enable or disable telling spectators of reason for kicks.

## PlayerPacks

**Type: string\[8\]**  
**Default: *empty***  

Config list of supported player packs

## HitFeedbackMode

**Type: EHitFeedbackMode**  
**Default: HFM_Always**  

Determines how server-side hit feedback is handled.

* `HFM_Disabled`: No feedback to clients
* `HFM_VisibleOnly`: Feedback only if client can see the victim
* `HFM_Always`: Feedback always provided

## TeleRadius

**Type: int**  
**Default: 210**  
**Unit: uu**  

Radius within which to telefrag enemies using translocator.

## ThrowVelocity

**Type: int**  
**Default: 750**  
**Unit: uu/s**  

Horizontal speed with which to throw weapons.

## bForceDemo

**Type: bool**  
**Default: False**  

Forces clients to do demos.

## MaxHitError

**Type: float**  
**Default: 10000**  
**Unit: uu**  

Distance to any position over the last 500ms for hits to be counted.

## ShowTouchedPackage

**Type: bool**  
**Default: False**  

Send package-names of touched actors to clients when those clients touch the actors.

## ShowDamageNumberMode

**Type: EShowDamageNumberMode**  
**Default: DMG_Disabled**  

Controls who sees damage numbers on screen, and whether the player who dealt the damage also gets a console line.

* `DMG_Disabled`: Nobody sees damage numbers
* `DMG_SpecOnly`: Spectators see them for the player they watch, if they turn on [bSpectatorShowDamageNumbers](#bspectatorshowdamagenumbers)
* `DMG_AlwaysHUD`: Players see the damage they deal, and spectators as above
* `DMG_AlwaysHUDConsole`: As `DMG_AlwaysHUD`, and the player who dealt the damage also gets a console line

NextIG shows no damage numbers, whatever this is set to. Every hit there is a kill.

## bEnableHitboxDebugMode

**Type: bool**  
**Default: False**  

If `True`, enables hitbox debug instrumentation.

## ExcludeMapsForKickers

**Type: string\[128\]**  
**Default: *empty***  

List of map names (with or without .unr) for maps that should not have their Kickers replaced with NN_Kickers.

## MaxJitterTime

**Type: float**  
**Default: 0.1**  
**Unit: s**  

Maximum time between updates by clients that's tolerated by IG+. Allowed position error scales with time since last update, up to this amount of time. Guideline setting is half the maximum supported ping.

## MinNetUpdateRate

**Type: float**  
**Default: 60**  
**Unit: Hz**  

Minimum frequency of client updates for server.

## MaxNetUpdateRate

**Type: float**  
**Default: 200**  
**Unit: Hz**  

Maximum frequency of client updates for server.

## bRestrictTrading

**Type: bool**  
**Default: True**  

If True, the server tries to determine who shot first, and prevents shots from players that are already dead and fired their last shot after their killer by in-game time from causing a trade.

If False, any shot made while alive on your client counts.

## MaxTradeTimeMargin

**Type: float**  
**Default: 0.1**  
**Unit: s**  

Maximum time after death (on server) that players can still fire their weapons. Only applies if [bRestrictTrading](#brestricttrading) is True. A negative value rejects every shot fired after death, which disables trading. This window applies to NewNet weapons, and to the IG+ shock rifle, rocket launcher, flak, bio, ripper and sniper when [bEnableAllWeaponTrades](#benableallweapontrades) is True.

## TradePingMargin

**Type: float**  
**Default: 0.5**  

Trade uncertainty relative to shooters ping. Reasonable values range from 0 to 1. Higher values lead to more trades.

## bEnableAllWeaponTrades

**Type: bool**  
**Default: False**  

If True, trades also work with the IG+ shock rifle (beam and combo), rocket launcher, flak cannon, bio rifle, ripper, sniper rifle and super shock rifle, not only the NewNet weapons. A shot that reaches the server just after its shooter died still counts if, by the same rule as the NewNet weapons ([bRestrictTrading](#brestricttrading), [MaxTradeTimeMargin](#maxtradetimemargin), [TradePingMargin](#tradepingmargin)), he fired it first. Rockets he was loading are kept for that window, so a release just after death still fires them; once the window is over, the load is dropped. A traded shot leaves from where his screen had him when he fired, as long as he could have got there since he died. Needs the weapon's bEnablePingCompensation. NextIG and NextSA do not read this setting. They have [bEnableTrades](#benabletrades) in their weapon settings.

## bEnableInputReplication

**Type: bool**
**Default: False**

If enabled, players will replicate their movement at a higher fidelity, in exchange for more upstream traffic.  
Players will replicate (up to) the 10 most recent simulation steps to the server at their selected NetUpdateRate.

Restrictions:
- Players should not run very high FPS (>500).
- Speed parameters of movement axis inputs are ignored.
- Pitch is only replicated within [-90°..+90°). Values outside this range may not be replicated correctly.

Disable to restore default netcode behavior.

## bEnableServerExtrapolation

**Type: bool**  
**Default: False**  

If enabled the server will extrapolate client movement when the client's movement updates are too far behind the server's timepoint.

Disable to restore default netcode behavior.

## bPlayersAlwaysRelevant

**Type: bool**  
**Default: True**  

If enabled the server will always replicate all players to each other, increasing network traffic in order to make sure players always appear on screen.

Disable to restore default netcode behavior.

## bEnablePingCompensatedSpawn

**Type: bool**  
**Default: True**  

If enabled, players will not become visible to others until they can actually move on their end.  
If disabled, players will stand on their spawn-point visible to other players without being able to move for the duration of their ping.

Disable to restore default netcode behavior.

## JitterBoundingMode

**Type: enum**  
**Default: JB_None**  

Selects which players get updates over more than [MaxJitterTime](#maxjittertime) cut down to MaxJitterTime, in order to reduce visible warping for other players.

| Value | Effect |
| --- | --- |
| `JB_None` | Disabled. Default netcode behavior. |
| `JB_CarrierOnly` | Bounds CTF flag carriers only. |
| `JB_All` | Bounds every player. |

`JB_CarrierOnly` is intended for CTF, where a lagging flag carrier warps and becomes hard to hit. Bounding costs the bounded player a position correction when it triggers, so restricting it to carriers keeps that cost off everyone else.

All modes share [MaxJitterTime](#maxjittertime).

Jitter bounding does not run while [bEnableAdaptiveBuffering](#benableadaptivebuffering) is on.

## bEnableSnapshotInterpolation

**Type: bool**  
**Default: False**  

If enabled, clients use snapshot interpolation for simulated proxies.

This feature is highly experimental and should be enabled only for controlled testing.

## SnapshotInterpSendHz

**Type: float**  
**Default: 30.0**  
**Unit: Hz**  

Snapshot send rate used by snapshot interpolation.

## SnapshotInterpRewindMs

**Type: float**  
**Default: 66.0**  
**Unit: ms**  

Interpolation rewind delay used by snapshot interpolation.

## bEnableWarpFix

**Type: bool**  
**Default: True**  

If enabled, other players will not be extrapolated indefinitely on clients. Instead, after a short amount of time they will be forcibly reset to the last position the client received from the server.

## WarpFixDelay

**Type: float**  
**Default: 0.25**  
**Unit: s**  

The amount of time that has to pass without an update from a player before forcing them back to their position on the server for all other clients. Also controls 

## bEnableAdaptiveBuffering

**Type: bool**  
**Default: False**  

Evens out the movement of a player whose packets arrive late or in clumps.

Without it the server runs every move the moment its packet arrives. When packets come late and together, that player stands still on the server and then covers all the missed time in one tick. Other players see a stop and a jump, and the player is hard to hit.

If set to `True`, the server keeps the moves of such a player in a short queue. It plays them at the pace the player made them. Other players then see an even path. When the queue runs empty the player stands still until the next move arrives, and carries on from that spot. The server never guesses the missing input, so the queue gives that player no corrections.

The player with the bad connection pays with delay. Their moves, shots and hit sounds come later by the time their moves wait, up to [AdaptiveBufferingMax](#adaptivebufferingmax). Their ping on the scoreboard includes that delay. The delay shrinks again once their packets arrive on time.

A player whose packets arrive on time is not queued. The server runs their moves on arrival, as with the setting off.

A player is queued when one of their moves arrives later than 2 server ticks plus one of their own move intervals. With [bEnableTickInterpolation](#benabletickinterpolation) on it is 4 ticks. The other clients then draw a player 2 ticks behind and carry them on for 2 more, so a move up to 4 ticks late shows as nothing, and queueing for it would only cost that player delay. They leave the queue once their usual lateness is back under 1.5 ticks plus half a move interval (3.5 ticks with Tick Interpolation) and the delay has run down.

Adaptive Buffering replaces jitter bounding. [JitterBoundingMode](#jitterboundingmode) does not run while this is on. Requires bEnableInputReplication to be False. Needs a server on version 469.

The server log gets a `[BUFFER]` line when a player enters or leaves the queue. It also gets a `[JITTER-SUMMARY]` line for each player at the end of a map. That line says how late the player's moves arrived, and how many of them were later than the slack that queues a player (`slackMs`, `overSlack`, and `overSlackEvents` for the times such a move came with none in the 3 seconds before it). It is written with the setting on or off.

## AdaptiveBufferingMax

**Type: int**  
**Default: 100**  
**Unit: ms**  

The most delay [bEnableAdaptiveBuffering](#benableadaptivebuffering) gives one player. Movement that arrives later than this runs at once, as with the setting off.

## bEnableTickInterpolation

**Type: bool**  
**Default: False**  

If enabled, a client draws every other player between two real updates from the server, a little in the past, instead of moving them forward by a guess. Every move then tells the server the exact tick position its target was drawn at, and the server stands the players between the same two snapshots. What the shooter's screen showed is the spot the server tests, at any frame rate and any ping.

How it works:

* The server numbers its ticks. With each player it sends the number of the tick that player's last move ran in, where the player stood at the end of that tick, and the time of that move in one byte. That costs about 12 bytes for each other player in each tick.
* A player is drawn at an even pace. A tick's spot is where the player's last move ended, and one tick runs more of a player's move time than the next. Drawn by tick number alone, a player who moves evenly speeds up and slows down from tick to tick, more the faster they move, so most on a jump pad. The client takes the moment to draw on an even clock of the player's own move time and draws the spot between the two updates around it. The shot reports that spot as a part of the way between those two updates, and the server stands the player there as before.
* The moment a player is drawn at runs on the client's own frame time. Each frame it moves on by exactly the time the frame took. It follows the moment the tick clock asks for only slowly, because that one shifts a little with every update that comes early or late. Close to a player's newest update it runs up to 15% slower, so a late update is met with a slightly slower body and not with one that stops.
* A dead player is hidden and has no updates. The server sends none while they are dead, and the client drops the ones from before. After the respawn they are drawn from their first update at the new spot, and until it arrives they are not drawn. The server tests them from that same update on.
* A position is sent in quarters of a unit. The engine sends a position rounded to whole units, so the quarters go in a byte of their own. The client draws and tests a player between these spots, and the server tests a shot against the same rounded spots. Tested against its exact spots, a shot that grazed a player by less than the rounding could count on one side and miss on the other. In whole units alone a walking player was drawn unevenly, because each spot was up to half a unit off.
* A client reads a player's update once per frame. When two updates arrive in one frame, or a packet is lost, it has no update for one tick and draws that player across the gap. A shot reports which two updates its target was drawn between, and the server stands the players between the same two, not between the two snapshots next to each other.
* The client keeps each player's last 16 updates. It draws a player behind the server's tick clock by the gap between that player's updates plus one tick, 2 ticks at least and 10 at most.
* Two updates too far apart to be movement, as after a teleporter, are not drawn as a slide. The player stays at the older one until the newer one's tick.
* Past a player's newest update the client carries them on by their velocity for at most 2 ticks. Then they stand still until the next update arrives. The shot tells the server when that was the case.
* A player the server holds still is not carried on at all. That is a player whose queue ran empty with [bEnableAdaptiveBuffering](#benableadaptivebuffering) on. The server says so, and the shot tells the server that the player was drawn standing.
* The animation is drawn from the same moment as the body. The client notes the animation the engine plays in every frame and shows the one from as long ago as the body is drawn behind.
* A hit test takes the crouch that came with the update the body is drawn from, as the server takes it from its snapshot of that tick.
* While a player's body stands still because their updates stopped, their animation stands still too and they make no footstep sounds.
* The client's own trace for the instant hit sound tests the players where the last frame drew them.
* Players are drawn with different delays, and the server stands them all at the one moment a move reports. So a move reports the moment of the player it aims at. The rifle of NextIG and the sniper of NextSA find that player with their own trace. Every other move takes the player nearest the line of sight, which covers the weapons with no trace of their own on the client: the shock rifle, the normal sniper, the minigun, the enforcer and the pulse gun.
* The same report carries how far behind their newest update that player was drawn. The server moves a new projectile of the shooter ahead by that delay, on top of the one-way ping, because the shooter led a target that was drawn that much in the past.

A player with `enableDebugData 1` gets one `Tick Interpolation:` line in the debug log for every other player every 30 seconds:

| Field | Meaning |
| --- | --- |
| `frames`, `updates` | Frames that player was drawn in, and updates that arrived |
| `past` | Share of frames drawn past the newest update |
| `stopped` | Share of frames the body stood still because no update was there |
| `held` | Share of frames the server held the player still |
| `delayMsAvg`, `delayMsMax` | How far behind the newest update the player was drawn |
| `gapTicksMax` | The longest gap between two updates, in server ticks |
| `back1`, `back3`, `backMax` | Frames that moved the body backwards by over 1 and over 3 units, and the largest such step |
| `paceMsMax` | The furthest one update's move time was off the even pace, in milliseconds |
| `resets`, `clockSnaps` | Times the stored updates were thrown away, and times the tick clock jumped |

A client's Location Offset Fix setting has no effect while this is on. The picture is later than without it, by the delay above. A player whose packets stall is drawn standing still for a moment and then catches up. [bEnableAdaptiveBuffering](#benableadaptivebuffering) evens that out on the server.

Needs [bEnablePingCompensation](#benablepingcompensation) and [bEnablePreciseRewindTime](#benablepreciserewindtime). Not used with [bEnableSnapshotInterpolation](#benablesnapshotinterpolation) or bEnableInputReplication. Players on lifts are drawn the same way, with no lift handling of their own yet.

## KillCamDelay

**Type: float**  
**Default: 0**  
**Unit: s**  

KillCam can not start before a player has been dead for this long.

## KillCamDuration

**Type: float**  
**Default: 2**  
**Unit: s**  

KillCam follows the killing player for this long after its start.

## bJumpingPreservesMomentum

**Type: bool**  
**Default: False**  

If False, players will be slowed down to ground speed upon landing, which prevents Bunny Hopping. If True, landing works like before.

## bOldLandingMomentum

**Type: bool**  
**Default: True**  

If True, players retain the momentum of their in-air movement upon landing. If False, players can cancel their momentum by moving in the opposite direction of their in-air movement.

## bEnableSingleButtonDodge

**Type: bool**  
**Default: True**  

Enables an input button clients can bind to a key, which makes the client dodge in the direction it is currently walking.

Button can be bound to a key by assigning Button bDodge to a key in User.ini under section \[Engine.Input\]

## bUseFlipAnimation

**Type: bool**  
**Default: True**  

If False, models will not do a flip when dodging forwards, but use an animation similar to that of all other dodge directions.

## bEnableWallDodging

**Type: bool**  
**Default: False**  

If enabled, allows players to dodge off of walls while in the air.

## bDodgePreserveZMomentum

**Type: bool**  
**Default: False**  

If True, preserves upward momentum (from lifts and regular jumps) when dodging. Downward momentum is always cancelled out.

## MaxMultiDodges

**Type: int**  
**Default: 1**  

How many additional dodges you can perform after the first dodge. Only applies when [bEnableWallDodging](#benablewalldodging) is True.

## BrightskinMode

**Type: int**  
**Default: 1**  

What brightskin mode is allowed for clients.

* 0 ➜ No brightskins allowed
* 1 ➜ Unlit skins allowed

## PlayerScale

**Type: float**  
**Default: 1.0**  

Scale factor for player models. Scales both DrawScale (visuals) and CollisionRadius/-Height (hitbox).

## bAlwaysRenderFlagCarrier

**Type: bool**  
**Default: False**  

If True, team-mates of flag carriers will be able to see the carrier through walls.

## bAlwaysRenderDroppedFlags

**Type: bool**  
**Default: False**  

If True, players are able to see their own flags through walls if those flags are currently dropped on the ground.

## ForcedSettings

**Type: ForcedSettingsEntry\[128\]**  
**Default: (Key="",Value="",Mode=0)**  

Type `ForcedSettingsEntry` is defined like this:  
```unrealscript
struct ForceSettingsEntry {
    var string Key;
    var string Value;
    var int Mode;
};
```

Each entry can be used to force a setting on clients:
* `Key` is the name of the setting to force
* `Value` is the value to force the setting to
* `Mode` describes how to force the setting:
  * `0` ➜ Initial only
  * `1` ➜ Always, but reset after leaving server
  * `2` ➜ Always, but don't reset (should not be used)

Settings forced with mode `1` or `2` are locked while the player is connected. They are grayed out in the settings menu, and IG+ commands refuse to change them. A value changed with the console `set` command is put back within half a second.

## bEnableCarcassCollision

**Type: bool**  
**Default: True**  

If True, carcasses left by dead players have collision. If false, carcasses will not have collision.

## FireTimeout

**Type: float**
**Default: 0.1**
**Unit: seconds**

Shots more than this long in the past are rejected.

## DetFireClockMargin

**Type: float**  
**Default: 0.5**  
**Unit: seconds**  

Stops clients whose clock runs fast, such as speed hacks, from firing deterministic weapons faster than normal. Normal lag does not trigger it. 0 or less disables the check.

## bEnablePredictedSwitching

**Type: bool**  
**Default: True**  

If True, weapon switches start on the client the moment the key is pressed instead of one round trip later, and the server applies them at the same timestamp: the holster, the swap and the moment the new weapon may fire land on the same instants on both sides. The server validates every switch and rolls the client back if it can't honour one. Requires bEnableInputReplication to be False, works with or without bUseFastWeaponSwitch, and IG+'s own HUD on the client. Switches the server makes itself (out of ammo, pickups, respawn) are unchanged. Players can turn it off for themselves with [bPredictedSwitching](#bpredictedswitching).

## bEnablePushSafeAim

**Type: bool**  
**Default: True**  

If True, a shot fired right after the shooter was pushed leaves from where the shooter's screen had them, not from where the push had already moved them on the server. Projectiles fired from a moving lift leave from where the shooter saw themselves on the lift, and meet the lift where the shooter saw it. With [bCameraCorrectionSmoothing](#bcameracorrectionsmoothing), shots go through the crosshair while the camera eases out a correction. Requires bEnableInputReplication to be False. The lift part needs the weapon's bEnablePingCompensation.

With this setting on or off, a shot leaves from the spot the shooter's own game client had them at whenever that spot is close to the server's. Close means no further apart than the movement code allows without a correction, about 1.7 units. The shooter's screen fired from there, and from the server's own spot a beam that grazed a player by less than that could hit on the screen and miss on the server. The server's hit line for a player with `enableDebugData 1` has `originGap`, the distance between the two spots, and `origin`, which is `client`, `push` or `server`.

## bEnablePredictedSelfKnockback

**Type: bool**  
**Default: True**  

If True, the push from your own rockets, flak slug, shock ball, ripper alt-fire and impact hammer is applied on your client the moment it happens, and the server applies the same push at the same point in your movement, so you aren't corrected a ping later. The server still decides the push. If it differs from what your client predicted, you get a normal correction. Requires bEnableInputReplication to be False and a 469 server. Projectiles also need their weapon's ping compensation.

## bEnableDeterministicTranslocator

**Type: bool**  
**Default: True**  

If True, translocator throws, recalls and translocations follow the same rules on client and server at the same timestamp, and you see your own disc from the moment you throw it. The server's disc follows your own moves, so TranslocatorCompensatePing is not used while this is on. Requires bEnableInputReplication to be False.

## bEnablePredictedTranslocation

**Type: bool**  
**Default: True**  

If True, translocating moves you to the disc on your screen the moment you press, instead of a round trip later. The server translocates you at the same timestamp. Works with the stock translocator and with [bEnableDeterministicTranslocator](#benabledeterministictranslocator). The stock translocator also needs TranslocatorCompensatePing. Requires bEnableInputReplication to be False. Players can turn it off for themselves with [bPredictedTranslocation](#bpredictedtranslocation).

## bEnablePredictedDiscBoost

**Type: bool**  
**Default: True**  

If True, shooting your own translocator disc with the shock beam or a shock combo pushes it on your screen right away, the same way the server does at the same timestamp. With [bEnablePredictedSelfKnockback](#benablepredictedselfknockback) also on, so do your own shock balls, rockets, flak slugs and ripper alt blades going off near it: the server pushes your disc on your moves, as it pushes you, so other players see it pushed when you are pushed by the same explosion. A projectile that hits something you didn't see (a player, mostly) is corrected a moment later. Requires [bEnableDeterministicTranslocator](#benabledeterministictranslocator). Players can turn it off for themselves with [bPredictedDiscBoost](#bpredicteddiscboost).

# Weapon Settings

Per-preset settings in the `[WeaponSettings*]` sections. Only the netcode-relevant ones are listed here.

Each weapon mutator reads its own section of InstaGibPlus.ini, and writes it with the default values the first time it runs:

| Mutator | Section |
|---|---|
| ST_Mutator | `WeaponSettingsOldNet` |
| NewNetIG, NewNetSA | `WeaponSettingsNewNet` |
| NextIG | `WeaponSettingsInstaGib` |
| NextSA | `WeaponSettingsSniperArena` |
| MutFraggerArena | `WeaponSettingsFraggerArena` |

The URL option `?IGPlusWeaponSettings=<section>` makes the mutator read another section.

## bEnablePingCompensation

**Type: bool**  
**Default: True**  

If enabled, hitscan shots are tested against where targets were on the shooter's screen: the server rewinds every player (and the lift they stand on) by the shooter's ping before tracing. Also switches supported ST_ weapons to the deterministic fire path (see Docs/DETERMINISTIC-NETCODE.md).

## PingCompensationMax

**Type: int**  
**Default: 200 (250 in NextIG and NextSA)**  
**Unit: ms**  

Upper bound on the rewind. Players above this ping are compensated as if they had this ping.

With [bEnablePreciseRewindTime](#benablepreciserewindtime) the rewind is the age of the picture a shot was aimed at, and that age is what this bound is compared with. It is the shooter's ping, plus the delay their screen draws other players with (about 20 ms with [bEnableTickInterpolation](#benabletickinterpolation), up to 80 for a target whose updates arrive unevenly), plus the delay [bEnableAdaptiveBuffering](#benableadaptivebuffering) runs the shooter's own moves with (up to AdaptiveBufferingMax). A shot older than the bound falls back to the average-ping rewind at this bound, and the shooter's own hit sound and marker can then be wrong. So a player with 300 ping is fully covered at about 350, and at about 450 while their moves are buffered by 100 ms.

The server keeps each player's last 128 positions, one for every tick a move ran in. That is one second at 128 ticks a second and 0.64 s at 200.

## ShockComboRewindMax

**Type: int**  
**Default: 0**  
**Unit: ms**  

A shock combo on its owner's own ball goes off where the owner saw the ball. If this is above 0, the players it hurts are also rewound to where the owner saw them, by the owner's ping but at most this long (and never past PingCompensationMax), like a beam hit. 0 hurts them where they are now. Combos on someone else's ball are never rewound. Needs bEnablePingCompensation.

## bEnableSubTickCompensation

**Type: bool**  
**Default: False** (True in NextIG and NextSA)  

If enabled, the rewound position is interpolated between the two snapshots around the target time instead of snapping to the older one.

## bEnablePreciseRewindTime

**Type: bool**  
**Default: False** (True in NextIG and NextSA)  

If enabled, a hitscan shot rewinds the other players to the moment the shooter's screen showed them, instead of guessing from the shooter's average ping. The server tells each player the server time of every update it sends. A shot then carries the update the shooter's screen showed and how long the screen had been moving players forward past it. The server places every player the same way: at their snapshot from that update, carried forward by their velocity for the same time. Network jitter, the wait for the server's next tick and ping changes stop moving the rewound players. It doesn't need bEnableSubTickCompensation. With bEnableWarpFix on, a player whose packets stalled for longer than WarpFixDelay stays where clients hold them. Shots traced later in the tick than the moves arrive (minigun, pulse beam, enforcer refire) use the same report. If the shot's rewind is above PingCompensationMax, or differs from the server's own ping measurement by more than PreciseRewindTimeMaxDeviationMs, the shot uses the old rewind. Needs bEnablePingCompensation and bEnableInputReplication off. Not used for a player with snapshot interpolation. Console `enableDebugData 1` writes a line per hitscan shot: the rewind used, the old rewind and how far the change moved the players.

## PreciseRewindTimeMaxDeviationMs

**Type: int**  
**Default: 60**  
**Unit: ms**  

How far a shot's [bEnablePreciseRewindTime](#benablepreciserewindtime) rewind may differ from the server's own ping measurement before the server falls back to the old rewind. Limits how much extra rewind a modified client can claim.

## bEnableTrades

**Type: bool**  
**Default: False**  

NextIG and NextSA only. If True, a shot that reaches the server just after its shooter died still counts, by the rule described under [bEnableAllWeaponTrades](#benableallweapontrades). In these two modes this setting decides in place of that server setting. The other modes do not read it.

## bEnableFireTimeOrder

**Type: bool**  
**Default: False** (True in NextIG and NextSA)  

Fire Time Order. It acts on the rifle of NextIG and on the sniper rifle in every mode.

Without it the server runs a shot the moment it reads the shot's packet. Two shots that reach the server in the same tick then run in the order their packets arrived, and the later click can win.

If set to `True`, the server notes the rifle and sniper shots of a tick and runs them once all of the tick's packets are read, the one fired first first. The fire time is the time stamp of the shot's move on the server's clock, plus half of the shooter's lowest ping of late. Two shots less than 2 ms apart keep the order they arrived in. A shooter killed by an earlier shot of the same tick loses his own shot, unless [bEnableTrades](#benabletrades) is on.

It adds no delay. A shot is still traced in the tick it arrived in. `fireShared` and `fireMoved` in the `[DET-SUMMARY]` line count how often it had something to do.

The server log gets one `[FIRE-ORDER]` line for each tick in which two or more such shots met. It lists the shooters in the order their shots ran, each with `agoMs`, how long before the tick the server reckons the shot was fired, and `arrived`, the place its packet had.

## RocketCompensatePing

**Type: bool**  
**Default: True**  

If enabled, projectiles are fast-forwarded by the shooter's ping at spawn, with targets rewound for each simulated step.

## FlakCompensatePing

**Type: bool**  
**Default: True**  

As [RocketCompensatePing](#rocketcompensateping), for flak chunks and slugs. With it off, the flak cannon does not use the deterministic fire path.

## RipperCompensatePing

**Type: bool**  
**Default: True**  

As [RocketCompensatePing](#rocketcompensateping), for ripper blades of both fire modes. With it off, the ripper does not use the deterministic fire path.

## BioCompensatePing

**Type: bool**  
**Default: True**  

As [RocketCompensatePing](#rocketcompensateping), for bio gel and the charged glob. With it off, the bio rifle does not use the deterministic fire path.

## PulseCompensatePing

**Type: bool**  
**Default: True**  

If enabled, pulse spheres are fast-forwarded by the shooter's ping at spawn, and the server tests the pulse beam against where the shooter saw the other players.

## TranslocatorCompensatePing

**Type: bool**  
**Default: False**  

If enabled, the disc is fast-forwarded by the thrower's ping. Not needed while [bEnableDeterministicTranslocator](#benabledeterministictranslocator) is on, which handles the disc itself.

## SniperUseReducedHitbox

**Type: bool**  
**Default: False**  

If enabled, the server tests sniper shots against a body cylinder with a smaller head cylinder on top, instead of the player's full collision cylinder. A shot that passes beside the head misses. [HeadHalfHeight](#headhalfheight) and [HeadRadius](#headradius) set the size of the head.

## ShockBeamUseReducedHitbox

**Type: bool**  
**Default: False**  

As [SniperUseReducedHitbox](#sniperusereducedhitbox), for the shock rifle's beam and the IG+ SuperShockRifle. The SuperShockRifle's own beam and its hit sound at the click follow the same rule as the server.

## EnforcerUseReducedHitbox

**Type: bool**  
**Default: False**  

As [SniperUseReducedHitbox](#sniperusereducedhitbox), for the enforcer.

## HeadHalfHeight

**Type: float**  
**Default: 7.5**  
**Unit: uu**  

Half the height of the head cylinder of the reduced hitbox. The head gets lower as the player crouches and is gone at a full crouch.

## HeadRadius

**Type: float**  
**Default: 11.0**  
**Unit: uu**  

Radius of the head cylinder of the reduced hitbox.

## bEnableAnimationAdaptiveHeadHitbox

**Type: bool**  
**Default: False**  

If enabled, the head cylinder of the reduced hitbox follows the player's animation, so it sits where the model's head is.

# Demos

The demo features only work in demos recorded on a server that runs this build.

**Client demos**
* Projectiles show where they were on your screen, and your own projectiles show from the moment you fired.
* Shock combos you set off show as they did on your screen.
* The match timer and the boots counter show, also in a spectator's demo.

**Server demos**
* Following a player in first person shows what that player saw: the exact view, the eye height, the zoom, and the other players where that player saw them.
* The followed player's hit markers, hit sounds, damage numbers and screen flashes show.
* The match timer and the boots counter show.
* The InstaGib rifle's beam and ring show, with NewNetIG and with NextIG. When you follow the shooter in first person, the beam starts at the gun.
* The followed player's messages, chat, announcer sounds and pickup messages show, and so do the match start countdown, killing sprees and the won or lost announcer.

[bDemoShowRealModels](#bdemoshowrealmodels) decides whether a demo shows forced models or the real ones.

# Server Log

Every IG+ event line in the server log ends with the server's clock time, for example `at=21:15:07`, so you can match a line to a player's report or to a demo.

When a match ends or a player leaves, the server writes one `[DET-SUMMARY]` line for that player, unless every count is zero:

| Field | Meaning |
|---|---|
| `throws`, `translocates` | Translocator throws and translocates |
| `landedApart` | Landings the player saw corrected |
| `absorbed` | Landings a little apart that the server took over, so the player saw nothing |
| `throwApart` | Throws the server could not start from the client's spot |
| `rejects` | Translocator actions the server refused |
| `late` | Translocator actions that arrived through a re-send or were held back |
| `jumpDropped` | Jumps at a landing that only the server took |
| `shotRefused` | Shots the client showed while the server's fire window was closed |
| `shotUnbound` | Shots the client showed while the server held another weapon |
| `switchMismatch` | Weapon switches the two sides resolved differently |
| `clockHolds` | Seconds in which shots were held by [DetFireClockMargin](#detfireclockmargin) |
| `hitShots` | NextIG and NextSA: shots that carried the result of the shooter's own trace |
| `hitNoData` | NextIG and NextSA: shots the server ran with no result from the shooter's own trace. The shot's own move was lost, and the server fired on the next one |
| `hitBoth` | Of those, shots that hit a player in both traces |
| `hitClientOnly` | Shots that hit a player only in the shooter's own trace. The shooter got a hit sound and the server counted a miss |
| `hitServerOnly` | Shots that hit a player only in the server's trace. The hit sound came a ping late |
| `hitHeadDiff` | NextSA: hits the two traces counted differently as head or body |
| `hitDrawnDiff` | Shots where the shooter's trace against the players as drawn on screen said the opposite of its trace against them where the server places them |
| `hitDrawnRight` | Of those, shots where the server agreed with the drawn players |
| `deadShots` | Rifle and sniper shots the shooter's client fired when the server already had the shooter dead. The server fired nothing |
| `fireShared` | Rifle and sniper shots that reached the server in the same tick as another player's shot. With [bEnableFireTimeOrder](#benablefiretimeorder) on, the server traces such shots once the tick's packets are all read, the one fired first first. The fire time is the move's time stamp mapped to the server's clock, less half the server's own ping measure. Shots fired less than 2 ms apart keep the order they arrived in. A shooter killed by an earlier shot of the same tick loses his own, unless trades are on. Needs a 469 server |
| `fireMoved` | Of those, the shots that ran in another place than they arrived in |
| `deadShotHits` | Of those, shots that hit a player in the shooter's own trace, so a hit sound played for a shot that did not count |
| `eyeUsed` | Rifle and sniper shots the server started at the eye height the shooter's client sent |
| `eyeRefused` | Shots whose sent eye height was more than 24 units from the server's own. The server used its own |
| `eyeDiffAvg`, `eyeDiffMax` | How far the sent eye height was from the server's own, in units |
| `originFar`, `originGapMax` | Rifle and sniper shots fired while the shooter's own spot was further from the server's than the movement code allows without a correction, and the largest such distance, in units |
| `ping`, `lostMoves` | The player's ping and lost moves |

The single lines behind the shot and switch counts are only written while [TraceInput](#traceinput) is on for that player.

Every shot counted in `hitClientOnly`, `hitServerOnly`, `hitDrawnDiff` or `deadShots` also writes one `[DET-HIT]` line. Its first word says which: `clientOnly`, `serverOnly`, `drawnOnly` (only the drawn players were hit), `drawnMissed` (only the drawn players were missed) or `deadShot`. It names the weapon, the nearest player on the server's line, the distance to that player and that player's speed, the rewind used and the shooter's ping. For a `clientOnly` line, `gapXY` and `gapZ` say by how many units the server's line passed that player's rewound body, and `blocked=True` means something solid was in between. `eyeDiff` is the shooter's eye height minus the server's own for that shot. A shooter with `enableDebugData 1` gets the same line in the debug log.

A player with `enableDebugData 1` also gets lines about their own movement, to show why the server corrected their position:

| Line | Meaning |
| --- | --- |
| `Dodge done`, `Dodge refused` | A dodge that happened, or one that could not (in the air with no wall near, or crouching). The number after it is the direction |
| `Jump done`, `Jump refused` | A jump that happened, or a jump key pressed while not on the ground |
| `Landed` | A landing |
| `Send CAP:` | The server corrected the position. The values are the move time, the server's physics, the client's physics, the square of the distance between the two positions, the limit, the server's speed (`sv`) and the speed the client reported (`cv`) |

Each of the first three kinds comes twice: `(client)` for what the player's own game did, and `(server)` for what the server did with the same move. Each side decides on its own copy of the player whether a dodge or a jump is possible. Where a pair differs, one side dodged or jumped alone, and corrections follow until the client has the server's state again, about one ping later.

The IG+ SuperShockRifle and the IG+ sniper start a shot at the shooter's eye. The client sends its eye height with the shot, and the server starts its trace there. Each side works out the eye height on its own, and only the client's follows view shake, so without this the server's line can be above or below the crosshair's line right after a hit, a landing or a step.

# Building

1. Go to the installation directory of UT99 in a command shell
2. Use `git clone https://github.com/utspect/InstaGibPlus` to clone the repo
3. Navigate to the newly created directory `InstaGibPlus`
4. Execute `Build.bat`
5. The result of the build process will be available in the `System` folder that is next to `Build.bat`

# Credits

**TimTim** - Original NewNet.  
**Deepu** - Ultimate NewNet.  
**AnthraX** - Lots and lots of help with debugging tricky problems.  
**spect** - Starting this project.  
**Deaod** - Maintenance.  
**UT99 Community** - For their endless patience, support and help testing and reporting bugs.  
**Epic** - For not open sourcing a 20 year old game running on their 20 year old engine.
