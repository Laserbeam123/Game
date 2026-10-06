// Every machine (remoteExec JIP from createTower): tower shots are visual only here too, and clients
// remember the tower for name tags and the "nearest tower" actions on the player.
params ["_t"];
if (isNull _t) exitWith {};
if (!isServer) then {
    {
        _x addEventHandler ["Fired", { params ["_u"]; if (!isPlayer (gunner vehicle _u) && !isPlayer _u) then { deleteVehicle (_this select 6) } }];
    } forEach ([_t, _t getVariable ["bo_heli", objNull]] + (_t getVariable ["bo_crew", []]) - [objNull]);
};
if (!hasInterface) exitWith {};
if (isNil "BO_ClientTowers") then { BO_ClientTowers = [] };
BO_ClientTowers = (BO_ClientTowers select { !isNull _x }) + [_t];
// With the player's BTD6 art pack, a BLOONS TD tower shows as its BTD6 cut-out: the spheres are hidden here only.
private _type = _t getVariable ["bo_type", ""];
if (_type in BO_Btd6Has) then {
    if (isNil "BO_Boards") then { BO_Boards = [] };
    { hideObject _x } forEach ([_t] + attachedObjects _t);
    private _size = BO_Cfg get "btd6_tower_size_m";
    private _c = getPosASL _t;
    _c set [2, (getTerrainHeightASL _c) + _size / 2];
    BO_Boards pushBack [[BO_Btd6Art get _type, _c, _size] call BO_fnc_billboard, _t, _c];
};
