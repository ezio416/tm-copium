uint[]        bestCpTimes;
Json::Value@  bestEver        = Json::Object();
const string  bestEverFile    = IO::FromStorageFolder("best.json");
uint          bestSessionTime = 0;
int           cpCount         = 0;
int           diff            = 0;
string        diffText;
uint          lastTime        = 0;
int           medal           = 0;
const string  pluginColor     = "\\$FA0";
const string  pluginIcon      = Icons::Flag;
Meta::Plugin@ pluginMeta      = Meta::ExecutingPlugin();
const string  pluginTitle     = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;
uint          respawns        = 0;
TimesSource   source          = TimesSource::None;
string        text;
const string  versionFile     = IO::FromStorageFolder("version.txt");

void OnDestroyed() {
#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    UltimateMedalsExtended::RemoveMedal("Best Copium");
    UltimateMedalsExtended::RemoveMedal("Previous Copium");
    UltimateMedalsExtended::RemoveMedal("Session Copium");
#endif
}

void Main() {
    ChangeFont();

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED
    trace("registering UME medals");
    UltimateMedalsExtended::AddMedal(UME_Best());
    UltimateMedalsExtended::AddMedal(UME_Previous());
    UltimateMedalsExtended::AddMedal(UME_Session());
#endif

    if (IO::FileExists(bestEverFile)) {
        try {
            @bestEver = Json::FromFile(bestEverFile);
        } catch {
            error("error reading best.json! " + getExceptionInfo());
        }
    } else {
        trace("best.json not found, try respawning!");
    }

    bool old = true;
    string version;

    if (IO::FileExists(versionFile)) {
        IO::File file(versionFile, IO::FileMode::Read);
        version = file.ReadToEnd();
        file.Close();
        if (version == pluginMeta.Version) {
            old = false;
        }
    }

    if (old) {
        warn("plugin was updated" + (version.Length > 0 ? ", was v" + version : ""));

        if (version < "1.5.0") {
            warn("resetting font choice");
            S_Font = Font::DroidSans_Bold;
        }

        try {
            IO::File file(versionFile, IO::FileMode::Write);
            file.Write(pluginMeta.Version);
            file.Close();
        } catch {
            error("error writing version file: " + getExceptionInfo());
        }
    }

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData;
    const MLFeed::SharedGhostDataHook_V2@ ghostData;
    uint[] _bestTimes;

    auto App = cast<CTrackMania>(GetApp());

    while (true) {
        yield();

        if (!S_Enabled) {
            Reset();
            continue;
        }

        auto Playground = cast<CSmArenaClient>(App.CurrentPlayground);

        if (false
            or App.RootMap is null
            or Playground is null
            or Playground.UIConfigs.Length == 0
            or Playground.UIConfigs[0] is null
        ) {
            Reset();
            bestSessionTime = 0;
            lastTime = 0;
            continue;
        }

        if (false
            or Playground.UIConfigs[0].UISequence != CGamePlaygroundUIConfig::EUISequence::Playing
            or (@raceData = MLFeed::GetRaceData_V4()) is null
            or raceData.LocalPlayer is null
        ) {
            continue;
        }

        respawns = raceData.LocalPlayer.NbRespawnsRequested;
        _bestTimes = raceData.LocalPlayer.BestRaceTimes;
        if (true
            and _bestTimes.Length > 0
            and _bestTimes[0] == 0
        ) {
            _bestTimes.RemoveAt(0);
        }

        if (ShouldUpdateBestTimes(_bestTimes)) {
            bestCpTimes = _bestTimes;
            source = TimesSource::RaceData;
        }

        if (false
            or (@ghostData = MLFeed::GetGhostData()) is null
            or ghostData.Ghosts_V2.Length == 0
        ) {
            continue;
        }

        const MLFeed::GhostInfo_V2@ ghost, pbGhost;
        uint64 now = Time::Now;
        for (uint i = 0; i < ghostData.Ghosts_V2.Length; i++) {
            if (true
                and (@ghost = ghostData.Ghosts_V2[i]) !is null
                and (false
                    or ghost.IsLocalPlayer
                    or ghost.IsPersonalBest
                )
                and (false
                    or pbGhost is null
                    or ghost.Result_Time < pbGhost.Result_Time
                )
                and ghost.Checkpoints.Length == raceData.CPsToFinish
            ) {
                @pbGhost = ghost;
            }

            // hotfix for 2026-01-26_15_06 (thanks fort)
            if (now < Time::Now) {
                now = Time::Now;
                yield();
            }
        }

        if (true
            and pbGhost !is null
            and (false
                or bestCpTimes.Length < 2
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

    if (!S_Enabled) {
        return;
    }

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData;
    if (false
        or (@raceData = MLFeed::GetRaceData_V4()) is null
        or raceData.LocalPlayer is null
    ) {
        return;
    }

    auto App = cast<CTrackMania>(GetApp());
    auto Playground = cast<CSmArenaClient>(App.CurrentPlayground);

    if (false
        or App.RootMap is null
        or Playground is null
        or Playground.GameTerminals.Length == 0
        or Playground.GameTerminals[0] is null
        or Playground.UIConfigs.Length == 0
        or Playground.UIConfigs[0] is null
    ) {
        return;
    }

    if (true
        and Playground.GameTerminals[0].GUIPlayer !is null
        and Playground.GameTerminals[0].GUIPlayer !is Playground.GameTerminals[0].ControlledPlayer
    ) {
        return;  // spectating
    }

    if (respawns == 0) {
        if (S_Persist) {
            if (true
                and raceData.LocalPlayer.CurrentRaceTime < 0
                and text.Length > 0
                and !raceData.WarmupActive
            ) {
                RenderTimer();
            } else {
                ResetSaved();
            }
        }

        return;
    }

    switch (Playground.UIConfigs[0].UISequence) {
        case CGamePlaygroundUIConfig::EUISequence::EndRound:
        case CGamePlaygroundUIConfig::EUISequence::Finish:
        case CGamePlaygroundUIConfig::EUISequence::Playing:
            break;
        default:
            return;
    }

    const bool finished = raceData.LocalPlayer.cpCount == int(raceData.CPsToFinish);
    const uint theoreticalTime = finished
        ? raceData.LocalPlayer.LastTheoreticalCpTime
        : Math::Max(0, raceData.LocalPlayer.TheoreticalRaceTime)
    ;
    const uint raceTime = finished
        ? raceData.LocalPlayer.lastCpTime
        : raceData.LocalPlayer.CurrentRaceTime
    ;
    if (int(theoreticalTime) <= 0 || int(theoreticalTime) > int(raceTime) - 500) {
        return;
    }

    if (finished) {
        bestSessionTime = bestSessionTime == 0
            ? theoreticalTime
            : Math::Min(bestSessionTime, theoreticalTime)
        ;

        lastTime = theoreticalTime;
        SetBestEver(App.RootMap.EdChallengeId, theoreticalTime);
    }

    if (false
        or (S_HideWithGame and !UI::IsGameUIVisible())
        or (S_HideWithOP and !UI::IsOverlayShown())
    ) {
        return;
    }

    cpCount = raceData.LocalPlayer.cpCount;

    text = Time::Format(theoreticalTime);
    if (!S_Thousandths) {
        text = text.SubStr(0, text.Length - 1);
    }

    if (true
        and S_Respawns
        and finished
        and respawns > 0
    ) {
        text += " (" + respawns + " respawn" + (respawns == 1 ? "" : "s") + ")";
    }

    if (true
        and S_Delta
        and raceData.LocalPlayer.cpTimes.Length > 1
        and bestCpTimes.Length > raceData.LocalPlayer.cpTimes.Length - 2  // check this...
    ) {
        diff = raceData.LocalPlayer.lastCpTime
            - bestCpTimes[raceData.LocalPlayer.cpTimes.Length - 2]        // ...so this works
            - SumAllButLast(raceData.LocalPlayer.TimeLostToRespawnByCp)
        ;
        diffText = TimeFormat(diff);
        if (!S_Thousandths) {
            diffText = diffText.SubStr(0, diffText.Length - 1);
        }
        text += (S_Font == Font::DroidSans_Mono ? " " : "  ") + diffText;
    }

    if (finished) {
#if DEPENDENCY_CHAMPIONMEDALS
        const uint cm = ChampionMedals::GetCMTime();
#endif
#if DEPENDENCY_WARRIORMEDALS
        const uint wm = WarriorMedals::GetWMTime();
#endif

#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        uint medal5 = 0, medal6 = 0;

        if (cm == 0) {
            medal5 = wm;
        } else if (wm == 0) {
            medal5 = cm;
        } else if (cm <= wm) {
            medal5 = wm;
            medal6 = cm;
        } else {
            medal5 = cm;
            medal6 = wm;
        }
#endif

        if (false) {  // here so preprocessors work
#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        } else if (theoreticalTime <= medal6) {
            medal = 6;
        } else if (theoreticalTime <= medal5) {
            medal = 5;
#elif DEPENDENCY_CHAMPIONMEDALS
        } else if (theoreticalTime <= cm) {
            medal = 5;
#elif DEPENDENCY_WARRIORMEDALS
        } else if (theoreticalTime <= wm) {
            medal = 5;
#endif
        } else if (theoreticalTime <= App.RootMap.TMObjective_AuthorTime) {
            medal = 4;
        } else if (theoreticalTime <= App.RootMap.TMObjective_GoldTime) {
            medal = 3;
        } else if (theoreticalTime <= App.RootMap.TMObjective_SilverTime) {
            medal = 2;
        } else if (theoreticalTime <= App.RootMap.TMObjective_BronzeTime) {
            medal = 1;
        } else {
            medal = 0;
        }
    }

    RenderTimer();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void RenderTimer() {
    nvg::FontSize(S_FontSize);
    nvg::FontFace(font);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    const vec2 size = nvg::TextBounds(text);  // todo: change this for variable width fonts
    const float diffWidth = nvg::TextBounds(diffText).x;

    const float posX = Display::GetWidth() * S_X;
    const float posY = Display::GetHeight() * S_Y;
    const float radius = S_FontSize * 0.4f;

    const float halfSizeX = size.x * 0.5f;
    const float halfSizeY = size.y * 0.5f;

    if (S_Background == BackgroundOption::BehindEverything) {
        nvg::FillColor(S_BackgroundColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX - halfSizeX - S_BackgroundXPad - (S_Medals and medal > 0 ? S_FontSize + radius : 0.0f),
            posY - halfSizeY - S_BackgroundYPad - 2.0f,
            size.x + S_BackgroundXPad * 2.0f + (S_Medals and medal > 0 ? (S_FontSize + radius) * 2.0f : 0.0f),
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    if (true
        and S_Delta
        and S_Background > 0
        and bestCpTimes.Length > 0
        and cpCount > 0
        and cpCount <= int(bestCpTimes.Length)
        and diffText.Length > 0
    ) {
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

    if (true
        and S_Medals
        and medal > 0
    ) {
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
