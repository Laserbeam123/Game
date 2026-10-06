class CfgPatches {
    class btdops_missions {
        name = "Bloons TD Ops - scenarios";
        author = "Bloons TD Ops contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"btdops_main"};
    };
};
class CfgMissions {
    class Missions {
        class btdops_solo {
            briefingName = "Bloons TD Ops (Altis)";
            directory = "z\btdops\addons\missions\btdops_solo.Altis";
        };
        class btdops_selftest {
            briefingName = "Bloons TD Ops - Self Test";
            directory = "z\btdops\addons\missions\btdops_selftest.Altis";
        };
    };
    class MPMissions {
        class btdops_coop {
            briefingName = "Bloons TD Ops - Co-op 1-4 (Altis)";
            directory = "z\btdops\addons\missions\btdops_coop.Altis";
        };
    };
};
