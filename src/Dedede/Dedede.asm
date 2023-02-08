// Dedede.asm

// This file contains file inclusions, action edits, and assembly for Dedede.

scope Dedede {

	// Image commands used by moveset files
	scope EYES: {
		constant OPEN(0xAC000000)
		constant SHOCK(0xAC000001)
		constant CLOSED_1(0xAC000002)	// blink
		constant CLOSED_2(0xAC000003)	// extreme blink
		constant HALF_1(0xAC000004)
		constant HALF_2(0xAC000005)
	}
	scope MOUTH: {
		constant CLOSED(0xAC100000)
		constant OPEN(0xAC100001)
		constant DOT(0xAC100002)
		constant CLENCH(0xAC100003)
		constant SMIRK(0xAC100004)
		constant PUFFED(0xAC100005)
	}

    CLIFF_CATCH:
	dw EYES.CLOSED_2
	Moveset.GO_TO(Moveset.shared.CLIFF_CATCH)

    CLIFF_WAIT:
	dw EYES.CLOSED_2
	Moveset.GO_TO(Moveset.shared.CLIFF_WAIT)

	DOWN_BOUNCE:
	dw EYES.SHOCK; dw MOUTH.OPEN
	Moveset.GO_TO(Moveset.shared.DOWN_BOUNCE)

    // Insert Moveset files
	insert BLINK,"moveset/BLINK.bin"; Moveset.GO_TO(BLINK)            // loops
	IDLE:
    dw 0xbc000003                                   // set slope contour state
    Moveset.SUBROUTINE(BLINK)                   // blink
    dw 0x0400005A; Moveset.SUBROUTINE(BLINK)    // wait 90 frames then blink
    dw 0x0400000A; Moveset.SUBROUTINE(BLINK)    // wait 10 frames then blink
    dw 0x04000050; Moveset.GO_TO(IDLE)         // loop

    insert JUMP,"moveset/JUMP.bin"
    insert JUMP_AERIAL,"moveset/JUMP_AERIAL.bin"
    insert JUMP_LAST,"moveset/JUMP_LAST.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert THROW_F_DATA,"moveset/THROW_F_DATA.bin"
    THROW_F:; Moveset.THROW_DATA(THROW_F_DATA); insert "moveset/THROW_F.bin"
    insert THROW_B_DATA,"moveset/THROW_B_DATA.bin"
    THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); insert "moveset/THROW_B.bin"
    insert CROUCH,"moveset/CROUCH.bin"
    insert CROUCH_IDLE,"moveset/CROUCH_IDLE.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert TEETER,"moveset/TEETER.bin"
    insert EDGE_ATTACK_QUICK_2,"moveset/EDGE_ATTACK_QUICK_2.bin"
    insert EDGE_ATTACK_SLOW_2,"moveset/EDGE_ATTACK_SLOW_2.bin"
    insert TECH,"moveset/TECH.bin"
    insert TECH_ROLL,"moveset/TECH_ROLL.bin"

    insert DOWN_STAND,"moveset/DOWN_STAND.bin"
    insert DAMAGED_FACE,"moveset/DAMAGED_FACE.bin"
    insert DAMAGED_FACE_ELEC,"moveset/DAMAGED_FACE_ELEC.bin"
    DMG_1:; Moveset.SUBROUTINE(DAMAGED_FACE); dw 0
    DMG_2:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0x270); dw 0
    FALCON_DIVE_PULLED:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF44); dw 0
    UNKNOWN_0B4:; Moveset.SUBROUTINE(DAMAGED_FACE); Moveset.GO_TO_FILE(0xF58); dw 0
    DMG_ELEC:; Moveset.SUBROUTINE(DAMAGED_FACE_ELEC); dw 0

    insert TURN,"moveset/TURN.bin"
    insert RUN,"moveset/RUN.bin"; Moveset.GO_TO(RUN)            // loops
    insert DASH,"moveset/DASH.bin"
    insert DASHATTACK,"moveset/DASHATTACK.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert JAB_3,"moveset/JAB_3.bin"
    insert FTILT,"moveset/FTILT.bin"
    insert UTILT,"moveset/UTILT.bin"
    insert DTILT,"moveset/DTILT.bin"
    insert FSMASH,"moveset/FSMASH.bin"
    insert USMASH,"moveset/USMASH.bin"
    insert DSMASH,"moveset/DSMASH.bin"
    insert ATTACK_AIR_D,"moveset/ATTACK_AIR_D.bin"
    insert ATTACK_AIR_F,"moveset/ATTACK_AIR_F.bin"
    insert ATTACK_AIR_U,"moveset/ATTACK_AIR_U.bin"
    insert ATTACK_AIR_B,"moveset/ATTACK_AIR_B.bin"
    insert ATTACK_AIR_N,"moveset/ATTACK_AIR_N.bin"
    insert DOWNATTACK_D,"moveset/DOWNATTACK_D.bin"
    insert DOWNATTACK_U,"moveset/DOWNATTACK_U.bin"
	insert LANDING_AIR_U,"moveset/LANDING_AIR_U.bin"

    insert NSP_SUBROUTINE,"moveset/NSP_SUBROUTINE.bin"
    insert NSP_BEGIN,"moveset/NSP_BEGIN.bin"; Moveset.SUBROUTINE(NSP_SUBROUTINE); dw 0x00000000
    insert NSP_INHALE_THROW_DATA,"moveset/NSP_INHALE_THROW_DATA.bin"
    NSP_INHALE:; Moveset.THROW_DATA(NSP_INHALE_THROW_DATA); insert "moveset/NSP_INHALE.bin"
    insert NSP_SWALLOW,"moveset/NSP_SWALLOW.bin"
    NSP_SPIT:
    dw      0x08000007      // after 7 frames
    Moveset.SUBROUTINE(NSP_SUBROUTINE)
    insert NSP_SPIT_2,"moveset/NSP_SPIT_2.bin"

    insert USP_BEGIN,"moveset/USP_BEGIN.bin"
    insert USP_MOVE,"moveset/USP_MOVE.bin"
    insert USP_LAND,"moveset/USP_LAND.bin"
	insert LANDING_SPECIAL,"moveset/LANDING_SPECIAL.bin"
    insert USP_BONK,"moveset/USP_BONK.bin"
    insert DSP_BEGIN,"moveset/DSP_BEGIN.bin"
    insert DSP_CHARGE,"moveset/DSP_CHARGE.bin"
    insert DSP_SHOOT,"moveset/DSP_SHOOT.bin"

    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
	SHIELD_BREAK:
    dw EYES.CLOSED_2; dw MOUTH.OPEN;
    insert SHIELD_BREAK_CMD,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)      // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert SLEEP, "moveset/SLEEP.bin"; Moveset.GO_TO(SLEEP)                         // loops

    insert STARRING,"moveset/STARRING.bin"

    insert CLAP,"moveset/CLAP.bin"
    insert VICTORY_2,"moveset/VICTORY_2.bin"
    insert VICTORY_3,"moveset/VICTORY_3.bin"

	// Insert AI attack options
	constant CPU_ATTACKS_ORIGIN(origin())
	insert CPU_ATTACKS,"AI/attack_options.bin"
	OS.align(16)

    // Action name constants.
    scope Action {
        constant JUMP_2(0xDF)
        constant JUMP_3(0xE0)
        constant JUMP_4(0xE1)
        constant JUMP_5(0xE2)
        constant JUMP_6(0xE3)
        constant USP_BEGIN(0xE4)
        constant USP_MOVE(0xE5)
        constant USP_LAND(0xE6)

        constant NSP_BEGIN_GROUND(0xE7)
        constant NSP_LOOP_GROUND(0xE8)
        constant USP_CANCEL(0xE9)
        constant NSP_PULL_GROUND(0xEA)
        constant NSP_SWALLOW_GROUND(0xEB)	// unused
        constant NSP_IDLE_GROUND(0xEC)
        constant NSP_SPIT_GROUND(0xED)
        constant NSP_TURN_GROUND(0xEE)
        // NEW ACTIONS
        constant NSP_END_GROUND(0xEF)
        constant NSP_BEGIN_AIR(0xF0)
        constant NSP_LOOP_AIR(0xF1)
        constant NSP_PULL_AIR(0xF2)
        constant NSP_SWALLOW_AIR(0xF3)		// unused
        constant NSP_FALL(0xF4)
        constant NSP_SPIT_AIR(0xF5)
        constant NSP_TURN_AIR(0xF6)
        constant NSP_END_AIR(0xF7)
        constant DSPG_BEGIN(0xF8)
        constant DSPG_CHARGE(0xF9)
        constant DSPG_SHOOT(0xFA)
        constant DSPA_BEGIN(0xFB)
        constant DSPA_CHARGE(0xFC)
        constant DSPA_SHOOT(0xFD)
        constant JAB_3(0xFE)
		constant NSP_WALK_1(0xFF)
		constant NSP_WALK_2(0x100)
		constant NSP_WALK_3(0x101)
        constant USP_CEILING_BONK(0x102)
        //constant DEDEDE_STARRING_LEFT(0x103)
        //constant DEDEDE_STARRING_RIGHT(0x104)

        string_0x0DC:; String.insert("Empty")
        string_0x0DF:; String.insert("Jump2")
        string_0x0E0:; String.insert("Jump3")
        string_0x0E1:; String.insert("Jump4")
        string_0x0E2:; String.insert("Jump5")
        string_0x0E3:; String.insert("Jump6")
        string_0x0E4:; String.insert("SuperJumpBegin")
        string_0x0E5:; String.insert("SuperJumpMove")
        string_0x0E6:; String.insert("SuperJumpLand")
        string_0x0E7:; String.insert("InhaleBeginG")
        string_0x0E8:; String.insert("InhaleLoopG")
        string_0x0E9:; String.insert("SuperJumpCancel")
        string_0x0EA:; String.insert("InhalePullG")
        string_0x0EB:; String.insert("InhaleSwallowG")
        string_0x0EC:; String.insert("InhaleIdleG")
        string_0x0ED:; String.insert("InhaleSpitG")
        string_0x0EE:; String.insert("InhaleTurnG")
        string_0x0EF:; String.insert("InhaleEndG")
        string_0x0F0:; String.insert("InhaleBeginA")
        string_0x0F1:; String.insert("InhaleLoopA")
        string_0x0F2:; String.insert("InhalePullA")
        string_0x0F3:; String.insert("InhaleSwallowA")
        string_0x0F4:; String.insert("InhaleFall")
        string_0x0F5:; String.insert("InhaleSpitA")
        string_0x0F6:; String.insert("InhaleTurnA")
        string_0x0F7:; String.insert("InhaleEndA")
        string_0x0F8:; String.insert("MinionToss1G")
        string_0x0F9:; String.insert("MinionToss2G")
        string_0x0FA:; String.insert("MinionToss3G")
        string_0x0FB:; String.insert("MinionToss1A")
        string_0x0FC:; String.insert("MinionToss2A")
        string_0x0FD:; String.insert("MinionToss3A")
        string_0x0FE:; String.insert("Jab3")
        string_0x0FF:; String.insert("InhaleWalk1")
        string_0x100:; String.insert("InhaleWalk2")
        string_0x101:; String.insert("InhaleWalk3")
        string_0x102:; String.insert("SuperJumpCeilingBonk")
        string_0x103:; String.insert("AppearLeft")
        string_0x104:; String.insert("AppearRight")

        action_string_table:
        dw string_0x0DC
        dw string_0x0DC
        dw string_0x0DC
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
        dw string_0x0EE
        dw string_0x0EF
        dw string_0x0F0
        dw string_0x0F1
        dw string_0x0F2
        dw string_0x0F3
        dw string_0x0F4
        dw string_0x0F5
        dw string_0x0F6
        dw string_0x0F7
        dw string_0x0F8
        dw string_0x0F9
        dw string_0x0FA
        dw string_0x0FB
        dw string_0x0FC
        dw string_0x0FD
        dw string_0x0FE
        dw string_0x0FF
        dw string_0x100
        dw string_0x101
        dw string_0x102
        dw string_0x103
        dw string_0x104
    }

    // Modify Action Parameters             // Action                       // Animation                    // Moveset Data             // Flags
