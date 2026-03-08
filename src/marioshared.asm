// MarioShared.asm

// This file contains shared functions by Mario and others

scope MarioShared {
    scope recovery_logic: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Check CPU level for vanilla characters
        lbu t1, 0x0013(a0) // t1 = cpu level
        addiu t1, t1, -10 // t1 = 0 if level 10
        bnezl t1, _end // if not lv10, skip
        nop

        lw t0, 0x78(a0) // load location vector
        lwc1 f2, 0x0(t0) // f2 = location X
        lwc1 f4, 0x4(t0) // f4 = location Y

        mtc1 r0, f0 // guarantee f0 = 0

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

        // if currently doing DSP, mash!
        lw at, 0x24(a0) // at = action id
        lli t0, Action.MARIO.MarioTornadoAir
        beq at, t0, _dsp_mash
        nop

        // check if up high first
        // in this case, go for NSP
        lui at, 0xC4FA
        mtc1 at, f22 // f22 = -2000.0

        c.le.s f12, f22 // if 2000 units or more above ledge
        nop
        bc1t _up_high
        nop

        // Then, if recovering from very far
        // we can try a DSP if it will rise based on flag
        lw at, 0xADC(a0) // flag to know if aerial dsp was already used
        bnez at, _end // if aerial dsp was already used, skip. Won't rise
        nop

        lui at, 0x4520
        mtc1 at, f22 // f22 = 2560.0

        abs.s f16, f14 // f16 = abs(x distance to ledge)

        c.le.s f16, f22 // if distance to ledge is higher than 2560.0
        nop
        bc1t _end // not far enough, skip
        nop

        c.le.s f0, f12 // check if under ledge level
        nop
        bc1t _dsp // dsp if far from stage and under ledge height
        nop

        b _end // no conditions matched, skip
        nop

        _up_high:
        swc1 f6, 0x01CC+0x60(a0) // save new target x = ledge x
        swc1 f8, 0x01CC+0x64(a0) // save new target y = ledge y

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NSP_TOWARDS // arg1 = NSP

        b _end
        nop

        _dsp:
        swc1 f6, 0x01CC+0x60(a0) // save new target x = ledge x
        swc1 f8, 0x01CC+0x64(a0) // save new target y = ledge y

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.DSP // arg1 = DSP

        b _end
        nop

        _dsp_mash:
        lw t3, 0x001C(a0) // t3 = current frame
        slti t3, t3, 50 // t3 = 0 if 50 or greater

        beqz t3, _end // skip if at the end of the move to not accidentally usp
        nop

        swc1 f6, 0x01CC+0x60(a0) // save new target x = ledge x
        swc1 f8, 0x01CC+0x64(a0) // save new target y = ledge y

        li t5, Global.current_screen_frame_count // ~
        lw t5, 0x0000(t5) // t5 = global frame count
        andi t5, t5, 0x0001
        beqz t5, _dsp_mash_release
        lh at, 0x01C6(a0) // at = buttons pressed
        _dsp_mash_press:
        b _dsp_mash_apply
        ori at, at, 0x4000 // press B
        _dsp_mash_release:
        andi at, at, 0x0000 // release all buttons
        _dsp_mash_apply:
        sh at, 0x01C6(a0) // save press B mask

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.POINT_STICK_TO_TARGET // arg1 = point to target

        _end:
        lw a0, 0x10(sp)
        OS.routine_end(0x20)
    }
    Character.table_patch_start(recovery_logic, Character.id.MARIO, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JMARIO, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.LUIGI, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JLUIGI, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.DRM, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.DRL, 0x4)
    dw recovery_logic; OS.patch_end()

    // Set pipe turn rotation for Poly Dr Mario
    Character.table_patch_start(pipe_turn, Character.id.NDRM, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for Poly Wario
    Character.table_patch_start(pipe_turn, Character.id.NWARIO, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for Poly Conker
    Character.table_patch_start(pipe_turn, Character.id.NCONKER, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for JMARIO
    Character.table_patch_start(pipe_turn, Character.id.JMARIO, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for JLUIGI
    Character.table_patch_start(pipe_turn, Character.id.JLUIGI, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for MLUIGI
    Character.table_patch_start(pipe_turn, Character.id.MLUIGI, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for WARIO
    Character.table_patch_start(pipe_turn, Character.id.WARIO, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for GOEMON
    Character.table_patch_start(pipe_turn, Character.id.GOEMON, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for EBI
    Character.table_patch_start(pipe_turn, Character.id.EBI, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for DRM
    Character.table_patch_start(pipe_turn, Character.id.DRM, 0x1)
    db      OS.TRUE;     OS.patch_end();

    // Set pipe turn rotation for CONKER
    Character.table_patch_start(pipe_turn, Character.id.CONKER, 0x1)
    db      OS.TRUE;     OS.patch_end();


    // Hardcoding for when Mario Clones use Pipes, ensures they face the correct way when entering
    scope pipe_turn_enter: {
        OS.patch_start(0xBCC40, 0x80142200)
        j       pipe_turn_enter
        nop                                 // original line 2
        _return:
        OS.patch_end()

        beq     v0, r0, _mario_turn         // modified original line 1, correct turn if Mario
        nop

        // v0 = character id
        li      at, Character.pipe_turn.table
        addu    t0, v0, at                  // t0 = entry in pipe_turn.table
        lb      t0, 0x0000(t0)              // load characters entry in jump table
        bnez    t0, _mario_turn
        nop

        j       _return                     // return
        addiu   at, r0, 0x000D              // reinserting in the interest of caution

        _mario_turn:
        j       0x80142228                  // modified original line 1, routine having Mario properly turn during Pipe animation
        addiu   at, r0, 0x000D              // reinserting in the interest of caution
    }

    // Hardcoding for when Mario Clones use Pipes, ensures they face the correct way when exiting
    scope pipe_turn_exit: {
        OS.patch_start(0xBD19C, 0x8014275C)
        j       pipe_turn_exit
        sw      t5, 0x0B3C(s0)              // original line 2
        _return:
        OS.patch_end()

        beq     v0, r0, _mario_turn         // modified original line 1, correct turn if Mario
        nop
        // v0 = character id
        li      at, Character.pipe_turn.table
        addu    t6, v0, at                  // t6 = entry in pipe_turn.table
        lb      t6, 0x0000(t6)              // load characters entry in jump table
        bnez    t6, _mario_turn
        nop

        j       _return                     // return
        nop

        _mario_turn:
        j       0x801427AC                  // modified original line 1, routine having Mario properly turn during Pipe animation
        nop
    }

}
