// NConker.asm

// This file contains file inclusions, action edits, and assembly for NConker.

scope NConker {
    

    // Modify Action Parameters             // Action                   // Animation                    // Moveset Data             // Flags
    Character.edit_action_parameters(NCONKER, Action.Teeter,             -1,                             Conker.TEETERING,                  -1)
    Character.edit_action_parameters(NCONKER, Action.ShieldBreak,        -1,                             Conker.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NCONKER, Action.ShieldOn,           File.CONKER_SHIELD_ON,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ShieldOff,          File.CONKER_SHIELD_OFF,         -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ShieldDrop,         File.CONKER_SHIELD_DROP,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Pass,               File.CONKER_SHIELD_DROP,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Stun,               File.CONKER_STUN,               Conker.STUN,                       -1)
    Character.edit_action_parameters(NCONKER, Action.Sleep,              File.CONKER_STUN,               Conker.ASLEEP,                     -1)
    Character.edit_action_parameters(NCONKER, Action.DamageFlyHigh,      File.CONKER_DAMAGE_FLYHIGH,     -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.DamageFlyMid,       File.CONKER_DAMAGE_FLYMID,      -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.DamageFlyLow,       File.CONKER_DAMAGE_FLYLOW,      -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.DownStandU,         File.CONKER_DOWNSTANDU,         -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.StunStartU,         File.CONKER_DOWNSTANDU,         -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Revive1,            File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Revive2,            File.CONKER_DOWNSTANDU,         -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.DownBounceU,        File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.StunLandU,          File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.StunLandU,          File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.DownAttackD,        File.CONKER_DOWNATTACKD,        Conker.DOWNATTACKD,                -1)
    Character.edit_action_parameters(NCONKER, Action.Tech,               -1,                             Conker.TECH,                       -1)
    Character.edit_action_parameters(NCONKER, Action.TechF,              File.CONKER_TECHF,              Conker.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NCONKER, Action.TechB,              File.CONKER_TECHB,              Conker.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NCONKER, Action.Walk1,              File.CONKER_WALK1,              Conker.WALK1,                      -1)
    Character.edit_action_parameters(NCONKER, Action.Walk2,              File.CONKER_WALK2,              -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Walk3,              File.CONKER_WALK3,              -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Dash,               File.CONKER_DASH,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Run,                File.CONKER_RUN,                -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.RunBrake,           File.CONKER_RUN_BRAKE,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.TurnRun,            File.CONKER_RUN_TURN,           -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Crouch,             File.CONKER_CROUCH,             -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CrouchIdle,         File.CONKER_CROUCH_IDLE,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CrouchEnd,          File.CONKER_CROUCH_END,         -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.JumpSquat,          File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ShieldJumpSquat,    File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.LandingLight,       File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.LandingHeavy,       File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.LandingSpecial,     File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.LandingAirX,        File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.LandingAirF,        File.CONKER_FAIR_LANDING,       -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.LandingAirB,        File.CONKER_BAIR_LANDING,       -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.FallAerial,         File.CONKER_FALLAERIAL,         -1,                         -1)

    Character.edit_action_parameters(NCONKER, Action.JumpF,              File.CONKER_JUMPF,              Conker.JUMP,                       -1)
    Character.edit_action_parameters(NCONKER, Action.JumpB,              File.CONKER_JUMPB,              Conker.JUMP,                       -1)
    Character.edit_action_parameters(NCONKER, Action.JumpAerialF,        File.CONKER_JUMPAF,             Conker.JUMP2,                      -1)
    Character.edit_action_parameters(NCONKER, Action.JumpAerialB,        File.CONKER_JUMPAB,             Conker.JUMP2,                      -1)
    Character.edit_action_parameters(NCONKER, Action.Fall,               File.CONKER_FALL,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.FallSpecial,        File.CONKER_SFALL,              Conker.SFALL,                      -1)
    Character.edit_action_parameters(NCONKER, Action.Idle,               File.CONKER_IDLE,               Conker.IDLE,                       -1)
    Character.edit_action_parameters(NCONKER, 0x06,                      File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Entry,              File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ReviveWait,         File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.EggLay,             File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Turn,               File.CONKER_TURN,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.RollF,              File.CONKER_ROLLF,              Conker.FROLL,                         -1)
    Character.edit_action_parameters(NCONKER, Action.RollB,              File.CONKER_ROLLB,              Conker.BROLL,                         -1)

    Character.edit_action_parameters(NCONKER, Action.Taunt,              File.CONKER_TAUNT,              Conker.TAUNT,                      -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirF,      File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirB,      File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirU,      File.CONKER_ITEM_THROWU,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirD,      File.CONKER_ITEM_THROWD,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirSmashF, File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirSmashB, File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirSmashU, File.CONKER_ITEM_THROWU,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ItemThrowAirSmashD, File.CONKER_ITEM_THROWD,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.BeamSwordSmash,     File.CONKER_ITEM_SWING_SMASH,   -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.BeamSwordDash,      File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.BeamSwordNeutral,   File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.BeamSwordTilt,      File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.BatSmash,           File.CONKER_ITEM_SWING_SMASH,   -1,                   -1)
    Character.edit_action_parameters(NCONKER, Action.BatDash,            File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.BatNeutral,         File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.BatTilt,            File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.FanSmash,           File.CONKER_ITEM_SWING_SMASH,   -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.FanDash,            File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.FanNeutral,         File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.FanTilt,            File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.StarRodSmash,       File.CONKER_ITEM_SWING_SMASH,   -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.StarRodDash,        File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.StarRodNeutral,     File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.StarRodTilt,        File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.RayGunShoot,        File.CONKER_RAYGUN_GROUND,      -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.FireFlowerShoot,    File.CONKER_RAYGUN_GROUND,      -1,                         -1)

    Character.edit_action_parameters(NCONKER, Action.CliffCatch,         File.CONKER_CLIFF_CATCH,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffWait,          File.CONKER_CLIFF_WAIT,         -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffQuick,         File.CONKER_CLIFF_QUICK,        -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffClimbQuick1,   File.CONKER_CLIFF_CLIMB_QUICK1, -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffClimbQuick2,   File.CONKER_CLIFF_CLIMB_QUICK2, -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffSlow,          File.CONKER_CLIFF_SLOW,         -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffClimbSlow1,    File.CONKER_CLIFF_CLIMB_SLOW1,  -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffClimbSlow2,    File.CONKER_CLIFF_CLIMB_SLOW2,  -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffAttackQuick1,  File.CONKER_CLIFF_ATTACK_QUICK1, -1,                        -1)
    Character.edit_action_parameters(NCONKER, Action.CliffAttackQuick2,  File.CONKER_CLIFF_ATTACK_QUICK2, Conker.EDGEATTACKF,                        -1)
    Character.edit_action_parameters(NCONKER, Action.CliffAttackSlow1,   File.CONKER_CLIFF_ATTACK_SLOW1, Conker.EDGEATTACKS,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffAttackSlow2,   File.CONKER_CLIFF_ATTACK_SLOW2, -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffEscapeQuick1,  File.CONKER_CLIFF_ESCAPE_QUICK1, -1,                        -1)
    Character.edit_action_parameters(NCONKER, Action.CliffEscapeQuick2,  File.CONKER_CLIFF_ESCAPE_QUICK2, -1,                        -1)
    Character.edit_action_parameters(NCONKER, Action.CliffEscapeSlow1,   File.CONKER_CLIFF_ESCAPE_SLOW1, -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.CliffEscapeSlow2,   File.CONKER_CLIFF_ESCAPE_SLOW2, -1,                         -1)

    Character.edit_action_parameters(NCONKER, Action.Grab,               File.CONKER_GRAB,               Conker.GRAB,                         -1)
    Character.edit_action_parameters(NCONKER, Action.GrabPull,           File.CONKER_GRAB_PULL,          -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ThrowF,             File.CONKER_THROWF,             Conker.FTHROW,                         -1)
    Character.edit_action_parameters(NCONKER, Action.ThrowB,             File.CONKER_THROWB,             Conker.BTHROW,                     0x10000000)
    Character.edit_action_parameters(NCONKER, Action.CapturePulled,      File.CONKER_CAPTURE_PULLED,     -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.EggLayPulled,       File.CONKER_CAPTURE_PULLED,     -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.Jab1,               File.CONKER_JAB1,               Conker.JAB1,                       -1)
    Character.edit_action_parameters(NCONKER, Action.Jab2,               File.CONKER_JAB2,               Conker.JAB2,                       -1)
    Character.edit_action_parameters(NCONKER, 0xDC,                      File.CONKER_JAB_LOOP_START,     Conker.JAB_LOOP_START,             -1)
    Character.edit_action_parameters(NCONKER, 0xDD,                      File.CONKER_JAB_LOOP,           Conker.JAB_LOOP,                   -1)
    Character.edit_action_parameters(NCONKER, 0xDE,                      File.CONKER_JAB_LOOP_END,       Conker.JAB_LOOP_END,               -1)
    Character.edit_action_parameters(NCONKER, Action.DashAttack,         File.CONKER_DASH_ATTACK,        Conker.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NCONKER, Action.UTilt,              File.CONKER_UTILT,              Conker.UTILT,                      0x00000000)
    Character.edit_action_parameters(NCONKER, Action.FTiltHigh,          File.CONKER_FTILT_HIGH,         Conker.FTILT_HIGH,                 0x00000000)
    Character.edit_action_parameters(NCONKER, Action.FTiltMidHigh,       0,                              0x80000000,                 0x00000000)
    Character.edit_action_parameters(NCONKER, Action.FTilt,              File.CONKER_FTILT_MID,          Conker.FTILT_MID,                  0x00000000)
    Character.edit_action_parameters(NCONKER, Action.FTiltMidLow,        0,                              0x80000000,                 0x00000000)
    Character.edit_action_parameters(NCONKER, Action.FTiltLow,           File.CONKER_FTILT_LOW,          Conker.FTILT_LOW,                  0x00000000)
    Character.edit_action_parameters(NCONKER, Action.DTilt,              File.CONKER_DTILT,              Conker.DTILT,                      0x00000000)
    Character.edit_action_parameters(NCONKER, Action.DSmash,             File.CONKER_DSMASH,             Conker.DSMASH,                     -1)
    Character.edit_action_parameters(NCONKER, Action.FSmash,             File.CONKER_FSMASH,             Conker.FSMASH,                     0x00000000)
    Character.edit_action_parameters(NCONKER, Action.USmash,             File.CONKER_USMASH,             Conker.USMASH,                     0x00000000)
    Character.edit_action_parameters(NCONKER, Action.AttackAirB,         File.CONKER_BAIR,               Conker.BAIR,                       0x00000000)
    Character.edit_action_parameters(NCONKER, Action.AttackAirF,         File.CONKER_FAIR,               Conker.FAIR,                       -1)
    Character.edit_action_parameters(NCONKER, Action.AttackAirD,         File.CONKER_DAIR,               Conker.DAIR,                       -1)
    Character.edit_action_parameters(NCONKER, Action.AttackAirN,         File.CONKER_NAIR,               -1,                         -1)
    Character.edit_action_parameters(NCONKER, Action.AttackAirU,         File.CONKER_UAIR,               Conker.UAIR,                       -1)


    Character.edit_action_parameters(NCONKER, 0xDF,                      File.CONKER_IDLE,               0x80000000,                0)
    Character.edit_action_parameters(NCONKER, 0xE0,                      File.CONKER_IDLE,               0x80000000,                0)
    Character.edit_action_parameters(NCONKER, 0xE3,                      File.CONKER_USP_START_AIR,      Conker.USP_GROUND,                 0x00000000)
    Character.edit_action_parameters(NCONKER, 0xE4,                      File.CONKER_USP_START_AIR,      Conker.USP,                        0x00000000)
    Character.edit_action_parameters(NCONKER, 0xE6,                      File.CONKER_USP_LOOP_AIR,       Conker.USP_DESCENT_LOOP,           0x00000000)
    Character.edit_action_parameters(NCONKER, 0xEC,                      File.CONKER_DSP_GROUND,         Conker.DSP_GROUND,                 -1)
    Character.edit_action_parameters(NCONKER, 0xEF,                      File.CONKER_DSP_GROUND_FAIL,    Conker.DSP_FAIL,                   0x00000000)
    Character.edit_action_parameters(NCONKER, 0xF1,                      File.CONKER_DSP_AIR,            Conker.DSP_GROUND,                 -1)
    Character.edit_action_parameters(NCONKER, 0xF5,                      File.CONKER_DSP_AIR_FAIL,       Conker.DSP_FAIL,                   0x00000000)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NCONKER, 0xDF,             -1,            0x8013D994,                  0x00000000,                     0x00000000,                     0x00000000)
    Character.edit_action(NCONKER, 0xE0,             -1,            0x8013D994,                  0x00000000,                     0x00000000,                     0x00000000)
    Character.edit_action(NCONKER, 0xE3,             -1,            ConkerUSP.main_air,          ConkerUSP.ground_y_velocity_,   ConkerUSP.air_physics_,         0x8015DD58)
    Character.edit_action(NCONKER, 0xE4,             -1,            ConkerUSP.main_air,          0,                              ConkerUSP.air_physics_,         0x8015DD58)
    Character.edit_action(NCONKER, 0xE6,             -1,            ConkerUSP.descent_main_air,  0,                              ConkerUSP.descent_air_physics_2, 0x8015DD58)
    Character.edit_action(NCONKER, 0xEC,             -1,            ConkerDSP.main,              0,                              0x800D8CCC,                     ConkerDSP.ground_collision)
    Character.edit_action(NCONKER, 0xEF,             -1,            0x800D94C4,                  0x00000000,                     0x800D8CCC,                     ConkerDSP.ground_collision_fail)
    Character.edit_action(NCONKER, 0xF1,             -1,            ConkerDSP.main,              0,                              0x800D90E0,                     ConkerDSP.air_collision)
    Character.edit_action(NCONKER, 0xF5,             -1,            0x800D94E8,                  0x00000000,                     0x800D90E0,                     ConkerDSP.air_collision_fail)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NCONKER, 0x0,              File.CONKER_IDLE,           Conker.PLACEHOLDER,                -1)
    Character.edit_menu_action_parameters(NCONKER, 0x1,              File.CONKER_VICTORY1,       Conker.VICTORY1,                   -1)
    Character.edit_menu_action_parameters(NCONKER, 0x2,              File.CONKER_VICTORY2,       Conker.VICTORY2,                   -1)
    Character.edit_menu_action_parameters(NCONKER, 0x3,              File.CONKER_SELECTED,       Conker.SELECTED,                   -1)
    Character.edit_menu_action_parameters(NCONKER, 0x4,              File.CONKER_SELECTED,       Conker.SELECTED,                   -1)
    Character.edit_menu_action_parameters(NCONKER, 0x5,              File.CONKER_CLAP,           Conker.CLAP,                       -1)
    Character.edit_menu_action_parameters(NCONKER, 0x9,              File.CONKER_PUPPET_FALL,    -1,                         -1)
    Character.edit_menu_action_parameters(NCONKER, 0xA,              File.CONKER_PUPPET_UP,      -1,                         -1)
    Character.edit_menu_action_parameters(NCONKER, 0xD,              File.CONKER_1P,             Conker.ONEP,                       -1)
    Character.edit_menu_action_parameters(NCONKER, 0xE,              File.CONKER_1P_CPU_POSE,    -1,                         -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(NCONKER, NSP_Ground_Begin,   -1,             File.CONKER_NSPG_BEGIN,     Conker.NSP_BEGIN,                  0)
    Character.add_new_action_params(NCONKER, NSP_Ground_Wait,    -1,             File.CONKER_NSPG_WAIT,      Conker.NSP_WAIT,                   0)
    Character.add_new_action_params(NCONKER, NSP_Ground_End,     -1,             File.CONKER_NSPG_END,       Conker.NSP_END,                    0)
    Character.add_new_action_params(NCONKER, NSP_Air_Begin,      -1,             File.CONKER_NSPA_BEGIN,     Conker.NSP_BEGIN,                  0)
    Character.add_new_action_params(NCONKER, NSP_Air_Wait,       -1,             File.CONKER_NSPA_WAIT,      Conker.NSP_WAIT,                   0)
    Character.add_new_action_params(NCONKER, NSP_Air_End,        -1,             File.CONKER_NSPA_END,       Conker.NSP_END,                    0)

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(NCONKER, NSP_Ground_Begin,  -1,             ActionParams.NSP_Ground_Begin,      0x12,           ConkerNSP.ground_begin_main_,   0,                              0x800D8BB4,                         ConkerNSP.ground_collision_)
    Character.add_new_action(NCONKER, NSP_Ground_Wait,   -1,             ActionParams.NSP_Ground_Wait,       0x12,           ConkerNSP.ground_wait_main_,    0,                              0x800D8BB4,                         ConkerNSP.ground_collision_)
    Character.add_new_action(NCONKER, NSP_Ground_End,    -1,             ActionParams.NSP_Ground_End,        0x12,           ConkerNSP.end_main_,            0,                              0x800D8BB4,                         ConkerNSP.ground_collision_)
    Character.add_new_action(NCONKER, NSP_Air_Begin,     -1,             ActionParams.NSP_Air_Begin,         0x12,           ConkerNSP.air_begin_main_,      0,                              0x800D90E0,                         ConkerNSP.air_collision_)
    Character.add_new_action(NCONKER, NSP_Air_Wait,      -1,             ActionParams.NSP_Air_Wait,          0x12,           ConkerNSP.air_wait_main_,       0,                              0x800D90E0,                         ConkerNSP.air_collision_)
    Character.add_new_action(NCONKER, NSP_Air_End,       -1,             ActionParams.NSP_Air_End,           0x12,           ConkerNSP.end_main_,            0,                              0x800D90E0,                         ConkerNSP.air_collision_end_)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NCONKER, 0x4)
    float32 0.8
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.NCONKER, 0x4)
    dw      ConkerNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.NCONKER, 0x4)
    dw      ConkerNSP.ground_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.NCONKER, 0x4)
    dw      ConkerDSP.initial_
    OS.patch_end()

    Character.table_patch_start(air_dsp, Character.id.NCONKER, 0x4)
    dw      ConkerDSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.NCONKER, 0x4)
    dw      ConkerUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.NCONKER, 0x4)
    dw      ConkerUSP.ground_initial_
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NCONKER, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.NCONKER, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NCONKER, 0x4)
    dw      Conker.CPU_ATTACKS
    OS.patch_end()
    
    // Set action strings
    Character.table_patch_start(action_string, Character.id.NCONKER, 0x4)
    dw  Conker.Action.action_string_table
    OS.patch_end()

    // Handles common things for Polygons
    Character.polygon_setup(NCONKER, CONKER)

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.NCONKER, 0x2)
    dh  0x005E
    OS.patch_end()
}
