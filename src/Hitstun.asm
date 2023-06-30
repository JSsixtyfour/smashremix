scope Hitstun {  
    // @ Description
    // Toggle for Melee Style Hitstun.
    // Divides Knockback by 2.5, instead of 1.875, thus less hitstun
    scope hitstun_: {
        OS.patch_start(0x659B0, 0x800EA1B0)
        j       hitstun_
        nop
        hitstun_end_:
        OS.patch_end()
        
        
        lui     at, 0x3FF0                  // original line 1 (1.875 fp)
        mtc1    at, f4                      // original line 2, move to floating point register (f4)
        Toggles.single_player_guard(Toggles.entry_hitstun, hitstun_end_)
        
        lui     at, 0x4020                  // Melee style, higher divisor, so less hitstun
        mtc1    at, f4                      // original line 2
        
        j      hitstun_end_         // return
        nop
    }
}