// Server: [player, tower] refund sell_ratio of what was spent, remove everything it spawned.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_player", "_t", "_refund"];
_player = _this select 0;
_t = _this select 1;
if (!isServer || { isNull _t } || { !(_t in BO_TowerList) }) exitWith {};
if (isPlayer gunner _t) exitWith { [_player, "BO_fnc_notify", ["Get off the gun before selling it.", "error"]] call BO_fnc_netClient };
_refund = floor ((_t getVariable "bo_spent") * CFG_SELL_RATIO);
BO_Cash = BO_Cash + _refund;
publicVariable "BO_Cash";
BO_TowerList = BO_TowerList - [_t];
{ deleteVehicle _x } forEach (_t getVariable "bo_crew");
{ deleteVehicle _x } forEach (_t getVariable "bo_parts");
deleteVehicle _t;
[_player, "BO_fnc_notify", [format ["Sold for $%1.", _refund], "info"]] call BO_fnc_netClient;
