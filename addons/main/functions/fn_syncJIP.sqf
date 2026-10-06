// Server: send every live bloon to a player who just joined.
params ["_player"];
if (!isServer || { isNil "BO_Live" }) exitWith {};
private _batch = [];
{ _y params ["_type", "_d0", "_t0"]; _batch pushBack [_x, _type, _d0, _t0] } forEach BO_Live;
if (_batch isNotEqualTo []) then { [_batch] remoteExecCall ["BO_fnc_bloonLocal", _player] };
