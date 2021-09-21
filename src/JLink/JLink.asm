scope JLink {
    // Insert Moveset files
    insert BAIR, "moveset/BAIR.bin"
    insert DAIR, "moveset/DAIR.bin"
    insert FAIR, "moveset/FAIR.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert UTILT, "moveset/UTILT.bin"
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JLINK, Action.UTilt,           -1,                         UTILT,                     -1)
    Character.edit_action_parameters(JLINK, Action.USmash,          -1,                         USMASH,                    -1)
    Character.edit_action_parameters(JLINK, Action.AttackAirB,            -1,                         BAIR,                      -1)
    Character.edit_action_parameters(JLINK, Action.AttackAirN,            -1,                         NAIR,                      -1)
    Character.edit_action_parameters(JLINK, Action.AttackAirF,            -1,                         FAIR,                      -1)
    Character.edit_action_parameters(JLINK, Action.AttackAirD,            -1,                         DAIR,                      -1)
    
    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    
    
    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JLINK, 0x2)
    dh  0x0316
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JLINK, 0x4)
    dw  Action.LINK.action_string_table
    OS.patch_end()
}
