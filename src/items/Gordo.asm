// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0)

// @ Description
// Gordo Attributes
scope gordo_attributes {
	constant DURATION(0x0000)
	constant GRAVITY(0x0004)
	constant MAX_SPEED(0x0008)
	constant BOUNCE(0x000C)
	constant ANGLE(0x0010)
	constant ROTATION(0x0014)
	constant DAMAGE(0x0018)
	constant DAMAGE_IDLE(0x001C)

	struct:
	dw 160                              // 0x0000 - duration (int)
	float32 2.0                         // 0x0004 - gravity
	float32 48                          // 0x0008 - max speed
	float32 0.95                        // 0x000C - bounce multiplier
	float32 0.872665                    // 0x0010 - angle
	float32 0.001                       // 0x0014 - rotation speed
	dw 18								// 0x0018 - thrown damage
	dw 5								// 0x001C - idle (stuck in wall) damage
}

// This is set in the Waddle Dee Info file (0x1000)
// It is at 0x7B, left shifted by 1 (0x106 << 1 = 0x20E, so 0x1A0E when combined with 0x1800)
constant HITBOX_FGM(0x106)

constant SURFACE_STICK_FGM(0x107)
constant SURFACE_STICK_DAMAGE(5)

constant ITEM_INFO_ARRAY_ORIGIN(origin())
item_info_array:
constant gordo_ID(0x2002)
dw gordo_ID                             // 0x00 - item ID
dw Character.DEDEDE_file_6_ptr          // 0x04 - address of file pointer
dw 0x00000120                           // 0x08 - offset to item footer
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?

item_state_table:
// state 00 - null state
dw gordo_null_main_              		// 0x14 - main
dw 0                					// 0x18 - collision
dw 0            						// 0x1C - hitbox collision w/ hurtbox
dw 0            						// 0x20 - hitbox collision w/ shield
dw 0                           			// 0x24 - hitbox collision w/ shield edge
dw 0                                    // 0x28 - unknown (maybe absorb)
dw 0                           			// 0x2C - hitbox collision w/ reflector
dw 0             						// 0x30 - hurtbox collision w/ hitbox
// state 0 - main/aerial
dw gordo_aerial_main_                   // 0x34 - main
dw gordo_collision_                     // 0x38 - collision
dw gordo_hurtbox_collision_             // 0x1C - hitbox collision w/ hurtbox
dw gordo_hurtbox_collision_             // 0x20 - hitbox collision w/ shield
dw 0x801733E4                           // 0x24 - hitbox collision w/ shield edge
dw 0                                    // 0x28 - unknown (maybe absorb)
dw 0x80173434                           // 0x2C - hitbox collision w/ reflector
dw gordo_hitbox_collision_              // 0x30 - hurtbox collision w/ hitbox

// state 1 - resting
dw gordo_resting_main_                  // 0x34 - main
dw resting_collision_                   // 0x38 - collision
dw resting_hurtbox_collision_           // 0x3C - hitbox collision w/ hurtbox
dw 0                                    // 0x40 - hitbox collision w/ shield
dw 0                                    // 0x44 - hitbox collision w/ shield edge
dw 0                                    // 0x48 - unknown (maybe absorb)
dw 0                                    // 0x4C - hitbox collision w/ reflector
dw 0                                    // 0x50 - hurtbox collision w/ hitbox


// @ Description
// Subroutine which sets up initial properties of waddle dee/doo.
// a0 - player object
// a1 - item info array
// a2 - x/y/z coordinates to create item at
// a3 - unknown x/y/z offset
scope stage_setting_: {
	addiu   sp, sp,-0x0060                  // allocate stack space
	sw      s0, 0x0020(sp)                  // ~
	sw      s1, 0x0024(sp)                  // ~
	sw      ra, 0x0028(sp)                  // store s0, s1, ra
	sw      a0, 0x0038(sp)                  // 0x0038(sp) = player object
	sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
	jal     0x8016E174                      // create item
	sw      r0, 0x0010(sp)                  // argument 4(unknown) = 0
	beqz    v0, _end                        // end if no item was created
	or      s0, v0, r0                      // s0 = item object
	li      s1, gordo_attributes.struct     // s1 = gordo_attributes.struct

	// item is created
	lw      v1, 0x0084(v0)                  // v1 = item special struct
	sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
	lw      a0, 0x0074(v0)                  // a0 = item first joint (joint 0)
	sw      a0, 0x0030(sp)                  // 0x0030(sp) = item joint 0
	sw      r0, 0x0024(a0)                  // set z coordinate to 0
	sh      r0, 0x033E(v1)                  // set landing timer to 0
	lli     a1, 0x002E                      // a1(render routine?) = 0x2E
	jal     0x80008CC0                      // set up render routine?
	or      a2, r0, r0                      // a2 (unknown) = 0
	lw      a0, 0x0030(sp)                  // ~

	lw      v1, 0x002C(sp)                  // v1 = item special struct
	lbu     t9, 0x0158(v1)                  // ~
	ori     t9, t9, 0x0010                  // ~
	sb      t9, 0x0158(v1)                  // enable unknown bitflag
	sw      r0, 0x02C0(v1)                  // store duration
	lli     t7, 0x0004                      // ~
	sw      t7, 0x0354(v1)                  // unknown value(bit field?) = 0x00000004

	lw      a0, 0x0038(sp)                  // a0 = player object
	lw      v1, 0x002C(sp)                  // v1 = item special struct
	sw      a0, 0x0008(v1)                  // set player as projectile owner
	lw      t6, 0x0084(a0)                  // t6 = player struct
	lbu     at, 0x000D(t6)                  // at = player port
	sb      at, 0x0015(v1)                  // store player port for combo ownership
	lbu     t5, 0x000C(t6)                  // get player team id
    sb      t5, 0x0014(v1)                  // save player's team to item to prevent damage when team attack is off
    lbu     t5, 0x0012(t6)                  // load offset to attack hitbox type in 5x
	sb      t5, 0x0012(v1)                  // unknown
	sw      a0, 0x01C4(v1)                  // save player object to custom variable space in the item special struct

	lli     at, 0x0001                      // ~
	sw      r0, 0x0248(v1)                  // disable hurtbox
	sw      r0, 0x010C(v1)                  // disable hitbox

	li      t0, gordo_attributes.struct   // t0 = minion_attributes.struct
	lw      t1, gordo_attributes.MAX_SPEED(t0)    // t1 = MAX_SPEED

	sw      t1, 0x01C8(v1)                  // max speed = MAX_SPEED
	sw      r0, 0x01CC(v1)                  // rotation direction = 0
	sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
	sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE

	// set damage
	lw      t1, gordo_attributes.DAMAGE(t0) // t1 = DAMAGE
	sw      t1, Item.STRUCT.HITBOX.DAMAGE(v1)  // set damage amount

	li      t1, Item.WaddleDee.minion_blast_zone_ // load blast zone routine
	sw      t1, 0x0398(v1)                  // save routine to part of item special struct that carries unique blast wall destruction routines

	// disable clang
	//lh      t0, 0x0158(v1)                  // t0 = clang bitfield
	//andi    t0, t0, 0x7FFF                  // disable clang
	//sh      t0, 0x0158(v1)                  // ~

	_end:
	or      v0, s0, r0                      // v0 = item object
	lw      s0, 0x0020(sp)                  // ~
	lw      s1, 0x0024(sp)                  // ~
	lw      ra, 0x0028(sp)                  // load s0, s1, ra
	jr      ra                              // return
	addiu   sp, sp, 0x0060                  // deallocate stack space
}

