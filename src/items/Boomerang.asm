// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_) // bomb is 0x80177D9C
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_boomerang)
constant PICKUP_ITEM_INIT(prepickup_) // prepickup
constant DROP_ITEM(0x801745FC) // same as Maxim Tomato
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(OS.FALSE)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xE0)

// edit these as needed
constant BASE_DAMAGE(1)					    // base damage
constant BKB(70)					        // base knockback
constant KBG(40)					        // knockback growth
constant KB_ANGLE(68)
constant THROW_TIMER(28)			        // number of frames the boomerang will travel before turning
constant RETURN_TIMER(40)                   // number of frames the boomerang will return for
constant TURN_ACCEL(0x3D60)                 // float32 multiplier for turn acceleration
constant CATCH_RANGE_X(0x438C)              // float32 width for item catch range
constant CATCH_RANGE_LY(0xC2C8)             // float32 lower y range for item catch
constant CATCH_RANGE_UY(0x43DC)             // float32 upper y range for item catch

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw Character.MARINA_file_8_ptr          // 0x04 - hard-coded pointer to file
dw FILE_OFFSET                          // 0x08 - offset to item footer in file
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?

// @ Description
// Item state table
item_state_table:
// STATE 0 - PREPICKUP - GROUNDED
dw 0                                    // 0x00 - main
dw 0x801744FC                           // 0x04 - collision
dw 0                                    // 0x08 - hitbox collision w/ hurtbox
dw 0                                    // 0x0C - hitbox collision w/ shield
dw 0                                    // 0x10 - hitbox collision w/ shield edge
dw 0                                    // 0x14 - clang?
dw 0                                    // 0x18 - hitbox collision w/ reflector
dw 0                                    // 0x1C - hurtbox collision w/ hitbox

// STATE 1 - PREPICKUP - AERIAL
dw 0x801744C0                           // 0x20 - main
dw 0x80174524                           // 0x24 - collision
dw 0                                    // 0x28 - hitbox collision w/ hurtbox
dw 0                                    // 0x2C - hitbox collision w/ shield
dw 0                                    // 0x30 - hitbox collision w/ shield edge
dw 0                                    // 0x34 - clang?
dw 0                                    // 0x38 - hitbox collision w/ reflector
dw 0                                    // 0x3C - hurtbox collision w/ hitbox

// STATE 2 - PICKUP
dw 0                                    // 0x40 - main
dw 0                                    // 0x44 - collision
dw 0                                    // 0x48 - hitbox collision w/ hurtbox
dw 0                                    // 0x4C - hitbox collision w/ shield
dw 0                                    // 0x50 - hitbox collision w/ shield edge
dw 0                                    // 0x54 - clang?
dw 0                                    // 0x58 - hitbox collision w/ reflector
dw 0                                    // 0x5C - hurtbox collision w/ hitbox

// STATE 3 - thrown
dw thrown_main_                         // 0x60 - main
dw throw_collision_                     // 0x64 - collision
dw throw_collide_                       // 0x68 - hitbox collision w/ hurtbox
dw shield_collision_                    // 0x6C - hitbox collision w/ shield
dw 0x801733E4                           // 0x70 - hitbox collision w/ shield edge
dw 0                                    // 0x74 - clang?
dw reflect_                             // 0x78 - hitbox collision w/ reflector
dw hurtbox_collision_                   // 0x7C - hurtbox collision w/ hitbox

// STATE 4 - turning
dw turn_main_                           // 0x80 - main
dw turn_collision_                      // 0x84 - collision
dw turn_collide_                        // 0x88 - hitbox collision w/ hurtbox
dw shield_collision_                    // 0x8C - hitbox collision w/ shield
dw 0x801733E4                           // 0x90 - hitbox collision w/ shield edge
dw 0                                    // 0x94 - clang?
dw reflect_                             // 0x98 - hitbox collision w/ reflector
dw hurtbox_collision_                   // 0x9C - hurtbox collision w/ hitbox

// STATE 5 - returning
dw return_main_                         // 0xA0 - main
dw return_collision_                    // 0xA4 - collision
dw return_collide_                      // 0xA8 - hitbox collision w/ hurtbox
dw shield_collision_                    // 0xAC - hitbox collision w/ shield
dw 0x801733E4                           // 0xB0 - hitbox collision w/ shield edge
dw 0                                    // 0xB4 - clang?
dw reflect_                             // 0xB8 - hitbox collision w/ reflector
dw hurtbox_collision_                   // 0xBC - hurtbox collision w/ hitbox

