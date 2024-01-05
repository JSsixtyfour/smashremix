// CharacterDataScreen.asm
if !{defined __CharacterDataScreen__} {
define __CharacterDataScreen__()

include "Color.asm"
include "Global.asm"
include "OS.asm"
include "String.asm"

// @ Description
// Character Data Screen expanded to include Remix fighters
scope CharacterDataScreen {

    constant TABLE_ORIGIN(0x1622A0)    // 80136250
    constant EXTENDED_BIOS_POINTER(0x80136A88)
    constant EXTENDED_IMAGES_POINTER(0x80136A8C)

    constant USP(0)
    constant NSP(1)
    constant DSP(2)
    constant JAB(3)

    variable new_characters(0)
    variable action_count(0)
    variable jab_action_counts(0)
    variable action_type(USP)

    macro add_char_to_data_screen(name, bio_offset, unknown2, unknown3, name_X, name_Y, name_offset, works_offset, nsp_offset, dsp_offset, usp_offset, use_existing_special_actions, special_char, use_existing_jab_actions, jab_char) {
        evaluate n(new_characters)
        global define DATA_SCREEN_CHAR_{n}({name})
        global define DATA_SCREEN_CHAR_{n}_ID({n} + 12)
        global define DATA_SCREEN_CHAR_{n}_BIO_OFFSET({bio_offset} + 0x30)
        global define DATA_SCREEN_CHAR_{n}_UNKNOWN2({unknown2})
        global define DATA_SCREEN_CHAR_{n}_UNKNOWN3({unknown3})
        global define DATA_SCREEN_CHAR_{n}_NAME_X({name_X})
        global define DATA_SCREEN_CHAR_{n}_NAME_Y({name_Y})
        global define DATA_SCREEN_CHAR_{n}_NAME_OFFSET({name_offset} + 0x10)
        global define DATA_SCREEN_CHAR_{n}_WORKS_OFFSET({works_offset} + 0x10)
        global define DATA_SCREEN_CHAR_{n}_NSP_OFFSET({nsp_offset} + 0x10)
        global define DATA_SCREEN_CHAR_{n}_DSP_OFFSET({dsp_offset} + 0x10)
        global define DATA_SCREEN_CHAR_{n}_USP_OFFSET({usp_offset} + 0x10)

        if ({use_existing_special_actions} == 1) {
            global define DATA_SCREEN_CHAR_{n}_SPECIAL_ACTION_POINTER({special_char})
        }

        if ({use_existing_jab_actions} == 1) {
            global define DATA_SCREEN_CHAR_{n}_JAB_ACTION_POINTER({jab_char})
        }

        // increment counter
        global variable new_characters(new_characters + 1)

        // reset action counts
        global variable action_count(0)
        global variable jab_action_count(1)
        global variable action_type(USP)
    }

    macro set_action(type, action, frames, flags) {
        evaluate n(new_characters - 1)
        evaluate prev_type(action_type)
        evaluate t({type})

        if {t} != JAB {
            if {t} != {prev_type} {
                // changed action type, so reset action_count
                global variable action_count(0)
                global variable action_type({t})
            }
            evaluate i(action_count)

            global define DATA_SCREEN_CHAR_{n}_{type}_{i}_ACTION({action})
            global define DATA_SCREEN_CHAR_{n}_{type}_{i}_FRAMES({frames})
            global define DATA_SCREEN_CHAR_{n}_{type}_{i}_FLAGS({flags})

            global variable action_count(action_count + 1)
        } else {
            evaluate i(jab_action_count)

            global define DATA_SCREEN_CHAR_{n}_JAB_{i}_ACTION({action})
            global define DATA_SCREEN_CHAR_{n}_JAB_{i}_FRAMES({frames})
            global define DATA_SCREEN_CHAR_{n}_JAB_{i}_FLAGS({flags})

            global variable jab_action_count(jab_action_count + 1)

        }
    }

    macro extend_tables() {
        // character id

        // originally, we copied the existing table
        // id_table:
        // OS.copy_segment(TABLE_ORIGIN, 0x30)
        evaluate n(0)
        while {n} < new_characters {
            global evaluate CHAR_ID_{n}(Character.id.{DATA_SCREEN_CHAR_{n}})
            // dw {CHAR_ID_{n}}
            evaluate n({n} + 1)
        }

        id_table:
        // Mario
        dw Character.id.MARIO
        dw Character.id.LUIGI
        dw Character.id.BOWSER
        dw Character.id.DRM
        // DK
        dw Character.id.DK
        // Wario
        dw Character.id.WARIO
        // Zelda
        dw Character.id.LINK
        dw Character.id.YLINK
        dw Character.id.SHEIK
        dw Character.id.GND
        // Metroid
        dw Character.id.SAMUS
        dw Character.id.DSAMUS
        // Yoshi
        dw Character.id.YOSHI
        // Kirby
        dw Character.id.KIRBY
        dw Character.id.DEDEDE
        // Starfox
        dw Character.id.FOX
        dw Character.id.FALCO
        dw Character.id.WOLF
        // Pokemon
        dw Character.id.PIKACHU
        dw Character.id.JIGGLYPUFF
        dw Character.id.MTWO
        // F-Zero
        dw Character.id.CAPTAIN
        dw Character.id.NESS
        dw Character.id.LUCAS
        // Fire Emblem
        dw Character.id.MARTH
        // Third party (sorting by year of appearance)
        dw Character.id.GOEMON
        dw Character.id.SONIC
        dw Character.id.BANJO
        dw Character.id.CONKER
        dw Character.id.MARINA

        // This table is used to map character ID to data screen ID
        scope character_id_to_data_screen_id_table: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0x30, 0x30)
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
        }

        // bio image offsets
        scope biography_offsets: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0x60, 0x30)
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
            // Marios = 0x0000ACA8
        }

        // ?
        scope unknown_table_2: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0xC0, 0x30)
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
        }

        // ??
        scope unknown_table_3: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0xF0, 0x30)
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
        }

        // float32 x, y
        scope fighter_name_coordinates: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0x120, 0x60)
            // mario = (33, 50)
            // pika = (23, 50)
            fill ((Character.NUM_CHARACTERS - 12) * 8), 0
        }

        // image offsets
        scope name_offsets: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0x180, 0x30)
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
        }

        // image offsets
        scope works_offsets: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0x1B0, 0x30)
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
        }

        // The pointers point to a table of size 0x120.
        // The entries are 0xC in length:
        //   - 0x0000 = action
        //   - 0x0004 = number of frames
        //   - 0x0008 = argument 4 for the change action routine
        // The table is really 3 sub tables of size 0x60: USP, NSP, DSP.
        // The necessary actions are added, then ends with idle.
        // The rest of each sub block is filled with: 0x000A2C2A 0x00000001 0x00000000
        scope special_action_pointers: {
            constant ORIGIN(origin())

            constant MARIO(0x801340B0)
            constant FOX(MARIO + (0x120 * 1))
            constant DK(MARIO + (0x120 * 2))
            constant SAMUS(MARIO + (0x120 * 3))
            constant LUIGI(MARIO + (0x120 * 4))
            constant LINK(MARIO + (0x120 * 5))
            constant YOSHI(MARIO + (0x120 * 6))
            constant FALCON(MARIO + (0x120 * 7))
            constant KIRBY(MARIO + (0x120 * 8))
            constant PIKACHU(MARIO + (0x120 * 9))
            constant JIGGLYPUFF(MARIO + (0x120 * 10))
            constant NESS(MARIO + (0x120 * 11))

            OS.copy_segment(TABLE_ORIGIN + 0x1E0, 0x30)
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
        }

        // image offsets
        scope special_attack_offsets: {
            constant ORIGIN(origin())
            OS.copy_segment(TABLE_ORIGIN + 0x210, 0x90)
            fill ((Character.NUM_CHARACTERS - 12) * 0xC), 0
        }

        // The pointers point to a table of size 0x60.
        // Originally, this table didn't exist.
        // The entries are 0xC in length:
        //   - 0x0000 = action
        //   - 0x0004 = number of frames
        //   - 0x0008 = argument 4 for the change action routine
        // The first entry is always Jab1
        // The necessary actions for Jab2, JabLoop, etc. are added, then ends with idle.
        // The rest of each block is filled with: 0x000A2C2A 0x00000001 0x00000000
        scope jab_action_pointers: {
            constant ORIGIN(origin())

            constant MARIO(0x80135DA8)
            constant FOX(MARIO + (0x60 * 1))
            constant DK(MARIO + (0x60 * 2))
            constant SAMUS(MARIO + (0x60 * 3))
            constant LUIGI(MARIO + (0x60 * 4))
            constant LINK(MARIO + (0x60 * 5))
            constant YOSHI(MARIO + (0x60 * 6))
            constant FALCON(MARIO + (0x60 * 7))
            constant KIRBY(MARIO + (0x60 * 8))
            constant PIKACHU(MARIO + (0x60 * 9))
            constant JIGGLYPUFF(MARIO + (0x60 * 10))
            constant NESS(MARIO + (0x60 * 11))

            dw MARIO
            dw FOX
            dw DK
            dw SAMUS
            dw LUIGI
            dw LINK
            dw YOSHI
            dw FALCON
            dw KIRBY
            dw PIKACHU
            dw JIGGLYPUFF
            dw NESS
            fill ((Character.NUM_CHARACTERS - 12) * 4), 0
        }

        evaluate n(0)
        while {n} < new_characters {
            if !{defined DATA_SCREEN_CHAR_{n}_SPECIAL_ACTION_POINTER} {
                special_action_table_{n}:
                evaluate i(0)
                evaluate j(0)
                evaluate needs_idle(0)
                define type(USP)
                while {i} < 24 {
                    if !{defined DATA_SCREEN_CHAR_{n}_{type}_{j}_ACTION} {
                        if ({needs_idle} > 0) {
                            dw 0x0002000A, 0x0000001E, 0x00000000 // idle
                            evaluate needs_idle(0)
                        } else {
                            dw 0x000A2C2A, 0x00000001, 0x00000000 // filler
                        }
                    } else {
                        dw (0x00020000 + {DATA_SCREEN_CHAR_{n}_{type}_{j}_ACTION})
                        dw {DATA_SCREEN_CHAR_{n}_{type}_{j}_FRAMES}
                        dw {DATA_SCREEN_CHAR_{n}_{type}_{j}_FLAGS}
                        evaluate needs_idle(1)
                    }
                    evaluate i({i} + 1)
                    evaluate j({j} + 1)
                    if ({i} == 8) {
                        define type(NSP)
                        evaluate j(0)
                    } else if ({i} == 16) {
                        define type(DSP)
                        evaluate j(0)
                    }
                }
            }
            evaluate n({n} + 1)
        }

        evaluate n(0)
        while {n} < new_characters {
            if !{defined DATA_SCREEN_CHAR_{n}_JAB_ACTION_POINTER} {
                jab_action_table_{n}:
                dw 0x000200BE, 0x0000029A, 0x00000000 // first action is always jab 1

                evaluate i(1)
                evaluate needs_idle(0)
                while {i} < 8 {
                    if !{defined DATA_SCREEN_CHAR_{n}_JAB_{i}_ACTION} {
                        if ({needs_idle} > 0) {
                            dw 0x0002000A, 0x0000001E, 0x00000000 // idle
                            evaluate needs_idle(0)
                        } else {
                            dw 0x000A2C2A, 0x00000001, 0x00000000 // random
                        }
                    } else {
                        dw (0x00020000 + {DATA_SCREEN_CHAR_{n}_JAB_{i}_ACTION})
                        dw {DATA_SCREEN_CHAR_{n}_JAB_{i}_FRAMES}
                        dw {DATA_SCREEN_CHAR_{n}_JAB_{i}_FLAGS}
                        evaluate needs_idle(1)
                    }
                    evaluate i({i} + 1)
                }
            }
            evaluate n({n} + 1)
        }

        pushvar origin, base

        evaluate n(0)
        while {n} < new_characters {
            origin character_id_to_data_screen_id_table.ORIGIN + ({CHAR_ID_{n}} * 4)
            dw {DATA_SCREEN_CHAR_{n}_ID}

            origin biography_offsets.ORIGIN + ({CHAR_ID_{n}} * 4)
            dw {DATA_SCREEN_CHAR_{n}_BIO_OFFSET}

            origin unknown_table_2.ORIGIN + ({CHAR_ID_{n}} * 4)
            dw {DATA_SCREEN_CHAR_{n}_UNKNOWN2}

            origin unknown_table_3.ORIGIN + ({CHAR_ID_{n}} * 4)
            dw {DATA_SCREEN_CHAR_{n}_UNKNOWN3}

            origin fighter_name_coordinates.ORIGIN + ({CHAR_ID_{n}} * 8)
            float32 {DATA_SCREEN_CHAR_{n}_NAME_X}
            float32 {DATA_SCREEN_CHAR_{n}_NAME_Y}

            origin name_offsets.ORIGIN + ({CHAR_ID_{n}} * 4)
            dw {DATA_SCREEN_CHAR_{n}_NAME_OFFSET}

            origin works_offsets.ORIGIN + ({CHAR_ID_{n}} * 4)
            dw {DATA_SCREEN_CHAR_{n}_WORKS_OFFSET}

            origin special_action_pointers.ORIGIN + ({CHAR_ID_{n}} * 4)
            if !{defined DATA_SCREEN_CHAR_{n}_SPECIAL_ACTION_POINTER} {
                dw special_action_table_{n}
            } else {
                dw special_action_pointers.{DATA_SCREEN_CHAR_{n}_SPECIAL_ACTION_POINTER}
            }

            origin special_attack_offsets.ORIGIN + ({CHAR_ID_{n}} * 0xC)
            dw {DATA_SCREEN_CHAR_{n}_USP_OFFSET}
            dw {DATA_SCREEN_CHAR_{n}_NSP_OFFSET}
            dw {DATA_SCREEN_CHAR_{n}_DSP_OFFSET}

            origin jab_action_pointers.ORIGIN + ({CHAR_ID_{n}} * 4)
            if !{defined DATA_SCREEN_CHAR_{n}_JAB_ACTION_POINTER} {
                dw jab_action_table_{n}
            } else {
                dw jab_action_pointers.{DATA_SCREEN_CHAR_{n}_JAB_ACTION_POINTER}
            }

            evaluate n({n} + 1)
        }

        pullvar base, origin
    }

    scope setup_files {
        // Extend the file array
        OS.patch_start(0x162288, 0x80136238)
        dw File.CHARACTER_BIOS_EXTENDED
        dw File.CHARACTER_IMAGES_EXTENDED
        OS.patch_end()

        // Extend the file count
        OS.patch_start(0x15FEE4, 0x80133E94)
        addiu   a1, r0, 0x0006                      // a1 = 6 files (original is 4)
        OS.patch_end()
        OS.patch_start(0x15FF00, 0x80133EB0)
        addiu   a1, r0, 0x0006                      // a1 = 6 files (original is 4)
        OS.patch_end()
    }

    // extend id table
    scope extend_id_table: {
        OS.patch_start(0x15DBA8, 0x80131B58)
        li      v1, id_table                             // original lines 2 & 3, modified: v1 = id_table
        sll     t1, a0, 0x0002                           // original line 16, modified: t1 = offset for char
        addu    t2, v1, t1                               // original line 17: t2 = address of id
        jr      ra                                       // original line 19
        lw      v0, 0x0000(t2)                           // original line 18: v0 = id
        OS.patch_end()
    }

    // extend character_id_to_data_screen_id_table
    scope extend_character_id_to_data_screen_id_table: {
        OS.patch_start(0x15DBF8, 0x80131BA8)
        li      v1, character_id_to_data_screen_id_table // original lines 2 & 3, modified: v1 = character_id_to_data_screen_id_table
        sll     t1, a0, 0x0002                           // original line 16, modified: t1 = offset for char
        addu    t2, v1, t1                               // original line 17: t2 = address of data screen id
        jr      ra                                       // original line 19
        lw      v0, 0x0000(t2)                           // original line 18: v0 = data screen id
        OS.patch_end()
    }

    // extend biography_offsets
    scope extend_biography_offsets: {
        OS.patch_start(0x15DC54, 0x80131C04)
        li      t7, biography_offsets                    // original lines 1 & 2, modified: t7 = biography_offsets
        sw      ra, 0x001C(sp)                           // original line 3
        sw      a0, 0x0058(sp)                           // original line 4
        sll     t8, a0, 0x0002                           // t8 = offset in table
        addu    t7, t7, t8                               // t7 = address of biography offset
        lw      t7, 0x0000(t7)                           // t7 = biography offset
        b       0x80131C40                               // skip all the lines that copied the table to the stack
        sw      t7, 0x0020(sp)                           // save to stack for later use
        OS.patch_end()

        OS.patch_start(0x15DD30, 0x80131CE0)
        lw      t9, 0x0020(sp)                           // t9 = biography offset
        nop
        nop
        OS.patch_end()
    }

    // extend series_logo_offsets
    scope extend_series_logo_offsets: {
        OS.patch_start(0x15DF7C, 0x80131F2C)
        li      t7, ResultsScreen.series_logo_offset_table // original lines 1 & 2, modified: t7 = series_logo_offset_table
        sw      ra, 0x0024(sp)                           // original line 3
        sw      s0, 0x0020(sp)                           // original line 4
        sw      a0, 0x00C0(sp)                           // original line 5
        sll     v1, a0, 0x0002                           // v1 = offset in table
        addu    t7, t7, v1                               // t7 = address of offset
        lw      t7, 0x0000(t7)                           // t7 = offset
        sw      t7, 0x008C(sp)                           // save to stack

        li      t2, unknown_table_2                      // original lines 17 & 18, modified: t2 = unknown_table_2
        addu    t2, t2, v1                               // t2 = address of offset
        lw      t2, 0x0000(t2)                           // t2 = offset
        sw      t2, 0x005C(sp)                           // save to stack

        li      t7, unknown_table_3                      // original lines 30 & 31, modified: t7 = unknown_table_3
        addu    t7, t7, v1                               // t7 = address of offset
        lw      t7, 0x0000(t7)                           // t7 = offset
        b       0x80131FD4                               // skip past all the table copy to stack stuff
        sw      t7, 0x002C(sp)                           // save to stack
        OS.patch_end()

        OS.patch_start(0x15E054, 0x80132004)
        lw      t5, 0x008C(sp)                           // t5 = series logo offset
        OS.patch_end()

        OS.patch_start(0x15E0A0, 0x80132050)
        lw      t4, 0x005C(sp)                           // t4 = unknown table 2 offset
        OS.patch_end()

        OS.patch_start(0x15E0C0, 0x80132070)
        lw      t0, 0x002C(sp)                           // t0 = unknown table 3 offset
        OS.patch_end()
    }

    // name offset and coordinates
    scope extend_name_offset_and_coordinates: {
        OS.patch_start(0x15E138, 0x801320E8)
        li      t7, fighter_name_coordinates             // original lines 1 & 2, modified: t7 = fighter_name_coordinates
        sw      ra, 0x001C(sp)                           // original line 3
        sw      a0, 0x00B8(sp)                           // original line 4
        sll     v1, a0, 0x0003                           // v1 = offset in table
        addu    t7, t7, v1                               // t7 = address of coordinates
        lw      t2, 0x0000(t7)                           // t2 = x coord
        sw      t2, 0x0050(sp)                           // save to stack
        lw      t2, 0x0004(t7)                           // t2 = y coord
        sw      t2, 0x0054(sp)                           // save to stack

        li      t2, name_offsets                         // original lines 16 & 17, modified: t2 = name_offsets
        sll     v1, a0, 0x0002                           // v1 = offset in table
        addu    t2, t2, v1                               // t2 = address of offset
        lw      t2, 0x0000(t2)                           // t2 = offset
        b       0x80132158                               // skip past copy table to stack stuff
        sw      t2, 0x0020(sp)                           // save to stack
        OS.patch_end()

        OS.patch_start(0x15E2D4, 0x80132284)
        lw      t7, 0x0020(sp)                           // t7 = name offset
        OS.patch_end()

        OS.patch_start(0x15E314, 0x801322C4)
        lwc1    f16, 0x0050(sp)                          // f16 = x coord
        swc1    f16, 0x0058(v0)                          // original line 2
        lwc1    f18, 0x0054(sp)                          // f18 = y coord
        OS.patch_end()
    }

    // extend works offsets
    scope extend_works_offsets: {
        OS.patch_start(0x15E3F0, 0x801323A0)
        li      t7, works_offsets                        // original lines 1 & 2, modified: t7 = works_offsets
        sw      ra, 0x001C(sp)                           // original line 3
        sw      a0, 0x0058(sp)                           // original line 4
        sll     t2, a0, 0x0002                           // t2 = offset in table
        addu    t7, t7, t2                               // t7 = address of offset
        lw      t7, 0x0000(t7)                           // t7 = offset
        b       0x801323DC                               // skip past copy table to stack stuff
        sw      t7, 0x0020(sp)                           // save to stack
        OS.patch_end()

        OS.patch_start(0x15E480, 0x80132430)
        lw      t4, 0x0020(sp)                           // t4 = works offset
        OS.patch_end()
    }

    scope extend_special_action_pointers: {
        OS.patch_start(0x15E558, 0x80132508)
        li      t6, special_action_pointers              // original lines 1 & 2, modified: t7 = special_action_pointers
        sll     t1, a1, 0x0002                           // t1 = offset in table
        addu    t6, t6, t1                               // t6 = address of pointer
        b       0x80132540                               // skip past copy table to stack stuff
        lw      t3, 0x0000(t6)                           // t3 = pointer
        OS.patch_end()

        OS.patch_start(0x15E5B4, 0x80132564)
        nop                                              // nop out lw t3, 0x0000(2) so t3 stays our pointer
        OS.patch_end()
    }

    scope extend_special_attack_offsets: {
        OS.patch_start(0x15EE74, 0x80132E24)
        li      t7, special_attack_offsets               // original lines 1 & 2, modified: t7 = special_attack_offsets
        sw      ra, 0x0014(sp)                           // original line 3
        sw      a0, 0x00C8(sp)                           // original line 4
        lui     a0, 0x8013
        jal     0x80131B58                               // v0 = char_id
        lw      a0, 0x65F8(a0)                           // a0 = data screen id
        sll     t5, v0, 0x0002                           // t5 = v0 * 4
        sub     t5, t5, v0                               // t5 = v0 * 3
        sll     t5, t5, 0x0002                           // t5 = v0 * 0x000C = offset in table
        addu    t7, t7, t5                               // t7 = offset array for char
        b       0x80132E60                               // skip past copy table to stack stuff
        sw      t7, 0x0034(sp)                           // save to stack
        OS.patch_end()

        OS.patch_start(0x15EF6C, 0x80132F1C)
        lw      t7, 0x0034(sp)                           // t7 = special attacks array
        lui     t6, 0x8013                               // original line 2
        lw      t6, 0x6A78(t6)                           // original line 3 - t6 = file location
        addu    t7, t7, v1                               // t7 = address of offset
        b       0x80132F40                               // skip older code
        lw      t7, 0x0000(t7)                           // t7 = offset
        OS.patch_end()
    }

    // originally the table was not referenced by pointers, but that wouldn't be very efficient!
    scope extend_jab_action_pointers: {
        OS.patch_start(0x15E734, 0x801326E4)
        // a1 = char_id
        // t0 = char_id * 4 = offset in table
        li      t7, jab_action_pointers                     // t7 = jab_action_pointers
        sll     t6, t6, 0x0002                           // original line 3
        addu    t7, t7, t0                               // t7 = address of pointer
        lw      t7, 0x0000(t7)                           // t7 = jab action table
        addu    t8, t6, t7                               // t8 = action address
        nop
        OS.patch_end()
    }

    scope extend_biography_file: {
        OS.patch_start(0x15DD28, 0x80131CD8)
        j       extend_biography_file
        lb      t9, 0x0020(sp)         // t9 = special flag in offset
        _return:
        OS.patch_end()

        beqz    t9, _normal             // do normal if no special flag in the file pointer
        sb      r0, 0x0020(sp)          // remove special flag
        // if here, then use remix file instead
        OS.read_word(EXTENDED_BIOS_POINTER, t1) // t1 = remix file pointer
        j       _return + 0x04
        lw      t9, 0x0020(sp)          // t9 = offset (og line 3)

        _normal:
        lui     t1, 0x8013              // og line 1
        j       _return
        lw      t1, 0x6A78(t1)          // og line 2
    }

    scope extend_works_file: {
        OS.patch_start(0x15E470, 0x80132420)
        j       extend_works_file
        lb      t4, 0x0020(sp)         // t4 = special flag in offset
        _return:
        OS.patch_end()

        beqz    t4, _normal             // do normal if no special flag in the file pointer
        sb      r0, 0x0020(sp)          // remove special flag
        // if here, then use remix file instead
        OS.read_word(EXTENDED_IMAGES_POINTER, t5) // t5 = remix file pointer
        j       _return + 0x04
        sll     t3, t2, 2               // og line 3

        _normal:
        lui     t5, 0x8013              // og line 1
        j       _return
        lw      t5, 0x6A78(t5)          // og line 2
    }

    scope extend_special_attacks_file: {
        OS.patch_start(0x15EF70, 0x80132F20)
        j       extend_special_attacks_file
        addu    t7, t7, v1              // get offset to attack image offset
        _return:
        OS.patch_end()
        lb      at, 0x0000(t7)          // t7 = attack image offset
        beqz    at, _normal
        lw      t7, 0x0000(t7)          // t7 = file ptr

        // remix file if here
        OS.read_word(EXTENDED_IMAGES_POINTER, t6) // t6 = remix file pointer
        sll     t7, t7, 8
        j       0x80132F40
        srl     t7, t7, 8               // remove special flag

        _normal:
        lui     t6, 0x8013
        j       0x80132F40
        lw      t6, 0x6A78(t6)
    }

    scope extend_names_file: {
        OS.patch_start(0x15E2C4, 0x80132274)
        j       extend_names_file
        lb      t4, 0x0020(sp)         // t4 = special flag in offset
        _return:
        OS.patch_end()

        beqz    t4, _normal
        OS.read_word(EXTENDED_IMAGES_POINTER, t6) // t6 = remix file pointer
        j       _return
        sb      r0, 0x0020(sp)          // remove special flag to reveal offset

        _normal:
        lui     t6, 0x8013              // og line 1
        j       _return
        lw      t6, 0x6A78(t6)          // og line 2
    }

    scope extend_name_border_check: {
        OS.patch_start(0x15E1FC, 0x801321AC)
        j       extend_name_border_check
        addiu   at, r0, 0x0007              // at = Falcons Character ID (line line 1)
        OS.patch_end()

        beq     v0, at, _large_border       // branch to use large border
        addiu   at, r0, Character.id.DRM    // at = Character ID
        beq     v0, at, _large_border       // branch to use large border
        addiu   at, r0, Character.id.DSAMUS // at = Character ID
        beq     v0, at, _large_border       // branch to use large border
        addiu   at, r0, Character.id.GND    // at = Character ID
        beq     v0, at, _large_border       // branch to use large border
        addiu   at, r0, Character.id.BANJO  // at = Character ID
        beq     v0, at, _large_border       // branch to use large border
        addiu   at, r0, Character.id.YLINK  // at = Character ID
        beq     v0, at, _large_border       // branch to use large border
        nop

        _small_border:
        j       0x80132214          // og line 2 (modified)
        lui     t0, 0x8013          // og line 3

        _large_border:
        j       0x801321B8
        lui     t0, 0x8013

    }

    // offsets to image file for special attacks with special flag added
    scope offset {
        constant phantasm(0x8000B288)
        constant reflector(0x8000B3C8)
        constant fire_bird(0x8000B148)
        constant flame_choke(0x8000B508)
        constant warlock_punch(0x8000B648)
        constant wizards_foot(0x8000B788)
        constant spin_attack(0x8000B8C8)
        constant boomerang(0x8000BA08)
        constant bombchu(0x8000BB48)
        constant super_jump_punch(0x8000BC88)
        constant mega_vitamin(0x8000BDC8)
        constant dr_tornado(0x8000BF08)
        constant cork_screw(0x8000C048)
        constant body_slam(0x8000C188)
        constant ground_pound(0x8000C2C8)
        constant screw_attack(0x8000C408)
        constant charge_shot(0x8000C548)
        constant bomb(0x8000C688)
        constant pk_thunder(0x8000C7C8)
        constant pk_fire(0x8000C908)
        constant psychic_magnet(0x8000CA48)
        constant whirling_fortress(0x8000CB88)
        constant flame_breath(0x8000CCC8)
        constant bowser_bomb(0x8000CE08)
        constant wolf_flash(0x8000CF48)
        constant blaster_shot(0x8000D088)
        constant wolf_reflector(0x8000D1C8)
        constant helicoptery_tail(0x8000D308)
        constant slingshot(0x8000D448)
        constant grenade(0x8000D588)
        constant teleport(0x8000D6C8)
        constant shadow_ball(0x8000D808)
        constant disable(0x8000D948)
        constant dolphin_slash(0x8000DA88)
        constant dancing_blade(0x8000DBC8)
        constant counter(0x8000DD08)
        constant spring(0x8000DE48)
        constant homing_attack(0x8000DF88)
        constant spin_dash(0x8000E0C8)
        constant vanish(0x8000E208)
        constant needle_storm(0x8000E348)
        constant bouncing_fish(0x8000E488)
        constant cyber_uppercut(0x8000E5C8)
        constant ultra_grab(0x8000E708)
        constant clancer_pot(0x8000E848)
        constant super_dedede_jump(0x8000E988)
        constant inhale(0x8000EAC8)
        constant waddle_dee_toss(0x8000EC08)
        constant cloud(0x8000ED48)
        constant ryo_throw(0x8000EE88)
        constant chain_pipe(0x8000EFC8)
        constant egg_fire(0x80019068)
        constant beak_barge_buster(0x800191A0)
        constant beak_bomb(0x800192D8)

    }

    // name, bio_offset, unknown2, unknown3, name_X, name_Y,                 name_offset, works_offset, nsp_offset, dsp_offset, usp_offset, use_existing_special_actions, special_char, use_existing_jab_actions, jab_char)
    add_char_to_data_screen(FALCO,  0x80002408, 0x00000000, 0x00000000, 33, 50, 0x8000F528, 0x00026508, offset.phantasm, offset.reflector, offset.fire_bird, 1, FOX, 1, FOX)
        // set_action(USP, 0x000200E3, 0x0000029A, 0x00000000)
        // set_action(USP, 0x000200E5, 0x00000023, 0x00000002)
        // set_action(USP, 0x000200E7, 0x0000001E, 0x00000002)
        // set_action(USP, 0x000200E9, 0x0000029A, 0x00000002)
        // set_action(NSP, 0x000200E1, 0x0000029A, 0x00000000)
        // set_action(DSP, 0x000200EC, 0x00000023, 0x00000002)
        // set_action(DSP, 0x000200EF, 0x0000003C, 0x00000006)
        // set_action(DSP, 0x000200EE, 0x0000029A, 0x00000006)
        // set_action(JAB, 0x000200BF, 0x0000029A, 0x00000000)
        // set_action(JAB, 0x000200DC, 0x0000029A, 0x00000000)
        // set_action(JAB, 0x000200DD, 0x0000029A, 0x00000000)
        // set_action(JAB, 0x000200DE, 0x0000029A, 0x00000000)
    add_char_to_data_screen(GND,    0x80004888, 0x00000000, 0x00000000, 33, 48, 0x80014920, 0x80000A08, offset.warlock_punch, offset.wizards_foot, offset.flame_choke, 1, FALCON,   1, NESS)
    add_char_to_data_screen(YLINK,  0x80006D08, 0x00000000, 0x00000000, 33, 48, 0x800155E0, 0x80001468, offset.boomerang, offset.bombchu, offset.spin_attack, 1, LINK,     1, LINK)
    add_char_to_data_screen(DRM,    0x80009188, 0x00000000, 0x00000000, 33, 48, 0x80013C60, 0x80008688, offset.mega_vitamin, offset.dr_tornado, offset.super_jump_punch, 1, MARIO,    1, MARIO)
    add_char_to_data_screen(WARIO,  0x8000B608, 0x00000000, 0x00000000, 33, 50, 0x800122E8, 0x80001EC8, offset.body_slam, offset.ground_pound, offset.cork_screw, 0, 0,    1, DK)
        set_action(USP, Wario.Action.Corkscrew, 0x0000029A, 0x00000000)
        set_action(NSP, Wario.Action.BodySlam, 0x0000029A, 0x00000000)
        set_action(DSP, Wario.Action.GroundPound, 0x0000029A, 0x00000000)
        set_action(DSP, Wario.Action.GroundPoundLanding, 0x0000029A, 0x00000000)
    add_char_to_data_screen(DSAMUS, 0x8000DA88, 0x00000000, 0x00000000, 33, 46, 0x80012FA0, 0x800090E8, offset.charge_shot, offset.bomb, offset.screw_attack, 1, SAMUS,    1, SAMUS)
    add_char_to_data_screen(LUCAS,  0x8000FF08, 0x00000000, 0x00000000, 33, 50, 0x80010128, 0x80009B48, offset.pk_fire, offset.psychic_magnet, offset.pk_thunder, 1, NESS,     1, MARIO)
    add_char_to_data_screen(BOWSER, 0x80012388, 0x00000000, 0x00000000, 24, 50, 0x80016DB8, 0x80002928, offset.flame_breath, offset.bowser_bomb, offset.whirling_fortress, 1, YOSHI,    0, -1)
        set_action(JAB, Action.Jab2, 0x0000029A, 0x00000000)
        set_action(JAB, Bowser.Action.Jab3, 0x0000029A, 0x00000000)
    add_char_to_data_screen(WOLF,   0x80014808, 0x00000000, 0x00000000, 33, 50, 0x8000FA88, 0x80003388, offset.blaster_shot, offset.wolf_reflector, offset.wolf_flash, 0, 0,      1, MARIO)
        set_action(USP, Wolf.Action.WolfFlashStart, 0x0000029A, 0x00000000)
        set_action(USP, Wolf.Action.WolfFlash, 0x0000029A, 0x00000000)
        set_action(NSP, Wolf.Action.Blaster, 0x0000029A, 0x00000000)
        set_action(DSP, Wolf.Action.ReflectorStart, 0x00000023, 0x00000002)
        set_action(DSP, Wolf.Action.ReflectorLoop, 0x0000003C, 0x00000006)
        set_action(DSP, Wolf.Action.ReflectorEnd, 0x0000029A, 0x00000006)
    add_char_to_data_screen(CONKER, 0x80016C88, 0x00000000, 0x00000000, 26, 50, 0x80015DC8, 0x80003DE8, offset.slingshot, offset.grenade, offset.helicoptery_tail, 0, 0,        1, FOX)
        set_action(USP, Conker.Action.HelicopteryTailThing, 0x0000029A, 0x00000000)
        set_action(USP, Conker.Action.HelicopteryTailThingDescent, 0x0000003C, 0x00000000)
        set_action(NSP, Conker.Action.CatapultStart, 0x0000029A, 0x00000000)
        set_action(NSP, Conker.Action.CatapultCharge, 0x0000003C, 0x00000000)
        set_action(NSP, Conker.Action.CatapultShoot, 0x0000029A, 0x00000000)
        set_action(DSP, Conker.Action.GrenadeToss, 0x0000029A, 0x00000000)
    add_char_to_data_screen(MTWO,   0x80019108, 0x00000000, 0x00000000, 24, 50, 0x80018F28, 0x80004848, offset.shadow_ball, offset.disable, offset.teleport, 0, 0,        0, -1)
        set_action(USP, Mewtwo.Action.TeleportStart, 0x0000029A, 0x00000000)
        set_action(USP, Mewtwo.Action.Teleport, 0x0000029A, 0x00000000)
        set_action(USP, Mewtwo.Action.TeleportEnd, 0x0000029A, 0x00000000)
        set_action(NSP, Mewtwo.Action.ShadowBallStart, 0x0000029A, 0x00000000)
        set_action(NSP, Mewtwo.Action.ShadowBallCharge, 0x0000003C, 0x00000002)
        set_action(NSP, Mewtwo.Action.ShadowBallShoot, 0x0000029A, 0x00000002)
        set_action(DSP, Mewtwo.Action.Disable, 0x0000029A, 0x00000000)
        set_action(JAB, Action.Jab2, 0x0000029A, 0x00000000)
        set_action(JAB, Mewtwo.Action.JabLoopStart, 0x0000029A, 0x00000000)
        set_action(JAB, Mewtwo.Action.JabLoop, 0x0000029A, 0x00000000)
        set_action(JAB, Mewtwo.Action.JabLoopEnd, 0x0000029A, 0x00000000)
    add_char_to_data_screen(MARTH,  0x8001B588, 0x00000000, 0x00000000, 33, 50, 0x800107C8, 0x800052A8, offset.dancing_blade, offset.counter, offset.dolphin_slash, 0, 0,        1, DK)
        set_action(USP, Marth.Action.USPG, 0x0000029A, 0x00000000)
        set_action(NSP, Marth.Action.NSPG_1, 0x0000029A, 0x00000000)
        set_action(NSP, Marth.Action.NSPG_2_High, 0x0000029A, 0x00000000)
        set_action(NSP, Marth.Action.NSPG_3_High, 0x0000029A, 0x00000000)
        set_action(DSP, Marth.Action.DSPG, 0x0000003C, 0x00000000)
        set_action(DSP, Marth.Action.DSPG_Attack, 0x0000029A, 0x00000000)
    add_char_to_data_screen(SONIC,  0x8001DA08, 0x00000000, 0x00000000, 33, 50, 0x80011C20, 0x80005D08, offset.homing_attack, offset.spin_dash, offset.spring, 0, 0,        1, MARIO)
        set_action(USP, Sonic.Action.Spring, 0x0000029A, 0x00000000)
        set_action(NSP, Sonic.Action.HomingStart, 0x0000029A, 0x00000000)
        set_action(NSP, Sonic.Action.HomingMove, 0x0000003C, 0x00000000)
        set_action(NSP, Sonic.Action.HomingEndGround, 0x0000029A, 0x00000000)
        set_action(DSP, Sonic.Action.SpinDashChargeGround, 0x0000003C, 0x00000000)
        set_action(DSP, Sonic.Action.SpinDashGround, 0x0000003C, 0x00000000)
        set_action(DSP, Sonic.Action.SpinDashEndGround, 0x0000029A, 0x00000000)
    add_char_to_data_screen(SHEIK,  0x8001FE88, 0x00000000, 0x00000000, 33, 50, 0x80011558, 0x80000A08, offset.needle_storm, offset.bouncing_fish, offset.vanish, 0, 0,        1, FOX)
        set_action(USP, Sheik.Action.USPG_BEGIN, 0x0000029A, 0x00000000)
        set_action(USP, Sheik.Action.USPG_MOVE, 0x0000029A, 0x00000000)
        set_action(USP, Sheik.Action.USPG_END, 0x0000029A, 0x00000000)
        set_action(NSP, Sheik.Action.NSPG_BEGIN, 0x0000029A, 0x00000000)
        set_action(NSP, Sheik.Action.NSPG_CHARGE, 0x0000003C, 0x00000000)
        set_action(NSP, Sheik.Action.NSPG_SHOOT, 0x0000029A, 0x00000000)
        set_action(DSP, Sheik.Action.DSP_BEGIN, 0x0000029A, 0x00000000)
        set_action(DSP, Sheik.Action.DSP_ATTACK, 0x0000029A, 0x00000000)
        set_action(DSP, Sheik.Action.DSP_LANDING, 0x0000029A, 0x00000000)
    add_char_to_data_screen(MARINA, 0x80022308, 0x00000000, 0x00000000, 26, 48, 0x80010E90, 0x80006768, offset.ultra_grab, offset.clancer_pot, offset.cyber_uppercut, 0, 0,        1, FOX)
        set_action(USP, Marina.Action.USPG, 0x0000029A, 0x00000000)
        set_action(NSP, Marina.Action.CargoWalk1, 0x00000023, 0x00000000)
        set_action(NSP, Marina.Action.CargoShake, 0x0000003C, 0x00000000)
        set_action(NSP, Marina.Action.CargoWalk2, 0x00000023, 0x00000000)
        set_action(NSP, Marina.Action.CargoThrow, 0x0000029A, 0x00000000)
        set_action(DSP, Marina.Action.DSPG_Begin, 0x0000029A, 0x00000000)
        set_action(DSP, Marina.Action.DSPG_Wait, 0x0000003C, 0x00000000)
        set_action(DSP, Marina.Action.DSPG_End, 0x0000029A, 0x00000000)
    add_char_to_data_screen(DEDEDE, 0x80024788, 0x00000000, 0x00000000, 20, 50, 0x800165A8, 0x800071C8, offset.inhale, offset.waddle_dee_toss, offset.super_dedede_jump, 0, 0,        0, -1)
        set_action(USP, Dedede.Action.USP_BEGIN, 0x0000029A, 0x00000000)
        set_action(USP, Dedede.Action.USP_MOVE, 0x0000003C, 0x00000000)
        set_action(USP, Dedede.Action.USP_LAND, 0x0000029A, 0x00000000)
        set_action(NSP, Dedede.Action.NSP_BEGIN_GROUND, 0x0000029A, 0x00000000)
        set_action(NSP, Dedede.Action.NSP_LOOP_GROUND, 0x00000028, 0x00000024)
        set_action(NSP, Dedede.Action.NSP_END_GROUND, 0x0000029A, 0x00000000)
        set_action(DSP, Dedede.Action.DSPG_BEGIN, 0x0000029A, 0x00000000)
        set_action(DSP, Dedede.Action.DSPG_CHARGE, 0x0000003C, 0x00000000)
        set_action(DSP, Dedede.Action.DSPG_SHOOT, 0x0000029A, 0x00000000)
        set_action(JAB, Action.Jab2, 0x0000029A, 0x00000000)
        set_action(JAB, Dedede.Action.JAB_3, 0x0000029A, 0x40000000)
    add_char_to_data_screen(GOEMON, 0x80026C08, 0x00000000, 0x00000000, 23, 50, 0x80018608, 0x80007C28, offset.ryo_throw, offset.chain_pipe, offset.cloud, 0, 0,        1, MARIO)
        set_action(USP, Goemon.Action.USP, 0x000003C, 0x00000000)
        set_action(USP, Goemon.Action.USPAttack, 0x0000029A, 0x00000024)
        set_action(NSP, Goemon.Action.NSP_Ground_Begin, 0x0000029A, 0x00000000)
        set_action(NSP, Goemon.Action.NSP_Ground_Wait, 0x00000028, 0x00000002)
        set_action(NSP, Goemon.Action.NSP_Ground_End, 0x0000029A, 0x00000000)
        set_action(DSP, Goemon.Action.DSPGround, 0x0000029A, 0x00000000)
        set_action(DSP, Goemon.Action.DSPGAttack, 0x0000029A, 0x00000000)
        set_action(DSP, Goemon.Action.DSPEnd, 0x0000029A, 0x00000000)
    add_char_to_data_screen(BANJO, 0x80029088, 0x00000000, 0x00000000, 20, 48, 0x8001A200, 0x8000A5A8, offset.egg_fire, offset.beak_barge_buster, offset.beak_bomb, 0, 0,        0, -1)
        set_action(USP, Banjo.Action.USPBegin, 0x0000003C, 0x00000000)
        set_action(USP, Banjo.Action.USPAttack, 0x0000029A, 0x00000000)
        set_action(NSP, Banjo.Action.NSPBeginG, 0x0000029A, 0x00000000)
        set_action(NSP, Banjo.Action.NSPForwardA, 0x0000029A, 0x00000000)
        set_action(DSP, Banjo.Action.DSPG, 0x0000029A, 0x00000000)
        set_action(JAB, Action.Jab2, 0x0000029A, 0x00000000)
        set_action(JAB, Banjo.Action.Jab3, 0x0000029A, 0x40000000)

    extend_tables()

    scope extend_index_: {
        // scroll left
        OS.patch_start(0x15FBAC, 0x80133B5C)
        addiu   s1, r0, new_characters + 11              // s1 = max data screen id
        OS.patch_end()

        // scroll right
        OS.patch_start(0x15FC40, 0x80133BF0)
        addiu   s1, r0, new_characters + 11              // s1 = max data screen id
        OS.patch_end()
    }

    // This ensures we don't get into a frozen state due to our fsm custom moveset command.
    // The original lines checked for c.eq.s f4, f6 (specifically, 0 = current frame count)
    OS.patch_start(0x15E7B8, 0x80132768)
    lui     v0, 0x3DCD                     // v0 = 0.100098
    mtc1    v0, f4                         // f4 = 0.100098
    lwc1    f6, 0x0078(a0)                 // original line 2 - f6 = current frame count
    c.le.s  f6, f4                         // check if the current frame count is <= 0.1
    or      v0, r0, r0                     // original line 3 - v0 = 0
    OS.patch_end()

}

}
