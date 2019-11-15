// SRAM.asm (read/write fround by bit)
if !{defined __SRAM__} {
define __SRAM__()
print "included SRAM.asm\n"

// @ Description
// SRAM = Static RAM. This file controls saving/loading.

scope SRAM {
    // @ Description
    // Variable to hold current SRAM address. SSB only used 0x0BDC bytes out of 0x8000 available.
    variable address(0x0BDC)
    constant ADDRESS(0x0BDC)

    // @ Description
    // Struct that holds information for a block of save data. 
    macro block(size) {
        dw SRAM.address
        dw pc() + 8
        dw {size}
        fill {size}
        SRAM.address = SRAM.address + {size}
    }

    // @ Description
    // Allocates space for a boolean indicating if the player has saved previously.
    has_saved:; block(4)

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
        lli     a2, 0x0004                  // a2 - size
        jal     write_                      // write true to has_saved
        nop

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers 
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        true:
        dw OS.TRUE
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
        li      a2, 0x0004                  // a2 - size
        jal     read_                       // read from  has_saved
        nop
        li      v0, return                  // ~
        lw      v0, 0x0000(v0)              // v0 = ret

        lw      a0, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      ra, 0x0014(sp)              // restore registers 
        addiu   sp, sp, 0x0018              // deallocate stack space
        jr      ra                          // return
        nop

        return:
        dw OS.FALSE
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
}

} // __SRAM__
