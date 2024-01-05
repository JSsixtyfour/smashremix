// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(Hazards.minion_stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0)

// @ Description
// Attributes
scope minion_attributes {
	constant DURATION(0x0000)
	constant GRAVITY(0x0004)
	constant MAX_SPEED(0x0008)
	constant BOUNCE(0x000C)
	constant ANGLE(0x0010)
	constant ROTATION(0x0014)
	constant GROUND_SPEED(0x0018)
	constant LAND_LAG(0x001C)
	constant HORIZONTAL_JUMP_SPEED(0x0020)
	constant VERTICAL_JUMP_SPEED(0x0024)
	constant BEAM_CHARGE_TIME(0x0028)
	constant BEAM_INITIAL_ANGLE(0x002C)
	constant BEAM_DISTANCE_FROM_PARENT(0x0030)
	constant BEAM_ROTATION_AMOUNT(0x0034)
	constant BEAM_DURATION(0x0038)
	constant BEAM_ROTATION_OFFSET(0x003C)

	constant WALK_SPEED_VALUE(15)

	struct:
	dw 420                                  // 0x0000 - duration (int)
	float32 2.0                             // 0x0004 - gravity
	float32 48                              // 0x0008 - max speed (THROWN)
	float32 0.3                             // 0x000C - bounce multiplier
	float32 0.872665                        // 0x0010 - angle
	float32 0.003                           // 0x0014 - rotation speed
	float32 WALK_SPEED_VALUE                // 0x0018 - walking speed
	dw 16                                   // 0x001C - landing frames (int)
	float32 8                               // 0x0020 - horizontal jump speed
	float32 40                              // 0x0024 - vertical jump speed
	dw 20                                   // 0x0028 - beam charge time (int)
	dw 0x3F900000                           // 0x002C - intial angle of projectile beam
	float32 256                             // 0x0030 - beam distance from parent
	dw 0x3E860000                           // 0x0034 - beam rotation amount (every 4 frames)
	dw 0x0A                                 // 0x0038 - beam duration (int)
	dw 0x3ED00000                           // 0x003C - beam child rotation offset
	// see WaddleDoo.asm for more beam
}

constant WADDLE_DEE_WALK_ATTACK_DELAY(4)
constant WADDLE_DOO_WALK_ATTACK_DELAY(8)

item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0                                    // 0x00 - item ID
dw 0x801313F4                           // 0x04 - address of file pointer
dw 0x00000040                           // 0x08 - offset to item footer
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?

item_state_table:
// state 00 - null state
dw minion_null_main_              		// 0x14 - state 0 main
dw 0                					// 0x18 - state 0 collision
dw 0            						// 0x1C - state 0 hitbox collision w/ hurtbox
dw 0            						// 0x20 - state 0 hitbox collision w/ shield
dw 0                           			// 0x24 - state 0 hitbox collision w/ shield edge
dw 0                                    // 0x28 - state 0 unknown (maybe absorb)
dw 0                           			// 0x2C - state 0 hitbox collision w/ reflector
dw 0             						// 0x30 - state 0 hurtbox collision w/ hitbox

// state 0 - main/aerial
dw aerial_main_              // 0 main
dw collision_                // 0 collision
dw minion_hurtbox_collision_            // 0 hitbox collision w/ hurtbox
dw minion_hurtbox_collision_            // 0 hitbox collision w/ shield
dw 0x801733E4                           // 0 hitbox collision w/ shield edge
dw 0                                    // 0 unknown (maybe absorb)
dw 0x80173434                           // 0 hitbox collision w/ reflector
dw minion_hitbox_collision_             // 0 hurtbox collision w/ hitbox

// state 1 - landing
dw waddle_dee_landing_main_             //  1 main
dw waddle_dee_resting_collision_        //  1 collision
dw minion_hurtbox_collision_            //  1 hitbox collision w/ hurtbox
dw minion_hurtbox_collision_            //  1 hitbox collision w/ shield
dw 0x801733E4                           //  1 hitbox collision w/ shield edge
dw 0                                    //  1 unknown (maybe absorb)
dw 0x80173434                           //  1 hitbox collision w/ reflector
dw minion_hitbox_collision_             //  1 hurtbox collision w/ hitbox

// state 2 - walking around
dw minion_walk_main
dw waddle_ground_collision              // - 2 collision / aerial transition
dw 0                                    // - 2 hitbox collision w/ hurtbox
dw 0                                    // - 2 hitbox collision w/ shield
dw 0                                    // - 2 hitbox collision w/ shield edge
dw 0                                    // - 2 unknown (maybe absorb)
dw 0                                    // - 2 hitbox collision w/ reflector
dw minion_hitbox_collision_             // - 2 hurtbox collision w/ hitbox

// state 3 - jumpsquat
dw waddle_dee_jumpsquat_main            //  3 main
dw waddle_ground_collision              //  3 collision / aerial transition
dw 0                                    //  3 hitbox collision w/ hurtbox
dw 0                                    //  3 hitbox collision w/ shield
dw 0                                    //  3 hitbox collision w/ shield edge
dw 0                                    //  3 unknown (maybe absorb)
dw 0                                    //  3 hitbox collision w/ reflector
dw minion_hitbox_collision_             //  3 hurtbox collision w/ hitbox

// state 4 - jump
dw waddle_dee_jumpsquat_main            //  4 main
dw collision_                //  4 collision / aerial transition
dw minion_hurtbox_collision_            //  4 hitbox collision w/ hurtbox
dw minion_hurtbox_collision_            //  4 hitbox collision w/ shield
dw 0                                    //  4 hitbox collision w/ shield edge
dw 0                                    //  4 unknown (maybe absorb)
dw 0                                    //  4 hitbox collision w/ reflector
dw minion_hitbox_collision_             //  4 hurtbox collision w/ hitbox

// @ Description
// Hook that removes bob-omb walking sfx for the Minions (in 0x80177848)
scope remove_bob_bomb_walk_fgm_: {
    OS.patch_start(0xF23CC, 0x8017798C)
    j		remove_bob_bomb_walk_fgm_
    lli		at, Hazards.standard.BOBOMB		// at = bobombs item id
    _return:
    OS.patch_end()

    // s0 = item struct
    lw      a0, 0x000C(s0)					// a0 = item id
    bne		a0, at, _end					// do original routine if it is bobomb walking
    nop

    _bobomb:
    jal 	0x800269C0						// original line 1, play FGM
    addiu	a0, r0, 0x002D					// original line 2, FGM id = bobomb fuse

    _end:
    j		_return							// return to original routine
    nop

}

