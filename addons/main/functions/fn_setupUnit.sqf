// Client: actions and handlers on the player's unit (again after every respawn).
params ["_unit"];
_unit addAction [
    "<t color='#FFD700' size='1.1'>Start Next Round</t>",
    { remoteExecCall ["BO_fnc_startRound", 2] },
    nil, 7, true, true, "",
    "BO_State == 'play' && !BO_RoundActive && BO_Round < (BO_Cfg get 'final_round') && vehicle _this == _this"
];
_unit addAction [
    "<t color='#00FFFF'>Build Tablet</t>",
    { [] call BO_fnc_tablet },
    nil, 6, false, true, "", "BO_State == 'play' && vehicle _this == _this"
];
{
    private _row = BO_Towers get _x;
    _unit addAction [
        format ["    Build %1 ($%2)", _row get "name", _row get "cost"],
        {
            params ["_u", "_caller", "_aid", "_id"];
            private _pos = _caller getRelPos [BO_Cfg get "build_distance", 0];
            _pos set [2, 0];
            [_caller, _id, _pos] remoteExecCall ["BO_fnc_requestBuild", 2];
            BO_TabletOpen = false;
            hintSilent "";
        },
        _x, 5.9 - _forEachIndex * 0.01, false, true, "", "BO_TabletOpen && vehicle _this == _this"
    ];
} forEach BO_TowerOrder;
_unit addEventHandler ["FiredMan", { call BO_fnc_onFiredMan }];
