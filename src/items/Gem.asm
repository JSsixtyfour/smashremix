// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(gem_stage_setting_) // bomb is 0x80177D9C
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_gem)
constant PICKUP_ITEM_INIT(prepickup_) // prepickup
constant DROP_ITEM(0x801745FC) // same as Maxim Tomato
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0x40)
constant SHATTER_FGM(0x33)		// 0x33 = fan smack

// @ Description
// Pull values from this table when spawning gems
blue_gem:
dh 0x0000                       // palette offset (0)
dh 1                            // base damage
dh 30                           // base knockback
dh 90                           // kbg
green_gem:
dh 0x3F80                       // palette offset (1.0)
dh 4                            // base damage
dh 40                           // base knockback
dh 90                           // kbg


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
dw 0                                    // 0x00
dw 0x801744FC                           // 0x04 resting (using Maxim Tomato)
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
dw throw_duration_                      // 0x64 - collision with clipping (bomb is 0x8017756C)
dw collide_with_player_                 // 0x68
dw collide_with_player_                 // 0x6C
dw 0x801733E4                           // 0x70
dw collide_with_player_                 // 0x74
dw 0x80173434                           // 0x78
dw hurtbox_collision_    				// 0x7C

// STATE 6 - COLLIDE WITH GROUND
dw collide_with_clipping_
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0                          			// 0xC0 - 0xDC


