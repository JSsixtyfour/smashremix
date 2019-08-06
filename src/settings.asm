scope Settings {    
    // @ Description
    // This function sets VS. Mode settings to tournament settings. This hook was selected because
    // it occurs directly after VS. Mode settings are written. This should not be called. ALL CREDIT TO CYJORG.
	// lifted directly from TE.
    set_vs_settings_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        li      t0, vsgame_mode     		// ~
        lli     t1, GAME_MODE               // ~
        sb      t1, 0x0000(t0)              // update game mode

        li      t0, vstime          // ~
        lli     t1, TIME                    // ~
        sb      t1, 0x0000(t0)              // update time

        li      t0, vsstocks_		        // ~
        lli     t1, STOCKS                  // ~
        sb      t1, 0x0000(t0)              // update stocks

        li      t0, vsteam_attack   // ~
        lli     t1, TEAM_ATTACK             // ~
        sb      t1, 0x0000(t0)              // update team attack

        li      t0, vsitem_frequency		// ~
        lli     t1, ITEM_FREQUENCY          // ~
        sb      t1, 0x0000(t0)              // update game Mode

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
		
        addiu   sp, sp, 0x0010              // deallocate stack space
        lw      t5, 0x0000(t1)              // original line 1
        lui     t6, 0x800A                  // original line 2
        j       _set_vs_settings_return     // return 
        nop
    }
 }