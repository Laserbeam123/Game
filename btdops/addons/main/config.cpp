class CfgPatches {
    class btdops_main {
        name = "Bloons TD Ops";
        author = "Bloons TD Ops contributors";
        units[] = {};
        weapons[] = {};
        requiredVersion = 2.14;
        requiredAddons[] = {"A3_Functions_F", "A3_Ui_F", "A3_Characters_F", "A3_Static_F", "A3_Structures_F_Civ_Constructions", "A3_Modules_F"};
    };
};

#include "CfgFunctions.hpp"
#include "CfgSounds.hpp"
#include "ui\base.hpp"
#include "ui\hud.hpp"
#include "ui\tablet.hpp"
#include "ui\mainmenu.hpp"
