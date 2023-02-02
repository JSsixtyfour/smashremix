// ConkerSpecial.asm

// This file contains subroutines used by Conker's special moves.

scope ConkerUSP {

    constant LANDING_FSM(0x3EB33333)            // current setting - float:0.35

    // @ Description
    // Initial Subroutine for Conker's aerial up special, heavily based on Donkey Kongs located at 0x8015B9B8.
    scope air_initial_: {
        addiu   sp, sp, 0xFFE8
        sw      ra, 0x0014(sp)

        lw      v0, 0x0084(a0)
        sw      r0, 0x017C(v0)              // temp variable 1
        sw      r0, 0x0180(v0)              // temp variable 2
        sw      r0, 0x0184(v0)              // temp variable 3
        lui     at, 0x41f0                  // 30
        mtc1    at, f4                      // initial vertical lift loaded, DK's is 0x41A26666
        lui     at, 0x8019
        addiu   a1, r0, 0x0001

        jal     ConkerUSP_part2_
        swc1    f4, 0x004C(v0)              // saving initial lift value

        lw      ra, 0x0014(sp)
        addiu   sp,sp, 0x0018
        jr      ra
        nop

        ConkerUSP_part2_:
        OS.copy_segment(0xD6328, 0x14)

        addiu   a1, r0, 0x00E4              // Conker Up Special Action loaded

        OS.copy_segment(0xD6340, 0x74)
    }

    // @ Description
    // Initial Subroutine for Conker's grounded up special, heavily based on Donkey Kongs located at 0x8015B9B8.
    scope ground_initial_: {
        addiu   sp, sp, 0xFFE8
        sw      ra, 0x0014(sp)

        lw      v0, 0x0084(a0)
        sw      r0, 0x017C(v0)              // temp variable 1
        sw      r0, 0x0180(v0)              // temp variable 2
        sw      r0, 0x0184(v0)              // temp variable 3

        mtc1    r0, f4                      // set initial vertical lift to 0
        lui     at, 0x8019
        addiu   a1, r0, 0x0001

        jal     ConkerUSP_part2_
        swc1    f4, 0x004C(v0)              // saving initial lift value

        lw      ra, 0x0014(sp)
        addiu   sp,sp, 0x0018
        jr      ra
        nop

        ConkerUSP_part2_:
        OS.copy_segment(0xD6328, 0x14)

        addiu   a1, r0, 0x00E3              // Conker Up Special Action loaded

        OS.copy_segment(0xD6340, 0x74)
    }

    // @ Description
    // Main subroutine for Conker's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Piano's landing FSM value and disable the interrupt flag.
    scope main_air: {
        // Copy the first 8 lines of subroutine 0x8015C750
        OS.copy_segment(0xD7190, 0x04)
        sw      a2, 0x0028(sp)
        sw      a0, 0x0020(sp)
        OS.copy_segment(0xD7194, 0x1C)
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra
        lw      t8, 0x0028(sp)              // loads player struct
        lh      t8, 0x01BC(t8)              // loads current button press
        andi    t8, t8, Joypad.B            // t8 = 0x0020 if (B_HELD); else t8 = 0
        beqz    t8, _no_hold                // skip if (!B_HELD)
        addiu   a1, r0, 0x003A
        addiu   a1, r0, 0x00E6
        addiu   a2, r0, 0x0000
        lui     a3, 0x3F80
        jal     0x800E6F24
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830
        lw      a0, 0x0020(sp)              // unknown original subroutine
        beq     r0, r0, _end
        lw      ra, 0x0024(sp)              // restore ra

        _no_hold:
        lw      a0, 0x0020(sp)              // a0 = player object
        lui     a1, 0x3F80                  // a1 (drift multiplier?) = 1.0
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        li      t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        beq     r0, r0, _end
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles the y velocity changes for Conker's grounded up special.
    // Decelerates the current y velocity while temp variable 2 is set.
    scope ground_y_velocity_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      a0, 0x0018(sp)              // store ra, a0


        lw      t0, 0x0180(a0)              // t0 = temp variable 2
        beq     t0, r0, _end                // skip if temp variable 2 = 0
        nop


        lli     at, 0x0001                  // ~
        bne     at, t0, _decelerate         // if temp variable 2 is set to a value other than 1, decelerate
        nop

        _lift_off:
        jal     0x800DEEC8                  // set aerial state
        nop
        lw      a0, 0x0018(sp)              // a0 = player struct
        lui     at, 0x42A0                  // ~
        b       _end                        // end subrotuine
        sw      at, 0x004C(a0)              // set current y velocity to 80

        _decelerate:
        lwc1    f0, 0x004C(a0)              // f0 = current y velocity
        lui     t0, 0x3F70                  // ~
        mtc1    t0, f2                      // f2 = 0.94
        mul.s   f0, f0, f2                  // f0 = y velocity * 0.94
        swc1    f0, 0x004C(a0)              // store updated y velocity

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
     }

    // @ Description
    // Subroutine for Conker's aerial up special, heavily based on Donkey Kongs located at 0x8015B780.
    scope air_physics_: {
        // 0x17C in player struct = temp variable 1
        addiu   sp, sp, 0xFFE0
        sw      ra, 0x001C(sp)               // allocate stack space
        sw      s0, 0x0018(sp)
        sw      a0, 0x0004(sp)
        sw      a1, 0x0008(sp)

        lw      s0, 0x0084(a0)            // load player struct
        lw      t6, 0x017C(s0)              // load 54 command
        lw      v0, 0x09C8(s0)
        beq     t6, r0, load_lift           // this branch determines if vertical lift should be applied based on a flag in the moveset data
        nop

        lui     at, 0x3F80
        mtc1    at, f0                      // sets multiplier to one, ie. no change
        beq     r0, r0, apply_lift
        lwc1    f4, 0x0058(v0)              // loads fall speed acceleration

        load_lift:
        lui     at, 0x3D8F
        addiu   at, 0x5D00                  // sets multiplier to hard coded number used by link and DK
        mtc1    at, f0
        lwc1    f4, 0x0058(v0)              // loads fall speed acceleration

        apply_lift:
        or      a0, s0, r0                  // place player struct in a0
        lw      a2, 0x005C(v0)              // loads max fall speed, which will be the cap on vertical speed
        mul.s   f6, f4, f0
        mfc1    a1, f6                      // will be used as multiplier for vertical height calculation
        jal     0x800D8D68                  // Shared subroutine that determines vertical lift amount
        nop

        li      a2, 0x3D3751EC              // horizontal speed multiplier placed into a2, DK's is 3D4CCCCD
        or      a0, s0, r0                  // player struct put into a0
        or      a1, r0, r0                  // a1 cleard out
        jal     0x800D8FC8                  // horizontal speed set based on a2 and a3
        lui     a3, 0x4248                  // cap on horizontal speed

        _end:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }

    // @ Description
    // Subroutine for Conker's aerial up special descent.
    scope descent_main_air: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x0024(sp)

        lw      v0, 0x0084(a0)              // load player struct
        lh      t6, 0x01BC(v0)              // loads current button press
        andi    t6, t6, Joypad.B            // t8 = 0x0020 if (B_HELD); else t8 = 0
        bnez    t6, _end                    // skip if (!B_HELD)
        nop
        lui     a1, 0x3F80                  // a1 (drift multiplier?) = 1.0
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        li      t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

        _end:
        lw      ra, 0x0024(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // Subroutine for Conker's aerial up special, heavily based on Donkey Kongs located at 0x8015B780.
    scope descent_air_physics_2: {
        // 0x17C in player struct = temp variable 1
        addiu   sp, sp, 0xFFE0
        sw      ra, 0x001C(sp)            // allocate stack space
        sw      s0, 0x0018(sp)
        sw      a0, 0x0004(sp)
        sw      a1, 0x0008(sp)


        lw      s0, 0x0084(a0)            // load player struct
        lw      v0, 0x09C8(s0)

        load_lift:
        lui     at, 0x3e80
        addiu   at, 0x0000                // sets multiplier to which determines how fast character will rise or fall
        mtc1    at, f0
        lwc1    f4, 0x0058(v0)            // loads fall speed acceleration

        apply_lift:
        or      a0, s0, r0                // place player struct in a0
        lw      a2, 0x005C(v0)            // loads max fall speed, which will be the cap on vertical speed
        mul.s   f6, f4, f0
        mfc1    a1, f6                    // will be used as multiplier for vertical height calculation
        jal     0x800D8D68                // Shared subroutine that determines vertical lift amount
        nop

        li      a2, 0x3D23D70A            // horizontal speed multiplier placed into a2, DK's is 3D4CCCCD
        or      a0, s0, r0                // player struct put into a0
        or      a1, r0, r0                // a1 cleard out
        jal     0x800D8FC8                // horizontal speed set based on a2 and a3
        lui     a3, 0x4200                // cap on horizontal speed
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }

    // @ Description
    // Subroutine for Conker's aerial up special loop, based on the up special part 1 of Fox's up special, minus a slowdown on horizontal momentum
    scope descent_air_physics_: {
        OS.copy_segment(0xD6788, 0x60)
        lw      a1, 0x0018(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020
        jr      ra
        nop
    }
}

scope ConkerNSP {
    // @ Description
    // Subroutine which runs when Conker initiates a grounded neutral special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Ground_Begin

        lli     a1, Conker.Action.NSP_Ground_Begin // a1(action id) = NSP_Ground_Begin
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
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Conker initiates an aerial neutral special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Air_Begin

        lli     a1, Conker.Action.NSP_Air_Begin // a1(action id) = NSP_Air_Begin
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
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Conker's grounded neutral special wait action.
    scope ground_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Ground_Wait
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Ground_Wait

        lli     a1, Conker.Action.NSP_Ground_Wait // a1(action id) = NSP_Ground_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Conker's aerial neutral special wait action.
    scope air_wait_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Air_Wait
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Air_Wait

        lli     a1, Conker.Action.NSP_Air_Wait // a1(action id) = NSP_Air_Wait
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which begins Conker's grounded neutral special ending action.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Ground_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Ground_End

        lli     a1, Conker.Action.NSP_Ground_End // a1(action id) = NSP_Ground_End
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
    // Subroutine which begins Conker's aerial neural special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Air_End
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.CONKER_NSP_Air_End

        lli     a1, Conker.Action.NSP_Air_End // a1(action id) = NSP_Ground_End
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
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
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
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lh      t7, 0x01BC(v0)              // t7 = buttons_held
        andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t7, _end                    // branch if (B_HELD)
        nop

        // if we reach this point, the b button is not being held, so transition to ending action
        jal     ground_end_initial_         // transition to NSP_Ground_End
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for NSP_Air_Wait
    scope air_wait_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        lh      t7, 0x01BC(v0)              // t7 = buttons_held
        andi    t7, t7, Joypad.B            // t7 = 0x0020 if (B_HELD); else t7 = 0
        bnez    t7, _end                    // branch if (B_HELD)
        nop

        // if we reach this point, the b button is not being held, so transition to ending action
        jal     air_end_initial_            // transition to NSP_Air_End
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
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
        lw      a0, 0x092C(v0)              // a0 = part 0xD (weapon) struct
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct
        lwc1    f6, 0x0024(sp)              // f6 = y coordinate
        lui     t6, 0x4270                  // ~
        mtc1    t6, f8                      // f6 = 60
        add.s   f6, f6, f8                  // add 60 to y coordinate
        swc1    f6, 0x0024(sp)              // store updated y coordinate
        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     nut_stage_setting_          // INITIATE NUT
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
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which handles ground collision for neutral special actions
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
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
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air collision for neutral special end
    scope air_collision_end_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      t9, 0x0078(a0)              // t9(starting frame) = current animation frame
        lui     t8, 0x40c0                  // insert amount of frames before conker fires (6)
        mtc1    t9, f2                      // move to floating point
        mtc1    t8, f4                      // move to floating point
        c.lt.s  f2, f4                      // compare current frame to see if equal or greater than (6)
        bc1fl   _fired                      // branch to collision process for NSP after firing
        nop
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        b       _end                        // end subroutine
        nop

        _fired:
       jal      0x800DE99C                  // air collision subroutine (cancel on landing)
       nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
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
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   a1, t7, 0x0003              // a1 = equivalent air action for current ground action (id + 3)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
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
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   a1, t7,-0x0003              // a1 = equivalent ground action for current air action (id - 3)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0800                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0800 (this flag continues FGM called with the 3C command)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    // TODO: this is still largely uncommented, and may contain leftover logic that isn't needed.
    scope nut_stage_setting_: {
        constant MAX_POWER(4)
        addiu   sp, sp, -0x0050
        sw      s0, 0x0018(sp)
        li      s0, nut_properties_struct   // s0 = projectile properties struct address
        sw      a1, 0x0034(sp)
        sw      ra, 0x001C(sp)
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, nut_projectile_struct   // a1 = main projectile struct address
        lw      a2, 0x0034(sp)
        lui     a3, 0x8000
        sw      t6, 0x002C(sp)              // 0x002C(sp) = player struct
        jal     0x801655C8                  // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)

        beq     v0, r0, _end_stage_setting  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        _projectile_branch:
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile struct
        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(v1)              // store duration
        lw      t4, 0x002C(sp)              // t4 = player struct
        lw      t5, 0x014C(t4)              // t5 = kinetic state
        beq     t5, r0, _power_adjustments  // branch if kinetic state = grounded
        lwc1    f12, 0x0018(s0)             // f12 = initial angle (ground)
        lwc1    f12, 0x001C(s0)             // f12 = initial angle (air)

        _power_adjustments:
        // calculate power level, check if max power has been reached, and store power level in the projectile struct
        lw      t6, 0x002C(sp)              // t6 = player struct
        lw      t6, 0x0184(t6)              // t6 = temp variable 3/power level (int)
        mtc1    t6, f8                      // ~
        cvt.s.w f8, f8                      // f8 = power level (float)
        swc1    f8, 0x01B4(v1)              // 0x01B4 in projectile struct = power level (float)
        lli     t5, MAX_POWER - 1           // ~
        sltu    t5, t5, t6                  // t5 = 1 if power level > MAX_POWER, else t5 = 0

        _fgm:
        // play an FGM, changes with power level
        beqz    t6, _play_fgm               // branch if power level = 0...
        lli     a0, 0x0104                  // ..and load FGM id 0x104
        // if power level is above 0
        beqz    t5, _play_fgm               // branch if bool max_power = FALSE
        lli     a0, 0x0103                  // ..and load FGM id 0x103
        // if power level is above 0 and max_power = TRUE
        lli     a0, 0x0102                  // load FGM id 0x102

        _play_fgm:
        jal     FGM.play_                   // play FGM
        nop

        _hitbox:
        // adjust hitbox properties based on power level
        // t6 = power level (int), t5 = bool max_power
        lw      t7, 0x0104(v1)              // t7 = current hitbox damage
        sll     t8, t6, 0x1                 // t8 = power level * 2
        addu    t7, t7, t8                  // t7 = hitbox damage + (power level * 2)
        sw      t7, 0x0104(v1)              // add 2 damage per power level
        lw      t7, 0x0130(v1)              // t7 = current hitbox kbg
        sll     t8, t6, 0x2                 // ~
        subu    t8, t8, t6                  // ~
        sll     t8, t8, 0x2                 // t8 = power level * 12
        addu    t7, t7, t8                  // t7 = hitbox kbg + (power level * 12)
        sw      t7, 0x0130(v1)              // add 16 kbg per power level
        lw      t7, 0x0138(v1)              // t7 = current hitbox bkb
        sll     t8, t6, 0x2                 // t8 = power level * 4
        addu    t7, t7, t8                  // t7 = hitbox bkb + (power level * 4)
        sw      t7, 0x0138(v1)              // add 4 bkb per power level
        beqz    t5, _speed                  // branch if bool max_power = FALSE
        lli     t7, 0x001F                  // t7 = 0x1F
        // if bool max_power = TRUE
        sh      t7, 0x0146(v1)              // set on-hit FGM to 0x1F

        _speed:
        // adjust speed based on power level
        // f8 = power level (float)
        lui     t6, 0x4140                  // ~
        mtc1    t6, f6                      // f6 = 12
        mul.s   f6, f6, f8                  // f6 = bonus speed (power level * 12)
        swc1    f6, 0x0048(sp)              // 0x0048(sp) = bonus speed

        _angle:
        // adjust angle based on power level
        li      t6, 0x3C0EFA39              // ~
        mtc1    t6, f6                      // f6 = 0.00872665 rads (.5 degrees)
        mul.s   f6, f6, f8                  // f6 = angle adjustment (.5 degrees per power level)
        sub.s   f12, f12, f6                // f12 = adjusted angle (initial angle - adjustment)

        mtc1    r0, f4                      // f4 = 0
        swc1    f4, 0x0028(v1)              // set z speed? to 0
        swc1    f12, 0x0020(sp)             // 0x0020(sp) = adjusted angle
        jal     0x80035CD0                  // ~
        sw      v1, 0x0024(sp)              // original logic

        // add bonus speed
        lwc1    f6, 0x0020(s0)              // f6 = initial projectile speed
        lwc1    f8, 0x0048(sp)              // f8 = bonus speed
        add.s   f6, f6, f8                  // f6 = initial speed + bonus speed

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

        // add bonus speed
        lwc1    f4, 0x0020(s0)              // f4 = initial projectile speed
        lwc1    f6, 0x0048(sp)              // f6 = bonus speed
        add.s   f4, f4, f6                  // f4 = initial speed + bonus speed

        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        mul.s   f6, f0, f4                  // ~
        swc1    f6, 0x0024(v1)              // ~
        lw      t8, 0x0074(a0)              // ~
        lwc1    f10, 0x002C(s0)             // ~
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
    // Main subroutine for the nut.
    scope nut_main_: {
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

        _continue:
        li      v0, nut_properties_struct   // v0 = nut_properties_struct
        lw      a1, 0x000C(v0)              // a1 = gravity
        jal     0x80168088                  // apply gravity to nut
        lw      a2, 0x0004(v0)              // a2 = max speed
        lw      a0, 0x001C(sp)              // a0 = projectile struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile struct with coordinates/rotation etc (bone struct?)
        li      at, nut_properties_struct   // at = nut properties struct
        lwc1    f6, 0x0014(at)              // f6 = rotation speed
        lwc1    f4, 0x01B4(a0)              // f4 = power level
        lui     t6, 0x3F00                  // ~
        mtc1    t6, f8                      // f8 = 0.5
        mul.s   f4, f4, f8                  // f4 = power level * 0.5
        lui     t6, 0x3F80                  // ~
        mtc1    t6, f8                      // f8 = 1
        add.s   f4, f4, f8                  // f4 = 1 + (power level * 0.5)
        mul.s   f6, f6, f4                  // increase rotation speed by 50% per power level
        lwc1    f4, 0x0030(v1)              // f4 = current rotation
        add.s   f8, f4, f6                  // add rotation speed to current rotation
        swc1    f8, 0x0030(v1)              // update rotation
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This subroutine destroys the nut and creates a smoke gfx.
    scope nut_destruction_: {
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

    OS.align(16)
    nut_projectile_struct:
    constant NUT_ID(0x1001)
    dw 0x00000000                           // unknown
    dw NUT_ID                               // projectile id
    dw Character.CONKER_file_6_ptr          // address of conker's file 6 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
    dw nut_main_                            // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0x80175914                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw nut_destruction_                     // This function runs when the projectile collides with a hurtbox.
    dw nut_destruction_                     // This function runs when the projectile collides with a shield.
    dw 0x801686F8                           // This function runs when the projectile collides with edges of a shield and bounces off
    dw nut_destruction_                     // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x801692C4                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw nut_destruction_                     // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    nut_properties_struct:
    dw 30                                   // 0x0000 - duration (int)
    float32 120                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 1.2                             // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.1                             // 0x0014 - rotation speed
    float32 0.174533                        // 0x0018 - initial angle (ground)
    float32 0.174533                        // 0x001C   initial angle (air)
    float32 60                              // 0x0020   initial speed
    dw Character.CONKER_file_6_ptr          // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)
}

scope ConkerDSP {

    // @ Description
    // initial routine for Conker's Grenade
    scope initial_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        lw      v0, 0x0084(a0)
        addiu   t7, r0, 0x0014
        sw      t7, 0x0B20(v0)          // save 14 to free space in character struct, this is used as a power level of throw
        sw      r0, 0x0B28(v0)
        lw      t7, 0x0ADC(v0)
        addiu   a1, r0, 0x00EC          // place in grenade available action
        addiu   a2, r0, 0x0000
        beq     t7, r0, _grenade_available      // branch if theres an active grenade
        nop

        addiu   a1, r0, 0x00EF          // place in grenade unavailable command
        addiu   a2, r0, 0x0000

        _grenade_available:
        lui     a3, 0x3F80
        sw      r0, 0x0010(sp)
        sw      v0, 0x0024(sp)
        jal     0x800E6F24
        sw      a0, 0x0028(sp)
        lw      v0, 0x0024(sp)
        lbu     t9, 0x0192(v0)
        ori     t0, t9, 0x0080

        beq     r0, r0, branch_1
        sb      t0, 0x0192(v0)
        lui     a3, 0x3F80
        sw      r0, 0x0010(sp)
        jal     0x800E6F24
        sw      a0, 0x0028(sp)

        branch_1:
        jal     0x800E0830
        lw      a0, 0x0028(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // main subroutine for first action of DSP, its job is to determine joystick and and transition to another move based on this
    scope air_initial_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        lw      v0, 0x0084(a0)
        addiu   t7, r0, 0x0014
        sw      t7, 0x0B20(v0)          // save 14 to free space in character struct, this is used as a power level of throw
        sw      r0, 0x0B28(v0)
        lw      t7, 0x0ADC(v0)
        addiu   a1, r0, 0x00F1          // place in grenade available action
        addiu   a2, r0, 0x0000
        beq     t7, r0, _grenade_available      // branch if theres an active grenade
        nop

        addiu   a1, r0, 0x00F5          // place in grenade unavailable command
        addiu   a2, r0, 0x0000

        _grenade_available:
        lui     a3, 0x3F80
        sw      r0, 0x0010(sp)
        sw      v0, 0x0024(sp)
        jal     0x800E6F24
        sw      a0, 0x0028(sp)
        lw      v0, 0x0024(sp)
        lbu     t9, 0x0192(v0)
        ori     t0, t9, 0x0080

        beq     r0, r0, branch_1
        sb      t0, 0x0192(v0)
        lui     a3, 0x3F80
        sw      r0, 0x0010(sp)
        jal     0x800E6F24
        sw      a0, 0x0028(sp)

        branch_1:
        jal     0x800E0830
        lw      a0, 0x0028(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // main subroutine for Conker's Grenade based on Mario's fireball coding
    scope main: {
        addiu   sp, sp, -0x0080
        sw      ra, 0x0014(sp)
        swc1    f6, 0x003C(sp)
        swc1    f8, 0x0038(sp)
        sw      a0, 0x0034(sp)                      // 0x0034(sp) = player object
        lw      v0, 0x0084(a0)                      // loads player struct
        addiu   t6, r0, r0                          // clear register
        lw      t6, 0x0B28(v0)                      // load from frame counter/character free space
        addiu   t8, t6, 0x0001                      // add a frame
        sw      t8, 0x0B28(v0)                      // save new frame amount
        slti    at, t6, 0x0003
        bnez    at, _no_hold
        addu    a2, a0, r0
        lh      t6, 0x01BC(v0)                      // loads current button press
        andi    t6, t6, Joypad.B                    // t6 = 0x0020 if (B_HELD); else t8 = 0
        beqz    t6, _no_hold                        // skip if (!B_HELD)

        lw      t6, 0x0B20(v0)                      // loads free space / current power
        addiu   t6, t6, 0x0005                      // adds 5 to speed
        sw      t6, 0x0B20(v0)                      // saves previous speed +10

        _no_hold:
        or      a3, a0, r0
        lw      t6, 0x017C(v0)
        beql    t6, r0, _idle_transition_check      // this checks moveset variables to see if projectile should be spawned
        lw      ra, 0x0014(sp)
        mtc1    r0, f0



        sw      r0, 0x017C(v0)                      // reset temp variable 1
        sw      r0, 0x0040(sp)                      // ~
        sw      r0, 0x0044(sp)                      // ~
        sw      r0, 0x0048(sp)                      // unknown x/y/z offset?
        addiu   a1, sp, 0x0020
        swc1    f0, 0x0020(sp)                      // x offset
        swc1    f0, 0x0024(sp)                      // y offset
        swc1    f0, 0x0028(sp)                      // z offset
        lw      a0, 0x0928(v0)                      // a0 = part 0xC (right hand) struct
        sw      a3, 0x0030(sp)
        jal     0x800EDF24                          // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)
        li      at, 0x80000002                      // ~
        sw      at, 0x0010(sp)                      // unknown argument = 0x80000002
        lw      a0, 0x0034(sp)                      // a0 = player object
        li      a1, grenade_item_info_array         // a1 = grenade_item_info_array

        addiu   a2, sp, 0x0020                      // a2 = x/y/z coordinates
        jal     grenade_stage_setting_              // create grenade
        addiu   a3, sp, 0x0040                      // a3 = unknown x/y/z offset

        // checks frame counter to see if reached end of the move
        _idle_transition_check:
        lw      a2, 0x0034(sp)
        mtc1    r0, f6
        lwc1    f8, 0x0078(a2)
        c.le.s  f8, f6
        nop
        bc1fl   _end
        lw      ra, 0x0014(sp)
        lw      a2, 0x0034(sp)
        jal     0x800DEE54
        or      a0, a2, r0

        _end:
        lw      a0, 0x0034(sp)
        lwc1    f6, 0x003C(sp)
        lwc1    f8, 0x0038(sp)
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0080
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which sets up initial properties of grenade.
    // a0 - player object
    // a1 - item info array
    // a2 - x/y/z coordinates to create item at
    // a3 - unknown x/y/z offset
    scope grenade_stage_setting_: {
        addiu   sp, sp,-0x0060                  // allocate stack space
        sw      s0, 0x0020(sp)                  // ~
        sw      s1, 0x0024(sp)                  // ~
        sw      ra, 0x0028(sp)                  // store s0, s1, ra
        sw      a0, 0x0038(sp)                  // 0x0038(sp) = player object
        sw      a2, 0x003C(sp)                  // 0x003C(sp) = original x/y/z
        jal     0x8016E174                      // create item
        sw      r0, 0x0010(sp)                  // argument 4(unknown) = 0
        beqz    v0, _end                        // end if no item was created
        or      s0, v0, r0                      // s0 = item object
        li      s1, grenade_attributes.struct   // s1 = grenade_attributes.struct

        // item is created
        sw      v0, 0x0040(sp)                  // 0x0040(sp) = item object
        lw      v1, 0x0084(v0)                  // v1 = item special struct
        sw      v1, 0x002C(sp)                  // 0x002C(sp) = item special struct
        lw      a0, 0x0074(v0)                  // a0 = item first joint (joint 0)
        sw      a0, 0x0030(sp)                  // 0x0030(sp) = item joint 0
        lli     a1, 0x002E                      // a1(render routine?) = 0x2E
        jal     0x80008CC0                      // set up render routine?
        or      a2, r0, r0                      // a2 (unknown) = 0
        lw      a0, 0x0030(sp)                  // ~
        lw      a0, 0x0010(a0)                  // a0 = item second joint (joint 1)
        lli     a1, 0x002E                      // a1(render routine?) = 0x2E
        jal     0x80008CC0                      // set up render routine?
        or      a2, r0, r0                      // a2 (unknown) = 0

        lw      v1, 0x002C(sp)                  // v1 = item special struct
        lbu     t9, 0x0158(v1)                  // ~
        ori     t9, t9, 0x0010                  // ~
        sb      t9, 0x0158(v1)                  // enable unknown bitflag
        lw      t6, grenade_attributes.DURATION(s1)  // t6 = duration
        sw      t6, 0x02C0(v1)                  // store duration
        lli     t7, 0x0004                      // ~
        sw      t7, 0x0354(v1)                  // unknown value(bit field?) = 0x00000004

        lwc1    f12, grenade_attributes.ANGLE(s1) // f12 = ANGLE
        // ultra64 cosf function
        jal     0x80035CD0                      // f0 = cos(ANGLE)
        swc1    f12, 0x0050(sp)                 // 0x0050(sp) = ANGLE
        lw      t6, 0x0038(sp)                  // ~
        lw      t6, 0x0084(t6)                  // t6 = player struct
        lwc1    f10, 0x0044(t6)                 // ~
        cvt.s.w f10, f10                        // f10 = DIRECTION
        lwc1    f6, 0x0B20(t6)                  // ~
        cvt.s.w f6, f6                          // f6 = SPEED
        mul.s   f8, f6, f0                      // ~
        mul.s   f12, f8, f10                    // f12 = x velocity ((SPEED * cos(ANGLE)) * DIRECTION)
        lw      v1, 0x002C(sp)                  // v1 = item special struct
        swc1    f12, 0x002C(v1)                 // store x velocity
        // ultra64 sinf function
        jal     0x800303F0                      // f0 = sin(ANGLE)
        lwc1    f12, 0x0050(sp)                 // f12 = ANGLE
        lw      a0, 0x0038(sp)                  // a0 = player object
        lw      v1, 0x002C(sp)                  // v1 = item special struct
        sw      a0, 0x0008(v1)                  // set player as projectile owner
        lw      t6, 0x0084(a0)                  // t6 = player struct
        lbu     at, 0x000C(t6)                  // load player team
        sb      at, 0x0014(v1)                  // save player's team to item to prevent damage when team attack is off
        lbu     at, 0x000D(t6)                  // at = player port
        sb      at, 0x0015(v1)                  // store player port for combo ownership
        sw      v1, 0x0ADC(t6)                  // save object address to free space in player struct
        sw      t6, 0x01C4(v1)                  // save player struct to custom variable space in the item special struct

        lwc1    f6, 0x0B20(t6)                  // ~
        cvt.s.w f6, f6                          // f6 = SPEED
        mul.s   f8, f6, f0                      // f8 = y velocity (SPEED * cos(ANGLE))
        swc1    f8, 0x0030(v1)                  // store y velocity
        sw      r0, 0x0034(v1)                  // z velocity = 0
        lli     at, 0x0001                      // ~
        sw      at, 0x0248(v1)                  // enable hurtbox
        sw      at, 0x010C(v1)                  // enable hitbox
        lhu     at, 0x02CE(v1)                  // ~
        ori     at, at, 0x0080                  // ~
        sh      at, 0x02CE(v1)                  // enable bitflag which allows owner's hitboxes to collide with the hurtbox

        li      t0, grenade_attributes.struct   // t0 = grenade_attributes.struct
        lw      t1, grenade_attributes.MAX_SPEED(t0)    // t1 = MAX_SPEED
        sw      t1, 0x01C8(v1)                  // max speed = MAX_SPEED
        sw      r0, 0x01CC(v1)                  // rotation direction = 0
        sw      r0, 0x01D0(v1)                  // hitbox refresh timer = 0
        sw      r0, 0x01D4(v1)                  // hitbox collision flag = FALSE
        li      t1, grenade_blast_zone_         // load grenade blast zone routine
        sw      t1, 0x0398(v1)                  // save routine to part of item special struct that carries unique blast wall destruction routines

		sw      r0, 0x0100(v1)                  // remove possible reference to character ID use by Bomb

        lw      a1, 0x0038(sp)					// ~
        lw      a1, 0x0084(a1)                  // ~
        addiu   a2, a1, 0x0078                  // a2 = unknown
        lw      a1, 0x0078(a1)                  // a1 = player x/y/z coordinates
        jal     0x800DF058                      // check clipping
        lw      a0, 0x0040(sp)                  // a0 = item object

        _end:
        or      v0, s0, r0                      // v0 = item object
        lw      s0, 0x0020(sp)                  // ~
        lw      s1, 0x0024(sp)                  // ~
        lw      ra, 0x0028(sp)                  // load s0, s1, ra
        jr      ra                              // return
        addiu   sp, sp, 0x0060                  // deallocate stack space
    }

    // @ Description
    // Main subroutine for the grenade.
    // a0 = item object
    scope grenade_main_: {
        addiu   sp, sp,-0x0040                  // allocate stack space
        sw      s0, 0x0014(sp)                  // ~
        sw      s1, 0x0018(sp)                  // ~
        sw      s2, 0x001C(sp)                  // ~
        sw      ra, 0x0030(sp)                  // store ra, s0-s2

        lw      s0, 0x0084(a0)                  // s0 = item special struct
        or      s1, a0, r0                      // s1 = item object
        li      s2, grenade_attributes.struct   // s2 = grenade_attributes.struct
        lw      at, 0x0108(s0)                  // at = kinetic state
        beq     at, r0, _update_speed_ground    // branch if kinetic state = grounded
        nop

        _update_speed_air:
        lui     at, 0x3F80                      // ~
        mtc1    at, f2                          // f2 = 1.0
        lwc1    f4, grenade_attributes.MAX_SPEED(s2)    // f4 = MAX_SPEED
        lwc1    f6, 0x01C8(s0)                  // f6 = current max speed
        sub.s   f6, f6, f2                      // f6 = current max speed - 1.0
        c.le.s  f6, f4                          // ~
        nop                                     // ~
        bc1f    _apply_speed_air                // branch if MAX_SPEED =< updated max speed
        swc1    f6, 0x01C8(s0)                  // update current max speed
        // if updated max speed is below MAX_SPEED
        swc1    f4, 0x01C8(s0)                  // current max speed = MAX_SPEED

        _apply_speed_air:
        lw      a1, grenade_attributes.GRAVITY(s2)      // a1 = GRAVITY
        lw      a2, 0x01C8(s0)                  // a2 = current max speed
        jal     0x80172558                      // apply gravity/max speed
        or      a0, s0, r0                      // a0 = item special struct
        b       _check_duration                 // branch
        nop

        _update_speed_ground:
        lwc1    f0, 0x002C(s0)                  // f0 = x speed
        lui     t0, 0x3F70                      // ~
        mtc1    t0, f2                          // f2 = 0.875
        mul.s   f0, f0, f2                      // f0 = x speed * 0.875
        swc1    f0, 0x002C(s0)                  // update x speed
        abs.s   f0, f0                          // f0 = absolute x speed
        lui     t0, 0x4000                      // ~
        mtc1    t0, f2                          // f2 = minimum x speed
        c.lt.s  f0, f2                          // ~
        nop                                     // ~
        bc1fl   _check_duration                 // branch if abs x speed > minimum x speed
        nop
        sw      r0, 0x002C(s0)                  // x speed = 0
        sw      r0, 0x010C(s0)                  // disable hitbox

        _check_duration:
        lw      v0, 0x02C0(s0)                  // v0 = remaining duration
        bnezl   v0, _update_duration            // branch if duration has not ended
        nop
        jal     grenade_explosion_              // begin explosion
        or      a0, s1, r0                      // a0 = item special struct
        b       _end                            // end
        nop

        _update_duration:
        addiu   t7, v0,-0x0001                  // t7 = decremented duration
        sw      t7, 0x02C0(s0)                  // store updated duration

        _update_rotation_direction:
        lw      t0, 0x002C(s0)                  // t0 = current x speed
        beqz    t0, _update_rotation_speed      // branch if x speed is 0
        lwc1    f12, 0x01CC(s0)                 // f12 = rotation direction

        // if the grenade's x speed isn't 0, update the rotation direction
        lwc1    f12, 0x002C(s0)                 // ~
        abs.s   f10, f12                        // ~
        div.s   f12, f12, f10                   // f12 = rotation direction
        swc1    f12, 0x01CC(s0)                 // update rotation direction


        _update_rotation_speed:
        // f12 = rotation direction
        lwc1    f8, 0x002C(s0)                  // f8 = current x speed
        lwc1    f6, 0x0030(s0)                  // f6 = current y speed
        mul.s   f8, f8, f8                      // f8 = x speed squared
        mul.s   f6, f6, f6                      // f6 = y speed squared
        add.s   f8, f8, f6                      // f8 = x speed squared + y speed squared
        sqrt.s  f10, f8                         // f10 = absolute speed
        lwc1    f6, grenade_attributes.ROTATION(s2) // f6 = default rotation speed
        mul.s   f6, f6, f10                     // f6 = default rotation speed * absolute speed
        lui     t1, 0x3C90                      // ~
        mtc1    t1, f8                          // ~
        add.s   f8, f8, f6                      // f8 = calculated rotation speed + base rotation of 0.086
        mul.s   f8, f8, f12                     // f8(rotation speed) = calculated rotation * direction
        mfc1    at, f10                         // at = absolute speed
        bnez    at, _apply_rotation             // branch if absolute speed = 0
        nop

        // if we're here, absolute speed is 0
        mtc1    r0, f8                          // f8(rotation speed) = 0

        _apply_rotation:
        lw      v0, 0x0074(s1)                  // v0 = item first joint struct
        lwc1    f6, 0x0038(v0)                  // f6 = current x rotation
        sub.s   f6, f6, f8                      // update x rotation
        swc1    f6, 0x0038(v0)                  // store updated x rotation

        _hitbox_timer:
        // refresh the hitbox when the hitbox refresh timer is used
        lw      t0, 0x01D0(s0)                  // t0 = hitbox refresh timer
        beqz    t0, _speed_refresh              // branch if hitbox refresh timer = 0
        nop
        // if the timer is not 0
        addiu   t0, t0,-0x0001                  // subtract 1 from the timer
        bnez    t0, _calculate_damage           // branch if the timer is still not 0
        sw      t0, 0x01D0(s0)                  // update the timer
        // if the timer just reached 0
        sw      r0, 0x0224(s0)                  // reset hit object pointer 1
        sw      r0, 0x022C(s0)                  // reset hit object pointer 2
        sw      r0, 0x0234(s0)                  // reset hit object pointer 3
        sw      r0, 0x023C(s0)                  // reset hit object pointer 4

        _speed_refresh:
        // refresh the hitbox when the refresh timer is unused and the grenade passes a certain speed threshold
        lui     t0, 0x420C                      // ~
        mtc1    t0, f4                          // f4 = 35
        c.le.s  f4, f10                         // ~
        nop                                     // ~
        bc1f    _calculate_damage               // branch if absolute speed =< 35
        nop
        // if absolute speed > 20
        sw      r0, 0x0224(s0)                  // reset hit object pointer 1
        sw      r0, 0x022C(s0)                  // reset hit object pointer 2
        sw      r0, 0x0234(s0)                  // reset hit object pointer 3
        sw      r0, 0x023C(s0)                  // reset hit object pointer 4

        _calculate_damage:
        lui     t1, 0x3D90                      // ~
        mtc1    t1, f4                          // ~
        mul.s   f4, f4, f10                     // ~
        trunc.w.s f4, f4                        // ~
        mfc1    t1, f4                          // t1 = absolute speed * 0.07 (rounding down to nearest int)
        addiu   t1, t1, 0x0001                  // add 1 base damage
        sw      t1, 0x0110(s0)                  // update projectile damage
        sll     t1, t1, 0x3                     // t1 = damage * 8
        addiu   t1, t1, 000010                  // add 10 base knockback
        sw      t1, 0x0148(s0)                  // set hitbox bkb to (damage * 8) + 10

        _do_smoke:
        // when the grenade is close to exploding, it will begin start to smoke
        lw      t0, 0x02C0(s0)                  // t0 = current duration
        sltiu   t1, t0, 50                      // if current duration is above 50 frames...
        beqz    t1, _end                        // ...then branch to end
        nop

        // check to see if a smoke particle should be created on this frame
        andi    t0, t0, 0x0007                  // t0 = duration % 8
        bnez    t0, _end                        // branch if duration % 8 != 0
        nop

        // create a smoke particle every 8 frames
        lw      a0, 0x0074(s1)                  // a0 = item first joint struct
        lwc1    f12, 0x0038(a0)                 // f12 = grenade rotation angle
        neg.s   f12, f12                        // f12 = theta
        jal     0x80035CD0                      // f0 = cos(theta)
        swc1    f12, 0x0004(sp)                 // save 0x0050(sp) = theta

        swc1    f0, 0x0008(sp)                  // save cos(theta)
        jal     0x800303F0                      // f0 = sin(ANGLE)
        lwc1    f12, 0x0004(sp)                 // f12 = ANGLE

        lwc1    f2, 0x0008(sp)                  // f2 = cos(theta)

        // x' = x * cos(theta) + y * sin(theta)
        // y' = -x * sin(theta) + y * cos(theta)

        lw      at, 0x0010(a0)                  // at = item 2nd joint
        lwc1    f4, 0x001C(at)                  // f4 = grenade pin x
        lwc1    f6, 0x0020(at)                  // f6 = grenade pin y

        mul.s   f8, f4, f2                      // f8 = x * cos(theta)
        mul.s   f10, f6, f0                     // f10 = y * sin(theta)
        mul.s   f12, f4, f0                     // f12 = x * sin(theta)
        mul.s   f14, f6, f2                     // f14 = y * cos(theta)

        add.s   f16, f8, f10                    // f16 = x'
        sub.s   f18, f14, f12                   // f18 = y'

        lwc1    f0, 0x001C(a0)                  // f0 = grenade x
        lwc1    f2, 0x0020(a0)                  // f2 = grenade y
        lwc1    f4, 0x0024(a0)                  // f4 = grenade z

        add.s   f0, f0, f16                     // f0 = grenade pin abs x
        add.s   f2, f2, f18                     // f2 = grenade pin abs y

        swc1    f0, 0x0004(sp)                  // save abs x
        swc1    f2, 0x0008(sp)                  // save abs y
        swc1    f4, 0x000C(sp)                  // save abs z

        jal     0x800FE9B4                      // create smoke gfx
        addiu   a0, sp, 0x0004                  // a0 = grenade pin abs x/y/z

        _end:
        sw      r0, 0x01D4(s0)                  // hitbox collision flag = FALSE
        lw      s0, 0x0014(sp)                  // ~
        lw      s1, 0x0018(sp)                  // ~
        lw      s2, 0x001C(sp)                  // ~
        lw      ra, 0x0030(sp)                  // store ra, s0-s2
        addiu   sp, sp, 0x0040                  // deallocate stack space
        jr      ra                              // return
        or      v0, r0, r0                      // v0 = 0
    }

    // @ Description
    // Collision subroutine for the grenade.
    // a0 = item object
    scope grenade_collision_: {
        addiu   sp, sp,-0x0058                  // allocate stack space
        sw      ra, 0x0014(sp)                  // ~
        sw      s0, 0x0040(sp)                  // ~
        sw      s1, 0x0044(sp)                  // store ra, s0, s1
        or      s0, a0, r0                      // s0 = item object
        li      s1, grenade_attributes.struct   // s1 = grenade_attributes.struct

        lw      a0, 0x0084(s0)                  // ~
        addiu   a0, a0, 0x0038                  // a0 = x/y/z position
        li      a1, grenade_detect_collision_   // a1 = grenade_detect_collision_
        or      a2, s0, r0                      // a2 = item object
        jal     0x800DA034                      // collision detection
        ori     a3, r0, 0x0C21                  // bitmask (all collision types)
        sw      v0, 0x0028(sp)                  // store collision result
        or      a0, s0, r0                      // a0 = item object
        ori     a1, r0, 0x0C21                  // bitmask (all collision types)
        lw      a2, grenade_attributes.BOUNCE(s1) // a2 = bounce multiplier
        jal     0x801737EC                      // apply collsion/bounce?
        or      a3, r0, r0                      // a3 = 0

        lw      t0, 0x0028(sp)                  // t0 = collision result
        beqz    t0, _end                        // branch if collision result = FALSE
        lw      t8, 0x0084(s0)                  // t8 = item special struct
        lhu     t0, 0x0092(t8)                  // t0 = collision flags
        andi    t0, t0, 0x0800                  // t0 = collision flags | grounded bitmask
        beqz    t0, _end                        // branch if ground collision flag = FALSE
        nop
        lwc1    f0, 0x0030(t8)                  // f2 = y speed
        abs.s   f0, f0                          // f2 = absolute y speed
        lui     t0, 0x40A0                      // ~
        mtc1    t0, f2                          // f2 = minimum y speed
        c.lt.s  f0, f2                          // ~
        nop                                     // ~
        bc1fl   _end                            // branch if abs y speed > minimum y speed
        nop

        jal     grenade_begin_resting_          // change to grounded/resting state
        or      a0, s0, r0                      // a0 = item object

        _end:
        lw      ra, 0x0014(sp)                  // ~
        lw      s0, 0x0040(sp)                  // ~
        lw      s1, 0x0044(sp)                  // load ra, s0, s1
        addiu   sp, sp, 0x0058                  // deallocate stack space
        jr      ra                              // return
        or      v0, r0, r0                      // return 0
    }

    // @ Description
    // Collision subroutine for the grenade's resting state.
    // a0 = item object
    scope grenade_resting_collision_: {
        addiu   sp, sp,-0x0018                  // allocate stack space
        sw      ra, 0x0014(sp)                  // store ra
        li      a1, grenade_begin_main_         // a1 = grenade_begin_main_
        jal     0x801735A0                      // generic resting collision?
        nop
        lw      ra, 0x0014(sp)                  // restore ra
        addiu   sp, sp, 0x0018                  // deallocate stack space
        jr      ra                              // return
        or      v0, r0, r0                      // return 0
    }

    // @ Description
    // Main subroutine for the grenade's exploding state.
    // a0 = item object
    // 80186524
    scope grenade_exploding_main_: {
        addiu   sp, sp,-0x0028                  // allocate stack space
        sw      ra, 0x0014(sp)                  // ~
        sw      s0, 0x001C(sp)                  // store ra, s0
        lw      s0, 0x0084(a0)                  // s0 = item special struct

        jal     grenade_explosion_hitboxes_     // subroutine which handles explosion hitboxes
        sw      s0, 0x0010(sp)                  // save item special struct address
        lli     at, 0x0006                      // at = explosion ending frame
        lhu     t6, 0x033E(s0)                  // t6 = current explosion timer
        addiu   t6, t6, 0x0001                  // ~
        sh      t6, 0x033E(s0)                  // increment and update explosion timer
        bne     t6, at, _end                    // branch if explosion timer != ending frame
        lli     v0, OS.FALSE                    // return FALSE (don't destroy item?)
        // if explosion timer = ending frame
        lli     v0, OS.TRUE                     // return TRUE (destroy item?)
        lw      at, 0x0010(sp)                  // load item special struct address
        lw      at, 0x01C4(at)                  // load player struct address
        sw      r0, 0x0ADC(at)                  // clear out free space in player struct so that another grenade can be thrown
        _end:
        lw      ra, 0x0014(sp)                  // ~
        lw      s0, 0x001C(sp)                  // load ra, s0
        jr      ra                              // return
        addiu   sp, sp, 0x0028                  // deallocate stack space
    }

    // @ Description
    // Hitbox? subroutine for the grenade's exploding state.
    // For now, just replaces a hard-coded reference to the item info array and then jumps to the original routine, 0x801863AC
    scope grenade_explosion_hitboxes_: {
        lw      v0, 0x0084(a0)                  // a0 = item special struct
        li      t6, grenade_item_info_array     // t6 = grenade_item_info_array
        // TODO: extend this custom routine if addressing offset hard-code(s)
        j       0x801863B8                      // jump to original routine
        lw      t6, 0x0004(t6)                  // t6 = file pointer
    }

    // @ Description
    // Changes a grenade to the aerial/main state.
    // a0 = item object
    scope grenade_begin_main_: {
        addiu   sp, sp,-0x0018                  // allocate stack space
        sw      ra, 0x0014(sp)                  // ~
        sw      a0, 0x0018(sp)                  // store ra, a0
        lw      a0, 0x0084(a0)               // a0 = item special struct
        // lbu     t0, 0x02CE(a0)               // t0 = unknown bitfield
        // andi    t0, t0, 0xFF7F               // disable item pickup bit
        // sb      t0, 0x02CE(a0)               // store updated bitfield
        lli     at, 0x0001                      // ~
        jal     0x80173F78                      // bomb subroutine, sets kinetic state value
        sw      at, 0x010C(a0)                  // enable hitbox
        jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
        lw      a0, 0x0018(sp)                  // a0 = item object
        lw      a0, 0x0018(sp)                  // a0 = item object
        li      a1, grenade_item_states         // a1 = object state base address
        jal     0x80172EC8                      // change item state
        ori     a2, r0, r0                      // a2 = 0 (aerial/main state)
        lw      ra, 0x0014(sp)                  // load ra
        jr      ra                              // return
        addiu   sp, sp, 0x0018                  // deallocate stack space
    }

    // @ Description
    // Changes a grenade to the grounded/resting state.
    // a0 = item object
    scope grenade_begin_resting_: {
        addiu   sp, sp,-0x0018                  // allocate stack space
        sw      ra, 0x0014(sp)                  // ~
        sw      a0, 0x0018(sp)                  // store ra, a0
        lw      a0, 0x0084(a0)                  // a0 = item special struct
        // sw      r0, 0x010C(a0)               // disable hitbox
        lbu     t0, 0x02CE(a0)                  // t0 = unknown bitfield
        // ori     t0, t0, 0x0080               // enables item pickup bit
        andi    t0, t0, 0x00CF                  // disable 2 bits
        sb      t0, 0x02CE(a0)                  // store updated bitfield
        sw      r0, 0x0030(a0)                  // y speed = 0
        jal     0x80173F54                      // bomb subroutine, sets kinetic state value and applies a multiplier to x speed?
        sw      r0, 0x0034(a0)                  // z speed = 0
        jal     0x80185CD4                      // bomb subroutine, sets an unknown value to 0x1
        lw      a0, 0x0018(sp)                  // a0 = item object
        lw      a0, 0x0018(sp)                  // a0 = item object
        li      a1, grenade_item_states         // a1 = object state base address
        jal     0x80172EC8                      // change item state
        ori     a2, r0, 0x0001                  // a2 = 1 (grounded/resting state)
        lw      ra, 0x0014(sp)                  // load ra
        jr      ra                              // return
        addiu   sp, sp, 0x0018                  // deallocate stack space
    }

    // @ Description
    // Handles the grenade's explosion.
    // Based on function 0x80186368 and its subroutine 0x80185A80.
    scope grenade_explosion_: {
        addiu   sp, sp,-0x0030                  // allocate stack space
        sw      ra, 0x001C(sp)                  // ~
        sw      s0, 0x0018(sp)                  // store ra, s0
        or      s0, a0, r0                      // s0 = item object
        lw      v0, 0x0084(a0)                  // v0 = item special struct
        sw      r0, 0x002C(v0)                  // ~
        sw      r0, 0x0030(v0)                  // ~
        sw      r0, 0x0034(v0)                  // reset x/y/z velocity
        jal     0x8017279C                      // bomb subroutine, removes owner, updates unknown value, sets unknown bitflag
        sw      r0, 0x0248(v0)                  // disable hurtbox
        lw      a0, 0x0074(s0)                  // a0 = item first joint struct
        jal     0x801005C8                      // create exploseion gfx
        addiu   a0, a0, 0x001C                  // a0 = item x/y/z

        // make the explosion larger (probably not needed for grenade)
        //beqz    v0, _next_gfx_call            // branch if no explosion gfx was created
        //nop
        //lui     at, 0x3FA6                    // ~
        //ori     at, at, 0x6666                // at = size multiplier
        //lw      t8, 0x005C(v0)                // t8 = some kind of graphic related struct
        //sw      at, 0x001C(t8)                // ~
        //sw      at, 0x0020(t8)                // ~
        //sw      at, 0x0024(t8)                // store multiplier to graphic x/y/z size

        jal     0x801008F4                      // unknown gfx related? function
        lli     a0, 0x0001                      // a0 = 1 (why?)

        lw      t0, 0x0074(s0)                  // t0 = item first joint struct
        lli     t1, 0x0002                      // t1 = 2
        sb      t1, 0x0054(t0)                  // set unknown value to 2
        lw      t0, 0x0084(s0)                  // t0 = item special struct
        lli     t1, 0x0001                      // t1 = 1
        sh      t1, 0x0156(t0)                  // set unknown value to 1
        jal     0x8017275C                      // bomb subroutine, sets up hitbox stuff? potentially hard-coded?
        or      a0, s0, r0                      // a0 = item object
        jal     grenade_begin_explosion_        // change to explosion state
        or      a0, s0, r0                      // a0 = item object
        jal     0x800269C0                      // play FGM
        lli     a0, 0x0001                      // FGM id = 1
        lw      ra, 0x001C(sp)                  // ~
        lw      s0, 0x0018(sp)                  // load ra, s0
        jr      ra                              // return
        addiu   sp, sp, 0x0030                  // deallocate stack space
    }

    // @ Description
    // Changes a grenade to the explosion state.
    // Based on function 0x8018656C and its subroutine 0x801864E8
    // a0 = item object
    scope grenade_begin_explosion_: {
        addiu   sp, sp,-0x0018                  // allocate stack space
        sw      ra, 0x0014(sp)                  // store ra
        lw      v0, 0x0084(a0)                  // v0 = item special struct
        lbu     t6, 0x0340(v0)                  // ~
        andi    t6, t6, 0xFF0F                  // ~
        sb      t6, 0x0340(v0)                  // disable unknown bitflags
        sh      r0, 0x033E(v0)                  // set explosion timer to 0
        lui     at, 0x3F80                      // ~
        sw      at, 0x0114(v0)                  // set unknown value to 1.0
        lli     t2, 000070                      // ~
        sw      t2, 0x0140(v0)                  // set hitbox kbg to 70
        lli     t2, 000050                      // ~
        sw      t2, 0x0148(v0)                  // set hitbox bkb to 50
        jal     grenade_explosion_hitboxes_     // subroutine which handles explosion hitboxes
        sw      a0, 0x0018(sp)                  // store a0
        lw      a0, 0x0018(sp)                  // a0 = item object
        li      a1, grenade_item_states         // a1 = object state base address
        jal     0x80172EC8                      // change item state
        ori     a2, r0, 0x0002                  // a2 = 2 (explosion state)
        lw      ra, 0x0014(sp)                  // load ra
        jr      ra                              // return
        addiu   sp, sp, 0x0018                  // deallocate stack space
    }

    // @ Description
    // Collision detection subroutine for aerial grenades.
    scope grenade_detect_collision_: {
        // Copy beginning of subroutine 0x801737B8
        OS.copy_segment(0xEE0F4, 0x88)
        beql    v0, r0, _end                    // modify branch
        lhu     t5, 0x0056(s0)                  // ~
        jal     0x800DD59C                      // ~
        or      a0, s0, r0                      // ~
        lhu     t0, 0x005A(s0)                  // ~
        lhu     t5, 0x0056(s0)                  // original logic
        // Remove ground collision lines
        // Copy end of subroutine
        _end:
        OS.copy_segment(0xEE1CC, 0x2C)
    }

    // @ Description
    // Runs when a Grenade's hitbox collides with a hurtbox.
    // a0 = item object
    scope grenade_hurtbox_collision_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        jal     grenade_begin_main_         // transition to aerial/main state
        sw      a0, 0x0028(sp)              // store ra, a0

        lw      a0, 0x0028(sp)              // a0 = item struct
        lw      t0, 0x0084(a0)              // t0 = item special struct
        lwc1    f0, 0x002C(t0)              // f0 = current x speed
        lwc1    f2, 0x0030(t0)              // f2 = current y speed
        mul.s   f0, f0, f0                  // f0 = x speed squared
        mul.s   f2, f2, f2                  // f2 = y speed squared
        add.s   f0, f0, f2                  // f0 = x speed squared + y speed squared
        sqrt.s  f4, f0                      // f4 = absolute speed
        lui     t1, 0x3F00                  // ~
        mtc1    t1, f2                      // f2 = 0.5
        mul.s   f0, f4, f2                  // f0 = absolute speed * 0.5
        lui     t1, 0x40A0                  // ~
        mtc1    t1, f2                      // f2 = 5
        add.s   f0, f0, f2                  // add base speed of 5 to f0

        // prevent the x/y speed from being updated if the hitbox collision flag is enabled
        // this is to prevent the grenade from recoiling if it trades hits
        lw      t1, 0x01D4(t0)              // t1 = hitbox collision flag
        bnez    t1, _continue               // skip if hitbox collision flag = TRUE
        sw      r0, 0x01D4(t0)              // hitbox collision flag = FALSE

        // if the hitbox collision flag wasn't enabled
        sw      r0, 0x002C(t0)              // item x speed = 0
        swc1    f0, 0x0030(t0)              // item y speed = (absolute speed * 0.5) + 5

        _continue:
        sw      r0, 0x01D0(t0)              // disable hitbox refresh timer
        cvt.w.s f0, f4                      // convert absolute speed to int
        mfc1    t1, f0                      // t1 = absolute speed (int)
        srl     t2, t1, 0x1                 // ~
        addu    t1, t1, t2                  // t1 = absolute speed * 1.5
        lw      t2, 0x02C0(t0)              // t2 = current duration
        subu    t2, t2, t1                  // t2 = updated duration (duration - (absolute speed * 1.5))
        slti    at, t2, 000012              // at = TRUE if updated duration < 12; else at = FALSE
        beqz    at, _end                    // branch if updated duration >= 12
        nop
        // if we're here then the calculated remaining duration was set to less than 12 frames
        // we'll set it to 12 instead
        lli     t2, 000012                  // t2 = 12

        _end:
        sw      t2, 0x02C0(t0)              // update remaining duration
        lw      ra, 0x0024(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0
    }

    // @ Description
    // this subroutine handles hitbox collision for the grenade, causing it to be launched when hit by attacks
    // a0 = item object
    scope grenade_hitbox_collision_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        lw      v0, 0x0084(a0)              // v0 = item special struct
        sw      ra, 0x0020(sp)              // 0x0020(sp) = ra
        sw      a0, 0x0024(sp)              // 0x0024(sp) = item object
        jal     grenade_begin_main_         // transition to aerial/main state
        sw      v0, 0x0028(sp)              // 0x0028(sp) = item special struct

        // update item ownership and combo ownership
        lw      t0, 0x0028(sp)              // t0 = item special struct
        lw      t1, 0x02A8(t0)              // t1 = object which has ownership over the colliding hitbox
        sw      t1, 0x0008(t0)              // update item owner
        lli     at, 0x0004                  // at = 0x4 (no combo ownership)
        beqz    t1, _calculate_movement     // skip if there isn't an object in t1
        lli     t2, 0x03E8                  // t2 = player object type
        lw      t3, 0x0000(t1)              // t3 = object type
        bne     t2, t3, _calculate_movement // skip if object type != player
        lw      t1, 0x0084(t1)              // t1 = type specific special struct
        lbu     at, 0x000D(t1)              // at = player port (for combo ownership)


        _calculate_movement:
        sb      at, 0x0015(t0)              // update combo ownership
        lwc1    f0, 0x0298(t0)              // ~
        cvt.s.w f0, f0                      // f0 = damage
        lui     t1, 0x4080                  // ~
        mtc1    t1, f2                      // f2 = 4
        mul.s   f0, f0, f2                  // f0 = damage * 4
        lui     t1, 0x4120                  // ~
        mtc1    t1, f2                      // f2 = 10
        add.s   f0, f0, f2                  // f0 = knockback ((damage * 4) + 10)
        swc1    f0, 0x002C(sp)              // 0x002C(sp) = knockback
        swc1    f0, 0x01C8(t0)              // current max speed = knockback
        lw      a0, 0x029C(t0)              // a0 = knockback angle
        // this subroutine converts the int angle in a0 to radians, also handles sakurai angle
        jal     0x801409BC                  // f0 = knockback angle in rads
        lw      a2, 0x002C(sp)              // a2 = knockback
        swc1    f0, 0x0030(sp)              // 0x0030(sp) = knockback angle
        // ultra64 cosf function
        jal     0x80035CD0                  // f0 = cos(angle)
        mov.s   f12, f0                     // f12 = knockback angle
        lwc1    f4, 0x002C(sp)              // f4 = knockback
        mul.s   f4, f4, f0                  // f4 = x velocity (knockback * cos(angle))
        swc1    f4, 0x0034(sp)              // 0x0034(sp) = x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(angle)
        lwc1    f12, 0x0030(sp)             // f12 = knockback angle
        lwc1    f4, 0x002C(sp)              // f4 = knockback
        mul.s   f4, f4, f0                  // f4 = y velocity (knockback * sin(angle))
        lwc1    f2, 0x0034(sp)              // f2 = x velocity

        lw      t0, 0x0028(sp)              // t0 = item special struct
        lw      t1, 0x02A4(t0)              // ~
        subu    t1, r0, t1                  // t1 = DIRECTION
        sw      t1, 0x0024(t0)              // update item direction
        mtc1    t1, f0                      // ~
        cvt.s.w f0, f0                      // f0 = DIRECTION
        mul.s   f2, f0, f2                  // f2 = x velocity * DIRECTION
        swc1    f2, 0x002C(t0)              // update projectile x velocity
        swc1    f4, 0x0030(t0)              // update projectile y velocity
        // lw      t1, 0x0004(t0)              // ~
        // lw      t1, 0x0074(t1)              // t1 = projectile position struct
        // lwc1    f2, 0x0034(t1)              // f2 = projectile z rotation
        // abs.s   f2, f2                      // f2 = absolute projectile z rotation
        // mul.s   f2, f0, f2                  // f2 = rotation * DIRECTION
        // swc1    f2, 0x0034(t1)              // store updated rotation
        lli     t1, 000016                  // ~
        sw      t1, 0x01D0(t0)              // set hitbox refresh timer to 16 frames
        lli     t1, OS.TRUE                 // ~
        sw      t1, 0x01D4(t0)              // hitbox collision flag = TRUE
        lw      t1, 0x0298(t0)              // t1 = damage
        sll     t1, t1, 0x1                 // t1 = damage * 2
        lw      t2, 0x02C0(t0)              // t2 = current duration
        subu    t2, t2, t1                  // t2 = updated duration (duration - (damage * 2))
        slti    at, t2, 000020              // at = TRUE if updated duration < 20; else at = FALSE
        beqz    at, _end                    // branch if updated duration >= 20
        nop
        // if we're here then the calculated remaining duration was set to less than 20 frames
        // we'll set it to 20 instead
        lli     t2, 000020                  // t2 = 20

        _end:
        sw      t2, 0x02C0(t0)              // update remaining duration

        lw      ra, 0x0020(sp)              // load ra
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra
        or      v0, r0, r0                  // return 0 (important, not sure why)
    }

    scope grenade_attributes {
        constant DURATION(0x0000)
        constant GRAVITY(0x0004)
        constant MAX_SPEED(0x0008)
        constant BOUNCE(0x000C)
        constant ANGLE(0x0010)
        constant ROTATION(0x0014)
        struct:
        dw 150                                  // 0x0000 - duration (int)
        float32 1.5                             // 0x0004 - gravity
        float32 60                              // 0x0008 - max speed
        float32 0.55                            // 0x000C - bounce multiplier
        float32 0.85                            // 0x0010 - angle
        float32 0.003                           // 0x0014 - rotation speed
    }

    OS.align(16)
    grenade_item_info_array:
    constant GRENADE_ID(0x15)
    dw GRENADE_ID                           // 0x00 - item ID (will be updated by Item.add_item
    dw Character.CONKER_file_7_ptr          // 0x04 - address of file pointer
    dw 0x00000040                           // 0x08 - offset to item footer
    dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
    dw 0                                    // 0x10 - ?
    grenade_item_states:
    // state 0 - main/aerial
    dw grenade_main_                        // 0x14 - state 0 main
    dw grenade_collision_                   // 0x18 - state 0 collision
    dw grenade_hurtbox_collision_           // 0x1C - state 0 hitbox collision w/ hurtbox
    dw grenade_hurtbox_collision_           // 0x20 - state 0 hitbox collision w/ shield
    dw 0x801733E4                           // 0x24 - state 0 hitbox collision w/ shield edge
    dw 0                                    // 0x28 - state 0 unknown (maybe absorb)
    dw 0x80173434                           // 0x2C - state 0 hitbox collision w/ reflector
    dw grenade_hitbox_collision_            // 0x30 - state 0 hurtbox collision w/ hitbox
    // state 1 - resting
    dw grenade_main_                        // 0x34 - state 1 main
    dw grenade_resting_collision_           // 0x38 - state 1 collision
    dw grenade_hurtbox_collision_           // 0x3C - state 1 hitbox collision w/ hurtbox
    dw grenade_hurtbox_collision_           // 0x40 - state 1 hitbox collision w/ shield
    dw 0x801733E4                           // 0x44 - state 1 hitbox collision w/ shield edge
    dw 0                                    // 0x48 - state 1 unknown (maybe absorb)
    dw 0x80173434                           // 0x4C - state 1 hitbox collision w/ reflector
    dw grenade_hitbox_collision_            // 0x50 - state 1 hurtbox collision w/ hitbox
    // state 2 - explosion
    dw grenade_exploding_main_              // 0xD4 - state 2 main
    dw 0                                    // 0xD8 - state 2 collision
    dw 0                                    // 0xDC - state 2 hitbox collision w/ hurtbox
    dw 0                                    // 0xE0 - state 2 hitbox collision w/ shield
    dw 0                                    // 0xE4 - state 2 hitbox collision w/ shield edge
    dw 0                                    // 0xE8 - state 2 unknown (maybe absorb)
    dw 0                                    // 0xEC - state 2 hitbox collision w/ reflector
    dw 0                                    // 0xF0 - state 2 hurtbox collision w/ hitbox
    OS.align(16)

    // this is used for how conker reacts to collision when using grounded grenades, based on Mario's NSP collision at 80155F28
    scope ground_collision: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, ground_to_air
        jal     0x800DDE84
        nop
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    scope ground_to_air: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)
        jal     0x800DEEC8
        sw      a0, 0x0024(sp)
        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x0002
        addiu   a1, r0, 0x00F1  // insert air action id
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)
        jal     0x800E6F24      // change action routine
        lui     a3, 0x3F80
        jal     0x800D8EB8
        lw      a0, 0x0024(sp)
        lw      t9, 0x0024(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // this is used for how conker reacts to collision when using grounded grenades, based on Mario's NSP collision at 80155F28
    scope ground_collision_fail: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, ground_to_air_fail
        jal     0x800DDE84
        nop
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    scope ground_to_air_fail: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)
        jal     0x800DEEC8
        sw      a0, 0x0024(sp)
        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x0002
        addiu   a1, r0, 0x00F5  // insert air action id
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)
        jal     0x800E6F24      // change action routine
        lui     a3, 0x3F80
        jal     0x800D8EB8
        lw      a0, 0x0024(sp)
        lw      t9, 0x0024(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // this is used for how conker reacts to collision when using aerial grenades, based on Mario's NSP collision at 80155F28
    scope air_collision: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, air_to_ground
        jal     0x800DE6E4
        nop
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    scope air_to_ground: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)
        jal     0x800DEE98
        sw      a0, 0x0024(sp)
        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x0002
        addiu   a1, r0, 0x00EC  // insert ground action id
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)
        jal     0x800E6F24      // change action routine
        lui     a3, 0x3F80
        lw      t9, 0x0024(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // this is used for how conker reacts to collision when using aerial grenades, based on Mario's NSP collision at 80155F28
    scope air_collision_fail: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, air_to_ground_fail
        jal     0x800DE6E4
        nop
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0018
        jr      ra
        nop
    }

    scope air_to_ground_fail: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        sw      a0, 0x0028(sp)
        lw      a0, 0x0084(a0)
        jal     0x800DEE98
        sw      a0, 0x0024(sp)
        lw      a0, 0x0028(sp)
        addiu   t7, r0, 0x0002
        addiu   a1, r0, 0x00EF  // insert ground action id
        lw      a2, 0x0078(a0)
        sw      t7, 0x0010(sp)
        jal     0x800E6F24      // change action routine
        lui     a3, 0x3F80
        lw      t9, 0x0024(sp)
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x0028
        jr      ra
        nop
    }

    // @ Description
    // this routine gets run by whenever a projectile crosses the blast zone. The purpose here is to restock Conker's grenades
    scope grenade_blast_zone_: {
        lw      t0, 0x0084(a0)          // t0 = item special struct
        lw      t1, 0x01C4(t0)          // load player struct from item special struct
        jr      ra                      // return
        sw      r0, 0x0ADC(t1)          // clear out player struct free space so another grenade can be thrown
    }
}
