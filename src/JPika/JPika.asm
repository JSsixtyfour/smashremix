// JPika.asm

// This file contains file inclusions, action edits, and assembly for JPika.

scope JPika {
    // Insert Moveset files
    insert NEUTRAL1,"moveset/NEUTRAL1.bin"
    insert DASHATTACK,"moveset/DASHATTACK.bin"
    FSMASH:; Moveset.CONCURRENT_STREAM(FSMASHLOOP); insert "moveset/FSMASH.bin"
    insert FSMASHLOOP, "moveset/FSMASHLOOP.bin"
    insert UTILT, "moveset/UTILT.bin"
    insert FTILT_UP, "moveset/FTILT_UP.bin"
    insert FTILT_DOWN, "moveset/FTILT_DOWN.bin"
    insert UP_SPECIAL_1, "moveset/UP_SPECIAL_1.bin"

    // Modify Action Parameters               // Action               // Animation                // Moveset Data             // Flags
    Character.edit_action_parameters(JPIKA,   Action.Jab1,          -1,                         NEUTRAL1,                  -1)
    Character.edit_action_parameters(JPIKA,   Action.DashAttack,    -1,                         DASHATTACK,                -1)
    Character.edit_action_parameters(JPIKA,   Action.FSmash,        -1,                         FSMASH,                    -1)
    Character.edit_action_parameters(JPIKA,   Action.UTilt,         -1,                         UTILT,                     -1)
    Character.edit_action_parameters(JPIKA,   Action.FTiltHigh,     -1,                         FTILT_UP,                  -1)
    Character.edit_action_parameters(JPIKA,   Action.FTiltLow,      -1,                          FTILT_DOWN,                -1)
    Character.edit_action_parameters(JPIKA,   0xE9,                 -1,                          UP_SPECIAL_1,              -1)
    Character.edit_action_parameters(JPIKA,   0xEC,                 -1,                          UP_SPECIAL_1,              -1)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JPIKA, 0x2)
    dh  0x031B
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JPIKA, 0x4)
    dw  Action.PIKACHU.action_string_table
    OS.patch_end()

    // Changes the duration of Thunder Jolt to match that of the Japanese Version
    scope thunderjolt_duration: {
        OS.patch_start(0xE405C, 0x8016961C)
        j       thunderjolt_duration
        or      v0, a0, r0                  // original line 2
        _return:
        OS.patch_end()

        addiu   t6, r0, 0x0078              // J Pika Duration

        lw      t7, 0x0008(s1)              // t0 = character id
        ori     t9, r0, Character.id.JPIKA  // t1 = id.JPIKA
        bne     t7, t9, _end                // end if character id = JPIKA
        nop

        addiu   t6, r0, 0x0064              // original line 1 (U Pika Duration)

        _end:
        j       _return                     // return
        nop
    }


    }
