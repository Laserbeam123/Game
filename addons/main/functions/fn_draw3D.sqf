// Client, Draw3D: bloon strings, shot streaks, and tower name tags.
private _black = [0.05, 0.05, 0.05, 1];
{
    private _k = _y select 6;
    if (!isNull _k && { (_k distance player) < 120 }) then {
        private _a = ASLToAGL (getPosASL _k);
        drawLine3D [_a, _a vectorAdd [0.05, 0, -1.1], _black, 2];
    };
} forEach BO_LocalBloons;

private _t = diag_tickTime;
BO_Fx = BO_Fx select { (_x select 3) > _t };
{
    _x params ["_from", "_to", "_c"];
    drawLine3D [ASLToAGL _from, ASLToAGL _to, _c, 6];
} forEach BO_Fx;

{
    if (!isNull _x && { (_x distance player) < 45 }) then {
        private _row = BO_Towers getOrDefault [_x getVariable ["bo_type", ""], createHashMap];
        if (count _row > 0) then {
            private _arma = (_row get "section") == "arma";
            private _h = [3.2, 2.6] select ((_row get "kind") in ["monkey", "farm"]);
            drawIcon3D ["", [[1, 0.85, 0.2, 1], [0.75, 0.95, 0.55, 1]] select _arma, (ASLToAGL getPosASL _x) vectorAdd [0, 0, _h], 0, 0, 0,
                (_row get "name") + (["", " +"] select (_x getVariable ["bo_upgraded", false])), 2, 0.035, "PuristaBold"];
        };
    };
} forEach BO_ClientTowers;
