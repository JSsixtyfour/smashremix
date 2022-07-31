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

    // @ Description
    // This hook corrects the aspect ratio of the menu when widescreen mode is enabled. This is called everytime the screen is changed.
    // Intended for 16:9 displays that wish to play the game in widescreen mode but to retain original aspect ratio of menus without stretching.
    scope menu_fix_aspect_ratio_: {
        OS.patch_start(0x1B20, 0x80000F20)
        j      menu_fix_aspect_ratio_
        nop
        _menu_fix_return:
        OS.patch_end()

        li     t5, Toggles.entry_widescreen
        lw     t5, 0x0004(t5)               // t5 = 1 if enabled, 0 if disabled
        beqz   t5, _end                     // if widescreen mode is disabled, skip menu fix
        nop

        li     t5, Global.current_screen
        lb     t5, 0x0000(t5)
        // list of screens we don't want to correct the aspect ratio for
        addiu  at, r0, 0x16                 // at = vs mode
        beq    at, t5, _end                 // skip if equal (already handled by enable_widescreen_)
        addiu  at, r0, 0x33                 // at = end of stage screen for 1P mode
        beq    at, t5, _end                 // skip if equal (already handled by enable_widescreen_)
        addiu  at, r0, 0x01                 // at = 1P mode or title screen
        beq    at, t5, _end                 // skip if equal (they share the same id/ handled by enable_widescreen_)
        addiu  at, r0, 0x36                 // at = training mode
        beq    at, t5, _end                 // skip if equal  (already handled by enable_widescreen_)
        addiu  at, r0, 0x35                 // at = bonus mode
        beq    at, t5, _end                 // skip if equal  (already handled by enable_widescreen_)
        addiu  at, r0, 0x77                 // at = Remix mode
        beq    at, t5, _end                 // skip if equal  (already handled by enable_widescreen_)
        addiu  at, r0, 0x38                 // at = Credits screen
        beq    at, t5, _end                 // skip if equal
        nop

        // if here, correct aspect ratio
        lui    at, 0x8004                   // original line 1
        addiu  t5, r0, 0x02A1               // VI_X_SCALE_REG(0x30)  = 0x2A1
        sw     t5, 0x4F08(at)               // overwrite value for this Video Interface Register
        li     t5, 0x00B402A0               // VI_H_START(0X24) = 0XB4, H_VIDEO_REG(0X26) = 0X02A0
        sw     t5, 0x4F04(at)               // overwrite value for this Video Interface Register

        _end:
        lui    at, 0x8004                   // original line 1
        j      _menu_fix_return
        sw     r0, 0x4F88(at)               // original line 2

    }

}

} // __WIDESCREEN__
