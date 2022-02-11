// Stereo.asm
if !{defined __STEREO__} {
define __STEREO__()
print "included Stereo.asm\n"

// @ Description
// Allows us to swap L/R stereo channels.

include "OS.asm"
include "Toggles.asm"

scope Stereo {
    // @ Description
    // This fixes a vanilla bug where the original hit SFX would be panned the wrong direction.
    scope fix_sfx_pan_: {
        OS.patch_start(0x440A4, 0x800C86C4)
        j      fix_sfx_pan_
        sw      a0, 0x001C(sp)                // original line 3
        nop
        _return:
        OS.patch_end()

        lli     a1, SinglePlayerModes.HRC_ID
        li      t6, SinglePlayerModes.singleplayer_mode_flag
        lw      t6, 0x0000(t6)                // t6 = singleplayer_mode_flag
        beql    t6, a1, _end                  // if in HRC, center the SFX (the plat is at extreme left of stage)
        lli     v0, 0x0080                    // v0 = center

        li      a1, Toggles.entry_stereo_fix
        lw      a1, 0x0004(a1)                // a1 = 1 if stereo fix is on
        beqz    a1, _end                      // if stereo fix is off, skip
        lli     a1, 0x0080                    // a1 = 80

        // if we're here, adjust the pan value so it goes to the other side
        subu    v0, a1, v0                    // v0 = pan value, corrected

        _end:
        jal     0x800267F4                    // original line 2
        sb      v0, 0x002F(a0)                // original line 1

        j       _return
        nop
    }
}

} // __STEREO__
