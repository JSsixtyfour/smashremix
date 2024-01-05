// InputDelay.asm
if !{defined __INPUTDELAY__} {
define __INPUTDELAY__()
print "included InputDelay.asm\n"

// @ Description
// This file enables increasing input delay.
// This is useful for netplay warriors.

include "OS.asm"
include "Global.asm"

scope InputDelay {
    constant MAX_FRAMES(12)

    // @ Description
    // Hijacks the controller struct writing routine to use a buffer if input delay is greater than 0.
    scope apply_input_delay_: {
        OS.patch_start(0x4BF8, 0x80003FF8)
        jal     apply_input_delay_
        nop
        OS.patch_end()
        
        // a1 = port
        // a3 = 0x80045228 = Joypad.struct
        // v0 = current port controller struct
        // t0 = size of controller struct (10)
        // t7 = port * size of controller struct = port * 10
        // t8 = is_held  - check for is_held
        // t9 = pressed  - check for !is_held -> is_held
        // t2 = turbo    - is_held but continually goes on and off
        // t1 = released - check for is_held -> !is_held
        // t3 = xpos
        // t4 = ypos

        // Get port's input delay
        li      t5, delay_table
        sll     t6, a1, 0x0002                  // t6 = port * 4 = offset to delay value
        addu    t5, t5, t6                      // t5 = address of delay value
        lw      t5, 0x0000(t5)                  // t5 = delay value

        // If zero, skip to end
        beqz    t5, _end                        // if delay = 0, skip to end
        nop

        // Otherwise, update buffer
        lli     t0, MAX_FRAMES                  // t0 = MAX_FRAMES
        multu   t7, t0                          // (port * 10 * MAX_FRAMES) = offset to start of port's buffer
        mflo    t6                              // t6 = offset to port's buffer
        li      at, buffer                      // at = buffer start
        addu    t6, at, t6                      // t6 = port's buffer

        addiu   sp, sp, -0x0010                 // allocate stack space

        _loop:
        addiu   t0, t0, -0x0001                 // t0--
        sltu    at, t0, t5                      // at = 1 if this frame should be used, 0 if not
        bnez    at, _update                     // if frame should be used, update it
        nop                                     // otherwise, zero out this frame

        sh      r0, 0x0000(t6)                  // clear first halfword
        sh      r0, 0x0002(t6)                  // clear second halfword
        sh      r0, 0x0004(t6)                  // clear third halfword
        sh      r0, 0x0006(t6)                  // clear fourth halfword
        sh      r0, 0x0008(t6)                  // clear last halfword
        b       _loop                           // continue looping
        addiu   t6, t6, 0x000A                  // t6 = previous frame

        _update:
        lhu     at, 0x0000(t6)                  // at = first halfword of frame's input buffer
        sh      at, 0x0000(sp)                  // save first halfword
        lhu     at, 0x0002(t6)                  // at = second halfword of frame's input buffer
        sh      at, 0x0002(sp)                  // save second halfword
        lhu     at, 0x0004(t6)                  // at = third halfword of frame's input buffer
        sh      at, 0x0004(sp)                  // save third halfword
        lhu     at, 0x0006(t6)                  // at = fourth halfword of frame's input buffer
        sh      at, 0x0006(sp)                  // save fourth halfword
        lhu     at, 0x0008(t6)                  // at = last halfword of frame's input buffer
        sh      at, 0x0008(sp)                  // save last halfword

        sh      t8, 0x0000(t6)                  // update frame data
        sh      t9, 0x0002(t6)                  // update frame data
        sh      t2, 0x0004(t6)                  // update frame data
        sh      t1, 0x0006(t6)                  // update frame data
        sb      t3, 0x0008(t6)                  // update frame data
        sb      t4, 0x0009(t6)                  // update frame data

        lhu     t8, 0x0000(sp)                  // load frame data
        lhu     t9, 0x0002(sp)                  // load frame data
        lhu     t2, 0x0004(sp)                  // load frame data
        lhu     t1, 0x0006(sp)                  // load frame data
        lb      t3, 0x0008(sp)                  // load frame data
        lb      t4, 0x0009(sp)                  // load frame data

        bnez    t0, _loop                       // continue looping
        addiu   t6, t6, 0x000A                  // t6 = previous frame

        addiu   sp, sp, 0x0010                  // restore stack space
        lli     t0, 0x000A                      // restore t0

        _end:
        // sh      t8, 0x0000(v0)                  // original line 1 (moved to 'DpadFunctions.css_dpad_cursor_control_')
        // sh      t9, 0x0002(v0)                  // original line 2 (moved to 'DpadFunctions.css_dpad_cursor_control_')
        jr      ra
        nop

        // controller struct buffer for 12 frames
        // frame MAX_FRAMES, frame MAX_FRAMES - 1, frame MAX_FRAMES - 2, ...frame 1
        buffer:
        fill (10 * MAX_FRAMES) // p1
        fill (10 * MAX_FRAMES) // p2
        fill (10 * MAX_FRAMES) // p3
        fill (10 * MAX_FRAMES) // p4
    }

    // @ Description
    // Holds input delay values for each port
    delay_table:
    dw  0   // P1
    dw  0   // P2
    dw  0   // P3
    dw  0   // P4
}

} // __INPUTDELAY__
