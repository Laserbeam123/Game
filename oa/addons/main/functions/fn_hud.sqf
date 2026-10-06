// Client: cash / lives / round readout, and the Upgrade / Sell / Take-the-gun actions for the nearest tower
// (OA has no setUserActionText, so they are re-added whenever the nearest tower changes).
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_d", "_near", "_best", "_dist", "_reach", "_row", "_up", "_state"];
"BO_HudLayer" cutRsc ["BO_Hud", "PLAIN"];
while { true } do {
    _d = uiNamespace getVariable "BO_Hud";
    if (isNil "_d") then { _d = displayNull };
    if (isNull _d) then { "BO_HudLayer" cutRsc ["BO_Hud", "PLAIN"] } else {
        _state = "<t color='#FF8C00'>(in progress)</t>";
        if (!BO_RoundActive) then { _state = "<t color='#7CFC00'>(ready)</t>" };
        (_d displayCtrl 1100) ctrlSetStructuredText parseText format [
            "<t size='1.15'>BLOONS OPS: ARROWHEAD</t><br/><t color='#FFD700'>$%1</t>   <t color='#FF6060'>Lives %2</t><br/>Round %3 / %4 %5<br/><t size='0.85'>Bloons on track: %6</t>",
            BO_Cash, BO_Lives max 0, BO_Round, BO_FinalRound, _state, count BO_LocalIds];
    };

    _near = objNull;
    _best = 1e9;
    {
        if (!isNull _x) then {
            _dist = [getPosATL _x, getPosATL player] call BO_fnc_dist2D;
            _reach = 6;
            if (!isNull (_x getVariable "bo_heli")) then { _reach = 9 };
            if (_dist < _reach && _dist < _best) then { _best = _dist; _near = _x };
        };
    } forEach BO_ClientTowers;
    BO_Near = _near;
    if (_near != BO_NearShown || { !isNull _near && { (_near getVariable "bo_upgraded") && count BO_NearActs == 3 } }) then {
        { player removeAction _x } forEach BO_NearActs;
        BO_NearActs = [];
        BO_NearShown = _near;
        if (!isNull _near) then {
            _row = TOWER(_near getVariable "bo_type");
            if (!(_near getVariable "bo_upgraded")) then {
                _up = BO_Upgrades select (_row select T_UPGRADE);
                BO_NearActs set [count BO_NearActs, player addAction [format ["<t color='#7CFC00'>Upgrade %1: %2 ($%3)</t>", _row select T_OA_NAME, _up select U_NAME, _up select U_COST], ACT("act_upgrade.sqf"), [], 5, false, true, "", "vehicle _this == _this"]]
            };
            if (_row select T_MANNABLE) then {
                BO_NearActs set [count BO_NearActs, player addAction [format ["<t color='#00BFFF'>Take the %1 yourself</t>", _row select T_OA_NAME], ACT("act_man.sqf"), [], 4.9, true, true, "", "vehicle _this == _this && !isPlayer (gunner BO_Near)"]]
            };
            BO_NearActs set [count BO_NearActs, player addAction [format ["<t color='#FF8C00'>Sell %1 ($%2)</t>", _row select T_OA_NAME, floor ((_near getVariable "bo_spent") * CFG_SELL_RATIO)], ACT("act_sell.sqf"), [], 1, false, true, "", "vehicle _this == _this"]]
        };
    };
    sleep 0.25;
};
