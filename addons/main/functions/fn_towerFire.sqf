// Server: one tower, one tick. Picks bloons on its stretch of track and shoots: aimed (furthest along
// first), all-around (aoe), or a delayed splash. Every hit draws a coloured streak on clients.
params ["_t", "_now"];
if (_now < (_t getVariable ["bo_next", 0])) exitWith {};
private _s = _t getVariable "bo_stats";
private _kind = _s get "kind";
if (_kind == "farm") exitWith {};
if ((_t getVariable ["bo_mannable", false]) && { isPlayer gunner _t }) exitWith {};   // a player is on the gun
private _cover = _t getVariable "bo_cover";
private _seesCamo = _s get "sees_camo";

private _cands = [];
{
    private _r = BO_Bloons get (_y select 0);
    if (_seesCamo || { !(_r get "camo") }) then {
        private _d = [_y, _now] call BO_fnc_bloonDist;
        if (_cover findIf { _d >= (_x select 0) && _d <= (_x select 1) } >= 0) then { _cands pushBack [_d, _x, (_r get "speed_mps") * (_y select 3)] };
    };
} forEach BO_Live;
if (_cands isEqualTo []) exitWith {};
_cands sort false;
_t setVariable ["bo_next", _now + (_s get "fire_interval_s")];

private _target = _cands select 0;
private _tpos = [_target select 0] call BO_fnc_pathPos;
private _crew = (_t getVariable ["bo_crew", []]) select { alive _x };
private _heli = _t getVariable ["bo_heli", objNull];
private _muzzle = (getPosASL _t) vectorAdd [0, 0, 1.4];

// visuals: aim and fire (real projectiles are deleted by the Fired handler)
switch (_kind) do {
    case "static": {
        private _g = gunner _t;
        if (!isNull _g) then {
            _g doWatch (ASLToAGL _tpos);
            private _w = (_t weaponsTurret [0]) select 0;
            if (!isNil "_w") then { [_t, _w, [0]] call BIS_fnc_fire };
            _t setVehicleAmmo 1;
        };
    };
    case "infantry": {
        {
            _x setDir (_x getDir _tpos);
            _x doWatch (ASLToAGL _tpos);
            [_x, currentWeapon _x] call BIS_fnc_fire;
            _x setVehicleAmmo 1;
        } forEach _crew;
    };
    case "heli": {
        if (!isNull _heli) then {
            _muzzle = getPosASL _heli;
            {
                private _w = _heli weaponsTurret _x;
                if (_w isNotEqualTo [] && { !isNull (_heli turretUnit _x) }) then {
                    (_heli turretUnit _x) doWatch (ASLToAGL _tpos);
                    [_heli, _w select 0, _x] call BIS_fnc_fire;
                };
            } forEach (allTurrets [_heli, false]);
            _heli setVehicleAmmo 1;
        };
    };
    case "monkey": {
        _t setDir (_t getDir _tpos);
        _muzzle = (getPosASL _t) vectorAdd [0, 0, 0.6];
    };
};

private _dmg = _s get "damage";
private _lead = _s get "pops_lead";
private _slow = _s get "slow_mult";
private _fx = _s get "fx_rgba";
private _hit = {
    // _this: [id, distance]
    params ["_id", "_d"];
    if (_slow < 1) then { [_id, _slow, _s get "slow_s"] call BO_fnc_slowBloon };
    if (_dmg > 0) then { [_id, _dmg, _lead] call BO_fnc_damageBloon };
};

if ((_s get "splash_m") > 0) then {
    // shell lands after impact_delay_s where the lead bloon will be by then
    private _delay = _s get "impact_delay_s";
    private _aimD = ((_target select 0) + (_target select 2) * _delay) min BO_PathLen;
    BO_FxQueue pushBack [_muzzle, [_aimD] call BO_fnc_pathPos, _fx];
    [_aimD, _delay, _s, _hit, _dmg, _lead, _slow] spawn {
        params ["_aimD", "_delay", "_s", "_hit", "_dmg", "_lead", "_slow"];
        sleep _delay;
        private _p = [_aimD] call BO_fnc_pathPos;
        private _ammo = _s get "impact_ammo";
        if (_ammo != "") then {
            private _shell = createVehicle [_ammo, (ASLToATL _p) vectorAdd [0, 0, 30], [], 0, "CAN_COLLIDE"];
            _shell setVelocity [0, 0, -120];
        };
        BO_FxQueue pushBack [_p vectorAdd [0, 0, 3], _p vectorAdd [0, 0, -1], _s get "fx_rgba"];
        private _now = call BO_fnc_now;
        private _in = [];
        { if (abs (([_y, _now] call BO_fnc_bloonDist) - _aimD) <= (_s get "splash_m")) then { _in pushBack _x } } forEach BO_Live;
        { [_x, 0] call _hit } forEach (_in select [0, _s get "pierce"]);
    };
} else {
    private _n = if (_s get "aoe") then { _s get "pierce" } else { (_s get "pierce") * ((count _crew) max 1) };
    if (_kind == "heli" || _kind == "static") then { _n = _s get "pierce" };
    private _shots = _cands select [0, _n];
    { BO_FxQueue pushBack [_muzzle, [_x select 0] call BO_fnc_pathPos, _fx] } forEach (_shots select [0, 6]);
    { [_x select 1, _x select 0] call _hit } forEach _shots;
};
