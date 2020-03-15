// LucasSpecial.asm

// This file contains subroutines used by Lucas' special moves.

// @ Description
// Subroutines for Neutral Special
scope LucasNSP {
    // upper 2 bytes of x speed as a float, current setting = 40.0
    constant X_SPEED(0x4220)
    
    // @ Description
    // Subroutine which adds horizontal movement to Lucas' aerial pk fire.
    // Applies the movement when set flag command 54000001 is used.
    scope air_move_: {   
        // a2 = player struct
        // 0x17C in player struct = temp variable 1
        // temp variable 1 is set by the comand 5400XXXX 
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        swc1    f0, 0x0010(sp)              // ~
        swc1    f2, 0x0014(sp)              // store a0, ra, t0, t1, f0, f2
        
        _check_move:
        lw      t0, 0x017C(a2)              // t0 = temp variable 1
        beq     t0, r0, _end                // skip if temp variable 1 = 0
        nop   
        
        // continues if temp variable 1 != 0
        // facing direction is used to determine if X_SPEED should be positive or negative
        // facing direction is stored as a signed int of -1 or 1, so if we convert it to a float
        // and then multiply it by X_SPEED we will get the appropriate velocity to apply for the
        // direction the character is facing
        lui     t1, X_SPEED                 // ~
        mtc1    t1, f0                      // f0 = X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED * DIRECTION
        // now, we load the current x velocity and subtract X_SPEED from it
        lwc1    f2, 0x0048(a2)              // f2 = current x velocity
        sub.s   f0, f2, f0                  // f0 = current x velocity - (X_SPEED * DIRECTION)
        swc1    f0, 0x0048(a2)              // store updated x velocity

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lwc1    f0, 0x0010(sp)              // ~
        lwc1    f2, 0x0014(sp)              // load a0, ra, t0, t1, f0, f2
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }
}