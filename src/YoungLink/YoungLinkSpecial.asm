// YoungLink.asm

// This file contains subroutines used by Young Link's special moves.

scope YoungLinkUSP: {
    // @ Description
    // Subroutine for Young Link's up special, allows a direction change with the command 58000002
    scope direction_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x000C(sp)              // store ra
        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _end                // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        sw      a1, 0x0010(sp)              // 0x0010(sp) = player struct

        lw      a1, 0x0010(sp)              // a1 = player struct
        lb      at, 0x01C2(a1)              // ~
        mtc1    at, f2                      // ~
        cvt.s.w f2, f2                      // ~
        abs.s   f2, f2                      // f2 = |stick_x|
        li      at, 0x3C4CCCCD              // ~
        mtc1    at, f4                      // f4 = 0.0125
        mul.s   f2, f2, f4                  // f2 = speed multiplier (|stick_x| * 0.0125)
        lwc1    f4, 0x0044(a1)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        lui     at, 0x4220                  // ~
        mtc1    at, f6                      // f6 = 40
        mul.s   f6, f6, f2                  // ~
        mul.s   f6, f6, f4                  // f6 = final x velocity (38 * (|stick_x|/80)), adjusted for DIRECTION
        swc1    f6, 0x0048(a1)              // store x velocity

        _end:
        lw      ra, 0x000C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }
}