// @ Description
// Removes minion if too old.
// Attach to Dedede's hand.
scope gordo_null_main_: {
	addiu   sp, sp, -0x0040                 // allocate stack space
	sw		ra, 0x001C(sp)					// store ra
	sw		a0, 0x0014(sp)					// store item

	lw		v1, 0x0084(a0)					// v1 = item struct
	sw      v1, 0x0018(sp)                  // save to stack

	lh 		t0, 0x033E(v1)					// t0 = thrown flag
	beqz	t0, _pin_to_hand
	lw		v1, 0x0084(a0)					// v1 = item struct


	addiu	at, r0, 0xFFFF					// at = FFFF
	beq		at,	t0, _end_destroy			// destroy minion if flag = FFFF
	lli		v0, 1							// destroy

	_throw_minion:
	// if here, then minion gets tossed
	lw		a0, 0x0014(sp)					// restore item
	lw		a1, 0x0084(a0)					// restore player obj
	jal 	gordo_throw_initial_
	lw		a1, 0x0008(a1)					// ~
	jal		Item.WaddleDee.remove_minion_check_	// remove the oldest minion
	or      a0, s0, r0                      // a0 = item object
	b		_end
	lli		v0, 0							// don't destroy

	_pin_to_hand:
	// v1 = item struct
	lw		v0, 0x0074(a0)					// item location ptr
	addiu   a1, v0, 0x001C					// arg 1 = item location coords

	lw		v0, 0x0008(v1)					// v0 = player object
	lw		v0, 0x0084(v0)					// v0 = player object
	lw      a0, 0x0910(v0)					// arg 0 = left hand joint

	lui		at, 0x4300						// at = x offset
	sw    	at, 0x0000(a1)                  // x origin point
	sw    	r0, 0x0004(a1)                  // y origin point
	jal     0x800EDF24                      // sets coords to world coords of players hand
	sw    	r0, 0x0008(a1)                  // z origin point
	lw		a0, 0x0074(s0)					// load position struct
	sw		r0, 0x0024(a0)					// set z coordinate to 0
	sw		r0, 0x0038(a0)					// set z rotation to 0

	lli		v0, 0							// don't destroy
	lw		a0, 0x0014(sp)					// load item
	lw		v1, 0x0084(a0)					// v1 = item struct
	b		_end
	sw      r0, 0x01CC(v1)                  // rotation direction = 0

	_end_destroy:
	lw		a0, 0x0014(sp)					// load item
    lw      v1, 0x0084(a0)                  // v1 = item struct
	lli 	at, 0x001C						// at = fake item id
	addiu   v0, r0, 0x0001                  // destroy item = TRUE
	b 		_end_2
	sw		at, 0x000C(v1)					// overwrite item id so no smoke puff occurs

	_end:
	lw      v1, 0x0018(sp)                  // load to stack
	lw      t1, 0x02C0(v1)                  // load timer
	addiu   t1, t1, 0x0001                  // add to timer
	sw      t1, 0x02C0(v1)                  // save new time
	_end_2:
	lw      ra, 0x001C(sp)                  // load ra
	jr      ra                              // return
	addiu   sp, sp, 0x0040                  // deallocate stack space
}

