#if TMNEXT
[Setting name="Show timer"]
bool showTimer = true;

[Setting name="Show drop shadow (Disable Background color if activated)"]
bool showDropShadow = true;

[Setting name="Hide timer when interface is hidden"]
bool hideTimerWithIFace = true;

[Setting name="Show adjusted CP Delta (if there is an official one)"]
bool cpDelta = true;

[Setting name="Anchor X position" min=0 max=1]
float anchorX = .5;

[Setting name="Anchor Y position" min=0 max=1]
float anchorY = .987;

[Setting name="Font size" min=8 max=72]
int fontSize = 24;

[Setting color name="Timer color"]
vec4 colorNormal = vec4(1, 1, 1, 1);

[Setting color name="Backgroung color"]
vec4 backColor = vec4(0, 0, 0, 0);

bool inGame = false;
int preCPIdx = -1;
bool firstCP = true;
uint64 lastCPTime = 0;
int respawnCount = -1;
uint64 timeShift = 0;

vec4 colorBlue = vec4(0, 0, 0.8, 0.8);
vec4 colorRed = vec4(0.8, 0, 0, 0.8);

string infos;
string diffPB;
int medal = -1;

const array<vec4> medals = {
  vec4(0, 0, 0, 0), // no medal
  vec4(0.604, 0.400, 0.259, 1), // bronze medal
  vec4(0.537, 0.604, 0.604, 1), // silver medal
  vec4(0.871, 0.737, 0.259, 1), // gold medal
  vec4(0.000, 0.471, 0.035, 1), // author medal
};

nvg::Font font;

void Main()
{
	font = nvg::LoadFont("DroidSans-Bold.ttf", true);
}

void RenderMenu()
{
	if (UI::MenuItem("\\$09f" + Icons::Flag + "\\$z No-Respawn Timer", "", showTimer))
		showTimer = !showTimer;
}

void Render()
{
	if (showTimer && inGame && infos != "")
	{
		nvg::FontFace(font);
		nvg::FontSize(fontSize);
		float w = infos.Length < 12 ? infos.Length * fontSize * 0.5 : nvg::TextBounds(infos).x;
		float bck_l = 0;
		float bck_w = 0;
		float y = anchorY * Draw::GetHeight() + 1;
		float shadowOffset = fontSize / 12.0;
		if (medal >= 1)
		{
			bck_w = fontSize * 3 - 4;
			bck_l = -0.5 * bck_w;
		}
		if (diffPB == "" || !cpDelta)
		{
			nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
			if (showDropShadow)
			{
				nvg::FillColor(vec4(0, 0, 0, 1));
				nvg::TextBox(anchorX * Draw::GetWidth() - w / 2 - 2 + shadowOffset, y + shadowOffset, w + 4, infos);
			}
			else
			{
				nvg::BeginPath();
				bck_l += anchorX * Draw::GetWidth() - w / 2 - 3;
				bck_w += w + 6;
				nvg::Rect(bck_l, y - (fontSize - 2) / 2 - 3, bck_w, fontSize + 2);
				nvg::FillColor(backColor);
				nvg::Fill();
				nvg::ClosePath();
			}

			nvg::FillColor(colorNormal);
			nvg::TextBox(anchorX * Draw::GetWidth() - w / 2 - 2, y, w + 4, infos);
		}
		else
		{
			nvg::FontSize(fontSize - 2);
			float wd = nvg::TextBounds(diffPB).x;
			float center = (w - wd) / 2;

			nvg::FontSize(fontSize);
			nvg::TextAlign(nvg::Align::Right | nvg::Align::Middle);
			if (showDropShadow)
			{
				nvg::FillColor(vec4(0, 0, 0, 1));
				nvg::TextBox(anchorX * Draw::GetWidth() +center - w - 10 + shadowOffset, y + shadowOffset, w + 4, infos);
			}
			else
			{
				nvg::BeginPath();
				bck_l += anchorX * Draw::GetWidth() + center - w - 8;
				bck_w += w + wd + 17;
				nvg::Rect(bck_l, y - (fontSize - 2) / 2 - 3, bck_w, fontSize + 2);
				nvg::FillColor(backColor);
				nvg::Fill();
				nvg::ClosePath();
			}

			nvg::FillColor(colorNormal);
			nvg::TextBox(anchorX * Draw::GetWidth() + center - w - 10, y, w + 4, infos);

			nvg::BeginPath();
            nvg::Rect(anchorX * Draw::GetWidth() + center + 3, y - (fontSize - 2) / 2 - 2, wd + 5, fontSize);
            nvg::FillColor(diffPB.SubStr(0, 1) == "-" ? colorBlue : colorRed);
            nvg::Fill();
            nvg::ClosePath();

			nvg::FontSize(fontSize - 2);
			nvg::TextAlign(nvg::Align::Left | nvg::Align::Middle);
			nvg::FillColor(colorNormal);
		    nvg::TextBox(anchorX * Draw::GetWidth() + center + 6, y + 1, wd + 4, diffPB);

			w += wd + 10;
		}

		if (medal >= 1)
		{
			if (showDropShadow)
			{
				nvg::BeginPath();
				nvg::Ellipse(vec2(anchorX * Draw::GetWidth() - w / 2 - fontSize + shadowOffset, y - 1 + shadowOffset), fontSize / 2.5, fontSize / 2.5);
				nvg::FillColor(vec4(0, 0, 0, 1));
				nvg::Fill();
				nvg::ClosePath();
				nvg::BeginPath();
				nvg::Ellipse(vec2(anchorX * Draw::GetWidth() + w / 2 + fontSize + shadowOffset, y - 1 + shadowOffset), fontSize / 2.5, fontSize / 2.5);
				nvg::FillColor(vec4(0, 0, 0, 1));
				nvg::Fill();
				nvg::ClosePath();
			}

			nvg::BeginPath();
            nvg::Ellipse(vec2(anchorX * Draw::GetWidth() - w / 2 - fontSize, y - 1), fontSize / 2.5, fontSize / 2.5);
            nvg::FillColor(medals[medal]);
            nvg::Fill();
            nvg::ClosePath();
			nvg::BeginPath();
            nvg::Ellipse(vec2(anchorX * Draw::GetWidth() + w / 2 + fontSize, y - 1), fontSize / 2.5, fontSize / 2.5);
            nvg::FillColor(medals[medal]);
            nvg::Fill();
            nvg::ClosePath();
		}
	}
}

