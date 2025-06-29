// c 2025-04-09
// m 2025-04-12

void RenderDebug() {
    if (!S_Debug or GetApp().RootMap is null)
        return;

    const MLFeed::HookRaceStatsEventsBase_V4@ raceData;

    @raceData = MLFeed::GetRaceData_V4();

    if (UI::Begin(pluginTitle + "\\$888 (debug)", S_Debug, UI::WindowFlags::None)) {
        UI::Text("respawns: " + respawns);
        UI::Separator();
        UI::Text("text: " + text);
        UI::Separator();
        UI::Text("diff: " + diff);
        UI::Separator();
        UI::Text("diffText: " + diffText);
        UI::Separator();
        UI::Text("medal: " + medal);
        UI::Separator();

        UI::Text("bestCpTimes (" + tostring(source) + ")");
        for (uint i = 0; i < bestCpTimes.Length; i++)
            UI::Text("    " + Time::Format(bestCpTimes[i]));

        UI::Text("localPlayer.cpTimes (" + tostring(source) + ")");
        for (uint i = 0; i < raceData.LocalPlayer.cpTimes.Length; i++)
            UI::Text(i + ":    " + Time::Format(raceData.LocalPlayer.cpTimes[i]));
    }
    UI::End();
}