// initial routine sets minions speed and thrown state
// a0 must be set to item object
// a1 must be player object
scope gordo_throw_initial_: {
	addiu   sp, sp,-0x0060                  // allocate stack space
	sw      s0, 0x0020(sp)                  // ~
	sw      s1, 0x0024(sp)                  // ~
	sw      ra, 0x0028(sp)                  // store s0, s1, ra
	sw      a0, 0x0038(sp)                  // item object
	sw      a1, 0x003C(sp)                  // player object

	li		s1, gordo_attributes.struct
    lw		v1, 0x0074(a0)					// v1 = position struct
    lwc1    f6, 0x0020(v1)                  // f6 = y position
    lui     at, 0xC348                      // ~
    mtc1    at, f8                          // f8 = -200
    add.s   f6, f6, f8                      // f6 = y position - 200
    sw      r0, 0x0024(v1)                  // z position = 0
    swc1    f6, 0x0020(v1)                  // store updated y position
	lw		v1, 0x0084(a0)					// v1 = item struct
	lbu     t9, 0x0158(v1)                  // ~
	ori     t9, t9, 0x0010                  // ~
	sb      t9, 0x0158(v1)                  // enable unknown bitflag
	lw      t6, gordo_attributes.DURATION(s1) // t6 = duration
	sw      t6, 0x02C0(v1)                  // store duration
	lli     t7, 0x0004                      // ~
	sw      t7, 0x0354(v1)                  // unknown value(bit field?) = 0x00000004

	lwc1    f12, gordo_attributes.ANGLE(s1) // f12 = ANGLE
	lw      t6, 0x0084(a1)                  // t6 = player struct
    lwc1    f10, 0x0044(t6)                 // ~
	cvt.s.w f10, f10                        // f10 = DIRECTION
    lb      t7, 0x01C2(t6)                  // t7 = stick_x
    mtc1    t7, f8                          // ~
    cvt.s.w f8, f8                          // f8 = stick_x
    mul.s   f10, f8, f10                    // f10 = stick_x * DIRECTION
    lui     at, 0xBC00                      // ~
    mtc1    at, f8                          // f8 = -0.0078
    mul.s   f10, f8, f10                    // f10 = (stick_x * DIRECTION) * -0.0078
    add.s   f12, f12, f10                   // f12 = FINAL_ANGLE = ((stick_x * DIRECTION) * -0.0078) + ANGLE

	// ultra64 cosf function
	jal     0x80035CD0                      // f0 = cos(FINAL_ANGLE)
	swc1    f12, 0x0050(sp)                 // 0x0050(sp) = FINAL_ANGLE

	lw      a0, 0x0038(sp)                  // a0 = item object
	lw		v1, 0x0084(a0)					// v1 = item struct
	lw      a1, 0x003C(sp)
	lw      t6, 0x0084(a1)                  // t6 = player struct
	lwc1    f10, 0x0044(t6)                 // ~
	cvt.s.w f12, f10                        // f10 = DIRECTION
	lwc1    f6, gordo_attributes.MAX_SPEED(s1) // f6 = MAX SPEEED
	mul.s   f8, f6, f0                      // ~
	mul.s   f12, f8, f12                    // f12 = x velocity ((SPEED * cos(FINAL_ANGLE)) * DIRECTION)
	lw      v1, 0x0038(sp)                  // v1 = item special struct
	lw		v1, 0x0084(v1)					// ~
	swc1    f10, 0x0024(v1)                 // save direction (int) to item
	swc1    f12, 0x002C(v1)                 // save x velocity to item

	// ultra64 sinf function
	jal     0x800303F0                      // f0 = sin(FINAL_ANGLE)
	lwc1    f12, 0x0050(sp)                 // f12 = FINAL_ANGLE
	lw      a1, 0x003C(sp)					// a1 = player object
	lw      t6, 0x0084(a1)                  // t6 = player struct
	lwc1    f6, gordo_attributes.MAX_SPEED(s1) // f6 = MAX SPEEED
	lw      v1, 0x0038(sp)                  // v1 = item special struct
	lw		v1, 0x0084(v1)					// ~
	mul.s   f8, f6, f0                      // f8 = y velocity (SPEED * cos(FINAL_ANGLE))
	swc1    f8, 0x0030(v1)                  // store y velocity
	sw      r0, 0x0034(v1)                  // z velocity = 0
	lli     at, 0x0001                      // ~
	//sw      at, 0x0248(v1)                  // enable hurtbox
	sw      at, 0x010C(v1)                  // enable hitbox

	// set direction
	lw      a0, 0x003C(sp)                  // a0 = player object
	lw      t1, 0x0084(a0)                  // t1 = player struct
	lw      t1, 0x0044(t1)                  // t1 = player direction

	jal		gordo_begin_throw_				// set state to thrown
	lw      a0, 0x0038(sp)                  // item object

    lw      a1, 0x003C(sp)					// ~
    lw      a1, 0x0084(a1)                  // ~
    addiu   a2, a1, 0x0078                  // a2 = unknown
    lw      a1, 0x0078(a1)                  // a1 = player x/y/z coordinates
    jal     0x800DF058                      // check clipping
    lw      a0, 0x0038(sp)                  // a0 = item object

	lw      s0, 0x0020(sp)                  // ~
	lw      s1, 0x0024(sp)                  // ~
	lw      ra, 0x0028(sp)                  // load s0, s1, ra
	jr      ra                              // return
	addiu   sp, sp, 0x0060                  // deallocate stack space

}

