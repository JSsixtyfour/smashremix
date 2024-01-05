// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(spawn_custom_item_based_on_star_)
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant PLAYER_COLLISION(collide_mushroom_)
constant THROW_ITEM(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xD90)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw 0x8018D040                           // 0x04 - hard-coded pointer to file 0xFB
dw FILE_OFFSET                          // 0x08 - offset to item footer in file 0xFB
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?
dw movement_routine_no_bounce_          // 0x14 - movement routine
dw ground_collision_no_bounce_          // 0x18 - ground routine
dw 0x80174A0C                           // 0x1C - ? after effect? (using Star)
dw 0, 0, 0, 0                           // 0x20 - 0x2C - ?
dw 0                                    // 0x30 - ?
dw 0                                    // 0x34 - ?
dw 0                                    // 0x38 - ? resting state? (using Star)
dw 0                                    // 0x3C - ?

// @ Description
// References to registered routine objects for keeping track whether or not a player has a mushroom
player_shrooms:
dw 0, 0, 0, 0                           // references for p1 through p4

// @ Description
// Holds the number of mushrooms currently spawning this frame.
// Used so we can vary the spawn angles/directions for crates.
spawning_shrooms:
dw 0

// @ Description
// Spawns a custom item.
// Heavily based off of Star spawn code (80174A18).
scope spawn_custom_item_based_on_star_: {
    // We just need to update a1 to be the custom item's item info array and update spawn angle/speed.

    OS.copy_segment(0xEF458, 0x30)

    // Look up item info array address using item ID
    li      at, item_info_array_table
    lw      t7, 0x0074(sp)                  // t7 = item ID
    addiu   a1, t7, -0x002D                 // a1 = index in item_info_array_table
    sll     a1, a1, 0x0002                  // a1 = offset in item_info_array_table
    addu    at, at, a1                      // at = address of item info array pointer
    lw      a1, 0x0000(at)                  // a1 = item info array pointer

    // increment spawning_shrooms and modify x/y speed
    li      at, spawning_shrooms
    lw      t1, 0x0000(at)                  // t1 = current spawning shroom count
    addiu   t1, t1, 0x0001                  // t1++
    sw      t1, 0x0000(at)                  // update spawning shroom count
    lli     t8, 0x0010                      // t8 = absolute horizontal speed (16)
    sll     at, t1, 0x0001                  // at = t1 * 2
    addu    t8, t8, at                      // t8 = updated horizontal speed

    c.lt.s  f4, f6                          // original line 14
    addiu   a3, sp, 0x0034                  // original line 16
    mtc1    t8, f10                         // f10 = updated horizontal speed
    cvt.s.w f10, f10                        // f10 = updated horizontal speed, float
    bc1fl   _set_x                          // if should be moving left, need to negate, otherwise jump to setting x
    neg.s   f10, f10                        // f10 = updated horizontal speed (going left)

    _set_x:
    andi    t1, t1, 0x0001                  // t1 = 1 if current spawning shroom count is odd, 0 if even
    beqzl   t1, pc() + 8                    // if an even shroom count, send it the other direction
    neg.s   f10, f10                        // f10 = flipped horizontal speed
    swc1    f10, 0x0034(sp)                 // set x (original ine 24)

    abs.s   f16, f10                        // f16 = vertical speed = same as horizontal speed

    // next part was OS.copy_segment(0xEF4C8, 0x30)
    lw      t7, 0x005C(sp)
    swc1    f18, 0x003C(sp)
    swc1    f16, 0x0038(sp)
    jal     0x8016E174
    sw      t7, 0x0010(sp)
    beqz    v0, _end                        // branch if no item created
    or      v1, v0, r0
    lw      a0, 0x0074(v0)
    addiu   t8, sp, 0x0028
    addiu   t1, r0, 0x0001
    addiu   a3, a0, 0x001C
    lw      t0, 0x0000(a3)

    addiu   t2, r0, 0x0020                  // original line 39, modified to be an active item after 0x20 frames
    OS.copy_segment(0xEF4FC, 0x74)
    sw      r0, 0x0040(v1)                  // set custom variable to 0 for not grounded

    _end:
    lw      ra, 0x001C(sp)
    or      v0, v1, r0
    jr      ra
    addiu   sp, sp, 0x50
}

