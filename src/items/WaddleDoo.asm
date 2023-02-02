// @ Description
// These constants must be defined for an item.
// See Item.WaddleDee for the routines
constant SPAWN_ITEM(Item.WaddleDee.stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0)

constant ITEM_INFO_ARRAY_ORIGIN(origin())
item_info_array:
dw 0                                        // 0x00 - item ID
dw Character.DEDEDE_file_6_ptr              // 0x04 - address of file pointer
dw 0x000000B0                               // 0x08 - offset to item footer
dw 0x1B000000                               // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                        // 0x10 - ?

item_state_table:
// state 00 - null state
dw Item.WaddleDee.minion_null_main_         // 0x14 - state 0 main
dw 0                					    // 0x18 - state 0 collision
dw 0            						    // 0x1C - state 0 hitbox collision w/ hurtbox
dw 0            						    // 0x20 - state 0 hitbox collision w/ shield
dw 0                           			    // 0x24 - state 0 hitbox collision w/ shield edge
dw 0                                        // 0x28 - state 0 unknown (maybe absorb)
dw 0                           			    // 0x2C - state 0 hitbox collision w/ reflector
dw 0             						    // 0x30 - state 0 hurtbox collision w/ hitbox

// state 0 - main/aerial
dw Item.WaddleDee.waddle_dee_aerial_main_   // 0x14 - state 0 main
dw Item.WaddleDee.waddle_dee_collision_     // 0x18 - state 0 collision
dw Item.WaddleDee.minion_hurtbox_collision_ // 0x1C - state 0 hitbox collision w/ hurtbox
dw Item.WaddleDee.minion_hurtbox_collision_ // 0x20 - state 0 hitbox collision w/ shield
dw 0x801733E4                               // 0x24 - state 0 hitbox collision w/ shield edge
dw 0                                        // 0x28 - state 0 unknown (maybe absorb)
dw 0x80173434                               // 0x2C - state 0 hitbox collision w/ reflector
dw Item.WaddleDee.minion_hitbox_collision_  // 0x30 - state 0 hurtbox collision w/ hitbox

// state 1 - landing
dw Item.WaddleDee.waddle_dee_landing_main_  // 0x34 - state 1 main
dw Item.WaddleDee.waddle_dee_resting_collision_ // 0x38 - state 1 collision
dw Item.WaddleDee.minion_hurtbox_collision_ // 0x3C - state 1 hitbox collision w/ hurtbox
dw Item.WaddleDee.minion_hurtbox_collision_ // 0x40 - state 1 hitbox collision w/ shield
dw 0x801733E4                               // 0x44 - state 1 hitbox collision w/ shield edge
dw 0                                        // 0x48 - state 1 unknown (maybe absorb)
dw 0x80173434                               // 0x4C - state 1 hitbox collision w/ reflector
dw Item.WaddleDee.minion_hitbox_collision_  // 0x50 - state 1 hurtbox collision w/ hitbox

// state 2 - walking around
dw Item.WaddleDee.minion_walk_main          // 0xD4 - state 2 main
dw Item.WaddleDee.waddle_ground_collision   // 0xD8 - state 2 collision / aerial transition
dw 0                                        // 0xDC - state 2 hitbox collision w/ hurtbox
dw 0                                        // 0xE0 - state 2 hitbox collision w/ shield
dw 0                                        // 0xE4 - state 2 hitbox collision w/ shield edge
dw 0                                        // 0xE8 - state 2 unknown (maybe absorb)
dw 0                                        // 0xEC - state 2 hitbox collision w/ reflector
dw Item.WaddleDee.minion_hitbox_collision_  // 0xF0 - state 2 hurtbox collision w/ hitbox

// state 3 - shoot maybe
dw waddle_doo_attack_main    // 0xD4 - state 3 main
dw Item.WaddleDee.waddle_ground_collision   // 0xD8 - state 3 collision / aerial transition
dw 0                                        // 0xDC - state 3 hitbox collision w/ hurtbox
dw 0                                        // 0xE0 - state 3 hitbox collision w/ shield
dw 0                                        // 0xE4 - state 3 hitbox collision w/ shield edge
dw 0                                        // 0xE8 - state 3 unknown (maybe absorb)
dw 0                                        // 0xEC - state 3 hitbox collision w/ reflector
dw Item.WaddleDee.minion_hitbox_collision_             // 0xF0 - state 3 hurtbox collision w/ hitbox

