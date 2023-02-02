// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_) // bomb is 0x80177D9C
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_item)
constant PICKUP_ITEM_INIT(prepickup_) // prepickup
constant DROP_ITEM(drop_item_)
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(0)

constant HITBOX_TYPE(Damage.id.BURY)
constant BOUNCE_MULTIPLIER(0x3F00)
constant KB_ANGLE(270)		// downwards
constant DAMAGE(14)			//
constant AERIAL_BASE_KB(0x100)
constant GROUNDED_HURTBOX_FGM(0x25)	// was FGM.NONE
constant AERIAL_HURTBOX_FGM(0x25)
constant PLANT_FGM(0x439)
constant GROUNDED_BASE_KB(0x100)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xF70)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw 0x8018D040                           // 0x04 - hard-coded pointer to file
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
dw 0                                    // 0x00
dw 0x801744FC                           // 0x04 buried (using Maxim Tomato)
dw 0                                    // 0x08
dw 0                                    // 0x0C
dw 0, 0, 0, 0                           // 0x10 - 0x1C

// STATE 1 - PREPICKUP - AERIAL
dw 0x801744C0                           // 0x20 (using Maxim Tomato)
dw 0x80174524                           // 0x24 (using Maxim Tomato)
dw 0, 0                                 // 0x28 - 0x2C
dw 0, 0, 0, 0                           // 0x30 - 0x3C

// STATE 2 - PICKUP
dw 0, 0, 0, 0                           // 0x40 - 0x4C
dw 0, 0, 0, 0                           // 0x50 - 0x5C

// STATE 3 - thrown
dw 0x80177530                       	// 0x60 - gravity routine
dw collision_                      		// 0x64 - collision with clipping (bomb is 0x8017756C)
dw destroy_                 			// 0x68
dw destroy_                 			// 0x6C
dw destroy_                 			// 0x70
dw destroy_                 			// 0x74
dw 0x80173434                 			// 0x78 - reflect
dw destroy_    							// 0x7C - absorb

// STATE 4 - BURIED
dw buried_main_
dw buried_collision_
dw destroy_
dw destroy_
dw destroy_
dw destroy_
dw destroy_
dw destroy_                        		// 0xC0 - 0xDC


// @ Description
// spawns the gem, based on bob-ombs spawn routine @0x80177D9C
scope stage_setting_: {
    addiu   sp, sp, -0x48
    sw      a2, 0x0050 (sp)
    or      a2, a1, r0
    sw      s0, 0x0020 (sp)
    sw      a1, 0x004c (sp)
    or      s0, a3, r0
    sw      ra, 0x0024 (sp)
    li      a1, item_info_array
    lw      a3, 0x0050 (sp)

    jal     0x8016e174
    sw      s0, 0x0010 (sp)
    beqz    v0, _end
    or      a3, v0, r0
    lw      v0, 0x0074 (v0)
    addiu   t6, sp, 0x0030
    or      a0, a3, r0
    addiu   v1, v0, 0x001c
    lw      t8, 0x0000 (v1)
    sw      t8, 0x0000 (t6)
    lw      t7, 0x0004 (v1)
    sw      t7, 0x0004 (t6)
    lw      t8, 0x0008 (v1)
    sw      t8, 0x0008 (t6)
    lw      s0, 0x0084 (a3)
    sh      r0, 0x033e (s0)
    sw      a3, 0x0044 (sp)
    sw      v1, 0x002c (sp)
    // jal     explode_subroutine_
    sw      v0, 0x0040 (sp)
    lw      a0, 0x0040 (sp)
    addiu   a1, r0, 0x002E    // argument 1 = billboard object?
    jal     0x80008cc0
    or      a2, r0, r0
    addiu   t0, sp, 0x0030
    lw      t2, 0x0000 (t0)
    lw      t9, 0x002c (sp)
    mtc1    r0, f4
    or      a0, s0, r0
    sw      t2, 0x0000 (t9)
    lw      t1, 0x0004 (t0)
    sw      t1, 0x0004 (t9)
    lw      t2, 0x0008 (t0)
    sw      t2, 0x0008 (t9)
    lbu     t4, 0x02d3 (s0)
    ori     t5, t4, 0x0004
    sb      t5, 0x02d3 (s0)
    lw      t6, 0x0040 (sp)
    jal     0x80111ec0
    swc1    f4, 0x0038 (t6)
    lw      a3, 0x0044 (sp)
    sw      v0, 0x0348 (s0)
	
	lli 	v0, HITBOX_TYPE
    sw      v0, Item.STRUCT.HITBOX.TYPE(s0)	// overwrite angle
	
	lli		v0, KB_ANGLE
    sw      v0, Item.STRUCT.HITBOX.ANGLE(s0)	// overwrite angle

    addiu   v0, r0, AERIAL_HURTBOX_FGM 			// v0 = aerial hurtbox FGM
    sh      v0, 0x156(s0)     					// save fgm value

    addiu   v0, r0, AERIAL_BASE_KB  // v0 = knockback
    sw      v0, Item.STRUCT.HITBOX.KNOCKBACK1(s0)     // save
    sw      v0, Item.STRUCT.HITBOX.KNOCKBACK2(s0)     // save
    sw      v0, Item.STRUCT.HITBOX.KNOCKBACK3(s0)     // save
	
	addiu   v0, r0, DAMAGE
    sw      v0, Item.STRUCT.HITBOX.DAMAGE(s0)     	// save

    _end:
    lw     ra, 0x0024 (sp)
    lw     s0, 0x0020 (sp)
    addiu  sp, sp, 0x48
    jr     ra
    or     v0, a3, r0

}