// @ Description
// aerial main subroutine for the gordo
// a0 = item object
scope gordo_aerial_main_: {
	addiu   sp, sp,-0x0040                  // allocate stack space
	sw      a0, 0x0014(sp)                  // ~
	sw      s1, 0x0018(sp)                  // ~
	sw      s2, 0x001C(sp)                  // ~
	sw      ra, 0x0030(sp)                  // store ra, s0-s2

	lw      s0, 0x0084(a0)                  // s0 = item special struct
	or      s1, a0, r0                      // s1 = item object
	li      s2, gordo_attributes.struct     // s2 = minion_attributes.struct
	lw      at, 0x0108(s0)                  // at = kinetic state
	beq     at, r0, _update_speed_ground    // branch if kinetic state = grounded
	nop

	_update_speed_air:
	lui     at, 0x3F80                      // ~
	mtc1    at, f2                          // f2 = 1.0
	lwc1    f4, gordo_attributes.MAX_SPEED(s2)    // f4 = MAX_SPEED
	lwc1    f6, 0x01C8(s0)                  // f6 = current max speed
	sub.s   f6, f6, f2                      // f6 = current max speed - 1.0
	c.le.s  f6, f4                          // ~
	nop                                     // ~
	bc1f    _apply_speed_air                // branch if MAX_SPEED =< updated max speed
	swc1    f6, 0x01C8(s0)                  // update current max speed
	// if updated max speed is below MAX_SPEED
	swc1    f4, 0x01C8(s0)                  // current max speed = MAX_SPEED

	_apply_speed_air:
	lw      a1, gordo_attributes.GRAVITY(s2)      // a1 = GRAVITY
	lw      a2, 0x01C8(s0)                  // a2 = current max speed
	jal     0x80172558                      // apply gravity/max speed
	or      a0, s0, r0                      // a0 = item special struct
	b       _check_duration                 // branch
	nop

	_update_speed_ground:
	lwc1    f0, 0x002C(s0)                  // f0 = x speed
	lui     t0, 0x3F70                      // ~
	mtc1    t0, f2                          // f2 = 0.875
	mul.s   f0, f0, f2                      // f0 = x speed * 0.875
	swc1    f0, 0x002C(s0)                  // update x speed
	abs.s   f0, f0                          // f0 = absolute x speed
	lui     t0, 0x4000                      // ~
	mtc1    t0, f2                          // f2 = minimum x speed
	c.lt.s  f0, f2                          // ~
	nop                                     // ~
	bc1fl   _check_duration                 // branch if abs x speed > minimum x speed
	nop
	sw      r0, 0x002C(s0)                  // x speed = 0
	sw      r0, 0x010C(s0)                  // disable hitbox

	_check_duration:
	lw      v0, 0x02C0(s0)                  // v0 = remaining duration
	bnezl   v0, _update_duration            // branch if duration has not ended
	nop
	// if here, duration has ended
    jal     Item.WaddleDee.minion_free_
    lw      a0, 0x0014(sp)                  // a0 = minion object
	b       _end_2
	addiu   v0, r0, 0x0001                  // destroy the item

	_update_duration:
	addiu   t7, v0,-0x0001                  // t7 = decremented duration
	sw      t7, 0x02C0(s0)                  // store updated duration

	_update_rotation_direction:
	lw      t0, 0x002C(s0)                  // t0 = current x speed
	beqz    t0, _update_rotation_speed      // branch if x speed is 0
	lwc1    f12, 0x01CC(s0)                 // f12 = rotation direction

	// if the x speed isn't 0, update the rotation direction
	lwc1    f12, 0x002C(s0)                 // ~
	abs.s   f10, f12                        // ~
	div.s   f12, f12, f10                   // f12 = rotation direction
	swc1    f12, 0x01CC(s0)                 // update rotation direction

	_update_rotation_speed:
	// f12 = rotation direction
	lwc1    f8, 0x002C(s0)                  // f8 = current x speed
	lwc1    f6, 0x0030(s0)                  // f6 = current y speed
	mul.s   f8, f8, f8                      // f8 = x speed squared
	mul.s   f6, f6, f6                      // f6 = y speed squared
	add.s   f8, f8, f6                      // f8 = x speed squared + y speed squared
	sqrt.s  f10, f8                         // f10 = absolute speed
	lwc1    f6, gordo_attributes.ROTATION(s2) // f6 = default rotation speed
	mul.s   f6, f6, f10                     // f6 = default rotation speed * absolute speed
	lui     t1, 0x3C90                      // ~
	mtc1    t1, f8                          // ~
	add.s   f8, f8, f6                      // f8 = calculated rotation speed + base rotation of 0.086
	mul.s   f8, f8, f12                     // f8(rotation speed) = calculated rotation * direction
	lw      at, 0x0108(s0)                  // at = kinetic state
	bnez    at, _apply_rotation             // branch if in air
	nop

	b       _end_2                          // end
	lli      v0, 1                          // destroy item object

	_apply_rotation:
	lw      v0, 0x0074(s1)                  // v0 = item first joint struct
	lwc1    f6, 0x0038(v0)                  // f6 = current x rotation
	sub.s   f6, f6, f8                      // update x rotation
	swc1    f6, 0x0038(v0)                  // store updated x rotation

	_hitbox_timer:
	// refresh the hitbox when the hitbox refresh timer is used
	lw      t0, 0x01D0(s0)                  // t0 = hitbox refresh timer
	beqz    t0, _speed_refresh              // branch if hitbox refresh timer = 0
	nop
	// if the timer is not 0
	addiu   t0, t0,-0x0001                  // subtract 1 from the timer
	bnez    t0, _end                        // branch if the timer is still not 0
	sw      t0, 0x01D0(s0)                  // update the timer
	// if the timer just reached 0
	sw      r0, 0x0224(s0)                  // reset hit object pointer 1
	sw      r0, 0x022C(s0)                  // reset hit object pointer 2
	sw      r0, 0x0234(s0)                  // reset hit object pointer 3
	sw      r0, 0x023C(s0)                  // reset hit object pointer 4

	_speed_refresh:
	// refresh the hitbox when the refresh timer is unused and the waddle_dee passes a certain speed threshold
	lui     t0, 0x420C                      // ~
	mtc1    t0, f4                          // f4 = 35
	c.le.s  f4, f10                         // ~
	nop                                     // ~
	bc1f    _end                            // branch if absolute speed =< 35
	nop
	// if absolute speed > 20
	sw      r0, 0x0224(s0)                  // reset hit object pointer 1
	sw      r0, 0x022C(s0)                  // reset hit object pointer 2
	sw      r0, 0x0234(s0)                  // reset hit object pointer 3
	sw      r0, 0x023C(s0)                  // reset hit object pointer 4

	_end:
	or      v0, r0, r0                      // v0 = 0
	_end_2:
	sw      r0, 0x01D4(s0)                  // hitbox collision flag = FALSE
	lw      s0, 0x0014(sp)                  // ~
	lw      s1, 0x0018(sp)                  // ~
	lw      s2, 0x001C(sp)                  // ~
	lw      ra, 0x0030(sp)                  // store ra, s0-s2
	jr      ra                              // return
	addiu   sp, sp, 0x0040                  // deallocate stack space
}

