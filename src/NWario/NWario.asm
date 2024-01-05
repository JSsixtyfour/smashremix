// nwario.asm

// This file contains file inclusions, action edits, and assembly for Wario.

        // insert moveset


scope NWARIO {
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NWARIO, Action.Entry,           File.WARIO_IDLE,            Wario.IDLE,                       -1)
    Character.edit_action_parameters(NWARIO, Action.ReviveWait,      File.WARIO_IDLE,            Wario.IDLE,                       -1)
    Character.edit_action_parameters(NWARIO, Action.Idle,            File.WARIO_IDLE,            Wario.IDLE,                       -1)
    Character.edit_action_parameters(NWARIO, Action.Dash,            File.WARIO_DASH,            Wario.DASH,                       -1)
    Character.edit_action_parameters(NWARIO, Action.Run,             File.WARIO_RUN,             Wario.RUN,                        -1)
    Character.edit_action_parameters(NWARIO, Action.RunBrake,        File.WARIO_RUN_BRAKE,       -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.Turn,            File.WARIO_TURN,            -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.TurnRun,         File.WARIO_RUN_TURN,        Wario.RUN_TURN,                   -1)
    Character.edit_action_parameters(NWARIO, Action.JumpSquat,       File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.ShieldJumpSquat, File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.JumpF,           File.WARIO_JUMP_F,          Wario.JUMP_1,                     -1)
    Character.edit_action_parameters(NWARIO, Action.JumpB,           File.WARIO_JUMP_B,          Wario.JUMP_1,                     -1)
    Character.edit_action_parameters(NWARIO, Action.JumpAerialF,     File.WARIO_JUMP_AERIAL_F,   Wario.JUMP_2_F,                   -1)
    Character.edit_action_parameters(NWARIO, Action.JumpAerialB,     File.WARIO_JUMP_AERIAL_B,   Wario.JUMP_2_B,                   -1)
    Character.edit_action_parameters(NWARIO, Action.Crouch,          File.WARIO_CROUCH_BEGIN,    -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.CrouchIdle,      File.WARIO_CROUCH_IDLE,     -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.CrouchEnd,       File.WARIO_CROUCH_END,      -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.LandingLight,    File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.LandingHeavy,    File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.LandingSpecial,  File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.Tech,            -1,                         Wario.TECH_STAND,                 -1)
    Character.edit_action_parameters(NWARIO, Action.TechF,           -1,                         Wario.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NWARIO, Action.TechB,           -1,                         Wario.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NWARIO, Action.RollF,           -1,                         Wario.ROLL_F,                     -1)
    Character.edit_action_parameters(NWARIO, Action.RollB,           -1,                         Wario.ROLL_B,                     -1)
    Character.edit_action_parameters(NWARIO, Action.CliffAttackQuick1, File.WARIO_LEDGE_ATK_F_1, -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.CliffAttackQuick2, File.WARIO_LEDGE_ATK_F_2, Wario.EDGE_ATTACK_F,              -1)
    Character.edit_action_parameters(NWARIO, Action.CliffAttackSlow2, -1,                        Wario.EDGE_ATTACK_S,              -1)
    Character.edit_action_parameters(NWARIO, Action.ShieldBreak,     -1,                         Wario.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NWARIO, Action.Stun,            -1,                         Wario.STUN,                       -1)
    Character.edit_action_parameters(NWARIO, Action.Sleep,           -1,                         Wario.ASLEEP,                     -1)
    Character.edit_action_parameters(NWARIO, Action.Grab,            File.WARIO_GRAB,            Wario.GRAB,                       -1)
    Character.edit_action_parameters(NWARIO, Action.GrabPull,        File.WARIO_GRAB_PULL,       Wario.IDLE,                       -1)
    Character.edit_action_parameters(NWARIO, Action.DownAttackD,     -1,                         Wario.DOWN_ATTACK_D,              -1)
    Character.edit_action_parameters(NWARIO, Action.DownAttackU,     -1,                         Wario.DOWN_ATTACK_U,              -1)
    Character.edit_action_parameters(NWARIO, Action.ThrowF,          File.WARIO_FTHROW,          Wario.FTHROW,                     0x50000000)
    Character.edit_action_parameters(NWARIO, Action.ThrowB,          File.WARIO_BTHROW,          Wario.BTHROW,                     0x50000000)
    Character.edit_action_parameters(NWARIO, Action.EggLay,          File.WARIO_IDLE,            Wario.IDLE,                       -1)
    Character.edit_action_parameters(NWARIO, Action.Taunt,           File.WARIO_TAUNT,           Wario.TAUNT,                      -1)
    Character.edit_action_parameters(NWARIO, Action.Jab1,            File.WARIO_JAB_1,           Wario.JAB_1,                      -1)
    Character.edit_action_parameters(NWARIO, Action.Jab2,            File.WARIO_JAB_2,           Wario.JAB_2,                      -1)
    Character.edit_action_parameters(NWARIO, Action.DashAttack,      File.WARIO_DASH_ATTACK,     Wario.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NWARIO, Action.FTiltHigh,       File.WARIO_FTILT_HIGH,      Wario.FTILT_HI,                   0x40000000)
    Character.edit_action_parameters(NWARIO, Action.FTiltMidHigh,    0,                          0x80000000,                 0)
    Character.edit_action_parameters(NWARIO, Action.FTilt,           File.WARIO_FTILT,           Wario.FTILT,                      0x40000000)
    Character.edit_action_parameters(NWARIO, Action.FTiltMidLow,     0,                          0x80000000,                 0)
    Character.edit_action_parameters(NWARIO, Action.FTiltLow,        File.WARIO_FTILT_LOW,       Wario.FTILT_LO,                   0x40000000)
    Character.edit_action_parameters(NWARIO, Action.UTilt,           File.WARIO_UTILT,           Wario.UTILT,                      0)
    Character.edit_action_parameters(NWARIO, Action.DTilt,           File.WARIO_DTILT,           Wario.DTILT,                      -1)
    Character.edit_action_parameters(NWARIO, Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(NWARIO, Action.FSmashMidHigh,   0,                          0x80000000,                 0)
    Character.edit_action_parameters(NWARIO, Action.FSmash,          File.WARIO_FSMASH,          Wario.FSMASH,                     0x40000000)
    Character.edit_action_parameters(NWARIO, Action.FSmashMidLow,    0,                          0x80000000,                 0)
    Character.edit_action_parameters(NWARIO, Action.FSmashLow,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(NWARIO, Action.USmash,          File.WARIO_USMASH,          Wario.USMASH,                     -1)
    Character.edit_action_parameters(NWARIO, Action.DSmash,          File.WARIO_DSMASH,          Wario.DSMASH,                     0x80000000)
    Character.edit_action_parameters(NWARIO, Action.AttackAirN,      File.WARIO_NAIR,            Wario.NAIR,                       -1)
    Character.edit_action_parameters(NWARIO, Action.AttackAirF,      File.WARIO_FAIR,            Wario.FAIR,                       -1)
    Character.edit_action_parameters(NWARIO, Action.AttackAirB,      File.WARIO_BAIR,            Wario.BAIR,                       -1)
    Character.edit_action_parameters(NWARIO, Action.AttackAirU,      File.WARIO_UAIR,            Wario.UAIR,                       -1)
    Character.edit_action_parameters(NWARIO, Action.AttackAirD,      File.WARIO_DAIR,            Wario.DAIR,                       0)
    Character.edit_action_parameters(NWARIO, Action.LandingAirX,     File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(NWARIO, Action.LandingAirU,     File.WARIO_LANDING_U,       Wario.LANDING_AIR_U,              -1)
    Character.edit_action_parameters(NWARIO, 0xDD,                   File.WARIO_IDLE,            0x80000000,                      0x00000000)
    Character.edit_action_parameters(NWARIO, 0xDE,                   File.WARIO_IDLE,            0x80000000,                      0x00000000)
    Character.edit_action_parameters(NWARIO, 0xDF,                   File.WARIO_NSP_GROUND,      Wario.NSP_GROUND,                 -1)
    Character.edit_action_parameters(NWARIO, 0xE0,                   File.WARIO_NSP_AIR,         Wario.NSP_AIR,                    -1)
    Character.edit_action_parameters(NWARIO, 0xE1,                   File.WARIO_USP,             Wario.USP,                        0)
    Character.edit_action_parameters(NWARIO, 0xE2,                   File.WARIO_DSP_LANDING,     Wario.DSP_LANDING,                0)
    Character.edit_action_parameters(NWARIO, 0xE3,                   File.WARIO_DSP_GROUND,      Wario.DSP_GROUND,                 0)
    Character.edit_action_parameters(NWARIO, 0xE4,                   File.WARIO_DSP_AIR,         Wario.DSP_AIR,                    0)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NWARIO, 0xDD,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NWARIO, 0xDE,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NWARIO, 0xDF,              -1,             0x800D94C4,                 WarioNSP.ground_move_,          WarioNSP.ground_physics_,       WarioNSP.ground_collision_)
    Character.edit_action(NWARIO, 0xE0,              -1,             0x800D94E8,                 WarioNSP.air_move_,             WarioNSP.air_physics_,          WarioNSP.air_collision_)
    Character.edit_action(NWARIO, 0xE1,              -1,             WarioUSP.main_,             WarioUSP.change_direction_,     WarioUSP.physics_,              WarioUSP.collision_)
    Character.edit_action(NWARIO, 0xE2,              0x1E,           0x800D94C4,                 0,                              0x800D8BB4,                     0x800DDEE8)
    Character.edit_action(NWARIO, 0xE3,              -1,             0x800D94E8,                 WarioDSP.ground_move_,          WarioDSP.physics_,              WarioDSP.collision_)
    Character.edit_action(NWARIO, 0xE4,              -1,             0x800D94E8,                 WarioDSP.air_move_,             WarioDSP.physics_,              WarioDSP.collision_)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(WARIO,  NSP_Recoil_Ground,  -1,             File.WARIO_NSP_RECOIL_G,    Wario.NSP_RECOIL,                 0)
    Character.add_new_action_params(WARIO,  NSP_Recoil_Air,     -1,             File.WARIO_NSP_RECOIL_A,    Wario.NSP_RECOIL,                 0)

    // Add Actions                  // Action Name      // Base Action  //Parameters                        // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.add_new_action(NWARIO, NSP_Recoil_Ground,  -1,             ActionParams.NSP_Recoil_Ground,     0x12,           0x800D94C4,                 0,                              0x800D8BB4,                     WarioNSP.recoil_ground_collision_)
    Character.add_new_action(NWARIO, NSP_Recoil_Air,     -1,             ActionParams.NSP_Recoil_Air,        0x12,           0x800D94E8,                 WarioNSP.recoil_move_,          WarioNSP.recoil_physics_,       WarioNSP.recoil_air_collision_)

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NWARIO,    0x0,                File.WARIO_IDLE,            Wario.IDLE,                 -1)
    Character.edit_menu_action_parameters(NWARIO,    0x1,                File.WARIO_VICTORY_1,       0x80000000,                  0)
    Character.edit_menu_action_parameters(NWARIO,    0x2,                File.WARIO_VICTORY_2,       0x80000000,                  0)
    Character.edit_menu_action_parameters(NWARIO,    0x3,                File.WARIO_VICTORY_3,       0x80000000,                  0)
    Character.edit_menu_action_parameters(NWARIO,    0x4,                File.WARIO_VICTORY_3,       0x80000000,                      0)
    Character.edit_menu_action_parameters(NWARIO,    0x5,                File.WARIO_CLAP,            Wario.CLAPPING,              0)
    Character.edit_menu_action_parameters(NWARIO,    0xD,                File.WARIO_POSE_1P,         Wario.POSE_1P,              -1)
    Character.edit_menu_action_parameters(NWARIO,    0xE,                File.WARIO_1P_CPU_POSE,     0x80000000,                 -1)

    Character.table_patch_start(ground_nsp, Character.id.NWARIO, 0x4)
    dw      WarioNSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.NWARIO, 0x4)
    dw      WarioNSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.NWARIO, 0x4)
    dw      WarioUSP.initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.NWARIO, 0x4)
    dw      WarioUSP.initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.NWARIO, 0x4)
    dw      WarioDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.NWARIO, 0x4)
    dw      WarioDSP.air_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NWARIO, 0x4)
    float32 1.4
    OS.patch_end()

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.NWARIO, 0x2)
    dh  0x00A0
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NWARIO, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.NWARIO, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.NWARIO, 0xC)
    dw Character.kirby_inhale_struct.star_damage.YOSHI
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NWARIO, 0x4)
    dw      Wario.CPU_ATTACKS
    OS.patch_end()

    // Handles common things for Polygons
    Character.polygon_setup(NWARIO, WARIO)

}
