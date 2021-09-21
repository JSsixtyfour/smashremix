// MarthSpecial.asm

// This file contains subroutines used by Marth's special moves.

// @ Description
// Subroutines for Up Special    
scope MarthUSP {
    // floating point constants for physics and fsm
    constant AIR_Y_SPEED(0x43C8)            // current setting - float32 400
    constant GROUND_Y_SPEED(0x43D2)         // current setting - float32 420
    constant X_SPEED(0x4120)                // current setting - float32 10
    constant END_AIR_ACCELERATION(0x3C20)   // current setting - float32 0.00977
    constant END_AIR_SPEED(0x41C0)          // current setting - float32 24
    constant LANDING_FSM(0x3EC0)            // current setting - float32 0.375
    // temp variable 3 constants for movement states
    constant BEGIN(0x1)
    constant BEGIN_MOVE(0x2)
    constant MOVE(0x3)
    constant END_MOVE(0x4)
    constant END(0x5)
    
    // @ Description
    // Subroutine which runs when Marth initiates an aerial up special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Marth.Action.USPA       // a1 = Action.USPA
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
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
    // Subroutine which runs when Marth initiates a grounded up special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lli     a1, Marth.Action.USPG       // a1 = Action.USPG
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     v1, r0, 0x0001              // ~
        sw      v1, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }
    
    // @ Description
    // Main subroutine for Marth's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Marth's landing FSM value and disable the interrupt flag.
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
    // Subroutine which allows a direction change for Marth's up special.
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
    // Subroutine which handles movement for Marth's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = end movement
    // 0x5 = ending
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      t0, 0x0024(sp)              // ~
        sw      t1, 0x0028(sp)              // ~
        swc1    f0, 0x002C(sp)              // ~
        swc1    f2, 0x0030(sp)              // ~
        swc1    f4, 0x0034(sp)              // store t0, t1, f0, f2, f4
        
        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t0, 0x014C(s0)              // t0 = kinetic state
        bnez    t0, _aerial                 // branch if kinetic state !grounded
        nop
        
        //_grounded:
        jal     0x800D8BB4                  // grounded physics subroutine
        nop
        b       _end                        // end subroutine
        nop
        
        _aerial:
        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, END                 // t1 = END
        bne     t0, t1, _apply_air_physics  // branch if temp variable 3 != END
        nop
        li      t8, air_control_             // t8 = air_control_
        
        _apply_air_physics:
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
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Marth.Action.USPG       // t1 = Action.USPG
        beq     t0, t1, _check_begin_move   // skip if current action = USP_GROUND
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
        bne     t0, t1, _check_end_move     // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lw      t0, 0x0024(s0)              // t0 = current action
        lli     t1, Marth.Action.USPG       // t1 = Action.USPG
        beq     t0, t1, _calculate_velocity // branch if current action = USP_GROUND
        lui     t0, GROUND_Y_SPEED          // t0 = GROUND_Y_SPEED
        // if current action != USP_GROUND
        lui     t0, AIR_Y_SPEED             // t0 = AIR_Y_SPEED
        
        _calculate_velocity:
        mtc1    t0, f4                      // f4 = Y_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lb      t0, 0x01C2(s0)              // ~
        mtc1    t0, f2                      // ~         
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f0, f2, f0                  // f0 = stick_x * direction
        lui     t0, 0x4120                  // ~
        mtc1    t0, f2                      // f2 = 10
        c.le.s  f2, f0                      // ~
        nop                                 // ~
        bc1f    _apply_movement             // branch if stick_x * direction =< 10
        nop
        
        // update x velocity based on stick_x
        // f0 = stick_x (relative to direction)
        lui     t0, 0x4000                  // ~
        mtc1    t0, f2                      // f2 = 2
        mul.s   f2, f0, f2                  // f2 = x velocity (stick_x * 2)
        // update y velocity based on x velocity (higher x = lower y)
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f0                      // f0 = 0.375
        mul.s   f0, f0, f2                  // ~
        sub.s   f4, f4, f0                  // f4 = Y_SPEED - (x velocity * 0.375)
        
        _apply_movement:
        // f2 = x velocity to add
        // f4 = y velocity
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f0                      // f0 = X_SPEED
        add.s   f2, f2, f0                  // f2 = final velocity
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = x velocity * direction
        swc1    f2, 0x0048(s0)              // store x velocity
        swc1    f4, 0x004C(s0)              // store y velocity
        ori     t0, r0, MOVE                // t0 = MOVE
        sw      t0, 0x0184(s0)              // temp variable 3 = MOVE
        // take mid-air jumps away at this point
        lw      t0, 0x09C8(s0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(s0)              // jumps used = max jumps
        
        _check_end_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != END_MOVE
        nop
        
        _end_movement:
        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, 0x3E00                  // ~
        mtc1    t0, f2                      // f2 = 0.125
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.125
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        lwc1    f4, 0x0044(s0)              // ~
        cvt.s.w f4, f4                      // f4 = direction
        mul.s   f2, f2, f4                  // f2 = X_SPEED * direction
        add.s   f0, f0, f2                  // f0 = final velocity
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.125) + X_SPEED
        // slow y movement
        lwc1    f0, 0x004C(s0)              // f0 = current y velocity
        lui     t0, 0x3DC0                  // ~
        mtc1    t0, f2                      // f2 = 0.09375
        mul.s   f0, f0, f2                  // f0 = y velocity * 0.09375
        swc1    f0, 0x004C(s0)              // y velocity = (y velocity * 0.09375)
        ori     t0, r0, END                 // t0 = END
        sw      t0, 0x0184(s0)              // temp variable 3 = END
        
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
    // Subroutine which handles Marth's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        // load an immediate value into a2 instead of the air acceleration from the attributes
        lui     a2, END_AIR_ACCELERATION    // a2 = END_AIR_ACCELERATION
        lui     a3, END_AIR_SPEED           // a3 = END_AIR_SPEED
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
    // Subroutine which handles collision for Marth's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Marth.
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
// Subroutines for Marth Neutral special.
scope MarthNSP {
    constant Y_SPEED(0x4210)                // current setting - float32 36
    constant Y_SPEED_STALE(0x4180)          // current setting - float32 16
    constant Y_SPEED_SECOND(0x4100)          // current setting - float32 8

    // @ Description
    // Subroutine which runs when Marth initiates grounded neutral special actions.
    // Changes action, and sets up initial variable values.
    // a0 - player object
    // a1 - action id
    scope ground_shared_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store ra, a0
        sw      r0, 0x0010(sp)              // argument 4 = 0
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Initial subroutine for grounded neutral special.
    // Wrapped version of ground_shared_initial_ which sets the action id to NSPG_1
    scope ground_1_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        sw      r0, 0x0B20(v1)              // set stage to 0(first stage)
        
        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPG_1
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPG_1
        
        lli     a1, Marth.Action.NSPG_1     // a1 = Action.NSPG_1
        jal     ground_shared_initial_      // ground_shared_initial_
        nop
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Initial subroutine for grounded neutral special's second stage.
    // Wrapped version of ground_shared_initial_ which sets the appropriate action id
    scope ground_2_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        
        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPG_2_Mid
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPG_2_Mid
        
        lli     a1, Marth.Action.NSPG_2_Mid // a1 = Action.NSPG_2_Mid
        slti    at, t6, 40                  // at = 1 if stick_y < 40, else at = 0
        beql    at, r0, _change_action      // branch if stick_y >= 40...
        addiu   a1, a1,-0x0001              // ...and decrement action id to Action.NSPG_2_High
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnel    at, r0,_change_action          // branch if stick_y >= -40...
        addiu   a1, a1, 0x0001              // ...and increment action id to Action.NSPG_2_Low
        
        _change_action:
        lli     at, 0x0001                  // ~
        jal     ground_shared_initial_      // ground_shared_initial_
        sw      at, 0x0B20(v1)              // set stage to 1(second stage)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Initial subroutine for grounded neutral special's third stage.
    // Wrapped version of ground_shared_initial_ which sets the appropriate action id
    scope ground_3_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        
        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPG_3_Mid
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPG_3_Mid
        
        lli     a1, Marth.Action.NSPG_3_Mid // a1 = Action.NSPG_3_Mid
        slti    at, t6, 40                  // at = 1 if stick_y < 40, else at = 0
        beql    at, r0, _change_action      // branch if stick_y >= 40...
        addiu   a1, a1,-0x0001              // ...and decrement action id to Action.NSPG_3_High
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnel    at, r0,_change_action       // branch if stick_y >= -40...
        addiu   a1, a1, 0x0001              // ...and increment action id to Action.NSPG_3_Low
        
        _change_action:
        lli     at, 0x0002                  // ~
        jal     ground_shared_initial_      // ground_shared_initial_
        sw      at, 0x0B20(v1)              // set stage to 2(third stage)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which runs when Marth initiates aerial neutral special actions.
    // Changes action, and sets up initial variable values.
    // a0 - player object
    // a1 - action id
    scope air_shared_initial_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      a1, 0x0024(sp)              // store ra, a0, a1
        sw      r0, 0x0010(sp)              // argument 4 = 0
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        // reset fall speed
        lbu     v1, 0x018D(a0)              // v1 = fast fall flag
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        // slow x movement
        lwc1    f0, 0x0048(a0)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(a0)              // x velocity = (x velocity * 0.875)
        lw      v1, 0x0008(a0)              // v1 = character id
        lli     at, Character.id.KIRBY      // at = id.KIRBY
        beql    at, v1, _y_velocity_kirby   // branch if character = KIRBY
        lw      v1, 0x0024(sp)              // v1 = action id
        lli     at, Character.id.JKIRBY     // at = id.JKIRBY
        beq     at, v1, _y_velocity_kirby   // branch if character = JKIRBY
        lw      v1, 0x0024(sp)              // v1 = action id  
        
        // apply y velocity
        _y_velocity_marth:     
        lli     at, Marth.Action.NSPA_1     // at = Action.NSPA_1
        bne     v1, at, _end                // branch if action id != NSPA_1
        lui     v1, Y_SPEED_SECOND          // v1 = Y_SPEED_SECOND
        
        lw      v1, 0x0ADC(a0)              // v1 = pseudo-jump flag
        bnez    v1, _end                    // branch if pseudo-jump has been used (flag = TRUE)
        lui     v1, Y_SPEED_STALE           // v1 = Y_SPEED_STALE
        // if we're here, this is the first use of aerial neutral b, so give Marth a larger vertical boost
        lui     v1, Y_SPEED                 // v1 = Y_SPEED
        lli     t6, OS.TRUE                 // ~
        b       _end                        // branch to end
        sw      t6, 0x0ADC(a0)              // set pseudo-jump flag to TRUE
        
        // apply y velocity
        _y_velocity_kirby:
        lli     at, Kirby.Action.MARTH_NSPA_1 // at = Action.MARTH_NSPA_1
        bne     v1, at, _end                // branch if action id != NSPA_1
        lui     v1, Y_SPEED_SECOND          // v1 = Y_SPEED_SECOND
        
        lw      v1, 0x0AE0(a0)              // v1 = pseudo-jump flag
        bnez    v1, _end                    // branch if pseudo-jump has been used (flag = TRUE)
        lui     v1, Y_SPEED_STALE           // v1 = Y_SPEED_STALE
        // if we're here, this is the first use of aerial neutral b, so give Marth a larger vertical boost
        lui     v1, Y_SPEED                 // v1 = Y_SPEED
        lli     t6, OS.TRUE                 // ~
        sw      t6, 0x0AE0(a0)              // set pseudo-jump flag to TRUE
        
        _end:
        sw      v1, 0x004C(a0)              // update y velocity
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Initial subroutine for aerial neutral special.
    // Wrapped version of air_shared_initial_ which sets the action id to NSPA_1
    scope air_1_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        sw      r0, 0x0B20(v1)              // set stage to 0(first stage)
        
        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPA_1
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPA_1
        
        lli     a1, Marth.Action.NSPA_1     // a1 = Action.NSPA_1
        jal     air_shared_initial_         // air_shared_initial_
        nop
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Initial subroutine for aerial neutral special's second stage.
    // Wrapped version of air_shared_initial_ which sets the appropriate action id
    scope air_2_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        
        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPA_2_Mid
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPA_2_Mid
        
        lli     a1, Marth.Action.NSPA_2_Mid // a1 = Action.NSPA_2_Mid
        slti    at, t6, 40                  // at = 1 if stick_y < 40, else at = 0
        beql    at, r0, _change_action      // branch if stick_y >= 40...
        addiu   a1, a1,-0x0001              // ...and decrement action id to Action.NSPA_2_High
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnel    at, r0,_change_action          // branch if stick_y >= -40...
        addiu   a1, a1, 0x0001              // ...and increment action id to Action.NSPA_2_Low
        
        _change_action:
        lli     at, 0x0001                  // ~
        jal     air_shared_initial_         // air_shared_initial_
        sw      at, 0x0B20(v1)              // set stage to 1(second stage)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Initial subroutine for aerial neutral special's third stage.
    // Wrapped version of air_shared_initial_ which sets the appropriate action id
    scope air_3_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        
        lw      a2, 0x0008(v1)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPA_3_Mid
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.MARTH_NSPA_3_Mid
        
        lli     a1, Marth.Action.NSPA_3_Mid // a1 = Action.NSPA_2_Mid
        slti    at, t6, 40                  // at = 1 if stick_y < 40, else at = 0
        beql    at, r0, _change_action      // branch if stick_y >= 40...
        addiu   a1, a1,-0x0001              // ...and decrement action id to Action.NSPA_3_High
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        bnel    at, r0,_change_action          // branch if stick_y >= -40...
        addiu   a1, a1, 0x0001              // ...and increment action id to Action.NSPA_3_Low
        
        _change_action:
        lli     at, 0x0002                  // ~
        jal     air_shared_initial_         // air_shared_initial_
        sw      at, 0x0B20(v1)              // set stage to 2(third stage)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Main subroutine for grounded neutral special actions
    // Transitions to idle and checks for inputs to transition to the next stage
    scope ground_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        
        // first, check if temp variable 2 is set, this flag is used to determine the window for inputting the next attack/stage in neutral special
        lw      t6, 0x0180(v0)              // t6 = temp variable 1
        beqz    t6, _check_idle             // skip if temp variable 1 isn't set
        nop
        // now, check if the b button is being pressed
        lhu     t6, 0x01BE(v0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        beqz    t6, _check_idle             // skip if B is not pressed
        nop
        
        // if we're here, the b button has been pressed within the window for starting the next stage
        lw      t6, 0x0B20(v0)              // t6 = current stage of neutral special
        beqz    t6, _begin_stage_2          // if current stage is 1, begin stage 2
        lli     at, 0x0001                  // at = 0x0001
        beq     at, t6, _begin_stage_3      // if current stage is 2, begin stage 3
        nop
        b       _check_idle                 // if current stage is not 1 or 2, then no interrupt is possible
        nop
        
        _begin_stage_2:
        jal     ground_2_initial_           // ground_2_initial_
        nop
        b       _end                        // skip to end
        nop
        
        _begin_stage_3:
        jal     ground_3_initial_           // ground_3_initial_
        nop
        b       _end                        // skip to end
        nop
        
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
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Main subroutine for aerial neutral special actions
    // Transitions to idle and checks for inputs to transition to the next stage
    scope air_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v0, 0x0084(a0)              // v0 = player struct
        
        // first, check if temp variable 2 is set, this flag is used to determine the window for inputting the next attack/stage in neutral special
        lw      t6, 0x0180(v0)              // t6 = temp variable 1
        beqz    t6, _check_idle             // skip if temp variable 1 isn't set
        nop
        // now, check if the b button is being pressed
        lhu     t6, 0x01BE(v0)              // t6 = buttons_pressed
        andi    t6, t6, Joypad.B            // t6 = 0x4000 if (B_PRESSED); else t6 = 0
        beqz    t6, _check_idle             // skip if B is not pressed
        nop
        
        // if we're here, the b button has been pressed within the window for starting the next stage
        lw      t6, 0x0B20(v0)              // t6 = current stage of neutral special
        beqz    t6, _begin_stage_2          // if current stage is 1, begin stage 2
        lli     at, 0x0001                  // at = 0x0001
        beq     at, t6, _begin_stage_3      // if current stage is 2, begin stage 3
        nop
        b       _check_idle                 // if current stage is not 1 or 2, then no interrupt is possible
        nop
        
        _begin_stage_2:
        jal     air_2_initial_              // air_2_initial_
        nop
        b       _end                        // skip to end
        nop
        
        _begin_stage_3:
        jal     air_3_initial_              // air_3_initial_
        nop
        b       _end                        // skip to end
        nop
        
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
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
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
    // Subroutine which handles ground collision for Kirby's neutral special actions
    scope kirby_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
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
    // Subroutine which handles ground to air transition for neutral special actions
    scope ground_to_air_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0024(sp)              // 0x0024(sp) = player struct
        
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x0024(v0)              // t6 = current action
        addiu   a1, t6, 0x0007              // a1 = equivalent air action for current ground action (id + 7)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x2003                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x2003 (continue: sword trails, gfx routines, hitboxes)
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0024(sp)              // a0 = player struct
        
        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which handles air to ground transition for neutral special actions
    scope air_to_ground_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x0024(v0)              // t6 = current action
        addiu   a1, t6,-0x0007              // a1 = equivalent air action for current ground action (id - 7)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x2003                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x2003 (continue: sword trails, gfx routines, hitboxes)
        
        _end:
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }
}

