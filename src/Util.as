// c 2024-03-05
// m 2025-05-01

// Indicated the source of the times
enum TimesSource {
    RaceData,
    PbGhost,
    None
}

string GetText(const bool finished, const uint theoreticalTime, const MLFeed::PlayerCpInfo_V4@ localPlayer)
{
    // Format the theoretical time to a string
    string text = Time::Format(theoreticalTime);

    // Remove the inaccurate thousandth if configured
    if (!S_Thousandths)
        text = text.SubStr(0, text.Length - 1);

    // Render number of respawns of finish if configured
    if (true
        and S_Respawns
        and finished
        and respawns > 0
    )
        text += " (" + respawns + " respawn" + (respawns == 1 ? "" : "s") + ")";

    // Calculate difference and update text
    if (true
        and S_Delta                                               // if delta should be displayed
        and localPlayer.cpTimes.Length > 1                        // if at least 1 CP has been reached
        and bestCpTimes.Length >= localPlayer.cpTimes.Length - 1  // the bestCPTimes is at least as long as the local player cp times
    ) {
                // last CP time
        diff = localPlayer.lastCpTime
                // minus the best CP time of the same CP (correct for index 0 and length) (e.g. time diff at last CP)
            - bestCpTimes[localPlayer.cpTimes.Length - 2]
                // minus all the time diffs at the CPs before the last CP
            - SumAllButLast(localPlayer.TimeLostToRespawnByCp)
        ;
        diffText = TimeFormat(diff);
        if (!S_Thousandths)
            diffText = diffText.SubStr(0, diffText.Length - 1);
        text += (S_Font == Font::DroidSans_Mono ? " " : "  ") + diffText;
    }

    return text;
}

int GetMedal(const bool finished, const uint theoreticalTime)
{
    auto App = cast<CTrackMania>(GetApp());

    if (!finished)
        return 0;

#if DEPENDENCY_CHAMPIONMEDALS
    const uint cm = ChampionMedals::GetCMTime();
#endif
#if DEPENDENCY_WARRIORMEDALS
    const uint wm = WarriorMedals::GetWMTime();
#endif

#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
    uint medal5 = 0, medal6 = 0;

    // Set correct medal time order. This only order time
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
    // Determine the achieved medal based on time order
#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
    if (theoreticalTime <= medal6)
        return 6;
    if (theoreticalTime <= medal5)
        return 5;
#elif DEPENDENCY_CHAMPIONMEDALS
    if (theoreticalTime <= cm)
        return 5;
#elif DEPENDENCY_WARRIORMEDALS
    if (theoreticalTime <= wm)
        return 5;
#endif
    if (theoreticalTime <= App.RootMap.TMObjective_AuthorTime)
        return 4;
    if (theoreticalTime <= App.RootMap.TMObjective_GoldTime)
        return 3;
    if (theoreticalTime <= App.RootMap.TMObjective_SilverTime)
        return 2;
    if (theoreticalTime <= App.RootMap.TMObjective_BronzeTime)
        return 1;
    return 0;
}

// Return the color for the achieved medal index
vec4 GetMedalColor(int medal) {
#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
    const bool cmFaster = ChampionMedals::GetCMTime() <= WarriorMedals::GetWMTime();
#endif

    switch (medal) {
#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        case 6:
            return cmFaster
                ? S_ChampionColor
                : vec4(WarriorMedals::GetColorVec(), 1.0f)
            ;
        case 5:
            return cmFaster
                ? vec4(WarriorMedals::GetColorVec(), 1.0f)
                : S_ChampionColor
            ;
#elif DEPENDENCY_CHAMPIONMEDALS
        case 5: return S_ChampionColor;
#elif DEPENDENCY_WARRIORMEDALS
        case 5: return vec4(WarriorMedals::GetColorVec(), 1.0f);
#endif
        case 4:  return S_AuthorColor;
        case 3:  return S_GoldColor;
        case 2:  return S_SilverColor;
        case 1:  return S_BronzeColor;
        default: return vec4();
    }
}

void Reset() {
    bestCpTimes = {};
    respawns    = 0;
    source      = TimesSource::None;
    ResetSavedCopium();
}

void ResetSavedCopium() {
    text        = "";
    diff        = 0;
    diffText    = "";
    medal       = 0;
}

// Returns if the stored best CP times should be updated based on the new times
bool ShouldUpdateBestTimes(const uint[] &in new) {
    if (new.Length == 0 or new.Length < bestCpTimes.Length)
        return false;

    if (bestCpTimes.Length == 0 or bestCpTimes.Length < new.Length)
        return true;

    // both must now be non-empty and of equal length
    return new[new.Length - 1] < bestCpTimes[bestCpTimes.Length - 1];
}

int SumAllButLast(const int[] &in times) {
    int total = 0;

    for (uint i = 0; i < times.Length - 1; i++)
        total += times[i];

    return total;
}

string TimeFormat(int64 time) {
    string str = "+";

    if (time < 0) {
        str = "-";
        time *= -1;
    }

    return str + Time::Format(time);
}