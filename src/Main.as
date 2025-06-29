// c 2024-03-05
// m 2025-05-06

uint[]        bestCpTimes;
const string  pluginColor = "\\$FA0";
const string  pluginIcon  = Icons::Flag;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
uint          respawns    = 0;
const float   scale       = UI::GetScale();
TimesSource   source      = TimesSource::None;
string        text        = "";
int           diff        = 0;
string        diffText    = "";
int           medal       = 0;
int           cpCount     = 0;

void Main() {
    ChangeFont();

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData;
    const MLFeed::SharedGhostDataHook_V2@ ghostData;
    uint[] _bestTimes;

    auto App = cast<CTrackMania>(GetApp());

    // Continues loop to update bestCpTimes to the best availabe time (Current session or PB Ghost)
    while (true) {
        yield();

        auto Playground = cast<CSmArenaClient>(App.CurrentPlayground);

        // Reset and Don't show if not playing
        if (false
            or App.RootMap is null
            or Playground is null
            or Playground.UIConfigs.Length == 0
            or Playground.UIConfigs[0] is null
        ) {
            Reset();
            continue;
        }

        // Don't show if not playing, or there is no raceData
        if (false
            or Playground.UIConfigs[0].UISequence != CGamePlaygroundUIConfig::EUISequence::Playing
            or (@raceData = MLFeed::GetRaceData_V4()) is null
            or raceData.LocalPlayer is null
        )
            continue;

        // Number of the times the player respawned
        respawns = raceData.LocalPlayer.NbRespawnsRequested;
        // CP times for player's best performance this session
        _bestTimes = raceData.LocalPlayer.BestRaceTimes;

        // Remove the first element if 0
        if (_bestTimes.Length > 0 and _bestTimes[0] == 0)
            _bestTimes.RemoveAt(0);

        // Update stored best CP times if needed.
        if (ShouldUpdateBestTimes(_bestTimes)) {
            bestCpTimes = _bestTimes;
            source = TimesSource::RaceData;
        }

        // If there is no (PB) Ghost, there is nothing to compare the current run to
        if (false
            or (@ghostData = MLFeed::GetGhostData()) is null
            or ghostData.Ghosts_V2.Length == 0
        )
            continue;

        // Find the PB Ghost
        const MLFeed::GhostInfo_V2@ ghost, pbGhost;
        for (uint i = 0; i < ghostData.Ghosts_V2.Length; i++) {
            if (true
                and (@ghost = ghostData.Ghosts_V2[i]) !is null
                and (ghost.IsLocalPlayer or ghost.IsPersonalBest)
                and (pbGhost is null or ghost.Result_Time < pbGhost.Result_Time)
                and ghost.Checkpoints.Length == raceData.CPsToFinish
            )
                @pbGhost = ghost;
        }

        // If the PB Ghost is found and is faster than the currect run, update bestCpTimes
        if (true
            and pbGhost !is null
            and (false
                or bestCpTimes.Length < 2 // bestCPTimes only has 1st CP
                or uint(pbGhost.Result_Time) < bestCpTimes[bestCpTimes.Length - 1]
            )
        ) {
            bestCpTimes = pbGhost.Checkpoints;
            source = TimesSource::PbGhost;
        }
    }
}

void Render() {
    RenderDebug();

    // Don't render is Show Timer is diabled, or if it should be hidden with the UI or OP
    if (
        !S_Enabled
        or (S_HideWithGame and !UI::IsGameUIVisible())
        or (S_HideWithOP and !UI::IsOverlayShown())
    )
        return;

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData;

    // Don't show if there is no data for the player
    if (false
        or (@raceData = MLFeed::GetRaceData_V4()) is null
        or raceData.LocalPlayer is null
    )
        return;

    // Don't render if there have not been any respwans
    if (respawns == 0)
    {
        // Keep rendering the previous result
        if (S_ShowCopiumAfterReset)
            if(S_ShowCopiumAfterResetTime - raceData.LocalPlayer.CurrentRaceTime - 1500 > 0) // 1500ms spawn time
                RenderTextAndMedals();
            else
                ResetSavedCopium();
        return;
    }

    auto App = cast<CTrackMania>(GetApp());
    auto Playground = cast<CSmArenaClient>(App.CurrentPlayground);

    // Don't show if not playing
    if (false
        or App.RootMap is null
        or Playground is null
        or Playground.GameTerminals.Length == 0
        or Playground.GameTerminals[0] is null
        or Playground.UIConfigs.Length == 0
        or Playground.UIConfigs[0] is null
    )
        return;

    // Don't show if the player is not playing or finished a run
    switch (Playground.UIConfigs[0].UISequence) {
        case CGamePlaygroundUIConfig::EUISequence::EndRound:
        case CGamePlaygroundUIConfig::EUISequence::Finish:
        case CGamePlaygroundUIConfig::EUISequence::Playing:
            break;
        default:
            return;
    }

    // Player finished a run
    const bool finished = raceData.LocalPlayer.IsFinished;
    // Theoretical time to the last CP or fin
    const uint theoreticalTime = finished
        ? raceData.LocalPlayer.LastTheoreticalCpTime
        : Math::Max(0, raceData.LocalPlayer.TheoreticalRaceTime)
    ;

    // Don't show if, somehow, the player is doing time travelling
    if (int(theoreticalTime) <= 0)
        return;

    cpCount = raceData.LocalPlayer.cpCount;
    text = GetText(finished, theoreticalTime, raceData.LocalPlayer);
    medal = GetMedal(finished, theoreticalTime);
    RenderTextAndMedals();
}

void RenderMenu() {
    // Render a menu item
    if (UI::MenuItem(pluginTitle, "", S_Enabled))
        S_Enabled = !S_Enabled;
}
