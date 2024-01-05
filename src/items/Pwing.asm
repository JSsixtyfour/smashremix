// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(Item.spawn_custom_item_based_on_tomato_)
constant SHOW_GFX_WHEN_SPAWNED(OS.TRUE)
constant PICKUP_ITEM_MAIN(pickup_pwing)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0x801745FC)
constant THROW_ITEM(0)
constant PLAYER_COLLISION(0)

// @ Description
// Offset to item in file 0xFB.
constant FILE_OFFSET(0x1060)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x0                                  // 0x00 - item ID (will be updated by Item.add_item
dw 0x8018D040                           // 0x04 - hard-coded pointer to file 0xFB
dw FILE_OFFSET                          // 0x08 - offset to item footer in file 0xFB
dw 0x1C000000                           // 0x0C - (value - 1 * 4) + 0x8003DC24 = pointer to draw-related routine, 0x1C = no billboarding and transforms permitted

dw 0                                    // 0x10 - hitbox enabler/offset (0 = none, appends to 0x10C)
dw 0x801744C0                           // 0x14 - spawn behaviour routine (tomato, appends to 0x378)
dw 0x80174524                           // 0x18 - ground transition routine  (appends to 0x37C)
dw 0                                    // 0x1C - hurtbox collision routine (appends to 0x380)

dw 0                                    // 0x20 - collide with shield (appends to 0x384)
dw 0                                    // 0x24 - collide with shield edge (appends to 0x388)
dw 0                                    // 0x28 - collide with hitbox ( appends to 0x38C)
dw 0                                    // 0x2C - collide with reflector (appends to 0x390)

item_state_table:
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
// Duration of Pwing item
constant PWING_DURATION(20*60)          // duration = 20 seconds
constant GFX_ROUTINE(0x7A)              // custom gfx routine index
constant JUMP_COOLDOWN(27)              // minimum frames between Pwing jumps
                                        // note: Kirby and DDD mid-air Jump animation is 28 frames, Jiggly is 25

// @ Description
// Main item pickup routine for Pwing.
scope pickup_pwing: {

    OS.save_registers()
    // check if player already has a Pwing
    li      t0, players_with_pwing
    lbu     t1, 0x000D(a0)              // t1 = port
    sll     t2, t1, 0x0002              // t2 = offset to player entry
    addu    t0, t0, t2                  // t0 = address of players pwing
    lw      t3, 0x0000(t0)              // get current value
    bnez    t3, _duplicate_pwing        // skip pwing setup if there is already a pwing
    sw      t0, 0x0020(sp)              // save address of players pwing

    // setup pwing
    li      at, GFXRoutine.port_override.override_table // load override table for gfx routines
    addu    t2, at, t2                  // get address of player entry in gfx override table
    addiu   t7, r0, GFX_ROUTINE
    sw      t7, 0x0000(t2)              // save pwing gfx routine in override table
    sw      at, 0x0A28(a0)              // save gfx routine to player struct (todo: this is a typo but it works?)
    Render.register_routine(handle_active_pwing_)    // register routine that handles the countdown
    // v0 = routine handler
    lw      a0, 0x0010(sp)              // a0 = player struct
    lw      a2, 0x0018(sp)              // a2 = item object
    lw      t0, 0x0020(sp)              // t0 = players_with_pwing table
    sw      a0, 0x0040(v0)              // save player struct in handler object
    sw      a2, 0x0044(v0)              // save item struct in handler object
    sw      t0, 0x0048(v0)              // save address of players pwing
    sw      v0, 0x0000(t0)              // save routine handler to players pwing entry
    addiu   at, r0, PWING_DURATION
    sh      at, 0x004C(v0)              // save timer value to handler obj
    b       _end
    nop

    _duplicate_pwing:
    addiu   at, r0, PWING_DURATION
    sh      at, 0x004C(t3)              // overwrite duration

    _end:
    FGM.play(0x559)                     // play fgm (pwing pickup)
    OS.restore_registers()

    // Continue after damage restore routine in tomato/heart pickup routine
    sw      a2, 0x0018(sp)              // save a2 to where the rest of the routine expects it
    j       0x80145C4C
    sw      a3, 0x001C(sp)              // save a3 to where the rest of the routine expects it
}

