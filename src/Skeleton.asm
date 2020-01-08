// Skeleton.asm
if !{defined __SKELETON__} {
define __SKELETON__()
print "included Skeleton.asm\n"

// @ Description
// Skeleton display is implemented in this file

include "Toggles.asm"
include "OS.asm"

scope Skeleton {

    macro apply_skeleton_mode(register) {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // store registers

        li      t0, Toggles.entry_special_model
        lw      t0, 0x0004(t0)              // t0 = 2 if skeleton_mode
        lli     t1, 0x0002                  // t1 = 2
        bne     t0, t1, _end                // if not skeleton mode, skip
        nop
        
        lui     t0, 0x0800                  // ~
        or      {register}, {register}, t0  // enable skeleton bitflag
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // load registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_1_: {
        OS.patch_start(0x6DCB0, 0x800F24B0)
        jal     skeleton_mode_1_
        nop
        OS.patch_end()

        lw      v1, 0x0A88(a1)              // original line 1
        lw      a3, 0x09C8(a1)              // original line 2

        apply_skeleton_mode(v1)
    }

    // @ Description
    // This hooks into a function that displays the character's "skeleton" (the model displayed when a character is electrified)
    scope skeleton_mode_2_: {
        OS.patch_start(0x6DA28, 0x800F2228)
        jal     skeleton_mode_2_
        nop
        OS.patch_end()
        
        lw      t7, 0x0A88(t4)              // original line 1
        sll     t3, v1, 0x3                 // original line 2
        
        apply_skeleton_mode(t7)
    }
}
}
