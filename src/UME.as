#if DEPENDENCY_ULTIMATEMEDALSEXTENDED

class UME_Best : UltimateMedalsExtended::IMedal {
    string uid;

    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;

        c.defaultName = "Best Copium";
        c.icon = "\\$777" + Icons::ArrowCircleUp;
        c.shareIcon = false;
        c.usePreviousColor = true;

        return c;
    }

    uint GetMedalTime() override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return 0;
        }

        return GetBestEver(uid);
    }

    bool HasMedalTime(const string&in uid) override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return false;
        }

        const uint best = GetBestEver(uid);
        return true
            and best > 0
            and best < GetPB()
        ;
    }

    void UpdateMedal(const string&in uid) override {
        this.uid = uid;
    }
}

class UME_Previous : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;

        c.defaultName = "Previous Copium";
        c.icon = "\\$777" + Icons::ArrowCircleLeft;
        c.shareIcon = false;
        c.usePreviousColor = true;

        return c;
    }

    uint GetMedalTime() override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return 0;
        }

        return lastTime;
    }

    bool HasMedalTime(const string&in uid) override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return false;
        }

        return true
            and lastTime > 0
            and (false
                or lastTime > bestSessionTime
                or (true
                    and !UltimateMedalsExtended::IsMedalEnabled("Session Copium")
                    and (false
                        or bestSessionTime > GetBestEver(uid)
                        or (true
                            and !UltimateMedalsExtended::IsMedalEnabled("Best Copium")
                            and bestSessionTime < GetPB()
                        )
                    )
                )
            )
        ;
    }

    void UpdateMedal(const string&in uid) override { }
}

class UME_Session : UltimateMedalsExtended::IMedal {
    UltimateMedalsExtended::Config GetConfig() override {
        UltimateMedalsExtended::Config c;

        c.defaultName = "Session Copium";
        c.icon = "\\$777" + Icons::ArrowCircleDown;
        c.shareIcon = false;
        c.usePreviousColor = true;

        return c;
    }

    uint GetMedalTime() override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return 0;
        }

        return bestSessionTime;
    }

    bool HasMedalTime(const string&in uid) override {
        if (false
            or pluginMeta is null
            or !pluginMeta.Enabled
        ) {
            return false;
        }

        return true
            and bestSessionTime > 0
            and (false
                or bestSessionTime > GetBestEver(uid)
                or (true
                    and !UltimateMedalsExtended::IsMedalEnabled("Best Copium")
                    and bestSessionTime < GetPB()
                )
            )
        ;
    }

    void UpdateMedal(const string&in uid) override { }
}

#endif
