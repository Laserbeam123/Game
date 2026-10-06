// Server loop: leaks cost lives, towers fire, queued spawns/pops are broadcast in batches.
private _step = BO_Cfg get "server_tick_s";
private _lastPub = 0;
while { BO_State == "play" } do {
    private _now = call BO_fnc_now;

    // leaks
    private _leaked = [];
    {
        _y params ["_type", "_d0", "_t0"];
        if (_d0 + ((BO_Bloons get _type) get "speed_mps") * (_now - _t0) >= BO_PathLen) then { _leaked pushBack _x };
    } forEach BO_Live;
    {
        private _type = (BO_Live get _x) select 0;
        BO_Lives = BO_Lives - ((BO_Bloons get _type) get "lives_cost");
        BO_Live deleteAt _x;
        BO_LeakQueue pushBack _x;
    } forEach _leaked;
    if (_leaked isNotEqualTo []) then { publicVariable "BO_Lives" };

    // towers
    {
        if (!isNull _x) then {
            private _t = _x;
            if ((_t getVariable ["bo_mannable", false]) && { isNull gunner _t } && { _now > (_t getVariable ["bo_remanAt", 0]) }) then {
                [_t] call BO_fnc_remanTower;
            };
            [_t, _now] call BO_fnc_towerFire;
        };
    } forEach BO_TowerList;

    // broadcast batches
    if (BO_SpawnQueue isNotEqualTo []) then {
        private _q = BO_SpawnQueue; BO_SpawnQueue = [];
        [_q] remoteExecCall ["BO_fnc_bloonLocal", 0];
    };
    if (BO_PopQueue isNotEqualTo []) then {
        private _q = BO_PopQueue; BO_PopQueue = [];
        [_q, false] remoteExecCall ["BO_fnc_popLocal", 0];
    };
    if (BO_LeakQueue isNotEqualTo []) then {
        private _q = BO_LeakQueue; BO_LeakQueue = [];
        [_q, true] remoteExecCall ["BO_fnc_popLocal", 0];
    };
    if (BO_CashDirty && { _now - _lastPub > 0.3 }) then {
        BO_CashDirty = false;
        _lastPub = _now;
        publicVariable "BO_Cash";
    };
    if (BO_Lives <= 0) then { [false] call BO_fnc_gameOver };
    sleep _step;
};
