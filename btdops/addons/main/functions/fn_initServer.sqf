/*
    Server: lay the track, hide clutter on it, reset the shared state and start the loop.
*/
params ["_mapId"];
private _map = BTD_Maps get _mapId;
BTD_Track = [_map] call BTD_fnc_buildTrack;
publicVariable "BTD_Track";
BTD_Track params ["_pts", "_cum", "_total"];

// Hide trees, rocks and buildings near the track; mark it with cones and a map line; log the slope.
private _clear = BTD_Const get "track_clear_m";
private _maxSlope = 0;
private _lastH = -1;
private _step = 5;
for "_d" from 0 to _total step _step do {
    ([_d] call BTD_fnc_trackPos) params ["_p", "_dir"];
    { _x hideObjectGlobal true } forEach (nearestTerrainObjects [_p, [], _clear, false, true]);
    private _h = getTerrainHeightASL _p;
    if (_lastH >= 0) then {_maxSlope = _maxSlope max (abs (_h - _lastH) / _step)};
    _lastH = _h;
    if ((round _d) % 15 == 0) then {
        {
            private _c = createVehicle ["RoadCone_F", _p getPos [3.5, _dir + _x], [], 0, "CAN_COLLIDE"];
            _c enableSimulationGlobal false;
            _c allowDamage false;
        } forEach [90, -90];
    };
};
diag_log format ["[BTDOPS] track %1 m, %2 points, track slope max %3 (rise per metre)", round _total, count _pts, _maxSlope toFixed 2];
private _mk = createMarkerLocal ["btd_track", _pts#0];
_mk setMarkerShapeLocal "polyline";
_mk setMarkerColorLocal "ColorRed";
_mk setMarkerPolyline (flatten (_pts apply {[_x#0, _x#1]}));
private _sp = (_map get "center") vectorAdd ((_map get "spawn") + [0]);
createMarker ["respawn_west", _sp];
BTD_SpawnPos = _sp;
publicVariable "BTD_SpawnPos";

BTD_Live = createHashMap;
BTD_NextId = 1;
BTD_Batch = [[], [], [], [], [], []];
BTD_Schedule = [];
BTD_TowerObjs = createHashMap;
BTD_TowerKey = 0;
BTD_Dirty = false;
BTD_Clock = [[time, serverTime] select isMultiplayer, 0, 1];
BTD_Cash = BTD_Const get "start_cash";
BTD_Lives = BTD_Const get "start_lives";
BTD_Round = 0;
BTD_RoundRunning = false;
BTD_GameOver = false;
BTD_TowerList = [];
{ publicVariable _x } forEach ["BTD_Clock", "BTD_Cash", "BTD_Lives", "BTD_Round", "BTD_RoundRunning", "BTD_GameOver", "BTD_TowerList"];
BTD_ServerReady = true;
publicVariable "BTD_ServerReady";

[] spawn {
    private _tick = BTD_Const get "server_tick_s";
    while {!BTD_GameOver} do {
        call BTD_fnc_serverTick;
        uiSleep _tick;
    };
    call BTD_fnc_flushBatch;
};
