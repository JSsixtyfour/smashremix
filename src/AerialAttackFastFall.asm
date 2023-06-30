// AerialAttackFastFall.asm

scope AerialAttackFastFall {

    // @ Description
    // This routine checks if the remix toggle is enabled
    scope fast_fall_check: {
    
        Toggles.read(entry_fast_fall_aerials, at)      // at = toggle
        beqz    at, _normal
        nop
        
        // if here, fast fall during aerial attacks is ENABLED
        j       0x800D9160 + 4              // allow fast fall routine
        addiu   sp, sp, -0x0020             // alternate routine line 1

        _normal:
        j       0x800D90E0 + 4              // default routine
        addiu   sp, sp, -0x0020             // default routine line 1

    }

    // based on gameshark code @ https://smashboards.com/threads/gameshark-code-collection.341009/
    OS.patch_start(0xA5638, 0x80129E38) // nair
    dw  fast_fall_check
    OS.patch_end()
    OS.patch_start(0xA564C, 0x80129E4C) // fair
    dw  fast_fall_check
    OS.patch_end()
    OS.patch_start(0xA5660, 0x80129E60) // bair
    dw  fast_fall_check
    OS.patch_end()
    OS.patch_start(0xA5674, 0x80129E74) // uair
    dw  fast_fall_check
    OS.patch_end()
    OS.patch_start(0xA5688, 0x80129E88) // dair
    dw  fast_fall_check
    OS.patch_end()

}