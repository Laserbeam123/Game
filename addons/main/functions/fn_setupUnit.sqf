// Client: actions and handlers on the player's unit (again after every respawn).
// Tower actions live on the player and act on the nearest tower (BO_Near, set by the HUD loop), because
// sphere monkeys and helipads have no geometry for actions of their own.
params ["_unit"];
if (BO_Cfg get "players_invincible") then { _unit allowDamage false };
_unit setAnimSpeedCoef (BO_Cfg get "player_speed_mult");   // zip around on foot
_unit addAction [
    "<t color='#FFD700' size='1.1'>Start Next Round</t>",
    { remoteExecCall ["BO_fnc_startRound", 2] },
    nil, 7, true, true, "",
    "BO_State == 'play' && !BO_RoundActive && BO_Round < (BO_Cfg get 'final_round') && vehicle _this == _this"
];
_unit addAction [
    "<t color='#00FFFF'>Build Tablet</t>",
    { [] spawn BO_fnc_tablet },
    nil, 6, false, true, "", "BO_State == 'play' && vehicle _this == _this"
];
BO_ActUp = _unit addAction ["Upgrade", { [player, BO_Near] remoteExecCall ["BO_fnc_requestUpgrade", 2] },
    nil, 5, false, true, "", "!isNull BO_Near && { !(BO_Near getVariable ['bo_upgraded', true]) } && vehicle _this == _this"];
BO_ActMan = _unit addAction ["Take the gun", { [player, BO_Near] remoteExecCall ["BO_fnc_manTower", 2] },
    nil, 4.9, true, true, "", "!isNull BO_Near && { BO_Near getVariable ['bo_mannable', false] } && { !isPlayer (gunner BO_Near) } && vehicle _this == _this"];
BO_ActSell = _unit addAction ["Sell", { [player, BO_Near] remoteExecCall ["BO_fnc_requestSell", 2] },
    nil, 1, false, true, "", "!isNull BO_Near && vehicle _this == _this"];
_unit addEventHandler ["FiredMan", { call BO_fnc_onFiredMan }];