// @ Description
// Main subroutine for the waddle_dee.
// a0 = item object
scope gordo_resting_main_: {
	addiu   sp, sp,-0x0040                  // allocate stack space
	sw      a0, 0x0014(sp)                  // ~
	sw      s1, 0x0018(sp)                  // ~
	sw      s2, 0x001C(sp)                  // ~
	sw      ra, 0x0030(sp)                  // store ra, s0-s2

	lw      s0, 0x0084(a0)                  // s0 = item special struct
	or      s1, a0, r0                      // s1 = item object
	li      s2, gordo_attributes.struct     // s2 = minion_attributes.struct
	lw      at, 0x0108(s0)                  // at = kinetic state

	// _update_speed_ground:
	sw      r0, 0x002C(s0)                  // update x speed
	// abs.s   f0, f0                          // f0 = absolute x speed
	// lui     t0, 0x4000                      // ~
	// mtc1    t0, f2                          // f2 = minimum x speed
	// c.lt.s  f0, f2                          // ~
	// nop                                     // ~
	// bc1fl   _check_duration                 // branch if abs x speed > minimum x speed
	// nop
	// sw      r0, 0x002C(s0)                  // x speed = 0

	_check_duration:
	lw      v0, 0x02C0(s0)                  // v0 = remaining duration
	bnezl   v0, _update_duration            // branch if duration has not ended
	nop
	// if here, duration has ended
    jal     Item.WaddleDee.minion_free_
    lw      a0, 0x0014(sp)                  // a0 = minion object
	b       _end_2
	addiu   v0, r0, 0x0001                  // destroy the item

	_update_duration:
	addiu   t7, v0,-0x0001                  // t7 = decremented duration
	sw      t7, 0x02C0(s0)                  // store updated duration

	_hitbox_timer:
	// refresh the hitbox when the hitbox refresh timer is used
	lw      t0, 0x01D0(s0)                  // t0 = hitbox refresh timer
	beqz    t0, _end                        // branch if hitbox refresh timer = 0
	nop
	// if the timer is not 0
	addiu   t0, t0,-0x0001                  // subtract 1 from the timer
	bnez    t0, _end                        // branch if the timer is still not 0
	sw      t0, 0x01D0(s0)                  // update the timer
	// if the timer just reached 0
	sw      r0, 0x0224(s0)                  // reset hit object pointer 1
	sw      r0, 0x022C(s0)                  // reset hit object pointer 2
	sw      r0, 0x0234(s0)                  // reset hit object pointer 3
	sw      r0, 0x023C(s0)                  // reset hit object pointer 4

	_end:
	or      v0, r0, r0                      // v0 = 0
	_end_2:
	sw      r0, 0x01D4(s0)                  // hitbox collision flag = FALSE
	lw      s0, 0x0014(sp)                  // ~
	lw      s1, 0x0018(sp)                  // ~
	lw      s2, 0x001C(sp)                  // ~
	lw      ra, 0x0030(sp)                  // store ra, s0-s2
	jr      ra                              // return
	addiu   sp, sp, 0x0040                  // deallocate stack space

}

// @ Description
// Collision subroutine for Gordo.
// a0 = item object
scope gordo_collision_: {
	addiu   sp, sp,-0x0060                  // allocate stack space
	sw      ra, 0x0014(sp)                  // ~
	sw      s0, 0x0040(sp)                  // ~
	sw      s1, 0x0044(sp)                  // store ra, s0, s1
	or      s0, a0, r0                      // s0 = item object
	li      s1, gordo_attributes.struct     // s1 = gordo's attributes

	// get current image rotation
	lw      a0, 0x0074(s0)                  // ~
	lw      at, 0x0038(a0)                  // get current image rotation
	sw		at, 0x005C(sp)					// save to sp in case image rotation gets reset

	lw      a0, 0x0084(s0)                  // ~
	addiu   a0, a0, 0x0038                  // a0 = x/y/z position
	li      a1, detect_collision_           // a1 = collision subroutine
	or      a2, s0, r0                      // a2 = item object
	//jal     0x800DA034                      // collision detection
	or      a0, s0, r0                      // a0 = s0
	jal     0x801737B8                      // collision detect
	ori     a1, r0, 0x0C21                  // bitmask (all collision types)
	sw      v0, 0x0028(sp)                  // store collision result
	or      a0, s0, r0                      // a0 = item object

	// fix the rotation if it was reset after touching the ground
	beqz	v0, _no_rotation_fix			// branch if no collision
	nop

	// if here, a collision happened and we put the rotation back to what it was
	lw		v0, 0x0074(a0)					// v0 = item rendering struct
	lw      at, 0x0038(v0)                  // at = objects current rotation
	lw		v0, 0x0074(a0)					// get joint
	lw		at, 0x005C(sp)					// get old value from sp
	sw		at, 0x0038(v0)					// restore old rotation

	_no_rotation_fix:
	ori     a1, r0, 0x0C21                  // bitmask (all collision types)
	lw      a2, gordo_attributes.BOUNCE(s1) // a2 = bounce multiplier
	jal     0x801737EC                      // apply collsion/bounce?
	or      a3, r0, r0                      // a3 = 0

	lw      t0, 0x0028(sp)                  // t0 = collision result
	beqz    t0, _end                        // branch if collision result = FALSE
	lw      t8, 0x0084(s0)                  // t8 = item special struct
	lhu     t0, 0x0092(t8)                  // t0 = collision flags
	andi    at, t0, 0x0800                  // t0 = collision flags | grounded bitmask
	bnez    at, _ground                     // branch if ground collision flag = FALSE
	nop

	b       _start_resting
	nop

	// check if we stick into the ground
	_ground:
	lwc1    f0, 0x0030(t8)                  // f2 = y speed
	abs.s   f0, f0                          // f2 = absolute y speed
	lui     t0, 0x4200                      // ~
	mtc1    t0, f2                          // f2 = minimum y speed
	c.lt.s  f0, f2                          // ~
	nop                                     // ~
	bc1fl   _end                            // branch if abs y speed > minimum y speed
	nop

	_start_resting:
	jal     begin_resting_                  // change to grounded/resting state
	or      a0, s0, r0                      // a0 = item object

	_end:
	lw      ra, 0x0014(sp)                  // ~
	lw      s0, 0x0040(sp)                  // ~
	lw      s1, 0x0044(sp)                  // load ra, s0, s1
	addiu   sp, sp, 0x0060                  // deallocate stack space
	jr      ra                              // return
	or      v0, r0, r0                      // return 0
}

