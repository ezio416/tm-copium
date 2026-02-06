[Setting category="General" name="Show timer"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Show debug window"]
bool S_Debug = false;

[Setting category="General" name="Use TM-style UI" description="Use the TM-native rectangular timer UI"]
bool S_TMStyleUI = false;

[Setting category="Position/Style" name="Position X" min=0.0f max=1.0f hidden]
float S_X = 0.5f;

[Setting category="Position/Style" name="Position Y" min=0.0f max=1.0f hidden]
float S_Y = 0.99f;

[Setting category="Position/Style" name="Show number of respawns after finish" hidden]
bool S_Respawns = true;

[Setting category="Position/Style" name="Show thousandths" description="not perfectly accurate" hidden]
bool S_Thousandths = true;

enum BackgroundOption {
    None,
    OnlyBehindDelta,
    BehindEverything
}

[Setting category="Position/Style" name="Show background" hidden]
BackgroundOption S_Background = BackgroundOption::OnlyBehindDelta;

[Setting category="Position/Style" name="Background color" color hidden]
vec4 S_BackgroundColor = vec4(0.0f, 0.0f, 0.0f, 0.7f);

// [Setting category="Position/Style" name="Background X-padding" min=0.0f max=30.0f]
const float S_BackgroundXPad = 8.0f;

[Setting category="Position/Style" name="Background Y-padding" min=0.0f max=30.0f hidden]
float S_BackgroundYPad = 6.0f;

[Setting category="Position/Style" name="Background corner radius" min=0.0f max=50.0f hidden]
float S_BackgroundRadius = 20.0f;

[Setting category="Position/Style" name="Show delta" hidden]
bool S_Delta = true;

[Setting category="Position/Style" name="Positive delta color" description="slower than PB" color hidden]
vec4 S_PositiveColor = vec4(0.8f, 0.0f, 0.0f, 0.8f);

[Setting category="Position/Style" name="Neutral delta color" description="equal to PB" color hidden]
vec4 S_NeutralColor = vec4(0.7f, 0.7f, 0.7f, 0.8f);

[Setting category="Position/Style" name="Negative delta color" description="faster than PB" color hidden]
vec4 S_NegativeColor = vec4(0.0f, 0.0f, 0.8f, 0.8f);

[Setting category="Position/Style" name="Show drop shadow" hidden]
bool S_Drop = true;

[Setting category="Position/Style" name="Drop shadow color" color hidden]
vec4 S_DropColor = vec4(0.0f, 0.0f, 0.0f, 1.0f);

[Setting category="Position/Style" name="Drop shadow offset" min=1 max=10 hidden]
int S_DropOffset = 2;

[Setting category="Position/Style" name="Show medal icons after finish" hidden]
bool S_Medals = true;

#if DEPENDENCY_CHAMPIONMEDALS
[Setting category="Position/Style" name="Champion medal" color hidden]
vec4 S_ChampionColor = vec4(1.0f, 0.267f, 0.467f, 1.0f);
#endif

[Setting category="Position/Style" name="Author medal" color hidden]
vec4 S_AuthorColor = vec4(0.0f, 0.471f, 0.035f, 1.0f);

[Setting category="Position/Style" name="Gold medal" color hidden]
vec4 S_GoldColor = vec4(0.871f, 0.737f, 0.259f, 1.0f);

[Setting category="Position/Style" name="Silver medal" color hidden]
vec4 S_SilverColor = vec4(0.537f, 0.604f, 0.604f, 1.0f);

[Setting category="Position/Style" name="Bronze medal" color hidden]
vec4 S_BronzeColor = vec4(0.604f, 0.4f, 0.259f, 1.0f);

[Setting category="Position/Style" name="Persist timer after restart" description="Shows until player is driving again" hidden]
bool S_Persist = true;

[Setting category="TM Style" name="Position X" min=0.0f max=1.0f hidden]
float S_TMX = 0.5f;

[Setting category="TM Style" name="Position Y" min=0.0f max=1.0f hidden]
float S_TMY = 0.25f;

[Setting category="TM Style" name="Scale" min=0.5f max=3.0f hidden]
float S_Scale = 1.0f;

[Setting category="TM Style" name="Enable drag mode" description="Allow dragging the TM-style UI in-game" hidden]
bool S_TMUIDragMode = false;

[Setting category="TM Style" name="Font color" color hidden]
vec4 S_TM_FontColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);

