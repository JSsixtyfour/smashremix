// Settings.asm
if !{defined __SETTINGS__} {
define __SETTINGS__()
print "included Settings.asm\n"

// @ Description
// This file is used for loading default tournament settings on boot.

include "OS.asm"
include "Global.asm"

scope Settings {
    // @ TODO Save VS. Settings
    // @ Description
    // These consants are for default tournament settings
    constant GAME_MODE(0x03)
    constant TIME(0x08)
    constant STOCKS(0x03)
    constant TEAM_ATTACK(0x01)
    constant ITEM_FREQUENCY(0x00)

    // @ Description
    // This function sets VS. Mode settings to tournament settings. This hook was selected because
    // it occurs directly after VS. Mode settings are written. This should not be called.
    scope set_vs_settings_: {
        OS.patch_start(0x00040898, 0x800A1B48)
        j       Settings.set_vs_settings_
        nop
        _set_vs_settings_return:
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        li      t0, Global.vs.game_mode     // ~
        lli     t1, GAME_MODE               // ~
        sb      t1, 0x0000(t0)              // update game mode

        li      t0, Global.vs.time          // ~
        lli     t1, TIME                    // ~
        sb      t1, 0x0000(t0)              // update time

        li      t0, Global.vs.stocks        // ~
        lli     t1, STOCKS                  // ~
        sb      t1, 0x0000(t0)              // update stocks

        li      t0, Global.vs.team_attack   // ~
        lli     t1, TEAM_ATTACK             // ~
        sb      t1, 0x0000(t0)              // update team attack

        li      t0, Global.vs.item_frequency// ~
        lli     t1, ITEM_FREQUENCY          // ~
        sb      t1, 0x0000(t0)              // update game Mode

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        lw      t5, 0x0000(t1)              // original line 1
        lui     t6, 0x800A                  // original line 2
        j       _set_vs_settings_return     // retrun 
        nop
    }
}

} // __SETTINGS__