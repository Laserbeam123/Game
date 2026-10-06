class RscTitles {
    class BTD_Hud {
        idd = 9100;
        duration = 1e10;
        fadeIn = 0;
        fadeOut = 0;
        onLoad = "uiNamespace setVariable ['BTD_HudDisplay', _this select 0]";
        class controls {
            class Bar: RscStructuredText {
                idc = 9101;
                x = "safeZoneX + safeZoneW * 0.25";
                y = "safeZoneY + safeZoneH * 0.01";
                w = "safeZoneW * 0.5";
                h = "safeZoneH * 0.05";
                colorBackground[] = {0, 0, 0, 0.55};
                text = "";
            };
        };
    };
};
