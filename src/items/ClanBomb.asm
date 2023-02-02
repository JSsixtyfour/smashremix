// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(clanbomb_stage_setting_) // bomb is 0x80177D9C
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_)
constant PICKUP_ITEM_INIT(prepickup_) // prepickup
constant DROP_ITEM(0x801745FC) // same as Maxim Tomato
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0x130)

// @ Description
// Pull values from this table when spawning clanpot
item_table:
// CLAN BOMB
dh 0x4080                       		// palette index (3)
dh 1                            		// base damage
dh 80                          		    // base knockback
dh 70                          		    // kbg

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
dw 0x801744FC                           // 0x04 - collision (using Maxim Tomato)
dw 0                                    // 0x08
dw 0                                    // 0x0C
dw 0, 0, 0, 0                           // 0x10 - 0x1C

// STATE 1 - PREPICKUP - AERIAL
dw 0x801744C0                           // 0x20 - main
dw 0x80174524                           // 0x24 - collision
dw 0, 0                                 // 0x28 - 0x2C
dw 0, 0, 0                              // 0x30 - 0x38
dw collide_with_player_                 // 0x3C

// STATE 2 - PICKUP
dw hold_clanbomb_						// 0x30 - main
dw 0, 0, 0                           	// 0x34 - 0x3C
dw 0, 0, 0, 0                           // 0x40 - 0x4C

// STATE 3 - thrown
dw 0x80177530                       	// 0x50 - main
dw throw_duration_                      // 0x54 - collision
dw collide_with_player_                 // 0x58
dw collide_with_player_                 // 0x5C
dw 0x801733E4                           // 0x60
dw collide_with_player_                 // 0x64
dw 0x80173434                           // 0x68
dw collide_with_player_                 // 0x6C

// STATE 4 - explode transition
dw collide_with_clipping_
dw 0, 0, 0
dw 0, 0, 0 ,0

// STATE 5 - exploding
dw explode_, 0, 0, 0
dw 0, 0, 0, 0

// @ Description
// spawns the gem, based on bob-ombs spawn routine @0x80177D9C
scope clanbomb_stage_setting_: {
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
    sw      a3, 0x0044(sp)				// save item object to sp
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

    // GET ITEM VALUES
	lw      t7, 0x001C(sp)              // get player object
	lw      t7, 0x0084(t7)              // get player struct
    li      t1, item_table              // t1 = item table

    // SET BASE DAMAGE
    lh      at, 0x0002(t1)              // at = base damage
    sw      at, 0x0110(s0)              // overwrite base damage
    lh      at, 0x0004(t1)              // at = base knockback
    sw      at, 0x0148(s0)              // overwrite bkb
    lh      at, 0x0006(t1)              // at = knockback growth
    sw      at, 0x0140(s0)              // overwrite

    // SET PALETTE OFFSET
    lw      t2, 0x0004(s0)              // t2 = item object
    lw      t2, 0x0074(t2)              // t2 = joint/position struct
    lw      t2, 0x0080(t2)              // t2 = image struct?
    lhu     at, 0x0000(t1)              // at = palette index (float)
    sll     at, at, 16
    sw      at, 0x0088(t2)              // overwrite palette index (float)

	// clanbomb image set
    lli     at, 0x0002         			// at = clanbomb image index
    sh      at, 0x0080(t2)     			// set image to clanbomb

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

scope hold_clanbomb_: {
    addiu   sp, sp, -0x20            // allocate stackspace
    sw      ra, 0x0014(sp)           // save return address
	sw		a0, 0x0018(sp)			 // save item object

	jal		animate_clanbomb_
	nop

    _end:
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x20
    jr      ra
	addiu	v0, r0, 0x0000			// don't destroy

}

// @ Description
// based on red shell collision routine @ 0x8017AE48
scope collide_with_player_: {
    addiu   sp, sp, -0x20            // allocate stackspace
    sw      ra, 0x0014(sp)           // save return address
	sw		a0, 0x0018(sp)			 // save item object
    or      a1, a0, r0

	_explode:
    lw      a0, 0x0018(sp)
    jal     explode_transition_  	// transition
    addiu   a1, r0, 0x0001
	b		_end
    or      v0, r0, r0

    _end:
    lw      ra, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x20
}

// @ Description
// based on bobbomb prepickup @ 0x801774FC
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
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// based on bobbomb throw routine @ 0x80177590
scope throw_initial_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     0x80177208				// enables hurtbox
    sw      a0, 0x0018 (sp)
    li      a1, item_state_table
    lw      a0, 0x0018 (sp)
    jal     0x80172ec8              // change item state
    addiu   a2, r0, 0x0003          // state = 3(thrown)
    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// based on bombs 0x8017756C
scope throw_duration_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
	sw		a0, 0x0018(sp)			// store a0
    li      a1, collide_transition  // runs this routine if bomb collides with clipping
    jal     0x80173e58
    nop
	jal		animate_clanbomb_
	lw		a0, 0x0018(sp)			// load a0

    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    lli		v0, 0
}

// @ Description
// based on bobombs 0x80177B78
scope collide_transition: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     0x80177208
    sw      a0, 0x0018 (sp)
    li      a1, item_state_table
    lw      a0, 0x0018 (sp)
    jal     0x80172ec8         // change item state
    addiu   a2, r0, 0x0004     // state = 4 (collide with clipping)
    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x18

}

