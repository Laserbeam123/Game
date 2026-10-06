// Server: walk the road network into a track; straight fallback. Sets and broadcasts BO_Path / BO_PathCum / BO_PathLen.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_map", "_center", "_radius", "_target", "_minLen", "_h", "_walk", "_best", "_roads", "_pts", "_res", "_dirF", "_i"];
_map = _this select 0;
_center = _map select M_SEARCH_CENTER;
_radius = _map select M_SEARCH_RADIUS_M;
_target = CFG_TRACK_TARGET_M;
_minLen = CFG_TRACK_MIN_M;
_h = CFG_BLOON_HEIGHT_M;

_walk = {
    private ["_cur", "_pts", "_visited", "_len", "_dir", "_next", "_best", "_bestDev", "_dev", "_d"];
    _cur = _this;
    _pts = [getPosATL _cur];
    _visited = [_cur];
    _len = 0;
    _dir = -1;
    while { _len < _target } do {
        _next = [];
        { if !(_x in _visited) then { _next set [count _next, _x] } } forEach (roadsConnectedTo _cur);
        if (count _next == 0) exitWith {};
        _best = _next select 0;
        if (_dir >= 0 && count _next > 1) then {
            _bestDev = 999;
            {
                _d = ((getPosATL _x select 0) - (getPosATL _cur select 0)) atan2 ((getPosATL _x select 1) - (getPosATL _cur select 1));
                _dev = abs ((((_d - _dir) + 540) % 360) - 180);
                if (_dev < _bestDev) then { _bestDev = _dev; _best = _x };
            } forEach _next;
        };
        _dir = ((getPosATL _best select 0) - (getPosATL _cur select 0)) atan2 ((getPosATL _best select 1) - (getPosATL _cur select 1));
        _len = _len + ([getPosATL _cur, getPosATL _best] call BO_fnc_dist2D);
        _visited set [count _visited, _best];
        _pts set [count _pts, getPosATL _best];
        _cur = _best;
    };
    [_pts, _len]
};

_best = [[], 0];
_roads = _center nearRoads _radius;
for "_i" from 0 to ((count _roads min 25) - 1) do {
    _res = (_roads select _i) call _walk;
    if ((_res select 1) > (_best select 1)) then { _best = _res };
};

_pts = _best select 0;
if ((_best select 1) < _minLen) then {
    diag_log format ["[BloonsOps] no road track >= %1 m near %2 (best %3 m), straight fallback", _minLen, _center, _best select 1];
    _dirF = _map select M_FALLBACK_DIR_DEG;
    _pts = [];
    for "_i" from 0 to (_target / 20) do {
        _pts set [count _pts, [(_center select 0) + (sin _dirF) * _i * 20, (_center select 1) + (cos _dirF) * _i * 20, 0]]
    };
};

BO_Path = [];
{ BO_Path set [count BO_Path, [_x select 0, _x select 1, (getTerrainHeightASL [_x select 0, _x select 1]) + _h]] } forEach _pts;
BO_PathCum = [0];
for "_i" from 1 to (count BO_Path - 1) do {
    BO_PathCum set [count BO_PathCum, (BO_PathCum select (_i - 1)) + ([BO_Path select (_i - 1), BO_Path select _i] call BO_fnc_dist2D)];
};
BO_PathLen = BO_PathCum select (count BO_PathCum - 1);
diag_log format ["[BloonsOps] track built: %1 points, %2 m", count BO_Path, round BO_PathLen];
publicVariable "BO_Path";
publicVariable "BO_PathCum";
publicVariable "BO_PathLen";
