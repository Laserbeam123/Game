// Server: which stretches of track [[dFrom, dTo], ...] lie within _range of _pos. Lets towers target by
// comparing track distances instead of 3D positions every tick.
params ["_pos", "_range"];
private _out = [];
private _open = -1;
private _step = 2;
private _d = 0;
while { _d <= BO_PathLen } do {
    private _in = (([_d] call BO_fnc_pathPos) distance2D _pos) <= _range;
    if (_in && _open < 0) then { _open = _d };
    if (!_in && _open >= 0) then { _out pushBack [_open, _d - _step]; _open = -1 };
    _d = _d + _step;
};
if (_open >= 0) then { _out pushBack [_open, BO_PathLen] };
_out
