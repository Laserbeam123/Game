// Server loop: leaks, slows ending, helicopters keep station, towers fire, batches broadcast.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_step", "_lastPub", "_lastHeli", "_now", "_leaked", "_e", "_d", "_heliCheck", "_t", "_h", "_q"];
_step = CFG_SERVER_TICK_S;
_lastPub = 0;
_lastHeli = 0;
while { BO_State == "play" } do {
    _now = call BO_fnc_now;
    _leaked = [];
    {
        _e = BO_Live select _x;
        _d = [_e, _now] call BO_fnc_bloonDist;
        if (_d >= BO_PathLen) then {
            _leaked set [count _leaked, _x];
        } else {
            if ((_e select 4) > 0 && { _now >= (_e select 4) }) then {
                BO_Live set [_x, [_e select 0, _d, _now, 1, 0]];
                BO_RebaseQueue set [count BO_RebaseQueue, [_x, _d, _now, 1]]
            };
        };
    } forEach BO_Alive;
    {
        BO_Lives = BO_Lives - ((BLOON((BO_Live select _x) select 0)) select B_LIVES_COST);
        BO_Live set [_x, []];
        BO_LeakQueue set [count BO_LeakQueue, _x];
    } forEach _leaked;
    if (count _leaked > 0) then { BO_Alive = BO_Alive - _leaked; publicVariable "BO_Lives" };

    _heliCheck = _now - _lastHeli > 5;
    if (_heliCheck) then { _lastHeli = _now };
    {
        _t = _x;
        if (!isNull _t) then {
            if ((_t getVariable "bo_mannable") && { isNull gunner _t } && { _now > (_t getVariable "bo_remanAt") }) then { [_t] call BO_fnc_remanTower };
            _h = _t getVariable "bo_heli";
            if (_heliCheck && { !isNull _h }) then {
                _h setFuel 1;
                _h flyInHeight (TOWER(_t getVariable "bo_type") select T_HOVER_M);
                if ([getPosATL _h, getPosATL _t] call BO_fnc_dist2D > 15) then { (driver _h) doMove (getPosATL _t) };
            };
            [_t, _now] call BO_fnc_towerFire;
        };
    } forEach BO_TowerList;

    if (count BO_SpawnQueue > 0) then { _q = BO_SpawnQueue; BO_SpawnQueue = []; ["BO_fnc_bloonLocal", [_q]] call BO_fnc_netAll };
    if (count BO_RebaseQueue > 0) then { _q = BO_RebaseQueue; BO_RebaseQueue = []; ["BO_fnc_rebaseLocal", [_q]] call BO_fnc_netAll };
    if (count BO_PopQueue > 0) then { _q = BO_PopQueue; BO_PopQueue = []; ["BO_fnc_popLocal", [_q, false]] call BO_fnc_netAll };
    if (count BO_LeakQueue > 0) then { _q = BO_LeakQueue; BO_LeakQueue = []; ["BO_fnc_popLocal", [_q, true]] call BO_fnc_netAll };
    if (BO_CashDirty && { _now - _lastPub > 0.3 }) then { BO_CashDirty = false; _lastPub = _now; publicVariable "BO_Cash" };
    if (BO_Lives <= 0) then { [false] call BO_fnc_gameOver };
    sleep _step;
};
