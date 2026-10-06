/*
    Server -> clients, once per server tick: [spawns, pops, slows, moab hp, shot effects, leaks].
*/
if (!hasInterface || {isNil "BTD_CLive"}) exitWith {};
params ["_spawns", "_pops", "_slows", "_hps", "_fx", "_leaks"];
private _now = call BTD_fnc_now;
{ BTD_CLive set [_x#0, _x select [1, 6]] } forEach _spawns;
{
    _x params ["_id", "_d0", "_t0", "_mult", "_until"];
    private _e = BTD_CLive getOrDefault [_id, []];
    if (_e isNotEqualTo []) then {_e set [1, _d0]; _e set [2, _t0]; _e set [3, _mult]; _e set [4, _until]};
} forEach _slows;
{
    private _e = BTD_CLive getOrDefault [_x#0, []];
    if (_e isNotEqualTo []) then {_e set [5, _x#1]};
} forEach _hps;
private _sounds = 0;
{
    private _e = BTD_CLive getOrDefault [_x, []];
    if (_e isNotEqualTo []) then {
        private _p = ([[_e, _now] call BTD_fnc_bloonDist] call BTD_fnc_trackPos)#0;
        BTD_Effects pushBack ["pop", _p, _p, diag_tickTime, 0.25, 0];
        if (_sounds < 4) then {_sounds = _sounds + 1; ["pop", _p] call BTD_fnc_playSfx};
        BTD_CLive deleteAt _x;
    };
} forEach _pops;
{ BTD_CLive deleteAt _x } forEach _leaks;
{
    _x params ["_kind", "_from", "_to", "_sound", "_aoe"];
    BTD_Effects pushBack [_kind, _from, _to, diag_tickTime, [0.15, 0.6] select (_kind in ["bomb", "frost", "place", "sell"]), _aoe];
    if (_sound != "none" && {(player distance _from) < 150}) then {[_sound, _from] call BTD_fnc_playSfx};
} forEach _fx;
