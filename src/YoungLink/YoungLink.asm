// YoungLink.asm

// This file contains file inclusions, action edits, and assembly for Young Link.

scope YoungLink {
    // Insert Moveset files
    insert JUMP, "moveset/JUMP.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert STUN, "moveset/STUN.bin"; Moveset.GO_TO(STUN)                            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)   // loops
    insert TEETERING, "moveset/TEETERING.bin"
    insert EDGEATTACKF, "moveset/EDGEATTACKF.bin"
    insert EDGEATTACKS, "moveset/EDGEATTACKS.bin"
    insert TECHSTAND, "moveset/TECHSTAND.bin"
    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert JAB_3,"moveset/JAB_3.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NSP, "moveset/NEUTRAL_SPECIAL.bin"
    insert USP_GROUND, "moveset/UP_SPECIAL_GROUND.bin"
    insert USP_GROUND_END, "moveset/UP_SPECIAL_GROUND_END.bin"
    insert USP_AIR, "moveset/UP_SPECIAL_AIR.bin"
    insert VICTORY_POSE_2,"moveset/VICTORY_POSE_2.bin"
    insert POSE_1P, "moveset/POSE_1P.bin"
    insert VICTORY_POSE_1,"moveset/VICTORY_POSE_1.bin"
    insert GRAB_PULL,"moveset/GRAB_PULL.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
    OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(YLINK, Action.JumpF,            -1,                        JUMP,                       -1)
    Character.edit_action_parameters(YLINK, Action.JumpB,            -1,                        JUMP,                       -1)
    Character.edit_action_parameters(YLINK, Action.JumpAerialF,      -1,                        JUMP2,                      -1)
    Character.edit_action_parameters(YLINK, Action.JumpAerialB,      -1,                        JUMP2,                      -1)
    Character.edit_action_parameters(YLINK, Action.Tech,             -1,                        TECHSTAND,                  -1)
    Character.edit_action_parameters(YLINK, Action.CliffAttackQuick2,-1,                        EDGEATTACKF,                -1)
    Character.edit_action_parameters(YLINK, Action.CliffAttackSlow2, -1,                        EDGEATTACKS,                -1)
    Character.edit_action_parameters(YLINK, Action.Stun,             -1,                        STUN,                       -1)
    Character.edit_action_parameters(YLINK, Action.Sleep,            -1,                        ASLEEP,                     -1)
    Character.edit_action_parameters(YLINK, Action.Grab,             -1,                        GRAB,                       -1)
    Character.edit_action_parameters(YLINK, Action.Grab,            File.YLINK_GRAB,            GRAB,                       0x10000000)
    Character.edit_action_parameters(YLINK, Action.GrabPull,        File.YLINK_GRAB_PULL,       GRAB_PULL,                  0x10000000)
    Character.edit_action_parameters(YLINK, Action.Teeter,           -1,                        TEETERING,                  -1)
    Character.edit_action_parameters(YLINK, Action.Taunt,           File.YLINK_TAUNT,           TAUNT,                      -1)
    Character.edit_action_parameters(YLINK, Action.Jab1,            -1,                         JAB_1,                      -1)
    Character.edit_action_parameters(YLINK, Action.Jab2,            -1,                         JAB_2,                      -1)
    Character.edit_action_parameters(YLINK, Action.DashAttack,      0x4B2,                      DASH_ATTACK,                -1)
    Character.edit_action_parameters(YLINK, Action.FTilt,           -1,                         FTILT,                      -1)
    Character.edit_action_parameters(YLINK, Action.UTilt,           -1,                         UTILT,                      -1)
    Character.edit_action_parameters(YLINK, Action.DTilt,           -1,                         DTILT,                      -1)
    Character.edit_action_parameters(YLINK, Action.FSmash,          -1,                         FSMASH,                     -1)
    Character.edit_action_parameters(YLINK, Action.USmash,          File.YLINK_USMASH,          USMASH,                     -1)
    Character.edit_action_parameters(YLINK, Action.DSmash,          -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirN,      -1,                         NAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirF,      -1,                         FAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(YLINK, Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(YLINK, 0xDC,                   -1,                         JAB_3,                      -1)
    Character.edit_action_parameters(YLINK, 0xE5,                   -1,                         NSP,                        -1)
    Character.edit_action_parameters(YLINK, 0xE8,                   -1,                         NSP,                        -1)
    Character.edit_action_parameters(YLINK, 0xE2,                   -1,                         USP_GROUND,                 -1)
    Character.edit_action_parameters(YLINK, 0xE3,                   -1,                         USP_GROUND_END,             -1)
    Character.edit_action_parameters(YLINK, 0xE4,                   -1,                         USP_AIR,                    -1)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(YLINK, 0x1,               File.YL_VICTORY,            VICTORY_POSE_1,             -1)
    Character.edit_menu_action_parameters(YLINK, 0x2,               -1,                         VICTORY_POSE_2,             -1)
    Character.edit_menu_action_parameters(YLINK, 0xD,               -1,                         POSE_1P,                    -1)
    Character.edit_menu_action_parameters(YLINK, 0xE,               File.YLINK_1P_CPU_POSE,     0x80000000,                 -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(YLINK, 0xE4,              -1,             -1,                         YoungLinkUSP.direction_,        -1,                             -1)

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.YLINK, 0x4)
    float32 1.05
    OS.patch_end()

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.YLINK, 0x2)
    dh  0x02D7
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.YLINK, 0, 1, 4, 5, 2, 3, 0)
    Teams.add_team_costume(YELLOW, YLINK, 0x6)

    // Shield colors for costume matching
    Character.set_costume_shield_colors(YLINK, GREEN, WHITE, RED, AZURE, PINK, BLACK, YELLOW, NA)

    // @ Description
    // Young Link's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant JabLoopStart(0x0DD)
        constant JabLoop(0x0DE)
        constant JabLoopEnd(0x0DF)
        constant Appear1(0x0E0)
        constant Appear2(0x0E1)
        constant UpSpecial(0x0E2)
        constant UpSpecialEnd(0x0E3)
        constant UpSpecialAir(0x0E4)
        constant Boomerang(0x0E5)
        constant BoomerangCatch(0x0E6)
        constant BoomerangMiss(0x0E7)
        constant BoomerangAir(0x0E8)
        constant BoomerangCatchAir(0x0E9)
        constant BoomerangMissAir(0x0EA)
        constant Bomb(0x0EB)
        constant BombAir(0x0EC)

        // strings!
        //string_0x0DC:; String.insert("Jab3")
        //string_0x0DD:; String.insert("JabLoopStart")
        //string_0x0DE:; String.insert("JabLoop")
        //string_0x0DF:; String.insert("JabLoopEnd")
        //string_0x0E0:; String.insert("Appear1")
        //string_0x0E1:; String.insert("Appear2")
        //string_0x0E2:; String.insert("UpSpecial")
        //string_0x0E3:; String.insert("UpSpecialEnd")
        //string_0x0E4:; String.insert("UpSpecialAir")
        //string_0x0E5:; String.insert("Boomerang")
        //string_0x0E6:; String.insert("BoomerangCatch")
        //string_0x0E7:; String.insert("BoomerangMiss")
        //string_0x0E8:; String.insert("BoomerangAir")
        //string_0x0E9:; String.insert("BoomerangCatchAir")
        //string_0x0EA:; String.insert("BoomerangMissAir")
        string_0x0EB:; String.insert("Bombchu")
        string_0x0EC:; String.insert("BombchuAir")

        action_string_table:
        dw Action.COMMON.string_jab3
        dw Action.COMMON.string_jabloopstart
        dw Action.COMMON.string_jabloop
        dw Action.COMMON.string_jabloopend
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw Action.LINK.string_0x0E2
        dw Action.LINK.string_0x0E3
        dw Action.LINK.string_0x0E4
        dw Action.LINK.string_0x0E5
        dw Action.LINK.string_0x0E6
        dw Action.LINK.string_0x0E7
        dw Action.LINK.string_0x0E8
        dw Action.LINK.string_0x0E9
        dw Action.LINK.string_0x0EA
        dw string_0x0EB
        dw string_0x0EC
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.YLINK, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.YLINK, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Edit cpu attack behaviours
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPA,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  -1,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSMASH, -1,  9,   22,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DTILT,  -1,  7,   14,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1,  9,   16,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DAIR,   -1,  5,   63,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FSMASH, -1,  14,  21,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1,  6,   9,   -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1,  6,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, JAB,    -1,  5,  -1,  50, 150, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NAIR,   -1,  4,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPA,   -1,  18,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, NSPG,   -1,  18,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UAIR,   -1,  5,   48,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPA,   -1,  5,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USPG,   -1,  5,  -1,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1,  9,   26,  -1, -1, -1, -1)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, UTILT,  -1,  8,  16,  -1, -1, -1, -1)

    up_special_landing_fsm:
    float32 0.33                // 25 frames of landing lag

    // @ Description
    // modifies a subroutine which determines the speed of Link's boomerang
    // uses a different speed value if character is Young Link
    scope boomerang_speed_: {
        OS.patch_start(0xE8578, 0x8016DB38)
        j       _slow
        nop
        _slow_return:
        OS.patch_end()

        OS.patch_start(0xE859C, 0x8016DB5C)
        j       _fast
        nop
        _fast_return:
        OS.patch_end()

        _slow:
        or      a1, s1, r0                  // a1 = player struct (original line 1)
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1

        lw      t0, 0x0008(a1)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power

        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        lui     a3, 0x428C                  // a3 = float: 65
        beq     t1, t0, _slow_end           // end if character id = YLINK
        nop
        lui     a3, 0x42AA                  // a3 = float: 85 (original line 2)

        _slow_end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _slow_return                // return
        nop

        _fast:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1

        lw      t0, 0x0008(a1)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power

        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        lui     a3, 0x42C6                  // a3 = float: 99
        beq     t1, t0, _fast_end           // end if character id = YLINK
        nop
        lui     a3, 0x42E4                  // a3 = float: 114 (original line 2)

        _fast_end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x8016D914                  // original line 1
        nop
        j       _fast_return                // return
        nop
    }

    // @ Description
    // modifies a subroutine which runs when Link uses up special
    // uses character id to determine special fall landing speed
    scope up_special_landing_: {
        OS.patch_start(0xDEA30, 0x80163FF0)
        j       up_special_landing_
        nop
        _return:
        OS.patch_end()
        lw      a0, 0x0028(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(a0)              // t0 = character id
        ori     t1, r0, Character.id.YLINK  // t1 = id.YLINK
        li      a1, up_special_landing_fsm  // ~
        lwc1    f8, 0x0000(a1)              // f8 = YLINK landing fsm value
        beq     t1, t0, _end                // end if character id = YLINK
        nop
        li      a1, 0x8018CA28              // ~
        lwc1    f8, 0x0000(a1)              // f8 = LINK landing fsm value (modified original logic)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

}