// @ Description
// Changes the Gordo to the grounded/resting state.
// a0 = item object
scope begin_resting_: {
	addiu   sp, sp,-0x0018                  // allocate stack space
	sw      ra, 0x0014(sp)                  // ~
	sw      a0, 0x0018(sp)                  // store ra, a0
	lw      a0, 0x0084(a0)                  // a0 = item special struct

	sw      r0, 0x0248(a0)                  // disable hurtbox
	lbu     t0, 0x02CE(a0)                  // t0 = unknown bitfield
	// ori     t0, t0, 0x0080               // enables item pickup bit
	andi    t0, t0, 0x00CF                  // disable 2 bits
	sb      t0, 0x02CE(a0)                  // store updated bitfield
	sw      r0, 0x0030(a0)                  // y speed = 0
	sw      r0, 0x0034(a0)                  // z speed = 0
	jal     stick_to_surface				// stick item to collided surface
	lw      a0, 0x0018(sp)                  // a0 = item object
	jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
	lw      a0, 0x0018(sp)                  // a0 = item object
	lw      a0, 0x0018(sp)                  // a0 = item object
	li      a1, item_state_table            // a1 = object state base address
	jal     0x80172EC8                      // change item state
	ori     a2, r0, 0x0002                  // a2 = 2 (grounded/resting state)
	lw      ra, 0x0014(sp)                  // load ra
	jr      ra                              // return
	addiu   sp, sp, 0x0018                  // deallocate stack space
}

// motion sensor stick to surface = 80176840
scope stick_to_surface: {
	addiu 	sp, sp, -0x20
	sw    	ra, 0x0014(sp)
	lw    	v0, 0x0084(a0)          // v0 = item struct
	lw    	v1, 0x0074(a0)          // v1 = position struct
	lui   	at, 0x41F0
	mtc1  	at, f2
	mtc1  	r0, f0
	lui   	at, 0xC1f0

	mtc1  	r0, f4
	mtc1  	at, f6
	swc1  	f2, 0x0070(v0)
	swc1  	f2, 0x007c(v0)
	swc1  	f0, 0x0034(v0)
	swc1  	f0, 0x0030(v0)
	swc1  	f0, 0x002c(v0)
	swc1  	f4, 0x0074(v0)
	swc1  	f6, 0x0078(v0)

	lw      at, 0x0038(v1)   // get current z rotation (the next routine overwrites this)
	sw      at, 0x0008(sp)   // store z rotation
	sw      v1, 0x0004(sp)   // store position struct
	sw    	a0, 0x0020(sp)   // save item object
	jal   	0x80176708	     // attaches item to the surface
	sw    	v0, 0x001C(sp)   // v0 = item struct

	lw    	v0, 0x001C(sp)   // restore item struct
	lw    	v1, 0x0004(sp)   // v1 = item position/rendering struct
	lw      at, 0x0008(sp)   // get old z rotation
	sw      at, 0x0038(v1)   // overwrite the new z rotation

	// todo: need to look at all this stuff
	addiu 	t3, r0, 0x0001
	addiu 	at, r0, 0xffff
	lbu   	t1, 0x02cf(v0)
	lbu   	v1, 0x0015(v0)
	//sw    	t3, 0x0248(v0)					// enable hurtbox

	// disable clang
	// lh      t0, 0x0158(v0)                  // t0 = clang bitfield
	// andi    t0, t0, 0x7FFF                  // disable clang
	// sh      t0, 0x0158(v0)                  // ~

	ori   	t2, t1, 0x0040

	beq   	v1, at, _end
	sb    	t2, 0x02cf(v0)
	addiu 	at, r0, 0x0004
	beq   	v1, at, _end
	lui   	t4, 0x800a
	sll   	t5, v1, 3
	subu  	t5, t5, v1
	lw    	t4, 0x50e8(t4)
	sll   	t5, t5, 2
	addu  	t5, t5, v1
	sll   	t5, t5, 2
	addu  	t6, t4, t5
	lw    	v0, 0x0078(t6)
	addiu 	a1, r0, 0x0006
	or    	a2, r0, r0
	beqz  	v0, _end
	nop
	jal   	0x800E806C
	lw    	a0, 0x0084(v0)

	_end:
	// set damage
	lw    	a0, 0x0020(sp)				// a0 = item object
	lw		v0, 0x0084(a0)				// v0 = item struct
	lli		at, SURFACE_STICK_DAMAGE
	sw      at, Item.STRUCT.HITBOX.DAMAGE(v0)  // set new damage amount
	jal   	0x800269C0					// play fgm
	addiu 	a0, r0, SURFACE_STICK_FGM
	// jal   	0x8017279C              // not releasing ownership
	lw    	a0, 0x0020(sp)
	lw    	ra, 0x0014(sp)
	jr    	ra
	addiu 	sp, sp, 0x20

}

