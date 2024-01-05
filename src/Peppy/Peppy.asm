// Peppy.asm

// This file contains file inclusions, action edits, and assembly for Peppy.

scope Peppy {

    OS.align(4)
    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // @ Description
    // Peppy's extra actions
    scope Action {
        constant JabLoopStart(0x0DC)
        constant JabLoop(0x0DD)
        constant JabLoopEnd(0x0DE)
        constant Appear1(0x0DF)
        constant Appear2(0x0E0)
        constant NSPG_BEGIN(0xE1)
        constant NSPG_CHARGE(0xE2)
        constant FireHareStart(0x0E3)
        constant FireHareStartAir(0x0E4)
        constant ReadyingFireHare(0x0E5)
        constant ReadyingFireHareAir(0x0E6)
        constant FireHare(0x0E7)
        constant FireHareAir(0x0E8)
        constant FireHareEnd(0x0E9)
        constant FireHareEndAir(0x0EA)
        constant FireHareBounce(0x0EB)
        constant ReflectorStart(0x0EC)
        constant NSPG_SHOOT(0xED)
        constant NSPA_BEGIN(0xEE)
        constant ReflectorLoop(0x0EF)
        constant ReflectorSwitchDirection(0x0F0)
        constant ReflectorStartAir(0x0F1)
        constant NSPA_CHARGE(0xF2)
        constant NSPA_SHOOT(0xF3)
        constant ReflectorAir(0x0F4)
        constant ReflectorSwitchDirectionAir(0x0F5)

        // strings!
        //string_0x0DC:; String.insert("JabLoopStart")
        //string_0x0DD:; String.insert("JabLoop")
        //string_0x0DE:; String.insert("JabLoopEnd")
        //string_0x0DF:; String.insert("Appear1")
        //string_0x0E0:; String.insert("Appear2")
        string_0x0E1:; String.insert("RevolverBeginGround")
        string_0x0E2:; String.insert("RevolverChargeGround")
        string_0x0E3:; String.insert("FireHareStart")
        string_0x0E4:; String.insert("FireHareStartAir")
        string_0x0E5:; String.insert("ReadyingFireHare")
        string_0x0E6:; String.insert("ReadyingFireHareAir")
        string_0x0E7:; String.insert("FireHare")
        string_0x0E8:; String.insert("FireHareAir")
        string_0x0E9:; String.insert("FireHareEnd")
        string_0x0EA:; String.insert("FireHareEndAir")
        string_0x0EB:; String.insert("FireHareBounce")
        string_0x0EC:; String.insert("FlashBombThrow")
        string_0x0ED:; String.insert("RevolverShootGround")
        string_0x0EE:; String.insert("RevolverBeginAir")
        string_0x0EF:; String.insert("FlashBombDetonate")
        //string_0x0F0:; String.insert("FlashBombDetonateAir")
        string_0x0F1:; String.insert("FlashBombThrowAir")
        string_0x0F2:; String.insert("RevolverChargeAir")
        string_0x0F3:; String.insert("RevolverShootAir")
        //string_0x0F4:; String.insert("ReflectorAir")
        string_0x0F5:; String.insert("FlashBombDetonateAir")

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
        dw Action.FOX.string_0x0F0
        dw string_0x0F1
        dw string_0x0F2
        dw string_0x0F3
        dw Action.FOX.string_0x0F4
        dw string_0x0F5
    }
    // Insert Moveset files
    insert USP_GROUND_MOVE,"moveset/UP_SPECIAL_GROUND_MOVE.bin" // no end command, transitions into USP_LOOP
    insert USP_LOOP,"moveset/UP_SPECIAL_LOOP.bin"; Moveset.GO_TO(USP_LOOP)
    insert USP_AIR_MOVE,"moveset/UP_SPECIAL_AIR_MOVE.bin" ; Moveset.GO_TO(USP_LOOP)
    insert NSP_BEGIN,"moveset/NSP_BEGIN.bin"
    NSP_CHARGE:
    Moveset.HIDE_ITEM();
    dw 0xA0880000, 0xC40C8007, 0xD0004000;
    NSP_CHARGE_LOOP:
    Moveset.WAIT(0x16); Moveset.SET_FLAG(0); dw 0x4400002C; Moveset.WAIT(9); Moveset.GO_TO(NSP_CHARGE_LOOP)
    insert NSP_SHOOT,"moveset/NSP_SHOOT.bin"

    USP_READY_ROUTINE:
    dw 0xC4000007; // ?
    dw 0xBC000003 // slope contour state feet
    dw 0x98607C00, 0x0000003C, 0, 0; // gfx
    dw 0xB1DC0000 // colour overlay
    dw 0x380000BA // play FGM
    Moveset.END();

    USP_READY:
    Moveset.CONCURRENT_STREAM(USP_READY_ROUTINE);
    Moveset.LOOP(5);
    dw 0x98005800, 0, 0, 0; // gfx
    Moveset.WAIT(0x0B);
    Moveset.END_LOOP();
    Moveset.END();

    insert DSP_DETONATE,"moveset/DSP_DETONATE.bin"
    insert DSP_GROUND,"moveset/DSP_GROUND.bin"

    insert FTHROWDATA, "moveset/FTHROWDATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROWDATA); insert "moveset/FTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"

    insert JUMP2,"moveset/JUMP2.bin" ;
    insert FROLL,"moveset/FROLL.bin" ;
    insert BROLL,"moveset/BROLL.bin" ;
    insert TECH_STAND, "moveset/TECH_STAND.bin"
    insert TECH_ROLL, "moveset/TECH_FROLL.bin"
    insert TEETERING,"moveset/TEETERING.bin"

    DASH_ATTACK_PEP:
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert UTILT,"moveset/UTILT.bin"
    insert DTILT,"moveset/DTILT.bin"
    insert NAIR,"moveset/NAIR.bin"
    insert FAIR,"moveset/FAIR.bin"
    insert BAIR,"moveset/BAIR.bin"
    insert UAIR,"moveset/UAIR.bin"
    insert DAIR,"moveset/DAIR.bin"

    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)                    // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)          // loops
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)                      // loops

    CSS:
    Moveset.WAIT(0x6A); Moveset.VOICE(0x4EB); Moveset.END();

    VICTORY_1:; insert "moveset/VICTORY_1.bin"

    VICTORY_2:
    dw 0xA0880000;
    Moveset.WAIT(0x10); Moveset.VOICE(0x4F0);
    Moveset.AFTER(0x55);
    dw 0xA08FFFFF;
    dw 0xA0800001;
    Moveset.END();

    TAUNT:
    Moveset.WAIT(0x0); Moveset.VOICE(0x4F7); dw 0;



    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(PEPPY, Action.Dash,            File.PEPPY_DASH,            -1,                         -1)
    Character.edit_action_parameters(PEPPY, Action.Run,             File.PEPPY_RUN,             -1,                         -1)
    Character.edit_action_parameters(PEPPY, Action.RunBrake,        File.PEPPY_RUN_BRAKE,       -1,                         -1)
    Character.edit_action_parameters(PEPPY, Action.TurnRun,         File.PEPPY_TURN_RUN,        -1,                         -1)

    Character.edit_action_parameters(PEPPY, Action.Grab,            -1,                         GRAB,                       -1)
    Character.edit_action_parameters(PEPPY, Action.ThrowF,          -1,                         FTHROW,                     -1)
    Character.edit_action_parameters(PEPPY, Action.ThrowB,          -1,                         BTHROW,                     -1)
    Character.edit_action_parameters(PEPPY, Action.Crouch,          File.WOLF_CROUCH,          -1,                          -1)
    Character.edit_action_parameters(PEPPY, Action.CrouchIdle,      File.WOLF_CROUCH_IDLE,     -1,                          -1)
    Character.edit_action_parameters(PEPPY, Action.CrouchEnd,       File.WOLF_CROUCH_END,      -1,                          -1)
    Character.edit_action_parameters(PEPPY, Action.JumpAerialF,     -1,                         JUMP2,                      -1)
    Character.edit_action_parameters(PEPPY, Action.JumpAerialB,     -1,                         JUMP2,                      -1)
    Character.edit_action_parameters(PEPPY, Action.Teeter,          -1,                         TEETERING,                  -1)
    Character.edit_action_parameters(PEPPY, Action.TeeterStart,     -1,                         0x80000000,                 -1)
    Character.edit_action_parameters(PEPPY, Action.RollF,           -1,                         FROLL,                      -1)
    Character.edit_action_parameters(PEPPY, Action.RollB,           -1,                         BROLL,                      -1)
    Character.edit_action_parameters(PEPPY, Action.TechF,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(PEPPY, Action.TechB,           -1,                         TECH_ROLL,                  -1)
    Character.edit_action_parameters(PEPPY, Action.Tech,            -1,                         TECH_STAND,                 -1)
    Character.edit_action_parameters(PEPPY, Action.ShieldBreak,     -1,                         SHIELD_BREAK,               -1)
    Character.edit_action_parameters(PEPPY, Action.Stun,            -1,                         STUN,                       -1)
    Character.edit_action_parameters(PEPPY, Action.Sleep,           -1,                         ASLEEP,                     -1)
    Character.edit_action_parameters(PEPPY, Action.Taunt,           File.PEPPY_TAUNT,           TAUNT,                      -1)
    Character.edit_action_parameters(PEPPY, Action.DashAttack,      File.PEPPY_DASH_ATTACK,     DASH_ATTACK,                -1)
    Character.edit_action_parameters(PEPPY, Action.UTilt,           File.PEPPY_UTILT,           UTILT,                      -1)
    Character.edit_action_parameters(PEPPY, Action.DTilt,           File.WOLF_DTILT,            DTILT,                      -1)
    Character.edit_action_parameters(PEPPY, Action.FSmash,          File.FALCO_FSMASH,          FSMASH,                     -1)
    Character.edit_action_parameters(PEPPY, Action.USmash,          -1,                         USMASH,                     -1)
    Character.edit_action_parameters(PEPPY, Action.AttackAirN,      -1,                         NAIR,                       -1)
    Character.edit_action_parameters(PEPPY, Action.AttackAirF,      File.PEPPY_FAIR,            FAIR,                       -1)
    Character.edit_action_parameters(PEPPY, Action.AttackAirB,      File.PEPPY_BAIR,            BAIR,                       -1)
    Character.edit_action_parameters(PEPPY, Action.AttackAirU,      File.PEPPY_UAIR,            UAIR,                       -1)
    Character.edit_action_parameters(PEPPY, Action.AttackAirD,      -1,                         DAIR,                       -1)


    Character.edit_action_parameters(PEPPY, Action.NSPG_BEGIN,      File.PEPPY_NSP_CHARGESTART, NSP_BEGIN,                   0)
    Character.edit_action_parameters(PEPPY, Action.NSPG_CHARGE,     File.PEPPY_NSP_CHARGELOOP,  NSP_CHARGE,                  0)
    Character.edit_action_parameters(PEPPY, Action.NSPG_SHOOT,      0x30B,                      NSP_SHOOT,                   0)
    Character.edit_action_parameters(PEPPY, Action.NSPA_BEGIN,      File.PEPPY_NSP_CHARGESTART_AIR, NSP_BEGIN,               0)
    Character.edit_action_parameters(PEPPY, Action.NSPA_CHARGE,     File.PEPPY_NSP_CHARGELOOP_AIR,  NSP_CHARGE,              0)
    Character.edit_action_parameters(PEPPY, Action.NSPA_SHOOT,      File.PEPPY_NSP_SHOOT_AIR,   NSP_SHOOT,                   0)
    Character.edit_action_parameters(PEPPY, Action.FOX.ReadyingFireFox,     -1,                 USP_READY,                  -1)
    Character.edit_action_parameters(PEPPY, Action.FOX.ReadyingFireFoxAir,  -1,                 USP_READY,                  -1)
    Character.edit_action_parameters(PEPPY, Action.FOX.FireFox,     File.PEPPY_BARREL_ROLL,     USP_GROUND_MOVE,             0)
    Character.edit_action_parameters(PEPPY, Action.FOX.FireFoxAir,  File.PEPPY_BARREL_ROLL,     USP_AIR_MOVE,                0)
    Character.edit_action_parameters(PEPPY, 0xEC,                   File.PEPPY_DSP_GROUND,      DSP_GROUND,                 -1)
    Character.edit_action_parameters(PEPPY, 0xEF,                   File.PEPPY_DSP_IGNITE_GROUND, DSP_DETONATE,     0x00000000)
    Character.edit_action_parameters(PEPPY, 0xF1,                   File.PEPPY_DSP_AIR,         DSP_GROUND,                 -1)
    Character.edit_action_parameters(PEPPY, 0xF5,                   File.PEPPY_DSP_IGNITE_AIR,  DSP_DETONATE,       0x00000000)

    // Modify Actions               // Action           // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    Character.edit_action(PEPPY,    Action.NSPG_BEGIN,  0x12,           PeppyNSP.begin_main_,       PeppyNSP.ground_begin_interrupt_, 0x800D8BB4,                   PeppyNSP.ground_begin_collision_)  //NSP_Ground_Begin
    Character.edit_action(PEPPY,    Action.NSPG_CHARGE, 0x12,           PeppyNSP.charge_main_,      PeppyNSP.ground_charge_interrupt_, 0x800D8BB4,                  PeppyNSP.ground_charge_collision_) //NSP_Ground_Charge
    Character.edit_action(PEPPY,    Action.NSPG_SHOOT,  0x12,           PeppyNSP.shoot_main_,       0,                              0x800D8BB4,                     PeppyNSP.ground_shoot_collision_)  //NSP_Ground_Shoot
    Character.edit_action(PEPPY,    Action.NSPA_BEGIN,  0x12,           PeppyNSP.begin_main_,       PeppyNSP.air_begin_interrupt_,  0x800D90E0,                     PeppyNSP.air_begin_collision_)     //NSP_Air_Begin
    Character.edit_action(PEPPY,    Action.NSPA_CHARGE, 0x12,           PeppyNSP.charge_main_,      PeppyNSP.air_charge_interrupt_, 0x800D90E0,                     PeppyNSP.air_charge_collision_)    //NSP_Air_Charge
    Character.edit_action(PEPPY,    Action.NSPA_SHOOT,  0x12,           PeppyNSP.shoot_main_,       0,                              0x800D90E0,                     PeppyNSP.air_shoot_collision_)
    Character.edit_action(PEPPY,   0xEC,                -1,             PeppyDSP.main,              0,                              0x800D8CCC,                     PeppyDSP.ground_collision)
    Character.edit_action(PEPPY,   0xEF,                -1,             PeppyDSP.detonate_main_ground, 0x00000000,                  0x800D8CCC,                     PeppyDSP.ground_collision_fail)
    Character.edit_action(PEPPY,   0xF1,                -1,             PeppyDSP.main,              0,                              0x800D90E0,                     PeppyDSP.air_collision)
    Character.edit_action(PEPPY,   0xF5,                -1,             PeppyDSP.detonate_main_air, 0x00000000,                     0x800D90E0,                     PeppyDSP.air_collision_fail)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(PEPPY, 0x1,               -1,                         VICTORY_2,                  -1)
    Character.edit_menu_action_parameters(PEPPY, 0x2,               File.PEPPY_CSS,             CSS,                        -1)
    Character.edit_menu_action_parameters(PEPPY, 0x3,               File.PEPPY_VICTORY_1,       VICTORY_1,                  -1)
    Character.edit_menu_action_parameters(PEPPY, 0x4,               File.PEPPY_CSS,             CSS,                        -1)
    Character.edit_menu_action_parameters(PEPPY, 0xD,               File.PEPPY_1P_POSE,         -1,                         -1)

    Character.table_patch_start(ground_nsp, Character.id.PEPPY, 0x4)
    dw      PeppyNSP.ground_begin_initial_
    OS.patch_end()

    Character.table_patch_start(air_nsp, Character.id.PEPPY, 0x4)
    dw      PeppyNSP.air_begin_initial_
    OS.patch_end()

    Character.table_patch_start(ground_dsp, Character.id.PEPPY, 0x4)
    dw      PeppyDSP.initial_
    OS.patch_end()

    Character.table_patch_start(air_dsp, Character.id.PEPPY, 0x4)
    dw      PeppyDSP.air_initial_
    OS.patch_end()

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.PEPPY, 0x4)
    float32 1.0
    OS.patch_end()

    // Set Fox as original character
    Character.table_patch_start(variant_original, Character.id.PEPPY, 0x4)
    dw      Character.id.FOX
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.PEPPY, 0x2)
    dh  0x02B7
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.PEPPY, 0xC)
    dh 0x24
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.PEPPY, 0, 1, 4, 5, 1, 3, 2)
    Teams.add_team_costume(YELLOW, PEPPY, 0x5)

    // Patches for full charge Neutral B effect removal.
    Character.table_patch_start(gfx_routine_end, Character.id.PEPPY, 0x4)
    dw      charge_gfx_routine_
    OS.patch_end()
    
    // For spawning, clears out charges of nsp
    Character.table_patch_start(initial_script, Character.id.PEPPY, 0x4)
    dw      0x800D7DEC                      // use samus jump
    OS.patch_end()

    // an associated moveset command: b0bc0000 removes the white flicker, this is identical to Samus
    // @ Description
    // Jump table patch which enables Peppy's charged neutral b effect when another gfx routine ends, or upon action change.
    scope charge_gfx_routine_: {
        lw      t9, 0x0AE0(a3)              // t9 = charge level
        lli     at, 0x0005                  // at = 5
        lw      a0, 0x0020(sp)              // a0 = player object
        bne     t9, at, _end                // skip if charge level != 6 (full)
        lli     a1, GFXRoutine.id.SHEIK_CHARGE // a1 = SHEIK_CHARGE id

        // if the neutral special is full charged
        _spark:
        or      a2, r0, r0                  // a2 = 0
        jal     0x800E9814                  // begin gfx routine
        sw      a3, 0x001C(sp)              // store a3

        _end:
        j       0x800E9A60                  // return
        lw      a3, 0x001C(sp)              // load a3
    }

    // Shield colors for costume matching
    Character.set_costume_shield_colors(PEPPY, WHITE, RED, BROWN, AZURE, BLACK, ORANGE, NA, NA)

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  4,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  0,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  60,  -1,  200, 1000, -50, 200)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  6,  -1,  -1, -1, -10, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  4,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  4,   -1,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  14,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  6,   -1,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  4,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  65,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  65,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  6,   -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  44,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  44,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  6,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  6,  -1,  -1, -1, -1, -1)

    // Set action strings
    Character.table_patch_start(action_string, Character.id.PEPPY, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set CPU NSP long range behaviour
    Character.table_patch_start(ai_long_range, Character.id.PEPPY, 0x4)
    dw      AI.LONG_RANGE.ROUTINE.NSP_SHOOT
    OS.patch_end()

    // @ Description
    // Patch which does not apply Fox's rotational value for up special
    scope up_special_rotation_offset_air_: {
        OS.patch_start(0xD6AB4, 0x8015C074)
        j       up_special_rotation_offset_air_
        lw      t6, 0x0008(v0)          // t6 = character id
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.PEPPY
        bnel    at, t6, _normal
        lui     at, 0x8019              // og line 1

        mtc1    r0, f10                 // rotation = 0 for peppy
        j       _return
        nop

        _normal:
        lwc1    f10, 0xC880(at)         // og line 2
        j       _return
        nop

    }

    // apply reflect gfx
    //JAL     0x8015D1E0


}
