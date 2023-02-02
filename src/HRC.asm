// HRC.asm
if !{defined __HRC__} {
define __HRC__()
print "included HRC.asm\n"

include "Global.asm"

// This file handles much of the custom logic for Home-Run Contest.

scope HRC {
    constant BAT_SPAWN(0xC6B01C00)                  // -22542
    constant DEFAULT_CAMERA_X(0xC6A68000)           // -21312
    constant START_X(0xC6978000)                    // -19392
    constant UNITS_PER_FOOT_TENTH(0x4111EB85)       // 9.12 units/0.1 ft
    constant CAMERA_WARP_THRESHOLD(0x4643C000)      // 12528 = 350 ft * UNITS_PER_FOOT_TENTH + START_X
    constant CAMERA_WARP_DISTANCE(0xC60E8000)       // -9120 = -100 ft

    constant PROJECTILE_LEFT_THRESHOLD(0xC4900000)  // -1152 = 200 ft * UNITS_PER_FOOT_TENTH + START_X
    constant PROJECTILE_WARP_WINDOW(0x468E8000)     // 18240 = 200 ft
    constant PROJECTILE_LEFT_PADDING(0xC58E8000)    // -4560 = -50 ft

    constant COMPLETE_TIMER_START(45)

    constant CLOUD_START(0xC0F027C0)           // -7.505
    constant CLOUD_WARP_THRESHOLD(0xC3AB40A4)  // -342.505
    constant CLOUD_WARP_DISTANCE(0x43A78000)   // 335

    // @ Description
    // Distance sandbag has traveled
    distance:
    dw 0

    // @ Description
    // Distance warped, which helps calculate total distance
    warp_distance:
    dw 0

    // @ Description
    // Timer before showing COMPLETE to allow sandbag to stand up
    complete_timer:
    dw 0

    // @ Description
    // Holds string object pointers so we can control placement/size
    counter_string:
    dw 0
    metric_string:
    dw 0

    // @ Description
    // This runs every frame and handles camera movement as well as tracking distance
    scope main_: {
        OS.save_registers()

        // Move camera to track sandbag
        li      at, Global.p_struct_head
        lw      at, 0x0000(at)                // at = first player struct
        lli     t2, 0x0005                    // t2 = 5 = CPU, no movement
        _get_player_type:
        lw      t1, 0x0004(at)                // t1 = player object
        beqz    t1, _next                     // if no player object, get next player struct
        lbu     t1, 0x0023(at)                // t1 = player type (0 = HMN, 5 = Sandbag)
        beqzl   t1, pc() + 8                  // if human player, set t9
        or      t9, at, r0                    // t9 = human player struct
        beql    t1, t2, pc() + 8              // if sanbag, set t0
        or      t0, at, r0                    // t0 = sandbag player struct
        _next:
        lw      at, 0x0000(at)                // at = next player struct
        bnez    at, _get_player_type          // loop over all player structs
        nop

        lw      t1, 0x0078(t0)                // t1 = position struct
        lwc1    f0, 0x0000(t1)                // f0 = X position
        li      at, START_X
        mtc1    at, f2                        // f2 = START_X
        li      t2, Camera.hrc
        li      t3, DEFAULT_CAMERA_X          // t3 = DEFAULT_CAMERA_X
        c.lt.s  f0, f2                        // check if X position is less than START_X
        li      t8, _failure                  // assume failure
        mtc1    r0, f4                        // f4 = 0 = warp distance
        lli     s0, OS.FALSE                  // s0 = 0 = not at or beyond START_X
        bc1fl   pc() + 8                      // if we're at or beyond START_X, set s0 to 1
        lli     s0, OS.TRUE                   // s0 = 1 = at or beyond START_X

        beqzl   s0, _update_camera_x          // if we're not at or beyond START_X, use default
        mtc1    t3, f0                        // f0 = DEFAULT_CAMERA_X

        // Track distance
        sub.s   f4, f0, f2                    // f4 = difference between player X and START_X
        li      at, warp_distance
        lwc1    f2, 0x0000(at)                // f2 = warp distance
        add.s   f4, f4, f2                    // f4 = distance traveled in units
        li      at, UNITS_PER_FOOT_TENTH
        mtc1    at, f2                        // f2 = units per foot
        div.s   f6, f4, f2                    // f6 = distance in feet... div takes 29 cycles, so we'll save later

        // Smoothly pan the camera until the sandbag is centered
        lwc1    f2, 0x0000(t2)                // f2 = current camera X position
        sub.s   f0, f0, f2                    // f0 = difference between camera X and player X
        lui     at, 0x4100                    // at = 3 (fp)
        mtc1    at, f4                        // f4 = 3
        div.s   f0, f0, f4                    // f0 = distance to 1/3 point
        add.s   f0, f2, f0                    // f0 = 1/3 point between camera X and player X

        li      at, distance
        trunc.w.s f6, f6                      // f6 = distance, integer
        swc1    f6, 0x0000(at)                // save distance
        li      t8, _complete                 // past START_X we are no longer a failure

        _check_warp:
        li      at, CAMERA_WARP_THRESHOLD
        mtc1    at, f2                        // f2 = CAMERA_WARP_THRESHOLD
        c.lt.s  f0, f2                        // check if camera is too far right and needs to be warped left
        mtc1    r0, f4                        // f4 = 0 = warp distance
        li      at, CAMERA_WARP_DISTANCE
        bc1t    _update_camera_x              // if we're not beyond warp threshold, don't set warp distance
        nop

        mtc1    at, f4                        // f4 = CAMERA_WARP_DISTANCE
        li      at, warp_distance
        lwc1    f2, 0x0000(at)                // f2 = warp distance
        sub.s   f2, f2, f4                    // f2 = updated warp distance
        swc1    f2, 0x0000(at)                // update warp distance

        // update signs
        lw      a3, 0x0054(a0)                // a3 = 4th sign 00/X00 image struct
        lw      a2, 0x0000(a3)                // a2 = 4th sign hundreds/thousands digit image struct
        lw      a1, 0x0000(a2)                // a1 = 4th sign thousands/ten thousands digit image struct
        lh      t4, 0x0080(a1)                // t4 = current thousands/ten thousands index
        lh      t5, 0x0080(a2)                // t5 = current hundreds/thousands index
        lh      t6, 0x0080(a3)                // t6 = current 00/X00 index

        lw      at, 0x0050(a0)                // at = sign state (0 = under 10k; 1 = 10k - 99.9k; 2 = 99,999)
        lli     t3, 0x0002                    // t3 = 2 = 99,999
        beq     at, t3, _99999                // if we got this far, stop updating the signs
        nop
        beqzl   at, pc() + 8                  // if under 10k, increment hundreds/thousands index
        addiu   t5, t5, 0x0001                // t5++
        lli     t3, 0x0001                    // t3 = 1 = 10k-99.9k sign state
        beql    at, t3, pc() + 8              // if sign state is 10k-99.9k, increment 00/X00 index
        addiu   t6, t6, 0x0001                // t6++

        lli     t3, 0x000B                    // t3 = 11
        beql    t6, t3, pc() + 8              // if 00/X00 is >900, increment hundreds/thousands index
        addiu   t5, t5, 0x0001                // t5++

        lli     t7, 0x000A                    // t7 = 10
        beql    t5, t7, pc() + 8              // if t5 = 10, increment thousands/ten thousands index
        addiu   t4, t4, 0x0001                // t4++

        beql    t4, t7, pc() + 8              // if t4 = 10, increment sign state
        addiu   at, at, 0x0001                // at = 1 if 10k-99.k, 2 if 99,999

        beql    t6, t3, pc() + 8              // if t6 = 11, reset 00/X00 index
        lli     t6, 0x0001                    // t5 = 000
        beql    t5, t7, pc() + 8              // if t5 = 10, reset hundreds/thousands index
        lli     t5, 0x0000                    // t5 = 0
        bne     t4, t7, _update_signs         // if t4 != 10, skip resetting thousands/ten thousands index
        nop
        lli     t4, 0x0001                    // t4 = 1
        bne     at, t4, _99999                // if at = 2, then we are in the 99,999 case
        nop
        b       _update_signs
        lli     t6, 0x0001                    // t6 = 000

        _99999:
        lli     t4, 0x0009                    // t4 = 9
        lli     t5, 0x0009                    // t5 = 9
        lli     t6, 0x000B                    // t6 = 999

        _update_signs:
        sh      t4, 0x0080(a1)                // update thousands/ten thousands index
        sh      t5, 0x0080(a2)                // update hundreds/thousands index
        sh      t6, 0x0080(a3)                // update 00/X00 index
        sw      at, 0x0050(a0)                // update sign state

        _update_camera_x:
        add.s   f0, f0, f4                    // f0 = updated camera position
        swc1    f0, 0x0000(t2)                // update frozen camera table X
        swc1    f0, 0x000C(t2)                // update frozen camera table focal X

        lwc1    f0, 0x0000(t1)                // f0 = sandbag X position
        add.s   f0, f0, f4                    // f0 = updated sandbag X position
        swc1    f0, 0x0000(t1)                // update sandbag X position

        jal     update_projectile_and_hmn_positions_
        nop

        lui     t4, 0x8013
        bnezl   s0, pc() + 8                  // if we're at or beyond START_X, turn off magnifying glass
        sb      r0, 0x1580(t4)                // turn off magnifying glass

        // animate clouds
        lui     t4, 0x8004
        lw      t4, 0x6800(t4)                // t4 = background object
        beqzl   s0, _update_cloud_scroll_speed // if we're not at or beyond START_X, don't animate clouds
        mtc1    r0, f2                        // f2 = 0

        lwc1    f2, 0x008C(t0)                // f2 = X speed
        li      at, 0xBA83126F                // at = -0.001
        mtc1    at, f4                        // f4 = -0.001
        mul.s   f2, f2, f4                    // f2 = cloud scroll speed
        _update_cloud_scroll_speed:
        swc1    f2, 0x0044(t4)                // update cloud scroll speed

        _check_failure_complete:
        // Check time
        li      at, 0x800A4B18
        lw      at, 0x0018(at)                // at = frames elapsed
        sltiu   at, at, 0x0258                // at = 1 if less than ten seconds
        beqz    at, _check_sandbag_moving     // if no time remaining, we need to check if we should stop
        lw      t2, 0x014C(t0)                // t2 = kinetic state (0 = grounded, 1 = aerial)
        bnez    s0, _check_sandbag_moving     // if we're at or beyond START_X, we should stop if the sandbag is grounded
        nop

        // if we're here, there is time remaining but we're not past START_X, so we should stop if the sandbag is grounded off the plat
        lw      t1, 0x00EC(t0)                // t1 = clipping ID of the surface directly below the sandbag
        beqz    t1, _return                   // if we're over the platform, then we can keep going
        nop                                   // otherwise we'll check if grounded and not moving

        _check_sandbag_moving:
        // DK cargo hold is a special case: if time is up, we stop if stuck in cargo hold
        bnez    at, _check_grounded           // if time remaining, don't check cargo hold
        lw      t1, 0x0024(t0)                // t1 = sandbag action
        lli     t5, Action.ThrownDK           // t5 = Action.ThrownDK
        bne     t1, t5, _check_grounded       // if not getting thrown by DK, JDK, or GDK, skip
        lw      t1, 0x0024(t9)                // t1 = human player action
        lli     t5, Action.DK.Cargo           // t5 = Action.DK.Cargo
        beq     t1, t5, _do_failure_or_complete // if in cargo hold, do failure/complete
        nop

        _check_grounded:
        // first, check if sandbag is grounded
        bnez    t2, _return                   // if sandbag is in the air, we're good to keep rollin'!
        lw      t2, 0x008C(t0)                // t2 = X speed

        // then, check if sandbag is moving
        bnez    t2, _disable_inputs           // if sandbag is still moving, don't stop yet! but disable inputs
        nop

        // if time is up and sandbag is before START_X, we'll need to check HMN player action to let attacks continue
        bnez    at, _do_failure_or_complete   // if time remaining, don't check player action
        nop
        bnez    s0, _do_failure_or_complete   // if we're at or beyond START_X, don't check player action
        nop

        lw      t1, 0x0024(t9)                // t1 = human player action
        li      t5, action_table              // t5 = action_table
        lhu     t2, 0x0000(t5)                // t2 = action_table value

        _begin_loop:
        // loops until the player's current action value matches an action value from the table
        // or if the end of the table is reached
        addiu   t5, 0x0002                    // increment action table address
        beq     t1, t2, _do_failure_or_complete // if action value is in table, don't let it continue
        lhu     t2, 0x0000(t5)                // t2 = action_table value(updated)
        bnez    t2, _begin_loop               // if t2 != 0, loop (loop until table value 0 reached)
        nop                                   // if no valid action found, fall through to failure/complete

        // if we're here, then let the current action complete before moving to complete/failure
        b       _return
        nop

        _do_failure_or_complete:
        jr      t8                            // jump to _failure or _complete
        nop

        _complete:
        li      at, complete_timer
        lw      t0, 0x0000(at)                // t0 = frames until we complete
        addiu   t1, t0, -0x0001               // t1 = t0 decremented

        // first time, calculate change in X for animation
        li      t5, counter_string            // t5 = counter_string pointer address
        lw      t2, 0x0000(t5)                // t2 = string object
        lw      t3, 0x0040(a0)                // t3 = change in X, if non-zero
        bnez    t3, _animate_counter          // if already set, skip
        nop
        lw      t3, 0x0074(t2)                // t3 = position struct
        lwc1    f0, 0x0058(t3)                // f0 = ulx
        lwc1    f2, 0x0058(t2)                // f2 = urx of counter string
        sub.s   f6, f2, f0                    // f6 = length of string
        li      t4, 0x3F39999A                // t4 = (1 + 0.45) / 2 = 0.725 = multiplier to get half length of string after scaling applied
        mtc1    t4, f4                        // f4 = (1 + 0.45) / 2 = 0.725 = multiplier to get half length of string after scaling applied
        mul.s   f6, f6, f4                    // f6 = half length of string after scaling applied
        lui     t4, 0x4148                    // t4 = .5 * length from last digit to end of "FT." after scaling applied
        mtc1    t4, f4                        // f4 = .5 * length from last digit to end of "FT." after scaling applied
        sub.s   f4, f6, f4                    // f2 = distance from center to urx after scaling applied
        lui     t4, 0x4320                    // t4 = 160 (center of screen)
        mtc1    t4, f0                        // f0 = 160 (center of screen)
        add.s   f0, f0, f4                    // f0 = final urx
        sub.s   f0, f2, f0                    // f0 = X distance to travel to be centered
        addiu   t4, t0, 0x0001                // t4 = frames remaining
        mtc1    t4, f2                        // f2 = frames remaining
        cvt.s.w f2, f2                        // f2 = frames remaining, floating point
        div.s   f0, f0, f2                    // f0 = change to X position (distance/time)
        swc1    f0, 0x0040(a0)                // save change in X

        // animate the counter to be centered and larger
        _animate_counter:
        lw      t2, 0x0000(t5)                // t2 = string object
        lwc1    f0, 0x0058(t2)                // f0 = X position
        lwc1    f2, 0x003C(t2)                // f2 = Y position
        lwc1    f4, 0x0044(t2)                // f4 = scale
        lwc1    f6, 0x0040(a0)                // f6 = change in X
        sub.s   f0, f0, f6                    // f0 = new X position
        lui     t3, 0x3F00                    // t3 = 0.5
        mtc1    t3, f6                        // f6 = 0.5
        add.s   f2, f2, f6                    // f0 = new Y position
        swc1    f0, 0x0058(t2)                // update X position
        li      t3, 0x3C23D70A                // t3 = 0.01
        mtc1    t3, f6                        // f6 = 0.01
        add.s   f4, f4, f6                    // f4 = new scale
        swc1    f2, 0x003C(t2)                // update Y position
        sw      r0, 0x0030(t2)                // trigger redraw
        sw      r0, 0x005C(t2)                // turn off blur
        swc1    f4, 0x0044(t2)                // update scale

        li      t4, metric_string
        bne     t5, t4, _animate_counter      // if we haven't animated the metric string, loop
        or      t5, t4, r0                    // t5 = metric_string pointer address

        bnez    t0, _return                   // if timer not done, skip
        sw      t1, 0x0000(at)                // update timer

        jal     0x80114D58                    // call game end complete
        addiu   a0, r0, 0x01CB                // a0 = Complete! FGM id
        b       _end
        nop

        _failure:
        li      at, complete_timer
        lw      t0, 0x0000(at)                // t0 = frames until we complete
        addiu   t1, t0, -0x0001               // t1 = t0 decremented

        bnez    t0, _return                   // if timer not done, skip
        sw      t1, 0x0000(at)                // update timer

        jal     0x80114C80                    // call game end failure
        nop
        b       _end
        nop

        _return:
        bnez    at, _end                      // if time remaining, don't disable inputs for HMN
        _disable_inputs:
        lli     t4, 0x0002                    // t4 = 2 = turn off inputs

        // Conker's NSP needs input enabled in order to release, so check for that
        lw      t2, 0x0008(t9)                // t2 = char_id
        lli     t3, Character.id.CONKER
        bne     t2, t3, _check_bowser         // if not Conker, skip
        lw      t1, 0x0024(t9)                // t1 = human player action
        lli     t3, Conker.Action.CatapultCharge
        beql    t1, t3, _set_inputs           // if Conker is currently doing Catapult Charge, don't disable inputs
        lli     t4, 0x0000                    // t4 = 0 = turn on inputs

        // Bowser's NSP needs input enabled in order to stop, so check for that
        _check_bowser:
        lli     t3, Character.id.BOWSER
        bne     t2, t3, _check_kirby          // if not Bowser, skip
        lli     t3, Bowser.Action.FireBreath
        beql    t1, t3, _set_inputs           // if Bowser is currently doing Fire Breath, don't disable inputs
        lli     t4, 0x0000                    // t4 = 0 = turn on inputs

        // Kirby's NSP needs input enabled in order to stop, so check for that
        _check_kirby:
        lli     t3, Character.id.KIRBY
        beq     t2, t3, _check_kirby_suck     // if Kirby, check if sucking
        lli     t3, Character.id.JKIRBY
        bne     t2, t3, _set_inputs           // if not J Kirby, skip
        nop

        _check_kirby_suck:
        lli     t3, Action.KIRBY.Inhale
        beql    t1, t3, _set_inputs           // if Kirby is currently sucking, don't disable inputs
        lli     t4, 0x0000                    // t4 = 0 = turn on inputs

        _set_inputs:
        lbu     t3, 0x018F(t9)                // t3 = current flags
        andi    t3, t3, 0xFFF0                // t3 = current flags, without last bit
        or      t4, t3, t4                    // t4 = updated flags
        sb      t4, 0x018F(t9)                // turn off inputs for HMN player
        sh      r0, 0x01C2(t9)                // clear joystick angles
        // Some characters have moves that can loop indefinitely by holding B (Shine, Absorb, etc.), so clear it
        // Also clear pressed buttons to avoid things getting stuck
        sw      r0, 0x01BC(t9)                // clear held buttons and pressed buttons

        _end:
        OS.restore_registers()
        jr      ra
        nop

        action_table:
        dh Action.Idle
        dh Action.Teeter
        dh Action.Walk1
        dh Action.Walk2
        dh Action.Walk3
        dh Action.Run
        dh Action.DownWaitD
        dh Action.DownWaitU
        dh 0x0000                           // end table
        OS.align(4)
    }

    // @ Description
    // Updates projectile and human player X positions so they show up where they should
    // with all the camera warping going on
    scope update_projectile_and_hmn_positions_: {
        // t2 - Camera.hrc

        // Logic:
        // CX = (current_camera_x - PROJECTILE_LEFT_THRESHOLD) + warp_distance = camera distance traveled from PROJECTILE_LEFT_THRESHOLD
        // PX = (current_projectile_x - PROJECTILE_LEFT_THRESHOLD) + projectile_distance = projectile distance traveled from PROJECTILE_LEFT_THRESHOLD
        // (PX - CX) = current_projectile_x + projectile_distance - current_camera_x - warp_distance

        // For each projectile
            // If < PROJECTILE_LEFT_THRESHOLD, continue normally
            // If >= PROJECTILE_LEFT_THRESHOLD
                // track distance traveled past PROJECTILE_LEFT_THRESHOLD
                // If sandbag warp distance = 0, continue normally
                // Else If (PX - CX) < 0, then freeze projectile X to PROJECTILE_LEFT_THRESHOLD
                // Else set projectile to (projectile_distance - warp_distance) + PROJECTILE_LEFT_THRESHOLD

        lui     s1, 0x8004
        lw      s1, 0x6838(s1)                // s1 = projectile
        lw      s2, 0x0004(t9)                // s2 = human player object
        li      at, PROJECTILE_LEFT_THRESHOLD
        mtc1    at, f4                        // f4 = PROJECTILE_LEFT_THRESHOLD

        _loop:
        beqz    s1, _end                      // if not a projectile, return
        nop
        lw      t3, 0x0074(s1)                // t3 = projectile top joint
        lwc1    f2, 0x001C(t3)                // f2 = projectile X position

        c.lt.s  f2, f4                        // check if projectile is before threshold
        bc1t    _next                         // if not past threshold, move to next projectile
        nop

        // Let's use 0x38 in the projectile/human object to help figure out if we've initialized distance...
        // ...if it is 0, the projectile is not displayed, but any other value is treated the same,
        // and it is always -1 in the game, so we can just set to 1 when we initialize distance.
        // Let's store distance in 0x40 and previous X position in 0x44.
        lw      t4, 0x0038(s1)                // t4 = display flag
        lli     t5, 0x0001                    // t5 = 1 = initialized
        beq     t4, t5, _initialized          // if initialized already, skip initializing
        sw      t5, 0x0038(s1)                // set as initialized
        sw      r0, 0x0040(s1)                // initialize distance
        swc1    f4, 0x0044(s1)                // initialize previous X position as PROJECTILE_LEFT_THRESHOLD

        _initialized:
        lwc1    f8, 0x0040(s1)                // f8 = distance
        lwc1    f10, 0x0044(s1)               // f10 = previous X position
        sub.s   f10, f2, f10                  // f10 = distance traveled this frame
        add.s   f8, f8, f10                   // f8 = PX = updated distance
        swc1    f8, 0x0040(s1)                // update distance

        li      at, warp_distance
        lw      at, 0x0000(at)                // at = warp distance
        mtc1    at, f10                       // f10 = sandbag warp distance

        lwc1    f0, 0x000C(t2)                // f0 = current camera X
        add.s   f12, f0, f10                  // f12 = current_camera_X + warp_distance
        sub.s   f12, f12, f4                  // f12 = CX = (current_camera_x - PROJECTILE_LEFT_THRESHOLD) + warp_distance

        sub.s   f14, f8, f12                  // f14 = PX - CX
        li      at, PROJECTILE_LEFT_PADDING   // at = PROJECTILE_LEFT_PADDING
        mtc1    at, f16                       // f16 = PROJECTILE_LEFT_PADDING

        c.lt.s  f14, f16                      // check if (PX - CX) < 0
        bc1tl   _next                         // if the projectile hasn't traveled far enough yet, keep out of frame
        swc1    f4, 0x001C(t3)                // set projectile X position to PROJECTILE_LEFT_THRESHOLD

        sub.s   f0, f8, f10                   // f0 = projectile_distance - warp_distance
        add.s   f0, f0, f4                    // f0 = projectile_distance - warp_distance + PROJECTILE_LEFT_THRESHOLD
        swc1    f0, 0x001C(t3)                // set projectile X to projectile_distance - warp_distance + PROJECTILE_LEFT_THRESHOLD

        _next:
        lw      at, 0x001C(t3)                // at = projectile X position
        sw      at, 0x0044(s1)                // update previous X position
        bnel    s1, s2, _loop                 // loop over all projectiles but skip if human player
        lw      s1, 0x0020(s1)                // s1 = next projectile

        _end:
        bne     s1, s2, _loop                 // if we haven't handled the human player yet, do so
        or      s1, s2, r0                    // s1 = human player object
        jr      ra
        nop
    }

    // @ Description
    // Setups up the signs to have the correct digits and turns off their animation tracks
    // a0 - HRC main object
    scope initialize_signs_: {
        lui     t3, 0x8004
        lw      t3, 0xDE70(t3)                // t3 = animation off value = 0xFF7FFFFF

        lui     at, 0x8004
        lw      at, 0x6818(at)                // at = sign and track geometry object
        lw      at, 0x0074(at)                // at = sign and track position structs
        lw      at, 0x0010(at)                // at = platform and first sign
        lw      at, 0x0008(at)                // at = ?
        lw      at, 0x0008(at)                // at = track 1, first half
        lw      at, 0x0008(at)                // at = track 1, second half

        lw      t0, 0x0080(at)                // t0 = 2nd sign 00/X00 image struct
        lw      t1, 0x0000(t0)                // t1 = 2nd sign hundreds/thousands digit image struct
        lw      t2, 0x0000(t1)                // t2 = 2nd sign thousands/ten thousands digit image struct
        sh      r0, 0x0080(t0)                // set 00/X00 to 00
        lli     t4, 0x0001                    // t4 = 1
        sh      t4, 0x0080(t1)                // set hundreds digit to 1
        sh      r0, 0x0080(t2)                // set thousands/ten thousands digit to blank
        sw      t3, 0x0098(t0)                // turn off animation for 00/X00
        sw      t3, 0x0098(t1)                // turn off animation for hundreds/thousands digit
        sw      t3, 0x0098(t2)                // turn off animation for thousands/ten thousands digit

        lw      at, 0x0008(at)                // at = track 2, first half
        lw      at, 0x0008(at)                // at = track 2, second half

        lw      t0, 0x0080(at)                // t0 = 3rd sign 00/X00 image struct
        lw      t1, 0x0000(t0)                // t1 = 3rd sign hundreds/thousands digit image struct
        lw      t2, 0x0000(t1)                // t2 = 3rd sign thousands/ten thousands digit image struct
        sh      r0, 0x0080(t0)                // set 00/X00 to 00
        lli     t4, 0x0002                    // t4 = 2
        sh      t4, 0x0080(t1)                // set hundreds digit to 2
        sh      r0, 0x0080(t2)                // set thousands/ten thousands digit to blank
        sw      t3, 0x0098(t0)                // turn off animation for 00/X00
        sw      t3, 0x0098(t1)                // turn off animation for hundreds/thousands digit
        sw      t3, 0x0098(t2)                // turn off animation for thousands/ten thousands digit

        lw      at, 0x0008(at)                // at = track 3, first half
        lw      at, 0x0008(at)                // at = track 3, second half

        lw      t0, 0x0080(at)                // t0 = 4th sign 00/X00 image struct
        lw      t1, 0x0000(t0)                // t1 = 4th sign hundreds/thousands digit image struct
        lw      t2, 0x0000(t1)                // t2 = 4th sign thousands/ten thousands digit image struct
        sh      r0, 0x0080(t0)                // set 00/X00 to 00
        lli     t4, 0x0003                    // t4 = 3
        sh      t4, 0x0080(t1)                // set hundreds digit to 1
        sh      r0, 0x0080(t2)                // set thousands/ten thousands digit to blank
        sw      t3, 0x0098(t0)                // turn off animation for 00/X00
        sw      t3, 0x0098(t1)                // turn off animation for hundreds/thousands digit
        sw      t3, 0x0098(t2)                // turn off animation for thousands/ten thousands digit

        sw      r0, 0x0050(a0)                // set sign state to under 10k

        jr      ra
        sw      t0, 0x0054(a0)                // save reference to 4th sign
    }

    // @ Description
    // Ensures players load visible (as opposed to invisible before entry animation)
    scope spawn_visible_: {
        OS.patch_start(0x10E454, 0x8018FBF4)
        jal     spawn_visible_
        or      v0, t1, t2                  // original line 1
        OS.patch_end()

        li      a0, SinglePlayerModes.singleplayer_mode_flag
        lw      a0, 0x0000(a0)              // a0 = singleplayer_mode_flag
        lli     t0, SinglePlayerModes.HRC_ID
        beql    a0, t0, pc() + 8            // if HRC, force visible
        lli     v0, 0x0080                  // v0 = 0x80 = start visible

        jr      ra
        sb      v0, 0x007B(sp)              // original line 2
    }

    // @ Description
    // Apply countdown SFX
    scope apply_countdown_: {
        OS.patch_start(0x8EA00, 0x80113200)
        j       apply_countdown_
        nop
        nop
        _return:
        OS.patch_end()

        li      at, SinglePlayerModes.singleplayer_mode_flag
        lw      at, 0x0000(at)              // at = singleplayer_mode_flag
        lli     s1, SinglePlayerModes.HRC_ID
        bne     at, s1, _original           // if not HRC, skip
        nop
        lli     t9, 0x0258                  // t9 = 10 seconds
        lw      v1, 0x0018(a0)              // v1 = time elapsed
        subu    v1, t9, v1                  // v1 = time remaining
        beqz    v1, _j_0x80113378           // if no time remaining, skip
        nop

        _original:
        sltiu   at, v1, 0x012D              // original line 1
        beqz    at, _j_0x80113378           // original line 2, modified
        nop
        j       _return
        nop

        _j_0x80113378:
        j       0x80113378
        lw      ra, 0x002C(sp)              // original line 3
    }

    // @ Description
    // Plays Are You Ready?
    scope play_are_you_ready_: {
        OS.patch_start(0x10D1BC, 0x8018E95C)
        j       play_are_you_ready_
        addiu   at, r0, SinglePlayerModes.HRC_ID
        _return:
        OS.patch_end()

        li      a0, SinglePlayerModes.singleplayer_mode_flag
        lw      a0, 0x0000(a0)              // a0 = singleplayer_mode_flag
        bnel    a0, at, _original           // if not HRC, do original
        nop

        jal     0x800269C0                  // play FGM
        lli     a0, FGM.announcer.misc.ARE_YOU_READY

        addiu   a0, r0, 0x0042              // a0 = 1.1 seconds

        _original:
        jal     0x8000B1E8                  // original line 1 - Sleep()
        addiu   a0, r0, 0x003C              // original line 2 - a0 = 1 second
        j       _return
        nop
    }

    // @ Description
    // Turns off blastzones
    scope turn_off_blastzones_: {
        OS.patch_start(0x5DAF0, 0x800E22F0)
        j       turn_off_blastzones_
        lli     at, SinglePlayerModes.HRC_ID
        _return:
        OS.patch_end()

        li      a0, SinglePlayerModes.singleplayer_mode_flag
        lw      a0, 0x0000(a0)              // a0 = singleplayer_mode_flag
        beq     a0, at, _end                // if HRC, skip checking blastzones
        nop

        _original:
        jal     0x8013CB7C                  // original line 1 - check blastzones
        lw      a0, 0x0070(sp)              // original line 2

        _end:
        j       _return
        nop
    }

    // @ Description
    // Keeps the bat alive indefinitely bu
    scope prevent_bat_despawn_: {
        OS.patch_start(0xEE64C, 0x80173C0C)
        j       prevent_bat_despawn_
        nop
        _return:
        OS.patch_end()

        jal     0x80018994                  // original line 1 - Global.get_random_int_
        addiu   a0, r0, 0x0004              // original line 2

        // s0 = item struct
        lli     at, SinglePlayerModes.HRC_ID
        li      t0, SinglePlayerModes.singleplayer_mode_flag
        lw      t0, 0x0000(t0)              // t0 = singleplayer_mode_flag
        bne     t0, at, _end                // if not HRC, skip
        lli     at, Hazards.standard.HOME_RUN_BAT
        lw      t0, 0x000C(s0)              // t0 = item_id
        beql    t0, at, _end                // if the bat, always force the random int result to be 1
        lli     v0, 0x0001                  // v0 = 1 (non-zero avoids despawning)

        _end:
        j       _return
        nop
    }

    // @ Description
    // Stops volume from lowering after countdown.
    scope prevent_volume_reduction_: {
        OS.patch_start(0x8EB6C, 0x8011336C)
        j       prevent_volume_reduction_
        lli     at, SinglePlayerModes.HRC_ID
        _return:
        OS.patch_end()

        li      a3, SinglePlayerModes.singleplayer_mode_flag
        lw      a3, 0x0000(a3)              // a3 = singleplayer_mode_flag
        beq     a3, at, _end                // if HRC, skip
        nop

        jal     0x80020B38                  // original line 1 - reduce volume
        nop                                 // original line 2

        _end:
        j       _return
        nop
    }

    // @ Description
    // Animates the background image.
    // The background image is the same image twice, so we stretch it to allow scrolling.
    // This also is used to animate Big Blue's background
    scope animate_background_image_: {
        OS.patch_start(0x8000C, 0x8010480C)
        nop
        swc1    f0, 0x003C(sp)              // original line 2
        nop
        jal     animate_background_image_
        lwc1    f10, 0x003C(sp)             // original line 4
        OS.patch_end()

        lli     at, SinglePlayerModes.HRC_ID
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw      t6, 0x0000(t6)              // t6 = singleplayer_mode_flag
        beq     t6, at, _hrc                // if HRC, do scroll
        lli     at, 0x0016                  // at = vs screen_id
        OS.read_byte(Global.current_screen, t6) // t6 = screen_id
        bne     at, t6, _end                // if not VS, skip
        lli     at, Stages.id.BLUE          // at = Big Blue stage_id
        OS.read_byte(Global.vs.stage, t6)   // t6 = stage_id
        bne     t6, at, _end                // if not Big Blue, skip
        lw      t6, 0x0004(v0)              // t6 = background object

        lw      at, 0x0084(t6)              // at = special struct of background object
        bnez    at, _blue                   // if not 0, then we've initialized already so skip initializing
        lli     at, 0x0001                  // at = 1 = initialized
        sw      at, 0x0084(t6)              // mark initialized
        li      at, 0xBF17FDFF              // at = scroll speed
        sw      at, 0x0044(t6)              // set scroll speed
        lw      at, 0x0058(v0)              // at = initial background X
        sw      at, 0x0040(t6)              // set initial background X
        li      at, 0x400EF007              // at = original X scale doubled = 2.2334
        sw      at, 0x0048(t6)              // save initial background X scale
        lw      at, 0x001C(v0)              // at = initial background Y scale
        sw      at, 0x004C(t6)              // save initial background Y scale
        lui     at, 0x4100                  // at = Y position to use
        sw      at, 0x0050(t6)              // save Y position

        _blue:
        lw      at, 0x004C(t6)              // at = Y scale
        sw      at, 0x001C(v0)              // update Y scale so the image doesn't stretch with zoom
        lwc1    f10, 0x0050(t6)             // f10 = Y position

        _hrc:
        lli     at, 0x0001                  // at = 1
        lw      t6, 0x0004(v0)              // t6 = background object
        lwc1    f18, 0x0040(t6)             // f18 = current X position
        lwc1    f6, 0x0044(t6)              // f6 = current scroll speed

        li      t7, Global.match_info
        lw      t7, 0x0000(t7)              // t7 = match info
        lbu     t7, 0x0011(t7)              // t7 = 0 or 1 if not paused
        beqzl   t7, pc() + 8                // if we're not paused, animate clouds
        add.s   f18, f18, f6                // f18 = new X position
        beql    t7, at, pc() + 8            // if we're not paused, animate clouds
        add.s   f18, f18, f6                // f18 = new X position

        li      at, CLOUD_WARP_THRESHOLD    // at = CLOUD_WARP_THRESHOLD
        mtc1    at, f6                      // f6 = CLOUD_WARP_THRESHOLD
        c.lt.s  f6, f18                     // check if we need to warp the cloud image
        li      at, CLOUD_WARP_DISTANCE     // at = CLOUD_WARP_DISTANCE
        mtc1    at, f8                      // f8 = CLOUD_WARP_DISTANCE
        bc1fl   pc() + 8                    // if we need to warp the cloud image, then do it
        add.s   f18, f18, f8                // f18 = updated X position after warping the image
        swc1    f18, 0x0040(t6)             // set X position

        lw      at, 0x0048(t6)              // at = X scale
        sw      at, 0x0018(v0)              // update X scale so the image is correct width

        _end:
        swc1    f18, 0x0058(v0)             // original line 1 and 3 - set X position of background image
        jr      ra
        swc1    f10, 0x005C(v0)             // original line 5 - set Y position of background image
    }
}

} // __HRC__
