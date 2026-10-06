// Server: register bloons and queue them for broadcast. [[type, startDistance, mult?, until?], ...] -> ids
params ["_list"];
private _now = call BO_fnc_now;
private _ids = [];
{
    _x params ["_type", "_d0", ["_mult", 1], ["_until", 0]];
    private _id = BO_NextId;
    BO_NextId = BO_NextId + 1;
    BO_Live set [_id, [_type, _d0, _now, _mult, _until]];
    BO_SpawnQueue pushBack [_id, _type, _d0, _now, _mult];
    _ids pushBack _id;
} forEach _list;
_ids
