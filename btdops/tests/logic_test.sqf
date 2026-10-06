// Headless logic tests for Bloon Strike: Altis, run by tests/run_sqfvm.py against the real functions.
TEST_fails = 0;
TEST_check = {
    params ["_name", "_ok", ["_info", ""]];
    diag_log format ["[TEST] %1 %2 %3", ["FAIL", "PASS"] select _ok, _name, _info];
    if (!_ok) then {TEST_fails = TEST_fails + 1};
};
TEST_T = 0;
BTD_fnc_now = {TEST_T};
BTD_fnc_notify = {};
BTD_fnc_createTower = {[objNull, objNull]};
TEST_reset = {
    BTD_Track = [BTD_Maps get "altis_airfield"] call BTD_fnc_buildTrack;
    BTD_Live = createHashMap; BTD_NextId = 1; BTD_Batch = [[], [], [], [], [], []];
    BTD_Schedule = []; BTD_TowerObjs = createHashMap; BTD_TowerKey = 0; BTD_Dirty = false;
    BTD_Cash = BTD_Const get "start_cash"; BTD_Lives = BTD_Const get "start_lives";
    BTD_Round = 0; BTD_RoundRunning = false; BTD_GameOver = false; BTD_TowerList = [];
    TEST_T = 0;
};
TEST_near = { params ["_a", "_b", ["_eps", 0.01]]; abs (_a - _b) < _eps };

call BTD_fnc_initData;
call TEST_reset;

// --- data
["7 bloon types", count (keys BTD_Bloons) == 7] call TEST_check;
["6 towers, 3 per section", count BTD_TowerOrder == 6 && {({(BTD_Towers get _x) get "section" == "ARMA"} count BTD_TowerOrder) == 3}] call TEST_check;
["10 rounds", BTD_RoundCount == 10] call TEST_check;
["MOAB on rounds 5 and 10", ((BTD_Rounds get "r05") get "boss") && ((BTD_Rounds get "r10") get "boss") && !((BTD_Rounds get "r04") get "boss")] call TEST_check;
// lives_cost is the bloon's total layers (rbe): own hp plus its children's
{
    private _rbe = {
        private _b = BTD_Bloons get _this;
        private _sum = _b get "rbe_hp";
        { _sum = _sum + (_x call _rbe) } forEach (_b get "children");
        _sum
    };
    [format ["%1 lives_cost = layers", _x], ((BTD_Bloons get _x) get "lives_cost") == (_x call _rbe), str (_x call _rbe)] call TEST_check;
} forEach (keys BTD_Bloons);

