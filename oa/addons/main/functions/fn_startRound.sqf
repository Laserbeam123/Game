// Server: a player chose "Start Next Round".
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_row", "_tip"];
if (!isServer || { BO_State != "play" } || BO_RoundActive || { BO_Round >= CFG_FINAL_ROUND }) exitWith {};
BO_Round = BO_Round + 1;
BO_RoundActive = true;
publicVariable "BO_Round";
publicVariable "BO_RoundActive";
_row = BO_Rounds select (BO_Round - 1);
_tip = _row select R_TIP;
if (_tip != "") then { _tip = " - " + _tip };
["BO_fnc_notify", [format ["Round %1%2", BO_Round, _tip], "round"]] call BO_fnc_netAll;
diag_log format ["[BloonsOps] round %1 start", BO_Round];
[_row] spawn {
    private ["_row", "_bonus", "_i"];
    _row = _this select 0;
    {
        sleep (_x select 3);
        for "_i" from 1 to (_x select 1) do {
            if (BO_State == "play") then { [[[_x select 0, 0]]] call BO_fnc_spawnBloons };
            sleep (_x select 2);
        };
    } forEach (_row select R_GROUPS);
    waitUntil { sleep 0.5; BO_State != "play" || { count BO_Alive == 0 && count BO_SpawnQueue == 0 } };
    if (BO_State == "play") then {
        _bonus = CFG_ROUND_BONUS_BASE + BO_Round;
        { if (!isNull _x) then { _bonus = _bonus + ((_x getVariable "bo_stats") select T_INCOME) } } forEach BO_TowerList;
        BO_Cash = BO_Cash + _bonus;
        BO_CashDirty = true;
        BO_RoundActive = false;
        publicVariable "BO_RoundActive";
        diag_log format ["[BloonsOps] round %1 cleared, lives %2, cash %3", BO_Round, BO_Lives, BO_Cash];
        if (BO_Round >= CFG_FINAL_ROUND) then { [true] call BO_fnc_gameOver } else {
            ["BO_fnc_notify", [format ["Round %1 cleared! +$%2 (bonus and bananas)", BO_Round, _bonus], "round"]] call BO_fnc_netAll;
        };
    };
};
