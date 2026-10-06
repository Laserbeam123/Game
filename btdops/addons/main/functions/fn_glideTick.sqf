/*
    Client, every frame: hover-glide. The player floats glide_hover_m above whatever is below and
    slides where the movement keys point (relative to the camera), coasting to a stop when let go.
    BTD_GlideTest = [forward, right] stands in for the keys during the self test.
*/
if (!BTD_GlideOn || {!alive player} || {!isNull objectParent player}) exitWith {};
private _dt = diag_deltaTime min 0.1;
private _in = missionNamespace getVariable ["BTD_GlideTest", []];
if (_in isEqualTo []) then {
    _in = [
        ((inputAction "MoveForward") + (inputAction "MoveFastForward") + (inputAction "MoveSlowForward") min 1) - ((inputAction "MoveBack") min 1),
        ((inputAction "TurnRight") min 1) - ((inputAction "TurnLeft") min 1)
    ];
};
_in params ["_f", "_r"];
private _view = getCameraViewDirection player;
private _fw = vectorNormalized [_view#0, _view#1, 0];
private _rt = [_fw#1, -(_fw#0), 0];
private _wish = (_fw vectorMultiply _f) vectorAdd (_rt vectorMultiply _r);
private _top = (BTD_Const get "glide_speed_mps") * ([1, BTD_Const get "glide_boost_mult"] select ((inputAction "Turbo") > 0));
private _v = BTD_GlideVel;
if ((vectorMagnitude _wish) > 0.05) then {
    private _want = (vectorNormalized _wish) vectorMultiply _top;
    private _diff = _want vectorDiff _v;
    private _stepMax = (BTD_Const get "glide_accel") * _dt;
    if ((vectorMagnitude _diff) > _stepMax) then {_diff = (vectorNormalized _diff) vectorMultiply _stepMax};
    _v = _v vectorAdd _diff;
} else {
    _v = _v vectorMultiply (exp (-(BTD_Const get "glide_drag") * _dt));
};
BTD_GlideVel = _v;

// hold the hover height over terrain or whatever object is below
private _p = getPosASL player;
private _ground = getTerrainHeightASL _p;
private _hits = lineIntersectsSurfaces [_p vectorAdd [0, 0, 1.5], _p vectorAdd [0, 0, -6], player, objNull, true, 1, "GEOM", "NONE"];
if (count _hits > 0) then {_ground = _ground max ((_hits#0#0)#2)};
private _vz = (((_ground + (BTD_Const get "glide_hover_m")) - (_p#2)) * (BTD_Const get "glide_hover_gain")) max -8 min 8;
player setVelocity [_v#0, _v#1, _vz];
