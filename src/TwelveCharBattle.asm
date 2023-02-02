// TwelveCharBattle.asm
if !{defined __TWELVE_CHAR_BATTLE__} {
define __TWELVE_CHAR_BATTLE__()
print "included TwelveCharBattle.asm\n"

// @ Description
// This file adds a 12-Character Battle mode.

// TODO: Allow other ports besides just 1 and 2.
//  - This is a big lift, and not high priority.

include "OS.asm"
include "FGM.asm"

scope TwelveCharBattle {

    // @ Description
    // Flag to indicate if we should show the 12cb CSS or the normal VS CSS
    // FALSE = VS CSS, TRUE = 12cb CSS
    twelve_cb_flag:
    dw OS.FALSE

    macro define_match_struct() {
        define n(1)
        while {n} < 24 {
            scope game_{n}: {
                char_id:; db Character.id.NONE   // character_id used this game
                starting_stocks:; db 0x00        // starting stocks this game
                ending_stocks:; db 0x00          // ending stocks this game
                portrait_id:; db 0xFF            // portrait_id of this character
                damage_taken:; dw 0x00           // damage taken this game TODO: Not implemented, maybe won't be, but this word is important to keep
            }
            evaluate n({n} + 1)
        }
    }

    scope config: {
        constant STATUS_NOT_STARTED(0x0000)
        constant STATUS_STARTED(0x0001)
        constant STATUS_COMPLETE(0x0002)

        status:; dw STATUS_NOT_STARTED           // indicates state of 12cb
        num_stocks:; dw 0x03                     // number of stocks per character (0-based)
        current_game:; dw 0xFFFFFFFF             // current game

        scope p1: {
            stocks_remaining:; dw 0x30           // stocks remaining for p1
            scope match: {
                define_match_struct()
            }
            character_set:; dw 0x0               // character set index
            character_set_pointer:; dw string_character_set_default // character set string pointer
            best_character:; dw 0x001C00FF       // character_id and portrait_id of best character
            best_character_pointer:; dw 0x0      // best character string pointer
            best_character_tkos_for:; dw -0x01   // best character TKOs (stocks taken as character)
            best_character_tkos_against:; dw 0x00 // best character TKOs (stocks lost as character)
        }
        scope p2: {
            stocks_remaining:; dw 0x30           // stocks remaining for p2
            scope match: {
                define_match_struct()
            }
            character_set:; dw 0x0               // character set index
            character_set_pointer:; dw string_character_set_default // character set string pointer
            best_character:; dw 0x001C00FF       // character_id and portrait_id of best character
            best_character_pointer:; dw 0x0      // best character string pointer
            best_character_tkos_for:; dw -0x01   // best character TKOs (stocks taken as character)
            best_character_tkos_against:; dw 0x00 // best character TKOs (stocks lost as character)
        }

        // This will hold the remaining stocks for the character at each portrait slot
        stocks_by_portrait_id:
        fill 24, 0x03
    }

    // @ Description
    // The following patches enable a new button on the VS Game Mode menu
    scope add_button_: {
        // Adjust max index from 3 to 4 when pressing up
        OS.patch_start(0x12482E, 0x80133E7E)
        dh      0x0004
        OS.patch_end()
        // Adjust max index from 3 to 4 when pressing down
        OS.patch_start(0x124996, 0x80133FE6)
        dh      0x0004
        OS.patch_end()
        // Adjust scroll wrap pause time index check from 3 to 4 when pressing down
        OS.patch_start(0x124962, 0x80133FB2)
        dh      0x0003
        OS.patch_end()

        // This adds the new button's object pointer to the stack
        OS.patch_start(0x12456C, 0x80133BBC)
        jal     add_button_
        lui     v1, 0x8013                  // original line 1
        OS.patch_end()

        // treat index 4 as 0 when pressing A/Start
        OS.patch_start(0x124680, 0x80133CD0)
        andi    v0, v0, 0x0003              // v0 = 0 - 3 (if it was 4, it's 0 now)
        beq     v0, r0, 0x80133CEC          // original line 2
        addiu   at, r0, 0x0003              // original line 1
        OS.patch_end()
        OS.patch_start(0x1246A4, 0x80133CF4)
        jal     add_button_._handle_select
        lui     a0, 0x8013                  // original line 1
        OS.patch_end()

        // This selects the new button when coming from the 12cb CSS
        OS.patch_start(0x124084, 0x801336D4)
        j       add_button_._init_cursor
        lui     at, 0x8013                  // original line 1
        _return:
        OS.patch_end()

        li      t0, 0x80134940              // t0 = address of new button object pointer
        sw      t0, 0x0010(t6)              // save it to the stack

        jr      ra
        addiu   v1, v1, 0x4980              // original line 2

        _handle_select:
        li      t1, twelve_cb_flag
        lui     v0, 0x8013
        lw      v0, 0x4948(v0)              // v0 = cursor index
        beqzl   v0, _end                    // if the new button is not selected, skip
        sw      r0, 0x0000(t1)              // set 12cb flag to FALSE

        lli     t0, OS.TRUE                 // t0 = TRUE
        addiu   a0, a0, 0x0010              // adjust button pointer address for new button
        sw      t0, 0x0000(t1)              // set 12cb flag

        _end:
        jr      ra
        lw      a0, 0x4930(a0)              // original line 2

        _init_cursor:
        li      t0, twelve_cb_flag
        lw      v0, 0x0000(t0)              // v0 = TRUE if coming from 12cb CSS
        sw      r0, 0x0000(t0)              // reset 12cb flag

        // ensure pointers are correct for other CSS screens
        li      t0, CharacterSelect.id_table_pointer
        li      t1, CharacterSelect.id_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_id_table_pointer
        li      t1, CharacterSelect.portrait_id_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_offset_table_pointer
        li      t1, CharacterSelect.portrait_offset_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_x_position_pointer
        li      t1, CharacterSelect.portrait_x_position
        sw      t1, 0x0000(t0)

        lli     a0, 0x0004                  // a0 = 4 (index of new button)
        beqzl   v0, pc() + 8                // if not coming from 12cb, then select VS START
        lli     a0, 0x0000                  // a0 = 0 (index of VS START)

        j       _return
        sw      a0, 0x4948(at)              // original line 2, modified to use a0
    }

    // @ Description
    // Creates the custom objects for the VS Game Mode screen (5th button)
    scope vs_game_mode_setup_: {
        constant TWELVECB_LABEL_OFFSET(0x6760)

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        // Render 12-Char Battle button
        lli     a2, 0x0002                  // a2 = room
        lli     a3, 0x0004                  // a3 = group
        li      a1, Render.TEXTURE_RENDER_  // a1 = render routine
        jal     Render.create_display_object_
        lli     a0, 0x0000                  // a0 = routine
        lui     t0, 0x8013
        sw      v0, 0x4940(t0)              // store object pointer in free memory

        addiu   sp, sp,-0x0020              // allocate stack space
        or      a0, v0, r0                  // a0 = object pointer
        lui     a1, 0x41E0                  // a1 = X position of button
        lui     a2, 0x433B                  // a2 = Y position of button
        jal     0x80132024                  // CREATE_BUTTON_
        lli     a3, 0x0011                  // a3 = unselected color
        addiu   sp, sp, 0x0020              // deallocate stack space

        // update display state of new button
        lui     t0, 0x8013
        lw      a0, 0x4940(t0)              // a0 = object pointer of new button
        lw      t7, 0x4948(t0)              // t7 = cursor index
        sltiu   a1, t7, 0x0004              // a1 = 0 if new button is selected, 1 otherwise
        jal     0x80131F4C                  // update button coloring
        xori    a1, a1, 0x0001              // a1 = 1 if new button is selected, 0 otherwise

        // render text
        Render.draw_texture_at_offset(2, 4, 0x80134A4C, TWELVECB_LABEL_OFFSET, Render.NOOP, 0x42240000, 0x43400000, 0x000000FF, 0x00000000, 0x3F800000)

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop
    }

    // @ Description
    // CHARACTER SELECT SCREEN LAYOUT
    constant NUM_SLOTS(24)
    constant NUM_PRESETS(4)
    scope layout {
        scope u {
            // row 1
            define slot_1(LUIGI)
            define slot_2(MARIO)
            define slot_3(DONKEY)
            define slot_4(LINK)
            define slot_5(LUIGI)
            define slot_6(MARIO)
            define slot_7(DONKEY)
            define slot_8(LINK)
            // row 2
            define slot_9(SAMUS)
            define slot_10(CAPTAIN)
            define slot_11(NESS)
            define slot_12(YOSHI)
            define slot_13(SAMUS)
            define slot_14(CAPTAIN)
            define slot_15(NESS)
            define slot_16(YOSHI)
            // row 3
            define slot_17(KIRBY)
            define slot_18(FOX)
            define slot_19(PIKACHU)
            define slot_20(JIGGLYPUFF)
            define slot_21(KIRBY)
            define slot_22(FOX)
            define slot_23(PIKACHU)
            define slot_24(JIGGLYPUFF)
        }
        scope j {
            // row 1
            define slot_1(JLUIGI)
            define slot_2(JMARIO)
            define slot_3(JDK)
            define slot_4(JLINK)
            define slot_5(JLUIGI)
            define slot_6(JMARIO)
            define slot_7(JDK)
            define slot_8(JLINK)
            // row 2
            define slot_9(JSAMUS)
            define slot_10(JFALCON)
            define slot_11(JNESS)
            define slot_12(JYOSHI)
            define slot_13(JSAMUS)
            define slot_14(JFALCON)
            define slot_15(JNESS)
            define slot_16(JYOSHI)
            // row 3
            define slot_17(JKIRBY)
            define slot_18(JFOX)
            define slot_19(JPIKA)
            define slot_20(JPUFF)
            define slot_21(JKIRBY)
            define slot_22(JFOX)
            define slot_23(JPIKA)
            define slot_24(JPUFF)
        }
        scope r {
            // row 1
            define slot_1(DRM)
            define slot_2(GND)
            define slot_3(YLINK)
            define slot_4(FALCO)
            define slot_5(DRM)
            define slot_6(GND)
            define slot_7(YLINK)
            define slot_8(FALCO)
            // row 2
            define slot_9(DSAMUS)
            define slot_10(WARIO)
            define slot_11(LUCAS)
            define slot_12(BOWSER)
            define slot_13(DSAMUS)
            define slot_14(WARIO)
            define slot_15(LUCAS)
            define slot_16(BOWSER)
            // row 3
            define slot_17(WOLF)
            define slot_18(CONKER)
            define slot_19(MTWO)
            define slot_20(MARTH)
            define slot_21(WOLF)
            define slot_22(CONKER)
            define slot_23(MTWO)
            define slot_24(MARTH)
        }
        scope pv {
            // row 1
            define slot_1(NLUIGI)
            define slot_2(NMARIO)
            define slot_3(NDONKEY)
            define slot_4(NLINK)
            define slot_5(NLUIGI)
            define slot_6(NMARIO)
            define slot_7(NDONKEY)
            define slot_8(NLINK)
            // row 2
            define slot_9(NSAMUS)
            define slot_10(NCAPTAIN)
            define slot_11(NNESS)
            define slot_12(NYOSHI)
            define slot_13(NSAMUS)
            define slot_14(NCAPTAIN)
            define slot_15(NNESS)
            define slot_16(NYOSHI)
            // row 3
            define slot_17(NKIRBY)
            define slot_18(NFOX)
            define slot_19(NPIKACHU)
            define slot_20(NJIGGLY)
            define slot_21(NKIRBY)
            define slot_22(NFOX)
            define slot_23(NPIKACHU)
            define slot_24(NJIGGLY)
        }
        // scope pr {
            // // row 1
            // define slot_1(NDRM)
            // define slot_2(GND)
            // define slot_3(YLINK)
            // define slot_4(FALCO)
            // define slot_5(NDRM)
            // define slot_6(GND)
            // define slot_7(YLINK)
            // define slot_8(FALCO)
            // // row 2
            // define slot_9(DSAMUS)
            // define slot_10(NWARIO)
            // define slot_11(NLUCAS)
            // define slot_12(NBOWSER)
            // define slot_13(DSAMUS)
            // define slot_14(NWARIO)
            // define slot_15(NLUCAS)
            // define slot_16(NBOWSER)
            // // row 3
            // define slot_17(NWOLF)
            // define slot_18(CONKER)
            // define slot_19(MTWO)
            // define slot_20(MARTH)
            // define slot_21(NWOLF)
            // define slot_22(CONKER)
            // define slot_23(MTWO)
            // define slot_24(MARTH)
        // }
    }

    // @ Description
    // This table holds the velocity for portrait slide in animations
    portrait_velocity:
    float32 1.9                               // column 1
    float32 3.9                               // column 2
    float32 7.8                               // column 3
    float32 11.8                              // column 4
    float32 -11.8                             // column 5
    float32 -7.8                              // column 6
    float32 -3.8                              // column 7
    float32 -1.8                              // column 8

    // @ Description
    // CSS characters in order of portrait ID
    id_table:
    fill NUM_SLOTS
    OS.align(4)

    // @ Description
    // Portrait offsets in order of portrait ID
    portrait_offset_table:
    fill NUM_SLOTS * 4
    OS.align(4)

    // @ Description
    // CSS portraits IDs in order of character ID
    portrait_id_table:
    fill Character.NUM_CHARACTERS, 0xFF
    OS.align(4)

    macro create_portrait_tables(layout_type, layout) {
        // @ Description
        // Holds the valid character count for this type
        global variable character_count_{layout_type}(0)

        // @ Description
        // CSS characters in order of portrait ID
        id_table_{layout_type}:
        evaluate n(0)
        while NUM_SLOTS > {n} {
            evaluate n({n} + 1)
            db Character.id.{layout.{layout}.slot_{n}}

            // Increment valid character count for this type
            if (Character.id.{layout.{layout}.slot_{n}} != Character.id.NONE) {
               global variable character_count_{layout_type}(character_count_{layout_type} + 1)
            }
        }
        OS.align(4)

        // Valid character count should be divided by 2 since we double counted
        global variable character_count_{layout_type}(character_count_{layout_type} / 2)

        // @ Description
        // Portrait offsets in order of portrait ID
        portrait_offset_table_{layout_type}:
        evaluate n(0)
        while NUM_SLOTS > {n} {
            evaluate n({n} + 1)
            dw CharacterSelect.portrait_offsets.{layout.{layout}.slot_{n}}
        }
        OS.align(4)

        // @ Description
        // CSS portraits IDs in order of character ID
        portrait_id_table_{layout_type}:
        constant portrait_id_table_{layout_type}_origin(origin())
        // fill table with empty slots
        fill Character.NUM_CHARACTERS, 0xFF
        OS.align(4)
        pushvar origin, base
        evaluate n(0)
        while NUM_SLOTS > {n} {
            evaluate n({n} + 1)
            origin portrait_id_table_{layout_type}_origin + Character.id.{layout.{layout}.slot_{n}}
            db {n} - 1
        }
        // The game always returns 0 for Character.id.NONE, but we'll end up detecting 0xFF and returning 0x00 in get_portrait_id_
        origin portrait_id_table_{layout_type}_origin + Character.id.NONE
        db 0xFF
        pullvar base, origin
    }

    macro create_portrait_tables(layout_type) {
        create_portrait_tables({layout_type}, {layout_type})
    }

    create_portrait_tables(u)       // create vanilla character set tables
    create_portrait_tables(j)       // create japanese character set tables
    create_portrait_tables(pv)      // create polygon vanilla character set tables
    create_portrait_tables(r)       // create remix character set tables
    // create_portrait_tables(pr)      // create polygon remix character set tables
    create_portrait_tables(p1, u)   // create p1's custom character set tables
    create_portrait_tables(p2, u)   // create p2's custom character set tables

    character_set_table:
    // id table     // portrait offset table     // portrait id table     // custom preset cycle index
    dw id_table_u;  dw portrait_offset_table_u;  dw portrait_id_table_u;  dw 0x0
    dw id_table_j;  dw portrait_offset_table_j;  dw portrait_id_table_j;  dw 0x0
    dw id_table_pv;  dw portrait_offset_table_pv;  dw portrait_id_table_pv;  dw 0x0
    dw id_table_r;  dw portrait_offset_table_r;  dw portrait_id_table_r;  dw 0x0
    // dw id_table_pr;  dw portrait_offset_table_pr;  dw portrait_id_table_pr;  dw 0x0
    dw id_table_p1; dw portrait_offset_table_p1; dw portrait_id_table_p1; dw 0x0
    dw id_table_p2; dw portrait_offset_table_p2; dw portrait_id_table_p2; dw 0x0

    constant START_X(30)
    constant START_Y(25)
    constant START_VISUAL(10)
    constant NUM_ROWS(3)
    constant NUM_COLUMNS(8)
    constant NUM_PORTRAITS(NUM_ROWS * NUM_COLUMNS)
    constant PORTRAIT_WIDTH(30)
    constant PORTRAIT_HEIGHT(30)

    // @ Description
    // This table holds the final X position for portraits
    // This could just be based on column, but it is set for each portrait to make code simpler
    portrait_x_position:
    evaluate n(0)
    while NUM_COLUMNS > {n} {
        evaluate x(START_VISUAL + START_X + PORTRAIT_WIDTH * {n})
        if ({n} < 4) {
            evaluate x({x} - 8)
        } else {
            evaluate x({x} + 8)
        }
        float32 {x}
        evaluate n({n} + 1)
    }

    // @ Description
    scope setup_ports_and_characters_: {
        OS.patch_start(0x138F3C, 0x8013ACBC)
        j       setup_ports_and_characters_
        lbu     t0, 0x0023(v1)              // original line 2
        _return:
        OS.patch_end()

        // a0 = port_id
        // t0 = character_id
        // v0 = CSS player struct
        // v1 = Global.vs.pX - 0x20

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      v0, 0x0008(sp)              // ~

        li      a1, twelve_cb_flag
        lw      a1, 0x0000(a1)              // a1 = 1 if 12cb
        beqz    a1, _end                    // skip if not 12cb CSS
        nop

        or      a1, r0, t0                  // a1 = character_id

        // Ensure 3P and 4P are not enabled
        sltiu   t1, a0, 0x0002              // t1 = 1 if 1P/2P
        bnez    t1, _port_1_or_2            // if 1P or 2P, skip
        nop
        lli     t1, 0x021C                  // t1 = N/A, no character
        sh      t1, 0x0022(v1)              // set 3P/4P to N/A, no character
        b       _end                        // skip to end
        nop

        _port_1_or_2:
        lbu     t0, 0x0022(v1)              // t0 = 0 if HMN, 1 if CPU, 2 if N/A
        lli     t1, 0x0002                  // t1 = N/A
        beq     t0, t1, _end                // if N/A, just skip
        nop
        li      t0, config
        lw      t1, 0x0000(t0)              // t1 = battle status
        beqz    t1, _check_valid_chars      // if 12cb not started, then skip past defeated check
        lw      t1, 0x0008(t0)              // t1 = current game
        sll     t1, t1, 0x0003              // t1 = offset to current game in match struct

        li      t0, config.p1.match         // t0 = match struct (1P's)
        beqz    a0, _check_defeated         // if not 1P, set t0 to 2P's match struct
        nop
        li      t0, config.p2.match         // t0 = match struct (2P's)

        _check_defeated:
        addu    t0, t0, t1                  // t0 = current game in match struct
        lbu     t2, 0x0000(t0)              // t2 = character ID
        lli     t1, Character.id.NONE       // t1 = Character.id.NONE
        beq     t2, t1, _end                // if no character selected, skip to end
        nop

        lbu     t3, 0x0002(t0)              // t3 = stocks remaining
        lbu     t5, 0x0003(t0)              // t5 = portrait_id
        lli     t4, 0x00FF                  // t4 = 0x000000FF (no stocks remaining)
        bnel    t3, t4, _set_char           // if stocks remaining, set to the previous match's char_id
        sw      t5, 0x00B4(v0)              // also save portrait_id

        // otherwise, let's check if the player is CPU
        lbu     t3, 0x0022(v1)              // t3 = player type
        lw      t1, 0x00B4(v0)              // t1 = saved portrait_id
        bnel    t1, t4, pc() + 8            // if saved portrait is not 0xFF, then we'll use that instead of last game's
        or      t5, r0, t1                  // t5 = saved portrait_id
        bnezl   t3, _check_valid_chars      // if CPU, then just keep the selected character
        sw      t5, 0x00B4(v0)              // also save portrait_id

        // let's check if there are valid portraits with this character
        jal     get_valid_portrait_for_char_and_port_
        nop
        addiu   t1, r0, -0x0001             // t1 = -1 (no valid portraits)
        beql    v0, t1, _set_char           // if no valid portraits, set to none
        lli     t2, Character.id.NONE       // t2 = Character.id.NONE
        // if there is a valid portrait, use it!
        or      t2, r0, a1                  // t2 = selected character_id
        lw      t1, 0x0008(sp)              // t1 = CSS player struct
        b       _set_char
        sw      v0, 0x00B4(t1)              // save portrait_id

        _set_char:
        sb      t2, 0x0023(v1)              // set character
        // let's make sure the costume is legal!
        li      t1, Costumes.select_.num_costumes // t1 = num_costumes
        addu    t1, t1, t2                  // t1 = address of character's original costume count
        lbu     t1, 0x0000(t1)              // t1 = character's original costume count

        sll     a1, t2, 0x0002              // a1 = offset in extra costume table
        li      t3, Costumes.extra_costumes_table
        addu    t3, t3, a1                  // t3 = character extra costume table address
        lw      t3, 0x0000(t3)              // t3 = character extra costume table, or 0 if none defined
        beqz    t3, _check_costume_id       // if no extra costumes, skip
        addiu   t1, t1, 0x0001              // t5 = index of first extra costume or max costume_id + 1

        lbu     a1, 0x0003(t3)              // a1 = costumes to skip
        addu    t1, t1, a1                  // t1 = add skipped costumes to costume count
        lbu     a1, 0x0000(t3)              // a1 = number of extra costumes for this character
        addu    t1, t1, a1                  // t1 = max costume_id + 1

        _check_costume_id:
        lbu     a1, 0x0026(v1)              // a1 = costume_id
        sltu    a1, a1, t1                  // a1 = 1 if valid costume, 0 otherwise
        beqzl   a1, _check_valid_chars      // if not a valid costume, set costume_id to 0
        sb      r0, 0x0026(v1)              // set costume_id to 0

        _check_valid_chars:
        // make sure 1P and 2P don't have invalid character IDs selected
        jal     is_character_valid_for_port_
        lbu     a1, 0x0023(v1)              // a1 = selected character_id
        lli     t1, Character.id.NONE       // t1 = Character.id.NONE
        beqzl   v0, _end                    // if not a valid character, set to none
        sh      t1, 0x0022(v1)              // set character to none and panel to human to avoid ungrabbable CPU token

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      v0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lbu     t0, 0x0023(v1)              // original line 2
        j       _return
        lbu     a1, 0x0022(v1)              // original line 1
    }

    // @ Description
    // The following prevents ports 3 and 4 as being seen as plugged in
    scope ignore_ports_3_and_4_: {
        OS.patch_start(0x138560, 0x8013A2E0)
        j       ignore_ports_3_and_4_
        nop
        _return:
        OS.patch_end()

        li      a3, twelve_cb_flag
        lw      a3, 0x0000(a3)              // a3 = 1 if 12cb mode
        beqzl   a3, _end                    // if not 12cb mode, return normally
        sw      a0, 0x0000(v1)              // original line 1

        // otherwise, check if v0 is 2 or 3 and set to unplugged if so
        sltiu   a3, v0, 0x0002              // a3 = 0 if ports 3 or 4
        bnez    a3, _end                    // if not ports 3 or 4, return normally
        sw      a0, 0x0000(v1)              // original line 1

        sw      t0, 0x0000(v1)              // set to unplugged

        _end:
        j       _return
        lb      a3, 0x0001(a2)              // original line 2
    }

    // @ Description
    // Skips rendering the panels for ports 3 and 4
    scope skip_rendering_panels_3_and_4_: {
        // rendering of the panel
        OS.patch_start(0x139328, 0x8013B0A8)
        jal     skip_rendering_panels_3_and_4_._panel
        nop
        nop
        nop
        OS.patch_end()
        // button interaction
        OS.patch_start(0x134A34, 0x801367B4)
        jal     skip_rendering_panels_3_and_4_._button_interaction
        addiu   a2, r0, 0x0002              // original line 2
        OS.patch_end()
        // something related to checking if over a placed token?
        OS.patch_start(0x137938, 0x801396B8)
        jal     skip_rendering_panels_3_and_4_._token_check
        addiu   s0, s0, 0x0001              // original line 1
        OS.patch_end()

        _panel:
        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        bnez    t0, _end_panel              // if 12cb mode, skip rendering panels 3 and 4
        nop

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        jal     0x8013AFC0                  // original line 1
        addiu   a0, r0, 0x0002              // original line 2
        jal     0x8013AFC0                  // original line 3
        addiu   a0, r0, 0x0003              // original line 4

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end_panel:
        jr      ra
        nop

        _button_interaction:
        li      v0, twelve_cb_flag
        lw      v0, 0x0000(v0)              // v0 = 1 if 12cb mode
        beqz    v0, _end_button_interaction // if not 12cb mode, continue normally to check HMN/CPU button interaction for panels 3 and 4
        nop                                 // otherwise, skip to the end of the routine

        j       0x801367E0                  // skip to end of routine
        lw      ra, 0x001C(sp)              // load correct ra

        _end_button_interaction:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0008(sp)              // ~ (0x0004(sp) is not safe for the next routine)

        jal     0x801365D0                  // original line 1
        nop

        lw      ra, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop

        _token_check:
        li      at, twelve_cb_flag
        lw      at, 0x0000(at)              // at = 1 if 12cb mode
        beqzl   at, _end_token_check        // if not 12cb mode, continue normally to check for panels 3 and 4
        lli     at, 0x0004                  // at = 4 - the original value to check for being less than against
        lli     at, 0x0002                  // at = 2 - makes it so we don't check for panels 3 and 4

        _end_token_check:
        jr      ra
        sltu    at, s0, at                  // original line 2, modified from slti
    }

    // @ Description
    // Render 2P panel in 4P position
    scope change_2p_panel_position_: {
        // Blue panel
        OS.patch_start(0x131A14, 0x80133794)
        jal     change_2p_panel_position_._panel
        sll     t9, s0, 0x0002              // original line 1
        OS.patch_end()
        // "2P" image
        OS.patch_start(0x131880, 0x80133600)
        jal     change_2p_panel_position_._2p_image
        addu    t8, t8, t7                  // original line 1
        OS.patch_end()
        // "CP" image
        OS.patch_start(0x131838, 0x801335B8)
        jal     change_2p_panel_position_._cp_image
        addu    t2, t2, t1                  // original line 1
        OS.patch_end()
        // "CP Level" image
        OS.patch_start(0x13504C, 0x80136DCC)
        jal     change_2p_panel_position_._cp_level
        addu    a2, a2, at                  // original line 1
        OS.patch_end()
        // CP Level/Handicap value
        OS.patch_start(0x135238, 0x80136FB8)
        jal     change_2p_panel_position_._cp_handicap_value
        addu    t3, t3, t2                  // original line 1
        OS.patch_end()
        // CP Level/Handicap left arrow
        OS.patch_start(0x134D68, 0x80136AE8)
        jal     change_2p_panel_position_._cp_handicap_left
        addu    t1, t1, s3                  // original line 1
        OS.patch_end()
        // CP Level/Handicap right arrow
        OS.patch_start(0x134DF8, 0x80136B78)
        jal     change_2p_panel_position_._cp_handicap_right
        addu    t9, t9, s3                  // original line 1
        OS.patch_end()
        // "Handicap" image
        OS.patch_start(0x135000, 0x80136D80)
        jal     change_2p_panel_position_._handicap
        addu    a2, a2, at                  // original line 1
        OS.patch_end()
        // HMN/CPU button initial
        OS.patch_start(0x1316D0, 0x80133450)
        jal     change_2p_panel_position_._hmn_button
        addu    t6, t6, t5                  // original line 1
        OS.patch_end()
        // HMN/CPU button when pressed
        OS.patch_start(0x130C58, 0x801329D8)
        jal     change_2p_panel_position_._hmn_button_pressed
        addu    t5, t5, t4                  // original line 1
        OS.patch_end()
        // sliding doors
        OS.patch_start(0x130EA4, 0x80132C24)
        j       change_2p_panel_position_._sliding_doors
        addu    v1, v1, a0                  // original line 1
        _return_sliding_doors:
        OS.patch_end()
        // sliding doors render function
        OS.patch_start(0x13194C, 0x801336CC)
        jal     change_2p_panel_position_._sliding_doors_render
        lw      t6, 0x0004(t5)              // original line 1
        OS.patch_end()
        // cursor initial position
        OS.patch_start(0x1370C0, 0x80138E40)
        jal     change_2p_panel_position_._cursor
        lw      t3, 0x0008(t1)              // original line 1
        OS.patch_end()
        // character
        OS.patch_start(0x132E2C, 0x80134BAC)
        jal     change_2p_panel_position_._character
        lw      t0, 0x0020(sp)              // original line 1
        OS.patch_end()
        // name and series logo
        OS.patch_start(0x130D98, 0x80132B18)
        jal     change_2p_panel_position_._name_and_logo
        addu    a3, a3, v1                  // original line 1
        OS.patch_end()
        // white circle
        OS.patch_start(0x138004, 0x80139D84)
        jal     change_2p_panel_position_._white_circle
        swc1    f6, 0x001C(t9)              // original line 2
        OS.patch_end()
        // HMN/CPU button interaction
        OS.patch_start(0x133D44, 0x80135AC4)
        j       change_2p_panel_position_._hmn_button_press
        addu    v1, v1, a1                  // original line 1
        _return_hmn_button_press:
        OS.patch_end()
        // CPU Level/Handicap right arrow button interaction
        OS.patch_start(0x133B84, 0x80135904)
        j       change_2p_panel_position_._right_arrow_press
        addu    v1, v1, a1                  // original line 1
        _return_right_arrow_press:
        OS.patch_end()
        // CPU Level/Handicap left arrow button interaction
        OS.patch_start(0x133C64, 0x801359E4)
        j       change_2p_panel_position_._left_arrow_press
        addu    v1, v1, a1                  // original line 1
        _return_left_arrow_press:
        OS.patch_end()

        _panel:
        beqz    s0, _end_panel              // skip if not port 2
        nop
        li      t3, twelve_cb_flag
        lw      t3, 0x0000(t3)              // t3 = 1 if 12cb mode
        bnezl   t3, _end_panel              // if 12cb mode, use 4p's x position
        lli     t1, 0x00CF                  // t1 = 4p's x position

        _end_panel:
        jr      ra
        addiu   t3, t1, 0x0016              // original line 2

        _2p_image:
        beqz    t7, _end_2p_image           // skip if not port 2
        nop
        li      t9, twelve_cb_flag
        lw      t9, 0x0000(t9)              // t9 = 1 if 12cb mode
        bnezl   t9, _end_2p_image           // if 12cb mode, use 4p's x position
        lli     t8, 0x00CF                  // t8 = 4p's x position

        _end_2p_image:
        jr      ra
        addiu   t9, t8, 0x0016              // original line 2

        _cp_image:
        beqz    t1, _end_cp_image           // skip if not port 2
        nop
        li      t3, twelve_cb_flag
        lw      t3, 0x0000(t3)              // t3 = 1 if 12cb mode
        bnezl   t3, _end_cp_image           // if 12cb mode, use 4p's x position
        lli     t2, 0x00CF                  // t2 = 4p's x position

        _end_cp_image:
        jr      ra
        addiu   t3, t2, 0x001A              // original line 2

        _cp_level:
        beqz    at, _end_cp_level           // skip if not port 2
        nop
        li      t7, twelve_cb_flag
        lw      t7, 0x0000(t7)              // t7 = 1 if 12cb mode
        bnezl   t7, _end_cp_level           // if 12cb mode, use 4p's x position
        lli     a2, 0x00CF                  // a2 = 4p's x position

        _end_cp_level:
        jr      ra
        addiu   t7, a2, 0x0022              // original line 2

        _cp_handicap_value:
        beqz    t2, _end_cp_handicap_value  // skip if not port 2
        nop
        li      t4, twelve_cb_flag
        lw      t4, 0x0000(t4)              // t4 = 1 if 12cb mode
        bnezl   t4, _end_cp_handicap_value  // if 12cb mode, use 4p's x position
        lli     t3, 0x00CF                  // t3 = 4p's x position

        _end_cp_handicap_value:
        jr      ra
        addiu   t4, t3, 0x0043              // original line 2

        _cp_handicap_left:
        beqz    s3, _end_cp_handicap_left   // skip if not port 2
        nop
        li      t2, twelve_cb_flag
        lw      t2, 0x0000(t2)              // t2 = 1 if 12cb mode
        bnezl   t2, _end_cp_handicap_left   // if 12cb mode, use 4p's x position
        lli     t1, 0x00CF                  // t1 = 4p's x position

        _end_cp_handicap_left:
        jr      ra
        addiu   t2, t1, 0x0019              // original line 2

        _cp_handicap_right:
        beqz    s3, _end_cp_handicap_right  // skip if not port 2
        nop
        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        bnezl   t0, _end_cp_handicap_right  // if 12cb mode, use 4p's x position
        lli     t9, 0x00CF                  // t9 = 4p's x position

        _end_cp_handicap_right:
        jr      ra
        addiu   t0, t9, 0x004F              // original line 2

        _handicap:
        beqz    at, _end_handicap           // skip if not port 2
        nop
        li      t4, twelve_cb_flag
        lw      t4, 0x0000(t4)              // t4 = 1 if 12cb mode
        bnezl   t4, _end_handicap           // if 12cb mode, use 4p's x position
        lli     a2, 0x00CF                  // t2 = 4p's x position

        _end_handicap:
        jr      ra
        addiu   t4, a2, 0x0023              // original line 2

        _hmn_button:
        beqz    t5, _end_hmn_button         // skip if not port 2
        nop
        li      t7, twelve_cb_flag
        lw      t7, 0x0000(t7)              // t7 = 1 if 12cb mode
        bnezl   t7, _end_hmn_button         // if 12cb mode, use 4p's x position
        lli     t6, 0x00CF                  // t6 = 4p's x position

        _end_hmn_button:
        jr      ra
        addiu   t7, t6, 0x0040              // original line 2

        _hmn_button_pressed:
        beqz    t4, _end_hmn_button_pressed // skip if not port 2
        nop
        li      t6, twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        bnezl   t6, _end_hmn_button_pressed // if 12cb mode, use 4p's x position
        lli     t5, 0x00CF                  // t5 = 4p's x position

        _end_hmn_button_pressed:
        jr      ra
        addiu   t6, t5, 0x0040              // original line 2

        _sliding_doors:
        beqz    a0, _end_sliding_doors      // skip if not port 2
        nop
        li      t9, twelve_cb_flag
        lw      t9, 0x0000(t9)              // t9 = 1 if 12cb mode
        bnezl   t9, _end_sliding_doors      // if 12cb mode, use 4p's x position
        lli     v1, 0x00CF                  // v1 = 4p's x position

        _end_sliding_doors:
        j       _return_sliding_doors
        addu    t9, t8, v1                  // original line 2

        _sliding_doors_render:
        li      t7, twelve_cb_flag
        lw      t7, 0x0000(t7)              // t7 = 1 if 12cb mode
        bnezl   t7, _end_sliding_doors_render // if 12cb mode, use 4p's render routine
        lw      t6, 0x000C(t5)              // original line 1, modified to use 4p's render routine

        _end_sliding_doors_render:
        jr      ra
        lw      t7, 0x0000(t5)              // original line 2

        _cursor:
        li      t2, twelve_cb_flag
        lw      t2, 0x0000(t2)              // t2 = 1 if 12cb mode
        bnezl   t2, _end_cursor             // if 12cb mode, use 4p's initial cursor position
        lw      t3, 0x0018(t1)              // original line 1, modified to use 4p's x position

        _end_cursor:
        jr      ra
        lw      t2, 0x000C(t1)              // original line 2

        _character:
        beqz    t3, _end_character          // skip if not port 2
        nop
        li      t4, twelve_cb_flag
        lw      t4, 0x0000(t4)              // t4 = 1 if 12cb mode
        bnezl   t4, _end_character          // if 12cb mode, use 4p's x position
        lli     t3, 0x0003                  // t3 = port 4

        _end_character:
        jr      ra
        sll     t4, t3, 0x0002              // original line 2

        _name_and_logo:
        beqz    v1, _end_name_and_logo      // skip if not port 2
        nop
        li      t1, twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb mode
        bnezl   t1, _end_name_and_logo      // if 12cb mode, use 4p's x position
        lli     a3, 0x00CF                  // t2 = 4p's x position

        _end_name_and_logo:
        jr      ra
        addiu   t1, a3, 0x0018              // original line 2

        _white_circle:
        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        bnezl   t0, _end_white_circle       // if 12cb mode, use 4p's x position
        addiu   s2, s2, 0x0690              // t2 = 4p's x position

        _end_white_circle:
        jr      ra
        addiu   s2, s2, 0x0348              // original line 1

        _hmn_button_press:
        beqz    a1, _end_hmn_button_press   // skip if not port 2
        nop
        li      t6, twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        bnezl   t6, _end_hmn_button_press   // if 12cb mode, use 4p's x position
        lli     v1, 0x00CF                  // v1 = 4p's x position

        _end_hmn_button_press:
        j       _return_hmn_button_press
        lw      v0, 0x0074(a0)              // original line 2

        _right_arrow_press:
        beqz    a1, _end_right_arrow_press  // skip if not port 2
        nop
        li      t6, twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        bnezl   t6, _end_right_arrow_press  // if 12cb mode, use 4p's x position
        lli     v1, 0x00CF                  // v1 = 4p's x position

        _end_right_arrow_press:
        j       _return_right_arrow_press
        lw      v0, 0x0074(a0)              // original line 2

        _left_arrow_press:
        beqz    a1, _end_left_arrow_press   // skip if not port 2
        nop
        li      t6, twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        bnezl   t6, _end_left_arrow_press   // if 12cb mode, use 4p's x position
        lli     v1, 0x00CF                  // v1 = 4p's x position

        _end_left_arrow_press:
        j       _return_left_arrow_press
        lw      v0, 0x0074(a0)              // original line 2
    }

    // @ Description
    // This function returns what character is selected by the token's position.
    // It is called from CharacterSelect.get_character_id_.
    // @ Returns
    // v0 - character id
    scope get_character_id_: {
        constant LEFT_GRID_START_X(START_X - 11)
        constant LEFT_GRID_END_X(START_X - 12 + (PORTRAIT_WIDTH * 4))
        constant RIGHT_GRID_START_X(START_X + (PORTRAIT_WIDTH * 4) + 5)
        constant RIGHT_GRID_END_X(START_X + (PORTRAIT_WIDTH * 8) + 4)

        // a0 = player index (port 0 - 3)
        // a1 = (int) xpos
        // v1 = (int) ypos
        // a3 = CSS player struct most of the time, but sometimes it's not, so don't use it

        addiu   v1, v1, -START_Y            // v1 = ypos - START_Y

        li      a3, CharacterSelect.CSS_PLAYER_STRUCT
        bnezl   a0, pc() + 8                // if not p1, set t1 to p2's CSS player struct
        addiu   a3, a3, 0x00BC              // a3 = p2's CSS player struct

        // we'll save portrait_id at 0x00B4 in the CSS player struct since it doesn't appear to be used
        addiu   t0, r0, -0x0001             // set portrait_id to -1 for non-valid entries
        lw      t1, 0x0084(a3)              // t1 = 0 if HMN, 1 if CPU, 2 if N/A
        beqzl   t1, pc() + 8                // if not HMN, don't initialize portrait_id to -1 (prevents CPU autoposition bug with white flash)
        sw      t0, 0x00B4(a3)              // initialize portrait_id

        lli     t0, LEFT_GRID_END_X
        bnezl   a0, _greater_than_check     // if port 0, then use left grid end x
        lli     t0, RIGHT_GRID_END_X        // otherwise, use right grid end x

        _greater_than_check:
        sltu    t1, t0, a1                  // t1 = 1 if x pos too big to be valid for this port
        bnez    t1, _end                    // if x pos to big, skip to end
        lli     v0, Character.id.NONE       // and return id.NONE

        lli     t0, LEFT_GRID_START_X
        bnezl   a0, _less_than_check        // if port 0, then use left grid start x
        lli     t0, RIGHT_GRID_START_X      // otherwise, use right grid start x

        _less_than_check:
        sltu    t1, a1, t0                  // t1 = 1 if x pos too small to be valid for this port
        bnez    t1, _end                    // if x pos to small, skip to end
        lli     v0, Character.id.NONE       // and return id.NONE

        subu    a1, a1, t0                  // a1 = x pos, 0 adjusted

        // calculate id
        lli     t0, PORTRAIT_WIDTH          // t0 = PORTRAIT_WIDTH
        divu    a1, t0                      // ~
        mflo    t1                          // t1 = x index
        lli     t0, PORTRAIT_HEIGHT         // t0 = PORTRAIT_HEIGHT
        divu    v1, t0                      // ~
        mflo    t2                          // t2 = y index

        // index = (row * NUM_COLUMNS) + column
        lli     t0, NUM_COLUMNS             // ~
        multu   t0, t2                      // ~
        mflo    t0                          // t0 = (row * NUM_COLUMNS)
        addu    t0, t0, t1                  // t0 = index

        // if port 1 (2P), then shift portrait ID over 4 slots
        bnezl   a0, pc() + 8
        addiu   t0, 0x0004                  // t0 = index for 2P

        // return id.NONE if index is too large for table
        lli     t1, NUM_PORTRAITS           // t1 = NUM_PORTRAITS
        sltu    t2, t0, t1                  // if (t0 < t1), t2 = 0
        beqz    t2, _end                    // explained above lol
        lli     v0, Character.id.NONE       // also explained above lol

        sw      t0, 0x00B4(a3)              // save portrait_id

        li      t1, config.status           // t1 = battle status
        lw      t1, 0x0000(t1)              // ~
        sltiu   t1, t1, config.STATUS_COMPLETE // t1 = 0 if match complete
        beqz    t1, _get_char_id            // if match complete, skip setting match struct
        nop

        li      t1, config.p1.match
        li      t2, config.p2.match
        bnezl   a0, pc() + 8
        or      t1, r0, t2                  // t1 = match struct
        li      t2, config.current_game
        lw      t2, 0x0000(t2)              // t2 = current_game
        addiu   t2, t2, 0x0001              // t2 = next game
        sll     t2, t2, 0x0003              // t2 = offset to next game in match struct
        addu    t1, t1, t2                  // t1 = game struct
        sb      t0, 0x0003(t1)              // save portrait_id in match struct

        _get_char_id:
        li      t1, CharacterSelect.id_table_pointer
        lw      t1, 0x0000(t1)              // t1 = id_table
        addu    t0, t0, t1                  // t1 = id_table[index]
        lbu     v0, 0x0000(t0)              // v0 = character id

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This gets the portrait ID for the given character ID, which for us depends on port.
    // This will return 0x00 if the character is not valid for the port.
    // This is called from patches in CharacterSelect.token_autoposition_ and CharacterSelect.place_token_from_id_, as well as this file.
    // @ Arguments
    // a0 - character_id
    // a1 - port_id
    // @ Returns
    // v0 - portrait_id
    scope get_portrait_id_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~

        li      t1, config.p1.character_set // t1 = p1's character set index
        li      t2, config.p2.character_set
        bnezl   a1, pc() + 8                // if player 2, set t1 to p2's character set index
        or      t1, r0, t2                  // t1 = p2's character set index
        lw      t1, 0x0000(t1)              // t2 = p2 character set index

        li      t2, character_set_table
        sltiu   at, t1, NUM_PRESETS         // at = 0 if custom
        beqzl   at, _custom                 // if they are using custom, adjust to correct custom tables and branch to custom logic
        addu    t1, t1, a1                  // t1 = t1 + 1 if p2

        sll     t1, t1, 0x0004              // t1 = offset in character set table
        addu    t1, t1, t2                  // t1 = character set table array
        lw      t0, 0x0008(t1)              // t0 = portrait_id_table
        addu    t0, t0, a0                  // t0 = portrait_id_table + character id
        lbu     v0, 0x0000(t0)              // v0 = portrait_id for character in a0

        // The portrait IDs will always be right for 2P's character but too high by 4 for 1P
        lli     t0, 0x00FF                  // t0 = 0x000000FF (indicates the character really should be Character.id.NONE)
        beql    v0, t0, _end                // if Character.id.NONE, return 0 as the game does
        lli     v0, 0x0000                  // v0 = 0
        sll     t0, a1, 0x0002              // t0 = 0 if port 0, 4 if port 1
        addiu   t0, t0, -0x0004             // t0 = -4 if port 0, 0 if port 1
        b       _end
        addu    v0, v0, t0                  // adjust portrait_id if port 0 down by 4

        _custom:
        sll     t1, t1, 0x0004              // t1 = offset in character set table
        addu    t1, t1, t2                  // t1 = character set table array
        lw      t0, 0x0000(t1)              // t0 = id_table

        // 0x00B4 may hold the right portrait_id, so let's check that first
        li      at, Global.current_screen   // ~
        lbu     at, 0x0000(at)              // at = current screen
        lli     v0, 0x10                    // v0 = vs css screen id
        bne     at, v0, _do_loop            // if screen id != vs css, skip
        nop
        li      at, CharacterSelect.CSS_PLAYER_STRUCT
        bnezl   a1, pc() + 8                // if player 2, set p2's CSS player struct
        addiu   at, at, 0x00BC              // at = p2's CSS player struct
        lw      v0, 0x00B4(at)              // v0 = portrait_id, maybe
        bltz    v0, _do_loop                // if not a valid portrait_id, skip
        addu    at, t0, v0                  // at = address of character_id that may be the right one
        lbu     at, 0x0000(at)              // at = character_id to compare
        beq     at, a0, _end                // if the character_ids match, then use this portrait_id
        nop

        _do_loop:
        lli     t2, NUM_SLOTS - 1           // t2 = loop until this number
        lli     v0, 0x0000                  // v0 = loop index/portrait_id

        _loop:
        lbu     t1, 0x0000(t0)              // t1 = character_id
        beq     t1, a0, _end_loop           // if the character_ids match, then this portrait_id holds this character_id
        nop
        addiu   t0, t0, 0x0001              // t0 = increment id_table address
        bne     v0, t2, _loop               // loop while portrait_id < max portrait_id
        addiu   v0, v0, 0x0001              // v0 = portrait_id++

        b       _end                        // if not found, return 0 as the game does
        lli     v0, 0x0000                  // v0 = 0

        _end_loop:
        sll     t0, a1, 0x0002              // t0 = 0 if port 0, 4 if port 1
        addu    v0, v0, t0                  // adjust portrait_id if port 1 up by 4

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This gets the portrait ID for the given character ID, which for us depends on port.
    // This will return 0xFF if the character is not valid for the port.
    // @ Arguments
    // a0 - character_id
    // a1 - port_id
    // @ Returns
    // v0 - portrait_id
    scope get_valid_portrait_id_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~

        li      t1, config.p1.character_set // t1 = p1's character set index
        li      t2, config.p2.character_set
        bnezl   a1, pc() + 8                // if player 2, set t1 to p2's character set index
        or      t1, r0, t2                  // t1 = p2's character set index
        lw      t1, 0x0000(t1)              // t2 = p2 character set index

        li      t2, character_set_table
        sltiu   at, t1, NUM_PRESETS         // at = 0 if custom
        beqzl   at, _custom                 // if they are using custom, adjust to correct custom tables and branch to custom logic
        addu    t1, t1, a1                  // t1 = t1 + 1 if p2

        sll     t1, t1, 0x0004              // t1 = offset in character set table
        addu    t1, t1, t2                  // t1 = character set table array
        lw      t0, 0x0008(t1)              // t0 = portrait_id_table
        addu    t0, t0, a0                  // t0 = portrait_id_table + character id
        lbu     v0, 0x0000(t0)              // v0 = portrait_id for character in a0

        // The portrait IDs will always be right for 2P's character but too high by 4 for 1P
        lli     t0, 0x00FF                  // t0 = 0x000000FF (indicates the character really should be Character.id.NONE)
        beq     v0, t0, _end                // if Character.id.NONE, return
        nop
        sll     t0, a1, 0x0002              // t0 = 0 if port 0, 4 if port 1
        addiu   t0, t0, -0x0004             // t0 = -4 if port 0, 0 if port 1
        b       _end
        addu    v0, v0, t0                  // adjust portrait_id if port 1 down by 4

        _custom:
        sll     t1, t1, 0x0004              // t1 = offset in character set table
        addu    t1, t1, t2                  // t1 = character set table array
        lw      t0, 0x0000(t1)              // t0 = id_table

        // 0x00B4 may hold the right portrait_id, so let's check that first
        li      at, Global.current_screen   // ~
        lbu     at, 0x0000(at)              // at = current screen
        lli     v0, 0x10                    // v0 = vs css screen id
        bne     at, v0, _do_loop            // if screen id != vs css, skip
        nop
        li      at, CharacterSelect.CSS_PLAYER_STRUCT
        bnezl   a1, pc() + 8                // if player 2, set p2's CSS player struct
        addiu   at, at, 0x00BC              // at = p2's CSS player struct
        lw      v0, 0x00B4(at)              // v0 = portrait_id, maybe
        bltz    v0, _do_loop                // if not a valid portrait_id, skip
        addu    at, t0, v0                  // at = address of character_id that may be the right one
        lbu     at, 0x0000(at)              // at = character_id to compare
        beq     at, a0, _end                // if the character_ids match, then use this portrait_id
        nop

        _do_loop:
        lli     t2, NUM_SLOTS - 1           // t2 = loop until this number
        lli     v0, 0x0000                  // v0 = loop index/portrait_id

        _loop:
        lbu     t1, 0x0000(t0)              // t1 = character_id
        beq     t1, a0, _end_loop           // if the character_ids match, then this portrait_id holds this character_id
        nop
        addiu   t0, t0, 0x0001              // t0 = increment id_table address
        bne     v0, t2, _loop               // loop while portrait_id < max portrait_id
        addiu   v0, v0, 0x0001              // v0 = portrait_id++

        b       _end                        // if not found, return 0x000000FF
        lli     v0, 0x00FF                  // v0 = 0x000000FF

        _end_loop:
        sll     t0, a1, 0x0002              // t0 = 0 if port 0, 4 if port 1
        addu    v0, v0, t0                  // adjust portrait_id if port 1 up by 4

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This determines the last match's portrait and number of stocks available for the given port.
    // @ Arguments
    // a0 - port_id
    // @ Returns
    // v0 - stocks remaining (1-based)
    // v1 - portrait_id
    scope get_last_match_portrait_and_stocks_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~

        lli     v1, 0x00FF                  // if not started, we'll return portrait_id as none (0x000000FF)

        li      t0, config.status
        lw      t1, 0x0000(t0)              // t1 = battle status
        beqzl   t1, _end                    // if not started, return num_stocks
        lw      v0, 0x0004(t0)              // v0 = num_stocks

        li      t1, config.p1.match         // t1 = config.p1.match
        li      t0, config.p2.match
        bnezl   a0, pc() + 8                // if p2's token, then set t1 to config.p2.match
        or      t1, r0, t0                  // t1 = config.p2.match

        li      t0, config.current_game
        lw      t0, 0x0000(t0)              // t0 = current game
        sll     t0, t0, 0x0003              // t0 = t0 * 8 (offset to match struct)
        addu    t1, t1, t0                  // t1 = address of match struct for current game
        lbu     v0, 0x0002(t1)              // v0 = remaining stocks, 0-based
        lbu     v1, 0x0003(t1)              // v1 = portrait_id
        lli     t0, 0x00FF                  // t0 = 0x000000FF (no remaining stocks)
        beql    v0, t0, _end                // if there are no remaining stocks, adjust to -1
        addiu   v0, r0, -0x0001             // v0 = -1

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra                          // return
        addiu   v0, v0, 0x0001              // v0 = remaining stocks, actually
    }

    // @ Description
    // This determines the number of stocks remaining for the given character and port.
    // @ Arguments
    // a0 - port_id
    // a1 - character_id
    // @ Returns
    // v0 - stocks remaining (1-based)
    scope get_stocks_remaining_for_char_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~
        sw      a1, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~

        or      a1, r0, a0                  // a1 = port_id
        jal     get_valid_portrait_id_      // v0 = portrait_id
        lw      a0, 0x0010(sp)              // a0 = character_id
        lli     t0, 0x00FF                  // t0 = 0x000000FF (indicates the character ID is invalid for this port)
        beql    v0, t0, _end                // if invalid character, return 0
        addiu   v0, r0, -0x0001             // v0 = -1

        li      t0, config.stocks_by_portrait_id
        addu    t0, t0, v0                  // t0 = stock count address
        lb      v0, 0x0000(t0)              // v0 = stocks remaining

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        lw      a1, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra                          // return
        addiu   v0, v0, 0x0001              // v0 = remaining stocks, actually
    }

    // @ Description
    // This determines the given character is valid for the given port.
    // It only considers the character_id, not the stocks remaining.
    // @ Arguments
    // a0 - port_id
    // a1 - character_id
    // @ Returns
    // v0 - (bool) is_valid
    scope is_character_valid_for_port_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~

        li      t1, config.p1.character_set // t1 = p1's character set index
        li      t2, config.p2.character_set
        bnezl   a0, pc() + 8                // if player 2, set t1 to p2's character set index
        or      t1, r0, t2                  // t1 = p2's character set index
        lw      t1, 0x0000(t1)              // t2 = p2 character set index

        li      t2, character_set_table
        sltiu   at, t1, NUM_PRESETS         // at = 0 if custom
        beqzl   at, pc() + 8                // if they are using custom, adjust to correct custom tables
        addu    t1, t1, a0                  // t1 = t1 + 1 if p2

        sll     t1, t1, 0x0004              // t1 = offset in character set table
        addu    t1, t1, t2                  // t1 = character set table array
        lw      t0, 0x0000(t1)              // t0 = id_table
        lli     t2, NUM_SLOTS - 1           // t2 = loop until this number
        lli     v0, 0x0000                  // v0 = loop index/portrait_id

        _loop:
        lbu     t1, 0x0000(t0)              // t1 = character_id
        beql    t1, a1, _end                // if the character_ids match, then this portrait_id holds this character_id
        lli     v0, OS.TRUE                 // return TRUE
        addiu   t0, t0, 0x0001              // t0 = increment id_table address
        bne     v0, t2, _loop               // loop while portrait_id < max portrait_id
        addiu   v0, v0, 0x0001              // v0 = portrait_id++

        b       _end                        // if not found, return FALSE
        lli     v0, OS.FALSE

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This determines the first valid portrait for the given character and port.
    // It considers a valid portrait to be one with stocks remaining.
    // @ Arguments
    // a0 - port_id
    // a1 - character_id
    // @ Returns
    // v0 - portrait_id (-1 if none)
    scope get_valid_portrait_for_char_and_port_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      t4, 0x0018(sp)              // ~

        li      t1, config.p1.character_set // t1 = p1's character set index
        li      t2, config.p2.character_set
        bnezl   a0, pc() + 8                // if player 2, set t1 to p2's character set index
        or      t1, r0, t2                  // t1 = p2's character set index
        lw      t1, 0x0000(t1)              // t2 = p2 character set index

        li      t2, character_set_table
        sltiu   at, t1, NUM_PRESETS         // at = 0 if custom
        beqzl   at, pc() + 8                // if they are using custom, adjust to correct custom tables
        addu    t1, t1, a0                  // t1 = t1 + 1 if p2

        sll     t1, t1, 0x0004              // t1 = offset in character set table
        addu    t1, t1, t2                  // t1 = character set table array
        lw      t0, 0x0000(t1)              // t0 = id_table
        lli     t2, NUM_SLOTS - 1           // t2 = loop until this number
        lli     v0, 0x0000                  // v0 = loop index/portrait_id
        li      t3, config.stocks_by_portrait_id
        lli     t4, NUM_COLUMNS

        _loop:
        divu    v0, t4                      // t1 = column
        mfhi    t1                          // ~
        lli     at, 0x0003                  // at = 4
        sltu    t1, at, t1                  // t1 = 0 if left grid, 1 if right grid
        bne     t1, a0, _next               // if not a valid portrait_id for this port, go to next
        nop
        lbu     t1, 0x0000(t0)              // t1 = character_id
        bne     t1, a1, _next               // if the character_ids don't match, then go to next
        nop
        lbu     t1, 0x0000(t3)              // t1 = stocks remaining for this portrait
        lli     at, 0x00FF                  // at = 0x000000FF (no stocks remaining)
        bne     t1, at, _end                // if stocks remaining, then return portrait_id
        nop
        _next:
        addiu   t0, t0, 0x0001              // t0 = increment id_table address
        addiu   t3, t3, 0x0001              // t3 = increment config.stocks_by_portrait_id address
        bne     v0, t2, _loop               // loop while portrait_id < max portrait_id
        addiu   v0, v0, 0x0001              // v0 = portrait_id++

        b       _end                        // if not found, return -1
        addiu   v0, r0, -0x0001             // v0 = -1

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      t4, 0x0018(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Determines if the given portrait has been played in a game.
    // @ Arguments
    // a0 - portrait
    // a1 - port
    scope was_portrait_played_: {
        li      t0, config.p1.match
        bnezl   a1, pc() + 8                      // if p2, use p2 array
        addiu   t0, t0, config.p2.match - config.p1.match
        lli     v0, 0x0000                        // v0 = 0 (portrait not played)
        li      t2, config.current_game
        lw      t2, 0x0000(t2)                    // t2 = current game
        addiu   t2, t2, 0x0001                    // t2 = offset in match array to stop looping at
        sll     t2, t2, 0x0003                    // ~
        addu    t2, t0, t2                        // t2 = address to stop looping at

        _loop:
        beq     t0, t2, _end                      // if we got to the current game, then quit looping
        lb      t1, 0x0003(t0)                    // t1 = portrait_id
        beql    t1, a0, _end                      // if we found the portrait_id, return
        lli     v0, 0x0001                        // v0 = 1 (portrait was played)
        b       _loop                             // loop while there are still games to check
        addiu   t0, t0, 0x0008                    // t0 = next game struct

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This will update white flash portrait positioning.
    // This is called from CharacterSelect.set_white_flash_texture on the VS CSS
    scope adjust_white_flash_position_: {
        li      t3, twelve_cb_flag
        lw      t3, 0x0000(t3)          // t3 = 1 if 12cb, 0 if not
        beqz    t3, _end                // skip if not 12cb
        nop

        addiu   t3, r0, 0x0007          // t3 = 7
        sltiu   t4, t0, 0x0004          // t4 = 1 if left grid, 0 if right grid
        beqzl   t4, pc() + 8            // if right grid, then adjust right instead of left
        lli     t3, 0x0017              // t3 = 23

        addu    t2, t2, t3              // t2 = adjusted x position
        addiu   t2, t2, PORTRAIT_WIDTH - CharacterSelect.PORTRAIT_WIDTH + START_X - CharacterSelect.START_X + START_VISUAL - CharacterSelect.START_VISUAL

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Disables Free-for-all/Team Battle toggling
    scope disable_mode_toggle_: {
        OS.patch_start(0x1334F0, 0x80135270)
        j       disable_mode_toggle_
        lw      v0, 0x0074(a0)              // original line 1
        _return:
        OS.patch_end()

        li      at, twelve_cb_flag
        lw      at, 0x0000(at)              // at = 1 if 12cb mode
        bnez    at, _end                    // if 12cb mode, skip to the end of the routine
        lui     at, 0x41A0                  // original line 2

        j       _return
        nop

        _end:
        jr      ra
        or      v0, r0, r0                  // return 0 for v0 to signal no click
    }

    // @ Description
    // Updates stock related fields given the stock value.
    // @ Arguments
    // a0 - stocks
    scope update_stock_fields_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0020(sp)              // ~
        sw      t2, 0x0024(sp)              // ~
        sw      t3, 0x0028(sp)              // ~
        sw      t9, 0x002C(sp)              // ~

        li      t1, config.num_stocks
        lw      t0, 0x0000(t1)              // t0 = previous stock count
        beq     t0, a0, _end                // if stock count is unchanged, skip updating stuff
        sw      a0, 0x0000(t1)              // store stock count

        lli     t0, 12                      // t0 = 12 (number of characters)
        addiu   t9, a0, 0x0001              // t9 = stocks, not 0-based
        multu   t0, t9                      // t0 = stocks remaining
        mflo    t0                          // ~
        li      t1, config.p1.stocks_remaining
        sw      t0, 0x0000(t1)              // initialize stocks remaining
        li      t1, config.p2.stocks_remaining
        sw      t0, 0x0000(t1)              // initialize stocks remaining
        addiu   t9, t9, -0x0001             // t9 = stocks, 0-based

        li      t1, config.stocks_by_portrait_id
        lli     t2, 6                       // t3 = 24 portraits / 4 set each loop
        _loop:
        sb      t9, 0x0000(t1)              // update stocks remaining for this portrait
        sb      t9, 0x0001(t1)              // update stocks remaining for this portrait
        sb      t9, 0x0002(t1)              // update stocks remaining for this portrait
        sb      t9, 0x0003(t1)              // update stocks remaining for this portrait
        addiu   t2, t2, -0x0001             // t2--
        bnez    t2, _loop                   // loop over all portraits
        addiu   t1, t1, 0x0004              // move to next group of 4

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0020(sp)              // ~
        lw      t2, 0x0024(sp)              // ~
        lw      t3, 0x0028(sp)              // ~
        lw      t9, 0x002C(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Force Free-for-all mode with Stock (no timer) when entering CSS
    // Also sets up portrait_id field in CSS player structs for handling duplicates in custom char sets
    scope force_ffa_and_stock_: {
        OS.patch_start(0x1391A0, 0x8013AF20)
        j       force_ffa_and_stock_
        sw      s1, 0x001C(sp)              // original line 1
        nop
        _return:
        OS.patch_end()

        // t9 = stocks

        li      t1, twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb mode
        beqzl   t1, _end                    // if not 12cb mode, then skip
        lbu     t1, 0x0003(s2)              // original line 3

        // set up important pointers
        li      t0, CharacterSelect.id_table_pointer
        li      t1, id_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_id_table_pointer
        li      t1, portrait_id_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_offset_table_pointer
        li      t1, portrait_offset_table
        sw      t1, 0x0000(t0)

        li      t0, CharacterSelect.portrait_x_position_pointer
        li      t1, portrait_x_position
        sw      t1, 0x0000(t0)

        // set up stocks and settings
        li      t1, config.num_stocks
        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        bnezl   t0, _set_ffa_and_stock      // if not started, skip setting stock_count
        lw      t9, 0x0000(t1)              // t9 = saved stock count

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        jal     update_stock_fields_
        or      a0, r0, t9                  // a0 = new stock count

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        _set_ffa_and_stock:
        lui     t0, 0x8014
        sw      t9, 0xBD80(t0)              // save stock count displayed in counter

        // restore portrait_id
        li      t0, config.current_game
        lw      t0, 0x0000(t0)              // t0 = current game
        sll     t0, t0, 0x0003              // t0 = offset to game struct
        li      t1, config.p1.match
        addu    t1, t1, t0                  // t1 = p1 game struct
        lbu     t1, 0x0003(t1)              // t1 = portrait_id
        li      t3, CharacterSelect.CSS_PLAYER_STRUCT
        sw      t1, 0x00B4(t3)              // save portrait_id in p1 CSS player struct
        li      t1, config.p2.match
        addu    t1, t1, t0                  // t1 = p2 game struct
        lbu     t1, 0x0003(t1)              // t1 = portrait_id
        addiu   t3, t3, 0x00BC              // t3 = p2 CSS player struct
        sw      t1, 0x00B4(t3)              // save portrait_id in p2 CSS player struct

        lli     t0, 0x0000                  // t0 = 0 for FFA
        lli     t1, 0x0002                  // t1 = 2 for Stock

        _end:
        j       _return
        sw      t0, 0xBDA8(at)              // original line 2
    }

    // @ Description
    // Modify the announcer clip when entering CSS
    scope update_announcer_on_entry_: {
        // original FGM call
        OS.patch_start(0x139588, 0x8013B308)
        jal     update_announcer_on_entry_
        nop                                 // original line 2
        jal     0x800269C0                  // original line 3
        nop                                 // originally set a0 to Free For All fgm_id
        OS.patch_end()
        // add WINS
        OS.patch_start(0x138BD0, 0x8013A950)
        jal     update_announcer_on_entry_._wins
        lw      t9,  0x0000(s0)             // original line 1
        OS.patch_end()

        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqzl   t0, _default                // if not 12cb mode, use default fgm_id
        addiu   a0, r0, 0x0200              // original line 4

        // otherwise, return with custom fgm_id

        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        lli     a0, config.STATUS_COMPLETE  // a0 = STATUS_COMPLETE
        bnel    t0, a0, _return             // if 12cb not complete, play "12-character battle"
        addiu   a0, r0, FGM.announcer.css.TWELVECB

        // otherwise, the announcer will say "Player X Wins", which requires 2 FGM calls
        li      t0, config.p1.stocks_remaining
        lw      t0, 0x0000(t0)              // t0 = p1 stocks remaining
        addiu   a0, r0, FGM.announcer.fight.PLAYER_1
        beqzl   t0, _return                 // if p1 has no stocks remaining, p2 won
        addiu   a0, r0, FGM.announcer.fight.PLAYER_2

        _return:
        jr      ra
        nop

        _default:
        bnez    t6, _j_0x8013B320           // original line 1, modified to use jump
        nop

        jr      ra
        nop

        _j_0x8013B320:
        j       0x8013B320                  // jump to Team Battle announcer call
        nop

        _wins:
        li      v1, twelve_cb_flag
        lw      v1, 0x0000(v1)              // v1 = 1 if 12cb mode
        beqzl   v1, _end                    // if not 12cb mode, skip WINS
        nop

        li      v1, config.status
        lw      v1, 0x0000(v1)              // v1 = battle status
        sltiu   v1, v1, config.STATUS_COMPLETE // v1 = 0 if battle complete
        bnezl   v1, _end                    // if not battle complete, skip WINS
        nop

        // t9 = frame count
        lli     v1, 0x0034                  // v1 = frame to play WINS
        bne     t9, v1, _end                // if not the frame to play WINS, skip
        nop

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        jal     FGM.play_                   // play WINS
        lli     a0, FGM.announcer.results.WINS

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        jr      ra
        lui     v1, 0x800A                  // original line 1
    }

    // @ Description
    // Update Free-for-all/Team Battle header text to "12-Char. Battle"
    scope update_css_header_: {
        // vs
        OS.patch_start(0x1326B0, 0x80134434)
        jal     update_css_header_._vs
        lw      t2, 0xC4B0(t2)              // original line 1
        OS.patch_end()
        // results
        OS.patch_start(0x155928, 0x80136788)
        jal     update_css_header_._results
        lw      t8, 0x0054(t8)              // original line 1
        OS.patch_end()

        _vs:
        li      t4, twelve_cb_flag
        lw      t4, 0x0000(t4)              // t4 = 1 if 12cb mode
        bnezl   t4, _end_vs                 // if 12cb mode, use custom image
        lli     t9, 0x2048                  // t9 = offset to "12-Char. Battle" image

        _end_vs:
        jr      ra
        addiu   t4, r0, 0x0001              // original line 2

        _results:
        li      t1, twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb mode
        beqz    t1, _end_results            // if not 12cb mode, use normal image
        nop                                 // otherwise, use custom image

        lli     t8, 0x2048                  // t8 = offset to "12-Char. Battle" image

        // Also, display the current game under the header text
        OS.save_registers()
        li      t0, string_game
        li      t1, config.current_game
        lw      t1, 0x0000(t1)              // t1 = current_game
        addiu   a0, t1, 0x0001              // a0 = current_game, adjusted
        lli     a1, OS.FALSE                // a1 = unsigned
        lli     a2, OS.FALSE                // a2 = don't show + sign
        jal     String.itoa_                // v0 = address of number string
        lli     a3, 0x0000                  // a3 = number of decimal places
        lbu     t1, 0x0000(v0)              // t1 = 1st character
        sb      t1, 0x0005(t0)              // set character in string
        lbu     t1, 0x0001(v0)              // t1 = 2nd character
        sb      t1, 0x0006(t0)              // set character in string
        Render.draw_string(0x1F, 0x16, string_game, Render.NOOP, 0x42000000, 0x42380000, 0xFFFFFFFF, 0x3F600000, Render.alignment.LEFT)
        OS.restore_registers()

        _end_results:
        jr      ra
        addiu   t1, r0, 0x0001              // original line 2
    }

    // @ Description
    // When the stock count is changed, we need to either block it or update our values
    scope handle_stock_count_change_: {
        // decrement
        OS.patch_start(0x1366D0, 0x80138450)
        jal     handle_stock_count_change_._decrement
        lw      v1, 0x0000(v0)              // original line 1 (stock count)
        OS.patch_end()
        // increment
        OS.patch_start(0x136648, 0x801383C8)
        jal     handle_stock_count_change_._increment
        lw      v1, 0x0000(v0)              // original line 1 (stock count)
        OS.patch_end()

        _decrement:
        li      t4, twelve_cb_flag
        lw      t4, 0x0000(t4)              // t4 = 1 if 12cb mode
        beqz    t4, _allow_decrement_end    // if not 12cb mode, allow change and skip updating config
        nop
        li      t4, config.status
        lw      t4, 0x0000(t4)              // t4 = battle status
        beqz    t4, _allow_decrement        // if battle not started, allow change
        addiu   t4, r0, 0x0062              // original line 2

        // otherwise, don't allow decrement
        jr      ra
        addiu   v1, v1, 0x0001              // add 1 to negate the decrement after the ra

        _allow_decrement:
        or      a0, v1, r0                  // a0 = stock count, not 0-based
        beqzl   v1, _initialize_stocks_d    // if stocks should be 99, then stock count is 12
        lli     a0, 99                      // a0 = 99

        // otherwise, update stocks
        _initialize_stocks_d:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        jal     update_stock_fields_
        addiu   a0, a0, -0x0001             // a0 = stock count, 0-based

        jal     CharacterSelect.refresh_stock_indicators_
        nop

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _allow_decrement_end:
        jr      ra
        addiu   t4, r0, 0x0062              // original line 2

        _increment:
        li      at, twelve_cb_flag
        lw      at, 0x0000(at)              // at = 1 if 12cb mode
        beqz    at, _allow_increment_end    // if not 12cb mode, allow change and skip updating config
        nop
        li      at, config.status
        lw      at, 0x0000(at)              // at = battle status
        beqz    at, _allow_increment        // if battle not started, allow change
        nop

        // otherwise, don't allow increment
        jr      ra
        nop                                 // don't increment

        _allow_increment:
        addiu   a0, v1, 0x0002              // a0 = stocks incremented, not 0-based
        sltiu   at, a0, 0x0064              // at = 0 if stocks should be 1
        beqzl   at, _initialize_stocks_i    // if stocks should be 1, then set a0 = 1
        lli     a0, 1                       // stocks = 1

        // otherwise, calculate
        _initialize_stocks_i:
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        jal     update_stock_fields_
        addiu   a0, a0, -0x0001             // a0 = stock count, 0-based

        jal     CharacterSelect.refresh_stock_indicators_
        nop

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        _allow_increment_end:
        jr      ra
        addiu   v1, v1, 0x0001              // original line 2
    }

    // @ Description
    // Play a different FGM if switching the stock count is not allowed.
    scope handle_stock_change_fgm_: {
        // decrement
        OS.patch_start(0x1366F8, 0x80138478)
        jal     handle_stock_change_fgm_
        lli     a0, FGM.menu.SCROLL         // original line 2 (fgm id)
        OS.patch_end()
        // increment
        OS.patch_start(0x136670, 0x801383F0)
        jal     handle_stock_change_fgm_
        lli     a0, FGM.menu.SCROLL         // original line 2 (fgm id)
        OS.patch_end()

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0008(sp)              // store ra

        li      t6, twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        beqz    t6, _end                    // if not 12cb mode, skip
        nop
        li      t6, config.status
        lw      t6, 0x0000(t6)              // t6 = battle status
        bnel    t6, r0, _end                // branch if battle has started
        lli     a0, FGM.menu.ILLEGAL        // on branch, a0 = FGM.menu.ILLEGLAL

        _end:
        jal     0x800269C0                  // original line 1 (play fgm)
        nop
        lw      ra, 0x00008(sp)             // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0010              // deallocate stack space
    }

    // @ Description
    // Resets the 12cb config when RESET is pressed.
    scope handle_reset_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        // reset the config struct
        li      t0, config
        sw      r0, 0x0000(t0)              // config.status = NOT_STARTED
        addiu   t1, r0, -0x0001             // t1 = FFFFFFFF
        sw      t1, 0x0008(t0)              // config.current_game = -1

        lw      a0, 0x0004(t0)              // a0 = config.num_stocks
        jal     update_stock_fields_
        sw      t1, 0x0004(t0)              // config.num_stocks = 0 (so update_stock_fields_ resets portrait counts)

        jal     CharacterSelect.refresh_stock_indicators_
        nop

        li      t1, 0x001C00FF
        li      t0, config.p1.best_character
        sw      t1, 0x0000(t0)              // initialize best character
        sw      r0, 0x0004(t0)              // initialize best character string pointer
        li      t0, config.p2.best_character
        sw      t1, 0x0000(t0)              // initialize best character
        sw      r0, 0x0004(t0)              // initialize best character string pointer

        // reset the match structs
        // this should really be cleaned up into it's own routine
        li      t2, 0x1C0000FF              // t2 = initial values for first part of match struct
        li      t0, config.p1.match
        lli     t3, 23                      // t3 = 23 matches
        _loop_1:
        sw      t2, 0x0000(t0)              // update this game in match struct, part 1
        sw      r0, 0x0004(t0)              // update this game in match struct, part 1
        addiu   t3, t3, -0x0001             // t3--
        bnez    t3, _loop_1                 // loop over all games in match struct
        addiu   t0, t0, 0x0008              // move to next game

        li      t0, config.p2.match
        lli     t3, 23                      // t3 = 23 matches
        _loop_2:
        sw      t2, 0x0000(t0)              // update this game in match struct, part 1
        sw      r0, 0x0004(t0)              // update this game in match struct, part 1
        addiu   t3, t3, -0x0001             // t3--
        bnez    t3, _loop_2                 // loop over all games in match struct
        addiu   t0, t0, 0x0008              // move to next game

        // toggle display items
        lli     a0, setup_.GROUP_STARTED    // a0 = group of items that should only display when battle has started
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = 1 (hide)

        lli     a0, setup_.GROUP_COMPLETED  // a0 = group of items that should only display when battle has completed
        jal     Render.toggle_group_display_
        lli     a1, 0x0001                  // a1 = 1 (hide)

        lli     a0, setup_.GROUP_NOT_STARTED // a0 = group of items that should only display when battle has not started
        jal     Render.toggle_group_display_
        lli     a1, 0x0000                  // a1 = 0 (don't hide)

        jal     0x800269C0
        lli     a0, 0x00A4                  // play same sound as when pressing BACK

        lli     a0, 0x0000                  // a0 = panel index
        li      a1, CharacterSelect.CSS_PLAYER_STRUCT
        jal     update_character_panel_     // sync character model
        lli     a2, OS.TRUE                 // a2 = play announcer

        lli     a0, 0x0001                  // a0 = panel index
        li      a1, CharacterSelect.CSS_PLAYER_STRUCT
        addiu   a1, a1, 0x00BC
        jal     update_character_panel_     // sync character model
        lli     a2, OS.TRUE                 // a2 = play announcer

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Updates the variant indicator for the given portrait.
    // @ Arguments
    // a0 - portrait object struct
    scope update_portrait_variant_indicator_: {
        addiu   sp, sp,-0x0040              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        // 0x0010(sp) reserved for render flags
        // 0x0014(sp) reserved for scale
        // 0x0018(sp) reserved for X position
        // 0x001C(sp) reserved for Y position
        sw      t2, 0x0020(sp)              // ~
        sw      at, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        sw      a1, 0x002C(sp)              // ~
        sw      v0, 0x0030(sp)              // ~

        lw      t0, 0x0074(a0)              // t0 = portrait image struct
        lw      a0, 0x0008(t0)              // t0 = indicator image struct
        beqz    a0, _start                  // if no indicator struct, skip destroying it
        nop
        jal     0x800096EC                  // destroy the previous indicator image
        nop

        _start:
        lw      a0, 0x0028(sp)              // a0 = portrait object struct
        lw      a0, 0x0030(a0)              // a0 = portrait_id
        lli     t1, 0x0201                  // t1 = render flags for flags/icons (blur)
        sw      t1, 0x0010(sp)              // save render flags
        lui     t1, 0x3F10                  // t1 = scale for flags (0.5625)
        sw      t1, 0x0014(sp)              // save scale for flags
        li      at, CharacterSelect.id_table_pointer
        lw      at, 0x0000(at)              // at = id_table
        addu    at, at, a0                  // at = address of character_id
        lbu     at, 0x0000(at)              // at = character_id
        li      t0, Character.variant_type.table
        addu    t0, t0, at                  // t0 = address of variant_type
        lbu     t0, 0x0000(t0)              // t0 = variant_type
        li      t1, Render.file_pointer_2   // t1 = CSS images file
        lw      t1, 0x0000(t1)              // ~
        lli     t2, Character.variant_type.J
        beql    t0, t2, _add_indicator      // if a J variant, then draw J flag
        addiu   a1, t1, 0x558               // a1 = J flag footer struct TODO: make offset a constant
        lli     t2, Character.variant_type.E
        beql    t0, t2, _add_indicator      // if a E variant, then draw E flag
        addiu   a1, t1, 0x3B8               // a1 = E flag footer struct TODO: make offset a constant

        lui     t2, 0x3F80                  // t2 = scale for stock icons (1.0)
        sw      t2, 0x0014(sp)              // save scale for stock icons

        lli     t2, Character.variant_type.POLYGON
        beql    t0, t2, _add_indicator      // if a polygon, then draw polygon icon from our file instead
        addiu   a1, t1, 0x13A8              // a1 = polygon icon footer struct TODO: make offset a constant

        // if we're here, then we will use the character's stock icon
        li      t1, 0x80116E10              // t1 = main character struct table
        sll     t2, at, 0x0002              // t2 = a1 * 4 (offset in struct table)
        addu    t1, t1, t2                  // t1 = pointer to character struct
        lw      t1, 0x0000(t1)              // t1 = character struct
        lw      t2, 0x0028(t1)              // t2 = main character file address pointer
        lw      t2, 0x0000(t2)              // t2 = main character file address
        beqz    t2, _end
        lw      t1, 0x0060(t1)              // t1 = offset to attribute data
        addu    t1, t2, t1                  // t1 = attribute data address
        lw      t1, 0x0340(t1)              // t1 = pointer to stock icon footer address
        lw      a1, 0x0000(t1)              // a1 = stock icon footer address

        lli     t1, 0x0205                  // t1 = render flags to disable display
        lli     t2, Character.variant_type.SPECIAL
        beql    t0, t2, _add_indicator      // if a special character, then turn off display (we add custom portraits)
        sw      t1, 0x0010(sp)              // store render flags
        beqzl   t0, _add_indicator          // if not a variant, then turn off display
        sw      t1, 0x0010(sp)              // store render flags

        _add_indicator:
        lw      a0, 0x0028(sp)              // a0 = portrait object struct
        lw      t0, 0x0074(a0)              // t0 = portrait image struct
        lw      t1, 0x0058(t0)              // t1 = portrait ulx
        sw      t1, 0x0018(sp)              // save ulx
        lw      t1, 0x005C(t0)              // t1 = portrait ulx
        sw      t1, 0x001C(sp)              // save uly

        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      t1, 0x0014(sp)              // t1 = scale
        sw      t1, 0x0018(v0)              // save X scale
        sw      t1, 0x001C(v0)              // save Y scale

        lwc1    f0, 0x0018(sp)              // f0 = X position
        lwc1    f2, 0x001C(sp)              // f2 = Y position
        swc1    f0, 0x0058(v0)              // set X position
        swc1    f2, 0x005C(v0)              // set Y position

        lw      t1, 0x0010(sp)              // t1 = render flags
        sh      t1, 0x0024(v0)              // turn on blur

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0020(sp)              // ~
        lw      at, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        lw      a1, 0x002C(sp)              // ~
        lw      v0, 0x0030(sp)              // ~
        addiu   sp, sp, 0x0040              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Updates the given portrait_id_table based on the given id_table's values.
    // a0 - portrait_id_table
    // a1 - id_table
    scope update_portrait_id_table_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~
        sw      t1, 0x0014(sp)              // ~
        sw      t2, 0x0018(sp)              // ~
        sw      t3, 0x001C(sp)              // ~
        sw      t4, 0x0020(sp)              // ~

        lli     at, Character.NUM_CHARACTERS
        lli     t1, 0x00FF                  // t1 = 0xFF (no portrait)
        or      t2, r0, a0                  // t2 = portrait_id_table

        // first, clear it out
        _clear_loop:
        sb      t1, 0x0000(t2)              // clear portrait_id
        addiu   at, at, -0x0001             // index--
        bnezl   at, _clear_loop             // loop until all are cleared
        addiu   t2, t2, 0x0001              // increment address

        // next, update ids
        lw      t2, 0x0008(sp)              // t2 = portrait_id_table
        lli     at, 0x0000
        lw      t3, 0x000C(sp)              // t3 = id_table
        _update_loop:
        lbu     t1, 0x0000(t3)              // t1 = character_id
        addu    t4, t2, t1                  // t4 = offset to portrait_id for this character
        sb      at, 0x0000(t4)              // save portrait_id
        sltiu   t4, at, NUM_SLOTS           // at = 0 if end of loop
        addiu   t3, t3, 0x0001              // id_table++
        bnezl   t4, _update_loop            // loop until all updated
        addiu   at, at, 0x0001              // portrait_id++

        // ensure NONE is FF
        lli     t1, Character.id.NONE
        addu    t4, t2, t1                  // t4 = offset to portrait_id for NONE
        lli     at, 0x00FF                  // 0xFF (no portrait)
        sb      at, 0x0000(t4)              // save portrait_id

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        lw      t1, 0x0014(sp)              // ~
        lw      t2, 0x0018(sp)              // ~
        lw      t3, 0x001C(sp)              // ~
        lw      t4, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Updates the character set for the given player.
    // @ Arguments
    // a0 - port_id
    // a1 - increment?
    scope update_character_set_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      v1, 0x0014(sp)              // ~
        sw      s1, 0x0018(sp)              // ~
        sw      a1, 0x001C(sp)              // ~

        // update index and string
        li      t0, character_set_string_table
        li      t1, config.p1.character_set // t1 = p1 character set index address
        li      t2, config.p2.character_set // t1 = p2 character set index address
        bnezl   a0, pc() + 8                // if p2, then set t1 to p2 character set index address
        or      t1, r0, t2                  // t1 = p2 character set index address

        lw      t2, 0x0000(t1)              // t2 = character_set_index
        addu    t2, t2, a1                  // character_set_index++, maybe
        sltiu   at, t2, NUM_PRESETS + 1     // at = 0 if past last item in table
        beqzl   at, pc() + 8                // if past last item in table, set to first index
        lli     t2, 0x0000                  // t2 = 0
        sw      t2, 0x0000(t1)              // update character_set_index

        sll     t2, t2, 0x0002              // t2 = offset in character_set_string_table
        addu    t0, t0, t2                  // t0 = address of string pointer
        lw      t0, 0x0000(t0)              // t0 = pointer to character set string
        sw      t0, 0x0004(t1)              // update character set index string pointer

        // update portraits
        li      t0, character_set_table
        lli     at, NUM_PRESETS * 4         // at = custom character set * 4
        bne     at, t2, _get_portrait_offset // if not custom character set, then skip
        nop                                 // otherwise, check if p2 and adjust up if so
        bnezl   a0, _get_portrait_offset    // if p2, then adjust offset
        addiu   t2, t2, 0x0004              // t2 = offset to use for p2 character set
        _get_portrait_offset:
        sll     t2, t2, 0x0002              // t2 = offset in character_set_table (character_set_index * 0x10)
        addu    t0, t0, t2                  // t0 = address of array of portrait related tables
        sll     at, a0, 0x0002              // at = offset for portrait index

        // id_table
        lw      t1, 0x0000(t0)              // t1 = set id_table
        addu    t1, t1, at                  // t1 = set id_table, adjusted to first portrait based on port
        li      t3, CharacterSelect.id_table_pointer
        lw      t3, 0x0000(t3)              // t3 = id_table
        addu    t3, t3, at                  // t3 = id_table, adjusted to first portrait based on port
        lw      t4, 0x0000(t1)              // t4 = top 4 portraits
        sw      t4, 0x0000(t3)              // save top 4 portraits
        lw      t4, 0x0008(t1)              // t4 = middle 4 portraits
        sw      t4, 0x0008(t3)              // save middle 4 portraits
        lw      t4, 0x0010(t1)              // t4 = bottom 4 portraits
        sw      t4, 0x0010(t3)              // save bottom 4 portraits

        // portrait_offset_table
        lw      t1, 0x0004(t0)              // t1 = set portrait_offset_table
        sll     at, at, 0x0002              // at = offset * 4
        addu    t1, t1, at                  // t1 = set portrait_offset_table, adjusted to first portrait based on port
        li      t3, CharacterSelect.portrait_offset_table_pointer
        lw      t3, 0x0000(t3)              // t3 = portrait_offset_table
        addu    t3, t3, at                  // t3 = portrait_offset_table, adjusted to first portrait based on port
        lw      t4, 0x0000(t1)              // t4 = top 4 portraits
        sw      t4, 0x0000(t3)              // save top 4 portraits
        lw      t4, 0x0004(t1)              // t4 = top 4 portraits
        sw      t4, 0x0004(t3)              // save top 4 portraits
        lw      t4, 0x0008(t1)              // t4 = top 4 portraits
        sw      t4, 0x0008(t3)              // save top 4 portraits
        lw      t4, 0x000C(t1)              // t4 = top 4 portraits
        sw      t4, 0x000C(t3)              // save top 4 portraits
        lw      t4, 0x0020(t1)              // t4 = middle 4 portraits
        sw      t4, 0x0020(t3)              // save middle 4 portraits
        lw      t4, 0x0024(t1)              // t4 = middle 4 portraits
        sw      t4, 0x0024(t3)              // save middle 4 portraits
        lw      t4, 0x0028(t1)              // t4 = middle 4 portraits
        sw      t4, 0x0028(t3)              // save middle 4 portraits
        lw      t4, 0x002C(t1)              // t4 = middle 4 portraits
        sw      t4, 0x002C(t3)              // save middle 4 portraits
        lw      t4, 0x0040(t1)              // t4 = bottom 4 portraits
        sw      t4, 0x0040(t3)              // save bottom 4 portraits
        lw      t4, 0x0044(t1)              // t4 = bottom 4 portraits
        sw      t4, 0x0044(t3)              // save bottom 4 portraits
        lw      t4, 0x0048(t1)              // t4 = bottom 4 portraits
        sw      t4, 0x0048(t3)              // save bottom 4 portraits
        lw      t4, 0x004C(t1)              // t4 = bottom 4 portraits
        sw      t4, 0x004C(t3)              // save bottom 4 portraits

        // portrait_id_table
        li      t3, CharacterSelect.portrait_id_table_pointer
        lw      a0, 0x0000(t3)              // a0 = portrait_id_table
        li      t3, CharacterSelect.id_table_pointer
        jal     update_portrait_id_table_
        lw      a1, 0x0000(t3)              // a1 = id_table

        // Check incrementing flag
        lw      a1, 0x001C(sp)              // a1 = increment?
        beqz    a1, _portraits              // if not incrementing, skip
        nop

        // update character id and panel preview based on new character set
        lw      a0, 0x0008(sp)              // t0 = port_id
        li      t3, CharacterSelect.CSS_PLAYER_STRUCT // t3 = p1 css player struct
        bnezl   a0, pc() + 8                // adjust address for p2
        addiu   t3, t3, 0x00BC              // t3 = p2 css player struct
        sw      t3, 0x001C(sp)              // remember css player struct
        lw      t0, 0x0048(t3)              // t0 = selected character_id
        lli     at, Character.id.NONE
        beq     t0, at, _portraits          // if no character is selected, skip
        nop                                 // otherwise, let's update the character_id to the new portrait's character

        lw      t2, 0x0004(t3)              // a2 = token object
        lw      t2, 0x0074(t2)              // t2 = token object position struct
        lwc1    f0, 0x0058(t2)              // f0 = (float) xpos
        trunc.w.s f0, f0                    // f0 = (int) xpos
        mfc1    a1, f0                      // a1 = (int) xpos
        lwc1    f0, 0x005C(t2)              // f0 = (float) ypos
        trunc.w.s f0, f0                    // f0 = (int) ypos
        jal     get_character_id_           // v0 = character_id
        mfc1    v1, f0                      // v1 = (int) ypos
        lli     at, Character.id.NONE
        bne     at, v0, _update_panel       // if a valid character is selected, update panel
        nop                                 // otherwise we'll get a random one
        or      s0, r0, t3                  // s0 = CSS player struct
        jal     CharacterSelect.get_random_char_id_
        lw      s1, 0x0008(sp)              // s1 = panel index

        _update_panel:
        lw      a1, 0x001C(sp)              // t3 = css player struct
        sw      v0, 0x0048(a1)              // save character_id

        lw      a0, 0x0008(sp)              // a0 = panel index
        jal     update_character_panel_     // sync character model
        lli     a2, OS.TRUE                 // a2 = play announcer

        _portraits:
        // Now update the portrait image structs with the correct RAM address
        li      t0, Render.ROOM_TABLE
        lli     t1, 0x01B * 4               // t1 = portrait room offset
        addu    t0, t0, t1                  // t0 = pointer to first portrait object
        lw      t0, 0x0000(t0)              // t0 = 1st portrait object
        li      t2, Render.file_pointer_1
        lw      t2, 0x0000(t2)              // t2 = base address of character portraits file
        li      t3, CharacterSelect.portrait_offset_table_pointer
        lw      t3, 0x0000(t3)              // t3 = portrait_offset_table
        _loop:
        beqz    t0, _end                    // exit loop when there are no more portraits
        nop
        lw      t1, 0x0030(t0)              // t1 = portrait_id
        sll     t1, t1, 0x0002              // t1 = offset to portrait offset
        addu    t1, t3, t1                  // t1 = address of portrait offset
        lw      t1, 0x0000(t1)              // t1 = portrait offset
        addu    t1, t2, t1                  // t1 = RAM address of new portrait image footer, off by 0x10
        addiu   t1, t1, -0x0010             // t1 = RAM address of new portrait image footer
        lw      t4, 0x0074(t0)              // t4 = portrait image struct
        sw      t1, 0x0044(t4)              // update portrait image footer pointer
        jal     update_portrait_variant_indicator_
        or      a0, r0, t0                  // a0 = portrait object struct
        lw      t1, 0x0030(t0)              // t1 = portrait_id
        sltiu   t4, t1, NUM_SLOTS - 1       // t4 = 1 if we should continue looping
        beqz    t4, _end                    // if we've hit our last portrait_id, then stop looping
        lw      t0, 0x0020(t0)              // t0 = next portrait object
        b       _loop                       // loop while there are still more portraits
        nop

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      v1, 0x0014(sp)              // ~
        lw      s1, 0x0018(sp)              // ~
        lw      a1, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Updates the given character panel (syncs it with the CSS player struct).
    // @ Arguments
    // a0 - panel index
    // a1 - CSS player struct
    // a2 - play announcer? 1 = yes, 0 = no
    scope update_character_panel_: {
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // ~

        jal     0x80136128                  // set up character model
        lw      a0, 0x0008(sp)              // a0 = panel index
        jal     0x80136300                  // set up panel
        lw      a0, 0x0008(sp)              // a0 = panel index
        lw      t3, 0x000C(sp)              // t3 = css player struct
        lw      at, 0x0084(t3)              // at = panel state (0 = HMN, 1 = CPU)
        beqz    at, pc() + 16               // if CPU, then we need to clean up the CP panel a bit
        nop                                 // otherwise just skip ahead
        jal     0x80137004                  // clean up CP panel
        lw      a0, 0x0008(sp)              // a0 = panel index

        OS.read_byte(Global.vs.handicap, a0) // a0 = 0 if handicap off
        beqz    a0, _finish                 // if handicap is off, skip
        nop
        jal     0x80137004                  // fix Handicap display
        lw      a0, 0x0008(sp)              // a0 = port

        _finish:
        lw      a0, 0x0008(sp)              // a0 = panel index
        lw      a2, 0x0010(sp)              // a2 = play announcer?
        beqz    a2, _end                    // skip playing announcer if necessary
        nop
        // TODO: potentially could delay this announcer call a few frames to not overlap
        addiu   sp, sp,-0x0010              // allocate stack space
        jal     0x801367F0                  // play announcer FGM
        or      a1, r0, a0                  // a1 = token index
        addiu   sp, sp, 0x0010              // deallocate stack space

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Handles button presses on custom buttons.
    scope handle_custom_presses_: {
        OS.patch_start(0x136708, 0x80138488)
        jal     handle_custom_presses_
        lw      a0, 0x0040(sp)              // original line 2
        OS.patch_end()

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        // 0x0010(sp) reserved
        sw      a3, 0x0014(sp)              // ~

        li      v0, twelve_cb_flag
        lw      v0, 0x0000(v0)              // v0 = 1 if 12cb mode
        beqz    v0, _end                    // if not 12cb mode, skip
        nop

        li      v0, config.status
        lw      v0, 0x0000(v0)              // v0 = 0 if not started
        beqz    v0, _check_character_set_p1 // if not started, skip
        nop

        // Check RESET button
        li      a1, reset_button_pointer
        jal     CharacterSelect.check_image_press_ // v0 = 1 if reset pressed, 0 if not
        lw      a1, 0x0000(a1)              // a1 = reset button object

        beqz    v0, _end                    // if not pressed, skip
        nop

        jal     handle_reset_               // reset config
        nop
        b       _end                        // skip to end
        nop

        _check_character_set_p1:
        // p1
        lui     a1, 0x42C2                  // a1 = image ulx
        lli     a2, 55                      // a2 = image width
        lui     a3, 0x432C                  // a3 = image uly
        lli     t4, 14                      // t4 = image height
        jal     CharacterSelect.check_press_ // v0 = (bool) image pressed
        sw      t4, 0x0010(sp)              // 0x0010(sp) = image height

        beqz    v0, _check_character_set_p2 // if not pressed, skip
        nop

        lli     a0, 0x0000                  // a0 = player 1
        jal     update_character_set_
        lli     a1, OS.TRUE                 // a1 = increment? yes
        b       _play_sound
        nop

        _check_character_set_p2:
        // p2
        lui     a1, 0x4325                  // a1 = image ulx
        lli     a2, 55                      // a2 = image width
        lui     a3, 0x432C                  // a3 = image uly
        lli     t4, 14                      // t4 = image height
        jal     CharacterSelect.check_press_ // v0 = (bool) image pressed
        sw      t4, 0x0010(sp)              // 0x0010(sp) = image height

        beqz    v0, _end                    // if not pressed, skip
        nop

        lli     a0, 0x0001                  // a0 = player 2
        jal     update_character_set_
        lli     a1, OS.TRUE                 // a1 = increment? yes

        _play_sound:
        // audial feedback
        jal     0x800269C0
        lli     a0, FGM.menu.SCROLL         // play sound

        _end:
        jal     0x80135270                  // original line 1 (check BACK press)
        lw      a0, 0x0060(sp)              // original line 2, adjusted for sp

        lw      ra, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        // 0x0010(sp) reserved
        lw      a3, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Draws a semitransparent rectangle over portraits of defeated characters.
    // Called from CharacterSelect.draw_portraits_ only when on 12cb css.
    // @ Arguments
    // a0 - portrait object
    scope draw_disabled_rectangle_: {
        lw      t0, 0x0030(a0)              // t0 = portrait_id
        li      t1, config.stocks_by_portrait_id
        addu    t1, t0, t1                  // t1 = addres of stocks remaining for this portrait
        lbu     t0, 0x0000(t1)              // t0 = stocks remaining, 0-based
        lli     t1, 0x00FF                  // t1 = 0x000000FF (so no stocks left)
        bne     t0, t1, _check_destroy      // if there are still stocks remaining, updating it
        lw      t1, 0x0034(a0)              // t1 = rectangle object reference

        // get ulx and uly
        lw      t0, 0x0074(a0)              // t0 = image struct
        lwc1    f0, 0x0058(t0)              // f0 = (float) ulx
        lwc1    f2, 0x005C(t0)              // f2 = (float) uly
        trunc.w.s f0, f0                    // f0 = (int) ulx
        trunc.w.s f2, f2                    // f2 = (int) uly

        // check if we need to create the rectangle or just update it
        beqz    t1, _update                 // if haven't created yet, create it
        lli     at, OS.TRUE                 // at = TRUE (create)

        // otherwise, just update ulx and uly
        swc1    f0, 0x0030(t1)              // update ulx
        swc1    f2, 0x0034(t1)              // update uly

        b       _end
        nop

        _update:
        OS.save_registers()

        bnez    at, _create                 // if creating, jump to _create
        nop                                 // otherwise, destroy

        sw      r0, 0x0034(a0)              // clear rectangle object reference

        jal     Render.DESTROY_OBJECT_      // destroy the object
        or      a0, r0, t1                  // a0 = rectangle object

        b       _restore
        nop

        _create:
        lli     a0, 0x1B
        lli     a1, 0x12
        mfc1    s1, f0                      // ulx
        mfc1    s2, f2                      // uly
        lli     s3, PORTRAIT_WIDTH
        lli     s4, PORTRAIT_HEIGHT
        li      s5, 0x000000A0              // color
        jal     Render.draw_rectangle_
        lli     s6, OS.TRUE                 // enable alpha

        lw      a0, 0x0010(sp)              // a0 = portrait object
        sw      v0, 0x0034(a0)              // save rectangle object reference

        _restore:
        OS.restore_registers()

        _end:
        jr      ra
        nop

        _check_destroy:
        beqz    t1, _end                    // if haven't created yet, exit
        nop                                 // otherwise, need to destroy it
        b       _update
        lli     at, OS.FALSE                // at = FALSE (destroy)
    }

    // @ Description
    // Prevents defeated characters from being selected by humans.
    // Also prevents switching characters if player won the previous match.
    scope prevent_defeated_char_select_: {
        OS.patch_start(0x13546C, 0x801371EC)
        jal     prevent_defeated_char_select_
        nop
        OS.patch_end()

        // t0 = CSS player struct

        beq     t1, at, _j_0x80137218       // original line 2, modified to jump
        nop

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      t1, 0x0014(sp)              // ~
        sw      t2, 0x0018(sp)              // ~
        sw      v0, 0x001C(sp)              // ~
        sw      v1, 0x0020(sp)              // ~

        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _end                    // if not 12cb mode, return normally
        nop

        // check if this character was defeated
        // a0 = port_id
        // t1 = character_id
        // t8 = token_id
        or      a0, t8, r0                  // a0 = token_id
        jal     get_stocks_remaining_for_char_ // v0 = remaining_stocks
        or      a1, r0, t1                  // a1 = character_id
        li      t2, 0x80137218              // t2 = ra if char is defeated
        beqzl   v0, _end                    // if there are no stocks remaining, don't allow selection
        sw      t2, 0x0004(sp)              // update stored ra

        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        beqz    t0, _end                    // if not started, return normally
        nop

        // if the player won last match, make sure they can't select a different character
        jal     get_last_match_portrait_and_stocks_ // v0 = remaining stocks, v1 = portrait_id of last match
        nop
        beqz    v0, _end                    // if there are no remaining stocks (they lost), allow selection
        nop                                 // otherwise we need to double-check they selected the same character
        lw      t0, 0x0010(sp)              // t0 = CSS player struct
        lw      a1, 0x00B4(t0)              // a1 = portrait_id being hovered
        bnel    a1, v1, _end                // if they are hovered over a different character, then don't allow selection
        sw      t2, 0x0004(sp)              // update stored ra

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      t1, 0x0014(sp)              // ~
        lw      t2, 0x0018(sp)              // ~
        lw      v0, 0x001C(sp)              // ~
        lw      v1, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra                          // otherwise return normally, allowing selection
        nop

        _j_0x80137218:
        j       0x80137218
        nop
    }

    // @ Description
    // Overrides the menu action parameters for defeated characters.
    // t3 - pointer to the action parameters
    // s1 - player struct
    scope defeated_action_override_: {
        OS.patch_start(0x62D58, 0x800E7558)
        jal     defeated_action_override_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      t1, 0x0014(sp)              // ~
        sw      t2, 0x0018(sp)              // ~
        sw      v0, 0x001C(sp)              // ~
        sw      v1, 0x0020(sp)              // ~

        // Firster still, check to see if character is sonic

        li      t0, Global.current_screen   // ~
        lb      t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x0E                    // t1 = vs css screen id
        beq     t0, t1, _sonic              // if screen id = preview, sonic
        lli     t1, 0x18                    // t1 = vs css screen id
        bne     t0, t1, _remix_check        // if screen id does not equal results, skip other checks
        nop

        _sonic:
        lw      t0, 0x0008(s1)              // t0 = character id
        ori     t1, r0, Character.id.SONIC  // Sonic ID
        bne     t0, t1, _remix_check        // if not Sonic, branch
        nop

        lbu     t0, 0x000D(s1)              // t0 = player port
        li      t1, Sonic.classic_table     // t1 = classic_table
        addu    t1, t1, t0                  // t1 = classic_table + port
        lbu     t1, 0x0000(t1)              // t1 = px is_classic
        beqz    t1, _remix_check            // skip if px is_clasic = FALSE
        nop

        jal     Sonic.classic_sonic_anim_swap_     // jump to anim swapping system
        nop

        beq     r0, r0, _end
        nop

        // Even firster, check to see if in Remix 1p
        _remix_check:
        li      t0, SinglePlayerModes.singleplayer_mode_flag       // ~
        lw      t0, 0x0000(t0)              // t0 = 4 if Remix 1p mode
        addiu   t1, r0, 0x0004              // Remix 1p ID
        beq     t0, t1, _remix_1p           // if Remix 1p, skip
        nop

        // First check if we're in character selection for an active 12CB.
        li      t0, Global.current_screen   // ~
        lb      t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x10                    // t1 = vs css screen id
        bne     t0, t1, _end                // if screen id != vs css, skip
        nop

        li      t0, twelve_cb_flag          // ~
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _end                    // if not 12cb mode, skip
        nop
        b       _12cb
        nop

        _remix_1p:
        // check if on title card screen
        li      t0, Global.current_screen   // ~
        lb      t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x0E                    // t1 = 1p Title Card screen id
        bne     t0, t1, _end                // if screen id != 1p title screen, skip
        nop

        // check to see if on team stage of 1p
        lui     t0, 0x8013
        lw      t0, 0x5C28(t0)              // load from current progress of 1p ID
        addiu   t1, r0, 0x0001              // team stage id
        bne     t0, t1, _end
        nop
        // check to see if is the cpu character
        lbu     t1, 0x001B(s1)              // t1 = 1 if a cpu
        addiu   t0, r0, 0x0001
        beq     t1, t0, _end                // if not the first loaded character, continue
        nop

        // If we reach this point, the character is the cpu on the Remix 1p Title Card, so we should override the action paramters.
        li      t0, team_array              // t0 = remix_team_array_array
        lw      t1, 0x0008(s1)              // t1 = character_id
        sll     t2, t1, 0x2                 // ~
        subu    t2, t2, t1                  // ~
        sll     t2, t2, 0x2                 // t2 = offset (character_id * 0xC)

        addu    t3, t0, t2                  // t3 = new parameters pointer (defeated_array + offset)

        beq     r0, r0, _end
        nop

        // Now check if the character is defeated.
        _12cb:
        lbu     a0, 0x000D(s1)              // a0 = port_id
        jal     get_stocks_remaining_for_char_ // v0 = remaining_stocks
        lw      a1, 0x0008(s1)              // a1 = character_id
        bnez    v0, _end                    // if character has stocks remaining, skip
        nop

        // If we reach this point, the character is defeated, so we should override the action paramters.
        li      t0, defeated_array          // t0 = defeated_array
        lw      t1, 0x0008(s1)              // t1 = character_id
        sll     t2, t1, 0x2                 // ~
        subu    t2, t2, t1                  // ~
        sll     t2, t2, 0x2                 // t2 = offset (character_id * 0xC)

        addu    t3, t0, t2                  // t3 = new parameters pointer (defeated_array + offset)

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      t1, 0x0014(sp)              // ~
        lw      t2, 0x0018(sp)              // ~
        lw      v0, 0x001C(sp)              // ~
        lw      v1, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        sw      t3, 0x0024(sp)              // original line 1
        jr      ra                          // return
        lw      t4, 0x0008(t3)              // original line 2
    }

    // @ Description
    // Adds parameter overrides for defeated characters.
    // @ Arguments
    // anim - animation id
    // moveset - pointer to moveset commands
    // flags - animation flags
    macro add_defeat_parameters(anim, moveset, flags) {
        dw {anim}
        dw {moveset}
        dw {flags}
    }

    // @ Description
    // Block of moveset commands for defeated characters.
    // Generic defeated moveset commands.
    defeated_moveset:
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Mario.
    defeated_moveset_mario:
    dw 0xAC000001                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Fox/Link.
    defeated_moveset_fox_link:
    dw 0xAC000001                           // Set Texture Form
    dw 0xAC100001                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated DK.
    defeated_moveset_donkey:
    dw 0xA0600001                           // Set Model Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Luigi.
    defeated_moveset_luigi:
    dw 0xAC000002                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Yoshi.
    defeated_moveset_yoshi:
    dw 0xAC000008                           // Set Texture Form
    dw 0xAC100008                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Captain Falcon.
    defeated_moveset_captain:
    dw 0xAC000006                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Kirby.
    defeated_moveset_kirby:
    dw 0xAC000007                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Pikachu.
    defeated_moveset_pikachu:
    dw 0xAC000006                           // Set Texture Form
    dw 0xAC100005                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Jigglypuff.
    defeated_moveset_jiggly:
    dw 0xAC000006                           // Set Texture Form
    dw 0xAC100006                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Ness.
    defeated_moveset_ness:
    dw 0xAC000004                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Sonic.
    defeated_moveset_sonic:
    dw 0xA0600001                           // Set Texture Form
    dw 0xAC000001                           // Set Texture Form
    dw 0xAC100001                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Sheik.
    defeated_moveset_marina:
    dw 0xAC000001                           // Set Texture Form
    dw 0xAC100001                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Dedede.
    defeated_moveset_dedede:
    dw 0xAC100001                           // Set Texture Form
    dw 0xAC000002                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Sheik.
    defeated_moveset_sheik:
    dw 0xAC000002                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End

    // @ Description
    // Array of menu action parameter overrides for defeated characters. Uses DownStandU animation.
    // Arguments          Animation file ID             Moveset data                Flags
    defeated_array:
    add_defeat_parameters(0x222,                        defeated_moveset_mario,     0)          // 0x00 - MARIO
    add_defeat_parameters(0x2B1,                        defeated_moveset_fox_link,  0)          // 0x01 - FOX
    add_defeat_parameters(0x34F,                        defeated_moveset_donkey,    0)          // 0x02 - DONKEY
    add_defeat_parameters(0x3E8,                        defeated_moveset,           0)          // 0x03 - SAMUS
    add_defeat_parameters(0x222,                        defeated_moveset_luigi,     0)          // 0x04 - LUIGI
    add_defeat_parameters(0x48A,                        defeated_moveset_fox_link,  0)          // 0x05 - LINK
    add_defeat_parameters(0x745,                        defeated_moveset_yoshi,     0)          // 0x06 - YOSHI
    add_defeat_parameters(0x617,                        defeated_moveset_captain,   0)          // 0x07 - CAPTAIN
    add_defeat_parameters(0x51D,                        defeated_moveset_kirby,     0)          // 0x08 - KIRBY
    add_defeat_parameters(0x80E,                        defeated_moveset_pikachu,   0)          // 0x09 - PIKACHU
    add_defeat_parameters(0x51D,                        defeated_moveset_jiggly,    0)          // 0x0A - JIGGLY
    add_defeat_parameters(0x6AF,                        defeated_moveset_ness,      0)          // 0x0B - NESS
    add_defeat_parameters(0,                            0x80000000,                 0)          // 0x0C - BOSS
    add_defeat_parameters(0x222,                        defeated_moveset,           0)          // 0x0D - METAL
    add_defeat_parameters(0x222,                        defeated_moveset,           0)          // 0x0E - NMARIO
    add_defeat_parameters(0x2B1,                        defeated_moveset,           0)          // 0x0F - NFOX
    add_defeat_parameters(0x34F,                        defeated_moveset,           0)          // 0x10 - NDONKEY
    add_defeat_parameters(0x3E8,                        defeated_moveset,           0)          // 0x11 - NSAMUS
    add_defeat_parameters(0x222,                        defeated_moveset,           0)          // 0x12 - NLUIGI
    add_defeat_parameters(0x48A,                        defeated_moveset,           0)          // 0x13 - NLINK
    add_defeat_parameters(0x745,                        defeated_moveset,           0)          // 0x14 - NYOSHI
    add_defeat_parameters(0x617,                        defeated_moveset,           0)          // 0x15 - NCAPTAIN
    add_defeat_parameters(0x51D,                        defeated_moveset,           0)          // 0x16 - NKIRBY
    add_defeat_parameters(0x80E,                        defeated_moveset,           0)          // 0x17 - NPIKACHU
    add_defeat_parameters(0x51D,                        defeated_moveset,           0)          // 0x18 - NJIGGLY
    add_defeat_parameters(0x6AF,                        defeated_moveset,           0)          // 0x19 - NNESS
    add_defeat_parameters(0x34F,                        defeated_moveset_donkey,    0)          // 0x1A - GDONKEY
    add_defeat_parameters(0,                            0x80000000,                 0)          // 0x1B - PLACEHOLDER
    add_defeat_parameters(0,                            0x80000000,                 0)          // 0x1C - PLACEHOLDER
    add_defeat_parameters(0x2B1,                        defeated_moveset_fox_link,  0)          // 0x1D - FALCO
    add_defeat_parameters(0x617,                        defeated_moveset_captain,   0)          // 0x1E - GND
    add_defeat_parameters(0x48A,                        defeated_moveset_fox_link,  0)          // 0x1F - YLINK
    add_defeat_parameters(0x222,                        defeated_moveset_mario,     0)          // 0x20 - DRM
    add_defeat_parameters(0x222,                        defeated_moveset_mario,     0)          // 0x21 - WARIO
    add_defeat_parameters(0x3E8,                        defeated_moveset,           0)          // 0x22 - DARK SAMUS
    add_defeat_parameters(0x48A,                        defeated_moveset_fox_link,  0)          // 0x23 - ELINK
    add_defeat_parameters(0x3E8,                        defeated_moveset,           0)          // 0x24 - JSAMUS
    add_defeat_parameters(0x6AF,                        defeated_moveset_ness,      0)          // 0x25 - JNESS
    add_defeat_parameters(0x6AF,                        defeated_moveset_ness,      0)          // 0x26 - LUCAS
    add_defeat_parameters(0x48A,                        defeated_moveset_fox_link,  0)          // 0x27 - JLINK
    add_defeat_parameters(0x617,                        defeated_moveset_captain,   0)          // 0x28 - JFALCON
    add_defeat_parameters(0x2B1,                        defeated_moveset_fox_link,  0)          // 0x29 - JFOX
    add_defeat_parameters(0x222,                        defeated_moveset_mario,     0)          // 0x2A - JMARIO
    add_defeat_parameters(0x222,                        defeated_moveset_luigi,     0)          // 0x2B - JLUIGI
    add_defeat_parameters(0x34F,                        defeated_moveset_donkey,    0)          // 0x2C - JDK
    add_defeat_parameters(0x80E,                        defeated_moveset_pikachu,   0)          // 0x2D - EPIKA
    add_defeat_parameters(0x51D,                        defeated_moveset_jiggly,    0)          // 0x2E - JPUFF
    add_defeat_parameters(0x51D,                        defeated_moveset_jiggly,    0)          // 0x2F - EPUFF
    add_defeat_parameters(0x51D,                        defeated_moveset_kirby,     0)          // 0x30 - JKIRBY
    add_defeat_parameters(0x745,                        defeated_moveset_yoshi,     0)          // 0x31 - JYOSHI
    add_defeat_parameters(0x80E,                        defeated_moveset_pikachu,   0)          // 0x32 - JPIKA
    add_defeat_parameters(0x3E8,                        defeated_moveset,           0)          // 0x33 - ESAMUS
    add_defeat_parameters(File.BOWSER_DOWN_STAND_U,     defeated_moveset_yoshi,     0)          // 0x34 - BOWSER
    add_defeat_parameters(File.BOWSER_DOWN_STAND_U,     defeated_moveset_yoshi,     0)          // 0x35 - GBOWSER
    add_defeat_parameters(File.PIANO_DOWN_STND_U,       defeated_moveset_mario,     0)          // 0x36 - PIANO
	add_defeat_parameters(0x2B1,                        defeated_moveset_fox_link,  0)          // 0x37 - WOLF
    add_defeat_parameters(File.CONKER_DOWNSTANDU,       defeated_moveset_fox_link,  0)          // 0x38 - CONKER
    add_defeat_parameters(File.MTWO_DOWN_STND_U,        defeated_moveset_kirby,     0)          // 0x39 - MTWO
    add_defeat_parameters(File.MARTH_DOWN_STAND_U,      defeated_moveset_jiggly,    0)          // 0x3A - MARTH
    add_defeat_parameters(0x2B1,                        defeated_moveset_sonic,     0)          // 0x3B - SONIC
    add_defeat_parameters(0x617,                        defeated_moveset_captain,   0)          // 0x3C - SANDBAG
    add_defeat_parameters(0x2B1,                        defeated_moveset_sonic,     0)          // 0x3D - SSONIC
    add_defeat_parameters(0x617,                        defeated_moveset_sheik,     0)          // 0x3E - SHEIK
    add_defeat_parameters(File.MARINA_DOWN_STND_U,      defeated_moveset_marina,    0)          // 0x3F - MARINA
    add_defeat_parameters(0x617,                        defeated_moveset_dedede,    0)          // 0x40 - DEDEDE
    // ADD NEW CHARACTERS HERE

    // REMIX POLYGONS
    add_defeat_parameters(0x222,                        defeated_moveset_mario,     0)          // - NWARIO
    add_defeat_parameters(0x6AF,                        defeated_moveset_ness,      0)          // - NLUCAS
    add_defeat_parameters(File.BOWSER_DOWN_STAND_U,     defeated_moveset_yoshi,     0)          // - NBOWSER
    add_defeat_parameters(0x2B1,                        defeated_moveset_fox_link,  0)          // - NWOLF
    add_defeat_parameters(0x222,                        defeated_moveset,           0)          // - NDRM
    add_defeat_parameters(0x2B1,                        defeated_moveset_sonic,     0)          // - NSONIC
    add_defeat_parameters(0x617,                        defeated_moveset_captain,   0)          // - NSHEIK
    add_defeat_parameters(File.MARINA_DOWN_STND_U,      defeated_moveset,           0)          // - NMARINA

    // REMIX 1p

    // @ Description
    // Adds parameter overrides for CPU Characters on Team Stage of Remix 1p.
    // @ Arguments
    // anim - animation id
    // moveset - pointer to moveset commands
    // flags - animation flags
    macro add_team_parameters(anim, moveset, flags) {
        dw {anim}
        dw {moveset}
        dw {flags}
    }

    // @ Description
    // Block of moveset commands for defeated characters.
    // Generic defeated moveset commands.
    team_moveset:
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Mario.
    team_moveset_mario:
    dw 0xAC000001                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Fox/Link.
    team_moveset_fox_link:
    dw 0xAC000001                           // Set Texture Form
    dw 0xAC100001                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated DK.
    team_moveset_donkey:
    dw 0xA0600001                           // Set Model Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Luigi.
    team_moveset_luigi:
    dw 0xAC000002                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Yoshi.
    team_moveset_yoshi:
    dw 0xAC000008                           // Set Texture Form
    dw 0xAC100008                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Captain Falcon.
    team_moveset_captain:
    dw 0xAC000006                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Kirby.
    team_moveset_kirby:
    dw 0xAC000007                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Pikachu.
    team_moveset_pikachu:
    dw 0xAC000006                           // Set Texture Form
    dw 0xAC100005                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Jigglypuff.
    team_moveset_jiggly:
    dw 0xAC000006                           // Set Texture Form
    dw 0xAC100006                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End
    // Moveset commands for defeated Ness.
    team_moveset_ness:
    dw 0xAC000004                           // Set Texture Form
    dw 0xD0000000                           // FSM = 0.0
    dw 0x00000000                           // End

    // @ Description
    // Array of menu action parameter overrides for defeated characters. Uses DownStandU animation.
    // Arguments          Animation file ID             Moveset data                Flags
    team_array:
    add_team_parameters(0x222,                        team_moveset_mario,     0)          // 0x00 - MARIO
    add_team_parameters(0x2B1,                        team_moveset_fox_link,  0)          // 0x01 - FOX
    add_team_parameters(0x34F,                        team_moveset_donkey,    0)          // 0x02 - DONKEY
    add_team_parameters(0x3E8,                        team_moveset,           0)          // 0x03 - SAMUS
    add_team_parameters(0x222,                        team_moveset_luigi,     0)          // 0x04 - LUIGI
    add_team_parameters(0x48A,                        team_moveset_fox_link,  0)          // 0x05 - LINK
    add_team_parameters(0x745,                        team_moveset_yoshi,     0)          // 0x06 - YOSHI
    add_team_parameters(0x617,                        team_moveset_captain,   0)          // 0x07 - CAPTAIN
    add_team_parameters(0x51D,                        team_moveset_kirby,     0)          // 0x08 - KIRBY
    add_team_parameters(0x80E,                        team_moveset_pikachu,   0)          // 0x09 - PIKACHU
    add_team_parameters(0x51D,                        team_moveset_jiggly,    0)          // 0x0A - JIGGLY
    add_team_parameters(0x6AF,                        team_moveset_ness,      0)          // 0x0B - NESS
    add_team_parameters(0,                            0x80000000,                 0)          // 0x0C - BOSS
    add_team_parameters(0x222,                        team_moveset,           0)          // 0x0D - METAL
    add_team_parameters(0x222,                        team_moveset,           0)          // 0x0E - NMARIO
    add_team_parameters(0x2B1,                        team_moveset,           0)          // 0x0F - NFOX
    add_team_parameters(0x34F,                        team_moveset,           0)          // 0x10 - NDONKEY
    add_team_parameters(0x3E8,                        team_moveset,           0)          // 0x11 - NSAMUS
    add_team_parameters(0x222,                        team_moveset,           0)          // 0x12 - NLUIGI
    add_team_parameters(0x48A,                        team_moveset,           0)          // 0x13 - NLINK
    add_team_parameters(0x745,                        team_moveset,           0)          // 0x14 - NYOSHI
    add_team_parameters(0x617,                        team_moveset,           0)          // 0x15 - NCAPTAIN
    add_team_parameters(0x51D,                        team_moveset,           0)          // 0x16 - NKIRBY
    add_team_parameters(0x80E,                        team_moveset,           0)          // 0x17 - NPIKACHU
    add_team_parameters(0x51D,                        team_moveset,           0)          // 0x18 - NJIGGLY
    add_team_parameters(0x1BA,                        team_moveset,           0)          // 0x19 - NNESS
    add_team_parameters(0x34F,                        team_moveset_donkey,    0)          // 0x1A - GDONKEY
    add_team_parameters(0,                            0x80000000,                 0)          // 0x1B - PLACEHOLDER
    add_team_parameters(0,                            0x80000000,                 0)          // 0x1C - PLACEHOLDER
    add_team_parameters(0x17A,                        team_moveset_fox_link,  0)          // 0x1D - FALCO
    add_team_parameters(File.GND_TEAM_POSE,           0x80000000,             0)          // 0x1E - GND
    add_team_parameters(File.YLINK_TEAM_POSE,         0x80000000,             0)          // 0x1F - YLINK
    add_team_parameters(File.DRM_TEAM_POSE,           0x80000000,             0)          // 0x20 - DRM
    add_team_parameters(File.WARIO_TEAM_POSE,         0x80000000,             0)          // 0x21 - WARIO
    add_team_parameters(File.DSAMUS_TEAM_POSE,        team_moveset,           0)          // 0x22 - DARK SAMUS
    add_team_parameters(0x19F,                        team_moveset_fox_link,  0)          // 0x23 - ELINK
    add_team_parameters(0x192,                        team_moveset,           0)          // 0x24 - JSAMUS
    add_team_parameters(0x1BA,                        team_moveset_ness,      0)          // 0x25 - JNESS
    add_team_parameters(File.LUCAS_TEAM_POSE,         0x80000000,             0)          // 0x26 - LUCAS
    add_team_parameters(0x19F,                        team_moveset_fox_link,  0)          // 0x27 - JLINK
    add_team_parameters(0x617,                        team_moveset_captain,   0)          // 0x28 - JFALCON
    add_team_parameters(0x2B1,                        team_moveset_fox_link,  0)          // 0x29 - JFOX
    add_team_parameters(0x171,                        team_moveset_mario,     0)          // 0x2A - JMARIO
    add_team_parameters(0x171,                        team_moveset_luigi,     0)          // 0x2B - JLUIGI
    add_team_parameters(0x34F,                        team_moveset_donkey,    0)          // 0x2C - JDK
    add_team_parameters(0x80E,                        team_moveset_pikachu,   0)          // 0x2D - EPIKA
    add_team_parameters(0x51D,                        team_moveset_jiggly,    0)          // 0x2E - JPUFF
    add_team_parameters(0x51D,                        team_moveset_jiggly,    0)          // 0x2F - EPUFF
    add_team_parameters(0x51D,                        team_moveset_kirby,     0)          // 0x30 - JKIRBY
    add_team_parameters(0x745,                        team_moveset_yoshi,     0)          // 0x31 - JYOSHI
    add_team_parameters(0x80E,                        team_moveset_pikachu,   0)          // 0x32 - JPIKA
    add_team_parameters(0x192,                        team_moveset,           0)          // 0x33 - ESAMUS
    add_team_parameters(File.BOWSER_TEAM_POSE,        0x80000000,             0)          // 0x34 - BOWSER
    add_team_parameters(0x1C9,                        team_moveset_yoshi,     0)          // 0x35 - GBOWSER
    add_team_parameters(0x171,                        team_moveset_mario,     0)          // 0x36 - PIANO
    add_team_parameters(File.WOLF_TEAM_POSE,          0x80000000,             0)          // 0x37 - WOLF
    add_team_parameters(File.CONKER_TEAM_POSE,        0x80000000,             0)          // 0x38 - CONKER
    add_team_parameters(File.MTWO_TEAM_POSE,          0x80000000,             0)          // 0x39 - MTWO
    add_team_parameters(File.MARTH_TEAM_POSE,         0x80000000,             0)          // 0x3A - MARTH
    add_team_parameters(File.SONIC_TEAM_POSE,         0x80000000,             0)          // 0x3B - SONIC
    add_team_parameters(0x617,                        team_moveset_captain,   0)          // 0x3C - SANDBAG
    add_team_parameters(File.SONIC_TEAM_POSE,         0x80000000,             0)          // 0x3D - SSONIC
    add_team_parameters(File.SHEIK_TEAM_POSE,         0x80000000,             0)          // 0x3E - SHEIK
    add_team_parameters(File.MARINA_TEAM_POSE,        0x80000000,             0)          // 0x3F - MARINA
    add_team_parameters(File.DEDEDE_TEAM_POSE,        0x80000000,             0)          // 0x40 - DEDEDE
    // ADD NEW CHARACTERS HERE

	// REMIX POLYGONS
    add_team_parameters(File.WARIO_TEAM_POSE,         0x80000000,             0)          // - NWARIO
    add_team_parameters(File.LUCAS_TEAM_POSE,         0x80000000,             0)          // - NLUCAS
    add_team_parameters(File.BOWSER_TEAM_POSE,        0x80000000,             0)          // - NBOWSER
    add_team_parameters(File.WOLF_TEAM_POSE,          0x80000000,             0)          // - NWOLF
    add_team_parameters(File.DRM_TEAM_POSE,           0x80000000,             0)          // - NDRM
    add_team_parameters(File.SONIC_TEAM_POSE,         0x80000000,             0)          // - NSONIC
    add_team_parameters(File.SHEIK_TEAM_POSE,         0x80000000,             0)          // - NSHEIK
    add_team_parameters(File.MARINA_TEAM_POSE,        0x80000000,             0)          // - NMARINA

    // @ Description
    // This prevents picking up the token of a CPU character with stocks remaining after a match.
    scope prevent_token_pickup_: {
        OS.patch_start(0x13588C, 0x8013760C)
        j       prevent_token_pickup_
        addiu   a2, r0, 0x00BC              // original line 1
        _return:
        OS.patch_end()

        // a0 = port_id
        // a1 = token_id
        multu   a1, a2                      // original line 2

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      v0, 0x000C(sp)              // ~
        sw      v1, 0x0010(sp)              // ~
        sw      t0, 0x0014(sp)              // ~

        mflo    t6                          // t6 = offset to token css planel struct
        sw      t6, 0x0018(sp)              // save offset to token css panel struct

        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _end                    // if not 12cb mode, return normally
        nop

        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        beqz    t0, _end                    // if not started, return normally
        nop

        jal     get_last_match_portrait_and_stocks_ // v0 = remaining stocks, v1 = portrait_id of last match
        or      a0, r0, a1                  // a0 = token_id
        beqz    v0, _end                    // if there are no remaining stocks (they lost), allow selecting token
        nop

        // otherwise, don't allow picking up the token if CPU
        lw      t6, 0x0018(sp)              // t6 = offset to token css panel struct
        li      t0, CharacterSelect.CSS_PLAYER_STRUCT
        addu    t0, t0, t6                  // t0 = css panel struct for token being picked up
        lbu     t6, 0x0022(t0)              // t6 = player type (0 if HMN, 1 if CPU)
        beqz    t6, _end                    // if human, allow selecting token
        nop


        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0008(sp)              // store ra

        jal     0x800269C0                  // original line 1 (play fgm)
        lli     a0, FGM.menu.ILLEGAL        // on branch, a0 = FGM.menu.ILLEGAL

        lw      ra, 0x00008(sp)             // load ra
        addiu   sp, sp, 0x0010              // deallocate stack space

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      v1, 0x0010(sp)              // ~
        lw      t0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra                          // exit routine
        nop

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      v0, 0x000C(sp)              // ~
        lw      v1, 0x0010(sp)              // ~
        lw      t0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        j       _return
        nop
    }

    // @ Description
    // Sets the initial stock count based on the previous match's ending stock count
    scope set_initial_stock_count_: {
        OS.patch_start(0x10A39C, 0x8018D4AC)
        jal     set_initial_stock_count_
        sw      r0, 0x0080(sp)              // original line 2
        OS.patch_end()

        // s0 = port_id

        li      t6, twelve_cb_flag
        lw      t6, 0x0000(t6)              // t6 = 1 if 12cb mode
        beqzl   t6, _end                    // if not 12cb mode, use default stock count
        lbu     t8, 0x0007(a1)              // original line 1 (t8 = default stock count)

        li      t6, config.p1.match         // t6 = config.p1.match
        li      t8, config.p2.match
        bnezl   s0, pc() + 8                // if p2, then set t6 to config.p2.match
        or      t6, r0, t8                  // t6 = config.p2.match

        // This runs before the current_game is updated, so the first game looks like 0xFFFFFFFF
        li      t8, config.current_game
        lw      t8, 0x0000(t8)              // t8 = previous game
        bltzl   t8, _get_portrait_stock_count // if first game, use stock count by portrait
        lbu     t8, 0x0003(t6)              // t8 = portrait_id

        sll     t8, t8, 0x0003              // t8 = t8 * 8 (offset to previous match)
        addu    a0, t6, t8                  // t6 = previous match struct
        lb      t8, 0x0002(a0)              // t8 = remaining stocks (0xFFFFFFFF if no stocks remaining)
        bgtz    t8, _end                    // if the player was not previously defeated, use remaining stocks
        nop
        lbu     t8, 0x000B(a0)              // t8 = portrait_id of current match

        _get_portrait_stock_count:
        li      t6, config.stocks_by_portrait_id
        addu    t6, t6, t8                  // t6 = stocks remaining for this portrait ID address
        lbu     t8, 0x0000(t6)              // t8 = stocks remaining

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Treats selected defeated characters as not selected to block starting the game.
    scope treat_selected_defeated_chars_as_unselected_: {
        // p1
        OS.patch_start(0x1385B8, 0x8013A338)
        j       treat_selected_defeated_chars_as_unselected_._p1
        lw      t8, 0xBBC8(t8)              // original line 2
        _return_p1:
        OS.patch_end()
        // p2
        OS.patch_start(0x1385E0, 0x8013A360)
        j       treat_selected_defeated_chars_as_unselected_._p2
        lw      t0, 0xBC84(t0)              // original line 2
        _return_p2:
        OS.patch_end()

        _p1:
        or      v1, a0, r0                  // original line 1

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      v0, 0x0014(sp)              // ~

        li      t0, twelve_cb_flag          // ~
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _end_p1                 // if not 12cb mode, skip
        nop

        // Now check if the character is defeated.
        lli     a0, 0x0000                  // a0 = port_id
        lui     a1, 0x8014
        jal     get_stocks_remaining_for_char_ // v0 = remaining_stocks
        lw      a1, 0xBAD0(a1)              // a1 = character_id
        beqzl   v0, _end_p1                 // if character has no stocks remaining, then character is defeated so v1 should be 0
        lli     v1, 0x0000

        // since Remix only has 8 chars, there could be undefeated chars available for the losing player
        // so we should check for that case and block starting accordingly
        li      t0, config.p1.stocks_remaining
        lw      t0, 0x0000(t0)              // t0 = stocks remaining
        beqzl   t0, _end_p1                 // if player has no stocks remaining, then v1 should be 0
        lli     v1, 0x0000

        _end_p1:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      v0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        j       _return_p1
        nop

        _p2:
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      t0, 0x0010(sp)              // ~
        sw      v0, 0x0014(sp)              // ~

        addiu   v1, v1, 0x0001              // original line 1

        li      t0, twelve_cb_flag          // ~
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqzl   t0, _end_p2                 // if not 12cb mode, skip
        nop

        // Now check if the character is defeated.
        lli     a0, 0x0001                  // a0 = port_id
        lui     a1, 0x8014
        jal     get_stocks_remaining_for_char_ // v0 = remaining_stocks
        lw      a1, 0xBB8C(a1)              // a1 = character_id
        beqzl   v0, _end_p2                 // if character has no stocks remaining, then character is defeated so v1 should be not be incremented
        addiu   v1, v1, -0x0001             // undo original line 1

        // since Remix only has 8 chars, there could be undefeated chars available for the losing player
        // so we should check for that case and block starting accordingly
        li      t0, config.p2.stocks_remaining
        lw      t0, 0x0000(t0)              // t0 = stocks remaining
        beqzl   t0, _end_p2                 // if player has no stocks remaining, then v1 should not be incremented
        addiu   v1, v1, -0x0001             // undo original line 1

        _end_p2:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      t0, 0x0010(sp)              // ~
        lw      v0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        j       _return_p2
        nop
    }

    // @ Description
    // Forces both players to input the reset command in order for a reset to occur.
    // In this case, the current game's data is wiped, as if it never happened.
    scope gentlemens_reset_: {
        // reset input entered
        OS.patch_start(0x8FCD0, 0x801144D0)
        jal     gentlemens_reset_
        addiu   v0, v0, 0x4AD0              // original line 1
        OS.patch_end()
        // unpause
        OS.patch_start(0x8FC90, 0x80114490)
        jal     gentlemens_reset_._unpause
        lui     t2, 0x800A                  // original line 1
        OS.patch_end()

        // 801317E4 = first byte is port of pausing player

        li      t7, twelve_cb_flag          // ~
        lw      t7, 0x0000(t7)              // t7 = 1 if 12cb mode
        beqz    t7, _end                    // if not 12cb mode, skip
        nop

        // check if this is a request or an approval
        li      t0, reset_requested
        lw      t7, 0x0000(t0)              // t7 = 0 if request, 1 if approval
        bnezl   t7, _reset                  // if reset is approved, do reset
        sw      r0, 0x0000(t0)              // clear reset request

        // otherwise, show the reset requested message
        lli     t7, OS.TRUE
        sw      t7, 0x0000(t0)              // set reset resquested

        lui     t6, 0x8013
        lbu     t6, 0x17E4(t6)              // t6 = port of player controlling pause state

        // show explanation
        OS.save_registers()
        li      t0, string_reset_line_1
        lli     t1, '1'                     // t1 = '1'
        addu    t1, t1, t6                  // t1 = '2' if 2P, '1' if 1P
        sb      t1, 0x0018(t0)              // set character in string
        Render.draw_string(0x18, 0xE, string_reset_line_1, Render.NOOP, 0x43200000, 0x42FC0000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.CENTER)
        Render.draw_string(0x18, 0xE, string_reset_line_2, Render.NOOP, 0x43200000, 0x43100000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.CENTER)
        Render.draw_string(0x18, 0xE, string_reset_accept, Render.NOOP, 0x42200000, 0x43240000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.LEFT)
        // use native routines to render reset button combo textures
        lli     s0, 0x0001                  // s0 = starting index
        or      s1, v0, r0                  // s1 = string_reset_accept object
        lli     s2, 0x0008                  // s2 = last texture index
        or      a0, s1, r0                  // a0 = string_reset_accept object
        _loop_button_mask:
        jal     0x80113D60                  // native routine to append images to object
        or      a1, s0, r0                  // a1 = texture index
        // t0 is ulx, t1 is uly
        addiu   t0, t0, -0x0004             // t0 = adjusted ulx
        mtc1    t0, f4                      // f4 = adjusted ulx
        cvt.s.w f6, f4                      // f6 = adjusted ulx, float
        swc1    f6, 0x0058(v0)              // set adjusted ulx
        addiu   t1, t1, -0x0027             // t1 = adjusted uly
        mtc1    t1, f8                      // f8 = adjusted uly
        cvt.s.w f10, f8                     // f10 = adjusted uly, float
        swc1    f10, 0x005C(v0)             // set adjusted uly
        addiu   s0, s0, 0x0001
        bnel    s0, s2, _loop_button_mask
        or      a0, s1, r0                  // a0 = string_reset_accept object

        Render.draw_string(0x18, 0xE, string_reset_decline, Render.NOOP, 0x433C0000, 0x43240000, 0xFFFFFFFF, Render.FONTSIZE_DEFAULT, Render.alignment.LEFT)
        Render.draw_texture_at_offset(0x18, 0xE, Render.file_pointer_1, 0x1D50, Render.NOOP, 0x43740000, 0x43240000, 0xff0000FF, 0x303030FF, 0x3F800000)
        OS.restore_registers()

        // give input control to other player, if not CPU
        li      t3, Global.vs.p1            // t3 = Global.vs.p1
        li      t4, Global.vs.p2            // t4 = Global.vs.p2
        beqzl   t6, pc() + 8                // if player is p1, set t3 to p2's vs struct
        or      t3, r0, t4                  // t3 = Global.vs.p2
        lbu     t4, 0x0002(t3)              // t4 = player type (0 = man, 1 = cpu, 2 = n/a)
        beqzl   t4, pc() + 8                // if player is HMN, then we'll give control to the opposing player
        xori    t6, t6, 0x0001              // t6 = opposite player (0 -> 1, 1 -> 0)
        lui     t7, 0x8013
        j       0x80114514                  // skip reset
        sb      t6, 0x17E4(t7)              // set port of player controlling pause state

        _reset:
        // reset remaining stocks clear out this game's data
        li      t0, config
        lw      t7, 0x0008(t0)              // t7 = current game
        sll     t6, t7, 0x0003              // t7 = offset in match struct
        beqzl   t7, pc() + 8                // if first game, reset status
        sw      r0, 0x0000(t0)              // set status to not started
        addiu   t7, t7, -0x0001             // current_game--
        sw      t7, 0x0008(t0)              // reset current game

        lli     at, 0x0000                  // loop param
        li      t0, config.p1.match

        // reset pX
        _loop:
        addu    t1, t0, t6                  // t1 = game struct
        lbu     t2, 0x0001(t1)              // t2 = starting stocks
        lbu     t3, 0x0002(t1)              // t3 = ending stocks
        subu    t4, t2, t3                  // t4 = stocks lost this game
        lbu     t3, 0x0003(t1)              // t3 = portrait_id
        lw      t5, -0x0004(t0)             // t5 = stocks remaining for pX
        addu    t5, t5, t4                  // t5 = stocks remaining at start of game
        sw      t5, -0x0004(t0)             // reset stocks remaining for pX
        lui     t4, 0x1C00                  // t4 = reset value for game
        sh      t4, 0x0000(t1)              // reset game (but keep portrait_id)
        sb      r0, 0x0002(t1)              // ~
        li      t1, config.stocks_by_portrait_id
        addu    t1, t1, t3                  // t1 = address of stocks remaining for this character
        sb      t2, 0x0000(t1)              // reset stocks remaining for this character

        li      t0, config.p2.match
        beqz    at, _loop                   // loop to reset both players
        addiu   at, at, 0x0001              // t1 = game struct

        _end:
        jr      ra
        addiu   t7, r0, 0x0001              // original line 2

        _unpause:
        li      t1, reset_requested
        sw      r0, 0x0000(t1)              // clear reset request

        jr      ra
        lw      t2, 0x50E8(t2)              // original line 2

        reset_requested:
        dw OS.FALSE
    }

    // @ Description
    // Checks if p3 or p4 holds B to enable going back to VS Game Mode screen.
    // This wouldn't be necessary if we allowed different port combinations in 12cb mode.
    scope check_p3_and_p4_back_: {
        constant NUM_FRAMES(45)
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        li      t0, input_table
        lbu     t3, 0x0002(t0)              // t3 = frames_held_p3
        lbu     t4, 0x0003(t0)              // t4 = frames_held_p4
        lli     a1, 0x0002                  // a1 = loop index/player
        or      t5, r0, t3                  // t5 = frames_held_p3

        _loop:
        lli     a0, Joypad.B                // a0 - button mask
        lli     a2, Joypad.HELD             // a2 - type
        jal     Joypad.check_buttons_       // v0 = bool (p3)
        lli     a3, OS.TRUE                 // a3 - match any?
        bnezl   v0, pc() + 8                // if back pressed, increment counter
        addiu   t5, t5, 0x0001              // frames_held_pX++
        beqzl   v0, pc() + 8                // if back not pressed, reset counter
        lli     t5, 0x0000                  // frames_held_pX = 0
        addu    t1, t0, a1                  // t1 = frames_held_pX address
        sb      t5, 0x0000(t1)              // update frames_held_pX
        sltiu   at, t5, NUM_FRAMES          // at = 0 if held NUM_FRAMES frames
        beqz    at, _back
        nop
        addiu   a1, a1, 0x0001              // increment loop index/player
        sltiu   at, a1, 0x0004              // at = 1 if still need to check p4
        bnezl   at, _loop                   // if we still need to check p4, loop
        or      t5, r0, t4                  // t5 = frames_held_p4

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop

        _back:
        sh      r0, 0x0000(t0)              // reset counters
        jal     Menu.change_screen_
        lli     a0, 0x0009                  // a0 = vs game mode screen_id
        b       _end
        nop

        input_table:
        dh 0x00                             // spacer for convenience
        db 0x00                             // p3
        db 0x00                             // p4
    }

    // @ Description
    // This adds/updates variant indicators to the panels.
    scope update_variant_indicators_: {
        // a0 = control object
        // 0x0030(a0) = p1 flag object (0 if non-existent)
        // 0x0034(a0) = p2 flag object (0 if non-existent)
        // 0x0038(a0) = p1 previous variant_type_id
        // 0x003C(a0) = p2 previous variant_type_id
        OS.save_registers()
        // a0 => 0x0010(sp)

        lli     s0, 0x0000                  // s0 = panel index = start at 0
        addiu   s1, a0, 0x0030              // s1 = address of p1 flag object pointer
        li      s2, CharacterSelect.CSS_PLAYER_STRUCT // s2 = CSS player struct for p1
        li      s3, Character.variant_type.table // s3 = variant_type table

        _loop:
        lw      t1, 0x0008(s1)              // t1 = previous variant_type_id
        lw      t2, 0x0048(s2)              // t2 = selected character_id
        addu    t3, s3, t2                  // t3 = address of variant_type
        lbu     t3, 0x0000(t3)              // t3 = variant_type

        beq     t1, t3, _next               // if the variant type hasn't changed this frame, then skip
        sw      t3, 0x0008(s1)              // otherwise we'll need to handle

        lw      a0, 0x0000(s1)              // a0 = flag object address
        beqz    a0, _check_type             // if there's not an object, skip destroying it
        nop
        sw      r0, 0x0000(s1)              // clear out reference
        jal     Render.DESTROY_OBJECT_      // destroy object
        nop

        _check_type:
        // here, check if flag should be drawn
        lw      t1, 0x0008(s1)              // t1 = previous variant_type_id
        lli     a0, Character.variant_type.J
        beql    t1, a0, _draw_flag          // if selected char is a J variant, draw J flag
        lli     a0, 0x0558                  // a0 = j flag offset TODO: make constant
        lli     a0, Character.variant_type.E
        beql    t1, a0, _draw_flag          // if selected char is a J variant, draw J flag
        lli     a0, 0x03B8                  // a0 = e flag offset TODO: make constant
        b       _next                       // otherwise don't draw anything
        nop

        _draw_flag:
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      s0, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      s3, 0x0010(sp)              // ~

        li      a2, Render.file_pointer_2   // a2 = pointer to CSS images file start address
        lw      a2, 0x0000(a2)              // a2 = base file address
        addu    a2, a2, a0                  // a2 = pointer to flag image footer
        lli     a0, 0x20                    // a0 = room
        lli     a1, 0x13                    // a1 = group
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lui     s1, 0x41D0                  // s1 = ulx
        bnezl   s0, pc() + 8                // if p2, adjust ulx
        lui     s1, 0x4369                  // s1 = ulx
        lui     s2, 0x433F                  // s2 = uly
        lli     s3, 0x0000                  // s3 = color
        lli     s4, 0x0000                  // s4 = palette
        jal     Render.draw_texture_
        lui     s5, 0x3F80                  // s5 = scale

        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      s3, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        sw      v0, 0x0000(s1)              // save reference to flag object

        _next:
        bnez    s0, _end                    // if we just processed p2, then we're done
        addiu   s0, s0, 0x0001              // s0++
        addiu   s1, s1, 0x0004              // s1++
        b       _loop
        addiu   s2, s2, 0x00BC              // s2++

        _end:
        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Calculates the best character for each player and sets up the string pointers.
    scope set_best_characters_: {
        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        beqz    t0, _end                    // if not started, skip
        nop

        li      at, config.current_game
        lw      t0, 0x0000(at)              // at = current game
        li      t1, config.p1.match         // t1 = p1 match struct
        li      t2, config.p2.match         // t2 = p2 match struct
        lli     s1, Character.id.NONE       // s1 = p1 previous character (NONE to start)
        sll     s1, s1, 0x0010              // s1 = p1 previous character (NONE to start) / p1 previous portrait (none to start)
        addiu   s1, s1, 0x00FF              // ~
        lli     s2, Character.id.NONE       // s2 = p2 previous character (NONE to start)
        sll     s2, s2, 0x0010              // s2 = p2 previous character (NONE to start) / p2 previous portrait (none to start)
        addiu   s2, s2, 0x00FF              // ~
        lli     s3, 0                       // s3 = p1's TKOs as character
        lli     s4, 0                       // s4 = p2's TKOs vs p1's character
        lli     s5, 0                       // s5 = p2's TKOs as character
        lli     s6, 0                       // s6 = p1's TKOs vs p2's character

        // clear current best characters data
        addiu   t4, r0, -0x0001             // t4 = -1 (1 less than lowest possible)
        li      t3, config.p1.best_character
        sw      s1, 0x0000(t3)              // set best character to none
        sw      r0, 0x0004(t3)              // clear best character string pointer
        sw      t4, 0x0008(t3)              // initialize best character TKOs for
        sw      r0, 0x000C(t3)              // initialize best character TKOs against
        li      t3, config.p2.best_character
        sw      s1, 0x0000(t3)              // set best character to none
        sw      r0, 0x0004(t3)              // clear best character string pointer
        sw      t4, 0x0008(t3)              // initialize best character TKOs for
        sw      r0, 0x000C(t3)              // initialize best character TKOs against

        or      t5, r0, sp                  // t5 = original sp

        // create temp table on stack
        addiu   sp, sp, -0x00D0
        // 12 entries of 0x10 size:
        //  - p1 character_id / p1 portrait_id
        //  - p1 TKOs for / p1 TKOs against
        //  - p2 character_id / p2 portrait_id
        //  - p2 TKOs for / p2 TKOs against
        // adds a 13th entry so that we can easily detect the end of the table without a counter

        // initialize character_ids in table
        or      t6, r0, sp                  // t6 = new sp
        _temp_table_loop:
        sw    s1, 0x0000(t6)
        sw    s1, 0x0008(t6)
        addiu t6, t6, 0x0010                // increment entry
        bne   t5, t6, _temp_table_loop
        nop

        addiu   t8, sp, -0x0010             // t8 = will hold current entry p1
        addiu   t9, sp, -0x0008             // t9 = will hold current entry p2

        _loop:
        lbu     a1, 0x0000(t1)              // a1 = p1 current game character
        lbu     a3, 0x0003(t1)              // a3 = p1 current game portrait
        sll     a1, a1, 0x0010              // a1 = p1 current game character / p1 current game portrait
        addu    a1, a1, a3                  // ~
        lbu     a2, 0x0000(t2)              // a2 = p2 current game character
        lbu     a0, 0x0003(t2)              // a0 = p2 current game portrait
        sll     a2, a2, 0x0010              // a2 = p2 current game character / p2 current game portrait
        addu    a2, a2, a0                  // ~


        beq     a1, s1, _check_p2_new_char  // if the game didn't start with a different character than last game, skip resetting counters
        nop
        lli     s3, 0                       // s3 = p1's TKOs as character
        lli     s4, 0                       // s4 = p2's TKOs vs p1's character
        addiu   t8, t8, 0x0010              // increment temp table
        sw      a1, 0x0000(t8)              // store character_id in temp table
        or      s1, r0, a1                  // update previous character for next iteration

        _check_p2_new_char:
        beq     a2, s2, _calculate_tkos     // if the game didn't start with a different character than last game, skip resetting counters
        nop
        lli     s5, 0                       // s5 = p2's TKOs as character
        lli     s6, 0                       // s6 = p1's TKOs vs p2's character
        addiu   t9, t9, 0x0010              // increment temp table
        sw      a2, 0x0000(t9)              // store character_id in temp table
        or      s2, r0, a2                  // update previous character for next iteration

        _calculate_tkos:
        lbu     t3, 0x0001(t1)              // t3 = p1's starting stock count for game, 0-based
        addiu   t3, t3, 0x0001              // t3 = p1's starting stock count for game
        lbu     t4, 0x0002(t1)              // t4 = p1's ending stock count for game, 0-based
        lli     t5, 0x00FF                  // t5 = 0x000000FF (no stocks remaining)
        beql    t5, t4, pc() + 8            // if no stocks remaining, adjust to -1
        addiu   t4, r0, -0x0001             // t4 = -1
        addiu   t4, t4, 0x0001              // t4 = p1's ending stock count for game
        subu    t3, t3, t4                  // t3 = p1's TKOs this game
        addu    s3, s3, t3                  // s3 = p1's TKOs as character
        addu    s6, s6, t3                  // s6 = p1's TKOs vs p2's character

        lbu     t5, 0x0001(t2)              // t5 = p2's starting stock count for game, 0-based
        addiu   t5, t5, 0x0001              // t5 = p2's starting stock count for game
        lbu     t6, 0x0002(t2)              // t6 = p2's ending stock count for game, 0-based
        lli     t7, 0x00FF                  // t7 = 0x000000FF (no stocks remaining)
        beql    t7, t6, pc() + 8            // if no stocks remaining, adjust to -1
        addiu   t6, r0, -0x0001             // t6 = -1
        addiu   t6, t6, 0x0001              // t6 = p2's ending stock count for game
        subu    t5, t5, t6                  // t5 = p2's TKOs this game
        addu    s5, s5, t5                  // s5 = p2's TKOs as character
        addu    s4, s4, t5                  // s4 = p2's TKOs vs p1's character

        sh      s4, 0x0004(t8)              // save p1 TKOs for to temp table
        sh      s3, 0x0006(t8)              // save p1 TKOs against to temp table
        sh      s6, 0x0004(t9)              // save p2 TKOs for to temp table
        sh      s5, 0x0006(t9)              // save p2 TKOs against to temp table

        _next:
        beqz    t0, _set_best_values        // if this is the last game, exit loop
        addiu   t1, t1, 0x0008              // t1 = next game's p1 game struct
        addiu   t2, t2, 0x0008              // t2 = next game's p2 game struct
        b       _loop                       // loop
        addiu   t0, t0, -0x0001             // t0 > 0 if games remaining to process

        // We do this at the end to make sure we don't over count a character's TKO differential
        _set_best_values:
        or      t8, r0, sp                  // t8 = temp table, p1
        lli     t0, Character.id.NONE
        sll     t0, t0, 0x0010
        addiu   t0, t0, 0x00FF              // t0 = 0x001C00FF (unset value)
        li      t5, config.p1.best_character_tkos_for
        lli     t9, 0x0000                  // t9 = loop index

        _best_values_loop:
        lw      t1, 0x0000(t8)              // t1 = character_id
        beq     t1, t0, _best_value_next    // if no character, then we're done
        nop
        lhu     t2, 0x0004(t8)              // t2 = TKOs for
        lhu     t3, 0x0006(t8)              // t3 = TKOs against
        lw      t6, 0x0000(t5)              // t6 = best TKOs for
        lw      t4, 0x0004(t5)              // t4 = best TKOs against
        slt     t7, t6, t2                  // t7 = 1 if this is the best TKOs for
        bnez    t7, _is_best                // if the best, update saved value
        addiu   t8, t8, 0x0010              // t8 = next entry
        bne     t6, t2, _best_values_loop   // if the TKOs for is not the same, skip updating
        slt     t7, t3, t4                  // t7 = 1 if TKOs against < saved TKOs against
        beqz    t7, _best_values_loop       // if the TKOs is not less than the saved value, skip updating
        nop

        _is_best:
        sw      t2, 0x0000(t5)              // save best TKOs for
        sw      t3, 0x0004(t5)              // save best TKOs against
        b       _best_values_loop           // continue looping
        sw      t1, -0x0008(t5)             // save best character_id

        _best_value_next:
        bnez    t9, _set_best_value_strings // if done looping, skip
        addiu   t8, sp, 0x0008              // t8 = temp table, p2
        li      t5, config.p2.best_character_tkos_for
        b       _best_values_loop
        lli     t9, 0x0001

        _set_best_value_strings:
        addiu   sp, sp, 0x00D0              // restore stack

        li      t5, config.p1.best_character
        lh      t6, 0x0000(t5)              // t6 = p1's best character_id
        li      t3, Training.char_id_to_entry_id
        addu    t3, t3, t6                  // t3 = address of entry_id in Training.string_table_char
        lbu     t3, 0x0000(t3)              // t3 = entry_id in Training.string_table_char
        sll     t3, t3, 0x0002              // t3 = offset to character string pointer
        li      t4, Training.string_table_char
        addu    t3, t4, t3                  // t3 = address of character string pointer
        lw      t3, 0x0000(t3)              // t3 = character string pointer
        sw      t3, 0x0004(t5)              // save best character's string pointer

        li      t5, config.p2.best_character
        lh      t6, 0x0000(t5)              // t6 = p2's best character_id
        li      t3, Training.char_id_to_entry_id
        addu    t3, t3, t6                  // t3 = address of entry_id in Training.string_table_char
        lbu     t3, 0x0000(t3)              // t3 = entry_id in Training.string_table_char
        sll     t3, t3, 0x0002              // t3 = offset to character string pointer
        li      t4, Training.string_table_char
        addu    t3, t4, t3                  // t3 = address of character string pointer
        lw      t3, 0x0000(t3)              // t3 = character string pointer
        sw      t3, 0x0004(t5)              // save best character's string pointer

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Checks R/Z button presses for updating custom character sets
    scope check_input_: {
        // a1 = player index (port 0 - 3)
        // v0 = pointer to player CSS struct
        // 0x0080(v0) = held token player index (port 0 - 3 or -1 if not holding a token)
        // v1 = input struct
        // t8 = pressed button mask

        addiu   sp, sp,-0x0050              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      t4, 0x0018(sp)              // ~
        sw      t5, 0x001C(sp)              // ~
        sw      t6, 0x0020(sp)              // ~
        sw      t7, 0x0024(sp)              // ~
        sw      a0, 0x0028(sp)              // ~
        sw      a1, 0x002C(sp)              // ~
        sw      a2, 0x0030(sp)              // ~
        sw      a3, 0x0034(sp)              // ~
        sw      t8, 0x0038(sp)              // ~
        sw      v0, 0x003C(sp)              // ~
        sw      v1, 0x004C(sp)              // ~

        lw      t2, 0x0080(v0)              // t2 = held token player index (port 0 - 3 or -1 if not holding a token)
        bltz    t2, _end                    // if not holding a token, skip
        sw      t2, 0x0044(sp)              // save held token player index
        li      t0, CharacterSelect.CSS_PLAYER_STRUCT
        bnezl   t2, pc() + 8                // if p2, set t0 to p2's CSS player struct
        addiu   t0, t0, 0x00BC              // t0 = CSS player struct of held token
        lw      t4, 0x00B4(t0)              // t4 = portrait_id (or -1 if not over a portrait)
        bltz    t4, _end                    // if not hovering over a portrait, skip
        sw      t4, 0x0040(sp)              // save portrait_id
        lw      t1, 0x0048(t0)              // t1 = char_id
        lli     t3, Character.id.NONE       // t3 = id.NONE
        beq     t1, t3, _end                // skip if not actually hovering over a portrait
        andi    t1, t8, Joypad.A | Joypad.CU | Joypad.CD | Joypad.CL | Joypad.CR // check if A or any C button pressed
        bnez    t1, _end                    // if A or any C button pressed this frame, skip cycling portrait since it will get selected
        nop

        andi    t1, t8, Joypad.DL | Joypad.DR // D-pad Left/Right
        beqz    t1, _check_char_set         // if not pressed, skip stock mode stuff
        nop

        li      t0, StockMode.stockmode_table
        sll     t3, t2, 0x0002              // t3 = offset in stock mode table
        addu    t0, t0, t3                  // t0 = address of stock mode
        lw      t0, 0x0000(t0)              // t0 = stock mode
        lli     t3, StockMode.mode.MANUAL
        bne     t0, t3, _check_char_set     // if not manual stock mode, don't adjust stocks
        nop
        li      t1, config.status
        lw      t1, 0x0000(t1)              // t1 = config.status
        addiu   t1, t1, -config.STATUS_COMPLETE
        beqz    t1, _check_char_set         // if the 12cb is complete, don't adjust stocks
        or      a0, t4, r0                  // a0 = portrait_id
        jal     was_portrait_played_
        or      a1, t2, r0                  // a1 = port
        bnez    v0, _check_char_set         // if portrait was played, don't adjust stocks
        lw      t2, 0x0044(sp)              // t2 = held token player index (port 0 - 3 or -1 if not holding a token)
        li      t0, CharacterSelect.render_control_object
        lw      t0, 0x0000(t0)              // t0 = render control object
        lw      t0, 0x0034(t0)              // t0 = stock icon and count indicators object
        sll     t1, t2, 0x0004              // t1 = offset to port's stocks remaining object
        addu    t0, t0, t1                  // t0 = address of stocks remaining object, minus 0x30
        addiu   a0, t0, 0x0030              // a0 = address of stocks remaining object
        or      a1, t2, r0                  // a1 = panel index
        lli     a3, 0x0001                  // a3 = +1 for right press
        andi    t1, t8, Joypad.DL           // t1 = 0 if not D-pad Left
        bnezl   t1, pc() + 8                // if D-pad left, set to -1
        addiu   a3, r0, -0x0001             // a3 = -1 for left press
        lbu     t1, 0x0004(a0)              // t1 = portrait_id
        li      t0, config.stocks_by_portrait_id
        jal     CharacterSelect.update_remaining_stocks_
        addu    a2, t0, t1                  // a2 = stocks remaining address

        _check_char_set:
        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        bnez    t0, _end                    // if not NOT_STARTED, skip
        nop
        lw      t2, 0x0044(sp)              // t2 = held token player index (port 0 - 3 or -1 if not holding a token)
        lw      t8, 0x0038(sp)              // t8 = pressed button mask
        li      t0, config.p1.character_set
        li      t1, config.p2.character_set
        bnezl   t2, pc() + 8                // if p2, set t0 to p2's character set
        or      t0, r0, t1                  // t0 = character set address
        lw      t0, 0x0000(t0)              // t0 = character set
        lli     t1, NUM_PRESETS             // t1 = custom character set
        bne     t0, t1, _end                // if not on the custom character set, skip
        addu    t0, t0, t2                  // t0 = character set index, adjusted for p2 if necessary

        lli     t3, 0x0000                  // t3 = 0 - amount to adjust portrait by (-1 or 1 may be set)

        lw      v1, 0x004C(sp)              // v1 = input struct
        lhu     v1, 0x0000(v1)              // v1 = held button mask
        andi    v0, v1, Joypad.Z            // v0 = 0 if Z not held
        bnezl   v0, _held_Z_R               // if held, cycle hovered portrait left
        addiu   t3, t3, -0x0001             // t3 = -1 (cycle left)

        andi    v0, v1, Joypad.R            // v0 = 0 if R not held
        bnezl   v0, _held_Z_R               // if held, cycle hovered portrait left
        addiu   t3, t3, 0x0001              // t3 = 1 (cycle right)

        // neither Z nor R is held, reset initial repeat delay
        li      t1, portrait_cycle_timer    // t1 = portrait_cycle_timer for p1
        bnezl   a1, pc() + 8                // based on the port, use the appropriate address
        addiu   t1, t1, 0x0002              // t1 = portrait_cycle_timer for p2
        addiu   t7, r0, -0x0001             // t7 = -1
        sh      t7, 0x0000(t1)              // save updated timer

        andi    t1, t8, Joypad.L            // L
        bnez    t1, _do_update              // if pressed, update all portraits
        nop

        andi    t1, t8, Joypad.DU           // dpad up
        bnez    t1, _preset                 // if pressed, update all portraits to one of the presets
        nop

        andi    t1, t8, Joypad.DD           // dpad down
        bnez    t1, _randomize              // if pressed, update all portraits randomly
        nop

        b       _end                        // nothing pressed, don't update portraits
        nop

        _held_Z_R:
        li      t1, portrait_cycle_timer    // t1 = portrait_cycle_timer for p1
        bnezl   a1, pc() + 8                // based on the port, use the appropriate address
        addiu   t1, t1, 0x0002              // t1 = portrait_cycle_timer for p2
        lh      t8, 0x0000(t1)              // t8 = timer for cycling portraits
        addiu   t8, t8, 0x0001              // t8++
        sh      t8, 0x0000(t1)              // t8 = timer for cycling portraits
        beqz    t8, _do_update              // t8 = 0 if initial press
        slti    t7, t8, 0x001E              // wait 30 frames
        bne     t7, r0, _end                // if not 30 or greater, skip cycling
        addiu   t8, t8, -0x0008             // add to timer (8 frames)
        sh      t8, 0x0000(t1)              // save updated timer

        _do_update:
        // t2 = token_id
        // t3 = 1 or -1: which way to adjust character_id; or 0: update all

        sw      t0, 0x0048(sp)              // save character set index
        lw      t4, 0x0040(sp)              // t4 = portrait_id
        li      t1, character_set_table
        sll     t0, t0, 0x0004              // t0 = offset to character set table array
        addu    t0, t1, t0                  // t0 = character set table array

        // update id_table
        lw      t1, 0x0000(t0)              // t1 = id_table
        addu    t1, t1, t4                  // t1 = address of character_id to update
        lbu     t5, 0x0000(t1)              // t5 = character_id
        li      t7, Training.char_id_to_entry_id
        addu    t7, t7, t5                  // t7 = address of entry_id
        lbu     t7, 0x0000(t7)              // t7 = entry_id
        addu    t7, t7, t3                  // t6 = updated entry_id
        // adjust to be within bounds of table
        lli     t6, Training.char_id_to_entry_id - Training.entry_id_to_char_id
        beql    t7, t6, pc() + 8            // if outside upper bound of table, set to 0
        lli     t7, 0x0000                  // t7 = first entry
        bltzl   t7, pc() + 8                // if outside lower bound of table, set to max
        lli     t7, Training.char_id_to_entry_id - Training.entry_id_to_char_id - 1

        li      t6, Training.entry_id_to_char_id
        addu    t6, t6, t7                  // t6 = address of updated_character_id
        lbu     t6, 0x0000(t6)              // t6 = updated character_id

        lli     t7, Character.id.SANDBAG
        bne     t6, t7, _valid_char_id      // if not Sandbag, we can keep going
        nop

        lw      t0, 0x0048(sp)              // t0 = character set index
        b       _do_update                  // skip Sandbag
        sll     t3, t3, 0x0001              // t3 = -2 or +2

        _valid_char_id:
        beqz    t3, _update_all             // if updating all portraits, use different logic
        nop
        sb      t6, 0x0000(t1)              // update character_id
        addiu   t7, t1, 0x0004              // t7 = other portrait_id slot to update (because of how it's set up)
        bnezl   t2, pc() + 8                // if p2, then slot is to the left 4 places, not right
        addiu   t7, t1, -0x0004             // t7 = other portrait_id slot to update (because of how it's set up)
        sb      t6, 0x0000(t7)              // update character_id

        // update portrait_offset_table
        li      t7, CharacterSelect.portrait_offset_by_character_table
        sll     t6, t6, 0x0002              // t6 = offset in portrait_offset_by_character_table
        addu    t7, t7, t6                  // t7 = address of portrait offset to use
        lw      t7, 0x0000(t7)              // t7 = portrait offset to use
        sll     t4, t4, 0x0002              // t4 = offset in portrait_offset_table
        lw      t1, 0x0004(t0)              // t1 = portrait_offset_table
        addu    t1, t1, t4                  // t1 = address of portrait offset to update
        sw      t7, 0x0000(t1)              // update portrait offset

        b       _update_portrait_id_table
        nop

        _update_all:
        li      t7, CharacterSelect.portrait_offset_by_character_table
        sll     t5, t6, 0x0002              // t5 = offset in portrait_offset_by_character_table
        addu    t7, t7, t5                  // t7 = address of portrait offset to use
        lw      t5, 0x0000(t7)              // t5 = portrait offset to use
        lw      t1, 0x0000(t0)              // t1 = id_table
        lw      t3, 0x0004(t0)              // t3 = portrait_offset_table
        lli     t7, NUM_SLOTS               // t7 = loop index

        _loop:
        sb      t6, 0x0000(t1)              // update character_id
        sw      t5, 0x0000(t3)              // update portrait offset
        addiu   t7, t7, -0x0001             // t7--
        addiu   t3, t3, 0x0004              // t3++
        bnez    t7, _loop
        addiu   t1, t1, 0x0001              // t1++

        b       _update_portrait_id_table
        nop

        _preset:
        li      t4, character_set_table
        sll     t0, t0, 0x0004              // t0 = offset to character set table array
        addu    t0, t4, t0                  // t0 = character set table array
        lw      t1, 0x0000(t0)              // t1 = id_table
        lw      t3, 0x0004(t0)              // t3 = portrait_offset_table
        lw      t6, 0x000C(t0)              // t6 = index to preset character set table
        sll     t5, t6, 0x0004              // t5 = offset to preset character set table array
        addu    t5, t4, t5                  // t5 = preset character set table array
        lw      t4, 0x0000(t5)              // t4 = preset id_table
        lw      t5, 0x0004(t5)              // t5 = preset portrait_offset_table
        lli     t7, NUM_SLOTS               // t7 = loop index
        addiu   t6, t6, 0x0001              // t6++ = next preset character set table index
        lli     v0, NUM_PRESETS             // v0 = max preset character set table index + 1
        beql    t6, v0, pc() + 8            // if next preset character set table index is out of bounds, reset to 0
        lli     t6, 0x0000                  // t6 = 0
        sw      t6, 0x000C(t0)              // save updated preset character set table index

        _loop_preset:
        lbu     v0, 0x0000(t4)              // v0 = character_id
        lw      t6, 0x0000(t5)              // t6 = portrait offset
        sb      v0, 0x0000(t1)              // update character_id
        sw      t6, 0x0000(t3)              // update portrait offset
        addiu   t7, t7, -0x0001             // t7--
        addiu   t3, t3, 0x0004              // t3++
        addiu   t5, t5, 0x0004              // t5++
        addiu   t4, t4, 0x0001              // t4++
        bnez    t7, _loop_preset
        addiu   t1, t1, 0x0001              // t1++

        b       _update_portrait_id_table
        nop

        _randomize:
        li      t1, character_set_table
        sll     t0, t0, 0x0004              // t0 = offset to character set table array
        addu    t0, t1, t0                  // t0 = character set table array
        lw      t1, 0x0000(t0)              // t1 = id_table
        lw      t3, 0x0004(t0)              // t3 = portrait_offset_table
        li      t4, CharacterSelect.portrait_offset_by_character_table
        lli     t7, NUM_SLOTS               // t7 = loop index

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t2, 0x000C(sp)              // ~
        sw      t4, 0x0014(sp)              // ~

        _loop_randomize:
        sw      t1, 0x0008(sp)              // ~
        sw      t3, 0x0010(sp)              // ~
        sw      t7, 0x0018(sp)              // ~

        jal     Global.get_random_int_      // v0 = random character_id
        lli     a0, Character.NUM_CHARACTERS

        lli     t0, Character.id.BOSS
        beq     v0, t0, _loop_randomize     // if Master Hand, get a different ID
        lli     t0, Character.id.SANDBAG
        beq     v0, t0, _loop_randomize     // if Sandbag, get a different ID
        lli     t0, Character.id.PLACEHOLDER
        beq     v0, t0, _loop_randomize     // if invalid, get a different ID
        lli     t0, Character.id.NONE
        beq     v0, t0, _loop_randomize     // if invalid, get a different ID
        nop

        // Check toggle to see if we should include variants
        li      t0, Toggles.entry_variant_random
        lw      t0, 0x0004(t0)              // t0 = random select with variants when 1
        bnez    t0, _next                   // if random select with variants is on, then skip variant checks
        nop
        li      t2, Character.variant_type.table
        addu    t2, t2, v0                  // t2 = address of variant type of character
        lbu     t2, 0x0000(t2)              // t2 = variant type of character
        bnez    t2, _loop_randomize         // if a variant, get a different ID
        nop

        _next:
        lw      t0, 0x0004(sp)              // restore registers (get_random_int_ may blow some away)
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      t3, 0x0010(sp)              // ~
        lw      t4, 0x0014(sp)              // ~
        lw      t7, 0x0018(sp)              // ~

        sll     t5, v0, 0x0002              // t5 = offset in portrait_offset_by_character_table
        addu    t4, t4, t5                  // t4 = address of portrait offset to use
        lw      t5, 0x0000(t4)              // t5 = portrait offset to use
        sb      v0, 0x0000(t1)              // update character_id
        sw      t5, 0x0000(t3)              // update portrait offset
        addiu   t7, t7, -0x0001             // t7--
        addiu   t3, t3, 0x0004              // t3++
        bnez    t7, _loop_randomize
        addiu   t1, t1, 0x0001              // t1++

        lw      t0, 0x0004(sp)              // restore registers
        lw      t2, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        _update_portrait_id_table:
        // update portrait_id_table
        lw      a0, 0x0008(t0)              // a0 = portrait_id_table
        jal     update_portrait_id_table_
        lw      a1, 0x0000(t0)              // a1 = id_table

        or      a0, r0, t2                  // a0 = port_id
        jal     update_character_set_
        lli     a1, OS.FALSE                // don't increment

        // audial feedback
        jal     0x800269C0
        lli     a0, FGM.menu.SCROLL         // play sound

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      t4, 0x0018(sp)              // ~
        lw      t5, 0x001C(sp)              // ~
        lw      t6, 0x0020(sp)              // ~
        lw      t7, 0x0024(sp)              // ~
        lw      a0, 0x0028(sp)              // ~
        lw      a1, 0x002C(sp)              // ~
        lw      a2, 0x0030(sp)              // ~
        lw      a3, 0x0034(sp)              // ~
        lw      v0, 0x003C(sp)              // ~
        addiu   sp, sp, 0x0050              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Modifies the code that checks if a character_id has changed to detect if a portrait_id has changed
    scope portrait_change_: {
        OS.patch_start(0x136DC0, 0x80138B40)
        // beql    t0, t3, 0x80138B5C       // original line 1
        j       portrait_change_
        nop
        _return:
        OS.patch_end()

        // t0 = new character ID
        // a3 = css player struct
        // a0 = panel index

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // ~

        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _skip                   // if not 12cb, do original code
        nop

        lw      t0, 0x00B4(a3)              // t0 = portrait_id
        li      t1, previous_portrait_id_pointer
        lw      t1, 0x0000(t1)              // t1 = previous portrait_id address, p1
        bnezl   a0, pc() + 8                // if p2, adjusted address
        addiu   t1, t1, 0x0010              // t1 = previous portrait_id address, p2
        lb      t1, 0x0000(t1)              // t1 = previous portrait_id
        beq     t0, t1, _skip               // if portrait_id didn't change, do original code
        nop                                 // otherwise, we'll return without checking character_id

        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        j       _return
        nop

        _skip:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        beq     t0, t3, j_0x80138B5C        // original line 1, modified
        nop

        j       _return
        nop

        j_0x80138B5C:
        j       0x80138B5C
        lw      ra, 0x001C(sp)              // original line 2
    }

    // @ Description
    // Prevents CPU selection of invalid character by other port changing from human to CPU while hovering over an invalid portrait.
    scope prevent_invalid_cpu_: {
        //OS.patch_start(0x1340F0, 0x80135E70)
        jal     prevent_invalid_cpu_
        addiu   at, r0, 0x001C              // original line 2
        //OS.patch_end()

        // t8 is current char_id
        li      a0, twelve_cb_flag
        lw      a0, 0x0000(a0)              // a0 = 1 if 12cb mode
        beqz    a0, _end                    // skip if not 12cb mode
        nop
        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        beqz    t0, _end                    // if NOT_STARTED, skip
        nop

        or      at, t8, r0                  // set at to current char_id so we branch to get a random char_id, which we handle elsewhere

        _end:
        jr      ra
        addiu   a3, r0, 0x0001              // original line 1
    }

    // @ Description
    // This adds/updates UI in the panels for custom character sets to explain how to change portraits.
    scope draw_custom_portrait_indicators_: {
        // a0 = control object
        // 0x0030(a0) = p1 object (0 if non-existent)
        // 0x0034(a0) = p2 object (0 if non-existent)
        // 0x0040(a0) = p1 blink timer
        // 0x0044(a0) = p2 blink timer
        OS.save_registers()
        // a0 => 0x0010(sp)

        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status
        bnez    t0, _end                    // if not NOT_STARTED, skip
        nop

        lli     s0, 0x0000                  // s0 = panel index = start at 0
        addiu   s1, a0, 0x0030              // s1 = address of p1 object pointer
        li      s2, CharacterSelect.CSS_PLAYER_STRUCT // s2 = CSS player struct for p1
        li      s3, config.p1.character_set // s3 = character set address for p1
        li      s4, config.p2.character_set // s4 = character set address for p2

        _loop:
        lw      t1, 0x0080(s2)              // t1 = token_id or -1 if token is not held
        bltz    t1, _check_destroy          // skip if not held
        nop

        lw      t3, 0x0000(s3)              // t3 = character set
        bnezl   t1, pc() + 8                // if p2, update character set to p2
        lw      t3, 0x0000(s4)              // t3 = character set
        sltiu   t3, t3, NUM_PRESETS         // t3 = 1 if character set is not custom
        bnez    t3, _check_destroy          // skip if character set is not custom
        nop

        lli     t1, Character.id.NONE
        lw      t2, 0x0048(s2)              // t2 = selected character_id
        beq     t1, t2, _check_destroy      // if no valid portrait is hovered, then skip
        nop

        // if here, then we need to display the object
        lw      a0, 0x0000(s1)              // a0 = object address
        bnez    a0, _update_display         // if object defined, skip creating it
        nop

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      s0, 0x0008(sp)              // ~
        sw      s1, 0x000C(sp)              // ~
        sw      s2, 0x0010(sp)              // ~
        sw      s3, 0x0014(sp)              // ~
        sw      s4, 0x0018(sp)              // ~

        // Draw left arrow
        Render.draw_texture_at_offset(0x1C, 0x16, 0x8013C4A0, 0xECE8, Render.NOOP, 0x41D00000, 0x432C0000, 0xFF0000FF, 0x303030FF, 0x3F800000)
        lw      s1, 0x000C(sp)              // s1 = object reference
        sw      v0, 0x0000(s1)              // save object reference
        or      a0, r0, v0                  // a0 = object

        // Draw right arrow
        li      a1, 0x8013C4A0              // a1 = file 0x11 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0x11 base address
        lli     t0, 0xEDC8                  // t0 = right arrow image footer offset
        addu    a1, a1, t0                  // t0 = right arrow image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x429C                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x432C                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur

        // Draw Z button
        lw      a0, 0x0000(s1)              // a0 = object reference
        li      a1, Render.file_pointer_4   // a1 = file 0xC5 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0xC5 base address
        lli     t0, Render.file_c5_offsets.Z // t0 = Z image footer offset
        addu    a1, a1, t0                  // t0 = Z image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x41D0                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x431A                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur
        li      t0, 0x848484FF              // color
        sw      t0, 0x0028(v0)              // set color
        li      t0, 0x303030FF              // palette
        sw      t0, 0x0060(v0)              // set palette

        // Draw R button
        lw      a0, 0x0000(s1)              // a0 = object reference
        li      a1, Render.file_pointer_4   // a1 = file 0xC5 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0xC5 base address
        lli     t0, Render.file_c5_offsets.R // t0 = R image footer offset
        addu    a1, a1, t0                  // t0 = R image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x428E                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x431C                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur
        li      t0, 0x848484FF              // color
        sw      t0, 0x0028(v0)              // set color
        li      t0, 0x303030FF              // palette
        sw      t0, 0x0060(v0)              // set palette

        // Draw L button legend text
        lli     a0, 0x1C                    // room
        lli     a1, 0x16                    // group
        li      a2, string_update_all       // string
        lli     a3, 0x0000                  // routine (Render.NOOP)
        li      s1, 0x43778000              // ulx (p2)
        lw      s2, 0x0010(sp)              // ~
        lw      t3, 0x0080(s2)              // t3 = token_id
        beqzl   t3, pc() + 8                // if p1, update X position
        lui     s1, 0x4224                  // ulx (p1)
        lui     s2, 0x4359                  // uly
        addiu   s3, r0, -0x0001             // color (0xFFFFFFFF)
        lui     s4, 0x3F50                  // scale
        lli     s5, Render.alignment.LEFT   // alignment
        lli     s6, Render.string_type.TEXT
        jal     Render.draw_string_
        lli     t8, 0x0001                  // blur
        lw      s1, 0x000C(sp)              // s1 = object reference
        lw      a0, 0x0000(s1)              // a0 = indicators object reference
        sw      v0, 0x0030(a0)              // save reference

        // Draw L button
        or      a0, v0, r0                  // a0 = object reference
        li      a1, Render.file_pointer_4   // a1 = file 0xC5 base address pointer
        lw      a1, 0x0000(a1)              // a1 = file 0xC5 base address
        lli     t0, Render.file_c5_offsets.L // t0 = L image footer offset
        addu    a1, a1, t0                  // t0 = L image footer address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x41C8                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x4358                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur
        li      t0, 0x848484FF              // color
        sw      t0, 0x0028(v0)              // set color
        li      t0, 0x303030FF              // palette
        sw      t0, 0x0060(v0)              // set palette
        lw      a0, 0x0004(v0)              // L button legend object
        sw      v0, 0x0030(a0)              // save reference to L button image

        // Draw dpad up icon legend text
        lli     a0, 0x1C                    // room
        lli     a1, 0x16                    // group
        li      a2, string_dpad_up_legend   // string
        lli     a3, 0x0000                  // routine (Render.NOOP)
        lui     s1, 0x432D                  // ulx (p2)
        lw      s2, 0x0010(sp)              // ~
        lw      t3, 0x0080(s2)              // t3 = token_id
        beqzl   t3, pc() + 8                // if p1, update X position
        lui     s1, 0x42D2                  // ulx (p1)
        lui     s2, 0x433B                  // uly
        addiu   s3, r0, -0x0001             // color (0xFFFFFFFF)
        lui     s4, 0x3F50                  // scale
        lli     s5, Render.alignment.LEFT   // alignment
        lli     s6, Render.string_type.TEXT
        jal     Render.draw_string_
        lli     t8, 0x0001                  // blur
        lw      s1, 0x000C(sp)              // s1 = object reference
        lw      a0, 0x0000(s1)              // a0 = indicators object reference
        sw      v0, 0x0040(a0)              // save reference

        // Draw preset dpad icon
        or      a0, v0, r0                  // a0 = object reference
        li      a1, Render.file_pointer_2   // a1 = CSS images file address pointer
        lw      a1, 0x0000(a1)              // a1 = CSS images file address
        addiu   a1, a1, 0x0218              // a2 = address of d-pad image footer TODO: make constant
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x42BA                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x433A                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur
        li      t0, 0x848484FF              // color
        sw      t0, 0x0028(v0)              // set color
        li      t0, 0x303030FF              // palette
        sw      t0, 0x0060(v0)              // set palette
        lui     t0, 0x3F40                  // t0 = scale
        sw      t0, 0x0018(v0)              // set x scale
        sw      t0, 0x001C(v0)              // set y scale
        lw      a0, 0x0004(v0)              // preset dpad icon legend object
        sw      v0, 0x0030(a0)              // save reference to preset dpad icon

        // Draw dpad down icon legend text
        lli     a0, 0x1C                    // room
        lli     a1, 0x16                    // group
        li      a2, string_dpad_down_legend // string
        lli     a3, 0x0000                  // routine (Render.NOOP)
        lui     s1, 0x432D                  // ulx (p2)
        lw      s2, 0x0010(sp)              // ~
        lw      t3, 0x0080(s2)              // t3 = token_id
        beqzl   t3, pc() + 8                // if p1, update X position
        lui     s1, 0x42D2                  // ulx (p1)
        lui     s2, 0x4349                  // uly
        addiu   s3, r0, -0x0001             // color (0xFFFFFFFF)
        lui     s4, 0x3F50                  // scale
        lli     s5, Render.alignment.LEFT   // alignment
        lli     s6, Render.string_type.TEXT
        jal     Render.draw_string_
        lli     t8, 0x0001                  // blur
        lw      s1, 0x000C(sp)              // s1 = object reference
        lw      a0, 0x0000(s1)              // a0 = indicators object reference
        sw      v0, 0x0044(a0)              // save reference

        // Draw random dpad icon
        or      a0, v0, r0                  // a0 = object reference
        li      a1, Render.file_pointer_2   // a1 = CSS images file address pointer
        lw      a1, 0x0000(a1)              // a1 = CSS images file address
        addiu   a1, a1, 0x0218              // a2 = address of d-pad image footer TODO: make constant
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lui     t0, 0x42BA                  // t0 = ulx
        sw      t0, 0x0058(v0)              // save ulx
        lui     t0, 0x4348                  // t0 = uly
        sw      t0, 0x005C(v0)              // save uly
        lli     t0, 0x0201                  // t0 = render flags
        sh      t0, 0x0024(v0)              // turn on blur
        li      t0, 0x848484FF              // color
        sw      t0, 0x0028(v0)              // set color
        li      t0, 0x303030FF              // palette
        sw      t0, 0x0060(v0)              // set palette
        lui     t0, 0x3F40                  // t0 = scale
        sw      t0, 0x0018(v0)              // set x scale
        sw      t0, 0x001C(v0)              // set y scale
        lw      a0, 0x0004(v0)              // random dpad icon legend object
        sw      v0, 0x0030(a0)              // save reference to random dpad icon

        Render.draw_rectangle(0x1C, 0x16, 0x62, 0xBC, 2, 2, Color.high.YELLOW, OS.FALSE)
        lw      s1, 0x000C(sp)              // s1 = object reference
        lw      a0, 0x0000(s1)              // a0 = indicators object reference
        sw      v0, 0x0048(a0)              // save reference
        Render.draw_rectangle(0x1C, 0x16, 0x62, 0xD0, 2, 2, Color.high.YELLOW, OS.FALSE)
        lw      s1, 0x000C(sp)              // s1 = object reference
        lw      a0, 0x0000(s1)              // a0 = indicators object reference
        sw      v0, 0x004C(a0)              // save reference

        lw      ra, 0x0004(sp)              // restore registers
        lw      s0, 0x0008(sp)              // ~
        lw      s1, 0x000C(sp)              // ~
        lw      s2, 0x0010(sp)              // ~
        lw      s3, 0x0014(sp)              // ~
        lw      s4, 0x0018(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        // adjust X positions if p2
        lw      t3, 0x0080(s2)              // t3 = token_id
        beqz    t3, _update_display         // if p1, skip updating X positions
        lw      a0, 0x0000(s1)              // a0 = object reference

        lw      t0, 0x0074(a0)              // t0 = left arrow image struct
        lui     t1, 0x436A                  // t1 = X position
        sw      t1, 0x0058(t0)              // save X position
        lw      t0, 0x0008(t0)              // t0 = right arrow image struct
        li      t1, 0x438E8000              // t1 = X position
        sw      t1, 0x0058(t0)              // save X position
        lw      t0, 0x0008(t0)              // t0 = Z button image struct
        lui     t1, 0x436A                  // t1 = X position
        sw      t1, 0x0058(t0)              // save X position
        lw      t0, 0x0008(t0)              // t0 = R button image struct
        li      t1, 0x438AC000              // t1 = X position
        sw      t1, 0x0058(t0)              // save X position

        lw      t0, 0x0030(a0)              // t0 = L button legend object
        lw      t0, 0x0030(t0)              // t0 = L button image struct
        lui     t1, 0x4368                  // t1 = X position
        sw      t1, 0x0058(t0)              // save X position

        lw      t0, 0x0040(a0)              // t0 = preset dpad icon legend object
        lw      t0, 0x0030(t0)              // t0 = preset dpad icon image struct
        lui     t1, 0x4321                  // t1 = X position
        sw      t1, 0x0058(t0)              // save X position

        lw      t0, 0x0044(a0)              // t0 = random dpad icon legend object
        lw      t0, 0x0030(t0)              // t0 = random dpad icon image struct
        sw      t1, 0x0058(t0)              // save X position

        lw      t0, 0x0048(a0)              // t0 = dpad up rectangle object
        lli     t1, 0x00A6                  // t1 = X position
        sw      t1, 0x0030(t0)              // save X position
        lw      t0, 0x004C(a0)              // t0 = dpad down rectangle object
        sw      t1, 0x0030(t0)              // save X position

        sw      r0, 0x0010(s1)              // reset timer to 0

        _update_display:
        // implements blinking arrows
        lw      t0, 0x0010(s1)              // t0 = timer
        addiu   t0, t0, 0x0001              // t0 = timer++
        sltiu   t2, t0, 0x000B              // t2 = 1 if timer < 60, 0 otherwise
        sltiu   at, t0, 0x0014              // at = 1 if timer < 90, 0 otherwise
        beqzl   at, pc() + 8                // if timer past 90, reset
        lli     t0, 0x0000                  // t0 = 0 to reset timer to 0
        sw      t0, 0x0010(s1)              // update timer

        lli     t1, 0x0201                  // t1 = render flags (blur)
        beqzl   t2, pc() + 8                // if in hide state, update render flags
        lli     t1, 0x0205                  // t1 = render flags (hide)

        lw      t0, 0x0074(a0)              // t0 = left arrow image struct
        sh      t1, 0x0024(t0)              // update render flags
        lw      t0, 0x0008(t0)              // t0 = right arrow image struct
        sh      t1, 0x0024(t0)              // update render flags

        b       _next
        nop

        _check_destroy:
        lw      a0, 0x0000(s1)              // a0 = object address
        beqz    a0, _next                   // if there's not an object, skip destroying it
        nop
        jal     Render.DESTROY_OBJECT_      // destroy object
        lw      a0, 0x004C(a0)              // a0 = dpad down rectangle object

        lw      a0, 0x0000(s1)              // a0 = object address
        jal     Render.DESTROY_OBJECT_      // destroy object
        lw      a0, 0x0048(a0)              // a0 = dpad up rectangle object

        lw      a0, 0x0000(s1)              // a0 = object address
        jal     Render.DESTROY_OBJECT_      // destroy object
        lw      a0, 0x0044(a0)              // a0 = dpad down legend string object

        lw      a0, 0x0000(s1)              // a0 = object address
        jal     Render.DESTROY_OBJECT_      // destroy object
        lw      a0, 0x0040(a0)              // a0 = dpad up legend string object

        lw      a0, 0x0000(s1)              // a0 = object address
        jal     Render.DESTROY_OBJECT_      // destroy object
        lw      a0, 0x0030(a0)              // a0 = update all string object

        lw      a0, 0x0000(s1)              // a0 = object address
        jal     Render.DESTROY_OBJECT_      // destroy object
        sw      r0, 0x0000(s1)              // clear out reference

        _next:
        bnez    s0, _end                    // if we just processed p2, then we're done
        addiu   s0, s0, 0x0001              // s0++
        addiu   s1, s1, 0x0004              // s1++
        b       _loop
        addiu   s2, s2, 0x00BC              // s2++

        _end:
        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Sets up custom display items on the 12cb CSS. Called from Render.asm.
    scope setup_: {
        constant GROUP_ALWAYS(8)
        constant GROUP_NOT_STARTED(9)
        constant GROUP_STARTED(10)
        constant GROUP_COMPLETED(0xC)

        constant X_P1(0x42F80000)
        constant X_P2(0x43400000)

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~

        Render.load_font()                                        // load font for strings
        Render.load_file(File.CHARACTER_PORTRAITS, Render.file_pointer_1) // load character portraits into file_pointer_1
        Render.load_file(File.CSS_IMAGES, Render.file_pointer_2)          // load CSS images into file_pointer_2
        Render.load_file(0x0024, Render.file_pointer_3)          // load file with "x" image into file_pointer_3
        Render.load_file(0x00C5, Render.file_pointer_4)          // load file with button images into file_pointer_4

        // add a room for our indicators that shows up on top of the panels
        lli     a0, 0x38                    // a0 = room
        lli     a1, 0x10                    // a1 = group
        lli     a2, 0x15                    // a2 = z_index
        lui     s1, 0x4120                  // s1 = ulx
        lui     s2, 0x4120                  // s2 = uly
        lui     s3, 0x439B                  // s3 = lrx
        jal     Render.create_room_
        lui     s4, 0x4366                  // s4 = lry

        lli     a0, 0x0000                  // a0 = p1
        jal     update_character_set_
        lli     a1, OS.FALSE                // a1 = increment? no

        lli     a0, 0x0001                  // a0 = p1
        jal     update_character_set_
        lli     a1, OS.FALSE                // a1 = increment? no

        jal     CharacterSelect.draw_portraits_
        lli     a0, OS.TRUE                 // a0 = 12cb flag

        // Stocks Remaining
        Render.draw_string(0x1E, GROUP_ALWAYS, string_stocks_remaining, Render.NOOP, 0x43200000, 0x42FC0000, 0xFFFFFFFF, 0x3F600000, Render.alignment.CENTER)
        Render.draw_number(0x1E, GROUP_ALWAYS, config.p1.stocks_remaining, Render.update_live_string_, X_P1, 0x430C0000, 0xB00000FF, 0x3F600000, Render.alignment.CENTER)
        Render.draw_number(0x1E, GROUP_ALWAYS, config.p2.stocks_remaining, Render.update_live_string_, X_P2, 0x430C0000, 0x4040C0FF, 0x3F600000, Render.alignment.CENTER)

        // Character Set
        Render.draw_string(0x1E, GROUP_NOT_STARTED, string_character_set, Render.NOOP, 0x43200000, 0x43200000, 0xFFFFFFFF, 0x3F600000, Render.alignment.CENTER)
        Render.draw_string_pointer(0x1E, GROUP_NOT_STARTED, config.p1.character_set_pointer, Render.update_live_string_, X_P1, 0x432D8000, 0xB00000FF, 0x3F600000, Render.alignment.CENTER)
        Render.draw_string_pointer(0x1E, GROUP_NOT_STARTED, config.p2.character_set_pointer, Render.update_live_string_, X_P2, 0x432D8000, 0x4040C0FF, 0x3F600000, Render.alignment.CENTER)

        // Best Character
        jal     set_best_characters_
        nop
        Render.draw_string(0x1E, GROUP_STARTED, string_best_character, Render.NOOP, 0x43200000, 0x43200000, 0xFFFFFFFF, 0x3F600000, Render.alignment.CENTER)
        Render.draw_string_pointer(0x1E, GROUP_STARTED, config.p1.best_character_pointer, Render.update_live_string_, X_P1, 0x432E0000, 0xB00000FF, 0x3F480000, Render.alignment.CENTER)
        Render.draw_string_pointer(0x1E, GROUP_STARTED, config.p2.best_character_pointer, Render.update_live_string_, X_P2, 0x432E0000, 0x4040C0FF, 0x3F480000, Render.alignment.CENTER)
        Render.draw_number(0x1E, GROUP_STARTED, config.p1.best_character_tkos_for, Render.update_live_string_, X_P1, 0x433B0000, 0xB00000FF, 0x3F480000, Render.alignment.CENTER)
        Render.draw_number(0x1E, GROUP_STARTED, config.p2.best_character_tkos_for, Render.update_live_string_, X_P2, 0x433B0000, 0x4040C0FF, 0x3F480000, Render.alignment.CENTER)

        // Reset button
        Render.draw_texture_at_offset(0x1E, GROUP_STARTED, 0x8013C4A0, 0x187A8, Render.NOOP, 0x43080000, 0x434E0000, 0xFFFFFFFF, 0x000000FF, 0x3F800000)
        li      t0, reset_button_pointer
        sw      v0, 0x0000(t0)              // save reference to reset button

        li      t0, config.status
        lw      t0, 0x0000(t0)              // t0 = battle status

        lli     a0, GROUP_STARTED           // a0 = group of items that should only display when battle has started
        jal     Render.toggle_group_display_
        sltiu   a1, t0, config.STATUS_STARTED // a1 = 1 if not started (1 = hide)

        lli     a0, GROUP_NOT_STARTED       // a0 = group of items that should only display when battle has not started
        jal     Render.toggle_group_display_
        xori    a1, a1, 0x0001              // a1 = 1 if started (1 = hide)

        lli     a0, config.STATUS_COMPLETE  // a0 = battle status when battle has completed
        bne     t0, a0, _register_routines  // if not completed, skip
        nop                                 // otherwise, render the winner wreath
        Render.load_file(0x0022, results_file_pointer) // load file with wreath image into results file pointer
        Render.draw_texture_at_offset(0x1E, GROUP_COMPLETED, results_file_pointer, 0xE2A0, Render.NOOP, 0x42A80000, 0x43080000, 0xFFFFFFFF, 0x000000FF, 0x3F200000)
        // adjust position based on winner
        li      t0, config.p1.stocks_remaining
        lw      t0, 0x0000(t0)              // t0 = p1 stocks remaining
        bnez    t0, _register_routines      // if p1 has stocks remaining, use p1 position (default)
        lui     t1, 0x4350                  // otherwise, set x position if p2 is the winner
        lw      t0, 0x0074(v0)              // t0 = image struct
        sw      t1, 0x0058(t0)              // update x position

        _register_routines:
        Render.register_routine(check_p3_and_p4_back_)
        li      t0, CharacterSelect.render_control_object
        sw      v0, 0x0000(t0)              // store this as the render control object (useful for debug menu)

        Render.register_routine(update_variant_indicators_)
        sw      r0, 0x0030(v0)              // clear p1 flag object pointer
        sw      r0, 0x0034(v0)              // clear p2 flag object pointer
        sw      r0, 0x0038(v0)              // clear p1 previous variant_type
        sw      r0, 0x003C(v0)              // clear p2 previous variant_type
        li      t0, CharacterSelect.render_control_object
        lw      t0, 0x0000(t0)              // t0 = render control object
        sw      v0, 0x0030(t0)              // save variant indicators object

        Render.register_routine(CharacterSelect.update_stock_icon_and_count_indicators_)
        sw      r0, 0x0030(v0)              // clear p1 stocks remaining object pointer
        sw      r0, 0x0034(v0)              // clear p1 previous portrait_id, char_id, stock mode, selected state
        sw      r0, 0x003C(v0)              // clear p1 yellow rectangle object pointer
        sw      r0, 0x0040(v0)              // clear p2 stocks remaining object pointer
        sw      r0, 0x0044(v0)              // clear p2 previous portrait_id, char_id, stock mode, selected state
        sw      r0, 0x004C(v0)              // clear p2 yellow rectangle object pointer
        sw      r0, 0x0050(v0)              // clear p3 stocks remaining object pointer
        sw      r0, 0x0054(v0)              // clear p3 previous portrait_id, char_id, stock mode, selected state
        sw      r0, 0x005C(v0)              // clear p3 yellow rectangle object pointer
        sw      r0, 0x0060(v0)              // clear p4 stocks remaining object pointer
        sw      r0, 0x0064(v0)              // clear p4 previous portrait_id, char_id, stock mode, selected state
        sw      r0, 0x006C(v0)              // clear p4 yellow rectangle object pointer
        li      t0, config.num_stocks
        lw      t0, 0x0000(t0)              // t0 = num_stocks
        sw      t0, 0x0070(a0)              // initialize previous num_stocks
        lli     t0, 0x0001                  // t0 = 1 for 12cb mode
        sw      t0, 0x0084(v0)              // set mode to 12cb
        li      t0, CharacterSelect.render_control_object
        lw      t0, 0x0000(t0)              // t0 = render control object
        sw      v0, 0x0034(t0)              // save stock icon and count indicators object
        li      t0, previous_portrait_id_pointer
        addiu   v0, v0, 0x0034              // v0 = address of portrait_ids
        sw      v0, 0x0000(t0)              // save reference to previous portrait_ids

        Render.register_routine(draw_custom_portrait_indicators_)
        sw      r0, 0x0030(v0)              // clear p1 object pointer
        sw      r0, 0x0034(v0)              // clear p2 object pointer
        sw      r0, 0x0040(v0)              // clear p1 timer
        sw      r0, 0x0044(v0)              // clear p2 timer
        li      t0, CharacterSelect.render_control_object
        lw      t0, 0x0000(t0)              // t0 = render control object
        sw      v0, 0x0038(t0)              // save custom portrait indicators object

        jal     CharacterSelectDebugMenu.init_debug_menu_
        lli     a0, 0x0000                  // a0 = offset in CharacterSelect.css_player_structs

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop

        results_file_pointer:; dw 0x00000000
    }

    string_stocks_remaining:;  String.insert("Stocks Remaining")
    string_character_set:;  String.insert("Character Set")
    string_character_set_default:; String.insert("Default")
    string_character_set_japanese:; String.insert("Japanese")
    string_character_set_polygon_vanilla:; String.insert("Polygon")
    string_character_set_remix:; String.insert("Remix")
    // string_character_set_polygon_remix:; String.insert("Polygon R")
    string_character_set_custom:; String.insert("Custom")
    string_best_character:; String.insert("Best Character")
    string_tkos:; String.insert("TKOs")

    string_reset_line_1:;  String.insert("Game reset requested by  P.")
    string_reset_line_2:;  String.insert("If accepted, stock counts will be reset.")
    string_reset_accept:;  String.insert("Accept:")
    string_reset_decline:;  String.insert("Decline:")

    string_game:; String.insert("Game   ")

    string_update_all:; String.insert(": Set All")
    string_dpad_up_legend:; String.insert(": Presets")
    string_dpad_down_legend:; String.insert(": Random")

    // @ Description
    // Pointers to custom objects
    reset_button_pointer:; dw 0x00000000
    previous_portrait_id_pointer:; dw 0x00000000

    // @ Description
    // Pointers to the character sets
    character_set_string_table:
    dw string_character_set_default
    dw string_character_set_japanese
    dw string_character_set_polygon_vanilla
    dw string_character_set_remix
    // dw string_character_set_polygon_remix
    dw string_character_set_custom

    // @ Description
    // Runs when a game starts and updates config values accordingly. Called from Render.asm.
    scope game_setup_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _end                    // if not 12cb mode, skip
        nop

        Render.load_font()                  // load font for reset
        Render.load_file(0xC4, Render.file_pointer_1) // load file with start icon for reset

        li      t0, config.status
        lli     t1, config.STATUS_STARTED
        sw      t1, 0x0000(t0)              // set 12cb to started
        lw      at, 0x0008(t0)              // at = current game
        addiu   at, at, 0x0001              // increment current game
        sw      at, 0x0008(t0)              // save current game
        sll     at, at, 0x0003              // at = current game * 8 = offset to game in match struct

        lli     a1, 0x0000                  // loop index (port_id)
        li      t3, Global.vs.p1
        li      t0, config.p1.match

        _loop:
        lbu     a0, 0x0003(t3)              // t1 = char_id
        lbu     t2, 0x000B(t3)              // t2 = stocks
        addu    t0, t0, at                  // t0 = game struct

        sb      a0, 0x0000(t0)              // save char_id
        sb      t2, 0x0001(t0)              // save starting stocks
        sb      t2, 0x0002(t0)              // save ending stocks

        li      t3, Global.vs.p2
        li      t0, config.p2.match
        beqz    a1, _loop                   // loop to initialize both players
        lli     a1, 0x0001                  // a1 = port_id

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Updates the stocks remaining for a game.
    // Have to do this during the game since they may skip results.
    scope update_stocks_remaining_: {
        OS.patch_start(0xB6930, 0x8013BEF0)
        jal     update_stocks_remaining_
        lb      t4, 0x002B(v0)              // original line 1
        OS.patch_end()
        OS.patch_start(0xB6988, 0x8013BF48)
        jal     update_stocks_remaining_
        lb      t4, 0x002B(v0)              // original line 1
        OS.patch_end()

        addiu   t5, t4, 0xFFFF              // original line 2

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      a1, 0x001C(sp)              // ~
        sw      v0, 0x0020(sp)              // ~

        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x0016                  // t1 = vs battle screen id
        bne     t0, t1, _end                // if screen id != vs battle, skip
        lbu     a0, 0x000D(s0)              // a0 = port

        li      t0, twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        bnez    t0, _12cb                   // if 12cb mode, skip to 12cb code
        nop                                 // otherwise update Stock Mode previous stock count

        li      t0, StockMode.previous_stock_count_table
        addu    t0, t0, a0                  // t0 = address of port's previous stock count
        b       _end                        // skip 12cb stuff
        sb      t5, 0x0000(t0)              // save previous stock count

        _12cb:
        li      t2, config.p1.match
        li      t3, config.p2.match
        bnezl   a0, pc() + 8                // if p2, then set t2 to config.p2.match
        or      t2, r0, t3                  // t2 = config.p2.match

        lw      t3, -0x0004(t2)             // t3 = stocks remaining
        addiu   t3, t3, -0x0001             // t3--
        sw      t3, -0x0004(t2)             // update stocks remaining

        li      t0, config.status
        lli     t1, config.STATUS_COMPLETE
        beqzl   t3, pc() + 8                // if no more stocks, then battle is over
        sw      t1, 0x0000(t0)              // so update status

        li      t0, config.current_game
        lw      at, 0x0000(t0)              // at = current game
        sll     at, at, 0x0003              // at = current game * 8 = offset to game in match struct
        addu    t2, t2, at                  // t2 = game struct
        sb      t5, 0x0002(t2)              // update ending stocks

        lbu     v0, 0x0003(t2)              // v0 = portrait_id
        li      t0, config.stocks_by_portrait_id
        addu    t0, t0, v0                  // t0 = address of stock count for this portrait_id
        sb      t5, 0x0000(t0)              // update stock count

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      a0, 0x0018(sp)              // ~
        lw      a1, 0x001C(sp)              // ~
        lw      v0, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Timer for cycling portraits with held buttons to control speed of cycling.
    portrait_cycle_timer:
    dh -0x0001, -0x0001     // p1, p2

}

} // __TWELVE_CHAR_BATTLE__
