class IGPlus_TestCommandlet extends Commandlet
	dependson(ClientSettings); // the crosshair layer struct

// bbPlayer.IGPlus_OverCrouchTop for a 39 high body with radius 17.
function bool CrouchTopCase(float EntryZ, float DirZ, float Duck, bool bOver, float WantZ) {
	local float Z;
	return class'bbPlayer'.static.IGPlus_OverCrouchTop(EntryZ, DirZ, 17.0, 39.0, Duck, Z) == bOver && Abs(Z - WantZ) < 0.01;
}

function LogTestResult(bool Result, string TestName) {
	if (Result)
		Log(TestName@"succeeded");
	else
		Warn(TestName@"failed");
}

function bool TestDataBuffer() {
	LogTestResult(DataBuffer_by_default_is_empty(), "DataBuffer_by_default_is_empty");
	LogTestResult(DataBuffer_stores_bits(), "DataBuffer_stores_bits");
	LogTestResult(DataBuffer_stores_more_than_32_bits(), "DataBuffer_stores_more_than_32_bits");

	LogTestResult(Can_pass_buffer_to_functions(), "Can_pass_buffer_to_functions");

	return true;
}

function bool TestFunction(int test[3], int expected0, int expected1, int expected2) {
	return test[0] == expected0 && test[1] == expected1 && test[2] == expected2;
}

function bool Can_pass_buffer_to_functions() {
	local int buffer[3];

	buffer[0] = 0xDEADBEEF;
	buffer[1] = 0xC0FFEE;
	buffer[2] = 0xBAADD00D;

	return TestFunction(buffer, buffer[0], buffer[1], buffer[2]);
}

function bool DataBuffer_by_default_is_empty() {
	local IGPlus_DataBuffer B;
	B = new class'IGPlus_DataBuffer';

	return B.NumBits == 0;
}

function bool DataBuffer_stores_bits() {
	local IGPlus_DataBuffer B;
	local int Result;
	B = new class'IGPlus_DataBuffer';

	B.AddBits(3, 0xFF);
	B.ConsumeBits(3, Result);

	return B.NumBits == 3 && Result == 0x7;
}

function bool DataBuffer_stores_more_than_32_bits() {
	local IGPlus_DataBuffer B;
	local int Result;
	B = new class'IGPlus_DataBuffer';

	B.AddBits(32, 0xDEADBEEF);
	B.AddBits(16, 0xDEADBEEF);
	B.AddBits(8, 0xBA);
	B.AddBits(32, 0xC0FFEE);
	B.AddBits(16, 0xDEAD);
	B.AddBits(32, 0xDEADBEEF);

	// if (B.NumBits != 80) return false;

	// if (B.BitsData[0] != 0xDEADBEEF) return false;
	// if (B.BitsData[1] != 0xFFEEBEEF) return false;
	// if (B.BitsData[2] != 0x00C0) return false;

	Log(B.BitsData[0]@B.BitsData[1]@B.BitsData[2]);

	B.ConsumeBits(32, Result);
	Log("Result 1"@Result);
	if (Result != 0xDEADBEEF) return false;

	B.ConsumeBits(16, Result);
	Log("Result 2"@Result);
	if (Result != 0xBEEF) return false;

	B.ConsumeBits(8, Result);
	Log("Result 3"@Result);
	if (Result != 0xBA) return false;

	B.ConsumeBits(32, Result);
	Log("Result 4"@Result);
	if (Result != 0xC0FFEE) return false;

	B.ConsumeBits(16, Result);
	Log("Result 5"@Result);
	if (Result != 0xDEAD) return false;

	B.ConsumeBits(32, Result);
	Log("Result 6"@Result);
	if (Result != 0xDEADBEEF) return false;

	return B.NumBits == B.NumBitsConsumed;
}

function bool TestDetEffectiveAnimTime() {
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetEffectiveAnimTime(0.25, 0.5) - 0.25) < 0.0001,
		"Det_anim_time_config_below_default"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetEffectiveAnimTime(0.75, 0.5) - 0.75) < 0.0001,
		"Det_anim_time_config_above_default"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetEffectiveAnimTime(0.0, 0.5) - 0.005) < 0.0001,
		"Det_anim_time_zero_config_hits_speed_cap"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetEffectiveAnimTime(0.001, 0.5) - 0.005) < 0.0001,
		"Det_anim_time_tiny_config_hits_speed_cap"
	);
	// The select animation ends one frame short of the configured time.
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetSelectAnimTime(0.6, 0.5, 15) - 0.56) < 0.0001,
		"Det_select_time_shock_15_frames"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetSelectAnimTime(0.6, 0.607143, 17) - 0.564706) < 0.0001,
		"Det_select_time_sniper_17_frames"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetSelectAnimTime(0.0, 0.75, 30) - 0.00725) < 0.0001,
		"Det_select_time_zero_config_hits_speed_cap"
	);
	// The flak cannon's Loading after the select: stock speed 1.3, and the speed cap.
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetFlakPostSelectTime(1.3) - 0.408974) < 0.0001,
		"Det_flak_post_select_stock_speed"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetFlakPostSelectTime(100.0) - 0.054667) < 0.0001,
		"Det_flak_post_select_speed_cap"
	);
	// The NewNet rifles' select and down: 1.35, a 0.05 tween on the down only.
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetNewNetAnimTime(15, 30.0, 0.0) - 0.345679) < 0.0001,
		"Det_newnet_select_instagib_rifle"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetNewNetAnimTime(17, 28.0, 0.0) - 0.423280) < 0.0001,
		"Det_newnet_select_sniper"
	);
	LogTestResult(
		Abs(class'bbPlayer'.static.IGPlus_DetNewNetAnimTime(7, 27.0, 0.05) - 0.214609) < 0.0001,
		"Det_newnet_down_instagib_rifle"
	);
	// The rocket launcher loads as stock's animations do: one more rocket
	// every 0.9 s, the sixth 0.8333 s after the fifth.
	LogTestResult(class'ST_UT_Eightball'.static.DetRocketsForLoadTime(0.0) == 1, "Det_rockets_one_at_the_press");
	LogTestResult(class'ST_UT_Eightball'.static.DetRocketsForLoadTime(0.89) == 1
		&& class'ST_UT_Eightball'.static.DetRocketsForLoadTime(0.91) == 2, "Det_rockets_second_after_0.9");
	LogTestResult(class'ST_UT_Eightball'.static.DetRocketsForLoadTime(3.61) == 5
		&& class'ST_UT_Eightball'.static.DetRocketsForLoadTime(4.42) == 5, "Det_rockets_five_until_the_sixth_is_in");
	LogTestResult(class'ST_UT_Eightball'.static.DetRocketsForLoadTime(4.44) == 6
		&& class'ST_UT_Eightball'.static.DetRocketsForLoadTime(60.0) == 6, "Det_rockets_sixth_at_4.4333");
	// What the launcher's next count takes over from a late step.
	LogTestResult(Abs(class'ST_UT_Eightball'.static.DetCarryOf(0.03) - 0.03) < 0.0001, "Det_rockets_carry_a_held_frame");
	LogTestResult(class'ST_UT_Eightball'.static.DetCarryOf(0.07) == 0.0
		&& class'ST_UT_Eightball'.static.DetCarryOf(-0.5) == 0.0
		&& class'ST_UT_Eightball'.static.DetCarryOf(0.0) == 0.0, "Det_rockets_no_carry_for_a_later_press");
	// The bio rifle's alt charge: one step for every 0.5 s held, nine at most.
	LogTestResult(class'ST_ut_biorifle'.static.DetChargeSteps(0.49) == 0
		&& class'ST_ut_biorifle'.static.DetChargeSteps(0.51) == 1, "Det_bio_charge_first_step_after_0.5");
	LogTestResult(class'ST_ut_biorifle'.static.DetChargeSteps(3.6) == 7
		&& class'ST_ut_biorifle'.static.DetChargeSteps(4.49) == 8, "Det_bio_charge_a_step_every_0.5");
	LogTestResult(class'ST_ut_biorifle'.static.DetChargeSteps(4.51) == 9
		&& class'ST_ut_biorifle'.static.DetChargeSteps(60.0) == 9, "Det_bio_charge_nine_steps_at_most");
	// The launcher's client takes over the server's ready time after a volley.
	LogTestResult(Abs(class'ST_UT_Eightball'.static.DetReadyLeft(100.98, 100.0, 100.4) - 0.58) < 0.0001, "Det_rockets_ready_time_taken_over");
	LogTestResult(class'ST_UT_Eightball'.static.DetReadyLeft(100.05, 100.0, 100.01) < 0.0, "Det_rockets_ready_time_of_an_older_volley_ignored");
	LogTestResult(class'ST_UT_Eightball'.static.DetReadyLeft(100.9, 99.0, 101.0) < 0.0
		&& class'ST_UT_Eightball'.static.DetReadyLeft(103.0, 100.0, 100.5) < 0.0, "Det_rockets_ready_time_past_or_too_far_ignored");
	// Which kinds of weapon run deterministic: 3 the flak cannon, 2 the ripper, 4 the bio rifle, 5 the launcher,
	// 1, 6 and 7 the shock rifle, the sniper and the instagib rifle.
	LogTestResult(class'bbPlayer'.static.IGPlus_DetKindRuns(3, true, true, false, true, true) == false
		&& class'bbPlayer'.static.IGPlus_DetKindRuns(3, false, false, true, false, false), "Det_kind_flak_by_its_own_setting");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetKindRuns(2, true, false, true, true, true) == false
		&& class'bbPlayer'.static.IGPlus_DetKindRuns(4, true, true, true, false, true) == false
		&& class'bbPlayer'.static.IGPlus_DetKindRuns(5, true, true, true, true, false) == false, "Det_kind_ripper_bio_rockets_by_their_own");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetKindRuns(1, true, false, false, false, false)
		&& class'bbPlayer'.static.IGPlus_DetKindRuns(6, true, false, false, false, false)
		&& class'bbPlayer'.static.IGPlus_DetKindRuns(7, false, true, true, true, true) == false
		&& class'bbPlayer'.static.IGPlus_DetKindRuns(0, true, true, true, true, true) == false, "Det_kind_rifles_by_the_main_setting");
	// A move that still names a deterministic weapon we no longer hold: (Predicted Switching, hammer in hand).
	LogTestResult(class'bbPlayer'.static.IGPlus_DetStaleBlockRule(false, false) == false, "Det_stale_binding_lets_held_fire_through_without_predicted_switching");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetStaleBlockRule(true, false), "Det_stale_binding_blocks_with_predicted_switching");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetStaleBlockRule(false, true), "Det_stale_binding_blocks_for_the_hammer");
	// The deterministic translocator's bring-up is its animation: Select, or the tween to ThrownFrame with a disc out.
	LogTestResult(class'ST_Translocator'.static.IGPlus_DetBringUpOver('Select', true) == false
		&& class'ST_Translocator'.static.IGPlus_DetBringUpOver('ThrownFrame', true) == false, "Det_tloc_bring_up_lasts_while_its_animation_plays");
	LogTestResult(class'ST_Translocator'.static.IGPlus_DetBringUpOver('Select', false)
		&& class'ST_Translocator'.static.IGPlus_DetBringUpOver('ThrownFrame', false), "Det_tloc_bring_up_is_over_when_its_animation_has_ended");
	LogTestResult(class'ST_Translocator'.static.IGPlus_DetBringUpOver('Still', true), "Det_tloc_bring_up_is_over_once_another_animation_plays");
	// A resent translocator action: packed with its view, and due for a move between the last one run and this one.
	LogTestResult((class'bbPlayer'.static.IGPlus_DetPackRedo(7, (0x1230 << 16) | 0xABC0) & 7) == 7
		&& class'bbPlayer'.static.IGPlus_DetUnpackRedoView(class'bbPlayer'.static.IGPlus_DetPackRedo(1, (0x1230 << 16) | 0xABC0)) == ((0x1230 << 16) | 0xABC0),
		"Det_tloc_resend_keeps_action_and_view");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetRedoDue(1, 5.2, 5.0, 5.5)
		&& class'bbPlayer'.static.IGPlus_DetRedoDue(1, 4.9, 5.0, 5.5) == false
		&& class'bbPlayer'.static.IGPlus_DetRedoDue(1, 5.6, 5.0, 5.5) == false
		&& class'bbPlayer'.static.IGPlus_DetRedoDue(0, 5.2, 5.0, 5.5) == false, "Det_tloc_resend_is_due_between_the_last_move_and_this_one");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetPressOf(true, true) == 1 && class'bbPlayer'.static.IGPlus_DetPressOf(false, true) == 2
		&& class'bbPlayer'.static.IGPlus_DetPressOf(false, false) == 0, "Det_tloc_early_click_fire_first");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetSpawnWaitOver(10.4, 10.0, 0.5) == false && class'bbPlayer'.static.IGPlus_DetSpawnWaitOver(10.5, 10.0, 0.5)
		&& class'bbPlayer'.static.IGPlus_DetSpawnWaitOver(0.2, 0.0, 0.5), "Det_tloc_first_throw_waits_after_spawn");
	LogTestResult(class'bbPlayer'.static.IGPlus_DetHoldsTloc(3, 2, 1) && class'bbPlayer'.static.IGPlus_DetHoldsTloc(3, 0, 3)
		&& class'bbPlayer'.static.IGPlus_DetHoldsTloc(1, 2, 1) == false && class'bbPlayer'.static.IGPlus_DetHoldsTloc(3, 1, 1) == false
		&& class'bbPlayer'.static.IGPlus_DetHoldsTloc(0, 2, 1) == false, "Det_tloc_no_correction_while_a_translocate_is_held_for_a_switch");
	return true;
}

