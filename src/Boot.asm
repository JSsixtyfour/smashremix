// Boot.asm
if !{defined __BOOT__} {
define __BOOT__()
print "included Boot.asm\n"

// @ Description
// This file loads Remix data into RAM.

include "OS.asm"
include "Global.asm"
include "Toggles.asm"
include "SRAM.asm"

scope Boot {
    // @ Description
    // Nintendo 64 logo exits to title screen because t1 contains screen ID 0x0001
    // instead of 0x001C
    OS.patch_start(0x0017EE54, 0x80131C94)
    ori     t1, r0, 0x0001
    OS.patch_end()

    // @ Descritpion
    // Nintendo 64 logo cannot be skipped.
    // Instead of checking for a button press, the check has been disabled.
    OS.patch_start(0x0017EE18, 0x80131C58)
    beq     r0, r0, 0x80131C80
    OS.patch_end()

    // @ Description
    // Performs one DMA as part of the boot sequence.
    // It transfers 0x400000 bytes to 0x80400000.
    scope load_: {
        OS.patch_start(0x00001234, 0x80000634)
        j       0x80000438
        nop
        OS.patch_end()

        OS.patch_start(0x00001038, 0x80000438)
        jal     Global.dma_copy_        // original line 1
        addiu   a2, r0, 0x0100          // original line 2
        lui     a0, 0x0200              // load rom address (0x02000000)
        lui     a1, 0x8040              // load ram address (0x80400000)
        jal     Global.dma_copy_        // add custom functions
        lui     a2, 0x0040              // load length of 0x400000
        j       load_                   // finish function
        nop
        OS.patch_end()

        jal     SRAM.check_saved_       // v0 = has_saved
        nop
        addiu   sp, sp,-0x0008          // allocate stack space
        sw      t0, 0x0004(sp)          // save t0
        lli     t0, OS.TRUE             // t0 = OS.TRUE
        bne     v0, t0, _continue       // if (!has_saved), skip
        nop
        jal     Toggles.load_           // load toggles
        nop

        _continue:
        lw      t0, 0x0004(sp)          // restore t0
        addiu   sp, sp, 0x0008          // deallocate stack space

        j       0x80000638              // return
        nop
    }

}

} // __BOOT__