// @ Description
// Collision subroutine for the waddle_dee's resting state.
// a0 = item object
scope resting_collision_: {
	addiu   sp, sp,-0x0018                  // allocate stack space
	sw      ra, 0x0014(sp)                  // store ra
	//jal     0x801735A0                      // generic resting collision? (crashes. todo, find a better one)
	//nop
	lw      ra, 0x0014(sp)                  // restore ra
	addiu   sp, sp, 0x0018                  // deallocate stack space
	jr      ra                              // return
	or      v0, r0, r0                      // return 0
}


// @ Description
// Changes a gordos to the aerial/main state.
// a0 = item object
scope gordo_begin_throw_: {
	addiu   sp, sp,-0x0020                  // allocate stack space
	sw      ra, 0x0014(sp)                  // ~
	sw      a0, 0x0018(sp)                  // store ra, a0
	lw      a0, 0x0084(a0)                  // a0 = item special struct
	// lbu     t0, 0x02CE(a0)               // t0 = unknown bitfield
	// andi    t0, t0, 0xFF7F               // disable item pickup bit
	// sb      t0, 0x02CE(a0)               // store updated bitfield
	lli     at, 0x0001                      // ~
	//sw      at, 0x0248(a0)                  // enable hurtbox
	jal     0x80173F78                      // bomb subroutine, sets kinetic state value
	sw      at, 0x010C(a0)                  // enable hitbox
	sh      r0, 0x033E(a0)                  // reset custom timer to 0
	jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
	lw      a0, 0x0018(sp)                  // a0 = item object
	lw      a0, 0x0018(sp)                  // a0 = item object
	li      a1, item_state_table            // a1 = object state base address
	jal     0x80172EC8                      // change item state
	lli		a2, 0x0001                      // a2 =  (aerial/main state)
	lw      a0, 0x0018(sp)                  // store ra, a0
	lw      a0, 0x0084(a0)                  // a0 = item special struct
	sw		r0, 0x0248(a0)					// disable hurtbox
	lw      ra, 0x0014(sp)                  // load ra
	jr      ra                              // return
	addiu   sp, sp, 0x0020                  // deallocate stack space
}



// @ Description
// Runs when a gordo's hitbox collides with a hurtbox.
// a0 = item object
scope gordo_hurtbox_collision_: {
	addiu   sp, sp,-0x0030              // allocate stack space
	sw      ra, 0x0024(sp)              // ~
	// jal     gordo_begin_throw_           // transition to aerial/main state
	sw      a0, 0x0028(sp)              // store ra, a0

	lw      a0, 0x0028(sp)              // a0 = item struct
	lw      t0, 0x0084(a0)              // t0 = item special struct
	lwc1    f0, 0x002C(t0)              // f0 = current x speed
	lwc1    f2, 0x0030(t0)              // f2 = current y speed
	mul.s   f0, f0, f0                  // f0 = x speed squared
	mul.s   f2, f2, f2                  // f2 = y speed squared
	add.s   f0, f0, f2                  // f0 = x speed squared + y speed squared
	sqrt.s  f4, f0                      // f4 = absolute speed
	lui     t1, 0x3F00                  // ~
	mtc1    t1, f2                      // f2 = 0.5
	mul.s   f0, f4, f2                  // f0 = absolute speed * 0.5
	lui     t1, 0x40A0                  // ~
	mtc1    t1, f2                      // f2 = 5
	add.s   f0, f0, f2                  // add base speed of 5 to f0

	// prevent the x/y speed from being updated if the hitbox collision flag is enabled
	// this is to prevent the waddle_dee from recoiling if it trades hits
	lw      t1, 0x01D4(t0)              // t1 = hitbox collision flag
	bnez    t1, _continue               // skip if hitbox collision flag = TRUE
	sw      r0, 0x01D4(t0)              // hitbox collision flag = FALSE

	// if the hitbox collision flag wasn't enabled
	sw      r0, 0x002C(t0)              // item x speed = 0
	swc1    f0, 0x0030(t0)              // item y speed = (absolute speed * 0.5) + 5

	_continue:
	addiu   at, r0, 16
	sw      at, 0x01D0(t0)              // set hitbox refresh timer
	cvt.w.s f0, f4                      // convert absolute speed to int
	mfc1    t1, f0                      // t1 = absolute speed (int)
	srl     t2, t1, 0x1                 // ~
	addu    t1, t1, t2                  // t1 = absolute speed * 1.5
	lw      t2, 0x02C0(t0)              // t2 = current duration
	subu    t2, t2, t1                  // t2 = updated duration (duration - (absolute speed * 1.5))
	slti    at, t2, 000012              // at = TRUE if updated duration < 12; else at = FALSE
	beqz    at, _end                    // branch if updated duration >= 12
	nop
	// if we're here then the calculated remaining duration was set to less than 12 frames
	// we'll set it to 12 instead
	lli     t2, 000012                  // t2 = 12

	_end:
	sw      t2, 0x02C0(t0)              // update remaining duration
	lw      ra, 0x0024(sp)              // load ra
	addiu   sp, sp, 0x0030              // deallocate stack space
	jr      ra                          // return
	or      v0, r0, r0                  // return 0
}

// @ Description
// Runs when a gordo's hitbox collides with a hurtbox.
// a0 = item object
scope resting_hurtbox_collision_: {
	addiu   sp, sp,-0x0030              // allocate stack space
	sw      ra, 0x0024(sp)              // ~
	sw      a0, 0x0028(sp)              // store ra, a0
	lw      a0, 0x0028(sp)              // a0 = item struct
	lw      t0, 0x0084(a0)              // t0 = item special struct

	addiu   at, r0, 16
	sw      at, 0x01D0(t0)              // set hitbox refresh timer

	lw      ra, 0x0024(sp)              // load ra
	addiu   sp, sp, 0x0030              // deallocate stack space
	jr      ra                          // return
	or      v0, r0, r0                  // return 0
}

