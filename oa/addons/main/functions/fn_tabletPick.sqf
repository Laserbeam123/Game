// Client: [towerIdx] (tablet button) build it in front of the player.
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_dir", "_d", "_pos"];
closeDialog 0;
_dir = getDir player;
_d = CFG_BUILD_DISTANCE;
_pos = [((getPosATL player) select 0) + (sin _dir) * _d, ((getPosATL player) select 1) + (cos _dir) * _d, 0];
["BO_fnc_requestBuild", [player, _this select 0, _pos]] call BO_fnc_netServer;
