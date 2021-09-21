// Widescreen.asm
if !{defined __WIDESCREEN__} {
define __WIDESCREEN__()
print "included Widescreen.asm\n"

// @ Description
// This file enables widescreen (16:9) matches.

include "Toggles.asm"
include "OS.asm"

scope Widescreen {
    // The following code enables widescreen.
    // Based on work done by Danny_SsB. I have no idea how it works.

    // @ Description
    // This function enables widescreen in matches if the widescreen screen toggle is enabled
    scope enable_widescreen_: {
        OS.patch_start(0x000890D0, 0x8010D8D0)
        jal    enable_widescreen_._match_start_1
        lw     t4, 0x000C(t3)               // original line 1
        OS.patch_end()

        OS.patch_start(0x000891B4, 0x8010D9B4)
        jal     enable_widescreen_._match_start_2
        lwc1    f16, 0x0C50(at)             // original line 2
        OS.patch_end()

        _match_start_1:
        li      t5, Toggles.entry_widescreen
        lw      t5, 0x0004(t5)              // t5 = 1 if enabled, 0 if disabled
        beqz    t5, _end_match_start_1      // if disabled, skip
        nop                                 // otherwise load a different value
        li      t4, 0x3FE8BA2F
        _end_match_start_1:
        jr      ra
        sw      t4, 0x0024(s1)              // original line 2

        _match_start_2:
        li      t7, Toggles.entry_widescreen
        lw      t7, 0x0004(t7)              // t7 = 1 if enabled, 0 if disabled
        beqzl   t7, _end_match_start_2      // if disabled, perform original line 1
        swc1    f10, 0x0024(s1)             // original line 1
        _end_match_start_2:
        jr      ra
        nop
    }

}

} // __WIDESCREEN__
