// Server loop: leaks cost lives, slows wear off, helicopters keep station, towers fire, and the queued
// spawns / pops / re-bases / shot streaks are broadcast in batches.
private _step = BO_Cfg get "server_tick_s";
private _lastPub = 0;
private _lastHeli = 0;
while { BO_State == "play" } do {
    private _now = call BO_fnc_now;

    // leaks, and slows that have run out
    private _leaked = [];
    {
        if (([_y, _now] call BO_fnc_bloonDist) >= BO_PathLen) then {
            _leaked pushBack _x;
        } else {
            if ((_y select 4) > 0 && { _now >= (_y select 4) }) then {
                private _d = [_y, _now] call BO_fnc_bloonDist;
                BO_Live set [_x, [_y select 0, _d, _now, 1, 0]];
                BO_RebaseQueue pushBack [_x, _d, _now, 1];
            };
        };
    } forEach BO_Live;
    {
        private _type = (BO_Live get _x) select 0;
        BO_Lives = BO_Lives - ((BO_Bloons get _type) get "lives_cost");
        BO_Live deleteAt _x;
        BO_LeakQueue pushBack _x;
    } forEach _leaked;
    if (_leaked isNotEqualTo []) then { publicVariable "BO_Lives" };

    // helicopters: stay over the pad, stay fuelled
    private _heliCheck = _now - _lastHeli > 5;
    if (_heliCheck) then { _lastHeli = _now };

    // towers
    {
        if (!isNull _x) then {
            private _t = _x;
            if ((_t getVariable ["bo_mannable", false]) && { isNull gunner _t } && { _now > (_t getVariable ["bo_remanAt", 0]) }) then {
                [_t] call BO_fnc_remanTower;
            };
            private _h = _t getVariable ["bo_heli", objNull];
            if (_heliCheck && { !isNull _h }) then {
                _h setFuel 1;
                _h flyInHeight ((_t getVariable "bo_stats") get "hover_m");
                if ((_h distance2D _t) > 15) then { (driver _h) doMove (getPosATL _t) };
            };
            [_t, _now] call BO_fnc_towerFire;
        };
    } forEach BO_TowerList;

    // broadcast batches
    if (BO_SpawnQueue isNotEqualTo []) then {
        private _q = BO_SpawnQueue; BO_SpawnQueue = [];
        [_q] remoteExecCall ["BO_fnc_bloonLocal", 0];
    };
    if (BO_RebaseQueue isNotEqualTo []) then {
        private _q = BO_RebaseQueue; BO_RebaseQueue = [];
        [_q] remoteExecCall ["BO_fnc_rebaseLocal", 0];
    };
    if (BO_PopQueue isNotEqualTo []) then {
        private _q = BO_PopQueue; BO_PopQueue = [];
        [_q, false] remoteExecCall ["BO_fnc_popLocal", 0];
    };
    if (BO_LeakQueue isNotEqualTo []) then {
        private _q = BO_LeakQueue; BO_LeakQueue = [];
        [_q, true] remoteExecCall ["BO_fnc_popLocal", 0];
    };
    if (BO_FxQueue isNotEqualTo []) then {
        private _q = BO_FxQueue; BO_FxQueue = [];
        [_q select [(count _q - 40) max 0, 40]] remoteExecCall ["BO_fnc_fxLocal", 0];
    };
    if (BO_CashDirty && { _now - _lastPub > 0.3 }) then {
        BO_CashDirty = false;
        _lastPub = _now;
        publicVariable "BO_Cash";
    };
    if (BO_Lives <= 0) then { [false] call BO_fnc_gameOver };
    sleep _step;
};