// STATE 6 - falling
dw falling_main_                        // 0x20 - main
dw 0x801745CC                           // 0x24 - collision
dw 0                                    // 0x28 - hitbox collision w/ hurtbox
dw 0                                    // 0x2C - hitbox collision w/ shield
dw 0                                    // 0x30 - hitbox collision w/ shield edge
dw 0                                    // 0x34 - clang?
dw 0                                    // 0x38 - hitbox collision w/ reflector
dw 0                                    // 0x3C - hurtbox collision w/ hitbox


// @ Description
// spawns the boomerang, based on bob-ombs spawn routine @0x80177D9C
scope stage_setting_: {
    addiu   sp, sp, -0x80               // allocate stackspace
    sw      a2, 0x0050(sp)              // save a previous sp value to sp
    sw      s0, 0x0020(sp)              // save s0
    sw      a0, 0x001C(sp)              // save owner object (presumed player object)
    or      a2, a1, r0                  // a2 = a1(?)
    sw      a1, 0x004c(sp)              // save a1(?)
    or      s0, a3, r0                  // s0 = a3 (boolean ?)
    sw      ra, 0x0024(sp)              // save ra

    li      a1, item_info_array         // a1 = items info array
    lw      a3, 0x0050(sp)              // a3 = unknown sp pointer
    jal     0x8016E174                  // spawn item
    sw      s0, 0x0010(sp)              // save boolean(?) to sp
    beqz    v0, _end                    // skip if no item was spawned

    or      a3, v0, r0                  // a3 = item object
    lw      v0, 0x0074(v0)              // load item position struct

    // rendering stuff
    addiu   t6, sp, 0x0030              // t6 = sp + 0x30
    or      a0, a3, r0
    addiu   v1, v0, 0x001C              // v1 = substruct in position struct
    lw      t8, 0x0000(v1)              // load ? from substruct
    sw      t8, 0x0000(t6)              // save value
    lw      t7, 0x0004(v1)              // load ? from substruct
    sw      t7, 0x0004(t6)              // save value
    lw      t8, 0x0008(v1)              // load render/view matrix ptr?
    sw      t8, 0x0008(t6)              // save value

    lw      s0, 0x0084(a3)              // s0 = item struct
    sh      r0, 0x033e(s0)              // set flag used for bomb to 0
    sw      a3, 0x0044(sp)
    sw      v1, 0x002c(sp)              // save substruct address
    jal     0x8017279C                  // unknown. Used with bob-omb and bumper
    sw      v0, 0x0040(sp)
    lw      a0, 0x0040(sp)
    addiu   a1, r0, 0x002E              // argument 1 = render routine index?
    jal     0x80008CC0                  // apply render routine
    or      a2, r0, r0                  // argument 2 = 0

    addiu   t0, sp, 0x0030              // this seems related to rendering
    lw      t2, 0x0000(t0)              // load ? from substruct
    lw      t9, 0x002C(sp)              // save
    mtc1    r0, f4
    or      a0, s0, r0
    sw      t2, 0x0000(t9)
    lw      t1, 0x0004(t0)              // load ? from substruct
    sw      t1, 0x0004(t9)              // save value
    lw      t2, 0x0008(t0)              // load ? from substruct
    sw      t2, 0x0008(t9)              // save value

    // // SET BASE DAMAGE
    lli		at, BASE_DAMAGE             // at = base damage
    sw		at, 0x0110(s0)              // overwrite base damage
    lli     at, KBG              		// at = kb growth
    sw      at, 0x0140(s0)           	// overwrite
    lli		at, BKB              		// at = base knockback
    sw      at, 0x0148(s0)              // overwrite
	lli		at, KB_ANGLE                // at = knockback angle
    sw      at, 0x013C(s0)           	// overwrite

	// SET FGM
    addiu   at, r0, 0x001F			    // at = heavy kick FGM
    sh      at, 0x156(s0)               // overwrite hb fgm

    _continue:
    lbu     t4, 0x02d3(s0)            // original code here
    ori     t5, t4, 0x0004
    sb      t5, 0x02d3(s0)
    lw      t6, 0x0040(sp)
    jal     0x80111EC0                // Common subroutine seems to be used for items
    swc1    f4, 0x0038(t6)
    lw      a3, 0x0044(sp)
    sw      v0, 0x0348(s0)

    _end:
    lw      ra, 0x0024(sp)
    lw      s0, 0x0020(sp)
    addiu   sp, sp, 0x80
    jr      ra
    or      v0, a3, r0

}

