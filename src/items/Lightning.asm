// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(Item.spawn_custom_item_based_on_tomato_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(pickup_lightning_)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0x801745FC) 		// same as Maxim Tomato
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xE80)
constant STATE_TABLE(item_info_array + 0x34)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw 0x8018D040                           // 0x04 - hard-coded pointer to file 0xFB
dw FILE_OFFSET                          // 0x08 - offset to item footer in file 0xFB
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0                                    // 0x10 - ?
dw 0x801744C0                           // 0x14 - ? spawn behavior? (using Maxim Tomato)
dw 0x80174524                           // 0x18 - ? ground collision? (using Maxim Tomato)
dw 0                                    // 0x1C - ?
dw 0, 0, 0, 0                           // 0x20 - 0x2C - ?
dw 0                                    // 0x30 - ?
dw 0                                    // 0x34 - ?
dw 0x801744FC                           // 0x38 - ? resting state? (using Maxim Tomato)
dw 0                                    // 0x3C - ?
dw 0, 0, 0, 0                           // 0x40 - 0x4C - ?
dw 0                                    // 0x50 - ?
dw 0x801744C0                           // 0x54 - ? (using Maxim Tomato)
dw 0x80174524                           // 0x58 - ? (using Maxim Tomato)
dw 0                                    // 0x5C - ?
dw 0, 0, 0, 0                           // 0x60 - 0x6C thrown
dw 0                                    // 0x70 - ?
dw 0x801744C0                           // 0x74 - ? (using Maxim Tomato)
dw 0x801745CC                           // 0x78 - ? (using Maxim Tomato)
dw 0                                    // 0x7C - ?
dw 0, 0, 0, 0                           // 0x80 - 0x8C - ?
dw 0                                    // 0x90
dw 0, 0, 0                              // 0x94 - 0x9C - state - thrown

constant lightning_shrink_timer(600)            // 10 seconds. 60 = 1 second
constant lightning_time(25)                     // used for flash
constant frames_til_zap(0)
constant zap_sfx_delay(5)

// @ Description
// Main item pickup routine for cloaking device.
scope pickup_lightning_: {

    // a0 = player struct
    OS.save_registers()

    // register routine that handles the countdown
    Render.register_routine(aerial_main_)
    lw      a0, 0x0010(sp)              // a0 = player struct
    lw      a2, 0x0018(sp)              // a2 = item object
    sw      a0, 0x0040(v0)              // save player struct in handler object
    sw      a2, 0x0044(v0)              // save item object in handler object

    addiu   at, r0, 0x0001
    addiu   t7, r0, lightning_time      // throw timer = x frames
    andi    t9, t8, 0xfff1
    sb      t7, 0x004C(v0)              // save timer

    li      t0, Toggles.entry_flash_guard
    lw      t0, 0x0004(t0)              // t0 = 1 if Flash Guard is enabled
    bnez    t0, _restore_registers      // skip if Flash Guard is enabled
    nop
    li      t0, 0x80131460              // t0 = global ptr to camera object
    lw      t0, 0x0000(t0)              // t0 = global camera object
    addiu   t2, r0, 0x0002              // t2 = 2
    // 'set mode to 2. ' this makes it black
    sw      t2, 0x0108(t0)              // set mode to 2. (default is 4)
    addiu   t1, r0, 0xFFFF              // t1 = white
    sw      t1, 0x010C(t0)              // save draw colour
    _restore_registers:
    OS.restore_registers()

    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}

// @ Description
// Clears the timer and routine for active lightning.
scope clear_active_lightning_routine_: {
    li      t8, shrink_timer_table      // t8 = shrink timer for lightning
    sw      r0, 0x0000(t8)              // clear timers
    sw      r0, 0x0004(t8)              // ~
    sw      r0, 0x0008(t8)              // ~
    sw      r0, 0x000C(t8)              // ~
    li      t8, lightning_routine_      // t8 = shrink timer for lightning
    sw      r0, 0x0000(t8)              // clear routine ptr
    jr      ra
    nop
}

// @ Description
// Pointer to current routine handler object for lightning.
lightning_routine_:
dw   0x00000000

