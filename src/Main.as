// c 2024-03-05
// m 2024-03-05

const vec4   colorBlue    = vec4(0, 0, 0.8, 0.8);
const vec4   colorRed     = vec4(0.8, 0, 0, 0.8);
string       diffPB;
bool         firstCP      = true;
nvg::Font    font;
string       infos;
bool         inGame       = false;
uint64       lastCPTime   = 0;
int          medal        = -1;
int          preCPIdx     = -1;
int          respawnCount = -1;
uint64       timeShift    = 0;
const string title        = "\\$09F" + Icons::Flag + "\\$G Better Copium Timer";

const vec4[] medals = {
  vec4(0.0f,   0.0f,   0.0f,   0.0f),  // no medal
  vec4(0.604f, 0.400f, 0.259f, 1.0f),  // bronze medal
  vec4(0.537f, 0.604f, 0.604f, 1.0f),  // silver medal
  vec4(0.871f, 0.737f, 0.259f, 1.0f),  // gold medal
  vec4(0.000f, 0.471f, 0.035f, 1.0f),  // author medal
};

void Main() {
    font = nvg::LoadFont("DroidSans-Bold.ttf", true);
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (S_Enabled && inGame && infos != "") {
        nvg::FontFace(font);
        nvg::FontSize(S_FontSize);

        float w = infos.Length < 12 ? infos.Length * S_FontSize * 0.5f : nvg::TextBounds(infos).x;
        float bck_l = 0.0f;
        float bck_w = 0.0f;
        float y = S_X * Draw::GetHeight() + 1.0f;
        float shadowOffset = S_FontSize / 12.0f;

        if (medal > 0) {
            bck_w = S_FontSize * 3.0f - 4.0f;
            bck_l = -0.5f * bck_w;
        }

        if (diffPB == "" || !S_CpDelta) {
            nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

            if (S_DropShadow) {
                nvg::FillColor(vec4(0.0f, 0.0f, 0.0f, 1.0f));
                nvg::TextBox(S_X * Draw::GetWidth() - w / 2.0f - 2.0f + shadowOffset, y + shadowOffset, w + 4.0f, infos);
            } else {
                nvg::BeginPath();
                bck_l += S_X * Draw::GetWidth() - w / 2.0f - 3.0f;
                bck_w += w + 6.0f;
                nvg::Rect(bck_l, y - (S_FontSize - 2) / 2.0f - 3.0f, bck_w, S_FontSize + 2.0f);
                nvg::FillColor(S_BackgroundColor);
                nvg::Fill();
                nvg::ClosePath();
            }

            nvg::FillColor(S_FontColor);
            nvg::TextBox(S_X * Draw::GetWidth() - w / 2.0f - 2.0f, y, w + 4.0f, infos);
        } else {
            nvg::FontSize(S_FontSize - 2.0f);
            float wd = nvg::TextBounds(diffPB).x;
            float center = (w - wd) / 2.0f;

            nvg::FontSize(S_FontSize);
            nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);

            if (S_DropShadow) {
                nvg::FillColor(vec4(0.0f, 0.0f, 0.0f, 1.0f));
                nvg::TextBox(S_X * Draw::GetWidth() +center - w - 10.0f + shadowOffset, y + shadowOffset, w + 4.0f, infos);
            } else {
                nvg::BeginPath();
                bck_l += S_X * Draw::GetWidth() + center - w - 8.0f;
                bck_w += w + wd + 17.0f;
                nvg::Rect(bck_l, y - (S_FontSize - 2) / 2.0f - 3.0f, bck_w, S_FontSize + 2.0f);
                nvg::FillColor(S_BackgroundColor);
                nvg::Fill();
                nvg::ClosePath();
            }

            nvg::FillColor(S_FontColor);
            nvg::TextBox(S_X * Draw::GetWidth() + center - w - 10.0f, y, w + 4.0f, infos);

            nvg::BeginPath();
            nvg::Rect(S_X * Draw::GetWidth() + center + 3.0f, y - (S_FontSize - 2) / 2.0f - 2.0f, wd + 5.0f, S_FontSize);
            nvg::FillColor(diffPB.SubStr(0, 1) == "-" ? colorBlue : colorRed);
            nvg::Fill();
            nvg::ClosePath();

            nvg::FontSize(S_FontSize - 2.0f);
            nvg::TextAlign(nvg::Align::Left | nvg::Align::Middle);
            nvg::FillColor(S_FontColor);
            nvg::TextBox(S_X * Draw::GetWidth() + center + 6.0f, y + 1.0f, wd + 4.0f, diffPB);

            w += wd + 10.0f;
        }

        if (medal >= 1) {
            if (S_DropShadow) {
                nvg::BeginPath();
                nvg::Ellipse(vec2(S_X * Draw::GetWidth() - w / 2.0f - S_FontSize + shadowOffset, y - 1.0f + shadowOffset), S_FontSize / 2.5f, S_FontSize / 2.5f);
                nvg::FillColor(vec4(0.0f, 0.0f, 0.0f, 1.0f));
                nvg::Fill();
                nvg::ClosePath();
                nvg::BeginPath();
                nvg::Ellipse(vec2(S_X * Draw::GetWidth() + w / 2.0f + S_FontSize + shadowOffset, y - 1.0f + shadowOffset), S_FontSize / 2.5f, S_FontSize / 2.5f);
                nvg::FillColor(vec4(0.0f, 0.0f, 0.0f, 1.0f));
                nvg::Fill();
                nvg::ClosePath();
            }

            nvg::BeginPath();
            nvg::Ellipse(vec2(S_X * Draw::GetWidth() - w / 2.0f - S_FontSize, y - 1.0f), S_FontSize / 2.5f, S_FontSize / 2.5f);
            nvg::FillColor(medals[medal]);
            nvg::Fill();
            nvg::ClosePath();
            nvg::BeginPath();
            nvg::Ellipse(vec2(S_X * Draw::GetWidth() + w / 2.0f + S_FontSize, y - 1.0f), S_FontSize / 2.5f, S_FontSize / 2.5f);
            nvg::FillColor(medals[medal]);
            nvg::Fill();
            nvg::ClosePath();
        }
    }
}