[Setting category="TM Style" name="Positive delta color" color hidden]
vec4 S_TM_PositiveColor = vec4(0.8f, 0.0f, 0.0f, 0.8f);

[Setting category="TM Style" name="Neutral delta color" color hidden]
vec4 S_TM_NeutralColor = vec4(0.7f, 0.7f, 0.7f, 0.8f);

[Setting category="TM Style" name="Negative delta color" color hidden]
vec4 S_TM_NegativeColor = vec4(0.0f, 0.0f, 0.8f, 0.8f);

[Setting category="TM Style" name="Background color" color hidden]
vec4 S_TM_BackgroundColor = vec4(0.0f, 0.0f, 0.0f, 0.7f);

[Setting category="TM Style" name="Font" hidden]
Font S_TM_Font = Font::Oswald_Regular;

[Setting category="TM Style" name="Custom font" hidden]
string S_TM_CustomFont;

[Setting category="TM Style" name="Font size" hidden]
int S_TM_FontSize = 34;

[Setting category="TM Style" name="Show number of respawns after finish" hidden]
bool S_TM_Respawns = true;

[Setting category="TM Style" name="Show thousandths" description="not perfectly accurate" hidden]
bool S_TM_Thousandths = true;

[Setting category="TM Style" name="Show medal icons after finish" hidden]
bool S_TM_Medals = true;

[Setting category="TM Style" name="Persist timer after restart" description="Shows until player is driving again" hidden]
bool S_TM_Persist = false;

[Setting category="TM Style" name="Show only on respawn" description="Only show TM UI for a short time when a respawn occurs" hidden]
bool S_TM_ShowOnRespawn = true;

[Setting category="TM Style" name="Show-on-respawn duration (ms)" min=500 max=10000 hidden]
int S_TM_ShowOnRespawnDuration = 3000;

[Setting category="Font" hidden]
Font S_Font = Font::DroidSans_Bold;

[Setting category="Font" hidden]
string S_CustomFont;

[Setting category="Font" hidden]
int S_FontSize = 24;

[Setting category="Font" hidden]
vec4 S_FontColor = vec4(1.0f, 1.0f, 1.0f, 1.0f);

[SettingsTab name="Font" icon="Font" order=1]
void SettingsTab_Font() {
    if (S_TMStyleUI) {
        UI::TextWrapped("This settings tab is not available because TM Style is selected.");
        UI::TextWrapped("To operate changes, please, go to TM Style tab.");
        return;
    }
    if (UI::Button("Reset to default")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Font") {
                settings[i].Reset();
            }
        }

        ChangeFont();
    }

    const string userFontFolder = IO::FromDataFolder("Fonts").Replace("\\", "/");

    if (UI::BeginCombo("Style", tostring(S_Font), UI::ComboFlags::HeightLargest)) {
        Font f;

        for (int i = 0; i < Font::_Droid_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_Font == f)) {
                S_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        for (int i = Font::_Droid_End + 1; i < Font::_Montserrat_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_Font == f)) {
                S_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        for (int i = Font::_Montserrat_End + 1; i < Font::_Oswald_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_Font == f)) {
                S_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        if (UI::Selectable("Custom", S_Font == Font::Custom)) {
            S_Font = Font::Custom;

            if (!IO::FolderExists(userFontFolder)) {
                IO::CreateFolder(userFontFolder);
            } else {
                ChangeFont();
            }
        }

        UI::EndCombo();
    }

    if (S_Font == Font::Custom) {
        UI::Indent(UI::GetScale() * 30.0f);

        UI::TextWrapped("Font files (\\$0F0.ttf\\$G) go in");
        UI::SameLine();
        if (UI::TextLink(userFontFolder)) {
            OpenExplorerPath(userFontFolder);
        }
        if (UI::IsItemHovered()) {
            UI::BeginTooltip();
            UI::Text(Icons::ExternalLink + " open in explorer");
            UI::EndTooltip();
        }

        string[]@ filenames = IO::IndexFolder(userFontFolder, false);
        if (filenames.Length == 0) {
            S_CustomFont = "";
            UI::TextWrapped("\\$FF0Folder is empty, download some fonts!");

        } else {
            if (UI::BeginCombo("File", S_CustomFont)) {
                for (uint i = 0; i < filenames.Length; i++) {
                    const string name = Path::GetFileName(filenames[i]);
                    if (name.EndsWith(".ttf") and UI::Selectable(name, S_CustomFont == name)) {
                        S_CustomFont = name;
                        ChangeFont();
                    }
                }

                UI::EndCombo();
            }
        }

        UI::Indent(UI::GetScale() * -30.0f);
    }

    S_FontSize = UI::SliderInt("Size", S_FontSize, 8, 128);
    if (S_FontSize < 8) {
        S_FontSize = 8;
    }
    if (S_FontSize > 128) {
        S_FontSize = 128;
    }

    S_FontColor = UI::InputColor4("Color", S_FontColor);
}

