// Character.asm
if !{defined __CHARACTER_SELECT__} {
define __CHARACTER_SELECT__()
print "included CharacterSelect.asm\n"

// @ Description
// This file contains modifications to the Character Select screen

include "Global.asm"
include "OS.asm"
include "RCP.asm"
include "Texture.asm"

scope CharacterSelect {

    // hands
    insert hand_pointing,       "../textures/hand_pointing.rgba5551"
    insert hand_holding,        "../textures/hand_holding.rgba5551"
    insert hand_open,           "../textures/hand_open.rgba5551"

    constant HAND_WIDTH(32)
    constant HAND_HEIGHT(32)

    // chips
    insert chip_1,              "../textures/chip_1.rgba5551"
    insert chip_2,              "../textures/chip_2.rgba5551"
    insert chip_3,              "../textures/chip_3.rgba5551"
    insert chip_4,              "../textures/chip_4.rgba5551"
    insert chip_C,              "../textures/chip_C.rgba5551"

    constant CHIP_WIDTH(32)
    constant CHIP_HEIGHT(32)

    // portrait
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
    dw portait_mario                   // Mario
    dw portait_fox                     // Fox
    dw portait_donkey_kong             // Donkey Kong
    dw portait_samus                   // Samus
    dw portait_luigi                   // Luigi
    dw portait_link                    // Link
    dw portait_yoshi                   // Yoshi
    dw portait_falcon                  // Captain Falcon
    dw portait_kirby                   // Kirby
    dw portait_pikachu                 // Pikachu
    dw portait_jigglypuff              // Jigglypuff
    dw portait_ness                    // Ness
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario
    dw portait_mario                   // Mario



    constant START_X(22)
    constant START_Y(22)
    constant START_VISUAL(10)
    constant NUM_ROWS(3)
    constant NUM_COLUMNS(8)
    constant NUM_TILES(NUM_ROWS * NUM_COLUMNS)
    constant PORTRAIT_SIZE(32)

    // @ Description
    // this function returns what character is selected by the tokens position
    // this is purely based on token position, not hand position
    // @ Returns
    // v0 - character id
    // 8013782C

    scope get_character_id_: {
        OS.patch_start(0x000135AEC, 0x8013786C)
        j       get_character_id_
        nop
        OS.patch_end()

        // make sure chip is down
            // if chip not down, return no character 0x1C
            // if chip down, return char id based on position
        
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
        lli     t0, PORTRAIT_SIZE   // t0 = PORTRAIT_SIZE
        divu    a1, t0              // ~
        mflo    t1                  // t1 = x index
        divu    v1, t0              // ~
        mflo    t2                  // t2 = y index

        // multi dimmensional array math
        // index = (row * NUM_COLUMNS) + column
        lli     t0, NUM_COLUMNS     // ~
        multu   t0, t2              // ~
        mflo    t0                  // t0 = (row * NUM_COLUMNS)
        addu    t0, t0, t1          // t0 = index

        // return id.NONE if index is too large for table
        lli     t1, NUM_TILES       // t1 = num tiles
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

    id_table:
    // default
    // row 1
    db Character.id.LUIGI
    db Character.id.MARIO
    db Character.id.DONKEY_KONG
    db Character.id.LINK
    db Character.id.SAMUS
    db Character.id.CAPTAIN_FALCON

    db Character.id.MARIO
    db Character.id.MARIO

    // row 2
    db Character.id.NESS
    db Character.id.YOSHI
    db Character.id.KIRBY
    db Character.id.FOX
    db Character.id.PIKACHU
    db Character.id.JIGGLYPUFF

    db Character.id.MARIO
    db Character.id.MARIO


    // row 3
    db Character.id.MARIO
    db Character.id.MARIO
    db Character.id.MARIO
    db Character.id.MARIO
    db Character.id.MARIO
    db Character.id.MARIO


    OS.align(4)


    display_list_info:
    RCP.display_list_info(OS.NULL, 0)

    // later revision
    scope run_: {

        // disable drawing of tiles
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
        beqz    t0, _cursor                 // once every row complete, draw cursor
        nop
        addiu   t0, t0,-0x0001              // decrement outer loop

        
        lli     t1, NUM_COLUMNS             // init columns
        _inner_loop:
        beqz    t1, _outer_loop             // once every column in row drawn, draw next row
        nop
        addiu   t1, t1,-0x0001              // decrement inner loop


        // calculate ulx/uly offset
        lli     a2, PORTRAIT_SIZE
        multu   a2, t1                      // ~
        mflo    t3                          // t3 = ulx offset
        multu   a2, t0                      // ~
        mflo    t4                          // t4 = uly offset

        // add to ulx/uly
        lli     a0, START_X + START_VISUAL  // ~
        addu    a0, a0, t3                  // a0 - ulx
        lli     a1, START_Y + START_VISUAL  // ~
        addu    a1, a1, t4                  // a1 - uly

        // get the character portrait to draw


        // draw character portrait
        lli     t2, NUM_COLUMNS             // ~
        multu   t0, t2                      // ~
        mflo    t2                          // ~
        addu    t2, t2, t1                  // ~
        li      t3, id_table                // ~
        addu    t3, t3, t2                  // t3 = (id_table + ((y * NUM_COLUMNS) + x))
        lbu     t3, 0x0000(t3)              // t3 = id of character to draw
        sll     t3, t3, 0x0002              // t3 = id * 4
        li      t4, portrait_table          // t4 = portrait_table
        addu    t4, t4, t3                  // t4 = portrait_table[id]
        lw      t4, 0x0000(t4)              // t4 = address of texture
        li      a2, portrait_info            // a2 - address of texture struct
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
        lw      t2, 0x0000(t1)              // t2 = cursor
        lw      a0, 0x0170(t2)              // a0 = (float) p2 cursor x
        jal     OS.float_to_int_            // v0 = (int) p2 cursor x
        nop
        or      v1, v0, r0                  // v1 = (int) p2 cursor x
        lw      a0, 0x0174(t2)              // a0 = (float) p2 cursor y
        jal     OS.float_to_int_            // v0 = (int) p2 cursor y
        nop

        or      a0, v1, r0                  // a0 - ulx 
        or      a1, v0, r0                  // a1 - uly
        lw      t2, 0x0054(t1)              // t2 = cursor state
        lli     t3, 0x0001                  // t1 = HOLDING_TOKEN
        bne     t2, t3, _draw_cursor        // if not holding, skip
        nop
        addiu   a0, a0,-000011
        addiu   a1, a1,-000011


        _draw_cursor:
        sll     t2, t2, 0x0002              // t1 = cursor_state * 4
        li      t3, hand_textures           // ~
        addu    t3, t3, t2                  // ~
        lw      t3, 0x0000(t3)              // t3 = address of hand texture
        li      a2, hand_info               // a2 - address of texture struct
        sw      t3, 0x00008(a2)             // update info image data
        jal     Overlay.draw_texture_       // draw cursor
        nop


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
        li      t3, chip_textures           // ~
        addu    t3, t3, t2                  // ~
        lw      t3, 0x0000(t3)              // t3 = address of hand texture
        li      a2, chip_info               // a2 - address of texture struct
        sw      t3, 0x00008(a2)             // update info image data
        jal     Overlay.draw_texture_       // draw chip
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

        player_data:
        dw 0x8013BA88
        dw 0x8013BB44
        dw 0x8013BC00
        dw 0x8013BCBC

        hand_textures:
        dw hand_pointing
        dw hand_holding
        dw hand_open

        chip_textures:
        dw chip_1
        dw chip_2
        dw chip_3
        dw chip_4

        hand_info:
        Texture.info(HAND_WIDTH, HAND_HEIGHT)

        portrait_info:
        Texture.info(PORTRAIT_SIZE, PORTRAIT_SIZE)

        chip_info:
        Texture.info(CHIP_WIDTH, CHIP_HEIGHT)
    }

    // TODO

    // 1. why is gdk crashing
    // 2. animations for additonal characters 
    // 6. get rid of white flash

    // @ Description
    // 1. memory solution 
    scope move_filetable_: {
        OS.patch_start(0x000499F8, 0x800CE018)
//      jr      ra                          // original line
//      sw      t6, 0x002C(v0)              // original line
        j       move_filetable_
        nop
        OS.patch_end()
        
        li      t3, 0x00000100              // t3 = hardcode filetable length
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

    // logo offsets in file 0x14
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
        constant YUH(0x0)
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
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH
    dw name_texture.YUH




    // @ Description
    // allows for custom entries of series logo based on file offset (+0x10 for DF000000 00000000)
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
    // logo offsets in file 0x14
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
    dw series_logo.SMASH                    // Master Hand
    dw series_logo.MARIO_BROS               // Metal Mario
    dw series_logo.SMASH                    // Polygon Mario
    dw series_logo.SMASH                    // Polygon Fox
    dw series_logo.SMASH                    // Polygon Donkey Kong
    dw series_logo.SMASH                    // Polygon Samus
    dw series_logo.SMASH                    // Polygon Luigi
    dw series_logo.SMASH                    // Polygon Link
    dw series_logo.SMASH                    // Polygon Yoshi
    dw series_logo.SMASH                    // Polygon Captain Falcon
    dw series_logo.SMASH                    // Polygon Kirby
    dw series_logo.SMASH                    // Polygon Pikachu
    dw series_logo.SMASH                    // Polygon Jigglypuff
    dw series_logo.SMASH                    // Polygon Ness
    dw series_logo.DONKEY_KONG              // Giant Donkey Kong
    dw 0x00000000                           // (Placeholder)
    dw 0x00000000                           // None (Placeholder)

    // @ Description
    // Disables chip movement when chip set down
    OS.patch_start(0x001376E0, 0x80139460)
    jr      ra
    nop
    OS.patch_end()


    // controls whether or not white circle written 
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

    // this line controls how many chars are loaded on the VS. CSS
    OS.patch_start(0x0013944C, 0x8013B1CC)
    slti    at, s0, Character.id.GDONKEY + 1
    OS.patch_end()

    // this is the call to play_fgm_ for announcing chars
    // 8013689C
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
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0
    dh 0

    // this loads the zoom table for each character so they all appear the same
    // size. this table has been moved and extended [Fray]
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

}

} // __CHARACTER_SELECT__