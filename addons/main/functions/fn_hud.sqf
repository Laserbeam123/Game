// Client: cash / lives / round readout (RscTitles BO_Hud), and the nearest-tower action titles.
"BO_HudLayer" cutRsc ["BO_Hud", "PLAIN", 0, false];
BO_Near = objNull;
while { true } do {
    private _d = uiNamespace getVariable ["BO_Hud", displayNull];
    if (isNull _d) then { "BO_HudLayer" cutRsc ["BO_Hud", "PLAIN", 0, false] } else {
        (_d displayCtrl 1100) ctrlSetStructuredText parseText format [
            "<t size='1.15' font='PuristaBold'>BLOONS OPS</t><br/><t color='#FFD700'>$%1</t>   <t color='#FF6060'>Lives %2</t><br/>Round %3 / %4 %5<br/><t size='0.85'>Bloons on track: %6</t>",
            BO_Cash, BO_Lives max 0, BO_Round, BO_Cfg get "final_round",
            ["<t color='#7CFC00'>(ready)</t>", "<t color='#FF8C00'>(in progress)</t>"] select BO_RoundActive,
            count BO_LocalBloons
        ];
    };

    // nearest tower within reach (helipads are bigger)
    private _near = objNull;
    private _best = 1e9;
    {
        if (!isNull _x) then {
            private _dist = _x distance2D player;
            private _reach = [6, 9] select (!isNull (_x getVariable ["bo_heli", objNull]));
            if (_dist < _reach && _dist < _best) then { _best = _dist; _near = _x };
        };
    } forEach (missionNamespace getVariable ["BO_ClientTowers", []]);
    BO_Near = _near;
    if (!isNull _near && { !isNil "BO_ActUp" }) then {
        private _row = BO_Towers get (_near getVariable ["bo_type", ""]);
        private _up = BO_Upgrades get (_row get "upgrade");
        player setUserActionText [BO_ActUp, format ["<t color='#7CFC00'>Upgrade %1: %2 ($%3)</t>", _row get "name", _up get "name", _up get "cost"]];
        player setUserActionText [BO_ActMan, format ["<t color='#00BFFF'>Take the %1 yourself</t>", _row get "name"]];
        player setUserActionText [BO_ActSell, format ["<t color='#FF8C00'>Sell %1 ($%2)</t>", _row get "name", floor ((_near getVariable ["bo_spent", 0]) * (BO_Cfg get "sell_ratio"))]];
    };
    sleep 0.25;
};
