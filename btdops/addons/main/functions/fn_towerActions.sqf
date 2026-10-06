/*
    Client: Upgrade and Sell actions for the tower you stand next to; their text follows it.
*/
private _up = player addAction ["Upgrade", {
    [BTD_NearTower] remoteExecCall ["BTD_fnc_requestUpgrade", 2];
}, nil, 7, false, true, "", "BTD_NearTower >= 0 && {!BTD_GameOver}"];
private _sell = player addAction ["Sell", {
    [BTD_NearTower] remoteExecCall ["BTD_fnc_requestSell", 2];
}, nil, 6, false, true, "", "BTD_NearTower >= 0 && {!BTD_GameOver}"];
[_up, _sell] spawn {
    params ["_up", "_sell"];
    while {true} do {
        private _i = BTD_TowerList findIf {(_x#0) == BTD_NearTower};
        if (_i >= 0) then {
            (BTD_TowerList#_i) params ["", "_rowId", "_upg", "", "", "_spent"];
            private _row = BTD_Towers get _rowId;
            private _u = BTD_Upgrades get (_row get "upgrade");
            player setUserActionText [_up, [format ["<t color='#7cd7ff'>Upgrade %1: %2 ($%3)</t>", _row get "name", _u get "name", _u get "cost"], format ["%1 is upgraded", _row get "name"]] select _upg];
            player setUserActionText [_sell, format ["Sell %1 (+$%2)", _row get "name", floor (_spent * (BTD_Const get "sell_ratio"))]];
        };
        uiSleep 0.3;
    };
};