// state 4 - shoot maybe
dw waddle_doo_attack_main    // 4 main
dw Item.WaddleDee.waddle_ground_collision   // 4 collision / aerial transition
dw 0                                        // 4 hitbox collision w/ hurtbox
dw 0                                        // 4 hitbox collision w/ shield
dw 0                                        // 4 hitbox collision w/ shield edge
dw 0                                        // 4 unknown (maybe absorb)
dw 0                                        // 4 hitbox collision w/ reflector
dw Item.WaddleDee.minion_hitbox_collision_  // 4 hurtbox collision w/ hitbox


// @ Description
// set up for laser attack
scope waddle_doo_attack_initial: {
	addiu   sp, sp,-0x0018                  // allocate stack space
	sw      ra, 0x0014(sp)                  // ~
	sw      a0, 0x0018(sp)                  // store ra, a0

	// a0 = item object

	// change image to index 2 and rotation to 0
	lw      a0, 0x0074(a0)                  // a0 = position struct
	sw      r0, 0x0038(a0)                  // set rotation to 0
	lw      a0, 0x0080(a0)                  // a0 = image struct
	lli     at, 0x0005                      // at = jump squat image
	sh      at, 0x0080(a0)                  // set waddle dee to landing frame
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

	jal     0x800269C0                      // play FGM (shoot intial)
	lli     a0, 0x00DC                      // FGM id = 0xD3 or 0x35

	lw      a0, 0x0018(sp)                  // restore a0
	li      a2, Item.WaddleDee.minion_attributes.struct // s2 = minion_attributes.struct
	lw      a2, Item.WaddleDee.minion_attributes.BEAM_CHARGE_TIME(a2) // argument 2 = time to do gfx routine
	addiu   a1, r0, 0x0007                  // argument 1 = flashing gfx routine
	lw      t6, 0x0080(a0)                  // t6 = current frame
	jal     0x80172F98                      // apply gfx routine to object
	lw      a0, 0x0018(sp)                  // a0 = item object
	lw      a0, 0x0018(sp)                  // restore a0

	li      a1, item_state_table            // a1 = object state base address
	jal     0x80172EC8                      // change item state
	ori     a2, r0, 0x0004                  // a2 = attack state
	lw      ra, 0x0014(sp)                  // load ra
	jr      ra                              // return
	addiu   sp, sp, 0x0018                  // deallocate stack space
}

