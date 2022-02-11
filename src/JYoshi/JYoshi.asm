// JYoshi.asm

// This file contains file inclusions, action edits, and assembly for JYoshi.

scope JYoshi {
    // Insert Moveset files

    insert DSMASH, "moveset/DSMASH.bin"
    insert DTILT, "moveset/DTILT.bin"
    insert UTILT, "moveset/UTILT.bin"

    // Modify Action Parameters                 // Action               // Animation                // Moveset Data             // Flags

    Character.edit_action_parameters(JYOSHI,    Action.UTilt,           -1,                         UTILT,                       -1)
    Character.edit_action_parameters(JYOSHI,    Action.DTilt,           -1,                         DTILT,                       -1)
    Character.edit_action_parameters(JYOSHI,    Action.DSmash,          -1,                         DSMASH,                      -1)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JYOSHI, 0x2)
    dh  0x0318
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JYOSHI, 0x4)
    dw  Action.YOSHI.action_string_table
    OS.patch_end()

    // This alters the amount of Yoshi's armor during double jump. It's a simple floating point number written
    // to a specific location. In Japan it was 42DC0000(110) and internationally it was 430C0000(140)
    scope joshi_armor: {
        OS.patch_start(0xBA840, 0x8013FE00)
        j       joshi_armor
        nop
        _return:
        OS.patch_end()

        addiu   at, r0, Character.id.JYOSHI    // j yoshi ID
        bne     v0, at, _end
        nop

        lui     at, 0x42DC                 // 110 in floating point, Yoshi's armor amount
        mtc1    at, f4                     // move to fp register used to save

        _end:
        j       0x8013FE34                  // original line 1 modified
        swc1    f4, 0x07E8(s0)              // original line 2
        j       _return
        nop
    }

   }
