// DrgaonKing.asm

// This file contains file inclusions, action edits, and assembly for Dragon King.

scope DragonKing {

    // Insert Moveset files
    JUMP:; insert "moveset/JUMP.bin"
    JUMP_AERIAL:; insert "moveset/JUMP_AERIAL.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
    insert SLEEP, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP)         // loops
    ROLLF:; insert "moveset/ROLLF.bin"
    ROLLB:; insert "moveset/ROLLB.bin"
    TECH:; insert "moveset/TECH.bin"
    TECH_ROLL:; insert "moveset/TECH_ROLL.bin"
    CLIFF_ATTACK_QUICK_2:; insert "moveset/CLIFF_ATTACK_QUICK_2.bin"
    CLIFF_ATTACK_SLOW_2:; insert "moveset/CLIFF_ATTACK_SLOW_2.bin"

    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    insert F_THROW_DATA,"moveset/F_THROW_DATA.bin"
    F_THROW:; Moveset.THROW_DATA(F_THROW_DATA); insert "moveset/F_THROW.bin"
    insert B_THROW_DATA,"moveset/B_THROW_DATA.bin"
    B_THROW:; Moveset.THROW_DATA(B_THROW_DATA); insert "moveset/B_THROW.bin"
    ENTRY:; insert "moveset/ENTRY.bin"
    TAUNT:; insert "moveset/TAUNT.bin"
    JAB_1:; insert "moveset/JAB_1.bin"
    JAB_2:; insert "moveset/JAB_2.bin"
    insert JAB_LOOP, "moveset/JAB_LOOP.bin"; Moveset.GO_TO(JAB_LOOP) // loops
    DASH_ATTACK:; insert "moveset/DASH_ATTACK.bin"
    UTILT:; insert "moveset/UTILT.bin"
    DTILT:; insert "moveset/DTILT.bin"
    FTILT_HIGH:; insert "moveset/FTILT_HIGH.bin"
    FTILT_MID_HIGH:; insert "moveset/FTILT_MID_HIGH.bin"
    FTILT:; insert "moveset/FTILT.bin"
    FTILT_MID_LOW:; insert "moveset/FTILT_MID_LOW.bin"
    FTILT_LOW:; insert "moveset/FTILT_LOW.bin"
    FSMASH_HIGH:; insert "moveset/FSMASH_HIGH.bin"
    FSMASH_MID_HIGH:; insert "moveset/FSMASH_MID_HIGH.bin"
    FSMASH:; insert "moveset/FSMASH.bin"
    FSMASH_MID_LOW:; insert "moveset/FSMASH_MID_LOW.bin"
    FSMASH_LOW:; insert "moveset/FSMASH_LOW.bin"
    UP_SMASH:; insert "moveset/UP_SMASH.bin"
    DOWN_SMASH:; insert "moveset/DOWN_SMASH.bin"
    ATTACK_AIR_N:; insert "moveset/ATTACK_AIR_N.bin"
    ATTACK_AIR_F:; insert "moveset/ATTACK_AIR_F.bin"
    ATTACK_AIR_B:; insert "moveset/ATTACK_AIR_B.bin"
    ATTACK_AIR_U:; insert "moveset/ATTACK_AIR_U.bin"
    ATTACK_AIR_D:; insert "moveset/ATTACK_AIR_D.bin"

    NSP:; insert "moveset/NSP.bin"
    USP_AIR_PULL_CONCURRENT:
    Moveset.AFTER(30)
    Moveset.SET_FLAG(0)
    dw 0x98012800, 0, 0, 0
    Moveset.WAIT(1)
    dw 0x54000002
    Moveset.WAIT(1)
    Moveset.GO_TO(USP_AIR_PULL_CONCURRENT + 4)
    USP:; insert "moveset/USP.bin"
    insert USP_THROW_DATA,"moveset/USP_THROW_DATA.bin"
    USP_GROUND_THROW:; Moveset.THROW_DATA(USP_THROW_DATA); insert "moveset/USP_GROUND_THROW.bin"
    USP_AIR_PULL:; Moveset.CONCURRENT_STREAM(USP_AIR_PULL_CONCURRENT); Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/USP_AIR_PULL.bin"
    USP_LANDING_THROW:; Moveset.THROW_DATA(USP_THROW_DATA); insert "moveset/USP_LANDING_THROW.bin"
    DSPG:; insert "moveset/DSPG.bin"
    DSPA_BEGIN:; insert "moveset/DSPA_BEGIN.bin"
    DSPA_LOOP:; insert "moveset/DSPA_LOOP.bin"
    DSPA_LAND:; insert "moveset/DSPA_LAND.bin"

    VICTORY_2:; insert "moveset/VICTORY_2.bin"

    // @ Description
    // Dragon King's extra actions
    scope Action {
        constant JabLoopStart(0x0DC)
        constant JabLoop(0x0DD)
        constant JabLoopEnd(0x0DE)
        constant Appear1(0x0E0)
        constant Appear2(0x0E1)
        //constant AppearLeft2(0x0E2)
        //constant AppearRight2(0x0E3)
        constant DragonBall(0x0E4)
        constant DragonBallAir(0x0E5)
        constant Earthquake(0x0E6)
        constant EarthquakeAir(0x0E7)
        constant EarthquakeAirLanding(0x0E8)
        constant EarthquakeAirBegin(0x0E9)
        //constant CollisionWarlockKick(0x0EA)
        //constant WarlockDive(0x0EB)
        //constant WarlockDiveCatch(0x0EC)
        //constant WarlockDiveEnd1(0x0ED)
        //constant WarlockDiveEnd2(0x0EE)
        //constant HealthAbsorbGround(0x0EF)
        //constant HealthAbsorbGroundThrow(0x0F0)
        //constant HealthAbsorbAir(0x0F1)
        //constant HealthAbsorbAirPull(0x0F2)
        //constant HealthAbsorbLandingThrow(0x0F3)

        // strings!
        string_0x0DC:; String.insert("JabLoopStart")
        string_0x0DD:; String.insert("JabLoop")
        string_0x0DE:; String.insert("JabLoopEnd")
        string_0x0E0:; String.insert("Appear1")
        string_0x0E1:; String.insert("Appear2")
        //string_0x0E2:; String.insert("AppearLeft1")
        //string_0x0E3:; String.insert("AppearRight2")
        string_0x0E4:; String.insert("DragonBall")
        string_0x0E5:; String.insert("DragonBallAir")
        string_0x0E6:; String.insert("Earthquake")
        string_0x0E7:; String.insert("EarthquakeAir")
        string_0x0E8:; String.insert("EarthquakeAirLanding")
        string_0x0E9:; String.insert("EarthquakeAirBegin")
        //string_0x0EA:; String.insert("CollisionWarlockKick")
        //string_0x0EB:; String.insert("WarlockDive")
        //string_0x0EC:; String.insert("DarkDiveCatch")
        //string_0x0ED:; String.insert("DarkDiveEnd1")
        //string_0x0EE:; String.insert("DarkDiveEnd2")
        string_0x0EF:; String.insert("HealthAbsorbGround")
        string_0x0F0:; String.insert("HealthAbsorbGroundThrow")
        string_0x0F1:; String.insert("HealthAbsorbAir")
        string_0x0F2:; String.insert("HealthAbsorbAirPull")
        string_0x0F3:; String.insert("HealthAbsorbLandingThrow")

        action_string_table:
        dw string_0x0DC
        dw string_0x0DD
        dw string_0x0DE
        dw 0
        dw string_0x0E0
        dw string_0x0E1
        dw 0
        dw 0
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0EF
        dw string_0x0F0
        dw string_0x0F1
        dw string_0x0F2
        dw string_0x0F3
    }

    // Insert AI attack options


    // Modify Action Parameters                     // Action               // Animation                    // Moveset Data             // Flags
    Character.edit_action_parameters(DRAGONKING,    Action.Idle,            File.DKING_IDLE,                0x80000000,                 -1)
    Character.edit_action_parameters(DRAGONKING,    Action.ReviveWait,      File.DKING_IDLE,                0x80000000,                 -1)
	Character.edit_action_parameters(DRAGONKING, 	Action.Dash,            File.DKING_DASH,            	-1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.Run,             File.DKING_RUN,                 -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.RunBrake,        File.DKING_RUN_BRAKE,           -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.JumpF,           File.DKING_JUMP_F,              JUMP,                       -1)
    Character.edit_action_parameters(DRAGONKING,    Action.JumpB,           File.DKING_JUMP_B,              JUMP,                       -1)
    Character.edit_action_parameters(DRAGONKING,    Action.JumpAerialF,     File.DKING_JUMP_AERIAL_F,       JUMP_AERIAL,                -1)
    Character.edit_action_parameters(DRAGONKING,    Action.JumpAerialB,     File.DKING_JUMP_AERIAL_B,       JUMP_AERIAL,                -1)
    Character.edit_action_parameters(DRAGONKING,    Action.Fall,            File.DKING_FALL,                -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.FallAerial,      File.DKING_FALL,                -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.Taunt,           File.DKING_TAUNT,               TAUNT,                      0x00000000)
    Character.edit_action_parameters(DRAGONKING,    Action.Teeter,          -1,                             0x80000000,                 -1)
    Character.edit_action_parameters(DRAGONKING,    Action.TeeterStart,     -1,                             0x80000000,                 -1)
    Character.edit_action_parameters(DRAGONKING,    Action.CliffAttackQuick2,-1,                            CLIFF_ATTACK_QUICK_2,       -1)
    Character.edit_action_parameters(DRAGONKING,    Action.CliffAttackSlow2,-1,                             CLIFF_ATTACK_SLOW_2,        -1)
    Character.edit_action_parameters(DRAGONKING,    Action.ShieldOn,        File.DRAGONKING_SHIELD_ON,      -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.ShieldOff,       File.DRAGONKING_SHIELD_OFF,     -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.ShieldBreak,     -1,                             SHIELD_BREAK,               -1)
    Character.edit_action_parameters(DRAGONKING,    Action.Stun,            -1,                             STUN,                       -1)
    Character.edit_action_parameters(DRAGONKING,    Action.Sleep,           -1,                             SLEEP,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.Tech,            -1,                             TECH,                       -1)
    Character.edit_action_parameters(DRAGONKING,    Action.TechF,           -1,                             TECH_ROLL,                  -1)
    Character.edit_action_parameters(DRAGONKING,    Action.TechB,           -1,                             TECH_ROLL,                  -1)
    Character.edit_action_parameters(DRAGONKING,    Action.RollF,           -1,                             ROLLF,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.RollB,           -1,                             ROLLB,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.TeeterStart,     -1,                             0x80000000,                 -1)

    Character.edit_action_parameters(DRAGONKING,    Action.JumpSquat,       File.DKING_JUMPSQUAT,           -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.ShieldJumpSquat, File.DKING_JUMPSQUAT,           -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.LandingLight,    File.DKING_JUMPSQUAT,           -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.LandingHeavy,    File.DKING_JUMPSQUAT,           -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.LandingSpecial,  File.DKING_JUMPSQUAT,           -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.LandingAirX,     File.DKING_JUMPSQUAT,           -1,                         -1)

    Character.edit_action_parameters(DRAGONKING,    Action.ThrowF,          File.DKING_FTHROW,              F_THROW,                    -1)
    Character.edit_action_parameters(DRAGONKING,    Action.ThrowB,          File.DKING_BTHROW,              B_THROW,                    0x50000000)

    Character.edit_action_parameters(DRAGONKING,    Action.Jab1,            File.DKING_JAB_1,               JAB_1,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.Jab2,            File.DKING_JAB_2,               JAB_2,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.JabLoopStart,    File.DKING_JAB_LOOP_START,      0x80000000,                 0x40000000)
    Character.edit_action_parameters(DRAGONKING,    Action.JabLoop,         File.DKING_JAB_LOOP,            JAB_LOOP,                   -1)
    Character.edit_action_parameters(DRAGONKING,    Action.JabLoopEnd,      File.DKING_JAB_LOOP_END,        0x80000000,                 -1)
    Character.edit_action_parameters(DRAGONKING,    Action.TeeterStart,     -1,                             0x80000000,                 -1)
    Character.edit_action_parameters(DRAGONKING,    Action.DashAttack,      File.DKING_DASH_ATTACK,         DASH_ATTACK,                -1)
    Character.edit_action_parameters(DRAGONKING,    Action.FTiltHigh,       File.DKING_FTILT_HIGH,          FTILT_HIGH,                 -1)
    Character.edit_action_parameters(DRAGONKING,    Action.FTiltMidHigh,    File.DKING_FTILT_MID_HIGH,      FTILT_MID_HIGH,             -1)
    Character.edit_action_parameters(DRAGONKING,    Action.FTilt,           File.DKING_FTILT,               FTILT,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.FTiltMidLow,     File.DKING_FTILT_MID_LOW,       FTILT_MID_LOW,              -1)
    Character.edit_action_parameters(DRAGONKING,    Action.FTiltLow,        File.DKING_FTILT_LOW,           FTILT_LOW,                  -1)
    Character.edit_action_parameters(DRAGONKING,    Action.UTilt,           File.DKING_UTILT,               UTILT,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.DTilt,           File.DKING_DTILT,               DTILT,                      -1)
    Character.edit_action_parameters(DRAGONKING,    Action.USmash,          File.DKING_USMASH,              UP_SMASH,                   0)
    Character.edit_action_parameters(DRAGONKING,    Action.DSmash,          File.DKING_DSMASH,              DOWN_SMASH,                 -1)
    Character.edit_action_parameters(DRAGONKING,    Action.FSmashHigh,      File.DKING_FSMASH_HIGH,         FSMASH_HIGH,                0x00000000)
    Character.edit_action_parameters(DRAGONKING,    Action.FSmashMidHigh,   File.DKING_FSMASH_MID_HIGH,     FSMASH_MID_HIGH,            0x00000000)
    Character.edit_action_parameters(DRAGONKING,    Action.FSmash,          File.DKING_FSMASH,              FSMASH,                     0x00000000)
    Character.edit_action_parameters(DRAGONKING,    Action.FSmashMidLow,    File.DKING_FSMASH_MID_LOW,      FSMASH_MID_LOW,             0x00000000)
    Character.edit_action_parameters(DRAGONKING,    Action.FSmashLow,       File.DKING_FSMASH_LOW,          FSMASH_LOW,                 0x00000000)
    Character.edit_action_parameters(DRAGONKING,    Action.AttackAirN,      File.DKING_ATTACK_AIR_N,        ATTACK_AIR_N,               -1)
    Character.edit_action_parameters(DRAGONKING,    Action.AttackAirF,      File.DKING_ATTACK_AIR_F,        ATTACK_AIR_F,               -1)
    Character.edit_action_parameters(DRAGONKING,    Action.AttackAirB,      File.DKING_ATTACK_AIR_B,        ATTACK_AIR_B,               -1)
    Character.edit_action_parameters(DRAGONKING,    Action.AttackAirU,      File.DKING_ATTACK_AIR_U,        ATTACK_AIR_U,               -1)
    Character.edit_action_parameters(DRAGONKING,    Action.AttackAirD,      File.DKING_ATTACK_AIR_D,        ATTACK_AIR_D,               -1)
    Character.edit_action_parameters(DRAGONKING,    Action.LandingAirB,     File.DKING_LANDING_AIR_B,       -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    Action.LandingAirF,     File.DKING_LANDING_AIR_F,       -1,                         -1)
    Character.edit_action_parameters(DRAGONKING,    0xE0,                   File.DKING_ENTRY_L,             ENTRY,                      -1)
    Character.edit_action_parameters(DRAGONKING,    0xE1,                   File.DKING_ENTRY_R,             ENTRY,                      -1)
    Character.edit_action_parameters(DRAGONKING,    0xE2,                   0,                              0x80000000,                 0)
    Character.edit_action_parameters(DRAGONKING,    0xE3,                   0,                              0x80000000,                 0)
    Character.edit_action_parameters(DRAGONKING,    0xE4,                   File.DKING_NSPG,                NSP,                        0x40000000)
    Character.edit_action_parameters(DRAGONKING,    0xE5,                   File.DKING_NSPA,                NSP,                        0x00000000)
    Character.edit_action_parameters(DRAGONKING,    0xE6,                   File.DKING_DSP_G,               DSPG,                       0x00000000)
    Character.edit_action_parameters(DRAGONKING,    0xE7,                   File.DKING_DSP_A_LOOP,          DSPA_LOOP,                  0x00000000)
    Character.edit_action_parameters(DRAGONKING,    0xE8,                   File.DKING_DSP_A_LANDING,       DSPA_LAND,                  0x00000000)
    Character.edit_action_parameters(DRAGONKING,    0xE9,                   File.DKING_DSP_A_BEGIN,         DSPA_BEGIN,                 0x00000000)

    // Add Action Parameters                    // Action Name      // Base Action  // Animation                    // Moveset Data             // Flags
    Character.add_new_action_params(DRAGONKING, USPGround,          -1,             File.DKING_USPG,                USP,                        0)
    Character.add_new_action_params(DRAGONKING, USPGroundThrow,     -1,             File.DKING_USPG_THROW,          USP_GROUND_THROW,           0x10000000)
    Character.add_new_action_params(DRAGONKING, USPAir,             -1,             File.DKING_USPA,                USP,                        0x40000000)
    Character.add_new_action_params(DRAGONKING, USPAirPull,         -1,             File.DKING_USPA_THROW,          USP_AIR_PULL,               0x10000000)
    Character.add_new_action_params(DRAGONKING, USPLandingThrow,    -1,             File.DKING_USPA_LANDING,        USP_LANDING_THROW,          0x10000000)

    // Modify Actions                   // Action               // Staling ID   // Main ASM                     // Interrupt/Other ASM      // Movement/Physics ASM         // Collision ASM
    Character.edit_action(DRAGONKING,   Action.JabLoopStart,    0x4,            0x8014F0D0,                     0,                          0x800D8BB4,                     0x800DDF44)
    Character.edit_action(DRAGONKING,   Action.JabLoop,         0x4,            0x8014F2A8,                     0x8014F388,                 0x800D8BB4,                     0x800DDF44)
    Character.edit_action(DRAGONKING,   Action.JabLoopEnd,      0x4,            0x800D94C4,                     0,                          0x800D8BB4,                     0x800DDF44)
    Character.edit_action(DRAGONKING,   0xDC,                   -1,             0x8014F0D0,                     0x00000000,                 0x800D8C14,                     0x800DDF44)
    Character.edit_action(DRAGONKING,   0xE4,                   -1,             DragonKingNSP.main_,            -1,                         0x800D8CCC,                     DragonKingNSP.ground_collision_)
    Character.edit_action(DRAGONKING,   0xE5,                   -1,             DragonKingNSP.main_,            -1,                         DragonKingNSP.physics_aerial_,  DragonKingNSP.air_collision_)
    Character.edit_action(DRAGONKING,   0xE5,                   -1,             -1,                             -1,                         -1,                             -1)
    Character.edit_action(DRAGONKING,   0xE6,                   0x1E,           0x800D94C4,                     0,                          0x800D8BB4,                     0x800DDF44)                 // DSP_Ground
    Character.edit_action(DRAGONKING,   0xE7,                   0x1E,           0x00000000,                     DragonKingDSP.air_move_,    DragonKingDSP.physics_,         DragonKingDSP.collision_)   // DSP Air Loop
    Character.edit_action(DRAGONKING,   0xE8,                   0x1E,           0x800D94C4,                     0,                          0x800D8BB4,                     0x800DDF44)                 // DSP Air Landing
    Character.edit_action(DRAGONKING,   0xE9,                   0x1E,           DragonKingDSP.aerial_main_,     DragonKingDSP.air_move_,    DragonKingDSP.physics_,         DragonKingDSP.collision_)   // DSP Air Begin

    // Add Actions                          // Action Name      // Base Action  //Parameters                    // Staling ID   // Main ASM                         // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(DRAGONKING,    USPGround,          -1,             ActionParams.USPGround,         0x11,           0x800D94C4,                         0x80160370,                     0x800D8BB4,                         DragonKingUSP.ground_collision_)
    Character.add_new_action(DRAGONKING,    USPGroundThrow,     -1,             ActionParams.USPGroundThrow,    0x11,           DragonKingUSP.throw_main_,          0,                              0x800D8BB4,                         0x80149B78)
    Character.add_new_action(DRAGONKING,    USPAir,             -1,             ActionParams.USPAir,            0x11,           0x801602B0,                         0x80160370,                     0x801603F0,                         0x80160560)
    Character.add_new_action(DRAGONKING,    USPAirPull,         -1,             ActionParams.USPAirPull,        0x11,           DragonKingUSP.air_pull_main_,       0,                              DragonKingUSP.air_pull_physics_,    DragonKingUSP.air_pull_collision_)
    Character.add_new_action(DRAGONKING,    USPLandingThrow,    -1,             ActionParams.USPLandingThrow,   0x11,           DragonKingUSP.throw_main_,          0,                              0x800D8BB4,                         0x800DDF44)

    // Modify Menu Action Parameters                    // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(DRAGONKING,   0x0,                File.DKING_IDLE,            0x80000000,                 -1)
    Character.edit_menu_action_parameters(DRAGONKING,   0x1,                File.DKING_VICTORY_2,       VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(DRAGONKING,   0x2,                File.DKING_CSS,             0x80000000,                 -1)
    Character.edit_menu_action_parameters(DRAGONKING,   0x3,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(DRAGONKING,   0x4,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(DRAGONKING,   0xD,               File.DRAGONKING_1P_POSE,     0x80000000,                 -1)

    Character.table_patch_start(air_nsp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingNSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_nsp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingNSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingDSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.DRAGONKING, 0x4)
    dw      DragonKingDSP.ground_initial_
    OS.patch_end()

    Character.table_patch_start(variants, Character.id.FALCON, 0x4)
    db      Character.id.DRAGONKING  // set as SPECIAL variant for FALCON
    db      0x15                     // set as POLYGON variant for FALCON
    db      Character.id.JFALCON     // set as JAPANESE variant for FALCON
    db      Character.id.NONE
    OS.patch_end()

    Character.table_patch_start(jab_3, Character.id.DRAGONKING, 0x4)
    dw      Character.jab_3.DISABLED        // disable jab 3
    OS.patch_end()
    Character.table_patch_start(rapid_jab_begin_action, Character.id.DRAGONKING, 0x4)
    dw      0x8014F13C                      // copied from FOX
    OS.patch_end()
    Character.table_patch_start(rapid_jab_loop_action, Character.id.DRAGONKING, 0x4)
    dw      0x8014F3F4                      // copied from FOX
    OS.patch_end()
    Character.table_patch_start(rapid_jab_ending_action, Character.id.DRAGONKING, 0x4)
    dw      0x8014F490                      // copied from FOX
    OS.patch_end()
    Character.table_patch_start(rapid_jab_unknown, Character.id.DRAGONKING, 0x4)
    dw      0x8014F5B0                      // copied from FOX
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.DRAGONKING, 0x4)
    float32 1.0
    OS.patch_end()

    // Sets Dragon King entry actions
    Character.table_patch_start(entry_action, Character.id.DRAGONKING, 0x8)
    dw 0xE0, 0xE1
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.DRAGONKING, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set crowd chant FGM to none
    Character.table_patch_start(crowd_chant_fgm, Character.id.DRAGONKING, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.DRAGONKING, 0xC)
    dh 0x29
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.DRAGONKING, 0, 1, 2, 3, 0, 3, 1)
    Teams.add_team_costume(YELLOW, DRAGONKING, 0x4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(DRAGONKING, RED, GREEN, WHITE, BLUE, YELLOW, BLUE, NA, NA)

    // Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.DRAGONKING, 0xC)
    dw Character.kirby_inhale_struct.star_damage.FALCON
    OS.patch_end()

    // No skeleton if hit by electric attacks
    Character.table_patch_start(electric_hit, Character.id.DRAGONKING, 0x4)
    dw 0x10
    OS.patch_end()

    // Set CPU behaviour
    //Character.table_patch_start(ai_behaviour, Character.id.DRAGONKING, 0x4)
    //dw      CPU_ATTACKS
    //OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  14,   24,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  12,   31,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  16,   38,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  16,   35,  -1, -1, -1, -1) // todo: coords
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  8,    15,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  7,    19,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  24,   33,  -1, -1, -1, -1) // todo: coords
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  10,   16,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,    6,   -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  5,    8,   -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  7,    17,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  47,   52,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  47,   52,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  7,    17,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  16,   51,  -1, -1, -1, -1)
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  15,   55,  -1, -1, -1, -1) // todo: coords
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  19,   33,  -1, -1, -1, -1) // todo: coords
    //AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  34,   40,  -1, -1, -1, -1) // todo: coords

    // Set action strings
    Character.table_patch_start(action_string, Character.id.DRAGONKING, 0x4)
    dw  Action.action_string_table
    OS.patch_end()
}
