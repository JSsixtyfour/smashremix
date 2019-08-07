// FD.asm
if !{defined __FD__} {
define __FD__()
print "included FD.asm\n"

// @ Description
// This file makes Final Destination playable in VS. mode.

include "OS.asm"
include "Global.asm"

scope FD {

    // @ Description
    // Makes Final Destination playables in VS. mode by skipping a jal to code only available in 
    // in singleplayer
    scope fix_: {
        OS.patch_start(0x00080484 , 0x80104C84)
//      jal     0x80192764                  // original line 1
        j       fix_
        nop
        _fix_return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = current_screen
        lli     t1, 0x0001                  // t1 = singleplayer fight screen
        beq     t0, t1, _singleplayer       // if (current_screen == singleplayer)
        nop

        _else:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _fix_return                 // execution return (skip jal)
        nop


        // this block executes for everything but singleplayer FD
        _singleplayer: 
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jal     0x80192764                  // original line 1
        nop
        j       _fix_return
        nop

    }


    // @ Description
    // Sets track to 0x18 (FD battle music)
    OS.patch_start(0x640CD2, 0x00000000)
    dh 0xC33E
    OS.patch_end()
}

} // __FD__