// @ Description
// based on bobbomb throw routine @ 0x80177590
scope throw_initial_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x0014(sp)
    lw      v0, 0x0084(a0)          // v0 = item special struct
    lli     at, THROW_TIMER         // ~
    sw      at, 0x01CC(v0)          // store THROW_TIMER
    jal     0x80177208
    sw      a0, 0x0018(sp)
    li      a1, item_state_table
    lw      a0, 0x0018(sp)
    jal     0x80172EC8              // change item state
    addiu   a2, r0, 0x0003          // state = 3(thrown)
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x30
    jr      ra
    nop
}

// @ Description
// initial routine for turn state
scope turn_initial_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw		at, 0x002C(v0)			        // at = x velocity
    bnel    at, r0, _continue               // branch if x velocity != 0...
    sw      r0, 0x01D0(v0)                  // ...and set target axis to x

    // if x velocity was 0
    lli     at, 0x0001                      // ~
    sw      at, 0x01D0(v0)                  // set target axis to y
    lw      at, 0x0030(v0)                  // at = y velocity

    _continue:
    mtc1    at, f2                          // f2 = velocity
    neg.s   f6, f2                          // f6 = target velocity
    lui     at, TURN_ACCEL                  // ~
    mtc1    at, f4                          // f4 = TURN_ACCEL
    mul.s   f8, f6, f4                      // f8 = acceleration value
    swc1    f6, 0x01D4(v0)                  // store target velocity
    swc1    f8, 0x01D8(v0)                  // store acceleration value
    li      a1, item_state_table            // a1 = state table
    jal     0x80172EC8                      // change item state
    addiu   a2, r0, 0x0004                  // state = 4 (turn)
    lw      a0, 0x0018(sp)                  // ~
    lw      t6, 0x0084(a0)                  // t6 = item special struct
    lbu     at, 0x02CF(t6)                  // at = bit field
    ori     at, at, 0x0020                  // ~
    sb      at, 0x02CF(t6)                  // enable bitflag for bonus damage
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x30
    jr      ra
    nop
}

// @ Description
// initial routine for return state
scope return_initial_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lli     at, RETURN_TIMER                // ~
    sw      at, 0x01CC(v0)                  // store RETURN_TIMER
    li      a1, item_state_table
    jal     0x80172EC8                      // change item state
    addiu   a2, r0, 0x0005                  // state = 5(return)
    lw      a0, 0x0018(sp)                  // ~
    lw      t6, 0x0084(a0)                  // t6 = item special struct
    lbu     at, 0x02CF(t6)                  // at = bit field
    ori     at, at, 0x0020                  // ~
    sb      at, 0x02CF(t6)                  // enable bitflag for bonus damage
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x30
    jr      ra
    nop
}

// @ Description
// initial routine for falling state
scope falling_initial_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x0014(sp)
    lw      v1, 0x0084(a0)                  // v1 = item special struct
    sw      r0, 0x0248(v1)                  // disable hurtbox
    sw      r0, 0x010C(v1)                  // disable hitbox
    li      a1, item_state_table
    jal     0x80172EC8                      // change item state
    addiu   a2, r0, 0x0006                  // state = 6(falling)
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x30
    jr      ra
    nop
}

