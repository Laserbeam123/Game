class CfgPatches {
    class bloonsops_oa_main {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.62;
        requiredAddons[] = {"CAData", "CAUI", "CA_E"};
        author = "Bloons Ops contributors";
    };
};

#include "sounds.hpp"

// Own control styles (Arma 2 OA addon configs cannot rely on mission-side Rsc classes).
class BO_RscText {
    access = 0;
    type = 0;
    idc = -1;
    style = 0;
    font = "Zeppelin32";
    sizeEx = 0.035;
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0};
    text = "";
    x = 0; y = 0; w = 0.2; h = 0.05;
};
class BO_RscStructuredText {
    access = 0;
    type = 13;
    idc = -1;
    style = 0;
    size = 0.035;
    colorText[] = {1, 1, 1, 1};
    colorBackground[] = {0, 0, 0, 0.45};
    text = "";
    x = 0; y = 0; w = 0.2; h = 0.05;
    class Attributes {
        font = "Zeppelin32";
        color = "#ffffff";
        align = "left";
        shadow = 1;
    };
};
class BO_RscButton {
    access = 0;
    type = 1;
    style = 2;
    text = "";
    font = "Zeppelin32";
    sizeEx = 0.032;
    colorText[] = {1, 1, 1, 1};
    colorDisabled[] = {0.4, 0.4, 0.4, 1};
    colorBackground[] = {0.25, 0.25, 0.25, 0.9};
    colorBackgroundDisabled[] = {0.1, 0.1, 0.1, 0.9};
    colorBackgroundActive[] = {0.45, 0.45, 0.45, 1};
    colorFocused[] = {0.35, 0.35, 0.35, 1};
    colorShadow[] = {0, 0, 0, 0.5};
    colorBorder[] = {0, 0, 0, 1};
    soundEnter[] = {"", 0.1, 1};
    soundPush[] = {"", 0.1, 1};
    soundClick[] = {"", 0.1, 1};
    soundEscape[] = {"", 0.1, 1};
    offsetX = 0.003;
    offsetY = 0.003;
    offsetPressedX = 0.002;
    offsetPressedY = 0.002;
    borderSize = 0;
    tooltip = "";
    action = "";
    x = 0; y = 0; w = 0.2; h = 0.05;
};

#include "tablet.hpp"

class RscTitles {
    class BO_Hud {
        idd = -1;
        duration = 1e+011;
        fadeIn = 0;
        fadeOut = 0;
        movingEnable = 0;
        onLoad = "uiNamespace setVariable ['BO_Hud', _this select 0]";
        controls[] = {"Text"};
        class Text: BO_RscStructuredText {
            idc = 1100;
            x = "safeZoneX + safeZoneW - 0.36";
            y = "safeZoneY + 0.22";
            w = 0.34;
            h = 0.2;
        };
    };
};
