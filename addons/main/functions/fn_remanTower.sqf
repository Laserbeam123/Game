// Server: an AI gunner returns to an empty mannable tower.
params ["_t"];
if (isNull _t || { !isNull gunner _t }) exitWith {};
private _row = BO_Towers get (_t getVariable "bo_type");
private _g = (createGroup [west, true]) createUnit [_row get "crew_class", getPosATL _t, [], 0, "CAN_COLLIDE"];
_g allowDamage false;
_g moveInGunner _t;
_t setVariable ["bo_crew", [_g], true];
_t setVariable ["bo_remanAt", (call BO_fnc_now) + 5];