function TestTranslocatorFireMerging() {
	LogTestResult(!class'ST_Translocator'.static.CanMergeFireInput(true, false, false, true),
		"Translocator_throw_then_teleport_stays_separate");
	LogTestResult(!class'ST_Translocator'.static.CanMergeFireInput(false, true, true, false),
		"Translocator_teleport_then_throw_stays_separate");
	LogTestResult(!class'ST_Translocator'.static.CanMergeFireInput(true, false, false, false),
		"Translocator_primary_release_stays_separate");
	LogTestResult(!class'ST_Translocator'.static.CanMergeFireInput(false, true, false, false),
		"Translocator_alt_release_stays_separate");
	LogTestResult(!class'ST_Translocator'.static.CanMergeFireInput(true, true, true, false),
		"Translocator_dual_hold_release_stays_separate");
	LogTestResult(class'ST_Translocator'.static.CanMergeFireInput(true, true, true, true),
		"Translocator_real_dual_hold_is_preserved");
	LogTestResult(class'ST_Translocator'.static.CanMergeFireInput(true, false, true, false),
		"Translocator_unchanged_primary_hold_can_merge");
}

// Two standing players (radius 17, half height 39): a telefrag needs their
// bodies to overlap, as the engine tests it.
function TestTelefragOverlap() {
	LogTestResult(class'ST_Translocator'.static.IGPlus_CylindersOverlap(vect(0,0,0), 17, 39, vect(33,0,0), 17, 39),
		"Telefrag_bodies_33_units_apart_overlap");
	LogTestResult(!class'ST_Translocator'.static.IGPlus_CylindersOverlap(vect(0,0,0), 17, 39, vect(34,0,0), 17, 39),
		"Telefrag_bodies_34_units_apart_do_not");
	LogTestResult(class'ST_Translocator'.static.IGPlus_CylindersOverlap(vect(0,0,0), 17, 39, vect(20,20,77), 17, 39),
		"Telefrag_bodies_overlap_diagonally_and_77_units_up");
	LogTestResult(!class'ST_Translocator'.static.IGPlus_CylindersOverlap(vect(0,0,0), 17, 39, vect(0,0,78), 17, 39),
		"Telefrag_bodies_78_units_up_do_not");
}

// A shock ball (radius and half height 12) and a standing player (17 and 39):
// where on a tick's way the two first overlap, which is the touch the ball's
// owner's beam is timed against (ST_ShockProj.IGPlus_TouchWait).
function TestShockBallTouchFraction() {
	LogTestResult(Abs(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(-100,0,0), vect(0,0,0), vect(0,0,0), 29, 51) - 0.71) < 0.001,
		"ShockBallTouch_head_on_at_29_units_from_the_middle");
	LogTestResult(Abs(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(-100,20,0), vect(0,20,0), vect(0,0,0), 29, 51) - 0.79) < 0.001,
		"ShockBallTouch_20_units_beside_the_middle_is_later");
	LogTestResult(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(-100,30,0), vect(0,30,0), vect(0,0,0), 29, 51) == 1.0,
		"ShockBallTouch_30_units_beside_the_middle_passes");
	LogTestResult(Abs(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(0,0,151), vect(0,0,51), vect(0,0,0), 29, 51) - 1.0) < 0.001
		&& Abs(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(0,0,151), vect(0,0,1), vect(0,0,0), 29, 51) - 0.6667) < 0.001,
		"ShockBallTouch_from_above_at_the_top_of_the_head");
	LogTestResult(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(-10,0,0), vect(50,0,0), vect(0,0,0), 29, 51) == 0.0,
		"ShockBallTouch_overlapping_at_the_start_is_0");
	LogTestResult(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(-100,0,60), vect(0,0,60), vect(0,0,0), 29, 51) == 1.0,
		"ShockBallTouch_over_the_head_passes");
	LogTestResult(class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(40,0,0), vect(40,0,0), vect(0,0,0), 29, 51) == 1.0
		&& class'ST_ShockProj'.static.IGPlus_TouchFraction(vect(20,0,0), vect(20,0,0), vect(0,0,0), 29, 51) == 0.0,
		"ShockBallTouch_a_ball_that_stands_still");
}

// Simulates 200 Hz moves against a server ticking every 10 ms. The client
// clock runs at ClientRate from HackAt on; a spike holds packets in flight
// and delivers them together. Returns the highest lead after the 2 s learn.
function float SimFireClockLead(float ClientRate, float Seconds, optional float SpikeAt, optional float SpikeLen, optional float HackAt) {
	local float Baseline, Lead, MaxLead, T, ClientT, ServerT, LastServerT;
	local int i, N;
	local bool bInit;

	N = int(Seconds / 0.005);
	for (i = 0; i < N; i++) {
		T = i * 0.005;
		if (T < HackAt)
			ClientT = T;
		else
			ClientT = HackAt + (T - HackAt) * ClientRate;
		if (SpikeLen > 0 && T >= SpikeAt && T < SpikeAt + SpikeLen)
			ServerT = SpikeAt + SpikeLen;
		else
			ServerT = T;
		ServerT = int(ServerT / 0.01) * 0.01;
		if (!bInit) {
			Baseline = ClientT - ServerT;
			bInit = true;
		} else {
			Baseline = class'bbPlayer'.static.IGPlus_DetNextClockBaseline(
				Baseline, ClientT - ServerT, ServerT - LastServerT, ServerT < 2.0);
		}
		LastServerT = ServerT;
		Lead = (ClientT - ServerT) - Baseline;
		if (ServerT >= 2.0)
			MaxLead = FMax(MaxLead, Lead);
	}
	return MaxLead;
}

// The next shot's due time (bbPlayer.IGPlus_DetNextShotTS): a held refire
// counts from when the shot was due, a later one from its own step.
function float SimHeldRefireGap(float FrameTime, float Interval, int Shots) {
	local float T, Due, First;
	local int N;

	// Frames of FrameTime, the button held, as bbPlayer.IGPlus_DetIntervalShotDue decides.
	T = 100.0;
	while (N <= Shots) {
		if (T + 0.0001 >= Due) {
			if (N == 0)
				First = T;
			Due = class'bbPlayer'.static.IGPlus_DetNextShotTS(T, Due, Interval);
			N++;
		}
		if (N <= Shots)
			T += FrameTime;
	}
	return (T - First) / float(Shots);
}

function TestDetNextShot() {
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_DetNextShotTS(10.0, 0.0, 1.0) - 11.0) < 0.0001,
		"DetNextShot_first_shot_counts_from_its_step");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_DetNextShotTS(10.03, 10.0, 1.0) - 11.0) < 0.0001,
		"DetNextShot_a_frame_late_counts_from_the_due_time");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_DetNextShotTS(9.99995, 10.0, 1.0) - 11.0) < 0.0001,
		"DetNextShot_inside_the_due_tolerance_counts_from_the_due_time");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_DetNextShotTS(10.2, 10.0, 1.0) - 11.2) < 0.0001,
		"DetNextShot_a_later_press_counts_from_its_step");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_DetNextShotTS(10.07, 10.0, 1.0) - 11.07) < 0.0001,
		"DetNextShot_past_the_carry_limit_counts_from_its_step");
	// The rifle's interval at 30, 60 and 500 frames a second: the same rate at each.
	LogTestResult(Abs(SimHeldRefireGap(1.1 / 30.0, 1.0727, 200) - 1.0727) < 0.0005,
		"DetNextShot_held_rate_at_30_fps_is_the_interval");
	LogTestResult(Abs(SimHeldRefireGap(1.1 / 60.0, 1.0727, 200) - 1.0727) < 0.0005,
		"DetNextShot_held_rate_at_60_fps_is_the_interval");
	LogTestResult(Abs(SimHeldRefireGap(1.1 / 500.0, 1.0727, 200) - 1.0727) < 0.0005,
		"DetNextShot_held_rate_at_500_fps_is_the_interval");
	// The ripper's interval at 30 frames a second.
	LogTestResult(Abs(SimHeldRefireGap(1.1 / 30.0, 0.3846, 400) - 0.3846) < 0.0005,
		"DetNextShot_short_interval_at_30_fps_is_the_interval");
}

// IGPlus_Glide: the share of the skipped path still to close, from the gun
// (1) to the projectile's real spot (0), never back, no jump in speed at
// either end.
function TestGlideGap() {
	local float A, Last;
	local bool bDown;

	bDown = true;
	Last = 1.0;
	for (A = 0.05; A <= 1.0; A += 0.05) {
		if (class'IGPlus_Glide'.static.GapLeft(A) > Last)
			bDown = false;
		Last = class'IGPlus_Glide'.static.GapLeft(A);
	}
	LogTestResult(class'IGPlus_Glide'.static.GapLeft(0.0) == 1.0 && class'IGPlus_Glide'.static.GapLeft(1.0) == 0.0
		&& class'IGPlus_Glide'.static.GapLeft(-0.5) == 1.0 && class'IGPlus_Glide'.static.GapLeft(1.5) == 0.0,
		"GlideGap_starts_at_the_gun_and_ends_on_the_real_spot");
	LogTestResult(bDown, "GlideGap_only_closes");
	LogTestResult(class'IGPlus_Glide'.static.GapLeft(0.01) > 0.999 && class'IGPlus_Glide'.static.GapLeft(0.99) < 0.001,
		"GlideGap_leaves_the_gun_and_lands_at_flying_speed");
	LogTestResult(class'IGPlus_Glide'.static.GlideTime() > 0.0 && class'IGPlus_Glide'.static.GlideTime() <= 0.2,
		"GlideGap_closes_within_a_fifth_of_a_second");
	// The fastest it is drawn: its speed plus the gap over the glide's time,
	// 1.5 times that at the curve's steepest.
	LogTestResult(class'IGPlus_Glide'.static.GlideTimeFor(0.05) == class'IGPlus_Glide'.static.GlideTime()
		&& 1.0 + 1.5 * 0.3 / class'IGPlus_Glide'.static.GlideTimeFor(0.3) <= 2.5001
		&& 1.0 + 1.5 * 0.05 / class'IGPlus_Glide'.static.GlideTimeFor(0.05) <= 2.5001,
		"GlideGap_never_draws_it_over_two_and_a_half_times_its_speed");
}

