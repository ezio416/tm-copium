// c 2024-03-05
// m 2024-03-06

string       myName;
const string title = "\\$FA0" + Icons::Flag + "\\$G Better Copium Timer";

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
        || Playground.UIConfigs.Length == 0
        || Playground.UIConfigs[0] is null
    )
        return;

    CGamePlaygroundUIConfig::EUISequence Sequence = Playground.UIConfigs[0].UISequence;
    if (
        Sequence != CGamePlaygroundUIConfig::EUISequence::EndRound
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Finish
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Playing
    )
        return;

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

    int medal = 0;

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

    nvg::FontSize(S_FontSize);
    nvg::FontFace(font);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    string text = Time::Format(theoreticalTime);

    uint[] bestCpTimes;

    const MLFeed::GhostInfo_V2@ pbGhost = null;

    const MLFeed::SharedGhostDataHook_V2@ ghostData = MLFeed::GetGhostData();
    for (uint i = 0; i < ghostData.Ghosts_V2.Length; i++) {
        const MLFeed::GhostInfo_V2@ ghost = ghostData.Ghosts_V2[i];

        if (ghost.Nickname == "Personal best") {
            @pbGhost = ghost;
            break;
        }
    }

    if (pbGhost !is null)
        bestCpTimes = pbGhost.Checkpoints;
    else if (cpInfo.BestRaceTimes.Length == raceData.CPsToFinish)
        bestCpTimes = cpInfo.BestRaceTimes;

    if (cpInfo.cpCount == int(raceData.CPsToFinish) && cpInfo.NbRespawnsRequested > 0 && S_Respawns)
        text += " (" + cpInfo.NbRespawnsRequested + " respawn" + (cpInfo.NbRespawnsRequested == 1 ? "" : "s") + ")";

    int diff = 0;
    string diffText;

    if (bestCpTimes.Length > 0 && cpInfo.cpTimes.Length > 1) {
        diff = cpInfo.lastCpTime - bestCpTimes[cpInfo.cpTimes.Length - 2] - SumAllButLast(cpInfo.TimeLostToRespawnByCp);
        diffText = TimeFormat(diff);
        text += (S_Font == Font::DroidSansMono ? " " : "  ") + diffText;
    }

    const vec2 size = nvg::TextBounds(text);
    const float diffWidth = nvg::TextBounds(diffText).x;

    const float posX = Draw::GetWidth() * S_X;
    const float posY = Draw::GetHeight() * S_Y;
    const float radius = S_FontSize * 0.4f;

    if (S_Background == BackgroundOption::BehindEverything) {
        nvg::FillColor(S_BackgroundColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX - size.x * 0.5f - S_BackgroundXPad - (S_Medals && medal > 0 ? S_FontSize + radius : 0.0f),
            posY - size.y * 0.5f - S_BackgroundYPad - 2.0f,
            size.x + S_BackgroundXPad * 2.0f + (S_Medals && medal > 0 ? (S_FontSize + radius) * 2.0f : 0.0f),
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    if (bestCpTimes.Length > 0 && S_Background > 0) {
        const float diffBgOffset = S_FontSize * 0.125f;

        nvg::FillColor(diff > 0 ? S_PositiveColor : diff == 0 ? S_NeutralColor : S_NegativeColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX + size.x * 0.5f - diffWidth - diffBgOffset,
            posY - size.y * 0.5f - S_BackgroundYPad - 2.0f,
            diffWidth + diffBgOffset + S_BackgroundXPad,
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    if (S_Drop) {
        nvg::FillColor(S_DropColor);
        nvg::Text(posX + S_DropOffset, posY + S_DropOffset, text);
    }

    nvg::FillColor(S_FontColor);
    nvg::Text(posX, posY, text);

    if (S_Medals && medal > 0) {
        const float halfSizeX = size.x * 0.5f;
        const float y = posY + 1.0f - S_FontSize * 0.1f;

        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::BeginPath();
            nvg::Circle(vec2(posX - halfSizeX - S_FontSize + S_DropOffset, y + S_DropOffset), radius);
            nvg::Fill();
            nvg::BeginPath();
            nvg::Circle(vec2(posX + halfSizeX + S_FontSize + S_DropOffset, y + S_DropOffset), radius);
            nvg::Fill();
        }

        nvg::BeginPath();
        nvg::FillColor(GetMedalColor(medal));
        nvg::Circle(vec2(posX - halfSizeX - S_FontSize, y), radius);
        nvg::Fill();
        nvg::BeginPath();
        nvg::Circle(vec2(posX + halfSizeX + S_FontSize, y), radius);
        nvg::Fill();
    }
}