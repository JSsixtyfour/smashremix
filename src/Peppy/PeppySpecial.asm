// PeppySpecial.asm

// This file contains subroutines used by Peppy Hare's special moves.

// @ Description
// Subroutines for Peppy Neutral special.
scope PeppyNSP {
    constant LASER_DURATION(18)
    constant CHARGES(0x5)
    constant FINAL_SHOT_DAMAGE(8)
    constant FINAL_SHOT_KB2(0x64)
    constant FINAL_SHOT_KB_ANGLE(0x46)

    // @ Description
    // Subroutine which runs when Peppy initiates a grounded neutral special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Begin

        lli     a1, Peppy.Action.NSPG_BEGIN // a1(action id) = NSP_Ground_Begin
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which runs when Peppy initiates an aerial neutral special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Begin

        lli     a1, Peppy.Action.NSPA_BEGIN // a1(action id) = NSP_Air_Begin
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine for when Peppy initiates a neutral special.
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
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        jal     0x801576B4                  // kirby's on hit subroutine setup
        or      a0, s0, r0                  // a0 = player struct
        b       _continue                   // branch
        nop

        _peppy:
        jal     0x8015DB4C                  // on hit subroutine setup
        or      a0, s0, r0                  // a0 = player struct

        _continue:
        lw      t7, 0x0AE0(s0)              // t7 = charge level
        lli     at, CHARGES                 // at = 0x0005
        lli     t8, 0x0001                  // t8 = 0x0001
        bnel    t7, at, _end                // end if charge level != 5(max)
        sw      r0, 0x0B18(s0)              // set transition bool to 0 (charge)

        // if we're here, the neutral special is fully charged, so set transition bool to shoot
        sw      at, 0x0AE0(s0)              // set charges to 5 to prevent kathys random kirby hat jank
        sw      t8, 0x0B18(s0)              // set transition bool to 1 (shoot)

        _end:
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Ground_Begin and NSP_Air_Begin.
    // Based on subroutine 0x8015D3EC, which is the main subroutine for Samus's NSPG_Begin and NSPA_Begin actions.
    scope begin_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0030(sp)              // store ra, a0
        lw      v0, 0x0084(a0)              // v0 = player struct

        lh      t1, 0x01BE(v0)              // t1 = player inputs
        andi    t1, t1, Joypad.B
        beqz    t1, _continue
        lw      t1, 0xAE0(v0)               // load charge amount
        beqz    t1, _continue               // branch if no ammo
        nop
        // if here, player is trying to shoot
        addiu   t7, r0, 1                   // set transition boolean to shoot
        b       _get_kinetic_state
        sw      t7, 0x0B18(v0)              // overwrite transition boolean

        _continue:
        // checks the current animation frame to see if we've reached end of the animation
        lwc1    f6, 0x0078(a0)              // ~
        mtc1    r0, f4                      // ~
        c.le.s  f6, f4                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0014(sp)              // load ra


        _get_kinetic_state:
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
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
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
        lw      ra, 0x0014(sp)              // restore ra
        jr      ra
        addiu   sp, sp, 0x0020              // deallocate stack space
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
        lw      ra, 0x0014(sp)              // restore ra
        jr      ra
        addiu   sp, sp,0x0020              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Begin

        lli     a1, Peppy.Action.NSPA_BEGIN // a1(action id) = NSP_Air_Begin
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Begin

        lli     a1, Peppy.Action.NSPG_BEGIN // a1(action id) = NSP_Ground_Begin
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
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Charge

        lli     a1, Peppy.Action.NSPG_CHARGE// a1(action id) = NSP_Ground_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Charge

        lli     a1, Peppy.Action.NSPA_CHARGE// a1(action id) = NSP_Air_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main subroutine for NSP_Ground_Charge and NSP_Air_Charge.
    // Based on subroutine 0x8015D5AC, which is the main subroutine for Samus' grounded neutral special charge.
    scope charge_main_: {
        // First 2 lines of subroutine 0x8015D5AC
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      a3, 0x0084(a0)              // load player struct
        lw      t9, 0x017C(a3)              // t9 = temp variable 1
        beqz    t9, _end
        sw      r0, 0x017C(a3)              // clear out temp var

        // if here, add 1 to charge
        lw      v0, 0x0AE0(a3)              // load charge amount
        addiu   t9, r0, 0x0012
        sw      t9, 0x0B1C(a3)
        slti    at, v0, CHARGES
        beq     at, r0, _end
        addiu   t0, v0, 0x0001              // add one to charge
        addiu   at, r0, CHARGES
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
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Interrupt subroutine for NSP_Ground_Charge.
    // Based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope ground_charge_interrupt_: {
        addiu   sp, sp, -0x20
        sw      ra, 0x0014(sp)
        lw      a1, 0x0084(a0)
        or      a2, a0, r0
        lhu     v0, 0x01BE(a1)
        lhu     t6, 0x01B6(a1)
        and     t7, v0, t6

        bnez    t7, _shoot
        nop
        lhu     t8, 0x01B4(a1)
        or      a0, a1, r0
        and     t9, v0, t8
        beql    t9, r0, _branch
        sw      a1, 0x001C(sp)

        _shoot:
        lw      v0, 0xAE0(a1)       // load charge amount
        beqzl   v0, _branch         // branch if no ammo loaded
        sw      a1, 0x001C(sp)
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
        jr      ra
        addiu   sp, sp, 0x0020
    }

    // @ Description
    // Interrupt subroutine for NSP_Air_Charge.
    // Loosely based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope air_charge_interrupt_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0084(a0)              // a1 = player struct

        // skip shoot check if no ammo loaded
        lw      v0, 0xAE0(a1)               // load charge amount
        beqzl   v0, _check_cancel           // branch if no ammo loaded
        sw      a1, 0x001C(sp)
        // begin by checking for A or B presses
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
        jal     0x8013F9E0                  // transition to fall
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dellocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Charge

        lli     a1, Peppy.Action.NSPG_CHARGE// a1(action id) = NSP_Ground_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Charge

        lli     a1, Peppy.Action.NSPA_CHARGE// a1(action id) = NSP_Air_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Shoot

        lli     a1, Peppy.Action.NSPG_SHOOT // a1(action id) = NSP_Ground_Shoot
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t6, 0x0024(sp)              // 0x0024(sp) = player struct

        lw      t9, 0x0024(sp)              // 0x0024(sp) = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        lw      t9, 0x0024(sp)              // t9 = player struct
        sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
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
         lli     a1, Kirby.Action.PEPPY_NSP_Air_Shoot
         lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
         beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
         lli     a1, Kirby.Action.PEPPY_NSP_Air_Shoot

        lli     a1, Peppy.Action.NSPA_SHOOT // a1(action id) = NSP_Air_Shoot
        or      a2, r0, r0                  // a2(starting frame) = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

         lw      t7, 0x0008(s0)              // t7 = current character ID
         lli     at, Character.id.KIRBY      // at = id.KIRBY
         beq     t7, at, _kirby              // branch if character = KIRBY
         lli     at, Character.id.JKIRBY     // at = id.JKIRBY
         bne     t7, at, _peppy              // branch if character != JKIRBY
         nop

         _kirby:
         li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
         b       _end                        // branch to end
         nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
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

        lw      t6, 0x0AE0(v0)              // load Laser Charge Amount
        beqz    t6, _idle_check
        lw      t9, 0x017C(v0)              // t9 = temp variable 1
        beq     t9, r0, _checks             // skip if temp variable 1 = 0
        nop
        sw      r0, 0x017C(v0)              // t6 = temp variable 0
        addiu   t6, t6, -0x1
        sw      t6, 0x0AE0(v0)              // save new Laser Charge Amount

        // s0 = needle_properties_struct

        // if we're here, then temp variable 1 was enabled, so create a projectile
        mtc1    r0, f0                      // move 0 to f0
        sw      r0, 0x0028(sp)              // z offset = 0
        addiu   at, r0, Character.id.PEPPY
        lw      t5, 0x0008(v0)              // load character id
        beq     at, t5, _peppy
        lui     at, 0x4320
        sw      at, 0x0020(sp)              // x offset = ^
        lui     at, 0xC202
        beq     r0, r0, _kirby
        sw      at, 0x0024(sp)              // y offset = ^

        _peppy:
        lui     at, 0x4300
        sw      at, 0x0020(sp)              // x offset = ^
        lui     at, 0x4250

        _kirby:
        sw      at, 0x0024(sp)              // y offset = ^
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x092C(v0)              // a0 = part weapon struct
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct

        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     laser_stage_setting_        // INITIATE Laser
        addiu   a1, sp, 0x0020              // a1 = coordinates to create projectile at
        lw      a0, 0x0034(sp)              // a0 = player object
        // beqz    v0, _checks                 // branch if no projectile created
        // nop
        // lw      v1, 0x0084(a0)              // v1 = player struct
        // lw      t0, 0x0AE0(v1)              // t0 = ammo count
        // bnez    t0, _checks                 // branch if ammo count is > 0

        // if here, increase projectile damage
        // lw      t1, 0x0084(v0)
        // addiu   at, r0, FINAL_SHOT_DAMAGE
        // sw      at, 0x0104(t1)              // save projectile damage
        // addiu   at, r0, FINAL_SHOT_KB2
        // sw      at, 0x0134(t1)              // save new knockback
        // addiu   at, r0, FINAL_SHOT_KB_ANGLE
        // sw      at, 0x012C(t1)              // save new knockback angle

        _checks:
        lwc1    f8, 0x0078(a0)              // ~
        lui     at, 0x4200
        mtc1    at, f6
        c.eq.s  f8, f6
        nop
        bc1f    _idle_check
        nop

        lw      t1, 0x0084(a0)              // player struct
        lw      t4, 0x0008(t1)              // t4 = current character ID
        lui     a2, 0x41C0                  // a2(starting frame)
        lhu     t1, 0x0026(t1)              // player action
        lli     t3, Character.id.PEPPY      // t3 = id.PEPPYY
        beq     t3, t4, _peppy_action       // if PEPPY, select correct action ID
        nop

        addiu   t2, r0, Kirby.Action.PEPPY_NSP_Ground_Shoot
        bnel    t1, t2, _change_action
        addiu   a1, r0, Kirby.Action.PEPPY_NSP_Air_Shoot // a1 = NSP routine
        beq     r0, r0, _change_action
        addiu   a1, r0, Kirby.Action.PEPPY_NSP_Ground_Shoot // a1 = NSP routine

        _peppy_action:
        addiu   t2, r0, Peppy.Action.NSPG_SHOOT
        bnel    t1, t2, _change_action
        addiu   a1, r0, Peppy.Action.NSPA_SHOOT // a1 = NSP routine
        addiu   a1, r0, Peppy.Action.NSPG_SHOOT // a1 = NSP routine

        _change_action:
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        beq     r0, r0, _end
        nop

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
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dellocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // dellocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to NSP_Ground_Shoot.
    // Based on subroutine 0x8015D9B0, which is the transition subroutine for Samus' aerial neutral special shot.
    scope ground_shoot_transition_: {
        // Copy the first 8 lines of subroutine 0x8015D9B0
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
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Ground_Shoot

        lli     a1, Peppy.Action.NSPG_SHOOT // a1(action id) = NSP_Ground_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802

        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
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
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.PEPPY_NSP_Air_Shoot

        lli     a1, Peppy.Action.NSPA_SHOOT // a1(action id) = NSP_Air_Shoot
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7

        lw      t9, 0x0024(sp)              // t9 = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _peppy              // branch if character != JKIRBY
        nop

        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop

        _peppy:
        li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }


    // @ Description
    // Subroutine which handles air collision for neutral special actions
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
    // Subroutine which handles ground to air transition for neutral special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lw      a2, 0x0008(v0)              // load character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, _change_action      // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, _change_action      // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WOLF_NSP_Ground

        addiu   a1, r0, 0x00E1             // a1 = equivalent ground action for current air action
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x00010(sp)             // argument 4 = 0
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0038              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for Peppy's laser.
    scope laser_stage_setting_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      a1, 0x0024(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a1
        li      a1, projectile_struct       // a1 = projectile struct
        lw		a2, 0x0024(sp)              // a2 = create coordinates
        jal     0x801655C8                  // general projectile creation
        lui     a3, 0x8000                  // a3 = 0x80000000
        beq     v0, r0, _end_stage_setting  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        lw      v1, 0x0084(v0)              // v0 = projectile special struct
        lui     at, 0x4396                  // ~
        mtc1    at, f8                      // projectile speed = 300
        lwc1    f12, 0x0024(v1)             // f12 = y speed? argument for 0x8001863C?
        lwc1    f6, 0x0018(v1)              // ~
        cvt.s.w f6, f6                      // v0 = DIRECTION
        mul.s   f14, f6, f8                 // f14 = speed * DIRECTION
        swc1    f14, 0x0020(v1)             // store projectile speed
        jal     0x8001863C                  // unknown subroutine
        sw      v0, 0x0018(sp)              // 0x0018(sp) = projectile object
        lw      t7, 0x0018(sp)              // t7 = projectile object
        lw      t8, 0x0074(t7)              // t8 = projectile first part struct
        swc1    f0, 0x0038(t8)              // update projectile rotation (returned by 0x8001863C)
        jal     create_orange_blast_gfx_    // greate orange blast gfx
        lw      a0, 0x0024(sp)              // a0 = creation coordinates
        lw      v0, 0x0018(sp)              // v0 = projectile object

        _end_stage_setting:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // based on 0x80168924
    blaster_projectile_collision_check_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014 (sp)

        jal     0x80167C04
        sw      a0, 0x0018 (sp)
        beqz    v0, _end
        lw      t6, 0x0018 (sp)
        lw      a0, 0x0074 (t6)
        jal     create_orange_blast_gfx_    // create orange blast gfx
        addiu   a0, a0, 0x001c
        b       _end_2
        addiu   v0, r0, 0x0001

        _end:
        or v0, r0, r0

        _end_2:
        lw ra, 0x0014 (sp)
        jr      ra
        addiu sp, sp, 0x18
    }


    // @ Description
    // Based on 0x80103320
    scope create_orange_blast_gfx_: {
        addiu          sp, sp, -0x18
        or             a2, a0, r0
        sw             ra, 0x0014(sp)

        lui            a0, 0x8013
        lw             a0, 0x13C4(a0)
        sw             a2, 0x0018(sp)
        jal            0x800CE870
        addiu          a1, r0, 0x008D       // gfx routine index
        lw             a2, 0x0018(sp)
        beqz           v0, _end
        or             v1, v0, r0
        lwc1           f4, 0x0000(a2)
        swc1           f4, 0x0020(v0)
        lwc1           f6, 0x0004(a2)
        swc1           f6, 0x0024(v0)
        lwc1           f8, 0x0008(a2)
        swc1           f8, 0x0028(v0)

        _end:
        lw             ra, 0x0014(sp)
        addiu          sp, sp, 0x18
        jr             ra
        or             v0, v1, r0
    }

    // @ Description
    // based on 80168964
    scope blaster_projectile_collision: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)
        lw      a0, 0x0074(a0)
        jal     create_orange_blast_gfx_
        addiu   a0, a0, 0x001C
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x18
        jr      ra
        addiu   v0, r0, 0x0001        // destroy projectile
    }

    // @ Description
    // based on 80168964
    scope blaster_projectile_collision_2: {
        addiu          sp, sp, -0x20
        sw             ra, 0x0014(sp)
        lw             v0, 0x0084(a0)
        lui            at, 0x4000
        mtc1           at, f6
        lwc1           f4, 0x0244(v0)
        or             a3, a0, r0
        sw             a3, 0x0020(sp)
        mul.s          f8, f4, f6
        addiu          a0, v0, 0x0020
        sw             v0, 0x001c(sp)
        addiu          a1, v0, 0x0248
        mfc1           a2, f8
        jal            0x80019438
        nop
        lw             v0, 0x001C(sp)
        lwc1           f12, 0x0024(v0)
        jal            0x8001863c
        lwc1           f14, 0x0020(v0)
        lw             a3, 0x0020(sp)
        lui            at, 0x3f80
        mtc1           at, f10
        lw             t6, 0x0074(a3)
        swc1           f0, 0x0038(t6)
        lw             t7, 0x0074(a3)
        swc1           f10, 0x0040(t7)
        lw             a0, 0x0074(a3)
        jal            create_orange_blast_gfx_
        addiu          a0, a0, 0x001C
        lw             ra, 0x0014(sp)
        addiu          sp, sp, 0x20
        jr             ra
        or             v0, r0, r0
    }

    // @ Description
    // Projectile struct for Peppy's laser.
    OS.align(16)
    projectile_struct:
    dw 0x00000000                           // unknown
    dw 0x00000001                           // projectile id
    dw Character.PEPPY_file_6_ptr           // address of Sheik's file 6 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x1C000000                           // This determines z axis rotation? (samus is 1246)
    dw 0x801688D0                           // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw blaster_projectile_collision_check_  // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw blaster_projectile_collision         // This function runs when the projectile collides with a hurtbox.
    dw blaster_projectile_collision         // This function runs when the projectile collides with a shield.
    dw blaster_projectile_collision_2       // This function runs when the projectile collides with edges of a shield and bounces off
    dw blaster_projectile_collision         // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x80168A14                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw blaster_projectile_collision         // This function runs when the projectile collides with Ness's psi magnet// absorb routine
    OS.copy_segment(0x103904, 0x0C)         // empty

}

