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

    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.JFALCON, 0x2)
    dh {MIDI.id.FZERO_CLIMBUP}
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JFALCON, 0x4)
    dw  Action.CAPTAIN.action_string_table
    OS.patch_end()

    // Update variants with same model
    Character.table_patch_start(variants_with_same_model, Character.id.JFALCON, 0x4)
    db      Character.id.CAPTAIN
    db      Character.id.NONE
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    FALCONDIVE_AIR_ACCEL_MUL:
    float32 1.2                 // U = 1.1
    FALCONDIVE_AIR_SPEED_MAX_MUL:
    float32 0.84                // U = 0.8

    // 801603F0+38
    // @ Description
    // Modifies J Falcon's aerial drift during UpB
    scope up_special_aerial_drift_1_: {
        OS.patch_start(0xDAE68, 0x80160428)
        j       up_special_aerial_drift_1_
        lwc1    f10, 0x0050(s1)                             // original line 2
        _return:
        OS.patch_end()

        // s0 = player struct, s1 = attributes struct
        lw      a0, 0x0008(s0)                              // a0 = character id
        addiu   a0, a0, -Character.id.JFALCON               // ~
        beqzl   a0, _jfalcon                                // take branch if J Falcon
        OS.UPPER(at, FALCONDIVE_AIR_SPEED_MAX_MUL)          // load upper 2 bytes of FALCONDIVE_AIR_SPEED_MAX_MUL

        j       _return                                     // otherwise, load U max air speed multiplier (float = 0.8)
        lwc1    f16, 0xC908(at)                             // original line 1 (at is initalized as 0x8019 before this hook)

        _jfalcon:
        j       _return                                     // return
        lwc1    f16, FALCONDIVE_AIR_SPEED_MAX_MUL & 0xFFFF(at) // load lower 2 bytes of FALCONDIVE_AIR_SPEED_MAX_MUL
    }

    // 801603F0+58
    // @ Description
    // Modifies J Falcon's aerial drift during UpB
    scope up_special_aerial_drift_2_: {
        OS.patch_start(0xDAE94, 0x80160454)
        j       up_special_aerial_drift_2_
        lui     at, 0x8019                                  // original line 1
        _return:
        OS.patch_end()
        // s0 = player struct, s1 = attributes struct
        lw      a0, 0x0008(s0)                              // a0 = character id
        addiu   a0, a0, -Character.id.JFALCON               // ~
        beqzl   a0, _jfalcon                                // take branch if J Falcon
        OS.UPPER(at, FALCONDIVE_AIR_ACCEL_MUL)              // load upper 2 bytes of FALCONDIVE_AIR_ACCEL_MUL

        j       _return                                     // otherwise, load U max air speed multiplier (float = 0.8)
        lwc1    f16, 0xC910(at)                             // original line 2

        _jfalcon:
        lwc1    f6, FALCONDIVE_AIR_ACCEL_MUL & 0xFFFF(at)   // load lower 2 bytes of FALCONDIVE_AIR_ACCEL_MUL
        OS.UPPER(at, FALCONDIVE_AIR_SPEED_MAX_MUL)          // load upper 2 bytes of FALCONDIVE_AIR_SPEED_MAX_MUL
        j       _return                                     // return
        lwc1    f16, FALCONDIVE_AIR_SPEED_MAX_MUL & 0xFFFF(at) // load lower 2 bytes of FALCONDIVE_AIR_SPEED_MAX_MUL
        
    }
}
