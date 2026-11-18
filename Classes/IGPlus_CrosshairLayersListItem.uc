// One layer of a crosshair in the Crosshair Factory window. A list of these is
// a crosshair as the window shows it, bottom layer first.
class IGPlus_CrosshairLayersListItem extends UWindowListBoxItem;

var() string Texture;
var() int    OffsetX, OffsetY;
var() float  ScaleX, ScaleY;
var() color  Color;
var() byte   Style;
var() bool   bSmooth;
var() byte   Shape;
var() int    Thickness;

// The image of Texture, looked up once for each name (IGPlus_CrosshairLayersListBox.LayerTex).
var Texture Tex;
var string TexName;
var bool bTexLooked;