// @ Description
// based on bobombs 0x8017741C
scope explode_transition_player_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     explode_transition_
    addiu   a1, r0, 0x0001
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    or      v0, r0, r0
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
    FGM.play(0x0001)            	// play fgm
    lw      a2, 0x0010(sp)
    lw      a0, 0x0018(sp)
    jal     explode_transition_  	// transition
    addiu   a1, r0, 0x0001
	_end:
    or      v0, r0, r0
	_end_2:
    lw      ra, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// based on 801779E4 (bomb)
scope explode_transition_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a1, 0x001c (sp)

    mtc1    r0, f0
    lw      v0, 0x0084(a0)
    andi    a1, a1, 0x00ff
    swc1    f0, 0x0034(v0)
    swc1    f0, 0x0030(v0)
    jal     check_explode            // set explode state
    swc1    f0, 0x002c(v0)

    lw      ra, 0x0014 (sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// based on bomb routine @ 0x80177060
scope check_explode: {
    addiu   sp, sp, -0x30
    sw      ra, 0x001c (sp)
    sw      s0, 0x0018 (sp)
    sw      a1, 0x0034 (sp)

    lw      t6, 0x0074 (a0)
    or      s0, a0, r0
    sw      t6, 0x0028 (sp)
    lw      t7, 0x0084 (a0)
    jal     0x80177218
    sw      t7, 0x0024 (sp)
    lw      a0, 0x0028 (sp)
    jal     0x801005c8
    addiu   a0, a0, 0x001c
    beqz    v0, _branch
    lui     at, 0x8019
    lwc1    f0, 0xcd30 (at)
    lw      t8, 0x005c (v0)
    swc1    f0, 0x001c (t8)
    lw      t9, 0x005c (v0)
    swc1    f0, 0x0020 (t9)
    lw      t0, 0x005c (v0)
    swc1    f0, 0x0024 (t0)
    _branch:
    jal     0x801008f4
    addiu   a0, r0, 0x0001
    lw      t2, 0x0074 (s0)
    addiu   t1, r0, 0x0002
    addiu   t3, r0, 0x0001
    sb      t1, 0x0054(t2)
    lw      t4, 0x0024(sp)
    or      a0, s0, r0
    jal     0x8017275c
    sh      t3, 0x0156(t4)
    jal     0x8017279c
    or      a0, s0, r0
    jal     explode_initial_         // subroutine sets item state explode
    or      a0, s0, r0

    lw      ra, 0x001C(sp)
    lw      s0, 0x0018(sp)
    jr      ra
    addiu   sp, sp, 0x30
}

// @ Description
// based on bob bombs explode routine @ 0x80177C30
scope explode_initial_: {
	addiu   sp, sp, -0x18
	sw      ra, 0x0014(sp)
	jal     0x80177bac
	sw      a0, 0x0018(sp)
	li      a1, item_state_table
	lw      a0, 0x0018(sp)
	jal     0x80172ec8          // change item state
	addiu   a2, r0, 0x0005      // state = 5 (explode)
	lw      ra, 0x0014(sp)
	jr      ra
	addiu   sp, sp, 0x18
}

// @ Description
// based on bobombs @ 0x80177BE8
scope explode_: {
    addiu   sp, sp, -0x20
    sw      ra, 0x0014 (sp)
    lw      v0, 0x0084 (a0)
    jal     0x80177a24
    sw      v0, 0x001c (sp)
    lw      v0, 0x001c (sp)
    addiu   at, r0, 0x0006      // timer?
    lhu     t6, 0x033e (v0)
    addiu   t7, t6, 0x0001
    andi    t8, t7, 0xffff
    sh      t7, 0x033e (v0)
    bne     t8, at, _keep_alive
    lw      ra, 0x0014 (sp)

    // if here, destroy
    b       _end
    addiu   v0, r0, 0x0001

    _keep_alive:
    or      v0, r0, r0

    _end:
    jr      ra
    addiu   sp, sp, 0x20

}


// @ Description
// Main item pickup routine for cloaking device.
scope pickup_: {
    // a0 = player struct
    // a2 = item object
    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}

// a0 should be item object
scope animate_clanbomb_: {
	addiu   sp, sp, -0x20
    sw      ra, 0x0014(sp)

    lw      v1, 0x0074(a0)    			// v1 = position struct
	lw      at, 0x0080(v1)              // v1 = image struct
	bnezl	at, _continue
	or		v1, at, r0
	lw		v1, 0x0010(v1)
	beqz	v1, _end					// failsafe in case no ptr here
	nop
	lw		v1, 0x0080(v1)

	_continue:
	lb		v0, 0x000E(a0)				// get async timer
	andi	v0, v0, 0x000F
	bnez	v0, _end

    // Sets palette offset, there is probably a better way.
	lh      v0, 0x0088(v1)              // get current palette index
	lli		at, 0x4040
	bne		v0, at, _overwrite
	nop
	lb		v0, 0x000E(a0)				// get async timer
	andi	v0, v0, 0x0020
	bnez	v0, _overwrite
	lli     at, 0x4080
	lli     at, 0x4000

	_overwrite:
    sh      at, 0x0088(v1)              // overwrite palette index

	_end:
    lw      ra, 0x0014(sp)
	jr		ra
	addiu   sp, sp, 0x20

}