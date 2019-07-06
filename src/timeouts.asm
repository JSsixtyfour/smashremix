// Timeouts.asm (Cyjorg) (additional timeouts found by bit)
if !{defined __TIMEOUTS__} {
define __TIMEOUTS__()
print "included Timeouts.asm\n"

// @ Description
// The following patches disable a conditional check with each screen frame counter. Typically,
// the number of frames ran on the current screen is compared with 18000 frames (5 minutes). Then,
// a conditional branch to a function that changes screens is called. The conditional branch (bne)
// been replaced by a branch always (b) so that the change screen function is never called.

include "OS.asm"

scope Timeouts {

    // Mode select screen
    OS.patch_start(0x0011D5B0, 0x80132620)
    b 0x80132640
    OS.patch_end()

    // 1P menu screen
    OS.patch_start(0x0011EB1C, 0x80132A0C)
    b 0x80132A2C
    OS.patch_end()

    // Option screen
    OS.patch_start(0x00120658, 0x80132EA8)
    b 0x80132ED0
    OS.patch_end()

    // Data screen
    OS.patch_start(0x00121D20, 0x801328D0)
    b 0x801328F0
    OS.patch_end()

    // Versus menu screen
    OS.patch_start(0x001245A0, 0x80133BF0)
    b 0x80133C18
    OS.patch_end()

    // Versus options screen
    OS.patch_start(0x00127284, 0x80133AA4)
    b 0x80133AD4
    OS.patch_end()

    // Versus css
    OS.patch_start(0x00138BDC, 0x8013A95C)
    b 0x8013A984
    OS.patch_end()

    // 1P css
    OS.patch_start(0x001401F4, 0x80137FF4)
    b 0x80138024
    OS.patch_end()

    // Training css
    OS.patch_start(0x00146D08, 0x80137728)
    b 0x80137758
    OS.patch_end()

    // Bonus practice css
    OS.patch_start(0x0014CA28, 0x801369F8)
    b 0x80136A28
    OS.patch_end()

    // Stage selection screen
    OS.patch_start(0x0014F928, 0x80133DB8)
    b 0x80133DE0
    OS.patch_end()
}

} // __TIMEOUTS__