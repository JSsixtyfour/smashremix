// DrgaonKing.asm

// This file contains file inclusions, action edits, and assembly for Dragon King.

scope DragonKingUSP {
    constant Y_SPEED(0x4258)                // float32 54
    constant THROW_AIR_FRICTION(0x3FE0)     // float32 1.75
    constant THROW_FALL_SPEED(0x42DC)       // float32 110
    constant THROW_GRAVITY(0x3F00)          // float32 0.5
    constant THROW_GRAVITY_2(0x40E0)        // float32 7

    // @ Description
    // Initial subroutine for USPGround.
    scope ground_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v1, 0x0084(a0)              // v1 = player struct

        lli     a1, DragonKing.Action.USPGround // a1(action id) = USPGround
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        li      a1, ground_throw_initial_   // a1 = ground_throw_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
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
    // Initial subroutine for USPAir.
    scope air_initial_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // store ra, a0
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      v0, 0x0084(a0)              // ~
        li      t6, 0x801605FC              // ~
        sw      t6, 0x0A0C(v0)              // run this falcon function to avoid random bs

        lli     a1, DragonKing.Action.USPAir // a1(action id) = USPAir
        or      a2, r0, r0                  // a2(starting frame) = 0
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        lw      a0, 0x0018(sp)              // a0 = player object
        li      a1, air_pull_initial_       // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0018(sp)              // a0 = player object
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // ~
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        ori     t6, r0, 0x0007              // t6 = bitmask (01111111)
        and     v1, v1, t6                  // ~
        sb      v1, 0x018D(a0)              // disable fast fall flag
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0028              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for USPGroundThrow.
    scope ground_throw_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct

        lli     a1, DragonKing.Action.USPGroundThrow // a1(action id) = USPGroundThrow
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     throw_setup_                // additional command grab setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        sw      r0, 0x0B18(a0)              // turn frame timer = 0
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for USPAirPull.
    scope air_pull_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lw      v1, 0x0084(a0)              // v1 = player struct

        lli     a1, DragonKing.Action.USPAirPull // a1(action id) = USPAirPull
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0020(sp)              // a0 = player object
        jal     throw_setup_                // additional command grab setup
        lw      a0, 0x0020(sp)              // a0 = player object
        lw      a0, 0x0020(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        lui     at, 0x3F00                  // ~
        mtc1    at, f2                      // f2 = 0.5
        lwc1    f4, 0x0048(a0)              // f4 = x velocity
        mul.s   f4, f4, f2                  // f4 = x velocity * 0.5
        lui     at, 0x3E00                  // ~
        mtc1    at, f10                     // f10 = 0.125
        lwc1    f6, 0x004C(a0)              // f6 = y velocity
        mul.s   f6, f6, f10                 // f6 = y velocity * 0.125
        sw      r0, 0x017C(a0)              // temp variable 1 = 0
        sw      r0, 0x0180(a0)              // temp variable 2 = 0
        sw      r0, 0x0184(a0)              // temp variable 3 = 0
        lui     at, Y_SPEED                 // ~
        mtc1    at, f8                      // ~
        add.s   f6, f6, f8                  // y velocity = y velocity * 0.5 + Y_SPEED
        swc1    f4, 0x0048(a0)              // store updated x velocity
        swc1    f6, 0x004C(a0)              // store updated y velocity
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initial subroutine for USPLandingThrow
    scope landing_throw_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEE98                  // set grounded state
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0020(sp)              // a0 = player object
        lli     a1, DragonKing.Action.USPLandingThrow // a1(action id) = Ground_Cmd_Throw
        or      a2, r0, r0                  // a2(starting frame) = 0
        lli     t6, 0x0002                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0002
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
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
    // Subroutine which helps set up the command grab for Dragon King.
    scope throw_setup_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, 0x003F                  // a1 = bitflags?
        jal     0x800E8098                  // sets the byte at 0x193 in the player struct to the value in a1
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      t6, 0x0830(a0)              // ~
        sw      t6, 0x0840(a0)              // update captured player?
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Main function for Up Special throw actions
    scope throw_main_: {
        OS.routine_begin(0x20)
        sw      a0, 0x0018(sp)
        jal     0x8014A0C0                  // original throw routine
        nop
        lw      a0, 0x0018(sp)              // restore a0
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      at, 0x017C(v1)              // at = temp variable 1
        beqz    at, _end                    // skip if temp variable 1 not set
        lli     t6, 0x0001                  // t6 = 1
        bne     t6, at, _end                // if temp variable 1 != 1, skip
        nop

        _drain:
        // heal HP
        lw      t6, 0x0818(v1)
        addiu   t6, t6, 1
        sw      t6, 0x0818(v1)              // increase HP heal by 1
        // drain hp
        lw      a0, 0x0840(v1)              // a0 = captured player object
        lw      a0, 0x0084(a0)              // a0 = captured played struct

        lw      at, 0x05B0(a0)              // at = super star counter
        bnez    at, _end                    // do not apply damage to players with super star
        nop

        li      at, Item.CloakingDevice.cloaked_players
        lbu     t6, 0x000D(a0)          // load port
        addu    at, at, t6              // t5 = players entry in table
        lbu     at, 0x0000(at)
        bnez    at, _end                // do not apply damage to cloaking device players
        nop

        jal     0x800EA248                  // apply 1 damage to captured player
        addiu   a1, r0, 1

        _end:
        OS.routine_end(0x20)
    }

    // @ Description
    // Main function for Up Special air pull
    scope air_pull_main_: {
        OS.routine_begin(0x20)
        lw      v1, 0x0084(a0)              // v1 = player struct

        lw      at, 0x017C(v1)              // at = temp variable 1
        beqz    at, _end                    // skip if temp variable 1 not set
        lli     t6, 0x0001                  // t6 = 1
        bne     t6, at, _end                // if temp variable 1 != 1, skip
        nop

        _drain:
        // heal HP
        lw      t6, 0x0818(v1)
        addiu   t6, t6, 1
        sw      t6, 0x0818(v1)              // increase HP heal by 1
        // drain hp
        lw      a0, 0x0840(v1)              // a0 = captured player object
        lw      a0, 0x0084(a0)              // a0 = captured played struct


        lw      at, 0x05B0(a0)              // at = super star counter
        bnez    at, _end                    // do not apply damage to players with super star
        nop

        li      at, Item.CloakingDevice.cloaked_players
        lbu     t6, 0x000D(a0)          // load port
        addu    at, at, t6              // t5 = players entry in table
        lbu     at, 0x0000(at)
        bnez    at, _end                // do not apply damage to cloaking device players
        nop

        jal     0x800EA248                  // apply 1 damage to captured player
        addiu   a1, r0, 1

        _end:
        OS.routine_end(0x20)
    }

    // @ Description
    // Aerial movement subroutine for USPAirPull
    // Modified version of subroutine 0x800D90E0.
    scope air_pull_physics_: {
        // Copy the first 8 lines of subroutine 0x800D90E0
        OS.copy_segment(0x548E0, 0x20)

        // Skip 7 lines (fast fall branch logic)

        // jal 0x800D8E50                   // ~
        // or a1, s1, r0                    // original 2 lines call gravity subroutine
        lui     a1, THROW_GRAVITY           // a1 = THROW_GRAVITY
        lw      t6, 0x0180(s0)              // t6 = temp variable 2
        bnezl   t6, _apply_gravity          // branch if temp variable 2 is set...
        lui     a1, THROW_GRAVITY_2         // ...and a1 = THROW_GRAVITY_2

        _apply_gravity:
        jal     0x800D8D68                  // apply gravity/fall speed
        lui     a2, THROW_FALL_SPEED        // a1 = THROW_FALL_SPEED

        // Copy the next 8 lines of subroutine 0x800D90E0
        OS.copy_segment(0x54924, 0x20)
        // jal 0x800D9074                   // original line calls air friction subroutine
        jal     air_pull_friction_          // call custom wrapped subroutine instead
        // Copy the last 6 lines of subroutine 0x800D90E0
        OS.copy_segment(0x54948, 0x18)
    }

    scope air_pull_friction_: {
        OS.routine_begin(0x80)
        // use sp as fake attribute pointer for custom air friction
        lui     at, THROW_AIR_FRICTION      // ~
        sw      at, 0x0054(sp)              // 0x0054(sp) = THROW_AIR_FRICTION
        jal     0x800D9074                  // air friction function
        or      a1, sp, r0                  // a1 = sp
        OS.routine_end(0x80)
    }

    // @ Description
    // Collision subroutine for USPGround.
    scope ground_collision_: {
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
    // Subroutine which handles the transition from USPGround to USPAir.
    scope ground_to_air_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        jal     0x800DEEC8                  // set aerial state
        lw      a0, 0x0084(a0)              // a0 = player struct

        lw      a0, 0x0020(sp)              // a0 = player object
        lw      v0, 0x0084(a0)              // ~
        li      t6, 0x801605FC              // ~
        sw      t6, 0x0A0C(v0)              // run this falcon function to avoid random bs

        lli     a1, DragonKing.Action.USPAir // a1 = Action.USPAir
        lw      a2, 0x0078(a0)              // a2(starting frame) = current animation frame
        lli     t6, 0x0003                  // ~
        sw      t6, 0x0010(sp)              // argument 4 = 0x0003
        jal     0x800E6F24                  // change action
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        lw      a0, 0x0020(sp)              // a0 = player object
        li      a1, air_pull_initial_       // a1 = air_pull_initial_
        jal     0x8015E310                  // command grab setup (yoshi)
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      ra, 0x001C(sp)              // load ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Collision wubroutine for USPAirPull
    scope air_pull_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, landing_throw_initial_  // a1(transition subroutine) = landing_throw_initial_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Makes the % display during dragon king up special friendlier towards photosensitivity
    scope drain_flash_fix_: {
        OS.patch_start(0x8A1E4, 0x8010E9E4)
        j       drain_flash_fix_
        nop
        _return:
        OS.patch_end()

        lw      s0, 0x0078(a1)              // s0 = player object, if any
        beqz    s0, _original               // skip if no player object
        nop
        lw      s0, 0x0084(s0)              // s0 = player struct, if any
        beqz    s0, _original               // skip if no player struct
        nop
        lw      s0, 0x0844(s0)              // t6 = capturing player object, if any
        beqz    s0, _original               // skip if no capturing player object
        nop

        lw      s0, 0x0084(s0)              // s0 = capturing player struct
        lw      t6, 0x0008(s0)              // a2 = capturing character ID
        lli     at, Character.id.DRAGONKING // at = id.DRAGONKING
        bne     t6, at, _original           // skip if capturing character != DRAGONKING
        lw      t6, 0x0024(s0)              // t6 = capturing character Action ID
        lli     at, DragonKing.Action.USPAirPull // USPAirPull
        beq     t6, at, _override           // override if action = USPAirPull
        lli     at, DragonKing.Action.USPGroundThrow // USPGroundThrow
        bne     t6, at, _original           // skip if action != USPGroundThrow
        nop

        _override:
        lw      t6, 0x017C(s0)              // t6 = temp variable 1
        bnez    t6, _j_0x8010E9F4           // if we're here and temp variable 1 is set, skip branch and prevent % colour from turning white
        nop

        _original:
        beqz    t3, _j_0x8010E9F4           // original branch logic
        nop

        _end:
        j       _return
        addiu   s0, sp, 0x003C

        _j_0x8010E9F4:
        j       0x8010E9F4                  // original branch location
        addiu   s0, sp, 0x003C

    }
}


scope DragonKingNSP {

    constant OFFSET_X(0x437A)               // float 250
    constant OFFSET_Y(0xC1F0)               // float -30
    constant KIRBY_OFFSET_X(0x439B)         // float 310
    constant KIRBY_OFFSET_Y(0x42C8)          // float 100

    // @ Description
    // Initial Routine for Grounded Dragon Ball attack.
    scope ground_initial_: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)
        sw      r0, 0x0010(sp)
        addiu   a1, r0, DragonKing.Action.DragonBall
        addiu   a2, r0, 0x0000
        jal     0x800E6F24
        lui     a3, 0x3F80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x8015FB40
        lw      a0, 0x0020(sp)
        lw      a0, 0x0020(sp)
        lw      a0, 0x0084(a0)
        sw      r0, 0x0B20(a0)              // reset referenced gfx object
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x28
        jr      ra
        nop
    }

    // @ Description
    // Initial Routine for Aerial Dragon Ball attack.
    scope air_initial_: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)
        sw      r0, 0x0010(sp)
        addiu   a1, r0, DragonKing.Action.DragonBallAir
        addiu   a2, r0, 0x0000
        jal     0x800E6F24
        lui     a3, 0x3F80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x8015FB40
        lw      a0, 0x0020(sp)
        lw      a0, 0x0020(sp)
        lw      a0, 0x0084(a0)
        sw      r0, 0x0B20(a0)              // reset referenced gfx object
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x28
        jr      ra
        nop
    }

    // @ Description
    // Initial Routine for Kirby's Grounded Dragon Ball attack.
    scope kirby_ground_begin_initial_: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)
        sw      r0, 0x0010(sp)
        addiu   a1, r0, Action.KIRBY.DragonKingNSPGround
        addiu   a2, r0, 0x0000
        jal     0x800E6F24
        lui     a3, 0x3F80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x80160B14
        lw      a0, 0x0020(sp)
        lw      a0, 0x0020(sp)
        lw      a0, 0x0084(a0)
        sw      r0, 0x0B20(a0)              // reset referenced gfx object
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x28
        jr      ra
        nop
    }

    // @ Description
    // Initial Routine for Kirby's Aerial Dragon Ball attack.
    scope kirby_air_begin_initial_: {
        addiu   sp, sp, -0x28
        sw      ra, 0x001C(sp)
        sw      a0, 0x0020(sp)
        sw      r0, 0x0010(sp)
        addiu   a1, r0, Action.KIRBY.DragonKingNSPAir
        addiu   a2, r0, 0x0000
        jal     0x800E6F24
        lui     a3, 0x3F80
        jal     0x800E0830
        lw      a0, 0x0020(sp)
        jal     0x80160B14
        lw      a0, 0x0020(sp)
        lw      a0, 0x0020(sp)
        lw      a0, 0x0084(a0)
        sw      r0, 0x0B20(a0)              // reset referenced gfx object
        lw      ra, 0x001C(sp)
        addiu   sp, sp, 0x28
        jr      ra
        nop
    }

    // @ Description
    // Subroutine which runs when Dragon King main routine. This routine spawns the effect and transitions to idle.
    scope main_: {
        addiu   sp, sp, -0x18
        sw      ra, 0x0014(sp)
        sw      a0, 0x0004(sp)
        jal     dragon_ball_
        sw      a0, 0x0018(sp)

        lw      a0, 0x0004(sp)
        lw      t1, 0x0084(a0)      // load player struct
        lw      t1, 0x014C(t1)      // load kinetic state
        lui     a1, 0x8014
        beqzl   t1, _action_routine
        addiu   a1, a1, 0xE1C8
        addiu   a1, a1, 0xF9E0

        _action_routine:
        jal     0x800D9480
        nop

        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x18
        jr      ra
        nop
    }

    // @ Description
    // This subroutine spawns the effect of the lightning ball.
    scope dragon_ball_: {
        addiu   sp, sp, -0x20
        sw      ra, 0x0014(sp)
        lw      v1, 0x0084(a0)
        lw      t9, 0x017C(v1)              // load moveset variable
        addiu   at, r0, 0x0001

        bne     t9, at, _end                // branch if not set to 0x1
        nop

        sw      v1, 0x001C(sp)              // save player struct to stack

        addiu   sp, sp, -0x40
        sw      v1, 0x0034(sp)              // save player struct to stack
        sw      a0, 0x0018 (sp)
        lui     a0, 0x8013                  // load GFX Struct
        sw      a1, 0x001C(sp)
        jal     0x800FDAFC
        addiu   a0, a0, 0xE1D4              // load GFX Struct
        bnez    v0, _branch
        or      v1, v0, r0
        b       _end_gfx
        or      v0, r0, r0

        _branch:

        lw      a0, 0x0084(v1)              // load special struct
        addiu   t6, r0, 0x001D              // set animations timer to 0x1D
        or      v0, v1, r0                  // place object struct into v0
        sw      t6, 0x0018(a0)              // save timer to location
        lw      t7, 0x0018(sp)
        lw      a1, 0x0074(v1)              // load gfx object's part 0 (location) struct
        sw      a1, 0x002C(sp)              // save gfx part 0 struct
        lw      t0, 0x0010(a1)              // t0 = next joint

        lw      at, 0x0034(sp)              // load player struct
        lw      t8, 0x0008(at)              // t8 = current character ID
        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t8, t1, _kirby              // if Kirby, load alternate parameters
        lui     t1, 0x3F00                  // t1 = scale
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t8, t1, _kirby              // if J Kirby, load alternate parameters
        lui     t1, 0x3F00                  // t1 = scale

        lui     t2, OFFSET_Y                // ~
        or      t3, r0, r0                  // ~
        lui     t4, OFFSET_X                // load x/y/z offset
        b       _continue                   // continue
        lui     t1, 0x3F40                  // t1 = scale

        _kirby:
        lui     t2, KIRBY_OFFSET_X          // ~
        or      t3, r0, r0                  // ~
        lui     t4, KIRBY_OFFSET_Y          // load x/y/z offset

        _continue:
        li      t8, Size.multiplier_table
        lbu     at, 0x000D(at)              // at = port
        sll     at, at, 0x0002              // at = port * 4 = offset to multiplier
        addu    t8, t8, at                  // t8 = size multiplier address
        lwc1    f6, 0x0000(t8)              // f6 = size multiplier
        mtc1    t1, f8                      // f8 = scale
        mul.s   f6, f6, f8                  // f6 = new scale

        sw      t2, 0x0020(sp)              // ~
        sw      t3, 0x0024(sp)              // ~
        sw      t4, 0x0028(sp)              // set x/y/z offset
        lw      t8, 0x0084(t7)              // load player struct
        sw      t8, 0x0004(a0)              // save reference to player struct in ball gfx's special struct
        swc1    f6, 0x0040(t0)              // update x scale
        swc1    f6, 0x0044(t0)              // update y scale
        swc1    f6, 0x0048(t0)              // update z scale
        sw      v0, 0x0B20(t8)              // save reference to ball object in player struct
        li      at, destroy_ball_on_hit_    // ~
        sw      at, 0x09EC(t8)              // store on hit routine in player struct
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        lw      a0, 0x0928(t8)              // a0 = part 0xC (right hand) struct

        lw      a1, 0x002C(sp)              // a1 = gfx part 0 struct
        lwc1    f0, 0x0020(sp)              // ~
        swc1    f0, 0x001C(a1)              // set x position of gfx
        lwc1    f0, 0x0024(sp)              // ~
        swc1    f0, 0x0020(a1)              // set y position of struct
        lwc1    f0, 0x0028(sp)              // ~
        swc1    f0, 0x0024(a1)              // set z position of struct

        _end_gfx:
        addiu          sp, sp, 0x40

        lw      v1, 0x001C(sp)

        lbu     t1, 0x018F(v1)
        sw      r0, 0x017C(v1)      // clear moveset variable 1

        _end:
        lw      ra, 0x0014(sp)
        addiu   sp, sp, 0x20
        jr      ra
        nop
    }
    // 8012E1D4 GFX STRUCT

    // @ Description
    // Prevents ball from animating during hitlag, attaches ball to Dragon King's hand
    scope augment_ball_update_routine_: {
        OS.patch_start(0x7CFF0, 0x801017F0)
        jal     augment_ball_update_routine_
        lw      a1, 0x0084(a0)              // original line 1
        OS.patch_end()

        lw      t0, 0x0004(a1)              // t0 = player struct
        lw      t1, 0x0040(t0)              // t1 = hit lag frames remaining
        bnez    t1, _hitlag                 // if in hit lag, return after animation update routine
        sw      a0, 0x0020(sp)              // original line 2


        // if we're not in hitlag, update the ball's location to match DKing's hand
        addiu   sp, sp, -0x0040             // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // 0x0018(sp) = gfx object

        lw      t8, 0x0008(t0)              // t8 = current character ID
        lli     t1, Character.id.KIRBY      // t1 = id.KIRBY
        beql    t8, t1, _kirby              // if Kirby, load alternate parameters
        lui     t1, 0x3F00                  // t1 = scale
        lli     t1, Character.id.JKIRBY     // t1 = id.JKIRBY
        beql    t8, t1, _kirby              // if J Kirby, load alternate parameters
        lui     t1, 0x3F00                  // t1 = scale

        lui     t2, OFFSET_Y                // ~
        or      t3, r0, r0                  // ~
        lui     t4, OFFSET_X                // load x/y/z offset
        b       _continue                   // continue
        lui     t1, 0x3F40                  // t1 = scale

        _kirby:
        lui     t2, KIRBY_OFFSET_X          // ~
        or      t3, r0, r0                  // ~
        lui     t4, KIRBY_OFFSET_Y          // load x/y/z offset

        _continue:
        sw      t2, 0x0020(sp)              // ~
        sw      t3, 0x0024(sp)              // ~
        sw      t4, 0x0028(sp)              // set x/y/z offset
        addiu   a1, sp, 0x0020              // a1 = address to return x/y/z coordinates to
        jal     0x800EDF24                  // returns x/y/z coordinates of the part in a0 to a1
        lw      a0, 0x0928(t0)              // a0 = part 0xC (right hand) struct

        lw      a0, 0x0018(sp)              // a0 = gfx object
        lw      a1, 0x0074(a0)              // a1 = gfx part 0 struct
        lwc1    f0, 0x0020(sp)              // ~
        swc1    f0, 0x001C(a1)              // set x position of gfx
        lwc1    f0, 0x0024(sp)              // ~
        swc1    f0, 0x0020(a1)              // set y position of struct
        lwc1    f0, 0x0028(sp)              // ~
        swc1    f0, 0x0024(a1)              // set z position of struct
        lw      ra, 0x0014(sp)              // load ra
        lw      a0, 0x0018(sp)              // load a0
        addiu   sp, sp, 0x00040             // deallocate stack space
        jr      ra                          // return
        lw      a1, 0x0084(a0)              // original line 1 again

        _hitlag:
        j       0x80101830                  // skip animation update and timer decrement
        lw      ra, 0x0014(sp)              // restore ra
    }

    // @ Description
    // Function which destroys the ball object
    // @ Arguments
    // a0 - ball object
    scope destroy_ball_object_: {
        OS.patch_start(0x7D010, 0x80101810)
        jal     destroy_ball_object_
        lw      a0, 0x0020(sp)              // a0 = gfx object
        nop
        nop
        OS.patch_end()

        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        lw      a1, 0x0084(a0)              // a1 = gfx special struct
        lw      t0, 0x0004(a1)              // t0 = referenced player struct
        sw      r0, 0x0B20(t0)              // reset referenced gfx object in player struct
        sw      r0, 0x09EC(t0)              // reset on-hit routine in player struct
        sw      a0, 0x0018(sp)              // store a0
        jal     0x800FD4F8                  // original line
        or      a0, a1, r0                  // a0 = gfx special struct
        jal     0x80009A84                  // original line 2
        lw      a0, 0x0018(sp)              // load a0
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Function which destroys the ball object when Dragon King gets hit
    scope destroy_ball_on_hit_: {
        addiu   sp, sp, -0x0020             // allocate stack space
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a0, 0x0B20(a0)              // a0 = referenced gfx object
        beqz    a0, _end                    // skip if no referenced gfx object
        sw      ra, 0x0014(sp)              // store ra

        jal     destroy_ball_object_        // destroy ball object
        nop

        _end:
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0020              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles physics for the aerial version of Dragon Ball.
    // Prevents player control when temp variable 2 = 0
    scope physics_aerial_: {
        // 0x180 in player struct = temp variable 2
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw    	ra, 0x000C(sp)              // store t0, t1, ra
        sw      a0, 0x0010(sp)              // player object saved
        lw      t0, 0x0084(a0)              // t0 = player struct
        lw      t1, 0x0180(t0)              // t1 = temp variable 2

        beqz    t1, _control                // skip if t1 != 0
        nop

        jal     0x800D91EC                  // t8 = physics subroutine which prevents player control
        nop

        lw      a0, 0x0010(sp)              // player object loaded
        lw      t2, 0x0084(a0)              // load player struct
        sw      r0, 0x0048(t2)              // prevent x movement
        beq     r0, r0, _end                // branch to end
        sw      r0, 0x004C(t2)              // prevent y movement

        _control:
        jal     0x800D90E0                  // t8 = physics subroutine which allows player control
        nop

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load t0, t1, ra
        addiu 	sp, sp, 0x0018				// deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground collision for neutral special actions
    scope kirby_ground_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, kirby_ground_to_air_          // a1(transition subroutine) = ground_to_air_
        jal     0x800DDDDC                  // common ground collision subroutine (transition on no floor, slide-off)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
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
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles air collision for neutral special begin and wait
    scope kirby_air_collision_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        li      a1, kirby_air_to_ground_    // a1(transition subroutine) = air_to_ground_
        jal     0x800DE6E4                  // common air collision subroutine (transition on landing, no ledge grab)
        nop
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground to air transition
    scope ground_to_air_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // store a0
        jal     0x8015FA8C                  // original falcon subroutine
        sw      a0, 0x0018(sp)              // store a0
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        li      at, destroy_ball_on_hit_    // ~
        sw      at, 0x09EC(a0)              // store on hit routine in player struct
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles ground to air transition
    scope kirby_ground_to_air_: {
    addiu           sp, sp,-0x0028              // allocate stack space
    sw              ra, 0x0014(sp)              // store ra
    sw              a0, 0x0018(sp)              // store a0
    addiu           sp, sp, -0x28
    sw              ra, 0x0024 (sp)
    sw              s0, 0x0020 (sp)
    sw              a0, 0x0028 (sp)
    lw              s0, 0x0084 (a0)
    jal             0x800deec8
    or              a0, s0, r0
    lw              a0, 0x0028 (sp)
    addiu           t7, r0, 0x4006
    addiu           a1, r0, Action.KIRBY.DragonKingNSPAir
    lw              a2, 0x0078 (a0)
    sw              t7, 0x0010 (sp)
    jal             0x800e6f24
    lui             a3, 0x3f80
    jal             0x800d8eb8
    or              a0, s0, r0
    lui             t8, 0x800f
    lui             t9, 0x800f
    addiu           t8, t8, 0x9c8c
    addiu           t9, t9, 0x9cc4
    sw              t8, 0x0a04 (s0)
    sw              t9, 0x0a08 (s0)
    lw              s0, 0x0020 (sp)
    addiu           sp, sp, 0x28
    lw              a0, 0x0018(sp)              // ~
    lw              a0, 0x0084(a0)              // a0 = player struct
    li              at, destroy_ball_on_hit_    // ~
    sw              at, 0x09EC(a0)              // store on hit routine in player struct
    lw              ra, 0x0014(sp)              // load ra
    addiu           sp, sp, 0x0028              // deallocate stack space
    jr              ra
    nop
    }

    // @ Description
    // Subroutine which handles air to ground transition
    scope air_to_ground_: {
        addiu   sp, sp,-0x0028              // allocate stack space
        sw      ra, 0x0014(sp)              // store ra
        sw      a0, 0x0018(sp)              // store a0
        jal     0x8015FA2C                  // original falcon subroutine
        sw      a0, 0x0018(sp)              // store a0
        lw      a0, 0x0018(sp)              // ~
        lw      a0, 0x0084(a0)              // a0 = player struct
        li      at, destroy_ball_on_hit_    // ~
        sw      at, 0x09EC(a0)              // store on hit routine in player struct
        lw      ra, 0x0014(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0028              // deallocate stack space
    }

    // @ Description
    // Subroutine which handles air to ground transition
    scope kirby_air_to_ground_: {
    addiu           sp, sp,-0x0028              // allocate stack space
    sw              ra, 0x0014(sp)              // store ra
    sw              a0, 0x0018(sp)              // store a0
    addiu           sp, sp, -0x28
    sw              ra, 0x001c (sp)
    sw              a0, 0x0028 (sp)
    lw              a0, 0x0084 (a0)

    jal             0x800dee98
    sw              a0, 0x0024 (sp)

    lw              a0, 0x0028 (sp)
    addiu           t7, r0, 0x4006
    addiu           a1, r0, Action.KIRBY.DragonKingNSPGround
    lw              a2, 0x0078 (a0)
    sw              t7, 0x0010 (sp)

    jal             0x800e6f24
    lui             a3, 0x3f80

    lw              v0, 0x0024 (sp)
    lui             t8, 0x800f
    lui             t9, 0x800f
    addiu           t8, t8, 0x9c8c
    addiu           t9, t9, 0x9cc4
    sw              t8, 0x0a04 (v0)
    sw              t9, 0x0a08 (v0)
    lw              ra, 0x001c (sp)
    addiu           sp, sp, 0x28
    lw              a0, 0x0018(sp)              // ~
    lw              a0, 0x0084(a0)              // a0 = player struct
    li              at, destroy_ball_on_hit_    // ~
    sw              at, 0x09EC(a0)              // store on hit routine in player struct
    lw              ra, 0x0014(sp)              // load ra
    jr              ra                          // return
    addiu           sp, sp, 0x0028              // deallocate stack space
    }
}

scope DragonKingDSP {
    constant AERIAL_INITIAL_Y_SPEED(0x4100) // DSP rise
    constant X_SPEED(0x4270)                // current setting - float:60
    constant Y_SPEED(0xC30C)                // current setting - float:-140.0
    constant INITIAL_Y_SPEED(0x4334)        // current setting - float:180.0
    constant BEGIN(0x1)
    constant MOVE(0x2)

    // @ Description
    // Subroutine which runs when Dragon King initiates a grounded down special.
    scope ground_initial_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x001C(sp)              // ~
        sw      a0, 0x0020(sp)              // store a0, ra
        lli     a1, 0x00E6                  // a1(action id) = 0x00E6(grounded down special)
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
    // Subroutine which runs when Dragon King initiates an aerial down special.
    // Changes action, and sets up initial variable values.
    scope air_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0008              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x0E9               // a1 = action id: DSP Begin
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
    // Subroutine which sets up the movement for the aerial version of Dragon King's down special.
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
    // Subroutine which handles physics for Dragon King's down special.
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
        addiu   at, r0, 0x0E7               // action = DSPA Loop
        beq     at, t0, _moving_down        // branch if in DSPALoop
        lw      t0, 0x0184(a0)              // t0 = temp variable 3
        ori     t1, r0, MOVE                // t1 = MOVE
        bne     t0, t1, _apply_y_speed      // skip if t0 != MOVE
        lui     t1, AERIAL_INITIAL_Y_SPEED  // moving up y speed
        _moving_down:
        lui     t0, X_SPEED                 // ~
        mtc1    t0, f2                      // f2 = X_SPEED
        lwc1    f0, 0x0044(a0)              // ~
        cvt.s.w f0, f0                      // f0 = direction
        mul.s   f2, f0, f2                  // f2 = x velocity * direction
        lui     t1, Y_SPEED                 // moving down y speed
        _apply_y_speed:
        swc1    f2, 0x0048(a0)              // x velocity = X_SPEED
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
    // Subroutine which handles collision for Dragon King's down special.
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
        addiu   at, r0, 0x0E7               // DSP loop action
        lw      v1, 0x0024(a1)              // current action
        beq     at, v1, _main_collision     // branch if doing aerial loop action
        nop

        // If Dragon King is not in the ground pound motion, run a normal aerial collision subroutine
        // instead.
        jal     0x800DE99C                  // aerial collision subroutine
        nop
        b       _end                        // branch to end
        nop

        _main_collision:
        li      a1, 0x801600EC          // a1 = begin_landing_
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
    // Initial for Dragon King's DSP loop
    // Changes action, and sets up initial variable values.
    scope loop_initial_: {
        addiu   sp, sp,-0x0020              // ~
        sw      ra, 0x001C(sp)              // ~
        addiu   t6, r0, 0x0001              // ~
        sw      a0, 0x0020(sp)              // ~
        sw      t6, 0x0010(sp)              // original begin logic
        ori     a1, r0, 0x0E7               // a1 = action id: DragonKing DSPA Loop
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
}