// Client: cash / lives / round readout (RscTitles BO_Hud from config.cpp).
"BO_HudLayer" cutRsc ["BO_Hud", "PLAIN", 0, false];
while { true } do {
    private _d = uiNamespace getVariable ["BO_Hud", displayNull];
    if (isNull _d) then { "BO_HudLayer" cutRsc ["BO_Hud", "PLAIN", 0, false] } else {
        (_d displayCtrl 1100) ctrlSetStructuredText parseText format [
            "<t size='1.15' font='PuristaBold'>BLOONS OPS</t><br/><t color='#FFD700'>$%1</t>   <t color='#FF6060'>&#10084; %2</t><br/>Round %3 / %4 %5<br/><t size='0.85'>Bloons on track: %6</t>",
            BO_Cash, BO_Lives max 0, BO_Round, BO_Cfg get "final_round",
            ["<t color='#7CFC00'>(ready)</t>", "<t color='#FF8C00'>(in progress)</t>"] select BO_RoundActive,
            count BO_LocalBloons
        ];
    };
    sleep 0.25;
};