// @ Description
// Updates the mushroom's movement data to notiilj bounce when the ground is hit.
// Heavily based off of Star ground collision code.
scope ground_collision_no_bounce_: {
    OS.copy_segment(0xEF3D0, 0x4 * 4)

    // check if grounded, and if so run a different routine that detects ground to air transition
    lw      a1, 0x0040(a0)                  // a1 = 1 if grounded (custom variable)
    beqz    a1, _not_grounded               // if not grounded, skip to call that checks air to ground transition
    sw      t6, 0x0024(sp)                  // original line 7

    // This is borrowed from Green Shell when grounded
    li      a1, handle_ground_to_air_transition_ // a1 = some routine to run when transition occurs?
    jal     0x801735A0                      // ground collision detection routine?
    nop

    b       _continue                       // skip not grounded code
    nop

    _not_grounded:
    OS.copy_segment(0xEF3E0, 0x4 * 3)

    _continue:
    lw      a0, 0x0028(sp)                  // a0 = item object
    sw      v0, 0x0040(a0)                  // update custom variable with grounded/not grounded flag

    OS.copy_segment(0xEF3EC, 0x4 * 11)
    lui     at, 0x0000                      // original line 19, modified to not bounce
    OS.copy_segment(0xEF41C, 0x4 * 4)
    // The next two lines  would play a sound if uncommented and un NOP'd
    //addiu   a0, r0, FGM.hit.PUNCH_S         // original line 23, modified to different sound effect
    //OS.copy_segment(0xEF430, 0x4)
    nop
    nop
    OS.copy_segment(0xEF434, 0x4 * 7)
}

// @ Description
// Runs when mushroom transitions from ground to air.
// Does nothing!
scope handle_ground_to_air_transition_: {
    jr      ra
    nop
}

// @ Description
// Updates the mushroom's movement data to not apply gravity once it makes contact with the ground.
// Based on Star (80174930).
scope movement_routine_no_bounce_: {
    OS.copy_segment(0xEF370, 0x4 * 4)

    // reset spawning_shrooms count
    li      a2, spawning_shrooms
    sw      r0, 0x0000(a2)                  // reset spawning shroom count

    lh      a2, 0x0092(a0)                  // a2 = 0x0800 if grounded
    andi    a2, a2, 0x0800                  // a2 = 0 if not grounded
    bnez    a2, _skip_gravity               // if grounded, skip call that applies gravity
    nop
    j       0x80174940                      // return to original star routine
    nop
    _skip_gravity:
    j       0x80174958                      // return to original star routine without applying gravity
    nop
}

