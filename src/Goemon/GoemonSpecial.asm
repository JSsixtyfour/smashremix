// GoemonSpecial.asm

// This file contains subroutines used by Goemon's special moves.

scope GoemonNSP {
    constant WALK_MULTIPLIER(0x3E80)        // float32 0.25
    constant WALK_TRACTION(0x41F0)          // float32 30
    constant AIR_SPEED(0x41E0)              // float32 28
    constant CHARGE_TIME(12)
    constant SFX_RYO_SHOOT_1(28)
    constant SFX_RYO_SHOOT_2(65)
    constant SFX_RYO_FIRE(27)

    // @ Description
    // Subroutine which runs when Goemon initiates a grounded neutral special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_Begin

        lli     a1, Goemon.Action.NSP_Ground_Begin // a1(action id) = NSP_Ground_Begin
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
    // Subroutine which runs when Goemon initiates an aerial neutral special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Air_Begin

        lli     a1, Goemon.Action.NSP_Air_Begin // a1(action id) = NSP_Air_Begin
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
    // Subroutine which begins Goemon's grounded neutral special wait action.
    scope ground_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_Wait
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_Wait

        lli     a1, Goemon.Action.NSP_Ground_Wait // a1(action id) = NSP_Ground_Wait
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
    // Subroutine which begins Goemon's aerial neutral special wait action.
    scope air_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Air_Wait
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Air_Wait

        lli     a1, Goemon.Action.NSP_Air_Wait // a1(action id) = NSP_Air_Wait
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
    // Subroutine which begins Goemon's grounded neutral special ending action.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_End

        lli     a1, Goemon.Action.NSP_Ground_End // a1(action id) = NSP_Ground_End
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
    // Subroutine which begins Goemon's aerial neural special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Air_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.GOEMON_NSP_Air_End

        lli     a1, Goemon.Action.NSP_Air_End // a1(action id) = NSP_Ground_End
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
        beqz    t7, _check_end              // branch if temp variable 2 is not set
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
        li      a1, ground_wait_initial_    // a1(transition subroutine) = ground_wait_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
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
        beqz    t7, _check_end              // branch if temp variable 2 is not set
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
    // Main subroutine for NSP_Ground_Wait
    scope ground_wait_main_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t7, 0x0B18(v0)              // t7 = charge timer
        lli     at, CHARGE_TIME             // ~
        bne     t7, at, _continue           // branch if charge timer != CHARGE_TIME
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        // if we reach this point play a sound, begin the GFX routine and set the charge flag
        lli     at, OS.TRUE                 // ~
        sw      at, 0x0B1C(v0)              // set charge flag to TRUE
        FGM.play(SFX_RYO_SHOOT_1)           // play first sfx
        FGM.play(SFX_RYO_SHOOT_2)           // play second sfx
        lli     a1, GFXRoutine.id.GOEMON_CHARGE // a1 = GOEMON_CHARGE id
        or      a2, r0, r0                  // a2 = 0
        jal     0x800E9814                  // begin gfx routine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct

        _continue:
        lw      t7, 0x0B18(v0)              // t7 = charge timer
        addiu   t7, t7, 0x0001              // ~
        sw      t7, 0x0B18(v0)              // increment charge timer
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
        lw      t7, 0x0B18(v0)              // t7 = charge timer
        lli     at, CHARGE_TIME             // ~
        bne     t7, at, _continue           // branch if charge timer != CHARGE_TIME
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        // if we reach this point play a sound, begin the GFX routine and set the charge flag
        lli     at, OS.TRUE                 // ~
        sw      at, 0x0B1C(v0)              // set charge flag to TRUE
        jal     0x800269C0                  // play FGM
        lli     a0, 28                      // FGM id = 28
        jal     0x800269C0                  // play FGM
        lli     a0, 65                      // FGM id = 65
        lli     a1, GFXRoutine.id.GOEMON_CHARGE // a1 = GOEMON_CHARGE id
        or      a2, r0, r0                  // a2 = 0
        jal     0x800E9814                  // begin gfx routine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct

        _continue:
        lw      t7, 0x0B18(v0)              // t7 = charge timer
        addiu   t7, t7, 0x0001              // ~
        sw      t7, 0x0B18(v0)              // increment charge timer
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
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beq     t6, r0, _idle_check         // skip if temp variable 1 = 0
        sw      r0, 0x017C(v0)              // reset temp variable 1 to 0

        // if we're here, then temp variable 1 was enabled, so create a projectile
        swc1    f0, 0x0020(sp)              // ~
        swc1    f0, 0x0024(sp)              // ~
        swc1    f0, 0x0028(sp)              // clear space used for x/y/z coordinates (probably not needed)
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x0928(v0)              // a0 = part 0xC (right hand) struct
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct
        lwc1    f6, 0x0024(sp)              // f6 = y coordinate
        lui     t6, 0x41F0                  // ~
        mtc1    t6, f8                      // f6 = 30
        add.s   f6, f6, f8                  // add 30 to y coordinate
        swc1    f6, 0x0024(sp)              // store updated y coordinate
        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     ryo_stage_setting_          // INITIATE RYO
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
        addiu   at, r0, Character.id.GOEMON

        beq     t7, at, _goemon
        lw      t7, 0x0024(v1)              // t7 = current action

        // kirby
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -44                 // at = 1 if stick_x < -44, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < -44
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_BWalk2 // a1 = Action.NSP_Ground_BWalk2
        slti    at, t6, -9                  // at = 1 if stick_x < -9, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < -9
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_BWalk1 // a1 = Action.NSP_Ground_BWalk1
        slti    at, t6, 10                  // at = 1 if stick_x < 10, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < 10
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_Wait // a1 = Action.NSP_Ground_Wait
        slti    at, t6, 45                  // at = 1 if stick_x < 45, else at = 0
        bnezl   at, _kirby_check_transition       // branch if stick_x < 45
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_Walk1 // a1 = Action.NSP_Ground_Walk1
        // if here stick_x >= 45
        lli     a1, Kirby.Action.GOEMON_NSP_Ground_Walk2 // a1 = Action.NSP_Ground_Walk2

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
        lli     a1, Goemon.Action.NSP_Ground_BWalk2 // a1 = Action.NSP_Ground_BWalk2
        slti    at, t6, -9                  // at = 1 if stick_x < -9, else at = 0
        bnezl   at, _check_transition       // branch if stick_x < -9
        lli     a1, Goemon.Action.NSP_Ground_BWalk1 // a1 = Action.NSP_Ground_BWalk1
        slti    at, t6, 10                  // at = 1 if stick_x < 10, else at = 0
        bnezl   at, _check_transition       // branch if stick_x < 10
        lli     a1, Goemon.Action.NSP_Ground_Wait // a1 = Action.NSP_Ground_Wait
        slti    at, t6, 45                  // at = 1 if stick_x < 45, else at = 0
        bnezl   at, _check_transition       // branch if stick_x < 45
        lli     a1, Goemon.Action.NSP_Ground_Walk1 // a1 = Action.NSP_Ground_Walk1
        // if here stick_x >= 45
        lli     a1, Goemon.Action.NSP_Ground_Walk2 // a1 = Action.NSP_Ground_Walk2

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
        lli     at, Goemon.Action.NSP_Ground_Wait // at = NSP_Ground_Wait
        beql    t5, at, _end                // branch if current action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0
        beql    a2, at, _end                // branch if target action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0

        addiu   at, t5, -Goemon.Action.NSP_Ground_Wait
        sll     at, at, 0x2                 // at = table index for current action
        addu    t7, t6, at                  // t7 = cycle_length_table + current action index
        addiu   at, a1, -Goemon.Action.NSP_Ground_Wait
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
        lli     at, Kirby.Action.GOEMON_NSP_Ground_Wait // at = NSP_Ground_Wait
        beql    t5, at, _end                // branch if current action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0
        beql    a2, at, _end                // branch if target action = NSP_Ground_Wait...
        or      a2, r0, r0                  // ...a2 = starting frame = 0

        addiu   at, t5, -Kirby.Action.GOEMON_NSP_Ground_Wait
        sll     at, at, 0x2                 // at = table index for current action
        addu    t7, t6, at                  // t7 = kirby_cycle_length_table + current action index
        addiu   at, a1, -Kirby.Action.GOEMON_NSP_Ground_Wait
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
    // Physics function for ground walk actions.
    // Based on 0x8013E548
    scope ground_walk_physics_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(a0) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     a1, WALK_MULTIPLIER         // a1 = WALK_MULTIPLIER
        jal     0x800D8A70                  // apply walk physics
        lui     a2, WALK_TRACTION           // a2 = WALK_TRACTION
        jal     0x800D87D0                  // unknown subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Physics function for ground back walk actions.
    // Based on 0x8013E548
    scope ground_back_walk_physics_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(a0) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     a1, WALK_MULTIPLIER | 0x8000 // a1 = -WALK_MULTIPLIER
        jal     0x800D8A70                  // apply walk physics
        lui     a2, WALK_TRACTION           // a2 = WALK_TRACTION
        jal     0x800D87D0                  // unknown subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Shared air physics function.
    // Based on 0x800D90E0
    scope air_physics_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _end                    // modified original branch
        or      a0, s0, r0                  // a0 = player struct
        jal     air_control_                // air control subroutine
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // original load registers
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles Goemons's horizontal air control for neutral special.
    // Based on 0x800D9044
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        or      t6, a1, r0                  // t6 = attribute pointer
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      a2, 0x004C(t6)              // a2 = air acceleration
        // load an immediate value into a3 instead of the air acceleration from the attributes
        lui     a3, AIR_SPEED               // a3 = AIR_SPEED
        jal     0x800D8FC8                  // air drift subroutine?
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
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
        addiu   t7, t7, -Goemon.Action.NSP_Ground_Begin
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
        addiu   t7, t7, -Goemon.Action.NSP_Air_Begin
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
        addiu   t7, t7, -Kirby.Action.GOEMON_NSP_Ground_Begin
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
        addiu   t7, t7, -Kirby.Action.GOEMON_NSP_Air_Begin
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
    dh Goemon.Action.NSP_Air_Begin          // NSP_Ground_Begin
    dh Goemon.Action.NSP_Air_Wait           // NSP_Ground_Wait
    dh Goemon.Action.NSP_Air_Wait           // NSP_Ground_Walk1
    dh Goemon.Action.NSP_Air_Wait           // NSP_Ground_Walk2
    dh Goemon.Action.NSP_Air_Wait           // NSP_Ground_BWalk1
    dh Goemon.Action.NSP_Air_Wait           // NSP_Ground_BWalk2
    dh Goemon.Action.NSP_Air_End            // NSP_Ground_End
    OS.align(4)

    air_to_ground_table:
    dh Goemon.Action.NSP_Ground_Begin       // NSP_Air_Begin
    dh Goemon.Action.NSP_Ground_Wait        // NSP_Air_Wait
    dh Goemon.Action.NSP_Ground_End         // NSP_Air_End
    OS.align(4)

    cycle_length_table:
    float32 40                              // NSP_Ground_Wait
    float32 80                              // NSP_Ground_Walk1
    float32 60                              // NSP_Ground_Walk2
    float32 80                              // NSP_Ground_BWalk1
    float32 60                              // NSP_Ground_BWalk2

    kirby_ground_to_air_table:
    dh Kirby.Action.GOEMON_NSP_Air_Begin    // NSP_Ground_Begin
    dh Kirby.Action.GOEMON_NSP_Air_Wait     // NSP_Ground_Wait
    dh Kirby.Action.GOEMON_NSP_Air_Wait     // NSP_Ground_Walk1
    dh Kirby.Action.GOEMON_NSP_Air_Wait     // NSP_Ground_Walk2
    dh Kirby.Action.GOEMON_NSP_Air_Wait     // NSP_Ground_BWalk1
    dh Kirby.Action.GOEMON_NSP_Air_Wait     // NSP_Ground_BWalk2
    dh Kirby.Action.GOEMON_NSP_Air_End      // NSP_Ground_End
    OS.align(4)

    kirby_air_to_ground_table:
    dh Kirby.Action.GOEMON_NSP_Ground_Begin // NSP_Air_Begin
    dh Kirby.Action.GOEMON_NSP_Ground_Wait  // NSP_Air_Wait
    dh Kirby.Action.GOEMON_NSP_Ground_End   // NSP_Air_End
    OS.align(4)

    kirby_cycle_length_table:
    float32 40                              // NSP_Ground_Wait
    float32 80                              // NSP_Ground_Walk1
    float32 60                              // NSP_Ground_Walk2
    float32 80                              // NSP_Ground_BWalk1
    float32 60                              // NSP_Ground_BWalk2

    // @ Description
    // Subroutine which sets up the initial properties for the ryo.
    // @ Arguments
    // a0 - player object
    // a1 - starting x/y/z coordinates
    scope ryo_stage_setting_: {
        addiu   sp, sp, -0x0050             // allocate stack space
        sw      s0, 0x0018(sp)              // store s0
        sw      s1, 0x001C(sp)              // store s1
        sw      a0, 0x0030(sp)              // 0x0030(sp) = player object
        sw      a1, 0x0034(sp)              // 0x0034(sp) = starting coordinates
        li      s0, ryo_properties_struct   // s0 = projectile properties struct address
        li      s1, sparkle_effect_projectile_struct // s1 = sparkle_effect_projectile_struct
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      at, 0x0B1C(t6)              // at = charge flag
        beqz    at, _continue               // branch if charge flag = FALSE
        sw      ra, 0x0038(sp)              // store ra

        // if we're here the charge flag is set to TRUE, so use the fire ryo properties instead
        li      s0, fire_ryo_properties_struct // s0 = projectile properties struct address
        li      s1, fire_effect_projectile_struct // s1 = fire_effect_projectile_struct

        _continue:
        lw      a2, 0x0034(sp)              // a2 = starting coordinates
        lw      t1, 0x0028(s0)              // t1 = hitbox offset
        li      a1, ryo_projectile_struct   // a1 = main projectile struct address
        lui     a3, 0x8000                  // a3 = bit flag?
        sw      t6, 0x002C(sp)              // 0x002C(sp) = player struct
        jal     0x801655C8                  // create projectile
        sw      t1, 0x000C(a1)              // override hitbox offset

        beq     v0, r0, _end_stage_setting  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object

        jal     0x801655A0                  // get projectile instance id
        nop
        lw      t0, 0x0028(sp)              // ~
        lw      t0, 0x0084(t0)              // t0 = ryo projectile special struct
        sw      r0, 0x01B8(t0)              // 0x01B8 in ryo projectile special struct = null
        beq     s1, r0, _projectile_branch  // skip if no effect projectile struct
        sw      v0, 0x0264(t0)              // store instance id
        lw      a0, 0x0030(sp)              // a0 = player object
        or      a1, s1, r0                  // a1 = effect projectile special struct
        lw      a2, 0x0034(sp)              // a2 = starting coordinates
        jal     0x801655C8                  // create projectile
        or      a3, r0, r0                  // a3 = 0

        beq     v0, r0, _projectile_branch  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip ahead
        lw      t0, 0x0084(v0)              // t0 = ryo projectile special struct

        _effect_projectile_branch:
        or      v1, v0, r0                  // v1 = effect projectile object
        lw      v0, 0x0028(sp)              // v0 = ryo projectile object
        lw      t0, 0x0084(v0)              // t0 = ryo projectile special struct
        lw      t1, 0x0084(v1)              // t1 = effect projectile special struct
        lw      at, 0x0264(t0)              // ~
        sw      at, 0x0264(t1)              // pass instance id to effect projectile
        sw      v1, 0x01B8(t0)              // 0x01B8 in ryo projectile special struct = effect projectile object
        sw      r0, 0x01B4(t1)              // effect destruction flag = FALSE
        sw      v0, 0x01B8(t1)              // 0x01B8 in effect projectile special struct = ryo projectile object

        _projectile_branch:
        li      t3, ryo_blast_zone_         // t3 = ryo_blast_zone_
        sw      t3, 0x0298(t0)              // store blast zone routine
        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(t0)              // store duration
        lw      t4, 0x002C(sp)              // t4 = player struct
        lw      t5, 0x0B1C(t4)              // t5 = charge flag
        sw      t5, 0x01B4(t0)              // 0x01B4 in ryo projectile special struct = charge flag
        lw      t5, 0x014C(t4)              // t5 = kinetic state
        beq     t5, r0, _play_fgm           // branch if kinetic state = grounded
        lwc1    f12, 0x0018(s0)             // f12 = initial angle (ground)
        lwc1    f12, 0x001C(s0)             // f12 = initial angle (air)

        _play_fgm:
        lw      t5, 0x0B1C(t4)              // t5 = charge flag
        beqz    t5, _skip_fgm               // skip if charge flag != TRUE
        nop
        FGM.play(SFX_RYO_FIRE)              // play FGM

        _skip_fgm:
        swc1    f12, 0x0020(sp)             // 0x0020(sp) = projectile angle
        lw      v0, 0x0028(sp)              // v0 = ryo projectile object
        lw      v1, 0x0084(v0)              // v1 = ryo projectile special struct
        jal     0x80035CD0                  // ~
        sw      v1, 0x0024(sp)              // original logic

        lwc1    f6, 0x0020(s0)              // f6 = initial projectile speed
        lw      t6, 0x002C(sp)              // ~
        lw      v1, 0x0024(sp)              // ~
        lw      t7, 0x0044(t6)              // ~
        mul.s   f8, f0, f6                  // ~
        lwc1    f12, 0x0020(sp)             // ~
        mtc1    t7, f10                     // ~
        nop                                 // ~
        cvt.s.w f16, f10                    // ~
        mul.s   f18, f8, f16                // ~
        jal     0x800303F0                  // ~
        swc1    f18, 0x0020(v1)             // original logic

        lwc1    f4, 0x0020(s0)              // f4 = initial projectile speed
        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        mul.s   f6, f0, f4                  // ~
        swc1    f6, 0x0024(v1)              // ~
        lw      t8, 0x0074(a0)              // ~
        lwc1    f10, 0x002C(s0)             // ~
        lw      t9, 0x0080(t8)              // ~
        jal     ryo_rotation_               // ~
        swc1    f10, 0x0088(t9)             // ~
        lw      v0, 0x0028(sp)              // original logic

        _end_stage_setting:
        lw      ra, 0x0038(sp)              // load ra
        lw      s0, 0x0018(sp)              // load s0
        lw      s1, 0x001C(sp)              // load s1
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Subroutine which sets initial rotation for the ryo.
    // @ Arguments
    // a0 - projectile object
    scope ryo_rotation_: {
        lw      v0, 0x0084(a0)              // v0 = projectile special struct
        lw      a1, 0x01B8(v0)              // a1 = effect projectile object
        li      t0, 0x3FC90FDB              // t0 = initial angle (1.5708 rads/90 degrees)
        lw      t1, 0x0020(v0)              // t1 = projectile velocity
        lui     at, 0x8000                  // ~
        and     t1, t1, at                  // t0 = bitmask for positive/negative velocity
        or      t1, t1, t0                  // t1 = initial angle corrected with velocity bitmask
        beqz    a1, _end                    // skip if no effect projectile
        lw      v0, 0x0074(a0)              // v0 = projectile part 0 struct

        lw      v1, 0x0074(a1)              // v1 = effect projectile part 0 struct
        sw      t1, 0x0034(v1)              // effect y rotation = 90 degrees | direction

        _end:
        sw      t1, 0x0030(v0)              // x rotation = 90 degrees | direction
        sw      r0, 0x0034(v0)              // y rotation = 0
        jr      ra
        sw      t0, 0x0038(v0)              // z rotation = 90 degrees
    }

    // @ Description
    // Main subroutine for the ryo.
    scope ryo_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      a0, 0x0020(sp)              // 0x0020(sp) = projectile object
        sw      s0, 0x0024(sp)              // store s0
        lw      a0, 0x0084(a0)              // a0 = projectile special struct
        li      s0, ryo_properties_struct   // s0 = projectile properties struct address
        lw      at, 0x01B4(a0)              // at = charge flag
        beqz    at, _check_duration         // branch if charge flag = FALSE
        sw      ra, 0x0014(sp)              // store ra

        // if we're here the charge flag is set to TRUE, so use the fire ryo properties instead
        li      s0, fire_ryo_properties_struct // s0 = projectile properties struct address

        _check_duration:
        jal     0x80167FE8                  // original logic, subroutine returns 1 if projectile duration is over
        sw      a0, 0x001C(sp)              // 0x001C(sp) = projectile special struct
        beq     v0, r0, _continue           // branch if projectile duration has not ended
        lw      a0, 0x001C(sp)              // a0 = projectile special struct

        _end_duration:
        lw      a1, 0x001C(sp)              // a1 = projectile special struct
        lw      t0, 0x01B8(a1)              // t0 = effect projectile object
        beqz    t0, _destroy                // branch if no effect projectile
        lli     at, OS.TRUE                 // at = TRUE
        lw      t0, 0x0084(t0)              // t0 = effect projectile special struct
        sw      at, 0x01B4(t0)              // signify to the effect projectile struct that its time in this world has come to an end

        _destroy:
        lw      t7, 0x0020(sp)              // t7 = projectile object
        lw      a0, 0x0074(t7)              // a0 = projectile part 0 struct
        lw      at, 0x01B4(a1)              // at = charge flag
        bnez    at, _explode                // branch if charge flag = TRUE
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords

        jal     0x800FF648                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0
        b       _end                        // branch to end
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)

        _explode:
        jal     0x80100480                  // create smoke gfx
        nop
        jal     0x800269C0                  // play FGM
        lli     a0, 0                       // FGM id = 0
        b       _end                        // branch to end
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)

        _continue:
        lw      a1, 0x000C(s0)              // a1 = gravity
        jal     0x80168088                  // apply gravity to ryo
        lw      a2, 0x0004(s0)              // a2 = max speed

        lw      a0, 0x001C(sp)              // a0 = projectile special struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile joint 0 struct
        lwc1    f6, 0x0014(s0)              // f6 = rotation speed
        lwc1    f4, 0x0034(v1)              // f4 = current rotation
        sub.s   f8, f4, f6                  // subtract rotation speed from current rotation
        swc1    f8, 0x0034(v1)              // update rotation
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        lw      s0, 0x0024(sp)              // load s0
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for the ryo.
    // Based on 0x801688C4, which is the equivalent for Charge Shot.
    scope ryo_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x00014(sp)             // store ra

        jal     0x80167C04                  // general collision detection?
        sw      a0, 0x0018(sp)              // 0x0018(sp) = projectile object
        beqz    v0, _end                    // end if collision wasn't detected
        lw      a0, 0x0018(sp)              // a2 = projectile object
        // if collision was detected
        jal     ryo_destruction_
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for effect projectile objects.
    scope effect_projectile_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      a0, 0x0020(sp)              // 0x0020(sp) = projectile object
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = effect projectile special struct
        lw      t0, 0x01B4(v0)              // t0 = destruction flag
        bnezl   t0, _end                    // end if destruction flag = TRUE...
        lli     v0, OS.TRUE                 // ...and return TRUE (destroys projectile)

        lw      t0, 0x01B8(v0)              // ~
        lw      t0, 0x0074(t0)              // t0 = ryo projectile joint 0 struct
        beqzl   t0, _end
        lli     v0, OS.TRUE                 // return TRUE (destroy)
        lw      t1, 0x0074(a0)              // t1 = effect projectile joint 0 struct
        lw      at, 0x001C(t0)              // ~
        sw      at, 0x001C(t1)              // copy projectile x to effect projectile
        lw      at, 0x0020(t0)              // ~
        sw      at, 0x0020(t1)              // copy projectile y to effect projectile
        lw      at, 0x0024(t0)              // ~
        sw      at, 0x0024(t1)              // copy projectile z to effect projectile
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // This subroutine destroys the ryo and creates a smoke gfx.
    scope ryo_destruction_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = projectile special struct
        lw      t0, 0x01B8(v0)              // t0 = effect projectile object
        beqz    t0, _end                    // skip if no effect projectile
        lli     at, OS.TRUE                 // at = TRUE
        lw      t0, 0x0084(t0)              // t0 = effect projectile special struct
        sw      at, 0x01B4(t0)              // signify to the effect projectile struct that its time in this world has come to an end
        lw      a0, 0x0074(a0)              // projectile part 0 struct
        lw      at, 0x01B4(v0)              // at = charge flag
        bnez    at, _explode                // branch if charge flag = TRUE
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords

        jal     0x800FF648                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0
        b       _end                        // branch to end
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)

        _explode:
        jal     0x80100480                  // create smoke gfx
        nop
        jal     0x800269C0                  // play FGM
        lli     a0, 0                       // FGM id = 0
        b       _end                        // branch to end
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)
    }

    // @ Description
    // This subroutine destroys the ryo when it crosses a blast zone.
    scope ryo_blast_zone_: {
        lw      v0, 0x0084(a0)              // v0 = projectile special struct
        lw      t0, 0x01B8(v0)              // t0 = effect projectile object
        beqz    t0, _end                    // skip if no effect projectile
        lli     at, OS.TRUE                 // at = TRUE
        lw      t0, 0x0084(t0)              // t0 = effect projectile special struct
        sw      at, 0x01B4(t0)              // signify to the effect projectile struct that its time in this world has come to an end

        _end:
        jr      ra                          // return
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)
    }

    // @ Description
    // This subroutine reflects the ryo and changes the rotation of the graphic on top
    scope ryo_reflect_: {
        OS.routine_begin(0x20)              // allocate stackspace

        jal     0x801692C4                  // reflect projectile routine
        sw      a0, 0x0018(sp)              // save a0

        jal     ryo_rotation_
        lw      a0, 0x0018(sp)              // load a0

        addiu   v0, r0, 0                   // return 0 (dont destroy)

        OS.routine_end(0x20)                // deallocate stackspace and return
    }

    // @ Description
    // This subroutine bounces the ryo off shields and changes the rotation of the graphic on top
    scope ryo_shield_bounce_: {
        OS.routine_begin(0x20)              // allocate stackspace

        jal     0x801686F8                  // bounce projectile routine
        sw      a0, 0x0018(sp)              // save a0

        jal     ryo_rotation_
        lw      a0, 0x0018(sp)              // load a0

        addiu   v0, r0, 0                   // return 0 (dont destroy)

        OS.routine_end(0x20)                // deallocate stackspace and return
    }

    OS.align(16)
    ryo_projectile_struct:
    constant RYO_ID(0x1004)
    dw 0x00000000                           // unknown
    dw RYO_ID                               // projectile id
    dw Character.GOEMON_file_6_ptr          // address of goemon's file 6 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x12450000                           // Render routine
    dw ryo_main_                            // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw ryo_collision_                       // This is the collision subroutine for the projectile, responsible for detecting collision with clipping.
    dw ryo_destruction_                     // This function runs when the projectile collides with a hurtbox.
    dw ryo_destruction_                     // This function runs when the projectile collides with a shield.
    dw ryo_shield_bounce_                   // This function runs when the projectile collides with edges of a shield and bounces off
    dw ryo_destruction_                     // This function runs when the projectile collides/clangs with a hitbox.
    dw ryo_reflect_                         // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw ryo_destruction_                     // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    fire_effect_projectile_struct:
    dw 0x00000000                           // unknown
    dw RYO_ID                               // projectile id
    dw Character.GOEMON_file_6_ptr          // address of goemon's file 6 pointer
    dw 0x00000080                           // offset to hitbox
    dw 0x12480000                           // Render routine
    dw effect_projectile_main_              // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0                                    // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw 0                                    // This function runs when the projectile collides with a hurtbox.
    dw 0                                    // This function runs when the projectile collides with a shield.
    dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
    dw 0                                    // This function runs when the projectile collides/clangs with a hitbox.
    dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    sparkle_effect_projectile_struct:
    dw 0x00000000                           // unknown
    dw RYO_ID                               // projectile id
    dw Character.GOEMON_file_6_ptr          // address of goemon's file 6 pointer
    dw 0x000000C0                           // offset to hitbox
    dw 0x12480000                           // Render routine
    dw effect_projectile_main_              // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0                                    // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw 0                                    // This function runs when the projectile collides with a hurtbox.
    dw 0                                    // This function runs when the projectile collides with a shield.
    dw 0                                    // This function runs when the projectile collides with edges of a shield and bounces off
    dw 0                                    // This function runs when the projectile collides/clangs with a hitbox.
    dw 0                                    // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw 0                                    // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    ryo_properties_struct:
    dw 40                                   // 0x0000 - duration (int)
    float32 100                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.3                             // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (ground)
    float32 0                               // 0x001C   initial angle (air)
    float32 100                             // 0x0020   initial speed
    dw Character.GOEMON_file_6_ptr          // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   offset to hitbox
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)

    OS.align(16)
    fire_ryo_properties_struct:
    dw 60                                   // 0x0000 - duration (int)
    float32 130                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.5                             // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (ground)
    float32 0                               // 0x001C   initial angle (air)
    float32 130                             // 0x0020   initial speed
    dw Character.GOEMON_file_6_ptr          // 0x0024   projectile data pointer
    dw 0x00000040                           // 0x0028   offset to hitbox
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)
}