void Update(float dt)
{
	auto playground = cast<CSmArenaClient>(GetApp().CurrentPlayground);

	if (playground is null
		|| playground.Arena is null
		|| playground.Map is null
		|| playground.GameTerminals.Length <= 0
		|| (playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Playing
			&& playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::Finish
			&& playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::EndRound) )
	{
		inGame = false;
		preCPIdx = -1;
		firstCP = true;
		return;
	}

	auto player = cast<CSmPlayer>(playground.GameTerminals[0].GUIPlayer);
	auto scriptPlayer = player is null ? null : cast<CSmScriptPlayer>(player.ScriptAPI);
	int64 raceTime = 0;

	if (playground.GameTerminals[0].UISequence_Current != CGamePlaygroundUIConfig::EUISequence::EndRound)
	{
		if (scriptPlayer is null)
		{
			inGame = false;
			preCPIdx = -1;
			firstCP = true;
			return;
		}

		raceTime = GetRaceTime(scriptPlayer);

		if (player.CurrentLaunchedRespawnLandmarkIndex == uint(-1) || raceTime <= 0)
		{
			inGame = false;
			preCPIdx = -1;
			firstCP = true;
			return;
		}
	}

	// in game only if interface displayed or don't care
	inGame = !hideTimerWithIFace || UI::IsGameUIVisible();

	if (playground.GameTerminals[0].UISequence_Current == CGamePlaygroundUIConfig::EUISequence::Playing)
	{
		if (preCPIdx == -1)
		{
			// starting => no time shift, no respawn yet
			lastCPTime = timeShift = respawnCount = 0;
			infos = "";
			diffPB = "";
			medal = -1;
			preCPIdx = player.CurrentLaunchedRespawnLandmarkIndex;
			firstCP = true;
		}
		else
		{
			if (preCPIdx != int(player.CurrentLaunchedRespawnLandmarkIndex))
			{
				// changing CP => save last CP time with time shift
				preCPIdx = player.CurrentLaunchedRespawnLandmarkIndex;
				firstCP = false;
				lastCPTime = raceTime - timeShift;
				if (respawnCount > 0 && cpDelta)
				{
					int64 diff = GetDiffPB();
					if (diff == 0)
						diffPB = "";
					else
						diffPB = FormatDiff(diff - timeShift);
				}
			}
			if (respawnCount < int(scriptPlayer.Score.NbRespawnsRequested))
			{
				// changing respawn count => time shift recalculated so that timer will be reset to last CP time
				respawnCount = scriptPlayer.Score.NbRespawnsRequested;
				timeShift = raceTime - lastCPTime;
				if (!firstCP)
					timeShift += 1000; // 1000 = 3 - 2 - 1 delay (not applicable on first CP)
			}
		}

		if (respawnCount > 0 && raceTime >= timeShift)
			// display timer only if at least one respawn
			infos = FormatTime(raceTime - timeShift);
	}
	else if (preCPIdx != -1)
	{
		preCPIdx = -1;
		firstCP = true;
		if (respawnCount > 0 && raceTime >= timeShift)
		{
			infos = FormatTime(raceTime - timeShift) + " (" + respawnCount + " respawn" + (respawnCount > 1 ? "s" : "") + ")";
			if (cpDelta)
			{
				int64 diff = GetDiffPB();
				if (diff == 0)
					diffPB = "";
				else
					diffPB = FormatDiff(diff - timeShift);
			}

			auto app = cast<CTrackMania>(GetApp());
			auto map = app.RootMap;
			if (map.TMObjective_AuthorTime >= uint(raceTime - timeShift))
				medal = 4;
			else if (map.TMObjective_GoldTime >= uint(raceTime - timeShift))
				medal = 3;
			else if (map.TMObjective_SilverTime >= uint(raceTime - timeShift))
				medal = 2;
			else if (map.TMObjective_BronzeTime >= uint(raceTime - timeShift))
				medal = 1;
			else
				medal = 0;
		}
	}
}

