// SRAM.asm (read/write fround by bit)
if !{defined __SRAM__} {
define __SRAM__()
print "included SRAM.asm\n"

// @ Description
// SRAM = Static RAM. This file controls saving/loading.

scope SRAM {
    // @ Description
    // Variable to hold current SRAM address. SSB only used 0x0BDC bytes out of 0x8000 available.
    // Start aligned at 16 bytes - may not be necessary, but we don't need to be stingy currently.
    variable address(0x0BE0)
    constant ADDRESS(0x0BE0)

    // @ Description
    // Constant to hold current revision. Increment this whenever:
    //  - A new stage is added
    //  - A new MIDI is added
    //  - A new toggle is added
    //  - The order of the toggles is changed
    constant REVISION(0x008B)

    // @ Description
    // Struct that holds information for a block of save data.
    macro block(size) {
        dw SRAM.address
        dw pc() + 8
        dw {size}
        fill {size}
        SRAM.address = SRAM.address + {size}
        // 16 byte align the next address - may not be necessary but let's do it anyway
        while (SRAM.address % 16) {
            SRAM.address = SRAM.address + 1
        }
        if (SRAM.address > 0x8000) {
            print "\n***** SRAM WARNING! ******\nNot enough SRAM! (0x"; OS.print_hex(SRAM.address); print "... it's over 0x8000!)\n"
        }
    }

    // @ Description
    // Allocates space for save info.
    //  - 0x0000 = has_saved: boolean indicating if the player has saved previously.
    //  - 0x0004 = revision_number: revision number, which will help determine if we should load previously saved data.
    save_info:; block(8)

    // @ Description
    // Function to marked has_saved as true.
    scope mark_saved_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      a0, true                    // a0 - RAM source
        li      a1, ADDRESS                 // a1 - SRAM destination
        lli     a2, 0x0010                  // a2 - size
        jal     write_                      // write true to has_saved
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        // Reading/writing only 0x8 bytes didn't work properly on console, so we do 0x10 instead
        true:
        dw OS.TRUE
        dw REVISION
        dw 0x0 // fill
        dw 0x0 // fill
    }

    // @ Description
    // Function to check if the user has saved
    // @ Returns
    // v0 - bool has_saved
    scope check_saved_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0014(sp)              // save registers

        li      a0, ADDRESS                 // a0 - SRAM source
        li      a1, return                  // a1 - RAM destination
        li      a2, 0x0010                  // a2 - size
        jal     read_                       // read from save_info
        nop
        li      v0, return                  // ~
        lli     a0, REVISION                // a0 = current revision number
        lw      a1, 0x0004(v0)              // a1 = saved revision number
        beq     a0, a1, _end                // If the revision numbers match, then trust the has_saved value
        nop                                 // otherwise, set back to FALSE:
        lli     a0, OS.FALSE                // a0 = false
        sw      a0, 0x0000(v0)              // reset saved flag back to FALSE

        _end:
        lw      v0, 0x0000(v0)              // v0 = has_saved bool

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        // Reading/writing only 0x8 bytes didn't work properly on console, so we do 0x10 instead
        return:
        dw OS.FALSE
        dw 0x0 // REVISION
        dw 0x0 // fill
        dw 0x0 // fill
    }


    // @ Description
    // Read from SRAM (load)
    // @ Arguments
    // a0 - SRAM source
    // a1 - RAM destination
    // a2 - size
    constant read_(0x80002DA4)

    // @ Description
    // Read from SRAM wrapper
    // @ Arguments
    // a0 - address of block
    scope load_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        lw      a1, 0x0004(a0)              // a1 - RAM destination
        lw      a2, 0x0008(a0)              // a2 - size
        lw      a0, 0x0000(a0)              // a0 = SRAM source
        jal     read_                       // read
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Write to SRAM (save)
    // @ Arguments
    // a0 - RAM source
    // a1 - SRAM destination
    // a2 - size
    constant write_(0x80002DE0)

    // @ Description
    // Save to SRAM wrapper
    // @ Arguments
    // a0 - address of block
    scope save_: {
        addiu   sp, sp,-0x0018              // allocate stack space
        sw      a0, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        lw      a1, 0x0000(a0)              // a1 = SRAM destination
        lw      a2, 0x0008(a0)              // a2 - size
        lw      a0, 0x0004(a0)              // a0 - RAM source
        jal     write_                      // write
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // restore registers
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // Initializes SRAM
    scope initialize_: {
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      a0, 0x0004(sp)              // save registers
        sw      ra, 0x0008(sp)              // ~

        li      a0, Character.EXTENDED_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.MULTIMAN_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.CRUEL_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.BONUS3_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.REMIX_1P_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.ALLSTAR_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Character.HRC_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        li      a0, Bonus.REMIX_BONUS_HIGH_SCORE_TABLE_BLOCK
        jal     SRAM.save_
        nop

        jal     SRAM.mark_saved_            // mark save file present
        nop

        lw      a0, 0x0004(sp)              // restore registers
        lw      ra, 0x0008(sp)              // ~
        jr      ra                          // return
        addiu   sp, sp, 0x0010              // deallocate stack space
    }
}

} // __SRAM__
