/*
    Distance along the track -> [position ATL (z 0), heading in degrees].
*/
params ["_d"];
BTD_Track params ["_pts", "_cum", "_total"];
_d = (_d max 0) min _total;
private _n = count _pts - 1;
private _i = 0;
while {_i < _n - 1 && {(_cum#(_i + 1)) < _d}} do {_i = _i + 1};
private _a = _pts#_i;
private _b = _pts#(_i + 1);
private _seg = (_cum#(_i + 1)) - (_cum#_i);
private _f = 0;
if (_seg > 0) then {_f = (_d - (_cum#_i)) / _seg};
[_a vectorAdd ((_b vectorDiff _a) vectorMultiply _f), _a getDir _b]
