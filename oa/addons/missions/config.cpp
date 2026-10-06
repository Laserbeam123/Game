class CfgPatches {
    class bloonsops_oa_missions {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.62;
        requiredAddons[] = {"bloonsops_oa_main", "Takistan"};
        author = "Bloons Ops contributors";
    };
};

class CfgMissions {
    class Missions {
        class BloonsOps_Takistan {
            briefingName = "Bloons Ops: Arrowhead (Takistan)";
            directory = "z\bloonsops_oa\addons\missions\BloonsOps.Takistan";
        };
    };
    class MPMissions {
        class BloonsOps_Takistan {
            briefingName = "Bloons Ops: Arrowhead - Co-op 1-4 (Takistan)";
            directory = "z\bloonsops_oa\addons\missions\BloonsOps.Takistan";
        };
    };
};
