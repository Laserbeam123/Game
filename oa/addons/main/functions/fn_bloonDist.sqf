// [entry, now] -> track distance of a server bloon entry [typeIdx, d0, t0, mult, until].
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_e"];
_e = _this select 0;
(_e select 1) + ((BLOON(_e select 0)) select B_SPEED_MPS) * (_e select 3) * ((_this select 1) - (_e select 2))
