/*
    Client -> server: a player's grenade or rocket exploded at _pos (ASL). Blasts pop lead.
*/
params ["_pos"];
if (!isServer || {BTD_GameOver}) exitWith {};
private _now = call BTD_fnc_now;
private _r = BTD_Const get "player_blast_m";
private _hits = [];
{
    private _p = ([[_y, _now] call BTD_fnc_bloonDist] call BTD_fnc_trackPos)#0;
    if ((_p distance2D _pos) <= _r) then {_hits pushBack _x};
} forEach BTD_Live;
_hits resize ((count _hits) min (BTD_Const get "player_blast_pierce"));
{ [_x, 1, true] call BTD_fnc_damageBloon } forEach _hits;
