/*
    Client: key of the tower within 6 m of the player, or -1.
*/
private _best = 6;
private _key = -1;
{
    private _d = player distance2D (_x#3);
    if (_d < _best) then {_best = _d; _key = _x#0};
} forEach BTD_TowerList;
_key
