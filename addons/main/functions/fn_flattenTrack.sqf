// Server: smooth Altis around the track into gentle rolling ground (not superflat). For every terrain
// grid point within flatten_radius_m of the track: new height = local ground level (track heights averaged
// over flatten_window_m) + flatten_keep * the original bump, capped at flatten_max_dev_m, faded out at the edge.
params ["_pts"];   // 2D track points [[x, y, z], ...]
private _R = BO_Cfg get "flatten_radius_m";
private _keep = BO_Cfg get "flatten_keep";
private _maxDev = BO_Cfg get "flatten_max_dev_m";
private _win = BO_Cfg get "flatten_window_m";
private _grid = (getTerrainInfo) select 2;
if (isNil "_grid" || { _grid <= 0 }) then { _grid = 7.5 };

// samples every ~grid/2 metres along the track, with their local ground level
private _samples = [];
for "_i" from 1 to (count _pts - 1) do {
    private _a = _pts select (_i - 1);
    private _b = _pts select _i;
    private _n = ceil (((_a distance2D _b) / (_grid / 2)) max 1);
    for "_k" from 0 to (_n - 1) do {
        private _p = _a vectorAdd ((_b vectorDiff _a) vectorMultiply (_k / _n));
        _samples pushBack [_p select 0, _p select 1, getTerrainHeightASL [_p select 0, _p select 1]];
    };
};
if (_samples isEqualTo []) exitWith {};
private _span = ceil (_win / (_grid / 2) / 2);
private _base = [];
{
    private _from = (_forEachIndex - _span) max 0;
    private _to = (_forEachIndex + _span) min (count _samples - 1);
    private _sum = 0;
    for "_j" from _from to _to do { _sum = _sum + ((_samples select _j) select 2) };
    _base pushBack (_sum / (_to - _from + 1));
} forEach _samples;

// nearest sample for every grid point in reach
private _cells = createHashMap;   // "gx,gy" -> [dist, baseHeight]
private _cellsR = ceil (_R / _grid);
{
    private _sx = _x select 0;
    private _sy = _x select 1;
    private _bh = _base select _forEachIndex;
    private _gx0 = round (_sx / _grid);
    private _gy0 = round (_sy / _grid);
    for "_gx" from (_gx0 - _cellsR) to (_gx0 + _cellsR) do {
        for "_gy" from (_gy0 - _cellsR) to (_gy0 + _cellsR) do {
            private _dist = [_gx * _grid, _gy * _grid] distance2D [_sx, _sy];
            if (_dist <= _R) then {
                private _key = format ["%1,%2", _gx, _gy];
                private _old = _cells getOrDefault [_key, [1e9, 0]];
                if (_dist < (_old select 0)) then { _cells set [_key, [_dist, _bh]] };
            };
        };
    };
} forEach _samples;

private _out = [];
{
    (_x splitString ",") params ["_gxs", "_gys"];
    private _px = (parseNumber _gxs) * _grid;
    private _py = (parseNumber _gys) * _grid;
    _y params ["_dist", "_bh"];
    private _h0 = getTerrainHeightASL [_px, _py];
    private _target = _bh + (((_h0 - _bh) * _keep) max -_maxDev min _maxDev);
    private _w = if (_dist <= _R * 0.7) then { 1 } else { 1 - (_dist - _R * 0.7) / (_R * 0.3) };
    _out pushBack [_px, _py, _h0 + (_target - _h0) * _w];
} forEach _cells;
setTerrainHeight [_out, true];
diag_log format ["[BloonsOps] smoothed %1 terrain points around the track (grid %2 m)", count _out, _grid];