// @ Description
// based on red shell aerial physics routine @ 0x8017A74C
scope aerial_main_: {
    addiu   sp, sp, -0x24           // allocate sp
    sw      ra, 0x0014(sp)          // store registers
    sw      a0, 0x0020(sp)          // save routine handler
    sw      s1, 0x0004(sp)          //

    // 0x0040(a0) owner
    // 0x0044(a0) item obj
    // 0x004C(a0) timer

    // save camera pointer to sp
    li      t0, 0x80131460          // t0 = global ptr to camera object
    lw      t0, 0x0000(t0)          // t0 = global camera object
    sw      t0, 0x0008(sp)          // save to stack space

    lbu     v0, 0x004C(a0)          // v0 = throw timer

    addiu   at, r0, lightning_time - frames_til_zap // at = frame to zap players
    bne     at, v0, _check_sfx      // if not that frame, skip zapping players and sfx
    nop

    _zap_players:
    li      a1, shrink_timer_table
    addiu   at, r0, 0x01E0          // at = shrink time
    sw      at, 0x0000(a1)          // save to slot 1
    sw      at, 0x0004(a1)          // save to slot 2
    sw      at, 0x0008(a1)          // save to slot 3
    sw      at, 0x000C(a1)          // save to slot 4

    li      at, lightning_routine_   // at = current lightning routine
    lw      at, 0x0000(at)
    bnez    at, _skip_routine_registration // skip if lightning routine already registered
    nop
    OS.save_registers()
    Render.register_routine(shrink_timer_)
    nop
    li      at, lightning_routine_  // at = ptr to lightning routine
    sw      v0, 0x0000(at)          // save routine to our hard coded spot
    OS.restore_registers()

    _skip_routine_registration:
    lw      at, 0x0020(sp)          // at = handler
    lw      a1, 0x0040(at)          // a1 = item owner object struct
    jal     lightning_zap_players_
    nop
    b       _continue
    lw      a0, 0x0020(sp)

    _check_sfx:
    addiu   at, r0, lightning_time - frames_til_zap - zap_sfx_delay // at = sfx frame
    bne     at, v0, _check_timer    // if not that frame, skip zapping players and sfx
    nop
    addiu   a0, r0, 0xE8            // argument = thunder sfx
    jal     0x800269C0              // play fgm
    nop
    b       _continue
    nop

    _check_timer:
    lw      t0, 0x0008(sp)          // save to stack space

    beqzl   v0, _end_lightning      // if timer is 0, return camera draw clear to false and destroy object
    addiu   t2, r0, 0x0004          // t2 = 4
    addiu   t2, r0, 0x0002          // t2 = 2
    sll     at, v0, 27              // check bit in timer and see what colour we have to set to
    srl     at, at, 31

    li      t1, 0x040433FF          // t1 = dark blue
    beqzl   at, _set_draw_mode
    sw      t1, 0x010C(t0)          // overwrite global camera draw colour with dark blue

    // if here, set colour to white
    addiu   t1, r0, 0xFFFF          // at = color.white 0xFFFFFFFF
    b       _set_draw_mode
    sw      t1, 0x010C(t0)          // t1 = overwrite global camera draw colour with COLOR.WHITE

    _end_lightning:
    jal     Render.DESTROY_OBJECT_
    lw      a0, 0x0020(sp)          // load routine handler
    lw      t0, 0x0008(sp)          // load camera object ptr
    b       _end
    sw      t2, 0x0108(t0)          // set camera draw clear true or false. (default is 4)

    _set_draw_mode:
    li      a0, Toggles.entry_flash_guard
    lw      a0, 0x0004(a0)          // a0 = 1 if Flash Guard is enabled
    beqzl   a0, _continue           // set camera only if Flash Guard is not enabled
    sw      t2, 0x0108(t0)          // set camera draw clear true or false. (default is 4)

    _continue:
    lw      a0, 0x0020(sp)          // load routine handler
    lbu     v0, 0x004C(a0)          // v0 = timer
    addiu   at, r0, 0x00ff
    beql    v0, at, _end            // branch if timer has ended
    addiu   v0, r0, 0x0001          // destroy if ended

    addiu   t8, v0, 0xffff          //
    sb      t8, 0x004C(a0)          // save timer

    _end:
    lw      s1, 0x0004(sp)          //
    lw      ra, 0x0014(sp)          // restore registers
    addiu   sp, sp, 0x24            // deallocate sp
    jr      ra                      // return
    nop                             // ~
}

