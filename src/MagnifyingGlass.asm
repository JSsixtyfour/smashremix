// MagnifyingGlass.asm
if !{defined __MAGNIFYING_GLASS__} {
define __MAGNIFYING_GLASS__()
print "included MagnifyingGlass.asm\n"

// @ Description
// Allows us to scale characters in the magnifying glass.

include "OS.asm"

scope MagnifyingGlass {
    OS.align(8)
    custom_matrix_array:
    fill 0x40 // player 1
    fill 0x40 // player 2
    fill 0x40 // player 3
    fill 0x40 // player 4

    // @ Description
    // Applies a custom zoom to the player model in the magnifying glass
    scope apply_custom_zoom_: {
        OS.patch_start(0x8C680, 0x80110E80)
        jal     apply_custom_zoom_
        lbu     t6, 0x0001(t2)              // original line 2
        OS.patch_end()

        // a1 = player struct
        lw      t7, 0x0008(a1)              // t7 = char_id
        li      a3, Character.magnifying_glass_zoom.table
        sll     t7, t7, 0x0001              // t7 = char_id * 2 = offset to scale override
        addu    a3, a3, t7                  // a3 = address of scale override
        lhu     a3, 0x0000(a3)              // a3 = scale override

        beqz    a3, _end                    // if not set, skip
        lbu     t7, 0x000D(a1)              // t7 = port
        sll     t7, t7, 0x0006              // t7 = port * 0x40 = offset to custom matrix

        li      a1, custom_matrix_array
        addu    a1, a1, t7                  // a1 = custom matrix

        // copy real matrix
        addiu   a2, t9, 0x0040              // a2 = end address of real matrix
        _loop:
        lw      t7, 0x0000(t9)              // t7 = matrix values
        sw      t7, 0x0000(a1)              // copy to custom matrix
        addiu   t9, t9, 0x0004              // increment address
        bne     t9, a2, _loop               // loop until at the final address
        addiu   a1, a1, 0x0004              // increment address

        // replace scale
        addiu   t9, a1, -0x0040             // t9 = custom matrix
        sh      a3, 0x0020(t9)              // set x scale
        sh      a3, 0x002A(t9)              // set y scale

        _end:
        jr      ra
        sw      t9, 0x0004(v0)              // original line 1
    }
}

} // __MAGNIFYING_GLASS__
