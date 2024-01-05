// Sheik.asm

// This file contains file inclusions, action edits, and assembly for Sheik.

scope Sheik {


    scope MODEL {
        scope FACE {
            constant NORMAL(0xAC000000)
            constant CLOSED(0xAC000006)
        }
        scope RIGHT_HAND {
            constant NORMAL(0xA0800000)
            constant POINT(0xA0800001)
            constant OPEN(0xA0800002)
        }
        scope LEFT_HAND {
            constant NORMAL(0xA0500000)
            constant POINT(0xA0500001)
            constant OPEN(0xA0500002)
            constant HARP(0xA0500003)
        }
    }

    // Insert Moveset files
    insert BLINK,"moveset/BLINK.bin"; Moveset.GO_TO(BLINK)            // loops

    IDLE:
    Moveset.SUBROUTINE(BLINK)                   // blink
    dw 0x0400005A; Moveset.SUBROUTINE(BLINK)    // wait 90 frames then blink
    dw 0x0400000A; Moveset.SUBROUTINE(BLINK)    // wait 10 frames then blink
    dw 0x04000050; Moveset.GO_TO(IDLE)          // loop

    insert USP_BEGIN,"moveset/USP_BEGIN.bin"
    insert USP_MOVE,"moveset/USP_MOVE.bin"
    insert USP_END,"moveset/USP_END.bin"
    insert DSP_BEGIN,"moveset/DSP_BEGIN.bin"
    insert DSP_ATTACK,"moveset/DSP_ATTACK.bin"
    insert DSP_LANDING,"moveset/DSP_LANDING.bin"
    insert DSP_RECOIL,"moveset/DSP_RECOIL.bin"
    insert NSP_BEGIN,"moveset/NSP_BEGIN.bin"
    insert NSP_CHARGE,"moveset/NSP_CHARGE.bin"
    insert NSP_SHOOT,"moveset/NSP_SHOOT.bin"
    insert JUMP,"moveset/JUMP.bin"
    insert JUMP_AERIAL,"moveset/JUMP_AERIAL.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert THROW_F_DATA,"moveset/THROW_F_DATA.bin"
    THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); insert "moveset/THROW_F.bin"
    insert THROW_B_DATA,"moveset/THROW_F_DATA.bin"
    THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); insert "moveset/THROW_B.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert F_TILT,"moveset/F_TILT.bin"
    insert U_TILT,"moveset/U_TILT.bin"
    insert D_TILT,"moveset/D_TILT.bin"
    insert F_SMASH,"moveset/F_SMASH.bin"
    insert U_SMASH,"moveset/U_SMASH.bin"
    insert D_SMASH,"moveset/D_SMASH.bin"
    insert ATTACK_AIR_N,"moveset/ATTACK_AIR_N.bin"
    insert ATTACK_AIR_F,"moveset/ATTACK_AIR_F.bin"
    insert ATTACK_AIR_B,"moveset/ATTACK_AIR_B.bin"
    insert ATTACK_AIR_U,"moveset/ATTACK_AIR_U.bin"
    insert ATTACK_AIR_D,"moveset/ATTACK_AIR_D.bin"
    insert TEETER,"moveset/TEETER.bin"
    insert TECH,"moveset/TECH.bin"
    insert TECHROLL,"moveset/TECHROLL.bin"
    insert ENTRY,"moveset/ENTRY.bin"
    insert VICTORY_1,"moveset/VICTORY_1.bin"
    insert VICTORY_2,"moveset/VICTORY_2.bin"
    insert VICTORY_3,"moveset/VICTORY_3.bin"
    insert ONEP,"moveset/ONEP.bin"
    insert CPU,"moveset/CPU.bin"
    insert RUN,"moveset/RUN.bin"; Moveset.GO_TO(RUN)            // loops
    insert TURNRUN,"moveset/TURNRUN.bin"
    insert DASH,"moveset/DASH.bin"
    insert CROUCH_START,"moveset/CROUCH_START.bin"
    insert CROUCH_IDLE,"moveset/CROUCH_IDLE.bin"
    insert CROUCH_END,"moveset/CROUCH_END.bin"
    insert CLIFF_ATTACK_QUICK_2,"moveset/CLIFF_ATTACK_QUICK_2.bin"
    insert CLIFF_ATTACK_SLOW_2,"moveset/CLIFF_ATTACK_SLOW_2.bin"
    insert FLOORATTACK_U,"moveset/FLOORATTACK_U.bin"
    insert FLOORATTACK_D,"moveset/FLOORATTACK_D.bin"
    insert TEETER_START,"moveset/TEETER_START.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops
    insert ROLL_F,"moveset/ROLL_F.bin"
    insert ROLL_B,"moveset/ROLL_B.bin"
    insert DOWN_STAND,"moveset/DOWN_STAND.bin"

    DOWN_BOUNCE:
    dw MODEL.FACE.CLOSED
    Moveset.GO_TO(Moveset.shared.DOWN_BOUNCE)

    insert JAB_LOOP_START,"moveset/JAB_LOOP_START.bin"
    JAB_LOOP:
    insert JAB_SUBROUTINE,"moveset/JAB_SUBROUTINE.bin"
    Moveset.GO_TO(JAB_LOOP)              // go to beginning
    insert JAB_LOOP_END,"moveset/JAB_LOOP_END.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Action name constants.
    scope Action {
        constant JAB_LOOP_START(0xDC)
        constant JAB_LOOP(0xDD)
        constant JAB_LOOP_END(0xDE)
        constant USPG_BEGIN(0xE4)
        constant USPG_MOVE(0xE5)
        constant USPG_END(0xE6)
        constant USPA_BEGIN(0xE7)
        constant USPA_MOVE(0xE8)
        constant USPA_END(0xE9)
        constant NSPG_BEGIN(0xEA)
        constant NSPG_CHARGE(0xEB)
        constant NSPG_SHOOT(0xEC)
        constant NSPA_BEGIN(0xED)
        constant NSPA_CHARGE(0xEE)
        constant NSPA_SHOOT(0xEF)
        constant DSP_BEGIN(0xF0)
        constant DSP_ATTACK(0xF1)
        constant DSP_LANDING(0xF2)
        constant DSP_RECOIL(0xF3)

        string_0x0E4:; String.insert("VanishStartGround")
        string_0x0E5:; String.insert("VanishGround")
        string_0x0E6:; String.insert("VanishEndGround")
        string_0x0E7:; String.insert("VanishStartAir")
        string_0x0E8:; String.insert("VanishAir")
        string_0x0E9:; String.insert("VanishEndAir")
        string_0x0EA:; String.insert("NeedleStormStartGround")
        string_0x0EB:; String.insert("NeedleStormChargeGround")
        string_0x0EC:; String.insert("NeedleStormShootGround")
        string_0x0ED:; String.insert("NeedleStormStartAir")
        string_0x0EE:; String.insert("NeedleStormChargeAir")
        string_0x0EF:; String.insert("NeedleStormShootAir")
        string_0x0F0:; String.insert("BouncingFishStart")
        string_0x0F1:; String.insert("BouncingFishAttack")
        string_0x0F2:; String.insert("BouncingFishLanding")
        string_0x0F3:; String.insert("BouncingFishRecoil")

        action_string_table:
        dw Action.COMMON.string_jabloopstart
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw 0
        dw 0
        dw 0
        dw 0
        dw 0
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw string_0x0EA
        dw string_0x0EB
        dw string_0x0EC
        dw string_0x0ED
        dw string_0x0EE
        dw string_0x0EF
        dw string_0x0F0
        dw string_0x0F1
        dw string_0x0F2
        dw string_0x0F3

    }

    // Sound name constants.
    scope FGM {
        constant FIRST_INDEX(1033)                 // < this value has been updated. old hex values in comments for reference
        constant ANNOUNCER(FIRST_INDEX)            // 0x03D4, patch
        constant CROWD_CHANT(FIRST_INDEX + 1)      // 0x03D5, patch
        constant HURT(FIRST_INDEX + 2)             // 0x03D6, main
        constant DEATH(FIRST_INDEX + 3)            // 0x03D7, main
        constant ATTACK_1(FIRST_INDEX + 4)         // 0x03D8, main
        constant JUMP(FIRST_INDEX + 5)             // 0x03D9, moveset cmd
        constant NSP_CHARGE(FIRST_INDEX + 6)       // 0x03DA, asm
        constant NSP_THROW(FIRST_INDEX + 7)        // 0x03DB, asm
        constant ATTACK_2(FIRST_INDEX + 8)         // 0x03DC, main
        constant SLEEP(FIRST_INDEX + 9)            // 0x03DD
        constant STAR_KO(FIRST_INDEX + 10)         // 0x03DE, main
        constant ATTACK_3(FIRST_INDEX + 11)        // 0x03DF, main
        constant USP_POOF(FIRST_INDEX + 12)        // 0x03E0, asm
        constant VICTORY(FIRST_INDEX + 13)         // 0x03E1,
        constant VOICE(FIRST_INDEX + 14)           // 0x03E2, sounds like "tzu"
        constant TAUNT(FIRST_INDEX + 15)           // 0X03E3, moveset cmd (0x418)
        constant HEAVY_LIFT(FIRST_INDEX + 16)      // 0X03E4, main
        constant JAB(FIRST_INDEX + 17)             // 0X03E5, moveset cmd

    }


    // Modify Action Parameters             // Action                       // Animation                        // Moveset Data             // Flags
