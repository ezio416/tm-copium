// c 2024-03-05
// m 2024-03-05

string       diffPB;
bool         firstCP      = true;
string       infos;
bool         inGame       = false;
uint64       lastCPTime   = 0;
int          medal        = -1;
string       myName;
int          preCPIdx     = -1;
int          respawnCount = -1;
uint64       timeShift    = 0;
const string title        = "\\$FA0" + Icons::Flag + "\\$G Better Copium Timer";

const vec4[] medalColors = {
  vec4(0.0f,   0.0f,   0.0f,   0.0f),  // no medal
  vec4(0.604f, 0.400f, 0.259f, 1.0f),  // bronze
  vec4(0.537f, 0.604f, 0.604f, 1.0f),  // silver
  vec4(0.871f, 0.737f, 0.259f, 1.0f),  // gold
  vec4(0.000f, 0.471f, 0.035f, 1.0f)   // author
};

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    myName = App.LocalPlayerInfo.Name;

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
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);

    if (
        App.RootMap is null
        || Playground is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
    )
        return;

    // CSmPlayer@ Player = cast<CSmPlayer@>(Playground.GameTerminals[0].GUIPlayer);
    // if (Player is null)
    //     return;

    // CSmScriptPlayer@ ScriptPlayer = cast<CSmScriptPlayer@>(Player.ScriptAPI);
    // if (ScriptPlayer is null)
    //     return;

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
    if (raceData is null)
        return;

    const MLFeed::PlayerCpInfo_V2@ cpInfo = raceData.GetPlayer_V2(myName);
    if (
        cpInfo is null
        || cpInfo.NbRespawnsRequested == 0
        || !cpInfo.IsLocalPlayer
    )
        return;

    int theoreticalTime = cpInfo.TheoreticalRaceTime;

    if (cpInfo.cpCount == int(raceData.CPsToFinish))
        theoreticalTime = cpInfo.LastTheoreticalCpTime;
    else if (theoreticalTime < 0)
        theoreticalTime = 0;

    string text = Time::Format(theoreticalTime);

    uint[] bestCpTimes;

    const MLFeed::GhostInfo_V2@ pbGhost = null;

    const MLFeed::SharedGhostDataHook_V2@ ghostData = MLFeed::GetGhostData();
    UI::Text("ghosts: " + ghostData.Ghosts_V2.Length);
    for (uint i = 0; i < ghostData.Ghosts_V2.Length; i++) {
        const MLFeed::GhostInfo_V2@ ghost = ghostData.Ghosts_V2[i];
        UI::Text("    " + ghost.Nickname);
        if (ghost.Nickname == "Personal best") {
            @pbGhost = ghost;
            break;
        }
    }

    if (pbGhost !is null) {
        bestCpTimes = pbGhost.Checkpoints;
        for (uint i = 0; i < pbGhost.Checkpoints.Length; i++) {
            UI::Text("        " + Time::Format(pbGhost.Checkpoints[i]));
        }
    } else {
        UI::Text("null pb ghost");

        if (cpInfo.BestRaceTimes.Length == raceData.CPsToFinish) {
            bestCpTimes = cpInfo.BestRaceTimes;
        }
    }

    for (uint i = 0; i < bestCpTimes.Length; i++) {
        UI::Text("- " + bestCpTimes[i]);
    }

    if (cpInfo.cpCount == int(raceData.CPsToFinish) && cpInfo.NbRespawnsRequested > 0)
        text += " (" + cpInfo.NbRespawnsRequested + " respawn" + (cpInfo.NbRespawnsRequested == 1 ? "" : "s") + ")";

    int index = cpInfo.cpTimes.Length - 2;
    UI::Text("index: " + index);
    UI::Text("cpTimes.Length: " + cpInfo.cpTimes.Length);
    UI::Text("bestCpTimes.Length: " + bestCpTimes.Length);
    try {
        uint lastBestTime = bestCpTimes[index];
        UI::Text("lastBestTime: " + lastBestTime);
        UI::Text("lastCpTime: " + cpInfo.lastCpTime);
        UI::Text("delta: " + (cpInfo.lastCpTime - lastBestTime));
        string diff = TimeFormat(cpInfo.lastCpTime - lastBestTime - TimeLostToAllButLastCp(cpInfo.TimeLostToRespawnByCp));
        UI::Text("format diff: " + diff);
        text += " (" + diff + ")";
    } catch {
        UI::Text(getExceptionInfo());
    }

    nvg::FontSize(S_FontSize);
    nvg::FontFace(font);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    const vec2 size = nvg::TextBounds(text);

    const float posX = Draw::GetWidth() * S_X;
    const float posY = Draw::GetHeight() * S_Y;

    if (S_Drop) {
        nvg::FillColor(S_DropColor);
        nvg::Text(posX + S_DropOffset, posY + S_DropOffset, text);
    }

    nvg::FillColor(S_FontColor);
    nvg::Text(posX, posY, text);

    medal = 0;

    if (cpInfo.cpCount == int(raceData.CPsToFinish)) {
        if (theoreticalTime <= int(App.RootMap.TMObjective_AuthorTime))
            medal = 4;
        else if (theoreticalTime <= int(App.RootMap.TMObjective_GoldTime))
            medal = 3;
        else if (theoreticalTime <= int(App.RootMap.TMObjective_SilverTime))
            medal = 2;
        else if (theoreticalTime <= int(App.RootMap.TMObjective_BronzeTime))
            medal = 1;
    }

    // if (!S_Enabled || !inGame || infos.Length == 0)
    //     return;

    // nvg::FontFace(font);
    // nvg::FontSize(S_FontSize);

    // float bck_l = 0.0f;
    // float bck_w = 0.0f;
    // float w = infos.Length < 12 ? infos.Length * S_FontSize * 0.5f : nvg::TextBounds(infos).x;

    const float width = Draw::GetWidth() * S_X;
    const float height = Draw::GetHeight() * S_Y + 1.0f;

    // if (medal > 0) {
    //     bck_w = S_FontSize * 3.0f - 4.0f;
    //     bck_l = -0.5f * bck_w;
    // }

    // if (diffPB == "" || !S_CpDelta) {
    //     nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    //     if (S_Drop) {
    //         nvg::FillColor(S_DropColor);
    //         nvg::TextBox(width - w / 2.0f - 2.0f + S_DropOffset, height + S_DropOffset, w + 4.0f, infos);
    //     } else {
    //         nvg::BeginPath();
    //         nvg::FillColor(S_BackgroundColor);
    //         bck_l += width - w / 2.0f - 3.0f;
    //         bck_w += w + 6.0f;
    //         nvg::Rect(bck_l, height - (S_FontSize - 2) / 2.0f - 3.0f, bck_w, S_FontSize + 2.0f);
    //         nvg::Fill();
    //     }

    //     nvg::FillColor(S_FontColor);
    //     nvg::TextBox(width - w / 2.0f - 2.0f, height, w + 4.0f, infos);
    // } else {
    //     nvg::FontSize(S_FontSize - 2.0f);
    //     const float wd = nvg::TextBounds(diffPB).x;
    //     const float center = (w - wd) / 2.0f;

    //     nvg::FontSize(S_FontSize);
    //     nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);

    //     if (S_Drop) {
    //         nvg::FillColor(S_DropColor);
    //         nvg::TextBox(width + center - w - 10.0f + S_DropOffset, height + S_DropOffset, w + 4.0f, infos);
    //     } else {
    //         nvg::BeginPath();
    //         nvg::FillColor(S_BackgroundColor);
    //         bck_l += width + center - w - 8.0f;
    //         bck_w += w + wd + 17.0f;
    //         nvg::Rect(bck_l, height - (S_FontSize - 2) / 2.0f - 3.0f, bck_w, S_FontSize + 2.0f);
    //         nvg::Fill();
    //     }

    //     nvg::FillColor(S_FontColor);
    //     nvg::TextBox(width + center - w - 10.0f, height, w + 4.0f, infos);

    //     nvg::BeginPath();
    //     nvg::FillColor(diffPB.SubStr(0, 1) == "-" ? S_NegativeColor : S_PositiveColor);
    //     nvg::Rect(width + center + 3.0f, height - (S_FontSize - 2) / 2.0f - 2.0f, wd + 5.0f, S_FontSize);
    //     nvg::Fill();

    //     nvg::FontSize(S_FontSize - 2.0f);
    //     nvg::TextAlign(nvg::Align::Left | nvg::Align::Middle);
    //     nvg::FillColor(S_FontColor);
    //     nvg::TextBox(width + center + 6.0f, height + 1.0f, wd + 4.0f, diffPB);

    //     w += wd + 10.0f;
    // }

    if (medal > 0) {
        const float circleRadius = S_FontSize / 2.5f;
        const float y = height - S_FontSize / 12.0f;

        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::BeginPath();
            nvg::Circle(vec2(width - size.x / 2.0f - S_FontSize + S_DropOffset, y + S_DropOffset), circleRadius);
            nvg::Fill();
            nvg::BeginPath();
            nvg::Circle(vec2(width + size.x / 2.0f + S_FontSize + S_DropOffset, y + S_DropOffset), circleRadius);
            nvg::Fill();
        }

        nvg::BeginPath();
        nvg::FillColor(medalColors[medal]);
        nvg::Circle(vec2(width - size.x / 2.0f - S_FontSize, y), circleRadius);
        nvg::Fill();
        nvg::BeginPath();
        nvg::Circle(vec2(width + size.x / 2.0f + S_FontSize, y), circleRadius);
        nvg::Fill();
    }
}

int TimeLostToAllButLastCp(int[] times) {
    int total = 0;

    for (uint i = 0; i < times.Length; i++) {
        if (i == times.Length - 1)
            break;

        total += times[i];
    }

    return total;
}