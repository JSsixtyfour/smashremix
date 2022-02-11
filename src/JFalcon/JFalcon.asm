// J Falcon.asm

// This file contains file inclusions, action edits, and assembly for J Captain Falcon.

scope JFalcon {
    // Insert Moveset files
    insert NEUTRAL2, "moveset/NEUTRAL2.bin"
    insert NEUTRAL3, "moveset/NEUTRAL3.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JFALCON, Action.Jab2,           -1,                         NEUTRAL2,                   -1)
    Character.edit_action_parameters(JFALCON, 0xDC,                  -1,                         NEUTRAL3,                   -1)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags


    // Set crowd chant FGM.
     Character.table_patch_start(crowd_chant_fgm, Character.id.JFALCON, 0x2)
     dh  0x031E
     OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JFALCON, 0x4)
    dw  Action.CAPTAIN.action_string_table
    OS.patch_end()
}
