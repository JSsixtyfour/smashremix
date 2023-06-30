// NFalco.asm

// This file contains file inclusions, action edits, and assembly for Polygon Falco.

scope NFalco {
    // Insert Moveset files

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NFALCO, Action.Run,              -1,                       Falco.RUN,                        -1)
    Character.edit_action_parameters(NFALCO, Action.Dash,             -1,                       Falco.DASH,                       -1)
    Character.edit_action_parameters(NFALCO, Action.JumpAerialF,      -1,                       Falco.JUMP2,                      -1)
    Character.edit_action_parameters(NFALCO, Action.JumpAerialB,      -1,                       Falco.JUMP2,                      -1)
    Character.edit_action_parameters(NFALCO, Action.Grab,             -1,                       Falco.GRAB,                       -1)
    Character.edit_action_parameters(NFALCO, Action.ThrowF,           -1,                       Falco.FTHROW,                     -1)
    Character.edit_action_parameters(NFALCO, Action.ThrowB,           -1,                       Falco.BTHROW,                     -1)
    Character.edit_action_parameters(NFALCO, Action.RollF,            -1,                       Falco.FROLL,                      -1)
    Character.edit_action_parameters(NFALCO, Action.RollB,            -1,                       Falco.BROLL,                      -1)
    Character.edit_action_parameters(NFALCO, Action.TechF,            -1,                       Falco.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NFALCO, Action.TechB,            -1,                       Falco.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NFALCO, Action.Tech,             -1,                       Falco.TECH_STAND,                 -1)
    Character.edit_action_parameters(NFALCO, Action.Teeter,           -1,                       Falco.TEETERING,                  -1)
    Character.edit_action_parameters(NFALCO, Action.ShieldBreak,      -1,                       Falco.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NFALCO, Action.Stun,             -1,                       Falco.STUN,                       -1)
    Character.edit_action_parameters(NFALCO, Action.Sleep,            -1,                       Falco.ASLEEP,                     -1)
    Character.edit_action_parameters(NFALCO, Action.Taunt,           File.FALCO_TAUNT,          Falco.TAUNT,                      -1)
    Character.edit_action_parameters(NFALCO, Action.Jab1,            -1,                        Falco.JAB_1,                      -1)
    Character.edit_action_parameters(NFALCO, Action.Jab2,            -1,                        Falco.JAB_2,                      -1)
    Character.edit_action_parameters(NFALCO, Action.DashAttack,      -1,                        Falco.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NFALCO, Action.FTiltHigh,       -1,                        Falco.FTILT_HI,                   -1)
    Character.edit_action_parameters(NFALCO, Action.FTiltMidHigh,    -1,                        Falco.FTILT_M_HI,                 -1)
    Character.edit_action_parameters(NFALCO, Action.FTilt,           -1,                        Falco.FTILT,                      -1)
    Character.edit_action_parameters(NFALCO, Action.FTiltMidLow,     -1,                        Falco.FTILT_M_LO,                 -1)
    Character.edit_action_parameters(NFALCO, Action.UTilt,           File.FALCO_UTILT,          Falco.UTILT,                      -1)
    Character.edit_action_parameters(NFALCO, Action.DTilt,           -1,                        Falco.DTILT,                      -1)
    Character.edit_action_parameters(NFALCO, Action.FSmash,          File.FALCO_FSMASH,         Falco.FSMASH,                     -1)
    Character.edit_action_parameters(NFALCO, Action.USmash,          -1,                        Falco.USMASH,                     -1)
    Character.edit_action_parameters(NFALCO, Action.AttackAirB,      -1,                        Falco.BAIR,                       -1)
    Character.edit_action_parameters(NFALCO, Action.AttackAirU,      -1,                        Falco.UAIR,                       -1)
    Character.edit_action_parameters(NFALCO, Action.AttackAirD,      -1,                        Falco.DAIR,                       -1)
    Character.edit_action_parameters(NFALCO, 0xE1,                   0x2E9,                     Falco.NSP_GROUND,                 -1)
    Character.edit_action_parameters(NFALCO, 0xE2,                   File.FALCO_NSP_AIR,        Falco.NSP_AIR,                    -1)
    Character.edit_action_parameters(NFALCO, 0xE7,                   -1,                        Falco.USP_GROUND_MOVE,            -1)
    Character.edit_action_parameters(NFALCO, 0xE8,                   -1,                        Falco.USP_AIR_MOVE,               -1)
    Character.edit_action_parameters(NFALCO, 0xEC,                   -1,                        Falco.DSP_GROUND_START,           -1)
    Character.edit_action_parameters(NFALCO, 0xF1,                   -1,                        Falco.DSP_AIR_START,              -1)
    
    Character.edit_action_parameters(NFALCO,    0xDF,                0x282,            0x80000000,                      0x00000000)
    Character.edit_action_parameters(NFALCO,    0xE0,                0x282,            0x80000000,                      0x00000000)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NFALCO, 0xDF,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NFALCO, 0xE0,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NFALCO, 0xE1,              -1,             0x800D94C4,                 Phantasm.ground_subroutine_,    -1,                             -1)
    Character.edit_action(NFALCO, 0xE2,              -1,             0x8015C750,                 Phantasm.air_subroutine_,       Phantasm.air_physics_,          Phantasm.air_collision_)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NFALCO, 0x1,               -1,                        0x80000000,             -1)
    Character.edit_menu_action_parameters(NFALCO, 0x2,               File.FALCO_SELECT,         0x80000000,             -1)
    Character.edit_menu_action_parameters(NFALCO, 0x3,               -1,                        0x80000000,             -1)
    Character.edit_menu_action_parameters(NFALCO, 0x4,               File.FALCO_SELECT,         0x80000000,             -1)
    Character.edit_menu_action_parameters(NFALCO, 0x5,               File.FALCO_CLAP,           0x80000000,                       -1)
    Character.edit_menu_action_parameters(NFALCO, 0xD,               File.FALCO_POSE_1P,        0x80000000,                    -1)
    Character.edit_menu_action_parameters(NFALCO, 0xE,               File.FALCO_1P_DUO_POSE,    0x80000000,                    -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NFALCO, 0x4)
    float32 1.2
    OS.patch_end()

    // Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.NFALCO, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
    OS.patch_end()


    // Set action strings
    Character.table_patch_start(action_string, Character.id.NFALCO, 0x4)
    dw  Falco.Action.action_string_table
    OS.patch_end()
    
    // Handles common things for Polygons
    Character.polygon_setup(NFALCO, FALCO)

}
