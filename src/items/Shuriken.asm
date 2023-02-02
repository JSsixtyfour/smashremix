// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_) // bomb is 0x80177D9C
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_shuriken)
constant PICKUP_ITEM_INIT(prepickup_) // prepickup
constant DROP_ITEM(0x801745FC) // same as Maxim Tomato
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(OS.FALSE)

// @ Description
// Offset to item in Gem item file
constant FILE_OFFSET(0x90)

// edit these as needed
constant BASE_DAMAGE(2)					// base damage
constant BKB(70)					    // base knockback
constant KBG(50)					    // knockback growth
constant KB_ANGLE(150)
constant TIME_BETWEEN_HITS(4)			// x frames between hits
constant THROW_TIMER(50)                // x frames before ending throw state
constant SLOW_TIMER(30)                 // x frames before ending slowing state
constant SLOW_MULTIPLIER(0x3F70)        // deceleration multiplier to use for slowing state
constant HIT_MULTIPLIER(0x3F00)         // deceleration multiplier to use on player collision

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw Character.MARINA_file_8_ptr          // 0x04 - hard-coded pointer to file
dw FILE_OFFSET                          // 0x08 - offset to item footer in file
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?

dw 0x801744C0                           // 0x14 - ? spawn behavior? (using Maxim Tomato)
dw 0x80174524                           // 0x18 - ? ground collision? (using Maxim Tomato)
dw 0                                    // 0x1C - ?
dw 0, 0, 0, 0                           // 0x20 - 0x2C - ?

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

// STATE 3 - THROWN
dw thrown_main_                         // 0x60 - main
dw throw_collision_                     // 0x64 - collision
dw throw_collide_                       // 0x68 - hitbox collision w/ hurtbox
dw throw_collide_                       // 0x6C - hitbox collision w/ shield
dw 0x801733E4                           // 0x70 - hitbox collision w/ shield edge
dw throw_collide_                       // 0x74 - clang?
dw reflect_                             // 0x78 - hitbox collision w/ reflector
dw 0                                    // 0x7C - hurtbox collision w/ hitbox

// STATE 4 - SLOWING
dw slow_main_                           // 0x60 - main
dw slow_collision_                      // 0x64 - collision
dw slow_collide_                        // 0x68 - hitbox collision w/ hurtbox
dw slow_collide_                        // 0x6C - hitbox collision w/ shield
dw 0x801733E4                           // 0x70 - hitbox collision w/ shield edge
dw slow_collide_                        // 0x74 - clang?
dw reflect_                             // 0x78 - hitbox collision w/ reflector
dw 0                                    // 0x7C - hurtbox collision w/ hitbox

// STATE 5 - FALLING
dw 0x801744C0                           // 0x20 - main
dw 0x801745CC                           // 0x24 - collision
dw 0                                    // 0x28 - hitbox collision w/ hurtbox
dw 0                                    // 0x2C - hitbox collision w/ shield
dw 0                                    // 0x30 - hitbox collision w/ shield edge
dw 0                                    // 0x34 - clang?
dw 0                                    // 0x38 - hitbox collision w/ reflector
dw 0                                    // 0x3C - hurtbox collision w/ hitbox

// @ Description
// spawns the shuriken, based on bob-ombs spawn routine @0x80177D9C
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
    addiu   at, r0, 0x0106			    // at = sword hit hurt FGM
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
// This sets the knockback angle to point toward the thrower
scope throw_initial_: {
    addiu   sp, sp, -0x28
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
	lw		v1, 0x0084(a0)			        // v1 = item special struct
    lli     at, THROW_TIMER                 // ~
    sw      at, 0x01CC(v1)                  // store THROW_TIMER
	lw		v0, 0x0008(v1)			        // v0 = player struct
	lw		v0, 0x0084(v0)			        // ~
	lw		v0, 0x0024(v0)			        // get action id
	lli 	at, Action.ItemThrowDash
	beq		at, v0, _apply_angle			// branch if current action = itemthrowdash
	lli		at, KB_ANGLE
	sll		v0, v0, 30				        // we can use last two bits to determine thrown direction
	beqz 	v0, _apply_angle
	lli		at, 270					        // throwing upwards. kb angle = downwards
	srl		v0, v0, 31
	bnez	v0, _apply_angle
	lli		at, KB_ANGLE			        // throwing forwards or backwards.kb angle = default.
	lli		at, 90					        // if here, throwing downwards. kb angle = upwards

	_apply_angle:
	sw		at, 0x013C(v1)			        // overwrite knockback angle

	_continue:
    li      a1, item_state_table
    lw      a0, 0x0018(sp)
    jal     0x80172EC8                      // change item state
    addiu   a2, r0, 0x0003                  // state = 3(thrown)

    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x28
}

