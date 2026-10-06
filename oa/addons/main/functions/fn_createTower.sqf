// Server: [towerIdx, posATL, dir] spawn a tower. The anchor carries its state: the static gun, a sandbag
// (infantry), a helipad under the hovering helicopter, or the monkey's body sphere.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_idx", "_pos", "_dir", "_row", "_kind", "_crew", "_parts", "_tex", "_anchor", "_grp", "_g", "_u", "_p", "_n", "_i", "_h", "_ball", "_fur", "_acc"];
_idx = _this select 0;
_pos = _this select 1;
_dir = _this select 2;
_row = TOWER(_idx);
_kind = _row select T_KIND;
_crew = [];
_parts = [];
_tex = [];          // [object, texture] pairs every client applies (setObjectTexture is local in OA)
_anchor = objNull;
_ball = {
    // [class, texture, attachTo (or objNull), offset, pos]
    private ["_o"];
    _o = createVehicle [_this select 0, _this select 4, [], 0, "CAN_COLLIDE"];
    _o allowDamage false;
    _tex set [count _tex, [_o, _this select 1]];
    if (!isNull (_this select 2)) then { _o attachTo [_this select 2, _this select 3]; _parts set [count _parts, _o] };
    _o
};

switch (_kind) do {
    case "static": {
        _grp = createGroup west;
        _anchor = createVehicle [_row select T_OA_OBJECT_CLASS, _pos, [], 0, "CAN_COLLIDE"];
        _anchor setDir _dir;
        _anchor allowDamage false;
        _g = _grp createUnit [_row select T_OA_CREW_CLASS, _pos, [], 0, "CAN_COLLIDE"];
        _g moveInGunner _anchor;
        _g allowDamage false;
        _crew set [count _crew, _g];
    };
    case "infantry": {
        _grp = createGroup west;
        _anchor = createVehicle [PROP_SANDBAG, _pos, [], 0, "CAN_COLLIDE"];
        _anchor setDir (_dir + 180);
        _anchor allowDamage false;
        _n = _row select T_CREW_COUNT;
        for "_i" from 1 to _n do {
            _p = [(_pos select 0) + (sin (_dir + 180 + (_i - (_n + 1) / 2) * 35)) * 1.5, (_pos select 1) + (cos (_dir + 180 + (_i - (_n + 1) / 2) * 35)) * 1.5, 0];
            _u = _grp createUnit [_row select T_OA_CREW_CLASS, _p, [], 0, "CAN_COLLIDE"];
            _u setDir _dir;
            _u disableAI "MOVE";
            _u allowDamage false;
            _crew set [count _crew, _u];
        };
    };
    case "heli": {
        _anchor = createVehicle [PROP_HELIPAD, _pos, [], 0, "CAN_COLLIDE"];
        _h = createVehicle [_row select T_OA_OBJECT_CLASS, [_pos select 0, _pos select 1, _row select T_HOVER_M], [], 0, "FLY"];
        _h setDir _dir;
        _h allowDamage false;
        _grp = createGroup west;
        _g = _grp createUnit [_row select T_OA_CREW_CLASS, _pos, [], 0, "CAN_COLLIDE"];
        _g moveInDriver _h;
        _crew set [count _crew, _g];
        {
            _u = _grp createUnit [_row select T_OA_CREW_CLASS, _pos, [], 0, "CAN_COLLIDE"];
            _u moveInTurret [_h, _x];
            _crew set [count _crew, _u];
        } forEach (_row select T_OA_TURRETS);
        { _x allowDamage false } forEach _crew;
        _grp setBehaviour "CARELESS";
        _grp setCombatMode "BLUE";
        _h flyInHeight (_row select T_HOVER_M);
        _g doMove _pos;
        _anchor setVariable ["bo_heli", _h, true];
        _parts set [count _parts, _h];
    };
    case "monkey": {
        _fur = _row select T_BODY_TEX;
        _acc = _row select T_ACCENT_TEX;
        _anchor = [PROP_BLOON_SPHERE, _fur, objNull, [], [_pos select 0, _pos select 1, 0.55]] call _ball;
        _anchor setDir _dir;
        [PROP_BLOON_SPHERE, _fur, _anchor, [0, 0, 0.85], _pos] call _ball;        // head
        [PROP_SMALL_SPHERE, BO_TexTan, _anchor, [0, 0.42, 0.75], _pos] call _ball; // face
        [PROP_SMALL_SPHERE, BO_TexTan, _anchor, [0.5, 0, 1.0], _pos] call _ball;   // ears
        [PROP_SMALL_SPHERE, BO_TexTan, _anchor, [-0.5, 0, 1.0], _pos] call _ball;
        [PROP_TINY_SPHERE, BO_TexWhite, _anchor, [0.16, 0.44, 0.98], _pos] call _ball;  // eyes
        [PROP_TINY_SPHERE, BO_TexWhite, _anchor, [-0.16, 0.44, 0.98], _pos] call _ball;
        [PROP_SMALL_SPHERE, _acc, _anchor, [0, 0, 1.38], _pos] call _ball;         // hat / headband
        [PROP_SMALL_SPHERE, _acc, _anchor, [0.45, 0.35, 0.05], _pos] call _ball;   // what it throws
    };
    case "farm": {
        _anchor = [PROP_BLOON_SPHERE, _row select T_BODY_TEX, objNull, [], [_pos select 0, _pos select 1, 1.0]] call _ball;
        { [PROP_SMALL_SPHERE, _row select T_ACCENT_TEX, _anchor, _x, _pos] call _ball } forEach [[0.5, 0.4, 0.3], [-0.5, 0.3, 0.1], [0.1, -0.5, 0.4], [0.4, -0.3, -0.1]];
    };
};

_anchor setVariable ["bo_stats", +_row];
_anchor setVariable ["bo_crew", _crew, true];
_anchor setVariable ["bo_parts", _parts];
_anchor setVariable ["bo_tex", _tex];
_anchor setVariable ["bo_next", 0];
_anchor setVariable ["bo_remanAt", 0];
if (isNil { _anchor getVariable "bo_heli" }) then { _anchor setVariable ["bo_heli", objNull, true] };
_anchor setVariable ["bo_cover", [getPosATL _anchor, _row select T_RANGE_M] call BO_fnc_towerCoverage];
_anchor setVariable ["bo_mannable", _row select T_MANNABLE, true];
_anchor setVariable ["bo_type", _idx, true];
_anchor setVariable ["bo_spent", _row select T_COST, true];
_anchor setVariable ["bo_upgraded", false, true];
BO_TowerList set [count BO_TowerList, _anchor];
["BO_fnc_towerLocal", [_anchor, _tex]] call BO_fnc_netAll;
diag_log format ["[BloonsOps] built %1 (%2) at %3 cover %4", _row select T_ID, _kind, mapGridPosition _anchor, _anchor getVariable "bo_cover"];
_anchor
