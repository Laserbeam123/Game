// Headless logic tests for the Arma 2: OA edition, run in SQF-VM by tests/run_sqfvm_oa.py.
#include "\z\bloonsops_oa\addons\main\script.hpp"
BO_fails = 0;
BO_check = { if (!(_this select 0)) then { BO_fails = BO_fails + 1 }; diag_log format ["%1 %2", if (_this select 0) then {"PASS"} else {"FAIL"}, _this select 1] };

[count BO_Bloons == 7 && count BO_Towers == 15 && count BO_Upgrades == 15, "sheets load as OA arrays (7 bloons, 15 towers, 15 upgrades)"] call BO_check;
[((BO_Towers select TROW_GHOST_HAWK) select T_OA_OBJECT_CLASS) == "UH60M_EP1", "Ghost Hawk row builds a UH-60M in OA"] call BO_check;
[((BO_Bloons select BROW_BLUE) select B_CHILD) == BROW_RED, "bloon child refs become row indexes"] call BO_check;
[CFG_START_CASH == 650 && CFG_FINAL_ROUND == 20, "economy constants via CFG_ macros"] call BO_check;
[PROP_HELIPAD == "HeliH", "props sheet gives OA classes"] call BO_check;

BO_Path = [[0,0,0],[600,0,0],[600,400,0]];
BO_PathCum = [0, 600, 1000];
BO_PathLen = 1000;
private ["_p", "_ids", "_e", "_r"];
_p = [800] call BO_fnc_pathPos;
[(_p select 0) == 600 && (_p select 1) == 200, format ["pathPos 800 m -> %1", _p]] call BO_check;
_p = [[0,0,0],[3,4,0]] call BO_fnc_dist2D;
[_p == 5, "dist2D 3-4-5"] call BO_check;

BO_T = 0; BO_State = "play";
BO_Live = []; BO_Alive = []; BO_NextId = 0; BO_SpawnQueue = []; BO_PopQueue = []; BO_RebaseQueue = []; BO_Cash = 0; BO_CashDirty = false;
_ids = [[[BROW_PINK, 100]]] call BO_fnc_spawnBloons;
BO_T = 2;
[_ids select 0, 1, false] call BO_fnc_damageBloon;
_e = BO_Live select (BO_Alive select 0);
[count BO_Alive == 1 && (_e select 0) == BROW_YELLOW && abs ((_e select 1) - 142) < 0.01 && BO_Cash == 1, format ["pink hit -> yellow at 142 m, $1: %1", _e]] call BO_check;

BO_Live = []; BO_Alive = []; BO_Cash = 0;
_ids = [[[BROW_LEAD, 50]]] call BO_fnc_spawnBloons;
_r = [_ids select 0, 5, false] call BO_fnc_damageBloon;
[!_r && count BO_Alive == 1, "bullets bounce off lead"] call BO_check;
[_ids select 0, 1, true] call BO_fnc_damageBloon;
[count BO_Alive == 2 && ((BO_Live select (BO_Alive select 0)) select 0) == BROW_PINK, "explosive on lead -> 2 pinks"] call BO_check;

{
    BO_Live = []; BO_Alive = []; BO_Cash = 0;
    [[[_forEachIndex, 0]]] call BO_fnc_spawnBloons;
    while { count BO_Alive > 0 } do { { [_x, 1, true] call BO_fnc_damageBloon } forEach (+BO_Alive) };
    [BO_Cash == (_x select B_LIVES_COST), format ["fully popping %1 pays $%2", _x select B_ID, BO_Cash]] call BO_check;
} forEach BO_Bloons;

BO_Live = []; BO_Alive = []; BO_T = 0;
_ids = [[[BROW_RED, 100]]] call BO_fnc_spawnBloons;
BO_T = 1;
[_ids select 0, 0.5, 6] call BO_fnc_slowBloon;
_e = BO_Live select (_ids select 0);
BO_T = 3;
[abs (([_e, BO_T] call BO_fnc_bloonDist) - 112) < 0.01, "glued red: half speed after re-base"] call BO_check;
[_ids select 0, 0, 1.2] call BO_fnc_slowBloon;
_e = BO_Live select (_ids select 0);
BO_T = 4;
[abs (([_e, BO_T] call BO_fnc_bloonDist) - 112) < 0.01, "frozen bloon stays put"] call BO_check;

private ["_cov"];
_cov = [[300, 10, 0], 25] call BO_fnc_towerCoverage;
[count _cov == 1, format ["tower coverage %1", _cov]] call BO_check;

diag_log format ["RESULT %1 failure(s)", BO_fails];
