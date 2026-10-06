/*
    Client, tablet button: build towers row _rowId where the player is looking (within
    build_reach_m), or a few metres in front.
*/
params ["_rowId"];
private _eye = eyePos player;
private _end = _eye vectorAdd ((getCameraViewDirection player) vectorMultiply (BTD_Const get "build_reach_m"));
private _p = terrainIntersectAtASL [_eye, _end];
if (_p isEqualTo [0, 0, 0]) then {_p = AGLToASL (player getRelPos [5, 0])};
[_rowId, ASLToATL _p] remoteExecCall ["BTD_fnc_requestBuild", 2];
