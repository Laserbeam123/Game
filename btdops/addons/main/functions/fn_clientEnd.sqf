/*
    Server -> clients: the game is over.
*/
params ["_won"];
if (!hasInterface) exitWith {};
[["win", "lose"] select !_won, getPosATL player] call BTD_fnc_playSfx;
titleText [["<t size='3' color='#ff5050'>GAME OVER</t><br/>The bloons got through.", "<t size='3' color='#7cff7c'>VICTORY!</t><br/>Every round cleared."] select _won, "PLAIN", 1, true, true];
if (!isMultiplayer && {!(missionNamespace getVariable ["BTD_SelfTest", false])}) then {
    _won spawn {
        uiSleep 8;
        [["EveryoneLost", "EveryoneWon"] select _this, _this] call BIS_fnc_endMission;
    };
};
