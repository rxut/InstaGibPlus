// One saved crosshair of the Crosshair Factory. Each has its own section in
// InstaGibPlus.ini, [CrosshairPreset1] to [CrosshairPreset16]. ClientSettings
// creates them with its own outer object, whose name is the ini file.
class IGPlus_CrosshairPreset extends Object
	config(InstaGibPlus)
	perobjectconfig
	dependson(ClientSettings); // its layer struct has to be parsed first

var config string PresetName; // empty: the slot is free
var config ClientSettings.CrosshairLayerDescr Layers[32]; // as many as ClientSettings.CrosshairLayers

// (The array is too large to reach through an object reference.)
function ClientSettings.CrosshairLayerDescr GetLayer(int i) {
	return Layers[i];
}

function SetLayer(int i, ClientSettings.CrosshairLayerDescr L) {
	Layers[i] = L;
}
