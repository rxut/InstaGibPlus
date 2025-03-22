class ST_ShockBeamOwnerHidden extends ShockBeam;

var bool bAlreadyHidden;

simulated function Tick(float F)
{
    Super.Tick(F);
	
	if ( Owner == None )
		return;
	
    if(!bAlreadyHidden && Owner.IsA('bbPlayer') && bbPlayer(Owner).Player != None)
    {
        if((Level.NetMode == NM_Client))
        {
            bHidden = true;
            bAlreadyHidden = true;
        }
    }
    return;
}

defaultproperties
{
     bOwnerNoSee=True
}
