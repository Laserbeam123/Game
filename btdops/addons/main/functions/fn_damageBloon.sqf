/*
    Server: hit bloon _id for _dmg layers.
    Lead ignores hits that can't pop lead. A MOAB loses hp first. When the last layer goes,
    its children appear where it was (keeping any slow) and take the leftover damage.
    Returns: layers popped.
*/
params ["_id", "_dmg", "_canLead"];
private _e = BTD_Live getOrDefault [_id, []];
if (_e isEqualTo [] || {BTD_GameOver}) exitWith {0};
private _b = BTD_Bloons get (_e#0);
if ((_b get "lead") && !_canLead) exitWith {0};
private _now = call BTD_fnc_now;
private _left = _dmg - 1;
if (_b get "is_moab") then {
    private _hp = (_e#5) - _dmg;
    _e set [5, _hp];
    _left = -_hp;
};
if ((_e#5) > 0 && {_b get "is_moab"}) exitWith {
    (BTD_Batch#3) pushBack [_id, _e#5];
    0
};
private _d = [_e, _now] call BTD_fnc_bloonDist;
BTD_Live deleteAt _id;
(BTD_Batch#1) pushBack _id;
BTD_Cash = BTD_Cash + (_b get "pop_cash");
BTD_Dirty = true;
private _n = 1;
{
    private _kid = [_x, (_d - _forEachIndex * 0.8) max 0, _now, _e#3, _e#4] call BTD_fnc_spawnBloon;
    if (_left > 0) then {_n = _n + ([_kid, _left, _canLead] call BTD_fnc_damageBloon)};
} forEach (_b get "children");
_n
