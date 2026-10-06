// Server: build the track and start the game state. Called from the mission's initServer.sqf.
if (!isServer) exitWith {};
private _map = (values BO_Maps) select { (_x get "world") == worldName };
if (_map isEqualTo []) exitWith { diag_log format ["[BloonsOps] no maps row for world %1", worldName] };
[_map select 0] call BO_fnc_buildPath;
[] call BO_fnc_drawTrack;

BO_Live = createHashMap;     // id -> [type, d0, t0]
BO_NextId = 0;
BO_SpawnQueue = [];          // [id, type, d0, t0] waiting to be broadcast
BO_PopQueue = [];            // popped ids waiting to be broadcast
BO_LeakQueue = [];           // leaked ids waiting to be broadcast
BO_TowerList = [];
BO_CashDirty = false;
BO_Cash = BO_Cfg get "start_cash";
BO_Lives = BO_Cfg get "start_lives";
BO_Round = 0;
BO_RoundActive = false;
{ publicVariable _x } forEach ["BO_Cash", "BO_Lives", "BO_Round", "BO_RoundActive"];
missionNamespace setVariable ["BO_State", "play", true];
diag_log format ["[BloonsOps] server ready on %1, track %2 m", worldName, round BO_PathLen];
[] spawn BO_fnc_serverTick;
