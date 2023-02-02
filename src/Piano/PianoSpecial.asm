// PianoSpecial.asm

// This file contains subroutines used by Piano's special moves.

// @ Description
// Subroutines for Up Special
scope PianoUSP {
    constant Y_SPEED(0x42F0)                // current setting - float:120
    constant X_SPEED(0x4248)                // current setting - float:50
    constant LANDING_FSM(0x3E20)            // current setting - float:0.15625

    // @ Description
    // Subroutine which runs when Piano initiates an up special (both ground/air).
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
        lw      a0, 0x0020(sp)              // a0 = player object
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, 0x00E1              // a1 = 0xE1
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        // take mid-air jumps away
        lw      t6, 0x09C8(a0)              // t6 = attribute pointer
        lw      t6, 0x0064(t6)              // t6 = max jumps
        sb      t6, 0x0148(a0)              // jumps used = max jumps
        // freeze y position
        lw      v1, 0x09C8(a0)              // v1 = attribute pointer
        lw      v1, 0x0058(v1)              // v1 = gravity
        sw      v1, 0x004C(a0)              // y velocity = gravity
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Main subroutine for Piano's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Piano's landing FSM value and disable the interrupt flag.
    scope main_: {
        // Copy the first 8 lines of subroutine 0x8015C750
        OS.copy_segment(0xD7190, 0x20)
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for Piano's up special.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x2 = change direction
    scope change_direction_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _end                // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles movement for Piano's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = begin movement
    // 0x3 = movement
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        constant BEGIN(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      t0, 0x0024(sp)              // ~
        sw      t1, 0x0028(sp)              // ~
        swc1    f0, 0x002C(sp)              // ~
        swc1    f2, 0x0030(sp)              // ~
        swc1    f4, 0x0034(sp)              // store t0, t1, f0, f2, f4

        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        beq     t0, t1, _continue           // branch if temp variable 3 = BEGIN
        nop
        li      t8, air_control_            // t8 = air_control_

        _continue:
        or      a0, s0, r0                  // a0 = player struct
        jalr    t8                          // air control subroutine
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

        _check_begin:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.875)
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_begin_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lui     t0, Y_SPEED                 // ~
        mtc1    t0, f4                      // f4 = Y_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lb      t0, 0x01C2(s0)              // ~
        mtc1    t0, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f0, f2, f0                  // f0 = stick_x * direction
        mtc1    r0, f2                      // f2 = 0
        c.le.s  f2, f0                      // ~
        nop                                 // ~
        bc1f    _apply_movement             // branch if stick_x * direction =< 0
        nop

        // update x velocity based on stick_x
        // f0 = stick_x (relative to direction)
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f2                      // f2 = 0.5
        mul.s   f2, f0, f2                  // f2 = x velocity (stick_x * 0.5)
        // update y velocity based on x velocity (higher x = lower y)
        lui     t0, 0x3F40                  // ~
        mtc1    t0, f0                      // f0 = 0.75
        mul.s   f0, f0, f2                  // ~
        sub.s   f4, f4, f0                  // f4 = Y_SPEED - (x velocity * 0.75)

        _apply_movement:
        // f2 = x velocity to add
        // f4 = y velocity
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f0                      // f0 = X_SPEED
        add.s   f2, f2, f0                  // f0 = final velocity
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = x velocity * direction
        swc1    f2, 0x0048(s0)              // store x velocity
        swc1    f4, 0x004C(s0)              // store y velocity
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        b       _end                        // end
        nop

        _end:
        lw      t0, 0x0024(sp)              // ~
        lw      t1, 0x0028(sp)              // ~
        lwc1    f0, 0x002C(sp)              // ~
        lwc1    f2, 0x0030(sp)              // ~
        lwc1    f4, 0x0034(sp)              // load t0, t1, f0, f2, f4
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // original load registers
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles Piano's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        lw      a2, 0x004C(t6)              // a2 = air acceleration
        lw      a3, 0x0050(t6)              // a3 = max air speed
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        _check_move:
        ori     t1, r0, physics_.MOVE       // t1 = MOVE
        beql    t0, t1, _continue           // branch if temp variable 3 = MOVE
        lui     a2, 0x3C75                  // on branch, a2 = 0.0149536

        _continue:
        jal     0x800D8FC8                  // air drift subroutine?
        nop
        lw      ra, 0x0014(sp)              // ~
        lw      t0, 0x0020(sp)              // ~
        lw      t1, 0x0024(sp)              // load ra, t0, t1
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Piano's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Piano.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }
}


// @ Description
// Subroutines for Down Special
scope PianoDSP {
    // @ Description
    // Subroutine which runs when Piano initiates a grounded down special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Ground_Begin // a1(action id) = DSP_Ground_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     0x80155454                  // Ness DSP setup subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Piano initiates a grounded down special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Air_Begin // a1(action id) = DSP_Air_Begin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     0x80155454                  // Ness DSP setup subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's grounded down special wait action.
    scope ground_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Ground_Wait // a1(action id) = DSP_Ground_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0804                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0804
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // a0 = player object
        li      a1, cmd_throw_ground_initial_ // a1 = cmd_throw_ground_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     absorb_setup_               // absorb setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's aerial down special wait action.
    scope air_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Air_Wait // a1(action id) = DSP_Air_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0804                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0804
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // a0 = player object
        li      a1, cmd_throw_air_initial_  // a1 = cmd_throw_air_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     absorb_setup_               // absorb setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's grounded down special absorb action.
    scope ground_absorb_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Ground_Absorb // a1(action id) = DSP_Ground_Absorb
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0004                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0004
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     0x80155934                  // additional absorb subroutine (enables 0x018D bitflag)
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x0180(a0)              // reset temp variable 2
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's aerial down special absorb action.
    scope air_absorb_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Air_Absorb // a1(action id) = DSP_Air_Absorb
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0004                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0004
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     0x80155934                  // additional absorb subroutine (enables 0x018D bitflag)
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x0180(a0)              // reset temp variable 2
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's grounded down special ending action.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Ground_End // a1(action id) = DSP_Ground_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's aerial down special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.DSP_Air_End // a1(action id) = DSP_Ground_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Ground_Begin
    scope ground_begin_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_wait_initial_    // a1(transition subroutine) = ground_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Air_Begin
    scope air_begin_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_wait_initial_       // a1(transition subroutine) = air_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Ground_Wait
    scope ground_wait_main_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      a0, 0x0020(sp)              // store a0
        jal     0x80155518                  // subroutine which updates min_frame_timer and b_not_held variables
        sw      v0, 0x001C(sp)              // store v0
        lw      v0, 0x001C(sp)              // v0 = player struct
        lw      t6, 0x0B18(v0)              // t6 = min_frame_timer
        bgtz    t6, _end                    // if min_frame_timer > 0, skip
        lw      t7, 0x0B1C(v0)              // t7 = b_not_held
        beqz    t7, _end                    // skip if !b_not_held
        nop

        // if we reach this point, the minimum number of frames before the action can end has elapsed, and b is not held
        jal     ground_end_initial_         // transition to DSP_Ground_End
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Air_Wair
    scope air_wait_main_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      a0, 0x0020(sp)              // store a0
        jal     0x80155518                  // subroutine which updates min_frame_timer and b_not_held variables
        sw      v0, 0x001C(sp)              // store v0
        lw      v0, 0x001C(sp)              // v0 = player struct
        lw      t6, 0x0B18(v0)              // t6 = min_frame_timer
        bgtz    t6, _end                    // if min_frame_timer > 0, skip
        lw      t7, 0x0B1C(v0)              // t7 = b_not_held
        beqz    t7, _end                    // skip if !b_not_held
        nop

        // if we reach this point, the minimum number of frames before the action can end has elapsed, and b is not held
        jal     air_end_initial_            // transition to DSP_Air_End
        lw      a0, 0x0020(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Ground_Absorb
    scope ground_absorb_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x0180(t5)              // t6 = temp variable 2
        beqz    t6, _check_end_transition   // skip if temp variable 2 = 0
        lh      t6, 0x01BC(t5)              // t6 = buttons_held
        andi    t6, t6, Joypad.B            // t6 = 0x0020 if (B_HELD); else t6 = 0
        bnez    t6, _check_end_transition   // skip if (!B_HELD)
        nop

        // if temp variable 2 has been set, and the player is not holding B
        jal     0x8013E1C8                  // transition to idle
        nop
        b       _end                        // end subroutine
        nop

        _check_end_transition:
        li      a1, ground_wait_initial_    // a1(transition subroutine) = ground_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop


        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for DSP_Air_Absorb
    scope air_absorb_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x0180(t5)              // t6 = temp variable 2
        beqz    t6, _check_end_transition   // skip if temp variable 2 = 0
        lh      t6, 0x01BC(t5)              // t6 = buttons_held
        andi    t6, t6, Joypad.B            // t6 = 0x0020 if (B_HELD); else t6 = 0
        bnez    t6, _check_end_transition   // skip if (!B_HELD)
        nop

        // if temp variable 2 has been set, and the player is not holding B
        jal     0x8013F9E0                  // transition to fall
        nop
        b       _end                        // end subroutine
        nop

        _check_end_transition:
        li      a1, air_wait_initial_       // a1(transition subroutine) = air_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop


        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground collision for down special actions
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_to_air_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
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
    scope ground_to_air_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0038(sp)              // store a0, ra
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct

        li      t6, ground_to_air_table     // t6 = ground_to_air_table
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7,-Piano.Action.DSP_Ground_Begin // ~
        sll     t7, t7, 0x3                 // t7 = offset for ground_to_air_table
        addu    t6, t6, t7                  // t6 = ground_to_air_table + offset
        sw      t6, 0x0030(sp)              // store address of current action in ground_to_air_table
        lhu     t7, 0x0002(t6)              // t7 = argument 4 for current action
        sw      t7, 0x0010(sp)              // store argument 4

        lw      a0, 0x0038(sp)              // a0 = player object
        lhu     a1, 0x0000(t6)              // a1 = action id to transition to
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct

        _check_set_bitflag:
        lw      v0, 0x0030(sp)              // ~
        lhu     v0, 0x0004(v0)              // v0 = bool set_bitflag
        beqz    v0, _check_command_grab     // skip if !set_flag
        lw      v0, 0x0034(sp)              // v0 = player struct

        lbu     t9, 0x018D(v0)              // ~
        ori     t0, t9, 0x0080              // ~
        sb      t0, 0x018D(v0)              // enable an unknown bitflag

        _check_command_grab:
        lw      v0, 0x0030(sp)              // ~
        lhu     v0, 0x0006(v0)              // v0 = bool command_grab
        beqz    v0, _end                    // skip if !set_flag
        nop

        li      a1, cmd_throw_air_initial_  // a1 = cmd_throw_air_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0034(sp)              // a0 = player struct

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition for down special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0038(sp)              // store a0, ra
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct

        li      t6, air_to_ground_table     // t6 = air_to_ground_table
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7,-Piano.Action.DSP_Air_Begin // ~
        sll     t7, t7, 0x3                 // t7 = offset for air_to_ground_table
        addu    t6, t6, t7                  // t6 = air_to_ground_table + offset
        sw      t6, 0x0030(sp)              // store address of current action in air_to_ground_table
        lhu     t7, 0x0002(t6)              // t7 = argument 4 for current action
        sw      t7, 0x0010(sp)              // store argument 4

        lw      a0, 0x0038(sp)              // a0 = player object
        lhu     a1, 0x0000(t6)              // a1 = action id to transition to
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        _check_set_bitflag:
        lw      v0, 0x0030(sp)              // ~
        lhu     v0, 0x0004(v0)              // v0 = bool set_bitflag
        beqz    v0, _check_command_grab     // skip if !set_flag
        lw      v0, 0x0034(sp)              // v0 = player struct

        lbu     t9, 0x018D(v0)              // ~
        ori     t0, t9, 0x0080              // ~
        sb      t0, 0x018D(v0)              // enable an unknown bitflag

        _check_command_grab:
        lw      v0, 0x0030(sp)              // ~
        lhu     v0, 0x0006(v0)              // v0 = bool command_grab
        beqz    v0, _end                    // skip if !set_flag
        nop

        li      a1, cmd_throw_ground_initial_ // a1 = cmd_throw_ground_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0034(sp)              // a0 = player struct

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the absorb range for Piano
    scope absorb_setup_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        lw      v1, 0x0084(a0)              // v1 = player struct
        lbu     t3, 0x018D(v1)              // ~
        ori     t4, t3, 0x0080              // ~
        sb      t4, 0x018D(v1)              // enable an unknown bitflag
        li      t7, absorb_struct           // t7 = absorb_struct
        sw      t7, 0x0850(v1)              // store absorb_struct pointer
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's grounded command throw action
    scope cmd_throw_ground_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.Ground_Cmd_Throw // a1(action id) = Ground_Cmd_Throw
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0024                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0024
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     command_throw_setup_        // additional command throw setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Piano's aerial command throw action
    scope cmd_throw_air_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Piano.Action.Air_Cmd_Throw // a1(action id) = Air_Cmd_Throw
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0024                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0024
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     command_throw_setup_        // additional command throw setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which hides the opponent during the command throw when temp variable 1 is set
    scope cmd_throw_hide_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t6, 0x017C(a0)              // ~
        beq     t6, r0, _end                // skip if temp variable 1 = 0
        nop

        // hide captured opponent
        lw      t6, 0x0840(a0)              // t6 = capture player object
        beq     t6, r0, _end                // skip if there's no captured player
        nop
        lw      t6, 0x0084(t6)              // t6 = captured player struct
        lbu     t7, 0x018D(t6)              // t7 = bit field
        ori     t7, t7, 0x0001              // enable bitflag for invisibility
        sb      t7, 0x018D(t6)              // update bit field

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground physics during the command throw
    scope cmd_throw_ground_physics_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        or      a1, r0, r0                  // a1 = 0
        li      a2, 0x3DCCCCCD              // a2(acceleration rate) = 0.1
        lui     a3, 0x41D0                  // a3(max x speed) = 26
        jal     0x800D89E0                  // calculate horizontal movement
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800D87D0                  // apply horizontal movement
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Ground_Cmd_Throw
    scope cmd_throw_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, cmd_throw_ground_to_air_ // a1(transition subroutine) = cmd_throw_ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Air_Cmd_Throw
    scope cmd_throw_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, cmd_throw_air_to_ground_ // a1(transition subroutine) = cmd_throw_air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from Ground_Cmd_Throw to Air_Cmd_Throw
    scope cmd_throw_ground_to_air_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lli     a1, Piano.Action.Air_Cmd_Throw // a1(action id) = Air_Cmd_Throw
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0024                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0024
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from Air_Cmd_Throw to Ground_Cmd_Throw
    scope cmd_throw_air_to_ground_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lli     a1, Piano.Action.Ground_Cmd_Throw // a1(action id) = Ground_Cmd_Throw
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0024                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0024
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which helps set up the command throw for Piano
    scope command_throw_setup_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, 0x003F                  // a1 = bitflags?
        jal     0x800E8098                  // sets the byte at 0x193 in the player struct to the value in a1
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t6, 0x0830(a0)              // ~
        sw      t6, 0x0840(a0)              // update captured player?
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // table containing arguments for air_to_ground_
    // format is XXXXYYYYZZZZAAAA
    // XXXX = action id for ground transition
    // YYYY = argument 4 for change action subroutine
    // ZZZZ = bool for setting the bitflag at 0x018D in the player struct
    // AAAA = bool for enabling command grab behaviour
    air_to_ground_table:
    // ground action id                     // change action arg 4  // set_bitflag  //command_grab
    dh Piano.Action.DSP_Ground_Begin      ; dh  0x0092            ; dh OS.FALSE     ; dh OS.FALSE       // DSP_Air_Begin
    dh Piano.Action.DSP_Ground_Wait       ; dh  0x0097            ; dh OS.TRUE      ; dh OS.TRUE        // DSP_Air_Wait
    dh Piano.Action.DSP_Ground_Absorb     ; dh  0x0097            ; dh OS.TRUE      ; dh OS.FALSE       // DSP_Air_Absorb
    dh Piano.Action.DSP_Ground_End        ; dh  0x0092            ; dh OS.FALSE     ; dh OS.FALSE       // DSP_Air_End

    // @ Description
    // table containing arguments for ground_to_air_
    // format is XXXXYYYYZZZZAAAA
    // XXXX = action id for air transition
    // YYYY = argument 4 for change action subroutine
    // AAAA = bool for enabling command grab behaviour
    ground_to_air_table:
    // aerial action id                     // change action arg 4  // set_bitflag  //command_grab
    dh Piano.Action.DSP_Air_Begin         ; dh  0x0092            ; dh OS.FALSE     ; dh OS.FALSE       // DSP_Air_Begin
    dh Piano.Action.DSP_Air_Wait          ; dh  0x0097            ; dh OS.TRUE      ; dh OS.TRUE        // DSP_Air_Wait
    dh Piano.Action.DSP_Air_Absorb        ; dh  0x0097            ; dh OS.TRUE      ; dh OS.FALSE       // DSP_Air_Absorb
    dh Piano.Action.DSP_Air_End           ; dh  0x0092            ; dh OS.FALSE     ; dh OS.FALSE       // DSP_Air_End

    OS.align(16)
    absorb_struct:
    dw      0x00000001                      // not sure
    dw      0x00000000                      // not sure
    float32 0                             // offset x
    float32 330                             // offset y
    float32 330                             // offset z
    float32 350                             // size x
    float32 350                             // size y
    float32 350                             // size z

    // @ Description
    // Patch which adds ground_absorb_initial_ to the Ness absorb routine when the character is Piano
    scope ground_absorb_initial_patch_: {
        OS.patch_start(0xCFCB8, 0x80155278)
        jal     ground_absorb_initial_patch_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        lw      a0, 0x0084(a1)              // a0 = player struct
        lw      t6, 0x0008(a0)              // t6 = character id
        lli     t7, Character.id.PIANO      // t7 = id.PIANO
        beq     t6, t7, _piano              // branch if character id = PIANO
        nop
        // if we're here then the character is not Piano, so proceed normally
        jal     0x80155948                  // Ness DSP ground absorb initial (original line 1)
        or      a0, a1, r0                  // a0 = player object (original line 2)
        b       _end
        nop

        _piano:
        jal     ground_absorb_initial_      // transition to DSP_Ground_Absorb
        or      a0, a1, r0                  // a0 = player object

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Patch which adds air_absorb_initial_ to the Ness absorb routine when the character is Piano
    scope air_absorb_initial_patch_: {
        OS.patch_start(0xCFCC8, 0x80155278)
        jal     air_absorb_initial_patch_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        lw      a0, 0x0084(a1)              // a0 = player struct
        lw      t6, 0x0008(a0)              // t6 = character id
        lli     t7, Character.id.PIANO      // t7 = id.PIANO
        beq     t6, t7, _piano              // branch if character id = PIANO
        nop
        // if we're here then the character is not Piano, so proceed normally
        jal     0x8015598C                  // Ness DSP air absorb initial (original line 1)
        or      a0, a1, r0                  // a0 = player object (original line 2)
        b       _end
        nop

        _piano:
        jal     air_absorb_initial_         // transition to DSP_Ground_Absorb
        or      a0, a1, r0                  // a0 = player object

        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Patch which swaps the action id of the captured opponent for Piano/Marina's command grabs
    scope command_grab_action_fix_: {
        OS.patch_start(0xC733C, 0x8014C8FC)
        jal     command_grab_action_fix_
        nop
        OS.patch_end()

        lli     a1, Action.EggLayPulled     // original line 1
        lw      t5, 0x0844(s0)              // t5 = player.entity_captured_by
        lw      t5, 0x0084(t5)              // t5 = grabbing player struct
        lw      t7, 0x0008(t5)              // t7 = grabbing player character id
        ori     t6, r0, Character.id.PIANO  // t6 = id.PIANO
        beq     t7, t6, _piano              // branch if id = PIANO
        ori     t6, r0, Character.id.MARINA // t6 = id.MARINA
        beq     t7, t6, _marina             // branch if id = MARINA
        ori     t8, r0, Character.id.JKIRBY // t8 = id.JKIRBY
        beq     t7, t8, _kirby              // branch if id = JKIRBY
        ori     t8, r0, Character.id.KIRBY  // t8 = id.KIRBY
        bne     t7, t8, _end                // skip if id != KIRBY
        
        _kirby:
        lw      t7, 0x0ADC(t5)              // t7 = grabbing player copied power id
        bne     t7, t6, _end                // skip if copied power != Marina
        nop

        _marina:
        // load an alternate action id if the character is being captured by Piano
        b       _end                        // branch to end
        lli     a1, Action.Thrown2          // a1(action id) = Thrown1

        _piano:
        // load an alternate action id if the character is being captured by Piano
        lli     a1, Action.ThrownDK         // a1(action id) = ThrownDK

        _end:
        jr      ra                          // return
        or      a2, r0, r0                  // original line 2
    }

    // @ Description
    // Patch which adjusts the recovery rate for projectiles eaten by Mad Piano, and increments the
    // bonus ammunition for neutral special.
    scope absorb_behaviour_: {
        OS.patch_start(0x5EBAC, 0x800E33AC)
        jal     absorb_behaviour_
        mtc1    t8, f8                      // original line 1
        OS.patch_end()

        lw      t9, 0x002C(s0)              // original line 2
        lw      t3, 0x0008(s0)              // t3 = character id
        lli     t4, Character.id.PIANO      // t4 = id.PIANO
        beql    t3, t4, _piano              // branch if id = PIANO...
        addiu   ra, ra, 0x14                // ...and increment return address

        // return normally if the character is not Piano
        jr      ra                          // return
        nop

        _piano:
        // f8 = projectile damage
        // first, multiply the damage by 0.75x for healing
        cvt.s.w f8, f8                      // f8 = projectile damage (float)
        lui     t3, 0x3F40                  // ~
        mtc1    t3, f0                      // f0 = 0.75
        mul.s   f0, f8, f0                  // f0 = projectile damage * 0.75
        trunc.w.s f0, f0                    // ~
        mfc1    t1, f0                      // convert to int (final healing amount)
        nop

        // next multiply the damage by 0.33333x for bonus ammunition
        // (1 extra projectile per 3% damage absorbed)
        li      t3, 0x3EAAAAAB              // ~
        mtc1    t3, f0                      // f0 = 0.33333
        mul.s   f0, f8, f0                  // f0 = projectile damage * 0.33333
        lwc1    f10, 0x0ADC(s0)             // f10 = bonus_ammo
        add.s   f10, f10, f0                // increment bonus_ammo
        lui     t3, 0x40A0                  // ~
        mtc1    t3, f16                     // f16 = 5.0 (bonus_ammo maximum)
        c.le.s  f16, f10                    // if bonus_ammo <= 5.0...
        nop
        bc1f    _store_ammo                 // ...then update ammo count
        nop

        // if we reach this point, then the incremented ammo count exceeds the maximum,
        // so store the maximum instead
        mov.s   f10, f16                    // f10 = bonus_ammo maximum

        _store_ammo:
        swc1    f10, 0x0ADC(s0)             // store updated bonus_ammo

        jr      ra                          // return
        nop
    }
}