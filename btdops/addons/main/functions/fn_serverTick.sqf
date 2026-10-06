/*
    Server loop step: spawn what the round schedule says, leak bloons that reached the end,
    let every tower shoot, end the round, then send one batch to the clients.
*/
private _now = call BTD_fnc_now;
while {count BTD_Schedule > 0 && {((BTD_Schedule#0)#0) <= _now}} do {
    private _s = BTD_Schedule deleteAt 0;
    [_s#1, 0, _s#0] call BTD_fnc_spawnBloon;
};

private _total = BTD_Track#2;
private _cache = [];
private _leaks = [];
{
    private _d = [_y, _now] call BTD_fnc_bloonDist;
    if (_d >= _total) then {_leaks pushBack _x} else {_cache pushBack [_d, _x]};
} forEach BTD_Live;
{
    private _e = BTD_Live deleteAt _x;
    BTD_Lives = BTD_Lives - ((BTD_Bloons get (_e#0)) get "lives_cost");
    (BTD_Batch#5) pushBack _x;
    BTD_Dirty = true;
} forEach _leaks;
if (BTD_Lives <= 0) exitWith {
    BTD_Lives = 0;
    [false] call BTD_fnc_gameOver;
};

// first = furthest along the track
_cache sort false;
_cache = _cache apply {[_x#1, _x#0, ([_x#0] call BTD_fnc_trackPos)#0]};
{ [_x, _cache, _now] call BTD_fnc_towerFire } forEach BTD_TowerList;

if (BTD_RoundRunning && {count BTD_Schedule == 0} && {count BTD_Live == 0}) then {
    BTD_RoundRunning = false;
    publicVariable "BTD_RoundRunning";
    private _r = BTD_Rounds get (format ["r%1", [BTD_Round, 2] call BIS_fnc_padNumber]);
    BTD_Cash = BTD_Cash + (_r get "bonus_cash");
    BTD_Dirty = true;
    if (BTD_Round >= BTD_RoundCount) then {
        [true] call BTD_fnc_gameOver;
    } else {
        [format ["Round %1 cleared! +$%2", BTD_Round, _r get "bonus_cash"], "round"] remoteExecCall ["BTD_fnc_notify", 0];
    };
};

if (BTD_Dirty) then {
    BTD_Dirty = false;
    publicVariable "BTD_Cash";
    publicVariable "BTD_Lives";
};
call BTD_fnc_flushBatch;
