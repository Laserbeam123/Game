// Client: remove popped (or leaked) bloons, with a pop sound.
params ["_ids", ["_leak", false]];
if (!hasInterface || { isNil "BO_LocalBloons" }) exitWith {};
private _snd = BO_Sounds get (["pop", "leak"] select _leak);
private _path = "z\bloonsops\addons\main\" + (_snd get "file");
private _sounds = 0;
{
    private _e = BO_LocalBloons getOrDefault [_x, []];
    if (_e isNotEqualTo []) then {
        private _o = _e select 0;
        if (_sounds < 6 && { (_o distance player) < (_snd get "range_m") }) then {
            playSound3D [_path, objNull, false, getPosASL _o, _snd get "volume", 0.85 + random 0.3, _snd get "range_m", 0, true];
            _sounds = _sounds + 1;
        };
        deleteVehicle _o;
        deleteVehicle (_e select 6);
        BO_LocalBloons deleteAt _x;
    };
} forEach _ids;
