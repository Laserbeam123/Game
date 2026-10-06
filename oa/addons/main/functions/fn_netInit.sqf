// Three message channels over publicVariable (OA has no remoteExec). A message is [functionName, args];
// only names in BO_NetAllowed (generated from sheets/oa_hooks.json, column net) are ever called.
#include "\z\bloonsops_oa\addons\main\script.hpp"
BO_netRun = {
    private ["_fn"];
    _fn = _this select 0;
    if (_fn in BO_NetAllowed) then { (_this select 1) call (missionNamespace getVariable _fn) } else { diag_log format ["[BloonsOps] refused net call %1", _fn] };
};
"BO_NET_ALL" addPublicVariableEventHandler { (_this select 1) call BO_netRun };
"BO_NET_CLI" addPublicVariableEventHandler { (_this select 1) call BO_netRun };
if (isServer) then { "BO_NET_SRV" addPublicVariableEventHandler { (_this select 1) call BO_netRun } };
