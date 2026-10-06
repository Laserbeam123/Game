// Server: [player, towerIdx, posATL] check cash and placement, then build.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_player", "_idx", "_pos", "_row", "_best", "_face", "_i", "_a", "_b", "_abx", "_aby", "_len2", "_f", "_q", "_dist", "_near", "_fail", "_dir"];
_player = _this select 0;
_idx = _this select 1;
_pos = _this select 2;
if (!isServer || { BO_State != "play" } || { _idx < 0 } || { _idx >= count BO_Towers }) exitWith {};
_row = TOWER(_idx);
_fail = { [_player, "BO_fnc_notify", [_this, "error"]] call BO_fnc_netClient };
if (BO_Cash < (_row select T_COST)) exitWith { format ["Need $%1 for %2 (you have $%3).", _row select T_COST, _row select T_OA_NAME, BO_Cash] call _fail };
if (surfaceIsWater _pos) exitWith { "Can't build on water." call _fail };
_best = 1e9;
_face = _pos;
for "_i" from 1 to (count BO_Path - 1) do {
    _a = BO_Path select (_i - 1);
    _b = BO_Path select _i;
    _abx = (_b select 0) - (_a select 0);
    _aby = (_b select 1) - (_a select 1);
    _len2 = (_abx ^ 2 + _aby ^ 2) max 0.001;
    _f = ((((_pos select 0) - (_a select 0)) * _abx + ((_pos select 1) - (_a select 1)) * _aby) / _len2) max 0 min 1;
    _q = [(_a select 0) + _abx * _f, (_a select 1) + _aby * _f, 0];
    _dist = [_q, _pos] call BO_fnc_dist2D;
    if (_dist < _best) then { _best = _dist; _face = _q };
};
if (_best < CFG_TRACK_CLEARANCE) exitWith { format ["Too close to the track (%1 m). Step back from the road.", round _best] call _fail };
_near = false;
{ if (!isNull _x && { ([getPosATL _x, _pos] call BO_fnc_dist2D) < CFG_TOWER_SPACING }) then { _near = true } } forEach BO_TowerList;
if (_near) exitWith { "Too close to another tower." call _fail };
BO_Cash = BO_Cash - (_row select T_COST);
publicVariable "BO_Cash";
_dir = ((_face select 0) - (_pos select 0)) atan2 ((_face select 1) - (_pos select 1));
[_idx, _pos, _dir] call BO_fnc_createTower;
["BO_fnc_notify", [format ["%1 built %2.", name _player, _row select T_OA_NAME], "info"]] call BO_fnc_netAll;
