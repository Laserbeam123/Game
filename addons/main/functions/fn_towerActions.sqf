// Every machine (remoteExec JIP from createTower): tower shots are visual only here too, and clients
// remember the tower for name tags and the "nearest tower" actions on the player.
params ["_t"];
if (isNull _t) exitWith {};
if (!isServer) then {
    {
        _x addEventHandler ["Fired", { params ["_u"]; if (!isPlayer (gunner vehicle _u) && !isPlayer _u) then { deleteVehicle (_this select 6) } }];
    } forEach ([_t, _t getVariable ["bo_heli", objNull]] + (_t getVariable ["bo_crew", []]) - [objNull]);
};
if (!hasInterface) exitWith {};
if (isNil "BO_ClientTowers") then { BO_ClientTowers = [] };
BO_ClientTowers = (BO_ClientTowers select { !isNull _x }) + [_t];
