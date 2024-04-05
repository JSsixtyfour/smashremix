// FGM.asm
if !{defined __FGM__} {
define __FGM__()
print "included FGM.asm\n"

// @ Description
// This file allows FGM (foreground music) to be played.

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
    // Handles L and R presses for Sound Test quick browsing (increments of 50)
    scope sound_test_R: {
        OS.patch_start(0x18838C, 0x80131FBC)
        j       sound_test_R
        nop
        _return:
        OS.patch_end()

        jal     0x80390804                      // check pressed button
        addiu   a0, r0, Joypad.R                // a0 = R (not DR or CR)

        bnezl   v0, _end
        addiu   t9, t0, 0x0032                  // t9 = t0 + 50
        addiu   t9, t0, 0x0001                  // t9 = t0++ (original logic)

        _end:
        lw      v0, 0x0000(a3)                  // restore v0 (the currently selected type)
        lui     t7, 0x8013                      // original line 1
        j       _return
        nop
    }
    scope sound_test_L: {
        OS.patch_start(0x188210, 0x80131E40)
        j       sound_test_L
        nop
        _return:
        OS.patch_end()

        or      at, r0, t6                      // at = t6
        jal     0x80390804                      // check pressed button
        addiu   a0, r0, Joypad.L                // a0 = L (not DL or CL)

        or      t6, r0, at                      // restore t6 (current value)
        bnezl   v0, _end
        addiu   t7, t6, -0x0032                 // t7 = t6 - 50
        addiu   t7, t6, -0x0001                 // t7 = t6-- (original logic)

        _end:
        lw      v0, 0x0000(a3)                  // restore v0 (the currently selected type)
        addiu   at, r0, 0x0001                  // original line 1
        j       _return
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

    // @ Description
    // Plays a sound effect
    macro play(sfx) {
        jal     0x800269C0
        addiu   a0, r0, {sfx}
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
    read32 FGM_MICROCODE_MAP, "../roms/original.z64", 0x3D798 // PAL: 0x3DDC8
    constant FGM_MICROCODE(FGM_MICROCODE_MAP + 0xAE0) // 0x2B7 * 4 + 4

    // The following help determine correct offsets
    constant ORIGINAL_MIDI_SEGMENT_SIZE(0x35C0)
    constant DIFFERENCE((((MIDI.midi_count + 1) * 8 + 0xF) & 0xFFF0) - ORIGINAL_MIDI_SEGMENT_SIZE)
    constant FGM_MICROCODE_MAP_PC(0x80076D50 + DIFFERENCE) // PAL: 8007F280
    constant SFX_FGM_MAP_PC(0x80073F80 + DIFFERENCE) // PAL: 8007BBE0
    constant PREDICTOR_PC(0x8004E940)
    constant CTL_TABLE_PC(0x8004D9F0)

    constant ORIGINAL_FGM_COUNT(0x2B7)
    constant ORIGINAL_SFX_FGM_COUNT(0x1D0)
    constant ORIGINAL_SAMPLE_COUNT(0x142)
    variable new_sample_count(0)
    variable new_sfx_count(0)
    variable new_fgm_count(0)
    variable new_sound_test_count(0)
    variable new_sfx_fgm_size(0)
    variable new_fgm_microcode_size(0)

    // Sample rate constants
    constant SAMPLE_RATE_32000(0x60)
    constant SAMPLE_RATE_16000(0x20)

    // FGM types
    constant FGM_TYPE_VOICE(0x00)
    constant FGM_TYPE_CHANT(0x01)
    constant FGM_TYPE_SLEEP(0x02)

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
        global variable new_sound_test_count(new_sound_test_count + 1)
        evaluate num(new_sample_count)
        evaluate sfx_num(new_sfx_count)
        evaluate fgm_num(new_fgm_count)
        evaluate st_num(new_sound_test_count)
        global define SOUND_NAME_{num}({name})
        global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}(ORIGINAL_SFX_FGM_COUNT - 1 + new_sfx_count)
        global evaluate SOUND_SFX_SOUND_ID_{sfx_num}(0x8141 + new_sample_count)
        global evaluate SOUND_SAMPLE_RATE_{sfx_num}({sample_rate})
        global evaluate SOUND_TYPE_FGM_{fgm_num}({fgm_type})
        global evaluate SOUND_TYPE_SFX_{sfx_num}({fgm_type})
        global evaluate SOUND_REVERB_{sfx_num}({reverb})
        global evaluate SOUND_TEST_FGM_ID_{st_num}({fgm_num})

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
        } else if {fgm_type} == FGM_TYPE_CHANT {
            global variable new_fgm_microcode_size(new_fgm_microcode_size + 0x13)
        } else {
            global variable new_fgm_microcode_size(new_fgm_microcode_size + 0x1D)
        }
        if {fgm_type} == FGM_TYPE_VOICE {
            global variable new_sfx_fgm_size(new_sfx_fgm_size + 0xD)
        } else if {fgm_type} == FGM_TYPE_CHANT {
            global variable new_sfx_fgm_size(new_sfx_fgm_size + 0xD)
        } else {
            global variable new_sfx_fgm_size(new_sfx_fgm_size + 0xA)
        }

        global define SOUND_LOOP_PARAMS_{num}(0x00000000)

        print "Added {SOUND_NAME_{num}}\nFGM_ID: 0x"; OS.print_hex(ORIGINAL_FGM_COUNT - 1 + {fgm_num}); print " (", ORIGINAL_FGM_COUNT - 1 + {fgm_num},")\n"
        print "Sound Test Voice ID: ", 244 + new_sound_test_count, "\n\n"
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
        global variable new_sound_test_count(new_sound_test_count + 1)
        evaluate num(new_sample_count)
        evaluate sfx_num(new_sfx_count)
        evaluate fgm_num(new_fgm_count)
        evaluate st_num(new_sound_test_count)
        global define SOUND_NAME_{num}({file_name})
        global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}(ORIGINAL_SFX_FGM_COUNT - 1 + new_sfx_count)
        global evaluate SOUND_SFX_SOUND_ID_{sfx_num}(0x8141 + new_sample_count)
        global define SOUND_FGM_MICROCODE_FILE_{fgm_num}({fgm_microcode_file})
        global define SOUND_SFX_MICROCODE_FILE_{sfx_num}({sfx_microcode_file})
        global evaluate SOUND_TEST_FGM_ID_{st_num}({fgm_num})

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
        print "Sound Test Voice ID: ", 244 + new_sound_test_count, "\n\n"
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
        global variable new_sound_test_count(new_sound_test_count + 1)
        evaluate fgm_num(new_fgm_count)
        evaluate st_num(new_sound_test_count)
        global define SOUND_FGM_MICROCODE_FILE_{fgm_num}({fgm_microcode_file})
        global variable new_fgm_microcode_size(new_fgm_microcode_size + {fgm_microcode_file_size})
        global evaluate SOUND_TEST_FGM_ID_{st_num}({fgm_num})

        if {sfx_id} == -1 {
            global variable new_sfx_count(new_sfx_count + 1)
            evaluate sfx_num(new_sfx_count)
            global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}(ORIGINAL_SFX_FGM_COUNT - 1 + new_sfx_count)
            global evaluate SOUND_SFX_SOUND_ID_{sfx_num}(0x8000|{sound_id})
            global define SOUND_SFX_MICROCODE_FILE_{sfx_num}({sfx_microcode_file})
            global variable new_sfx_fgm_size(new_sfx_fgm_size + {sfx_microcode_file_size})
        } else {
            global evaluate SOUND_SFX_FGM_INDEX_{fgm_num}({sfx_id})
        }

        print "Added {name}\nFGM_ID: 0x"; OS.print_hex(ORIGINAL_FGM_COUNT - 1 + {fgm_num}); print " (", ORIGINAL_FGM_COUNT - 1 + {fgm_num},")\n"
        print "Sound Test Voice ID: ", 244 + new_sound_test_count, "\n\n"
    }

    // @ Description
    // Increments fgm_id without adding to sound test and without adding a sample.
    macro reserve_fgm() {
        global variable new_fgm_count(new_fgm_count + 1)
        evaluate fgm_num(new_fgm_count)
        print "Reserved FGM_ID: 0x"; OS.print_hex(ORIGINAL_FGM_COUNT - 1 + {fgm_num}); print " (", ORIGINAL_FGM_COUNT - 1 + {fgm_num},")\n"
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
            if (moved_bank_table_slots > ORIGINAL_SAMPLE_COUNT) {
                variable moved_bank_table_slots(ORIGINAL_SAMPLE_COUNT)
            }

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

        predictors_moved:
        global variable predictors_moved_origin(origin())
        variable SPACE_REQUIRED((new_sample_count - 0x288) * 0x4) // need a word for each new sample that overflows
        variable total_predictors_size(0)
        define n(1)
        while total_predictors_size < SPACE_REQUIRED {
            read32   predictor_curr_pointer_info_{n}, "../roms/original.z64", PARAMETERS_MAP + 0x8 + (({n} - 1) * 0x10)
            read32   predictor_curr_pointer_{n}, "../roms/original.z64", CTL_TABLE + predictor_curr_pointer_info_{n} + 0x10
            read32   predictor_next_pointer_info_{n}, "../roms/original.z64", PARAMETERS_MAP + 0x8 + ({n} * 0x10)
            read32   predictor_next_pointer_{n}, "../roms/original.z64", CTL_TABLE + predictor_next_pointer_info_{n} + 0x10
            constant PREDICTOR_SIZE_{n}(predictor_next_pointer_{n} - predictor_curr_pointer_{n})
            variable total_predictors_size(total_predictors_size + PREDICTOR_SIZE_{n})
            evaluate n({n} + 1)
        }
        evaluate predictor_blocks({n})
        fill total_predictors_size, 0x00 // moved ones
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
        fill new_sound_test_count * 0x4, 0x00

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
        dh      ORIGINAL_SAMPLE_COUNT + new_sample_count

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
        define x(0)
        define y(0)
        while {n} < new_sample_count {
            // TODO: first two bytes should increment for each sound added until we get to 7F...
            // ...then it should increment the 0202 to 0303 for example and restart the first two at 0000
            if ({n} < (0x80 - 0x42)) {
                dw      0x42420202 + ({n} * 0x01010000)
            } else {
                dw      0x00000303 + ({x} * 0x01010000) + ({y} * 0x00000101)
                evaluate x({x}+1)
                if {x} > 0x7F {
                    evaluate x(0)
                    evaluate y({y}+1)
                }
            }
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
            } else if {fgm_type} == FGM_TYPE_CHANT {
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
            } else {
                dh  0xDE00
                db  0xD1 ; dh  {sfx_fgm_index}
                dh  0xD2FF
                dh  0xDC0A
                dh  0xD3C8
                dh  0xD2A4
                dh  0xD5FF
                db  0x77 ; dh {fgm_length}
                dh  0xD5FF
                db  0x77 ; dh {fgm_length}
                dh  0xD5FF
                db  0x77 ; dh {fgm_length}
                db  0xD0
                // size = 0x1D
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
            if !{defined SOUND_SFX_FGM_INDEX_{s}} {
                // skip
            } else if !{defined SOUND_FGM_MICROCODE_FILE_{s}} {
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
            } else if {fgm_type} == FGM_TYPE_CHANT {
                db      0x60                                        // always starts with 60
                dh      {sound_id}                                  // add the pointer to the sfx id we added
                db      {sample_rate}                               // set sample rate (0x20 = 16000 Hz, 0x60 = 32000 Hz)
                dw      0x306420FB
                dw      0x5A0B747F
                db      0x70
                // size = 0xD
            } else {
                db      0x60                                        // always starts with 60
                dh      {sound_id}                                  // add the pointer to the sfx id we added
                db      {sample_rate}                               // set sample rate (0x20 = 16000 Hz, 0x60 = 32000 Hz)
                dw      0xFB500A2C
                dh      0x6470
                // size = 0xA
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

        // now make room for adding more fgm_ids by moving some vanilla predictors
        define x(1)
        origin  predictors_moved_origin
        variable predictors_origin(origin())
        variable start(PREDICTORS)
        variable predictor_pc(pc() - PREDICTOR_PC)
        while {x} < {predictor_blocks} {
            origin  predictors_origin
            insert  "../roms/original.z64", start, PREDICTOR_SIZE_{x}
            variable start(start + PREDICTOR_SIZE_{x})
            variable new_offset(predictor_pc + predictor_curr_pointer_info_{x})
            variable predictors_origin(origin())

            // now fix the pointer to the predictors
            origin  PARAMETERS_MAP + 0x8 + (({x} - 1) * 0x10)
            dw      new_offset
            // now fix the pointer inside the predictors
            origin  predictors_origin - 0xC
            // if there are loop params, need to update the pointer
            if PREDICTOR_SIZE_{x} > 0xA8 {
                dw      new_offset - 0x30
            } else {
                dw 0
            }
            dw      new_offset + 0x18 - PREDICTOR_SIZE_{x}
            evaluate x({x} + 1)
        }

        // add new fgm_ids to our extended voice ID map table
        origin  extended_voice_map_table_origin
        define n(0)
        while {n} < new_sound_test_count {
            evaluate n({n}+1)
            dw      ORIGINAL_FGM_COUNT - 1 + {SOUND_TEST_FGM_ID_{n}}
        }

        // Extend Sound Test Voice numbers so we can test in game easier
        origin  0x188422
        dh      0xF4 + new_sound_test_count
        origin  0x18842A
        dh      0xF4 + new_sound_test_count
        origin  0x188436
        dh      0xF3 + new_sound_test_count
        origin  0x18829E
        dh      0xF3 + new_sound_test_count

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
    add_sound(Falco/sounds/70, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
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
    add_sound(YoungLink/sounds/YLSLEEP, SAMPLE_RATE_32000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Ganondorf/sounds/GNDSTUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/GND_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 0x10C)
    add_sound(DrMario/sounds/DRM_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 0x160)
    add_sound(DSamus/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
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
    add_sound(Wario/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
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
    add_sound(JMario/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 265)
    add_sound(JDK/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 254)
    add_sound(JLink/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 143)
    add_sound(JSamus/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 147)
    add_sound(JYoshi/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 293)
    add_sound(JKirby/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 204)
    add_sound(JFox/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 265)
    add_sound(JPika/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 198)
    add_sound(JLuigi/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 299)
    add_sound(JNess/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 294)
    add_sound(JFalcon/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 269)
    add_sound(JPuff/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 136)
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
    add_sound(JPuff/sounds/124_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x150)
    add_sound(JPuff/sounds/125_STUN, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(JPuff/sounds/126_HEAVY_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(JPuff/sounds/127_STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/ATTACKLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/ATTACK2LUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/ATTACK3LUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/CROWDCHANTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 158)
    add_sound(Lucas/sounds/DIZZYLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/DOWNSMASHLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/HURTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/JUMPLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/KOLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/LIFTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/PKFIRELUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/PKTHUNDERLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/PKTHUNDER2LUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/SLEEPLUCAS, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Lucas/sounds/STARKOLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/TEETERLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/UPSMASHLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Lucas/sounds/TAUNTLUCAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(ESamus/sounds/ANNOUNCER, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Lucas/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Marth/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/ATTACK_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/ATTACK_5, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/ATTACK_6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/DODGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/CROWD_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(Marth/sounds/TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/DEATH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Marth/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/USP_SFX, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 50, -1)
    add_sound(Marth/sounds/USP_VOICE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 20, -1)
    add_sound(Marth/sounds/COUNTER_SFX, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 80, -1)
    add_sound(Marth/sounds/COUNTER_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/VICTORY_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/VICTORY_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/VICTORY_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_fgm(MONSTER TIPPER, Marth/sounds/MONSTER_TIPPER_MICROCODE, 0x21, 0x8, -1, -1, -1)
    add_sound(Marth/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Marth/sounds/COUNTER_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/COUNTER_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_CHEER, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(Bowser/sounds/BOWSER_STUNNED, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_DAMAGED, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Bowser/sounds/BOWSER_STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_FOOTSTEP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_SMASH1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_SMASH2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_SMASH3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_SMASH4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_UPSPECIAL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Bowser/sounds/BOWSER_VICTORY_LAUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Bowser/sounds/BOWSER_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Bowser/sounds/BOWSER_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Bowser/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
	add_sound(GBowser/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
	add_sound(Bowser/sounds/BOWSER_ENTRY_LAUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Kirby/sounds/PHANTASM, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 120, -1)
    add_sound(Piano/sounds/PIANO_DAMAGE_HIGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_DEATH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_GULP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_THROW, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_SHOOT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_WARP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_DITTY_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 20, -1)
    add_sound(Piano/sounds/PIANO_DITTY_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 20, -1)
    add_sound(Piano/sounds/PIANO_DITTY_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 20, -1)
    add_sound(Piano/sounds/PIANO_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 20, -1)
    add_sound(Piano/sounds/PIANO_DAMAGE_LOW_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_DAMAGE_LOW_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_DAMAGE_MID_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_DAMAGE_MID_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Piano/sounds/PIANO_DAMAGE_MID_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_CHAINSAW_DSMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound_advanced(Conker Chainsaw, Conker/sounds/CONKER_CHAINSAW_JAB, Conker/sounds/CONKER_CHAINSAW_microcode, 0x13, Conker/sounds/CONKER_CHAINSAW_sfx_microcode, 0xD, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_sound(Conker/sounds/CONKER_DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_DAMAGE_HEAVY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_PAN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Conker/sounds/CONKER_SMASH1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_SMASH2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_SMASH3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_STARKO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_TECH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_fgm(ConkerPanQuiet, Conker/sounds/CONKER_PAN_QUIET_microcode, 0x11, 0x2A3, -1, -1, -1) //note: the sfx_id here and the length in the microcode are hard coded based on CONKER_PAN
    add_sound(Conker/sounds/CONKER_NSP1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_NSP2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_CHAINSAW_BEGIN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Conker/sounds/CONKER_CHAINSAW_END, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_STUNNED, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_DAMAGED, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_JUMP1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Wolf/sounds/WOLF_SMASH1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_SMASH2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_SMASH3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_STARKO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_SHIELD_BREAK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_TECH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Wolf/sounds/WOLF_TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_USMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(1p/sounds/TEAM, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(1p/sounds/GIANT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Mewtwo/sounds/CROWD_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(Mewtwo/sounds/VICTORY_LAUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/DEATH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x170)
    add_sound(Mewtwo/sounds/TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/SHADOW_BALL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/SFX_SHOOT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/SFX_DOUBLE_JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/SFX_TELEPORT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Mewtwo/sounds/SFX_DISABLE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_fgm(MewtwoEntry, Mewtwo/sounds/ENTRY_microcode, 0x28, 0x77, -1, -1, -1)
    add_sound(Conker/sounds/CONKER_TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Wolf/sounds/WOLF_CHEER, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(Conker/sounds/CONKER_ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Falco/sounds/STARFOX, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Piano/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/MULTIMAN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/CRUEL_MULTIMAN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_fgm(MewtwoCharge1, Mewtwo/sounds/CHARGE_1_fgm_microcode, 0x1B, -1, Mewtwo/sounds/CHARGE_1_sfx_microcode, 0xA8, 0xD)
    add_fgm(MewtwoCharge2, Mewtwo/sounds/CHARGE_2_fgm_microcode, 0x19, -1, Mewtwo/sounds/CHARGE_2_sfx_microcode, 0x1E, 0xD)
    add_fgm(MewtwoCharge3, Mewtwo/sounds/CHARGE_3_fgm_microcode, 0x19, -1, Mewtwo/sounds/CHARGE_3_sfx_microcode, 0x1E, 0xD)
    add_fgm(MewtwoCharge4, Mewtwo/sounds/CHARGE_4_fgm_microcode, 0x19, -1, Mewtwo/sounds/CHARGE_4_sfx_microcode, 0x1E, 0xD)
    add_fgm(MewtwoCharge5, Mewtwo/sounds/CHARGE_5_fgm_microcode, 0x19, -1, Mewtwo/sounds/CHARGE_5_sfx_microcode, 0x1D, 0xD)
    add_fgm(MewtwoCharge6, Mewtwo/sounds/CHARGE_6_fgm_microcode, 0x19, -1, Mewtwo/sounds/CHARGE_6_sfx_microcode, 0x1E, 0xD)
    add_fgm(MewtwoCharge7, Mewtwo/sounds/CHARGE_7_fgm_microcode, 0x19, -1, Mewtwo/sounds/CHARGE_7_sfx_microcode, 0x1E, 0xD)
    add_fgm(MewtwoCharge8, Mewtwo/sounds/CHARGE_8_fgm_microcode, 0x19, -1, Mewtwo/sounds/CHARGE_8_sfx_microcode, 0x18, 0xD)
    add_sound(sounds/misc/splash, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/gameboy_start_up, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marth/sounds/ENTRY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 50, -1)
    add_sound(Sonic/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(sounds/misc/sonic_bumper, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/triangle_bumper, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SPRING, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SPINDASH_CHARGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SPINDASH_ROLL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/HOMING_CHARGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/HOMING_ATTACK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_SKID, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SPINDASH_CHARGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SPRING, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SONIC_JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SONIC_SKID, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SONIC_SPIN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SPINDASH_ATTACK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SONIC_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_ATTACK1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_ATTACK2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_ATTACK3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/badnik_destroy, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_FSMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_SHIELDBREAKSTUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Sonic/sounds/SONIC_STARKO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_VICTORY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_ROLL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_TECH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_HEAVYLIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/cannon_turn, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/cannon_shoot, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/all_star, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/homerun_contest, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/twelve_character_battle, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, -1)
    add_sound(Sonic/sounds/TAILSFLY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/shrinkray, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/SONIC_JUMP_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sonic/sounds/CLASSIC_SONIC_JUMP_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(SSonic/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
	add_sound(Sonic/sounds/SONIC_TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/rain, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/chainchomp, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/mk64_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/mk64_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/mk64_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/mk64_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/mk64_5, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/deku_nut, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/deku_nut_freeze, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/CROWD_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 375)
    add_sound(Sheik/sounds/HURT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/DEATH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/NSP_CHARGE, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/NSP_THROW, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Sheik/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/USP_POOF, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/VICTORY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/VOICE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/HEAVY_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/JAB, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/franklin_badge, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/onett/honk, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Sheik/sounds/SHIELD_BREAK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
	add_sound(Marina/sounds/SHAKE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/HOI, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/YAHOO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/HO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/YAH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/YAAAH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/TORIYA, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/PAIN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/STARKO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/SIGH, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
	add_sound(Marina/sounds/THRUSTER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
	add_sound(Marina/sounds/STUNLOOP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(NBowser/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NDrMario/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NLucas/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NSheik/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NSonic/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NWario/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NWolf/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Dedede/sounds/USP_INITIAL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/USP_LAND, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/Pitfall_Jump, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/CROWD_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 469)
    add_sound(sounds/misc/pitfall_vanish, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/USP_LAND_VOICE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marina/sounds/SHAKE_SHAKE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/JUMP_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/JUMP_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/JUMP_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/USP_BONK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_HEAVY_GET, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_HURT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_LAUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Dedede/sounds/VOICE_STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_USP_RISE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/WADDLE_JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/WADDLE_STEP_L, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/WADDLE_STEP_R, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/WADDLE_THROW, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/VOICE_ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Dedede/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NMarina/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Marina/sounds/VICTORY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(1p/sounds/TINY_TEAM, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(YoungLink/sounds/BOMBCHU, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/tripstart, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marina/sounds/SFX_POP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marina/sounds/SFX_SHAKE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marina/sounds/SFX_ENTRY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/JUMP_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/THERE_GOES, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ONIX, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/SNORLAX, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GOLDEEN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/MEOWTH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/CHARIZARD, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/BEEDRILL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/BLASTOISE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/CHANSEY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/STARMIE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/HITMONLEE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KOFFING, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/CLEFAIRY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/MEW, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/NORMAL_KO_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/NORMAL_KO_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/NORMAL_KO_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/NORMAL_KO_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/QUICK_KO_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/QUICK_KO_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/HEAVY_PICKUP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/ROLL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/TECH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/CHAIN_PIPE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/CHAIN_PIPE_END, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/LONG_KO_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/LONG_KO_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/BURN_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/FACE_EACH_OTHER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/BATTLE_POSES, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/FIGHTING_POSES, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ASLEEP_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ASLEEP_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/SING, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ASLEEP_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ATTACK_CONTINUING, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/onett/car, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_5, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_7, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_8, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_9, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_10, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_11, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_HIGH_12, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_MID_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_MID_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_MID_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_MID_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_MID_5, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/KNOCKBACK_MID_6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/DAMAGE_EARLY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/DAMAGE_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/DAMAGE_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/DAMAGE_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/DAMAGE_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_5, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/BURN_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/CLOSE_MATCH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/TIME, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/THUNDER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/TELEPORT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/DISABLE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/FIRE_PUNCH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/BUILDING_ENERGY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/HUNG_TOUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/COUNTER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/DAMAGE_LITTLE_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/POUND, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/QUICK_ATTACK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/REST_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/REST_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/TIME_UP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/SEISMIC_TOSS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/footstool, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/RECOVERY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/CLANG, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/STUN_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/STUN_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/FLAMETHROWER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GYM_LEADER_CASTLE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/OPENING_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/SLASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/TEAM_KO_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/TEAM_KO_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_7, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/GENERAL_8, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/OPENING_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/stadium/OPENING_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/goldengunshoot, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/goldengunnoammo, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/RAKU_SHOU, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/ATTACK_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/HEAVY_PICKUP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/ROLL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/TECH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/STUN_INITIAL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/LETS_GO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(NFalco/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NGanondorf/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(YoungLink/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/ATTACK_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/HEAVY_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/DEATH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/DODGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/SCREAM, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/VICTORY_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/VICTORY_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Peppy/sounds/OKAY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/TECH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/SHIELD_BREAK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/TRUST_YER_INSTINCTS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(Peppy/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/BLASTER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/YERMINE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Slippy/sounds/TEETER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/BARREL_ROLL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Peppy/sounds/TAUNT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(SLIPPY/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(PEPPY/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/DOUBLE_TROUBLE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/DREAM_TEAM, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/ECHOES, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/HYLIAN_HEROES, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/POCKET_MONSTERS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/PSI_ROCKERS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Goemon/sounds/CLOUD_SPAWN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/CLOUD_DESPAWN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/MASTERHAND, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(DSamus/sounds/CROWD_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 179)
    add_sound(Banjo/sounds/NSP_FORWARD, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/NSP_BACKWARD, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/EGG_BOUNCE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/JUMP_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x150)
    add_sound(Banjo/sounds/HEAVY_LIFT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/JUMP_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NDSamus/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Banjo/sounds/SHIELD_BREAK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(MLuigi/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Ebi/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Ebi/sounds/ATTACK_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/ATTACK_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/ATTACK_3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/ATTACK_4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/HEAVY_PICKUP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/JUMP_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/STUN_INITIAL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/TECH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/ROLL, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/AUDIENCE_LAUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/LETS_GO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/THROW, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/boo_laugh, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 60, -1)
    add_sound(sounds/misc/chargesmash, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(sounds/misc/cloak, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/decloak, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/KAZOOIE_FAIR_1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/KAZOOIE_FAIR_2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/BREEGUL_BASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/BEAK_BARGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/BEAK_BUSTER_START, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/BEAK_BUSTER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/Yellow_Team, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/MYSTICAL_NINJAS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Banjo/sounds/BANJO_ANNOYED, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/KAZOOIE_LAUGH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/USP_ATTACK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/USP_JUMP, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/bc_time, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/GU_HUH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/ENTRY, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/CROWD_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 420)
    add_sound(Banjo/sounds/KAZOOIE_USMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Goemon/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x150)
    add_sound(NMarth/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NMewtwo/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Banjo/sounds/KAZOOIE_DSMASH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Banjo/sounds/YUH_OH, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(NDedede/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(1p/sounds/METAL_MARIO_BROTHERS, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NYoungLink/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(DragonKing/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(DragonKing/sounds/KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DragonKing/sounds/STAR_KO, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DragonKing/sounds/DAMAGE, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DragonKing/sounds/SMASH1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DragonKing/sounds/SMASH2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DragonKing/sounds/SMASH3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DragonKing/sounds/SHIELDBREAK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(CONKER/sounds/CONKER_CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 336)
    add_sound(sounds/pokemon/Blastoise_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Chansey_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Charmander_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Clefairy_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Goldeen_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Koffing_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Snorlax1_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Snorlax2_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/pokemon/Venusaur_J, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ebi/sounds/CAMERA, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(GOEMON/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 313)
    add_sound(sounds/misc/pwing, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/pwing_pickup, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/pwing_end, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/pwing_low, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(1p/sounds/RARE_PAIR, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(sounds/misc/thunderball_shoot, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/cacodemon_death, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Ganondorf/sounds/GNDSLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x180)
    add_sound(DragonKing/sounds/STUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(DragonKing/sounds/SLEEP, SAMPLE_RATE_16000, FGM_TYPE_SLEEP, 0, 0x120)
    add_sound(NConker/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(Ebi/sounds/EBI_SELECT, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(NGoemon/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(NBanjo/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 40, -1)
    add_sound(sounds/misc/song_of_time, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/meow, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/woof, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/DonkeyD, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(sounds/misc/DonkeyK, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0, -1)
    add_sound(Marina/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 313)
    add_sound(EPuff/sounds/ANNOUNCER, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 40, -1)
    add_sound(EPuff/sounds/POUND, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/SMASH1, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/SMASH2, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/SMASH3, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/SING, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound_advanced(Pummeluff Rest, EPuff/sounds/REST_INITIAL, EPuff/sounds/REST_fgm_microcode, 0x18, EPuff/sounds/REST_sfx_microcode, 0xC, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_sound_advanced(Pummeluff Sleep, EPuff/sounds/SLEEP, EPuff/sounds/SLEEP_fgm_microcode, 0x23, EPuff/sounds/REST_SNORE_sfx_microcode, 0xC, OS.FALSE, 0, 0, 0, OS.FALSE)
    add_sound(EPuff/sounds/AWAKEN, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/DAMAGE, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/TAUNT, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/STAR_KO, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/STUN, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0, -1)
    add_sound(EPuff/sounds/CHANT, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0, 291)
    add_fgm(Pummeluff Sleep Snore, EPuff/sounds/REST_SNORE_fgm_microcode, 0x15, 0x486, -1, -1, 0x3F0)

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
        constant ELECTRIC_S(0x16)
        constant ELECTRIC_M(0x17)
        constant ELECTRIC_L(0x18)
        constant FIRE_S(0x19)
        constant FIRE_M(0x1A)
        constant FIRE_L(0x1B)
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

    // pokemon voices
    scope pokemon {
        scope u {
            constant ONIX(0x136)
            constant SNORLAX_1(0x138)
            constant SNORLAX_2(0x137)
            constant GOLDEEN(0x143)
            // constant MEOWTH // (no voice)
            constant CHARIZARD(0x13D)
            constant BEEDRILL_1(0x140)
            constant BEEDRILL_2(0x141)
            constant BLASTOISE(0x139)
            constant CHANSEY(0x13A)
            constant STARMIE(0x142)
            constant HITMONLEE_1(0x13E)
            constant HITMONLEE_2(0x13F)
            constant KOFFING(0x135)
            constant CLEFAIRY(0x13C)
            constant MEW(0x13B)
            // Saffron pokemon
            constant SAF_VENUSAUR(0x228)
            constant SAF_CHARMANDER(0x229)
            constant SAF_PORYGON(0x22C)
            constant SAF_CHANSEY(0x22A)
        }
        scope j {
            constant SNORLAX_1(0x553)
            constant SNORLAX_2(0x554)
            constant GOLDEEN(0x551)
            constant BLASTOISE(0x54D)
            constant CHANSEY(0x54E)
            constant KOFFING(0x552)
            constant CLEFAIRY(0x550)
            constant SAF_VENUSAUR(0x555)
            constant SAF_CHARMANDER(0x54F)
        }
    }

    constant NONE(0x2B7)
    constant CLOUD_FADE(0x113)          // Yoshis Story

    // character select screen
    scope announcer {

        scope names {
            constant STARFOX(0x03C5)
            constant DOUBLE_TROUBLE(1274)
            constant DREAM_TEAM(1275)
            constant ECHOES(1276)
            constant HYLIAN_HEROES(1277)
            constant POCKET_MONSTERS(1278)
            constant PSI_ROCKERS(1279)
            constant FIGHTING_POLYGON_TEAM(482)
            constant MASTERHAND(1282)
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
            constant BOWSER(882)
            constant GBOWSER(883)
            constant WOLF(938)
            constant CONKER(964)
            constant PIANO(966)
            constant MEWTWO(944)
            constant MARTH(864)
            constant SONIC(980)
            constant SSONIC(1022)
            constant SHEIK(1033)
            constant MARINA(1055)
            constant NBOWSER(1070)
            constant NDR_MARIO(1071)
            constant NLUCAS(1072)
            constant NSHEIK(1073)
            constant NSONIC(1074)
            constant NWARIO(1075)
            constant NWOLF(1076)
            constant DEDEDE(1105)
            constant GOEMON(1220)
            constant NMARINA(1106)
            constant SLIPPY(1272)
            constant PEPPY(1273)
            constant NFALCO(1235)
            constant NGANONDORF(1236)
            constant BANJO(1298)
            constant NDSAMUS(1299)
            constant MLUIGI(1301)
            constant EBI(1302)
            constant NMARTH(1341)
            constant NMTWO(1342)
            constant NDEDEDE(1345)
            constant NYLINK(1347)
            constant DRAGONKING(1348)
            constant NCONKER(1378)
            constant NGOEMON(1380)
            constant NBANJO(1381)
            constant EPUFF(1388)
        }

        scope css {
            constant CHOOSE_YOUR_CHARACTER(479)
            constant FREE_FOR_ALL(512)
            constant TEAM_BATTLE(526)
            constant TRAINING_MODE(530)
            constant ALLSTAR(1014)
            constant HRC(1015)
            constant TWELVECB(1016)
        }

        scope team {
            constant BLUE(475)
            constant GREEN(491)
            constant RED(510)
            constant YELLOW(1329)
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

        scope pokemon {
            constant ONIX(0x45B)
            constant SNORLAX(0x45C)
            constant GOLDEEN(0x45D)
            constant MEOWTH(0x45E)
            constant CHARIZARD(0x45F)
            constant BEEDRILL(0x460)
            constant BLASTOISE(0x461)
            constant CHANSEY(0x462)
            constant STARMIE(0x463)
            constant HITMONLEE(0x464)
            constant KOFFING(0x465)
            constant CLEFAIRY(0x466)
            constant MEW(0x467)
        }

    }

}

} // __FGM__
