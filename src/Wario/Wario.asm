// Wario.asm

// This file contains file inclusions, action edits, and assembly for Wario.

scope Wario {
    // Insert Moveset files
    insert BLINK,"moveset/BLINK.bin"
    IDLE:
    // Idle commands are defined here instead of in a bin file in order to use subroutines.
    dw 0x80000003                                   // begin loop 3x
        Moveset.SUBROUTINE(BLINK)                   // blink
        dw 0x0400005A; Moveset.SUBROUTINE(BLINK)    // wait 90 frames then blink
        dw 0x0400000A; Moveset.SUBROUTINE(BLINK)    // wait 10 frames then blink
        dw 0x04000050; dw 0x84000000                // wait 80 frames then end loop
    dw 0x0400003C; dw 0xAC000002                    // wait 60 frames then half shut eyes
    dw 0x04000001; dw 0xAC000003                    // wait 1 frames then shut eyes
    dw 0x0400000A; dw 0xAC000002                    // wait 10 frames then half shut eyes
    dw 0x04000064; dw 0xAC000003                    // wait 100 frames then shut eyes
    dw 0x0400000F; dw 0xAC000002                    // wait 15 frames then half shut eyes
    dw 0x04000096; dw 0xAC000003                    // wait 150 frames then shut eyes
    dw 0x04000168; dw 0xAC000002                    // wait 360 frames then half shut eyes
    dw 0x04000001; dw 0xAC000006                    // wait 1 frames then squint
    dw 0x04000096; dw 0xAC000000                    // wait 150 frames then open eyes
    dw 0x0400003C; Moveset.GO_TO(IDLE)              // wait 60 frames then go to beginning
    insert DASH,"moveset/DASH.bin"
    insert RUN,"moveset/RUN.bin"
    insert RUN_LOOP,"moveset/RUN_LOOP.bin"; Moveset.GO_TO(RUN_LOOP)                 // loops
    insert RUN_TURN,"moveset/RUN_TURN.bin"
    insert JUMP_1,"moveset/JUMP_1.bin"
    insert JUMP_2_F,"moveset/JUMP_2_F.bin"
    insert JUMP_2_B,"moveset/JUMP_2_B.bin"
    insert TECH_STAND,"moveset/TECH_STAND.bin"
    insert TECH_ROLL,"moveset/TECH_ROLL.bin"
    insert DOWN_ATTACK_D,"moveset/DOWN_ATTACK_D.bin"
    insert DOWN_ATTACK_U,"moveset/DOWN_ATTACK_U.bin"
    insert ROLL_F,"moveset/ROLL_F.bin"
    insert ROLL_B,"moveset/ROLL_B.bin"
    insert EDGE_ATTACK_F,"moveset/EDGE_ATTACK_F.bin"
    insert EDGE_ATTACK_S,"moveset/EDGE_ATTACK_S.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert FTHROW_DATA,"moveset/FORWARD_THROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FORWARD_THROW.bin"
    insert BTHROW_DATA,"moveset/BACK_THROW_DATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BACK_THROW.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT_HI,"moveset/FORWARD_TILT_HIGH.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert FTILT_LO,"moveset/FORWARD_TILT_LOW.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"
    insert LANDING_AIR_U,"moveset/LANDING_AIR_U.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NSP_RECOIL,"moveset/NEUTRAL_SPECIAL_RECOIL.bin"
    insert NSP_TRAIL,"moveset/NEUTRAL_SPECIAL_TRAIL.bin"
    NSP_GROUND:; Moveset.CONCURRENT_STREAM(NSP_TRAIL); insert "moveset/NEUTRAL_SPECIAL_GROUND.bin"
    NSP_AIR:; Moveset.CONCURRENT_STREAM(NSP_TRAIL); insert "moveset/NEUTRAL_SPECIAL_AIR.bin"
    insert USP,"moveset/UP_SPECIAL.bin"
    insert DSP_LANDING,"moveset/DOWN_SPECIAL_LANDING.bin"
    insert DSP_GROUND,"moveset/DOWN_SPECIAL_GROUND.bin"
    insert DSP_AIR,"moveset/DOWN_SPECIAL_AIR.bin"
    insert VICTORY_LOOP,"moveset/VICTORY_LOOP.bin"; Moveset.GO_TO(VICTORY_LOOP)   // loops
    insert VICTORY_1,"moveset/VICTORY_1.bin"; Moveset.GO_TO(VICTORY_LOOP)
    insert VICTORY_2,"moveset/VICTORY_2.bin"; Moveset.GO_TO(VICTORY_LOOP)
    insert VICTORY_3,"moveset/VICTORY_3.bin"; Moveset.GO_TO(VICTORY_LOOP)
    insert SELECT,"moveset/VICTORY_3.bin"; dw 0x04000708 ; Moveset.GO_TO(VICTORY_LOOP) // wait 30 seconds before starting victory loop
    insert CLAPPING,"moveset/CLAPPING.bin"
    insert ENTRY,"moveset/ENTRY.bin"
    insert POSE_1P, "moveset/POSE_1P.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(WARIO, Action.Entry,           File.WARIO_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(WARIO, Action.ReviveWait,      File.WARIO_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(WARIO, Action.Idle,            File.WARIO_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(WARIO, Action.Dash,            File.WARIO_DASH,            DASH,                       -1)
    Character.edit_action_parameters(WARIO, Action.Run,             File.WARIO_RUN,             RUN,                        -1)
    Character.edit_action_parameters(WARIO, Action.RunBrake,        File.WARIO_RUN_BRAKE,       -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.Turn,            File.WARIO_TURN,            -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.TurnRun,         File.WARIO_RUN_TURN,        RUN_TURN,                   -1)
    Character.edit_action_parameters(WARIO, Action.JumpSquat,       File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.ShieldJumpSquat, File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.JumpF,           File.WARIO_JUMP_F,          JUMP_1,                     -1)
    Character.edit_action_parameters(WARIO, Action.JumpB,           File.WARIO_JUMP_B,          JUMP_1,                     -1)
    Character.edit_action_parameters(WARIO, Action.JumpAerialF,     File.WARIO_JUMP_AERIAL_F,   JUMP_2_F,                   -1)
    Character.edit_action_parameters(WARIO, Action.JumpAerialB,     File.WARIO_JUMP_AERIAL_B,   JUMP_2_B,                   -1)
    Character.edit_action_parameters(WARIO, Action.Crouch,          File.WARIO_CROUCH_BEGIN,    -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.CrouchIdle,      File.WARIO_CROUCH_IDLE,     -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.CrouchEnd,       File.WARIO_CROUCH_END,      -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.LandingLight,    File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.LandingHeavy,    File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.LandingSpecial,  File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.Tech,            -1,                         TECH_STAND,                 -1)
    Character.edit_action_parameters(WARIO, Action.TechF,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(WARIO, Action.TechB,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(WARIO, Action.RollF,           -1,                         ROLL_F,                     -1)
    Character.edit_action_parameters(WARIO, Action.RollB,           -1,                         ROLL_B,                     -1)
    Character.edit_action_parameters(WARIO, Action.CliffAttackQuick1, File.WARIO_LEDGE_ATK_F_1, -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.CliffAttackQuick2, File.WARIO_LEDGE_ATK_F_2, EDGE_ATTACK_F,              -1)
    Character.edit_action_parameters(WARIO, Action.CliffAttackSlow2, -1,                        EDGE_ATTACK_S,              -1)
    Character.edit_action_parameters(WARIO, Action.ShieldBreak,     -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(WARIO, Action.Stun,            -1,                         STUN,                       -1)
    Character.edit_action_parameters(WARIO, Action.Sleep,           -1,                         ASLEEP,                     -1)
    Character.edit_action_parameters(WARIO, Action.Grab,            File.WARIO_GRAB,            GRAB,                       -1)
    Character.edit_action_parameters(WARIO, Action.GrabPull,        File.WARIO_GRAB_PULL,       IDLE,                       -1)
    Character.edit_action_parameters(WARIO, Action.DownAttackD,     -1,                         DOWN_ATTACK_D,              -1)
    Character.edit_action_parameters(WARIO, Action.DownAttackU,     -1,                         DOWN_ATTACK_U,              -1)
    Character.edit_action_parameters(WARIO, Action.ThrowF,          File.WARIO_FTHROW,          FTHROW,                     0x50000000)
    Character.edit_action_parameters(WARIO, Action.ThrowB,          File.WARIO_BTHROW,          BTHROW,                     0x50000000)
    Character.edit_action_parameters(WARIO, Action.EggLay,          File.WARIO_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(WARIO, Action.Taunt,           File.WARIO_TAUNT,           TAUNT,                      -1)
    Character.edit_action_parameters(WARIO, Action.Jab1,            File.WARIO_JAB_1,           JAB_1,                      -1)
    Character.edit_action_parameters(WARIO, Action.Jab2,            File.WARIO_JAB_2,           JAB_2,                      -1)
    Character.edit_action_parameters(WARIO, Action.DashAttack,      File.WARIO_DASH_ATTACK,     DASH_ATTACK,                -1)
    Character.edit_action_parameters(WARIO, Action.FTiltHigh,       File.WARIO_FTILT_HIGH,      FTILT_HI,                   0x40000000)
    Character.edit_action_parameters(WARIO, Action.FTiltMidHigh,    0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FTilt,           File.WARIO_FTILT,           FTILT,                      0x40000000)
    Character.edit_action_parameters(WARIO, Action.FTiltMidLow,     0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FTiltLow,        File.WARIO_FTILT_LOW,       FTILT_LO,                   0x40000000)
    Character.edit_action_parameters(WARIO, Action.UTilt,           File.WARIO_UTILT,           UTILT,                      0)
    Character.edit_action_parameters(WARIO, Action.DTilt,           File.WARIO_DTILT,           DTILT,                      -1)
    Character.edit_action_parameters(WARIO, Action.FSmashHigh,      0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FSmashMidHigh,   0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FSmash,          File.WARIO_FSMASH,          FSMASH,                     0x40000000)
    Character.edit_action_parameters(WARIO, Action.FSmashMidLow,    0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.FSmashLow,       0,                          0x80000000,                 0)
    Character.edit_action_parameters(WARIO, Action.USmash,          File.WARIO_USMASH,          USMASH,                     -1)
    Character.edit_action_parameters(WARIO, Action.DSmash,          File.WARIO_DSMASH,          DSMASH,                     0x80000000)
    Character.edit_action_parameters(WARIO, Action.AttackAirN,      File.WARIO_NAIR,            NAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirF,      File.WARIO_FAIR,            FAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirB,      File.WARIO_BAIR,            BAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirU,      File.WARIO_UAIR,            UAIR,                       -1)
    Character.edit_action_parameters(WARIO, Action.AttackAirD,      File.WARIO_DAIR,            DAIR,                       0)
    Character.edit_action_parameters(WARIO, Action.LandingAirX,     File.WARIO_LANDING,         -1,                         -1)
    Character.edit_action_parameters(WARIO, Action.LandingAirU,     File.WARIO_LANDING_U,       LANDING_AIR_U,              -1)
    Character.edit_action_parameters(WARIO, 0xDD,                   File.WARIO_ENTRY_R,         ENTRY,                      0x40000000)
    Character.edit_action_parameters(WARIO, 0xDE,                   File.WARIO_ENTRY_L,         ENTRY,                      0x40000000)
    Character.edit_action_parameters(WARIO, 0xDF,                   File.WARIO_NSP_GROUND,      NSP_GROUND,                 -1)
    Character.edit_action_parameters(WARIO, 0xE0,                   File.WARIO_NSP_AIR,         NSP_AIR,                    -1)
    Character.edit_action_parameters(WARIO, 0xE1,                   File.WARIO_USP,             USP,                        0)
    Character.edit_action_parameters(WARIO, 0xE2,                   File.WARIO_DSP_LANDING,     DSP_LANDING,                0)
    Character.edit_action_parameters(WARIO, 0xE3,                   File.WARIO_DSP_GROUND,      DSP_GROUND,                 0)
    Character.edit_action_parameters(WARIO, 0xE4,                   File.WARIO_DSP_AIR,         DSP_AIR,                    0)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(WARIO, 0xDF,              -1,             0x800D94C4,                 WarioNSP.ground_move_,          WarioNSP.ground_physics_,       WarioNSP.ground_collision_)
    Character.edit_action(WARIO, 0xE0,              -1,             0x800D94E8,                 WarioNSP.air_move_,             WarioNSP.air_physics_,          WarioNSP.air_collision_)
    Character.edit_action(WARIO, 0xE1,              -1,             WarioUSP.main_,             WarioUSP.change_direction_,     WarioUSP.physics_,              WarioUSP.collision_)
    Character.edit_action(WARIO, 0xE2,              0x1E,           0x800D94C4,                 0,                              0x800D8BB4,                     0x800DDEE8)
    Character.edit_action(WARIO, 0xE3,              -1,             0x800D94E8,                 WarioDSP.ground_move_,          WarioDSP.physics_,              WarioDSP.collision_)
    Character.edit_action(WARIO, 0xE4,              -1,             0x800D94E8,                 WarioDSP.air_move_,             WarioDSP.physics_,              WarioDSP.collision_)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(WARIO,  NSP_Recoil_Ground,  -1,             File.WARIO_NSP_RECOIL_G,    NSP_RECOIL,                 0)
    Character.add_new_action_params(WARIO,  NSP_Recoil_Air,     -1,             File.WARIO_NSP_RECOIL_A,    NSP_RECOIL,                 0)

    // Add Actions                  // Action Name      // Base Action  //Parameters                        // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.add_new_action(WARIO, NSP_Recoil_Ground,  -1,             ActionParams.NSP_Recoil_Ground,     0x12,           0x800D94C4,                 0,                              0x800D8BB4,                     WarioNSP.recoil_ground_collision_)
    Character.add_new_action(WARIO, NSP_Recoil_Air,     -1,             ActionParams.NSP_Recoil_Air,        0x12,           0x800D94E8,                 WarioNSP.recoil_move_,          WarioNSP.recoil_physics_,       WarioNSP.recoil_air_collision_)

    // Modify Menu Action Parameters                // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(WARIO,    0x0,                File.WARIO_IDLE,            IDLE,                       -1)
    Character.edit_menu_action_parameters(WARIO,    0x1,                File.WARIO_VICTORY_1,       VICTORY_1,                  0)
    Character.edit_menu_action_parameters(WARIO,    0x2,                File.WARIO_VICTORY_2,       VICTORY_2,                  0)
    Character.edit_menu_action_parameters(WARIO,    0x3,                File.WARIO_VICTORY_3,       VICTORY_3,                  0)
    Character.edit_menu_action_parameters(WARIO,    0x4,                File.WARIO_VICTORY_3,       SELECT,                     0)
    Character.edit_menu_action_parameters(WARIO,    0x5,                File.WARIO_CLAP,            CLAPPING,                   0)
    Character.edit_menu_action_parameters(WARIO,    0xD,                File.WARIO_POSE_1P,         POSE_1P,                    -1)
    Character.edit_menu_action_parameters(WARIO,    0xE,                File.WARIO_1P_CPU_POSE,     0x80000000,                    -1)

    Character.table_patch_start(ground_nsp, Character.id.WARIO, 0x4)
    dw      WarioNSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.WARIO, 0x4)
    dw      WarioNSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.WARIO, 0x4)
    dw      WarioUSP.initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.WARIO, 0x4)
    dw      WarioUSP.initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.WARIO, 0x4)
    dw      WarioDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.WARIO, 0x4)
    dw      WarioDSP.air_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.WARIO, 0x4)
    float32 1.4
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.WARIO, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.WARIO, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()

    Character.table_patch_start(variants, Character.id.WARIO, 0x4)
    db      Character.id.NONE
    db      Character.id.NWARIO // set as POLYGON variant for WARIO
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    Character.table_patch_start(variant_original, Character.id.NWARIO, 0x4)
    dw      Character.id.WARIO // set Wario as original character (not Mario, who NWARIO is a clone of)
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.WARIO, 0x2)
    dh 0x303
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.WARIO, 0, 1, 2, 3, 1, 2, 4)
    Teams.add_team_costume(YELLOW, DEDEDE, 0x0)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(WARIO, YELLOW, BLUE, TURQUOISE, PINK, LIME, WHITE, NA, NA)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.WARIO, 0xC)
    dw Character.kirby_inhale_struct.star_damage.YOSHI
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.WARIO, 0xC)
    dh 0xF
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.WARIO, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

	// Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.WARIO, 0x4)
    dw    	AI.LONG_RANGE.ROUTINE.NONE
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  6,   37,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  26,  63,  -230, 230, -54, 406)  // copied Yoshi dspa coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  26,  63,  630, 1085, -25, 1755) // copied Yoshi dspg coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  22,  28,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  5,   12,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, BAIR,   -1,  10,  29,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  12,  25,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  10,  11,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,   6,   -1, -1, -1, -1) // todo: check range
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  5,   8,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  5,   32,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  11,  36,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  11,  36,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  8,   29,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  6,   41,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  6,   41,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  14,  19,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  7,   20,  -1, -1, -1, -1)

    // @ Description
    // Wario's extra actions
    scope Action {
        //constant Jab3(0x0DC)
        constant Appear1(0x0DD)
        constant Appear2(0x0DE)
        constant BodySlam(0x0DF)
        constant BodySlamAir(0x0E0)
        constant Corkscrew(0x0E1)
        constant GroundPoundLanding(0x0E2)
        constant GroundPound(0x0E3)
        constant GroundPoundAir(0x0E4)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("Appear1")
        //string_0x0DE:; String.insert("Appear2")
        string_0x0DF:; String.insert("BodySlam")
        string_0x0E0:; String.insert("BodySlamAir")
        string_0x0E1:; String.insert("Corkscrew")
        string_0x0E2:; String.insert("GroundPoundLanding")
        string_0x0E3:; String.insert("GroundPound")
        string_0x0E4:; String.insert("GroundPoundAir")
        string_0x0E5:; String.insert("BodySlamRecoil")
        string_0x0E6:; String.insert("BodySlamRecoilAir")

        action_string_table:
        dw 0 //dw Action.COMMON.string_jab3
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DF
        dw string_0x0E0
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.WARIO, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.WARIO, 0x2)
    dh  0x00A0
    OS.patch_end()

    // @ Description
    // Subroutine which causes Wario's body slam to recoil on hit.
    // Runs when a hitbox makes contact.
    // Sets temp variable 1 to 0x1 and plays an FGM if connecting with a hurtbox or shield.
    scope body_slam_recoil_: {
        OS.patch_start(0x5DED0, 0x800E26D0)
        j       body_slam_recoil_
        nop
        _return:
        OS.patch_end()

        // a0 = player struct
        // a3 = hitbox contact type (0 = hurtbox, 1 = shield, 2 = don't disable? (unsafe), 3 = clang)
        // s0-s3 are safe
        lw      s0, 0x0008(a0)              // s0 = character id
        ori     s1, r0, Character.id.WARIO  // s1 = id.WARIO
        beq     s0, s1, _check_action_wario // if id = WARIO, check action
        nop
        ori     s1, r0, Character.id.SHEIK  // s1 = id.SHEIK
        beq     s0, s1, _check_action_sheik // if id = SHEIK, check action
        ori     s1, r0, Character.id.BANJO  // s1 = id.SHEIK
        beq     s0, s1, _check_action_banjo // if id = banjo, check action
        ori     s1, r0, Character.id.EBI    // s1 = id.EBI
        beq     s0, s1, _check_action_ebi   // if id = EBI, check action
        ori     s1, r0, Character.id.KIRBY  // s1 = id.KIRBY
        beq     s0, s1, _check_action_kirby // if id = KIRBY, check action
        ori     s1, r0, Character.id.JKIRBY // s1 = id.JKIRBY
        bne     s0, s1, _end                // if id != JKIRBY, skip
        nop

        _check_action_kirby:
        lw      s0, 0x0024(a0)              // s0 = current action
        ori     s1, r0, Kirby.Action.EBI_NSP_Ground_End   // s1 = action id: EBI_NSPEND
        beq     s0, s1, _food_check_type    // branch if current action = down special attack
        ori     s1, r0, Kirby.Action.EBI_NSP_Air_End// s1 = action id: EBI_NSPENDAIR
        beq     s0, s1, _food_check_type    // branch if current action = down special attack
        lli     s1, Kirby.Action.WARIO_NSP_Ground
        beq     s0, s1, _check_type         // branch if current action = ground neutral special
        lli     s1, Kirby.Action.WARIO_NSP_Air
        bne     s0, s1, _end                // skip if current action != aerial neutral special
        nop
        b       _check_type                 // check contact type
        nop


        _check_action_sheik:
        lw      s0, 0x0024(a0)              // s0 = current action
        ori     s1, r0, Sheik.Action.DSP_ATTACK // s1 = action id: DSP_ATTACK
        beq     s0, s1, _recoil             // branch if current action = down special attack
        nop
        beq     r0, r0, _end                // if any other attack, function normally
        nop

        _check_action_banjo:
        lw      s0, 0x0024(a0)              // s0 = current action
        ori     s1, r0, Banjo.Action.USPAttack
        beq     s0, s1, _recoil             // branch if current action = up special attack
        nop
        beq     r0, r0, _end                // if any other attack, function normally
        nop


        _check_action_ebi:
        lw      s0, 0x0024(a0)              // s0 = current action
        ori     s1, r0, Ebi.Action.NSPEND   // s1 = action id: NSP_END
        beq     s0, s1, _food_check_type    // branch if current action = down special attack
        ori     s1, r0, Ebi.Action.NSPENDAIR// s1 = action id: NSP_END
        beq     s0, s1, _food_check_type    // branch if current action = down special attack
        nop
        b       _end                // if any other attack, function normally
        nop

        _check_action_wario:
        lw      s0, 0x0024(a0)              // s0 = current action
        ori     s1, r0, 0x00DF              // s1 = action id: NSP_GROUND
        beq     s0, s1, _check_type         // branch if current action = ground neutral special
        ori     s1, r0, 0x00E0              // s1 = action id: NSP_AIR
        bne     s0, s1, _end                // skip if current action != aerial neutral special
        nop

        _check_type:
        beq     a3, r0, _recoil             // branch if contact type = hurtbox
        nop
        ori     s2, r0, 0x0001              // ~
        beq     a3, s2, _recoil             // branch if contact type = shield
        nop

        _clang:
        // when clanging, Wario should recoil if his invincibility is not active
        ori     s2, r0, 0x0003              // ~
        bne     a3, s2, _end                // skip if contact type != clang
        nop
        lw      s0, 0x05BC(a0)              // s0 = shoulder hurtbox vulnerability

        lw      s1, 0x0008(a0)              // s1 = character id
        lli     s2, Character.id.KIRBY      // s2 = id.KIRBY
        beql    s1, s2, pc() + 8            // if Kirby, load alternate shoulder hurtbox offset
        lw      s0, 0x0640(a0)              // s0 = shoulder hurtbox vulnerability
        lli     s2, Character.id.JKIRBY     // s2 = id.JKIRBY
        beql    s1, s2, pc() + 8            // if J Kirby, load alternate shoulder hurtbox offset
        lw      s0, 0x0640(a0)              // s0 = shoulder hurtbox vulnerability

        ori     s1, r0, 0x0002              // at = 0x2 (invincible)
        beq     s0, s1, _end                // skip if shoulder hurtbox is invincible
        nop

        _recoil:
        ori     s2, r0, 0x0001              // ~
        b       _end
        sw      s2, 0x017C(a0)              // temp variable 1 = 0x1 (recoil flag = true)

        _food_check_type:
        bne     a3, r0, _end             // branch if contact type = hurtbox
        nop

        _create_food:
        OS.save_registers()
        addiu   sp, sp, -0x0060             // allocate stack space (0x8016EA78 is unsafe)
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        sw      a0, 0x001C(sp)              // a1 = player struct
        sw      r0, 0x0000(a1)              // ~
        sw      r0, 0x0004(a1)              // ~
        sw      r0, 0x0008(a1)              // clear space for x/y/z coordinates
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        lw      a0, 0x095C(a0)              // a0 = joint
        or      a0, r0, r0                  // a0 = owner (none)
        addiu   a2, sp, 0x0020              // a2 = coordinates to create item at
        addiu   a3, sp, 0x002C              // a3 = address of velocity floats
        lli     t3, 0x0001                  // t3 = 1
        sw      t3, 0x0010(sp)              // 0x0010(sp) = 1
        sw      r0, 0x0008(a2)              // initial z position = 0
        sw      r0, 0x0000(a3)              // initial x velocity = 0
        lui     t3, 0x41F0                  // ~
        sw      t3, 0x0004(a3)              // initial y velocity = 30
        jal     Global.get_random_int_safe_
        addiu   a0, r0, 100
        beqz    v0, _create_food_continue
        lli     a1, Item.Tomato.id          // 1 in 100 chance of tomato
        lli     a1, Item.Dango.id           // 99 in 100 chance of Dango item (heals 10%)
        _create_food_continue:
        jal     0x8016EA78                  // create item
        sw      r0, 0x0008(a3)              // initial z velocity = 0
        beqz    v0, _end_food               // branch if no item object was created
        addiu   sp, sp, 0x0060              // deallocate stack space

        // prevent spawned item from clipping into walls
        lw      a1, 0xFFBC (sp)             // a1 = player struct
        addiu   a2, a1, 0x0078              // a2 = unknown
        lw      a1, 0x0078(a1)              // a1 = player x/y/z coordinates
        jal     0x800DF058                  // check clipping
        or      a0, v0, r0                  // a0 = item object

        FGM.play(0x524)                     // audience laugh

        _end_food:
        OS.restore_registers()

        _end:
        or      s0, a2, r0                  // original line 1
        or      s1, a3, r0                  // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Routine used for body_slam_clang_x_ patches
    // The hook for these patches replaces these two lines:
    // addiu    {r1}, {r2}, 0xFFF6
    // slt      at, {r1}, {r3}
    macro body_slam_clang_patch(r1, r2, r3) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0008(sp)              // store ra
        jal     check_body_slam_invincible_ // check invincibility
        sw      v0, 0x000C(sp)              // store v0
        beqz    v0, _end                    // skip if shoulder hurtbox isn't invincible
        nop

        lw      ra, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // load v0, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        or      at, r0, r0                  // at = 0 (beats other hitbox)
        j       _return
        nop

        _end:
        lw      ra, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // load v0, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        addiu   {r1}, {r2}, 0xFFF6          // original line 1
        slt     at, {r1}, {r3}              // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Subroutine which checks if Wario is currently in the invincible stage of body slam.
    // @ Arguments
    // a0 - player struct
    // @ Returns
    // v0 - OS.TRUE, OS.FALSE
    scope check_body_slam_invincible_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // store t0, t1, at

        lw      t0, 0x0008(a0)              // t0 = character id
        ori     at, r0, Character.id.WARIO  // at = id.WARIO
        beq     t0, at, _check_action_wario // if id = WARIO, check action
        ori     at, r0, Character.id.KIRBY  // at = id.KIRBY
        beq     t0, at, _check_action_kirby // if id = KIRBY, check action
        ori     at, r0, Character.id.JKIRBY // at = id.JKIRBY
        bne     t0, at, _end                // if id != JKIRBY, skip
        lli     v0, OS.FALSE                // v0 = FALSE

        _check_action_kirby:
        lw      t0, 0x0024(a0)              // t0 = current action
        lli     at, Kirby.Action.WARIO_NSP_Ground
        beq     t0, at, _body_slam          // branch if current action = ground neutral special
        lli     at, Kirby.Action.WARIO_NSP_Air
        bne     t0, at, _end                // skip if current action != aerial neutral special
        lli     v0, OS.FALSE                // v0 = FALSE
        b       _body_slam                  // current action is body slam
        nop

        _check_action_wario:
        lw      t0, 0x0024(a0)              // t0 = current action
        ori     at, r0, 0x00DF              // at = action id: NSP_GROUND
        beq     t0, at, _body_slam          // branch if current action = ground neutral special
        ori     at, r0, 0x00E0              // at = action id: NSP_AIR
        bne     t0, at, _end                // skip if current action != aerial neutral special
        lli     v0, OS.FALSE                // v0 = FALSE

        _body_slam:
        lw      t0, 0x05BC(a0)              // t0 = shoulder hurtbox vulnerability

        lw      t1, 0x0008(a0)              // t1 = character id
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beql    t1, at, pc() + 8            // if Kirby, load alternate shoulder hurtbox offset
        lw      t0, 0x0640(a0)              // t0 = shoulder hurtbox vulnerability
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        beql    t1, at, pc() + 8            // if J Kirby, load alternate shoulder hurtbox offset
        lw      t0, 0x0640(a0)              // t0 = shoulder hurtbox vulnerability

        ori     at, r0, 0x0002              // at = 0x2 (invincible)
        bne     t0, at, _end                // skip if shoulder hurtbox isn't invincible
        lli     v0, OS.FALSE                // v0 = FALSE

        // if we reach this point, Wario is currently in the invincible stage of Body Slam, so return TRUE
        lli     v0, OS.TRUE                 // v0 = TRUE

        _end:
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // load t0, t1, at
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }



    // @ Description
    // Forces Wario's body slam to beat any other hitbox on clang when the shoulder is invincible. (1/4)
    // This patch is for check 1/2 in the hitbox vs hitbox clang function.
    scope body_slam_clang_1_: {
        OS.patch_start(0x5E14C, 0x800E294C)
        j       body_slam_clang_1_
        nop
        _return:
        OS.patch_end()
        body_slam_clang_patch(t8, t7, t6)
    }

    // @ Description
    // Forces Wario's body slam to beat any other hitbox on clang when the shoulder is invincible. (2/4)
    // This patch is for check 2/2 in the hitbox vs hitbox clang function.
    scope body_slam_clang_2_: {
        OS.patch_start(0x5E1EC, 0x800E29EC)
        j       body_slam_clang_2_
        nop
        _return:
        OS.patch_end()
        body_slam_clang_patch(t0, t9, t8)
    }

    // @ Description
    // Forces Wario's body slam to beat any other hitbox on clang when the shoulder is invincible. (3/4)
    // This patch is for the hitbox vs projectile clang function.
    scope body_slam_clang_3_: {
        OS.patch_start(0x5E750, 0x800E2F50)
        j       body_slam_clang_3_
        nop
        _return:
        OS.patch_end()
        body_slam_clang_patch(t6, v1, s1)
    }

    // @ Description
    // Forces Wario's body slam to beat any other hitbox on clang when the shoulder is invincible. (4/4)
    // This patch is for the an unknown clang function. The function is almost identical to the
    // hitbox vs projectile clang function but I'm not sure what it is actually for.
    // TODO: figure out what this clang function is used for (800E35BC)
    scope body_slam_clang_4_: {
        OS.patch_start(0x5EE08, 0x800E2F50)
        j       body_slam_clang_4_
        nop
        _return:
        OS.patch_end()
        body_slam_clang_patch(t6, v1, s1)
    }

    // @ Description
    // When an opponent is grabbed by Wario, they will be put into the ThrownDK action (0xB8)
    // rather than the usual CapturePulled action (0xAB)
    // Also used by Mad Piano.
    scope capture_action_fix_: {
        OS.patch_start(0xC534C, 0x8014A90C)
        j       capture_action_fix_
        nop
        _return:
        OS.patch_end()

        // v0 = grabbing player struct
        ori     a1, r0, Character.id.WARIO  // a1 = id.WARIO
        lw      a2, 0x0008(v0)              // a2 = grabbing player character id
        beq     a1, a2, _wario              // if id = WARIO, load alternate action
        ori     a1, r0, Action.CapturePulled// original line 1
        ori     a1, r0, Character.id.PIANO  // a1 = id.PIANO
        bne     a1, a2, _end                // if id != PIANO, skip
        ori     a1, r0, Action.CapturePulled// original line 1

        _wario:
        // if id = WARIO or PIANO
        ori     a1, r0, Action.ThrownDK     // captured player action = ThrownDK

        _end:
        addiu   a2, r0, 0x0000              // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Attempts to fix the position of the grabbed character on frame 1 of Wario's GrabPull action.
    // Not perfect, but a big improvement.
    // Also used by Mad Piano.
    scope capture_position_fix_: {
        OS.patch_start(0xC539C, 0x8014A95C)
        j       capture_position_fix_
        nop
        _return:
        OS.patch_end()

        lw      a0, 0x0044(sp)              // ~
        lw      a0, 0x0084(a0)              // v0 = grabbing player struct
        lw      a0, 0x0008(a0)              // a0 = grabbing player character id
        ori     a1, r0, Character.id.PIANO  // a1 = id.PIANO
        beq     a0, a1, _wario              // branch if id = PIANO
        ori     a1, r0, Character.id.WARIO  // a1 = id.WARIO
        beq     a0, a1, _wario              // branch if id = WARIO
        nop
        // if id != WARIO
        jal     0x8014A6B4                  // original line 1
        or      a0, s1, r0                  // original line 2
        j       _return                     // return
        nop

        _wario:
        // Usually, 8014A6B4 is used to set the captured player's position on the first frame of
        // being grabbed, with 8014AB64 being used on subsequent frames.
        // If the grabbing character is Wario or Piano, 8014AB64 will be used on the first frame instead.
        jal     0x8014AB64                  // modified original line 1
        or      a0, s1, r0                  // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Modifies the subroutine which handles mashing/breaking out of the ThrownDK action.
    // Skips if the throwing character is Wario.
    // Also used by Mad Piano, and makes Mad Piano's captured opponent invisible.
    scope capture_break_fix_: {
        OS.patch_start(0xC8F14, 0x8014E4D4)
        j       capture_break_fix_
        nop
        _return:
        OS.patch_end()

        lw      a2, 0x0084(a0)              // a2 = captured player struct
        lw      a2, 0x0844(a2)              // a2 = player.entity_captured_by
        lw      a2, 0x0084(a2)              // a2 = grabbing player struct
        lw      t7, 0x0008(a2)              // a2 = grabbing player character id
        ori     a3, r0, Character.id.PIANO  // a3 = id.PIANO
        beq     t7, a3, _piano              // branch if id = PIANO
        ori     a3, r0, Character.id.MARINA // a3 = id.MARINA
        beq     t7, a3, _marina             // branch if id = MARINA
        ori     a3, r0, Character.id.WARIO  // a3 = id.WARIO
        beq     t7, a3, _end                // branch if id = WARIO
        nop
        // if id != WARIO
        addiu   sp, sp, 0xFFD8              // original line 1
        sw      ra, 0x0014(sp)              // original line 2
        j       _return                     // return (and continue subroutine)
        nop

        _marina:
        lli     a3, Action.ThrowF           // a3 = ThrowF
        lw      t7, 0x0024(a2)              // t7 = grabbing player action
        beq     a3, t7, _end                // end if action = ThrowF
        nop
        addiu   sp, sp, 0xFFD8              // original line 1
        j       _return                     // return (and continue subroutine)
        sw      ra, 0x0014(sp)              // original line 2


        _piano:
        lli     a3, Action.GrabWait         // a3 = GrabWait
        lw      t7, 0x0024(a2)              // t7 = grabbing player action
        bne     a3, t7, _end                // skip if action != GrabWait
        lw      a2, 0x0084(a0)              // a2 = captured player struct
        // if we're here, then the captured player is being held by Mad Piano's grab, so make them invisible.
        lbu     t7, 0x018D(a2)              // t7 = bit field
        ori     t7, t7, 0x0001              // enable bitflag for invisibility
        sb      t7, 0x018D(a2)              // update bit field

        _end:
        jr      ra                          // end subroutine
        nop
    }

    // @ Description
    // Plays an alternate voice FGM for Wario's neutral special.
    scope alternate_voice_: {
        OS.patch_start(0x638FC, 0x800E80FC)
        j       alternate_voice_
        nop
        _return:
        OS.patch_end()

        constant L_HELD(0x0020)             // bitmask for the button L
        // a0 = player struct
        // a1 = fgm id
        sw      a1, 0x001C(sp)              // original line 1
        sw      a2, 0x0018(sp)              // original line 2
        ori     a2, r0, 0x2FB               // a2 = wario neutral special voice FGM id
        bne     a1, a2, _end                // skip if fgm != wario neutral special voice
        nop

        _check_alt_voice:
        lh      a2, 0x01BC(a0)              // a2 = buttons_held
        andi    a2, a2, L_HELD              // a2 = 0x0020 if (L_HELD); else a2 = 0
        beq     a2, r0, _end                // skip if !(L_HELD)
        nop
        lw      a2, 0x0ADC(a0)              // a2 = flag (resets to FALSE on death/character load)
        bnez    a2, _end                    // skip if flag != FALSE
        nop

        _set_alt_fgm:
        ori     a1, r0, 0x300               // a1 = alternate FGM id
        sw      a1, 0x001C(sp)              // update FGM id in stack
        ori     a2, r0, OS.TRUE             // ~
        sw      a2, 0x0ADC(a0)              // set flag to TRUE (resets to FALSE on death/character load)

        _end:
        lw      a1, 0x001C(sp)              // load a1
        j       _return                     // return
        lw      a2, 0x0018(sp)              // load a2
    }
}
