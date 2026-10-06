// Server: a player asked to build tower _id at _posATL. Checks cash and placement.
params ["_player", "_id", "_posATL"];
if (!isServer || { BO_State != "play" }) exitWith {};
private _row = BO_Towers getOrDefault [_id, createHashMap];
if (count _row == 0) exitWith {};
private _fail = { [_this, "error"] remoteExecCall ["BO_fnc_notify", _player] };
if (BO_Cash < (_row get "cost")) exitWith { format ["Need $%1 for %2 (you have $%3).", _row get "cost", _row get "name", BO_Cash] call _fail };
if (surfaceIsWater _posATL) exitWith { "Can't build on water." call _fail };

// distance to the track (nearest segment) and the direction to face it
private _best = 1e9;
private _face = [0, 0, 0];
for "_i" from 1 to (count BO_Path - 1) do {
    private _a = BO_Path select (_i - 1);
    private _b = BO_Path select _i;
    private _ab = [(_b select 0) - (_a select 0), (_b select 1) - (_a select 1)];
    private _len2 = ((_ab select 0) ^ 2 + (_ab select 1) ^ 2) max 0.001;
    private _f = ((((_posATL select 0) - (_a select 0)) * (_ab select 0) + ((_posATL select 1) - (_a select 1)) * (_ab select 1)) / _len2) max 0 min 1;
    private _q = [(_a select 0) + (_ab select 0) * _f, (_a select 1) + (_ab select 1) * _f, 0];
    private _dist = _q distance2D _posATL;
    if (_dist < _best) then { _best = _dist; _face = _q };
};
if (_best < (BO_Cfg get "track_clearance")) exitWith { format ["Too close to the track (%1 m). Step back from the road.", round _best] call _fail };
if (BO_TowerList findIf { !isNull _x && { (_x distance2D _posATL) < (BO_Cfg get "tower_spacing") } } >= 0) exitWith { "Too close to another tower." call _fail };

BO_Cash = BO_Cash - (_row get "cost");
publicVariable "BO_Cash";
[_id, _posATL, _posATL getDir _face] call BO_fnc_createTower;
[format ["%1 built %2.", name _player, _row get "name"], "info"] remoteExecCall ["BO_fnc_notify", 0];
