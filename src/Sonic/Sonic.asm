// Sonic.asm

// This file contains file inclusions, action edits, and assembly for Sonic.

scope Sonic {
    // Insert Moveset files
    insert SHOW_MODEL,"moveset/SHOW_MODEL.bin"

    insert IDLE,"moveset/IDLE.bin"; Moveset.GO_TO(IDLE)            // loops
    insert RUN,"moveset/RUN.bin"; Moveset.GO_TO(RUN)            // loops
    insert RUNSTOP,"moveset/RUNSTOP.bin"
    insert TURNRUN,"moveset/TURNRUN.bin"
    insert JUMP,"moveset/JUMP.bin"
    insert JUMP_2,"moveset/JUMP_2.bin"
    insert TEETERING, "moveset/TEETERING.bin"

    insert DAMAGED_FACE,"moveset/DAMAGED_FACE.bin"
    DMG_1:; Moveset.SUBROUTINE(DAMAGED_FACE); dw 0
    DMG_2:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0x180); dw 0
    FALCON_DIVE_PULLED:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF44); dw 0
    UNKNOWN_0B4:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF58); dw 0
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)   // loops

    insert DOWNBOUNCE, "moveset/DOWNBOUNCE.bin"
    insert DOWNATTACKU,"moveset/DOWNATTACKU.bin"
    insert TECH_STAND,"moveset/TECH_STAND.bin"
    insert TECH_ROLL,"moveset/TECH_ROLL.bin"
    insert FROLL, "moveset/FROLL.bin"
    insert BROLL, "moveset/BROLL.bin"

    EDGEATTACKF:; Moveset.CONCURRENT_STREAM(EDGE_ATTACK_CONCURRENT); insert "moveset/EDGE_ATTACK_F.bin"
    EDGE_ATTACK_CONCURRENT:
    dw 0x04000004; dw 0xA8000000; dw 0xA0300001     // wait 4 frames then show ball model
    dw 0x04000007; Moveset.SUBROUTINE(SHOW_MODEL)   // wait 7 frames then show full model
    dw 0                                            // terminate moveset commands
    insert CLIFF_ESCAPE2, "moveset/CLIFFESCAPE2.bin"

    insert FTHROW_DATA,"moveset/FTHROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert BTHROW_DATA,"moveset/BTHROW_DATA.bin"
    BTHROW:; Moveset.CONCURRENT_STREAM(BTHROW_CONCURRENT); Moveset.THROW_DATA(BTHROW_DATA); insert "moveset/BTHROW.bin"
    BTHROW_CONCURRENT:
    dw 0x0800000D;                                  // after 14 frames
    dw 0x80000007                                   // begin a loop with 7 iterations
    dw 0xA8000000; dw 0xA0300001; dw 0x04000003     // show ball model and wait 3 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000003   // show full model and wait 3 frames
    dw 0x84000000; dw 0                             // end loop and terminate moveset commands

    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB1,"moveset/JAB1.bin"
    insert JAB2,"moveset/JAB2.bin"
    insert JAB3,"moveset/JAB3.bin"
    DASH_ATTACK:; Moveset.CONCURRENT_STREAM(DASH_ATTACK_CONCURRENT); insert "moveset/DASH_ATTACK.bin"
    DASH_ATTACK_CONCURRENT:
    dw 0x04000005; dw 0xA8000000; dw 0xA0300002     // wait 5 frames then show ball model
    dw 0x04000009; Moveset.SUBROUTINE(SHOW_MODEL)   // wait 9 frames then show full model
    dw 0x80000002                                   // begin a loop with 2 iterations
    dw 0x04000003; dw 0xA8000000; dw 0xA0300001     // show ball model and wait 3 frames
    dw 0x04000003; Moveset.SUBROUTINE(SHOW_MODEL)   // show full model and wait 3 frames
    dw 0x84000000; dw 0                             // end loop and terminate moveset commands
    insert UTILT,"moveset/UTILT.bin"
    insert DTILT,"moveset/DTILT.bin"
    insert FTILT,"moveset/FTILT.bin"
    insert FTILT_HIGH,"moveset/FTILT_HIGH.bin"
    insert FTILT_LOW,"moveset/FTILT_LOW.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DSMASH.bin"
    insert FSMASH_HIGH,"moveset/FSMASH_HIGH.bin"
    insert FSMASH_MID_HIGH,"moveset/FSMASH_MID_HIGH.bin"
    insert FSMASH,"moveset/FSMASH.bin"
    insert FSMASH_MID_LOW,"moveset/FSMASH_MID_LOW.bin"
    insert FSMASH_LOW,"moveset/FSMASH_LOW.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"


    insert USP,"moveset/USP.bin"
    insert DSP_CHARGE,"moveset/DSP_CHARGE.bin"
    insert DSP_AIR_CHARGE,"moveset/DSP_AIR_CHARGE.bin"
    DSP_MOVE:; Moveset.CONCURRENT_STREAM(DSP_FLICKER_LOOP); insert "moveset/DSP_MOVE.bin"
    DSP_AIR_MOVE:; Moveset.CONCURRENT_STREAM(DSP_FLICKER_END); insert "moveset/DSP_AIR_MOVE.bin"
    DSP_AIR_JUMP:; Moveset.CONCURRENT_STREAM(DSP_FLICKER_END); insert "moveset/DSP_AIR_JUMP.bin"
    DSP_FLICKER_LOOP:
    dw 0xA8000000; dw 0xA0300001; dw 0x04000003     // show ball model and wait 3 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000003   // show full model and wait 3 frames
    Moveset.GO_TO(DSP_FLICKER_LOOP)                 // loops
    DSP_FLICKER_END:
    dw 0x80000006                                   // begin a loop with 6 iterations
    dw 0xA8000000; dw 0xA0300001; dw 0x04000003     // show ball model and wait 3 frames
    Moveset.SUBROUTINE(SHOW_MODEL); dw 0x04000003   // show full model and wait 3 frames
    dw 0x84000000; dw 0                             // end loop and terminate moveset commands
    insert NSP_CHARGE,"moveset/NSP_CHARGE.bin"
    insert NSP_MOVE,"moveset/NSP_MOVE.bin"
    insert NSP_BOUNCE,"moveset/NSP_BOUNCE.bin"

    insert TAILS_LOOP,"moveset/TAILS_LOOP.bin"
    ENTRY:; Moveset.CONCURRENT_STREAM(TAILS_LOOP); insert "moveset/ENTRY.bin"
    insert CLAP,"moveset/CLAP.bin"
    insert CSS,"moveset/CSS.bin"
    insert VICTORY,"moveset/VICTORY.bin"
    insert SPPOSE,"moveset/SPPOSE.bin"
    insert VICTORY1,"moveset/VICTORY1.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(SONIC, Action.Idle,            File.SONIC_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(SONIC, 0x06,                   File.SONIC_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(SONIC, Action.Entry,           File.SONIC_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(SONIC, Action.ReviveWait,      File.SONIC_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(SONIC, Action.EggLay,          File.SONIC_IDLE,            IDLE,                       -1)
    Character.edit_action_parameters(SONIC, Action.Tech,            File.SONIC_TECH,            TECH_STAND,                 -1)
    Character.edit_action_parameters(SONIC, Action.TechF,           File.SONIC_TECHF,           TECH_ROLL,                  -1)
    Character.edit_action_parameters(SONIC, Action.TechB,           File.SONIC_TECHB,           TECH_ROLL,                  -1)
    Character.edit_action_parameters(SONIC, Action.RollF,           -1,                         FROLL,                      -1)
    Character.edit_action_parameters(SONIC, Action.RollB,           -1,                         BROLL,                      -1)
    Character.edit_action_parameters(SONIC, Action.CliffCatch,      File.SONIC_CLIFF_CATCH,     -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.CliffSlow,       File.SONIC_CLIFF_SLOW,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.CliffWait,       File.SONIC_CLIFF_WAIT,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.CliffQuick,      File.SONIC_CLIFF_QUICK,     -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.CliffClimbQuick1, File.SONIC_CLIFF_CLIMB_QUICK1, -1,                     -1)
    Character.edit_action_parameters(SONIC, Action.CliffClimbQuick2, File.SONIC_CLIFF_CLIMB_QUICK2, -1,                     -1)
    Character.edit_action_parameters(SONIC, Action.CliffAttackQuick1, File.SONIC_CLIFF_CLIMB_QUICK1, -1,                    -1)
    Character.edit_action_parameters(SONIC, Action.CliffAttackQuick2, File.SONIC_CLIFF_ATTACK_QUICK2, EDGEATTACKF,          -1)
    Character.edit_action_parameters(SONIC, Action.CliffEscapeQuick1, File.SONIC_CLIFF_CLIMB_QUICK1, -1,                    -1)
    Character.edit_action_parameters(SONIC, Action.CliffEscapeQuick2, File.SONIC_CLIFF_ESCAPE_QUICK2, -1,                   -1)
    Character.edit_action_parameters(SONIC, Action.CliffEscapeSlow2, -1,                        CLIFF_ESCAPE2,              -1)
    Character.edit_action_parameters(SONIC, Action.ShieldBreak,     -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(SONIC, Action.DeadU,           File.SONIC_TUMBLE,          DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.ScreenKO,        File.SONIC_TUMBLE,          DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.Tumble,          File.SONIC_TUMBLE,          DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.WallBounce,      File.SONIC_TUMBLE,          DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.Tornado,         File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.ShieldBreakFall, File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.EggLayPulled,    -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.InhalePulled,    File.SONIC_TUMBLE,          DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.InhaleSpat,      File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.InhaleCopied,    File.SONIC_TUMBLE,          -1,                         -1)
    Character.edit_action_parameters(SONIC, 0xB4,                   File.SONIC_TUMBLE,          UNKNOWN_0B4,                -1)
    Character.edit_action_parameters(SONIC, Action.FalconDivePulled, -1,                        FALCON_DIVE_PULLED,         -1)
    Character.edit_action_parameters(SONIC, Action.ThrownDK,        -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.ThrownDKPulled,  -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.ThrownMarioBros, -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.CapturePulled,   -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.Thrown1,         -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.Thrown2,         -1,                         DMG_1,                      -1)

    Character.edit_action_parameters(SONIC, Action.Stun,            File.SONIC_STUN,            STUN,                       -1)
    Character.edit_action_parameters(SONIC, Action.Sleep,           File.SONIC_STUN,            ASLEEP,                     -1)
    Character.edit_action_parameters(SONIC, Action.ShieldDrop,      File.SONIC_SHIELD_DROP,     -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Pass,            File.SONIC_SHIELD_DROP,     -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Crouch,          File.SONIC_CROUCH,          -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.CrouchIdle,      File.SONIC_CROUCH_IDLE,     -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.CrouchEnd,       File.SONIC_CROUCH_END,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Walk1,           File.SONIC_WALK1,           -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Walk2,           File.SONIC_WALK2,           -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Walk3,           File.SONIC_WALK3,           -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Run,             File.SONIC_RUN,             RUN,                        -1)
    Character.edit_action_parameters(SONIC, Action.RunBrake,        File.SONIC_RUN_BRAKE,       RUNSTOP,                    -1)
    Character.edit_action_parameters(SONIC, Action.TurnRun,         File.SONIC_RUN_TURN,        TURNRUN,                    -1)
    Character.edit_action_parameters(SONIC, Action.JumpF,           File.SONIC_JUMP_F,          JUMP,                       -1)
    Character.edit_action_parameters(SONIC, Action.JumpB,           File.SONIC_JUMP_B,          JUMP,                       -1)
    Character.edit_action_parameters(SONIC, Action.JumpAerialF,     File.SONIC_JUMP_AF,         JUMP_2,                     -1)
    Character.edit_action_parameters(SONIC, Action.JumpAerialB,     File.SONIC_JUMP_AB,         JUMP_2,                     -1)
    Character.edit_action_parameters(SONIC, Action.Fall,            File.SONIC_FALL,            -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.FallAerial,      File.SONIC_FALL2,           -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.JumpSquat,       File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.ShieldJumpSquat, File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.LandingLight,    File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.LandingHeavy,    File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.LandingSpecial,  File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.LandingAirX,     File.SONIC_JUMPSQUAT,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.FallSpecial,     File.SONIC_SFALL,           -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Taunt,           File.SONIC_TAUNT,           TAUNT,                      -1)
    Character.edit_action_parameters(SONIC, Action.Grab,            File.SONIC_GRAB,            -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.GrabPull,        File.SONIC_GRAB_PULL,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.ThrowF,          File.SONIC_THROWF,          FTHROW,                     -1)
    Character.edit_action_parameters(SONIC, Action.ThrowB,          File.SONIC_THROWB,          BTHROW,                     -1)
    Character.edit_action_parameters(SONIC, Action.Jab1,            File.SONIC_JAB1,            JAB1,                       -1)
    Character.edit_action_parameters(SONIC, Action.Jab2,            File.SONIC_JAB2,            JAB2,                       -1)
    Character.edit_action_parameters(SONIC, 0xDC,                   File.SONIC_JAB3,            JAB3,                       -1)
    Character.edit_action_parameters(SONIC, Action.DashAttack,      File.SONIC_DASH_ATTACK,     DASH_ATTACK,                -1)
    Character.edit_action_parameters(SONIC, Action.FTiltHigh,       File.SONIC_FTILT_HIGH,      FTILT_HIGH,                 -1)
    Character.edit_action_parameters(SONIC, Action.FTiltMidHigh,    0,                          0x80000000,                  0)
    Character.edit_action_parameters(SONIC, Action.FTilt,           File.SONIC_FTILT,           FTILT,                      -1)
    Character.edit_action_parameters(SONIC, Action.FTiltMidLow,     0,                          0x80000000,                  0)
    Character.edit_action_parameters(SONIC, Action.FTiltLow,        File.SONIC_FTILT_LOW,       FTILT_LOW,                  -1)
    Character.edit_action_parameters(SONIC, Action.UTilt,           File.SONIC_UTILT,           UTILT,                      -1)
    Character.edit_action_parameters(SONIC, Action.DTilt,           File.SONIC_DTILT,           DTILT,                      -1)
    Character.edit_action_parameters(SONIC, Action.FSmashHigh,      File.SONIC_FSMASH_HIGH,     FSMASH_HIGH,                0x00000000)
    Character.edit_action_parameters(SONIC, Action.FSmashMidHigh,   File.SONIC_FSMASH_MID_HIGH, FSMASH_MID_HIGH,            0x00000000)
    Character.edit_action_parameters(SONIC, Action.FSmash,          File.SONIC_FSMASH,          FSMASH,                     0x00000000)
    Character.edit_action_parameters(SONIC, Action.FSmashMidLow,    File.SONIC_FSMASH_MID_LOW,  FSMASH_MID_LOW,             0x00000000)
    Character.edit_action_parameters(SONIC, Action.FSmashLow,       File.SONIC_FSMASH_LOW,      FSMASH_LOW,                 0x00000000)
    Character.edit_action_parameters(SONIC, Action.USmash,          File.SONIC_USMASH,          USMASH,                     -1)
    Character.edit_action_parameters(SONIC, Action.DSmash,          File.SONIC_DSMASH,          DSMASH,                     -1)
    Character.edit_action_parameters(SONIC, Action.AttackAirN,      File.SONIC_NAIR,            NAIR,                       -1)
    Character.edit_action_parameters(SONIC, Action.AttackAirF,      File.SONIC_FAIR,            FAIR,                       -1)
    Character.edit_action_parameters(SONIC, Action.AttackAirB,      File.SONIC_BAIR,            BAIR,                       -1)
    Character.edit_action_parameters(SONIC, Action.AttackAirU,      File.SONIC_UAIR,            UAIR,                       -1)
    Character.edit_action_parameters(SONIC, Action.AttackAirD,      File.SONIC_DAIR,            DAIR,                       -1)
    Character.edit_action_parameters(SONIC, Action.EnterPipe,       File.SONIC_ENTER_PIPE,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.ExitPipe,        File.SONIC_EXIT_PIPE,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.DownStandU,      File.SONIC_DOWNSTANDU,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.StunStartU,      File.SONIC_DOWNSTANDU,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.Revive2,         File.SONIC_DOWNSTANDU,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.DownStandD,      File.SONIC_DOWNSTANDD,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.StunStartD,      File.SONIC_DOWNSTANDD,      -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.DownBounceU,     -1,                         DOWNBOUNCE,                 -1)
    Character.edit_action_parameters(SONIC, Action.DownBounceD,     -1,                         DOWNBOUNCE,                 -1)
    Character.edit_action_parameters(SONIC, Action.DownAttackU,     File.SONIC_DOWNATTACKU,     DOWNATTACKU,                         -1)
    Character.edit_action_parameters(SONIC, Action.DownBackU,       File.SONIC_DOWNBACKU,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.DownBackD,       File.SONIC_DOWNBACKD,       -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.DownForwardD,    File.SONIC_DOWNFORWARDD,    -1,                         -1)
    Character.edit_action_parameters(SONIC, Action.DownForwardU,    File.SONIC_DOWNFORWARDU,    -1,                         -1)
    Character.edit_action_parameters(SONIC, 0xE4,                   File.SONIC_USP_SPRING,      USP,                        0x00000000)

    Character.edit_action_parameters(SONIC, Action.Teeter,          File.SONIC_TEETER,          TEETERING,                  -1)
    Character.edit_action_parameters(SONIC, Action.TeeterStart,     File.SONIC_TEETER_START,    -1,                         -1)

    Character.edit_action_parameters(SONIC, 0xDF,                   File.SONIC_ENTRY_RIGHT,     ENTRY,                      -1)
    Character.edit_action_parameters(SONIC, 0xE0,                   File.SONIC_ENTRY_LEFT,      ENTRY,                      -1)

    Character.edit_action_parameters(SONIC, Action.DamageHigh1,     -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageHigh2,     -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageHigh3,     -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageMid1,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageMid2,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageMid3,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageLow1,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageLow2,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageLow3,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageAir1,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageAir2,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageAir3,      -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageElec1,     -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageElec2,     -1,                         DMG_1,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageFlyHigh,   -1,                         DMG_2,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageFlyMid,    -1,                         DMG_2,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageFlyLow,    -1,                         DMG_2,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageFlyTop,    -1,                         DMG_2,                      -1)
    Character.edit_action_parameters(SONIC, Action.DamageFlyRoll,   -1,                         DMG_2,                      -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(SONIC,  DSP_Ground_Charge,  -1,             File.SONIC_CHARGE_LOOP,     DSP_CHARGE,                 0)
    Character.add_new_action_params(SONIC,  DSP_Ground_Move,    -1,             File.SONIC_SPIN_LOOP_FAST,  DSP_MOVE,                   0x10000000)
    Character.add_new_action_params(SONIC,  DSP_Ground_End,     -1,             File.SONIC_CROUCH_END,      0x80000000,                 0)
    Character.add_new_action_params(SONIC,  DSP_Air_Charge,     -1,             File.SONIC_CHARGE_LOOP,     DSP_AIR_CHARGE,             0)
    Character.add_new_action_params(SONIC,  DSP_Air_Move,       -1,             File.SONIC_JUMP_F,          DSP_AIR_MOVE,               0)
    Character.add_new_action_params(SONIC,  DSP_Air_Jump,       -1,             File.SONIC_JUMP_F,          DSP_AIR_JUMP,               0)
    Character.add_new_action_params(SONIC,  DSP_Air_End,        -1,             File.SONIC_NSP_FINISH,      0x80000000,                 0)
    Character.add_new_action_params(SONIC,  NSP_Begin,          -1,             File.SONIC_SPIN_LOOP,       NSP_CHARGE,                 0)
    Character.add_new_action_params(SONIC,  NSP_Move,           -1,             File.SONIC_SPIN_LOOP_FAST,  NSP_MOVE,                   0x10000000)
    Character.add_new_action_params(SONIC,  NSP_Locked_Move,    -1,             File.SONIC_SPIN_LOOP_FAST,  NSP_MOVE,                   0x10000000)
    Character.add_new_action_params(SONIC,  NSP_Ground_End,     -1,             File.SONIC_NSP_GROUND_END,  0x80000000,                 0)
    Character.add_new_action_params(SONIC,  NSP_Air_End,        -1,             File.SONIC_JUMP_F,          0x80000000,                 0)
    Character.add_new_action_params(SONIC,  NSP_Ground_Recoil,  -1,             File.SONIC_NSP_GROUND_RECOIL, 0x80000000,               0)
    Character.add_new_action_params(SONIC,  NSP_Air_Recoil,     -1,             File.SONIC_JUMP_B,          0x80000000,                 0)
    Character.add_new_action_params(SONIC,  NSP_Bounce,         -1,             File.SONIC_JUMP_F,          NSP_BOUNCE,                 0)


    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(SONIC, 0xDC,              -1,             0x8014FE40,                 0x00000000,                     0x800D8CCC,                     0x800DDF44)
    Character.edit_action(SONIC, 0xE4,              -1,             SonicUSP.main_air_,         SonicUSP.interrupt_,            SonicUSP.air_physics_,          0x800DE99C)
    //Character.edit_action(SONIC, 0xEA,              -1,             0x00000000,                 SonicUSP.special_fall_interrupt_, -1,                           0x800DE99C)
    //Character.edit_action(SONIC, 0xDF,              -1,             0x00000000,               0x00000000,                     0x00000000,                     0x00000000)
    //Character.edit_action(SONIC, 0xE0,              -1,             0x00000000,               0x00000000,                     0x00000000,                     0x00000000)

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(SONIC,  DSP_Ground_Charge, -1,             ActionParams.DSP_Ground_Charge,     0x1E,           SonicDSP.ground_charge_main_,   0,                              0x800D8BB4,                         SonicDSP.ground_charge_collision_)
    Character.add_new_action(SONIC,  DSP_Ground_Move,   -1,             ActionParams.DSP_Ground_Move,       0x1E,           SonicDSP.ground_move_main_,     0,                              SonicDSP.ground_move_physics_,      SonicDSP.ground_move_collision_)
    Character.add_new_action(SONIC,  DSP_Ground_End,    -1,             ActionParams.DSP_Ground_End,        0x1E,           0x800D94C4,                     0,                              0x800D8BB4,                         SonicDSP.ground_end_collision_)
    Character.add_new_action(SONIC,  DSP_Air_Charge,    -1,             ActionParams.DSP_Air_Charge,        0x1E,           SonicDSP.air_charge_main_,      0,                              0x800D91EC,                         SonicDSP.air_charge_collision_)
    Character.add_new_action(SONIC,  DSP_Air_Move,      -1,             ActionParams.DSP_Air_Move,          0x1E,           SonicDSP.air_move_main_,        SonicDSP.air_move_interrupt_,   SonicDSP.air_movement_physics_,     SonicDSP.air_move_collision_)
    Character.add_new_action(SONIC,  DSP_Air_Jump,      -1,             ActionParams.DSP_Air_Jump,          0x1E,           SonicDSP.air_move_main_,        SonicDSP.air_move_interrupt_,   SonicDSP.air_movement_physics_,     SonicDSP.air_move_collision_)
    Character.add_new_action(SONIC,  DSP_Air_End,       -1,             ActionParams.DSP_Air_End,           0x1E,           0x800D94E8,                     0,                              0x800D91EC,                         SonicDSP.air_end_collision_)
    Character.add_new_action(SONIC,  NSP_Begin,         -1,             ActionParams.NSP_Begin,             0x12,           SonicNSP.begin_main_,           0,                              0,                                  0x800DE6B0)
    Character.add_new_action(SONIC,  NSP_Move,          -1,             ActionParams.NSP_Move,              0x12,           SonicNSP.move_main_,            0,                              SonicNSP.move_physics_,             SonicNSP.move_collision_)
    Character.add_new_action(SONIC,  NSP_Locked_Move,   -1,             ActionParams.NSP_Locked_Move,       0x12,           SonicNSP.move_main_,            0,                              SonicNSP.move_physics_,             SonicNSP.move_collision_)
    Character.add_new_action(SONIC,  NSP_Ground_End,    -1,             ActionParams.NSP_Ground_End,        0x12,           0x800D94C4,                     0,                              0x800D8BB4,                         SonicNSP.ground_end_collision_)
    Character.add_new_action(SONIC,  NSP_Air_End,       -1,             ActionParams.NSP_Air_End,           0x12,           0x800D94E8,                     0,                              0x800D91EC,                         SonicNSP.air_end_collision_)
    Character.add_new_action(SONIC,  NSP_Ground_Recoil, -1,             ActionParams.NSP_Ground_Recoil,     0x12,           0x800D94C4,                     0,                              0x800D8BB4,                         SonicNSP.ground_recoil_collision_)
    Character.add_new_action(SONIC,  NSP_Air_Recoil,    -1,             ActionParams.NSP_Air_Recoil,        0x12,           0x800D94E8,                     0,                              0x800D91EC,                         SonicNSP.air_recoil_collision_)
    Character.add_new_action(SONIC,  NSP_Bounce,        -1,             ActionParams.NSP_Bounce,            0x12,           0x800D94E8,                     0,                              0x800D91EC,                         0x800DE99C)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(SONIC, 0x0,               File.SONIC_IDLE,            IDLE,                       -1)
    Character.edit_menu_action_parameters(SONIC, 0x1,               File.SONIC_VICTORY1,        VICTORY1,                 -1)
    Character.edit_menu_action_parameters(SONIC, 0x2,               File.SONIC_VICTORY2,        0x80000000,                 -1)
    Character.edit_menu_action_parameters(SONIC, 0x3,               File.SONIC_CSS,             CSS,                 -1)
    Character.edit_menu_action_parameters(SONIC, 0x4,               File.SONIC_CSS,             CSS,                 -1)
    Character.edit_menu_action_parameters(SONIC, 0x5,               File.SONIC_CLAP,            CLAP,                       -1)
    Character.edit_menu_action_parameters(SONIC, 0x9,               File.SONIC_PUPPET_FALL,     -1,                         -1)
    Character.edit_menu_action_parameters(SONIC, 0xA,               File.SONIC_PUPPET_UP,       -1,                         -1)
    Character.edit_menu_action_parameters(SONIC, 0xD,               File.SONIC_1P_POSE,         SPPOSE,                 -1)
    Character.edit_menu_action_parameters(SONIC, 0xE,               File.SONIC_1P_CPU_POSE,     0x80000000,                 -1)

    Character.table_patch_start(variants, Character.id.SONIC, 0x4)
    db      Character.id.SSONIC // set as SPECIAL variant for SONIC
    db      Character.id.NSONIC // set as POLYGON variant for SONIC
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.SONIC, 0x4)
    float32 0.95
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.SONIC, 0x2)
    dh  0x03F9
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.SONIC, 0xC)
    dh 0x1D
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.SONIC, 0, 1, 4, 5, 2, 0, 3)

    // Set default costume shield colors
    Character.set_costume_shield_colors(SONIC, BLUE, BLACK, RED, GREEN, PURPLE, YELLOW, BLUE, YELLOW, RED, GREEN, PINK, ORANGE)

    Character.table_patch_start(ground_usp, Character.id.SONIC, 0x4)
    dw      SonicUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.SONIC, 0x4)
    dw      SonicUSP.air_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.SONIC, 0x4)
    dw      SonicNSP.begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.SONIC, 0x4)
    dw      SonicNSP.begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.SONIC, 0x4)
    dw      SonicDSP.ground_charge_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.SONIC, 0x4)
    dw      SonicDSP.air_charge_initial_
    OS.patch_end()

    // Use Mario's initial/grounded script.
    Character.table_patch_start(initial_script, Character.id.SONIC, 0x4)
    dw 0x800D7DCC
    OS.patch_end()
    Character.table_patch_start(grounded_script, Character.id.SONIC, 0x4)
    dw 0x800DE428
    OS.patch_end()

    // Adds Tails to entry.
    Character.table_patch_start(entry_script, Character.id.SONIC, 0x4)
    dw 0x8013DCAC                         // routine typically used by DK to load Barrel, now used for Tails
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.SONIC, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()
	
	// Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.SONIC, 0x4)
    dw    	AI.LONG_RANGE.ROUTINE.NONE
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  4,  41,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  18, 18+47, 50, 1500, -400, 200)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  18, 18+47, 50, 1500, -400, 200)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  8,  20,    -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  5,  10,    -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  7,  14,    -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  17, 22,    -1, 720.0, -1, -1) // less range than Fox
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  7,  12,    -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1, -1,    -1, -1, -1, -1)    // todo: check range
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  3,  7,     -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  4,  27,    -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  21, 21+21, -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  21, 21+21, -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  4,  14,    -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  6,  60,    -60, 60, -200, 40)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  0, 0,    0, 0, 0, 0)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  6,  21,    -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,  11,    -1, -1, -1, -1)

    // Edit cpu attack behaviours
    // edit_attack_behavior(behavior_table_origin, attack_name, new_attack, start_hb_frame, end_hb_frame, min_x,   max_x,   min_y,   max_y)



    // @ Description
    // Sonic's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant Appear1(0x0DF)
        constant Appear2(0x0E0)
        constant Spring(0x0E4)
        constant SpinDashChargeGround(0xF6)
        constant SpinDashGround(0xF7)
        constant SpinDashEndGround(0xF8)
        constant SpinDashChargeAir(0xF9)
        constant SpinDashAir(0xFA)
        constant SpinDashJumpAir(0xFB)
        constant SpinDashendAir(0xFC)
        constant HomingStart(0xFD)
        constant HomingMove(0xFE)
        constant HomingLockedMove(0xFF)
        constant HomingEndGround(0x100)
        constant HomingEndAir(0x101)
        constant HomingRecoilGround(0x102)
        constant HomingRecoilAir(0x103)
        constant HomingBounce(0x104)

        // strings!
        string_0x0E4:; String.insert("Spring")
        string_0xF6:; String.insert("SpinDashChargeGround")
        string_0xF7:; String.insert("SpinDashGround")
        string_0xF8:; String.insert("SpinDashEndGround")
        string_0xF9:; String.insert("SpinDashChargeAir")
        string_0xFA:; String.insert("SpinDashAir")
        string_0xFB:; String.insert("SpinDashJumpAir")
        string_0xFC:; String.insert("SpinDashEndAir")
        string_0xFD:; String.insert("HomingStart")
        string_0xFE:; String.insert("HomingMove")
        string_0xFF:; String.insert("HomingLockedMove")
        string_0x100:; String.insert("HomingEndGround")
        string_0x101:; String.insert("HomingEndAir")
        string_0x102:; String.insert("HomingRecoilGround")
        string_0x103:; String.insert("HomingRecoilAir")
        string_0x104:; String.insert("HomingBounce")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0E4
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0xF6
        dw string_0xF7
        dw string_0xF8
        dw string_0xF9
        dw string_0xFA
        dw string_0xFB
        dw string_0xFC
        dw string_0xFD
        dw string_0xFE
        dw string_0xFF
        dw string_0x100
        dw string_0x101
        dw string_0x102
        dw string_0x103
        dw string_0x104
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.SONIC, 0x4)
    dw  Action.action_string_table
    OS.patch_end()


    // @ Description
    // Patch which loads the current animation frame when swapping to/from Classic Sonic on the character select screen.
    scope handle_select_anim_: {
        OS.patch_start(0x107BBC, 0x803905DC)
        j       handle_select_anim_
        nop
        OS.patch_end()

        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x0008(t5)              // t6 = character id
        lli     at, Character.id.SONIC      // at = id.SONIC
        bne     at, t6, _end                // end if character != SONIC
        nop

        // if the character is Sonic
        li      at, 0x00010004              // at = action id: menu selection
        bne     at, a1, _end                // end if action != menu selection
        lbu     at, 0x000D(t5)              // at = player port

        // if Sonic is beginning the menu selection action
        li      t6, select_anim_frame       // t6 = select_anim_frame
        sll     at, at, 0x2                 // at = port * 4
        addu    t6, t6, at                  // 6t = px select_anim_frame address
        lw      a2, 0x0000(t6)              // a2 = new frame to begin animation on

        _end:
        jal     0x800E6F24                  // original line 1 (change action)
        lui     a3, 0x3F80                  // original line 2 (fsm = 1.0)

        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original lines 3-5
        nop
    }

    // @ Description
    // Patch which swaps Classic Sonic FGM for the 0x3800XXXX (play FGM) moveset command
    scope classic_fgm_patch_1_: {
        OS.patch_start(0x5B074, 0x800DF874)
        j       classic_fgm_patch_1_
        andi    a0, a0, 0xFFFF              // original line 2
        _return:
        OS.patch_end()

        // s1 = player struct, a0 = FGM id
        lli     t6, Character.id.SONIC      // t6 = id.SONIC
        lw      t5, 0x0008(s1)              // t5 = character id
        bne     t6, t5, _end                // end if character id != SONIC
        nop

        // if the character is sonic
        lbu     t6, 0x000D(s1)              // t6 = player port
        li      t5, classic_table           // t5 = classic_table
        addu    t5, t5, t6                  // t5 = classic_table + port
        lbu     t5, 0x0000(t5)              // t5 = px is_classic
        beqz    t5, _end                    // end if px is_clasic = FALSE
        nop

        // if sonic is using the classic model, check for FGM swaps
        lli     t5, 0x3D8                   // t5 = SPINDASH_CHARGE FGM
        beql    t5, a0, _end                // branch if FGM = SPINDASH_CHARGE...
        lli     a0, 0x3DE                   // ...and use CLASSIC_SPINDASH_CHARGE instead

        lli     t5, 0x3D9                   // t5 = SPINDASH_ROLL FGM
        beql    t5, a0, _end                // branch if FGM = SPINDASH_ROLL...
        lli     a0, 0x3E3                   // ...and use CLASSIC_SPINDASH_ATTACK instead

        lli     t5, 0x3DB                   // t5 = HOMING_ATTACK FGM
        beql    t5, a0, _end                // branch if FGM = HOMING_ATTACK...
        lli     a0, 0x3E3                   // ...and use CLASSIC_SPINDASH_ATTACK instead

        lli     t5, 0x3DC                   // t5 = SONIC_JUMP FGM
        beql    t5, a0, _end                // branch if FGM = SONIC_JUMP...
        lli     a0, 0x3E0                   // ...and use CLASSIC_SONIC_JUMP instead

        lli     t5, 0x3DD                   // t5 = SONIC_SKID FGM
        beql    t5, a0, _end                // branch if FGM = CLASSIC_SONIC_SKID...
        lli     a0, 0x3E1                   // ...and use CLASSIC_SONIC_SKID instead

        lli     t5, 0x3FC                   // t5 = SONIC_JUMP_2 FGM
        beql    t5, a0, _end                // branch if FGM = SONIC_JUMP_2...
        lli     a0, 0x3FD                   // ...and use CLASSIC_SONIC_JUMP_2 instead

        _end:
        jal     0x800269C0                  // original line 1
        nop
        j       _return
        nop
    }

    // @ Description
    // Patch which swaps Classic Sonic FGM for the 0x3C00XXXX (play FGM once) moveset command
    scope classic_fgm_patch_2_: {
        OS.patch_start(0x5B0C4, 0x800DF8C4)
        j       classic_fgm_patch_2_
        andi    a1, a1, 0xFFFF              // original line 2
        _return:
        OS.patch_end()

        // s1 = player struct, a1 = FGM id
        lli     t6, Character.id.SONIC      // t6 = id.SONIC
        lw      t5, 0x0008(s1)              // t5 = character id
        bne     t6, t5, _end                // end if character id != SONIC
        nop

        // if the character is sonic
        lbu     t6, 0x000D(s1)              // t6 = player port
        li      t5, classic_table           // t5 = classic_table
        addu    t5, t5, t6                  // t5 = classic_table + port
        lbu     t5, 0x0000(t5)              // t5 = px is_classic
        beqz    t5, _end                    // end if px is_clasic = FALSE
        nop

        // if sonic is using the classic model, check for FGM swaps
        lli     t5, 0x3D8                   // t5 = SPINDASH_CHARGE FGM
        beql    t5, a1, _end                // branch if FGM = SPINDASH_CHARGE...
        lli     a1, 0x3DE                   // ...and use CLASSIC_SPINDASH_CHARGE instead

        lli     t5, 0x3DA                   // t5 = HOMING_CHARGE FGM
        beql    t5, a1, _end                // branch if FGM = HOMING_CHARGE...
        lli     a1, 0x3E2                   // ...and use CLASSIC_SONIC_SPIN instead

        _end:
        jal     0x800E8190                  // original line 1
        nop
        j       _return
        nop
    }

    // @ Description
    // Patch which prevents Classic Sonic from playing FGM with the 0x4400XXXX (play voice FGM) moveset command
    scope classic_voice_patch_1_: {
        OS.patch_start(0x5B140, 0x800DF940)
        j       classic_voice_patch_1_
        andi    a1, a1, 0xFFFF              // original line 2
        _return:
        OS.patch_end()

        // s1 = player struct
        lli     t6, Character.id.SONIC      // t6 = id.SONIC
        lw      t5, 0x0008(s1)              // t5 = character id
        bne     t6, t5, _end                // end if character id != SONIC
        nop

        // if the character is sonic
        lbu     t6, 0x000D(s1)              // t6 = player port
        li      t5, classic_table           // t5 = classic_table
        addu    t5, t5, t6                  // t5 = classic_table + port
        lbu     t5, 0x0000(t5)              // t5 = px is_classic
        bnez    t5, _skip                   // skip if px is_clasic = TRUE
        nop

        _end:
        jal     0x800E80F0                  // original line 1
        nop

        _skip:
        j       _return
        nop
    }

    // @ Description
    // Patch which prevents Classic Sonic from playing FGM with the 0x4800XXXX (play voice FGM once) moveset command
    scope classic_voice_patch_2_: {
        OS.patch_start(0x5B1A4, 0x800DF9A4)
        j       classic_voice_patch_2_
        andi    a1, a1, 0xFFFF              // original line 2
        _return:
        OS.patch_end()

        // s1 = player struct
        lli     t6, Character.id.SONIC      // t6 = id.SONIC
        lw      t5, 0x0008(s1)              // t5 = character id
        bne     t6, t5, _end                // end if character id != SONIC
        nop

        // if the character is sonic
        lbu     t6, 0x000D(s1)              // t6 = player port
        li      t5, classic_table           // t5 = classic_table
        addu    t5, t5, t6                  // t5 = classic_table + port
        lbu     t5, 0x0000(t5)              // t5 = px is_classic
        bnez    t5, _skip                   // skip if px is_clasic = TRUE
        nop

        _end:
        jal     0x800E8190                  // original line 1
        nop

        _skip:
        j       _return
        nop
    }

    // @ Description
    // Patch which allows the spin dash FGM to restart when called using 0x800E8190 (play FGM once)
    scope spin_dash_fgm_patch_: {
        OS.patch_start(0x639A8, 0x800E81A8)
        j       spin_dash_fgm_patch_
        andi    a0, a1, 0xFFFF              // original line 2
        _return:
        OS.patch_end()

        // a0 = FGM id
        // a2 = player struct
        lli     t2, 0x3D8                   // t2 = SPINDASH_CHARGE FGM
        beq     a0, t2, _spin_dash          // branch if FGM id = SPINDASH_CHARGE
        lli     t2, 0x3DE                   // t2 = CLASSIC_SPINDASH_CHARGE FGM
        beq     a0, t2, _spin_dash          // branch if FGM id = SPINDASH_CHARGE
        nop

        bnez    t6, _branch                 // original line 1
        nop
        j       _return                     // return
        nop

        _spin_dash:
        sw      a2, 0x0018(sp)              // 0x0018(sp) = player struct
        jal     0x800E81E4                  // end stored FGM
        or      a0, a2, r0                  // a0 = player struct
        lw      a0, 0x001C(sp)              // ~
        andi    a0, a0, 0xFFFF              // a0 = FGM id
        j       _return                     // return
        lw      a2, 0x0018(sp)              // a2 = player struct

        _branch:
        j       0x800E81D4                  // jump to original branch location
        nop
    }

    // @ Description
    // Patch which saves Classic Sonic flags for 1P mode.
    scope save_classic_flags_1p_: {
        OS.patch_start(0x140184, 0x80137F84)
        j       save_classic_flags_1p_
        nop
        _return:
        OS.patch_end()

        lbu     t6, 0x0013(v0)              // t6 = human player port
        li      t7, classic_table           // t7 = classic_table
        addu    t6, t6, t7                  // t6 = classic_table + port
        lbu     t6, 0x0000(t6)              // t6 = px is_classic
        li      t7, classic_flag_1p         // t7 = classic_flag_1p
        sw      t6, 0x0000(t7)              // update classic_flag_1p
        jal     0x800D45F4                  // original line 1
        sb      t3, 0x0015(v0)              // original line 2
        j       _return
        nop
    }

    // @ Description
    // Patch which loads Classic Sonic flags for 1P mode.
    scope load_classic_flag_1p_: {
        OS.patch_start(0x140360, 0x80138160)
        j       load_classic_flag_1p_
        nop
        _return:
        OS.patch_end()

        lbu     t6, 0x0013(v1)              // t6 = human player port
        li      t7, classic_table           // t7 = classic_table
        addu    t6, t6, t7                  // t6 = classic_table + port
        li      at, classic_flag_1p         // ~
        lw      at, 0x0000(at)              // at = classic_flag_1p
        sw      r0, 0x0000(t7)              // reset classic_table
        sb      at, 0x0000(t6)              // set px is_classic to classic_flag_1p
        lbu     t6, 0x0014(v1)              // original line 1
        j       _return                     // return
        lbu     t7, 0x0015(v1)              // original line 2
    }

    // @ Description
    // Patch which saves Classic Sonic flags for Training mode.
    scope save_classic_flags_training_: {
        OS.patch_start(0x146BEC, 0x8013760C)
        j       save_classic_flags_training_
        nop
        _return:
        OS.patch_end()

        lbu     t4, 0x0013(a0)              // t4 = human player port
        or      t5, r0, r0                  // t5 = 0 (cpu player port)
        beqzl   t4, pc() + 8                // if human port = 0...
        lli     t5, 0x0001                  // ...change cpu port to 1
        li      t6, classic_table           // t6 = classic_table
        addu    t4, t4, t6                  // t4 = classic_table + human port
        addu    t5, t5, t6                  // t5 = classic_table + cpu port
        li      t7, classic_flags_training  // t7 = classic_flags_training
        lbu     t4, 0x0000(t4)              // t4 = px is_clasic for human
        sh      t4, 0x0000(t7)              // update classic_flags_training for human
        lbu     t5, 0x0000(t5)              // t4 = px is_clasic for cpu
        sh      t5, 0x0002(t7)              // update classic_flags_training for cpu
        sb      t8, 0x003B(a0)              // original line 1
        j       _return                     // return
        sb      t9, 0x003C(a0)              // original line 2
    }

    // @ Description
    // Patch which loads Classic Sonic flags for Training mode.
    scope load_classic_flags_training_: {
        OS.patch_start(0x147080, 0x80137AA0)
        j       load_classic_flags_training_
        nop
        _return:
        OS.patch_end()

        lbu     t4, 0x0013(s1)              // t4 = human player port
        or      t5, r0, r0                  // t5 = 0 (cpu player port)
        beqzl   t4, pc() + 8                // if human port = 0...
        lli     t5, 0x0001                  // ...change cpu port to 1
        li      t6, classic_table           // t6 = classic_table
        addu    t4, t4, t6                  // t4 = classic_table + human port
        addu    t5, t5, t6                  // t5 = classic_table + cpu port
        li      t7, classic_flags_training  // t7 = classic_flags_training
        sw      r0, 0x0000(t6)              // reset classic_table
        lhu     at, 0x0000(t7)              // at = human classic_flags_training
        sb      at, 0x0000(t4)              // update px is_classic for human
        lhu     at, 0x0002(t7)              // at = cpu classic_flags_training
        sb      at, 0x0000(t5)              // update px is_classic for cpu
        lbu     s0, 0x003D(s1)              // original line 1
        j       _return                     // return
        addiu   at, r0, 0x001C              // original line 2
    }

    // @ Description
    // Patch which saves Classic Sonic flags for VS mode.
    scope save_classic_flags_vs_: {
        OS.patch_start(0x1388E4, 0x8013A664)
        j       save_classic_flags_vs_
        nop
        _return:
        OS.patch_end()

        li      t5, classic_table           // ~
        lw      t5, 0x0000(t5)              // t5 = current classic flags
        li      t6, classic_flags_vs        // t6 = classic_flags_vs
        sw      t5, 0x0000(t6)              // update classic_flags_vs
        lui     t6, 0x8014                  // original line 1
        j       _return                     // return
        lw      t6, 0xBD7C(t6)              // original line 2
    }

    // @ Description
    // Patch which loads Classic Sonic flags for VS mode.
    scope load_classic_flag_vs_: {
        OS.patch_start(0x139238, 0x8013AFB8)
        j       load_classic_flag_vs_
        nop
        OS.patch_end()

        li      t5, classic_flags_vs        // ~
        lw      t5, 0x0000(t5)              // t5 = classic_flags_vs
        li      t6, classic_table           // t6 = classic_table
        sw      t5, 0x0000(t6)              // update current classic flags
        jr      ra                          // original line 1
        sh      t4, 0xBDBC(at)              // original line 2
    }

    // @ Description
    // Resets Classic Sonic flag on the CSS when the character is deselected.
    scope reset_classic_flag_: {
        // VS, deselect with A.
        OS.patch_start(0x1358C8, 0x80137648)
        j       reset_classic_flag_._vs_1
        sw      r0, 0x0058(v0)              // original line 1
        _return_vs_1:
        OS.patch_end()
        // VS, deselect with B.
        OS.patch_start(0x1362A4, 0x80138024)
        j       reset_classic_flag_._vs_2
        sw      r0, 0x0058(v0)              // original line 1
        _return_vs_2:
        OS.patch_end()
        // VS, close port.
        OS.patch_start(0x13427C, 0x80135FFC)
        j       reset_classic_flag_._vs_3
        sw      r0, 0x0058(s0)              // original line 1
        _return_vs_3:
        OS.patch_end()
        // Training, deselect with A.
        OS.patch_start(0x1442E4, 0x80134D04)
        j       reset_classic_flag_._training_1
        sw      r0, 0x0054(v0)              // original line 1
        _return_training_1:
        OS.patch_end()
        // Training, deselect with B.
        OS.patch_start(0x144CDC, 0x801356FC)
        j       reset_classic_flag_._training_2
        sw      r0, 0x0054(v0)              // original line 1
        _return_training_2:
        OS.patch_end()
        // Bonus, deselect with A.
        OS.patch_start(0x14AE00, 0x80134DD0)
        j       reset_classic_flag_._bonus_1
        sw      r0, 0x002C(s1)              // original line 1
        _return_bonus_1:
        OS.patch_end()
        // Bonus, deselect with B.
        OS.patch_start(0x14B6A4, 0x80135674)
        j       reset_classic_flag_._bonus_2
        sw      r0, 0x002C(a0)              // original line 1
        _return_bonus_2:
        OS.patch_end()
        // 1P, deselect with A.
        OS.patch_start(0x13E0B4, 0x80135EB4)
        j       reset_classic_flag_._1p_1
        sw      r0, 0x002C(s1)              // original line 1
        _return_1p_1:
        OS.patch_end()
        // 1P, deselect with B.
        OS.patch_start(0x13EDEC, 0x80136BEC)
        j       reset_classic_flag_._1p_2
        sw      r0, 0x002C(a0)              // original line 1
        _return_1p_2:
        OS.patch_end()

        _vs_1:
        // a1 - port index
        li      s2, classic_table           // s2 = classic_table
        addu    s2, s2, a1                  // t5 = classic_table + port
        sb      r0, 0x0000(s2)              // reset px is_classic
        j       _return_vs_1                // return
        or      s2, a1, r0                  // original line 2

        _vs_2:
        // a0 - port index
        li      t9, classic_table           // t9 = classic_table
        addu    t9, t9, a0                  // t9 = classic_table + port
        sb      r0, 0x0000(t9)              // reset px is_classic
        j       _return_vs_2                // return
        sw      t8, 0x005C(v0)              // original line 2

        _vs_3:
        // 0x0020(sp) - port index
        lw      t7, 0x0020(sp)              // t7 = port index
        li      t8, classic_table           // t8 = classic_table
        addu    t8, t8, t7                  // t8 = classic_table + port
        sb      r0, 0x0000(t8)              // reset px is_classic
        j       _return_vs_3                // return
        sw      t1, 0x0080(s0)              // original line 2

        _training_1:
        // a1 - port index
        li      s2, classic_table           // s2 = classic_table
        addu    s2, s2, a1                  // t5 = classic_table + port
        sb      r0, 0x0000(s2)              // reset px is_classic
        j       _return_training_1          // return
        or      s2, a1, r0                  // original line 2

        _training_2:
        // a0 - port index
        li      t9, classic_table           // t9 = classic_table
        addu    t9, t9, a0                  // t9 = classic_table + port
        sb      r0, 0x0000(t9)              // reset px is_classic
        j       _return_training_2          // return
        sw      t8, 0x0058(v0)              // original line 2

        _bonus_1:
        lw      t5, 0x00B0(s1)              // t5 = port index
        li      at, classic_table           // at = classic_table
        addu    at, at, t5                  // at = classic_table + port
        sb      r0, 0x0000(at)              // reset px is_classic
        j       _return_bonus_1             // return
        sw      t0, 0x0028(s1)              // original line 2

        _bonus_2:
        lw      t7, 0x00B0(a0)              // t7 = port index
        li      t8, classic_table           // t8 = classic_table
        addu    t8, t8, t7                  // t8 = classic_table + port
        sb      r0, 0x0000(t8)              // reset px is_classic
        j       _return_bonus_2             // return
        sw      t6, 0x0030(a0)              // original line 2

        _1p_1:
        lw      t5, 0x00B0(s1)              // t5 = port index
        li      at, classic_table           // at = classic_table
        addu    at, at, t5                  // at = classic_table + port
        sb      r0, 0x0000(at)              // reset px is_classic
        j       _return_1p_1                // return
        sw      t1, 0x0028(s1)              // original line 2

        _1p_2:
        lw      t7, 0x00B0(a0)              // t7 = port index
        li      t8, classic_table           // t8 = classic_table
        addu    t8, t8, t7                  // t8 = classic_table + port
        sb      r0, 0x0000(t8)              // reset px is_classic
        j       _return_1p_2                // return
        sw      t6, 0x0030(a0)              // original line 2

    }

    // @ Description
    // Patch which loads the Classic Sonic model.
    scope load_classic_model_: {
        OS.patch_start(0x537DC, 0x800D7FDC)
        j       load_classic_model_
        nop
        _return:
        OS.patch_end()

        // s6 = player info
        lbu     t6, 0x0015(s6)              // t6 = player port
        li      t5, select_anim_frame       // t5 = select_anim_frame
        sll     t4, t6, 0x2                 // t4 = port * 4
        addu    t5, t5, t4                  // t5 = px select_anim_frame address
        sw      r0, 0x0000(t5)              // reset px select_anim_frame
        li      t5, classic_table           // t5 = classic_table
        addu    t5, t5, t6                  // t5 = classic_table + port
        lw      t4, 0x0028(t3)              // original line 1
        lli     t6, Character.id.SONIC      // t6 = id.SONIC
        lw      t0, 0x0000(s6)              // t0 = character id
        bnel    t6, t0, _end                // skip if character id != SONIC...
        sb      r0, 0x0000(t5)              // ...and reset px is_classic to FALSE

        // if the character is Sonic
        lbu     t0, 0x0000(t5)              // t0 = px is_classic
        bnel    t0, r0, _end                // branch if px is_classic = TRUE...
        lw      t4, 0x0040(t3)              // ...and load Classic Sonic Main file pointer into t4

        _end:
        j       _return
        lw      t6, 0x0060(t3)              // original line 2
    }

    // @ Description
    // Patch which takes the Sonic model into account when comparing costumes on the CSS.
    scope adjust_costume_comparison_: {
        // vs
        OS.patch_start(0x132A54, 0x801347D4)
        jal     adjust_costume_comparison_._vs
        lw      t9, 0x004C(s1)              // t9 = costume_id - original line 1
        OS.patch_end()

        // training HMN
        OS.patch_start(0x142AA4, 0x801334C4)
        jal     adjust_costume_comparison_._training_hmn
        addu    t2, s4, t1                  // t2 = CPU CSS character struct - original line 1
        OS.patch_end()
        // training CPU
        OS.patch_start(0x142B3C, 0x8013355C)
        jal     adjust_costume_comparison_._training_cpu
        addu    t1, s4, t0                  // t1 = HMN CSS character struct - original line 1
        OS.patch_end()

        _vs:
        // s5 = character_id
        // s6 = port_id of other
        // 0x006C(sp) = port_id of self
        lli     t1, Character.id.SONIC      // t1 = id.SONIC
        bne     s5, t1, _end                // if not Sonic, skip
        sll     t0, s0, 0x0002              // original line 2

        li      at, classic_table           // at = classic_table
        lw      t1, 0x006C(sp)              // t1 = port_id for self
        addu    t1, at, t1                  // t1 = classic_table + port for self
        lbu     t1, 0x0000(t1)              // t1 = is_classic for self
        bnezl   t1, pc() + 8                // if classic, increase costume_id for self
        addiu   v0, v0, 0x0006              // t9 = fudged costume_id for self

        addu    t1, at, s6                  // t1 = classic_table + port for other
        lbu     t1, 0x0000(t1)              // t1 = is_classic for other
        bnezl   t1, pc() + 8                // if classic, increase costume_id for other
        addiu   t9, t9, 0x0006              // t9 = fudged costume_id for other

        b       _end
        nop

        _training_hmn:
        // s6 = character_id
        // t0 = port_id
        lli     t3, Character.id.SONIC      // t3 = id.SONIC
        bne     s6, t3, _end                // if not Sonic, skip
        lw      t3, 0x004C(t2)              // t3 = costume_id - original line 2

        li      t1, classic_table           // t1 = classic_table
        addu    t1, t1, t0                  // t1 = classic_table + port
        lbu     t1, 0x0000(t1)              // t1 = is_classic
        bnezl   t1, _end                    // if classic, increase costume_id
        addiu   t3, t3, 0x0006              // t3 = fudged costume_id
        b       _end
        nop

        _training_cpu:
        // s6 = character_id
        // t9 = port_id
        lli     t2, Character.id.SONIC      // t2 = id.SONIC
        bne     s6, t2, _end                // if not Sonic, skip
        lw      t2, 0x004C(t1)              // t2 = costume_id - original line 2

        li      t0, classic_table           // t0 = classic_table
        addu    t0, t0, t9                  // t0 = classic_table + port
        lbu     t0, 0x0000(t0)              // t0 = is_classic
        bnezl   t0, _end                    // if classic, increase costume_id
        addiu   t2, t2, 0x0006              // t3 = fudged costume_id

        _end:
        jr      ra
        nop
    }

    classic_table:
    db 0x00; db 0x00; db 0x00; db 0x00      // p1, p2, p3, p4

    classic_flag_1p:
    dw 0x00000000                           // hmn

    classic_flags_training:
    dh 0x0000; dh 0x0000                    // hmn, cpu

    classic_flags_vs:
    db 0x00; db 0x00; db 0x00; db 0x00      // p1, p2, p3, p4

    select_anim_frame:
    float32 0                               // p1
    float32 0                               // p2
    float32 0                               // p3
    float32 0                               // p4

    // @ Description
    // Allows Sonic to pick up facing for entry
    scope sonic_facing_: {
        OS.patch_start(0xB8690, 0x8013DC50)
        j       sonic_facing_
        sw      r0, 0x0B24(s0)              // original line 1, clears an action address in player struct
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.SONIC  // SSONIC ID
        lw      t6, 0x0008(s0)              // load character ID
        beq     t6, at, _end                // modified original line 1
        addiu   at, r0, Character.id.SSONIC // SSONIC ID
        bnel    t6, at, _end
        sw      r0, 0x0044(s0)              // original line 2, clears out player facing


        _end:
        j       _return
        nop
    }

    // @ Description
    // Adds parameter overrides for Classic Sonic Menu Animations
    // @ Arguments
    // anim - animation id
    // moveset - pointer to moveset commands
    // flags - animation flags
    macro add_sonic_parameters(anim, moveset, flags) {
        dw {anim}
        dw {moveset}
        dw {flags}
    }

    // @ Description
    // Block of moveset commands for Sonic.
    standard_moveset:
    dw 0x00000000                           // End

    // @ Description
    // Array of menu action parameter overrides for Classic Sonic.
    // Arguments          Animation file ID             Moveset data                Flags
    sonic_array:

    sonic_1p_HMN:
    add_sonic_parameters(File.SONIC_CLASSIC_1P_POSE,    standard_moveset,           0)          // 0x00 - 1P_POSE_HUMAN

    sonic_victory1:
    add_sonic_parameters(File.CSONIC_VICTORY1,          standard_moveset,           0)          // 0x03 - VICTORY1


    // @ Description
    // Patch which swaps animations and moveset data for certain Classic Sonic Menu actions
    scope classic_sonic_anim_swap_: {
        li      t2, sonic_array
        lw      t0, 0x0000(t3)      // load the expected animations for Adventure SONIC

        ori     t1, r0, File.SONIC_1P_POSE      // insert anim
        beql    t1, t0, _end                    // check to see if select anim is one CSONIC has an alternate
        addu    t3, t2, r0                      // get pointer to new parameter for CSONIC anim

        ori     t1, r0, File.SONIC_VICTORY2
        beql    t1, t0, _end
        addiu   t3, t2, 0x000C


        _end:
        jr      ra
        nop
    }
}
