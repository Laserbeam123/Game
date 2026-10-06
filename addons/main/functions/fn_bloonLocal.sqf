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
    if (missionNamespace getVariable ["BO_SelfTest", false] && { isNil "BO_TestSeen" }) then {
        BO_TestSeen = true;
        diag_log format ["[BloonsOps][TEST] %1 bloon sphere textures %2", ["FAIL", "PASS"] select ((getObjectTextures _o) isNotEqualTo []), getObjectTextures _o];
        [_o] spawn {
            params ["_o"];
            private _p = getPosASL _o;
            sleep 2;
            diag_log format ["[BloonsOps][TEST] %1 bloon moved %2 m in 2 s", ["FAIL", "PASS"] select (isNull _o || { (getPosASL _o distance _p) > 1 }), [round (getPosASL _o distance _p), "popped"] select isNull _o];
        };
    };
} forEach _batch;
