class CfgPatches {
    class bloonsops_main {
        name = "Bloons Ops - Main";
        author = "Bloons Ops contributors";
        url = "https://github.com/laserbeam123/game";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"A3_Functions_F", "A3_UI_F", "A3_Characters_F", "A3_Static_F", "A3_Structures_F", "A3_Weapons_F"};
    };
};

#include "CfgFunctions.hpp"
#include "CfgMainMenuSpotlight.hpp"

class RscStructuredText;
class RscTitles {
    class BO_Hud {
        idd = -1;
        duration = 1e+011;
        fadeIn = 0;
        fadeOut = 0;
        movingEnable = 0;
        onLoad = "uiNamespace setVariable ['BO_Hud', _this select 0]";
        class controls {
            class Text: RscStructuredText {
                idc = 1100;
                x = "safeZoneX + safeZoneW - 0.34";
                y = "safeZoneY + 0.22";
                w = 0.32;
                h = 0.2;
                size = 0.04;
                colorBackground[] = {0, 0, 0, 0.45};
            };
        };
    };
};
