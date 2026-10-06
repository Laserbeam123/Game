// Server: end the mission for everyone.
params ["_win"];
if (!isServer || { BO_State != "play" }) exitWith {};
missionNamespace setVariable ["BO_State", "over", true];
diag_log format ["[BloonsOps] game over, win=%1 round=%2 lives=%3", _win, BO_Round, BO_Lives];
[["BO_Lose", "BO_Win"] select _win, _win] remoteExecCall ["BIS_fnc_endMission", 0];
