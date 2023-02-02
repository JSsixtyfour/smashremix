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
    // (R)esu(L)ts mask (display results regardless of toggles)
    constant BUTTON_MASK_RL(Joypad.R | Joypad.L )

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
        // reset pause dpad cycle initial delay
        li      t1, Pause.dpad_song_cycle_timer   // t1 = dpad_song_cycle_timer
        addiu   t6, r0, 0x0002
        sw      t6, 0x0000(t1)              // save updated timer

        lli     t6, 0x0018                  // original line 1
        sb      t6, 0x0000(v0)              // original line 2

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      v0, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~ 
        sw      a0, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~
        sw      a2, 0x0018(sp)              // save registers

        lli     a0, BUTTON_MASK_RL          // a0 - button masks
        lli     a1, OS.FALSE                // a1 - all must be pressed
        lli     a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_all_   // v0 - bool dd_pressed
        nop
        li      t1, _update_screen_return   // ~
        bnez    v0, _end                    // if held, skip skip results check
        nop

        li      t6, TwelveCharBattle.twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        li      t1, _skip_results_screen    // in 12cb mode without RL held, need to check skip
        bnez    t6, _end                    // if 12cb mode, don't allow salty runback
        nop

        li      t6, Toggles.entry_salty_runback
        lw      t0, 0x0000(t6)              // t0 = 0 if salty runback is off
        beqzl   t0, _no_salty_runback       // if salty runback is off, skip check
        nop

        // p1
        lli     a0, BUTTON_MASK             // a0 - button masks
        lli     a1, OS.FALSE                // a1 - all must be pressed
        lli     a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_all_   // v0 = bool
        nop
        bnez    v0, _success                // if held, restart
        nop

        _no_salty_runback:
        // end
        li      t1, update_screen_          // check skip results

        _end:
        li      t0, is_salty_runback        // t0 = address of is_salty_runback
        sw      r0, 0x0000(t0)              // is_salty_runback = 0
        lw      t0, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // ~
        lw      a2, 0x0018(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      t1                          // return
        nop

        _success:
        li      t0, is_salty_runback        // t0 = address of is_salty_runback
        li      t6, 0x0001                  // t6 = 1
        sw      t6, 0x0000(t0)              // is_salty_runback = 1
        lw      t0, 0x0004(sp)              // ~
        lw      v0, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // restore registers
        lli     t6, 0x0016                  // original line 1 (modified to fight screen)
        sb      t6, 0x0000(v0)              // original line 2
        j       _update_screen_return       // return
        nop
    }

    is_salty_runback:
    dw 0

}

} // __GAME_END__
