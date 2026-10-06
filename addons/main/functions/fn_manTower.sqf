// Server: the player takes the gun; the AI gunner steps away until the player leaves.
params ["_player", "_t"];
if (!isServer || { isNull _t } || { !(_t getVariable ["bo_mannable", false]) } || { isPlayer gunner _t }) exitWith {};
private _g = gunner _t;
if (!isNull _g) then {
    moveOut _g;
    deleteVehicle _g;
};
_t setVariable ["bo_remanAt", (call BO_fnc_now) + 5];
[_t] remoteExecCall ["BO_fnc_moveInGunnerLocal", _player];
