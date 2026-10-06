// Client: create the local spheres for newly spawned bloons. [[id, type, d0, t0], ...]
params ["_batch"];
if (!hasInterface || { isNil "BO_LocalBloons" }) exitWith {};
{
    _x params ["_id", "_type", "_d0", "_t0"];
    private _r = BO_Bloons get _type;
    private _o = "Sign_Sphere100cm_F" createVehicleLocal [0, 0, 0];
    _o enableSimulation false;
    (_r get "rgba") params ["_cr", "_cg", "_cb", "_ca"];
    _o setObjectTexture [0, format ["#(argb,8,8,3)color(%1,%2,%3,%4,ca)", _cr, _cg, _cb, _ca]];
    _o setPosASL ([_d0] call BO_fnc_pathPos);
    BO_LocalBloons set [_id, [_o, _type, _d0, _t0, _r get "speed_mps", random 360]];
} forEach _batch;
