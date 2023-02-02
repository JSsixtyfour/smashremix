// Marina.asm

// This file contains file inclusions, action edits, and assembly for Ultra-InterGalactic-Cybot G Marina Liteyears.

scope Marina {

	// Image commands used by moveset files
	scope EYES: {
		constant OPEN(0xAC000000)
		constant DAMAGE(0xAC000001)
	}
	scope MOUTH: {
		constant CLOSED(0xAC100000)
		constant OPEN(0xAC100001)
	}

	DOWN_BOUNCE:
	dw EYES.DAMAGE; dw MOUTH.OPEN
	Moveset.GO_TO(Moveset.shared.DOWN_BOUNCE)

    // Insert Moveset files
	insert BLINK,"moveset/BLINK.bin"; Moveset.GO_TO(BLINK)            // loops
	IDLE:
    dw 0xbc000003                                   // set slope contour state
    Moveset.SUBROUTINE(BLINK)                   // blink
    dw 0x0400005A; Moveset.SUBROUTINE(BLINK)    // wait 90 frames then blink
    dw 0x0400000A; Moveset.SUBROUTINE(BLINK)    // wait 10 frames then blink
    dw 0x04000050; Moveset.GO_TO(IDLE)         // loop

    insert DASH,"moveset/DASH.bin"
    insert RUN, "moveset/RUN.bin"; Moveset.GO_TO(RUN) // loops
    insert RUN_BRAKE,"moveset/RUN_BRAKE.bin"
    insert TURN,"moveset/TURN.bin"
    insert JUMP_1,"moveset/JUMP_1.bin"
    insert JUMP_2,"moveset/JUMP_2.bin"
    insert TEETER,"moveset/TEETER.bin"

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

    insert DOWN_ROLL,"moveset/DOWN_ROLL.bin"
    insert DOWN_ATTACK_D,"moveset/DOWN_ATTACK_D.bin"
    insert DOWN_ATTACK_U,"moveset/DOWN_ATTACK_U.bin"
	insert TECH,"moveset/TECH.bin"
	insert TECH_ROLL,"moveset/TECH_ROLL.bin"
    insert ROLL_F,"moveset/ROLL_F.bin"
    insert ROLL_B,"moveset/ROLL_B.bin"

    insert CLIFF_CATCH,"moveset/CLIFF_CATCH.bin"
    insert CLIFF_WAIT,"moveset/CLIFF_WAIT.bin"
	insert CLIFF_ATK_QUICK_2,"moveset/CLIFF_ATK_QUICK_2.bin"
	insert CLIFF_ATK_SLOW_2,"moveset/CLIFF_ATK_SLOW_2.bin"

    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert THROW_F,"moveset/THROW_F.bin"
    insert THROW_B_DATA,"moveset/THROW_B_DATA.bin"
    THROW_B:; Moveset.THROW_DATA(THROW_B_DATA); insert "moveset/THROW_B.bin"
    insert CARGO_TURN,"moveset/CARGO_TURN.bin"
    insert CARGO_THROW_DATA,"moveset/CARGO_THROW_DATA.bin"
    CARGO_THROW:; Moveset.THROW_DATA(CARGO_THROW_DATA); insert "moveset/CARGO_THROW.bin"
    insert CARGO_SHAKE,"moveset/CARGO_SHAKE.bin"; Moveset.GO_TO(CARGO_SHAKE + 0x4)        // loops

    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1, "moveset/JAB_1.bin"
    insert JAB_2, "moveset/JAB_2.bin"
    insert JAB_LOOP, "moveset/JAB_LOOP.bin"; Moveset.GO_TO(JAB_LOOP) // loops
    insert DASH_ATTACK, "moveset/DASH_ATTACK.bin"
    insert F_TILT_HIGH,"moveset/F_TILT_HIGH.bin"
    insert F_TILT,"moveset/F_TILT.bin"
    insert F_TILT_LOW,"moveset/F_TILT_LOW.bin"
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

    insert NSP,"moveset/NSP.bin"
    NSP_PULL:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/NSP_PULL.bin"
    insert NSPG_THROW_DATA,"moveset/NSPG_THROW_DATA.bin"
    NSPG_THROW:; Moveset.THROW_DATA(NSPG_THROW_DATA); insert "moveset/NSPG_THROW.bin"
    insert NSPG_THROWU_DATA,"moveset/NSPG_THROWU_DATA.bin"
    NSPG_THROWU:; Moveset.THROW_DATA(NSPG_THROWU_DATA); insert "moveset/NSPG_THROWU.bin"
    insert NSPG_THROWD_DATA,"moveset/NSPG_THROWD_DATA.bin"
    NSPG_THROWD:; Moveset.THROW_DATA(NSPG_THROWD_DATA); insert "moveset/NSPG_THROWD.bin"
    insert NSPA_THROW_DATA,"moveset/NSPA_THROW_DATA.bin"
    NSPA_THROW:; Moveset.THROW_DATA(NSPA_THROW_DATA); insert "moveset/NSPA_THROW.bin"
    insert NSPA_THROWU_DATA,"moveset/NSPA_THROWU_DATA.bin"
    NSPA_THROWU:; Moveset.THROW_DATA(NSPA_THROWU_DATA); insert "moveset/NSPA_THROWU.bin"
    insert NSPA_THROWD_DATA,"moveset/NSPA_THROWD_DATA.bin"
    NSPA_THROWD:; Moveset.THROW_DATA(NSPA_THROWD_DATA); insert "moveset/NSPA_THROWD.bin"
    insert USP,"moveset/USP.bin"
    insert DSP_BEGIN, "moveset/DOWN_SPECIAL_BEGIN.bin"
    insert DSP_WAIT, "moveset/DOWN_SPECIAL_WAIT.bin"
    insert DSP_ABSORB, "moveset/DOWN_SPECIAL_ABSORB.bin"
    insert DSP_END, "moveset/DOWN_SPECIAL_END.bin"
    insert DSP_PULL, "moveset/DOWN_SPECIAL_PULL.bin"
    insert DSP_PULL_FAIL, "moveset/DOWN_SPECIAL_PULL_FAIL.bin"
    insert DSP_STOW, "moveset/DOWN_SPECIAL_STOW.bin"

    insert ONEP, "moveset/ONEP.bin"
    insert ENTRY,"moveset/ENTRY.bin"
	insert CLAP,"moveset/CLAP.bin"
	insert VICTORY,"moveset/VICTORY.bin"
	insert VICTORY_1,"moveset/VICTORY_1.bin"
	insert VICTORY_2,"moveset/VICTORY_2.bin"
	insert CSS,"moveset/CSS.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // @ Description
    // Marina's extra actions
    scope Action {
        constant JabLoopStart(0x0DC)
        constant JabLoop(0x0DD)
        constant JabLoopEnd(0x0DE)
        constant Entry_R(0x0DF)
        constant Entry_L(0x0E0)
        constant NSPGround(0x0E1)
        constant NSPGroundPull(0x0E2)
        constant NSPGroundThrow(0x0E3)
        constant NSPGroundThrowU(0x0E4)
        constant NSPGroundThrowD(0x0E5)
        constant NSPAir(0x0E6)
        constant NSPAirPull(0x0E7)
        constant NSPAirThrow(0x0E8)
        constant NSPAirThrowU(0x0E9)
        constant NSPAirThrowD(0x0EA)
        constant Cargo(0x0EB)
        constant CargoWalk1(0x0EC)
        constant CargoWalk2(0x0ED)
        constant CargoWalk3(0x0EE)
        // constant CargoTurn(0x0EF)
        // constant CargoJumpSquat(0x0F0)
        // constant CargoAir(0x0F1)
        // constant CargoLanding(0x0F2)
        // constant CargoDamage(0x0F3)
        // constant CargoThrow(0x0F4)
        // constant CargoThrowAir(0x0F5)
        // constant CargoItemThrowF(0x0F6)
        // constant CargoItemThrowB(0x0F7)
        // constant CargoItemThrowSmashF(0x0F8)
        // constant CargoItemThrowSmashB(0x0F9)
        // constant CargoJump(0x0FA)
        // constant CargoShake(0x0FB)
        // constant USPG(0x0FC)
        // constant USPA(0x0FD)
        // constant ClanpotBeginG(0x0FE)
        // constant ClanpotWaitG(0x0FF)
        // constant ClanpotAbsorbG(0x0100)
        // constant ClanpotEndG(0x0101)
        // constant ClanpotPullG(0x0102)
        // constant ClanpotFailG(0x0103)
        // constant ClanpotStowG(0x0104)
        // constant ClanpotBeginA(0x0105)
        // constant ClanpotWaitA(0x0106)
        // constant ClanpotAbsorbA(0x0107)
        // constant ClanpotEndA(0x0108)
        // constant ClanpotPullA(0x0109)
        // constant ClanpotFailA(0x010A)
        // constant ClanpotStowA(0x010B)

        // strings!
        string_0x0DC:; String.insert("JabLoopStart")
        string_0x0DD:; String.insert("JabLoop")
        string_0x0DE:; String.insert("JabLoopEnd")
        string_0x0DF:; String.insert("EntryR")
        string_0x0E0:; String.insert("EntryL")
        string_0x0E1:; String.insert("JetSnatchG")
        string_0x0E2:; String.insert("JetSnatchPullG")
        string_0x0E3:; String.insert("JetSnatchThrowG")
        string_0x0E4:; String.insert("JetSnatchThrowUG")
        string_0x0E5:; String.insert("JetSnatchThrowDG")
        string_0x0E6:; String.insert("JetSnatchA")
        string_0x0E7:; String.insert("JetSnatchPullA")
        string_0x0E8:; String.insert("JetSnatchThrowA")
        string_0x0E9:; String.insert("JetSnatchThrowUA")
        string_0x0EA:; String.insert("JetSnatchThrowDA")
        string_0x0EB:; String.insert("Cargo")
        string_0x0EC:; String.insert("CargoWalk1")
        string_0x0ED:; String.insert("CargoWalk2")
        string_0x0EE:; String.insert("CargoWalk3")
        string_0x0EF:; String.insert("CargoTurn")
        string_0x0F0:; String.insert("CargoJumpSquat")
        string_0x0F1:; String.insert("CargoAir")
        string_0x0F2:; String.insert("CargoLanding")
        string_0x0F3:; String.insert("CargoDamage")
        string_0x0F4:; String.insert("CargoThrow")
        string_0x0F5:; String.insert("CargoThrowAir")
        string_0x0F6:; String.insert("CargoItemThrowF")
        string_0x0F7:; String.insert("CargoItemThrowB")
        string_0x0F8:; String.insert("CargoItemThrowSmashF")
        string_0x0F9:; String.insert("CargoItemThrowSmashB")
        string_0x0FA:; String.insert("CargoJump")
        string_0x0FB:; String.insert("CargoShake")
        string_0x0FC:; String.insert("AfterburnerUppercutG")
        string_0x0FD:; String.insert("AfterburnerUppercutA")
        string_0x0FE:; String.insert("ClanpotBeginG")
        string_0x0FF:; String.insert("ClanpotWaitG")
        string_0x0100:; String.insert("ClanpotAbsorbG")
        string_0x0101:; String.insert("ClanpotEndG")
        string_0x0102:; String.insert("ClanpotPullG")
        string_0x0103:; String.insert("ClanpotFailG")
        string_0x0104:; String.insert("ClanpotStowG")
        string_0x0105:; String.insert("ClanpotBeginA")
        string_0x0106:; String.insert("ClanpotWaitA")
        string_0x0107:; String.insert("ClanpotAbsorbA")
        string_0x0108:; String.insert("ClanpotEndA")
        string_0x0109:; String.insert("ClanpotPullA")
        string_0x010A:; String.insert("ClanpotFailA")
        string_0x010B:; String.insert("ClanpotStowA")

        action_string_table:
        dw Action.COMMON.string_jabloopstart
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
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
        dw string_0x0100
        dw string_0x0101
        dw string_0x0102
        dw string_0x0103
        dw string_0x0104
        dw string_0x0105
        dw string_0x0106
        dw string_0x0107
        dw string_0x0108
        dw string_0x0109
        dw string_0x010A
        dw string_0x010B
    }

    // Modify Action Parameters              // Action                      // Animation                        // Moveset Data             // Flags
    Character.edit_action_parameters(MARINA, Action.DeadU,                  File.MARINA_TUMBLE,                 DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.ScreenKO,               File.MARINA_TUMBLE,                 DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.Entry,                  File.MARINA_IDLE,                   IDLE,                       -1)
    Character.edit_action_parameters(MARINA, 0x006,                         File.MARINA_IDLE,                   IDLE,                       -1)
    Character.edit_action_parameters(MARINA, Action.Revive1,                File.MARINA_DOWN_BNCE_D,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Revive2,                File.MARINA_DOWN_STND_D,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ReviveWait,             File.MARINA_IDLE,                   IDLE,                       -1)
    Character.edit_action_parameters(MARINA, Action.Idle,                   File.MARINA_IDLE,                   IDLE,                       -1)
    Character.edit_action_parameters(MARINA, Action.Walk1,                  File.MARINA_WALK_1,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Walk2,                  File.MARINA_WALK_2,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Walk3,                  File.MARINA_WALK_3,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, 0x00E,                         File.MARINA_WALK_END,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Dash,                   File.MARINA_DASH,                   DASH,                       0x10000000)
    Character.edit_action_parameters(MARINA, Action.Run,                    File.MARINA_RUN,                    RUN,                        -1)
    Character.edit_action_parameters(MARINA, Action.RunBrake,               File.MARINA_RUN_BRAKE,              RUN_BRAKE,                  -1)
    Character.edit_action_parameters(MARINA, Action.Turn,                   File.MARINA_TURN,                   TURN,                       -1)
    Character.edit_action_parameters(MARINA, Action.TurnRun,                File.MARINA_TURN_RUN,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.JumpSquat,              File.MARINA_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ShieldJumpSquat,        File.MARINA_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.JumpF,                  File.MARINA_JUMP_F,                 JUMP_1,                     -1)
    Character.edit_action_parameters(MARINA, Action.JumpB,                  File.MARINA_JUMP_B,                 JUMP_1,                     -1)
    Character.edit_action_parameters(MARINA, Action.JumpAerialF,            File.MARINA_JUMP_AERIAL_F,          JUMP_2,                     0x10000000)
    Character.edit_action_parameters(MARINA, Action.JumpAerialB,            File.MARINA_JUMP_AERIAL_B,          JUMP_2,                     0x10000000)
    Character.edit_action_parameters(MARINA, Action.Fall,                   File.MARINA_FALL,                   -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FallAerial,             File.MARINA_FALL_AERIAL,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Crouch,                 File.MARINA_CROUCH,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CrouchIdle,             File.MARINA_CROUCH_IDLE,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CrouchEnd,              File.MARINA_CROUCH_END,             -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.LandingLight,           File.MARINA_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.LandingHeavy,           File.MARINA_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Pass,                   File.MARINA_PLAT_DROP,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ShieldDrop,             File.MARINA_PLAT_DROP,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Teeter,                 File.MARINA_TEETER,                 TEETER,                     -1)
    Character.edit_action_parameters(MARINA, Action.TeeterStart,            File.MARINA_TEETERSTART,            TEETER,                     -1)
    Character.edit_action_parameters(MARINA, Action.DamageHigh1,            File.MARINA_DMG_HIGH_1,             DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageHigh2,            File.MARINA_DMG_HIGH_2,             DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageHigh3,            File.MARINA_DMG_HIGH_3,             DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageMid1,             File.MARINA_DMG_MID_1,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageMid2,             File.MARINA_DMG_MID_2,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageMid3,             File.MARINA_DMG_MID_3,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageLow1,             File.MARINA_DMG_LOW_1,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageLow2,             File.MARINA_DMG_LOW_2,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageLow3,             File.MARINA_DMG_LOW_3,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageAir1,             File.MARINA_DMG_AIR_1,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageAir2,             File.MARINA_DMG_AIR_2,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageAir3,             File.MARINA_DMG_AIR_3,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageElec1,            File.MARINA_DMG_ELEC,               DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageElec2,            File.MARINA_DMG_ELEC,               DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageFlyHigh,          File.MARINA_DMG_FLY_HIGH,           DMG_2,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageFlyMid,           File.MARINA_DMG_FLY_MID,            DMG_2,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageFlyLow,           File.MARINA_DMG_FLY_LOW,            DMG_2,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageFlyTop,           File.MARINA_DMG_FLY_TOP,            DMG_2,                      -1)
    Character.edit_action_parameters(MARINA, Action.DamageFlyRoll,          File.MARINA_DMG_FLY_ROLL,           DMG_2,                      -1)
    Character.edit_action_parameters(MARINA, Action.WallBounce,             File.MARINA_TUMBLE,                 DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.Tumble,                 File.MARINA_TUMBLE,                 DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.FallSpecial,            File.MARINA_FALL_SPECIAL,           -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.LandingSpecial,         File.MARINA_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Tornado,                File.MARINA_TUMBLE,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.EnterPipe,              File.MARINA_ENTER_PIPE,             -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ExitPipe,               File.MARINA_EXIT_PIPE,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ExitPipeWalk,           File.MARINA_EXIT_PIPE_WALK,         -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CeilingBonk,            File.MARINA_CEILING_BONK,           -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.DownBounceD,            File.MARINA_DOWN_BNCE_D,            DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(MARINA, Action.DownBounceU,            File.MARINA_DOWN_BNCE_U,            DOWN_BOUNCE,                -1)
    Character.edit_action_parameters(MARINA, Action.DownStandD,             File.MARINA_DOWN_STND_D,            DOWN_STAND,                 -1)
    Character.edit_action_parameters(MARINA, Action.DownStandU,             File.MARINA_DOWN_STND_U,            DOWN_STAND,                 -1)
    Character.edit_action_parameters(MARINA, Action.TechF,                  File.MARINA_TECH_F,                 TECH_ROLL,                  -1)
    Character.edit_action_parameters(MARINA, Action.TechB,                  File.MARINA_TECH_B,                 TECH_ROLL,                  -1)
    Character.edit_action_parameters(MARINA, Action.DownForwardD,           File.MARINA_DOWN_FWRD_D,            DOWN_ROLL,                  0x50000000)
    Character.edit_action_parameters(MARINA, Action.DownForwardU,           File.MARINA_DOWN_FWRD_U,            DOWN_ROLL,                  0x50000000)
    Character.edit_action_parameters(MARINA, Action.DownBackD,              File.MARINA_DOWN_BACK_D,            DOWN_ROLL,                  0x50000000)
    Character.edit_action_parameters(MARINA, Action.DownBackU,              File.MARINA_DOWN_BACK_U,            DOWN_ROLL,                  0x50000000)
    Character.edit_action_parameters(MARINA, Action.DownAttackD,            File.MARINA_DOWN_ATK_D,             DOWN_ATTACK_D,              -1)
    Character.edit_action_parameters(MARINA, Action.DownAttackU,            File.MARINA_DOWN_ATK_U,             DOWN_ATTACK_U,              -1)
    Character.edit_action_parameters(MARINA, Action.Tech,                   File.MARINA_TECH,                   TECH,                       -1)
    Character.edit_action_parameters(MARINA, Action.ClangRecoil,            File.MARINA_CLANG_RECOIL,           -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffCatch,             File.MARINA_CLF_CATCH,              CLIFF_CATCH,                -1)
    Character.edit_action_parameters(MARINA, Action.CliffWait,              File.MARINA_CLF_WAIT,               CLIFF_WAIT,                 -1)
    Character.edit_action_parameters(MARINA, Action.CliffQuick,             File.MARINA_CLF_QUICK,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffClimbQuick1,       File.MARINA_CLF_CLM_Q_1,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffClimbQuick2,       File.MARINA_CLF_CLM_Q_2,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffSlow,              File.MARINA_CLF_SLOW,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffClimbSlow1,        File.MARINA_CLF_CLM_S_1,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffClimbSlow2,        File.MARINA_CLF_CLM_S_2,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffAttackQuick1,      File.MARINA_CLF_ATK_Q_1,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffAttackQuick2,      File.MARINA_CLF_ATK_Q_2,            CLIFF_ATK_QUICK_2,          -1)
    Character.edit_action_parameters(MARINA, Action.CliffAttackSlow1,       File.MARINA_CLF_ATK_S_1,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffAttackSlow2,       File.MARINA_CLF_ATK_S_2,            CLIFF_ATK_SLOW_2,           -1)
    Character.edit_action_parameters(MARINA, Action.CliffEscapeQuick1,      File.MARINA_CLF_ESC_Q_1,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffEscapeQuick2,      File.MARINA_CLF_ESC_Q_2,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffEscapeSlow1,       File.MARINA_CLF_ESC_S_1,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.CliffEscapeSlow2,       File.MARINA_CLF_ESC_S_2,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.LightItemPickup,        File.MARINA_L_ITM_PICKUP,           -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HeavyItemPickup,        File.MARINA_NSPG_PULL,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemDrop,               File.MARINA_ITM_DROP,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowDash,          File.MARINA_ITM_THROW_DASH,         -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowF,             File.MARINA_ITM_THROW_F,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowB,             File.MARINA_ITM_THROW_F,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowU,             File.MARINA_ITM_THROW_U,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowD,             File.MARINA_ITM_THROW_D,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowSmashF,        File.MARINA_ITM_THROW_F,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowSmashB,        File.MARINA_ITM_THROW_F,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowSmashU,        File.MARINA_ITM_THROW_U,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowSmashD,        File.MARINA_ITM_THROW_D,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirF,          File.MARINA_ITM_THROW_AIR_F,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirB,          File.MARINA_ITM_THROW_AIR_F,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirU,          File.MARINA_ITM_THROW_AIR_U,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirD,          File.MARINA_ITM_THROW_AIR_D,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirSmashF,     File.MARINA_ITM_THROW_AIR_F,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirSmashB,     File.MARINA_ITM_THROW_AIR_F,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirSmashU,     File.MARINA_ITM_THROW_AIR_U,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ItemThrowAirSmashD,     File.MARINA_ITM_THROW_AIR_D,        -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HeavyItemThrowF,        File.MARINA_CARGO_THROW,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HeavyItemThrowB,        File.MARINA_CARGO_THROW,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HeavyItemThrowSmashF,   File.MARINA_CARGO_THROW,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HeavyItemThrowSmashB,   File.MARINA_CARGO_THROW,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BeamSwordNeutral,       File.MARINA_ITM_NEUTRAL,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BeamSwordTilt,          File.MARINA_ITM_TILT,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BeamSwordSmash,         File.MARINA_ITM_SMASH,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BeamSwordDash,          File.MARINA_ITM_DASH,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BatNeutral,             File.MARINA_ITM_NEUTRAL,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BatTilt,                File.MARINA_ITM_TILT,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BatSmash,               File.MARINA_ITM_SMASH,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.BatDash,                File.MARINA_ITM_DASH,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FanNeutral,             File.MARINA_ITM_NEUTRAL,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FanTilt,                File.MARINA_ITM_TILT,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FanSmash,               File.MARINA_ITM_SMASH,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FanDash,                File.MARINA_ITM_DASH,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StarRodNeutral,         File.MARINA_ITM_NEUTRAL,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StarRodTilt,            File.MARINA_ITM_TILT,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StarRodSmash,           File.MARINA_ITM_SMASH,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StarRodDash,            File.MARINA_ITM_DASH,               -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.RayGunShoot,            File.MARINA_ITM_SHOOT,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.RayGunShootAir,         File.MARINA_ITM_SHOOT_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FireFlowerShoot,        File.MARINA_ITM_SHOOT,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FireFlowerShootAir,     File.MARINA_ITM_SHOOT_AIR,          -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HammerIdle,             File.MARINA_HAMMER_IDLE,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HammerWalk,             File.MARINA_HAMMER_MOVE,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HammerTurn,             File.MARINA_HAMMER_MOVE,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HammerJumpSquat,        File.MARINA_HAMMER_MOVE,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HammerAir,              File.MARINA_HAMMER_MOVE,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.HammerLanding,          File.MARINA_HAMMER_MOVE,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ShieldOn,               File.MARINA_SHIELD_ON,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ShieldOff,              File.MARINA_SHIELD_OFF,             -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.RollF,                  File.MARINA_ROLL_F,                 ROLL_F,                     0x50000000)
    Character.edit_action_parameters(MARINA, Action.RollB,                  File.MARINA_ROLL_B,                 ROLL_B,                     0x50000000)
    Character.edit_action_parameters(MARINA, Action.ShieldBreak,            File.MARINA_DMG_FLY_TOP,            SHIELD_BREAK,               -1)
    Character.edit_action_parameters(MARINA, Action.ShieldBreakFall,        File.MARINA_TUMBLE,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StunLandD,              File.MARINA_DOWN_BNCE_D,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StunLandU,              File.MARINA_DOWN_BNCE_U,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StunStartD,             File.MARINA_DOWN_STND_D,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.StunStartU,             File.MARINA_DOWN_STND_U,            -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.Stun,                   File.MARINA_STUN,                   STUN,                       -1)
    Character.edit_action_parameters(MARINA, Action.Sleep,                  File.MARINA_STUN,                   ASLEEP,                     -1)
    Character.edit_action_parameters(MARINA, Action.Grab,                   File.MARINA_GRAB,                   GRAB,                       -1)
    Character.edit_action_parameters(MARINA, Action.GrabPull,               File.MARINA_GRAB_PULL,              -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.ThrowF,                 File.MARINA_THROW_F,                THROW_F,                    -1)
    Character.edit_action_parameters(MARINA, Action.ThrowB,                 File.MARINA_THROW_B,                THROW_B,                    0x50000000)
    Character.edit_action_parameters(MARINA, Action.CapturePulled,          File.MARINA_CAPTURE_PULLED,         DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.InhalePulled,           File.MARINA_TUMBLE,                 DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.InhaleSpat,             File.MARINA_TUMBLE,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.InhaleCopied,           File.MARINA_TUMBLE,                 -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.EggLayPulled,           File.MARINA_CAPTURE_PULLED,         DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.EggLay,                 File.MARINA_IDLE,                   -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.FalconDivePulled,       File.MARINA_DMG_HIGH_3,             -1,                         -1)
    Character.edit_action_parameters(MARINA, 0x0B4,                         File.MARINA_TUMBLE,                 UNKNOWN_0B4,                -1)
    Character.edit_action_parameters(MARINA, Action.ThrownDKPulled,         File.MARINA_THROWN_DKPULLED,        DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.ThrownMarioBros,        File.MARINA_THROWN_MARIO_BROS,      DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.ThrownDK,               File.MARINA_THROWN_DK,              DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.Thrown1,                File.MARINA_THROWN_1,               DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.Thrown2,                File.MARINA_THROWN_2,               DMG_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.Taunt,                  File.MARINA_TAUNT,                  TAUNT,                      -1)
    Character.edit_action_parameters(MARINA, Action.Jab1,                   File.MARINA_JAB_1,                  JAB_1,                      -1)
    Character.edit_action_parameters(MARINA, Action.Jab2,                   File.MARINA_JAB_2,                  JAB_2,                      -1)
    Character.edit_action_parameters(MARINA, Action.DashAttack,             File.MARINA_DASH_ATTACK,            DASH_ATTACK,                -1)
    Character.edit_action_parameters(MARINA, Action.FTiltHigh,              File.MARINA_FTILT_HIGH,             F_TILT_HIGH,                -1)
    Character.edit_action_parameters(MARINA, Action.FTiltMidHigh,           0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARINA, Action.FTilt,                  File.MARINA_FTILT,                  F_TILT,                     1)
    Character.edit_action_parameters(MARINA, Action.FTiltMidLow,            0,                                  0x80000000,                 0)
    Character.edit_action_parameters(MARINA, Action.FTiltLow,               File.MARINA_FTILT_LOW,              F_TILT_LOW,                 -1)
    Character.edit_action_parameters(MARINA, Action.UTilt,                  File.MARINA_UTILT,                  U_TILT,                     -1)
    Character.edit_action_parameters(MARINA, Action.DTilt,                  File.MARINA_DTILT,                  D_TILT,                     -1)
    Character.edit_action_parameters(MARINA, Action.FSmashHigh,             0,                                  0x80000000,                 -1)
    Character.edit_action_parameters(MARINA, Action.FSmash,                 File.MARINA_FSMASH,                 F_SMASH,                    -1)
    Character.edit_action_parameters(MARINA, Action.FSmashLow,              0,                                  0x80000000,                 -1)
    Character.edit_action_parameters(MARINA, Action.USmash,                 File.MARINA_USMASH,                 U_SMASH,                    0)
    Character.edit_action_parameters(MARINA, Action.DSmash,                 File.MARINA_DSMASH,                 D_SMASH,                    -1)
    Character.edit_action_parameters(MARINA, Action.AttackAirN,             File.MARINA_ATTACK_AIR_N,           ATTACK_AIR_N,               -1)
    Character.edit_action_parameters(MARINA, Action.AttackAirF,             File.MARINA_ATTACK_AIR_F,           ATTACK_AIR_F,               -1)
    Character.edit_action_parameters(MARINA, Action.AttackAirB,             File.MARINA_ATTACK_AIR_B,           ATTACK_AIR_B,               -1)
    Character.edit_action_parameters(MARINA, Action.AttackAirU,             File.MARINA_ATTACK_AIR_U,           ATTACK_AIR_U,               -1)
    Character.edit_action_parameters(MARINA, Action.AttackAirD,             File.MARINA_ATTACK_AIR_D,           ATTACK_AIR_D,               -1)
    Character.edit_action_parameters(MARINA, Action.LandingAirF,            File.MARINA_LANDING_AIR_F,          -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.LandingAirB,            File.MARINA_LANDING_AIR_B,          -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.LandingAirX,            File.MARINA_LANDING,                -1,                         -1)
    Character.edit_action_parameters(MARINA, Action.JabLoopStart,           File.MARINA_JAB_LOOP_START,         0x80000000,                 0)
    Character.edit_action_parameters(MARINA, Action.JabLoop,                File.MARINA_JAB_LOOP,               JAB_LOOP,                   0)
    Character.edit_action_parameters(MARINA, Action.JabLoopEnd,             File.MARINA_JAB_LOOP_END,           0x80000000,                 0)
    Character.edit_action_parameters(MARINA, Action.Entry_R,                File.MARINA_ENTRY,                  ENTRY,                      0x40000000)
    Character.edit_action_parameters(MARINA, Action.Entry_L,                File.MARINA_ENTRY,                  ENTRY,                      0x40000000)
    Character.edit_action_parameters(MARINA, Action.NSPGround,              File.MARINA_NSPG,                   NSP,                        0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPGroundPull,          File.MARINA_NSPG_PULL,              NSP_PULL,                   0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPGroundThrow,         File.MARINA_NSPG_THROW,             NSPG_THROW,                 0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPGroundThrowU,        File.MARINA_NSPG_THROW_U,           NSPG_THROWU,                0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPGroundThrowD,        File.MARINA_NSPG_THROW_D,           NSPG_THROWD,                0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPAir,                 File.MARINA_NSPA,                   NSP,                        0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPAirPull,             File.MARINA_NSPA_PULL,              NSP_PULL,                   0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPAirThrow,            File.MARINA_NSPA_THROW,             NSPA_THROW,                 0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPAirThrowU,           File.MARINA_NSPA_THROW_U,           NSPA_THROWU,                0x10000000)
    Character.edit_action_parameters(MARINA, Action.NSPAirThrowD,           File.MARINA_NSPA_THROW_D,           NSPA_THROWD,                0x10000000)
    Character.edit_action_parameters(MARINA, Action.Cargo,                  File.MARINA_CARGO,                  0x80000000,                 0x10000000)
    Character.edit_action_parameters(MARINA, Action.CargoWalk1,             File.MARINA_CARGO_WALK_1,           0x80000000,                 0x10000000)
    Character.edit_action_parameters(MARINA, Action.CargoWalk2,             File.MARINA_CARGO_WALK_2,           0x80000000,                 0x10000000)
    Character.edit_action_parameters(MARINA, Action.CargoWalk3,             File.MARINA_CARGO_WALK_3,           0x80000000,                 0x10000000)

    // Modify Actions             // Action                 // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(MARINA, Action.JabLoopStart,      0x4,            0x8014F0D0,                     0,                              0x800D8BB4,                     0x800DDF44)
    Character.edit_action(MARINA, Action.JabLoop,           0x4,            0x8014F2A8,                     0x8014F388,                     0x800D8BB4,                     0x800DDF44)
    Character.edit_action(MARINA, Action.JabLoopEnd,        0x4,            0x800D94C4,                     0,                              0x800D8BB4,                     0x800DDF44)
    Character.edit_action(MARINA, Action.Entry_R,           0,              0x8013DA94,                     0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(MARINA, Action.Entry_L,           0,              0x8013DA94,                     0,                              0x8013DB2C,                     0x800DE348)
    Character.edit_action(MARINA, Action.NSPGround,         0x12,           0x800D94C4,                     0,                              MarinaNSP.ground_physics_,      MarinaNSP.ground_collision_)
    Character.edit_action(MARINA, Action.NSPGroundPull,     0x12,           MarinaNSP.ground_pull_main_,    0,                              0x800D8BB4,                     MarinaNSP.grab_ground_collision_)
    Character.edit_action(MARINA, Action.NSPGroundThrow,    0x12,           0x8014A0C0,                     MarinaNSP.throw_turn_,          0x800D8BB4,                     0x80149B78)
    Character.edit_action(MARINA, Action.NSPGroundThrowU,   0x12,           0x8014A0C0,                     0,                              0x800D8BB4,                     0x80149B78)
    Character.edit_action(MARINA, Action.NSPGroundThrowD,   0x12,           0x8014A0C0,                     0,                              0x800D8BB4,                     0x80149B78)
    Character.edit_action(MARINA, Action.NSPAir,            0x12,           0x800D94E8,                     0,                              MarinaNSP.air_physics_,         MarinaNSP.air_collision_)
    Character.edit_action(MARINA, Action.NSPAirPull,        0x12,           MarinaNSP.air_pull_main_,       0,                              0x800D91EC,                     MarinaNSP.grab_air_collision_)
    Character.edit_action(MARINA, Action.NSPAirThrow,       0x12,           0x8014A0C0,                     MarinaNSP.throw_turn_,          MarinaNSP.throw_air_physics_,   MarinaNSP.throw_air_collision_)
    Character.edit_action(MARINA, Action.NSPAirThrowU,      0x12,           0x8014A0C0,                     0,                              MarinaNSP.throw_air_physics_,   MarinaNSP.throw_air_collision_)
    Character.edit_action(MARINA, Action.NSPAirThrowD,      0x12,           0x8014A0C0,                     0,                              MarinaNSP.throw_air_physics_,   MarinaNSP.throw_air_collision_)
    Character.edit_action(MARINA, Action.Cargo,             0x23,           0,                              0x8014D400,                     0x800D8BB4,                     0x8014D478)
    Character.edit_action(MARINA, Action.CargoWalk1,        0x23,           0,                              0x8014D590,                     0x8013E548,                     0x8014D478)
    Character.edit_action(MARINA, Action.CargoWalk2,        0x23,           0,                              0x8014D590,                     0x8013E548,                     0x8014D478)
    Character.edit_action(MARINA, Action.CargoWalk3,        0x23,           0,                              0x8014D590,                     0x8013E548,                     0x8014D478)

    // Add Action Parameters                // Action Name      // Base Action  // Animation                    // Moveset Data             // Flags
    Character.add_new_action_params(MARINA, CargoTurn,          -1,             File.MARINA_CARGO_TURN,         CARGO_TURN,                 0x10000000)
    Character.add_new_action_params(MARINA, CargoJumpSquat,     -1,             File.MARINA_CARGO_JUMPSQUAT,    0x80000000,                 0x10000000)
    Character.add_new_action_params(MARINA, CargoAir,           -1,             File.MARINA_CARGO_AIR,          0x80000000,                 0x10000000)
    Character.add_new_action_params(MARINA, CargoLanding,       -1,             File.MARINA_CARGO_JUMPSQUAT,    0x80000000,                 0x10000000)
    Character.add_new_action_params(MARINA, CargoDamage,        -1,             File.MARINA_CARGO_AIR,          0x80000000,                 0x10000000)
    Character.add_new_action_params(MARINA, CargoThrow,         -1,             File.MARINA_CARGO_THROW,        CARGO_THROW,                0x10000000)
    Character.add_new_action_params(MARINA, CargoThrowAir,      -1,             File.MARINA_CARGO_THROW_AIR,    CARGO_THROW,                0x10000000)
    Character.add_new_action_params(MARINA, CargoItemThrowF,    -1,             File.MARINA_CARGO_THROW,        0x8F8,                      0x10000000)
    Character.add_new_action_params(MARINA, CargoItemThrowB,    -1,             File.MARINA_CARGO_THROW,        0x908,                      0x10000000)
    Character.add_new_action_params(MARINA, CargoItemThrowSF,   -1,             File.MARINA_CARGO_THROW,        0x918,                      0x10000000)
    Character.add_new_action_params(MARINA, CargoItemThrowSB,   -1,             File.MARINA_CARGO_THROW,        0x928,                      0x10000000)
    Character.add_new_action_params(MARINA, CargoJump,          -1,             File.MARINA_CARGO_JUMP,         0x80000000,                 0x10000000)
    Character.add_new_action_params(MARINA, CargoShake,         -1,             File.MARINA_CARGO_SHAKE,        CARGO_SHAKE,                0x10000000)
    Character.add_new_action_params(MARINA, USPG,               -1,             File.MARINA_USPG,               USP,                        0x10000000)
    Character.add_new_action_params(MARINA, USPA,               -1,             File.MARINA_USPA,               USP,                        0x10000000)
    Character.add_new_action_params(MARINA, DSPG_Begin,         -1,             File.MARINA_DSPG_BEGIN,         DSP_BEGIN,                  0x10000000)
    Character.add_new_action_params(MARINA, DSPG_Wait,          -1,             File.MARINA_DSPG_WAIT,          DSP_WAIT,                   0x10000000)
    Character.add_new_action_params(MARINA, DSPG_Absorb,        -1,             File.MARINA_DSPG_ABSORB,        DSP_ABSORB,                 0x10000000)
    Character.add_new_action_params(MARINA, DSPG_End,           -1,             File.MARINA_DSPG_END,           DSP_END,                    0x10000000)
    Character.add_new_action_params(MARINA, DSPG_Pull,          -1,             File.MARINA_DSPG_PULL,          DSP_PULL,                   0x10000000)
    Character.add_new_action_params(MARINA, DSPG_Pull_Fail,     -1,             File.MARINA_DSPG_PULL_FAIL,     DSP_PULL_FAIL,              0x10000000)
    Character.add_new_action_params(MARINA, DSPG_Stow,          -1,             File.MARINA_DSPG_STOW,          DSP_STOW,                   0x10000000)
    Character.add_new_action_params(MARINA, DSPA_Begin,         -1,             File.MARINA_DSPA_BEGIN,         DSP_BEGIN,                  0x10000000)
    Character.add_new_action_params(MARINA, DSPA_Wait,          -1,             File.MARINA_DSPA_WAIT,          DSP_WAIT,                   0x10000000)
    Character.add_new_action_params(MARINA, DSPA_Absorb,        -1,             File.MARINA_DSPA_ABSORB,        DSP_ABSORB,                 0x10000000)
    Character.add_new_action_params(MARINA, DSPA_End,           -1,             File.MARINA_DSPA_END,           DSP_END,                    0x10000000)
    Character.add_new_action_params(MARINA, DSPA_Pull,          -1,             File.MARINA_DSPA_PULL,          DSP_PULL,                   0x10000000)
    Character.add_new_action_params(MARINA, DSPA_Pull_Fail,     -1,             File.MARINA_DSPA_PULL_FAIL,     DSP_PULL_FAIL,              0x10000000)
    Character.add_new_action_params(MARINA, DSPA_Stow,          -1,             File.MARINA_DSPA_STOW,          DSP_STOW,                   0x10000000)

    // Add Actions                   // Action Name     // Base Action  //Parameters                    // Staling ID   // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM             // Collision ASM
    Character.add_new_action(MARINA, CargoTurn,         -1,             ActionParams.CargoTurn,         0x23,           0x8014D740,                     0x8014D790,                     0x800D8BB4,                         0x8014D478)
    Character.add_new_action(MARINA, CargoJumpSquat,    -1,             ActionParams.CargoJumpSquat,    0x23,           0x8014D850,                     0x8014D8E4,                     0x800D8BB4,                         0x8014D478)
    Character.add_new_action(MARINA, CargoAir,          -1,             ActionParams.CargoAir,          0x23,           0,                              0x8014DA00,                     0x800D9160,                         0x8014DA30)
    Character.add_new_action(MARINA, CargoLanding,      -1,             ActionParams.CargoLanding,      0x23,           0x8014DC50,                     0,                              0x800D8BB4,                         0x8014D478)
    Character.add_new_action(MARINA, CargoDamage,       -1,             ActionParams.CargoDamage,       0x23,           0x8014E050,                     0,                              0x801407A8,                         0x800DEDF0)
    Character.add_new_action(MARINA, CargoThrow,        -1,             ActionParams.CargoThrow,        0x23,           0x8014DD00,                     0,                              0x800D8BB4,                         0x8014DECC)
    Character.add_new_action(MARINA, CargoThrowAir,     -1,             ActionParams.CargoThrowAir,     0x23,           0x8014DD00,                     0,                              0x800D90E0,                         0x8014DEF0)
    Character.add_new_action(MARINA, CargoItemThrowF,   -1,             ActionParams.CargoItemThrowF,   0x23,           0x8014634C,                     0,                              0x80146618,                         0x800DEDF0)
    Character.add_new_action(MARINA, CargoItemThrowB,   -1,             ActionParams.CargoItemThrowB,   0x23,           0x8014634C,                     0,                              0x80146618,                         0x800DEDF0)
    Character.add_new_action(MARINA, CargoItemThrowSF,  -1,             ActionParams.CargoItemThrowSF,  0x23,           0x8014634C,                     0,                              0x80146618,                         0x800DEDF0)
    Character.add_new_action(MARINA, CargoItemThrowSB,  -1,             ActionParams.CargoItemThrowSB,  0x23,           0x8014634C,                     0,                              0x80146618,                         0x800DEDF0)
    Character.add_new_action(MARINA, CargoJump,         -1,             ActionParams.CargoJump,         0x23,           MarinaCargo.jump_main_,         0x8014DA00,                     0x800D9160,                         0x8014DA30)
    Character.add_new_action(MARINA, CargoShake,        -1,             ActionParams.CargoShake,        0x23,           MarinaCargo.shake_main_,        0,                              0x800D8BB4,                         0x8014D478)
    Character.add_new_action(MARINA, USPG,              -1,             ActionParams.USPG,              0x11,           MarinaUSP.main_,                MarinaUSP.change_direction_,    MarinaUSP.physics_,                 MarinaUSP.collision_)
    Character.add_new_action(MARINA, USPA,              -1,             ActionParams.USPA,              0x11,           MarinaUSP.main_,                MarinaUSP.change_direction_,    MarinaUSP.physics_,                 MarinaUSP.collision_)
    Character.add_new_action(MARINA, DSPG_Begin,        -1,             ActionParams.DSPG_Begin,        0x1E,           MarinaDSP.ground_begin_main_,   0,                              0x800D8BB4,                         MarinaDSP.ground_collision_)
    Character.add_new_action(MARINA, DSPG_Wait,         -1,             ActionParams.DSPG_Wait,         0x1E,           MarinaDSP.ground_wait_main_,    0,                              0x800D8BB4,                         MarinaDSP.ground_collision_)
    Character.add_new_action(MARINA, DSPG_Absorb,       -1,             ActionParams.DSPG_Absorb,       0x1E,           MarinaDSP.ground_absorb_main_,  0,                              0x800D8BB4,                         MarinaDSP.ground_collision_)
    Character.add_new_action(MARINA, DSPG_End,          -1,             ActionParams.DSPG_End,          0x1E,           MarinaDSP.ground_end_main_,     0,                              0x800D8BB4,                         MarinaDSP.ground_collision_)
    Character.add_new_action(MARINA, DSPG_Pull,         -1,             ActionParams.DSPG_Pull,         0x1E,           MarinaDSP.pull_main_,           0,                              0x800D8BB4,                         MarinaDSP.ground_collision_)
    Character.add_new_action(MARINA, DSPG_Pull_Fail,    -1,             ActionParams.DSPG_Pull_Fail,    0x1E,           0x800D94C4,                     0,                              0x800D8BB4,                         MarinaDSP.ground_collision_)
    Character.add_new_action(MARINA, DSPG_Stow,         -1,             ActionParams.DSPG_Stow,         0x1E,           MarinaDSP.stow_main_,           0,                              0x800D8BB4,                         MarinaDSP.ground_collision_)
    Character.add_new_action(MARINA, DSPA_Begin,        -1,             ActionParams.DSPA_Begin,        0x1E,           MarinaDSP.air_begin_main_,      0,                              0x800D90E0,                         MarinaDSP.air_collision_)
    Character.add_new_action(MARINA, DSPA_Wait,         -1,             ActionParams.DSPA_Wait,         0x1E,           MarinaDSP.air_wait_main_,       0,                              0x800D90E0,                         MarinaDSP.air_collision_)
    Character.add_new_action(MARINA, DSPA_Absorb,       -1,             ActionParams.DSPA_Absorb,       0x1E,           MarinaDSP.air_absorb_main_,     0,                              0x800D90E0,                         MarinaDSP.air_collision_)
    Character.add_new_action(MARINA, DSPA_End,          -1,             ActionParams.DSPA_End,          0x1E,           MarinaDSP.air_end_main_,        0,                              0x800D90E0,                         MarinaDSP.air_collision_)
    Character.add_new_action(MARINA, DSPA_Pull,         -1,             ActionParams.DSPA_Pull,         0x1E,           MarinaDSP.pull_main_,           0,                              0x800D90E0,                         MarinaDSP.air_collision_)
    Character.add_new_action(MARINA, DSPA_Pull_Fail,    -1,             ActionParams.DSPA_Pull_Fail,    0x1E,           0x800D94E8,                     0,                              0x800D90E0,                         MarinaDSP.air_collision_)
    Character.add_new_action(MARINA, DSPA_Stow,         -1,             ActionParams.DSPA_Stow,         0x1E,           MarinaDSP.stow_main_,           0,                              0x800D90E0,                         MarinaDSP.air_collision_)

    // Modify Menu Action Parameters              // Action     // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(MARINA, 0x0,          File.MARINA_IDLE,           IDLE,                       -1)
    Character.edit_menu_action_parameters(MARINA, 0x1,          File.MARINA_VICTORY_1,      CSS,                        -1)
    Character.edit_menu_action_parameters(MARINA, 0x2,          File.MARINA_VICTORY_2,      VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(MARINA, 0x3,          File.MARINA_VICTORY_3,      VICTORY,                    -1)
    Character.edit_menu_action_parameters(MARINA, 0x4,          File.MARINA_VICTORY_1,      CSS,                        -1)
    Character.edit_menu_action_parameters(MARINA, 0x5,          File.MARINA_CLAP,           CLAP,                       -1)
    Character.edit_menu_action_parameters(MARINA, 0x9,          File.MARINA_CONTINUE_FALL,  -1,                         -1)
    Character.edit_menu_action_parameters(MARINA, 0xA,          File.MARINA_CONTINUE_UP,    -1,                         -1)
    Character.edit_menu_action_parameters(MARINA, 0xD,          File.MARINA_1P_POSE,        ONEP,                       -1)
    Character.edit_menu_action_parameters(MARINA, 0xE,          File.MARINA_CPU_POSE,        ONEP,                       -1)

    Character.table_patch_start(air_nsp, Character.id.MARINA, 0x4)
    dw      MarinaNSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_nsp, Character.id.MARINA, 0x4)
    dw      MarinaNSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_usp, Character.id.MARINA, 0x4)
    dw      MarinaUSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_usp, Character.id.MARINA, 0x4)
    dw      MarinaUSP.ground_initial_
    OS.patch_end()
    Character.table_patch_start(air_dsp, Character.id.MARINA, 0x4)
    dw      MarinaDSP.air_initial_
    OS.patch_end()
    Character.table_patch_start(ground_dsp, Character.id.MARINA, 0x4)
    dw      MarinaDSP.ground_initial_
    OS.patch_end()


    Character.table_patch_start(jab_3, Character.id.MARINA, 0x4)
    dw      Character.jab_3.DISABLED        // disable jab 3
    OS.patch_end()
    Character.table_patch_start(rapid_jab_begin_action, Character.id.MARINA, 0x4)
    dw      0x8014F13C                      // copied from FOX
    OS.patch_end()
    Character.table_patch_start(rapid_jab_loop_action, Character.id.MARINA, 0x4)
    dw      0x8014F3F4                      // copied from FOX
    OS.patch_end()
    Character.table_patch_start(rapid_jab_ending_action, Character.id.MARINA, 0x4)
    dw      0x8014F490                      // copied from FOX
    OS.patch_end()
    Character.table_patch_start(rapid_jab_unknown, Character.id.MARINA, 0x4)
    dw      0x8014F5B0                      // copied from FOX
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.MARINA, 0x4)
    float32 0.63
    OS.patch_end()

    // Allows Marina to use her entry which is similar to Link
    Character.table_patch_start(entry_action, Character.id.MARINA, 0x8)
    dw 0xDF, 0xE0
    OS.patch_end()
    Character.table_patch_start(entry_script, Character.id.MARINA, 0x4)
    dw marina_entry_routine_
    OS.patch_end()

    // Patches for full charge Neutral B effect.
    Character.table_patch_start(gfx_routine_end, Character.id.MARINA, 0x4)
    dw      charge_gfx_routine_
    OS.patch_end()
    Character.table_patch_start(initial_script, Character.id.MARINA, 0x4)
    dw      0x800D7DEC                      // use samus jump
    OS.patch_end()

    // Remove grounded script.
    Character.table_patch_start(grounded_script, Character.id.MARINA, 0x4)
    dw Character.grounded_script.DISABLED   // skips grounded script
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.MARINA, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.MARINA, 0xC)
    dh 0x1F
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.MARINA, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.MARINA, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.MARINA_NSP
    OS.patch_end()

    // Edit cpu attack behaviours, original table is from Falcon
    // edit_attack_behavior(table, attack, override,	start_hb, end_hb, 	min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,  	-1,  4,   		0,  -132, 276, -90, 329)	// updated 11-24-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  5,   		0,  0, 100, 100, 330)       // updated 11-26-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  5,   		0,  0, 100, 100, 330)       // updated 11-26-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  8,   		0,  -320, 320, -100, 300)	// updated 11-27-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  7,   		0,  -50, 499, -100, 325)	// Updated 11-26-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, BAIR,   -1,  11,  		0,  -40, 280, 100, 300)	    // updated 11-24-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  12,  		0,  250, 1170, 50, 590)	// updated 11-27-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  8,   		0,  45, 560, -45, 270)	    // Copied Mario coords. updated 11-24-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,   		0,  50, 240, 65, 355.0)	    // updated 11-24-2022, copied Fox's
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  3,   		0,  25, 495, 280, 510)	    // updated 11-26-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  5,   		0,  -192, 201, -30, 280)	// updated 11-24-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  20,  		0,  200, 900, 100, 250)	    // updated 11-24-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  20,  		0,  200, 900, 100, 250)	    // updated 11-24-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  6,   		0,  50, 200, 128, 500)	    // updated 11-24-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  10,  		0,  89, 475, 242, 1000)     // updated 11-26-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  10,  		0,  89, 475, 242, 1700)	    // updated 11-26-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  12,  		0,  -174, 243, 177, 940)	// updated 11-26-2022
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,   		0,  -274, 326, 196, 717)	// updated 11-26-2022

    // Set default costumes
    Character.set_default_costumes(Character.id.MARINA, 0, 2, 4, 5, 1, 2, 3)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(MARINA, RED, MAGENTA, BLUE, GREEN, PURPLE, YELLOW, NA, NA)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.MARINA, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // @ Description
    // Jump table patch which enables Marina's charged down b effect when another gfx routine ends, or upon action change.
    scope charge_gfx_routine_: {
        lw      t9, 0x0ADC(a3)              // t9 = charge level
        lli     at, MarinaDSP.MAX_CHARGE    // at = MAX_CHARGE
        lw      a0, 0x0020(sp)              // a0 = player object
        bne     t9, at, _end                // skip if charge level != MAX_CHARGE (full)
        lli     a1, GFXRoutine.id.MARINA_CHARGE // a1 = MARINA_CHARGE id

        // if the down special is full charged
        or      a2, r0, r0                  // a2 = 0
        jal     0x800E9814                  // begin gfx routine
        sw      a3, 0x001C(sp)              // store a3

        _end:
        j       0x800E9A60                  // return
        lw      a3, 0x001C(sp)              // load a3
    }

    // @ Description
    // Entry routine for Marina. Sets the correct facing direction and then jumps to Link's entry routine.
    scope marina_entry_routine_: {
        lw      a1, 0x0B1C(s0)              // a1 = direction
        addiu   at, r0,-0x0001              // at = -1 (left)
        beql    a1, at, _end                // branch if direction = left...
        sw      v1, 0x0B24(s0)              // ...and enable reversed direction flag

        _end:
        j       0x8013DCCC                  // jump to Link's entry routine to load entry object
        nop
    }

    // @ Description
    // Patch which loads alternate animations (ThrownMarina) for CFalcon/DK when Marina grabs them.
    scope thrown_marina_patch_: {
        OS.patch_start(0x62D68, 0x800E7568)
        jal     thrown_marina_patch_
        nop
        OS.patch_end()

        bgezl   t8, _continue               // original line 1
        lw      a0, 0x0000(t1)              // original line 2 (a0 = animation id)

        jr      ra                          // return if branch wasn't taken
        nop

        _continue:
        lw      t7, 0x0024(s1)              // t7 = action id
        lli     at, Action.ThrownDK         // at = ThrownDK id
        bne     t7, at, _end                // end if action id != ThrownDK
        lw      t7, 0x0844(s1)              // t7 = player.entity_captured_by
        lw      t7, 0x0084(t7)              // t7 = grabbing player struct
        lw      t7, 0x0008(t7)              // t7 = grabbing player character id
        lli     at, Character.id.MARINA     // at = id.MARINA
        bne     t7, at, _end                // end if grabbing character != MARINA
        lw      t7, 0x0008(s1)              // t7 = character id

        // if the action is ThrownDK and the grabbing character is MARINA
        lli     at, Character.id.DONKEY     // at = id.DONKEY
        beql    t7, at, _end                // end if character = DONKEY...
        lli     a0, File.DK_THROWN_MARINA   // ...override animation with DK_THROWN_MARINA
        lli     at, Character.id.NDONKEY    // at = id.NDONKEY
        beql    t7, at, _end                // end if character = NDONKEY...
        lli     a0, File.DK_THROWN_MARINA   // ...override animation with DK_THROWN_MARINA
        lli     at, Character.id.GDONKEY    // at = id.GDONKEY
        beql    t7, at, _end                // end if character = GDONKEY...
        lli     a0, File.DK_THROWN_MARINA   // ...override animation with DK_THROWN_MARINA
        lli     at, Character.id.JDK        // at = id.JDK
        beql    t7, at, _end                // end if character = JDK...
        lli     a0, File.DK_THROWN_MARINA   // ...override animation with DK_THROWN_MARINA
        lli     at, Character.id.CAPTAIN    // at = id.CAPTAIN
        beql    t7, at, _end                // end if character = CAPTAIN...
        lli     a0, File.FALCON_THROWN_MARINA // ...override animation with FALCON_THROWN_MARINA
        lli     at, Character.id.NCAPTAIN   // at = id.NCAPTAIN
        beql    t7, at, _end                // end if character = NCAPTAIN...
        lli     a0, File.FALCON_THROWN_MARINA // ...override animation with FALCON_THROWN_MARINA
        lli     at, Character.id.GND        // at = id.GND
        beql    t7, at, _end                // end if character = GND...
        lli     a0, File.FALCON_THROWN_MARINA // ...override animation with FALCON_THROWN_MARINA
        lli     at, Character.id.JFALCON    // at = id.JFALCON
        beql    t7, at, _end                // end if character = CAPTAIN...
        lli     a0, File.FALCON_THROWN_MARINA // ...override animation with FALCON_THROWN_MARINA

        _end:
        j       0x800E7588                  // jump to original branch location
        nop
    }

    // @ Description
    // Patch which handles the decaying jump height for Marina's multiple jumps.
    scope jump_height_patch_: {
    OS.patch_start(0xBA898, 0x8013FE58)
        j       jump_height_patch_
        lwc1    f16, 0x003C(t0)             // original line 2
        _return:
        OS.patch_end()

        lw      t6, 0x0008(s0)              // t6 = character id
        lli     at, Character.id.MARINA     // at = id.MARINA
        beq     at, t6, _marina             // branch if character = MARINA...
        lli     at, Character.id.NMARINA    // at = id.NMARINA
        bne     at, t6, _end                // branch if character != NMARINA...
        lbu     t6, 0x0148(s0)              // t6 = jumps used

		_marina:
        // if we're here then the character is MARINA, so apply alternate base jump height
        lbu     t6, 0x0148(s0)              // t6 = jumps used
        li      at, jump_height_table       // at = jump_height_table
        add     at, at, t6                  // at = jump_height_table + jumps used
        lbu     t3, 0x0000(at)              // t3 = base height for next jump

        _end:
        j       _return                     // return
        mtc1    t3, f8                      // original line 1
    }

    // @ Description
    // Patch which prevents marina from cancelling double jump into itself until a flag is set.
    scope jump_timing_patch_: {
    OS.patch_start(0xBAD50, 0x80140310)
        j       jump_timing_patch_
        lw      a0, 0x0020(sp)             // original line 2
        _return:
        OS.patch_end()

        lw      t6, 0x0008(a2)              // t6 = character id
        lli     at, Character.id.MARINA     // at = id.MARINA
        beq     at, t6, _marina             // branch if character = MARINA...
        lli     at, Character.id.NMARINA    // at = id.NMARINA
        bne     at, t6, _end                // branch if character != NMARINA...
        nop

        _marina:
        // if we're here then the character is MARINA, so check if special restrictions should be applied
        lw      t6, 0x0024(a2)              // t6 = current action
        lli     at, Action.JumpAerialF      // at = JumpAerialF
        beq     at, t6, _check_flag         // branch if current action = JumpAerialF
        lli     at, Action.JumpAerialB      // at = id.JumpAerialB
        bnel    at, t6, _end                // end if current action != JumpAerialB...
        sw      r0, 0x0180(a2)              // ...set temp variable 2 to FALSE


        _check_flag:
        // if the character is MARINA and she is currently doing a double jump
        lw      t6, 0x0180(a2)              // t6 = temp variable 2
        bnezl   t6, _end                    // end if temp variable 2 != FALSE...
        sw      r0, 0x0180(a2)              // ...set temp variable 2 to FALSE

        // if we're here then MARINA has attempted to start a consecutive double jump too soon, so disallow it
        j       0x80140324                  // end action checks
        or      v0, r0, r0                  // return FALSE (no action change occured)

        _end:
        jal     0x8013FD74                  // original line 1
        nop
        j       _return                     // return
        nop
    }

    jump_height_table:
    db  0   // jump 1
    db  80  // jump 2
    db  70  // jump 3
    db  60  // jump 4
    db  50  // jump 5
    db  40  // jump 6
    OS.align(4)
}
