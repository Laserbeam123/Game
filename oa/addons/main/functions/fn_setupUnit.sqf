// Client: [unit] invincible, actions, Fired handler (again after every respawn).
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_u"];
_u = _this select 0;
if (CFG_PLAYERS_INVINCIBLE) then { _u allowDamage false };
_u addAction ["<t color='#FFD700'>Start Next Round</t>", ACT("act_startRound.sqf"), [], 7, true, true, "",
    "BO_State == 'play' && !BO_RoundActive && BO_Round < BO_FinalRound && vehicle _this == _this"];
_u addAction ["<t color='#00FFFF'>Build Tablet</t>", ACT("act_tablet.sqf"), [], 6, false, true, "",
    "BO_State == 'play' && vehicle _this == _this"];
_u addEventHandler ["Fired", { _this call BO_fnc_onFired }];
BO_NearActs = [];
BO_NearShown = objNull;
