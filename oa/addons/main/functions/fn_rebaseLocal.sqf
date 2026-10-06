// Client: [[[id, d0, t0, mult], ...]] a bloon was slowed, frozen or released.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_e"];
if (isDedicated || { isNil "BO_LocalB" }) exitWith {};
{
    if ((_x select 0) < count BO_LocalB) then {
        _e = BO_LocalB select (_x select 0);
        if (count _e > 0) then {
            _e set [2, _x select 1];
            _e set [3, _x select 2];
            _e set [4, ((BLOON(_e select 1)) select B_SPEED_MPS) * (_x select 3)];
        };
    };
} forEach (_this select 0);
