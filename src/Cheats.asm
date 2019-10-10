// Cheats.asm
if !{defined __CHEATS__} {
define __CHEATS__()
print "included Cheats.asm\n"

// @ Description
// This file contains a list of permanent, random patches to make SSB better.

include "OS.asm"

scope Cheats {
    // @ Description
    // Unlocks everything
    OS.patch_start(0x00042B3A, 0x800A3DEA)
    dw 0x007F0C90
    OS.patch_end()

    // @ Description
    // This alters an f3dex2 display list builder function to disable anti-aliasing.
    OS.patch_start(0x000337F8, 0x80032BF8)
    // ori     t2, r0, 0x0212
    OS.patch_end()

    // @ Description
    // The following code enables Widescreen [Danny_SsB]. I have no iddea how it works
    OS.patch_start(0x000AA37C, 0x00000000)
    dw      0x3FEF311A
    OS.patch_end()

    OS.patch_start(0x00051C80, 0x00000000)
    dw      0x3FEF311A
    OS.patch_end()

    OS.patch_start(0x000891B4, 0x8010D9B4)
    // nop
    OS.patch_end()

    // @ Description
    // This makes it so that stock value is always displayed as a number.
    OS.patch_start(0x0008B0D4, 0x8010F8D4)
    // slti    at, s1, 0x0001          // default value is 7
    OS.patch_end()

    // @ Descritpion
    // (I don't remember how this works)
    OS.patch_start(0x00081408, 0x80105C08)
    // nop
    OS.patch_end()

    // @ Description
    // disable music by disable write
    OS.patch_start(0x000216FC, 0x80020AFC)
    // nop
    OS.patch_end()

    // @ Description
    // This allows multiple players to be the same color by bypassing the check.
    OS.patch_start(0x001361C8, 0x80137F48)
    b       0x80137F60
    OS.patch_end()
}

} // __CHEATS__