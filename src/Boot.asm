// Boot.asm
if !{defined __BOOT__} {
define __BOOT__()
print "included Boot.asm\n"

// @ Description
// This file loads Remix data into RAM.

include "OS.asm"
include "Global.asm"
include "Toggles.asm"
include "SRAM.asm"

scope Boot {
    // @ Description
    // Nintendo 64 logo exits to 1p victory screen because t1 contains screen ID 0x0037
    // instead of 0x001C
    OS.patch_start(0x0017EE54, 0x80131C94)
    ori     t1, r0, 0x0037
    OS.patch_end()

    // @ Description
    // After the Nintendo 64 logo exits we display the 1p victory screen but we want it
    // to display a different image than the Mario victory image, so we set the character
    // ID to NONE which will never occur after beating 1p mode.
    // See SinglePlayer.replace_victory_image_
    scope splash_: {
        // @ Description
        // unused word which will be used as a countdown timer
        constant TIMER(0x801322F8)

        // @ Description
        // the character id of the 1p victor
        constant VICTOR_ID(0x801322E0)

        // image
        OS.patch_start(0x17EA6C, 0x8013205C)
        jal     splash_
        nop
        OS.patch_end()
        // FGM
        OS.patch_start(0x17E958, 0x80131F48)
        jal     splash_._fgm
        nop
        OS.patch_end()
        // Countdown timer
        OS.patch_start(0x17E650, 0x80131C40)
        jal     splash_._countdown
        nop
        _countdown_return:
        OS.patch_end()
        // prevent frame buffer blue screen glitch
        OS.patch_start(0x17EA2C, 0x8013201C)
        jal     splash_._frame_buffer_glitch_fix
        nop
        OS.patch_end()

        lli     t8, 0x0000              // t8 = 0 (original value stored in 0x801322E0)

        lli     at, 0x001B              // at = N64 logo screen id
        bne     v0, at, _end            // if previous screen is not the N64 logo screen
        nop                             // then skip

        lli     t8, 0x0200              // t8 = initial countdown timer value
        li      at, TIMER               // at = countdown timer address
        sw      t8, 0x0000(at)          // set countdown timer
        lli     t8, Character.id.NONE   // t8 = Character.id.NONE, which we will detect to display splash images

        _end:
        lui     at, 0x8013              // original line 0
        j       0x80132084              // original line 1 (modified to jump instead of branch)
        sw      t8, 0x22E0(at)          // original line 2 (modified to use custom value)

        _fgm:
        mtlo    ra                      // save ra
        lli     at, Character.id.NONE   // at = Character.id.NONE
        bne     t3, at, pc() + 12       // if character id is not none, skip
        nop                             // otherwise we'll use a nice sound:
        lli     v0, 0x0A0               // v0 = fgm_id of a nice sound
        jal     0x800269C0              // original line 1
        andi    a0, v0, 0xFFFF          // original line 2
        mflo    ra                      // restore ra
        jr      ra
        nop

        _countdown:
        li      a0, VICTOR_ID           // a0 = victor character_id address
        lw      a0, 0x0000(a0)          // a0 = victor character_id
        lli     v0, Character.id.NONE   // v0 = Character.id.NONE
        bne     a0, v0, _check_button_press
        nop                             // skip timer check if not on splash screen

        li      a0, TIMER               // a0 = countdown timer address
        lw      v0, 0x0000(a0)          // v0 = countdown timer value
        beqzl   v0, _return             // if the countdown timer is 0,
        addiu   v0, r0, 0x0001          // then set v0 to nonzero to simulate button press

        addiu   v0, v0, -0x0001         // otherwise, decrement the timer value
        sw      v0, 0x0000(a0)          // and update the timer

        // check for button press
        _check_button_press:
        jal     0x80131B6C              // original line 1
        ori     a0, r0, 0xD000          // original line 2

        _return:
        j       _countdown_return
        nop

        _frame_buffer_glitch_fix:
        li      a1, Global.previous_screen
        lbu     a1, 0x0000(a1)          // a1 = previous_screen
        lli     v0, 0x001B              // v0 = N64 logo screen id
        bne     v0, a1, _end_fb_fix     // if previous screen is not the N64 logo screen
        addiu   v0, r0, 0x00FF          // then use original value (original line 2)

        // otherwise, just use r0 to clear the frame buffer (actually the rest of normal RAM)
        // I don't know why this matters, but it works
        addu    v0, r0, r0

        _end_fb_fix:
        jr      ra                      // return
        lui     a1, 0x8040              // original line 1
    }

    // @ Description
    // Draws the version on the title screen
    scope draw_version_on_title_screen_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        Render.load_font()
        Render.draw_string(1, 3, string_version, Render.NOOP, 0x43200000, 0x435A0000, 0x888800FF, 0x3F700000, Render.alignment.CENTER)

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    string_version:; String.insert("Smash Remix v1.3.1")

    // @ Description
    // Nintendo 64 logo cannot be skipped.
    // Instead of checking for a button press, the check has been disabled.
    OS.patch_start(0x0017EE18, 0x80131C58)
    beq     r0, r0, 0x80131C80
    OS.patch_end()

    // @ Description
    // Performs one DMA as part of the boot sequence.
    // It transfers 0x400000 bytes to 0x80400000.
    scope load_: {
        OS.patch_start(0x00001234, 0x80000634)
        j       0x80000438
        nop
        OS.patch_end()

        OS.patch_start(0x00001038, 0x80000438)
        jal     Global.dma_copy_        // original line 1
        addiu   a2, r0, 0x0100          // original line 2
        lui     a0, 0x0200              // load rom address (0x02000000)
        lui     a1, 0x8040              // load ram address (0x80400000)
        jal     Global.dma_copy_        // add custom functions
        lui     a2, 0x0040              // load length of 0x400000
        j       load_                   // finish function
        nop
        OS.patch_end()

        jal     SRAM.check_saved_       // v0 = has_saved
        nop
        addiu   sp, sp,-0x0008          // allocate stack space
        sw      t0, 0x0004(sp)          // save t0
        lli     t0, OS.TRUE             // t0 = OS.TRUE
        bne     v0, t0, _initialize     // if (!has_saved), initialize SRAM
        nop
        jal     Toggles.load_           // load toggles
        nop

        _continue:
        lw      t0, 0x0004(sp)          // restore t0
        addiu   sp, sp, 0x0008          // deallocate stack space

        j       0x80000638              // return
        nop

        _initialize:
        jal     SRAM.initialize_
        nop
        b       _continue
        nop
    }

}

} // __BOOT__
