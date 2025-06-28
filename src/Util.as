// c 2024-03-05
// m 2025-05-01

// Indicated the source of the times
enum TimesSource {
    RaceData,
    PbGhost,
    None
}

// Return the color for the achieved medal index
vec4 GetMedalColor(int medal) {
#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
    const bool cmFaster = ChampionMedals::GetCMTime() <= WarriorMedals::GetWMTime();
#endif

    switch (medal) {
#if DEPENDENCY_CHAMPIONMEDALS && DEPENDENCY_WARRIORMEDALS
        case 6:
            return cmFaster
                ? S_ChampionColor
                : vec4(WarriorMedals::GetColorVec(), 1.0f)
            ;
        case 5:
            return cmFaster
                ? vec4(WarriorMedals::GetColorVec(), 1.0f)
                : S_ChampionColor
            ;
#elif DEPENDENCY_CHAMPIONMEDALS
        case 5: return S_ChampionColor;
#elif DEPENDENCY_WARRIORMEDALS
        case 5: return vec4(WarriorMedals::GetColorVec(), 1.0f);
#endif
        case 4:  return S_AuthorColor;
        case 3:  return S_GoldColor;
        case 2:  return S_SilverColor;
        case 1:  return S_BronzeColor;
        default: return vec4();
    }
}

void Reset() {
    bestCpTimes = {};
    respawns    = 0;
    source      = TimesSource::None;
    ResetSavedCopium();
}

void ResetSavedCopium() {
    text        = "";
    diff        = 0;
    diffText    = "";
    medal       = 0;
}

// Returns if the stored best CP times should be updated based on the new times
bool ShouldUpdateBestTimes(const uint[] &in new) {
    if (new.Length == 0 or new.Length < bestCpTimes.Length)
        return false;

    if (bestCpTimes.Length == 0 or bestCpTimes.Length < new.Length)
        return true;

    // both must now be non-empty and of equal length
    return new[new.Length - 1] < bestCpTimes[bestCpTimes.Length - 1];
}

int SumAllButLast(const int[] &in times) {
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

// void RenderTextAndMedal(string text, int diff, string diffText, int medal, int cpCount)
void RenderTextAndMedal()
{
    // Configure font and text position
    nvg::FontSize(S_FontSize);
    nvg::FontFace(font);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);

    const vec2 size = nvg::TextBounds(text);  // TODO: change this for variable width fonts
    const float diffWidth = nvg::TextBounds(diffText).x;

    const float posX = Draw::GetWidth() * S_X;
    const float posY = Draw::GetHeight() * S_Y;
    const float radius = S_FontSize * 0.4f;

    // Render medal
    const float halfSizeX = size.x * 0.5f;
    const float halfSizeY = size.y * 0.5f;

    // Render background if configured
    if (S_Background == BackgroundOption::BehindEverything) {
        nvg::FillColor(S_BackgroundColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX - halfSizeX - S_BackgroundXPad - (S_Medals and medal > 0 ? S_FontSize + radius : 0.0f),
            posY - halfSizeY - S_BackgroundYPad - 2.0f,
            size.x + S_BackgroundXPad * 2.0f + (S_Medals and medal > 0 ? (S_FontSize + radius) * 2.0f : 0.0f),
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

    // Render delta background if configured and delta available
    if (true
        and S_Delta
        and S_Background > 0
        and bestCpTimes.Length > 0
        // and raceData.LocalPlayer.cpCount > 0                        // jvdz: not sure if this is needed?
        // and raceData.LocalPlayer.cpCount <= int(bestCpTimes.Length) // jvdz: not sure if this is needed?
    ) {
        const float diffBgOffset = S_FontSize * 0.125f;

        nvg::FillColor(diff > 0 ? S_PositiveColor : diff == 0 ? S_NeutralColor : S_NegativeColor);
        nvg::BeginPath();
        nvg::RoundedRect(
            posX + halfSizeX - diffWidth - diffBgOffset,
            posY - halfSizeY - S_BackgroundYPad - 2.0f,
            diffWidth + diffBgOffset + S_BackgroundXPad,
            size.y + S_BackgroundYPad * 2.0f,
            S_BackgroundRadius
        );
        nvg::Fill();
    }

        // Render drop shadow if configured
    if (S_Drop) {
        nvg::FillColor(S_DropColor);
        nvg::Text(posX + S_DropOffset, posY + S_DropOffset, text);
    }

    // Render the main text (prepared earlier)
    nvg::FillColor(S_FontColor);
    nvg::Text(posX, posY, text);

    // Render medal if configured and obtained
    if (S_Medals and medal > 0) {
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