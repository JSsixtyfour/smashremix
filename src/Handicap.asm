// Handicap.asm
if !{defined __HANDICAP__} {
define __HANDICAP__()
print "included Handicap.asm\n"

include "Global.asm"
include "Toggles.asm"
include "OS.asm"

// TODO: auto and AI fix

scope Handicap {

    // @ Description
    // This function disables damage handicaps by setting the expected value to the max (9). It also
    // overwrites the stock value at 0x0007(a1). This still requires handicap to be on in the VS.
    // Options menu
    scope use_stocks_: {
        OS.patch_start(0x0010A38C, 0x8018D49C)
        j       use_stocks_
        nop
        _use_stocks_return:
        lbu     t5, 0x0020(v1)              // original line 3
        sb      t5, 0x0076(sp)              // original line 4
        nop                                 // move stock to use_stock_
        OS.patch_end()

        lbu     t9, 0x0021(v1)              // original line 1 (t9 = handicap)
        sb      t9, 0x0075(sp)              // original line 2
        lbu     t8, 0x0007(a1)              // original line 5 (t8 = stocks)

        Toggles.guard(Toggles.entry_stock_handicap, _use_stocks_return)

        li      t9, Global.vs.handicap      // ~
        lbu     t9, 0x0000(t9)              // at = handicap
        beqz    t9, _end                    // if handicap disabled, end
        nop

        lbu     t8, 0x0021(v1)              // t8 = handicap value = stocks (overwritten below)
        addiu   t8, t8,-0x0001              // off by 1 error

        _end:
        lli     t9, 0x0009                  // original line 1 (handicap = 9)
        sb      t9, 0x0075(sp)              // original line 2
        j       _use_stocks_return          // return
        nop
    }

}

} // __HANDICAP__
