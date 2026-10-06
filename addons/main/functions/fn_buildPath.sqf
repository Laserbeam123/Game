// Server: walk the road network of the map row into a track. Sets and broadcasts BO_Path (ASL points)
// and BO_PathCum (cumulative metres). Falls back to a straight track if no road is long enough.
params ["_map"];
private _center = _map get "search_center";
private _radius = _map get "search_radius_m";
private _target = BO_Cfg get "track_target_m";
private _minLen = BO_Cfg get "track_min_m";
private _h = BO_Cfg get "bloon_height_m";

private _walk = {
    params ["_start"];
    private _pts = [getPosATL _start];
    private _visited = [_start];
    private _cur = _start;
    private _len = 0;
    private _dir = -1;
    while { _len < _target } do {
        private _next = (roadsConnectedTo [_cur, true]) select { !(_x in _visited) };
        if (_next isEqualTo []) exitWith {};
        private _best = _next select 0;
        if (_dir >= 0 && count _next > 1) then {
            // keep going as straight as possible
            private _bestDev = 999;
            {
                private _dev = abs (((_cur getDir _x) - _dir + 540) % 360 - 180);
                if (_dev < _bestDev) then { _bestDev = _dev; _best = _x };
            } forEach _next;
        };
        _dir = _cur getDir _best;
        _len = _len + (_cur distance2D _best);
        _visited pushBack _best;
        _pts pushBack (getPosATL _best);
        _cur = _best;
    };
    [_pts, _len]
};

private _best = [[], 0];
private _roads = _center nearRoads _radius;
{
    private _r = _x;
    private _res = [_r] call _walk;
    if ((_res select 1) > (_best select 1)) then { _best = _res };
    if ((_best select 1) >= _target) exitWith {};
} forEach (_roads select [0, 25]);

private _pts2d = _best select 0;
if ((_best select 1) < _minLen) then {
    diag_log format ["[BloonsOps] no road track >= %1 m near %2 (best %3 m), using straight fallback", _minLen, _center, _best select 1];
    private _dirF = _map get "fallback_dir_deg";
    _pts2d = [];
    for "_i" from 0 to (_target / 20) do {
        _pts2d pushBack [(_center select 0) + (sin _dirF) * _i * 20, (_center select 1) + (cos _dirF) * _i * 20, 0];
    };
};

// to ASL at float height, then cumulative distance
BO_Path = _pts2d apply { private _p = [_x select 0, _x select 1, 0]; _p set [2, (getTerrainHeightASL _p) + _h]; _p };
BO_PathCum = [0];
for "_i" from 1 to (count BO_Path - 1) do {
    BO_PathCum pushBack ((BO_PathCum select (_i - 1)) + ((BO_Path select (_i - 1)) distance2D (BO_Path select _i)));
};
BO_PathLen = BO_PathCum select -1;
diag_log format ["[BloonsOps] track built: %1 points, %2 m", count BO_Path, round BO_PathLen];
publicVariable "BO_Path";
publicVariable "BO_PathCum";
publicVariable "BO_PathLen";
