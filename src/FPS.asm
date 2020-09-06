// FPS.asm
if !{defined __FPS__} {
define __FPS__()

include "Color.asm"
include "Global.asm"
include "OS.asm"
include "String.asm"
include "Toggles.asm"

scope FPS {

    macro li.s(register, value) {
        addi    sp,sp,-0x0004
        li      at, {value}
        sw      at, 0x0000(sp)
        lwc1    {register}, 0x0000(sp)
        addi    sp,sp,0x0004
        cvt.s.w {register},{register}
    }

    // @ Description
    // TODO: Check this math
    // The standard count register (46.875 MHz) increments every 21.33 ns
    // Over the course of a second, the counter will increment
    // 46,882,325 times, this is stored as SECOND_LENGTH
    // floor((1.666*10^7 * 60)/(21.33)) in hex
    constant SECOND_LENGTH(0x02CB14D4)
    // The overclocked count register (62.5 MHz) increments every 16 ns
    // Over the course of a second, the counter will increment
    // 46,882,325 times, this is stored as SECOND_LENGTH
    // floor((1.666*10^7 * 60)/(16)) in hex
    constant SECOND_LENGTH_OC(0x03B94AF8)

    // @ Description
    constant UPDATES_PER_SECOND(3)
    constant UPDATE_LENGTH(SECOND_LENGTH / UPDATES_PER_SECOND)
    constant UPDATE_LENGTH_OC(SECOND_LENGTH_OC / UPDATES_PER_SECOND)

    // @ Description
    constant FPS_HEIGHT(12)
    constant FPS_WIDTH(32)
    constant FPS_X_COORD(20)
    constant FPS_Y_COORD(21)

    current_fps:
    dw 0x0000003C

    current_partial_fps:
    dw 0x00000000

    frame_count:
    dw 0x00000000

    last_os_get_count:
    dw 0x00000000

    decimal:; String.insert(".")

    // @ Description
    // Sets up the FPS display objects if the FPS toggle is on
    scope setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        li      at, Toggles.entry_fps       // ~
        lw      at, 0x0004(at)              // at = 0 if off
        beqz    at, _end                    // skip if off
        nop

        Render.load_font()

        Render.create_room(0x37, 0x18, 0x01, 0x41200000, 0x41200000, 0x42480000, 0x41F00000)
        Render.draw_rectangle(0x37, 0x19, FPS_X_COORD - 2, FPS_Y_COORD - 2, FPS_WIDTH, FPS_HEIGHT, 0x000000B0, OS.TRUE)
        Render.draw_number(0x37, 0x19, current_fps, Render.update_live_string_, 0x42090000, 0x419C0000, 0xFFFFFFFF, 0x3F600000, Render.alignment.RIGHT)
        Render.draw_string(0x37, 0x19, decimal, Render.NOOP, 0x42080000, 0x419C0000, 0xFFFFFFFF, 0x3F600000, Render.alignment.LEFT)
        Render.draw_number(0x37, 0x19, current_partial_fps, Render.update_live_string_, 0x423B0000, 0x419C0000, 0xFFFFFFFF, 0x3F600000, Render.alignment.RIGHT)

        // Registering the routine here results in a constant 62.5 reading - perhaps evidence the game is attempting to compensate for lag?
        // Render.register_routine(run_, 0x0, 0x19)

        _end:
        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Calculates the FPS
    scope run_: {
        OS.patch_start(0x00005FD0, 0x800053D0)
        j        run_
        nop
        _run_return:
        OS.patch_end()

        lui     v1, 0x8004                  // original line 1
        lui     v0, 0x8004                  // original line 2

        b       _guard                      // check if toggle is on
        nop

        _toggle_off:
        b       _end                        // toggle is off, skip to end
        nop

        _guard:
        // If fps toggle is off, skip to _end and don't draw fps
        Toggles.guard(Toggles.entry_fps, _toggle_off)

        OS.save_registers()                 // save registers

        li      at, Toggles.entry_fps       // ~
        lw      at, 0x0004(at)              // at = 1 for standard, 2 for overclocked
        addiu   at, at, -0x0001             // at = 0 for standard, 1 for overclocked
        li      t8, SECOND_LENGTH           // t8 = SECOND_LENGTH
        li      t9, UPDATE_LENGTH           // t9 = UPDATE_LENGTH
        beqz    at, _os_get_count           // if standard, skip ahead
        nop                                 // otherwise, use overclocked value:
        li      t8, SECOND_LENGTH_OC        // t8 = SECOND_LENGTH_OC
        li      t9, UPDATE_LENGTH_OC        // t9 = UPDATE_LENGTH_OC

        _os_get_count:
        jal     0x80033490                  // osGetCount
        nop
        li      t0, last_os_get_count       // t0 = address of last_os_get_count
        lw      t1, 0x0000(t0)              // t1 = last_os_get_count
        move    t7, v0
        bne     t1, r0, _inc_frame_count    // if (last_os_get_count != 0), jump
        nop
        sw      v0, 0x0000(t0)              // update last_os_get_count

        _inc_frame_count:
        li      t0, frame_count             // t0 = address of frame_count
        lw      t2, 0x0000(t0)              // t2 = frame_count
        addiu   t3, t2, 0x0001              // increment counter
        sw      t3, 0x0000(t0)              // update frame_count

        _determine_update:
        subu    t3, v0, t1                  // t3 = delta time since last update
        sltu    at, t3, t9                  // if (delta < UPDATE_LENGTH), set at
        beqz    at, _calculate_fps          // calculate fps to display
        nop

        _done:
        OS.restore_registers()              // restore registers

        _end:
        j       _run_return                 // return
        nop

        _calculate_fps:
        li      t1, frame_count             // t1 = address of frame_count
        lw      t2, 0x0000(t1)              // t2 = frame_count
        mtc1    t2, f0                      // move given int to f0
        cvt.s.w f0, f0                      // f0 = frame_count FP
        mtc1    t3, f2                      // move given int to f2
        cvt.s.w f2, f2                      // f2 = (osGetCount - lastOsGetCount) FP
        or      t4, r0, t8                  // t4 = SECOND_LENGTH
        mtc1    t4, f4                      // move given int to f4
        cvt.s.w f4, f4                      // f4 = SECOND_LENGTH FP
        div.s   f6, f2, f4                  // f3 = (osGetCount - lastOsGetCount)/(SECOND_LENGTH)
        div.s   f8, f0, f6                  // f5 = (frame_count)/(time_period)

        _store_fps:
        floor.w.s f10, f8                   // f10 = calculated fps INT
        mfc1    t1, f10                     // t1 = calculated fps
        li      t0, current_fps             // t0 = address of current_fps
        sw      t1, 0x0000(t0)              // update current_fps
        cvt.s.w f10, f10                    // f10 = calculated fps FP
        sub.s   f12, f10, f8
        FPS.li.s(f14, 10.0)
        mul.s   f16, f12, f14
        cvt.w.s f16, f16
        mfc1    t2, f16
        move    t3, t2
        bgez    t2, _store_partial_fps
        nop
        sub     t3, r0, t2

        _store_partial_fps:
        slti    t0, t3, 0x000A              // t0 = 0 if t3 is 10, which apparently can happen sometimes
        addiu   t0, t0, -0x0001             // t0 = -1 if t3 is 10, 0 otherwise
        addu    t3, t3, t0                  // t3 = current_partial_fps, assured to be 0-9
        li      t0, current_partial_fps     // t0 = address of current_partial_fps
        sw      t3, 0x0000(t0)              // update current_partial_fps

        _reset_counters:
        li      t0, frame_count             // t0 = address of frame_count
        sw      r0, 0x0000(t0)              // reset frame_count
        li      t0, last_os_get_count       // t0 = address of last_os_get_count
        sw      t7, 0x0000(t0)              // update last_os_get_count
        b      _done

    }

}

}
