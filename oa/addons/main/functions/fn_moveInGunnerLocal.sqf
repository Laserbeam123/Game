// Client: [tower] moveInGunner where the player is local; the gun's shots are tracked like the player's own.
private ["_t"];
_t = _this select 0;
player moveInGunner _t;
if (isNil { _t getVariable "bo_playerEH" }) then {
    _t addEventHandler ["Fired", { if (isPlayer (gunner (_this select 0))) then { _this call BO_fnc_onFired } }];
    _t setVariable ["bo_playerEH", true];
};