// @ Description
// based on bob-omb throw physics @ 0x80177530 but no gravity
scope thrown_main_: {
	addiu	sp, sp, -0x30                   // allocate stack space
	sw   	ra, 0x0014(sp)                  // store ra
    sw   	a0, 0x0018(sp)                  // store a0

	lw		a2, 0x0084(a0)			        // a2 = item struct
    lw      t0, 0x01CC(a2)                  // t0 = current THROW_TIMER value
    lli     at, THROW_TIMER                 // at = initial THROW_TIMER value
    bne     t0, at, _rotation               // branch after first frames
    nop

	lw		at, 0x002C(a2)			        // at = x velocity
	beqz	at, _rotation                   // branch if one of the velocitys are already 0
	lw		at, 0x0030(a2)			        // at = y velocity
	l.s		f6, 0x002C(a2)			        // f6 = x velocity
	beqz	at, _rotation                   // ~
	l.s		f8, 0x0030(a2)			        // f8 = y velocity

	abs.s	f6, f6					        // get absolute x value
	nop
	abs.s	f8, f8					        // get absolute y value
	nop
	c.le.s	f6, f8					        // compare which is larger
	nop
	bc1fl	_rotation                       // which one is lower
	sw		r0, 0x0030(a2)			        // set y velocity to 0
	sw		r0, 0x002C(a2)			        // or set x velocity to 0

	_rotation:
    jal  	apply_rotation_                 // apply rotation
    lw   	a0, 0x0018(sp)                  // a0 = item object

    lw   	a0, 0x0018(sp)                  // ~
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      t0, 0x01CC(v0)                  // t0 = THROW_TIMER
    addiu   t0, t0,-0x0001                  // decrement THROW_TIMER
    bnez    t0, _end                        // skip if THROW_TIMER hasn't reached 0
    sw      t0, 0x01CC(v0)                  // store updated THROW_TIMER

    // when THROW_TIMER reaches 0
    jal     turn_initial_                   // begin turning
    lw      a0, 0x0018(sp)                  // a0 = item object

    _end:
	lw   	ra, 0x0014(sp)                  // load ra
	addiu	sp, sp, 0x30                    // deallocate stack space
	jr   	ra                              // return
	or   	v0, r0, r0                      // return 0 (don't destroy)
}

// @ Description
// Main function for turn state.
scope turn_main_: {
	addiu	sp, sp, -0x18                   // allocate stack space
	sw   	ra, 0x0014(sp)                  // store ra
    sw   	a0, 0x0018(sp)                  // store a0

	_rotation:
    jal  	apply_rotation_                 // apply rotation
    lw   	a0, 0x0018(sp)                  // a0 = item object

    lw      a0, 0x0018(sp)                  // ~
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      t0, 0x01D0(v0)                  // t0 = target axis
    beql    t0, r0, _apply_acceleration     // branch if target axis = 0(x)...
    addiu   t1, v0, 0x002C                  // ...and t1 = x velocity address
    addiu   t1, v0, 0x0030                  // t1 = y velocity address

    _apply_acceleration:
    lwc1    f2, 0x0000(t1)                  // f2 = velocity
    lwc1    f4, 0x01D8(v0)                  // f4 = acceleration value
    add.s   f2, f2, f4                      // apply acceleration to velocity
    lwc1    f6, 0x01D4(v0)                  // f6 = target velocity
    abs.s   f8, f2                          // f8 = absolute velocity
    abs.s   f10, f6                         // f10 = absolute target velocity
    c.lt.s  f10, f8                         // check if new velocity < target velocity
    nop
    bc1fl   _end                            // skip if new velocity < target velocity
    swc1    f2, 0x0000(t1)                  // ...and update velocity

    _change_state:
    swc1    f6, 0x0000(t1)                  // velocity = target velocity
    jal     return_initial_                 // change item state
    lw      a0, 0x0018(sp)                  // a0 = item object

    _end:
	lw   	ra, 0x0014(sp)                  // load ra
	addiu	sp, sp, 0x18                    // deallocate stack space
	jr   	ra                              // return
	or   	v0, r0, r0                      // return 0 (don't destroy)
}

// @ Description
// Main function for return state.
scope return_main_: {
	addiu	sp, sp, -0x18                   // allocate stack space
	sw   	ra, 0x0014(sp)                  // store ra
    sw   	a0, 0x0018(sp)                  // store a0

	_rotation:
    jal  	apply_rotation_                 // apply rotation
    lw   	a0, 0x0018(sp)                  // a0 = item object

    _check_catch:
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      t6, 0x0084(a0)                  // t6 = item special struct
    lw      a1, 0x0008(t6)                  // a1 = owner object
    beqz    a1, _timer                      // skip if there's no owner object
    lli     at, 0x03E8                      // at = 0x03E8 (player type)
    lw      t6, 0x0000(a1)                  // t6 = owner object type
    bne     at, t6, _timer                  // skip if owner object is not a player object
    nop
    // if the item owner is a player, check to see if they can catch the boomerang
    jal     handle_item_catch_              // check for item catch
    nop

    _timer:
    lw   	a0, 0x0018(sp)                  // ~
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      t0, 0x01CC(v0)                  // t0 = RETURN_TIMER
    addiu   t0, t0,-0x0001                  // decrement RETURN_TIMER
    bnez    t0, _end                        // skip if RETURN_TIMER hasn't reached 0
    sw      t0, 0x01CC(v0)                  // store updated RETURN_TIMER

    // when RETURN_TIMER reaches 0
    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0x3F00                      // a1 = speed multiplier
    jal     falling_initial_                // begin falling
    lw      a0, 0x0018(sp)                  // a0 = item object

    _end:
	lw   	ra, 0x0014(sp)                  // load ra
	addiu	sp, sp, 0x18                    // deallocate stack space
	jr   	ra                              // return
	or   	v0, r0, r0                      // return 0 (don't destroy)
}

