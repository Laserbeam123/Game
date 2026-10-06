/*
    Client, every frame: move each followed bullet along its path since last frame and pop the
    first bloon it crosses (segment against sphere, bloon positions from draw3D).
*/
if (count BTD_Shots == 0) exitWith {};
private _dt = diag_deltaTime min 0.1;
private _keep = [];
{
    _x params ["_proj", "_last", "_vel"];
    private _alive = !isNull _proj;
    private _now = if (_alive) then {getPosASL _proj} else {_last vectorAdd (_vel vectorMultiply _dt)};
    private _seg = _now vectorDiff _last;
    private _len2 = _seg vectorDotProduct _seg;
    private _hit = -1;
    if (_len2 > 0) then {
        {
            _x params ["_id", "_c", "_r"];
            private _t = (((_c vectorDiff _last) vectorDotProduct _seg) / _len2) max 0 min 1;
            if ((_c distance (_last vectorAdd (_seg vectorMultiply _t))) <= _r) exitWith {_hit = _id};
        } forEach BTD_CPos;
    };
    if (_hit >= 0) then {
        [_hit] remoteExecCall ["BTD_fnc_playerHit", 2];
        BTD_CPos = BTD_CPos select {(_x#0) != _hit};
        if (_alive) then {deleteVehicle _proj};
    } else {
        if (_alive) then {_keep pushBack [_proj, _now, velocity _proj]};
    };
} forEach BTD_Shots;
BTD_Shots = _keep;
