// MIDI.asm (Fray)
if !{defined __MIDI__} {
define __MIDI__()

// This file extends the music table and defines macros for including new MIDI files.
// For converting MIDI files, it's reccomended to use GE Editor.
// Tools > Extra Tools > MIDI Tools > Convert Midi to GE Format and Loop

include "OS.asm"

scope MIDI {
    read32 MUSIC_TABLE, "../roms/original.z64", 0x3D768
    variable MUSIC_TABLE_END(MUSIC_TABLE + 0x17C)   // variable containing the current end of the music table
    constant MIDI_BANK(0x2400000)                   // defines the start of the additional MIDI bank
    variable MIDI_BANK_END(MIDI_BANK)               // variable containing the current end of the MIDI bank
    // These 2 variables will be used in FGM.asm to calculate the correct RAM offset for numerous pointers
    variable midi_count(0x2F)                       // variable containing total number of MIDIs
    variable largest_midi(0)                        // variable containing the largest MIDI size
    
    // @ Description
    // moves the Dream Land midi to our new MIDI bank to clear space for expanding MUSIC_TABLE
    macro move_dream_land_midi() {
        pushvar origin, base
        
        // define a new offset for the Dream Land MIDI
        origin  MUSIC_TABLE + 0x4           
        dw      MIDI_BANK_END - MUSIC_TABLE
        
        // remove the previous Dream Land MIDI
        origin  MUSIC_TABLE_END
        fill    0x1F40, 0x00
        
        // insert the Dream Land MIDI and update MIDI_BANK_END
        origin  MIDI_BANK_END
        insert  MIDI_Dream_Land, "../roms/original.z64", MUSIC_TABLE + 0x17C, 0x1F40
        global variable MIDI_BANK_END(origin())
        
        pullvar base, origin
    }

    // @ Description
    // adds a MIDI to our new MIDI bank, and the music table
    macro insert_midi(file_name) {
        pushvar origin, base
        
        // defines
        define  path_MIDI_{file_name}(../src/music/{file_name}.bin)
        evaluate offset_MIDI_{file_name}(MIDI_BANK_END)
        evaluate MIDI_{file_name}_ID((MUSIC_TABLE_END - MUSIC_TABLE) / 0x8)
        
        global variable midi_count({MIDI_{file_name}_ID} + 0x1)

        // print message
        print "Added MIDI_{file_name}({path_MIDI_{file_name}})\n"
        print "ROM Offset: 0x"; OS.print_hex({offset_MIDI_{file_name}}); print "\n"
        print "MIDI_{file_name}_ID: 0x"; OS.print_hex({MIDI_{file_name}_ID}); print "\n"
        print "Sound Test Music ID: ", midi_count, "\n\n"
        
        // add the new midi to the music table and update MUSIC_TABLE_END
        origin  MUSIC_TABLE_END
        dw      origin_MIDI_{file_name} - MUSIC_TABLE
        dw      MIDI_{file_name}.size
        global variable MUSIC_TABLE_END(origin())
        
        // insert the MIDI file and update MIDI_BANK_END
        origin  MIDI_BANK_END
        constant origin_MIDI_{file_name}(origin())
        insert  MIDI_{file_name}, "{path_MIDI_{file_name}}"
        OS.align(4)
        global variable MIDI_BANK_END(origin())
        
        // set the number of songs in MUSIC_TABLE
        origin  MUSIC_TABLE + 0x2
        dh      midi_count
        
        // update largest MIDI size
        if MIDI_{file_name}.size > largest_midi {
            global variable largest_midi(MIDI_{file_name}.size)
        }

        pullvar base, origin
    }
    
    // define new MIDI bank
    print "=============================== MIDI FILES =============================== \n"
    // print music table offset
    evaluate music_table_offset(MUSIC_TABLE)
    print "Music Table: 0x"; OS.print_hex({music_table_offset}); print "\n"
    // move dream land midi
    move_dream_land_midi()
    // insert custom midi files
    insert_midi(GANONDORF_BATTLE)
    insert_midi(CORNERIA)
    insert_midi(KOKIRI_FOREST)
    insert_midi(DR_MARIO)
    insert_midi(KALOS)
    insert_midi(SMASHVILLE)
    insert_midi(WARIO_WARE)
    insert_midi(FIRST_DESTINATION)
	insert_midi(COOLCOOLMOUNTAIN)
	insert_midi(GODDESSBALLAD)
	insert_midi(GREATBAY)
	insert_midi(TOWEROFHEAVEN)
	insert_midi(FOD)
    insert_midi(MUDA)
    insert_midi(MEMENTOS)
    insert_midi(SPIRAL_MOUNTAIN)
    insert_midi(MORAY_TOWERS)
    insert_midi(MUTE_CITY)
    insert_midi(BATTLEFIELD)
    insert_midi(MADMONSTER)
    insert_midi(GANON_VICTORY)
    insert_midi(YOUNGLINK_VICTORY)
    insert_midi(FALCO_VICTORY)
    insert_midi(DRMARIO_VICTORY)

    pushvar origin, base

    // Extend Sound Test Music numbers so we can test in game easier
    origin  0x1883BA
    dh      midi_count
    origin  0x188246
    dh      midi_count - 1
    origin  0x1883C2
    dh      midi_count - 1
    origin  0x1883CE
    dh      midi_count - 1

    pullvar base, origin

    // @ Description
    // Modifies the routine that maps Sound Test screen choices to BGM IDs
    scope augment_sound_test_music_: {
        OS.patch_start(0x188530, 0x80132160)
        j       augment_sound_test_music_
        nop
        OS.patch_end()

        lui     t0, 0x8013                        // original line 1
        lw      t0, 0x4348(t0)                    // original line 2
        slti    a0, t0, 0x2D                      // check if this is one we added (so >= 0x2D)
        bnez    a0, _normal                       // if (original bgm_id) then skip to _normal
        nop
        // If we're here, then the music ID is > 0x2C which means it's
        // one we added. So we need to set up a1 as the extended music
        // table address and offset:
        li      a1, extended_music_map_table      // a1 = address of extended table
        addiu   t0, t0, -0x002D                   // t0 = slot in extended table
        sll     t1, t0, 0x2                       // t1 = offset for bgm_id in extended table
        addu    a1, a1, t1                        // a1 = adress for bgm_id
        lhu     a1, 0x0002(a1)                    // a1 = bgm_id
        jal     0x80020AB4                        // call play MIDI routine
        nop
        j       0x80132180                        // return
        nop

        _normal:
        j       0x80132168                        // continue with original line 3
        nop
    }

    extended_music_map_table:
    dw     0xA                                    // for some reason originally left of music test
    dw     0xB                                    // for some reason originally left of music test
    define n(0x2F)
    while {n} < midi_count {
        dw      {n}
        evaluate n({n}+1)
    }

    print "========================================================================== \n"
}

} // __MIDI__
