// NGanondorf.asm

// This file contains file inclusions, action edits, and assembly for Polygon Ganondorf.

scope NGanondorf {

    // Insert Moveset files

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NGND,   Action.Idle,            -1,                        Ganondorf.IDLE,                       -1)
    Character.edit_action_parameters(NGND,   Action.Run,             -1,                        Ganondorf.RUN,                        -1)
    Character.edit_action_parameters(NGND,   Action.JumpAerialF,     -1,                        Ganondorf.JUMP2,                      -1)
    Character.edit_action_parameters(NGND,   Action.JumpAerialB,     -1,                        Ganondorf.JUMP2,                      -1)
    Character.edit_action_parameters(NGND,   Action.DownBounceD,     -1,                        Ganondorf.DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(NGND,   Action.DownBounceU,     -1,                        Ganondorf.DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(NGND,   Action.DownStandD,      -1,                        Ganondorf.DOWN_STAND,                 -1)
    Character.edit_action_parameters(NGND,   Action.DownStandU,      -1,                        Ganondorf.DOWN_STAND,                 -1)
    Character.edit_action_parameters(NGND,   Action.TechF,           -1,                        Ganondorf.TECHROLL,                   -1)
    Character.edit_action_parameters(NGND,   Action.TechB,           -1,                        Ganondorf.TECHROLL,                   -1)
    Character.edit_action_parameters(NGND,   Action.Tech,            -1,                        Ganondorf.TECHSTAND,                  -1)
    Character.edit_action_parameters(NGND,   Action.CliffAttackQuick2, -1,                      Ganondorf.EDGEATTACKF,                -1)
    Character.edit_action_parameters(NGND,   Action.CliffAttackSlow2, -1,                       Ganondorf.EDGEATTACKS,                -1)
    Character.edit_action_parameters(NGND,   Action.Taunt,           File.GND_TAUNT,            Ganondorf.TAUNT,                      -1)
    Character.edit_action_parameters(NGND,   Action.ShieldBreak,     -1,                        Ganondorf.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NGND,   Action.Stun,             -1,                       Ganondorf.STUN,                       -1)
    Character.edit_action_parameters(NGND,   Action.Jab1,            -1,                        Ganondorf.JAB_1,                      -1)
    Character.edit_action_parameters(NGND,   Action.DashAttack,      -1,                        Ganondorf.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NGND,   Action.FTiltHigh,       -1,                        Ganondorf.FTILT_HI,                   -1)
    Character.edit_action_parameters(NGND,   Action.FTiltMidHigh,    -1,                        Ganondorf.FTILT_M_HI,                 -1)
    Character.edit_action_parameters(NGND,   Action.FTilt,           -1,                        Ganondorf.FTILT,                      -1)
    Character.edit_action_parameters(NGND,   Action.FTiltMidLow,     -1,                        Ganondorf.FTILT_M_LO,                 -1)
    Character.edit_action_parameters(NGND,   Action.FTiltLow,        -1,                        Ganondorf.FTILT_LO,                   -1)
    Character.edit_action_parameters(NGND,   Action.UTilt,           -1,                        Ganondorf.UTILT,                      -1)
    Character.edit_action_parameters(NGND,   Action.DTilt,           -1,                        Ganondorf.DTILT,                      -1)
    Character.edit_action_parameters(NGND,   Action.FSmashHigh,      0,                         0x80000000,                             0)
    Character.edit_action_parameters(NGND,   Action.FSmash,          0x64E,                     Ganondorf.FSMASH,                     0)
    Character.edit_action_parameters(NGND,   Action.FSmashLow,       0,                         0x80000000,                             0)
    Character.edit_action_parameters(NGND,   Action.USmash,          File.GND_USMASH,           Ganondorf.USMASH,                     0)
    Character.edit_action_parameters(NGND,   Action.DSmash,          File.GND_DSMASH,           Ganondorf.DSMASH,                     -1)
    Character.edit_action_parameters(NGND,   Action.AttackAirN,      0x667,                     Ganondorf.NAIR,                       -1)
    Character.edit_action_parameters(NGND,   Action.AttackAirF,      File.GND_FAIR,             Ganondorf.FAIR,                       -1)
    Character.edit_action_parameters(NGND,   Action.AttackAirB,      -1,                        Ganondorf.BAIR,                       -1)
    Character.edit_action_parameters(NGND,   Action.AttackAirU,      -1,                        Ganondorf.UAIR,                       -1)
    Character.edit_action_parameters(NGND,   Action.AttackAirD,      -1,                        Ganondorf.DAIR,                       -1)
    Character.edit_action_parameters(NGND,   Action.LandingAirN,     0x66B,                     0x1720,                               -1)
    Character.edit_action_parameters(NGND,   Action.LandingAirF,     0,                         0x80000000,                           -1)
    Character.edit_action_parameters(NGND,   0xE0,                   0x5E8,                     0x80000000,                         0x00000000)
    Character.edit_action_parameters(NGND,   0xE1,                   0x5E8,                     0x80000000,                        0x00000000)
	Character.edit_action_parameters(NGND,   0xE2,                   0x5E8,                     0x80000000,                        0x00000000)
	Character.edit_action_parameters(NGND,   0xE3,                   0x5E8,                     0x80000000,                        0x00000000)
	Character.edit_action_parameters(NGND,   0xE4,                   -1,                        Ganondorf.NSP_GROUND,                 -1)
    Character.edit_action_parameters(NGND,   0xE5,                   -1,                        Ganondorf.NSP_AIR,                    -1)
    Character.edit_action_parameters(NGND,   0xE6,                   -1,                        Ganondorf.DSP_GROUND,                 -1)
    Character.edit_action_parameters(NGND,   0xE7,                   -1,                        Ganondorf.DSP_FLIP,                   -1)
    Character.edit_action_parameters(NGND,   0xE8,                   -1,                        Ganondorf.DSP_LAND,                   -1)
    Character.edit_action_parameters(NGND,   0xE9,                   -1,                        Ganondorf.DSP_AIR,                    -1)
    Character.edit_action_parameters(NGND,   0xEB,                   -1,                        Ganondorf.USP_GROUND,                 -1)
    Character.edit_action_parameters(NGND,   0xEC,                   -1,                        Ganondorf.USP_GRAB,                   -1)
    Character.edit_action_parameters(NGND,   0xED,                   -1,                        Ganondorf.USP_RELEASE,                -1)
    Character.edit_action_parameters(NGND,   0xEE,                   -1,                        Ganondorf.USP_AIR,                    -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NGND, 0xE0,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NGND, 0xE1,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NGND,   0x1,               -1,                        0x80000000,             -1)
    Character.edit_menu_action_parameters(NGND,   0x2,               File.GND_SELECT,           0x80000000,             -1)
    Character.edit_menu_action_parameters(NGND,   0x3,               File.GND_VICTORY1,         0x80000000,             -1)
    Character.edit_menu_action_parameters(NGND,   0x4,               -1,                        0x80000000,             -1)
    Character.edit_menu_action_parameters(NGND,   0xE,               File.GND_1P_CPU,           0x80000000,                       -1)
    Character.edit_menu_action_parameters(NGND,   0xD,               File.GND_POSE_1P,          0x80000000,                       -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NGND, 0x4)
    float32 1.125
    OS.patch_end()

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.NGND, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.NGND, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
    OS.patch_end()

    // Handles common things for Polygons
    Character.polygon_setup(NGND, GND)

}