// @ Description
// spawns the gem, based on bob-ombs spawn routine @0x80177D9C
scope gem_stage_setting_: {
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

    // GET ITEM VALUES BASED ON OWNERSHIP
	lw      t7, 0x001C(sp)              // t7 = owner object
    li      t1, blue_gem                // t1 = item info (blue gem)
    beqz    t7, _get_item_info          // branch if no owner object
    nop

    // if the item is being created with an owner, assume it's from Marina's clanpot
    li      t1, green_gem               // t1 = item info (green gem)

    // SET BASE DAMAGE
    _get_item_info:
    lh      at, 0x0002(t1)              // at = base damage
    sw      at, 0x0110(s0)              // overwrite base damage
    lh      at, 0x0004(t1)              // at = base knockback
    sw      at, 0x0148(s0)              // overwrite bkb
    lh      at, 0x0006(t1)              // at = knockback growth
    sw      at, 0x0140(s0)              // overwrite

    addiu   at, r0, 0x0105			    // at = hb FGM
    sh      at, 0x156(s0)               // overwrite hb fgm

    // SET PALETTE OFFSET
    lw      t2, 0x0004(s0)              // t2 = item object
    lw      t2, 0x0074(t2)              // t2 = joint/position struct
    lw      t2, 0x0080(t2)              // t2 = image struct?
    lhu     at, 0x0000(t1)              // at = palette index (float)
    sll     at, at, 16
    sw      at, 0x0088(t2)              // overwrite palette index (float)

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
// function which runs when the gem gets hit
scope hurtbox_collision_: {
    addiu   sp, sp, -0x20                   // allocate stackspace
    sw      ra, 0x0014(sp)                  // save return address
    sw		a0, 0x0018(sp)			        // save item object
	
	lw		v1, 0x0084(a0)					// v1 = item struct
    addiu   at, r0, SHATTER_FGM				// at = hb FGM
    sh      at, 0x156(v1)           		// overwrite hb fgm with shatter for later
    lw      v0, 0x0074(a0)     				// v0 = position struct
    lw      v0, 0x0080(v0)     				// v0 = image struct
    lli     at, 0x0001         				// at = image index 2
	lh      v1, 0x0080(v0)          		// v0 = current image index
	bne		at, v1, _continue	   			// don't destroy if not already cracked
    sh      at, 0x0080(v0)     				// set gem image to cracked

	_destroy_gem:
	jal		destroy_gem_					// do gfx and sfx
	nop
	b 		_end
    addiu   v0, r0, 0x0001					// mark for destruction
	
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
scope collide_with_player_: {
    addiu   sp, sp, -0x20            // allocate stackspace
    sw      ra, 0x0014(sp)           // save return address
	sw		a0, 0x0018(sp)			 // save item object
    lw      v1, 0x0084(a0)
    or      a1, a0, r0
    addiu   t9, r0, 0x0001           // t9 = 1
    lbu     t6, 0x0355(v1)           // load shells "hp" value
    addiu   a0, r0, 0x0004
    addiu   t7, t6, 0xffff
    andi    t8, t7, 0x00ff

    _gem:
    sw      a1, 0x0020(sp)		// store a1
	// see if gem is supposed to be destroyed first
    addiu   at, r0, SHATTER_FGM		// at = hb FGM
    sh      at, 0x156(v1)           // overwrite hb fgm with shatter for later
    lw      a0, 0x0018(sp)
    lw      a1, 0x0074(a0)     		// a1 = position struct
    lw      a1, 0x0080(a1)     		// a1 = image struct
    lli     at, 0x0001         		// at = image index 2
	lh      v0, 0x0080(a1)          // v0 = current image index
    sh      at, 0x0080(a1)     		// set gem to cracked
	bne		at, v0, _continue	   	// don't destroy if not already cracked
    nop

	_destroy_gem:
	jal		destroy_gem_			// do gfx and sfx
	nop
	b 		_end
    addiu   v0, r0, 0x0001			// mark for destruction

	_continue:
    addiu   t3, r0, 0x0000          // restore t3
    addiu   t9, r0, 0x0001          // restore t9
    sw      t9, 0x0248(v1)
	lw      a1, 0x0020(sp)			// restore a1

    //jal     0x80018994            // unknown
    sw      v1, 0x001c(sp)
    lw      v1, 0x001c(sp)
    lui     at, 0x3f80              // on hit speed multiplier(default = bf80)
    mtc1    at, f6
    lw      t0, 0x0268(v1)
    lwc1    f4, 0x002c(v1)
    lui     at, 0xc100
    mtc1    t0, f16
    mul.s   f8, f4, f6
    mtc1    at, f10
    lw      a0, 0x0020(sp)
    lui     at, 0x8019
    sb      v0, 0x0352(v1)
    cvt.s.w f18, f16
    lwc1    f16, 0xcda8(at)
    mul.s   f4, f10, f18
    add.s   f6, f8, f4
    mul.s   f10, f6, f16
    jal     0x8017a734              // unknown

    swc1    f10, 0x002c(v1)
    lw      v1, 0x001c(sp)
    lw      a1, 0x0020(sp)
    lw      t1, 0x0108(v1)
    jal     set_idle_aerial_        // change state back to idle and adds bounce back
    or      a0, a1, r0
    b       _end                    // branch to end
    or      v0, r0, r0


    or      v0, r0, r0

    _end:
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x20
    jr      ra
    nop
}




// @ Description
// based on green shells bounce back routine @ 80178C6C
// if blue shell is thrown at a player, it re-enters idle state similar to green shell
scope set_idle_aerial_: {
    addiu   sp, sp, -0x20
    sw      ra, 0x0014 (sp)
    sw      a0, 0x0020 (sp)
    lw      v1, 0x0084 (a0)
    addiu   t7, r0, 0x0001
    addiu   a0, r0, 0x0004
    sw      t7, 0x0248 (v1)
    jal     0x80018994
    sw      v1, 0x001c (sp)
    lw      v1, 0x001c (sp)
    lui     at, 0x4218
    mtc1    at, f4
    sb      v0, 0x0352 (v1)
    jal     0x80018948            // common routine that items use
    swc1    f4, 0x0030 (v1)
    lw      v1, 0x001c (sp)
    lui     at, 0x3e00
    mtc1    at, f10
    lwc1    f6, 0x002c (v1)
    neg.s   f8, f6
    mul.s   f16, f8, f10
    nop
    mul.s   f18, f0, f16
    swc1    f18, 0x002c (v1)
    jal     0x8017279c             // unknown
    lw      a0, 0x0020 (sp)
    jal     0x80178704             // unknown
    lw      a0, 0x0020 (sp)
    jal     set_idle_aerial_2      // changes state. Based on 0x80178930
    lw      a0, 0x0020 (sp)
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x20
    or      v0, r0, r0
    jr      ra
    nop
}
// @ Description
// Changes state to idle after hitting a player. based on 0x80178930
scope set_idle_aerial_2: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    lw      a0, 0x0084(a0)
    lbu     t7, 0x02ce(a0)
    sw      r0, 0x0248(a0)
    sw      r0, 0x010c(a0)
    andi    t8, t7, 0xff7f			// writes a flag that might make the gem die when it hits the ground
    jal     0x80173f78             // common subroutine changes kinetic state flag to aerial
    sb      t8, 0x02ce(a0)		// write that flag
	//sb      r0, 0x02CE(a0)			// saving flag as 0 to prevent gem from randomly dying

    lw      a1, 0x0018(sp)     // a1 = item object
    lw      a1, 0x0074(a1)     // a1 = position struct
    lw      a1, 0x0080(a1)     // a1 = image struct
    lli     at, 0x0001         // at = image index 2
    sh      at, 0x0080(a1)     // set gem to cracked

    li      a1, item_state_table        // a1 = item info array offset
    lw      a0, 0x0018(sp)
    jal     0x80172ec8             // change item state
    addiu   a2, r0, 0x0001         // state = 1
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
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
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// based on bobbomb throw routine @ 0x80177590
scope throw_initial_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     0x80177208
    sw      a0, 0x0018 (sp)
    li      a1, item_state_table
    lw      a0, 0x0018 (sp)
    jal     0x80172ec8              // change item state
    addiu   a2, r0, 0x0003          // state = 3(thrown)
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// based on bombs 0x8017756C
scope throw_duration_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    li      a1, collide_transition   // runs this routine if bomb collides with clipping
    jal     0x80173e58
    nop
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// based on bobombs 0x80177B78
scope collide_transition: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    sw      a0, 0x0018 (sp)

    lw      a1, 0x0074(s0)     // a1 = position struct
    lw      a1, 0x0080(a1)     // a1 = image struct
    lli     at, 0x0001         // at = image index 2
    sh      at, 0x0080(a1)     // set gem to cracked

    li      a1, item_state_table
    lw      a0, 0x0018 (sp)
    jal     0x80172ec8         // change item state
    addiu   a2, r0, 0x0004     // state = 4 (collide with clipping)
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop

}

// @ Description
// based on bobombs @ 0x80177B10
scope collide_with_clipping_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
	lw		a2, 0x0084(a0)
    sw      a2, 0x0010(sp)

    jal     0x80177180           	// gfx?
    or      a1, r0, r0

    lw      a2, 0x0010(sp)

	_gem:
    lw      a0, 0x0018(sp)			// a0 = item object
	jal		destroy_gem_			// do gfx and sfx
	nop
	b		_end_2					// destroy gem
	addiu	v0, r0, 0x0001			// ~

	_end:
    or      v0, r0, r0
	_end_2:
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}


