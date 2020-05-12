// EPika.asm

// This file contains file inclusions, action edits, and assembly for EPika.

scope EPika {
    // Insert Moveset files
    insert DAIR,"moveset/DAIR.bin"
    FSMASH:; Moveset.CONCURRENT_STREAM(FSMASHLOOP); insert "moveset/FSMASH.bin"
    insert FSMASHLOOP, "moveset/FSMASHLOOP.bin"
    insert UTILT, "moveset/UTILT.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(EPIKA,   Action.AttackAirD,       -1,                      DAIR,                      -1)
    Character.edit_action_parameters(EPIKA,   Action.FSmash,        -1,                         FSMASH,                    -1)
    Character.edit_action_parameters(EPIKA,   Action.UTilt,         -1,                         UTILT,                     -1)

    
    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.EPIKA, 0x2)
    dh  0x0263
    OS.patch_end()
    
    

    }