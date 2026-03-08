// Nessshared.asm

// This file contains shared functions by Ness Clones.

scope NessShared {

    // @ Description
    // Fix PK Thunder reflect crashing 2
    scope pk_thunder_reflect_crash_fix_1_: {
        OS.patch_start(0xE6280, 0x8016B840)
        j       pk_thunder_reflect_crash_fix_1_
        addiu   sp, sp, -0x18       // og line 1
        _return:
        OS.patch_end()

        sw      ra, 0x0014(sp)      // og line 2

        Toggles.read(entry_pk_thunder_reflect_crash_fix, at) // at = toggle
        beqz    at, _normal         // branch if toggle is disabled
        nop

        // fixed
        jal     0x8016B6A0          // Mark trail objects as 'discarded' on reflection
        sw      a0, 0x0018(sp)      // store a0 (weapon_gobj)
        lw      a0, 0x0018(sp)      // restore a0

        _normal:
        j       _return
        nop

    }

    // @ Description
    // Fix PK Thunder reflect crashing 2
    scope pk_thunder_reflect_crash_fix_2_: {
        OS.patch_start(0xE6640, 0x8016BC00)
        j       pk_thunder_reflect_crash_fix_2_
        nop
        _return:
        OS.patch_end()

        Toggles.read(entry_pk_thunder_reflect_crash_fix, at) // at = toggle
        beqz    at, _normal         // branch if toggle is disabled
        nop

        _fixed:
        lwc1    f14, 0x20(t0)       //
        swc1    f14, 0x20(v1)       //
        lwc1    f12, 0x24(t0)       //
        swc1    f12, 0x24(v1)       //
        jal     0x8001863C          // Get tangent of velocity; same method used by DamageFlyRoll to calculate model rotation
        sw      a0, 0x002C(sp)      //

        lw      a0, 0x002C(sp)      //
        lw      t3, 0x0074(a0)      //
        lui     at, 0x8019          // og line 2
        lwc1    f6, 0xCB18(at)      // Get M_PI / 2
        sub.s   f0, f0, f6          // The PK Thunder trail model's rotation is, by default, situated vertically at 90 degrees; subtract 90 degrees to get the correct rotation
        j       0x8016BC2C          // return to original routine
        swc1    f0, 0x0038(t3)      //

        // bugged version
        _normal:
        lwc1    f4, 0x0020(t0)      // og line 1
        j       _return
        lui     at, 0x8019          // og line 2

    }



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
        lw      t3, 0x0000(t2)              // t3 = projectile struct
        li      a1, pkfire1_struct          // save new struct new address into a1
        lw      t1, 0x0008(s1)              // load current character ID into t1

        lli     t2, Character.id.KIRBY      // t2 = id.KIRBY
        beql    t1, t2, pc() + 8            // if Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power
        lli     t2, Character.id.JKIRBY     // t2 = id.JKIRBY
        beql    t1, t2, pc() + 8            // if J Kirby, get held power character_id
        lw      t1, 0x0ADC(s1)              // t1 = character id of copied power

        sw      t1, 0x0078(t3)              // save character id into projectile struct for pkfire2
        ori     t2, r0, Character.id.JNESS  // t1 = id.JNESS
        beq     t1, t2, _end                // end if character id = JNESS
        nop
        li      a1, pkfire1_struct_lucas    // save new struct new address into a1
        ori     t2, r0, Character.id.LUCAS  // t1 = id.LUCAS
        beq     t1, t2, _end                // end if character id = LUCAS
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

        lw      t1, 0x0078(v0)              // load character ID from projectile struct that we placed in pkfire1
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

    // @ Description
    // Set special Jump2 physics for Ness
    Character.table_patch_start(ness_jump, Character.id.NESS, 0x1)
    db      OS.TRUE;     OS.patch_end();
    // Set special Jump2 physics for Polygon Ness
    Character.table_patch_start(ness_jump, Character.id.NNESS, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // character ID check add for when Ness/Lucas perform their unique double jump
    scope ness_jump1_: {
        OS.patch_start(0xBA848, 0x8013FE08)
        j       ness_jump1_
        nop
        _return:
        OS.patch_end()

        li      at, Character.ness_jump.table
        addu    t2, v0, at                  // t2 = entry in ness_jump.table
        lb      t2, 0x0000(t2)              // load characters entry in jump table
        bnez    t2, _special_jump           // do special jump if not defined in the above table
        nop

        // if here, then character has special ness jump
        // addiu   at, r0, 0x000B              // original line 1
        // beq     v0, at, _special_jump       // original line 2

        _normal_jump:
        j       _return                     // return
        lui     t2, 0x8014                  // original line 3

        _special_jump:
        j       0x8013FE20
        lui     t2, 0x8014                  // original line 3
    }

    // character ID check2 add for when Ness/Lucas perform their unique double jump
    scope ness_jump2_: {
        OS.patch_start(0xBA8C0, 0x8013FE80)
        j       ness_jump2_
        nop
        _return:
        OS.patch_end()

        swc1    f10, 0x004C(s0)

        li      at, Character.ness_jump.table
        addu    t2, v0, at                  // t2 = entry in ness_jump.table
        lb      t2, 0x0000(t2)              // load characters entry in jump table
        bnezl   t2, _special_jump           // do special jump if not defined in the above table
        nop

        j       _return                     // return
        nop

        _special_jump:
        j       0x8013FE94
        nop
    }

    // @ Description
    // Patch which loads an alternate up special landing FSM for Ness variants.
    scope up_special_landing_fsm_: {
        constant LANDING_FSM_JNESS(0x3E75C28F) // float: 0.24
        constant LANDING_FSM_LUCAS(0x3E99999A) // float: 0.3
        constant AIR_SPEED_MULTIPLIER_NESS(0x3F19999A) // float: 0.600000023842
        constant AIR_SPEED_MULTIPLIER_LUCAS(0x3F52) // float: 0.8203125

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
        beq     t6, t7, _lucas              // branch if character id = LUCAS
        nop

        // load default landing FSM when no variant is detected
        lw      t8, 0xC5B0(at)              // t8 = ness upb landing fsm (modified original line 1)

        _end:
        j       _return                     // return
        mtc1    t8, f8                      // f8 = landing fsm

        _lucas:
        lui     a1, AIR_SPEED_MULTIPLIER_LUCAS
        j       _return                     // return
        mtc1    t8, f8                      // f8 = landing fsm

    }

    // @ Description
    // Patch to load the correct delay to wait before transitioning to PKThunderEnd.
    scope up_special_ending_delay_: {
        constant ENDING_DELAY_JNESS(0x14)   // integer: 20

        OS.patch_start(0xCEA18, 0x80153FD8)
        j       up_special_ending_delay_
        sw      v1, 0x0B18(v0)              // original line 1
        _return:
        OS.patch_end()

        lw      t0, 0x0008(v0)              // Get fighter kind
        addiu   at, r0, Character.id.JNESS  // at = JNESS fighter kind
        beql    at, t0, _store_delay        // Check if character is JNESS
        addiu   v1, r0, ENDING_DELAY_JNESS  // If JNESS, load J version delay

        _store_delay:
        j       _return
        sw      v1, 0xB1C(v0)               // original line 2
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

    // 80185824+50
    // Establishes a pointer to the character struct that can be used for a character id check
    // for J Ness' PK Fire pillar
    scope get_pillar_playerstruct_: {
        OS.patch_start(0x1002B4, 0x80185874)
        j       get_pillar_playerstruct_
        lbu     t8, 0x02CE(s0)              // original line 2
        _return:
        OS.patch_end()

        // v1 = projectile struct
        // s0 = item struct
        lw      t7, 0x0078(v1)              // load character ID from projectile struct, set in get_pkfire_pointer_
        sw      t7, 0x0354(s0)              // save character ID to unused space in item struct

        j       _return                     // return
        lw      t7, 0x0008(v1)              // original line 1
    }
    
    // 80185614+28
    scope pkfire_pillar_gravity_: {
        OS.patch_start(0x10007C, 0x8018563C)
        lw      a1, 0x0354(a0)              // load character ID from item struct, set in get_pillar_playerstruct_
        addiu   a1, a1, -Character.id.JNESS // ~
        jal     pkfire_pillar_gravity_      
        nop
        _return:
        OS.patch_end()
        
        constant U_ITPKFIRE_GRAVITY(0x3EE66666)     // float: 0.45F
        constant U_ITPKFIRE_TVEL(0x425C)            // float: 55F
        constant J_ITPKFIRE_GRAVITY(0x3ECCCCCD)     // float: 0.4F
        constant J_ITPKFIRE_TVEL(0x4248)            // float: 50F
        
        // a0 = item struct, a1 = gravity, a2 = terminal velocity
        beqzl   a1, _jness                  // take branch if J Ness
        lui     a1, J_ITPKFIRE_GRAVITY >> 16 // load upper 2 bytes of J_ITPKFIRE_GRAVITY

        li      a1, U_ITPKFIRE_GRAVITY      // otherwise, load U gravity (original line 1/2)
        j       0x80172558                  // modified original line 3
        lui     a2, U_ITPKFIRE_TVEL         // load U terminal velocity (original line 4)
        
        _jness:
        ori     a1, a1, J_ITPKFIRE_GRAVITY & 0xFFFF // load lower 2 bytes of J_ITPKFIRE_GRAVITY
        j       0x80172558                  // modified original line 3
        lui     a2, J_ITPKFIRE_TVEL         // load J terminal velocity
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
        lw      t2, 0x0084(a0)
        lw      t2, 0x02A4(t2)              // load original player object from projectile struct
        lw      t2, 0x0084(t2)              // load player struct from player object
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
    // Ness = 0x8012E494
    pkthunder_anim_struct_lucas:
    dw  0x060F0000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C9C, 0x8)
    dw  Size.ness.usp.update_routine_._update // allows scaling usp head gfx
    OS.copy_segment(0xA9CA8, 0x4)
    dw  0x000121B8
    dw  0x000122F8  // adjust coordinates at this offset to fix head gfx location
    dw  0x000123E8
    dw  0x000124A0

    // the dw like above may need changed for every model revision for anim structs

    OS.align(16)
    pkthunder_anim_struct2:
    dw  0x02120000
    dw  Character.JNESS_file_4_ptr
    OS.copy_segment(0xA9C74, 0x20)

    OS.align(16)
    // Ness = 0x8012E46C
    pkthunder_anim_struct2_lucas:
    dw  0x02120000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C74, 0x10)
    dw  0x000125A8
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
    // Ness = 0x8012E444
    pkthunder_anim_struct3_lucas:
    dw  0x020F0000
    dw  Character.LUCAS_file_4_ptr
    OS.copy_segment(0xA9C4C, 0x10)
    dw  0x000125A8
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
        ori     at, r0, Character.id.NLUCAS // at = id.NLUCAS
        beq     v0, at, _ness               // branch if character = NLUCAS
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
        ori     at, r0, Character.id.NLUCAS // at = id.NLUCAS
        beq     v0, at, _ness               // branch if character = NLUCAS
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
        ori     at, r0, Character.id.NLUCAS // at = id.NLUCAS
        beq     v0, at, _ness               // branch if character = NLUCAS
        nop

        _end:
        j       _return                     // return; don't branch
        addiu   at, r0, 0x0017              // original line 2

        _ness:
        j       0x8014FF78                  // return; branch
        addiu   at, r0, 0x0017              // original line 2
    }

	// @ Description
	// Adds Lucas and Jness to a character ID check allowing them to attack with USP.
	scope cpu_pk_thunder_attack_: {
		OS.patch_start(0xB344C, 0x80138A0C)
		j		cpu_pk_thunder_attack_
		addiu	at, r0, Character.id.NESS		// original line 1
		OS.patch_end()

		beq		at, a0, _pk_thunder				// branch if NESS
		addiu   at, r0, Character.id.LUCAS
		beq		at, a0, _pk_thunder				// branch if LUCAS
		addiu   at, r0, Character.id.JNESS
		bne		at, a0, _normal					// branch if not JNESS
		nop

		_pk_thunder:
		j		0x80138A6C
		nop

		_normal:
		j		0x80138A9C						// skip rest of routine if not Ness.
		lw		ra, 0x0014(sp)					// original

	}


	// @ Description
	// Replace the vanilla y offset for when Ness targets himself with PK Thunder
	scope improved_pk_thunder_: {
        OS.patch_start(0xB1C3C, 0x801371FC)
        j    improved_pk_thunder_
        nop
        _return:
        OS.patch_end()

		constant MULTIPLIER(0x4400)		// arbitrary
		constant LEDGE_Y_OFFSET(0x43FA) //(+25)
		constant MAX_VALUE(0x43FA)		// if return value is greater, Ness will miss himself.
		constant MAX_TIME(0x3B)			// If above this time, then crank the stick upwards.

		// safe registers f6, f8, f10
		// t3 = player coords

		lbu 	at, 0x0013(s0)				// at = cpu level
		slti	at, at, 10					// at = 0 if 10 or greater
		beqz    at, _fix					// improved PK thunder if lvl 10

		// Fix if Remix 1P
        addiu   v1, r0, 0x0004
        OS.read_word(SinglePlayerModes.singleplayer_mode_flag, at) // at = singleplayer mode flag
        beq     at, v1, _fix           		// if Remix 1p, automatic advanced ai

		// No fix if Vanilla 1P
        OS.read_word(Global.match_info, at)	// at = current match info struct
		lbu		at, 0x0000(at)
        lli     v1, Global.GAMEMODE.CLASSIC
        beq     v1, at, _normal         	// dont use toggle if vanilla 1P/RTTF

		// fix if improved AI is on
		OS.read_word(Toggles.entry_improved_ai + 0x4, at)	// check improved AI toggle
		beqz    at, _normal					// act normally if it is off

		_fix:
		lw      at, 0x001C(s0)			// at = current animation frame
		addiu   a0, r0, MAX_TIME
		bgt     at, a0, _normal			// crank stick upwards if above max time
		nop
        li		at, pk_thunder_target_coords
        lbu     a0, 0x000D(s0)          // a0 = port
        sll     a0, a0, 0x0002          // a0 = offset to player entry
        addu    at, at, a0              // a0 = coords entry

		lwc1	f6, 0x001C(t3)			// f6 = player.x
		lwc1	f14, 0x0000(at)			// f12 = target.x
		sub.s   f14, f14, f6
		abs.s   f14, f14				// make target coord absolute

		lwc1	f8, 0x0020(t3)			// f8 = player.y
		lwc1	f12, 0x0004(at)			// f14 = target.y
		sub.s   f12, f12, f8

		lui 	at, LEDGE_Y_OFFSET		//
        mtc1 	at, f8
		add.s   f12, f12, f8			// add y offset to target y value
		jal     0x8001863C 				// f0 = atan2(f12,f14)
		nop
		lui 	at, MULTIPLIER
        mtc1 	at, f8
		mul.s	f8, f8, f0				// f8 * multplier
		j		_return					// y offset =
		addiu   v1, s0, 0x01CC			// restore v1

        _normal:
		addiu   v1, s0, 0x01CC			// restore v1
        lui 	at, 0x42C8				// y offset = 100 original line 1
        j		_return
        mtc1 	at, f8

		// some return values to try later
		// C2C8 = -100 (starts going downwards)
		// C1C8 = -25 (he goes 0 deg, forwards)
		// 42C8 = 100 (vanilla)
		// 4348 = 200
		// 4396 = 300
		// 43C8 = 400
		// 43FA = 500 any higher than this it seems he misses himself
		// getting him to go 90 degress upwards or beyond would require more work
	}

	// 0x80137218 target opponent with PK Thunder

	// @ Description
	// Save the last known coordinates that CPU Ness wanted to recover towards.
	// Done when PK Thunder is created. Can probably play with this
	scope save_cpu_recovery_location_: {
		OS.patch_start(0xCE6E8, 0x80153CA8)
		j 		save_cpu_recovery_location_
		sw  	v0, 0x0034(sp)					// original line 4
		_return:
		OS.patch_end()

		// v0 = player struct
		li		at, pk_thunder_target_coords
        lbu     a1, 0x000D(v0)              // a1 = port
        sll     a1, a1, 0x0002              // a1 = offset to player entry
        addu    at, at, a1                  // a0 = coords entry

		lw      a0, 0x0074(a0)				// a0 = player position struct
		lh		a0, 0x001C(a0)				//
		andi    a0, a0, 0x8000

		//lwc1    f4, 0x022C(v0)				// f4 = previous x coord cpu was going towards
		//lwc1    f6, 0x0230(v0)				// f6 = previous y coord cpu was going towards
		//swc1    f4, 0x0000(at)				// save x
		//swc1    f6, 0x0004(at)				// save y


		_continue_0:
		beqzl	a0, _continue
		addiu   v0, v0, 0x0008				// v0 += 0x8

		_continue:
		lwc1    f12, 0x0218(v0)				// f12 = ledge x
		lwc1    f14, 0x021C(v0)				// f14 = ledge y
		swc1    f12, 0x0000(at)				// save ledge x
		swc1    f14, 0x0004(at)				// save ledge y

		// sw		a1, 0x0000(a0)				// save the x coordinate
		// // lw      a1, 0x0230(v0)			// a1 = previous y coord cpu was going towards
		// lwc1    f6, 0x0230(v0)				// f6 = previous y coord cpu was going towards
		// sw		a1, 0x0004(a0)				// save the y coordinate
		_end:
		lw      v0, 0x0034(sp)				// restore v0
		lw 		a0, 0x0918(v0) 				// og line 1
		j		_return
		addiu 	a1, sp, 0x0028 				// og line 2

	}

	// @ Description
	// Ness and Lucas will aim here when recovering with improved PK Thunder.
	pk_thunder_target_coords:
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0

    scope recovery_logic: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Check CPU level for vanilla characters
        lbu t1, 0x0013(a0) // t1 = cpu level
        addiu t1, t1, -10 // t1 = 0 if level 10
        bnezl t1, _end // if not lv10, skip
        nop

        // Only go for it when double jumping back to stage
        lw at, 0x24(a0) // at = action id
        lli t0, Action.JumpAerialF
        bne t0, at, _end
        nop

        // skip if air speed is down
        mtc1 r0, f0 // guarantee f0 = 0
        lwc1 f20, 0x004C(a0) // f20 = y speed
        c.le.s f20, f0 // y speed < 0?
        nop
        bc1t _end // if so, skip
        nop

        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X
        lwc1 f4, 0x4(t0) // f4 = location Y

        // check closest ledge in X
        scope ledge_check: {
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x54(a0) // load nearest RIGHT ledge X

            sub.s f6, f6, f2
            abs.s f6, f6 // f6 = abs(distance) to left ledge

            sub.s f8, f8, f2
            abs.s f8, f8 // f8 = abs(distance) to right ledge

            c.le.s f6, f8
            nop
            bc1f _right
            nop

            _left:
            lwc1 f6, 0x01CC+0x4C(a0) // load nearest LEFT ledge X
            lwc1 f8, 0x01CC+0x50(a0) // load nearest LEFT ledge Y
            
            b _check_end
            nop

            _right:
            lwc1 f6, 0x01CC+0x54(a0) // load nearest RIGHT ledge X
            lwc1 f8, 0x01CC+0x58(a0) // load nearest RIGHT ledge Y

            _check_end:
        }

        sub.s f14, f6, f2 // f14 = x diff
        sub.s f12, f8, f4 // f12 = y diff

        lw t6, 0x9C8(a0) // t6 = character attributes
        lwc1 f20, 0xB0(t6) // f20 = ledge grab Y
        add.s f20, f4, f20 // f20 = Y + ledge grab Y

        lw t0, 0x44(a0) // t0 = player facing direction (int)
        mtc1 t0, f10
        cvt.s.w f10, f10 // f10 = facing direction (float)

        lwc1 f22, 0xB0(t6) // f22 = ledge grab X
        mul.s f10, f10, f22 // f10 = facing direction * ledge grab X
        add.s f22, f2, f10 // f22 = X + facing direction * ledge grab X

        // check if ledge Y + ledge grab Y is above ledge Y
        c.le.s f20, f8 // f20 <= ledge Y?
        nop
        bc1t _end // if not, skip
        nop

        // check if Y > ledge Y (don't dsp if already above ledge Y)
        c.le.s f8, f4 // ledge Y <= Y?
        nop
        bc1t _end // if not, skip
        nop

        // check if ledge grab X is beyond ledge X in the facing direction
        // we can use the x diff to determine this
        // first check if the x diff is positive or negative
        c.lt.s f14, f0 // if x diff < 0
        nop
        bc1t _going_left // if x diff < 0, hold left
        nop

        _going_right:
        // check if ledge grab X > ledge X
        // if so, dsp
        c.le.s f22, f6 // f22 <= ledge X?
        nop
        bc1f _dsp // if not, dsp
        nop
        b _end
        nop
        
        _going_left:
        // check if ledge grab X < ledge X
        // if so, dsp
        c.le.s f6, f22 // ledge X <= ledge grab X?
        nop
        bc1f _dsp // if not, dsp
        nop
        b _end
        nop

        _dsp:
        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.DSP // arg1 = DSP

        b _end
        nop

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(recovery_logic, Character.id.NESS, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JNESS, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.LUCAS, 0x4)
    dw recovery_logic; OS.patch_end()
}
