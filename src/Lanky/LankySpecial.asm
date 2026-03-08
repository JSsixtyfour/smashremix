// LankySpecial.asm

// This file contains subroutines used by Lanky's special moves.

// For his neutral special, Lanky Kong wields his iconic Grape Shooter
scope LankyNSP {
    // @ Description
    // Subroutine which runs when Lanky initiates a grounded neutral special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.LANKY_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.LANKY_NSP_Ground

        lli     a1, Lanky.Action.NSPG       // a1(action id) = NSPG
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
        lli     at, 3                       // ~
        sw      at, 0x0B20(a0)              // ammo = 3
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which runs when Lanky initiates an aerial neutral special.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.LANKY_NSP_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.LANKY_NSP_Air

        lli     a1, Lanky.Action.NSPA       // a1(action id) = NSPA
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
        lli     at, 3                       // ~
        sw      at, 0x0B20(a0)              // ammo = 3
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main subroutine for neutral special.
    // If temp variable 1 is set by moveset, create a projectile.
    scope main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player object
        addu    a2, a0, r0                  // a2 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        lw      t6, 0x017C(v0)              // t6 = temp variable 1
        beq     t6, r0, _cancel_check       // skip if temp variable 1 = 0
        sw      r0, 0x017C(v0)              // reset temp variable 1 to 0

        // if we're here, then temp variable 1 was enabled, so create a projectile
        lw      t6, 0x0008(v0)              // t6 = current character ID
        lli     at, Kirby.Action.LANKY_NSP_Ground - Lanky.Action.NSPG
        // if kinetic state = aerial
        lli     at, Kirby.Action.LANKY_NSP_Air - Lanky.Action.NSPA
        lw      a2, 0x0008(v0)              // a2 = current character ID
        lli     t6, Character.id.KIRBY      // t6 = id.KIRBY
        beq     t6, a2, _kirby              // branch if Kirby
        lli     t6, Character.id.JKIRBY     // t6 = id.JKIRBY
        beq     t6, a2, _kirby              // branch if JKirby
        lw      a0, 0x0930(v0)              // a0 = part 0xE (weapon) struct
        sw      r0, 0x0020(sp)              // x offset = 0
        lui     at, 0xC348                  // ~
        sw      at, 0x0024(sp)              // y offset = -200
        b       _continue
        sw      r0, 0x0028(sp)              // z offset = 0

        _kirby:
        lw      a0, 0x092C(v0)              // a0 = part 0xD (weapon) struct
        lui     at, 0x4396                  // ~
        sw      at, 0x0020(sp)              // x offset = 200
        sw      r0, 0x0024(sp)              // y offset = 0
        sw      r0, 0x0028(sp)              // z offset = 0

        _continue:
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        sw      v0, 0x002C(sp)              // 0x002C(sp) = player struct
        sw      r0, 0x0028(sp)              // set z coordinate to 0
        lw      v0, 0x002C(sp)              // v0 = player struct
        lw      a0, 0x0034(sp)              // a0 = player object
        jal     grape_stage_setting_        // INITIATE GRAPE
        addiu   a1, sp, 0x0020              // a1 = coordinates to create projectile at
        lw      a0, 0x0034(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct

        _cancel_check:
        lw      t6, 0x0180(v0)              // t6 = temp variable 2
        beq     t6, r0, _idle_check         // skip if temp variable 2 = 0
        lhu     t7, 0x01BE(v0)              // t7 = buttons_pressed

        andi    at, t7, Joypad.B            // at = !0 if (B_PRESSED), else t6 = 0
        beqz    at, _idle_check             // skip if B isn't pressed
        nop

        // if B was pressed
        lw      t0, 0x0B20(v0)              // t0 = ammo
        addiu   at, t0,-0x0001              // at = ammo - 1
        sw      at, 0x0B20(v0)              // store updated ammo...
        beqzl   t0, _idle_check             // skip if ammo = 0
        sw      r0, 0x0B20(v0)              // and set ammo to 0
        lw      a2, 0x014C(v0)              // a2 = kinetic state
        beqz    a2, pc() + 12               // branch if kinetic state = grounded
        // if kinetic state = grounded
        lli     a1, Lanky.Action.NSPG
        // if kinetic state = aerial
        lli     a1, Lanky.Action.NSPA
        beqz    a2, pc() + 12               // branch if kinetic state = grounded
        // if kinetic state = grounded
        lli     at, Kirby.Action.LANKY_NSP_Ground - Lanky.Action.NSPG
        // if kinetic state = aerial
        lli     at, Kirby.Action.LANKY_NSP_Air - Lanky.Action.NSPA
        lw      a2, 0x0008(v0)              // a2 = current character ID
        lli     t6, Character.id.KIRBY      // t6 = id.KIRBY
        beql    t6, a2, pc() + 20           // if Kirby, adjust action ID
        addu    a1, a1, at
        lli     t6, Character.id.JKIRBY     // t6 = id.JKIRBY
        beql    t6, a2, pc() + 8            // if J Kirby, adjust action ID
        addu    a1, a1, at
        lw      a0, 0x0034(sp)              // a0 = player object
        lui     a2, 0x4160                  // a2(starting frame) = 14
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0034(sp)              // a0 = player object

        lw      a0, 0x0034(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // v0 = player struct
        sw      r0, 0x0180(v0)              // reset temp variable 2

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
    // Subroutine which sets up the initial properties for the projectile.
    // TODO: this is still largely uncommented, and may contain leftover logic that isn't needed.
    scope grape_stage_setting_: {
        constant MAX_POWER(4)
        addiu   sp, sp, -0x0050
        sw      s0, 0x0018(sp)
        li      s0, grape_properties_struct // s0 = projectile properties struct address
        sw      a1, 0x0034(sp)
        sw      ra, 0x001C(sp)
        lw      t6, 0x0084(a0)
        lw      t0, 0x0024(s0)
        lw      t1, 0x0028(s0)
        li      a1, grape_projectile_struct // a1 = main projectile struct address
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
        beq     t5, r0, _continue           // branch if kinetic state = grounded
        lwc1    f12, 0x0018(s0)             // f12 = initial angle (ground)
        lwc1    f12, 0x001C(s0)             // f12 = initial angle (air)

        _continue:
        mtc1    r0, f4                      // f4 = 0
        swc1    f4, 0x0028(v1)              // set z speed? to 0
        swc1    f12, 0x0020(sp)             // 0x0020(sp) = adjusted angle
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
    // Main subroutine for the grape.
    scope grape_main_: {
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
        li      v0, grape_properties_struct // v0 = grape_properties_struct
        lw      a1, 0x000C(v0)              // a1 = gravity
        jal     0x80168088                  // apply gravity to grape
        lw      a2, 0x0004(v0)              // a2 = max speed
        lw      a0, 0x001C(sp)              // a0 = projectile struct
        lw      t1, 0x0020(sp)              // t1 = projectile object
        lw      v1, 0x0074(t1)              // v1 = projectile struct with coordinates/rotation etc (bone struct?)
        li      at, grape_properties_struct // at = grape properties struct
        lwc1    f6, 0x0014(at)              // f6 = rotation speed
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
    // Collision subroutine for the grape.
    // Based on 0x801688C4, which is the equivalent for Charge Shot.
    scope grape_collision_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x00014(sp)             // store ra

        jal     0x80167C04                  // general collision detection?
        sw      a0, 0x0018(sp)              // 0x0018(sp) = projectile object
        beqz    v0, _end                    // end if collision wasn't detected
        lw      a0, 0x0018(sp)              // a2 = projectile object
        // if collision was detected
        jal     grape_destruction_
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // This subroutine spawns a hit effect and destroys the GRAPE
    scope grape_hit_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = projectile object
        lw      v1, 0x0084(a0)              // v1 = projectile struct
        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = x/y/z coordinates
        or      a1, r0, r0                  // a1 = 0
        lw      a2, 0x0234(v1)              // a2 = damage
        jal     0x800FDC04                  // create "normal hit" gfx
        or      a3, r0, r0                  // a3 = 0
        jal     grape_destruction_          // destroy the grape
        lw      a0, 0x0018(sp)              // a0 = projectile obect
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // This subroutine destroys the grape and creates a smoke gfx.
    scope grape_destruction_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a0, 0x0074(a0)              // ~
        addiu   a0, a0, 0x001C              // a0 = projectile x/y/z coords
        jal     0x800FF648                  // create smoke gfx
        lui     a1, 0x3F80                  // a1 = 1.0
        jal     0x800269C0                  // play FGM
        lli     a0, 1521                    // FGM id = 1521
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        lli     v0, OS.TRUE                 // return TRUE (destroys projectile)
    }

    OS.align(16)
    grape_projectile_struct:
    dw 0x00000000                           // unknown
    dw Projectile.id.LANKY_NUT              // projectile id
    dw Character.LANKY_file_6_ptr           // address of conker's file 6 pointer
    dw 0x00000000                           // offset to hitbox
    dw 0x12470000                           // This determines z axis rotation? (samus is 1246)
    dw grape_main_                          // This is the main subroutine for the projectile, handles duration and other things. (default 0x80168540) (samus 0x80168F98)
    dw grape_collision_                     // This is the collision subroutine for the projectile, responsible for detecting collision with clipping.
    dw grape_hit_                           // This function runs when the projectile collides with a hurtbox.
    dw grape_destruction_                   // This function runs when the projectile collides with a shield.
    dw 0x801686F8                           // This function runs when the projectile collides with edges of a shield and bounces off
    dw grape_destruction_                   // This function runs when the projectile collides/clangs with a hitbox.
    dw 0x801692C4                           // This function runs when the projectile collides with Fox's reflector (default 0x80168748)
    dw grape_destruction_                   // This function runs when the projectile collides with Ness's psi magnet
    OS.copy_segment(0x103904, 0x0C)         // empty

    OS.align(16)
    grape_properties_struct:
    dw 70                                   // 0x0000 - duration (int)
    float32 50                              // 0x0004 - max speed
    float32 0                               // 0x0008 - min speed
    float32 0                               // 0x000C - gravity
    float32 0                               // 0x0010 - bounce multiplier
    float32 0.4                             // 0x0014 - rotation speed
    float32 0                               // 0x0018 - initial angle (ground)
    float32 0                               // 0x001C   initial angle (air)
    float32 40                              // 0x0020   initial speed
    dw Character.LANKY_file_6_ptr           // 0x0024   projectile data pointer
    dw 0x00000000                           // 0x0028   unknown (default 0)
    dw 0x00000000                           // 0x002C   palette index (0 = mario, 1 = luigi)
}

// Inflates himself, just like a balloon.
scope LankyUSP {
    constant Y_SPEED(0x4180)                // current setting - float32 16
    constant END_Y_SPEED(0x4248)            // current setting - float32 50
    constant AIR_ACCELERATION(0x3C24)       // current setting - float32 0.01
    constant AIR_SPEED(0x41C0)              // current setting - float32 24
    constant LANDING_FSM(0x3EC0)            // current setting - float32 0.375
    constant TURN_SPEED(0x3DD67770)         // current setting - float32 0.10472 rads/6 degrees
    constant MAX_TIME(120)

    // @ Description
    // Initial function for USPGBegin.
    scope ground_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v1, 0x0084(a0)              // v1 = player struct

        lli     a1, Lanky.Action.USPGBegin  // a1(action id) = USPG
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
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
    // Initial function for USPABegin.
    scope air_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        lli     a1, Lanky.Action.USPABegin  // a1(action id) = USPA
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x004C(a0)              // y velocity = 0
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial function for USPMove.
    scope move_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0

        lli     a1, Lanky.Action.USPMove    // a1(action id) = USPMove
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0803 (continue: 3C FGM, gfx routines, hitboxes)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~

        // take mid-air jumps away at this point
        lw      t0, 0x09C8(a0)              // t0 = attribute pointer
        lw      t0, 0x0064(t0)              // t0 = max jumps
        sb      t0, 0x0148(a0)              // jumps used = max jumps
        lli     t0, 0x0001                  // ~
        sw      t0, 0x014C(a0)              // kinetic state = aerial
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial function for USPTurn
    scope turn_intial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lli     a1, Lanky.Action.USPTurn    // a1(action id) = Action.USPTurn
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0803 (continue: 3C FGM, gfx routines, hitboxes)
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for USPEnd
    // a1 = argument 4
    scope end_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        sw      a1, 0x0010(sp)              // store argument 4
        lli     a1, Lanky.Action.USPEnd     // a1(action id) = Action.USPEnd
        or      a2, r0, r0                  // a2(starting frame) = 0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, END_Y_SPEED             // ~
        sw      at, 0x004C(a0)              // y velocity = END_Y_SPEED
        lli     at, 0x0001                  // ~
        sw      at, 0x0180(a0)              // temp variable 2 = 1
        sw      at, 0x0184(a0)              // temp variable 3 = 1
        OS.routine_end(0x30)
    }

    // @ Description
    // Main function for USPABegin and USPGBegin.
    scope begin_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // transition to USPMove if the animation has ended
        lw      a1, 0x0084(a0)              // a1 = player struct
        lli     at, MAX_TIME                // at = MAX_TIME
        jal     move_initial_               // begin USPMove
        sw      at, 0x0B18(a1)              // USPMove timer = MAX_TIME

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0040              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Main function for USPMove.
    scope main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      v1, 0x0084(a0)              // v1 = player struct

        _update_timer:
        lw      at, 0x0B18(v1)              // at = timer
        addiu   at, at, -1                  // decrement timer by 1
        lli     a1, 0x0803                  // argument 4 = 0x0803 (continue: 3C FGM, gfx routines, hitboxes)
        beqz    at, _end_movement           // end up special if timer has expired
        sw      at, 0x0B18(v1)              // store updated timer

        _check_cancel:
        lhu     v0, 0x01BE(v1)              // v0 = buttons_pressed
        andi    at, v0, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
        beqz    at, _check_turn             // skip if (!B_PRESSED)
        lli     a1, 0x0003                  // argument 4 = 0x0003 (continue: gfx routines, hitboxes)

        // when the timer expires, or b is pressed
        _end_movement:
        jal     end_initial_                // begin USPEnd
        nop
        b       _end                        // end
        nop

        _check_turn:
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        bnez    at, _end                    // branch if |stick_x| < 11
        lb      t6, 0x01C2(v1)              // t6 = stick_x

        // if |stick_x| >= 10
        lui     at, 0x8000                  // at = sign bitmask
        and     t6, t6, at                  // t6 = stick_x sign
        lw      t7, 0x0044(v1)              // t7 = DIRECTION
        and     t7, t7, at                  // t7 = DIRECTION sign
        beq     t6, t7, _end                // end if DIRECTION and stick_x signs match
        nop

        // if the signs of DIRECTION and stick_x don't match, begin a turn
        _begin_turn:
        jal     turn_intial_                // begin USPTurn
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for USPTurn.
    scope turn_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      at, 0x017C(v1)              // at = temp variable 1
        beqz    at, _update_timer           // branch if temp variable 1 not set
        lw      at, 0x0044(v1)              // at = DIRECTION

        // if temp variable 2 is set
        subu    at, r0, at                  // ~
        sw      at, 0x0044(v1)              // reverse and update DIRECTION
        sw      r0, 0x017C(v1)              // reset temp variable 1

        _update_timer:
        lw      at, 0x0B18(v1)              // at = timer
        addiu   at, at, -1                  // decrement timer by 1
        lli     a1, 0x0803                  // argument 4 = 0x0803 (continue: 3C FGM, gfx routines, hitboxes)
        beqz    at, _end_movement           // end up special if timer has expired
        sw      at, 0x0B18(v1)              // store updated timer

        _check_cancel:
        lhu     v0, 0x01BE(v1)              // v0 = buttons_pressed
        andi    at, v0, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
        beqz    at, _check_ending           // skip if (!B_PRESSED)
        lli     a1, 0x0003                  // argument 4 = 0x0003 (continue: gfx routines, hitboxes)

        // when the timer expires, or b is pressed
        _end_movement:
        jal     end_initial_                // begin USPEnd
        nop
        b       _end                        // end
        nop

        // checks the current animation frame to see if we've reached end of the animation
        _check_ending:
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        jal     move_initial_               // begin USPMove
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for USPEnd.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Lanky's landing FSM value and disable the interrupt flag.
    scope end_main_: {
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
    // Main function for USPDamage.
    // Based on 0x8014053C ftCommon_DamageAirCommon_ProcUpdate
    scope damage_main_: {
        OS.routine_begin(0x20)
        lw      t6, 0x0084(a0)              // t6 = player struct
        jal     0x80140454                  // ftCommon_Damage_UpdateDustGFX
        sw      a0, 0x0020(sp)              // 0x0020(sp) = player object
        jal     0x801404B8                  // ftCommon_Damage_DecHitStunSetPublicity
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      t6, 0x001C(sp)              // t6 = player struct
        lw      t7, 0x0B18(t6)              // t7 = hitstun_timer
        bnez    t7, _end                    // skip if hitstun_timer != 0
        nop

        // if the hitstun timer has ended
        jal     0x80143664                  // ftCommon_DamageFall_SetStatusFromDamage
        nop

        _end:
        OS.routine_end(0x20)
    }

    // @ Description
    // Function which handles movement for Lanky's up special.
    scope physics_: {
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // store ra, s0, s1

        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      s1, 0x09C8(s0)              // s1 = attribute pointers

        or      a0, s0, r0                  // a0 = player struct
        jal     air_control_                // air control subroutine
        or      a1, s1, r0                  // a1 = attributes pointer
        or      a0, s0, r0                  // a0 = player struct
        jal     0x800D9074                  // air friction subroutine?
        or      a1, s1, r0                  // a1 = attributes pointer

        // apply y velocity during movement
        lui     t1, Y_SPEED                 // t1 = Y_SPEED
        sw      t1, 0x004C(s0)              // y velocity = Y_SPEED

        _end:
        lw      ra, 0x001C(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // loar ra, s0, s1
        addiu   sp, sp, 0x0038              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Function which handles Lanky's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        // load an immediate value into a2 instead of the air acceleration from the attributes
        lui     a2, AIR_ACCELERATION        // a2 = AIR_ACCELERATION
        lui     a3, AIR_SPEED               // a3 = AIR_SPEED
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
    // Function which handles movement for USPDamage.
    scope damage_physics_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      s0, 0x001C(sp)              // store ra, a0, s0

        lw      s0, 0x0084(a0)              // s0 = player struct
        lw      v1, 0x0B18(s0)              // v1 = hitstun_timer
        bnez    v1, _get_stick_angle        // branch if hitstun_timer != 0
        nop

        // if hitstun timer has ended
        jal     0x800D9160                  // ftPhysics_ApplyAirVelDriftFastFall
        lw      a0, 0x0018(sp)              // a0 = player object

        _get_stick_angle:
        lb      t0, 0x01C2(s0)              // t0 = stick_x
        lb      t1, 0x01C3(s0)              // t1 = stick_y
        mtc1    t1, f12                     // ~
        mtc1    t0, f14                     // ~
        cvt.s.w f12, f12                    // f12 = stick y
        cvt.s.w f14, f14                    // f14 = stick x
        mul.s   f8, f12, f12                // ~
        mul.s   f10, f14, f14               // ~
        add.s   f8, f8, f10                 // ~
        sqrt.s  f8, f8                      // f8 = absolute stick x/y
        lui     at, 0x4120                  // ~
        mtc1    at, f6                      // f6 = 10
        c.le.s  f6, f8                      // ~
        nop                                 // ~
        bc1fl   _update_model               // skip if absolute stick < 10
        nop

        jal     0x8001863C                  // f0 = atan2(f12,f14)
        nop
        swc1    f0, 0x0020(sp)              // 0x0020(sp) = stick angle

        _get_knockback_angle:
        lwc1    f12, 0x0058(s0)             // f12 = knockback velocity y
        lwc1    f14, 0x0054(s0)             // f14 = knockback velocity x
        mul.s   f8, f12, f12                // ~
        mul.s   f10, f14, f14               // ~
        add.s   f8, f8, f10                 // ~
        sqrt.s  f8, f8                      // f8 = absolute knockback velocity
        jal     0x8001863C                  // f0 = atan2(f12,f14)
        swc1    f8, 0x0024(sp)              // 0x0024(sp) = knockback velocity
        swc1    f0, 0x0028(sp)              // 0x0028(sp) = knockback angle

        _get_turn_angle:
        mtc1    r0, f0                      // f0 = 0
        li      at, 0x40C90FE4              // ~
        mtc1    at, f2                      // f2 = 6.28319 rads/360 degrees
        li      at, 0x40490FD0              // ~
        mtc1    at, f4                      // f4 = 3.14159 rads/180 degrees
        li      at, TURN_SPEED              // ~
        mtc1    at, f6                      // f6 = TURN_SPEED
        lwc1    f10, 0x0028(sp)             // f10 = current knockback angle
        lwc1    f12, 0x0020(sp)             // f12 = stick angle
        // normalize the angles to a 0-360 range
        add.s   f14, f10, f2                // f14 = knockback angle + 180
        add.s   f16, f12, f2                // f16 = stick angle + 180
        sub.s   f8, f16, f14                // f8 = angle difference (stick - knockback)
        c.lt.s  f0, f8                      // ~
        nop                                 // ~
        bc1fl   _calculate_turn             // branch if angle difference < 0...
        add.s   f8, f8, f2                  // ...and add 360 to angle difference

        _calculate_turn:
        c.lt.s  f6, f8                      // ~
        nop                                 // ~
        bc1fl   _update_model               // branch if absolute angle difference < TURN_SPEED
        nop
        c.lt.s  f8, f4                      // ~
        nop                                 // ~
        bc1fl   _apply_turn                 // branch if angle difference > 180...
        neg.s   f6, f6                      // ...and set f6 to -TURN_SPEED

        _apply_turn:
        add.s   f10, f10, f6                // f10 = knockback angle + TURN_SPEED

        _apply_movement:
        swc1    f10, 0x0028(sp)              // 0x0028(sp) = knockback angle
        // ultra64 cosf function
        jal     0x80035CD0                  // f0 = cos(f12)
        lwc1    f12, 0x0028(sp)             // f12 = knockback angle
        lwc1    f4, 0x0024(sp)              // f4 = knockback velocity
        mul.s   f4, f4, f0                  // f4 = knockback x velocity (velocity * cos(angle))
        swc1    f4, 0x0054(s0)              // store updated knockback x velocity
        // ultra64 sinf function
        jal     0x800303F0                  // f0 = sin(f12)
        lwc1    f12, 0x0028(sp)             // f12 = knockback angle
        lwc1    f4, 0x0024(sp)              // f4 = knockback velocity
        mul.s   f4, f4, f0                  // f4 = knockback y velocity (velocity * sin(angle))
        swc1    f4, 0x0058(s0)              // store updated knockback y velocity

        _update_model:
        jal     0x80140744                  // ftCommon_DamageFlyRoll_UpdateModelRoll
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      ra, 0x0014(sp)              // ~
        lw      s0, 0x001C(sp)              // loar ra, s0
        addiu   sp, sp, 0x0050              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision function for USPABegin
    scope begin_ground_collision_: {
        OS.routine_begin(0x18)
        li      a1, begin_ground_to_air_  // a1(transition subroutine) = begin_ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        OS.routine_end(0x18)
    }

    // @ Description
    // Collision function for USPABegin
    scope begin_air_collision_: {
        OS.routine_begin(0x18)
        li      a1, begin_air_to_ground_  // a1(transition subroutine) = begin_air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        OS.routine_end(0x18)
    }

    // @ Description
    // Function which handles ground to air transition for USPABegin
    scope begin_ground_to_air_: {
        OS.routine_begin(0x50)
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lli     a1, Lanky.Action.USPABegin // a1 = Action.USPABegin
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0803 (continue: 3C FGM, gfx routines, hitboxes)
        lw      a0, 0x0038(sp)              // a0 = player object
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0084(a0)              // a0 = player struct
        OS.routine_end(0x50)
    }

    // @ Description
    // Function which handles air to ground transition for USPABegin
    scope begin_air_to_ground_: {
        OS.routine_begin(0x50)
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0038(sp)              // a0 = player object

        lli     a1, Lanky.Action.USPGBegin  // a1 = Action.USPGBegin
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lli     t6, 0x0803                  // ~
        jal     0x800E6F24                  // change action
        sw      t6, 0x0010(sp)              // argument 4 = 0x0803 (continue: 3C FGM, gfx routines, hitboxes)
        OS.routine_end(0x50)
    }

    // @ Description
    // Collision wubroutine for Lanky's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Lanky.
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
    // Patch which changes the action to USPDamage when Lanky is hit out of USP.
    scope damage_patch_: {
        OS.patch_start(0xBBDE4, 0x801413A4)
        j       damage_patch_
        nop
        _return:
        OS.patch_end()

        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0008(t0)              // t1 = character id
        lli     at, Character.id.LANKY      // at = id.LANKY
        bne     t1, at, _end                // skip if character != LANKY
        nop
        lw      t1, 0x0024(t0)              // t1 = current action
        lli     at, Lanky.Action.USPGBegin  // at = Action.USPGBegin
        beq     t1, at, _check_action       // branch if current action = USPGBegin
        lli     at, Lanky.Action.USPABegin  // at = Action.USPABegin
        beq     t1, at, _check_action       // branch if current action = USPABegin
        lli     at, Lanky.Action.USPTurn    // at = Action.USPTurn
        beq     t1, at, _check_action       // branch if current action = USPTurn
        lli     at, Lanky.Action.USPMove    // at = Action.USPMove
        bne     t1, at, _end                // skip if current action != USPMove
        nop

        // if Lanky is currently inflated just like a balloon
        // a1 = next action
        _check_action:
        lli     at, Action.DamageElec2      // at = Action.DamageElec2
        beql    at, a1, _electric           // branch if next action = DamageElec2...
        lw      t1, 0x0054(sp)              // ...and t1 = saved damage action
        sltiu   at, a1, Action.DamageFlyHigh // at = 1 if next action < DamageFlyHigh
        bnez    at, _end                    // skip if next action is below DamageFly range
        sltiu   at, a1, Action.DamageFlyRoll + 1 // at = 1 if next action =< DamageFlyRoll
        beqz    at, _end                    // skip if next action is not within DamageFly range
        nop

        // if Lanky is changing to a DamageFly action
        b       _end                        // end...
        lli     a1, Lanky.Action.USPDamage  // ...and use USPDamage instead

        _electric:
        sltiu   at, t1, Action.DamageFlyHigh // at = 1 if saved action < DamageFlyHigh
        bnez    at, _end                    // skip if saved action is below DamageFly range
        sltiu   at, t1, Action.DamageFlyRoll + 1 // at = 1 if saved action =< DamageFlyRoll
        beqz    at, _end                    // skip if saved action is not within DamageFly range
        nop

        // if Lanky's saved damage action is a DamageFly action
        lli     at, Lanky.Action.USPDamage  // ~
        sw      at, 0x0054(sp)              // override saved action

        _end:
        jal     0x800E6F24                  // change action (original line 1)
        lui     a3, 0x3F80                  // original line 2
        j       _return                     // return
        nop
    }
}

// Does a handstand, just for you.
scope LankyDSP {
    constant MIN_SPEED(0x4100)              // float32 8
    constant MAX_SPEED(0x4258)              // float32 54
    constant ACCELERATION(0x4120)           // float32 10
    constant G_SPEED_MULTIPLIER(0x3F50)     // float32 0.8125
    constant MAX_TIME(180)

    // @ Description
    // Initial function for DSPGBegin
    scope ground_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lli     a1, Lanky.Action.DSPGBegin  // a1(action id) = Action.DSPGBegin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPABegin
    scope air_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lli     a1, Lanky.Action.DSPABegin  // a1(action id) = Action.DSPABegin
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPWait and DSPAWait
    scope wait_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      at, 0x014C(v1)              // at = kinetic state
        bnez    at, _begin_wait             // branch if kinetic state != grounded...
        lli     a1, Lanky.Action.DSPAWait   // ...a1(action id) = Action.DSPAWait

        lb      t6, 0x01C2(v1)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        bnez    at, _begin_wait             // branch if |stick_x| < 11
        lli     a1, Lanky.Action.DSPGWait   // else, a1(action id) = Action.DSPGWait

        // if |stick_x| >= 10
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        lui     at, 0x8000                  // at = sign bitmask
        and     t6, t6, at                  // t6 = stick_x sign
        lw      t7, 0x0044(v1)              // t7 = DIRECTION
        and     t7, t7, at                  // t7 = DIRECTION sign
        beq     t6, t7, _begin_move         // branch if DIRECTION and stick_x signs match
        nop

        // if the signs of DIRECTION and stick_x don't match, begin a turn
        _begin_turn:
        jal     turn_intial_                // begin DSPTurn
        nop
        b       _end                        // end
        nop

        // if the signs of DIRECTION and stick_x match, begin moving
        _begin_move:
        jal     move_initial_               // begin DSPMove
        nop
        b       _end                        // end
        nop

        _begin_wait:
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object

        _end:
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPMove
    scope move_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lli     a1, Lanky.Action.DSPMove    // a1(action id) = Action.DSPTurn
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        mtc1    t6, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        lui     at, 0x3F20                  // ~
        mtc1    at, f4                      // f4 = 0.625
        mul.s   f2, f2, f4                  // f2 = stick_x * 0.625
        swc1    f2, 0x0048(v1)              // store updated x velocity
        lwc1    f4, 0x0044(v1)              // ~
        cvt.s.w f4, f4                      // f4 = DIRECTION
        mul.s   f2, f2, f4                  // f2 = X_VELOCITY * DIRECTION
        swc1    f2, 0x0060(v1)              // ground x velocity = X_VELOCITY * DIRECTION
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPTurn
    scope turn_intial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lli     a1, Lanky.Action.DSPTurn    // a1(action id) = Action.DSPTurn
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPLanding
    scope landing_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lli     a1, Lanky.Action.DSPLanding // a1(action id) = Action.DSPLanding
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPTaunt
    scope taunt_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lli     a1, Lanky.Action.DSPTaunt   // a1(action id) = Action.DSPTaunt
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPJumpSquat, based on 0x8014D950 (ftDonkeyThrowFKneeBendSetStatus)
    scope jumpsquat_initial_: {
        mtc1    r0, f0                      // ~
        addiu   sp, sp, -0x28               // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a1, 0x002C(sp)              // ~
        lw      v0, 0x0084(a0)              // ~
        sw      r0, 0x0010(sp)              // original logic
        lli     a1, Lanky.Action.DSPJumpSquat // a1(action id) = Action.DSPJumpSquat
        mfc1    a2, f0                      // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // ~
        sw      v0, 0x0024(sp)              // ~
        lw      v0, 0x0024(sp)              // ~
        mtc1    r0, f8                      // ~
        lb      t6, 0x01C3(v0)              // ~
        swc1    f8, 0x0B1C(v0)              // ~
        mtc1    t6, f4                      // ~
        nop                                 // ~
        cvt.s.w f6, f4                      // ~
        swc1    f6, 0x0B18(v0)              // ~
        lw      t7, 0x002C(sp)              // ~
        sw      r0, 0x0B24(v0)              // ~
        sw      t7, 0x0B20(v0)              // ~
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x28                // ~
        jr      ra                          // original logic
        nop
    }

    // @ Description
    // Initial function for DSPJump, based on 0x8014DAF8 (ftDonkeyThrowFJumpSetStatus)
    scope jump_initial_: {
        addiu   sp, sp, -0x40               // ~
        sw      ra, 0x0024(sp)              // ~
        sw      s0, 0x0020(sp)              // ~
        sw      a0, 0x0040(sp)              // ~
        lw      s0, 0x0084(a0)              // ~
        lw      t7, 0x09C8(s0)              // ~
        or      a0, s0, r0                  // ~
        jal     0x800DEEC8                  // ~
        sw      t7, 0x0038(sp)              // ~
        mtc1    r0, f0                      // ~
        lw      a0, 0x0040(sp)              // original logic
        lli     a1, Lanky.Action.DSPJump    // a1(action id) = Action.DSPJump
        mfc1    a2, f0                      // a2(starting frame) = 0
        j       0x8014DB30                  // return to monke
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
    }

    // @ Description
    // Initial function for DSPPlatDrop
    scope plat_drop_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0,0x001C(sp)               // 0x001C(sp) = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        lli     a1, Lanky.Action.DSPPlatDrop // a1(action id) = Action.DSPPlatDrop
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x001C(sp)              // a0 = player struct
        lw      a0, 0x001C(sp)              // a0 = player struct
        lw      at, 0x00EC(a0)              // ~
        sw      at, 0x0144(a0)              // ignore clipping id
        lli     at, 0x00FE                  // ~
        sb      at, 0x0269(a0)              // reset stick buffer
        sw      r0, 0x004C(a0)              // y velocity = 0
        OS.routine_end(0x30)
    }

    // @ Description
    // Initial function for DSPGCancel and DSPGCancel
    scope cancel_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        sw      a1, 0x001C(sp)              // 0x001C(sp) = jumpsquat flag
        lw      a1, 0x0084(a0)              // a1 = player struct
        lw      at, 0x014C(a1)              // at = kinetic state
        bnez    at, pc() + 12               // if kinetic state != grounded...
        lli     a1, Lanky.Action.DSPACancel // ...a1(action id) = Action.DSPACancel
        lli     a1, Lanky.Action.DSPGCancel // else, a1(action id) = Action.DSPGCancel
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lhu     t6, 0x01BE(a0)              // t6 = buttons_pressed
        sh      t6, 0x0B20(a0)              // set initial value of input buffer

        _check_x:
        lbu     at, 0x0268(a0)              // at = tap_stick_x
        sb      at, 0x0B22(a0)              // store tap_stick_x
        bltz    at, _check_y                // skip if tap_stick_x < 0
        sltiu   at, at, 0x0007              // at = 1 if tap_stick_x < 7
        bnel    at, r0, _check_y            // if tap_stick_x < 7...
        sb      at, 0x0B22(a0)              // set tap_stick_x to 1

        _check_y:
        lbu     at, 0x0269(a0)              // at = tap_stick_y
        sb      at, 0x0B23(a0)              // store tap_stick_y
        bltz    at, _end                    // skip if tap_stick_y < 0
        sltiu   at, at, 0x0006              // at = 1 if tap_stick_y < 5
        bnel    at, r0, _end                // if tap_stick_y < 5...
        sb      at, 0x0B23(a0)              // set tap_stick_y to 1

        _end:
        lw      a1, 0x001C(sp)              // a1 = jumpsquat flag
        lli     at, 0x0001                  // ~
        bnezl   a1, pc() + 8                // if jumpsquat flag = true...
        sb      at, 0x0B23(a0)              // ...set tap_stick_y to 1
        sw      a1, 0x0B24(a0)              // store jumpsquat flag
        OS.routine_end(0x30)
    }


    // @ Description
    // Initial function for DSPGEnd and DSPAEnd
    // a0 - player struct
    scope end_initial_: {
        OS.routine_begin(0x30)
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      at, 0x014C(v1)              // at = kinetic state
        beqz    at, pc() + 12               // if kinetic state = grounded...
        lli     a1, Lanky.Action.DSPGEnd    // ...a1(action id) = Action.DSPGEnd

        lli     a1, Lanky.Action.DSPAEnd    // a1(action id) = Action.DSPAEnd
        lui     at, 0x8000                  // ~
        lw      t6, 0x0044(v1)              // ~
        and     t6, t6, at                  // ~
        lui     at, 0x4180                  // ~
        or      at, at, t6                  // ~
        mtc1    at, f2                      // f2 = 16 * DIRECTION
        lwc1    f4, 0x0048(v1)              // f4 = x velocity
        add.s   f4, f4, f2                  // f4 = x velocity + 16
        swc1    f4, 0x00048(v1)             // store updated y velocity
        lui     at, 0x3EC0                  // ~
        mtc1    at, f2                      // f2 = 0.375
        lwc1    f4, 0x004C(v1)              // f4 = y velocity
        mul.s   f4, f4, f2                  // f4 = y velocity * 0.375
        swc1    f4, 0x0004C(v1)             // store updated y velocity

        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct

        _end:
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        OS.routine_end(0x30)
    }

    // @ Description
    // Main subroutine for DSPBegin and DSPABegin.
    // Transitions to DSPWait on animation end.
    scope begin_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0024(sp)              // store ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        // transition to DSPWait if the animation has ended

        jal     wait_initial_               // begin DSPWait
        nop

        _end:
        lw      ra, 0x0024(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for DSPGWait.
    scope ground_wait_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      v1, 0x0084(a0)              // v1 = player struct

        _check_end:
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        beqz    at, _check_cancel           // skip if stick_y >= -39
        lh      t7, 0x01BE(v1)              // t7 = buttons_pressed

        // if we're here then the stick is being held down, so check if B is pressed
        andi    at, t7, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
        beqz    at, _check_cancel           // skip if (!B_PRESSED)
        nop

        // if the down special input is performed, stop handstanding
        jal     end_initial_                // begin DSPEnd
        nop
        b       _end                        // end
        nop

        _check_cancel:
        andi    at, t7, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED); else at = 0
        bnez    at, _begin_cancel           // begin cancel if A or B is pressed
        lhu     at, 0x01B8(v1)              // at = shield press bitmask
        and     at, at, t7                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _check_taunt        // branch if shield is not pressed
        nop

        // if we're here then Lanky is trying to act out of OrangStand, so go into the cancel action
        _begin_cancel:
        jal     cancel_initial_             // begin DSPCancel
        or      a1, r0, r0                  // jumpsquat flag = FALSE
        b       _end                        // end
        nop

        _check_taunt:
        lhu     at, 0x01BA(v1)              // at = taunt bitmask
        and     at, at, t7                  // at != 0 if taunt pressed; else at = 0
        beql    at, r0, _check_jump         // branch if taunt is not pressed
        nop

        // if we're here then Lanky is trying to do his silly taunt his funny little taunt his goofy taunt
        _begin_taunt:
        jal     taunt_initial_              // begin DSPTaunt
        nop
        b       _end                        // end
        nop

        _check_jump:
        jal     0x8013F474                  // check jump, v0 = jump type
        or      a0, v1, r0                  // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        beq     v0, r0, _check_plat_drop    // skip if !jump
        lw      v1, 0x0084(a0)              // v1 = player struct

        // if we're here then Lanky has input a jump, so transition to DSPJumpSquat
        _begin_jump:
        jal     jumpsquat_initial_          // begin DSPJumpSquat
        or      a1, v0, r0                  // a1 = jump type
        b       _end                        // end
        nop

        _check_plat_drop:
        lw      t6, 0x00F4(v1)              // t6 = clipping id
        andi    t6, t6, 0x4000              // t6 = 0x4000 if platform has drop-through
        beqz    t6, _check_turn             // skip if platform can't be dropped through
        nop
        jal     0x80141E60                  // check if stick slammed down
        or      a0, v1, r0                  // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        beqz    v0, _check_turn             // skip if no plat drop input
        lw      v1, 0x0084(a0)              // v1 = player struct

        // if we're here then Lanky has input a plat drop, so transition to DSPPlatDrop
        _begin_plat_drop:
        jal     plat_drop_initial_          // begin DSPPlatDrop
        nop
        b       _end                        // end
        nop

        _check_turn:
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        bnez    at, _end                    // branch if |stick_x| < 11
        lb      t6, 0x01C2(v1)              // t6 = stick_x

        // if |stick_x| >= 10
        lui     at, 0x8000                  // at = sign bitmask
        and     t6, t6, at                  // t6 = stick_x sign
        lw      t7, 0x0044(v1)              // t7 = DIRECTION
        and     t7, t7, at                  // t7 = DIRECTION sign
        beq     t6, t7, _begin_move         // branch if DIRECTION and stick_x signs match
        nop

        // if the signs of DIRECTION and stick_x don't match, begin a turn
        _begin_turn:
        jal     turn_intial_                // begin DSPTurn
        nop
        b       _end                        // end
        nop

        // if the signs of DIRECTION and stick_x match, begin moving
        _begin_move:
        jal     move_initial_               // begin DSPMove
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for DSPAWait and DSPJump.
    scope air_wait_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      v1, 0x0084(a0)              // v1 = player struct

        _check_end:
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        beqz    at, _check_cancel           // skip if stick_y >= -39
        lh      t7, 0x01BE(v1)              // t7 = buttons_pressed

        // if we're here then the stick is being held down, so check if B is pressed
        andi    at, t7, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
        beqz    at, _check_cancel           // skip if (!B_PRESSED)
        nop

        // if the down special input is performed, stop handstanding
        jal     end_initial_                // begin DSPEnd
        nop
        b       _end                        // end
        nop

        _check_cancel:
        andi    at, t7, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED); else at = 0
        beqz    at, _check_double_jump         // skip if A or B is not pressed
        nop

        // if we're here then Lanky is trying to act out of OrangStand, so go into the cancel action
        _begin_cancel:
        jal     cancel_initial_             // begin DSPCancel
        or      a1, r0, r0                  // jumpsquat flag = FALSE
        b       _end                        // end
        nop

        _check_double_jump:
        jal     0x8014019C                  // ftCommonJumpAerialCheckInterruptCommon
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for DSPMove.
    scope move_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      v1, 0x0084(a0)              // v1 = player struct

        _scale_fsm:
        // adjust the animation speed based on sonic's movement speed
        lwc1    f4, 0x0060(v1)              // f4 = ground x velocity
        lui     at, 0x3CC0                  // ~
        mtc1    at, f2                      // f2 = 0.0234
        mul.s   f2, f2, f4                  // f2 = ground x velocity * 0.0214
        lui     at, 0x3DCD                  // ~
        mtc1    at, f4                      // f4 = 0.1
        add.s   f2, f2, f4                  // f2 = FSM = (ground x velocity * 0.0214) + 0.1
        jal     0x8000BB04                  // fsm subroutine
        mfc1    a1, f2                      // a1 = FSM

        _check_end:
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      v1, 0x0084(a0)              // v1 = player struct
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        beqz    at, _check_cancel           // skip if stick_y >= -39
        lh      t7, 0x01BE(v1)              // t7 = buttons_pressed

        // if we're here then the stick is being held down, so check if B is pressed
        andi    at, t7, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
        beqz    at, _check_cancel           // skip if (!B_PRESSED)
        nop

        // if the down special input is performed, stop handstanding
        jal     end_initial_                // begin DSPEnd
        nop
        b       _end                        // end
        nop

        _check_cancel:
        andi    at, t7, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED); else at = 0
        bnez    at, _begin_cancel           // begin cancel if A or B is pressed
        lhu     at, 0x01B8(v1)              // at = shield press bitmask
        and     at, at, t7                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _check_taunt        // branch if shield is not pressed
        nop

        // if we're here then Lanky is trying to act out of OrangStand, so go into the cancel action
        _begin_cancel:
        jal     cancel_initial_             // begin DSPCancel
        or      a1, r0, r0                  // jumpsquat flag = FALSE
        b       _end                        // end
        nop

        _check_taunt:
        lhu     at, 0x01BA(v1)              // at = taunt bitmask
        and     at, at, t7                  // at != 0 if taunt pressed; else at = 0
        beql    at, r0, _check_jump         // branch if taunt is not pressed
        nop

        // if we're here then Lanky is trying to do his silly taunt his funny little taunt his goofy taunt
        _begin_taunt:
        jal     taunt_initial_              // begin DSPTaunt
        nop
        b       _end                        // end
        nop

        _check_jump:
        jal     0x8013F474                  // check jump, v0 = jump type
        or      a0, v1, r0                  // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        beq     v0, r0, _check_plat_drop    // skip if !jump
        lw      v1, 0x0084(a0)              // v1 = player struct

        // if we're here then Lanky has input a jump, so transition to DSPJumpSquat
        _begin_jump:
        jal     jumpsquat_initial_          // begin DSPJumpSquat
        or      a1, v0, r0                  // a1 = jump type
        b       _end                        // end
        nop

        _check_plat_drop:
        lw      t6, 0x00F4(v1)              // t6 = clipping id
        andi    t6, t6, 0x4000              // t6 = 0x4000 if platform has drop-through
        beqz    t6, _check_turn             // skip if platform can't be dropped through
        nop
        jal     0x80141E60                  // check if stick slammed down
        or      a0, v1, r0                  // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        beqz    v0, _check_turn             // skip if no plat drop input
        lw      v1, 0x0084(a0)              // v1 = player struct

        // if we're here then Lanky has input a plat drop, so transition to DSPPlatDrop
        _begin_plat_drop:
        jal     plat_drop_initial_          // begin DSPPlatDrop
        nop
        b       _end                        // end
        nop

        _check_turn:
        lb      t6, 0x01C2(v1)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        bnez    at, _begin_wait             // branch if |stick_x| < 11
        lb      t6, 0x01C2(v1)              // t6 = stick_x

        // if |stick_x| >= 10
        lui     at, 0x8000                  // at = sign bitmask
        and     t6, t6, at                  // t6 = stick_x sign
        lw      t7, 0x0044(v1)              // t7 = DIRECTION
        and     t7, t7, at                  // t7 = DIRECTION sign
        beq     t6, t7, _end                // end if DIRECTION and stick_x signs match
        nop

        // if the signs of DIRECTION and stick_x don't match, begin a turn
        _begin_turn:
        jal     turn_intial_                // begin DSPTurn
        nop
        b       _end                        // end
        nop

        // if |stick_x| < 11
        _begin_wait:
        lw      t6, 0x0048(v1)              // t6 = x velocity
        bnez    t6, _end                    // skip if x velocity != 0
        nop
        jal     wait_initial_               // begin DSPWait
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for DSPTurn.
    scope turn_main_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object

        lw      v1, 0x0084(a0)              // v1 = player struct
        lw      at, 0x0180(v1)              // at = temp variable 2
        beqz    at, _check_end              // branch if temp variable 2 not set
        lw      at, 0x0044(v1)              // at = DIRECTION

        // if temp variable 2 is set
        subu    at, r0, at                  // ~
        sw      at, 0x0044(v1)              // reverse and update DIRECTION
        sw      r0, 0x0180(v1)              // reset temp variable 2

        _check_end:
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        beqz    at, _check_cancel           // skip if stick_y >= -39
        lh      t7, 0x01BE(v1)              // t7 = buttons_pressed

        // if we're here then the stick is being held down, so check if B is pressed
        andi    at, t7, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
        beqz    at, _check_cancel           // skip if (!B_PRESSED)
        nop

        // if the down special input is performed, stop handstanding
        jal     end_initial_                // begin DSPEnd
        nop
        b       _end                        // end
        nop

        _check_cancel:
        andi    at, t7, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED); else at = 0
        bnez    at, _begin_cancel           // begin cancel if A or B is pressed
        lhu     at, 0x01B8(v1)              // at = shield press bitmask
        and     at, at, t7                  // at != 0 if shield pressed; else at = 0
        beql    at, r0, _check_taunt        // branch if shield is not pressed
        nop

        // if we're here then Lanky is trying to act out of OrangStand, so go into the cancel action
        _begin_cancel:
        jal     cancel_initial_             // begin DSPCancel
        or      a1, r0, r0                  // jumpsquat flag = FALSE
        b       _end                        // end
        nop

        _check_taunt:
        lhu     at, 0x01BA(v1)              // at = taunt bitmask
        and     at, at, t7                  // at != 0 if taunt pressed; else at = 0
        beql    at, r0, _check_jump         // branch if taunt is not pressed
        nop

        // if we're here then Lanky is trying to do his silly taunt his funny little taunt his goofy taunt
        _begin_taunt:
        jal     taunt_initial_              // begin DSPTaunt
        nop
        b       _end                        // end
        nop

        _check_jump:
        jal     0x8013F474                  // check jump, v0 = jump type
        or      a0, v1, r0                  // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        beq     v0, r0, _check_plat_drop    // skip if !jump
        lw      v1, 0x0084(a0)              // v1 = player struct

        // if we're here then Lanky has input a jump, so transition to DSPJumpSquat
        _begin_jump:
        jal     jumpsquat_initial_          // begin DSPJumpSquat
        or      a1, v0, r0                  // a1 = jump type
        b       _end                        // end
        nop

        _check_plat_drop:
        lw      t6, 0x00F4(v1)              // t6 = clipping id
        andi    t6, t6, 0x4000              // t6 = 0x4000 if platform has drop-through
        beqz    t6, _check_ending           // skip if platform can't be dropped through
        nop
        jal     0x80141E60                  // check if stick slammed down
        or      a0, v1, r0                  // a0 = player struct
        lw      a0, 0x0018(sp)              // a0 = player object
        beqz    v0, _check_ending           // skip if no plat drop input
        lw      v1, 0x0084(a0)              // v1 = player struct

        // if we're here then Lanky has input a plat drop, so transition to DSPPlatDrop
        _begin_plat_drop:
        jal     plat_drop_initial_          // begin DSPPlatDrop
        nop
        b       _end                        // end
        nop

        _check_ending:
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        bc1fl   _end                        // skip if animation end has not been reached
        nop

        jal     wait_initial_               // begin DSPWait
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Main function for DSPJumpSquat, based on 0x8014D850 (ftDonkeyThrowFKneeBendSetStatus)
    scope jumpsquat_main_: {
        addiu   sp, sp, -0x18               // ~
        sw      ra, 0x0014(sp)              // ~
        lw      v0, 0x0084(a0)              // ~
        lui     at, 0x3F80                  // ~
        mtc1    at, f6                      // ~
        lwc1    f4, 0x0B1C(v0)              // ~
        lw      t6, 0x0B20(v0)              // ~
        addiu   at, r0, 0x0002              // ~
        add.s   f8, f4, f6                  // ~
        lw      v1, 0x09C8(v0)              // ~
        bne     t6, at, branch_1            // ~
        swc1    f8, 0x0B1C(v0)              // ~
        lui     at, 0x4040                  // ~
        mtc1    at, f10                     // ~
        lwc1    f16, 0x0B1C(v0)             // ~
        c.le.s  f16, f10                    // ~
        nop                                 // ~
        bc1fl   branch_2                    // ~
        lwc1    f18, 0x0B1C(v0)             // ~
        lhu     t7, 0x01C0(v0)              // ~
        addiu   t9, r0, 0x0001              // ~
        andi    t8, t7, 0x000F              // ~
        beqzl   t8, branch_2                // ~
        lwc1    f18, 0x0B1C(v0)             // ~
        sw      t9, 0x0B24(v0)              // ~

        branch_1:
        lwc1    f18, 0x0B1C(v0)             // ~
        branch_2:
        lwc1    f4, 0x0034(v1)              // ~
        c.le.s  f4, f18                     // ~
        nop                                 // ~
        bc1fl   branch_3                    // ~
        lw      ra, 0x0014(sp)              // original logic
        jal     jump_initial_               // begin DSPJump
        nop
        lw      ra, 0x0014(sp)              // ~
        branch_3:
        addiu   sp, sp, 0x18                // ~
        jr      ra                          // original logic
        nop
    }

    // @ Description
    // Interrupt function for DSPJumpSquat
    scope jumpsquat_interrupt_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      v1, 0x0084(a0)              // v1 = player struct

        lb      t6, 0x01C3(v1)              // t6 = stick_y
        slti    at, t6,  53                 // at = 1 if stick_y < 53, else at = 0
        bnez    at, _end                    // skip if stick_y >= 53
        lh      t7, 0x01BE(v1)              // t7 = buttons_pressed

        // if we're here, the stick is being held up, so check for button presses
        andi    at, t7, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED); else at = 0
        beqz    at, _end                    // skip if A or B is not pressed
        nop

        // if we're here then Lanky is trying to act out of OrangStand, so go into the cancel action
        _begin_cancel:
        jal     cancel_initial_             // begin DSPCancel
        lli     a1, OS.TRUE                 // jumpsquat flag = TRUE

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Main subroutine for DSPJump and DSPPlatDrop.
    scope jump_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = player object
        lw      v1, 0x0084(a0)              // v1 = player struct

        _check_end:
        lb      t6, 0x01C3(v1)              // t6 = stick_y
        slti    at, t6, -39                 // at = 1 if stick_y < -39, else at = 0
        beqz    at, _check_cancel           // skip if stick_y >= -39
        lh      t7, 0x01BE(v1)              // t7 = buttons_pressed

        // if we're here then the stick is being held down, so check if B is pressed
        andi    at, t7, Joypad.B            // at = 0x0020 if (B_PRESSED); else at = 0
        beqz    at, _check_cancel           // skip if (!B_PRESSED)
        nop

        // if the down special input is performed, stop handstanding
        jal     end_initial_                // begin DSPEnd
        nop
        b       _end                        // end
        nop

        _check_cancel:
        andi    at, t7, Joypad.B | Joypad.A // at = !0 if (B_PRESSED) or (A_PRESSED); else at = 0
        beqz    at, _check_double_jump         // skip if A or B is not pressed
        nop

        // if we're here then Lanky is trying to act out of OrangStand, so go into the cancel action
        _begin_cancel:
        jal     cancel_initial_             // begin DSPCancel
        or      a1, r0, r0                  // jumpsquat flag = FALSE
        b       _end                        // end
        nop

        _check_double_jump:
        jal     0x8014019C                  // ftCommonJumpAerialCheckInterruptCommon
        nop
        bnez    v0, _end                    // branch if double jump was started
        nop

        // checks the current animation frame to see if we've reached end of the animation
        _check_animation_end:
        lw      a0, 0x0018(sp)              // a0 = player object
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     wait_initial_               // begin DSPWait
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Main subroutine for DSPLanding and DSPTaunt.
    scope landing_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        jal     wait_initial_               // begin DSPWait
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }


    // @ Description
    // Main subroutine for DSPACancel and DSPGCancel.
    scope cancel_main_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0014(sp)              // 0x0014(sp) = ra
        lw      v1, 0x0084(a0)              // v1 = player struct
        lhu     at, 0x0B20(v1)              // at = buffered a/b inputs
        lhu     t6, 0x01BE(v1)              // t6 = buttons_pressed
        or      t6, t6, at                  // t6 = buttons_pressed | buffered inputs
        sh      t6, 0x0B20(v1)              // update input buffer

        // checks the current animation frame to see if we've reached end of the animation
        mtc1    r0, f6                      // ~
        lwc1    f8, 0x0078(a0)              // ~
        c.le.s  f8, f6                      // ~
        nop
        bc1fl   _end                        // skip if animation end has not been reached
        nop
        lw      at, 0x0B24(v1)              // at = jumpsquat flag
        beqz    at, _change_action          // branch if jumpsquat flag = false
        lli     at, 80                      // ~

        // if jumpsquat flag = true
        sb      at, 0x01C3(v1)              // stick_y = 80

        _change_action:
        lhu     at, 0x0B22(v1)              // at = stored tap_stick_x and tap_stick_y
        sh      at, 0x0268(v1)              // at = update tap_stick_x and tap_stick_y
        jal     0x800DEE54                  // transition to idle
        sh      t6, 0x01BE(v1)              // update buttons_pressed

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra
        addiu   sp, sp, 0x0040              // deallocate stack space
    }

    // @ Description
    // Handles ground movement for DSP
    scope ground_physics_: {
        OS.routine_begin(0x40)
        sw      a0, 0x0020(sp)              // ~
        sw      s0, 0x0024(sp)              // store a0, s0
        lw      s0, 0x0084(a0)              // s0 = player struct
        lui     at, ACCELERATION            // ~
        mtc1    at, f12                     // f12 = ACCELERATION

        _check_movement:
        lb      t6, 0x01C2(s0)              // t6 = stick_x
        bltzl   t6, pc() + 8                // if stick_x is negative...
        subu    t6, r0, t6                  // ...make stick_x positive
        slti    at, t6, 11                  // at = 1 if |stick_x| < 11, else at = 0
        beqz    at, _check_stick            // branch if |stick_x| >= 10
        nop

        _check_min_speed:
        // if we're here then stick_x is < 11, so consider the stick neutral
        lui     at, 0x4080                  // ~
        mtc1    at, f12                     // set acceleration to 4
        lwc1    f4, 0x0048(s0)              // ~
        abs.s   f4, f4                      // f4 = absolute x velocity
        lui     at, MIN_SPEED               // ~
        mtc1    at, f6                      // f6 = MIN_SPEED
        c.le.s  f4, f6                      // ~
        bc1fl   _apply_movement             // apply movement if current speed < MIN_SPEED...
        mtc1    r0, f2                      // ...and target x velocity = 0
        // set velocity to 0 if below minimum speed
        addiu   at, r0, -1                  // ~
        sw      at, 0x0B20(s0)              // move timer offset = -1
        b       _end                        // end
        sw      r0, 0x0048(s0)              // x velocity = 0

        _check_stick:
        lui     at, G_SPEED_MULTIPLIER      // ~
        mtc1    at, f0                      // f0 = G_SPEED_MULTIPLIER
        lb      t6, 0x01C2(s0)              // t6 = stick_x
        mtc1    t6, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        abs.s   f4, f2                      // f4 = |stick_x|
        mul.s   f2, f2, f4                  // f2 = stick_x * |stick_x|
        lui     at, 0x3C38                  // ~
        mtc1    at, f4                      // f4 = 0.01123
        mul.s   f2, f2, f4                  // f2 = stick_x^2 * 0.01123
        lui     at, MIN_SPEED               // at = MIN_SPEED
        bltzl   t6, pc() + 8                // if stick_x is negative...
        lui     at, MIN_SPEED | 0x8000      // ...make MIN_SPEED negative
        mtc1    at, f6                      // f6 = MIN_SPEED
        add.s   f2, f2, f6                  // f2 = target x velocity = MIN_SPEED + (stick_x^2 * 0.01123)
        mul.s   f2, f2, f0                  // f2 = target x velocity * SPEED_MULTIPLIER

        _apply_movement:
        lwc1    f4, 0x0048(s0)              // f4 = x velocity
        sub.s   f6, f2, f4                  // f6 = X_DIFF
        abs.s   f8, f6                      // f8 = |X_DIFF|
        lui     at, 0x4000                  // ~
        mtc1    at, f10                     // f10 = 2
        c.le.s  f10, f8                     // ~
        mfc1    t6, f6                      // t6 = X_DIFF
        bc1fl   _set_velocity               // branch if |X_DIFF| < 2...
        mov.s   f2, f4                      // ...and set x velocity to target velocity

        lui     t7, 0x8000                  // ~
        and     t6, t6, t7                  // t6 = sign of X_DIFF
        beql    t6, r0, _set_velocity       // branch if X_DIFF is positive...
        add.s   f4, f4, f12                 // and add ACCELERATION to x velocity
        sub.s   f4, f4, f12                 // subtract ACCELERATION from x velocity

        _set_velocity:
        lui     at, MAX_SPEED               // ~
        mtc1    at, f6                      // f6 = MAX_SPEED
        abs.s   f8, f4                      // f8 |X_VELOCITY|
        mfc1    t6, f4                      // t6 = X_VELOCITY
        lui     t7, 0x8000                  // ~
        and     t6, t6, t7                  // t6 = sign of X_VELOCITY
        c.le.s  f8, f6                      // ~
        or      at, at, t6                  // at = MAX_SPEED, adjusted
        bc1fl   pc() + 8                    // if MAX_SPEED =< X_VELOCITY...
        mtc1    at, f4                      // X_VELOCITY = MAX_SPEED
        swc1    f4, 0x0048(s0)              // store updated x velocity
        lwc1    f6, 0x0044(s0)              // ~
        cvt.s.w f6, f6                      // f6 = DIRECTION
        mul.s   f4, f4, f6                  // f4 = X_VELOCITY * DIRECTION
        swc1    f4, 0x0060(s0)              // ground x velocity = X_VELOCITY * DIRECTION

        _end:
        OS.routine_end(0x40)
    }

    // @ Description
    // Collision subroutine for grounded DSP actions
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
    // Subroutine which handles the transition from ground to air.
    scope ground_to_air_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     wait_initial_               // begin DSPWait
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     0x800D8EB8                  // momentum capture?
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Collision subroutine for aerial DSP actions
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, air_to_ground_          // a1(transition subroutine) = air_to_ground_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles the transition from air to ground.
    scope air_to_ground_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     landing_initial_            // begin DSPLanding
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      ra, 0x001C(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0030              // deallocate stack space
    }

    // @ Description
    // Counts Lanky's DSP taunt as taunt in 1P modes
    scope lanky_fighter_stance_bonus_: {
        OS.patch_start(0x10EEB0, 0x80190650)
        j       lanky_fighter_stance_bonus_
        lw      a0, 0x33C8(a0)              // original line 1 - a0 = ending action
        _return:
        OS.patch_end()

        lli     at, 0xF1                    // at = OrangStandTaunt
        bne     a0, at, _normal             // if not OrangStandTaunt, skip
        lbu     at, 0x0014(t2)              // at = char_id

        lli     t7, Character.id.LANKY
        bne     at, t7, _normal             // if not Lanky, skip
        nop                                 // otherwise, it's OrangStandTaunt

        j       0x80190664                  // treat as if bonus
        lw      t9, 0x0030(t2)              // line at 0x80190660

        _normal:
        j       _return
        addiu   at, r0, Action.Taunt        // original line 2 - at = taunt action
    }
}