/*
    maps row -> track: [points (ATL, z 0), cumulative lengths, total length].
*/
params ["_map"];
private _c = _map get "center";
private _pts = (_map get "track") apply {[(_c#0) + (_x#0), (_c#1) + (_x#1), 0]};
private _cum = [0];
for "_i" from 1 to (count _pts - 1) do {
    _cum pushBack ((_cum#(_i - 1)) + ((_pts#(_i - 1)) distance2D (_pts#_i)));
};
[_pts, _cum, _cum#(count _cum - 1)]
