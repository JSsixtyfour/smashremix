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
    Character.table_patch_start(recovery_logic, Character.id.YOSHI, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JYOSHI, 0x4)
    dw recovery_logic; OS.patch_end()

    scope cpu_post_process: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Apply only for lv10 CPUs
        lbu t0, 0x13(a0) // t0 = cpu level
        slti t0, t0, 10 // t0 = 0 if 10 or greater
        bnez t0, _end // skip if not lv10
        nop

        // If going for NSP, check if the opponent is not already trapped in an egg
        lw t0, 0x1D4(a0) // t0 = ft_com->p_command
        li t1, AI.command_table // load command table base address

        lw at, AI.ATTACK_TABLE.NSPG.INPUT << 2(t1)
        beq t0, at, nsp_check
        lw at, AI.ATTACK_TABLE.NSPA.INPUT << 2(t1)
        beq t0, at, nsp_check
        nop

        b _end
        nop

        scope nsp_check: {
            lw at, 0x01FC(a0) // get target player object

            beqz at, _end // if no target object, skip
            nop

            lw at, 0x84(at) // at = target struct

            // skip if the opponent is in one of these states
            lw t0, 0x24(at) // t0 = target action id
            lli t1, Action.EggLay
            beq t0, t1, _no_input
            lli t1, Action.EggLayPulled
            beq t0, t1, _no_input
            nop

            b _end // all tests passed, use nsp
            nop

            _no_input:
            // skip DSP
            jal 0x80132758 // execute AI command
            lli a1, AI.ROUTINE.NULL // arg1 = NULL

            _end:
        }

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_post_process, Character.id.YOSHI, 0x4)
    dw cpu_post_process; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.JYOSHI, 0x4)
    dw cpu_post_process; OS.patch_end()

    scope cpu_attack_weight: {
        // s0 = character struct
        // s2 = current input config (dw input_id, dw start_frame, dw [unused], float32 min_x, float32 max_x, float32 min_y, float32 max_y)
        // f2 = weight multiplier (starts with calculated value, can be further modified or completely reset)
        OS.routine_begin(0x20)

        // Check CPU level
        lbu t0, 0x13(s0) // t0 = cpu level
        addiu t0, t0, -10 // t0 = 0 if level 10
        bnez t0, _end // if not lv10, perform original logic
        nop

        lw t0, 0x0(s2) // t0 = input id
        addiu at, r0, AI.ATTACK_TABLE.NSPG.INPUT
        beq t0, at, _nsp
        nop
        b _end // no attack matched
        nop

        _nsp:
        // nsp more often vs shielding opponents
        lw t4, 0x1CC+0x6C(s0) // opponent struct
        lw t1, 0x24(t4) // opponent's current action
        addiu at, r0, Action.Shield
        beq t1, at, _nsp_continue
        addiu at, r0, Action.ShieldStun
        beq t1, at, _nsp_continue
        addiu at, r0, Action.ShieldOn
        beq t1, at, _nsp_continue
        nop
        b _end // opponent not shielding, skip
        nop
        _nsp_continue:
        lui at, 0x42C8 // at = 100.0
        b _end
        mtc1 at, f2 // f2 = new weight (override)

        _end:
        OS.routine_end(0x20)
    }
    Character.table_patch_start(cpu_attack_weight, Character.id.YOSHI, 0x4)
    dw cpu_attack_weight; OS.patch_end()
    Character.table_patch_start(cpu_attack_weight, Character.id.JYOSHI, 0x4)
    dw cpu_attack_weight; OS.patch_end()
}