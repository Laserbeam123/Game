// Client: a local, camera-facing BTD6 cut-out. The converter's PAA goes on a UserTexture1m_F simple object
// (simple objects take setObjectScale). [texture, centreASL, size_m] -> object
params ["_tex", "_centre", "_size"];
private _o = createSimpleObject ["UserTexture1m_F", _centre, true];
_o setObjectTexture [0, _tex];
(boundingBoxReal _o) params ["_lo", "_hi"];
_o setVariable ["bo_size", _size];
_o setVariable ["bo_cz", ((_lo select 2) + (_hi select 2)) / 2];   // model centre height, so _centre is the picture's middle
if (isNil "BO_CamASL") then { BO_CamASL = AGLToASL positionCameraToWorld [0, 0, 0] };
[_o, _centre] call BO_fnc_faceBoard;
_o
