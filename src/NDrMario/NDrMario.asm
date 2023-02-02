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

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.NDRM, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.NDRM, 0xC)
    dh 0x8
    OS.patch_end()
    
    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NDRM, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.NDRM, 0, 1, 4, 5, 1, 3, 2)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(NDRM, PURPLE, RED, GREEN, BLUE, BLACK, WHITE, NA, NA)

    // @ Description
    // Dr. Mario's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant Appear1(0x0DD)
        constant Appear2(0x0DE)
        constant Capsule(0x0DF)
        constant CapsuleAir(0x0E0)
        constant SuperJumpPunch(0x0E1)
        constant SuperJumpPunchAir(0x0E2)
        constant MarioTornado(0x0E3)
        constant MarioTornadoAir(0x0E4)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("Appear1")
        //string_0x0DE:; String.insert("Appear2")
        string_0x0DF:; String.insert("Capsule")
        string_0x0E0:; String.insert("CapsuleAir")
        //string_0x0E1:; String.insert("SuperJumpPunch")
        //string_0x0E2:; String.insert("SuperJumpPunchAir")
        //string_0x0E3:; String.insert("MarioTornado")
        //string_0x0E4:; String.insert("MarioTornadoAir")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DF
        dw string_0x0E0
        dw Action.MARIO.string_0x0E1
        dw Action.MARIO.string_0x0E2
        dw Action.MARIO.string_0x0E3
        dw Action.MARIO.string_0x0E4
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.NDRM, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NDRM, 0x4)
    dw      DrMario.CPU_ATTACKS
    OS.patch_end()
}
