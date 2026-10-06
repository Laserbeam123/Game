/*
    Client -> server: start the next round from its rounds row.
*/
if (!isServer || {BTD_GameOver} || {BTD_RoundRunning} || {BTD_Round >= BTD_RoundCount}) exitWith {};
BTD_Round = BTD_Round + 1;
private _r = BTD_Rounds get (format ["r%1", [BTD_Round, 2] call BIS_fnc_padNumber]);
private _now = call BTD_fnc_now;
private _s = [];
{
    _x params ["_type", "_count", "_spacing", "_start"];
    for "_i" from 0 to (_count - 1) do {_s pushBack [_now + 1 + _start + _i * _spacing, _type]};
} forEach (_r get "groups");
_s sort true;
BTD_Schedule = _s;
BTD_RoundRunning = true;
publicVariable "BTD_Round";
publicVariable "BTD_RoundRunning";
private _msg = [format ["Round %1", BTD_Round], format ["Round %1: a M.O.A.B. is coming!", BTD_Round]] select (_r get "boss");
[_msg, "round"] remoteExecCall ["BTD_fnc_notify", 0];
