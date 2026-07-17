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

function bool TestV4InputSliceReplay() {
	local float SingleTS;
	local float FirstTS;
	local float LastTS;
	local rotator FirstView;
	local rotator LastView;

	SingleTS = class'IGPlus_WeaponImplementationBase'.static.IGPlus_V4ComputeSliceTimestamp(10.0, 0.02, 0, 1);
	FirstTS = class'IGPlus_WeaponImplementationBase'.static.IGPlus_V4ComputeSliceTimestamp(10.0, 0.02, 0, 2);
	LastTS = class'IGPlus_WeaponImplementationBase'.static.IGPlus_V4ComputeSliceTimestamp(10.0, 0.02, 1, 2);
	FirstView = class'IGPlus_WeaponImplementationBase'.static.IGPlus_V4InterpolateSliceView(0, 16384, 0, 2);
	LastView = class'IGPlus_WeaponImplementationBase'.static.IGPlus_V4InterpolateSliceView(0, 16384, 1, 2);

	LogTestResult(Abs(SingleTS - 10.0) < 0.0001, "V4_single_slice_timestamp");
	LogTestResult(Abs(FirstTS - 9.99) < 0.0001, "V4_first_slice_timestamp");
	LogTestResult(Abs(LastTS - 10.0) < 0.0001, "V4_last_slice_timestamp");
	LogTestResult(FirstView.Yaw == 0, "V4_first_slice_view");
	LogTestResult(LastView.Yaw == 16384, "V4_last_slice_view");
	LogTestResult(
		class'bbPlayer'.static.IGPlus_V4HeldAtSlice(false, 0, 1, 0)
			&& !class'bbPlayer'.static.IGPlus_V4HeldAtSlice(false, 0, 1, 1),
		"V4_press_release_timeline"
	);

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

event int main(string Params) {
	TestDataBuffer();
	TestV4InputSliceReplay();
	return 0;
}