// @ Description
// Routine that runs when mushroom collides with player.
scope collide_mushroom_: {
    // a0 = player struct
    // a2 = item ID
    // s0 = item special struct

    sw      r0, 0x010C(s0)              // 0 this out to prevent the mushroom from colliding with more than one player

    OS.save_registers()

    // Get the player's size multiplier address
    li      t0, Size.multiplier_table
    lbu     t1, 0x000D(a0)              // t1 = port
    sll     t1, t1, 0x0002              // t1 = offset to size multiplier
    addu    t0, t0, t1                  // t0 = address of size multiplier
    sw      t0, 0x0020(sp)              // remember address of size multiplier
    li      t0, player_shrooms
    addu    t0, t0, t1                  // t0 = address of shroom routine object pointer
    sw      t0, 0x0024(sp)              // remember address of shroom routine object pointer
    li      t0, Size.match_state_table
    addu    t0, t0, t1                  // t0 = address of player's match size state
    lw      t0, 0x0000(t0)              // t0 = player's match size state
    sw      t0, 0x002C(sp)              // remember player's match size state
    //li      t0, Hazards.shrink_timer_table
    //addu    t0, t0, t1                  // t0 = address of Robot Bee shrink timer
    //sw      r0, 0x0000(t0)              // clear timer

    // register routine that handles the countdown
    Render.register_routine(handle_active_mushroom_)
    lw      a0, 0x0010(sp)              // a0 = player struct
    lw      a2, 0x0018(sp)              // a2 = item ID
    lw      t0, 0x0020(sp)              // t0 = address of size multiplier
    lw      t1, 0x0024(sp)              // t0 = address of shroom routine object pointer
    sw      a0, 0x0040(v0)              // save player struct in handler object
    sw      a2, 0x0044(v0)              // save item ID in handler object
    sw      t0, 0x0048(v0)              // save address of size multiplier
    sw      r0, 0x004C(v0)              // save timer value
    sw      r0, 0x0050(v0)              // save transition index
    sw      r0, 0x0054(v0)              // save size state
    sw      t1, 0x0058(v0)              // save address of shroom routine object pointer
    lw      t0, 0x002C(sp)              // t0 = player's match size state
    sw      t0, 0x005C(v0)              // save player's match size state

    OS.restore_registers()

    // Continue after item collision check
    addiu   a1, r0, 0x0258              // original line 4
    lw      a0, 0x004C(sp)              // original line 5
    j       0x800E3A5C                  // was 0x800E3C9C
    lw      ra, 0x001C(sp)              // original line 9
}

