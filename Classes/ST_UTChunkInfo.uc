class ST_UTChunkInfo extends Info;

var Actor Victim[8];
var int HitCount;
var int ChunkCount;

var IGPlus_WeaponImplementation WImp;
var bool RandomSpread;
var bool IGPlus_bLiftAim;  // Push-Safe Aim from a moving lift (IGPlus_LiftShot)

function AddChunk(ST_UTChunk Chunk)
{
	local bbPlayer bbP;
	local IGPlus_LiftShot LS;

	bbP = bbPlayer(Owner);

	if (Chunk == None)
		return;				// If it for some reason failed to spawn.
	Chunk.Chunkie = Self;
	Chunk.ChunkIndex = ChunkCount++;
	Chunk.LifeSpan = WImp.WeaponSettings.FlakChunkLifespan;
	Chunk.RandomSpread = RandomSpread;
	if (IGPlus_bLiftAim && bbP != None)
		LS = class'IGPlus_LiftShot'.static.Begin(Chunk, bbP);

	// Apply ping compensation for flak chunks if enabled
	if (bbP != none && WImp.WeaponSettings.FlakCompensatePing) {
		// Apply ping compensation simulation to each chunk
		WImp.SimulateProjectile(Chunk, bbP.PingAverage);
		Chunk.LifeSpan -= bbP.PingAverage*0.001*Level.TimeDilation;
	}
	if (LS != None)
		LS.Hold();
}

// The chunks have a lifespan of 2.9-3.1 seconds, so this is sufficient.
defaultproperties {
	LifeSpan=3.5
}