// The shooter's own copy and the server's projectile leave the gun at the
// same speed from spots Gap apart: the step from the copy to the server's
// path is Gap, less the part along the copy's flight.
function bool OwnCopyStepIs(vector Gap, vector Launch, vector Gravity, float CopyT, float ServerT) {
	local vector C, V, S, SV, Dir, Want;

	C = Launch * CopyT + 0.5 * Gravity * CopyT * CopyT;
	V = Launch + Gravity * CopyT;
	S = Gap + Launch * ServerT + 0.5 * Gravity * ServerT * ServerT;
	SV = Launch + Gravity * ServerT;
	Dir = Normal(V);
	Want = Gap - Dir * (Gap dot Dir);
	return VSize(class'IGPlus_OwnCopy'.static.PathStep(C, V, S, SV, Gravity) - Want) < 0.01;
}

function TestOwnCopyPathStep() {
	LogTestResult(OwnCopyStepIs(vect(0,0,5), vect(1100,-440,200), vect(0,0,-950), 0.3, 0.2)
		&& OwnCopyStepIs(vect(0,0,-9), vect(300,0,700), vect(0,0,-950), 0.05, 0.02),
		"OwnCopy_falling_copy_steps_onto_the_servers_path");
	LogTestResult(OwnCopyStepIs(vect(0,3,-7), vect(2000,500,-300), vect(0,0,0), 0.2, 0.1),
		"OwnCopy_straight_copy_steps_onto_the_servers_path");
	LogTestResult(OwnCopyStepIs(vect(0,0,0), vect(1100,-440,200), vect(0,0,-950), 0.3, 0.2)
		&& class'IGPlus_OwnCopy'.static.PathStep(vect(0,0,0), vect(0,0,0), vect(5,5,5), vect(0,0,0), vect(0,0,0)) == vect(0,0,0),
		"OwnCopy_no_step_on_the_same_path_or_at_rest");
}

function TestDetFireClockLead() {
	LogTestResult(SimFireClockLead(1.0, 10.0) < 0.02, "FireClockLead_synced_clock_stays_near_zero");
	LogTestResult(SimFireClockLead(1.005, 60.0) < 0.05, "FireClockLead_small_drift_is_absorbed");
	LogTestResult(SimFireClockLead(1.0, 30.0, 5.0, 1.0) < 0.05, "FireClockLead_1s_lag_spike_never_builds_lead");
	LogTestResult(SimFireClockLead(1.0, 10.0, 0.0, 1.5) < 0.05, "FireClockLead_hitch_while_connecting_is_learned");
	LogTestResult(SimFireClockLead(1.5, 5.0, 0, 0, 3.0) > 0.5, "FireClockLead_speedhack_exceeds_default_margin_within_2s");
}

function TestPreciseRewindTimeReport() {
	LogTestResult(class'bbPlayer'.static.IGPlus_PRTTicksBack(500, class'bbPlayer'.static.IGPlus_PRTPack(497, 0.0123)) == 3,
		"PRT_report_finds_its_tick");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_PRTAge(class'bbPlayer'.static.IGPlus_PRTPack(497, 0.0123)) - 0.0123) < 0.0001,
		"PRT_report_keeps_its_age");
	LogTestResult(class'bbPlayer'.static.IGPlus_PRTTicksBack(32772, class'bbPlayer'.static.IGPlus_PRTPack(32770, 0)) == 2,
		"PRT_report_tick_survives_wrap");
	LogTestResult(class'bbPlayer'.static.IGPlus_PRTTicksBack(10, class'bbPlayer'.static.IGPlus_PRTPack(12, 0)) >= 64,
		"PRT_report_from_the_future_is_too_old");
	// (15 bits of 0.1 ms: the top bit of the report marks a tick position.)
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_PRTAge(class'bbPlayer'.static.IGPlus_PRTPack(5, 9.0)) - 3.2767) < 0.0001,
		"PRT_report_long_age_clamps_and_stays_positive");
	LogTestResult((class'bbPlayer'.static.IGPlus_PRTPack(0, 0) & 0x8000) != 0,
		"PRT_report_is_always_marked");
}

// A traded shot leaves from the client's spot only within this reach of
// where we died (stock speeds: dodge 600, JumpZ 325, accel 2048, gravity 950).
function TestTradeReach() {
	LogTestResult(class'bbPlayer'.static.IGPlus_TradeReach(440, 600, 325, 2048, 950, 0.0) == 16.0,
		"TradeReach_no_time_allows_16uu");
	// Running at 440, dodging sideways for 0.15s: about 113uu.
	LogTestResult(class'bbPlayer'.static.IGPlus_TradeReach(440, 600, 325, 2048, 950, 0.15) > 113.0,
		"TradeReach_covers_a_dodge_while_running");
	LogTestResult(class'bbPlayer'.static.IGPlus_TradeReach(0, 600, 325, 2048, 950, 0.1) < 150.0,
		"TradeReach_standing_still_stays_under_150uu_in_0.1s");
}

// A shot's eye height and its move's time share one int (bbPlayer.SendSavedMove).
function TestShotEyePacking() {
	local int P;

	LogTestResult(class'bbPlayer'.static.IGPlus_EyeUnpack(class'bbPlayer'.static.IGPlus_EyePack(27.0)) == 27.0,
		"ShotEye_default_eye_height_survives");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_EyeUnpack(class'bbPlayer'.static.IGPlus_EyePack(12.37)) - 12.37) <= 0.25,
		"ShotEye_is_within_a_quarter_unit");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_EyeUnpack(class'bbPlayer'.static.IGPlus_EyePack(-14.85)) + 14.85) <= 0.25,
		"ShotEye_below_the_body_centre_survives");
	LogTestResult(class'bbPlayer'.static.IGPlus_EyePack(-500.0) == 1 && class'bbPlayer'.static.IGPlus_EyePack(500.0) == 255,
		"ShotEye_clamps_and_is_never_zero");
	P = class'bbPlayer'.static.IGPlus_PackDeltaEye(0.016, 150);
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_UnpackDelta(P) - 0.016) < 0.00002 && (P >>> 24) == 150 && (P & 0xFF) == 0,
		"MoveDelta_and_eye_unpack_apart");
	P = class'bbPlayer'.static.IGPlus_PackDeltaEye(0.4, 255);
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_UnpackDelta(P) - 0.4) < 0.00002 && (P >>> 24) == 255,
		"MoveDelta_longest_frame_with_highest_eye");
	P = class'bbPlayer'.static.IGPlus_PackDeltaEye(5.0, 0);
	LogTestResult(class'bbPlayer'.static.IGPlus_UnpackDelta(P) < 1.0 && class'bbPlayer'.static.IGPlus_UnpackDelta(P) > 0.999 && (P >>> 24) == 0,
		"MoveDelta_clamps_under_a_second_and_leaves_the_eye_alone");
}

// Fire order inside one tick (bbPlayer.IGPlus_ShotRunsFirst): the values are
// how long before now each shot was fired.
function TestFireOrder() {
	// Fired 10 ms earlier than the shot that arrived first: runs first.
	LogTestResult(class'bbPlayer'.static.IGPlus_ShotRunsFirst(0.040, 0.030, 0.002),
		"FireOrder_the_earlier_click_runs_first");
	// Fired later than the shot that arrived first: stays behind it.
	LogTestResult(class'bbPlayer'.static.IGPlus_ShotRunsFirst(0.020, 0.030, 0.002) == false,
		"FireOrder_the_later_click_stays_behind");
	// 1 ms apart is inside the margin: the order they arrived in stays.
	LogTestResult(class'bbPlayer'.static.IGPlus_ShotRunsFirst(0.031, 0.030, 0.002) == false,
		"FireOrder_inside_the_margin_keeps_arrival_order");
	LogTestResult(class'bbPlayer'.static.IGPlus_ShotRunsFirst(0.030, 0.030, 0.002) == false,
		"FireOrder_a_tie_keeps_arrival_order");
}

