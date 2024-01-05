// Marth.asm

// This file contains file inclusions, action edits, and assembly for Marth.

scope Marth {

	// Image commands used by moveset files
	scope EYES: {
		constant OPEN(0xAC000000)
		constant DAMAGE(0xAC000001)
	}
	scope MOUTH: {
		constant NORMAL(0xAC100000)
		constant DAMAGE(0xAC100001)
	}

    DOWN_BOUNCE:
	dw EYES.DAMAGE; dw MOUTH.DAMAGE;
	Moveset.GO_TO(Moveset.shared.DOWN_BOUNCE)

    // Insert Moveset files
    insert BLINK,"moveset/BLINK.bin"
    IDLE:
    dw 0xbc000003                               // set slope contour state
    Moveset.SUBROUTINE(BLINK)                   // blink
    dw 0x04000050; Moveset.SUBROUTINE(BLINK)    // wait 80 frames then blink
    dw 0x04000014; Moveset.SUBROUTINE(BLINK)    // wait 20 frames then blink
    dw 0x04000050; Moveset.GO_TO(IDLE)          // wait 80 frames then loop

    insert JUMP,"moveset/JUMP.bin"
    insert JUMP_AERIAL,"moveset/JUMP_AERIAL.bin"
    insert TEETER,"moveset/TEETER.bin"
    insert TEETER_START,"moveset/TEETER_START.bin"

    insert DOWN_STAND,"moveset/DOWN_STAND.bin"
    insert DAMAGED_FACE,"moveset/DAMAGED_FACE.bin"
    DMG_1:; Moveset.SUBROUTINE(DAMAGED_FACE); dw 0
    DMG_2:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0x270); dw 0
    FALCON_DIVE_PULLED:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF44); dw 0
    UNKNOWN_0B4:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF58); dw 0
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops

    insert DOWN_ATTACK_D,"moveset/DOWN_ATTACK_D.bin"
    insert DOWN_ATTACK_U,"moveset/DOWN_ATTACK_U.bin"
    insert TECH_ROLL,"moveset/TECH_ROLL.bin"
    insert TECH,"moveset/TECH.bin"
    insert ROLL_F,"moveset/ROLL_F.bin"
    insert ROLL_B,"moveset/ROLL_B.bin"

    insert EDGE_GRAB, "moveset/EDGE_GRAB.bin"
    insert EDGE_IDLE, "moveset/EDGE_IDLE.bin"
    insert EDGE_ATTACK_QUICK_2, "moveset/EDGE_ATTACK_QUICK_2.bin"
    insert EDGE_ATTACK_SLOW_2, "moveset/EDGE_ATTACK_SLOW_2.bin"

    BEAMSWORD_JAB:; dw 0xBC000003; dw 0x08000005; dw 0xCC040000; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_JAB); dw 0x04000005; dw 0x18000000; dw 0x04000004; dw 0xCC03FFFF; dw 0
    BEAMSWORD_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0xCC040000; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_TILT); dw 0x04000004; dw 0x18000000; dw 0x04000006; dw 0xCC03FFFF; dw 0x08000026; dw 0xBC000003; dw 0
    BEAMSWORD_SMASH:; dw 0xBC000003; dw 0x08000012; dw 0xCC040000; dw 0x08000013; dw 0xBC000004; dw 0x50000000; dw 0x08000014; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_SMASH); dw 0x04000007; dw 0x18000000; dw 0x04000002; dw 0xCC03FFFF; dw 0x0800002D; dw 0xBC000003; dw 0
    BEAMSWORD_DASH:; dw 0xBC000004; dw 0xCC040000; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BEAMSWORD_DASH); dw 0x04000003; dw 0xCC03FFFF; dw 0x0400000F; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    BAT_JAB:; dw 0xBC000003; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BAT_JAB); dw 0x04000004; dw 0x18000000; dw 0
    BAT_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.BAT_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    BAT_SMASH:; dw 0xC4000007; dw 0xBC000003; dw 0xB1300028; dw 0x08000013; dw 0xBC000004; dw 0x50000000; dw 0x08000014; Moveset.SUBROUTINE(Moveset.shared.BAT_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    BAT_DASH:; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.BAT_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    FAN_JAB:; dw 0xBC000003; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.FAN_JAB); dw 0x04000004; dw 0x18000000; dw 0
    FAN_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.FAN_TILT); dw 0x04000004; dw 0x18000000; dw 0x08000026; dw 0xBC000003; dw 0
    FAN_SMASH:; dw 0xBC000003; dw 0x08000013; dw 0xBC000004; dw 0x50000000; dw 0x08000014; Moveset.SUBROUTINE(Moveset.shared.FAN_SMASH); dw 0x04000007; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    FAN_DASH:; dw 0xBC000004; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.FAN_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0
    STARROD_JAB:; dw 0xBC000003; dw 0xB12C0010; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.STARROD_JAB); dw 0x04000004; dw 0x18000000; dw 0
    STARROD_TILT:; dw 0xBC000003; dw 0x08000004; dw 0xBC000004; dw 0xB12C000D; dw 0x08000006; Moveset.SUBROUTINE(Moveset.shared.STARROD_TILT); dw 0x04000002; dw 0x54000001; dw 0x04000002; dw 0x18000000;  dw 0x08000026; dw 0xBC000003; dw 0
    STARROD_SMASH:; dw 0xBC000003; dw 0x08000013; dw 0xBC000004; dw 0xB12C0024; dw 0x50000000; dw 0x08000014; Moveset.SUBROUTINE(Moveset.shared.STARROD_SMASH); dw 0x04000002; dw 0x54000002; dw 0x04000005; dw 0x18000000; dw 0x0800002D; dw 0xBC000003; dw 0
    STARROD_DASH:; dw 0xBC000004; dw 0xB12C0014; dw 0x08000007; Moveset.SUBROUTINE(Moveset.shared.STARROD_DASH); dw 0x04000012; dw 0x18000000; dw 0x08000020; dw 0xBC000003; dw 0

    insert TAUNT,"moveset/TAUNT.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert THROW_F_DATA,"moveset/THROW_F_DATA.bin"
    THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); insert "moveset/THROW_F.bin"
    insert THROW_B_DATA,"moveset/THROW_B_DATA.bin"
    THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); insert "moveset/THROW_B.bin"
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

    insert USP,"moveset/USP.bin"
    insert DSP,"moveset/DSP.bin"
    COUNTER_VOICE_ARRAY:; dh 0x35B; dh 0x361; dh 0x362; OS.align(4)
    DSP_ATTACK:; Moveset.RANDOM_SFX(100, 0x0, 0x3, COUNTER_VOICE_ARRAY); insert "moveset/DSP_ATTACK.bin" // Play a random Voice FX and then continue with moveset
    insert NSP_1,"moveset/NSP_1.bin"
    insert NSP_2_HIGH,"moveset/NSP_2_HIGH.bin"
    insert NSP_2,"moveset/NSP_2.bin"
    insert NSP_2_LOW,"moveset/NSP_2_LOW.bin"
    insert NSP_3_HIGH,"moveset/NSP_3_HIGH.bin"
    insert NSP_3,"moveset/NSP_3.bin"
    insert NSP_3_LOW,"moveset/NSP_3_LOW.bin"

    insert ENTRY,"moveset/ENTRY.bin"
    insert CLAP,"moveset/CLAP.bin"
    insert SELECT,"moveset/SELECT.bin"
    VICTORY_1:; Moveset.CONCURRENT_STREAM(SELECT); insert "moveset/VICTORY_1.bin"
    insert VICTORY_2,"moveset/VICTORY_2.bin"
    insert VICTORY_3,"moveset/VICTORY_3.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // @ Description
    // Marth's extra actions
    scope Action {
        constant Entry_R(0xDC)
        constant Entry_L(0xDD)
        constant USPG(0xDE)
        constant USPA(0xDF)
        constant NSPG_1(0xE0)
        constant NSPG_2_High(0xE1)
        constant NSPG_2_Mid(0xE2)
        constant NSPG_2_Low(0xE3)
        constant NSPG_3_High(0xE4)
        constant NSPG_3_Mid(0xE5)
        constant NSPG_3_Low(0xE6)
        constant NSPA_1(0xE7)
        constant NSPA_2_High(0xE8)
        constant NSPA_2_Mid(0xE9)
        constant NSPA_2_Low(0xEA)
        constant NSPA_3_High(0xEB)
        constant NSPA_3_Mid(0xEC)
        constant NSPA_3_Low(0xED)
        //constant ?(0xEE)
        constant DSPG(0xEF)
        constant DSPG_Attack(0xF0)
        constant DSPGA(0xF1)
        constant DSPGA_Attack(0xF2)


        // strings!
        string_0x0DE:; String.insert("DolphinSlash")
        string_0x0DF:; String.insert("DolphinSlashAir")
        string_0x0E0:; String.insert("DancingBlade1")
        string_0x0E1:; String.insert("DancingBlade2High")
        string_0x0E2:; String.insert("DancingBlade2Mid")
        string_0x0E3:; String.insert("DancingBlade2Low")
        string_0x0E4:; String.insert("DancingBlade3High")
        string_0x0E5:; String.insert("DancingBlade3Mid")
        string_0x0E6:; String.insert("DancingBlade3Low")
        string_0x0E7:; String.insert("DancingBlade1Air")
        string_0x0E8:; String.insert("DancingBlade2HighAir")
        string_0x0E9:; String.insert("DancingBlade2MidAir")
        string_0x0EA:; String.insert("DancingBlade2LowAir")
        string_0x0EB:; String.insert("DancingBlade3HighAir")
        string_0x0EC:; String.insert("DancingBlade3MidAir")
        string_0x0ED:; String.insert("DancingBlade3LowAir")
        // string_0x0EE;: String.insert("?")
        string_0x0EF:; String.insert("Counter")
        string_0x0F0:; String.insert("CounterAttack")
        string_0x0F1:; String.insert("CounterAir")
        string_0x0F2:; String.insert("CounterAttackAir")

        action_string_table:
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw string_0x0DE
        dw string_0x0DF
        dw string_0x0E0
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
        dw string_0x0EC
        dw string_0x0ED
        dw 0 //dw string_0x0EE
        dw string_0x0EF
        dw string_0x0F0
        dw string_0x0F1
        dw string_0x0F2
    }

    // Modify Action Parameters             // Action                       // Animation                        // Moveset Data             // Flags
    Character.edit_action_parameters(MARTH, Action.DeadU,                   File.MARTH_TUMBLE,                  DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.ScreenKO,                File.MARTH_TUMBLE,                  DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.Entry,                   File.MARTH_IDLE,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, 0x006,                          File.MARTH_IDLE,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Revive1,                 File.MARTH_DOWN_BOUNCE_D,           -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Revive2,                 File.MARTH_DOWN_STAND_D,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ReviveWait,              File.MARTH_IDLE,                    IDLE,                       -1)
    Character.edit_action_parameters(MARTH, Action.Idle,                    File.MARTH_IDLE,                    IDLE,                       -1)
    Character.edit_action_parameters(MARTH, Action.Walk1,                   File.MARTH_WALK_1,                  -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Walk2,                   File.MARTH_WALK_2,                  -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Walk3,                   File.MARTH_WALK_3,                  -1,                         -1)
    Character.edit_action_parameters(MARTH, 0x00E,                          File.MARTH_WALK_END,                -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Dash,                    File.MARTH_DASH,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Run,                     File.MARTH_RUN,                     -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.RunBrake,                File.MARTH_RUN_BRAKE,               -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Turn,                    File.MARTH_TURN,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.TurnRun,                 File.MARTH_TURN_RUN,                -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.JumpSquat,               File.MARTH_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ShieldJumpSquat,         File.MARTH_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.JumpF,                   File.MARTH_JUMP_F,                  JUMP,                       -1)
    Character.edit_action_parameters(MARTH, Action.JumpB,                   File.MARTH_JUMP_B,                  JUMP,                       -1)
    Character.edit_action_parameters(MARTH, Action.JumpAerialF,             File.MARTH_JUMP_AERIAL_F,           JUMP_AERIAL,                -1)
    Character.edit_action_parameters(MARTH, Action.JumpAerialB,             File.MARTH_JUMP_AERIAL_B,           JUMP_AERIAL,                -1)
    Character.edit_action_parameters(MARTH, Action.Fall,                    File.MARTH_FALL,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.FallAerial,              File.MARTH_FALL_AERIAL,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Crouch,                  File.MARTH_CROUCH,                  -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CrouchIdle,              File.MARTH_CROUCH_IDLE,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CrouchEnd,               File.MARTH_CROUCH_END,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingLight,            File.MARTH_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingHeavy,            File.MARTH_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Pass,                    File.MARTH_PASS,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ShieldDrop,              File.MARTH_PASS,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Teeter,                  File.MARTH_TEETER,                  TEETER,                     -1)
    Character.edit_action_parameters(MARTH, Action.TeeterStart,             File.MARTH_TEETER_START,            TEETER_START,               -1)
    Character.edit_action_parameters(MARTH, Action.DamageHigh1,             File.MARTH_DAMAGE_HIGH_1,           DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageHigh2,             File.MARTH_DAMAGE_HIGH_2,           DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageHigh3,             File.MARTH_DAMAGE_HIGH_3,           DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageMid1,              File.MARTH_DAMAGE_MID_1,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageMid2,              File.MARTH_DAMAGE_MID_2,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageMid3,              File.MARTH_DAMAGE_MID_3,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageLow1,              File.MARTH_DAMAGE_LOW_1,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageLow2,              File.MARTH_DAMAGE_LOW_2,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageLow3,              File.MARTH_DAMAGE_LOW_3,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageAir1,              File.MARTH_DAMAGE_AIR_1,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageAir2,              File.MARTH_DAMAGE_AIR_2,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageAir3,              File.MARTH_DAMAGE_AIR_3,            DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageElec1,             File.MARTH_DAMAGE_ELEC,             DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageElec2,             File.MARTH_DAMAGE_ELEC,             DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageFlyHigh,           File.MARTH_DAMAGE_FLY_HIGH,         DMG_2,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageFlyMid,            File.MARTH_DAMAGE_FLY_MID,          DMG_2,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageFlyLow,            File.MARTH_DAMAGE_FLY_LOW,          DMG_2,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageFlyTop,            File.MARTH_DAMAGE_FLY_TOP,          DMG_2,                      -1)
    Character.edit_action_parameters(MARTH, Action.DamageFlyRoll,           File.MARTH_DAMAGE_FLY_ROLL,         DMG_2,                      -1)
    Character.edit_action_parameters(MARTH, Action.WallBounce,              File.MARTH_TUMBLE,                  DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.Tumble,                  File.MARTH_TUMBLE,                  DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.FallSpecial,             File.MARTH_FALL_SPECIAL,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingSpecial,          File.MARTH_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Tornado,                 File.MARTH_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.EnterPipe,               File.MARTH_ENTER_PIPE,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ExitPipe,                File.MARTH_EXIT_PIPE,               -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ExitPipeWalk,            File.MARTH_EXIT_PIPE_WALK,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CeilingBonk,             File.MARTH_CEILING_BONK,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.DownBounceD,             File.MARTH_DOWN_BOUNCE_D,           DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(MARTH, Action.DownBounceU,             File.MARTH_DOWN_BOUNCE_U,           DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(MARTH, Action.DownStandD,              File.MARTH_DOWN_STAND_D,            DOWN_STAND,                 -1)
    Character.edit_action_parameters(MARTH, Action.DownStandU,              File.MARTH_DOWN_STAND_U,            DOWN_STAND,                 -1)
    Character.edit_action_parameters(MARTH, Action.TechF,                   File.MARTH_TECH_F,                  TECH_ROLL,                  -1)
    Character.edit_action_parameters(MARTH, Action.TechB,                   File.MARTH_TECH_B,                  TECH_ROLL,                  -1)
    Character.edit_action_parameters(MARTH, Action.DownForwardD,            File.MARTH_DOWN_FORWARD_D,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.DownForwardU,            File.MARTH_DOWN_FORWARD_U,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.DownBackD,               File.MARTH_DOWN_BACK_D,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.DownBackU,               File.MARTH_DOWN_BACK_U,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.DownAttackD,             File.MARTH_DOWN_ATTACK_D,           DOWN_ATTACK_D,              -1)
    Character.edit_action_parameters(MARTH, Action.DownAttackU,             File.MARTH_DOWN_ATTACK_U,           DOWN_ATTACK_U,              -1)
    Character.edit_action_parameters(MARTH, Action.Tech,                    File.MARTH_TECH,                    TECH,                       -1)
    Character.edit_action_parameters(MARTH, 0x053,                          File.MARTH_UNKNOWN_053,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffCatch,              File.MARTH_CLIFF_CATCH,             EDGE_GRAB,                  -1)
    Character.edit_action_parameters(MARTH, Action.CliffWait,               File.MARTH_CLIFF_WAIT,              EDGE_IDLE,                  -1)
    Character.edit_action_parameters(MARTH, Action.CliffQuick,              File.MARTH_CLIFF_QUICK,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffClimbQuick1,        File.MARTH_CLIFF_CLIMB_QUICK_1,     -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffClimbQuick2,        File.MARTH_CLIFF_CLIMB_QUICK_2,     -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffSlow,               File.MARTH_CLIFF_SLOW,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffClimbSlow1,         File.MARTH_CLIFF_CLIMB_SLOW_1,      -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffClimbSlow2,         File.MARTH_CLIFF_CLIMB_SLOW_2,      -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffAttackQuick1,       File.MARTH_CLIFF_ATTACK_QUICK_1,    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffAttackQuick2,       File.MARTH_CLIFF_ATTACK_QUICK_2,    EDGE_ATTACK_QUICK_2,        -1)
    Character.edit_action_parameters(MARTH, Action.CliffAttackSlow1,        File.MARTH_CLIFF_ATTACK_SLOW_1,     -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffAttackSlow2,        File.MARTH_CLIFF_ATTACK_SLOW_2,     EDGE_ATTACK_SLOW_2,         -1)
    Character.edit_action_parameters(MARTH, Action.CliffEscapeQuick1,       File.MARTH_CLIFF_ESCAPE_QUICK_1,    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffEscapeQuick2,       File.MARTH_CLIFF_ESCAPE_QUICK_2,    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffEscapeSlow1,        File.MARTH_CLIFF_ESCAPE_SLOW_1,     -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.CliffEscapeSlow2,        File.MARTH_CLIFF_ESCAPE_SLOW_2,     -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LightItemPickup,         File.MARTH_LIGHT_ITEM_PICKUP,       -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HeavyItemPickup,         File.MARTH_HEAVY_ITEM_PICKUP,       -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemDrop,                File.MARTH_ITEM_DROP,               -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowDash,           File.MARTH_ITEM_THROW_DASH,         -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowF,              File.MARTH_ITEM_THROW,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowB,              File.MARTH_ITEM_THROW,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowU,              File.MARTH_ITEM_THROW_U,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowD,              File.MARTH_ITEM_THROW_D,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowSmashF,         File.MARTH_ITEM_THROW,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowSmashB,         File.MARTH_ITEM_THROW,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowSmashU,         File.MARTH_ITEM_THROW_U,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowSmashD,         File.MARTH_ITEM_THROW_D,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirF,           File.MARTH_ITEM_THROW_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirB,           File.MARTH_ITEM_THROW_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirU,           File.MARTH_ITEM_THROW_AIR_U,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirD,           File.MARTH_ITEM_THROW_AIR_D,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirSmashF,      File.MARTH_ITEM_THROW_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirSmashB,      File.MARTH_ITEM_THROW_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirSmashU,      File.MARTH_ITEM_THROW_AIR_U,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ItemThrowAirSmashD,      File.MARTH_ITEM_THROW_AIR_D,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HeavyItemThrowF,         File.MARTH_HEAVY_ITEM_THROW,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HeavyItemThrowB,         File.MARTH_HEAVY_ITEM_THROW,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HeavyItemThrowSmashF,    File.MARTH_HEAVY_ITEM_THROW,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HeavyItemThrowSmashB,    File.MARTH_HEAVY_ITEM_THROW,        -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.BeamSwordNeutral,        File.MARTH_ITEM_NEUTRAL,            BEAMSWORD_JAB,              -1)
    Character.edit_action_parameters(MARTH, Action.BeamSwordTilt,           File.MARTH_ITEM_TILT,               BEAMSWORD_TILT,             -1)
    Character.edit_action_parameters(MARTH, Action.BeamSwordSmash,          File.MARTH_ITEM_SMASH,              BEAMSWORD_SMASH,            -1)
    Character.edit_action_parameters(MARTH, Action.BeamSwordDash,           File.MARTH_ITEM_DASH_ATTACK,        BEAMSWORD_DASH,             -1)
    Character.edit_action_parameters(MARTH, Action.BatNeutral,              File.MARTH_ITEM_NEUTRAL,            BAT_JAB,                    -1)
    Character.edit_action_parameters(MARTH, Action.BatTilt,                 File.MARTH_ITEM_TILT,               BAT_TILT,                   -1)
    Character.edit_action_parameters(MARTH, Action.BatSmash,                File.MARTH_ITEM_SMASH,              BAT_SMASH,                  -1)
    Character.edit_action_parameters(MARTH, Action.BatDash,                 File.MARTH_ITEM_DASH_ATTACK,        BAT_DASH,                   -1)
    Character.edit_action_parameters(MARTH, Action.FanNeutral,              File.MARTH_ITEM_NEUTRAL,            FAN_JAB,                    -1)
    Character.edit_action_parameters(MARTH, Action.FanTilt,                 File.MARTH_ITEM_TILT,               FAN_TILT,                   -1)
    Character.edit_action_parameters(MARTH, Action.FanSmash,                File.MARTH_ITEM_SMASH,              FAN_SMASH,                  -1)
    Character.edit_action_parameters(MARTH, Action.FanDash,                 File.MARTH_ITEM_DASH_ATTACK,        FAN_DASH,                   -1)
    Character.edit_action_parameters(MARTH, Action.StarRodNeutral,          File.MARTH_ITEM_NEUTRAL,            STARROD_JAB,                -1)
    Character.edit_action_parameters(MARTH, Action.StarRodTilt,             File.MARTH_ITEM_TILT,               STARROD_TILT,               -1)
    Character.edit_action_parameters(MARTH, Action.StarRodSmash,            File.MARTH_ITEM_SMASH,              STARROD_SMASH,              -1)
    Character.edit_action_parameters(MARTH, Action.StarRodDash,             File.MARTH_ITEM_DASH_ATTACK,        STARROD_DASH,               -1)
    Character.edit_action_parameters(MARTH, Action.RayGunShoot,             File.MARTH_ITEM_SHOOT,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.RayGunShootAir,          File.MARTH_ITEM_SHOOT_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.FireFlowerShoot,         File.MARTH_ITEM_SHOOT,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.FireFlowerShootAir,      File.MARTH_ITEM_SHOOT_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HammerIdle,              File.MARTH_HAMMER_IDLE,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HammerWalk,              File.MARTH_HAMMER_MOVE,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HammerTurn,              File.MARTH_HAMMER_MOVE,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HammerJumpSquat,         File.MARTH_HAMMER_MOVE,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HammerAir,               File.MARTH_HAMMER_MOVE,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.HammerLanding,           File.MARTH_HAMMER_MOVE,             -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ShieldOn,                File.MARTH_SHIELD_ON,               -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ShieldOff,               File.MARTH_SHIELD_OFF,              -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.RollF,                   File.MARTH_ROLL_F,                  ROLL_F,                     -1)
    Character.edit_action_parameters(MARTH, Action.RollB,                   File.MARTH_ROLL_B,                  ROLL_B,                     -1)
    Character.edit_action_parameters(MARTH, Action.ShieldBreak,             File.MARTH_DAMAGE_FLY_TOP,          SHIELD_BREAK,               -1)
    Character.edit_action_parameters(MARTH, Action.ShieldBreakFall,         File.MARTH_TUMBLE,                  SPARKLE,                    -1)
    Character.edit_action_parameters(MARTH, Action.StunLandD,               File.MARTH_DOWN_BOUNCE_D,           -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.StunLandU,               File.MARTH_DOWN_BOUNCE_U,           -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.StunStartD,              File.MARTH_DOWN_STAND_D,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.StunStartU,              File.MARTH_DOWN_STAND_U,            -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Stun,                    File.MARTH_STUN,                    STUN,                       -1)
    Character.edit_action_parameters(MARTH, Action.Sleep,                   File.MARTH_STUN,                    ASLEEP,                     -1)
    Character.edit_action_parameters(MARTH, Action.Grab,                    File.MARTH_GRAB,                    GRAB,                       -1)
    Character.edit_action_parameters(MARTH, Action.GrabPull,                File.MARTH_GRAB_PULL,               -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ThrowF,                  File.MARTH_THROW_F,                 THROW_F,                    -1)
    Character.edit_action_parameters(MARTH, Action.ThrowB,                  File.MARTH_THROW_B,                 THROW_B,                    -1)
    Character.edit_action_parameters(MARTH, Action.CapturePulled,           File.MARTH_CAPTURE_PULLED,          DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.InhalePulled,            File.MARTH_TUMBLE,                  DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.InhaleSpat,              File.MARTH_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.InhaleCopied,            File.MARTH_TUMBLE,                  -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.EggLayPulled,            File.MARTH_CAPTURE_PULLED,          DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.EggLay,                  File.MARTH_IDLE,                    -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.FalconDivePulled,        File.MARTH_DAMAGE_HIGH_3,           FALCON_DIVE_PULLED,         -1)
    Character.edit_action_parameters(MARTH, 0x0B4,                          File.MARTH_TUMBLE,                  UNKNOWN_0B4,                -1)
    Character.edit_action_parameters(MARTH, Action.ThrownDKPulled,          File.MARTH_THROWN_DK_PULLED,        DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.ThrownMarioBros,         File.MARTH_THROWN_MARIO_BROS,       DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, 0x0B7,                          -1,                                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.ThrownDK,                File.MARTH_THROWN_DK,               DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.Thrown1,                 File.MARTH_THROWN_1,                DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.Thrown2,                 File.MARTH_THROWN_2,                DMG_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.Thrown3,                 -1,                                 -1,                         -1)
    Character.edit_action_parameters(MARTH, 0x0BC,                          -1,                                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Taunt,                   File.MARTH_TAUNT,                   TAUNT,                      -1)
    Character.edit_action_parameters(MARTH, Action.Jab1,                    File.MARTH_JAB_1,                   JAB_1,                      -1)
    Character.edit_action_parameters(MARTH, Action.Jab2,                    File.MARTH_JAB_2,                   JAB_2,                      -1)
    Character.edit_action_parameters(MARTH, Action.DashAttack,              File.MARTH_DASH_ATTACK,             DASH_ATTACK,                -1)
    Character.edit_action_parameters(MARTH, Action.FTiltHigh,               0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.FTiltMidHigh,            0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.FTilt,                   File.MARTH_F_TILT,                  F_TILT,                     -1)
    Character.edit_action_parameters(MARTH, Action.FTiltMidLow,             0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.FTiltLow,                0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.UTilt,                   File.MARTH_U_TILT,                  U_TILT,                     -1)
    Character.edit_action_parameters(MARTH, Action.DTilt,                   File.MARTH_D_TILT,                  D_TILT,                     -1)
    Character.edit_action_parameters(MARTH, Action.FSmashHigh,              0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.FSmashMidHigh,           0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.FSmash,                  File.MARTH_F_SMASH,                 F_SMASH,                    -1)
    Character.edit_action_parameters(MARTH, Action.FSmashMidLow,            0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.FSmashLow,               0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARTH, Action.USmash,                  File.MARTH_U_SMASH,                 U_SMASH,                    0)
    Character.edit_action_parameters(MARTH, Action.DSmash,                  File.MARTH_D_SMASH,                 D_SMASH,                    -1)
    Character.edit_action_parameters(MARTH, Action.AttackAirN,              File.MARTH_ATTACK_AIR_N,            ATTACK_AIR_N,               -1)
    Character.edit_action_parameters(MARTH, Action.AttackAirF,              File.MARTH_ATTACK_AIR_F,            ATTACK_AIR_F,               -1)
    Character.edit_action_parameters(MARTH, Action.AttackAirB,              File.MARTH_ATTACK_AIR_B,            ATTACK_AIR_B,               -1)
    Character.edit_action_parameters(MARTH, Action.AttackAirU,              File.MARTH_ATTACK_AIR_U,            ATTACK_AIR_U,               -1)
    Character.edit_action_parameters(MARTH, Action.AttackAirD,              File.MARTH_ATTACK_AIR_D,            ATTACK_AIR_D,               -1)
    Character.edit_action_parameters(MARTH, Action.LandingAirN,             -1,                                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingAirF,             File.MARTH_LANDING_AIR_F,           -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingAirB,             File.MARTH_LANDING_AIR_B,           -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingAirU,             -1,                                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingAirD,             -1,                                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.LandingAirX,             File.MARTH_LANDING,                 -1,                         -1)
    Character.edit_action_parameters(MARTH, Action.Entry_R,                 File.MARTH_ENTRY,                   ENTRY,                      0x40000000)
    Character.edit_action_parameters(MARTH, Action.Entry_L,                 File.MARTH_ENTRY,                   ENTRY,                      0x40000000)
    Character.edit_action_parameters(MARTH, Action.USPG,                    File.MARTH_USP_GROUND,              USP,                        0)
    Character.edit_action_parameters(MARTH, Action.USPA,                    File.MARTH_USP_AIR,                 USP,                        0)
    Character.edit_action_parameters(MARTH, Action.NSPG_1,                  File.MARTH_NSPG_1,                  NSP_1,                      0)
    Character.edit_action_parameters(MARTH, Action.NSPG_2_High,             File.MARTH_NSPG_2_HI,               NSP_2_HIGH,                 0)
    Character.edit_action_parameters(MARTH, Action.NSPG_2_Mid,              File.MARTH_NSPG_2,                  NSP_2,                      0)
    Character.edit_action_parameters(MARTH, Action.NSPG_2_Low,              File.MARTH_NSPG_2_LO,               NSP_2_LOW,                  0)
    Character.edit_action_parameters(MARTH, Action.NSPG_3_High,             File.MARTH_NSPG_3_HI,               NSP_3_HIGH,                 0x40000000)
    Character.edit_action_parameters(MARTH, Action.NSPG_3_Mid,              File.MARTH_NSPG_3,                  NSP_3,                      0x40000000)
    Character.edit_action_parameters(MARTH, Action.NSPG_3_Low,              File.MARTH_NSPG_3_LO,               NSP_3_LOW,                  0x40000000)
    Character.edit_action_parameters(MARTH, Action.NSPA_1,                  File.MARTH_NSPA_1,                  NSP_1,                      0)
    Character.edit_action_parameters(MARTH, Action.NSPA_2_High,             File.MARTH_NSPA_2_HI,               NSP_2_HIGH,                 0)
    Character.edit_action_parameters(MARTH, Action.NSPA_2_Mid,              File.MARTH_NSPA_2,                  NSP_2,                      0)
    Character.edit_action_parameters(MARTH, Action.NSPA_2_Low,              File.MARTH_NSPA_2_LO,               NSP_2_LOW,                  0)
    Character.edit_action_parameters(MARTH, Action.NSPA_3_High,             File.MARTH_NSPA_3_HI,               NSP_3_HIGH,                 0)
    Character.edit_action_parameters(MARTH, Action.NSPA_3_Mid,              File.MARTH_NSPA_3,                  NSP_3,                      0)
    Character.edit_action_parameters(MARTH, Action.NSPA_3_Low,              File.MARTH_NSPA_3_LO,               NSP_3_LOW,                  0)
    Character.edit_action_parameters(MARTH, 0x0EE,                          0,                                  0x80000000,                 0)

    // Modify Actions            // Action              // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(MARTH, Action.Entry_R,        0,              0x8013DA94,                 0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(MARTH, Action.Entry_L,        0,              0x8013DA94,                 0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(MARTH, Action.USPG,           0x11,           MarthUSP.main_,             MarthUSP.change_direction_,     MarthUSP.physics_,              MarthUSP.collision_)
    Character.edit_action(MARTH, Action.USPA,           0x11,           MarthUSP.main_,             MarthUSP.change_direction_,     MarthUSP.physics_,              MarthUSP.collision_)
    Character.edit_action(MARTH, Action.NSPG_1,         0x12,           MarthNSP.ground_main_,      0,                              0x800D8CCC,                     MarthNSP.ground_collision_)
    Character.edit_action(MARTH, Action.NSPG_2_High,    0x12,           MarthNSP.ground_main_,      0,                              0x800D8CCC,                     MarthNSP.ground_collision_)
    Character.edit_action(MARTH, Action.NSPG_2_Mid,     0x12,           MarthNSP.ground_main_,      0,                              0x800D8CCC,                     MarthNSP.ground_collision_)
    Character.edit_action(MARTH, Action.NSPG_2_Low,     0x12,           MarthNSP.ground_main_,      0,                              0x800D8CCC,                     MarthNSP.ground_collision_)
    Character.edit_action(MARTH, Action.NSPG_3_High,    0x12,           MarthNSP.ground_main_,      0,                              0x800D8CCC,                     MarthNSP.ground_collision_)
    Character.edit_action(MARTH, Action.NSPG_3_Mid,     0x12,           MarthNSP.ground_main_,      0,                              0x800D8CCC,                     MarthNSP.ground_collision_)
    Character.edit_action(MARTH, Action.NSPG_3_Low,     0x12,           MarthNSP.ground_main_,      0,                              0x800D8CCC,                     MarthNSP.ground_collision_)
    Character.edit_action(MARTH, Action.NSPA_1,         0x12,           MarthNSP.air_main_,         0,                              0x800D91EC,                     MarthNSP.air_collision_)
    Character.edit_action(MARTH, Action.NSPA_2_High,    0x12,           MarthNSP.air_main_,         0,                              0x800D91EC,                     MarthNSP.air_collision_)
    Character.edit_action(MARTH, Action.NSPA_2_Mid,     0x12,           MarthNSP.air_main_,         0,                              0x800D91EC,                     MarthNSP.air_collision_)
    Character.edit_action(MARTH, Action.NSPA_2_Low,     0x12,           MarthNSP.air_main_,         0,                              0x800D91EC,                     MarthNSP.air_collision_)
    Character.edit_action(MARTH, Action.NSPA_3_High,    0x12,           MarthNSP.air_main_,         0,                              0x800D91EC,                     MarthNSP.air_collision_)
    Character.edit_action(MARTH, Action.NSPA_3_Mid,     0x12,           MarthNSP.air_main_,         0,                              0x800D91EC,                     MarthNSP.air_collision_)
    Character.edit_action(MARTH, Action.NSPA_3_Low,     0x12,           MarthNSP.air_main_,         0,                              0x800D91EC,                     MarthNSP.air_collision_)

    // Modify Menu Action Parameters             // Action      // Animation                // Moveset Data             // Flags
    // TODO: add game over and continue
    Character.edit_menu_action_parameters(MARTH, 0x0,           File.MARTH_MENU_IDLE,       IDLE,                       -1)
    Character.edit_menu_action_parameters(MARTH, 0x1,           File.MARTH_VICTORY_1,       VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(MARTH, 0x2,           File.MARTH_VICTORY_2,       VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(MARTH, 0x3,           File.MARTH_VICTORY_3,       VICTORY_3,                  -1)
    Character.edit_menu_action_parameters(MARTH, 0x4,           File.MARTH_VICTORY_1,       SELECT,                     -1)
    Character.edit_menu_action_parameters(MARTH, 0x5,           File.MARTH_CLAP,            CLAP,                       -1)
    Character.edit_menu_action_parameters(MARTH, 0x9,           File.MARTH_GAME_OVER,       -1,                         -1)
    Character.edit_menu_action_parameters(MARTH, 0xA,           File.MARTH_GAME_CONTINUE,   -1,                         -1)
    Character.edit_menu_action_parameters(MARTH, 0xD,           File.MARTH_POSE_1P,         0x80000000,                 -1)
    Character.edit_menu_action_parameters(MARTH, 0xE,           File.MARTH_POSE_1P_CPU,     0x80000000,                 -1)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                // Moveset Data             // Flags
    Character.add_new_action_params(MARTH, DSP_Ground,         -1,             File.MARTH_COUNTER_G,       DSP,                        0)
    Character.add_new_action_params(MARTH, DSP_Ground_Attack,  -1,             File.MARTH_COUNTER_ATK_G,   DSP_ATTACK,                 0)
    Character.add_new_action_params(MARTH, DSP_Air,            -1,             File.MARTH_COUNTER_A,       DSP,                        0)
    Character.add_new_action_params(MARTH, DSP_Air_Attack,     -1,             File.MARTH_COUNTER_ATK_A,   DSP_ATTACK,                 0)

    // Add Actions                   // Action Name     // Base Action  //Parameters                        // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(MARTH, DSP_Ground,        -1,             ActionParams.DSP_Ground,            0x1E,            MarthDSP.main_,             0,                              0x800D8BB4,                         MarthDSP.ground_collision_)
    Character.add_new_action(MARTH, DSP_Ground_Attack, -1,             ActionParams.DSP_Ground_Attack,     0x1E,            0x800D94C4,                 0,                              0x800D8BB4,                         MarthDSP.ground_collision_)
    Character.add_new_action(MARTH, DSP_Air,           -1,             ActionParams.DSP_Air,               0x1E,            MarthDSP.main_,             0,                              MarthDSP.air_physics_,              MarthDSP.air_collision_)
    Character.add_new_action(MARTH, DSP_Air_Attack,    -1,             ActionParams.DSP_Air_Attack,        0x1E,            0x800D94E8,                 0,                              MarthDSP.air_physics_,              MarthDSP.air_collision_)

    Character.table_patch_start(air_nsp, Character.id.MARTH, 0x4)
    dw      MarthNSP.air_1_initial_
    OS.patch_end()
    Character.table_patch_start(ground_nsp, Character.id.MARTH, 0x4)
    dw      MarthNSP.ground_1_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.MARTH, 0x4)
    dw      MarthUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.MARTH, 0x4)
    dw      MarthUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.MARTH, 0x4)
    dw      MarthDSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.MARTH, 0x4)
    dw      MarthDSP.ground_initial_
    OS.patch_end()

    // Use Mario's initial/grounded script.
    Character.table_patch_start(initial_script, Character.id.MARTH, 0x4)
    dw 0x800D7DCC
    OS.patch_end()
    Character.table_patch_start(grounded_script, Character.id.MARTH, 0x4)
    dw 0x800DE428
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.MARTH, 0x4)
    float32 0.93
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MARTH, 0x2)
    dh  0x0351
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.MARTH, 0xC)
    dh 0x1C
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.MARTH, 0, 1, 2, 3, 1, 0, 2)
    Teams.add_team_costume(YELLOW, MARTH, 0x5)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(MARTH, BLUE, RED, GREEN, YELLOW, WHITE, ORANGE, NA, NA)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MARTH, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set Magnifying Glass Scale Override
    Character.table_patch_start(magnifying_glass_zoom, Character.id.MARTH, 0x2)
    dh  0x0068
    OS.patch_end()

    // Allows Marth to use his entry which is similar to Link
    Character.table_patch_start(entry_action, Character.id.MARTH, 0x8)
    dw 0xDC, 0xDD
    OS.patch_end()
    Character.table_patch_start(entry_script, Character.id.MARTH, 0x4)
    dw marth_entry_routine_
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.MARTH, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.MARTH, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.NONE
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  6,   16,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  1,   1,  -50, 50, 10, 100)  // todo: ?
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  1,   1,  -50, 50, 10, 100)  // todo: ?
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  6,   24,  -630, 630, -100, 250)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  6,   9,   -95, 680, -220, 260)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, BAIR,   -1,  5,   9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  14,  17,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  7,   10,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,   6,   170, 420, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  4,   8,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  5,   21,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  6,   9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  6,   9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  5,   10,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  8,   16,  150, 570, 223, 423)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  8,   16,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  12,  17,  -1, -1, -1, 995)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  5,   12,  -350, 350, -85, 800)

    // @ Description
    // Entry routine for Marth. Sets the correct facing direction and then jumps to Link's entry routine.
    scope marth_entry_routine_: {
        lw      a1, 0x0B1C(s0)              // a1 = direction
        addiu   at, r0,-0x0001              // at = -1 (left)
        beql    a1, at, _end                // branch if direction = left...
        sw      v1, 0x0B24(s0)              // ...and enable reversed direction flag

        _end:
        j       0x8013DCCC                  // jump to Link's entry routine to load entry object
        nop
    }
}