// @ Description
// Begins the throw state without changing the knockback angle
scope reflected_initial_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
	lw		v1, 0x0084(a0)			        // v1 = item special struct
    lli     at, THROW_TIMER                 // ~
    sw      at, 0x01CC(v1)                  // store THROW_TIMER
    li      a1, item_state_table
    lw      a0, 0x0018(sp)
    jal     0x80172EC8                      // change item state
    addiu   a2, r0, 0x0003                  // state = 3(thrown)
    lw      a0, 0x0018(sp)                  // ~
    lw      t6, 0x0084(a0)                  // t6 = item special struct
    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x30
}

// @ Description
// initial routine for slowing state
scope slow_initial_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lli     at, SLOW_TIMER                  // ~
    sw      at, 0x01CC(v0)                  // store SLOW_TIMER
    li      a1, item_state_table
    jal     0x80172EC8                      // change item state
    addiu   a2, r0, 0x0004                  // state = 4(slow)
    lw      a0, 0x0018(sp)                  // ~
    lw      t6, 0x0084(a0)                  // t6 = item special struct
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
    addiu   a2, r0, 0x0005                  // state = 5(falling)
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x30
    jr      ra
    nop
}

// @ Description
// Main function for the thrown state.
scope thrown_main_: {
	addiu	sp, sp, -0x30                   // allocate stack space
	sw   	ra, 0x0014(sp)                  // store ra
    sw   	a0, 0x0018(sp)                  // store a0

    lw		a2, 0x0084(a0)			        // a2 = item special struct
    lw      t0, 0x01CC(a2)                  // t0 = current THROW_TIMER value
    lli     at, THROW_TIMER                 // at = initial THROW_TIMER value
    bne     t0, at, _rotation               // branch after first frames
    nop

    lbu     at, 0x02CF(a2)                  // at = bit field
    andi    at, at, 0x00DF                  // ~
    sb      at, 0x02CF(a2)                  // disable bitflag for bonus damage
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
    jal  	0x801713f4                      // apply rotation
    lw   	a0, 0x0018(sp)                  // a0 = item object

    lw   	a0, 0x0018(sp)                  // a0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      t0, 0x01CC(v0)                  // t0 = THROW_TIMER
    sll		t1, t0, 29				        // every 8 frames...
	bnez	t1, _check_end_timer		    // ... add gfx
	nop
	// if here, add gfx
	lw		a0, 0x0074(a0)
	addiu	a0, a0, 0x001C			        // a0 = coordinates struct
	lui		a2, 0x3F80
	jal     0x800FF048           	        // smoke gfx
    lli     a1, 1
	lw		a0, 0x0018(sp)                  // a0 = item object
	lw		v0, 0x0084(a0)                  // v0 = item special struct
    lw      t0, 0x01CC(v0)                  // t0 = THROW_TIMER

    _check_end_timer:
    addiu   t0, t0,-0x0001                  // decrement THROW_TIMER
    bnez    t0, _end                        // skip if THROW_TIMER hasn't reached 0
    sw      t0, 0x01CC(v0)                  // store updated THROW_TIMER

    // when THROW_TIMER reaches 0
    jal     slow_initial_                   // begin slowing down
    lw      a0, 0x0018(sp)                  // a0 = item object

    _end:
	lw   	ra, 0x0014(sp)                  // load ra
	addiu	sp, sp, 0x30                    // deallocate stack space
	jr   	ra                              // return
	or   	v0, r0, r0                      // return 0 (don't destroy)
}

// @ Description
// Main function for the slowing state.
scope slow_main_: {
	addiu	sp, sp, -0x30                   // allocate stack space
	sw   	ra, 0x0014(sp)                  // store ra
    sw   	a0, 0x0018(sp)                  // store a0

    jal  	0x801713f4                      // apply rotation
    lw   	a0, 0x0018(sp)                  // a0 = item object

    lw   	a0, 0x0018(sp)                  // a0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lui     at, SLOW_MULTIPLIER             // ~
    mtc1    at, f2                          // f2 = SLOW_MULTIPLIER
    lwc1    f4, 0x002C(v0)                  // f4 = x velocity
    lwc1    f6, 0x0030(v0)                  // f6 = y velocity
    mul.s   f4, f4, f2                      // f4 = x velocity * SLOW_MULTIPLIER
    mul.s   f6, f6, f2                      // f6 = y velocity * SLOW_MULTIPLIER

    // refresh the hitbox when the hitbox refresh timer is used
	lw      t0, 0x01D0(v0)                  // t0 = hitbox refresh timer
	beqz    t0, _continue              		// branch if hitbox refresh timer = 0
	nop
	// if the timer is not 0
	addiu   t0, t0,-0x0001                  // subtract 1 from the timer
	bnez    t0, _continue           		// branch if the timer is still not 0
	sw      t0, 0x01D0(v0)                  // update the timer
	// if the timer just reached 0
	sw      r0, 0x0224(v0)                  // reset hit object pointer 1
	sw      r0, 0x022C(v0)                  // reset hit object pointer 2
	sw      r0, 0x0234(v0)                  // reset hit object pointer 3
	sw      r0, 0x023C(v0)                  // reset hit object pointer 4

    _continue:
    lw      t0, 0x01CC(v0)                  // t0 = SLOW_TIMER
    addiu   t0, t0,-0x0001                  // decrement SLOW_TIMER
    swc1    f4, 0x002C(v0)                  // store updated x velocity
    swc1    f6, 0x0030(v0)                  // store updated y velocity
    bnez    t0, _end                        // skip if SLOW_TIMER hasn't reached 0
    sw      t0, 0x01CC(v0)                  // store updated SLOW_TIMER

    // when SLOW_TIMER reaches 0
    jal     falling_initial_                // begin falling
    lw      a0, 0x0018(sp)                  // a0 = item object

    _end:
	lw   	ra, 0x0014(sp)                  // load ra
	addiu	sp, sp, 0x30                    // deallocate stack space
	jr   	ra                              // return
	or   	v0, r0, r0                      // return 0 (don't destroy)
}