Character.edit_action_parameters(SHEIK, Action.DeadU,                   File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ScreenKO,                File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Entry,                   File.SHEIK_IDLE,                    IDLE,                         -1)
Character.edit_action_parameters(SHEIK, 0x006,                          File.SHEIK_IDLE,                    IDLE,                         -1)
Character.edit_action_parameters(SHEIK, Action.Revive1,                 File.SHEIK_DOWN_BOUNCE_D,           -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Revive2,                 File.SHEIK_DOWN_STAND_D,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ReviveWait,              File.SHEIK_IDLE,                    IDLE,                         -1)
Character.edit_action_parameters(SHEIK, Action.Idle,                    File.SHEIK_IDLE,                    IDLE,                         -1)
Character.edit_action_parameters(SHEIK, Action.Walk1,                   File.SHEIK_WALK_1,                  -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Walk2,                   File.SHEIK_WALK_2,                  -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Walk3,                   File.SHEIK_WALK_3,                  -1,                         -1)
// Character.edit_action_parameters(SHEIK, 0x00E,                          File.SHEIK_WALK_END,                -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Dash,                    File.SHEIK_DASH,                    DASH,                       -1)
Character.edit_action_parameters(SHEIK, Action.Run,                     File.SHEIK_RUN,                     RUN,                        -1)
Character.edit_action_parameters(SHEIK, Action.RunBrake,                File.SHEIK_RUN_BRAKE,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Turn,                    File.SHEIK_TURN,                    -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.TurnRun,                 File.SHEIK_TURN_RUN,                TURNRUN,                    -1)
Character.edit_action_parameters(SHEIK, Action.JumpSquat,               File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ShieldJumpSquat,         File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.JumpF,                   File.SHEIK_JUMP_F,                  JUMP,                       -1)
Character.edit_action_parameters(SHEIK, Action.JumpB,                   File.SHEIK_JUMP_B,                  JUMP,                       -1)
Character.edit_action_parameters(SHEIK, Action.JumpAerialF,             File.SHEIK_JUMP_AERIAL_F,           JUMP_AERIAL,                -1)
Character.edit_action_parameters(SHEIK, Action.JumpAerialB,             File.SHEIK_JUMP_AERIAL_B,           JUMP_AERIAL,                -1)
Character.edit_action_parameters(SHEIK, Action.Fall,                    File.SHEIK_FALL,                    -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.FallAerial,              File.SHEIK_FALL_AERIAL,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Crouch,                  File.SHEIK_CROUCH,                  CROUCH_START,                         -1)
Character.edit_action_parameters(SHEIK, Action.CrouchIdle,              File.SHEIK_CROUCH_IDLE,             CROUCH_IDLE,                         -1)
Character.edit_action_parameters(SHEIK, Action.CrouchEnd,               File.SHEIK_CROUCH_END,              CROUCH_END,                         -1)
Character.edit_action_parameters(SHEIK, Action.LandingLight,            File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.LandingHeavy,            File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Teeter,                  File.SHEIK_TEETER,                  TEETER,                     -1)
Character.edit_action_parameters(SHEIK, Action.TeeterStart,             File.SHEIK_TEETER_START,            TEETER_START,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageHigh1,             File.SHEIK_DAMAGE_HIGH_1,           -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageHigh2,             File.SHEIK_DAMAGE_HIGH_2,           -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageHigh3,             File.SHEIK_DAMAGE_HIGH_3,           -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageMid1,              File.SHEIK_DAMAGE_MID_1,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageMid2,              File.SHEIK_DAMAGE_MID_2,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageMid3,              File.SHEIK_DAMAGE_MID_3,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageLow1,              File.SHEIK_DAMAGE_LOW_1,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageLow2,              File.SHEIK_DAMAGE_LOW_2,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageLow3,              File.SHEIK_DAMAGE_LOW_3,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageAir1,              File.SHEIK_DAMAGE_AIR_1,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageAir2,              File.SHEIK_DAMAGE_AIR_2,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageAir3,              File.SHEIK_DAMAGE_AIR_3,            -1,                         -1)
 //Character.edit_action_parameters(SHEIK, Action.DamageElec1,             File.SHEIK_DAMAGE_ELEC,             -1,                         -1)
 //Character.edit_action_parameters(SHEIK, Action.DamageElec2,             File.SHEIK_DAMAGE_ELEC,             -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageFlyHigh,           File.SHEIK_DAMAGE_FLY_HIGH,         -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageFlyMid,            File.SHEIK_DAMAGE_FLY_MID,          -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageFlyLow,            File.SHEIK_DAMAGE_FLY_LOW,          -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageFlyTop,            File.SHEIK_DAMAGE_FLY_TOP,          -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.DamageFlyRoll,           File.SHEIK_DAMAGE_FLY_ROLL,         -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.Tumble,                  File.SHEIK_TUMBLE,                  -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.WallBounce,              File.SHEIK_TUMBLE,                  -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.FallSpecial,             File.SHEIK_FALL_SPECIAL,            -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.LandingSpecial,          File.SHEIK_LANDING,                 -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.Tornado,                 File.SHEIK_TUMBLE,                  -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.EnterPipe,               File.SHEIK_ENTER_PIPE,              -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.ExitPipe,                File.SHEIK_EXIT_PIPE,               -1,                         -1)
 Character.edit_action_parameters(SHEIK, Action.ExitPipeWalk,            File.SHEIK_EXIT_PIPE_WALK,          -1,                         -1)
 //Character.edit_action_parameters(SHEIK, Action.CeilingBonk,             File.SHEIK_CEILING_BONK,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownBounceD,             File.SHEIK_DOWN_BOUNCE_D,           DOWN_BOUNCE,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownBounceU,             File.SHEIK_DOWN_BOUNCE_U,           DOWN_BOUNCE,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownStandD,              File.SHEIK_DOWN_STAND_D,            DOWN_STAND,                 -1)
