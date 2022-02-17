// SonicSpecial.asm

// This file contains subroutines used by Sonic's special moves.

scope SonicNSP {
    constant MAX_X_RANGE(0x450A)            // current setting - float: 2208
    constant MIN_Y_RANGE(0x447A)            // current setting - float: 1000
    constant MAX_X_RANGE_SS(0x453b)         // current setting (Super Sonic) - float: 3000
    constant MIN_Y_RANGE_SS(0x447A)         // current setting (Super Sonic) - float: 1000
    constant SPEED(0x42F0)                  // current setting - float: 120
    constant LOCKED_SPEED(0x4302)           // current setting - float: 130
    constant SPEED_SS(0x4316)               // current setting (Super Sonic) - float: 150
    constant LOCKED_SPEED_SS(0x4320)        // current setting (Super Sonic) - float: 160
    constant RECOIL_X_SPEED(0xC1A0)         // current setting - float: -20
    constant RECOIL_Y_SPEED(0x42A0)         // current setting - float: 80
    constant BOUNCE_Y_SPEED(0x4270)         // current setting - float: 60
    constant TURN_SPEED(0x3E0EFA1E)         // current setting - float: 0.139626 rads/8 degrees
    constant DEFAULT_ANGLE(0xBE860A85)      // current setting - float: -0.261799 rads/-15 degrees
    constant MAX_INITAL_ANGLE(0x3F1C61A6)   // current setting - float: 0.610865 rads/35 degrees
    constant MIN_INITAL_ANGLE(0xBF1C61A6)   // current setting - float: -0.610865 rads/-35 degrees
    constant DURATION(12)
    constant LOCKED_DURATION(20)

    // @ Description
    // Subroutine which runs when Sonic initiates a neutral special.
    scope begin_initial_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t0, 0x014C(a0)              // t0 = kinetic state
        bnez    t0, _continue               // skip if kinetic state = aerial
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        jal     0x800DEEC8                  // set aerial state
        nop

        _continue:
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Begin

        lli     a1, Sonic.Action.NSP_Begin  // a1(action id) = NSP_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      a0, 0x0034(sp)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // target = NULL
        sw      r0, 0x0B1C(a0)              // X_DIFF = 0
        lui     t0, 0x4140                  // ~
        sw      r0, 0x0048(a0)              // x velocity = 0
        sw      t0, 0x004C(a0)              // y velocity = 12
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for NSP_Begin
    scope begin_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        // check temp variable 1 to determine the status of Sonic's charge
        lw      t0, 0x017C(s0)              // t0 = temp variable 1
        beqz    t0, _end                    // skip to end if temp variable 1 = 0
        lli     at, 0x0001                  // at = 1
        bne     t0, at, _begin_movement     // if temp variable is set to a value other than 1, force movement
        lh      t0, 0x01BC(s0)              // t0 = buttons_held
        andi    t0, t0, Joypad.B            // t0 = 0x0020 if (B_HELD); else t0 = 0
        bnez    t0, _end                    // skip to end if temp variable 1 = 1 and B is held
        nop


        // if we're here, then begin movement and check for targets in front of Sonic
        _begin_movement:
        jal     check_for_targets_          // check_for_targets_
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      t0, 0x0B18(s0)              // t0 = target object
        beq     t0, r0, _no_target          // branch if no target was found
        nop
        jal     locked_move_initial_        // locked_move_initial_
        lw      a0, 0x0018(sp)              // a0 = player object
        b       _end                        // end
        nop

        // if no target was found, then move in a fixed direction instead
        _no_target:
        jal     move_initial_               // move_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which checks for valid targets for Sonic's homing attack.
    // a0 - player object
    scope check_for_targets_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      s1, 0x0024(sp)              // ~
        sw      s2, 0x0028(sp)              // store ra, s0-s2

        or      s0, a0, r0                  // s0 = Sonic player object
        li      s1, 0x800466FC              // s1 = player object head
        lw      s1, 0x0000(s1)              // s1 = first player object
        lw      s2, 0x0084(s0)              // s2 = player struct

        _player_loop:
        beqz    s1, _player_loop_exit       // exit loop when s1 no longer holds an object pointer
        nop
        beql    s1, s0, _player_loop        // loop if player and target object match...
        lw      s1, 0x0004(s1)              // ...and load next object into s1

        _team_check:
        li      t0, Global.match_info       // ~
        lw      t0, 0x0000(t0)              // t0 = match info struct
        lbu     t1, 0x0002(t0)              // t1 = team battle flag
        beqz    t1, _action_check           // branch if team battle flag = FALSE
        lbu     t1, 0x0009(t0)              // t1 = team attack flag
        bnez    t1, _action_check           // branch if team attack flag != FALSE
        nop

        // if the match is a team battle with team attack disabled
        lw      t0, 0x0084(s1)              // t0 = target player struct
        lbu     t0, 0x000C(t0)              // t0 = target team
        lbu     t1, 0x000C(s2)              // t1 = player team
        beq     t0, t1, _player_loop_end    // skip if player and target are on the same team
        nop

        _action_check:
        lw      t0, 0x0084(s1)              // t0 = target player struct
        lw      t0, 0x0024(t0)              // t0 = target player action
        sltiu   at, t0, 0x0007              // at = 1 if action id < 7, else at = 0
        bnez    at, _player_loop_end        // skip if target action id < 7 (target is in a KO action)
        nop

        _target_check:
        or      a0, s2, r0                  // a0 = player struct
        lw      a1, 0x0074(s1)              // a1 = target top joint struct
        jal     check_target_               // check_target_
        or      a2, s1, r0                  // a2 = target object struct
        beqz    v0, _player_loop_end        // branch if no new target
        nop

        // if check_target_ returned a new valid target
        sw      v0, 0x0B18(s2)              // store target object
        sw      v1, 0x0B1C(s2)              // store target X_DIFF

        _player_loop_end:
        b       _player_loop                // loop
        lw      s1, 0x0004(s1)              // s1 = next object

        _player_loop_exit:
        lw      t0, 0x0B18(s2)              // t0 = target object
        bnez    t0, _end                    // end if there is a targeted object
        nop

        li      s1, 0x80046700              // s1 = item object head
        lw      s1, 0x0000(s1)              // s1 = first item object

        _item_loop:
        beqz    s1, _end                    // exit loop when s1 no longer holds an object pointer
        nop

        lw      t0, 0x0084(s1)              // t0 = item special struct
        lw      t0, 0x0248(t0)              // t0 = bit field with hurtbox state
        andi    t0, t0, 0x0001              // t0 = 1 if hurtbox is enabled, else t0 = 0
        beqz    t0, _item_loop_end          // skip if item doesn't have an active hurtbox
        nop
        or      a0, s2, r0                  // a0 = player struct
        lw      a1, 0x0074(s1)              // a1 = target top joint struct
        jal     check_target_               // check_target_
        or      a2, s1, r0                  // a2 = target object struct
        beqz    v0, _item_loop_end          // branch if no new target
        nop

        // if check_target_ returned a new valid target
        sw      v0, 0x0B18(s2)              // store target object
        sw      v1, 0x0B1C(s2)              // store target X_DIFF

        _item_loop_end:
        b       _item_loop                  // loop
        lw      s1, 0x0004(s1)              // s1 = next object

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0020(sp)              // ~
        lw      s1, 0x0024(sp)              // ~
        lw      s2, 0x0028(sp)              // load ra, s0-s2
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which checks if a potential target is in range for Sonic's homing attack.
    // a0 - player struct
    // a1 - target top joint struct
    // a2 - target object struct
    // returns
    // v0 - target object (NULL when no valid target)
    // v1 - target X_DIFF
    scope check_target_: {
        lw      t8, 0x0078(a0)              // t8 = player x/y/z coordinates
        addiu   t9, a1, 0x001C              // t9 = target x/y/z coordinates

        // check if the target is within x range
        mtc1    r0, f0                      // f0 = 0
        lwc1    f2, 0x0000(t8)              // f2 = player x coordinate
        lwc1    f4, 0x0000(t9)              // f4 = target x coordinate
        sub.s   f10, f4, f2                 // f10 = X_DIFF (target x - player x)
        lwc1    f8, 0x0044(a0)              // ~
        cvt.s.w f8, f8                      // f8 = DIRECTION
        mul.s   f10, f10, f8                // f10 = X_DIFF * DIRECTION
        lui     at, MAX_X_RANGE             // at = MAX_X_RANGE
        ori     t6, r0, Character.id.SSONIC // t6 = id.SSONIC
        lw      t7, 0x0008(a0)              // t7 = character id
        beql    t7, t6, pc() + 8            // if character = SSONIC...
        lui     at, MAX_X_RANGE_SS          // ...use MAX_X_RANGE_SS instead
        mtc1    at, f8                      // f8 = MAX_X_RANGE
        c.le.s  f10, f8                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if MAX_X_RANGE =< X_DIFF
        or      v0, r0, r0                  // return 0
        c.le.s  f0, f10                      // ~
        nop                                 // ~
        bc1fl   _end                        // end if X_DIFF =< 0
        or      v0, r0, r0                  // return 0

        // check if there is a previous target
        lw      t0, 0x0B18(a0)              // t0 = current target
        beq     t0, r0, _check_y            // branch if there is no current target
        lwc1    f8, 0x0B1C(a0)              // f8 = current target X_DIFF

        // compare X_DIFF to see if the previous target was within closer x proximity
        c.le.s  f10, f8                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if prev X_DIFF =< current X_DIFF
        or      v0, r0, r0                  // return 0

        _check_y:
        // calculate Y_RANGE based on X_DIFF, creating a cone shaped range
        lwc1    f2, 0x0004(t8)              // f2 = player y coordinate
        lwc1    f4, 0x0004(t9)              // f4 = target y coordinate
        sub.s   f12, f4, f2                 // f12 = Y_DIFF (target y - player y)
        abs.s   f12, f12                    // f12 = absolute Y_DIFF
        lui     at, MIN_Y_RANGE             // at = MIN_Y_RANGE
        ori     t6, r0, Character.id.SSONIC // t6 = id.SSONIC
        lw      t7, 0x0008(a0)              // t7 = character id
        beql    t7, t6, pc() + 8            // if character = SSONIC...
        lui     at, MIN_Y_RANGE_SS          // ...use MIN_Y_RANGE_SS instead
        mtc1    at, f8                      // f8 = MIN_Y_RANGE
        lui     at, 0x3F00                  // ~
        mtc1    at, f6                      // f6 = 0.5
        mul.s   f6, f6, f10                 // f6 = X_DIFF * 0.5
        add.s   f8, f8, f6                  // f8 = Y_RANGE (MIN_Y_RANGE + X_DIFF * 0.5)
        c.le.s  f12, f8                     // ~
        nop                                 // ~
        bc1fl   _end                        // end if Y_RANGE =< Y_DIFF
        or      v0, r0, r0                  // return 0

        // if we're here then the target is the closest within range
        or      v0, a2, r0                  // v0 = target object
        mfc1    v1, f10                     // v1 = X_DIFF

        _end:
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins NSP_Locked_Move.
    scope locked_move_initial_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store ra, a0, s0

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Locked_Move
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Locked_Move

        lli     a1, Sonic.Action.NSP_Locked_Move // a1(action id) = NSP_Locked_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t8, 0x0078(a0)              // t8 = player x/y/z coordinates
        lw      t9, 0x0B18(a0)              // ~
        lw      t9, 0x0074(t9)              // ~
        addiu   t9, t9, 0x001C              // t9 = target x/y/z coordinates
        lw      t2, 0x0044(a0)              // ~
        mtc1    t2, f10                     // ~
        cvt.s.w f10, f10                    // f10 = DIRECTION
        lwc1    f4, 0x0000(t8)              // f4 = player x
        lwc1    f6, 0x0000(t9)              // f6 = target x
        sub.s   f14, f6, f4                 // f14 = X_DIFF
        mul.s   f14, f14, f10               // f14 = X_DIFF * DIRECTION
        lwc1    f4, 0x0004(t8)              // f4 = player y
        lwc1    f6, 0x0004(t9)              // f6 = target y
        sub.s   f12, f6, f4                 // f12 = Y_DIFF
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        nop
        // f0 = initial angle
        li      at, MIN_INITAL_ANGLE        // ~
        mtc1    at, f2                      // f2 = MIN_INITAL_ANGLE
        li      at, MAX_INITAL_ANGLE        // ~
        mtc1    at, f4                      // f4 = MAX_INITAL_ANGLE
        c.lt.s  f2, f0                      // ~
        nop                                 // ~
        bc1fl   _end                        // branch if initial angle < MIN_INITAL_ANGLE...
        mov.s   f0, f2                      // ...and set initial angle to MIN_INITAL_ANGLE
        c.lt.s  f0, f4                      // ~
        nop                                 // ~
        bc1fl   _end                        // branch if initial angle > MAX_INITAL_ANGLE
        mov.s   f0, f4                      // set initial angle to MAX_INITAL_ANGLE

        _end:
        swc1    f0, 0x0B20(s0)              // set intial angle
        lwc1    f12, 0x0044(s0)             // ~
        cvt.s.w f12, f12                    // f12 = direction
        lw      t0, 0x0004(s0)              // ~
        lw      t0, 0x0074(t0)              // t0 = top joint struct
        mul.s   f12, f12, f0                // f12 = movement angle * direction
        swc1    f12, 0x0038(t0)             // set joint rotation
        lli     at, LOCKED_DURATION         // ~
        sw      at, 0x0B28(s0)              // set movement timer
        lw      s0, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Subroutine which begins NSP_Move.
    scope move_initial_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store ra, a0, s0

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Move
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Move

        lli     a1, Sonic.Action.NSP_Move   // a1(action id) = NSP_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~

        _end:
        li      at, DEFAULT_ANGLE           // ~
        mtc1    at, f10                     // f10 = DEFAULT_ANGLE
        sw      at, 0x0B20(s0)              // set angle to DEFAULT_ANGLE
        lwc1    f12, 0x0044(s0)             // ~
        cvt.s.w f12, f12                    // f12 = direction
        lw      t0, 0x0004(s0)              // ~
        lw      t0, 0x0074(t0)              // t0 = top joint struct
        mul.s   f12, f12, f10               // f12 = DEFAULT_ANGLE * direction
        swc1    f12, 0x0038(t0)             // set joint rotation
        lli     at, DURATION                // ~
        sw      at, 0x0B28(s0)              // set movement timer
        lw      s0, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Move and NSP_Locked_Move.
    scope move_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // store
        lw      v0, 0x0084(a0)              // v0 = player struct

        _check_collision:
        addiu   t8, v0, 0x0294              // t8 = first hitbox struct
        addiu   t9, t8, 0xC4 * 3            // t9 = last hitbox struct
        or      t6, r0, r0                  // t6 = 0
        _loop:
        lw      t0, 0x0000(t8)              // t0 = hitbox state
        beqz    t0, _loop_end               // skip if hitbox is disabled
        nop
        lbu     t1, 0x0060(t8)              // t1 = hitbox collision flags(1/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        lbu     t1, 0x0068(t8)              // t1 = hitbox collision flags(2/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        lbu     t1, 0x0070(t8)              // t1 = hitbox collision flags(3/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        lbu     t1, 0x0078(t8)              // t1 = hitbox collision flags(4/4)
        or      t6, t6, t1                  // t6 = t6 | collision flags
        _loop_end:
        bne     t8, t9, _loop               // loop if t8 != last hitbox struct
        addiu   t8, t8, 0x00C4              // t8 = next hitbox struct
        // t6 = collision flags for all active hitboxes
        andi    t6, t6, 0x00F0              // t6 != 0 if hitbox collision has occured
        beq     t6, r0, _check_movement_end // skip if no hitbox collision is detected
        nop

        // If we're here, then a hitbox collision has occured, so begin recoil
        _begin_recoil:
        jal     air_recoil_initial_         // transition to NSP_Air_Recoil
        nop
        b       _end                        // end
        nop

        _check_movement_end:
        lw      t6, 0x0B28(v0)              // t6 = movement timer
        addiu   t6, t6,-0x0001              // decrement timer
        bnez    t6, _end                    // skip if timer !0
        sw      t6, 0x0B28(v0)              // update movement timer

        // If we're here, then the movement timer has ended, so transition to ending animation
        lw      t6, 0x014C(v0)              // t6 = kinetic state
        bnez    t6, _aerial                 // branch if kinetic state !grounded
        nop

        _grounded:
        jal     ground_end_initial_         // transition to NSP_Ground_End
        nop
        b       _end                        // end
        nop

        _aerial:
        jal     air_end_initial_            // transition to NSP_Air_End
        nop

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which controls movement for NSP_Move and NSP_Locked_Move.
    scope move_physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t9, 0x0B18(s0)              // t9 = target object

        ori     at, r0, Character.id.SSONIC // at = SSONIC
        lw      t8, 0x0008(s0)              // load character id
        beql    t8, at, _save_speed
        lui     at, SPEED_SS                // ~

        lui     at, SPEED                   // ~

        _save_speed:
        beqz    t9, _apply_movement         // branch if target object = NULL
        sw      at, 0x0030(sp)              // 0x0030(sp) = SPEED

        _get_angle:
        ori     at, r0, Character.id.SSONIC // at = SSONIC
        lw      t8, 0x0008(s0)              // load character id
        beql    t8, at, _move_locked
        lui     at, LOCKED_SPEED_SS         // ~

        lui     at, LOCKED_SPEED            // ~

        _move_locked:
        sw      at, 0x0030(sp)              // 0x0030(sp) = LOCKED_SPEED
        lw      t8, 0x0078(s0)              // t8 = player x/y/z coordinates
        lw      t9, 0x0074(t9)              // ~
        addiu   t9, t9, 0x001C              // t9 = target x/y/z coordinates
        lw      t2, 0x0044(s0)              // ~
        mtc1    t2, f10                     // ~
        cvt.s.w f10, f10                    // f10 = DIRECTION
        lwc1    f4, 0x0000(t8)              // f4 = player x
        lwc1    f6, 0x0000(t9)              // f6 = target x
        sub.s   f14, f6, f4                 // f14 = X_DIFF
        mul.s   f14, f14, f10               // f14 = X_DIFF * DIRECTION
        lwc1    f4, 0x0004(t8)              // f4 = player y
        lwc1    f6, 0x0004(t9)              // f6 = target y
        sub.s   f12, f6, f4                 // f12 = Y_DIFF
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        nop
        mov.s   f12, f0                     // f12 = DIFF_ANGLE

        _get_turn_angle:
        mtc1    r0, f0                      // f0 = 0
        li      at, 0x40C90FE4              // ~
        mtc1    at, f2                      // f2 = 6.28319 rads/360 degrees
        li      at, 0xC0490FD0              // ~
        mtc1    at, f4                      // f4 = -3.14159 rads/-180 degrees
        li      at, TURN_SPEED              // ~
        mtc1    at, f6                      // f6 = TURN_SPEED
        lwc1    f10, 0x0B20(s0)             // f10 = current movement angle
        sub.s   f8, f12, f10                // f8 = angle difference: DIFF_ANGLE - current angle
        c.lt.s  f4, f8                      // ~
        nop                                 // ~
        bc1fl   _calculate_turn             // branch if angle difference < -180...
        add.s   f8, f8, f2                  // ...and add 360 degrees to angle differnece

        _calculate_turn:
        abs.s   f14, f8                     // f14 = absolute angle difference
        c.lt.s  f6, f14                     // ~
        nop                                 // ~
        bc1fl   _update_angle               // branch and immediately update if absolute angle difference < TURN_SPEED...
        mov.s   f10, f12                    // ...and set movement angle to DIFF_ANGLE
        c.lt.s  f0, f8                      // ~
        nop                                 // ~
        bc1fl   _apply_turn                 // branch if angle difference < 0...
        neg.s   f6, f6                      // ...and set f6 to -TURN_SPEED

        _apply_turn:
        add.s   f10, f10, f6                // f10 = previous angle + TURN_SPEED

        _update_angle:
        c.lt.s  f4, f10                     // ~
        nop                                 // ~
        bc1fl   pc() + 8                    // branch if new movement angle < -180...
        add.s   f10, f10, f2                // ...and add 360 degrees to movement angle
        swc1    f10, 0x0B20(s0)             // store updated movement angle
        lwc1    f12, 0x0044(s0)             // ~
        cvt.s.w f12, f12                    // f12 = direction
        lw      t0, 0x0004(s0)              // ~
        lw      t0, 0x0074(t0)              // t0 = top joint struct
        mul.s   f12, f12, f10               // f12 = movement angle * direction
        swc1    f12, 0x0038(t0)             // set joint rotation

        _apply_movement:
        // ultra64 cosf function
        jal     0x80035CD0                  // f0 = cos(f12)
        lwc1    f12, 0x0B20(s0)             // f12 = movement angle
        lwc1    f4, 0x0030(sp)              // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = x velocity (SPEED * cos(angle))
        swc1    f4, 0x0034(sp)              // 0x0034(sp) = x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x0B20(s0)             // f12 = movement angle
        lwc1    f4, 0x0030(sp)              // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = y velocity (SPEED * sin(angle))
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lwc1    f2, 0x0034(sp)              // f2 = x velocity
        mul.s   f2, f2, f0                  // f2 = x velocity * direction
        swc1    f2, 0x0048(s0)              // store updated x velocity
        swc1    f4, 0x004C(s0)              // store updated y velocity

        _end:
        lw      s0, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles collision for NSP_Move and NSP_Locked_Move.
    scope move_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, bounce_initial_         // a1(transition subroutine) = bounce_initial_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins NSP_Bounce.
    scope bounce_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Bounce
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Bounce

        lli     a1, Sonic.Action.NSP_Bounce // a1(action id) = NSP_Bounce
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t0, 0x3E80                  // ~
        mtc1    t0, f0                      // f0 = 0.25
        lwc1    f2, 0x0048(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0048(a0)              // multiply x velocity by 0.25 and update
        lui     at, BOUNCE_Y_SPEED          // at = BOUNCE_Y_SPEED
        sw      at, 0x004C(a0)              // set y velocity to BOUNCE_Y_SPEED
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins NSP_Ground_End.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Ground_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Ground_End

        lli     a1, Sonic.Action.NSP_Ground_End // a1(action id) = NSP_Ground_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.5
        lwc1    f2, 0x0060(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0060(a0)              // multiply x velocity by 0.5 and update
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins NSP_Air_End.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_End

        lli     a1, Sonic.Action.NSP_Air_End // a1(action id) = NSP_Air_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.5
        lwc1    f2, 0x0048(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0048(a0)              // multiply x velocity by 0.5 and update
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x004C(a0)              // multiply y velocity by 0.5 and update
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Ground_End.
    scope ground_end_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_end_transition_     // a1(transition subroutine) = air_end_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Air_End.
    scope air_end_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_end_transition_  // a1(transition subroutine) = ground_end_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Ground_End.
    scope ground_end_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Ground_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Ground_End

        lli     a1, Sonic.Action.NSP_Ground_End // a1(action id) = NSP_Ground_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0001                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Air_End.
    scope air_end_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_End

        lli     a1, Sonic.Action.NSP_Air_End // a1(action id) = NSP_Air_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0001                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
        lw      a0, 0x0038(sp)              // a0 = player object
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins NSP_Air_Recoil.
    scope air_recoil_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_Recoil
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_Recoil

        lli     a1, Sonic.Action.NSP_Air_Recoil // a1(action id) = NSP_Air_Recoil
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lwc1    f2, 0x0044(a0)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        lui     at, RECOIL_X_SPEED          // ~
        mtc1    at, f4                      // f4 = RECOIL_X_SPEED
        mul.s   f4, f4, f2                  // f4 = RECOIL_X_SPEED * DIRECTION
        lui     at, RECOIL_Y_SPEED          // at = RECOIL_Y_SPEED
        swc1    f4, 0x0048(a0)              // set x velocity to RECOIL_X_SPEED
        sw      at, 0x004C(a0)              // set y velocity to RECOIL_Y_SPEED
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Ground_Recoil.
    scope ground_recoil_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_recoil_transition_  // a1(transition subroutine) = air_recoil_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Air_Recoil.
    scope air_recoil_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_recoil_transition_  // a1(transition subroutine) = ground_recoil_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Ground_Recoil.
    scope ground_recoil_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Ground_Recoil
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Ground_Recoil

        lli     a1, Sonic.Action.NSP_Ground_Recoil // a1(action id) = NSP_Ground_Recoil
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0001                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Air_Recoil.
    scope air_recoil_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_Recoil
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SONIC_NSP_Air_Recoil

        lli     a1, Sonic.Action.NSP_Air_Recoil // a1(action id) = NSP_Air_Recoil
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0001                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 1 (continue hitbox)
        lw      a0, 0x0038(sp)              // a0 = player object
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Patch which removes destroyed objects as Sonic's target.
    scope destroyed_target_fix_: {
        OS.patch_start(0xA698, 0x80009A98)
        j       destroyed_target_fix_
        nop
        _return:
        OS.patch_end()

        lui     t0, 0x8004                  // ~
        lw      t0, 0x66FC(t0)              // t0 = first player object
        lw      t1, 0x0000(s0)              // t1 = object type
        lli     at, 0x03F5                  // at = item object id
        beq     t1, at, _loop               // branch if object type = item
        lli     at, 0x03E8                  // at = player object id
        bne     t1, at, _end                // skip if object type != player
        nop

        _loop:
        // t0 = player object
        beqz    t0, _end                    // exit loop when s1 no longer holds an object pointer
        nop

        lw      t1, 0x0084(t0)              // t1 = player struct
        lw      t2, 0x0008(t1)              // t2 = character id
        lli     at, Character.id.SSONIC     // at = id.SSONIC
        beq     t2, at, _sonic              // branch if character = SSONIC
        lli     at, Character.id.SONIC      // at = id.SONIC
        bne     t2, at, _loop_end           // skip if character != SONIC
        nop

        _sonic:
        lw      t2, 0x0B18(t1)              // t2 = target object
        beql    s0, t2, _loop_end           // branch if object being destroyed is Sonic's target...
        sw      r0, 0x0B18(t1)              // ...and set target object to NULL

        _loop_end:
        b       _loop                       // loop
        lw      t0, 0x0004(t0)              // t0 = next player object

        _end:
        lui     t6, 0x8004                  // original line 1
        j       _return                     // return
        lw      t6, 0x6A54(t6)              // original line 2
    }
}


scope SonicUSP {
    constant Y_SPEED(0x4308)                // current setting - float: 136.0

    // @ Description
    // Initial Subroutine for Sonic's grounded up special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct

        // move Sonic up to be on spring
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      t0, 0x0074(a0)              // t0 = top joint
        lui     at, 0x4310                  // at = 144 (fp)
        mtc1    at, f0                      // f0 = 144
        lwc1    f2, 0x0020(t0)              // f2 = Y position
        add.s   f2, f2, f0                  // f2 = adjusted Y position
        jal     air_initial_                // air_initial_
        swc1    f2, 0x0020(t0)              // update Y position

        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lli     t0, 0x0000                  // t0 = 0 (initialize spring on ground)
        lw      at, 0x00EC(a0)              // at = clipping ID of player
        bltzl   at, pc() + 8                // if not over a normal plat (like on the respawn plat), then initialize in air
        lli     t0, 0x0001                  // t0 = 1 (initialize spring in air)
        sb      at, 0x0186(a0)              // temp variable 3, 3rd byte = character's clipping ID
        sb      t0, 0x0187(a0)              // temp variable 3, 4th byte = initialize spring on ground/in air
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Initial Subroutine for Sonic's aerial up special.
    scope air_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, 0xE4                    // a1(action id) = NSP_Air_B
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        lli     v1, 0x0001                  // v1 = 1
        sw      v1, 0x0184(a0)              // temp variable 3 = 1 (initialize spring in air)
        sw      r0, 0x0B18(a0)              // movement flag = FALSE
        sw      r0, 0x0048(a0)              // set x velocity to 0
        sw      r0, 0x004C(a0)              // set y velocity to 0
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for Sonic's aerial up special.
    scope main_air_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0038(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        or      a3, a0, r0                  // a3 = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lhu     t6, 0x0184(v0)              // t6 = temp variable 3
        beqz    t6, _create_spring          // if temp variable 3 = 0, create spring projectile
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beqz    t6, _check_end              // skip if temp variable 1 = 0
        lw      t6, 0x0184(v0)              // t6 = spring object

        // if we're here, then temp variable 1 was set, so uncoil the spring and begin upwards movement
        lw      at, 0x0074(t6)              // at = position struct
        beqz    at, _begin_movement         // if the projectile has been destroyed, skip
        nop
        lw      at, 0x0080(at)              // at = special image struct
        lh      t6, 0x0080(at)              // t6 = coiled spring index
        andi    t0, t6, 0x0001              // t0 = 1 if coiled
        beqz    t0, _begin_movement         // if already uncoiled, skip
        addiu   t6, t6, -0x0001             // t6 = uncoiled spring index
        mtc1    t6, f8                      // f8 = uncoiled spring index
        cvt.s.w f8, f8                      // t6 = uncoiled spring index, fp
        sh      t6, 0x0080(at)              // set image to uncoiled spring
        swc1    f8, 0x0088(at)              // set palette to uncoiled spring's

        _begin_movement:
        lui     at, Y_SPEED                 // at = Y_SPEED
        sw      at, 0x004C(v0)              // y velocity = Y_SPEED
        sw      r0, 0x017C(v0)              // reset temp variable 1
        lli     at, OS.TRUE                 // at = TRUE
        sw      at, 0x0B18(v0)              // movement flag = TRUE
        sw      at, 0x0ADC(v0)              // up special bool = TRUE
        // take mid-air jumps away at this point
        lw      at, 0x09C8(v0)              // at = attribute pointer
        lw      at, 0x0064(at)              // at = max jumps
        b       _check_end
        sb      at, 0x0148(v0)              // jumps used = max jumps

        _create_spring:
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        sw      r0, 0x0020(sp)              // ~
        sw      r0, 0x0028(sp)              // x/z offset = 0
        sw      r0, 0x0024(sp)              // y offset = 0

        lw      a0, 0x08F8(v0)              // a0 = part 0x0 (body) struct
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct
        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lui     t6, 0xC364                  // t6 = -228 (fp)
        mtc1    t6, f8                      // f8 = -228
        lwc1    f6, 0x0024(sp)              // f6 = y coordinate
        add.s   f6, f6, f8                  // f6 = adjusted y coordinate
        swc1    f6, 0x0024(sp)              // update y coordinate
        lw      a0, 0x0034(sp)              // a0 = player object
        addiu   a2, r0, r0
        jal     spring_stage_setting_       // INITIATE SPRING
        addiu   a1, sp, 0x0020              // a1 = coordinates to create projectile at
        lw      a0, 0x0034(sp)              // a0 = player object

        _check_end:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        nop

        _end:
        lw      ra, 0x0038(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine for Sonic's aerial up special interrupt.
    scope interrupt_: {
        addiu   sp, sp, -0x0020
        sw      a0, 0x0018(sp)              // ~
        sw      ra, 0x001C(sp)              // store ra, a0
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      at, 0x0180(t0)              // at = temp variable 2
        beqz    at, _end                    // skip if temp variable 2 isn't set
        nop

        // if temp variable 2 was set, do an action check/allow interrupts
        jal     0x80150B00                  // check for aerial attacks
        nop

        _end:
        lw      ra, 0x001C(sp)      // load ra
        jr      ra
        addiu   sp, sp, 0x0020
    }

    // @ Description
    // Subroutine for Sonic's aerial up special physics.
    scope air_physics_: {
        addiu   sp, sp, -0x0020
        sw      a0, 0x0018(sp)      // ~
        sw      ra, 0x001C(sp)      // store ra, a0
        lw      t0, 0x0084(a0)      // t0 = player struct
        lw      t0, 0x0B18(t0)      // t0 = movement flag
        beqz    t0, _end            // skip if movement flag = FALSE
        nop

        // if movement has started
        jal     0x800D90E0          // physics subroutine which allows player control
        nop

        _end:
        lw      ra, 0x001C(sp)      // load ra
        jr      ra
        addiu   sp, sp, 0x0020
    }

    // @ Description
    // Patch which prevents Sonic from using special moves after up special has been performed.
    scope action_check_patch_: {
        OS.patch_start(0xCB950, 0x80150F10)
        j       action_check_patch_
        lw      a1, 0x0084(a0)              // original line 1 (a1 = player struct)
        _return:
        OS.patch_end()


        lw      t6, 0x0008(a1)              // t6 = character id
        lli     at, Character.id.SSONIC     // at = id.SSONIC

        beq     t6, at, _sonic              // branch if character = SSonic
        lli     at, Character.id.SONIC      // at = id.SONIC

        bne     t6, at, _end                // skip if character != Sonic
        nop

        // if the character is Sonic
        _sonic:
        lw      t6, 0x0ADC(a1)              // t6 = up special bool
        beqz    t6, _end                    // skip if bool = FALSE (up special has not been used)
        nop

        // if up special has been used
        j       0x8015104C                  // end function early, skipping special move action checks
        or      v0, r0, r0                  // return FALSE (this return value represents whether an action change occured)

        _end:
        j       _return
        or      a2, a0, r0                  // original line 2
    }

    // @ Description
    // Patch which allows Sonic to use special moves again after being hit.
    scope restore_specials_on_hit_: {
        OS.patch_start(0x63A44, 0x800E8244)
        j       restore_specials_on_hit_
        nop
        _return:
        OS.patch_end()

        sw      a0, 0x0020(sp)              // store a0 (original line 1)
        lw      a0, 0x0084(a0)              // a0 = player struct (original line 2)
        lw      t6, 0x0008(a0)              // t6 = character id
        lli     at, Character.id.SSONIC     // at = id.SSONIC

        beq     t6, at, _sonic              // branch if character = SSonic
        lli     at, Character.id.SONIC      // at = id.SONIC

        bne     t6, at, _end                // skip if character != Sonic
        nop

        // if the character is Sonic
        _sonic:
        sw      r0, 0x0ADC(a0)              // set up special bool to FALSE

        _end:
        j       _return                     // return
        nop
    }

    // @ Description
    // Spawns the spring in the default item room so it is z-buffered correctly
    scope change_spring_room_: {
        OS.patch_start(0xE066C, 0x80165C2C)
        jal     change_spring_room_
        lw      a0, 0x007C(sp)              // original line 1 - a0 = projectile object
        OS.patch_end()

        lw      a2, 0x0084(a0)              // a2 = projectile special struct
        lw      a2, 0x000C(a2)              // a2 = projectile ID
        lli     a3, SONIC_ID                // a3 = spring projectile ID
        beql    a2, a3, _end                // if spring, change room to 0x000B
        lli     a2, 0x000B                  // a2 = 0x000B (room)

        lli     a2, 0x000E                  // original line 2 - a2 = 0x000E (room)

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    // @ Arguments
    // a0 - player object
    // a1 - spring coordinates
    // a2 - ?
    scope spring_stage_setting_: {
        addiu   sp, sp, -0x0050             // allocate stack space
        sw      s0, 0x0018(sp)              // save registers
        sw      ra, 0x001C(sp)              // ~

        lw      t6, 0x0084(a0)              // t6 = player struct
        li      s0, spring_properties_struct // s0 = projectile properties struct address
        //lw      t0, 0x0024(s0)              // t0 = projectile data pointer
        lw      t1, 0x0028(s0)              // t1 = ?
        or      a2, a1, r0                  // a2 = spring coordinates
        li      a1, spring_projectile_struct // a1 = main projectile struct address
        lui     a3, 0x8000                  // a3 = ?
        sw      t6, 0x002C(sp)              // 0x002C(sp) = player struct
        jal     0x801655C8                  // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)              // ?

        beqz    v0, _end_stage_setting      // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        _projectile_branch:
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile struct
        sw      v1, 0x0024(sp)              // save projectile struct to stack
        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(v1)              // store duration

        lw      a0, 0x002C(sp)              // a0 = player struct
        lbu     at, 0x000D(a0)              // at = player port
        li      t7, Sonic.classic_table     // t7 = classic_table
        addu    t7, t7, at                  // t7 = classic_table + port
        lbu     t7, 0x0000(t7)              // t7 = px is_classic
        lw      t3, 0x0074(v0)              // t3 = position struct
        lw      t3, 0x0080(t3)              // t3 = special image struct
        lli     t6, 0x0001                  // t6 = 1 = spring coiled index
        bnezl   t7, pc() + 8                // if Classic Sonic, use classic spring
        lli     t6, 0x0003                  // t6 = 3 = classic spring coiled index
        sh      t6, 0x0080(t3)              // set image to coiled spring
        lui     t6, 0x3F80                  // t6 = 1 (fp) = spring coiled index for palette
        bnezl   t7, pc() + 8                // if Classic Sonic, use classic spring
        lui     t6, 0x4040                  // t6 = 3 (fp) = classic spring coiled index for palette
        sw      t6, 0x0088(t3)              // set palette to coiled spring's

        lb      at, 0x0186(a0)              // at = clipping ID of character at start of USP
        lbu     t3, 0x0187(a0)              // t3 = kinetic state to initialize as (1 = aerial, 0 = grounded)
        sw      v0, 0x0184(a0)              // temp variable 3 = projectile object
        sw      r0, 0x0040(v0)              // set spring check flag to false
        sw      r0, 0x0150(v1)              // turn off hitbox initially
        bnez    t3, _fgm                    // if not grounded, skip
        lw      t6, 0x00EC(a0)              // t6 = clipping ID of player
        bnel    at, t6, _fgm                // if character is no longer over original clipping ID, set to aerial
        lli     t3, 0x0001                  // t3 = kinetic state = aerial
        bgezl   t6, _fgm                    // if player is still over a valid clipping ID, set for spring
        sw      t6, 0x00A0(v1)              // set clipping ID of spring

        // if here, set initial state to aerial
        lli     t3, 0x0001                  // t3 = kinetic state = aerial

        _fgm:
        sw      t3, 0x00FC(v1)              // initialize kinetic state
        lli     a0, 0x03D7                  // a0 = spring fgm_id
        bnezl   t7, pc() + 8                // if Classic Sonic, use classic spring
        lli     a0, 0x03DF                  // a0 = classic spring fgm_id

        _play_fgm:
        jal     FGM.play_                   // play FGM
        sw      a0, 0x0044(v0)              // save fgm_id

        lw      t6, 0x002C(sp)              // ~
        lw      v1, 0x0024(sp)              // ~
        lw      t7, 0x0044(t6)              // ~
        mul.s   f8, f0, f6                  // ~
        mtc1    r0, f12                     // ~
        mtc1    t7, f10                     // ~
        nop                                 // ~
        cvt.s.w f16, f10                    // ~
        mul.s   f18, f8, f16                // ~
        //jal     0x800303F0                  // ~
        //swc1    f18, 0x0020(v1)             // original logic

        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        jal     0x80167FA0                  // ~
        nop

        lw      v0, 0x0028(sp)              // original logic

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0050
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which accounts for the main function of spring projectile
    scope spring_main_: {
        addiu   sp, sp, -0x0030     // allocate stack space
        sw      ra, 0x0014(sp)      // save registers
        sw      a0, 0x0020(sp)      // ~

        lw      a0, 0x0084(a0)      // a0 = projectile special struct
        jal     0x80167FE8          // counts down from duration
        sw      a0, 0x001C(sp)      // save projectile special struct
        beqz    v0, _continue       // if duration not met, continue
        lw      a0, 0x001C(sp)      // a0 = projectile special struct

        // end projectile
        lw      t7, 0x0020(sp)      // t7 = projectile object
        lui     a1, 0x3F80          // a1 = 1 (fp)
        lw      a0, 0x0074(t7)      // a0 = projectile position struct
        jal     0x800FF648          // create smoke gfx
        addiu   a0, a0, 0x001C      // a0 = coordinates
        b       _end
        addiu   v0, r0, 0x0001      // v0 = 1 means destroy spring object

        _continue:
        li      v0, spring_properties_struct
        lw      t8, 0x0000(v0)      // t8 = initial duration
        addiu   t8, t8, -0x0004     // t8 = initial duration - 4 frames
        // t7 has current count from prior jal
        sltu    t8, t7, t8          // t8 = 1 if after first 4 frames
        mtc1    r0, f6              // f6 = 0 = no rotation
        beqz    t8, _initial_rotation // if in the first 4 frames, skip normal rotation/gravity
        addiu   a1, r0, r0          // set gravity to 0

        // rest of the duration functionality
        lw      a1, 0x000C(v0)      // load normal gravity

        lw      t1, 0x0020(sp)      // t1 = projectile object
        lw      t2, 0x0084(t1)      // t2 = projectile special struct

        // ensure hitbox is always on in the air
        lli     at, 0x0001          // at = 1 = enable hitbox
        sw      at, 0x0150(t2)      // turn on hitbox

        lw      t3, 0x00FC(t2)      // t3 = 0 if grounded
        bnezl   t3, _initial_rotation // if not grounded, rotate
        lwc1    f6, 0x0014(v0)      // load normal rotation

        // if here, set the rotation to 0
        lw      v1, 0x0074(t1)      // v1 = top joint
        sw      r0, 0x0030(v1)      // set current rotation value to 0

        // remove hitbox and remove stored player objects
        sw      r0, 0x0150(t2)      // turn off hitbox
        lli     at, 0x00E0          // at = flag
        sw      r0, 0x0214(t2)      // clear hit player object reference
        sb      at, 0x0218(t2)      // clear hit flag
        sw      r0, 0x021C(t2)      // clear hit player object reference
        sb      at, 0x0220(t2)      // clear hit flag
        sw      r0, 0x0224(t2)      // clear hit player object reference
        sb      at, 0x0228(t2)      // clear hit flag
        sw      r0, 0x022C(t2)      // clear hit player object reference
        sb      at, 0x0230(t2)      // clear hit flag

        lli     at, 0x0001          // at = 1 = enable spring
        sw      at, 0x0040(t1)      // set enable spring flag to true

        // and set to uncoiled
        lw      t3, 0x0080(v1)      // t3 = special image struct
        lh      t6, 0x0080(t3)      // t6 = spring index
        andi    at, t6, 0x0001      // at = 1 if coiled
        beqz    at, _after_rotation_set // if already uncoiled, skip
        addiu   t6, t6, -0x0001     // t6 = uncoiled spring index
        mtc1    t6, f8              // f8 = uncoiled spring index
        cvt.s.w f8, f8              // t6 = uncoiled spring index, fp
        sh      t6, 0x0080(t3)      // set image to coiled spring
        swc1    f8, 0x0088(t3)      // set palette to coiled spring's

        b       _after_rotation_set
        sw      r0, 0x0040(t1)      // set enable spring flag to false this frame

        _initial_rotation:
        lw      t1, 0x0020(sp)      // t1 = projectile object
        lw      v1, 0x0074(t1)      // v1 = top joint
        lwc1    f4, 0x0030(v1)      // f4 = current rotation value
        add.s   f8, f4, f6          // f8 = new rotation value
        swc1    f8, 0x0030(v1)      // update rotation value

        _after_rotation_set:
        // todo: check if the following 2 lines are necessary
        addiu   t2, r0, r0          // used to use free space area, but for no apparent reason, effects graphics
        addiu   t8, r0, r0          // used to use free space area, but for no apparent reason, affects graphics

        jal     0x80168088          // main projectile routine
        lw      a2, 0x0004(v0)      // a2 = max speed

        lw      a0, 0x0020(sp)      // a0 = projectile object
        lw      at, 0x0040(a0)      // at = spring enabled flag
        beqz    at, _end            // if not enabled, skip
        or      v0, r0, r0          // v0 = 0 (don't destroy spring)

        jal     check_spring_bounce_
        nop

        or      v0, r0, r0          // v0 = 0 (don't destroy spring)

        _end:
        lw      ra, 0x0014(sp)      // restore registers
        addiu   sp, sp, 0x0030      // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // For the given spring, checks if any players should trigger the spring.
    // @ Arguments
    // a0 - spring projectile object
    scope check_spring_bounce_: {
        addiu   sp, sp, -0x0030     // allocate stack space
        sw      ra, 0x0024(sp)      // save registers
        sw      a0, 0x0028(sp)      // ~

        lui     t0, 0x8004
        lw      t0, 0x66FC(t0)      // t0 = first player object

        _loop:
        beqz    t0, _end            // stop looping if no more players to check
        nop
        lw      t1, 0x0074(t0)      // t1 = player position struct (top joint)
        lw      t2, 0x0084(t0)      // t2 = player struct

        lw      t3, 0x0008(t2)      // t3 = char_id
        lli     at, Character.id.BOSS
        beq     t3, at, _next       // if Masterhand, skip
        lw      at, 0x014C(t2)      // at = kinetic state

        beqz    at, _next           // if player is grounded, skip
        lw      t3, 0x0024(t1)      // t3 = player Z position

        bnez    t3, _next           // if player Z position is not 0, skip
        lwc1    f4, 0x0090(t2)      // f4 = Y velocity

        mtc1    r0, f0              // f0 = 0
        c.lt.s  f4, f0              // check if Y velocity is negative
        bc1f    _next               // if Y velocity is not negative, skip
        lwc1    f4, 0x001C(t1)      // f4 = player X position

        lw      t4, 0x0074(a0)      // t4 = spring position struct
        lwc1    f6, 0x001C(t4)      // f6 = spring X position

        lw      t3, 0x0084(a0)      // t3 = spring projectile special struct

        sub.s   f4, f4, f6          // f4 = player X position - spring X position
        abs.s   f4, f4              // f4 = |player X position - spring X position|
        lwc1    f2, 0x0070(t3)      // f2 = spring ECB width/2
        c.le.s  f4, f2              // check if player is within X bounds of spring
        bc1f    _next               // if player is not within X bounds of spring, skip
        lwc1    f4, 0x0020(t1)      // f4 = player Y position

        lwc1    f6, 0x0020(t4)      // f6 = spring center Y position
        lwc1    f2, 0x0064(t3)      // f2 = spring ECB top point Y offset
        add.s   f2, f6, f2          // f2 = spring top Y position
        c.lt.s  f4, f6              // check if player is below the spring center
        bc1t    _next               // if player is below the spring center, skip
        nop
        c.le.s  f4, f2              // check if player is at or below top of spring
        bc1f    _next               // if player is above top of spring,  skip
        lw      t3, 0x0024(t2)      // t3 = Action

        // if we're here, then initiate spring

        // move player to be on spring
        swc1    f6, 0x0020(t1)      // update Y position of player

        // update spring to coiled
        lw      t4, 0x0074(a0)      // t4 = spring position struct
        lw      t4, 0x0080(t4)      // t4 = special image struct
        lh      t6, 0x0080(t4)      // t6 = spring index
        andi    at, t6, 0x0001      // at = 1 if coiled
        bnez    at, _check_action   // if already coiled, skip
        addiu   t6, t6, 0x0001      // t6 = coiled spring index
        mtc1    t6, f8              // f8 = coiled spring index
        cvt.s.w f8, f8              // t6 = coiled spring index, fp
        sh      t6, 0x0080(t4)      // set image to coiled spring
        swc1    f8, 0x0088(t4)      // set palette to coiled spring's

        _check_action:
        // For some actions, we'll do an action change to JumpF
        // Valid action ranges: JumpF - Pass, Tumble - FallSpecial

        or      a0, t0, r0          // a0 = player object
        sw      a0, 0x002C(sp)      // save player object

        lli     t4, Action.JumpF
        sltu    t4, t3, t4          // t4 = 1 if < JumpF
        bnez    t4, _keep_action    // if not in range, don't change action
        lli     t4, Action.Pass + 1
        sltu    t4, t3, t4          // t4 = 1 if in range for JumpF - Pass
        bnez    t4, _change_action  // if in range, do action change
        lli     t4, Action.Tumble
        sltu    t4, t3, t4          // t4 = 1 if < Tumble
        bnez    t4, _keep_action    // if not in range, don't change action
        lli     t4, Action.FallSpecial
        sltu    t4, t3, t4          // t4 = 1 if in range for Tumble = FallSpecial
        bnez    t4, _change_action  // if not in range, change action
        lli     t4, Action.ShieldBreakFall
        beq     t4, t3, _change_action  // if in Shield Break Fall, change action
        lli     t4, Action.ShieldBreak
        beq     t4, t3, _change_action  // if in Shield Break Fall, change action
        lli     t4, Action.InhalePulled
        beq     t4, t3, _next       // if in Inhale Pulled, ignore spring
        nop

        _keep_action:
        // Some character actions need to be interrupted, so check!

        lw      t4, 0x0008(t2)      // t4 = char_id
        lli     at, Character.id.FOX
        beq     t4, at, _fox_falco  // if Fox, need to do action checks
        lli     at, Character.id.JFOX
        beq     t4, at, _fox_falco  // if JFox, need to do action checks
        lli     at, Character.id.FALCO
        beq     t4, at, _fox_falco  // if Falco, need to do action checks
        lli     at, Character.id.KIRBY
        beq     t4, at, _kirby      // if Kirby, need to do action checks
        lli     at, Character.id.JKIRBY
        beq     t4, at, _kirby      // if JKirby, need to do action checks
        lli     at, Character.id.YOSHI
        beq     t4, at, _yoshi      // if Yoshi, need to do action checks
        lli     at, Character.id.JYOSHI
        beq     t4, at, _yoshi      // if JYoshi, need to do action checks
        lli     at, Character.id.BOWSER
        beq     t4, at, _bowser     // if Bowser, need to do action checks
        lli     at, Character.id.GBOWSER
        beq     t4, at, _bowser     // if Giga Bowser, need to do action checks
        lli     at, Character.id.NESS
        beq     t4, at, _ness_lucas     // if Ness, need to do action checks
        lli     at, Character.id.JNESS
        beq     t4, at, _ness_lucas     // if J Ness, need to do action checks
        lli     at, Character.id.LUCAS
        beq     t4, at, _ness_lucas     // if Lucas, need to do action checks
        lli     at, Character.id.CONKER
        beq     t4, at, _conker         // if Conker, need to do action checks
        lli     at, Character.id.MARTH
        beq     t4, at, _marth          // if Marth, need to do action checks
        nop

        b       _draw_smoke_gfx
        nop

        _fox_falco:
        // Change action for these actions
        lli     t4, Action.FOX.FireFoxAir  // same as FALCO.Action.FireBirdAir
        beq     t3, t4, _change_action
        addiu   at, r0, Action.FOX.ReflectorTurnAir // final reflector action
        lli     t4, Action.FOX.ReflectorStartAir  // same as FALCO

        _reflector_loop:
        beq     t3, t4, _change_action
        nop
        bne     at, t4, _reflector_loop
        addiu   t4, t4, 0x0001
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _kirby:
        // Change action for these actions
        lli     t4, Action.KIRBY.FinalCutter
        beq     t3, t4, _change_action
        lli     t4, Action.KIRBY.FinalCutterAir
        beq     t3, t4, _change_action
        lli     t4, Action.KIRBY.FinalCutterFall
        beq     t3, t4, _change_action
        lli     t4, Action.KIRBY.StoneFall
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _yoshi:
        // Change action for these actions
        lli     t4, Action.YOSHI.GroundPoundDrop
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _bowser:
        // Change action for these actions
        lli     t4, Bowser.Action.BowserBombDrop
        beq     t3, t4, _change_action
        // Skip for these actions
        lli     t4, Bowser.Action.BowserForwardThrow1   // same as Giga Bowser
        beq     t3, t4, _next
        lli     t4, Bowser.Action.BowserForwardThrow2   // same as Giga Bowser
        beq     t3, t4, _next
        lli     t4, Bowser.Action.BowserForwardThrow3   // same as Giga Bowser
        beq     t3, t4, _next
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _ness_lucas:
        addiu   at, r0, Action.NESS.PsiMagnetEndAir // final magnet action
        lli     t4, Action.NESS.PsiMagnetStartAir   // same as LUCAS

        _magnet_loop:
        beq     t3, t4, _psi_magnet
        nop
        bne     at, t4, _magnet_loop
        addiu   t4, t4, 0x0001

        addiu   at, r0, Action.NESS.PKTAAir          // final pk thunder action
        lli     t4, Action.NESS.PKThunderStartAir    // same as LUCAS


        _pk_thunder_loop:
        beq     t3, t4, _change_action
        nop
        bne     at, t4, _pk_thunder_loop
        addiu   t4, t4, 0x0001

        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _psi_magnet:
        sw      r0, 0x0A20(t2)                      // clear Overlay Routine
        sw      r0, 0x0A24(t2)                      // clear Overlay Routine
        sw      r0, 0x0A28(t2)                      // clear Overlay Routine
        sw      r0, 0x0A30(t2)                      // clear Overlay Flag
        sh      r0, 0x018C(t2)                      // clear space used for overlay stuff
        j       _change_action
        sw      r0, 0x0A88(t2)                      // clear current Overlay


        _marth:
        // Change action for these actions
        lli     t4, Marth.Action.DSPGA
        beq     t3, t4, _change_action
        lli     t4, Marth.Action.DSPGA_Attack
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _conker:
        // Change action for these actions
        lli     t4, Conker.Action.HelicopteryTailThingAir
        beq     t3, t4, _change_action
        lli     t4, Conker.Action.HelicopteryTailThingDescent
        beq     t3, t4, _change_action
        nop
        // Otherwise, don't change action
        b        _draw_smoke_gfx
        nop

        _change_action:
        // set player action to JumpF
        lli     a1, Action.JumpF    // a1(action id) = JumpF
        or      a2, r0, r0          // a2(starting frame) = 0
        lui     a3, 0x3F80          // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24          // change action
        sw      r0, 0x0010(sp)      // argument 4 = 0
        jal     0x800E0830          // unknown common subroutine
        lw      a0, 0x002C(sp)      // a0 = player object
        b       _set_y_velocity     // skip drawing jump smoke gfx when we change actions
        nop

        _draw_smoke_gfx:
        // draw jump smoke gfx
        lw      a0, 0x002C(sp)      // a0 = player object
        lw      a0, 0x0074(a0)      // a0 = top joint
        addiu   a0, a0, 0x001C      // a0 = player x/y/z pointer
        ori     a1, r0, 0x0001      // a1 = 0x1
        lui     a2, 0x3F80          // a2 = float: 1.0
        jal     0x800FF3F4          // jump smoke graphic
        addiu   sp, sp, -0x0010     // allocate stack space
        addiu   sp, sp, 0x0010      // restore stack space

        _set_y_velocity:
        // set initial Y velocity
        lw      t0, 0x002C(sp)      // t0 = player object
        lw      t1, 0x0084(t0)      // t1 = player struct
        lui     at, 0x4302          // at = initial Y velocity = 130
        sw      at, 0x004C(t1)      // set initial Y velocity
        sw      r0, 0x0058(t1)      // clear knockback Y velocity
        lbu     at, 0x018D(t1)      // at = bit field
        andi    at, at, 0x0007      // at = bit field & mask(0b01111111), this disables the fast fall flag
        sb      at, 0x018D(t1)      // store updated bit field

        // play spring sound
        lw      a0, 0x0028(sp)      // a0 = spring projectile object
        jal     FGM.play_           // play fgm
        lw      a0, 0x0044(a0)      // a0 = spring or classic spring fgm_id

        // do rumble
        lw      t0, 0x002C(sp)      // t0 = player object
        lw      t1, 0x0084(t0)      // t1 = player struct
        lbu     a1, 0x0023(t1)      // a1 = player type (0 = HMN, 1 = CPU)
        bnez    a1, _end_rumble     // if port is CPU, skip rumble
        lbu     a0, 0x000D(t1)      // a0 = port
        lli     a1, 0x0000          // a1 = rumble_id
        lli     a2, 0x0005          // a2 = duration
        jal     Global.rumble_      // add rumble
        addiu   sp, sp, -0x0030     // allocate stack space (not a safe function)
        addiu   sp, sp, 0x0030      // deallocate stack space

        _end_rumble:
        lw      t0, 0x002C(sp)      // t0 = player object

        // if Sonic, restore specials
        lw      t3, 0x0084(t0)      // t3 = player struct
        lw      t4, 0x0008(t3)      // t4 = char_id
        lli     at, Character.id.SONIC
        beql    t4, at, _next       // if Sonic, restore specials
        sw      r0, 0x0ADC(t3)      // set up special bool to FALSE
        lli     at, Character.id.SSONIC
        beql    t4, at, _next       // if Super Sonic, restore specials
        sw      r0, 0x0ADC(t3)      // set up special bool to FALSE

        _next:
        lw      a0, 0x0028(sp)      // a0 = spring projectile object
        b       _loop
        lw      t0, 0x0004(t0)      // t0 = next player object

        _end:
        lw      ra, 0x0024(sp)      // restore registers
        addiu   sp, sp, 0x0030      // deallocate stack space
        jr      ra
        nop
    }

    OS.align(16)
    spring_projectile_struct:
    constant SONIC_ID(0x1002)
    dw 0x00000000                           // unknown
    dw SONIC_ID                             // projectile id
    dw Character.SONIC_file_6_ptr           // address of sonic's file 6 pointer
    dw 0x00000000                           // 00000000
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
    dw spring_main_                         // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0x80169108                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw 0x80169108                           // This function runs when the projectile collides with a hurtbox.
    dw 0                                    // This function runs when the projectile collides with a shield.
    dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
    dw 0x80168A14                           // This function runs when the projectile collides/clangs with a hitbox.
    dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    spring_properties_struct:
    dw 180                                  // 0x0000 - duration (int)
    float32 100                             // 0x0004 - max speed
    float32 100                             // 0x0008 - min speed
    float32 3                               // 0x000C - gravity
    float32 1.5                             // 0x0010 - bounce multiplier
    float32 0.1875                          // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (ground)
    float32 0                               // 0x001C   initial angle (air)
    float32 0                               // 0x0020   initial speed
    dw Character.SONIC_file_6_ptr           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)
}

scope SonicDSP {
    constant MAX_CHARGE(20)
    constant MAX_CHARGE_AIR(16)
    constant BASE_SPEED(0x4258)             // current setting - float: 54.0
    constant MIN_SPEED(0x4170)              // current setting - float: 15.0
    constant JUMP_SPEED(0x4268)             // current setting - float: 58.0
    constant BASE_SPEED_SS(0x428C)          // current setting (Super Sonic) - float: 70.0
    constant MIN_SPEED_SS(0x41C8)           // current setting (Super Sonic) - float: 25.0
    constant JUMP_SPEED_SS(0x4296)          // current setting (Super Sonic) - float: 75.0
    constant GRAVITY(0x4010)                // current setting - float: 2.25
    constant SLOPE_ACCELERATION(0x4060)     // current setting - float: 3.5
    constant MAX_FALL_SPEED(0x4248)         // current setting - float: 50.0
    constant AIR_FRICTION(0x4040)           // current setting - float: 3.0
    constant GROUND_TRACTION(0x3E80)        // current setting - float: 0.25

    constant WALL_COLLISION_L(0x0001)       // bitmask for wall collision
    constant WALL_COLLISION_R(0x0020)       // bitmask for wall collision

    // @ Description
    // Initial subroutine for DSP_Ground_Charge.
    scope ground_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, Sonic.Action.DSP_Ground_Charge // a1(action id) = DSP_Ground_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.5
        lwc1    f2, 0x0060(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0060(a0)              // multiply x velocity by 0.5 and update
        sw      r0, 0x0B18(a0)              // charge level = 0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSP_Air_Charge.
    scope air_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, Sonic.Action.DSP_Air_Charge // a1(action id) = DSP_Air_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.5
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x004C(a0)              // multiply y velocity by 0.5 and update
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        sw      r0, 0x0B18(a0)              // charge level = 0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Ground_Charge
    scope ground_charge_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        // check if the a or b button are pressed to add charge level
        _check_button_press:
        lhu     t6, 0x01BE(s0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B | Joypad.A // t6 != 0 if B or A is pressed, else t6 = 0
        beqz    t6, _check_charge_variable  // skip if B or A are not pressed
        nop

        // if either the a or b button was pressed, add two charge levels and play a sound
        lw      t6, 0x0B18(s0)              // t6 = charge level
        addiu   t6, t6, 0x0002              // increase charge level by 2
        sw      t6, 0x0B18(s0)              // store updated charge level
        lbu     t6, 0x000D(s0)              // t6 = player port
        li      t7, Sonic.classic_table     // t7 = classic_table
        addu    t7, t7, t6                  // t7 = classic_table + port
        lbu     t7, 0x0000(t7)              // t7 = px is_classic
        lli     a1, 0x3D8                   // a1 = SPINDASH_CHARGE FGM
        bnezl   t7, pc() + 8                // if px is_classic = TRUE...
        lli     a1, 0x3DE                   // ...a1 = CLASSIC_SPINDASH_CHARGE FGM
        jal     0x800E8190                  // play fgm once
        or      a0, s0, r0                  // a0 = player struct

        // increase charge level by the value of temp variable 2 when it is set
        _check_charge_variable:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lw      t7, 0x0180(s0)              // t7 = temp variable 2
        addu    t6, t6, t7                  // t7 = charge level + variable value
        sw      t6, 0x0B18(s0)              // store updated charge level
        sw      r0, 0x0180(s0)              // reset temp variable 2

        // prevent the charge level from exceeeding a maximum value
        _limit_charge_level:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lli     t7, MAX_CHARGE              // t7 = MAX_CHARGE
        slt     at, t7, t6                  // at = 1 if MAX_CHARGE < charge level, else at = 0
        bnel    at, r0, _check_movement     // branch if charge level exceeds MAX_CHARGE...
        sw      t7, 0x0B18(s0)              // ...and set charge level to MAX_CHARGE

        // check if movement should begin
        // values for temp variable 1:
        // 0 - can't begin movement
        // 1 - can begin movement
        // 2 - force movement
        _check_movement:
        lw      t6, 0x017C(s0)              // t6 = temp variable 1
        beqz    t6, _end                    // skip if temp variable 1 = 0
        lli     at, 0x0001                  // at = 1
        bne     t6, at, _begin_movement     // force movement if temp variable 1 != 1
        nop

        // check if the stick is being held down
        _check_stick:
        lb      t6, 0x01C3(s0)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnez    at, _end                    // skip if stick_y =< -40
        nop

        // check if sonic is holding b
        _check_b_held:
        lh      t6, 0x01BC(s0)              // t7 = buttons_held
        andi    t6, t6, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t6, _end                    // skip if (B_HELD)
        nop

        // if we're here, then transition into DSP_Ground_Move
        _begin_movement:
        jal     ground_move_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Air_Charge
    scope air_charge_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        // check if the a or b button are pressed to add charge level
        _check_button_press:
        lhu     t6, 0x01BE(s0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B | Joypad.A // t6 != 0 if B or A is pressed, else t6 = 0
        beqz    t6, _check_charge_variable  // skip if B or A are not pressed
        nop


        // if either the a or b button was pressed, add two charge levels and play a sound
        lw      t6, 0x0B18(s0)              // t6 = charge level
        addiu   t6, t6, 0x0002              // increase charge level by 2
        sw      t6, 0x0B18(s0)              // store updated charge level
        lbu     t6, 0x000D(s0)              // t6 = player port
        li      t7, Sonic.classic_table     // t7 = classic_table
        addu    t7, t7, t6                  // t7 = classic_table + port
        lbu     t7, 0x0000(t7)              // t7 = px is_classic
        lli     a1, 0x3D8                   // a1 = SPINDASH_CHARGE FGM
        bnezl   t7, pc() + 8                // if px is_classic = TRUE...
        lli     a1, 0x3DE                   // ...a1 = CLASSIC_SPINDASH_CHARGE FGM
        jal     0x800E8190                  // play fgm once
        or      a0, s0, r0                  // a0 = player struct

        // increase charge level by the value of temp variable 2 when it is set
        _check_charge_variable:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lw      t7, 0x0180(s0)              // t7 = temp variable 2
        addu    t6, t6, t7                  // t7 = charge level + variable value
        sw      t6, 0x0B18(s0)              // store updated charge level
        sw      r0, 0x0180(s0)              // reset temp variable 2

        // prevent the charge level from exceeeding a maximum value
        _limit_charge_level:
        lw      t6, 0x0B18(s0)              // t6 = charge level
        lli     t7, MAX_CHARGE_AIR          // t7 = MAX_CHARGE_AIR
        slt     at, t7, t6                  // at = 1 if MAX_CHARGE_AIR < charge level, else at = 0
        bnel    at, r0, _check_cancel       // branch if charge level exceeds MAX_CHARGE_AIR...
        sw      t7, 0x0B18(s0)              // ...and set charge level to MAX_CHARGE_AIR

        // check if cancel should begin
        // values for temp variable 1:
        // 0 - can't begin cancel
        // 1 - can begin cancel
        // 2 - force cancel
        _check_cancel:
        lw      t6, 0x017C(s0)              // t6 = temp variable 1
        beqz    t6, _end                    // skip if temp variable 1 = 0
        lli     at, 0x0001                  // at = 1
        bne     t6, at, _begin_cancel       // force cancel if temp variable 1 != 1
        nop

        // check if the stick is being held down
        _check_stick:
        lb      t6, 0x01C3(s0)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnez    at, _end                    // skip if stick_y =< -40
        nop

        // check if sonic is holding b
        _check_b_held:
        lh      t6, 0x01BC(s0)              // t7 = buttons_held
        andi    t6, t6, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t6, _end                    // skip if (B_HELD)
        nop

        // if we're here, then transition into DSP_Air_End
        _begin_cancel:
        jal     air_end_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSP_Ground_Charge.
    scope ground_charge_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_charge_transition_  // a1(transition subroutine) = air_charge_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSP_Air_Charge.
    scope air_charge_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_charge_transition_ // a1(transition subroutine) = ground_charge_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_Charge or DSP_Ground_Move.
    scope ground_charge_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct


        // if Sonic has built enough charge, then allow movement to begin instantly upon hitting the ground
        _check_charge:
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      t6, 0x0B18(a0)              // t6 = charge level
        sltiu   at, t6, 6                   // at = 1 if charge level < 6, else at = 0
        bnez    at, _transition_to_charge   // if charge level is less than 6, then don't begin movement
        nop

        // if we're here, then transition into DSP_Ground_Move
        _begin_movement:
        jal     ground_move_initial_
        lw      a0, 0x0038(sp)              // a0 = player object
        b       _end                        // branch to end
        nop

        _transition_to_charge:
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sonic.Action.DSP_Ground_Charge // a1(action id) = DSP_Ground_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0


        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Air_Charge.
    scope air_charge_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sonic.Action.DSP_Air_Charge // a1(action id) = DSP_Air_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSP_Ground_Move
    scope ground_move_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, Sonic.Action.DSP_Ground_Move // a1(action id) = DSP_Ground_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        ori     at, r0, Character.id.SSONIC // at = SSONIC
        lw      t8, 0x0008(a0)              // load character id
        beql    t8, at, _move_base
        lui     at, BASE_SPEED_SS           // ~
        lui     at, BASE_SPEED              // ~
        _move_base:
        mtc1    at, f2                      // f2 = BASE_SPEED
        lw      at, 0x0B18(a0)              // ~
        sll     at, at, 0x2                 // ~
        mtc1    at, f4                      // ~
        cvt.s.w f4, f4                      // f4 = charge level * 4
        add.s   f2, f2, f4                  // f2 = BASE_SPEED + (charge level * 4)
        swc1    f2, 0x0060(a0)	            // ground x velocity = BASE_SPEED + (charge level * 4)
        lwc1    f4, 0x0044(a0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = ground x velocity * DIRECTION
        swc1    f2, 0x0048(a0)              // x velocity = ground x velocity * DIRECTION
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSP_Air_Move
    scope air_move_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        lli     a1, Sonic.Action.DSP_Air_Move // a1(action id) = DSP_Air_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Ground_Move
    scope ground_move_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        // adjust sonic's speed based on the angle of the slope he's spinning on
        jal     0x80161478                  // f0 = slope angle
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800303F0                  // f0 = sin(f12)
        mov.s   f12, f0                     // f12 = slope angle
        lui     at, SLOPE_ACCELERATION      // ~
        mtc1    at, f2                      // f2 = SLOPE_ACCELERATION
        lwc1    f4, 0x0044(s0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        neg.s   f4, f4                      // f4 = -DIRECTION
        mul.s   f2, f2, f0                  // f2 = SLOPE_ACCELERATION * sin(slope angle)
        mul.s   f2, f2, f4                  // f2 = speed difference = (SLOPE_ACCELERATION * sin(slope angle)) * -DIRECTION
        lwc1    f4, 0x0060(s0)              // f4 = ground x velocity
        add.s   f4, f4, f2                  // f4 = current x velocity + calculated speed difference
        swc1    f4, 0x0060(s0)              // update ground x velocity

        // adjust the animation speed based on sonic's movement speed
        lui     at, 0x41A0                  // ~
        mtc1    at, f2                      // f2 = 20
        add.s   f4, f4, f2                  // f2 = ground x velocity + 20
        lui     at, 0x3C22                  // ~
        mtc1    at, f2                      // f2 = 0.01
        mul.s   f2, f2, f4                  // f2 = FSM = (ground x velocity + 10) * 0.01
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      t0, 0x0074(a0)              // t0 = top joint struct
        lw      t1, 0x0078(t0)              // t1 = top joint frame speed multiplier
        lui     t2, 0x3F80                  // t2 = 1.0
        beql    t1, t2, pc() + 8            // if top joint fsm = 1.0...
        addiu   t1, t2, 0x0001              // ...set top joint fsm to 3F800001 so it resets on action change
        sw      t1, 0x0078(t0)              // update top joint FSM
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x08F8(t0)              // t1 = joint 0 struct
        swc1    f2, 0x0078(t1)              // set joint 0 FSM
        lw      t1, 0x08FC(t0)              // t1 = joint 1 struct
        swc1    f2, 0x0078(t1)              // set joint 1 FSM

        // check if sonic's speed is below minimum
        ori     at, r0, Character.id.SSONIC // at = id.SSONIC
        lw      t8, 0x0008(s0)              // t8 = character id
        lui     t0, MIN_SPEED               // t0 = MIN_SPEED
        beql    t8, at, pc() + 8            // if character = SSONIC...
        lui     t0, MIN_SPEED_SS            // ...use MIN_SPEED_SS insead
        mtc1    t0, f2                      // f2 = MIN_SPEED
        lwc1    f4, 0x0060(s0)              // f4 = ground x velocity
        c.le.s  f4, f2                      // ~
        nop                                 // ~
        bc1fl   _jump_check                 // branch if MIN_SPEED =< ground x velocity
        nop

        // if we're here, sonic is below minimum speed so transition to DSP_Ground_End
        _end_movement:
        jal     ground_end_initial_
        lw      a0, 0x0018(sp)              // a0 = player object
        b       _end                        // branc to end
        nop

        _jump_check:
        jal     0x8013F474                  // check jump (returns 0 for no jump)
        or      a0, s0, r0                  // a0 = player struct
        beq     v0, r0, _end                // skip if !jump
        nop

        // if we're here then sonic has input a jump, so transition to DSP_Air_Jump
        jal     air_jump_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // load ra, s0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Air_Move and DSP_Air_Jump.
    scope air_move_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        jal     0x800D94E8                  // main subroutine which transitions to fall on animation end
        nop

        // adjust the animation speed based on sonic's movement speed
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      t8, 0x0084(a0)              // t8 = player struct
        lwc1    f4, 0x0048(t8)              // ~
        mul.s   f4, f4, f4                  // ~
        lwc1    f6, 0x004C(t8)              // ~
        mul.s   f6, f6, f6                  // ~
        add.s   f4, f4, f6                  // ~
        sqrt.s  f4, f4                      // f4 = absolute speed
        lui     at, 0x41A0                  // ~
        mtc1    at, f2                      // f2 = 20
        add.s   f4, f4, f2                  // f2 = absolute speed + 20
        lui     at, 0x3C22                  // ~
        mtc1    at, f2                      // f2 = 0.01
        mul.s   f2, f2, f4                  // f2 = FSM = (absolute speed + 20) * 0.01
        lw      t0, 0x0074(a0)              // t0 = top joint struct
        lw      t1, 0x0078(t0)              // t1 = top joint frame speed multiplier
        lui     t2, 0x3F80                  // t2 = 1.0
        beql    t1, t2, pc() + 8            // if top joint fsm = 1.0...
        addiu   t1, t2, 0x0001              // ...set top joint fsm to 3F800001 so it resets on action change
        sw      t1, 0x0078(t0)              // update top joint FSM
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x08F8(t0)              // t1 = joint 0 struct
        swc1    f2, 0x0078(t1)              // set joint 0 FSM
        lw      t1, 0x08FC(t0)              // t1 = joint 1 struct
        swc1    f2, 0x0078(t1)              // set joint 1 FSM

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Interrupt subroutine for DSP_Air_Move and DSP_Air_Jump.
    scope air_move_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0184(t6)              // t6 = temp variable 3
        beqz    t6, _end                    // skip if temp variable 3 is not set
        nop

        // if we're here then Sonic is now considered actionable, so allow interrupts
        _interrupt:
        jal      0x8013F660                 // jump interrupt subroutine
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Physics subroutine for DSP_Ground_Move
    // Copy of subroutine 0x800D8BB4, loads a hard-coded traction value instead of the character's
    // traction value.
    scope ground_move_physics_: {
        // Copy the first 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543B4, 0x28)
        // Replace original lines which load the base friction from the friction table
        constant UPPER(Surface.friction_table >> 16)
        constant LOWER(Surface.friction_table & 0xFFFF)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        // Replace original line which loads the character's grounded tracion value
        // lwc1 f6, 0x0024(v0)              // replaced line
        lui     a1, GROUND_TRACTION         // ~
        mtc1    a1, f6                      // f6 = GROUND_TRACTION
        // Copy the last 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543EC, 0x28)
    }

    // @ Description
    // Physics subroutine for DSP_Air_Move and DSP_Air_Jump.
    // Restores player control when temp variable 3 = 1
    scope air_movement_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0184(t6)              // t6 = temp variable 3
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t6, _subroutine             // branch if temp variable 3 is set
        nop

        // if we're here then Sonic is still locked into movement, so use a special physics subroutine
        li      t8, air_move_physics_

        // if we're here then Sonic is now considered actionable, so do a normal transition on landing
        _subroutine:
        jalr    t8                          // run physics subroutine
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Physics subroutine for non-actionable aerial movement
    // Modified version of subroutine 0x800D91EC.
    scope air_move_physics_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      s1, 0x0018(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        lw      s0, 0x0084(a0)              // ~
        lw      s1, 0x09C8(s0)              // ~
        or      a0, s0, r0                  // original lines
        or      a3, s1, r0                  // a3
        lui     a1, GRAVITY                 // a1 = GRAVITY
        jal     0x800D8D68                  // apply gravity/fall speed
        lui     a2, MAX_FALL_SPEED          // a2 = MAX_FALL_SPEED

        // Subroutine 0x800D9074 applies air friction. Usually, air friction is loaded from
        // 0x0054(a1), with a1 being the attribute pointer for the character. In this case, a
        // different air friction value is stored at 0x0054(sp) and then the stack pointer is
        // passed to a1 for subroutine 0x800D9074.
        or      a0, s0, r0                  // a0 = player struct
        addiu   sp, sp,-0x0058              // allocate stack space
        lui     a1, AIR_FRICTION            // a1 = AIR_FRICTION
        sw      a1, 0x0054(sp)              // store AIR_FRICTION
        jal     0x800D9074                  // apply air friction
        or      a1, sp, r0                  // a1 = stack pointer
        addiu   sp, sp, 0x0058              // deallocate stack space
        lw      ra, 0x001C(sp)              // ~
        lw      s1, 0x0018(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        jr      ra                          // ~
        addiu   sp, sp, 0x0020              // original return logic
    }

    // @ Description
    // Collision subroutine for DSP_Ground_Move.
    scope ground_move_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_move_initial_       // a1(transition subroutine) = air_move_initial_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        sw      a0, 0x0018(sp)              // store a0

        beqz    v0, _end                    // skip if air transition occured
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _end                // skip if !WALL_COLLISION
        nop

        // if Sonic is colliding with a wall, end movement
        jal     ground_end_initial_
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for for DSP_Air_Move and DSP_Air_Jump.
    scope air_move_collision_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t6, 0x0184(t6)              // t6 = temp variable 3
        bnez    t6, _interrupt              // branch if temp variable 3 is set
        nop

        // if we're here then Sonic is still locked into movement, so transition to DSP_Ground_Move
        _transition:
        li      a1, ground_move_transition_ // a1(transition subroutine) = ground_move_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        b       _end                        // end subroutine
        nop

        // if we're here then Sonic is now considered actionable, so do a normal transition on landing
        _interrupt:
        jal      0x800DE99C                 // air collision subroutine (cancel on landing)
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_Move.
    scope ground_move_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sonic.Action.DSP_Ground_Move // a1(action id) = DSP_Ground_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }


    // @ Description
    // Initial subroutine for DSP_Air_Jump
    scope air_jump_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        lli     a1, Sonic.Action.DSP_Air_Jump // a1(action id) = DSP_Air_Move
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

        // apply jump velocity
        lw      a0, 0x0018(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct

        ori     at, r0, Character.id.SSONIC // at = SSONIC
        lw      t8, 0x0008(a0)              // load character id
        beql    t8, at, _move_jump
        lui     at, JUMP_SPEED_SS           // ~
        lui     at, JUMP_SPEED              // at = JUMP_SPEED

        _move_jump:
        sw      at, 0x004C(a0)              // y velocity = JUMP_SPEED
        // create gfx
        lw      a0, 0x0078(a0)              // a0 = player x/y/z pointer
        ori     a1, r0, 0x0001              // a1 = 0x1
        jal     0x800FF3F4                  // jump smoke graphic
        lui     a2, 0x3F80                  // a2 = float: 1.0

        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSP_Ground_End.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, Sonic.Action.DSP_Ground_End // a1(action id) = DSP_Ground_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSP_Air_End.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, Sonic.Action.DSP_Air_End // a1(action id) = DSP_Air_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSP_Ground_End.
    scope ground_end_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_end_transition_     // a1(transition subroutine) = air_end_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSP_Air_End.
    scope air_end_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_end_transition_  // a1(transition subroutine) = ground_end_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Ground_End.
    scope ground_end_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sonic.Action.DSP_Ground_End // a1(action id) = DSP_Ground_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to DSP_Air_End.
    scope air_end_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sonic.Action.DSP_Air_End // a1(action id) = DSP_Air_End
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }
}