void Update(float) {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);

    if (
        Playground is null
        || Playground.Arena is null
        || Playground.Map is null
        || Playground.GameTerminals.Length == 0
        || (Playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Playing
            && Playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Finish
            && Playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::EndRound)
    ) {
        inGame = false;
        preCPIdx = -1;
        firstCP = true;
        return;
    }

    CSmPlayer@ Player = cast<CSmPlayer@>(Playground.GameTerminals[0].GUIPlayer);
    CSmScriptPlayer@ ScriptPlayer = Player is null ? null : cast<CSmScriptPlayer@>(Player.ScriptAPI);
    int64 raceTime = 0;

    if (Playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::EndRound) {
        if (ScriptPlayer is null) {
            inGame = false;
            preCPIdx = -1;
            firstCP = true;
            return;
        }

        raceTime = GetRaceTime(ScriptPlayer);

        if (Player.CurrentLaunchedRespawnLandmarkIndex == uint(-1) || raceTime <= 0) {
            inGame = false;
            preCPIdx = -1;
            firstCP = true;
            return;
        }
    }

    // in game only if interface displayed or don't care
    inGame = !S_HideWithGame || UI::IsGameUIVisible();

    if (Playground.GameTerminals[0].UISequence_Current == CGamePlaygroundUIConfig::EUISequence::Playing) {
        if (preCPIdx == -1) {
            // starting => no time shift, no respawn yet
            lastCPTime = timeShift = respawnCount = 0;
            infos = "";
            diffPB = "";
            medal = -1;
            preCPIdx = Player.CurrentLaunchedRespawnLandmarkIndex;
            firstCP = true;
        } else {
            if (preCPIdx != int(Player.CurrentLaunchedRespawnLandmarkIndex)) {
                // changing CP => save last CP time with time shift
                preCPIdx = Player.CurrentLaunchedRespawnLandmarkIndex;
                firstCP = false;
                lastCPTime = raceTime - timeShift;

                if (respawnCount > 0 && S_CpDelta) {
                    int64 diff = GetDiffPB();

                    if (diff == 0)
                        diffPB = "";
                    else
                        diffPB = FormatDiff(diff - timeShift);
                }
            }

            if (respawnCount < int(ScriptPlayer.Score.NbRespawnsRequested)) {
                // changing respawn count => time shift recalculated so that timer will be reset to last CP time
                respawnCount = ScriptPlayer.Score.NbRespawnsRequested;
                timeShift = raceTime - lastCPTime;

                if (!firstCP)
                    timeShift += 1000;  // 1000 = 3 - 2 - 1 delay (not applicable on first CP)
            }
        }

        if (respawnCount > 0 && uint64(raceTime) >= timeShift)  // display timer only if at least one respawn
            infos = FormatTime(raceTime - timeShift);

    } else if (preCPIdx != -1) {
        preCPIdx = -1;
        firstCP = true;

        if (respawnCount > 0 && uint64(raceTime) >= timeShift) {
            infos = FormatTime(raceTime - timeShift) + " (" + respawnCount + " respawn" + (respawnCount > 1 ? "s" : "") + ")";

            if (S_CpDelta) {
                int64 diff = GetDiffPB();

                if (diff == 0)
                    diffPB = "";
                else
                    diffPB = FormatDiff(diff - timeShift);
            }

            CGameCtnChallenge@ Map = App.RootMap;

            if (Map.TMObjective_AuthorTime >= uint(raceTime - timeShift))
                medal = 4;
            else if (Map.TMObjective_GoldTime >= uint(raceTime - timeShift))
                medal = 3;
            else if (Map.TMObjective_SilverTime >= uint(raceTime - timeShift))
                medal = 2;
            else if (Map.TMObjective_BronzeTime >= uint(raceTime - timeShift))
                medal = 1;
            else
                medal = 0;
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
            if (Label is null || !Label.Visible || !Label.Parent.Visible)  // reference lap not finished
                break;

            string diff = string(Label.Value);
            int64 res = 0;

            if (diff.Length == 10) {  // invalid format
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