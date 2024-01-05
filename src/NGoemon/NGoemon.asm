// NGoemon.asm

// This file contains file inclusions, action edits, and assembly for NGoemon.

scope NGoemon {

    // Modify Action Parameters                 // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NGOEMON,    Action.Entry,           File.GOEMON_IDLE,           Goemon.ENTRY,                       -1)
    Character.edit_action_parameters(NGOEMON,    0x006,                  File.GOEMON_IDLE,           Goemon.IDLE,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.Idle,            File.GOEMON_IDLE,           Goemon.IDLE,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.ReviveWait,      File.GOEMON_IDLE,           Goemon.IDLE,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.Crouch,          File.GOEMON_CROUCH_BEGIN,   -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.CrouchIdle,      File.GOEMON_CROUCH_IDLE,    -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.CrouchEnd,       File.GOEMON_CROUCH_END,     -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.JumpF,           File.GOEMON_JUMP_F,         Goemon.JUMP_1,                     -1)
    Character.edit_action_parameters(NGOEMON,    Action.JumpB,           File.GOEMON_JUMP_B,         Goemon.JUMP_1,                     -1)
    Character.edit_action_parameters(NGOEMON,    Action.JumpAerialF,     File.GOEMON_JUMP_AIR_F,     Goemon.JUMP_2,                     -1)
    Character.edit_action_parameters(NGOEMON,    Action.JumpAerialB,     File.GOEMON_JUMP_AIR_B,     Goemon.JUMP_2,                     -1)
    Character.edit_action_parameters(NGOEMON,    Action.Fall,            File.GOEMON_FALL,           -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.FallAerial,      File.GOEMON_FALL_AERIAL,    -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.FallSpecial,     File.GOEMON_SFALL,          -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.Teeter,          File.GOEMON_TEETER,         Goemon.TEETER,                     -1)
    Character.edit_action_parameters(NGOEMON,    Action.TeeterStart,     File.GOEMON_TEETER_START,   -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.TechF,           -1,                         Goemon.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NGOEMON,    Action.TechB,           -1,                         Goemon.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NGOEMON,    Action.Tech,            -1,                         Goemon.TECH,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.ShieldBreak,     -1,                         Goemon.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NGOEMON,    Action.Stun,            File.GOEMON_STUN,           Goemon.STUN,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.Sleep,           File.GOEMON_STUN,           Goemon.ASLEEP,                     -1)
    Character.edit_action_parameters(NGOEMON,    Action.Taunt,           File.GOEMON_TAUNT,          Goemon.TAUNT,                      -1)
    Character.edit_action_parameters(NGOEMON,    Action.Dash,            File.GOEMON_DASH,           -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.Run,             File.GOEMON_RUN,            -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.RunBrake,        File.GOEMON_RUN_BRAKE,      -1,                         -1)
    //Character.edit_action_parameters(GOEMON,    Action.Turn,            File.GOEMON_TURN,           -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.TurnRun,         File.GOEMON_TURN_RUN,       -1,                         -1)

    Character.edit_action_parameters(NGOEMON,    Action.JumpSquat,       File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.ShieldJumpSquat, File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.LandingLight,    File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.LandingHeavy,    File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.LandingSpecial,  File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.LandingAirB,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.LandingAirU,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.LandingAirD,     File.GOEMON_JUMPSQUAT,      -1,                         0)
    Character.edit_action_parameters(NGOEMON,    Action.LandingAirX,     File.GOEMON_JUMPSQUAT,      -1,                         0)

    Character.edit_action_parameters(NGOEMON, Action.EnterPipe,              File.GOEMON_ENTER_PIPE,             -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.ExitPipe,               File.GOEMON_EXIT_PIPE,              -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffWait,              File.GOEMON_CLIFF_WAIT,             -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffClimbQuick2,       File.GOEMON_CLIFF_CLIMB_QUICK_2,    -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffClimbSlow2,        File.GOEMON_CLIFF_CLIMB_SLOW_2,     -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffAttackQuick1,      File.GOEMON_CLIFF_ATTACK_QUICK_1,   -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffAttackQuick2,      File.GOEMON_CLIFF_ATTACK_QUICK_2,   Goemon.CLIFF_ATTACK_F,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffAttackSlow2,       File.GOEMON_CLIFF_ATTACK_SLOW_2,    Goemon.CLIFF_ATTACK_S,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffEscapeQuick2,      File.GOEMON_CLIFF_ESCAPE_QUICK_2,   -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffEscapeSlow1,       File.GOEMON_CLIFF_ESCAPE_SLOW_1,    -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.CliffEscapeSlow2,       File.GOEMON_CLIFF_ESCAPE_SLOW_2,    -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.DownAttackD,            File.GOEMON_DOWN_ATTACK_D,          Goemon.DOWN_ATTACK_D,  -1)
    Character.edit_action_parameters(NGOEMON, Action.DownAttackU,            File.GOEMON_DOWN_ATTACK_U,          Goemon.DOWN_ATTACK_U,  -1)
    Character.edit_action_parameters(NGOEMON, Action.DownStandD,             File.GOEMON_DOWN_STAND_D,           -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.DownStandU,             File.GOEMON_DOWN_STAND_U,           -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.DownForwardD,           File.GOEMON_DOWN_FORWARD_D,         -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.DownForwardU,           File.GOEMON_DOWN_FORWARD_U,         -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.DownBackD,              File.GOEMON_DOWN_BACK_D,            -1,             -1)
    Character.edit_action_parameters(NGOEMON, Action.DownBackU,              File.GOEMON_DOWN_BACK_U,            -1,             -1)


    Character.edit_action_parameters(NGOEMON,    Action.EggLay,          File.GOEMON_IDLE,           -1,                         -1)

    Character.edit_action_parameters(NGOEMON,    Action.Jab1,            File.GOEMON_JAB1,           Goemon.JAB_1,                      -1)
    Character.edit_action_parameters(NGOEMON,    Action.Jab2,            File.GOEMON_JAB2,           Goemon.JAB_2,                      -1)
    Character.edit_action_parameters(NGOEMON,    Action.DashAttack,      File.GOEMON_DASH_ATTACK,    Goemon.DASH_ATTACK,                0x40000000)
    Character.edit_action_parameters(NGOEMON,    Action.FTiltHigh,       File.GOEMON_FTILT_HIGH,     Goemon.FTILT_HIGH,                 0x10000000)
    Character.edit_action_parameters(NGOEMON,    Action.FTilt,           File.GOEMON_FTILT,          Goemon.FTILT,                      0x10000000)
    Character.edit_action_parameters(NGOEMON,    Action.FTiltLow,        File.GOEMON_FTILT_LOW,      Goemon.FTILT_LOW,                  0x10000000)
    Character.edit_action_parameters(NGOEMON,    Action.UTilt,           File.GOEMON_UTILT,          Goemon.UTILT,                      0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.DTilt,           File.GOEMON_DTILT,          Goemon.DTILT,                      0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.FSmashHigh,      0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.FSmashMidHigh,   0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.FSmash,          File.GOEMON_FSMASH,         Goemon.FSMASH,                     0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.FSmashMidLow,    0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.FSmashLow,       0,                          0x80000000,                 0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.USmash,          File.GOEMON_USMASH,         Goemon.USMASH,                     0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.DSmash,          File.GOEMON_DSMASH,         Goemon.DSMASH,                     0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.AttackAirN,      File.GOEMON_NAIR,           Goemon.NAIR,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.AttackAirF,      File.GOEMON_FAIR,           Goemon.FAIR,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.AttackAirB,      File.GOEMON_BAIR,           Goemon.BAIR,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.AttackAirU,      File.GOEMON_UAIR,           Goemon.UAIR,                       -1)
    Character.edit_action_parameters(NGOEMON,    Action.AttackAirD,      File.GOEMON_DAIR,           Goemon.DAIR,                       0x00000000)
    Character.edit_action_parameters(NGOEMON,    Action.BatSmash,        -1,                         Goemon.BAT_SMASH,                  -1)
    Character.edit_action_parameters(NGOEMON,    Action.HeavyItemThrowF, -1,                         Goemon.HEAVY_ITEM_THROW_F,         -1)
    Character.edit_action_parameters(NGOEMON,    Action.HeavyItemThrowB, -1,                         Goemon.HEAVY_ITEM_THROW_B,         -1)
    Character.edit_action_parameters(NGOEMON,    Action.HeavyItemThrowSmashF, -1,                    Goemon.HEAVY_ITEM_THROW_SMASH_F,   -1)
    Character.edit_action_parameters(NGOEMON,    Action.HeavyItemThrowSmashB, -1,                    Goemon.HEAVY_ITEM_THROW_SMASH_B,   -1)
    Character.edit_action_parameters(NGOEMON,    Action.Grab,            File.GOEMON_GRAB,           Goemon.GRAB,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.GrabPull,        File.GOEMON_GRAB_PULL,      -1,                         -1)
    Character.edit_action_parameters(NGOEMON,    Action.ThrowF,          File.GOEMON_THROW_FORWARD,  Goemon.FTHROW,                     -1)
    Character.edit_action_parameters(NGOEMON,    Action.ThrowB,          File.GOEMON_THROW_BACKWARD, Goemon.BTHROW,                     -1)
    Character.edit_action_parameters(NGOEMON,    Goemon.Action.Jab3,            File.GOEMON_JAB3,           Goemon.JAB_3,                      -1)
    Character.edit_action_parameters(NGOEMON,    Goemon.Action.USP,             File.GOEMON_USP_LOOP,       Goemon.USP_IDLE,                    0)
    // Character.edit_action_parameters(GOEMON,    Action.USPTurn,         0x1FB,                      0x80000000,               0)
    Character.edit_action_parameters(NGOEMON,    Goemon.Action.USPAttack,       File.GOEMON_USP_ATTACK,     Goemon.USP_ATTACK,                  0)
    Character.edit_action_parameters(NGOEMON,    Goemon.Action.USPJump,         File.GOEMON_USP_JUMP,       Goemon.USP_JUMP,                    0)
    Character.edit_action_parameters(NGOEMON,    Goemon.Action.USPEscape,       File.GOEMON_USP_ESCAPE,     Goemon.USP_ESCAPE,                  0)
    Character.edit_action_parameters(NGOEMON,    Goemon.Action.Entry_R,         File.GOEMON_IDLE,          0x80000000,                 0)
    Character.edit_action_parameters(NGOEMON,    Goemon.Action.Entry_L,         File.GOEMON_IDLE,          0x80000000,                 0)
    Character.edit_action_parameters(NGOEMON,    Action.ShieldOn, 		File.GOEMON_SHIELD_ON,   	-1,                         -1)
	Character.edit_action_parameters(NGOEMON,    Action.ShieldOff, 		File.GOEMON_SHIELD_OFF,   	-1,                         -1)


    // Modify Actions             // Action             // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NGOEMON, Goemon.Action.USP,           0x11,           GoemonUSP.main_,                GoemonUSP.interrupt_,           GoemonUSP.physics_,             GoemonUSP.collision_)
    // Character.edit_action(NGOEMON, Goemon.Action.USPTurn,       0x11,           GoemonUSP.turn_main_,           GoemonUSP.interrupt_,           GoemonUSP.physics_,             GoemonUSP.collision_)
    Character.edit_action(NGOEMON, Goemon.Action.USPAttack,     0x11,           GoemonUSP.attack_main_,         0,                              GoemonUSP.physics_,             GoemonUSP.collision_)
    Character.edit_action(NGOEMON, Goemon.Action.USPJump,       0x11,           GoemonUSP.jump_main_,           0,                              GoemonUSP.jump_physics_,        GoemonUSP.collision_)
    Character.edit_action(NGOEMON, Goemon.Action.USPEscape,     0x11,           GoemonUSP.escape_main_,         0,                              0x800D9160,                     GoemonUSP.collision_)
    Character.edit_action(NGOEMON, Goemon.Action.Entry_R,           -1,            0x8013D994,                  0x00000000,                     0x00000000,                     0x00000000)
    Character.edit_action(NGOEMON, Goemon.Action.Entry_L,           -1,            0x8013D994,                  0x00000000,                     0x00000000,                     0x00000000)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(NGOEMON, DSPGround,          -1,             File.GOEMON_DSPG,           Goemon.DSP,                        0x1FF00000)
    Character.add_new_action_params(NGOEMON, DSPGroundPull,      -1,             File.GOEMON_DSP_PULL,       Goemon.DSP_PULL,                   0x5FF00000)
    Character.add_new_action_params(NGOEMON, DSPGAttack,         -1,             File.GOEMON_DSPG_ATTACK,    Goemon.DSP_ATTACK,                 0x00000000)
    Character.add_new_action_params(NGOEMON, DSPAir,             -1,             File.GOEMON_DSPA,           Goemon.DSP_AIR,                    0x1FF00000)
    Character.add_new_action_params(NGOEMON, DSPAirPull,         -1,             File.GOEMON_DSP_PULL,       Goemon.DSP_PULL,                   0x5FF00000)
    Character.add_new_action_params(NGOEMON, DSPAAttack,         -1,             File.GOEMON_DSPA_ATTACK,    Goemon.DSP_ATTACK,                 0x00000000)
    Character.add_new_action_params(NGOEMON, DSPEnd,             -1,             File.GOEMON_DSP_END,        0x80000000,                 0x00000000)
    Character.add_new_action_params(NGOEMON, NSP_Ground_Begin,   -1,             File.GOEMON_NSPG_BEGIN,     Goemon.NSP_BEGIN,                  0)
    Character.add_new_action_params(NGOEMON, NSP_Ground_Wait,    -1,             File.GOEMON_NSPG_IDLE,      Goemon.NSP_WAIT,                   0)
    Character.add_new_action_params(NGOEMON, NSP_Ground_Walk1,   -1,             File.GOEMON_NSPG_WALK_1,    Goemon.NSP_WAIT,                   0)
    Character.add_new_action_params(NGOEMON, NSP_Ground_Walk2,   -1,             File.GOEMON_NSPG_WALK_2,    Goemon.NSP_WAIT,                   0)
    Character.add_new_action_params(NGOEMON, NSP_Ground_BWalk1,  -1,             File.GOEMON_NSPG_BWALK_1,   Goemon.NSP_WAIT,                   0)
    Character.add_new_action_params(NGOEMON, NSP_Ground_BWalk2,  -1,             File.GOEMON_NSPG_BWALK_2,   Goemon.NSP_WAIT,                   0)
    Character.add_new_action_params(NGOEMON, NSP_Ground_End,     -1,             File.GOEMON_NSPG_END,       Goemon.NSP_END,                    0)
    Character.add_new_action_params(NGOEMON, NSP_Air_Begin,      -1,             File.GOEMON_NSPG_BEGIN,     Goemon.NSP_BEGIN,                  0)
    Character.add_new_action_params(NGOEMON, NSP_Air_Wait,       -1,             File.GOEMON_NSPG_IDLE,      Goemon.NSP_WAIT,                   0)
    Character.add_new_action_params(NGOEMON, NSP_Air_End,        -1,             File.GOEMON_NSPG_END,       Goemon.NSP_END,                    0)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(NGOEMON, NSP_Ground_Begin,  -1,             ActionParams.NSP_Ground_Begin,  0x12,           GoemonNSP.ground_begin_main_,   0,                              0x800D8BB4,                         GoemonNSP.ground_collision_)
    Character.add_new_action(NGOEMON, NSP_Ground_Wait,   -1,             ActionParams.NSP_Ground_Wait,   0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    0x800D8BB4,                         GoemonNSP.ground_collision_)
    Character.add_new_action(NGOEMON, NSP_Ground_Walk1,  -1,             ActionParams.NSP_Ground_Walk1,  0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     GoemonNSP.ground_collision_)
    Character.add_new_action(NGOEMON, NSP_Ground_Walk2,  -1,             ActionParams.NSP_Ground_Walk2,  0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_walk_physics_,     GoemonNSP.ground_collision_)
    Character.add_new_action(NGOEMON, NSP_Ground_BWalk1, -1,             ActionParams.NSP_Ground_BWalk1, 0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, GoemonNSP.ground_collision_)
    Character.add_new_action(NGOEMON, NSP_Ground_BWalk2, -1,             ActionParams.NSP_Ground_BWalk2, 0x12,           GoemonNSP.ground_wait_main_,    GoemonNSP.ground_interrupt_,    GoemonNSP.ground_back_walk_physics_, GoemonNSP.ground_collision_)
    Character.add_new_action(NGOEMON, NSP_Ground_End,    -1,             ActionParams.NSP_Ground_End,    0x12,           GoemonNSP.end_main_,            0,                              0x800D8BB4,                         GoemonNSP.ground_collision_)
    Character.add_new_action(NGOEMON, NSP_Air_Begin,     -1,             ActionParams.NSP_Air_Begin,     0x12,           GoemonNSP.air_begin_main_,      0,                              GoemonNSP.air_physics_,             GoemonNSP.air_collision_)
    Character.add_new_action(NGOEMON, NSP_Air_Wait,      -1,             ActionParams.NSP_Air_Wait,      0x12,           GoemonNSP.air_wait_main_,       0,                              GoemonNSP.air_physics_,             GoemonNSP.air_collision_)
    Character.add_new_action(NGOEMON, NSP_Air_End,       -1,             ActionParams.NSP_Air_End,       0x12,           GoemonNSP.end_main_,            0,                              GoemonNSP.air_physics_,             GoemonNSP.air_collision_)
    Character.add_new_action(NGOEMON, DSPGround,         -1,             ActionParams.DSPGround,         0x1E,           GoemonDSP.main_,                0,                              0x800D8BB4,                         GoemonDSP.ground_collision_)
    Character.add_new_action(NGOEMON, DSPGroundPull,     -1,             ActionParams.DSPGroundPull,     0x1E,           GoemonDSP.pull_main_,           0,                              0x800D8C14,                         GoemonDSP.shared_ground_collision_)
    Character.add_new_action(NGOEMON, DSPGroundWallPull, -1,             ActionParams.DSPGroundPull,     0x1E,           GoemonDSP.wall_pull_main_,      0,                              0x800D8C14,                         GoemonDSP.shared_ground_collision_)
    Character.add_new_action(NGOEMON, DSPGAttack,         -1,            ActionParams.DSPGAttack,        0x1E,           0x800D94C4,                     0,                              0x800D8BB4,                         GoemonDSP.shared_ground_collision_)
    Character.add_new_action(NGOEMON, DSPAir,            -1,             ActionParams.DSPAir,            0x1E,           GoemonDSP.main_,                0,                              0x800D90E0,                         GoemonDSP.air_collision_)
    Character.add_new_action(NGOEMON, DSPAirPull,        -1,             ActionParams.DSPAirPull,        0x1E,           GoemonDSP.pull_main_,           0,                              0x800D93E4,                         GoemonDSP.shared_air_collision_)
    Character.add_new_action(NGOEMON, DSPAirWallPull,    -1,             ActionParams.DSPAirPull,        0x1E,           GoemonDSP.wall_pull_main_,      0,                              0x800D93E4,                         GoemonDSP.shared_air_collision_)
    Character.add_new_action(NGOEMON, DSPAAttack,         -1,            ActionParams.DSPAAttack,        0x1E,           0x800D94E8,                     0,                              0x800D91EC,                         GoemonDSP.shared_air_collision_)
    Character.add_new_action(NGOEMON, DSPEnd,            -1,             ActionParams.DSPEnd,            0x1E,           0x800D94E8,                     0,                              0x800D9160,                         0x800DE99C)

    // Modify Menu Action Parameters                    // Action       // Animation                    // Moveset Data    // Flags
    Character.edit_menu_action_parameters(NGOEMON,       0x0,            File.GOEMON_IDLE,               Goemon.IDLE,           -1)
    Character.edit_menu_action_parameters(NGOEMON,       0x1,            File.GOEMON_CSS,                Goemon.CSS,            -1)
    Character.edit_menu_action_parameters(NGOEMON,       0x2,            File.GOEMON_VICTORY_2,          Goemon.VICTORY_2,      -1)
    Character.edit_menu_action_parameters(NGOEMON,       0x3,            File.GOEMON_VICTORY_3,          Goemon.SUDDEN_IMPACT,  -1)
    Character.edit_menu_action_parameters(NGOEMON,       0x4,            File.GOEMON_CSS,                Goemon.CSS,            -1)
    Character.edit_menu_action_parameters(NGOEMON,       0x5,            File.GOEMON_CLAP,                -1,            -1)
    Character.edit_menu_action_parameters(NGOEMON,       0xD,            File.GOEMON_1P_POSE,            Goemon.ONEP,           -1)
    Character.edit_menu_action_parameters(NGOEMON,       0xE,            File.GOEMON_1P_CPU,             Goemon.CPU,            -1)
    Character.edit_menu_action_parameters(NGOEMON,       0xA,            File.GOEMON_PUPPET_UP,          -1,             -1)

    Character.table_patch_start(ground_nsp, Character.id.NGOEMON, 0x4)
    dw      GoemonNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.NGOEMON, 0x4)
    dw      GoemonNSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.NGOEMON, 0x4)
    dw      GoemonUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.NGOEMON, 0x4)
    dw      GoemonUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.NGOEMON, 0x4)
    dw      GoemonDSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.NGOEMON, 0x4)
    dw      GoemonDSP.air_initial_
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NGOEMON, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.NGOEMON, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()
    
    // Set action strings
    Character.table_patch_start(action_string, Character.id.NGOEMON, 0x4)
    dw  Goemon.Action.action_string_table
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NGOEMON, 0x4)
    dw      Goemon.CPU_ATTACKS
    OS.patch_end()

    // Handles common things for Polygons
    Character.polygon_setup(NGOEMON, GOEMON)


}
