/*
    A tower's numbers: its towers row, with its upgrades row applied when bought.
*/
params ["_rowId", "_upgraded"];
private _s = +(BTD_Towers get _rowId);
if (_upgraded) then {
    private _u = BTD_Upgrades get (_s get "upgrade");
    _s set ["range_m", (_s get "range_m") * (_u get "range_mult")];
    _s set ["interval_s", (_s get "interval_s") * (_u get "interval_mult")];
    _s set ["damage", (_s get "damage") + (_u get "damage_add")];
    _s set ["pierce", (_s get "pierce") + (_u get "pierce_add")];
    _s set ["aoe_m", (_s get "aoe_m") * (_u get "aoe_mult")];
    _s set ["pops_lead", (_s get "pops_lead") || (_u get "pops_lead")];
    _s set ["slow_s", (_s get "slow_s") + (_u get "slow_s_add")];
};
_s