// @ Description
// Laser attack
scope waddle_doo_attack_main: {
	addiu   sp, sp,-0x0040                  // allocate stack space
	sw      a0, 0x0014(sp)                  // ~
	sw      s1, 0x0018(sp)                  // ~
	sw      s2, 0x001C(sp)                  // ~
	sw      ra, 0x0030(sp)                  // store ra, s0-s2

	lw      s0, 0x0084(a0)                  // s0 = item special struct
	or      s1, a0, r0                      // s1 = item object
	li      s2, Item.WaddleDee.minion_attributes.struct // s2 = minion_attributes.struct
	lw      at, 0x0108(s0)                  // at = kinetic state

	lh      t0, 0x033E(s0)                  // t0 = timer value
	addiu   t0, t0, 1                       // t0 += 1
	sh      t0, 0x033E(s0)                  // write timer value
	lw      t1, Item.WaddleDee.minion_attributes.BEAM_CHARGE_TIME(s2) // t1 = time to charge beam
	bgt     t0, t1, _shooting               // branch if greater than timer to transition
	addiu	at, t1, -BEAM_STAR_COUNT + 1	// how many frames we are creating stars
	beq     at, t0, _spawn_beam_initial     // branch if first star is being created
	lw      a0, 0x0014(sp)                  // a0 = item object
	blt		t0, at, _check_duration
	nop
	lw		a1, 0x0084(a0)
	lw		a2, 0x0350(a1)					// a2 = last created star
	beqz	a2, _check_duration
	lw      a1, 0x0074(a2)                  // a1 = last stars position
	b		_spawn_star
	addiu	a1, a1, 0x001C					// ~
	
	_spawn_beam_initial:
	lw		v1, 0x0084(a0)
	sw      r0, 0x0248(v1)                  // disable waddle doo hurtbox
	jal     0x800269C0                      // play FGM (shoot)
	lli     a0, 0x0040                      // fgm id = 
	lw      a0, 0x0014(sp)                  // restore a0
	lw      v0, 0x0074(a0)                  // v0 = position struct
	addiu   a1, v0, 0x001C                  // a1 = initial coords
	lw      v0, 0x0080(v0)                  // v0 = image struct
	lli     at, 0x0006                      // at = jumping image
	lw      a0, 0x0014(sp)                  // restore a0 (waddle doo is owner)
	lw      a2, 0x0014(sp)                  // a2 = parent to append projectile to
	sh      at, 0x0080(v0)                  // set waddle dee to jump frame

	_spawn_star:
	// a1 = position
	jal     star_stage_setting
	nop
	lw      a0, 0x0014(sp)                  // a0 = item object
	lw		v1, 0x0084(a0)
	sw		v0, 0x0350(v1)					// overwrite last created projectile
	
	// overlay flashing gfx over waddle doo
	lw      a0, 0x0014(sp)                  // restore a0
	lw      v0, 0x0084(a0)                  // v0 = item struct
	addiu   a2, r0, 0x0014                  // a2, frame count to run gfx
	addiu   a1, r0, 0x002A                  // a1, gfx routine = white and black flashing
	lw      t6, 0x0080(a0)                  // t6 = current frame (?)
	jal     0x80172F98                      // apply gfx routine
	lw      a0, 0x0014(sp)                  // a0 = item object
	b       _check_duration
	nop

	_shooting:
	addiu   t1, t1, 40                      // t1 += 40 frames
	blt     t0, t1, _check_duration         // continue if still shooting
	nop

	_end_shooting:
	jal     Item.WaddleDee.minion_walk_intitial // set state to walk
	or      a0, s1, r0                      // a0 = item object
	b       _end
	or      a0, s1, r0                      // restore a0

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

constant BEAM_STAR_COUNT(4)
constant BEAM_STAR_DAMAGE(3)
constant BEAM_TIME_BETWEEN_DESTROY(1)
constant BEAM_CHILD_ANGLE_OFFSET(0x3ED0)
constant BEAM_START_UP(10)	// after created

// @ Description
// Creates waddle doo's beam. This spawns 3 star projectiles and places them at their initial angle
// a0 = waddle doo
// a1 = waddle doo coords
// a2 = parent
scope star_stage_setting: {
	variable alloc(0x60)
	addiu   sp, sp, -alloc					// allocate stack space
	sw      a1, 0x0010(sp)                  // store ptr to initial coordinates
	lw		v1, 0x0084(a0)					// v1 = waddle doo item struct
	sw      a1, 0x002C(sp)                  // save waddle doo to sp

	lw      at, 0x0008(v1)                  // load waddle doos parent
	sw      at, 0x0034(sp)                  // save waddle doos parent to sp
	sw      a0, 0x0014(sp)                  // store waddle doo object
			
	lw      at, 0x0024(v1)                  // at = waddle doos direction
	sw      at, 0x005C(sp)                  // save waddle doos direction to sp
	sw      a0, 0x001C(sp)                  // ~
	sw		a2, 0x0020(sp)
	sw      ra, 0x0018(sp)                  // store ra

	_loop_setup:
	// routine 0x8016679C deals with this value
	lli		at, BEAM_STAR_COUNT				// at = loop count
	addiu	a1, sp, alloc					// a1 = free space projectile ptrs
	_clear_space_loop:
	sw      r0, 0x0000(a1)                  // clear space for projectile ptr
	addiu	a1, a1, 0x04					// a1 = next place to write to
	bnez	at, _clear_space_loop			// keep looping
	addiu	at, at, -1						// at--
	
	sw      r0, 0x003C(sp)                  // make space for loop counter
	li      a1, Item.WaddleDee.minion_attributes.struct
	lw      at, Item.WaddleDee.minion_attributes.BEAM_DURATION(a1)  // at = beam duration
	sh      at, 0x0050(sp)                  // save duration to sp
	lw      at, Item.WaddleDee.minion_attributes.BEAM_INITIAL_ANGLE(a1)  // at = beam initial angle
	sw      at, 0x0054(sp)                  // save angle to sp
	lw      at, Item.WaddleDee.minion_attributes.BEAM_DISTANCE_FROM_PARENT(a1)  // at = beam distance from parent
	sw      at, 0x0058(sp)                  // save distance to sp
	addiu	at, BEAM_START_UP
	sh 		at, 0x0052(sp)                  // save initial flash timer to sp

	lw      a1, 0x002C(sp)                  // load coords
	jal     create_beam_star                 // create star projectile, based on star rod
	lw      a0, 0x0034(sp)                   // load player object
	beqz    v0, _end                         // skip if not enough space for star
	addiu   at, r0, 0x0001

	// projectile created. initial setup
	sw      at, 0x007C(v0)				     // overwrite visibility
	lw      a0, 0x001C(sp)                   // a0 = parent object
	lw      t2, 0x0084(a0)                   // t2 = parent struct
	lbu     t5, 0x0012(t2)                   // get team?
	sw      v0, 0x001C(sp)                   // write new object to sp
	lw      v1, 0x0084(v0)                   // v1 = new projectile struct
	sw		r0, 0x0020(v1)				 	 // remove x velocity
	sb      t5, 0x0012(v1)                   // save team id to projectile
	lw      at, 0x0034(sp)                   // at = player parent object
	sw      at, 0x0008(v1)                   // overwrite parent with player
	lw      t2, 0x002C(sp)                   // at = parent position struct

	sw      t2, 0x002C(sp)                   // overwrite ptr to parent coords in sp
	lw		at, 0x0020(sp)				 	 // get parent object
	sw      at, 0x02A0(v1)                   // write parent object to custom space
	lw      at, 0x0000(t2)                   // get parent x
	sw      at, 0x0048(sp)                   // store parent x in stackspace
	lw      at, 0x0004(t2)                   // get parent y
	sw      at, 0x004C(sp)                   // store parent y in stackspace

	sw      v0, 0x001C(sp)                   // save projectile object to sp
	lw      t0, 0x0084(a0)                   // t0 = parent special struct
	lli     at, 0x0001
	sh      at, 0x02A8(v1)                   // overwrite custom space with 1
	sw      at, 0x0018(v1)                   // ?

	// set timer values
	sw      v1, 0x0044(sp)                   // save projectile struct to sp
	lh      at, 0x0050(sp)                   // at = duration
	sw      at, 0x29C(v1)                    // save to projectile struct
	addiu   at, at, 2                        // modify value for next star
	sh      at, 0x0050(sp)                   // save duration for next star to use
	
	lh      at, 0x0052(sp)                   // at = start up flash duration
	sh      at, 0x029A(v1)                   // save to projectile struct
	addiu   at, at, 2                        // modify value for next star
	sh      at, 0x0052(sp)                   // save flash timer for next star to use

	// get initial angle 
	lw      at, 0x0054(sp)
	sw      at, 0x02A4(v1)                   // save initial angle to projectile struct
	mtc1    at, f18							 // move to float
	lui		at, BEAM_CHILD_ANGLE_OFFSET		 // angle offset
	mtc1    at, f12							 // move to float
	add.s	f12, f18, f12
	swc1	f12, 0x0054(sp)					 // overwrite angle in SP for next star to use.

	lli     at, 0x00FF                       // at = idk what this one is
	sw      at, 0x268(v1)                    // overwrite
	lli     at, BEAM_STAR_DAMAGE             // at = damage amount
	sw      at, 0x0104(v1)                   // overwrite
	lli     at, 0x0003                       // at = hitbox type (electric)
	sw      at, 0x010C(v1)                   // overwrite
	lli     at, FGM.hit.ELECTRIC_S           // at = fgm
	sh      at, 0x0146(v1)                   // overwrite
	sw		r0, 0x0100(v1)					 // disable hitbox... for now

	// based on 8016B100
	// set initial X
	lw      at, 0x02A4(v1)                   // get angle in radians
	sw      at, 0x0000(sp)                   // argument for next function
	mtc1    at, f12                          // move to float
	jal     0x80035cd0                       // math
	or      a3, v1, r0                       // a3 = projectile struct
	lw      at, 0x0058(sp)                   // load distance from sp
	mtc1    at, f18
	swc1    f0, 0x0038(sp)                   // save f0
	lw      a3, 0x0044(sp)
	lwc1    f0, 0x005C(sp)                   // load parent direction
	swc1    f0, 0x0018(a3)                   // write direction to projectile struct
	cvt.s.w f0, f0                           // convert direction to float
	nop
	mul.s   f4, f0, f18                      // f4 = x offset * direction
	nop
	lwc1    f18, 0x0048(sp)                  // load parent x pos
	add.s   f6, f4, f18                      // x = parent x + offset
	lw      at, 0x002C(a3)                   // at = projectile position struct
	swc1    f6, 0x0000(at)                   // save intial x coord
	swc1    f6, 0x0154(a3)                   // ~

	// set intial Y
	lwc1    f0, 0x0038(sp)                   // restore original direction (f0)
	lw      at, 0x0054(sp)                   // load angle from sp
	mtc1    at, f12
	jal     0x800303f0                       // math
	sw      at, 0x0000(sp)                   // argument for next function
	lw      at, 0x0058(sp)                   // load distance from sp
	mtc1    at, f8
	lw      a3, 0x0044(sp)
	lw      at, 0x0054(sp)                   // load angle from sp
	mtc1    at, f10
	mtc1    at, f12
	lwc1    f18, 0x004C(sp)                  // load parent y pos
	mul.s   f6, f0, f8
	add.s   f6, f18, f6                      // y = parent y + offset
	lw      at, 0x002C(a3)                   // at = projectile position struct
	swc1    f6, 0x0004(at)                   // save intial y coord
	swc1    f6, 0x0158(a3)                   // overwrite previous x coordinate

	lw      a0, 0x0014(sp)                  // restore a0
	lw      a1, 0x002C(sp)                  // restore a1
	lw      v0, 0x001C(sp)					// v0 = new projectile

	_end:
	lw      a0, 0x0014(sp)                  // ~
	lw      ra, 0x0018(sp)                  // restore ra
	jr      ra
	addiu   sp, sp, alloc 					// deallocate stack space

}

// @ Description
// Creates waddle doo's beam. This spawns 3 star projectiles and places them at their initial angle
// a0 = waddle doo
// a1 = waddle doo coords
// a2 = coords ptr
// scope beam_stage_setting: {
	// variable alloc(0x60 + BEAM_STAR_ALLOCATION)
	// addiu   sp, sp, -alloc					// allocate stack space
	// sw      a2, 0x0010(sp)                  // store ptr to initial coordinates
	// lw		v1, 0x0084(a0)					// v1 = waddle doo item struct
	// sw      a1, 0x002C(sp)                  // save waddle doo to sp

	// lw      at, 0x0008(v1)                  // load waddle doos parent
	// sw      at, 0x0034(sp)                  // save waddle doos parent to sp
	// sw      a0, 0x0014(sp)                  // store waddle doo object
			
	// lw      at, 0x0024(v1)                  // at = waddle doos direction
	// sw      at, 0x005C(sp)                  // save waddle doos direction to sp
	// sw      a0, 0x001C(sp)                  // ~
	// sw      ra, 0x0018(sp)                  // store ra

	// // a0 = parent object
	// // a2 = ptr to parents coordinates
	// _loop_setup:
	// jal     0x801655A0                      // get unique ID for projectile batch
	// nop
	// // routine 0x8016679C deals with this value
	// sw      v0, 0x0020(sp)                  // save unique ID for these projectiles
	// lli		at, BEAM_STAR_COUNT				// at = loop count
	// addiu	a1, sp, alloc					// a1 = free space projectile ptrs
	// _clear_space_loop:
	// sw      r0, 0x0000(a1)                  // clear space for projectile ptr
	// addiu	a1, a1, 0x04					// a1 = next place to write to
	// bnez	at, _clear_space_loop			// keep looping
	// addiu	at, at, -1						// at--
	
	// sw      r0, 0x003C(sp)                  // make space for loop counter
	// li      a1, Item.WaddleDee.minion_attributes.struct
	// lw      at, Item.WaddleDee.minion_attributes.BEAM_DURATION(a1)  // at = beam duration
	// sh      at, 0x0050(sp)                  // save duration to sp
	// lw      at, Item.WaddleDee.minion_attributes.BEAM_INITIAL_ANGLE(a1)  // at = beam initial angle
	// sw      at, 0x0054(sp)                  // save angle to sp
	// lw      at, Item.WaddleDee.minion_attributes.BEAM_DISTANCE_FROM_PARENT(a1)  // at = beam distance from parent
	// sw      at, 0x0058(sp)                  // save distance to sp
	// addiu	at, BEAM_START_UP
	// sh 		at, 0x0052(sp)                  // save initial flash timer to sp

	// lw      a1, 0x002C(sp)                  // load coords

	// // CREATE STAR 
	// _loop_begin:
	// jal     create_beam_star                 // create star projectile, based on star rod
	// lw      a0, 0x0034(sp)                   // load player object
	// beqz    v0, _end                         // skip if not enough space for star
	// addiu   at, r0, 0x0001

	// // projectile created. initial setup
	// sw      at, 0x007C(v0)				     // overwrite visibility
	// lw      a0, 0x001C(sp)                   // a0 = parent object
	// lw      t2, 0x0084(a0)                   // t2 = parent struct
	// lbu     t5, 0x0012(t2)                   // get team?
	// sw      v0, 0x001C(sp)                   // overwrite parent object with current object in sp
	// lw      v1, 0x0084(v0)                   // v1 = new projectile struct
	// sw		r0, 0x0020(v1)					// remove x velocity
	// sb      t5, 0x0012(v1)                   // save team id to projectile
	// lw      at, 0x0020(sp)                   // at = unique ID
	// sw      at, 0x0264(v1)                   // save unique ID to projectile struct
	// lw      at, 0x0034(sp)                   // at = player parent object
	// sw      at, 0x0008(v1)                   // overwrite parent with player
	// lw      at, 0x0074(a0)                   // at = parent position struct
	// addiu   t2, at, 0x001C
	// sw      t2, 0x002C(sp)                   // overwrite ptr to parent coords in sp
	// sw      a0, 0x02A0(v1)                   // save parent object to custom space
	// lw      at, 0x0000(t2)                   // get parent x
	// sw      at, 0x0048(sp)                   // store parent x in stackspace
	// lw      at, 0x0004(t2)                   // get parent y
	// sw      at, 0x004C(sp)                   // store parent y in stackspace

	// sw      v0, 0x001C(sp)                   // save projectile object to sp
	// lw      t0, 0x0084(a0)                   // t0 = parent special struct
	// lli     at, 0x0001
	// sh      at, 0x02A8(v1)                   // overwrite custom space with 1
	// sw      at, 0x0018(v1)                   // ?

	// // set timer values
	// sw      v1, 0x0044(sp)                   // save projectile struct to sp
	// lh      at, 0x0050(sp)                   // at = duration
	// sw      at, 0x29C(v1)                    // save to projectile struct
	// addiu   at, at, 2                        // modify value for next star
	// sh      at, 0x0050(sp)                   // save duration for next star to use
	
	// lh      at, 0x0052(sp)                   // at = start up flash duration
	// sh      at, 0x029A(v1)                   // save to projectile struct
	// addiu   at, at, 2                        // modify value for next star
	// sh      at, 0x0052(sp)                   // save flash timer for next star to use

	// // get initial angle 
	// lw      at, 0x0054(sp)
	// sw      at, 0x02A4(v1)                   // save initial angle to projectile struct
	// mtc1    at, f18							 // move to float
	// lui		at, BEAM_CHILD_ANGLE_OFFSET		 // angle offset
	// mtc1    at, f12							 // move to float
	// add.s	f12, f18, f12
	// swc1	f12, 0x0054(sp)					 // overwrite angle in SP for next star to use.

	// lli     at, 0x00FF                       // at = idk what this one is
	// sw      at, 0x268(v1)                    // overwrite
	// lli     at, BEAM_STAR_DAMAGE             // at = damage amount
	// sw      at, 0x0104(v1)                   // overwrite
	// lli     at, 0x0003                       // at = hitbox type (electric)
	// sw      at, 0x010C(v1)                   // overwrite
	// lli     at, FGM.hit.ELECTRIC_S           // at = fgm
	// sh      at, 0x0146(v1)                   // overwrite
	// sw		r0, 0x0100(v1)					 // disable hitbox... for now

	// // based on 8016B100
	// // set initial X
	// lw      at, 0x02A4(v1)                   // get angle in radians
	// sw      at, 0x0000(sp)                   // argument for next function
	// mtc1    at, f12                          // move to float
	// jal     0x80035cd0                       // math
	// or      a3, v1, r0                       // a3 = projectile struct
	// lw      at, 0x0058(sp)                   // load distance from sp
	// mtc1    at, f18
	// swc1    f0, 0x0038(sp)                   // save f0
	// lw      a3, 0x0044(sp)
	// lwc1    f0, 0x005C(sp)                   // load parent direction
	// swc1    f0, 0x0018(a3)                   // write direction to projectile struct
	// cvt.s.w f0, f0                           // convert direction to float
	// nop
	// mul.s   f4, f0, f18                      // f4 = x offset * direction
	// nop
	// lwc1    f18, 0x0048(sp)                  // load parent x pos
	// add.s   f6, f4, f18                      // x = parent x + offset
	// lw      at, 0x002C(a3)                   // at = projectile position struct
	// swc1    f6, 0x0000(at)                   // save intial x coord
	// swc1    f6, 0x0154(a3)                   // ~

	// // set intial Y
	// lwc1    f0, 0x0038(sp)                   // restore original direction (f0)
	// lw      at, 0x0054(sp)                   // load angle from sp
	// mtc1    at, f12
	// jal     0x800303f0                       // math
	// sw      at, 0x0000(sp)                   // argument for next function
	// lw      at, 0x0058(sp)                   // load distance from sp
	// mtc1    at, f8
	// lw      a3, 0x0044(sp)
	// lw      at, 0x0054(sp)                   // load angle from sp
	// mtc1    at, f10
	// mtc1    at, f12
	// lwc1    f18, 0x004C(sp)                  // load parent y pos
	// mul.s   f6, f0, f8
	// add.s   f6, f18, f6                      // y = parent y + offset
	// lw      at, 0x002C(a3)                   // at = projectile position struct
	// swc1    f6, 0x0004(at)                   // save intial y coord
	// swc1    f6, 0x0158(a3)                   // overwrite previous x coordinate

	// _loop_increment:
	// lli     at, BEAM_STAR_COUNT -1          // at = # max loop iterations
	// lw      t0, 0x003C(sp)                  // load loop counter

	// or      t2, sp, r0                      // t2 = beam ptr list
	// sll     t3, t0, 4                       // t3 = current entry offset
	// or      t2, t2, t3                      // t2 = entry in beam ptr list
	// lw      v0, 0x001C(sp)                  // get projectile object
	// sw      v0, 0x0060(t2)                  // store projectile object to sp

	// beq     at, t0, _end                    // end loop if all projectiles created
	// addiu   t0, t0, 0x0001                  // loop counter++

	// lw      a0, 0x0014(sp)                  // restore a0
	// lw      a1, 0x002C(sp)                  // restore a1

	// b       _loop_begin
	// sw      t0, 0x003C(sp)                  // increase loop counter

	// _end:
	// lw      a0, 0x0014(sp)                  // ~
	// lw      ra, 0x0018(sp)                  // restore ra
	// jr      ra
	// addiu   sp, sp, alloc 					// deallocate stack space

// }


// @ Description
// Based on star rod projectile creation
// a0 = parent object (player)
// a1 = initial coordinates
// a2 = heavy or light star boolean?
scope create_beam_star: {
	addiu	sp, sp, -0x20
	sw		ra, 0x0014(sp)
	lli		at, 0x0001
	sw		at, 0x0028(sp) 					// store unknown boolean to sp
	sw		a1, 0x0024(sp)					// store initial coordinates
	li		a1, beam_info_array				// arg1 = beam info array
	j		0x801784A8						// goto original star rod star stage setting routine
	sw		at, 0x0028(sp)
}

// @ Description
// uses math function that PK thunder uses to keep the stars in a column
scope beam_main: {
	addiu    sp, sp, -0x30
	sw       ra, 0x0014(sp)
	sw       a0, 0x0018(sp)
	lw       v1, 0x0084(a0)
	sw       v1, 0x0010(sp)
	or       a2, a0, r0                     // a2 = a0
	
	lh		t0, 0x029A(v1)					// check startup timer
	beqz	t0, _continue
	lli		at, BEAM_START_UP
	bne		at, t0, _start_up_check			// continue if not the first frame
	addiu   at, t0, -1						// at = initial timer -1
	
	// create initial spark gfx:	
	lui     a1, 0x3f80
	sh		at, 0x029A(v1)					// save timer -1
	lw		a0, 0x0074(a0)					// set a0 as position struct
	jal		0x8010066C						// if first frame, create a sparkly gfx
	addiu 	a0, a0, 0x001C					// a0 = current coordinates
	b		_skip_movement					// skip movement
	nop
	
	_start_up_check:
	bnezl	at, _skip
	lw      v1, 0x0010(sp)
	// if here, enable projectile
	addiu   at, r0, 0

	_skip:
	b		_skip_movement					// skip movement
	sh		at, 0x029A(v1)					// save timer

	_continue:
	jal      0x801781B0                     // original star projectile routine
	nop
	
	bnez     v0, _end_destroy               // destroy if duration is up
	lw       a0, 0x0018(sp)                 // restore a0
	
	// update visibility/hitbox every 2 frames
	lw       at, 0x007C(a0)					// at = draw enabled flag
	lw       v1, 0x0010(sp)                 // restore projectile struct
	lh       v0, 0x02A8(v1)					// v0 = second flag we are using to enable/disable drawing
	bnel	 at, v0, _check_duration		// branch if the flags aren't the same
	sh		 at, 0x02A8(v1)					// overwrite the flag in projectile struct
	
	_suspend:
	addiu    t0, r0, 0x0001					// t0 = 1
	
	_toggle:
	beql	 t0, at, _toggle_hitbox		    // toggle drawing
	sw       r0, 0x007C(a0)					// ~
	sw       t0, 0x007C(a0)					// ~

	_toggle_hitbox:
	addiu	t0, r0, 0x0003					// at = hitbox update interval (0 = disabled)
	lw      v0, 0x0100(v1)					// load hitbox update interval
	bnel	t0, v0, _check_duration			// set hitbox update interval
	sw		t0, 0x0100(v1)					// set enabled
	sw      r0, 0x0100(v1)					// set disabled
	
	_check_duration:
	lw       at, 0x029C(v1)                 // get duration
	sll      t0, at, 31						// update position offset ever 2 frames
	bnez     t0, _skip_movement             // we aren't calculating movement every frame 

	lw       at, 0x02A4(v1)                 // get current angle
	mtc1     at, f8                         // move to float
	li       t0, Item.WaddleDee.minion_attributes.struct
	lw       at, Item.WaddleDee.minion_attributes.BEAM_DISTANCE_FROM_PARENT(t0) // at = distance
	sw       at, 0x0020(sp)                 // save to sp
	lw       at, Item.WaddleDee.minion_attributes.BEAM_ROTATION_AMOUNT(t0)  // at = beam rotation amount (every 4 frames)

	mtc1     at, f10                        // move to float
	sub.s    f8, f8, f10                    // subtract rotation amount
	swc1     f8, 0x02A4(v1)

	lw      t0, 0x02A0(v1)                  // t0 = parent object
	beqz    t0, _skip_movement				// if parent is gone, skip movement
	nop
	
	// if here, parent object is alive
	lw      at, 0x0084(t0)                  // at = parents item struct
	beqz	at, _skip_movement				// skip movement if no parent special struct
	nop
	lw		at, 0x000C(at)					// get item id
	beqzl	at, _skip_movement				// skip movement if parent is no longer a star
	sw      r0, 0x02A0(v1)                  // remove parent association if no position struct
	lw      t0, 0x0074(t0)                  // t0 = parent object position struct
	beqzl	t0, _skip_movement
	sw      r0, 0x02A0(v1)                  // remove parent association if no position struct

	addiu   t0, t0, 0x1C					// t0 = parent coords
	lw      at, 0x0000(t0)                  // get parent x pos
	sw      at, 0x0008(sp)                  // save parent x pos
	lw      at, 0x0004(t0)                  // get parent y pos
	sw      at, 0x000C(sp)                  // save parent y pos

	lw      t1, 0x002C(v1)                  // t1 = ptr to own coords
	sw      t1, 0x001C(sp)                  // save to sp

	// here we calculate the new position
	lw      v1, 0x0010(sp)                  // restore projectile struct
	lw      at, 0x02A4(v1)                  // get angle in radians
	sw      at, 0x0000(sp)                  // argument for next function
	mtc1    at, f12                         // move to float
	jal     0x80035cd0                      // math
	or      a3, v1, r0                      // a3 = projectile struct
	lw      at, 0x0020(sp)                  // load distance from sp
	mtc1    at, f18
	swc1    f0, 0x0030(sp)                  // save f0
	lwc1    f0, 0x0018(a3)                  // move current direction to float
	cvt.s.w f0, f0                          // convert direction to float
	nop
	mul.s   f4, f0, f18                     // f4 = x offset * direction
	lwc1    f18, 0x0008(sp)                 // load parent x pos
	add.s   f6, f4, f18                     // x = parent x + offset
	lw      at, 0x001C(sp)                  // at = projectile position struct
	swc1    f6, 0x0000(at)                  // save intial x coord

	// set intial y
	lwc1    f0, 0x0030(sp)                  // restore f0
	lw      v1, 0x0010(sp)                  // restore projectile struct
	lw      at, 0x02A4(v1)                  // get angle in radians
	mtc1    at, f12
	jal     0x800303f0                      // math
	sw      at, 0x0000(sp)                  // argument for next function
	lw      at, 0x0020(sp)                  // load distance from sp
	mtc1    at, f8
	lw      v1, 0x0010(sp)                  // restore projectile struct
	lw      at, 0x02A4(v1)                  // get angle in radians
	mtc1    at, f10
	mtc1    at, f12
	lwc1    f18, 0x000C(sp)                 // load parent y pos
	mul.s   f6, f0, f8
	add.s   f6, f18, f6                     // y = parent y + offset
	lw      at, 0x001C(sp)                  // at = projectile position struct
	swc1    f6, 0x0004(at)                  // save intial y coord

	lw      v1, 0x0010(sp)                  // restore projectile struct
	sw      r0, 0x214(v1)                   // remove hit player from struct for multi-hit

	_skip_movement:
	or        v0, r0, r0                    // v0 = don't destroy me

	_end_destroy:
	lw        ra, 0x0014(sp)
	jr        ra
	addiu     sp, sp, 0x30

}

// currently a copy of star rod projectile @ 8018A1C4
beam_info_array:
dw 0x00000000        // ?
dw 0x00000016        // projectile id
dw 0x8018D040        // pointer to file 0xFB
dw 0x000004D4        // offset in file
dw 0x1C000000        // rendering routine index ?
dw beam_main         // main routine
dw 0x00000000        // collision with clipping
dw 0x00000000        // collision with hurtbox
dw 0x00000000        // collision with hitbox
dw 0x00000000        // collision with something
dw 0x00000000        // collision with something
dw 0x00000000        // collision with something
dw 0x00000000        // collision with something
dw 0x00000000        // collision with something