Character.edit_action_parameters(SHEIK, Action.DownStandU,              File.SHEIK_DOWN_STAND_U,            DOWN_STAND,                 -1)
Character.edit_action_parameters(SHEIK, Action.TechF,                   -1,                                 TECHROLL,                   -1)
Character.edit_action_parameters(SHEIK, Action.TechB,                   -1,                                 TECHROLL,                   -1)
Character.edit_action_parameters(SHEIK, Action.DownForwardD,            File.SHEIK_DOWN_FORWARD_D,          -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownForwardU,            File.SHEIK_DOWN_FORWARD_U,          -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownBackD,               File.SHEIK_DOWN_BACK_D,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownBackU,               File.SHEIK_DOWN_BACK_U,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownAttackD,             File.SHEIK_DOWN_ATTACK_D,           FLOORATTACK_D,                         -1)
Character.edit_action_parameters(SHEIK, Action.DownAttackU,             File.SHEIK_DOWN_ATTACK_U,           FLOORATTACK_U,                         -1)
Character.edit_action_parameters(SHEIK, Action.Tech,                    File.SHEIK_TECH,                    TECH,                       -1)
// Character.edit_action_parameters(SHEIK, 0x053,                          File.SHEIK_UNKNOWN_053,             -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.CliffCatch,              File.SHEIK_CLIFF_CATCH,             CLIFF_CATCH,                -1)
// Character.edit_action_parameters(SHEIK, Action.CliffWait,               File.SHEIK_CLIFF_WAIT,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffQuick,              File.SHEIK_CLIFF_QUICK,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffClimbQuick1,        File.SHEIK_CLIFF_ATTACK_QUICK_1,     -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffClimbQuick2,        File.SHEIK_CLIFF_CLIMB_QUICK_2,     -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffSlow,               File.SHEIK_CLIFF_SLOW,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffClimbSlow1,         File.SHEIK_CLIFF_ATTACK_SLOW_1,      -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffClimbSlow2,         File.SHEIK_CLIFF_CLIMB_SLOW_2,      -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffAttackQuick1,       File.SHEIK_CLIFF_ATTACK_QUICK_1,    -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffAttackQuick2,       File.SHEIK_CLIFF_ATTACK_QUICK_2,    CLIFF_ATTACK_QUICK_2,       -1)
Character.edit_action_parameters(SHEIK, Action.CliffAttackSlow1,        File.SHEIK_CLIFF_ATTACK_SLOW_1,     -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffAttackSlow2,        File.SHEIK_CLIFF_ATTACK_SLOW_2,     CLIFF_ATTACK_SLOW_2,        -1)
// Character.edit_action_parameters(SHEIK, Action.CliffEscapeQuick1,       File.SHEIK_CLIFF_ESCAPE_QUICK_1,    -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.CliffEscapeQuick2,       File.SHEIK_CLIFF_ESCAPE_QUICK_2,    -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.CliffEscapeSlow1,        File.SHEIK_CLIFF_ATTACK_SLOW_1,     -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.CliffEscapeSlow2,        File.SHEIK_CLIFF_ESCAPE_SLOW_2,     -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.LightItemPickup,         File.SHEIK_LIGHT_ITEM_PICKUP,       -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.HeavyItemPickup,         File.SHEIK_HEAVY_ITEM_PICKUP,       -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ItemDrop,                File.SHEIK_ITEM_DROP,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ItemThrowDash,           File.SHEIK_ITEM_THROW_DASH,         -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowF,              File.SHEIK_ITEM_THROW,              -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowB,              File.SHEIK_ITEM_THROW,              -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowU,              File.SHEIK_ITEM_THROW_U,            -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowD,              File.SHEIK_ITEM_THROW_D,            -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowSmashF,         File.SHEIK_ITEM_THROW,              -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowSmashB,         File.SHEIK_ITEM_THROW,              -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowSmashU,         File.SHEIK_ITEM_THROW_U,            -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowSmashD,         File.SHEIK_ITEM_THROW_D,            -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowAirF,           File.SHEIK_ITEM_THROW_AIR,          -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowAirB,           File.SHEIK_ITEM_THROW_AIR,          -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ItemThrowAirU,           File.SHEIK_ITEM_THROW_AIR_U,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowAirD,           File.SHEIK_ITEM_THROW_AIR_D,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowAirSmashF,      File.SHEIK_ITEM_THROW_AIR,          -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowAirSmashB,      File.SHEIK_ITEM_THROW_AIR,          -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ItemThrowAirSmashU,      File.SHEIK_ITEM_THROW_AIR_U,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ItemThrowAirSmashF,      File.SHEIK_ITEM_THROW_AIR_D,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.HeavyItemThrowF,         File.SHEIK_HEAVY_ITEM_THROW,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.HeavyItemThrowB,         File.SHEIK_HEAVY_ITEM_THROW,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.HeavyItemThrowSmashF,    File.SHEIK_HEAVY_ITEM_THROW,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.HeavyItemThrowSmashB,    File.SHEIK_HEAVY_ITEM_THROW,        -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BeamSwordNeutral,        File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BeamSwordTilt,           File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BeamSwordSmash,          File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BeamSwordDash,           File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BatNeutral,              File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BatTilt,                 File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BatSmash,                File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.BatDash,                 File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.FanNeutral,              File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.FanTilt,                 File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.FanSmash,                File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.FanDash,                 File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StarRodNeutral,          File.SHEIK_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StarRodTilt,             File.SHEIK_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StarRodSmash,            File.SHEIK_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StarRodDash,             File.SHEIK_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.RayGunShoot,             File.SHEIK_ITEM_SHOOT_GROUND,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.RayGunShootAir,          File.SHEIK_ITEM_SHOOT_AIR,          -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.FireFlowerShoot,         File.SHEIK_ITEM_SHOOT_GROUND,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.FireFlowerShootAir,      File.SHEIK_ITEM_SHOOT_AIR,          -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.HammerIdle,              File.SHEIK_HAMMER_IDLE,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.HammerWalk,              File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.HammerTurn,              File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.HammerJumpSquat,         File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.HammerAir,               File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.HammerLanding,           File.SHEIK_HAMMER_MOVE,             -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ShieldOn,                File.SHEIK_SHIELD_ON,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ShieldOff,               File.SHEIK_SHIELD_OFF,              -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.RollF,                   File.SHEIK_ROLL_F,                  ROLL_F,                         -1)
Character.edit_action_parameters(SHEIK, Action.RollB,                   File.SHEIK_ROLL_B,                  ROLL_B,                         -1)
Character.edit_action_parameters(SHEIK, Action.ShieldBreak,             -1,                                 SHIELD_BREAK,               -1)
Character.edit_action_parameters(SHEIK, Action.ShieldBreakFall,         File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StunLandD,               File.SHEIK_DOWN_BOUNCE_D,           -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StunLandU,               File.SHEIK_DOWN_BOUNCE_U,           -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StunStartD,              File.SHEIK_DOWN_STAND_D,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.StunStartU,              File.SHEIK_DOWN_STAND_U,            -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Stun,                    File.SHEIK_STUN,                    STUN,                         -1)
Character.edit_action_parameters(SHEIK, Action.Sleep,                   File.SHEIK_STUN,                    ASLEEP,                         -1)
Character.edit_action_parameters(SHEIK, Action.Grab,                    File.SHEIK_GRAB,                    GRAB,                       -1)
Character.edit_action_parameters(SHEIK, Action.GrabPull,                File.SHEIK_GRAB_PULL,               -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.ThrowF,                  File.SHEIK_THROW_F,                 THROW_F,                    -1)
Character.edit_action_parameters(SHEIK, Action.ThrowB,                  File.SHEIK_THROW_B,                 THROW_B,                    -1)
// Character.edit_action_parameters(SHEIK, Action.CapturePulled,           File.SHEIK_CAPTURE_PULLED,          -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.InhalePulled,            File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.InhaleSpat,              File.SHEIK_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.InhaleCopied,            File.SHEIK_TUMBLE,                  -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.EggLayPulled,            File.SHEIK_CAPTURE_PULLED,          -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.EggLay,                  File.SHEIK_IDLE,                    -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.FalconDivePulled,        File.SHEIK_DAMAGE_HIGH_3,           -1,                         -1)
Character.edit_action_parameters(SHEIK, 0x0B4,                          File.SHEIK_TUMBLE,                  -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ThrownDKPulled,          File.SHEIK_THROWN_DK_PULLED,        -1,                         -1)
// Character.edit_action_parameters(SHEIK, 0x0B6,                          File.SHEIK_UNKNOWN_0B6,             -1,                         -1)
// Character.edit_action_parameters(SHEIK, 0x0B7,                          -1,                                 -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.ThrownDK,                File.SHEIK_THROWN_DK,               -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.Thrown1,                 File.SHEIK_THROWN_1,                -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.Thrown2,                 File.SHEIK_THROWN_2,                -1,                         -1)
// Character.edit_action_parameters(SHEIK, Action.Thrown3,                 -1,                                 -1,                         -1)
// Character.edit_action_parameters(SHEIK, 0x0BC,                          -1,                                 -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.Taunt,                   File.SHEIK_TAUNT,                   TAUNT,                      -1)
Character.edit_action_parameters(SHEIK, Action.Jab1,                    File.SHEIK_JAB_1,                   JAB_1,                      -1)
Character.edit_action_parameters(SHEIK, Action.Jab2,                    File.SHEIK_JAB_2,                   JAB_2,                      -1)
Character.edit_action_parameters(SHEIK, Action.JAB_LOOP_START,          File.SHEIK_JAB_LOOP_START,          JAB_LOOP_START,             -1)
Character.edit_action_parameters(SHEIK, Action.JAB_LOOP,                File.SHEIK_JAB_LOOP,                JAB_LOOP,                   -1)
Character.edit_action_parameters(SHEIK, Action.JAB_LOOP_END,            File.SHEIK_JAB_LOOP_END,            JAB_LOOP_END,               -1)

