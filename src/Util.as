// c 2024-03-05
// m 2024-04-01

vec4 GetMedalColor(const int medal) {
    switch (medal) {
        case 4:  return S_AuthorColor;
        case 3:  return S_GoldColor;
        case 2:  return S_SilverColor;
        case 1:  return S_BronzeColor;
        default: return vec4();
    }
}

bool InMap() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    return App.Editor is null
        && App.RootMap !is null
        && App.CurrentPlayground !is null
        && App.Network.ClientManiaAppPlayground !is null;
}

int SumAllButLast(const int[] times) {
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