// Tick Interpolation: the tick position a shot reports, and the tick number
// of an update from its low 8 bits.
function TestTickInterp() {
	local int P;

	P = class'bbPlayer'.static.IGPlus_TI_Pack(70000.5);
	LogTestResult(P < 0 && Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 70003) - 70000.5) < 0.005,
		"TickInterp_report_round_trip_with_the_mark_bit");
	// The server's tick number has gone past a 15 bit wrap since the report.
	P = class'bbPlayer'.static.IGPlus_TI_Pack(32766.25);
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 32770) - 32766.25) < 0.005,
		"TickInterp_report_across_the_15_bit_wrap");
	P = class'bbPlayer'.static.IGPlus_TI_Pack(500.75, true);
	LogTestResult((P & (1 << 24)) != 0 && Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 501) - 500.75) < 0.005,
		"TickInterp_report_keeps_its_place_with_the_past_mark");
	LogTestResult(class'bbPlayer'.static.IGPlus_PRTPack(100, 9.0) > 0,
		"TickInterp_an_age_report_never_carries_the_mark_bit");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_FullTick(250, 1020) == 1018,
		"TickInterp_stamp_two_ticks_back");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_FullTick(2, 1023) == 1026,
		"TickInterp_stamp_ahead_of_our_own_number");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_FullTick(255, 1023) == 1023,
		"TickInterp_stamp_of_this_tick");
	P = class'bbPlayer'.static.IGPlus_TI_Pack(500.75, true, true);
	LogTestResult((P & (1 << 25)) != 0 && (P & (1 << 24)) != 0 && Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 501) - 500.75) < 0.005,
		"TickInterp_report_keeps_its_place_with_the_held_mark");
	// Held only counts for a player drawn past their newest update.
	P = class'bbPlayer'.static.IGPlus_TI_Pack(500.75, false, true);
	LogTestResult((P & (1 << 25)) == 0,
		"TickInterp_no_held_mark_without_the_past_mark");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_CarryTicks(1.25, false) == 1.25,
		"TickInterp_carried_on_past_the_newest_update");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_CarryTicks(7.0, false) == 2.0,
		"TickInterp_carry_stops_after_two_ticks");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_CarryTicks(1.25, true) == 0.0,
		"TickInterp_a_held_player_is_not_carried_on");
	// A lift's travel over the drawing delay (IGPlus_TI_LiftTravel). An even
	// move of 600 units in 1 s, 25 ms back from its middle: 15 units.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_LiftTravel(0.5, 1.0, false, -1.0, 0.025, 600.0) - 15.0) < 0.01,
		"TickInterp_lift_travel_in_the_middle_of_a_move");
	// It started 10 ms ago: only those 10 ms count, it stood still before.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_LiftTravel(0.01, 1.0, false, -1.0, 0.025, 600.0) - 6.0) < 0.01,
		"TickInterp_lift_travel_just_after_the_start");
	// It stopped 10 ms ago: the 15 ms before the stop count.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_LiftTravel(0.0, 1.0, false, 0.01, 0.025, 600.0) - 9.0) < 0.01,
		"TickInterp_lift_travel_just_after_the_stop");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_LiftTravel(0.0, 1.0, false, 0.03, 0.025, 600.0) == 0.0,
		"TickInterp_no_lift_travel_once_it_has_stood_for_the_delay");
	// A soft start and stop: fastest in the middle (1.5 times the even pace), slow at the ends.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_LiftTravel(0.5125, 1.0, true, -1.0, 0.025, 600.0) - 22.5) < 0.05
		&& class'bbPlayer'.static.IGPlus_TI_LiftTravel(0.025, 1.0, true, -1.0, 0.025, 600.0) < 2.0,
		"TickInterp_lift_travel_with_a_soft_start_and_stop");
	// A lift going down has a travel below 0.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_LiftTravel(0.5, 1.0, false, -1.0, 0.025, -600.0) + 15.0) < 0.01,
		"TickInterp_lift_travel_going_down");

	// How much of that travel a player is drawn with (IGPlus_TI_LiftWalk): the
	// part of the last 8 ticks they stood on the lift. An update every tick,
	// walked back from tick position 100.5.
	LogTestResult(Abs(TestLiftShare(100.5, 8.0, 101, 90) - 1.0) < 0.001,
		"TickInterp_lift_share_is_whole_for_a_player_who_stays_on");
	LogTestResult(Abs(TestLiftShare(100.5, 8.0, 101, 98) - 0.3125) < 0.001,
		"TickInterp_lift_share_comes_in_after_getting_on");
	LogTestResult(Abs(TestLiftShare(100.5, 8.0, 97, 90) - 0.5625) < 0.001,
		"TickInterp_lift_share_goes_out_after_leaving");
	LogTestResult(TestLiftShare(100.5, 8.0, 92, 90) == 0.0,
		"TickInterp_no_lift_share_once_off_it_for_the_whole_fade");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_LiftFade(2.5) == 8.0
		&& class'bbPlayer'.static.IGPlus_TI_LiftFade(3.5) == 10.5
		&& class'bbPlayer'.static.IGPlus_TI_LiftFade(10.0) == 12.0,
		"TickInterp_lift_fade_grows_with_the_drawing_delay_up_to_12_ticks");
	// IGPlus_TI_Lead: delay, the part of it the clock was held, the most that
	// counts of the rest.
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_Lead(2.5, 0.0, 2.0) == 2.0
		&& class'bbPlayer'.static.IGPlus_TI_Lead(4.5, 0.0, 2.0) == 2.0
		&& class'bbPlayer'.static.IGPlus_TI_Lead(0.0, 0.0, 2.0) == 0.0,
		"TickInterp_a_lift_runs_ahead_by_2_ticks_and_by_none_with_no_delay");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_Lead(2.5, 0.0, 3.0) == 2.5
		&& class'bbPlayer'.static.IGPlus_TI_Lead(4.5, 0.0, 3.0) == 3.0,
		"TickInterp_a_ball_runs_ahead_by_3_ticks_at_most");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_Lead(9.0, 7.0, 2.0) == 9.0
		&& class'bbPlayer'.static.IGPlus_TI_Lead(10.0, 6.0, 2.0) == 8.0
		&& class'bbPlayer'.static.IGPlus_TI_Lead(10.0, 6.0, 3.0) == 9.0,
		"TickInterp_and_by_all_of_the_time_the_clock_was_held");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_Lead(4.0, 7.0, 2.0) == 9.0
		&& class'bbPlayer'.static.IGPlus_TI_Lead(4.0, 7.0, 3.0) == 9.0,
		"TickInterp_a_delay_that_dropped_for_a_frame_does_not_count_against_the_hold");
	// The delay rides in the same report and leaves the tick position alone.
	P = class'bbPlayer'.static.IGPlus_TI_Pack(500.75, true, true, 2.7);
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_UnpackDelay(P) - 2.5) < 0.01
		&& Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 501) - 500.75) < 0.005
		&& (P & (1 << 24)) != 0 && (P & (1 << 25)) != 0 && P < 0,
		"TickInterp_report_carries_the_drawing_delay_in_half_ticks");
	P = class'bbPlayer'.static.IGPlus_TI_Pack(500.75, false, false, 40.0);
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_UnpackDelay(P) == 15.5 && Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 501) - 500.75) < 0.005,
		"TickInterp_a_delay_too_long_for_the_report_is_cut_off");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_UnpackDelay(class'bbPlayer'.static.IGPlus_TI_Pack(70000.5)) == 0.0,
		"TickInterp_a_report_without_a_delay_reads_as_none");
	// 25 units in one 10 ms tick is a fall at 2500 units a second.
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_IsJump(vect(0,0,0), vect(0,0,-25), 1, 0.01) == false,
		"TickInterp_fast_movement_is_drawn_between_its_updates");
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_IsJump(vect(0,0,0), vect(300,0,0), 1, 0.01),
		"TickInterp_a_teleport_is_not_drawn_as_a_slide");
	// A stall of 10 ticks at a dodge's speed is movement, not a teleport.
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_IsJump(vect(0,0,0), vect(100,0,0), 10, 0.01) == false,
		"TickInterp_a_long_gap_at_speed_is_still_movement");
	// The two updates a player was drawn between ride in 4 bits of the report.
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_Span(1915, 1915, 1916) == 0
		&& class'bbPlayer'.static.IGPlus_TI_Span(1915, 1915, 1917) == 4
		&& class'bbPlayer'.static.IGPlus_TI_Span(1915, 1914, 1916) == 1
		&& class'bbPlayer'.static.IGPlus_TI_Span(1915, 1900, 1930) == 15,
		"TickInterp_the_two_updates_drawn_between_are_counted_from_the_tick_position");
	P = class'bbPlayer'.static.IGPlus_TI_Pack(70000.5, true, false, 2.5, 6);
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_UnpackSpan(P) == 6
		&& Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 70003) - 70000.5) < 0.005
		&& Abs(class'bbPlayer'.static.IGPlus_TI_UnpackDelay(P) - 2.5) < 0.01 && (P & (1 << 24)) != 0,
		"TickInterp_the_report_carries_the_two_updates_next_to_its_other_parts");
	// 11 bits of the tick number: a report from just before the count wraps is still read right.
	P = class'bbPlayer'.static.IGPlus_TI_Pack(2046.25);
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_Unpack(P, 2050) - 2046.25) < 0.005
		&& class'bbPlayer'.static.IGPlus_TI_UnpackSpan(P) == 0,
		"TickInterp_a_report_from_before_the_tick_count_wraps_is_read_right");
	// A shot leaves from the client's own spot while that is no further from
	// ours than the movement code lets it be (the square of the gap up to 3).
	LogTestResult(class'bbPlayer'.static.IGPlus_ShotOriginIsNear(0.0) && class'bbPlayer'.static.IGPlus_ShotOriginIsNear(1.7)
		&& class'bbPlayer'.static.IGPlus_ShotOriginIsNear(1.8) == false && class'bbPlayer'.static.IGPlus_ShotOriginIsNear(-1.0) == false,
		"ShotOrigin_the_client_spot_counts_only_inside_the_movement_tolerance");
	// A lift carried us up before the client's own lift did: the client's
	// spot counts while it is behind ours on the lift's path, no further than
	// the lift went.
	LogTestResult(class'bbPlayer'.static.IGPlus_LiftGapTakes(vect(0,0,30), vect(0,0,45))
		&& class'bbPlayer'.static.IGPlus_LiftGapTakes(vect(2,1,45), vect(0,0,45))
		&& class'bbPlayer'.static.IGPlus_LiftGapTakes(vect(0,0,-20), vect(0,0,-30)),
		"ShotOrigin_a_client_spot_behind_ours_on_the_lift_path_counts");
	LogTestResult(class'bbPlayer'.static.IGPlus_LiftGapTakes(vect(0,0,46), vect(0,0,45)) == false
		&& class'bbPlayer'.static.IGPlus_LiftGapTakes(vect(0,0,-5), vect(0,0,45)) == false
		&& class'bbPlayer'.static.IGPlus_LiftGapTakes(vect(5,0,30), vect(0,0,45)) == false
		&& class'bbPlayer'.static.IGPlus_LiftGapTakes(vect(0,0,1), vect(0,0,1.5)) == false,
		"ShotOrigin_a_client_spot_past_the_lift_travel_ahead_of_us_or_beside_the_path_does_not_count");
	// The lift lag: the client's ping less 4/3 of its frame, plus 0.6 of a
	// server tick, plus how much later than usual this move came, never
	// under 0 and never over the ping compensation cap.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_LiftLagMs(113.0, 0.0, 16.6, 9.0, 200.0) - 110.99) < 0.01
		&& Abs(class'bbPlayer'.static.IGPlus_LiftLagMs(113.0, -4.0, 8.3, 17.6, 200.0) - 90.572) < 0.01
		&& class'bbPlayer'.static.IGPlus_LiftLagMs(10.0, 0.0, 8.3, 17.6, 200.0) == 0.0
		&& class'bbPlayer'.static.IGPlus_LiftLagMs(250.0, 9.0, 16.6, 9.0, 200.0) == 200.0,
		"LiftLag_ping_less_the_client_frame_plus_the_tick_and_the_move_lateness_inside_the_cap");
	// We stepped off a lift the client still rides: only right after we stood
	// on it, with the client at the height we stood at and no further from
	// us sideways than we went since.
	LogTestResult(class'bbPlayer'.static.IGPlus_StillRidesTakes(0.1, 0.23, vect(20,0,28), vect(20,0,26))
		&& class'bbPlayer'.static.IGPlus_StillRidesTakes(0.1, 0.23, vect(3,0,0), vect(0,0,0))
		&& class'bbPlayer'.static.IGPlus_StillRidesTakes(0.3, 0.23, vect(0,0,0), vect(0,0,0)) == false
		&& class'bbPlayer'.static.IGPlus_StillRidesTakes(-1.0, 0.23, vect(0,0,0), vect(0,0,0)) == false
		&& class'bbPlayer'.static.IGPlus_StillRidesTakes(0.1, 0.23, vect(0,0,28), vect(0,0,20)) == false
		&& class'bbPlayer'.static.IGPlus_StillRidesTakes(0.1, 0.23, vect(30,0,28), vect(20,0,28)) == false,
		"ShotOrigin_a_lift_we_stepped_off_counts_only_at_once_and_with_the_client_where_it_can_be_on_it");
	// Push ease: the jump a push's correction makes goes on the camera when it
	// is an ordinary move. A teleport, a jump over 150 units or one through a wall snaps.
	LogTestResult(class'bbPlayer'.static.IGPlus_PushEaseTakes(vect(90,0,30), false, true)
		&& class'bbPlayer'.static.IGPlus_PushEaseTakes(vect(0,0,0), false, true)
		&& class'bbPlayer'.static.IGPlus_PushEaseTakes(vect(150,0,0), false, true)
		&& class'bbPlayer'.static.IGPlus_PushEaseTakes(vect(151,0,0), false, true) == false
		&& class'bbPlayer'.static.IGPlus_PushEaseTakes(vect(90,0,0), true, true) == false
		&& class'bbPlayer'.static.IGPlus_PushEaseTakes(vect(90,0,0), false, false) == false,
		"PushEase_an_ordinary_push_jump_eases_a_teleport_a_long_one_or_one_through_a_wall_snaps");
	LogTestResult(class'ClientSettings'.static.IntToHitEffectSource(0) == HESRC_Server
		&& class'ClientSettings'.static.IntToHitEffectSource(1) == HESRC_Client
		&& class'ClientSettings'.default.HitEffectSource == HESRC_Client
		&& class'SuperShockRifleBeamEffect'.default.bPlayBeam && class'SuperShockRifleBeamEffect'.default.bPlayRing == false
		&& class'SuperShockRifleRingEffect'.default.bPlayRing && class'SuperShockRifleRingEffect'.default.bPlayBeam == false,
		"HitEffectSource_starts_on_client_and_the_two_effect_halves_are_split");
	LogTestResult(class'ClientSettings'.static.IntToHeadshotSource(0) == HDSRC_Server
		&& class'ClientSettings'.static.IntToHeadshotSource(1) == HDSRC_Client
		&& class'ClientSettings'.default.HeadshotSource == HDSRC_Client,
		"HeadshotSource_starts_on_client");
	// A 39 high body with radius 17. Half the radius along the shot is 8.5.
	// The top of a full crouch is 11.7 above the middle, of half a crouch 25.35.
	LogTestResult(CrouchTopCase(25.0, 0.0, 0.0, false, 25.0)
		&& CrouchTopCase(25.0, -0.28, 0.0, false, 22.62)
		&& CrouchTopCase(38.0, 0.5, 0.0, false, 42.25)
		&& CrouchTopCase(10.8, 0.18, 1.0, true, 11.7)
		&& CrouchTopCase(10.0, 0.18, 1.0, false, 11.53)
		&& CrouchTopCase(30.0, -0.28, 0.5, true, 25.35)
		&& CrouchTopCase(27.0, -0.28, 0.5, false, 24.62),
		"OverCrouchTop_tests_the_crouch_top_half_a_radius_along_the_shot_as_the_server_does");
	// Debug data shows nowhere but its log file unless the player asks for it.
	LogTestResult(class'ClientSettings'.default.DebugDataDisplay == 0,
		"DebugDataDisplay_starts_off");
	// Auto Debug Data makes every player write a file each match: only when the admin turns it on.
	LogTestResult(class'ServerSettings'.default.bAutoDebugData == false
		&& class'bbPlayer'.default.IGPlus_AutoDebugData == false,
		"AutoDebugData_starts_off");
	// The stock look of other players' models stays unless the player asks.
	LogTestResult(class'ClientSettings'.default.FlipAnimationFix == FAF_FinishFlip
		&& class'ClientSettings'.static.IntToFlipAnimationFix(0) == FAF_Off
		&& class'ClientSettings'.static.IntToFlipAnimationFix(1) == FAF_FinishFlip
		&& class'ClientSettings'.static.IntToFlipAnimationFix(2) == FAF_FinishFlip
		&& class'ClientSettings'.static.IntToFlipAnimationFix(7) == FAF_Off,
		"FlipAnimationFix_starts_on_Finish_Flip_and_offers_Off_and_Finish_Flip");
	// Tick Interpolation: the move time between two updates comes back from the two bytes sent,
	// also past the 128 ms the byte covers, and for a tick that ran far more move time than one tick is long.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TI_MoveDelta(class'bbPlayer'.static.IGPlus_TI_MoveByte(100.0000),
			class'bbPlayer'.static.IGPlus_TI_MoveByte(100.0090), 0.0087) - 0.0090) < 0.0006
		&& Abs(class'bbPlayer'.static.IGPlus_TI_MoveDelta(class'bbPlayer'.static.IGPlus_TI_MoveByte(100.1200),
			class'bbPlayer'.static.IGPlus_TI_MoveByte(100.1320), 0.0087) - 0.0120) < 0.0006
		&& Abs(class'bbPlayer'.static.IGPlus_TI_MoveDelta(class'bbPlayer'.static.IGPlus_TI_MoveByte(50.0000),
			class'bbPlayer'.static.IGPlus_TI_MoveByte(50.3000), 0.3045) - 0.3000) < 0.0006
		&& Abs(class'bbPlayer'.static.IGPlus_TI_MoveDelta(class'bbPlayer'.static.IGPlus_TI_MoveByte(50.0000),
			class'bbPlayer'.static.IGPlus_TI_MoveByte(50.0500), 0.0087) - 0.0500) < 0.0006
		&& class'bbPlayer'.static.IGPlus_TI_MoveDelta(7, 7, 0.0087) == 0.0,
		"TickInterp_move_time_between_two_updates_comes_back_from_the_two_bytes");
	// Tick Interpolation, the tick clock of a client whose download comes late at times: it stays behind the
	// newest tick number, gives back only what the last seconds never needed, catches up over the most it
	// holds at once (never more than 8 ticks behind), and falls back when the newest tick number is behind it.
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_HeldMove(6.0, 0.0, 1.0) == 0.0
		&& Abs(class'bbPlayer'.static.IGPlus_TI_HeldMove(6.0, 4.0, 1.0) - 0.03) < 0.0001
		&& Abs(class'bbPlayer'.static.IGPlus_TI_HeldMove(6.0, 0.01, 1.0) - 0.01) < 0.0001
		&& Abs(class'bbPlayer'.static.IGPlus_TI_HeldMove(12.0, 0.0, 1.0) - 4.0) < 0.0001
		&& Abs(class'bbPlayer'.static.IGPlus_TI_HeldMove(8.05, 0.0, 1.0) - 0.05) < 0.0001
		&& Abs(class'bbPlayer'.static.IGPlus_TI_HeldMove(-3.0, 2.0, 1.0) + 0.3) < 0.0001
		&& class'bbPlayer'.static.IGPlus_TI_HeldMove(-9.0, 2.0, 1.0) == -9.0
		&& class'bbPlayer'.static.IGPlus_TI_HeldMove(2.0, -4.0, 1.0) == 0.0,
		"TickInterp_held_clock_stays_behind_and_gives_back_slowly");
	// The server tests a shot against the spot as the client got it: in quarters of a unit,
	// sent as whole units and one byte of quarters, also below zero.
	LogTestResult(class'bbPlayer'.static.IGPlus_TI_WireLoc(vect(2317.04,-126.51,-212.2)) == vect(2317,-126.5,-212.25)
		&& class'bbPlayer'.static.IGPlus_TI_LocWhole(vect(2317,-126.5,-212.25)) == vect(2317,-127,-213)
		&& class'bbPlayer'.static.IGPlus_TI_LocJoin(class'bbPlayer'.static.IGPlus_TI_LocWhole(vect(2317,-126.5,-212.25)),
			class'bbPlayer'.static.IGPlus_TI_LocFrac(vect(2317,-126.5,-212.25))) == vect(2317,-126.5,-212.25)
		&& class'bbPlayer'.static.IGPlus_TI_LocJoin(class'bbPlayer'.static.IGPlus_TI_LocWhole(vect(-0.25,31999.75,-32000)),
			class'bbPlayer'.static.IGPlus_TI_LocFrac(vect(-0.25,31999.75,-32000))) == vect(-0.25,31999.75,-32000),
		"TickInterp_the_server_rounds_a_spot_as_the_client_gets_it");
}

