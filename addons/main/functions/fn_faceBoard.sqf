// Client, every frame: stand a billboard upright at centreASL, turned to the camera, at its size. [object, centreASL]
// (setVectorDirAndUp resets the scale, so the scale is applied after it.)
params ["_o", "_c"];
private _s = _o getVariable ["bo_size", 1];
private _d = BO_CamASL vectorDiff _c;
_d set [2, 0];
if ((vectorMagnitude _d) < 0.01) then { _d = [0, 1, 0] };
_o setPosASL (_c vectorAdd [0, 0, -(_o getVariable ["bo_cz", 0]) * _s]);
_o setVectorDirAndUp [_d vectorMultiply (BO_Cfg get "btd6_board_side"), [0, 0, 1]];
_o setObjectScale _s;
