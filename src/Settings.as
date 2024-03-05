// c 2024-03-05
// m 2024-03-05

[Setting category="General" name="Show timer"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show adjusted CP delta" description="only if an official one exists"]
bool S_CpDelta = true;


[Setting category="Position/Style" name="Position X" min=0.0f max=1.0f]
float S_X = 0.5f;

[Setting category="Position/Style" name="Position Y" min=0.0f max=1.0f]
float S_Y = 0.987f;

[Setting category="Position/Style" name="Background color" color]
vec4 S_BackgroundColor = vec4(0.0f, 0.0f, 0.0f, 0.0f);

[Setting category="Position/Style" name="Show drop shadow" description="disables background color"]
bool S_DropShadow = true;

[Setting category="Position/Style" name="Font size" min=8 max=72]
uint S_FontSize = 24;

[Setting category="Position/Style" name="Font color" color]
vec4 S_FontColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);