[SettingsTab name="Position/Style" order=2]
void SettingsTab_PositionStyle() {
    if (S_TMStyleUI) {
        UI::TextWrapped("This settings tab is not available because TM Style is selected.");
        UI::TextWrapped("To operate changes, please, go to TM Style tab.");
        return;
    }

    if (UI::Button("Reset to default")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "Position/Style") {
                settings[i].Reset();
            }
        }
    }

    S_X = UI::SliderFloat("Position X", S_X, 0.0f, 1.0f);
    S_Y = UI::SliderFloat("Position Y", S_Y, 0.0f, 1.0f);

    S_Respawns = UI::Checkbox("Show number of respawns after finish", S_Respawns);
    S_Thousandths = UI::Checkbox("Show thousandths", S_Thousandths);

    if (UI::BeginCombo("Show background", tostring(S_Background))) {
        if (UI::Selectable("None", S_Background == BackgroundOption::None)) {
            S_Background = BackgroundOption::None;
        }
        if (UI::Selectable("Only behind delta", S_Background == BackgroundOption::OnlyBehindDelta)) {
            S_Background = BackgroundOption::OnlyBehindDelta;
        }
        if (UI::Selectable("Behind everything", S_Background == BackgroundOption::BehindEverything)) {
            S_Background = BackgroundOption::BehindEverything;
        }
        UI::EndCombo();
    }

    S_BackgroundColor = UI::InputColor4("Background color", S_BackgroundColor);
    S_BackgroundYPad = UI::SliderFloat("Background Y-padding", S_BackgroundYPad, 0.0f, 30.0f);
    S_BackgroundRadius = UI::SliderFloat("Background corner radius", S_BackgroundRadius, 0.0f, 50.0f);

    S_Delta = UI::Checkbox("Show delta", S_Delta);
    S_PositiveColor = UI::InputColor4("Positive delta color", S_PositiveColor);
    S_NeutralColor = UI::InputColor4("Neutral delta color", S_NeutralColor);
    S_NegativeColor = UI::InputColor4("Negative delta color", S_NegativeColor);

    S_Drop = UI::Checkbox("Show drop shadow", S_Drop);
    S_DropColor = UI::InputColor4("Drop shadow color", S_DropColor);
    S_DropOffset = UI::SliderInt("Drop shadow offset", S_DropOffset, 1, 10);

    S_Medals = UI::Checkbox("Show medal icons after finish", S_Medals);
    S_Persist = UI::Checkbox("Persist timer after restart", S_Persist);
}