// @ Description
// Main function for falling state.
scope falling_main_: {
	addiu	sp, sp, -0x18                   // allocate stack space
	sw   	ra, 0x0014(sp)                  // store ra

    jal  	0x801744C0                      // main function for falling tomato
    sw   	a0, 0x0018(sp)                  // store a0

    _check_catch:
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      t6, 0x0084(a0)                  // t6 = item special struct
    lw      a1, 0x0008(t6)                  // a1 = owner object
    beqz    a1, _end                        // skip if there's no owner object
    lli     at, 0x03E8                      // at = 0x03E8 (player type)
    lw      t6, 0x0000(a1)                  // t6 = owner object type
    bne     at, t6, _end                    // skip if owner object is not a player object
    nop
    // if the item owner is a player, check to see if they can catch the boomerang
    jal     handle_item_catch_              // check for item catch
    nop

    _end:
	lw   	ra, 0x0014(sp)                  // load ra
	addiu	sp, sp, 0x18                    // deallocate stack space
	jr   	ra                              // return
	or   	v0, r0, r0                      // return 0 (don't destroy)
}


// @ Description
// Function which checks for clipping collisions while the boomerang is thrown.
scope throw_collision_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
	sw		a0, 0x0018(sp)

    lw      a0, 0x0084(a0)                  // ~
    addiu   a0, a0, 0x0038                  // a0 = x/y/z position
    li      a1, detect_collision_           // a1 = detect_collision_
    or      a2, s0, r0                      // a2 = item object
    jal     0x800DA034                      // collision detection
    ori     a3, r0, 0x0C21                  // bitmask (all collision types)

    beqz    v0, _end                        // end if no collision result
    nop

    jal     throw_collide_                  // run collision function
    lw		a0, 0x0018(sp)                  // a0 = item object


	_end:
    lw      ra, 0x0014(sp)
	addiu   sp, sp, 0x18
    jr      ra
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// Function which checks for clipping collisions while the boomerang is turning.
scope turn_collision_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
	sw		a0, 0x0018(sp)

    lw      a0, 0x0084(a0)                  // ~
    addiu   a0, a0, 0x0038                  // a0 = x/y/z position
    li      a1, detect_collision_           // a1 = detect_collision_
    or      a2, s0, r0                      // a2 = item object
    jal     0x800DA034                      // collision detection
    ori     a3, r0, 0x0C21                  // bitmask (all collision types)

    beqz    v0, _end                        // end if no collision result
    nop

    jal     turn_collide_                   // run collision function
    lw		a0, 0x0018(sp)                  // a0 = item object


	_end:
    lw      ra, 0x0014(sp)
	addiu   sp, sp, 0x18
    jr      ra
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// Function which checks for clipping collisions while the boomerang is returning.
scope return_collision_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
	sw		a0, 0x0018(sp)

    lw      a0, 0x0084(a0)                  // ~
    addiu   a0, a0, 0x0038                  // a0 = x/y/z position
    li      a1, detect_collision_           // a1 = detect_collision_
    or      a2, s0, r0                      // a2 = item object
    jal     0x800DA034                      // collision detection
    ori     a3, r0, 0x0C21                  // bitmask (all collision types)
    beqz    v0, _end                        // end if no collision result
    nop

    jal     return_collide_clipping_        // run collision function
    lw		a0, 0x0018(sp)                  // a0 = item object


	_end:
    lw      ra, 0x0014(sp)
	addiu   sp, sp, 0x18
    jr      ra
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// Collision detection subroutine for boomerang.
scope detect_collision_: {
    // Copy beginning of subroutine 0x801737B8
    OS.copy_segment(0xEE0F4, 0x88)
    beql    v0, r0, _end                    // modify branch
    lhu     t5, 0x0056(s0)                  // ~
    jal     0x800DD59C                      // ~
    or      a0, s0, r0                      // ~
    lhu     t0, 0x005A(s0)                  // ~
    lhu     t5, 0x0056(s0)                  // original logic
    // Remove ground collision lines
    // Copy end of subroutine
    _end:
    OS.copy_segment(0xEE1CC, 0x2C)
}