// Where the client's own trace stands another player (bbPlayer.IGPlus_PRTRulePos).
function TestPRTRulePos() {
	LogTestResult(VSize(class'bbPlayer'.static.IGPlus_PRTRulePos(vect(100,200,300), vect(400,0,-100), 0.02, false) - vect(108,200,298)) < 0.001,
		"PRTRule_carries_the_update_on_by_its_velocity");
	LogTestResult(class'bbPlayer'.static.IGPlus_PRTRulePos(vect(100,200,300), vect(400,0,0), 0.0, false) == vect(100,200,300),
		"PRTRule_no_time_past_the_update_is_the_update");
	LogTestResult(VSize(class'bbPlayer'.static.IGPlus_PRTRulePos(vect(0,0,0), vect(1000,0,0), 5.0, false) - vect(200,0,0)) < 0.001,
		"PRTRule_carry_is_capped_at_200ms");
	LogTestResult(class'bbPlayer'.static.IGPlus_PRTRulePos(vect(7,8,9), vect(1000,0,0), 0.5, true) == vect(7,8,9),
		"PRTRule_a_held_player_stays_at_the_update");
	// Update and tick counter came in one frame, 4 ms before the shown frame.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_PRTRuleAge(10.004, 10.0) - 0.004) < 0.00001,
		"PRTRuleAge_is_the_time_since_the_update");
	// No update for 40 ms: the server carries its old snapshot for all of it.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_PRTRuleAge(10.040, 10.0) - 0.040) < 0.00001,
		"PRTRuleAge_a_stalled_player_is_carried_for_the_whole_stall");
	LogTestResult(class'bbPlayer'.static.IGPlus_PRTRuleAge(9.9, 10.0) == 0.0,
		"PRTRuleAge_never_negative");
	LogTestResult(class'bbPlayer'.static.IGPlus_Fmt1(12.34) == "12.3" && class'bbPlayer'.static.IGPlus_Fmt1(-0.26) == "-0.3"
		&& class'bbPlayer'.static.IGPlus_Fmt1(-0.04) == "0.0" && class'bbPlayer'.static.IGPlus_Fmt1(7.96) == "8.0",
		"Fmt1_one_decimal_with_sign");
	// A line along X at height 0. A body 20 to the side with radius 17 is 3 away.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_LineCylinderGap(vect(0,0,0), vect(1,0,0), vect(500,20,0), 17, 39) - 3.0) < 0.001,
		"LineCylinderGap_side");
	LogTestResult(class'bbPlayer'.static.IGPlus_LineCylinderGap(vect(0,0,0), vect(1,0,0), vect(500,10,30), 17, 39) == 0.0,
		"LineCylinderGap_inside_is_zero");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_LineCylinderGap(vect(0,0,0), vect(1,0,0), vect(500,0,50), 17, 39) - 11.0) < 0.001,
		"LineCylinderGap_above");
}

