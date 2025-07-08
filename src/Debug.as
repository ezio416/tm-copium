// c 2025-04-09
// m 2025-07-07

void RenderDebug() {
    if (false
        or !S_Debug
        or GetApp().RootMap is null
    ) {
        return;
    }

    const string uid = GetApp().RootMap.EdChallengeId;

    if (UI::Begin(pluginTitle + "\\$888 (debug)", S_Debug, UI::WindowFlags::None)) {
        const uint best = GetBestEver(uid);
        UI::AlignTextToFramePadding();
        UI::Text("best ever time: " + Time::Format(best));
        if (best > 0) {
            UI::SameLine();
            if (UI::Button(Icons::TrashO)) {
                DeleteBestEver(uid);
            }
            if (UI::IsItemHovered()) {
                UI::BeginTooltip();
                UI::Text("\\$DD0" + Icons::ExclamationTriangle + " Are you sure? " + Icons::ExclamationTriangle);
                UI::EndTooltip();
            }
        }

        UI::Text("bestSessionTime: " + Time::Format(bestSessionTime));
        UI::Text("cpCount: " + cpCount);
        UI::Text("diff: " + diff);
        UI::Text("lastTime: " + Time::Format(lastTime));
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
