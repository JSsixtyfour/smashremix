// Character.asm
if !{defined __CHARACTER_SELECT__} {
define __CHARACTER_SELECT__()
print "included CharacterSelect.asm\n"

// @ Description
// This file contains modifications to the Character Select screen

// TODO
// Training mode - models don't load
// 1p mode - apply
// BTT - apply
// BTP - apply
// why is gdk crashing
// costumes    
// automatic token placement on cpu select (DONE) and character (NOT DONE)

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
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0008(sp)              // store ra
        sll     t6, a0, 0x2                 // t6 = character id * 4
        li      t7, alt_req_table           // t7 = alt_req_table
        li      t8, alt_req_list            // t8 = alt_req_list address
        addu    t7, t6, t7                  // t7 = alt req table + (character id * 4)
        lw      t6, 0x0000(t7)              // t6 = req list ROM offset
        bnel    t6, r0, _malloc             // branch if t6 != 0
        sw      t6, 0x0000(t8)              // on branch, store alt_req_list
        _malloc:
        sll     t6, a0, 0x2                 // t6 = character id * 4
        li      t7, alt_malloc_table        // t7 = alt_malloc_table
        li      t8, alt_malloc_size         // t8 = alt_malloc_size address
        addu    t7, t6, t7                  // t7 = alt_malloc_table + (character id * 4)
        lw      t6, 0x0000(t7)              // t6 = alt_malloc_size for {character}
        addiu   t6, t6, 0x1000
        bnel    t6, r0, _end                // branch if t6 != 0
        sw      t6, 0x0000(t8)              // on branch, store alt_malloc_size
        _end:
        jal     0x800D786C                  // load character
        nop
        lw      ra, 0x0008(sp)              // load ra
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Patch vs mode character select loading routine to use load_character_model_
    OS.patch_start(0x139440, 0x8013B1C0)
    jal     load_character_model_
    OS.patch_end()
    
    // @ Description
    // Patch Training mode character select loading routine to use load_character_model_
    OS.patch_start(0x14737C, 0x80137D9C)
    jal     load_character_model_
    OS.patch_end()

    // @ Description
    // Patch 1P mode character select loading routine to use load_character_model_
    OS.patch_start(0x157DFC, 0x8013841C)
    //jal     load_character_model_
    OS.patch_end()

    // TODO: load_character_model_ call for BTT and BTP

    // @ Description
    // Patch which checks for an alternate malloc size, ensures that the right amount of space is
    // allocated when an alternate req list is loaded.
    scope get_alternate_malloc_size_: {
        OS.patch_start(0x52EBC, 0x800D76BC)
        j       get_alternate_malloc_size_
        nop
        _return:
        OS.patch_end()
        
        li      t6, alt_req_list            // t6 = alt_req_list address
        lw      t7, 0x0000(t6)              // t7 = alt_req_list
        beq     t7, r0, _end                // skip if alt_req_list = 0
        nop
        
        li      t6, alt_malloc_size         // t6 = alt_malloc_size address
        lw      t7, 0x0000(t6)              // t7 = alt_malloc_size
        beq     t7, r0, _end                // skip if alt_malloc_size = 0
        nop
        
        or      a0, r0, t7                  // a0 = alt_malloc_size
        sw      r0, 0x0000(t6)              // destroy alt_malloc_size
        
        _end:
        // original lines 1/2
        jal     0x80004980                  // malloc (original line 1)
        addiu   a1, r0, 0x0010              // original line 2
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Patch which checks for an alternate req list, in theory this should always contain the ROM
    // offset of the main file's req list the first time it runs after load_character_model_
    scope get_alternate_req_list_: {
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
    // Holds an alternate malloc size, used by get_alternate_malloc_size_
    alt_malloc_size:
    dw  0
    
    // @ Description
    // Table of alternate malloc sizes.
    // TODO: figure out if padding these segments by 0x200 is needed.
    // TODO: get the segment size for characters 0xC to 0x1A if we want to use them.
    alt_malloc_table:
    dw  0x7710                              // 0x00 - MARIO
    dw  0x8050                              // 0x01 - FOX
    dw  0xD800                              // 0x02 - DONKEY
    dw  0xE750                              // 0x03 - SAMUS
    dw  0x8110                              // 0x04 - LUIGI
    dw  0x12170                             // 0x05 - LINK
    dw  0xAEE0                              // 0x06 - YOSHI
    dw  0xCA90                              // 0x07 - CAPTAIN
    dw  0x1FFD0                             // 0x08 - KIRBY
    dw  0x9E30                              // 0x09 - PIKACHU
    dw  0x7FE0                              // 0x0A - JIGGLY
    dw  0xC5C0                              // 0x0B - NESS
    dw  0                                   // 0x0C - BOSS
    dw  0                                   // 0x0D - METAL
    dw  0                                   // 0x0E - NMARIO
    dw  0                                   // 0x0F - NFOX
    dw  0                                   // 0x10 - NDONKEY
    dw  0                                   // 0x11 - NSAMUS
    dw  0                                   // 0x12 - NLUIGI
    dw  0                                   // 0x13 - NLINK
    dw  0                                   // 0x14 - NYOSHI
    dw  0                                   // 0x15 - NCAPTAIN
    dw  0                                   // 0x16 - NKIRBY
    dw  0                                   // 0x17 - NPIKACHU
    dw  0                                   // 0x18 - NJIGGLY
    dw  0                                   // 0x19 - NNESS
    dw  0                                   // 0x1A - GDONKEY
    dw  0                                   // 0x1B - PLACEHOLDER
    dw  0                                   // 0x1C - PLACEHOLDER
    dw  0x8050                              // 0x1D - FALCO
    dw  0x19270                             // 0x1E - GND
    dw  0x14268                             // 0x1F - YLINK
    dw  0x7710                              // 0x20 - DRM
    dw  0x8A70                              // 0x21 - WARIO
    dw  0x12550                             // 0x22 - DARK SAMUS

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
    add_alt_req_list(Character.id.WARIO, req/WARIO_MODEL)
    add_alt_req_list(Character.id.DSAMUS, req/DSAMUS_MODEL)
    OS.align(4)

    // @ Description
    // This function returns what character is selected by the token's position
    // this is purely based on token position, not hand position
    // @ Returns
    // v0 - character id
    scope get_character_id_: {
        // VS
        OS.patch_start(0x000135AEC, 0x8013786C)
        j       get_character_id_
        nop
        OS.patch_end()

        // Training
        OS.patch_start(0x000144508, 0x80134F2C)
        j       get_character_id_
        nop
        OS.patch_end()

        // TODO: 1P, BTT and BTP

        // 1P
        //OS.patch_start(0x000135AEC, 0x8013786C)
        //j       get_character_id_
        //nop
        //OS.patch_end()
        
        mfc1    v1, f10                     // original line 1 (v1 = (int) ypos)
        mfc1    a1, f6                      // original line 2 (a1 = (int) xpos)

        // make the furthest left/up equal 0 for arithmetic purposes
        addiu   a1, a1, -START_X            // a1 = xpos - X_START
        addiu   v1, v1, -START_Y            // v1 = ypos - Y_START

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // save registers

        // discard values right of certain given x value
        sltiu   t0, a1, 240                 // if xpos less than given value
        beqz    t0, _end                    // ...return
        lli     v0, Character.id.NONE       // v0 = ret = NONE

        // calculate id
        lli     t0, PORTRAIT_WIDTH          // t0 = PORTRAIT_WIDTH
        divu    a1, t0                      // ~
        mflo    t1                          // t1 = x index
        lli     t0, PORTRAIT_HEIGHT         // t0 = PORTRAIT_HEIGHT
        divu    v1, t0                      // ~
        mflo    t2                          // t2 = y index

        // multi dimmensional array math
        // index = (row * NUM_COLUMNS) + column
        lli     t0, NUM_COLUMNS             // ~
        multu   t0, t2                      // ~
        mflo    t0                          // t0 = (row * NUM_COLUMNS)
        addu    t0, t0, t1                  // t0 = index

        // return id.NONE if index is too large for table
        lli     t1, NUM_PORTRAITS           // t1 = NUM_PORTRAITS
        sltu    t2, t0, t1                  // if (t0 < t1), t2 = 0
        beqz    t2, _end                    // explained above lol
        lli     v0, Character.id.NONE       // also explained above lol

        li      t1, id_table                // t1 = id_table
        addu    t0, t0, t1                  // t1 = id_table[index]
        lbu     v0, 0x0000(t0)              // v0 = character id
        
        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // save registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return (discard the rest of the function)
        addiu   sp, sp, 0x0028              // deallocate stack space (original function)
    }

    // disable drawing of default portraits on VS CSS
    OS.patch_start(0x001307A0, 0x80132520)
    jr      ra 
    nop
    OS.patch_end()

    // disable drawing of default portraits on Training Mode CSS
    OS.patch_start(0x001419B8, 0x801323D8)
    jr      ra
    nop
    OS.patch_end()

    // disable drawing of default portraits on 1P Mode CSS
    OS.patch_start(0x0013ADA4, 0x80132BA4)
    //jr      ra
    //nop
    OS.patch_end()

    // TODO: disable drawing of default portraits on BTP and BTT CSS

    // @ Description
    // Highjacks the display list of the portraits
    scope highjack_: {
        OS.patch_start(0x47AD0, 0x800CC0F0)
        j       highjack_
        nop
        _return:
        OS.patch_end()

        sw      t7, 0x0000(v1)              // original line 1
        sw      r0, 0x0004(v1)              // original line 2   

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      at, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // save registers

        // lazy attempt to see if the texture drawn is the "back" texture 
        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = screen id
        lli     at, 0x0010                  // at = vs css screen id
        beq     at, t0, _continue           // if (screen_id = vs css), continue
        nop
        lli     at, 0x0012                  // at = training css screen id
        beq     at, t0, _continue           // if (screen_id = training css), continue
        nop
        b       _skip                       // not on a valid css, so skip
        nop

        _continue:
        lli     at, 0x0030                  // at = expected height
        lhu     t0, 0x0014(s1)              // t0 = height
        bne     at, t0, _skip               // if test fails, end
        nop    


        lli     at, 0x000B                  // at = expected height
        lhu     t0, 0x0016(s1)              // t0 = width
        bne     at, t0, _skip               // if test fails, end
        nop

        // highjack here
        addiu   v0, v0, 0x0008              // increment v0
        addiu   v1, v1, 0x0008              // increment v1

        // init
        li      t0, RCP.display_list_info_p // t0 = display list info pointer 
        li      at, display_list_info       // at = address of display list info
        sw      at, 0x0000(t0)              // update display list info pointer

        // reset
        li      t0, display_list            // t0 = address of display_list
        li      at, display_list_info       // at = address of display_list_info
        sw      t0, 0x0000(at)              // ~
        sw      t0, 0x0004(at)              // update display list address each frame

        // highjack
        li      t0, 0xDE000000              // ~
        sw      t0, 0x0000(v1)              // ~
        li      t0, display_list            // ~ 
        sw      t0, 0x0004(v1)              // highjack ssb display list

        // draw
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
        beqz    t0, _end                    // once every row complete, draw cursor (hand/token)
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
        
        // get id of character to draw
        lli     t2, NUM_COLUMNS             // ~
        multu   t0, t2                      // ~
        mflo    t2                          // ~
        addu    t2, t2, t1                  // ~
        li      t3, id_table                // ~
        addu    t3, t3, t2                  // t3 = (id_table + ((y * NUM_COLUMNS) + x))
        lbu     t3, 0x0000(t3)              // t3 = id of character to draw
        
        // check for selection flash
        li      a2, flash_table             // a2 = flash_table
        addu    a2, a2, t3                  // a2 = flash_table + character id
        lbu     t4, 0x0000(a2)              // t4 = flash timer for {character}
        beq     t4, r0, _draw_portrait      // if flash = 0, _draw_portrait
        nop
        addiu   t4, t4,-0x0001              // decrement flash timer
        sb      t4, 0x0000(a2)              // store updated flash timer
        lli     a2, 0x0002                  // ~
        divu    t4, a2                      // ~
        mfhi    a2                          // a2 = flash % 2
        beq     a2, r0, _draw_portrait      // if flash % 2 = 0, _draw_portrait
        nop
        
        // draw selection flash
        li      t4, portrait_flash_table    // t4 = portrait flash table
        b       _draw
        nop

        // draw character portrait
        _draw_portrait:
        li      t4, portrait_table          // t4 = portrait table

        _draw:
        sll     t3, t3, 0x0002              // t3 = id * 4
        addu    t4, t4, t3                  // t4 = portrait_table[id]
        lw      t4, 0x0000(t4)              // t4 = address of texture
        li      a2, portrait_info           // a2 - address of texture struct
        sw      t4, 0x008(a2)               // update texture to draw
        jal     Overlay.draw_texture_       // draw portrait
        nop

        b       _inner_loop                 // loop
        nop
        
        _end:
        li      a0, 0xEF00AC3F              // ~ 
        li      a1, 0x00504241              // restore RDP other modes
        jal     RCP.append_
        nop
        jal     RCP.pipe_sync_
        nop
        jal     RCP.end_list_
        nop
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
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // restore registers registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop

        _skip:
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        j       _return                     // return
        nop
    }

    OS.align(16)
    display_list:
    fill 0x8000

    display_list_info:
    RCP.display_list_info(display_list, 0x8000)

    // @ Description
    // Allows random character to include remix characters
    scope get_random_char_id_: {
        // VS
        OS.patch_start(0x136AD8, 0x80138858)
//      jal     0x80018A30                  // original line 1
//      addiu   a0, r0, 0xC                 // original line 2
        jal     get_random_char_id_
        nop
        OS.patch_end()

        // Training
        OS.patch_start(0x147090, 0x80137AB0)
//      jal     0x80018A30                  // original line 1
//      addiu   a0, r0, 0xC                 // original line 2
        jal     get_random_char_id_
        nop
        OS.patch_end()

        addiu   sp, sp,-0x0004              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        _get_random_id:
        jal     0x80018A30                  // original line 1
        addiu   a0, r0, NUM_SLOTS           // original line 2 modified to include all slots
        // v0 = random number between 0 and NUM_SLOTS
        li      s0, id_table                // s0 = id_table
        addu    s0, s0, v0                  // s0 = id_table + offset
        lbu     v0, 0x0000(s0)              // v0 = character_id
        lli     s0, Character.id.NONE       // s0 = Character.id.NONE
        beq     s0, v0, _get_random_id      // if v0 is not a valid character then get a new random number
        nop                                 // ~

        lw      ra, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0004              // deallocate stack space

        jr      ra                          // return
        nop                                 // ~
    }

    // @ Description
    // Places the token based on character id
    scope place_token_from_id_: {
        // VS
        OS.patch_start(0x00136A28, 0x801387A8)
//      jal     0x80132168                  // original line 1
//      or      a0, a1, r0                  // original line 2
        j       place_token_from_id_
        nop
        OS.patch_end()

        // Training
        OS.patch_start(0x001452BC, 0x80135CDC)
//      jal     0x80132020                  // original line 1
//      or      a0, a1, r0                  // original line 2
        j       place_token_from_id_
        nop
        OS.patch_end()

        // 80132168/80132020 originally returned portrait_id in v0 (0-5 on the top row, 6-11 on bottom)
        // 0x0058(t8) = xpos
        // 0x005C(t8) = ypos
        // a0 = character id

        lw      t8, 0x0074(a2)              // original line ?
        or      a0, a1, r0                  // original line 2
        
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        // allocate stack space for v0
        sw      a0, 0x0014(sp)              // save registers

        // get portrait id
        li      t0, portrait_id_table       // t0 = portrait_id_table
        addu    t0, t0, a0                  // t0 = portrait_id_table + character id
        lbu     v0, 0x0000(t0)              // v0 = portrait_id for character in a0
        sw      v0, 0x0010(sp)              // store v0 in stack
        
        // get token location
        lli     t0, NUM_COLUMNS             // ~
        divu    v0, t0                      // ~
        mfhi    t1                          // t1 = portrait_id % NUM_COLUMNS = column
        lli     t0, PORTRAIT_WIDTH          // ~
        multu   t0, t1                      // ~
        mflo    t2                          // t2 = ulx
        addiu   t2, t2, START_X + 12        // t2 = (int) ulx + offset
        move    a0, t2                      // ~
        jal     OS.int_to_float_            // ~
        nop
        move    t2, v0                      // t2 = (float) ulx + offset
        sw      t2, 0x0058(t8)              // update token_xpos

        lw      v0, 0x0010(sp)              // restore v0 (portrait_id)
        lli     t0, NUM_COLUMNS             // ~
        divu    v0, t0                      // ~
        mflo    t1                          // t1 = portrait_id / NUM_COLUMS = row
        lli     t0, PORTRAIT_HEIGHT         // ~
        multu   t0, t1                      // ~
        mflo    t2                          // t2 = uly
        addiu   t2, t2, START_Y + 14        // t2 = (int) uly + offset
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
    // character id NONE on VS CSS
    OS.patch_start(0x00136D70, 0x80138AF0)
//  lli     at, r0, Character.id.NONE       // original line
    lli     at, 0x7FFF                      // at = really large unsigned value
    OS.patch_end()

    // @ Description
    // Bypasses CPU token being recalled when selecting a portrait with the
    // character id NONE on training CSS
    OS.patch_start(0x00145550, 0x80135F70)
//  lli     at, r0, Character.id.NONE       // original line
    lli     at, 0x7FFF                      // at = really large unsigned value
    OS.patch_end()

    // @ Description
    // removes white flash on vs character select
    OS.patch_start(0x134730, 0x801364B0)
    nop
    OS.patch_end()

    // @ Description
    // removes white flash on Training character select
    OS.patch_start(0x143670, 0x80134090)
    nop
    OS.patch_end()

    // @ Description
    // removes white flash on 1p character select
    //OS.patch_start(0x13770C, 0x8013948C)
    //nop
    //OS.patch_end()

    // @ Description
    // Expands the filetable to include more entries
    scope move_filetable_: {
        OS.patch_start(0x000499F8, 0x800CE018)
//      jr      ra                          // original line
//      sw      t6, 0x002C(v0)              // original line
        j       move_filetable_
        nop
        OS.patch_end()
        
        li      t3, 0x00000300              // t3 = hardcode filetable length
        sw      t3, 0x001C(v0)              // update filetable length
        li      t3, 0x80700000              // t3 = hardcoded filetable address
        sw      t3, 0x0020(v0)              // update filetable address

        jr      ra                          // original line
        sw      t6, 0x002C(v0)              // original line
    }

    // @ Description
    // allows for custom entries of name texture based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x11)
    // VS Mode
    scope get_name_texture_: {
        OS.patch_start(0x00130E18, 0x80132B98)
//      lw      t8, 0x0024(t8)                  // original line 1
        j       get_name_texture_
        lw      t5, 0xC4A0(t5)                  // original line 2
        _get_name_texture_return:
        OS.patch_end()
    
        li      t8, name_texture_table          // t8 = texture offset table
        addu    t8, t8, a2                      // t8 = address of texture offset
        lw      t8, 0x0000(t8)                  // t8 = texture offset
        j       _get_name_texture_return        // return
        nop
    }

    // @ Description
    // allows for custom entries of name texture based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x11)
    // Training Mode
    scope get_name_texture_training_: {
        OS.patch_start(0x00141D24, 0x80132744)
//      lw      t6, 0x001C(t6)                    // original line 1
        j       get_name_texture_training_
        lw      t8, 0x8C98(t8)                    // original line 2
        _get_name_texture_training_return:
        OS.patch_end()

        li      t6, name_texture_table            // t8 = texture offset table
        addu    t6, t6, a2                        // t8 = address of texture offset
        lw      t6, 0x0000(t6)                    // t8 = texture offset
        j       _get_name_texture_training_return // return
        nop
    }

    // @ Description
    // Allows for custom entries of series logo based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x14)
    // VS Mode
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
    // Allows for custom entries of series logo based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x14)
    // Training Mode
    scope get_series_logo_offset_training_: {
        OS.patch_start(0x00141C88, 0x801326A8)
//      addu    t5, sp, a2                  // original line (sp holds table, a2 holds char id * 4)
//      lw      t5, 0x004C(t5)              // original line (t5 = file offset of data)
        j       get_series_logo_offset_training_
        nop
        _get_series_logo_offset_training_return:
        OS.patch_end()

        li      t5, series_logo_offset_table
        addu    t5, t5, a2
        lw      t5, 0x0000(t5)
        j       _get_series_logo_offset_training_return
        nop
    }

    // @ Description
    // Disables token movement when token set down on vs css (migrates towards original spot)
    OS.patch_start(0x001376E0, 0x80139460)
    jr      ra
    nop
    OS.patch_end()

    // @ Description
    // Disables token movement when token set down on training css (migrates towards original spot)
    OS.patch_start(0x00145E68, 0x80136888)
    jr      ra
    nop
    OS.patch_end()

    // @ Description
    // Loads from white_circle_size_table instead of original table
    // @ Note
    // All values are 1.5 except DK. Possibly change this to static in the future
    scope get_zoom_: {
        OS.patch_start(0x00137E18, 0x80139B98)
//      addiu   a1, sp, 0x0004                  // original line 1
        j       get_zoom_                       // set table to custom table
        addiu   t6, t6, 0xB90C                  // original line 2
        _get_zoom_return:
        OS.patch_end()

        li      a1, white_circle_size_table     // set a1
        j       _get_zoom_return                // return
        nop
    }

    // @ Description
    // Loads from white_circle_size_table instead of original table
    // @ Note
    // All values are 1.5 except DK. Possibly change this to static in the future
    scope get_zoom_training_: {
        OS.patch_start(0x001465B0, 0x80136FD0)
//      addiu   a1, sp, 0x0004                  // original line 1
        j       get_zoom_training_              // set table to custom table
        addiu   t6, t6, 0x83FC                  // original line 2
        _get_zoom_training_return:
        OS.patch_end()

        li      a1, white_circle_size_table     // set a1
        j       _get_zoom_training_return       // return
        nop
    }
    
    // @ Description
    // Patch which loads character selected action from selection_action_table.
    // Originally a jump table was used here, but it's not necessary.
    scope get_action_: {
        // vs
        OS.patch_start(0x132B6C, 0x801348EC)
        j       get_action_
        nop
        OS.patch_end()

        // training
        OS.patch_start(0x142BFC, 0x8013361C)
        j       get_action_
        nop
        OS.patch_end()

        // a0 = character id
        sll     t6, a0, 0x2                 // t6 = character id * 4
        li      at, selection_action_table  // at = selection_action_table
        addu    at, at, t6                  // at = selection_action_table + (id * 4)
        lw      v0, 0x0000(at)              // v0 = selection_action for {character}
        jr      ra                          // return
        nop
    }
    
    // @ Description
    // Patch default costume subroutines to use Character.default_costume.table
    scope get_default_costume_: {
        constant UPPER(Character.default_costume.table >> 16)
        constant LOWER(Character.default_costume.table & 0xFFFF)
        // returns "c-button" costume ids
        OS.patch_start(0x678F4, 0x800EC0F4)
        if LOWER > 0x7FFF {
            lui     v0, (UPPER + 0x1)       // modified original line 1
        } else {
            lui     v0, UPPER               // modified original line 1
        }
        addu    v0, v0, t7                  // original line 2
        jr      ra                          // original line 3
        lbu     v0, LOWER(v0)               // modified original line 4    
        OS.patch_end()
        // returns team costume ids
        OS.patch_start(0x6790C, 0x800EC10C)
        if LOWER > 0x7FFF {
            lui     v0, (UPPER + 0x1)       // modified original line 1
        } else {
            lui     v0, UPPER               // modified original line 1
        }
        addu    v0, v0, t7                  // original line 2
        jr      ra                          // original line 3
        lbu     v0, LOWER+4(v0)             // modified original line 4   
        OS.patch_end()
        // returns unknown costume id (byte after green team id)
        // TODO: figure out what this costume id is for (low priority)
        OS.patch_start(0x67920, 0x800EC120)
        if LOWER > 0x7FFF {
            lui     v0, (UPPER + 0x1)       // modified original line 1
        } else {
            lui     v0, UPPER               // modified original line 1
        }
        addu    v0, v0, t6                  // original line 2
        jr      ra                          // original line 3
        lbu     v0, LOWER+7(v0)             // modified original line 4  
        OS.patch_end()
    }

    // @ Description
    // This is the hook for loading more characters. Located directly after the initial characters.
    scope load_additional_characters_: {
        // VS
        OS.patch_start(0x00139458, 0x8013B1D8)
        lli     s8, 0x0000                  // 0 for VS
        j       load_additional_characters_
        nop
        _return:
        OS.patch_end()
        // Training
        OS.patch_start(0x00147394, 0x80137DB4)
        lli     s8, 0x0001                  // 1 for Training
        j       load_additional_characters_
        nop
        _return_training:
        OS.patch_end()
        // 1P
        //OS.patch_start(0x00157E14, 0x8013B1D8)
        //lli     s8, 0x0002                  // 2 for 1P
        //j       load_additional_characters_
        //nop
        //_return_1p:
        //OS.patch_end()

        // for (char_id i = FALCO; i < DSAMUS; i++)
        lli     s0, Character.id.FALCO      // s0 = index (and start character, usually skips polygons)
        
        _loop:
        jal     load_character_model_       // load character function
        or      a0, s0, r0                  // a0 = index
        // end on x character (Character.NUM_CHARACTERS - 1 should work usually)
        slti    at, s0, Character.NUM_CHARACTERS - 1
        bnez    at, _loop
        addiu   s0, s0, 0x0001              // increment index
        lui     v1, 0x8014                  // original line 1
        lui     s0, 0x8013                  // original line 2
        addiu   s0, s0, 0x0D9C              // original line 3
        beqz    s8, _vs                     // if (a1 = 1) then return to VS code
        nop
        j       _return_training
        nop

        _vs:
        j       _return
        nop
    }


    // @ Description
    // Changes the loads from fgm_table instead of the original function table
    // Also sets the selection flash timer
    scope get_fgm_: {
        // vs
        OS.patch_start(0x00134B10, 0x80136890)
//      sll     t5, t4, 0x0001              // original line 1
//      addu    a0, sp, t5                  // original line 2
        jal     get_fgm_
        nop
        OS.patch_end()
        OS.patch_start(0x00134B1C, 0x8013689C)
//      lw      a0, 0x0020(a0)              // original line
        nop
        OS.patch_end()
        
        // training
        OS.patch_start(0x14385C, 0x8013427C)
//      sll     t6, t5, 0x0001              // original line 1
//      addu    a0, sp, t6                  // original line 2
        jal     get_fgm_
        addu    t4, t5, r0
        OS.patch_end()
        OS.patch_start(0x143868, 0x80134288)
//      lw      a0, 0x0028(a0)              // original line
        nop
        OS.patch_end()

        lli     t5, FLASH_TIME              // t5 = FLASH_TIME
        li      a0, flash_table             // a0 = flash_table
        addu    a0, a0, t4                  // a0 = flash_table + character id
        sb      t5, 0x0000(a0)              // store FLASH_TIME
        li      a0, fgm_table               // a0 = fgm_table 
        sll     t5, t4, 0x0001              // ~
        addu    a0, a0, t5                  // a0 = fgm_table + char offset
        lhu     a0, 0x0000(a0)              // a0 = fgm id
        jr      ra                          // return
        nop       
    }

    // @ Description
    // Struct for portrait textures
    portrait_info:;     Texture.info(PORTRAIT_WIDTH_FILE, PORTRAIT_HEIGHT_FILE)

    // @ Description
    // New table for sound fx (for each character)
    fgm_table:
    constant fgm_table_origin(origin())
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
    dh FGM.announcer.names.METAL_MARIO     // Metal Mario
    dh FGM.announcer.names.MARIO           // Polygon Mario
    dh FGM.announcer.names.FOX             // Polygon Fox
    dh FGM.announcer.names.DONKEY_KONG     // Polygon Donkey Kong
    dh FGM.announcer.names.SAMUS           // Polygon Samus
    dh FGM.announcer.names.LUIGI           // Polygon Luigi
    dh FGM.announcer.names.LINK            // Polygon Link
    dh FGM.announcer.names.YOSHI           // Polygon Yoshi
    dh FGM.announcer.names.CAPTAIN_FALCON  // Polygon Captain Falcon
    dh FGM.announcer.names.KIRBY           // Polygon Kirby
    dh FGM.announcer.names.PIKACHU         // Polygon Pikachu
    dh FGM.announcer.names.JIGGLYPUFF      // Polygon Jigglypuff
    dh FGM.announcer.names.NESS            // Polygon Ness
    dh FGM.announcer.names.GDK             // Giant Donkey Kong
    dh FGM.announcer.names.MARIO           // (Placeholder)
    dh FGM.announcer.names.MARIO           // None (Placeholder)

    // add space for new characters
    fill (fgm_table + (Character.NUM_CHARACTERS * 0x2)) - pc()
    OS.align(4)

    white_circle_size_table:
    constant white_circle_size_table_origin(origin())
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
    // add space for new characters
    fill (white_circle_size_table + (Character.NUM_CHARACTERS * 0x4)) - pc()
    
    // @ Description
    // New table for selection action
    selection_action_table:
    constant selection_action_table_origin(origin())
    dw 0x00010003                           // Mario
    dw 0x00010004                           // Fox
    dw 0x00010001                           // Donkey Kong
    dw 0x00010004                           // Samus
    dw 0x00010001                           // Luigi
    dw 0x00010001                           // Link
    dw 0x00010002                           // Yoshi
    dw 0x00010001                           // Captain Falcon
    dw 0x00010003                           // Kirby
    dw 0x00010001                           // Pikachu
    dw 0x00010002                           // Jigglypuff
    dw 0x00010002                           // Ness
    dw 0x00010001                           // Master Hand
    dw 0x00010001                           // Metal Mario
    dw 0x00010001                           // Polygon Mario
    dw 0x00010001                           // Polygon Fox
    dw 0x00010001                           // Polygon Donkey Kong
    dw 0x00010001                           // Polygon Samus
    dw 0x00010001                           // Polygon Luigi
    dw 0x00010001                           // Polygon Link
    dw 0x00010001                           // Polygon Yoshi
    dw 0x00010001                           // Polygon Captain Falcon
    dw 0x00010001                           // Polygon Kirby
    dw 0x00010001                           // Polygon Pikachu
    dw 0x00010001                           // Polygon Jigglypuff
    dw 0x00010001                           // Polygon Ness
    dw 0x00010001                           // Giant Donkey Kong
    dw 0x00010001                           // (Placeholder)
    dw 0x00010001                           // None (Placeholder)
    // add space for new characters
    fill (selection_action_table + (Character.NUM_CHARACTERS * 0x4)) - pc()
    
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
    constant series_logo_offset_table_origin(origin())
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
    // add space for new characters
    fill (series_logo_offset_table + (Character.NUM_CHARACTERS * 0x4)) - pc()
    
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
        constant GND(0x00011AA8)
        constant FALCO(0x00011F88)
        constant YLINK(0x00012468)
        constant DRM(0x00012948)
        constant DSAMUS(0x00002358)
        constant BLANK(0x0)
    }

    name_texture_table:
    constant name_texture_table_origin(origin())
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
    dw name_texture.BLANK                   // Master Hand
    dw name_texture.BLANK                   // Metal Mario
    dw name_texture.BLANK                   // Polygon Mario
    dw name_texture.BLANK                   // Polygon Fox
    dw name_texture.BLANK                   // Polygon Donkey Kong
    dw name_texture.BLANK                   // Polygon Samus
    dw name_texture.BLANK                   // Polygon Luigi
    dw name_texture.BLANK                   // Polygon Link
    dw name_texture.BLANK                   // Polygon Yoshi
    dw name_texture.BLANK                   // Polygon Captain Falcon
    dw name_texture.BLANK                   // Polygon Kirby
    dw name_texture.BLANK                   // Polygon Pikachu
    dw name_texture.BLANK                   // Polygon Jigglypuff
    dw name_texture.BLANK                   // Polygon Ness
    dw name_texture.BLANK                   // Giant Donkey Kong
    dw name_texture.BLANK                   // (Placeholder)
    dw name_texture.BLANK                   // None (Placeholder)
    // add space for new characters
    fill (name_texture_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    constant START_X(30)
    constant START_Y(25)
    constant START_VISUAL(10)
    constant NUM_ROWS(3)
    constant NUM_COLUMNS(8)
    constant NUM_PORTRAITS(NUM_ROWS * NUM_COLUMNS)
    constant PORTRAIT_WIDTH_FILE(32)
    constant PORTRAIT_HEIGHT_FILE(32)
    constant PORTRAIT_WIDTH(30)
    constant PORTRAIT_HEIGHT(30)


    // @ Description
    // CHARACTER SELECT SCREEN LAYOUT
    constant NUM_SLOTS(24)
    scope layout {
        // row 1
        define slot_1(DRM)
        define slot_2(LUIGI)
        define slot_3(MARIO)
        define slot_4(DONKEY)
        define slot_5(LINK)
        define slot_6(SAMUS)
        define slot_7(CAPTAIN)
        define slot_8(GND)
        // row 2
        define slot_9(YLINK)
        define slot_10(NESS)
        define slot_11(YOSHI)
        define slot_12(KIRBY)
        define slot_13(FOX)
        define slot_14(PIKACHU)
        define slot_15(JIGGLYPUFF)
        define slot_16(FALCO)
        // row 3
        define slot_17(DSAMUS)
        define slot_18(NONE)
        define slot_19(NONE)
        define slot_20(NONE)
        define slot_21(NONE)
        define slot_22(NONE)
        define slot_23(NONE)
        define slot_24(NONE)
    }
    
    
    // @ Description
    // CSS characters in order of portrait ID
    id_table:
    evaluate n(0)
    while NUM_SLOTS > {n} {
        evaluate n({n} + 1)
        db Character.id.{layout.slot_{n}}
    }
    OS.align(4)
    
    // @ Description
    // CSS portraits IDs in order of character ID
    portrait_id_table:
    constant portrait_id_table_origin(origin())
    // fill table with empty slots
    fill Character.NUM_CHARACTERS
    OS.align(4)
    pushvar origin, base
    evaluate n(0)
    while NUM_SLOTS > {n} {
        evaluate n({n} + 1)
        origin portrait_id_table_origin + Character.id.{layout.slot_{n}}
        db {n} - 1
    }
    pullvar base, origin
    
    // @ Description
    // used for storing white flash timer
    flash_table:
    constant FLASH_TIME(0xF)
    fill Character.NUM_CHARACTERS
    OS.align(4)
    
    // @ Description
    // Texture inserts for portraits
    insert portrait_donkey_kong,         "../textures/portrait_donkey_kong.rgba5551"
    insert portrait_falcon,              "../textures/portrait_falcon.rgba5551"
    insert portrait_fox,                 "../textures/portrait_fox.rgba5551"
    insert portrait_jigglypuff,          "../textures/portrait_jigglypuff.rgba5551"
    insert portrait_kirby,               "../textures/portrait_kirby.rgba5551"
    insert portrait_link,                "../textures/portrait_link.rgba5551"
    insert portrait_luigi,               "../textures/portrait_luigi.rgba5551"
    insert portrait_mario,               "../textures/portrait_mario.rgba5551"
    insert portrait_ness,                "../textures/portrait_ness.rgba5551"
    insert portrait_pikachu,             "../textures/portrait_pikachu.rgba5551"
    insert portrait_samus,               "../textures/portrait_samus.rgba5551"
    insert portrait_yoshi,               "../textures/portrait_yoshi.rgba5551"
    insert portrait_donkey_kong_flash,   "../textures/portrait_donkey_kong_flash.rgba5551"
    insert portrait_falcon_flash,        "../textures/portrait_falcon_flash.rgba5551"
    insert portrait_fox_flash,           "../textures/portrait_fox_flash.rgba5551"
    insert portrait_jigglypuff_flash,    "../textures/portrait_jigglypuff_flash.rgba5551"
    insert portrait_kirby_flash,         "../textures/portrait_kirby_flash.rgba5551"
    insert portrait_link_flash,          "../textures/portrait_link_flash.rgba5551"
    insert portrait_luigi_flash,         "../textures/portrait_luigi_flash.rgba5551"
    insert portrait_mario_flash,         "../textures/portrait_mario_flash.rgba5551"
    insert portrait_ness_flash,          "../textures/portrait_ness_flash.rgba5551"
    insert portrait_pikachu_flash,       "../textures/portrait_pikachu_flash.rgba5551"
    insert portrait_samus_flash,         "../textures/portrait_samus_flash.rgba5551"
    insert portrait_yoshi_flash,         "../textures/portrait_yoshi_flash.rgba5551"
    // allow add_portrait to use portrait_unknown
    define __portrait_unknown__()
    insert portrait_unknown,        "../textures/portrait_unknown.rgba5551"

    portrait_table:
    constant portrait_table_origin(origin())
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
    dw portrait_unknown                 // Masterhand
    dw portrait_unknown                 // Metal Mario
    dw portrait_unknown                 // Polygon Mario
    dw portrait_unknown                 // Polygon Fox
    dw portrait_unknown                 // Polygon Donkey Kong
    dw portrait_unknown                 // Polygon Samus
    dw portrait_unknown                 // Polygon Luigi
    dw portrait_unknown                 // Polygon Link
    dw portrait_unknown                 // Polygon Yoshi
    dw portrait_unknown                 // Polygon Captain Falcon
    dw portrait_unknown                 // Polygon Kirby
    dw portrait_unknown                 // Polygon Pikachu
    dw portrait_unknown                 // Polygon Jigglypuff
    dw portrait_unknown                 // Polygon Ness
    dw portrait_unknown                 // Giant Donkey Kong
    dw portrait_unknown                 // (Placeholder)
    dw portrait_unknown                 // None (Placeholder)
    // add space for new characters
    fill (portrait_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    portrait_flash_table:
    constant portrait_flash_table_origin(origin())
    dw portrait_mario_flash             // Mario
    dw portrait_fox_flash               // Fox
    dw portrait_donkey_kong_flash       // Donkey Kong
    dw portrait_samus_flash             // Samus
    dw portrait_luigi_flash             // Luigi
    dw portrait_link_flash              // Link
    dw portrait_yoshi_flash             // Yoshi
    dw portrait_falcon_flash            // Captain Falcon
    dw portrait_kirby_flash             // Kirby
    dw portrait_pikachu_flash           // Pikachu
    dw portrait_jigglypuff_flash        // Jigglypuff
    dw portrait_ness_flash              // Ness
    dw portrait_unknown                 // Masterhand
    dw portrait_unknown                 // Metal Mario
    dw portrait_unknown                 // Polygon Mario
    dw portrait_unknown                 // Polygon Fox
    dw portrait_unknown                 // Polygon Donkey Kong
    dw portrait_unknown                 // Polygon Samus
    dw portrait_unknown                 // Polygon Luigi
    dw portrait_unknown                 // Polygon Link
    dw portrait_unknown                 // Polygon Yoshi
    dw portrait_unknown                 // Polygon Captain Falcon
    dw portrait_unknown                 // Polygon Kirby
    dw portrait_unknown                 // Polygon Pikachu
    dw portrait_unknown                 // Polygon Jigglypuff
    dw portrait_unknown                 // Polygon Ness
    dw portrait_unknown                 // Giant Donkey Kong
    dw portrait_unknown                 // (Placeholder)
    dw portrait_unknown                 // None (Placeholder)
    // add space for new characters
    fill (portrait_flash_table + (Character.NUM_CHARACTERS * 0x4)) - pc()
    
    // @ Description
    // Adds a portrait for a character.
    // @ Arguments
    // character - character id to add a portrait for
    // portrait - portrait file name (.rgba5551 file in ../textures/)
    macro add_portrait(character, portrait) {
        if !{defined __{portrait}__} {
            define __{portrait}__()
            insert {portrait}, "../textures/{portrait}.rgba5551"
            insert {portrait}_flash, "../textures/{portrait}_flash.rgba5551"
        }
        
        pushvar origin, base
        origin portrait_table_origin + ({character} * 0x4)
        dw  {portrait}
        origin portrait_flash_table_origin + ({character} * 0x4)
        dw  {portrait}_flash
        pullvar base, origin
    }
    
    // @ Description
    // Adds a character to the character select screen.
    // @ Arguments
    // character - character id to add a portrait for
    // fgm - fgm id for announcer voice
    // circle_size - float32 size of white circle underneath character
    // action - action id (format 0x000100??) for menu action
    // logo - series logo to use
    // name_texture - name texture to use
    // portrait - portrait file name (.rgba5551 file in ../textures/)
    macro add_to_css(character, fgm, circle_size, action, logo, name_texture, portrait) {
        pushvar origin, base
        // add to fgm table
        origin fgm_table_origin + ({character} * 2)
        dh  {fgm}
        // add to white circle table
        origin white_circle_size_table_origin + ({character} * 4)
        float32 {circle_size}
        // add to selection action table
        origin selection_action_table_origin + ({character} * 4)
        dw  {action}
        // add to series logo offset table
        origin series_logo_offset_table_origin + ({character} * 4)
        dw  {logo}
        // add to name texture table
        origin name_texture_table_origin + ({character} * 4)
        dw  {name_texture}
        pullvar base, origin

        // add portrait
        add_portrait({character}, {portrait})
    }
    
    
    // ADD CHARACTERS
    add_to_css(Character.id.FALCO, FGM.announcer.names.FALCO, 1.50, 0x00010004, series_logo.STARFOX, name_texture.FALCO, portrait_falco)
    add_to_css(Character.id.GND, FGM.announcer.names.GANONDORF, 1.50, 0x00010002, series_logo.ZELDA, name_texture.GND, portrait_ganondorf)
    add_to_css(Character.id.YLINK, FGM.announcer.names.YOUNG_LINK, 1.50, 0x00010002, series_logo.ZELDA, name_texture.YLINK, portrait_young_link)
    add_to_css(Character.id.DRM, FGM.announcer.names.DR_MARIO, 1.50, 0x00010001, series_logo.MARIO_BROS, name_texture.DRM, portrait_dr_mario)
    add_to_css(Character.id.WARIO, FGM.announcer.names.WARIO, 1.50, 0x00010003, series_logo.MARIO_BROS, name_texture.BLANK, portrait_wario)
    add_to_css(Character.id.DSAMUS, FGM.announcer.names.DSAMUS, 1.50, 0x00010004, series_logo.METROID, name_texture.DSAMUS, portrait_dark_samus)
    
}

} // __CHARACTER_SELECT__
