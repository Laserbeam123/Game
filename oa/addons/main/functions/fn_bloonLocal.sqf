// Client: [[[id, typeIdx, d0, t0, mult], ...]] create the local bloon spheres (painted) and knots.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_id", "_type", "_tex", "_o", "_k", "_p"];
if (isDedicated || { isNil "BO_LocalB" }) exitWith {};
{
    _id = _x select 0;
    _type = _x select 1;
    _tex = format ["\z\bloonsops_oa\addons\main\data\bloon_%1_co.paa", (BLOON(_type)) select B_ID];
    _o = PROP_BLOON_SPHERE createVehicleLocal [0, 0, 0];
    _o enableSimulation false;
    _o setObjectTexture [0, _tex];
    _k = PROP_SMALL_SPHERE createVehicleLocal [0, 0, 0];
    _k enableSimulation false;
    _k setObjectTexture [0, _tex];
    _p = [_x select 2] call BO_fnc_pathPos;
    _o setPosASL _p;
    BO_LocalB set [_id, [_o, _type, _x select 2, _x select 3, ((BLOON(_type)) select B_SPEED_MPS) * (_x select 4), random 360, _k]];
    BO_LocalIds set [count BO_LocalIds, _id];
} forEach (_this select 0);