// @ Description
// Handles an active mushroom.
scope handle_active_mushroom_: {
    constant REVERT(600)
    constant GROW_DURATION(57)
    constant SHRINK_DURATION(48)
    constant MAINTAIN_DURATION(REVERT - GROW_DURATION - SHRINK_DURATION)
    constant STATE_TRANSITION_1(0)
    constant STATE_MAINTAIN(1)
    constant STATE_TRANSITION_2(2)
    // 0x0040(a0) = player struct
    // 0x0044(a0) = item ID
    // 0x0048(a0) = address of size multiplier
    // 0x004C(a0) = timer value
    // 0x0050(a0) = transition frame index
    // 0x0054(a0) = state
    // 0x0058(a0) = address of shroom routine object pointer
    // 0x005C(a0) = player's match size state
    // 0x0060(a0) = FGM flag
    sw      r0, 0x0060(a0)              // initialize FGM flag

    lw      t3, 0x0040(a0)              // t3 = player struct

    lw      t0, 0x004C(a0)              // t0 = timer value
    bnez    t0, _update_timer           // if timer > 0, skip setting shroomed state
    nop                                 // otherwise, set up shroomed state first frame

    lw      t5, 0x0058(a0)              // t5 = address of previous shroom routine object pointer
    lw      t6, 0x0000(t5)              // t6 = previous shroom routine object
    beqz    t6, _check_match_size       // if not currently shroomed, then set shroom routine object and skip ahead
    sw      a0, 0x0000(t5)              // set shroom routine object

    lw      t7, 0x0044(a0)              // t7 = this item ID
    lw      t8, 0x0044(t6)              // t6 = previous item ID

    sw      r0, 0x0064(a0)              // use this as a flag to play FGM

    // if same item, don't do transition 1
    // if different item, set previous item to final transition and destroy this item
    lli     t4, STATE_MAINTAIN
    beql    t7, t8, _clear_dupe_routine // if same item as already possessing, don't do transition 1
    sw      t4, 0x0054(a0)              // set state to MAINTAIN

    sw      t6, 0x0000(t5)              // set shroom routine object (keep it as it was prior to this mushroom)
    lli     t8, STATE_TRANSITION_2
    lw      at, 0x0054(t6)              // at = state of previous
    beql    at, t8, _pre_clear          // if already in transition 2, don't set it up for transition 2
    sw      t8, 0x0064(a0)              // set FGM flag to nonzero so we play the FGM
    lli     t8, GROW_DURATION + MAINTAIN_DURATION - 1
    lli     at, Item.PoisonMushroom.id  // at = Poison Mushroom ID
    bnel    t7, at, pc() + 8            // if poison, adjust start frame for transition 2
    addiu   t8, t8, SHRINK_DURATION - GROW_DURATION
    sw      t8, 0x004C(t6)              // set timer of previous item to the frame before transition 2
    sw      r0, 0x0050(t6)              // reset frame index
    sw      t4, 0x0054(t6)              // update state to MAINTAIN

    _pre_clear:
    or      t6, a0, r0                  // t6 = this item, which will get destroyed

    _clear_dupe_routine:
    // stop the duplicate routine from running any longer
    addiu   sp, sp, -0x0010             // allocate stack space
    sw      ra, 0x0004(sp)              // save ra
    sw      a0, 0x0008(sp)              // save a0
    sw      t6, 0x000C(sp)              // save t6
    jal     Render.DESTROY_OBJECT_
    or      a0, t6, r0                  // a0 = previous shroom routine object
    lw      ra, 0x0004(sp)              // restore ra
    lw      a0, 0x0008(sp)              // restore a0
    addiu   sp, sp, 0x0010              // deallocate stack space

    lw      t3, 0x0040(a0)              // t3 = player struct
    lw      t0, 0x004C(a0)              // t0 = timer value
    lw      t1, 0x0054(a0)              // t1 = state
    lli     t4, STATE_MAINTAIN
    beq     t1, t4, _check_match_size   // if the state was updated to MAINTAIN, then this object is good, so continue
    nop                                 // if it wasn't, then we can stop processing

    // If the previous item was already in transition 2, we need to play the sound for this item.
    // We have a flag for that!
    lw      t1, 0x0064(a0)              // t1 = FGM flag = non-zero if we should play
    beqz    t1, _return_destroyed       // if FGM flag not set, skip
    lw      t1, 0x0044(a0)              // t1 = item ID

    addiu   sp, sp, -0x0010             // allocate stack space
    sw      ra, 0x0004(sp)              // save ra

    lli     a0, 0x00D4                  // a0 = mushroom grow sound effect
    lli     at, Item.PoisonMushroom.id  // at = Poison Mushroom ID
    beql    t1, at, pc() + 8            // if poison mushroom, change sound effect
    lli     a0, 0x00D5                  // a0 = mushroom shrink sound effect
    jal     FGM.play_                   // play FGM
    nop

    lw      ra, 0x0004(sp)              // restore ra
    addiu   sp, sp, 0x0010              // deallocate stack space

    _return_destroyed:
    jr      ra
    nop

    _check_match_size:
    // state | get    | have
    // ----- | ------ | ------
    // tiny  | poison | none   => sound/flash/revert
    // tiny  | poison | super  => sound/flash/shrink to tiny
    // tiny  | super  | none   => sound/flash/grow from tiny
    // tiny  | super  | super  => sound/flash/maintain
    // giant | super  | none   => sound/flash/revert
    // giant | super  | poison => sound/flash/grow to giant
    // giant | poison | none   => sound/flash/shrink from giant
    // giant | poison | poison => sound/flash/maintain

    // here, check match size state to see if we need to adjust the transitions
    lw      t7, 0x0044(a0)              // t7 = this item ID
    lw      t5, 0x005C(a0)              // t5 = player's match size state
    beqz    t5, _flash                  // if match size is normal, skip extra logic
    lli     t6, Size.state.GIANT        // t6 = GIANT match state
    beq     t5, t6, _giant              // if match size is giant, go to giant logic
    nop                                 // otherwise use tiny logic

    // Tiny
    // if STATE_TRANSITION_1 && poison, then revert
    // if STATE_TRANSITION_1 && super, then transition 1 should be grow_poison
    lli     t6, STATE_TRANSITION_1      // t6 = STATE_TRANSITION_1
    lli     at, Item.PoisonMushroom.id  // at = Poison Mushroom ID
    bne     at, t7, _flash              // if Super, skip
    lw      t5, 0x0054(a0)              // t5 = state

    beql    t5, t6, _flash              // if we just got our first shroom and it's poison, don't apply it by spoofing the timer
    lli     t0, REVERT                  // t0 = REVERT

    b       _flash
    nop

    _giant:
    // Tiny
    // if STATE_TRANSITION_1 && super, then revert
    // if STATE_TRANSITION_1 && poison, then transition 1 should be shrink_super
    lli     t6, STATE_TRANSITION_1      // t6 = STATE_TRANSITION_1
    lli     at, Item.PoisonMushroom.id  // at = Poison Mushroom ID
    beq     at, t7, _flash              // if Poison, skip
    lw      t5, 0x0054(a0)              // t5 = state

    beql    t5, t6, _flash              // if we just got our first shroom and it's super, don't apply it by spoofing the timer
    lli     t0, REVERT                  // t0 = REVERT

    _flash:
    addiu   sp, sp, -0x0020             // allocate stack space
    sw      ra, 0x0004(sp)              // save registers
    sw      a0, 0x0008(sp)              // ~
    sw      t0, 0x000C(sp)              // ~
    sw      t1, 0x0010(sp)              // ~
    sw      t3, 0x0014(sp)              // ~

    // play sound effect
    lw      t1, 0x0044(a0)              // t1 = this item ID
    sw      t1, 0x0060(a0)              // set FGM flag
    lli     a0, 0x00D4                  // a0 = mushroom grow sound effect
    lli     at, Item.PoisonMushroom.id  // at = Poison Mushroom ID
    beql    t1, at, pc() + 8            // if poison mushroom, change sound effect
    lli     a0, 0x00D5                  // a0 = mushroom shrink sound effect
    jal     FGM.play_                   // play FGM
    nop

    // do flash effect
    lw      a0, 0x0008(sp)              // restore a0
    lw      a0, 0x0040(a0)              // a0 = player struct
    lw      a0, 0x0004(a0)              // a0 = player object
    lli     a1, 0x0005                  // a1 = flash_id (quick bright flash)
    jal     Global.flash_               // add flash
    lli     a2, 0x0000                  // a2 = 0

    lw      ra, 0x0004(sp)              // ~
    lw      a0, 0x0008(sp)              // ~
    lw      t0, 0x000C(sp)              // ~
    lw      t1, 0x0010(sp)              // ~
    lw      t3, 0x0014(sp)              // ~
    addiu   sp, sp, 0x0020              // deallocate stack space

    _update_timer:
    addiu   t0, t0, 0x0001              // t0 = timer value++
    sltiu   at, t0, REVERT              // at = 0 if end of size alteration reached
    beqz    at, _revert                 // if end of mushroom duration reached, then revert
    sw      t0, 0x004C(a0)              // update timer value

    lhu     t2, 0x0026(t3)              // t2 = action
    sltiu   at, t2, 0x0004              // at = 1 if player just died
    bnez    at, _revert                 // if player died, then revert
    // delay slot below runs always, intentionally

    lw      t2, 0x0048(a0)              // t2 = address of size multiplier
    lw      t7, 0x0054(a0)              // t7 = state
    lw      t8, 0x005C(a0)              // t8 = player's match size state

    lw      t4, 0x0044(a0)              // t4 = item ID
    lli     at, Item.PoisonMushroom.id  // at = Poison Mushroom ID
    beq     t4, at, _poison             // if Poison Mushroom, set up transition variables differently
    lw      t4, 0x0050(a0)              // t4 = frame index

    // super mushroom set up
    beqz    t8, _super_setup_normal     // if match size is normal, use normal logic
    nop                                 // otherwise, set up for tiny

    // _super_setup_tiny:
    lli     at, STATE_TRANSITION_1      // at = STATE_TRANSITION_1
    beq     t7, at, _grow_poison        // first transition is grow
    lli     at, STATE_TRANSITION_2      // at = STATE_TRANSITION_2
    beql    t7, at, _shrink_poison      // second transition is shrink
    addiu   t0, t0, -(MAINTAIN_DURATION + GROW_DURATION) // t0 = frame of shrink transition

    lli     at, GROW_DURATION + MAINTAIN_DURATION
    beql    t0, at, pc() + 8            // if we've reached the start of transition 2, increment state
    lli     t7, STATE_TRANSITION_2      // t7 = STATE_TRANSITION_2

    lui     t1, 0x3F80                  // t1 = normal size
    b       _set_size_multipler
    sw      t7, 0x0054(a0)              // save state

    _super_setup_normal:
    lli     at, STATE_TRANSITION_1      // at = STATE_TRANSITION_1
    beq     t7, at, _grow               // first transition is grow
    lli     at, STATE_TRANSITION_2      // at = STATE_TRANSITION_2
    beql    t7, at, _shrink             // second transition is shrink
    addiu   t0, t0, -(MAINTAIN_DURATION + GROW_DURATION) // t0 = frame of shrink transition

    lli     at, GROW_DURATION + MAINTAIN_DURATION
    beql    t0, at, pc() + 8            // if we've reached the start of transition 2, increment state
    lli     t7, STATE_TRANSITION_2      // t7 = STATE_TRANSITION_2

    lui     t1, 0x4010                  // t1 = increased size
    b       _set_size_multipler
    sw      t7, 0x0054(a0)              // save state

    _poison:
    // poison mushroom set up
    beqz    t8, _poison_setup_normal    // if match size is normal, use normal logic
    nop                                 // otherwise, set up for giant

    // _poison_setup_giant:
    lli     at, STATE_TRANSITION_1      // at = STATE_TRANSITION_1
    beq     t7, at, _shrink             // first transition is shrink
    lli     at, STATE_TRANSITION_2      // at = STATE_TRANSITION_2
    beql    t7, at, _grow               // second transition is grow
    addiu   t0, t0, -(MAINTAIN_DURATION + SHRINK_DURATION) // t0 = frame of grow transition

    lli     at, SHRINK_DURATION + MAINTAIN_DURATION
    beql    t0, at, pc() + 8            // if we've reached the start of transition 2, increment state
    lli     t7, STATE_TRANSITION_2      // t7 = STATE_TRANSITION_2

    lui     t1, 0x3F80                  // t1 = normal size
    b       _set_size_multipler
    sw      t7, 0x0054(a0)              // save state

    _poison_setup_normal:
    lli     at, STATE_TRANSITION_1      // at = STATE_TRANSITION_1
    beq     t7, at, _shrink_poison      // first transition is shrink
    lli     at, STATE_TRANSITION_2      // at = STATE_TRANSITION_2
    beql    t7, at, _grow_poison        // second transition is grow
    addiu   t0, t0, -(MAINTAIN_DURATION + SHRINK_DURATION) // t0 = frame of grow transition

    lli     at, SHRINK_DURATION + MAINTAIN_DURATION
    beql    t0, at, pc() + 8            // if we've reached the start of transition 2, increment state
    lli     t7, STATE_TRANSITION_2      // t7 = STATE_TRANSITION_2

    lui     t1, 0x3F00                  // t1 = decreased size
    b       _set_size_multipler
    sw      t7, 0x0054(a0)              // save state

    _grow:
    li      t5, transition_frames_grow
    li      t6, transition_sizes_grow
    lli     t8, 0x00D4                  // t8 = mushroom grow sound effect
    lli     at, GROW_DURATION
    bne     t0, at, _check_transition   // if we've reached the end of the transition, increment state
    addiu   t7, t7, 0x0001              // increment state
    b       _check_transition
    sw      t7, 0x0054(a0)              // save state

    _shrink:
    li      t5, transition_frames_shrink
    li      t6, transition_sizes_shrink
    lli     t8, 0x00D5                  // t8 = mushroom shrink sound effect
    lli     at, SHRINK_DURATION
    bne     t0, at, _check_transition   // if we've reached the end of the transition, increment state
    addiu   t7, t7, 0x0001              // increment state
    b       _check_transition
    sw      t7, 0x0054(a0)              // save state

    _grow_poison:
    li      t5, transition_frames_grow
    li      t6, transition_sizes_grow_poison
    lli     t8, 0x00D4                  // t8 = mushroom grow sound effect
    lli     at, GROW_DURATION
    bne     t0, at, _check_transition   // if we've reached the end of the transition, increment state
    addiu   t7, t7, 0x0001              // increment state
    b       _check_transition
    sw      t7, 0x0054(a0)              // save state

    _shrink_poison:
    li      t5, transition_frames_shrink
    li      t6, transition_sizes_shrink_poison
    lli     t8, 0x00D5                  // t8 = mushroom shrink sound effect
    lli     at, SHRINK_DURATION
    bne     t0, at, _check_transition   // if we've reached the end of the transition, increment state
    addiu   t7, t7, 0x0001              // increment state
    b       _check_transition
    sw      t7, 0x0054(a0)              // save state

    _check_transition:
    // play sound effect if on the first frame
    lli     at, 0x0001                  // at = 1
    bne     t0, at, _begin_check        // skip if not on first frame of transition
    or      t9, a0, r0                  // t9 = a0 (save a0)
    lw      t7, 0x0060(a0)              // t7 = FGM flag
    bnez    t7, _do_rumble              // if already played the FGM, then don't play it again!
    or      t7, ra, r0                  // t7 = ra (save ra)
    jal     FGM.play_                   // play FGM
    or      a0, t8, r0                  // a0 = fgm_id
    or      a0, t9, r0                  // restore a0 (routine object)
    or      ra, t7, r0                  // restore ra (routine object)

    _do_rumble:
    addiu   sp, sp, -0x0020             // allocate stack space
    sw      ra, 0x0004(sp)              // save registers
    sw      a0, 0x0008(sp)              // ~
    sw      t0, 0x000C(sp)              // ~
    sw      t2, 0x0010(sp)              // ~
    sw      t4, 0x0014(sp)              // ~
    sw      t5, 0x0018(sp)              // ~
    sw      t6, 0x001C(sp)              // ~

    // do rumble
    lw      a0, 0x0040(a0)              // a0 = player struct
    lbu     a1, 0x0023(a0)              // a1 = player type (0 = HMN, 1 = CPU)
    bnez    a1, _end_rumble             // if port is CPU, skip rumble
    lbu     a0, 0x000D(a0)              // a0 = port
    lli     a1, 0x0007                  // a1 = rumble_id (same as Mario's taunt)
    lli     a2, 0x003C                  // a2 = duration
    jal     Global.rumble_              // add rumble
    addiu   sp, sp, -0x0030             // allocate stack space (not a safe function)
    addiu   sp, sp, 0x0030              // deallocate stack space
    lli     t0, 0x0001                  // v0 can be 1 sometimes (like during Mario's taunt)
    beq     v0, t0, _end_rumble         // if v0 not a rumble struct, skip updating rumble_id
    lli     t0, 0x0017                  // t0 = non-valid rumble_id
    bnezl   v0, _end_rumble             // if rumble struct was assigned, update rumble_id
    sb      t0, 0x0000(v0)              // save non-valid rumble_id in rumble info struct to avoid action change disabling rumble

    _end_rumble:
    lw      ra, 0x0004(sp)              // ~
    lw      a0, 0x0008(sp)              // ~
    lw      t0, 0x000C(sp)              // ~
    lw      t2, 0x0010(sp)              // ~
    lw      t4, 0x0014(sp)              // ~
    lw      t5, 0x0018(sp)              // ~
    lw      t6, 0x001C(sp)              // ~
    addiu   sp, sp, 0x0020              // deallocate stack space

    _begin_check:
    addu    t5, t5, t4                  // t5 = transition frame address
    lbu     t5, 0x0000(t5)              // t5 = transition frame
    bnel    t5, t0, _set_size_multipler // if not a transition frame, keep previous value
    lw      t1, 0x0000(t2)              // t1 = previous value

    sll     t5, t4, 0x0002              // t5 = offset to size value
    addu    t5, t5, t6                  // t5 = address of size value
    lw      t1, 0x0000(t5)              // t1 = size value

    addiu   t4, t4, 0x0001              // t4++ (frame index++)
    sltiu   at, t4, 0x000C              // at = 0 if no more frames
    beqzl   at, pc() + 8                // if no more transition frames, zero out frame index
    lli     t4, 0x0000                  // t4 = 0
    sw      t4, 0x0050(a0)              // save frame index

    _set_size_multipler:
    sw      t1, 0x0000(t2)              // set size multiplier for character

    _return:
    jr      ra
    nop

    _revert:
    lw      t2, 0x0048(a0)              // t2 = address of size multiplier
    lw      t3, 0x005C(a0)              // t3 = player's match size state
    beqzl   t3, _clear_size_multiplier  // if player's match size state is normal, use 1
    lui     t1, 0x3F80                  // t1 = (float) 1.0
    lli     t4, Size.state.GIANT        // t4 = GIANT
    beql    t3, t4, _clear_size_multiplier // if in GIANT state, use giant size multiplier
    lui     t1, 0x4010                  // t9 = 2.25 (float)
    // otherwise, we're in TINY state so use tiny size multiplier
    lui     t1, 0x3F00                  // t9 = 0.5 (float)

    _clear_size_multiplier:
    sw      t1, 0x0000(t2)              // clear size multiplier

    lw      t5, 0x0058(a0)              // t5 = address of current shroom routine object pointer
    sw      r0, 0x0000(t5)              // clear shroom routine object

    // stop this routine from running any longer
    addiu   sp, sp, -0x0010             // allocate stack space
    sw      ra, 0x0004(sp)              // save ra
    jal     Render.DESTROY_OBJECT_
    nop
    lw      ra, 0x0004(sp)              // restore ra
    addiu   sp, sp, 0x0010              // deallocate stack space

    jr      ra
    nop
}

