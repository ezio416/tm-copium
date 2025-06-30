// c 2024-03-05
// m 2025-06-30

enum TimesSource {
    RaceData,
    PbGhost,
    None
}

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
}

bool ShouldUpdateBestTimes(const uint[] &in new) {
    if (new.Length == 0 or new.Length < bestCpTimes.Length) {
        return false;
    }

    if (bestCpTimes.Length == 0 or bestCpTimes.Length < new.Length) {
        return true;
    }

    // both must now be non-empty and of equal length
    return new[new.Length - 1] < bestCpTimes[bestCpTimes.Length - 1];
}

int SumAllButLast(const int[] &in times) {
    int total = 0;

    for (uint i = 0; i < times.Length - 1; i++) {
        total += times[i];
    }

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
