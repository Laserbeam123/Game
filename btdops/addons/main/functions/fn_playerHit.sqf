/*
    Client -> server: a player's bullet crossed bloon _id. Bullets don't pop lead.
*/
params ["_id"];
if (!isServer || {BTD_GameOver}) exitWith {};
[_id, BTD_Const get "player_shot_damage", false] call BTD_fnc_damageBloon;
