class Utilities extends Object;

static final function float Round(float A) {
	if (A < 0) return float(int(A-0.5));
	return float(int(A+0.5));
}

// convert rotation representation from signed to unsigned
static final function int RotS2U(int A) {
	return A & 0xFFFF;
}

// convert rotation representation from unsigned to signed
static final function int RotU2S(int A) {
	return A << 16 >> 16;
}
