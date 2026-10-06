// Client: Fired handler on the player (and on a gun the player mans). Starts tracking the projectile.
private ["_ammo", "_proj", "_cfg", "_explosive"];
_ammo = _this select 4;
_proj = objNull;
if (count _this > 6) then { _proj = _this select 6 } else { _proj = nearestObject [_this select 0, _ammo] };
if (isNull _proj || { isNil "BO_Proj" }) exitWith {};
_cfg = configFile >> "CfgAmmo" >> _ammo;
_explosive = (getNumber (_cfg >> "explosive")) > 0.5 || { (getNumber (_cfg >> "indirectHitRange")) > 1 };
BO_Proj set [count BO_Proj, [_proj, getPosASL _proj, _explosive, (call BO_fnc_now) + 6]];
