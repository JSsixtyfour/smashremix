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
        insert SOUND_RAW_{num}, "../src/{SOUND_NAME_{num}}.aifc", 0x100
    }

    // @ Description
    // Adds a new sound file to the sound bank.
    // @ Arguments
    // name - Name of the file located in ../src, without the extension and including directory e.g. DrMario/sounds/B65
    // sample rate - The desired sample rate, for now 16000 Hz and 32000 Hz are supported
    // fgm_type - The type of sound, for now Voice and Chant are supported, with Chant including crowd noise
    // fgm_length - The length of the sound, for now only suppored for chants
    macro add_sound(name, sample_rate, fgm_type, fgm_length) {
        global variable new_sample_count(new_sample_count + 1)
        evaluate num(new_sample_count)
        global define SOUND_NAME_{num}({name})
        global evaluate SOUND_SAMPLE_RATE_{num}({sample_rate})
        global evaluate SOUND_TYPE_{num}({fgm_type})
        global evaluate SOUND_LENGTH_{num}({fgm_length})
        print "Added {SOUND_NAME_{num}}\nFGM_ID: 0x"; OS.print_hex(ORIGINAL_FGM_COUNT - 1 + {num}); print " (", ORIGINAL_FGM_COUNT - 1 + {num},")\n"
        print "Sound Test Voice ID: ", 244 + {num}, "\n\n"
    }

    // @ Description
    // Adds a new FGM ID
    // TODO: it would be nice to be able to add new FGM_IDs referencing existing sounds
    macro add_fgm() {

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
        pullvar base, origin

        sfx_fgm_table_extended:
        global variable sfx_fgm_table_extended_origin(origin())
        constant SPACE_REQUIRED(new_sample_count * 0x4) // need a word for each new sound
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
        fill new_sample_count * 0x3D, 0x00 // TODO: maybe not all should be 0x3D?
        OS.align(4)

        fgm_microcode_extended:
        global variable fgm_microcode_extended_origin(origin())
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
        fill new_sample_count * 0x1C, 0x00 // TODO: maybe not all should be 0x1C?
        OS.align(4)

        extended_voice_map_table:
        global variable extended_voice_map_table_origin(origin())
        fill new_sample_count * 0x4, 0x00

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
            dw      0x0000
            // TODO: predictors can be 0xA8 or 0xD8, so need to account for that properly
            // For now assuming always 0xA8
            dw      predictors_extended - CTL_TABLE_PC + ({n} * 0xA8)
            dw      0x0000

            evaluate n({n}+1)
        }

        // update fgm bank size
        origin  SFX_FGM_MAP
        dw      0x01D0 + new_sample_count

        // update fgm bank size
        origin  FGM_MICROCODE_MAP
        dw      0x02B7 + new_sample_count

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

            if {fgm_type} == FGM_TYPE_VOICE {
                dh  0xDE00
                db  0xD1              // Next halfword is pointer to SFX_ID
                dh  {sfx_fgm_index}
                dh  0xD2FF
                db  0xD3
                dw  0x55D224D5
                dw  0xEC6F64D3
                dw  0x4B6F64D3
                dw  0x416F64D3
                dw  0x3C6F1ED0
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
                // fill rest of block with 0x00s for now
                fill 0x6, 0x00
            }
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
        while {n} < new_sample_count {
            // add the new fgm_id
            origin  FGM_MICROCODE + ({n} * 4)
            dw      microcode_pc - FGM_MICROCODE_MAP_PC

            // add the microcode
            origin microcode_origin
            evaluate s({n}+1)
            add_microcode(ORIGINAL_SFX_FGM_COUNT  + {n}, {SOUND_TYPE_{s}}, {SOUND_LENGTH_{s}})
            variable microcode_origin(origin())
            variable microcode_pc(pc())
            evaluate n({n}+1)
        }

        // @ Description
        // Adds SFX to FGM blocks
        // TODO: set up with more arguments once we understand this better
        // @ Arguments
        // sfx_index - The index in the SFX table
        // sample_rate - Sample of the SFX, for now 16000 Hz and 32000 Hz are supported.
        // fgm_type - The type of sound, either Voice or Chant
        macro add_sfx_fgm(sfx_index, sample_rate, fgm_type) {
            // TODO: May not always use 0x3C as the block size
            // Block size of 0x3C is no longer filled
            if {fgm_type} == FGM_TYPE_VOICE {
                db      0x60                                        // always starts with 60
                dh      {sfx_index}                                 // add the pointer to the sfx id we added
                db      {sample_rate}                               // set sample rate (0x20 = 16000 Hz, 0x60 = 32000 Hz)
                dw      0xFB500564
                dw      0x05690574
                dw      0x080A7208
                dw      0x19690832
                dw      0x5F083255
                dw      0x08324608
                dw      0x3C3C083C
                dw      0x32700000
            } else {
                db      0x60                                        // always starts with 60
                dh      {sfx_index}                                 // add the pointer to the sfx id we added
                db      {sample_rate}                               // set sample rate (0x20 = 16000 Hz, 0x60 = 32000 Hz)
                dw      0x306420FB
                dw      0x5A0B747F
                dw      0x70000000
                fill    0x14, 0x00
            }
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
        while {n} < new_sample_count {
            // add the new sfx_fgm_id
            origin  SFX_FGM_TABLE + ({n} * 4)
            dw      sfx_fgm_pc - SFX_FGM_MAP_PC

            // add the sfx to fgm block
            origin sfx_fgm_origin
            evaluate s({n}+1)
            add_sfx_fgm(0x8142 + {n}, {SOUND_SAMPLE_RATE_{s}}, {SOUND_TYPE_{s}})
            variable sfx_fgm_origin(origin())
            variable sfx_fgm_pc(pc())
            evaluate n({n}+1)
        }

        // add voice ID 244's fgm_id to our extended voice ID map table
        origin  extended_voice_map_table_origin
        define n(0)
        while {n} < new_sample_count {
            dw      ORIGINAL_FGM_COUNT + {n}
            evaluate n({n}+1)
        }

        // Extend Sound Test Voice numbers so we can test in game easier
        origin  0x188422
        dh      0xF4 + new_sample_count
        origin  0x18842A
        dh      0xF4 + new_sample_count
        origin  0x188436
        dh      0xF3 + new_sample_count
        origin  0x18829E
        dh      0xF3 + new_sample_count

        pullvar base, origin
        OS.align(4)
    }

    // Add the sounds here
    add_sound(Ganondorf/sounds/53 deflectsound2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0) // PLACEHOLDER: id 2B7 has issues in-game
    add_sound(Ganondorf/sounds/53 deflectsound2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/54 hurtcut3, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/55 hurt2cut2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/56 attacklike6cut3 seems unused, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/57 middle size attackcut6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/58 attacklike2cut7, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/GNDWARLOCKPUNCH1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/GNDWARLOCKPUNCH2, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/5C Goodattacksound, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/5D attacklike6, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/5E shortenedlaugh, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/5F attacklike5cut4, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/62 deathlikecut1, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(DrMario/sounds/65, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(DrMario/sounds/B5, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/FALCO_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0x8157)
    add_sound(Falco/sounds/66, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/67, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/68, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/69, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/6a, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/6B, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/6C, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/6D, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/6E, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/6F, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/70, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/71, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/72, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Falco/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/YLINK_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0x8101)
    add_sound(YoungLink/sounds/8A2, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/8B Hup!short3, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/8C5, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/8D2, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/8E2, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/8F, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/90, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/91, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/92, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/93, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/95, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/yltaunt, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/96, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(DrMario/sounds/ANNOUNCER, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/YLTAUNTDRINK, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(YoungLink/sounds/YLSLEEP, SAMPLE_RATE_32000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/GNDSTUN, SAMPLE_RATE_16000, FGM_TYPE_VOICE, 0x0)
    add_sound(Ganondorf/sounds/GND_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0x810C)
    add_sound(DrMario/sounds/DRM_CROWD, SAMPLE_RATE_16000, FGM_TYPE_CHANT, 0x8160)

    // This is always last
    write_sounds()

    print "========================================================================== \n"

    // item sounds
    scope item {
        constant BAT(52)
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
