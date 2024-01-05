// Handicap.asm
if !{defined __HANDICAP__} {
define __HANDICAP__()
print "included Handicap.asm\n"

include "Global.asm"
include "Toggles.asm"
include "OS.asm"

scope Handicap {
    // @ Description
    // Holds the handicap override values for p1 - p4
    override_table:
    dw  0   // P1
    dw  0   // P2
    dw  0   // P3
    dw  0   // P4

    // @ Description
    // This allows us to override CPU handicap values.
    scope use_handicap_: {
        OS.patch_start(0x5396C, 0x800D816C)
        jal     use_handicap_
        lbu     t2, 0x001A(s6)              // original line 1
        OS.patch_end()

        lbu     t5, 0x0023(v0)              // t5 = player type (0 = HMN, 1 = CPU, 2 = N/A)

        // Use override value if CPU
        addiu   t5, t5, -0x0001             // t5 = 0 if CPU
        bnez    t5, _end                    // if not CPU, skip to end
        lbu     t5, 0x000D(v0)              // t5 = port

        sll     t5, t5, 0x0002              // t5 = offset in override table
        li      t8, override_table
        addu    t8, t8, t5                  // t8 = address of override value
        lw      t5, 0x0000(t8)              // t8 = override value
        bnezl   t5, _end                    // if override value...
        or      t9, t5, r0                  // ...then use it

        _end:
        jr      ra                          // return
        sb      t9, 0x0012(v0)              // original line 2 - set handicap
    }

}

} // __HANDICAP__
