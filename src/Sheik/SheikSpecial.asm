// SheikSpecial.asm

// This file contains subroutines used by Sheik's special moves.

// @ Description
// Subroutines for Up Special
scope SheikUSP {
    constant DEFAULT_ANGLE(0x3FC90FDB) // float 1.570796 rads
    constant LANDING_FSM(0x3EBD3000) // float 0.37 (makes it 30 frames)
    constant INITIAL_SPEED(0x4296) // float 75
    constant SPEED(0x438C) // float 280

    // @ Description
    // Subroutine which runs when Sheik initiates a grounded up special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Sheik.Action.USPG_BEGIN // a1(action id) = USP_Ground_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
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
    // Subroutine which runs when Sheik initiates an aerial up special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Sheik.Action.USPA_BEGIN // a1(action id) = USP_Air_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.5
        lwc1    f2, 0x0048(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0048(a0)              // multiply x velocity by 0.5 and update
        lui     at, INITIAL_SPEED           // at = INITIAL_SPEED
        sw      at, 0x004C(a0)              // y velocity = INITIAL_SPEED
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // Main subroutine for USP_Ground_Begin and USP_Air_Begin
    scope begin_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      t8, 0x014C(a2)              // t8 = kinetic state
        li      a1, move_initial_           // a1(transition subroutine) = move_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for USP_Ground_Begin.
    scope ground_begin_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_begin_transition_   // a1(transition subroutine) = air_begin_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for USP_Air_Begin.
    scope air_begin_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0010(sp)              // save object
        sw      s1, 0x0008(sp)
        sw      a1, 0x000c(sp)

        _first:
        li      a1, ground_begin_transition_ // a1(transition subroutine) = ground_begin_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Physics subroutine for USP_Air_Begin.
    scope air_begin_physics_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to USP_Ground_Begin.
    scope ground_begin_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sheik.Action.USPG_BEGIN // a1(action id) = USP_Ground_Begin
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
    // Subroutine which transitions to USP_Air_Begin.
    scope air_begin_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sheik.Action.USPA_BEGIN // a1(action id) = USP_Air_Begin
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
    // Subroutine which begins Sheik's up special movement actions.
    scope move_initial_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store a0, s0, ra
        lw      s0, 0x0084(a0)              // s0 = player struct
        lb      v0, 0x01C2(s0)              // v0 = stick_x
        bltzl   v0, _check_turnaround       // branch if stick_x is negative...
        subu    v0, r0, v0                  // ...and make stick_x positive

        _check_turnaround:
        // v0 = absolute stick_x
        slti    at, v0, 0x000B              // at = 1 if absolute stick_x < 11, else at = 0
        bnez    at, _check_deadzone         // skip if absolute stick_x < 11
        nop
        jal     0x800E8044                  // apply turnaround
        or      a0, s0, r0                  // a0 = player struct

        _check_deadzone:
        lw      t8, 0x014C(s0)              // t8 = kinetic state
        sw      t8, 0x0028(sp)              // 0x0028(sp) = kinetic state
        lb      t0, 0x01C2(s0)              // t0 = stick_x
        lb      t1, 0x01C3(s0)              // t1 = stick_y
        multu   t0, t0                      // ~
        mflo    t2                          // t2 = stick_x ^ 2
        multu   t1, t1                      // ~
        mflo    t3                          // t3 = stick_y ^ 2
        addu    t2, t2, t3                  // ~
        mtc1    t2, f12                     // ~
        cvt.s.w f12, f12                    // ~
        sqrt.s  f12, f12                    // f12 = absolute stick input
        cvt.w.s f12, f12                    // ~
        mfc1    t2, f12                     // t2 = absolute stick input (int)
        slti    at, t2, 0x000B              // at(use_default_angle) = 1 if absolute stick < 11, else at = 0
        sw      at, 0x002C(sp)              // 0x002C(sp) = use_default_angle
        bnez    at, _aerial                 // branch if use_default_angle = 1
        nop

        bnez    t8, _change_action          // skip if kinetic state !grounded
        lli     a1, Sheik.Action.USPA_MOVE // a1(action id) = USPA_MOVE

        _grounded:
        lb      t0, 0x01C3(s0)              // t0 = stick_y
        bnez    t0, _aerial                 // branch if stick_y = 0
        lli     a1, Sheik.Action.USPA_MOVE // a1(action id) = USPA_MOVE
        lb      t0, 0x01C2(s0)              // t0 = stick_x
        beqz    t0, _aerial                 // branch if stick_x = 0
        lli     a1, Sheik.Action.USPA_MOVE // a1(action id) = USPA_MOVE

        // if we're here, stick_y is 0 and stick_x is not 0, so use grounded action
        b       _change_action              // change action
        lli     a1, Sheik.Action.USPG_MOVE // a1(action id) = USPG_MOVE

        _aerial:
        jal     0x800DEEC8                  // set aerial state
        or      a0, s0, r0                  // a0 = player struct
        lli     a1, Sheik.Action.USPA_MOVE // a1(action id) = USPA_MOVE

        _change_action:
        sw      r0, 0x0060(s0)              // ground x velocity = 0
        sw      r0, 0x0048(s0)              // x velocity = 0
        sw      r0, 0x004C(s0)              // y velocity = 0
        lw      a0, 0x0020(sp)              // a0 = player object
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object

        // take mid-air jumps away at this point
        lw      t0, 0x09C8(s0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(s0)              // jumps used = max jumps
        li      t0, DEFAULT_ANGLE           // t0 = DEFAULT_ANGLE
        lw      at, 0x002C(sp)              // at = use_default_angle
        bnez    at, _movement               // branch if use_default_angle = 1
        sw      t0, 0x0B20(s0)              // store DEFAULT_ANGLE

        _continue:
        lb      t0, 0x01C2(s0)              // t0 = stick_x
        lb      t1, 0x01C3(s0)              // t1 = stick_y
        lw      t2, 0x0044(s0)              // t2 = direction
        multu   t0, t2                      // ~
        mflo    t0                          // t0 = stick_x * direction
        mtc1    t1, f12                     // ~
        mtc1    t0, f14                     // ~
        cvt.s.w f12, f12                    // f12 = stick y
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        cvt.s.w f14, f14                    // f14 = stick x * direction
        swc1    f0, 0x0B20(s0)              // store movement angle

        _movement:
        or      a0, s0, r0                  // a0 = player struct
        lli     at, 000012                  // at = 12
        jal     apply_movement_             // apply movement
        sw      at, 0x0B18(a0)              // set movement timer to 12

        _visibility:
        lbu     at, 0x018D(s0)              // at = bit field
        ori     at, at, 0x0001              // enable bitflag for invisibility
        sb      at, 0x018D(s0)              // update bit field
        li      t0, CharEnvColor.moveset_table
        lbu     t1, 0x000D(s0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = offset to env color override value
        addu    t0, t0, t1                  // t0 = address of env color override value
        li      t1, 0xFFFFFF00              // env color for full transparency
        sw      t1, 0x0000(t0)              // store updated env color

        _intangibility:
        lli     t0, 0x0003                  // ~
        sb      t0, 0x05BB(s0)              // set hurtbox state to 0x0003(intangible)

        _platform:
        lw      at, 0x0028(sp)              // at = kinetic state
        bnez    at, _end                    // skip if kinetic state was !grounded
        nop

        // if the original kinetic state was grounded, this will allow dropping through platforms
        lw      t8, 0x00EC(s0)              // t8 = platform ID
        sw      t8, 0x0144(s0)              // allows pass through given ID?


        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0024(sp)              // load s0
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for USPG_MOVE and USPA_MOVE.
    scope move_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // store
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x0B18(v0)              // t6 = movement timer
        addiu   t6, t6,-0x0001              // decrement timer
        bnez    t6, _end                    // skip if timer !0
        sw      t6, 0x0B18(v0)              // update movement timer

        // If we're here, then the movement timer has ended, so transition to ending animation
        lw      t6, 0x014C(v0)              // t6 = kinetic state
        bnez    t6, _aerial                 // branch if kinetic state !grounded
        nop

        _grounded:
        jal     ground_end_initial_         // transition to USPG_END
        nop
        b       _end                        // end
        nop

        _aerial:
        jal     air_end_initial_            // transition to USPA_END
        nop

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Physics subroutine for USPG_MOVE and USPA_MOVE.
    scope move_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     apply_movement_             // apply movement
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for USPG_MOVE.
    scope ground_move_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_move_transition_    // a1(transition subroutine) = air_move_transition_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for USPA_MOVE.
    scope air_move_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_move_transition_ // a1(transition subroutine) = ground_move_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to USPG_MOVE.
    scope ground_move_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sheik.Action.USPG_MOVE // a1(action id) = USPG_MOVE
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0

        _visibility:
        lw      a0, 0x0034(sp)              // a0 = player struct
        lbu     at, 0x018D(a0)              // at = bit field
        ori     at, at, 0x0001              // enable bitflag for invisibility
        sb      at, 0x018D(a0)              // update bit field
        li      t0, CharEnvColor.moveset_table
        lbu     t1, 0x000D(a0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = offset to env color override value
        addu    t0, t0, t1                  // t0 = address of env color override value
        li      t1, 0xFFFFFF00              // env color for full transparency
        sw      t1, 0x0000(t0)              // store updated env color

        _intangibility:
        lli     t0, 0x0003                  // ~
        sb      t0, 0x05BB(a0)              // set hurtbox state to 0x0003(intangible)

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to USPA_MOVE.
    scope air_move_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Sheik.Action.USPA_MOVE  // a1(action id) = USPA_MOVE
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player struct
        sw      r0, 0x0B20(a0)              // set angle to 0

        _visibility:
        lbu     at, 0x018D(a0)              // at = bit field
        ori     at, at, 0x0001              // enable bitflag for invisibility
        sb      at, 0x018D(a0)              // update bit field
        li      t0, CharEnvColor.moveset_table
        lbu     t1, 0x000D(a0)              // t1 = port
        sll     t1, t1, 0x0002              // t1 = offset to env color override value
        addu    t0, t0, t1                  // t0 = address of env color override value
        li      t1, 0xFFFFFF00              // env color for full transparency
        sw      t1, 0x0000(t0)              // store updated env color

        _intangibility:
        lli     t0, 0x0003                  // ~
        sb      t0, 0x05BB(a0)              // set hurtbox state to 0x0003(intangible)

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Sheik's grounded up special ending action.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Sheik.Action.USPG_END // a1(action id) = USPG_END
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
        lwc1    f2, 0x0060(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0060(a0)              // multiply x velocity by 0.25 and update
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Sheik's aerial up special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Sheik.Action.USPA_END // a1(action id) = USPA_END
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t0, 0x3DE0                  // ~
        mtc1    t0, f0                      // f0 = 0.109
        lwc1    f2, 0x0048(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0048(a0)              // multiply x velocity by 0.109 and update
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x004C(a0)              // multiply y velocity by 0.109 and update
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for USPA_END.
    // Transitions to special fall on animation end, and makes the character invisible if temp variable 3 is set.
    scope air_end_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store a0, ra

        jal     end_invisibility_           // check for invisibility
        lw      a0, 0x0084(a0)              // a0 = player struct

        // checks the current animation frame to see if we've reached end of the animation
        lw      a0, 0x0028(sp)              // a0 = player object
        lwc1    f6, 0x0078(a0)              // ~
        mtc1    r0, f4                      // ~
        c.le.s  f6, f4                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        lli     t6, OS.TRUE                 // ~
        sw      t6, 0x0018(sp)              // interrupt flag = TRUE
        lui     t6, 0x3F00                  // t6 = 0.5
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store fsm of 0.5
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for USPG_END.
    // Transitions to idle on animation end, and makes the character invisible if temp variable 3 is set.
    scope ground_end_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        jal     end_invisibility_           // check for invisibility
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800D94C4                  // check for idle transition
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which makes the character invisible if temp variable 3 is set during up special ending actions.
    // a0 - player struct
    scope end_invisibility_: {
        lbu     at, 0x018D(a0)              // at = bit field
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        beqz    t0, _end                    // branch if temp variable 3 = 0
        andi    at, at, 0xFFFE              // disable bitflag for invisibility
        // if temp variable 3 is set
        ori     at, at, 0x0001              // enable bitflag for invisibility

        _end:
        jr      ra                          // return
        sb      at, 0x018D(a0)              // update bit field
    }

    // @ Description
    // Collision subroutine for USPG_END and USPA_END.
    // Based on subroutine 0x8015DD58, which is the collision subroutine for Samus' up special.
    // Modified to load Sheik's landing FSM value.
    scope end_collision_: {
        // Copy the first 26 lines of subroutine 0x8015DD58
        OS.copy_segment(0xD8798, 0x68)
        lli     a1, OS.FALSE                // interrupt flag = FALSE
        lui     a2, LANDING_FSM >> 16       // load upper 2 bytes of LANDING_FSM
        // Copy the next 7 lines
        OS.copy_segment(0xD8808, 0x1C)
        jal     0x80142E3C                  // original line, landing transition
        addiu   a2, a2, LANDING_FSM & 0xFFFF// load lower 2 bytes of LANDING_FSM
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _grounded:
        jal     0x800DDEE8                  // grounded subroutine
        nop
        lw      ra, 0x0014(sp)

        _end:
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which applies movement to Sheik's up special based on the angle stored at 0x0B20 in the player struct.
    // a0 - player struct
    scope apply_movement_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      t1, 0xB18(a0)               // load timer
        slti    t1, t1, 0x0006              // shift to determine if enough time has passed to move_initial_
        beqz    t1, _end                    // if not enough time, skip movement

        lui     at, SPEED                   // ~
        sw      at, 0x0018(sp)              // 0x0018(sp) = SPEED
        lw      at, 0x0B20(a0)              // ~
        sw      at, 0x001C(sp)              // 0x001C(sp) = movement angle
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player struct

        // ultra64 cosf function
        jal     0x80035CD0                  // f0 = cos(f12)
        lwc1    f12, 0x001C(sp)             // f12 = movement angle
        lwc1    f4, 0x0018(sp)              // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = x velocity (SPEED * cos(angle))
        swc1    f4, 0x0024(sp)              // 0x0024(sp) = x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x001C(sp)             // f12 = movement angle
        lwc1    f4, 0x0018(sp)              // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = y velocity (SPEED * sin(angle))

        lw      at, 0x0020(sp)              // at = player struct
        lw      t0, 0x014C(at)              // t0 = kinetic state
        bnez    t0, _aerial                 // branch if kinetic state !grounded
        lwc1    f2, 0x0024(sp)              // f2 = x velocity

        _grounded:
        swc1    f2, 0x0060(at)              // store updated ground x velocity
        lwc1    f0, 0x0044(at)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f2, f0                  // f2 = x velocity * direction
        b       _end                        // end
        swc1    f2, 0x0048(at)              // store updated air x velocity

        _aerial:
        lwc1    f0, 0x0044(at)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f2, f0                  // f2 = x velocity * direction
        swc1    f2, 0x0048(at)              // store updated x velocity
        swc1    f4, 0x004C(at)              // store updated y velocity

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Sheik's horizontal control for up special end.
    // based on 0x800D91EC
    // s1 = player struct
    // a2 = other player struct?
    scope end_physics_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      a1, 0x000C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        lw      s0, 0x0084(a0)              // load player struct
        lw      t6, 0x0180(s0)              // load variable 2
        lw      s1, 0x09C8(s0)              // load attribute pointer
        or      a0, s0, r0                  // place player struct into a0
        beqz    t6, _no_drift               // branch if variable not active yet
        or      a1, s1, r0                  // place attribute pointer into a1

        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      a2, 0x004C(s1)              // a2 = air acceleration
        lw      a3, 0x0050(s1)              // a3 = max air speed

        _continue:
        jal     0x800D8FC8                  // air drift subroutine?
        nop

        _no_drift:
        jal     0x800D8E50                  // set vertical velocity
        or      a1, s1, r0
        or      a0, s0, r0
        jal     0x800D8FA8
        or      a1, s1, r0
        bnez    v0, _end
        or      a0, s0, r0
        jal     0x800D9074                  // apply air friction
        or      a1, s1, r0

        _end:
        lw      a1, 0x000C(sp)
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)
        lw      s1, 0x0018(sp)
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }
}

// @ Description
// Subroutines for Sheik Neutral special.
scope SheikNSP {
    constant NEEDLE_DURATION(18)

    // @ Description
    // Subroutine which runs when Sheik initiates a grounded neutral special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Begin

        lli     a1, Sheik.Action.NSPG_BEGIN // a1(action id) = NSP_Ground_Begin
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Sheik initiates an aerial neutral special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Begin

        lli     a1, Sheik.Action.NSPA_BEGIN // a1(action id) = NSP_Air_Begin
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine for when Sheik initiates a neutral special.
    // Based on subroutine 0x8015DB64, which is the initial subroutine for Samus' grounded neutral special.
    // a0 - player object
    // a1 - action id
    scope begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0028(sp)              // a0 = player object


        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop

        _kirby:
        jal     0x801576B4                  // kirby's on hit subroutine setup
        or      a0, s0, r0                  // a0 = player struct
        b       _continue                   // branch
        nop

        _sheik:
        jal     0x8015DB4C                  // on hit subroutine setup
        or      a0, s0, r0                  // a0 = player struct

        _continue:
        lw      t7, 0x0AE0(s0)              // t7 = charge level
        lli     at, 0x0006                  // at = 0x0006
        lli     t8, 0x0001                  // t8 = 0x0001
        bnel    t7, at, _end                // end if charge level != 6(max)
        sw      r0, 0x0B18(s0)              // set transition bool to 0 (charge)

        // if we're here, the neutral special is fully charged, so set transition bool to shoot
        sw      t8, 0x0B18(s0)              // set transition bool to 1 (shoot)

        _end:
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for NSP_Ground_Begin and NSP_Air_Begin.
    // Based on subroutine 0x8015D3EC, which is the main subroutine for Samus's NSPG_Begin and NSPA_Begin actions.
    scope begin_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0030(sp)              // store ra, a0
        lw      v0, 0x0084(a0)              // v0 = player struct
        // checks the current animation frame to see if we've reached end of the animation
        lwc1    f6, 0x0078(a0)              // ~
        mtc1    r0, f4                      // ~
        c.le.s  f6, f4                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0014(sp)              // load ra
        lw      t6, 0x014C(v0)              // t6 = kinetic state (0 = grounded, 1 = aerial)
        beq     t6, r0, _grounded           // branch if kinetic state = grounded
        lw      t7, 0x0B18(v0)              // t7 = transition bool (0 = charge, 1 = shoot)

        _aerial:
        bnez    t7, _air_shoot              // branch if transition bool = shoot
        nop

        _air_charge:
        jal     air_charge_initial_         // air_charge_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _air_shoot:
        jal     air_shoot_initial_          // air_shoot_initial_
        lw      a0, 0x0030(sp)              // a0 = player object
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra


        _grounded:
        bnez    t7, _ground_shoot           // branch if transition bool = shoot
        nop

        _ground_charge:
        jal     ground_charge_initial_      // ground_charge_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _ground_shoot:
        jal     ground_shoot_initial_       // ground_shoot_initial_
        lw      a0, 0x0030(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Interupt subroutine for NSP_Ground_Begin.
    scope ground_begin_interrupt_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw             v0, 0x0084 (a0)          // load player struct
        addiu          t0, r0, 0x0001
        lhu            v1, 0x01be (v0)
        lhu            t6, 0x01b6 (v0)
        and            t7, v1, t6
        
        bnezl          t7, _cancel_check
        sw             t0, 0x0b18 (v0)
        lhu            t8, 0x01b4 (v0)
        and            t9, v1, t8
        
        beqz           t9, _cancel_check
        nop            
        sw             t0, 0x0b18 (v0)
        
        _cancel_check:       
        // now check if Shield button has been pressed
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed       
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end                // end if shield is not pressed
        lw      ra, 0x0014(sp)              // load ra

        // if we're here, Z has been pressed, so transition to fall
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        jal     0x8013E1C8                  // transition to idle
        lw      a0, 0x0020(sp)              // a0 = player object
        
        
        _end:
        lw      ra, 0x0014(sp)              // store ra
        addiu   sp, sp,0x0020              // allocate stack space
        jr             ra
        nop            
    }
    
    // @ Description
    // Interupt subroutine for NSP_Ground_Air.
    scope air_begin_interrupt_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw             v0, 0x0084 (a0)          // load player struct
        addiu          t0, r0, 0x0001
        lhu            v1, 0x01be (v0)
        lhu            t6, 0x01b6 (v0)
        and            t7, v1, t6
        
        bnezl          t7, _cancel_check
        sw             t0, 0x0b18 (v0)
        lhu            t8, 0x01b4 (v0)
        and            t9, v1, t8
        
        beqz           t9, _cancel_check
        nop            
        sw             t0, 0x0b18 (v0)
        
        _cancel_check:       
        // now check if Shield button has been pressed
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed       
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end                // end if shield is not pressed
        lw      ra, 0x0014(sp)              // load ra

        // if we're here, Z has been pressed, so transition to fall
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        jal     0x8013F9E0                  // transition to fall
        lw      a0, 0x0020(sp)              // a0 = player object
        
        _end:
        lw      ra, 0x0014(sp)              // store ra
        addiu   sp, sp,0x0020              // allocate stack space
        jr      ra
        nop            
    }

    // @ Description
    // Collision subroutine for NSP_Ground_Begin.
    scope ground_begin_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_begin_transition_   // a1(transition subroutine) = air_charge_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for Kirby's NSP_Ground_Begin.
    scope kirby_ground_begin_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_begin_transition_   // a1(transition subroutine) = air_charge_transition_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Air_Begin.
    scope air_begin_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_begin_transition_ // a1(transition subroutine) = ground_begin_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Air_Begin.
    scope air_begin_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        jal     0x800DEEC8                  // set aerial state
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D8EB8                  // momentum capture?
        or      a0, s0, r0                  // a0 = player struct
        lw      a0, 0x0028(sp)              // a0 = player object

        lw      a2, 0x0008(s0)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Begin

        lli     a1, Sheik.Action.NSPA_BEGIN // a1(action id) = NSP_Air_Begin
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Ground_Begin.
    scope ground_begin_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        jal     0x800DEE98                  // set grounded state
        or      a0, s0, r0                  // a0 = player struct
        lw      a0, 0x0028(sp)              // a0 = player object

        lw      a2, 0x0008(s0)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Begin

        lli     a1, Sheik.Action.NSPG_BEGIN // a1(action id) = NSP_Ground_Begin
        lw      t8, 0x08E8(s0)              // t8 = top joint struct (original logic, useless?)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop
      
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSP_Ground_Charge.
    scope ground_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        lw      a2, 0x0084(a0)              // ~
        addiu   at, r0, 0x0012              // set timer for charge
        sw      at, 0x0B1C(a2)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Charge

        lli     a1, Sheik.Action.NSPG_CHARGE// a1(action id) = NSP_Ground_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSP_Air_Charge.
    scope air_charge_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        lw      a2, 0x0084(a0)              // ~
        addiu   at, r0, 0x0012              // set timer for charge
        sw      at, 0x0B1C(a2)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Charge

        lli     a1, Sheik.Action.NSPA_CHARGE// a1(action id) = NSP_Air_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for NSP_Ground_Charge and NSP_Air_Charge.
    // Based on subroutine 0x8015D5AC, which is the main subroutine for Samus' grounded neutral special charge.
    scope charge_main_: {
        // First 2 lines of subroutine 0x8015D5AC
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      a3, 0x0084(a0)              // load player struct
        lw      t6, 0x0B1C(a3)              // load unknown variable
        addiu   t7, t6, 0xFFFF
        bnez    t7, _end
        sw      t7, 0x0B1C(a3)              // save to unknown variable
        lw      v0, 0x0AE0(a3)              // load charge amount
        addiu   t9, r0, 0x0012
        sw      t9, 0x0B1C(a3)
        slti    at, v0, 0x0006
        beq     at, r0, _end
        addiu   t0, v0, 0x0001              // add one to charge
        addiu   at, r0, 0x0006
        sw      t0, 0x0AE0(a3)              // save new charge amount
        bne     t0, at, _charge_continue    // not fully charged, so continue loop
        or      v0, t0, r0

        _charge_end:
        lli     a1, GFXRoutine.id.SHEIK_CHARGE // a1 = SHEIK_CHARGE id
        or      a2, r0, r0                  // a2 = 0
        sw      a0, 0x0020(sp)              // store a0
        jal     0x800E9814                  // begin gfx routine which attaches white spark to hand
        sw      a3, 0x001C(sp)              // store a3
        jal     0x800DEE54                  // transition to idle (ground and air)
        lw      a0, 0x0020(sp)              // a0 = player object
        beq     r0, r0, _end
        nop
        _charge_continue:
        lw      a0, 0x0B20(a3)
        beql    a0, r0, _end
        nop
        lw      v1, 0x0084(a0)
        sw      v0, 0x02A4(v1)


        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Interrupt subroutine for NSP_Ground_Charge.
    // Based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope ground_charge_interrupt_: {
        // Copy the first 14 lines of subroutine 0x8015D640
        OS.copy_segment(0xD8080, 0x1C)
        bnez    t7, _shoot
        nop
        lhu     t8, 0x01B4(a1)
        or      a0, a1, r0
        and     t9, v0, t8
        beql    t9, r0, _branch
        sw      a1, 0x001C(sp)

        _shoot:
        jal     ground_shoot_initial_       // ground_shoot_initial_
        or      a0, a2, r0                  // original line
        beq     r0, r0, _end
        lw      ra, 0x0014(sp)
        sw      a1, 0x001C(sp)

        _branch:
        jal     0x801492F8
        sw      a2, 0x0020(sp)

        addiu   at, r0, 0xFFFF
        lw      a1, 0x0001C(sp)

        beq     v0, at, _buttons
        lw      a2, 0x0020(sp)

        or      a0, a1, r0
        sw      a2, 0x0020(sp)
        sw      v0, 0x0018(sp)
        lw      a0, 0x0020(sp)

        jal     0x80149294
        lw      a1, 0x0018(sp)

        beq     r0, r0, _end
        lw      ra, 0x0014(sp)

        _buttons:
        lhu     t0, 0x01BE(a1)
        lhu     t1, 0x01B8(a1)
        or      a0, a1, r0
        and     t2, t0, t1
        beql    t2, r0, _end
        lw      ra, 0x0014(sp)
        sw      a2, 0x0020(sp)
        jal     0x8013E1C8
        lw      a0, 0x0020(sp)
        lw      ra, 0x0014(sp)

        _end:
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }

    // @ Description
    // Interrupt subroutine for NSP_Air_Charge.
    // Loosely based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope air_charge_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        // begin by checking for A or B presses
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed
        andi    t6, v0, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        andi    t7, v0, Joypad.A            // t7 = 0x8000 if (A_PRESSED); else t6 = 0
        or      at, t6, t7                  // at = !0 if (A_PRESSED) or (B_PRESSED), else at = 0
        beqz    at, _check_cancel           // branch if both A and B are not being pressed
        nop

        // if we're here, A or B has been pressed, so transition to NSP_Air_Shoot
        jal     air_shoot_initial_          // air_shoot_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_cancel:
        // now check if Shield button has been pressed
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end                // end if shield is not pressed
        lw      ra, 0x0014(sp)              // load ra

        // if we're here, Z has been pressed, so transition to fall
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        //jal     0x8015D300                  // destroy attached projectile
        //lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x8013F9E0                  // transition to fall
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        addiu   sp, sp, 0x0030              // dellocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Ground_Charge.
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
    // Collision subroutine for Kirby's NSP_Ground_Charge.
    scope kirby_ground_charge_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_charge_transition_  // a1(transition subroutine) = air_charge_transition_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Ground_Charge
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
    // Subroutine which transitions to NSP_Ground_Charge.
    scope ground_charge_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        jal     0x800DEE98                  // set grounded state
        or      a0, s0, r0                  // a0 = player struct
        lw      a0, 0x0028(sp)              // a0 = player object

        lw      a2, 0x0008(s0)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Charge

        lli     a1, Sheik.Action.NSPG_CHARGE// a1(action id) = NSP_Ground_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Air_Charge.
    scope air_charge_transition_: {
        addiu   sp, sp,-0x0030              // allocate stack spcae
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        jal     0x800DEEC8                  // set aerial state
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D8EB8                  // momentum capture?
        or      a0, s0, r0                  // a0 = player struct
        lw      a0, 0x0028(sp)              // a0 = player object

        lw      a2, 0x0008(s0)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Charge

        lli     a1, Sheik.Action.NSPA_CHARGE// a1(action id) = NSP_Air_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop
     
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSP_Ground_Shoot.
    // Based on subroutine 0x8015DA60, which is the initial subroutine for Samus' grounded neutral special shot.
    scope ground_shoot_initial_: {
        // Copy the first 5 lines of subroutine 0x8015DA60
        OS.copy_segment(0xD84A0, 0x14)

        lw      a2, 0x0084(a0)              // ~
        sw      r0, 0x017C(a2)              // clear our variable 1
        lw      at, 0x0AE0(a2)              // load charge
        addiu   t1, r0, 0x0001              // set t1 ro 1
        beqzl   at, _character_check
        sw      t1, 0x0AE0(a2)              // set charge to 1 so you have at least one needle
        _character_check:
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Ground_Shoot

        lli     a1, Sheik.Action.NSPG_SHOOT // a1(action id) = NSP_Ground_Shoot
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t6, 0x0024(sp)              // 0x0024(sp) = player struct

        lw      t9, 0x0024(sp)              // 0x0024(sp) = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop
     
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        lw      t9, 0x0024(sp)              // t9 = player struct
        sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for NSP_Air_Shoot.
    // Based on subroutine 0x8015DAA8, which is the initial subroutine for Samus' grounded neutral special shot.
    scope air_shoot_initial_: {
        // Copy the first 15 lines of subroutine 0x8015DAA8
        OS.copy_segment(0xD84E8, 0x3C)

         lw      a2, 0x0084(a0)              // ~
         sw      r0, 0x017C(a2)              // clear our variable 1
         lw      at, 0x0AE0(a2)              // load charge
         addiu   t1, r0, 0x0001              // set t1 ro 1
         beqzl   at, _character_check
         sw      t1, 0x0AE0(a2)              // set charge to 1 so you have at least one needle
         _character_check:
         lw      a2, 0x0008(a2)              // a2 = current character ID
         lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
         beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
         lli     a1, Kirby.Action.SHEIK_NSP_Air_Shoot
         lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
         beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
         lli     a1, Kirby.Action.SHEIK_NSP_Air_Shoot

        lli     a1, Sheik.Action.NSPA_SHOOT // a1(action id) = NSP_Air_Shoot
        or      a2, r0, r0                  // a2(starting frame) = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

         lw      t7, 0x0008(s0)              // t7 = current character ID
         lli     at, Character.id.KIRBY      // at = id.KIRBY
         beq     t7, at, _kirby              // branch if character = KIRBY
         lli     at, Character.id.JKIRBY     // at = id.JKIRBY
         bne     t7, at, _sheik              // branch if character != JKIRBY
         nop
       
         _kirby:
         li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
         b       _end                        // branch to end
         nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for neutral special air ending.
    // If temp variable 1 is set by moveset, create a projectile.
    scope shoot_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beq     t6, r0, _idle_check         // skip if temp variable 1 = 0
        nop
        sw      r0, 0x017C(v0)              // t6 = temp variable 0
        lw      t6, 0x0AE0(v0)              // load Needle Charge Amount
        beqz    t6, _idle_check
        addiu   t6, t6, -0x1
        sw      t6, 0x0AE0(v0)              // save new Needle Charge Amount

        // s0 = needle_properties_struct

        // if we're here, then temp variable 1 was enabled, so create a projectile
        mtc1    r0, f0                      // move 0 to f0
        swc1    f0, 0x0020(sp)              // ~
        swc1    f0, 0x0024(sp)              // ~
        swc1    f0, 0x0028(sp)              // establish origin points for x, y, and z
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x0924(v0)              // a0 = part 0xC (hand) struct
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct

        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     needle_stage_setting_       // INITIATE Needle
        addiu   a1, sp, 0x0020              // a1 = coordinates to create projectile at
        lw      a0, 0x0034(sp)              // a0 = player object

        _idle_check:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     0x800DEE54                  // transition to idle
        sw      r0, 0x017C(v0)              // reset temp variable 1 to 0

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }
    
    // @ Description
    // Interrupt subroutine for NSP_Air_Charge.
    // Loosely based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope air_shoot_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        
        lui     at, 0x3f80
        mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1f   _end                         // skip if animation not on frame 2 has not been reached
        nop
        
        // now check if Shield button has been pressed
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed       
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end                // end if shield is not pressed
        lw      ra, 0x0014(sp)              // load ra

        // if we're here, Z has been pressed, so transition to fall
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        jal     0x8013F9E0                  // transition to fall
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        addiu   sp, sp, 0x0030              // dellocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Interrupt subroutine for NSP_Air_Charge.
    // Loosely based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope ground_shoot_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        
        lui     at, 0x3f80
        mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1f   _end                        // skip if animation not on frame 2 has not been reached
        nop
        
        // now check if Shield button has been pressed
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed       
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _end                // end if shield is not pressed
        lw      ra, 0x0014(sp)              // load ra

        // if we're here, Z has been pressed, so transition to fall
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        jal     0x8013E1C8                  // transition to idle
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        addiu   sp, sp, 0x0030              // dellocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    scope needle_stage_setting_: {
        addiu   sp, sp, -0x0050
        sw      s0, 0x0018(sp)
        li      s0, needle_properties_struct   // s0 = projectile properties struct address
        sw      a1, 0x0034(sp)
        sw      a0, 0x0038(sp)
        sw      ra, 0x001C(sp)
        // play fgm
        jal     0x800269C0                  // play FGM
        lli     a0, 0x0410                  // FGM id = 0x3C
        lw      a0, 0x0038(sp)
        lw      ra, 0x001C(sp)
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, needle_projectile_struct   // a1 = main projectile struct address
        lw      a2, 0x0034(sp)
        lui     a3, 0x8000
        sw      t6, 0x002C(sp)              // 0x002C(sp) = player struct
        jal     0x801655C8                  // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)

        beq     v0, r0, _end_stage_setting  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        _projectile_branch:
        mtc1    r0, f4
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile struct
        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(v1)              // store duration
        lw      t4, 0x002C(sp)              // t4 = player struct
        lw      t5, 0x014C(t4)              // t5 = kinetic state
        addiu   at, r0, 0x0001
        bnel    t5, at, _trajectory         // branch if player is grounded
        lwc1    f12, 0x0018(s0)
        beq     r0, r0, _trajectory
        lwc1    f12, 0x001c(s0)             // projectile direction =
        lwc1    f12, 0x0018(s0)


        _trajectory:
        swc1    f4, 0x0028(v1)
        swc1    f12, 0x0020(sp)
        jal     0x80035CD0                  // ~
        sw      v1, 0x0024(sp)              // original logic from Mario fireball coding

        lw      t6, 0x002C(sp)              // ~
        lw      v1, 0x0024(sp)              // ~
        lw      t7, 0x0044(t6)              // t7 = player direction
        lwc1    f6, 0x0020(s0)
        mul.s   f8, f0, f6                  // ~
        lwc1    f12, 0x0020(sp)             // ~
        mtc1    t7, f10                     // ~
        nop                                 // ~
        cvt.s.w f10, f10                    // ~
        mul.s   f18, f8, f10                // ~
        jal     0x800303F0                  // ~
        swc1    f18, 0x0020(v1)             // original logic


        lwc1    f4, 0x0020(s0)              // ~ load speed
        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        mul.s   f6, f0, f4                  // f6 = direction times speed
        swc1    f6, 0x0024(v1)              // ~ save new speed


        // v0 =  projectile angle
        beqz    v0, _normal_rotation        // skip aerial rotation calculation if not rotated
        lw      t8, 0x0074(a0)              // t8 = projectile position struct

        lui     at, 0x8019
        lw      at, 0xCA84(at)
        mtc1    at, f14
        swc1    f14, 0x0034(t8)             // this needs to be set for rotation to work, don't know why
        li      at, 0x3f490fd8              // aerial rotation for needles (in rad, 45 deg)
        mtc1    at, f14
        swc1    f14, 0x0030(t8)             // save projectile rotation
        lwc1    f10, 0x002C(s0)             // ~

        _normal_rotation:
        lw      t9, 0x0080(t8)              // ~
        jal     0x80167FA0                  // ~
        swc1    f10, 0x0088(t9)             // ~
        lw      v0, 0x0028(sp)              // original logic

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0050
        jr      ra
        nop
    }

    // @ Description
    // This subroutine destroys the needle and creates a smoke gfx.
    scope needle_destruction_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords
        jal     0x800FF648                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)
    }

    // @ Description
    // Collision subroutine for NSP_Ground_Shoot.
    scope ground_shoot_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_shoot_transition_   // a1(transition subroutine) = air_shoot_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for Kirby's NSP_Ground_Shoot.
    scope kirby_ground_shoot_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_shoot_transition_   // a1(transition subroutine) = air_shoot_transition_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Air_Shoot.
    scope air_shoot_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_shoot_transition_ // a1(transition subroutine) = ground_shoot_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Ground_Shoot.
    // Based on subroutine 0x8015D9B0, which is the transition subroutine for Samus' aerial neutral special shot.
    scope ground_shoot_transition_: {
        // Copy the first 8 lines of subroutine 0x8015D9B0
        OS.copy_segment(0xD83F0, 0x20)

        lw      a2, 0x0084(a0)              // ~
        lli     a1, Action.LandingLight     // a1(action id) = LandingLight
        addiu   a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7

        lw      t9, 0x0024(sp)              // t9 = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop
     
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Air_Shoot.
    // Based on subroutine 0x8015DA04, which is the transition subroutine for Samus' aerial neutral special shot.
    scope air_shoot_transition_: {
        // Copy the first 8 lines of subroutine 0x8015DA04
        OS.copy_segment(0xD8444, 0x20)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SHEIK_NSP_Air_Shoot

        lli     a1, Sheik.Action.NSPA_SHOOT // a1(action id) = NSP_Air_Shoot
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7

        lw      t9, 0x0024(sp)              // t9 = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _sheik              // branch if character != JKIRBY
        nop
     
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _sheik:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for the needles.
    scope needle_main_: {
        addiu   sp, sp, 0xFFE0              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0020(sp)              // 0x0020(sp) = projectile object
        lw      a0, 0x0084(a0)              // a0 = projectile struct
        jal     0x80167FE8                  // original logic, subroutine returns 1 if projectile duration is over
        sw      a0, 0x001C(sp)              // 0x001C(sp) = projectile struct
        beq     v0, r0, _continue           // branch if projectile duration has not ended
        lw      a0, 0x001C(sp)              // a0 = projectile struct

        _end_duration:
        lw      t7, 0x0020(sp)              // t7 = projectile object
        lw      a0, 0x0074(t7)              // ~
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords
        jal     0x800FF648                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0
        b       _end                        // branch to end
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)

        // t6 = current needle duration

        _continue:
        li      v0, needle_properties_struct // v0 = needle properties struct
        lw      a1, 0x000C(v0)              // a1 = gravity
        jal     0x80168088                  // apply gravity to needle
        lw      a2, 0x0004(v0)              // a2 = max speed
        lw      a0, 0x001C(sp)              // a0 = projectile struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile struct with coordinates/rotation etc (bone struct?)
        li      at, needle_properties_struct   // at = needle properties struct
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    OS.align(16)
    needle_projectile_struct:
    constant NEEDLE_ID(0x1003)
    dw 0x00000000                           // unknown
    dw NEEDLE_ID                            // projectile id
    dw Character.SHEIK_file_6_ptr           // address of Sheik's file 6 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
    dw needle_main_                         // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0x80175914                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw needle_destruction_                  // This function runs when the projectile collides with a hurtbox.
    dw needle_destruction_                  // This function runs when the projectile collides with a shield.
    dw 0x8016DD2C                           // This function runs when the projectile collides with edges of a shield and bounces off
    dw needle_destruction_                  // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x801692C4                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw needle_destruction_                  // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    needle_properties_struct:
    dw NEEDLE_DURATION                      // 0x0000 - duration (int)
    float32 250                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0                               // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (grounded)
    float32 -0.785398                       // 0x001C   initial angle (aerial) 0xbf490fd8, 45 deg
    float32 225                             // 0x0020   initial speed
    dw Character.SHEIK_file_6_ptr           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)
}

// @ Description
// Subroutines for Down Special, Bouncing Fish
scope SheikDSP {
    constant B_PRESSED(0x40)                // bitmask for b press
    constant WALL_COLLISION(0x0021)         // bitmask for wall collision
    constant HORIZONTAL_MAX(0x4220)         // current setting - float: 40
    constant VERTICAL_VELOCITY(0x4248)      // current setting - float: 50

    // @ Description
    // Subroutine which runs when Sheik initiates a down special
    // Changes action, and sets up initial variable values.
    scope initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0084(a0)              // a0 = player struct
        
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _change_action          // skip if kinetic state !grounded
        nop

        jal     0x800DEEC8                  // set aerial state
        nop

        _change_action:
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, Sheik.Action.DSP_BEGIN// a1 = Sheik.Action.DSP_BEGIN
        or      a2, r0, r0                  // a2 = float: 0.0

        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0


        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        
        
        lw      t7, 0x0ADC(a0)              // load special struct to check if vertical should occur
        bnez    t7, _skip        
        lui     at, VERTICAL_VELOCITY
        
        sw      at, 0x004C(a0)              // set y velocity
        _skip:
        addiu   t7, r0, 0x0001              // set to 1
        sw      t7, 0x0ADC(a0)              // set to 1 so cannot be performed again until landing
        li      t7, dsp_on_hit_
        sw      t7, 0x09EC(a0)              // set on hit routine, so can still gain height/repeat if his before attack
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag

        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }
    
    // @ Description
    // On Hit Subroutine which runs when Sheik initiates a down special (both ground and air)
    // sole purpose is to allow another dsp/height
    scope dsp_on_hit_: {
        lw      at, 0x0084(a0)              // load player struct
        jr      ra                          // original return logic
        sw      r0, 0x0ADC(at)              // clear dsp/height thing
    }

    // @ Description
    // Main Subroutine which runs when Sheik initiates a down special (both ground and air) based on 8015BD24.
    // Deals with transition to part 2 of action and thereby, shortening.
    scope main_: {
        addiu   sp, sp, -0x0020             // ~
        sw      ra, 0x0014(sp)              // ~

        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer
        sw      t3, 0x0018(sp)              // save button_pressed to stack

		li		a1, attack_transition
        jal		0x800D9480
		nop

		lui		at, 0x4120					// at = 10.0
		mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1tl   _end                        // skip if haven't reached frame 10
        nop

		lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _end                // skip if (!B_PRESSED)
        nop

		jal		attack_transition
		nop

		_end:
        lw      ra, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Holds each player's button presses from the previous frame.
    // Used to add a single frame input buffer to shorten.
    button_press_buffer:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4

    // @ Description
    // Subroutine which runs when Sheik transitions to attack phase on DSP
    scope attack_transition: {
        addiu   sp, sp, -0x0020             // ~
        sw      ra, 0x001C(sp)              // ~

        addiu	t6, r0, 0x0003
		sw		a0, 0x0020(sp)
		sw		t6, 0x0010(sp)
		addiu	a1, r0, Sheik.Action.DSP_ATTACK // Action id = DSP_ATTACK
		addiu	a2, r0, 0x0000
		jal		0x800E6F24					// change action routine
		lui		a3, 0x3f80
		jal		0x800E0830
		lw		a0, 0x0020(sp)

        //jal		0x8015BFBC
		//lw		a0, 0x0020(sp)

        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }
    
   
    
    // @ Description
    // Subroutine which handles Sheik's physics for DSP
    // based on 0x80164064
    // s1 = player struct
    // a2 = other player struct?
    scope physics_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // save return address to stack
        sw      s0, 0x0018(sp)              // save to stack
        lw      s0, 0x0084(a0)              // load player struct
        lw      t6, 0x0180(s0)              // load flag variable 2
        or      a0, s0, r0                  // put player struct in a0
        beql    t6, r0, vertical_accel_     // branch if variable=0
        lw      v0, 0x09C8(s0)              // load attribute struct

        lw      v0, 0x09C8(s0)              // load attribute struct
        beq     r0, r0, end_accel_          // branch when vertical accel ends
        lwc1    f0, 0x0058(v0)              // load normal gravity

        lw      v0, 0x09C8(s0)              // load attribute struct


        // VERTICAL CALCULATION
        vertical_accel_:
        li      at, 0x3e6b851f              // load multiplier, which reduces gravity
        mtc1    at, f6                      // move multiplier to fp register
        lwc1    f4, 0x0058(v0)              // load gravity
        mul.s   f0, f4, f6                  // multiply gravity by multiplier
        nop
        end_accel_:
        mfc1    a1, f0                      // move product to a1
        jal     0x800D8D68                  // calculate vertical lift amount
        lw      a2, 0x005C(v0)              // load max air speed

        or      a0, s0, r0                  // player struct into a0
        jal     0x800D8FA8                  // unknown
        lw      a1, 0x09C8(s0)              // load attribute struct

        bnel    v0, r0, _end
        lw      ra, 0x001C(sp)

        // HORIZONTAL CALCULATION
        horizontal_accel_:
        lw      v0, 0x09C8(s0)      // attribute struct loaded
        //lui     at, 0x3F00          // .5 in fp
        mtc1    at, f10             // move to fp
        //lwc1    f12, 0x004C(v0)      // air acceleration loaded from attributes
        or      a0, s0, r0          // player struct loaded in
        addiu   a1, r0, 0x0008      // minimum input value loaded into a1
        //mul.s   f12, f8, f10        // air acceleration multiplied by 0.5
        //lwc1    f14, 0x0050(v0)     // max air speed loaded in
        lui     at, HORIZONTAL_MAX          // load in max speed of 40
        mtc1    at, f14             // place into floating point

        //mul.s   f16, f8, f10        // air acceleration multiplied by 0.5
        //lw      a3, 0x0050(v0)      // max air speed loaded from attributes
        //mfc1    a2, f16             // halved air acceleration placed into a2
        //jal     0x800D8FC8          // generic function that determines aerial horizontal speed
        //nop

        // BEGIN INPUT DETERMINATIONS
        lb      v0, 0x01C2(a0)      // load stick position
        bgez    v0, _input_check    // check to see if left, right, or neutral
        or      v1, v0, r0          // place input into v1

        beq     r0, r0, _input_check    // go this route if moving leftward
        subu    v1, r0, v0          // place negative version of inputs, because moving leftward

        _input_check:
        lw      t2, 0x0044(a0)      // load facing direction
        bgezl   t2, _right_facing
        lui     t1, 0x4220          // load normal speed in fp (40) when facing right
        lui     t1, 0xc220          // load normal speed in fp (-40) when facing left

        _right_facing:
        slt     at, v1, a1          // set at to 1 if input is less than minimum input
        bnezl   at, _end            // set horizontal movement to normal speed because no inputs
        sw      t1, 0x0048(a0)

        mtc1    v0, f6              // move inputs to floating point
        lwc1    f4, 0x0048(a0)      // load current aerial speed
        neg.s   f2, f14             // set max aerial speed to negative
        cvt.s.w f10, f6             // convert inputs to floating point
        //mul.s   f10, f8, f12        // multiply input by accel
        add.s   f16, f4, f10        // subtract max air speed
        swc1    f16, 0x0048(a0)     // save new horizontal speed
        lwc1    f0, 0x0048(a0)      // load new horizontal speed

        bgezl   t2, _right_facing_checks
        lui     at, 0x41a0          // load minimum speed (20)

        c.lt.s  f0, f2              // check to see if new speed is beyond leftwards max
        nop
        bc1tl   _end                // branch if is less than left max (if going beyond leftwards max, ie. too fast)
        swc1    f2, 0x0048(a0)      // set to max leftwards
        lui     at, 0xc1a0          // load minimum speed (-20)
        mtc1    at, f10

        c.lt.s  f10, f0             // is minimum speed less than current speed
        bc1tl   _end                // if current speed is greater than minimum, make sure the speed is not slower than minimum
        swc1    f10, 0x0048(a0)     // set to minimum leftwards

        beq     r0, r0, _end        // not less than minimum speed, so keep caculated speed
        nop

        _right_facing_checks:
        c.lt.s  f14, f0             // check to see if new speed is beyond rightwards max
        nop
        bc1tl   _end
        swc1     f14, 0x0048(a0)    // set to max rightwards

        // rightwards min check
        mtc1    at, f18
        c.lt.s  f0, f18             // compare to minimum speed
        nop
        bc1tl   _end                // if less than minimum speed branch on likely
        swc1    f18, 0x0048(a0)     // set to minimum if branch taken

        _end:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0020      // deallocate stack space
        jr      ra                  // return
        nop
    }

   // @ Description
   // Subroutine which handles air collision for down special actions
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground to air transition for down special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        addiu   a1, r0, Sheik.Action.DSP_LANDING // a1 = DSP landing routine
        _change_action:
        addiu   a2, r0, r0                  // a2(starting frame)
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        nop
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Sheik's down special attack.
    scope attack_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lbu     a1, 0x000D(a0)              // a1 = player port

        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        andi    a1, a1, WALL_COLLISION      // a1 = collision flags & WALL_COLLISION
        beql    a1, r0, _recoil_check       // skip if !WALL_COLLISION
        nop
        // enable the flag to begin recoil
        ori     a1, r0, 0x0001              // ~
        sw      a1, 0x017C(a0)              // temp variable 1 = 0x1 (recoil flag = true)

        _recoil_check:
        li      a1, _end                    // a1 = _end
        jal     check_recoil_               // check for recoil transition
        lw      a0, 0x0010(sp)              // load a0

        li      a1, air_to_ground_          // a1 = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0010(sp)              // load a0
        jal     0x800DE87C                  // check ledge/floor collision?
        nop
        beq     v0, r0, _end                // skip if !collision
        nop
        lw      a0, 0x0010(sp)              // load a0
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     a2, 0x00D2(a1)              // a2 = collision flags?
        andi    a2, a2, 0x3000              // bitmask
        beq     a2, r0, _end                // skip if !ledge_collision
        nop
        jal     0x80144C24                  // ledge grab subroutine
        nop
        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which handles hitbox collision for Sheik's down special. Reads a flag set by Wario NSP routine (see body_slam_recoil_ in Wario.asm)
    // @ Arguments
    // a0 - entity struct?
    // a1 - return address upon collision
    scope check_recoil_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      a0, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        swc1    f0, 0x0018(sp)              // ~
        swc1    f2, 0x001C(sp)              // store t0, t1, a0, a1, ra, f0, f2

        _check:
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x017C(t0)              // t1 = temp variable 1
        beq     t1, r0, _end                // skip if temp variable 1 = 0
        nop

        _collision:
        sw      a1, 0x0014(sp)              // overwrite return address in stack
        lw      a0, 0x000C(sp)              // load a0
        lw      t0, 0x0084(a0)              // t0 = player struct
        lui     at, 0x4282
        sw      at, 0x004C(t0)              // set y velocity
        sw      r0, 0x017C(t0)              // temp variable 1 = 0
        sw      r0, 0x0180(t0)              // temp variable 2 = 0

        ori     a1, r0, Sheik.Action.DSP_RECOIL // load DSP_RECOIL Action ID
        or      a2, r0, r0                  // a2 = 0(begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      a0, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // ~
        lwc1    f0, 0x0018(sp)              // ~
        lwc1    f2, 0x001C(sp)              // load t0, t1, ra, f0, f2
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Sheik's physic's for recoil
    // based on 0x80164064
    // s1 = player struct
    // a2 = other player struct?
    scope recoil_physics_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // save return address to stack
        sw      s0, 0x0018(sp)              // save to stack
        lw      s0, 0x0084(a0)              // load player struct
        lw      t6, 0x0180(s0)              // load flag variable 2
        or      a0, s0, r0                  // put player struct in a0
        beql    t6, r0, vertical_accel_     // branch if variable=0
        lw      v0, 0x09C8(s0)              // load attribute struct

        lw      v0, 0x09C8(s0)              // load attribute struct
        beq     r0, r0, end_accel_          // branch when vertical accel ends
        lwc1    f0, 0x0058(v0)              // load normal gravity

        lw      v0, 0x09C8(s0)              // load attribute struct


        // VERTICAL CALCULATION
        vertical_accel_:
        li      at, 0x3e6b851f              // load multiplier, which reduces gravity
        mtc1    at, f6                      // move multiplier to fp register
        lwc1    f4, 0x0058(v0)              // load gravity
        mul.s   f0, f4, f6                  // multiply gravity by multiplier
        nop
        end_accel_:
        mfc1    a1, f0                      // move product to a1
        jal     0x800D8D68                  // calculate vertical lift amount
        lw      a2, 0x005C(v0)              // load max air speed

        or      a0, s0, r0                  // player struct into a0
        jal     0x800D8FA8                  // unknown
        lw      a1, 0x09C8(s0)              // load attribute struct

        //bnel    v0, r0, _end
        //lw      ra, 0x001C(sp)

        // HORIZONTAL CALCULATION
        horizontal_accel_:
        lw      v0, 0x09C8(s0)      // attribute struct loaded
        mtc1    at, f10             // move to fp
        or      a0, s0, r0          // player struct loaded in
        addiu   a1, r0, 0x0008      // minimum input value loaded into a1
        lui     at, HORIZONTAL_MAX  // load in max speed
        mtc1    at, f2
        neg.s   f14, f2

        // BEGIN INPUT DETERMINATIONS
        lb      v0, 0x01C2(a0)      // load stick position
        bgez    v0, _input_check    // check to see if left, right, or neutral
        or      v1, v0, r0          // place input into v1

        beq     r0, r0, _input_check    // go this route if moving leftward
        subu    v1, r0, v0          // place negative version of inputs, because moving leftward


        _input_check:
        lw      t2, 0x0044(a0)      // load facing direction
        bgezl   t2, _right_facing
        lui     t1, 0xc1f0          // load normal speed in fp (-30) when facing right
        lui     t1, 0x41f0          // load normal speed in fp (30) when facing left


        _right_facing:
        slt     at, v1, a1          // set at to 1 if input is less than minimum input
        bnezl   at, _end            // set horizontal movement to normal speed because no inputs
        sw      t1, 0x0048(a0)

        mtc1    v0, f6              // move inputs to floating point
        lwc1    f4, 0x0048(a0)      // load current aerial speed
        neg.s   f2, f14             // set max aerial speed to negative
        cvt.s.w f10, f6             // convert inputs to floating point
        neg.s   f10, f10
        add.s   f16, f4, f10        // subtract max air speed
        swc1    f16, 0x0048(a0)     // save new horizontal speed
        lwc1    f0, 0x0048(a0)      // load new horizontal speed

        bgezl   t2, _right_facing_checks
        lui     at, 0xc1a0          // load minimum speed (-20)

        c.lt.s  f0, f2              // check to see if new speed is beyond leftwards max
        nop
        bc1tl   _end                // branch if is less than left max (if going beyond leftwards max, ie. too fast)
        swc1    f2, 0x0048(a0)      // set to max leftwards
        lui     at, 0x41a0          // load minimum speed (20)
        mtc1    at, f10

        c.lt.s  f10, f0             // is minimum speed less than current speed
        bc1tl   _end                // if current speed is greater than minimum, make sure the speed is not slower than minimum
        swc1    f10, 0x0048(a0)     // set to minimum leftwards

        beq     r0, r0, _end        // not less than minimum speed, so keep caculated speed
        nop

        _right_facing_checks:
        c.lt.s  f14, f0             // check to see if new speed is beyond rightwards max
        nop
        bc1tl   _end
        swc1     f14, 0x0048(a0)    // set to max rightwards

        // rightwards min check
        mtc1    at, f18
        c.lt.s  f0, f18             // compare to minimum speed
        nop
        bc1tl   _end                // if less than minimum speed branch on likely
        swc1    f18, 0x0048(a0)     // set to minimum if branch taken

        _end:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0020      // deallocate stack space
        jr      ra                  // return
        nop
    }

    // @ Description
    // Main Subroutine for recoil portion of DSP
    scope recoil_main_: {
        addiu   sp, sp, -0x0020             // ~
        sw      ra, 0x0014(sp)              // ~

        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer
        sw      t3, 0x0018(sp)              // save button_pressed to stack

		li		a1, 0x8013F9E0              // transition to falling
        jal		0x800D9480
		nop


        lui		at, 0x4220					// at = 40.0
		mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if haven't reached frame 10
        nop


		lui		at, 0x4170					// at = 15.0
		mtc1    at, f6                      // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1tl   _end                        // skip if haven't reached frame 10
        nop

		lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _end                // skip if (!B_PRESSED)
        nop

        lw      t3, 0x0044(a2)              // check facing
        addiu   t4, r0, 0x0001              // set to 1, right facing
        bnel    t3, t4, _attack             // if not facing right
        sw      t4, 0x0044(a2)              // set to right facing
        addiu   t3, r0, 0xFFFF              // load left facing
        sw      t3, 0x0044(a2)              // set to left facing

        _attack:
		jal		attack_transition
		nop

		_end:
        lw      ra, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

}