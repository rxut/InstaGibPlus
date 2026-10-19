class IGPlus_TestCommandlet extends Commandlet;

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
	LogTestResult(Abs(class'bbPlayer'.static.IGPlus_PRTAge(class'bbPlayer'.static.IGPlus_PRTPack(5, 9.0)) - 6.5535) < 0.0001,
		"PRT_report_long_age_clamps_and_stays_positive");
	LogTestResult((class'bbPlayer'.static.IGPlus_PRTPack(0, 0) & 0x8000) != 0,
		"PRT_report_is_always_marked");
}

event int main(string Params) {
	TestDataBuffer();
	TestDetEffectiveAnimTime();
	TestTranslocatorFireMerging();
	TestDetFireClockLead();
	TestPreciseRewindTimeReport();
	return 0;
}