// @ Description
// Clears the effects of active mushrooms.
scope clear_active_mushrooms_: {
    li      t0, player_shrooms
    sw      r0, 0x0000(t0)              // clear shroom routine object pointer p1
    sw      r0, 0x0004(t0)              // clear shroom routine object pointer p1
    sw      r0, 0x0008(t0)              // clear shroom routine object pointer p3
    sw      r0, 0x000C(t0)              // clear shroom routine object pointer p4

    jr      ra
    nop
}

// @ Description
// Holds frames for transition effects' different sizes.
transition_frames_grow:
db 11
db 16
db 21
db 26
db 30
db 34
db 38
db 42
db 45
db 48
db 51
db 54
transition_frames_shrink:
db 4
db 7
db 10
db 13
db 16
db 19
db 22
db 25
db 28
db 33
db 38
db 43
OS.align(4)

// @ Description
// Holds sizes for transition effects.
transition_sizes_grow:
dw 0x3FA66000
dw 0x3F800000
dw 0x3FA66000
dw 0x3F800000
dw 0x3FA66000
dw 0x3FF33000
dw 0x40100000
dw 0x3F800000
dw 0x3FA66000
dw 0x3FF33000
dw 0x40100000
dw 0x3FA66000
transition_sizes_shrink:
dw 0x3FA66000
dw 0x40100000
dw 0x3FF33000
dw 0x3FA66000
dw 0x3F800000
dw 0x40100000
dw 0x3FF33000
dw 0x3FA66000
dw 0x3F800000
dw 0x3FA66000
dw 0x3F800000
dw 0x3FA66000
transition_sizes_grow_poison:
dw 0x3F266666
dw 0x3F000000
dw 0x3F266666
dw 0x3F000000
dw 0x3F266666
dw 0x3F666666
dw 0x3F800000
dw 0x3F000000
dw 0x3F266666
dw 0x3F666666
dw 0x3F800000
dw 0x3F266666
transition_sizes_shrink_poison:
dw 0x3F266666
dw 0x3F800000
dw 0x3F666666
dw 0x3F266666
dw 0x3F000000
dw 0x3F800000
dw 0x3F666666
dw 0x3F266666
dw 0x3F000000
dw 0x3F266666
dw 0x3F000000
dw 0x3F266666
