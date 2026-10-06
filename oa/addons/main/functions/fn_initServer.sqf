// Server: build the track on Takistan and start the game state. Called from the mission's init.sqf.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_map"];
if (!isServer) exitWith {};
_map = [];
{ if ((_x select M_EDITION) == "oa" && { (_x select M_WORLD) == worldName }) then { _map = _x } } forEach BO_Maps;
if (count _map == 0) exitWith { diag_log format ["[BloonsOps] no OA maps row for world %1", worldName] };
[_map] call BO_fnc_buildPath;
[] call BO_fnc_drawTrack;

BO_Live = [];          // id -> [typeIdx, d0, t0, speedMult, slowUntil], or [] once popped/leaked
BO_Alive = [];         // ids still on the track
BO_NextId = 0;
BO_SpawnQueue = [];    // [id, typeIdx, d0, t0, mult]
BO_PopQueue = [];
BO_LeakQueue = [];
BO_RebaseQueue = [];   // [id, d0, t0, mult]
BO_TowerList = [];
BO_CashDirty = false;
BO_Cash = CFG_START_CASH;
BO_Lives = CFG_START_LIVES;
BO_Round = 0;
BO_RoundActive = false;
{ publicVariable _x } forEach ["BO_Cash", "BO_Lives", "BO_Round", "BO_RoundActive"];
BO_State = "play";
publicVariable "BO_State";
diag_log format ["[BloonsOps] OA server ready on %1, track %2 m", worldName, round BO_PathLen];
[] spawn BO_fnc_serverTick;
