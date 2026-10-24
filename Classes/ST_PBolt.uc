class ST_PBolt extends PBolt;

var IGPlus_WeaponImplementation WImp;
var float GrowthAccumulator;
var float GrowthDelay;
var int MaxSegments;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		GrowthDelay,
		MaxSegments;
}

simulated function CheckBeam(vector X, float DeltaTime)
{
	if ( Position < MaxSegments-1 ) {
		if ( PlasmaBeam == None ) {
			// Originally, it spawned a new segment every tick, meaning higher tickrate = faster growth of beam
			// This also meant it was incorrectly simulated on clients, since clients usually have a much higher framerate.
			// This should fix both issues. Tickrate 20 is assumed.
			GrowthAccumulator += DeltaTime;
			if (GrowthAccumulator >= GrowthDelay)		// 1 / 20 (Tickrate 20) = 0.050
			{
				PlasmaBeam = Spawn(class'ST_PBolt',,, Location + BeamSize * X);
				PlasmaBeam.Position = Position + 1;
				ST_PBolt(PlasmaBeam).GrowthAccumulator = GrowthAccumulator - GrowthDelay;
				ST_PBolt(PlasmaBeam).WImp = WImp;
				ST_PBolt(PlasmaBeam).GrowthDelay = GrowthDelay;
				ST_PBolt(PlasmaBeam).MaxSegments = MaxSegments;
				GrowthAccumulator = 0.0;

				if (GrowthDelay < 0.0)
					PlasmaBeam.CheckBeam(X, DeltaTime);
			}
		} else {
			PlasmaBeam.CheckBeam(X, DeltaTime);
		}
	}
}

simulated function UpdateBeam(PBolt ParentBolt, vector Dir, float DeltaTime)
{
	SpriteFrame = ParentBolt.SpriteFrame;
	Skin = SpriteAnim[SpriteFrame];
	SetLocation(ParentBolt.Location + BeamSize * Dir);
	SetRotation(ParentBolt.Rotation);

	if (PlasmaBeam != none)
		PlasmaBeam.UpdateBeam(self, Dir, DeltaTime);
}

// Starts where the parent segment ends and carries on its way until past Join,
// then points at End (ST_StarterBolt.TraceBeam).
simulated function IGPlus_AimBeam(PBolt ParentBolt, vector Join, vector End)
{
	local vector Dir;

	SpriteFrame = ParentBolt.SpriteFrame;
	Skin = SpriteAnim[SpriteFrame];
	Dir = vector(ParentBolt.Rotation);
	SetLocation(ParentBolt.Location + BeamSize * Dir);
	if (((Join - Location) dot Dir) <= 0.0 && ((End - Location) dot Dir) > 0.0)
		Dir = Normal(End - Location);
	SetRotation(rotator(Dir));

	if (ST_PBolt(PlasmaBeam) != none)
		ST_PBolt(PlasmaBeam).IGPlus_AimBeam(self, Join, End);
}

defaultproperties {
	GrowthDelay=0.050
}