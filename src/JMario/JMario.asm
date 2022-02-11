// JMario.asm

// This file contains file inclusions, action edits, and assembly for JMario.

scope JMario {
    // Insert Moveset files
    insert JAB_2,"moveset/NEUTRAL2.bin"
    BTHROW:; Moveset.THROW_DATA(BTHROWDATA); insert "moveset/BTHROW.bin"
    insert BTHROWDATA, "moveset/BTHROWDATA.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JMARIO,   Action.Jab2,            -1,                      JAB_2,                      -1)
    Character.edit_action_parameters(JMARIO,   Action.ThrowB,          -1,                      BTHROW,                     -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JMARIO, 0x2)
    dh  0x0314
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JMARIO, 0x4)
    dw  Action.MARIO.action_string_table
    OS.patch_end()
}