scope PeppyDSP {

    // time until bomb explodes after manual explosion click sfx plays
    constant DETONATE_TIMER(0x3)

    // @ Description
    // initial routine for Peppy's Grenade
    scope initial_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        lw      v0, 0x0084(a0)
        sw      r0, 0x017C(v0)          // clear temp variable 1
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
        jr      ra
        addiu   sp, sp, 0x0028
    }

    // @ Description
    // main subroutine for first action of DSP, its job is to determine joystick and and transition to another move based on this
    scope air_initial_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x001c(sp)
        lw      v0, 0x0084(a0)
        sw      r0, 0x017C(v0)          // clear temp variable 1
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
        jr      ra
        addiu   sp, sp, 0x0028
    }

    // @ Description
    // main subroutine for Peppy's Grenade based on Mario's fireball coding
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
        addiu   t6, t6, 0x0001                      // adds to speed
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
        sw      r0, 0x0008(a1)                      // z coordinate = 0
        li      at, 0x80000002                      // ~
        sw      at, 0x0010(sp)                      // unknown argument = 0x80000002
        lw      a0, 0x0034(sp)                      // a0 = player object
        li      a1, Item.Flashbang.item_info_array   // a1 = grenade_item_info_array

        addiu   a2, sp, 0x0020                      // a2 = x/y/z coordinates
        jal     Item.Flashbang.SPAWN_ITEM           // create flashbang
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
        jr      ra
        addiu   sp, sp, 0x0080
    }

    scope detonate_main_ground: {
        OS.routine_begin(0x20)

        jal     detonate_check
        sw      a0, 0x0010(sp)
        jal     0x800D94C4          // original routine
        lw      a0, 0x0010(sp)      // restore a0

        OS.routine_end(0x20)

    }

    scope detonate_main_air: {
        OS.routine_begin(0x20)

        jal     detonate_check
        sw      a0, 0x0010(sp)
        jal     0x800D94E8          // original routine
        lw      a0, 0x0010(sp)      // restore a0

        OS.routine_end(0x20)

    }

    // @ Description
    // Check if it is time to detonate the explosive for Peppy
    scope detonate_check: {
        OS.routine_begin(0x20)

        lw      v0, 0x0084(a0)          // v0 = player struct
        lw      t6, 0x017C(v0)          // t6 = temp variable 1
        beqz    t6, _end
        sw      r0, 0x017C(v0)          // reset temp variable 1
        lw      t7, 0x0ADC(v0)          // get grenade item struct
        beqz    t7, _end                // branch if no grenade
        nop

        // if here, detonate
        lw      at, 0x02C0(t7)          // at = current explode timer
        slti    at, at, DETONATE_TIMER  // at = 0 if => detonate timer
        bnez    at, _end                // branch if already about to detonate
        addiu   at, r0, DETONATE_TIMER
        sw      at, 0x02C0(t7)          // set explosion timer so it explodes soon

        _end:
        OS.routine_end(0x20)
    }

    // this is used for how Peppy reacts to collision when using grounded grenades, based on Mario's NSP collision at 80155F28
    scope ground_collision: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, ground_to_air
        jal     0x800DDE84
        nop
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0018
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
        jr      ra
        addiu   sp, sp, 0x0028
    }

    // this is used for how Peppy reacts to collision when using grounded grenades, based on Mario's NSP collision at 80155F28
    scope ground_collision_fail: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, ground_to_air_fail
        jal     0x800DDE84
        nop
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0018
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
        jr      ra
        addiu   sp, sp, 0x0028
    }

    // this is used for how Peppy reacts to collision when using aerial grenades, based on Mario's NSP collision at 80155F28
    scope air_collision: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, air_to_ground
        jal     0x800DE6E4
        nop
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0018
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
        jr      ra
        addiu   sp, sp, 0x0028
    }

    // this is used for how Peppy reacts to collision when using aerial grenades, based on Mario's NSP collision at 80155F28
    scope air_collision_fail: {
        addiu   sp, sp, -0x0018
        sw      ra, 0x0014(sp)
        li      a1, air_to_ground_fail
        jal     0x800DE6E4
        nop
        lw      ra, 0x0014(sp)
        jr      ra
        addiu   sp, sp, 0x0018
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
        jr      ra
        addiu   sp, sp, 0x0028
    }

}