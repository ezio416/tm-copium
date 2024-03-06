// c 2024-03-05
// m 2024-03-05

string TimeFormat(int64 time) {
    string str = "+";

    if (time < 0) {
        str = "-";
        time *= -1;
    }

    return str + Time::Format(time);
}

string ZPad2(int number) {
    return (number < 10 ? "0" : "") + number;
}