// @ Description
// Subroutines for Marth Down special (counter).
scope MarthDSP {
    // @ Description
    // Subroutine which runs when Marth initiates a grounded down special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marth.Action.DSP_Ground // a1(action id) = DSP_Ground
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
        sw      r0, 0x0B18(a0)              // hit detection = FALSE
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Marth initiates an aerial down special.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marth.Action.DSP_Air    // a1(action id) = DSP_Air
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
        sw      r0, 0x0B18(a0)              // hit detection = FALSE
        sw      r0, 0x004C(a0)              // y velocity = 0
        lwc1    f4, 0x0048(a0)              // f4 = x velocity
        lui     at, 0x3F00                  // ~
        mtc1    at, f6                      // f6 = 0.5
        mul.s   f4, f4, f6                  // f4 = x velocity * 0.5
        swc1    f4, 0x0048(a0)              // store updated x velocity
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which begins Marth's grounded down special attack action.
    scope ground_attack_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marth.Action.DSP_Ground_Attack // a1(action id) = DSP_Ground_Attack
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
    // Subroutine which begins Marth's aerial neural special attack action.
    scope air_attack_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, Marth.Action.DSP_Air_Attack // a1(action id) = DSP_Air_Attack
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
    // Main subroutine for down special.
    // If temp variable 1 is set by moveset, make Marth invincible, and check for hits.
    scope main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beqz    t6, _hit_detection_check    // branch if temp variable 1 isn't set
        sw      r0, 0x07E8(v0)              // set armour to 0
        
        // if temp variable 1 is set
        lui     at, 0x4800                  // ~
        sw      at, 0x07E8(v0)              // set armour to a very high amount (should be unbreakable)
        
        _hit_detection_check:
        lw      t6, 0x0B18(v0)              // t6 = hit detection
        beqz    t6, _idle_check             // branch if hit detection = FALSE
        nop
        
        // if marth has been hit
        lw      t6, 0x07FC(v0)              // t6 = hit direction
        sw      t6, 0x0044(v0)              // direction = hit direction
        mtc1    t6, f6                      // ~
        cvt.s.w f6, f6                      // f6 = direction
        lui     at, 0x8013                  // ~
        lwc1    f8, 0xFE90(at)              // at = rotation constant
        mul.s   f8, f8, f6                  // f8 = rotation constant * direction
        lw      t6, 0x08E8(v0)              // t6 = character control joint struct
        swc1    f8, 0x0034(t6)              // update character rotation to match direction
        lw      t6, 0x014C(v0)              // t6 = kinetic state
        bnez    t6, _aerial                 // branch if kinetic state !grounded
        nop
        
        jal     ground_attack_initial_      // begin grounded attack action
        nop
        b       _end                        // end
        nop
        
        _aerial:
        jal     air_attack_initial_         // begin aerial attack action
        nop
        b       _end                        // end
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
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }
    
    // @ Description
    // Subroutine which handles physics for Marth's aerial down special.
    scope air_physics_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        
        jal     0x800D91EC                  // physics subroutine (disallows player control)
        nop
        
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lwc1    f4, 0x004C(a0)              // f4 = current y velocity
        lui     at, 0x3FC0                  // ~
        mtc1    at, f6                      // f6 = 1.5
        add.s   f4, f4, f6                  // f4 = current y velocity + 1.5
        swc1    f4, 0x004C(a0)              // store updated y velocity
        
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground collision for down special actions
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
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      v0, 0x0034(sp)              // v0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      t7, 0x0024(v0)              // t7 = current action
        addiu   a1, t7, 0x0002              // a1 = equivalent air action for current ground action (id + 2)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x2803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x2803 (continue: sword trails, 3C command FGM, gfx routines, hitboxes)
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0034(sp)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition for down special actions
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
        addiu   a1, t7,-0x0002              // a1 = equivalent ground action for current air action (id - 2)
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x2803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x2803 (continue: sword trails, 3C command FGM, gfx routines, hitboxes)
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Patch which adds hit detection for counter and prevents Marth from taking damage
    scope detection_patch_: {
        OS.patch_start(0x65A48, 0x800EA248)
        j       detection_patch_
        nop
        _return:
        OS.patch_end()
        
        // a0 = player struct
        // a1 = damage
        addiu   sp, sp,-0x0030              // original line 1
        sw      ra, 0x0014(sp)              // original line 2
        
        lw      t8, 0x0008(a0)              // t8 = character id
        lli     t9, Character.id.MARTH      // t9 = id.MARTH
        bne     t8, t9, _end                // skip if character != MARTH
        nop
        
        _check_action:
        lw      t8, 0x0024(a0)              // t8 = current action
        lli     t9, Marth.Action.DSP_Ground // t9 = Action.DSP_Ground
        beq     t8, t9, _counter            // branch if current action = DSP_Ground
        lli     t9, Marth.Action.DSP_Air    // t9 = Action.DSP_Air
        bne     t8, t9, _end                // skip if current action != DSP_Air
        nop
        
        _counter:
        lw      t8, 0x017C(a0)              // t8 = temp variable 1
        beqz    t8, _end                    // skip if temp variable 1 isn't set
        nop
        
        // if temp variable 1 is set
        or      a1, r0, r0                  // damage = 0
        lli     t8, 0x0001                  // ~
        sw      t8, 0x0B18(a0)              // hit detection = 1
        
        
        _end:
        j       _return                     // return
        nop
    }
}