scope drop_item_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      v0, 0x0010(sp)
    sw      r0, 0x011C(v0)            // damage type = normal
    jal     0x801745FC                // item drop subroutine for tomato
    nop
    lw      v0, 0x0010(sp)
    sw      r0, 0x0140(v0)             // set kb to 0
    sw      r0, 0x0144(v0)             // set kb to 0
    sw      r0, 0x0148(v0)             // set kb to 0
    lw      ra, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x18
} 



// @ Description
// function which runs when the gem gets hit
scope hurtbox_collision_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address
    sw		a0, 0x0018(sp)			        // save item object
	
	lw		v1, 0x0084(a0)					// v1 = item struct
	
	_continue:
    jal     apply_multiplier_               // apply speed multiplier
    lui     a1, 0xBE80                      // a1 = speed multiplier
    jal     falling_initial_                // begin falling
    lw      a0, 0x0018(sp)                  // a0 = item object
    or      v0, r0, r0                      // don't destroy
	_end:
    lw      ra, 0x0014(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x20                    // deallocate stack space
}

// @ Description
// Subroutine which applies a speed multiplier to the gem
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
// disables hurt/hit boxes
scope falling_initial_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x0014(sp)
    lw      v1, 0x0084(a0)                  // v1 = item special struct
    sw      r0, 0x0248(v1)                  // disable hurtbox
    sw      r0, 0x010C(v1)                  // disable hitbox
    lw      ra, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x30
}

// @ Description
// based on red shell collision routine @ 0x8017AE48
scope destroy_: {
    jr      ra
    addiu   v0, r0, 0x0001			// destroy item
}


// @ Description
// based on bobbomb prepickup @ 0x801774FC
scope prepickup_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     0x80177218                  // subroutine disables hurtbox
    // v0 = item struct
    sw      a0, 0x0018(sp)              // store a0

    li      a1, item_state_table        // a1 = state table
    lw      a0, 0x0018(sp)              // original line - idk why it loads a0 when it hasn't changed

    jal     0x80172ec8                  // change item state
    addiu   a2, r0, 0x0002              // state = 2 (picked up)

    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// based on bobbomb throw routine @ 0x80177590
scope throw_initial_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
	lw		v0, 0x0084(a0)			// v0 = item struct
    addiu   at, r0, 0x000B          // at = bury damage type
    sw      at, 0x011C(v0)          // overwrite damage type
	lh      t0, 0x0158(v0)          // t0 = clang bitfield
	andi    t0, t0, 0x7FFF          // disable clang
	sh      t0, 0x0158(v0)          // ~
    addiu   at, r0, AERIAL_BASE_KB  // at = knockback
    sw      at, Item.STRUCT.HITBOX.KNOCKBACK1(v0)     // save
    sw      at, Item.STRUCT.HITBOX.KNOCKBACK2(v0)     // save
    sw      at, Item.STRUCT.HITBOX.KNOCKBACK3(v0)     // save
    jal     0x80177208
    sw      a0, 0x0018 (sp)
    li      a1, item_state_table
    lw      a0, 0x0018 (sp)
    jal     0x80172ec8              // change item state
    addiu   a2, r0, 0x0003          // state = 3(thrown)
    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x18
}

constant COLLISION_MASK(0x0800)				// all types = 0x0C21

