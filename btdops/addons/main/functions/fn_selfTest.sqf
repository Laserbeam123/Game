/*
    Self Test scenario (server + local player): builds every tower, upgrades it, checks the glide,
    plays every round at high speed, and writes [BTDOPS][TEST] PASS/FAIL lines to the RPT log.
*/
private _fails = 0;
private _check = {
    params ["_name", "_ok", ["_info", ""]];
    diag_log format ["[BTDOPS][TEST] %1 %2 %3", ["FAIL", "PASS"] select _ok, _name, _info];
    if (!_ok) then {_fails = _fails + 1};
};
waitUntil {!isNil "BTD_ServerReady" && {!isNil "BTD_CLive"}};
uiSleep 3;

["track length", (BTD_Track#2) > 300, format ["%1 m", round (BTD_Track#2)]] call _check;
["BTD6 art pack", true, format ["present %1 (stand-ins are used without it)", isClass (configFile >> "CfgPatches" >> "btdops_art")]] call _check;
{
    private _tex = [_y get "art"] call BTD_fnc_artTexture;
    [format ["texture %1", _x], fileExists _tex, _tex] call _check;
} forEach BTD_Bloons;
{
    if ((_y get "recipe") != "none") then {
        private _f = format ["\z\btdops\addons\main\sounds\%1.ogg", _x];
        [format ["sound %1", _x], fileExists _f, _f] call _check;
    };
} forEach BTD_Sounds;

// glide: 3 s of "forward", then let go
player setPosATL (BTD_SpawnPos vectorAdd [0, -30, 0]);
uiSleep 1;
private _p0 = getPosATL player;
BTD_GlideTest = [1, 0];
private _anims = [];
for "_i" from 1 to 6 do {uiSleep 0.5; _anims pushBackUnique animationState player};
private _height = (getPosATL player)#2;
BTD_GlideTest = [0, 0];
uiSleep 2;
BTD_GlideTest = nil;
private _moved = _p0 distance2D (getPosATL player);
["glide moves", _moved > 15, format ["%1 m in ~5 s", round _moved]] call _check;
["glide hovers", _height > 0.4 && _height < 1.8, format ["%1 m above ground", _height toFixed 2]] call _check;
["glide animation", (_anims findIf {"fal" in toLower _x || "para" in toLower _x || "halo" in toLower _x}) < 0, str _anims] call _check;

// build every tower beside the track, then upgrade it
BTD_Cash = 1e6;
private _i = 0;
{
    private _row = BTD_Towers get _x;
    private _tp = ([60 + _i * 45] call BTD_fnc_trackPos);
    private _p = (_tp#0) getPos [7, (_tp#1) + 90];
    private _key = [_x, _p] call BTD_fnc_requestBuild;
    [format ["build %1", _x], !isNil "_key", str _p] call _check;
    if (!isNil "_key") then {
        [_key] call BTD_fnc_requestUpgrade;
        private _t = BTD_TowerList select (BTD_TowerList findIf {(_x#0) == _key});
        [format ["upgrade %1", _x], _t#2] call _check;
        private _o = (BTD_TowerObjs get _key)#0;
        if ((_row get "section") == "ARMA") then {
            _o params ["_veh", "_unit"];
            if ((_row get "object_class") != "none") then {
                [format ["%1 object", _x], !isNull _veh && {typeOf _veh == (_row get "object_class")}, typeOf _veh] call _check;
                [format ["%1 gunner", _x], !isNull _unit && {gunner _veh == _unit}, str (crew _veh)] call _check;
                [format ["%1 weapon", _x], count (weapons _veh) > 0, str (weapons _veh)] call _check;
            } else {
                [format ["%1 soldier", _x], !isNull _unit && {primaryWeapon _unit != ""}, primaryWeapon _unit] call _check;
            };
        };
    };
    _i = _i + 1;
} forEach BTD_TowerOrder;
BTD_Cash = 1e6;

// play every round at x4
BTD_Clock = [[time, serverTime] select isMultiplayer, call BTD_fnc_now, 4];
publicVariable "BTD_Clock";
private _livesStart = BTD_Lives;
for "_r" from 1 to BTD_RoundCount do {
    [] call BTD_fnc_requestRound;
    private _t0 = diag_tickTime;
    waitUntil {uiSleep 0.5; !BTD_RoundRunning || BTD_GameOver || (diag_tickTime - _t0) > 240};
    [format ["round %1 ends", _r], !BTD_RoundRunning || BTD_GameOver, format ["%1 s, lives %2, cash %3, drawn bloons %4", round (diag_tickTime - _t0), BTD_Lives, BTD_Cash, count BTD_CPos]] call _check;
    if (BTD_GameOver) exitWith {};
    BTD_Cash = 1e6;
};
["all rounds cleared", BTD_GameOver && BTD_Lives > 0, format ["lives %1 of %2", BTD_Lives, _livesStart]] call _check;
diag_log format ["[BTDOPS][TEST] DONE: %1 failure(s)", _fails];
hint format ["Bloons TD Ops self test done: %1 failure(s). Details in the RPT log.", _fails];
