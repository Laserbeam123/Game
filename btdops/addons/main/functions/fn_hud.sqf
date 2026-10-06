/*
    Client: the Cash / Lives / Round bar.
*/
private _d = uiNamespace getVariable ["BTD_HudDisplay", displayNull];
if (isNull _d) exitWith {"btd_hud" cutRsc ["BTD_Hud", "PLAIN", 0, false]};
private _speed = ["", "   <t color='#ffd84a'>x" + str (BTD_Clock#2) + "</t>"] select ((BTD_Clock#2) > 1);
private _glide = ["   <t color='#999999'>walking</t>", "   <t color='#7cd7ff'>gliding</t>"] select BTD_GlideOn;
(_d displayCtrl 9101) ctrlSetStructuredText parseText format [
    "<t size='1.3' font='PuristaBold'><t color='#ffd84a'>$%1</t>   <t color='#ff6b6b'>Lives %2</t>   Round %3 / %4%5%6</t>",
    BTD_Cash, BTD_Lives, BTD_Round, BTD_RoundCount, _speed, _glide
];
