// Server: automated in-game check (the "Bloons Ops - Self Test" scenario). Builds and upgrades every tower,
// plays every round with test cash, and logs [BloonsOps][TEST] PASS/FAIL lines to the RPT log.
if (!isServer) exitWith {};
private _log = { diag_log format ["[BloonsOps][TEST] %1", _this] };
private _check = { params ["_ok", "_what"]; format ["%1 %2", ["FAIL", "PASS"] select _ok, _what] call _log; _ok };
waitUntil { sleep 0.5; !isNil "BO_State" && { BO_State == "play" } };
waitUntil { sleep 0.5; allPlayers isNotEqualTo [] || !isMultiplayer };
if (!isMultiplayer) then { setAccTime 4 };
private _fails = 0;
private _player = if (isMultiplayer) then { allPlayers select 0 } else { player };

if !([BO_PathLen >= (BO_Cfg get "track_min_m"), format ["track %1 m, %2 points", round BO_PathLen, count BO_Path]] call _check) then { _fails = _fails + 1 };
{
    private _f = "z\bloonsops\addons\main\" + (_y get "file");
    if !([fileExists _f, "sound " + _f] call _check) then { _fails = _fails + 1 };
} forEach BO_Sounds;

BO_Cash = 100000;
publicVariable "BO_Cash";
{
    private _d = BO_PathLen * (0.25 + _forEachIndex * 0.15);
    private _a = [_d] call BO_fnc_pathPos;
    private _b = [_d + 2] call BO_fnc_pathPos;
    private _pos = _a getPos [9, (_a getDir _b) + 90];
    _pos set [2, 0];
    [_player, _x, _pos] call BO_fnc_requestBuild;
} forEach BO_TowerOrder;
sleep 1;
{
    private _t = _x;
    private _row = BO_Towers get (_t getVariable "bo_type");
    if ((_row get "kind") == "static") then {
        if !([!isNull gunner _t && { (_t weaponsTurret [0]) isNotEqualTo [] }, format ["%1 has gunner and weapon %2", _row get "name", _t weaponsTurret [0]]] call _check) then { _fails = _fails + 1 };
    } else {
        if !([count ((_t getVariable ["bo_crew", []]) select { alive _x }) == (_row get "crew_count"), format ["%1 crew of %2", _row get "name", _row get "crew_count"]] call _check) then { _fails = _fails + 1 };
    };
    if !([(_t getVariable ["bo_cover", []]) isNotEqualTo [], format ["%1 covers track %2", _row get "name", _t getVariable "bo_cover"]] call _check) then { _fails = _fails + 1 };
    [_player, _t] call BO_fnc_requestUpgrade;
} forEach BO_TowerList;
if !([count BO_TowerList == count BO_TowerOrder, format ["%1 of %2 towers built", count BO_TowerList, count BO_TowerOrder]] call _check) then { _fails = _fails + 1 };
if (hasInterface && { BO_Btd6Has isNotEqualTo [] }) then {
    private _want = { (_x getVariable ["bo_type", ""]) in BO_Btd6Has } count BO_TowerList;
    private _boards = missionNamespace getVariable ["BO_Boards", []];
    if !([count _boards == _want && { _boards findIf { (getObjectTextures (_x select 0)) isEqualTo [] } < 0 }, format ["%1 BTD6 tower billboards with textures (want %2)", count _boards, _want]] call _check) then { _fails = _fails + 1 };
} else {
    "INFO BTD6 art pack not installed: towers and bloons use the Bloons Ops look" call _log;
};

for "_r" from 1 to (BO_Cfg get "final_round") do {
    if (BO_State != "play") exitWith {};
    private _lives = BO_Lives;
    private _t0 = time;
    [] call BO_fnc_startRound;
    waitUntil { sleep 1; !BO_RoundActive || BO_State != "play" || time - _t0 > 300 };
    format ["round %1 done in %2 s: lives %3 -> %4, cash %5, live bloons %6", _r, round (time - _t0), _lives, BO_Lives, BO_Cash, count BO_Live] call _log;
    if (time - _t0 > 300) exitWith { [false, format ["round %1 timed out", _r]] call _check; _fails = _fails + 1 };
};
format ["DONE: %1 failure(s), reached round %2, lives %3, state %4", _fails, BO_Round, BO_Lives, BO_State] call _log;
