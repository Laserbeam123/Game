/*
    Server: a new bloon at track distance _d, queued for the next client batch.
    Returns its id.
*/
params ["_type", "_d", "_t0", ["_mult", 1], ["_until", -1]];
private _id = BTD_NextId;
BTD_NextId = _id + 1;
private _e = [_type, _d, _t0, _mult, _until, (BTD_Bloons get _type) get "rbe_hp"];
BTD_Live set [_id, _e];
(BTD_Batch#0) pushBack ([_id] + _e);
_id
