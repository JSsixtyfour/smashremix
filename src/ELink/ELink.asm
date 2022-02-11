// YoungLink.asm

// This file contains file inclusions, action edits, and assembly for ELink.

scope ELink {
    // Insert Moveset files
    insert FSMASH,"moveset/FORWARD_SMASH.bin"


    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(ELINK, Action.FSmash,          -1,                         FSMASH,                     -1)

    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags


    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.ELINK, 0x2)
    dh  0x025F
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.ELINK, 0x4)
    dw  Action.LINK.action_string_table
    OS.patch_end()
}