// @ Description
// Subroutines for Up Special
scope GoemonUSP {
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
        lli     a1, Goemon.Action.USP       // a1(action id) = USP
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        jal     attach_cloud_               // attach_cloud_
        lw      a0, 0x0018(sp)              // a0 = player object
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
        FGM.play(0x500)                     // play cloud spawn sfx

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
    // Checks for turnaround inputs.
    // @ Arguments
    // a0 - player object
    scope check_turn_: {
        // begin by checking for turn inputs
        lw      a1, 0x0084(a0)              // a1 = player struct
        lb      t6, 0x01C2(a1)              // t6 = stick_x
        lw      t7, 0x0044(a1)              // t7 = DIRECTION
        multu   t6, t7                      // ~
        mflo    t6                          // t6 = stick_x * DIRECTION
        slti    at, t6, -39                 // at = 1 if stick_x < -39, else at = 0
        beqz    at, _end                    // branch if stick_x >= -39
        nop

        // if we're here, stick_x is opposite the facing direction, so turn the character around
        subu    t7, r0, t7                  // ~
        sw      t7, 0x0044(a1)              // reverse and update DIRECTION

        _end:
        jr      ra                          // return
        nop
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
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, Goemon.Action.USPJump   // a1(action id) = USPJump
        b       _end                        // end
        nop

        // _check_turn:
        // lwc1    f2, 0x0048(v1)              // ~
        // abs.s   f2, f2                      // ~
        // cvt.w.s f2, f2                      // ~
        // lui     at, 0x8000                  // at = sign bitmask
        // lw      t6, 0x0044(v1)              // t6 = DIRECTION
        // lw      t7, 0x0048(v1)              // t7 = x velocity
        // and     t6, t6, at                  // t6 = DIRECTION sign
        // and     t7, t7, at                  // t7 = x velocity sign
        // mfc1    at, f2                      // at = int(|x velocity|)
        // sltiu   at, 4                       // at = 1 if int(|x velocity|) < 4, else at = 0
        // bnezl   at, _end                    // end if x velocity < 4...
        // lw      ra, 0x0024(sp)              // ...and load ra
        // beql    t6, t7, _end                // end if DIRECTION and x velocity signs match...
        // lw      ra, 0x0024(sp)              // ...and load ra
        //
        // // if the signs of DIRECTION and x velocity don't match, begin a turn
        // jal     shared_initial_             // transition to USP action
        // lli     a1, Goemon.Action.USPTurn   // a1(action id) = USPTurn
        // lw      ra, 0x0024(sp)              // load ra

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // scrapped turn action
    // // @ Description
    // // Main function for USPTurn.
    // scope turn_main_: {
    //     addiu   sp, sp,-0x0030              // allocate stack space
    //     sw      ra, 0x0024(sp)              // store ra
    //     lw      v1, 0x0084(a0)              // v1 = player struct
    //     lw      t6, 0x0B18(v1)              // t6 = frame timer
    //     slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
    //     addiu   t6, t6, 0x0001              // ~
    //     bnez    at, _check_end_transition   // branch if frame timer < MAX_TIME
    //     sw      t6, 0x0B18(v1)              // increment frame timer
    //
    //     // if frame timer has reached MAX_TIME
    //     lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
    //     or      a2, r0, r0                  // a2 (unknown) = 0
    //     lli     a3, 0x0001                  // a3 (unknown) = 1
    //     sw      r0, 0x0010(sp)              // unknown argument = 0
    //     sw      r0, 0x0018(sp)              // interrupt flag = FALSE
    //     lui     t6, LANDING_FSM             // t6 = LANDING_FSM
    //     jal     0x801438F0                  // begin special fall
    //     sw      t6, 0x0014(sp)              // store LANDING_FSM
    //     b       _end                        // end
    //     nop
    //
    //     _check_end_transition:
    //     // checks the current animation frame to see if we've reached end of the animation
    //     mtc1    r0, f6                      // ~
    //     lwc1    f8, 0x0078(a0)              // ~
    //     c.le.s  f8, f6                      // ~
    //     bc1fl   _end                        // skip if animation end has not been reached
    //     nop
    //     lw      at, 0x0044(v1)              // at = DIRECTION
    //     subu    at, r0, at                  // ~
    //     sw      at, 0x0044(v1)              // reverse and update DIRECTION
    //     jal     shared_initial_             // transition to USP action
    //     lli     a1, Goemon.Action.USP       // a1(action id) = USP
    //
    //     _end:
    //     lw      ra, 0x0024(sp)              // load ra
    //     jr      ra                          // return
    //     addiu   sp, sp, 0x0030              // deallocate stack space
    // }

    // @ Description
    // Main function for USPAttack.
    scope attack_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x0B18(v1)              // t6 = frame timer
        slti    at, t6, MAX_TIME            // at = 1 if frame timer < MAX_TIME, else at = 0
        addiu   t6, t6, 0x0001              // ~
        bnez    at, _check_end_transition   // branch if frame timer < MAX_TIME
        sw      t6, 0x0B18(v1)              // increment frame timer

        // if frame timer has reached MAX_TIME
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        b       _end                        // end
        nop

        _check_end_transition:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, Goemon.Action.USP       // a1(action id) = USP

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for USPJump.
    // Transitions to special fall on animation end.
    scope jump_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x017C(v1)              // t6 = temp variable 1
        lli     at, 0x0001                  // ~
        bne     t6, at, _check_end_transition // branch if temp variable 1 != 1
        lli     at, 0x0002                  // ~

        // apply jump velocity if temp variable 1 = 1
        sw      at, 0x017C(v1)              // temp variable 1 = 2
        lui     at, JUMP_SPEED              // ~
        sw      at, 0x004C(v1)              // y velocity = JUMP_SPEED

        _check_end_transition:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for USPEscape.
    // Transitions to special fall on animation end.
    scope escape_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F70                  // a1 (air speed multiplier) = 0.9375
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Interrupt function for USP actions
    scope interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      a1, 0x0084(a0)              // a1 = player struct

        // begin by checking for A and B presses
        lhu     v0, 0x01BE(a1)              // v0 = buttons_pressed
        andi    at, v0, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED), else t6 = 0
        beqz    at, _check_escape           // branch if both A and B are not being pressed
        nop

        // if we're here, A or B has been pressed, so transition to USPAttack
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, Goemon.Action.USPAttack // a1(action id) = USPAttack
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_escape:
        // now check if Shield button has been pressed
        lhu     at, 0x01B8(a1)              // at = shield press bitmask
        and     at, at, v0                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _check_jump         // branch if shield is not pressed
        nop

        // if we're here, Shield has been pressed, so transition to USPEscape
        lui     at, ESCAPE_SPEED            // ~
        sw      at, 0x004C(a1)              // y velocity = ESCAPE_SPEED
        jal     shared_initial_             // transition to USP action
        lli     a1, Goemon.Action.USPEscape // a1(action id) = USPEscape
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _check_jump:
        // finally, check for C inputs
        // at = !0 if (CU_PRESSED) or (CD_PRESSED) or (CL_PRESSED) or (CR_PRESSED), else t6 = 0
        andi    at, v0, Joypad.CU | Joypad.CD | Joypad.CL | Joypad.CR
        beqzl   at, _end                    // branch if no c buttons are being pressed...
        lw      ra, 0x0014(sp)              // ...and load ra

        // if we're here, a C button has been pressed, so transition to USPJump
        jal     check_turn_                 // check for turnaround inputs
        nop
        jal     shared_initial_             // transition to USP action
        lli     a1, Goemon.Action.USPJump   // a1(action id) = USPJump
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dellocate stack space
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
    // Handles physics for USPJump
    scope jump_physics_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      t6, 0x017C(v1)              // t6 = temp variable 1
        bnez    t6, _control                // branch if temp variable 1 is set
        nop

        // before temp variable 1 is set
        jal     physics_                    // USP physics function
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _control:
        jal     0x800D9160                  // general physics function (allows player control)
        nop
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for Goemons's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Goemon.
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
       jal      destroy_attached_cloud_    // destroy attached minion
       sw       r0, 0x0AE4(a0)              // reset charge level
       lw       ra, 0x0014(sp)              // load ra
       jr       ra                          // return
       addiu    sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which attaches a cloud to Goemon's Feet.
    // a0 - player object
    scope attach_cloud_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0038(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct

        _goemon:
        li      t7, goemon_on_hit_subroutine_ // t7 = on hit subroutine

        _continue:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        or      a0, s0, r0                  // a0 = player struct
        jal     0x8015D35C                  // get part position
        addiu   a1, sp, 0x0028              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x0038(sp)              // a0 = player object
        addiu   a2, sp, 0x0028              // x/y/z coordinates

		// makes a cloud
        lw      a0, 0x0038(sp)              // 0x0034(sp) = player object
        lw      t0, 0x0084(a0)              // loads player struct
        addiu   a3, sp, 0x0040              // a3 = unknown x/y/z offset
        sw      r0, 0x0000(a3)              // x offset
        sw      r0, 0x0004(a3)              // set y offset to 0
        sw      r0, 0x0008(a3)              // z offset
        li      a1, Item.Cloud.item_info_array // a1 = cloud

        _create_cloud:
        jal     Item.Cloud.SPAWN_ITEM           // create item
        addiu   a3, sp, 0x0040                  // a3 = unknown x/y/z offset
        beqz    v0, _end                     // end if item not created
        li      at, Size.item.render_routine_
        sw      at, 0x002C(v0)              // set custom render routine so size is obeyed

        _end:
        sw      v0, 0x0B20(s0)              // store attached item object
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Destroys Goemon's attached item object.
    // @ Arguments
    // a0 - player struct
    scope destroy_attached_cloud_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0B20(a0)              // a1 = attached item object
        beqz    a1, _end                    // skip if no attached item object
        sw      r0, 0x0B20(a0)              // reset attached item object

        or      a0, a1, r0                  // a0 = attached item object
        lw      a1, 0x0084(a0)              // a1 = item special struct
        lli     at, 0x001C                  // at = fake item id
        jal     0x801728D4                  // destroy item
        sw      at, 0x000C(a1)              // override item id to prevent smoke gfx

        _end:
        lw       ra, 0x0014(sp)             // load ra
        jr       ra                         // return
        addiu    sp, sp, 0x0018             // deallocate stack space
    }

}

