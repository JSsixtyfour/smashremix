// GameEnd.asm
if !{defined __GAME_END__} {
define __GAME_END__()
print "included GameEnd.asm\n"

// @ Description
// This file modidfies what screen the game exits to.

include "Toggles.asm"
include "OS.asm"

scope GameEnd {

    // @ Description
    // Reset combination mask + Start
     constant BUTTON_MASK(Joypad.A | Joypad.B | Joypad.Z | Joypad.R | Joypad.START )

    // @ Description
    // This function changes the screen_id loaded into t6 if skip results screen is enabled
    scope update_screen_: {
        OS.patch_start(0x0010B204, 0x8018E314)
        // CHECK SALTY RUNBACK FIRST
        j       update_screen_._salty_runback
        nop
        _update_screen_return:
        OS.patch_end()

        _skip_results_screen:
        Toggles.guard(Toggles.entry_skip_results_screen, _update_screen_return)
        lli     t6, 0x0010                  // original line 1 (modified to character select screen)
        sb      t6, 0x0000(v0)              // original line 2
        j       _update_screen_return       // return
        nop

        _salty_runback:
        lli     t6, 0x0018                  // original line 1
        sb      t6, 0x0000(v0)              // original line 2

        li      t6, TwelveCharBattle.twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        bnez    t6, _skip_results_screen    // if 12cb mode, don't allow salty runback
        nop

        Toggles.guard(Toggles.entry_salty_runback, _skip_results_screen)
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      v0, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~ 
        sw      a0, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~
        sw      a2, 0x0018(sp)              // save registers

        // p1
        lli     a0, BUTTON_MASK             // a0 - button masks
        lli     a1, OS.FALSE                // a1 - all must be pressed
        lli     a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = bool
        nop
        bnez    v0, _success                // if held, restart
        nop

        // end
        lw      t0, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // ~
        lw      a2, 0x0018(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        j       update_screen_              // check skip results
        nop

        _success:
        lw      t0, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // restore registers
        lli     t6, 0x0016                  // original line 1 (modified to fight screen)
        sb      t6, 0x0000(v0)              // original line 2
        j       _update_screen_return       // return
        nop
    }

}

} // __GAME_END__
