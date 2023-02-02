// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(Item.spawn_custom_item_based_on_tomato_)
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_cloaking_device_)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0x801745FC) // same as Maxim Tomato
constant PLAYER_COLLISION(0)
constant THROW_ITEM(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0xD40)

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
dw 0, 0, 0, 0                           // 0x60 - 0x6C - ?
dw 0                                    // 0x70 - ?
dw 0x801744C0                           // 0x74 - ? (using Maxim Tomato)
dw 0x801745CC                           // 0x78 - ? (using Maxim Tomato)
dw 0                                    // 0x7C - ?
dw 0, 0, 0, 0                           // 0x80 - 0x8C - ?
dw 0, 0, 0, 0                           // 0x90 - 0x9C - ?

// @ Description
// Flags for keeping track whether or not a player has a cloak
cloaked_players:
db 0, 0, 0, 0                           // flags for p1 through p4

// @ Description
// Main item pickup routine for cloaking device.
scope pickup_cloaking_device_: {
    // a0 = player struct
    // a2 = item object

    OS.save_registers()

    // Get the player's env color override address
    li      t0, CharEnvColor.override_table
    lbu     t1, 0x000D(a0)              // t1 = port
    sll     t1, t1, 0x0002              // t1 = offset to env color override value
    addu    t0, t0, t1                  // t0 = address of env color override value
    sw      t0, 0x0020(sp)              // remember address of env color override value

    // register routine that handles the countdown
    Render.register_routine(handle_active_cloaking_device_)
    lw      a0, 0x0010(sp)              // a0 = player struct
    lw      a2, 0x0018(sp)              // a2 = item object
    lw      t0, 0x0020(sp)              // t0 = address of env color override value
    sw      a0, 0x0040(v0)              // save player struct in handler object
    sw      a2, 0x0044(v0)              // save item object in handler object
    sw      t0, 0x0048(v0)              // save address of env color override value
    sw      r0, 0x004C(v0)              // save timer value

    OS.restore_registers()

    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}

