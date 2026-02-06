enum TimesSource {
    RaceData,
    PbGhost,
    None
}

void DeleteBestEver(const string&in uid) {
    if (bestEver.HasKey(uid)) {
        bestEver.Remove(uid);
        Json::ToFile(bestEverFile, bestEver, true);
    }
}

uint GetBestEver(const string&in uid) {
    if (false
        or uid.Length == 0
        or !bestEver.HasKey(uid)
        or bestEver[uid].GetType() != Json::Type::Number
    ) {
        return 0;
    }

    return uint(bestEver[uid]);
}

uint GetPB() {
    auto App = cast<CTrackMania>(GetApp());

    if (false
        or App.RootMap is null
        or App.MenuManager is null
        or App.MenuManager.MenuCustom_CurrentManiaApp is null
        or App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr is null
        or App.UserManagerScript is null
        or App.UserManagerScript.Users.Length == 0
        or App.UserManagerScript.Users[0] is null
    ) {
        return uint(-1);
    }

    return App.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.Map_GetRecord_v2(
        App.UserManagerScript.Users[0].Id,
        App.RootMap.EdChallengeId,
        "PersonalBest",
        "",
        "TimeAttack",
        ""
    );
}

vec4 GetMedalColor(const int medal) {
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

    tm_showEnd = 0;
    tm_prevRespawns = 0;
    tm_prevLostTotal = 0;
    tm_prevFinished = false;

    ResetSaved();
}

void ResetSaved() {
    cpCount  = 0;
    diff     = 0;
    diffText = "";
    medal    = 0;
    text     = "";
}

void SetBestEver(const string&in uid, const uint time) {
    const uint best = GetBestEver(uid);
    if (true
        and uid.Length > 0
        and time > 0
        and (false
            or best == 0
            or time < best
        )
    ) {
        trace("new best time: " + Time::Format(time));
        bestEver[uid] = time;
        Json::ToFile(bestEverFile, bestEver, true);
    }
}

bool ShouldUpdateBestTimes(const uint[]& new) {
    if (new.Length == 0 or new.Length < bestCpTimes.Length) {
        return false;
    }

    if (bestCpTimes.Length == 0 or bestCpTimes.Length < new.Length) {
        return true;
    }

    // both must now be non-empty and of equal length
    return new[new.Length - 1] < bestCpTimes[bestCpTimes.Length - 1];
}

int SumAllButLast(const int[]& times) {
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
