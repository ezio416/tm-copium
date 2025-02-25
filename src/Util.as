// c 2024-03-05
// m 2025-02-25

// courtesy of "Auto-hide Opponents" plugin - https://github.com/XertroV/tm-autohide-opponents
void CacheLocalLogin() {
    while (true) {
        sleep(100);

        loginLocal = GetLocalLogin();

        if (loginLocal.Length > 10)
            break;
    }
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
                : vec4(WarriorMedals::GetColorVec(), 1.0f);
        case 5:
            return cmFaster
                ? vec4(WarriorMedals::GetColorVec(), 1.0f)
                : S_ChampionColor;
#elif DEPENDENCY_CHAMPIONMEDALS && !DEPENDENCY_WARRIORMEDALS
        case 5: return S_ChampionColor;
#elif !DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        case 5: return vec4(WarriorMedals::GetColorVec(), 1.0f);
#endif
        case 4:  return S_AuthorColor;
        case 3:  return S_GoldColor;
        case 2:  return S_SilverColor;
        case 1:  return S_BronzeColor;
        default: return vec4();
    }
}

// courtesy of "Buffer Time" plugin - https://github.com/XertroV/tm-cotd-buffer-time
string SeenGhostSaveMap(const MLFeed::GhostInfo_V2@ ghost) {
    const string key = ghost.Nickname + (ghost.Checkpoints.Length << 12 ^ ghost.Result_Time);

    if (!ghostFirstSeenMap.Exists(key))
        ghostFirstSeenMap[key] = GetApp().RootMap.EdChallengeId;

    return key;
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
