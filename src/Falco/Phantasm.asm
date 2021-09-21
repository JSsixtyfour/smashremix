// Phantasm.asm (Fray)

scope Phantasm {
    constant X_SPEED(0x43E6)                // current setting - float:460.0
    constant X_SPEED_END_AIR(0x41F0)        // current setting - float:30.0
    constant X_SPEED_END_GROUND(0x4270)     // current setting - float:60.0
    constant Y_SPEED_INITIAL(0x4248)        // current setting - float:50.0
    constant LANDING_FSM(0x3EB3)            // current setting - float:0.35
    constant B_PRESSED(0x40)                // bitmask for b press
    
    // @ Description
    // Subroutine which sets up the movement for the grounded version of phantasm.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = begin movement
    // 0x3 = end movement
    scope ground_subroutine_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3
        constant MOVE(0x2)
        constant END_MOVE(0x3)
        
        OS.save_registers()
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        
        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer 
        
        _move:
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _check_end_move     // skip if t0 != MOVE
        nop
        lui     t1, X_SPEED                 // t1 = X_SPEED
        sw		t1, 0x0060(a2)	            // ground x velocity = X_SPEED
        
        _shorten:
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _end                // skip if !(B_PRESSED)
        nop
        ori     t1, r0, END_MOVE            // ~
        sw      t1, 0x0184(a2)              // temp variable 3 = END_MOVE
        beq     r0, r0, _end_move           // branch and end movement
        nop
        
        _check_end_move:
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _end                // skip if t0 != END_MOVE
        nop
        
        _end_move:
        lui     t1, X_SPEED_END_GROUND      // t1 = X_SPEED_END_GROUND
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        sw		t1, 0x0060(a2)	            // ground x velocity = X_SPEED
        sw      r0, 0x0184(a2)              // temp variable 3 = 0
        lw      t1, 0x0A88(a2)              // t1 = overlay settings
        li      t2, 0x7FFFFFFF              // t2 = bitmask
        and     t1, t1, t2                  // ~
        sw      t1, 0x0A88(a2)              // disable colour overlay bit
        jal     0x800E8518                  // end hitboxes
        nop
        
        _end:
        OS.restore_registers()
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which sets up the movement for the aerial version of phantasm.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = initial setup
    // 0x2 = freeze y velocity
    // 0x3 = x movement
    // 0x4 = end movement
    // 0x5 = reduce y velocity (slow fall)
    scope air_subroutine_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3
        constant INITIAL_SETUP(0x1)
        constant FREEZE_Y(0x2)
        constant MOVE(0x3)
        constant END_MOVE(0x4)
        constant SLOW_FALL(0x5)
        
        addiu   sp, sp,-0x0010              // allocate stack space
        swc1    f0, 0x0004(sp)              // ~
        swc1    f2, 0x0008(sp)              // store f0, f2
        OS.save_registers()
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        
        _update_buffer:
        lbu     t1, 0x000D(a2)              // t1 = player port
        li      t2, button_press_buffer     // ~
        addu    t3, t2, t1                  // t3 = px button_press_buffer address
        lbu     t1, 0x01BE(a2)              // t1 = button_pressed
        lbu     t2, 0x0000(t3)              // t2 = button_press_buffer
        sb      t1, 0x0000(t3)              // update button_press_buffer with current inputs
        or      t3, t1, t2                  // t3 = button_pressed | button_press_buffer 
        
        _initial_setup:
        ori     t1, r0, INITIAL_SETUP       // t1 = INITIAL_SETUP
        bne     t0, t1, _check_freeze_y     // skip if t0 != INITIAL_SETUP
        nop
        lbu     t1, 0x018D(a2)              // t1 = fast fall flag
        ori     t2, r0, 0x0007              // t2 = bitmask (01111111)
        and     t1, t1, t2                  // ~
        sb      t1, 0x018D(a2)              // disable fast fall flag
        sw      r0, 0x0048(a2)              // x velocity = 0
        lui     t1, Y_SPEED_INITIAL         // ~
        sw      t1, 0x004C(a2)              // y velocity = Y_SPEED_INITIAL
        
        _check_freeze_y:
        ori     t1, r0, FREEZE_Y            // t1 = FREEZE_Y
        beq     t0, t1, _freeze_y           // branch if t0 = FREEZE_Y
        nop
        
        _move:
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _check_end_move     // skip if t0 != MOVE
        nop
        lui     t1, X_SPEED                 // ~
        mtc1    t1, f0                      // f0 = X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = X_SPEED * DIRECTION
        
        _shorten:
        andi    t1, t3, B_PRESSED           // t1 = 0x40 if (B_PRESSED); else t1 = 0
        beq     t1, r0, _freeze_y           // skip if (!B_PRESSED)
        nop
        ori     t1, r0, END_MOVE            // ~
        sw      t1, 0x0184(a2)              // temp variable 3 = END_MOVE
        beq     r0, r0, _end_move           // branch and end movement
        nop
        
        _freeze_y:
        // when attempting to freeze the character's y velocity by setting it to 0 they will fall at a rate equal to their fall speed acceleration
        // therefore the character's fall speed acceleration value needs to be written to their y velocity instead of 0
        lw      t1, 0x09C8(a2)              // t1 = attribute pointer
        lw      t1, 0x0058(t1)              // t1 = fall speed acceleration
        sw      t1, 0x004C(a2)              // overwrite y velocity with fall speed acceleration value
        
        _check_end_move:
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _slow_fall          // skip if t0 != END_MOVE
        nop
        
        _end_move:
        lui     t1, X_SPEED_END_AIR         // ~
        mtc1    t1, f0                      // f0 = X_SPEED_AIR
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED_AIR * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = X_SPEED_AIR * DIRECTION
        ori     t1, r0, SLOW_FALL           // ~
        sw      t1, 0x0184(a2)              // temp variable 3 = SLOW_FALL
        lw      t1, 0x0A88(a2)              // t1 = overlay settings
        li      t2, 0x7FFFFFFF              // t2 = bitmask
        and     t1, t1, t2                  // ~
        sw      t1, 0x0A88(a2)              // disable colour overlay bit
        jal     0x800E8518                  // end hitboxes
        nop
        
        _slow_fall:
        // negative y velocity = moving downwards, so adding to the y velocity will slow the fall
        ori     t1, r0, SLOW_FALL           // t1 = SLOW_FALL
        bne     t0, t1, _end                 // skip if t0 != SLOW_FALL
        nop
        lw      t0, 0x0008(a2)              // t0 = current character ID
        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beq     t0, t1, _end                // if Kirby, skip
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beq     t0, t1, _end                // if J Kirby, skip
        lui     t0, 0x3FCD                  // ~
        mtc1    t0, f0                      // f0 = float:1.6
        lwc1    f2, 0x004C(a2)              // f2 = y velocity
        add.s   f0, f2, f0                  // f0 = y velocity + 1.6
        swc1    f0, 0x004C(a2)              // store updated y velocity
        
        _end:
        OS.restore_registers()
        lwc1    f0, 0x0004(sp)              // ~
        lwc1    f2, 0x0008(sp)              // load f0, f2
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
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
    // Subroutine which controls the physics for aerial phantasm. Applies gravity without allowing
    // for control by default, allows control and fast fall when temp variable 3 = 0x5(SLOW_FALL)
    scope air_physics_: {
        // 0x184 in player struct = temp variable 3
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0184(t0)              // t1 = temp variable 3
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control 
        ori     t6, r0, air_subroutine_.SLOW_FALL
        bne     t1, t6, _subroutine         // skip if t1 != SLOW_FALL
        nop
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        
        _subroutine:
        jalr      t8                        // run physics subroutine
        nop
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu 	sp, sp, 0x0010				// deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Subroutine which handles collision for aerial phantasm.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Falco.
    scope air_collision_: {
        // Copy the first 30 lines of subroutine 0x80156358
        OS.copy_segment(0xD0D98, 0x78)
        // Replace original line which loads the landing fsm
        //lui     a2, 0x3E8F                // original line 1
        lui     a2, LANDING_FSM             // a2 = LANDING_FSM
        // Copy the last 17 lines of subroutine 0x80156358
        OS.copy_segment(0xD0E14, 0x44)
    }
    
    // @ Description
    // Modified version of a short subroutine which resets the temp variables when Fox uses his
    // neutral special. Usually, this subroutine doesn't set the value of temp variable 3.
    scope set_variables_: {
        OS.patch_start(0xD66E0, 0x8015BCA0)
        jal     set_variables_              // ground neutral special
        OS.patch_end()
        OS.patch_start(0xD6724, 0x8015BCE4)
        jal     set_variables_              // air neutral special
        OS.patch_end()
        OS.patch_start(0xD1840, 0x80156E00)
        jal     set_variables_              // kirby ground neutral special
        OS.patch_end()
        OS.patch_start(0xD1884, 0x80156E44)
        jal     set_variables_              // kirby air neutral special
        OS.patch_end()
        
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      t0, 0x0004(sp)              // store t0
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      r0, 0x017C(v0)              // temp variable 1 = 0
        sw      r0, 0x0180(v0)              // temp variable 2 = 0
        ori     t0, r0, 0x0001              // ~
        sw      t0, 0x0184(v0)              // temp variable 3 = 0x1(INITIAL_SETUP)
        lw      t0, 0x0004(sp)              // load t0
        jr      ra
        addiu   sp, sp, 0x0008              // deallocate stack space
    }
}