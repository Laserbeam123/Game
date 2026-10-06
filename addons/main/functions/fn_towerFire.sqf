// Server: one tower, one tick. Picks the bloon furthest along its stretch of track and shoots.
params ["_t", "_now"];
if (_now < (_t getVariable ["bo_next", 0])) exitWith {};
if ((_t getVariable ["bo_mannable", false]) && { isPlayer gunner _t }) exitWith {};   // a player is on the gun
private _s = _t getVariable "bo_stats";
private _cover = _t getVariable "bo_cover";
private _seesCamo = _s get "sees_camo";

private _cands = [];
{
    _y params ["_type", "_d0", "_t0"];
    private _r = BO_Bloons get _type;
    if (_seesCamo || { !(_r get "camo") }) then {
        private _d = _d0 + (_r get "speed_mps") * (_now - _t0);
        if (_cover findIf { _d >= (_x select 0) && _d <= (_x select 1) } >= 0) then { _cands pushBack [_d, _x, _r get "speed_mps"] };
    };
} forEach BO_Live;
if (_cands isEqualTo []) exitWith {};
_cands sort false;
_t setVariable ["bo_next", _now + (_s get "fire_interval_s")];

private _target = _cands select 0;
private _tpos = [_target select 0] call BO_fnc_pathPos;
private _crew = (_t getVariable ["bo_crew", []]) select { alive _x };

// visuals: turn to the bloon and fire (projectile is deleted by the Fired handler)
if ((_s get "kind") == "static") then {
    private _g = gunner _t;
    if (!isNull _g) then {
        _g doWatch (ASLToAGL _tpos);
        private _w = (_t weaponsTurret [0]) select 0;
        if (!isNil "_w") then { [_t, _w, [0]] call BIS_fnc_fire };
        _t setVehicleAmmo 1;
    };
} else {
    {
        _x setDir (_x getDir _tpos);
        _x doWatch (ASLToAGL _tpos);
        [_x, currentWeapon _x] call BIS_fnc_fire;
        _x setVehicleAmmo 1;
    } forEach _crew;
};

private _dmg = _s get "damage";
private _lead = _s get "pops_lead";
if ((_s get "splash_m") > 0) then {
    // shell lands after impact_delay_s where the lead bloon will be by then
    private _delay = _s get "impact_delay_s";
    private _aimD = ((_target select 0) + (_target select 2) * _delay) min BO_PathLen;
    [_aimD, _delay, _s] spawn {
        params ["_aimD", "_delay", "_s"];
        sleep _delay;
        private _p = [_aimD] call BO_fnc_pathPos;
        private _ammo = _s get "impact_ammo";
        if (_ammo != "") then {
            private _shell = createVehicle [_ammo, (ASLToATL _p) vectorAdd [0, 0, 30], [], 0, "CAN_COLLIDE"];
            _shell setVelocity [0, 0, -120];
        };
        private _now = call BO_fnc_now;
        private _hit = [];
        {
            _y params ["_type", "_d0", "_t0"];
            private _d = _d0 + ((BO_Bloons get _type) get "speed_mps") * (_now - _t0);
            if (abs (_d - _aimD) <= (_s get "splash_m")) then { _hit pushBack _x };
        } forEach BO_Live;
        { [_x, _s get "damage", _s get "pops_lead"] call BO_fnc_damageBloon } forEach (_hit select [0, _s get "pierce"]);
    };
} else {
    private _shots = (_s get "pierce") * ((count _crew) max 1);
    { [_x select 1, _dmg, _lead] call BO_fnc_damageBloon } forEach (_cands select [0, _shots]);
};
