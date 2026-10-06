/*
    Server: tower _t shoots the first bloon in range it can hurt, with its row's numbers.
    _cache: [[id, d, posATL], ...] furthest first.
*/
params ["_t", "_cache", "_now"];
_t params ["_key", "_rowId", "_upg", "_pos"];
private _o = BTD_TowerObjs get _key;
if (isNil "_o" || {_now < (_o#1)}) exitWith {};
private _s = [_rowId, _upg] call BTD_fnc_towerStats;
private _lead = _s get "pops_lead";
private _moab = _s get "hits_moab";
private _canHit = {
    private _b = BTD_Bloons get ((BTD_Live get _this)#0);
    (!(_b get "lead") || _lead) && {!(_b get "is_moab") || _moab}
};
private _range = _s get "range_m";
private _target = [];
{
    if (((_x#2) distance2D _pos) <= _range && {(_x#0) in BTD_Live} && {(_x#0) call _canHit}) exitWith {_target = _x};
} forEach _cache;
if (_target isEqualTo []) exitWith {};

private _fx = _s get "shot_fx";
private _aoe = _s get "aoe_m";
private _center = [_target#2, _pos] select (_fx == "frost");
private _radius = [2, _aoe] select (_aoe > 0);
private _victims = [_target#0];
if (_fx == "frost") then {_victims = []};
{
    if (count _victims >= (_s get "pierce")) exitWith {};
    if (!((_x#0) in _victims) && {((_x#2) distance2D _center) <= _radius} && {(_x#0) in BTD_Live} && {(_x#0) call _canHit}) then {
        _victims pushBack (_x#0);
    };
} forEach _cache;
{
    if ((_s get "slow_s") > 0) then {[_x, _s get "slow_mult", _s get "slow_s"] call BTD_fnc_slowBloon};
    [_x, _s get "damage", _lead] call BTD_fnc_damageBloon;
} forEach _victims;
_o set [1, _now + (_s get "interval_s")];

// Show it: real Arma weapons fire for real (the pop above is what counts), BTD6 shots are drawn by clients.
private _to = _target#2;
(BTD_Batch#4) pushBack [_fx, _pos, _to, _s get "fire_sound", _aoe];
(_o#0) params [["_veh", objNull], ["_gunner", objNull]];
if (_s get "section" == "ARMA") then {
    private _aim = AGLToASL (_to vectorAdd [0, 0, 1.5]);
    if (!isNull _gunner) then {_gunner doWatch _aim};
    if (_fx == "shell") then {
        if (!isNull _veh) then {[_veh, (weapons _veh)#0] call BIS_fnc_fire};
        private _sh = createVehicle ["Sh_82mm_AMOS", _to vectorAdd [0, 0, 40], [], 0, "CAN_COLLIDE"];
        _sh setVelocity [0, 0, -60];
    } else {
        if (!isNull _veh) then {[_veh, (weapons _veh)#0] call BIS_fnc_fire} else {
            if (!isNull _gunner) then {[_gunner, primaryWeapon _gunner] call BIS_fnc_fire};
        };
    };
};
