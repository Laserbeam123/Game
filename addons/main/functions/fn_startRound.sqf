// Server: a player pressed "Start Next Round". Spawns the round's groups, pays the bonus when it is clear.
if (!isServer) exitWith {};
if (BO_State != "play" || BO_RoundActive || BO_Round >= (BO_Cfg get "final_round")) exitWith {};
BO_Round = BO_Round + 1;
BO_RoundActive = true;
publicVariable "BO_Round";
publicVariable "BO_RoundActive";
private _row = BO_Rounds select (BO_Round - 1);
private _tip = _row get "tip";
[format ["Round %1%2", BO_Round, ["", " - " + _tip] select (_tip != "")], "round"] remoteExecCall ["BO_fnc_notify", 0];
diag_log format ["[BloonsOps] round %1 start", BO_Round];

[_row] spawn {
    params ["_row"];
    {
        _x params ["_type", "_count", "_spacing", "_delay"];
        sleep _delay;
        for "_i" from 1 to _count do {
            if (BO_State != "play") exitWith {};
            [[[_type, 0]]] call BO_fnc_spawnBloons;
            sleep _spacing;
        };
    } forEach (_row get "groups");
    waitUntil { sleep 0.5; BO_State != "play" || { count BO_Live == 0 && BO_SpawnQueue isEqualTo [] } };
    if (BO_State != "play") exitWith {};
    private _bonus = (BO_Cfg get "round_bonus_base") + BO_Round;
    BO_Cash = BO_Cash + _bonus;
    BO_CashDirty = true;
    BO_RoundActive = false;
    publicVariable "BO_RoundActive";
    diag_log format ["[BloonsOps] round %1 cleared, lives %2, cash %3", BO_Round, BO_Lives, BO_Cash];
    if (BO_Round >= (BO_Cfg get "final_round")) then {
        [true] call BO_fnc_gameOver;
    } else {
        [format ["Round %1 cleared! +$%2", BO_Round, _bonus], "round"] remoteExecCall ["BO_fnc_notify", 0];
    };
};
