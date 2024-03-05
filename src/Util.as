// c 2024-03-05
// m 2024-03-05

string FormatDiff(int64 time) {
    string str = "+";

    if (time < 0) {
        str = "-";
        time *= -1;
    }

    double tm = time / 1000.0;

    int hundredth = int((tm % 1.0) * 100.0);
    int seconds   = int(tm % 60.0);
    int minutes   = int(tm / 60.0) % 60;
    int hours     = int(tm / 3600.0);

    if (hours > 0)
        str += hours + ":";
    str += ZPad2(minutes) + ":";
    str += ZPad2(seconds) + ".";
    str += ZPad2(hundredth);

    return str;
}

string FormatTime(uint64 time) {
    string str = "";
    double tm = time / 1000.0;

    int hundredth = int((tm % 1.0) * 100);
    int seconds   = int(tm % 60.0);
    int minutes   = int(tm / 60.0) % 60;
    int hours     = int(tm / 3600.0);

    if (hours > 0)
        str += hours + ":";
    str += ZPad2(minutes) + ":";
    str += ZPad2(seconds) + ".";
    str += ZPad2(hundredth);

    return str;
}

string ZPad2(int number) {
    return (number < 10 ? "0" : "") + number;
}