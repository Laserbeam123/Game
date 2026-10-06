// Headless logic tests for Bloons Ops, run in SQF-VM by tests/run_sqfvm.py.
// The real fn_*.sqf files are loaded as BO_fnc_*; only the clock is replaced (BO_T).
BO_fails = 0;
// SQF-VM cannot iterate hashmaps: bloon ids are sequential, so list them by id instead
BO_t_keys = { private _o = []; for "_i" from 0 to (BO_NextId - 1) do { if (_i in BO_Live) then { _o pushBack _i } }; _o };
BO_t_values = { (call BO_t_keys) apply { BO_Live get _x } };
BO_t_count = { count (call BO_t_keys) };
BO_check = { params ["_ok", "_what"]; if (!_ok) then { BO_fails = BO_fails + 1 }; diag_log format ["%1 %2", ["FAIL", "PASS"] select _ok, _what] };

// --- data from the sheets
[count BO_Bloons == 7, "7 bloon rows loaded"] call BO_check;
[count BO_Towers == 15 && count BO_Upgrades == 15, "15 towers (6 Arma + 9 BTD) and 15 upgrades loaded"] call BO_check;
[({ ((BO_Towers get _x) get "section") == "btd" } count BO_TowerOrder) == 9, "9 towers in the BLOONS TD section"] call BO_check;
[count BO_Rounds == (BO_Cfg get "final_round"), "rounds 1..final_round loaded"] call BO_check;

// --- track: an L-shaped road, 600 m east then 400 m north
BO_Path = [[0,0,0],[600,0,0],[600,400,0]];
BO_PathCum = [0, 600, 1000];
BO_PathLen = 1000;
private _p = [300] call BO_fnc_pathPos;
[(_p select 0) == 300 && (_p select 1) == 0, format ["pathPos 300 m -> %1", _p]] call BO_check;
_p = [800] call BO_fnc_pathPos;
[(_p select 0) == 600 && (_p select 1) == 200, format ["pathPos 800 m -> %1 (around the corner)", _p]] call BO_check;
_p = [5000] call BO_fnc_pathPos;
[(_p select 1) == 400, "pathPos past the end clamps to the exit"] call BO_check;

// --- tower coverage: tower 10 m north of the 300 m mark, range 25 m
private _cov = [[300, 10, 0], 25] call BO_fnc_towerCoverage;
[count _cov == 1 && { abs (((_cov select 0) select 0) - 278) <= 2 && abs (((_cov select 0) select 1) - 322) <= 2 }, format ["coverage of a 25 m tower is ~[278,322]: %1", _cov]] call BO_check;
_cov = [[590, 10, 0], 30] call BO_fnc_towerCoverage;
[count _cov == 1 && { ((_cov select 0) select 0) < 600 && ((_cov select 0) select 1) > 600 }, format ["coverage wraps the corner: %1", _cov]] call BO_check;

// --- server state
BO_T = 0;
BO_State = "play";
BO_Live = createHashMap; BO_NextId = 0; BO_SpawnQueue = []; BO_PopQueue = []; BO_LeakQueue = []; BO_RebaseQueue = [];
BO_Cash = 0; BO_CashDirty = false;

private _ids = [[["pink", 100]]] call BO_fnc_spawnBloons;
[(call BO_t_count) == 1 && count BO_SpawnQueue == 1, "spawn registers and queues a bloon"] call BO_check;
BO_T = 2;
[(_ids select 0), 1, false] call BO_fnc_damageBloon;
private _kids = (call BO_t_values);
[count _kids == 1 && { ((_kids select 0) select 0) == "yellow" }, format ["pink hit once -> yellow: %1", _kids]] call BO_check;
[abs (((_kids select 0) select 1) - (100 + 21 * 2)) < 0.01, format ["child starts where the parent was (142 m): %1", (_kids select 0) select 1]] call BO_check;
[BO_Cash == 1 && BO_PopQueue isEqualTo [0], "1 cash and a pop broadcast per layer"] call BO_check;

// damage carries through layers
BO_Live = createHashMap; BO_Cash = 0;
_ids = [[["pink", 0]]] call BO_fnc_spawnBloons;
[(_ids select 0), 3, false] call BO_fnc_damageBloon;
_kids = (call BO_t_values);
[count _kids == 1 && { ((_kids select 0) select 0) == "blue" } && BO_Cash == 3, format ["3 damage on pink -> blue, $3: %1 $%2", _kids, BO_Cash]] call BO_check;

// a red bloon pops completely
BO_Live = createHashMap; BO_Cash = 0;
_ids = [[["red", 0]]] call BO_fnc_spawnBloons;
[(_ids select 0), 1, false] call BO_fnc_damageBloon;
[(call BO_t_count) == 0 && BO_Cash == 1, "red pops to nothing"] call BO_check;

