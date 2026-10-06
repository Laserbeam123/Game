// Client: scroll-menu actions on a tower (upgrade, sell, take the gun).
params ["_t"];
if (isNull _t) exitWith {};
if (!isServer) then {
    // tower shots are visual only on every machine, not just the server
    {
        _x addEventHandler ["Fired", { params ["_u"]; if (!isPlayer (gunner vehicle _u) && !isPlayer _u) then { deleteVehicle (_this select 6) } }];
    } forEach ([_t] + (_t getVariable ["bo_crew", []]));
};
if (!hasInterface) exitWith {};
private _row = BO_Towers get (_t getVariable ["bo_type", ""]);
if (isNil "_row") exitWith {};
private _up = BO_Upgrades get (_row get "upgrade");
_t addAction [
    format ["<t color='#7CFC00'>Upgrade %1: %2 ($%3)</t>", _row get "name", _up get "name", _up get "cost"],
    { params ["_t", "_caller"]; [_caller, _t] remoteExecCall ["BO_fnc_requestUpgrade", 2] },
    nil, 3, false, true, "", "!(_target getVariable ['bo_upgraded', true]) && vehicle _this == _this", 6
];
_t addAction [
    format ["<t color='#FF8C00'>Sell %1</t>", _row get "name"],
    { params ["_t", "_caller"]; [_caller, _t] remoteExecCall ["BO_fnc_requestSell", 2] },
    nil, 1, false, true, "", "vehicle _this == _this", 6
];
if (_row get "mannable") then {
    _t addAction [
        format ["<t color='#00BFFF'>Take the %1 yourself</t>", _row get "name"],
        { params ["_t", "_caller"]; [_caller, _t] remoteExecCall ["BO_fnc_manTower", 2] },
        nil, 4, true, true, "", "vehicle _this == _this && !isPlayer (gunner _target)", 6
    ];
};