// @ Description
// shrink all other players than s0. modified robot bee code
// todo: grow the players back to normal
scope lightning_zap_players_: {
    addiu   sp, sp, -0x0030                     // allocate stack space
    sw      ra, 0x0004(sp)                      // save registers
    sw      a1, 0x0014(sp)                      // save registers

    li      at, FranklinBadge.players_with_franklin_badge     // at = player ports with a Franklin Badge
    sw      at, 0x0008(sp)                      // save the array to stackspace

    // a1 = lightning owner
    // a0 = item special struct
    // s0 = lightning owner

    li      t0, 0x800466FC
    lw      t0, 0x0000(t0)                      // t0 = first player object
    sw      t0, 0x0010(sp)                      // save player object t0 stack
    lw      t0, 0x0084(t0)                      // t0 = first player struct

    li      t3, Global.match_info               // ~
    lw      t3, 0x0000(t3)                      // t3 = match info struct
    lbu     t4, 0x0002(t3)                      // t4 = team battle flag
    lbu     t3, 0x0009(t3)                      // t3 = team attack flag
    sw      t4, 0x0024(sp)                      // save team battle flag to stack
    sw      t3, 0x0028(sp)                      // save team attack flag to stack

    _loop:
    lw      a1, 0x0014(sp)                      // a1 = item owner struct
    lw      a0, 0x0010(sp)                      // a0 = current player object
    lw      t4, 0x0024(sp)                      // load team battle flag from stack
    lw      t3, 0x0028(sp)                      // load team attack flag from stack

    sw      t0, 0x000C(sp)                      // save player struct to stack
    sw      a0, 0x0010(sp)                      // save player object to stack
    beqz    a0, _next                           // if no player object, skip this port
    lw      t2, 0x000C(sp)                      // t2 = player struct
    beq     t2, a1, _next                       // if player is item owner, skip this port
    nop

    beqz    t4, _action_check                   // branch if team battle flag = FALSE
    nop

    bnez    t3, _action_check                   // branch if team attack flag != FALSE
    nop

    lbu     t2, 0x000C(t2)                      // t2 = player team
    lbu     t5, 0x000C(a1)                      // t5 = item owner team
    beq     t2, t5, _next                       // if player is team mate with team attack off, skip this port
    nop

    _action_check:
    lw      a0, 0x0024(t0)                      // a0 = players current action
    addiu   at, r0, Action.Revive1              // at = revive1
    beq     at, a0, _next                       // skip if player reviving
    nop
    addiu   at, r0, Action.Revive2              // at = revive2
    beq     at, a0, _next                       // skip if player reviving
    nop
    addiu   at, r0, Action.ReviveWait           // at = reviveWait
    beq     at, a0, _next                       // skip if player reviving
    nop

    lw      a0, 0x05A4(t0)                      // check if player is invulnerable from spawning
    bnez    a0, _next                           // skip this player if they are still spawning
    nop
    lw      a0, 0x05B0(t0)                      // a0 = super star counter
    bnez    a0, _next                           // skip this player if they are using a super star
    nop

    lw      a0, 0x0008(sp)                      // load players entry in franklin badge array
    lw      a0, 0x0000(a0)                      // a0 = ptr to player with franklin badge in this port
    beqz    a0, _zap_player                     // branch to zap player if they don't have a franklin badge
    nop

    // if here, this player has a Franklin Badge
    jal     0x800269C0                          // play FGM
    lli     a0, 0x041B                          // FGM id = franklin badge reflect sound
    b       _next                               // skip if there is a player with a franklin badge here
    nop

    _zap_player:
    lw      s1, 0x000C(sp)                      // s1 = player struct (used for 2d gfx scaling)
    lw      a0, 0x78(s1)                        // load player location struct
    jal     0x80101408                          // lightning strike gfx routine, may want to check original ra 80101428
    nop
    li      t6, Size.multiplier_table
    li      t8, shrink_timer_table
    li      v1, Item.SuperMushroom.player_shrooms
    lw      a0, 0x0010(sp)                      // load player object
    lw      t0, 0x000C(sp)                      // load player struct
    lw      t2, 0x000C(sp)                      // t2 = player struct

    lbu     t3, 0x000D(t2)                      // t3 = port
    sll     t3, t3, 0x0002                      // t3 = offset to size multiplier
    addu    t7, t6, t3                          // t7 = address of size multiplier
    addu    t9, t8, t3                          // t9 = address of shrink timer

    lui     t4, 0x3F00                          // t4 = Shrunk size multiplier
    addiu   at, r0, lightning_shrink_timer      // at = shrink duration
    sw      at, 0x0000(t9)                      // save duration to shrink timer for port
    sw      t4, 0x0000(t7)                      // save size to multiplier table for port
    addu    t9, v1, t3                          // t9 = address of player shroom
    lw      t4, 0x0000(t9)                      // t4 = active shroom routine if not 0
    beqz    t4, _apply_damage                   // if no active shroom, skip to apply damage
    sw      r0, 0x0000(t9)                      // clear shroom reference

    // destroy the active shroom routine
    addiu   sp, sp, -0x0020                     // allocate stack space
    sw      ra, 0x0004(sp)                      // save registers
    sw      a0, 0x0008(sp)                      // ~
    sw      t0, 0x000C(sp)                      // ~
    sw      t5, 0x0010(sp)                      // ~
    sw      t6, 0x0014(sp)                      // ~
    sw      t8, 0x0018(sp)                      // ~
    sw      v1, 0x001C(sp)                      // ~
    jal     Render.DESTROY_OBJECT_
    or      a0, t4, r0                          // a0 = shroom routine object
    lw      ra, 0x0004(sp)                      // restore registers
    lw      a0, 0x0008(sp)                      // ~
    lw      t0, 0x000C(sp)                      // ~
    lw      t5, 0x0010(sp)                      // ~
    lw      t6, 0x0014(sp)                      // ~
    lw      t8, 0x0018(sp)                      // ~
    lw      v1, 0x001C(sp)                      // ~
    addiu   sp, sp, 0x0020                      // deallocate stack space

    _apply_damage:
    addiu   a0, t0, 0x0000                      // a0 = player getting struck
    jal     0x800EA248                          // jump to damage application routine
    addiu   a1, r0, 0x0001                      // set to 1 damage per drop
    //jal     0x80141670
    //lw      a0, 0x0010(sp)                      // a0 = current player object

    _next:
    lw      a0, 0x0008(sp)                      // load franklin badge array
    addiu   a0, a0, 0x0004                      // a0 = next entry in array
    sw      a0, 0x0008(sp)                      // save next Franklin Badge entry to stackspace

    lw      a0, 0x0010(sp)                      // a0 = current player object
    lw      a0, 0x0004(a0)                      // a0 = next player object
    sw      a0, 0x0010(sp)                      // save next player object
    bnezl   a0, _loop                           // if more players, keep looping
    lw      t0, 0x0084(a0)                      // t0 = next player struct

    lw      ra, 0x0004(sp)                      // restore registers
    lw      a1, 0x0014(sp)                      // ~
    addiu   sp, sp, 0x0030                      // deallocate stack space
    jr      ra
    nop
}

    shrink_timer_table:
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000
    dw  0x00000000

