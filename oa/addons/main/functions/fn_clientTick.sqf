// Client, every frame: float bloons along the track; test tracked player shots; on-foot speed boost.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_now", "_t", "_dt", "_e", "_p", "_keep", "_r", "_proj", "_last", "_cur", "_sx", "_sy", "_sz", "_len2", "_hit", "_bp", "_f", "_cx", "_cy", "_cz", "_v", "_k", "_rad"];
_now = call BO_fnc_now;
_t = diag_tickTime;
_dt = (_t - BO_LastTick) min 0.1;
BO_LastTick = _t;
{
    _e = BO_LocalB select _x;
    _p = [(_e select 2) + (_e select 4) * (_now - (_e select 3))] call BO_fnc_pathPos;
    _p set [2, (_p select 2) + 0.15 * sin (_now * 180 + (_e select 5))];
    (_e select 0) setPosASL _p;
    (_e select 6) setPosASL [_p select 0, _p select 1, (_p select 2) - 0.55];
} forEach BO_LocalIds;

// speed boost: carry the player further along their own movement (OA has no setAnimSpeedCoef)
if (vehicle player == player && { alive player } && { speed player > 4 }) then {
    _v = velocity player;
    _k = (CFG_PLAYER_SPEED_MULT - 1) * _dt;
    _p = getPosASL player;
    player setPosASL [(_p select 0) + (_v select 0) * _k, (_p select 1) + (_v select 1) * _k, _p select 2];
};

if (count BO_Proj == 0) exitWith {};
_r = CFG_PLAYER_HIT_RADIUS_M;
_keep = [];
{
    _proj = _x select 0;
    _last = _x select 1;
    if (isNull _proj || { _now > (_x select 3) }) then {
        if (_x select 2) then {
            // explosive: everything within the blast where it went off, lead included
            _rad = 5;
            _hit = 0;
            {
                _e = BO_LocalB select _x;
                if (_hit < 20 && { ((getPosASL (_e select 0)) distance _last) < _rad }) then { ["BO_fnc_damageBloon", [_x, 1, true]] call BO_fnc_netServer; _hit = _hit + 1 };
            } forEach BO_LocalIds;
        };
    } else {
        _cur = getPosASL _proj;
        _sx = (_cur select 0) - (_last select 0);
        _sy = (_cur select 1) - (_last select 1);
        _sz = (_cur select 2) - (_last select 2);
        _len2 = (_sx * _sx + _sy * _sy + _sz * _sz) max 0.0001;
        _hit = -1;
        if !(_x select 2) then {
            {
                if (_hit < 0) then {
                    _bp = getPosASL ((BO_LocalB select _x) select 0);
                    _f = ((((_bp select 0) - (_last select 0)) * _sx + ((_bp select 1) - (_last select 1)) * _sy + ((_bp select 2) - (_last select 2)) * _sz) / _len2) max 0 min 1;
                    _cx = (_last select 0) + _sx * _f;
                    _cy = (_last select 1) + _sy * _f;
                    _cz = (_last select 2) + _sz * _f;
                    if (sqrt (((_bp select 0) - _cx) ^ 2 + ((_bp select 1) - _cy) ^ 2 + ((_bp select 2) - _cz) ^ 2) < _r) then { _hit = _x };
                };
            } forEach BO_LocalIds;
        };
        if (_hit >= 0) then { ["BO_fnc_damageBloon", [_hit, 1, false]] call BO_fnc_netServer } else {
            _x set [1, _cur];
            _keep set [count _keep, _x];
        };
    };
} forEach BO_Proj;
BO_Proj = _keep;
