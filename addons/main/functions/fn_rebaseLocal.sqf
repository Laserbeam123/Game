// Client: a bloon was slowed, frozen or released: continue from the server's new base. [[id, d0, t0, mult], ...]
params ["_batch"];
if (!hasInterface || { isNil "BO_LocalBloons" }) exitWith {};
{
    _x params ["_id", "_d0", "_t0", "_mult"];
    private _e = BO_LocalBloons getOrDefault [_id, []];
    if (_e isNotEqualTo []) then {
        _e set [2, _d0];
        _e set [3, _t0];
        _e set [4, ((BO_Bloons get (_e select 1)) get "speed_mps") * _mult];
    };
} forEach _batch;
