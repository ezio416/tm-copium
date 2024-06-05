// c 2024-03-05
// m 2024-04-10

uint[]       bestCpTimes;
string       localLogin;
string       localName;
const vec4   rowBgAltColor = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const string title         = "\\$FA0" + Icons::Flag + "\\$G Better Copium Timer";

const MLFeed::HookRaceStatsEventsBase_V4@ raceData;
const MLFeed::PlayerCpInfo_V4@            cpInfo;

void Main() {
    startnew(CacheLocalLogin);
    startnew(CacheLocalName);

    ChangeFont();
    OnSettingsChanged();

    while (true) {
        yield();

        @raceData = null;
        @cpInfo   = null;

        if (!S_Enabled)
            continue;

        @raceData = MLFeed::GetRaceData_V4();
        if (raceData is null)
            continue;

        @cpInfo = raceData.GetPlayer_V4(localName);
        if (cpInfo is null)
            continue;

        if (!cpInfo.IsLocalPlayer)
            @cpInfo = null;
    }
}

void OnSettingsChanged() {
    if (currentFont != S_Font)
        ChangeFont();

    negColorUi = Text::FormatOpenplanetColor(vec3(S_NegativeColor.x, S_NegativeColor.y, S_NegativeColor.z));
    neuColorUi = Text::FormatOpenplanetColor(vec3(S_NeutralColor.x,  S_NeutralColor.y,  S_NeutralColor.z));
    posColorUi = Text::FormatOpenplanetColor(vec3(S_PositiveColor.x, S_PositiveColor.y, S_PositiveColor.z));
}

void Render() {
    RenderDebug();

    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);

    if (
        App.RootMap is null
        || Playground is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
        || Playground.UIConfigs.Length == 0
        || Playground.UIConfigs[0] is null
        || raceData is null
        || cpInfo is null
    )
        return;

    if (Playground.GameTerminals[0].GUIPlayer is null)
        return;

    CSmPlayer@ ViewingPlayer = VehicleState::GetViewingPlayer();
    if (ViewingPlayer is null || ViewingPlayer.ScriptAPI.Login != localLogin)
        return;

    const CGamePlaygroundUIConfig::EUISequence Sequence = Playground.UIConfigs[0].UISequence;
    if (
        Sequence != CGamePlaygroundUIConfig::EUISequence::EndRound
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Finish
        && Sequence != CGamePlaygroundUIConfig::EUISequence::Playing
    )
        return;

    const int    mapCpCount            = raceData.CPsToFinish;
    const int    cpCount               = cpInfo.cpCount;
    const int[]  cpTimes               = cpInfo.cpTimes;
    const int    lastCpTime            = cpInfo.lastCpTime;
    const int    LastTheoreticalCpTime = cpInfo.LastTheoreticalCpTime;
    const uint   NbRespawnsRequested   = cpInfo.NbRespawnsRequested;
    const int    TheoreticalRaceTime   = cpInfo.TheoreticalRaceTime;
    const int[]@ TimeLostToRespawnByCp = cpInfo.TimeLostToRespawnByCp;

    if (NbRespawnsRequested == 0)
        return;

    const bool finished = cpCount == mapCpCount;
    const uint theoreticalTime = finished ? LastTheoreticalCpTime : Math::Max(0, TheoreticalRaceTime);

    string text = Time::Format(theoreticalTime);

    if (finished && NbRespawnsRequested > 0 && S_Respawns)
        text += " (" + NbRespawnsRequested + " respawn" + (NbRespawnsRequested == 1 ? "" : "s") + ")";

    int diff = 0;
    string diffText;

    if (bestCpTimes.Length > 0 && cpTimes.Length > 0) {
        diff = lastCpTime - bestCpTimes[cpTimes.Length - 1] - SumAllButLast(TimeLostToRespawnByCp);
        diffText = TimeFormat(diff);
        text += (S_Font == Font::DroidSansMono ? " " : "  ") + diffText;
    }

    nvg::FontSize(S_FontSize);
    nvg::FontFace(font);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    const vec2 size = nvg::TextBounds(text);
    const float diffWidth = nvg::TextBounds(diffText).x;

    const float posX = Draw::GetWidth() * S_X;
    const float posY = Draw::GetHeight() * S_Y;
    const float radius = S_FontSize * 0.4f;

    int medal = 0;

    if (finished) {
        if (theoreticalTime <= App.RootMap.TMObjective_AuthorTime)
            medal = 4;
        else if (theoreticalTime <= App.RootMap.TMObjective_GoldTime)
            medal = 3;
        else if (theoreticalTime <= App.RootMap.TMObjective_SilverTime)
            medal = 2;
        else if (theoreticalTime <= App.RootMap.TMObjective_BronzeTime)
            medal = 1;
    }

    if (S_Background == BackgroundOption::BehindEverything) {
        nvg::FillColor(S_BackgroundColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX - size.x * 0.5f - S_BackgroundXPad - (S_Medals && medal > 0 ? S_FontSize + radius : 0.0f),
            posY - size.y * 0.5f - S_BackgroundYPad - 2.0f,
            size.x + S_BackgroundXPad * 2.0f + (S_Medals && medal > 0 ? (S_FontSize + radius) * 2.0f : 0.0f),
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    if (bestCpTimes.Length > 0 && S_Background > 0) {
        const float diffBgOffset = S_FontSize * 0.125f;

        nvg::FillColor(diff > 0 ? S_PositiveColor : diff == 0 ? S_NeutralColor : S_NegativeColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX + size.x * 0.5f - diffWidth - diffBgOffset,
            posY - size.y * 0.5f - S_BackgroundYPad - 2.0f,
            diffWidth + diffBgOffset + S_BackgroundXPad,
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    if (S_Drop) {
        nvg::FillColor(S_DropColor);
        nvg::Text(posX + S_DropOffset, posY + S_DropOffset, text);
    }

    nvg::FillColor(S_FontColor);
    nvg::Text(posX, posY, text);

    if (S_Medals && medal > 0) {
        const float halfSizeX = size.x * 0.5f;
        const float y = posY + 1.0f - S_FontSize * 0.1f;

        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::BeginPath();
            nvg::Circle(vec2(posX - halfSizeX - S_FontSize + S_DropOffset, y + S_DropOffset), radius);
            nvg::Fill();
            nvg::BeginPath();
            nvg::Circle(vec2(posX + halfSizeX + S_FontSize + S_DropOffset, y + S_DropOffset), radius);
            nvg::Fill();
        }

        nvg::BeginPath();
        nvg::FillColor(GetMedalColor(medal));
        nvg::Circle(vec2(posX - halfSizeX - S_FontSize, y), radius);
        nvg::Fill();
        nvg::BeginPath();
        nvg::Circle(vec2(posX + halfSizeX + S_FontSize, y), radius);
        nvg::Fill();
    }
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}
