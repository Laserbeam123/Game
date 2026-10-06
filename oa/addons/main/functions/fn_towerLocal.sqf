// Every machine: [anchor, [[object, texture], ...]] paint the monkey spheres (setObjectTexture is local in OA),
// make tower shots visual only, and (clients) remember the tower for nearest-tower actions.
private ["_t", "_heli"];
_t = _this select 0;
if (isNull _t) exitWith {};
{ (_x select 0) setObjectTexture [0, _x select 1] } forEach (_this select 1);
_heli = _t getVariable "bo_heli";
if (isNil "_heli") then { _heli = objNull };
{
    if (!isNull _x) then {
        _x addEventHandler ["Fired", {
            if (!isPlayer (gunner (vehicle (_this select 0))) && !isPlayer (_this select 0)) then {
                if (count _this > 6) then { deleteVehicle (_this select 6) } else { deleteVehicle (nearestObject [_this select 0, _this select 4]) };
            };
        }];
    };
} forEach ([_t, _heli] + (_t getVariable "bo_crew"));
if (!isDedicated) then {
    if (isNil "BO_ClientTowers") then { BO_ClientTowers = [] };
    BO_ClientTowers = BO_ClientTowers - [objNull];
    BO_ClientTowers set [count BO_ClientTowers, _t];
};
