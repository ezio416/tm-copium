// c 2024-03-05
// m 2025-04-08

dictionary@                 ghostFirstSeenMap  = dictionary();
int                         highestGhostIdSeen = -1;
uint                        lastNbGhosts       = 0;
// string                      loginLocal;
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

    // startnew(CacheLocalLogin);

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
        Reset();
        return;
    }

    const CGamePlaygroundUIConfig::EUISequence Sequence = Playground.UIConfigs[0].UISequence;
    const bool playing = Sequence == CGamePlaygroundUIConfig::EUISequence::Playing;
    const bool end = false
        || Sequence == CGamePlaygroundUIConfig::EUISequence::EndRound
        || Sequence == CGamePlaygroundUIConfig::EUISequence::Finish
    ;
    if (!end && !playing)
        return;

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
    if (raceData is null)
        return;

    const MLFeed::PlayerCpInfo_V4@ cpInfo = raceData.GetPlayer_V4(myName);
    if (false
        || cpInfo is null
        || !cpInfo.IsLocalPlayer  // is this possible?
        || cpInfo.NbRespawnsRequested == 0
        || cpInfo.spawnStatus != MLFeed::SpawnStatus::Spawned
    ) {
        // Reset();
        return;
    }

    const bool finished = cpInfo.cpCount == int(raceData.CPsToFinish);
    const uint theoreticalTime = finished ? cpInfo.LastTheoreticalCpTime : Math::Max(0, cpInfo.TheoreticalRaceTime);
    if (theoreticalTime == 0)
        return;

    const MLFeed::SharedGhostDataHook_V2@ ghostData = MLFeed::GetGhostData();

    UI::Text("\\$F8Fghosts: " + ghostData.NbGhosts);

    // do I need to manually load my pb ghost when joining a map?
    // if (ghostData.NbGhosts == 0) {
    //     auto mgr = App.Network.ClientManiaAppPlayground.DataFileMgr;
    //     mgr.repl
    // }

    // 202504082237 going to bed, but I still need to figure out logic during the first finish of a map after loading
    // if pbGhost is null when we finish, we should use cpInfo.BestRaceTimes
    //
    // debug screen should be fleshed out a bit

    if (lastNbGhosts != ghostData.NbGhosts) {
        lastNbGhosts = ghostData.NbGhosts;
        string key;

        // if (pbGhost is null && ghostData.NbGhosts > 0 && ghostData.Ghosts_V2[0].IsLocalPlayer)
        //     @pbGhost = ghostData.Ghosts_V2[0];  // 202504082242 this is the last thing I commented, untested

        // else {
            for (uint i = 0; i < ghostData.Ghosts_V2.Length; i++) {
                const MLFeed::GhostInfo_V2@ ghost = ghostData.Ghosts_V2[i];

                if (int(ghost.IdUint) <= highestGhostIdSeen)
                    continue;
                highestGhostIdSeen = ghost.IdUint;

                key = SeenGhostSaveMap(ghost);
                if (seenGhosts.Exists(key))
                    continue;
                seenGhosts[key] = true;

                if (true
                    && (pbGhost is null || ghost.Result_Time < pbGhost.Result_Time)
                    // && (ghost.Nickname == "Personal best" || ghost.Nickname == myName)
                    && (ghost.IsPersonalBest || ghost.IsLocalPlayer)
                    && !end
                )
                    @pbGhost = ghost;
            }
        // }

        warn("(" + ghostData.NbGhosts + " ghosts) pbGhost: " + (pbGhost !is null ? "valid" : "null"));
    }

    uint[] bestCpTimes = {};

    if (pbGhost !is null)
        bestCpTimes = pbGhost.Checkpoints;

    if (true
        && cpInfo.BestRaceTimes.Length == raceData.CPsToFinish
        && (pbGhost is null || cpInfo.bestTime < pbGhost.Result_Time)
        && (pbGhost is null || !end)
    )
        bestCpTimes = cpInfo.BestRaceTimes;

    string text = Time::Format(theoreticalTime);
    if (!S_Thousandths)
        text = text.SubStr(0, text.Length - 1);

    if (finished && cpInfo.NbRespawnsRequested > 0 && S_Respawns)
        text += " (" + cpInfo.NbRespawnsRequested + " respawn" + (cpInfo.NbRespawnsRequested == 1 ? "" : "s") + ")";

    int diff = 0;
    string diffText;

    if (bestCpTimes.Length > 1 && cpInfo.cpTimes.Length > 1) {
        diff = cpInfo.lastCpTime - bestCpTimes[cpInfo.cpTimes.Length - 2] - SumAllButLast(cpInfo.TimeLostToRespawnByCp);  // oob
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

    if (UI::Begin(pluginTitle + "\\$888 (debug)", S_Debug, UI::WindowFlags::None)) {
        if (cpInfo is null)
            UI::Text("\\$F00cpInfo null");
        else {
            UI::Text("cpInfo.CurrentLap: "             + tostring(cpInfo.CurrentLap));
            UI::Text("cpInfo.WebServicesUserId: "      + tostring(cpInfo.WebServicesUserId));
            UI::Text("cpInfo.Login: "                  + tostring(cpInfo.Login));
            UI::Text("cpInfo.LoginMwId.Value: "        + tostring(cpInfo.LoginMwId.Value));
            UI::Text("cpInfo.LoginMwId.GetName(): "    + tostring(cpInfo.LoginMwId.GetName()));
            UI::Text("cpInfo.NameMwId.Value: "         + tostring(cpInfo.NameMwId.Value));
            UI::Text("cpInfo.NameMwId.GetName(): "     + tostring(cpInfo.NameMwId.GetName()));
            UI::Text("cpInfo.RoundPoints: "            + tostring(cpInfo.RoundPoints));
            UI::Text("cpInfo.Points: "                 + tostring(cpInfo.Points));
            UI::Text("cpInfo.TeamNum: "                + tostring(cpInfo.TeamNum));
            UI::Text("cpInfo.IsMVP: "                  + tostring(cpInfo.IsMVP));
            UI::Text("cpInfo.FirstSeen: "              + tostring(cpInfo.FirstSeen));
            string str;
            foreach (uint time : cpInfo.BestLapTimes) str += time + " ";
            UI::Text("cpInfo.BestLapTimes: "           + str);
            UI::Text("cpInfo.raceRespawnRank: "        + tostring(cpInfo.raceRespawnRank));
            str = "";
            foreach (uint time : cpInfo.BestRaceTimes) str += time + " ";
            UI::Text("cpInfo.BestRaceTimes: "          + str);
            UI::Text("cpInfo.IsLocalPlayer: "          + tostring(cpInfo.IsLocalPlayer));
            UI::Text("cpInfo.StartTime: "              + tostring(cpInfo.StartTime));
            UI::Text("cpInfo.NbRespawnsRequested: "    + tostring(cpInfo.NbRespawnsRequested));
            UI::Text("cpInfo.LastRespawnRaceTime: "    + tostring(cpInfo.LastRespawnRaceTime));
            UI::Text("cpInfo.LastRespawnCheckpoint: "  + tostring(cpInfo.LastRespawnCheckpoint));
            UI::Text("cpInfo.TimeLostToRespawns: "     + tostring(cpInfo.TimeLostToRespawns));
            UI::Text("cpInfo.latencyEstimate: "        + tostring(cpInfo.latencyEstimate));
            UI::Text("cpInfo.lagDataPoints: "          + tostring(cpInfo.lagDataPoints));
            UI::Text("cpInfo.name: "                   + tostring(cpInfo.name));
            UI::Text("cpInfo.cpCount: "                + tostring(cpInfo.cpCount));
            UI::Text("cpInfo.lastCpTime: "             + tostring(cpInfo.lastCpTime));
            str = "";
            foreach (uint time : cpInfo.cpTimes) str += time + " ";
            UI::Text("cpInfo.cpTimes: "                + str);
            UI::Text("cpInfo.bestTime: "               + tostring(cpInfo.bestTime));
            UI::Text("cpInfo.spawnStatus: "            + tostring(cpInfo.spawnStatus));
            UI::Text("cpInfo.spawnIndex: "             + tostring(cpInfo.spawnIndex));
            UI::Text("cpInfo.taRank: "                 + tostring(cpInfo.taRank));
            UI::Text("cpInfo.raceRank: "               + tostring(cpInfo.raceRank));
            UI::Text("cpInfo.KoState: "                + (cpInfo.KoState !is null ? "valid" : "null"));
            UI::Text("cpInfo.UpdateNonce: "            + tostring(cpInfo.UpdateNonce));
            UI::Text("cpInfo.RequestsSpectate: "       + tostring(cpInfo.RequestsSpectate));
            UI::Text("cpInfo.RaceProgression: "        + tostring(cpInfo.RaceProgression));
            str = "";
            foreach (int time : cpInfo.RaceProgressionHistory) str += time + " ";
            UI::Text("cpInfo.RaceProgressionHistory: " + str);
            UI::Text("cpInfo.SpawnCount: "             + tostring(cpInfo.SpawnCount));
        }

        UI::Separator();

        if (pbGhost is null)
            UI::Text("\\$F00pbGhost null");
        else {
            string times;
            foreach (uint time : pbGhost.Checkpoints) times += tostring(time) + " ";
            UI::Text("pbGhost.Checkpoints: "    + times);
            UI::Text("pbGhost.IdName: "         + tostring(pbGhost.IdName));
            UI::Text("pbGhost.IdUint: "         + tostring(pbGhost.IdUint));
            UI::Text("pbGhost.IsLoaded: "       + tostring(pbGhost.IsLoaded));
            UI::Text("pbGhost.IsLocalPlayer: "  + tostring(pbGhost.IsLocalPlayer));
            UI::Text("pbGhost.IsPersonalBest: " + tostring(pbGhost.IsPersonalBest));
            UI::Text("pbGhost.Nickname: "       + tostring(pbGhost.Nickname));
            UI::Text("pbGhost.Result_Score: "   + tostring(pbGhost.Result_Score));
            UI::Text("pbGhost.Result_Time: "    + tostring(pbGhost.Result_Time));
        }
    }
    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Reset() {
    highestGhostIdSeen = -1;
    lastNbGhosts = 0;
    @pbGhost = null;
    seenGhosts.DeleteAll();
}
