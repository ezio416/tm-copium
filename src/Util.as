string FormatDiff(int64 time) {
    string str = "+";

    if (time < 0) {
        str = "-";
        time *= -1;
    }

    double tm = time / 1000.0;

    int hundredth = int((tm % 1.0) * 100.0);
    int seconds = int(tm % 60.0);
    int minutes = int(tm / 60.0) % 60;
    int hours = int(tm / 3600.0);

    if (hours > 0)
        str += hours + ":";
    str += PadNumber(minutes) + ":";
    str += PadNumber(seconds) + ".";
    str += PadNumber(hundredth);

    return str;
}

string FormatTime(uint64 time) {
    string str = "";
    double tm = time / 1000.0;

    int hundredth = int((tm % 1.0) * 100);
    int seconds = int(tm % 60.0);
    int minutes = int(tm / 60.0) % 60;
    int hours = int(tm / 3600.0);

    if (hours > 0)
        str += hours + ":";
    str += PadNumber(minutes) + ":";
    str += PadNumber(seconds) + ".";
    str += PadNumber(hundredth);

    return str;
}

int64 GetRaceTime(CSmScriptPlayer@ ScriptPlayer) {
    if (ScriptPlayer is null)
        // not playing
        return 0;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CSmArenaRulesMode@ PlaygroundScript = cast<CSmArenaRulesMode@>(App.PlaygroundScript);

    if (PlaygroundScript is null)  // Online
        return Network.PlaygroundClientScriptAPI.GameTime - ScriptPlayer.StartTime;
    else  // Solo
        return PlaygroundScript.Now - ScriptPlayer.StartTime;
}

string PadNumber(int number) {
    if (number < 10)
        return "0" + number;
    else
        return "" + number;
}