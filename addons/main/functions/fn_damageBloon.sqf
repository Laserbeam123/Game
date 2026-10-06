// Server: hit bloon _id for _dmg layers. Pops it into its children, pays cash. Returns true if it popped.
// Called by towers, and by clients via remoteExecCall when a player's shot passes through a bloon.
params [["_id", -1, [0]], ["_dmg", 1, [0]], ["_popsLead", false, [false]]];
if (!isServer) exitWith { false };
if (!isNil "BO_State" && { BO_State != "play" }) exitWith { false };
private _b = BO_Live getOrDefault [_id, []];
if (_b isEqualTo []) exitWith { false };
_b params ["_type", "_d0", "_t0"];
private _row = BO_Bloons get _type;
if ((_row get "needs_lead_popper") && !_popsLead) exitWith { false };
_dmg = (_dmg max 1) min 5;
BO_Live deleteAt _id;
private _d = _d0 + (_row get "speed_mps") * ((call BO_fnc_now) - _t0);

private _cash = 0;
private _spawn = [];
private _fn = {
    params ["_t", "_left"];
    private _r = BO_Bloons get _t;
    if (_left <= 0 || { (_r get "needs_lead_popper") && !_popsLead }) exitWith { _spawn pushBack _t };
    _cash = _cash + (_r get "pop_cash");
    private _c = _r get "child";
    if (_c != "") then {
        for "_k" from 1 to (_r get "child_count") do { [_c, _left - 1] call _fn };
    };
};
[_type, _dmg] call _fn;

BO_Cash = BO_Cash + _cash;
BO_CashDirty = true;
BO_PopQueue pushBack _id;
if (_spawn isNotEqualTo []) then {
    // children appear where the parent was, slightly staggered back along the track
    private _list = [];
    { _list pushBack [_x, (_d - _forEachIndex * 0.8) max 0] } forEach _spawn;
    [_list] call BO_fnc_spawnBloons;
};
true
