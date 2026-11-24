// ===============================================================
// Stats.NN_ShockProj: put your comment here

// Created by UClasses - (C) 2000-2001 by meltdown@thirdtower.com
// ===============================================================

class NN_ShockProj extends ShockProj;

var actor NN_HitOther;
var int zzNN_ProjIndex;

function SuperExplosion()	// aka, combo.
{
	local bbPlayer bbP;

	bbP = bbPlayer(Owner);
	Spawn(Class'ut_ComboRing',,'',Location, Instigator.ViewRotation);
	PlayOwnedSound(ExploSound,,20.0,,2000,0.6);

	Destroy();
}

simulated function NN_SuperExplosion(Pawn Pwner)	// aka, combo.
{
	local rotator Tater;
	local bbPlayer bbP;
    local UT_ComboRing Ring;

	bbP = bbPlayer(Pwner);
	Tater = Pwner.ViewRotation;

	Ring = Spawn(Class'ut_ComboRing',Pwner,'',Location, Tater);
	PlaySound(ExploSound,,20.0,,2000,0.6);
    if(bbP != none)
    {
        bbP.xxClientDemoFix(Ring, class'ut_ComboRing', Location, Ring.Velocity, Ring.Acceleration, Tater);
    }

	Destroy();
}

auto state Flying
{
	simulated function ProcessTouch(Actor Other, vector HitLocation)
	{
		if (bDeleteMe || Other == None || Other.bDeleteMe)
			return;
		If ( Level.NetMode == NM_Client && Other!=Owner && Other!=Instigator && Other.Owner != Owner && (!Other.IsA('Projectile') || (Other.CollisionRadius > 0)) && NN_HitOther != Other )
		{
			if (Other.IsA('Projectile') && Other.bOwnerNoSee)
				bbPlayer(Owner).xxExplodeOther(Projectile(Other));
			NN_HitOther = Other;
			Explode(HitLocation,Normal(HitLocation-Other.Location));
		}
	}

	simulated function BeginState()
	{
		Velocity = vector(Rotation) * speed;
	}
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local bbPlayer bbP;

	bbP = bbPlayer(Owner);

	if (bDeleteMe)
		return;

	NN_Momentum( 70, MomentumTransfer, Location );

	if (Damage > 60)
	{
		Spawn(class'ut_RingExplosion3',,, HitLocation+HitNormal*8,rotator(HitNormal));
		if (bbP != None)
			bbP.xxClientDemoFix(None, class'ut_RingExplosion3',HitLocation+HitNormal*8,,, rotator(HitNormal));
	}
	else
	{
		Spawn(class'ut_RingExplosion',,, HitLocation+HitNormal*8,rotator(Velocity));
		if (bbP != None)
			bbP.xxClientDemoFix(None, class'ut_RingExplosion',HitLocation+HitNormal*8,,, rotator(Velocity));
	}

	PlayOwnedSound(ImpactSound, SLOT_Misc, 0.5,,, 0.5+FRand());

	Destroy();
}

simulated function NN_Momentum( float DamageRadius, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local bbPlayer bbP;

	bbP = bbPlayer(Owner);

	if ( bbP == None || !bbP.bNewNet || Self.IsA('NN_ShockProjOwnerHidden') || RemoteRole == ROLE_Authority )
		return;

	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims == Owner )
		{
			dir = Owner.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Owner.CollisionRadius)/DamageRadius);

			dir = damageScale * Momentum * dir;

			if (bbP.Physics == PHYS_None)
				bbP.SetMovementPhysics();
			if (bbP.Physics == PHYS_Walking)
				dir.Z = FMax(dir.Z, 0.4 * VSize(dir));

			dir = 0.6*dir/bbP.Mass;

			bbP.AddVelocity(dir);
		}
	}
}