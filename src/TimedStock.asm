// TimedStock.asm (original by Danny_SsB and Mada0)
if !{defined __TIMED_STOCK__} {
define __TIMED_STOCK__()
print "included TimedStock.asm\n"

// @ Description
// SSB uses a bitwise behavior for time and stock so (mode 1 = time, mode 2 = stock, 1 & 2 = both).
// Timed stock matches were likely planned but cut during development. This file replaces stock
// matches with timed stock matches.

include "OS.asm"
include "Global.asm"

scope TimedStock {
    constant calculate_time_score_(0x801373F4)
    constant calculate_stock_score_(0x801373CC)

    // @ Description
    // Enable TimedStock scoring for FFA (mode = 2 to mode = 3)
    OS.patch_start(0x001241A0, 0x801337F0)
    ori     t8, r0, 0x0003                  // t8 = (stock & time)
    OS.patch_end()

    // @ Description
    // Enable TimedStock scoring for Teams (mode = 2 to mode = 3)
    OS.patch_start(0x001241B4, 0x80133804)
    ori     t9, r0, 0x0003                  // t9 = (stock & time)
    OS.patch_end()

    // @ Description
    // This block originally used a bitwise and for time (mode & 1) but now checks against time to
    // determine whether or not to display stock_number of stock icons.
    OS.patch_start(0x001389F8, 0x8013A778)
    lli     t6, 0x0001
    bnel    t6, t5, 0x8013A790
    OS.patch_end()

    // @ Description
    // Correct scoring. The check usually checks against 0x02 (stock) but the mode will always be
    // 1 or 3. The simple fix is to change 2 to 3
    OS.patch_start(0x00156560, 0x801373C0)
    addiu   at, r0, 0x0003
    OS.patch_end()

    // @ Description
    // Correct scoring for matches with timer.
    // This hook is used any time the timer reachs 0.
    // Score is adjusted as follows:
    //  - (KOs - deaths) for Time
    //  - (initial stock count - deaths + 1) << 0xC + (damage taken if stocks remaining) for Stock/Stamina
    // Stock and Stamina are scored this way so we can break ties.
    // @ Arguments
    // a0 = player
    // @ Returns
    // v0 - score
    // @ Free Registers
    // t6, t7
    scope score_fix_: {
        OS.patch_start(0x155DA8, 0x80136C08)
        j       score_fix_
        nop
        OS.patch_end()

        li      t6, Global.vs.game_mode     // t6 = address of vs game_mode
        lbu     t6, 0x0000(t6)              // t6 = vs game_mode ( 1 = time, 3 = stock, 5 = stamina)
        lli     t7, 0x0001                  // t7 = stock
        beq     t6, t7, _time               // branch if Time mode
        nop

        _stock:
        sll     v1, a0, 0x0002              // (original) v1 = offset = player * 4
        lui     t6, 0x8014                  // (original) t6 = address of ?
        addu    t6, t6, v1                  // (original) t6 = address of ? + offset
        lw      t6, 0x9B90 (t6)             // (original) t6 = deaths
        li      t7, StockMode.initial_stock_count_table
        addu    t7, t7, a0                  // t7 = address of initial stock count
        lbu     t7, 0x0000(t7)              // t7 = initial stock count
        subu    v0, t7, t6                  // v0 = initial stock count - deaths

        addiu   v0, v0, 0x0001              // v0 = stocks remaining at end of match
        beqz    v0, _end                    // if no stocks remaining, skip adding damage/h.p.
        sll     v0, v0, 0x000C              // v0 = v0 << 0xC = v0 * 0x1000

        li      t6, Global.vs.p1            // t6 = vs struct for p1
        lli     v1, Global.vs.P_DIFF        // v1 = Global.vs.P_DIFF
        multu   v1, a0                      // v1 = offset to px
        mflo    v1                          // ~
        addu    t6, t6, v1                  // t6 = Global.vs.px
        lw      v1, 0x004C(t6)              // v1 = ending damage
        b       _end
        subu    v0, v0, v1                  // v0 = score

        _time:
        sll     v1, a0, 0x0002              // (original) v1 = offset = player * 4
        lui     t6, 0x8014                  // (original) t6 = address of ?
        addu    t6, t6, v1                  // (original) t6 = address of ? + offset
        lw      t7, 0x9B90(t6)              // (original) t7 = deaths
        lw      t6, 0x9B80(t6)              // (original) t6 = KOs
        subu    v0, t6, t7                  // (original) v0 = score = KOs - deaths

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Correct scoring (time/stock mode update) [bit]
    scope pick_scoring_: {
        OS.patch_start(0x156564, 0x801373C4)
        j   pick_scoring_
        OS.patch_end()

        lli     t0, 0x0001              // t1 = time
        beq     t6, t0, _time           // if mode == time, branch to time
        nop
        li      t0, Global.vs.timer     // t0 = address of timer
        lw      t0, 0x0000(t0)          // t0 = timer
        beqz    t0, _time               // if timer at 0, use time scoring hook
        nop

        _stock:
        j       calculate_stock_score_
        nop

        _time:
        j       calculate_time_score_
        nop
    }

    // Prevent sudden death when not Time mode [bit]
    OS.patch_start(0x10A4F8, 0x8018D608)
    lli     t7, 0x0001                  // t7 = 1 for time
    beq     t6, t7, 0x8018D61C          // take time branch if in Time mode
    OS.patch_end()

    // Allows always viewing full (KOs & TKOs) results screen
    scope show_full_results_: {
        OS.patch_start(0x156884, 0x801376E4)
        j       show_full_results_
        lui     v1, 0x8014                    // original line 2
        _return_normal:
        bne     a0, t7, 0x80137728            // original line 3 - if mode is not Time, go to KOs only results screen
        _return_full:
        OS.patch_end()

        li      a0, Toggles.entry_full_results
        lw      a0, 0x0004(a0)                // a0 = 1 if we should always show full results
        bnez    a0, _full                     // if we should always show full results, do so
        addiu   a0, r0, 0x0001                // original line 1

        j       _return_normal                // otherwise, return normally
        nop

        _full:
        j       _return_full
        nop
    }
}

} // __TIMED_STOCK__
