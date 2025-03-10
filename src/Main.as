// c 2024-03-05
// m 2025-02-25

dictionary@                 ghostFirstSeenMap  = dictionary();
int                         highestGhostIdSeen = -1;
uint                        lastNbGhosts       = 0;
string                      loginLocal;
string                      myName;
const MLFeed::GhostInfo_V2@ pbGhost            = null;
const string                pluginColor        = "\\$FA0";
const string                pluginIcon         = Icons::Flag;
Meta::Plugin@               pluginMeta         = Meta::ExecutingPlugin();
const string                pluginTitle        = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
dictionary@                 seenGhosts         = dictionary();

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    myName = App.LocalPlayerInfo.Name;

    startnew(CacheLocalLogin);

    ChangeFont();
}

void OnSettingsChanged() {
    if (currentFont != S_Font)
        ChangeFont();
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

    if (false
        || App.RootMap is null
        || Playground is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
        || Playground.UIConfigs.Length == 0
        || Playground.UIConfigs[0] is null
    ) {
        highestGhostIdSeen = -1;
        lastNbGhosts = 0;
        @pbGhost = null;
        seenGhosts.DeleteAll();
        return;
    }

    const CGamePlaygroundUIConfig::EUISequence Sequence = Playground.UIConfigs[0].UISequence;
    if (true
        && Sequence != CGamePlaygroundUIConfig::EUISequence::EndRound
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Finish
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Playing
    )
        return;

    if (true
        && Sequence == CGamePlaygroundUIConfig::EUISequence::Playing
        && Playground.GameTerminals[0].GUIPlayer is null
    )
        return;  // watching replay

    CSmPlayer@ ViewingPlayer = VehicleState::GetViewingPlayer();
    if (true
        && ViewingPlayer !is null
        && ViewingPlayer.ScriptAPI !is null
        && ViewingPlayer.ScriptAPI.Login != loginLocal
    )
        return;  // spectating

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
    if (raceData is null)
        return;

    const MLFeed::PlayerCpInfo_V4@ cpInfo = raceData.GetPlayer_V4(myName);
    if (cpInfo is null || !cpInfo.IsLocalPlayer || cpInfo.NbRespawnsRequested == 0)
        return;

    const bool finished = cpInfo.cpCount == int(raceData.CPsToFinish);
    const uint theoreticalTime = finished ? cpInfo.LastTheoreticalCpTime : Math::Max(0, cpInfo.TheoreticalRaceTime);
    if (theoreticalTime == 0)
        return;

    const MLFeed::SharedGhostDataHook_V2@ ghostData = MLFeed::GetGhostData();

    if (lastNbGhosts != ghostData.NbGhosts) {
        lastNbGhosts = ghostData.NbGhosts;
        string key;

        for (uint i = 0; i < ghostData.LoadedGhosts.Length; i++) {
            MLFeed::GhostInfo_V2@ ghost = ghostData.LoadedGhosts[i];

            if (int(ghost.IdUint) <= highestGhostIdSeen)
                continue;
            highestGhostIdSeen = ghost.IdUint;

            key = SeenGhostSaveMap(ghost);
            if (seenGhosts.Exists(key))
                continue;
            seenGhosts[key] = true;

            if (
                (pbGhost is null || ghost.Result_Time < pbGhost.Result_Time)
                && (ghost.Nickname == "Personal best" || ghost.Nickname == myName)
            )
                @pbGhost = ghost;
        }
    }

    uint[] bestCpTimes = {};

    if (pbGhost !is null)
        bestCpTimes = pbGhost.Checkpoints;

    if (cpInfo.BestRaceTimes.Length == raceData.CPsToFinish && (pbGhost is null || cpInfo.bestTime < pbGhost.Result_Time))
        bestCpTimes = cpInfo.BestRaceTimes;

    string text = Time::Format(theoreticalTime);
    if (!S_Thousandths)
        text = text.SubStr(0, text.Length - 1);

    if (finished && cpInfo.NbRespawnsRequested > 0 && S_Respawns)
        text += " (" + cpInfo.NbRespawnsRequested + " respawn" + (cpInfo.NbRespawnsRequested == 1 ? "" : "s") + ")";

    int diff = 0;
    string diffText;

    if (bestCpTimes.Length > 0 && cpInfo.cpTimes.Length > 1) {
        diff = cpInfo.lastCpTime - bestCpTimes[cpInfo.cpTimes.Length - 2] - SumAllButLast(cpInfo.TimeLostToRespawnByCp);
        diffText = TimeFormat(diff);
        if (!S_Thousandths)
            diffText = diffText.SubStr(0, diffText.Length - 1);
        text += (S_Font == Font::DroidSansMono ? " " : "  ") + diffText;
    }

    nvg::FontSize(S_FontSize);
    nvg::FontFace(font);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    const vec2 size = nvg::TextBounds(text);
    const float diffWidth = nvg::TextBounds(diffText).x;

    const float posX = Draw::GetWidth() * S_X;
    const float posY = Draw::GetHeight() * S_Y;
    const float radius = S_FontSize * 0.4f;

    int medal = 0;

    if (finished) {
#if DEPENDENCY_CHAMPIONMEDALS
        const uint cm = ChampionMedals::GetCMTime();
#endif
#if DEPENDENCY_WARRIORMEDALS
        const uint wm = WarriorMedals::GetWMTime();
#endif

#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        uint medal5 = 0, medal6 = 0;

        if (cm == 0)
            medal5 = wm;
        else if (wm == 0)
            medal5 = cm;
        else if (cm <= wm) {
            medal5 = wm;
            medal6 = cm;
        } else {
            medal5 = cm;
            medal6 = wm;
        }
#endif

        if (false) {}  // here so preprocessors work
#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        else if (theoreticalTime <= medal6)
            medal = 6;
        else if (theoreticalTime <= medal5)
            medal = 5;
#elif DEPENDENCY_CHAMPIONMEDALS
        else if (theoreticalTime <= cm)
            medal = 5;
#elif DEPENDENCY_WARRIORMEDALS
        else if (theoreticalTime <= wm)
            medal = 5;
#endif
        else if (theoreticalTime <= App.RootMap.TMObjective_AuthorTime)
            medal = 4;
        else if (theoreticalTime <= App.RootMap.TMObjective_GoldTime)
            medal = 3;
        else if (theoreticalTime <= App.RootMap.TMObjective_SilverTime)
            medal = 2;
        else if (theoreticalTime <= App.RootMap.TMObjective_BronzeTime)
            medal = 1;
    }

    const float halfSizeX = size.x * 0.5f;
    const float halfSizeY = size.y * 0.5f;

    if (S_Background == BackgroundOption::BehindEverything) {
        nvg::FillColor(S_BackgroundColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX - halfSizeX - S_BackgroundXPad - (S_Medals && medal > 0 ? S_FontSize + radius : 0.0f),
            posY - halfSizeY - S_BackgroundYPad - 2.0f,
            size.x + S_BackgroundXPad * 2.0f + (S_Medals && medal > 0 ? (S_FontSize + radius) * 2.0f : 0.0f),
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    if (S_Background > 0 && bestCpTimes.Length > 0 && cpInfo.cpCount > 0) {
        const float diffBgOffset = S_FontSize * 0.125f;

        nvg::FillColor(diff > 0 ? S_PositiveColor : diff == 0 ? S_NeutralColor : S_NegativeColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX + halfSizeX - diffWidth - diffBgOffset,
            posY - halfSizeY - S_BackgroundYPad - 2.0f,
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

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}
