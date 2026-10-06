// Server: spawn a tower from its towers row. Returns the anchor object (the gun, or a sandbag for infantry).
params ["_id", "_posATL", "_dir"];
private _row = BO_Towers get _id;
private _grp = createGroup [west, true];
private _crew = [];
private _anchor = objNull;
private _noBullets = {
    // muzzle flash and sound only: the real projectile is removed, damage is scripted
    _this addEventHandler ["Fired", { params ["_u"]; if (!isPlayer (gunner vehicle _u) && !isPlayer _u) then { deleteVehicle (_this select 6) } }];
};

if ((_row get "kind") == "static") then {
    _anchor = createVehicle [_row get "object_class", _posATL, [], 0, "CAN_COLLIDE"];
    _anchor setDir _dir;
    _anchor allowDamage false;
    _anchor call _noBullets;
    private _g = _grp createUnit [_row get "crew_class", _posATL, [], 0, "CAN_COLLIDE"];
    _g moveInGunner _anchor;
    _g allowDamage false;
    _crew pushBack _g;
} else {
    _anchor = createVehicle ["Land_BagFence_Round_F", _posATL, [], 0, "CAN_COLLIDE"];
    _anchor setDir (_dir + 180);
    _anchor allowDamage false;
    for "_i" from 1 to (_row get "crew_count") do {
        private _p = _anchor getPos [1.5, _dir + 180 + (_i - ((_row get "crew_count") + 1) / 2) * 35];
        private _u = _grp createUnit [_row get "crew_class", _p, [], 0, "CAN_COLLIDE"];
        _u setDir _dir;
        _u disableAI "PATH";
        _u allowDamage false;
        _u call _noBullets;
        _crew pushBack _u;
    };
};
_grp setBehaviour "AWARE";

private _stats = +_row;
_anchor setVariable ["bo_stats", _stats];
_anchor setVariable ["bo_crew", _crew, true];
_anchor setVariable ["bo_next", 0];
_anchor setVariable ["bo_cover", [getPosATL _anchor, _stats get "range_m"] call BO_fnc_towerCoverage];
_anchor setVariable ["bo_mannable", _row get "mannable"];
_anchor setVariable ["bo_type", _id, true];
_anchor setVariable ["bo_spent", _row get "cost", true];
_anchor setVariable ["bo_upgraded", false, true];
BO_TowerList pushBack _anchor;
[_anchor] remoteExecCall ["BO_fnc_towerActions", 0, _anchor];
playSound3D ["z\bloonsops\addons\main\" + ((BO_Sounds get "build") get "file"), objNull, false, getPosASL _anchor, (BO_Sounds get "build") get "volume", 1, (BO_Sounds get "build") get "range_m"];
diag_log format ["[BloonsOps] built %1 at %2 cover %3", _id, mapGridPosition _anchor, _anchor getVariable "bo_cover"];
_anchor
