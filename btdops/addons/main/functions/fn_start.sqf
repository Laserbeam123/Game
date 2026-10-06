/*
    Mission entry (each scenario's init.sqf): ["altis_airfield", "solo"|"coop"|"selftest"] spawn BTD_fnc_start.
*/
params ["_mapId", "_kind"];
BTD_SelfTest = _kind == "selftest";
if (isServer) then {[_mapId] call BTD_fnc_initServer};
if (hasInterface) then {[] spawn BTD_fnc_initPlayer};
if (BTD_SelfTest && {isServer}) then {[] spawn BTD_fnc_selfTest};
