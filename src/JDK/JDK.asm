// JDK.asm

// This file contains file inclusions, action edits, and assembly for JDK.

scope JDK {
    // Insert Moveset files

    insert BAIR, "moveset/BAIR.bin"
    insert DAIR, "moveset/DAIR.bin"

    // Modify Action Parameters             // Action               // Animation                // Moveset Data             // Flags

    Character.edit_action_parameters(JDK, Action.AttackAirB,      -1,                         BAIR,                       -1)
    Character.edit_action_parameters(JDK, Action.AttackAirD,      -1,                         DAIR,                       -1)

    // Set crowd chant FGM.
    Character.table_patch_start(crowd_chant_fgm, Character.id.JDK, 0x2)
    dh  0x0315
    OS.patch_end()

    // Set action strings
    Character.table_patch_start(action_string, Character.id.JDK, 0x4)
    dw  Action.DK.action_string_table
    OS.patch_end()

    // coding for JDK's unique Spinning Kong Velocity Startup
    // the constant velocity multiplier is actually identical in all versions
    // the difference is a slight coding change at the very beginning of the move
    // essentially the J version has a startup number of 0x41900000(18.0) and the U version has 0x41A26666(20.2999992371)
    scope spinning_kong_startup_: {
        OS.patch_start(0xD6404, 0x8015B9C4)
        j       spinning_kong_startup_
        nop
        _return:
        OS.patch_end()

        lw      v0, 0x0084(a0)              // original line 1
        lwc1    f4, 0xC878(at)              // original line 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lw      t1, 0x0008(a1)              // load player ID
        addiu   t2, r0, Character.id.JDK        // load JDK ID
        beq     t1, t2, _jdkspin                // jump to JDK spin if JDK
        nop
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop


        _jdkspin:
        lui     t2, 0x4190
        mtc1    t2, f4
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    // coding for JDK's unique cargo hold, which requires a higher base amount of inputs to escape
    // J version has a number of 0x41A0 and the U version has 0x4160
    // also used by Marina
    scope jdk_cargo_: {
        OS.patch_start(0xC8FD4, 0x8014E594)
        j       jdk_cargo_
        nop
        _return:
        OS.patch_end()

        lui     at, 0x4160                  // original line 1
        mtc1    at, f16                     // original line 2
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t1, 0x0004(sp)              // store t2, t1
        sw      t2, 0x0008(sp)              // store t2, t1
        lw      t1, 0x0008(s1)              // load player ID
        addiu   t2, r0, Character.id.JDK    // load JDK ID
        beq     t1, t2, _jdkcargo           // jump to JDK cargo if JDK
        addiu   t2, r0, Character.id.MARINA // load MARINA ID
        beq     t1, t2, _marinacargo        // jump to MARINA cargo if MARINA
        addiu   t2, r0, Character.id.NMARINA // load NMARINA ID
        beq     t1, t2, _marinacargo        // jump to MARINA cargo if MARINA
        nop
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop


        _jdkcargo:
        lui     at, 0x41A0
        mtc1    at, f16                     // original line 2
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop

        _marinacargo:
        lui     at, 0x41A0
        mtc1    at, f16                     // original line 2
        lw      t1, 0x0004(sp)              // ~
        lw      t2, 0x0008(sp)              // load t0, t1
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }


    }