Character.edit_action_parameters(SHEIK, Action.DashAttack,              File.SHEIK_DASH_ATTACK,             DASH_ATTACK,                -1)
Character.edit_action_parameters(SHEIK, Action.FTiltHigh,               0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.FTiltMidHigh,            0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.FTilt,                   File.SHEIK_F_TILT,                  F_TILT,                     -1)
Character.edit_action_parameters(SHEIK, Action.FTiltMidLow,             0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.FTiltLow,                0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.UTilt,                   File.SHEIK_U_TILT,                  U_TILT,                     -1)
Character.edit_action_parameters(SHEIK, Action.DTilt,                   File.SHEIK_D_TILT,                  D_TILT,                     -1)
Character.edit_action_parameters(SHEIK, Action.FSmashHigh,              0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.FSmashMidHigh,           0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.FSmash,                  File.SHEIK_F_SMASH,                 F_SMASH,                    -1)
Character.edit_action_parameters(SHEIK, Action.FSmashMidLow,            0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.FSmashLow,               0,                                  0x80000000,                 0)
Character.edit_action_parameters(SHEIK, Action.USmash,                  File.SHEIK_U_SMASH,                 U_SMASH,                    -1)
Character.edit_action_parameters(SHEIK, Action.DSmash,                  File.SHEIK_D_SMASH,                 D_SMASH,                    -1)
Character.edit_action_parameters(SHEIK, Action.AttackAirN,              File.SHEIK_ATTACK_AIR_N,            ATTACK_AIR_N,               -1)
Character.edit_action_parameters(SHEIK, Action.AttackAirF,              File.SHEIK_ATTACK_AIR_F,            ATTACK_AIR_F,               -1)
Character.edit_action_parameters(SHEIK, Action.AttackAirB,              File.SHEIK_ATTACK_AIR_B,            ATTACK_AIR_B,               -1)
Character.edit_action_parameters(SHEIK, Action.AttackAirU,              File.SHEIK_ATTACK_AIR_U,            ATTACK_AIR_U,               -1)
Character.edit_action_parameters(SHEIK, Action.AttackAirD,              File.SHEIK_ATTACK_AIR_D,            ATTACK_AIR_D,               -1)
Character.edit_action_parameters(SHEIK, Action.LandingAirN,             File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.LandingAirF,             File.SHEIK_LANDING_AIR_F,           -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.LandingAirB,             File.SHEIK_LANDING_AIR_B,           -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.LandingAirU,             File.SHEIK_LANDING_AIR_U,           -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.LandingAirD,             File.SHEIK_LANDING,                 -1,                         -1)
Character.edit_action_parameters(SHEIK, Action.LandingAirX,             File.SHEIK_LANDING,                 -1,                         -1)

   Character.edit_action_parameters(SHEIK, Action.USPG_BEGIN,              File.SHEIK_USPG_BEGIN,              USP_BEGIN,                  0)
   Character.edit_action_parameters(SHEIK, Action.USPG_MOVE,               -1,                                 USP_MOVE,                   -1)
   Character.edit_action_parameters(SHEIK, Action.USPG_END,                File.SHEIK_USPG_END,                USP_END,                    0)
   Character.edit_action_parameters(SHEIK, Action.USPA_BEGIN,              File.SHEIK_USPA_BEGIN,              USP_BEGIN,                  0)
   Character.edit_action_parameters(SHEIK, Action.USPA_MOVE,               -1,                                 USP_MOVE,                   -1)
   Character.edit_action_parameters(SHEIK, Action.USPA_END,                File.SHEIK_USPA_END,                USP_END,                    0)
   Character.edit_action_parameters(SHEIK, Action.NSPG_BEGIN,              File.SHEIK_NSPG_BEGIN,              NSP_BEGIN,                  0)
   Character.edit_action_parameters(SHEIK, Action.NSPG_CHARGE,             File.SHEIK_NSPG_CHARGE,             NSP_CHARGE,                 0)
   Character.edit_action_parameters(SHEIK, Action.NSPG_SHOOT,              File.SHEIK_NSPG_SHOOT,              NSP_SHOOT,                  0)
   Character.edit_action_parameters(SHEIK, Action.NSPA_BEGIN,              File.SHEIK_NSPA_BEGIN,              NSP_BEGIN,                  0)
   Character.edit_action_parameters(SHEIK, Action.NSPA_CHARGE,             File.SHEIK_NSPA_CHARGE,             NSP_CHARGE,                 0)
   Character.edit_action_parameters(SHEIK, 0xE0,                           File.SHEIK_ENTRY_LEFT,              ENTRY,                     0x40000009)
   Character.edit_action_parameters(SHEIK, 0xE1,                           File.SHEIK_ENTRY_RIGHT,             ENTRY,                     0x40000009)

   // Modify Actions            // Action              // Staling ID    // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
   Character.edit_action(SHEIK, Action.JAB_LOOP_START, 0x4,            0x8014F0D0,                    0,                              0x800D8C14,                    0x800DDF44)
   Character.edit_action(SHEIK, Action.JAB_LOOP,       0x4,            0x8014F2A8,                    0x8014F388,                     0x800D8C14,                    0x800DDF44)
   Character.edit_action(SHEIK, Action.JAB_LOOP_END,   0x4,            0x800D94C4,                    0,                              0x800D8C14,                    0x800DDF44)

   Character.edit_action(SHEIK, Action.USPG_BEGIN,     0x11,            SheikUSP.begin_main_,          0,                               0x800D8BB4,                     SheikUSP.ground_begin_collision_)
   Character.edit_action(SHEIK, Action.USPG_MOVE,      0x11,            SheikUSP.move_main_,           0,                               SheikUSP.move_physics_,         SheikUSP.ground_move_collision_)
   Character.edit_action(SHEIK, Action.USPG_END,       0x11,            SheikUSP.ground_end_main_,     0,                               0x800D8BB4,                     SheikUSP.end_collision_)
   Character.edit_action(SHEIK, Action.USPA_BEGIN,     0x11,            SheikUSP.begin_main_,          0,                               0x800D90E0,                     SheikUSP.air_begin_collision_)
   Character.edit_action(SHEIK, Action.USPA_MOVE,      0x11,            SheikUSP.move_main_,           0,                               SheikUSP.move_physics_,         SheikUSP.air_move_collision_)
   Character.edit_action(SHEIK, Action.USPA_END,       0x11,            SheikUSP.air_end_main_,        0,                               SheikUSP.end_physics_,          SheikUSP.end_collision_)
   Character.edit_action(SHEIK, Action.NSPG_BEGIN,     0x12,            SheikNSP.begin_main_,          SheikNSP.ground_begin_interrupt_,                      0x800D8BB4,                     SheikNSP.ground_begin_collision_)  //NSP_Ground_Begin
   Character.edit_action(SHEIK, Action.NSPG_CHARGE,    0x12,            SheikNSP.charge_main_,         SheikNSP.ground_charge_interrupt_, 0x800D8BB4,                   SheikNSP.ground_charge_collision_) //NSP_Ground_Charge
   Character.edit_action(SHEIK, Action.NSPG_SHOOT,     0x12,            SheikNSP.shoot_main_,          0,                               0x800D8BB4,                     SheikNSP.ground_shoot_collision_)  //NSP_Ground_Shoot
   Character.edit_action(SHEIK, Action.NSPA_BEGIN,     0x12,            SheikNSP.begin_main_,          SheikNSP.air_begin_interrupt_,                      0x800D90E0,                     SheikNSP.air_begin_collision_)     //NSP_Air_Begin
   Character.edit_action(SHEIK, Action.NSPA_CHARGE,    0x12,            SheikNSP.charge_main_,         SheikNSP.air_charge_interrupt_,  0x800D91EC,                     SheikNSP.air_charge_collision_)    //NSP_Air_Charge
   Character.edit_action(SHEIK, 0xE0,                   -1,            0x8013DA94,                    0,                              0x8013DB2C,                    0x800DE348)   // LEFT ENTRY
   Character.edit_action(SHEIK, 0xE1,                   -1,            0x8013DA94,                    0,                              0x8013DB2C,                    0x800DE348)   // RIGHT ENTRY

    Character.edit_action(SHEIK, Action.DSP_RECOIL,     0x13,            SheikDSP.recoil_main_,         0,                               SheikDSP.recoil_physics_,       0x800DE99C)
    // Modify Menu Action Parameters             // Action      // Animation                // Moveset Data             // Flags

    Character.edit_menu_action_parameters(SHEIK, 0x0,           File.SHEIK_IDLE,            -1,                         -1)
    Character.edit_menu_action_parameters(SHEIK, 0x1,           File.SHEIK_VICTORY_3,       VICTORY_3,                  -1)
    Character.edit_menu_action_parameters(SHEIK, 0x2,           File.SHEIK_VICTORY_1,       VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(SHEIK, 0x3,           File.SHEIK_VICTORY_2,       VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(SHEIK, 0x4,           File.SHEIK_VICTORY_3,       VICTORY_3,                  -1)
    Character.edit_menu_action_parameters(SHEIK, 0x5,           File.SHEIK_CLAP,            -1,                         -1)
    Character.edit_menu_action_parameters(SHEIK, 0xD,           File.SHEIK_1P,              ONEP,                       -1)
    Character.edit_menu_action_parameters(SHEIK, 0xE,           File.SHEIK_1P_CPU,          CPU,                        -1)
    Character.edit_menu_action_parameters(SHEIK, 0x9,           File.SHEIK_PUPPET_FALL,     -1,                         -1)
    Character.edit_menu_action_parameters(SHEIK, 0xA,           File.SHEIK_PUPPET_UP,       -1,                         -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(SHEIK,  NSP_Shoot_Air,      -1,             File.SHEIK_NSPA_SHOOT,      NSP_SHOOT,                  0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Begin,          -1,             File.SHEIK_DSP_BEGIN,       DSP_BEGIN,                  0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Attack,         -1,             File.SHEIK_DSP_ATTACK,      DSP_ATTACK,                 0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Landing,        -1,             File.SHEIK_DSP_LANDING,     DSP_LANDING,                0x00000000)
    Character.add_new_action_params(SHEIK,  DSP_Recoil,         -1,             File.SHEIK_DSP_RECOIL,      DSP_RECOIL,                 0x00000000)

    // Add Actions                  // Action Name      // Base Action  // Parameters                       // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(SHEIK, NSP_Shoot_Air,      -1,             ActionParams.NSP_Shoot_Air,         0x12,           SheikNSP.shoot_main_,       0,                              0x800D91EC,                         0x800DE934)
    Character.add_new_action(SHEIK, DSP_Begin,          -1,             ActionParams.DSP_Begin,             0x13,           SheikDSP.main_,             0,                              SheikDSP.physics_,                  SheikDSP.air_collision_)
    Character.add_new_action(SHEIK, DSP_Attack,         -1,             ActionParams.DSP_Attack,            0x13,           0x800D94E8,                 0,                              SheikDSP.physics_,                  SheikDSP.attack_collision_)
    Character.add_new_action(SHEIK, DSP_Landing,        -1,             ActionParams.DSP_Landing,           0x13,           0x800D94C4,                 0,                              0x800D8CCC,                         0x800DDEE8)
    Character.add_new_action(SHEIK, DSP_Recoil,         -1,             ActionParams.DSP_Recoil,            0x13,           SheikDSP.recoil_main_,      0,                              SheikDSP.recoil_physics_,           0x800DE99C)


     // Set action strings
     Character.table_patch_start(action_string, Character.id.SHEIK, 0x4)
     dw  Action.action_string_table
     OS.patch_end()

    Character.table_patch_start(air_usp, Character.id.SHEIK, 0x4)
    dw      SheikUSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.SHEIK, 0x4)
    dw      SheikUSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.SHEIK, 0x4)
    dw      SheikDSP.initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.SHEIK, 0x4)
    dw      SheikDSP.initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.SHEIK, 0x4)
    dw      SheikNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_nsp, Character.id.SHEIK, 0x4)
    dw      SheikNSP.air_begin_initial_
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.SHEIK, 0x2)
    dh  Sheik.FGM.CROWD_CHANT
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.SHEIK, 0xC)
    dh 0x1E
    OS.patch_end()

    // Set rapid jab begin action.
    Character.table_patch_start(rapid_jab_begin_action, Character.id.SHEIK, 0x4)
    dw 0x8014F13C
    OS.patch_end()

    // Set rapid jab loop action.
    Character.table_patch_start(rapid_jab_loop_action, Character.id.SHEIK, 0x4)
    dw 0x8014F3F4
    OS.patch_end()

    // Set rapid jab end action.
    Character.table_patch_start(rapid_jab_ending_action, Character.id.SHEIK, 0x4)
    dw 0x8014F490
    OS.patch_end()

    // Patches for full charge Neutral B effect removal.
    Character.table_patch_start(gfx_routine_end, Character.id.SHEIK, 0x4)
    dw      charge_gfx_routine_
    OS.patch_end()

    // For spawning, clears out charges of nsp
    Character.table_patch_start(initial_script, Character.id.SHEIK, 0x4)
    dw      0x800D7DEC                      // use samus jump
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.SHEIK, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.SHEIK, 0, 3, 4, 5, 1, 0, 2)
    Teams.add_team_costume(YELLOW, SHEIK, 0x6)

    // Set default costume shield colors
    Character.set_costume_shield_colors(SHEIK, BLUE, RED, GREEN, PURPLE, BLACK, WHITE, YELLOW, NA)

    Character.table_patch_start(variants, Character.id.SHEIK, 0x4)
    db      Character.id.NONE
    db      Character.id.NSHEIK // set as POLYGON variant for SHEIK
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    Character.table_patch_start(variant_original, Character.id.NSHEIK, 0x4)
    dw      Character.id.SHEIK // set Sheik as original character (not Captain Falcon, who NSHEIK is a clone of)
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.SHEIK, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.SHEIK, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
    OS.patch_end()

	// Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.SHEIK, 0x4)
    dw    	AI.LONG_RANGE.ROUTINE.NSP_SHOOT
    OS.patch_end()

    // Edit cpu attack behaviours
    // Most of Sheiks attacks were manually updated with hex-edits.
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  -1,  -1,  250, 500, -500, -250)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  -1,  -1,  500, 1500, 200, 445)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,   0,   0,    0,    0,   0,   0) // no attack with Up Special
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  -1,  -1,    0,    0,   0,   0) // no attack with Up Special
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  -1,  -1,  180, 850, 100, 400)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  -1,  -1,  180, 850, 100, 400)

    // an associated moveset command: b0bc0000 removes the white flicker, this is identical to Samus
    // @ Description
    // Jump table patch which enables Sheik's charged neutral b effect when another gfx routine ends, or upon action change.
    scope charge_gfx_routine_: {
        lw      t9, 0x0AE0(a3)              // t9 = charge level
        lli     at, 0x0006                  // at = 7
        lw      a0, 0x0020(sp)              // a0 = player object
        bne     t9, at, _end                // skip if charge level != 7 (full)
        lli     a1, GFXRoutine.id.SHEIK_CHARGE // a1 = SHEIK_CHARGE id

        // if the neutral special is full charged
        or      a2, r0, r0                  // a2 = 0
        jal     0x800E9814                  // begin gfx routine
        sw      a3, 0x001C(sp)              // store a3

        _end:
        j       0x800E9A60                  // return
        lw      a3, 0x001C(sp)              // load a3
    }
}