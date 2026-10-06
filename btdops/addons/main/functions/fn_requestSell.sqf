/*
    Client -> server: sell tower _key for sell_ratio of what was spent on it.
*/
params ["_key"];
if (!isServer || {BTD_GameOver}) exitWith {};
private _i = BTD_TowerList findIf {(_x#0) == _key};
if (_i < 0) exitWith {};
private _t = BTD_TowerList deleteAt _i;
private _o = BTD_TowerObjs getOrDefault [_key, [[], 0]];
BTD_TowerObjs deleteAt _key;
{
    if (!isNull _x) then {
        if (_x isKindOf "Man") then {deleteVehicle _x} else {
            { (vehicle _x) deleteVehicleCrew _x } forEach (crew _x);
            deleteVehicle _x;
        };
    };
} forEach (_o#0);
BTD_Cash = BTD_Cash + floor ((_t#5) * (BTD_Const get "sell_ratio"));
publicVariable "BTD_Cash";
publicVariable "BTD_TowerList";
(BTD_Batch#4) pushBack ["sell", _t#3, _t#3, "sell", 0];
