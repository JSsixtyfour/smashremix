// JLuigi.asm

// This file contains file inclusions, action edits, and assembly for JLuigi.

scope JLuigi {
    // Insert Moveset files
    insert JAB_2,"moveset/NEUTRAL2.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROWDATA); insert "moveset/FTHROW.bin"
    insert FTHROWDATA, "moveset/FTHROWDATA.bin"
    insert USPECIALGRND, "moveset/USPECIAL.bin"
    insert USPECIALAIR, "moveset/USPECIALAIR.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JLUIGI,   Action.Jab2,            -1,                      JAB_2,                      -1)
    Character.edit_action_parameters(JLUIGI,   Action.ThrowB,          -1,                      BTHROW,                     -1)
    Character.edit_action_parameters(JLUIGI,   Action.ThrowF,          -1,                      FTHROW,                     -1)
    Character.edit_action_parameters(JLUIGI,   0xE1,                   -1,                      USPECIALGRND,               -1)
    Character.edit_action_parameters(JLUIGI,   0xE2,                   -1,                      USPECIALAIR,                -1)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JLUIGI, 0x2)
    dh  0x031C
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JLUIGI, 0x4)
    dw  Action.LUIGI.action_string_table
    OS.patch_end()
}
