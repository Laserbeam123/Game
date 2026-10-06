// Client: run [fn, args] on the server (directly when this machine is the server).
if (isServer) then { _this call BO_netRun } else {
    BO_NET_SRV = _this;
    publicVariableServer "BO_NET_SRV";
};
