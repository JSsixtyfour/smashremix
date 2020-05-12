// JKirby.asm

// This file contains file inclusions, action edits, and assembly for JKirby.

scope JKirby {
    // Insert Moveset files

    insert DSMASH, "moveset/DSMASH.bin"
    insert USMASH, "moveset/USMASH.bin"
    insert UAIR, "moveset/UAIR.bin"
    insert NEUTRAL2, "moveset/NEUTRAL2.bin"
    insert NEUTRALINF_SUB, "moveset/NEUTRALINF_SUB.bin"
    insert NEUTRALINF, "moveset/NEUTRALINF.bin"
        dw  0x5c000001; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x08000006
        dw  0x5c000002; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x0800000b
        dw  0x5c000003; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x08000010
        dw  0x5c000004; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x08000015
        dw  0x5c000005; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001
        dw  0x94000000; Moveset.SUBROUTINE(NEUTRALINF_SUB)
        dw  0x58000001; Moveset.GO_TO(NEUTRALINF) 
    insert FTHROW_DATA, "moveset/FTHROW_DATA.bin"
    FTHROW:; Moveset.THROW_DATA(FTHROW_DATA); insert "moveset/FTHROW.bin"
    insert NEUTRAL_SPECIAL_START_THROW_DATA, "moveset/NEUTRAL_SPECIAL_START_THROW_DATA.bin"
    NEUTRAL_SPECIAL_START:; Moveset.THROW_DATA(NEUTRAL_SPECIAL_START_THROW_DATA); insert "moveset/NEUTRAL_SPECIAL_START.bin"
    insert FTHROW_IMPACT, "moveset/FTHROW_IMPACT.bin"
    insert DOWN_SPECIAL_FALL, "moveset/DOWN_SPECIAL_FALL.bin"
    insert DOWN_SPECIAL_LANDING, "moveset/DOWN_SPECIAL_LANDING.bin"
    insert DOWN_SPECIAL_FALL_OFF, "moveset/DOWN_SPECIAL_FALL_OFF.bin"
    
        

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JKIRBY, Action.Jab2,            -1,                         NEUTRAL2,                     -1)
    Character.edit_action_parameters(JKIRBY, Action.DSmash,          -1,                         DSMASH,                     -1)
    Character.edit_action_parameters(JKIRBY, Action.USmash,          -1,                         USMASH,                     -1)
    Character.edit_action_parameters(JKIRBY, Action.AttackAirU,      -1,                         UAIR,                       -1)
    Character.edit_action_parameters(JKIRBY, 0xDD,                   -1,                         NEUTRALINF,                 -1)
    Character.edit_action_parameters(JKIRBY, 0xE4,                   -1,                         FTHROW,                     -1)
    Character.edit_action_parameters(JKIRBY, 0xE6,                   -1,                         FTHROW_IMPACT,              -1)
    Character.edit_action_parameters(JKIRBY, 0x10E,                  -1,                         NEUTRAL_SPECIAL_START,       -1)
    Character.edit_action_parameters(JKIRBY, 0x117,                  -1,                         NEUTRAL_SPECIAL_START,       -1)
    Character.edit_action_parameters(JKIRBY, 0x109,                  -1,                         DOWN_SPECIAL_FALL,          -1)
    Character.edit_action_parameters(JKIRBY, 0x10A,                  -1,                         DOWN_SPECIAL_LANDING,       -1)
    Character.edit_action_parameters(JKIRBY, 0x10B,                  -1,                         DOWN_SPECIAL_FALL_OFF,      -1)
    
    // Set crowd chant FGM.
    // Character.table_patch_start(crowd_chant_fgm, Character.id.JKirby, 0x2)
    // dh  0x0315
    // OS.patch_end()
    
}