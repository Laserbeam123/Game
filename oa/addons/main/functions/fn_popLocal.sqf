// Client: [ids, leaked] remove popped/leaked bloons; pop sound from an invisible emitter (OA has no playSound3D).
private ["_n", "_e", "_snd", "_cls"];
if (isDedicated || { isNil "BO_LocalB" }) exitWith {};
_n = 0;
_cls = "bo_pop";
if (_this select 1) then { _cls = "bo_leak" };
{
    if (_x < count BO_LocalB) then {
        _e = BO_LocalB select _x;
        if (count _e > 0) then {
            if (_n < 6 && { ((_e select 0) distance player) < 150 }) then {
                _snd = "HeliHEmpty" createVehicleLocal (getPosATL (_e select 0));
                _snd say3D _cls;
                [_snd] spawn { sleep 2; deleteVehicle (_this select 0) };
                _n = _n + 1;
            };
            deleteVehicle (_e select 0);
            deleteVehicle (_e select 6);
            BO_LocalB set [_x, []];
        };
    };
} forEach (_this select 0);
BO_LocalIds = BO_LocalIds - (_this select 0);
