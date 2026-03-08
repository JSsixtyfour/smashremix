// FoxShared.asm

scope FoxShared {
    scope recovery_logic: {
        OS.routine_begin(0x20)
        sw a0, 0x10(sp)

        // Check CPU level for vanilla characters
        lbu t1, 0x0013(a0) // t1 = cpu level
        addiu t1, t1, -10 // t1 = 0 if level 10
        bnezl t1, _end // if not lv10, skip
        nop

        // If performing any USP action, skip
        // Otherwise, could angle the recovery straight down
        lw at, 0x24(a0) // at = action id
        lli t0, Action.FOX.FireFoxStart
        beq t0, at, _end
        lli t0, Action.FOX.FireFoxStartAir
        beq t0, at, _end
        lli t0, Action.FOX.ReadyingFireFox
        beq t0, at, _end
        lli t0, Action.FOX.ReadyingFireFoxAir
        beq t0, at, _end
        lli t0, Action.FOX.FireFox
        beq t0, at, _end
        lli t0, Action.FOX.FireFoxAir
        beq t0, at, _end
        lli t0, Action.FOX.FireFoxEnd
        beq t0, at, _end
        lli t0, Action.FOX.FireFoxEndAir
        beq t0, at, _end
        nop

        // skip if air speed is up (to not cut a jump short)
        mtc1 r0, f0 // guarantee f0 = 0
        lwc1 f20, 0x004C(a0) // f20 = y speed
        c.le.s f20, f0 // y speed < 0?
        nop
        bc1f _end // if so, skip
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

        // Calculate distance to ledge into f20
        mul.s f20, f14, f14 // f20 = (x distance)^2
        mul.s f22, f12, f12 // f22 = (y distance)^2
        add.s f20, f20, f22 // f20 = (x distance)^2 + (y distance)^2
        sqrt.s f20, f20 // f20 = sqrt((x distance)^2 + (y distance)^2) = distance to ledge

        // check if we have jumps left
        lw t0, 0x09C8(a0) // t0 = attribute pointer
        lw t0, 0x0064(t0) // t0 = max jumps
        lb t1, 0x0148(a0) // t1 = jumps used

        beq t0, t1, _no_jump // used all jumps already
        nop

        _has_jump:
        lui at, 0x457A
        mtc1 at, f22 // f22 = 4000.0
        b _check_distance
        nop

        _no_jump:
        lui at, 0x44FA
        mtc1 at, f22 // f22 = 2000.0

        _check_distance:
        c.le.s f20, f22 // if distance to ledge is less than the threshold
        nop
        bc1f _end // if too far, skip
        nop

        _randomize:
        jal Global.get_random_int_ // v0 = (random value)
        lli a0, 20 // 1 in 20 chance to dsp
        beqz v0, _dsp
        lw a0, 0x10(sp) // restore player struct
        b _end // skipping dsp based on random
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
    Character.table_patch_start(recovery_logic, Character.id.FOX, 0x4)
    dw recovery_logic; OS.patch_end()
    Character.table_patch_start(recovery_logic, Character.id.JFOX, 0x4)
    dw recovery_logic; OS.patch_end()

    scope cpu_post_process: {
        OS.routine_begin(0x20)

        // Apply only for lv10 CPUs
        lbu     t0, 0x13(a0) // t0 = cpu level
        slti    t0, t0, 10 // t0 = 0 if 10 or greater
        bnez    t0, _end // skip if not lv10
        nop

        lw at, 0x24(a0) // at = action id
        lli t0, Action.FOX.FireFoxStart
        beq t0, at, _firefox_down
        lli t0, Action.FOX.FireFoxStartAir
        beq t0, at, _firefox_down
        lli t0, Action.FOX.ReadyingFireFox
        beq t0, at, _firefox_down
        lli t0, Action.FOX.ReadyingFireFoxAir
        beq t0, at, _firefox_down
        lli t0, Action.FOX.FireFox
        beq t0, at, _firefox_down
        lli t0, Action.FOX.FireFoxAir
        beq t0, at, _firefox_down
        nop

        b _end // no actions matched
        nop

        _firefox_down:
        // check if already above clipping
        addiu at, r0, -1 // at = 0xFFFFFFF
        lw v0, 0x00EC(a0) // get current clipping below player
        beq at, v0, _end // skip if not above clipping
        nop

        jal 0x80132758 // execute AI command
        lli a1, AI.ROUTINE.NULL // arg1 = point to target

        addiu at, r0, 0xFFB0 // min stick Y value (down)
        sb at, 0x01C9(a0) // save CPU stick y

        sb r0, 0x01C8(a0) // CPU stick x = 0

        _end:
        OS.routine_end(0x20)
    }
    // Assign custom recovery logic to all Foxes
    Character.table_patch_start(cpu_post_process, Character.id.FOX, 0x4)
    dw cpu_post_process; OS.patch_end()
    Character.table_patch_start(cpu_post_process, Character.id.JFOX, 0x4)
    dw cpu_post_process; OS.patch_end()
}