// Client: create the local cartoon bloons (painted sphere + knot; the string is drawn in draw3D).
// [[id, type, d0, t0, mult?], ...]
params ["_batch"];
if (!hasInterface || { isNil "BO_LocalBloons" }) exitWith {};
{
    _x params ["_id", "_type", "_d0", "_t0", ["_mult", 1]];
    private _r = BO_Bloons get _type;
    private _tex = format ["\z\bloonsops\addons\main\data\bloon_%1_co.paa", _type];
    private _o = "Sign_Sphere100cm_F" createVehicleLocal [0, 0, 0];
    _o enableSimulation false;
    _o setObjectTexture [0, _tex];
    private _k = "Sign_Sphere25cm_F" createVehicleLocal [0, 0, 0];
    _k enableSimulation false;
    _k setObjectTexture [0, _tex];
    private _p = [_d0] call BO_fnc_pathPos;
    _o setPosASL _p;
    _k setPosASL (_p vectorAdd [0, 0, -0.55]);
    BO_LocalBloons set [_id, [_o, _type, _d0, _t0, (_r get "speed_mps") * _mult, random 360, _k]];
    if (missionNamespace getVariable ["BO_SelfTest", false] && { isNil "BO_TestSeen" }) then {
        BO_TestSeen = true;
        diag_log format ["[BloonsOps][TEST] %1 bloon sphere textures %2", ["FAIL", "PASS"] select ((getObjectTextures _o) isNotEqualTo []), getObjectTextures _o];
    };
} forEach _batch;
