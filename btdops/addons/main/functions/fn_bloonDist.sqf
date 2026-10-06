/*
    How far a bloon has travelled at game time _now.
    _e: [type, d0, t0, mult, until, hp]. Between t0 and until it moves at mult x speed (0 = frozen).
*/
params ["_e", "_now"];
_e params ["_type", "_d0", "_t0", "_mult", "_until"];
private _v = ((BTD_Bloons get _type) get "speed_rel") * (BTD_Const get "speed_base_mps");
if (_now <= _until) exitWith {_d0 + _v * _mult * ((_now - _t0) max 0)};
private _slowEnd = _until max _t0;
_d0 + _v * _mult * (_slowEnd - _t0) + _v * (_now - _slowEnd)
