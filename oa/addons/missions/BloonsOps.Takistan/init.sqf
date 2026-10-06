// Bloons Ops: Arrowhead. Functions are compiled by the generated loader (OA has no CfgFunctions without
// the Functions module), then the message channels, then the server and the player.
call compile preprocessFileLineNumbers "\z\bloonsops_oa\addons\main\init_functions.sqf";
call BO_fnc_netInit;
if (isServer) then { [] spawn BO_fnc_initServer };
if (!isDedicated) then { [] spawn BO_fnc_initPlayer };
