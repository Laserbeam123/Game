/*
    Game clock shared by every machine. Fast forward changes the rate, never jumps it.
    Returns: game seconds.
*/
private _real = [time, serverTime] select isMultiplayer;
if (isNil "BTD_Clock") exitWith {_real};
BTD_Clock params ["_r0", "_g0", "_mult"];
_g0 + (_real - _r0) * _mult
