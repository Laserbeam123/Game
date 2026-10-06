// Any machine: how far along the track a server bloon entry [type, d0, t0, mult, until] is at time _now.
params ["_e", "_now"];
_e params ["_type", "_d0", "_t0", ["_mult", 1]];
_d0 + ((BO_Bloons get _type) get "speed_mps") * _mult * (_now - _t0)