// --- track
private _total = BTD_Track#2;
["track length 730 m", [_total, 730] call TEST_near, str _total] call TEST_check;
private _c = (BTD_Maps get "altis_airfield") get "center";
private _p0 = ([0] call BTD_fnc_trackPos)#0;
["track starts at first point", [_p0#0, (_c#0) - 110] call TEST_near && [_p0#1, (_c#1) - 55] call TEST_near, str _p0] call TEST_check;
private _p1 = ([250] call BTD_fnc_trackPos);
["track turns the first corner", [(_p1#0)#0, (_c#0) + 100] call TEST_near && [(_p1#0)#1, (_c#1) - 15] call TEST_near && [_p1#1, 0] call TEST_near, str _p1] call TEST_check;
["track end clamps", [((([9999] call BTD_fnc_trackPos)#0)#0), (_c#0) + 110] call TEST_near] call TEST_check;
["distance to track", [[[(_c#0), (_c#1) - 45, 0]] call BTD_fnc_trackNear, 10] call TEST_near] call TEST_check;

// --- movement
private _e = ["red", 0, 0, 1, -1, 1];
["red moves 9 m/s", [[_e, 2] call BTD_fnc_bloonDist, 18] call TEST_near] call TEST_check;
_e = ["red", 0, 0, 0.5, 4, 1];
["slow then normal", [[_e, 6] call BTD_fnc_bloonDist, 36] call TEST_near, str ([_e, 6] call BTD_fnc_bloonDist)] call TEST_check;
_e = ["yellow", 10, 0, 0, 3, 1];
["frozen stays put", [[_e, 2] call BTD_fnc_bloonDist, 10] call TEST_near] call TEST_check;

// --- damage
call TEST_reset;
private _id = ["blue", 50, 0] call BTD_fnc_spawnBloon;
private _n = [_id, 1, false] call BTD_fnc_damageBloon;
private _kids = (keys BTD_Live) apply {BTD_Live get _x};
["blue -> red at the same spot", _n == 1 && count _kids == 1 && {((_kids#0)#0) == "red"} && {[(_kids#0)#1, 50] call TEST_near}, str _kids] call TEST_check;
["pop pays cash", BTD_Cash == (BTD_Const get "start_cash") + 1] call TEST_check;
call TEST_reset;
_id = ["pink", 10, 0] call BTD_fnc_spawnBloon;
_n = [_id, 5, false] call BTD_fnc_damageBloon;
["5 damage pops a whole pink", _n == 5 && count BTD_Live == 0, str _n] call TEST_check;
call TEST_reset;
_id = ["lead", 10, 0] call BTD_fnc_spawnBloon;
["darts bounce off lead", ([_id, 3, false] call BTD_fnc_damageBloon) == 0 && count BTD_Live == 1] call TEST_check;
[_id, 1, true] call BTD_fnc_damageBloon;
["explosives split lead into 2 pinks", count BTD_Live == 2 && {((keys BTD_Live) findIf {((BTD_Live get _x)#0) != "pink"}) < 0}] call TEST_check;
call TEST_reset;
_id = ["moab", 10, 0] call BTD_fnc_spawnBloon;
[_id, 50, false] call BTD_fnc_damageBloon;
private _hp = (BTD_Bloons get "moab") get "rbe_hp";
["MOAB loses hp", count BTD_Live == 1 && ((BTD_Live get _id)#5) == _hp - 50] call TEST_check;
_n = [_id, _hp - 50 + 20, false] call BTD_fnc_damageBloon;
["MOAB pops; 20 leftover damage pops all 4 pinks", count BTD_Live == 0 && _n == 21, format ["popped %1, left %2", _n, count BTD_Live]] call TEST_check;
call TEST_reset;
private _cash0 = BTD_Cash;
{ private _i = [_x, 10, 0] call BTD_fnc_spawnBloon; [_i, 9999, true] call BTD_fnc_damageBloon } forEach ["red", "blue", "green", "yellow", "pink", "lead"];
["full pops pay 1 per layer", BTD_Cash - _cash0 == 1 + 2 + 3 + 4 + 5 + 11, str (BTD_Cash - _cash0)] call TEST_check;
["stale id does nothing", ([999, 1, true] call BTD_fnc_damageBloon) == 0] call TEST_check;

// --- slow / freeze
call TEST_reset;
_id = ["green", 20, 0] call BTD_fnc_spawnBloon;
TEST_T = 1;
[_id, 0, 2] call BTD_fnc_slowBloon;
TEST_T = 2;
private _d = [BTD_Live get _id, 2] call BTD_fnc_bloonDist;
["freeze holds the bloon", [_d, 20 + 16.2] call TEST_near, str _d] call TEST_check;
[_id, 1, false] call BTD_fnc_damageBloon;
private _kid = (keys BTD_Live)#0;
["children keep the freeze", ((BTD_Live get _kid)#3) == 0 && ((BTD_Live get _kid)#4) == 3] call TEST_check;
_id = ["moab", 0, 2] call BTD_fnc_spawnBloon;
[_id, 0, 5] call BTD_fnc_slowBloon;
["MOAB ignores freeze", ((BTD_Live get _id)#3) == 1] call TEST_check;

// --- building, upgrading, selling
call TEST_reset;
private _at = {params ["_d", "_off"]; private _tp = [_d] call BTD_fnc_trackPos; private _a = (_tp#1) + 90; (_tp#0) vectorAdd [_off * sin _a, _off * cos _a, 0]};
BTD_Cash = 100;
["dart", [60, 8] call _at] call BTD_fnc_requestBuild;
["no cash, no tower", count BTD_TowerList == 0] call TEST_check;
BTD_Cash = 5000;
["dart", [60, 2] call _at] call BTD_fnc_requestBuild;
["not on the track", count BTD_TowerList == 0] call TEST_check;
private _dartCost = (BTD_Towers get "dart") get "cost";
private _upCost = (BTD_Upgrades get "dart_sharp") get "cost";
private _key = ["dart", [60, 8] call _at] call BTD_fnc_requestBuild;
["builds beside the track", count BTD_TowerList == 1 && BTD_Cash == 5000 - _dartCost] call TEST_check;
["dart", [60, 9] call _at] call BTD_fnc_requestBuild;
["not on another tower", count BTD_TowerList == 1] call TEST_check;
[_key] call BTD_fnc_requestUpgrade;
["upgrade costs and applies", BTD_Cash == 5000 - _dartCost - _upCost && ((BTD_TowerList#0)#2) && (((["dart", true] call BTD_fnc_towerStats) get "pierce") == 3)] call TEST_check;
[_key] call BTD_fnc_requestSell;
["sell refunds 70%", count BTD_TowerList == 0 && BTD_Cash == 5000 - _dartCost - _upCost + floor ((_dartCost + _upCost) * (BTD_Const get "sell_ratio")), str BTD_Cash] call TEST_check;

// --- towers shooting
{
    _x params ["_tower", "_bloon", "_expect"];
    call TEST_reset;
    BTD_Cash = 1e6;
    private _k = [_tower, [100, 6] call _at] call BTD_fnc_requestBuild;
    private _b = [_bloon, 100, 0] call BTD_fnc_spawnBloon;
    TEST_T = 0.01;
    private _cache = (keys BTD_Live) apply {private _dd = [BTD_Live get _x, TEST_T] call BTD_fnc_bloonDist; [_x, _dd, ([_dd] call BTD_fnc_trackPos)#0]};
    [BTD_TowerList#0, _cache, TEST_T] call BTD_fnc_towerFire;
    private _hit = !(_b in BTD_Live) || {((BTD_Live get _b)#5) < ((BTD_Bloons get _bloon) get "rbe_hp")} || {((BTD_Live get _b)#3) < 1};
    [format ["%1 vs %2", _tower, _bloon], _hit == _expect, format ["hit %1, live %2", _hit, count BTD_Live]] call TEST_check;
} forEach [
    ["dart", "red", true], ["dart", "lead", false], ["bomb", "lead", true], ["ice", "red", true], ["ice", "moab", false],
    ["m2_nest", "blue", true], ["m2_nest", "lead", false], ["mortar", "lead", true], ["sniper", "moab", true]
];

// --- rounds through the real server loop (BTD_Const server_tick_s steps)
call TEST_reset;
[] call BTD_fnc_requestRound;
private _steps = 0;
while {BTD_RoundRunning && _steps < 5000} do { TEST_T = TEST_T + 0.1; call BTD_fnc_serverTick; _steps = _steps + 1 };
["undefended round 1 leaks 20 lives", BTD_Lives == (BTD_Const get "start_lives") - 20 && !BTD_RoundRunning, format ["lives %1 after %2 s", BTD_Lives, TEST_T toFixed 1]] call TEST_check;
["round bonus paid", BTD_Cash == (BTD_Const get "start_cash") + ((BTD_Rounds get "r01") get "bonus_cash")] call TEST_check;

// A whole game with a modest defence: start cash spent on 3 towers, then towers bought from earnings between rounds.
call TEST_reset;
private _plan = [["dart", 40, 7], ["dart", 230, 7], ["m2_nest", 150, 9], ["bomb", 330, 8], ["dart", 420, 7], ["ice", 520, 6], ["mortar", 365, -25], ["sniper", 600, 9], ["bomb", 620, -8], ["m2_nest", 470, -9], ["dart", 100, -7], ["bomb", 200, -8]];
private _built = 0;
private _buy = {
    while {_built < count _plan} do {
        (_plan#_built) params ["_t", "_dd", "_off"];
        private _row = BTD_Towers get _t;
        if (BTD_Cash < (_row get "cost")) exitWith {};
        [_t, [_dd, _off] call _at] call BTD_fnc_requestBuild;
        _built = _built + 1;
    };
    { if (!(_x#2)) then {[_x#0] call BTD_fnc_requestUpgrade} } forEach BTD_TowerList;
};
for "_r" from 1 to 10 do {
    call _buy;
    [] call BTD_fnc_requestRound;
    private _s = 0;
    while {BTD_RoundRunning && !BTD_GameOver && _s < 20000} do { TEST_T = TEST_T + 0.1; call BTD_fnc_serverTick; _s = _s + 1 };
    diag_log format ["[TEST] INFO round %1: lives %2, cash %3, towers %4", _r, BTD_Lives, BTD_Cash, count BTD_TowerList];
    if (BTD_GameOver) exitWith {};
};
["a modest defence wins all 10 rounds", BTD_GameOver && BTD_Lives > 0, format ["round %1, lives %2", BTD_Round, BTD_Lives]] call TEST_check;

// The same game with no towers at all must be lost.
call TEST_reset;
for "_r" from 1 to 10 do {
    [] call BTD_fnc_requestRound;
    private _s = 0;
    while {BTD_RoundRunning && !BTD_GameOver && _s < 20000} do { TEST_T = TEST_T + 0.1; call BTD_fnc_serverTick; _s = _s + 1 };
    if (BTD_GameOver) exitWith {};
};
["no defence loses", BTD_GameOver && BTD_Lives == 0, format ["lost on round %1", BTD_Round]] call TEST_check;

// --- player blasts pop lead
call TEST_reset;
_id = ["lead", 300, 0] call BTD_fnc_spawnBloon;
[([300] call BTD_fnc_trackPos)#0] call BTD_fnc_playerBlast;
["player grenade pops lead", !(_id in BTD_Live) && count BTD_Live == 2] call TEST_check;
[(keys BTD_Live)#0] call BTD_fnc_playerHit;
["player bullet pops a layer", count BTD_Live == 2] call TEST_check;

diag_log format ["[TEST] DONE: %1 failure(s)", TEST_fails];
