// c 2024-03-05
// m 2024-04-02

uint[]       bestCpTimes;
int          cpCount;
int[]        cpTimes;
int          lastCpTime;
bool         lastTaskSuccess = false;
MwId         localId;
string       localLogin;
string       localName;
int          mapCpCount      = 0;
const vec4   rowBgAltColor   = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const string title           = "\\$FA0" + Icons::Flag + "\\$G Better Copium Timer";

void OnDestroyed() { ResetIntercept(); }
void OnDisabled()  { ResetIntercept(); }

void Main() {
    startnew(CacheLocalId);
    startnew(CacheLocalLogin);
    startnew(CacheLocalName);

    ChangeFont();
    OnSettingsChanged();

    bool inMap;
    bool wasInMap = InMap();

    if (wasInMap)
        OnEnteredMap();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    while (true) {
        yield();

        inMap = InMap();

        if (!inMap) {
            wasInMap = false;
            Reset();
            continue;
        }

        if (!wasInMap) {
            wasInMap = true;
            OnEnteredMap();
        }

        CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

        if (
            CMAP.UI is null
            || CMAP.UI.UISequence != CGamePlaygroundUIConfig::EUISequence::Finish
        )
            continue;

        const uint yieldFrames = App.PlaygroundScript is null ? 50 : 20;
        for (uint i = 0; i < yieldFrames; i++)
            yield();  // allow game to process PB

        SetBestCpTimes();

        try {
            while (
                CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::Finish
                || CMAP.UI.UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
            )
                yield();
        } catch { }
    }
}

void OnSettingsChanged() {
    if (currentFont != S_Font)
        ChangeFont();

    negColorUi = Text::FormatOpenplanetColor(vec3(S_NegativeColor.x, S_NegativeColor.y, S_NegativeColor.z));
    neuColorUi = Text::FormatOpenplanetColor(vec3(S_NeutralColor.x,  S_NeutralColor.y,  S_NeutralColor.z));
    posColorUi = Text::FormatOpenplanetColor(vec3(S_PositiveColor.x, S_PositiveColor.y, S_PositiveColor.z));
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);

    if (
        App.RootMap is null
        || Playground is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
        || Playground.UIConfigs.Length == 0
        || Playground.UIConfigs[0] is null
    ) {
        Reset();
        return;
    }

    RenderDebug();

    if (Playground.GameTerminals[0].GUIPlayer is null)
        return;

    CSmPlayer@ ViewingPlayer = VehicleState::GetViewingPlayer();
    if (ViewingPlayer is null || ViewingPlayer.ScriptAPI.Login != localLogin)
        return;

    const CGamePlaygroundUIConfig::EUISequence Sequence = Playground.UIConfigs[0].UISequence;
    if (
        Sequence != CGamePlaygroundUIConfig::EUISequence::EndRound
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Finish
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Playing
    )
        return;

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
    if (raceData is null)
        return;

    const MLFeed::PlayerCpInfo_V4@ cpInfo = raceData.GetPlayer_V4(localName);
    if (cpInfo is null || !cpInfo.IsLocalPlayer)
        return;

    //##########################################################################

    // const int    mapCpCount            = raceData.CPsToFinish;
    // const int    cpCount               = cpInfo.cpCount;
    // const int[]  cpTimes               = cpInfo.cpTimes;
    // cpTimes                            = cpInfo.cpTimes;
    // const int    lastCpTime            = cpInfo.lastCpTime;
    const int    LastTheoreticalCpTime = cpInfo.LastTheoreticalCpTime;
    // const uint   NbRespawnsRequested   = cpInfo.NbRespawnsRequested;
    const int    TheoreticalRaceTime   = cpInfo.TheoreticalRaceTime;
    const int[]@ TimeLostToRespawnByCp = cpInfo.TimeLostToRespawnByCp;

    CSmScriptPlayer@ ScriptPlayer = cast<CSmScriptPlayer@>(ViewingPlayer.ScriptAPI);
    if (ScriptPlayer is null || ScriptPlayer.Score is null)
        return;
    const uint NbRespawnsRequested = ScriptPlayer.Score.NbRespawnsRequested;

    if (Network.PlaygroundClientScriptAPI.GameTime - ScriptPlayer.StartTime < 0) {
        cpCount = 0;
        cpTimes.RemoveRange(0, cpTimes.Length);
        lastCpTime = 0;
        return;
    }

    //##########################################################################

    if (!S_Debug && NbRespawnsRequested == 0)
        return;

    const bool finished = cpCount == mapCpCount;
    const uint theoreticalTime = finished ? LastTheoreticalCpTime : Math::Max(0, TheoreticalRaceTime);

    if (NbRespawnsRequested == 0)
        return;

    string text = Time::Format(theoreticalTime);

    if (finished && NbRespawnsRequested > 0 && S_Respawns)
        text += " (" + NbRespawnsRequested + " respawn" + (NbRespawnsRequested == 1 ? "" : "s") + ")";

    int diff = 0;
    string diffText;

    if (bestCpTimes.Length > 0 && cpTimes.Length > 0) {
        diff = lastCpTime - bestCpTimes[cpTimes.Length - 1] - SumAllButLast(TimeLostToRespawnByCp);
        diffText = TimeFormat(diff);
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
        if (theoreticalTime <= App.RootMap.TMObjective_AuthorTime)
            medal = 4;
        else if (theoreticalTime <= App.RootMap.TMObjective_GoldTime)
            medal = 3;
        else if (theoreticalTime <= App.RootMap.TMObjective_SilverTime)
            medal = 2;
        else if (theoreticalTime <= App.RootMap.TMObjective_BronzeTime)
            medal = 1;
    }

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

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void OnEnteredMap() {
    print("OnEnteredMap");

    Intercept();
    SetMapCpCount();
    SetBestCpTimes();
}

