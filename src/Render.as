// Background Options
enum BackgroundOption {
    None,
    OnlyBehindDelta,
    BehindEverything
}

void RenderBackground(const vec2 size, const float posX, const float posY, const float halfSizeX, const float halfSizeY, const float radius)
{
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
}

void RenderDelta(const vec2 size, const float posX, const float posY, const float halfSizeX, const float halfSizeY, const float diffWidth)
{
    if (true
        and S_Delta
        and S_Background > 0
        and bestCpTimes.Length > 0
        and cpCount > 0
        and cpCount <= int(bestCpTimes.Length)
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
}

void RenderText(const float posX, const float posY)
{
    // Render drop shadow if configured
    if (S_Drop) {
        nvg::FillColor(S_DropColor);
        nvg::Text(posX + S_DropOffset, posY + S_DropOffset, text);
    }

    // Render the main text (prepared earlier)
    nvg::FillColor(S_FontColor);
    nvg::Text(posX, posY, text);
}

void RenderMedals(const float posX, const float posY, const float halfSizeX, const float radius)
{
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

void RenderTextAndMedals()
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

    const float halfSizeX = size.x * 0.5f;
    const float halfSizeY = size.y * 0.5f;

    RenderBackground(size, posX, posY, halfSizeX, halfSizeY, radius);

    RenderDelta(size, posX, posY, halfSizeX, halfSizeY, diffWidth);

    RenderText(posX, posY);

    RenderMedals(posX, posY, halfSizeX, radius);
}