class NN_ShockDOMRifle extends NN_ShockRifle;

simulated function bool NN_ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    local bbPlayer bbP;
    if (Owner.IsA('Bot'))
        return false;

    bbP = bbPlayer(Owner);
    if (bbP == none) return false;

    super.NN_ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);
    class'bbPlayerStatics'.static.PlayClientHitResponse(Pawn(Owner), Other, HitDamage, MyDamageType);
    
    return false;
}

simulated function PlaySelect ()
{
    return;
}

defaultproperties
{
    bNewNet=True
    PickupAmmoCount=50
    AmmoName=Class'ST_ShockCoreSDOM'
}