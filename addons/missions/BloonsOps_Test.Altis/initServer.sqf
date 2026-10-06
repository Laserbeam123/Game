BO_SelfTest = true;
publicVariable "BO_SelfTest";
[] call BO_fnc_initServer;
[] spawn BO_fnc_selfTest;
