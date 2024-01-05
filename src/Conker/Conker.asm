// Conker.asm

// This file contains file inclusions, action edits, and assembly for Conker.

scope Conker {
    // Insert Moveset files
    insert BLINK,"moveset/BLINK.bin"; Moveset.GO_TO(BLINK)            // loops
    IDLE:
    dw 0xbc000003                                   // set slope contour state
        Moveset.SUBROUTINE(BLINK)                   // blink
        dw 0x0400005A; Moveset.SUBROUTINE(BLINK)    // wait 90 frames then blink
        dw 0x0400000A; Moveset.SUBROUTINE(BLINK)    // wait 10 frames then blink
        dw 0x04000050; Moveset.GO_TO(IDLE)         // loop
    insert JUMP, "moveset/JUMP.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert JAB1,"moveset/JAB1.bin"
    insert JAB2,"moveset/JAB2.bin"
    insert JAB_LOOP_START,"moveset/JAB_LOOP_START.bin"
    insert JAB_LOOP,"moveset/JAB_LOOP.bin"; Moveset.GO_TO(JAB_LOOP+0x4)            // loops, but skips first command
    insert JAB_LOOP_END,"moveset/JAB_LOOP_END.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert UTILT,"moveset/UTILT.bin"
    insert DTILT,"moveset/DTILT.bin"
    insert ENTRY,"moveset/ENTRY.bin"
    insert FTILT_HIGH,"moveset/FTILT_HIGH.bin"
    insert FTILT_MID,"moveset/FTILT_MID.bin"
    insert FTILT_LOW,"moveset/FTILT_LOW.bin"
    insert FSMASH,"moveset/FSMASH.bin"
    insert USMASH,"moveset/USMASH.bin"
    insert DSMASH,"moveset/DSMASH.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    insert FAIR,"moveset/FAIR.bin"
    insert BAIR,"moveset/BAIR.bin"
    insert UAIR,"moveset/UAIR.bin"
    insert DAIR,"moveset/DAIR.bin"
    insert EDGEATTACKF,"moveset/EDGE_ATTACK_F.bin"
    insert EDGEATTACKS,"moveset/EDGE_ATTACK_S.bin"
    insert FTHROWDATA, "moveset/FTHROWDATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROWDATA); insert "moveset/FTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert NSP_BEGIN,"moveset/NSP2_BEGIN.bin"
    insert NSP_WAIT,"moveset/NSP2_WAIT.bin"
    insert NSP_WAIT_LOOP,"moveset/NSP2_WAIT_LOOP.bin"; Moveset.GO_TO(NSP_WAIT_LOOP) // loops
    insert NSP_END,"moveset/NSP2_END.bin"
    insert DSP_FAIL,"moveset/DSP_FAIL.bin"
    insert DSP_GROUND,"moveset/DSP_GROUND.bin"
    insert USP,"moveset/USP.bin"
    insert USP_GROUND,"moveset/USP_GROUND.bin"
    insert USP_DESCENT_LOOP,"moveset/USP_DESCENT_LOOP.bin"; Moveset.GO_TO(USP_DESCENT_LOOP)            // loops
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)   // loops
    insert TEETERING, "moveset/TEETERING.bin"
    insert TECH, "moveset/TECH.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"
    insert FROLL, "moveset/FROLL.bin"
    insert BROLL, "moveset/BROLL.bin"
    insert ONEP, "moveset/ONEP.bin"
    insert DOWNATTACKD,"moveset/DOWNATTACKD.bin"
    insert PLACEHOLDER,"moveset/PLACEHOLDER.bin"
    insert VICTORY1,"moveset/VICTORY1.bin"
    insert VICTORY2,"moveset/VICTORY2.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert CLAP,"moveset/CLAP.bin"
    insert SELECTED,"moveset/SELECTED.bin"
    insert WALK1,"moveset/WALK1.bin"
    insert SFALL,"moveset/SFALL.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action                   // Animation                    // Moveset Data             // Flags
    Character.edit_action_parameters(CONKER, Action.Teeter,             -1,                             TEETERING,                  -1)
    Character.edit_action_parameters(CONKER, Action.ShieldBreak,        -1,                             SHIELD_BREAK,               -1)
    Character.edit_action_parameters(CONKER, Action.ShieldOn,           File.CONKER_SHIELD_ON,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ShieldOff,          File.CONKER_SHIELD_OFF,         -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ShieldDrop,         File.CONKER_SHIELD_DROP,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Pass,               File.CONKER_SHIELD_DROP,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Stun,               File.CONKER_STUN,               STUN,                       -1)
    Character.edit_action_parameters(CONKER, Action.Sleep,              File.CONKER_STUN,               ASLEEP,                     -1)
    Character.edit_action_parameters(CONKER, Action.DamageFlyHigh,      File.CONKER_DAMAGE_FLYHIGH,     -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.DamageFlyMid,       File.CONKER_DAMAGE_FLYMID,      -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.DamageFlyLow,       File.CONKER_DAMAGE_FLYLOW,      -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.DownStandU,         File.CONKER_DOWNSTANDU,         -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.StunStartU,         File.CONKER_DOWNSTANDU,         -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Revive1,            File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Revive2,            File.CONKER_DOWNSTANDU,         -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.DownBounceU,        File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.StunLandU,          File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.StunLandU,          File.CONKER_DOWNBOUNCEU,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.DownAttackD,        File.CONKER_DOWNATTACKD,        DOWNATTACKD,                -1)
    Character.edit_action_parameters(CONKER, Action.Tech,               -1,                             TECH,                       -1)
    Character.edit_action_parameters(CONKER, Action.TechF,              File.CONKER_TECHF,              TECH_ROLL,                  -1)
    Character.edit_action_parameters(CONKER, Action.TechB,              File.CONKER_TECHB,              TECH_ROLL,                  -1)
    Character.edit_action_parameters(CONKER, Action.Walk1,              File.CONKER_WALK1,              WALK1,                      -1)
    Character.edit_action_parameters(CONKER, Action.Walk2,              File.CONKER_WALK2,              -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Walk3,              File.CONKER_WALK3,              -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Dash,               File.CONKER_DASH,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Run,                File.CONKER_RUN,                -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.RunBrake,           File.CONKER_RUN_BRAKE,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.TurnRun,            File.CONKER_RUN_TURN,           -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Crouch,             File.CONKER_CROUCH,             -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CrouchIdle,         File.CONKER_CROUCH_IDLE,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CrouchEnd,          File.CONKER_CROUCH_END,         -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.JumpSquat,          File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ShieldJumpSquat,    File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.LandingLight,       File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.LandingHeavy,       File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.LandingSpecial,     File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.LandingAirX,        File.CONKER_JUMPSQUAT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.LandingAirF,        File.CONKER_FAIR_LANDING,       -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.LandingAirB,        File.CONKER_BAIR_LANDING,       -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.FallAerial,         File.CONKER_FALLAERIAL,         -1,                         -1)

    Character.edit_action_parameters(CONKER, Action.JumpF,              File.CONKER_JUMPF,              JUMP,                       -1)
    Character.edit_action_parameters(CONKER, Action.JumpB,              File.CONKER_JUMPB,              JUMP,                       -1)
    Character.edit_action_parameters(CONKER, Action.JumpAerialF,        File.CONKER_JUMPAF,             JUMP2,                      -1)
    Character.edit_action_parameters(CONKER, Action.JumpAerialB,        File.CONKER_JUMPAB,             JUMP2,                      -1)
    Character.edit_action_parameters(CONKER, Action.Fall,               File.CONKER_FALL,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.FallSpecial,        File.CONKER_SFALL,              SFALL,                      -1)
    Character.edit_action_parameters(CONKER, Action.Idle,               File.CONKER_IDLE,               IDLE,                       -1)
    Character.edit_action_parameters(CONKER, 0x06,                      File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Entry,              File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ReviveWait,         File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.EggLay,             File.CONKER_IDLE,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Turn,               File.CONKER_TURN,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.RollF,              File.CONKER_ROLLF,              FROLL,                         -1)
    Character.edit_action_parameters(CONKER, Action.RollB,              File.CONKER_ROLLB,              BROLL,                         -1)

    Character.edit_action_parameters(CONKER, Action.Taunt,              File.CONKER_TAUNT,              TAUNT,                      -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirF,      File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirB,      File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirU,      File.CONKER_ITEM_THROWU,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirD,      File.CONKER_ITEM_THROWD,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirSmashF, File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirSmashB, File.CONKER_ITEM_THROWF,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirSmashU, File.CONKER_ITEM_THROWU,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ItemThrowAirSmashD, File.CONKER_ITEM_THROWD,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.BeamSwordSmash,     File.CONKER_ITEM_SWING_SMASH,   -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.BeamSwordDash,      File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.BeamSwordNeutral,   File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.BeamSwordTilt,      File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.BatSmash,           File.CONKER_ITEM_SWING_SMASH,   -1,                   -1)
    Character.edit_action_parameters(CONKER, Action.BatDash,            File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.BatNeutral,         File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.BatTilt,            File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.FanSmash,           File.CONKER_ITEM_SWING_SMASH,   -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.FanDash,            File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.FanNeutral,         File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.FanTilt,            File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.StarRodSmash,       File.CONKER_ITEM_SWING_SMASH,   -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.StarRodDash,        File.CONKER_ITEM_SWING_DASH,    -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.StarRodNeutral,     File.CONKER_ITEM_NEUTRAL,       -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.StarRodTilt,        File.CONKER_ITEM_TILT,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.RayGunShoot,        File.CONKER_RAYGUN_GROUND,      -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.FireFlowerShoot,    File.CONKER_RAYGUN_GROUND,      -1,                         -1)

    Character.edit_action_parameters(CONKER, Action.CliffCatch,         File.CONKER_CLIFF_CATCH,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffWait,          File.CONKER_CLIFF_WAIT,         -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffQuick,         File.CONKER_CLIFF_QUICK,        -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffClimbQuick1,   File.CONKER_CLIFF_CLIMB_QUICK1, -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffClimbQuick2,   File.CONKER_CLIFF_CLIMB_QUICK2, -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffSlow,          File.CONKER_CLIFF_SLOW,         -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffClimbSlow1,    File.CONKER_CLIFF_CLIMB_SLOW1,  -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffClimbSlow2,    File.CONKER_CLIFF_CLIMB_SLOW2,  -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffAttackQuick1,  File.CONKER_CLIFF_ATTACK_QUICK1, -1,                        -1)
    Character.edit_action_parameters(CONKER, Action.CliffAttackQuick2,  File.CONKER_CLIFF_ATTACK_QUICK2, EDGEATTACKF,                        -1)
    Character.edit_action_parameters(CONKER, Action.CliffAttackSlow1,   File.CONKER_CLIFF_ATTACK_SLOW1, EDGEATTACKS,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffAttackSlow2,   File.CONKER_CLIFF_ATTACK_SLOW2, -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffEscapeQuick1,  File.CONKER_CLIFF_ESCAPE_QUICK1, -1,                        -1)
    Character.edit_action_parameters(CONKER, Action.CliffEscapeQuick2,  File.CONKER_CLIFF_ESCAPE_QUICK2, -1,                        -1)
    Character.edit_action_parameters(CONKER, Action.CliffEscapeSlow1,   File.CONKER_CLIFF_ESCAPE_SLOW1, -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.CliffEscapeSlow2,   File.CONKER_CLIFF_ESCAPE_SLOW2, -1,                         -1)

    Character.edit_action_parameters(CONKER, Action.Grab,               File.CONKER_GRAB,               GRAB,                         -1)
    Character.edit_action_parameters(CONKER, Action.GrabPull,           File.CONKER_GRAB_PULL,          -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.ThrowF,             File.CONKER_THROWF,             FTHROW,                         -1)
    Character.edit_action_parameters(CONKER, Action.ThrowB,             File.CONKER_THROWB,             BTHROW,                     0x10000000)
    Character.edit_action_parameters(CONKER, Action.CapturePulled,      File.CONKER_CAPTURE_PULLED,     -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.EggLayPulled,       File.CONKER_CAPTURE_PULLED,     -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.Jab1,               File.CONKER_JAB1,               JAB1,                       -1)
    Character.edit_action_parameters(CONKER, Action.Jab2,               File.CONKER_JAB2,               JAB2,                       -1)
    Character.edit_action_parameters(CONKER, 0xDC,                      File.CONKER_JAB_LOOP_START,     JAB_LOOP_START,             -1)
    Character.edit_action_parameters(CONKER, 0xDD,                      File.CONKER_JAB_LOOP,           JAB_LOOP,                   -1)
    Character.edit_action_parameters(CONKER, 0xDE,                      File.CONKER_JAB_LOOP_END,       JAB_LOOP_END,               -1)
    Character.edit_action_parameters(CONKER, Action.DashAttack,         File.CONKER_DASH_ATTACK,        DASH_ATTACK,                -1)
    Character.edit_action_parameters(CONKER, Action.UTilt,              File.CONKER_UTILT,              UTILT,                      0x00000000)
    Character.edit_action_parameters(CONKER, Action.FTiltHigh,          File.CONKER_FTILT_HIGH,         FTILT_HIGH,                 0x00000000)
    Character.edit_action_parameters(CONKER, Action.FTiltMidHigh,       0,                              0x80000000,                 0x00000000)
    Character.edit_action_parameters(CONKER, Action.FTilt,              File.CONKER_FTILT_MID,          FTILT_MID,                  0x00000000)
    Character.edit_action_parameters(CONKER, Action.FTiltMidLow,        0,                              0x80000000,                 0x00000000)
    Character.edit_action_parameters(CONKER, Action.FTiltLow,           File.CONKER_FTILT_LOW,          FTILT_LOW,                  0x00000000)
    Character.edit_action_parameters(CONKER, Action.DTilt,              File.CONKER_DTILT,              DTILT,                      0x00000000)
    Character.edit_action_parameters(CONKER, Action.DSmash,             File.CONKER_DSMASH,             DSMASH,                     -1)
    Character.edit_action_parameters(CONKER, Action.FSmash,             File.CONKER_FSMASH,             FSMASH,                     0x00000000)
    Character.edit_action_parameters(CONKER, Action.USmash,             File.CONKER_USMASH,             USMASH,                     0x00000000)
    Character.edit_action_parameters(CONKER, Action.AttackAirB,         File.CONKER_BAIR,               BAIR,                       0x00000000)
    Character.edit_action_parameters(CONKER, Action.AttackAirF,         File.CONKER_FAIR,               FAIR,                       -1)
    Character.edit_action_parameters(CONKER, Action.AttackAirD,         File.CONKER_DAIR,               DAIR,                       -1)
    Character.edit_action_parameters(CONKER, Action.AttackAirN,         File.CONKER_NAIR,               -1,                         -1)
    Character.edit_action_parameters(CONKER, Action.AttackAirU,         File.CONKER_UAIR,               UAIR,                       -1)


    Character.edit_action_parameters(CONKER, 0xDF,                      File.CONKER_ENTRY,              ENTRY,                -1)
    Character.edit_action_parameters(CONKER, 0xE0,                      File.CONKER_ENTRY,              ENTRY,                -1)
    Character.edit_action_parameters(CONKER, 0xE3,                      File.CONKER_USP_START_AIR,      USP_GROUND,                 0x00000000)
    Character.edit_action_parameters(CONKER, 0xE4,                      File.CONKER_USP_START_AIR,      USP,                        0x00000000)
    Character.edit_action_parameters(CONKER, 0xE6,                      File.CONKER_USP_LOOP_AIR,       USP_DESCENT_LOOP,           0x00000000)
    Character.edit_action_parameters(CONKER, 0xEC,                      File.CONKER_DSP_GROUND,         DSP_GROUND,                 -1)
    Character.edit_action_parameters(CONKER, 0xEF,                      File.CONKER_DSP_GROUND_FAIL,    DSP_FAIL,                   0x00000000)
    Character.edit_action_parameters(CONKER, 0xF1,                      File.CONKER_DSP_AIR,            DSP_GROUND,                 -1)
    Character.edit_action_parameters(CONKER, 0xF5,                      File.CONKER_DSP_AIR_FAIL,       DSP_FAIL,                   0x00000000)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(CONKER, 0xE3,             -1,            ConkerUSP.main_air,          ConkerUSP.ground_y_velocity_,   ConkerUSP.air_physics_,         0x8015DD58)
    Character.edit_action(CONKER, 0xE4,             -1,            ConkerUSP.main_air,          0,                              ConkerUSP.air_physics_,         0x8015DD58)
    Character.edit_action(CONKER, 0xE6,             -1,            ConkerUSP.descent_main_air,  0,                              ConkerUSP.descent_air_physics_2, 0x8015DD58)
    Character.edit_action(CONKER, 0xEC,             -1,            ConkerDSP.main,              0,                              0x800D8CCC,                     ConkerDSP.ground_collision)
    Character.edit_action(CONKER, 0xEF,             -1,            0x800D94C4,                  0x00000000,                     0x800D8CCC,                     ConkerDSP.ground_collision_fail)
    Character.edit_action(CONKER, 0xF1,             -1,            ConkerDSP.main,              0,                              0x800D90E0,                     ConkerDSP.air_collision)
    Character.edit_action(CONKER, 0xF5,             -1,            0x800D94E8,                  0x00000000,                     0x800D90E0,                     ConkerDSP.air_collision_fail)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(CONKER, 0x0,              File.CONKER_IDLE,           PLACEHOLDER,                -1)
    Character.edit_menu_action_parameters(CONKER, 0x1,              File.CONKER_VICTORY1,       VICTORY1,                   -1)
    Character.edit_menu_action_parameters(CONKER, 0x2,              File.CONKER_VICTORY2,       VICTORY2,                   -1)
    Character.edit_menu_action_parameters(CONKER, 0x3,              File.CONKER_SELECTED,       SELECTED,                   -1)
    Character.edit_menu_action_parameters(CONKER, 0x4,              File.CONKER_SELECTED,       SELECTED,                   -1)
    Character.edit_menu_action_parameters(CONKER, 0x5,              File.CONKER_CLAP,           CLAP,                       -1)
    Character.edit_menu_action_parameters(CONKER, 0x9,              File.CONKER_PUPPET_FALL,    -1,                         -1)
    Character.edit_menu_action_parameters(CONKER, 0xA,              File.CONKER_PUPPET_UP,      -1,                         -1)
    Character.edit_menu_action_parameters(CONKER, 0xD,              File.CONKER_1P,             ONEP,                       -1)
    Character.edit_menu_action_parameters(CONKER, 0xE,              File.CONKER_1P_CPU_POSE,    -1,                         -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(CONKER, NSP_Ground_Begin,   -1,             File.CONKER_NSPG_BEGIN,     NSP_BEGIN,                  0)
    Character.add_new_action_params(CONKER, NSP_Ground_Wait,    -1,             File.CONKER_NSPG_WAIT,      NSP_WAIT,                   0)
    Character.add_new_action_params(CONKER, NSP_Ground_End,     -1,             File.CONKER_NSPG_END,       NSP_END,                    0)
    Character.add_new_action_params(CONKER, NSP_Air_Begin,      -1,             File.CONKER_NSPA_BEGIN,     NSP_BEGIN,                  0)
    Character.add_new_action_params(CONKER, NSP_Air_Wait,       -1,             File.CONKER_NSPA_WAIT,      NSP_WAIT,                   0)
    Character.add_new_action_params(CONKER, NSP_Air_End,        -1,             File.CONKER_NSPA_END,       NSP_END,                    0)

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(CONKER, NSP_Ground_Begin,  -1,             ActionParams.NSP_Ground_Begin,      0x12,           ConkerNSP.ground_begin_main_,   0,                              0x800D8BB4,                         ConkerNSP.ground_collision_)
    Character.add_new_action(CONKER, NSP_Ground_Wait,   -1,             ActionParams.NSP_Ground_Wait,       0x12,           ConkerNSP.ground_wait_main_,    0,                              0x800D8BB4,                         ConkerNSP.ground_collision_)
    Character.add_new_action(CONKER, NSP_Ground_End,    -1,             ActionParams.NSP_Ground_End,        0x12,           ConkerNSP.end_main_,            0,                              0x800D8BB4,                         ConkerNSP.ground_collision_)
    Character.add_new_action(CONKER, NSP_Air_Begin,     -1,             ActionParams.NSP_Air_Begin,         0x12,           ConkerNSP.air_begin_main_,      0,                              0x800D90E0,                         ConkerNSP.air_collision_)
    Character.add_new_action(CONKER, NSP_Air_Wait,      -1,             ActionParams.NSP_Air_Wait,          0x12,           ConkerNSP.air_wait_main_,       0,                              0x800D90E0,                         ConkerNSP.air_collision_)
    Character.add_new_action(CONKER, NSP_Air_End,       -1,             ActionParams.NSP_Air_End,           0x12,           ConkerNSP.end_main_,            0,                              0x800D90E0,                         ConkerNSP.air_collision_end_)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.CONKER, 0x2)
    dh  0x054C
    OS.patch_end()

    // Adds Greg's Hand to entry.
    Character.table_patch_start(entry_script, Character.id.CONKER, 0x4)
    dw 0x8013DD14                          // routine typically used by Captain Falcon to load Blue Falcon, now used for Greg's Hand
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.CONKER, 0x4)
    float32 0.8
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.CONKER, 0x4)
    dw      ConkerNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.CONKER, 0x4)
    dw      ConkerNSP.ground_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.CONKER, 0x4)
    dw      ConkerDSP.initial_
    OS.patch_end()

    Character.table_patch_start(air_dsp, Character.id.CONKER, 0x4)
    dw      ConkerDSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.CONKER, 0x4)
    dw      ConkerUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_usp, Character.id.CONKER, 0x4)
    dw      ConkerUSP.ground_initial_
    OS.patch_end()

    // Set Kirby copy power and hat_id
    Character.table_patch_start(kirby_inhale_struct, Character.id.CONKER, 0xC)
    dh Character.id.CONKER
    dh 0x19
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.CONKER, 0, 1, 4, 5, 2, 0, 3)
    Teams.add_team_costume(YELLOW, CONKER, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(CONKER, AZURE, PINK, RED, GREEN, BLACK, WHITE, YELLOW, NA)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.CONKER, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, BAIR,   -1,  12,   16,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  8,   23,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  20,  134, -10, 500, -500, 500)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  20,  134, -10, 500, -500, 500)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  9,   16,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  6,   9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  9,   14,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  7,   14,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,  -1,  -1, -1, -1, -1) // todo: check range
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  2,   3,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  4,   31,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  19,  47,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  19,  47,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  5,   13,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  3,   59,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  3,   59,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  9,   30,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,   13,  -1, -1, -1, -1)

	// Prevents Conker from using grenade when it can't be used
    Character.table_patch_start(ai_attack_prevent, Character.id.CONKER, 0x4)
    dw	AI.PREVENT_ATTACK.ROUTINE.CONKER_GRENADE
    OS.patch_end()

    // @ Description
    // Conker's extra actions
    scope Action {
        constant JabLoopStart(0x0DC)
        constant JabLoop(0x0DD)
        constant JabLoopEnd(0x0DE)
        constant Appear1(0x0DF)
        constant Appear2(0x0E0)
        //constant Laser(0x0E1)
        //constant LaserAir(0x0E2)
        constant HelicopteryTailThing(0x0E3)
        constant HelicopteryTailThingAir(0x0E4)
        //constant ReadyingFireFox(0x0E5)
        constant HelicopteryTailThingDescent(0x0E6)
        //constant FireFox(0x0E7)
        //constant FireFoxAir(0x0E8)
        //constant FireFoxEnd(0x0E9)
        //constant FireFoxEndAir(0x0EA)
        //constant LandingFireFoxAir(0x0EB)
        constant GrenadeToss(0x0EC)
        //constant Reflecting(0x0ED)
        //constant Shine1(0x0EE)
        constant GrenadeTossFail(0x0EF)
        //constant ShineSwitchDirection(0x0F0)
        constant GrenadeTossAir(0x0F1)
        // constant ?(0x0F2)
        //constant ShineEndAir(0x0F3)
        //constant ShineAir(0x0F4)
        constant GrenadeTossFailAir(0x0F5)
        constant CatapultStart(0x0F6)
        constant CatapultCharge(0x0F7)
        constant CatapultShoot(0x0F8)
        constant CatapultStartAir(0x0F9)
        constant CatapultChargeAir(0x0FA)
        constant CatapultShootAir(0x0FB)

        // strings!
        //string_0x0DC:; String.insert("JabLoopStart")
        //string_0x0DD:; String.insert("JabLoop")
        //string_0x0DE:; String.insert("JabLoopEnd")
        //string_0x0DF:; String.insert("Appear1")
        //string_0x0E0:; String.insert("Appear2")
        //string_0x0E1:; String.insert("Laser")
        //string_0x0E2:; String.insert("LaserAir")
        string_0x0E3:; String.insert("HelicopteryTailThing")
        string_0x0E4:; String.insert("HelicopteryTailThingAir")
        //string_0x0E5:; String.insert("ReadyingFireFox")
        string_0x0E6:; String.insert("HelicopteryTailThingDescent")
        //string_0x0E7:; String.insert("FireFox")
        //string_0x0E8:; String.insert("FireFoxAir")
        //string_0x0E9:; String.insert("FireFoxEnd")
        //string_0x0EA:; String.insert("FireFoxEndAir")
        //string_0x0EB:; String.insert("LandingFireFoxAir")
        string_0x0EC:; String.insert("GrenadeToss")
        //string_0x0ED:; String.insert("Reflecting")
        //string_0x0EE:; String.insert("Shine1")
        string_0x0EF:; String.insert("GrenadeTossFail")
        //string_0x0F0:; String.insert("ShineSwitchDirection")
        string_0x0F1:; String.insert("GrenadeTossAir")
        // string_0x0F2:; String.insert("?")
        //string_0x0F3:; String.insert("ShineEndAir")
        //string_0x0F4:; String.insert("ShineAir")
        string_0x0F5:; String.insert("GrenadeTossFailAir")
        string_0x0F6:; String.insert("CatapultStart")
        string_0x0F7:; String.insert("CatapultCharge")
        string_0x0F8:; String.insert("CatapultShoot")
        string_0x0F9:; String.insert("CatapultStartAir")
        string_0x0FA:; String.insert("CatapultChargeAir")
        string_0x0FB:; String.insert("CatapultShootAir")

        action_string_table:
        dw Action.COMMON.string_jabloopstart
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw 0 //dw string_0x0E1
        dw 0 //dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw 0 //dw string_0x0E5
        dw string_0x0E6
        dw 0 //dw string_0x0E7
        dw 0 //dw string_0x0E8
        dw 0 //dw string_0x0E9
        dw 0 //dw string_0x0EA
        dw 0 //dw string_0x0EB
        dw string_0x0EC
        dw 0 //dw string_0x0ED
        dw 0 //dw string_0x0EE
        dw string_0x0EF
        dw 0 //dw string_0x0F0
        dw string_0x0F1
        dw 0 //dw string_0x0F2
        dw 0 //dw string_0x0F3
        dw 0 //dw string_0x0F4
        dw string_0x0F5
        dw string_0x0F6
        dw string_0x0F7
        dw string_0x0F8
        dw string_0x0F9
        dw string_0x0FA
        dw string_0x0FB
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.CONKER, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.CONKER, 0x2)
    dh  0x005E
    OS.patch_end()
    
    Character.table_patch_start(variants, Character.id.CONKER, 0x4)
    db      Character.id.NONE
    db      Character.id.NCONKER
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()
}
