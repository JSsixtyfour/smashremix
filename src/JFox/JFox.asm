// JFox.asm

// This file contains file inclusions, action edits, and assembly for JFox.

scope JFox {
    // Insert Moveset files
    insert USP_GROUND_MOVE,"moveset/UP_SPECIAL_GROUND_MOVE.bin" // no end command, transitions into USP_LOOP
    insert USP_LOOP,"moveset/UP_SPECIAL_LOOP.bin"; Moveset.GO_TO(USP_LOOP)
    insert USP_AIR_MOVE,"moveset/UP_SPECIAL_AIR_MOVE.bin"; Moveset.GO_TO(USP_LOOP)
    insert NEUTRAL_INF,"moveset/NEUTRAL_INF.bin"; Moveset.GO_TO(NEUTRAL_INF)
    insert DSMASH,"moveset/DSMASH.bin"
    insert DTILT,"moveset/DTILT.bin"
    UPSPECIALMID:; Moveset.CONCURRENT_STREAM(UPSPECIALMIDCONCURRENT); insert "moveset/UPSPECIALMID.bin"
    insert UPSPECIALMIDCONCURRENT,"moveset/UPSPECIALMIDCONCURRENT.bin"
    insert VICTORY_POSE_1, "moveset/VICTORY_POSE_1.bin"
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JFOX, 0xE7,                   -1,                         USP_GROUND_MOVE,            -1)
    Character.edit_action_parameters(JFOX, 0xE8,                   -1,                         USP_AIR_MOVE,               -1)
    Character.edit_action_parameters(JFOX, 0xDD,                   -1,                         NEUTRAL_INF,                -1)
    Character.edit_action_parameters(JFOX, Action.DSmash,          -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(JFOX, Action.DTilt,           -1,                         DTILT,                      -1)
    Character.edit_action_parameters(JFOX, 0xE5,                   -1,                         UPSPECIALMID,               -1)
    Character.edit_action_parameters(JFOX, 0xE6,                   -1,                         UPSPECIALMID,               -1)

    // Modify Actions            // Action          // Staling ID   // Main ASM                 // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM

    
    // Modify Menu Action Parameters             // Action          // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(JFOX, 0x2,               -1,                         VICTORY_POSE_1,             -1)
    
    // Set crowd chant FGM.
     Character.table_patch_start(crowd_chant_fgm, Character.id.JFOX, 0x2)
     dh  0x031A
     OS.patch_end()
    

}