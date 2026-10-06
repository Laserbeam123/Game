// Server: [tower, now] one tower, one tick: aimed (furthest along first), all-around (aoe), or delayed splash.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_t", "_now", "_s", "_kind", "_cover", "_seesCamo", "_cands", "_r", "_d", "_e", "_in", "_sorted", "_bestI", "_bestD", "_i", "_target", "_tpos", "_crew", "_heli", "_g", "_w", "_dmg", "_lead", "_slow", "_n", "_shots", "_delay", "_aimD", "_dir"];
_t = _this select 0;
_now = _this select 1;
if (_now < (_t getVariable "bo_next")) exitWith {};
_s = _t getVariable "bo_stats";
_kind = _s select T_KIND;
if (_kind == "farm") exitWith {};
if ((_t getVariable "bo_mannable") && { isPlayer gunner _t }) exitWith {};
_cover = _t getVariable "bo_cover";
_seesCamo = _s select T_SEES_CAMO;

_cands = [];
{
    _e = BO_Live select _x;
    _r = BLOON(_e select 0);
    if (_seesCamo || { !(_r select B_CAMO) }) then {
        _d = [_e, _now] call BO_fnc_bloonDist;
        _in = false;
        { if (_d >= (_x select 0) && _d <= (_x select 1)) then { _in = true } } forEach _cover;
        if (_in) then { _cands set [count _cands, [_d, _x, (_r select B_SPEED_MPS) * (_e select 3)]] };
    };
} forEach BO_Alive;
if (count _cands == 0) exitWith {};

// furthest along first (selection sort; OA has no sort)
_sorted = [];
while { count _cands > 0 } do {
    _bestI = 0;
    _bestD = -1;
    for "_i" from 0 to (count _cands - 1) do { if (((_cands select _i) select 0) > _bestD) then { _bestD = (_cands select _i) select 0; _bestI = _i } };
    _sorted set [count _sorted, _cands select _bestI];
    _cands set [_bestI, "x"];
    _cands = _cands - ["x"];
};
_t setVariable ["bo_next", _now + (_s select T_FIRE_INTERVAL_S)];
_target = _sorted select 0;
_tpos = [_target select 0] call BO_fnc_pathPos;
_crew = [];
{ if (alive _x) then { _crew set [count _crew, _x] } } forEach (_t getVariable "bo_crew");
_heli = _t getVariable "bo_heli";

// visuals (real projectiles are deleted by the Fired handlers from towerLocal)
switch (_kind) do {
    case "static": {
        _g = gunner _t;
        if (!isNull _g) then {
            _g doWatch (ASLToATL _tpos);
            _w = _t weaponsTurret [0];
            if (count _w > 0) then { _t fire (_w select 0) };
            _t setVehicleAmmo 1;
        };
    };
    case "infantry": {
        {
            _dir = ((_tpos select 0) - (getPosATL _x select 0)) atan2 ((_tpos select 1) - (getPosATL _x select 1));
            _x setDir _dir;
            _x doWatch (ASLToATL _tpos);
            _x fire (primaryWeapon _x);
            _x setVehicleAmmo 1;
        } forEach _crew;
    };
    case "heli": {
        if (!isNull _heli) then {
            {
                _w = _heli weaponsTurret _x;
                if (count _w > 0 && { !isNull (_heli turretUnit _x) }) then {
                    (_heli turretUnit _x) doWatch (ASLToATL _tpos);
                    (_heli turretUnit _x) fire (_w select 0);
                };
            } forEach ((TOWER(_t getVariable "bo_type")) select T_OA_TURRETS);
            _heli setVehicleAmmo 1;
        };
    };
    case "monkey": {
        _dir = ((_tpos select 0) - (getPosATL _t select 0)) atan2 ((_tpos select 1) - (getPosATL _t select 1));
        _t setDir _dir;
    };
};

_dmg = _s select T_DAMAGE;
_lead = _s select T_POPS_LEAD;
_slow = _s select T_SLOW_MULT;
BO_hitOne = {
    // [id] apply this tower's slow, then its damage
    if (_slow < 1) then { [_this select 0, _slow, _s select T_SLOW_S] call BO_fnc_slowBloon };
    if (_dmg > 0) then { [_this select 0, _dmg, _lead] call BO_fnc_damageBloon };
};
if ((_s select T_SPLASH_M) > 0) then {
    _delay = _s select T_IMPACT_DELAY_S;
    _aimD = ((_target select 0) + (_target select 2) * _delay) min BO_PathLen;
    [_aimD, _delay, _s, _dmg, _lead, _slow] spawn {
        private ["_aimD", "_s", "_dmg", "_lead", "_slow", "_p", "_shell", "_now", "_hit", "_ammo"];
        _aimD = _this select 0;
        _s = _this select 2;
        _dmg = _this select 3;
        _lead = _this select 4;
        _slow = _this select 5;
        sleep (_this select 1);
        _p = [_aimD] call BO_fnc_pathPos;
        _ammo = _s select T_IMPACT_AMMO;
        if (_ammo != "") then {
            _shell = createVehicle [PROP_MORTAR_SHELL, [_p select 0, _p select 1, 30], [], 0, "CAN_COLLIDE"];
            _shell setVelocity [0, 0, -120];
        };
        _now = call BO_fnc_now;
        _hit = [];
        {
            if (abs (([BO_Live select _x, _now] call BO_fnc_bloonDist) - _aimD) <= (_s select T_SPLASH_M) && count _hit < (_s select T_PIERCE)) then { _hit set [count _hit, _x] };
        } forEach BO_Alive;
        { [_x] call BO_hitOne } forEach _hit;
    };
} else {
    _n = _s select T_PIERCE;
    if (_kind == "infantry") then { _n = _n * ((count _crew) max 1) };
    _shots = [];
    for "_i" from 0 to ((_n min (count _sorted)) - 1) do { _shots set [count _shots, (_sorted select _i) select 1] };
    { [_x] call BO_hitOne } forEach _shots;
};
