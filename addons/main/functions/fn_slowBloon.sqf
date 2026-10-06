// Server: slow (or freeze, mult 0) bloon _id for _secs. The bloon is re-based at its current distance so
// every machine keeps computing the same position; clients get the new base in the next tick's batch.
params ["_id", "_mult", "_secs"];
private _e = BO_Live getOrDefault [_id, []];
if (_e isEqualTo []) exitWith {};
private _now = call BO_fnc_now;
_e params ["_type", "_d0", "_t0", "_m0", "_u0"];
private _m = _mult min _m0;
private _until = (_now + _secs) max _u0;
private _d = [_e, _now] call BO_fnc_bloonDist;
BO_Live set [_id, [_type, _d, _now, _m, _until]];
BO_RebaseQueue pushBack [_id, _d, _now, _m];
