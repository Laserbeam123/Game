/*
    Client: the player fired. Bullets are followed frame by frame (shotTick); grenades, shells and
    rockets report where they explode.
*/
params ["_unit", "", "", "", "_ammo", "", "_proj"];
if (_unit != player || {isNull _proj}) exitWith {};
private _cfg = configFile >> "CfgAmmo" >> _ammo;
private _sim = toLower getText (_cfg >> "simulation");
if (_sim in ["shotbullet", "shotspread"]) exitWith {
    BTD_Shots pushBack [_proj, getPosASL _proj, velocity _proj];
};
if (getNumber (_cfg >> "explosive") > 0.3 || {_sim in ["shotgrenade", "shotshell", "shotrocket", "shotmissile", "shotsubmunitions"]}) then {
    _proj addEventHandler ["Explode", {
        params ["", "_pos"];
        [_pos] remoteExecCall ["BTD_fnc_playerBlast", 2];
    }];
};
