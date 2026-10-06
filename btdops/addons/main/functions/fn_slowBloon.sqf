/*
    Server: slow bloon _id to _mult x speed (0 = frozen) for _secs. A stronger slow already
    running is kept. MOABs ignore it.
*/
params ["_id", "_mult", "_secs"];
private _e = BTD_Live getOrDefault [_id, []];
if (_e isEqualTo [] || {_secs <= 0}) exitWith {};
if ((BTD_Bloons get (_e#0)) get "is_moab") exitWith {};
private _now = call BTD_fnc_now;
private _d = [_e, _now] call BTD_fnc_bloonDist;
private _until = _now + _secs;
if (_now < (_e#4)) then {
    _mult = _mult min (_e#3);
    _until = _until max (_e#4);
};
_e set [1, _d];
_e set [2, _now];
_e set [3, _mult];
_e set [4, _until];
(BTD_Batch#2) pushBack [_id, _d, _now, _mult, _until];