int64 GetRaceTime(CSmScriptPlayer& scriptPlayer)
{
	if (scriptPlayer is null)
		// not playing
		return 0;

	auto playgroundScript = cast<CSmArenaRulesMode>(GetApp().PlaygroundScript);

	if (playgroundScript is null)
		// Online
		return GetApp().Network.PlaygroundClientScriptAPI.GameTime - scriptPlayer.StartTime;
	else
		// Solo
		return playgroundScript.Now - scriptPlayer.StartTime;
}

int64 GetDiffPB()
{
	auto network = GetApp().Network;

	if (network.ClientManiaAppPlayground !is null &&
		network.ClientManiaAppPlayground.UILayers.Length > 0)
	{
		auto uilayers = network.ClientManiaAppPlayground.UILayers;

		for (uint i = 0; i < uilayers.Length; i++)
		{
			CGameUILayer@ curLayer = uilayers[i];
			int start = curLayer.ManialinkPageUtf8.IndexOf("<");
			int end = curLayer.ManialinkPageUtf8.IndexOf(">");
			if (start != -1 && end != -1)
			{
				auto manialinkname = curLayer.ManialinkPageUtf8.SubStr(start, end);
				if (manialinkname.Contains("UIModule_Race_Checkpoint"))
				{
					auto c = cast<CGameManialinkLabel@>(curLayer.LocalPage.GetFirstChild("label-race-diff"));
					if (c.Visible && c.Parent.Visible) // reference lap not finished
					{
						string diff = c.Value;
						int64 res = 0;
						if (diff.Length == 10) // invalid format
						{
							res = diff.SubStr(0,1) == "-" ? -1 : 1;
							int min = Text::ParseInt(diff.SubStr(1, 2));
							int sec = Text::ParseInt(diff.SubStr(4, 2));
							int ms = Text::ParseInt(diff.SubStr(7, 3));
							res *= (min * 60000) + (sec * 1000) + ms;
						}
						return res;
					}
				}
			}
		}
	}

	return 0;
}

string FormatTime(uint64 time)
{
	string str = "";
	double tm = time / 1000.0;

	int hundredth = int((tm % 1.0) * 100);
	int seconds = int(tm % 60);
	int minutes = int(tm / 60) % 60;
	int hours = int(tm / 60 / 60);

	if (hours > 0) str += hours + ":";
	str += PadNumber(minutes) + ":";
	str += PadNumber(seconds) + ".";
	str += PadNumber(hundredth);

	return str;
}

string FormatDiff(int64 time)
{
	string str = "+";
	if (time < 0)
	{
		str = "-";
		time *= -1;
	}
	double tm = time / 1000.0;

	int hundredth = int((tm % 1.0) * 100);
	int seconds = int(tm % 60);
	int minutes = int(tm / 60) % 60;
	int hours = int(tm / 60 / 60);

	if (hours > 0) str += hours + ":";
	str += PadNumber(minutes) + ":";
	str += PadNumber(seconds) + ".";
	str += PadNumber(hundredth);

	return str;
}

string PadNumber(int number)
{
	if (number < 10)
		return "0" + number;
	else
		return "" + number;
}

#else

void Main()
{
	print("This plugin only works with TM 2020 !");
}

#endif