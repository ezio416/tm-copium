nvg::Font font;
Font currentFont = S_Font;

enum Font {
    DroidSans,
    DroidSans_Bold,
    DroidSans_Mono,
    _Droid_End,
    Montserrat_Black,
    Montserrat_BlackItalic,
    Montserrat_Bold,
    Montserrat_BoldItalic,
    Montserrat_ExtraBold,
    Montserrat_ExtraBoldItalic,
    Montserrat_ExtraLight,
    Montserrat_ExtraLightItalic,
    Montserrat_Italic,
    Montserrat_Light,
    Montserrat_LightItalic,
    Montserrat_Medium,
    Montserrat_MediumItalic,
    Montserrat_Regular,
    Montserrat_SemiBold,
    Montserrat_SemiBoldItalic,
    Montserrat_Thin,
    Montserrat_ThinItalic,
    _Montserrat_End,
    Oswald_Bold,
    Oswald_ExtraLight,
    Oswald_Light,
    Oswald_Medium,
    Oswald_Regular,
    Oswald_SemiBold,
    _Oswald_End,
    Custom
}

void ChangeFont() {
    int f = -1;

    switch (S_Font) {
        case Font::DroidSans:                   f = nvg::LoadFont("DroidSans.ttf");                                           break;
        case Font::DroidSans_Bold:              f = nvg::LoadFont("DroidSans-Bold.ttf");                                      break;
        case Font::DroidSans_Mono:              f = nvg::LoadFont("DroidSansMono.ttf");                                       break;

        case Font::Montserrat_Black:            f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-Black.ttf");            break;
        case Font::Montserrat_BlackItalic:      f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-BlackItalic.ttf");      break;
        case Font::Montserrat_Bold:             f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-Bold.ttf");             break;
        case Font::Montserrat_BoldItalic:       f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-BoldItalic.ttf");       break;
        case Font::Montserrat_ExtraBold:        f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-ExtraBold.ttf");        break;
        case Font::Montserrat_ExtraBoldItalic:  f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-ExtraBoldItalic.ttf");  break;
        case Font::Montserrat_ExtraLight:       f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-ExtraLight.ttf");       break;
        case Font::Montserrat_ExtraLightItalic: f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-ExtraLightItalic.ttf"); break;
        case Font::Montserrat_Italic:           f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-Italic.ttf");           break;
        case Font::Montserrat_Light:            f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-Light.ttf");            break;
        case Font::Montserrat_LightItalic:      f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-LightItalic.ttf");      break;
        case Font::Montserrat_Medium:           f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-Medium.ttf");           break;
        case Font::Montserrat_MediumItalic:     f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-MediumItalic.ttf");     break;
        case Font::Montserrat_Regular:          f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-Regular.ttf");          break;
        case Font::Montserrat_SemiBold:         f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-SemiBold.ttf");         break;
        case Font::Montserrat_SemiBoldItalic:   f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-SemiBoldItalic.ttf");   break;
        case Font::Montserrat_Thin:             f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-Thin.ttf");             break;
        case Font::Montserrat_ThinItalic:       f = nvg::LoadFont("assets/fonts/Montserrat/Montserrat-ThinItalic.ttf");       break;

        case Font::Oswald_Bold:                 f = nvg::LoadFont("assets/fonts/Oswald/Oswald-Bold.ttf");                     break;
        case Font::Oswald_ExtraLight:           f = nvg::LoadFont("assets/fonts/Oswald/Oswald-ExtraLight.ttf");               break;
        case Font::Oswald_Light:                f = nvg::LoadFont("assets/fonts/Oswald/Oswald-Light.ttf");                    break;
        case Font::Oswald_Medium:               f = nvg::LoadFont("assets/fonts/Oswald/Oswald-Medium.ttf");                   break;
        case Font::Oswald_Regular:              f = nvg::LoadFont("assets/fonts/Oswald/Oswald-Regular.ttf");                  break;
        case Font::Oswald_SemiBold:             f = nvg::LoadFont("assets/fonts/Oswald/Oswald-SemiBold.ttf");                 break;

        case Font::Custom:                      f = nvg::LoadFont(S_CustomFont);                                              break;
    }

    if (f > -1) {
        font = f;
    }

    currentFont = S_Font;
}
