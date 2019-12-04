// Widescreen.asm
if !{defined __WIDESCREEN__} {
define __WIDESCREEN__()
print "included Widescreen.asm\n"

// @ Description
// This file enables widescreen (16:9) matches.

include "Toggles.asm"
include "OS.asm"

scope Widescreen {

    // @ Description
    // The following code enables widescreen [Danny_SsB]. I have no iddea how it works
    OS.patch_start(0x000AA37C, 0x00000000)
    dw      0x3FEF311A
    OS.patch_end()

    OS.patch_start(0x00051C80, 0x00000000)
    dw      0x3FEF311A
    OS.patch_end()

    OS.patch_start(0x000891B4, 0x8010D9B4)
    nop
    OS.patch_end()

    // @ Description
    // This function enables widescreen if the widescreen screen toggle is enabled
    scope enable_widescreen_: {
        OS.patch_start(0x000891B4, 0x8010D9B4)
        j       enable_widescreen_._guard
        nop
        _enable_widescreen_return:
        OS.patch_end()

        _no_widescreen:
        swc1    f10, 0x0024(s1)             // original line 1
        lwc1    f16, 0x0C50(at)             // original line 2
        j       _enable_widescreen_return   // return
        nop

        _guard:
        Toggles.guard(Toggles.entry_widescreen, _no_widescreen)
        nop                                 // don't do original line 1 to enable widescreen
        lwc1    f16, 0x0C50(at)             // original line 2
        j       _enable_widescreen_return   // return
        nop
    }

}

} // __WIDESCREEN__
