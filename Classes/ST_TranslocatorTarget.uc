class ST_TranslocatorTarget extends TranslocatorTarget;

var IGPlus_WeaponImplementation WImp;

simulated function PostBeginPlay() {
	local UTPure PureRef;
	local bbPlayer bbP;

	if (Instigator != none && Instigator.Role == ROLE_Authority) {

		bbP = bbPlayer(Instigator);
		if (bbP != none)
			PureRef = bbP.zzUTPure;
		
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
		local bool bMasterTouch;
		local vector NewPos;
		local UTPlusDummy Dummy;
		local Pawn ActualPawn;

		if (Other.IsA('ST_HitTestHelper'))
			return;

		if (Other.IsA('UTPlusDummy')) {
			Dummy = UTPlusDummy(Other);
			if (Dummy.Actual != none) {
				ActualPawn = Dummy.Actual;
				bMasterTouch = ActualPawn == Instigator;

				if (Physics == PHYS_None) {
					if (bMasterTouch) {
						PlaySound(Sound'Botpack.Pickups.AmmoPick',,2.0);
						Master.TTarget = none;
						Master.bTTargetOut = false;
						if (ActualPawn.IsA('PlayerPawn'))
							PlayerPawn(ActualPawn).ClientWeaponEvent('TouchTarget');
						destroy();
					}
					return;
				}

				if (bMasterTouch)
					return;

				NewPos = Dummy.Location;
				NewPos.Z = Location.Z;
				SetLocation(NewPos);
				Velocity = vect(0,0,0);

				if (Level.Game.bTeamGame
					&& ActualPawn.PlayerReplicationInfo != none
					&& Instigator.PlayerReplicationInfo != none
					&& Instigator.PlayerReplicationInfo.Team == ActualPawn.PlayerReplicationInfo.Team)
					return;

				if (Instigator.IsA('Bot'))
					Master.Translocate();

				return;
			}
		}

		super.Touch(Other);
	}
}

defaultproperties {
	bSimFall=True
}
