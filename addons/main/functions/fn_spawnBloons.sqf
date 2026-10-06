// Server: register bloons and queue them for broadcast. [[type, startDistance], ...] -> ids
params ["_list"];
private _now = call BO_fnc_now;
private _ids = [];
{
    _x params ["_type", "_d0"];
    private _id = BO_NextId;
    BO_NextId = BO_NextId + 1;
    BO_Live set [_id, [_type, _d0, _now]];
    BO_SpawnQueue pushBack [_id, _type, _d0, _now];
    _ids pushBack _id;
} forEach _list;
_ids
