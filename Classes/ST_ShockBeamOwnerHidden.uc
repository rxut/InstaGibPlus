class ST_ShockBeamOwnerHidden extends ShockBeam;

var bool bAlreadyHidden;

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
