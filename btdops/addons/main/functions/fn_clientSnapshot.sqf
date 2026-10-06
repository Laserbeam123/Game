/*
    Server -> joining client: every live bloon as [id, type, d0, t0, mult, until, hp].
*/
params ["_all"];
if (isNil "BTD_CLive") exitWith {};
{ BTD_CLive set [_x#0, _x select [1, 6]] } forEach _all;
