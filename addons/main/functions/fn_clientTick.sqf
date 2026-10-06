// Client, every frame: float the local bloons along the track; check tracked player bullets against them.
private _now = call BO_fnc_now;
{
    _y params ["_o", "_type", "_d0", "_t0", "_v", "_ph", "_k"];
    private _p = ([_d0 + _v * (_now - _t0)] call BO_fnc_pathPos) vectorAdd [0, 0, 0.15 * sin (_now * 180 + _ph)];
    _o setPosASL _p;
    _k setPosASL (_p vectorAdd [0, 0, -0.55]);
} forEach BO_LocalBloons;

if (BO_Proj isEqualTo []) exitWith {};
private _r = BO_Cfg get "player_hit_radius_m";
private _keep = [];
{
    _x params ["_proj", "_last", "_lead", "_until"];
    if (!isNull _proj && { _now < _until }) then {
        private _cur = getPosASL _proj;
        private _seg = _cur vectorDiff _last;
        private _len2 = (_seg vectorDotProduct _seg) max 0.0001;
        private _hit = -1;
        {
            private _bp = getPosASL (_y select 0);
            private _f = (((_bp vectorDiff _last) vectorDotProduct _seg) / _len2) max 0 min 1;
            if ((_bp distance (_last vectorAdd (_seg vectorMultiply _f))) < _r) exitWith { _hit = _x };
        } forEach BO_LocalBloons;
        if (_hit >= 0) then {
            [_hit, 1, _lead] remoteExecCall ["BO_fnc_damageBloon", 2];
            // the projectile stops counting (pierce 1); the sphere goes when the server broadcasts the pop
        } else {
            _x set [1, _cur];
            _keep pushBack _x;
        };
    };
} forEach BO_Proj;
BO_Proj = _keep;
