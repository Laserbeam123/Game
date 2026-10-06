// Server: [player, tower] the AI gunner steps away and the player takes the gun.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_player", "_t", "_g"];
_player = _this select 0;
_t = _this select 1;
if (!isServer || { isNull _t } || { !(_t getVariable "bo_mannable") } || { isPlayer gunner _t }) exitWith {};
_g = gunner _t;
if (!isNull _g) then { moveOut _g; deleteVehicle _g };
_t setVariable ["bo_remanAt", (call BO_fnc_now) + 5];
[_player, "BO_fnc_moveInGunnerLocal", [_t]] call BO_fnc_netClient;