// The crosshair presets of ClientSettings, on a settings object of its own.
// It saves to IGPlusTest.ini, not to a player's InstaGibPlus.ini.
function TestCrosshairPresets() {
	local Object Helper;
	local ClientSettings S;
	local ClientSettings.CrosshairLayerDescr D;
	local string Dump;
	local int i;
	local bool bOK;

	Helper = new(none, 'IGPlusTest') class'Object';
	S = new(Helper, 'ClientSettings') class'ClientSettings';

	// A player from before the presets: one crosshair, no preset yet.
	S.CrosshairPreset = 0;
	S.SetCrosshairLayerUse(0, true);
	S.SetCrosshairLayerScaleX(0, 3);
	S.LoadCrosshairPresets();
	for (i = 0; i < arraycount(S.CrosshairPresets); i++) { // (what an earlier run saved)
		S.CrosshairPresets[i].PresetName = "";
		S.CrosshairPresets[i].SaveConfig();
	}
	S.CopyLayersToCrosshairPreset();
	S.CreateCrosshairLayers();
	LogTestResult(S.GetCrosshairPresetName(0) == "Crosshair 1" && S.CrosshairPresets[0].GetLayer(0).ScaleX == 3
		&& S.GetCrosshairPresetName(1) == "" && S.BottomLayer != None && S.BottomLayer.ScaleX == 3,
		"CrosshairPresets_the_old_crosshair_is_the_first_preset");

	bOK = S.NewCrosshairPreset() && S.CrosshairPreset == 1 && S.GetCrosshairPresetName(1) == "Crosshair 2"
		&& S.CrosshairPresets[1].GetLayer(0).ScaleX == 3;
	S.SetCrosshairLayerScaleX(0, 7);
	S.StoreCrosshairPreset("Dot");
	LogTestResult(bOK && S.GetCrosshairPresetName(1) == "Dot" && S.CrosshairPresets[1].GetLayer(0).ScaleX == 7
		&& S.CrosshairPresets[0].GetLayer(0).ScaleX == 3,
		"CrosshairPresets_a_new_preset_is_a_copy_and_a_save_changes_only_the_picked_one");

	S.PickCrosshairPreset(0);
	bOK = S.CrosshairPreset == 0 && S.GetCrosshairLayer(0).ScaleX == 3 && S.BottomLayer.ScaleX == 3;
	S.PickCrosshairPreset(5); // a free slot
	bOK = bOK && S.CrosshairPreset == 0;
	Dump = S.DumpCrosshairPresets();
	bOK = bOK && InStr(Dump, "CrosshairPresets[0]: Crosshair 1") >= 0 && InStr(Dump, "CrosshairPresets[1]: Dot") >= 0
		&& InStr(Dump, "CrosshairPresets[1].Layers[0]: (") >= 0 && InStr(Dump, "CrosshairPresets[0].Layers") < 0;
	S.PickCrosshairPreset(1);
	LogTestResult(bOK && S.CrosshairPreset == 1 && S.GetCrosshairLayer(0).ScaleX == 7 && S.BottomLayer.ScaleX == 7,
		"CrosshairPresets_picking_one_draws_its_layers_and_the_dump_lists_them");

	// An older IG+ version edits CrosshairLayers and knows no presets.
	S.SetCrosshairLayerScaleX(0, 9);
	S.PickCrosshairPreset(0);
	LogTestResult(S.CrosshairPresets[1].GetLayer(0).ScaleX == 9 && S.GetCrosshairLayer(0).ScaleX == 3,
		"CrosshairPresets_layers_changed_elsewhere_go_back_to_their_preset_on_a_switch");

	// As after a restart: everything is read from the ini again.
	S = new(Helper, 'ClientSettings') class'ClientSettings';
	S.LoadCrosshairPresets();
	LogTestResult(S.CrosshairPreset == 0 && S.GetCrosshairLayer(0).ScaleX == 3 && S.GetCrosshairPresetName(0) == "Crosshair 1"
		&& S.GetCrosshairPresetName(1) == "Dot" && S.CrosshairPresets[1].GetLayer(0).ScaleX == 9,
		"CrosshairPresets_are_read_back_from_the_ini");

	S.PickCrosshairPreset(1);
	bOK = S.DeleteCrosshairPreset() && S.CrosshairPreset == 0 && S.GetCrosshairPresetName(1) == ""
		&& S.GetCrosshairLayer(0).ScaleX == 3;
	LogTestResult(bOK && S.DeleteCrosshairPreset() == false && S.GetCrosshairPresetName(0) == "Crosshair 1",
		"CrosshairPresets_a_delete_picks_the_first_one_left_and_the_last_one_stays");

	// The last of the 32 layers goes into the preset like the first.
	S.SetCrosshairLayerUse(31, true);
	S.SetCrosshairLayerScaleX(31, 4);
	S.StoreCrosshairPreset();
	bOK = S.CrosshairLayerCount() == 32 && S.CrosshairPresets[S.CrosshairPreset].GetLayer(31).ScaleX == 4;
	S.SetCrosshairLayerUse(31, false);
	S.StoreCrosshairPreset();
	LogTestResult(bOK, "CrosshairPresets_thirty_two_layers");

	bOK = true;
	for (i = 1; i < arraycount(S.CrosshairPresets); i++)
		bOK = bOK && S.NewCrosshairPreset();
	LogTestResult(bOK && S.NewCrosshairPreset() == false && S.CrosshairPreset == 15 && S.GetCrosshairPresetName(15) == "Crosshair 16",
		"CrosshairPresets_sixteen_slots");

	// The console command. All 16 are saved and the last one is picked.
	bOK = InStr(S.CrosshairPresetCommand("next"), "Crosshair preset 1: Crosshair 1") == 0 && S.CrosshairPreset == 0;
	bOK = bOK && InStr(S.CrosshairPresetCommand("prev"), "Crosshair preset 16: Crosshair 16") == 0 && S.CrosshairPreset == 15;
	bOK = bOK && InStr(S.CrosshairPresetCommand("4"), "Crosshair preset 4:") == 0 && S.CrosshairPreset == 3;
	LogTestResult(bOK, "CrosshairPresetCommand_number_next_and_prev_wrap_around");

	bOK = S.DeleteCrosshairPreset() && S.CrosshairPreset == 0; // slot 4 is free now
	S.CrosshairPresetCommand("3");
	bOK = bOK && InStr(S.CrosshairPresetCommand("next"), "Crosshair preset 5:") == 0 && S.CrosshairPreset == 4;
	bOK = bOK && InStr(S.CrosshairPresetCommand("previous"), "Crosshair preset 3:") == 0;
	bOK = bOK && InStr(S.CrosshairPresetCommand("4"), "No crosshair preset 4.") == 0 && S.CrosshairPreset == 2;
	bOK = bOK && InStr(S.CrosshairPresetCommand("17"), "No crosshair preset") == 0 && InStr(S.CrosshairPresetCommand("x"), "No crosshair preset") == 0;
	bOK = bOK && InStr(S.CrosshairPresetCommand(""), "Crosshair preset 3:") == 0 && S.CrosshairPreset == 2;
	LogTestResult(bOK, "CrosshairPresetCommand_skips_free_slots_and_refuses_them");

	// The Crosshair Factory's Save writes any preset. Preset 3 is picked here.
	D = S.CrosshairPresets[0].GetLayer(0);
	D.bUse = true;
	D.ScaleX = 21;
	S.SetCrosshairPresetLayer(0, 0, D);
	S.SaveCrosshairPreset(0, "Other");
	bOK = S.GetCrosshairPresetName(0) == "Other" && S.CrosshairPresets[0].GetLayer(0).ScaleX == 21
		&& S.GetCrosshairLayer(0).ScaleX != 21 && S.BottomLayer.ScaleX != 21;
	D.ScaleX = 22;
	S.SetCrosshairPresetLayer(2, 0, D);
	S.SaveCrosshairPreset(2, "");
	LogTestResult(bOK && S.CrosshairPreset == 2 && S.GetCrosshairPresetName(2) == "Crosshair 3" && S.CrosshairPresets[2].GetLayer(0).ScaleX == 22
		&& S.GetCrosshairLayer(0).ScaleX == 22 && S.BottomLayer.ScaleX == 22,
		"CrosshairPresets_the_window_saves_a_preset_that_is_not_picked_and_the_picked_one_is_drawn");
}

// How a layer's style and alpha reach the Canvas.
function TestCrosshairLayerCanvas() {
	local Canvas C;
	local color Col;
	local bool bOK;

	C = new(none) class'Canvas';
	Col.R = 200;
	Col.G = 100;
	Col.B = 50;
	Col.A = 128;
	class'CrosshairLayer'.static.SetupCanvas(C, 3, Col, false);
	LogTestResult(C.Style == 3 && C.DrawColor.R == 100 && C.DrawColor.G == 50 && C.DrawColor.B == 25 && C.DrawColor.A == 255 && C.bNoSmooth,
		"CrosshairLayer_a_translucent_layer_is_darker_by_its_alpha");
	class'CrosshairLayer'.static.SetupCanvas(C, 1, Col, true);
	bOK = C.Style == 1 && C.DrawColor.R == 200 && C.DrawColor.B == 50 && C.DrawColor.A == 255 && C.bNoSmooth == false;
	Col.A = 0;
	class'CrosshairLayer'.static.SetupCanvas(C, 3, Col, false);
	bOK = bOK && C.DrawColor.R == 200 && C.DrawColor.G == 100;
	class'CrosshairLayer'.static.SetupCanvas(C, 0, Col, false);
	LogTestResult(bOK && C.Style == 1, "CrosshairLayer_alpha_is_for_translucent_only_and_0_counts_as_255");
}

// A crosshair shape as text, row after row: # for a pixel of the shape, . for none.
function string ShapePic(byte Shape, int W, int H, int Thickness) {
	local int Row, i, First, Last, HoleFirst, HoleLast;
	local string S;

	for (Row = 0; Row < H; Row++) {
		if (Row > 0)
			S = S$"/";
		if (class'CrosshairLayer'.static.ShapeRow(Shape, W, H, Thickness, Row, First, Last, HoleFirst, HoleLast) == false) {
			First = 1;
			Last = 0;
		}
		for (i = 0; i < W; i++) {
			if (i >= First && i <= Last && (i < HoleFirst || i > HoleLast))
				S = S$"#";
			else
				S = S$".";
		}
	}
	return S;
}

function TestCrosshairShapes() {
	local ClientSettings.CrosshairLayerDescr D;
	local CrosshairLayer L;
	local ClientSettings S;
	local int First, Last, HoleFirst, HoleLast;

	LogTestResult(ShapePic(1, 5, 5, 0) == ".###./#####/#####/#####/.###.", "CrosshairShape_circle_5");
	LogTestResult(ShapePic(1, 4, 4, 0) == ".##./####/####/.##.", "CrosshairShape_circle_4");
	LogTestResult(ShapePic(1, 7, 7, 1) == "..###../.#...#./#.....#/#.....#/#.....#/.#...#./..###..", "CrosshairShape_ring_7");
	LogTestResult(ShapePic(2, 5, 5, 1) == "#####/#...#/#...#/#...#/#####", "CrosshairShape_square_outline");
	LogTestResult(ShapePic(2, 5, 5, 3) == "#####/#####/#####/#####/#####", "CrosshairShape_outline_thicker_than_the_shape_fills_it");
	LogTestResult(ShapePic(3, 5, 5, 0) == "..#../.###./#####/.###./..#..", "CrosshairShape_diamond");
	LogTestResult(ShapePic(4, 9, 5, 0) == "....#..../...###.../..#####../.#######./#########", "CrosshairShape_triangle_up");
	LogTestResult(ShapePic(5, 9, 5, 0) == "#########/.#######./..#####../...###.../....#....", "CrosshairShape_triangle_down");
	LogTestResult(class'CrosshairLayer'.static.ShapeRow(0, 5, 5, 0, 2, First, Last, HoleFirst, HoleLast) == false
		&& class'CrosshairLayer'.static.ShapeRow(1, 0, 5, 0, 2, First, Last, HoleFirst, HoleLast) == false,
		"CrosshairShape_no_shape_and_no_width_draw_nothing");

	D.Shape = 3;
	D.Thickness = 2;
	S = new(none, 'IGPlusShapeTest') class'ClientSettings';
	L = S.MakeCrosshairLayer(D);
	LogTestResult(L.Shape == 3 && L.Thickness == 2 && InStr(class'ClientSettings'.static.DumpCrosshairLayer(D), ",Shape=3,Thickness=2)") >= 0,
		"CrosshairShape_a_layer_and_the_dump_keep_shape_and_thickness");
}

