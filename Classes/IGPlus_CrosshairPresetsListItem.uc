// One preset in the Crosshair Factory window, as the window shows it. Its
// layers and its name are what the player has made of it since the window
// opened. Save writes them, closing the window drops them.
class IGPlus_CrosshairPresetsListItem extends UWindowListBoxItem;

var int Slot;              // the preset's slot in ClientSettings
var string PresetName;
var IGPlus_CrosshairLayersListItem Layers; // a list of its layers, bottom first (the list's sentinel)
var bool bDirty;           // not what is saved
