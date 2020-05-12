// Character.asm
if !{defined __CHARACTER_SELECT__} {
define __CHARACTER_SELECT__()
print "included CharacterSelect.asm\n"

// @ Description
// This file contains modifications to the Character Select screen

// TODO: 
// - Names for variants (improve quality)
// - Console not rendering env mapping for MM or polygons

include "Global.asm"
include "OS.asm"
include "RCP.asm"
include "Texture.asm"

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
    dw  0xD800                              // 0x02 - DONKEY (req list also includes the file with stock icons, but size of that file not accounted for here)
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
    dw  0x105D0 + 0x200                     // 0x1F - YLINK
    dw  0x7720 + 0x200                      // 0x20 - DRM
    dw  0xCA50 + 0x200                      // 0x21 - WARIO
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

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // save registers

        // discard values right of certain given x value
        sltiu   t0, a1, 240                 // if xpos less than given value
        beqz    t0, _end                    // ...return
        lli     v0, Character.id.NONE       // v0 = ret = NONE

        // discard values past given y value
        sltiu   t0, v1, 86                  // if ypos greater than given value
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
        
        // Only check variants on the VS and Training screens
        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = screen id

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    t1, t0, 0x0010              // if (screen id < 0x10)...
        bnez    t1, _end                    // ...then skip (not on a CSS)
        nop
        slti    t1, t0, 0x0015              // if (screen id is between 0x10 and 0x14)...
        beqz    t1, _end                    // ...then we're on a CSS
        nop
        lli     t1, 0x0010                  // t1 = VS CSS
        bnel    t1, t0, pc() + 8            // if we're not on the VS CSS,
        lli     t1, 0x0012                  // then spoof training so the offsets are correct

        // a3 is the CSS player struct

        addiu   t0, t0, -0x0010             // t0 = 0 if VS, 2 if training
        sll     t0, t0, 0x0001              // t0 = 0 if VS, 4 if training
        subu    t0, a3, t0                  // t0 = a3 if VS, a3 - 4 if training (now 0x007C(a3) is player index of token holder)
        lw      t0, 0x007C(a3)              // t0 = 0x0004 if token isn't held
        lli     t4, 0x0004                  // t1 = 0x0004 (means token isn't held)
        beq     t0, t4, _end                // skip if token isn't held
        nop

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
        lw      t2, 0x000C(sp)              // save registers
        addiu   sp, sp, 0x0010              // deallocate stack space
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
        li      t2, portrait_id_table           // t2 = portraid_id_table
        addu    t2, t2, a0                      // t2 = address of character's portrait_id
        lbu     v0, 0x0000(t2)                  // v0 = portrait_id
        jr      ra
        nop
        OS.patch_end()
        // training
        OS.patch_start(0x00141600, 0x80132020)
        // a0 = character_id
        li      t2, portrait_id_table           // t2 = portraid_id_table
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
        addiu   t9, t9, START_X + 12        // t9 = (int) ulx + offset
        mtc1    t9, f4                      // original line 8
        addu    t9, v0, r0                  // remember portrait_id
        OS.patch_end()
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
            jal    token_autoposition_y_fix_
            lui    at, 0x4120                   // original line 1
            OS.patch_end()
            // training
            OS.patch_start(0x00145F48, 0x80136968)
            jal    token_autoposition_y_fix_
            lui    at, 0x4120                   // original line 1
            OS.patch_end()
    
            lli     t1, NUM_COLUMNS             // ~
            divu    t9, t1                      // ~
            mflo    t1                          // t1 = portrait_id / NUM_COLUMS = row
            lli     t2, PORTRAIT_HEIGHT         // ~
            multu   t2, t1                      // ~
            mflo    t2                          // t2 = uly
            addiu   t2, t2, START_Y + 14        // t2 = (int) uly + offset
    
            jr      ra
            nop
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

            li      t4, portrait_id_table           // t4 = portraid_id_table
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

            li      t0, portrait_id_table           // t0 = portraid_id_table
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

    // disable drawing of default portraits on Training Mode CSS
    OS.patch_start(0x001419B8, 0x801323D8)
    jr      ra
    nop
    OS.patch_end()

    // disable drawing of default portraits on 1P Mode CSS
    OS.patch_start(0x0013ADA4, 0x80132BA4)
    jr      ra
    nop
    OS.patch_end()

    // disable drawing of default portraits on BTT/BTP CSS
    OS.patch_start(0x00148A88, 0x80132A58)
    jr      ra
    nop
    OS.patch_end()

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

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    at, t0, 0x0010              // if (screen id < 0x10)...
        bnez    at, _skip                   // ...then skip (not on a CSS)
        nop
        slti    at, t0, 0x0015              // if (screen id is between 0x10 and 0x14)...
        beqz    at, _skip                   // ...then we're on a CSS
        nop

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
        li      t0, RCP.display_list_info_p       // t0 = display list info pointer
        li      at, DL.portrait_display_list_info // at = address of display list info
        sw      at, 0x0000(t0)                    // update display list info pointer

        // reset
        li      t0, DL.portrait_display_list      // t0 = address of DL.portrait_display_list
        li      at, DL.portrait_display_list_info // at = address of DL.portrait_display_list_info
        sw      t0, 0x0000(at)                    // ~
        sw      t0, 0x0004(at)                    // update display list address each frame

        // highjack
        li      t0, 0xDE000000               // ~
        sw      t0, 0x0000(v1)               // ~
        li      t0, DL.portrait_display_list // ~
        sw      t0, 0x0004(v1)               // highjack ssb display list

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

    // @ Description
    // Highjacks the display list before the cursor so the variant indicators show under them
    scope highjack_2_: {
        OS.patch_start(0x787EC, 0x800FCFEC)
        j       highjack_2_
        nop
        _return:
        OS.patch_end()

        sw      t7, 0x0000(v0)              // original line 1
        sw      r0, 0x0004(v0)              // original line 2

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      at, 0x0004(sp)              // ~
        sw      t0, 0x0008(sp)              // ~
        sw      t1, 0x000C(sp)              // ~
        sw      a0, 0x0010(sp)              // ~
        sw      a3, 0x0014(sp)              // ~
        sw      v0, 0x0018(sp)              // ~
        sw      ra, 0x001C(sp)              // save registers

        // Make sure we're on a CSS
        li      t0, Global.current_screen   // ~
        lbu     t0, 0x0000(t0)              // t0 = screen id

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    at, t0, 0x0010              // if (screen id < 0x10)...
        bnez    at, _continue               // ...then skip
        nop
        slti    at, t0, 0x0015              // if (screen id is between 0x10 and 0x14)...
        beqz    at, _skip                   // ...then we're on a CSS
        nop

        _continue:
        // This appears to be called twice, so let's use the first one when 0xF is the value in a1
        lli     at, 0x000F                  // at = expected value
        bne     at, a1, _skip               // if test fails, end
        nop

        // highjack here
        addiu   v0, v0, 0x0008              // increment v0
        addiu   t1, v0, 0x0008              // t1 = v0 + 8
        sw      t1, 0x0000(v1)              // update v1

        // init
        li      t1, RCP.display_list_info_p                // t1 = display list info pointer
        li      at, DL.variant_indicator_display_list_info // at = address of display list info
        sw      at, 0x0000(t1)                             // update display list info pointer

        // reset
        li      t1, DL.variant_indicator_display_list      // t1 = address of display_list
        li      at, DL.variant_indicator_display_list_info // at = address of display_list_info
        sw      t1, 0x0000(at)                             // ~
        sw      t1, 0x0004(at)                             // update display list address each frame

        // highjack
        li      t1, 0xDE000000                             // ~
        sw      t1, 0x0000(v0)                             // ~
        li      t1, DL.variant_indicator_display_list      // ~
        sw      t1, 0x0004(v0)                             // highjack ssb display list

        // draw variant indicator
        jal     CharacterSelect.run_variant_check_
        nop

        // This probably isn't 100% correct, but the subsequent commands in the original
        // display list most likely make up for it...
        li      a0, 0xEF002C0F              // restore RDP other modes
        li      a1, 0x00504240              // ~
        jal     RCP.append_
        nop

        jal     RCP.pipe_sync_
        nop
        jal     RCP.end_list_
        nop

        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a3, 0x0014(sp)              // ~
        lw      v0, 0x0018(sp)              // ~
        lw      ra, 0x001C(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space

        j       _return                     // return
        nop

        _skip:
        lw      at, 0x0004(sp)              // ~
        lw      t0, 0x0008(sp)              // ~
        lw      t1, 0x000C(sp)              // ~
        lw      a0, 0x0010(sp)              // ~
        lw      a3, 0x0014(sp)              // ~
        lw      v0, 0x0018(sp)              // ~
        lw      ra, 0x001C(sp)              // restore registers
        addiu   sp, sp, 0x0020              // deallocate stack space
        j       _return                     // return
        nop
    }

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

        addiu   sp, sp,-0x0004              // allocate stack space
        sw      ra, 0x0004(sp)              // ~

        _get_random_id:
        jal     Global.get_random_int_alt_  // original line 1
        addiu   a0, r0, NUM_SLOTS           // original line 2 modified to include all slots
        // v0 = random number between 0 and NUM_SLOTS
        li      s0, id_table                // s0 = id_table
        addu    s0, s0, v0                  // s0 = id_table + offset
        lbu     v0, 0x0000(s0)              // v0 = character_id
        lli     s0, Character.id.NONE       // s0 = Character.id.NONE
        beq     s0, v0, _get_random_id      // if v0 is not a valid character then get a new random number
        nop                                 // ~

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
    OS.patch_start(0x13DC10, 0x80135A10)
    nop
    OS.patch_end()

    // @ Description
    // removes white flash on BTT/BTP character select
    OS.patch_start(0x14A960, 0x80134930)
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

        // for (char_id i = METAL; i < last character; i++)
        lli     s0, Character.id.METAL
        
        _loop:
        lli     a0, Character.id.PLACEHOLDER// a0 = PLACEHOLDER
        beql    a0, s0, _loop               // if char_id = PLACEHOLDER, skip
        addiu   s0, s0, 0x0001              // increment index
        lli     a0, Character.id.NONE       // a0 = NONE
        beql    a0, s0, _loop               // if char_id = NONE, skip
        addiu   s0, s0, 0x0001              // increment index
        jal     load_character_model_       // load character function
        or      a0, s0, r0                  // a0 = index
        // end on x character (Character.NUM_CHARACTERS - 1 should work usually)
        slti    at, s0, Character.NUM_CHARACTERS - 1
        bnez    at, _loop
        addiu   s0, s0, 0x0001              // increment index

        li      s0, chars_loaded            // s0 = chars_loaded
        lli     v1, 0x0001                  // v1 = 1
        sw      v1, 0x0000(s0)              // set chars_loaded to 1

        lui     v1, 0x8014                  // original line 1
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
    // Changes the loads from fgm_table instead of the original function table
    // Also sets the selection flash timer
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
        beq     t1, r0, _update_flash_timer // if s1 is port id, use it to get original character id
        nop
        li      t1, Character.variant_original.table
        sll     v1, v1, 0x0002              // v1 = offset in variant_original table
        addu    t1, t1, v1                  // t1 = address of original character id
        lw      v1, 0x0000(t1)              // v1 = original character id

        _update_flash_timer:
        // update flash timer
        lli     t5, FLASH_TIME              // t5 = FLASH_TIME
        li      a0, flash_table             // a0 = flash_table
        addu    a0, a0, v1                  // a0 = flash_table + character id
        sb      t5, 0x0000(a0)              // store FLASH_TIME

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
    // This patch increases the heap space by moving it to expansion RAM.
    // This enables us to load an unlimited number of character models.
    scope increase_heap_: {
        OS.patch_start(0x7450, 0x80006850)
        jal     increase_heap_
        nop
        _increase_heap_return:
        OS.patch_end()

        li      at, Global.current_screen   // at = address of current screen
        lbu     at, 0x0000(at)              // at = current screen

        // css screen ids: vs - 0x10, 1p - 0x11, training - 0x12, bonus1 - 0x13, bonus2 - 0x14
        slti    a1, at, 0x0010              // if (screen id < 0x10)...
        bnez    a1, _original               // ...then skip (not on a CSS)
        nop
        slti    a1, at, 0x0015              // if (screen id is not between 0x10 and 0x14)...
        beqz    a1, _original               // ...then skip (not on a CSS)
        nop

        li      a0, custom_heap             // a0 = address of start of our custom heap
        lui     a1, 0x0060                  // a1 = custom heap size (0x00600000) - increase as needed
        jal     0x80004950                  // original line 1
        nop
        j       _increase_heap_return       // return
        nop

        _original:
        lw      a1, 0x0010(s0)              // original line 0
        jal     0x80004950                  // original line 1
        lw      a0, 0x000C(a0)              // original line 2
        j       _increase_heap_return       // return
        nop
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
        OS.patch_start(0x0014B9B0, 0x80135988)
        jal     check_variant_input_._bonus
        nop
        OS.patch_end()

        _vs:
        // a1 = player index (port 0 - 3)
        // v0 = pointer to player CSS struct
        // 0x0080(v0) = held token player index (port 0 - 3 or -1 if not holding a token)

        addu    t8, t6, t7                  // original line 1
        sw      t8, 0x0024(sp)              // original line 2

        addiu   sp, sp, -0x000C             // allocate stack space
        sw      v1, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~

        lhu     t8, 0x0002(t8)              // unique press button state
        jal     _shared                     // call main routine (shared between vs and training)
        addu    v1, v0, r0                  // v1 = pointer to player CSS struct

        lw      v1, 0x0004(sp)              // ~
        lw      ra, 0x0008(sp)              // ~
        addiu   sp, sp, 0x000C              // deallocate stack space

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
        addiu   t8, r0, Character.variants.SPECIAL + 1

        andi    at, t8, Joypad.DD           // D-pad down
        bnel    at, r0, _set_variant_offset // if pressed, update to POLYGON
        addiu   t8, r0, Character.variants.POLYGON + 1

        andi    at, t8, Joypad.DL           // D-pad left
        bnel    at, r0, _set_variant_offset // if pressed, update to J
        addiu   t8, r0, Character.variants.J + 1

        andi    at, t8, Joypad.DR           // D-pad right
        bnel    at, r0, _set_variant_offset // if pressed, update to E
        addiu   t8, r0, Character.variants.E + 1

        andi    at, t8, Joypad.Z            // Z
        bnel    at, r0, _set_variant_offset // if pressed, reset to normal character
        addu    t8, a0, r0                  // t8 = a0

        addu    t8, r0, r0                  // t8 = 0

        _set_variant_offset:
        beqzl   t8, _determine_variant      // if t8 = 0, then use previous variant_offset
        sb      a0, 0x0000(t1)              // ~
        beql    a0, t8, _determine_variant  // if the same direction already selected is selected again...
        sb      r0, 0x0000(t1)              // ...then reset to normal character
        sb      t8, 0x0000(t1)              // ...else store new variant_offset

        _determine_variant:
        bnez    t0, _end                    // if the token is being held, then skip
        nop                                 // otherwise, check if the player already has a character selected
        lw      at, 0x0088(v1)              // at = is_char_selected
        beqz    at, _end                    // if no character is selected, skip to end
        nop                                 // otherwise, check the variant to see if we need to update the selection

        lbu     t8, 0x0000(t1)              // t8 = variant_offset
        beqz    t8, _check_selectable       // if Z was pressed, update character
        lbu     a0, 0x0004(t1)              // a0 = selected character's portrait's character_id

        lbu     t0, 0x0004(t1)              // t0 = selected character's portrait's character_id
        li      a0, Character.variants.table// a0 = variant table
        sll     at, t0, 0x0002              // at = character variant array index
        addu    a0, a0, at                  // a0 = character variant array
        addu    a0, a0, t8                  // a0 = character variant ID address, unadjusted
        addiu   a0, a0, -0x0001             // a0 = character variant ID address
        lbu     a0, 0x0000(a0)              // a0 = variant ID
        _check_selectable:
        lw      t0, 0x0048(v0)              // t0 = selected character_id
        beq     a0, t0, _end                // if variant is already selected, skip to end
        nop                                 // ~
        addiu   at, r0, Character.id.NONE   // at = id.NONE
        beq     a0, at, _end                // if no variant defined, skip to end
        nop                                 // ~

        _select_character:
        // TODO: it would be nice to be able to change selection while the character is selected...
        // ...however, I haven't had much luck in doing something that didn't crash console.
        // So for now, you'll have to deselect the character before it can be changed to the original or variant.

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
    // Struct for portrait textures
    portrait_info:;     Texture.info(PORTRAIT_WIDTH_FILE, PORTRAIT_HEIGHT_FILE)

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
        constant SMASH(0x000045D8)
        constant DR_MARIO(0x00004C38)
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
        constant JLINK(0x00002BA0)
        constant JFALCON(0x00003998)
        constant JFOX(0x000025B8)
        constant JMARIO(0x00001838)
        constant JLUIGI(0x00001B18)
        constant JDK(0x00017AA8)
        constant EPIKA(0x000032F8)
        constant JPUFF(0x00017DD8)
        constant JPIKA(0x000032F8)
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
        define slot_18(WARIO)
        define slot_19(LUCAS)
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
    portrait_unknown_flash: // we don't need a flash, but this prevents compile errors
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
    
    // Set menu zoom size for GDK
    Character.table_patch_start(menu_zoom, Character.id.GDONKEY, 0x4)
    float32 1.3
    OS.patch_end()

    // @ Description
    // This indicates when all characters have been loaded and helps to not display
    // the variant indicator until after the screen fully transitions
    chars_loaded:
    dw     0x00000000

    // @ Description
    // This adds variant-related indicators to the screen.
    scope run_variant_check_: {
        constant CSS_PLAYER_STRUCT_SIZE(0xBC)
        constant CSS_PLAYER_STRUCT_SIZE_TRAINING(0xB8)
        constant HELD_TOKEN_OFFSET(0x80)
        constant HELD_TOKEN_OFFSET_TRAINING(0x7C)
        constant PANEL_OFFSET(000069)
        constant PANEL_OFFSET_TRAINING(000132)
        constant DPAD_X(000034)
        constant DPAD_X_TRAINING(000065)
        constant DPAD_X_1P(000038)
        constant DPAD_X_BONUS(000071)
        constant DPAD_Y(000177)

        // t0 = screen_id - is 0x0010 if VS CSS, 0x0011 if 1p, 0x0012 if Training CSS

        addiu   sp, sp,-0x0044              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      a1, 0x000C(sp)              // ~
        sw      a2, 0x0010(sp)              // ~
        sw      v0, 0x0014(sp)              // ~
        sw      v1, 0x0018(sp)              // ~
        sw      t0, 0x001C(sp)              // ~
        sw      t1, 0x0020(sp)              // ~
        sw      t2, 0x0024(sp)              // ~
        sw      s0, 0x0028(sp)              // ~
        sw      s1, 0x002C(sp)              // ~
        sw      s2, 0x0030(sp)              // ~
        sw      s3, 0x0034(sp)              // ~
        sw      s4, 0x0038(sp)              // ~
        sw      s5, 0x003C(sp)              // ~
        sw      at, 0x0040(sp)              // save registers

        lli     s0, 0x0000                  // s0 = 0 (player 1)
        li      s1, CSS_PLAYER_STRUCT
        lli     s2, CSS_PLAYER_STRUCT_SIZE
        lli     s3, HELD_TOKEN_OFFSET
        lli     s4, PANEL_OFFSET
        lli     s5, DPAD_X

        lli     t2, 0x0010                  // t2 = stage_id for VS CSS
        beq     t0, t2, _loop               // if on the VS CSS, we have the right values set
        nop                                 // ~

        // if on the training or 1p CSS, need to use different constants
        li      s1, CSS_PLAYER_STRUCT_TRAINING
        lli     s2, CSS_PLAYER_STRUCT_SIZE_TRAINING
        lli     s3, HELD_TOKEN_OFFSET_TRAINING
        lli     s4, PANEL_OFFSET_TRAINING
        lli     s5, DPAD_X_TRAINING

        lli     t2, 0x0012                  // t2 = stage_id for training CSS
        beq     t0, t2, _loop               // if on the training CSS, we have the right values set
        nop                                 // ~

        // use these settings for 1p CSS
        li      s1, CSS_PLAYER_STRUCT_1P
        lli     s2, 0x0000                  // there is only one element in the array, so no need to calculate offsets
        lli     s4, 0x0000                  // there is only one element in the array, so no need to calculate offsets
        lli     s5, DPAD_X_1P

        lli     t2, 0x0011                  // t2 = stage_id for 1p CSS
        beq     t0, t2, _loop               // if on the 1p CSS, we have the right values set
        nop                                 // ~

        // on Bonus CSS, override some more values
        li      s1, CSS_PLAYER_STRUCT_BONUS
        lli     s5, DPAD_X_BONUS

        _loop:
        li      t1, chars_loaded            // t1 = chars_loaded address
        lw      t1, 0x0000(t1)              // t1 = chars_loaded
        beqz    t1, _end                    // if characters aren't loaded, skip
        nop                                 // ~
        multu   s0, s2                      // t1 = offset to CSS player struct
        mflo    t1                          // ~
        addu    at, s1, t1                  // at = CSS player struct for player X
        lw      v1, 0x0004(at)              // v1 = 0 if screen not completely loaded
        beqz    v1, _next                   // if screen not loaded, skip
        nop                                 // ~
        addu    at, at, s3                  // at = address of player_index (held token)
        lw      v1, 0x0000(at)              // v1 = player_index (held token)
        sltiu   at, v1, 0x0004              // at = 1 if token is held
        beqz    at, _next                   // if token is not held, then skip
        nop
        multu   v1, s2                      // at = offset to CSS player struct of held token
        mflo    at                          // ~
        addu    at, s1, at                  // at = CSS player struct for held token
        lw      v0, 0x0048(at)              // v0 = character_id
        li      at, Character.variant_original.table
        sll     v0, v0, 0x0002              // v0 = offset in variant_original table
        addu    at, at, v0                  // at = address of original character id
        lw      v0, 0x0000(at)              // v0 = character_id of hovered portrait

        li      t0, 0x1C1C1C1C              // t0 = mask for no variants
        li      at, Character.variants.table// at = variant table
        sll     t1, v0, 0x0002              // t1 = character variant array index
        addu    at, at, t1                  // at = character variant array
        lw      t1, 0x0000(at)              // t1 = character variants
        beq     t0, t1, _next               // if there are no variants, skip
        nop

        // calculate X using player_index and PANEL_OFFSET
        addu    a0, r0, s5                  // a0 - ulx
        multu   v1, s4                      // t0 = player_index * PANEL_OFFSET
        mflo    t0                          // ~
        lli     t1, DPAD_X                  // t1 = DPAD_X
        beq     t1, s5, _draw_dpad          // if we are on training or 1p CSS, we have different maths
        nop
        // Training:
        //  - The CPU is port 1 unless the human is port 1 - then it is port 2.
        //  - The Human is always in position 1, and the CPU in position 2.
        // 1P:
        //  - Always port 1, but since s4 is 0 for 1P, we can reuse the logic below
        beql    s0, v1, _draw_dpad          // if holding human token, set t0 to 0
        addu    t0, r0, r0                  // ~
        addu    t0, r0, s4                  // otherwise we have the CPU token, so t0 should be the offset

        _draw_dpad:
        // draw dpad
        addu    a0, a0, t0                  // a0 = adjusted ulx
        lli     a1, DPAD_Y                  // a1 - uly
        li      a2, Data.dpad_info          // a2 - address of texture struct
        jal     Overlay.draw_texture_       // draw options text texture
        nop                                 // ~

        // draw MM/GDK indicator
        lbu     a0, 0x0000(at)              // a0 = Character.id.NONE if no variant
        lli     a1, Character.id.NONE       // a1 = Character.id.NONE
        beq     a0, a1, _check_polygon      // if there is no special variant, skip
        nop                                 // ~
        li      a2, Data.stock_icon_mm_info // a2 - address of texture struct
        lli     a1, Character.id.METAL      // a1 = Character.id.METAL
        beq     a0, a1, _draw_special       // if this is Metal Mario, a2 is correct
        nop                                 // if not, set a2 to GDK's icon instead
        li      a2, Data.stock_icon_gdk_info// a2 - address of texture struct
        _draw_special:
        addiu   a0, s5, 000004              // a0 - ulx
        addu    a0, a0, t0                  // a0 = adjusted ulx
        lli     a1, DPAD_Y - 8              // a1 - uly
        jal     Overlay.draw_texture_       // draw MM/GDK icon
        nop

        _check_polygon:
        // draw polygon indicator
        lbu     a0, 0x0001(at)              // a0 = Character.id.NONE if no variant
        lli     a1, Character.id.NONE       // a1 = Character.id.NONE
        beq     a0, a1, _check_eu           // if there is no polygon variant, skip
        nop                                 // ~
        addiu   a0, s5, 000004              // a0 - ulx
        addu    a0, a0, t0                  // a0 = adjusted ulx
        lli     a1, DPAD_Y + 16             // a1 - uly
        li      a2, Data.stock_icon_poly_info
        jal     Overlay.draw_texture_       // draw EU flag
        nop

        _check_eu:
        // draw EU flag
        lbu     a0, 0x0003(at)              // a0 = Character.id.NONE if no variant
        lli     a1, Character.id.NONE       // a1 = Character.id.NONE
        beq     a0, a1, _check_jp           // if there is no EU variant, skip
        nop                                 // ~
        addiu   a0, s5, 000016              // a0 - ulx
        addu    a0, a0, t0                  // a0 = adjusted ulx
        lli     a1, DPAD_Y + 4              // a1 - uly
        li      a2, Data.flag_eu_info       // a2 - address of texture struct
        jal     Overlay.draw_texture_       // draw EU flag
        nop

        _check_jp:
        // draw JP flag
        lbu     a0, 0x0002(at)              // a0 = Character.id.NONE if no variant
        lli     a1, Character.id.NONE       // a1 = Character.id.NONE
        beq     a0, a1, _draw_indicator     // if there is no JP variant, skip
        nop                                 // ~
        addiu   a0, s5, -000010             // a0 - ulx
        addu    a0, a0, t0                  // a0 = adjusted ulx
        lli     a1, DPAD_Y + 4              // a1 - uly
        li      a2, Data.flag_jp_info       // a2 - address of texture struct
        jal     Overlay.draw_texture_       // draw JP flag
        nop

        _draw_indicator:
        // draw selected direction using yellow square
        li      t1, variant_offset          // t1 = address of variant_offset array
        addu    t1, t1, v1                  // t1 = address of variant_offset for port
        lbu     t1, 0x0000(t1)              // t1 = variant_offset
        beqz    t1, _next                   // if variant_offset is 0, then skip
        nop                                 // else, get the variant ID
        lli     a0, Color.low.YELLOW        // a0 - fill color
        jal     Overlay.set_color_          // fill color = YELLOW
        nop
        slti    t2, t1, 0x0003              // t2 = 1 if special or polygon
        beqz    t2, _regional               // if variant_offset is special or polygon, set x and y accordingly:
        addiu   a0, s5, 000007              // a0 - ulx
        lli     a1, DPAD_Y - 5              // a1 - uly
        sll     t2, t1, 0x0003              // t2 = t1 * 3 (8 for special, 16 for polygon)
        b       _draw_indicator_rectangle
        addu    a1, a1, t2                  // a1 = adjusted uly

        _regional:
        addiu   a0, s5, -000021             // a0 - ulx
        lli     a1, DPAD_Y + 7              // a1 - uly
        sll     t2, t1, 0x0003              // t2 = t1 * 3 (8 for E, 16 for J)
        addu    a0, a0, t2                  // a0 = adjusted uly

        _draw_indicator_rectangle:
        addu    a0, a0, t0                  // a0 = adjusted ulx
        lli     a2, 2                       // a2 - width
        lli     a3, 2                       // a3 - height
        jal     Overlay.draw_rectangle_     // draw rectangle
        nop

        _next:
        // draw selected character's EU/JP flag
        multu   s0, s2                      // t1 = offset to CSS player struct
        mflo    t1                          // ~
        addu    at, s1, t1                  // at = CSS player struct for player X
        addu    at, at, s3                  // at = address of player_index (held token)
        lw      v1, 0x0008(at)              // v1 = bool_character_selected
        beqz    v1, _continue               // if no character selected, continue
        nop                                 // otherwise, check if this is a variant and display flags if so
        addiu   v1, v1, -0x0001             // v0 = 0 if we still should draw
        bnez    v1, _end                    // end if we shouldn't draw
        nop
        subu    at, at, s3                  // at = CSS player struct for player X
        lw      v1, 0x0048(at)              // v1 = character_id
        addu    at, at, s3                  // at = address of player_index (held token)
        lw      t2, 0x0004(at)              // t2 = panel state (0 = HMN, 1 = CPU, 2 = N/A)
        li      at, Character.variant_original.table
        sll     v0, v1, 0x0002              // v0 = offset in variant_original table
        addu    at, at, v0                  // at = address of original
        lw      v0, 0x0000(at)              // v0 = variant original
        li      at, Character.variants.table// at = address of variants table
        sll     v0, v0, 0x0002              // v0 = offset in variants table
        addu    at, at, v0                  // at = address of variants array

        // calculate X using player_index and PANEL_OFFSET
        multu   s0, s4                      // t0 = panel_index * PANEL_OFFSET
        mflo    t0                          // ~
        lli     t1, DPAD_X                  // t1 = DPAD_X
        beq     t1, s5, _check_flag_jp      // if we are on training or 1p CSS, we have different maths
        nop
        // Training:
        //  - The CPU is port 1 unless the human is port 1 - then it is port 2.
        //  - The Human is always in position 1, and the CPU in position 2.
        // 1P:
        //  - Always port 1, but since s4 is 0 for 1P, we can reuse the logic below
        beqzl   t2, _check_flag_jp          // if panel is human, set t0 to first position
        addiu   t0, r0, 000008              // ~
        addu    t0, r0, s4                  // otherwise it is the CPU, so t0 should be the offset
        addiu   t0, t0, 000008              // ~

        _check_flag_jp:
        lbu     t2, 0x0002(at)              // t2 = J variant_id
        bne     t2, v1, _check_flag_eu      // if not J, check E
        nop
        addu    a0, s5, t0                  // a0 = adjusted ulx
        addiu   a0, a0, -000008             // a0 = adjusted ulx
        lli     a1, 000189                  // a1 - uly
        li      a2, Data.flag_jp_big_info   // a2 - address of texture struct
        jal     Overlay.draw_texture_       // draw JP flag
        nop
        b       _continue
        nop

        _check_flag_eu:
        lbu     t2, 0x0003(at)              // t2 = E variant_id
        bne     t2, v1, _continue           // if not E, continue
        nop
        addu    a0, s5, t0                  // a0 = adjusted ulx
        addiu   a0, a0, -000008             // a0 = adjusted ulx
        lli     a1, 000189                  // a1 - uly
        li      a2, Data.flag_eu_big_info   // a2 - address of texture struct
        jal     Overlay.draw_texture_       // draw JP flag
        nop

        _continue:
        lli     t0, DPAD_X_1P               // t0 = DPAD_X_1P
        beq     t0, s5, _end                // if we are on 1P CSS, we don't have to loop
        nop
        slti    t0, s0, 0x0003              // t0 = 1 if we haven't looped through all player ports
        bnez    t0, _loop                   // if we have more to loop over, then loop
        addiu   s0, s0, 0x0001              // increment s0

        _end:
        lw      ra, 0x0004(sp)              // ~
        lw      a0, 0x0008(sp)              // ~
        lw      a1, 0x000C(sp)              // ~
        lw      a2, 0x0010(sp)              // ~
        lw      v0, 0x0014(sp)              // ~
        lw      v1, 0x0018(sp)              // ~
        lw      t0, 0x001C(sp)              // ~
        lw      t1, 0x0020(sp)              // ~
        lw      t2, 0x0024(sp)              // ~
        lw      s0, 0x0028(sp)              // ~
        lw      s1, 0x002C(sp)              // ~
        lw      s2, 0x0030(sp)              // ~
        lw      s3, 0x0034(sp)              // ~
        lw      s4, 0x0038(sp)              // ~
        lw      s5, 0x003C(sp)              // ~
        lw      at, 0x0040(sp)              // restore registers
        addiu   sp, sp, 0x0044              // deallocate stack space
        jr      ra                          // return
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
    // portrait - portrait file name (.rgba5551 file in ../textures/)
    // portrait_id_override - if not -1, then it updates the portrait_id table (used for new variants)
    macro add_to_css(character, fgm, circle_size, action, logo, name_texture, portrait, portrait_id_override) {
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

        // add portrait
        add_portrait({character}, {portrait})
    }
    
    
    // ADD CHARACTERS
               // id                fgm                             circle size   action    series logo               name texture                portrait, portrait override                         
    add_to_css(Character.id.FALCO,  FGM.announcer.names.FALCO,          1.50,   0x00010004, series_logo.STARFOX,      name_texture.FALCO,         portrait_falco, -1)
    add_to_css(Character.id.GND,    FGM.announcer.names.GANONDORF,      1.50,   0x00010002, series_logo.ZELDA,        name_texture.GND,           portrait_ganondorf, -1)
    add_to_css(Character.id.YLINK,  FGM.announcer.names.YOUNG_LINK,     1.50,   0x00010002, series_logo.ZELDA,        name_texture.YLINK,         portrait_young_link, -1)
    add_to_css(Character.id.DRM,    FGM.announcer.names.DR_MARIO,       1.50,   0x00010001, series_logo.DR_MARIO,     name_texture.DRM,           portrait_dr_mario, -1)
    add_to_css(Character.id.WARIO,  FGM.announcer.names.WARIO,          1.50,   0x00010004, series_logo.MARIO_BROS,   name_texture.WARIO,         portrait_wario, -1)
    add_to_css(Character.id.DSAMUS, FGM.announcer.names.DSAMUS,         1.50,   0x00010004, series_logo.METROID,      name_texture.DSAMUS,        portrait_dark_samus, -1)
    add_to_css(Character.id.ELINK,  FGM.announcer.names.ELINK,          1.50,   0x00010001, series_logo.ZELDA,        name_texture.LINK,          portrait_unknown, 4)
    add_to_css(Character.id.JSAMUS, FGM.announcer.names.SAMUS,          1.50,   0x00010003, series_logo.METROID,      name_texture.SAMUS,         portrait_unknown, 5)
    add_to_css(Character.id.JNESS,  FGM.announcer.names.NESS,           1.50,   0x00010002, series_logo.EARTHBOUND,   name_texture.NESS,          portrait_unknown, 9)
    add_to_css(Character.id.LUCAS,  FGM.announcer.names.LUCAS,          1.50,   0x00010002, series_logo.EARTHBOUND,   name_texture.LUCAS,         portrait_lucas, -1)
    add_to_css(Character.id.JLINK,  FGM.announcer.names.LINK,           1.50,   0x00010001, series_logo.ZELDA,        name_texture.LINK,          portrait_unknown, 4)
    add_to_css(Character.id.JFALCON,FGM.announcer.names.CAPTAIN_FALCON, 1.50,   0x00010001, series_logo.FZERO,        name_texture.CAPTAIN_FALCON,portrait_unknown, 6)
    add_to_css(Character.id.JFOX,   FGM.announcer.names.JFOX,           1.50,   0x00010004, series_logo.STARFOX,      name_texture.FOX,           portrait_unknown, 12)
    add_to_css(Character.id.JMARIO, FGM.announcer.names.MARIO,          1.50,   0x00010003, series_logo.MARIO_BROS,   name_texture.MARIO,         portrait_unknown, 2)
    add_to_css(Character.id.JLUIGI, FGM.announcer.names.LUIGI,          1.50,   0x00010001, series_logo.MARIO_BROS,   name_texture.LUIGI,         portrait_unknown, 1)
    add_to_css(Character.id.JDK,    FGM.announcer.names.DONKEY_KONG,    1.50,   0x00010001, series_logo.DONKEY_KONG,  name_texture.JDK,           portrait_unknown, 3)
    add_to_css(Character.id.EPIKA,  FGM.announcer.names.PIKACHU,        1.50,   0x00010001, series_logo.POKEMON,      name_texture.PIKACHU,       portrait_unknown, 13)
    add_to_css(Character.id.JPUFF,  FGM.announcer.names.JPUFF,          1.50,   0x00010002, series_logo.POKEMON,      name_texture.JPUFF,         portrait_unknown, 14)
    add_to_css(Character.id.EPUFF,  FGM.announcer.names.JIGGLYPUFF,     1.50,   0x00010002, series_logo.POKEMON,      name_texture.JIGGLYPUFF,    portrait_unknown, 14)
    add_to_css(Character.id.JKIRBY, FGM.announcer.names.KIRBY,          1.50,   0x00010003, series_logo.KIRBY,        name_texture.KIRBY,         portrait_unknown, 11)
    add_to_css(Character.id.JYOSHI, FGM.announcer.names.YOSHI,          1.50,   0x00010002, series_logo.YOSHI,        name_texture.YOSHI,         portrait_unknown, 10)
    add_to_css(Character.id.JPIKA,  FGM.announcer.names.PIKACHU,        1.50,   0x00010001, series_logo.POKEMON,      name_texture.PIKACHU,       portrait_unknown, 13)
    add_to_css(Character.id.ESAMUS, FGM.announcer.names.ESAMUS,         1.50,   0x00010003, series_logo.METROID,      name_texture.SAMUS,         portrait_unknown, 5)
}

} // __CHARACTER_SELECT__
