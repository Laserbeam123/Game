// [posA, posB] -> horizontal distance (OA has no distance2D).
private ["_a", "_b"];
_a = _this select 0;
_b = _this select 1;
sqrt (((_a select 0) - (_b select 0)) ^ 2 + ((_a select 1) - (_b select 1)) ^ 2)
