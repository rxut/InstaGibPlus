class ST_ShieldBeltEffect extends UT_ShieldBeltEffect;

simulated function PostBeginPlay() { /* deliberately empty */ }
simulated function Destroyed() { /* deliberately empty */ }

simulated function Tick(float DeltaTime) {
	local int IdealFatness;

	// Sent to whoever gets its owner (bPlayersAlwaysRelevant), not only to
	// those who can see the middle of the owner's body.
	if (Role == ROLE_Authority && Owner != None)
		bAlwaysRelevant = Owner.bAlwaysRelevant;

	if (bHidden || (Level.NetMode == NM_DedicatedServer) || (Owner == None))
		return;

	if (Owner != none) {
	    IdealFatness = Owner.Fatness; // Convert to int for safety.
		bHidden = Owner.bHidden;
		PrePivot = Owner.PrePivot;
		Mesh = Owner.Mesh;
		DrawScale = Owner.DrawScale;
	}
	IdealFatness += FatnessOffset;

	if (Fatness > IdealFatness)
		Fatness = Max(IdealFatness, Fatness - 130 * DeltaTime);
	else
		Fatness = Min(IdealFatness, 255);
}