// @ Description
// Subroutines for Down Special
scope GoemonDSP {
    constant ATTACK_X_SPEED(0x4280)         // float32 64
    constant END_X_SPEED(0x41C0)            // float32 24
    constant END_Y_SPEED(0x4210)            // float32 36
    constant COLLISION_SFX(0x13)            // grab fgm

    // @ Description
    // Initial subroutine for DSPGround.
    scope ground_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, Goemon.Action.DSPGround // a1(action id) = DSPGround
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        li      a1, ground_pull_initial_    // a1 = ground_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSPAir.
    scope air_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lli     a1, Goemon.Action.DSPAir    // a1(action id) = DSPAir
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        li      a1, air_pull_initial_       // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSPGroundPull.
    scope ground_pull_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lli     a1, Goemon.Action.DSPGroundPull // a1(action id) = DSPGroundPull
        lwc1    f2, 0x0180(v1)              // ~
        cvt.s.w f2, f2                      // ~
        mfc1    a2, f2                      // a2(starting frame) = temp variable 2
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     grab_pull_setup_            // additional command grab setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        FGM.play(COLLISION_SFX)             // play collision sfx
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSPAirPull.
    scope air_pull_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lli     a1, Goemon.Action.DSPAirPull // a1(action id) = DSPAirPull
        lwc1    f2, 0x0180(v1)              // ~
        cvt.s.w f2, f2                      // ~
        mfc1    a2, f2                      // a2(starting frame) = temp variable 2
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     grab_pull_setup_            // additional command grab setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0048(a0)              // x velocity = 0
        sw      r0, 0x004C(a0)              // y velocity = 0
        swc1    f4, 0x0048(a0)              // store updated x velocity
        FGM.play(COLLISION_SFX)             // play collision sfx
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSPGroundWallPull.
    scope ground_wall_pull_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lli     a1, Goemon.Action.DSPGroundWallPull // a1(action id) = DSPGroundWallPull
        lwc1    f2, 0x0180(v1)              // ~
        cvt.s.w f2, f2                      // ~
        mfc1    a2, f2                      // a2(starting frame) = temp variable 2
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        FGM.play(COLLISION_SFX)             // play collision sfx
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSPAirWallPull.
    scope air_wall_pull_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lli     a1, Goemon.Action.DSPAirWallPull // a1(action id) = DSPAirWallPull
        lwc1    f2, 0x0180(v1)              // ~
        cvt.s.w f2, f2                      // ~
        mfc1    a2, f2                      // a2(starting frame) = temp variable 2
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0048(a0)              // x velocity = 0
        sw      r0, 0x004C(a0)              // y velocity = 0
        swc1    f4, 0x0048(a0)              // store updated x velocity
        FGM.play(COLLISION_SFX)             // play collision sfx
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for DSPAAttack.
    // DISABLED: Transition to Idle instead if B is not held
    scope attack_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        // lw      v0, 0x0084(a0)              // v0 = player struct
        // lh      t6, 0x01BC(v0)              // t6 = buttons_held
        // andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_HELD); else t6 = 0
        // beqz    t6, _idle                   // branch if (!B_HELD)
		sw      a0, 0x0018(sp)              // 0x0018(a0) = player object

        lw      v0, 0x0084(a0)              // v0 = player struct
        lli     at, 0x0001                  // ~
        sw      at, 0x014C(v0)              // kinetic state = aerial
        lbu     t6, 0x0148(v0)              // v0 = jumps used
        beqzl   t6, pc() + 8                // if jumps used = 0...
        sb      at, 0x0148(v0)              // ...jumps used = 1
        lli     a1, Goemon.Action.DSPAAttack // a1(action id) = DSPAAttack
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        // b       _end                        // branch to end
        lui     at, ATTACK_X_SPEED          // at = ATTACK_X_SPEED

        // _idle:
        // jal     0x800DEE54                  // transition to idle (ground and air)
        // nop
        // lui     at, END_X_SPEED             // at = END_X_SPEED

        // _end:
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        mtc1    at, f2                      // f2 = ATTACK_X_SPEED
        lwc1    f4, 0x0044(a0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = ATTACK_X_SPEED * DIRECTION
        lui     at, END_Y_SPEED             // ~
        sw      at, 0x004C(a0)              // y velocity = END_Y_SPEED
        swc1    f2, 0x0048(a0)              // x velocity = ATTACK_X_SPEED * DIRECTION
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for DSPEnd.
    scope end_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(a0) = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lli     at, 0x0001                  // ~
        sw      at, 0x014C(v0)              // kinetic state = aerial
        lbu     t6, 0x0148(v0)              // v0 = jumps used
        beqzl   t6, pc() + 8                // if jumps used = 0...
        sb      at, 0x0148(v0)              // ...jumps used = 1
        lli     a1, Goemon.Action.DSPEnd    // a1(action id) = DSPEnd
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, END_X_SPEED             // ~
        mtc1    at, f2                      // f2 = END_X_SPEED
        lwc1    f4, 0x0044(a0)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = END_X_SPEED * DIRECTION
        lui     at, END_Y_SPEED             // ~
        sw      at, 0x004C(a0)              // y velocity = END_Y_SPEED
        swc1    f2, 0x0048(a0)              // x velocity = END_X_SPEED * DIRECTION
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Subroutine which helps set up the command grab for Goemon.
    scope grab_pull_setup_: {
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
    // Main function for DSPGround and DSPAir
    scope main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      t5, 0x0084(a0)              // t5 = player struct
        lw      t6, 0x0180(t5)              // t6 = starting frame (temp variable 2)
        beqz    t6, _check_idle             // skip if starting frame = 0
        addiu   t6, t6,-0x0001              // t6 = decrement starting frame
        sw      t6, 0x0180(t5)              // store updated starting frame

        _check_idle:
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
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for DSPGroundPull and DSPAirPull.
    // Based on 0x8014A0C0, which is the main function for throws.
    scope pull_main_: {
        // Copy the first 67 lines of subroutine 0x8014A0C0
        OS.copy_segment(0xC4B00, 0x10C)

        jal     attack_initial_             // transition to DSPAttack
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra

        _end:
        lw      s0, 0x0018(sp)              // load s0
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for DSPGroundWallPull and DSPAirWallPull
    scope wall_pull_main_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      v0, 0x0018(sp)              // 0x0018(sp) = player struct

        _check_idle:
        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     end_initial_                // transition to DSPEnd
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSPGround.
    scope ground_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      at, 0x0184(v0)              // at = temp variable 3
        beqz    at, _check_collision        // branch if temp variable 3 is not set
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        // if temp variable 3 is set, check for chain collisions
        jal     chain_collision_            // run collision for chain
        nop

        beqz    v0, _check_collision        // branch if no collision detected
        lw      a0, 0x0018(sp)              // a0 = player object

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      at, 0x0044(v1)              // at = DIRECTION
        bgezl   at, _wall_chain_collision   // branch if direction = right
        andi    v0, v0, 0x0001              // a1 = collision result & left wall mask
        andi    v0, v0, 0x0002              // a1 = collision result & right wall mask

        _wall_chain_collision:
        beqz    v0, _check_collision        // branch if collision result is not valid for direction
        nop

        // if we're here, then the chain is colliding with a wall in front of Goemon, so transition to DSPGroundWallPull
        jal     ground_wall_pull_initial_   // transition to DSPGroundWallPull
        lw      a0, 0x0018(sp)              // a0 = player object
        b       _end                        // branch to end
        nop

        _check_collision:
        li      a1, ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSPAir.
    scope air_collision_: {
       addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      at, 0x0184(v0)              // at = temp variable 3
        beqz    at, _check_collision        // branch if temp variable 3 is not set
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        // if temp variable 3 is set, check for chain collisions
        jal     chain_collision_            // run collision for chain
        nop

        beqz    v0, _check_collision        // branch if no collision detected
        lw      a0, 0x0018(sp)              // a0 = player object

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      at, 0x0044(v1)              // at = DIRECTION
        bgezl   at, _wall_chain_collision   // branch if direction = right
        andi    v0, v0, 0x0001              // a1 = collision result & left wall mask
        andi    v0, v0, 0x0002              // a1 = collision result & right wall mask

        _wall_chain_collision:
        beqz    v0, _check_collision        // branch if collision result is not valid for direction
        nop

        // if we're here, then the chain is colliding with a wall in front of Goemon, so transition to DSPAirWallPull
        jal     air_wall_pull_initial_      // transition to DSPAirWallPull
        lw      a0, 0x0018(sp)              // a0 = player object
        b       _end                        // branch to end
        nop

        _check_collision:
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from DSPGround to DSPAir.
    scope ground_to_air_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // ~
        lw      a1, 0x0024(a1)              // ~
        addiu   a1, a1, 0x0004              // a1 = equivalent air action for current ground action (id + 4)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0003                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0003
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // a0 = player object
        li      a1, air_pull_initial_       // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the transition from DSPAir to DSPGround.
    scope air_to_ground_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // ~
        lw      a1, 0x0024(a1)              // ~
        addiu   a1, a1,-0x0004              // a1 = equivalent air action for current ground action (id - 4)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0003                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0003
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // a0 = player object
        li      a1, ground_pull_initial_    // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSPGround actions.
    scope shared_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, shared_ground_to_air_    // a1(transition subroutine) = shared_ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for DSPAir actions.
    scope shared_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, shared_air_to_ground_   // a1(transition subroutine) = shared_air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground to air transitions for DSPGround actions.
    scope shared_ground_to_air_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // ~
        lw      a1, 0x0024(a1)              // ~
        addiu   a1, a1, 0x0004              // a1 = equivalent air action for current ground action (id + 4)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0003                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0003
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transitions for DSPAir actions.
    scope shared_air_to_ground_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // ~
        lw      a1, 0x0024(a1)              // ~
        addiu   a1, a1,-0x0004              // a1 = equivalent air action for current ground action (id - 4)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0003                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0003
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Sets up an ECB for the chain pipe and detects collisions.
    // @ Arguments
    // a0 - player object
    // @ Returns
    // v0 - 0 for no collision, 1 for left wall collision, 2 for right wall collision
    scope chain_collision_: {
        addiu   sp, sp,-0x0110              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        sw      r0, 0x0000(a1)              // ~
        sw      r0, 0x0004(a1)              // ~
        sw      r0, 0x0008(a1)              // clear space for x/y/z coordinates
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        lw      a0, 0x094C(v0)              // a0 = chain end joint

        lw      a0, 0x0018(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        addiu   t0, v0, 0x0078              // t0 = ecb info
        addiu   t1, sp, 0x0030              // t1 = chain ecb info
        addiu   at, sp, 0x0020              // ~
        sw      at, 0x0000(t1)              // store chain end x/y/z pointer
        or      t2, t0, r0                  // ~
        or      t3, t1, r0                  // loop setup
        addiu   t4, t1, 0x00D0              // loop end address

        _loop:
        addiu   t2, t2, 0x0004              // ~
        addiu   t3, t3, 0x0004              // increment copy address
        lw      at, 0x0000(t2)              // ~
        bne     t3, t4, _loop               // loop if end not reached
        sw      at, 0x0000(t3)              // copy data from player ecb to chain ecb

        lui     at, 0x4120                  // ~
        sw      at, 0x0038(t1)              // chain ecb upper y = 10
        lui     at, 0x40A0                  // ~
        sw      at, 0x003C(t1)              // chain ecb middle y = 5
        sw      r0, 0x0040(t1)              // chain ecb lower y = 0
        lui     at, 0x4320                  // ~
        sw      at, 0x0044(t1)              // chain ecb width = 160
        addiu   at, t1, 0x0038              // ~
        sw      at, 0x0048(t1)              // store ecb pointer

        or      a0, t1, r0                  // a0 = chain ecb info
        lw      a1, 0x0018(sp)              // a1 = player object
        jal     chain_detect_collision_     // detect collision for chain
        or      a2, r0, r0                  // a2 = 0

        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0110              // allocate stack space
    }

    // @ Description
    // Collision detection function for DSP.
    // Based on function 0x800DE45C
    // @ Arguments
    // a0 - ECB info
    // a1 - player object
    // a2 - unknown(0)
    // @ Returns
    // v0 - 0 for no collision, 1 for left wall collision, 2 for right wall collision, 3 for floor collision, 4 for ceiling
    scope chain_detect_collision_: {
        addiu   sp, sp,-0x0058              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s1, 0x0018(sp)              // ~
        sw      s0, 0x0014(sp)              // store ra, s0, s1
        sw      a1, 0x003C(sp)              // 0x003C(sp) = player object
        sw      a2, 0x0040(sp)              // 0x0040(sp) = unknown
        lw      s0, 0x0084(a1)              // s0 = player struct
        or      s1, a0, r0                  // s1 = ecb info
        lw      t0, 0x0044(s0)              // t0 = player direction
        addiu   at, r0, 1                   // at = 1
        bne     at, t0, _check_right_wall   // check right wall collision if facing left
        nop

        _check_left_wall:
        jal     0x800DB838                  // detect left wall collision
        sw      r0, 0x0024(sp)              // 0x0024(sp) = 0
        bnez    v0, _end                    // branch if left collision = true
        lli     v0, 0x0001                  // v0 = 0x1 (left collision)
        b       _check_floor
        nop

        _check_right_wall:
        jal     0x800DC3C8                  // detect right wall collision
        or      a0, s1, r0                  // a0 = ecb info
        bnez    v0, _end                    // branch if right wall collision = true
        lli     v0, 0x0002                  // v0 = 0x2 (right collision)

        _check_floor:
        //jal     0x800DD578                  // detect floor collision
        //or      a0, s1, r0                  // a0 = ecb info

        //bnez    v0, _end                    // branch if floor collision = true
        //lli     v0, 0x0003                  // v0 = 0x3 (floor collision)

        jal     0x800DCF58
        or      a0, s1, r0                  // a0 = ecb info

        bnez    v0, _end                    // branch if ceiling collision = true
        lli     v0, 0x0004                  // v0 = 0x4 (ceiling collision)

        or      v0, r0, r0                  // if no wall collision detected, v0 = 0 (no collision)

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s1, 0x0018(sp)              // ~
        lw      s0, 0x0014(sp)              // load ra, s0, s1

        jr      ra                          // return
        addiu   sp, sp, 0x0058              // deallocate stack space
    }

    // @ Description
    // Patch which allows Goemon's down b to collide with item hurtboxes.
    scope item_hurtbox_patch_: {
        OS.patch_start(0xEB0D8, 0x80170698)
        j       item_hurtbox_patch_
        nop
        nop
        _return:
        OS.patch_end()

        lw      t0, 0x0008(s7)              // t0 = character id
        lli     at, Character.id.GOEMON     // at = id.GOEMON

        bne     at, t0, _check_grab         // skip if character != GOEMON
        nop

        // if we're here the character is Goemon
        lw      t0, 0x0024(s7)              // t0 = current action id
        lli     at, Goemon.Action.DSPGround // at = DSPGround
        beq     t0, at, _end                // skip grab check for Goemon DSPGround
        lli     at, Goemon.Action.DSPAir    // at = DSPAir
        beq     t0, at, _end                // skip grab check for Goemon DSPAir
        nop

        _check_grab:
        sll     t0, t8, 18                  // original line 1
        bltzl   t0, _j_0x80170850           // original line 2, modified
        lw      t6, 0x0094(sp)              // original line 3

        _end:
        j       _return                     // return
        nop

        _j_0x80170850:
        j       0x80170850                  // original branch location
        nop
    }
}