// EbiSpecial.asm

// This file contains subroutines used by Ebi's special moves.

scope EbiNSP {
    constant WALK_MULTIPLIER(0x3E80)        // float32 0.25
    constant WALK_TRACTION(0x41F0)          // float32 30
    constant AIR_SPEED(0x41E0)              // float32 28
    constant CHARGE_TIME(12)

    // @ Description
    // Subroutine which runs when Ebi initiates a grounded neutral special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Ground_Begin

        lli     a1, Ebi.Action.NSP_Ground_Begin // a1(action id) = NSP_Ground_Begin
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
        sw      r0, 0x0B18(a0)              // charge timer = 0
        sw      r0, 0x0B1C(a0)              // charge flag = 0
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which runs when Ebi initiates an aerial neutral special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Air_Begin

        lli     a1, Ebi.Action.NSP_Air_Begin // a1(action id) = NSP_Air_Begin
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
        sw      r0, 0x0B18(a0)              // charge timer = 0
        sw      r0, 0x0B1C(a0)              // charge flag = 0
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which begins Ebi's grounded neutral special wait action.
    scope ground_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Ground_Wait
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Ground_Wait

        lli     a1, Ebi.Action.NSP_Ground_Wait // a1(action id) = NSP_Ground_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which begins Ebi's aerial neutral special wait action.
    scope air_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Air_Wait
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Air_Wait

        lli     a1, Ebi.Action.NSP_Air_Wait // a1(action id) = NSP_Air_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which begins Ebi's grounded neutral special ending action.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Ground_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Ground_End

        lli     a1, Ebi.Action.NSP_Ground_End // a1(action id) = NSP_Ground_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which begins Ebi's aerial neural special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Air_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.EBI_NSP_Air_End

        lli     a1, Ebi.Action.NSP_Air_End // a1(action id) = NSP_Ground_End
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Ground_Begin
    // If temp variable 2 is set by moveset, cancel with NSP_Ground_End when B is not held.
    scope ground_begin_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t7, 0x0180(v0)              // t7 = temp variable 2
        beqz    t7, _end                    // branch if temp variable 2 is not set
        lh      t7, 0x01BC(v0)              // t7 = buttons_held
        andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t7, _check_end              // branch if (B_HELD)
        nop

        _release:
        // if we're here then temp variable 2 is set and b is not held, so transition to ending action
        jal     ground_end_initial_         // transition to NSP_Ground_End
        nop
        b       _end
        nop

        _check_end:
        jal     ground_wait_initial_         // transition
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Air_Begin
    // If temp variable 2 is set by moveset, cancel with NSP_Ground_End when B is not held.
    scope air_begin_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t7, 0x0180(v0)              // t7 = temp variable 2
        beqz    t7, _end                    // branch if temp variable 2 is not set
        lh      t7, 0x01BC(v0)              // t7 = buttons_held
        andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t7, _check_end              // branch if (B_HELD)
        nop

        _release:
        // if we're here then temp variable 2 is set and b is not held, so transition to ending action
        jal     air_end_initial_            // transition to NSP_Air_End
        nop
        b       _end
        nop

        _check_end:
        jal     air_wait_initial_           // common main subroutine (transition on animation end)
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for NSP_Ground_Wait
    scope ground_wait_main_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        lh      t7, 0x01BC(v0)              // t7 = buttons_held
        andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t7, _end                    // branch if (B_HELD)
        nop

        // if we reach this point, the b button is not being held, so transition to ending action
        jal     ground_end_initial_         // transition to NSP_Ground_End
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Air_Wait
    scope air_wait_main_: {
       addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        lh      t7, 0x01BC(v0)              // t7 = buttons_held
        andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t7, _end                    // branch if (B_HELD)
        nop

        // if we reach this point, the b button is not being held, so transition to ending action
        jal     air_end_initial_            // transition to NSP_Air_End
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main subroutine for neutral special air ending.
    // If temp variable 1 is set by moveset, create a projectile.
    // The value of temp variable 3 will be added as bonus power to the projectile.
    scope end_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct

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
        lw      ra, 0x0014(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Interrupt function for ground wait/walk actions.
    scope ground_interrupt_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        lw      t7, 0x0044(v1)              // t7 = DIRECTION
        multu   t6, t7                      // stick_x * DIRECTION
        sw      ra, 0x0014(sp)              // store ra

        lw      t7, 0x0008(v1)              // character id
        addiu   at, r0, Character.id.EBI

        beq     t7, at, _goemon
        lw      t7, 0x0024(v1)              // t7 = current action

        // kirby
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -44                 // at = 1 if stick_x < -44, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < -44
        lli     a1, Kirby.Action.EBI_NSP_Ground_BWalk2 // a1 = Action.NSP_Ground_BWalk2
        slti    at, t6, -9                  // at = 1 if stick_x < -9, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < -9
        lli     a1, Kirby.Action.EBI_NSP_Ground_BWalk1 // a1 = Action.NSP_Ground_BWalk1
        slti    at, t6, 10                  // at = 1 if stick_x < 10, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < 10
        lli     a1, Kirby.Action.EBI_NSP_Ground_Wait // a1 = Action.NSP_Ground_Wait
        slti    at, t6, 45                  // at = 1 if stick_x < 45, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < 45
        lli     a1, Kirby.Action.EBI_NSP_Ground_Walk1 // a1 = Action.NSP_Ground_Walk1
        // if here stick_x >= 45
        lli     a1, Kirby.Action.EBI_NSP_Ground_Walk2 // a1 = Action.NSP_Ground_Walk2

        _kirby_check_transition:
        beq     a1, t7, _end                // skip if already performing appropriate action
        nop
        jal     kirby_ground_transition_          // transition to new action
        nop
        b       _end
        nop

        _goemon:
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -44                 // at = 1 if stick_x < -44, else at = 0
        bnezl   at, _check_transition       // branch if stick_x < -44
        lli     a1, Ebi.Action.NSP_Ground_BWalk2 // a1 = Action.NSP_Ground_BWalk2
        slti    at, t6, -9                  // at = 1 if stick_x < -9, else at = 0
        bnezl   at, _check_transition       // branch if stick_x < -9
        lli     a1, Ebi.Action.NSP_Ground_BWalk1 // a1 = Action.NSP_Ground_BWalk1
        slti    at, t6, 10                  // at = 1 if stick_x < 10, else at = 0
        bnezl   at, _check_transition       // branch if stick_x < 10
        lli     a1, Ebi.Action.NSP_Ground_Wait // a1 = Action.NSP_Ground_Wait
        slti    at, t6, 45                  // at = 1 if stick_x < 45, else at = 0
        bnezl   at, _check_transition       // branch if stick_x < 45
        lli     a1, Ebi.Action.NSP_Ground_Walk1 // a1 = Action.NSP_Ground_Walk1
        // if here stick_x >= 45
        lli     a1, Ebi.Action.NSP_Ground_Walk2 // a1 = Action.NSP_Ground_Walk2

        _check_transition:
        beq     a1, t7, _end                // skip if already performing appropriate action
        nop
        jal     ground_transition_          // transition to new action
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Descirption
    // Transition between grounded wait/walk actions.
    // a0 - player object
    // a1 - action id
    scope ground_transition_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lwc1    f4, 0x0078(a0)              // f4 = current animation frame
        li      t6, cycle_length_table      // t6 = cycle_length_table
        lw      t5, 0x0084(a0)              // t
        lw      t5, 0x0024(t5)              // t5 = current action
        lli     at, Ebi.Action.NSP_Ground_Wait // at = NSP_Ground_Wait
        beql    t5, at, _end                // branch if current action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0
        beql    a2, at, _end                // branch if target action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0

        addiu   at, t5, -Ebi.Action.NSP_Ground_Wait
        sll     at, at, 0x2                 // at = table index for current action
        addu    t7, t6, at                  // t7 = cycle_length_table + current action index
        addiu   at, a1, -Ebi.Action.NSP_Ground_Wait
        sll     at, at, 0x2                 // at = table index for target action
        addu    t8, t6, at                  // t8 = cycle_length_table + target action index
        lwc1    f6, 0x0000(t7)              // f6 = current cycle length
        lwc1    f8, 0x0000(t8)              // f8 = target cycle length
        div.s   f4, f4, f6                  // f4 = multiplier (current frame / current cycle length)
        mul.s   f6, f4, f8                  // ~
        trunc.w.s f6, f6                    // ~
        cvt.s.w f6, f6                      // f6 = starting frame = trunc(multiplier * target cycle length)
        mfc1    a2, f6                      // a2 = starting frame

        _end:
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0802 (continue: 3C FGM, gfx routines)
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }

    // @ Descirption
    // Transition between grounded wait/walk actions.
    // a0 - player object
    // a1 - action id
    scope kirby_ground_transition_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lwc1    f4, 0x0078(a0)              // f4 = current animation frame
        li      t6, kirby_cycle_length_table      // t6 = kirby_cycle_length_table
        lw      t5, 0x0084(a0)              // t
        lw      t5, 0x0024(t5)              // t5 = current action
        lli     at, Kirby.Action.EBI_NSP_Ground_Wait // at = NSP_Ground_Wait
        beql    t5, at, _end                // branch if current action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0
        beql    a2, at, _end                // branch if target action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0

        addiu   at, t5, -Kirby.Action.EBI_NSP_Ground_Wait
        sll     at, at, 0x2                 // at = table index for current action
        addu    t7, t6, at                  // t7 = kirby_cycle_length_table + current action index
        addiu   at, a1, -Kirby.Action.EBI_NSP_Ground_Wait
        sll     at, at, 0x2                 // at = table index for target action
        addu    t8, t6, at                  // t8 = kirby_cycle_length_table + target action index
        lwc1    f6, 0x0000(t7)              // f6 = current cycle length
        lwc1    f8, 0x0000(t8)              // f8 = target cycle length
        div.s   f4, f4, f6                  // f4 = multiplier (current frame / current cycle length)
        mul.s   f6, f4, f8                  // ~
        trunc.w.s f6, f6                    // ~
        cvt.s.w f6, f6                      // f6 = starting frame = trunc(multiplier * target cycle length)
        mfc1    a2, f6                      // a2 = starting frame

        _end:
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0802 (continue: 3C FGM, gfx routines)
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground collision for neutral special actions
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles air collision for neutral special begin and wait
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground collision for neutral special actions
    scope kirby_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, kirby_ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles air collision for neutral special begin and wait
    scope kirby_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, kirby_air_to_ground_    // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground to air transition for neutral special actions
    scope ground_to_air_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        li      t6, ground_to_air_table     // t6 = ground_to_air_table
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7, -Ebi.Action.NSP_Ground_Begin
        sll     t7, t7, 0x0001              // t7 = table index for current action
        addu    t6, t6, t7                  // t6 = ground_to_air_table + index
        lhu      a1, 0x0000(t6)              // a1 = equivalent air action for current ground action
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0802 (continue: 3C FGM, gfx routines)
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles air to ground transition for begin and wait neutral special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        li      t6, air_to_ground_table     // t6 = air_to_ground_table
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7, -Ebi.Action.NSP_Air_Begin
        sll     t7, t7, 0x0001              // t7 = table index for current action
        addu    t6, t6, t7                  // t6 = air_to_ground_table + index
        lhu      a1, 0x0000(t6)              // a1 = equivalent ground action for current air action
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0803                  // ~
        jal     0x800E6F24                  // change action
        
        sw      t6, 0x0010(sp)              // argument 4 = 0x0802 (continue: 3C FGM, gfx routines)
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground to air transition for neutral special actions
    scope kirby_ground_to_air_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        li      t6, kirby_ground_to_air_table     // t6 = ground_to_air_table
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7, -Kirby.Action.EBI_NSP_Ground_Begin
        sll     t7, t7, 0x0001              // t7 = table index for current action
        addu    t6, t6, t7                  // t6 = ground_to_air_table + index
        lhu      a1, 0x0000(t6)              // a1 = equivalent air action for current ground action
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0802 (continue: 3C FGM, gfx routines)
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles air to ground transition for begin and wait neutral special actions
    scope kirby_air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        li      t6, kirby_air_to_ground_table     // t6 = air_to_ground_table
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   t7, t7, -Kirby.Action.EBI_NSP_Air_Begin
        sll     t7, t7, 0x0001              // t7 = table index for current action
        addu    t6, t6, t7                  // t6 = air_to_ground_table + index
        lhu      a1, 0x0000(t6)              // a1 = equivalent ground action for current air action
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0802 (continue: 3C FGM, gfx routines)
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }

    ground_to_air_table:
    dh Ebi.Action.NSP_Air_Begin          // NSP_Ground_Begin
    dh Ebi.Action.NSP_Air_Wait           // NSP_Ground_Wait
    dh Ebi.Action.NSP_Air_Wait           // NSP_Ground_Walk1
    dh Ebi.Action.NSP_Air_Wait           // NSP_Ground_Walk2
    dh Ebi.Action.NSP_Air_Wait           // NSP_Ground_BWalk1
    dh Ebi.Action.NSP_Air_Wait           // NSP_Ground_BWalk2
    dh Ebi.Action.NSP_Air_End            // NSP_Ground_End
    OS.align(4)

    air_to_ground_table:
    dh Ebi.Action.NSP_Ground_Begin       // NSP_Air_Begin
    dh Ebi.Action.NSP_Ground_Wait        // NSP_Air_Wait
    dh Ebi.Action.NSP_Ground_End         // NSP_Air_End
    OS.align(4)

    cycle_length_table:
    float32 40                              // NSP_Ground_Wait
    float32 80                              // NSP_Ground_Walk1
    float32 60                              // NSP_Ground_Walk2
    float32 80                              // NSP_Ground_BWalk1
    float32 60                              // NSP_Ground_BWalk2

    kirby_ground_to_air_table:
    dh Kirby.Action.EBI_NSP_Air_Begin    // NSP_Ground_Begin
    dh Kirby.Action.EBI_NSP_Air_Wait     // NSP_Ground_Wait
    dh Kirby.Action.EBI_NSP_Air_Wait     // NSP_Ground_Walk1
    dh Kirby.Action.EBI_NSP_Air_Wait     // NSP_Ground_Walk2
    dh Kirby.Action.EBI_NSP_Air_Wait     // NSP_Ground_BWalk1
    dh Kirby.Action.EBI_NSP_Air_Wait     // NSP_Ground_BWalk2
    dh Kirby.Action.EBI_NSP_Air_End      // NSP_Ground_End
    OS.align(4)

    kirby_air_to_ground_table:
    dh Kirby.Action.EBI_NSP_Ground_Begin // NSP_Air_Begin
    dh Kirby.Action.EBI_NSP_Ground_Wait  // NSP_Air_Wait
    dh Kirby.Action.EBI_NSP_Ground_End   // NSP_Air_End
    OS.align(4)

    kirby_cycle_length_table:
    float32 40                              // NSP_Ground_Wait
    float32 80                              // NSP_Ground_Walk1
    float32 60                              // NSP_Ground_Walk2
    float32 80                              // NSP_Ground_BWalk1
    float32 60                              // NSP_Ground_BWalk2

}

