// Client: FiredMan handler on the player (on foot or on a tower's gun).
params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_mag", "_proj"];
if (isNull _proj || { isNil "BO_Proj" }) exitWith {};
private _cfg = configFile >> "CfgAmmo" >> _ammo;
if ((getNumber (_cfg >> "explosive")) > 0.5 || { (getNumber (_cfg >> "indirectHitRange")) > 1 }) then {
    // explosives: pop everything in the blast, lead included
    private _rad = ((getNumber (_cfg >> "indirectHitRange")) * 1.5) max 3 min 8;
    _proj setVariable ["bo_rad", _rad];
    _proj addEventHandler ["Explode", {
        params ["_proj", "_pos"];
        private _rad = _proj getVariable ["bo_rad", 3];
        private _n = 0;
        {
            if (_n < 20 && { ((getPosASL (_y select 0)) distance _pos) < _rad }) then {
                [_x, 1, true] remoteExecCall ["BO_fnc_damageBloon", 2];
                _n = _n + 1;
            };
        } forEach BO_LocalBloons;
    }];
} else {
    BO_Proj pushBack [_proj, getPosASL _proj, false, (call BO_fnc_now) + 3];
};