Character.edit_action_parameters(DEDEDE, Action.DeadU,                   File.DEDEDE_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ScreenKO,                File.DEDEDE_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Entry,                  File.DEDEDE_IDLE,                   IDLE,                         -1)
Character.edit_action_parameters(DEDEDE, 0x006,                         File.DEDEDE_IDLE,                   IDLE,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Revive1,                File.DEDEDE_DOWN_BOUNCE_D,           -1,                          -1)
Character.edit_action_parameters(DEDEDE, Action.Revive2,                File.DEDEDE_DOWN_STAND_D,            -1,                          -1)
Character.edit_action_parameters(DEDEDE, Action.ReviveWait,             File.DEDEDE_IDLE,                   IDLE,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Idle,                   File.DEDEDE_IDLE,                   IDLE,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Walk1,                   File.DEDEDE_WALK_1,                  -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Walk2,                   File.DEDEDE_WALK_2,                  -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Walk3,                   File.DEDEDE_WALK_3,                  -1,                         -1)
//// Character.edit_action_parameters(DEDEDE, 0x00E,                          File.DEDEDE_WALK_END,                -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Dash,                   File.DEDEDE_DASH,                   DASH,                       -1)
Character.edit_action_parameters(DEDEDE, Action.Run,                    File.DEDEDE_RUN,                    RUN,                        -1)
Character.edit_action_parameters(DEDEDE, Action.RunBrake,               File.DEDEDE_RUN_BRAKE,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Turn,                   File.DEDEDE_TURN,                   TURN,                       -1)
Character.edit_action_parameters(DEDEDE, Action.TurnRun,                File.DEDEDE_TURN_RUN,               -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.JumpSquat,              File.DEDEDE_LANDING,                -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ShieldJumpSquat,        File.DEDEDE_LANDING,                -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.JumpF,                  File.DEDEDE_JUMP_F,                 JUMP,                       -1)
Character.edit_action_parameters(DEDEDE, Action.JumpB,                  File.DEDEDE_JUMP_B,                 JUMP,                       -1)
Character.edit_action_parameters(DEDEDE, Action.JumpAerialF,            File.DEDEDE_JUMP_AERIAL_F,          JUMP_AERIAL,                -1)
Character.edit_action_parameters(DEDEDE, Action.JumpAerialB,            File.DEDEDE_JUMP_AERIAL_B,          JUMP_AERIAL,                -1)

