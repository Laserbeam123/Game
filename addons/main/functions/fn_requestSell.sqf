// Server: sell a tower for sell_ratio of what was spent on it.
params ["_player", "_t"];
if (!isServer || { isNull _t } || { !(_t in BO_TowerList) }) exitWith {};
if (isPlayer gunner _t) exitWith { ["Get off the gun before selling it.", "error"] remoteExecCall ["BO_fnc_notify", _player] };
private _refund = floor ((_t getVariable ["bo_spent", 0]) * (BO_Cfg get "sell_ratio"));
BO_Cash = BO_Cash + _refund;
publicVariable "BO_Cash";
BO_TowerList = BO_TowerList - [_t];
{ deleteVehicle _x } forEach (_t getVariable ["bo_crew", []]);
deleteVehicle _t;
[format ["Sold for $%1.", _refund], "info"] remoteExecCall ["BO_fnc_notify", _player];
