// Lucas.asm

// This file contains file inclusions, action edits, and assembly for Lucas.

scope Lucas {
    // Insert Moveset files
    insert FAIR, "moveset/FAIR.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert BAIR, "moveset/BAIR.bin"
    insert DAIR, "moveset/DAIR.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert FSMASH, "moveset/FSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert GRAB_RELEASE_DATA,"moveset/GRAB_RELEASE_DATA.bin"
    GRAB:; Moveset.THROW_DATA(GRAB_RELEASE_DATA); insert "moveset/GRAB.bin"
    insert FTHROW_CONCURRENT,"moveset/FORWARD_THROW_CONCURRENT.bin"
    insert FTHROW_DATA,"moveset/FORWARD_THROW_DATA.bin"
    FTHROW:; Moveset.CONCURRENT_STREAM(FTHROW_CONCURRENT); Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FORWARD_THROW.bin"
    insert GRAB_PULL,"moveset/GRAB_PULL.bin"
    insert PKFIREGROUND, "moveset/PKFIREGROUND.bin"
    insert PKFIREAIR, "moveset/PKFIREAIR.bin"
    insert JUMP1, "moveset/JUMP1.bin"
    insert JUMP2, "moveset/JUMP2.bin"
    insert JAB1, "moveset/JAB1.bin"
    insert JAB2, "moveset/JAB2.bin"
    insert JAB3, "moveset/JAB3.bin"
    insert DASHATTACK, "moveset/DASHATTACK.bin"
    insert FTILT_MID, "moveset/FTILT.bin"
    insert FTILT_LOW, "moveset/FTILT_DOWN.bin"
    insert FTILT_HIGH, "moveset/FTILT_UP.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert DOWN_SPECIAL_INITIATE, "moveset/DOWN_SPECIAL_INITIATE.bin"
    insert DOWN_SPECIAL_WAIT, "moveset/DOWN_SPECIAL_WAIT.bin"
    insert DOWN_SPECIAL_ABSORB, "moveset/DOWN_SPECIAL_ABSORB.bin"
    insert DOWN_SPECIAL_END, "moveset/DOWN_SPECIAL_END.bin"
    insert TAUNT, "moveset/TAUNT.bin"
    insert TECH, "moveset/TECH.bin"
    insert TECH_ROLL, "moveset/TECH_ROLL.bin"
    insert STUN_LOOP, "moveset/STUN_LOOP.bin"; Moveset.GO_TO(STUN_LOOP)         // loops
    insert EDGE_ATTACK_F, "moveset/EDGE_ATTACK_F.bin"
    insert EDGE_ATTACK_S, "moveset/EDGE_ATTACK_S.bin"
    insert UP_SPECIAL_INTIATE, "moveset/UP_SPECIAL_INTIATE.bin"
    insert UP_SPECIAL_2, "moveset/UP_SPECIAL_2.bin"
    insert SPARKLE,"moveset/SPARKLE.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert SHIELD_BREAK,"moveset/SHIELD_BREAK.bin"; Moveset.GO_TO(SPARKLE)            // loops
    insert ASLEEP, "moveset/ASLEEP.bin"; Moveset.GO_TO(ASLEEP)   // loops
    insert TEETER, "moveset/TEETER.bin"
    insert SELECTED, "moveset/SELECTED.bin"
	insert ONEP, "moveset/1P.bin"
	insert NEEDLE, "moveset/NEEDLE.bin"
    insert ENTRY,"moveset/ENTRY.bin"
	insert PKVICTORY,"moveset/PKVICTORY.bin"

    // Insert AI attack options
    constant CPU_ATTACKS_ORIGIN(origin())
    insert CPU_ATTACKS,"AI/attack_options.bin"
	OS.align(16)

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(LUCAS, Action.Jab1,            File.LUCAS_JAB1,            JAB1,                       0x00000000)
    Character.edit_action_parameters(LUCAS, Action.Jab2,            File.LUCAS_JAB2,            JAB2,                       0x00000000)
    Character.edit_action_parameters(LUCAS, 0xDC,                   File.LUCAS_JAB3,            JAB3,                       0x00000000)
    Character.edit_action_parameters(LUCAS, Action.AttackAirN,      File.LUCAS_NAIR,            NAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirF,      File.LUCAS_FAIR,            FAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirB,      File.LUCAS_BAIR,            BAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirU,      File.LUCAS_UAIR,            UAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.AttackAirD,      File.LUCAS_DAIR,            DAIR,                       -1)
    Character.edit_action_parameters(LUCAS, Action.FTilt,           File.LUCAS_FTILT_MID,       FTILT_MID,                  0x00000000)
    Character.edit_action_parameters(LUCAS, Action.FTiltHigh,       File.LUCAS_FTILT_HIGH,      FTILT_HIGH,                 0x00000000)
    Character.edit_action_parameters(LUCAS, Action.FTiltLow,        File.LUCAS_FTILT_LOW,       FTILT_LOW,                  0x00000000)
    Character.edit_action_parameters(LUCAS, Action.UTilt,           File.LUCAS_UTILT,           UTILT,                      -1)
    Character.edit_action_parameters(LUCAS, Action.DTilt,           File.LUCAS_DTILT,           DTILT,                         -0x80000000)
    Character.edit_action_parameters(LUCAS, Action.USmash,          File.LUCAS_USMASH,          USMASH,                     0x80000000)
    Character.edit_action_parameters(LUCAS, Action.DSmash,          File.LUCAS_DSMASH,          DSMASH,                     0x00000000)
    Character.edit_action_parameters(LUCAS, Action.Grab,            File.LUCAS_GRAB,            GRAB,                       -1)
    Character.edit_action_parameters(LUCAS, Action.GrabPull,        File.LUCAS_GRAB_PULL,       GRAB_PULL,                  -1)
    Character.edit_action_parameters(LUCAS, Action.ThrowF,          File.LUCAS_FTHROW,          FTHROW,                     -1)
    Character.edit_action_parameters(LUCAS, Action.FSmash,          -1,                         FSMASH,                     -1)
    Character.edit_action_parameters(LUCAS, Action.DashAttack,      File.LUCAS_DASHATTACK,      DASHATTACK,                 -1)
    Character.edit_action_parameters(LUCAS, Action.JumpF,           -1,          		JUMP1,                         -1)
    Character.edit_action_parameters(LUCAS, Action.JumpB,           -1,          		JUMP1,                         -1)
    Character.edit_action_parameters(LUCAS, Action.Taunt,           File.LUCAS_TAUNT,           TAUNT,                      0x00000000)
    Character.edit_action_parameters(LUCAS, Action.CliffAttackQuick2, -1,                       EDGE_ATTACK_F,              -1)
    Character.edit_action_parameters(LUCAS, Action.CliffAttackSlow2, -1,                        EDGE_ATTACK_S,              -1)
    Character.edit_action_parameters(LUCAS, Action.Stun,            -1,                         STUN_LOOP,                  -1)
    Character.edit_action_parameters(LUCAS, Action.TechF,            -1,                        TECH_ROLL,                  -1)
    Character.edit_action_parameters(LUCAS, Action.TechB,            -1,                        TECH_ROLL,                  -1)
    Character.edit_action_parameters(LUCAS, Action.Tech,             -1,                        TECH,                       -1)
    Character.edit_action_parameters(LUCAS, Action.ShieldBreak,      -1,                        SHIELD_BREAK,               -1)
    Character.edit_action_parameters(LUCAS, Action.Sleep,            -1,                        ASLEEP,                     -1)
    Character.edit_action_parameters(LUCAS, Action.Teeter,           -1,                        TEETER,                     -1)
    Character.edit_action_parameters(LUCAS, Action.JumpAerialF,        -1,             JUMP2,                      -1)
    Character.edit_action_parameters(LUCAS, Action.JumpAerialB,        -1,                             JUMP2,                      -1)


    Character.edit_action_parameters(LUCAS, 0xE2,                   File.LUCAS_PKFIREGROUNDANI, PKFIREGROUND,               0x40000000)
    Character.edit_action_parameters(LUCAS, 0xE3,                   File.LUCAS_PKFIREAIRANI,    PKFIREAIR,                  -1)
    Character.edit_action_parameters(LUCAS, 0xED,                   File.LUCAS_MAGNETSTARTGR,   DOWN_SPECIAL_INITIATE,      -1)
    Character.edit_action_parameters(LUCAS, 0xEE,                   File.LUCAS_MAGNETHOLDGR,    DOWN_SPECIAL_WAIT,          -1)
	Character.edit_action_parameters(LUCAS, 0xEF,                   File.LUCAS_MAGNETHOLDGR,    DOWN_SPECIAL_ABSORB,        -1)
    Character.edit_action_parameters(LUCAS, 0xF0,                   File.LUCAS_MAGNETRELEASEGR, DOWN_SPECIAL_END,           -1)
    Character.edit_action_parameters(LUCAS, 0xF1,                   File.LUCAS_MAGNETSTARTAIR,  DOWN_SPECIAL_INITIATE,      -1)
    Character.edit_action_parameters(LUCAS, 0xF2,                   File.LUCAS_MAGNETHOLDAIR,   DOWN_SPECIAL_WAIT,          -1)
	Character.edit_action_parameters(LUCAS, 0xF3,                   File.LUCAS_MAGNETHOLDAIR,   DOWN_SPECIAL_ABSORB,        -1)
    Character.edit_action_parameters(LUCAS, 0xF4,                   File.LUCAS_MAGNETRELEASEAIR, DOWN_SPECIAL_END,          -1)
    Character.edit_action_parameters(LUCAS, Action.FallSpecial,     File.LUCAS_SFALL,           -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xE4,                   File.LUCAS_PKTHUNDERSTARTGR, UP_SPECIAL_INTIATE,        -1)
    Character.edit_action_parameters(LUCAS, 0xE5,                   File.LUCAS_PKTHUNDERHOLDGR, -1,                         -1)
    Character.edit_action_parameters(LUCAS, 0xE6,                   File.LUCAS_PKTHUNDERRELEASEGR, -1,                      -1)
    Character.edit_action_parameters(LUCAS, 0xE8,                   File.LUCAS_PKTHUNDERSTARTAIR, UP_SPECIAL_INTIATE,       -1)
    Character.edit_action_parameters(LUCAS, 0xE9,                   File.LUCAS_PKTHUNDERHOLDAIR, -1,                        -1)
    Character.edit_action_parameters(LUCAS, 0xEA,                   File.LUCAS_PKTHUNDERRELEASEAIR, -1,                     -1)
    Character.edit_action_parameters(LUCAS, 0xEC,                   File.LUCAS_PKTHUNDER2,      UP_SPECIAL_2,               -1)
    Character.edit_action_parameters(LUCAS, 0xE7,                   File.LUCAS_PKTHUNDER2,      UP_SPECIAL_2,               -1)
    Character.edit_action_parameters(LUCAS, 0xDD,                   File.LUCAS_ENTRY_R,         ENTRY,                      0x50000000)
    Character.edit_action_parameters(LUCAS, 0xDE,                   File.LUCAS_ENTRY_L,         ENTRY,                      0x50000000)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(LUCAS, 0xDD,              -1,             0x8013DA94,                         -1,                             -1,                       -1)
	Character.edit_action(LUCAS, 0xDE,              -1,             0x8013DA94,                         -1,                             -1,                       -1)
    Character.edit_action(LUCAS, 0xE2,              -1,             -1,                         -1,                             0x800D8CCC,                       -1)
    Character.edit_action(LUCAS, 0xE3,              -1,             -1,                         LucasNSP.air_move_,             -1,                               -1)
    Character.edit_action(LUCAS, 0xF1,              -1,             -1,                         -1,                             -1,                             0x800DE99C)
    Character.edit_action(LUCAS, 0xF2,              -1,             -1,                         -1,                             -1,                             0x800DE99C)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
	Character.edit_menu_action_parameters(LUCAS, 0x1,               File.LUCAS_NEEDLE_ANIM,     NEEDLE,                             0x10000000)
    Character.edit_menu_action_parameters(LUCAS, 0x2,               File.LUCAS_SELECTED,        SELECTED,                           -1)
	Character.edit_menu_action_parameters(LUCAS, 0x3,               File.LUCAS_PKVICTORY,       PKVICTORY,                          -1)
	Character.edit_menu_action_parameters(LUCAS, 0x4,               File.LUCAS_PKVICTORY,       PKVICTORY,                          -1)
	Character.edit_menu_action_parameters(LUCAS, 0xD,               File.LUCAS_1P,        		ONEP,                               -1)
    Character.edit_menu_action_parameters(LUCAS, 0xE,               File.LUCAS_1P_CPU_POSE,     0x80000000,                         -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.LUCAS, 0x2)
    dh  0x0338
    OS.patch_end()

    // Remove entry script.
    Character.table_patch_start(entry_script, Character.id.LUCAS, 0x4)
    dw 0x8013DD68                           // skips entry script
    OS.patch_end()

    // Remove gfx routine ending script.
    Character.table_patch_start(gfx_routine_end, Character.id.LUCAS, 0x4)
    dw  0x800E9A60                          // skips overlay ending script
    OS.patch_end()

    // Set Kirby hat_id
    Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.LUCAS, 0xC)
    dh 0x14
    OS.patch_end()

    // Set default costumes
    Character.set_default_costumes(Character.id.LUCAS, 0, 1, 2, 4, 0, 2, 5)
    Teams.add_team_costume(YELLOW, LUCAS, 0x4)

    Character.table_patch_start(variants, Character.id.LUCAS, 0x4)
    db      Character.id.NONE
    db      Character.id.NLUCAS // set as POLYGON variant for LUCAS
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    Character.table_patch_start(variant_original, Character.id.NLUCAS, 0x4)
    dw      Character.id.WARIO // set Wario as original character (not Ness, who NLUCAS is a clone of)
    OS.patch_end()

    // Set CPU behaviour
    Character.table_patch_start(ai_behaviour, Character.id.LUCAS, 0x4)
    dw      CPU_ATTACKS
    OS.patch_end()

    // Edit cpu attack behaviours
    // Timing values are already set in Lucas's .bin file, just need to adjust floats
    // edit_attack_behavior(table, attack, override, start_hb, end_hb, min_x, max_x, min_y, max_y)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, DSPG,   -1,  1,  1,  -90,     270,     60,      410)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, USMASH, -1, -1, -1,  -115,    115,     80,      1000)
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, GRAB,   -1, -1, -1,  -1,      580.0,   -1,      -1)  // x max was 720.0
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FTILT,  -1, -1, -1,  -1,      520.0,   -1,      -1)  // x max was 580.0
    AI.edit_attack_behavior(CPU_ATTACKS_ORIGIN, FAIR,   -1, -1, -1,  -457,    180,     -200,    200) // change coords

    // Shield colors for costume matching
    Character.set_costume_shield_colors(LUCAS, YELLOW, ORANGE, PINK, BROWN, BROWN, GREEN, NA, NA)

    // @ Description
    // Lucas's extra actions
    scope Action {
        constant Jab3(0x0DC)
        constant Appear1(0x0DD)
        constant Appear2(0x0DE)
        //constant Appear1(0x0DF)
        //constant Appear2(0x0E0)
        //constant AppearEnd(0x0E1)
        constant PKFire(0x0E2)
        constant PKFireAir(0x0E3)
        constant PKThunderStart1(0x0E4)
        constant PKThunderStart2(0x0E5)
        constant PKThunderEnd(0x0E6)
        constant PKTA(0x0E7)
        constant PKThunderStartAir(0x0E8)
        constant PKThunderAir(0x0E9)
        constant PKThunderEndAir(0x0EA)
        constant ClashingPKTA(0x0EB)
        constant PKTAAir(0x0EC)
        constant PsiMagnetStart(0x0ED)
        constant PsiMagnet(0x0EE)
        constant Healing(0x0EF)
        constant PsiMagnetEnd(0x0F0)
        constant PsiMagnetStartAir(0x0F1)
        constant PsiMagnetAir(0x0F2)
        constant HealingAir(0x0F3)
        constant PsiMagnetEndAir(0x0F4)

        action_string_table:
        dw Action.COMMON.string_jab3
        dw Action.COMMON.string_appear1
        dw Action.COMMON.string_appear2
        dw 0 //dw string_0x0DF
        dw 0 //dw string_0x0E0
        dw 0 //dw string_0x0E1
        dw Action.NESS.string_0x0E2
        dw Action.NESS.string_0x0E3
        dw Action.NESS.string_0x0E4
        dw Action.NESS.string_0x0E5
        dw Action.NESS.string_0x0E6
        dw Action.NESS.string_0x0E7
        dw Action.NESS.string_0x0E8
        dw Action.NESS.string_0x0E9
        dw Action.NESS.string_0x0EA
        dw Action.NESS.string_0x0EB
        dw Action.NESS.string_0x0EC
        dw Action.NESS.string_0x0ED
        dw Action.NESS.string_0x0EE
        dw Action.NESS.string_0x0EF
        dw Action.NESS.string_0x0F0
        dw Action.NESS.string_0x0F1
        dw Action.NESS.string_0x0F2
        dw Action.NESS.string_0x0F3
        dw Action.NESS.string_0x0F4
    }

    // Set action strings
    Character.table_patch_start(action_string, Character.id.LUCAS, 0x4)
    dw  Action.action_string_table
    OS.patch_end()

    // Forces Lucas' pk fire to stay horizontal when in the air
    // @ Description
    // essentially a binary BNE, if 0, player is on the ground and will skip diagonal command. If in the air,
    // then it will be 1 and will proceed to go diagonal. A character check is done, player struct in s1 and v0.
    // If lucas, the number will be changed to 0
    scope pkfire_horizontal: {
        // Ness (or Ness clone)
        OS.patch_start(0xCE414, 0x801539D4)
        jal     pkfire_horizontal
        nop
        OS.patch_end()
        // Kirby w/Ness (or Ness clone) power
        OS.patch_start(0xD0600, 0x80155BC0)
        jal     pkfire_horizontal
        nop
        OS.patch_end()

        swc1    f18, 0x0028(sp)             // original line 1

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lw      t1, 0x0008(v0)              // load character ID

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(v0)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(v0)              // t1 = character id of copied power

        ori     t2, r0, Character.id.LUCAS  // t1 = id.LUCAS
        addiu   t9, r0, r0                  // set LUCAS as if grounded always
        beq     t1, t2, _end
        nop
        lw      t9, 0x14C(v0)               // original line 2 - load current position, grounded (0) or air (1)

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // Changes PK FIRE's after effect for Lucas
    // @ Description
    // the normal path it takes to spawn the pk fire2 object is swapped out with the explosion graphic
    scope pkfire_explosion: {
        OS.patch_start(0xE55A8, 0x8016AB68)
        j       pkfire_explosion
        nop
        _return:
        OS.patch_end()

        swc1    f18, 0x0030(sp)             // original line 2

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store registers
        sw      t2, 0x0008(sp)              // ~
        sw      t3, 0x000C(sp)              // ~

        lw      t3, 0x0078(v0)              // load player struct from projectile struct as placed in previously by pkfire1pointer
        lw      t1, 0x0008(t3)              // load character ID

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(t3)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(t3)              // t1 = character id of copied power

        ori     t2, r0, Character.id.LUCAS  // t1 = id.JNESS
        beq     t1, t2, lucas_explosion_
        nop

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // ~
        lw      t3, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80185824                  // original line 1 - modified
        nop
        j       _return                     // return
        nop

        lucas_explosion_:
        addiu   a0, a1, 0x0000
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // ~
        lw      t3, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80100480                  // jump to explosion process
        nop
        j       _return                     // return
        nop
    }

    // @ Description
    // Fixes the position of the up special graphic for Lucas.
    // Normally, this routine will set a Y rotation value in a struct used for the up special
    // graphic to 1.5708 or -1.5708. This patch skips setting that rotation for Lucas.
    // Unclear if this is necessary, but may as well keep for safety.
    scope usp_graphic_position_fix_: {
        OS.patch_start(0x7E268, 0x80102A68)
        j       usp_graphic_position_fix_
        mul.s   f10, f6, f8                 // original line 1
        _return:
        OS.patch_end()

        // t2 = unknown graphic related struct
        // a1 = player struct
        lw      t0, 0x0008(a0)              // t0 = character id
        ori     t2, r0, Character.id.LUCAS  // t2 = id.LUCAS
        bnel    t0, t2, _end                // branch if character !id = LUCAS
        swc1    f10, 0x0034(t1)             // original line 2 (if branch taken)
        _end:
        j       _return
        nop
    }

    // @ Description
    // Moves the subroutine 0x801655A0(which gets the projectile instance id) to the creation of
    // the thunder head projectile. Then passes the instance id to the thunder head projectile
    // struct. This will allow the thunder head to be included in the multi hit logic.
    scope usp_thunder_head_: {
        OS.patch_start(0xE5D3C, 0x8016B2FC)
        j       usp_thunder_head_
        nop
        _return:
        OS.patch_end()

        // 0x0018(sp) = player object struct
        lw      at, 0x0018(sp)              // ~
        lw      at, 0x0084(at)              // at = player struct
        lw      at, 0x0008(at)              // at = character id
        ori     t6, r0, Character.id.LUCAS  // t7 = id.LUCAS
        bne     at, t6, _end                // skip if character !id = LUCAS
        nop

        // if we reach this point the character creating the projectile is Lucas
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // store a0
        jal     0x801655A0                  // get projectile instance id
        sw      v0, 0x0008(sp)              // store v0
        or      t6, v0, r0                  // t6 = projectile instance id
        lw      v0, 0x0008(sp)              // ~
        lw      a0, 0x0004(sp)              // load v0, a0
        addiu   sp, sp, 0x0010              // deallocate stack space
        lw      v1, 0x0084(v0)              // v1 = thunder head projectile struct
        sw      t6, 0x0264(v1)              // store projectile instance id
        _end:
        // TODO: rework this into nesshared.asm?
        lw      v1, 0x0084(v0)              // original line 1
        lw      at, 0x0018(sp)              // ~
        lw      at, 0x0084(at)              // at = player struct
        sw      at, 0x01B4(v1)              // save player struct in thunder head projectile struct
        lui     at, 0x8019                  // original line 2
        j       _return                     // return
        nop
    }

    // @ Description
    // Skips the subroutine 0x801655A0(which gets the projectile instance id) upon creation of the
    // first thunder tail projectile, and passes the value from the thunder head instead.
    scope usp_thunder_tail_: {
        OS.patch_start(0xE6034, 0x8016B5F4)
        j       usp_thunder_tail_
        sw      t0, 0x001C(sp)              // original line 2
        _return:
        OS.patch_end()

        // t0 = thunder head struct
        // v1 = first thunder tail struct
        lw      t6, 0x01B4(t0)              // t6 = thunder head projectile creator struct
        lw      t6, 0x0008(t6)              // t6 = character id
        ori     t7, r0, Character.id.LUCAS  // t7 = id.LUCAS
        bne     t6, t7, _end                // skip if character !id = LUCAS
        nop

        // if we reach this point the character creating the projectile is Lucas
        // normally, 0x801655A0 returns the instance id to v0, it is then passed to the first tail
        // struct and eventually all subsequent tail structs, but since we already ran 0x801655A0
        // for the thunder head with Lucas, we can just get the instance id from the thunder head
        // projectile struct instead
        lw      v0, 0x0264(t0)              // v0 = projectile instance id of thunder head
        j       _return                     // return
        nop

        _end:
        jal     0x801655A0                  // original line 1(get projectile instance id)
        nop
        j       _return                     // return
        nop
    }

    // @ Description
    // Function which allows Lucas up special to hit multiple times.
    // Overrides 2 JALs, at 0x8016B51C(controlled thunder) and 0x8016BB08(reflected thunder)
    // The JAL is usually to 0x80167FE8, which is a short subroutine used to increment the
    // projectile timer for the projectile in a0. This new function will be responsible for
    // resetting the hit object pointers for all thunder head/tail projectiles at a fixed rate.
    // Loop logic is based on the loop at 0x801667D0 which copies hit object pointers to all
    // thunder tail projectiles when a thunder tail hits something, so it is presumed safe.
    scope usp_multi_hit_: {
        constant HIT_RATE(8) // number of frames between hitbox refreshes

        // hook for controlled pk thunder head
        OS.patch_start(0xE5994, 0x8016AF54)
        jal     usp_multi_hit_
        OS.patch_end()
        // hook for controlled pk thunder tail
        OS.patch_start(0xE5F5C, 0x8016B51C)
        jal     usp_multi_hit_
        OS.patch_end()

        // TODO: these are currently disabled because the player struct is not passed to reflected
        // pk thunder projectiles
        // hook for reflected pk thunder head
        OS.patch_start(0xE61A4, 0x8016B764)
        // jal     usp_multi_hit_
        OS.patch_end()
        // hook for reflected pk thunder tail
        OS.patch_start(0xE6548, 0x8016BB08)
        // jal     usp_multi_hit_
        OS.patch_end()


        addiu   sp, sp,-0x0028              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      t4, 0x0014(sp)              // ~
        sw      t5, 0x0018(sp)              // ~
        sw      t6, 0x001C(sp)              // ~
        sw      ra, 0x0020(sp)              // store t0 - t6, ra


        // Initial setup
        // a0 = current projectile struct
        // The "projectile instance id" is a unique id which gets generated upon the creation of
        // a special projectile by subroutine 0x801655A0. This subroutine is used by the thunder
        // tails and presumably 2 other projectile types (unknown).
        or      t0, a0, r0                  // t0 = current projectile struct
        lw      t1, 0x0264(t0)              // t1 = current projectile instance id
        lw      t2, 0x01B4(t0)              // t2 = current projectile creator struct
        lw      t2, 0x0008(t2)              // t2 = current projectile creator id
        ori     t3, r0, Character.id.LUCAS  // t6 = id.LUCAS
        bne     t2, t3, _end                // end if character id != LUCAS
        nop
        li      t2, 0x80046704              // t2 = projectile objects head
        lw      t2, 0x0000(t2)              // t2 = first projectile object
        beq     t2, r0, _end                // end if no projectile objects (this is likely redundant)
        nop

        // The outer loop is used to find the first projectile struct which matches the current
        // instance id, if said struct is also the current projectile struct, continues to the
        // inner loop.
        _outer_loop:
        lw      t3, 0x0084(t2)              // t3 = projectile struct
        lw      t4, 0x0264(t3)              // t4 = instance id
        bne     t1, t4, _end_outer_loop     // branch to outer loop end if instance id does not match
        nop

        // If we reach this point, we've found the first projectile struct with an instance id that
        // matches the current projectile, so the next step is to check if the current projectile
        // is the first struct with its instance id (the thunder head, hopefully).
        // If the current projectile is not the first of its instance id, then exit the loop.
        bne     t0, t3, _end                // exit loop if projectile struct does not match
        nop

        // If we reach this point, we've determined that the current projectile is the first in the
        // projectile object list with its instance id, and we can proceed with checking if the
        // hitboxes should be refreshed.
        lw      t5, 0x0268(t0)              // t5 = current projectile timer
        // I can't recall if attempting to divide by 0 will cause an exception/crash, so I added
        // this check to be safe.
        beq     t5, r0, _end                // exit loop if timer = 0
        nop
        ori     t6, r0, HIT_RATE            // t6 = HIT_RATE
        divu    t5, t6                      // t5 div t6
        mfhi    t6                          // t6 = timer % HIT_RATE
        bnez    t6, _end                    // exit loop if timer % HIT_RATE != 0
        nop

        // If we reach this point, then it's time to refresh the hitboxes for all thunder tail
        // projectiles. This is done by once again looping through all active projectile objects,
        // this time nulling the pointers at 0x214, 0x21C, 0x224, and 0x22C in each projectile
        // struct which matches the current instance id. These four pointers are used to track
        // objects which have been hit by the projectile, preventing it from hitting those objects
        // a second time. By resetting this pointers, the projectile will now be able to hit any
        // object again and will have a "multi hit" effect.
        li      t2, 0x80046704              // t2 = projectile objects head
        lw      t2, 0x0000(t2)              // t2 = first projectile object

        _inner_loop:
        lw      t3, 0x0084(t2)              // t3 = projectile struct
        lw      t4, 0x0264(t3)              // t4 = instance id
        bne     t1, t4, _end_inner_loop     // branch to inner loop end if instance id does not match
        nop

        // If we reach this point, do a final check to verify that the projectile was created by Lucas
        lw      t5, 0x01B4(t3)              // t5 = projectile creator struct
        lw      t5, 0x0008(t5)              // t5 = projectile creator id
        ori     t6, r0, Character.id.LUCAS  // t6 = id.LUCAS
        bne     t5, t6, _end_inner_loop     // branch to inner loop end if character id != LUCAS
        nop

        // refresh hitbox
        sw      r0, 0x0214(t3)              // reset hit object pointer 1
        sw      r0, 0x021C(t3)              // reset hit object pointer 2
        sw      r0, 0x0224(t3)              // reset hit object pointer 3
        sw      r0, 0x022C(t3)              // reset hit object pointer 4

        _end_inner_loop:
        lw      t2, 0x0004(t2)              // t2 = next projectile object
        bne     t2, r0, _inner_loop         // loop if next projectile object exists
        nop
        beq     r0, r0, _end                // exit loop
        nop

        _end_outer_loop:
        lw      t2, 0x0004(t2)              // t2 = next projectile object
        bne     t2, r0, _outer_loop         // loop if next projectile object exists
        nop

        _end:
        jal     0x80167FE8                  // original JAL (increment timer)
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      t4, 0x0014(sp)              // ~
        lw      t5, 0x0018(sp)              // ~
        lw      t6, 0x001C(sp)              // ~
        lw      ra, 0x0020(sp)              // load t0 - t6, ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Fixes the position of the down special graphic for Lucas.
    // This patch simply adds X translation to the graphic's position, based on facing direction.
    scope dsp_graphic_position_fix_: {
        constant X_TRANSLATION(0x4370)  // float: 240

        OS.patch_start(0x7DE04, 0x80102604)
        j       dsp_graphic_position_fix_
        nop
        _return:
        OS.patch_end()

        // v1 = graphic object struct
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a1, 0x0074(v1)              // ~
        lw      a1, 0x0010(a1)              // a1 = graphic struct with x/y/z position

        addiu   sp, sp,-0x0010              // allocate stack space
        swc1    f0, 0x0004(sp)              // ~
        swc1    f2, 0x0008(sp)              // store f0, f2

        lw      t6, 0x0008(a0)              // t6 = character id
        ori     t7, r0, Character.id.LUCAS  // t7 = id.LUCAS
        bne     t6, t7, _end                // skip if character !id = LUCAS
        nop

        _lucas:
        lui     t6, X_TRANSLATION           // ~
        mtc1    t6, f0                      // f0 = X_TRANSLATION
        lwc1    f2, 0x0044(a0)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_TRANSLATION * DIRECTION
        swc1    f0, 0x001C(a1)              // store x translation

        _end:
        lwc1    f0, 0x0004(sp)              // ~
        lwc1    f2, 0x0008(sp)              // load f0, f2
        addiu   sp, sp, 0x0010              // allocate stack space
        lw      a0, 0x0084(v1)              // original line 1
        or      v0, v1, r0                  // original line 2
        j       _return
        nop
    }
    
    // @ Description
    // Prevent Lucas from turning around
    scope dsp_absorption_turnaround_prevent: {
        OS.patch_start(0xCFC80, 0x80155240)
        j       dsp_absorption_turnaround_prevent
        lwc1    f6, 0xC610(at)      // og line 2
        _return:
        OS.patch_end()
        
        lw      at, 0x0008(v0)      // at = character id
        addiu   t9, r0, Character.id.LUCAS
        beq     at, t9, _continue
        nop

        // normal
        sw      t8, 0x0044(v0)     // og line 1, update characters facing direction

        _continue:
        j       _return
        nop
    }

    // @ Description
    // Fixes the position of the down special absorption radius for Lucas by creating a new struct.
    scope dsp_absorption_position_fix_: {
        OS.patch_start(0xD0178, 0x80155738)
        j       dsp_absorption_position_fix_
        nop
        _return:
        OS.patch_end()

        // v1 = player struct
        lw      t4, 0x0008(v1)              // t4 = character id
        ori     t7, r0, Character.id.LUCAS  // t7 = id.LUCAS
        bnel    t4, t7, _end                // skip if character id != LUCAS
        addu    t7, t5, t6                  // original line 1

        _lucas:
        li      t7, psi_magnet_struct_lucas

        _end:
        sw      t7, 0x0850(v1)              // original line 2
        j       _return
        nop
    }

	// @ Description
    // Increases Lucas PSI Magnet recovery to 2.5x.
    scope psi_magnet_multiplier_: {
        OS.patch_start(0x5EBB4, 0x800E33B4)
        j       psi_magnet_multiplier_
        cvt.s.w		f0, f8			// original line 1
        _return:
        OS.patch_end()

		addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
		swc1    f2, 0x000C(sp)              // store f1
		lw		t1, 0x0008(s0)				// load character ID into t1
		ori     t2, r0, Character.id.LUCAS  // load Lucas Character ID into t2
		add.s	f10, f0, f0					// original line 2, this is what doubles Ness recovery
		bne		t1, t2, _end				// skip Lucas multipier if not lucas
		nop
		lui		t1, 0x4020
		mtc1	t1, f2
		mul.s	f10, f0, f2

		_end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
		lwc1	f2, 0x000C(sp)				// load f1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return
        nop
    }

    OS.align(16)
    psi_magnet_struct_lucas:

    dw      0x00000001
    dw      0x00000000
    float32 0           // x position
    float32 300         // y position
    float32 350         // z position
    float32 300         // scale 1
    float32 300         // scale 2
    float32 300         // scale 3
}
