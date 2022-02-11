// WarioSpecial.asm

// This file contains subroutines used by Wario's special moves.

// @ Description
// Subroutines for Neutral Special
scope WarioNSP {
    constant X_SPEED(0x4280)                // current setting - float:64.0
    constant Y_SPEED(0x41F0)                // current setting - float:30.0
    constant JUMP_SPEED(0x4288)             // current setting - float:68.0
    constant RECOIL_X_SPEED(0xC220)         // current setting - float:-40.0
    constant RECOIL_Y_SPEED(0x4220)         // current setting - float:40.0
    constant GRAVITY(0x4030)                // current setting - float:2.75
    constant MAX_FALL_SPEED(0x4240)         // current setting - float:48.0
    constant AIR_FRICTION(0x4000)           // current setting - float:2.0
    constant GROUND_TRACTION(0x3F00)        // current setting - float:0.5

    constant BEGIN(0x1)
    constant MOVE(0x2)

    constant WALL_COLLISION_L(0x0001)       // bitmask for wall collision
    constant WALL_COLLISION_R(0x0020)       // bitmask for wall collision

    // @ Description
    // Subroutine which runs when Wario initiates a grounded neutral special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        OS.copy_segment(0xD0A54, 0x10)      // copy beginning of subroutine from Mario

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground

        OS.copy_segment(0xD0A64, 0x18)      // copy next part of subroutine from Mario

        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        ori     ra, r0, 0x0001              // ~
        sw      ra, 0x0184(a0)              // temp variable 3 = 0x1(BEGIN)
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which runs when Wario initiates an aerial neutral special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        OS.copy_segment(0xD0A94, 0x14)      // copy beginning of subroutine from Mario

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air

        OS.copy_segment(0xD0AA8, 0x18)      // copy next part of subroutine from Mario
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
        lui     v1, GRAVITY                 // v1 = GRAVITY
        sw      v1, 0x004C(a0)              // y velocity = GRAVITY
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which sets up the movement for the grounded version of Body Slam.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x2 = apply movement speed
    scope ground_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // store t0, t1

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if t0 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0060(a2)              // f0 = current ground x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0060(a2)              // x velocity = (x velocity * 0.875)

        _check_move:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _end                // skip if t0 != MOVE
        nop
        // apply x velocity
        lui     t1, X_SPEED                 // t1 = X_SPEED
        sw		t1, 0x0060(a2)	            // ground x velocity = X_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Wario's grounded neutral special.
    // Copy of subroutine 0x800D8BB4, loads a hard-coded traction value instead of the character's
    // traction value.
    scope ground_physics_: {
        // Copy the first 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543B4, 0x28)
        // Replace original lines which load the base friction from the friction table
        constant UPPER(Surface.friction_table >> 16)
        constant LOWER(Surface.friction_table & 0xFFFF)
        if LOWER > 0x7FFF {
            lui     at, (UPPER + 0x1)
        } else {
            lui     at, UPPER
        }
        addu    at, at, t9
        lwc1    f4, LOWER(at)
        // Replace original line which loads the character's grounded tracion value
        // lwc1 f6, 0x0024(v0)              // replaced line
        lui     a1, GROUND_TRACTION         // ~
        mtc1    a1, f6                      // f6 = GROUND_TRACTION
        // Copy the last 10 lines of subroutine 0x800D8BB4
        OS.copy_segment(0x543EC, 0x28)
    }

    // @ Description
    // Subroutine which handles collision for Wario's grounded neutral special.
    scope ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lbu     a1, 0x000D(a0)              // a1 = player port
        li      a2, special_jim_flag        // ~
        addu    t0, a2, a1                  // t0 = px special_jim_flag address
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bnel    a1, a2, _recoil_check       // skip if a1 != MOVE
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch

        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _recoil_check       // skip if !WALL_COLLISION
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch
        lbu     a1, 0x0000(t0)              // a2 = px special_jim_flag
        bne     a1, r0, _recoil_check       // skip if Jim's special collision flag is enabled
        nop
        // enable the flag to begin recoil
        ori     a1, r0, 0x0001              // ~
        sw      a1, 0x017C(a0)              // temp variable 1 = 0x1 (recoil flag = true)

        _recoil_check:
        li      a1, _end                    // a1 = _end
        jal     check_recoil_               // check for recoil transition
        lw      a0, 0x0010(sp)              // load a0
        li      a1, ground_to_air_          // a1 = ground_to_air_
        jal     0x800DDDDC                  // ground collision (with slide-off)
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      a1, 0x0008(a0)              // a1 = current character id
        lli     a2, Character.id.KIRBY      // a2 = id.KIRBY
        beq     a1, a2, _kirby              // branch if character id = KIRBY
        lli     a2, Character.id.JKIRBY     // a2 = id.JKIRBY
        bne     a1, a2, _wario              // branch if character id != JKIRBY
        nop

        _kirby:
        lw      a1, 0x0024(a0)              // a1 = current action
        lli     a2, Kirby.Action.WARIO_NSP_Ground
        bne     a1, a2, _end                // skip if action id != ground nsp
        nop
        b       _jump                       // check for jump
        nop

        _wario:
        lw      a1, 0x0024(a0)              // a1 = current action
        ori     a2, r0, 0x00DF              // a2 = action id: ground nsp
        bne     a1, a2, _end                // skip if action id != ground nsp
        nop

        _jump:
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bne     a1, a2, _end                // skip if a1 != MOVE
        nop
        jal     0x8013F474                  // check jump (returns 0 for no jump)
        nop
        beq     v0, r0, _end                // skip if !jump
        nop
        lw      a0, 0x0010(sp)              // load a0
        jal     ground_to_air_              // transition from ground to air
        nop
        lw      a0, 0x0010(sp)              // load a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     a1, JUMP_SPEED              // a1 = JUMP_SPEED
        sw      a1, 0x004C(a0)              // y velocity = JUMP_SPEED
        lw      a0, 0x0078(a0)              // a0 = player x/y/z pointer
        ori     a1, r0, 0x0001              // a1 = 0x1
        lui     a2, 0x3F80                  // a2 = float: 1.0
        jal     0x800FF3F4                  // jump smoke graphic
        nop
        ori     a0, r0, 0x005E              // a0 = FGM ID
        jal     FGM.play_                   // play fgm
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles ground to air transition Wario's grounded neutral special.
    scope ground_to_air_: {
        OS.copy_segment(0xDE2EC, 0x18)      // copy beginning of subroutine from Link NSP
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Air

        ori     a1, r0, 0x00E0              // a1 = 0xE0

        OS.copy_segment(0xDE30C, 0x20)      // copy end of subroutine from Link NSP
    }

    // @ Description
    // Subroutine which sets up the movement for the aerial version of Body Slam.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = apply movement speed
    // Also uses command 58000001 for to set y velocity when movement begins.
    scope air_move_: {
        // a2 = player struct
        // 0x184 in player struct = temp variable 3

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~
        sw      t1, 0x0010(sp)              // ~
        swc1    f0, 0x0014(sp)              // ~
        swc1    f2, 0x0018(sp)              // store a0, ra, t0, t1, f0, f2

        _check_begin:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        bne     t0, t1, _check_move         // skip if t0 != BEGIN
        nop
        // slow x movement
        lwc1    f0, 0x0048(a2)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(a2)              // x velocity = (x velocity * 0.875)
        // freeze y position
        lw      t1, 0x09C8(a2)              // t1 = attribute pointer
        lui     t1, GRAVITY                 // t1 = gravity
        sw      t1, 0x004C(a2)              // y velocity = gravity

        _check_move:
        lw      t0, 0x0184(a2)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _check_y            // skip if t0 != MOVE
        nop
        // apply x velocity
        lui     t1, X_SPEED                 // ~
        mtc1    t1, f0                      // f0 = X_SPEED
        lwc1    f2, 0x0044(a2)              // ~
        cvt.s.w f2, f2                      // f2 = DIRECTION
        mul.s   f0, f0, f2                  // f0 = X_SPEED * DIRECTION
        swc1    f0, 0x0048(a2)              // x velocity = X_SPEED * DIRECTION

        _check_y:
        lw      t0, 0x0180(a2)              // temp variable 2
        beq     t0, r0, _end                // skip if temp variable 2 = 0
        nop
        _apply_y:
        sw      r0, 0x0180(a2)              // temp variable 2 = 0
        // falcon punch subroutine which takes stick_y and returns an angle in radians to f0
        jal     0x8015F874                  // return f0 = angle
        lb      a0, 0x01C3(a2)              // a0 = stick_y
        // ultra64 sinf function
        jal     0x800303F0                  // return f0 = sin(angle)
        mov.s   f12, f0                     // f12 = angle
        // sine used to calculate final Y_SPEED
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        mul.s   f0, f0, f2                  // f2 = sin(angle) * X_SPEED
        // multiply by 0.75 to reduce the range of angles
        lui     t0, 0x3F40                  // ~
        mtc1    t0, f2                      // f2 = 0.75
        mul.s   f0, f0, f2                  // f2 = f2 * 0.75
        // add base speed
        lui     t0, Y_SPEED                 // ~
        mtc1    t0, f2                      // f2 = Y_SPEED
        add.s   f0, f0, f2                  // f0 = f2 + Y_SPEED
        swc1    f0, 0x004C(a2)              // store final y velocity

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // ~
        lw      t1, 0x0010(sp)              // ~
        lwc1    f0, 0x0014(sp)              // ~
        lwc1    f2, 0x0018(sp)              // load a0, ra, t0, t1, f0, f2
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Wario's aerial neutral special.
    // Modified version of subroutine 0x800D91EC.
    scope air_physics_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      s1, 0x0018(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        lw      s0, 0x0084(a0)              // ~
        lw      s1, 0x09C8(s0)              // ~
        or      a0, s0, r0                  // original lines
        or      a3, s1, r0                  // a3
        lui     a1, GRAVITY                 // a1 = GRAVITY
        jal     0x800D8D68                  // apply gravity/fall speed
        lui     a2, MAX_FALL_SPEED          // a2 = MAX_FALL_SPEED

        // Subroutine 0x800D9074 applies air friction. Usually, air friction is loaded from
        // 0x0054(a1), with a1 being the attribute pointer for the character. In this case, a
        // different air friction value is stored at 0x0054(sp) and then the stack pointer is
        // passed to a1 for subroutine 0x800D9074.
        or      a0, s0, r0                  // a0 = player struct
        addiu   sp, sp,-0x0058              // allocate stack space
        lui     a1, AIR_FRICTION            // a1 = AIR_FRICTION
        sw      a1, 0x0054(sp)              // store AIR_FRICTION
        jal     0x800D9074                  // apply air friction
        or      a1, sp, r0                  // a1 = stack pointer
        addiu   sp, sp, 0x0058              // deallocate stack space
        lw      ra, 0x001C(sp)              // ~
        lw      s1, 0x0018(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        jr      ra                          // ~
        addiu   sp, sp, 0x0020              // original return logic
    }

    // @ Description
    // Subroutine which handles collision for Wario's aerial neutral special.
    scope air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0010(sp)              // ~
        sw      ra, 0x0014(sp)              // store ra, a0
        lw      a0, 0x0084(a0)              // a0 = player struct
        lbu     a1, 0x000D(a0)              // a1 = player port
        li      a2, special_jim_flag        // ~
        addu    t0, a2, a1                  // t0 = px special_jim_flag address
        lw      a1, 0x0184(a0)              // a1 = temp variable 3
        ori     a2, r0, MOVE                // a2 = MOVE
        bnel    a1, a2, _recoil_check       // skip if a1 != MOVE
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch

        lhu     a1, 0x00CC(a0)              // a1 = collision flags
        lw      t1, 0x0044(a0)              // t0 = direction
        bgezl   t1, _wall_collision         // branch if direction = right
        andi    a1, a1, WALL_COLLISION_L    // a1 = collision flags & WALL_COLLISION_L
        andi    a1, a1, WALL_COLLISION_R    // a1 = collision flags & WALL_COLLISION_R

        _wall_collision:
        beql    a1, r0, _recoil_check       // skip if !WALL_COLLISION
        sb      r0, 0x0000(t0)              // reset px special_jim_flag on branch
        ori     a1, r0, OS.TRUE             // ~
        sb      a1, 0x0000(t0)              // px special_jim_flag = TRUE

        _recoil_check:
        li      a1, _end                    // a1 = _end
        jal     check_recoil_               // check for recoil transition
        lw      a0, 0x0010(sp)              // load a0
        li      a1, air_to_ground_          // a1 = air_to_ground_
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
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which handles air to ground transition Wario's grounded neutral special.
    scope air_to_ground_: {
        OS.copy_segment(0xD098C, 0x1C)      // copy beginning of subroutine from Mario NSP
        ori     t7, r0, 0x0003              // t7 = 0x0003 (hitbox persist)

        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Ground

        ori     a1, r0, 0x00DF              // a1 = 0xDF

        lw      a2, 0x0078(a0)              // a2 = current animation frame
        sw      t7, 0x0010(sp)              // store t7 (some kind of parameter for change action)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0028              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which sets up the movement for the Body Slam recoil.
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
        lw      t0, 0x0180(a2)              // t0 = temp variable 2
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
        lli     t1, Character.id.WARIO      // t1 = id.WARIO
        beq     t1, t0, _modify_y_velocity  // branch if character id = WARIO
        lui     t0, 0x3FA0                  // t0 = 1.25

        // if we're here, the character is Kirby or J Kirby
        // (unless another character is eventually allowed to use Wario's neutral special)
        li      t0, 0x3F0CCCCD              // t0 = 0.55

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
    // Subroutine which handles physics for the recoil.
    // Prevents player control when temp variable 2 = 0
    scope recoil_physics_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // store t0, t1, ra
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control

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
    // Subroutine which handles hitbox collision for Wario's neutral special.
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
        sw      a1, 0x0014(sp)              // overwrite return address in stack
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
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions into Wario's neutral special recoil action.
    scope begin_recoil_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        ori     a0, r0, 0x0117              // a0 = FGM ID
        jal     FGM.play_                   // play fgm
        nop
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
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air

        ori     a1, r0, Wario.Action.NSP_Recoil_Air
        or      a2, r0, r0                  // a2 = 0(begin action frame)
        sw      t7, 0x0010(sp)              // store t7 (some kind of parameter for change action)
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Recoil_Ground.
    scope recoil_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, recoil_air_transition_  // a1(transition subroutine) = air_begin_transition_
        jal     0x800DDE84                  // common ground collision subroutine (transition on no floor, no slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision subroutine for NSP_Recoil_Air.
    scope recoil_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, recoil_ground_transition_ // a1(transition subroutine) = recoil_ground_transition_
        jal     0x800DE80C                  // common air collision subroutine (transition on landing, allow ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which transitions to NSP_Recoil_Ground.
    scope recoil_ground_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEE98                  // set grounded state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Ground
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Ground
        lli     a1, Wario.Action.NSP_Recoil_Ground // a1(action id) = NSP_Recoil_Ground
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
    // Subroutine which transitions to NSP_Recoil_Air.
    scope recoil_air_transition_: {
        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x001C(sp)              // store ra
        sw      a0, 0x0038(sp)              // 0x0038(sp) = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800DEEC8                  // set aerial state
        sw      a0, 0x0034(sp)              // 0x0034(sp) = player struct
        lw      a0, 0x0038(sp)              // a0 = player object
        lw      a2, 0x0084(a0)              // ~
        lw      a2, 0x0008(a2)              // a2 = current character ID
        lli     a1, Character.id.KIRBY      // a1 = id.KIRBY
        beql    a1, a2, pc() + 24           // if Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, Character.id.JKIRBY     // a1 = id.JKIRBY
        beql    a1, a2, pc() + 12           // if J Kirby, load alternate action ID
        lli     a1, Kirby.Action.WARIO_NSP_Recoil_Air
        lli     a1, Wario.Action.NSP_Recoil_Air // a1(action id) = NSP_Recoil_Air
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
    // This is Jim's special collision flag.
    // Its primary purpose is to disable grounded wall collision recoil when Wario transitions from
    // air to ground while already colliding with a wall.
    // Its secondary purpose is to make Jim shut up.
    special_jim_flag:
    db 0x00 //p1
    db 0x00 //p2
    db 0x00 //p3
    db 0x00 //p4
}

// @ Description
// Subroutines for Up Special
scope WarioUSP {
    constant Y_SPEED(0x4280)                // current setting - float:64.0
    constant LANDING_FSM(0x3E80)            // current setting - float:0.25

    // @ Description
    // Subroutine which runs when Wario initiates an up special (both ground/air).
    // Changes action, and sets up initial variable values.
    scope initial_: {
        addiu   sp, sp, 0xFFE0              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // original lines 1-3
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t7, 0x014C(a0)              // t7 = kinetic state
        bnez    t7, _change_action          // skip if kinetic state !grounded
        nop
        jal     0x800DEEC8                  // set aerial state
        nop
        _change_action:
        lw      a0, 0x0020(sp)              // a0 = entity struct?
        sw      r0, 0x0010(sp)              // store r0 (some kind of parameter for change action)
        ori     a1, r0, 0x00E1              // a1 = 0xE1
        or      a2, r0, r0                  // a2 = float: 0.0
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3 = float: 1.0
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
    // Main subroutine for Wario's up special.
    // Based on subroutine 0x8015C750, which is the main subroutine of Fox's up special ending.
    // Modified to load Wario's landing FSM value and disable the interrupt flag.
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
    // Subroutine which allows a direction change for Wario's up special.
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
    // Subroutine which handles movement for Wario's up special.
    // Uses the moveset data command 5C0000XX (orignally identified as "apply throw?" by toomai)
    // This command's purpose appears to be setting a temporary variable in the player struct.
    // The most common use of this variable is to determine when a throw should be applied.
    // Variable values used by this subroutine:
    // 0x1 = begin
    // 0x2 = begin movement
    // 0x3 = movement
    // 0x4 = end movement?
    scope physics_: {
        // s0 = player struct
        // s1 = attributes pointer
        // 0x184 in player struct = temp variable 3
        constant BEGIN(0x1)
        constant BEGIN_MOVE(0x2)
        constant MOVE(0x3)
        constant END_MOVE(0x4)
        addiu   sp, sp,-0x0038              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      s0, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // original store registers
        sw      t0, 0x0024(sp)              // ~
        sw      t1, 0x0028(sp)              // ~
        swc1    f0, 0x002C(sp)              // ~
        swc1    f2, 0x0030(sp)              // ~
        swc1    f4, 0x0034(sp)              // store t0, t1, f0, f2, f4

        OS.copy_segment(0x548F0, 0x40)      // copy from original air physics subroutine
        bnez    v0, _check_begin            // modified original branch
        nop
        li      t8, 0x800D8FA8              // t8 = subroutine which disallows air control
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, BEGIN               // t1 = BEGIN
        beq     t0, t1, _continue           // branch if temp variable 3 = BEGIN
        nop
        li      t8, air_control_            // t8 = air_control_

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
        bne     t0, t1, _check_begin_move   // skip if temp variable 3 != BEGIN
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
        bne     t0, t1, _check_move         // skip if temp variable 3 != BEGIN_MOVE
        nop
        // initialize x/y velocity
        lui     t0, Y_SPEED                 // ~
        mtc1    t0, f4                      // f4 = Y_SPEED
        lwc1    f0, 0x0044(s0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        lb      t0, 0x01C2(s0)              // ~
        mtc1    t0, f2                      // ~
        cvt.s.w f2, f2                      // f2 = stick_x
        mul.s   f0, f2, f0                  // f0 = stick_x * direction
        mtc1    r0, f2                      // f2 = 0
        c.le.s  f2, f0                      // ~
        nop                                 // ~
        bc1f    _apply_movement             // branch if stick_x * direction =< 0
        nop

        // update x velocity based on stick_x
        // f0 = stick_x (relative to direction)
        lui     t0, 0x3F00                  // ~
        mtc1    t0, f2                      // f2 = 0.5
        mul.s   f2, f0, f2                  // f2 = x velocity (stick_x * 0.5)
        // update y velocity based on x velocity (higher x = lower y)
        lui     t0, 0x3E60                  // ~
        mtc1    t0, f0                      // f0 = 0.21875
        mul.s   f0, f0, f2                  // ~
        sub.s   f4, f4, f0                  // f4 = Y_SPEED - (x velocity * 0.21875)

        _apply_movement:
        // f2 = x velocity
        // f4 = y velocity
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
        b       _end                        // end
        nop


        _check_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _check_end_move     // skip if temp variable 3 != MOVE
        nop
        // update y velocity to negate gravity
        lwc1    f0, 0x0058(s1)              // f0 = gravity
        lwc1    f2, 0x004C(s0)              // f2 = y velocity
        add.s   f2, f2, f0                  // f2 = y velocity + GRAVITY
        swc1    f2, 0x004C(s0)              // store updated y velocity

        _check_end_move:
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        ori     t1, r0, END_MOVE            // t1 = END_MOVE
        bne     t0, t1, _end                // skip if temp variable 3 != END_MOVE
        nop
        // slow x movement
        lwc1    f0, 0x0048(s0)              // f0 = current x velocity
        lui     t0, 0x3F60                  // ~
        mtc1    t0, f2                      // f2 = 0.875
        mul.s   f0, f0, f2                  // f0 = x velocity * 0.875
        swc1    f0, 0x0048(s0)              // x velocity = (x velocity * 0.875)
        // freeze y position
        sw      r0, 0x004C(s0)              // y velocity = 0

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
    // Subroutine which handles Wario's horizontal control for up special.
    scope air_control_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      a1, 0x001C(sp)              // ~
        sw      ra, 0x0014(sp)              // ~
        sw      t0, 0x0020(sp)              // ~
        sw      t1, 0x0024(sp)              // store a1, ra, t0, t1
        addiu   a1, r0, 0x0008              // a1 = 0x8 (original line)
        lw      t6, 0x001C(sp)              // t6 = attribute pointer
        lw      a2, 0x004C(t6)              // a2 = air acceleration
        lw      a3, 0x0050(t6)              // a3 = max air speed
        lw      t0, 0x0184(s0)              // t0 = temp variable 3
        _check_move:
        ori     t1, r0, physics_.MOVE       // t1 = MOVE
        beql    t0, t1, _continue           // branch if temp variable 3 = MOVE
        lui     a2, 0x3CC0                  // on branch, a2 = 0.0234375
        _check_end_move:
        ori     t1, r0, physics_.END_MOVE   // t1 = END_MOVE
        beql    t0, t1, _continue           // branch if temp variable 3 = END_MOVE
        lui     a2, 0x3C00                  // on branch, a2 = 0.0078125

        _continue:
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
    // Subroutine which handles collision for Wario's up special.
    // Copy of subroutine 0x80156358, which is the collision subroutine for Mario's up special.
    // Loads the appropriate landing fsm value for Wario.
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
scope WarioDSP {
    constant Y_SPEED(0xC2A0)                // current setting - float:-80.0
    constant INITIAL_Y_SPEED(0x4334)        // current setting - float:180.0
    constant INITIAL_X_SPEED(0x42B4)        // current setting - float:90.0

    constant BEGIN(0x1)
    constant MOVE(0x2)

    // @ Description
    // Subroutine which runs when Wario initiates a grounded down special.
    // Changes action, and sets up initial variable values.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      r0, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x00E3              // a1 = action id: Wario DSP Ground
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
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which runs when Wario initiates an aerial down special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0008              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x00E4              // a1 = action id: Wario DSP Ground
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
        addiu   sp, sp, 0x0020              // ~
        jr      ra                          // original return logic
        nop
    }

    // @ Description
    // Subroutine which sets up the movement for the grounded version of Wario's down special.
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
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which sets up the movement for the aerial version of Wario's down special.
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
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles physics for Wario's down special.
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
        li      t8, 0x800D90E0              // t8 = physics subroutine which allows player control
        bnez    t1, _subroutine             // skip if t1 != 0
        nop
        li      t8, 0x800D91EC              // t8 = physics subroutine which prevents player control

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

        // Checks if the highest bit is set to 1, which is used to represent a negative floating
        // point value. If the highest bit is set to 1, sets y velocity to 0.
        lw      t0, 0x004C(a0)              // t0 = y velocity
        lui     t1, 0x8000                  // t1 = bitmask
        and     t1, t0, t1                  // t1 = 0 if y velocity is positive
        bnel    t1, r0, _end                // execute next instruction if y velocity is negative
        sw      r0, 0x004C(a0)              // y velocity = 0

        _check_move:
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _end                // skip if t0 != MOVE
        nop
        // apply y velocity
        lui     t1, Y_SPEED                 // ~
        sw      t1, 0x004C(a0)              // y velocity = Y_SPEED

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // load t0, t1, ra, a0
        addiu 	sp, sp, 0x0018				// deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Subroutine which handles collision for Wario's down special.
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
        ori     a1, r0, MOVE                // a1 = MOVE
        beq     a1, v0, _main_collision     // branch if temp variable 3 = MOVE
        nop

        // If Wario is not in the ground pound motion, run a normal aerial collision subroutine
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
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which transitions into the landing action for Wario's down special.
    // Copy of subroutine 0x801600EC, which begins the landing action for Falcon Kick.
    // Loads the appropriate landing action for Wario.
    scope begin_landing_: {
        // Copy the first 6 lines of subroutine 0x801600EC
        OS.copy_segment(0xDAB2C, 0x18)
        // Replace original line which loads the landing action id
        // addiu   a1, r0, 0x00E8           // replaced line
        addiu   a1, r0, 0x00E2              // a1 = action id: Wario DSP Landing
        // Copy the last 8 lines of subroutine 0x801600EC
        OS.copy_segment(0xDAB48, 0x20)
    }
}
