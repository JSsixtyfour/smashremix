// SlippySpecial.asm

// This file contains subroutines used by Slippy Toad's special moves.

// @ Description
// Subroutines for Neutral Special
scope SlippyNSP {

    // @ Description
    // based on Fox's at 0x8015BC78
    scope kirby_ground_begin_initial: {
        addiu   sp, sp, -0x20
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)
        sw      r0, 0x0010(sp)
        addiu   a1, r0, Kirby.Action.SLIPPY_NSP_Ground
        addiu   a2, r0, 0x0000
        jal     0x800E6F24          // change action
        lui     a3, 0x3F80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x8015BC68
        lw      a0, 0x0020(sp)
        lw      ra, 0x001C(sp)
        jr      ra
        addiu   sp, sp, 0x20
    }

    // based on Fox's at 0x8015BCB8
    scope kirby_air_begin_initial: {
        addiu   sp, sp, -0x20
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)
        addiu   t6, r0, 0x0008
        sw      t6, 0x0010 (sp)
        addiu   a1, r0, Kirby.Action.SLIPPY_NSP_Air
        addiu   a2, r0, 0x0000
        jal     0x800E6F24          // change action
        lui     a3, 0x3F80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x8015BC68
        lw      a0, 0x0020(sp)
        lw      ra, 0x001C(sp)
        jr      ra
        addiu   sp, sp, 0x20
    }

    // @ Description
    // Main subroutine for Slippy's neutral special.
    // a0 = player object
    scope main_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0028(sp)              // store ra, a0
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beql    t6, r0, _continue           // branch if temp variable 1 is not set
        mtc1    r0, f6                      // f6 = 0
        
        // if temp variable 1 is set
        addiu   a1, sp, 0x0018              // 0x0018(sp) = offset coordinates
        sw      r0, 0x017C(v0)              // reset temp variable 1
        sw      r0, 0x0018(sp)              // x offset = 0
        lui     at, 0x4200                  // ~
        sw      at, 0x001C(sp)              // y offset = 32
        lui     at, 0x43AA                  // ~
        sw      at, 0x0020(sp)              // z offset = 340
        jal     0x800EDF24                  // returns x/y/z coordinates of the model part in a0 to a1, a1 can also contain offset coordinates
        lw      a0, 0x092C(v0)              // a0 = weapon part struct
        lw      a0, 0x0028(sp)              // a0 = player object
        jal     laser_stage_setting_        // create projectile
        addiu   a1, sp, 0x0018              // a1 = coordinates to create projectile at
        lw      a0, 0x0028(sp)              // a0 = player object
        mtc1    r0, f6                      // f6 = 0
        
        _continue:
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop                                 // ~
        bc1fl   _end                        // branch if animation end hasn't been reached
        lw      ra, 0x0014(sp)              // load ra
        
        jal     0x800DEE54                  // idle/fall transition
        nop
        lw      ra, 0x0014(sp)              // load ra
        
        _end:
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
        lli     a1, Kirby.Action.SLIPPY_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, _change_action      // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.SLIPPY_NSP_Ground
        
        
        addiu   a1, r0, 0x00E1              // a1 = equivalent ground action for current air action
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
    // Initial subroutine for Slippy's laser.
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
        jal     0x80103320                  // unknown subroutine (pink ball graphic?)
        lw      a0, 0x0024(sp)              // a0 = creation coordinates
        lw      v0, 0x0018(sp)              // v0 = projectile object
        
        _end_stage_setting:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return    
        addiu   sp, sp, 0x0030              // deallocate stack space
    }
    
    
    
    // @ Description
    // Projectile struct for Slippy's laser.
    OS.align(16)
    projectile_struct:
    dw 0x00000000
    dw 0x00000001
    dw Character.SLIPPY_file_6_ptr
    OS.copy_segment(0x10391C, 0x28)
}
	

