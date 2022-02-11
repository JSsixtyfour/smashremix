// EPuff.asm

// This file contains file inclusions, action edits, and assembly for EPuff.

scope EPuff {
    // Insert Moveset files

    insert DAIR, "moveset/DAIR.bin"
    insert BLINK_SUBROUTINE, "moveset/BLINK_SUBROUTINE.bin"
    insert DSPECIAL, "moveset/DSPECIAL.bin"; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
    dw 0x04000014; Moveset.SUBROUTINE(BLINK_SUBROUTINE)
    dw 0x00000000

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags

    Character.edit_action_parameters(EPUFF, Action.AttackAirD,      -1,                         DAIR,                       -1)
    Character.edit_action_parameters(EPUFF, 0xEA,                   -1,                         DSPECIAL,                     -1)
    Character.edit_action_parameters(EPUFF, 0xEB,                   -1,                         DSPECIAL,                     -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.EPUFF, 0x2)
    dh  0x0264
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.EPUFF, 0x4)
    dw  Action.JIGGLY.action_string_table
    OS.patch_end()
}
