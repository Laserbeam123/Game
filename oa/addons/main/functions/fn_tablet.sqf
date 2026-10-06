// Client: open the build tablet (dialog and buttons generated from the towers sheet into tablet.hpp).
#include "\z\bloonsops_oa\addons\main\script.hpp"
private ["_d", "_i"];
if (!createDialog "BO_TabletDialog") exitWith {};
_d = findDisplay 77200;
(_d displayCtrl 77201) ctrlSetText format ["BUILD TABLET      Cash: $%1", BO_Cash];
for "_i" from 0 to (count BO_Towers - 1) do {
    if (BO_Cash < ((BO_Towers select _i) select T_COST)) then { (_d displayCtrl (77300 + _i)) ctrlSetTextColor [1, 0.45, 0.45, 1] };
};
