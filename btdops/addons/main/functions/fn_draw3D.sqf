/*
    Client, every frame: bloons and BTD6 monkeys as camera-facing billboards sized to the world,
    the track line, the nearest tower's range ring, and shot effects. Also refreshes BTD_CPos
    (bloon centres, ASL) for shotTick.
*/
private _now = call BTD_fnc_now;
private _cam = positionCameraToWorld [0, 0, 0];
private _scale = BTD_Const get "icon_scale";
private _minSize = BTD_Const get "icon_min_size";
private _total = BTD_Track#2;
private _pos = [];

// track centre line
private _pts = BTD_Track#0;
for "_i" from 0 to (count _pts - 2) do {
    drawLine3D [(_pts#_i) vectorAdd [0, 0, 0.15], (_pts#(_i + 1)) vectorAdd [0, 0, 0.15], [1, 0.85, 0.3, 0.6]];
};

{
    private _d = [_y, _now] call BTD_fnc_bloonDist;
    if (_d < _total) then {
        private _b = BTD_Bloons get (_y#0);
        private _size = _b get "size_m";
        private _p = ([_d] call BTD_fnc_trackPos)#0;
        _p set [2, 0.5 + _size * 0.6];
        private _w = (_scale * _size / ((_cam distance _p) max 1)) max _minSize;
        private _col = [[1, 1, 1, 1], [0.55, 0.8, 1, 1]] select (_now < (_y#4) && {(_y#3) < 0.5});
        private _txt = ["", format ["%1", _y#5]] select (_b get "is_moab");
        drawIcon3D [[_b get "art"] call BTD_fnc_artTexture, _col, _p, _w, _w, 0, _txt, 2, 0.05, "PuristaBold", "center"];
        _pos pushBack [_x, AGLToASL _p, _size * 0.55];
    };
} forEach BTD_CLive;
BTD_CPos = _pos;

// BTD6 monkeys, tower names up close, range ring of the tower you stand next to
{
    _x params ["_key", "_rowId", "_upg", "_tp"];
    private _row = BTD_Towers get _rowId;
    private _dist = _cam distance _tp;
    if (_row get "section" == "BTD6") then {
        private _h = _row get "billboard_m";
        private _w = (_scale * _h / (_dist max 1)) max _minSize;
        drawIcon3D [[_row get "art"] call BTD_fnc_artTexture, [1, 1, 1, 1], _tp vectorAdd [0, 0, _h * 0.5], _w, _w, 0, "", 0];
    };
    if (_dist < 25) then {
        drawIcon3D ["", [1, 1, 1, 0.9], _tp vectorAdd [0, 0, 2.8], 0, 0, 0, (_row get "name") + (["", " +"] select _upg), 2, 0.035, "PuristaMedium", "center"];
    };
    if (_key == BTD_NearTower) then {
        private _r = ([_rowId, _upg] call BTD_fnc_towerStats) get "range_m";
        for "_a" from 0 to 350 step 10 do {
            drawLine3D [_tp getPos [_r, _a] vectorAdd [0, 0, 0.3], _tp getPos [_r, _a + 10] vectorAdd [0, 0, 0.3], [1, 1, 1, 0.7]];
        };
    };
} forEach BTD_TowerList;

// shot effects: [kind, from, to, startTick, duration, aoe]
private _t = diag_tickTime;
BTD_Effects = BTD_Effects select {(_t - (_x#3)) < (_x#4)};
{
    _x params ["_kind", "_from", "_to", "_t0", "_dur", "_aoe"];
    private _f = (_t - _t0) / _dur;
    switch (_kind) do {
        case "tracer": {drawLine3D [_from vectorAdd [0, 0, 1.2], _to vectorAdd [0, 0, 1.2], [1, 0.9, 0.4, 1 - _f]]};
        case "dart": {
            private _p = (_from vectorAdd [0, 0, 1.6]) vectorAdd (((_to vectorAdd [0, 0, 1.2]) vectorDiff (_from vectorAdd [0, 0, 1.6])) vectorMultiply _f);
            drawIcon3D ["\a3\ui_f\data\map\markers\military\arrow2_ca.paa", [0.3, 0.2, 0.1, 1], _p, 0.6, 0.6, (_from getDir _to), "", 0];
        };
        case "bomb";
        case "frost";
        case "pop";
        case "place";
        case "sell": {
            private _col = switch (_kind) do {
                case "bomb": {[1, 0.55, 0.1, 1 - _f]};
                case "frost": {[0.6, 0.9, 1, 1 - _f]};
                case "pop": {[1, 1, 1, 1 - _f]};
                default {[1, 0.85, 0.2, 1 - _f]};
            };
            private _r = ([1.2, _aoe] select (_aoe > 0)) * (0.3 + 0.7 * _f);
            private _c = [_to, _from] select (_kind in ["frost", "place", "sell"]);
            for "_a" from 0 to 330 step 30 do {
                drawLine3D [_c getPos [_r, _a] vectorAdd [0, 0, 1], _c getPos [_r, _a + 30] vectorAdd [0, 0, 1], _col];
            };
        };
        default {};
    };
} forEach BTD_Effects;
