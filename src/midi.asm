// MIDI.asm (Fray)

// This file extends the music table and defines macros for including new MIDI files.
// For converting MIDI files, it's reccomended to use GE Editor.
// Tools > Extra Tools > MIDI Tools > Convert Midi to GE Format and Loop

include "OS.asm"

scope MIDI {
    read32 MUSIC_TABLE, "../roms/original.z64", 0x3D768
    variable MUSIC_TABLE_END(MUSIC_TABLE + 0x17C)   // variable containing the current end of the music table
    constant MIDI_BANK(0x2400000)                   // defines the start of the additional MIDI bank
    variable MIDI_BANK_END(MIDI_BANK)               // variable containing the current end of the MIDI bank
    
    
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
        
        // print message
        print "Added MIDI_{file_name}({path_MIDI_{file_name}})\n"
        print "ROM Offset: 0x"; OS.print_hex({offset_MIDI_{file_name}}); print "\n"
        print "MIDI_{file_name}_ID: 0x"; OS.print_hex({MIDI_{file_name}_ID}); print "\n\n"
        
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
        dh      {MIDI_{file_name}_ID} + 0x1
        
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
    print "========================================================================== \n"
}