// c 2024-03-07
// m 2024-03-09

void RenderDebug() {
    if (!S_Debug)
        return;

    UI::Begin(title + " (Debug)", S_Debug, UI::WindowFlags::None);
        if (UI::BeginTable("##cp-table", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("CP");
            UI::TableSetupColumn("time");
            UI::TableHeadersRow();

            for (uint i = 0; i < bestCpTimes.Length; i++) {
                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(tostring(i + 1));

                UI::TableNextColumn();
                UI::Text(Time::Format(bestCpTimes[i]));
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

    UI::End();

    UI::Begin(title + " (Debug 2)", S_Debug, UI::WindowFlags::None);
        UI::Text("cpCount: " + cpCount);
        UI::Text("lastCpTime: " + Time::Format(lastCpTime));
        UI::Text("mapCpCount: " + mapCpCount);

        if (UI::BeginTable("##cp2-table", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("CP");
            UI::TableSetupColumn("time");
            UI::TableHeadersRow();

            for (uint i = 0; i < cpTimes.Length; i++) {
                UI::TableNextRow();

                UI::TableNextColumn();
                UI::Text(tostring(i + 1));

                UI::TableNextColumn();
                UI::Text(Time::Format(cpTimes[i]));
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

    UI::End();
}