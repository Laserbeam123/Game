// [distance along track] -> position ASL (at bloon float height) on the track.
private ["_d", "_n", "_lo", "_hi", "_mid", "_a", "_b", "_seg", "_f"];
_d = _this select 0;
_n = count BO_Path;
if (_d <= 0) exitWith { +(BO_Path select 0) };
if (_d >= (BO_PathCum select (_n - 1))) exitWith { +(BO_Path select (_n - 1)) };
_lo = 0;
_hi = _n - 1;
while { _hi - _lo > 1 } do {
    _mid = floor ((_lo + _hi) / 2);
    if ((BO_PathCum select _mid) <= _d) then { _lo = _mid } else { _hi = _mid };
};
_a = BO_Path select _lo;
_b = BO_Path select _hi;
_seg = (BO_PathCum select _hi) - (BO_PathCum select _lo);
_f = 0;
if (_seg > 0) then { _f = (_d - (BO_PathCum select _lo)) / _seg };
[(_a select 0) + ((_b select 0) - (_a select 0)) * _f, (_a select 1) + ((_b select 1) - (_a select 1)) * _f, (_a select 2) + ((_b select 2) - (_a select 2)) * _f]
