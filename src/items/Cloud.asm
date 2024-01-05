// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0)

constant DESPAWN_FGM(FGM.CLOUD_FADE) // was 0x501

constant ITEM_INFO_ARRAY_ORIGIN(origin())
item_info_array:
dw 0                                    // 0x00 - item ID
dw Character.GOEMON_file_7_ptr          // 0x04 - address of file pointer
dw 0x00000040                           // 0x08 - offset to item footer
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?

item_state_table:
// state 0 - null state
dw cloud_null_main_                     // 0x14 - state 0 main
dw 0                                    // 0x18 - state 0 collision
dw 0                                    // 0x1C - state 0 hitbox collision w/ hurtbox
dw 0                                    // 0x20 - state 0 hitbox collision w/ shield
dw 0                                    // 0x24 - state 0 hitbox collision w/ shield edge
dw 0                                    // 0x28 - state 0 unknown (maybe absorb)
dw 0                                    // 0x2C - state 0 hitbox collision w/ reflector
dw 0                                    // 0x30 - state 0 hurtbox collision w/ hitbox

// state 1 - GOEMON JUMPED
dw cloud_aerial_main_                   // 0x14 - state 0 main
dw 0                                    // 0x18 - state 0 collision
dw 0                                    // 0x1C - state 0 hitbox collision w/ hurtbox
dw 0                                    // 0x20 - state 0 hitbox collision w/ shield
dw 0                                    // 0x24 - state 0 hitbox collision w/ shield edge
dw 0                                    // 0x28 - state 0 unknown (maybe absorb)
dw 0                                    // 0x2C - state 0 hitbox collision w/ reflector
dw 0                                    // 0x30 - state 0 hurtbox collision w/ hitbox
OS.align(16)

// CONSTANTS BECAUSE GOEMON STOPPED USING IT
constant TOTAL_TIMER(30)                // # frames until aerial death
constant TIME_UNTIL_FADE(8)             // # frames until fade begins

// @ Description
// Set up routine for Cloud.
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


    // item is created
    lw      v1, 0x0084(v0)                  // v1 = item special struct
    sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
    lw      a0, 0x0074(v0)                  // a0 = item first joint (joint 0)
    sw      a0, 0x0030(sp)                  // 0x0030(sp) = item joint 0

    lw      t0, 0x0080(a0)                  // get image footer struct

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
    sb      t5, 0x0014(v1)                  // save player's team to item to prevent damage when team attack is off
    lbu     t5, 0x0012(t6)                  // load offset to attack hitbox type in 5x
    sb      t5, 0x0012(v1)                  // unknown
    sw      a0, 0x01C4(v1)                  // save player object to custom variable space in the item special struct

    sw      r0, 0x0248(v1)                  // disable hurtbox
    sw      r0, 0x010C(v1)                  // disable hitbox

    sw      r0, 0x01CC(v1)                  // rotation direction = 0
    sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
    sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
    li      t1, cloud_blast_zone_           // load cloud blast zone routine
    sw      t1, 0x0398(v1)                  // save routine to part of item special struct that carries unique blast wall destruction routines

    // set direction
    lw      t1, 0x0038(sp)                  // a0 = player object
    lw      t1, 0x0084(t1)                  // t1 = player struct
    lw      t1, 0x0044(t1)                  // t1 = player direction
    lli     a1, 0x0001

    _end:
    or      v0, s0, r0                      // v0 = item object
    lw      s0, 0x0020(sp)                  // ~
    lw      s1, 0x0024(sp)                  // ~
    lw      ra, 0x0028(sp)                  // load s0, s1, ra
    jr      ra                              // return
    addiu   sp, sp, 0x0060                  // deallocate stack space
}

