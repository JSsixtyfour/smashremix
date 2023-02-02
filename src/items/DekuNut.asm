// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(spawn_deku_nut_) // bomb is 0x80177D9C
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_deku_nut)
constant PICKUP_ITEM_INIT(prepickup_) // prepickup
constant DROP_ITEM(drop_item_)        // same as Maxim Tomato, but removes damage type
constant THROW_ITEM(throw_initial_)
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xED0)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw 0x8018D040                           // 0x04 - hard-coded pointer to file 0xFB
dw FILE_OFFSET                          // 0x08 - offset to item footer in file 0xFB
dw 0x1B000000                           // 0x0C - (value - 1 * 4) + 0x8003DC24 = pointer to draw-related routine

dw 0                                    // 0x10 - hitbox enabler/offset (0 = none, appends to 0x10C)
dw 0x801744C0                           // 0x14 - spawn behaviour routine (tomato, appends to 0x378)
dw 0x80174524                           // 0x18 - ground transition routine  (appends to 0x37C)
dw 0                                    // 0x1C - hurtbox collision routine (appends to 0x380)

dw 0                                    // 0x20 - collide with shield (appends to 0x384)
dw 0                                    // 0x24 - collide with shield edge (appends to 0x388)
dw 0                                    // 0x28 - collide with hitbox ( appends to 0x38C)
dw 0                                    // 0x2C - collide with reflector (appends to 0x390)

item_state_table:
dw 0                                    // 0x00 - ?
dw 0x801744FC                           // 0x04 resting (using Maxim Tomato)
dw 0                                    // 0x08
dw 0                                    // 0x0C
dw 0, 0, 0, 0                           // 0x10 - 0x1C

// STATE 1 - PREPICKUP - AERIAL
dw 0x801744C0                           // 0x20 (using Maxim Tomato)
dw 0x80174524                           // 0x24 (using Maxim Tomato)
dw 0, 0                                 // 0x28 - 0x2C
dw 0, 0, 0                              // 0x30 - 0x38
dw collide_transition_player_           // 0x3C

// STATE 2 - PICKUP
dw 0, 0, 0, 0                           // 0x40 - 0x4C
dw 0, 0, 0, 0                           // 0x50 - 0x5C

// STATE 3 - thrown
dw throw_physics_                       // 0x60 - gravity routine
dw throw_duration_                      // 0x64 - collision with clipping (bomb is 0x8017756C)
dw collide_transition_player_           // 0x68
dw collide_transition_player_           // 0x6C
dw 0x801733E4                           // 0x70
dw collide_transition_player_           // 0x74
dw 0x80173434                           // 0x78
dw collide_transition_player_           // 0x7C

// STATE 4 - UNUSED
dw 0, 0, 0, 0, 0, 0, 0, 0               // 0x80 - 0x9C

// STATE 5 - UNUSED
dw 0, 0, 0, 0, 0, 0, 0, 0               // 0xA0 - 0xBC

// STATE 6 - COLLIDE WITH GROUND
dw collide_with_wall_
dw 0
dw collide_with_wall_
dw collide_with_wall_
dw 0
dw 0
dw collide_with_wall_
dw collide_with_wall_                            // 0xC0 - 0xDC

// STATE 7 - FLASH
dw nut_active_, 0, 0, 0, 0, 0, 0, 0              // 0xE0 - 0xFC

// @ Description
// spawns the deku nut, based on bob-ombs spawn routine @0x80177D9C
scope spawn_deku_nut_: {
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
    jal     explode_subroutine_
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

    addiu   v0, r0, 0x0408    // v0 = hurtbox FGM
    sh      v0, 0x156(s0)     // save fgm value

    addiu   v0, r0, 0x100     // v0 = hurtbox bkb?
    sh      v0, 0x140(s0)     // save

    _end:
    lw     ra, 0x0024 (sp)
    lw     s0, 0x0020 (sp)
    addiu  sp, sp, 0x48
    jr     ra
    or     v0, a3, r0

}

// @ Description
// based on bobbomb prepickup @ 0x801774FC
scope prepickup_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     0x80177218                  // subroutine disables hitbox
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
// Custom item drop routine with vanilla logic too
scope drop_item_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      v0, 0x0010(sp)

    sw      r0, 0x011C(v0)              // damage type = normal

    jal       0x801745FC                // item drop subroutine for tomato
    nop
    lw      v0, 0x0010(sp)

    sw      r0, 0x140(v0)               // set kb to 0

    lw      ra, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x18
}

