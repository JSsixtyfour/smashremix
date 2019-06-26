// this assembly and its other parts in scoring and main is lifted directly from 19xxte. All credit to Cyjorg, Danny_SsB and Mada0.
// TimedStock.asm (original by Danny_SsB and Mada0)
// @ Description
// SSB uses a bitwise behavior for time and stock so (mode 1 = time, mode 2 = stock, 1 & 2 = both).
// Timed stock matches were likely planned but cut during development. This file replaces stock
// matches with timed stock matches.
  
    // @ Description
    // Correct scoring for matches with timer [bit]
    // This hook is used any time there the timer reachs 0. Score is adjusted
    // to (KOs - deaths) for Time and (stock setting - deaths) for Stock
    // @ Arguments
    // a0 = player
    // @ Returns
    // v0 - score
    // @ Free Registers
    // t6, t7
  
_scorefix:
   
constant vsgame_mode(0x800A4D0B)
constant vsstocks_(0x800A4D0F)

        li      t6,	vsgame_mode     		// t6 = address of vs game_mode
        lbu     t6, 0x0000(t6)              // t6 = vs game_mode ( 1 = time, 2 = stock, 3 = both)
        lli     t7, 0x0001                  // t7 = stock
        beq     t6, t7, _time               // branch if timer is enabled
        nop

        _stock:
        sll     v1, a0, 0x0002              // (original) v1 = offset = player * 4 
        lui     t6, 0x8014                  // (original) t6 = address of ?
        addu    t6, t6, v1                  // (original) t6 = address of ? + offset
        lw      t6, 0x9B90 (t6)             // (original) t6 = deaths
        li      t7, vsstocks_        		// t7 = address of stocks_setting
        lbu     t7, 0x0000(t7)              // t7 = stocks_setting
        subu    v0, t6, t7                  // v0 = score = stocks_setting - deaths
        b       _endscorefix
        nop
        
        _time:
        sll     v1, a0, 0x0002              // (original) v1 = offset = player * 4 
        lui     t6, 0x8014                  // (original) t6 = address of ?
        addu    t6, t6, v1                  // (original) t6 = address of ? + offset
        lw      t7, 0x9B90(t6)              // (original) t7 = deaths
        lw      t6, 0x9B80(t6)              // (original) t6 = KOs
        subu    v0, t6, t7                  // (original) v0 = score = KOs - deaths
    
		_endscorefix:
        j	scorefixreturn_
        nop