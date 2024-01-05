// Yoshishared.asm

// This file contains shared functions by Yoshi Clones.

scope YoshiShared {

// Hardcoding for Yoshi Clones to execute Yoshi style double jump
    scope yoshi_dj_fix_1: {
        OS.patch_start(0xBA818, 0x8013FDD8)
        j       yoshi_dj_fix_1
        nop
        _return:
        OS.patch_end()

        beq     a0, v0, _yoshi_dj_1             // modified original line 1
        addiu   a0, r0, Character.id.JYOSHI     // j yoshi ID
        beq     a0, v0, _yoshi_dj_1
        nop
        j       _return
        lw      t0, 0x0028(sp)              // original line 2

        _yoshi_dj_1:
        lw      a0, 0x0008(s0)
        j       0x8013FDE8
        lw      t0, 0x0028(sp)              // original line 2
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute the Yoshi Egg Shield
    scope yoshi_shield_fix_1: {
        OS.patch_start(0xC3688, 0x80148C48)
        j       yoshi_shield_fix_1
        nop
        _return:
        OS.patch_end()

        beq     t7, at, _yoshi_shield_1
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     t7, at, _yoshi_shield_1
        nop

        _regular_shield_1:
        j       0x80148C60                 // original line 2
        nop

        _yoshi_shield_1:
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute the Yoshi Egg Shield
    scope yoshi_shield_fix_2: {
        OS.patch_start(0xC3560, 0x80148B20)
        j       yoshi_shield_fix_2
        nop
        _return:
        OS.patch_end()

        beq     t9, at, _yoshi_shield_2
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     t9, at, _yoshi_shield_2
        nop

        _regular_shield_2:
        j       0x80148B58                // original line 2
        nop

        _yoshi_shield_2:
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute the Yoshi Egg Shield  // v0 is dif, a3
    scope yoshi_shield_fix_3: {
        OS.patch_start(0xC2E54, 0x80148414)
        j       yoshi_shield_fix_3
        addiu   v0, v0, 0x0040                          // original line 2
        _return:
        OS.patch_end()

        beq     t6, at, _yoshi_shield_3
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     t6, at, _yoshi_shield_3
        nop

        _regular_shield_3:
        j       0x8014842C
        nop

        _yoshi_shield_3:
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute the Yoshi Egg Shield
    scope yoshi_shield_fix_4: {
        OS.patch_start(0xC2DC4, 0x80148384)
        j       yoshi_shield_fix_4
        nop
        _return:
        OS.patch_end()

        beq     t8, at, _yoshi_shield_4
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     t8, at, _yoshi_shield_4
        nop

        _regular_shield_4:
        j       0x801483E0
        nop

        _yoshi_shield_4:
        j       _return
        nop
    }


    // Hardcoding for Yoshi Clones to execute the Yoshi Egg Shield Roll
    scope yoshi_shield_fix_5: {
        OS.patch_start(0x66B60, 0x800EB360)
        j       yoshi_shield_fix_5
        nop
        _return:
        OS.patch_end()

        beq     t1, at, _yoshi_shield_5
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     t1, at, _yoshi_shield_5
        nop

        _regular_shield_5:
        j       0x800EB38C
        lw      ra, 0x001C(sp)

        _yoshi_shield_5:
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute the Yoshi Egg Shield Roll
    scope yoshi_shield_fix_6: {
        OS.patch_start(0xC38B8, 0x80148E78)
        j       yoshi_shield_fix_6
        nop
        _return:
        OS.patch_end()

        beq     t7, at, _yoshi_shield_6
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     t7, at, _yoshi_shield_6
        nop

        _regular_shield_6:
        j       0x80148EA4
        nop

        _yoshi_shield_6:
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute the Yoshi Egg Shield Roll
    scope yoshi_shield_fix_7: {
        OS.patch_start(0xC3C6C, 0x8014922C)
        j       yoshi_shield_fix_7
        swc1    f0, 0x0060(v0)                          // original line 2
        _return:
        OS.patch_end()

        beq     v1, at, _yoshi_shield_7
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     v1, at, _yoshi_shield_7
        nop

        _regular_shield_7:
        j       _return
        nop

        _yoshi_shield_7:
        j       0x80149240
        nop
    }

    // Hardcoding for Yoshi Clones to properly end invincibility when doing a parry
    scope yoshi_shield_fix_8: {
        OS.patch_start(0xC3538, 0x80148AF8)
        j       yoshi_shield_fix_8
        nop                                             // original line 2
        _return:
        OS.patch_end()

        beq     t8, at, _yoshi_shield_8
        addiu   at, r0, Character.id.JYOSHI             // j yoshi ID
        beq     t8, at, _yoshi_shield_8
        nop

        _regular_shield_8:
        j       0x80148B08
        nop

        _yoshi_shield_8:
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute Yoshi's grab
    scope yoshi_grab_fix_1: {
        OS.patch_start(0xC4ACC, 0x8014A08C)
        j       yoshi_grab_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _yoshi_grab_1             // modified original line 1
        addiu   at, r0, Character.id.JYOSHI       // j yoshi ID
        beq     at, v0, _yoshi_grab_1
        nop
        j       _return
        or      a0, s0, r0                 // original line 2

        _yoshi_grab_1:
        j       0x8014A09C
        or      a0, s0, r0                 // original line 2
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute Yoshi's grab
    scope yoshi_grab_fix_2: {
        OS.patch_start(0xC54E0, 0x8014AAA0)
        j       yoshi_grab_fix_2
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _yoshi_grab_2             // modified original line 1 part 2
        addiu   at, r0, Character.id.JYOSHI       // j yoshi ID
        beq     at, v0, _yoshi_grab_2
        nop
        j       _return
        addiu  at, r0, 0x0014                 // original line 2

        _yoshi_grab_2:
        j       0x8014AAB0                   // modified original line 1 part 2
        addiu  at, r0, 0x0014                 // original line 2
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to execute Yoshi's throw
    // Also used by Mad Piano.
    scope yoshi_throw_fix_1: {
        OS.patch_start(0xC5748, 0x8014AD08)
        j       yoshi_throw_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _yoshi_throw_1             // modified original line 1 part 2
        addiu   at, r0, Character.id.PIANO         // Piano ID
        beq     at, v0, _yoshi_throw_1
        addiu   at, r0, Character.id.JYOSHI       // j yoshi ID
        beq     at, v0, _yoshi_throw_1
        nop
        j       _return
        addiu  at, r0, 0x0014                 // original line 2

        _yoshi_throw_1:
        j       0x8014AD18                    // modified original line 1 part 2
        addiu  at, r0, 0x0014                 // original line 2
        j       _return
        nop
    }

    // Hardcoding for Yoshi Clones to recover as a CPU.
    // A good place for other characters to recover a certain way
    scope yoshi_cpu_fix_1: {
        OS.patch_start(0xAFFCC, 0x8013558C)
        j       yoshi_cpu_fix_1
        nop
        _return:
        OS.patch_end()

        beq     v0, at, _yoshi_recover_1      // modified original line 1 part 2
        addiu   at, r0, Character.id.MARINA   // marina ID
        beq     at, v0, _marina_jump_check
        addiu   at, r0, Character.id.JYOSHI   // j yoshi ID
        beq     at, v0, _yoshi_recover_1
        nop

        _USP:
        j       _return
        addiu  at, r0, 0x000A                 // original line 2

        _marina_jump_check:
        lb      at, 0x0148(s0)                // get current # jumps
        addiu   v0, r0, 0x0006                // v0 = max # of Marina's jumps
        beq     at, v0, _USP                  // do up special if no more jumps
        addiu   v0, r0, Character.id.MARINA   // restore v0 (unsure if needed)
        _yoshi_recover_1:                     // no up special
        j       0x80135628                    // modified original line 1 part 2
        addiu  at, r0, 0x000A                 // original line 2

    }


    // Yoshi has a hardcoded projectile struct for his up special similar to Ness and Link. This code inserts a new pointer to the clones main file so the game doesn't crash.
    scope up_special_struct_fix: {
        OS.patch_start(0xE6EE8, 0x8016C4A8)
        j       up_special_struct_fix
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t2, 0x0008(s0)                  // load character struct from t6

        addiu   t1, r0, Character.id.JYOSHI     // JYOSHI ID
        li      a1, upspecial_struct_jyoshi     // JYOSHI File Pointer placed in correct location
        beq     t1, t2, _end
        nop

        lui     a1, 0x8019                  // original line 1
        addiu   a1, a1, 0x92E0              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }

    // Yoshi has a hardcoded projectile struct for his down special similar to Ness and Link. This code inserts a new pointer to the clones main file so the game doesn't crash.
    scope down_special_struct_fix: {
        OS.patch_start(0xE72A4, 0x8016C864)
        j       down_special_struct_fix
        nop
        _return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1

        lw      t2, 0x0008(v0)                  // load character struct from t6

        addiu   t1, r0, Character.id.JYOSHI     // JYOSHI ID
        li      a1, downspecial_struct_jyoshi   // JYOSHI File Pointer placed in correct location
        beq     t1, t2, _end
        addiu   t1, r0, Character.id.DEDEDE     // DEDEDE ID
        li      a1, downspecial_struct_dedede   // DEDEDE File Pointer placed in correct location
        beq     t1, t2, _end
        nop

        lui     a1, 0x8019                  // original line 1
        addiu   a1, a1, 0x9320              // original line 2

        _end:
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return                     // return
        nop
    }


    OS.align(16)
    upspecial_struct_jyoshi:
    dw 0x00000000
    dw 0x00000005
    dw Character.JYOSHI_file_1_ptr
    OS.copy_segment(0x103D2C, 0x40)

    OS.align(16)
    downspecial_struct_jyoshi:
    dw 0x00000000
    dw 0x00000006
    dw Character.JYOSHI_file_1_ptr
    OS.copy_segment(0x103D6C, 0x40)

    OS.align(16)
    downspecial_struct_dedede:
    dw 0x00000000
    dw 0x00000006
    dw Character.DEDEDE_file_7_ptr
    OS.copy_segment(0x103D6C, 0x40)

    }