// Server: [tower] an AI gunner returns to an empty mannable gun.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_t", "_g"];
_t = _this select 0;
if (isNull _t || { !isNull gunner _t }) exitWith {};
_g = (createGroup west) createUnit [(TOWER(_t getVariable "bo_type")) select T_OA_CREW_CLASS, getPosATL _t, [], 0, "CAN_COLLIDE"];
_g allowDamage false;
_g moveInGunner _t;
_t setVariable ["bo_crew", [_g], true];
_t setVariable ["bo_remanAt", (call BO_fnc_now) + 5];
