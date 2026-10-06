// Server: mark the track with cones, entry/exit arrows and map markers; respawn at the exit.
private _step = 12;
private _d = 0;
private _i = 0;
while { _d < BO_PathLen } do {
    private _p = [_d] call BO_fnc_pathPos;
    private _q = [(_d + 1) min BO_PathLen] call BO_fnc_pathPos;
    private _dir = _p getDir _q;
    {
        private _side = _p getPos [3.5, _dir + _x];
        _side set [2, 0];
        private _cone = createVehicle ["RoadCone_F", _side, [], 0, "CAN_COLLIDE"];
        _cone enableSimulationGlobal false;
        _cone allowDamage false;
    } forEach [90, -90];
    if (_i % 3 == 0) then {
        private _m = createMarker [format ["bo_track_%1", _i], _p];
        _m setMarkerTypeLocal "mil_dot";
        _m setMarkerColorLocal "ColorRed";
        _m setMarkerSize [0.5, 0.5];
    };
    _d = _d + _step;
    _i = _i + 1;
};
private _start = BO_Path select 0;
private _end = BO_Path select -1;
{
    _x params ["_pos", "_cls", "_mk", "_txt", "_col"];
    private _a = createVehicle [_cls, ASLToATL _pos, [], 0, "CAN_COLLIDE"];
    _a enableSimulationGlobal false;
    private _m = createMarker [_mk, _pos];
    _m setMarkerTypeLocal "mil_flag";
    _m setMarkerColorLocal _col;
    _m setMarkerText _txt;
} forEach [
    [_start, "Sign_Arrow_Large_Green_F", "bo_entry", "Bloons enter", "ColorGreen"],
    [_end, "Sign_Arrow_Large_F", "bo_exit", "Bloons exit - defend!", "ColorRed"]
];
// players respawn just beside the exit
private _dirEnd = (BO_Path select -2) getDir _end;
private _spawn = _end getPos [10, _dirEnd + 90];
_spawn set [2, 0];
createMarker ["respawn_west", _spawn];
BO_SpawnPos = _spawn;
publicVariable "BO_SpawnPos";
