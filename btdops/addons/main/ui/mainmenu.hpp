class RscDisplayMain: RscStandardDisplay {
    class controls {
        class BTD_PlayButton: RscButton {
            idc = 9200;
            text = "PLAY BLOON STRIKE";
            font = "PuristaBold";
            sizeEx = "0.05";
            x = "safeZoneX + safeZoneW * 0.5 - 0.3";
            y = "safeZoneY + safeZoneH * 0.02";
            w = 0.6;
            h = 0.08;
            colorText[] = {1, 1, 1, 1};
            colorBackground[] = {0.8, 0.1, 0.1, 0.95};
            colorBackgroundActive[] = {1, 0.25, 0.2, 1};
            colorFocused[] = {0.9, 0.15, 0.15, 1};
            tooltip = "Solo game. Co-op: Multiplayer > Host > Bloon Strike: Altis - Co-op 1-4";
            action = "playMission ['', '\z\btdops\addons\missions\btdops_solo.Altis', true]";
        };
    };
};
