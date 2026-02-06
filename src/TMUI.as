void TMUI_Init() {
    ChangeFont();
    LoadTMUIAssets();
}

nvg::Texture@ copiumIcon;
bool          tmUIDragging    = false;
vec2          tmUIDragOffset;

void LoadTMUIAssets() {
    @copiumIcon = nvg::LoadTexture("assets/icons/copium.png");
}

void RenderTimerTMStyle() {
    float h = float(Display::GetHeight());
    float w = float(Display::GetWidth());
    if (true
        and h == 0
        or w == 0) {
        return;
    }
    // if configured to only show on reset, enforce visibility window (use tm_showEnd)
    if (S_TM_ShowOnRespawn) {
        if (tm_showEnd == 0) return;
        if (Time::Now > tm_showEnd) return;
    }

    float scaleX, scaleY, offsetX = 0;
    if (w / h > 16.0f / 9.0f) {
        float correctedW = (h / 9.0f) * 16.0f;
        scaleX = correctedW / 2560.0f;
        scaleY = h / 1440.0f;
        offsetX = (w - correctedW) / 2.0f;
    } else {
        scaleX = w / 2560.0f;
        scaleY = h / 1440.0f;
    }

    nvg::Save();
    nvg::Translate(offsetX, 0);
    nvg::Scale(scaleX, scaleY);

    float fontSize = float(S_TM_FontSize);
    float boxHeight = S_Scale * 57.0f;
    float iconSize = boxHeight;
    float padding = S_Scale * 14.0f;
    float boxGap = 0.0f;
    float textOffsetY = 3.0f;

    nvg::FontFace(tmuiFont);
    nvg::FontSize(fontSize);

    string timeText = Time::Format(theoreticalTime);
    if (!S_TM_Thousandths) {
        timeText = timeText.SubStr(0, timeText.Length - 1);
    }
    float timeBoxWidth = S_Scale * 180.0f ;

    bool showDelta = S_Delta and diffText.Length > 0;
    float diffBoxWidth = S_Scale * 180.0f;

    bool showRespawns = S_TM_Respawns ? (finished && respawns > 0) : (respawns > 0);

    float medalRadius = S_Scale * 12.0f;
    bool showMedal = S_TM_Medals and medal > 0;
    float totalWidth = iconSize + timeBoxWidth + (showDelta ? boxGap + diffBoxWidth : 0.0f) + (showMedal ? medalRadius * 2.0f + 8.0f : 0.0f);

    float centerX = S_TMX * 2560.0f;
    float startX = centerX - totalWidth / 2.0f;
    float y = S_TMY * 1440.0f - boxHeight / 2.0f;

    if (S_TMUIDragMode) {
        vec2 mousePos = vec2(UI::GetMousePos().x - offsetX, UI::GetMousePos().y) / vec2(scaleX, scaleY);
        vec2 rectPos = vec2(startX, y);
        vec2 rectSize = vec2(totalWidth, boxHeight);

        bool hovering = mousePos.x >= rectPos.x && mousePos.x <= rectPos.x + rectSize.x
                     && mousePos.y >= rectPos.y && mousePos.y <= rectPos.y + rectSize.y;

        if (true
            and UI::IsMouseDown()
            and (hovering or tmUIDragging)) {
            if (!tmUIDragging) {
                tmUIDragging = true;
                tmUIDragOffset = mousePos - vec2(centerX, y + boxHeight / 2.0f);
            }
            vec2 newCenter = mousePos - tmUIDragOffset;
            S_TMX = Math::Clamp(newCenter.x / 2560.0f, 0.0f, 1.0f);
            S_TMY = Math::Clamp((newCenter.y) / 1440.0f, 0.0f, 1.0f);

            centerX = S_TMX * 2560.0f;
            startX = centerX - totalWidth / 2.0f;
            y = S_TMY * 1440.0f - boxHeight / 2.0f;
        } else {
            tmUIDragging = false;
        }

        nvg::BeginPath();
        nvg::Rect(startX - 2, y - 2, totalWidth + 4, boxHeight + 4);
        nvg::StrokeColor(vec4(1.0f, 1.0f, 0.0f, 0.8f));
        nvg::StrokeWidth(2.0f);
        nvg::Stroke();
        nvg::ClosePath();
    }

    float currentX = startX;

    nvg::BeginPath();
    nvg::Rect(currentX, y, iconSize, boxHeight);
    nvg::FillColor(S_TM_BackgroundColor);
    nvg::Fill();
    nvg::ClosePath();

    if (copiumIcon !is null) {
        nvg::BeginPath();
        nvg::Rect(currentX, y, iconSize, iconSize);
        nvg::FillPaint(nvg::TexturePattern(vec2(currentX, y), vec2(iconSize, iconSize), 0, copiumIcon, 1.0f));
        nvg::Fill();
        nvg::ClosePath();
    }
    currentX += iconSize;

    nvg::BeginPath();
    nvg::Rect(currentX, y, timeBoxWidth, boxHeight);
    nvg::FillColor(S_TM_BackgroundColor);
    nvg::Fill();
    nvg::ClosePath();

    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
    if (S_Drop) {
        nvg::FillColor(S_DropColor);
        nvg::Text(currentX + timeBoxWidth / 2.0f + S_DropOffset, y + boxHeight / 2.0f + textOffsetY + S_DropOffset, timeText);
    }
    nvg::FillColor(S_TM_FontColor);
    nvg::Text(currentX + timeBoxWidth / 2.0f, y + boxHeight / 2.0f + textOffsetY, timeText);
    currentX += timeBoxWidth + boxGap;

    if (showDelta) {
        vec4 deltaColor = diff > 0 ? S_TM_PositiveColor : (diff < 0 ? S_TM_NegativeColor : S_TM_NeutralColor);

        nvg::BeginPath();
        nvg::Rect(currentX, y, diffBoxWidth, boxHeight);
        nvg::FillColor(deltaColor);
        nvg::Fill();
        nvg::ClosePath();

        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::Text(currentX + diffBoxWidth / 2.0f + S_DropOffset, y + boxHeight / 2.0f + textOffsetY + S_DropOffset, diffText);
        }

        nvg::FillColor(S_TM_FontColor);
        nvg::Text(currentX + diffBoxWidth / 2.0f, y + boxHeight / 2.0f + textOffsetY, diffText);
        currentX += diffBoxWidth;
    }

    if (showRespawns) {
        float respawnRowHeight = S_Scale * 35.0f;
        float respawnY = y + boxHeight;
        int respawnValue = respawns;

        string respawnText = "Respawns: " + respawnValue;

        float timeBoxStartX = startX + iconSize;
        float respawnBoxWidth = timeBoxWidth;
        float respawnX = timeBoxStartX;

        nvg::BeginPath();
        nvg::Rect(respawnX, respawnY, respawnBoxWidth, respawnRowHeight);
        nvg::FillColor(S_TM_BackgroundColor);
        nvg::Fill();
        nvg::ClosePath();

        nvg::FontSize(fontSize * 0.7f);
        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::Text(respawnX + respawnBoxWidth / 2.0f + S_DropOffset, respawnY + respawnRowHeight / 2.0f + 2.0f + S_DropOffset, respawnText);
        }
        nvg::FillColor(S_TM_FontColor);
        nvg::Text(respawnX + respawnBoxWidth / 2.0f, respawnY + respawnRowHeight / 2.0f + 2.0f, respawnText);
    }

    if (showMedal) {
        float medalX = currentX + medalRadius + 8.0f;
        float medalY = y + boxHeight / 2.0f;

        if (S_Drop) {
            nvg::FillColor(S_DropColor);
            nvg::BeginPath();
            nvg::Circle(vec2(medalX + S_DropOffset, medalY + S_DropOffset), medalRadius);
            nvg::Fill();
        }

        nvg::BeginPath();
        nvg::FillColor(GetMedalColor(medal));
        nvg::Circle(vec2(medalX, medalY), medalRadius);
        nvg::Fill();
    }

    nvg::Restore();
}
