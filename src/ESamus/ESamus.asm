// ESamus.asm

// This file contains file inclusions, action edits, and assembly for ESamus.

scope ESamus {
    // Insert Moveset files
    insert BAIR, "moveset/BAIR.bin"
    insert DAIR, "moveset/DAIR.bin"
    
    
    // Modify Action Parameters             // Action                       // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(ESAMUS, Action.AttackAirB,             -1,                         BAIR,                       -1)
    Character.edit_action_parameters(ESAMUS, Action.AttackAirD,             -1,                         DAIR,                       -1)
    
     // Modify Actions            // Action             // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    // Modify Menu Action Parameters                // Action          // Animation                // Moveset Data             // Flags
      
    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.ESAMUS, 0x2)
    dh  0x0265
    OS.patch_end()
    
    
}