Character.edit_action_parameters(DEDEDE, Action.KIRBY.Jump2,            File.DEDEDE_JUMP_AERIAL_F,          JUMP_AERIAL,                0)
Character.edit_action_parameters(DEDEDE, Action.KIRBY.Jump3,            File.DEDEDE_JUMP_AERIAL_F,          JUMP_AERIAL,                0)
Character.edit_action_parameters(DEDEDE, Action.KIRBY.Jump4,            File.DEDEDE_JUMP_AERIAL_F,          JUMP_AERIAL,                0)
Character.edit_action_parameters(DEDEDE, Action.KIRBY.Jump5,            File.DEDEDE_JUMP_AERIAL_F,          JUMP_LAST,                  0)
Character.edit_action_parameters(DEDEDE, Action.KIRBY.Jump6,            File.DEDEDE_JUMP_AERIAL_F,          JUMP_LAST,                  0)

Character.edit_action_parameters(DEDEDE, Action.Fall,                   File.DEDEDE_FALL,                   -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.FallAerial,             File.DEDEDE_FALL_AERIAL,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Crouch,                 File.DEDEDE_CROUCH,                 CROUCH,                     -1)
Character.edit_action_parameters(DEDEDE, Action.CrouchIdle,             File.DEDEDE_CROUCH_IDLE,            CROUCH_IDLE,                -1)
Character.edit_action_parameters(DEDEDE, Action.CrouchEnd,              File.DEDEDE_CROUCH_END,             -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.LandingLight,           File.DEDEDE_LANDING,                -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.LandingHeavy,           File.DEDEDE_LANDING,                -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Teeter,                 File.DEDEDE_TEETER,                 TEETER,                     -1)
Character.edit_action_parameters(DEDEDE, Action.TeeterStart,            File.DEDEDE_TEETER_START,           TEETER,                     -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageHigh1,             File.DEDEDE_DAMAGE_HIGH_1,           DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageHigh2,             File.DEDEDE_DAMAGE_HIGH_2,           DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageHigh3,             File.DEDEDE_DAMAGE_HIGH_3,           DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageMid1,              File.DEDEDE_DAMAGE_MID_1,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageMid2,              File.DEDEDE_DAMAGE_MID_2,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageMid3,              File.DEDEDE_DAMAGE_MID_3,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageLow1,              File.DEDEDE_DAMAGE_LOW_1,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageLow2,              File.DEDEDE_DAMAGE_LOW_2,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageLow3,              File.DEDEDE_DAMAGE_LOW_3,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageAir1,              File.DEDEDE_DAMAGE_AIR_1,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageAir2,              File.DEDEDE_DAMAGE_AIR_2,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageAir3,              File.DEDEDE_DAMAGE_AIR_3,            DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageElec1,             File.DEDEDE_DAMAGE_ELEC,             DMG_ELEC,                      -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageElec2,             File.DEDEDE_DAMAGE_ELEC,             DMG_ELEC,                      -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageFlyHigh,           File.DEDEDE_DAMAGE_FLY_HIGH,         DMG_2,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageFlyMid,            File.DEDEDE_DAMAGE_FLY_MID,          DMG_2,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageFlyLow,            File.DEDEDE_DAMAGE_FLY_LOW,          DMG_2,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageFlyTop,            File.DEDEDE_DAMAGE_FLY_TOP,          DMG_2,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.DamageFlyRoll,           File.DEDEDE_DAMAGE_FLY_ROLL,         DMG_2,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.Tumble,                  File.DEDEDE_TUMBLE,                  DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.WallBounce,              File.DEDEDE_TUMBLE,                  DMG_1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.FallSpecial,           File.DEDEDE_SFALL,                      -1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.LandingSpecial,        File.DEDEDE_SFALL_LANDING,            LANDING_SPECIAL,              -1)
 Character.edit_action_parameters(DEDEDE, Action.Tornado,                 File.DEDEDE_TUMBLE,                  -1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.EnterPipe,               File.DEDEDE_ENTER_PIPE,              -1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.ExitPipe,                File.DEDEDE_EXIT_PIPE,               -1,                         -1)
 Character.edit_action_parameters(DEDEDE, Action.ExitPipeWalk,            File.DEDEDE_EXIT_PIPE_WALK,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.CeilingBonk,             File.DEDEDE_CEILINGBONK,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.DownBounceD,             File.DEDEDE_DOWN_BOUNCE_D,             DOWN_BOUNCE,               -1)
