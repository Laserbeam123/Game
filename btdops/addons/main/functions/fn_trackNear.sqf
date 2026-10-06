/*
    Shortest ground distance from a position to the track's centre line.
*/
params ["_p"];
private _pts = BTD_Track#0;
private _best = 1e10;
private _q = [_p#0, _p#1, 0];
for "_i" from 0 to (count _pts - 2) do {
    private _a = _pts#_i;
    private _ab = (_pts#(_i + 1)) vectorDiff _a;
    private _len2 = _ab vectorDotProduct _ab;
    private _t = 0;
    if (_len2 > 0) then {_t = (((_q vectorDiff _a) vectorDotProduct _ab) / _len2) max 0 min 1};
    _best = _best min (_q distance2D (_a vectorAdd (_ab vectorMultiply _t)));
};
_best
