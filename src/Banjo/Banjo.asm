// Banjo.asm

// This file contains file inclusions, action edits, and assembly for Banjo the Honey Bear and Kazooie the Breegull.

scope Banjo {
    // Insert Moveset files

    scope MODEL {
        scope FACE {
            constant DEFAULT(0xA0600000)
            constant HURT(0xA0600001)
            constant ANGRY(0xA0600002)
            constant LOOK(0xA0600003)
        }

        scope HAND_R {
            constant DEFAULT(0xA0800000)
            constant OPEN(0xA0800001)
            constant FEET(0xA0800002)
            constant JIGGY(0xA0800003)
        }

        scope HAND_L {
            constant DEFAULT(0xA0500000)
            constant OPEN(0xA0500001)
        }

        scope KAZOOIE_HEAD {
            constant DEFAULT(0xA0A80000)
            constant OPEN(0xA0A80001)
            constant TAIL(0xA0A80002)
            constant ANGRY(0xA0A80003)
            constant LOOK(0xA0A80004)
            constant KAZOO(0xA0A80005)
        }
        scope KAZOOIE_BODY {
            constant DEFAULT(0xA0900000)
            constant WAIST(0xA0900001)
            constant FULL(0xA0900002)
        }
    }

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    DASH:; insert "moveset/DASH.bin"
    TURN:; insert "moveset/TURN.bin"

    JUMP_1:
    Moveset.VOICE(0x508);
    insert JUMP,"Moveset/JUMP_1.bin"

    JUMP_2:
    insert JUMP2,"Moveset/JUMP_2.bin"

    insert TECH, "moveset/TECH.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"

    CSS:; insert "moveset/CSS.bin"
	VICTORY2:; insert "moveset/VICTORY2.bin"
	VICTORY3:; insert "moveset/VICTORY3.bin"

    CONTINUE:
	dw  0x00000000	// end

	CONTINUE_UP:
	dw	0x040000AF	// Wait 175 frames
	dw  0xA0600003	// Banjo Face Look
    dw  0xA0A80004	// Kazooie Face Look
	dw  0x00000000	// end

	CPU_POSE:
	dw  0xA0A80005	// Kazooie Head Kazoo
	dw  0xA0800001  // Hand R Open
	dw  0xA0500001  // Hand L Open
	dw  0xA1200001  // Banjo Grab Joint
	dw  0x00000000  // End


    SPARKLE_ENTRY:
    dw  0x80000010  // set loops
    dw  0x04000001  // wait
    dw  0x9801D400  // Red Sparkle Effect
    dw  0x00000000
    dw  0xFCE00000  // z location
    dw  0x00000000
    dw  0x84000000  // end loop
    dw  0x00000000  // end stream
	ENTRY:;
    Moveset.CONCURRENT_STREAM(SPARKLE_ENTRY);
    insert "moveset/ENTRY.bin"

    CLAP:
    dw MODEL.FACE.LOOK;
    dw MODEL.KAZOOIE_HEAD.LOOK;
    dw MODEL.HAND_R.OPEN
    dw MODEL.HAND_L.OPEN
    dw 0;

    TAUNT:
    Moveset.WAIT(9);
    Moveset.VOICE(0x538)
    Moveset.WAIT(47);
    Moveset.VOICE(0x538)
    Moveset.WAIT(20);
    Moveset.SET_FLAG(1);
    Moveset.END()

    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN) // loops

    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops

    DAMAGED_FACE:; dw MODEL.FACE.HURT; dw 0;
    DMG_1:; Moveset.SUBROUTINE(DAMAGED_FACE); dw 0
    DMG_2:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0x270); dw 0
    FALCON_DIVE_PULLED:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF44); dw 0
    UNKNOWN_0B4:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF58); dw 0

    DOWN_BOUNCE:
    dw MODEL.FACE.HURT;
    Moveset.GO_TO(Moveset.shared.DOWN_BOUNCE)

    DOWNATTACKU:; insert "moveset/DOWNATTACKU.bin"
    DOWNATTACKD:; insert "moveset/DOWNATTACKD.bin"
    CLIFF_ATTACK_QUICK_2:; insert "moveset/CLIFF_ATTACK_QUICK_2.bin"
    CLIFF_ATTACK_SLOW_2:; insert "moveset/CLIFF_ATTACK_SLOW_2.bin"

    JAB1:; insert "moveset/JAB1.bin"
    JAB2:; insert "moveset/JAB2.bin"
    JAB3:; insert "moveset/JAB3.bin"
    U_TILT:; insert "moveset/U_TILT.bin"
    D_TILT:; insert "moveset/D_TILT.bin"
    F_TILT_HIGH:; insert "moveset/F_TILT_HIGH.bin"
    F_TILT_MID:; insert "moveset/F_TILT_MID.bin"
    F_TILT_LOW:; insert "moveset/F_TILT_LOW.bin"
    U_SMASH:; insert "moveset/U_SMASH.bin"
    D_SMASH:; insert "moveset/D_SMASH.bin"
    F_SMASH:; insert "moveset/F_SMASH.bin"
    ATTACK_AIR_N:; insert "moveset/ATTACK_AIR_N.bin"
    ATTACK_AIR_F:; insert "moveset/ATTACK_AIR_F.bin"
    ATTACK_AIR_B:; insert "moveset/ATTACK_AIR_B.bin"
    ATTACK_AIR_U:; insert "moveset/ATTACK_AIR_U.bin"
    ATTACK_AIR_D:; insert "moveset/ATTACK_AIR_D.bin"

    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"

    NSP_BEGIN:
    Moveset.END();

    NSP_FORWARD:
	dw 0xA0A80001;
	dw 0xA0900001;
    Moveset.VOICE(0x504)
    Moveset.WAIT(4);
    Moveset.SET_FLAG(0);
    Moveset.WAIT(4)
    Moveset.SET_FLAG(1);
	Moveset.WAIT(9)
	dw 0xA0A80000;
    Moveset.END();

    NSP_BACKWARD:
	dw 0xA0980001;
	dw 0xA0A80002;
    Moveset.WAIT(4);
    Moveset.VOICE(0x505)
    Moveset.SET_FLAG(0);
    Moveset.WAIT(4)
    Moveset.SET_FLAG(1);
    Moveset.END();

    // USP
    insert USP_BEGIN,"moveset/USP_BEGIN.bin"
    insert USP_TRAIL,"moveset/USP_TRAIL.bin"
    USP_ATTACK:; Moveset.CONCURRENT_STREAM(USP_TRAIL); insert "moveset/USP_ATTACK.bin"
    USP_ATTACK_END:
    dw 0x58000001
    dw 0x00000000
    USP_RECOIL:
    dw 0x18000000
    Moveset.VOICE(0x0511)
    Moveset.WAIT(4)
    dw 0x58000001
    Moveset.WAIT(8)
    dw 0x54000001
    dw 0
    USP_SPLAT:; insert "moveset/USP_SPLAT.bin"

    // DSP
    insert DSP_LANDING,"moveset/DOWN_SPECIAL_LANDING.bin"
    insert DSP_GROUND,"moveset/DOWN_SPECIAL_GROUND.bin"
    insert DSP_AIR,"moveset/DOWN_SPECIAL_AIR.bin"
    insert DSP_AIR_LOOP,"moveset/DOWN_SPECIAL_AIR_LOOP.bin"

    // THROWS
    insert THROW_B_DATA,"moveset/THROW_B_DATA.bin"
    THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); insert "moveset/THROW_B.bin"
    insert THROW_F_DATA,"moveset/THROW_F_DATA.bin"
    THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); insert "moveset/THROW_F.bin"

    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops

    // @ Description
    // Banjo's extra actions
    scope Action {
        constant EntryR(0xDC)
        constant EntryL(0xDD)
        constant Jab3(0xDE)
        // DF
        // E0
        constant NSPBeginG(0xE1)
        constant NSPForwardG(0xE2)
        constant NSPBackwardG(0xE3)
        constant NSPBeginA(0xE4)
        constant NSPForwardA(0xE5)
        constant NSPBackwardA(0xE6)
        constant DSPA(0xE7)
        constant DSPLand(0xE8)
        constant DSPG(0xE9)
        constant DSPGAir(0xEA)
        constant DSPALoop(0xEB)

        //string_0x0DE:; String.insert("Jab3")
        // string_0x0DF:; String.insert("")
        //string_0x0E0:; String.insert("")
        string_0x0E1:; String.insert("EggBeginGround")
        string_0x0E2:; String.insert("FireEggGround")
        string_0x0E3:; String.insert("EggBounceGround")
        string_0x0E4:; String.insert("EggBeginAir")
        string_0x0E5:; String.insert("FireEggAir")
        string_0x0E6:; String.insert("EggBounceAir")
        string_0x0E7:; String.insert("BillDrillStart")
        string_0x0E8:; String.insert("BillDrillLand")
        string_0x0E9:; String.insert("BeakBargeGround")
        string_0x0EA:; String.insert("BeakBargeAir")
        string_0x0EB:; String.insert("BillDrill")
        string_0x0EC:; String.insert("Flight")
        string_0x0ED:; String.insert("BeakBomb")
        string_0x0EE:; String.insert("BeakBombEnd")
        string_0x0EF:; String.insert("BeakBombRecoil")
        string_0x0F0:; String.insert("BeakBombSplat")

        action_string_table:
        dw 0
        dw 0
        dw Action.COMMON.string_jab3
        dw 0
        dw 0
        dw string_0x0E1
        dw string_0x0E2
        dw string_0x0E3
        dw string_0x0E4
        dw string_0x0E5
        dw string_0x0E6
        dw string_0x0E7
        dw string_0x0E8
        dw string_0x0E9
        dw string_0x0EA
        dw string_0x0EB
        dw 0
        dw 0
        dw 0
        dw string_0x0EC
        dw string_0x0ED
        dw string_0x0EE
        dw string_0x0EF
        dw string_0x0F0
    }

    // Modify Action Parameters             // Action                       // Animation                        // Moveset Data             // Flags
    Character.edit_action_parameters(BANJO, Action.DeadU,                   File.BANJO_TUMBLE,                  DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ScreenKO,                File.BANJO_TUMBLE,                  DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Entry,                   File.BANJO_IDLE,                    -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, 0x006,                          File.BANJO_IDLE,                    -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Revive1,                 File.BANJO_DOWN_BNCE_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Revive2,                 File.BANJO_DOWN_STND_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ReviveWait,              File.BANJO_IDLE,                    -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Idle,                    File.BANJO_IDLE,                    -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Walk1,                   File.BANJO_WALK_1,                  -1,                         0x00000000)
    Character.edit_action_parameters(BANJO, Action.Walk2,                   File.BANJO_WALK_2,                  -1,                         0x00000000)
    Character.edit_action_parameters(BANJO, Action.Walk3,                   File.BANJO_WALK_3,                  -1,                         0x00000000)
    Character.edit_action_parameters(BANJO, 0x00E,                          File.BANJO_WALK_END,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Dash,                    File.BANJO_DASH,                    DASH,                       -1)
    Character.edit_action_parameters(BANJO, Action.Run,                     File.BANJO_RUN,                     -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.RunBrake,                File.BANJO_RUN_BRAKE,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Turn,                    File.BANJO_TURN,                    TURN,                       -1)
    Character.edit_action_parameters(BANJO, Action.TurnRun,                 File.BANJO_TURN_RUN,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.JumpSquat,               File.BANJO_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ShieldJumpSquat,         File.BANJO_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.JumpF,                   File.BANJO_JUMP_F,                  JUMP_1,                     -1)
    Character.edit_action_parameters(BANJO, Action.JumpB,                   File.BANJO_JUMP_B,                  JUMP_1,                     0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.JumpAerialF,             File.BANJO_JUMP_AERIAL_F,           JUMP_2,                     0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.JumpAerialB,             File.BANJO_JUMP_AERIAL_B,           JUMP_2,                     0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Fall,                    File.BANJO_FALL,                    -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FallAerial,              File.BANJO_FALL_AERIAL,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Crouch,                  File.BANJO_CROUCH,                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CrouchIdle,              File.BANJO_CROUCH_IDLE,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CrouchEnd,               File.BANJO_CROUCH_END,              -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.LandingLight,            File.BANJO_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.LandingHeavy,            File.BANJO_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Pass,                    File.BANJO_PLAT_DROP,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ShieldDrop,              File.BANJO_PLAT_DROP,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Teeter,                  File.BANJO_TEETER,                  0x80000000,                 0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.TeeterStart,             File.BANJO_TEETERSTART,             0x80000000,                 0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DamageHigh1,             File.BANJO_DMG_HIGH_1,              DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageHigh2,             File.BANJO_DMG_HIGH_2,              DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageHigh3,             File.BANJO_DMG_HIGH_3,              DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageMid1,              File.BANJO_DMG_MID_1,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageMid2,              File.BANJO_DMG_MID_2,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageMid3,              File.BANJO_DMG_MID_3,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageLow1,              File.BANJO_DMG_LOW_1,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageLow2,              File.BANJO_DMG_LOW_2,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageLow3,              File.BANJO_DMG_LOW_3,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageAir1,              File.BANJO_DMG_AIR_1,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageAir2,              File.BANJO_DMG_AIR_2,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageAir3,              File.BANJO_DMG_AIR_3,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageElec1,             File.BANJO_DMG_ELEC,                DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageElec2,             File.BANJO_DMG_ELEC,                DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageFlyHigh,           File.BANJO_DMG_FLY_HIGH,            DMG_2,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageFlyMid,            File.BANJO_DMG_FLY_MID,             DMG_2,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageFlyLow,            File.BANJO_DMG_FLY_LOW,             DMG_2,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageFlyTop,            File.BANJO_DMG_FLY_TOP,             DMG_2,                         -1)
    Character.edit_action_parameters(BANJO, Action.DamageFlyRoll,           File.BANJO_DMG_FLY_ROLL,            DMG_2,                         -1)
    Character.edit_action_parameters(BANJO, Action.WallBounce,              File.BANJO_TUMBLE,                  DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Tumble,                  File.BANJO_TUMBLE,                  DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FallSpecial,             File.BANJO_FALL_SPECIAL,            -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.LandingSpecial,          File.BANJO_USP_LAND,                -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Tornado,                 File.BANJO_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.EnterPipe,               File.BANJO_ENTER_PIPE,              -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ExitPipe,                File.BANJO_EXIT_PIPE,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ExitPipeWalk,            File.BANJO_EXIT_PIPE_WALK,          -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CeilingBonk,             File.BANJO_CEILING_BONK,            -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DownBounceD,             File.BANJO_DOWN_BNCE_D,             DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(BANJO, Action.DownBounceU,             File.BANJO_DOWN_BNCE_U,             DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(BANJO, Action.DownStandD,              File.BANJO_DOWN_STND_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DownStandU,              File.BANJO_DOWN_STND_U,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.TechF,                   File.BANJO_TECH_F,                  TECH_ROLL,                       -1)
    Character.edit_action_parameters(BANJO, Action.TechB,                   File.BANJO_TECH_B,                  TECH_ROLL,                       -1)
    Character.edit_action_parameters(BANJO, Action.DownForwardD,            File.BANJO_DOWN_FWRD_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DownForwardU,            File.BANJO_DOWN_FWRD_U,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DownBackD,               File.BANJO_DOWN_BACK_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DownBackU,               File.BANJO_DOWN_BACK_U,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.DownAttackD,             File.BANJO_DOWN_ATK_D,              DOWNATTACKD,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DownAttackU,             File.BANJO_DOWN_ATK_U,              DOWNATTACKU,                0x10000000)
    Character.edit_action_parameters(BANJO, Action.Tech,                    File.BANJO_TECH,                    TECH,                       -1)
    Character.edit_action_parameters(BANJO, Action.ClangRecoil,             File.BANJO_CLANG_RECOIL,            -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffCatch,              File.BANJO_CLF_CATCH,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffWait,               File.BANJO_CLF_WAIT,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffQuick,              File.BANJO_CLF_QUICK,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffClimbQuick1,        File.BANJO_CLF_CLM_Q_1,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffClimbQuick2,        File.BANJO_CLF_CLM_Q_2,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffSlow,               File.BANJO_CLF_SLOW,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffClimbSlow1,         File.BANJO_CLF_CLM_S_1,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffClimbSlow2,         File.BANJO_CLF_CLM_S_2,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffAttackQuick1,       File.BANJO_CLF_ATK_Q_1,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffAttackQuick2,       File.BANJO_CLF_ATK_Q_2,             CLIFF_ATTACK_QUICK_2,       -1)
    Character.edit_action_parameters(BANJO, Action.CliffAttackSlow1,        File.BANJO_CLF_ATK_S_1,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffAttackSlow2,        File.BANJO_CLF_ATK_S_2,             CLIFF_ATTACK_SLOW_2,        0x4FE00000)
    Character.edit_action_parameters(BANJO, Action.CliffEscapeQuick1,       File.BANJO_CLF_ESC_Q_1,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffEscapeQuick2,       File.BANJO_CLF_ESC_Q_2,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffEscapeSlow1,        File.BANJO_CLF_ESC_S_1,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.CliffEscapeSlow2,        File.BANJO_CLF_ESC_S_2,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.LightItemPickup,         File.BANJO_L_ITM_PICKUP,            -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.HeavyItemPickup,         File.BANJO_H_ITM_PICKUP,            -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemDrop,                File.BANJO_ITM_DROP,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowDash,           File.BANJO_ITM_THROW_DASH,          -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowF,              File.BANJO_ITM_THROW_F,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowB,              File.BANJO_ITM_THROW_F,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowU,              File.BANJO_ITM_THROW_U,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowD,              File.BANJO_ITM_THROW_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowSmashF,         File.BANJO_ITM_THROW_F,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowSmashB,         File.BANJO_ITM_THROW_F,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowSmashU,         File.BANJO_ITM_THROW_U,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowSmashD,         File.BANJO_ITM_THROW_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirF,           File.BANJO_ITM_THROW_AIR_F,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirB,           File.BANJO_ITM_THROW_AIR_F,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirU,           File.BANJO_ITM_THROW_AIR_U,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirD,           File.BANJO_ITM_THROW_AIR_D,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirSmashF,      File.BANJO_ITM_THROW_AIR_F,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirSmashB,      File.BANJO_ITM_THROW_AIR_F,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirSmashU,      File.BANJO_ITM_THROW_AIR_U,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ItemThrowAirSmashD,      File.BANJO_ITM_THROW_AIR_D,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.HeavyItemThrowF,         File.BANJO_HEAVY_ITM_THROW,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.HeavyItemThrowB,         File.BANJO_HEAVY_ITM_THROW,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.HeavyItemThrowSmashF,    File.BANJO_HEAVY_ITM_THROW,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.HeavyItemThrowSmashB,    File.BANJO_HEAVY_ITM_THROW,         -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BeamSwordNeutral,        File.BANJO_ITM_NEUTRAL,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BeamSwordTilt,           File.BANJO_ITM_TILT,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BeamSwordSmash,          File.BANJO_ITM_SMASH,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BeamSwordDash,           File.BANJO_ITM_DASH,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BatNeutral,              File.BANJO_ITM_NEUTRAL,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BatTilt,                 File.BANJO_ITM_TILT,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BatSmash,                File.BANJO_ITM_SMASH,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.BatDash,                 File.BANJO_ITM_DASH,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FanNeutral,              File.BANJO_ITM_NEUTRAL,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FanTilt,                 File.BANJO_ITM_TILT,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FanSmash,                File.BANJO_ITM_SMASH,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FanDash,                 File.BANJO_ITM_DASH,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StarRodNeutral,          File.BANJO_ITM_NEUTRAL,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StarRodTilt,             File.BANJO_ITM_TILT,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StarRodSmash,            File.BANJO_ITM_SMASH,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StarRodDash,             File.BANJO_ITM_DASH,                -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.RayGunShoot,             File.BANJO_ITM_SHOOT,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.RayGunShootAir,          File.BANJO_ITM_SHOOT_AIR,           -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FireFlowerShoot,         File.BANJO_ITM_SHOOT,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FireFlowerShootAir,      File.BANJO_ITM_SHOOT_AIR,           -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.HammerIdle,              File.BANJO_HAMMER_IDLE,             -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.HammerWalk,              File.BANJO_HAMMER_MOVE,             -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.HammerTurn,              File.BANJO_HAMMER_MOVE,             -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.HammerJumpSquat,         File.BANJO_HAMMER_MOVE,             -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.HammerAir,               File.BANJO_HAMMER_MOVE,             -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.HammerLanding,           File.BANJO_HAMMER_MOVE,             -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.ShieldOn,                File.BANJO_SHIELD_ON,               -1,                         0xAFE00000)
    Character.edit_action_parameters(BANJO, Action.ShieldOff,               File.BANJO_SHIELD_OFF,              -1,                         0xAFE00000)
    Character.edit_action_parameters(BANJO, Action.RollF,                   File.BANJO_ROLL_F,                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.RollB,                   File.BANJO_ROLL_B,                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ShieldBreak,             File.BANJO_DMG_FLY_TOP,             SHIELD_BREAK,               -1)
    Character.edit_action_parameters(BANJO, Action.ShieldBreakFall,         File.BANJO_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StunLandD,               File.BANJO_DOWN_BNCE_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StunLandU,               File.BANJO_DOWN_BNCE_U,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StunStartD,              File.BANJO_DOWN_STND_D,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.StunStartU,              File.BANJO_DOWN_STND_U,             -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Stun,                    File.BANJO_STUN,                    STUN,                       0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Sleep,                   File.BANJO_STUN,                    ASLEEP,                     0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Grab,                    File.BANJO_GRAB,                    GRAB,                         -1)
    Character.edit_action_parameters(BANJO, Action.GrabPull,                File.BANJO_GRAB_PULL,               -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ThrowF,                  File.BANJO_THROW_F,                 THROW_F,                         -1)
    Character.edit_action_parameters(BANJO, Action.ThrowB,                  File.BANJO_THROW_B,                 THROW_B,                    -1)
    Character.edit_action_parameters(BANJO, Action.CapturePulled,           File.BANJO_CAPTURE_PULLED,          DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.InhalePulled,            File.BANJO_TUMBLE,                  DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.InhaleSpat,              File.BANJO_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.InhaleCopied,            File.BANJO_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.EggLayPulled,            File.BANJO_CAPTURE_PULLED,          DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.EggLay,                  File.BANJO_IDLE,                    -1,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.FalconDivePulled,        File.BANJO_DMG_HIGH_3,              FALCON_DIVE_PULLED,                         -1)
    Character.edit_action_parameters(BANJO, 0x0B4,                          File.BANJO_TUMBLE,                  UNKNOWN_0B4,                         -1)
    Character.edit_action_parameters(BANJO, Action.ThrownDKPulled,          File.BANJO_THROWN_DKPULLED,         DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.ThrownMarioBros,         File.BANJO_THROWN_MARIO_BROS,       DMG_1,                         -1)
    // B7
    Character.edit_action_parameters(BANJO, Action.ThrownDK,                File.BANJO_THROWN_DK,               DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Thrown1,                 File.BANJO_THROWN_1,                DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Thrown2,                 File.BANJO_THROWN_2,                DMG_1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Taunt,                   File.BANJO_TAUNT,                   TAUNT,                      0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.Jab1,                    File.BANJO_JAB_1,                   JAB1,                         -1)
    Character.edit_action_parameters(BANJO, Action.Jab2,                    File.BANJO_JAB_2,                   JAB2,                         -1)
    Character.edit_action_parameters(BANJO, Action.Jab3,                    File.BANJO_JAB_3,                   JAB3,                       0x40000000)
    Character.edit_action_parameters(BANJO, Action.DashAttack,              File.BANJO_DASH_ATTACK,             -1,                         0x4FE00000)
    Character.edit_action_parameters(BANJO, Action.FTiltHigh,               File.BANJO_FTILT_HIGH,              F_TILT_HIGH,                 0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.FTiltMidHigh,            0,                                  0x80000000,                 -1)
    Character.edit_action_parameters(BANJO, Action.FTilt,                   File.BANJO_FTILT,                   F_TILT_MID,                 0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.FTiltMidLow,             0,                                  0x80000000,                 -1)
    Character.edit_action_parameters(BANJO, Action.FTiltLow,                File.BANJO_FTILT_LOW,               F_TILT_LOW,                 0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.UTilt,                   File.BANJO_UTILT,                   U_TILT,                     0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DTilt,                   File.BANJO_DTILT,                   D_TILT,                 0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.FSmashHigh,              0,                                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.FSmash,                  File.BANJO_FSMASH,                  F_SMASH,                    0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.FSmashLow,               0,                                  -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.USmash,                  File.BANJO_USMASH,                  U_SMASH,                         0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DSmash,                  File.BANJO_DSMASH,                  D_SMASH,                    0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.AttackAirN,              File.BANJO_ATTACK_AIR_N,            ATTACK_AIR_N,               0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.AttackAirF,              File.BANJO_ATTACK_AIR_F,            ATTACK_AIR_F,               0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.AttackAirB,              File.BANJO_ATTACK_AIR_B,            ATTACK_AIR_B,               0x10000000)
    Character.edit_action_parameters(BANJO, Action.AttackAirU,              File.BANJO_ATTACK_AIR_U,            ATTACK_AIR_U,               0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.AttackAirD,              File.BANJO_ATTACK_AIR_D,            ATTACK_AIR_D,               -1)
    Character.edit_action_parameters(BANJO, Action.LandingAirF,             File.BANJO_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.LandingAirD,             File.BANJO_LANDING_AIR_D,           -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.LandingAirB,             File.BANJO_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.LandingAirX,             File.BANJO_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(BANJO, Action.EntryR,                  File.BANJO_ENTRY_RIGHT,             ENTRY,                         0x4FE00008)
    Character.edit_action_parameters(BANJO, Action.EntryL,                  File.BANJO_ENTRY_LEFT,              ENTRY,                         0x4FE00008)
    Character.edit_action_parameters(BANJO, 0xDF,                           File.BANJO_ACTION_0DF,              -1,                         -1)
    Character.edit_action_parameters(BANJO, 0xE0,                           File.BANJO_ACTION_0E0,              -1,                         -1)



    // special actions
    Character.edit_action_parameters(BANJO, Action.NSPBeginG,               File.BANJO_NSP_BEGIN,               NSP_BEGIN,                  0)
    Character.edit_action_parameters(BANJO, Action.NSPForwardG,             File.BANJO_NSP_FORWARD,             NSP_FORWARD,                0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.NSPBackwardG,            File.BANJO_NSP_BACKWARD,            NSP_BACKWARD,               0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.NSPBeginA,               File.BANJO_NSP_BEGIN,               NSP_BEGIN,                  0)
    Character.edit_action_parameters(BANJO, Action.NSPForwardA,             File.BANJO_NSP_FORWARD,             NSP_FORWARD,                0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.NSPBackwardA,            File.BANJO_NSP_BACKWARD,            NSP_BACKWARD,               0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DSPA,                    File.BANJO_DSP_AIR,                 DSP_AIR,                    0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DSPLand,                 File.BANJO_DSP_LAND,                DSP_LANDING,                0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DSPG,                    File.BANJO_DSP_GND,                 DSP_GROUND,                 0x4FE00000)
    Character.edit_action_parameters(BANJO, Action.DSPGAir,                 File.BANJO_DSP_GND_AIR,             0x80000000,                 0x0FE00000)
    Character.edit_action_parameters(BANJO, Action.DSPALoop,                File.BANJO_DSP_LOOP,                DSP_AIR_LOOP,                    0x0FE00000)



    // Modify Actions             // Action             // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Physics ASM                  // Collision ASM
    Character.edit_action(BANJO, Action.EntryR,         0,              0x8013DA94,                     0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(BANJO, Action.EntryL,         0,              0x8013DA94,                     0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(BANJO, Action.Jab3,           0x3,            0x800D94C4,                     0,                              0x800D8C14,                     0x800DDF44)
    Character.edit_action(BANJO, Action.NSPBeginG,      0x12,           BanjoNSP.begin_main_,           0,                              0x800D8BB4,                     BanjoNSP.ground_begin_collision_)
    Character.edit_action(BANJO, Action.NSPForwardG,    0x12,           BanjoNSP.shoot_forward_main_,   0,                              0x800D8BB4,                     BanjoNSP.ground_shoot_forward_collision_)
    Character.edit_action(BANJO, Action.NSPBackwardG,   0x12,           BanjoNSP.shoot_backward_main_,  0,                              0x800D8BB4,                     BanjoNSP.ground_shoot_backward_collision_)
    Character.edit_action(BANJO, Action.NSPBeginA,      0x12,           BanjoNSP.begin_main_,           0,                              0x800D91EC,                     BanjoNSP.air_begin_collision_)
    Character.edit_action(BANJO, Action.NSPForwardA,    0x12,           BanjoNSP.shoot_forward_main_,   0,                              BanjoNSP.air_shoot_physics_,    BanjoNSP.air_shoot_forward_collision_)
    Character.edit_action(BANJO, Action.NSPBackwardA,   0x12,           BanjoNSP.shoot_backward_main_,  0,                              BanjoNSP.air_shoot_physics_,    BanjoNSP.air_shoot_backward_collision_)
    Character.edit_action(BANJO, Action.DSPA,           0x1E,           BanjoDSP.aerial_main_,          BanjoDSP.air_move_,             BanjoDSP.physics_,              BanjoDSP.collision_)
    Character.edit_action(BANJO, Action.DSPLand,        0x1E,           0x800D94C4,                     0,                              0x800D8BB4,                     0x800DDEE8)
    Character.edit_action(BANJO, Action.DSPG,           0x1E,           0x800D94C4,                     0,                              0x800D8CCC,                     BanjoDSP.grounded_collision_)
    Character.edit_action(BANJO, Action.DSPGAir,        0x1E,           0x800D94E8,                     0,                              0x800D8BB4,                     0x800DE99C)
    Character.edit_action(BANJO, Action.DSPALoop,       0x1E,           0x00000000,                     BanjoDSP.air_move_,             BanjoDSP.physics_,              BanjoDSP.collision_)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                    // Moveset Data             // Flags
    Character.add_new_action_params(BANJO,  USPBegin,           -1,             File.BANJO_USP_BEGIN,           USP_BEGIN,                  0x0FE00000)
    Character.add_new_action_params(BANJO,  USPAttack,          -1,             File.BANJO_USP_ATTACK,          USP_ATTACK,                 0x0FE00000)
    Character.add_new_action_params(BANJO,  USPAttackEnd,       -1,             File.BANJO_USP_ATTACK_END,      USP_ATTACK_END,             0x0FE00000)
    Character.add_new_action_params(BANJO,  USPRecoil,          -1,             File.BANJO_USP_RECOIL,          USP_RECOIL,                 0x0FE00000)
    Character.add_new_action_params(BANJO,  USPWallSplat,       -1,             File.BANJO_USP_WALL_SPLAT,      USP_SPLAT,                  0x0FE00000)


    // Add Actions                   // Action Name     // Base Action  //Parameters                // Staling ID   // Main ASM                 // Interrupt/Other ASM      // Movement/Physics ASM     // Collision ASM
    Character.add_new_action(BANJO,  USPBegin,          -1,             ActionParams.USPBegin,      0x11,           BanjoUSP.begin_main_,       0,                          BanjoUSP.begin_physics_,    BanjoUSP.begin_collision_)
    Character.add_new_action(BANJO,  USPAttack,         -1,             ActionParams.USPAttack,     0x11,           BanjoUSP.attack_main_,      BanjoUSP.attack_interupt_,  BanjoUSP.attack_physics_,   BanjoUSP.attack_collision_)
    Character.add_new_action(BANJO,  USPAttackEnd,      -1,             ActionParams.USPAttackEnd,  0x11,           BanjoUSP.attack_end_main_,  0,                          0x800D91EC,                 BanjoUSP.collision_)
    Character.add_new_action(BANJO,  USPRecoil,         -1,             ActionParams.USPRecoil,     0x11,           0x800D94E8,                 BanjoUSP.recoil_move_,      BanjoUSP.recoil_physics_,   0x800DE99C)
    Character.add_new_action(BANJO,  USPWallSplat,      -1,             ActionParams.USPWallSplat,  0x11,           BanjoUSP.wall_splat_main_,  0,                          BanjoUSP.splat_physics_,    BanjoUSP.collision_)

    // Modify Menu Action Parameters              // Action     // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(BANJO, 0x0,           File.BANJO_IDLE,            -1,                         0x0FE00000)
    Character.edit_menu_action_parameters(BANJO, 0x1,           File.BANJO_VICTORY_1,       CSS,                        0x0FE00000)
    Character.edit_menu_action_parameters(BANJO, 0x2,           File.BANJO_VICTORY_2,       VICTORY2,                   0x1FE00000)
    Character.edit_menu_action_parameters(BANJO, 0x3,           File.BANJO_VICTORY_3,       VICTORY3,                   0x0FE00000)
    Character.edit_menu_action_parameters(BANJO, 0x4,           File.BANJO_VICTORY_1,       CSS,                        0x0FE00000)
    Character.edit_menu_action_parameters(BANJO, 0x5,           File.BANJO_CLAP,            CLAP,                       0x0FE00000)
    Character.edit_menu_action_parameters(BANJO, 0x9,           File.BANJO_CONTINUE_FALL,   CONTINUE,                   0x4FE00000)
    Character.edit_menu_action_parameters(BANJO, 0xA,           File.BANJO_CONTINUE_UP,     CONTINUE_UP,                0x4FE00000)
    Character.edit_menu_action_parameters(BANJO, 0xD,           File.BANJO_1P_POSE,         -1,                         0x0FE00000)
    Character.edit_menu_action_parameters(BANJO, 0xE,           File.BANJO_1P_CPU_POSE,     CPU_POSE,                 	0x1FE00000)

    Character.table_patch_start(air_nsp, Character.id.BANJO, 0x4)
    dw      BanjoNSP.air_begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_nsp, Character.id.BANJO, 0x4)
    dw      BanjoNSP.ground_begin_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.BANJO, 0x4)
    dw      BanjoUSP.initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.BANJO, 0x4)
    dw      BanjoUSP.initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.BANJO, 0x4)
    dw      BanjoDSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.BANJO, 0x4)
    dw      BanjoDSP.ground_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.BANJO, 0x4)
    float32 0.72
    OS.patch_end()

    // Allows Banjo to use his entry which is similar to Link
    Character.table_patch_start(entry_action, Character.id.BANJO, 0x8)
    dw 0xDC, 0xDD
    OS.patch_end()
    Character.table_patch_start(entry_script, Character.id.BANJO, 0x4)
    dw 0x8013DCCC       // Link's entry routine
    OS.patch_end()

    // Add Jab 3
    Character.table_patch_start(jab_3_timer, Character.id.BANJO, 0x4)
    dw 0x8014EB54                           // jab 3 timer routine copied from Mario
    OS.patch_end()
    Character.table_patch_start(jab_3_action, Character.id.BANJO, 0x4)
    dw set_jab_3_action_                    // subroutine which sets action id
    OS.patch_end()
    Character.table_patch_start(jab_3, Character.id.BANJO, 0x4)
    dw Character.jab_3.ENABLED              // jab 3 = ENABLED
    OS.patch_end()
    Character.table_patch_start(rapid_jab, Character.id.BANJO, 0x4)
    dw Character.rapid_jab.DISABLED         // disable rapid jab
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.BANJO, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.BANJO, 0x2)
    dh  0x053A
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.BANJO, 0xC)
    dh 0x26
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.BANJO, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.BANJO, 0x4)
    dw      AI.PREVENT_ATTACK.ROUTINE.NONE
    OS.patch_end()

    // Edit cpu attack behaviours, original table is from Falcon
    // edit_attack_behavior(table, attack, override,	start_hb, end_hb, 	min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,  	-1,  6,     0,  -132, 276, -90, 329)	// 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  26,    0,  0, 100, 100, 330)       // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  14,    0,  0, 100, 100, 330)       // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  10,    0,  -320, 320, -100, 300)	// 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  5,     0,  -50, 499, -100, 325)	// 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, BAIR,   -1,  12,    0,  -40, 280, 100, 300)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  16,    0,  250, 1170, 50, 590)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  8,     0,  45, 560, -45, 270)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,     0,  50, 240, 65, 355.0)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  4,     0,  25, 495, 280, 510)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  5,     0,  -192, 201, -30, 280)	// 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  14,    0,  200, 900, 100, 250)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  14,    0,  200, 900, 100, 250)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  7,     0,  50, 200, 128, 500)	    // 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  0,     0,  89, 475, 242, 1000)     // no offensive up B
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  0,     0,  89, 475, 242, 1700)     // no offensive up B
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  12,    0,  -174, 243, 177, 940)	// 
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,     0,  -274, 326, 196, 717)	// 

    // Set default costumes(id, costume_1, costume_2, costume_3, costume_4, red_team, blue_team, green_team)
    Character.set_default_costumes(Character.id.BANJO, 0, 2, 4, 5, 1, 2, 3)
    Teams.add_team_costume(YELLOW, BANJO, 4)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(BANJO, BROWN, RED, BLUE, GREEN, YELLOW, WHITE, ORANGE, NA)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.BANJO, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.BANJO, 0x2)
    dh  0x0053
    OS.patch_end()

    // @ Description
    // Sets Banjo's Jab 3 action.
    scope set_jab_3_action_: {
        ori     t7, r0, Action.Jab3         // t7 = action id
        j       0x8014EC30                  // return
        sw      t7, 0x0020(sp)              // store action id
    }

    Character.table_patch_start(variants, Character.id.BANJO, 0x4)
    db      Character.id.NONE
    db      Character.id.NBANJO
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

}
