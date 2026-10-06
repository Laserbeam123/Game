// Server: [id, dmg, popsLead] pop layers into children, pay cash. Returns true if it popped.
// Called by towers, and by clients (netServer) when a player's shot passes through a bloon.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_id", "_dmg", "_popsLead", "_e", "_type", "_now", "_d", "_mult", "_until", "_cash", "_spawn", "_fn", "_list"];
_id = _this select 0;
_dmg = (_this select 1) min 5;
_popsLead = _this select 2;
if (!isServer || { BO_State != "play" } || { _id < 0 } || { _id >= count BO_Live }) exitWith { false };
_e = BO_Live select _id;
if (count _e == 0) exitWith { false };
_type = _e select 0;
if (((BLOON(_type)) select B_NEEDS_LEAD_POPPER) && !_popsLead) exitWith { false };
if (_dmg <= 0) exitWith { false };
BO_Live set [_id, []];
BO_Alive = BO_Alive - [_id];
_now = call BO_fnc_now;
_d = [_e, _now] call BO_fnc_bloonDist;
_mult = _e select 3;
_until = _e select 4;
if (_until <= _now) then { _mult = 1; _until = 0 };

_cash = 0;
_spawn = [];
_fn = {
    private ["_t", "_left", "_r", "_k"];
    _t = _this select 0;
    _left = _this select 1;
    _r = BLOON(_t);
    if (_left <= 0 || { (_r select B_NEEDS_LEAD_POPPER) && !_popsLead }) then {
        _spawn set [count _spawn, _t];
    } else {
        _cash = _cash + (_r select B_POP_CASH);
        if ((_r select B_CHILD) >= 0) then {
            for "_k" from 1 to (_r select B_CHILD_COUNT) do { [_r select B_CHILD, _left - 1] call _fn };
        };
    };
};
[_type, _dmg] call _fn;

BO_Cash = BO_Cash + _cash;
BO_CashDirty = true;
BO_PopQueue set [count BO_PopQueue, _id];
if (count _spawn > 0) then {
    _list = [];
    { _list set [count _list, [_x, (_d - _forEachIndex * 0.8) max 0, _mult, _until]] } forEach _spawn;
    [_list] call BO_fnc_spawnBloons;
};
true