// @ Description
// Main routine while Goemon stands on top of it
scope cloud_null_main_: {
    addiu   sp, sp, -0x0040                 // allocate stack space
    sw      ra, 0x001C(sp)                  // store ra
    sw      a0, 0x0014(sp)                  // store item

    lw      v1, 0x0084(a0)                  // v1 = item struct
    sw      v1, 0x0018(sp)                  // save to stack
    
    lw      t0, 0x0008(v1)                  // t0 = player obj
    lw      t0, 0x0084(t0)                  // t0 = player struct
    lw      t1, 0x0024(t0)                  // t1 = current action
    addiu   at, r0, Goemon.Action.USP        
    beq     t1, at, _pin_to_feet
    addiu   at, r0, Goemon.Action.USPAttack
    beq     t1, at, _pin_to_feet
    nop

    // detach the cloud and destroy soon
    _detach_cloud:
    addiu   at, r0, Goemon.Action.USPJump
    beql    t1, at, _detach_cloud_continue
    addiu   at, r0, TOTAL_TIMER             // destroy cloud if jumping or escaping cloud
    addiu   at, r0, Goemon.Action.USPEscape
    beql    t1, at, _detach_cloud_continue  // ~
    addiu   at, r0, TOTAL_TIMER             // default death timer
    // addiu   at, r0, Action.FallSpecial
    // bnel    t1, at, _detach_cloud_continue  //
    // addiu   at, r0, TOTAL_TIMER             // default death timer
    
    lw      v1, 0x0018(sp)                  // load from stack
    lw      t0, 0x0008(v1)                  // t0 = player obj
    lw      t0, 0x0084(t0)                  // t0 = player struct
    addiu   at, r0, 1                       // default death timer

    _detach_cloud_continue:
    sh      at, 0x033E(v1)                  // write timer
    li      a1, item_state_table            // 
    lw      a0, 0x0018(sp)                  // a0 = item struct
    lw      v0, 0x0008(a0)                  // v0 = goemon player object
    lw      v0, 0x0084(v0)
    lwc1    f8, 0x008C(v0)                  // f8 = player aerial x speed
    lwc1    f4, 0x0090(v0)                  // f4 = player aerial y speed
    lui     at, 0x3F00
    mtc1    at, f6                          // f6 = 0.5
    mul.s   f4, f6, f4                      // f4 = player aerial y speed / 2
    nop
    mul.s   f8, f6, f8                      // f8 = player aerial x speed / 2
    swc1    f4, 0x0030(v1)                  // save aerial y speed / 2
    swc1    f8, 0x002C(v1)                  // save aerial x speed / 2

    lw      a0, 0x0004(a0)                  // 
    sw      r0, 0x007C(a0)                  // set visible
    jal     0x80172EC8                      // change to aerial state
    addiu   a2, r0, 0x0001                  //
    b       _end
    lli     v0, 0                           // don't destroy

    _pin_to_feet:
    // v1 = item struct
    lw      v0, 0x0074(a0)                  // item location ptr
    addiu   a1, v0, 0x001C                  // arg 1 = item location coords

    lw      at, 0x0084(a0)
    lw      t0, 0x02C0(at)                  // load timer
    sll     t0, t0, 30
    bnez    t0, _continue
    lw      v0, 0x0074(a0)                  // v1 = position struct
    
    _continue:
    lw      v0, 0x0008(v1)                  // sets coords to world coords of players top joint
    lw      v0, 0x0084(v0)                  // ~
    lw      a0, 0x08E8(v0)                  // ~
    sw      r0, 0x0000(a1)                  // ~
    sw      r0, 0x0004(a1)                  // ~
    jal     0x800EDF24                      // ~
    sw      r0, 0x0008(a1)                  // ~

    lw      a0, 0x0074(s0)                  // load position struct
    sw      r0, 0x0038(a0)                  // set z rotation to 0
    lw      a0, 0x0014(sp)                  // load item
    lw      v1, 0x0084(a0)                  // v1 = item struct
    sw      r0, 0x01CC(v1)                  // rotation direction = 0
    
    _flash:
    lw      v0, 0x0018(sp)                  // v0 = item struct
    lw      v1, 0x0008(v0)                  // v1 = player struct
    lw      v1, 0x0084(v1)                  // ~
    
    lw      t6, 0x0B18(v1)                  // t6 = frame timer
    slti    t5, t6, 70
    bnezl   t5, _end
    lli     v0, 0                           // don't destroy
    andi    t6, t6, 0x0002
    lw      t5, 0x0004(v0)                  // t5 = item obj
    srl     at, t6, 1
    sw      at, 0x007C(t5)                  // save draw flag to make it flash

    b       _end
    lli     v0, 0                           // don't destroy

    _end_destroy:
    b       _end_2
    addiu   v0, r0, 0x0001                  // destroy item = TRUE

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


// @ Description
// The Cloud's main routine since Goemon abandoned it
scope cloud_aerial_main_: {
    addiu   sp, sp, -0x0040                 // allocate stack space
    sw      ra, 0x001C(sp)                  // store ra
    sw      a0, 0x0014(sp)                  // store item

    lw      v1, 0x0084(a0)                  // v1 = item struct
    sw      v1, 0x0018(sp)                  // save to stack

    lh      t0, 0x033E(v1)                  // t0 = current timer
    addiu   t0, t0, -1                      // t0 -= 1
    sh      t0, 0x033E(v1)                  // write timer value
    beqz    t0, _end_destroy

    slti    t6, t0, TOTAL_TIMER - TIME_UNTIL_FADE
    beqz    t6, _end
    lli     v0, 0                           // don't destroy
    // flash if here
    andi    t6, t0, 0x0002   
    lw      t5, 0x0004(v1)                  // t5 = item obj
    srl     at, t6, 1
    sw      at, 0x007C(t5)                  // save draw flag to make it flash

    b       _end
    lli     v0, 0                           // don't destroy

    _end_destroy:
    FGM.play(DESPAWN_FGM)                   // play cloud fading out fgm
    b       _end_2
    addiu   v0, r0, 0x0001                  // destroy item = TRUE

    _end:
    lw      v1, 0x0018(sp)                  // load to stack
    lw      t1, 0x02C0(v1)                  // load timer
    addiu   t1, t1, 0x0001                  // add to timer
    sw      t1, 0x02C0(v1)                  // save new time
    // jal     0x80177530                      // apply aerial movement
    // lw      a0, 0x0014(sp)                  // load cloud
    // lli     v0, 0                           // don't destroy
    _end_2:
    lw      ra, 0x001C(sp)                  // load ra
    jr      ra                              // return
    addiu   sp, sp, 0x0040                  // deallocate stack space

}

// @ Description
// is this even needed?
scope cloud_blast_zone_: {
    jr      ra
    nop
}

// @ Description
scope enable_flash: {
    OS.patch_start(0xE9FF4, 0x8016F5B4)
    j       enable_flash
    lw      t9, 0x0C(a2)        // t9 = item id
    _return:
    OS.patch_end()
    
    addiu   at, r0, Item.Cloud.id
    beq     at, t9, _cloud
    addiu   at, r0, 0x011A      // bowser bomb item id
    beq     at, t9, _cloud
    nop
    
    _normal:
    bgezl   t8, _0x8016F64C     // og line 1 modified 
    sw      r0, 0x007C(s0)      // og line 2
    j       _return             // return to original logic
    nop
    
    _cloud:
    bgezl   t8, _0x8016F64C     // og line 1 modified 
    nop
    j       _return             // return to original logic
    nop

    _0x8016F64C:
    j   0x8016F64C
    nop
}