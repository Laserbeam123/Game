/*
    Client -> server: buy tower _key's upgrade.
*/
params ["_key"];
if (!isServer || {BTD_GameOver}) exitWith {};
private _to = [0, remoteExecutedOwner] select isRemoteExecuted;
private _i = BTD_TowerList findIf {(_x#0) == _key};
if (_i < 0) exitWith {};
private _t = BTD_TowerList#_i;
if (_t#2) exitWith {["Already upgraded.", "none"] remoteExecCall ["BTD_fnc_notify", _to]};
private _u = BTD_Upgrades get ((BTD_Towers get (_t#1)) get "upgrade");
if (BTD_Cash < (_u get "cost")) exitWith {[format ["%1 costs $%2.", _u get "name", _u get "cost"], "none"] remoteExecCall ["BTD_fnc_notify", _to]};
BTD_Cash = BTD_Cash - (_u get "cost");
_t set [2, true];
_t set [5, (_t#5) + (_u get "cost")];
publicVariable "BTD_Cash";
publicVariable "BTD_TowerList";
(BTD_Batch#4) pushBack ["place", _t#3, _t#3, "place", 0];
[format ["Upgraded: %1", _u get "name"], "none"] remoteExecCall ["BTD_fnc_notify", _to];
