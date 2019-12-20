// FPS.asm
if !{defined __FPS__} {
define __FPS__()

include "Color.asm"
include "Global.asm"
include "OS.asm"
include "Overlay.asm"
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
    constant FPS_HEIGHT(11)
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

    scope run_: {
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

        _draw_background:
        lli     a0, Color.BLACK             // a0 = color
        jal     Overlay.set_color_          // set fill color to black
        nop
        lli     a0, FPS_X_COORD - 2         // a0 = ulx
        lli     a1, FPS_Y_COORD - 2         // a1 = uly
        lli     a2, FPS_WIDTH               // a2 = width
        lli     a3, FPS_HEIGHT              // a3 = height
        jal     Overlay.draw_rectangle_     // draw rectangle in corner
        nop

        _draw_fps:
        li      a1, current_fps             // a1 = address of current_fps
        lw      a0, 0x0000(a1)              // a0 = current_fps
        jal     String.itoa_                // v0 = (string) current_fps
        nop
        slti    at, a0, 0x000A              // if (current_fps < 10), set at
        bne     at, r0, _draw_single_fps    // make single fps look pretty
        nop
        lli     a0, FPS_X_COORD             // a0 = ulx
        lli     a1, FPS_Y_COORD             // a1 = uly
        move    a2, v0                      // a2 = address of string
        jal     Overlay.draw_string_        // draw current fps count
        nop

        _draw_partial_fps:
        lli     a0, FPS_X_COORD + 15        // a0 = ulx
        lli     a1, FPS_Y_COORD             // a1 = uly
        lli     a2, '.'                     // a2 = period
        jal     Overlay.draw_char_          // draw current fps count
        nop
        li      a1, current_partial_fps     // a1 = address of current_partial_fps
        lw      a0, 0x0000(a1)              // a0 = current_partial_fps
        jal     String.itoa_                // v0 = (string) current_partial_fps
        nop
        lli     a0, FPS_X_COORD + 20        // a0 = ulx
        lli     a1, FPS_Y_COORD             // a1 = uly
        move    a2, v0                      // a2 = address of string
        jal     Overlay.draw_string_        // draw current fps count
        nop

        OS.restore_registers()              // restore registers

        _end:
        jr      ra                          // return
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
        j       _draw_background
        nop

        _draw_single_fps:
        lli     a0, FPS_X_COORD             // a0 = ulx
        lli     a1, FPS_Y_COORD             // a1 = uly
        lli     a2, '0'                     // a2 = 0
        jal     Overlay.draw_char_          // draw current fps count
        nop
        lli     a0, FPS_X_COORD + 8            // a0 = ulx
        lli     a1, FPS_Y_COORD             // a1 = uly
        move    a2, v0                      // a2 = address of string
        jal     Overlay.draw_string_        // draw current fps count
        nop
        j       _draw_partial_fps           // continue drawing fps
        nop

    }

}



}
