// Client: shot streaks from the server, drawn for a moment by draw3D. [[fromASL, toASL, rgba], ...]
params ["_batch"];
if (!hasInterface || { isNil "BO_Fx" }) exitWith {};
private _until = diag_tickTime + 0.15;
{ BO_Fx pushBack [_x select 0, _x select 1, _x select 2, _until] } forEach _batch;