// @ Description
// this subroutine handles hitbox collision for the waddle_dee, causing it to be launched when hit by attacks
// a0 = item object
scope gordo_hitbox_collision_: {
	addiu   sp, sp,-0x0050              // allocate stack space
	lw      v0, 0x0084(a0)              // v0 = item special struct
	sw      ra, 0x0020(sp)              // 0x0020(sp) = ra
	sw      a0, 0x0024(sp)              // 0x0024(sp) = item object
	jal     gordo_begin_throw_          // transition to aerial/main state
	sw      v0, 0x0028(sp)              // 0x0028(sp) = item special struct

	// update item ownership and combo ownership
	lw      t0, 0x0028(sp)              // t0 = item special struct
	lw      t1, 0x02A8(t0)              // t1 = object which has ownership over the colliding hitbox
	sw      t1, 0x0008(t0)              // update item owner
	lli     at, 0x0004                  // at = 0x4 (no combo ownership)
	beqz    t1, _calculate_movement     // skip if there isn't an object in t1
	lli     t2, 0x03E8                  // t2 = player object type
	lw      t3, 0x0000(t1)              // t3 = object type
	bne     t2, t3, _calculate_movement // skip if object type != player
	lw      t1, 0x0084(t1)              // t1 = type specific special struct
	lbu     at, 0x000D(t1)              // at = player port (for combo ownership)

	_calculate_movement:
	sb      at, 0x0015(t0)              // update combo ownership
	lwc1    f0, 0x0298(t0)              // ~
	cvt.s.w f0, f0                      // f0 = damage
	lui     t1, 0x4080                  // ~
	mtc1    t1, f2                      // f2 = 4
	mul.s   f0, f0, f2                  // f0 = damage * 4
	lui     t1, 0x4120                  // ~
	mtc1    t1, f2                      // f2 = 10
	add.s   f0, f0, f2                  // f0 = knockback ((damage * 4) + 10)
	swc1    f0, 0x002C(sp)              // 0x002C(sp) = knockback
	swc1    f0, 0x01C8(t0)              // current max speed = knockback
	lw      a0, 0x029C(t0)              // a0 = knockback angle
	// this subroutine converts the int angle in a0 to radians, also handles sakurai angle
	jal     0x801409BC                  // f0 = knockback angle in rads
	lw      a2, 0x002C(sp)              // a2 = knockback
	swc1    f0, 0x0030(sp)              // 0x0030(sp) = knockback angle
	// ultra64 cosf function
	jal     0x80035CD0                  // f0 = cos(angle)
	mov.s   f12, f0                     // f12 = knockback angle
	lwc1    f4, 0x002C(sp)              // f4 = knockback
	mul.s   f4, f4, f0                  // f4 = x velocity (knockback * cos(angle))
	swc1    f4, 0x0034(sp)              // 0x0034(sp) = x velocity
	// ultra64 sinf function
	jal     0x800303F0                  // f0 = sin(angle)
	lwc1    f12, 0x0030(sp)             // f12 = knockback angle
	lwc1    f4, 0x002C(sp)              // f4 = knockback
	mul.s   f4, f4, f0                  // f4 = y velocity (knockback * sin(angle))
	lwc1    f2, 0x0034(sp)              // f2 = x velocity

	lw      t0, 0x0028(sp)              // t0 = item special struct
	lw      t1, 0x02A4(t0)              // ~
	subu    t1, r0, t1                  // t1 = DIRECTION
	sw      t1, 0x0024(t0)              // update item direction
	mtc1    t1, f0                      // ~
	cvt.s.w f0, f0                      // f0 = DIRECTION
	mul.s   f2, f0, f2                  // f2 = x velocity * DIRECTION
	swc1    f2, 0x002C(t0)              // update projectile x velocity
	swc1    f4, 0x0030(t0)              // update projectile y velocity
	// lw      t1, 0x0004(t0)              // ~
	// lw      t1, 0x0074(t1)              // t1 = projectile position struct
	// lwc1    f2, 0x0034(t1)              // f2 = projectile z rotation
	// abs.s   f2, f2                      // f2 = absolute projectile z rotation
	// mul.s   f2, f0, f2                  // f2 = rotation * DIRECTION
	// swc1    f2, 0x0034(t1)              // store updated rotation
	lli     t1, 16                      // ~
	sw      t1, 0x01D0(t0)              // set hitbox refresh timer to 16 frames
	lli     t1, OS.TRUE                 // ~
	sw      t1, 0x01D4(t0)              // hitbox collision flag = TRUE
	lw      t1, 0x0298(t0)              // t1 = damage
	sll     t1, t1, 0x1                 // t1 = damage * 2
	lw      t2, 0x02C0(t0)              // t2 = current duration
	subu    t2, t2, t1                  // t2 = updated duration (duration - (damage * 2))
	slti    at, t2, 000020              // at = TRUE if updated duration < 20; else at = FALSE
	beqz    at, _end                    // branch if updated duration >= 20
	nop
	// if we're here then the calculated remaining duration was set to less than 20 frames
	// we'll set it to 20 instead
	lli     t2, 000020                  // t2 = 20

	_end:
	sw      t2, 0x02C0(t0)              // update remaining duration

	lw      ra, 0x0020(sp)              // load ra
	addiu   sp, sp, 0x0050              // deallocate stack space
	jr      ra
	or      v0, r0, r0                  // dont destroy item
}

// @ Description
// Collision detection subroutine for aerial waddle_dees.
scope detect_collision_: {
	// Copy beginning of subroutine 0x801737B8
	OS.copy_segment(0xEE0F4, 0x88)
	beql    v0, r0, _end                    // modify branch
	lhu     t6, 0x0056(s0)                  // ~
	jal     0x800DD59C                      // ~
	or      a0, s0, r0                      // ~
	lhu     t0, 0x005A(s0)                  // ~
	lhu     t5, 0x0056(s0)                  // original logic
	// Remove ground collision lines
	// Copy end of subroutine
	_end:
	OS.copy_segment(0xEE1CC, 0x2C)
}