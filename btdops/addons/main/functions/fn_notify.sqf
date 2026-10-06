/*
    A short message on screen, with a sounds-sheet effect ("none" for silence).
*/
params ["_msg", ["_sound", "none"]];
if (!hasInterface) exitWith {};
systemChat _msg;
hintSilent _msg;
if (_sound != "none") then {[_sound, getPosATL player] call BTD_fnc_playSfx};
