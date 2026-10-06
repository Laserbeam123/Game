// [distance along track] -> position ASL (at bloon float height) on the track.
params ["_d"];
private _pts = BO_Path;
private _cum = BO_PathCum;
private _n = count _pts;
if (_d <= 0) exitWith { _pts select 0 };
if (_d >= (_cum select (_n - 1))) exitWith { _pts select (_n - 1) };
// binary search for the segment holding _d
private _lo = 0;
private _hi = _n - 1;
while { _hi - _lo > 1 } do {
    private _mid = floor ((_lo + _hi) / 2);
    if ((_cum select _mid) <= _d) then { _lo = _mid } else { _hi = _mid };
};
private _a = _pts select _lo;
private _b = _pts select _hi;
private _seg = (_cum select _hi) - (_cum select _lo);
private _f = if (_seg > 0) then { (_d - (_cum select _lo)) / _seg } else { 0 };
_a vectorAdd ((_b vectorDiff _a) vectorMultiply _f)