[SettingsTab name="TM Style" order=3]
void SettingsTab_TMStyle() {
    if (!S_TMStyleUI) {
        UI::TextWrapped("TM Style is disabled.");
        UI::TextWrapped("Therefore these options aren't available.");
        UI::TextWrapped("Enable/disable 'Use TM-style UI' from the General tab.");
        return;
    }
    if (UI::Button("Reset TM Style to default")) {
        Meta::PluginSetting@[]@ settings = pluginMeta.GetSettings();
        for (uint i = 0; i < settings.Length; i++) {
            if (settings[i].Category == "TM Style") {
                settings[i].Reset();
            }
        }
        ChangeFont();
    }
    bool prevPersist = S_TM_Persist;
    bool prevShow = S_TM_ShowOnRespawn;
    UI::NewLine();
    S_TMX = UI::SliderFloat("Position X", S_TMX, 0.0f, 1.0f);
    S_TMY = UI::SliderFloat("Position Y", S_TMY, 0.0f, 1.0f);
    S_Scale = UI::SliderFloat("Scale", S_Scale, 0.5f, 3.0f);
    S_TMUIDragMode = UI::Checkbox("Enable drag mode", S_TMUIDragMode);

    S_TM_FontColor = UI::InputColor4("Font color", S_TM_FontColor);
    S_TM_PositiveColor = UI::InputColor4("Positive delta color", S_TM_PositiveColor);
    S_TM_NeutralColor = UI::InputColor4("Neutral delta color", S_TM_NeutralColor);
    S_TM_NegativeColor = UI::InputColor4("Negative delta color", S_TM_NegativeColor);
    UI::NewLine();

    S_TM_Respawns = UI::Checkbox("Show number of respawns after finish", S_TM_Respawns);
    S_TM_Thousandths = UI::Checkbox("Show thousandths", S_TM_Thousandths);
    S_TM_BackgroundColor = UI::InputColor4("Background color", S_TM_BackgroundColor);
    S_TM_Medals = UI::Checkbox("Show medal icons after finish", S_TM_Medals);

    UI::BeginDisabled(S_TM_ShowOnRespawn);
    S_TM_Persist = UI::Checkbox("Persist timer after restart", S_TM_Persist);
    UI::EndDisabled();
    if (S_TM_Persist) {
        S_TM_ShowOnRespawn = false;
    }

    UI::BeginDisabled(S_TM_Persist);
    S_TM_ShowOnRespawn = UI::Checkbox("Show only on reset", S_TM_ShowOnRespawn);
    UI::EndDisabled();
    if (S_TM_ShowOnRespawn) {
        S_TM_Persist = false;
        S_TM_ShowOnRespawnDuration = UI::SliderInt("Show-on-reset duration (ms)", S_TM_ShowOnRespawnDuration, 500, 10000);
    }
    UI::NewLine();

    const string userFontFolder = IO::FromDataFolder("Fonts").Replace("\\", "/");
    if (UI::BeginCombo("Font Style", tostring(S_TM_Font))) {
        Font f;

        for (int i = 0; i < Font::_Droid_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_TM_Font == f)) {
                S_TM_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        for (int i = Font::_Droid_End + 1; i < Font::_Montserrat_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_TM_Font == f)) {
                S_TM_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        for (int i = Font::_Montserrat_End + 1; i < Font::_Oswald_End; i++) {
            f = Font(i);
            if (UI::Selectable(tostring(f), S_TM_Font == f)) {
                S_TM_Font = f;
                ChangeFont();
            }
        }

        UI::Separator();

        if (UI::Selectable("Custom", S_TM_Font == Font::Custom)) {
            S_TM_Font = Font::Custom;
            if (!IO::FolderExists(userFontFolder)) {
                IO::CreateFolder(userFontFolder);
            } else {
                ChangeFont();
            }
        }

        UI::EndCombo();
    }

    if (S_TM_Font == Font::Custom) {
        UI::Indent(UI::GetScale() * 30.0f);
        if (UI::BeginCombo("TM Custom Font File", S_TM_CustomFont)) {
            string[]@ filenames = IO::IndexFolder(userFontFolder, false);
            for (uint i = 0; i < filenames.Length; i++) {
                const string name = Path::GetFileName(filenames[i]);
                if (name.EndsWith(".ttf")) {
                    const string full = IO::FromDataFolder("Fonts/" + name).Replace("\\", "/");
                    if (UI::Selectable(name, S_TM_CustomFont == full)) {
                        S_TM_CustomFont = full;
                        ChangeFont();
                    }
                }
            }
            UI::EndCombo();
        }
        UI::Indent(UI::GetScale() * -30.0f);
    }

    S_TM_FontSize = UI::SliderInt("Font Size", S_TM_FontSize, 8, 128);
    S_TM_FontColor = UI::InputColor4("Font Color", S_TM_FontColor);

    if (true
        and !S_TM_Persist
        and !S_TM_ShowOnRespawn
        and (prevPersist or prevShow)
    ){
        tm_showEnd = 0;
    }
}
