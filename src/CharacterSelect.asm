// Character.asm
if !{defined __CHARACTER_SELECT__} {
define __CHARACTER_SELECT__()
print "included CharacterSelect.asm\n"

// @ Description
// This file contains modifications to the Character Select screen

// TODO:
// - Names for variants (improve quality)

include "Global.asm"
include "OS.asm"

scope CharacterSelect {
    constant CSS_PLAYER_STRUCT(0x8013BA88)
    constant CSS_PLAYER_STRUCT_TRAINING(0x80138558)
    constant CSS_PLAYER_STRUCT_1P(0x80138EC0)
    constant CSS_PLAYER_STRUCT_BONUS(0x80137620)

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
        li      t8, alt_req_list            // t8 = alt_req_list address
        sw      r0, 0x0000(t8)              // destroy alt_req_list pointer
        li      t8, alt_malloc_size         // t8 = alt_malloc_size address
        sw      r0, 0x0000(t8)              // destroy alt_malloc_size
        lw      ra, 0x0008(sp)              // load ra
        jr      ra                          // return
        addiu   sp, sp, 0x0010              // deallocate stack space
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
    OS.patch_start(0x14061C, 0x8013841C)
    jal     load_character_model_
    OS.patch_end()

    // @ Description
    // Patch BTT/BTP mode character select loading routine to use load_character_model_
    OS.patch_start(0x14CDF0, 0x80136DC0)
    jal     load_character_model_
    OS.patch_end()

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
        j       _return                     // return
        or      a1, s0, r0                  // original line 2
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
    dw  0xD800                              // 0x02 - DONKEY (req list also includes the file with stock icons, but size of that file not accounted for here)
    dw  0xE750                              // 0x03 - SAMUS
    dw  0x8110                              // 0x04 - LUIGI
    dw  0x12170                             // 0x05 - LINK
    dw  0xAEE0                              // 0x06 - YOSHI
    dw  0xCA90                              // 0x07 - CAPTAIN
    dw  0x1D8C0 + 0xC18 + 0x740 + 0xB50 + 0x400 + 0x255D0  // 0x08 - KIRBY
    dw  0x9E30                              // 0x09 - PIKACHU
    dw  0x7FE0                              // 0x0A - JIGGLY
    dw  0xC5C0                              // 0x0B - NESS
    dw  0                                   // 0x0C - BOSS
    dw  0x36D4                              // 0x0D - METAL
    dw  0x41B0                              // 0x0E - NMARIO (file 0x012D)
    dw  0x4304                              // 0x0F - NFOX (file 0x012F)
    dw  0x4120                              // 0x10 - NDONKEY
    dw  0x5AF0                              // 0x11 - NSAMUS (file 0x0135)
    dw  0x41B0                              // 0x12 - NLUIGI (file 0x012D - same as Mario)
    dw  0x4640                              // 0x13 - NLINK
    dw  0x4860                              // 0x14 - NYOSHI
    dw  0x4190                              // 0x15 - NCAPTAIN (file 0x0137)
    dw  0x3724                              // 0x16 - NKIRBY (file 0x0131)
    dw  0x434C                              // 0x17 - NPIKACHU (file 0x0133)
    dw  0x3590                              // 0x18 - NJIGGLY (file 0x0132)
    dw  0x4684                              // 0x19 - NNESS (file 0x0138)
    dw  0xD800                              // 0x1A - GDONKEY (file 0x013D - sams as DK)
    dw  0                                   // 0x1B - PLACEHOLDER
    dw  0                                   // 0x1C - PLACEHOLDER
    dw  0x7AE0 + 0x200                      // 0x1D - FALCO
    dw  0x1A6D8 + 0x200                     // 0x1E - GND
    dw  0x186D0 + 0x200                     // 0x1F - YLINK
    dw  0xAED0 + 0x200                      // 0x20 - DRM
    dw  0xC440 + 0x200                      // 0x21 - WARIO
    dw  0xE708 + 0x200                      // 0x22 - DARK SAMUS
    dw  0x0                                 // 0x23 - ELINK
    dw  0x0                                 // 0x24 - JSAMUS
    dw  0x0                                 // 0x25 - JNESS
    dw  0x10580 + 0x200                     // 0x26 - LUCAS
    dw  0x12170                             // 0x27 - JLINK
    dw  0x0                                 // 0x28 - JFALCON
    dw  0x0                                 // 0x29 - JFOX
    dw  0x772C                              // 0x2A - JMARIO
    dw  0x8110                              // 0x2B - JLUIGI
    dw  0x0                                 // 0x2C - JDK
    dw  0x0                                 // 0x2D - EPIKA
    dw  0x0                                 // 0x2E - JPUFF
    dw  0x0                                 // 0x2F - EPUFF
    dw  0x0                                 // 0x30 - JKIRBY
    dw  0x0                                 // 0x31 - JYOSHI
    dw  0x0                                 // 0x32 - JPIKA
    dw  0x0                                 // 0x33 - ESAMUS
	dw  0x1B778 + 0x200                     // 0x34 - BOWSER
	dw  0xFA38 + 0x200                      // 0x35 - GBOWSER
    dw  0x4DB0 + 0x200                      // 0x36 - PIANO
    dw  0x76A0 + 0x200                      // 0x37 - WOLF
    dw  0x110F0 + 0x200                     // 0x38 - CONKER
    dw  0x19080 + 0x200                     // 0x39 - MEWTWO
    dw  0x15200 + 0x200                     // 0x3A - MARTH
    dw  0x16320 + 0x22260 + 0x170E8 + 0x200 // 0x3B - SONIC
    dw  0x49F8 + 0x200                      // 0x3C - SANDBAG
    dw  0xC900 + 0x200                      // 0x3D - SUPER SONIC
    dw  0x13C60 + 0x200                     // 0x3E - SHEIK
    dw  0x136E8 + 0x200                     // 0x3F - MARINA
    dw  0x173C8 + 0x200                     // 0x40 - DEDEDE
    // ADD NEW CHARACTERS HERE

    // REMIX POLYGONS
    dw  0x4550 + 0x200                      // NWARIO
    dw  0x4810 + 0x200                      // NLUCAS
    dw  0x4268 + 0x200                      // NBOWSER
    dw  0x38C8 + 0x200                      // NWOLF
    dw  0x41B0                              // NDRM
    dw  0x4BC0 + 0x200                      // NSONIC
    dw  0x3F78 + 0x200                      // NSHEIK
    dw  0x35A0 + 0x200                      // NMARINA

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
    // TODO: reuse pointers if the file has already been added and don't add the file again
    variable alt_req_list_count(0)
    macro add_alt_req_list(character, filename) {
        global variable alt_req_list_count(alt_req_list_count + 1)
        evaluate num(alt_req_list_count)

        pushvar origin, base

        // Insert new req list in ROM
        // TODO: Really should rename this variable to something more descriptive - it is used to track the end of used ROM space
        origin MIDI.MIDI_BANK_END
        constant ALT_REQ_{num}(origin())
        insert "../src/{filename}.req"
        OS.align(4)
        MIDI.MIDI_BANK_END = origin()

        // Add new req list to alt_req_table
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
    add_alt_req_list(Character.id.METAL, req/METAL_MODEL)
    add_alt_req_list(Character.id.NMARIO, req/NMARIO_MODEL)
    add_alt_req_list(Character.id.NFOX, req/NFOX_MODEL)
    add_alt_req_list(Character.id.NDONKEY, req/NDONKEY_MODEL)
    add_alt_req_list(Character.id.NSAMUS, req/NSAMUS_MODEL)
    add_alt_req_list(Character.id.NLUIGI, req/NLUIGI_MODEL)
    add_alt_req_list(Character.id.NLINK, req/NLINK_MODEL)
    add_alt_req_list(Character.id.NYOSHI, req/NYOSHI_MODEL)
    add_alt_req_list(Character.id.NCAPTAIN, req/NCAPTAIN_MODEL)
    add_alt_req_list(Character.id.NKIRBY, req/NKIRBY_MODEL)
    add_alt_req_list(Character.id.NPIKACHU, req/NPIKACHU_MODEL)
    add_alt_req_list(Character.id.NJIGGLY, req/NJIGGLY_MODEL)
    add_alt_req_list(Character.id.NNESS, req/NNESS_MODEL)
    add_alt_req_list(Character.id.GDONKEY, req/GDONKEY_MODEL)
    add_alt_req_list(Character.id.FALCO, req/FALCO_MODEL)
    add_alt_req_list(Character.id.GND, req/GND_MODEL)
    add_alt_req_list(Character.id.YLINK, req/YLINK_MODEL)
    add_alt_req_list(Character.id.DRM, req/DRM_MODEL)
    add_alt_req_list(Character.id.WARIO, req/WARIO_MODEL)
    add_alt_req_list(Character.id.DSAMUS, req/DSAMUS_MODEL)
    add_alt_req_list(Character.id.ELINK, req/LINK_MODEL)
    add_alt_req_list(Character.id.JSAMUS, req/SAMUS_MODEL)
    add_alt_req_list(Character.id.JNESS, req/NESS_MODEL)
    add_alt_req_list(Character.id.LUCAS, req/LUCAS_MODEL)
    add_alt_req_list(Character.id.JLINK, req/JLINK_MODEL)
    add_alt_req_list(Character.id.JFALCON, req/CAPTAIN_MODEL)
    add_alt_req_list(Character.id.JFOX, req/FOX_MODEL)
    add_alt_req_list(Character.id.JMARIO, req/JMARIO_MODEL)
    add_alt_req_list(Character.id.JLUIGI, req/JLUIGI_MODEL)
    add_alt_req_list(Character.id.JDK, req/DONKEY_MODEL)
    add_alt_req_list(Character.id.EPIKA, req/PIKACHU_MODEL)
    add_alt_req_list(Character.id.JPUFF, req/JIGGLY_MODEL)
    add_alt_req_list(Character.id.EPUFF, req/JIGGLY_MODEL)
    add_alt_req_list(Character.id.JKIRBY, req/KIRBY_MODEL)
    add_alt_req_list(Character.id.JYOSHI, req/YOSHI_MODEL)
    add_alt_req_list(Character.id.JPIKA, req/PIKACHU_MODEL)
    add_alt_req_list(Character.id.ESAMUS, req/SAMUS_MODEL)
	add_alt_req_list(Character.id.BOWSER, req/BOWSER_MODEL)
	add_alt_req_list(Character.id.GBOWSER, req/GBOWSER_MODEL)
    add_alt_req_list(Character.id.PIANO, req/PIANO_MODEL)
	add_alt_req_list(Character.id.WOLF, req/WOLF_MODEL)
    add_alt_req_list(Character.id.CONKER, req/CONKER_MODEL)
    add_alt_req_list(Character.id.MTWO, req/MTWO_MODEL)
    add_alt_req_list(Character.id.MARTH, req/MARTH_MODEL)
    add_alt_req_list(Character.id.SONIC, req/SONIC_MODEL)
    add_alt_req_list(Character.id.SANDBAG, req/SANDBAG_MODEL)
    add_alt_req_list(Character.id.SSONIC, req/SSONIC_MODEL)
    add_alt_req_list(Character.id.SHEIK, req/SHEIK_MODEL)
    add_alt_req_list(Character.id.MARINA, req/MARINA_MODEL)
    add_alt_req_list(Character.id.DEDEDE, req/DEDEDE_MODEL)

    // POLYGONS
    add_alt_req_list(Character.id.NWARIO, req/NWARIO_MODEL)
    add_alt_req_list(Character.id.NLUCAS, req/NLUCAS_MODEL)
    add_alt_req_list(Character.id.NBOWSER, req/NBOWSER_MODEL)
    add_alt_req_list(Character.id.NWOLF, req/NWOLF_MODEL)
    add_alt_req_list(Character.id.NDRM, req/NMARIO_MODEL)
    add_alt_req_list(Character.id.NSONIC, req/NSONIC_MODEL)
    add_alt_req_list(Character.id.NSHEIK, req/NSHEIK_MODEL)
    add_alt_req_list(Character.id.NMARINA, req/NMARINA_MODEL)
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
        OS.patch_start(0x000144508, 0x80134F28)
        j       get_character_id_
        nop
        OS.patch_end()

        // 1P
        OS.patch_start(0x00013E27C, 0x8013607C)
        j       get_character_id_
        nop
        OS.patch_end()
        OS.patch_start(0x00013E15C, 0x80135F5C)
        li      at, CSS_PLAYER_STRUCT_1P    // at = 1p CSS struct
        lw      v0, 0x0048(at)              // v0 = character id
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
        OS.patch_end()

        // BTT/BTP
        OS.patch_start(0x00014AFC8, 0x80134F98)
        j       get_character_id_
        nop
        OS.patch_end()
        OS.patch_start(0x00014AEA8, 0x80134E78)
        li      at, CSS_PLAYER_STRUCT_BONUS // at = Bonus CSS struct
        lw      v0, 0x0048(at)              // v0 = character id
        jr      ra                          // return
        addiu   sp, sp, 0x0018              // deallocate stack space
        OS.patch_end()

        // a0 = player index (port 0 - 3)

        mfc1    v1, f10                     // original line 1 (v1 = (int) ypos)
        mfc1    a1, f6                      // original line 2 (a1 = (int) xpos)

        // make the furthest left/up equal 0 for arithmetic purposes
        addiu   a1, a1, -START_X            // a1 = xpos - X_START
        addiu   v1, v1, -START_Y            // v1 = ypos - Y_START

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~
        sw      a1, 0x0018(sp)              // ~
        sw      a2, 0x001C(sp)              // ~
        sw      v0, 0x0020(sp)              // save registers

        // discard values past given y value
        sltiu   t0, v1, 86                  // if ypos greater than given value
        beqz    t0, _end                    // ...return
        lli     v0, Character.id.NONE       // v0 = ret = NONE

        // use different algorithm for 12cb
        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb
        beqz    t0, _normal                 // if not 12cb, calculate normally
        nop                                 // otherwise, we'll have to do some different calculations

        addiu   v1, v1, START_Y             // v1 = ypos, unadjusted
        // discard values past given y value
        sltiu   t0, v1, TwelveCharBattle.START_Y + 86 // if ypos greater than given value
        beqz    t0, _end                    // ...return
        lli     v0, Character.id.NONE       // v0 = ret = NONE

        jal     TwelveCharBattle.get_character_id_
        addiu   a1, a1, START_X             // a1 = xpos, unadjusted
        b       _end
        nop

        _normal:
        // discard values right of certain given x value
        sltiu   t0, a1, PORTRAIT_WIDTH * NUM_COLUMNS // if xpos less than given value
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

        li      t1, id_table_pointer
        lw      t1, 0x0000(t1)              // t1 = id_table
        addu    t0, t0, t1                  // t1 = id_table[index]
        lbu     v0, 0x0000(t0)              // v0 = character id

        // Variant check requires some setup based on screen
        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = screen id

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        lli     t1, 0x0010                  // t1 = VS CSS
        bnel    t1, t0, pc() + 8            // if we're not on the VS CSS,
        lli     t1, 0x0012                  // then spoof training so the offsets are correct

        // a3 is the CSS player struct

        // if ypos is 85, then we could be hovering, but need to confirm the cursor is not in pointing state (0)
        lli     t0, 85                      // t0 = 85
        bne     t0, v1, _check_variant      // if ypos != 85, continue
        nop
        lw      t0, 0x0054(a3)              // t0 = cursor state
        beqzl   t0, _end                    // if cursor is in pointing state, return
        lli     v0, Character.id.NONE       // v0 = ret = NONE

        _check_variant:
        li      t0, variant_offset          // t0 = address of variant_offset array
        addu    t0, t0, a0                  // t0 = address of variant_offset for port
        lbu     t0, 0x0000(t0)              // t0 = variant_offset
        beqz    t0, _end                    // if variant_offset is 0, then skip
        nop                                 // else, get the variant ID
        li      t1, Character.variants.table// t1 = variant table
        sll     t2, v0, 0x0002              // t2 = character variant array index
        addu    t1, t1, t2                  // t1 = character variant array
        addiu   t0, t0, -0x0001             // t0 = variant_offset, adjusted
        addu    t1, t1, t0                  // t1 = character variant ID address
        lbu     t1, 0x0000(t1)              // t1 = variant ID
        addiu   t0, r0, Character.id.NONE   // t0 = id.NONE
        beq     t1, t0, _end                // if no variant defined, skip to end and return portrait's character id
        nop                                 // otherwise return the variant ID
        addu    v0, r0, t1                  // v0 = variant ID

        _end:
        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      a1, 0x0018(sp)              // ~
        lw      a2, 0x001C(sp)              // restore registers
//      lw      v0, 0x0020(sp)              // don't restore, just needed the stack space
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra                          // return (discard the rest of the function)
        addiu   sp, sp, 0x0028              // deallocate stack space (original function)
    }

    // @ Description
    // Various fixes to ensure token autoposition functions properly
    scope token_autoposition_: {
        // fix portrait id for token recall
        // vs
        OS.patch_start(0x001303E8, 0x80132168)
        // a0 = character_id
        li      t2, portrait_id_table_pointer
        lw      t2, 0x0000(t2)                  // t2 = portraid_id_table
        addu    t2, t2, a0                      // t2 = address of character's portrait_id
        lbu     v0, 0x0000(t2)                  // v0 = portrait_id

        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)                  // t0 = 1 if 12cb mode
        beqz    t0, _end_vs_portrait_id_fix     // skip if not 12cb
        // intentially use delay slot to save space

        // This is a bit hacky...
        // The port is in s2 most of the time, but from one call it is at 0x0040(sp).
        // So check ra to determine the port.
        or      a1, s2, r0                      // a1 = port_id (maybe)
        li      t1, 0x80139494                  // ra when s2 is port_id
        bnel    t1, ra, pc() + 8                // if s2 is not port_id, use 0x0040(sp)
        lw      a1, 0x0040(sp)                  // a1 = port_id

        j       TwelveCharBattle.get_portrait_id_
        nop                                     // a0 = character_id

        _end_vs_portrait_id_fix:
        jr      ra
        nop
        OS.patch_end()
        // training
        OS.patch_start(0x00141600, 0x80132020)
        // a0 = character_id
        li      t2, portrait_id_table_pointer
        lw      t2, 0x0000(t2)                  // t2 = portraid_id_table
        addu    t2, t2, a0                      // t2 = address of character's portrait_id
        lbu     v0, 0x0000(t2)                  // v0 = portrait_id
        jr      ra
        nop
        OS.patch_end()
        // 1p
        OS.patch_start(0x0013A9EC, 0x801327EC)
        // a0 = character_id
        li      t2, portrait_id_table_pointer
        lw      t2, 0x0000(t2)                  // t2 = portraid_id_table
        addu    t2, t2, a0                      // t2 = address of character's portrait_id
        lbu     v0, 0x0000(t2)                  // v0 = portrait_id
        jr      ra
        nop
        OS.patch_end()
        // bonus
        OS.patch_start(0x00148410, 0x801323E0)
        // a0 = character_id
        li      t2, portrait_id_table_pointer
        lw      t2, 0x0000(t2)                  // t2 = portraid_id_table
        addu    t2, t2, a0                      // t2 = address of character's portrait_id
        lbu     v0, 0x0000(t2)                  // v0 = portrait_id
        jr      ra
        nop
        OS.patch_end()

        // fix x position
        // vs
        OS.patch_start(0x0013772C, 0x801394AC)
        lli     t8, NUM_COLUMNS             // ~
        divu    v0, t8                      // ~
        mfhi    t8                          // t8 = portrait_id % NUM_COLUMNS = column
        lli     t9, PORTRAIT_WIDTH          // ~
        multu   t9, t8                      // ~
        mflo    t9                          // t2 = ulx
        jal     token_autoposition_._vs_x_position
        addiu   t9, t9, START_X + 12        // t9 = (int) ulx + offset
        addu    t9, v0, r0                  // remember portrait_id
        OS.patch_end()

        _vs_x_position:
        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _end_vs_x_position      // skip if not 12cb
        nop
        lli     t8, TwelveCharBattle.NUM_COLUMNS
        divu    v0, t8                      // ~
        mfhi    t8                          // t8 = portrait_id % NUM_COLUMNS = column
        lli     t9, TwelveCharBattle.PORTRAIT_WIDTH // ~
        multu   t9, t8                      // ~
        mflo    t9                          // t2 = ulx
        addiu   t9, t9, TwelveCharBattle.START_X + 12 // t9 = (int) ulx + offset
        sltiu   t0, t8, 0x0004              // t0 = 1 if left grid
        addiu   t9, t9, -0x0008             // adjust x for left grid
        beqzl   t0, _end_vs_x_position      // if right grid, then adjust x for right grid
        addiu   t9, t9, 0x0010              // adjust x for right grid (8 * 2 to unadjust fo rleft)

        _end_vs_x_position:
        jr      ra
        mtc1    t9, f4                      // original line 8

        // training
        OS.patch_start(0x00145EB4, 0x801368D4)
        lli     t8, NUM_COLUMNS             // ~
        divu    v0, t8                      // ~
        mfhi    t8                          // t8 = portrait_id % NUM_COLUMNS = column
        lli     t9, PORTRAIT_WIDTH          // ~
        multu   t9, t8                      // ~
        mflo    t9                          // t2 = ulx
        addiu   t9, t9, START_X + 12        // t9 = (int) ulx + offset
        mtc1    t9, f4                      // original line 8
        addu    t9, v0, r0                  // remember portrait_id
        OS.patch_end()

        // fix y position
        scope token_autoposition_y_fix_: {
            // vs
            OS.patch_start(0x001377C0, 0x80139540)
            jal     token_autoposition_y_fix_
            lui     at, 0x4120                  // original line 1
            OS.patch_end()
            // training
            OS.patch_start(0x00145F48, 0x80136968)
            jal     token_autoposition_y_fix_
            lui     at, 0x4120                  // original line 1
            OS.patch_end()

            lli     t1, NUM_COLUMNS             // ~
            li      t2, TwelveCharBattle.twelve_cb_flag
            lw      at, 0x0000(t2)              // at = 1 if 12cb mode
            bnezl   at, pc() + 8                // if 12cb, use correct column count
            lli     t1, TwelveCharBattle.NUM_COLUMNS
            divu    t9, t1                      // ~
            mflo    t1                          // t1 = portrait_id / NUM_COLUMS = row
            lli     t2, PORTRAIT_HEIGHT         // ~
            bnezl   at, pc() + 8                // if 12cb, use correct height
            addiu   t2, t2, TwelveCharBattle.PORTRAIT_HEIGHT - PORTRAIT_HEIGHT
            multu   t2, t1                      // ~
            mflo    t2                          // t2 = uly
            addiu   t2, t2, START_Y + 14        // t2 = (int) uly + offset
            bnezl   at, pc() + 8                // if 12cb, use correct height
            addiu   t2, t2, TwelveCharBattle.START_Y - START_Y

            jr      ra
            lui     at, 0x4120                  // original line 1
        }

        // Set the scale of token gfx after it is created in vs CSS
        scope adjust_created_token_: {
            // vs
            OS.patch_start(0x137428, 0x801391A8)
            jal     adjust_created_token_
            lw      a1, 0x0088(sp)              // original line 1
            OS.patch_end()
            // training
            //OS.patch_start(0x145BB0, 0x801365D0)
            //jal     adjust_created_token_
            //lw      a1, 0x0088(sp)              // original line 1
            //OS.patch_end()

            li      t2, TwelveCharBattle.twelve_cb_flag
            lw      t2, 0x0000(t2)              // t2 = 1 if 12cb, 0 if not
            bnez    t2, _end                    // if 12cb, skip
            nop

            // v0 is newly created token object
            lw      v0, 0x0074(v0)              // v0 = image struct
            lui     t2, PORTRAIT_SCALE          // t2 = float of portrait scale
            sw      t2, 0x0018(v0)              // save x scale of token
            sw      t2, 0x001C(v0)              // save y scale of token
            lw      v0, 0x0004(v0)              // restore v0

            _end:
            jr      ra
            lui     t2, 0x8014                  // original line 2
        }

        // Set the scale of token gfx after it is changed between PLAYER TO CPU
        scope adjust_changed_token_: {
            // vs
            OS.patch_start(0x1369E4, 0x80138764)
            jal     adjust_changed_token_
            lwc1    f8, 0x0038(sp)              // original line 1
            OS.patch_end()
            // training
            OS.patch_start(0x145278, 0x80135C98)
            jal     adjust_changed_token_
            lwc1    f8, 0x0038(sp)              // original line 1
            OS.patch_end()

            li      t4, TwelveCharBattle.twelve_cb_flag
            lw      t4, 0x0000(t4)              // t4 = 1 if 12cb, 0 if not
            bnez    t4, _end                    // if 12cb, skip
            nop

            // v0 is the existing token object's image struct
            lui     t4, PORTRAIT_SCALE          // t2 = float of portrait scale
            sw      t4, 0x0018(v0)              // overwrite x scale of token
            sw      t4, 0x001C(v0)              // overwrite y scale of token

            _end:
            jr      ra
            lhu     t4, 0x0024(v0)              // original line 2
        }

        // fix right boundary check value
        // vs
        OS.patch_start(0x001377EC, 0x8013956C)
        lui     at, 0x4200
        OS.patch_end()
        // training
        OS.patch_start(0x00145F74, 0x80136994)
        lui     at, 0x4200
        OS.patch_end()

        // fix bottom boundary check value
        // vs
        OS.patch_start(0x0013782C, 0x801395AC)
        lui     at, 0x41D0
        OS.patch_end()
        // training
        OS.patch_start(0x00145FB4, 0x801369D4)
        lui     at, 0x41D0
        OS.patch_end()

        // extend max y for cursor so it's easier to reach Reset in 12CB and bottom CSS panel menu options
        // vs
        OS.patch_start(0x135F48, 0x80137CC8)
        lui     at, 0x4354                       // changed from 0x434D
        OS.patch_end()
        // training
        OS.patch_start(0x14498C, 0x801353AC)
        lui     at, 0x4354                       // changed from 0x434D
        OS.patch_end()
        // 1p
        OS.patch_start(0x13E6BC, 0x801364BC)
        lui     at, 0x4354                       // changed from 0x434D
        OS.patch_end()
        // bonus
        OS.patch_start(0x14B408, 0x801353D8)
        lui     at, 0x4354                       // changed from 0x434D
        OS.patch_end()

        // fix variant token overlap detection
        scope _fix_variant_overlap_detection: {
            // vs
            OS.patch_start(0x1379C8, 0x80139748)
            jal     _fix_variant_overlap_detection._vs
            nop
            nop
            nop
            OS.patch_end()
            // training
            OS.patch_start(0x146168, 0x80136B88)
            jal     _fix_variant_overlap_detection._training
            nop
            nop
            nop
            OS.patch_end()

            _vs:
            beql    s6, v0, _j_0x80139784           // original line 3, modified to jump
            addiu   s0, s0, 0x0001                  // original line 4

            // t3 and v0 are character IDs
            // check if their portrait IDs match instead of character IDs

            li      t4, portrait_id_table_pointer
            lw      t4, 0x0000(t4)                  // t4 = portraid_id_table
            addu    v0, t4, v0                      // v0 = address of character's portrait_id
            lbu     v0, 0x0000(v0)                  // v0 = portrait_id
            addu    t3, t4, t3                      // t3 = address of character's portrait_id
            lbu     t3, 0x0000(t3)                  // t3 = portrait_id

            bnel    v0, t3, _j_0x80139784           // original line 1, modified to jump
            addiu   s0, s0, 0x0001                  // original line 2

            jr      ra
            nop

            _j_0x80139784:
            j       0x80139784                      // jump
            nop

            _training:
            beq     v0, at, _j_0x80136BC8           // original line 3, modified to jump
            nop

            // t9 and v0 are character IDs
            // check if their portrait IDs match instead of character IDs

            li      t0, portrait_id_table_pointer
            lw      t0, 0x0000(t0)                  // t0 = portraid_id_table
            addu    v0, t0, v0                      // v0 = address of character's portrait_id
            lbu     v0, 0x0000(v0)                  // v0 = portrait_id
            addu    t9, t0, t9                      // t9 = address of character's portrait_id
            lbu     t9, 0x0000(t9)                  // t9 = portrait_id

            bne     v0, t9, _j_0x80136BC8           // original line 1, modified to jump
            nop

            jr      ra
            nop

            _j_0x80136BC8:
            j       0x80136BC8                      // jump
            nop
        }
    }

    // disable drawing of default portraits on VS CSS
    OS.patch_start(0x001307A0, 0x80132520)
    jr      ra
    nop
    OS.patch_end()

	// skip loading default portraits on VS CSS
	OS.patch_start(0x139634, 0x8013B3B4)
	dw 0			// original = 0x00000013
    OS.patch_end()

    // disable drawing of default portraits on Training Mode CSS
    OS.patch_start(0x001419B8, 0x801323D8)
    jr      ra
    nop
    OS.patch_end()

	// skip loading default portraits on Training mode CSS
    OS.patch_start(0x147558, 0x80137F78)
    dw 0			// original = 0x00000013
    OS.patch_end()

    // disable drawing of default portraits on 1P Mode CSS
    OS.patch_start(0x0013ADA4, 0x80132BA4)
    jr      ra
    nop
    OS.patch_end()

	// skip loading default portraits on 1P Mode CSS
    OS.patch_start(0x140840, 0x80138640)
    dw 0			// original = 0x00000013
    OS.patch_end()

    // disable drawing of default portraits on BTT/BTP CSS
    OS.patch_start(0x00148A88, 0x80132A58)
    jr      ra
    nop
    OS.patch_end()

	// skip loading default portraits on BTT/BTP CSS
    OS.patch_start(0x14CF90, 0x80136F60)
    dw 0			// original = 0x00000013
    OS.patch_end()


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

        // s1 is port id, except when first entering training mode

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        // 0x0008(sp) reserved
        sw      a1, 0x000C(sp)              // ~
        sw      v1, 0x0010(sp)              // ~
        sw      s0, 0x0014(sp)              // ~

        _get_random_id:
        addiu   a0, r0, NUM_SLOTS           // original line 2 modified to include all slots
        li      s0, TwelveCharBattle.twelve_cb_flag
        lw      s0, 0x0000(s0)              // s0 = 1 if 12cb
        bnezl   s0, pc() + 8                // if 12cb, use correct slot count
        addiu   a0, r0, TwelveCharBattle.NUM_SLOTS // original line 2 modified to include all slots

        jal     Global.get_random_int_alt_  // original line 1
        nop
        // v0 = random number between 0 and NUM_SLOTS

        // Check if 12cb and if so check if character is defeated/invalid for port or not
        li      s0, TwelveCharBattle.twelve_cb_flag
        lw      s0, 0x0000(s0)              // s0 = 1 if 12cb
        beqz    s0, _not_12cb               // if not 12cb, skip defeated check
        nop

        lli     a0, TwelveCharBattle.NUM_COLUMNS // a0 = TwelveCharBattle.NUM_COLUMNS
        divu    v0, a0                      // a0 = column
        mfhi    a0                          // ~
        sltiu   a0, a0, 0x0004              // a0 = 1 if left grid, 0 if right grid
        beqzl   s1, pc() + 8                // if p1, then change a0 so we can adjust the portrait_id correctly
        addiu   a0, a0, -0x0001             // a0 = 0 if left grid and p1 (ok) or right grid and p2 (ok), -1 if right grid and p1 (bad), 1 if left grid and p2 (bad)
        sll     a0, a0, 0x0002              // a0 = 0 if left grid and p1 (ok) or right grid and p2 (ok), -4 if right grid and p1 (bad), 4 if left grid and p2 (bad)
        addu    v0, v0, a0                  // v0 = portrait_id, adjusted for port

        lw      s0, 0x0014(sp)              // s0 = CSS player struct
        sw      v0, 0x00B4(s0)              // save the portrait_id so any duplicate character_ids are accounted for correctly

        li      s0, id_table_pointer
        lw      s0, 0x0000(s0)              // s0 = id_table
        addu    s0, s0, v0                  // s0 = id_table + offset
        lbu     v0, 0x0000(s0)              // v0 = character_id
        lli     s0, Character.id.NONE       // s0 = Character.id.NONE
        beq     s0, v0, _get_random_id      // if v0 is not a valid character then get a new random number
        sw      v0, 0x0008(sp)              // save v0

        li      s0, TwelveCharBattle.config.status
        lw      s0, 0x0000(s0)              // s0 = battle status
        lli     a0, TwelveCharBattle.config.STATUS_COMPLETE  // a0 = completed status
        beq     s0, a0, _check_valid_for_port // if completed, skip defeated check (to avoid infinite loop)
        nop

        // to avoid a crash with stock mode manual, check stocks remaining
        li      a1, TwelveCharBattle.config.p1.stocks_remaining
        bnezl   s1, pc() + 8                // if 2p, use p2.stocks_remaining
        addiu   a1, a1, TwelveCharBattle.config.p2.stocks_remaining - TwelveCharBattle.config.p1.stocks_remaining
        lw      a1, 0x0000(a1)              // a1 = stocks remaining
        beqz    a1, _check_valid_for_port   // if no stocks left, skip defeated check (to avoid infinite loop)
        nop

        or      a0, r0, s1                  // a0 = port_id
        jal     TwelveCharBattle.get_stocks_remaining_for_char_ // v0 = remaining_stocks
        or      a1, r0, v0                  // a1 = character_id
        beqz    v0, _get_random_id          // if the character is defeated/invalid for port then get a new random number
        lw      v0, 0x0008(sp)              // restore v0

        // so the random character is not defeated... if the match is started, then force that character_id if the player won
        jal     TwelveCharBattle.get_last_match_portrait_and_stocks_ // v0 = remaining stocks, v1 = portrait_id of last game
        lli     s0, 0x00FF                  // s0 = 0x000000FF (no portrait)
        beqz    v0, _end                    // if the character was defeated last match, then keep new character_id
        lw      v0, 0x0008(sp)              // restore v0
        beq     v1, s0, _end                // if no portrait, then skip
        nop
        // otherwise, the player won previously so we need to get the character_id and force it
        lw      s0, 0x0014(sp)              // s0 = CSS player struct
        sw      v1, 0x00B4(s0)              // save portrait_id
        li      s0, CharacterSelect.id_table_pointer
        lw      s0, 0x0000(s0)              // s0 = id_table
        addu    s0, s0, v1                  // s0 = address of character_id
        b       _end
        lbu     v0, 0x0000(s0)              // v0 = previous character_id

        _check_valid_for_port:
        or      a0, r0, s1                  // a0 = port_id
        jal     TwelveCharBattle.is_character_valid_for_port_
        or      a1, r0, v0                  // a1 = character_id
        beqz    v0, _get_random_id          // if the character is invalid for port then get a new random number
        lw      v0, 0x0008(sp)              // restore v0
        b       _end                        // skip variants check, keep new character_id
        nop

        _not_12cb:
        li      s0, id_table_pointer
        lw      s0, 0x0000(s0)              // s0 = id_table
        addu    s0, s0, v0                  // s0 = id_table + offset
        lbu     v0, 0x0000(s0)              // v0 = character_id
        lli     s0, Character.id.NONE       // s0 = Character.id.NONE
        beq     s0, v0, _get_random_id      // if v0 is not a valid character then get a new random number
        sw      v0, 0x0008(sp)              // save v0

        // Check toggle to see if we should include variants
        li      s0, Toggles.entry_variant_random
        lw      s0, 0x0004(s0)              // t1 = random select with variants when 1
        beqz    s0, _end                    // if random select with variants is off, then skip
        nop                                 // otherwise, determine id taking variants into account:

        addu    s0, r0, v0                  // s0 = character id
        jal     Global.get_random_int_alt_  // get random number for variant offset
        addiu   a0, r0, 0x0005              // a0 = 5
        // v0 = random number between 0 and 4
        beqzl   v0, _end                    // if 0, just use original character
        addu    v0, r0, s0                  // v0 = character id (not a variant)
        // otherwise we check for variants
        addiu   v0, v0, -0x0001             // v0 = offset in variants array
        li      a0, Character.variants.table
        sll     s0, s0, 0x0002              // s0 = offset to variants array
        addu    a0, a0, s0                  // a0 = variants array
        addu    a0, a0, v0                  // a0 = address of variant
        lbu     a0, 0x0000(a0)              // a0 = variant character id
        lli     v0, Character.id.NONE       // v0 = Character.id.NONE
        beql    a0, v0, _end                // if there is no variant, then use the original character
        srl     v0, s0, 0x0002              // v0 = character id (not a variant)
        addu    v0, r0, a0                  // v0 = character id (variant)

        _end:
        lw      ra, 0x0004(sp)              // ~
        // 0x0008(sp) reserved
        lw      a1, 0x000C(sp)              // ~
        lw      v1, 0x0010(sp)              // ~
        lw      s0, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

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

        // 1P
        OS.patch_start(0x0013F244, 0x80137044)
//      jal     0x801327EC                  // original line 1
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
        sw      a0, 0x0014(sp)              // ~
        sw      a1, 0x0018(sp)              // save registers

        // get portrait id
        li      t0, portrait_id_table_pointer
        lw      t0, 0x0000(t0)              // t0 = portrait_id_table
        addu    t0, t0, a0                  // t0 = portrait_id_table + character id
        lbu     v0, 0x0000(t0)              // v0 = portrait_id for character in a0

        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _store_portrait_id      // skip if not 12cb
        nop

        // This is a bit hacky...
        // The port is in s1 most of the time, but from one call it is at 0x0084(s0).
        // So check ra to determine the port.
        or      a1, s1, r0                      // a1 = port_id (maybe)
        li      t1, 0x80139274                  // ra when s1 is not port_id
        beql    t1, ra, pc() + 8                // if s1 is not port_id, use 0x0084(s0)
        lw      a1, 0x0084(s0)                  // a1 = port_id

        jal     TwelveCharBattle.get_portrait_id_
        nop                                     // a0 = character_id

        _store_portrait_id:
        sw      v0, 0x0010(sp)              // store v0 in stack

        // get token location
        lli     t2, NUM_COLUMNS             // ~
        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        bnezl   t0, pc() + 8                // if 12cb, use correct columns
        lli     t2, TwelveCharBattle.NUM_COLUMNS

        divu    v0, t2                      // ~
        mfhi    t1                          // t1 = portrait_id % NUM_COLUMNS = column
        lli     t2, PORTRAIT_WIDTH          // ~
        bnezl   t0, pc() + 8                // if 12cb, use correct width
        addiu   t2, t2, TwelveCharBattle.PORTRAIT_WIDTH - PORTRAIT_WIDTH
        multu   t2, t1                      // ~
        mflo    t2                          // t2 = ulx
        addiu   t2, t2, START_X + 12        // t2 = (int) ulx + offset
        bnezl   t0, pc() + 8                // if 12cb, use correct offset
        addiu   t2, t2, TwelveCharBattle.START_X - START_X

        beqz    t0, _continue               // skip if not 12cb
        sw      t0, 0x001C(sp)              // save 12cb flag
        sltiu   t0, t1, 0x0004              // t0 = 1 if left grid
        addiu   t2, t2, -0x0008             // adjust x for left grid
        beqzl   t0, _continue               // if right grid, then adjust x for right grid
        addiu   t2, t2, 0x0010              // adjust x for right grid (8 * 2 to unadjust fo rleft)

        _continue:
        move    a0, t2                      // ~
        jal     OS.int_to_float_            // ~
        nop
        move    t2, v0                      // t2 = (float) ulx + offset
        sw      t2, 0x0058(t8)              // update token_xpos

        lw      v0, 0x0010(sp)              // restore v0 (portrait_id)
        lli     t0, NUM_COLUMNS             // ~
        lw      t2, 0x001C(sp)              // t2 = 12cb flag
        bnezl   t2, pc() + 8                // if 12cb, use correct columns
        lli     t0, TwelveCharBattle.NUM_COLUMNS

        divu    v0, t0                      // ~
        mflo    t1                          // t1 = portrait_id / NUM_COLUMS = row
        lli     t0, PORTRAIT_HEIGHT         // ~
        bnezl   t2, pc() + 8                // if 12cb, use correct height
        addiu   t0, t0, TwelveCharBattle.PORTRAIT_HEIGHT - PORTRAIT_HEIGHT
        multu   t0, t1                      // ~
        mflo    t2                          // t2 = uly
        addiu   t2, t2, START_Y + 14        // t2 = (int) uly + offset
        lw      t0, 0x001C(sp)              // t0 = 12cb flag
        bnezl   t0, pc() + 8                // if 12cb, use correct offset
        addiu   t2, t2, TwelveCharBattle.START_Y - START_Y
        move    a0, t2                      // ~
        jal     OS.int_to_float_            // ~
        nop
        move    t2, v0                      // t2 = (float) uly + offset
        sw      t2, 0x005C(t8)              // update token_ypos

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      a1, 0x0018(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space

        // actual end
        lw      ra, 0x0014(sp)              // restore ra
        jr      ra                          // end function
        addiu   sp, sp, 0x0018              // deallocate stack space

    }

    // @ Description
    // This helper macro will overwrite some of the white flash routine for each screen.
    macro set_white_flash_texture() {
        li      t2, portrait_offset_table_pointer
        lw      t2, 0x0000(t2)              // t2 = portrait_offset_table
        sll     t3, s0, 0x0002              // t3 = offset in portrait offset table
        addu    t2, t2, t3                  // t2 = address of portrait offset
        lw      t2, 0x0000(t2)              // t2 = portrait offset
        li      a1, Render.file_pointer_1   // a1 = base address of character portraits file
        lw      a1, 0x0000(a1)              // ~
        addu    a1, a1, t2                  // a1 = portrait image footer address
        jal     0x800CCFDC
        addiu   a1, a1, 0x0860              // a1 = flash portrait image footer address

        // use portraits to get position/scale/etc info
        lli     t3, 0x0000                  // t3 = loop variable/portrait_id
        li      t4, Render.ROOM_TABLE + (0x1B * 4)
        lw      t4, 0x0000(t4)              // t4 = first portrait object
        _loop_{#}:
        beql    s0, t3, _set_portrait_info_{#}  // if this is the right portrait, exit loop
        lw      t4, 0x0074(t4)              // t4 = image struct
        lw      t4, 0x0020(t4)              // t4 = next portrait object
        b       _loop_{#}
        addiu   t3, t3, 0x0001              // t3 = next portrait_id

        _set_portrait_info_{#}:
        lw      t0, 0x0058(t4)              // t0 = ulx
        sw      t0, 0x0058(v0)              // set ulx
        lw      t0, 0x005C(t4)              // t0 = uly
        sw      t0, 0x005C(v0)              // set uly
        lhu     t0, 0x0024(t4)              // t4 = image flags
        sh      t0, 0x0024(v0)              // set image flags
        lw      t0, 0x0018(t4)              // t0 = x scale
        sw      t0, 0x0018(v0)              // set x scale
        lw      t0, 0x001C(t4)              // t0 = y scale
        sw      t0, 0x001C(v0)              // set y scale
    }

    // @ Description
    // The following patches reposition the white flash on vs character select.
    // The assumption is the white flash portrait is always 0x860 after the character portrait.
    OS.patch_start(0x13474C, 0x801364CC)
    addiu   a2, r0, 0x0012
    OS.patch_end()
    OS.patch_start(0x134778, 0x801364F8)
    addiu   a2, r0, 0x001B
    OS.patch_end()
    OS.patch_start(0x1347A4, 0x80136524)
    //      s0 = portrait ID
    lw      a0, 0x003C(sp)              // a0 = object struct (original line 6)

    set_white_flash_texture()

    fill    0x801365BC - pc()           // skip rest of routine
    OS.patch_end()

    // @ Description
    // The following patches reposition the white flash on training character select.
    // The assumption is the white flash portrait is always 0x860 after the character portrait.
    OS.patch_start(0x14368C, 0x801340AC)
    addiu   a2, r0, 0x0012
    OS.patch_end()
    OS.patch_start(0x1436B8, 0x801340D8)
    addiu   a2, r0, 0x001B
    OS.patch_end()
    OS.patch_start(0x1436E4, 0x80134104)
    //      s0 = portrait ID
    lw      a0, 0x003C(sp)              // a0 = object struct (original line 6)

    set_white_flash_texture()

    j       0x8013419C                  // skip rest of routine
    nop
    OS.patch_end()

    // @ Description
    // The following patches reposition the white flash on 1p character select.
    // The assumption is the white flash portrait is always 0x860 after the character portrait.
    OS.patch_start(0x13DC2C, 0x80135A2C)
    addiu   a2, r0, 0x0012
    OS.patch_end()
    OS.patch_start(0x13DC58, 0x80135A58)
    addiu   a2, r0, 0x001B
    OS.patch_end()
    OS.patch_start(0x13DC84, 0x80135A84)
    //      s0 = portrait ID
    lw      a0, 0x002C(sp)              // a0 = object struct (original line 5)

    set_white_flash_texture()

    j       0x80135B1C                  // skip rest of routine
    nop
    OS.patch_end()

    // @ Description
    // The following patches reposition the white flash on BTT/BTP character select.
    // The assumption is the white flash portrait is always 0x860 after the character portrait.
    OS.patch_start(0x14A97C, 0x8013494C)
    addiu   a2, r0, 0x0012
    OS.patch_end()
    OS.patch_start(0x14A9A8, 0x80134978)
    addiu   a2, r0, 0x001B
    OS.patch_end()
    OS.patch_start(0x14A9D4, 0x801349A4)
    //      s0 = portrait ID
    lw      a0, 0x002C(sp)              // a0 = object struct (original line 5)

    set_white_flash_texture()

    j       0x80134A3C                  // skip rest of routine
    nop
    OS.patch_end()

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
        li      t3, file_table              // t3 = filetable address
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
    // allows for custom entries of name texture based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x11)
    // 1P Mode and BTT/BTP
    scope get_name_texture_1p_btx_: {
        // 1P
        OS.patch_start(0x0013B0CC, 0x80132ECC)
//      lw      t7, 0x001C(t7)                    // original line 1
        jal     get_name_texture_1p_btx_
        lw      t0, 0x96A0(t0)                    // original line 2
        OS.patch_end()

        // BTT/BTP
        OS.patch_start(0x00148BF4, 0x80132BC4)
//      lw      t7, 0x001C(t7)                    // original line 1
        jal     get_name_texture_1p_btx_
        lw      t0, 0x7DF8(t0)                    // original line 2
        OS.patch_end()

        li      t7, name_texture_table            // t8 = texture offset table
        addu    t7, t7, v1                        // t8 = address of texture offset
        lw      t7, 0x0000(t7)                    // t8 = texture offset
        jr      ra                                // return
        nop
    }

    // @ Description
    // Allows for custom entries of series logo based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x14)
    scope get_series_logo_offset_: {
        // vs
        OS.patch_start(0x00130D68, 0x80132AE8)
//      addu    t5, sp, a2                  // original line (sp holds table, a2 holds char id * 4)
//      lw      t5, 0x0054(t5)              // original line (t5 = file offset of data)
        jal     get_series_logo_offset_
        nop
        OS.patch_end()

        // training
        OS.patch_start(0x00141C88, 0x801326A8)
//      addu    t5, sp, a2                  // original line (sp holds table, a2 holds char id * 4)
//      lw      t5, 0x004C(t5)              // original line (t5 = file offset of data)
        jal     get_series_logo_offset_
        nop
        OS.patch_end()

        li      t5, series_logo_offset_table
        addu    t5, t5, a2
        lw      t5, 0x0000(t5)
        jr      ra
        nop
    }

    // @ Description
    // Allows for custom entries of series logo based on file offset (+0x10 for DF000000 00000000)
    // (requires modification of file 0x14)
    // 1P Mode and BTT/BTP
    scope get_series_logo_offset_1p_btx_: {
        // 1P
        OS.patch_start(0x0013B070, 0x80132E70)
//      addu    t5, sp, v1                  // original line (sp holds table, a2 holds char id * 4)
//      lw      t5, 0x004C(t5)              // original line (t5 = file offset of data)
        jal     get_series_logo_offset_1p_btx_
        nop
        OS.patch_end()

        // BTT/BTP
        OS.patch_start(0x00148B98, 0x80132B68)
//      addu    t5, sp, v1                  // original line (sp holds table, a2 holds char id * 4)
//      lw      t5, 0x004C(t5)              // original line (t5 = file offset of data)
        jal     get_series_logo_offset_1p_btx_
        nop
        OS.patch_end()

        li      t5, series_logo_offset_table
        addu    t5, t5, v1
        lw      t5, 0x0000(t5)
        jr      ra
        nop
    }

    // @ Description
    // Disables token movement when token set down on 1p css (migrates towards original spot)
    OS.patch_start(0x0014C1DC, 0x801361AC)
    jr      ra
    nop
    OS.patch_end()

    // @ Description
    // Disables token movement when token set down on BTT/BTP css (migrates towards original spot)
    OS.patch_start(0x0013F8F8, 0x801376F8)
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
    // Loads from white_circle_size_table instead of original table
    // @ Note
    // All values are 1.5 except DK. Possibly change this to static in the future
    scope get_zoom_1p_: {
        OS.patch_start(0x0013FC34, 0x80137A34)
//      addiu   v0, sp, 0x0000                  // original line 1
        j       get_zoom_1p_                    // set table to custom table
        lui     v1, 0x8014                      // original line 2
        _get_zoom_1p_return:
        OS.patch_end()

        li      v0, white_circle_size_table     // set v0
        j       _get_zoom_1p_return             // return
        nop
    }

    // @ Description
    // Loads from white_circle_size_table instead of original table
    // @ Note
    // All values are 1.5 except DK. Possibly change this to static in the future
    scope get_zoom_btx_: {
        OS.patch_start(0x0014C518, 0x801364E8)
//      addiu   v0, sp, 0x0000                  // original line 1
        j       get_zoom_btx_                   // set table to custom table
        lui     v1, 0x8013                      // original line 2
        _get_zoom_btx_return:
        OS.patch_end()

        li      v0, white_circle_size_table     // set v0
        j       _get_zoom_btx_return            // return
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

        // 1p
        OS.patch_start(0x13D0E0, 0x80134EE0)
        j       get_action_
        nop
        OS.patch_end()

        // BTT/BTP
        OS.patch_start(0x149FB8, 0x80133F88)
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
        jal     load_additional_characters_
        nop
        OS.patch_end()

        // Training
        OS.patch_start(0x00147394, 0x80137DB4)
        jal     load_additional_characters_
        nop
        OS.patch_end()

        // 1P
        OS.patch_start(0x00140634, 0x80138434)
        jal     load_additional_characters_._1p_btx
        nop
        OS.patch_end()

        // BTT/BTP
        OS.patch_start(0x0014CE08, 0x80136DD8)
        jal     load_additional_characters_._1p_btx
        nop
        OS.patch_end()

        addiu   sp, sp, -0x0008             // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        // Not the cleanest place to put this, but meh
        li      s0, CharacterSelectDebugMenu.debug_control_object
        sw      r0, 0x0000(s0)              // clear out control object reference before it is used

        // for (char_id i = METAL; i < last character; i++)
        lli     s0, Character.id.METAL

        _loop:
        lli     a0, Character.id.PLACEHOLDER// a0 = PLACEHOLDER
        beql    a0, s0, _loop               // if char_id = PLACEHOLDER, skip
        addiu   s0, s0, 0x0001              // increment index
        lli     a0, Character.id.NONE       // a0 = NONE
        beql    a0, s0, _loop               // if char_id = NONE, skip
        addiu   s0, s0, 0x0001              // increment index
        lli     a0, Character.id.SANDBAG    // a0 = SANDBAG
        beql    a0, s0, _loop               // if char_id = SANDBAG, skip
        addiu   s0, s0, 0x0001              // increment index

		// check variant
        li      a0, Character.variant_type.table
		addu    a0, a0, s0
		lb      a0, 0x0000(a0)              // get variant type
        bnezl   a0, _loop                   // if not variant_type.NA, skip
        addiu   s0, s0, 0x0001              // increment index

        _load:
        jal     load_character_model_       // load character function
        or      a0, s0, r0                  // a0 = index
        // end on x character
        slti    at, s0, Character.id.NWARIO - 1
        bnez    at, _loop
        addiu   s0, s0, 0x0001              // increment index

        _end:
        lui     v1, 0x8014                  // original line 1
		_end_2:
        lui     s0, 0x8013                  // original line 2

        lw      ra, 0x0004(sp)              // ~
        addiu   sp, sp, 0x0008              // deallocate stack space

        jr      ra                          // return
        nop

        _1p_btx:
        addiu   sp, sp, -0x0010             // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      v1, 0x0008(sp)              // ~
        sw      s0, 0x000C(sp)              // ~

        jal     load_additional_characters_
        nop
        lui     a0, 0x8013                  // original line 1
        lw      a0, 0x0D9C(a0)              // original line 2

        lw      ra, 0x0004(sp)              // ~
        lw      v1, 0x0008(sp)              // ~
        lw      s0, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // Dynamically loads character files for unloaded characters
    scope dynamically_load_character_: {
        OS.patch_start(0x537E4, 0x800D7FE4)
        jal     dynamically_load_character_
        lw      t5, 0x0000(t4)              // original line 1
        OS.patch_end()

        // t5 = address of main character file, or 0 if not loaded yet
        bnez    t5, _end                    // if loaded, end normally
        nop

        OS.save_registers()
        jal     load_character_model_
        lw      a0, 0x0008(v0)              // a0 = char_id
        OS.restore_registers()

        lw      t5, 0x0000(t4)              // t5 = address of main character file, now loaded

        _end:
        jr      ra
        addu    s4, t5, t6                  // original line 2 (address of attribute data)
    }

    // @ Description
    // Changes the loads from fgm_table instead of the original function table
    scope get_fgm_: {
        // vs
        OS.patch_start(0x00134B10, 0x80136890)
//      sll     t5, t4, 0x0001              // original line 1
//      addu    a0, sp, t5                  // original line 2
        jal     get_fgm_
        nop
        jal     0x800269C0                  // original line 3
//      lw      a0, 0x0020(a0)              // original line 4
        nop
        OS.patch_end()

        // training
        OS.patch_start(0x14385C, 0x8013427C)
//      sll     t6, t5, 0x0001              // original line 1
//      addu    a0, sp, t6                  // original line 2
        jal     get_fgm_
        addu    t4, t5, r0                  // our routine uses t4, not t5
        jal     0x800269C0                  // original line 3
//      lw      a0, 0x0028(a0)              // original line 4
        nop
        OS.patch_end()

        // 1p
        OS.patch_start(0x13DDC4, 0x80135BC4)
//      sll     t2, t1, 0x0001              // original line 1
//      addu    a0, sp, t2                  // original line 2
        jal     get_fgm_
        addu    t4, t1, r0                  // our routine uses t4, not t1
        jal     0x800269C0                  // original line 3
//      lhu     a0, 0x0020(a0)              // original line 4
        nop
        OS.patch_end()

        // 1p
        OS.patch_start(0x14AB14, 0x80134AE4)
//      sll     t2, t1, 0x0001              // original line 1
//      addu    a0, sp, t2                  // original line 2
        jal     get_fgm_
        addu    t4, t1, r0                  // our routine uses t4, not t1
        jal     0x800269C0                  // original line 3
//      lhu     a0, 0x0020(a0)              // original line 4
        nop
        OS.patch_end()

        // t4 = character_id
        // s1 = port id in vs and training

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      t1, 0x0004(sp)              // ~
        sw      v1, 0x0008(sp)              // ~
        sw      t5, 0x000C(sp)              // ~

        addu    v1, t4, r0                  // v1 = character id
        sltiu   t1, s1, 0x0004              // t1 = 1 if s1 is a port id
        beq     t1, r0, _get_fgm_id         // if s1 is port id, use it to get original character id
        nop
        li      t1, Character.variant_original.table
        sll     v1, v1, 0x0002              // v1 = offset in variant_original table
        addu    t1, t1, v1                  // t1 = address of original character id
        lw      v1, 0x0000(t1)              // v1 = original character id

        _get_fgm_id:
        // get fgm_id
        li      a0, fgm_table               // a0 = fgm_table
        sll     t5, t4, 0x0001              // ~
        addu    a0, a0, t5                  // a0 = fgm_table + char offset
        lhu     a0, 0x0000(a0)              // a0 = fgm id

        lw      t1, 0x0004(sp)              // ~
        lw      v1, 0x0008(sp)              // ~
        lw      t5, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra                          // return
        nop
    }

    // @ Description
    // This patch increases the heap space by moving it to expansion RAM when the original heap fills up.
    // This enables us to load a nearly unlimited number of character models on the CSS.
    // It also ensures large stages don't crash with large characters.
    scope increase_heap_: {
        OS.patch_start(0x7920, 0x80006D20)
        jal     increase_heap_
        sltu    at, t9, v0                  // original line 2 - at = 1 if overflow
        OS.patch_end()

        beqz    at, _return                 // if no overflow, continue normally
        nop

        li      at, 0x800465E8              // at = main heap struct
        bnel    at, a3, _return             // if not the main heap, continue normally
        sltu    at, t9, v0                  // original line 2

        lui     at, 0x8080                  // at = 0x80800000 = end of expansion RAM
        beql    at, t9, _return             // if we've already extended the main heap, continue normally
        sltu    at, t9, v0                  // original line 2

        // if we're here, the current malloc will not fit in the original heap, so extend to expansion RAM
        li      at, custom_heap             // at = free memory start
        sw      at, 0x000C(a3)              // update current heap free memory
        lui     at, 0x8080                  // at = end of expansion RAM
        j       0x80006CF4                  // jump back to (almost) the start of routine
        sw      at, 0x0008(a3)              // update end of heap

        _return:
        jr      ra
        sw      v0, 0x000C(a3)              // original line 1
    }

    // @ Description
    // Hooks into button handler (tehz) so we can check d-pad/Z inputs for variant determination
    scope check_variant_input_: {
        // VS
        OS.patch_start(0x00136590, 0x80138310)
        jal     check_variant_input_._vs
        nop
        OS.patch_end()

        // training
        OS.patch_start(0x00144F54, 0x80135974)
        jal     check_variant_input_._training
        nop
        OS.patch_end()

        // 1p
        OS.patch_start(0x0013EF88, 0x80136D88)
        jal     check_variant_input_._1p
        nop
        OS.patch_end()

        // Bonus
        OS.patch_start(0x0014B9B0, 0x80135980)
        jal     check_variant_input_._bonus
        nop
        OS.patch_end()

        _vs:
        // a1 = player index (port 0 - 3)
        // v0 = pointer to player CSS struct
        // 0x0080(v0) = held token player index (port 0 - 3 or -1 if not holding a token)

        addu    t8, t6, t7                  // original line 1
        sw      t8, 0x0024(sp)              // original line 2

        addiu   sp, sp, -0x0020             // allocate stack space
        sw      v1, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~

        lhu     t8, 0x0002(t8)              // unique press button state

        // L press triggers random char select for human players if not hovering over portraits
        andi    at, t8, Joypad.L            // at = 0 if L not pressed
        beqz    at, _check_12cb             // if L not pressed, skip
        lw      at, 0x0080(v0)              // at = held token index
        bltz    at, _do_random_char_select  // if not holding a token (meaning char is selected), do random
        lli     t0, Character.id.NONE       // t0 = Character.id.NONE
        bne     at, a1, _check_12cb         // if not holding own token, skip
        lw      at, 0x0048(v0)              // at = selected char_id
        bne     t0, at, _check_12cb         // if hovering over a char, skip
        nop
        _do_random_char_select:
        lw      at, 0x0084(v0)              // at = panel state (0 if HMN)
        bnez    at, _check_12cb             // if not HMN, skip
        nop
        jal     select_random_char_
        or      a0, a1, r0                  // a0 = port

        _check_12cb:
        li      v1, TwelveCharBattle.twelve_cb_flag
        lw      v1, 0x0000(v1)              // v1 = 1 if 12cb mode
        beqz    v1, _not_12cb               // if not 12cb mode, continue normally
        nop

        // jump to 12cb's input code and skip the variant stuff
        jal     TwelveCharBattle.check_input_
        lw      v1, 0x0044(sp)              // v1 = input struct
        b       _end_vs
        nop

        _not_12cb:
        jal     _shared                     // call main routine (shared between vs and training)
        addu    v1, v0, r0                  // v1 = pointer to player CSS struct

        _end_vs:
        lw      v1, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        lw      t8, 0x0024(sp)              // restore t8

        jr      ra
        nop

        _1p:
        // a1 = player index (port 0 - 3)
        // t1 = pointer to 0x0028 offset in player CSS struct
        // 0x0054(t1) = held token player index (port 0 - 3 or -1 if not holding a token)

        addu    t8, t6, t7                  // original line 1
        sw      t8, 0x001C(sp)              // original line 2

        addiu   sp, sp, -0x000C             // allocate stack space
        sw      v1, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~

        lhu     t8, 0x0002(t8)              // unique press button state
        jal     _shared                     // call main routine (shared between vs and training)
        addiu   v1, t1, -0x002C             // v1 = pointer to player CSS struct, adjusted for 1p so some offsets line up correctly

        lw      v1, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // ~
        addiu   sp, sp, 0x000C              // deallocate stack space

        lw      t8, 0x001C(sp)              // restore t8

        jr      ra
        nop

        _training:
        // s0 = player index (port 0 - 3)
        // v0 = pointer to player CSS struct
        // 0x007C(v0) = held token player index (port 1 when P1, P3 or P4 and port 0 when P2)
        // t8 = unique press button state

        subu    t0, t0, s0                  // original line 1
        lw      a0, 0x0040(sp)              // original line 2

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      v1, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~

        addu    a1, s0, r0                  // a1 = player index
        jal     _shared                     // call main routine (shared between vs and training)
        addiu   v1, v0, -0x0004             // v1 = pointer to player CSS struct, adjusted for training so some offsets line up correctly

        lw      v1, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        jr      ra
        nop

        _bonus:
        // s0 = player index (port 0 - 3)
        // t1 = pointer to 0x0028 offset in player CSS struct
        // 0x0054(t1) = held token player index (port 0 - 3 or -1 if not holding a token)

        addu    t8, t6, t7                  // original line 1
        sw      t8, 0x0024(sp)              // original line 2

        addiu   sp, sp, -0x0010             // allocate stack space
        sw      v1, 0x0004(sp)              // ~
        sw      a1, 0x0008(sp)              // ~
        sw      ra, 0x000C(sp)              // ~

        addu    a1, s0, r0                  // a1 = player index
        lhu     t8, 0x0002(t8)              // unique press button state
        jal     _shared                     // call main routine (shared between vs and training)
        addiu   v1, t1, -0x002C             // v1 = pointer to player CSS struct, adjusted for bonus so some offsets line up correctly

        lw      a0, 0x0034(sp)              // a0 = controller struct pointer
        jal     Bonus.check_input_          // extra checks for bonus screen
        lhu     a0, 0x0002(a0)              // a0 = button mask

        lw      v1, 0x0004(sp)              // ~
        lw      a1, 0x0008(sp)              // ~
        lw      ra, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        lw      t8, 0x0024(sp)              // restore t8

        jr      ra
        nop

        _shared:
        addiu   sp, sp, -0x0020             // allocate stack space
        sw      at, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      v0, 0x0010(sp)              // ~
        sw      t8, 0x0014(sp)              // ~
        sw      a0, 0x0018(sp)              // ~
        sw      ra, 0x001C(sp)              // ~

        _check_mask:
        andi    t8, t8, 0x2F00              // Check for Z or any d-pad button
        beq     t8, r0, _end                // if no Z or d-pad press, exit
        nop

        li      at, variant_offset          // at = variant_offset address
        lw      t0, 0x0080(v1)              // t0 = currently held token
        addiu   t0, t0, 0x0001              // t0 = 0 if no token held, else 1 - 4 corresponding to port
        beq     t0, r0, _end                // if not holding a token, then skip altogether
        nop
        addiu   t0, t0, -0x0001             // ...otherwise, we'll use the token index to adjust variant_offset
        addu    t1, at, t0                  // t1 = variant_offset

        _check_input:
        lbu     a0, 0x0000(t1)              // a0 = current variant_offset value

        andi    at, t8, Joypad.DU           // D-pad up
        bnel    at, r0, _set_variant_offset // if pressed, update to SPECIAL
        addiu   t8, r0, Character.variants.DU + 1

        andi    at, t8, Joypad.DD           // D-pad down
        bnel    at, r0, _set_variant_offset // if pressed, update to POLYGON
        addiu   t8, r0, Character.variants.DD + 1

        andi    at, t8, Joypad.DL           // D-pad left
        bnel    at, r0, _set_variant_offset // if pressed, update to J
        addiu   t8, r0, Character.variants.DL + 1

        andi    at, t8, Joypad.DR           // D-pad right
        bnel    at, r0, _set_variant_offset // if pressed, update to E
        addiu   t8, r0, Character.variants.DR + 1

        andi    at, t8, Joypad.Z            // Z
        bnel    at, r0, _set_variant_offset // if pressed, reset to normal character
        addu    t8, a0, r0                  // t8 = a0

        addu    t8, r0, r0                  // t8 = 0

        _set_variant_offset:
        beqzl   t8, _end                    // if t8 = 0, then use previous variant_offset
        sb      a0, 0x0000(t1)              // ~
        beql    a0, t8, _end                // if the same direction already selected is selected again...
        sb      r0, 0x0000(t1)              // ...then reset to normal character
        sb      t8, 0x0000(t1)              // ...else store new variant_offset

        _end:
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      v0, 0x0010(sp)              // ~
        lw      t8, 0x0014(sp)              // ~
        lw      a0, 0x0018(sp)              // ~
        lw      ra, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        jr      ra
        nop
    }

    variant_offset:
    db 0x00                                 // player 1
    db 0x00                                 // player 2
    db 0x00                                 // player 3
    db 0x00                                 // player 4

    // @ Description
    // New table for sound fx (for each character)
    fgm_table:
    constant fgm_table_origin(origin())
    dh FGM.announcer.names.MARIO                  // Mario
    dh FGM.announcer.names.FOX                    // Fox
    dh FGM.announcer.names.DONKEY_KONG            // Donkey Kong
    dh FGM.announcer.names.SAMUS                  // Samus
    dh FGM.announcer.names.LUIGI                  // Luigi
    dh FGM.announcer.names.LINK                   // Link
    dh FGM.announcer.names.YOSHI                  // Yoshi
    dh FGM.announcer.names.CAPTAIN_FALCON         // Captain Falcon
    dh FGM.announcer.names.KIRBY                  // Kirby
    dh FGM.announcer.names.PIKACHU                // Pikachu
    dh FGM.announcer.names.JIGGLYPUFF             // Jigglypuff
    dh FGM.announcer.names.NESS                   // Ness

    // other sound fx
    dh FGM.announcer.names.MARIO                  // Master Hand
    dh FGM.announcer.names.METAL_MARIO            // Metal Mario
    // TODO: better announcer FGMs for polygons
    dh FGM.announcer.names.POLYGON_MARIO          // Polygon Mario
    dh FGM.announcer.names.POLYGON_FOX            // Polygon Fox
    dh FGM.announcer.names.POLYGON_DONKEY_KONG    // Polygon Donkey Kong
    dh FGM.announcer.names.POLYGON_SAMUS          // Polygon Samus
    dh FGM.announcer.names.POLYGON_LUIGI          // Polygon Luigi
    dh FGM.announcer.names.POLYGON_LINK           // Polygon Link
    dh FGM.announcer.names.POLYGON_YOSHI          // Polygon Yoshi
    dh FGM.announcer.names.POLYGON_CAPTAIN_FALCON // Polygon Captain Falcon
    dh FGM.announcer.names.POLYGON_KIRBY          // Polygon Kirby
    dh FGM.announcer.names.POLYGON_PIKACHU        // Polygon Pikachu
    dh FGM.announcer.names.POLYGON_JIGGLYPUFF     // Polygon Jigglypuff
    dh FGM.announcer.names.POLYGON_NESS           // Polygon Ness
    dh FGM.announcer.names.GDK                    // Giant Donkey Kong
    dh FGM.announcer.names.MARIO                  // (Placeholder)
    dh FGM.announcer.names.MARIO                  // None (Placeholder)

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
    float32 2.00                            // Polygon Donkey Kong
    float32 1.50                            // Polygon Samus
    float32 1.50                            // Polygon Luigi
    float32 1.50                            // Polygon Link
    float32 1.50                            // Polygon Yoshi
    float32 1.50                            // Polygon Captain Falcon
    float32 1.50                            // Polygon Kirby
    float32 1.50                            // Polygon Pikachu
    float32 1.50                            // Polygon Jigglypuff
    float32 1.50                            // Polygon Ness
    float32 2.25                            // Giant Donkey Kong
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
    dw 0x00010003                           // Metal Mario
    dw 0x00010003                           // Polygon Mario
    dw 0x00010004                           // Polygon Fox
    dw 0x00010001                           // Polygon Donkey Kong
    dw 0x00010004                           // Polygon Samus
    dw 0x00010001                           // Polygon Luigi
    dw 0x00010001                           // Polygon Link
    dw 0x00010002                           // Polygon Yoshi
    dw 0x00010001                           // Polygon Captain Falcon
    dw 0x00010003                           // Polygon Kirby
    dw 0x00010001                           // Polygon Pikachu
    dw 0x00010002                           // Polygon Jigglypuff
    dw 0x00010002                           // Polygon Ness
    dw 0x00010001                           // Giant Donkey Kong
    dw 0x00010001                           // (Placeholder)
    dw 0x00010001                           // None (Placeholder)
    // add space for new characters
    fill (selection_action_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    // @ Description
    // Offsets to the portrait image footers in the Character Portraits file.
    // It is assumed that the white flash version of the portraits are immediately following the corresponding normal portrait.
    // The size of each block is 0x860, so Mario's flash would be at portrait_offsets.MARIO + 0x860 for example.
    scope portrait_offsets: {
        constant NONE(0x00000818)
        // original
        constant MARIO(0x00001078)
        constant FOX(0x00002138)
        constant DONKEY(0x000031F8)
        constant SAMUS(0x000042B8)
        constant LUIGI(0x00005378)
        constant LINK(0x00006438)
        constant YOSHI(0x000074F8)
        constant CAPTAIN(0x000085B8)
        constant KIRBY(0x00009678)
        constant PIKACHU(0x0000A738)
        constant JIGGLYPUFF(0x0000B7F8)
        constant NESS(0x0000C8B8)
        // poly
        constant NMARIO(0x00001078)
        constant NFOX(0x00002138)
        constant NDONKEY(0x000031F8)
        constant NSAMUS(0x000042B8)
        constant NLUIGI(0x00005378)
        constant NLINK(0x00006438)
        constant NYOSHI(0x000074F8)
        constant NCAPTAIN(0x000085B8)
        constant NKIRBY(0x00009678)
        constant NPIKACHU(0x0000A738)
        constant NJIGGLY(0x0000B7F8)
        constant NNESS(0x0000C8B8)
        constant NWARIO(0x00012D38)
        constant NLUCAS(0x00013DF8)
        constant NBOWSER(0x00014EB8)
        constant NWOLF(0x0001A278)
        constant NDRM(0x00010BB8)
        constant NSONIC(0x0001E578)
        constant NSHEIK(0x000206F8)
        constant NMARINA(0x000217B8)
        // special
        constant METAL(0x00015F78)
        constant GDONKEY(0x00017038)
		constant GBOWSER(0x000180F8)
        constant PIANO(0x000191B8)
        constant SSONIC(0x0001F638)
        // custom
        constant FALCO(0x0000D978)
        constant GND(0x0000EA38)
        constant YLINK(0x0000FAF8)
        constant DRM(0x00010BB8)
        constant DSAMUS(0x00011C78)
        constant WARIO(0x00012D38)
        constant LUCAS(0x00013DF8)
        constant BOWSER(0x00014EB8)
        constant WOLF(0x0001A278)
        constant CONKER(0x0001B338)
        constant MTWO(0x0001C3F8)
        constant MARTH(0x0001D4B8)
        constant SONIC(0x0001E578)
        constant SANDBAG(0x00017038)
        constant SHEIK(0x000206F8)
        constant MARINA(0x000217B8)
        constant DEDEDE(0x00022878)
        // j
        constant JMARIO(0x00001078)
        constant JFOX(0x00002138)
        constant JDK(0x000031F8)
        constant JSAMUS(0x000042B8)
        constant JLUIGI(0x00005378)
        constant JLINK(0x00006438)
        constant JYOSHI(0x000074F8)
        constant JFALCON(0x000085B8)
        constant JKIRBY(0x00009678)
        constant JPIKA(0x0000A738)
        constant JPUFF(0x0000B7F8)
        constant JNESS(0x0000C8B8)
        // e
        constant ESAMUS(0x000042B8)
        constant ELINK(0x00006438)
        constant EPIKA(0x0000A738)
        constant EPUFF(0x0000B7F8)
    }

    // @ Description
    // Logo offsets in file 0x14
    scope series_logo {
        constant NONE(0)
        constant MARIO_BROS(1)
        constant STARFOX(2)
        constant DONKEY_KONG(3)
        constant METROID(4)
        constant ZELDA(5)
        constant YOSHI(6)
        constant FZERO(7)
        constant KIRBY(8)
        constant POKEMON(9)
        constant EARTHBOUND(10)
        constant SMASH(11)
        constant DR_MARIO(12)
        constant BOWSER(13)
        constant CONKER(14)
        constant WARIO(15)
        constant FIRE_EMBLEM(16)
        constant REMIX(17)
        constant BANJO_KAZOOIE(18)
        constant GAME_AND_WATCH(19)
        constant JET_FORCE_GEMINI(20)
        constant MISCHIEF_MAKERS(21)
        constant MVC(22)
        constant PERFECT_DARK(23)
        constant PERSONA(24)
        constant NBA_JAM(25)
        constant TOH(26)
        constant ANIMAL_CROSSING(27)
        constant SONIC(28)
		constant CASTLEVANIA(29)

        scope offset {
            constant NONE(0)
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
            constant SMASH(0x000045D8)
            constant DR_MARIO(0x00004C38)
            constant BOWSER(0x00005298)
            constant CONKER(0x000058F8)
            constant WARIO(0x00005F58)
            constant FIRE_EMBLEM(0x000065B8)
            constant REMIX(0x00006C18)
            constant BANJO_KAZOOIE(0x00007278)
            constant GAME_AND_WATCH(0x000078D8)
            constant JET_FORCE_GEMINI(0x00007F38)
            constant MISCHIEF_MAKERS(0x00008598)
            constant MVC(0x00008BF8)
            constant PERFECT_DARK(0x00009258)
            constant PERSONA(0x000098B8)
            constant NBA_JAM(0x00009F18)
            constant TOH(0x0000A578)
            constant ANIMAL_CROSSING(0x0000ABD8)
            constant SONIC(0x0000B238)
            constant CASTLEVANIA(0x0000B898)
        }

        // @ Description
        // Logo X/Y coordinates for stage select screen
        scope position {
            constant X_NONE(0)
            constant Y_NONE(0)
            constant X_MARIO_BROS(0x40400000)
            constant Y_MARIO_BROS(0x41980000)
            constant X_STARFOX(0x40400000)
            constant Y_STARFOX(0x41980000)
            constant X_DONKEY_KONG(0x40400000)
            constant Y_DONKEY_KONG(0x41A00000)
            constant X_METROID(0x40000000)
            constant Y_METROID(0x41A00000)
            constant X_ZELDA(0x40400000)
            constant Y_ZELDA(0x41880000)
            constant X_YOSHI(0xBF800000)
            constant Y_YOSHI(0x41980000)
            constant X_FZERO(0x40A00000)
            constant Y_FZERO(0x41A00000)
            constant X_KIRBY(0x3F800000)
            constant Y_KIRBY(0x41A00000)
            constant X_POKEMON(0x3F800000)
            constant Y_POKEMON(0x41A00000)
            constant X_EARTHBOUND(0x3F800000)
            constant Y_EARTHBOUND(0x419C0000)
            constant X_SMASH(0x3F800000)
            constant Y_SMASH(0x419C0000)
            constant X_DR_MARIO(0)
            constant Y_DR_MARIO(0x41980000)
            constant X_BOWSER(0)
            constant Y_BOWSER(0x41980000)
            constant X_CONKER(0x40400000)
            constant Y_CONKER(0x41780000)
            constant X_WARIO(0x40400000)
            constant Y_WARIO(0x41780000)
            constant X_FIRE_EMBLEM(0x00000000)
            constant Y_FIRE_EMBLEM(0x41980000)
            constant X_REMIX(0x40400000)
            constant Y_REMIX(0x419C0000)
            constant X_BANJO_KAZOOIE(0x00000000)
            constant Y_BANJO_KAZOOIE(0x41900000)
            constant X_GAME_AND_WATCH(0x3F800000)
            constant Y_GAME_AND_WATCH(0x41900000)
            constant X_JET_FORCE_GEMINI(0x40000000)
            constant Y_JET_FORCE_GEMINI(0x41800000)
            constant X_MISCHIEF_MAKERS(0x40000000)
            constant Y_MISCHIEF_MAKERS(0x419C0000)
            constant X_MVC(0x40800000)
            constant Y_MVC(0x419C0000)
            constant X_PERFECT_DARK(0x3F800000)
            constant Y_PERFECT_DARK(0x419C0000)
            constant X_PERSONA(0x3F800000)
            constant Y_PERSONA(0x419C0000)
            constant X_NBA_JAM(0x40000000)
            constant Y_NBA_JAM(0x41A80000)
            constant X_TOH(0x40000000)
            constant Y_TOH(0x41800000)
            constant X_ANIMAL_CROSSING(0x3F800000)
            constant Y_ANIMAL_CROSSING(0x419C0000)
            constant X_SONIC(0x40400000)
            constant Y_SONIC(0x41900000)
            constant X_CASTLEVANIA(0x40400000)
            constant Y_CASTLEVANIA(0x41900000)
        }

        table:
        constant series_logo_table_origin(origin())
        // offset                   // X position                // Y position
        dw offset.NONE,             position.X_NONE,             position.Y_NONE
        dw offset.MARIO_BROS,       position.X_MARIO_BROS,       position.Y_MARIO_BROS
        dw offset.STARFOX,          position.X_STARFOX,          position.Y_STARFOX
        dw offset.DONKEY_KONG,      position.X_DONKEY_KONG,      position.Y_DONKEY_KONG
        dw offset.METROID,          position.X_METROID,          position.Y_METROID
        dw offset.ZELDA,            position.X_ZELDA,            position.Y_ZELDA
        dw offset.YOSHI,            position.X_YOSHI,            position.Y_YOSHI
        dw offset.FZERO,            position.X_FZERO,            position.Y_FZERO
        dw offset.KIRBY,            position.X_KIRBY,            position.Y_KIRBY
        dw offset.POKEMON,          position.X_POKEMON,          position.Y_POKEMON
        dw offset.EARTHBOUND,       position.X_EARTHBOUND,       position.Y_EARTHBOUND
        dw offset.SMASH,            position.X_SMASH,            position.Y_SMASH
        dw offset.DR_MARIO,         position.X_DR_MARIO,         position.Y_DR_MARIO
        dw offset.BOWSER,           position.X_BOWSER,           position.Y_BOWSER
        dw offset.CONKER,           position.X_CONKER,           position.Y_CONKER
        dw offset.WARIO,            position.X_WARIO,            position.Y_WARIO
        dw offset.FIRE_EMBLEM,      position.X_FIRE_EMBLEM,      position.Y_FIRE_EMBLEM
        dw offset.REMIX,            position.X_REMIX,            position.Y_REMIX
        dw offset.BANJO_KAZOOIE,    position.X_BANJO_KAZOOIE,    position.Y_BANJO_KAZOOIE
        dw offset.GAME_AND_WATCH,   position.X_GAME_AND_WATCH,   position.Y_GAME_AND_WATCH
        dw offset.JET_FORCE_GEMINI, position.X_JET_FORCE_GEMINI, position.Y_JET_FORCE_GEMINI
        dw offset.MISCHIEF_MAKERS,  position.X_MISCHIEF_MAKERS,  position.Y_MISCHIEF_MAKERS
        dw offset.MVC,              position.X_MVC,              position.Y_MVC
        dw offset.PERFECT_DARK,     position.X_PERFECT_DARK,     position.Y_PERFECT_DARK
        dw offset.PERSONA,          position.X_PERSONA,          position.Y_PERSONA
        dw offset.NBA_JAM,          position.X_NBA_JAM,          position.Y_NBA_JAM
        dw offset.TOH,              position.X_TOH,              position.Y_TOH
        dw offset.ANIMAL_CROSSING,  position.X_ANIMAL_CROSSING,  position.Y_ANIMAL_CROSSING
        dw offset.SONIC,            position.X_SONIC,            position.Y_SONIC
        dw offset.CASTLEVANIA,      position.X_CASTLEVANIA,      position.Y_CASTLEVANIA
    }

    // @ Description
    // Logo offsets by character ID
    series_logo_offset_table:
    constant series_logo_offset_table_origin(origin())
    dw series_logo.offset.MARIO_BROS               // Mario
    dw series_logo.offset.STARFOX                  // Fox
    dw series_logo.offset.DONKEY_KONG              // Donkey Kong
    dw series_logo.offset.METROID                  // Samus
    dw series_logo.offset.MARIO_BROS               // Luigi
    dw series_logo.offset.ZELDA                    // Link
    dw series_logo.offset.YOSHI                    // Yoshi
    dw series_logo.offset.FZERO                    // Captain Falcon
    dw series_logo.offset.KIRBY                    // Kirby
    dw series_logo.offset.POKEMON                  // Pikachu
    dw series_logo.offset.POKEMON                  // Jigglypuff
    dw series_logo.offset.EARTHBOUND               // Ness
    dw series_logo.offset.SMASH
    dw series_logo.offset.MARIO_BROS
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.SMASH
    dw series_logo.offset.DONKEY_KONG
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
        constant METAL(0x00013308)
        constant NMARIO(0x00013CC8)
        constant NFOX(0x000141A8)
        constant NDONKEY(0x00014688)
        constant NSAMUS(0x00014B68)
        constant NLUIGI(0x00015048)
        constant NLINK(0x00015528)
        constant NYOSHI(0x00015A08)
        constant NCAPTAIN(0x00015EE8)
        constant NKIRBY(0x000163C8)
        constant NPIKACHU(0x000168A8)
        constant NJIGGLY(0x00016D88)
        constant NNESS(0x00017268)
        constant GDONKEY(0x000137E8)
        constant GND(0x00011AA8)
        constant FALCO(0x00011F88)
        constant YLINK(0x00012468)
        constant DRM(0x00012948)
        constant DSAMUS(0x00012E28)
        constant ELINK(0x00002BA0)
        constant WARIO(0x000175C8)
        constant LUCAS(0x00018138)
        constant BOWSER(0x00018618)
		constant GBOWSER(0x00018BC8)
        constant JLINK(0x00002BA0)
        constant JFALCON(0x00003998)
        constant JFOX(0x000025B8)
        constant JMARIO(0x00001838)
        constant JLUIGI(0x00001B18)
        constant JDK(0x00017AA8)
        constant EPIKA(0x000032F8)
        constant JPUFF(0x00017DD8)
        constant JPIKA(0x000032F8)
        constant PIANO(0x000190A8)
		constant WOLF(0x00019588)
        constant CONKER(0x00019A68)
        constant MEWTWO(0x00019F48)
        constant MARTH(0x0001A428)
        constant SONIC(0x0001B2C8)
        constant SHEIK(0x0001BC88)
        constant SANDBAG(0x00019A68)
        constant SSONIC(0x0001B7A8)
        constant MARINA(0x0001C168)
        constant DEDEDE(0x0001C648)
        // POLYGONS
        constant NWARIO(0x0001CB28)
        constant NLUCAS(0x0001D008)
        constant NBOWSER(0x0001D4E8)
        constant NWOLF(0x0001D9C8)
        constant NDRM(0x0001DEA8)
        constant NSONIC(0x0001E388)
        constant NSHEIK(0x0001E868)
        constant NMARINA(0x0001ED48)
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
    dw name_texture.METAL                   // Metal Mario
    dw name_texture.NMARIO                  // Polygon Mario
    dw name_texture.NFOX                    // Polygon Fox
    dw name_texture.NDONKEY                 // Polygon Donkey Kong
    dw name_texture.NSAMUS                  // Polygon Samus
    dw name_texture.NLUIGI                  // Polygon Luigi
    dw name_texture.NLINK                   // Polygon Link
    dw name_texture.NYOSHI                  // Polygon Yoshi
    dw name_texture.NCAPTAIN                // Polygon Captain Falcon
    dw name_texture.NKIRBY                  // Polygon Kirby
    dw name_texture.NPIKACHU                // Polygon Pikachu
    dw name_texture.NJIGGLY                 // Polygon Jigglypuff
    dw name_texture.NNESS                   // Polygon Ness
    dw name_texture.GDONKEY                 // Giant Donkey Kong
    dw name_texture.BLANK                   // (Placeholder)
    dw name_texture.BLANK                   // None (Placeholder)
    // add space for new characters
    fill (name_texture_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    constant START_X(14)
    constant START_Y(29)
    constant START_VISUAL(10)
    constant NUM_ROWS(3)
    constant NUM_COLUMNS(10)
    constant NUM_PORTRAITS(NUM_ROWS * NUM_COLUMNS)
    constant PORTRAIT_WIDTH_FILE(32)
    constant PORTRAIT_HEIGHT_FILE(32)
    constant PORTRAIT_SCALE(0x3F70)     // float 0.9375
    constant PORTRAIT_WIDTH(27)         // screen pixels
    constant PORTRAIT_HEIGHT(27)        // screen pixels


    // @ Description
    // CHARACTER SELECT SCREEN LAYOUT
    constant NUM_SLOTS(30)
    scope layout {
        // row 1
        define slot_1(MARINA)
        define slot_2(DRM)
        define slot_3(LUIGI)
        define slot_4(MARIO)
        define slot_5(DONKEY)
        define slot_6(LINK)
        define slot_7(SAMUS)
        define slot_8(CAPTAIN)
        define slot_9(GND)
        define slot_10(SONIC)

        // row 2
        define slot_11(DEDEDE)
        define slot_12(YLINK)
        define slot_13(NESS)
        define slot_14(YOSHI)
        define slot_15(KIRBY)
        define slot_16(FOX)
        define slot_17(PIKACHU)
        define slot_18(JIGGLYPUFF)
        define slot_19(FALCO)
        define slot_20(SHEIK)

        // row 3
        define slot_21(NONE)
        define slot_22(DSAMUS)
        define slot_23(WARIO)
        define slot_24(LUCAS)
        define slot_25(BOWSER)
        define slot_26(WOLF)
        define slot_27(CONKER)
        define slot_28(MTWO)
        define slot_29(MARTH)
        define slot_30(NONE)
    }

    // @ Description
    // This renders the portraits, using the slide in animation.
    // @ Arguments
    // a0 - 12cb flag: 1 if 12cb, 0 if not
    scope draw_portraits_: {
        constant SLIDE_IN_TRAINING(0x1D90)
        constant SLIDE_IN_VS(0x1EE4)
        constant SLIDE_IN_1P(0x255C)
        constant SLIDE_IN_BONUS(0x2150)

        addiu   sp, sp, -0x0020             // allocate stack space
        sw      ra, 0x0004(sp)              // save ra
        sw      a0, 0x0008(sp)              // ~

        lli     s0, 0x0000                  // s0 = slot index = 0
        lli     s1, NUM_SLOTS               // s1 = NUM_SLOTS
        bnezl   a0, pc() + 8                // if 12cb mode, use correct slot count
        lli     s1, TwelveCharBattle.NUM_SLOTS
        li      s2, id_table_pointer
        lw      s2, 0x0000(s2)              // s2 = id_table
        li      s3, Render.file_pointer_1   // s3 = base address of character portraits file
        lw      s3, 0x0000(s3)              // ~
        li      s4, portrait_offset_table_pointer
        lw      s4, 0x0000(s4)              // s4 = portrait_offset_table

        // set the animation slide in routine depending on the screen
        // screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        lui     s6, 0x8013                  // s6 = 0x80130000
        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = current screen
        lli     t1, 0x0010
        beql    t0, t1, _loop
        addiu   s6, s6, SLIDE_IN_VS         // VS
        lli     t1, 0x0011
        beql    t0, t1, _loop
        addiu   s6, s6, SLIDE_IN_1P         // 1P
        lli     t1, 0x0012
        beql    t0, t1, _loop
        addiu   s6, s6, SLIDE_IN_TRAINING   // Training
        addiu   s6, s6, SLIDE_IN_BONUS      // Bonus

        _loop:
        sll     s5, s0, 0x0002              // s5 = slot index * 4
        lli     t3, NUM_COLUMNS             // t3 = NUM_COLUMNS
        bnezl   a0, pc() + 8                // if 12cb mode, use correct column count
        lli     t3, TwelveCharBattle.NUM_COLUMNS
        divu    s0, t3                      // mflo = ROW, mfhi = COLUMN
        mfhi    t0                          // t0 = COLUMN
        mflo    t1                          // t1 = ROW

        // first, draw the portrait texture
        addiu   sp, sp, -0x0030             // allocate stack space
        sw      s0, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      s3, 0x0010(sp)              // ~
        sw      s4, 0x0014(sp)              // ~
        sw      s5, 0x0018(sp)              // ~
        sw      s6, 0x001C(sp)              // ~
        sw      t0, 0x0020(sp)              // ~

        li      a3, TwelveCharBattle.draw_disabled_rectangle_
        beqzl   a0, pc() + 8                // if not 12cb mode, then don't pass a routine
        lli     a3, 0x0000                  // a3 = (no) routine
        lli     a1, 0x12                    // a1 = group
        addu    a2, s4, s5                  // a2 = address of portrait offset
        lw      a2, 0x0000(a2)              // a2 = portrait offset
        addu    a2, s3, a2                  // a2 = image footer

        sltiu   t2, t0, NUM_COLUMNS / 2     // t2 = 1 if left of middle, 0 if right of middle
        bnezl   a0, pc() + 8                // if 12cb mode, use correct column count
        sltiu   t2, t0, TwelveCharBattle.NUM_COLUMNS / 2
        bnezl   t2, _get_y                  // set ulx appropriately:
        lui     s1, 0xC1A0                  // s1 = ulx when left of middle (-20)
        lui     s1, 0x439B                  // s1 = ulx when right of middle (310)

        _get_y:
        lli     t2, PORTRAIT_HEIGHT         // t2 = PORTRAIT_HEIGHT
        bnezl   a0, pc() + 8                // if 12cb mode, use 12cb height
        addiu   t2, t2, TwelveCharBattle.PORTRAIT_HEIGHT - PORTRAIT_HEIGHT
        multu   t1, t2                      // t2 = ROW * PORTRAIT_HEIGHT
        mflo    t2                          // ~
        addiu   t2, t2, START_Y + START_VISUAL // t2 = uly, adjusted for top padding
        bnezl   a0, pc() + 8                // if 12cb mode, use 12cb height
        addiu   t2, t2, TwelveCharBattle.START_Y - START_Y + TwelveCharBattle.START_VISUAL - START_VISUAL
        mtc1    t2, f0                      // f0 = uly
        cvt.s.w f0, f0                      // ~
        mfc1    s2, f0                      // s2 = uly

        lui     s5, PORTRAIT_SCALE          // s5 = scale
        bnezl   a0, pc() + 8                // if 12cb mode, don't scale
        lui     s5, 0x3F80                  // s5 = scale
        li      s3, 0xFFFFFFFF              // s3 = color
        li      s4, 0x00000000              // s4 = palette
        jal     Render.draw_texture_
        lli     a0, 0x1B                    // a0 = room

        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      s3, 0x0010(sp)              // ~
        lw      s4, 0x0014(sp)              // ~
        lw      s5, 0x0018(sp)              // ~
        lw      s6, 0x001C(sp)              // ~
        lw      t0, 0x0020(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        // setup 12cb related fields
        sw      s0, 0x0030(v0)              // save portrait_id in object struct
        sw      r0, 0x0034(v0)              // clear out rectangle pointer in object struct
        sw      v0, 0x0010(sp)              // save portrait_id object address

        // then, register the slide in animation
        sw      t0, 0x0084(v0)              // save column index in object struct
        addiu   sp, sp, -0x0030             // move stack pointer (0x80008188 is not safe)
        addu    a0, r0, v0                  // a0 = object struct
        addu    a1, r0, s6                  // a1 = animation slide in routine
        lli     a2, 0x0001                  // a2 = 1
        jal     0x80008188
        lli     a3, 0x0001                  // a3 = 1
        addiu   sp, sp, 0x0030              // restore stack pointer

        lw      t0, 0x0008(sp)              // t0 = 12cb flag
        beqz    t0, _next                   // if not 12cb mode, then don't add flag/icon image
        nop                                 // otherwise, add an image struct to this object for variant indicators
        jal     TwelveCharBattle.update_portrait_variant_indicator_
        lw      a0, 0x0010(sp)              // a0 = portrait_id object address

        _next:
        addiu   s0, s0, 0x0001              // increment slot index
        bne     s0, s1, _loop               // if not finished drawing all slots, loop
        lw      a0, 0x0008(sp)              // restore a0

        lw      ra, 0x0004(sp)              // restore ra
        addiu   sp, sp, 0x0020              // deallocate stack space
        jr      ra
        nop
    }

    // Patch portrait animation routine
    // 1p
    OS.patch_start(0x13A640, 0x80132440)
    mtc1    a1, f12                         // original line 3
    // v1 needs to be the location of the end X position table
    // a1 needs to be the location of the portrait velocity table
    // a0 needs to be the index in those tables, but is originaly the portrait ID
    li      v1, portrait_x_position
    li      a1, portrait_velocity

    j       0x801324B4                      // skip the rest of the routine
    nop
    OS.patch_end()

    // Patch portrait animation routine
    // Training
    OS.patch_start(0x141254, 0x80131C74)
    mtc1    a1, f12                         // original line 3
    // v1 needs to be the location of the end X position table
    // a1 needs to be the location of the portrait velocity table
    // a0 needs to be the index in those tables, but is originaly the portrait ID
    li      v1, portrait_x_position
    li      a1, portrait_velocity

    j       0x80131CE8                      // skip the rest of the routine
    nop
    OS.patch_end()

    // Patch portrait animation routine
    // VS
    OS.patch_start(0x130048, 0x80131DC8)
    mtc1    a1, f12                         // original line 3
    // v1 needs to be the location of the end X position table
    // a1 needs to be the location of the portrait velocity table
    // a0 needs to be the index in those tables, but is originaly the portrait ID
    li      v1, portrait_x_position_pointer
    lw      v1, 0x0000(v1)
    li      a1, portrait_velocity
    li      t0, TwelveCharBattle.twelve_cb_flag
    lw      t0, 0x0000(t0)              // t0 = 1 if 12cb
    beqz    t0, _j_0x80131E3C           // if not 12cb, a1 is correct
    nop                                 // otherwise use correct table
    li      a1, TwelveCharBattle.portrait_velocity

    _j_0x80131E3C:
    j       0x80131E3C                      // skip the rest of the routine
    nop
    OS.patch_end()

    // Patch portrait animation routine
    // Bonus
    OS.patch_start(0x148064, 0x80132034)
    mtc1    a1, f12                         // original line 3
    // v1 needs to be the location of the end X position table
    // a1 needs to be the location of the portrait velocity table
    // a0 needs to be the index in those tables, but is originaly the portrait ID
    li      v1, portrait_x_position
    li      a1, portrait_velocity

    j       0x801320A8                      // skip the rest of the routine
    nop
    OS.patch_end()

    // @ Description
    // Pointer to portrait_x_position
    portrait_x_position_pointer:
    dw portrait_x_position

    // @ Description
    // This table holds the final X position for portraits
    // This could just be based on column, but it is set for each portrait to make code simpler
    portrait_x_position:
    evaluate n(0)
    while NUM_COLUMNS > {n} {
        evaluate x(START_VISUAL + START_X + PORTRAIT_WIDTH * {n})
        float32 {x}
        evaluate n({n} + 1)
    }

    // @ Description
    // This table holds the velocity for portrait slide in animations
    // This could just be based on column, but it is set for each portrait to permit finer control
    // The custom characters' portraits slide in slower then the original cast's portraits
    portrait_velocity:
    float32 1.9                               // column 1
    float32 3.9                               // column 2
    float32 7.8                               // column 3
    float32 11.8                              // column 4
    float32 13.8                              // column 5
    float32 -11.8                             // column 6
    float32 -7.8                              // column 7
    float32 -3.8                              // column 8
    float32 -1.8                              // column 9
    float32 -0.9                              // column 10

    // @ Description
    // Pointer to id_table
    id_table_pointer:
    dw id_table

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
    // Pointer to portrait_offset_table
    portrait_offset_table_pointer:
    dw portrait_offset_table

    // @ Description
    // Portrait offsets in order of portrait ID
    portrait_offset_table:
    evaluate n(0)
    while NUM_SLOTS > {n} {
        evaluate n({n} + 1)
        dw portrait_offsets.{layout.slot_{n}}
    }
    OS.align(4)

    // @ Description
    // Portrait offsets in order of character ID
    portrait_offset_by_character_table:
    constant portrait_offset_by_character_table_origin(origin())
    dw portrait_offsets.MARIO                   // Mario
    dw portrait_offsets.FOX                     // Fox
    dw portrait_offsets.DONKEY                  // Donkey Kong
    dw portrait_offsets.SAMUS                   // Samus
    dw portrait_offsets.LUIGI                   // Luigi
    dw portrait_offsets.LINK                    // Link
    dw portrait_offsets.YOSHI                   // Yoshi
    dw portrait_offsets.CAPTAIN                 // Captain Falcon
    dw portrait_offsets.KIRBY                   // Kirby
    dw portrait_offsets.PIKACHU                 // Pikachu
    dw portrait_offsets.JIGGLYPUFF              // Jigglypuff
    dw portrait_offsets.NESS                    // Ness
    dw portrait_offsets.NONE                    // Master Hand
    dw portrait_offsets.METAL                   // Metal Mario
    dw portrait_offsets.NMARIO                  // Polygon Mario
    dw portrait_offsets.NFOX                    // Polygon Fox
    dw portrait_offsets.NDONKEY                 // Polygon Donkey Kong
    dw portrait_offsets.NSAMUS                  // Polygon Samus
    dw portrait_offsets.NLUIGI                  // Polygon Luigi
    dw portrait_offsets.NLINK                   // Polygon Link
    dw portrait_offsets.NYOSHI                  // Polygon Yoshi
    dw portrait_offsets.NCAPTAIN                // Polygon Captain Falcon
    dw portrait_offsets.NKIRBY                  // Polygon Kirby
    dw portrait_offsets.NPIKACHU                // Polygon Pikachu
    dw portrait_offsets.NJIGGLY                 // Polygon Jigglypuff
    dw portrait_offsets.NNESS                   // Polygon Ness
    dw portrait_offsets.GDONKEY                 // Giant Donkey Kong
    dw portrait_offsets.NONE                    // (Placeholder)
    dw portrait_offsets.NONE                    // None (Placeholder)
    // add space for new characters
    fill (portrait_offset_by_character_table + (Character.NUM_CHARACTERS * 0x4)) - pc()

    // @ Description
    // Pointer to portrait_id_table
    portrait_id_table_pointer:
    dw portrait_id_table

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
        // Metal Mario
        if (Character.id.{layout.slot_{n}} == Character.id.MARIO) {
            origin portrait_id_table_origin + Character.id.METAL
            db {n} - 1
        }
        // Giant Donkey Kong
        if (Character.id.{layout.slot_{n}} == Character.id.DONKEY) {
            origin portrait_id_table_origin + Character.id.GDONKEY
            db {n} - 1
        }
        // Polygons
        if (Character.id.{layout.slot_{n}} < Character.id.BOSS) {
            origin portrait_id_table_origin + Character.id.{layout.slot_{n}} + Character.id.NMARIO
            db {n} - 1
        }
    }
    // Always return 0 for Character.id.NONE (the game does this)
    origin portrait_id_table_origin + Character.id.NONE
    db 0x00
    pullvar base, origin

    // Set menu zoom size for GDK
    Character.table_patch_start(menu_zoom, Character.id.GDONKEY, 0x4)
    float32 1.3
    OS.patch_end()

    // Set menu zoom size for Sheik
    Character.table_patch_start(menu_zoom, Character.id.SHEIK, 0x4)
    float32 0.9921875
    OS.patch_end()

    // Set menu zoom size for NSheik
    Character.table_patch_start(menu_zoom, Character.id.NSHEIK, 0x4)
    float32 0.9921875
    OS.patch_end()


    // @ Description
    // Settings for the different CSS pages for easy access
    css_settings:
    // # panels;  // z-index  // X padding  // panel offset
    db 0x04;      db 0x15;    db 34;        db 69            // VS
    db 0x01;      db 0x0E;    db 38;        db 69            // 1P
    db 0x02;      db 0x15;    db 65;        db 132           // TRAINING
    db 0x01;      db 0x0E;    db 71;        db 69            // BONUS
    db 0x01;      db 0x0E;    db 71;        db 69            // BONUS

    // @ Description
    // Addresses for the different CSS pages' player panel structs for easy access
    // 1P and Bonus are actually not the start but normalized so that offsets we care about are the same across screens
    css_player_structs:
    dw CSS_PLAYER_STRUCT
    dw CSS_PLAYER_STRUCT_1P
    dw CSS_PLAYER_STRUCT_TRAINING
    dw CSS_PLAYER_STRUCT_BONUS
    dw CSS_PLAYER_STRUCT_BONUS

    // @ Description
    // This points to the object that olds the dpad objects
    render_control_object:
    dw 0x00000000

    // @ Description
    // This sets up variant-related indicators and renders the portraits to the screen.
    // Called from Render.asm.
    scope setup_: {
        constant DPAD_Y(0x4331)

        // a0 = screen id
        addiu   a0, a0, -0x0010             // a0 = 0, 1, 2, 3, 4 for VS, 1P, TRAINING, BONUS1, BONUS2
        sll     a0, a0, 0x0002              // a0 = CSS screen index * 4
        li      t0, css_settings
        addu    t0, t0, a0                  // t0 = CSS settings
        lbu     s0, 0x0000(t0)              // s0 = number of panels
        lbu     s1, 0x0001(t0)              // s1 = room z-index
        lbu     s2, 0x0002(t0)              // s2 = X padding
        lbu     s3, 0x0003(t0)              // s3 = panel offset
        lli     s4, 0x0000                  // s4 = offset for panel index for storing reference
        lli     s5, 0x00B8                  // s5 = css player struct size
        beqzl   a0, _begin                  // In VS, the css player struct is 0xBC (includes shade)
        lli     s5, 0x00BC                  // s5 = css player struct size
        addiu   t0, a0, -0x0008             // t0 = 0 if TRAINING
        bnez    t0, _begin                  // In TRAINING, the css player struct is at the port index for the human
        nop                                 // so we need to do some stuff
        lui     t0, 0x8014                  // t0 = port index of human
        lw      t0, 0x8894(t0)              // ~
        beqz    t0, _begin                  // if human is port 1, fuggedaboutit
        nop                                 // otherwise, make the offset 0xBC * player index
        multu   t0, s5                      // s5 = player index * 0xBC
        mflo    s5                          // ~

        _begin:
        // ensure pointers are correct
        li      t0, id_table_pointer
        li      t1, id_table
        sw      t1, 0x0000(t0)

        li      t0, portrait_id_table_pointer
        li      t1, portrait_id_table
        sw      t1, 0x0000(t0)

        li      t0, portrait_offset_table_pointer
        li      t1, portrait_offset_table
        sw      t1, 0x0000(t0)

        li      t0, portrait_x_position_pointer
        li      t1, portrait_x_position
        sw      t1, 0x0000(t0)

        li      t2, Training.special_model_display
        lw      t0, 0x0000(t2)              // t0 = Training's initialized special model display
        li      t1, Toggles.entry_special_model
        bgezl   t0, pc() + 8                // if value has been initialized, restore Toggles value
        sw      t0, 0x0004(t1)              // restore value
        addiu   t0, r0, -0x0001             // t0 = -1
        sw      t0, 0x0000(t2)              // clear Training value

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      s0, 0x000C(sp)              // ~
        sw      s1, 0x0010(sp)              // ~
        sw      s2, 0x0014(sp)              // ~
        sw      s3, 0x0018(sp)              // ~
        sw      s4, 0x001C(sp)              // ~
        sw      s5, 0x0020(sp)              // save registers

        Render.load_font()                                                // load font for strings
        Render.load_file(File.CHARACTER_PORTRAITS, Render.file_pointer_1) // load character portraits into file_pointer_1
        Render.load_file(File.CSS_IMAGES, Render.file_pointer_2)          // load CSS images into file_pointer_2
        Render.load_file(0x0024, Render.file_pointer_3)                   // load file with "x" image into file_pointer_3

        // add a room for our indicators that shows up on top of the panels
        lli     a0, 0x38                    // a0 = room
        lli     a1, 0x10                    // a1 = group
        lw      a2, 0x0010(sp)              // a2 = z_index
        lui     s1, 0x4120                  // s1 = ulx
        lui     s2, 0x4120                  // s2 = uly
        lui     s3, 0x439B                  // s3 = lrx
        jal     Render.create_room_
        lui     s4, 0x4366                  // s4 = lry

        // Create a control object which runs the variant update code every frame.
        // D-pad textures will be created and references to their objects will be stored in this control object
        Render.register_routine(update_variant_indicators_)
        sw      v0, 0x0024(sp)              // save control object reference
        li      a0, render_control_object
        sw      v0, 0x0000(a0)              // save control object reference for outside routine
        sw      r0, 0x0034(v0)              // 0 out panel reference slots we may not need
        sw      r0, 0x0038(v0)              // 0 out panel reference slots we may not need
        sw      r0, 0x003C(v0)              // 0 out panel reference slots we may not need
        lw      a0, 0x0008(sp)              // a0 = offset in css_player_structs
        li      a1, css_player_structs      // a1 = css_player_structs
        addu    a1, a1, a0                  // a1 = pointer to player struct address
        lw      a0, 0x0000(a1)              // a0 = player struct start
        sw      a0, 0x0040(v0)              // save player struct start address
        sw      r0, 0x0044(v0)              // clear remaining stock icon and stock indicators object reference

        _add_dpad_image:
        lli     a0, 0x38                    // a0 = room
        lli     a1, 0x13                    // a1 = group
        li      a2, Render.file_pointer_2   // a2 = pointer to CSS images file start address
        lw      a2, 0x0000(a2)              // a2 = base file address
        addiu   a2, a2, 0x0218              // a2 = address of d-pad image TODO: make constant
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lwc1    f0, 0x0014(sp)              // f0 = ulx
        cvt.s.w f0, f0                      // ~
        mfc1    s1, f0                      // s1 = ulx
        lui     s2, DPAD_Y                  // s2 = uly
        lli     s3, 0x0000                  // s3 = color
        lli     s4, 0x0000                  // s4 = palette
        jal     Render.draw_texture_
        lui     s5, 0x3F80                  // s5 = scale

        lw      t1, 0x0024(sp)              // t1 = control object reference
        lw      s4, 0x001C(sp)              // s4 = offset in control object reference for panel
        addu    t1, t1, s4                  // t1 = control object reference offset for panel
        sw      v0, 0x0030(t1)              // store port X dpad object pointer in control object
        sw      r0, 0x0034(v0)              // 0 out reference to variant icons
        addiu   t0, r0, 0x0001              // t0 = 1 (display off)
        sw      t0, 0x007C(v0)              // turn display off initially
        srl     t0, s4, 0x0002              // t0 = css player struct index
        lw      s5, 0x0020(sp)              // s5 = css player struct size
        mult    s5, t0                      // t0 = css player struct offset
        mflo    t0                          // ~
        lw      t1, 0x0024(sp)              // t1 = control object reference
        lw      t1, 0x0040(t1)              // t1 = css player struct base address
        addu    t1, t1, t0                  // t1 = css player struct address for this dpad image
        sw      t1, 0x0084(v0)              // save reference to css player struct
        addiu   t0, t1, -0x00BC             // t0 = normalized css player struct reference
        addu    t0, t0, s5                  // ~ (now we can reference 0x50 and higher offsets the same)
        sw      t0, 0x0048(v0)              // save normalized css player struct reference
        lw      t1, 0x0058(t0)              // t1 = initial player selected flag
        sw      t1, 0x003C(v0)              // store player selected status
        sw      r0, 0x0040(v0)              // 0 out reference to regional flag

        sw      v0, 0x0028(sp)              // save dpad object reference

        lli     a0, 0x38                    // a0 = room
        lli     a1, 0x13                    // a1 = group
        lli     s1, 0x0000                  // s1 = ulx
        lli     s2, 0x0000                  // s2 = uly
        lli     s3, 0x0002                  // s3 = width
        lli     s4, 0x0002                  // s4 = height
        li      s5, Color.high.YELLOW       // s5 = color
        jal     Render.draw_rectangle_
        lli     s6, OS.FALSE                // s6 = enable_alpha
        lli     t0, 0x0001                  // t0 = display off
        sw      t0, 0x007C(v0)              // turn off dpad direction indicator initially
        lw      t0, 0x0028(sp)              // t0 = dpad object reference
        sw      v0, 0x0030(t0)              // save dpad direction indicator reference
        lw      t0, 0x0074(t0)              // t0 = dpad image struct
        lwc1    f0, 0x0058(t0)              // f0 = dpad X, floating point
        trunc.w.s f0, f0                    // f0 = dpad X, word
        mfc1    t1, f0                      // t1 = dpad X
        addiu   t1, t1, 0x0003              // t1 = ulx for dpad-left
        sh      t1, 0x0058(v0)              // store ulx for dpad-left
        addiu   t1, t1, 0x0004              // t1 = ulx for dpad-up and dpad-down
        sh      t1, 0x0050(v0)              // store ulx for dpad-up
        sh      t1, 0x0054(v0)              // store ulx for dpad-down
        addiu   t1, t1, 0x0004              // t1 = ulx for dpad-right
        sh      t1, 0x005C(v0)              // store ulx for dpad-right
        lwc1    f0, 0x005C(t0)              // f0 = dpad Y, floating point
        trunc.w.s f0, f0                    // f0 = dpad Y, word
        mfc1    t1, f0                      // t1 = dpad Y
        addiu   t1, t1, 0x0003              // t1 = uly for dpad-up
        sh      t1, 0x0052(v0)              // store uly for dpad-up
        addiu   t1, t1, 0x0004              // t1 = uly for dpad-left and dpad-right
        sh      t1, 0x005A(v0)              // store uly for dpad-left
        sh      t1, 0x005E(v0)              // store uly for dpad-right
        addiu   t1, t1, 0x0004              // t1 = uly for dpad-down
        sh      t1, 0x0056(v0)              // store uly for dpad-down

        lw      t0, 0x000C(sp)              // t0 = number of panels remaining
        addiu   t0, t0, -0x0001             // ~
        beqz    t0, _end                    // if no more panels remaining, skip to end
        sw      t0, 0x000C(sp)              // save number of panels remaining

        lw      t0, 0x0014(sp)              // t0 = X padding
        lw      t1, 0x0018(sp)              // t1 = panel offset
        addu    t0, t0, t1                  // t0 = X position of next panel
        sw      t0, 0x0014(sp)              // save next panel's X position
        lw      s4, 0x001C(sp)              // s4 = offset in control object reference for panel
        addiu   s4, s4, 0x0004              // s4 = offset for next panel's control object reference
        sw      s4, 0x001C(sp)              // save s4
        b       _add_dpad_image             // add next image
        nop

        _end:
        // In Training, if human is not 1p, then we may need to swap some references
        lw      a0, 0x0008(sp)              // a0 = offset in css_player_structs = 8 for training
        addiu   a0, a0, -0x0008             // a0 = 0 if training
        bnez    a0, _portraits              // if not training, skip
        lw      t0, 0x0024(sp)              // t0 = control object reference
        lw      t1, 0x0030(t0)              // t1 = dpad object 1
        lw      t3, 0x0084(t1)              // t0 = css player struct
        lw      t5, 0x0000(t3)              // t5 = cursor object pointer - 0 if CPU
        bnez    t5, _portraits              // if first css player struct element is not the CPU, skip
        lw      t5, 0x0074(t1)              // t5 = dpad 1 image pointer
        lw      t2, 0x0034(t0)              // t2 = dpad object 2
        lw      t4, 0x0084(t2)              // t4 = css player struct
        lw      t6, 0x0074(t2)              // t5 = dpad 2 image pointer
        sw      t4, 0x0084(t1)              // swap css player struct pointers
        sw      t3, 0x0084(t2)              // ~
        addiu   t3, t3, -0x0004             // t3 = normalized css player struct
        addiu   t4, t4, -0x0004             // t4 = normalized css player struct
        sw      t4, 0x0048(t1)              // swap normalized css player struct pointers
        sw      t3, 0x0048(t2)              // ~

        _portraits:
        jal     draw_portraits_
        lli     a0, OS.FALSE                // a0 = 12cb mode flag

        jal     CharacterSelectDebugMenu.init_debug_menu_
        lw      a0, 0x0008(sp)              // a0 = offset in css_player_structs

        lw      a0, 0x0008(sp)              // a0 = offset in css_player_structs = 0 for VS
        bnez    a0, _return                 // skip remaining stock and count indicators if not VS
        nop

        Render.register_routine(update_stock_icon_and_count_indicators_)
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
        lui     t0, 0x8014                  // t0 = stock count
        lw      t0, 0xBD80(t0)              // ~
        sw      t0, 0x0070(a0)              // initialize previous num_stocks
        sw      r0, 0x0084(v0)              // set mode to VS
        lw      t1, 0x0024(sp)              // t1 = control object
        sw      v0, 0x0044(t1)              // save stock icon and count indicators control object

        _return:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This hook runs when a new character ID is hovered over.
    // We'll use it to toggle/update the variant indicator.
    scope character_change_: {
        // VS
        OS.patch_start(0x136DC8, 0x80138B48)
        jal     character_change_._vs
        sw      t0, 0x0048(a3)              // original line 2
        _return_vs:
        OS.patch_end()
        // 1P
        OS.patch_start(0x13F43C, 0x8013723C)
        jal     character_change_._1p
        sw      v0, 0x0020(v1)              // original line 1
        nop
        OS.patch_end()
        // Training
        OS.patch_start(0x1455A4, 0x80135FC4)
        jal     character_change_._training
        sw      a2, 0x0048(v1)              // original line 1
        nop
        OS.patch_end()
        // Bonus
        OS.patch_start(0x14BD0C, 0x80135CDC)
        jal     character_change_._bonus
        sw      v0, 0x0020(v1)              // original line 1
        nop
        OS.patch_end()

        _vs:
        // t0 = new character ID
        // a3 = css player struct
        // a0 = panel index
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~

        or      a1, r0, a0                  // a1 = panel index
        jal     draw_variant_indicator_
        or      a0, r0, t0                  // a0 = character ID

        jal     0x80136128                  // original line 1 - set character model
        lw      a0, 0x0008(sp)              // a0 = panel index

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

        _1p:
        // v0 = new character ID
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        lli     a1, 0x0000                  // a1 = panel index (only 1)
        jal     draw_variant_indicator_
        or      a0, r0, v0                  // a0 = character ID

        jal     0x80135804                  // original line 2 - set character model
        lw      a0, 0x0028(sp)              // original line 3, adjusted for sp

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

        _training:
        // a2 = new character ID
        // v1 = css player struct
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        lw      a1, 0x0080(v1)              // a1 = panel index
        jal     draw_variant_indicator_
        or      a0, r0, a2                  // a0 = character ID

        jal     0x80133E30                  // original line 2 - set character model
        lw      a0, 0x0030(sp)              // original line 3, adjusted for sp

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

        _bonus:
        // v0 = new character ID
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        lli     a1, 0x0000                  // a1 = panel index (only 1)
        jal     draw_variant_indicator_
        or      a0, r0, v0                  // a0 = character ID

        jal     0x8013476C                  // original line 2 - set character model
        lw      a0, 0x0028(sp)              // original line 3, adjusted for sp

        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra
        nop

    }

    // @ Description
    // Draws the variant icons and toggles the dpad
    scope draw_variant_indicator_: {
        // a0 = character id
        // a1 = panel index
        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _begin                  // if not 12cb mode, draw variant indicator
        nop                                 // otherwise, return
        lli     t0, Character.id.NONE
        addiu   t2, r0, -0x0001             // t2 = -1
        beql    a0, t0, pc() + 8            // if no character, then set portrait_id to -1
        sw      t2, 0x00B4(a3)              // save portrait_id
        jr      ra
        nop

        _begin:
        // first, destroy existing indicator icons
        li      t2, render_control_object
        lw      t2, 0x0000(t2)              // t2 = render control object
        sll     t0, a1, 0x0002              // t0 = offset to dpad object
        addu    t2, t2, t0                  // t2 = dpad object
        lw      t2, 0x0030(t2)              // ~
        lw      t3, 0x0034(t2)              // t3 = variant icons object reference
        beqz    t3, _check_for_variants     // if there is not currently any variant icons displayed, skip
        nop

        sw      r0, 0x0034(t2)              // 0 out variant icons object reference
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~

        jal     Render.DESTROY_OBJECT_
        or      a0, r0, t3                  // a0 = variant icons object struct

        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        _check_for_variants:
        li      at, Character.variant_original.table
        sll     a0, a0, 0x0002              // a0 = offset in variant_original table
        addu    at, at, a0                  // at = address of original character id
        lw      a0, 0x0000(at)              // a0 = character_id of hovered portrait

        li      t0, 0x1C1C1C1C              // t0 = mask for no variants
        li      at, Character.variants.table// at = variant table
        sll     t1, a0, 0x0002              // t1 = character variant array index
        addu    at, at, t1                  // at = character variant array
        lw      t1, 0x0000(at)              // t1 = character variants
        beq     t0, t1, _end                // if there are no variants, skip
        lli     t4, 0x0001                  // t4 = 1 (dpad will be set to not display)

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~

        // Create the variant icons object
        lli     a0, 0x0000                  // a0 = routine (Render.NOOP)
        li      a1, Render.TEXTURE_RENDER_  // a1 = display list routine
        lbu     a2, 0x000D(t2)              // a2 = room
        lbu     a3, 0x000C(t2)              // a3 = group
        jal     Render.create_display_object_
        nop

        lw      a0, 0x000C(sp)              // t2 = dpad object
        sw      v0, 0x0034(a0)              // save reference to variant icon object
        lw      at, 0x0038(a0)              // at = -1 if display on, 0 if not
        sw      at, 0x0038(v0)              // set initial display flag based on dpad object

        // Now, check each entry and add the variant icon as needed
        lw      at, 0x0010(sp)              // at = character variant array

        // D-UP
        lbu     a1, 0x0000(at)              // a1 = variant id
        lli     t4, Character.id.NONE       // t4 = Character.id.NONE
        beq     a1, t4, _d_down             // if no variant, skip
        nop

        jal     draw_variant_icon_
        lli     a2, 0x0000                  // a2 = up

        _d_down:
        lbu     a1, 0x0001(at)              // a1 = variant id
        lli     t4, Character.id.NONE       // t4 = Character.id.NONE
        beq     a1, t4, _d_left             // if no variant, skip
        nop

        jal     draw_variant_icon_
        lli     a2, 0x0001                  // a2 = down

        _d_left:
        lbu     a1, 0x0002(at)              // a1 = variant id
        lli     t4, Character.id.NONE       // t4 = Character.id.NONE
        beq     a1, t4, _d_right            // if no variant, skip
        nop

        jal     draw_variant_icon_
        lli     a2, 0x0002                  // a2 = left

        _d_right:
        lbu     a1, 0x0003(at)              // a1 = variant id
        lli     t4, Character.id.NONE       // t4 = Character.id.NONE
        beq     a1, t4, _finish             // if no variant, skip
        nop

        jal     draw_variant_icon_
        lli     a2, 0x0003                  // a2 = right

        _finish:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        lli     t4, 0x0000                  // t4 = 0 (dpad will be displayed)

        _end:
        lw      t0, 0x0030(t2)              // t0 = dpad direction indicator object
        sw      t4, 0x007C(t0)              // update dpad direction indicator display
        jr      ra
        sw      t4, 0x007C(t2)              // update dpad display
    }

	scope VARIANT_ICON_OFFSET {
		constant POLYGON(0x13A8)
		constant E(0x03B8)
		constant J(0x0558)
		constant METAL(0x2448 + 0x10)
		constant PIANO(0x2528 + 0x10)
		constant GBOWSER(0x2608 + 0x10)
		constant SSONIC(0x26E8 + 0x10)
		constant MASTER_HAND(0x27F0 + 0x10)
	}

    // @ Description
    // This adds variant icons (stock icons/flags) to the dpad image
    // @ Arguments
    // a0 - dpad object RAM address
    // a1 - modifier id (or variant_type for UP)
    // a2 - direction (0 = up, 1 = down, 2 = left, 3 = right)
    scope draw_variant_icon_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // ~
        sw      a1, 0x0014(sp)              // ~
        sw      a2, 0x0018(sp)              // ~
        sw      at, 0x001C(sp)              // ~

        lw      t1, 0x0074(a0)              // t1 = dpad image struct
        lw      t1, 0x0058(t1)              // t1 = dpad X position
        sw      t1, 0x0020(sp)              // save X position for easy reference
        lui     t1, 0x3F20                  // t1 = scale for flags (0.625)
        sw      t1, 0x0024(sp)              // save scale for flags

        li      t1, Character.variant_type.table
        addu    t1, t1, a1
        lbu     t1, 0x0000(t1)              // t0 = variant type
        li      at, Render.file_pointer_2   // at = CSS images file
        lw      at, 0x0000(at)              // ~
        lli     t2, Character.variant_type.J
        beql    t1, t2, _draw_icon          // if a J variant, then draw J flag
        addiu   a1, at, VARIANT_ICON_OFFSET.J // a1 = J flag footer struct
        lli     t2, Character.variant_type.E
        beql    t1, t2, _draw_icon          // if an E variant, then draw E flag
        addiu   a1, at, VARIANT_ICON_OFFSET.E // a1 = E flag footer struct

        // if we're here, then we will use the character's stock icon
        lui     t2, 0x3F80                  // t2 = scale for stock icons (1.0)
        sw      t2, 0x0024(sp)              // save scale for stock icons

        lli     t2, Character.variant_type.POLYGON
        beql    t1, t2, _draw_icon          // if a polygon, then draw polygon icon from our file instead
        addiu   a1, at, 0x13A8              // a1 = polygon icon footer struct TODO: make offset a constant
        lli     t2, Character.id.METAL
        beql    a1, t2, _draw_icon          // If METAL, then draw METAL stock icon
        addiu   a1, at, VARIANT_ICON_OFFSET.METAL // a1 = METAL footer struct
        lli     t2, Character.id.GBOWSER
        beql    a1, t2, _draw_icon          // If GBOWSER, then draw GBOWSER stock icon
        addiu   a1, at, VARIANT_ICON_OFFSET.GBOWSER // a1 = GBOWSER footer struct
        lli     t2, Character.id.PIANO
        beql    a1, t2, _draw_icon          // If PIANO, then draw PIANO stock icon
        addiu   a1, at, VARIANT_ICON_OFFSET.PIANO // a1 = PIANO footer struct
        lli     t2, Character.id.SSONIC
        beql    a1, t2, _draw_icon          // If SSONIC, then draw SSONIC stock icon
        addiu   a1, at, VARIANT_ICON_OFFSET.SSONIC // a1 = SSONIC footer struct

        // If here, GDK. Loading stock icon from character struct
        li      t1, 0x80116E10              // t1 = main character struct table
		lli     t2, Character.id.DK
        sll     t2, t2, 0x0002              // t2 = a1 * 4 (offset in struct table)
        // sll     t2, a1, 0x0002              // t2 = a1 * 4 (offset in struct table)
        addu    t1, t1, t2                  // t1 = pointer to character struct
        lw      t1, 0x0000(t1)              // t1 = character struct
        lw      t2, 0x0028(t1)              // t2 = main character file address pointer
        lw      t2, 0x0000(t2)              // t2 = main character file address
        beqz    t2, _end
        lw      t1, 0x0060(t1)              // t1 = offset to attribute data
        addu    t1, t2, t1                  // t1 = attribute data address
        lw      t1, 0x0340(t1)              // t1 = pointer to stock icon footer address
        lw      a1, 0x0000(t1)              // a1 = stock icon footer address
        b       _draw_icon
        nop

        _draw_icon:
        lw      a0, 0x0034(a0)              // a0 = RAM address of object block
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      a1, 0x0024(sp)              // a1 = scale
        sw      a1, 0x0018(v0)              // save X scale
        sw      a1, 0x001C(v0)              // save Y scale

        lwc1    f0, 0x0020(sp)              // a1 = X position
        lui     a2, 0x4331                  // a1 = Y position
        mtc1    a2, f2
        lw      at, 0x0018(sp)              // at = direction
        lui     t1, 0x4080                  // t1 = X adjustment (4)
        lui     t2, 0x4080                  // t2 = Y adjustment (4)
        beqzl   at, pc() + 8                // adjust t2 if direction = up
        lui     t2, 0xC110                  // t2 = Y adjustment (-9)
        addiu   at, at, -0x0001
        beqzl   at, pc() + 8                // adjust t2 if direction = down
        lui     t2, 0x4160                  // t2 = Y adjustment (14)
        addiu   at, at, -0x0001
        beqzl   at, pc() + 8                // adjust t1 if direction = left
        lui     t1, 0xC120                  // t1 = X adjustment (-10)
        addiu   at, at, -0x0001
        beqzl   at, pc() + 8                // adjust t1 if direction = right
        lui     t1, 0x4180                  // t1 = X adjustment (16)
        mtc1    t1, f4
        add.s   f0, f0, f4
        mtc1    t2, f4
        add.s   f2, f2, f4
        swc1    f0, 0x0058(v0)              // set X position
        swc1    f2, 0x005C(v0)              // set Y position

        lli     a1, 0x0201
        sh      a1, 0x0024(v0)              // turn on blur

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a1, 0x0014(sp)              // ~
        lw      a2, 0x0018(sp)              // ~
        lw      at, 0x001C(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space
        jr      ra
        nop
    }

    // @ Description
    // This adds/updates variant-related indicators to the screen.
    scope update_variant_indicators_: {
        // a0 = control object
        // 0x0030(a0) - 0x003C(a0) = pointers to dpad image objects (0 if non-existent)
        OS.save_registers()
        // a0 => 0x0010(sp)

        lli     s0, 0x0000                  // s0 = panel index = start at 0
        addiu   s1, a0, 0x0030              // s1 = address of first dpad image object pointer

        _loop:
        lw      t0, 0x0000(s1)              // t0 = dpad image object address
        beqz    t0, _end                    // if 0, then no more panels
        nop
        lw      t1, 0x0084(t0)              // t1 = pointer to css player struct
        lw      t2, 0x0034(t0)              // t2 = pointer to variant icons object
        lw      t3, 0x0048(t0)              // t3 = normalized pointer to css player struct (for 0x50 and higher offsets)

        lw      t4, 0x0048(t3)              // t4 = char_id
        lli     t5, Character.id.NONE
        lli     t6, 0x0001                  // t6 = 1 (hide dpad)
        beql    t4, t5, pc() + 8            // if no character selected, hide the dpad
        sw      t6, 0x007C(t0)              // this hides the dpad

        lw      t4, 0x003C(t0)              // t4 = previous selected flag value
        lw      t5, 0x0058(t3)              // t5 = current selected flag value
        beq     t4, t5, _flag_check         // if the selected status has changed this frame,
        sw      t5, 0x003C(t0)              // then we'll need to handle

        // if player is selected, hide the dpad
        lw      t4, 0x0030(t0)              // t4 = direction indicator object
        sw      t5, 0x007C(t4)              // sets display of direction indicator object
        bnez    t5, _flag_check             // if t5 = 1 (selected), then we can skip ahead and hide the dpad
        sw      t5, 0x007C(t0)              // this hides the dpad

        // we need to check if the variant indicators should be shown
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      s0, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~

        lw      a0, 0x0040(t0)              // a0 = regional flag object
        beqz    a0, _draw_variant_indicator
        sw      r0, 0x0040(t0)              // clear regional flag object reference
        jal     Render.DESTROY_OBJECT_
        nop

        _draw_variant_indicator:
        li      t3, render_control_object
        lw      t3, 0x0000(t3)              // t3 = render control object
        lw      t6, 0x0040(t3)              // t6 = base css player struct address
        li      t5, CSS_PLAYER_STRUCT_TRAINING
        lw      a1, 0x0004(sp)              // a1 = panel index
        lw      t1, 0x000C(sp)              // t1 = pointer to css player struct
        beql    t5, t6, pc() + 8            // if TRAINING, panel index is based on human/CPU
        lw      a1, 0x0080(t1)              // a1 = HUMAN = 0, CPU = 1

        lw      a0, 0x0048(t1)              // a0 = character index
        jal     draw_variant_indicator_
        nop

        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        b       _next
        nop

        // here, check if flag should be drawn
        _flag_check:
        // this little block makes sure the display is correct when a controller is unplugged
        lw      a0, 0x0034(t0)              // a0 = variant icons object
        beqz    a0, _check_selected         // skip if no variant icons object
        lli     a1, 0x0001                  // a1 = 1 (display off)
        lw      t5, 0x0048(t1)              // t5 = character index
        lli     t4, Character.id.NONE
        beql    t5, t4, _next               // if no character selected, skip and turn off variant icons
        sw      a1, 0x007C(a0)              // turn off display of variant icons object

        _check_selected:
        lw      t4, 0x003C(t0)              // t4 = selected flag value
        beqz    t4, _next                   // skip if not selected
        nop
        bnezl   a0, pc() + 8                // if there is a variant icons object, turn its display off
        sw      a1, 0x007C(a0)              // turn off display of variant icons object
        lw      a0, 0x0048(t1)              // a0 = character index
        li      a1, Character.variant_type.table
        addu    a1, a1, a0                  // a1 = variant type
        lbu     a1, 0x0000(a1)              // ~
        lli     a0, Character.variant_type.J
        beql    a1, a0, _draw_flag          // if selected char is a J variant, draw J flag
        lli     a0, 0x0558                  // a0 = j flag offset TODO: make constant
        lli     a0, Character.variant_type.E
        beql    a1, a0, _draw_flag          // if selected char is a J variant, draw J flag
        lli     a0, 0x03B8                  // a0 = e flag offset TODO: make constant

        // if we're here, there should be no flag... let's ensure there isn't any!
        lw      a0, 0x0040(t0)              // a0 = regional flag object
        beqz    a0, _next
        nop

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      s0, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~

        jal     Render.DESTROY_OBJECT_
        sw      r0, 0x0040(t0)              // clear regional flag object reference

        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        b       _next
        addiu   sp, sp, 0x0010              // deallocate stack space

        _draw_flag:
        lw      t1, 0x0040(t0)              // t1 = flag object pointer
        bnez    t1, _next                   // skip if flag object defined already
        nop

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      s0, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      t0, 0x000C(sp)              // ~

        li      a2, Render.file_pointer_2   // a2 = pointer to CSS images file start address
        lw      a2, 0x0000(a2)              // a2 = base file address
        addu    a2, a2, a0                  // a2 = pointer to flag image footer
        lbu     a0, 0x000D(t0)              // a0 = room
        lbu     a1, 0x000C(t0)              // a1 = group
        lli     a3, 0x0000                  // a3 = routine (Render.NOOP)
        lw      t1, 0x0074(t0)              // t1 = dpad image struct
        lwc1    f0, 0x0058(t1)              // f0 = ulx
        li      t3, render_control_object
        lw      t3, 0x0000(t3)              // t3 = render control object
        lw      t6, 0x0040(t3)              // t6 = base css player struct address
        li      t5, CSS_PLAYER_STRUCT
        bne     t5, t6, pc() + 0x10         // if not on VS, then we don't need to adjust X
        lui     t1, 0xC100                  // t1 = -8
        mtc1    t1, f2                      // f2 = -8
        add.s   f0, f0, f2                  // f0 = ulx
        mfc1    s1, f0                      // s1 = ulx
        lui     s2, 0x433F                  // s2 = uly
        lli     s3, 0x0000                  // s3 = color
        lli     s4, 0x0000                  // s4 = palette
        jal     Render.draw_texture_
        lui     s5, 0x3F80                  // s5 = scale

        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        lw      t0, 0x000C(sp)              // ~
        addiu   sp, sp, 0x0010              // deallocate stack space

        sw      v0, 0x0040(t0)              // save reference to flag object

        _next:
        // ensure the direction indicator is correctly positioned
        lw      t0, 0x0000(s1)              // t0 = dpad image object address
        lw      t4, 0x0048(t0)              // t4 = normalized css player struct
        lw      t2, 0x0080(t4)              // t2 = player port index
        li      t1, variant_offset          // t1 = address of variant_offset array
        addu    t1, t1, t2                  // t1 = address of variant_offset for port
        lbu     t1, 0x0000(t1)              // t1 = variant_offset
        addiu   t3, r0, -0x0001             // t3 = -1
        bne     t2, t3, _onscreen           // if token is held by this port, then render rectangle onscreen
        nop                                 // if no token held by this port, we need to check a few more conditions

        // if no character is selected AND it's a CPU, then skip forcing offscreen
        lw      t1, 0x0058(t4)              // t1 = 1 if character is selected
        bnezl   t1, _offscreen              // if character is selected, render offscreen
        lw      t0, 0x0030(t0)              // t0 = direction indicator object address
        lw      t1, 0x0084(t4)              // t1 = MAN = 0, CPU = 1, Closed = 2
        addiu   t1, t1, -0x0001             // t1 = 0 if CPU
        bnezl   t1, _offscreen              // if not a CPU panel, render offscreen
        lw      t0, 0x0030(t0)              // t0 = direction indicator object address

        // if we're here, skip updating since it's held by another port and will be handled by that port's dpad object
        b       _loop_check
        nop

        _onscreen:
        li      t3, render_control_object
        lw      t3, 0x0000(t3)              // t3 = render control object
        lw      t6, 0x0040(t3)              // t6 = base css player struct address
        li      t5, CSS_PLAYER_STRUCT       // t5 = VS CSS_PLAYER_STRUCT address
        beql    t6, t5, _onscreen_2         // on VS, port index is dpad index
        sll     t2, t2, 0x0002              // t2 = offset to dpad object based on port

        li      t5, CSS_PLAYER_STRUCT_TRAINING
        bnel    t6, t5, _onscreen_2         // on 1P and BONUS, dpad index is always 0
        lli     t2, 0x0000                  // t2 = offset to dpad object

        // For Training, the CPU comes first in the css player struct if the human is not port 1
        lli     t5, 0x0000                  // ~
        bnezl   t2, pc() + 8                // t5 = 0 or 1
        lli     t5, 0x0001                  // ~
        lui     t0, 0x8014                  // t0 = port index of CPU
        lw      t0, 0x8898(t0)              // ~
        lli     t2, 0x0000                  // t2 = offset to dpad object
        beql    t5, t0, pc() + 2            // if port index equals port index of CPU, return 1
        lli     t2, 0x0001                  // t2 = offset to dpad object
        sll     t2, t2, 0x0002              // ~

        _onscreen_2:
        addu    t2, t3, t2                  // t2 = dpad object
        lw      t2, 0x0030(t2)              // ~
        lw      t0, 0x0030(t2)              // t0 = direction indicator object address
        beqz    t1, _offscreen              // if variant_offset is 0, then render rectangle offscreen
        addiu   t1, t1, -0x0001             // else, get the position and set it
        addiu   t2, t0, 0x0050              // t2 = offset to positions by direction
        sll     t1, t1, 0x0002              // t1 = offset to positions for direction
        addu    t1, t1, t2                  // t1 = positions
        lhu     t2, 0x0000(t1)              // t2 = X
        sw      t2, 0x0030(t0)              // store X
        lhu     t2, 0x0002(t1)              // t2 = Y
        sw      t2, 0x0034(t0)              // store Y

        b       _loop_check
        nop

        _offscreen:
        sw      r0, 0x0030(t0)              // store X position as 0
        sw      r0, 0x0034(t0)              // store Y position as 0

        _loop_check:
        sltiu   t0, s0, 0x0003              // t0 = 1 if we need to keep looking
        beqz    t0, _end
        addiu   s0, s0, 0x0001              // s0++
        b       _loop
        addiu   s1, s1, 0x0004              // s1++

        _end:
        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // This adds/updates stock icons and stocks remaining count indicators to the panels.
    // TODO:
    // - 12cb
    //   - show modifier icons on portraits, e.g. mushrooms, cloak, starting stocks
    scope update_stock_icon_and_count_indicators_: {
        // a0 = control object
        // 0x0030(a0) = p1 stocks remaining object (0 if non-existent)
        // 0x0034(a0) = p1 previous portrait_id
        // 0x0035(a0) = p1 previous character_id
        // 0x0036(a0) = p1 previous stock mode
        // 0x0037(a0) = p1 previous char selected state
        // 0x0038(a0) = p1 previous costume_id
        // 0x003C(a0) = p1 yellow rectangle object (0 if non-existent)
        // 0x0040(a0) = p2 stocks remaining object (0 if non-existent)
        // 0x0044(a0) = p2 previous portrait_id
        // 0x0045(a0) = p2 previous character_id
        // 0x0046(a0) = p2 previous stock mode
        // 0x0047(a0) = p2 previous char selected state
        // 0x0048(a0) = p2 previous costume_id
        // 0x004C(a0) = p2 yellow rectangle object (0 if non-existent)
        // 0x0050(a0) = p3 stocks remaining object (0 if non-existent)
        // 0x0054(a0) = p3 previous portrait_id
        // 0x0055(a0) = p3 previous character_id
        // 0x0056(a0) = p3 previous stock mode
        // 0x0057(a0) = p3 previous char selected state
        // 0x0058(a0) = p3 previous costume_id
        // 0x005C(a0) = p3 yellow rectangle object (0 if non-existent)
        // 0x0060(a0) = p4 stocks remaining object (0 if non-existent)
        // 0x0064(a0) = p4 previous portrait_id
        // 0x0065(a0) = p4 previous character_id
        // 0x0066(a0) = p4 previous stock mode
        // 0x0067(a0) = p4 previous char selected state
        // 0x0068(a0) = p4 previous costume_id
        // 0x006C(a0) = p4 yellow rectangle object (0 if non-existent)
        // 0x0070(a0) = previous num stocks
        // 0x0084(a0) = CSS mode: 12cb if 1, VS if 0
        OS.save_registers()
        // a0 => 0x0010(sp)

        lli     s0, 0x0000                  // s0 = panel index = start at 0
        addiu   s1, a0, 0x0030              // s1 = address of p1 stocks remaining object pointer
        li      s2, CharacterSelect.CSS_PLAYER_STRUCT // s2 = CSS player struct for p1
        li      s4, p1_char_stocks_remaining // s4 = p1 stocks remaining for char
        lw      t4, 0x0070(a0)              // t4 = previous num_stocks
        lui     t5, 0x8014                  // t5 = stock count
        lw      t5, 0xBD80(t5)              // ~
        sw      t5, 0x0070(a0)              // update previous num_stocks

        _loop:
        lbu     t1, 0x0004(s1)              // t1 = previous portrait_id
        lbu     t2, 0x0005(s1)              // t2 = previous character_id
        lw      s3, 0x0048(s2)              // s3 = selected character_id
        lw      a0, 0x0010(sp)              // a0 = control object
        lw      t3, 0x0084(a0)              // t3 = mode: 12cb if 1, VS if 0
        bnezl   t3, pc() + 8                // if 12cb, get the actual portrait_id, otherwise 0 is fine
        lw      t3, 0x00B4(s2)              // t3 = portrait_id

        li      t6, StockMode.stockmode_table
        sll     t7, s0, 0x0002              // t7 = offset to stock mode for panel
        addu    t6, t6, t7                  // t6 = address of stock mode for panel
        lw      t6, 0x0000(t6)              // t6 = stock mode
        lbu     t7, 0x0006(s1)              // t7 = previous stock mode

        lbu     t8, 0x0007(s1)              // t8 = previous char selected state
        lw      t9, 0x0088(s2)              // t9 = selected character_id (1 if selected, 0 if not)

        lbu     t0, 0x0008(s1)              // t0 = previous costume_id
        lw      a0, 0x004C(s2)              // a0 = selected costume_id

        sb      t3, 0x0004(s1)              // update previous portrait_id
        sb      s3, 0x0005(s1)              // update previous character_id
        sb      t6, 0x0006(s1)              // update previous stock mode
        sb      t9, 0x0007(s1)              // update previous char selected state
        sb      a0, 0x0008(s1)              // update previous costume_id

        bne     t1, t3, _handle             // if the portrait_id changed this frame, then handle
        nop
        bne     t2, s3, _handle             // if the character_id changed this frame, then handle
        nop
        bne     t6, t7, _handle             // if the stock mode changed this frame, then handle
        nop
        bne     t8, t9, _handle             // if the char selected state changed this frame, then handle
        nop
        bne     t0, a0, _handle             // if the costume_id changed this frame, then handle
        nop
        beq     t4, t5, _update_display     // if the num_stocks hasn't changes this frame, then skip creating
        nop

        _handle:
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object address
        beqz    a0, _draw_indicator         // if there's not an object, skip destroying it
        nop
        sw      r0, 0x0000(s1)              // clear out reference
        lw      v0, 0x000C(s1)              // v0 = yellow rectangle reference
        beqz    v0, _destroy_stocks_remaining_object // if no reference, skip destroying rectangle objects
        sw      a0, 0x0020(sp)              // save a0 (this is t0 from os.save_registers, which isn't important)

        // destroy right yellow rectangle first
        lw      a0, 0x006C(v0)              // a0 = right yellow rectangle reference
        sw      r0, 0x000C(s1)              // clear yellow rectangle object reference
        jal     Render.DESTROY_OBJECT_      // destroy object
        sw      v0, 0x0024(sp)              // save v0 (this is t1 from os.save_registers, which isn't important)
        // then destroy left yellow rectangle
        jal     Render.DESTROY_OBJECT_      // destroy object
        lw      a0, 0x0024(sp)              // a0 = yellow rectangle reference

        _destroy_stocks_remaining_object:
        jal     Render.DESTROY_OBJECT_      // destroy object
        lw      a0, 0x0020(sp)              // a0 = stocks remaining object

        _draw_indicator:
        li      t1, Character.id.NONE
        beq     t1, s3, _next               // skip drawing if no character displayed
        nop
        addiu   sp, sp,-0x0020              // allocate stack space
        sw      s0, 0x0004(sp)              // save registers
        sw      s1, 0x0008(sp)              // ~
        sw      s2, 0x000C(sp)              // ~
        sw      s3, 0x0010(sp)              // ~
        sw      s4, 0x0014(sp)              // ~

        lw      s0, 0x0004(sp)              // s0 = panel index
        lw      s1, 0x0008(sp)              // s1 = address of stocks remaining object pointer
        lbu     t7, 0x0006(s1)              // t7 = stock mode

        lw      t8, 0x0030(sp)              // t8 = control object
        lw      t8, 0x0084(t8)              // t8 = mode: 12cb if 1, VS if 0
        bnez    t8, _12cb                   // if 12cb, handle stock mode differently
        lw      t3, 0x00B4(s2)              // t3 = portrait_id

        beqz    t7, _start_draw             // if stock mode is default, skip
        lli     t6, StockMode.mode.LAST
        li      s5, StockMode.stock_count_table
        beql    t6, t7, pc() + 8            // if stock mode is last, then use previous count address
        addiu   s5, s5, StockMode.previous_stock_count_table - StockMode.stock_count_table
        addu    a2, s5, s0                  // a2 = address of stock count

        lb      t8, 0x0000(a2)              // t8 = stocks remaining
        addiu   t0, t8, 0x0001              // t0 = 0 if no stocks remaining
        lui     t5, 0x8014                  // t5 = upper address of stock count
        lw      t5, 0xBD80(t5)              // t5 = stock count
        beqzl   t0, pc() + 8                // if no stocks remaining, set to global stock count
        or      t8, t5, r0                  // t8 = stock count
        sltu    t7, t8, t5                  // t7 = 1 if stocks remaining < stocks count
        beqzl   t7, pc() + 8                // if stocks remaining >= stock count, then set to stock count
        or      t8, t5, r0                  // t8 = stock count
        sb      t8, 0x0000(a2)              // update stocks remaining (in case it was -1)
        b       _start_draw
        sw      t8, 0x0000(s4)              // store stocks remaining in our number holder address

        _12cb:
        li      s5, TwelveCharBattle.config.stocks_by_portrait_id
        addu    a2, s5, t3                  // a2 = address of stocks remaining for this portrait_id
        lb      t8, 0x0000(a2)              // t8 = stocks remaining
        sw      t8, 0x0000(s4)              // store stocks remaining in our number holder address

        _start_draw:
        // first, draw stocks remaining
        or      a2, r0, s4                  // a2 = address of number
        li      a3, arrow_state_routine_    // a3 = routine
        lw      t8, 0x0018(s2)              // t8 = panel object
        lw      t8, 0x0074(t8)              // t8 = panel image struct
        lwc1    f0, 0x0058(t8)              // f0 = panel ulx
        lh      t8, 0x0014(t8)              // t8 = panel width
        mtc1    t8, f2                      // f2 = panel width
        cvt.s.w f2, f2                      // f2 = panel width, floating point
        add.s   f0, f0, f2                  // f0 = urx
        lw      t0, 0x0008(sp)              // t0 = address of stocks remaining pointer
        lbu     t2, 0x0007(t0)              // t2 = char selected state
        beqzl   t2, _set_right_padding      // if no char selected, don't adjust for arrows
        lui     t8, 0xC080                  // t8 = right padding no arrows = -4, floating point
        lbu     t2, 0x0006(t0)              // t2 = stock mode
        lli     t1, StockMode.mode.MANUAL
        bnel    t2, t1, _set_right_padding  // if not in manual stock mode, don't adjust for arrows
        lui     t8, 0xC080                  // t8 = right padding no arrows = -4, floating point

        li      t1, TwelveCharBattle.twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb
        beqz    t1, _check_digits           // skip if not 12cb
        nop

        li      t1, TwelveCharBattle.config.status
        lw      t1, 0x0000(t1)              // t1 = 0 if not started
        lli     t2, TwelveCharBattle.config.STATUS_COMPLETE
        beql    t1, t2, _set_right_padding  // if 12cb is complete, don't draw arrows
        lui     t8, 0xC080                  // t8 = right padding no arrows = -4, floating point

        or      a0, t3, r0                  // a0 = portrait_id
        jal     TwelveCharBattle.was_portrait_played_
        or      a1, s0, r0                  // a1 = port
        sw      v0, 0x0020(sp)              // save v0 (this is t0 from os.save_registers, which isn't important)
        bnezl   v0, _set_right_padding      // if portrait has been played, don't draw arrows
        lui     t8, 0xC080                  // t8 = right padding no arrows = -4, floating point

        _check_digits:
        lw      t8, 0x0000(a2)              // t8 = number
        slti    t8, t8, 0x0009              // t8 = 1 if 1 digit, 0 if 2 digits
        beqzl   t8, _set_right_padding      // if 2 digits, then don't pad as much as 1
        lui     t8, 0xC0E0                  // t8 = right padding w/arrows 2 digits = -7, floating point
        lui     t8, 0xC120                  // t8 = right padding w/arrows 1 digit = -10, floating point
        _set_right_padding:
        mtc1    t8, f2                      // f2 = right padding
        add.s   f0, f0, f2                  // f0 = urx
        mfc1    s1, f0                      // s1 = urx
        lui     s2, 0x433F                  // s2 = uly
        addiu   s3, r0, -1                  // s3 = color (0xFFFFFFFF - Color.high.WHITE)
        lui     s4, 0x3F68                  // s4 = scale
        lli     s5, Render.alignment.RIGHT  // s5 = alignment
        lli     s6, Render.string_type.NUMBER // s6 = string type
        lli     s7, 0x0001                  // s7 = amount to adjust number (stocks remaining is 0-based)
        lli     a0, 0x38                    // a0 = room
        lli     a1, 0x13                    // a1 = group
        jal     Render.draw_string_
        lli     t8, OS.TRUE                 // t8 = blur

        lw      s1, 0x0008(sp)              // s1 = address of stocks remaining pointer
        sw      v0, 0x0000(s1)              // save reference to stocks remaining object
        sw      r0, 0x0084(v0)              // this will hold reference to left arrow image struct if relevant
        sw      s1, 0x0054(v0)              // this will hold reference to stock remaining object pointer address

        // set initial display state based on debug menu visibility
        li      t0, CharacterSelectDebugMenu.debug_control_object
        lw      t0, 0x0000(t0)              // t0 = debug control object
        lw      s0, 0x0004(sp)              // s0 = panel index
        sll     s0, s0, 0x0002              // s0 = offset for panel
        addu    t0, t0, s0                  // t0 = debug control object, offset for panel
        lw      t0, 0x0030(t0)              // t0 = debug button object
        beqzl   t0, _set_initial_display    // if it doesn't exist, set to hidden (button not initialized)
        addiu   at, r0, -0x0001             // at = -1 to set visible
        lw      at, 0x0044(t0)              // at = debug menu display state (0 = hidden, 1 = active)
        addiu   at, at, -0x0001             // at = -1 if menu is hidden, 0 if not
        _set_initial_display:
        sw      at, 0x0038(v0)              // set initial display state

        // next, draw stock icon
        or      a0, r0, v0                  // a0 = stocks remaining object

        lw      s3, 0x0010(sp)              // s3 = character_id

        lw      s2, 0x000C(sp)              // s2 = CSS player struct
        lw      t1, 0x0008(s2)              // t1 = player object
        lw      t1, 0x0084(t1)              // t1 = player struct
        lw      t1, 0x09C8(t1)              // t1 = attribute data address
        lw      t1, 0x0340(t1)              // t1 = pointer to stock icon footer address
        lw      a1, 0x0000(t1)              // a2 = stock icon footer address
        lw      t1, 0x0004(t1)              // t1 = base palette address
        sw      t1, 0x001C(sp)              // save base palette address

        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      s1, 0x0008(sp)              // ~
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object
        lw      t0, 0x0074(a0)              // t0 = first letter image struct
        lwc1    f0, 0x0058(t0)              // f0 = ulx of first letter
        lui     t1, 0xC190                  // t1 = -18
        mtc1    t1, f2                      // f2 = -18
        add.s   f0, f0, f2                  // f0 = ulx of stock icon
        swc1    f0, 0x0058(v0)              // update stock icon X position
        lui     t1, 0x433F                  // t1 = uly
        mtc1    t1, f0                      // f0 = uly
        swc1    f0, 0x005C(v0)              // update stock icon Y position
        lli     t0, 0x0201                  // t0 = render flags (blur)
        sh      t0, 0x0024(v0)              // save render flags
        lw      t0, 0x001C(sp)              // t0 = base palette address
        lw      s2, 0x000C(sp)              // s2 = CSS player struct
        lw      t1, 0x004C(s2)              // t1 = color index
        sll     t1, t1, 0x0002              // t1 = offset to palette
        addu    t0, t0, t1                  // t0 = selected palette address
        lw      t0, 0x0000(t0)              // t0 = selected palette
        sw      t0, 0x0030(v0)              // update palette

        // now draw "x" image
        li      t0, Render.file_pointer_3
        lw      t0, 0x0000(t0)              // t0 = base address of file 0x0024
        addiu   a1, t0, 0x0828              // a1 = "x" image address
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      s1, 0x0008(sp)              // ~
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object
        lw      t0, 0x0074(a0)              // t0 = first letter image struct
        lwc1    f0, 0x0058(t0)              // f0 = ulx of first letter
        lui     t1, 0xC110                  // t1 = -9
        mtc1    t1, f2                      // f2 = -9
        add.s   f0, f0, f2                  // f0 = ulx of stock icon
        swc1    f0, 0x0058(v0)              // update "x" image X position
        lui     t1, 0x4340                  // t1 = uly
        mtc1    t1, f0                      // f0 = uly
        swc1    f0, 0x005C(v0)              // update "x" image Y position
        lui     t0, 0x3F60                  // t0 = scale
        sw      t0, 0x0018(v0)              // update X scale
        sw      t0, 0x001C(v0)              // update Y scale
        lli     t0, 0x0201                  // t0 = render flags (blur)
        sh      t0, 0x0024(v0)              // save render flags
        lli     t0, 0x0401                  // t0 = image type (change to I8)
        sh      t0, 0x0040(v0)              // save image type

        lw      t0, 0x0008(sp)              // t0 = address of stocks remaining pointer
        lbu     t0, 0x0006(t0)              // t0 = stock mode
        lli     t1, StockMode.mode.MANUAL
        bne     t0, t1, _finish_draw        // if not in manual stock mode, don't draw arrows/dpad
        nop
        li      t1, TwelveCharBattle.twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb
        beqz    t1, _draw_arrows            // if not 12cb, draw arrows
        nop
        li      t1, TwelveCharBattle.config.status
        lw      t1, 0x0000(t1)              // t1 = 0 if not started
        addiu   t1, t1, -TwelveCharBattle.config.STATUS_COMPLETE
        beqz    t1, _finish_draw            // if the 12cb is complete, don't draw arrows/dpad
        lw      t0, 0x0020(sp)              // t0 = was_portrait_played_ result
        bnez    t0, _finish_draw            // if the portrait was played, don't draw arrows/dpad
        lw      t0, 0x0008(sp)              // t0 = address of stocks remaining pointer
        lbu     t2, 0x0007(t0)              // t2 = char selected state
        bnez    t2, _draw_arrows            // if char selected, draw arrows
        nop                                 // otherwise, draw dpad

        // draw dpad
        li      a1, Render.file_pointer_2   // a1 = pointer to CSS images file start address
        lw      a1, 0x0000(a1)              // a1 = base file address
        addiu   a1, a1, 0x0218              // a1 = address of d-pad image TODO: make constant
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      s1, 0x0008(sp)              // ~
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object
        lw      t0, 0x0074(a0)              // t0 = first letter image struct
        lwc1    f0, 0x0058(t0)              // f0 = ulx of first letter
        lui     t1, 0xC1DC                  // t1 = -27.5
        mtc1    t1, f2                      // f2 = -27.5
        add.s   f0, f0, f2                  // f0 = ulx
        swc1    f0, 0x0058(v0)              // update dpad image X position
        lui     t1, 0x4340                  // t1 = uly
        mtc1    t1, f0                      // f0 = uly
        swc1    f0, 0x005C(v0)              // update dpad image Y position
        lui     t0, 0x3F10                  // t0 = scale
        sw      t0, 0x0018(v0)              // update X scale
        sw      t0, 0x001C(v0)              // update Y scale
        lli     t0, 0x0201                  // t0 = render flags (blur)
        sh      t0, 0x0024(v0)              // save render flags

        // next, create blinking rectangle objects
        Render.draw_rectangle(0x38, 0x13, 1, 0xC4, 1, 1, Color.high.YELLOW, OS.FALSE)
        lw      s1, 0x0008(sp)              // s1 = stocks remaining object address
        sw      v0, 0x000C(s1)              // save rectangle reference
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object
        lw      t0, 0x0074(a0)              // t0 = first letter image struct
        lwc1    f0, 0x0058(t0)              // f0 = ulx of first letter
        lui     t1, 0xC1C8                  // t1 = -25
        mtc1    t1, f2                      // f2 = -25
        add.s   f0, f0, f2                  // f0 = ulx
        trunc.w.s f0, f0                    // f0 = ulx, decimal
        swc1    f0, 0x0030(v0)              // update yellow rectangle X position
        // next draw right rectangle
        Render.draw_rectangle(0x38, 0x13, 1, 0xC4, 1, 1, Color.high.YELLOW, OS.FALSE)
        lw      s1, 0x0008(sp)              // s1 = stocks remaining object address
        lw      t0, 0x000C(s1)              // t0 = left rectangle reference
        sw      v0, 0x006C(t0)              // save right rectangle reference
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object
        lw      t0, 0x0074(a0)              // t0 = first letter image struct
        lwc1    f0, 0x0058(t0)              // f0 = ulx of first letter
        lui     t1, 0xC1A0                  // t1 = -20
        mtc1    t1, f2                      // f2 = -20
        add.s   f0, f0, f2                  // f0 = ulx
        trunc.w.s f0, f0                    // f0 = ulx, decimal
        swc1    f0, 0x0030(v0)              // update yellow rectangle X position

        b       _finish_draw
        nop

        _draw_arrows:
        lw      t0, 0x0008(sp)              // t0 = address of stocks remaining pointer
        lbu     t2, 0x0007(t0)              // t2 = char selected state
        beqz    t2, _finish_draw            // if no char selected, don't draw arrows
        nop

        // now draw left arrow
        // file 0x11 is always the first file loaded
        li      a1, file_table              // a1 = file_table
        lw      a1, 0x0004(a1)              // a1 = base file 0x11 address
        lli     t0, 0xECE8                  // t0 = offset to left arrow
        addu    a1, a1, t0                  // a1 = address of left arrow image footer
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      s1, 0x0008(sp)              // ~
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object
        sw      v0, 0x0084(a0)              // save reference to arrow image struct
        lw      t8, 0x0018(s2)              // t8 = panel object
        lw      t8, 0x0074(t8)              // t8 = panel image struct
        lwc1    f0, 0x0058(t8)              // f0 = panel ulx
        lui     t8, 0x41A0                  // t8 = left padding = 20, floating point
        mtc1    t8, f2                      // f2 = left padding
        add.s   f0, f0, f2                  // f0 = ulx
        swc1    f0, 0x0058(v0)              // update left arrow image X position
        lui     t1, 0x4341                  // t1 = uly
        mtc1    t1, f0                      // f0 = uly
        swc1    f0, 0x005C(v0)              // update left arrow image Y position
        lui     t0, 0x3F20                  // t0 = scale
        sw      t0, 0x0018(v0)              // update X scale
        sw      t0, 0x001C(v0)              // update Y scale
        lli     t0, 0x0201                  // t0 = render flags (blur)
        sh      t0, 0x0024(v0)              // save render flags

        // now draw right arrow
        // file 0x11 is always the first file loaded
        li      a1, file_table              // a1 = file_table
        lw      a1, 0x0004(a1)              // a1 = base file 0x11 address
        lli     t0, 0xEDC8                  // t0 = offset to right arrow
        addu    a1, a1, t0                  // a1 = address of right arrow image footer
        jal     Render.TEXTURE_INIT_        // v0 = RAM address of texture struct
        addiu   sp, sp, -0x0030             // allocate stack space for TEXTURE_INIT_
        addiu   sp, sp, 0x0030              // restore stack space

        lw      t8, 0x0018(s2)              // t8 = panel object
        lw      t8, 0x0074(t8)              // t8 = panel image struct
        lwc1    f0, 0x0058(t8)              // f0 = panel ulx
        lh      t8, 0x0014(t8)              // t8 = panel width
        mtc1    t8, f2                      // f2 = panel width
        cvt.s.w f2, f2                      // f2 = panel width, floating point
        add.s   f0, f0, f2                  // f0 = urx
        lui     t8, 0xC0A0                  // t8 = right padding = -5, floating point
        mtc1    t8, f2                      // f2 = right padding
        add.s   f0, f0, f2                  // f0 = ulx
        swc1    f0, 0x0058(v0)              // update right arrow image X position
        lui     t1, 0x4341                  // t1 = uly
        mtc1    t1, f0                      // f0 = uly
        swc1    f0, 0x005C(v0)              // update right arrow image Y position
        lui     t0, 0x3F20                  // t0 = scale
        sw      t0, 0x0018(v0)              // update X scale
        sw      t0, 0x001C(v0)              // update Y scale
        lli     t0, 0x0201                  // t0 = render flags (blur)
        sh      t0, 0x0024(v0)              // save render flags

        _finish_draw:
        lw      s0, 0x0004(sp)              // restore registers
        lw      s1, 0x0008(sp)              // ~
        lw      s2, 0x000C(sp)              // ~
        lw      s3, 0x0010(sp)              // ~
        lw      s4, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        _update_display:
        // here, update display if the object exists
        lw      a0, 0x0010(sp)              // a0 = control object
        lw      t0, 0x0084(a0)              // t0 = mode: 12cb if 1, VS if 0
        bnez    t0, _next                   // skip if 12cb - always show regardless of stock mode
        lw      a0, 0x0000(s1)              // a0 = stocks remaining object address
        beqz    a0, _next                   // if there's not an object, skip updating display
        nop
        li      t0, StockMode.stockmode_table
        sll     t1, s0, 0x0002              // t1 = offset to stock mode for panel
        addu    t0, t0, t1                  // t0 = address of stock mode for panel
        lw      t0, 0x0000(t0)              // t0 = stock mode
        lli     t1, 0x0001                  // t1 = display off
        beqzl   t0, _next                   // if stock mode is default, turn off display
        sw      t1, 0x007C(a0)              // turn off display of stock indicators
        sw      r0, 0x007C(a0)              // otherwise, turn on display of stock indicators

        _next:
        sltiu   t8, s0, 0x0003              // t8 = 1 until we've looped through all panels
        beqz    t8, _end                    // if we just processed p4, then we're done
        addiu   s0, s0, 0x0001              // s0++
        addiu   s1, s1, 0x0010              // s1++
        addiu   s4, s4, 0x0004              // s4 = p2 stocks remaining for char
        b       _loop
        addiu   s2, s2, 0x00BC              // s2++

        _end:
        // update blink timer here so they don't get annoyingly out of sync
        li      t3, arrow_state_routine_.timer
        lw      t0, 0x0000(t3)              // t0 = timer
        addiu   t0, t0, 0x0001              // t0 = timer++
        sltiu   at, t0, 0x0014              // at = 1 if timer < 20, 0 otherwise
        beqzl   at, pc() + 8                // if timer past 20, reset
        lli     t0, 0x0000                  // t0 = 0 to reset timer to 0
        sw      t0, 0x0000(t3)              // update timer

        OS.restore_registers()
        jr      ra
        nop

        p1_char_stocks_remaining:; dw 0x00000000
        p2_char_stocks_remaining:; dw 0x00000000
        p3_char_stocks_remaining:; dw 0x00000000
        p4_char_stocks_remaining:; dw 0x00000000
    }

    // @ Description
    // Gives the stocks remaining indicator arrows blinking effects.
    // @ Arguments
    // a0 - stocks remaining object
    scope arrow_state_routine_: {
        // implement blink
        li      t3, timer                   // t3 = timer address
        lw      t0, 0x0000(t3)              // t0 = timer
        sltiu   t2, t0, 0x000B              // t2 = 1 if timer < 11, 0 otherwise

        lw      t0, 0x0084(a0)              // t0 = left arrow image struct
        beqz    t0, _check_rectangles       // if 0, then no arrows so skip
        lli     t1, 0x0201                  // t1 = render flags (blur)
        beqzl   t2, pc() + 8                // if in hide state, update render flags
        lli     t1, 0x0205                  // t1 = render flags (hide)
        sh      t1, 0x0024(t0)              // update render flags
        lw      t0, 0x0008(t0)              // t0 = right arrow image struct
        b       _end
        sh      t1, 0x0024(t0)              // update render flags

        _check_rectangles:
        lw      t0, 0x0054(a0)              // t0 = stocks remaining info array
        lw      t0, 0x000C(t0)              // t0 = left rectangle object, if it exists
        beqz    t0, _end                    // if 0, then no rectangles so skip
        lli     t1, 0x0000                  // t1 = display on
        beqzl   t2, pc() + 8                // if in hide state, update display flag
        lli     t1, 0x0001                  // t1 = display off
        sw      t1, 0x007C(t0)              // update display flag
        lw      t0, 0x006C(t0)              // t0 = right yellow rectangle
        sw      t1, 0x007C(t0)              // update display flag

        _end:
        jr      ra
        nop

        timer:
        dw 0
    }

    // @ Description
    // Checks if and handles when stock mode's arrow buttons are pressed
    // a0 - cursor object
    // a1 - ra to use if there is a press
    scope check_manual_stock_arrow_press_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // ~
        sw      a3, 0x0014(sp)              // ~

        li      t0, render_control_object
        lw      t0, 0x0000(t0)              // t0 = render control object
        li      t1, TwelveCharBattle.twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb
        beqzl   t1, pc() + 12               // if not 12cb, get at 0x0044 instead of 0x0034
        lw      t0, 0x0044(t0)              // t0 = remaining stocks control object
        lw      t0, 0x0034(t0)              // t0 = remaining stocks control object
        addiu   t0, t0, 0x0030              // t0 = address of first stocks remaining object
        sw      t0, 0x0018(sp)              // save stocks remaining object to stack

        sw      r0, 0x001C(sp)              // initialize panel index to 0

        _loop:
        // first check for left arrow press
        lw      t0, 0x0018(sp)              // t0 = address of stocks remaining object
        lw      t0, 0x0000(t0)              // t0 = stocks remaining object
        beqz    t0, _next                   // skip if not defined
        nop
        lw      a1, 0x0084(t0)              // a1 = left arrow object
        beqz    a1, _next                   // skip if not defined
        lli     a2, 0x0000                  // a2 = left padding
        jal     check_image_footer_press_   // v0 = 1 if button pressed, 0 if not
        lli     a3, 0x0008                  // a3 = right padding
        bnez    v0, _pressed                // if pressed, handle
        addiu   t0, r0, -0x0001             // t0 = -1 for left arrow

        // next check for right arrow press
        lw      t0, 0x0018(sp)              // t0 = address of stocks remaining object
        lw      t0, 0x0000(t0)              // t0 = stocks remaining object
        beqz    t0, _next                   // skip if not defined
        lli     a2, 0x0008                  // a2 = left padding
        lw      a1, 0x0084(t0)              // a1 = left arrow object
        lw      a1, 0x0008(a1)              // a1 = rigt arrow object
        jal     check_image_footer_press_   // v0 = 1 if button pressed, 0 if not
        lli     a3, 0x0000                  // a3 = right padding
        bnez    v0, _pressed                // if pressed, handle
        lli     t0, 0x0001                  // t0 = +1 for right arrow

        // not pressed, check next panel
        _next:
        lw      t0, 0x001C(sp)              // t0 = panel index
        sltiu   t1, t0, 0x0003              // t1 = 0 if no more panels to loop over
        beqz    t1, _end                    // checked everything, skip to end
        addiu   t0, t0, 0x0001              // t0++
        sw      t0, 0x001C(sp)              // update panel index
        lw      t0, 0x0018(sp)              // t0 = address of stocks remaining object
        addiu   t0, t0, 0x0010              // t0 = address of next stocks remaining object
        b       _loop
        sw      t0, 0x0018(sp)              // update address of stocks remaining object

        _pressed:
        lw      at, 0x000C(sp)              // at = new ra
        sw      at, 0x0004(sp)              // set new ra

        li      t1, TwelveCharBattle.twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb
        bnez    t1, _12cb_pressed           // if 12cb, update portrait table and remaining stocks
        nop

        // vs pressed
        li      t2, StockMode.stock_count_table
        b       _update_stocks_remaining
        lw      at, 0x001C(sp)              // at = panel index

        _12cb_pressed:
        lw      at, 0x0018(sp)              // t0 = address of stocks remaining object
        lbu     at, 0x0004(at)              // at = portrait_id
        li      t2, TwelveCharBattle.config.stocks_by_portrait_id

        _update_stocks_remaining:
        lw      a0, 0x0018(sp)              // a0 = address of stocks remaining object
        lw      a1, 0x001C(sp)              // a1 = panel index
        addu    a2, t2, at                  // a2 = stocks remaining address
        jal     update_remaining_stocks_
        or      a3, t0, r0                  // a3 = increment/decrement

        // if portrait_id was set to -1, reset the panel
        // this makes sure the animation switches to/from the defeated pose
        lw      at, 0x0018(sp)              // at = address of stocks remaining object
        lb      at, 0x0004(at)              // at = portrait_id
        bgez    at, _end                    // if portrait_id is not -1, skip updating panel
        lw      a0, 0x001C(sp)              // a0 = panel index
        li      a1, CharacterSelect.CSS_PLAYER_STRUCT
        bnezl   a0, pc() + 8                // if p2, adjust CSS player struct
        addiu   a1, a1, 0x00BC              // a1 = p2 CSS_PLAYER_STRUCT
        jal     TwelveCharBattle.update_character_panel_ // sync character model
        lli     a2, OS.FALSE                // a2 = don't play announcer

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // ~
        lw      a3, 0x0014(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Updates remaining stocks indicators
    // @ Arguments
    // a0 - address of stocks remaining object
    // a1 - panel index
    // a2 - stocks remaining address
    // a3 - -1/+1 = increment/decrement
    scope update_remaining_stocks_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers

        lb      t6, 0x0000(a2)              // t6 = stocks remaining

        lui     t4, 0x8014                  // t4 = (global) stock count
        lw      t4, 0xBD80(t4)              // ~

        li      t1, TwelveCharBattle.twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb, 0 if not
        addu    t4, t4, t1                  // t4 = (global) stock count, 1-based if 12cb

        addu    t3, t6, a3                  // t3 = stocks remaining, updated
        addu    t3, t3, t1                  // t3 = stocks remaining, 1-based if 12cb
        bltzl   t3, _update_stock_count     // if < 0, set to global stock count
        or      t3, t4, r0                  // set stock count to max
        addiu   t4, t4, 0x0001              // t4 = max stock count + 1
        sltu    t5, t3, t4                  // t5 = 0 if updated stocks remaining is too high
        beqzl   t5, _update_stock_count     // if higher than max, set to 0
        lli     t3, 0x0000                  // set stock count to 0

        _update_stock_count:
        subu    t3, t3, t1                  // t3 = stocks remaining, 0-based
        sb      t3, 0x0000(a2)              // update stock count
        addiu   at, r0, -0x0001             // at = -1
        sb      at, 0x0007(a0)              // set previous char selected state to -1 to trigger redraw

        beqz    t1, _play_fgm               // if not 12cb, skip updating 12cb remaining stocks
        nop
        bltzl   t3, pc() + 8                // if no stocks remaining...
        sb      at, 0x0004(a0)              // ...then set previous portrait_id to -1 to trigger character redraw
        bltzl   t6, pc() + 8                // if previously there were no stocks remaining...
        sb      at, 0x0004(a0)              // ...then set previous portrait_id to -1 to trigger character redraw
        subu    t3, t3, t6                  // t3 = t3 - t6 = difference in stock count
        li      t1, TwelveCharBattle.config.p1.stocks_remaining
        beqz    a1, _update_stocks_remaining // if p1, use p1 location
        nop                                 // otherwise, use p2
        li      t1, TwelveCharBattle.config.p2.stocks_remaining
        _update_stocks_remaining:
        lw      t2, 0x0000(t1)              // t2 = prior stocks remaining
        addu    t2, t2, t3                  // t2 = new stocks remaining
        sw      t2, 0x0000(t1)              // update stocks remaining

        _play_fgm:
        // play FGM
        jal     0x800269C0
        lli     a0, FGM.menu.TOGGLE         // a0 = FGM.menu.TOGGLE

        _end:
        lw      ra, 0x0004(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // Forces all remaining stock indicators to refresh
    scope refresh_stock_indicators_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // save registers
        sw      t1, 0x0008(sp)              // ~

        li      t0, CharacterSelect.render_control_object
        lw      t0, 0x0000(t0)              // t0 = render control object
        beqz    t0, _end                    // skip if control object not yet defined
        addiu   t1, r0, -0x0001             // t1 = -1
        lw      t0, 0x0034(t0)              // t0 = remaining stocks control object
        beqz    t0, _end                    // skip if control object not yet defined
        nop
        sb      t1, 0x0037(t0)              // set p1 previous char selected state to -1 to trigger redraw
        sb      t1, 0x0047(t0)              // set p2 previous char selected state to -1 to trigger redraw
        sb      t1, 0x0057(t0)              // set p3 previous char selected state to -1 to trigger redraw
        sb      t1, 0x0067(t0)              // set p4 previous char selected state to -1 to trigger redraw

        _end:
        lw      t0, 0x0004(sp)              // restore registers
        lw      t1, 0x0008(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        jr      ra
        nop
    }

    // @ Description
    // This checks if an area was pressed.
    // Heavily based on BACK press check at 0x80138218 (ROM 0x136498).
    // @ Parameters
    // a0 - cursor object
    // a1 - image ulx (float)
    // a2 - image width (int)
    // a3 - image uly (float)
    // 0x0010(sp) - image height (int)
    // @ Returns
    // v0 - 1 if pressed, 0 if not
    scope check_press_: {
        // copy BACK button press routine
        lw      v0, 0x0074(a0)              // v0 = cursor object image struct
        lui     at, 0x4040                  // at = 3 (y spacer)
        mtc1    at, f6                      // f6 = 3 (y spacer)
        lwc1    f4, 0x005C(v0)              // f4 = cursor uly
        mtc1    a3, f8                      // f4 = image uly
        add.s   f0, f4, f6                  // f0 = cursor y, adjusted
        lw      at, 0x0010(sp)              // at = image height
        c.lt.s  f0, f8                      // if (cursor uly < image uly), then return no press
        nop
        bc1t    _fail_y                     // return no press
        nop
        mtc1    at, f10                     // f10 = image height
        cvt.s.w f10, f10                    // f10 = image height, float
        add.s   f10, f10, f8                // f10 = image lry
        or      v1, r0, r0                  // v1 = 0 (ok so far)
        c.lt.s  f10, f0                     // if (cursor uly > image lry), then return no press
        nop
        bc1f    _pass_y                     // y check passed, proceed to x check
        nop
        _fail_y:
        beq     r0, r0, _end                // not over button, so exit
        or      v0, r0, r0                  // v0 = 0 (OS.FALSE)

        _pass_y:
        lui     at, 0x41A0                  // at = 20 (x spacer)
        lwc1    f16, 0x0058(v0)             // f16 = cursor ulx
        mtc1    at, f18                     // f18 = 20 (x spacer)
        mtc1    a1, f4                      // f4 = image ulx
        add.s   f0, f16, f18                // f10 = cursor ulx, adjusted
        or      at, r0, a2                  // at = image width
        or      v0, r0, r0                  // v0 = 0 (OS.FALSE)
        c.le.s  f4, f0                      // if (cursor ulx < image ulx), then return no press
        nop
        bc1f    _end                        // not over button, so exit
        nop
        mtc1    at, f6                      // f6 = image width
        cvt.s.w f6, f6                      // f6 = image width, float
        add.s   f6, f6, f4                  // f10 = image lrx
        nop
        c.le.s  f0, f6                      // if (cursor urx > image urx), then return no press
        nop
        bc1f    _end                        // not over button, so exit
        nop
        addiu   v0, r0, 0x0001              // over button!

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This checks if an image was pressed.
    // @ Parameters
    // a0 - cursor object
    // a1 - image object
    // @ Returns
    // v0 - 1 if image pressed, 0 if not
    scope check_image_press_: {
        beqzl   a1, _end                    // if image object is empty, return
        lli     v0, 0x0000                  // ...and set v0 to 0

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a1, 0x0008(sp)              // ~
        sw      a2, 0x000C(sp)              // ~
        sw      a3, 0x0010(sp)              // ~

        lli     a2, 0x0000                  // a2 = left padding = 0
        lli     a3, 0x0000                  // a3 = right padding = 0
        jal     check_image_footer_press_   // v0 = (bool) image pressed
        lw      a1, 0x0074(a1)              // a1 = image object image struct

        lw      ra, 0x0004(sp)              // restore registers
        lw      a1, 0x0008(sp)              // ~
        lw      a2, 0x000C(sp)              // ~
        lw      a3, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0020              // deallocate stack space

        _end:
        jr      ra
        nop
    }

    // @ Description
    // This checks if an image was pressed.
    // @ Parameters
    // a0 - cursor object
    // a1 - image footer struct
    // a2 - left padding
    // a3 - right padding
    // @ Returns
    // v0 - 1 if image pressed, 0 if not
    scope check_image_footer_press_: {
        beqzl   a1, _end                    // if image object is empty, return
        lli     v0, 0x0000                  // ...and set v0 to 0

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a1, 0x0020(sp)              // ~
        sw      a2, 0x0024(sp)              // ~
        sw      a3, 0x0028(sp)              // ~
        sw      t4, 0x002C(sp)              // ~

        lhu     t4, 0x0016(a1)              // t4 = image height
        sw      t4, 0x0010(sp)              // 0x0010(sp) = image height
        lhu     t4, 0x0014(a1)              // t4 = image width
        addu    t4, t4, a2                  // t4 = image width + left padding
        addu    t4, t4, a3                  // t4 = image width + left padding + right padding
        lw      a3, 0x005C(a1)              // a3 = image uly
        lwc1    f0, 0x0058(a1)              // f0 = image ulx
        mtc1    a2, f2                      // f2 = left padding
        cvt.s.w f2, f2                      // f2 = left padding, floating point
        sub.s   f0, f0, f2                  // f0 = image ulx - left padding
        mfc1    a1, f0                      // a1 = image ulx
        jal     check_press_                // v0 = (bool) image pressed
        or      a2, t4, r0                  // a2 = image width

        lw      ra, 0x0004(sp)              // restore registers
        lw      a1, 0x0020(sp)              // ~
        lw      a2, 0x0024(sp)              // ~
        lw      a3, 0x0028(sp)              // ~
        lw      t4, 0x002C(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Selects a random character for a human player
    // @ Arguments
    // a0 - port
    // TODO: 1p, Bonus, Training support?
    scope select_random_char_: {
        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // save registers
        sw      a0, 0x0008(sp)              // ~
        sw      s0, 0x000C(sp)              // ~
        sw      s1, 0x0010(sp)              // ~

        lli     t1, 0x00BC                  // t1 = size of VS CSS Panel Struct
        multu   t1, a0                      // mflo = offset to port's panel struct
        li      t0, CSS_PLAYER_STRUCT       // t0 = VS CSS Panel Struct, p1
        mflo    t1                          // t1 = offset to ports panel struct
        addu    s0, t0, t1                  // s0 = port's VS CSS Panel Struct (expected in get_random_char_id)
        sw      s0, 0x0014(sp)              // save panel struct to stack

        jal     get_random_char_id_
        or      s1, a0, r0                  // s1 = port (expected in get_random_char_id)

        lw      a0, 0x0008(sp)              // a0 = port
        lw      a1, 0x0014(sp)              // a1 = css panel struct

        // set up as selected
        sw      v0, 0x0048(a1)              // set char_id
        addiu   t1, r0, -0x0001             // t1 = -1
        sw      t1, 0x0080(a1)              // set held token ID
        lli     t1, 0x0004                  // t1 = 4
        sw      t1, 0x007C(a1)              // set ?
        lli     t1, 0x0001                  // t1 = 1
        sw      t1, 0x0058(a1)              // set selected flag
        sw      t1, 0x0088(a1)              // set selected flag

        // a0 - panel index
        // a1 - CSS player struct
        // a2 - play announcer? 1 = yes, 0 = no
        jal     TwelveCharBattle.update_character_panel_
        lli     a2, 0x0001                  // a2 = 1 (do play announcer)

        lw      a2, 0x0014(sp)              // a2 = panel struct
        lw      a1, 0x0048(a2)              // a1 = char_id
        li      t0, _place_token_return     // t0 = ra for place_token_from_id
        addiu   sp, sp, -0x0018             // deallocate stack space for place_token_from_id
        sw      t0, 0x0014(sp)              // store ra for place_token_from_id
        jal     place_token_from_id_
        lw      a2, 0x0004(a2)              // a2 = token object
        _place_token_return:
        jal     0x8013647C                  // do white flash
        lw      a0, 0x0008(sp)              // a0 = port

        li      t1, TwelveCharBattle.twelve_cb_flag
        lw      t1, 0x0000(t1)              // t1 = 1 if 12cb
        bnez    t1, _check_handicap         // if 12cb, skip regional flag redrawing
        nop
        li      t0, render_control_object
        lw      t0, 0x0000(t0)              // t0 = render control object
        lw      a0, 0x0008(sp)              // a0 = port
        sll     t1, a0, 0x0002              // t1 = offset for port
        addu    t0, t0, t1                  // t0 = render control object, offset for port
        lw      t0, 0x0030(t0)              // t0 = dpad object
        sw      r0, 0x003C(t0)              // clear previous state to force redraw of regional flags

        _check_handicap:
        OS.read_byte(Global.vs.handicap, t0) // t0 = 0 if handicap off
        beqz    t0, _finish                 // if handicap is off, skip
        nop
        jal     0x80137004                  // fix Handicap display
        lw      a0, 0x0008(sp)              // a0 = port

        _finish:
        lw      ra, 0x0004(sp)              // restore registers
        lw      a0, 0x0008(sp)              // ~
        lw      s0, 0x000C(sp)              // ~
        lw      s1, 0x0010(sp)              // ~
        addiu   sp, sp, 0x0030              // deallocate stack space

        _end:
        jr      ra
        nop
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
    // portrait_offset - portrait offset to use
    // portrait_id_override - if not -1, then it updates the portrait_id table (used for new variants)
    macro add_to_css(character, fgm, circle_size, action, logo, name_texture, portrait_offset, portrait_id_override) {
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
        dw  series_logo.offset.{logo}
        // add to name texture table
        origin name_texture_table_origin + ({character} * 4)
        dw  {name_texture}
        // add to portrait offset by character table
        origin portrait_offset_by_character_table_origin + ({character} * 4)
        dw  {portrait_offset}
        // optionally override portrait_id_table (for variants)
        if ({portrait_id_override} != -1) {
            origin portrait_id_table_origin + {character}
            db {portrait_id_override}
        } else {
            // if not a variant, we don't want the variant indicator to display, so update the variant_original table
            origin Character.variant_original.TABLE_ORIGIN + ({character} * 4)
            dw {character}
        }
        pullvar base, origin
    }

    // ADD CHARACTERS
               // id                fgm                                 circle size   action      series logo   name texture                 portrait offset                  portrait override
    add_to_css(Character.id.FALCO,  FGM.announcer.names.FALCO,          1.50,         0x00010004, STARFOX,      name_texture.FALCO,          portrait_offsets.FALCO,          -1)
    add_to_css(Character.id.GND,    FGM.announcer.names.GANONDORF,      1.50,         0x00010002, ZELDA,        name_texture.GND,            portrait_offsets.GND,            -1)
    add_to_css(Character.id.YLINK,  FGM.announcer.names.YOUNG_LINK,     1.50,         0x00010002, ZELDA,        name_texture.YLINK,          portrait_offsets.YLINK,          -1)
    add_to_css(Character.id.DRM,    FGM.announcer.names.DR_MARIO,       1.50,         0x00010001, DR_MARIO,     name_texture.DRM,            portrait_offsets.DRM,            -1)
    add_to_css(Character.id.WARIO,  FGM.announcer.names.WARIO,          1.50,         0x00010004, WARIO,        name_texture.WARIO,          portrait_offsets.WARIO,          -1)
    add_to_css(Character.id.DSAMUS, FGM.announcer.names.DSAMUS,         1.50,         0x00010004, METROID,      name_texture.DSAMUS,         portrait_offsets.DSAMUS,         -1)
    add_to_css(Character.id.ELINK,  FGM.announcer.names.ELINK,          1.50,         0x00010001, ZELDA,        name_texture.LINK,           portrait_offsets.ELINK,          5)
    add_to_css(Character.id.JSAMUS, FGM.announcer.names.SAMUS,          1.50,         0x00010003, METROID,      name_texture.SAMUS,          portrait_offsets.JSAMUS,         6)
    add_to_css(Character.id.JNESS,  FGM.announcer.names.NESS,           1.50,         0x00010002, EARTHBOUND,   name_texture.NESS,           portrait_offsets.JNESS,          12)
    add_to_css(Character.id.LUCAS,  FGM.announcer.names.LUCAS,          1.50,         0x00010002, EARTHBOUND,   name_texture.LUCAS,          portrait_offsets.LUCAS,          -1)
    add_to_css(Character.id.JLINK,  FGM.announcer.names.LINK,           1.50,         0x00010001, ZELDA,        name_texture.LINK,           portrait_offsets.JLINK,          5)
    add_to_css(Character.id.JFALCON,FGM.announcer.names.CAPTAIN_FALCON, 1.50,         0x00010001, FZERO,        name_texture.CAPTAIN_FALCON, portrait_offsets.JFALCON,        7)
    add_to_css(Character.id.JFOX,   FGM.announcer.names.JFOX,           1.50,         0x00010004, STARFOX,      name_texture.FOX,            portrait_offsets.JFOX,           15)
    add_to_css(Character.id.JMARIO, FGM.announcer.names.MARIO,          1.50,         0x00010003, MARIO_BROS,   name_texture.MARIO,          portrait_offsets.JMARIO,         3)
    add_to_css(Character.id.JLUIGI, FGM.announcer.names.LUIGI,          1.50,         0x00010001, MARIO_BROS,   name_texture.LUIGI,          portrait_offsets.JLUIGI,         2)
    add_to_css(Character.id.JDK,    FGM.announcer.names.DONKEY_KONG,    2,            0x00010001, DONKEY_KONG,  name_texture.JDK,            portrait_offsets.JDK,            4)
    add_to_css(Character.id.EPIKA,  FGM.announcer.names.PIKACHU,        1.50,         0x00010001, POKEMON,      name_texture.PIKACHU,        portrait_offsets.EPIKA,          16)
    add_to_css(Character.id.JPUFF,  FGM.announcer.names.JPUFF,          1.50,         0x00010002, POKEMON,      name_texture.JPUFF,          portrait_offsets.JPUFF,          17)
    add_to_css(Character.id.EPUFF,  FGM.announcer.names.JIGGLYPUFF,     1.50,         0x00010002, POKEMON,      name_texture.JIGGLYPUFF,     portrait_offsets.EPUFF,          17)
    add_to_css(Character.id.JKIRBY, FGM.announcer.names.KIRBY,          1.50,         0x00010003, KIRBY,        name_texture.KIRBY,          portrait_offsets.JKIRBY,         14)
    add_to_css(Character.id.JYOSHI, FGM.announcer.names.YOSHI,          1.50,         0x00010002, YOSHI,        name_texture.YOSHI,          portrait_offsets.JYOSHI,         13)
    add_to_css(Character.id.JPIKA,  FGM.announcer.names.PIKACHU,        1.50,         0x00010001, POKEMON,      name_texture.PIKACHU,        portrait_offsets.JPIKA,          16)
    add_to_css(Character.id.ESAMUS, FGM.announcer.names.ESAMUS,         1.50,         0x00010003, METROID,      name_texture.SAMUS,          portrait_offsets.ESAMUS,         6)
    add_to_css(Character.id.BOWSER, FGM.announcer.names.BOWSER,         2,            0x00010002, BOWSER,       name_texture.BOWSER,         portrait_offsets.BOWSER,         -1)
    add_to_css(Character.id.GBOWSER,FGM.announcer.names.GBOWSER,        2.25,         0x00010002, BOWSER,       name_texture.GBOWSER,        portrait_offsets.GBOWSER,        24)
    add_to_css(Character.id.PIANO,  FGM.announcer.names.PIANO,          2,            0x00010004, MARIO_BROS,   name_texture.PIANO,          portrait_offsets.PIANO,          2)
    add_to_css(Character.id.WOLF,   FGM.announcer.names.WOLF,           1.50,         0x00010004, STARFOX,      name_texture.WOLF,           portrait_offsets.WOLF,           -1)
    add_to_css(Character.id.CONKER, FGM.announcer.names.CONKER,        	1.50,         0x00010004, CONKER,       name_texture.CONKER,         portrait_offsets.CONKER,         -1)
    add_to_css(Character.id.MTWO,   FGM.announcer.names.MEWTWO,         1.50,         0x00010004, POKEMON,      name_texture.MEWTWO,         portrait_offsets.MTWO,           -1)
    add_to_css(Character.id.MARTH,  FGM.announcer.names.MARTH,          1.50,         0x00010004, FIRE_EMBLEM,  name_texture.MARTH,          portrait_offsets.MARTH,          -1)
    add_to_css(Character.id.SONIC,  FGM.announcer.names.SONIC,        	1.50,         0x00010004, SONIC,        name_texture.SONIC,          portrait_offsets.SONIC,          -1)
    add_to_css(Character.id.SANDBAG,FGM.announcer.names.FALCO,          1.50,         0x00010001, ZELDA,        name_texture.JPUFF,          portrait_offsets.SANDBAG,        -1)
    add_to_css(Character.id.SSONIC, FGM.announcer.names.SSONIC,        	1.50,         0x00010004, SONIC,        name_texture.SSONIC,         portrait_offsets.SSONIC,         9)
    add_to_css(Character.id.SHEIK,  FGM.announcer.names.SHEIK,          1.50,         0x00010001, ZELDA,        name_texture.SHEIK,          portrait_offsets.SHEIK,          -1)
    add_to_css(Character.id.MARINA, FGM.announcer.names.MARINA,        	1.50,         0x00010004, MISCHIEF_MAKERS,  name_texture.MARINA,     portrait_offsets.MARINA,         -1)
    add_to_css(Character.id.DEDEDE, FGM.announcer.names.DEDEDE,         2,            0x00010001, KIRBY,        name_texture.DEDEDE,         portrait_offsets.DEDEDE,          -1)
    // ADD NEW CHARACTERS HERE

    // REMIX POLYGONS
    add_to_css(Character.id.NWARIO, FGM.announcer.names.NWARIO,         1.50,         0x00010004, SMASH,        name_texture.NWARIO,         portrait_offsets.WARIO,          22)
    add_to_css(Character.id.NLUCAS, FGM.announcer.names.NLUCAS,         1.50,         0x00010002, SMASH,        name_texture.NLUCAS,         portrait_offsets.LUCAS,          23)
    add_to_css(Character.id.NBOWSER, FGM.announcer.names.NBOWSER,       2,            0x00010002, SMASH,        name_texture.NBOWSER,        portrait_offsets.BOWSER,         24)
    add_to_css(Character.id.NWOLF,  FGM.announcer.names.NWOLF,          1.50,         0x00010004, SMASH,        name_texture.NWOLF,          portrait_offsets.WOLF,           25)
    add_to_css(Character.id.NDRM,   FGM.announcer.names.NDR_MARIO,      1.50,         0x00010001, SMASH,        name_texture.NDRM,           portrait_offsets.DRM,            1)
    add_to_css(Character.id.NSONIC, FGM.announcer.names.NSONIC,        	1.50,         0x00010004, SMASH,        name_texture.NSONIC,         portrait_offsets.SONIC,          9)
    add_to_css(Character.id.NSHEIK, FGM.announcer.names.NSHEIK,         1.50,         0x00010001, SMASH,        name_texture.NSHEIK,         portrait_offsets.SHEIK,          19)
    add_to_css(Character.id.NMARINA, FGM.announcer.names.NMARINA,       1.50,         0x00010001, SMASH,        name_texture.NMARINA,        portrait_offsets.MARINA,         0)
}


} // __CHARACTER_SELECT__
