// DI.asm
if !{defined __DI__} {
    define __DI__()
    print "included DI.asm\n"

    include "OS.asm"

    scope DI {
        // @ Description
        // Toggle for Japanese Style DI.
        // The percent effect of DI is different in the international vs J versions, the format of the coding is very similar to DK's Cargo hold
        // In the US 0x40066666 (2.09999990463) and in Japan 0x3fc00000 (1.5)
        // US Version, thus allowing for greater DI distance
        scope di_modifiers: {
            constant DI_NORMAL(0x0)
            constant DI_JAPANESE(0x1)
            constant DI_ULTIMATE(0x2)

            // this here was needed to make Toggles.single_player_guard work
            // since _end is not defined when it gets to that point,
            // we have to declare this branch here
            _single_player_guard_skip:
            b apply_di_modifiers._end
            nop

            scope apply_di_modifiers: {
                OS.patch_start(0xBB31C, 0x801408DC)
                j apply_di_modifiers
                nop
                _return:
                OS.patch_end()

                lui     at, 0x8019                  // original line 1
                lwc1    f0, 0xC0E0(at)              // original line 2: f0 = DI multiplier (vanilla)

                Toggles.single_player_guard(Toggles.entry_di, _single_player_guard_skip)
                li      at, Toggles.entry_di       // ~
                lw      at, 0x0004(at)             // at = di toggle value

                addiu   t7, r0, DI_JAPANESE
                beq    at, t7, di_japanese
                nop

                addiu   t7, r0, DI_ULTIMATE
                beq    at, t7, di_ultimate
                nop

                // It's set to an unknown value? Do nothing.
                b _end  // return
                nop

                di_japanese:
                lui     at, 0x3FC0      // Japanese coding part 1
                b _end  // return
                mtc1    at, f0          // Japanese coding part 2

                di_ultimate:
                // This is not accurate, it's just weaker (S)DI
                lui     at, 0x3F19      // Ultimate coding part 1
                b _end  // return
                mtc1    at, f0          // Ultimate coding part 2

                _end:
                j _return // return
                nop
            }
        }
    }
}