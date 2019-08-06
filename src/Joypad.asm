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
        bne     t0, a0, _end                // if (mask != button_mask), skip
        nop
        lli     v0, OS.TRUE

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
    // a1 - whatever you like!
    // a2 - type
    // @ Returns
    // v0 - bool
    scope check_buttons_all_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers
        
        // player 1
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0000                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        jal     Joypad.check_buttons_       // v0 = bool (p1)
        nop
        move    t0, v0                      // t0 = return

        // player 2
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0001                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        jal     Joypad.check_buttons_       // v0 = bool (p2)
        nop
        or      t0, t0, v0                  // t0 = bool (p1/p2)

        // player 3
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0002                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        jal     Joypad.check_buttons_       // v0 = bool (p3)
        nop
        or      t0, t0, v0                  // at = bool (p1/p2/p3)

        // player 4
        lw      a0, 0x0004(sp)              // a0 - button mask
        lli     a1, 0x0003                  // a1 - player
        lw      a2, 0x000C(sp)              // a2 - type
        jal     Joypad.check_buttons_       // v0 = bool (p4)
        nop
        or      t0, t0, v0                  // at = bool (p1/p2/p3/p4)
        move    v0, t0                      // v0 = ret = bool (p1/p2/p3/p4)

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // save registers
        addiu   sp, sp, 0x0018              // deallocate stack space
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
    // @ Arguments
    // a0 - POSITIVE/uint min coordinate (deadzone)
    scope update_stick_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // save registers

        _left:
//      lw      a0, 0x0010(sp)              // a0 - min coordinate (deadzone)
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
        lw      a0, 0x0010(sp)              // a0 - min coordinate (deadzone)
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
        lw      a0, 0x0010(sp)              // a0 - min coordinate (deadzone)
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
        lw      a0, 0x0010(sp)              // a0 - min coordinate (deadzone)
        lli     a1, 0x0001                  // a1 - enum down/up
        jal     check_stick_y_              // check stick y
        nop
        li      t0, frames_held             // t0 = address of frames_held
        beqzl   v0, _end                    // if (ret == 0), skip
        sw      r0, 0x000C(t0)              // if (ret == 0),  frames_held.up = 0
        lw      t1, 0x000C(t0)              // t1 = frames_held.up
        addiu   t1, t1, 0x0001              // ~
        sw      t1, 0x000C(t0)              // frames_held.up++

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~ 
        lw      a1, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }


    frames_held:
    dw 0x00000000                       // left
    dw 0x00000000                       // right
    dw 0x00000000                       // down
    dw 0x00000000                       // up
}

} // __JOYPAD__