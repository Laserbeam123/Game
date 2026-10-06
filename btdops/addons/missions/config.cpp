class CfgPatches {
    class btdops_missions {
        name = "Bloon Strike: Altis - scenarios";
        author = "Bloon Strike contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"btdops_main"};
    };
};
class CfgMissions {
    class Missions {
        class btdops_solo {
            briefingName = "Bloon Strike: Altis";
            directory = "z\btdops\addons\missions\btdops_solo.Altis";
        };
        class btdops_selftest {
            briefingName = "Bloon Strike: Altis - Self Test";
            directory = "z\btdops\addons\missions\btdops_selftest.Altis";
        };
    };
    class MPMissions {
        class btdops_coop {
            briefingName = "Bloon Strike: Altis - Co-op 1-4";
            directory = "z\btdops\addons\missions\btdops_coop.Altis";
        };
    };
};
