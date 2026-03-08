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

    // Set Remix 1P ending music
    Character.table_patch_start(remix_1p_end_bgm, Character.id.JYOSHI, 0x2)
    dh {MIDI.id.YOSHI_TALE}
    OS.patch_end()

    // Update variants with same model
    Character.table_patch_start(variants_with_same_model, Character.id.JYOSHI, 0x4)
    db      Character.id.YOSHI
    db      Character.id.NONE
    db      Character.id.NONE
    db      Character.id.NONE
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

    // 8014CF0C
    // 8014AA3C in J
    // Modifies J Yoshi's egg max timer to match that of the Japanese version
    scope joshi_egg_timer: {
        OS.patch_start(0xC794C, 0x8014CF0C)
        j       joshi_egg_timer
        lw      v0, 0x0084(a0)              // original line 1
        _return:
        OS.patch_end()

        // v0 = player struct
        // a0 = player object
        addiu   sp, sp,-0x0010                  // allocate stack space
        sw      t7, 0x0004(sp)                  // store t7, t8
        sw      t8, 0x0008(sp)                  // ~
        lw      t8, 0x0844(v0)                  // load capture_fp
        
        beqzl   t8, _end                        // safety branch (Cruel Z Punish 'Egg' has no captured player)
        addiu   t6, r0, 0x00FA                  // original line 2, U max wait = 250
        
        lw      t8, 0x0084(t8)                  // ~
        lw      t6, 0x0008(t8)                  // t6 = character id of the capturing player
        lli     t7, Character.id.KIRBY          // t7 = id.KIRBY
        
        beql    t6, t7, _joshi_check            // if Kirby, get held power character_id
        lw      t6, 0x0ADC(t8)                  // t6 = character id of copied power
        lli     t7, Character.id.JKIRBY         // t7 = id.JKIRBY
        
        beql    t6, t7, _joshi_check            // if J Kirby, get held power character_id
        lw      t6, 0x0ADC(t8)                  // t6 = character id of copied power

        _joshi_check:
        addiu   t6, t6, -Character.id.JYOSHI    // ~
        
        beqzl   t6, _end                        // If J Yoshi, then load J max wait time
        addiu   t6, r0, 0x00D2                  // J max wait = 210

        addiu   t6, r0, 0x00FA                  // original line 2, U max wait = 250

        _end:
        lw      t7, 0x0004(sp)                  // restore t7, t8
        lw      t8, 0x0008(sp)                  // ~
        j       _return                         // return
        addiu   sp, sp, 0x0010                  // deallocate stack space
    }

    // 8014CF20+80, otherwise known as 0x8014CFA0
    // 8014AAD0 in J
    // Modifies the amount of base inputs required to escape J Yoshi's neutral special
    scope joshi_mash: {
        OS.patch_start(0xC79E0, 0x8014CFA0)
        jal     joshi_mash
        addiu   sp, sp,-0x0010                  // allocate stack space
        OS.patch_end()

        sw      t0, 0x0004(sp)                  // store t0, t1
        sw      t1, 0x0008(sp)                  // ~
        lw      t1, 0x0844(a0)                  // load capture_fp
        
        beqzl   t1, _end                        // safety branch (Cruel Z Punish 'Egg' has no captured player)
        addiu   a1, r0, 0x02EE                  // original line 2, U minimum base inputs = 750
        
        lw      t1, 0x0084(t1)                  // ~
        lw      a1, 0x0008(t1)                  // a1 = character id of capturing player
        lli     t0, Character.id.KIRBY          // t0 = id.KIRBY
        
        beql    a1, t0, _joshi_check            // if Kirby, get held power character_id
        lw      a1, 0x0ADC(t1)                  // a1 = character id of copied power
        lli     t0, Character.id.JKIRBY         // t0 = id.JKIRBY
        
        beql    a1, t0, _joshi_check            // if J Kirby, get held power character_id
        lw      a1, 0x0ADC(t1)                  // a1 = character id of copied power

        _joshi_check:
        addiu   a1, a1, -Character.id.JYOSHI    // ~
        beqzl   a1, _end                        // If J Yoshi, then load J max wait time
        addiu   a1, r0, 0x0276                  // J minimum base inputs = 630

        addiu   a1, r0, 0x02EE                  // original line 2, U minimum base inputs = 750

        _end:
        lw      t0, 0x0004(sp)                  // restore t0, t1
        lw      t1, 0x0008(sp)                  // ~
        j       0x8014E3EC                      // ftCommonCaptureTrappedInitBreakoutVars (modified original line 1)
        addiu   sp, sp, 0x0010                  // deallocate stack space
    }
}