// @ Description
// handles an active Pwing. No Pwing item exists at this point.
scope handle_active_pwing_: {
    addiu   sp, sp, -0x24           // allocate sp
    sw      ra, 0x0014(sp)          // store registers
    sw      a0, 0x0020(sp)          // save routine handler
    sw      s1, 0x0004(sp)

    // 0x0034(a0) gfx routine
    // 0x0038(a0) reflect flag
    // 0x003C(a0) reflect hitbox struct
    // 0x0040(a0) player struct
    // 0x0044(a0) item struct
    // 0x0048(a0) pointer to player entry in Pwing array
    // 0x004C(a0) timer
    lw      a0, 0x0020(sp)          // a0 = handler object
    lw      a1, 0x0040(a0)          // a1 = item owner struct

    lbu     t1, 0x000D(a1)          // t1 = port
    li      t0, pwing_jump_flag     // pwing_jump_flag
    addu    t0, t0, t1              // t0 = address of pwing jump flag for this player

    lw      v0, 0x0024(a1)          // v0 = players current action
    sltiu   t2, v0, Action.Idle     // t2 = 1 if action id < 10
    bnezl   t2, _destroy_pwing      // destroy pwing if player is dead
    sb      r0, 0x0000(t0)          // set pwing flag to FALSE

    lb      t2, 0x0148(a1)          // t2 = number of jumps used (0 if on ground)

    beqzl   t2, subtract_timer      // branch if no jumps have been used
    sb      r0, 0x0000(t0)          // set pwing flag to FALSE

    // safety check (this value is usually same as above)
    lw      at, 0x014C(a1)          // load kinetic state (0 if on ground)
    beqzl   at, subtract_timer      // branch if on ground
    sb      r0, 0x0000(t0)          // set pwing flag to FALSE

    // Set the number of jumps required before Pwing activates based on the total number of jumps the character has
    lw      at, 0x09C8(a1)          // load attribute struct
    lw      at, 0x0064(at)          // at = number of jumps
    addiu   t8, r0, 2               // t8 = 2 (standard midair jump)
    bnel    at, t8, pc() + 8        // set appropriate value based on the total number of jumps the character has
    addiu   t8, r0, 4               // t8 = 4 (3rd midair jump)
    // Separate check for Marina
    lw      at, 0x0008(a1)          // at = character id
    lli     t1, Character.id.MARINA // t1 = id.NMARINA
    beql    at, t1, _check_action   // branch if Marina
    addiu   t8, r0, 3               // t8 = 3 (2nd midair jump)
    lli     t1, Character.id.NMARINA // t1 = id.NMARINA
    beql    at, t1, _check_action   // branch if Polygon Marina
    addiu   t8, r0, 3               // t8 = 3 (2nd midair jump)

    _check_action:
    addiu   at, r0, Action.FallSpecial
    beql    v0, at, subtract_timer    // skip if player is in special fall
    sb      r0, 0x0000(t0)            // set pwing flag to FALSE
    addiu   at, r0, Action.CliffCatch
    beql    v0, at, subtract_timer    // skip if player is grabbing ledge
    sb      r0, 0x0000(t0)            // set pwing flag to FALSE
    addiu   at, r0, Action.InhaleWait
    beql    v0, at, subtract_timer    // skip if player has been inhaled by Kirby or DDD
    sb      r0, 0x0000(t0)            // set pwing flag to FALSE
    addiu   at, r0, Action.EggLay
    beql    v0, at, subtract_timer    // skip if player is in a Yoshi egg
    sb      r0, 0x0000(t0)            // set pwing flag to FALSE

    // check if current action is ceiling bonk (note that multi-jump characters don't)
    _check_bonk:
    lb      at, 0x0000(t0)            // at = 1 if we are currently jumping via pwing
    beqz    at, _check_fall           // branch accordingly (only check for pwing jump bonks)
    addiu   at, r0, Action.CeilingBonk
    bne     v0, at, _check_fall       // branch if player is not bonking
    addiu   at, r0, 2                 // at = 2 (bonked)
    sb      at, 0x0000(t0)            // set pwing flag to indicate that we bonked
    // Separate check for Marina
    addiu   t8, r0, 6                 // t8 = 6 (Marina's jump count)
    lw      at, 0x0008(a1)            // at = character id
    lli     t1, Character.id.MARINA   // t1 = id.NMARINA
    beql    at, t1, subtract_timer    // update jump count if Marina (so none remain)
    sb      t8, 0x0148(a1)            // ~
    lli     t1, Character.id.NMARINA  // t1 = id.NMARINA
    beql    at, t1, subtract_timer    // update jump count if Polygon Marina (so none remain)
    sb      t8, 0x0148(a1)            // ~

    b       subtract_timer            // skip because player is not jumping
    nop

    _check_fall:
    // handle so we can't spam it immediately from 'Fall' or 'FallAerial' after bonking (headache)
    addiu   at, r0, Action.Fall
    beq     v0, at, pc() + 16          // branch accordingly
    addiu   at, r0, Action.FallAerial
    bne     v0, at, _check_midair_jump // branch accordingly
    nop
    _check_if_we_bonked:
    lb      at, 0x0000(t0)             // at = pwing flag value
    addiu   t1, r0, 2                  // t2 = 2 (bonked)
    bne     at, t1, _check_midair_jump // branch if we didn't bonk
    nop
    // cooldown guarantees we will have at least 1 frame of JumpAerial between CeilingBonks
    lw      at, 0x001C(a1)             // at = current frame
    sltiu   at, at, 6                  // at = 1 if jump frame < 7
    bnez    at, subtract_timer         // branch if we haven't waited long enough
    nop

    _check_midair_jump:
    // check if current action is a mid-air jump
    addiu   at, r0, Action.JumpAerialF
    beq     v0, at, _is_jumping       // branch if player is jumping
    addiu   at, r0, Action.JumpAerialB
    beq     v0, at, _is_jumping       // branch if player is jumping
    nop

    // separate check for multi-jump characters (Kirby, Jigglypuff, Dedede) which uses a different value
    _check_multi_jump:
    sltiu   at, t8, 4                  // at = 1 if not using multi-jump character (t8 is number of jumps required)
    bnez    at, _check_jumps_remaining // branch accordingly
    // note: these Actions all have the same value, so all 3 characters currently take first branch
    addiu   at, r0, Action.KIRBY.Jump3
    beq     v0, at, _is_jumping       // branch if player is jumping (Pwing setup at Jump3)
    addiu   at, r0, Action.KIRBY.Jump4
    beq     v0, at, _is_jumping       // branch if player is jumping (Pwing remains at Jump4)
    addiu   at, r0, Dedede.Action.JUMP_4
    beq     v0, at, _is_jumping       // branch if player is jumping
    addiu   at, r0, Action.JIGGLY.Jump4
    beq     v0, at, _is_jumping       // branch if player is jumping
    nop
    // safety check for other jump actions (just in case)
    addiu   at, r0, Action.KIRBY.Jump5
    beq     v0, at, _is_jumping       // branch if player is jumping
    addiu   at, r0, Action.KIRBY.Jump6

    // handle if jump count went straight from 0 to 2 (e.g. after a grounded USP)
    _check_jumps_remaining:
    slt     at, t2, t8                // at = 1 if current jumps used < required value
    beqz    at, _apply_pwing          // enable pwing if no jumps are left
    nop
    // handle if jump animation got interrupted before cooldown frame
    lb      at, 0x0000(t0)            // at = 1 if we are currently jumping via pwing
    bnez    at, _apply_pwing
    nop
    b       subtract_timer            // skip if player is not jumping
    nop

    _is_jumping:
    lb      at, 0x0000(t0)            // at = 1 if we are currently jumping via pwing
    beqz    at, _apply_pwing          // branch accordingly (only play sound effect for subsequent jumps)
    nop
    slt     t2, t2, t8                // t2 = 1 if current jumps used < required value
    bnez    t2, subtract_timer        // skip if we have jumps remaining to go through (so we don't spam sound effect)
    nop

    // // check if Jigglypuff (or a variant thereof) which uses a different jump cooldown value
    // // note: this check is no longer needed, but i didn't feel like erasing it
    // lw      at, 0x0008(a1)           // at = character id
    // lli     t2, Character.id.JIGGLY  // t2 = id.JIGGLY
    // beql    at, t2, _apply_pwing     // branch accordingly
    // lli     t1, JUMP_COOLDOWN - 3    // t1 = JUMP_COOLDOWN (modified for Jigglypuff)
    // lli     t2, Character.id.JPUFF   // t2 = id.JPUFF (PURIN)
    // beql    at, t2, _apply_pwing     // branch accordingly
    // lli     t1, JUMP_COOLDOWN - 3    // ~
    // lli     t2, Character.id.EPUFF   // t2 = id.EPUFF
    // beql    at, t2, _apply_pwing     // branch accordingly
    // lli     t1, JUMP_COOLDOWN - 3    // ~
    // lli     t2, Character.id.NJIGGLY // t2 = id.NJIGGLY
    // beql    at, t2, _apply_pwing     // branch accordingly
    // lli     t1, JUMP_COOLDOWN - 3    // ~

    // if we're here, use regular cooldown value
    lli     t1, JUMP_COOLDOWN        // t1 = JUMP_COOLDOWN

    _check_frame:
    lw      at, 0x001C(a1)          // at = current frame
    beqz    at, _pwing_sfx          // branch if on frame 1 of jump animation
    addiu   t2, r0, 2               // check if using a multi-jump character...
    bne     t2, t8, _apply_pwing    // ...in which case we skip cooldown check
    nop

    _jump_cooldown:
    slt     at, at, t1              // at = 1 if jump frame < JUMP_COOLDOWN (27)
    bnez    at, subtract_timer      // skip if we jumped too recently...
    nop
    b       _apply_pwing            // ...otherwise continue
    nop

    _pwing_sfx:
    lh      v0, 0x004C(a0)          // v0 = timer value
    sltiu   v0, v0, 60 * 3          // v0 = 1 if timer < 3 seconds
    beqzl   v0, pc() + 12           // set pwing fgm based on the time remaining
    lli     v0, 0x558               // normal fgm
    lli     v0, 0x55B               // low time fgm

    OS.save_registers()
    jal     0x800269C0              // play fgm (pwing)
    or      a0, r0, v0
    OS.restore_registers()
    // lw      a0, 0x0020(sp)          // a0 = handler object (restore)
    b       subtract_timer
    nop

    _apply_pwing:
    lli     at, OS.TRUE             // at = TRUE
    sb      at, 0x0000(t0)          // set pwing flag to TRUE (for next time)
    // then set jump to 1 and keep at 1 (i.e. infinite midair jumps)
    addiu   t2, t8, -1              // t2 = t8 - 1 (1 for regular, 3 for multi-jump)
    sb      t2, 0x0148(a1)          // update number of jumps used

    subtract_timer:
    lh      v0, 0x004C(a0)          // v0 = timer value
    addiu   t8, v0, 0xffff          // timer -= 1
    addiu   at, r0, 0x0001
    bne     v0, at, _end            // don't destroy if timer value not 1
    sh      t8, 0x004C(a0)          // save timer

    _destroy_pwing:
    // remove any lingering jumps when timer runs out
    lb      at, 0x0000(t0)          // at = 1 if we are currently jumping via pwing
    beqz    at, _play_destroy_sfx
    lb      t2, 0x0148(a1)          // t2 = number of jumps used
    beqz    t2, _play_destroy_sfx   // branch if no jumps have been used (safety check)
    lw      at, 0x09C8(a1)          // load attribute struct
    lw      at, 0x0064(at)          // at = number of jumps
    addiu   t2, r0, 2               // t2 = 2 (standard midair jump)
    bnel    at, t2, pc() + 8        // set appropriate value based on the total number of jumps the character has
    addiu   t2, r0, 4               // t2 = 4 (3rd midair jump)
    sb      t2, 0x0148(a1)          // update number of jumps used

    _play_destroy_sfx:
    OS.save_registers()
    FGM.play(0x55A)                 // play fgm (pwing end)
    OS.restore_registers()
    lw      at, 0x0048(a0)          // at = pointer to players index in Pwing array
    sw      r0, 0x0000(at)          // remove player from Pwing array
    sw      v0, 0x0000(at)          // clear player from Pwing array (-1)
    sb      r0, 0x0000(t0)          // clear pwing flag

    // remove player gfx, based on star
    _destroy_branch_1:
    li      at, players_with_pwing
    lbu     t1, 0x000D(a1)              // t1 = port
    sll     t2, t1, 0x0002              // t2 = offset to player entry
    addu    t0, at, t2                  // t0 = address of players gfx routine
    sw      r0, 0x0000(t0)
    li      at, GFXRoutine.port_override.override_table
    addu    t0, at, t2                  // t0 = address of players gfx routine
    addiu   at, r0, GFX_ROUTINE         // at = Pwing gfx routine index
    lw      t1, 0x0000(t0)              // t1 = current players override gfx routine
    bne     at, t1, _destroy_branch_2   // branch if Pwing gfx routine is not here
    lw      a0, 0x0004(a1)              // a0 = player object
    jal     0x800E98D4                  // run players default gfx routine
    sw      r0, 0x0000(t0)              // remove Pwing gfx override flag

    _destroy_branch_2:
    jal     Render.DESTROY_OBJECT_
    lw      a0, 0x0020(sp)              // argument = routine handler

    _end:
    lw      s1, 0x0004(sp)              //
    lw      ra, 0x0014(sp)              // restore registers
    jr      ra                          // return
    addiu   sp, sp, 0x24                // deallocate sp
}

// @ Description
// Clears the pointers for Pwing users
scope clear_active_pwings_: {
    li      t8, players_with_pwing      // t8 = array to clear
    sw      r0, 0x0000(t8)              // clear ptrs
    sw      r0, 0x0004(t8)              // ~
    sw      r0, 0x0008(t8)              // ~
    sw      r0, 0x000C(t8)              // ~
    li      t8, pwing_jump_flag         // t8 = array to clear
    jr      ra
    sw      r0, 0x0000(t8)              // clear ptrs
}

// @ Description
// stores player struct
players_with_pwing:
dw 0, 0, 0, 0

// @ Description
// stores flag to indicate that we are currently jumping with pwing
pwing_jump_flag:
db 0, 0, 0, 0

