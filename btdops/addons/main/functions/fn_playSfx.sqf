/*
    Client: play a sounds-sheet effect. range_m 0 = interface sound, else 3D at _pos (ATL).
*/
params ["_id", "_pos"];
private _s = BTD_Sounds getOrDefault [_id, createHashMap];
if (count _s == 0 || {(_s get "recipe") == "none"}) exitWith {};
if ((_s get "range_m") <= 0) exitWith {playSound ("btdops_" + _id)};
playSound3D [format ["z\btdops\addons\main\sounds\%1.ogg", _id], objNull, false, AGLToASL _pos, 10 ^ ((_s get "volume_db") / 20) * 2, 1, _s get "range_m", 0, true];