// @ Description
// Handles an active cloaking device.
scope handle_active_cloaking_device_: {
    constant TRANSITION(32)
    constant DECLOAK(600)
    // 0x0040(a0) = player struct
    // 0x0044(a0) = item object
    // 0x0048(a0) = address of env color override value
    // 0x004C(a0) = timer value

    lw      t3, 0x0040(a0)              // t3 = player struct
    lbu     t9, 0x000D(t3)              // t1 = port
    li      t8, cloaked_players         // t8 = cloaked_players
    addu    t8, t8, t9                  // t8 = address of cloaked flag for this player
    lli     at, OS.TRUE                 // at = TRUE
    sb      at, 0x0000(t8)              // update cloaked flag

    lw      t0, 0x0A30(t3)              // t0 = address of current player gfx effect
    li      t2, 0x8012CB34              // t2 = address of fully charged sparkle gfx effect
    lli     at, 0x0002                  // at = 2
    beql    t0, t2, pc() + 8            // if fully charged sparkle effect active, disable the effect
    sw      at, 0x0A34(t3)              // always force full charge sparkle off by not letting the sparkle counter decrement

    lw      t0, 0x004C(a0)              // t0 = timer value
    addiu   t0, t0, 0x0001              // t0 = timer value++
    sltiu   at, t0, DECLOAK             // at = 0 if end of cloaking reached
    beqz    at, _decloak                // if end of cloaking reached, then decloak
    sw      t0, 0x004C(a0)              // update timer value

    lhu     t2, 0x0026(t3)              // t2 = action
    sltiu   at, t2, 0x0004              // at = 1 if player just died
    bnez    at, _decloak               // if player died, then decloak
    // delay slot below runs always, intentionally

    lw      t2, 0x0048(a0)              // t2 = address of env color override value

    // set a 30 frame transition to invisible, and after that force value
    or      t4, r0, t0                  // t4 = frame
    sltiu   at, t0, TRANSITION          // at = 1 if within the transition to cloaking frames
    beqzl   at, pc() + 8                // if outside of the transition frames, cap at TRANSITION value
    lli     t4, TRANSITION              // t4 = TRANSITION

    lli     at, 0x0008                  // at = 8
    multu   t4, at                      // t4 * at is the amount to deduct from max opacity
    mflo    t4                          // t4 = amount to deduct from max opacity
    subu    t1, r0, t4                  // t1 = no less than FFFFFF00

    sltiu   at, t0, 0x0004              // at = 1 if within the first 4 frames
    bnez    at, _set_env_color          // if outside of the first 4 frames, adjust based on absolute speed below
    lw      t3, 0x0040(a0)              // t3 = player struct
    lwc1    f0, 0x008C(t3)              // f0 = X speed
    lwc1    f2, 0x0090(t3)              // f2 = Y speed
    mul.s   f0, f0, f0                  // f0 = X speed squared
    mul.s   f2, f2, f2                  // f2 = Y speed squared
    add.s   f2, f0, f2                  // f2 = X speed squared + Y speed squared
    sqrt.s  f0, f2                      // f0 = absolute speed
    trunc.w.s f0, f0                    // f0 = absolute speed, int
    mfc1    t4, f0                      // t4 = absolute speed
    addu    t1, t1, t4                  // add opacity
    bgezl   t1, pc() + 8                // if we added too much opacity, then we need to max it out at 0xFFFFFFFF
    addiu   t1, r0, -0x0001             // t1 = 0xFFFFFFFF (max opacity)

    // here, create a flicker on some of the final frames
    lli     at, DECLOAK - 30            // at = final frame - 30
    beql    at, t0, _set_env_color      // if on this frame, add some opacity
    addiu   t1, t1, 0x0048
    lli     at, DECLOAK - 22            // at = final frame - 22
    beql    at, t0, _set_env_color      // if on this frame, add some opacity
    addiu   t1, t1, 0x0018
    lli     at, DECLOAK - 18            // at = final frame - 18
    beql    at, t0, _set_env_color      // if on this frame, add some opacity
    addiu   t1, t1, 0x0068
    lli     at, DECLOAK - 9             // at = final frame - 9
    beql    at, t0, _set_env_color      // if on this frame, add some opacity
    addiu   t1, t1, 0x0078
    lli     at, DECLOAK - 5             // at = final frame - 5
    beql    at, t0, _set_env_color      // if on this frame, add some opacity
    addiu   t1, t1, 0x0058

    _set_env_color:
    sll     t1, t1, 0x0018              // shift left...
    srl     t1, t1, 0x0018              // then shift right so we get 0x000000XX

    lw      t5, 0x0020(t2)              // t5 = env color state
    addiu   t6, r0, -0x0100             // t6 = 0xFFFFFF00
    beqzl   t5, _update_override        // if Normal, we'll want 0xFFFFFFXX
    or      t1, t1, t6                  // t1 = 0xFFFFFFXX
    lli     t6, CharEnvColor.state.CLOAKED
    beql    t5, t6, _update_override    // if Cloaked, we'll want 0xFFFFFFXX
    or      t1, t1, t6                  // t1 = 0xFFFFFFXX

    // if here, state is DARK or NONE, so we are good unless it's all 0
    beqzl   t1, _update_override        // if 0, we will add 1 so we don't make opaque instead (by disabling override)
    addiu   t1, t1, 0x0001              // t1++

    _update_override:
    sw      t1, 0x0000(t2)              // set env color for character

    jr      ra
    nop

    _decloak:
    lw      t1, 0x0048(a0)              // t1 = address of env color override value

    addiu   t2, r0, -0x00FF             // t2 = 0xFFFFFF01 (None)
    addiu   t3, r0, 0x00FF              // t3 = 0x000000FF (Dark)
    addiu   t4, r0, -0x00F0             // t4 = 0xFFFFFF10 (Cloaked)

    lw      t5, 0x0020(t1)              // t5 = env color state
    beqzl   t5, _update_cloaked_flag    // if Normal, clear override
    sw      r0, 0x0000(t1)              // clear env color override
    lli     t6, CharEnvColor.state.NONE
    beql    t5, t6, _update_cloaked_flag // if None, set override accordingly
    sw      t2, 0x0000(t1)              // set env color override
    lli     t6, CharEnvColor.state.DARK
    beql    t5, t6, _update_cloaked_flag // if Dark, set override accordingly
    sw      t3, 0x0000(t1)              // set env color override

    // if here, cloaked - not sure how to handle just yet!
    sw      t4, 0x0000(t1)              // set env color override p1

    _update_cloaked_flag:
    sb      r0, 0x0000(t8)              // update cloaked flag to FALSE

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
// Prevents cloaked players from taking damage
scope prevent_damage_when_cloaked_: {
    OS.patch_start(0x65A68, 0x800EA268)
    j       prevent_damage_when_cloaked_
    addiu   a2, a2, 0x50E8              // original line 1
    _return:
    OS.patch_end()

    // a0 = player struct
    // t9 = port
    // t6 = current damage
    // t7 = new damage
    // a1 = move damage

    li      t8, cloaked_players         // t8 = cloaked_players
    addu    t8, t8, t9                  // t8 = address of cloaked flag for this player
    lbu     t8, 0x0000(t8)              // t8 = 1 if cloaked, 0 if not
    beqz    t8, _end                    // if cloaked, new damage = current damage
    nop
    or      t7, t6, r0                  // t7 = current damage
    lli     a1, 0x0000                  // a1 = 0 (move damage)

    _end:
    j       _return
    sw      t7, 0x002C(a0)              // original line 2
}

// @ Description
// Prevents cloaked players from having a drop shadow
scope prevent_shadow_when_cloaked_: {
    OS.patch_start(0xB5A14, 0x8013AFD4)
    jal     prevent_shadow_when_cloaked_
    lhu     t7, 0x018C(v0)              // original line 1
    OS.patch_end()

    andi    t6, t7, 0x0001              // original line 2

    // v0 = player struct
    // t6 is used to determine whether to render the drop shadow

    li      t7, cloaked_players         // t7 = cloaked_players
    lbu     t9, 0x000D(v0)              // t9 = port id
    addu    t7, t7, t9                  // t7 = address of cloaked flag for this player
    lbu     t7, 0x0000(t7)              // t7 = 1 if cloaked, 0 if not
    bnezl   t7, _end                    // if cloaked, then set as t6
    or      t6, t7, r0                  // t6 = t7 = do not render

    _end:
    jr      ra
    nop
}

// @ Description
// Clears the effects of active cloaking devices.
scope clear_active_cloaking_devices_: {
    li      t8, cloaked_players         // t8 = cloaked_players
    sw      r0, 0x0000(t8)              // clear cloaked flags

    li      t0, CharEnvColor.override_table
    li      t1, CharEnvColor.state_table

    addiu   t2, r0, -0x00FF             // t2 = 0xFFFFFF01 (None)
    addiu   t3, r0, 0x00FF              // t3 = 0x000000FF (Dark)
    addiu   t4, r0, -0x00F0             // t4 = 0xFFFFFF10 (Cloaked)

    lw      t5, 0x0000(t1)              // t2 = p1 state
    beqzl   t5, _p2                     // if Normal, clear override
    sw      r0, 0x0000(t0)              // clear env color override p1
    lli     t6, CharEnvColor.state.NONE
    beql    t5, t6, _p2                 // if None, set override accordingly
    sw      t2, 0x0000(t0)              // set env color override p1
    lli     t6, CharEnvColor.state.DARK
    beql    t5, t6, _p2                 // if Dark, set override accordingly
    sw      t3, 0x0000(t0)              // set env color override p1

    // if here, cloaked - not sure how to handle just yet!
    sw      t4, 0x0000(t0)              // set env color override p1

    _p2:
    lw      t5, 0x0004(t1)              // t2 = p2 state
    beqzl   t5, _p3                     // if Normal, clear override
    sw      r0, 0x0004(t0)              // clear env color override p2
    lli     t6, CharEnvColor.state.NONE
    beql    t5, t6, _p3                 // if None, set override accordingly
    sw      t2, 0x0004(t0)              // set env color override p2
    lli     t6, CharEnvColor.state.DARK
    beql    t5, t6, _p3                 // if Dark, set override accordingly
    sw      t3, 0x0004(t0)              // set env color override p2

    // if here, cloaked - not sure how to handle just yet!
    sw      t4, 0x0004(t0)              // set env color override p1

    _p3:
    lw      t5, 0x0008(t1)              // t2 = p3 state
    beqzl   t5, _p4                     // if Normal, clear override
    sw      r0, 0x0008(t0)              // clear env color override p3
    lli     t6, CharEnvColor.state.NONE
    beql    t5, t6, _p4                 // if None, set override accordingly
    sw      t2, 0x0008(t0)              // set env color override p3
    lli     t6, CharEnvColor.state.DARK
    beql    t5, t6, _p4                 // if Dark, set override accordingly
    sw      t3, 0x0008(t0)              // set env color override p3

    // if here, cloaked - not sure how to handle just yet!
    sw      t4, 0x0008(t0)              // set env color override p1

    _p4:
    lw      t5, 0x000C(t1)              // t2 = p4 state
    beqzl   t5, _end                    // if Normal, clear override
    sw      r0, 0x000C(t0)              // clear env color override p4
    lli     t6, CharEnvColor.state.NONE
    beql    t5, t6, _end                // if None, set override accordingly
    sw      t2, 0x000C(t0)              // set env color override p4
    lli     t6, CharEnvColor.state.DARK
    beql    t5, t6, _end                // if Dark, set override accordingly
    sw      t3, 0x000C(t0)              // set env color override p4

    // if here, cloaked - not sure how to handle just yet!
    sw      t4, 0x000C(t0)              // set env color override p1

    _end:
    jr      ra
    nop
}
