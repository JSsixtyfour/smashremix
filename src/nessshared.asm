// Nessshared.asm

// This file contains shared functions by Ness Clones.

scope NessShared {

    // @ Description
    // loads a different pointer for Ness clones/Kirby when spawning pkfire graphic.
    scope get_pkfire_pointer_: {
        OS.patch_start(0xE56D0, 0x8016AC90)
        j       get_pkfire_pointer_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lui     t2, 0x8019                  // the projectile struct is at a hard coded location
        addiu   t2, t2, 0xCFF0              // see above
        lw      t2, 0x0000(t2)              // see above
        sw      s1, 0x0078(t2)              // save player struct into projectile struct for pkfire2
        li      a1, pkfire1_struct          // save new struct new address into a1
        lw      t1, 0x0008(s1)              // load current character ID into t1

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power

        ori     t2, r0, Character.id.JNESS  // t1 = id.JNESS
        beq     t1, t2, _end                // end if character id = JNESS
        nop
        li      a1, pkfire1_struct_lucas    // save new struct new address into a1
        ori     t2, r0, Character.id.LUCAS  // t1 = id.LUCAS
        beq     t1, t2, _end                // end if character id = JNESS
        nop
        lui     a1, 0x8019                  // original line 1
        addiu   a1, a1, 0x9190              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        lui     a3, 0x8000                  // original line 3
    }

    // @ Description
    // Loads a different pointer when for Ness clones/Kirby when pkfire collides.
    // This subroutine eventually leads to a generic "spawn object" or spawn function of some kind that is in the least by
    // Link for bombs, the spawning of items and Peach's Castle (probably for bumper).
    // this spawn object routine uses a struct, this code puts in an alternate one for JNess
    scope get_pkfire_collision_pointer_: {
        OS.patch_start(0x100288, 0x80185848)
        j       get_pkfire_collision_pointer_
        nop
        _return:
        OS.patch_end()

        addiu   a1, a1, 0xB640              // original line 1
        sw      t6, 0x0010(sp)              // original line 2

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store registers
        sw      t2, 0x0008(sp)              // ~
        sw      t3, 0x000C(sp)              // ~

        lw      t3, 0x0078(v0)              // load player struct from projectile struct that we placed in pkfire1
        lw      t1, 0x0008(t3)              // load current character ID into t1

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(t3)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(t3)              // t1 = character id of copied power

        ori     t2, r0, Character.id.NESS   // t2 = id.NESS
        beq     t1, t2, _end                // end if character id = NESS
        nop
        li      a1, pkfire2_struct          // JNess File Pointer placed in correct location
        ori     t2, r0, Character.id.JNESS  // t2 = id.JNESS
        beq     t1, t2, _end                // end if character id = JNESS
        nop
        li      a1, pkfire2_struct_lucas    // Lucas File Pointer placed in correct location

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // ~
        lw      t3, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }

    OS.align(16)
    pkfire1_struct:
    dw 0x00000000
    dw 0x0000000D
    dw Character.JNESS_file_7_ptr
    //TODO: figure out how long this struct actually is
    OS.copy_segment(0x103BDC, 0x50)

    OS.align(16)
    pkfire1_struct_lucas:
    dw 0x00000000
    dw 0x0000000D
    dw Character.LUCAS_file_7_ptr
    //TODO: figure out how long this struct actually is
    OS.copy_segment(0x103BDC, 0x50)

    OS.align(16)
    pkfire2_struct:
    dw 0x00000014
    dw Character.JNESS_file_7_ptr
    //TODO: figure out how long this struct actually is
    OS.copy_segment(0x106088, 0xF8)

    OS.align(16)
    pkfire2_struct_lucas:
    dw 0x00000014
    dw Character.LUCAS_file_7_ptr
    //TODO: figure out how long this struct actually is
    OS.copy_segment(0x106088, 0xF8)

    // character ID check add for when Ness/Lucas perform their unique double jump
    scope ness_jump1_: {
        OS.patch_start(0xBA848, 0x8013FE08)
        j       ness_jump1_
        nop
        _return:
        OS.patch_end()

        addiu   at, r0, 0x000B              // original line 1
        beq     v0, at, special_jump        // original line 2
        lui     t2, 0x8014                  // original line 3
        addiu   at, r0, Character.id.JNESS  // JNess Character ID
        beq     v0, at, special_jump
        nop
        addiu   at, r0, Character.id.LUCAS  // Lucas Character ID
        beq     v0, at, special_jump
        nop
        addiu   at, r0, Character.id.MTWO   // Mewtwo Character ID
        beq     v0, at, special_jump
        nop
        j       _return                     // return
        nop

        special_jump:
        j       0x8013FE20
        nop
    }

    // character ID check2 add for when Ness/Lucas perform their unique double jump
    scope ness_jump2_: {
        OS.patch_start(0xBA8C0, 0x8013FE80)
        j       ness_jump2_
        nop
        _return:
        OS.patch_end()

        swc1    f10, 0x004C(s0)
        addiu   at, r0, Character.id.JNESS  // JNess Character ID
        beq     v0, at, special_jump        // jump to special jump
        nop
        addiu   at, r0, Character.id.NESS   // Ness Character ID
        beq     v0, at, special_jump        // jump to special jump
        nop
        addiu   at, r0, Character.id.LUCAS  // Lucas Character ID
        beq     v0, at, special_jump        // jump to special jump
        nop
        addiu   at, r0, Character.id.MTWO   // Mewtwo Character ID
        beq     v0, at, special_jump
        nop
        j       _return                     // return
        nop

        special_jump:
        j       0x8013FE94
        nop
    }

    // @ Description
    // Patch which loads an alternate up special landing FSM for Ness variants.
    scope up_special_landing_fsm_: {
        constant LANDING_FSM_JNESS(0x3E75C28F) // float: 0.24
        constant LANDING_FSM_LUCAS(0x3E99999A) // float: 0.3

        OS.patch_start(0xCEE54, 0x80154414)
        j       up_special_landing_fsm_
        sw      t6, 0x0010(sp)              // original line 2
        _return:
        OS.patch_end()

        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0008(t6)              // t6 = character id
        ori     t7, r0, Character.id.JNESS  // t7 = id.JNESS
        li      t8, LANDING_FSM_JNESS       // t8 = LANDING_FSM_JNESS
        beq     t6, t7, _end                // branch if character id = JNESS
        ori     t7, r0, Character.id.LUCAS  // t7 = id.LUCAS
        li      t8, LANDING_FSM_LUCAS       // t8 = LANDING_FSM_LUCAS
        beq     t6, t7, _end                // branch if character id = LUCAS
        nop

        // load default landing FSM when no variant is detected
        lw      t8, 0xC5B0(at)              // t8 = ness upb landing fsm (modified original line 1)

        _end:
        j       _return                     // return
        mtc1    t8, f8                      // f8 = landing fsm
    }

    // Changes the speed of JNess Projectile to match that of the Japanese Version
    // The speed is in floating point
    scope pkfire_ground_speed_1_: {
        // Ness (and clones)
        OS.patch_start(0xCE49C, 0x80153A5C)
        jal     pkfire_ground_speed_1_
        nop
        OS.patch_end()
        // Kirby (and clones)
        OS.patch_start(0xD0688, 0x80155C48)
        jal     pkfire_ground_speed_1_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lui     at, 0x42B4                  // JNess PK Fire Speed
        lw      t0, 0x0008(v0)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(v0)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(v0)              // t0 = character id of copied power

        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        beq     t0, t1, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.JNESS
        beq     t0, t1, _end                // end if character id = JNESS
        nop

        lui     at, 0x4292                  // original line 1 (Ness U Speed)

        _end:
        mtc1    at, f18                     // original line 2
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // Changes the speed of JNess Projectile to match that of the Japanese Version
    // The speed is in floating point
    scope pkfire_ground_speed_2_: {
        // Ness (and clones)
        OS.patch_start(0xCE4C8, 0x80153A88)
        jal     pkfire_ground_speed_2_
        nop
        OS.patch_end()
        // Kirby (and clones)
        OS.patch_start(0xD06B4, 0x80155C74)
        jal     pkfire_ground_speed_2_
        nop
        OS.patch_end()

        begin:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lui     at, 0x42B4                  // JNess PK Fire Speed
        lw      t0, 0x0008(s1)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power

        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        beq     t0, t1, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        beq     t0, t1, _end                // end if character id = LUCAS
        nop

        lui     at, 0x4292                  // original line 1 (Ness U Speed)

        _end:
        mtc1    at, f16                     // original line 2
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // Changes the speed of JNess Projectile to match that of the Japanese Version
    // The speed is in floating point
    scope pkfire_air_speed_1_: {
        // Ness (and clones)
        OS.patch_start(0xCE43C, 0x801539FC)
        jal     pkfire_air_speed_1_
        nop
        OS.patch_end()
        // Kirby (and clones)
        OS.patch_start(0xD0628, 0x80155BE8)
        jal     pkfire_air_speed_1_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lui     at, 0x42F0                  // JNess PK Fire Speed
        lw      t0, 0x0008(v0)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(v0)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(v0)              // t0 = character id of copied power

        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        beq     t0, t1, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.JNESS
        beq     t0, t1, _end                // end if character id = JNESS
        nop

        lui     at, 0x42BE                  // original line 1 (Ness U Speed)

        _end:
        mtc1    at, f16                     // original line 2
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // Changes the speed of JNess Projectile to match that of the Japanese Version
    // The speed is in floating point
    scope pkfire_air_speed_2_: {
        // Ness (and clones)
        OS.patch_start(0xCE468, 0x80153A28)
        jal     pkfire_air_speed_2_
        nop
        OS.patch_end()
        // Kirby (and clones)
        OS.patch_start(0xD0654, 0x80155C14)
        jal     pkfire_air_speed_2_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lui     at, 0x42F0                  // JNess PK Fire Speed
        lw      t0, 0x0008(s1)              // t0 = character id

        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t0, t1, pc() + 8            // if Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t0, t1, pc() + 8            // if J Kirby, get held power character_id
        lw      t0, 0x0ADC(s1)              // t0 = character id of copied power

        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        beq     t0, t1, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.JNESS
        beq     t0, t1, _end                // end if character id = JNESS
        nop

        lui     at, 0x42BE                  // original line 1 (Ness U Speed)

        _end:
        mtc1    at, f8                      // original line 2
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // Load Up Special from different struct
    // found via setting breakpoint at 800FD778
    // Location of original struct 8012E494
    // @ Description
    // loads a different animation struct when JNess uses the first graphic animation in his up special.
    scope get_pkthunder_anim_struct_: {
        OS.patch_start(0x7E208, 0x80102A08)
        j       get_pkthunder_anim_struct_
        nop
        _return:
        OS.patch_end()

        // v1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(v1)              // t0 = character id
        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        li      a0, pkthunder_anim_struct   // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a0, pkthunder_anim_struct_lucas   // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = LUCAS
        nop
        li      a0, 0x8012E494              // original line 1/3 (load pk thunder animation struct)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    // This little beauty of a hardcode seems to only find use when PK thunder is reflected by our boy Fox (or Falco) and Ness
    // @ Description
    // loads a different animation struct when JNess or Lucas call upon this.
    scope get_pkthunder_anim_struct2_: {
        OS.patch_start(0x7E178, 0x80102978)
        j       get_pkthunder_anim_struct2_
        nop
        _return:
        OS.patch_end()

        // t7 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lui     t0, 0x8019
        addiu   t0, t0, 0xCFF0              // This is some kind of hardcoded location for the projectile struct
        lw      t0, 0x0010(t0)
        lw      t0, 0x0008(t0)              // load character ID from projectile struct
        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        li      a0, pkthunder_anim_struct2  // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a0, pkthunder_anim_struct2_lucas  // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = LUCAS
        nop
        lui     a0, 0x8013                  // original line 1
        addiu   a0, a0, 0xE46C              // original line 2

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    // Load Up Special from different struct
    // found via setting breakpoint at 800FD778
    // Location of original struct 8012E444
    // @ Description
    // loads a different animation struct when JNess uses the third graphic animation in his up special.
    scope get_pkthunder_anim_struct3_: {
        OS.patch_start(0x7E058, 0x80102858)
        j       get_pkthunder_anim_struct3_
        nop
        _return:
        OS.patch_end()

        // t7 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0008(t7)              // t0 = character id
        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        li      a0, pkthunder_anim_struct3  // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a0, pkthunder_anim_struct3_lucas  // a0 = pkthunder_anim_struct
        beq     t0, t1, _end                // end if character id = LUCAS
        nop
        li      a0, 0x8012E444              // original line (load pk thunder animation struct)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    // Load Up Special Functionality from different struct
    // Location of original subroutine 801655C8
    // @ Description
    // loads a different special struct1 when JNess uses his up special.
    scope get_pkthunder_special_struct1_: {
        OS.patch_start(0xE5D1C, 0x8016B2DC)
        j       get_pkthunder_special_struct1_
        nop
        _return:
        OS.patch_end()

        // 0x0050(sp) = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // store t0, t1
        lw      t0, 0x0084(a0)
        lw      t0, 0x0008(t0)
        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        li      a1, pkthunder_special_struct1  // a1 = pkthunder_special_struct
        beq     t1, t0, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a1, pkthunder_special_struct1_lucas  // a1 = pkthunder_special_struct
        beq     t1, t0, _end                // end if character id = LUCAS
        nop
        lui     a1, 0x8019              // original line
        addiu   a1, a1, 0x91D0           // original line

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        sw      a0, 0x0018(sp)              // original line
        j       _return                     // return
        nop
    }

    // Load Up Special Functionality from different struct
    // Location of original subroutine 801655C8
    // @ Description
    // loads a different special struct2 when JNess uses his up special.
    scope get_pkthunder_special_struct2_: {
        OS.patch_start(0xE5FD8, 0x8016B598)
        j       get_pkthunder_special_struct2_
        nop
        _return:
        OS.patch_end()

        // 0x0050(sp) = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lw      t2, 0x01B4(t0)            // load player struct from projectile struct
        lw      t2, 0x0008(t2)
        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        li      a1, pkthunder_special_struct2  // a1 = pkthunder_special_struct
        beq     t1, t2, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a1, pkthunder_special_struct2_lucas  // a1 = pkthunder_special_struct
        beq     t1, t2, _end                // end if character id = LUCAS
        nop
        lui     a1, 0x8019                  // original line
        addiu   a1, a1, 0x9204              // original line

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    // Load Up Special Functionality from different struct for reflects
    // @ Description
    // loads a different reflect struct1 when JNess uses his up special and its reflected.
    scope get_pkthunder_reflect_struct1_: {
        OS.patch_start(0xE62FC, 0x8016B8BC)
        j       get_pkthunder_reflect_struct1_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lui     t1, 0x8019
        addiu   t1, t1, 0xCFF0              // This is some kind of hardcoded location for the projectile struct
        lw      t2, 0x0000(v1)              // load player struct from projectile struct. The parent struct to the projectile struct is here and you just go down till you get there.
        lw      t2, 0x0000(t2)              // load player struct from projectile struct
        lw      t2, 0x01B4(t2)              // load player struct from projectile struct
        sw      t2, 0x0010(t1)              // save playerstruct to magic struct. This struct is hardcoded, always in the same spot and can be loaded from whenever.
        lw      t2, 0x0008(t2)              // load character ID from projectile struct
        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        li      a1, pkthunder_reflect_struct1  // a1 = pkthunder_special_struct
        beq     t1, t2, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a1, pkthunder_reflect_struct1_lucas  // a1 = pkthunder_special_struct
        beq     t1, t2, _end                // end if character id = LUCAS
        nop
        lui     a1, 0x8019                  // original line
        addiu   a1, a1, 0x9238              // original line


        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x801655C8
        nop
        j       _return                     // return
        nop
    }

    // Load Up Special Functionality from different struct for reflects
    // @ Description
    // loads a different reflect struct2 when JNess uses his up special and its reflected.
    scope get_pkthunder_reflect_struct2_: {
        OS.patch_start(0xE65CC, 0x8016BB8C)
        j       get_pkthunder_reflect_struct2_
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        or      s0, a0, r0                  // original line 1
        lui     t2, 0x8019
        addiu   t2, t2, 0xCFF0              // This is some kind of hardcoded location for the projectile struct
        lw      t2, 0x0010(t2)
        lw      t2, 0x0008(t2)              // load character ID from projectile struct
        ori     t1, r0, Character.id.JNESS  // t1 = id.JNESS
        li      a1, pkthunder_reflect_struct2  // a1 = pkthunder_special_struct
        beq     t1, t2, _end                // end if character id = JNESS
        nop
        ori     t1, r0, Character.id.LUCAS  // t1 = id.LUCAS
        li      a1, pkthunder_reflect_struct2_lucas  // a1 = pkthunder_special_struct
        beq     t1, t2, _end                // end if character id = LUCAS
        nop
        lui     a1, 0x8019                  // original lineish
        addiu   a1, a1, 0x926C              // original line 2


        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     _return                     // return
        nop
    }

    // @ Description
    // Patch which adds Ness behaviour for CPU up special usage.
    scope cpu_usp_usage_fix_: {
        OS.patch_start(0xAF170, 0x80134730)
        j       cpu_usp_usage_fix_
        nop
        _return:
        OS.patch_end()

        // v0 = character id, at = Character.id.NESS
        beq     v0, at, _branch_return      // branch if character id = NESS (original line 1)
        ori     at, r0, Character.id.JNESS  // at = id.JNESS
        beq     v0, at, _branch_return      // branch if character id = JNESS
        ori     at, r0, Character.id.LUCAS  // at = id.LUCAS
        beq     v0, at, _branch_return      // branch if character id = LUCAS
        nop

        _ness:
        // return normally when character is not NESS, JNESS, or LUCAS
        j       _return                     // return
        addiu   at, r0, 0x001A              // original line 2

        _branch_return:
        j       0x80134754                  // returns to original branch location
        addiu   at, r0, 0x001A              // original line 2
    }

    // @ Description
    // Patch which adds Ness behaviour for CPU up special control control.
    scope cpu_usp_control_fix_: {
        OS.patch_start(0xB1BA0, 0x80137160)
        j       cpu_usp_control_fix_
        nop
        _return:
        OS.patch_end()

        // a0 = character id, at = Character.id.NESS
        beq     a0, at, _ness               // branch if character id = NESS
        ori     at, r0, Character.id.JNESS  // at = id.JNESS
        beq     a0, at, _ness               // branch if character id = JNESS
        ori     at, r0, Character.id.LUCAS  // at = id.LUCAS
        bnel    a0, at, _branch_return      // branch if character id != LUCAS (modified original line 1)
        lw      t2, 0x014C(a2)              // original line 2

        _ness:
        // return normally when character is NESS, JNESS, or LUCAS
        j       _return                     // return
        lw      t2, 0x014C(a2)              // original line 2

        _branch_return:
        j       0x8013723C                  // returns to original branch location
        nop
    }

    // 8016B598

    OS.align(16)
    pkthunder_anim_struct:
    dw  0x060F0000
    dw  Character.JNESS_file_4_ptr
    OS.copy_segment(0xA9C9C, 0x8)
    dw  Size.ness.usp.update_routine_._update // allows scaling usp head gfx
    OS.copy_segment(0xA9CA8, 0x14)

    OS.align(16)
    pkthunder_anim_struct_lucas:
    dw  0x060F0000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C9C, 0x8)
    dw  Size.ness.usp.update_routine_._update // allows scaling usp head gfx
    OS.copy_segment(0xA9CA8, 0x4)
    dw  0x0000AC78
	dw  0x0000ADB8
	dw  0x0000AEA8
	dw  0x0000AF60

    // the dw like above may need changed for every model revision for anim structs

    OS.align(16)
    pkthunder_anim_struct2:
    dw  0x02120000
    dw  Character.JNESS_file_4_ptr
    OS.copy_segment(0xA9C74, 0x20)

    OS.align(16)
    pkthunder_anim_struct2_lucas:
    dw  0x02120000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C74, 0x10)
    dw  0x0000B068
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000

    OS.align(16)
    pkthunder_anim_struct3:
    dw  0x020F0000
    dw  Character.JNESS_file_4_ptr
    OS.copy_segment(0xA9C4C, 0x20)

    // The anim structs are different because the numbers get updated when a new model is added via sub's import system

    OS.align(16)
    pkthunder_anim_struct3_lucas:
    dw  0x020F0000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C4C, 0x10)
    dw  0x0000B068
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000

    OS.align(16)
    pkthunder_special_struct1:
    dw 0x03000000
    dw 0x0000000E
    dw Character.JNESS_file_1_ptr
    OS.copy_segment(0x103C1C, 0x28)

    OS.align(16)
    // uses hit detection subroutine from tail projectile to prevent destruction on hit
    pkthunder_special_struct1_lucas:
    dw 0x03000000
    dw 0x0000000E
    dw Character.LUCAS_file_1_ptr
    dw 0x0000000C
    dw 0x122E0000
    dw 0x8016AEA8
    dw 0x8016B198
    dw 0x8016B550                           // hurtbox collision, originally 0x8016B1E8
    dw 0x8016B1E8                           // unknown collision
    dw 0x00000000
    dw 0x8016B1E8                           // hitbox collision
    dw 0x8016B22C
    dw 0x8016B1E8                           // unknown collision

    OS.align(16)
    pkthunder_special_struct2:
    dw 0x02000000
    dw 0x0000000F
    dw Character.JNESS_file_1_ptr
    OS.copy_segment(0x103C50, 0x28)

    OS.align(16)
    pkthunder_special_struct2_lucas:
    dw 0x02000000
    dw 0x0000000F
    dw Character.LUCAS_file_1_ptr
    OS.copy_segment(0x103C50, 0x28)

    OS.align(16)
    pkthunder_reflect_struct1:
    dw 0x03000000
    dw 0x0000000E
    dw Character.JNESS_file_1_ptr
    OS.copy_segment(0x103C84, 0x28)

    OS.align(16)
    pkthunder_reflect_struct1_lucas:
    dw 0x03000000
    dw 0x0000000E
    dw Character.LUCAS_file_1_ptr
    OS.copy_segment(0x103C84, 0x28)

    OS.align(16)
    pkthunder_reflect_struct2:
    dw 0x02000000
    dw 0x0000000F
    dw Character.JNESS_file_1_ptr
    OS.copy_segment(0x103CB8, 0x28)

    OS.align(16)
    pkthunder_reflect_struct2_lucas:
    dw 0x02000000
    dw 0x0000000F
    dw Character.LUCAS_file_1_ptr
    OS.copy_segment(0x103CB8, 0x28)

    OS.align(16)
    pkfire_anim_struct:
    dw 0x0000000D
    dw Character.JNESS_file_7_ptr
    OS.copy_segment(0x106088, 0x20)

    OS.align(16)
    pkfire_anim_struct_lucas:
    dw 0x0000000D
    dw Character.LUCAS_file_7_ptr
    OS.copy_segment(0x106088, 0x20)


    // establishes a pointer to the character struct that can be used for a character id check during
    // special_struct3.
    scope get_pkthunder_playerstruct1_: {
        OS.patch_start(0xE597C, 0x8016AF3C)
        j       get_pkthunder_playerstruct1_
        nop
        _return:
        OS.patch_end()
        sw      a2, 0x01B4(a3)              // save playerstruct to unused space in projectile struct
        jal     0x8016AE64                  // original code
        sw      a3, 0x0054(sp)              // original code
        j       _return                     // return
        nop
    }

    // 8028B064
    // from 8028AEB0

    // establishes a pointer to the character struct that can be used for a character id check during
    // special_struct3.
    scope get_pkthunder_playerstruct2_: {
        OS.patch_start(0xE5E10, 0x8016B3D0)
        j       get_pkthunder_playerstruct2_
        nop
        _return:
        OS.patch_end()
        sw      a0, 0x01B4(a2)              // save player struct to unused space in projectile struct
        sll     t1, t0, 1                   // original code
        lw      t9, 0x0AE0(a0)              // original line 2
        j       _return                     // return
        nop
    }

    // establishes a pointer to the character struct that can be used for a character id check during
    // special_struct3.
    scope get_pkthunder_playerstruct3_: {
        OS.patch_start(0xCE724, 0x80153CE4)
        j       get_pkthunder_playerstruct3_
        lw      t7, 0x0034(sp)              // original line 1
        _return:
        OS.patch_end()

        lw      t6, 0x0000(v1)              // load projectile struct
        lw      t6, 0x0000(t6)              // load projectile struct
        sw      t7, 0x01B4(t6)              // save player struct to unused space in projectile code

        j       _return                     // return
        sw      v0, 0x0B24(t7)              // original line 2
    }

    // @ Description
    // Adds reflection to forward smash for Ness clones. (1/3)
    // Not sure what this check is for, runs when intiating the fsmash, resets temp variable 2 if
    // the character is Ness.
    scope reflect_fix_1_: {
        OS.patch_start(0xCAB60, 0x80150120)
        j       reflect_fix_1_
        nop
        _return:
        OS.patch_end()
        // at = id.NESS
        // v0 = character id
        //beq   v0, at, 0x8015014C          // original line 1
        //addiu at, r0, 0x0017              // original line 2
        beq     v0, at, _ness               // branch if character = NESS
        ori     at, r0, Character.id.JNESS  // at = id.JNESS
        beq     v0, at, _ness               // branch if character = JNESS
        ori     at, r0, Character.id.LUCAS  // at = id.LUCAS
        beq     v0, at, _ness               // branch if character = LUCAS
        nop

        _end:
        j       _return                     // return; don't branch
        addiu   at, r0, 0x0017              // original line 2

        _ness:
        j       0x8015014C                  // return; branch
        addiu   at, r0, 0x0017              // original line 2
    }

    // @ Description
    // Adds reflection to forward smash for Ness clones. (2/3)
    // This check runs when intiating the fsmash, reflecting will crash if it fails.
    scope reflect_fix_2_: {
        OS.patch_start(0xCABBC, 0x8015017C)
        j       reflect_fix_2_
        lui     t2, 0x8013                  // original line 2
        _return:
        OS.patch_end()
        // at = id.NESS
        // v0 = character id
        //beq   v0, at, 0x801501B8          // original line 1
        //lui   t2, 0x8013                  // original line 2
        beq     v0, at, _ness               // branch if character = NESS
        ori     at, r0, Character.id.JNESS  // at = id.JNESS
        beq     v0, at, _ness               // branch if character = JNESS
        ori     at, r0, Character.id.LUCAS  // at = id.LUCAS
        beq     v0, at, _ness               // branch if character = LUCAS
        nop

        _end:
        j       _return                     // return; don't branch
        nop

        _ness:
        j       0x801501B8                  // return; branch
        nop
    }

    // @ Description
    // Adds reflection to forward smash for Ness clones. (3/3)
    // This check runs once per frame during the fsmash, checking for the actual clang/reflection.
    scope reflect_fix_3_: {
        OS.patch_start(0xCA8A0, 0x8014FE60)
        j       reflect_fix_3_
        nop
        _return:
        OS.patch_end()
        // at = id.NESS
        // v0 = character id
        //beq   v0, at, 0x8014FF78          // original line 1
        //addiu at, r0, 0x0017              // original line 2
        beq     v0, at, _ness               // branch if character = NESS
        ori     at, r0, Character.id.JNESS  // at = id.JNESS
        beq     v0, at, _ness               // branch if character = JNESS
        ori     at, r0, Character.id.LUCAS  // at = id.LUCAS
        beq     v0, at, _ness               // branch if character = LUCAS
        nop

        _end:
        j       _return                     // return; don't branch
        addiu   at, r0, 0x0017              // original line 2

        _ness:
        j       0x8014FF78                  // return; branch
        addiu   at, r0, 0x0017              // original line 2
    }

}
