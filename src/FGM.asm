// FGM.asm
if !{defined __FGM__} {
define __FGM__()
print "included FGM.asm\n"

// @ Description
// This file allows FGM (forground music) to be played.

include "OS.asm"
include "MIDI.asm"

scope FGM {
    // @ Description
    // Modifies the routine that maps Sound Test screen choices to FGM IDs
    scope augment_sound_test_voice_: {
        OS.patch_start(0x18858C, 0x801321BC)
        j       augment_sound_test_voice_
        nop
        OS.patch_end()

        lui     t4, 0x8013                        // original line 1
        lw      t4, 0x4350(t4)                    // original line 2
        slti    a0, t4, 0xF4                      // check if this is one we added (so >= 0xF4)
        bnez    a0, _normal                       // if (original fgm_id) then skip to _normal
        nop
        // If we're here, then the voice ID is > 0xF3 which means it's
        // one we added. So we need to set up a0 as the extended sfx
        // table address and offset:
        li      a0, extended_voice_map_table      // a0 = address of extended table
        addiu   t5, t4, -0x00F4                   // t5 = slot in extended table
        sll     t5, t5, 0x2                       // t5 = offset for fgm_id in extended table
        addu    a0, a0, t5                        // a0 = adress for fgm_id
        lhu     a0, 0x0002(a0)                    // a0 = fgm_id
        jal     0x800269C0                        // call sound routine
        nop
        j       0x801321D8                        // return
        nop

        _normal:
        j       0x801321C4                        // continue with original line 3
        nop
    }

    // @ Description
    // Plays a sound effect (safe)
    // @ Arguments
    // a0 - fgm_id
    scope play_: {
        OS.save_registers()
        jal     0x800269C0
        nop
        OS.restore_registers()
        jr      ra
        nop
    }

    // Extended Sound Effects

    print "=============================== SOUND FILES ==============================\n"

    // The CTL_TABLE is the base for a lot of sound related offsets
    read32 CTL_TABLE, "../roms/original.z64", 0x3D750
    constant BANK_MAP(CTL_TABLE + 0x0028) // 0x0028(CTL_TABLE)
    read32 RAW_SAMPLE_DATA, "../roms/original.z64", 0x3D754
    read32 PARAMETERS_MAP_OFFSET, "../roms/original.z64", BANK_MAP
    constant PARAMETERS_MAP(CTL_TABLE + PARAMETERS_MAP_OFFSET)
    read32 DEFAULT_SOUND_PARAMETERS_OFFSET, "../roms/original.z64", PARAMETERS_MAP
    constant DEFAULT_SOUND_PARAMETERS(CTL_TABLE + DEFAULT_SOUND_PARAMETERS_OFFSET)
    constant BANK_TABLE(DEFAULT_SOUND_PARAMETERS + 0x10)
    constant PREDICTORS(BANK_TABLE + 0xA10) // 0x142 * 8
    read32 SFX_FGM_MAP, "../roms/original.z64", 0x3D790
    constant SFX_FGM_TABLE(SFX_FGM_MAP + 0x744) // 0x1D0 * 4 + 4
    read32 FGM_MICROCODE_MAP, "../roms/original.z64", 0x3D798
    constant FGM_MICROCODE(FGM_MICROCODE_MAP + 0xAE0) // 0x2B7 * 4 + 4

    // The following help determine correct offsets
    constant ORIGINAL_MIDI_SEGMENT_SIZE(0x35C0)
    constant DIFFERENCE((((MIDI.midi_count + 1) * 8 + 0xF) & 0xFFF0) + ((MIDI.largest_midi + 0xF) & 0xFFF0) - ORIGINAL_MIDI_SEGMENT_SIZE)
    constant FGM_MICROCODE_MAP_PC(0x80076D50 + DIFFERENCE)
    constant SFX_FGM_MAP_PC(0x80073F80 + DIFFERENCE)
    constant CTL_TABLE_PC(0x8004D9F0)

    constant ORIGINAL_FGM_COUNT(0x2B7)
    constant ORIGINAL_SFX_FGM_COUNT(0x1D0)
    constant ORIGINAL_SAMPLE_COUNT(0x142)
    variable new_sample_count(0)
    variable new_sfx_count(0)
    variable new_fgm_count(0)
    variable new_sfx_fgm_size(0)
    variable new_fgm_microcode_size(0)

    // Sample rate constants
    constant SAMPLE_RATE_32000(0x60)
    constant SAMPLE_RATE_16000(0x20)

    // FGM types
    constant FGM_TYPE_VOICE(0x00)
    constant FGM_TYPE_CHANT(0x01)

    OS.align(16)
    default_sound_parameters_moved:
    variable default_sound_parameters_moved_origin(origin())
    dw 0x00
    dw 0x00
    dw 0x00
    dw 0x00

    // @ Description
    // Inserts the predictors for the given new sound number
    // @ Arguments
    // num - the new sound number
    macro insert_predictors(num) {
        dw     0x00000002
        dw     0x00000004
        insert SOUND_PREDICTORS_{num}, "../src/{SOUND_NAME_{num}}.aifc", 0x70, 0x80
    }

    // @ Description
    // Inserts the raw data for the given new sound number
    // @ Arguments
    // num - the new sound number
    macro insert_raw_data(num) {
        // Loop predictors can be at the end of the file, so I intentionally read a specific length
        insert SOUND_RAW_{num}, "../src/{SOUND_NAME_{num}}.aifc", 0x100, SOUND_SAMPLE_SIZE_{num} - 0x0008
    }

    // @ Description
    // Adds a new sound file to the sound bank.
    // @ Arguments
    // name - Name of the file located in ../src, without the extension and including directory e.g. DrMario/sounds/B65
    // sample rate - The desired sample rate, for now 16000 Hz and 32000 Hz are supported
    // fgm_type - The type of sound, for now Voice and Chant are supported, with Chant including crowd noise
    // reverb - Amount of reverb to apply to the sample, 0-127, only supported by Voice type
    // fgm_length - The length of the sound, -1 will determine length automatically  
    macro add_sound(name, sample_rate, fgm_type, reverb, fgm_length) {
        global variable new_sample_count(new_sample_count + 1)
        global variable new_sfx_count(new_sfx_count + 1)
        global variable new_fgm_count(new_fgm_count + 1)
        evaluate num(new_sample_count)
        evaluate sfx_num(new_sfx_count)
        evaluate fgm_num(new_fgm_count)
        global define SOUND_NAME_{num}({name})
        global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}(ORIGINAL_SFX_FGM_COUNT - 1 + new_sfx_count)
        global evaluate SOUND_SFX_SOUND_ID_{sfx_num}(0x8141 + new_sample_count)
        global evaluate SOUND_SAMPLE_RATE_{sfx_num}({sample_rate})
        global evaluate SOUND_TYPE_FGM_{fgm_num}({fgm_type})
        global evaluate SOUND_TYPE_SFX_{sfx_num}({fgm_type})
        global evaluate SOUND_REVERB_{sfx_num}({reverb})

        // Sample size is 2 words too long
        read32 SOUND_SAMPLE_SIZE_{num}, "../src/{SOUND_NAME_{num}}.aifc", 0xF4
        read32 SOUND_SIZE_{fgm_num}, "../src/{SOUND_NAME_{num}}.aifc", 0x4
        if {fgm_length} != -1 {
            global evaluate SOUND_LENGTH_{fgm_num}({fgm_length})
        } else {
            global evaluate SOUND_LENGTH_{fgm_num}(SOUND_SIZE_{fgm_num} / 177)
        }
        if {fgm_type} == FGM_TYPE_VOICE {
            global variable new_fgm_microcode_size(new_fgm_microcode_size + 0x11)
        } else {
            global variable new_fgm_microcode_size(new_fgm_microcode_size + 0x13)
        }
        global variable new_sfx_fgm_size(new_sfx_fgm_size + 0xD)
        
        global define SOUND_LOOP_PARAMS_{num}(0x00000000)

        print "Added {SOUND_NAME_{num}}\nFGM_ID: 0x"; OS.print_hex(ORIGINAL_FGM_COUNT - 1 + {fgm_num}); print " (", ORIGINAL_FGM_COUNT - 1 + {fgm_num},")\n"
        print "Sound Test Voice ID: ", 244 + {fgm_num}, "\n\n"
    }

    // @ Description
    // Adds a new sound file to the sound bank using files for finer control over microcode.
    // @ Arguments
    // display_name                - Name to displayed in debug output
    // file_name                   - Name of the file located in ../src, without the extension and including directory e.g. DrMario/sounds/B65
    // fgm_microcode_file          - The file containing the FGM microcode
    // fgm_microcode_file_size     - The size of the FGM microcode file
    // sfx_microcode_file          - The file containing the SFX to FGM microcode
    // sfx_microcode_file_size     - The size of the SFX to FGM microcode file
    // loop_enabled                - (bool) if OS.FALSE, then loop is not enabled, if OS.TRUE then loop is enabled
    // loop_start                  - (word) loop start
    // loop_end                    - (word) loop end
    // loop_count                  - (word) loop count
    // loop_predictors_file_exists - (bool) if OS.TRUE, then loop predictors are in {name}.bin, if OS.FALSE then fill with the end of the .aifc file
    macro add_sound_advanced(name, file_name, fgm_microcode_file, fgm_microcode_file_size, sfx_microcode_file, sfx_microcode_file_size, loop_enabled, loop_start, loop_end, loop_count, loop_predictors_file_exists) {
        global variable new_sample_count(new_sample_count + 1)
        global variable new_sfx_count(new_sfx_count + 1)
        global variable new_fgm_count(new_fgm_count + 1)
        evaluate num(new_sample_count)
        evaluate sfx_num(new_sfx_count)
        evaluate fgm_num(new_fgm_count)
        global define SOUND_NAME_{num}({file_name})
        global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}(ORIGINAL_SFX_FGM_COUNT - 1 + new_sfx_count)
        global evaluate SOUND_SFX_SOUND_ID_{sfx_num}(0x8141 + new_sample_count)
        global define SOUND_FGM_MICROCODE_FILE_{fgm_num}({fgm_microcode_file})
        global define SOUND_SFX_MICROCODE_FILE_{sfx_num}({sfx_microcode_file})

        // Sample size is 2 words too long
        read32 SOUND_SAMPLE_SIZE_{num}, "../src/{SOUND_NAME_{num}}.aifc", 0xF4

        global variable new_fgm_microcode_size(new_fgm_microcode_size + {fgm_microcode_file_size})
        global variable new_sfx_fgm_size(new_sfx_fgm_size + {sfx_microcode_file_size})

        if {loop_enabled} == OS.TRUE {
            global define SOUND_LOOP_PARAMS_{num}(pc() - CTL_TABLE_PC)
            dw  {loop_start}
            dw  {loop_end}
            dw  {loop_count}
            // loop predictors - should be at the end of the .aifc file or in a separate .bin file
            if {loop_predictors_file_exists} == OS.TRUE {
                insert "../src/music/instruments/{SAMPLE_NAME_{inst_num}_{sample_num}}.bin"
            } else {
                insert "../src/{SOUND_NAME_{num}}.aifc", SOUND_SAMPLE_SIZE_{num} + 0xF8
            }
            dw  0x0000
        } else {
            global define SOUND_LOOP_PARAMS_{num}(0x00000000)
        }

        print "Added {SOUND_NAME_{num}}\nFGM_ID: 0x"; OS.print_hex(ORIGINAL_FGM_COUNT - 1 + {fgm_num}); print " (", ORIGINAL_FGM_COUNT - 1 + {fgm_num},")\n"
        print "Sound Test Voice ID: ", 244 + {fgm_num}, "\n\n"
    }

    // @ Description
    // Adds a new FGM ID
    // name - Name to displayed in debug output
    // fgm_microcode_file - The file containing the FGM microcode
    // fgm_microcode_file_size - The size of the FGM microcode file
    // sfx_id - The sfx_id to use - if -1, then a new one is added from the following file
    // sfx_microcode_file - The file containing the SFX to FGM microcode
    // sfx_microcode_file_size - The size of the SFX to FGM microcode file
    // sound_id - The raw sample sound_id to use
    macro add_fgm(name, fgm_microcode_file, fgm_microcode_file_size, sfx_id, sfx_microcode_file, sfx_microcode_file_size, sound_id) {
        global variable new_fgm_count(new_fgm_count + 1)
        evaluate fgm_num(new_fgm_count)
        global define SOUND_FGM_MICROCODE_FILE_{fgm_num}({fgm_microcode_file})
        global variable new_fgm_microcode_size(new_fgm_microcode_size + {fgm_microcode_file_size})

        if {sfx_id} == -1 {
            global variable new_sfx_count(new_sfx_count + 1)
            evaluate sfx_num(new_sfx_count)
            global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}(ORIGINAL_SFX_FGM_COUNT - 1 + new_sfx_count)
            global evaluate SOUND_SFX_SOUND_ID_{sfx_num}({sound_id})
            global define SOUND_SFX_MICROCODE_FILE_{sfx_num}({sfx_microcode_file})
            global variable new_sfx_fgm_size(new_sfx_fgm_size + {sfx_microcode_file_size})
        } else {
            global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}({sfx_id})
        }

        print "Added {name}\nFGM_ID: 0x"; OS.print_hex(ORIGINAL_FGM_COUNT - 1 + {fgm_num}); print " (", ORIGINAL_FGM_COUNT - 1 + {fgm_num},")\n"
        print "Sound Test Voice ID: ", 244 + {fgm_num}, "\n\n"
    }

    // @ Description
    // Loops through the new sounds and FGMs and writes to the ROM.
    macro write_sounds() {
        parameters_map_extended:
        global variable parameters_map_extended_origin(origin())
        fill new_sample_count * 0x10, 0x00

        bank_table_extended:
        global variable bank_table_extended_origin(origin())
        // move bank table entries when new_sample_count > 4
        variable moved_bank_table_slots(0)
        if new_sample_count > 4 {
            variable moved_bank_table_slots((new_sample_count - 3) / 2) // 1 slot holds 2 words, bass rounds down

            // first move the slots
            insert  "../roms/original.z64", BANK_TABLE, moved_bank_table_slots * 0x8

            // then update the pointers
            define n(0)
            while {n} < moved_bank_table_slots {
                origin  PARAMETERS_MAP + 0x4 + ({n} * 0x10)       // need to update 2nd word in each 0x10 slot
                dw      bank_table_extended - CTL_TABLE_PC                                                                      // always this - when loaded to ram, it is 0x3F7E0104
                evaluate n({n}+1)
            }

            origin bank_table_extended_origin + (moved_bank_table_slots * 0x8)
        }
        fill new_sample_count * 0x8, 0x00

        predictors_extended:
        global variable predictors_extended_origin(origin())
        define n(1)
        while {n} <= new_sample_count {
            insert_predictors({n})
            evaluate size(SOUND_PREDICTORS_{n}.size)
            // Seems like A8 and D8 are the 2 valid sizes - we added 0x2 and 0x4 (words) and we'll add some words later as well
            if {size} < 0xA0 {
                fill 0xA0 - {size}, 0x00
            } else {
                fill 0xD0 - {size}, 0x00
            }
            evaluate n({n}+1)
        }

        pushvar origin, base
        origin MIDI.MIDI_BANK_END
        raw_sample_data_extended:
        global variable raw_sample_data_extended_origin(origin())
        define n(1)
        while {n} <= new_sample_count {
            insert_raw_data({n})
            evaluate n({n}+1)
        }
        OS.align(4)
        MIDI.MIDI_BANK_END = origin()
        pullvar base, origin

        sfx_fgm_table_extended:
        global variable sfx_fgm_table_extended_origin(origin())
        variable SPACE_REQUIRED(new_sfx_count * 0x4) // need a word for each new sfx_fgm
        variable total_sfx_fgm_size(0)
        define n(1)
        while total_sfx_fgm_size < SPACE_REQUIRED {
            read32   sfx_fgm_curr_pointer_{n}, "../roms/original.z64", SFX_FGM_MAP + ({n} * 4)
            evaluate next({n} + 1)
            read32   sfx_fgm_next_pointer_{n}, "../roms/original.z64", SFX_FGM_MAP + ({next} * 4)
            constant SFX_FGM_SIZE_{n}(sfx_fgm_next_pointer_{n} - sfx_fgm_curr_pointer_{n})
            variable total_sfx_fgm_size(total_sfx_fgm_size + SFX_FGM_SIZE_{n})
            evaluate n({n} + 1)
        }
        evaluate sfx_fgm_blocks({n})
        fill total_sfx_fgm_size, 0x00 // moved ones
        fill new_sfx_fgm_size, 0x00
        OS.align(4)

        fgm_microcode_extended:
        global variable fgm_microcode_extended_origin(origin())
        variable SPACE_REQUIRED(new_fgm_count * 0x4) // need a word for each new fgm
        variable total_microcode_size(0)
        define n(1)
        while total_microcode_size < SPACE_REQUIRED {
            read32   microcode_curr_pointer_{n}, "../roms/original.z64", FGM_MICROCODE_MAP + ({n} * 4)
            evaluate next({n} + 1)
            read32   microcode_next_pointer_{n}, "../roms/original.z64", FGM_MICROCODE_MAP + ({next} * 4)
            constant MICROCODE_SIZE_{n}(microcode_next_pointer_{n} - microcode_curr_pointer_{n})
            variable total_microcode_size(total_microcode_size + MICROCODE_SIZE_{n})
            evaluate n({n} + 1)
        }
        evaluate microcode_blocks({n})
        fill total_microcode_size, 0x00 // moved ones
        fill new_fgm_microcode_size, 0x00
        OS.align(4)

        extended_voice_map_table:
        global variable extended_voice_map_table_origin(origin())
        fill new_fgm_count * 0x4, 0x00

        // @ Description
        // Moves the default sound parameters to clear space for expanding BANK_MAP.
        // I'm not sure that these are ever used, though...
        macro move_default_sound_parameters() {
            pushvar origin, base

            // define a new offset for the default sound parameters
            origin  PARAMETERS_MAP
            while (origin() < RAW_SAMPLE_DATA) {
                dw      default_sound_parameters_moved - CTL_TABLE_PC           // first word in each entry is the offset
                origin origin() + 0xC
            }

            // remove the sound parameters - this makes room for 4 new sounds
            origin  DEFAULT_SOUND_PARAMETERS
            fill    0x10, 0x00

            // insert the default sound parameters
            origin  default_sound_parameters_moved_origin
            insert  "../roms/original.z64", DEFAULT_SOUND_PARAMETERS, 0x10

            pullvar base, origin
        }

        move_default_sound_parameters()

        pushvar origin, base

        // update bank size
        origin  CTL_TABLE + 0x26
        dh      0x0142 + new_sample_count

        // now augment bank with offsets
        origin  DEFAULT_SOUND_PARAMETERS
        define n(0)
        while {n} < new_sample_count {
            dw      parameters_map_extended - CTL_TABLE_PC + ({n} * 0x10)
            evaluate n({n}+1)
        }

        // now populate extended parameters map
        origin  parameters_map_extended_origin
        define n(0)
        while {n} < new_sample_count {
            dw      default_sound_parameters_moved - CTL_TABLE_PC                                     // offset to default sound params
            dw      bank_table_extended + (moved_bank_table_slots * 0x8) - CTL_TABLE_PC + ({n} * 0x8) // offset to bank table
            // TODO: predictors can be 0xA8 or 0xD8, so need to account for that properly
            // For now assuming always 0xA8
            dw      predictors_extended + 0x90 - CTL_TABLE_PC + ({n} * 0xA8)                          // offset to predictors block's raw sample data pointer
            dw      0x3F7E0004                                                                        // always this - when loaded to ram, it is 0x3F7E0104
            evaluate n({n}+1)
        }

        // now populate extended bank table
        origin  bank_table_extended_origin + moved_bank_table_slots * 0x8
        define n(0)
        while {n} < new_sample_count {
            // TODO: first two bytes should increment for each sound added until we get to 7F...
            // ...then it should increment the 0202 to 0303 for example and restart the first two at 0000
            dw      0x42420202 + ({n} * 0x01010000)
            // TODO: may need to put E180 or 0AF0 as the last halfword for every other one - unclear
            dw      0x00
            evaluate n({n}+1)
        }

        // now populate pointers in extended predictors table
        origin  predictors_extended_origin
        define n(0)
        variable added_raw_data_size(0)
        while {n} < new_sample_count {
            global evaluate num({n} + 1)

            // TODO: predictors can be 0xA8 or 0xD8, so need to account for that properly
            // For now assuming always 0xA8
            origin  predictors_extended_origin + 0x88 + ({n} * 0xA8)
            dw      0x00
            dw      0x00
            dw      raw_sample_data_extended_origin + added_raw_data_size - RAW_SAMPLE_DATA
            dw      SOUND_RAW_{num}.size
            variable added_raw_data_size(added_raw_data_size + SOUND_RAW_{num}.size)
            dw      0x0570
            dw      {SOUND_LOOP_PARAMS_{num}}     // pointer to loop params
            // TODO: predictors can be 0xA8 or 0xD8, so need to account for that properly
            // For now assuming always 0xA8
            dw      predictors_extended - CTL_TABLE_PC + ({n} * 0xA8)
            dw      0x0000

            evaluate n({n}+1)
        }

        // update sfx bank size
        origin  SFX_FGM_MAP
        dw      0x01D0 + new_sfx_count

        // update fgm bank size
        origin  FGM_MICROCODE_MAP
        dw      0x02B7 + new_fgm_count

        // @ Description
        // Adds SFX microcode
        // TODO: set up with more arguments once we understand this better
        // @ Arguments
        // sfx_fgm_index - The index in the SFX to FGM table
        // fgm_type - The type of sound, either Voice or Chant
        // fgm_length - The length of the sound, for now only suppored for chants
        macro add_microcode(sfx_fgm_index, fgm_type, fgm_length) {
            // If next byte is < 0x80, then it is the SFX_ID
            // If not, then the following byte is checked and combined with the first to get the SFX to FGM table's index
            // TODO: handle any sfx_fgm_index appropriately - for now, assume > 0x1D0 and < 0x180
            evaluate sfx_fgm_index({sfx_fgm_index}+0x8000)
            evaluate fgm_length({fgm_length}|0x8000)
            if {fgm_type} == FGM_TYPE_VOICE {
                dh  0xDE00
                db  0xD1              // Next halfword is pointer to SFX_ID
                dh  {sfx_fgm_index}
                dh  0xD2FF
                dh  0xD3D4
                dh  0xD224
                dh  0xD5FF
                db  0x6F
                dh  {fgm_length} // length
                db  0xD0
                // size = 0x11
            } else {
                dh  0xDE04
                db  0xD1
                dh  {sfx_fgm_index}
                dh  0xD2FF
                dh  0xD37F
                dw  0xD224DC26
                dh  0xD5FF
                db  0x6F
                dh  {fgm_length} // length
                db  0xD0
                // size = 0x13
            }
        }

        // @ Description
        // Adds SFX microcode using a file
        // @ Arguments
        // sfx_fgm_index - The index in the SFX to FGM table
        // fgm_microcode_file - The file containing the microcode
        macro add_microcode(sfx_fgm_index, fgm_microcode_file) {
            evaluate sfx_fgm_index({sfx_fgm_index}+0x8000)
            variable microcode_origin(origin())

            // Bytes 03-04 should be replaced with sfx_fgm_index
            insert "../src/{fgm_microcode_file}.bin"

            pushvar origin, base
            origin  microcode_origin + 0x03
            dh      {sfx_fgm_index}
            pullvar base, origin
        }

        // now make room for adding more fgm_ids by moving the first fgm_id microcodes
        define x(1)
        origin  fgm_microcode_extended_origin
        variable microcode_origin(origin())
        variable start(FGM_MICROCODE)
        while {x} < {microcode_blocks} {
            origin  microcode_origin
            variable microcode_pc(pc())
            insert  "../roms/original.z64", start, MICROCODE_SIZE_{x}
            variable start(start + MICROCODE_SIZE_{x})
            variable microcode_origin(origin())

            // now fix the pointer to the microcode
            origin  FGM_MICROCODE_MAP + ({x} * 4)
            dw      microcode_pc - FGM_MICROCODE_MAP_PC
            evaluate x({x} + 1)
        }

        // now add microcode for new sounds
        origin  fgm_microcode_extended_origin + total_microcode_size
        variable microcode_origin(origin())
        variable microcode_pc(pc())
        define n(0)
        while {n} < new_fgm_count {
            // add the new fgm_id
            origin  FGM_MICROCODE + ({n} * 4)
            dw      microcode_pc - FGM_MICROCODE_MAP_PC

            // add the microcode
            origin microcode_origin
            evaluate s({n}+1)
            if !{defined SOUND_FGM_MICROCODE_FILE_{s}} {
                add_microcode({SOUND_SFX_FGM_INDEX_{s}}, {SOUND_TYPE_FGM_{s}}, {SOUND_LENGTH_{s}})
            } else {
                add_microcode({SOUND_SFX_FGM_INDEX_{s}}, {SOUND_FGM_MICROCODE_FILE_{s}})
            }
            variable microcode_origin(origin())
            variable microcode_pc(pc())
            evaluate n({n}+1)
        }

        // @ Description
        // Adds SFX to FGM blocks
        // TODO: set up with more arguments once we understand this better
        // @ Arguments
        // sound_id - The index in the raw sample table
        // sample_rate - Sample of the SFX, for now 16000 Hz and 32000 Hz are supported
        // reverb - Amount of reverb to apply to the sample, 0-127, only supported by Voice type
        // fgm_type - The type of sound, either Voice or Chant
        macro add_sfx_fgm(sound_id, sample_rate, reverb, fgm_type) {
            // Block size of 0x3C is no longer filled
            if {reverb} > 127 {
                print "Invalid reverb value attempted: {reverb}. Max reverb of 127 will be used instead.\n"
                evaluate reverb(127)
            }
            if {fgm_type} == FGM_TYPE_VOICE {
                db      0x60                                        // always starts with 60
                dh      {sound_id}                                  // add the pointer to the sfx id we added
                db      {sample_rate}                               // set sample rate (0x20 = 16000 Hz, 0x60 = 32000 Hz)
                dh      0xFB50
                db      0x30
                db      {reverb}
                dw      0x089F407F
                db      0x70
                // size = 0xD
                // OLD
                // dw      0xFB500564
                // dw      0x05690574
                // dw      0x080A7208
                // dw      0x19690832
                // dw      0x5F083255
                // dw      0x08324608
                // dw      0x3C3C083C
                // dw      0x32700000
            } else {
                db      0x60                                        // always starts with 60
                dh      {sound_id}                                  // add the pointer to the sfx id we added
                db      {sample_rate}                               // set sample rate (0x20 = 16000 Hz, 0x60 = 32000 Hz)
                dw      0x306420FB
                dw      0x5A0B747F
                db      0x70
                // size = 0xD
            }
        }

        // @ Description
        // Adds SFX to FGM blocks using a file
        // @ Arguments
        // sound_id - The index in the raw sample table
        // sfx_fgm_file - The file containing the SFX to FGM microcode
        macro add_sfx_fgm(sound_id, sfx_fgm_file) {
            variable sfx_fgm_origin(origin())

            insert "../src/{sfx_fgm_file}.bin"

            // Bytes 01-02 should be replaced with sound_id
            pushvar origin, base
            origin  sfx_fgm_origin + 0x01
            dh      {sound_id}
            pullvar base, origin
        }

        // now make room for adding other sfx_id to fgm_id records by moving the first sfx_id to fgm_id blocks
        define x(1)
        origin  sfx_fgm_table_extended_origin
        variable sfx_fgm_origin(origin())
        variable start(SFX_FGM_TABLE)
        while {x} < {sfx_fgm_blocks} {
            origin  sfx_fgm_origin
            variable sfx_fgm_pc(pc())
            insert  "../roms/original.z64", start, SFX_FGM_SIZE_{x}
            variable start(start + SFX_FGM_SIZE_{x})
            variable sfx_fgm_origin(origin())

            // now fix the pointer to the sfx_fgm record
            origin  SFX_FGM_MAP + ({x} * 4)
            dw      sfx_fgm_pc - SFX_FGM_MAP_PC
            evaluate x({x} + 1)
        }

        // now add sfx_fgm records for new sounds
        origin  sfx_fgm_table_extended_origin + total_sfx_fgm_size
        variable sfx_fgm_origin(origin())
        variable sfx_fgm_pc(pc())
        define n(0)
        while {n} < new_sfx_count {
            // add the new sfx_fgm_id
            origin  SFX_FGM_TABLE + ({n} * 4)
            dw      sfx_fgm_pc - SFX_FGM_MAP_PC

            // add the sfx to fgm block
            origin sfx_fgm_origin
            evaluate s({n}+1)
            if !{defined SOUND_SFX_MICROCODE_FILE_{s}} {
                add_sfx_fgm({SOUND_SFX_SOUND_ID_{s}}, {SOUND_SAMPLE_RATE_{s}}, {SOUND_REVERB_{s}}, {SOUND_TYPE_SFX_{s}})
            } else {
                add_sfx_fgm({SOUND_SFX_SOUND_ID_{s}}, {SOUND_SFX_MICROCODE_FILE_{s}})
            }
            variable sfx_fgm_origin(origin())
            variable sfx_fgm_pc(pc())
            evaluate n({n}+1)
        }

        // add voice ID 244's fgm_id to our extended voice ID map table
        origin  extended_voice_map_table_origin
        define n(0)
        while {n} < new_fgm_count {
            dw      ORIGINAL_FGM_COUNT + {n}
            evaluate n({n}+1)
        }

        // Extend Sound Test Voice numbers so we can test in game easier
        origin  0x188422
        dh      0xF4 + new_fgm_count
        origin  0x18842A
        dh      0xF4 + new_fgm_count
        origin  0x188436
        dh      0xF3 + new_fgm_count
        origin  0x18829E
        dh      0xF3 + new_fgm_count

        pullvar base, origin

        // @ Description
        // 0x2B7 was used as a way to cancel SFX for at least Metal Mario.
        // This patch will look for 0x2B7 and treat it as out of bounds when
        // calling play_.
        scope fix_0x2b7_: {
            OS.patch_start(0x275CC, 0x800269CC)
            j       fix_0x2b7_
            andi    a1, a0, 0xFFFF              // original line 1
            _return:
            addiu   sp, sp, 0xFFE8              // original line 2
            OS.patch_end()

            lli     at, ORIGINAL_FGM_COUNT      // at = 0x2B7
            beql    at, a1, _end                // if fgm_id = 0x2B7, then skip to end
            or      at, r0, r0                  // and set at to 0

            // otherwise, use original line
            slt     at, a1, t6                  // original line 3

            _end:
            j       _return
            nop
        }

        OS.align(4)
    }

    // Add the sounds here
    add_sound(Ganondorf/sounds/PLACEHOLDER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1) // PLACEHOLDER: id 2B7 has issues in-game
    add_sound(Ganondorf/sounds/53 deflectsound2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/54 hurtcut3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/55 hurt2cut2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/56 attacklike6cut3 seems unused, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/57 middle size attackcut6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/58 attacklike2cut7, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/GNDWARLOCKPUNCH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/PLACEHOLDER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1) // PLACEHOLDER: GNDWARLOCKPUNCH is now all one sound so this lsot is unused
    add_sound(Ganondorf/sounds/5C Goodattacksound, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/5D attacklike6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/5E shortenedlaugh, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/5F attacklike5cut4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/62 deathlikecut1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(DrMario/sounds/65, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DrMario/sounds/B5, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/FALCO_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 0x157)
    add_sound(Falco/sounds/66, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/67, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/68, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/69, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/6a, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/6B, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/6C, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/6D, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/6E, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/6F, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/70, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/71, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/72, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Falco/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(YoungLink/sounds/YLINK_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 0x101)
    add_sound(YoungLink/sounds/8A2, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/8B Hup!short3, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/8C5, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/8D2, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/8E2, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/8F, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/90, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/91, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/92, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/93, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/95, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/yltaunt, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/96, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(DrMario/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(YoungLink/sounds/YLTAUNTDRINK, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/YLSLEEP, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/GNDSTUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/GND_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 0x10C)
    add_sound(DrMario/sounds/DRM_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 0x160)
    add_sound(DSamus/sounds/ANNOUNCER, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Wario/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/ATTACK_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/DODGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/DEATH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/SHIELD_BREAK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/SMALL_GRUNT_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/SMALL_GRUNT_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/LAUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/BIG_GRUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/YEAH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/SELECT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/VICTORY_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/VICTORY_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/HERE_I_GO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/PLANE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/HURRY_UP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wario/sounds/WARIO_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(Wario/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Elink/sounds/ANNOUNCER, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 40, -1)
    add_sound(sounds/PolygonMario, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonFox, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonDonkeyKong, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonSamus, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonLuigi, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonLink, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonYoshi, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonCaptainFalcon, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonKirby, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonPikachu, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonJigglypuff, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/PolygonNess, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/VICTORY_LAUGH, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JFox/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(JMario/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JDK/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JLink/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JSamus/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JYoshi/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JKirby/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JFox/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JPika/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JLuigi/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JNess/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JFalcon/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JPuff/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(JFox/sounds/VICTORY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_fgm(JBeamSwordHeavy, sounds/beamsword/JBeamSwordHeavyMicrocode, 0x25, 0x16, -1, -1, -1)
    add_fgm(JBeamSwordMedium, sounds/beamsword/JBeamSwordMediumMicrocode, 0x19, 0x17, -1, -1, -1)
    add_fgm(JBeamSwordLight, sounds/beamsword/JBeamSwordLightMicrocode, 0x13, 0x18, -1, -1, -1)
    add_sound(JPuff/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(JPuff/sounds/11A_POUND, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/11B_SMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/11C_SMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/11D_SMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/11E_SING, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound_advanced(Purin Sleep, JPuff/sounds/11F_SLEEP, JPuff/sounds/11F_SLEEP_fgm_microcode, 0x1A, JPuff/sounds/11F_SLEEP_sfx_microcode, 0xA, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_sound(JPuff/sounds/118_KO_DAMAGED, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/119_DAMAGED, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/120_UNKNOWN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/121_TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/122_ROLLMAYBE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/123_STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/124_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/125_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/126_HEAVY_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/127_STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/ATTACKLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/ATTACK2LUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/ATTACK3LUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/CROWDCHANTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(Lucas/sounds/DIZZYLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/DOWNSMASHLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/HURTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/JUMPLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/KOLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/LIFTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/PKFIRELUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/PKTHUNDERLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/PKTHUNDER2LUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/SLEEPLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/STARKOLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/TEETERLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/UPSMASHLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/TAUNTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(ESamus/sounds/ANNOUNCER, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Lucas/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)

    // This is always last
    write_sounds()

    print "========================================================================== \n"

    // item sounds
    scope item {
        constant BAT(52)
        constant BEAM_SWORD_HEAVY(0x43)
        constant J_BEAM_SWORD_HEAVY(0x321)
        constant BEAM_SWORD_MEDIUM(0x44)
        constant J_BEAM_SWORD_MEDIUM(0x322)
        constant BEAM_SWORD_LIGHT(0x45)
        constant J_BEAM_SWORD_LIGHT(0x323)
    }

    // main menu sounds
    scope menu {
        constant START(157)
        constant CONFIRM(158)
        constant SELECT_STAGE(159)
        constant TOGGLE(163)
        constant SCROLL(164)
        constant ILLEGAL(165)
    }

    // hit sounds
    scope hit {
        constant PUNCH_S(0x28)
        constant PUNCH_M(0x26)
        constant PUNCH_L(0x25)
        constant KICK_S(0x22)
        constant KICK_M(0x20)
        constant KICK_L(0x1F)
        constant J_PUNCH_S(0x93)
        constant J_PUNCH_M(0x92)
        constant J_PUNCH_L(0x91)
        constant J_KICK_S(0x90)
        constant J_KICK_M(0x8F)
        constant J_KICK_L(0x8E)
    }

    // character select screen
    scope announcer {

        scope names {
            constant FIGHTING_POLYGON_TEAM(482)
            constant DONKEY_KONG(483)
            constant DK(483)
            constant CAPTAIN_FALCON(485)
            constant FALCON(485)
            constant FOX(486)
            constant GIANT_DONKEY_KONG(489)
            constant GDK(489)
            constant METAL_MARIO(462)
            constant KIRBY(496)
            constant LINK(497)
            constant LUIGI(498)
            constant MARIO(499)
            constant NESS(501)
            constant PIKACHU(507)
            constant JIGGLYPUFF(508)
            constant SAMUS(513)
            constant YOSHI(535)
            constant FALCO(726)
            constant GANONDORF(709)
            constant YOUNG_LINK(741)
            constant DR_MARIO(742)
            constant WARIO(772)
            constant DSAMUS(748)
            constant ELINK(773)
            constant POLYGON_MARIO(774)
            constant POLYGON_FOX(775)
            constant POLYGON_DONKEY_KONG(776)
            constant POLYGON_SAMUS(777)
            constant POLYGON_LUIGI(778)
            constant POLYGON_LINK(779)
            constant POLYGON_YOSHI(780)
            constant POLYGON_CAPTAIN_FALCON(781)
            constant POLYGON_KIRBY(782)
            constant POLYGON_PIKACHU(783)
            constant POLYGON_JIGGLYPUFF(784)
            constant POLYGON_NESS(785)
            constant JFOX(787)
            constant JPUFF(804)
            constant ESAMUS(839)
            constant LUCAS(840)
        }

        scope css {
            constant CHOOSE_YOUR_CHARACTER(479)
            constant FREE_FOR_ALL(512)
            constant TEAM_BATTLE(526)
            constant TRAINING_MODE(530)
        }

        scope team {
            constant BLUE(475)
            constant GREEN(491)
            constant RED(510)
        }

        scope results {
            constant DRAW_GAME(484)                 // unused
            constant NO_CONTEST(502)
            constant WINS(533)
            constant THIS_GAMES_WINNER_IS(534)
        }

        scope singleplayer {
            constant A_NEW_RECORD(464)
            constant BOARD_THE_PLATFROMS(476)
            constant BONUS_STAGE(477)
            constant BREAK_THE_TARGETS(478)
            constant CONTINUE(481)
            constant GAME_OVER(487)
            constant RACE_TO_THE_FINISH(495)
            constant MARIO_BROTHERS(500)
            constant KIRBY_TEAM(529)
            constant YOSHI_TEAM(531)
            constant VERSUS(532)
        }

        scope fight {
            constant GAME_SET(488)
            constant GO(490)
            constant PLAYER_1(503)
            constant PLAYER_2(504)
            constant PLAYER_3(505)
            constant PLAYER_4(506)
            constant DEFEATED(511)
            constant SUDDEN_DEATH(514)
            constant TIME_UP(527)
        }

        scope misc {
            constant HOW_TO_PLAY(494)
            constant ARE_YOU_READY(509)
            constant SUPER_SMASH_BROTHERS(528)
            constant INCREDIBLE(466)
            constant SHINE(189)
            constant MARIO_POWERUP(212)
            constant MARIO_POWERDOWN(213)
            constant WARP_PIPE(214)
            constant FIREBALL(215)
            constant COIN(216)
            constant MARIO_JUMP(217)
            constant SHOW_ME_YOUR_MOVES(337)
        }

    }

}

} // __FGM__