void SetBestCpTimes() {
    print("SetBestCpTimes");

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

    lastTaskSuccess = false;

    if (
        App.RootMap is null
        || CMAP is null
        || CMAP.ScoreMgr is null
    )
        return;

    const uint64 start = Time::Now;
    const uint64 maxTime = 2000;

    while (localId.Value == 0) {
        yield();

        if (Time::Now - start > maxTime) {
            warn("SetBestCpTimes: waited too long for localId to be valid (" + maxTime + " ms)");
            return;
        }
    }

    CWebServicesTaskResult_GhostScript@ task = CMAP.ScoreMgr.Map_GetRecordGhost_v2(
        localId,
        App.RootMap.EdChallengeId,
        "PersonalBest",
        "",
        "TimeAttack",
        ""
    );

    while (task.IsProcessing) {
        yield();

        if (CMAP is null || CMAP.ScoreMgr is null || task is null) {
            warn("SetBestCpTimes: something is null, getting PB ghost failed");
            return;
        }
    }

    if (task.HasFailed || !task.HasSucceeded) {
        warn("SetBestCpTimes: task failed");
        CMAP.ScoreMgr.TaskResult_Release(task.Id);
        return;
    }

    CGameGhostScript@ ghost = task.Ghost;
    if (ghost is null) {
        trace("SetBestCpTimes: task ghost is null - player likely has no PB on the map");
        CMAP.ScoreMgr.TaskResult_Release(task.Id);
        return;
    }

    CTmRaceResultNod@ result = ghost.Result;
    if (result is null) {
        warn("SetBestCpTimes: task ghost result is null");
        CMAP.ScoreMgr.TaskResult_Release(task.Id);

        if (CMAP.DataFileMgr !is null)
            CMAP.DataFileMgr.Ghost_Release(ghost.Id);

        return;
    }

    bestCpTimes = {};
    lastTaskSuccess = true;

    if (result.Checkpoints.Length == 0) {
        warn("task ghost result has no checkpoints");

        if (CMAP.DataFileMgr !is null)
            CMAP.DataFileMgr.Ghost_Release(ghost.Id);

        CMAP.ScoreMgr.TaskResult_Release(task.Id);
        return;
    }

    for (uint i = 0; i < result.Checkpoints.Length; i++)
        bestCpTimes.InsertLast(result.Checkpoints[i]);

    if (CMAP.DataFileMgr !is null)
        CMAP.DataFileMgr.Ghost_Release(ghost.Id);

    CMAP.ScoreMgr.TaskResult_Release(task.Id);
}

void SetMapCpCount() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);

    if (
        App.RootMap is null
        || App.RootMap.TMObjective_AuthorTime == uint(-1)
        || Playground is null
        || Playground.Arena is null
        || Playground.Arena.MapLandmarks.Length == 0
    ) {
        Reset();
        return;
    }

    mapCpCount = 1;
    dictionary@ linked = dictionary();

    for (uint i = 0; i < Playground.Arena.MapLandmarks.Length; i++) {
        CGameScriptMapLandmark@ Landmark = Playground.Arena.MapLandmarks[i];
        if (
            Landmark is null
            || Landmark.Waypoint is null
            || Landmark.Waypoint.IsFinish
            || Landmark.Waypoint.IsMultiLap
        )
            continue;

        if (Landmark.Tag == "LinkedCheckpoint")
            linked.Set(tostring(Landmark.Order), true);
        else
            mapCpCount++;
    }

    mapCpCount += linked.GetSize();

    if (App.RootMap.TMObjective_IsLapRace)
        mapCpCount *= App.RootMap.TMObjective_NbLaps;
}

void Reset() {
    bestCpTimes = {};
    cpCount     = 0;
    cpTimes     = {};
    lastCpTime  = 0;
    mapCpCount  = -1;
    ResetIntercept();
}
