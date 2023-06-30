
constant STEP_FGM(0x7A)

VICTORY_1:
Moveset.AFTER(0x6C)
Moveset.SFX(STEP_FGM)
Moveset.END()

VICTORY_2:
Moveset.AFTER(0x27)
Moveset.SFX(STEP_FGM)
Moveset.AFTER(0x44)
Moveset.SFX(STEP_FGM)
Moveset.AFTER(0x64)
Moveset.SFX(STEP_FGM)
Moveset.END()

VICTORY_3:
Moveset.AFTER(0x62)
Moveset.SFX(STEP_FGM)
Moveset.END()

// CLAP:
// Moveset.SFX(STEP_FGM); Moveset.WAIT(0xC); Moveset.SFX(STEP_FGM); Moveset.WAIT(0x17 - 0xC);
// Moveset.SFX(STEP_FGM) Moveset.WAIT(0x23 - 0x17); Moveset.SFX(STEP_FGM); Moveset.WAIT(0x2F - 0x23);
// Moveset.SFX(STEP_FGM); Moveset.WAIT(0x3C - 0x2F); Moveset.SFX(STEP_FGM); Moveset.WAIT(0x48 - 0x3C);
// Moveset.SFX(STEP_FGM); Moveset.WAIT(0x54 - 0x48); Moveset.SFX(STEP_FGM); Moveset.WAIT(0x60 - 0x54);
// Moveset.SFX(STEP_FGM); Moveset.WAIT(0x6C - 0x60); Moveset.SFX(STEP_FGM); Moveset.WAIT(0x77 - 0x6C);
// Moveset.GO_TO(CLAP);    // loops

    Character.edit_menu_action_parameters(METAL, 0x1,           -1,       VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(METAL, 0x2,           -1,       VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(METAL, 0x3,           -1,       VICTORY_3,                  -1)
    Character.edit_menu_action_parameters(METAL, 0x4,           -1,       0x80000000,                 -1)
    //Character.edit_menu_action_parameters(METAL, 0x5,           -1,       CLAP,                       -1) // cursed clap
