// c 2025-04-09
// m 2025-06-30

void RenderDebug() {
    if (false
        or !S_Debug
        or GetApp().RootMap is null
    ) {
        return;
    }

    if (UI::Begin(pluginTitle + "\\$888 (debug)", S_Debug, UI::WindowFlags::None)) {
        UI::Text("cpCount: " + cpCount);
        UI::Text("diff: " + diff);
        UI::Text("diffText: " + diffText);
        UI::Text("medal: " + medal);
        UI::Text("respawns: " + respawns);
        UI::Text("text: " + text);
        UI::Separator();

        UI::Text("bestCpTimes (" + tostring(source) + ")");
        for (uint i = 0; i < bestCpTimes.Length; i++) {
            UI::Text("    " + Time::Format(bestCpTimes[i]));
        }
    }
    UI::End();
}
