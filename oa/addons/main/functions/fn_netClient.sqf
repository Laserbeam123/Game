// Server: run [fn, args] on the machine where _unit is local. [unit, fn, args]
private ["_u", "_msg"];
_u = _this select 0;
_msg = [_this select 1, _this select 2];
if (local _u) then { _msg call BO_netRun } else {
    BO_NET_CLI = _msg;
    (owner _u) publicVariableClient "BO_NET_CLI";
};
