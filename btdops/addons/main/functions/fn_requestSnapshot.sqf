/*
    Client -> server on join: send that client every live bloon.
*/
if (!isServer) exitWith {};
private _to = [0, remoteExecutedOwner] select isRemoteExecuted;
private _all = [];
{ _all pushBack ([_x] + _y) } forEach BTD_Live;
[_all] remoteExecCall ["BTD_fnc_clientSnapshot", _to];