function TestTweenPlaceholder() {
	local IGPlus_TweenTrack T;
	local bool bFresh, bBack, bAfter;

	// Running, then stock PlayFiring swaps in RunLGFR without a tween, then a tween back to RunLG.
	T = new class'IGPlus_TweenTrack';
	T.Update('RunLG', -0.2);
	bFresh = T.bPlaceholder == false;
	T.Update('RunLG', -0.1);
	bFresh = bFresh && T.bPlaceholder == false;
	T.Update('RunLG', 0.3);
	T.Update('RunLGFR', 0.4);
	T.Update('RunLG', -0.2);
	bBack = T.bPlaceholder && T.PlaceholderSeq == 'Breath1';
	T.Update('RunLG', -0.15);
	bAfter = T.bPlaceholder == false;
	T.Update('RunLG', -0.1);
	bAfter = bAfter && T.bPlaceholder == false;
	LogTestResult(bFresh && bBack && bAfter,
		"TweenPlaceholder_only_the_first_frame_that_needs_it");

	// A tween that starts again into the same sequence while the frame is still negative.
	T = new class'IGPlus_TweenTrack';
	T.Update('DuckWlkL', -0.3);
	T.Update('DuckWlkL', -0.2);
	bFresh = T.bPlaceholder == false;
	T.Update('DuckWlkL', -0.3);
	bBack = T.bPlaceholder && T.PlaceholderSeq == 'Breath1';
	// A loop that starts again from a server update: the tween's start frame comes back after the loop played.
	T = new class'IGPlus_TweenTrack';
	T.Update('StrafeR', -0.09);
	T.Update('StrafeR', -0.01);
	T.Update('StrafeR', 0.5);
	T.Update('StrafeR', 0.92);
	T.Update('StrafeR', -0.09);
	bBack = bBack && T.bPlaceholder;
	T.Update('StrafeR', -0.08);
	bBack = bBack && T.bPlaceholder == false;
	// Breath1 itself gets Breath2.
	T = new class'IGPlus_TweenTrack';
	T.Update('Breath1', -0.2);
	T.Update('Breath1', 0.5);
	T.Update('Breath1', -0.2);
	LogTestResult(bFresh && bBack && T.bPlaceholder && T.PlaceholderSeq == 'Breath2',
		"TweenPlaceholder_a_restarted_tween_a_restarted_loop_and_Breath1");
}

function plane SimAnimOf(float X, float Y, float Z, float W) {
	local plane P;
	P.X = X; P.Y = Y; P.Z = Z; P.W = W;
	return P;
}

// A strafe flip with the same SimAnim (seen on a server: -1000, 8500, 1700, -9000).
function TestMissedTween() {
	local plane S;
	S = SimAnimOf(-1000, 8500, 1700, -9000);
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('StrafeR', S, 'StrafeL', S, 0.91), "MissedTween_strafe_flip_with_the_same_SimAnim");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('StrafeR', S, 'StrafeL', SimAnimOf(-1000, 8500, 1700, -8999), 0.91) == false, "MissedTween_not_when_SimAnim_changed");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('StrafeR', S, 'StrafeL', S, -0.05) == false, "MissedTween_not_while_tweening");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('StrafeL', S, 'StrafeL', S, 0.91) == false, "MissedTween_not_on_the_same_sequence");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('StrafeR', SimAnimOf(1, 8500, 0, -9000), 'StrafeL', SimAnimOf(1, 8500, 0, -9000), 0.91) == false, "MissedTween_not_after_a_LoopAnim_with_no_tween");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('', S, 'StrafeL', S, 0.91) == false, "MissedTween_not_on_the_first_frame");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('RunLG', S, 'RunLGFR', S, 0.5) == false, "MissedTween_not_on_the_PlayFiring_swap");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('RunSMFR', S, 'RunLG', S, 0.5) == false, "MissedTween_not_on_the_PlayWeaponSwitch_swap");
	LogTestResult(class'bbPlayer'.static.IGPlus_MissedTween('RunLGFR', S, 'RunLG', S, 0.5), "MissedTween_RunLGFR_to_RunLG_is_a_LoopAnim");
}


function bool NearVec(vector A, vector B) {
	return VSize(A - B) < 0.05;
}

function vector HeadAt(name Seq, float Frame) {
	local vector C;

	class'IGPlus_HeadHitbox'.static.DataCenter(Seq, Frame, C);
	return C;
}

function TestHeadHitbox() {
	local class<IGPlus_HeadHitbox> H;
	local vector C, O;
	local rotator R;

	H = class'IGPlus_HeadHitbox';
	LogTestResult(H.static.DataCenter('RunLg', 0.0, C) && NearVec(C, vect(5.12,-0.18,38.70)),
		"HeadHitbox_run_first_frame_is_the_table_value");
	LogTestResult(H.static.DataCenter('RunLg', 0.05, C) && NearVec(C, vect(5.195,-0.945,37.435)),
		"HeadHitbox_halfway_between_two_frames_is_halfway_between_their_heads");
	LogTestResult(H.static.DataCenter('RunLg', -0.2, C) && NearVec(C, vect(5.12,-0.18,38.70)),
		"HeadHitbox_a_tween_blends_into_the_first_frame");
	LogTestResult(H.static.DataCenter('CockGun', 0.0, C) && NearVec(C, vect(1.38,0.98,27.83)),
		"HeadHitbox_an_animation_without_data_uses_a_similar_one");
	LogTestResult(H.static.DataCenter('NoSuchAnim', 0.0, C) == false,
		"HeadHitbox_no_data_for_other_animations");

	R.Pitch = 3072;
	O = H.static.HeadOffset(R, 'RunLg', 0.0, 31.5, 100.0);
	C = vect(5.12,-0.18,38.70) >> R;
	LogTestResult(NearVec(O, C * vect(1,1,0) + vect(0,0,31.5)), "HeadHitbox_the_head_moves_with_the_lean_but_keeps_its_height");
	O = H.static.HeadOffset(rot(0,0,0), 'Breath1', 0.0, 31.5, 6.0);
	LogTestResult(O.Z == 31.5, "HeadHitbox_the_top_of_the_head_stays_where_it_was");
	O = H.static.HeadOffset(rot(0,0,0), 'StrafeL', 0.0, 31.5, 6.0);
	LogTestResult(Abs(VSize(O * vect(1,1,0)) - 6.0) < 0.01, "HeadHitbox_the_head_stays_inside_the_collision_cylinder");
	R = rot(0,16384,0);
	R.Pitch = 3000;
	O = H.static.HeadOffset(R, 'NoSuchAnim', 0.0, 31.5, 6.0);
	LogTestResult(NearVec(O, vect(0,0,31.5)), "HeadHitbox_unknown_animations_keep_the_old_place");
	O = H.static.HeadOffset(R, 'StrafeL', 0.0, 31.5, 100.0);
	LogTestResult(O.X > 5.0, "HeadHitbox_the_head_turns_with_the_player");
	O = H.static.HeadOffset(rot(0,0,0), 'RunLg', 0.0, 31.5, 100.0, true, vect(1,2,30));
	LogTestResult(NearVec(O, vect(1,2,31.5)), "HeadHitbox_the_drawn_head_is_used_when_known");
}

function TestHeadTween() {
	local IGPlus_HeadTween Tw;
	local vector R04, B0, D0, Mid, Mid2;
	local bool Ok;

	R04 = HeadAt('RunLg', 0.4);
	B0 = HeadAt('Breath1', 0.0);
	D0 = HeadAt('DuckWlkL', 0.0);

	// A tween starts from the head as drawn last.
	Tw = new class'IGPlus_HeadTween';
	Tw.Update('RunLg', 0.3);
	Tw.Update('RunLg', 0.4);
	LogTestResult(Tw.bCur && NearVec(Tw.Cur, R04), "HeadTween_outside_a_tween_the_head_is_the_frame");
	Tw.Update('Breath1', -0.1);
	Ok = NearVec(Tw.Cur, R04);
	Tw.Update('Breath1', -0.05);
	Mid = B0 + (R04 - B0) * 0.5;
	LogTestResult(Ok && NearVec(Tw.Cur, Mid), "HeadTween_tween_start_blends_from_the_drawn_head");

	// A new tween half way through that one starts from the half-blended head.
	Tw.Update('DuckWlkL', -0.2);
	Ok = NearVec(Tw.Cur, Mid);
	Tw.Update('DuckWlkL', -0.1);
	Mid2 = D0 + (Mid - D0) * 0.5;
	LogTestResult(Ok && NearVec(Tw.Cur, Mid2), "HeadTween_chained_tween_starts_from_the_blend");

	// The same animation's tween restarted half way (AnimFrame goes back) goes on from where it was:
	// still for two frames (the placeholder frame, then the tween's own first frame), then on.
	Tw.Update('DuckWlkL', -0.3);
	Ok = NearVec(Tw.Cur, Mid2);
	Tw.Update('DuckWlkL', -0.15);
	Ok = Ok && NearVec(Tw.Cur, Mid2);
	Tw.Update('DuckWlkL', -0.075);
	LogTestResult(Ok && NearVec(Tw.Cur, D0 + (Mid - D0) * 0.25), "HeadTween_same_animation_tween_restart");

	// The tween ends on the animation's own frames.
	Tw.Update('DuckWlkL', 0.1);
	LogTestResult(NearVec(Tw.Cur, HeadAt('DuckWlkL', 0.1)), "HeadTween_after_the_tween_the_head_is_the_frame");

	// A tween back to RunLg after a swap to RunLgFr gets the placeholder frame: still for two
	// frames, then on.
	Tw = new class'IGPlus_HeadTween';
	Tw.Update('RunLg', 0.5);
	Tw.Update('RunLg', -0.1);
	Tw.Update('RunLg', -0.05);
	Tw.Update('RunLg', -0.001);
	Tw.Update('RunLg', 0.1);
	Tw.Update('RunLgFr', 0.6);
	Mid = HeadAt('RunLgFr', 0.6);
	Tw.Update('RunLg', -0.1);
	Ok = NearVec(Tw.Cur, Mid);
	Tw.Update('RunLg', -0.08);
	Ok = Ok && NearVec(Tw.Cur, Mid);
	Tw.Update('RunLg', -0.04);
	LogTestResult(Ok && NearVec(Tw.Cur, HeadAt('RunLg', 0.0) + (Mid - HeadAt('RunLg', 0.0)) * 0.5),
		"HeadTween_same_sequence_tween_blends_after_a_placeholder");

	// Unknown animations have no head, and a tween from one starts at the new animation's first frame.
	Tw = new class'IGPlus_HeadTween';
	Tw.Update('NoSuchAnim', 0.3);
	Ok = Tw.bCur == false;
	Tw.Update('Breath1', -0.1);
	LogTestResult(Ok && Tw.bCur && NearVec(Tw.Cur, B0), "HeadTween_no_blend_from_an_unknown_animation");
}

