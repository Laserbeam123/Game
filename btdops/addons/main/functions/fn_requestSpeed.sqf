/*
    Client -> server: toggle fast forward. The clock keeps running from where it is.
*/
if (!isServer || {BTD_GameOver}) exitWith {};
private _now = call BTD_fnc_now;
private _mult = [BTD_Const get "fast_forward_mult", 1] select ((BTD_Clock#2) > 1);
BTD_Clock = [[time, serverTime] select isMultiplayer, _now, _mult];
publicVariable "BTD_Clock";
[format ["Game speed x%1", _mult], "none"] remoteExecCall ["BTD_fnc_notify", 0];
