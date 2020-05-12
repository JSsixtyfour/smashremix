// Camera.asm
if !{defined __CAMERA__} {
define __CAMERA__()
print "included Camera.asm\n"


// @ Description
// This file disables the cinematic introduction before VS. matches.

include "Global.asm"
include "Toggles.asm"
include "OS.asm"

// 80131470 - camera

scope Camera {

    // @ Description
    // This replaces a call to Global.random_int_. Usually, when 0 is returned, the cinematic entry
    // does not play. Here, v0 is always set to 0. 
    scope disable_cinematic_: {
        OS.patch_start(0x0008E250, 0x80112A50)
        j       disable_cinematic_
        nop
        _disable_cinematic_return:
        OS.patch_end()

        jal     Global.get_random_int_      // original line 1
        lli     a0, 0x0003                  // original line 2
        Toggles.guard(Toggles.entry_disable_cinematic_camera, _disable_cinematic_return)

        lli     v0, OS.FALSE                // v0 = not cinematic camera
        j       _disable_cinematic_return   // return
        nop

    }

    // @ Description
    // Allows 360 control over the camera by changing the floats to check against
    // inspired by [Gaudy (Emudigital)] 
    OS.patch_start(0x000AC494, 0x80130C94)
    float32 100                             // x limit
    dw 0x39AE9681                           // x increment
    float32 -100                            // x limit
    float32 100                             // y limit
    dw 0x39AE9681                           // y increment
    float32 -100                            // y limit
    OS.patch_end()
}

} // __CAMERA__
