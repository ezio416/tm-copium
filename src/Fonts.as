nvg::Font font;
Font currentFont = S_Font;

enum Font {
    DroidSans,
    DroidSans_Bold,
    DroidSans_Mono,
    _Droid_End,
    Montserrat_Bold,
    Montserrat_BoldItalic,
    Montserrat_Medium,
    Montserrat_MediumItalic,
    Montserrat_SemiBold,
    Montserrat_SemiBoldItalic,
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
        case Font::DroidSans:                   f = nvg::LoadFont("DroidSans.ttf");                                             break;
        case Font::DroidSans_Bold:              f = nvg::LoadFont("DroidSans-Bold.ttf");                                        break;
        case Font::DroidSans_Mono:              f = nvg::LoadFont("DroidSansMono.ttf");                                         break;

        case Font::Montserrat_Bold:             f = nvg::LoadFont("assets/fonts/Montserrat/MontserratMono-Bold.ttf");           break;
        case Font::Montserrat_BoldItalic:       f = nvg::LoadFont("assets/fonts/Montserrat/MontserratMono-BoldItalic.ttf");     break;
        case Font::Montserrat_Medium:           f = nvg::LoadFont("assets/fonts/Montserrat/MontserratMono-Medium.ttf");         break;
        case Font::Montserrat_MediumItalic:     f = nvg::LoadFont("assets/fonts/Montserrat/MontserratMono-MediumItalic.ttf");   break;
        case Font::Montserrat_SemiBold:         f = nvg::LoadFont("assets/fonts/Montserrat/MontserratMono-SemiBold.ttf");       break;
        case Font::Montserrat_SemiBoldItalic:   f = nvg::LoadFont("assets/fonts/Montserrat/MontserratMono-SemiBoldItalic.ttf"); break;

        case Font::Oswald_Bold:                 f = nvg::LoadFont("assets/fonts/Oswald/OswaldMono-Bold.ttf");                   break;
        case Font::Oswald_ExtraLight:           f = nvg::LoadFont("assets/fonts/Oswald/OswaldMono-ExtraLight.ttf");             break;
        case Font::Oswald_Light:                f = nvg::LoadFont("assets/fonts/Oswald/OswaldMono-Light.ttf");                  break;
        case Font::Oswald_Medium:               f = nvg::LoadFont("assets/fonts/Oswald/OswaldMono-Medium.ttf");                 break;
        case Font::Oswald_Regular:              f = nvg::LoadFont("assets/fonts/Oswald/OswaldMono-Regular.ttf");                break;
        case Font::Oswald_SemiBold:             f = nvg::LoadFont("assets/fonts/Oswald/OswaldMono-SemiBold.ttf");               break;

        case Font::Custom:                      f = nvg::LoadFont(S_CustomFont);                                                break;
    }

    if (f > -1) {
        font = f;
    }

    currentFont = S_Font;
}
