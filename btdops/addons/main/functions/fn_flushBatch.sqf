/*
    Server: send this tick's spawns, pops, slows, MOAB hp, shot effects and leaks to every client at once.
*/
if ((BTD_Batch findIf {count _x > 0}) < 0) exitWith {};
private _b = BTD_Batch;
BTD_Batch = [[], [], [], [], [], []];
_b remoteExecCall ["BTD_fnc_clientBatch", 0];
