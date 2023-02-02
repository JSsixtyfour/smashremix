// Mewtwo.asm

// This file contains subroutines used by Mewtwo's special moves.

scope MewtwoNSP {
    constant SHOOT_X_SPEED(0x40A0)          // current setting: float 5.0

    // @ Description
    // Subroutine which runs when Mewtwo initiates a grounded neutral special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Begin
        
        lli     a1, 0x00DE                  // a1(action id) = NSP_Ground_Begin 
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Mewtwo initiates an aerial neutral special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Begin
        
        lli     a1, 0x00E1                  // a1(action id) = NSP_Air_Begin
        jal     begin_initial_              // begin_initial_
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine for when Mewtwo initiates a neutral special.
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
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        jal     0x801576B4                  // kirby's on hit subroutine setup
        or      a0, s0, r0                  // a0 = player struct
        b       _continue                   // branch
        nop
        
        _mewtwo:
        jal     0x8015DB4C                  // on hit subroutine setup
        or      a0, s0, r0                  // a0 = player struct
        
        _continue:
        lw      at, 0x0008(s0)              // at = current character ID
        lli     t7, Character.id.KIRBY      // t7 = id.KIRBY
        beql    t7, at, pc() + 24           // if Kirby, load Kirby charge level
        lw      t7, 0x0AE0(s0)              // t7 = charge level
        lli     t7, Character.id.JKIRBY     // t7 = id.JKIRBY
        beql    t7, at, pc() + 12           // if J Kirby, load Kirby charge level
        lw      t7, 0x0AE0(s0)              // t7 = charge level
        
        lw      t7, 0x0ADC(s0)              // t7 = charge level
        lli     at, 0x0007                  // at = 0x0007
        lli     t8, 0x0001                  // t8 = 0x0001
        bnel    t7, at, _end                // end if charge level != 7(max)
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
        jal     attach_shadow_ball_         // attach_shadow_ball_
        nop
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
        jal     attach_shadow_ball_         // attach_shadow_ball_
        nop
        jal     ground_shoot_initial_       // ground_shoot_initial_
        lw      a0, 0x0030(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        
        _end:
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
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
        lli     a1, Kirby.Action.MTWO_NSP_Air_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Begin
        
        lli     a1, 0x00E1                  // a1(action id) = NSP_Air_Begin
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0002
        
        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
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
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Begin
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Begin
        
        lli     a1, 0x00DE                  // a1(action id) = NSP_Ground_Begin
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
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
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
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Charge
        
        lli     a1, 0x00DF                  // a1(action id) = NSP_Ground_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     attach_shadow_ball_         // attach_shadow_ball_
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
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Charge
        
        lli     a1, 0x00E2                  // a1(action id) = NSP_Air_Charge
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0002                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     attach_shadow_ball_         // attach_shadow_ball_
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which attaches a shadow ball to mewtwo's hand.
    // a0 - player object
    scope attach_shadow_ball_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      s0, 0x0020(sp)              // ~
        sw      ra, 0x0024(sp)              // ~
        sw      a0, 0x0038(sp)              // store s0, ra, a0
        lw      s0, 0x0084(a0)              // s0 = player struct 
        
        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _continue                   // branch
        nop
        
        _mewtwo:
        li      t7, 0x8015D338              // t7 = on hit subroutine
        
        _continue:
        sw      t7, 0x09EC(s0)              // store on hit subroutine in player struct
        lli     t8, 0x0014                  // t8 = maybe a timer?
        sw      t8, 0x0B1C(s0)              // store unknown variable
        or      a0, s0, r0                  // a0 = player struct
        jal     0x8015D35C                  // get part position
        addiu   a1, sp, 0x0028              // a1 = address to return x/y/z coordinates to
        lw      a0, 0x0038(sp)              // a0 = player object
        addiu   a1, sp, 0x0028              // x/y/z coordinates
        
        lw      a3, 0x0008(s0)              // a3 = current character ID
        lli     a2, Character.id.KIRBY      // a2 = id.KIRBY
        beql    a2, a3, pc() + 24           // if Kirby, load Kirby charge level
        lw      a2, 0x0AE0(s0)              // a2 = charge level
        lli     a2, Character.id.JKIRBY     // a2 = id.JKIRBY
        beql    a2, a3, pc() + 12           // if J Kirby, load Kirby charge level
        lw      a2, 0x0AE0(s0)              // a2 = charge level
        
        lw      a2, 0x0ADC(s0)              // a2 = charge level
        jal     0x80168DDC                  // projectile stage setting
        or      a3, r0, r0                  // a3 = 0
        sw      v0, 0x0B20(s0)              // store projectile object
        lw      s0, 0x0024(sp)              // ~
        lw      ra, 0x0024(sp)              // load s0, ra
        addiu   sp, sp, 0x0050              // deallocate stack space
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
        // Now add some new logic to update the projectile position. 
        sw      a0, 0x0020(sp)              // store a0
        jal     0x8015D394                  // update projectile position
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // load a0
        // Copy the next 15 lines of subroutine 0x8015D5AC
        OS.copy_segment(0xD7FF4, 0x3C)
        lli     a1, 0x0058                  // a1 = Mewtwo Shadow Ball Charge id (hard coded)
        or      a2, r0, r0                  // a2 = 0
        sw      a0, 0x0020(sp)              // store a0
        jal     0x800E9814                  // begin gfx routine
        sw      a3, 0x001C(sp)              // store a3
        jal     0x8015D300                  // destroy attached projectile
        lw      a0, 0x001C(sp)              // a0 = player struct
        jal     0x800DEE54                  // transition to idle (ground and air)
        lw      a0, 0x0020(sp)              // a0 = player object
        // Copy the next 8 lines of subroutine 0x8015D5AC
        OS.copy_segment(0xD8054, 0x20)
        // End
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Main subroutine for NSP_Ground_Charge and NSP_Air_Charge.
    // Based on subroutine 0x80157114, which is the main subroutine for Kirby's Samus grounded neutral special charge.
    scope kirby_charge_main_: {
        // First 2 lines of subroutine 0x80157114
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        // Now add some new logic to update the projectile position. 
        sw      a0, 0x0020(sp)              // store a0
        jal     0x8015D394                  // update projectile position
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // load a0
        // Copy the next 15 lines of subroutine 0x80157114
        OS.copy_segment(0xD1B5C, 0x3C)
        lli     a1, 0x0064                  // a1 = Kirby Mewtwo Shadow Ball Charge id (hard coded)
        or      a2, r0, r0                  // a2 = 0
        sw      a0, 0x0020(sp)              // store a0
        jal     0x800E9814                  // begin gfx routine
        sw      a3, 0x001C(sp)              // store a3
        jal     0x8015D300                  // destroy attached projectile
        lw      a0, 0x001C(sp)              // a0 = player struct
        jal     0x800DEE54                  // transition to idle (ground and air)
        lw      a0, 0x0020(sp)              // a0 = player object
        // Copy the next 8 lines of subroutine 0x80157114
        OS.copy_segment(0xD1BBC, 0x20)
        // End
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    80157114
    
    // @ Description
    // Interrupt subroutine for NSP_Ground_Charge.
    // Based on subroutine 0x8015D640, which is the interrupt subroutine for Samus' grounded neutral special charge.
    scope ground_charge_interrupt_: {
        // Copy the first 14 lines of subroutine 0x8015D640
        OS.copy_segment(0xD8080, 0x38)
        jal     ground_shoot_initial_       // ground_shoot_initial_
        or      a0, a2, r0                  // original line
        j       0x8015D6F4                  // return to original subroutine
        lw      ra, 0x0014(sp)              // original line
        sw      a1, 0x001C(sp)              // original line
        j       0x8015D68C                  // return to original subroutine
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
        jal     0x8015D300                  // destroy attached projectile
        lw      a0, 0x0084(a0)              // a0 = player struct
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
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Charge
        
        lli     a1, 0x00DF                  // a1(action id) = NSP_Ground_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802
        
        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
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
        lli     a1, Kirby.Action.MTWO_NSP_Air_Charge
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Charge
        
        lli     a1, 0x00E2                  // a1(action id) = NSP_Air_Charge
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t8, 0x0802                  // ~
        jal     0x800E6F24                  // change action
        sw      t8, 0x0010(sp)              // argument 4 = 0x0802
        
        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
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
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Shoot
        
        lli     a1, 0x00E0                  // a1(action id) = NSP_Ground_Shoot
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t6, 0x0024(sp)              // 0x0024(sp) = player struct
        
        lw      t9, 0x0024(sp)              // t9 = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
        li      t7, 0x8015D338              // t7 = on hit subroutine
        
        _end:
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
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Shoot
        
        lli     a1, 0x00E4                  // a1(action id) = NSP_Air_Shoot
        or      a2, r0, r0                  // a2(starting frame) = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        
        lw      t7, 0x0008(s0)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
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
    // Main subroutine for NSP_Ground_Shoot and NSP_Air_Shoot.
    // Wrapped version of subroutine 0x0x8015D7AC (SamusNSP.shoot_main_)
    // Adds a jump to update_ball_position_
    scope shoot_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        jal     0x8015D394                  // update projectile position
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x8015D7AC                  // jump to SamusNSP.shoot_main_
        lw      a0, 0x0018(sp)              // load a0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Main 
    // Main subroutine for NSP_Ground_Shoot and NSP_Air_Shoot.
    // Wrapped version of subroutine 0x80157314 (Kirby.SamusNSP_shoot_main_)
    // Adds a jump to update_ball_position_
    scope kirby_shoot_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        jal     0x8015D394                  // update projectile position
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x80157314                  // jump to Kirby.SamusNSP_shoot_main_
        lw      a0, 0x0018(sp)              // load a0
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
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
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Ground_Shoot
        
        lli     a1, 0x00E0                  // a1(action id) = NSP_Ground_Shoot
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7
        
        lw      t9, 0x0024(sp)              // t9 = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
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
        lli     a1, Kirby.Action.MTWO_NSP_Air_Shoot
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MTWO_NSP_Air_Shoot
        
        lli     a1, 0x00E4                  // a1(action id) = NSP_Air_Shoot
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      t7, 0x0010(sp)              // argument 4 = t7
        
        lw      t9, 0x0024(sp)              // t9 = player struct
        lw      t7, 0x0008(t9)              // t7 = current character ID
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beq     t7, at, _kirby              // branch if character = KIRBY
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        bne     t7, at, _mewtwo             // branch if character != JKIRBY
        nop
        
        _kirby:
        li      t7, 0x80156E98              // t7 = kirby's on hit subroutine
        b       _end                        // branch to end
        nop
        
        _mewtwo:
        li      t7, 0x8015D338              // t7 = on hit subroutine
        
        _end:
        sw      t7, 0x09EC(t9)              // store on hit subroutine in player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Main subroutine for Shadow Ball.
    // Based on subroutine 0x80168BFC, which is the main subroutine for the Charge Shot projectile.
    scope shadow_ball_main_: {  
        constant AMPLITUDE(0x42C8)          // float: 100
        constant FREQUENCY(0x4040)          // float: 3Hz
    
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0084(a0)              // a1 = projectile special struct
        sw      a1, 0x001C(sp)              // 0x001C(sp) = projectile special struct
        sw      a0, 0x0020(sp)              // 0x0020(sp) = projectile object
        lw      t6, 0x029C(a1)              // t6 = frame count
        bnez    t6, _projectile_active      // branch if projectile is active (frame counter has started)
        nop
        
        // if projectile is not active (charging state)
        lw      t6, 0x02A4(a1)              // t6 = charge level
        sll     t7, t6, 0x0003              // ~
        addu    t7, t7, t6                  // ~
        sll     t7, t7, 0x0002              // t7 = offset (charge level * 0x24)
        li      at, charge_level_array      // ~
        addu    at, at, t7                  // at = struct for current charge level (charge_level_array + offset)
        lwc1    f4, 0x0000(at)              // f4 = current charge level graphic size
        lui     at, 0x41F0                  // ~
        mtc1    at, f6                      // f6 = 30
        div.s   f4, f4, f6                  // f4 = size multiplier (base size / 30)
        lw      t6, 0x0074(a0)              // t6 = projectile first bone(0) struct
        swc1    f4, 0x0040(t6)              // update bone x size multiplier
        swc1    f4, 0x0044(t6)              // update bone y size multiplier
        lw      t1, 0x02A0(a1)              // t1 = bool begin_shot
        beqz    t1, _end                    // skip if begin_shot = FALSE
        nop
        
        // if the bool for beginning the shot was enabled
        lw      t1, 0x0020(t6)              // t1 = current y position
        sw      t1, 0x02AC(a1)              // save current y position as base y
        sw      r0, 0x02B0(a1)              // set shield bounce flag to FALSE
        jal     apply_charge_level_         // apply charge level
        nop
        lw      a1, 0x001C(sp)              // a1 = projectile special struct
        lli     at, 0x0001                  // ~
        sw      at, 0x0100(a1)              // enable hitbox
        jal     0x80165F60                  // unknown original subroutine
        lw      a0, 0x0020(sp)              // a0 = projectile object
        lw      a1, 0x001C(sp)              // a1 = projectile special struct
        addiu   at, r0, 0x0001              // at = 0x1
        b       _end                        // end subroutine
        sw      at, 0x029C(a1)              // set frame count to initial value of 1
        
        _projectile_active:
        lw      at, 0x02B0(a1)              // at = shield bounce flag
        bnez    at, _update_frame_count     // skip if a shield bounce has ocurred
        lw      at, 0x029C(a1)              // ~
        mtc1    at, f6                      // ~
        cvt.s.w f6, f6                      // f6 = frame
        lui     at, FREQUENCY               // ~
        mtc1    at, f4                      // f4 = FREQUENCY
        li      at, 0x3DD67750              // ~
        mtc1    at, f2                      // f2 = 2π/60
        mul.s   f4, f4, f2                  // f4 = FREQUENCY * 2π/60 = ω/60
        jal     0x800303F0                  // f0 = sin(f12)
        mul.s   f12, f4, f6                 // f12 = ω/60 * frame = ωt
        lw      a1, 0x001C(sp)              // a1 = projectile special struct
        lw      a0, 0x0020(sp)              // a0 = projectile object
        lui     at, AMPLITUDE               // ~
        mtc1    at, f4                      // f4 = AMPLITUDE
        mul.s   f4, f4, f0                  // f4 = AMPLITUDE * sin(ωt)
        lwc1    f6, 0x02AC(a1)              // f6 = base y
        add.s   f6, f6, f4                  // f6 = base y + AMPLITUDE * sin(ωt)
        lw      t6, 0x0074(a0)              // t6 = projectile first bone(0) struct
        swc1    f6, 0x0020(t6)              // store updated y position
        
        _update_frame_count:
        lw      at, 0x029C(a1)              // at = frame count
        addiu   at, at, 0x0001              // increment frame count
        sw      at, 0x029C(a1)              // store updated frame count
        

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        or      v0, r0, r0                  // return 0 (don't destroy projectile)
    }
    
    // @ Description
    // Subroutine for applying charge levels to Shadow Ball.
    // Based on subroutine 0x80168B00 which applies charge levels for Charge Shot.
    scope apply_charge_level_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v0, 0x0084(a0)              // v0 = item special struct
        li      t8, charge_level_array      // t8 = charge_level_array
        // Copy the next 34 lines of subroutine 0x80168B00
        OS.copy_segment(0xE3554, 0x88)
        li      t5, charge_level_array      // t5 = charge_level_array
        // Copy the next 14 lines of subroutine 0x80168B00
        OS.copy_segment(0xE35E4, 0x38)
    }
    
    // @ Description
    // Patch for subroutine 0x80168DDC, which is the "stage setting" subroutine for Charge Shot.
    // Adds a check for Mewtwo when loading the charge FGM from the charge level array.
    scope charge_fgm_fix_: {
        OS.patch_start(0xE38C4, 0x80168E84)
        j       charge_fgm_fix_
        addu    a1, a1, t1                  // a1 = base + offset (original line 1)
        _return:
        OS.patch_end()
        
        // t1 = offset for charge_level_array
        // 0x0024(sp) = player struct
        lw      at, 0x0024(sp)              // at = player struct
        lw      a0, 0x0008(at)              // a0 = character id
        lli     t0, Character.id.KIRBY      // t0 = id.KIRBY
        beql    a0, t0, pc() + 8            // if Kirby, get held power character_id
        lw      a0, 0x0ADC(at)              // t1 = character id of copied power
        lli     t0, Character.id.JKIRBY     // t0 = id.JKIRBY
        beql    a0, t0, pc() + 8            // if J Kirby, get held power character_id
        lw      a0, 0x0ADC(at)              // t1 = character id of copied power
        lli     t0, Character.id.MTWO       // t0 = id.MTWO
        bne     a0, t0, _end                // skip if character !=MTWO
        lhu     a1, 0x8F2A(a1)              // a1 = charge fgm (Samus)
        
        // if character is Mewtwo
        li      a1, charge_level_array      // ~
        addu    a1, a1, t1                  // a1 = struct for current charge level (charge_level_array + offset)
        lw      a1, 0x0018(a1)              // a1 = charge fgm (Mewtwo)
        
        _end:
        j       _return                     // return
        nop  
    }
    
    // @ Description
    // Patch for subroutine 0x8015D7AC (SamusNSP.shoot_main_), increases the x velocity gained when firing for Mewtwo.
    scope shoot_velocity_patch_: {
        OS.patch_start(0xD82B8, 0x8015D878)
        j       shoot_velocity_patch_
        nop
        _return:
        OS.patch_end()
        
        // s0 = player struct
        lw      t1, 0x0008(s0)              // t1 = character id
        lli     at, Character.id.MTWO       // at = id.MTWO
        bne     t1, at, _original           // skip if character !=MTWO
        addiu   t9, t8, 0x0001              // original line 2
        
        _mewtwo:
        // if the character is Mewtwo, use an alternate calculation for x velocity
        lui     at, 0x4120                  // ~
        mtc1    t9, f4                      // ~
        subu    t1, r0, t0                  // ~
        mtc1    t1, f16                     // ~
        cvt.s.w f0, f4                      // ~
        mtc1    at, f8                      // original logic, f8 = x speed
        lui     at, SHOOT_X_SPEED           // ~
        mtc1    at, f4                      // f4 = SHOOT_X_SPEED
        lwc1    f18, 0x0ADC(s0)             // ~
        cvt.s.w f18, f18                    // f18 = charge level
        mul.s   f4, f4, f18                 // f4 = SHOOT_X_SPEED * charge level
        add.s   f8, f8, f4                  // f8 = original speed + (SHOOT_X_SPEED * charge_level
        lw      v0, 0x0AE0(s0)              // original line
        j       0x8015D89C                  // return to original subroutine
        lui     at, 0xC0A0                  // at = float -5.0, originally float -10.0
        
        _original:
        j       _return                     // return
        lui     at, 0x4120                  // original line 1
    }
    
    // @ Description
    // Patch for subroutine 0x80157314 (Kirby.SamusNSP_shoot_main_), increases the x velocity gained when firing with Mewtwo's power.
    scope kirby_shoot_velocity_patch_: {
        OS.patch_start(0xD1E20, 0x801573E0)
        j       kirby_shoot_velocity_patch_
        nop
        _return:
        OS.patch_end()
        
        // s0 = player struct
        lw      t1, 0x0ADC(s0)              // t1 = character id of copied power
        lli     at, Character.id.MTWO       // at = id.MTWO
        bne     t1, at, _original           // skip if copied character !=MTWO
        addiu   t9, t8, 0x0001              // original line 2
        
        _mewtwo:
        // if the copied character is Mewtwo, use an alternate calculation for x velocity
        lui     at, 0x4120                  // ~
        mtc1    t9, f4                      // ~
        subu    t1, r0, t0                  // ~
        mtc1    t1, f16                     // ~
        cvt.s.w f0, f4                      // ~
        mtc1    at, f8                      // original logic, f8 = x speed
        lui     at, SHOOT_X_SPEED           // ~
        mtc1    at, f4                      // f4 = SHOOT_X_SPEED
        lwc1    f18, 0x0AE0(s0)             // ~
        cvt.s.w f18, f18                    // f18 = charge level
        mul.s   f4, f4, f18                 // f4 = SHOOT_X_SPEED * charge level
        add.s   f8, f8, f4                  // f8 = original speed + (SHOOT_X_SPEED * charge_level
        lw      v0, 0x0AE0(s0)              // original line
        j       0x80157404                  // return to original subroutine
        lui     at, 0xC0A0                  // at = float -5.0, originally float -10.0
        
        _original:
        j       _return                     // return
        lui     at, 0x4120                  // original line 1
    }
     
    // @ Description
    // Patch for Samus NSP subroutine 0x8015D35C, which gets the x/y/z coordinates of the arm cannon part.
    // When the character is Mewtwo, use this version of the subroutine instead.
    scope ball_position_fix_: {
        OS.patch_start(0xD7D9C, 0x8015D35C)
        j       ball_position_fix_
        mtc1    r0, f0                      // f0 = 0 (original line 1)
        _return:
        OS.patch_end()
        
        addiu   sp, sp,-0x0018              // allocate stack space (original line 2)
        lw      at, 0x0008(a0)              // at = current character id
        lli     t6, Character.id.MTWO       // t6 = id.MTWO
        beq     at, t6, _mewtwo             // branch if character id = MTWO
        lli     t6, Character.id.KIRBY      // t6 = id.KIRBY
        beq     at, t6, _kirby              // branch if character id = KIRBY
        lli     t6, Character.id.JKIRBY     // t6 = id.JKIRBY
        beq     at, t6, _kirby              // branch if character id = JKIRBY
        nop
        
        // if we're here, go back to the original subroutine
        j       _return                     // return
        nop
        
        _mewtwo:
        sw      ra, 0x0014(sp)              // store ra
        swc1    f0, 0x0000(a1)              // ~
        swc1    f0, 0x0004(a1)              // ~
        swc1    f0, 0x0008(a1)              // set initial x/y/z offset to 0,0,0
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0, a1 is offset and then return
        lw      a0, 0x0978(a0)              // a0 = part 0x20 ("grab" part) struct
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
        
        _kirby:
        sw      ra, 0x0014(sp)              // store ra
        swc1    f0, 0x0000(a1)              // ~
        swc1    f0, 0x0004(a1)              // ~
        swc1    f0, 0x0008(a1)              // set initial x/y/z offset to 0,0,0
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0, a1 is offset and then return
        lw      a0, 0x0960(a0)              // a0 = part 0x1A ("grab" part) struct
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Runs when a Shadow Ball collides with a hurtbox or shield, is absorbed, or clangs.
    // Based on 0x80168D24, which is the equivalent for Charge Shot.
    scope shadow_ball_hurtbox_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x00014(sp)             // store ra
        lw      v0, 0x0084(a0)              // v0 = projectile special struct
        lw      a1, 0x0104(v0)              // a1 = projectile damage
        lw      a0, 0x0074(a0)              // a0 = projectile first bone(0) struct
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coordinates
        li      t6, GFX.current_gfx_id      // t6 = current_gfx_id
        lli     at, 0x006C                  // at = dark cross id
        jal     0x800FE2F4                  // create fire cross effect
        sw      at, 0x0000(t6)              // set dark cross as current GFX id
        jal     0x800269C0                  // play FGM
        lli     a0, 0x003C                  // FGM id = 0x3C
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        lli     v0, 0x0001                  // return 1 (destroy projectile)
    }
    
    // @ Description
    // Collision subroutine for Shadow Ball.
    // Based on 0x801688C4, which is the equivalent for Charge Shot.
    scope shadow_ball_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x00014(sp)             // store ra
        lw      v0, 0x0084(a0)              // v0 = projectile special struct
        lw      t6, 0x029C(v0)              // t6 = frame count
        beql    t6, r0, _end                // skip if projectile is not active (frame counter hasn't started)
        or      v0, r0, r0                  // return 0 (don't destroy projectile)
        
        jal     0x80167C04                  // charge shot collision detection?
        sw      a0, 0x0018(sp)              // 0x0018(sp) = projectile object
        beqz    v0, _end                    // end if collision wasn't detected
        lw      a0, 0x0018(sp)              // a2 = projectile object
        // if collision was detected
        lw      v0, 0x0084(a0)              // v0 = projectile special struct
        lw      a0, 0x0074(a0)              // a0 = projectile first bone(0) struct
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coordinates 
        li      t7, GFX.current_gfx_id      // t7 = current_gfx_id
        lw      t6, 0x02A4(v0)              // t6 = charge level
        lli     at, 0x0007                  // at = 7 (full charge)
        beq     at, t6, _full_charge        // branch if projectile is fully charged
        nop
        
        // if projectile is not fully charged
        lli     at, 0x005C                  // at = blue explosion id
        jal     0x80100480                  // create explosion effect
        sw      at, 0x0000(t7)              // set blue explosion as current GFX id
        jal     0x801008F4                  // screen shake
        lli     a0, 0x0000                  // shake severity = light
        jal     0x800269C0                  // play FGM
        lli     a0, 0x0000                  // FGM id = 0
        b       _end                        // end subroutine
        lli     v0, 0x0001                  // return 1 (destroy projectile)
        
        _full_charge:
        lli     at, 0x005D                  // at = "blue bomb explosion" id
        jal     0x801005C8                  // create large explosion effect
        sw      at, 0x0000(t7)              // set blue bomb explosion as current GFX id
        jal     0x801008F4                  // screen shake
        lli     a0, 0x0001                  // shake severity = moderate
        jal     0x800269C0                  // play FGM
        lli     a0, 0x0001                  // FGM id = 1
        lli     v0, 0x0001                  // return 1 (destroy projectile)
        
        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Runs when a Shadow Ball collides with edges of a shield and bounces off.
    // Wrapped version of 0x80168D54, which is the shield collision subroutine for Carge Shot.
    scope shadow_ball_shield_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x00014(sp)             // store ra
        lw      v0, 0x0084(a0)              // v0 = projectile special struct
        lli     at, OS.TRUE                 // at = TRUE
        jal     0x80168D54                  // original subroutine
        sw      at, 0x02B0(v0)              // set shield bounce flag to TRUE
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    OS.align(16)
    projectile_struct:
    constant SBALL_ID(0x1002)
    dw 0x00000000                           // unknown
    dw 0x00000002                           // projectile id
    dw Character.MTWO_file_8_ptr            // address of Mewtwo's file 8 pointer
    dw 0x00000000                           // 00000000
    dw 0x122E0000                           // Render routine?
    dw shadow_ball_main_                    // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168BFC)
    dw shadow_ball_collision_               // This is the collision subroutine for the projectile, responsible for detecting collision with clipping. (default 0x80168CC4)
    dw shadow_ball_hurtbox_collision_       // This function runs when the projectile collides with a hurtbox. (default 0x80168D24)
    dw shadow_ball_hurtbox_collision_       // This function runs when the projectile collides with a shield. (default 0x80168D24)
    dw shadow_ball_shield_collision_        // This function runs when the projectile collides with edges of a shield and bounces off. (default 0x80168D54)
    dw shadow_ball_hurtbox_collision_       // This function runs when the projectile collides/clangs with a hitbox. (default 0x80168D24)
    dw 0x80168DA4                           // This function runs when the projectile collides with Fox's reflector. (default 0x80168DA4)
    dw shadow_ball_hurtbox_collision_       // This function runs when the projectile collides with Ness's psi magnet. (default 0x80168D24)
    OS.align(16)                            // pad to 0x10
    
    // @ Description
    // Adds a charge level struct for Mewtwo.
    // graphic_size - graphic size multiplier
    // speed - x speed
    // damage - hitbox damage
    // hitbox_size - hitbox size
    // unknown_1 - unknown, always 10 for charge shot
    // shot_fgm - fgm to play when shooting
    // charge_fgm - fgm to play when charging
    // hit_fgm - fgm to play when the projectile hits an opponent
    // unknown_2 - unknown, charge shot is 1 for levels 0-6, 2 for level 7
    macro add_charge_level(graphic_size, speed, damage, hitbox_size, unknown_1, shot_fgm, charge_fgm, hit_fgm, unknown_2) {
        float32 {graphic_size}              // 0x00 - graphic size multiplier
        float32 {speed}                     // 0x04 - x speed
        dw {damage}                         // 0x08 - hitbox damage
        dw {hitbox_size}                    // 0x0C - hitbox size
        dw {unknown_1}                      // 0x10 - unknown, always 10 for charge shot
        dw {shot_fgm}                       // 0x14 - fgm to play when shooting
        dw {charge_fgm}                     // 0x18 - fgm to play when charging
        dw {hit_fgm}                        // 0x1C - fgm to play when the projectile hits an opponent
        dw {unknown_2}                      // 0x20 - unknown, charge shot is 1 for levels 0-6, 2 for level 7
    }
    
    OS.align(16)
    charge_level_array:
    add_charge_level(130, 70,  2,  90, 10,  0x1A,  0x3C9, 0x1C, 1)      // level 0
    add_charge_level(160, 72,  4, 110, 10,  0x1A,  0x3CA, 0x1C, 1)      // level 1
    add_charge_level(200, 74,  6, 130, 10,  0x1A,  0x3CB, 0x1B, 1)      // level 2
    add_charge_level(260, 76,  9, 150, 10,  0x3C,  0x3CC, 0x1B, 1)      // level 3
    add_charge_level(330, 78, 12, 170, 10,  0x3C,  0x3CD, 0x1B, 1)      // level 4
    add_charge_level(410, 80, 15, 190, 10,  0x3C,  0x3CE, 0x19, 1)      // level 5
    add_charge_level(500, 82, 18, 210, 10,  0x3C,  0x3CF, 0x19, 1)      // level 6
    add_charge_level(600, 84, 22, 230, 10,  0xC1,  0x3D0, 0x19, 2)      // level 7
}

scope MewtwoUSP {
    constant DEFAULT_ANGLE(0x3FC90FDB) // float 1.570796 rads
    constant LANDING_FSM(0x3F9D89D9) // float 1.23077
    constant SPEED(0x4300) // float 128
    
    // @ Description
    // Subroutine which runs when Mewtwo initiates a grounded up special.
    scope ground_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Mewtwo.Action.USP_Ground_Begin // a1(action id) = USP_Ground_Begin
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
    // Subroutine which runs when Mewtwo initiates an aerial up special.
    scope air_begin_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Mewtwo.Action.USP_Air_Begin // a1(action id) = USP_Air_Begin
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
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x004C(a0)              // multiply y velocity by 0.5 and update
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
        li      a1, ground_begin_transition_ // a1(transition subroutine) = ground_begin_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop 
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
        lli     a1, Mewtwo.Action.USP_Ground_Begin // a1(action id) = USP_Ground_Begin
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
        lli     a1, Mewtwo.Action.USP_Air_Begin // a1(action id) = USP_Air_Begin
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
    // Subroutine which begins Mewtwo's up special movement actions.
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
        lli     a1, Mewtwo.Action.USP_Air_Move // a1(action id) = USP_Air_Move
        
        _grounded:
        lb      t0, 0x01C3(s0)              // t0 = stick_y
        bnez    t0, _aerial                 // branch if stick_y = 0
        lli     a1, Mewtwo.Action.USP_Air_Move // a1(action id) = USP_Air_Move
        lb      t0, 0x01C2(s0)              // t0 = stick_x
        beqz    t0, _aerial                 // branch if stick_x = 0
        lli     a1, Mewtwo.Action.USP_Air_Move // a1(action id) = USP_Air_Move
        
        // if we're here, stick_y is 0 and stick_x is not 0, so use grounded action
        b       _change_action              // change action
        lli     a1, Mewtwo.Action.USP_Ground_Move // a1(action id) = USP_Ground_Move
        
        _aerial:
        jal     0x800DEEC8                  // set aerial state
        or      a0, s0, r0                  // a0 = player struct
        lli     a1, Mewtwo.Action.USP_Air_Move // a1(action id) = USP_Air_Move
        
        _change_action:
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
    // Main subroutine for USP_Ground_Move and USP_Air_Move.
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
        jal     ground_end_initial_         // transition to USP_Ground_End
        nop
        b       _end                        // end
        nop
        
        _aerial:
        jal     air_end_initial_            // transition to USP_Air_End
        nop
        
        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Physics subroutine for USP_Ground_Move and USP_Air_Move.
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
    // Collision subroutine for USP_Ground_Move.
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
    // Collision subroutine for USP_Air_Move.
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
    // Subroutine which transitions to USP_Ground_Move.
    scope ground_move_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Mewtwo.Action.USP_Ground_Move // a1(action id) = USP_Ground_Move
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
    // Subroutine which transitions to USP_Air_Move.
    scope air_move_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, Mewtwo.Action.USP_Air_Move // a1(action id) = USP_Air_Move
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
    // Subroutine which begins Mewtwo's grounded up special ending action.
    scope ground_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Mewtwo.Action.USP_Ground_End // a1(action id) = USP_Ground_End
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
    // Subroutine which begins Mewtwo's aerial up special ending action.
    scope air_end_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Mewtwo.Action.USP_Air_End // a1(action id) = USP_Air_End
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
        lwc1    f2, 0x004C(a0)              // f2 = y velocity
        mul.s   f2, f2, f0                  // ~
        swc1    f2, 0x004C(a0)              // multiply y velocity by 0.25 and update
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Main subroutine for USP_Air_End.
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
        sw      r0, 0x0018(sp)              // interrupt flag = FALSE
        li      t6, LANDING_FSM             // t6 = LANDING_FSM
        jal     0x801438F0                  // begin special fall
        sw      t6, 0x0014(sp)              // store LANDING_FSM
        lw      ra, 0x0024(sp)              // restore ra
        
        _end:
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Main subroutine for USP_Ground_End.
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
    // Collision subroutine for USP_Ground_End and USP_Air_End.
    // Based on subroutine 0x8015DD58, which is the collision subroutine for Samus' up special.
    // Modified to load Mewtwo's landing FSM value.
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
    // Subroutine which applies movement to Mewtwo's up special based on the angle stored at 0x0B20 in the player struct.
    // a0 - player struct
    scope apply_movement_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
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
}

scope MewtwoDSP {   
    // @ Description
    // Subroutine which runs when Mewtwo initiates a grounded down special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, 0x00E5                  // a1(action id) = 0x00E5(grounded down special)
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
    // Subroutine which runs when Mewtwo initiates an aerial down special.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, 0x00E6                  // a1(action id) = 0x00E6(aerial down special)
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x004C(a0)              // set y velocity to 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for ground DSP.
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_transition_         // a1(transition subroutine) = air_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop 
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Collision subroutine for aerial DSP.
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_transition_      // a1(transition subroutine) = ground_transition_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop 
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which transitions to grounded down special.
    scope ground_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, 0x00E5                  // a1(action id) = 0x00E5(grounded down special)
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
    // Subroutine which transitions to aerial down special.
    scope air_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lli     a1, 0x00E6                  // a1(action id) = 0x00E6(aerial down special)
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
}