// @ Description
// shatter FGM and hopefully gfx here
scope destroy_gem_: {
	addiu   sp, sp, -0x20
    sw      ra, 0x0014(sp)
    lw      v0, 0x0084(a0)

	jal		shatter_gfx_
	nop

	jal     0x800269C0			// play sound
    addiu   a0, r0, SHATTER_FGM	// shield break fgm
	lw      ra, 0x0014(sp)		// restore ra
	jr      ra
    addiu   sp, sp, 0x20
}

// @ Description
// copied blue shells gfx for now
scope shatter_gfx_: {
    addiu    sp, sp, -0x30              // allocate sp
    sw       ra, 0x0014(sp)             // store registers
    lw       a3, 0x0074(a0)
	lw       v0, 0x0084(a0)				// v0 = item struct

    lw    	t7, 0x001c(a3)
    addiu 	a0, sp, 0x001c
    lui   	a2, 0x4f80
    sw    	t7, 0x0000(a0)
    lw    	t6, 0x0020(a3)
    sw    	t6, 0x0004(a0)
    lw    	t7, 0x0024(a3)
    sw    	t7, 0x0008(a0)
    lw    	t8, 0x02D4(v0)
    lwc1  	f4, 0x0020(sp)
    lh    	t9, 0x002e(t8)
    mtc1  	t9, f6
    nop
    cvt.s.w f8, f6
    add.s   f10, f4, f8
    swc1    f10, 0x0020(sp)
    lw      a1, 0x0024(v0)
    jal     0x80101790                // big white spark gfx routine
    sw      v0, 0x002c(sp)
    lw      v0, 0x002c(sp)
    addiu   t0, r0, 0x0008
    andi    v1, t0, 0x00ff
    sb      t0, 0x0351(v0)

    _end:
    sb          t1, 0x0351(v0)
    lw          ra, 0x0014(sp)
    addiu       sp, sp, 0x30
    jr          ra
    nop
}

// @ Description
// Main item pickup routine for cloaking device.
scope pickup_gem: {
    // a0 = player struct
    // a2 = item object
    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}