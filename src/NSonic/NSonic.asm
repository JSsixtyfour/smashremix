// NSonic.asm

// This file contains file inclusions, action edits, and assembly for Polygon Sonic.

scope NSonic {
    // Insert Moveset files
    

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(NSONIC, Action.Idle,            File.SONIC_IDLE,            Sonic.IDLE,                       -1)
    Character.edit_action_parameters(NSONIC, 0x06,                   File.SONIC_IDLE,            Sonic.IDLE,                       -1)
    Character.edit_action_parameters(NSONIC, Action.Entry,           File.SONIC_IDLE,            Sonic.IDLE,                       -1)
    Character.edit_action_parameters(NSONIC, Action.ReviveWait,      File.SONIC_IDLE,            Sonic.IDLE,                       -1)
    Character.edit_action_parameters(NSONIC, Action.EggLay,          File.SONIC_IDLE,            Sonic.IDLE,                       -1)
    Character.edit_action_parameters(NSONIC, Action.Tech,            File.SONIC_TECH,            Sonic.TECH_STAND,                 -1)
    Character.edit_action_parameters(NSONIC, Action.TechF,           File.SONIC_TECHF,           Sonic.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NSONIC, Action.TechB,           File.SONIC_TECHB,           Sonic.TECH_ROLL,                  -1)
    Character.edit_action_parameters(NSONIC, Action.RollF,           -1,                         Sonic.FROLL,                      -1)
    Character.edit_action_parameters(NSONIC, Action.RollB,           -1,                         Sonic.BROLL,                      -1)
    Character.edit_action_parameters(NSONIC, Action.CliffCatch,      File.SONIC_CLIFF_CATCH,     -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.CliffSlow,       File.SONIC_CLIFF_SLOW,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.CliffWait,       File.SONIC_CLIFF_WAIT,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.CliffQuick,      File.SONIC_CLIFF_QUICK,     -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.CliffClimbQuick1, File.SONIC_CLIFF_CLIMB_QUICK1, -1,                     -1)
    Character.edit_action_parameters(NSONIC, Action.CliffClimbQuick2, File.SONIC_CLIFF_CLIMB_QUICK2, -1,                     -1)
    Character.edit_action_parameters(NSONIC, Action.CliffAttackQuick1, File.SONIC_CLIFF_CLIMB_QUICK1, -1,                    -1)
    Character.edit_action_parameters(NSONIC, Action.CliffAttackQuick2, File.SONIC_CLIFF_ATTACK_QUICK2, Sonic.EDGEATTACKF,          -1)
    Character.edit_action_parameters(NSONIC, Action.CliffEscapeQuick1, File.SONIC_CLIFF_CLIMB_QUICK1, -1,                    -1)
    Character.edit_action_parameters(NSONIC, Action.CliffEscapeQuick2, File.SONIC_CLIFF_ESCAPE_QUICK2, -1,                   -1)
    Character.edit_action_parameters(NSONIC, Action.CliffEscapeSlow2, -1,                        Sonic.CLIFF_ESCAPE2,              -1)
    Character.edit_action_parameters(NSONIC, Action.ShieldBreak,     -1,                         Sonic.SHIELD_BREAK,               -1)
    Character.edit_action_parameters(NSONIC, Action.DeadU,           File.SONIC_TUMBLE,          Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.ScreenKO,        File.SONIC_TUMBLE,          Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.Tumble,          File.SONIC_TUMBLE,          Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.WallBounce,      File.SONIC_TUMBLE,          Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.Tornado,         File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.ShieldBreakFall, File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.EggLayPulled,    -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.InhalePulled,    File.SONIC_TUMBLE,          Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.InhaleSpat,      File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.InhaleCopied,    File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(NSONIC, 0xB4,                   File.SONIC_TUMBLE,          Sonic.UNKNOWN_0B4,                -1)
    Character.edit_action_parameters(NSONIC, Action.FalconDivePulled, -1,                        Sonic.FALCON_DIVE_PULLED,         -1)
    Character.edit_action_parameters(NSONIC, Action.ThrownDK,        -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.ThrownDKPulled,  -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.ThrownMarioBros, -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.CapturePulled,   -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.Thrown1,         -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.Thrown2,         -1,                         Sonic.DMG_1,                      -1)
                                                                                              
    Character.edit_action_parameters(NSONIC, Action.Stun,            File.SONIC_STUN,            Sonic.STUN,                       -1)
    Character.edit_action_parameters(NSONIC, Action.Sleep,           File.SONIC_STUN,            Sonic.ASLEEP,                     -1)
    Character.edit_action_parameters(NSONIC, Action.ShieldDrop,      File.SONIC_SHIELD_DROP,     -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Pass,            File.SONIC_SHIELD_DROP,     -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Crouch,          File.SONIC_CROUCH,          -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.CrouchIdle,      File.SONIC_CROUCH_IDLE,     -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.CrouchEnd,       File.SONIC_CROUCH_END,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Walk1,           File.SONIC_WALK1,           -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Walk2,           File.SONIC_WALK2,           -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Walk3,           File.SONIC_WALK3,           -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Run,             File.SONIC_RUN,             Sonic.RUN,                        -1)
    Character.edit_action_parameters(NSONIC, Action.RunBrake,        File.SONIC_RUN_BRAKE,       Sonic.RUNSTOP,                    -1)
    Character.edit_action_parameters(NSONIC, Action.TurnRun,         File.SONIC_RUN_TURN,        Sonic.TURNRUN,                    -1)
    Character.edit_action_parameters(NSONIC, Action.JumpF,           File.SONIC_JUMP_F,          Sonic.JUMP,                       -1)
    Character.edit_action_parameters(NSONIC, Action.JumpB,           File.SONIC_JUMP_B,          Sonic.JUMP,                       -1)
    Character.edit_action_parameters(NSONIC, Action.JumpAerialF,     File.SONIC_JUMP_AF,         Sonic.JUMP_2,                     -1)
    Character.edit_action_parameters(NSONIC, Action.JumpAerialB,     File.SONIC_JUMP_AB,         Sonic.JUMP_2,                     -1)
    Character.edit_action_parameters(NSONIC, Action.Fall,            File.SONIC_FALL,            -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.FallAerial,      File.SONIC_FALL2,           -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.JumpSquat,       File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.ShieldJumpSquat, File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.LandingLight,    File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.LandingHeavy,    File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.LandingSpecial,  File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.LandingAirX,     File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.FallSpecial,     File.SONIC_SFALL,           -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Taunt,           File.SONIC_TAUNT,           Sonic.TAUNT,                      -1)
    Character.edit_action_parameters(NSONIC, Action.Grab,            File.SONIC_GRAB,            -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.GrabPull,        File.SONIC_GRAB_PULL,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.ThrowF,          File.SONIC_THROWF,          Sonic.FTHROW,                     -1)
    Character.edit_action_parameters(NSONIC, Action.ThrowB,          File.SONIC_THROWB,          Sonic.BTHROW,                     -1)
    Character.edit_action_parameters(NSONIC, Action.Jab1,            File.SONIC_JAB1,            Sonic.JAB1,                       -1)
    Character.edit_action_parameters(NSONIC, Action.Jab2,            File.SONIC_JAB2,            Sonic.JAB2,                       -1)
    Character.edit_action_parameters(NSONIC, 0xDC,                   File.SONIC_JAB3,            Sonic.JAB3,                       -1)
    Character.edit_action_parameters(NSONIC, Action.DashAttack,      File.SONIC_DASH_ATTACK,     Sonic.DASH_ATTACK,                -1)
    Character.edit_action_parameters(NSONIC, Action.FTiltHigh,       File.SONIC_FTILT_HIGH,      Sonic.FTILT_HIGH,                 -1)
    Character.edit_action_parameters(NSONIC, Action.FTiltMidHigh,    0,                          0x80000000,                  0)
    Character.edit_action_parameters(NSONIC, Action.FTilt,           File.SONIC_FTILT,           Sonic.FTILT,                      -1)
    Character.edit_action_parameters(NSONIC, Action.FTiltMidLow,     0,                          0x80000000,                  0)
    Character.edit_action_parameters(NSONIC, Action.FTiltLow,        File.SONIC_FTILT_LOW,       Sonic.FTILT_LOW,                  -1)
    Character.edit_action_parameters(NSONIC, Action.UTilt,           File.SONIC_UTILT,           Sonic.UTILT,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DTilt,           File.SONIC_DTILT,           Sonic.DTILT,                      -1)
    Character.edit_action_parameters(NSONIC, Action.FSmashHigh,      File.SONIC_FSMASH_HIGH,     Sonic.FSMASH_HIGH,                0x00000000)
    Character.edit_action_parameters(NSONIC, Action.FSmashMidHigh,   File.SONIC_FSMASH_MID_HIGH, Sonic.FSMASH_MID_HIGH,            0x00000000)
    Character.edit_action_parameters(NSONIC, Action.FSmash,          File.SONIC_FSMASH,          Sonic.FSMASH,                     0x00000000)
    Character.edit_action_parameters(NSONIC, Action.FSmashMidLow,    File.SONIC_FSMASH_MID_LOW,  Sonic.FSMASH_MID_LOW,             0x00000000)
    Character.edit_action_parameters(NSONIC, Action.FSmashLow,       File.SONIC_FSMASH_LOW,      Sonic.FSMASH_LOW,                 0x00000000)
    Character.edit_action_parameters(NSONIC, Action.USmash,          File.SONIC_USMASH,          Sonic.USMASH,                     -1)
    Character.edit_action_parameters(NSONIC, Action.DSmash,          File.SONIC_DSMASH,          Sonic.DSMASH,                     -1)
    Character.edit_action_parameters(NSONIC, Action.AttackAirN,      File.SONIC_NAIR,            Sonic.NAIR,                       -1)
    Character.edit_action_parameters(NSONIC, Action.AttackAirF,      File.SONIC_FAIR,            Sonic.FAIR,                       -1)
    Character.edit_action_parameters(NSONIC, Action.AttackAirB,      File.SONIC_BAIR,            Sonic.BAIR,                       -1)
    Character.edit_action_parameters(NSONIC, Action.AttackAirU,      File.SONIC_UAIR,            Sonic.UAIR,                       -1)
    Character.edit_action_parameters(NSONIC, Action.AttackAirD,      File.SONIC_DAIR,            Sonic.DAIR,                       -1)
    Character.edit_action_parameters(NSONIC, Action.EnterPipe,       File.SONIC_ENTER_PIPE,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.ExitPipe,        File.SONIC_EXIT_PIPE,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.DownStandU,      File.SONIC_DOWNSTANDU,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.StunStartU,      File.SONIC_DOWNSTANDU,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.Revive2,         File.SONIC_DOWNSTANDU,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.DownStandD,      File.SONIC_DOWNSTANDD,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.StunStartD,      File.SONIC_DOWNSTANDD,      -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.DownBounceU,     -1,                         Sonic.DOWNBOUNCE,                 -1)
    Character.edit_action_parameters(NSONIC, Action.DownBounceD,     -1,                         Sonic.DOWNBOUNCE,                 -1)
    Character.edit_action_parameters(NSONIC, Action.DownAttackU,     File.SONIC_DOWNATTACKU,     Sonic.DOWNATTACKU,                         -1)
    Character.edit_action_parameters(NSONIC, Action.DownBackU,       File.SONIC_DOWNBACKU,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.DownBackD,       File.SONIC_DOWNBACKD,       -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.DownForwardD,    File.SONIC_DOWNFORWARDD,    -1,                         -1)
    Character.edit_action_parameters(NSONIC, Action.DownForwardU,    File.SONIC_DOWNFORWARDU,    -1,                         -1)
    Character.edit_action_parameters(NSONIC, 0xE4,                   File.SONIC_USP_SPRING,      Sonic.USP,                        0x00000000)

    Character.edit_action_parameters(NSONIC, Action.Teeter,          File.SONIC_TEETER,          Sonic.TEETERING,                  -1)
    Character.edit_action_parameters(NSONIC, Action.TeeterStart,     File.SONIC_TEETER_START,    -1,                         -1)

    Character.edit_action_parameters(NSONIC, 0xDF,                   File.SONIC_IDLE,      0x800000000,                      0x00000000)
    Character.edit_action_parameters(NSONIC, 0xE0,                   File.SONIC_IDLE,      0x800000000,                      0x00000000)

    Character.edit_action_parameters(NSONIC, Action.DamageHigh1,     -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageHigh2,     -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageHigh3,     -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageMid1,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageMid2,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageMid3,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageLow1,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageLow2,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageLow3,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageAir1,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageAir2,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageAir3,      -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageElec1,     -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageElec2,     -1,                         Sonic.DMG_1,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageFlyHigh,   -1,                         Sonic.DMG_2,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageFlyMid,    -1,                         Sonic.DMG_2,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageFlyLow,    -1,                         Sonic.DMG_2,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageFlyTop,    -1,                         Sonic.DMG_2,                      -1)
    Character.edit_action_parameters(NSONIC, Action.DamageFlyRoll,   -1,                         Sonic.DMG_2,                      -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(NSONIC,  DSP_Ground_Charge,  -1,             File.SONIC_CHARGE_LOOP,     Sonic.DSP_CHARGE,                 0)
    Character.add_new_action_params(NSONIC,  DSP_Ground_Move,    -1,             File.SONIC_SPIN_LOOP_FAST,  Sonic.DSP_MOVE,                   0x10000000)
    Character.add_new_action_params(NSONIC,  DSP_Ground_End,     -1,             File.SONIC_CROUCH_END,      0x80000000,                 0)
    Character.add_new_action_params(NSONIC,  DSP_Air_Charge,     -1,             File.SONIC_CHARGE_LOOP,     Sonic.DSP_AIR_CHARGE,             0)
    Character.add_new_action_params(NSONIC,  DSP_Air_Move,       -1,             File.SONIC_JUMP_F,          Sonic.DSP_AIR_MOVE,               0)
    Character.add_new_action_params(NSONIC,  DSP_Air_Jump,       -1,             File.SONIC_JUMP_F,          Sonic.DSP_AIR_JUMP,               0)
    Character.add_new_action_params(NSONIC,  DSP_Air_End,        -1,             File.SONIC_NSP_FINISH,      0x80000000,                 0)
    Character.add_new_action_params(NSONIC,  NSP_Begin,          -1,             File.SONIC_SPIN_LOOP,       Sonic.NSP_CHARGE,                 0)
    Character.add_new_action_params(NSONIC,  NSP_Move,           -1,             File.SONIC_SPIN_LOOP_FAST,  Sonic.NSP_MOVE,                   0x10000000)
    Character.add_new_action_params(NSONIC,  NSP_Locked_Move,    -1,             File.SONIC_SPIN_LOOP_FAST,  Sonic.NSP_MOVE,                   0x10000000)
    Character.add_new_action_params(NSONIC,  NSP_Ground_End,     -1,             File.SONIC_NSP_GROUND_END,  0x80000000,                 0)
    Character.add_new_action_params(NSONIC,  NSP_Air_End,        -1,             File.SONIC_JUMP_F,          0x80000000,                 0)
    Character.add_new_action_params(NSONIC,  NSP_Ground_Recoil,  -1,             File.SONIC_NSP_GROUND_RECOIL, 0x80000000,               0)
    Character.add_new_action_params(NSONIC,  NSP_Air_Recoil,     -1,             File.SONIC_JUMP_B,          0x80000000,                 0)
    Character.add_new_action_params(NSONIC,  NSP_Bounce,         -1,             File.SONIC_JUMP_F,          Sonic.NSP_BOUNCE,                 0)


    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(NSONIC, 0xDC,              -1,             0x8014FE40,                 0x00000000,                     0x800D8CCC,                     0x800DDF44)
    Character.edit_action(NSONIC, 0xE4,              -1,             SonicUSP.main_air_,         SonicUSP.interrupt_,            SonicUSP.air_physics_,          0x800DE99C)
    //Character.edit_action(NSONIC, 0xEA,              -1,             0x00000000,                 SonicUSP.special_fall_interrupt_, -1,                           0x800DE99C)
    Character.edit_action(NSONIC,  0xDF,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)
    Character.edit_action(NSONIC,  0xE0,              -1,             0x8013D994,                 0x00000000,                    0x00000000,                     0x00000000)

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(NSONIC,  DSP_Ground_Charge, -1,             ActionParams.DSP_Ground_Charge,     0x1E,           SonicDSP.ground_charge_main_,   0,                              0x800D8BB4,                         SonicDSP.ground_charge_collision_)
    Character.add_new_action(NSONIC,  DSP_Ground_Move,   -1,             ActionParams.DSP_Ground_Move,       0x1E,           SonicDSP.ground_move_main_,     0,                              SonicDSP.ground_move_physics_,      SonicDSP.ground_move_collision_)
    Character.add_new_action(NSONIC,  DSP_Ground_End,    -1,             ActionParams.DSP_Ground_End,        0x1E,           0x800D94C4,                     0,                              0x800D8BB4,                         SonicDSP.ground_end_collision_)
    Character.add_new_action(NSONIC,  DSP_Air_Charge,    -1,             ActionParams.DSP_Air_Charge,        0x1E,           SonicDSP.air_charge_main_,      0,                              0x800D91EC,                         SonicDSP.air_charge_collision_)
    Character.add_new_action(NSONIC,  DSP_Air_Move,      -1,             ActionParams.DSP_Air_Move,          0x1E,           SonicDSP.air_move_main_,        SonicDSP.air_move_interrupt_,   SonicDSP.air_movement_physics_,     SonicDSP.air_move_collision_)
    Character.add_new_action(NSONIC,  DSP_Air_Jump,      -1,             ActionParams.DSP_Air_Jump,          0x1E,           SonicDSP.air_move_main_,        SonicDSP.air_move_interrupt_,   SonicDSP.air_movement_physics_,     SonicDSP.air_move_collision_)
    Character.add_new_action(NSONIC,  DSP_Air_End,       -1,             ActionParams.DSP_Air_End,           0x1E,           0x800D94E8,                     0,                              0x800D91EC,                         SonicDSP.air_end_collision_)
    Character.add_new_action(NSONIC,  NSP_Begin,         -1,             ActionParams.NSP_Begin,             0x12,           SonicNSP.begin_main_,           0,                              0,                                  0x800DE6B0)
    Character.add_new_action(NSONIC,  NSP_Move,          -1,             ActionParams.NSP_Move,              0x12,           SonicNSP.move_main_,            0,                              SonicNSP.move_physics_,             SonicNSP.move_collision_)
    Character.add_new_action(NSONIC,  NSP_Locked_Move,   -1,             ActionParams.NSP_Locked_Move,       0x12,           SonicNSP.move_main_,            0,                              SonicNSP.move_physics_,             SonicNSP.move_collision_)
    Character.add_new_action(NSONIC,  NSP_Ground_End,    -1,             ActionParams.NSP_Ground_End,        0x12,           0x800D94C4,                     0,                              0x800D8BB4,                         SonicNSP.ground_end_collision_)
    Character.add_new_action(NSONIC,  NSP_Air_End,       -1,             ActionParams.NSP_Air_End,           0x12,           0x800D94E8,                     0,                              0x800D91EC,                         SonicNSP.air_end_collision_)
    Character.add_new_action(NSONIC,  NSP_Ground_Recoil, -1,             ActionParams.NSP_Ground_Recoil,     0x12,           0x800D94C4,                     0,                              0x800D8BB4,                         SonicNSP.ground_recoil_collision_)
    Character.add_new_action(NSONIC,  NSP_Air_Recoil,    -1,             ActionParams.NSP_Air_Recoil,        0x12,           0x800D94E8,                     0,                              0x800D91EC,                         SonicNSP.air_recoil_collision_)
    Character.add_new_action(NSONIC,  NSP_Bounce,        -1,             ActionParams.NSP_Bounce,            0x12,           0x800D94E8,                     0,                              0x800D91EC,                         0x800DE99C)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NSONIC, 0x0,               File.SONIC_IDLE,            Sonic.IDLE,                       -1)
    Character.edit_menu_action_parameters(NSONIC, 0x1,               File.SONIC_VICTORY1,        Sonic.VICTORY1,                 -1)
    Character.edit_menu_action_parameters(NSONIC, 0x2,               File.SONIC_VICTORY2,        0x80000000,                 -1)
    Character.edit_menu_action_parameters(NSONIC, 0x3,               File.SONIC_CSS,             Sonic.CSS,                 -1)
    Character.edit_menu_action_parameters(NSONIC, 0x4,               File.SONIC_CSS,             Sonic.CSS,                 -1)
    Character.edit_menu_action_parameters(NSONIC, 0x5,               File.SONIC_CLAP,            Sonic.CLAP,                       -1)
    Character.edit_menu_action_parameters(NSONIC, 0x9,               File.SONIC_PUPPET_FALL,     -1,                         -1)
    Character.edit_menu_action_parameters(NSONIC, 0xA,               File.SONIC_PUPPET_UP,       -1,                         -1)
    Character.edit_menu_action_parameters(NSONIC, 0xD,               File.SONIC_1P_POSE,         Sonic.SPPOSE,                 -1)
    Character.edit_menu_action_parameters(NSONIC, 0xE,               File.SONIC_1P_CPU_POSE,     0x80000000,                 -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.NSONIC, 0x4)
    float32 0.95
    OS.patch_end()
    
    Character.table_patch_start(variant_original, Character.id.NSONIC, 0x4)
    dw      Character.id.SONIC // set Sonic as original character (not Fox, who NSONIC is a clone of)
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.NSONIC, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.NSONIC, 0xC)
    dh 0x08
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.NSONIC, 0, 1, 4, 5, 1, 3, 2)

    // Set default costume shield colors
    Character.set_costume_shield_colors(NSONIC, PURPLE, RED, GREEN, BLUE, BLACK, WHITE, NA, NA)

    Character.table_patch_start(ground_usp, Character.id.NSONIC, 0x4)
    dw      SonicUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.NSONIC, 0x4)
    dw      SonicUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.NSONIC, 0x4)
    dw      SonicNSP.begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.NSONIC, 0x4)
    dw      SonicNSP.begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.NSONIC, 0x4)
    dw      SonicDSP.ground_charge_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.NSONIC, 0x4)
    dw      SonicDSP.air_charge_initial_
    OS.patch_end()

    // Use Mario's initial/grounded script.
    Character.table_patch_start(initial_script, Character.id.NSONIC, 0x4)
    dw 0x800D7DCC
    OS.patch_end()
    Character.table_patch_start(grounded_script, Character.id.NSONIC, 0x4)
    dw 0x800DE428
    OS.patch_end()
    
    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.NSONIC, 0x4)
    dw      Sonic.CPU_ATTACKS
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.NSONIC, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.NSONIC, 0x4)
    dw  Sonic.Action.action_string_table
    OS.patch_end()

}
