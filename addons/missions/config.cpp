class CfgPatches {
    class bloonsops_missions {
        name = "Bloons Ops - Missions";
        author = "Bloons Ops contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"bloonsops_main", "A3_Map_Altis"};
    };
};

class CfgMissions {
    class Missions {
        class BloonsOps_Altis {
            briefingName = "Bloons Ops (Altis)";
            directory = "z\bloonsops\addons\missions\BloonsOps.Altis";
        };
        class BloonsOps_Test_Altis {
            briefingName = "Bloons Ops - Self Test";
            directory = "z\bloonsops\addons\missions\BloonsOps_Test.Altis";
        };
    };
    class MPMissions {
        class BloonsOps_Altis {
            briefingName = "Bloons Ops - Co-op 1-4 (Altis)";
            directory = "z\bloonsops\addons\missions\BloonsOps.Altis";
        };
    };
};
