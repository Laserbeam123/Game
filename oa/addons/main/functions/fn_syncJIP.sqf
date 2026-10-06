// Server: [player] send live bloons and every tower's paint/handlers to a player who just joined.
private ["_player", "_batch", "_e"];
_player = _this select 0;
if (!isServer || { isNil "BO_Live" }) exitWith {};
_batch = [];
{ _e = BO_Live select _x; _batch set [count _batch, [_x, _e select 0, _e select 1, _e select 2, _e select 3]] } forEach BO_Alive;
if (count _batch > 0) then { [_player, "BO_fnc_bloonLocal", [_batch]] call BO_fnc_netClient };
{ if (!isNull _x) then { [_player, "BO_fnc_towerLocal", [_x, _x getVariable "bo_tex"]] call BO_fnc_netClient } } forEach BO_TowerList;
