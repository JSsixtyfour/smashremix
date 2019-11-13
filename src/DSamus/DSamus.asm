// DSamus.asm

// This file contains file inclusions, action edits, and assembly for Dark Samus.

scope DSamus {
    // Insert Moveset files
    insert JUMP2, "moveset/JUMP2.bin"
    insert FAIR, "moveset/FAIR.bin"
    insert NAIR, "moveset/NAIR.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert DSMASH, "moveset/DSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert UP_SPECIAL_AIR, "moveset/UP_SPECIAL_AIR.bin"
    insert UP_SPECIAL_GROUND, "moveset/UP_SPECIAL_GROUND.bin"
    // insert ROLLF, "moveset/ROLLF.bin"
    // insert ROLLB, "moveset/ROLLB.bin"
    
    
    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(DSAMUS, Action.RollF,          File.DSAMUS_ROLLF,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.RollB,          File.DSAMUS_ROLLB,          -1,                         -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialF,    0x3C3,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.JumpAerialB,    0x3C3,                      JUMP2,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     -1,                         NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirN,     -1,                         NAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirF,     -1,                         FAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.AttackAirU,     -1,                         UAIR,                       -1)
    Character.edit_action_parameters(DSAMUS, Action.UTilt,          -1,                         UTILT,                      -1)
    Character.edit_action_parameters(DSAMUS, Action.DTilt,          0x435,                      DTILT,                      0x00180000)
    Character.edit_action_parameters(DSAMUS, Action.USmash,         -1,                         USMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, Action.DSmash,         0x430,                      DSMASH,                     -1)
    Character.edit_action_parameters(DSAMUS, 0xE3,                  -1,                         UP_SPECIAL_GROUND,          -1)
    Character.edit_action_parameters(DSAMUS, 0xE4,                  -1,                         UP_SPECIAL_AIR,             -1)
    
    // Modify Menu Action Parameters        // Action          // Animation                // Moveset Data             // Flags
    

    // Set menu zoom size.
    Character.table_patch_start(menu_zoom, Character.id.DSAMUS, 0x4)
    float32 1.05
    OS.patch_end()
    
    // Set crowd chant FGM.
        
    
    // Set default costumes
    Character.set_default_costumes(Character.id.DSAMUS, 0, 1, 2, 4, 1, 2, 0)
    
    
}