// @ Description
// function which runs when the boomerang collides with something after being thrown
scope throw_collide_: {
    addiu   sp, sp, -0x20                   // allocate stack space
    sw      ra, 0x0014(sp)                  // save return address
	sw		a0, 0x0018(sp)			        // save item object
    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0xBF70                      // a1 = speed multiplier
    jal     return_initial_                 // change item state
    lw      a0, 0x0018(sp)                  // a0 = item object

    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// function which runs when the boomerang collides with something while turning
scope turn_collide_: {
    addiu   sp, sp, -0x20                   // allocate stack space
    sw      ra, 0x0014(sp)                  // save return address
	sw		a0, 0x0018(sp)			        // save item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      t0, 0x01D0(v0)                  // t0 = target axis
    beql    t0, r0, _change_state           // branch if target axis = 0(x)...
    addiu   t1, v0, 0x002C                  // ...and t1 = x velocity address
    addiu   t1, v0, 0x0030                  // t1 = y velocity address

    _change_state:
    lw      at, 0x01D4(v0)                  // at = target velocity
    sw      at, 0x0000(t1)                  // velocity = target velocity
    jal     return_initial_                 // change item state
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw		a0, 0x0018(sp)			        // a0 = item object
    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0x3F70                      // a1 = speed multiplier
    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// function which runs when the boomerang collides with something other than clipping while returning
scope return_collide_: {
    addiu   sp, sp, -0x20                   // allocate stack space
    sw      ra, 0x0014(sp)                  // save return address
	//sw		a0, 0x0018(sp)			        // save item object
    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0x3F70                      // a1 = speed multiplier

    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// function which runs when the boomerang collides with clipping while returning
scope return_collide_clipping_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address
    sw		a0, 0x0018(sp)			        // save item object

    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0xBF00                      // a1 = speed multiplier
    jal     falling_initial_                // begin falling
    lw      a0, 0x0018(sp)                  // a0 = item object

    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// function which runs when the boomerang gets hit
scope hurtbox_collision_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address
    sw		a0, 0x0018(sp)			        // save item object

    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0x3F00                      // a1 = speed multiplier
    jal     falling_initial_                // begin falling
    lw      a0, 0x0018(sp)                  // a0 = item object

    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// function which runs when the boomerang collides with a shield
scope shield_collision_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address
    sw		a0, 0x0018(sp)			        // save item object

    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0xBE40                      // a1 = speed multiplier
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    jal     falling_initial_                // begin falling
    sw      r0, 0x0008(v0)                  // reset item ownership

    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// Reflect subroutine for boomerang
scope reflect_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address

    jal     0x80173434                      // generic reflect routine
    sw		a0, 0x0018(sp)			        // save item object
    jal     throw_initial_                  // change item state
    lw      a0, 0x0018(sp)                  // a0 = item object

    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// Subroutine which applies a speed multiplier to the boomerang
// @ Arguments
// a0 - item object
// a1 - multiplier
scope apply_multiplier_: {
    lw      v1, 0x0084(a0)                  // v1 = item special struct
    mtc1    a1, f2                          // f2 = speed multiplier
    lwc1    f4, 0x002C(v1)                  // f4 = x speed
    mul.s   f6, f4, f2                      // f6 = x speed * multiplier
    lwc1    f8, 0x0030(v1)                  // f8 = y speed
    mul.s   f10, f8, f2                     // f10 = y speed * multiplier
    swc1    f6, 0x002C(v1)                  // store updated x speed
    jr      ra                              // return
    swc1    f10, 0x0030(v1)                 // store updated y speed
}

// @ Description
// Subroutine which applies rotation to the boomerang
// @ Arguments
// a0 - item object
scope apply_rotation_: {
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      v1, 0x0074(a0)                  // v1 = item joint 0 struct
    lwc1    f6, 0x0344(v0)                  // f6 = rotation value
    lwc1    f4, 0x0038(v1)                  // f4 = current rotation
    add.s   f8, f4, f6                      // ~
    add.s   f8, f8, f6                      // apply rotation (twice)
    jr      ra                              // return
    swc1    f8, 0x0038(v1)                  // store updated rotation
}

// @ Description
// Subroutine which detects boomerang catches and handles item pickup
// @ Arguments
// a0 - item object
// a1 - player object
// @ Returns
// v0 - bool item pickup
scope handle_item_catch_: {
    addiu   sp, sp, -0x38                   // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      s0, 0x0018(sp)                  // ~
    sw      s1, 0x001C(sp)                  // store ra, s0, s1

    or      s0, a0, r0                      // s0 = item object
    or      s1, a1, r0                      // a1 = player object

    // first, check if the item object is within horizontal pickup range
    lw      t0, 0x0074(s0)                  // t0 = item top joint struct
    lw      t1, 0x0074(s1)                  // t1 = player top joint struct
    lwc1    f2, 0x001C(t0)                  // f2 = ITEM_X
    lwc1    f4, 0x001C(t1)                  // f4 = PLAYER_X
    sub.s   f6, f4, f2                      // f6 = X_DIFF (PLAYER_X - ITEM_X)
    abs.s   f6, f6                          // f6 = |X_DIFF|
    lui     at, CATCH_RANGE_X               // ~
    mtc1    at, f8                          // f8 = CATCH_RANGE_X
    c.le.s  f6, f8                          // ~
    nop                                     // ~
    bc1fl    _end                           // end if CATCH_RANGE_X =< X_DIFF
    or      v0, r0, r0                      // v0 = 0 (no pickup)

    // next, check if the item object is above the lower y range
    lwc1    f2, 0x0020(t0)                  // f2 = ITEM_Y
    lwc1    f4, 0x0020(t1)                  // f4 = PLAYER_Y
    lui     at, CATCH_RANGE_LY              // ~
    mtc1    at, f6                          // ~

    // account for size
    li      t2, Size.multiplier_table
    lw      t3, 0x0084(s1)                  // t3 = player struct
    lbu     t3, 0x000D(t3)                  // t3 = player port
    sll     t3, t3, 0x0002                  // t3 = offset to size multiplier
    addu    t2, t2, t3                      // t2 = size multipler address
    lwc1    f8, 0x0000(t2)                  // f8 = size multipler
    mul.s   f6, f6, f8                      // f6 = adjusted CATCH_RANGE_LY

    add.s   f6, f6, f4                      // f6 = PLAYER_Y + CATCH_RANGE_LY
    c.le.s  f6, f2                          // ~
    nop                                     // ~
    bc1fl   _end                            // end if ITEM_Y =< PLAYER_Y + CATCH_RANGE_LY
    or      v0, r0, r0                      // v0 = 0 (no pickup)

    // next, check if the item object is below the upper y range
    lui     at, CATCH_RANGE_UY              // ~
    mtc1    at, f6                          // ~

    // account for size
    mul.s   f6, f6, f8                      // f6 = adjusted CATCH_RANGE_UY

    add.s   f6, f6, f4                      // f6 = PLAYER_Y + CATCH_RANGE_UY
    c.le.s  f2, f6                          // ~
    nop                                     // ~
    bc1fl   _end                            // end if PLAYER_Y + CATCH_RANGE_LY =< ITEM_Y
    or      v0, r0, r0                      // v0 = 0 (no pickup)

    // if we're here then the boomerang is within pickup range, so check if an item pickup is allowed
    lw      t0, 0x0084(s1)                  // t0 = player struct
    lw      t6, 0x084C(t0)                  // t6 = held item
    bnezl   t6, _end                        // end if player is holding an item already
    or      v0, r0, r0                      // v0 = 0 (no pickup)

    // also need to check if the player is holding an opponent
    lw      t6, 0x0840(t0)                  // t6 = captured player object
    bnezl   t6, _end                        // end if the player is holding an opponent
    or      v0, r0, r0                      // v0 = 0 (no pickup)

    // if the player is not holding an item or opponent, then determine if the current action is valid
    lw      t6, 0x0024(t0)                  // t6 = current action
    // first, check if the action is within a valid range from Action.Idle to Action.TeeterStart
    sltiu   at, t6, Action.Idle             // at = 1 if action id < Action.Idle
    bnezl   at, _end                        // end if action id < Action.Idle
    or      v0, r0, r0                      // v0 = 0 (no pickup)
    sltiu   at, t6, Action.TeeterStart + 1  // at = 1 if action id =< Action.TeeterStart
    bnez    at, _pickup                     // branch if action id =< Action.TeeterStart
    // also allow pickup during FallSpecial, LandingSpecial and CeilingBonk
    lli     at, Action.FallSpecial          // ~
    beq     at, t6, _pickup                 // branch if action id = Action.FallSpecial
    lli     at, Action.LandingSpecial       // ~
    beq     at, t6, _pickup                 // branch if action id = Action.LandingSpecial
    lli     at, Action.CeilingBonk          // ~
    beq     at, t6, _pickup                 // branch if action id = Action.CeilingBonk
    // next, check if the action is within a valid range from Action.Clang to Action.CliffWait
    sltiu   at, t6, Action.Clang            // at = 1 if action id < Action.Clang
    bnezl   at, _end                        // end if action id < Action.Clang
    or      v0, r0, r0                      // v0 = 0 (no pickup)
    sltiu   at, t6, Action.CliffWait + 1    // at = 1 if action id =< Action.CliffWait
    bnez    at, _pickup                     // branch if action id =< Action.CliffWait
    // next, check if the action is within a valid range from Action.ItemThrowDash to Action.ItemThrowAirSmashD
    sltiu   at, t6, Action.ItemThrowDash    // at = 1 if action id < Action.ItemThrowDash
    bnezl   at, _end                        // end if action id < Action.ItemThrowDash
    or      v0, r0, r0                      // v0 = 0 (no pickup)
    sltiu   at, t6, Action.ItemThrowAirSmashD + 1 // at = 1 if action id =< Action.ItemThrowAirSmashD
    bnez    at, _pickup                     // branch if action id =< Action.ItemThrowAirSmashD
    // next, check if the action is within a valid range from Action.ShieldOn to Action.ShieldStun
    sltiu   at, t6, Action.ShieldOn         // at = 1 if action id < Action.ShieldOn
    bnezl   at, _end                        // end if action id < Action.ShieldOn
    or      v0, r0, r0                      // v0 = 0 (no pickup)
    sltiu   at, t6, Action.ShieldStun + 1   // at = 1 if action id =< Action.ShieldStun
    bnez    at, _pickup                     // branch if action id =< Action.ShieldStun
    // also allow pickup during Taunt
    lli     at, Action.Taunt                // ~
    beq     at, t6, _pickup                 // branch if action id = Action.Taunt
    // if all other checks have failed, perform one last extra check to account for multi-jump actions
    lw      t6, 0x09DC(t0)                  // t6 = current interrupt function
    li      at, 0x8013FB2C                  // at = double jump interrupt function
    bne     t6, at, _end                    // end if the current interrupt function isn't 0x8013FB2C
    nop

    // if the player is in a valid action, then allow pickup
    _pickup:
    jal     prepickup_                      // set item state
    or      a0, s0, r0                      // a0 = item object
    or      a0, s0, r0                      // a0 = item object
    or      a1, s1, r0                      // a1 = player object
    jal     0x80172CA4                      // initiate item pickup
    addiu   sp, sp, -0x0030                 // allocate stack space (0x80172CA4 is unsafe)
    addiu   sp, sp, 0x0030                  // deallocate stack space
    lli     v0, 0x0001                      // v0 = 1 (pickup)

    _end:
    lw      ra, 0x0014(sp)                  // ~
    lw      s0, 0x0018(sp)                  // ~
    lw      s1, 0x001C(sp)                  // store ra, s0, s1
    jr      ra                              // return
    addiu   sp, sp, 0x38                    // deallocate stack space
}

// @ Description
// based on bobbomb prepickup @ 0x801774FC
scope prepickup_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    jal     0x80177218                      // subroutine disables hurtbox
    // v0 = item struct
    sw      a0, 0x0018(sp)                  // store a0
    sw      r0, 0x010C(v0)                  // disable hitbox

    li      a1, item_state_table            // a1 = state table
    lw      a0, 0x0018(sp)                  // original line - idk why it loads a0 when it hasn't changed

    jal     0x80172ec8                      // change item state
    addiu   a2, r0, 0x0002                  // state = 2 (picked up)

    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// Main item pickup routine for Boomerang
scope pickup_boomerang: {
    // a0 = player struct
    // a2 = item object
    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}
