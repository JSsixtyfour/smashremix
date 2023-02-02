// Practice.asm (by Fray and bit)
if !{defined __PRACTICE__} {
define __PRACTICE__()
print "included Practice.asm\n"

// @ Description
// This file include enhancements for practice purposes.

include "Global.asm"
include "OS.asm"
include "Toggles.asm"

scope Practice {

    // @ Description
    // first actionable frame for various player states
    constant FAF_LANDING(4)
    constant FAF_HARD_LANDING(8)
    constant FAF_TURN_SLOW(5)
    constant FAF_TURN_FAST(3)

    // @ Description
    // This function checks for various conditions and applies a colour overlay when they are met
    // [Fray]
    scope overlay_colour_: {
        OS.patch_start(0x0005DE0C, 0x800E260C)
        j       overlay_colour_
        nop
        _overlay_colour_return:
        OS.patch_end()
        
        lw      v0, 0x0084(a0)              // original line 1
        lw      t6, 0x0844(v0)              // original line 2
        Toggles.guard(Toggles.entry_practice_overlay, _overlay_colour_return)
        
        
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      t4, 0x0014(sp)              // store t0 - t4
    
        load_flags:
        lbu     t1, 0x000D(v0)              // t1 = player port
        li      t4, flag_overlay            // ~
        add     t4, t1, t4                  // t4 = flag_overlay
        li      t3, flag_perfect_land       // ~
        add     t3, t1, t3                  // t3 = flag_perfect_land
        
        _reset_flag:
        lbu     t1, 0x0000(t4)              // t1 = flag_overlay
        beq     t1, r0, _check_vulnerability// branch if flag_overlay = 0
        nop
        sb      r0, 0x0000(t4)              // reset flag_overlay
        li      t0, 0x7FFFFFFF              // t0 = 7FFFFFFF
        lw      t1, 0x0A88(v0)              // t1 = struct overlay value
        and     t1, t1, t0                  // ~
        sw      t1, 0x0A88(v0)              // reset struct overlay bit
        
        _check_vulnerability:
        // the goal is to determine the vulnerability state based on multiple input values
        // the inputs from the vulnerability state offsets can have 3 possible values
        // after subtracting 0x1 to allow for more efficient code, these values are as follows
        // 0x00 = vulnerable, 0x01 = invulnerable, 0x02 = intangible
        lbu     t0, 0x05AF(v0)              // ~
        subiu   t0, t0, 0x1                 // t0 = input 1 (wall bounces, respawn invincibility)
        lbu     t1, 0x05B7(v0)              // ~
        subiu   t1, t1, 0x1                 // t1 = input 2 (no documented uses)
        or      t1, t1, t0                  // t1 = bitwise OR of t1 and t0
        lbu     t0, 0x05BB(v0)              // ~
        subiu   t0, t0, 0x1                 // t0 = input 3(moveset engine, pika up special)
        or      t1, t1, t0                  // t1 = bitwise OR of t1 and t0
        beq     t1, r0, _check_knockback    // if t1 = 0, the player is vulnerable
        andi    t1, t1, 0x2                 // t1 = 0x2 if the player is intangible; else t1 = 0
        li      t0, Color.high.BLUE         // t0 = RGBA32 BLUE
        bnez    t1, _store                  // if t1 != 0, the player is intangible
        nop
        li      t0, Color.high.GREEN        // t0 = RGBA32 GREEN
        b       _store                      // if this branch is reached the player is invulnerable
        nop
        
        _check_knockback:
        // when a character is in hitstun, their knockback is stored at player struct offset 0x7EC
        // this offset usually returns 0 otherwise, and can be used to help determine if thehitstun
        lw      t0, 0x07EC(v0)              // t0 = current knockback value
        bnez    t0, _hitstun                // branch if knockback != 0
        nop
		
        _check_reflect_absorb:
        lh      t0, 0x018C(v0)              // v0 = current players flag
        andi    t0, t0, 0x0480              // t0 != 0 if reflecting or absorbing
        beqz    t0, _check_action			
        lui     t0, 0x00FF                  // t0 = RGBA32 CYAN
        b       _store
        ori     t0, t0, 0xFFFF              // ~
        
        _check_action:
        lw      t1, 0x0024(v0)              // t1 = action
        ori     t0, r0, 0x000A              // t0 = action id: standing
        beq     t1, t0, _stand              // branch if action = standing
        nop
        ori     t0, r0, 0x0012              // t0 = action id: turning
        beql    t1, t0, _turn               // branch if action = turn
        lbu     t1, 0x000B(v0)              // t1 = char id if the above branch is taken
        ori     t0, r0, 0x001F              // t0 = action id: landing
        beq     t1, t0, _neutral_faf        // branch if current action = landing
        ori     t0, r0, FAF_LANDING         // t0 = FAF_LANDING
        ori     t0, r0, 0x0020              // t0 = action id: hard landing
        beq     t1, t0, _neutral_faf        // branch if current action = hard landing
        ori     t0, r0, FAF_HARD_LANDING    // t0 = 8
        b       _end                        // jump to end
        nop
        
        _hitstun:
        // the hitstun counter is used as an additional hitstun check
        lhu     t0, 0x0B1A(v0)              // t0 = hitstun counter
        beq     t0, r0, _end                // skip to end if t0 = 0
        li      t0, Color.high.RED          // t0 = RGBA32 RED
        b       _store                      // if this branch is reached the player is in hitstun
        nop
        
        _stand:
        // this overlay is skipped if the character was airborne on the previous frame,
        // prevents perfect lands from displaying the overlay when the character isn't actionable
        lbu     t1, 0x0000(t3)              // t1 = ground flag (previous frame)
        bnez    t1, _end                    // skip if flag = air
        nop
        b       _neutral
        nop
        
        _turn:
        // character id in t1
        ori     t0, r0, FAF_TURN_FAST       // t0 = fast turn FAF(falcon/samus)
        ori     t2, r0, 0x0003              // t2 = char id: samus
        beq     t2, t1, _neutral_faf        // branch if char = samus
        ori     t2, r0, 0x0007              // t2 = char id: falcon
        beql    t0, t1, _neutral_faf        // branch if char = falcon
        nop
        ori     t0, r0, FAF_TURN_SLOW       // t0 = slow turn FAF(used by the rest of the cast)

        _neutral_faf:
        // skips overlaying if the current action frame is lower than the first actionable frame
        // this is used to ensure the neutral overlay is only applied to actionable characters
        // t0 = first actionable frame
        lw      t1, 0x001C(v0)              // t1 = action frame count
        bgt     t0, t1, _end                // branch if t0 > t1
        _neutral:
        li      t0, Color.high.YELLOW       // t0 = RGBA32 YELLOW
            
        _store:
        // stores the colour value in the struct and enables the overlay flag
        // t0 = RGBA8888 colour value
        sw      t0, 0x0A68(v0)              // store colour
        lw      t1, 0x0A88(v0)              // t1 = struct overlay value
        lui     t2, 0x8000                  // ~
        or      t1, t1, t2                  // ~
        sw      t1, 0x0A88(v0)              // overwrite struct overlay flag
        ori     t2, r0, 0x0001              // ~
        sb      t2, 0x0000(t4)              // flag_overlay = 0x1
        
        _end:
        lw      t0, 0x014C(v0)              // t0 = ground flag (current frame)
        sb      t0, 0x0000(t3)              // store perfect land flag
        
        _skip:
        // deallocate stack space and load t0-t4
        lw      t4, 0x0014(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t0, 0x0004(sp)              // load t0-t4
        addiu   sp, sp, 0x0018              // deallocate stack space
        j       _overlay_colour_return      // return
        nop
        
        
        flag_perfect_land:
        // acts as a delayed version of the ground/air flag
        // used to prevent the neutral overlay if the player was airborne on the previous frame
        db  0x00                                //P1
        db  0x00                                //P2
        db  0x00                                //P3
        db  0x00                                //P4
        
        flag_overlay:
        // used to determine when to start/stop overlaying colour
        db  0x00                                //P1
        db  0x00                                //P2
        db  0x00                                //P3
        db  0x00                                //P4
        
    }

    // @ Description
    // This function flashes when a z-cancel is successful [bit]
    scope flash_on_z_cancel_: {
        constant Z_CANCEL_WINDOW(10)

        OS.patch_start(0x000CB528, 0x80150AE8)
        jal     flash_on_z_cancel_
        nop
        OS.patch_end()

//      jal     0x80142D9C                  // original line 1
//      nop                                 // original line 2
        Toggles.guard(Toggles.entry_flash_on_z_cancel, 0x80142D9C)

        addiu   sp, sp, -0x0018             // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~        
        sw      v1, 0x000C(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        jal     0x80142D9C                  // original line 1
        nop                                 // original line 2
        lw      v1, 0x000C(sp)              // restore v1
        lw      t0, 0x0160(v1)              // t0 = frame pressed
        slti    t1, t0, Z_CANCEL_WINDOW + 1 // ~
        beqz    t1, _end                    // if within frame window, don't flash
        nop
  
        lw      a0, 0x0004(v1)              // a0 - address of player struct
        lli     a1, 0x0008                  // a1 - flash_id (red from mario's fireball)
        lli     a2, 0x0000                  // a2 - 0
        jal     Global.flash_               // add flash
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

}

} // __PRACTICE__
