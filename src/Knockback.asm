// Knockback.asm

// @ Description
// This file contains a randomizer for knockback angles.

scope Knockback {

    // @ Description
    // Subroutine which randomizes knockback angles for each action when the character is initialized.
    scope randomize_angles_: {
        constant CHANCE_GOOD(60)
        constant CHANCE_F_YOU(15)
        constant CHANCE_RANDOM(15)

        OS.patch_start(0x53808, 0x800D8008)
        jal     randomize_angles_
        nop
        _return:
        OS.patch_end()

        lbu     t9, 0x0015(s6)              // t9 = player port (original line 1)
        sb      t9, 0x000D(v0)              // initialize player port in player struct (original line 2)

        OS.save_registers()

        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = current_screen
        li      t1, screen_table            // ~
        addu    t1, t1, t9                  // t1 = screen_table_px
        lbu     t2, 0x0000(t1)              // t2 = previous_screen_px
        sb      t0, 0x0000(t1)              // store current screen in screen_table
        // if current screen and previous screen match, don't randomize angles
        // this should prevent characters from being randomized when you reset training mode or do salty runback
        beq     t0, t2, _end                // branch if current_screen = previous_screen
        nop

        li      t0, random_table            // t0 = random_table
        sll     t1, t9, 0x0002              // ~
        addu    t0, t0, t1                  // t0 = random_table + (port * 4)
        lw      s2, 0x0000(t0)              // s2 = table_px
        or      s0, r0, r0                  // s0 = current action id (0)
        lli     s1, 0x200                   // s1 = end action id

        _loop:
        beq     s0, s1, _end                // exit loop if current action = end action id
        nop

        // get table position
        sll     at, s0, 0x1                 // at(offset) = current action * 0x2
        addu    s3, s2, at                  // s3 = table_px + offset

        // determine random angle type
        jal     Global.get_random_int_      // v0 = (0-99)
        lli     a0, 000100                  // ~
        or      s4, v0, r0                  // s4 = (0-99)

        // check for "GOOD" angle, likely favourable for doing combos, value between 45-135, 55% chance
        _good_angle:
        sltiu   t1, s4, CHANCE_GOOD
        beqz    t1, _f_you_angle            // if out of range, skip
        nop                                 // else, continue
        jal     Global.get_random_int_      // v0 = (0-90)
        lli     a0, 000091                  // ~
        addiu   t1, v0, 000045              // t1 = 45 + (0-90), or (45-135)
        sh      t1, 0x0000(s3)              // store knockback angle for current action
        b       _loop                       // loop
        addiu   s0, s0, 0x0001              // increment action id by 1

        // check for "F%#@ YOU" angle, semi spike or spike angle, value between 180 - 360, 15% chance
        _f_you_angle:
        sltiu   t1, s4, (CHANCE_GOOD + CHANCE_F_YOU)
        beqz    t1, _random_angle           // if out of range, skip
        nop                                 // else, continue
        jal     Global.get_random_int_      // v0 = (0-180)
        lli     a0, 000181                  // ~
        addiu   t1, v0, 000180              // t1 = 180 + (0-180), or (180-360)
        sh      t1, 0x0000(s3)              // store knockback angle for current action
        b       _loop                       // loop
        addiu   s0, s0, 0x0001              // increment action id by 1

        // check for "RANDOM" angle, completely random angle, value between 0 - 360, 15% chance
        _random_angle:
        sltiu   t1, s4, (CHANCE_GOOD + CHANCE_F_YOU + CHANCE_RANDOM)
        beqz    t1, _sakurai_angle          // if out of range, skip
        nop                                 // else, continue
        jal     Global.get_random_int_      // v0 = (0-360)
        lli     a0, 000361                  // ~
        sh      v0, 0x0000(s3)              // store knockback angle for current action
        b       _loop                       // loop
        addiu   s0, s0, 0x0001              // increment action id by 1

        // if no other angle type is used, use a "SAKURAI" angle (361)
        _sakurai_angle:
        lli     t0, 000361                  // ~
        sh      t0, 0x0000(s3)              // store sakurai angle for current action
        b       _loop                       // loop
        addiu   s0, s0, 0x0001              // increment action id by 1

        _end:
        OS.restore_registers()
        jr      ra                          // return
        nop
    }

    OS.align(16)
    random_table:
    dw  table_p1
    dw  table_p2
    dw  table_p3
    dw  table_p4

    state_table:
    dw  0   // P1
    dw  0   // P2
    dw  0   // P3
    dw  0   // P4

    OS.align(16)
    screen_table:
    db  0   // P1
    db  0   // P2
    db  0   // P3
    db  0   // P4

    // tables of halfwords containing knockback angles for each action
    OS.align(16)
    table_p1:
    fill 0x200 * 0x2
    OS.align(16)
    table_p2:
    fill 0x200 * 0x2
    OS.align(16)
    table_p3:
    fill 0x200 * 0x2
    OS.align(16)
    table_p4:
    fill 0x200 * 0x2

    // @ Description
    // Gets the new randomized angle for the current action when a hitbox is created.
    scope get_angle_hitbox_: {
        OS.patch_start(0x5AC24, 0x800DF424)
        j       get_angle_hitbox_
        nop
        _return:
        OS.patch_end()

        // a0 = player struct
        // t0 = hitbox struct

        li      t6, state_table
        lbu     t7, 0x000D(a0)              // t7 = player port
        sll     t7, t7, 0x0002              // t7 = port * 4
        addu    t6, t6, t7                  // t6 = state_table + (port * 4)
        lw      t6, 0x0000(t6)              // t6 = random knockback state
        bnez    t6, _random                 // TODO: if more knockback states are added, check specifically for state 0x1...
        nop                                 // ... but for now just branch if state != 0

        _original:
        sra     t6, t5, 0x16                // original line 1
        b       _end                        // branch to end
        sw      t6, 0x0028(t0)              // original line 2


        _random:
        li      t6, random_table            // t6 = random_table
        addu    t6, t6, t7                  // t6 = random_table + (port * 4)
        lw      t6, 0x0000(t6)              // t6 = table_px
        lw      t7, 0x0024(a0)              // t7 = current action id
        sll     t7, t7, 0x0001              // ~
        addu    t7, t6, t7                  // t7 = table_px + action id * 2
        lhu     t6, 0x0000(t7)              // t6 = new knockback angle for action
        sw      t6, 0x0028(t0)              // store konckback angle in hitbox struct

        _end:
        j       _return                     // return
        nop
    }

    // @ Description
    // Gets the new randomized angle for the current action when a throw is performed.
     scope get_angle_throw_: {
        OS.patch_start(0xC5BAC, 0x8014B16C)
        j       get_angle_throw_
        nop
        _return:
        OS.patch_end()

        // s0 = player struct

        li      t2, state_table
        lbu     t3, 0x000D(s0)              // t3 = player port
        sll     t3, t3, 0x0002              // t3 = port * 4
        addu    t2, t2, t3                  // t2 = state_table + (port * 4)
        lw      t2, 0x0000(t2)              // t2 = random knockback state
        bnez    t2, _random                 // TODO: if more knockback states are added, check specifically for state 0x1...
        nop                                 // ... but for now just branch if state != 0

        _original:
        b       _end                        // branch to end
        lw      t2, 0x0008(v1)              // t2 = throw knockback angle

        _random:
        li      t2, random_table            // t2 = random_table
        addu    t2, t2, t3                  // t2 = random_table + (port * 4)
        lw      t2, 0x0000(t2)              // t2 = table_px
        lw      t3, 0x0024(s0)              // t3 = current action id
        sll     t3, t3, 0x0001              // ~
        addu    t3, t2, t3                  // t3 = table_px + action id * 2
        lhu     t2, 0x0000(t3)              // t2 = new knockback angle for throw

        _end:
        j       _return                     // return
        lw      t3, 0x006C(sp)              // original line 2
    }

    //// @ Description
    //// Completely randomizes knockback angles. Scrapped but left in here for documentation/fun.
    //scope randomize_angle_: {
    //    OS.patch_start(0xBB3FC, 0x801409BC)
    //    j       randomize_angle_
    //    mtc1    a2, f12                     // original line 1
    //    _return:
    //    OS.patch_end()
    //
    //    // a0 = knockback angle (int)
    //    addiu   sp, sp,-0x0040          // allocate stack space
    //    sw      ra, 0x0020(sp)          // store ra
    //    sw      a0, 0x0024(sp)          // store original angle
    //
    //    // get a random value between 0 and 400
    //    jal     Global.get_random_int_  // v0 = (0, 400)
    //    lli     a0, 400                 // ~
    //    slti    a0, v0, 361             // a0 = 1 if v0 > 361
    //    bnez    a0, _end                // branch and use v0 as new angle if value is between 0 and 360
    //    or      a0, v0, r0              // a0 = random angle
    //
    //    // if the random value returned between 361 and 400, use sakurai angle
    //    lli     a0, 361                 // a0 = sakurai angle
    //
    //    _end:
    //    lli     at, 361                 // at = 361 (original line 2)
    //    lw      ra, 0x0020(sp)          // load ra
    //    j       _return                 // return
    //    addiu   sp, sp, 0x0040          // deallocate stack space
    //}
}