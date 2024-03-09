// c 2024-03-08
// m 2024-03-09

bool intercepting = false;

void Intercept() {
    if (intercepting) {
        // warn("Intercept called, but it's already running!");
        return;
    }

    if (GetApp().CurrentPlayground is null)
        return;

    trace("Intercept starting for \"LayerCustomEvent\"");

    try {
        Dev::InterceptProc("CGameManiaApp", "LayerCustomEvent", _Intercept);
        intercepting = true;
    } catch {
        warn("Intercept error: " + getExceptionInfo());
    }
}

void ResetIntercept() {
    if (!intercepting) {
        // warn("ResetIntercept called, but Intercept isn't running!");
        return;
    }

    trace("Intercept ending for \"LayerCustomEvent\"");

    try {
        Dev::ResetInterceptProc("CGameManiaApp", "LayerCustomEvent");
        intercepting = false;
    } catch {
        warn("ResetIntercept error: " + getExceptionInfo());
    }
}

bool _Intercept(CMwStack &in stack, CMwNod@ nod) {
    try {
        CaptureEvent(stack.CurrentWString(1), stack.CurrentBufferWString());
    } catch {
        warn("_Intercept error: " + getExceptionInfo());
    }

    return true;
}

void CaptureEvent(const string &in type, MwFastBuffer<wstring> &in data) {
    if (type != "TMGame_RaceCheckpoint_Waypoint")
        return;

    cpCount = Text::ParseInt(data[6]);

    const int cpTime = Text::ParseInt(data[0]);
    cpTimes.InsertLast(cpTime);
    lastCpTime = cpTime;
}