// Falco.asm

// This file contains file inclusions, action edits, and assembly for Falco.

scope Falco {
    // Insert Moveset files
    insert RUN,"moveset/RUN.bin"; Moveset.GO_TO(RUN)            // loops
    insert DASH,"moveset/DASH.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert FROLL, "moveset/FROLL.bin"
    insert BROLL, "moveset/BROLL.bin"
    insert TECH_STAND, "moveset/TECH_STAND.bin"
    insert TECH_ROLL, "moveset/TECH_FROLL.bin"
    insert FTHROWDATA, "moveset/FTHROWDATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROWDATA); insert "moveset/FTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert TEETERING, "moveset/TEETERING.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)         // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)   // loops
    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT_HI,"moveset/FORWARD_TILT_HIGH.bin"
    insert FTILT_M_HI,"moveset/FORWARD_TILT_MID_HIGH.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert FTILT_M_LO,"moveset/FORWARD_TILT_MID_LOW.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NSP_GROUND,"moveset/NEUTRAL_SPECIAL_GROUND.bin"
    insert NSP_AIR,"moveset/NEUTRAL_SPECIAL_AIR.bin"
    insert USP_GROUND_MOVE,"moveset/UP_SPECIAL_GROUND_MOVE.bin" // no end command, transitions into USP_LOOP
    insert USP_LOOP,"moveset/UP_SPECIAL_LOOP.bin"; Moveset.GO_TO(USP_LOOP)
    insert USP_AIR_MOVE,"moveset/UP_SPECIAL_AIR_MOVE.bin" ; Moveset.GO_TO(USP_LOOP)
    insert DSP_GROUND_START,"moveset/DOWN_SPECIAL_GROUND_START.bin"
    insert DSP_AIR_START,"moveset/DOWN_SPECIAL_AIR_START.bin"
    insert VICTORY_POSE_1,"moveset/VICTORY_POSE_1.bin"
    insert VICTORY_POSE_2,"moveset/VICTORY_POSE_2.bin"
    insert VICTORY_POSE_3,"moveset/VICTORY_POSE_3.bin"
    insert CLAP, "moveset/CLAP.bin"
    insert POSE_1P, "moveset/POSE_1P.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(FALCO, Action.Run,              -1,                        RUN,                        -1)
    Character.edit_action_parameters(FALCO, Action.Dash,             -1,                        DASH,                       -1)
    Character.edit_action_parameters(FALCO, Action.JumpAerialF,      -1,                        JUMP2,                      -1)
    Character.edit_action_parameters(FALCO, Action.JumpAerialB,      -1,                        JUMP2,                      -1)
    Character.edit_action_parameters(FALCO, Action.Grab,             -1,                        GRAB,                       -1)
    Character.edit_action_parameters(FALCO, Action.ThrowF,           -1,                        FTHROW,                     -1)
    Character.edit_action_parameters(FALCO, Action.ThrowB,           -1,                        BTHROW,                     -1)
    Character.edit_action_parameters(FALCO, Action.RollF,            -1,                        FROLL,                      -1)
    Character.edit_action_parameters(FALCO, Action.RollB,            -1,                        BROLL,                      -1)
    Character.edit_action_parameters(FALCO, Action.TechF,            -1,                        TECH_ROLL,                  -1)
    Character.edit_action_parameters(FALCO, Action.TechB,            -1,                        TECH_ROLL,                  -1)
    Character.edit_action_parameters(FALCO, Action.Tech,             -1,                        TECH_STAND,                 -1)
    Character.edit_action_parameters(FALCO, Action.Teeter,           -1,                        TEETERING,                  -1)
    Character.edit_action_parameters(FALCO, Action.ShieldBreak,      -1,                        SHIELD_BREAK,               -1)
    Character.edit_action_parameters(FALCO, Action.Stun,             -1,                        STUN,                       -1)
    Character.edit_action_parameters(FALCO, Action.Sleep,            -1,                        ASLEEP,                     -1)
    Character.edit_action_parameters(FALCO, Action.Taunt,           File.FALCO_TAUNT,           TAUNT,                      -1)
    Character.edit_action_parameters(FALCO, Action.Jab1,            -1,                         JAB_1,                      -1)
    Character.edit_action_parameters(FALCO, Action.Jab2,            -1,                         JAB_2,                      -1)
    Character.edit_action_parameters(FALCO, Action.DashAttack,      -1,                         DASH_ATTACK,                -1)
    Character.edit_action_parameters(FALCO, Action.FTiltHigh,       -1,                         FTILT_HI,                   -1)
    Character.edit_action_parameters(FALCO, Action.FTiltMidHigh,    -1,                         FTILT_M_HI,                 -1)
    Character.edit_action_parameters(FALCO, Action.FTilt,           -1,                         FTILT,                      -1)
    Character.edit_action_parameters(FALCO, Action.FTiltMidLow,     -1,                         FTILT_M_LO,                 -1)
    Character.edit_action_parameters(FALCO, Action.UTilt,           File.FALCO_UTILT,           UTILT,                      -1)
    Character.edit_action_parameters(FALCO, Action.DTilt,           -1,                         DTILT,                      -1)
    Character.edit_action_parameters(FALCO, Action.FSmash,          File.FALCO_FSMASH,          FSMASH,                     -1)
    Character.edit_action_parameters(FALCO, Action.USmash,          -1,                         USMASH,                     -1)
    Character.edit_action_parameters(FALCO, Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(FALCO, Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(FALCO, Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(FALCO, 0xE1,                   0x2E9,                      NSP_GROUND,                 -1)
    Character.edit_action_parameters(FALCO, 0xE2,                   File.FALCO_NSP_AIR,         NSP_AIR,                    -1)
    Character.edit_action_parameters(FALCO, 0xE7,                   -1,                         USP_GROUND_MOVE,            -1)
    Character.edit_action_parameters(FALCO, 0xE8,                   -1,                         USP_AIR_MOVE,               -1)
    Character.edit_action_parameters(FALCO, 0xEC,                   -1,                         DSP_GROUND_START,           -1)
    Character.edit_action_parameters(FALCO, 0xF1,                   -1,                         DSP_AIR_START,              -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(FALCO, 0xE1,              -1,             0x800D94C4,                 Phantasm.ground_subroutine_,    -1,                             -1)
    Character.edit_action(FALCO, 0xE2,              -1,             0x8015C750,                 Phantasm.air_subroutine_,       Phantasm.air_physics_,          Phantasm.air_collision_)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(FALCO, 0x1,               -1,                         VICTORY_POSE_1,             -1)
    Character.edit_menu_action_parameters(FALCO, 0x2,               File.FALCO_SELECT,          VICTORY_POSE_2,             -1)
    Character.edit_menu_action_parameters(FALCO, 0x3,               -1,                         VICTORY_POSE_3,             -1)
    Character.edit_menu_action_parameters(FALCO, 0x4,               File.FALCO_SELECT,          VICTORY_POSE_2,             -1)
    Character.edit_menu_action_parameters(FALCO, 0x5,               File.FALCO_CLAP,            CLAP,                       -1)
    Character.edit_menu_action_parameters(FALCO, 0xD,               File.FALCO_POSE_1P,         POSE_1P,                    -1)
    Character.edit_menu_action_parameters(FALCO, 0xE,               File.FALCO_1P_CPU_POSE,         POSE_1P,                    -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.FALCO, 0x4)
    float32 1.2
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.FALCO, 0x2)
    dh  0x02C8
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.FALCO, 0xC)
    dh 0x12
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.FALCO, 0, 1, 4, 5, 1, 2, 3)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(FALCO, WHITE, RED, BLUE, GREEN, BLACK, ORANGE, NA, NA)

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.FALCO, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()
	
	// Set CPU SD prevent routine
    Character.table_patch_start(ai_attack_prevent, Character.id.FALCO, 0x4)
    dw    	AI.PREVENT_ATTACK.ROUTINE.FALCO_NSP
    OS.patch_end()
	
	// Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.FALCO, 0x4)
    dw    	AI.LONG_RANGE.ROUTINE.NONE
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  14,   22,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,   -1,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  -1,   -1,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  17,   20,  50, 700, 35, 200)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  17,   20,  50, 700, 35, 200)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  43,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  43,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  -1,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  -1,   -1,  -1, -1, -1, -1)

    // @ Description
    // Falco's extra actions
    scope Action {
        constant JabLoopStart(0x0DC)
        constant JabLoop(0x0DD)
        constant JabLoopEnd(0x0DE)
        constant Appear1(0x0DF)
        constant Appear2(0x0E0)
        constant Phantasm(0x0E1)
        constant PhantasmAir(0x0E2)
        constant FireBirdStart(0x0E3)
        constant FireBirdStartAir(0x0E4)
        constant ReadyingFireBird(0x0E5)
        constant ReadyingFireBirdAir(0x0E6)
        constant FireBird(0x0E7)
        constant FireBirdAir(0x0E8)
        constant FireBirdEnd(0x0E9)
        constant FireBirdEndAir(0x0EA)
        constant FireBirdBounce(0x0EB)
        constant ReflectorStart(0x0EC)
        constant Reflecting(0x0ED)
        constant ReflectorEnd(0x0EE)
        constant ReflectorLoop(0x0EF)
        constant ReflectorSwitchDirection(0x0F0)
        constant ReflectorStartAir(0x0F1)
        // constant ?(0x0F2)
        constant ReflectorEndAir(0x0F3)
        constant ReflectorAir(0x0F4)
        constant ReflectorSwitchDirectionAir(0x0F5)

        // strings!
        //string_0x0DC:; String.insert("JabLoopStart")
        //string_0x0DD:; String.insert("JabLoop")
        //string_0x0DE:; String.insert("JabLoopEnd")
        //string_0x0DF:; String.insert("Appear1")
        //string_0x0E0:; String.insert("Appear2")
        string_0x0E1:; String.insert("Phantasm")
        string_0x0E2:; String.insert("PhantasmAir")
        string_0x0E3:; String.insert("FireBirdStart")
        string_0x0E4:; String.insert("FireBirdStartAir")
        string_0x0E5:; String.insert("ReadyingFireBird")
        string_0x0E6:; String.insert("ReadyingFireBirdAir")
        string_0x0E7:; String.insert("FireBird")
        string_0x0E8:; String.insert("FireBirdAir")
        string_0x0E9:; String.insert("FireBirdEnd")
        string_0x0EA:; String.insert("FireBirdEndAir")
        string_0x0EB:; String.insert("FireBirdBounce")
        //string_0x0EC:; String.insert("ReflectorStart")
        //string_0x0ED:; String.insert("Reflecting")
        //string_0x0EE:; String.insert("ReflectorEnd")
        //string_0x0EF:; String.insert("ReflectorLoop")
        //string_0x0F0:; String.insert("ReflectorSwitchDirection")
        //string_0x0F1:; String.insert("ReflectorStartAir")
        //string_0x0F2:; String.insert("ReflectingAir")
        //string_0x0F3:; String.insert("ReflectorEndAir")
        //string_0x0F4:; String.insert("ReflectorAir")
        //string_0x0F5:; String.insert("ReflectorSwitchDirectionAir")

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
        dw Action.FOX.string_0x0EC
        dw Action.FOX.string_0x0ED
        dw Action.FOX.string_0x0EE
        dw Action.FOX.string_0x0EF
        dw Action.FOX.string_0x0F0
        dw Action.FOX.string_0x0F1
        dw Action.FOX.string_0x0F2
        dw Action.FOX.string_0x0F3
        dw Action.FOX.string_0x0F4
        dw Action.FOX.string_0x0F5
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.FALCO, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // @ Description
    // Replaces a small subroutine which usually sets the up special delay for Fox, extends to
    // include Falco.
    scope up_special_delay_: {
        OS.patch_start(0xD6A38, 0x8015BFF8)
        jal     up_special_delay_
        OS.patch_end()
        OS.patch_start(0xD6A7C, 0x8015C03C)
        jal     up_special_delay_
        OS.patch_end()

        addiu   sp, sp,-0x0008              // allocate stack space
        sw      t0, 0x0004(sp)              // store t0
        lw      v0, 0x0084(a0)              // v0 = player struct, (original line 1 )
        lw      t6, 0x0008(v0)              // t6 = character id
        ori     t0, r0, Character.id.FALCO  // t0 = FALCO
        beq     t0, t6, _end                // branch if chracter = FALCO
        addiu   t6, r0, 0x0016              // up special delay = 0x16

        addiu   t6, r0, 0x0023              // up special delay = 0x23 (original line 2)
        _end:
        lw      t0, 0x0004(sp)              // load t0
        addiu   sp, sp, 0x0008              // deallocate stack space
        jr      ra                          // return (original line 3)
        sw      t6, 0x0B18(v0)              // store up special delay (original line 4)
    }

    // @ Description
    // Loads a unique up special velocity value for Falco.
    scope up_special_velocity_1_: {
        OS.patch_start(0xD6FF8, 0x8015C5B8)
        j       up_special_velocity_1_
        nop
        _return:
        OS.patch_end()

        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.FALCO  // t1 = FALCO
        beq     t0, t1, _end                // branch if character = FALCO
        lui     at, 0x42C4                  // up special velocity = 0x42C40000

        lui     at, 0x42E6                  // up special velocity = 0x42E60000 (original line 1)
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        mtc1    t2, f10                     // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Loads a unique up special velocity value for Falco.
    scope up_special_velocity_2_: {
        OS.patch_start(0xD7130, 0x8015C6F0)
        j       up_special_velocity_2_
        nop
        _return:
        OS.patch_end()

        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.FALCO  // t1 = FALCO
        beq     t0, t1, _end                // branch if character = FALCO
        lui     at, 0x42C4                  // up special velocity = 0x42C40000

        lui     at, 0x42E6                  // up special velocity = 0x42E60000 (original line 1)
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        mtc1    at, f10                     // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Loads a unique up special velocity value for Falco.
    scope up_special_velocity_3_: {
        OS.patch_start(0xD7154, 0x8015C714)
        j       up_special_velocity_3_
        nop
        _return:
        OS.patch_end()

        // s0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(s0)              // t0 = character id
        ori     t1, r0, Character.id.FALCO  // t1 = FALCO
        beq     t0, t1, _end                // branch if character = FALCO
        lui     at, 0x42C4                  // up special velocity = 0x42C40000

        lui     at, 0x42E6                  // up special velocity = 0x42E60000 (original line 1)
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        mtc1    at, f8                      // original line 2
        j       _return                     // return
        nop
    }
}
