// Tripping.asm (code by goom)
if !{defined __TRIPPING__} {
define __TRIPPING__()
print "included Tripping.asm\n"

// @ Description
// Tripping stuff
scope Tripping {

    // @ Description
    // Roll to see if we trip
    scope tripping: {
        // runs when we turn
        OS.patch_start(0xB9358, 0x8013E918)
        jal     tripping
        addiu   a1, r0, 0x0012       // original line 1
        OS.patch_end()
        // runs when we dash
        OS.patch_start(0xB9758, 0x8013ED18)
        jal     tripping
        addiu   a1, r0, 0x000F       // original line 1
        OS.patch_end()
        // runs when we turnrun
        OS.patch_start(0xB9C58, 0x8013F218)
        jal     tripping
        addiu   a1, r0, 0x0013       // original line 1
        OS.patch_end()

        li      a3, Toggles.entry_tripping
        lw      a3, 0x0004(a3)              // a3 = entry_tripping (0 if OFF, 1 if LOW, 2 if HIGH, 3 if "BRAWL")
        beqz    a3, _return                 // if tripping disabled, return normally
        nop

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      v0, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // save registers

        lbu     a2, 0x000D(v0)              // a2 = player index (0 - 3)
        li      a0, player_trip_flag
        addu    a0, a0, a2                  // a0 = address of trip flag for this player
        sb      r0, 0x0000(a0)              // clear trip flag (just in case)

        // Check which action we are attempting and set probability accordingly
        // Note: tripping is more likely for dash dance, since it is 2 separate rolls (turn + dash)
        addiu   a0, r0, Action.TurnRun       // a0 = Action.TurnRun
        beql    a0, a1, trip_roll            // ~
        addiu   a0, r0, 80                   // a0 - range (0, N-1)
        addiu   a0, r0, Action.Dash          // a0 = Action.Dash
        beql    a0, a1, trip_roll            // ~
        addiu   a0, r0, 96                   // a0 - range (0, N-1)
        // if we reached this point, we're turning; check if it's from a dash (v0 is player struct)
        lw      a2, 0x0024(v0)               // a2 = current action id
        bne     a0, a2, _end                 // if a2 != Action.Dash, abort (no trip from idle turn)
        nop
        addiu   a0, r0, 64                   // a0 - range (0, N-1)

        //             Low     High    Brawl
        // Turnrun     1.2%    5%      20%
        // Dash        1.0%    4%      16%
        // Dash dance  1.5%    6%      25%
        trip_roll:
        li      a3, Toggles.entry_tripping
        lw      a3, 0x0004(a3)              // a3 = entry_tripping (0 if OFF, 1 if LOW, 2 if HIGH, 3 if "BRAWL")
        addiu   a2, r0, 0x0003
        beql    a3, a2, pc() + 8            // if tripping brawl, divide range by 16
        srl     a0, a0, 4
        addiu   a2, r0, 0x0002
        beql    a3, a2, pc() + 8            // if tripping high, divide range by 4
        srl     a0, a0, 2
        jal     Global.get_random_int_      // v0 = (0, N-1)
        nop
        addiu   a0, r0, 0x0002              // place 2 as the random number to trip
        bne     a0, v0, _end                // if not 2, don't trip
        nop

        trip:
        lw      v0, 0x0008(sp)              // v0 = player struct
        addiu   a1, r0, 0x0008              // a1 = 8 frames (note: hitstun needs to be higher value than 'action frame' count)
        sh      a1, 0x0B1A(v0)              // a1 = put player in hitstun

        addiu   a1, r0, Action.DamageLow3   // a1 = DamageLow3 action (0x02D)

        // play sound effect
        // lli     a0, 0x011F                  // thunk
        lli     a0, 0x0456                  // tripstart
        jal     FGM.play_                   // play sfx
        nop

        lbu     v0, 0x000D(v0)              // v0 = player index (0 - 3)
        li      a0, player_trip_flag
        addu    a0, a0, v0                  // a0 = address of trip flag for this player
        addiu   v0, r0, 0x0001
        sb      v0, 0x0000(a0)              // v0 = update trip flag (true)

        _end:
        lw      a0, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              //
        lw      ra, 0x000C(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _return:
        jr      ra                          // return
        addiu   a2, r0, 0x0000              // original line 2

        player_trip_flag:
        db      0, 0, 0, 0
    }

    // lines 8013E8F0 and 8013E94C remove hitstun when turning, need to override if we are currently tripping
    scope trip_turn_hitstun_retention_1: {
        OS.patch_start(0xB9330, 0x8013E8F0)
        jal     trip_turn_hitstun_retention_1
        nop
        OS.patch_end()

        // a2, t1 are safe to edit
        li      a2, Toggles.entry_tripping
        lw      a2, 0x0004(a2)              // a2 = entry_tripping (0 if OFF, 1 if LOW, 2 if HIGH, 3 if "BRAWL")
        beqzl   a2, _return                 // if tripping disabled, return normally
        sw      r0, 0x0B18(s0)              // original line 1

        lbu     a2, 0x000D(s0)              // a2 = player index (0 - 3)
        li      t1, tripping.player_trip_flag
        addu    t1, t1, a2                  // t1 = address of trip flag for this player

        lbu     a2, 0x0000(t1)              // a2 = trip flag
        beqzl   a2, _return                 // clear hitstun only if not currently tripping on the ground
        sw      r0, 0x0B18(s0)              // original line 1

        _return:
        jr      ra
        lw      ra, 0x001C(sp)              // original line 2
        nop
    }

    scope trip_turn_hitstun_retention_2: {
        OS.patch_start(0xB9388, 0x8013E948)
        jal     trip_turn_hitstun_retention_2
        nop
        OS.patch_end()

        // t6, t8 are safe to edit
        li      t6, Toggles.entry_tripping
        lw      t6, 0x0004(t6)              // t6 = entry_tripping (0 if OFF, 1 if LOW, 2 if HIGH, 3 if "BRAWL")
        beqzl   t6, _return                 // if tripping disabled, return normally
        sw      r0, 0x0B18(v0)              // original line 1

        lbu     t6, 0x000D(v0)              // t6 = player index (0 - 3)
        li      t8, tripping.player_trip_flag
        addu    t8, t8, t6                  // t8 = address of trip flag for this player
        lbu     t6, 0x0000(t8)              // t6 = trip flag
        beqzl   t6, _return                 // clear hitstun only if not currently tripping on the ground
        sw      r0, 0x0B18(v0)              // original line 2

        _return:
        jr      ra
        addiu   t6, r0, 0x0100              // original line 1
        nop
    }

    // hooking into the function that checks if we should transition back to idle after being damaged on the ground
    scope damaged_check_trip: {
        OS.patch_start(0xBAF28, 0x801404E8)
        jal     damaged_check_trip
        sw      a0, 0x0020(sp)              // original line 2
        OS.patch_end()

        // a2 is player struct
        // t6, v0, v1 are safe to edit
        li      t6, Toggles.entry_tripping
        lw      t6, 0x0004(t6)              // t6 = entry_tripping (0 if OFF, 1 if LOW, 2 if HIGH, 3 if "BRAWL")
        beqz    t6, _return                 // if tripping disabled, return normally
        nop

        lbu     v0, 0x000D(a2)              // v0 = player index (0 - 3)
        li      t6, tripping.player_trip_flag
        addu    t6, t6, v0                  // t6 = address of trip flag for this player
        lbu     v0, 0x0000(t6)              // v0 = trip flag
        beqz    v0, _return                 // return if not tripping
        nop

        lw      v1, 0x0024(a2)              // v1 = current action id
        addiu   v0, r0, Action.DamageLow3   // v0 = DamageLow3
        bnel    v1, v0, _return
        sb      r0, 0x0000(t6)              // clear trip flag
        lw      v0, 0x001C(a2)              // v0 = current frame of current action
        slti    v0, v0, 0x6                 // v0 = 1 if action frame is >= 6 (note: this needs to be LESS than hitstun amount)
        bnez    v0, _return
        nop

        // if we're here, we finished tripping animation and need to change action
        sb      r0, 0x0000(t6)              // clear trip flag

        // player struct (pointer ptr at 0x80130D84)

        addiu   sp, sp, -0x0070             // allocate stack space
        sw      a0, 0x0034(sp)              // player object
        sw      a1, 0x0038(sp)              // ~
        sw      a2, 0x003C(sp)              // player struct
        sw      a3, 0x0044(sp)              // ~
        sw      at, 0x0048(sp)              // ~
        sw      t1, 0x004C(sp)              // ~
        sw      t2, 0x0050(sp)              // ~
        sw      t3, 0x0054(sp)              // ~
        sw      t4, 0x0058(sp)              // ~
        sw      t7, 0x005C(sp)              // ~
        sw      t9, 0x0060(sp)              // ~
        sw      ra, 0x0064(sp)              // save registers

        lw      a1, 0x014C(a2)              // load kinetic state
        beqzl   a1, _change_action          // branch accordingly
        addiu   a1, r0, Action.DownBounceD  // if grounded, set action to DownBounceD
        addiu   a1, r0, Action.Tumble       // if in the air, set to tumble

        _change_action:
        or      a2, r0, r0                  // a2(starting frame) = 0 (doesn't do anything here?)
        lui     a3, 0x3F80                  // a3(frame speed multiplier) = 1.0
        jal     0x800E6F24                  // change action
        sw      r0, 0x0010(sp)              // argument 4 = 0
        jal     0x800E0830                  // unknown common subroutine
        lw      a0, 0x0034(sp)              // a0 = player object

        _end:
        lw      a0, 0x0034(sp)              // restore registers
        lw      a1, 0x0038(sp)              // ~
        lw      a2, 0x003C(sp)              // ~
        lw      a3, 0x0044(sp)              // ~
        lw      at, 0x0048(sp)              // ~
        lw      t1, 0x004C(sp)              // ~
        lw      t2, 0x0050(sp)              // ~
        lw      t3, 0x0054(sp)              // ~
        lw      t4, 0x0058(sp)              // ~
        lw      t7, 0x005C(sp)              // ~
        lw      t9, 0x0060(sp)              // ~
        lw      ra, 0x0064(sp)              // ~
        addiu   sp, sp, 0x0070              // deallocate stack space

        _trip_end:
        j       0x8014052C                  // return (take branch)
        lw      t6, 0x0084(a0)              // original line 1

        _return:
        jr      ra                          // return (don't take branch)
        lw      t6, 0x0084(a0)              // original line 1
    }

}

} // __TRIPPING__