Character.edit_action_parameters(DEDEDE, Action.DownBounceU,             File.DEDEDE_DOWN_BOUNCE_U,             DOWN_BOUNCE,               -1)
Character.edit_action_parameters(DEDEDE, Action.DownStandD,              File.DEDEDE_DOWN_STAND_D,              DOWN_STAND,                -1)
Character.edit_action_parameters(DEDEDE, Action.DownStandU,              File.DEDEDE_DOWN_STAND_U,              DOWN_STAND,                -1)
Character.edit_action_parameters(DEDEDE, Action.TechF,                   File.DEDEDE_TECH_F,                   TECH_ROLL,                  -1)
Character.edit_action_parameters(DEDEDE, Action.TechB,                   File.DEDEDE_TECH_B,                   TECH_ROLL,                  -1)
Character.edit_action_parameters(DEDEDE, Action.DownForwardD,            File.DEDEDE_DOWN_FORWARD_D,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.DownForwardU,            File.DEDEDE_DOWN_FORWARD_U,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.DownBackD,               File.DEDEDE_DOWN_BACK_D,             -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.DownBackU,               File.DEDEDE_DOWN_BACK_U,             -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.DownAttackD,             File.DEDEDE_DOWN_ATTACK_D,           DOWNATTACK_D,                         -1)
Character.edit_action_parameters(DEDEDE, Action.DownAttackU,             File.DEDEDE_DOWN_ATTACK_U,           DOWNATTACK_U,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Tech,                    File.DEDEDE_TECH,                    TECH,                         -1)
Character.edit_action_parameters(DEDEDE, 0x053,                          File.DEDEDE_CLANG,                     -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.CliffCatch,             File.DEDEDE_CLIFF_CATCH,            CLIFF_CATCH,                    -1)
Character.edit_action_parameters(DEDEDE, Action.CliffWait,              File.DEDEDE_CLIFF_WAIT,             CLIFF_WAIT,                     -1)
Character.edit_action_parameters(DEDEDE, Action.CliffQuick,             File.DEDEDE_CLIFF_QUICK,            -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffClimbQuick1,       File.DEDEDE_CLIFF_CLIMB_QUICK_1,    -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffClimbQuick2,       File.DEDEDE_CLIFF_CLIMB_QUICK_2,    -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffSlow,              File.DEDEDE_CLIFF_SLOW,             -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffClimbSlow1,        File.DEDEDE_CLIFF_CLIMB_SLOW_1,     -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffClimbSlow2,        File.DEDEDE_CLIFF_CLIMB_SLOW_2,     -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffAttackQuick1,      File.DEDEDE_CLIFF_ATTACK_QUICK_1,   -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffAttackQuick2,      File.DEDEDE_CLIFF_ATTACK_QUICK_2,   EDGE_ATTACK_QUICK_2,            -1)
Character.edit_action_parameters(DEDEDE, Action.CliffAttackSlow1,       File.DEDEDE_CLIFF_ATTACK_SLOW_1,    -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffAttackSlow2,       File.DEDEDE_CLIFF_ATTACK_SLOW_2,    EDGE_ATTACK_SLOW_2,             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffEscapeQuick1,      File.DEDEDE_CLIFF_ESCAPE_QUICK_1,   -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffEscapeQuick2,      File.DEDEDE_CLIFF_ESCAPE_QUICK_2,   -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffEscapeSlow1,       File.DEDEDE_CLIFF_ESCAPE_SLOW_1,    -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.CliffEscapeSlow2,       File.DEDEDE_CLIFF_ESCAPE_SLOW_2,    -1,                             -1)
Character.edit_action_parameters(DEDEDE, Action.LightItemPickup,         File.DEDEDE_LIGHT_ITEM_PICKUP,       -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HeavyItemPickup,         File.DEDEDE_HEAVY_ITEM_PICKUP,       -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemDrop,                File.DEDEDE_ITEM_DROP,               -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowDash,           File.DEDEDE_ITEM_THROW_DASH,         -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowF,              File.DEDEDE_ITEM_THROW,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowB,              File.DEDEDE_ITEM_THROW,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowU,              File.DEDEDE_ITEM_THROW_U,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowD,              File.DEDEDE_ITEM_THROW_D,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowSmashF,         File.DEDEDE_ITEM_THROW,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowSmashB,         File.DEDEDE_ITEM_THROW,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowSmashU,         File.DEDEDE_ITEM_THROW_U,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowSmashD,         File.DEDEDE_ITEM_THROW_D,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirF,           File.DEDEDE_ITEM_THROW_AIR,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirB,           File.DEDEDE_ITEM_THROW_AIR,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirU,           File.DEDEDE_ITEM_THROW_AIR_U,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirD,           File.DEDEDE_ITEM_THROW_AIR_D,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirSmashF,      File.DEDEDE_ITEM_THROW_AIR,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirSmashB,      File.DEDEDE_ITEM_THROW_AIR,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirSmashU,      File.DEDEDE_ITEM_THROW_AIR_U,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ItemThrowAirSmashF,      File.DEDEDE_ITEM_THROW_AIR_D,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HeavyItemThrowF,         File.DEDEDE_HEAVY_ITEM_THROW,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HeavyItemThrowB,         File.DEDEDE_HEAVY_ITEM_THROW,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HeavyItemThrowSmashF,    File.DEDEDE_HEAVY_ITEM_THROW,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HeavyItemThrowSmashB,    File.DEDEDE_HEAVY_ITEM_THROW,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BeamSwordNeutral,        File.DEDEDE_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BeamSwordTilt,           File.DEDEDE_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BeamSwordSmash,          File.DEDEDE_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BeamSwordDash,           File.DEDEDE_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BatNeutral,              File.DEDEDE_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BatTilt,                 File.DEDEDE_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BatSmash,                File.DEDEDE_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.BatDash,                 File.DEDEDE_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.FanNeutral,              File.DEDEDE_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.FanTilt,                 File.DEDEDE_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.FanSmash,                File.DEDEDE_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.FanDash,                 File.DEDEDE_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StarRodNeutral,          File.DEDEDE_ITEM_NEUTRAL,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StarRodTilt,             File.DEDEDE_ITEM_TILT,               -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StarRodSmash,            File.DEDEDE_ITEM_SMASH,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StarRodDash,             File.DEDEDE_ITEM_DASH_ATTACK,        -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.RayGunShoot,            File.DEDEDE_ITEM_SHOOT,             -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.RayGunShootAir,         File.DEDEDE_ITEM_SHOOT_AIR,         -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.FireFlowerShoot,        File.DEDEDE_ITEM_SHOOT,             -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.FireFlowerShootAir,     File.DEDEDE_ITEM_SHOOT_AIR,         -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HammerIdle,             File.DEDEDE_HAMMER_IDLE,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HammerWalk,             File.DEDEDE_HAMMER_MOVE,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HammerTurn,             File.DEDEDE_HAMMER_MOVE,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HammerJumpSquat,        File.DEDEDE_HAMMER_MOVE,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HammerAir,              File.DEDEDE_HAMMER_MOVE,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.HammerLanding,          File.DEDEDE_HAMMER_MOVE,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ShieldOn,               File.DEDEDE_SHIELD_ON,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ShieldOff,              File.DEDEDE_SHIELD_OFF,             -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ShieldDrop,             File.DEDEDE_SHIELD_DROP,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Pass,                   File.DEDEDE_SHIELD_DROP,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.RollF,                  File.DEDEDE_ROLL_F,                 -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.RollB,                  File.DEDEDE_ROLL_B,                 -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ShieldBreak,             File.DEDEDE_DAMAGE_FLY_TOP,        SHIELD_BREAK,               -1)
Character.edit_action_parameters(DEDEDE, Action.ShieldBreakFall,         File.DEDEDE_TUMBLE,                  -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StunLandD,               File.DEDEDE_DOWN_BOUNCE_D,           -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StunLandU,               File.DEDEDE_DOWN_BOUNCE_U,           -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StunStartD,              File.DEDEDE_DOWN_STAND_D,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.StunStartU,              File.DEDEDE_DOWN_STAND_U,            -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Stun,                    File.DEDEDE_STUN,                    STUN,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Sleep,                   File.DEDEDE_STUN,                    SLEEP,                         -1)
Character.edit_action_parameters(DEDEDE, Action.Grab,                   File.DEDEDE_GRAB,                   GRAB,                       -1)
Character.edit_action_parameters(DEDEDE, Action.GrabPull,               File.DEDEDE_GRAB_PULL,              -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.ThrowF,                 File.DEDEDE_THROW_F,                THROW_F,                    -1)
Character.edit_action_parameters(DEDEDE, Action.ThrowB,                 File.DEDEDE_THROW_B,                THROW_B,                    -1)
Character.edit_action_parameters(DEDEDE, Action.CapturePulled,           File.DEDEDE_CAPTURE_PULLED,        DMG_1,                      -1)
Character.edit_action_parameters(DEDEDE, Action.InhalePulled,            File.DEDEDE_TUMBLE,                DMG_1,                      -1)
Character.edit_action_parameters(DEDEDE, Action.InhaleSpat,              File.DEDEDE_TUMBLE,                  -1,                       1)
Character.edit_action_parameters(DEDEDE, Action.InhaleCopied,            File.DEDEDE_TUMBLE,                  -1,                       1)
Character.edit_action_parameters(DEDEDE, Action.EggLayPulled,            File.DEDEDE_CAPTURE_PULLED,        DMG_1,                      -1)
Character.edit_action_parameters(DEDEDE, Action.EggLay,                  File.DEDEDE_IDLE,                    -1,                       1)
Character.edit_action_parameters(DEDEDE, Action.FalconDivePulled,        File.DEDEDE_DAMAGE_HIGH_3,         FALCON_DIVE_PULLED,         -1)
Character.edit_action_parameters(DEDEDE, 0x0B4,                          File.DEDEDE_TUMBLE,                UNKNOWN_0B4,                -1)
Character.edit_action_parameters(DEDEDE, Action.ThrownDKPulled,          File.DEDEDE_THROWN_DK_PULLED,      DMG_1,                      -1)
Character.edit_action_parameters(DEDEDE, Action.ThrownMarioBros,         File.DEDEDE_THROWN_MARIO_BROS,     DMG_1,                      -1)
Character.edit_action_parameters(DEDEDE, 0x0B7,                          -1,                                 -1,                        -1)
Character.edit_action_parameters(DEDEDE, Action.ThrownDK,                File.DEDEDE_THROWN_DK,             DMG_1,                      -1)
Character.edit_action_parameters(DEDEDE, Action.Thrown1,                 File.DEDEDE_THROWN_1,              DMG_1,                      -1)
Character.edit_action_parameters(DEDEDE, Action.Thrown2,                 File.DEDEDE_THROWN_2,              DMG_1,                      -1)
//// Character.edit_action_parameters(DEDEDE, Action.Thrown3,                 -1,                                 -1,                   -1)
//// Character.edit_action_parameters(DEDEDE, 0x0BC,                          -1,                                 -1,                   -1)
Character.edit_action_parameters(DEDEDE, Action.Taunt,                  File.DEDEDE_TAUNT,                  TAUNT,                      -1)
Character.edit_action_parameters(DEDEDE, Action.Jab1,                   File.DEDEDE_JAB_1,                  JAB_1,                      0x00000000)
Character.edit_action_parameters(DEDEDE, Action.Jab2,                   File.DEDEDE_JAB_2,                  JAB_2,                      0x00000000)

