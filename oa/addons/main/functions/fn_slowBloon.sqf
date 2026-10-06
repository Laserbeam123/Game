// Server: [id, mult, secs] slow or freeze a bloon and re-base it at its current distance.
private ["_id", "_e", "_now", "_m", "_until", "_d"];
_id = _this select 0;
if (_id >= count BO_Live) exitWith {};
_e = BO_Live select _id;
if (count _e == 0) exitWith {};
_now = call BO_fnc_now;
_m = (_this select 1) min (_e select 3);
_until = (_now + (_this select 2)) max (_e select 4);
_d = [_e, _now] call BO_fnc_bloonDist;
BO_Live set [_id, [_e select 0, _d, _now, _m, _until]];
BO_RebaseQueue set [count BO_RebaseQueue, [_id, _d, _now, _m]];