// @ Description
// based on bobbomb throw routine @ 0x80177590
scope throw_initial_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    // v0 = item struct
    jal     0x80177208
    sw      a0, 0x0018 (sp)
    addiu   at, r0, 0x000A           // at = deku stun damage type
    sw      at, 0x011C(v0)          // overwrite damage type
    addiu   at, r0, 0x100           // at = hurtbox kb
    sh      at, 0x140(v0)           // overwrite kb
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
// Based on bobombs thrown routine @ 0x80177530
scope throw_physics_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    sw      a0, 0x0018 (sp)
    lui     a1, 0x3fE0             // gravity multiplier, original was 0x3f99
    lw      a0, 0x0084 (a0)        // a0 = item special struct
    ori     a1, a1, 0x999a
    jal     0x80172558             // calcuate gravity
    lui     a2, 0x42c8
    jal     0x801713f4             // apply movement
    lw      a0, 0x0018 (sp)
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    or      v0, r0, r0
    jr      ra
    nop

}

// @ Description
// based on bombs 0x8017756C
scope throw_duration_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    li      a1, collide_transition // runs this routine if bomb collides with clipping
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
    jal     0x80177208
    sw      a0, 0x0018 (sp)
    li      a1, item_state_table
    lw      a0, 0x0018 (sp)
    jal     0x80172ec8         // change item state
    addiu   a2, r0, 0x0006     // state = 6 (collide with clipping)
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop

}

// @ Description
// based on bobombs 0x8017741C
scope collide_transition_player_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    jal     explode_transition_
    addiu   a1, r0, 0x0001
    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    or      v0, r0, r0
    jr      ra
    nop
}

// @ Description
// based on bobombs @ 0x80177B10
scope collide_with_wall_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    sw      a0, 0x0018(sp)
    jal     0x80177180           // gfx?
    or      a1, r0, r0
    lw      a0, 0x0018(sp)
    jal     explode_transition_  // transition
    addiu   a1, r0, 0x0001
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    or      v0, r0, r0
    jr      ra
    nop
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
    jal     explode_nut_        // set explode state
    swc1    f0, 0x002c(v0)
    jal     0x800269c0          // play fgm
    addiu   a0, r0, 0x0407      // fgm_id = deku nut

    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// based on bombs 0x8017279C
// this routine originally would clear item owner and thus allow hitting the throwing player, removed
scope explode_subroutine_: {
    lw      v0, 0x0084(a0)
    addiu   t9, r0, 0x0004
    lbu     t7, 0x02CF(v0)
    sb      t9, 0x0014(v0)
    ori     t8, t7, 0x0080
    jr      ra
    sb      t8, 0x02Cf(v0)
}

// 80420018

// @ Description
// based on bomb routine @ 0x80177060
scope explode_nut_: {
    addiu   sp, sp, -0x30
    sw      ra, 0x001c (sp)
    sw      s0, 0x0018 (sp)
    sw      a1, 0x0034 (sp)

    lw      t6, 0x0074 (a0)
    or      s0, a0, r0
    sw      t6, 0x0028 (sp)
    lw      t7, 0x0084 (a0)
    jal     0x80177218             // disable hitbox
    sw      t7, 0x0024 (sp)

    // we will create a screen flash instead of an explosion effect.
    li      at, flash_array_       // at = hard-coded pointer to blend colour command
    li      a0, 0x80131A40         // a0 = hard-coded address to write blend colour commands to screen
    sw      at, 0x0000(a0)         // save the pointer to the address.

    // continue
    lw      a0, 0x0028 (sp)
    jal     0x801008f4             // do screen shake
    addiu   a0, r0, 0x0001
    lw      t2, 0x0074 (s0)
    addiu   t1, r0, 0x0002
    addiu   t3, r0, 0x0408         // set hurtbox sound to deku_nut
    sb      t1, 0x0054(t2)
    lw      t4, 0x0024(sp)
    or      a0, s0, r0
    //jal     0x8017275c             // this subroutine enables the hitbox
    sh      t3, 0x0156(t4)
    jal     explode_subroutine_
    or      a0, s0, r0
    jal     explode_initial_       // subroutine sets item state to 7 explode
    or      a0, s0, r0

    lw      ra, 0x001C(sp)
    lw      s0, 0x0018(sp)
    addiu   sp, sp, 0x30
    jr      ra
    nop
}

// @ Description
// based on damage colour command @ 0x8012DB70
flash_array_:
dw 0x24000000     // 0x00 - ?
dw 0xDDDDDDCC     // 0x04 - initial colour (white)
dw 0x28000008     // 0x08 - determines length of colour transition (8 frames, second half word)
dw 0xFFFFFF00     // 0x0C - target colour (white, no alpha)
dw 0x04000008     // 0x10 - determines total length of flash (8 frames, second half word)
dw 0x00000000     // 0x14 - end of command

OS.align(16)

