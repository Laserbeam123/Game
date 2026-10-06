// Server: register bloons and queue them for broadcast. [[typeIdx, d0, mult, until], ...] -> ids
private ["_now", "_ids", "_id", "_mult", "_until"];
_now = call BO_fnc_now;
_ids = [];
{
    _mult = 1;
    _until = 0;
    if (count _x > 2) then { _mult = _x select 2; _until = _x select 3 };
    _id = BO_NextId;
    BO_NextId = BO_NextId + 1;
    BO_Live set [_id, [_x select 0, _x select 1, _now, _mult, _until]];
    BO_Alive set [count BO_Alive, _id];
    BO_SpawnQueue set [count BO_SpawnQueue, [_id, _x select 0, _x select 1, _now, _mult]];
    _ids set [count _ids, _id];
} forEach (_this select 0);
_ids
