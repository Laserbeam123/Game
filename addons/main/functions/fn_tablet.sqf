// Client: the build tablet. Two columns (ARMA 3 and BLOONS TD), one button per towers row.
if (!createDialog "BO_TabletDialog") exitWith {};
private _d = findDisplay 77200;
private _x0 = safeZoneX + safeZoneW * 0.2;
private _y0 = safeZoneY + safeZoneH * 0.12;
private _colW = safeZoneW * 0.285;
private _rowH = safeZoneH * 0.052;

private _title = _d ctrlCreate ["RscStructuredText", -1];
_title ctrlSetPosition [_x0, _y0, safeZoneW * 0.6, _rowH * 1.4];
_title ctrlSetStructuredText parseText format ["<t size='1.6' font='PuristaBold' color='#FFD700'>BUILD TABLET</t>   <t size='1.2'>Cash: $%1</t>", BO_Cash];
_title ctrlCommit 0;

{
    _x params ["_section", "_label", "_col", "_bg"];
    private _cx = _x0 + _col * (_colW + safeZoneW * 0.03);
    private _h = _d ctrlCreate ["RscStructuredText", -1];
    _h ctrlSetPosition [_cx, _y0 + _rowH * 1.6, _colW, _rowH];
    _h ctrlSetStructuredText parseText format ["<t size='1.3' font='PuristaBold'>%1</t>", _label];
    _h ctrlCommit 0;
    private _i = 0;
    {
        private _r = BO_Towers get _x;
        if ((_r get "section") == _section) then {
            private _afford = BO_Cash >= (_r get "cost");
            private _b = _d ctrlCreate ["RscButton", -1];
            _b ctrlSetPosition [_cx, _y0 + _rowH * (2.8 + _i * 1.12), _colW, _rowH];
            _b ctrlSetText format ["%1   $%2", _r get "name", _r get "cost"];
            _b ctrlSetBackgroundColor ([[0.2, 0.2, 0.2, 0.9], _bg] select _afford);
            _b ctrlSetTextColor ([[1, 0.45, 0.45, 1], [1, 1, 1, 1]] select _afford);
            private _flags = [];
            if (_r get "pops_lead") then { _flags pushBack "pops lead" };
            if (_r get "sees_camo") then { _flags pushBack "sees camo" };
            if (_r get "mannable") then { _flags pushBack "you can man it" };
            _b ctrlSetTooltip ((_r get "blurb") + (["", " (" + (_flags joinString ", ") + ")"] select (_flags isNotEqualTo [])));
            _b setVariable ["bo_id", _x];
            _b ctrlAddEventHandler ["ButtonClick", {
                params ["_b"];
                private _pos = player getRelPos [BO_Cfg get "build_distance", 0];
                _pos set [2, 0];
                [player, _b getVariable "bo_id", _pos] remoteExecCall ["BO_fnc_requestBuild", 2];
                closeDialog 0;
            }];
            _b ctrlCommit 0;
            _i = _i + 1;
        };
    } forEach BO_TowerOrder;
} forEach [
    ["arma", "<t color='#B8E07A'>ARMA 3</t>", 0, [0.24, 0.32, 0.16, 0.95]],
    ["btd", "<t color='#FFC640'>BLOONS TD</t>", 1, [0.7, 0.38, 0.06, 0.95]]
];

private _hint = _d ctrlCreate ["RscStructuredText", -1];
_hint ctrlSetPosition [_x0, safeZoneY + safeZoneH * 0.8, safeZoneW * 0.45, _rowH];
_hint ctrlSetStructuredText parseText "<t size='0.9'>Towers appear 4 m in front of you. Stay 5 m off the road. Hover a button for details.</t>";
_hint ctrlCommit 0;
private _close = _d ctrlCreate ["RscButton", -1];
_close ctrlSetPosition [safeZoneX + safeZoneW * 0.7, safeZoneY + safeZoneH * 0.8, safeZoneW * 0.1, _rowH];
_close ctrlSetText "Close";
_close ctrlAddEventHandler ["ButtonClick", { closeDialog 0 }];
_close ctrlCommit 0;
