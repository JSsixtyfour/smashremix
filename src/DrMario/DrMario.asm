// DrMario.asm

// This file contains file inclusions, action edits, and assembly for Dr. Mario.

scope DrMario {
    // Insert Moveset files
    insert TAUNT,"moveset/TAUNT.bin"
    insert JAB_1,"moveset/JAB_1.bin"
    insert JAB_2,"moveset/JAB_2.bin"
    insert JAB_3,"moveset/JAB_3.bin"
    insert DASH_ATTACK,"moveset/DASH_ATTACK.bin"
    insert FTILT_HI,"moveset/FORWARD_TILT_HIGH.bin"
    insert FTILT,"moveset/FORWARD_TILT.bin"
    insert FTILT_LO,"moveset/FORWARD_TILT_LOW.bin"
    insert UTILT,"moveset/UP_TILT.bin"
    insert DTILT,"moveset/DOWN_TILT.bin"
    insert FSMASH_HI,"moveset/FORWARD_SMASH_HIGH.bin"
    insert FSMASH_M_HI,"moveset/FORWARD_SMASH_MID_HIGH.bin"
    insert FSMASH,"moveset/FORWARD_SMASH.bin"
    insert FSMASH_M_LO,"moveset/FORWARD_SMASH_MID_LOW.bin"
    insert FSMASH_LO,"moveset/FORWARD_SMASH_MID_LOW.bin"
    insert USMASH,"moveset/UP_SMASH.bin"
    insert DSMASH,"moveset/DOWN_SMASH.bin"
    insert NAIR,"moveset/NEUTRAL_AERIAL.bin"
    insert FAIR,"moveset/FORWARD_AERIAL.bin"
    insert BAIR,"moveset/BACK_AERIAL.bin"
    insert UAIR,"moveset/UP_AERIAL.bin"
    insert DAIR,"moveset/DOWN_AERIAL.bin"
    insert NSP_GROUND, "moveset/NEUTRAL_SPECIAL_AIR.bin"
    insert NSP_AIR, "moveset/NEUTRAL_SPECIAL_GROUND.bin"
    insert USP, "moveset/UP_SPECIAL.bin"
    insert DSP_GROUND, "moveset/DOWN_SPECIAL_GROUND.bin"
    insert DSP_AIR, "moveset/DOWN_SPECIAL_AIR.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(DRM,   Action.Taunt,           File.DRM_TAUNT,             TAUNT,                      -1)
    Character.edit_action_parameters(DRM,   Action.Jab1,            -1,                         JAB_1,                      -1)
    Character.edit_action_parameters(DRM,   Action.Jab2,            -1,                         JAB_2,                      -1)
    Character.edit_action_parameters(DRM,   Action.DashAttack,      -1,                         DASH_ATTACK,                -1)
    Character.edit_action_parameters(DRM,   Action.FTiltHigh,       -1,                         FTILT_HI,                   -1)
    Character.edit_action_parameters(DRM,   Action.FTilt,           -1,                         FTILT,                      -1)
    Character.edit_action_parameters(DRM,   Action.FTiltLow,        -1,                         FTILT_LO,                   -1)
    Character.edit_action_parameters(DRM,   Action.UTilt,           -1,                         UTILT,                      -1)
    Character.edit_action_parameters(DRM,   Action.DTilt,           -1,                         DTILT,                      -1)
    Character.edit_action_parameters(DRM,   Action.FSmashHigh,      -1,                         FSMASH_HI,                  -1)
    Character.edit_action_parameters(DRM,   Action.FSmashMidHigh,   -1,                         FSMASH_M_HI,                -1)   
    Character.edit_action_parameters(DRM,   Action.FSmash,          -1,                         FSMASH,                     -1)   
    Character.edit_action_parameters(DRM,   Action.FSmashMidLow,    -1,                         FSMASH_M_LO,                -1)   
    Character.edit_action_parameters(DRM,   Action.FSmashLow,       -1,                         FSMASH_LO,                  -1)   
    Character.edit_action_parameters(DRM,   Action.USmash,          -1,                         USMASH,                     -1)
    Character.edit_action_parameters(DRM,   Action.DSmash,          -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(DRM,   Action.AttackAirN,      -1,                         NAIR,                       -1)
    Character.edit_action_parameters(DRM,   Action.AttackAirF,      File.DRM_FAIR,              FAIR,                       -1)
    Character.edit_action_parameters(DRM,   Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(DRM,   Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(DRM,   Action.AttackAirD,      File.DRM_DAIR,              DAIR,                       0) 
    Character.edit_action_parameters(DRM,   0xDC,                   -1,                         JAB_3,                      -1)
    Character.edit_action_parameters(DRM,   0xDF,                   -1,                         NSP_GROUND,                 -1)
    Character.edit_action_parameters(DRM,   0xE0,                   -1,                         NSP_AIR,                    -1)
    Character.edit_action_parameters(DRM,   0xE1,                   -1,                         USP,                        -1)
    Character.edit_action_parameters(DRM,   0xE2,                   -1,                         USP,                        -1)
    Character.edit_action_parameters(DRM,   0xE3,                   -1,                         DSP_GROUND,                 -1)
    Character.edit_action_parameters(DRM,   0xE4,                   -1,                         DSP_AIR,                    -1)    
    
    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.DRM, 0x2)
    dh  0x02EB
    OS.patch_end()
    
    // Set default costumes
    Character.set_default_costumes(Character.id.DRM, 0, 1, 2, 4, 1, 3, 4)
}