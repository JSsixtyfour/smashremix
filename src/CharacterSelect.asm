// Character.asm
if !{defined __CHARACTER_SELECT__} {
define __CHARACTER_SELECT__()
print "included CharacterSelect.asm\n"

// @ Description
// This file contains modifications to the Character Select screen

// TODO
// why is gdk crashing
// animations for additonal characters 
// costumes    
// fire in the background/question marks 
// memory issue mergew (in progress)
// 1p/2p/cpu logo on hands
// hiding token on tiles at the bottom
// draw cpu token instead of player token (for default but removes value tbh?)
// automatic token placement on cpu select (DONE) and character (NOT DONE)
// ready to fight appearance

include "Global.asm"
include "OS.asm"
include "RCP.asm"
include "Texture.asm"

scope CharacterSelect {

    // @ Description
    // Subroutine which loads a character, but uses an alternate req list which loads only the main
    // and model file, instead of all of the character's files. This is safe on the select screen.
    scope load_character_model_: {
        // a0 = character id
        OS.save_registers()
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0008(sp)              // store ra
        sll     t6, a0, 0x2                 // t6 = character id * 4
        li      t7, alt_req_table           // t7 = alt_req_table
        li      t8, alt_req_list            // t8 = alt_req_list address
        addu    t7, t6, t7                  // t7 = alt req table + (character id * 4)
        lw      t6, 0x0000(t7)              // t6 = req list ROM offset
        bnel    t6, r0, _load               // branch if t6 != 0
        sw      t6, 0x0000(t8)              // on branch, store alt_req_list
        _load:
        jal     0x800D786C                  // load character
        nop
        lw      ra, 0x0008(sp)              // load ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        OS.restore_registers()
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Patch vs mode character select loading routine to use load_character_model_
    OS.patch_start(0x139440, 0x8013B1C0)
    jal     load_character_model_
    OS.patch_end()
    
    // @ Description
    // Patch which causes a character's files to be loaded at the end of the heap instead of
    // updating the heap end with a fixed(?) address.
    // TODO: understand why the character files are loaded at a seemingly fixed position rather
    // than being loaded at the end of the heap under normal circumstances. (low priority)
    scope file_load_fix_: {
        OS.patch_start(0x52EC8, 0x800D76C8)
        j       file_load_fix_
        nop
        _return:
        OS.patch_end()
        
        // v0 = heap_end override
        li      at, alt_req_list            // at = alt_req_list address
        lw      at, 0x0000(at)              // at = alt_req_list
        beq     at, r0, _end                // skip if alt_req_list = 0
        nop
        li      at, 0x800D6348              // at = heap_end address
        lw      v0, 0x0000(at)              // v0 = heap_end
        
        _end:
        // original lines 1/2
        jal     0x800CDC88                  // load file (with heap_end override in a1)
        or      a1, v0, r0                  // a1 = heap_end override
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Patch which checks for an alternate req list, in theory this should always contain the ROM
    // offset of the main file's req list the first time it runs after load_character_model_
    get_alternate_req_list_: {
        OS.patch_start(0x4934C, 0x800CD96C)
        j       get_alternate_req_list_
        nop
        _return:
        OS.patch_end()
        
        // s4 contains current req ROM offset
        li      a0, alt_req_list            // a0 = alt_req_list address
        lw      a1, 0x0000(a0)              // a1 = alt_req_list
        beq     a1, r0, _end                // skip if alt_req_list = 0
        nop
        or      s4, a1, r0                  // move new ROM offset to s4
        sw      r0, 0x0000(a0)              // destroy alt_req_list
        
        _end:
        or      a0, s4, r0                  // move rom offset to a0 (original line 1)
        or      a1, s0, r0                  // original line 2
        j       _return                     // return
        nop   
    }
    
    // @ Description
    // Holds the ROM offset of an alternate req list, used by get_alternate_req_list_
    alt_req_list:
    dw  0
    
    // @ Description
    // Table of alternate req list ROM offsets.
    alt_req_table:
    constant alt_req_table_origin(origin())
    fill Character.NUM_CHARACTERS * 0x4
    
    // @ Description
    // Adds an alternate req list for a given character.
    // @ Arguments
    // character - ID of the character to add an alternate req list for
    // filename - Name of a .req file in ..src, excluding extension 
    variable alt_req_list_count(0)
    macro add_alt_req_list(character, filename) {
        global variable alt_req_list_count(alt_req_list_count + 1)
        evaluate num(alt_req_list_count)
        
        // Insert new req list
        // TODO: these req lists don't need to be in the DMA segment/RAM (low priority)
        // but they don't take up much space
        constant ALT_REQ_{num}(origin())
        insert "../src/{filename}.req"
        
        // Add new req list to alt_req_table
        pushvar origin, base
        origin alt_req_table_origin + ({character} * 0x4)
        dw ALT_REQ_{num}
        pullvar base, origin
    }
    
    
    // ADD ALTERNATE REQ LISTS //
    add_alt_req_list(Character.id.MARIO, req/MARIO_MODEL)
    add_alt_req_list(Character.id.FOX, req/FOX_MODEL)
    add_alt_req_list(Character.id.DONKEY, req/DONKEY_MODEL)
    add_alt_req_list(Character.id.SAMUS, req/SAMUS_MODEL)
    add_alt_req_list(Character.id.LUIGI, req/LUIGI_MODEL)
    add_alt_req_list(Character.id.LINK, req/LINK_MODEL)
    add_alt_req_list(Character.id.YOSHI, req/YOSHI_MODEL)
    add_alt_req_list(Character.id.CAPTAIN, req/CAPTAIN_MODEL)
    add_alt_req_list(Character.id.KIRBY, req/KIRBY_MODEL)
    add_alt_req_list(Character.id.PIKACHU, req/PIKACHU_MODEL)
    add_alt_req_list(Character.id.JIGGLY, req/JIGGLY_MODEL)
    add_alt_req_list(Character.id.NESS, req/NESS_MODEL)
    add_alt_req_list(Character.id.FALCO, req/FALCO_MODEL)
    add_alt_req_list(Character.id.GND, req/GND_MODEL)
    add_alt_req_list(Character.id.YLINK, req/YLINK_MODEL)
    add_alt_req_list(Character.id.DRM, req/DRM_MODEL)
    

    // @ Description
    // This function returns what character is selected by the token's position
    // this is purely based on token position, not hand position
    // @ Returns
    // v0 - character id
    scope get_character_id_: {
        OS.patch_start(0x000135AEC, 0x8013786C)
        j       get_character_id_
        nop
        OS.patch_end()
        
        mfc1    v1, f10             // original line 1 (v1 = (int) ypos)
        mfc1    a1, f6              // original line 2 (a1 = (int) xpos)

        // make the furthest left/up equal 0 for arithmetic purposes
        addiu   a1, a1, -START_X    // a1 = xpos - X_START
        addiu   v1, v1, -START_Y    // v1 = ypos - Y_START

        addiu   sp, sp,-0x0010      // allocate stack space
        sw      t0, 0x0004(sp)      // ~
        sw      t1, 0x0008(sp)      // ~
        sw      t2, 0x000C(sp)      // save registers

        // calculate id
        lli     t0, PORTRAIT_WIDTH  // t0 = PORTRAIT_WIDTH
        divu    a1, t0              // ~
        mflo    t1                  // t1 = x index
        lli     t0, PORTRAIT_HEIGHT // t0 = PORTRAIT_HEIGHT
        divu    v1, t0              // ~
        mflo    t2                  // t2 = y index

        // multi dimmensional array math
        // index = (row * NUM_COLUMNS) + column
        lli     t0, NUM_COLUMNS     // ~
        multu   t0, t2              // ~
        mflo    t0                  // t0 = (row * NUM_COLUMNS)
        addu    t0, t0, t1          // t0 = index

        // return id.NONE if index is too large for table
        lli     t1, NUM_PORTRAITS   // t1 = NUM_PORTRAITS
        sltu    t2, t0, t1          // if (t0 < t1), t2 = 0
        beqz    t2, _end            // explained above lol
        lli     v0, Character.id.NONE // also explained above lol

        li      t1, id_table        // t1 = id_table
        addu    t0, t0, t1          // t1 = id_table[index]
        lbu     v0, 0x0000(t0)      // v0 = character id
        
        _end:
        lw      t0, 0x0004(sp)      // ~
        lw      t1, 0x0008(sp)      // ~
        lw      t2, 0x000C(sp)      // save registers
        addiu   sp, sp, 0x0010      // deallocate stack space
        jr      ra                  // return (discard the rest of the function)
        addiu   sp, sp, 0x0028      // deallocate stack space (original function)
    }


    // @ Description
    // Overlay.asm hook for drawing things.
    scope run_: {

        // disable drawing of default portraits
        OS.patch_start(0x001307A0, 0x80132520)
        jr      ra 
        nop
        OS.patch_end()


        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      t2, 0x0010(sp)              // ~
        sw      t3, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      a1, 0x001C(sp)              // ~
        sw      a2, 0x0020(sp)              // ~
        sw      a3, 0x0024(sp)              // ~
        sw      t4, 0x0028(sp)              // ~
        sw      v1, 0x002C(sp)              // save registers

        // draw each character portrait
        // for each row
        // for each column

        lli     t0, NUM_ROWS                // init rows
        _outer_loop:
        beqz    t0, _cursor                 // once every row complete, draw cursor (hand/token)
        nop
        addiu   t0, t0,-0x0001              // decrement outer loop

        
        lli     t1, NUM_COLUMNS             // init columns
        _inner_loop:
        beqz    t1, _outer_loop             // once every column in row drawn, draw next row
        nop
        addiu   t1, t1,-0x0001              // decrement inner loop


        // calculate ulx/uly offset
        lli     a2, PORTRAIT_WIDTH
        multu   a2, t1                      // ~
        mflo    t3                          // t3 = ulx offset
        lli     a2, PORTRAIT_HEIGHT
        multu   a2, t0                      // ~
        mflo    t4                          // t4 = uly offset

        // add to ulx/uly
        lli     a0, START_X + START_VISUAL  // ~
        addu    a0, a0, t3                  // a0 - ulx
        lli     a1, START_Y + START_VISUAL  // ~
        addu    a1, a1, t4                  // a1 - uly

        // draw character portrait
        lli     t2, NUM_COLUMNS             // ~
        multu   t0, t2                      // ~
        mflo    t2                          // ~
        addu    t2, t2, t1                  // ~
        li      t3, id_table                // ~
        addu    t3, t3, t2                  // t3 = (id_table + ((y * NUM_COLUMNS) + x))
        lbu     t3, 0x0000(t3)              // t3 = id of character to draw
        sll     t3, t3, 0x0002              // t3 = id * 4
        li      t4, portrait_table          // t4 = portrait table
        addu    t4, t4, t3                  // t4 = portrait_table[id]
        lw      t4, 0x0000(t4)              // t4 = address of texture
        li      a2, portrait_info           // a2 - address of texture struct
        sw      t4, 0x008(a2)               // update texture to draw
        jal     Overlay.draw_texture_       // draw portrait
        nop

        b       _inner_loop                 // loop
        nop


        // draw difference
        // 438AFFFF,  43867FFF
        // holding, pointing/open
        // ~278 ~269

        // 0x0000(player data) = cursor
        // 0x0000
        _cursor:
        lli     at, 0x0003                  // i = 3

        _loop:
        lli     a0, Color.BLUE
        jal     Overlay.set_color_          // fill color = blue
        nop

        li      t0, player_data             // t0 = player_data_table
        sll     t1, at, 0x0002              // t1 = i * 4
        addu    t0, t0, t1                  // t0 = player_data_table[i]
        lw      t1, 0x0000(t0)              // t1 = data


        _token:
        lw      t2, 0x0004(t1)              // t2 = p2 token
        lw      a0, 0x00E0(t2)              // a0 = (float) p2 token x
        jal     OS.float_to_int_            // v0 = (int) p2 token x
        nop
        or      v1, v0, r0                  // v1 = (int) p2 token x
        lw      a0, 0x00E4(t2)              // a0 = (float) p2 token y
        jal     OS.float_to_int_            // v0 = (int) p2 token y
        nop

        or      a0, v1, r0                  // a0 - ulx 
        or      a1, v0, r0                  // a1 - uly
        sll     t2, at, 0x0002              // t2 = index * 4
        li      t3, token_textures          // ~
        addu    t3, t3, t2                  // ~
        lw      t3, 0x0000(t3)              // t3 = address of hand texture
        li      a2, token_info              // a2 - address of texture struct
        sw      t3, 0x00008(a2)             // update info image data
        jal     Overlay.draw_texture_       // draw portrait
        nop


        _hand:
        lw      t2, 0x0000(t1)              // t2 = hand
        lw      a0, 0x0170(t2)              // a0 = (float) p2 hand x
        jal     OS.float_to_int_            // v0 = (int) p2 hand x
        nop
        or      v1, v0, r0                  // v1 = (int) p2 hand x
        lw      a0, 0x0174(t2)              // a0 = (float) p2 hand y
        jal     OS.float_to_int_            // v0 = (int) p2 hand y
        nop

        or      a0, v1, r0                  // a0 - ulx 
        or      a1, v0, r0                  // a1 - uly
        addiu   a0, a0, 0x0001              // ulx correction
        addiu   a0, a0, 0x0003              // uly correction
        lw      t2, 0x0054(t1)              // t2 = hand state

        _holding:
        lli     t3, 0x0002                  // t1 = OPEN_HAND
        bne     t2, t3, _hand_pointing      // if not OPEN_HAND, skip
        nop
        addiu   a0, a0,-000011              // ~
        addiu   a1, a1,-000011              // hand correction

        _hand_pointing:
        lli     t3, 0x0000                  // t3 = HAND_POINTING
        bne     t2, t3, _draw_hand          // if not HAND_POINTING, skip
        nop
        // TODO: hand pointing on windows
        addiu   a1, a1,-000001              // hand correction

        _draw_hand:
        sll     t2, t2, 0x0002              // t1 = hand_state * 4
        li      t3, hand_textures           // ~
        addu    t3, t3, t2                  // ~
        lw      t3, 0x0000(t3)              // t3 = address of hand texture
        li      a2, hand_info               // a2 - address of texture struct
        sw      t3, 0x00008(a2)             // update info image data
        jal     Overlay.draw_texture_       // draw portrait
        nop

        bnez    at, _loop                   // draw for all cursors
        addiu   at, at,-0x0001              // decrement i


        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      t2, 0x0010(sp)              // ~
        lw      t3, 0x0014(sp)              // ~
        lw      a0, 0x0018(sp)              // ~
        lw      a1, 0x001C(sp)              // ~
        lw      a2, 0x0020(sp)              // ~
        lw      a3, 0x0024(sp)              // ~
        lw      t4, 0x0028(sp)              // ~
        lw      v1, 0x002C(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return
        nop

    }

    // @ Description
    // Places the token when the HMN/CPU/NONE button is pressed
    // TODO: fix automatic character
    scope place_token_from_id_: {
        OS.patch_start(0x00136A30, 0x801387B0)
//      slti    at, v0, 0x0006              // original line 1
//      bnez    at, 0x801387FC              // original line 2
        j       place_token_from_id_
        nop
        _return:
        OS.patch_end()

        // v0 = portrait_id (0-5 on the top row, 6-11 on bottom in original)
        // 0x0058(t8) = xpos
        // 0x005C(t8) = ypos

        lw      t8, 0x0074(a2)              // original line ?
        
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // save registers

        // get character
        li      t0, id_table                // t0 = id_table
        sll     t1, v0, 0x0002              // t1 = portrati_id * 4
        addu    t0, t0, t1                  // t0 = id_table + offset
        lbu     t0, 0x0000(t0)              // t0 = character_id


        // get token location
        lli     t0, NUM_COLUMNS - 1         // ~
        divu    v0, t0                      // ~
        mfhi    t1                          // t1 = portrait_id % NUM_COLUMNS = column
        lli     t0, PORTRAIT_WIDTH          // ~
        multu   t0, t1                      // ~
        mflo    t2                          // t2 = ulx
        addiu   t2, t2, START_X + (PORTRAIT_WIDTH / 2)             // t2 = (int) ulx + offset
        move    a0, t2                      // ~
        jal     OS.int_to_float_            // ~
        nop
        move    t2, v0                      // t2 = (float) ulx + offset
        sw      t2, 0x0058(t8)              // update token_xpos

        lw      v0, 0x0010(sp)              // restore v0 (portrait_id)
        lli     t0, NUM_COLUMNS - 1         // ~
        divu    v0, t0                      // ~
        mflo    t1                          // t1 = portrait_id / NUM_COLUMS = row
        lli     t0, PORTRAIT_HEIGHT         // ~
        multu   t0, t1                      // ~
        mflo    t2                          // t2 = uly
        addiu   t2, t2, START_Y + (PORTRAIT_HEIGHT / 2)             // t2 = (int) uly + offset
        move    a0, t2                      // ~
        jal     OS.int_to_float_            // ~
        nop
        move    t2, v0                      // t2 = (float) uly + offset
        sw      t2, 0x005C(t8)              // update token_ypos

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space

        // actual end
        lw      ra, 0x0014(sp)              // restore ra
        jr      ra                          // end function
        addiu   sp, sp, 0x0018              // deallocate stack space

    }
    

    // @ Description
    // Bypasses CPU token being recalled when selecting a portrait with the
    // character id NONE   
    OS.patch_start(0x00136D70, 0x80138AEC)
    // TODO: better fix
//  lli     at, r0, Character.id.NONE
    lli     at, 0x7FFF                      // at = really large unsinged value
    OS.patch_end()

    // @ Description
    // removes white flash on character select
    OS.patch_start(0x134730, 0x801364B0)
    nop
    OS.patch_end()


    // @ Description
    // 1. memory solution 
    scope move_filetable_: {
        OS.patch_start(0x000499F8, 0x800CE018)
//      jr      ra                          // original line
//      sw      t6, 0x002C(v0)              // original line
        //j       move_filetable_
        //nop
        OS.patch_end()
        
        li      t3, 0x00000200              // t3 = hardcode filetable length
        sw      t3, 0x001C(v0)              // update filetable length
        li      t3, 0x80700000              // t3 = hardcoded filetable address
        sw      t3, 0x0020(v0)              // update filetable address

        jr      ra                          // original line
        sw      t6, 0x002C(v0)              // original line
    }

    // @ Description
    // allows for custom entries of series logo based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x11)
    scope get_name_texture_: {
        OS.patch_start(0x00130E18, 0x80132B98)
//      lw      t8, 0x0024(t8)                  // original line
        j       get_name_texture_
        lw      t5, 0xC4A0(t5)                  // original line
        _get_name_texture_return:
        OS.patch_end()
    
        li      t8, name_texture_table      // t8 = texture offset table 
        addu    t8, t8, a2                      // t8 = address of texture offset
        lw      t8, 0x0000(t8)                  // t8 = texture offset
        j       _get_name_texture_return    // return
        nop
    }

    // @ Description
    // Allows for custom entries of series logo based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x14)
    scope get_series_logo_offset_: {
        OS.patch_start(0x00130D68, 0x80132AE8)
//      addu    t5, sp, a2                  // original line (sp holds table, a2 holds char id * 4)
//      lw      t5, 0x0054(t5)              // original line (t5 = file offset of data)
        j       get_series_logo_offset_ 
        nop 
        _get_series_logo_offset_return:
        OS.patch_end()
    
        li      t5, series_logo_offset_table
        addu    t5, t5, a2
        lw      t5, 0x0000(t5)
        j       _get_series_logo_offset_return
        nop
    }

    // @ Description
    // Disables token movement when token set down (migrates towards original spot)
    OS.patch_start(0x001376E0, 0x80139460)
    jr      ra
    nop
    OS.patch_end()

    // @ Description
    // Loads from white_circle_size_table instead of original table
    // @ Note
    // All values are 1.5 except DK. Possibly change this to static in the future
    scope get_zoom_: {
        OS.patch_start(0x00137E18, 0x80139B98)
//      addiu   a1, sp, 0x0004                  // original line
        j       get_zoom_                       // set table to custom table
        addiu   t6, t6, 0xB90C                  // original line
        _get_zoom_return:
        OS.patch_end()

        li      a1, white_circle_size_table // set a1
        j       _get_zoom_return            // return
        nop
    }

    // @ Description
    // This is the hook for loading more characters. Located directly after the initial characters.
    scope load_additional_characters_: {
        OS.patch_start(0x00139458, 0x8013B1D8)
        j       load_additional_characters_
        nop
        _return:
        OS.patch_end()

        // for (char_id i = FACLO; i < DRM; i++)
        lli     s0, Character.id.NMARIO      // s0 = index (and start character, skips polygons)
        
        _loop:
        jal     load_character_model_       // load character function
        or      a0, s0, r0                  // a0 = index
        slti    at, s0, Character.id.NNESS  // end on x character (Character.NUM_CHARACTERS - 1 should work usually)
        bnez    at, _loop
        addiu   s0, s0, 0x0001              // increment index
        lui     v1, 0x8014                  // original line 1
        lui     s0, 0x8013                  // original line 2
        j       _return
        nop

    }


    // @ Description
    // Changes the loads from fgm_table instead of the original function table
    scope get_fgm_: {
        OS.patch_start(0x00134B10, 0x80136890)
//      sll     t5, t4, 0x0001             // original line
//      addu    a0, sp, t5                 // original line
        j       get_fgm_
        sll     t5, t4, 0x0001
        _get_fgm_return:
        OS.patch_end()

        OS.patch_start(0x00134B1C, 0x8013689C)
//      lw      a0, 0x0020(a0)             // original line
        nop
        OS.patch_end()

        li      a0, fgm_table          // a0 = table 
        addu    a0, a0, t5                 // a0 = table + char offset
        lhu     a0, 0x0000(a0)             // a0 = fgm id
        j       _get_fgm_return        // return
        nop       
    }

    // @ Description
    // Struct containting cursor information [tehz] (https://github.com/tehzz/SSB64-Notes/blob/master/Char%20Select%20Screen/struct%20-%20css-player-data.md)
    player_data:
    dw 0x8013BA88
    dw 0x8013BB44
    dw 0x8013BC00
    dw 0x8013BCBC

    // @ Description
    // rgba5551 textures for hands (placement is not the same as the original causing "correction" issues)
    hand_textures:
    dw hand_pointing
    dw hand_holding
    dw hand_open

    // @ Description
    // rgba551 textures for tokens
    token_textures:
    dw token_1
    dw token_2
    dw token_3
    dw token_4

    // @ Description
    // Structs for each of  type of texture mentioned above
    hand_info:;         Texture.info(HAND_WIDTH, HAND_HEIGHT)
    portrait_info:;     Texture.info(PORTRAIT_WIDTH, PORTRAIT_HEIGHT)
    token_info:;        Texture.info(TOKEN_WIDTH, TOKEN_HEIGHT)

    // @ Description
    // New table for sound fx (for each character)
    fgm_table:
    dh FGM.announcer.names.MARIO           // Mario
    dh FGM.announcer.names.FOX             // Fox
    dh FGM.announcer.names.DONKEY_KONG     // Donkey Kong
    dh FGM.announcer.names.SAMUS           // Samus
    dh FGM.announcer.names.LUIGI           // Luigi
    dh FGM.announcer.names.LINK            // Link
    dh FGM.announcer.names.YOSHI           // Yoshi
    dh FGM.announcer.names.CAPTAIN_FALCON  // Captain Falcon
    dh FGM.announcer.names.KIRBY           // Kirby
    dh FGM.announcer.names.PIKACHU         // Pikachu
    dh FGM.announcer.names.JIGGLYPUFF      // Jigglypuff
    dh FGM.announcer.names.NESS            // Ness
    
    // other sound fx
    dh FGM.announcer.names.MARIO           // Master Hand
    dh FGM.announcer.names.FOX             // Metal Mario
    dh FGM.announcer.names.DONKEY_KONG     // Polygon Mario
    dh FGM.announcer.names.SAMUS           // Polygon Fox
    dh FGM.announcer.names.LUIGI           // Polygon Donkey Kong
    dh FGM.announcer.names.LINK            // Polygon Samus
    dh FGM.announcer.names.YOSHI           // Polygon Luigi
    dh FGM.announcer.names.CAPTAIN_FALCON  // Polygon Link
    dh FGM.announcer.names.KIRBY           // Polygon Yoshi
    dh FGM.announcer.names.PIKACHU         // Polygon Captain Falcon
    dh FGM.announcer.names.JIGGLYPUFF      // Polygon Kirby
    dh FGM.announcer.names.NESS            // Polygon Pikachu
    dh FGM.announcer.names.MARIO           // Polygon Jigglypuff
    dh FGM.announcer.names.FOX             // Polygon Ness
    dh FGM.announcer.names.DONKEY_KONG     // Giant Donkey Kong
    dh FGM.announcer.names.SAMUS           // (Placeholder)
    dh FGM.announcer.names.LUIGI           // None (Placeholder)
    dh FGM.announcer.names.LINK            // Falco
    dh FGM.announcer.names.YOSHI           // Ganondorf
    dh FGM.announcer.names.CAPTAIN_FALCON  // Young Link
    dh FGM.announcer.names.KIRBY           // Dr. Mario
    OS.align(4)

    // @ Description
    // This. loads the zoom table for each character so they all appear the same
    // size. this table has been moved and extended [Fray]
    // @ Note
    // To be moved to Character.asm
    OS.patch_start(0x00132E58, 0x80134BD8)
    li      t2, character_zoom_table        // original line 1/3
    cvt.s.w f10, f8                         // original line 2
    OS.patch_end()

    character_zoom_table:
    float32 1.25                            // Mario
    float32 1.15                            // Fox
    float32 1.00                            // Donkey Kong
    float32 1.03                            // Samus
    float32 1.21                            // Luigi
    float32 1.33                            // Link
    float32 1.05                            // Yoshi
    float32 1.07                            // Captain Falcon
    float32 1.22                            // Kirby
    float32 1.20                            // Pikachu
    float32 1.25                            // Jigglypuff
    float32 1.30                            // Ness
    float32 1.00                            // Master Hand
    float32 1.25                            // Metal Mario
    float32 1.25                            // Polygon Mario
    float32 1.15                            // Polygon Fox
    float32 1.00                            // Polygon Donkey Kong
    float32 1.03                            // Polygon Samus
    float32 1.21                            // Polygon Luigi
    float32 1.33                            // Polygon Link
    float32 1.05                            // Polygon Yoshi
    float32 1.07                            // Polygon Captain Falcon
    float32 1.22                            // Polygon Kirby
    float32 1.20                            // Polygon Pikachu
    float32 1.25                            // Polygon Jigglypuff
    float32 1.30                            // Polygon Ness
    float32 1.25                            // Giant Donkey Kong
    float32 0.00                            // (Placeholder)
    float32 0.00                            // None (Placeholder)
    float32 1.15                            // Falco
    float32 1.04                            // Ganondorf
    float32 1.15                            // Young Link
    float32 1.27                            // Dr. Mario

    white_circle_size_table:
    float32 1.50                            // Mario
    float32 1.50                            // Fox
    float32 2.00                            // Donkey Kong
    float32 1.50                            // Samus
    float32 1.50                            // Luigi
    float32 1.50                            // Link
    float32 1.50                            // Yoshi
    float32 1.50                            // Captain Falcon
    float32 1.50                            // Kirby
    float32 1.50                            // Pikachu
    float32 1.50                            // Jigglypuff
    float32 1.50                            // Ness
    float32 1.50                            // Master Hand
    float32 1.50                            // Metal Mario
    float32 1.50                            // Polygon Mario
    float32 1.50                            // Polygon Fox
    float32 1.50                            // Polygon Donkey Kong
    float32 1.50                            // Polygon Samus
    float32 1.50                            // Polygon Luigi
    float32 1.50                            // Polygon Link
    float32 1.50                            // Polygon Yoshi
    float32 1.50                            // Polygon Captain Falcon
    float32 1.50                            // Polygon Kirby
    float32 1.50                            // Polygon Pikachu
    float32 1.50                            // Polygon Jigglypuff
    float32 1.50                            // Polygon Ness
    float32 2.00                            // Giant Donkey Kong
    float32 0.00                            // (Placeholder)
    float32 0.00                            // None (Placeholder)
    float32 1.50                            // Falco
    float32 1.50                            // Ganondorf
    float32 1.50                            // Young Link
    float32 1.50                            // Dr. Mario

    // @ Description
    // Logo offsets in file 0x14
    scope series_logo {
        constant MARIO_BROS(0x00000618)
        constant STARFOX(0x00001938)
        constant DONKEY_KONG(0x00000C78)
        constant METROID(0x000012D8)
        constant ZELDA(0x000025F8)
        constant YOSHI(0x00002C58)
        constant FZERO(0x000032B8)
        constant KIRBY(0x00001F98)
        constant POKEMON(0x00003918)
        constant EARTHBOUND(0x00003F78)
        constant SMASH(0x00000000)
    }

    series_logo_offset_table:
    dw series_logo.MARIO_BROS               // Mario
    dw series_logo.STARFOX                  // Fox
    dw series_logo.DONKEY_KONG              // Donkey Kong
    dw series_logo.METROID                  // Samus
    dw series_logo.MARIO_BROS               // Luigi
    dw series_logo.ZELDA                    // Link
    dw series_logo.YOSHI                    // Yoshi
    dw series_logo.FZERO                    // Captain Falcon
    dw series_logo.KIRBY                    // Kirby
    dw series_logo.POKEMON                  // Pikachu
    dw series_logo.POKEMON                  // Jigglypuff
    dw series_logo.EARTHBOUND               // Ness
    dw series_logo.SMASH                    
    dw series_logo.MARIO_BROS               
    dw series_logo.SMASH                    
    dw series_logo.SMASH                    
    dw series_logo.SMASH                   
    dw series_logo.SMASH                    
    dw series_logo.SMASH                    
    dw series_logo.SMASH                    
    dw series_logo.SMASH                   
    dw series_logo.SMASH                    
    dw series_logo.SMASH                    
    dw series_logo.SMASH                    
    dw series_logo.SMASH                    
    dw series_logo.SMASH                    
    dw series_logo.DONKEY_KONG              
    dw 0x00000000                           
    dw 0x00000000                           
    dw series_logo.STARFOX                  
    dw series_logo.ZELDA                    
    dw series_logo.ZELDA                    
    dw series_logo.MARIO_BROS        

    // @ Description
    // Name texture offsets in file 0x11
    scope name_texture {
        constant MARIO(0x00001838)
        constant FOX(0x000025B8)
        constant DONKEY_KONG(0x00001FF8)
        constant SAMUS(0x00002358)
        constant LUIGI(0x00001B18)
        constant LINK(0x00002BA0)
        constant YOSHI(0x00002ED8)
        constant CAPTAIN_FALCON(0x00003998)
        constant KIRBY(0x000028E8)
        constant PIKACHU(0x000032F8)
        constant JIGGLYPUFF(0x00003DB8)
        constant NESS(0x000035B0)
        constant BLANK(0x0)
    }

    name_texture_table:
    dw name_texture.MARIO                   // Mario
    dw name_texture.FOX                     // Fox
    dw name_texture.DONKEY_KONG             // Donkey Kong
    dw name_texture.SAMUS                   // Samus
    dw name_texture.LUIGI                   // Luigi
    dw name_texture.LINK                    // Link
    dw name_texture.YOSHI                   // Yoshi
    dw name_texture.CAPTAIN_FALCON          // Captain Falcon
    dw name_texture.KIRBY                   // Kirby
    dw name_texture.PIKACHU                 // Pikachu
    dw name_texture.JIGGLYPUFF              // Jigglypuff
    dw name_texture.NESS                    // Ness
    dw name_texture.BLANK                     // Master Hand
    dw name_texture.BLANK                     // Metal Mario
    dw name_texture.BLANK                     // Polygon Mario
    dw name_texture.BLANK                     // Polygon Fox
    dw name_texture.BLANK                     // Polygon Donkey Kong
    dw name_texture.BLANK                     // Polygon Samus
    dw name_texture.BLANK                     // Polygon Luigi
    dw name_texture.BLANK                     // Polygon Link
    dw name_texture.BLANK                     // Polygon Yoshi
    dw name_texture.BLANK                     // Polygon Captain Falcon
    dw name_texture.BLANK                     // Polygon Kirby
    dw name_texture.BLANK                     // Polygon Pikachu
    dw name_texture.BLANK                     // Polygon Jigglypuff
    dw name_texture.BLANK                     // Polygon Ness
    dw name_texture.BLANK                     // Giant Donkey Kong
    dw name_texture.BLANK                     // (Placeholder)
    dw name_texture.BLANK                     // None (Placeholder)
    dw name_texture.BLANK                     // Falco
    dw name_texture.BLANK                     // Ganondorf
    dw name_texture.BLANK                     // Young Link
    dw name_texture.BLANK                     // Dr. Mario

    constant START_X(22)
    constant START_Y(24)
    constant START_VISUAL(10)
    constant NUM_ROWS(3)
    constant NUM_COLUMNS(8)
    constant NUM_PORTRAITS(NUM_ROWS * NUM_COLUMNS)
    constant PORTRAIT_WIDTH(32)
    constant PORTRAIT_HEIGHT(31)


    // @ Description
    // CSS characters in order
    id_table:
    // row 1
    db Character.id.YLINK
    db Character.id.LUIGI
    db Character.id.MARIO
    db Character.id.DONKEY_KONG
    db Character.id.LINK
    db Character.id.SAMUS
    db Character.id.CAPTAIN_FALCON
    db Character.id.GND
    // row 2
    db Character.id.DRM
    db Character.id.NESS
    db Character.id.YOSHI
    db Character.id.KIRBY
    db Character.id.FOX
    db Character.id.PIKACHU
    db Character.id.JIGGLYPUFF
    db Character.id.FALCO
    // row 3
    db Character.id.NONE
    db Character.id.NONE
    db Character.id.NONE
    db Character.id.NONE
    db Character.id.NONE
    db Character.id.NONE
    db Character.id.NONE
    db Character.id.NONE
    OS.align(4)

    // hands
    insert hand_pointing,       "../textures/hand_pointing.rgba5551"
    insert hand_holding,        "../textures/hand_holding.rgba5551"
    insert hand_open,           "../textures/hand_open.rgba5551"

    constant HAND_WIDTH(32)
    constant HAND_HEIGHT(32)

    // @ Description
    // Texture inserts for tokens
    insert token_1,              "../textures/token_1.rgba5551"
    insert token_2,              "../textures/token_2.rgba5551"
    insert token_3,              "../textures/token_3.rgba5551"
    insert token_4,              "../textures/token_4.rgba5551"
    insert token_C,              "../textures/token_C.rgba5551"

    constant TOKEN_WIDTH(32)
    constant TOKEN_HEIGHT(31)

    // @ Description
    // Texture inserts for portraits
    insert portrait_donkey_kong,    "../textures/portrait_donkey_kong.rgba5551"
    insert portrait_falcon,         "../textures/portrait_falcon.rgba5551"
    insert portrait_fox,            "../textures/portrait_fox.rgba5551"
    insert portrait_jigglypuff,     "../textures/portrait_jigglypuff.rgba5551"
    insert portrait_kirby,          "../textures/portrait_kirby.rgba5551"
    insert portrait_link,           "../textures/portrait_link.rgba5551"
    insert portrait_luigi,          "../textures/portrait_luigi.rgba5551"
    insert portrait_mario,          "../textures/portrait_mario.rgba5551"
    insert portrait_ness,           "../textures/portrait_ness.rgba5551"
    insert portrait_pikachu,        "../textures/portrait_pikachu.rgba5551"
    insert portrait_samus,          "../textures/portrait_samus.rgba5551"
    insert portrait_yoshi,          "../textures/portrait_yoshi.rgba5551"

    portrait_table:
    dw portrait_mario                   // Mario
    dw portrait_fox                     // Fox
    dw portrait_donkey_kong             // Donkey Kong
    dw portrait_samus                   // Samus
    dw portrait_luigi                   // Luigi
    dw portrait_link                    // Link
    dw portrait_yoshi                   // Yoshi
    dw portrait_falcon                  // Captain Falcon
    dw portrait_kirby                   // Kirby
    dw portrait_pikachu                 // Pikachu
    dw portrait_jigglypuff              // Jigglypuff
    dw portrait_ness                    // Ness
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario
    dw portrait_mario                   // Mario

}


// costume addresses
// 8012B830 
// A7030 
// C1C2C3C4 RRBBGG??

} // __CHARACTER_SELECT__