// lead
BO_Live = createHashMap; BO_Cash = 0;
_ids = [[["lead", 50]]] call BO_fnc_spawnBloons;
private _r = [(_ids select 0), 5, false] call BO_fnc_damageBloon;
[!_r && (call BO_t_count) == 1 && BO_Cash == 0, "bullets bounce off lead"] call BO_check;
_r = [(_ids select 0), 1, true] call BO_fnc_damageBloon;
_kids = (call BO_t_values);
[_r && count _kids == 2 && { (_kids findIf { (_x select 0) != "pink" }) < 0 }, format ["explosive on lead -> 2 pinks: %1", _kids]] call BO_check;

// popping everything a bloon holds pays its full lives_cost (RBE) in cash
{
    BO_Live = createHashMap; BO_Cash = 0;
    private _type = _x;
    _ids = [[[_type, 0]]] call BO_fnc_spawnBloons;
    private _guard = 0;
    while { (call BO_t_count) > 0 && _guard < 100 } do {
        { [_x, 1, true] call BO_fnc_damageBloon } forEach ((call BO_t_keys));
        _guard = _guard + 1;
    };
    [BO_Cash == ((BO_Bloons get _type) get "lives_cost"), format ["fully popping %1 pays $%2 (lives_cost %3)", _type, BO_Cash, (BO_Bloons get _type) get "lives_cost"]] call BO_check;
} forEach ["red","blue","green","yellow","pink","lead","camo_green"];

// a stale id (already popped) is ignored
BO_Cash = 0;
_r = [987654, 1, true] call BO_fnc_damageBloon;
[!_r && BO_Cash == 0, "damage to an already-popped bloon is ignored"] call BO_check;

// nothing happens once the game is over
BO_Live = createHashMap; BO_State = "over";
_ids = [[["red", 0]]] call BO_fnc_spawnBloons;
_r = [(_ids select 0), 1, true] call BO_fnc_damageBloon;
[!_r && (call BO_t_count) == 1, "no pops after game over"] call BO_check;
BO_State = "play";

// --- slows and freezes (glue / ice)
BO_Live = createHashMap; BO_T = 0;
_ids = [[["red", 100]]] call BO_fnc_spawnBloons;
BO_T = 1;
[(_ids select 0), 0.5, 6] call BO_fnc_slowBloon;
private _e = BO_Live get (_ids select 0);
[abs ((_e select 1) - 106) < 0.01 && (_e select 3) == 0.5 && (_e select 4) == 7, format ["glue re-bases at 106 m, half speed until t=7: %1", _e]] call BO_check;
[count BO_RebaseQueue == 1, "the slow is queued for clients"] call BO_check;
BO_T = 3;
[abs (([_e, BO_T] call BO_fnc_bloonDist) - 112) < 0.01, "glued red moves 6 m in 2 s (half of 6 m/s)"] call BO_check;
[(_ids select 0), 0, 1.2] call BO_fnc_slowBloon;
_e = BO_Live get (_ids select 0);
BO_T = 4;
[abs (([_e, BO_T] call BO_fnc_bloonDist) - 112) < 0.01, "frozen bloon stays put"] call BO_check;
[(_ids select 0), 0.5, 1] call BO_fnc_slowBloon;
[((BO_Live get (_ids select 0)) select 3) == 0, "a weaker slow does not thaw a freeze"] call BO_check;
BO_Live = createHashMap; BO_T = 0;
_ids = [[["blue", 50]]] call BO_fnc_spawnBloons;
[(_ids select 0), 0, 2] call BO_fnc_slowBloon;
[(_ids select 0), 1, false] call BO_fnc_damageBloon;
_kids = call BO_t_values;
[count _kids == 1 && { ((_kids select 0) select 3) == 0 }, format ["a frozen blue's red stays frozen: %1", _kids]] call BO_check;
_r = [((call BO_t_keys) select 0), 0, false] call BO_fnc_damageBloon;
[!_r && (call BO_t_count) == 1, "zero damage (glue) pops nothing"] call BO_check;

// --- every round's total threat, and the start cash can afford a tower
private _rbe = [];
{
    private _sum = 0;
    { _sum = _sum + (_x select 1) * ((BO_Bloons get (_x select 0)) get "lives_cost") } forEach (_x get "groups");
    _rbe pushBack _sum;
} forEach BO_Rounds;
diag_log format ["INFO red-bloon-equivalents per round: %1", _rbe];
private _cheapest = 1e9;
{ _cheapest = _cheapest min ((BO_Towers get _x) get "cost") } forEach BO_TowerOrder;
[(BO_Cfg get "start_cash") >= _cheapest * 2, format ["start cash $%1 buys at least two of the cheapest tower ($%2)", BO_Cfg get "start_cash", _cheapest]] call BO_check;

diag_log format ["RESULT %1 failure(s)", BO_fails];