// @ Description
// Subroutines for Up Special
scope EbiUSP {
    constant GROUND_SPEED(0x42A0)           // float32 80
    constant JUMP_SPEED(0x4280)             // float32 64
    constant ESCAPE_SPEED(0x4160)           // float32 14
    constant MIN_SPEED(0x4040)              // float32 3
    constant ACCELERATION(0x4000)           // float32 2
    constant LANDING_FSM(0x3E80)            // float32 0.25
    constant MAX_TIME(80)

    // @ Description
    // Initial subroutine for USP while grounded.
    scope ground_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, GROUND_SPEED            // at = GROUND_SPEED
        jal     0x800DEEC8                  // set aerial state
        sw      at, 0x004C(a0)              // y velocity = GROUND_SPEED
        jal     air_initial_                // transition to USP
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for USP.
    scope air_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      v1, 0x0ADC(v0)              // v1 = up special bool
        bnez    v1, _end                    // end if up special bool = TRUE
        lli     at, OS.TRUE                 // at = TRUE
        sw      at, 0x0ADC(v0)              // up special bool = TRUE
        lli     a1, Ebi.Action.USP          // a1(action id) = USP
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        jal     goemon_on_hit_subroutine_establishment_ // on hit subroutine setup
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t6, 0x3EC0                  // ~
        mtc1    t6, f0                      // f0 = 0.375
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // f2 = y velocity * 0.375
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        lli     at, 0x0001                  // ~
        sw      at, 0x0180(a0)              // temp variable 2 = 1
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // frame timer = 0
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      t6, 0x09C8(a0)              // t6 = attribute pointer
        lw      t6, 0x0064(t6)              // t0 = max jumps
        sb      t6, 0x0148(a0)              // jumps used = max jumps
        swc1    f2, 0x004C(a0)              // store updated y velocity

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Shared initial subroutine for USP actions.
    // @ Arguments
    // a0 - player object
    // a1 - action id
    scope shared_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lli     at, 0x0001                  // ~
        sw      at, 0x0180(a0)              // temp variable 2 = 1
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main function for USP
    scope main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x0B18(v1)              // t6 = frame timer
        slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
        addiu   t6, t6, 0x0001              // ~
        bnez    at, _end                    // branch if frame timer < MAX_TIME
        sw      t6, 0x0B18(v1)              // increment frame timer

        // if frame timer has reached MAX_TIME
        jal     0x800DEE54                  // transition to idle
        nop
        b       _end
        nop

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Handles movement for USP actions.
    scope physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct

        _check_movement:
        lb      t6, 0x01C2(s0)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        lb      t7, 0x01C3(s0)              // t7 = stick_y
        bltzl   t7, pc() + 8                // if stick_x is negative...
        subu    t7, r0, t7                  // ...make stick_y positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        beqz    at, _check_stick            // branch if |stick_x| >= 10
        slti    at, t7, 11                  // at = 1 if |stick_y| < 11, else at = 0
        beqz    at, _check_stick            // branch if |stick_y| >= 10
        nop

        _check_min_speed:
        // if we're here then stick_x and stick_y are both < 11, so consider the stick neutral
        lwc1    f2, 0x0048(s0)              // f2 = x velocity
        mul.s   f2, f2, f2                  // f2 = x velocity^2
        lwc1    f4, 0x004C(s0)              // f4 = y velocity
        mul.s   f4, f4, f4                  // f4 = y velocity^2
        add.s   f4, f2, f4                  // ~
        sqrt.s  f4, f4                      // f4 = current speed = sqrt(x velocity^2 + y velocity^2)
        lui     at, MIN_SPEED               // ~
        mtc1    at, f6                      // f6 = MIN_SPEED
        c.le.s  f4, f6                      // ~
        mtc1    r0, f2                      // target x velocity = 0
        bc1fl   _apply_movement             // apply movement if current speed < MIN_SPEED...
        mtc1    r0, f4                      // ...and target y velocity = 0
        // set velocity to 0 if below minimum speed
        sw      r0, 0x0048(s0)              // x velocity = 0
        b       _end                        // end
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_stick:
        lui     at, 0x3F08                  // ~
        mtc1    at, f0                      // f0 = 0.53125
        lb      at, 0x01C2(s0)              // ~
        mtc1    at, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f2, f2, f0                  // f2 = target x velocity = stick_x * 0.53125
        lb      at, 0x01C3(s0)              // ~
        mtc1    at, f4                      // ~
        cvt.s.w f4, f4                      // f4 = stick_y
        mul.s   f4, f4, f0                  // f4 = target y velocity = stick_y * 0.53125
        mul.s   f6, f2, f2                  // ~
        mul.s   f8, f4, f4                  // ~
        add.s   f6, f6, f8                  // ~
        sqrt.s  f6, f6                      // f6 = absolute target velocity
        lui     at, 0x422A                  // ~
        mtc1    at, f8                      // f8 = 42.5 = 80 * 0.53125
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _apply_movement             // branch if absolute target velocity < 50
        nop

        // adjust the target velocity if it is above 80
        div.s   f10, f8, f6                 // f10 = velocity multiplier = 80 / absolute target velocity
        mul.s   f2, f2, f10                 // f2 = adjusted target x velocity
        mul.s   f4, f4, f10                 // f4 = adjusted target y velocity

        _apply_movement:
        lwc1    f6, 0x0048(s0)              // f6 = x velocity
        lwc1    f8, 0x004C(s0)              // f8 = y velocity
        sub.s   f14, f2, f6                 // f14 = X_DIFF
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        sub.s   f12, f4, f8                 // f12 = Y_DIFF
        // f0 = acceleration angle
        swc1    f0, 0x0028(sp)              // 0x0028(sp) = acceleration angle
        jal     0x80035CD0                  // f0 = cos(f12)
        lwc1    f12, 0x0028(sp)             // f12 = acceleration angle
        lui     at, ACCELERATION            // ~
        mtc1    at, f2                      // f2 = ACCELERATION
        mul.s   f2, f2, f0                  // f2 = x velocity difference(ACCELERATION * cos(angle))
        lwc1    f4, 0x0048(s0)              // f4 = x velocity
        add.s   f4, f4, f2                  // f4 = x velocity + x velocity difference
        swc1    f4, 0x0048(s0)              // store updated x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x0028(sp)             // f12 = acceleration angle
        lui     at, ACCELERATION            // ~
        mtc1    at, f2                      // f2 = ACCELERATION
        mul.s   f2, f2, f0                  // f2 = y velocity difference(ACCELERATION * sin(angle))
        lwc1    f4, 0x004C(s0)              // f4 = y velocity
        add.s   f4, f4, f2                  // f4 = y velocity + y velocity difference
        swc1    f4, 0x004C(s0)              // store updated x velocity

        _end:
        lw      s0, 0x0024(sp)              // ~
        lw      ra, 0x0014(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }


    // @ Description
    // Collision subroutine for Ebis's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Ebi.
    scope collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }

    // @ Description
    // Establishment of on hit routine for USP, based on 0x8015DB4C
    scope goemon_on_hit_subroutine_establishment_: {
       li       t6, goemon_on_hit_subroutine_
       sw       t6, 0x09EC(a0)
       sw       r0, 0x0B20(a0)

       jr       ra
       sw       r0, 0x017C(a0)
    }

    // @ Description
    // On hit routine for USP.
    scope goemon_on_hit_subroutine_: {
       addiu    sp, sp,-0x0018              // allocate stack space
       sw       ra, 0x0014(sp)              // store ra
       lw       a0, 0x0084(a0)              // a0 = player struct
       lw       ra, 0x0014(sp)              // load ra
       jr       ra                          // return
       addiu    sp, sp, 0x0018              // deallocate stack space
    }



}