// @ Description
// Aerial collision subroutine for Pitfall.
// a0 = item object
scope collision_: {
	addiu   sp, sp,-0x0058                  // allocate stack space
	sw      ra, 0x0014(sp)                  // ~
	sw      s0, 0x0040(sp)                  // ~
	sw      s1, 0x0044(sp)                  // store ra, s0, s1
	or      s0, a0, r0                      // s0 = item object

	lw      a0, 0x0084(s0)                  // ~
	addiu   a0, a0, 0x0038                  // a0 = x/y/z position
	li      a1, detect_collision_           // a1 = collision subroutine
	or      a2, s0, r0                      // a2 = item object
	//jal     0x800DA034                      // collision detection
	or      a0, s0, r0                      // a0 = s0
	jal     0x801737B8                      // collision detect
	ori     a1, r0, 0x0C21          		// bitmask (all collision types)
	sw      v0, 0x0028(sp)                  // store collision result
	or      a0, s0, r0                      // a0 = item object
	ori     a1, r0, 0x0C21          		// bitmask (all collision types)
	lui		a2, BOUNCE_MULTIPLIER			// a2 =
	jal     0x801737EC                      // apply collsion/bounce?
	or      a3, r0, r0                      // a3 = 0

	lw      t0, 0x0028(sp)                  // t0 = collision result
	beqz    t0, _end                        // branch if collision result = FALSE
	lw      t8, 0x0084(s0)                  // t8 = item special struct
	lhu     t0, 0x0092(t8)                  // t0 = collision flags
	andi    at, t0, COLLISION_MASK          // t0 = collision flags | grounded bitmask
	beqz    at, _end               			// branch if ground collision flag = TRUE
	nop

	// if here, stick into the ground
	jal     begin_buried_                   // change to grounded/buried state
	or      a0, s0, r0                      // a0 = item object
	bnez	v0, _end2						// destroy pitfall if returned > 0
	nop

	_end:
	or      v0, r0, r0                      // return 0
	_end2:
	lw      ra, 0x0014(sp)                  // ~
	lw      s0, 0x0040(sp)                  // ~
	lw      s1, 0x0044(sp)                  // load ra, s0, s1
	jr      ra                              // return
	addiu   sp, sp, 0x0058                  // deallocate stack space

}

// @ Description
// Collision detection subroutine
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

// @ Description
// a0 = item object
scope begin_buried_: {
	addiu   sp, sp,-0x0018                  // allocate stack space
	sw      ra, 0x0014(sp)                  // ~
	sw      a0, 0x0018(sp)                  // store ra, a0
	lw      a0, 0x0084(a0)                  // a0 = item special struct
	lbu     t0, 0x02CE(a0)                  // t0 = unknown bitfield
	jal     0x80173F54						// sets grounded state?
	nop
	// ori     t0, t0, 0x0080               // enables item pickup bit
	andi    t0, t0, 0x00CF                  // disable 2 bits
	sb      t0, 0x02CE(a0)                  // store updated bitfield
	lh      t0, 0x0158(a0)                  // t0 = clang bitfield
	andi    t0, t0, 0x7FFF                  // disable clang
	sh      t0, 0x0158(a0)                  // ~
	
	// check stage id first (for some reason, SAFFRON doesn't return correct clipping flag)
    li      t0, Global.match_info           // ~ 0x800A50E8
    lw      t0, 0x0000(t0)                  // t0 = match_info
    lbu     t0, 0x0001(t0)                  // t0 = stage id
	addiu   at, r0, Stages.id.SAFFRON_CITY  // at = SAFFRON CITY stage id
	beq		at, t0, _continue
	nop

	jal		Surface.get_clipping_flag_		// return clipping flag in v0
	lw		a0, 0x00AC(a0)					// arg0 = platform ID
	andi	v0, v0, 0x00FF					// v0 = second byte only
	beqz	v0, _continue					// continue if not hazardous clipping	
	// if here, check hazard mode
    li      at, Toggles.entry_hazard_mode
    lw      at, 0x0004(at)              	// at = hazard_mode (hazards disabled when at = 1 or 3)
    andi    at, at, 0x0001              	// at = 1 if hazard_mode is 1 or 3, 0 otherwise
    beqzl   at, _end                   		// don't bury self if hazards are enabled
	lli		v0, 1							// return 1 (destroy pitfall)
	
	_continue:
	lw      a0, 0x0018(sp)                  // restore a0
	lw      a0, 0x0084(a0)                  // a0 = item special struct
	
	sw      r0, 0x002C(a0)                  // x speed = 0
	sw      r0, 0x0030(a0)                  // y speed = 0
	sw      r0, 0x0034(a0)                  // z speed = 0
	jal     stick_to_surface				// stick item to collided surface
	lw      a0, 0x0018(sp)                  // a0 = item object
	jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
	lw      a0, 0x0018(sp)                  // a0 = item object
	lw      a0, 0x0018(sp)                  // a0 = item object
	lw		v1, 0x0084(a0)					// v1 = struct
    sw      r0, 0x0248(v1)                  // disable hurtbox
	li      a1, item_state_table            // a1 = object state base address
	jal     0x80172EC8                      // change item state
	ori     a2, r0, 0x0004                  // buried state
	lli		v0, 0							// return 0 (dont destroy)

	_end:
	lw      ra, 0x0014(sp)                  // load ra
	jr      ra                              // return
	addiu   sp, sp, 0x0018                  // deallocate stack space
}


