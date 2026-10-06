/*
    Server: the game is won (all rounds cleared) or lost (no lives left).
*/
params ["_won"];
if (BTD_GameOver) exitWith {};
BTD_GameOver = true;
BTD_Schedule = [];
{ publicVariable _x } forEach ["BTD_GameOver", "BTD_Lives", "BTD_Cash"];
call BTD_fnc_flushBatch;
[_won] remoteExecCall ["BTD_fnc_clientEnd", 0];
diag_log format ["[BTDOPS] game over, won %1, round %2, lives %3", _won, BTD_Round, BTD_Lives];
if (isMultiplayer && {!(missionNamespace getVariable ["BTD_SelfTest", false])}) then {
    _won spawn {
        uiSleep 10;
        (["EveryoneLost", "EveryoneWon"] select _this) call BIS_fnc_endMissionServer;
    };
};
