// SwordTrail.asm
if !{defined __SWORDTRAIL__} {
define __SWORDTRAIL__()
print "included SwordTrail.asm\n"

// This file adds support for custom sword trail types.

scope SwordTrail {
    variable new_trail_count(0)       // number of new sword trails
    
    // @ Description
    // Sword trail struct constants.
    scope struct {
        constant character(0x00)
        constant model_part(0x02)
        constant colour_1(0x04)
        constant colour_2(0x08)
        constant start_pos(0x0C)
        constant end_pos(0x10)
    }
    
    // @ Description
    // Add a new sword trail.
    // name - sword trail name, used for display only
    // character - u16 character id which is allowed to use this sword trail
    // model_part - u16 model part/bone to attach the sword trail to
    // colour_1 - RGBA32 colour for the base of the sword trail
    // colour_2 - RGBA32 colour for the end of the sword trail
    // start_pos - float32 position for the base of the sword trail
    // end_pos - float32 position for the end of the sword trail
    macro add_sword_trail(name, character, model_part, colour_1, colour_2, start_pos, end_pos) {
        global variable new_trail_count(new_trail_count + 1)
        evaluate n(new_trail_count)
        // add sword trail parameters
        global define sword_trail_{n}_name({name})
        global define sword_trail_{n}_character({character})
        global define sword_trail_{n}_model_part({model_part})
        global define sword_trail_{n}_colour_1({colour_1})
        global define sword_trail_{n}_colour_2({colour_2})
        global define sword_trail_{n}_start_pos({start_pos})
        global define sword_trail_{n}_end_pos({end_pos})
        // print message
        print "Added Sword Trail: {name} - Moveset command is 0x" ; OS.print_hex(0xCC04 + (new_trail_count * 0x4)) ; print "0000 \n"
    }
    

    // @ Description
    // Writes new sword trails to the ROM, creates and populates sword_trail_table
    macro write_sword_trails() {
        // add sword trail structs
        evaluate n(1)
        while {n} <= new_trail_count {
            // add struct
            constant STRUCT_{n}(pc())
            dh      {sword_trail_{n}_character}
            dh      {sword_trail_{n}_model_part}
            dw      {sword_trail_{n}_colour_1}
            dw      {sword_trail_{n}_colour_2}
            float32 {sword_trail_{n}_start_pos}
            float32 {sword_trail_{n}_end_pos}
            // increment
            evaluate n({n}+1)
        }
        
        // Define a table containing pointers to each sword trail struct
        sword_trail_table:
        // Pad out the first two slots in this table for the original 2 sword trail IDs..
        // ..this probably saves space compared to subtracting 2 from the ID in the ASM routines.
        dw  0                               // 0x00
        dw  0                               // 0x01
        // add new sword trails
        evaluate n(1)
        while {n} <= new_trail_count {
            // add struct pointer to table
            dw  STRUCT_{n}
            // increment
            evaluate n({n}+1)
        }
    }
    
    // ADD NEW SWORD TRAILS HERE
    
    print "============================== SWORD TRAILS ============================== \n"
    
    // name - sword trail name, used for display only
    // character - character id to be used by this sword trail
    // model_part - model part/bone to attach the sword trail to
    // colour_1 - RGBA32 colour for the base of the sword trail
    // colour_2 - RGBA32 colour for the end of the sword trail
    // start_pos - float32 position for the base of the sword trail
    // end_pos - float32 position for the end of the sword trail
    
    add_sword_trail(marth_default_trail, Character.id.MARTH, 0xE, 0x00FFFF00, 0xFFFFFF00, 70, 370)
    add_sword_trail(conker_katana_trail, Character.id.CONKER, 0xD, 0x00FFFF00, 0xFFFFFF00, 150, 800)
    add_sword_trail(marth_nsp_red_trail, Character.id.MARTH, 0xE, 0xFF000000, 0xFFFFFF00, 70, 370)
    add_sword_trail(marth_nsp_blue_trail, Character.id.MARTH, 0xE, 0x0050FF00, 0xFFFFFF00, 70, 370)
    add_sword_trail(marth_nsp_green_trail, Character.id.MARTH, 0xE, 0x00FF0000, 0xFFFFFF00, 70, 370)
    add_sword_trail(kirby_marth_red_trail, -1, 0xD, 0xFF000000, 0xFFFFFF00, 50, 300)
    add_sword_trail(kirby_marth_blue_trail, -1, 0xD, 0x0050FF00, 0xFFFFFF00, 50, 300)
    add_sword_trail(kirby_marth_green_trail, -1, 0xD, 0x00FF0000, 0xFFFFFF00, 50, 300)
    add_sword_trail(sonic_trail, -1, 0x1A, 0x00D0FF00, 0x0090FF00, -190, 190)
    add_sword_trail(ssonic_trail, -1, 0x1A, 0xeeff5f00, 0xe4d72600, -190, 190)
	add_sword_trail(dedede_hammer, Character.id.DEDEDE, 0xE, 0xEEEEEE00, 0xB68E5600, -576, -192)
    // write sword trails to ROM  
    write_sword_trails()
    
    print "========================================================================== \n"
    
    // ASM PATCHES
    
    // @ Description
    // Modifies an original routine which sets up the initial properties of a sword trail.
    // Our custom sword trails will be treated as a Link sword trail, however the character ID to
    // check for and the part number to attach to the trail to will be loaded from our struct.
    scope initial_setup_: {
        OS.patch_start(0x61F40, 0x800E6740)
        j       initial_setup_
        lbu     a1, 0x0A9C(s0)              // original line 1
        _return:
        OS.patch_end()
        
        // s0 = player struct
        // a1 = sword trail id
        // check if the sword trail id is within the range of custom ids
        sltiu   at, a1, 0x2                 // at = 1 if sword trail id < 2; else at = 0
        bnel    at, r0, _original           // branch if at = 1 (sword trail is original)
        addiu   at, r0, 0x0001              // original line 2
        sltiu   at, a1, new_trail_count + 2 // at = 1 if sword trail id < new_trail_count + 2; else at = 0
        beql    at, r0, _original           // branch if at = 0 (sword trail does not exist)
        addiu   at, r0, 0x0001              // original line 2
        
        _custom:
        // get the struct for the current sword trail
        li      at, sword_trail_table       // at = sword_trail_table
        sll     a1, a1, 0x2                 // ~
        addu    at, at, a1                  // ~
        lw      at, 0x0000(at)              // at = sword_trail_struct
        
        
        // check if the current character id matches the character id in the struct
        lhu     a1, struct.character(at)    // a1 = character
        lli     t8, 0xFFFF                  // t8 = -1
        beq     a1, t8, _continue           // continue if no character is specified
        lw      t8, 0x0008(s0)              // t8 = current character id
        bnel    a1, t8, _original           // branch if character id does not match
        addiu   at, r0, 0x0001              // original line 2
        
        
        // load the bone struct for model_part, this is what the sword trail will attach to
        _continue:
        addiu   t8, s0, 0x08F8              // t8 = bone structs base + 0x10 (start at model part 0)
        lhu     a1, struct.model_part(at)   // a1 = model_part
        sll     a1, a1, 0x2                 // ~
        addu    t8, t8, a1                  // ~
        lw      a0, 0x0000(t8)              // a0 = bone struct for model_part
        j       0x800E6780                  // continue sword trail setup as if it's a Link sword trail
        nop
        
        _original:
        j       _return                     // return
        lbu     a1, 0x0A9C(s0)              // original line 1
    }
    
    // @ Description
    // Modifies a secondary check for allowed sword trail ids. This one seems totally useless but
    // we'll just follow the standards set by the original code.
    scope second_check_: {
        OS.patch_start(0x6DD3C, 0x800F253C)
        j       second_check_
        lbu     v0, 0x0A9C(a1)              // original line 1
        _return:
        OS.patch_end()
        
        // a1 = player struct
        // v0 = sword trail id
        // check if the sword trail id is within the range of custom ids
        sltiu   at, v0, 0x2                 // at = 1 if sword trail id < 2; else at = 0
        bnel    at, r0, _original           // branch if at = 1 (sword trail is original)
        addiu   at, r0, 0x0001              // original line 2
        sltiu   at, v0, new_trail_count + 2 // at = 1 if sword trail id < new_trail_count + 2; else at = 0
        beq     at, r0, _original           // branch if at = 0 (sword trail does not exist)
        addiu   at, r0, 0x0001              // original line 2
        
        _custom:
        j       0x800F255C                  // pass through check as if it's a Link sword trail
        nop
        
        _original:
        j       _return                     // return
        nop
    }
    
    // @ Description
    // Modifies an original routine which sets up sword trail properties before drawing the sword trail.
    // Loads new colour and position properties for custom sword trails.
    scope draw_trail_: {
        OS.patch_start(0x6C860, 0x800F1060)
        j       draw_trail_
        or      s2, a0, r0                  // original line 2
        _return:
        OS.patch_end()
        
        // s2 = player struct
        // v0 = sword trail id
        lbu     v0, 0x0A9C(a0)              // original line 1
        // check if the sword trail id is within the range of custom ids
        sltiu   at, v0, 0x2                 // at = 1 if sword trail id < 2; else at = 0
        bne     at, r0, _original           // branch if at = 1 (sword trail is original)
        sltiu   at, v0, new_trail_count + 2 // at = 1 if sword trail id < new_trail_count + 2; else at = 0
        beq     at, r0, _original           // branch if at = 0 (sword trail does not exist)
        nop
        
        _custom:
        lbu     v1, 0x0A9E(a0)              // original line 3
        lui     s5, 0x8004                  // original line 5
        // get the struct for the current sword trail
        li      t6, sword_trail_table       // t6 = sword_trail_table
        sll     at, v0, 0x2                 // ~
        addu    t6, t6, at                  // ~
        lw      t6, 0x0000(t6)              // t6 = sword_trail_struct
        // load sword trail properties from struct
        lwc1    f20, struct.start_pos(t6)   // f20 = start_pos
        lwc1    f22, struct.end_pos(t6)     // f22 = end_pos
        addiu   s7, t6, struct.colour_1     // s7 = colour_1 address
        addiu   s8, t6, struct.colour_2     // s8 = colour_2 address
        // replicate original setup logic
        addiu   t6, r0, 0x00FF              // t6 = 0xFF, not sure what this value is, maybe alpha
        li      t7, 0x8012C490              // t7 = 0x8012C490, some kind of display list?
        li      t8, 0x8012C4B0              // t8 = 0x8012C4B0, some kind of display list?
        lui     at, 0x8013                  // ~
        lwc1    f28, 0x0260(at)             // f28 = float 0x80130260, not sure what this is used for
        sw      t8, 0x00D8(sp)              // store t8 to 0x00D8(sp), original logic
        sw      t7, 0x00DC(sp)              // store t7 to 0x00DC(sp), original logic
        sw      t6, 0x00F4(sp)              // store t6 to 0x00F4(sp), original logic
        sw      r0, 0x00F8(sp)              // store r0 to 0x00F8(sp), original logic
        j       0x800F1130                  // continue drawing sword trail
        nop
        
        _original:
        j       _return                     // return
        nop
    }
}
}