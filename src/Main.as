// c 2024-03-05
// m 2024-03-05

string       diffPB;
bool         firstCP      = true;
string       infos;
bool         inGame       = false;
uint64       lastCPTime   = 0;
int          medal        = -1;
int          preCPIdx     = -1;
int          respawnCount = -1;
uint64       timeShift    = 0;
const string title        = "\\$09F" + Icons::Flag + "\\$G Better Copium Timer";

const vec4[] medalColors = {
  vec4(0.0f,   0.0f,   0.0f,   0.0f),  // no medal
  vec4(0.604f, 0.400f, 0.259f, 1.0f),  // bronze
  vec4(0.537f, 0.604f, 0.604f, 1.0f),  // silver
  vec4(0.871f, 0.737f, 0.259f, 1.0f),  // gold
  vec4(0.000f, 0.471f, 0.035f, 1.0f)   // author
};

void Main() {
    ChangeFont();
}

void OnSettingsChanged() {
    if (currentFont != S_Font)
        ChangeFont();
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (!S_Enabled || !inGame || infos.Length == 0)
        return;

    nvg::FontFace(font);
    nvg::FontSize(S_FontSize);

    float bck_l = 0.0f;
    float bck_w = 0.0f;
    float w = infos.Length < 12 ? infos.Length * S_FontSize * 0.5f : nvg::TextBounds(infos).x;

    const float width = Draw::GetWidth() * S_X;
    const float height = Draw::GetHeight() * S_Y + 1.0f;

    if (medal > 0) {
        bck_w = S_FontSize * 3.0f - 4.0f;
        bck_l = -0.5f * bck_w;
    }

    if (diffPB == "" || !S_CpDelta) {
        nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::TextBox(width - w / 2.0f - 2.0f + S_DropOffset, height + S_DropOffset, w + 4.0f, infos);
        } else {
            nvg::BeginPath();
            bck_l += width - w / 2.0f - 3.0f;
            bck_w += w + 6.0f;
            nvg::Rect(bck_l, height - (S_FontSize - 2) / 2.0f - 3.0f, bck_w, S_FontSize + 2.0f);
            nvg::FillColor(S_BackgroundColor);
            nvg::Fill();
        }

        nvg::FillColor(S_FontColor);
        nvg::TextBox(width - w / 2.0f - 2.0f, height, w + 4.0f, infos);
    } else {
        nvg::FontSize(S_FontSize - 2.0f);
        const float wd = nvg::TextBounds(diffPB).x;
        const float center = (w - wd) / 2.0f;

        nvg::FontSize(S_FontSize);
        nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);

        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::TextBox(width + center - w - 10.0f + S_DropOffset, height + S_DropOffset, w + 4.0f, infos);
        } else {
            nvg::BeginPath();
            bck_l += width + center - w - 8.0f;
            bck_w += w + wd + 17.0f;
            nvg::Rect(bck_l, height - (S_FontSize - 2) / 2.0f - 3.0f, bck_w, S_FontSize + 2.0f);
            nvg::FillColor(S_BackgroundColor);
            nvg::Fill();
        }

        nvg::FillColor(S_FontColor);
        nvg::TextBox(width + center - w - 10.0f, height, w + 4.0f, infos);

        nvg::BeginPath();
        nvg::Rect(width + center + 3.0f, height - (S_FontSize - 2) / 2.0f - 2.0f, wd + 5.0f, S_FontSize);
        nvg::FillColor(diffPB.SubStr(0, 1) == "-" ? S_NegativeColor : S_PositiveColor);
        nvg::Fill();

        nvg::FontSize(S_FontSize - 2.0f);
        nvg::TextAlign(nvg::Align::Left | nvg::Align::Middle);
        nvg::FillColor(S_FontColor);
        nvg::TextBox(width + center + 6.0f, height + 1.0f, wd + 4.0f, diffPB);

        w += wd + 10.0f;
    }

    if (medal > 0) {
        // if (S_Background) {
        //     nvg::FillColor(S_BackgroundColor);
        //     nvg::BeginPath();
        //     nvg::RoundedRect(
        //         width - size.x * 0.5f - S_BackgroundXPad,
        //         height - size.y * 0.5f - S_BackgroundYPad - 2.0f,
        //         size.x + S_BackgroundXPad * 2.0f,
        //         size.y + S_BackgroundYPad * 2.0f,
        //         S_BackgroundRadius
        //     );
        //     nvg::Fill();
        // }

        const float circleRadius = S_FontSize / 2.5f;
        const float y = height - S_FontSize / 12.0f;

        if (S_Drop) {
            nvg::BeginPath();
            nvg::Circle(vec2(width - w / 2.0f - S_FontSize + S_DropOffset, y + S_DropOffset), circleRadius);
            nvg::FillColor(S_DropColor);
            nvg::Fill();
            nvg::BeginPath();
            nvg::Circle(vec2(width + w / 2.0f + S_FontSize + S_DropOffset, y + S_DropOffset), circleRadius);
            nvg::Fill();
        }

        nvg::BeginPath();
        nvg::Circle(vec2(width - w / 2.0f - S_FontSize, y), circleRadius);
        nvg::FillColor(medalColors[medal]);
        nvg::Fill();
        nvg::BeginPath();
        nvg::Circle(vec2(width + w / 2.0f + S_FontSize, y), circleRadius);
        nvg::Fill();
    }
}

