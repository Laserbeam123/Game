// Client: open/close the build tablet (shows tower list; build entries appear in the scroll menu).
BO_TabletOpen = !BO_TabletOpen;
if (!BO_TabletOpen) exitWith { hintSilent "" };
private _lines = ["<t size='1.3' color='#00FFFF'>BUILD TABLET</t>", format ["<t color='#FFD700'>Cash: $%1</t>", BO_Cash], ""];
{
    private _r = BO_Towers get _x;
    private _flags = [];
    if (_r get "pops_lead") then { _flags pushBack "pops lead" };
    if (_r get "sees_camo") then { _flags pushBack "sees camo" };
    if (_r get "mannable") then { _flags pushBack "mannable" };
    _lines pushBack format ["<t align='left'><t color='%1'>%2 - $%3</t><br/><t size='0.85'>%4%5</t></t>",
        ["#FF6060", "#FFFFFF"] select (BO_Cash >= (_r get "cost")), _r get "name", _r get "cost", _r get "blurb",
        ["", " (" + (_flags joinString ", ") + ")"] select (_flags isNotEqualTo [])];
} forEach BO_TowerOrder;
_lines pushBack "<br/><t size='0.85'>Towers appear in front of you. Stay 5 m off the road.</t>";
hintSilent parseText (_lines joinString "<br/>");
