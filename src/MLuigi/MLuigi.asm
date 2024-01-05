// MLUIGI.asm

// This file contains file inclusions, action edits, and assembly for MLUIGI.

scope MLUIGI {
    // Insert Moveset files

constant STEP_FGM(0x7A)

    insert WALK2, "moveset/WALK2.bin"; Moveset.GO_TO(WALK2)            	// loops
    insert WALK3, "moveset/WALK3.bin"; Moveset.GO_TO(WALK3)            	// loops
    insert RUN, "moveset/RUN.bin"; Moveset.GO_TO(RUN)            		// loops
    insert DASH, "moveset/DASH.bin"
    insert LANDING_LIGHT,"moveset/LANDING_LIGHT.bin"
    insert LANDING_HEAVY,"moveset/LANDING_HEAVY.bin"
    insert LANDING_AIR,"moveset/LANDING_AIR.bin"
    insert VICTORY_1,"moveset/VICTORY_1.bin"

    SHUFFLE_VICTORY:
    Moveset.AFTER(0x0C);
    Moveset.SFX(STEP_FGM);
    Moveset.AFTER(0x2A);
    Moveset.SFX(STEP_FGM);
    Moveset.AFTER(0x47);
    Moveset.SFX(STEP_FGM);
    Moveset.AFTER(0x65);
    Moveset.SFX(STEP_FGM);
    Moveset.END();

    // insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"                        // sounds fun

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(MLUIGI,   Action.Walk2,           -1,                      WALK2,                      -1)
    Character.edit_action_parameters(MLUIGI,   Action.Walk3,           -1,                      WALK3,                      -1)
    Character.edit_action_parameters(MLUIGI,   Action.Dash,            -1,                      DASH,                       -1)
    Character.edit_action_parameters(MLUIGI,   Action.Run,             -1,                      RUN,                        -1)
    Character.edit_action_parameters(MLUIGI,   Action.LandingLight,    -1,                      LANDING_LIGHT,              -1)
    Character.edit_action_parameters(MLUIGI,   Action.LandingHeavy,    -1,                      LANDING_HEAVY,              -1)
    Character.edit_action_parameters(MLUIGI,   Action.LandingSpecial,  -1,                      LANDING_HEAVY,              -1)
    Character.edit_action_parameters(MLUIGI,   Action.LandingAirF,     -1,                      LANDING_AIR,                -1)
    Character.edit_action_parameters(MLUIGI,   Action.LandingAirB,     -1,                      LANDING_AIR,                -1)
    Character.edit_action_parameters(MLUIGI,   Action.LandingAirX,     -1,                      LANDING_AIR,                -1)
    //Character.edit_action_parameters(MLUIGI,   Action.DashAttack,      -1,                      DASH_ATTACK,                      -1)

    // Modify Menu Action Parameters              // Action      // Animation                  // Moveset Data             // Flags
    Character.edit_menu_action_parameters(MLUIGI, 0x1,           -1,                            VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(MLUIGI, 0x2,           -1,                            SHUFFLE_VICTORY,            -1)
    Character.edit_menu_action_parameters(MLUIGI, 0x4,           -1,                            VICTORY_1,                  -1)

    Character.table_patch_start(variant_original, Character.id.MLUIGI, 0x4)
    dw      Character.id.LUIGI // set Luigi as original character (not Mario, who MLUIGI is a clone of)
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MLUIGI, 0x2)
    dh  0x0260
    OS.patch_end()
    
    // Add initial script/passive armor.
    Character.table_patch_start(initial_script, Character.id.MLUIGI, 0x4)
    dw initial_script_
    OS.patch_end()
    
    // @ Description
    // Sets Metal Luigi's Passive Armor. This is based on Giant DK's script at 800D7DD4.
    scope initial_script_: {
        lui        at, 0x41F0
        mtc1    at, f6
        nop
        swc1    f6, 0x07E4(v1)
        j        0x800D7F0C
        sw        r0, 0x0ADC(v1)
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MLUIGI, 0x4)
    dw  Action.LUIGI.action_string_table
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.MLUIGI, 0, 1, 4, 5, 1, 3, 2)
    Teams.add_team_costume(YELLOW, MLUIGI, 0x4)
    
    // Shield colors for costume matching
    Character.set_costume_shield_colors(MLUIGI, BLACK, RED, GREEN, BLUE, YELLOW, ORANGE, NA, NA)

    // No skeleton if hit by electric attacks
    Character.table_patch_start(electric_hit, Character.id.MLUIGI, 0x4)
    dw 0x10
    OS.patch_end()

    // @ Description
    // Adds other metal characters to Metal Mario character id check
    metal_luigi_ai: {
        OS.patch_start(0xAD4E4, 0x80132AA4)
        j       metal_luigi_ai  // og = BNEL S7, T3, 0x80132ABC
        nop                     // og = SUB.S F0, F26, F20
        _return:
        OS.patch_end()

        // s7 = METAL characer ID
        beq     s7, t3, _metal
        addiu   s7, r0, Character.id.MLUIGI
        beq     s7, t3, _metal
        nop

        j       0x80132ABC
        sub.s   f0, f26, f20

        _metal:
        j       _return
        nop
    }
}
