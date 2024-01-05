// Joypad.asm
if !{defined __JOYPAD__} {
define __JOYPAD__()
print "included Joypad.asm\n"

include "OS.asm"

scope Joypad {
    // @ Description
    // Button masks
    constant A(0x8000)
    constant B(0x4000)
    constant Z(0x2000)
    constant START(0x1000)
    constant DU(0x0800)
    constant DD(0x0400)
    constant DL(0x0200)
    constant DR(0x0100)
    constant L(0x0020)
    constant R(0x0010)
    constant CU(0x0008)
    constant CD(0x0004)
    constant CL(0x0002)
    constant CR(0x0001)
    constant NONE(0x0000)

    // @ Description
    // Deadzones for menu left/right/up/down
    constant DEADZONE(30)

    // @ Description
    // This is the controller struct that game reads from. It's 10 bytes in size (per player)
    // @ Fields
    // 0x0000 - half - is_held  - check for is_held
    // 0x0002 - half - pressed  - check for !is_held -> is_held
    // 0x0004 - half - turbo    - is_held but continually goes on and off
    // 0x0006 - half - released - check for is_held -> !is_held
    // 0x0008 - byte - xpos
    // 0x0009 - byte - ypos
    // what is the difference between 0x0004 and 0x0006?
    constant struct(0x80045228)

    // @ Description
    // Types
    constant HELD(0x0000)
    constant PRESSED(0x0002)
    constant TURBO(0x0004)
    constant RELEASED(0x0006)

    // @ Description
    // Directions
    constant LEFT(0x0000)
    constant RIGHT(0x0001)
    constant DOWN(0x0002)
    constant UP(0x0003)

    // @ Description
    // Determine whether a button or button combination (type) or not.
    // @ Arguments
    // a0 - button_mask
    // a1 - player (p1 = 0, p4 = 3)
    // a2 - type
    // a3 - (bool) match any? Any non-zero treated as true
    // @ Returns
    // v0 - bool
    scope check_buttons_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      at, 0x000C(sp)              // save registers

        lli     at, 000010                  // ~
        mult    a1, at                      // ~
        mflo    at                          // at = offset
        li      t0, struct                  // t0 = struct
        addu    t0, t0, at                  // t0 = struct + offset
        addu    t0, t0, a2                  // t0 = struct + offset + type
        lhu     t0, 0x0000(t0)              // t0 = type
        lli     v0, OS.FALSE                // v0 = false
        bnez    a3, _any                    // if we are checking for any button in the mask, skip
        nop                                 // otherwise we check all buttons in the mask
        bne     t0, a0, _end                // if (mask != button_mask), skip
        nop
        lli     v0, OS.TRUE                 // v0 = true
        b       _end                        // skip to end
        nop

        _any:
        and     t1, t0, a0                  // t1 = zero if no buttons pressed
        beqz    t1, _end                    // if (no buttons pressed), skip
        nop
        lli     v0, OS.TRUE                 // v0 = true

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      at, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Calls check buttons for each player. If any player's check return true, this function returns
    // true as well.
    // @ Arguments
    // a0 - button_mask
    // a1 - (bool) match any?
    // a2 - type
    // @ Returns
    // v0 - bool
    scope check_buttons_all_: {
        addiu   sp, sp,-0x001C              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      a3, 0x0010(sp)              // ~
        sw      t0, 0x0014(sp)              // ~
        sw      ra, 0x0018(sp)              // save registers

        // player 1
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0000                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        lw      a3, 0x0008(sp)              // a3 - match any?
        jal     Joypad.check_buttons_       // v0 = bool (p1)
        nop
        move    t0, v0                      // t0 = return

        // player 2
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0001                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        lw      a3, 0x0008(sp)              // a3 - match any?
        jal     Joypad.check_buttons_       // v0 = bool (p2)
        nop
        or      t0, t0, v0                  // t0 = bool (p1/p2)

        // player 3
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0002                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        lw      a3, 0x0008(sp)              // a3 - match any?
        jal     Joypad.check_buttons_       // v0 = bool (p3)
        nop
        or      t0, t0, v0                  // at = bool (p1/p2/p3)

        // player 4
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0003                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        lw      a3, 0x0008(sp)              // a3 - match any?
        jal     Joypad.check_buttons_       // v0 = bool (p4)
        nop
        or      t0, t0, v0                  // at = bool (p1/p2/p3/p4)
        move    v0, t0                      // v0 = ret = bool (p1/p2/p3/p4)

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      a3, 0x0010(sp)              // ~
        lw      t0, 0x0014(sp)              // ~
        lw      ra, 0x0018(sp)              // save registers
        addiu   sp, sp, 0x001C              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Determine if a button is held or not
    // @ Arguments
    // a0 - button_mask
    // a1 - player (p1 = 0, p4 = 3)
    // @  Returns
    // v0 - bool
    scope is_held_: {
        lli     a2, HELD
        j       check_buttons_
        nop
    }

    // @ Description
    // Determine if a button was pressed
    // @ Arguments
    // a0 - button_mask
    // a1 - player (p1 = 0, p4 = 3)
    // @  Returns
    // v0 - bool
    scope was_pressed_: {
        lli     a2, PRESSED
        j       check_buttons_
        nop
    }

    // @ Description
    // Determine if a button was held (on/off turbo)
    // @ Arguments
    // a0 - button_mask
    // a1 - player (p1 = 0, p4 = 3)
    // @  Returns
    // v0 - bool
    scope turbo_: {
        lli     a2, TURBO
        j       check_buttons_
        nop
    }

    // @ Description
    // Determines if a button was released
    // @ Arguments
    // a0 - button_mask
    // a1 - player (p1 = 0, p4 = 3)
    // @  Returns
    // v0 - bool
    scope was_released_: {
        lli     a2, RELEASED
        j       check_buttons_
        nop
    }

    // @ Arguments
    // a0 - min coordinate (deadzone)
    // a1 - enum left/right
    // @ Returns
    // v0 - boolean
    constant check_stick_x_(0x8039089C)

    // @ Arguments
    // a0 - min coordinate (deadzone)
    // a1 -enum down/up
    // @ Returns
    // v0 - boolean
    constant check_stick_y_(0x80390950)

    // @ Arguments
    // a0 - enum left/right/down/up
    // @ Returns
    // v0 - boolean
    scope check_stick_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      a0, 0x000C(sp)              // save registers

        li      t0, frames_held             // t0 = address of frames_held
        sll     t1, a0, 0x0002              // t1 = enum left/right/dow/up * 4
        addu    t0, t0, t1                  // t0 = address of frames_held + offset
        lw      t0, 0x0000(t0)              // t0 = frames_held

        // case 1: frames_held = 0, return false
        beqz    t0, _end                    // if (frames_held == 0), end
        lli     v0, OS.FALSE                // and return false

        // case 2: frames_held = 1, return true
        lli     t1, OS.TRUE                 // t1 = OS.TRUE
        beq     t0, t1, _end                // if (frames_held == 1), end
        lli     v0, OS.TRUE                 // and return true

        // case 3: frames_held > 1 and frames_held < 28, return false
        sltiu   t1, t0, 000028              // if (frames_held < 28), t0 = OS.TRUE, else OS.FALSE
        bnez    t1, _end                    // end
        lli     v0, OS.FALSE                // and return false

        // case 4: frames_held >= 28 and frames_held % 4 == 0, return true
        lli     t1, 0x0004                  // t1 = 4
        divu    t0, t1                      // ~
        mfhi    t1                          // t1 = frames_held % 4
        beqz    t1, _end                    // if (frames_held % 4 == 0), end
        lli     v0, OS.TRUE                 // and return true

        // else: return false
        lli     v0, OS.FALSE                // return false

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      a0, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Function to update how many frames a direction has been held (should be called once a frame)
    scope update_stick_: {
        constant ORIGINAL_INSTRUCTION(0x27BDFFD8) //addiu sp, sp, 0xFFD8

        lli     a0, Joypad.DEADZONE         // a0 - min coordinate (deadzone)
        OS.save_registers()                 // allocate stack space, save registers
        addiu   sp, sp,-0x0008              // deallocate stack space
        sw      a0, 0x0004(sp)              // restore a0

        OS.read_word(0x8003B6E4, t0)        // t0 = current frame
        li      at, frame_checked
        lw      t1, 0x0000(at)              // t1 = frame checked
        beq     t0, t1, _end                // don't update if we already handled this frame
        sw      t0, 0x0000(at)              // update frame checked to current frame

        // make sure the functions are in RAM
        li      t0, check_stick_x_          // ~
        lw      t0, 0x0000(t0)              // t0 = current value of check_stick_x_
        li      t1, ORIGINAL_INSTRUCTION    // t1 = first instruction of check_stick_x_
        bne     t0, t1, _not_loaded         // skip when first instruction is not present
        nop

        _left:
//      lw      a0, 0x0004(sp)              // a0 - min coordinate (deadzone)
        subu    a0, r0, a0                  // a0 - min coordinate (deadzone) (negated)
        lli     a1, 0x0000                  // a1 - enum left/right
        jal     check_stick_x_              // check stick x
        nop
        li      t0, frames_held             // t0 = address of frames_held
        beqzl   v0, _right                  // if (ret == 0), skip
        sw      r0, 0x0000(t0)              // if (ret == 0), frames_held.left = 0
        lw      t1, 0x0000(t0)              // t1 = frames_held.left
        addiu   t1, t1, 0x0001              // ~
        sw      t1, 0x0000(t0)              // frames_held.left++

        _right:
        lw      a0, 0x0004(sp)              // a0 - min coordinate (deadzone)
        lli     a1, 0x0001                  // a1 - enum left/right
        jal     check_stick_x_              // check stick x
        nop
        li      t0, frames_held             // t0 = address of frames_held
        beqzl   v0, _down                   // if (ret == 0), skip
        sw      r0, 0x0004(t0)              // if (ret == 0), frames_held.right = 0
        lw      t1, 0x0004(t0)              // t1 = frames_held.right
        addiu   t1, t1, 0x0001              // ~
        sw      t1, 0x0004(t0)              // frames_held.right++

        _down:
        lw      a0, 0x0004(sp)              // a0 - min coordinate (deadzone)
        subu    a0, r0, a0                  // a0 - min coordinate (deadzone) (negated)
        lli     a1, 0x0000                  // a1 - enum down/up
        jal     check_stick_y_              // check stick y
        nop
        li      t0, frames_held             // t0 = address of frames_held
        beqzl   v0, _up                     // if (ret == 0), skip
        sw      r0, 0x0008(t0)              // if (ret == 0), frames_held.down = 0
        lw      t1, 0x0008(t0)              // t1 = frames_held.down
        addiu   t1, t1, 0x0001              // ~
        sw      t1, 0x0008(t0)              // frames_held.down++

        _up:
        lw      a0, 0x0004(sp)              // a0 - min coordinate (deadzone)
        lli     a1, 0x0001                  // a1 - enum down/up
        jal     check_stick_y_              // check stick y
        nop
        li      t0, frames_held             // t0 = address of frames_held
        beqzl   v0, _end                    // if (ret == 0), skip
        sw      r0, 0x000C(t0)              // if (ret == 0),  frames_held.up = 0
        lw      t1, 0x000C(t0)              // t1 = frames_held.up
        addiu   t1, t1, 0x0001              // ~
        sw      t1, 0x000C(t0)              // frames_held.up++
        b       _end                        // skip not loaded stuff
        nop

        _not_loaded:
        li      t0, frames_held             // t0 = address of frames_held
        sw      r0, 0x0000(t0)              // ~
        sw      r0, 0x0004(t0)              // ~
        sw      r0, 0x0008(t0)              // ~
        sw      r0, 0x000C(t0)              // set all directions of frames_held to 0

        _end:
        lw      a0, 0x0004(sp)              // restore a0
        addiu   sp, sp, 0x0008              // deallocate stack space
        OS.restore_registers()              // restore registers/deallocate stack space
        jr      ra                          // return
        nop

        frame_checked:
        dw 0
    }

    frames_held:
    dw 0x00000000                       // left
    dw 0x00000000                       // right
    dw 0x00000000                       // down
    dw 0x00000000                       // up

    // @ Description
    // Holds a reference to button masks for taunt for each port
    taunt_mask_per_port:
    dw 0, 0, 0, 0

    // @ Description
    // Allows overriding button mask for taunts per port.
    scope set_taunt_mask_: {
        OS.patch_start(0x53CD8, 0x800D84D8)
        jal     set_taunt_mask_
        lw      t4, 0x0104(v1)               // original line 2
        OS.patch_end()

        li      t3, taunt_mask_per_port
        lbu     t8, 0x000D(s5)               // t8 = port
        sll     t8, t8, 0x0002               // t8 = offset
        addu    t3, t3, t8                   // t3 = address of taunt mask index
        lw      t3, 0x0000(t3)               // t3 = taunt mask index
        beqz    t3, _end                     // if 0, then use default mask
        sll     t3, t3, 0x0001               // t3 = taunt mask index * 2 (offset)
        addiu   t3, t3, -0x0002              // t3 = offset to mask
        li      t8, mask_table
        addu    t8, t8, t3                   // t8 = address of mask
        lhu     t7, 0x0000(t8)               // t7 = mask

        _end:
        jr      ra
        sh      t7, 0x01BA(s5)               // original line 1 - set taunt button mask

        mask_table:
        dh CU
        dh CD
        dh CL
        dh CR
        dh DU
        dh DD
        dh DL
        dh DR
    }

    // @ Description
    // This hook prevents the remapped taunt button from causing a jump
    scope prevent_taunt_jump_: {
        // double jump
        OS.patch_start(0xB9E94, 0x8013F454)
        j       prevent_taunt_jump_
        andi    t7, t6, 0x000F               // original line 2 - t7 = 0 if no c button pressed
        OS.patch_end()

        // kirby/puff 3rd and beyond jumps
        OS.patch_start(0xBAB70, 0x80140130)
        j       prevent_taunt_jump_
        andi    t7, t6, 0x000F               // original line 2 - t7 = 0 if no c button pressed
        OS.patch_end()

        // a0 = player struct
        // t6 = pressed button mask

        beqz    t7, _no_jump                 // if no c button pressed, return normally as no jump
        lbu     t6, 0x000D(a0)               // t6 = port

        // If we are here, then a C button press occurred

        li      v0, taunt_mask_per_port
        sll     t6, t6, 0x0002               // t6 = offset to taunt button index
        addu    v0, v0, t6                   // v0 = address of taunt mask index
        lw      v0, 0x0000(v0)               // v0 = taunt mask index
        beqz    v0, _jump                    // if 0, then it's the default taunt button, so return normally as jump
        sll     v0, v0, 0x0001               // v0 = taunt mask index * 2 (offset)
        addiu   v0, v0, -0x0002              // v0 = offset to mask
        li      t6, set_taunt_mask_.mask_table
        addu    t6, t6, v0                   // t6 = address of mask
        lhu     v0, 0x0000(t6)               // v0 = mask

        and     t6, t7, v0                   // t6 = 0 if the taunt button wasn't pressed
        beqz    t6, _jump                    // if the taunt button wasn't pressed, return normally as jump
        nop
        bne     t6, t7, _jump                // if the masks don't match, then a different c button was pressed, so jump
        nop                                  // otherwise, only the remapped taunt button was pressed, so don't jump

        _no_jump:
        jr      ra
        or      v0, r0, r0                   // original line 1 - v0 = jump flag = no jump

        _jump:
        jr      ra
        lli     v0, 0x0001                   // v0 = jump flag = jump
    }
}

} // __JOYPAD__
