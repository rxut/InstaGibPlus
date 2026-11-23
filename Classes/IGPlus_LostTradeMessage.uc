// Client: our own hit lost to an earlier kill (bbPlayer.IGPlus_LostTradeCheck).
// It shows where "Head Shot" does and takes its place.
class IGPlus_LostTradeMessage extends DecapitationMessage;

var localized string LostTradeString;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
) {
	return default.LostTradeString;
}

defaultproperties
{
	LostTradeString="Lost Trade"
	DrawColor=(R=200,G=200,B=200)
}
