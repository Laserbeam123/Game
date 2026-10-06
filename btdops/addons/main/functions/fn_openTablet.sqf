/*
    Client: the build tablet (ARMA 3 and BTD6 columns, generated from the towers sheet).
*/
if (!createDialog "BTD_Tablet") exitWith {};
private _d = findDisplay 9300;
(_d displayCtrl 9301) ctrlSetText format ["BUILD TABLET    Cash $%1    (a tower goes where you are looking)", BTD_Cash];
