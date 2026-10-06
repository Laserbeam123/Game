// Every machine: show the ending (END1 = win, LOSER = out of lives; see description.ext CfgDebriefing).
if (_this select 0) then { endMission "END1" } else { endMission "LOSER" };
