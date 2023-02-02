// Transitions.asm
if !{defined __TRANSITIONS__} {
define __TRANSITIONS__()
print "included Transitions.asm\n"

// @ Description
// Restores unused VS to Results screen transitions in the ROM.

include "OS.asm"
include "Toggles.asm"

scope Transitions {
    // @ Description
    // Original transitions table:
    constant TRANSITONS_TABLE(0x800D5D60)
    constant TRANSITONS_TABLE_ORIGIN(0x51740)

    // @ Description
    // Number of transitions, original + restored
    constant NUM_TRANSITIONS(11 + 2)

    pushvar origin, base

    // Shrink the original table to use halfwords so we can fit the restored transitions in the same space.
    // Then we squeeze in some pointers and strings for the debug menu.
    // We use 100% of the original space, so if we ever add more, we'll have to move stuff.
    origin TRANSITONS_TABLE_ORIGIN
    base TRANSITONS_TABLE
    // original
    dh 0x0028, 0xB3F8, 0xB710, 0x0000
    dh 0x0029, 0x3E80, 0x4038, 0x0000
    dh 0x002A, 0x0F98, 0x101C, 0x0000
    dh 0x002B, 0x1F00, 0x1FB0, 0x0000
    dh 0x002C, 0x2450, 0x24D4, 0x0000
    dh 0x002D, 0x74A8, 0x7660, 0x0000
    dh 0x002E, 0x3EA0, 0x3F50, 0x0000
    dh 0x0033, 0x3F90, 0x4148, 0x0000
    dh 0x0030, 0x4E18, 0x536C, 0x0000
    dh 0x0031, 0x0F98, 0x101C, 0x0000
    dh 0x0032, 0x7AE0, 0x7C98, 0x0000
    // restored
    dh 0x0027, 0x3BC0, 0x3D78, 0x0000 // file 27's shapes falling
    dh 0x002F, 0x0F98, 0x101C, 0x0000 // file 2F's vertical flip

    debug_menu_label_array:
    OS.copy_segment(0x11B5DC, 0x2C) // original array
    dw string_shapes
    dw string_flip

    string_shapes:; db "Falling Shapes", 0
    string_flip:; db "Flip", 0

    pullvar base, origin

    // @ Description
    // Fix end of table during max size loop
    OS.patch_start(0x4FE04, 0x800D4424)
    addiu   s2, s2, debug_menu_label_array & 0x0000FFFF
    OS.patch_end()

    // @ Description
    // Fix file ID read during max size loop to use dh
    OS.patch_start(0x4FE10, 0x800D4430)
    lhu    a0, 0x0000(s0)
    OS.patch_end()

    // @ Description
    // Fix table size increment during max size loop
    OS.patch_start(0x4FE1C, 0x800D443C)
    addiu   s0, s0, 0x0008
    OS.patch_end()

    // @ Description
    // Fix index to offset calculation during transition initialization
    OS.patch_start(0x4FD00, 0x800D4320)
    sll     t6, a0, 0x0003
    OS.patch_end()

    // @ Description
    // Fix file ID read during transition initialization to use dh
    OS.patch_start(0x4FD24, 0x800D4344)
    lhu    a0, 0x0000(s0)
    OS.patch_end()

    // @ Description
    // Fix unknown value read during transition initialization to use dh
    OS.patch_start(0x4FD3C, 0x800D435C)
    lhu    t8, 0x0006(s0)
    OS.patch_end()

    // @ Description
    // Fix hierarchy offset read during transition initialization to use dh
    OS.patch_start(0x4FD6C, 0x800D438C)
    lhu    t0, 0x0002(s0)
    OS.patch_end()

    // @ Description
    // Fix animation offset read during transition initialization to use dh
    OS.patch_start(0x4FD8C, 0x800D43AC)
    lhu    v0, 0x0004(s0)
    OS.patch_end()

    // @ Description
    // Increase number of transitions used for random number routine
    OS.patch_start(0x157ECC, 0x80138D2C)
    addiu   a0, r0, NUM_TRANSITIONS
    OS.patch_end()

    // @ Description
    // Move debug menu label array pointer
    OS.patch_start(0x11B728, 0x80132EE8)
    dw debug_menu_label_array
    OS.patch_end()

    // @ Description
    // Increase debug menu label array max index from 10 to 12
    OS.patch_start(0x11B734, 0x80132EF4)
    dw 0x41400000
    OS.patch_end()
}

} // __TRANSITIONS__
