/*
    Client: wait for the server, then set the player up: invincible, gliding, actions, HUD,
    drawing and shot following.
*/
waitUntil {!isNull player && {!isNil "BTD_ServerReady"} && {!isNil "BTD_Track"}};
BTD_CLive = createHashMap;
BTD_CPos = [];
BTD_Effects = [];
BTD_Shots = [];
BTD_GlideOn = true;
BTD_GlideVel = [0, 0, 0];
BTD_NearTower = -1;
BTD_ArtCache = createHashMap;
BTD_ArtPack = isClass (configFile >> "CfgPatches" >> "btdops_art");
diag_log format ["[BTDOPS] BTD6 art pack present: %1", BTD_ArtPack];

player allowDamage false;
player setPosATL ((missionNamespace getVariable ["BTD_SpawnPos", getPosATL player]) vectorAdd [random 4, random 4, 0]);
player addEventHandler ["Respawn", {(_this#0) allowDamage false}];
player addEventHandler ["FiredMan", {_this call BTD_fnc_onFiredMan}];
addMissionEventHandler ["EachFrame", {call BTD_fnc_glideTick; call BTD_fnc_shotTick}];
addMissionEventHandler ["Draw3D", {call BTD_fnc_draw3D}];

player addAction ["<t color='#ffd84a'>Build Tablet</t>", {call BTD_fnc_openTablet}, nil, 9, false, true, "", "!BTD_GameOver"];
player addAction ["<t color='#7cff7c'>Start next round</t>", {[] remoteExecCall ["BTD_fnc_requestRound", 2]}, nil, 8, false, true, "",
    "!BTD_RoundRunning && {!BTD_GameOver} && {BTD_Round < BTD_RoundCount}"];
player addAction ["Fast forward on/off", {[] remoteExecCall ["BTD_fnc_requestSpeed", 2]}, nil, 1, false, true, "", "!BTD_GameOver"];
player addAction ["Glide on/off", {BTD_GlideOn = !BTD_GlideOn; [["Glide off: walking.", "Glide on."] select BTD_GlideOn, "none"] call BTD_fnc_notify}, nil, 1, false, true];
call BTD_fnc_towerActions;

"btd_hud" cutRsc ["BTD_Hud", "PLAIN", 0, false];
[] remoteExecCall ["BTD_fnc_requestSnapshot", 2];
["Glide with WASD (Shift = faster). Scroll menu: Build Tablet, then Start next round.", "none"] call BTD_fnc_notify;

[] spawn {
    while {true} do {
        BTD_NearTower = call BTD_fnc_nearestTower;
        call BTD_fnc_hud;
        uiSleep 0.25;
    };
};
