// c 2025-07-06
// m 2025-07-06

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

class UME_Last : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config@ config;

    UME_Last() {
        @config = UltimateMedalsExtended::Config();
        config.defaultName = "Last Copium";
        config.icon = "\\$777" + Icons::Repeat;
        config.shareIcon = false;
        config.usePreviousColor = true;
    }

    UltimateMedalsExtended::Config GetConfig() override {
        return config;
    }

    uint GetMedalTime() override {
        return lastTime;
    }

    bool HasMedalTime(const string&in uid) override {
        return lastTime > 0;
    }

    void UpdateMedal(const string&in uid) override { }
}

class UME_Session : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config@ config;

    UME_Session() {
        @config = UltimateMedalsExtended::Config();
        config.defaultName = "Session Copium";
        config.icon = "\\$777" + Icons::Backward;
        config.shareIcon = false;
        config.usePreviousColor = true;
    }

    UltimateMedalsExtended::Config GetConfig() override {
        return config;
    }

    uint GetMedalTime() override {
        return bestSessionTime;
    }

    bool HasMedalTime(const string&in uid) override {
        return bestSessionTime > 0;
    }

    void UpdateMedal(const string&in uid) override { }
}

#endif
