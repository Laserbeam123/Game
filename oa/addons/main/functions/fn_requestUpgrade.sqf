// Server: [player, tower] pay for and apply the tower's upgrade row.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_player", "_t", "_up", "_s"];
_player = _this select 0;
_t = _this select 1;
if (!isServer || { BO_State != "play" } || { isNull _t } || { _t getVariable "bo_upgraded" }) exitWith {};
_up = BO_Upgrades select ((TOWER(_t getVariable "bo_type")) select T_UPGRADE);
if (BO_Cash < (_up select U_COST)) exitWith { [_player, "BO_fnc_notify", [format ["Need $%1 for %2.", _up select U_COST, _up select U_NAME], "error"]] call BO_fnc_netClient };
BO_Cash = BO_Cash - (_up select U_COST);
publicVariable "BO_Cash";
_s = _t getVariable "bo_stats";
_s set [T_RANGE_M, (_s select T_RANGE_M) * (_up select U_RANGE_MULT)];
_s set [T_FIRE_INTERVAL_S, (_s select T_FIRE_INTERVAL_S) * (_up select U_INTERVAL_MULT)];
_s set [T_DAMAGE, (_s select T_DAMAGE) + (_up select U_DAMAGE_ADD)];
_s set [T_PIERCE, (_s select T_PIERCE) + (_up select U_PIERCE_ADD)];
_s set [T_SPLASH_M, (_s select T_SPLASH_M) + (_up select U_SPLASH_ADD)];
_s set [T_INCOME, (_s select T_INCOME) + (_up select U_INCOME_ADD)];
if (_up select U_GRANTS_LEAD) then { _s set [T_POPS_LEAD, true] };
if (_up select U_GRANTS_CAMO) then { _s set [T_SEES_CAMO, true] };
_t setVariable ["bo_cover", [getPosATL _t, _s select T_RANGE_M] call BO_fnc_towerCoverage];
_t setVariable ["bo_upgraded", true, true];
_t setVariable ["bo_spent", (_t getVariable "bo_spent") + (_up select U_COST), true];
["BO_fnc_notify", [format ["%1 upgraded: %2!", name _player, _up select U_NAME], "info"]] call BO_fnc_netAll;
