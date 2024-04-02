// c 2024-04-01
// m 2024-04-01

void CacheLocalId() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        sleep(97);

        if (
            App.UserManagerScript is null
            || App.UserManagerScript.Users.Length == 0
            || App.UserManagerScript.Users[0] is null
        )
            continue;

        localId = App.UserManagerScript.Users[0].Id;
        if (localId.Value == 0 || localId.GetName().Length == 0)
            continue;

        break;
    }
}

void CacheLocalLogin() {
    while (true) {
        sleep(101);

        localLogin = GetLocalLogin();
        if (localLogin.Length > 10)
            break;
    }
}

void CacheLocalName() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        sleep(103);

        if (App.LocalPlayerInfo is null)
            continue;

        localName = App.LocalPlayerInfo.Name;
        if (localName.Length == 0)
            continue;

        break;
    }
}
