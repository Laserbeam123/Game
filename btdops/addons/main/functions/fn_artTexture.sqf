/*
    Client: the picture for a btd6_art row. The player's own BTD6 art (converted on their PC into
    the btdops_art addon) when present, else this mod's stand-in drawn from scratch.
*/
params ["_artId"];
private _t = BTD_ArtCache getOrDefault [_artId, ""];
if (_t != "") exitWith {_t};
private _cfg = configFile >> "BTD_ArtPack" >> _artId;
_t = if (isClass _cfg) then {getText (_cfg >> "texture")} else {format ["\z\btdops\addons\main\data\art_%1_ca.paa", _artId]};
BTD_ArtCache set [_artId, _t];
_t
