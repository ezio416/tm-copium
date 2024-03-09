// c 2024-03-05
// m 2024-03-08

// courtesy of "Auto-hide Opponents" plugin - https://github.com/XertroV/tm-autohide-opponents
void CacheLocalLogin() {
    while (true) {
        sleep(100);

        loginLocal = GetLocalLogin();

        if (loginLocal.Length > 10)
            break;
    }
}

void CacheUserId() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        sleep(100);

        if (
            App.UserManagerScript !is null
            && App.UserManagerScript.Users.Length > 0
            && App.UserManagerScript.Users[0] !is null
        ) {
            userId = App.UserManagerScript.Users[0].Id;
            break;
        }
    }
}

vec4 GetMedalColor(const int medal) {
    switch (medal) {
        case 4: return S_AuthorColor;
        case 3: return S_GoldColor;
        case 2: return S_SilverColor;
        case 1: return S_BronzeColor;
        default: return vec4(0.0f, 0.0f, 0.0f, 0.0f);
    }
}

int SumAllButLast(const int[] times) {
    int total = 0;

    for (uint i = 0; i < times.Length; i++) {
        if (i == times.Length - 1)
            break;

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