// @ Description
// copy of main routine for shrink ray duration
scope shrink_timer_: {
    addiu   sp, sp, -0x0028
    sw      ra, 0x001C(sp)

    // check to see if mushroom acquired during shrink ray time
    li      t0, shrink_timer_table
    li      t5, Item.SuperMushroom.player_shrooms
    addiu   t6, r0, 0x0003

    _loop:
    lw      t1, 0x0000(t5)      // t1 = active mushrom routine object, or 0 if no active shroom
    bnezl   t1, _skip           // if active shroom, clear timer
    sw      r0, 0x0000(t0)      // clear timer

    _skip:
    addiu   t0, t0, 0x0004      // advance port
    addiu   t5, t5, 0x0004      // advance port
    bnezl   t6, _loop           // loop after all ports gone through
    addiu   t6, t6, 0xFFFF      // subtract 1


    // check to see if should end duration of shrink
    li      t0, shrink_timer_table
    li      t6, Size.multiplier_table
    li      t8, Size.match_state_table
    addiu   t5, r0, 0x0003      // load loop amount

    _loop_2:
    lw      t1, 0x0000(t0)      // load timer for port 1
    addiu   t3, r0, 0x0001      // place 1 in timer
    addiu   t2, t1, 0xFFFF      // subtract 1 from timer
    beq     t1, t3, _end_duration
    nop
    bnezl   t1, pc() + 8        // if timer isn't 0, update timer
    sw      t2, 0x0000(t0)      // update timer
    b       _next
    nop

    _end_duration:
    lw      t3, 0x0000(t8)      // t3 = size state
    beqzl   t3, _reset_size_multiplier // if in NORMAL state, use normal size multiplier
    lui     t4, 0x3F80          // t4 = (float) 1.0
    lli     t1, Size.state.GIANT // t1 = GIANT
    beql    t3, t1, _reset_size_multiplier // if in GIANT state, use giant size multiplier
    lui     t4, 0x4010          // t4 = 2.25 (float)
    // otherwise, we're in TINY state so use tiny size multiplier
    lui     t4, 0x3F00          // t4 = 0.5 (float)

    _reset_size_multiplier:
    sw      t4, 0x0000(t6)      // reset size multiplier
    sw      r0, 0x0000(t0)      // clear timer

    _next:
    addiu   t0, t0, 0x0004      // advance port
    addiu   t6, t6, 0x0004      // advance port
    addiu   t8, t8, 0x0004      // advance port
    bnez    t5, _loop_2         // if t5 isn't 0, then we haven't looped through each spots
    addiu   t5, t5, 0xFFFF      // subtract 1 from t5

    _end:
    lw  ra, 0x001C(sp)
    addiu   sp, sp, 0x0028
    jr      ra
    nop
}