// @ Description
// changes to slowing state and sets hitbox refresh timer
scope throw_collide_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lui     at, HIT_MULTIPLIER              // ~
    mtc1    at, f2                          // f2 = HIT_MULTIPLIER
    lwc1    f4, 0x002C(v0)                  // f4 = x velocity
    lwc1    f6, 0x0030(v0)                  // f6 = y velocity
    mul.s   f4, f4, f2                      // f4 = x velocity * HIT_MULTIPLIER
    mul.s   f6, f6, f2                      // f6 = y velocity * HIT_MULTIPLIER
    lli		at, TIME_BETWEEN_HITS           // ~
    sw      at, 0x01D0(v1)                  // enable hitbox refresh timer
    swc1    f4, 0x002C(v0)                  // store updated x velocity
    jal     slow_initial_                   // begin slowing down
    swc1    f6, 0x0030(v0)                  // store updated y velocity

    _end:
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x20
    jr      ra
    or      v0, r0, r0				        // don't destroy
}

// @ Description
// sets hitbox refresh timer and slows the shuriken
scope slow_collide_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lui     at, HIT_MULTIPLIER              // ~
    mtc1    at, f2                          // f2 = HIT_MULTIPLIER
    lwc1    f4, 0x002C(v0)                  // f4 = x velocity
    lwc1    f6, 0x0030(v0)                  // f6 = y velocity
    mul.s   f4, f4, f2                      // f4 = x velocity * HIT_MULTIPLIER
    mul.s   f6, f6, f2                      // f6 = y velocity * HIT_MULTIPLIER
    lli		at, TIME_BETWEEN_HITS           // ~
	sw      at, 0x01D0(v0)                  // enable hitbox refresh timer
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x20
    swc1    f4, 0x002C(v0)                  // store updated x velocity
    swc1    f6, 0x0030(v0)                  // store updated y velocity
    jr      ra
    or      v0, r0, r0				        // don't destroy
}

// @ Description
// based on bombs 0x8017756C
scope throw_collision_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
	sw		a2, 0x0018(sp)
	sw		s0, 0x001C(sp)
    jal     0x801737B8				        // common routine checks collision with clipping
    addiu	a1, r0, 0x0C21			        // collision bitmask?
	beqz	v0, _end                        // skip if no collision detected
	nop

	jal     0x800269C0						// play sound
    addiu   a0, r0, 0x0107					// stab hit sfx
	lli     v0, 1							// destroy item

	_end:
    lw      ra, 0x0014(sp)
	lw		a2, 0x0018(sp)
	lw		s0, 0x001C(sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// Function which checks for clipping collisions while the shuriken is slowing.
scope slow_collision_: {
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

    lw		a0, 0x0018(sp)                  // a0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    sw      r0, 0x002C(v0)                  // x velocity = 0
    sw      r0, 0x0030(v0)                  // y velocity = 0

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
// Reflect subroutine for shuriken
scope reflect_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address

    jal     0x80173434                      // generic reflect routine
    sw		a0, 0x0018(sp)			        // save item object
    jal     reflected_initial_              // change item state
    lw      a0, 0x0018(sp)                  // a0 = item object

    lw      ra, 0x0014(sp)                  // load ra
    addiu   sp, sp, 0x20                    // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // don't destroy
}

// @ Description
// I don't think this routine will run since the drop routine is based on toma
scope prepickup_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     0x80177218                  // subroutine disables hurtbox
    sw      a0, 0x0018(sp)              // store a0

    li      a1, item_state_table        // a1 = state table
    lw      a0, 0x0018(sp)              // original line - idk why it loads a0 when it hasn't changed

    jal     0x80172ec8                  // change item state
    addiu   a2, r0, 0x0002              // state = 2 (picked up)

    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// Main item pickup routine for Skuriken
scope pickup_shuriken: {
    // a0 = player struct
    // a2 = item object
    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}
