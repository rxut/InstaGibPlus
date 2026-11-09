class ST_ShockBeamOwnerHidden extends ShockBeam;

var bool bAlreadyHidden;

// Server demo playback: this is the shooter's beam from the server (live,
// their client drew its own). Following the shooter in first person, udemo
// and the engine hide what the shooter owns with bOwnerNoSee, so only the
// segments after the first showed (a short beam, none for a close combo).
// Shown, starting at the gun where the camera is.
simulated function PostNetBeginPlay()
{
	local bbPlayer P;
	local vector CamPos, NewStart, BeamEnd;
	local rotator View, R;
	local float Eye;

	Super.PostNetBeginPlay();

	P = bbPlayer(Owner);
	if (Level.NetMode != NM_Client || P == None || P.IGPlus_SDIsServerDemoProxy() == false)
		return;
	bOwnerNoSee = false;
	bHidden = false;
	if (P.IGPlus_SDFollowingViewer() == None)
		return;

	P.IGPlus_SDCameraNow(CamPos, View, Eye);
	// The beam starts 20 uu past the fire point, as on the shooter's client.
	NewStart = P.IGPlus_SDMuzzle(CamPos + Eye * vect(0,0,1), View, P.Weapon) + 20 * vector(View);
	BeamEnd = Location + MoveAmount * (NumPuffs + 1);
	if (VSize(NewStart - Location) > 150 || VSize(BeamEnd - NewStart) < 1)
		return;
	MoveAmount = (BeamEnd - NewStart) / (NumPuffs + 1);
	R = rotator(BeamEnd - NewStart);
	R.Roll = Rotation.Roll;
	SetLocation(NewStart);
	SetRotation(R);
}

simulated function Tick(float F)
{
    Super.Tick(F);
    
    if(!bAlreadyHidden && Owner.IsA('bbPlayer') && bbPlayer(Owner).Player != None)
    {

        if((Level.NetMode == NM_Client))
        {
            DrawType = DT_None;
            Destroy();
            bAlreadyHidden = true;
        }
    }
    return;
}

defaultproperties {
	bOwnerNoSee=True
}
