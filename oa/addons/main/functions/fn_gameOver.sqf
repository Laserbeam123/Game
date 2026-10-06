// Server: end the mission for everyone. [win]
if (!isServer || { BO_State != "play" }) exitWith {};
BO_State = "over";
publicVariable "BO_State";
diag_log format ["[BloonsOps] game over, win=%1 round=%2 lives=%3", _this select 0, BO_Round, BO_Lives];
["BO_fnc_endLocal", [_this select 0]] call BO_fnc_netAll;
