// c 2024-03-05
// m 2024-03-07

[Setting category="General" name="Show timer"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Show debug window"]
bool S_Debug = false;


[Setting category="Position/Style" name="Position X" min=0.0f max=1.0f]
float S_X = 0.5f;

[Setting category="Position/Style" name="Position Y" min=0.0f max=1.0f]
float S_Y = 0.99f;

[Setting category="Position/Style" name="Font style"]
Font S_Font = Font::DroidSansBold;

[Setting category="Position/Style" name="Font size" min=8 max=72]
uint S_FontSize = 24;

[Setting category="Position/Style" name="Font color" color]
vec4 S_FontColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);

[Setting category="Position/Style" name="Show number of respawns"]
bool S_Respawns = true;

enum BackgroundOption {
    None,
    OnlyBehindDelta,
    BehindEverything
}

[Setting category="Position/Style" name="Show background"]
BackgroundOption S_Background = BackgroundOption::OnlyBehindDelta;

[Setting category="Position/Style" name="Background color" color]
vec4 S_BackgroundColor = vec4(0.0f, 0.0f, 0.0f, 0.7f);

[Setting category="Position/Style" name="Background X-padding" min=0.0f max=30.0f]
float S_BackgroundXPad = 8.0f;

[Setting category="Position/Style" name="Background Y-padding" min=0.0f max=30.0f]
float S_BackgroundYPad = 8.0f;

[Setting category="Position/Style" name="Background corner radius" min=0.0f max=20.0f]
float S_BackgroundRadius = 10.0f;

[Setting category="Position/Style" name="Positive delta color" description="slower than PB" color]
vec4 S_PositiveColor = vec4(0.8f, 0.0f, 0.0f, 0.8f);

[Setting category="Position/Style" name="Neutral delta color" description="equal to PB" color]
vec4 S_NeutralColor = vec4(0.7f, 0.7f, 0.7f, 0.8f);

[Setting category="Position/Style" name="Negative delta color" description="faster than PB" color]
vec4 S_NegativeColor = vec4(0.0f, 0.0f, 0.8f, 0.8f);

[Setting category="Position/Style" name="Show drop shadow"]
bool S_Drop = true;

[Setting category="Position/Style" name="Drop shadow color" color]
vec4 S_DropColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Position/Style" name="Drop shadow offset" min=1 max=10]
int S_DropOffset = 2;

[Setting category="Position/Style" name="Show medal icons after finish" description="only if you would've gotten any"]
bool S_Medals = true;

[Setting category="Position/Style" name="Author medal" color]
vec4 S_AuthorColor = vec4(0.000f, 0.471f, 0.035f, 1.0f);

[Setting category="Position/Style" name="Gold medal" color]
vec4 S_GoldColor = vec4(0.871f, 0.737f, 0.259f, 1.0f);

[Setting category="Position/Style" name="Silver medal" color]
vec4 S_SilverColor = vec4(0.537f, 0.604f, 0.604f, 1.0f);

[Setting category="Position/Style" name="Bronze medal" color]
vec4 S_BronzeColor = vec4(0.604f, 0.400f, 0.259f, 1.0f);