// EPika.asm

// This file contains file inclusions, action edits, and assembly for EPika.

scope EPika {
    // Insert Moveset files
    insert DAIR,"moveset/DAIR.bin"
    FSMASH:; Moveset.CONCURRENT_STREAM(FSMASHLOOP); insert "moveset/FSMASH.bin"
    insert FSMASHLOOP, "moveset/FSMASHLOOP.bin"
    insert UTILT, "moveset/UTILT.bin"
	insert DOWN_SPECIAL_CONNECT, "moveset/DOWN_SPECIAL_CONNECT.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(EPIKA,   Action.AttackAirD,       -1,                      DAIR,                      -1)
    Character.edit_action_parameters(EPIKA,   Action.FSmash,        -1,                         FSMASH,                    -1)
    Character.edit_action_parameters(EPIKA,   Action.UTilt,         -1,                         UTILT,                     -1)
	Character.edit_action_parameters(EPIKA,   0xE2,         		-1,                         DOWN_SPECIAL_CONNECT,      -1)
	Character.edit_action_parameters(EPIKA,   0xE6,         		-1,                         DOWN_SPECIAL_CONNECT,      -1)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.EPIKA, 0x2)
    dh  0x0263
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.EPIKA, 0x4)
    dw  Action.PIKACHU.action_string_table
    OS.patch_end()
}
