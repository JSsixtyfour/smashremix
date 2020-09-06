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
	dw  0x11020 + 0x200                     // 0x34 - BOWSER
	dw  0xFA40 + 0x200                      // 0x35 - GBOWSER

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

        addiu   sp, sp,-0x0020              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      ra, 0x0010(sp)              // save registers

        // discard values past given y value
        sltiu   t0, v1, 86                  // if ypos greater than given value
        beqz    t0, _end                    // ...return
        lli     v0, Character.id.NONE       // v0 = ret = NONE

        // use different algorithm for 12cb
        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb
        beqz    t0, _normal                 // if not 12cb, calculate normally
        nop                                 // otherwise, we'll have to do some different calculations

        jal     TwelveCharBattle.get_character_id_
        addiu   a1, a1, START_X             // a1 = xpos, unadjusted
        b       _end
        nop

        _normal:
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
        lw      t2, 0x000C(sp)              // ~
        lw      ra, 0x0010(sp)              // save registers
        addiu   sp, sp, 0x0020              // deallocate stack space
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
        jal     Global.get_random_int_alt_  // original line 1
        addiu   a0, r0, NUM_SLOTS           // original line 2 modified to include all slots
        // v0 = random number between 0 and NUM_SLOTS

        // Check if 12cb and if so check if character is defeated/invalid for port or not
        li      s0, TwelveCharBattle.twelve_cb_flag
        lw      s0, 0x0000(s0)              // s0 = 1 if 12cb
        beqz    s0, _not_12cb               // if not 12cb, skip defeated check
        nop

        lli     a0, NUM_COLUMNS             // a0 = NUM_COLUMNS
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
        lli     t0, NUM_COLUMNS             // ~
        divu    v0, t0                      // ~
        mfhi    t1                          // t1 = portrait_id % NUM_COLUMNS = column
        lli     t0, PORTRAIT_WIDTH          // ~
        multu   t0, t1                      // ~
        mflo    t2                          // t2 = ulx
        addiu   t2, t2, START_X + 12        // t2 = (int) ulx + offset

        li      t0, TwelveCharBattle.twelve_cb_flag
        lw      t0, 0x0000(t0)              // t0 = 1 if 12cb mode
        beqz    t0, _continue               // skip if not 12cb
        nop
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
    macro set_white_flash_texture(check_12cb) {
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

        lli     t3, NUM_COLUMNS             // t3 = NUM_COLUMNS
        divu    s0, t3                      // mflo = ROW, mfhi = COLUMN
        mfhi    t0                          // t0 = COLUMN
        mflo    t1                          // t1 = ROW

        lli     t2, PORTRAIT_WIDTH          // t2 = PORTRAIT_WIDTH
        multu   t0, t2                      // t2 = COLUMN * PORTRAIT_WIDTH
        mflo    t2                          // ~
        addiu   t2, t2, START_X + START_VISUAL // t2 = ulx, adjusted for left padding

        if {check_12cb} == OS.TRUE {
            jal     TwelveCharBattle.adjust_white_flash_position_
            nop
        }

        mtc1    t2, f0                      // f0 = ulx
        cvt.s.w f0, f0                      // ~
        swc1    f0, 0x0058(v0)              // set ulx

        lli     t2, PORTRAIT_HEIGHT         // t2 = PORTRAIT_HEIGHT
        multu   t1, t2                      // t2 = ROW * PORTRAIT_HEIGHT
        mflo    t2                          // ~
        addiu   t2, t2, START_Y + START_VISUAL // t2 = uly, adjusted for top padding
        mtc1    t2, f0                      // f0 = uly
        cvt.s.w f0, f0                      // ~
        swc1    f0, 0x005C(v0)              // set uly
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

    set_white_flash_texture(OS.TRUE)

    j       0x801365BC                  // skip rest of routine
    nop
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

    set_white_flash_texture(OS.FALSE)

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

    set_white_flash_texture(OS.FALSE)

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

    set_white_flash_texture(OS.FALSE)

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
    // This patch increases the heap space by moving it to expansion RAM.
    // This enables us to load an unlimited number of character models.
    // It also ensures large stages don't crash with large characters.
    // NOTE: As RAM starts to fill up, this will stop working!
    scope increase_heap_: {
        OS.patch_start(0x7450, 0x80006850)
        jal     increase_heap_
        nop
        _increase_heap_return:
        OS.patch_end()

        lw      a0, 0x000C(a0)              // original line 2 (original start of heap)
        li      a1, free_memory_pointer     // a1 = pointer to free memory for loading custom files
        sw      a0, 0x0000(a1)              // use original heap start as free memory location

        li      a0, custom_heap             // a0 = address of start of our custom heap
        lui     a1, 0x8080                  // a1 = 0x80800000 (end of expansion RAM)
        subu    a1, a1, a0                  // a1 = custom heap size, filling to end of expansion RAM
        jal     0x80004950                  // original line 1
        nop
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

        addiu   sp, sp, -0x000C             // allocate stack space
        sw      v1, 0x0004(sp)              // ~
        sw      ra, 0x0008(sp)              // ~

        lhu     t8, 0x0002(t8)              // unique press button state

        li      v1, TwelveCharBattle.twelve_cb_flag
        lw      v1, 0x0000(v1)              // v1 = 1 if 12cb mode
        beqz    v1, _not_12cb               // if not 12cb mode, continue normally
        nop

        // jump to 12cb's input code and skip the variant stuff
        jal     TwelveCharBattle.check_input_
        nop
        b       _end_vs
        nop

        _not_12cb:
        jal     _shared                     // call main routine (shared between vs and training)
        addu    v1, v0, r0                  // v1 = pointer to player CSS struct

        _end_vs:
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
        // special
        constant METAL(0x00001078)
        constant GDONKEY(0x000031F8)
		constant GBOWSER(0x00014EB8)
        // custom
        constant FALCO(0x0000D978)
        constant GND(0x0000EA38)
        constant YLINK(0x0000FAF8)
        constant DRM(0x00010BB8)
        constant DSAMUS(0x00011C78)
        constant WARIO(0x00012D38)
        constant LUCAS(0x00013DF8)
        constant BOWSER(0x00014EB8)
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
        define slot_20(BOWSER)
        define slot_21(NONE)
        define slot_22(NONE)
        define slot_23(NONE)
        define slot_24(NONE)
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
        lli     a0, 0x1B                    // a0 = room
        lli     a1, 0x12                    // a1 = group
        addu    a2, s4, s5                  // a2 = address of portrait offset
        lw      a2, 0x0000(a2)              // a2 = portrait offset
        addu    a2, s3, a2                  // a2 = image footer

        sltiu   t2, t0, NUM_COLUMNS / 2     // t2 = 1 if left of middle, 0 if right of middle
        bnezl   t2, _get_y                  // set ulx appropriately:
        lui     s1, 0xC1A0                  // s1 = ulx when left of middle (-20)
        lui     s1, 0x439B                  // s1 = ulx when right of middle (310)

        _get_y:
        lli     t2, PORTRAIT_HEIGHT         // t2 = PORTRAIT_HEIGHT
        multu   t1, t2                      // t2 = ROW * PORTRAIT_HEIGHT
        mflo    t2                          // ~
        addiu   t2, t2, START_Y + START_VISUAL // t2 = uly, adjusted for top padding
        mtc1    t2, f0                      // f0 = uly
        cvt.s.w f0, f0                      // ~
        mfc1    s2, f0                      // s2 = uly

        li      s3, 0xFFFFFFFF              // s3 = color
        li      s4, 0x00000000              // s4 = palette
        jal     Render.draw_texture_
        lui     s5, 0x3F80                  // s5 = scale

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
    float32 -11.8                             // column 5
    float32 -7.8                              // column 6
    float32 -3.8                              // column 7
    float32 -1.8                              // column 8

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

    // @ Description
    // Settings for the different CSS pages for easy access
    css_settings:
    // # panels;  // room     // X padding  // panel offset
    db 0x04;      db 0x20;    db 34;        db 69            // VS
    db 0x01;      db 0x1E;    db 38;        db 69            // 1P
    db 0x02;      db 0x20;    db 65;        db 132           // TRAINING
    db 0x01;      db 0x1E;    db 71;        db 69            // BONUS
    db 0x01;      db 0x1E;    db 71;        db 69            // BONUS

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
        lbu     s1, 0x0001(t0)              // s1 = room
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

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      ra, 0x0004(sp)              // ~
        sw      a0, 0x0008(sp)              // ~
        sw      s0, 0x000C(sp)              // ~
        sw      s1, 0x0010(sp)              // ~
        sw      s2, 0x0014(sp)              // ~
        sw      s3, 0x0018(sp)              // ~
        sw      s4, 0x001C(sp)              // ~
        sw      s5, 0x0020(sp)              // save registers

        Render.load_file(File.CHARACTER_PORTRAITS, Render.file_pointer_1) // load character portraits into file_pointer_1
        Render.load_file(File.CSS_IMAGES, Render.file_pointer_2)          // load CSS images into file_pointer_2

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

        _add_dpad_image:
        // set display order to 0 to force this to render after tokens
        li      t0, Render.display_order_value
        sw      r0, 0x0000(t0)              // set order to 0 to force this to render after tokens

        lw      a0, 0x0010(sp)              // a0 = room
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
        sw      t0, 0x0038(v0)              // save normalized css player struct reference
        lw      t1, 0x0058(t0)              // t1 = initial player selected flag
        sw      t1, 0x003C(v0)              // store player selected status
        sw      r0, 0x0040(v0)              // 0 out reference to regional flag

        sw      v0, 0x0028(sp)              // save dpad object reference

        lw      a0, 0x0010(sp)              // a0 = room
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
        li      t0, Render.display_order_value
        lui     t1, Render.DISPLAY_ORDER_DEFAULT
        sw      t1, 0x0000(t0)              // reset display order

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
        sw      t4, 0x0038(t1)              // swap normalized css player struct pointers
        sw      t3, 0x0038(t2)              // ~

        _portraits:
        jal     draw_portraits_
        lli     a0, OS.FALSE                // a0 = 12cb mode flag

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

        jal     0x80136128                  // original line 1
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

        jal     0x80135804                  // original line 2
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

        jal     0x80133E30                  // original line 2
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

        jal     0x8013476C                  // original line 2
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

        // Create the variant icons object
        li      t0, Render.display_order_value
        sw      r0, 0x0000(t0)              // set display order to 0 to render after tokens
        
        lli     a0, 0x0000                  // a0 = routine (Render.NOOP)
        li      a1, Render.TEXTURE_RENDER_  // a1 = display list routine
        lbu     a2, 0x000D(t2)              // a2 = room
        lbu     a3, 0x000C(t2)              // a3 = group
        jal     Render.create_display_object_
        nop
        
        li      t0, Render.display_order_value
        lui     t1, Render.DISPLAY_ORDER_DEFAULT
        sw      t1, 0x0000(t0)              // reset display order
        
        lw      a0, 0x000C(sp)              // t2 = dpad object
        sw      v0, 0x0034(a0)              // save reference to variant icon object

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
        addiu   sp, sp, 0x0020              // deallocate stack space

        lli     t4, 0x0000                  // t4 = 0 (dpad will be displayed)

        _end:
        lw      t0, 0x0030(t2)              // t0 = dpad direction indicator object
        sw      t4, 0x007C(t0)              // update dpad direction indicator display
        jr      ra
        sw      t4, 0x007C(t2)              // update dpad display
    }

    // @ Description
    // This adds variant icons (stock icons/flags) to the dpad image
    // @ Arguments
    // a0 - dpad object RAM address
    // a1 - variant ID
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
        addiu   a1, at, 0x558               // a1 = J flag footer struct TODO: make offset a constant
        lli     t2, Character.variant_type.E
        beql    t1, t2, _draw_icon          // if an E variant, then draw E flag
        addiu   a1, at, 0x3B8               // a1 = E flag footer struct TODO: make offset a constant

        // if we're here, then we will use the character's stock icon
        lui     t1, 0x3F80                  // t1 = scale for stock icons (1.0)
        sw      t1, 0x0024(sp)              // save scale for stock icons

        li      t1, 0x80116E10              // t1 = main character struct table
        sll     t2, a1, 0x0002              // t2 = a1 * 4 (offset in struct table)
        addu    t1, t1, t2                  // t1 = pointer to character struct
        lw      t1, 0x0000(t1)              // t1 = character struct
        lw      t2, 0x0028(t1)              // t2 = main character file address pointer
        lw      t2, 0x0000(t2)              // t2 = main character file address
        lw      t1, 0x0060(t1)              // t1 = offset to attribute data
        addu    t1, t2, t1                  // t1 = attribute data address
        lw      t1, 0x0340(t1)              // t1 = pointer to stock icon footer address
        lw      a1, 0x0000(t1)              // a1 = stock icon footer address

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
        lw      t3, 0x0038(t0)              // t3 = normalized pointer to css player struct (for 0x50 and higher offsets)
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

        _flag_check:
        // here, check if flag should be drawn
        lw      t4, 0x003C(t0)              // t4 = selected flag value
        beqz    t4, _next                   // skip if not selected
        lw      a0, 0x0034(t0)              // a0 = variant icons object
        lli     a1, 0x0001                  // a1 = 1 (display off)
        bnezl   a0, pc() + 8                // if there is a variant icons object, turn its display of
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
        b       _next
        nop

        _draw_flag:
        lw      t1, 0x0040(t0)              // t1 = flag object pointer
        bnez    t1, _next                   // skip if flag object defined already
        nop

        li      t1, Render.display_order_value
        sw      r0, 0x0000(t1)              // set display order to 0 to render after tokens

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

        li      t0, Render.display_order_value
        lui     t1, Render.DISPLAY_ORDER_DEFAULT
        sw      t1, 0x0000(t0)              // reset display order

        _next:
        // ensure the direction indicator is correctly positioned
        lw      t0, 0x0000(s1)              // t0 = dpad image object address
        lw      t4, 0x0038(t0)              // t4 = normalized css player struct
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
        dw  {logo}
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
               // id                fgm                             circle size   action    series logo               name texture                 portrait offset                  portrait override
    add_to_css(Character.id.FALCO,  FGM.announcer.names.FALCO,          1.50,   0x00010004, series_logo.STARFOX,      name_texture.FALCO,          portrait_offsets.FALCO,          -1)
    add_to_css(Character.id.GND,    FGM.announcer.names.GANONDORF,      1.50,   0x00010002, series_logo.ZELDA,        name_texture.GND,            portrait_offsets.GND,            -1)
    add_to_css(Character.id.YLINK,  FGM.announcer.names.YOUNG_LINK,     1.50,   0x00010002, series_logo.ZELDA,        name_texture.YLINK,          portrait_offsets.YLINK,          -1)
    add_to_css(Character.id.DRM,    FGM.announcer.names.DR_MARIO,       1.50,   0x00010001, series_logo.DR_MARIO,     name_texture.DRM,            portrait_offsets.DRM,            -1)
    add_to_css(Character.id.WARIO,  FGM.announcer.names.WARIO,          1.50,   0x00010004, series_logo.MARIO_BROS,   name_texture.WARIO,          portrait_offsets.WARIO,          -1)
    add_to_css(Character.id.DSAMUS, FGM.announcer.names.DSAMUS,         1.50,   0x00010004, series_logo.METROID,      name_texture.DSAMUS,         portrait_offsets.DSAMUS,         -1)
    add_to_css(Character.id.ELINK,  FGM.announcer.names.ELINK,          1.50,   0x00010001, series_logo.ZELDA,        name_texture.LINK,           portrait_offsets.ELINK,          4)
    add_to_css(Character.id.JSAMUS, FGM.announcer.names.SAMUS,          1.50,   0x00010003, series_logo.METROID,      name_texture.SAMUS,          portrait_offsets.JSAMUS,         5)
    add_to_css(Character.id.JNESS,  FGM.announcer.names.NESS,           1.50,   0x00010002, series_logo.EARTHBOUND,   name_texture.NESS,           portrait_offsets.JNESS,          9)
    add_to_css(Character.id.LUCAS,  FGM.announcer.names.LUCAS,          1.50,   0x00010002, series_logo.EARTHBOUND,   name_texture.LUCAS,          portrait_offsets.LUCAS,          -1)
    add_to_css(Character.id.JLINK,  FGM.announcer.names.LINK,           1.50,   0x00010001, series_logo.ZELDA,        name_texture.LINK,           portrait_offsets.JLINK,          4)
    add_to_css(Character.id.JFALCON,FGM.announcer.names.CAPTAIN_FALCON, 1.50,   0x00010001, series_logo.FZERO,        name_texture.CAPTAIN_FALCON, portrait_offsets.JFALCON,        6)
    add_to_css(Character.id.JFOX,   FGM.announcer.names.JFOX,           1.50,   0x00010004, series_logo.STARFOX,      name_texture.FOX,            portrait_offsets.JFOX,           12)
    add_to_css(Character.id.JMARIO, FGM.announcer.names.MARIO,          1.50,   0x00010003, series_logo.MARIO_BROS,   name_texture.MARIO,          portrait_offsets.JMARIO,         2)
    add_to_css(Character.id.JLUIGI, FGM.announcer.names.LUIGI,          1.50,   0x00010001, series_logo.MARIO_BROS,   name_texture.LUIGI,          portrait_offsets.JLUIGI,         1)
    add_to_css(Character.id.JDK,    FGM.announcer.names.DONKEY_KONG,    1.50,   0x00010001, series_logo.DONKEY_KONG,  name_texture.JDK,            portrait_offsets.JDK,            3)
    add_to_css(Character.id.EPIKA,  FGM.announcer.names.PIKACHU,        1.50,   0x00010001, series_logo.POKEMON,      name_texture.PIKACHU,        portrait_offsets.EPIKA,          13)
    add_to_css(Character.id.JPUFF,  FGM.announcer.names.JPUFF,          1.50,   0x00010002, series_logo.POKEMON,      name_texture.JPUFF,          portrait_offsets.JPUFF,          14)
    add_to_css(Character.id.EPUFF,  FGM.announcer.names.JIGGLYPUFF,     1.50,   0x00010002, series_logo.POKEMON,      name_texture.JIGGLYPUFF,     portrait_offsets.EPUFF,          14)
    add_to_css(Character.id.JKIRBY, FGM.announcer.names.KIRBY,          1.50,   0x00010003, series_logo.KIRBY,        name_texture.KIRBY,          portrait_offsets.JKIRBY,         11)
    add_to_css(Character.id.JYOSHI, FGM.announcer.names.YOSHI,          1.50,   0x00010002, series_logo.YOSHI,        name_texture.YOSHI,          portrait_offsets.JYOSHI,         10)
    add_to_css(Character.id.JPIKA,  FGM.announcer.names.PIKACHU,        1.50,   0x00010001, series_logo.POKEMON,      name_texture.PIKACHU,        portrait_offsets.JPIKA,          13)
    add_to_css(Character.id.ESAMUS, FGM.announcer.names.ESAMUS,         1.50,   0x00010003, series_logo.METROID,      name_texture.SAMUS,          portrait_offsets.ESAMUS,         5)
    add_to_css(Character.id.BOWSER, FGM.announcer.names.BOWSER,         1.50,   0x00010002, series_logo.BOWSER,       name_texture.BOWSER,         portrait_offsets.BOWSER,         -1)
	add_to_css(Character.id.GBOWSER,FGM.announcer.names.GBOWSER,        1.50,   0x00010002, series_logo.BOWSER,       name_texture.GBOWSER,        portrait_offsets.GBOWSER,        19)
}

} // __CHARACTER_SELECT__