// This is set in the Waddle Dee Info file (0x1000)
// It is at 0x7B, left shifted by 1 (0x25 << 1 = 0x4A)
constant MINION_HITBOX_FGM(FGM.hit.PUNCH_L)

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
    li      s1, minion_attributes.struct    // s1 = minion_attributes.struct

    // item is created
    lw      v1, 0x0084(v0)                  // v1 = item special struct
    sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
    lw      a0, 0x0074(v0)                  // a0 = item first joint (joint 0)
    sw      a0, 0x0030(sp)                  // 0x0030(sp) = item joint 0

    lw		t0, 0x0080(a0)					// get image footer struct
    lli     at, 0x0001                      // at = target image index
    sh      at, 0x0080(t0)                  // set image index

    sw      r0, 0x0024(a0)                  // set z coordinate to 0
    sw      r0, 0x02C0(v1)                  // set timer to 0
    sh      r0, 0x033E(v1)                  // set timer to 0
    lli     a1, 0x002E                      // a1(render routine?) = 0x2E
    jal     0x80008CC0                      // set up render routine?
    or      a2, r0, r0                      // a2 (unknown) = 0
    lw      a0, 0x0030(sp)                  // ~

    lw      a0, 0x0038(sp)                  // a0 = player object
    lw      v1, 0x002C(sp)                  // v1 = item special struct
    sw      a0, 0x0008(v1)                  // set player as projectile owner
    lw      t6, 0x0084(a0)                  // t6 = player struct
    lbu     at, 0x000D(t6)                  // at = player port
    sb      at, 0x0015(v1)                  // store player port for combo ownership
    lbu     t5, 0x000C(t6)                  // load player team
    lbu     t5, 0x0012(t6)                  // load offset to attack hitbox type in 5x
    sb      t5, 0x0012(v1)                  // unknown
    sw      a0, 0x01C4(v1)                  // save player object to custom variable space in the item special struct

    sw      r0, 0x0248(v1)                  // disable hurtbox
    sw      r0, 0x010C(v1)                  // disable hitbox

    li      t0, minion_attributes.struct   // t0 = minion_attributes.struct
    lw      t1, minion_attributes.MAX_SPEED(t0)    // t1 = MAX_SPEED

    sw      t1, 0x01C8(v1)                  // max speed = MAX_SPEED
    sw      r0, 0x01CC(v1)                  // rotation direction = 0
    sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
    sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
    li      t1, minion_blast_zone_          // load waddle_dee blast zone routine
    sw      t1, 0x0398(v1)                  // save routine to part of item special struct that carries unique blast wall destruction routines

    // set direction
    lw      t1, 0x0038(sp)                  // a0 = player object
    lw      t1, 0x0084(t1)                  // t1 = player struct
    lw      t1, 0x0044(t1)                  // t1 = player direction
    lli     a1, 0x0001
    bnel    a1, t1, _direction_check
    lli     a1, 0x0000                      // set a1 to 0
    _direction_check:
    jal     ground_move_initial             // change the movement/direction
    move    a0, s0                  		// a0 = item object

    _end:
    or      v0, s0, r0                      // v0 = item object
    lw      s0, 0x0020(sp)                  // ~
    lw      s1, 0x0024(sp)                  // ~
    lw      ra, 0x0028(sp)                  // load s0, s1, ra
    jr      ra                              // return
    addiu   sp, sp, 0x0060                  // deallocate stack space
}

