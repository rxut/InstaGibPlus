class ST_TranslocatorTarget extends TranslocatorTarget;

var IGPlus_WeaponImplementation WImp;

simulated function PostBeginPlay() {
	local UTPure PureRef;

	if (Instigator != none && Instigator.Role == ROLE_Authority) {

		PureRef = bbPlayer(Instigator).zzUTPure;
		
		ForEach AllActors(Class'IGPlus_WeaponImplementation', WImp)
			break;
		
		if (PureRef != None) {
			PureRef.RegisterProjectile(self);
		}
	}
	Super.PostBeginPlay();
}

auto state Pickup {
	event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType) {
		local float OldDisruption;

		OldDisruption = Disruption;

		super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);

		if (Disruption == OldDisruption)
			return;

		if (Master != none && Master.Owner != none && Master.Owner.IsA('bbPlayer'))
			bbPlayer(Master.Owner).ClientDebugMessage("TTarget took"@Damage@"damage (Total"@int(Disruption)$")");
	}

	singular function Touch(Actor Other) {
		if (Other.IsA('ST_HitTestHelper') == false)
			super.Touch(Other);
	}
}

defaultproperties {
	bSimFall=True
}
