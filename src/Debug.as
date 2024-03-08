// c 2024-03-07
// m 2024-03-07

enum CpTimeSource {
    None,
    PbGhost,
    CpInfo
}

void RenderDebug() {
    if (!S_Debug)
        return;

    UI::Begin(title + " (Debug)", S_Debug, UI::WindowFlags::None);
        UI::Text("source: " + tostring(source));

        UI::Separator();

        for (uint i = 0; i < bestCpTimes.Length; i++)
            UI::Text("CP " + (i + 1) + ": " + bestCpTimes[i]);
    UI::End();
}