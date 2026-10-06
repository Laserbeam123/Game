// Client, postInit: on Arma's main menu (whose background scene also runs postInit), add a big
// PLAY BLOONS OPS button that starts the solo mission. Does nothing inside a real mission.
if (!hasInterface) exitWith {};
[] spawn {
    private _main = displayNull;
    for "_i" from 1 to 100 do {
        _main = uiNamespace getVariable ["RscDisplayMain", displayNull];
        if (!isNull _main) exitWith {};
        uiSleep 0.1;
    };
    if (isNull _main || { !isNull (_main displayCtrl 77100) }) exitWith {};
    private _b = _main ctrlCreate ["RscButton", 77100];
    _b ctrlSetPosition [safeZoneX + safeZoneW / 2 - 0.35, safeZoneY + 0.05, 0.7, 0.11];
    _b ctrlSetText "PLAY BLOONS OPS";
    _b ctrlSetFont "PuristaBold";
    _b ctrlSetFontHeight 0.07;
    _b ctrlSetBackgroundColor [0.85, 0.1, 0.1, 0.92];
    _b ctrlSetTextColor [1, 0.85, 0, 1];
    _b ctrlSetTooltip "Solo tower defense on Altis. For co-op: Multiplayer > Host > Bloons Ops - Co-op 1-4";
    _b ctrlAddEventHandler ["ButtonClick", {
        playMission ["", configFile >> "CfgMissions" >> "Missions" >> "BloonsOps_Altis"];
    }];
    _b ctrlCommit 0;
};
