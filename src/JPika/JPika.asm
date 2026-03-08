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
    
    
    // Modify Actions            // Action                   // Staling ID    // Main ASM                     // Interrupt/Other ASM          // Movement/Physics ASM         // Collision ASM
    Character.edit_action(JPIKA, 0xE9,                      0x1E,               0x80152A38,                     0x00000000,                     0x80152B24,                     JPikaUSP.JPika_SpecialHiProcMap_)


    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JPIKA, 0x2)
    dh  0x031B
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JPIKA, 0x4)
    dw  Action.PIKACHU.action_string_table
    OS.patch_end()

    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.JPIKA, 0x2)
    dh {MIDI.id.POKEFLOATS}
    OS.patch_end()

    // Update variants with same model
    Character.table_patch_start(variants_with_same_model, Character.id.JPIKA, 0x4)
    db      Character.id.PIKACHU
    db      Character.id.EPIKA
    db      Character.id.NONE
    db      Character.id.NONE
    OS.patch_end()

    // Changes the duration of Thunder Jolt to match that of the Japanese version
    scope thunderjolt_duration_: {
        OS.patch_start(0xE405C, 0x8016961C)
        j       thunderjolt_duration_
        or      v0, a0, r0                  // original line 2
        _return:
        OS.patch_end()

        // s1 = player struct, v1 = projectile struct
        addiu   t6, r0, 0x0078              // J Pika Duration

        lw      t7, 0x0008(s1)              // t7 = character id
        lli     t9, Character.id.KIRBY      // t9 = id.KIRBY
        beql    t7, t9, _jpika              // if Kirby, get held power character_id
        lw      t7, 0x0ADC(s1)              // t7 = character id of copied power
        lli     t9, Character.id.JKIRBY     // t9 = id.JKIRBY
        beql    t7, t9, _jpika              // if J Kirby, get held power character_id
        lw      t7, 0x0ADC(s1)              // t7 = character id of copied power

        // sw      t7, 0x01B4(v1)              // save character ID to unused space in projectile struct so we can check the character id during thunderjolt_tvel_
        _jpika:
        ori     t9, r0, Character.id.JPIKA  // t9 = id.JPIKA
        beq     t7, t9, _end                // end if character id = JPIKA
        nop

        addiu   t6, r0, 0x0064              // original line 1 (U Pika Duration)

        _end:
        j       _return                     // return
        nop
    }

    // // Commented out because Thunder Jolt will never have it's Y speed clamped to the terminal velocity since its gravity is 0.0F
    // // 80169390+40
    // // Changes the terminal velocity of Thunder Jolt to match that of the Japanese version
    // // scope thunderjolt_tvel_: {
        // OS.patch_start(0xE3E10, 0x801693D0)
        // jal     thunderjolt_tvel_
        // lw      a2, 0x01B4(a0)                  // a0 = character id
        // _return:
        // OS.patch_end()

        // // a0 = projectile struct
        // addiu   a2, a2, -Character.id.JPIKA     // ~
        // beqzl   a2, _end                        // take branch if J Pika
        // lui     a2, 0x4234                      // J Pika terminal velocity (float = 45.0)

        // lui     a2, 0x4248                  // original line 2 (U Pika terminal velocity -  float = 50.0)

        // _end:
        // j       0x80168088                  // modified original line 1
        // nop
    // }

}