// @ Description
// based on bob bombs explode routine @ 0x80177C30
scope explode_initial_: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014(sp)
    jal     explode_initial_2   // original was 0x80177BAC
    sw      a0, 0x0018(sp)
    li      a1, item_state_table
    lw      a0, 0x0018(sp)
    jal     0x80172ec8          // change item state
    addiu   a2, r0, 0x0007      // state = 7 (flash explode)
    lw      ra, 0x0014(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// based on 0x80177BAC
scope explode_initial_2: {
    addiu   sp, sp, -0x18
    sw      ra, 0x0014 (sp)
    lw      v0, 0x0084 (a0)

    lui     at, 0x3f80
    mtc1    at, f4
    lbu     t6, 0x0340 (v0)
    sh      r0, 0x033e (v0)
    swc1    f4, 0x0114 (v0)
    andi    t7, t6, 0xff0f
    jal     set_nut_flash_         // original was 0x80177A24
    sb      t7, 0x0340 (v0)

    lw      ra, 0x0014 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop
}

// @ Description
// based on bobombs @ 0x80177BE8
scope nut_active_: {
    addiu   sp, sp, -0x20
    sw      ra, 0x0014 (sp)
    lw      v0, 0x0084 (a0)
    jal     set_nut_flash_          // original was 0x80177A24
    sw      v0, 0x001c (sp)

    lw      v0, 0x001c (sp)
    addiu   at, r0, 0x0006      // timer?
    lhu     t6, 0x033e (v0)
    addiu   t7, t6, 0x0001
    andi    t8, t7, 0xffff
    sh      t7, 0x033e (v0)
    bne     t8, at, _keep_alive
    lw      ra, 0x0014 (sp)

    // if here, destroy deku nut
    b       _end
    addiu   v0, r0, 0x0001

    _keep_alive:
    or      v0, r0, r0

    _end:
    jr      ra
    addiu   sp, sp, 0x20

}

// @ Description
// based on bobombs 0x80177a24
scope set_nut_flash_: {
    lw      v0, 0x0084(a0)          // v0 = item object

    lw      a1, 0x0340(v0)          // a1 = flag from item
    li      t8, hurtbox_struct_
    srl     a1, a1, 28
    sll     t9, a1, 3
    addu    a2, t8, t9              // a2 = address to hurtbox
    lbu     t1, 0x0000(a2)          // a2 = unknown hurtbox flag
    lhu     t0, 0x033e(v0)          // flag, used for explosion in bobomb
    addiu   t9, a1, 0x0001
    bne     t0, t1, _end
    nop
    lw      t2, 0x0000 (a2)
    lui     at, 0x4f80
    sll     t3, t2, 8
    sra     t4, t3, 22
    sw      t4, 0x013c (v0)
    lw      t5, 0x0000 (a2)
    sll     t6, t5, 18
    srl     t7, t6, 24
    sw      t7, 0x0110 (v0)
    lhu     t8, 0x0004 (a2)
    mtc1    t8, f4
    bgez    t8, _branch
    cvt.s.w f6, f4

    mtc1    at, f8
    nop
    add.s   f6, f6, f8

    _branch:
    lbu     t0, 0x0158 (v0)
    addiu   t8, r0, Damage.id.DEKU_STUN      // t8 = new damage type
    addiu   at, r0, 0x0004
    ori     t2, t0, 0x0040
    sb      t2, 0x0158 (v0)
    andi    t4, t2, 0x00f7
    lbu     t2, 0x0340 (v0)
    sll     t0, t9, 4
    sb      t4, 0x0158 (v0)
    andi    t6, t4, 0x00fb
    andi    t1, t0, 0x00f0
    andi    t3, t2, 0xff0f
    or      t4, t1, t3
    sb      t4, 0x0340(v0)
    lw      t5, 0x0340(v0)
    sb      t6, 0x0158(v0)
    andi    t7, t6, 0x007f
    srl     t6, t5, 28
    swc1    f6, 0x0138(v0)           // save new hurtbox size
    sb      t7, 0x0158(v0)
    bne     t6, at, _end
    sw      t8, 0x011c(v0)           // save damage type to item

    andi    t8, t4, 0x000f
    ori     t9, t8, 0x0030
    sb      t9, 0x0340 (v0)

    _end:
    jr      ra
    nop

}

// @ Description
// Similar to bob-omb, deku nut explodes then shrinks
hurtbox_struct_:
dw 0x00434040         // 0x00 - flash hb 1
dw 0x017E0000         // 0x04 - hb size 1

dw 0x02434040         // 0x08 - flash hb 2
dw 0x00FA0000         // 0x0C - hb size 2

dw 0x04434040         // 0x10 - flash hb 3
dw 0x00960000         // 0x14 - hb size 3

dw 0x06434040         // 0x18 - flash hb 4
dw 0x00000000         // 0x1C - hb size 4

// @ Description
// Main item pickup routine for cloaking device. doesn't seem to break the nut.
scope pickup_deku_nut: {
    // a0 = player struct
    // a2 = item object
    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}

