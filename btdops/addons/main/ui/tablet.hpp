class BTD_TabletButton: RscButton {
    w = "safeZoneW * 0.39";
    h = "safeZoneH * 0.07";
    sizeEx = "0.045";
    colorBackground[] = {0.12, 0.16, 0.12, 0.9};
    colorBackgroundActive[] = {0.85, 0.65, 0.1, 1};
    colorFocused[] = {0.25, 0.3, 0.25, 1};
};
class BTD_Tablet {
    idd = 9300;
    movingEnable = 0;
    class controlsBackground {
        class Back: RscText {
            idc = -1;
            x = "safeZoneX + safeZoneW * 0.05";
            y = "safeZoneY + safeZoneH * 0.08";
            w = "safeZoneW * 0.9";
            h = "safeZoneH * 0.75";
            colorBackground[] = {0.04, 0.05, 0.04, 0.88};
        };
        class Title: RscText {
            idc = 9301;
            x = "safeZoneX + safeZoneW * 0.07";
            y = "safeZoneY + safeZoneH * 0.09";
            w = "safeZoneW * 0.86";
            h = "safeZoneH * 0.05";
            sizeEx = "0.05";
            colorText[] = {1, 0.85, 0.3, 1};
            text = "BUILD TABLET";
        };
        class ArmaHead: RscText {
            idc = -1;
            x = "safeZoneX + safeZoneW * 0.08";
            y = "safeZoneY + safeZoneH * 0.145";
            w = "safeZoneW * 0.39";
            h = "safeZoneH * 0.045";
            sizeEx = "0.045";
            colorText[] = {0.6, 0.85, 0.6, 1};
            text = "ARMA 3";
        };
        class BtdHead: ArmaHead {
            x = "safeZoneX + safeZoneW * 0.53";
            colorText[] = {1, 0.75, 0.3, 1};
            text = "BLOONS TD 6";
        };
    };
    class controls {
        #include "tablet_buttons.hpp"
        class Close: BTD_TabletButton {
            idc = 9399;
            x = "safeZoneX + safeZoneW * 0.355";
            y = "safeZoneY + safeZoneH * 0.74";
            w = "safeZoneW * 0.29";
            text = "Close";
            action = "closeDialog 0";
        };
    };
};