void Update(float) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    CGamePlaygroundUIConfig::EUISequence Sequence = Playground.UIConfigs[0].UISequence;

    if (
        Playground is null
        || Playground.Arena is null
        || Playground.Map is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
        || (Sequence != CGamePlaygroundUIConfig::EUISequence::Playing
            && Sequence != CGamePlaygroundUIConfig::EUISequence::Finish
            && Sequence != CGamePlaygroundUIConfig::EUISequence::EndRound)
        || Network.PlaygroundClientScriptAPI is null
    ) {
        inGame = false;
        preCPIdx = -1;
        firstCP = true;
        return;
    }

    CSmPlayer@ Player = cast<CSmPlayer@>(Playground.GameTerminals[0].GUIPlayer);
    CSmScriptPlayer@ ScriptPlayer = Player is null ? null : cast<CSmScriptPlayer@>(Player.ScriptAPI);
    int64 raceTime = 0;

    if (Sequence != CGamePlaygroundUIConfig::EUISequence::EndRound) {
        if (ScriptPlayer is null) {
            inGame = false;
            preCPIdx = -1;
            firstCP = true;
            return;
        }

        raceTime = Network.PlaygroundClientScriptAPI.GameTime - ScriptPlayer.StartTime;

        if (Player.CurrentLaunchedRespawnLandmarkIndex == uint(-1) || raceTime <= 0) {
            inGame = false;
            preCPIdx = -1;
            firstCP = true;
            return;
        }
    }

    inGame = !S_HideWithGame || UI::IsGameUIVisible();

    if (Playground.GameTerminals[0].UISequence_Current == CGamePlaygroundUIConfig::EUISequence::Playing) {
        if (preCPIdx == -1) {
            lastCPTime = timeShift = respawnCount = 0;
            infos = "";
            diffPB = "";
            medal = -1;
            preCPIdx = Player.CurrentLaunchedRespawnLandmarkIndex;
            firstCP = true;
        } else {
            if (preCPIdx != int(Player.CurrentLaunchedRespawnLandmarkIndex)) {
                preCPIdx = Player.CurrentLaunchedRespawnLandmarkIndex;
                firstCP = false;
                lastCPTime = raceTime - timeShift;

                if (respawnCount > 0 && S_CpDelta) {
                    int64 diff = GetDiffPB();
                    diffPB = diff == 0 ? "" : FormatDiff(diff - timeShift);
                }
            }

            if (respawnCount < int(ScriptPlayer.Score.NbRespawnsRequested)) {
                respawnCount = ScriptPlayer.Score.NbRespawnsRequested;
                timeShift = raceTime - lastCPTime;

                if (!firstCP)
                    timeShift += 1000;
            }
        }

        if (respawnCount > 0 && uint64(raceTime) >= timeShift)
            infos = Time::Format(raceTime - timeShift);

    } else if (preCPIdx != -1) {
        preCPIdx = -1;
        firstCP = true;

        if (respawnCount > 0 && uint64(raceTime) >= timeShift) {
            infos = Time::Format(raceTime - timeShift) + " (" + respawnCount + " respawn" + (respawnCount > 1 ? "s" : "") + ")";

            if (S_CpDelta) {
                int64 diff = GetDiffPB();
                diffPB = diff == 0 ? "" : FormatDiff(diff - timeShift);
            }

            CGameCtnChallenge@ Map = App.RootMap;
            medal = 0;

            if (Map.TMObjective_AuthorTime >= uint(raceTime - timeShift))
                medal = 4;
            else if (Map.TMObjective_GoldTime >= uint(raceTime - timeShift))
                medal = 3;
            else if (Map.TMObjective_SilverTime >= uint(raceTime - timeShift))
                medal = 2;
            else if (Map.TMObjective_BronzeTime >= uint(raceTime - timeShift))
                medal = 1;
        }
    }
}

int64 GetDiffPB() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

    if (CMAP is null)
        return 0;

    for (uint i = 0; i < CMAP.UILayers.Length; i++) {
        CGameUILayer@ Layer = CMAP.UILayers[i];
        if (Layer is null)
            continue;

        string Page = string(Layer.ManialinkPage);

        int start = Page.IndexOf("<");
        int end = Page.IndexOf(">");

        if (start != -1 && end != -1 && Page.SubStr(start, end).Contains("UIModule_Race_Checkpoint")) {
            CGameManialinkLabel@ Label = cast<CGameManialinkLabel@>(Layer.LocalPage.GetFirstChild("label-race-diff"));
            if (Label is null || !Label.Visible || !Label.Parent.Visible)
                break;

            string diff = string(Label.Value);
            int64 res = 0;

            if (diff.Length == 10) {
                res = diff.SubStr(0, 1) == "-" ? -1 : 1;
                int min = Text::ParseInt(diff.SubStr(1, 2));
                int sec = Text::ParseInt(diff.SubStr(4, 2));
                int ms = Text::ParseInt(diff.SubStr(7, 3));
                res *= (min * 60000) + (sec * 1000) + ms;
            }

            return res;
        }
    }

    return 0;
}