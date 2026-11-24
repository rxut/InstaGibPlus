class SpecFirstBloodMessage extends FirstBloodMessage;

#exec OBJ LOAD FILE=..\Sounds\Announcer.uax PACKAGE=Announcer

// FirstBloodMessage plays the announcer only for the player who drew first
// blood. In server demo playback the one watching is the demo spectator, so a
// viewer following that player gets the voice here, as SpecSpreeMessage does
// for killing sprees.
static simulated function ClientReceive(
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (RelatedPRI_1 == None || RelatedPRI_1 == P.PlayerReplicationInfo)
		return;
	if (Pawn(P.ViewTarget) != None && Pawn(P.ViewTarget).PlayerReplicationInfo == RelatedPRI_1)
		P.ClientPlaySound(sound'Announcer.FirstBlood',, true);
}

defaultproperties
{
}
