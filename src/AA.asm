// AA.asm
if !{defined __AA__} {
define __AA__()
print "included AA.asm\n"

// @ Description
// This file enables Anti-Aliasing to be toggled.

include "Toggles.asm"
include "OS.asm"

scope AA {

    // @ Description
    // This function disables AA if the Disable AA toggle is enabled
    scope disable_aa_: {
        OS.patch_start(0x00001CCC, 0x800010CC)
        j       disable_aa_._1
        ori     t7, t6, 0x0001              // original line 2
        _disable_aa_return_1:
        OS.patch_end()

        OS.patch_start(0x00001DEC, 0x800011EC)
        j       disable_aa_._2
        nop
        _disable_aa_return_2:
        OS.patch_end()

        OS.patch_start(0x000033F0, 0x800027F0)
        j       disable_aa_._3
        nop
        _disable_aa_return_3:
        OS.patch_end()

        _1:
        li      at, Toggles.entry_disable_aa
        lw      at, 0x0004(at)              // at = 0 if toggle not on
        beqzl   at, _return_1               // if AA not disabled, use original line
        lui     at, 0x0001                  // original line 1

        lui     at, 0x0000                  // otherwise disable

        _return_1:
        j       _disable_aa_return_1        // return
        nop

        _2:
        li      at, Toggles.entry_disable_aa
        lw      at, 0x0004(at)              // at = 0 if toggle not on
        beqzl   at, _return_2               // if AA not disabled, use original line
        addiu   at, r0, 0xFCFF              // original line 1

        addiu   at, r0, 0xFEFF              // otherwise disable

        _return_2:
        j       _disable_aa_return_2        // return
        and     t8, t7, at                  // original line 2

        _3:
        li      v0, Toggles.entry_disable_aa
        lw      v0, 0x0004(v0)              // v0 = 0 if toggle not on
        beqzl   v0, _default                // if AA not disabled, use original line
        lui     v0, 0x0001                  // original line 1

        j       _disable_aa_return_3        // otherwise, disabled
        ori     v0, r0, 0x0216              // v0 = 0x00000216

        _default:
        j       _disable_aa_return_3        // return
        ori     v0, v0, 0x0016              // original line 2
    }

}

} // __AA__