// Blends the engine would fold are drawn with transition frames (bbPlayer.IGPlus_TransitionLayout).
function TestTransitionFrames() {
	local int Pair, Sets, Steps, i;
	local float F;
	local bool Ok;

	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionLayout('StrafeR', 'StrafeL', Pair, Sets, Steps) && Pair == 0 && Sets == 1 && Steps == 8, "Transition_strafe_flip_has_one_set_of_8");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionLayout('StrafeL', 'StillFrRp', Pair, Sets, Steps) && Pair == 2 && Sets == 10 && Steps == 12, "Transition_stopping_a_strafe_has_a_set_per_key_frame");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionLayout('DuckWlkL', 'StrafeR', Pair, Sets, Steps) && Pair == 5 && Sets == 15 && Steps == 10, "Transition_leaving_a_crouch_walk_has_a_set_per_key_frame");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionLayout('StillFrRp', 'StrafeL', Pair, Sets, Steps) && Pair == 3 && class'bbPlayer'.static.IGPlus_TransitionLayout('LandLgFr', 'StrafeL', Pair, Sets, Steps) && Pair == 4, "Transition_standing_and_landing_into_StrafeL");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionLayout('StrafeR', 'StillFrRp', Pair, Sets, Steps) == false && class'bbPlayer'.static.IGPlus_TransitionLayout('StillFrRp', 'StrafeR', Pair, Sets, Steps) == false
		&& class'bbPlayer'.static.IGPlus_TransitionLayout('StrafeR', 'DuckWlkL', Pair, Sets, Steps) == false && class'bbPlayer'.static.IGPlus_TransitionLayout('StrafeL', 'DodgeR', Pair, Sets, Steps) == false, "Transition_other_blends_are_the_engines");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionLayout('LandLgFr', 'StillFrRp', Pair, Sets, Steps) && Pair == 6 && class'bbPlayer'.static.IGPlus_TransitionLayout('Flip', 'LandLgFr', Pair, Sets, Steps) && Pair == 7
		&& class'bbPlayer'.static.IGPlus_TransitionLayout('Flip', 'StillFrRp', Pair, Sets, Steps) && Pair == 8 && Sets == 1, "Transition_flip_end_and_landing_into_standing");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionModel(LodMesh'Botpack.Commando') == 0 && class'bbPlayer'.static.IGPlus_TransitionModel(LodMesh'Botpack.Soldier') == 1
		&& class'bbPlayer'.static.IGPlus_TransitionModel(LodMesh'Botpack.Boss') == 2 && class'bbPlayer'.static.IGPlus_TransitionModel(LodMesh'Botpack.FCommando') == 3
		&& class'bbPlayer'.static.IGPlus_TransitionModel(LodMesh'Botpack.SGirl') == 5 && class'bbPlayer'.static.IGPlus_TransitionModel(none) == -1, "TransitionModel_every_stock_model");
	Ok = true;
	for (i = 0; i < 7; i++)
		Ok = Ok && class'IGPlus_TransitionMesh'.default.Frames[i] != none && class'bbPlayer'.static.IGPlus_TransitionModel(class'IGPlus_TransitionMesh'.default.Frames[i]) == -1;
	LogTestResult(Ok, "TransitionMesh_one_for_each_model_and_none_for_itself");
	Ok = true;
	for (i = 0; i < 9; i++) {
		if (i == 2 || i == 5)
			Ok = Ok && class'IGPlus_TransitionMesh'.default.Kn[i] != '' && class'IGPlus_TransitionMesh'.default.Pn[i] != '';
		else
			Ok = Ok && class'IGPlus_TransitionMesh'.default.Tn[i] != '';
	}
	for (i = 0; i < 25; i++)
		Ok = Ok && class'IGPlus_TransitionMesh'.default.Into[i] != '';
	LogTestResult(Ok, "TransitionMesh_every_blend_has_its_sequences");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionPose(0, 1, 8, 0.0, 0.0, 0, true, 0.0, F) == 'T0' && F == 0.0 && class'bbPlayer'.static.IGPlus_TransitionPose(0, 1, 8, 1.0, 0.0, 0, true, 0.0, F) == 'T0' && Abs(F - 0.875) < 0.0001, "TransitionPose_one_start_runs_to_the_last_frame");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionPose(2, 10, 12, 0.0, 3.4, 3, false, 0.0, F) == 'K2' && Abs(F - 3.4 / 11.0) < 0.0001, "TransitionPose_first_the_exact_start");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionPose(2, 10, 12, 0.09, 3.4, 3, true, 0.0, F) == 'E2_3' && F < 0.0 && class'bbPlayer'.static.IGPlus_TransitionPose(5, 15, 10, 0.1, 14.2, 14, true, 0.0, F) == 'E5_14', "TransitionPose_then_the_tween_into_the_nearest_start");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionPose(2, 10, 12, 0.178, 3.4, 3, true, 0.0, F) == 'P2' && F >= 0.0, "TransitionPose_the_steps_take_over_late_in_the_blend");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionPose(2, 10, 12, 1.0, 3.4, 3, true, 0.0, F) == 'P2' && Abs(F - 47.0 / 120.0) < 0.0001 && class'bbPlayer'.static.IGPlus_TransitionPose(5, 15, 10, 1.0, 14.2, 14, true, 0.0, F) == 'P5' && F < 1.0, "TransitionPose_the_last_step_of_the_same_start");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionFits(0, 1, 0.9, 0.0, 0.0, 0.95) && class'bbPlayer'.static.IGPlus_TransitionFits(0, 1, 0.865, 0.0, 0.011, 0.95) && class'bbPlayer'.static.IGPlus_TransitionFits(0, 1, 0.5, 0.0, 0.011, 0.95) == false, "TransitionFits_a_strafe_flip_at_its_last_key");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionFits(6, 1, -0.002, -0.1, 0.0, 0.95) && class'bbPlayer'.static.IGPlus_TransitionFits(6, 1, -0.03, -0.1, 0.0, 0.95) == false, "TransitionFits_only_a_finished_blend");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionFits(7, 1, 0.95, 0.0, 0.0, 0.95) && class'bbPlayer'.static.IGPlus_TransitionFits(7, 1, 0.9, 0.0, 0.0, 0.95) == false && class'bbPlayer'.static.IGPlus_TransitionFits(2, 10, 0.47, 0.0, 0.0, 0.95), "TransitionFits_the_flip_at_its_end_and_a_stop_anywhere");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_FlipFix_PlayOnSpeed(2.0, 0.8, 0.95, 0.1) - 2.0) < 0.0001, "FlipFix_a_late_landing_keeps_the_flips_speed");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_FlipFix_PlayOnSpeed(2.0, 0.7, 0.95, 0.1) - 2.5) < 0.0001, "FlipFix_the_flip_ends_with_the_landing_blend");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_FlipFix_PlayOnSpeed(1.3, 0.5, 0.935484, 0.112) - 1.95) < 0.0001 && Abs(class'bbPlayer'.static.IGPlus_FlipFix_PlayOnSpeed(2.0, 0.2, 0.95, 0.0) - 3.0) < 0.0001, "FlipFix_never_more_than_one_and_a_half_times_as_fast");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_FlipFix_FlipEnd(0) - 0.95) < 0.0001 && Abs(class'bbPlayer'.static.IGPlus_FlipFix_FlipEnd(2) - 0.95) < 0.0001 && Abs(class'bbPlayer'.static.IGPlus_FlipFix_FlipEnd(3) - 29.0 / 31.0) < 0.0001 && Abs(class'bbPlayer'.static.IGPlus_FlipFix_FlipEnd(6) - 29.0 / 31.0) < 0.0001, "FlipFix_each_model_ends_where_its_frames_start");
	LogTestResult(class'bbPlayer'.static.IGPlus_FlipFix_Dying('Dead9B') && class'bbPlayer'.static.IGPlus_FlipFix_Dying('DeathEnd2') && class'bbPlayer'.static.IGPlus_FlipFix_Dying('DuckWlkL') == false && class'bbPlayer'.static.IGPlus_FlipFix_Dying('LandLgFr') == false, "FlipFix_the_dead_dont_finish_a_flip");
	LogTestResult(class'bbPlayer'.static.IGPlus_FlipFix_Looped('RunLgFr') && class'bbPlayer'.static.IGPlus_FlipFix_Looped('StrafeL') && class'bbPlayer'.static.IGPlus_FlipFix_Looped('Breath2') && class'bbPlayer'.static.IGPlus_FlipFix_Looped('LandLgFr') == false && class'bbPlayer'.static.IGPlus_FlipFix_Looped('StillFrRp') == false && class'bbPlayer'.static.IGPlus_FlipFix_Looped('Flip') == false, "FlipFix_looped_animations");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_FlipFix_Wrap(1.25) - 0.25) < 0.0001 && Abs(class'bbPlayer'.static.IGPlus_FlipFix_Wrap(-0.25) - 0.75) < 0.0001 && Abs(class'bbPlayer'.static.IGPlus_FlipFix_Wrap(0.5) - 0.5) < 0.0001, "FlipFix_phase_wraps");
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TransitionAlpha(-0.05, -0.1, 0.0) - 0.5) < 0.0001, "TransitionAlpha_halfway_through_the_blend");
	// A stop played twice: the blend restarts at -0.097 when it was 93% done. It goes on from 93%, never back.
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_TransitionAlpha(-0.097, -0.097, 0.93) - 0.93) < 0.0001
		&& Abs(class'bbPlayer'.static.IGPlus_TransitionAlpha(-0.0485, -0.097, 0.93) - 0.965) < 0.0001, "TransitionAlpha_a_restarted_blend_goes_on_from_where_it_was");
	LogTestResult(class'bbPlayer'.static.IGPlus_TransitionAlpha(0.0, -0.097, 0.93) == 1.0, "TransitionAlpha_ends_at_the_new_animation");
	// After Finish Flip the landing plays at its own speed, but a new jump or dodge takes over at once.
	LogTestResult(class'bbPlayer'.static.IGPlus_FlipFix_InAir('JumpLgFr') && class'bbPlayer'.static.IGPlus_FlipFix_InAir('DodgeL')
		&& class'bbPlayer'.static.IGPlus_FlipFix_InAir('Flip') && class'bbPlayer'.static.IGPlus_FlipFix_InAir('DuckWlkL'), "FlipFix_in_air_animations_end_a_late_landing");
	LogTestResult(class'bbPlayer'.static.IGPlus_FlipFix_InAir('LandLgFr') == false && class'bbPlayer'.static.IGPlus_FlipFix_InAir('StillFrRp') == false
		&& class'bbPlayer'.static.IGPlus_FlipFix_InAir('StrafeL') == false && class'bbPlayer'.static.IGPlus_FlipFix_InAir('RunLgFr') == false, "FlipFix_ground_animations_keep_the_landing");
}

// The lift share at tick position C for a player with an update in every tick
// who stood on the lift from tick From on, and off it from tick Last on.
function float TestLiftShare(float C, float Fade, int Last, int From) {
	local int T;
	local float Hi, Share;

	Hi = C;
	for (T = int(C); T > int(C) - 40; T--)
		if (class'bbPlayer'.static.IGPlus_TI_LiftWalk(float(T), Hi, C, Fade, T >= From && T < Last, Share) == false)
			break;
	return Share;
}

event int main(string Params) {
	TestDataBuffer();
	TestDetEffectiveAnimTime();
	TestTranslocatorFireMerging();
	TestTelefragOverlap();
	TestShockBallTouchFraction();
	TestDetNextShot();
	TestGlideGap();
	TestOwnCopyPathStep();
	TestDetFireClockLead();
	TestPreciseRewindTimeReport();
	TestTradeReach();
	TestShotEyePacking();
	TestPRTRulePos();
	TestFireOrder();
	TestTickInterp();
	TestCrosshairPresets();
	TestCrosshairShapes();
	TestCrosshairLayerCanvas();
	TestTweenPlaceholder();
	TestMissedTween();
	TestTransitionFrames();
	TestHeadHitbox();
	TestHeadTween();
	return 0;
}