scope YoungLinkDSP: {
    constant MOVING_SPEED(0x4208)           // float32 speed for moving Bombchus
    constant MOVING_FALL_SPEED(0xC1A0)      // float32 initial fall speed for moving Bombchus

    // @ Description
    // Item info array
    // This item is a CLONE of Link's bomb so it's here rather than in Item.asm
    item_info_array:
    constant BOMBCHU_ID(0x15)
    dw BOMBCHU_ID                           // 0x00 - item ID
    dw Character.YLINK_file_1_ptr           // 0x04 - hard-coded pointer to file
    dw 0x40                                 // 0x08 - offset to item footer in file
    dw 0x12000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
    dw 0                                    // 0x10 - ?

    // Is this state unused by link bomb?
    // STATE 0 - UNKNOWN
    dw held_main_                           // 0x14 - main
    dw 0                                    // 0x18 - collision
    dw 0                                    // 0x1C - hitbox collision w/ hurtbox
    dw 0                                    // 0x20 - hitbox collision w/ shield
    dw 0                                    // 0x24 - hitbox collision w/ shield edge
    dw 0                                    // 0x2C - clang?
    dw 0                                    // 0x30 - hitbox collision w/ reflector
    dw 0                                    // 0x34 - hurtbox collision w/ hitbox

    // @ Description
    // Item state table
    item_state_table:
    // STATE 0 - RESTING
    dw resting_main_                        // 0x00 - main
    dw 0x80185F10                           // 0x04 - collision
    dw 0                                    // 0x08 - hitbox collision w/ hurtbox
    dw 0                                    // 0x0C - hitbox collision w/ shield
    dw 0                                    // 0x10 - hitbox collision w/ shield edge
    dw 0                                    // 0x14 - clang?
    dw 0                                    // 0x18 - hitbox collision w/ reflector
    dw hurtbox_collision_                   // 0x1C - hurtbox collision w/ hitbox

    // STATE 1 - BOUNCE
    dw thrown_main_                         // 0x20 - main
    dw 0x80185F38                           // 0x24 - collision
    dw 0                                    // 0x28 - hitbox collision w/ hurtbox
    dw 0                                    // 0x2C - hitbox collision w/ shield
    dw 0                                    // 0x30 - hitbox collision w/ shield edge
    dw 0                                    // 0x34 - clang?
    dw 0                                    // 0x38 - hitbox collision w/ reflector
    dw hurtbox_collision_                   // 0x3C - hurtbox collision w/ hitbox

    // STATE 2 - HELD
    dw held_main_                           // 0x40 - main
    dw 0                                    // 0x44 - collision
    dw 0                                    // 0x48 - hitbox collision w/ hurtbox
    dw 0                                    // 0x4C - hitbox collision w/ shield
    dw 0                                    // 0x50 - hitbox collision w/ shield edge
    dw 0                                    // 0x54 - clang?
    dw 0                                    // 0x58 - hitbox collision w/ reflector
    dw 0                                    // 0x5C - hurtbox collision w/ hitbox

    // STATE 3 - THROWN
    dw thrown_main_                         // 0x60 - main
    dw thrown_collision_                    // 0x64 - collision
    dw 0x80185BFC                           // 0x68 - hitbox collision w/ hurtbox
    dw 0x80186498                           // 0x6C - hitbox collision w/ shield
    dw 0x801733E4                           // 0x70 - hitbox collision w/ shield edge
    dw 0                                    // 0x74 - clang?
    dw reflect_                             // 0x78 - hitbox collision w/ reflector
    dw hurtbox_collision_                   // 0x7C - hurtbox collision w/ hitbox

    // STATE 4 - DROPPED/FALLING
    dw dropped_main_                        // 0x80 - main
    dw thrown_collision_                    // 0x84 - collision
    dw 0x801862AC                           // 0x88 - hitbox collision w/ hurtbox
    dw 0x80186498                           // 0x8C - hitbox collision w/ shield
    dw 0x801733E4                           // 0x90 - hitbox collision w/ shield edge
    dw 0                                    // 0x94 - clang?
    dw reflect_                             // 0x98 - hitbox collision w/ reflector
    dw dropped_hurtbox_collision_           // 0x9C - hurtbox collision w/ hitbox

    // STATE 5 - EXPLODING
    dw exploding_main_                      // 0xA0 - main
    dw 0                                    // 0xA4 - collision
    dw 0                                    // 0xA8 - hitbox collision w/ hurtbox
    dw 0                                    // 0xAC - hitbox collision w/ shield
    dw 0                                    // 0xB0 - hitbox collision w/ shield edge
    dw 0                                    // 0xB4 - clang?
    dw 0                                    // 0xB8 - hitbox collision w/ reflector
    dw 0                                    // 0xBC - hurtbox collision w/ hitbox

    // STATE 6 - MOVING
    dw moving_main_                         // 0xC0 - main
    dw moving_collision_                    // 0xC4 - collision
    dw begin_explosion_                     // 0xC8 - hitbox collision w/ hurtbox
    dw begin_explosion_                     // 0xCC - hitbox collision w/ shield
    dw 0                                    // 0xD0 - hitbox collision w/ shield edge
    dw 0                                    // 0xD4 - clang?
    dw reflect_                             // 0xD8 - hitbox collision w/ reflector
    dw hurtbox_collision_                   // 0xDC - hurtbox collision w/ hitbox

    // @ Description
    // Updates the direction of the Bombchu's graphic to match the item's facing direction.
    // @ Arguments
    // a0 - item object
    scope update_direction_: {
        lw      t0, 0x0084(a0)              // t0 = item special struct
        lw      t1, 0x0074(a0)              // t1 = item joint 0 struct
        lw      t2, 0x0024(t0)              // t2 = item direction
        li      at, 0x40490FDB              // at = 3.14159 rads/180 degrees
        bgez    t2, pc() + 12               // if direction is positive...
        sw      r0, 0x0034(t1)              // ...z rotation = 0 degrees
        sw      at, 0x0034(t1)              // else, z rotation = 180 degrees
        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Ends active sound effect for Bombchus.
    // @ Arguments
    // a0 - item object
    scope end_fgm_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      v0, 0x0018(sp)              // store v0
        lw      t0, 0x0084(a0)              // t0 = item special struct
        lw      t1, 0x01D0(t0)              // t1 = FGM pointer
        beqz    t1, _end                    // end if FGM pointer = 0
        sw      ra, 0x0014(sp)              // store ra

        // if there is an FGM pointer
        sw      r0, 0x01D0(t0)              // reset FGM pointer
        lhu     at, 0x0026(t1)              // at = FGM id
        beqz    at, _end                    // end if FGM id = 0
        lw      t2, 0x01D4(t0)              // t2 = stored FGM id

        // if the pointer has an id
        bne     at, t2, _end                // end if FGM id != stored FGM id
        sw      r0, 0x01D4(t0)              // reset store FGM id

        // if here, end the FGM
        jal     0x80026738                  // end FGM
        or      a0, t1, r0                  // a0 = FGM pointer

        _end:
        lw      ra, 0x0014(sp)              // load ra
        lw      v0, 0x0018(sp)              // load v0
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Changes a Bombchu to the moving state.
    // a0 = item object
    scope begin_moving_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = item special struct
        lui     at, MOVING_SPEED            // ~
        mtc1    at, f2                      // f2 = MOVING_SPEED
        lwc1    f4, 0x0024(a0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = MOVING_SPEED * DIRECTION
        // sw      r0, 0x010C(a0)           // disable hitbox
        lbu     t0, 0x02CE(a0)              // t0 = unknown bitfield
        // ori     t0, t0, 0x0080           // enables item pickup bit
        andi    t0, t0, 0x00CF              // disable 2 bits
        sb      t0, 0x02CE(a0)              // store updated bitfield
        sw      r0, 0x0108(a0)              // kinetic state = 0 (grounded)
        sw      r0, 0x0030(a0)              // y speed = 0
        sw      r0, 0x0034(a0)              // z speed = 0
        swc1    f2, 0x002C(a0)              // x speed = MOVING_SPEED * DIRECTION
        jal     0x80185CD4                  // bomb subroutine, sets an unknown value to 0x1
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      a0, 0x0018(sp)              // a0 = item object
        li      a1, item_state_table        // a1 = object state base address
        jal     0x80172EC8                  // change item state
        ori     a2, r0, 0x0006              // a2 = 6 (moving state)
        lw      a0, 0x0018(sp)              // ~
        lw      t6, 0x0084(a0)              // t6 = item special struct
        lbu     at, 0x02CF(t6)              // at = bit field
        ori     at, at, 0x0020              // ~
        sb      at, 0x02CF(t6)              // enable bitflag for bonus damage
        jal     update_direction_           // update graphic direction if necessary
        lw      a0, 0x0018(sp)              // a0 = item object
        jal     0x800269C0                  // play FGM
        lli     a0, 0x0455                  // a0 = FGM id
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = item special struct
        sw      v0, 0x01D0(a0)              // store FGM pointer
        beqzl   v0, _end                    // if no FGM was created, skip...
        sw      r0, 0x01D4(a0)              // ...and store FGM id (none)

        lhu     at, 0x0026(v0)              // at = FGM id
        sw      at, 0x01D4(a0)              // store FGM id

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Begins an explosion for moving Bombchus
    // Ensures the object isn't destroyed
    scope begin_explosion_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80186368                  // original begin explosion function
        nop
        lw      ra, 0x0014(sp)              // restore ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0
    }

    // @ Description
    // Begins falling for moving Bombchus
    // Sets Y velocity
    scope begin_falling_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80185CD4                  // original subroutine
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      v0, 0x0084(a0)              // v0 = item special struct
        //addiu   t6, r0, 0x000A              // ~
        //sh      t6, 0x0352(v0)              // set invincibility timer
        sh      r0, 0x0352(v0)              // set invincibility timer to 0
        lbu     at, 0x02CF(v0)              // at = bit field
        ori     at, at, 0x0080              // ~
        sb      at, 0x02CF(v0)              // enable unknown bitflag
        li      a1, item_state_table        // a1 = object state base address
        jal     0x80172EC8                  // change item state
        ori     a2, r0, 0x0004              // a2 = 4 (falling state)
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      v0, 0x0084(a0)              // v0 = item special struct
        lui     at, MOVING_FALL_SPEED       // ~
        sw      at, 0x0030(v0)              // y velocity = MOVING_FALL_SPEED
        lli     at, 0x0001                  // ~
        jal     update_direction_           // update graphic direction if necessary
        sw      at, 0x0108(v0)              // kinetic state = aerial
        lw      ra, 0x0014(sp)              // restore ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0
    }

    // @ Description
    // Main function for Bombchu's resting state
    scope resting_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80185DCC                  // original main function
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        jal     end_fgm_                    // end fgm
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for Bombchu's bounce/thrown state
    scope thrown_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80185CF0                  // original main function
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        jal     end_fgm_                    // end fgm
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for Bombchu's dropped state
    scope dropped_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80186270                  // original main function
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        jal     end_fgm_                    // end fgm
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for the Bombchu's held state
    scope held_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80186024                  // original main function
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      t0, 0x0084(a0)              // t0 = item special struct
        lw      t1, 0x0074(a0)              // t1 = item joint 0 struct
        lw      t2, 0x0008(t0)              // t2 = item owner object
        beqz    t2, _end                    // end if there's no owner
        lw      t1, 0x0010(t1)              // t1 = item joint 1 struct

        lw      t2, 0x0084(t2)              // t2 = owner special struct (presumed player)
        lw      t2, 0x0044(t2)              // t2 = owner direction
        sw      t2, 0x0024(t0)              // item direction = owner direction
        li      at, 0x40490FDB              // at = 3.14159 rads/180 degrees
        bgez    t2, pc() + 12               // if direction is positive...
        sw      r0, 0x0034(t1)              // ...z rotation = 0 degrees
        sw      at, 0x0034(t1)              // else, z rotation = 180 degrees

        _end:
        jal     end_fgm_                    // end fgm
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for Bombchu's exploding state
    scope exploding_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80186524                  // original main function
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        jal     end_fgm_                    // end fgm
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for the Bombchu's moving state
    // Based on Link bomb @80185DCC
    // Lines pertaining to horizontal deceleration have been removed.
    scope moving_main_: {
        addiu   sp, sp,-0x0020
        sw      ra, 0x0014(sp)
        sw      a0, 0x0020(sp)
        lw      a3, 0x0084(a0)
        lw      v1, 0x02C0(a3)
        lw      a0, 0x0020(sp)
        bnezl   v1, _branch_1
        mtc1    v1, f4
        jal     0x80186368
        sw      a3, 0x001c(sp)
        lw      a3, 0x001c(sp)
        lw      v1, 0x02C0(a3)
        mtc1    v1, f4

        _branch_1:
        lui     at, 0x42c0
        mtc1    at, f8
        cvt.s.w f0, f4
        lw      a0, 0x0020(sp)
        addiu   a1, r0, 0x004F
        addiu   a2, r0, 0x0060
        c.eq.s  f8, f0
        nop
        bc1fl   _branch_2
        lui     at, 0x42C0
        jal     0x80172F98
        sw      a3, 0x001C(sp)
        lw      a3, 0x001C(sp)
        addiu   t8, r0, 0x0001
        lw      v1, 0x02C0(a3)
        sh      t8, 0x0354(a3)
        mtc1    v1, f10
        nop
        cvt.s.w f0, f10
        lui     at, 0x42C0

        _branch_2:
        mtc1    at, f16
        lw      a0, 0x0020(sp)
        c.lt.s  f0, f16
        nop
        bc1fl   _end + 0x4
        addiu   t9, v1, 0xFFFF
        jal     0x801859C0
        sw      a3, 0x001C(sp)
        lw      a3, 0x001C(sp)
        lw      v1, 0x02C0(a3)

        _end:
        addiu   t9, v1, 0xFFFF
        sw      t9, 0x02C0(a3)

        // spawn a footstep gfx every 8 frames
        lw      t6, 0x02C0(a3)              // ~
        andi    t6, t6, 0x0007              // ~
        bnez    t6, _skip                   // branch if timer value does not end in 0b000 (branch won't be taken once every 8 frames)
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = object x/y/z coordinates
        lw      a1, 0x0024(a3)              // a1 = item direction
        jal     0x800FF048                  // create footstep gfx
        lui     a2, 0x3F80                  // a2 = scale? float32 1

        _skip:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        or      v0, r0, r0
    }

    // @ Description
    // Collision function for thrown/dropped Bombchus
    // Based on Link bomb @80186150
    // Explosion check lines are commented out.
    scope thrown_collision_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(ap) = item object
        lw      v0, 0x0084(a0)              // v0 = item special struct
        //lw      t8, 0x002C(v0)              // t8 = x velocity
        //sw      t8, 0x0024(sp)              // 0x0024(sp) = x velocity
        //lw      t8, 0x002C(v0)              // t8 = y velocity
        //sw      t8, 0x0028(sp)              // 0x0028(sp) = y velocity
        //sw      r0, 0x002C(sp)              // don't think this is used, but just in case treat z velocity as 0
        addiu   a0, v0, 0x0038              // a0 = x/y/z position
        li      a1, 0x801736B4              // a1 = detect_collision_
        lw      a2, 0x0038(sp)              // a2 = item object
        jal     0x800DA034                  // collision detection
        ori     a3, r0, 0x0C21              // bitmask (all collision types)
        sw      v0, 0x0030(sp)              // store collision result
        lw      a0, 0x0038(sp)              // a0 = item object
        ori     a1, r0, 0x0C21              // bitmask (all collision types)
        lui     a2, 0x3EC0                  // a2 = bounce multiplier
        jal     0x801737EC                  // apply collsion/bounce?
        or      a3, r0, r0                  // a3 = 0
        beqz    v0, _end                    // end if no collision was detected
        nop

        // if collision was detected
        jal     0x80185FD8                  // bomb begin bounce routine
        lw      a0, 0x0038(sp)              // a0 = item object

        lw      a0, 0x0038(sp)              // a0 = item object
        lw      v0, 0x0084(a0)              // v0 = item special struct
        lhu     t6, 0x0092(v0)              // t6 = collision flags
        andi    t6, t6, 0x0800              // t6 = collision flags | grounded bitmask
        beqz    t6, _end                    // branch if ground collision flag = FALSE
        nop

        // if the Bombchu is colliding with a floor, begin movement state
        jal     begin_moving_               // begin moving
        nop
        //b       _end                        // branch to end
        //nop
        //
        //_check_explosion:
        //lwc1    f2, 0x0024(sp)              // ~
        //mtc1    r0, f12                     // ~
        //lui     at, 0x4210                  // ~
        //mtc1    at, f4                      // ~
        //c.lt.s  f2, f12                     // ~
        //lui     at, 0x41C8                  // ~
        //bc1fl   _check_x                    // ~
        //mov.s   f0, f2                      // ~
        //b       _check_x                    // ~
        //neg.s   f0, f2                      // ~
        //mov.s   f0, f2                      // sets up registers for x speed check
        //_check_x:
        //c.lt.s  f4, f0                      // ~
        //lwc1    f2, 0x0028(sp)              // ~
        //bc1t    _begin_explosion            // begin an explosion if x speed is too high
        //nop
        //
        //c.lt.s  f2, f12                     // ~
        //mtc1    at, f6                      // ~
        //bc1fl   _check_y                    // ~
        //mov.s   f0, f2                      // ~
        //b       _check_y                    // ~
        //neg.s   f0, f2                      // ~
        //mov.s   f0, f2                      // sets up registers for y xpeed check
        //_check_y:
        //c.lt.s  f6, f0                      // ~
        //nop                                 // ~
        //bc1fl   _end                        // skip explosion if y speed isn't high enough
        //nop
        //
        //_begin_explosion:
        //jal     0x80186368                  // begin exploding
        //nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0 (don't destroy)
    }

    // @ Description
    // Collision function for moving Bombchus
    scope moving_collision_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, begin_falling_          // a1 = begin_falling_
        jal     0x801735A0                  // generic resting collision?
        sw      a0, 0x0018(sp)              // 0x0018(ap) = item object
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      v0, 0x0084(a0)              // v0 = item special struct
        lw      t6, 0x0108(v0)              // t6 = kinetic state
        bnez    t6, _end                    // skip if kinetic state != grounded
        nop

        lhu     t6, 0x008E(v0)              // t6 = collision flags
        andi    t6, t6, 0x0021              // t6 = collision flags | left/right wall bitmask
        beqz    t6, _end                    // skip if wall collision flags = FALSE
        lui     at, MOVING_SPEED            // at = MOVING_SPEED
        andi    t6, t6, 0x0001              // t6 = collision flags | left wall bitmask
        bnezl   t6, pc() + 8                // if left wall collision = TRUE...
        lui     at, MOVING_SPEED | 0x8000   // ...at = -MOVING_SPEED
        sw      at, 0x002C(v0)              // update x speed
        bnezl   t6, pc() + 12               // if left wall collision = TRUE...
        addiu   at, r0, -1                  // ...at = -1
        addiu   at, r0, 1                   // else, at = 1
        jal     update_direction_           // update graphic direction if necessary
        sw      at, 0x0024(v0)              // update item direction

        _end:
        lw      ra, 0x0014(sp)              // restore ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0
    }

    // @ Description
    // General hurtbox collision function for Bombchus
    scope hurtbox_collision_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80185B84                  // run original function
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        jal     update_direction_           // update graphic direction if necessary
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // restore ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0
    }

    // @ Description
    // Hurtbox collision function for dropped Bombchus
    scope dropped_hurtbox_collision_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x801862E0                  // run original function
        sw      a0, 0x0018(sp)              // 0x0018(sp) = item object
        jal     update_direction_           // update graphic direction if necessary
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // restore ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0
    }

    // @ Description
    // Reflect function for Bomchus
    scope reflect_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     0x80173434                  // original reflect routine
        sw      a0, 0x0018(sp)              // store a0
        // f6 = direction (float)
        lw      a0, 0x0018(sp)              // ~
        lw      a1, 0x0084(a0)              // a1 = projectile special struct
        cvt.w.s f6, f6                      // f6 = direction (int)
        swc1    f6, 0x0024(a1)              // store new project direction
        jal     update_direction_           // update graphic direction if necessary
        lw      a0, 0x0018(sp)              // a0 = item object
        lw      ra, 0x0014(sp)              // deallocate stack space
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0
    }

    // @ Description
    // Patch which redirects to the Bombchu's item state table on state change
    scope state_change_: {
        OS.patch_start(0xED908, 0x80172EC8)
        j       state_change_
        addiu   sp, sp, -0x20               // original line 1
        _return:
        OS.patch_end()

        // a0 = item object
        sw      ra, 0x0014(sp)              // original line 2
        lw      t5, 0x0084(a0)              // t5 = item special struct
        lw      t6, 0x000C(t5)              // t6 = item ID
        lli     at, BOMBCHU_ID              // at = BOMBCHU_ID
        bne     at, t6, _end                // skip if item ID != BOMBCHU_ID
        lw      t6, 0x0100(t5)              // t6 = character id
        lli     at, Character.id.YLINK      // at = id.YLINK
        bne     at, t6, _end                // skip if character id != YLINK
        nop

        // if we're here the current item's ID matches a Link bomb and the item was created by YLINK, so treat it as a Bombchu
        li      a1, item_state_table        // a1 = item state table

        _end:
        j       _return                     // return
        nop
    }

    // @ Description
    // this routine gets run by whenever a projectile crosses the blast zone. The purpose here is to end the bombchu sound.
    scope bombchu_blast_zone_: {
        addiu   sp, sp, -0x0010
        sw      ra, 0x0008(sp)
        jal     end_fgm_                // end fgm
        nop
        lw      ra, 0x0008(sp)
        addiu   sp, sp, 0x0010
        jr      ra                      // return
        ori     v0, r0, 0x0001          // destroy item object
    }
}