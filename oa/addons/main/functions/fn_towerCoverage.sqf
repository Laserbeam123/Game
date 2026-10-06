// Server: [pos, range] -> stretches of track [[dFrom, dTo], ...] within range.
private ["_pos", "_range", "_out", "_open", "_d", "_in"];
_pos = _this select 0;
_range = _this select 1;
_out = [];
_open = -1;
_d = 0;
while { _d <= BO_PathLen } do {
    _in = ([[_d] call BO_fnc_pathPos, _pos] call BO_fnc_dist2D) <= _range;
    if (_in && _open < 0) then { _open = _d };
    if (!_in && _open >= 0) then { _out set [count _out, [_open, _d - 2]]; _open = -1 };
    _d = _d + 2;
};
if (_open >= 0) then { _out set [count _out, [_open, BO_PathLen]] };
_out
