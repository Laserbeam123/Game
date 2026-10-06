/*
    Server: the tower's objects. ARMA rows get the real Arma object and an AI crew that never
    picks its own targets; BTD6 rows get a grass cutter (the monkey itself is a billboard drawn
    by each client). Returns [vehicle or objNull, crew unit or objNull].
*/
params ["_rowId", "_pos", "_dir"];
private _row = BTD_Towers get _rowId;
if (_row get "section" == "BTD6") exitWith {
    private _cut = createVehicle ["Land_ClutterCutter_medium_F", _pos, [], 0, "CAN_COLLIDE"];
    [_cut, objNull]
};
private _cls = _row get "object_class";
private _crew = _row get "crew_class";
private _veh = objNull;
if (_cls != "none") then {
    _veh = createVehicle [_cls, _pos, [], 0, "CAN_COLLIDE"];
    _veh setDir _dir;
    _veh allowDamage false;
    _veh lock 2;
    _veh addEventHandler ["Fired", {
        params ["_v", "", "", "", "_ammo", "", "_proj"];
        if (_ammo isKindOf ["ShellBase", configFile >> "CfgAmmo"]) then {deleteVehicle _proj};
        _v setVehicleAmmo 1;
    }];
};
private _unit = objNull;
if (_crew != "none") then {
    private _grp = createGroup [west, true];
    _unit = _grp createUnit [_crew, _pos, [], 0, "CAN_COLLIDE"];
    _unit allowDamage false;
    _grp setCombatMode "BLUE";
    _grp setBehaviour "AWARE";
    { _unit disableAI _x } forEach ["PATH", "AUTOTARGET", "TARGET", "AUTOCOMBAT"];
    if (isNull _veh) then {
        _unit setDir _dir;
        _unit setPosATL _pos;
        _unit setUnitPos "DOWN";
        _unit addEventHandler ["Fired", {(_this#0) setAmmo [_this#1, 1000]}];
    } else {
        _unit moveInGunner _veh;
    };
};
[_veh, _unit]
