// Server: cones along the track, an arrow where bloons enter, map markers, respawn beside the exit.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_d", "_i", "_p", "_q", "_dir", "_side", "_cone", "_m", "_start", "_end", "_prev", "_a", "_spawn"];
_d = 0;
_i = 0;
while { _d < BO_PathLen } do {
    _p = [_d] call BO_fnc_pathPos;
    _q = [(_d + 1) min BO_PathLen] call BO_fnc_pathPos;
    _dir = ((_q select 0) - (_p select 0)) atan2 ((_q select 1) - (_p select 1));
    {
        _side = [(_p select 0) + (sin (_dir + _x)) * 3.5, (_p select 1) + (cos (_dir + _x)) * 3.5, 0];
        _cone = createVehicle [PROP_TRACK_CONE, _side, [], 0, "CAN_COLLIDE"];
        _cone enableSimulation false;
        _cone allowDamage false;
    } forEach [90, -90];
    if (_i % 3 == 0) then {
        _m = createMarker [format ["bo_track_%1", _i], _p];
        _m setMarkerTypeLocal "mil_dot";
        _m setMarkerColorLocal "ColorRed";
        _m setMarkerSize [0.5, 0.5];
    };
    _d = _d + 12;
    _i = _i + 1;
};
_start = BO_Path select 0;
_end = BO_Path select (count BO_Path - 1);
_prev = BO_Path select (count BO_Path - 2);
_a = createVehicle [PROP_TRACK_ENTRY, [_start select 0, _start select 1, 0], [], 0, "CAN_COLLIDE"];
_m = createMarker ["bo_entry", _start];
_m setMarkerTypeLocal "mil_flag";
_m setMarkerColorLocal "ColorGreen";
_m setMarkerText "Bloons enter";
_m = createMarker ["bo_exit", _end];
_m setMarkerTypeLocal "mil_flag";
_m setMarkerColorLocal "ColorRed";
_m setMarkerText "Bloons exit - defend!";
_dir = ((_end select 0) - (_prev select 0)) atan2 ((_end select 1) - (_prev select 1));
_spawn = [(_end select 0) + (sin (_dir + 90)) * 10, (_end select 1) + (cos (_dir + 90)) * 10, 0];
createMarker ["respawn_west", _spawn];
BO_SpawnPos = _spawn;
publicVariable "BO_SpawnPos";