constant DISPLAY_LIST_OFFSET(0x3F0)
// motion sensor stick to surface = 80176840
scope stick_to_surface: {
	addiu 	sp, sp, -0x20
	sw    	ra, 0x0014(sp)
	sw      a0, 0x0020(sp)   		// store item object
	lw    	v0, 0x0084(a0)          // v0 = item struct
	lw    	v1, 0x0074(a0)          // v1 = position struct
	lw		t1, 0x0050(v1)			// t1 = displaylist ptr
	addiu 	t1, t1, 0x03F0			// t1 += offset to next displaylist 
	sw		t1, 0x0050(v1)			// overwrite displaylist ptr
	
	move    a0, v1      			// arg 0 = position struct
    addiu   a1, r0, 0x0020    		// arg 1 = render flat?
    jal     0x80008CC0				// change rendering mode
    or      a2, r0, r0
	lw      a0, 0x0020(sp)   		// restore item object
	lw    	v1, 0x0074(a0)          // v1 = position struct
	
	lui   	at, 0x41F0				// leftovers?
	mtc1  	at, f2					// ~
	mtc1  	r0, f0					// ~
	lui   	at, 0xC1f0				// ~

	jal   	0x80176708	     		// attaches item to the surface
	lw      a0, 0x0020(sp)   		// restore item object
	lw      a0, 0x0020(sp)   		// restore item object
	lw 		v0, 0x0084(a0)			// v0 = item struct
	lw 		v1, 0x0074(a0)			// v1 = item struct
	li      at, 0xbfc90ff9			// at = -90 deg (radians)
	sw		at, 0x0030(v1)			// overwrite x rotation

	addiu 	t3, r0, 0x0001
	addiu 	at, r0, 0xffff
	lbu   	t1, 0x02cf(v0)
	lbu   	v1, 0x0015(v0)
	sw    	t3, 0x0248(v0)
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
	lw    	a0, 0x0084(a0)				// argument = item struct

	_end:
	// set damage
	lw    	a0, 0x0020(sp)				// a0 = item object
	lw		v0, 0x0084(a0)				// v0 = item struct	
	addiu	at, r0, GROUNDED_BASE_KB
	sw		at, Item.STRUCT.HITBOX.KNOCKBACK1(v0) // overwrite knockback
	addiu   at, r0, GROUNDED_HURTBOX_FGM // v0 = hurtbox FGM
    sh      at, 0x156(v0)     			// save fgm value

	// set counter to 2 seconds
	lli     at, 120  				    // 2 seconds until it can damage owner
	sw      at, 0x0350(v0)			    // set counter that removes player owner when 0

	FGM.play(PLANT_FGM)					// play fgm
	lw    	a0, 0x0020(sp)
	lw    	ra, 0x0014(sp)
	jr    	ra
	addiu 	sp, sp, 0x20

}

// @ Description
// based on bobombs @ 0x80177B10
scope buried_main_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
	lw		a2, 0x0084(a0)
    sw      a2, 0x0010(sp)
	
	lw		t0, 0x0350(a2)			// t0 = timer
	addiu	t0, t0, -1				// t0 = timer - 1
	bnez	t0, _end				// branch if timer is not 0
	sw		t0, 0x0350(a2)			// save timer
	// if here, timer is 0 and allow owner to take damage
	sw		r0, 0x0008(a2)			// remove player owner

	_end:
    or      v0, r0, r0
    lw      ra, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// Collision subroutine for the waddle_dee's buried state.
// a0 = item object
scope buried_collision_: {
	addiu   sp, sp,-0x0020                  // allocate stack space
	sw      ra, 0x0014(sp)                  // store ra
	sw		a0, 0x0020(sp)
	lw		v1, 0x0084(a0)
	lhu		a0, 0x02d0(v1)					// get a flag?
	jal		0x800fC67C
	sw		v1, 0x001C(sp)
	bnezl	v0, _end						// don't destroy if not aerial
	or      v0, r0, r0                      // return 0
	lw		a0, 0x0020(sp)
	addiu   v0, r0, 1                       // return 1, destroys item
	_end:
	lw      ra, 0x0014(sp)                  // restore ra
	jr      ra                              // return
	addiu   sp, sp, 0x0020                  // deallocate stack space
}

// @ Description
// Main item pickup routine for cloaking device.
scope pickup_item: {
    // a0 = player struct
    // a2 = item object
    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}