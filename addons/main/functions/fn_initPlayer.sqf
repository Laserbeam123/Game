// Client: called from the mission's initPlayerLocal.sqf.
if (!hasInterface) exitWith {};
waitUntil { !isNull player && { !isNil "BO_SpawnPos" } && { !isNil "BO_PathLen" } && { !isNil "BO_State" } };
if (!isMultiplayer) then {
    // single player: the other co-op slots would be AI squadmates; remove them
    { if (_x != player) then { deleteVehicle _x } } forEach (units group player);
};
BO_LocalBloons = createHashMap;   // id -> [object, type, d0, t0, speed, phase]
BO_Proj = [];                     // tracked player projectiles [projectile, lastPosASL, popsLead]
BO_Near = objNull;
BO_Fx = [];                       // shot streaks [from, to, rgba, untilTick]
if (isNil "BO_ClientTowers") then { BO_ClientTowers = [] };
player setPosATL (BO_SpawnPos vectorAdd [random 4 - 2, random 4 - 2, 0]);
player setDir (player getDir (BO_Path select -1));
[player] call BO_fnc_setupUnit;
[] spawn BO_fnc_hud;
addMissionEventHandler ["EachFrame", { call BO_fnc_clientTick }];
addMissionEventHandler ["Draw3D", { call BO_fnc_draw3D }];
[player] remoteExecCall ["BO_fnc_syncJIP", 2];
["Bloons are coming down the road. Open the Build Tablet (scroll menu) for Arma and Bloons TD towers, place them beside the track, then Start Next Round. You can't be hurt.", "round"] call BO_fnc_notify;
