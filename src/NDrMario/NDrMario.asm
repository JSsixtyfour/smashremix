// NDrMario.asm

// This file contains file inclusions, action edits, and assembly for Polygon Dr. Mario.

scope NDrMario {
    // Insert Moveset files

    // Modify Action Parameters              // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NDRM,   Action.Taunt,           File.DRM_TAUNT,             DrMario.TAUNT,                      -1)
    Character.edit_action_parameters(NDRM,   Action.Jab1,            -1,                         DrMario.JAB_1,                      -1)
    Character.edit_action_parameters(NDRM,   Action.Jab2,            -1,                         DrMario.JAB_2,                      -1)
    Character.edit_action_parameters(NDRM,   Action.DashAttack,      -1,                         DrMario.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NDRM,   Action.FTiltHigh,       -1,                         DrMario.FTILT_HI,                   -1)
    Character.edit_action_parameters(NDRM,   Action.FTilt,           -1,                         DrMario.FTILT,                      -1)
    Character.edit_action_parameters(NDRM,   Action.FTiltLow,        -1,                         DrMario.FTILT_LO,                   -1)
    Character.edit_action_parameters(NDRM,   Action.UTilt,           -1,                         DrMario.UTILT,                      -1)
    Character.edit_action_parameters(NDRM,   Action.DTilt,           -1,                         DrMario.DTILT,                      -1)
    Character.edit_action_parameters(NDRM,   Action.FSmashHigh,      -1,                         DrMario.FSMASH_HI,                  -1)
    Character.edit_action_parameters(NDRM,   Action.FSmashMidHigh,   -1,                         DrMario.FSMASH_M_HI,                -1)
    Character.edit_action_parameters(NDRM,   Action.FSmash,          -1,                         DrMario.FSMASH,                     -1)
    Character.edit_action_parameters(NDRM,   Action.FSmashMidLow,    -1,                         DrMario.FSMASH_M_LO,                -1)
    Character.edit_action_parameters(NDRM,   Action.FSmashLow,       -1,                         DrMario.FSMASH_LO,                  -1)
    Character.edit_action_parameters(NDRM,   Action.USmash,          -1,                         DrMario.USMASH,                     -1)
    Character.edit_action_parameters(NDRM,   Action.DSmash,          -1,                         DrMario.DSMASH,                     -1)
    Character.edit_action_parameters(NDRM,   Action.AttackAirN,      -1,                         DrMario.NAIR,                       -1)
    Character.edit_action_parameters(NDRM,   Action.AttackAirF,      File.DRM_FAIR,              DrMario.FAIR,                       -1)
    Character.edit_action_parameters(NDRM,   Action.AttackAirB,      -1,                         DrMario.BAIR,                       -1)
    Character.edit_action_parameters(NDRM,   Action.AttackAirU,      -1,                         DrMario.UAIR,                       -1)
    Character.edit_action_parameters(NDRM,   Action.AttackAirD,      File.DRM_DAIR,              DrMario.DAIR,                       0)
    Character.edit_action_parameters(NDRM,   0xDC,                   -1,                         DrMario.JAB_3,                      -1)
    Character.edit_action_parameters(NDRM,   0xDF,                   -1,                         DrMario.NSP_GROUND,                 -1)
    Character.edit_action_parameters(NDRM,   0xE0,                   -1,                         DrMario.NSP_AIR,                    -1)
    Character.edit_action_parameters(NDRM,   0xE1,                   -1,                         DrMario.USP,                        -1)
    Character.edit_action_parameters(NDRM,   0xE2,                   -1,                         DrMario.USP,                        -1)
    Character.edit_action_parameters(NDRM,   0xE3,                   -1,                         DrMario.DSP_GROUND,                 -1)
    Character.edit_action_parameters(NDRM,   0xE4,                   -1,                         DrMario.DSP_AIR,                    -1)
    Character.edit_action_parameters(NDRM,   Action.ThrowB,          File.DRM_BTHROW,            DrMario.BTHROW,                     0x50000000)
    Character.edit_action_parameters(NDRM,   0xDD,                   0x1F3,                      0x80000000,                      0x00000000)
    Character.edit_action_parameters(NDRM,   0xDE,                   0x1F3,                      0x80000000,                      0x00000000)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NDRM, 0xDD,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NDRM, 0xDE,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NDRM,     0xE,                File.DRM_1P_CPU_POSE,       0x80000000,                 -1)
    Character.edit_menu_action_parameters(NDRM,     0x4,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NDRM,     0x3,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NDRM,     0x2,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NDRM,     0x1,                -1,                         0x80000000,                 -1)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.NDRM, 0x4)
    dw  DrMario.Action.action_string_table
    OS.patch_end()

    // Handles common things for Polygons
    Character.polygon_setup(NDRM, DRM)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NDRM, 0x4)
    dw      DrMario.CPU_ATTACKS
    OS.patch_end()
    
}
