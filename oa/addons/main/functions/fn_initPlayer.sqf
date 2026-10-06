// Client: called from the mission's init.sqf on machines with a player.
#include "\z\bloonsops_oa\addons\main\script.hpp"
if (isDedicated) exitWith {};
waitUntil { !isNull player && { !isNil "BO_SpawnPos" } && { !isNil "BO_PathLen" } && { !isNil "BO_State" } };
if (!isMultiplayer) then { { if (_x != player) then { deleteVehicle _x } } forEach (units group player) };
BO_LocalB = [];          // id -> [object, typeIdx, d0, t0, speed, phase, knot] or []
BO_LocalIds = [];
BO_Proj = [];            // [projectile, lastPosASL, explosive, untilTime]
BO_Near = objNull;
BO_FinalRound = CFG_FINAL_ROUND;
if (isNil "BO_ClientTowers") then { BO_ClientTowers = [] };
BO_LastTick = diag_tickTime;
player setPosATL [(BO_SpawnPos select 0) + random 4 - 2, (BO_SpawnPos select 1) + random 4 - 2, 0];
[player] call BO_fnc_setupUnit;
player addEventHandler ["Respawn", { [_this select 0] call BO_fnc_setupUnit }];
[] spawn BO_fnc_hud;
onEachFrame { call BO_fnc_clientTick };
["BO_fnc_syncJIP", [player]] call BO_fnc_netServer;
["Bloons are coming down the road. Open the Build Tablet (scroll menu) for Arma and Bloons TD towers, place them beside the track, then Start Next Round. You can't be hurt.", "round"] call BO_fnc_notify;
