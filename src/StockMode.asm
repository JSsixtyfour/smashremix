// StockMode.asm
if !{defined __STOCKMODE__} {
define __STOCKMODE__()
print "included StockMode.asm\n"

include "Global.asm"

scope StockMode {
    // @ Description
    // Holds stock mode for players 1-4
    stockmode_table:
    dw 0, 0, 0, 0                           // stock mode for p1 through p4

    // @ Description
    // Holds stock count when in manual stock mode for players 1-4
    // Initialize for 4 stocks
    stock_count_table:
    db 3, 3, 3, 3                           // stock count override for p1 through p4

    // @ Description
    // Holds previous stock count for players 1-4
    // Initialize for 4 stocks
    previous_stock_count_table:
    db 3, 3, 3, 3                           // previous stock count override for p1 through p4

    // @ Description
    // Holds initial stock count for the match for players 1-4, for all stock modes.
    // This is helpful when scoring on the results screen.
    // Initialize for 4 stocks
    initial_stock_count_table:
    db 3, 3, 3, 3                           // initial stock count for p1 through p4

    // @ Description
    // Mode constants
    scope mode {
    	constant DEFAULT(0)
    	constant LAST(1)
    	constant MANUAL(2)
    }

    // @ Description
    // Sets the initial stock count based on the stock mode
    scope set_initial_stock_count_: {
        OS.patch_start(0x10A3A4, 0x8018D4B4)
        jal     set_initial_stock_count_
        lbu     t6, 0x0022(v1)              // original line 2
        OS.patch_end()

        // s0 = port_id

        li      a0, TwelveCharBattle.twelve_cb_flag
        lw      a0, 0x0000(a0)              // a0 = 1 if 12cb mode
        bnez    a0, _end                    // if 12cb mode, t8 is already correct, so skip
        nop

        li      a0, stockmode_table         // a0 = stock mode table
        sll     a1, s0, 0x0002              // a1 = offset to stock mode for port
        addu    a0, a0, a1                  // a0 = address of port's stock mode
        lw      a0, 0x0000(a0)              // a0 = stock mode

        beqz    a0, _end                    // if in default stock mode, skip
        lli     a1, mode.LAST               // a1 = mode.LAST

        beq     a0, a1, _use_last           // if in LAST mode, jump to _use_last
        nop                                 // otherwise it's manual mode

        li      a0, stock_count_table       // a0 = stock count table
        addu    a0, a0, s0                  // a0 = address of port's stock count
        lbu     t8, 0x0000(a0)              // t8 = stock count

        b       _end
        nop

        _use_last:
        li      a0, previous_stock_count_table // a0 = previous stock count table
        addu    a0, a0, s0                  // a0 = address of port's previous stock count
        lb      a1, 0x0000(a0)              // a1 = previous stock count
        bltzl   a1, _end                    // if a1 < 0 then keep t8 and update previous stock count value
        sb      t8, 0x0000(a0)              // update previous stock count

        // otherwise, use previous stock count value
        or      t8, a1, r0                  // t8 = previous stock count

        _end:
        li      a0, initial_stock_count_table
        addu    a0, a0, s0                  // a0 = address of port's initial stock count
        sb      t8, 0x0000(a0)              // save initial stock count in our custom table

        jr      ra
        sb      t8, 0x0077(sp)              // original line 1
    }
}

} // __STOCKMODE__
