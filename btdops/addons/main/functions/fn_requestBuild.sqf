/*
    Client -> server: build towers row _rowId at _pos (ATL), if there is cash and room.
*/
params ["_rowId", "_pos"];
if (!isServer || {BTD_GameOver}) exitWith {};
private _to = [0, remoteExecutedOwner] select isRemoteExecuted;
private _row = BTD_Towers getOrDefault [_rowId, createHashMap];
if (count _row == 0) exitWith {};
_pos = [_pos#0, _pos#1, 0];
private _cost = _row get "cost";
private _why = "";
if (BTD_Cash < _cost) then {_why = format ["Not enough cash for the %1 ($%2).", _row get "name", _cost]};
if (_why == "" && {([_pos] call BTD_fnc_trackNear) < (BTD_Const get "build_min_track_m")}) then {_why = "Too close to the track."};
if (_why == "" && {(BTD_TowerList findIf {((_x#3) distance2D _pos) < (BTD_Const get "build_min_tower_m")}) >= 0}) then {_why = "Too close to another tower."};
if (_why != "") exitWith {[_why, "none"] remoteExecCall ["BTD_fnc_notify", _to]};

// face the nearest stretch of track
private _best = 1e10;
private _face = _pos;
for "_d" from 0 to (BTD_Track#2) step 4 do {
    private _p = ([_d] call BTD_fnc_trackPos)#0;
    if ((_p distance2D _pos) < _best) then {_best = _p distance2D _pos; _face = _p};
};
private _dir = _pos getDir _face;
BTD_Cash = BTD_Cash - _cost;
publicVariable "BTD_Cash";
BTD_TowerKey = BTD_TowerKey + 1;
private _key = BTD_TowerKey;
BTD_TowerObjs set [_key, [[_rowId, _pos, _dir] call BTD_fnc_createTower, 0]];
BTD_TowerList pushBack [_key, _rowId, false, _pos, _dir, _cost];
publicVariable "BTD_TowerList";
(BTD_Batch#4) pushBack ["place", _pos, _pos, "place", 0];
_key
