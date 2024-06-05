// c 2024-03-07
// m 2024-04-08

void RenderDebug() {
    if (!S_Debug)
        return;

    if (UI::Begin(title + " (Debug)", S_Debug, UI::WindowFlags::AlwaysAutoResize)) {
        UI::BeginTabBar("##tabs");
            Tab_RaceData();
            Tab_CpInfo();
        UI::EndTabBar();

        // UI::Text("cpCount: " + cpCount);
        // UI::Text("lastCpTime: " + Time::Format(lastCpTime));
        // UI::Text("mapCpCount: " + mapCpCount);

//         const MLFeed::HookRaceStatsEventsBase_V4@ raceData = MLFeed::GetRaceData_V4();
//         if (raceData is null) {
//             UI::End();
//             return;
//         }

//         const MLFeed::PlayerCpInfo_V4@ cpInfo = raceData.GetPlayer_V4(localName);
//         if (cpInfo is null || !cpInfo.IsLocalPlayer) {
//             UI::End();
//             return;
//         }

//         mapCpCount  = raceData.CPsToFinish;
//         bestCpTimes = cpInfo.BestRaceTimes;
//         cpTimes     = cpInfo.cpTimes;
//         cpTimes.RemoveAt(0);

//         if (UI::BeginTable("##cp-table", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
//             UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

//             UI::TableSetupScrollFreeze(0, 1);
//             UI::TableSetupColumn("CP");
//             UI::TableSetupColumn("pb time");
//             UI::TableSetupColumn("cur time");
//             UI::TableSetupColumn("delta");
//             UI::TableHeadersRow();

//             if (mapCpCount < 0)
//                 mapCpCount = 0;

//             for (uint i = 0; i < uint(mapCpCount); i++) {
//                 UI::TableNextRow();

//                 UI::TableNextColumn();
//                 UI::Text(tostring(i + 1));

//                 UI::TableNextColumn();
//                 UI::Text(i < bestCpTimes.Length ? Time::Format(bestCpTimes[i]) : "");

//                 UI::TableNextColumn();
//                 UI::Text(i < cpTimes.Length ? Time::Format(cpTimes[i]) : "");

//                 UI::TableNextColumn();
//                 if (i < bestCpTimes.Length && i < cpTimes.Length) {
//                     int delta = cpTimes[i] - bestCpTimes[i];
//                     UI::Text((delta < 0 ? negColorUi : delta == 0 ? neuColorUi : posColorUi) + TimeFormat(delta));
//                 } else
//                     UI::Text("");
//             }

//             UI::PopStyleColor();
//             UI::EndTable();
//         }
    }

    UI::End();
}

void Tab_RaceData() {
    if (!UI::BeginTabItem("raceData"))
        return;

    if (raceData !is null) {
        if (UI::BeginTable("##table-racedata", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("mapCpCount");
            UI::TableHeadersRow();

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(tostring(raceData.CPsToFinish));

            UI::PopStyleColor();
            UI::EndTable();
        }
    } else
        UI::Text("\\$F60raceData null");

    UI::EndTabItem();
}

void Tab_CpInfo() {
    if (!UI::BeginTabItem("cpInfo"))
        return;

    if (cpInfo !is null) {
        if (UI::BeginTable("##table-cpinfo", 4, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("cpCount");
            UI::TableHeadersRow();

            UI::TableNextRow();
            UI::TableNextColumn();
            UI::Text(tostring(cpInfo.BestRaceTimes));

            UI::PopStyleColor();
            UI::EndTable();
        }
    } else
        UI::Text("\\$F60cpInfo null");

    UI::EndTabItem();
}