Character.edit_action_parameters(DEDEDE, Action.DashAttack,             File.DEDEDE_DASH_ATTACK,            DASHATTACK,                 -1)
Character.edit_action_parameters(DEDEDE, Action.FTiltHigh,              0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.FTiltMidHigh,           0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.FTilt,                  File.DEDEDE_F_TILT,                 FTILT,                      -1)
Character.edit_action_parameters(DEDEDE, Action.FTiltMidLow,            0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.FTiltLow,               0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.UTilt,                  File.DEDEDE_U_TILT,                 UTILT,                      0x00000000)
Character.edit_action_parameters(DEDEDE, Action.DTilt,                  File.DEDEDE_D_TILT,                 DTILT,                      0x40000000)
Character.edit_action_parameters(DEDEDE, Action.FSmashHigh,             0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.FSmashMidHigh,          0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.FSmash,                 File.DEDEDE_F_SMASH,                FSMASH,                     -1)
Character.edit_action_parameters(DEDEDE, Action.FSmashMidLow,           0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.FSmashLow,              0,                                  0x80000000,                 0)
Character.edit_action_parameters(DEDEDE, Action.USmash,                 File.DEDEDE_U_SMASH,                USMASH,                     0x00000000)
Character.edit_action_parameters(DEDEDE, Action.DSmash,                 File.DEDEDE_D_SMASH,                DSMASH,                     0x00000000)
Character.edit_action_parameters(DEDEDE, Action.AttackAirN,             File.DEDEDE_ATTACK_AIR_N,           ATTACK_AIR_N,               -1)
Character.edit_action_parameters(DEDEDE, Action.AttackAirF,             File.DEDEDE_ATTACK_AIR_F,           ATTACK_AIR_F,               -1)
Character.edit_action_parameters(DEDEDE, Action.AttackAirB,             File.DEDEDE_ATTACK_AIR_B,           ATTACK_AIR_B,               -1)
Character.edit_action_parameters(DEDEDE, Action.AttackAirU,             File.DEDEDE_ATTACK_AIR_U,           ATTACK_AIR_U,               -1)
Character.edit_action_parameters(DEDEDE, Action.AttackAirD,             File.DEDEDE_ATTACK_AIR_D,           ATTACK_AIR_D,               -1)
Character.edit_action_parameters(DEDEDE, Action.LandingAirN,            File.DEDEDE_LANDING,                -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.LandingAirF,            File.DEDEDE_LANDING,                -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.LandingAirB,            File.DEDEDE_LANDING_AIR_B,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.LandingAirU,            File.DEDEDE_LANDING_AIR_U,          LANDING_AIR_U,              -1)
Character.edit_action_parameters(DEDEDE, Action.LandingAirD,            File.DEDEDE_LANDING_AIR_D,          -1,                         -1)
Character.edit_action_parameters(DEDEDE, Action.LandingAirX,            File.DEDEDE_LANDING,                -1,                         -1)

     Character.edit_action_parameters(DEDEDE, Action.USP_BEGIN,         File.DEDEDE_USP_BEGIN,              USP_BEGIN,                  0)
     Character.edit_action_parameters(DEDEDE, Action.USP_MOVE,          File.DEDEDE_USP_LOOP,               USP_MOVE,                   0)
     Character.edit_action_parameters(DEDEDE, Action.USP_LAND,          File.DEDEDE_USP_LAND,               USP_LAND,                   0)
     Character.edit_action_parameters(DEDEDE, Action.USP_CANCEL,        File.DEDEDE_USP_CANCEL,             0x80000000,                 0)
     //Character.edit_action_parameters(DEDEDE, Action.USP_MOVE,               File.DEDEDE_USP_LOOP,                                 USP_MOVE,                 0x00000000)
     //Character.edit_action_parameters(DEDEDE, Action.USP_LAND,               File.DEDEDE_USP_LAND,                             USP_LAND,                    0)

    Character.edit_action_parameters(DEDEDE, Action.NSP_BEGIN_GROUND,   File.DEDEDE_NSP_BEGIN,              NSP_BEGIN,                  0x00000000)// 0x1C000000)
    Character.edit_action_parameters(DEDEDE, Action.NSP_LOOP_GROUND,    File.DEDEDE_NSP_LOOP,               NSP_INHALE,                 0x00000000)// 0x1C000000)
    Character.edit_action_parameters(DEDEDE, Action.NSP_PULL_GROUND,    File.DEDEDE_NSP_LOOP,               0x80000000,                 0x00000000)// 0x1C000000)
    Character.edit_action_parameters(DEDEDE, Action.NSP_SWALLOW_GROUND, File.DEDEDE_NSP_PULL,               NSP_SWALLOW,                0x00000000)// 0x1C000000)
    Character.edit_action_parameters(DEDEDE, Action.NSP_IDLE_GROUND,    File.DEDEDE_NSP_INHALED_IDLE,       NSP_SWALLOW,                0x00000000)// 0x0C000000)
    Character.edit_action_parameters(DEDEDE, Action.NSP_SPIT_GROUND,    File.DEDEDE_NSP_SPIT,               NSP_SPIT,                   0x40000000)// 0x4C000000)
    Character.edit_action_parameters(DEDEDE, Action.NSP_TURN_GROUND,    File.DEDEDE_TURN,      			    0x80000000,                 0x00000000)





   // Modify Actions            // Action                   // Staling ID    // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(DEDEDE, Action.JUMP_2,              -1,              0x8013FB00,                   0x8013FB2C,                      0x8013FC4C,                     0x800DE978)
    Character.edit_action(DEDEDE, Action.JUMP_3,              -1,              0x8013FB00,                   0x8013FB2C,                      0x8013FC4C,                     0x800DE978)
    Character.edit_action(DEDEDE, Action.JUMP_4,              -1,              0x8013FB00,                   0x8013FB2C,                      0x8013FC4C,                     0x800DE978)
    Character.edit_action(DEDEDE, Action.JUMP_5,              -1,              0x8013FB00,                   0x8013FB2C,                      0x8013FC4C,                     0x800DE978)
    Character.edit_action(DEDEDE, Action.JUMP_6,              -1,              0x8013FB00,                   0x8013FB2C,                      0x8013FC4C,                     0x800DE978)
    Character.edit_action(DEDEDE, Action.USP_BEGIN,           0x11,            DededeUSP.begin_main_,        0,                               DededeUSP.begin_physics_,       DededeUSP.begin_collision_)
    Character.edit_action(DEDEDE, Action.USP_MOVE,            0x11,            0x00000000,                   DededeUSP.move_cancel_,          DededeUSP.move_physics_,        DededeUSP.move_collision_)
    Character.edit_action(DEDEDE, Action.USP_LAND,            0x11,            DededeUSP.landing_main_,      0,                               0x800D8BB4,                     0x800DDEC4)
    Character.edit_action(DEDEDE, Action.USP_CANCEL,          0x11,            DededeUSP.cancel_main_,       0,                               0x800D90E0,                     DededeUSP.cancel_collision_)
    Character.edit_action(DEDEDE, Action.NSP_BEGIN_GROUND,    0x12,            DededeNSP.ground_begin_main_, 0,                               0x800D8BB4,                     0x80162750)
    Character.edit_action(DEDEDE, Action.NSP_LOOP_GROUND,     0x12,            0x8016201C,                   0x80162468,                      0x800D8BB4,                     DededeNSP.inhale_loop_ground_to_air_check_)
    Character.edit_action(DEDEDE, Action.NSP_PULL_GROUND,     0x12,            0x80162078,                   0,                               0x800D8BB4,                     0x801627BC)
    Character.edit_action(DEDEDE, Action.NSP_SWALLOW_GROUND,  0x12,            0x80162214,                   0,                               0x800D8BB4,                     0x801627E0)
    Character.edit_action(DEDEDE, Action.NSP_IDLE_GROUND,     0x12,                     0,                   DededeNSP.ground_idle_interrupt_, 0x800D8BB4,                     0x80162828)
    Character.edit_action(DEDEDE, Action.NSP_SPIT_GROUND,     0x12,            DededeNSP.ground_spit_main_,                   0,                               0x800D8C14,                     0x80162804)
    Character.edit_action(DEDEDE, Action.NSP_TURN_GROUND,     0x12,            0x801621CC,                   0,                               0x800D8BB4,                     0x8016284C)