// @ Description
// Subroutines for Up Special
scope SlippyUSP {
    constant BASE_SPEED(0x41A0)  // float: 20
    constant DECELERATION_FACTOR(0x41C0) // float: 24
    constant TURN_SPEED(0x3D567756) // float: 0.0523599 rads/3 degree
    constant DURATION(64)

    // @ Description
    // Subroutine which controls movement during Slippy's up special.
    scope movement_physics_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store ra, a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      t7, 0x0B28(s0)              // t7 = frame counter
        addiu   t7, t7, 0x0001              // increment frame counter
        slti    at, t7, 0x0002              // ~
        bnez    at, _end                    // skip if first frame of movement (replicated from firefox)
        sw      t7, 0x0B28(s0)              // store updated frame counter

        _get_stick_angle:
        lb      t0, 0x01C2(s0)              // t0 = stick_x
        lb      t1, 0x01C3(s0)              // t1 = stick_y
        lw      t2, 0x0044(s0)              // t2 = direction
        multu   t0, t2                      // ~
        mflo    t0                          // t0 = stick_x * direction
        mtc1    t1, f12                     // ~
        mtc1    t0, f14                     // ~
        cvt.s.w f12, f12                    // f12 = stick y
        cvt.s.w f14, f14                    // f14 = stick x * direction
        mul.s   f8, f12, f12                // ~
        mul.s   f10, f14, f14               // ~
        add.s   f8, f8, f10                 // ~
        sqrt.s  f8, f8                      // f8 = absolute stick x/y
        lui     at, 0x4120                  // ~
        mtc1    at, f6                      // f6 = 10
        c.le.s  f6, f8                      // ~
        nop                                 // ~
        bc1fl   _calculate_speed            // skip if absolute stick < 0...
        lwc1    f10, 0x0B20(s0)             // ...and set new angle to previous angle
        
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        nop
        mov.s   f12, f0                     // f12 = stick angle
        
        _get_turn_angle:
        mtc1    r0, f0                      // f0 = 0
        li      at, 0x40C90FE4              // ~
        mtc1    at, f2                      // f2 = 6.28319 rads/360 degrees
        li      at, 0xC0490FD0              // ~
        mtc1    at, f4                      // f4 = -3.14159 rads/-180 degrees
        li      at, TURN_SPEED              // ~
        mtc1    at, f6                      // f6 = TURN_SPEED    
        lwc1    f10, 0x0B20(s0)             // f10 = current movement angle
        sub.s   f8, f12, f10                // f8 = angle difference: stick angle - current angle
        c.lt.s  f4, f8                      // ~
        nop                                 // ~
        bc1fl   _calculate_turn             // branch if angle difference < -180...
        add.s   f8, f8, f2                  // ...and add 360 degrees to angle differnece
        
        _calculate_turn:
        abs.s   f14, f8                     // f14 = absolute angle difference
        c.lt.s  f6, f14                     // ~
        nop                                 // ~
        bc1fl   _update_angle               // branch and immediately update if absolute angle difference < TURN_SPEED...
        mov.s   f10, f12                    // ...and set movement angle to stick angle
        c.lt.s  f0, f8                      // ~
        nop                                 // ~
        bc1fl   _apply_turn                 // branch if angle difference < 0...
        neg.s   f6, f6                      // ...and set f6 to -TURN_SPEED
        
        _apply_turn:
        add.s   f10, f10, f6                // f10 = previous angle + TURN_SPEED
        
        _update_angle:
        c.lt.s  f4, f10                     // ~
        nop                                 // ~
        bc1fl   _calculate_speed            // branch if new movement angle < -180...
        add.s   f10, f10, f2                // ...and add 360 degrees to movement angle
        
        _calculate_speed:
        swc1    f10, 0x0B20(s0)             // store updated movement angle
        lui     at, 0x3F80                  // ~
        mtc1    at, f2                      // f2 = 1
        lwc1    f4, 0x0B24(s0)              // ~
        cvt.s.w f4, f4                      // f4 = duration remaining
        add.s   f4, f4, f2                  // f4 = duration remaining + 1
        lui     at, DECELERATION_FACTOR     // ~
        mtc1    at, f6                      // f6 = DECELERATION_FACTOR
        div.s   f4, f4, f6                  // ~
        add.s   f4, f4, f2                  // f4 = speed multiplier: 1 + (duration remaining / DECELERATION_FACTOR)
        lui     at, BASE_SPEED              // ~
        mtc1    at, f6                      // ~
        mul.s   f4, f6, f4                  // f4 = SPEED: BASE_SPEED * multiplier
        swc1    f4, 0x0030(sp)              // 0x0030(sp) = SPEED
        
        
        _apply_movement:
        // ultra64 cosf function
        jal     0x80035CD0                  // f0 = cos(f12)
        lwc1    f12, 0x0B20(s0)             // f12 = movement angle
        lwc1    f4, 0x0030(sp)              // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = x velocity (SPEED * cos(angle))
        swc1    f4, 0x0034(sp)              // 0x0034(sp) = x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x0B20(s0)             // f12 = movement angle
        lwc1    f4, 0x0030(sp)              // f4 = SPEED
        mul.s   f4, f4, f0                  // f4 = y velocity (SPEED * sin(angle))
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lwc1    f2, 0x0034(sp)              // f2 = x velocity
        mul.s   f2, f2, f0                  // f2 = x velocity * direction
        swc1    f2, 0x0048(s0)              // store updated x velocity
        swc1    f4, 0x004C(s0)              // store updated y velocity
        
        _end:
        jal     0x8015C054                  // unknown final firefox subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0040              // deallocate stack space
    }
    
    // @ Description
    // Ledge grab check for Slippy.
    scope check_ledge_grab_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        jal     0x800DE87C                  // check ledge/floor collision?
        nop
        beq     v0, r0, _end                // skip if !collision
        nop
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a1, 0x0084(a0)              // a1 = player struct
        lhu     a2, 0x00D2(a1)              // a2 = collision flags?
        andi    a2, a2, 0x3000              // bitmask
        beq     a2, r0, _end                // skip if !ledge_collision
        nop
        jal     0x80144C24                  // ledge grab subroutine
        nop
        
        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }
}

// @ Description
// Subroutines for Down Special
scope SlippyDSP {
    // @ Description
    // Subroutine which handles air physics for Slippy's down special.
    // Copy of subroutine 0x8015CC64, which is the aerial physics subroutine for Fox's Down Special.
    // Essentially it sets the speed to different values
    scope air_physics_: {
        OS.copy_segment(0xD76A4, 0x28)
        beq     r0, r0, _branch
        sw      t7, 0x0B28(a3)
        lui     a1, 0x4020
        lw      a2, 0x005C(t8)
        jal     0x800D8D68
        sw      a3, 0x001C(sp)
        lw      a3, 0x001C(sp)
        _branch:
        OS.copy_segment(0xD76EC, 0x34)
    }
    
}
