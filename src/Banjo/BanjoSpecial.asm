// BanjoSpecial.asm

// This file contains subroutines used by Banjo's special moves.

// @ Description
// Subroutines for Neutral Special
scope BanjoNSP {
    constant EGG_DURATION(30)
    constant BACKWARD_EGG_DURATION(120)
    constant DEADZONE(6) // 6 - 1 = 5

    // @ Description
    // Subroutine which runs when Banjo initiates a grounded neutral special.
    scope ground_begin_initial_: {
        OS.routine_begin(0x20)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a2, a1, _change_action      // branch if Banjo
        lli     a1, Banjo.Action.NSPBeginG  // a1(action id) = NSPBeginG
        lli     a1, Kirby.Action.BANJO_NSPBeginG
        _change_action:
        jal     begin_initial_              // begin_initial_
        nop
        OS.routine_end(0x20)
    }

    // @ Description
    // Subroutine which runs when Banjo initiates an aerial neutral special.
    scope air_begin_initial_: {
        OS.routine_begin(0x20)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a2, a1, _change_action      // branch if Banjo
        lli     a1, Banjo.Action.NSPBeginA  // a1(action id) = NSPBeginG
        lli     a1, Kirby.Action.BANJO_NSPBeginA
        _change_action:
        jal     begin_initial_              // begin_initial_
        nop
        OS.routine_end(0x20)
    }

    // @ Description
    // Subroutine for when Banjo initiates a neutral special.
    // Based on subroutine 0x8015DB64, which is the initial subroutine for Samus' grounded neutral special.
    // a0 - player object
    // a1 - action id
    scope begin_initial_: {
        OS.routine_begin(0x30)
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0028(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0028(sp)              // a0 = player object

        _end:
        lw      s0, 0x0020(sp)              // ~
        OS.routine_end(0x30)
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

        // if here, shoot forwards or backwards
        lb      t7, 0x01C2(v0)              // joystick x axis
        andi    t6, t7, 0x0080              // t6 = 0 if pointing right
        beqz    t6, _joystick_right
        addiu   t5, t7, +DEADZONE           // check deadzone
        // pointing left
        bgtzl   t5, _continue               // branch if within deadzone
        addiu   t5, r0, 0                   // t5 = 0 (within deadzone)
        b       _continue
        addiu   t5, r0, -1                   // t5 = -1 if facing left

        _joystick_right:
        addiu   t5, t7, -DEADZONE           // check deadzone
        bltzl   t5, _continue               // branch if within deadzone
        addiu   t5, r0, 0                   // t5 = 0 (within deadzone)
        b       _continue
        addiu   t5, r0, 1                  // t5 = 1 if facing right

        _continue:
        lw      t6, 0x014C(v0)              // t6 = kinetic state (0 = grounded, 1 = aerial)
        beq     t6, r0, _grounded           // branch if kinetic state = grounded
        lw      t8, 0x0044(v0)              // at = facing direction

        _aerial:
        beq     t5, t8, _air_shoot_forward  // branch if facing direction = stick direction
        nop
        beqz    t5, _air_shoot_forward      // shoot forward if not even pointing the stick
        nop

        _air_shoot_backward:
        jal     air_shoot_backward_initial_ // air_charge_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _air_shoot_forward:
        jal     air_shoot_forward_initial_  // air_shoot_initial_
        lw      a0, 0x0030(sp)              // a0 = player object
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _grounded:
        beq     t5, t8, _ground_shoot_forward // branch if facing direction = stick direction
        nop

        beqz    t5, _ground_shoot_forward   // shoot forward if not even pointing the stick
        nop

        _ground_shoot_backward:
        jal     ground_shoot_backward_initial_ // ground_charge_initial_
        nop
        b       _end                        // end
        lw      ra, 0x0014(sp)              // load ra

        _ground_shoot_forward:
        jal     ground_shoot_forward_initial_ // ground_shoot_initial_
        lw      a0, 0x0030(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra

        _end:
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
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
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPBeginA  // a1(action id) = Banjo NSPBeginA
        lli     a1, Kirby.Action.BANJO_NSPBeginA  // a1(action id) = Kirby NSPBeginA
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002

        // lw      t7, 0x0008(s0)              // t7 = current character ID
        // lli     at, Character.id.KIRBY      // at = id.KIRBY
        // beq     t7, at, _kirby              // branch if character = KIRBY
        // lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        // bne     t7, at, _sheik              // branch if character != JKIRBY
        // nop

        //_kirby:
        //li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        // b       _end                        // branch to end
        // nop

        // _sheik:
        // li      t7, 0x8015D338              // t7 = on hit subroutine

        _end:
        //sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
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
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPBeginG // a1(action id) = NSPBeginG
        lli     a1, Kirby.Action.BANJO_NSPBeginG  // a1(action id) = Kirby NSPBeginG
        _change_action:
        lw      t8, 0x08E8(s0)              // t8 = top joint struct (original logic, useless?)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002

        _end:
        //sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for NSP_Ground_Shoot.
    // Based on subroutine 0x8015DA60, which is the initial subroutine for Samus' grounded neutral special shot.
    scope ground_shoot_forward_initial_: {
        // Copy the first 5 lines of subroutine 0x8015DA60
        OS.copy_segment(0xD84A0, 0x14)

        lw      a2, 0x0084(a0)              // ~
        sw      r0, 0x017C(a2)              // ~
        sw      r0, 0x0180(a2)              // reset temp variable 1/2

        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPForwardG// a1(action id) = NSPForwardG
        lli     a1, Kirby.Action.BANJO_NSPForwardG // a1(action id) = Kirby NSPForwardG
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t6, 0x0024(sp)              // 0x0024(sp) = player struct

        _end:
        //lw      t9, 0x0024(sp)              // t9 = player struct
        //sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for NSP_Ground_Shoot.
    // Based on subroutine 0x8015DA60, which is the initial subroutine for Samus' grounded neutral special shot.
    scope ground_shoot_backward_initial_: {
        // Copy the first 5 lines of subroutine 0x8015DA60
        OS.copy_segment(0xD84A0, 0x14)

        lw      a2, 0x0084(a0)              // ~
        sw      r0, 0x017C(a2)              // ~
        sw      r0, 0x0180(a2)              // reset temp variable 1/2

        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPBackwardG// a1(action id) = NSPBackwardG
        lli     a1, Kirby.Action.BANJO_NSPBackwardG// a1(action id) = Kirby NSPBackwardG
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t6, 0x0024(sp)              // 0x0024(sp) = player struct

        _end:
        //lw      t9, 0x0024(sp)              // t9 = player struct
        //sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for NSP_Air_Shoot.
    // Based on subroutine 0x8015DAA8, which is the initial subroutine for Samus' grounded neutral special shot.
    scope air_shoot_forward_initial_: {
        // Copy the first 15 lines of subroutine 0x8015DAA8
        OS.copy_segment(0xD84E8, 0x3C)

        lw      a2, 0x0084(a0)              // ~
        sw      r0, 0x017C(a2)              // ~
        sw      r0, 0x0180(a2)              // reset temp variable 1/2

        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPForwardA// a1(action id) = NSPForwardA
        lli     a1, Kirby.Action.BANJO_NSPForwardA// a1(action id) = Kirby NSPForwardA
        _change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        _end:
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Initial subroutine for NSP_Air_Shoot.
    // Based on subroutine 0x8015DAA8, which is the initial subroutine for Samus' grounded neutral special shot.
    scope air_shoot_backward_initial_: {
        // Copy the first 15 lines of subroutine 0x8015DAA8
        OS.copy_segment(0xD84E8, 0x3C)

        lw      a2, 0x0084(a0)              // ~
        sw      r0, 0x017C(a2)              // ~
        sw      r0, 0x0180(a2)              // reset temp variable 1/2

        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPBackwardA// a1(action id) = NSPBackwardA
        lli     a1, Kirby.Action.BANJO_NSPBackwardA// a1(action id) = Kirby NSPBackwardA
        _change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0

        _end:
        lw      s0, 0x0020(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main subroutine for neutral special air ending.
    // If temp variable 1 is set by moveset, create a projectile.
    scope shoot_forward_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beq     t6, r0, _idle_check         // skip if temp variable 1 = 0
        nop
        sw      r0, 0x017C(v0)              // t6 = temp variable 0

        // s0 = egg_properties_struct

        // if we're here, then temp variable 1 was enabled, so create a projectile
        mtc1    r0, f0                      // move 0 to f0
        swc1    f0, 0x0020(sp)              // ~
        swc1    f0, 0x0028(sp)              // establish origin points for x, y, and z
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x093C(v0)              // a0 = Kazooie head struct
        lli     t0, Character.id.BANJO      // t0 = id.BANJO
        lw      t1, 0x0008(v0)              // t1 = char_id
        lli     t2, 0x0000                  // t2 = Y/X offset (none for Banjo)
        bnel    t0, t1, pc() + 8            // if not Banjo, add Y/X offset
        lui     t2, 0xC320                  // t2 = Y/X offset
        sw      t2, 0x0024(sp)              // set Y/X offset
        lui     t2, 0xC220                  // t2 = X/Y offset
        sw      t2, 0x0020(sp)              // set X/Y offset

        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct

        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     egg_stage_setting_          // INITIATE EGG
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
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Main subroutine for neutral special air ending.
    // If temp variable 1 is set by moveset, create a projectile.
    scope shoot_backward_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beq     t6, r0, _idle_check         // skip if temp variable 1 = 0
        nop
        sw      r0, 0x017C(v0)              // t6 = temp variable 0

        // s0 = egg_properties_struct

        // if we're here, then temp variable 1 was enabled, so create a projectile
        mtc1    r0, f0                      // move 0 to f0
        swc1    f0, 0x0020(sp)              // ~
        swc1    f0, 0x0024(sp)              // ~
        swc1    f0, 0x0028(sp)              // establish origin points for x, y, and z
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x093C(v0)              // a0 = Kazooie head struct
        // TODO: KIRBY CHECK
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct

        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     egg_poop_stage_setting_     // INITIATE EGG POOP
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
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    scope egg_stage_setting_: {
        addiu   sp, sp, -0x0050
        sw      s0, 0x0018(sp)
        li      s0, forward_egg_properties_struct   // s0 = projectile properties struct address
        sw      a1, 0x0034(sp)
        sw      a0, 0x0038(sp)
        sw      ra, 0x001C(sp)

        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, forward_egg_projectile_struct   // a1 = main projectile struct address
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

        sw      r0, 0x029C(v1)              // clear out some value used by fireball
        addiu   at, r0, 0x28                // fgm id
        sh      at, 0x0146(v1)              // save on hit fgm
        sw      r0, 0x010C(v1)              // set hitbox type to NORMAL

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
        cvt.s.w f16, f10                    // ~
        mul.s   f18, f8, f16                // ~
        jal     0x800303F0                  // ~
        swc1    f18, 0x0020(v1)             // original logic


        lwc1    f4, 0x0020(s0)              // ~ load speed
        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        mul.s   f6, f0, f4                  // f6 = direction times speed
        swc1    f6, 0x0024(v1)              // ~ save new speed
        lw      t8, 0x0074(a0)              // t8 = projectile position struct
        lwc1    f10, 0x002C(s0)             // ~
        lw      t9, 0x0080(t8)              // ~
        jal     0x80167FA0                  // ~
        swc1    f10, 0x0088(t9)             // ~

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        jr      ra
        addiu   sp, sp, 0x0050
    }

    // @ Description
    // Subroutine which sets up the initial properties for the projectile.
    scope egg_poop_stage_setting_: {
        addiu   sp, sp, -0x0050
        sw      s0, 0x0018(sp)
        li      s0, backward_egg_properties_struct   // s0 = projectile properties struct address
        sw      a1, 0x0034(sp)
        sw      a0, 0x0038(sp)
        sw      ra, 0x001C(sp)

        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, backward_egg_projectile_struct   // a1 = main projectile struct address
        lw      a2, 0x0034(sp)
        lui     a3, 0x8000
        sw      t6, 0x002C(sp)              // 0x002C(sp) = player struct
        jal     0x801655C8                  // This is a generic routine that does much of the work for defining all projectiles
        sw      t1, 0x000C(a1)

        beq     v0, r0, _end_stage_setting  // if 801655C8 returns 0, there's no space to create a new projectile object, so skip to end
        nop

        mtc1    r0, f4
        sw      v0, 0x0028(sp)              // 0x0028(sp) = projectile object
        lw      v1, 0x0084(v0)              // v1 = projectile struct

        sw      r0, 0x029C(v1)              // clear out some value used by fireball
        addiu   at, r0, 0x28                // fgm id
        sh      at, 0x0146(v1)              // save on hit fgm
        sw      r0, 0x010C(v1)              // set hitbox type to NORMAL

        lw      t3, 0x0000(s0)              // t3 = duration
        sw      t3, 0x0268(v1)              // store duration
        lw      t4, 0x002C(sp)              // t4 = player struct
        lw      t5, 0x014C(t4)              // t5 = kinetic state
        addiu   at, r0, 0x0001
        bnel    t5, at, _trajectory         // branch if player is grounded
        lwc1    f12, 0x0018(s0)
        beq     r0, r0, _trajectory
        lwc1    f12, 0x001C(s0)             // projectile direction =
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
        cvt.s.w f16, f10                    // ~
        mul.s   f18, f8, f16                // ~
        jal     0x800303F0                  // ~
        swc1    f18, 0x0020(v1)             // original logic


        lwc1    f4, 0x0020(s0)              // ~ load speed
        lw      v1, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        mul.s   f6, f0, f4                  // f6 = direction times speed
        swc1    f6, 0x0024(v1)              // ~ save new speed


        lw      t8, 0x0074(a0)              // t8 = projectile position struct
        lwc1    f10, 0x002C(s0)             // ~
        lw      t9, 0x0080(t8)              // ~
        jal     0x80167FA0                  // ~
        swc1    f10, 0x0088(t9)             // ~

        lw      v0, 0x0028(sp)              // original logic

        _end_stage_setting:
        lw      ra, 0x001C(sp)
        lw      s0, 0x0018(sp)
        jr      ra
        addiu   sp, sp, 0x0050
    }

    // @ Description
    // This subroutine destroys the needle and creates a smoke gfx.
    scope egg_destruction_: {
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
    // Subroutine which handles physics for the recoil.
    // Prevents player control when temp variable 2 = 0
    scope air_shoot_physics_: {
        // 0x180 in player struct = temp variable 1
        addiu   sp, sp,-0x0030              // allocate stack space
        sw    	ra, 0x0014(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        lui     t8, 0x800E                  // ~
        bnezl   t1, _subroutine             // skip if t1 != 0...
        addiu   t8, t8, 0x90E0              // ...and t8 = physics subroutine which allows player control

        addiu   t8, t8, 0x91EC              // t8 = physics subroutine which allows player control

        _subroutine:
        jalr    t8                          // run physics subroutine
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu 	sp, sp, 0x0030				// deallocate stack space
    }

    // @ Description
    // Collision subroutine for NSP_Ground_Shoot.
    scope ground_shoot_forward_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_shoot_forward_transition_   // a1(transition subroutine) = air_shoot_forward_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for NSP_Ground_Shoot.
    scope ground_shoot_backward_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_shoot_backward_transition_   // a1(transition subroutine) = air_shoot_backward_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // // @ Description
    // // Collision subroutine for Kirby's NSP_Ground_Shoot.
    // scope kirby_ground_shoot_collision_: {
        // addiu   sp, sp,-0x0018              // allocate stack space
        // sw      ra, 0x0014(sp)              // store ra
        // li      a1, air_shoot_transition_   // a1(transition subroutine) = air_shoot_transition_
        // jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        // nop
        // lw      ra, 0x0014(sp)              // load ra
        // jr      ra                          // return
        // addiu   sp, sp, 0x0018              // deallocate stack space
    // }

    // @ Description
    // Collision subroutine for NSP_Air_Shoot.
    scope air_shoot_forward_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_shoot_forward_transition_ // a1(transition subroutine) = ground_shoot_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for NSP_Air_Shoot.
    scope air_shoot_backward_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_shoot_backward_transition_ // a1(transition subroutine) = ground_shoot_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to NSP_Ground_Shoot.
    // Based on subroutine 0x8015D9B0, which is the transition subroutine for Samus' aerial neutral special shot.
    scope ground_shoot_forward_transition_: {
        // Copy the first 8 lines of subroutine 0x8015D9B0
        OS.copy_segment(0xD83F0, 0x20)

        lw      a2, 0x0084(a0)              // ~

        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPForwardG// a1(action id) = NSPForwardG
        lli     a1, Kirby.Action.BANJO_NSPForwardG// a1(action id) = Kirby NSPForwardG
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7

        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to NSP_Ground_Shoot.
    // Based on subroutine 0x8015D9B0, which is the transition subroutine for Samus' aerial neutral special shot.
    scope ground_shoot_backward_transition_: {
        // Copy the first 8 lines of subroutine 0x8015D9B0
        OS.copy_segment(0xD83F0, 0x20)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPBackwardG// a1(action id) = NSPBackwardG
        lli     a1, Kirby.Action.BANJO_NSPBackwardG// a1(action id) = Kirby NSPBackwardG
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7

        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Subroutine which transitions to NSP_Air_Shoot.
    // Based on subroutine 0x8015DA04, which is the transition subroutine for Samus' aerial neutral special shot.
    scope air_shoot_forward_transition_: {
        // Copy the first 8 lines of subroutine 0x8015DA04
        OS.copy_segment(0xD8444, 0x20)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPForwardA// a1(action id) = NSPForwardA
        lli     a1, Kirby.Action.BANJO_NSPForwardA// a1(action id) = Kirby NSPForwardA
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7

        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }


    // @ Description
    // Subroutine which transitions to NSP_Air_Shoot.
    // Based on subroutine 0x8015DA04, which is the transition subroutine for Samus' aerial neutral special shot.
    scope air_shoot_backward_transition_: {
        // Copy the first 8 lines of subroutine 0x8015DA04
        OS.copy_segment(0xD8444, 0x20)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.BANJO      // a1 = id.BANJO
        beql    a1, a2, _change_action      // if Banjo, load action ID
        lli     a1, Banjo.Action.NSPBackwardA// a1(action id) = NSPBackwardA
        lli     a1, Kirby.Action.BANJO_NSPBackwardA// a1(action id) = Kirby NSPBackwardA
        _change_action:
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7

        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Main subroutine for the needles.
    scope forward_egg_main_: {
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
        li      v0, forward_egg_properties_struct // v0 = needle properties struct
        lw      a1, 0x000C(v0)              // a1 = gravity
        jal     0x80168088                  // apply gravity to egg
        lw      a2, 0x0004(v0)              // a2 = max speed
        lw      a0, 0x001C(sp)              // a0 = projectile struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile struct with coordinates/rotation etc (bone struct?)
        li      at, forward_egg_properties_struct   // at = needle properties struct
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        // update rotation
        lw      t0, 0x0014(at)              // at = rotation speed
        lwc1    f4, 0x0030(v1)             // f4 = current rotation
        mtc1    t0, f6
        add.s   f8, f4, f6                  // current rotation += rotation speed

        swc1    f8, 0x0030(v1)              // update new rotation

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Main subroutine for the bouncing egg
    // Marios fireball routine = 0x80168540
    scope backward_egg_main_: {
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
        li      v0, backward_egg_properties_struct // v0 = egg properties struct
        lw      a1, 0x000C(v0)              // a1 = gravity
        jal     0x80168088                  // apply gravity to egg
        lw      a2, 0x0004(v0)              // a2 = max speed
        lw      a0, 0x001C(sp)              // a0 = projectile struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile struct with coordinates/rotation etc (bone struct?)
        li      at, backward_egg_properties_struct   // at = egg properties struct
        lli     v0, OS.FALSE                // return FALSE (don't destroy)

        // update rotation
        lw      t0, 0x0014(at)              // at = rotation speed
        lwc1    f4, 0x0030(v1)              // f4 = current rotation
        mtc1    t0, f6
        add.s   f8, f4, f6                  // current rotation += rotation speed

        swc1    f8, 0x0030(v1)              // update new rotation

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    constant EGG_ID(0x1008)

    OS.align(16)
    forward_egg_projectile_struct:
    dw 0x00000000                           // unknown
    dw EGG_ID                               // projectile id
    dw Character.BANJO_file_9_ptr           // address of Banjo's file 8 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
    dw forward_egg_main_                    // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0x80175914                           // This function runs when the projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw egg_destruction_                     // This function runs when the projectile collides with a hurtbox.
    dw egg_destruction_                     // This function runs when the projectile collides with a shield.
    dw 0x8016DD2C                           // This function runs when the projectile collides with edges of a shield and bounces off
    dw egg_destruction_                     // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x801692C4                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw egg_destruction_                     // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    forward_egg_properties_struct:
    dw EGG_DURATION                      // 0x0000 - duration (int)
    float32 250                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0.1                             // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.15                            // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (grounded)
    float32 0                               // 0x001C   initial angle (aerial) 0xbf490fd8, 45 deg
    float32 90                              // 0x0020   initial speed
    dw Character.BANJO_file_9_ptr           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)

    OS.align(16)
    backward_egg_projectile_struct:
    dw 0x00000000                           // unknown
    dw EGG_ID                               // projectile id
    dw Character.BANJO_file_9_ptr           // address of Banjo's file 8 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
    dw backward_egg_main_                    // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw 0x801685F0                           // if projectile collides with clipping. (0x801685F0 - Mario) (0x80169108 - Samus)
    dw egg_destruction_                     // if projectile collides with a hurtbox.
    dw egg_destruction_                     // if projectile collides with a shield.
    dw 0x8016DD2C                           // if projectile collides with edges of a shield and bounces off
    dw egg_destruction_                     // if projectile collides/clangs with a hitbox.
    dw 0x801692C4                           // if projectile collides with Fox's reflector (default 0x80168748)
    dw egg_destruction_                     // if projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    backward_egg_properties_struct:
    dw BACKWARD_EGG_DURATION                // 0x0000 - duration (int)
    float32 250                             // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 1.2                             // 0x000C - gravity
    float32 0.9                             // 0x0010 - bounce multiplier
    float32 0.1                             // 0x0014 - rotation speed
    float32 128                             // 0x0018 - initial angle (grounded)
    float32 128                             // 0x001C   initial angle (aerial) 0xbf490fd8, 45 deg
    float32 28                              // 0x0020   initial speed
    dw Character.BANJO_file_9_ptr           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)

}

// @ Description
// Subroutines for Up Special
scope BanjoUSP {
    constant Y_SPEED(0x42CA)                // current setting - float:101.0
    constant Y_SPEED_AIR(0x42B4)            // current setting - float:90.0
    constant X_SPEED_BACK(0xC1A0)           // current setting - float:-30.0
    constant Y_SPEED_ATTACK(0x0000)         // current setting - float: 0.0
    constant X_SPEED_ATTACK(0x42A0)         // current setting - float: 80.0
    constant LANDING_FSM(0x3F80)            // current setting - float:1.0
    constant BEGIN_LANDING_FSM(0x4000)      // current setting - float:1.5
    constant B_PRESSED(0x40)                // bitmask for b press
    constant RECOIL_X_SPEED(0xC1A0)         // current setting - float:-20
    constant RECOIL_Y_SPEED(0x4240)         // current setting - float:48
    constant SPLAT_X_SPEED(0xC170)         // current setting - float:-15
    constant SPLAT_Y_SPEED(0x40A0)         // current setting - float:5

    constant WALL_COLLISION_L(0x0001)       // bitmask for wall collision
    constant WALL_COLLISION_R(0x0020)       // bitmask for wall collision

    // @ Description
    // Subroutine which runs when Banjo initiates an up special (both ground/air).
    // Changes action, and sets up initial variable values.
    scope initial_: {
        addiu   sp, sp, -0x0028             // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        sw      a0, 0x0024(sp)

        bnezl   t7, _change_action          // skip if kinetic state !grounded
        sw      r0, 0x0B2C(a0)

        addiu   t0, r0, 0x0001
        jal     0x800DEEC8                  // set aerial state
        sw      t0, 0x0B2C(a0)

        _change_action:
        lw      t8, 0x0024(sp)
        lui     t7, 0x8016
        addiu   t7, t7, 0x05FC
        sw      t7, 0x0A0C(t8)
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, Banjo.Action.USPBegin // a1(action id) = USPBegin
        or      a2, r0, r0                  // a2 = float: 0.0

        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0

        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // reset button_press_buffer

        jal     0x800E0830                  // common subroutine, sets jumps
        lw      a0, 0x000(sp)               // load player object

        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0028              // ~

        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Deals with transition to part 2 of action
    scope usp_transition_attack_: {
        addiu   sp, sp, -0x0020             // ~
        sw      ra, 0x001C(sp)              // ~
        addiu	t6, r0, 0x0003
		sw		a0, 0x0020(sp)
		sw		t6, 0x0010(sp)
		addiu	a1, r0, Banjo.Action.USPAttack // insert action in a1
		addiu	a2, r0, 0x0000

        lw      t0, 0x0084(a0)              // load player struct
        sw      r0, 0x017C(t0)              // temp variable 1 = 0
        sw      r0, 0x0180(t0)              // temp variable 2 = 0
        sw      r0, 0x0184(t0)              // temp variable 3 = 0

        jal		0x800E6F24					// change action routine
		lui		a3, 0x3f80

        jal		0x800E0830
		lw		a0, 0x0020(sp)

        jal		0x8015BFBC
		lw		a0, 0x0020(sp)

        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~

        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which begins Banjo's up special attack ending action.
    scope attack_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Banjo.Action.USPAttackEnd // a1(action id) = USPAttackEnd
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.25
        lwc1    f2, 0x0048(a0)              // f2 = x velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x0048(a0)              // multiply x velocity by 0.25 and update
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions into Banjos up special recoil action.
    scope begin_recoil_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _end                    // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop

        _end:
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        ori     a1, r0, Banjo.Action.USPRecoil
        or      a2, r0, r0                  // a2 = 0(begin action frame)
        sw      t7, 0x0010(sp)              // store t7 (some kind of parameter for change action)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }

    // @ Description
    // Initial function for Banjos's up special wall splat.
    // Based on a Ness function, but I forgot to write down what it was OOPS!
    // Okay fine, here it is 0x80155114
    scope wall_splat_initial_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra
        sw      s0, 0x0020(sp)              // store s0
        sw      a0, 0x0038(sp)              // ~
        sw      a1, 0x003C(sp)              // ~
        sw      a2, 0x0040(sp)              // ~
        lw      s0, 0x0084(a0)              // original logic
        or      a2, r0, r0                  // a2  = 0
        addiu   a1, r0, Banjo.Action.USPWallSplat // a1 = Action.USPWallSplat
        lui     a3, 0x3F80                  // a3 = 1.0
        lw      a0, 0x0038(sp)              // a0 = player object
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // ~
        lw      a0, 0x0038(sp)              // ~
        lw      v0, 0x003C(sp)              // ~
        lwc1    f12, 0x0000(v0)             // ~
        lwc1    f14, 0x0004(v0)             // ~
        jal     0x8001863C                  // ~
        neg.s   f12, f12                    // ~
        mfc1    a2, f0                      // ~
        lw      a0, 0x0040(sp)              // original logic

        // the original function has this hook here so we'll have it too
        jal     Size.ground_gfx.save_player_struct_._wall_bounce

        addiu   a1, r0, 0x0004              // ~
        jal     0x801008F4                  // ~
        addiu   a0, r0, 0x0002              // original logic
        lui     at, SPLAT_Y_SPEED           // t1 = RECOIL_Y_SPEED
        sw      at, 0x004C(s0)              // y velocity = RECOIL_Y_SPEED
        lw      ra, 0x0024(sp)              // load ra
        sw      r0, 0x0048(s0)              // x velocity = 0
        sw      r0, 0x017C(s0)              // ~
        sw      r0, 0x0180(s0)              // ~
        sw      r0, 0x0184(s0)              // reset temp variables
        lw      s0, 0x0020(sp)              // load s0
        jr      ra                          // return
        addiu   sp, sp, 0x0050              // deallocate stack space
    }

    // @ Description
    // Main subroutine for Banjo's up special begin.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    scope begin_main_: {
        addiu   sp, sp, -0x0028              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0004(sp)

        _update_buffer:
        lw      a2, 0x0084(a0)              // a2 = player struct
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lw      t2, 0x0B18(a2)              // t2 = button_press_buffer
        or      t1, t1, t2                  // t1 = button_pressed | button_press_buffer
        sw      t1, 0x0B18(a2)              // update button_press_buffer with current inputs
        sw      t1, 0x0018(sp)              // save button_pressed to stack

		lui		at, 0x4120					// at = 10.0
		mtc1    at, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1tl   _animation                  // skip if haven't reached frame 8
        nop

		lw      t3, 0x0018(sp)              // load button press buffer
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _animation          // skip if (!B_PRESSED)
        nop

		sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE

        jal		usp_transition_attack_
		nop

        beq     r0, r0, _end
        nop


        _animation:
        lw      a0, 0x0004(sp)
        mtc1           r0, f4
        c.le.s         f8, f4
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        lui     a1, 0x3F80                  // a1 (air speed multiplier) = 1
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, BEGIN_LANDING_FSM       // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM

		_end:
        lw      ra, 0x0024(sp)              // ~
        addiu   sp, sp, 0x0028              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Main subroutine for Banjo's up special attack.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    scope attack_main_: {
        addiu   sp, sp, -0x0028
        sw      ra, 0x0024 (sp)
        lwc1    f6, 0x0078 (a0)
        lui     t5, 0x421C
        mtc1    t5, f4
        lui     a1, 0x3F80
        or      a2, r0, r0
        c.eq.s  f6, f4
        addiu   a3, r0, 0x0001
        lui     at, 0x8019
        addiu   t6, r0, 0x0001
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra

        jal     attack_end_initial_         // transition to USPAttackEnd
        nop

        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for USPAttackEnd.
    // Transitions to special fall on animation end.
    scope attack_end_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // store a0, ra

        // checks the current animation frame to see if we've reached end of the animation
        lw      a0, 0x0028(sp)              // a0 = player object
        lwc1    f6, 0x0078(a0)              // ~
        mtc1    r0, f4                      // ~
        c.le.s  f6, f4                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        lw      ra, 0x0024(sp)              // restore ra

        // begin a special fall if the end of the animation has been reached
        lui     a1, 0x3F80                  // a1 (air speed multiplier) = 1
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra

        _end:
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for Banjo's up special wall splat.
    scope wall_splat_main_: {
        addiu   sp, sp, -0x0038             // allocate stack space
        sw      ra, 0x0020(sp)              // store ra

        _check_ending:
        lwc1    f8, 0x0078(a0)              // ~
        mtc1    r0, f4                      // ~
        c.le.s  f8, f4                      // ~
        nop
        bc1fl   _apply_interpolation        // branch if animation end has not been reached
        nop


        _change_action:
        lui     a1, 0x3F80                  // a1 (air speed multiplier) = 1
        or      a2, r0, r0                  // a2 (unknown) = 0
        lli     a3, 0x0001                  // a3 (unknown) = 1
        sw      r0, 0x0010(sp)              // unknown argument = 0
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        lui     t6, BEGIN_LANDING_FSM       // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        b       _end                        // branch to end
        nop

        _apply_interpolation:
        // interpolate the x rotation back towards 0
        lw      a1, 0x0074(a0)              // a1 = topjoint struct
        lw      a2, 0x0084(a0)              // a2 = player struct
        lwc1    f2, 0x0030(a1)              // f2 = x rotation
        lui     at, 0x3F68                  // at = 0.90625
        mtc1    at, f4                      // f4 = ~0.9
        mul.s   f2, f2, f4                  // f4 = x rotation * ~0.9
        // if temp variable 1 is set, store updated x rotation
        lw      t6, 0x017C(a2)              // t6 = temp variable 1
        bnezl   t6, _end                    // branch if temp variable 1 is set...
        swc1    f2, 0x0030(a1)              // ...and store updated x rotation

		_end:
        lw      ra, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0038              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which allows a direction change for Banjo's up special and also checks to see if there is a collision with a hurtbox.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x2 = change direction
    scope attack_interupt_: {
        // 0x180 in player struct = temp variable 2
        lw      a1, 0x0084(a0)              // a1 = player struct
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store t0, t1, ra
        sw      a0, 0x0014(sp)
        lw      t0, 0x0180(a1)              // t0 = temp variable 2
        ori     t1, r0, 0x0002              // t1 = 0x2
        bne     t1, t0, _recoil             // skip if temp variable 2 != 2
        nop
        jal     0x80160370                  // turn subroutine (copied from captain falcon)
        nop

        _recoil:
        jal     check_recoil_
        lw      a0, 0x0014(sp)

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles hitbox collision for Banjo's up special.
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
        jal     begin_recoil_               // transition to recoil action
        nop
        lw      a0, 0x000C(sp)              // load a0
        lw      t0, 0x0084(a0)              // t0 = player struct
        sw      r0, 0x0180(t0)              // temp variable 2 = 0
        // initial x velocity
        lui     t1, RECOIL_X_SPEED          // ~
        mtc1    t1, f0                      // f0 = RECOIL_X_SPEED
        lwc1    f2, 0x0044(t0)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = RECOIL_X_SPEED * DIRECTION
        swc1    f0, 0x0048(t0)              // x velocity = RECOIL_X_SPEED * DIRECTION
        // initial y velocity
        lui     t1, RECOIL_Y_SPEED          // t1 = RECOIL_Y_SPEED
        sw      t1, 0x004C(t0)              // y velocity = RECOIL_Y_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      a0, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // ~
        lwc1    f0, 0x0018(sp)              // ~
        lwc1    f2, 0x001C(sp)              // load t0, t1, ra, f0, f2
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which sets up the movement for the Up Special recoil.
    // Uses the moveset data command 580000XX (orignally identified as "set flag" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // Variable values used by this subroutine:
    // 0x1 = end special movement
    scope recoil_move_: {
        // a2 = player struct
        // 0x180 in player struct = temp variable 2

        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        swc1    f0, 0x000C(sp)              // ~
        swc1    f2, 0x0010(sp)              // store t0, f0, f2

        _check_movement:
        lw      t0, 0x017C(a2)              // t0 = temp variable 1
        bnez    t0, _end                    // skip if t0 > 0
        nop
        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F78                  // ~
        mtc1    t0, f2                      // f2 = 0.96875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.96875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.96875)
        // slow falling speed
        lw      t0, 0x0008(a2)              // t0 = character id
        lui     t0, 0x3FA0                  // t0 = 1.25

        _modify_y_velocity:
        mtc1    t0, f0                      // f0 = 1.25/0.55
        lwc1    f2, 0x004C(a2)              // f2 = y velocity
        add.s   f0, f2, f0                  // f0 = y velocity + 1.25/0.55
        swc1    f0, 0x004C(a2)              // store updated y velocity
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lwc1    f0, 0x000C(sp)              // ~
        lwc1    f2, 0x0010(sp)              // load t0, t1, f0, f2
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles movement for Banjo's up special begin.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = end movement?
    scope begin_physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        constant BEGIN(0x0)
        constant BEGIN_MOVE(0x1)
        constant MOVE(0x2)
        constant END_MOVE(0x3)
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      a0, 0x0020(sp)

        lw             s0, 0x0084 (a0)      // load player struct
        lw             t6, 0x018c (s0)      // load bitfield
        lw             s1, 0x09c8 (s0)      // load attribute pointer
        or             a0, s0, r0           // place player struct in a0
        sll            t8, t6, 12           // shift bitfield status

        bgez           t8, _branch_1
        or             a1, s1, r0

        jal            0x800d8da0
        or             a0, s0, r0

        b              _branch_2
        or             a0, s0, r0

        _branch_1:
        jal            0x800d8e50           // set aerial vertical velocity
        or             a1, s1, r0
        or             a0, s0, r0

        _branch_2:
        bnez    v0, _check_begin            // modified original branch
        nop


        _continue:
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct

        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

        _check_begin:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
        nop
        // stop movement
        // freeze x position
        sw      r0, 0x0048(s0)              // x velocity = 0
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_begin_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != BEGIN_MOVE
        nop

        // initialize x/y velocity
        lw      t7, 0x0B2C(s0)              // t7 = grounded flag
        beqzl   t7, _air                    // skip if !grounded
        lui     t0, Y_SPEED_AIR             // ~

        lui     t0, Y_SPEED                 // ~

        _air:
        mtc1    t0, f4                      // f4 = Y_SPEED
        nop                                 // ~

        _apply_movement:
        // f2 = x velocity
        // f4 = y velocity
        swc1    f4, 0x004C(s0)              // store y velocity
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        // take mid-air jumps away at this point
        lw      t0, 0x09C8(s0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(s0)              // jumps used = max jump
        b       _end                        // end
        nop

        _end:
        lw      a0, 0x0020(sp)              // a0 = player ojbect
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800D9044                  // handle air control
        lw      a1, 0x09C8(a0)              // a1 = attribute pointer
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // original load registers
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles movement for Banjo's up special attack.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = end movement?
    scope attack_physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        constant BEGIN(0x0)
        constant REAR_BACK(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)
        constant SLOW(0x4)
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers


        lw             s0, 0x0084 (a0)      // load player struct
        lw             t6, 0x018c (s0)      // load bitfield
        lw             s1, 0x09c8 (s0)      // load attribute pointer
        or             a0, s0, r0           // place player struct in a0
        sll            t8, t6, 12           // shift bitfield status

        bgez           t8, _branch_1
        or             a1, s1, r0

        jal            0x800d8da0
        or             a0, s0, r0

        b              _branch_2
        or             a0, s0, r0

        _branch_1:
        jal            0x800d8e50           // set aerial vertical velocity
        or             a1, s1, r0
        or             a0, s0, r0

        _branch_2:
        //jal            0x800d8fa8
        //or             a1, s1, r0

        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3

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
        bne     t0, t1, _check_rear_back   // skip if temp variable 3 != BEGIN
        nop
        // freeze x position
        sw      r0, 0x0048(s0)              // x velocity = 0
		// freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

        _check_rear_back:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, REAR_BACK           // t1 = REAR_BACK
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != REAR_BACK
        nop

        lui     t0, X_SPEED_BACK          // ~
        mtc1	t0, f4						// put default X speed into f4
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f4, f0, f4                  // f2 = x velocity * direction
        sw      r0, 0x004C(s0)              // store y velocity
        swc1    f4, 0x0048(s0)              // store x velocity

        beq     r0, r0, _negate
        nop

        _check_begin_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN_MOVE          // t1 = BEGIN_MOVE
        bne     t0, t1, _check_move         // skip if temp variable 3 != REAR_BACK
        nop

        // initialize x/y velocity
        lui		t0, Y_SPEED_ATTACK  		// load default y speed
        mtc1    t0, f2                      // f2 = Y_SPEED
        lui     t0, X_SPEED_ATTACK          // ~
        mtc1	t0, f4						// put default X speed into f4

        _apply_movement:
        // f4 = x velocity
        // f2 = y velocity
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f4, f0, f4                  // f2 = x velocity * direction
        swc1    f2, 0x004C(s0)              // store y velocity
        swc1    f4, 0x0048(s0)              // store x velocity
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE

        _check_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _end         // skip if temp variable 3 != MOVE
        nop

        // update y velocity to negate gravity
        _negate:
        lwc1    f0, 0x0058(s1)              // f0 = gravity
        lwc1    f2, 0x004C(s0)              // f2 = y velocity
        add.s   f2, f2, f0                  // f2 = y velocity + GRAVITY
        swc1    f2, 0x004C(s0)              // store updated y velocity

        //_check_slow:
        //lw      t0, 0x0184(s0)              // t0 = temp variable 3
        //ori     t1, r0, SLOW                // t1 = SLOW
        //bne     t0, t1, _end                // skip if temp variable 3 != SLOW
        //nop
        //
        //// slow x movement
        //lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        //lui     t0, 0x3f73                  // ~
        //mtc1    t0, f2                      // f2 = 0.95
        //mul.s   f0, f0, f2                  // f0 = x velocity * 0.95
        //swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.95)

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // original load registers
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for the recoil.
    // Prevents player control when temp variable 1 = 0
    scope recoil_physics_: {
        // 0x17C in player struct = temp variable 1
        addiu   sp, sp,-0x0030              // allocate stack space
        sw    	ra, 0x0014(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x017C(t0)              // t1 = temp variable 1
        lui     t8, 0x800E                  // ~
        bnezl   t1, _subroutine             // skip if t1 != 0...
        addiu   t8, t8, 0x90E0              // ...and t8 = physics subroutine which allows player control

        addiu   t8, t8, 0x91EC              // t8 = physics subroutine which allows player control

        _subroutine:
        jalr    t8                          // run physics subroutine
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu 	sp, sp, 0x0030				// deallocate stack space
    }

    // @ Description
    // Subroutine which handles physics for the splat.
    // Wrapped version of recoil_physics_
    // Also applies SPLAT_X_SPEED
    scope splat_physics_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw    	ra, 0x0014(sp)              // ra
        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      t6, 0x0184(a1)              // t6 = temp variable 3
        beqz    t6, _end                    // branch if temp variable 3 not set
        lui     at, SPLAT_X_SPEED           // at = SPLAT_X_SPEED

        // if temp variable 3 is set
        sw      r0, 0x0184(a1)              // reset temp variable 3
        mtc1    at, f2                      // f2 = SPLAT_X_SPEED
        lwc1    f4, 0x0044(a1)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = SPLAT_X_SPEED * DIRECTION
        swc1    f2, 0x0048(a1)              // update x velocity

        _end:
        jal     recoil_physics_             // run recoil_physics_
        nop

        lw      ra, 0x0014(sp)              // load ra
        addiu 	sp, sp, 0x0020				// deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for Banjos's up special beginning.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Banjo.
    scope begin_collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, BEGIN_LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }

    // @ Description
    // Collision subroutine for USPAttack.
    scope attack_collision_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        jal     collision_                  // run normal up special collision function first
        sw      a0, 0x0018(sp)              // store a0

        lw      a0, 0x0018(sp)              // ~
        lw      t6, 0x0084(a0)              // t6 = player struct
        lw      t7, 0x0184(t6)              // t7 = temp variable 3
        lli     at, attack_physics_.MOVE    // at = MOVE
        bne     t7, at, _end                // skip if temp variable 3 != MOVE
        nop
        lhu     a1, 0x00CC(t6)              // a1 = collision flags
        lw      t1, 0x0044(t6)              // t0 = direction
        bgezl   t1, _check_collision_l      // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L

        b       _check_collision_r          // check right facing wall collisions
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _check_collision_l:
        beql    a1, r0, _end                // skip if !WALL_COLLISION
        nop

        // if Banjo is colliding with a wall, SPLAT
        lw      a1, 0x0074(a0)              // ~
        lwc1    f2, 0x001C(a1)              // ~
        swc1    f2, 0x0020(sp)              // store x position
        lwc1    f6, 0x0020(a1)              // ~
        swc1    f6, 0x0024(sp)              // store y position
        sw      r0, 0x0028(sp)              // whatever dude make the z position 0
        addiu   a1, t6, 0x0120              // a1 = clipping angles?
        sw      a1, 0x001C(sp)              // store a1
        jal     wall_splat_initial_
        addiu   a2, sp, 0x0020              // a2 = x/y/z coordinates
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0074(a0)              // t6 = topjoint struct
        lw      a1, 0x001C(sp)              // a1 = clipping angles?
        lw      t6, 0x0004(a1)              // t6 = relevant wall angle
        sw      t6, 0x0030(a0)              // set banjo's angle to wall angle
        b       _end                        // branch end
        nop

        _check_collision_r:
        beql    a1, r0, _end                // skip if !WALL_COLLISION
        nop

        // if Banjo is colliding with a wall, SPLAT
        lw      a1, 0x0074(a0)              // ~
        lwc1    f2, 0x001C(a1)              // ~
        swc1    f2, 0x0020(sp)              // store x position
        lwc1    f6, 0x0020(a1)              // ~
        swc1    f6, 0x0024(sp)              // store y position
        sw      r0, 0x0028(sp)              // whatever dude make the z position 0
        addiu   a1, t6, 0x0134              // a1 = clipping angles?
        sw      a1, 0x001C(sp)              // store a1
        jal     wall_splat_initial_
        addiu   a2, sp, 0x0020              // a2 = x/y/z coordinates
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0074(a0)              // t6 = topjoint struct
        lw      a1, 0x001C(sp)              // a1 = clipping angles?
        lw      t6, 0x0004(a1)              // t6 = relevant wall angle
        sw      t6, 0x0030(a0)              // set banjo's angle to wall angle

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for Banjos's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Banjo.
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
scope BanjoDSP {
    constant AERIAL_INITIAL_Y_SPEED(0x4100) // DSP rise
    constant Y_SPEED(0xC2DC)                // current setting - float:-110.0
    constant INITIAL_Y_SPEED(0x4334)        // current setting - float:180.0
    constant INITIAL_X_SPEED(0x42B4)        // current setting - float:90.0

    constant BEGIN(0x1)
    constant MOVE(0x2)

    // @ Description
    // Subroutine which runs when Banjo initiates a grounded down special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      r0, 0x0010(sp)              // original begin logic
        ori     a1, r0, Banjo.Action.DSPG   // a1 = action id: Banjo DSP Ground
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
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
    // Subroutine which runs when Banjo initiates an aerial down special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0008              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, Banjo.Action.DSPA   // a1 = action id: Banjo DSP Ground
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
        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }

    // Main subroutine for DSPA
    scope aerial_main_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      t8, 0x014C(a2)              // t8 = kinetic state
        li      a1, loop_initial_           // a1(transition subroutine) = loop_initial_
        jal     0x800D9480                  // common main subroutine (transition on animation end)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the movement for the grounded version of Banjo's down special.
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
    // Subroutine which sets up the movement for the aerial version of Banjo's down special.
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
    // Subroutine which handles physics for Banjo's down special.
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
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop

        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
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

        _check_move:
        lw      t0, 0x0024(a0)              // action id
        addiu   at, r0, Banjo.Action.DSPALoop
        beq     at, t0, _moving_down        // branch if in DSPALoop
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _apply_y_speed      // skip if t0 != MOVE
        lui     t1, AERIAL_INITIAL_Y_SPEED  // moving up y speed
        _moving_down:
        lui     t1, Y_SPEED                 // moving down y speed
        _apply_y_speed:
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
    // Subroutine which handles collision for Banjo's down special.
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
        ori     t0, r0, MOVE                // a1 = MOVE
        beq     t0, v0, _main_collision     // branch if temp variable 3 = MOVE
        addiu   at, r0, Banjo.Action.DSPALoop
        lw      v1, 0x0024(a1)              // current action
        beq     at, v1, _main_collision     // branch if doing aerial loop action
        nop

        // If Banjo is not in the ground pound motion, run a normal aerial collision subroutine
        // instead.
        jal     0x800DE99C                  // aerial collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _main_collision:
        li      a1, begin_landing_          // a1 = begin_landing_
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
    // Initial for Banjo's DSP loop
    // Changes action, and sets up initial variable values.
    scope loop_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0001              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, Banjo.Action.DSPALoop   // a1 = action id: Banjo DSPA Loop
        ori     a2, r0, 0x0000              // a2 = 0 (begin action frame)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a2 = float: 1.0
        jal     0x800E0830                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // unknown original subroutine
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 2 = 0
        lw      ra, 0x001C(sp)              // ~
        jr      ra                          // original return logic
        addiu   sp, sp, 0x0020              // ~
    }

    // @ Description
    // Subroutine which transitions into the landing action for Banjo's down special.
    // Copy of subroutine 0x801600EC, which begins the landing action for Falcon Kick.
    // Loads the appropriate landing action for Banjo.
    scope begin_landing_: {
        // Copy the first 6 lines of subroutine 0x801600EC
        OS.copy_segment(0xDAB2C, 0x18)
        // Replace original line which loads the landing action id
        // addiu   a1, r0, 0x00E8           // replaced line
        addiu   a1, r0, Banjo.Action.DSPLand    // a1 = action id: Banjo DSP Landing
        // Copy the last 8 lines of subroutine 0x801600EC
        OS.copy_segment(0xDAB48, 0x20)
    }

    // @ Description
    // Collision routine for grounded down special
    // Copy of subroutine 0x8015FF88, which is the collision action for Falcon Kick.
    scope grounded_collision_: {
        addiu          sp, sp, -0x18
        sw             ra, 0x0014 (sp)

        jal            0x8015fce8
        sw             a0, 0x0018 (sp)

        jal            0x8015feb4
        lw             a0, 0x0018 (sp)
        bnezl          v0, _end
        lw             ra, 0x0014 (sp)

        jal            BanjoDSP.status_check_
        lw             a0, 0x0018 (sp)

        lw             ra, 0x0014 (sp)

        _end:
        addiu          sp, sp, 0x18
        jr             ra
        nop
    }

    // @ Description
    // Collision subroutine for grounded down special
    // Copy of subroutine 0x8015FF2C, which checks to see if a moveset variable flag has been placed and if falcon is aerial
    scope status_check_: {
        addiu          sp, sp, -0x20
        sw             ra, 0x0014 (sp)
        lw             v1, 0x0084 (a0)
        addiu          at, r0, 0x0001
        or             v0, r0, r0
        lw             t6, 0x0180 (v1)      // load moveset flag

        bne            t6, at, _end         // skip to end if moveset flag isn't active
        nop

        lw             t7, 0x014c (v1)      // load kinetic state
        addiu          at, r0, 0x0001

        bnel           t7, at, _end         // branch to end if on ground
        nop

        jal            BanjoDSP.action_change_
        sw             v1, 0x001c (sp)

        lw             v1, 0x001c (sp)
        addiu          v0, r0, 0x0001
        b              _end
        nop
        nop

        _end:
        lw             ra, 0x0014 (sp)
        addiu          sp, sp, 0x20
        jr             ra
        nop
    }

    // @ Description
    // Collision subroutine for grounded down special
    // Copy of subroutine 0x80160060, which will change the action falcon transitions to if he is airborne during grounded falcon kick.
    scope action_change_: {
        addiu          sp, sp, -0x30
        sw             ra, 0x0024 (sp)
        sw             s0, 0x0020 (sp)
        sw             a0, 0x0030 (sp)
        lw             s0, 0x0084 (a0)
        lw             t7, 0x08e8 (s0)
        or             a0, s0, r0
        lwc1           f4, 0x0038 (t7)

        jal            0x800deec8
        swc1           f4, 0x0028 (sp)

        addiu          t8, r0, 0x0004
        sw             t8, 0x0010 (sp)
        lw             a0, 0x0030 (sp)
        addiu          a1, r0, Banjo.Action.DSPGAir   // Fall aerial action
        addiu          a2, r0, 0x0000

        jal            0x800e6f24       // change action
        lui            a3, 0x3f80

        lwc1           f6, 0x0028 (sp)
        lw             t9, 0x08e8 (s0)
        lui            t2, 0x800f
        lui            t3, 0x800f
        swc1           f6, 0x0038 (t9)
        lw             t0, 0x08e8 (s0)
        addiu          t2, t2, 0x9c8c
        lwc1           f8, 0x0038 (t0)
        addiu          t3, t3, 0x9cc4
        sw             t2, 0x0a04 (s0)
        sw             t3, 0x0a08 (s0)
        lw             ra, 0x0024 (sp)
        lw             s0, 0x0020 (sp)

        addiu          sp, sp, 0x30
        jr             ra
        nop
    }
}