//    // Modify Menu Action Parameters             // Action      // Animation                  // Moveset Data             // Flags

    Character.edit_menu_action_parameters(DEDEDE, 0x0,           File.DEDEDE_IDLE,              IDLE,                       -1)
    Character.edit_menu_action_parameters(DEDEDE, 0x1,           File.DEDEDE_VICTORY_1,         0x80000000,                 -1)
    Character.edit_menu_action_parameters(DEDEDE, 0x2,           File.DEDEDE_VICTORY_3,         VICTORY_3,                  -1)
    Character.edit_menu_action_parameters(DEDEDE, 0x3,           File.DEDEDE_VICTORY_2,         VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(DEDEDE, 0x4,           File.DEDEDE_VICTORY_1,         0x80000000,                 -1)
    Character.edit_menu_action_parameters(DEDEDE, 0x5,           File.DEDEDE_CLAP,              CLAP,                       -1)
    Character.edit_menu_action_parameters(DEDEDE, 0xD,           File.DEDEDE_1P_POSE,           0x80000000,                 -1)
    Character.edit_menu_action_parameters(DEDEDE, 0xE,           File.DEDEDE_CPU_POSE,          0x80000000,                 -1)
    Character.edit_menu_action_parameters(DEDEDE, 0x9,           File.DEDEDE_PUPPET_FALL,       -1,                         -1)
    Character.edit_menu_action_parameters(DEDEDE, 0xA,           File.DEDEDE_PUPPET_UP,         -1,                         -1)


//    // Add Action Parameters                // Action Name             // Base Action  // Animation                 // Moveset Data            // Flags
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_END_GROUND,       -1,             File.DEDEDE_NSP_END,          0x80000000,                  0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_BEGIN_AIR,        -1,             File.DEDEDE_NSP_BEGIN,        NSP_BEGIN,                 0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_LOOP_AIR,         -1,             File.DEDEDE_NSP_LOOP,         NSP_INHALE,                 0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_PULL_AIR,         -1,             File.DEDEDE_NSP_LOOP,         0x80000000,                 0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_SWALLOW_AIR,      -1,             File.DEDEDE_NSP_PULL,         NSP_SWALLOW,               0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_FALL,             -1,             File.DEDEDE_NSP_INHALED_IDLE, NSP_SWALLOW,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_SPIT_AIR,         -1,             File.DEDEDE_NSP_SPIT,         NSP_SPIT,                  0x40000000)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_TURN_AIR,         -1,             File.DEDEDE_TURN,             0x80000000,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_END_AIR,          -1,             File.DEDEDE_NSP_END,          0x80000000,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_DSPG_BEGIN,           -1,             File.DEDEDE_DSP_BEGIN,         DSP_BEGIN,                 0)
    Character.add_new_action_params(DEDEDE, DEDEDE_DSPG_CHARGE,          -1,             File.DEDEDE_DSP_CHARGE,        DSP_CHARGE,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_DSPG_SHOOT,           -1,             File.DEDEDE_DSP_SHOOT,         DSP_SHOOT,                 0)
    Character.add_new_action_params(DEDEDE, DEDEDE_DSPA_BEGIN,           -1,             File.DEDEDE_DSP_BEGIN,         DSP_BEGIN,                 0)
    Character.add_new_action_params(DEDEDE, DEDEDE_DSPA_CHARGE,          -1,             File.DEDEDE_DSP_CHARGE,        DSP_CHARGE,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_DSPA_SHOOT,           -1,             File.DEDEDE_DSP_SHOOT,         DSP_SHOOT,                 0)
    Character.add_new_action_params(DEDEDE, DEDEDE_JAB_3,                -1,             File.DEDEDE_JAB_3,             JAB_3,                     0x40000000)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_WALK_1,           -1,             File.DEDEDE_NSP_INHALED_WALK,  0x80000000,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_WALK_2,           -1,             File.DEDEDE_NSP_INHALED_WALK,  0x80000000,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_NSP_WALK_3,           -1,             File.DEDEDE_NSP_INHALED_WALK,  0x80000000,                0)
    Character.add_new_action_params(DEDEDE, DEDEDE_USP_CEILING_BONK,     -1,             File.DEDEDE_USP_CEILING_BONK,  USP_BONK,                  0)
    Character.add_new_action_params(DEDEDE, DEDEDE_STARRING_RIGHT,       -1,             File.DEDEDE_STARRING_RIGHT,    STARRING,                  0x40000008)
    Character.add_new_action_params(DEDEDE, DEDEDE_STARRING_LEFT,        -1,             File.DEDEDE_STARRING_LEFT,     STARRING,                  0x40000008)

    // Add Actions                    // Action Name             // Base Action //Parameters                                // Staling ID    // Main ASM            // Interrupt/Other ASM                  // Movement/Physics ASM     // Collision ASM
    Character.add_new_action(DEDEDE, DEDEDE_NSP_END_GROUND,      -1,           ActionParams.DEDEDE_NSP_END_GROUND,          0x12,            0x800D94C4,            0,                                      0x800D8BB4,                 0x80162798)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_BEGIN_AIR,       -1,           ActionParams.DEDEDE_NSP_BEGIN_AIR,           0x12,            DededeNSP.air_begin_main_,            0,                       0x800D91EC,                 0x80162894)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_LOOP_AIR,        -1,           ActionParams.DEDEDE_NSP_LOOP_AIR,            0x12,            0x8016201C,            0x80162498,                             0x800D91EC,                 DededeNSP.inhale_loop_air_to_ground_check_)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_PULL_AIR,        -1,           ActionParams.DEDEDE_NSP_PULL_AIR,            0x12,            0x80162078,            0,                                      0x800D91EC,                 0x80162900)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_SWALLOW_AIR,     -1,           ActionParams.DEDEDE_NSP_SWALLOW_AIR,         0x12,            0x80162214,            0,                                      0x800D91EC,                 0x80162924)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_FALL,            -1,           ActionParams.DEDEDE_NSP_FALL,                0x12,                     0,            DededeNSP.air_fall_interrupt_,          0x800D91EC,                 0x8016296C) // original physics was 0x801626C0
    Character.add_new_action(DEDEDE, DEDEDE_NSP_SPIT_AIR,        -1,           ActionParams.DEDEDE_NSP_SPIT_AIR,            0x12,            DededeNSP.air_spit_main_, 0,                                   0x800D93E4,                 0x80162948)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_TURN_AIR,        -1,           ActionParams.DEDEDE_NSP_TURN_AIR,            0x12,            0x801621F0,            0,                                      0x800D91EC,                 0x80162990) // original physics was 0x801626C0
    Character.add_new_action(DEDEDE, DEDEDE_NSP_END_AIR,         -1,           ActionParams.DEDEDE_NSP_END_AIR,             0x12,            0x800D94E8,            0,                                      0x800D91EC,                 0x801628DC)
    Character.add_new_action(DEDEDE, DEDEDE_DSPG_BEGIN,          -1,           ActionParams.DEDEDE_DSPG_BEGIN,              0x13,            DededeDSP.begin_main_,  0,                                     0x800D8CCC,                 DededeDSP.ground_begin_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_DSPG_CHARGE,         -1,           ActionParams.DEDEDE_DSPG_CHARGE,             0x13,            DededeDSP.charge_main_, DededeDSP.ground_charge_interrupt_,    0x800D8CCC,                 DededeDSP.ground_charge_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_DSPG_SHOOT,          -1,           ActionParams.DEDEDE_DSPG_SHOOT,              0x13,            DededeDSP.shoot_main_,  0,                                     0x800D8CCC,                 DededeDSP.ground_shoot_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_DSPA_BEGIN,          -1,           ActionParams.DEDEDE_DSPA_BEGIN,              0x13,            DededeDSP.begin_main_,  0,                                     0x800D90E0,                 DededeDSP.air_begin_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_DSPA_CHARGE,         -1,           ActionParams.DEDEDE_DSPA_CHARGE,             0x13,            DededeDSP.charge_main_, DededeDSP.air_charge_interrupt_,       0x800D90E0,                 DededeDSP.air_charge_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_DSPA_SHOOT,          -1,           ActionParams.DEDEDE_DSPA_SHOOT,              0x13,            DededeDSP.shoot_main_,  0,                                     0x800D90E0,                 DededeDSP.air_shoot_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_JAB_3,               -1,           ActionParams.DEDEDE_JAB_3,                   0x3,             0x800D94C4,             0x00000000,                            0x800D8C14,                                     0x800DDF44)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_WALK_1,          -1,           ActionParams.DEDEDE_NSP_WALK_1,              0x12,            0,            			 DededeNSP.ground_walk_interrupt_,       0x8013E548,                 DededeNSP.ground_walk_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_WALK_2,          -1,           ActionParams.DEDEDE_NSP_WALK_2,              0x12,            0,            			 DededeNSP.ground_walk_interrupt_,       0x8013E548,                 DededeNSP.ground_walk_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_NSP_WALK_3,          -1,           ActionParams.DEDEDE_NSP_WALK_3,              0x12,            0,            			 DededeNSP.ground_walk_interrupt_,       0x8013E548,                 DededeNSP.ground_walk_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_USP_CEILING_BONK,    -1,           ActionParams.DEDEDE_USP_CEILING_BONK,        0x12,            DededeUSP.ceiling_bonk_main_, 0x00000000,                      0x00000000,                 DededeUSP.ceiling_bonk_collision_)
    Character.add_new_action(DEDEDE, DEDEDE_STARRING_RIGHT,      -1,           ActionParams.DEDEDE_STARRING_RIGHT,          0x0,             0x8013DA94,            0x00000000,                             0x8013DB2C,                 0x800DE348)
    Character.add_new_action(DEDEDE, DEDEDE_STARRING_LEFT,       -1,           ActionParams.DEDEDE_STARRING_LEFT,           0x0,             0x8013DA94,            0x00000000,                             0x8013DB2C,                 0x800DE348)

	// Set action strings
    Character.table_patch_start(action_string, Character.id.DEDEDE, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

	// Set Special Actions
    Character.table_patch_start(air_usp, Character.id.DEDEDE, 0x4)
    dw      DededeUSP.begin_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.DEDEDE, 0x4)
    dw      DededeUSP.begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.DEDEDE, 0x4)
    dw      DededeDSP.ground_begin_initial_
    OS.patch_end()

    Character.table_patch_start(air_dsp, Character.id.DEDEDE, 0x4)
    dw      DededeDSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_nsp, Character.id.DEDEDE, 0x4)
    dw      DededeNSP.ground_begin_initial_
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.DEDEDE, 0x4)
    dw      DededeNSP.air_begin_initial_
    OS.patch_end()


	// Set grounded script to none (copied it from Mewtwo)
    Character.table_patch_start(grounded_script, Character.id.DEDEDE, 0x4)
    dw  0x800DE44C
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.DEDEDE, 0x4)
    float32 0.85
    OS.patch_end()

    // Patches for full charge DSP effect removal.
    Character.table_patch_start(gfx_routine_end, Character.id.DEDEDE, 0x4)
    dw      charge_gfx_routine_
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.DEDEDE, 0x2)
    dh  0x438
    OS.patch_end()

	// Set Kirby star damage
    Character.table_patch_start(kirby_inhale_struct, 0x8, Character.id.DEDEDE, 0xC)
    dw Character.kirby_inhale_struct.star_damage.DK
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.DEDEDE, 0xC)
    dh 0x20
    OS.patch_end()

    // Set Yoshi Egg Size override ID, these values are just copied from DK
    Character.table_patch_start(yoshi_egg, Character.id.DEDEDE, 0x1C)
    dw  0x40600000
	dw	0x00000000
	dw	0x43660000
	dw	0x00000000
	dw	0x43750000
	dw	0x43750000
	dw	0x43750000
    OS.patch_end()

    Character.table_patch_start(jab_3_action, Character.id.DEDEDE, 0x4)
    dw set_jab_3_action_                    // subroutine which sets action id
    OS.patch_end()

    Character.table_patch_start(jab_3, Character.id.DEDEDE, 0x4)
    dw Character.jab_3.ENABLED              // jab 3 = ENABLED
    OS.patch_end()

    Character.table_patch_start(rapid_jab, Character.id.DEDEDE, 0x4)
    dw      Character.rapid_jab.DISABLED        // disable rapid jab
    OS.patch_end()


    // Use Kirby Entry
    Character.table_patch_start(entry_action, Character.id.DEDEDE, 0x8)
    dw Dedede.Action.DEDEDE_STARRING_RIGHT, Dedede.Action.DEDEDE_STARRING_LEFT
    OS.patch_end()
    Character.table_patch_start(entry_script, Character.id.DEDEDE, 0x4)
    dw 0x8013DCF4                           // kirby entry
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.DEDEDE, 0, 1, 2, 5, 0, 3, 4)

    // Set default costume shield colors
    Character.set_costume_shield_colors(DEDEDE, RED, PINK, ORANGE, BLUE, GREEN, WHITE, NA, NA)

	Character.table_patch_start(initial_script, Character.id.DEDEDE, 0x4)
	dw		initial_script_
	OS.patch_end()

	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.DEDEDE, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.WOLF_USP		// skip USP if unsafe
    OS.patch_end()

	// TODO:
    // Edit cpu attack behaviours, original table is from Falcon
    // edit_attack_behavior(table, attack, override,	start_hb, end_hb, 	min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,  	-1,  9,   		0,  -132, 276, -90, 329)	// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  32,   		0,  0, 100, 100, 330)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  32,   		0,  0, 100, 100, 330)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  9,   		0,  -320, 320, -100, 300)	// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  3,   		0,  -50, 499, -100, 325)	// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, BAIR,   -1,  10,  		0,  -40, 280, 100, 300)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  26,  		0,  250, 1170, 50, 590)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  7,   		0,  45, 560, -45, 270)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,   		0,  50, 240, 65, 355.0)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  5,   		0,  25, 495, 280, 510)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  6,   		0,  -192, 201, -30, 280)	// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  15,  		0,  200, 900, 100, 250)		// todo need to look at kirbys
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  15,  		0,  200, 900, 100, 250)		// todo need to look at kirbys
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  11,   		0,  50, 200, 128, 500)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  14,  		0,  89, 475, 242, 1000)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  14,  		0,  89, 475, 242, 1700)		// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  20,  		0,  -174, 243, 177, 940)	// todo: coords
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,   		0,  -274, 326, 196, 717)	// todo: coords

    // @ Description
    // cleanup script is performed when spawning in
    scope initial_script_: {
		sw		r0, 0x0ADC(v1)					// clear minion 1 ptr
		sw 		r0, 0x0AE0(v1)					// clear minion 2 ptr
		j       0x800D7F0C                      // back to original routine
		sw 		r0, 0x0AE4(v1)					// clear "ammo" count
	}


    // an associated moveset command: b0bc0000 removes the white flicker, this is identical to Samus
    // @ Description
    // Jump table patch which enables Dedede's charged down b effect when another gfx routine ends, or upon action change.
    scope charge_gfx_routine_: {
        lw      t9, 0x0AE4(a3)              // t9 = charge level
        lli     at, 0x0002                  // at = 2
        lw      a0, 0x0020(sp)              // a0 = player object
        bne     t9, at, _end                // skip if charge level != 2 (full)
        lli     a1, GFXRoutine.id.SHEIK_CHARGE // a1 = SHEIK_CHARGE id

        // if the neutral special is full charged
        or      a2, r0, r0                  // a2 = 0
        jal     0x800E9814                  // begin gfx routine
        sw      a3, 0x001C(sp)              // store a3

        _end:
        j       0x800E9A60                  // return
        lw      a3, 0x001C(sp)              // load a3
    }

    // @ Description
    // Sets Dedede's Jab 3 action.
    scope set_jab_3_action_: {
        ori     t7, r0, Dedede.Action.JAB_3 // t7 = action id
        j       0x8014EC30                  // return
        sw      t7, 0x0020(sp)              // store action id
    }

	constant jump_decay(0x42A0)				// same as Kirbys

	jump_multiplier_table:
	dw		0.0		// na
	dw		0.0		// na
	float32 68		// jump 3
	float32 58		// jump 4
	float32 52		// jump 5
	float32 0		// jump 6 (unused)

    // Sets Dedede's inhale Graphics to use an alternate routine from kirby's so that it has a new position relative to dedede
    scope dedede_inhale_gfx_routine_: {
        OS.patch_start(0x7FB54, 0x80104354)
        j       dedede_inhale_gfx_routine_
        lw      t6, 0x0084(v0)              // load player struct
        _return:
        OS.patch_end()

        lw      t6, 0x0008(t6)              // load player id
        addiu   a2, r0, Character.id.DEDEDE
        beq     t6, a2, _dedede_inhale
        lhu     t6, 0x002A(v1)              // original line 1

        j       _return
        addiu   a1, a1, 0x4240              // original line 2

        _dedede_inhale:
        li      a1, dedede_gfx_             // modified routine
        j       _return
        nop
    }

    // @ Description
    // Routine that runs for Dedede's inhale gfx effect, based on 0x80104240
    scope dedede_gfx_: {
		lw             v0, 0x0084 (a0)
		lui            at, 0x447a           // x position offset (fp)
		mtc1           at, f8
		lw             t6, 0x0004 (v0)
		lw             v1, 0x000c (v0)
		lui            at, 0x4366           // y position offset (fp)
		lw             t7, 0x0074 (t6)
		lw             t9, 0x001c (t7)
		sw             t9, 0x0004 (v1)
		lw             t8, 0x0020 (t7)
		lwc1           f16, 0x0004 (v1)
		sw             t8, 0x0008 (v1)
		lw             t9, 0x0024 (t7)
		sw             t9, 0x000c (v1)
		lw             t0, 0x0004 (v0)
		lw             t1, 0x0084 (t0)
		lw             t2, 0x0044 (t1)
		mtc1           t2, f4
		nop
		cvt.s.w        f6, f4
		lwc1           f4, 0x0008 (v1)
		mul.s          f10, f6, f8
		mtc1           at, f6
		j              Size.kirby.nsp.adjust_suck_gfx_ // apply size fix
		lbu            t1, 0x000D(t1)                  // t1 = port
		add.s          f18, f16, f10
		swc1           f8, 0x0008 (v1)

		jr             ra
		swc1           f18, 0x0004 (v1)
    }

	constant INITIAL_ABSORB_TIME(250)	// Kirbys time / 2

	// @ Description
	// Sets initial captured timer for absorb
	// a0 = captured player struct
	// formula is (INITIAL_ABSORB_TIME + captured players %)
	scope custom_initial_absorbed_timer_: {
		OS.patch_start(0xC6848, 0x8014BE08)
		j		custom_initial_absorbed_timer_
		move	a1, a0				// store a0
		_return:
		OS.patch_end()

		lw		a0, 0x0844(a0)		// a0 = absorbing players object
		lw		a0, 0x0084(a0)		// a0 = absorbing players struct
		jal		check_hat_dedede_	// is this dedede?
		nop
		lw		t7, 0x002C(a1)		// t7 = captured players % damage
		move 	a0, a1 				// restore a0
		beqzl	v0, _set_timer		// do normal time if not Dedede or Dedede hat
		addiu	a1, r0, 0x01F4		// original line 2, a1 = default absorb timer

		addiu	t8, r0, INITIAL_ABSORB_TIME
		addu	a1, t8, t7			// absorb time = initial_time + players %

		_set_timer:
		jal		0x8014E3EC			// original line 1
		nop
		j		_return + 4			// back to original routine end
		lw		ra, 0x0024 (sp)		// load ra

	}

	// @ Description
	// returns 1 in v0 if player is Dedede, or wearing Dedede's hat
	// a0 = players struct
	scope check_hat_dedede_: {
		lw		v0, 0x0008(a0)				// v0 = absorbing players character id
		addiu   at, r0, Character.id.DEDEDE // at = DEDEDE
		beq		at, v0, _end				// return v0 as Character.id.DEDEDE if DEDEDE
		lb		at, 0x0980(a0)				// at = current hat ID

		_kirby_check:
		sltiu	at, at, 0x0020				// at = 0 or 1
		beqz	v0, _end
		addiu	v0, r0, 1					// return 1 if wearing dedede hat
		addiu	v0, r0, 0					// otherwise, return 0
		_end:
		jr		ra
		nop
	}

}