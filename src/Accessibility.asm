// Accessibility.asm (code by goom)
if !{defined __ACCESSIBILITY__} {
define __ACCESSIBILITY__()
print "included Accessibility.asm\n"

// This file includes several accessibility-related toggles.
// May help with photosensitivity and/or motion sickness by reducing flashes and camera shake.

scope Accessibility {

    // @ Description
    // Reimplements the unused 'Anti-Flash' feature.
    // This disables certain screen flashes (hard hits, Zebes acid, barrel etc)
    // Vanilla reads value stored at 0x800A4930 which is always 1 (no option to toggle)
    // Note: included checks in DekuNut.asm and Flashbang.asm for '0x80131A40' screen flashes
    //       included checks in Lighting.asm as well
    scope flash_guard: {
        OS.patch_start(0x91610, 0x80115E10)
        j       flash_guard
        addiu   a0, r0, 0x03F8              // original line 2
        _return:
        OS.patch_end()

        li      t6, Toggles.entry_flash_guard
        lw      t6, 0x0004(t6)              // t5 = 1 if Flash Guard is enabled
        xori    t6, t6, 1                   // 0 -> 1 or 1 -> 0 (flip bool)

        _end:
        //// lbu     t6, 0x4930(t6)         // original line 1
        j       _return                     // return
        nop
    }

    // @ Description
    // This handles screenshake intensity, which can be lowered or turned off altogether.
    scope screenshake_toggle: {
        OS.patch_start(0x7C164, 0x80100964)
        j       screenshake_toggle
        nop
        _return:
        OS.patch_end()

        // v1 = severity (0 = light, 1 = moderate, 2 = heavy, 3 = POW block)
        li      a0, Toggles.entry_screenshake
        lw      a0, 0x0004(a0)              // t5 = 0 if 'DEFAULT', 1 if 'LIGHT', 2 if 'OFF'
        beqzl   a0, _end                    // branch accordingly
        lw      v1, 0x0030(sp)              // original line 1
        sltiu   a0, a0, 2                   // a0 = 1 if 'LIGHT'
        bnezl   a0, _end                    // branch accordingly
        or      v1, r0, r0                  // v1 = 0 (force all shakes to be Light)
        // if we're here, screenshake is set to 'OFF'
        addiu   v1, r0, -0x0001             // v1 = -1 (invalid intensity, so it doesn't take any shake branches)
        
        _end:
        or      a0, s0, r0                  // original line 2
        j       _return                     // return
        nop
    }
} // __ACCESSIBILITY__
