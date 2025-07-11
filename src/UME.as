// c 2025-07-06
// m 2025-07-10

#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

UltimateMedalsExtended::Config@ configBest = UltimateMedalsExtended::Config();

class UME_Best : UltimateMedalsExtended::IMedal {
    string uid;

    UltimateMedalsExtended::Config GetConfig() override {
        configBest.defaultName = "Best Copium";
        configBest.icon = "\\$777" + Icons::ArrowCircleUp;
        configBest.shareIcon = false;
        configBest.usePreviousColor = true;

        return configBest;
    }

    uint GetMedalTime() override {
        return GetBestEver(uid);
    }

    bool HasMedalTime(const string&in uid) override {
        return GetBestEver(uid) > 0;
    }

    void UpdateMedal(const string&in uid) override {
        this.uid = uid;
    }
}

class UME_Previous : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config config;

        config.defaultName = "Previous Copium";
        config.icon = "\\$777" + Icons::ArrowCircleLeft;
        config.shareIcon = false;
        config.usePreviousColor = true;

        return config;
    }

    uint GetMedalTime() override {
        return lastTime;
    }

    bool HasMedalTime(const string&in uid) override {
        return lastTime > bestSessionTime;
    }

    void UpdateMedal(const string&in uid) override { }
}

class UME_Session : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config config;

        config.defaultName = "Session Copium";
        config.icon = "\\$777" + Icons::ArrowCircleDown;
        config.shareIcon = false;
        config.usePreviousColor = true;

        return config;
    }

    uint GetMedalTime() override {
        return bestSessionTime;
    }

    bool HasMedalTime(const string&in uid) override {
        return bestSessionTime > GetBestEver(uid);
    }

    void UpdateMedal(const string&in uid) override { }
}

#endif
