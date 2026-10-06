// Server: spawn a tower from its towers row. Returns the anchor object that carries its actions:
// the static gun, a sandbag (infantry), a helipad under the helicopter, or the monkey's body.
params ["_id", "_posATL", "_dir"];
private _row = BO_Towers get _id;
private _kind = _row get "kind";
private _crew = [];
private _parts = [];
private _anchor = objNull;
private _noBullets = {
    // muzzle flash and sound only: the real projectile is removed, damage is scripted
    _this addEventHandler ["Fired", { params ["_u"]; if (!isPlayer (gunner vehicle _u) && !isPlayer _u) then { deleteVehicle (_this select 6) } }];
};
private _ball = {
    // one painted sphere (texture path from the sheets), attached to _attach at _offset unless _attach is null
    params ["_cls", "_tex", "_attach", "_offset", ["_pos", [0, 0, 0]]];
    private _o = createVehicle [_cls, _pos, [], 0, "CAN_COLLIDE"];
    _o setObjectTextureGlobal [0, _tex];
    if (!isNull _attach) then { _o attachTo [_attach, _offset]; _parts pushBack _o };
    _o
};

switch (_kind) do {
    case "static": {
        private _grp = createGroup [west, true];
        _anchor = createVehicle [_row get "object_class", _posATL, [], 0, "CAN_COLLIDE"];
        _anchor setDir _dir;
        _anchor allowDamage false;
        _anchor call _noBullets;
        private _g = _grp createUnit [_row get "crew_class", _posATL, [], 0, "CAN_COLLIDE"];
        _g moveInGunner _anchor;
        _g allowDamage false;
        _crew pushBack _g;
    };
    case "infantry": {
        private _grp = createGroup [west, true];
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
    case "heli": {
        _anchor = createVehicle ["Land_HelipadCircle_F", _posATL, [], 0, "CAN_COLLIDE"];
        _anchor setDir _dir;
        private _h = createVehicle [_row get "object_class", _posATL vectorAdd [0, 0, _row get "hover_m"], [], 0, "FLY"];
        _h setDir _dir;
        createVehicleCrew _h;
        _h allowDamage false;
        { _x allowDamage false } forEach crew _h;
        private _g = group driver _h;
        _g setBehaviourStrong "CARELESS";
        _g setCombatMode "BLUE";
        _h flyInHeight (_row get "hover_m");
        (driver _h) doMove _posATL;
        _h call _noBullets;
        _anchor setVariable ["bo_heli", _h, true];
        _crew = crew _h;
        _parts pushBack _h;
    };
    case "monkey": {
        private _fur = _row get "body_tex";
        private _acc = _row get "accent_tex";
        private _tan = BO_TexTan;
        _anchor = ["Sign_Sphere100cm_F", _fur, objNull, [], _posATL vectorAdd [0, 0, 0.55]] call _ball;
        _anchor setDir _dir;
        ["Sign_Sphere100cm_F", _fur, _anchor, [0, 0, 0.85]] call _ball;            // head
        ["Sign_Sphere25cm_F", _tan, _anchor, [0, 0.42, 0.75]] call _ball;          // face
        ["Sign_Sphere25cm_F", _tan, _anchor, [0.5, 0, 1.0]] call _ball;            // ears
        ["Sign_Sphere25cm_F", _tan, _anchor, [-0.5, 0, 1.0]] call _ball;
        ["Sign_Sphere10cm_F", BO_TexWhite, _anchor, [0.16, 0.44, 0.98]] call _ball; // eyes
        ["Sign_Sphere10cm_F", BO_TexWhite, _anchor, [-0.16, 0.44, 0.98]] call _ball;
        ["Sign_Sphere25cm_F", _acc, _anchor, [0, 0, 1.38]] call _ball;             // hat / headband
        ["Sign_Sphere25cm_F", _acc, _anchor, [0.45, 0.35, 0.05]] call _ball;       // what it throws
    };
    case "farm": {
        _anchor = ["Sign_Sphere200cm_F", _row get "body_tex", objNull, [], _posATL vectorAdd [0, 0, 1.2]] call _ball;
        { ["Sign_Sphere25cm_F", _row get "accent_tex", _anchor, _x] call _ball } forEach [[0.6, 0.6, 0.4], [-0.6, 0.5, 0.2], [0.1, -0.7, 0.5], [0.5, -0.4, -0.1], [-0.4, -0.5, 0.6]];
    };
};

private _stats = +_row;
_anchor setVariable ["bo_stats", _stats];
_anchor setVariable ["bo_crew", _crew, true];
_anchor setVariable ["bo_parts", _parts];
_anchor setVariable ["bo_next", 0];
_anchor setVariable ["bo_cover", [getPosATL _anchor, _stats get "range_m"] call BO_fnc_towerCoverage];
_anchor setVariable ["bo_mannable", _row get "mannable"];
_anchor setVariable ["bo_type", _id, true];
_anchor setVariable ["bo_spent", _row get "cost", true];
_anchor setVariable ["bo_upgraded", false, true];
BO_TowerList pushBack _anchor;
[_anchor] remoteExecCall ["BO_fnc_towerActions", 0, _anchor];
private _snd = BO_Sounds get "build";
playSound3D ["z\bloonsops\addons\main\" + (_snd get "file"), objNull, false, getPosASL _anchor, _snd get "volume", 1, _snd get "range_m"];
diag_log format ["[BloonsOps] built %1 (%2) at %3 cover %4", _id, _kind, mapGridPosition _anchor, _anchor getVariable "bo_cover"];
_anchor