// @ Description
// Main routine while being held by Dedede
scope minion_null_main_: {
    addiu   sp, sp, -0x0040                 // allocate stack space
    sw		ra, 0x001C(sp)					// store ra
    sw		a0, 0x0014(sp)					// store item
    
    lw		v1, 0x0084(a0)					// v1 = item struct
    sw      v1, 0x0018(sp)                  // save to stack
    
    lh 		t0, 0x033E(v1)					// t0 = thrown flag
    beqz	t0, _pin_to_hand
    lli		v0, 0							// don't destroy
    
    addiu	at, r0, 0xFFFF					// at = FFFF
    beq		at,	t0, _end_destroy			// destroy minion if flag = FFFF
    lli		v0, 1							// destroy
    
    _throw_minion:
    // if here, then minion gets tossed
    lw		a0, 0x0014(sp)					// restore item
    lw		a1, 0x0084(a0)					// restore player obj
    jal 	minion_throw_initial_
    lw		a1, 0x0008(a1)					// ~
    jal		remove_minion_check_			// remove the oldest minion
    or      a0, s0, r0                      // a0 = item object
    b		_end
    lli		v0, 0							// don't destroy
    
    _pin_to_hand:
    // v1 = item struct
    lw		v0, 0x0074(a0)					// item location ptr
    addiu   a1, v0, 0x001C					// arg 1 = item location coords
    
    // change image if held for long enough
    lw		at, 0x0084(a0)
    lw      t0, 0x02C0(at)                  // load timer
    sll		t0, t0, 30
    bnez 	t0, _continue
    lw		v0, 0x0074(a0)					// v1 = position struct
    lw		v0, 0x0080(v0)					// v1 = image struct
    lw		at, 0x0080(v0)					// get current image index
    beqzl	at, _update_image
    lli		at, 0x0001						// image index 1...
    lli		at, 0							// ...or image index 0
    _update_image:
    sh		at, 0x0080(v0)					// v1 = set image index
    
    _continue:
    lw		v0, 0x0008(v1)					// v0 = player object
    lw		v0, 0x0084(v0)					// v0 = player object
    lw      a0, 0x0910(v0)					// arg 0 = left hand joint
    
    lui		at, 0x4310						// at = x offset (moves minion upwards)
    sw    	at, 0x0000(a1)                  // x origin point
    sw    	r0, 0x0004(a1)                  // y origin point
    jal     0x800EDF24                      // sets coords to world coords of players hand
    sw    	r0, 0x0008(a1)                  // z origin point
    
    lw		a0, 0x0074(s0)					// load position struct
    sw		r0, 0x0038(a0)					// set z rotation to 0
    lw		a0, 0x0014(sp)					// load item
    lw		v1, 0x0084(a0)					// v1 = item struct
    
    sw      r0, 0x01CC(v1)                  // rotation direction = 0
    b		_end
    lli		v0, 0							// don't destroy
    
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
scope minion_throw_initial_: {
    addiu   sp, sp,-0x0060                  // allocate stack space
    sw      s0, 0x0020(sp)                  // ~
    sw      s1, 0x0024(sp)                  // ~
    sw      ra, 0x0028(sp)                  // store s0, s1, ra
    sw      a0, 0x0038(sp)                  // item object
    sw      a1, 0x003C(sp)                  // player object
    
    li 		s1, minion_attributes.struct
    lw		v1, 0x0074(a0)					// v1 = position struct
    lwc1    f6, 0x0020(v1)                  // f6 = y position
    lui     at, 0xC348                      // ~
    mtc1    at, f8                          // f8 = -200
    add.s   f6, f6, f8                      // f6 = y position - 200
    sw      r0, 0x0024(v1)                  // z position = 0
    swc1    f6, 0x0020(v1)                  // store updated y position
    lw		v1, 0x0080(v1)					// v1 = image struct
    lli		at, 0x0001
    sh		at, 0x0080(v1)					// v1 = set image index
    
    lw		v1, 0x0084(a0)					// v1 = item struct
    lbu     t9, 0x0158(v1)                  // ~
    ori     t9, t9, 0x0010                  // ~
    sb      t9, 0x0158(v1)                  // enable unknown bitflag
    lw      t6, minion_attributes.DURATION(s1)  // t6 = duration
    sw      t6, 0x02C0(v1)                  // store duration
    lli     t7, 0x0004                      // ~
    sw      t7, 0x0354(v1)                  // unknown value(bit field?) = 0x00000004
    
    lwc1    f12, minion_attributes.ANGLE(s1) // f12 = ANGLE
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
    lw      a1, 0x003C(sp)					// a1 = player object
    lw      t6, 0x0084(a1)                  // t6 = player struct
    lwc1    f10, 0x0044(t6)                 // ~
    cvt.s.w f12, f10                        // f12 = DIRECTION
    lwc1    f6, minion_attributes.MAX_SPEED(s1) // 	F6 = MAX SPEED
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
    lw      v1, 0x0038(sp)                  // v1 = item special struct
    lw		v1, 0x0084(v1)					// ~
    lwc1    f6, minion_attributes.MAX_SPEED(s1) // f6 = MAX SPEEED
    mul.s   f8, f6, f0                      // f8 = y velocity (SPEED * cos(FINAL_ANGLE))
    swc1    f8, 0x0030(v1)                  // store y velocity
    sw      r0, 0x0034(v1)                  // z velocity = 0
    lli     at, 0x0001                      // ~
    sw      at, 0x0248(v1)                  // enable hurtbox
    sw      at, 0x010C(v1)                  // enable hitbox
    
    addiu	at, r0, 0x0080					// at = bitmask, allows owner to attack this item
    lh		t0, 0x02CE(v1)					// t0 = item flags bitfield
    or      t0, at, t0              		// t0 = new, combined flag
    sh		t0, 0x02CE(v1)					// overwrite bitfield
    
    jal		minion_begin_main_
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
// aerial main subroutine for the waddle_dee.
// a0 = item object
scope aerial_main_: {
    addiu   sp, sp,-0x0040                  // allocate stack space
    sw      s0, 0x0014(sp)                  // ~
    sw      s1, 0x0018(sp)                  // ~
    sw      s2, 0x001C(sp)                  // ~
    sw      ra, 0x0030(sp)                  // store ra, s0-s2
    sw      a0, 0x0020(sp)                  // store minion object
    
    lw      s0, 0x0084(a0)                  // s0 = item special struct
    or      s1, a0, r0                      // s1 = item object
    li      s2, minion_attributes.struct   // s2 = minion_attributes.struct
    
    _update_direction:
    lw      at, 0x002C(s0)
    beqz	at, _continue2					// don't update direction if speed = 0
    lwc1    f4, 0x002C(s0)                  // f4 = x speed
    mtc1    r0, f0                          // f0 = 0
    c.lt.s  f4, f0                          // = 1 if > 0
    nop
    bc1fl   _continue
    lli     at, 1                     		// direction = R
    li     at, -1                           // or direction = L
    
    _continue:
    sw      at, 0x0024(s0)					// overwrite direction
    _continue2:
    lw      at, 0x0108(s0)                  // at = kinetic state
    beq     at, r0, _update_speed_ground    // branch if kinetic state = grounded
    nop
    
    _update_speed_air:
    lui     at, 0x3F80                      // ~
    mtc1    at, f2                          // f2 = 1.0
    lwc1    f4, minion_attributes.MAX_SPEED(s2)    // f4 = MAX_SPEED
    lwc1    f6, 0x01C8(s0)                  // f6 = current max speed
    sub.s   f6, f6, f2                      // f6 = current max speed - 1.0
    c.le.s  f6, f4                          // ~
    nop                                     // ~
    bc1f    _apply_speed_air                // branch if MAX_SPEED =< updated max speed
    swc1    f6, 0x01C8(s0)                  // update current max speed
    // if updated max speed is below MAX_SPEED
    swc1    f4, 0x01C8(s0)                  // current max speed = MAX_SPEED
    
    _apply_speed_air:
    lw      a1, minion_attributes.GRAVITY(s2)      // a1 = GRAVITY
    lw      a2, 0x01C8(s0)                  // a2 = current max speed
    jal     0x80172558                      // apply gravity/max speed
    or      a0, s0, r0                      // a0 = item special struct
    b       _check_duration                 // branch
    nop
    
    // sliding
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
    jal     minion_free_
    lw      a0, 0x0020(sp)                  // a0 = minion object
    b       _end_2
    addiu   v0, r0, 0x0001                  // destroy the item
    
    _update_duration:
    addiu   t7, v0,-0x0001                  // t7 = decremented duration
    sw      t7, 0x02C0(s0)                  // store updated duration
    
    _update_rotation_direction:
    lw      t0, 0x002C(s0)                  // t0 = current x speed
    beqz    t0, _update_rotation_speed      // branch if x speed is 0
    lwc1    f12, 0x01CC(s0)                 // f12 = rotation direction
    
    // if the waddle_dee's x speed isn't 0, update the rotation direction
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
    lwc1    f6, minion_attributes.ROTATION(s2) // f6 = default rotation speed
    mul.s   f6, f6, f10                     // f6 = default rotation speed * absolute speed
    lui     t1, 0x3C90                      // ~
    mtc1    t1, f8                          // ~
    add.s   f8, f8, f6                      // f8 = calculated rotation speed + base rotation of 0.086
    mul.s   f8, f8, f12                     // f8(rotation speed) = calculated rotation * direction
    lw      at, 0x0108(s0)                  // at = kinetic state
    bnez    at, _apply_rotation             // branch if in air
    nop
    
    _grounded_transition:
    jal     minion_landing_initial_       // begin face plant
    or      a0, s1, r0                      // a0 = item special struct
    b       _end                            // end
    nop
    
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
    // // refresh the hitbox when the refresh timer is unused and the waddle_dee passes a certain speed threshold
    // lui     t0, 0x420C                      // ~
    // mtc1    t0, f4                          // f4 = 35
    // c.le.s  f4, f10                         // ~
    // nop                                     // ~
    // bc1f    _end                            // branch if absolute speed =< 35
    // nop
    // // if absolute speed > 20
    // sw      r0, 0x0224(s0)                  // reset hit object pointer 1
    // sw      r0, 0x022C(s0)                  // reset hit object pointer 2
    // sw      r0, 0x0234(s0)                  // reset hit object pointer 3
    // sw      r0, 0x023C(s0)                  // reset hit object pointer 4
    
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
scope waddle_dee_landing_main_: {
    addiu   sp, sp,-0x0040                  // allocate stack space
    sw      s0, 0x0014(sp)                  // ~
    sw      s1, 0x0018(sp)                  // ~
    sw      s2, 0x001C(sp)                  // ~
    sw      ra, 0x0030(sp)                  // store ra, s0-s2
    sw      a0, 0x0020(sp)                  // store minion object
    
    lw      s0, 0x0084(a0)                  // s0 = item special struct
    or      s1, a0, r0                      // s1 = item object
    li      s2, minion_attributes.struct    // s2 = minion_attributes.struct
    lw      at, 0x0108(s0)                  // at = kinetic state
    
    _update_speed_ground:
    lw      at, 0x002C(s0)
    lui     t0, 0x3F70                      // ~
    beqz	at, _continue2
    lwc1    f4, 0x002C(s0)                  // f4 = x speed
    mtc1    r0, f0                          // f0 = 0
    c.lt.s  f4, f0                          // = 1 if > 0
    nop
    bc1fl   _continue
    lli     at, 1                     		// direction = R
    li     at, -1                           // or direction = L
    
    _continue:
    sw      at, 0x0024(s0)					// overwrite direction
    _continue2:
    mtc1    t0, f2                          // f2 = 0.875
    mul.s   f4, f4, f2                      // f4 = x speed * 0.875
    swc1    f4, 0x002C(s0)                  // update x speed
    abs.s   f4, f4                          // f4 = absolute x speed
    lui     t0, 0x4000                      // ~
    mtc1    t0, f2                          // f2 = minimum x speed
    c.lt.s  f4, f2                          // ~
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
    jal     minion_free_
    lw      a0, 0x0020(sp)                  // a0 = minion object
    b       _end_2
    addiu   v0, r0, 0x0001                  // destroy the item
    
    _update_duration:
    addiu   t7, v0,-0x0001                  // t7 = decremented duration
    sw      t7, 0x02C0(s0)                  // store updated duration
    
    _landing_lag_check:
    or      a0, s0, r0                      // a0 = item special struct
    
    lh      t0, 0x033E(a0)                  // t0 = timer value
    addiu   t0, t0, 1                       // t0 += 1
    lw      at, minion_attributes.LAND_LAG(s2)
    bne     at, t0, _hitbox_timer
    sh      t0, 0x033E(a0)                  // save updated timer
    jal     minion_grounded_walk_initial_
    or      a0, s1, r0                      // a0 = item object
    j       _end
    or      a0, s1, r0
    
    _hitbox_timer:
    // refresh the hitbox when the hitbox refresh timer is used
    // lw      t0, 0x01D0(s0)                  // t0 = hitbox refresh timer
    // beqz    t0, _speed_refresh              // branch if hitbox refresh timer = 0
    // nop
    // // if the timer is not 0
    // addiu   t0, t0,-0x0001                  // subtract 1 from the timer
    // bnez    t0, _end                        // branch if the timer is still not 0
    // sw      t0, 0x01D0(s0)                  // update the timer
    // // if the timer just reached 0
    // sw      r0, 0x0224(s0)                  // reset hit object pointer 1
    // sw      r0, 0x022C(s0)                  // reset hit object pointer 2
    // sw      r0, 0x0234(s0)                  // reset hit object pointer 3
    // sw      r0, 0x023C(s0)                  // reset hit object pointer 4
    
    // _speed_refresh:
    // // refresh the hitbox when the refresh timer is unused and the waddle_dee passes a certain speed threshold
    // lwc1    f10, 0x0024(s0)                 // load direction var
    // cvt.s.w f10, f10                        // convert direction to float
    // lui     t0, 0x420C                      // ~
    // mtc1    t0, f4                          // f4 = 35
    // c.le.s  f4, f10                         // ~
    // nop                                     // ~
    // bc1f    _end                            // branch if absolute speed =< 35
    // nop
    // // if absolute speed > 20
    // sw      r0, 0x0224(s0)                  // reset hit object pointer 1
    // sw      r0, 0x022C(s0)                  // reset hit object pointer 2
    // sw      r0, 0x0234(s0)                  // reset hit object pointer 3
    // sw      r0, 0x023C(s0)                  // reset hit object pointer 4
    
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
// Collision subroutine for the waddle_dee.
// a0 = item object
scope collision_: {
    addiu   sp, sp,-0x0058                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      a0, 0x0030(sp)                  // store a0
    sw      s0, 0x0040(sp)                  // ~
    sw      s1, 0x0044(sp)                  // store ra, s0, s1
    or      s0, a0, r0                      // s0 = item object
    li      s1, minion_attributes.struct   // s1 = minion_attributes.struct
    
    lw      a0, 0x0084(s0)                  // ~
    addiu   a0, a0, 0x0038                  // a0 = x/y/z position
    li      a1, minion_detect_collision_   // a1 = minion_detect_collision_
    or      a2, s0, r0                      // a2 = item object
    jal     0x800DA034                      // collision detection
    ori     a3, r0, 0x0C21                  // bitmask (all collision types)
    sw      v0, 0x0028(sp)                  // store collision result
    or      a0, s0, r0                      // a0 = item object
    ori     a1, r0, 0x0421                  // bitmask same as bumper
    lw      a2, minion_attributes.BOUNCE(s1) // a2 = bounce multiplier
    jal     0x801737EC                      // apply collsion/bounce?
    or      a3, r0, r0                      // a3 = 0
    
    lw      t0, 0x0028(sp)                  // t0 = collision result
    beqz    t0, _end                        // branch if collision result = FALSE
    lw      t8, 0x0084(s0)                  // t8 = item special struct
    lhu     t0, 0x0092(t8)                  // t0 = collision flags
    andi    t0, t0, 0x0800                  // t0 = collision flags | grounded bitmask
    beqz    t0, _end                        // branch if ground collision flag = FALSE
    nop
    
    _grounded:
    jal     minion_landing_initial_          // change to grounded/resting state
    or      a0, s0, r0                       // a0 = item object
    
    lw      s0, 0x0030(sp)                  // s0 = item object
    lw      v0, 0x0084(s0)                  // v0 = item special struct
    addiu   at, r0, 1
    sw      at, 0x010C(v0)                  // enable hitbox
    
    _end:
    lw      ra, 0x0014(sp)                  // ~
    lw      s0, 0x0040(sp)                  // ~
    lw      s1, 0x0044(sp)                  // load ra, s0, s1
    addiu   sp, sp, 0x0058                  // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // return 0
}

// @ Description
// Collision subroutine for the waddle_dee's resting state.
// a0 = item object
scope waddle_dee_resting_collision_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // store ra
    li      a1, minion_begin_main_          // a1 = minion_begin_main_
    jal     0x801735A0                      // generic resting collision?
    nop
    lw      ra, 0x0014(sp)                  // restore ra
    addiu   sp, sp, 0x0018                  // deallocate stack space
    jr      ra                              // return
    or      v0, r0, r0                      // return 0
}

// @ Description
// Hitbox? subroutine for the waddle_dee's exploding state.
// For now, just replaces a hard-coded reference to the item info array and then jumps to the original routine, 0x801863AC
scope minion_grounded_walk_initial_hitboxes_: {
    lw      v0, 0x0084(a0)                  // a0 = item special struct
    li      t6, item_info_array             // t6 = item_info_array
    // TODO: extend this custom routine if addressing offset hard-code(s)
    j       0x801863B8                      // jump to original routine
    lw      t6, 0x0004(t6)                  // t6 = file pointer
}

// @ Description
// Changes a waddle_dee to the aerial/main state.
// a0 = item object
scope minion_begin_main_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      a0, 0x0018(sp)                  // store ra, a0
    lw      a0, 0x0084(a0)                  // a0 = item special struct
    lbu     t0, 0x02CE(a0)                  // t0 = unknown bitfield
    andi    t0, t0, 0xFF7F                  // disable item pickup bit
    sb      t0, 0x02CE(a0)                  // store updated bitfield
    lli     at, 0x0001                      // ~
    jal     0x80173F78                      // bomb subroutine, sets kinetic state value
    sw      at, 0x010C(a0)                  // enable hitbox
    sh      r0, 0x033E(a0)                  // reset custom timer to 0
    jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, item_state_table      // a1 = object state base address
    jal     0x80172EC8                      // change item state
    lli		a2, 0x0001                      // a2 = (aerial/main state)
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Changes a waddle_dee to the grounded/resting state.
// a0 = item object
scope minion_landing_initial_: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      a0, 0x0018(sp)                  // store ra, a0
    
    // a0 = item object
    
    // change image to index 2 and rotation to 0
    jal     0x800269C0                      // play FGM (waddle stepping)
    lli     a0, 0x044B                      // FGM id =
    lw      a0, 0x0018(sp)                  // restore a0
    lw      a0, 0x0074(a0)                  // a0 = position struct
    sw      r0, 0x0038(a0)                  // set rotation to 0
    lw      a0, 0x0080(a0)                  // a0 = image struct
    lli     at, 0x0001                      // at = image index 2
    sh      at, 0x0080(a0)                  // set waddle dee to landing frame
    lw      a0, 0x0018(sp)                  // restore a0
    
    lw      a0, 0x0084(a0)                  // a0 = item special struct
    lbu     t0, 0x02CE(a0)                  // t0 = unknown bitfield
    // ori     t0, t0, 0x0080                  // enables item pickup bit
    andi    t0, t0, 0x00CF                  // disable 2 bits
    sb      t0, 0x02CE(a0)                  // store updated bitfield
    sh      r0, 0x033E(a0)                  // set custom timer to 0
    
    sw      r0, 0x0030(a0)                  // y speed = 0
    jal     0x80173F54                      // bomb subroutine, sets kinetic state value and applies a multiplier to x speed?
    sw      r0, 0x0034(a0)                  // z speed = 0
    jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, item_state_table      // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, 0x0002                  // a2 =  (face plant state)
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Handles the minion when they land on the ground
// Based on function 0x80186368 and its subroutine 0x80185A80.
scope minion_grounded_walk_initial_: {
    addiu   sp, sp,-0x0030                  // allocate stack space
    sw      ra, 0x001C(sp)                  // ~
    sw      s0, 0x0018(sp)                  // store ra, s0
    or      s0, a0, r0                      // s0 = item object
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    sw      r0, 0x002C(v0)                  // ~
    sw      r0, 0x0030(v0)                  // ~
    sw      r0, 0x0034(v0)                  // reset x/y/z velocity
    lw      at, 0x01C4(v0)                  // at = original player owner object
    sw      at, 0x0008(v0)                  // set original owner
    
    lw      t0, 0x0074(s0)                  // t0 = item first joint struct
    //lli     t1, 0x0002                    // t1 = 2
    //sb      t1, 0x0054(t0)                // set unknown value to 2
    lw      t0, 0x0084(s0)                  // t0 = item special struct
    jal     minion_walk_intitial          // change to walking
    or      a0, s0, r0                      // a0 = item object
    // jal     0x800269C0                      // play FGM
    // lli     a0, 0x0001                      // FGM id = 1
    lw      ra, 0x001C(sp)                  // ~
    lw      s0, 0x0018(sp)                  // load ra, s0
    jr      ra                              // return
    addiu   sp, sp, 0x0030                  // deallocate stack space
}

// @ Description
// Collision detection subroutine for aerial waddle_dees.
scope minion_detect_collision_: {
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

// @ Description
// Runs when a waddle_dee's hitbox collides with a hurtbox.
// a0 = item object
scope minion_hurtbox_collision_: {
    addiu   sp, sp,-0x0030              // allocate stack space
    sw      ra, 0x0024(sp)              // ~
    jal     minion_begin_main_          // transition to aerial/main state
    sw      a0, 0x0028(sp)              // store ra, a0
    
    lw      a0, 0x0028(sp)              // a0 = item struct
    lw      t0, 0x0084(a0)              // t0 = item special struct
    sw      r0, 0x010C(v1)              // disable hitbox
    
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
    sw      r0, 0x01D0(t0)              // disable hitbox refresh timer
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
// this subroutine handles hitbox collision for the waddle_dee, causing it to be launched when hit by attacks
// a0 = item object
scope minion_hitbox_collision_: {
    addiu   sp, sp,-0x0050              // allocate stack space
    lw      v0, 0x0084(a0)              // v0 = item special struct
    sw      ra, 0x0020(sp)              // 0x0020(sp) = ra
    sw      a0, 0x0024(sp)              // 0x0024(sp) = item object
    jal     minion_begin_main_          // transition to aerial/main state
    sw      v0, 0x0028(sp)              // 0x0028(sp) = item special struct
    
    // change image to thrown
    lw      a0, 0x0024(sp)              // a0= item object
    lw      v1, 0x0074(a0)              // v1 = position struct
    lw      v1, 0x0080(v1)              // v1 = image struct
    sh      r0, 0x0080(v1)              // set to thrown frame
    sw      r0, 0x0090(v1)              // clear any animation ptrs
    sw      r0, 0x0094(v1)              // ~
    lw      v1, 0x0084(a0)              // v1 = item struct
    lli     at, 0x0001
    sw      at, 0x0108(v1)              // set kinetic state
    
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
    //sw      t1, 0x0024(t0)              // update item direction
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
    lli     t1, 000016                  // ~
    sw      t1, 0x01D0(t0)              // set hitbox refresh timer to 16 frames
    lli     t1, OS.TRUE                 // ~
    sw      t1, 0x01D4(t0)              // hitbox collision flag = TRUE
    lw      t1, 0x0298(t0)              // t1 = damage
    sll     t1, t1, 0x3                 // t1 = damage * 8
    lw      t2, 0x02C0(t0)              // t2 = current duration
    subu    t2, t2, t1                  // t2 = updated duration (duration - (damage * 8))
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
// grounded movement
scope minion_walk_intitial: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // store ra
    
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      at, 0x0008(v0)                  // at = item owner
    sw      at, 0x0010(sp)                  // store item owner
    
    addiu   at, r0, 0x0001
    sw      at, 0x0248(v0)                  // enable hurtbox
    
    l.s     f6, 0x0024(v0)                  // f6 = item direction (int)
    cvt.s.w f4, f6                          // f4 = item direction (float)
    li      at, minion_attributes.struct
    lw      at, minion_attributes.GROUND_SPEED(at)  // at = ground speed
    mtc1    at, f6                          // f6 = waddle ground speed
    mul.s   f4, f4, f6                      // f4 = speed * direction
    nop
    s.s     f4, 0x002C(v0)                  // save modified ground speed to item struct
    
    lbu     t6, 0x0340(v0)                  // ~
    andi    t6, t6, 0xFF0F                  // ~
    sb      t6, 0x0340(v0)                  // disable unknown bitflags
    sh      r0, 0x033E(v0)                  // set explosion timer to 0
    lui     at, 0x3F80                      // ~
    sw      at, 0x0114(v0)                  // set unknown value to 1.0
    
    // todo maybe: the below routine also makes it so Waddler turns around if at a ledge. remove that?
    jal     0x80177848                      // initiate bob-omb walk 0x80177848 begins bob-omb animation
    sw      a0, 0x0018(sp)                  // save a0
    lw      a0, 0x0018(sp)                  // restore a0 (item object)
    lw      at, 0x0010(sp)                  // restore item owner to item struct
    // the previous routine enabled the hitbox, so we disable it.
    lw      a1, 0x0084(a0)                  // ~
    sw      r0, 0x0010C(a1)                 // disable hitbox
    sw      at, 0x0008(a1)                  // ~
    
    li      a1, item_state_table            // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, 0x0003                  // a2 = (grounded move state)
    
    // a1 should be direction
    lw      a0, 0x0018(sp)                  // restore a0 (item object)
    lw      v0, 0x0084(a0)                  // v0 = item special struct
    lw      at, 0x0024(v0)					// a1 = direction
    addiu   a1, r0, 0x0001					// at = face right
    bnel    at, a1, _set_direction
    addiu   a1, r0, r0						// a1 = face left
    _set_direction:
    jal     ground_move_initial				// begin movement
    
    lw      at, 0x0010(sp)                  // restore item owner to item struct
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Make Item walk towards a direction. Based on 0x80177104.
// a0 = item, a1 = direction (0 = LEFT, 1 = RIGHT)
scope ground_move_initial: {
    sw             a1, 0x0004 (sp)
    lw             v0, 0x0084 (a0)
    lui            t8, 0x0000
    addiu          t8, t8, 0x33F8
    lw             t6, 0x02D4(v0)
    lui            t9, 0x0000
    lui            t1, 0x0000
    lw             t7, 0x0000(t6)
    andi           a1, a1, 0x00ff
    addiu          t9, t9, 0x34C0		// ?
    addiu          t1, t1, 0x3310		// ?
    subu           a3, t7, t8
    lw             v1, 0x0074 (a0)
    addu           a2, a3, t9
    beqz           a1, _move_left
    addu           t0, a3, t1
    lui            at, 0x4170			// = WALK_SPEED_VALUE
    _move_right:
    mtc1           at, f4
    addiu          t2, r0, 0x0001
    sw             t2, 0x0024 (v0)
    swc1           f4, 0x002c (v0)
    jr             ra
    sw             t0, 0x0050 (v1)
    _move_left:
    lui            at, 0xC170			// = WALK_SPEED_VALUE
    mtc1           at, f6
    addiu          t3, r0, 0xffff		// saves direction
    sw             t3, 0x0024(v0)
    swc1           f6, 0x002C(v0)
    jr             ra
    sw             a2, 0x0050(v1)
}

// @ Description
// based on bob-omb routine @ 801777D8. this routine jumps to it after choosing the transition routine in a1
scope waddle_ground_collision: {
    addiu   sp, sp, -0x20      // allocate stackspace
    lw      t6, 0x0084(a0)     // original line
    li      a1, waddle_ground_to_air_transition
    j       0x801777EC         // go to original routine
    sw      ra, 0x0014(sp)     // store ra
}

scope waddle_ground_to_air_transition: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    // a0 = item object
    
    // change image
    lw      v1, 0x0074(a0)                  // v1 = position struct
    lw      v1, 0x0080(v1)                  // v1 = image struct
    sh      r0, 0x0080(v1)                  // set waddle dee to landing frame
    sw      r0, 0x0090(v1)                  // clear animation ptrs
    sw      r0, 0x0094(v1)                  // ~
    lw      v1, 0x0084(a0)                  // v1 = item struct
    lli     at, 0x0001
    sw      at, 0x0108(v1)                  // set kinetic state
    sw      at, 0x010C(v1)                  // enable hitbox
    
    jal     0x80177208                      // sets a flag at 0x248 in item struct
    sw      a0, 0x0018(sp)
    
    lw      a0, 0x0018(sp)					// a0 = item object
    li      a1, item_state_table
    jal     0x80172Ec8                      // change item state
    addiu   a2, r0, 0x0001                  // thrown state
    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// based on bob-omb movement routine @ 801776A0
scope minion_walk_main: {
    addiu   sp, sp, -0x40
    sw      ra, 0x001C(sp)
    sw      s1, 0x0018(sp)
    sw      a0, 0x0014(sp)			// save object struct to sp
    lw      s0, 0x0084(a0)
    or      s1, a0, r0
    lw      t6, 0x02d4(s0)
    sw      t6, 0x0038(sp)
    lw      t7, 0x0074(a0)
    // jal     0x8017761c            // smoke gfx
    sw      t7, 0x0034 (sp)
    jal     0x800fc67c               // ?
    lw      a0, 0x00ac(s0)
    beqzl   v0, _check_timer
    lhu     v1, 0x033E(s0)           // v1 = timer
    lw      t8, 0x0024(s0)
    addiu   at, r0, 0xffff           // at = -1
    addiu   a1, sp, 0x0028           // a1 = sp variable space
    bne     t8, at, _move_left
    nop
    
    _move_right:
    lw      a0, 0x00ac (s0)
    jal     0x800f4428
    addiu   a1, sp, 0x0028
    lw      t0, 0x0038 (sp)
    lw      t9, 0x0034 (sp)
    lwc1    f4, 0x0028 (sp)
    lh      t1, 0x0030 (t0)
    lwc1    f6, 0x001c (t9)
    or      a0, s1, r0
    mtc1    t1, f8
    nop
    cvt.s.w f10, f8
    sub.s   f16, f6, f10
    c.le.s  f16, f4
    nop
    bc1fl   _check_timer
    lhu     v1, 0x033E(s0)           // v1 = timer
    // jal     ground_move_initial 	// edge detect / turnaround
    // addiu   a1, r0, 0x0001
    b       _check_timer
    lhu     v1, 0x033E(s0)           // v1 = timer
    
    _move_left:
    jal     0x800f4408               // related to movement
    lw      a0, 0x00ac (s0)
    lw      t3, 0x0038 (sp)
    lw      t2, 0x0034 (sp)
    lwc1    f4, 0x0028 (sp)
    lh      t4, 0x0030 (t3)
    lwc1    f18, 0x001C (t2)
    or      a0, s1, r0
    mtc1    t4, f8
    nop
    cvt.s.w f6, f8
    add.s   f10, f18, f6
    c.le.s  f4, f10
    nop
    bc1fl   _check_timer
    lhu     v1, 0x033E(s0)              // v1 = timer
    // jal     ground_move_initial      // edge detect / turnaorund
    // or      a1, r0, r0
    lhu     v1, 0x033E(s0)              // v1 = timer
    
    _check_timer:
    // every 16 frames...
    sll     at, v1, 28                  // v2 = 4 bits of timer
    bnez    at, _check_duration         // skip roll if not 0
    addiu   t5, v1, 0x0001              // t5 = timer +1
    
    // check if there is a player/target to attack
    lli     at, Item.WaddleDee.id      	// at = waddle dees item id
    lw      t0, 0x000C(s0)             	// t0 = current item id
    beql	at, t0, _waddle_dee_skip
    // waddle dee
    sltiu	at, t5, WADDLE_DEE_WALK_ATTACK_DELAY // at = 0 if >= x frames walking
    // waddle doo
    sltiu	at, t5, WADDLE_DOO_WALK_ATTACK_DELAY // at = 0 if >= x frames walking
    
    _waddle_dee_skip:
    bnez	at, _check_duration			// skip attack if not walking for 30 frames
    nop
    
    jal		check_for_targets_
    or      a0, s0, r0                 	// a0 = item struct
    
    lw		at, 0x0000(v0)				// != 0 if target found
    beqz	at, _check_duration			// branch if no reason to attack
    nop
    
    // if here, then attack
    _attack:
    lli     at, Item.WaddleDee.id      	// at = waddle dees item id
    lw      t0, 0x000C(s0)             	// t0 = current item id
    beq     at, t0, _waddle_dee        	// intitiate jump attack if waddle dee
    or      a0, s1, r0                 	// a0 = s1
    
    _waddle_doo:
    jal     Item.WaddleDoo.waddle_doo_attack_initial
    nop
    b       _continue
    nop
    
    _waddle_dee:
    jal     waddle_dee_attack_initial
    nop
    
    _continue:
    sw      r0, 0x0034(s0)             	// set velocity to 0
    sw      r0, 0x0030(s0)             	// set velocity to 0
    sw      r0, 0x002C(s0)             	// set velocity to 0
    lhu     v1, 0x033E(s0)             	// v1 = timer
    addiu   t5, v1, 0x0001             	// t5 = timer +1
    
    _check_duration:
    lw      v0, 0x02C0(s0)             	// v0 = remaining duration
    bnezl   v0, _update_duration       	// branch if duration has not ended
    nop
    // if here, duration has ended
    jal     minion_free_
    lw      a0, 0x0014(sp)              // a0 = minion object
    b       _end_2
    addiu   v0, r0, 0x0001             	// destroy the item
    
    _update_duration:
    addiu   t7, v0,-0x0001              // t7 = decremented duration
    sw      t7, 0x02C0(s0)              // store updated duration
    
    _end:
    or      v0, r0, r0                 	// dont destroy waddle dee
    _end_2:
    sh      t5, 0x033E(s0)
    lw      ra, 0x001C(sp)
    lw      s1, 0x0018(sp)
    lw      s0, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x40
}

// @ Description
// Based on subroutine which checks for valid targets for Sonic's homing attack.
// a0 - waddle Dee object
scope check_for_targets_: {
    addiu   sp, sp,-0x0050              // allocate stack space
    sw      ra, 0x001C(sp)              // ~
    sw      s0, 0x0020(sp)              // ~
    sw      s1, 0x0024(sp)              // ~
    sw      s2, 0x0028(sp)              // store ra, s0-s2
    
    sw		r0, 0x0030(sp)				// clear values
    sw		r0, 0x0034(sp)				// clear values
    
    li      s1, 0x800466FC              // s1 = player object head
    lw      s1, 0x0000(s1)              // s1 = first player object
    lw      s2, 0x0024(sp)              // s2 = minion item struct
    lw		s0, 0x0008(a0)				// s0 = player owner
    lw      s2, 0x0084(s0)              // s2 = player owner struct
    
    _player_loop:
    beqz    s1, _player_loop_exit       // exit loop when s1 no longer holds an object pointer
    nop
    beql    s1, s0, _player_loop        // loop if player owner and target object match...
    lw      s1, 0x0004(s1)              // ...and load next object into s1
    
    _team_check:
    li      t0, Global.match_info       // ~
    lw      t0, 0x0000(t0)              // t0 = match info struct
    lbu     t1, 0x0002(t0)              // t1 = team battle flag
    beqz    t1, _action_check           // branch if team battle flag = FALSE
    lbu     t1, 0x0009(t0)              // t1 = team attack flag
    bnez    t1, _action_check           // branch if team attack flag != FALSE
    nop
    
    // if the match is a team battle with team attack disabled
    lw      t0, 0x0084(s1)              // t0 = target player struct
    lbu     t0, 0x000C(t0)              // t0 = target team
    lbu     t1, 0x000C(s2)              // t1 = player team
    beq     t0, t1, _player_loop_end    // skip if player and target are on the same team
    nop
    
    _action_check:
    lw      t0, 0x0084(s1)              // t0 = target player struct
    lw      t0, 0x0024(t0)              // t0 = target player action
    sltiu   at, t0, 0x0007              // at = 1 if action id < 7, else at = 0
    bnez    at, _player_loop_end        // skip if target action id < 7 (target is in a KO action)
    nop
    
    _target_check:
    lw      a1, 0x0074(s1)              // a1 = target top joint struct
    addiu   a3, sp, 0x0030				// a3 = target storage addr
    jal     check_target_               // check_target_
    or      a2, s1, r0                  // a2 = target object struct
    beqz    v0, _player_loop_end        // branch if no new target
    nop
    
    // if check_target_ returned a new valid target
    sw      v0, 0x0030(sp)              // store target object
    sw      v1, 0x0034(sp)              // store target X_DIFF
    
    _player_loop_end:
    b       _player_loop                // loop
    lw      s1, 0x0004(s1)              // s1 = next object
    
    _player_loop_exit:
    lw      t0, 0x0030(sp)              // t0 = target object
    bnez    t0, _end                    // end if there is a targeted object
    nop
    
    li      s1, 0x80046700              // s1 = item object head
    lw      s1, 0x0000(s1)              // s1 = first item object
    
    _item_loop:
    beqz    s1, _end                    // exit loop when s1 no longer holds an object pointer
    nop
    lw      t0, 0x0084(s1)              // t0 = item special struct
    beq  	t0, a0, _item_loop_end  	// skip if item = self
    nop
    
    lw      at, 0x0248(t0)              // t0 = bit field with hurtbox state
    andi    at, at, 0x0001              // t0 = 1 if hurtbox is enabled, else at = 0
    beqz    at, _item_loop_end          // skip if item doesn't have an active hurtbox
    lw		at, 0x0008(t0)				// at = item's owner
    beq		at, s0, _item_loop_end		// end loop if item has the same owner
    nop
    
    lw      a1, 0x0074(s1)              // a1 = target top joint struct
    addiu   a3, sp, 0x0030				// a3 = target storage addr
    jal     check_target_               // check_target_
    or      a2, s1, r0                  // a2 = target object struct
    beqz    v0, _item_loop_end          // branch if no new target
    nop
    
    // if check_target_ returned a new valid target
    sw      v0, 0x0030(sp)              // store target object
    sw      v1, 0x0034(sp)              // store target X_DIFF
    
    _item_loop_end:
    b       _item_loop                  // loop
    lw      s1, 0x0004(s1)              // s1 = next object
    
    _end:
    lw      ra, 0x001C(sp)              // ~
    lw      s0, 0x0020(sp)              // ~
    lw      s1, 0x0024(sp)              // ~
    lw      s2, 0x0028(sp)              // load ra, s0-s2
    addiu   v0, sp, 0x0030				// v0 = target storage addr
    jr      ra                          // return
    addiu   sp, sp, 0x0050              // deallocate stack space
}

// constants used for target detection
constant MAX_X_RANGE(0x4416)            // - float: 600
constant MAX_Y_RANGE(0x442F)            // - float: 700
constant MAX_X_RANGE_DOO(0x4489)        // (Waddle Doo) - float: 1096
constant MAX_Y_RANGE_DOO(0x4416)        // (Waddle Doo) - float: 600

// @ Description
// Copy of subroutine which checks if a potential target is in range for Sonic's homing attack.
// a0 - waddle dee struct
// a1 - target top joint struct
// a2 - target object struct
// a3 - stackspace address for known targets
// returns
// v0 - target object (NULL when no valid target)
// v1 - target X_DIFF
scope check_target_: {
    lw      t8, 0x0004(a0)              // t8 = minion x/y/z coordinates
    lw      at, 0x0074(t8)				// ~
    addiu   t8, at, 0x001C				// ~
    addiu   t9, a1, 0x001C              // t9 = target x/y/z coordinates
    
    // check if the target is within x range
    mtc1    r0, f0                      // f0 = 0
    lwc1    f2, 0x0000(t8)              // f2 = player x coordinate
    lwc1    f4, 0x0000(t9)              // f4 = target x coordinate
    sub.s   f10, f4, f2                 // f10 = X_DIFF (target x - player x)
    lwc1    f8, 0x0024(a0)              // get minions direction
    cvt.s.w f8, f8                      // f8 = DIRECTION
    mul.s   f10, f10, f8                // f10 = X_DIFF * DIRECTION
    lui     at, MAX_X_RANGE             // at = MAX_X_RANGE
    ori     t6, r0, Item.WaddleDoo.id   // t6 = waddle doo id
    lw      t7, 0x000C(a0)              // t7 = item id
    beql    t7, t6, pc() + 8            // if  = if WADDLE DOO
    lui     at, MAX_X_RANGE_DOO         // ...use MAX_X_RANGE_DOO instead
    mtc1    at, f8                      // f8 = MAX_X_RANGE
    c.le.s  f10, f8                     // ~
    nop                                 // ~
    bc1fl   _end                        // end if MAX_X_RANGE =< X_DIFF
    or      v0, r0, r0                  // return 0
    c.le.s  f0, f10                     // ~
    nop                                 // ~
    bc1fl   _end                        // end if X_DIFF =< 0
    or      v0, r0, r0                  // return 0

    // check if there is a previous target
    lw      t0, 0x0000(a3)              // t0 = current target
    beq     t0, r0, _check_y            // branch if there is no current target
    lwc1    f8, 0x0004(a3)              // f8 = current target X_DIFF

    // compare X_DIFF to see if the previous target was within closer x proximity
    c.le.s  f10, f8                     // ~
    nop                                 // ~
    bc1fl   _end                        // end if prev X_DIFF =< current X_DIFF
    or      v0, r0, r0                  // return 0

    _check_y:
    // calculate Y_RANGE based on X_DIFF, creating a cone shaped range
    lwc1    f2, 0x0004(t8)              // f2 = player y coordinate
    lwc1    f4, 0x0004(t9)              // f4 = target y coordinate
    sub.s   f12, f4, f2                 // f12 = Y_DIFF (target y - player y)
    abs.s   f12, f12                    // f12 = absolute Y_DIFF
    lui     at, MAX_Y_RANGE             // at = MAX_Y_RANGE
    ori     t6, r0, Item.WaddleDoo.id 	// t6 = waddle doo item id
    lw      t7, 0x000C(a0)              // t7 = item id
    beql    t7, t6, pc() + 8            // if item = WADDLE DOO...
    lui     at, MAX_Y_RANGE_DOO         // ...use MAX_Y_RANGE_DOO instead
    mtc1    at, f8                      // f8 = MAX_Y_RANGE
    lui     at, 0x3F00                  // ~
    mtc1    at, f6                      // f6 = 0.5
    mul.s   f6, f6, f10                 // f6 = X_DIFF * 0.5
    add.s   f8, f8, f6                  // f8 = Y_RANGE (MAX_Y_RANGE + X_DIFF * 0.5)
    c.le.s  f12, f8                     // ~
    nop                                 // ~
    bc1fl   _end                        // end if Y_RANGE =< Y_DIFF
    or      v0, r0, r0                  // return 0
    
    // if we're here then the target is the closest within range
    or      v0, a2, r0                  // v0 = target object
    mfc1    v1, f10                     // v1 = X_DIFF
    
    _end:
    jr      ra                          // return
    nop
}

//
// setup for jump attack
scope waddle_dee_attack_initial: {
    addiu   sp, sp,-0x0018                  // allocate stack space
    sw      ra, 0x0014(sp)                  // ~
    sw      a0, 0x0018(sp)                  // store ra, a0
    
    // a0 = item object
    // change image to index 2 and rotation to 0
    lw      a0, 0x0074(a0)                  // a0 = position struct
    sw      r0, 0x0038(a0)                  // set rotation to 0
    lw      a0, 0x0080(a0)                  // a0 = image struct
    lli     at, 0x0005                      // at = jump squat image
    sh      at, 0x0080(a0)                  // set waddle dee frame
    sw      r0, 0x0090(a0)                  // clear animation ptrs
    sw      r0, 0x0094(a0)                  // ~
    lw      a0, 0x0018(sp)                  // restore a0
    
    lw      a0, 0x0084(a0)                  // a0 = item special struct
    sw      r0, 0x010C(a0)                  // disable hitbox
    lbu     t0, 0x02CE(a0)                  // t0 = unknown bitfield
    andi    t0, t0, 0x00CF                  // disable 2 bits
    sb      t0, 0x02CE(a0)                  // store updated bitfield
    sh      r0, 0x033E(a0)                  // set custom timer to 0
    jal     0x80173F54                      // bomb subroutine, sets kinetic state value and applies a multiplier to x speed?
    nop
    jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
    lw      a0, 0x0018(sp)                  // a0 = item object
    lw      a0, 0x0018(sp)                  // a0 = item object
    li      a1, item_state_table      // a1 = object state base address
    jal     0x80172EC8                      // change item state
    ori     a2, r0, 0x0004                  // a2 = attack state
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// main routine before jump-attack
scope waddle_dee_jumpsquat_main: {
    addiu   sp, sp,-0x0040                  // allocate stack space
    sw      s0, 0x0014(sp)                  // ~
    sw      s1, 0x0018(sp)                  // ~
    sw      s2, 0x001C(sp)                  // ~
    sw      ra, 0x0030(sp)                  // store ra, s0-s2
    sw      a0, 0x0034(sp)                  // save minion object
    
    lw      s0, 0x0084(a0)                  // s0 = item special struct
    or      s1, a0, r0                      // s1 = item object
    li      s2, minion_attributes.struct   // s2 = minion_attributes.struct
    lw      at, 0x0108(s0)                  // at = kinetic state
    beq     at, r0, _grounded               // branch if kinetic state = grounded
    nop
    
    _aerial:
    lui     at, 0x3F80                      // ~
    mtc1    at, f2                          // f2 = 1.0
    lwc1    f4, minion_attributes.MAX_SPEED(s2)    // f4 = MAX_SPEED
    lwc1    f6, 0x01C8(s0)                  // f6 = current max speed
    sub.s   f6, f6, f2                      // f6 = current max speed - 1.0
    c.le.s  f6, f4                          // ~
    nop                                     // ~
    bc1f    _apply_speed_air                // branch if MAX_SPEED =< updated max speed
    swc1    f6, 0x01C8(s0)                  // update current max speed
    // if updated max speed is below MAX_SPEED
    swc1    f4, 0x01C8(s0)                  // current max speed = MAX_SPEED
    
    _apply_speed_air:
    lw      a1, minion_attributes.GRAVITY(s2) // a1 = GRAVITY
    lw      a2, 0x01C8(s0)                  // a2 = current max speed
    jal     0x80172558                      // apply gravity/max speed
    or      a0, s0, r0                      // a0 = item special struct
    b       _check_duration                 // branch
    lli     t0, 0x0000
    
    _grounded:
    lh      t0, 0x033E(s0)                  // t0 = timer value
    addiu   t0, t0, 1                       // t0 += 1
    sh      t0, 0x033E(s0)                  // write timer value
    lw      t1, minion_attributes.LAND_LAG(s2)  // t1 = land lag
    bgt     t0, t1, _grounded_transition    // branch if greater than timer to transition
    nop
    bne     t1, t0, _check_duration         // branch if jump squatting
    or      a0, s1, r0                      // a0 = item object
    
    _jump_initial:
    jal     0x800269C0                      // play FGM (jump)
    lli     a0, 0x044A                      // FGM id = jump
    lw      a0, 0x0014(sp)                  // restore a0
    lw      v0, 0x0074(a0)                  // v0 = position struct
    lw      v0, 0x0080(v0)                  // v0 = image struct
    lli     at, 0x0006                      // at = jumping image
    sh      at, 0x0080(v0)                  // set waddle dee to jump frame
    lw      v0, 0x0084(a0)                  // v0 = item struct
    addiu   at, r0, 0x0001                  // at = 1
    sw      at, 0x010C(v0)                  // enable hitbox
    lw      at, minion_attributes.HORIZONTAL_JUMP_SPEED(s2)  // at = x jump speed
    mtc1    at, f6                          // f6 = horizontal jump speed
    lwc1    f10, 0x0024(s0)                 // load direction var
    cvt.s.w f10, f10                        // convert direction to float
    mul.s   f6, f6, f10                     // f6 = x speed * direction
    nop
    swc1    f6, 0x002C(s0)                  // update X speed
    lw      at, minion_attributes.VERTICAL_JUMP_SPEED(s2)  // at = y jump speed
    sw      at, 0x0030(s0)                  // update Y speed
    
    jal     0x80177208                      // sets a flag at 0x248 in item struct
    nop
    lli     at, 0x0001
    sw      at, 0x0108(s0)                  // set kinetic state as aerial
    li      a1, item_state_table
    jal     0x80172ec8                      // change item state
    addiu   a2, r0, 0x0005                  // jump state
    b       _end
    nop
    
    _check_duration:
    lw      v0, 0x02C0(s0)                  // v0 = remaining duration
    bnezl   v0, _update_duration            // branch if duration has not ended
    nop
    
    // if here, duration has ended
    jal     minion_free_
    lw      a0, 0x0034(sp)                  // a0 = minion object
    b       _end_2
    addiu   v0, r0, 0x0001                  // destroy the item
    
    _update_duration:
    addiu   t7, v0,-0x0001                  // t7 = decremented duration
    sw      t7, 0x02C0(s0)                  // store updated duration
    b       _hitbox_timer
    nop
    
    _grounded_transition:
    jal     minion_landing_initial_         // begin landing
    or      a0, s1, r0                      // a0 = item special struct
    
    b       _end                            // end
    nop

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
    // lui     t0, 0x420C                      // ~
    // mtc1    t0, f4                          // f4 = 35
    // c.le.s  f4, f10                         // ~
    // nop                                     // ~
    // bc1f    _end                            // branch if absolute speed =< 35
    // nop
    // // if absolute speed > 20
    // sw      r0, 0x0224(s0)                  // reset hit object pointer 1
    // sw      r0, 0x022C(s0)                  // reset hit object pointer 2
    // sw      r0, 0x0234(s0)                  // reset hit object pointer 3
    // sw      r0, 0x023C(s0)                  // reset hit object pointer 4

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

// Adds self to player object
// a0 = minion object
scope remove_minion_check_: {
    addiu	sp, sp, -0x0020					// allocate stack space
    sw		ra, 0x001C(sp)					// store ra
    sw		a0, 0x0014(sp)					// store minion object
    lw		v0, 0x0084(a0)					// v0 = minions item struct
    lw		t1, 0x0008(v0)					// t1 = player object
    lw		t1, 0x0084(t1)					// t1 = player struct

    lw		t2, 0x0ADC(t1)					// t2 = minion slot 1
    beqzl   t2, _end
    sw      a0, 0x0ADC(t1)                  // end if no minion here and overwrite this slot.

    lw		t3, 0x0AE0(t1)					// t2 = minion slot 2
    beqzl   t3, _end                        // end if no minion here and overwrite this slot.
    sw      a0, 0x0AE0(t1)                  // end if no minion here and overwrite this slot.

    // if here, then both slots are full. Remove the minion in slot 1.
    // t2 = minion to remove
    lli     at, 1
    lw      t2, 0x0084(t2)                  // t2 = minions special struct to remove
    sw      at, 0x02C0(t2)                  // at = duration of 1 frame

    lw      at, 0x0AE0(t1)                  // move oldest minion to slot 1
    sw      at, 0x0ADC(t1)                  // ~
    sw      a0, 0x0AE0(t1)                  // add newest minion to slot 2

    _end:
    lw		ra, 0x001C(sp)					// restore ra
    jr      ra                              // return
    addiu   sp, sp, 0x0020                  // deallocate stack space

}

// minions removes itself from owner struct when destroyed
// a0 = minion object
// slot 1 should always contain the oldest minion.
scope minion_free_: {
    jr      ra
    nop
}

// @ Description
// todo: is this even needed?
scope minion_blast_zone_: {
    j     minion_free_
    nop
}