// @ Description
// Subroutines for Down Special
scope EbiDSP {

    constant Y_SPEED(0xC2C8)                // current setting - float:-100
    constant INITIAL_Y_SPEED(0x4334)        // current setting - float:180.0
    constant INITIAL_X_SPEED(0x42B4)        // current setting - float:90.0

    constant BEGIN(0x1)
    constant MOVE(0x2)

    // @ Description
    // Subroutine which runs when Wario initiates a grounded down special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      r0, 0x0010(sp)              // original begin logic
        ori     a1, r0, Ebi.Action.DSPGROUND   // a1 = action id: DSPGROUND
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     ra, r0, 0x0001              // ~
        sw      ra, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }

    // @ Description
    // Subroutine which runs when Wario initiates an aerial down special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      at, 0x0AE0(v1)              // at = variable
        bnez    at, _skip                   // skip if already did a DSP
        nop
        ori     at, r0, Ebi.Action.DSPRECOIL// at = action id: DSPRECOIL
        lw      v0, 0x0024(v1)
        beq     v0, at, _skip
        nop

        addiu   t6, r0, 0x0008              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, Ebi.Action.DSPAIR // a1 = action id: Wario DSP Air
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
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
        _skip:
        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }

    // @ Description
    // Subroutine which sets up the movement for the grounded version of Wario's down special.
    // Temp variable 1 (5400XXXX):
    // 0x1 = apply initial movement and set aerial kinetic state
    // Temp variable 2 (5800XXXX):
    // 0x1 = control air drift (physics_)
    // Temp variable 3 (5C00XXXX):
    // 0x1 = begin
    // 0x2 = apply movement speed (physics_)
    scope ground_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store t0, t1, f0, f2, ra

        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.875)

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_initial      // skip if t0 != BEGIN
        nop
        // slow y movement
        lwc1    f0, 0x004C(a2)              // f0 = current y velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x004C(a2)              // y velocity = (y velocity * 0.875)

        _check_initial:
        lw      t0, 0x017C(a2)              // t0 = temp variable 1
        beq     t0, r0, _end                // skip if temp variable 1 = 0
        nop
        // reset temp variable 2
        sw      r0, 0x017C(a2)              // temp variable 1 = 0
        // apply initial x velocity
        lui     t1, INITIAL_X_SPEED         // ~
        mtc1    t1, f0                      // f0 = INITIAL_X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = INITIAL_X_SPEED * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = INITIAL_X_SPEED * DIRECTION
        // apply initial y velocity
        lui     t0, INITIAL_Y_SPEED         // ~
        sw      t0, 0x004C(a2)              // y velocity = INITIAL_Y_SPEED
        jal     0x800DEEC8                  // set aerial state
        or      a0, a2, r0                  // a0 = player struct

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // ~
        lw      ra, 0x0014(sp)              // load t0, t1, f0, f2, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which sets up the movement for the aerial version of Wario's down special.
    // Temp variable 2 (5800XXXX):
    // 0x1 = control air drift (physics_)
    // Temp variable 3 (5C00XXXX):
    // 0x1 = begin
    // 0x2 = apply movement speed
    scope air_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // store t0, t1, f0, f2

        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.875)

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _end                // skip if t0 != BEGIN
        nop
        // slow y movement
        lwc1    f0, 0x004C(a2)              // f0 = current y velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x004C(a2)              // y velocity = (y velocity * 0.875)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // load t0, t1, f0, f2
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }
    

    // @ Description
    scope grounded_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        _check_end:
        li      a1, begin_landing_           // a1(transition subroutine) = begin_recoil_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    scope landing_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        _check_end:
        li      a1, begin_recoil_           // a1(transition subroutine) = begin_recoil_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles physics for Wario's down special.
    // Prevents player control when temp variable 2 = 0
    // Prevents negative Y velocity when temp variable 3 = 1 (BEGIN)
    scope physics_: {
        // 0x180 in player struct = temp variable 2

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // store t0, t1, ra, a0
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control

        _subroutine:
        jalr      t8                        // run physics subroutine
        nop

        _check_fall:
        lw      a0, 0x0010(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if temp variable 3 != BEGIN
        nop

        // Checks if the highest bit is set to 1, which is used to represent a negative floating
        // point value. If the highest bit is set to 1, sets y velocity to 0.
        lw      t0, 0x004C(a0)              // t0 = y velocity
        lui     t1, 0x8000                  // t1 = bitmask
        and     t1, t0, t1                  // t1 = 0 if y velocity is positive
        bnel    t1, r0, _end                // execute next instruction if y velocity is negative
        sw      r0, 0x004C(a0)              // y velocity = 0

        _check_move:
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _end                // skip if t0 != MOVE
        nop
        // apply y velocity
        lui     t1, Y_SPEED                 // ~
        sw      t1, 0x004C(a0)              // y velocity = Y_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // load t0, t1, ra, a0
        jr      ra                          // return
        addiu 	sp, sp, 0x0018				// deallocate stack space
    }

    // @ Description
    // Subroutine which handles collision for Wario's down special.
    // Transitions into the down special landing action when temp variable 3 = MOVE,
    // otherwise lands normally.
    scope collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      v0, 0x014C(a1)              // v0 = kinetic state
        bnez    v0, _aerial                 // branch if kinetic state != grounded
        nop

        _grounded:
        jal     0x800DDF44                  // grounded collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _aerial:
        lw      v0, 0x184(a1)               // v0 = temp variable 3
        ori     a1, r0, MOVE                // a1 = MOVE
        beq     a1, v0, _main_collision     // branch if temp variable 3 = MOVE
        nop

        // If Wario is not in the ground pound motion, run a normal aerial collision subroutine
        // instead.
        jal     0x800DE99C                  // aerial collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _main_collision:
        li      a1, begin_landing_           // a1 = begin_landing_
        jal     0x800DE6E4                  // general air collision?
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
        jr      ra
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which starts the landing
    scope begin_landing_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        // bnez    t7, _end                    // skip if kinetic state !grounded
        // nop

        _end:
        lw      a0, 0x0020(sp)              // a0 = entity struct?

        lw      a2, 0x0084(a0)              // ~

        ori     a1, r0, Ebi.Action.DSPLANDING
        or      a2, r0, r0                  // a2 = 0(begin action frame)
        sw      r0, 0x0010(sp)              //
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0

        lw      a0, 0x0020(sp)              // a0 = entity struct?
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }

    constant RECOIL_Y_VELOCITY(0x42D0)

    // @ Description
    // Subroutine which starts the recoil
    scope begin_recoil_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _end                    // skip if kinetic state !grounded
        nop
        addiu   at, r0, 1
        sw      at, 0x0AE0(a0)              // variable so you can't spam DSP
        jal     0x800DEEC8                  // set aerial state
        nop

        _end:
        lw      a0, 0x0020(sp)              // a0 = entity struct?

        lw      a2, 0x0084(a0)              // ~

        ori     a1, r0, Ebi.Action.DSPRECOIL
        or      a2, r0, r0                  // a2 = 0(begin action frame)
        sw      r0, 0x0010(sp)              //
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0

        lw      a0, 0x0020(sp)              // restore a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, RECOIL_Y_VELOCITY

        sw      at, 0x004C(a0)              // save y velocity

        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }

    // 
    // 
    scope recoil_main_: {
        OS.routine_begin(0x20)
        lw      v1, 0x0084(a0)
        lw      v0, 0x17C(v1)   // load moveset flag
        beqz    v0, _end
        nop
        // if here, transition to idle
        jal     0x800DEE54                  // transition to idle
        nop
        addiu   v0, r0, 1       // return 1, not sure if needed.
        _end:
        OS.routine_end(0x20)
    }

    // @ Description
    // Subroutine which sets up the movement for the Body Slam recoil.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x1 = end special movement
    scope recoil_move_: {
        // a2 = player struct
        // 0x180 in player struct = temp variable 2

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // store t0, f0, f2
        sw      ra, 0x0014(sp)              // store ra

        // check for ceiling bonk
        lhu     t8, 0x00CE(a2)
        andi    t9, t8, 0x0400
        beqz    t9, _no_bonk
        nop

        // if here, ceiling bonk
        jal     0x801441C0
        nop
        b       _end
        nop

        _no_bonk:
        jal     0x8013F660                  // can interupt DSP recoil with whatever lol
        nop

        _end:
        lw      ra, 0x0014(sp)              // restore ra
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // load t0, t1, f0, f2
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles physics for the recoil.
    // Prevents player control when temp variable 2 = 0
    scope recoil_physics_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control

        _subroutine:
        jalr      t8                        // run physics subroutine
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for NSP_Recoil_Air.
    scope recoil_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, recoil_ground_transition_ // a1(transition subroutine) = recoil_ground_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to landing heavy.
    scope recoil_ground_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        Action.change(Action.LandingHeavy, 0x3f80)
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

}