// GFX.asm
if !{defined __GFX__} {
define __GFX__()
print "included GFX.asm\n"

// @ Description
// This file allows new GFX (graphics effects) to be created.

include "OS.asm"

scope GFX {

    scope TEXTURE {
        constant FOOTSTEP_SMOKE(0x11)
        constant JUMP_SMOKE(0x13)
        constant JUMP_SKID(0x15)
        constant WHITE_SPARK(0x31)
        constant SHOCK_WAVE(0x33)
    }

    variable new_gfx_count(0)                            // Number of new graphics effects added
    variable new_gfx_texture_block_count(0)              // Number of new gfx texture blocks added
    variable current_gfx_texture_count(0)                // Number of gfx textures in the current gfx texture block

    // @ Description
    // Stores the current gfx_id for custom use during GFX processing.
    // When 0, default functionality occurs.
    current_gfx_id:
    dw 0

    // @ Description
	// This may be necessary to ensure something below is aligned for console
	OS.align(16)

    // @ Description
    // Modifies routines that load GFX Instructions so that we can use a custom GFX_INSTRUCTIONS_ID
    scope augment_gfx_instructions_loader_: {
        OS.patch_start(0x4A3CC, 0x800CE9EC)
        sw      ra, 0x0014(sp)                        // original line 3
        jal     augment_gfx_instructions_loader_
        nop
        OS.patch_end()
        OS.patch_start(0x4A25C, 0x800CE87C)
        jal     augment_gfx_instructions_loader_
        nop
        OS.patch_end()

        // a1 = GFX_INSTRUCTIONS_ID

        li      at, current_gfx_id                     // at = current_gfx_id address
        lw      a2, 0x0000(at)                         // a2 = current_gfx_id - nonzero if a new gfx_id
        beqzl   a2, _original                          // if not set, then use default values
        or      a2, a1, r0                             // original line 1

        // if we're here, then we have a new gfx_id and need to load the new gfx_instructions_id
        li      a1, gfx_id_to_gfx_instructions_id_map  // a1 = gfx_id_to_gfx_instructions_id_map
        addiu   a2, a2, -0x005C                        // a2 = slot in table
        sll     a2, a2, 0x2                            // a2 = offset in table
        addu    a1, a1, a2                             // a1 = address of gfx_instructions_id
        lw      a2, 0x0000(a1)                         // a2 = gfx_instructions_id
        sw      r0, 0x0000(at)                         // clear current_gfx_id

        _original:
        or      a1, a0, r0                             // original line 2
        jr      ra
        nop
    }

    // @ Description
    // Modifies the routine that maps GFX IDs in moveset commands to GFX routines so that we can use an extended table
    scope extend_gfx_command_jump_table_: {
        OS.patch_start(0x666A4, 0x800EAEA4)
        j       extend_gfx_command_jump_table_
        nop
        OS.patch_end()

        slti    at, t8, 0x005C                           // check if ID is less than 0x5C, which means it's an original GFX ID
        beqz    at, _new_gfx_id                          // if it is a new GFX ID, then branch
        nop                                              // else return to original routine:
        sll     t8, t8, 0x2                              // original line 1
        lui     at, 0x8013                               // original line 2
        j       0x800EAEAC                               // return to original routine
        nop

        _new_gfx_id:
        li      at, current_gfx_id                       // at = address of current_gfx_id
        sw      t8, 0x0000(at)                           // store current_gfx_id
        li      at, extended_gfx_command_jump_table      // at = address of extended table
        addiu   t8, t8, -0x005C                          // t8 = slot in extended table
        sll     t8, t8, 0x2                              // t8 = offset in extended table
        addu    at, at, t8                               // at = address of address of GFX routine
        lw      t8, 0x0000(at)                           // t8 = address of GFX routine
        jr      t8                                       // jump to GFX routine
        nop                                              // ~
    }

    // @ Description
    // Modifies the routine that maps GFX Instruction IDs to GFX instructions so that we can use an extended table
    scope extend_gfx_instructions_map_: {
        OS.patch_start(0x4A0D0, 0x800CE6F0)
        j       extend_gfx_instructions_map_
        nop
        _return:
        OS.patch_end()

        addu    t8, t8, v1                               // original line 1
        slti    at, t6, 0x0077                           // check if ID is less than 0x77, which means it's an original GFX_INSTRUCTIONS_ID
        beqz    at, _new_gfx_instructions_id             // if it is a new GFX_INSTRUCTIONS_ID, then branch
        nop                                              // else return to original routine:
        slt     at, t6, t7                               // original line 2
        j       _return                                  // return to original routine
        nop

        _new_gfx_instructions_id:
        li      at, extended_gfx_instructions_map        // at = address of extended table
        addiu   t6, t6, -0x0077                          // t6 = slot in extended table
        sll     t6, t6, 0x2                              // t6 = offset in extended table
        addu    at, at, t6                               // at = address of address of GFX instructions
        lw      v0, 0x0000(at)                           // v0 = address of GFX instructions
        mtc1    r0, f0                                   // original line (important)
        j       0x800CE71C                               // return after v0 is originally set
        nop                                              // ~
    }

    // @ Description
    // Modifies the routine that maps GFX Texture Block IDs to GFX Texture Blocks so that we can use an extended table
    scope extend_gfx_texture_block_map_: {
        OS.patch_start(0x4A13C, 0x800CE75C)
        j       extend_gfx_texture_block_map_
        nop
        OS.patch_end()

        // a3 is the GFX_TEXTURE_BLOCK_ID

        slti    t6, a3, 0x002F                           // check if ID is less than 0x2F, which means it's an original GFX_TEXTURE_BLOCK_ID
        bnez    t6, _normal                              // if it is not a new GFX_TEXTURE_BLOCK_ID, then branch
        nop                                              // else determine extended table address and offset:
        li      t4, extended_gfx_texture_block_map       // t4 = address of extended table
        addiu   t5, a3, -0x002F                          // t5 = slot in extended table
        sll     t5, t5, 0x2                              // t5 = offset in extended table

        _normal:
        addu    t6, t4, t5                               // original line 1
        swc1    f6, 0x0028(sp)                           // original line 2
        j       0x800CE764                               // return
        nop                                              // ~
    }

    // @ Description
    // Modifies the routine that references GFX Texture Block IDs within GFX instructions so that we can use an extended table
    scope extend_referenced_gfx_texture_block_map_: {
        OS.patch_start(0x4F190, 0x800D37B0)
        j       extend_referenced_gfx_texture_block_map_
        lw      t2, 0x0000(t1)                          // original line 1
        OS.patch_end()

        // t3 is the GFX_TEXTURE_BLOCK_ID
        lhu     t3, 0x0002(t2)                          // original line 2

        slti    t6, t3, 0x002F                           // check if ID is less than 0x2F, which means it's an original GFX_TEXTURE_BLOCK_ID
        bnez    t6, _normal                              // if it is not a new GFX_TEXTURE_BLOCK_ID, then branch
        nop                                              // else determine extended table address and offset:
        li      t9, extended_gfx_texture_block_map       // t9 = address of extended table
        addiu   t3, t3, -0x002F                          // t3 = slot in extended table

        _normal:
        j       0x800D37B8                               // return
        nop                                              // ~
    }

    // @ Description
    // Modifies the render routine that maps GFX Texture Block IDs to GFX Texture Blocks so that we can use an extended table
    scope extend_gfx_texture_block_map_render_: {
        OS.patch_start(0x4D0D4, 0x800D16F4)
        j       extend_gfx_texture_block_map_render_
        nop
        OS.patch_end()

        // t7 is the GFX_TEXTURE_BLOCK_ID

        slti    t8, t7, 0x002F                           // check if ID is less than 0x2F, which means it's an original GFX_TEXTURE_BLOCK_ID
        bnez    t8, _normal                              // if it is not a new GFX_TEXTURE_BLOCK_ID, then branch
        nop                                              // else determine extended table address and offset:
        li      t6, extended_gfx_texture_block_map       // t6 = address of extended table
        addiu   t8, t7, -0x002F                          // t8 = slot in extended table
        sll     t8, t8, 0x2                              // t8 = offset in extended table
        j       0x800D1700                               // return
        nop

        _normal:
        addu    t6, t6, t9                               // original line 1
        lw      t6, 0x6420(t6)                           // original line 2
        j       0x800D16FC                               // return
        nop                                              // ~
    }

    // @ Description
    // Adds a new GFX Texture block
    // name - Used for display only
    // num_textures - The number of textures to be added to the block
    // tile_format - Tile Format Encoding - 0:RGBA, 1:YUV, 2:CI, 3:IA, 4:I
    // texture_tile_size - Size of Texels in Texture Tile - 0:4, 1:8, 2:16, 3:32
    // width - Texture width
    // height - Texture height
    macro add_gfx_texture_block(name, num_textures, tile_format, texture_tile_size, width, height) {
        global variable new_gfx_texture_block_count(new_gfx_texture_block_count + 1) // increment new_gfx_texture_block_count
        evaluate n(new_gfx_texture_block_count)
        print " - Added GFX_TEXTURE_BLOCK_ID 0x"; OS.print_hex(0x2E + new_gfx_texture_block_count); print ": {name}\n"
        global variable current_gfx_texture_count(0)                                 // reset current_gfx_texture_count to 0

        OS.align(16)

        gfx_texture_block_{n}:
        global variable gfx_texture_block_{n}_origin(origin())
        dw      {num_textures}                           // number of textures in block
        dw      {tile_format}                            // Tile Format Encoding - 0:RGBA, 1:YUV, 2:CI, 3:IA, 4:I
        dw      {texture_tile_size}                      // Size of Texels in Texture Tile - 0:4, 1:8, 2:16, 3:32
        dw      {width}                                  // Texture width
        dw      {height}                                 // Texture height
        dw      0x00000001                               // ?
        // next words are the pointers to the textures
        fill    {num_textures} * 4, 0x00

        OS.align(16)
    }

    // @ Description
    // Adds a new GFX Texture to the current GFX Texture Block
    // filename - The filename of the texture to be added to the block
    macro add_gfx_texture(filename) {
        evaluate n(new_gfx_texture_block_count)
        global variable current_gfx_texture_count(current_gfx_texture_count + 1) // increment current_gfx_texture_count
        evaluate i(current_gfx_texture_count)
        print "    - Texture 0x"; OS.print_hex(current_gfx_texture_count); print ": {filename}\n"

        // insert the texture
        gfx_texture_{n}_{i}:
        insert "{filename}"
        OS.align(16)
        variable texture_end(origin())

        // update the pointer in the texture block
        origin  gfx_texture_block_{n}_origin + 0x14 + ({i} * 4)
        dw      gfx_texture_{n}_{i}

        // return to end of texture
        origin  texture_end
    }

    // @ Description
    // Adds a new GFX
    // name - Used for display only
    // instructions_filename - The file containing the GFX instructions
    // base_gfx_id - original gfx_id used as a basis for the new GFX
    macro add_gfx(name, instructions_filename, base_gfx_id) {
        global variable new_gfx_count(new_gfx_count + 1) // increment new_gfx_count
        evaluate n(new_gfx_count)
        print " - Added GFX_ID 0x"; OS.print_hex(0x5B + new_gfx_count); print " (Command ID "; OS.print_hex((0x5B + new_gfx_count) * 4); print ") with Instruction ID 0x"; OS.print_hex(0x76 + new_gfx_count); print "): {name}\n"

        // Use base_gfx_id to get RAM address from the GFX command jump table (0xAB764, 0x8012ff64)
        read32 gfx_assembly_{n}, "../roms/original.z64", 0xAB764 + ({base_gfx_id} * 4)

        // This will map this gfx_id to the new gfx_instructions_id
        global variable gfx_instructions_id_{n}(0x76 + new_gfx_count)

        gfx_instructions_{n}:
        insert "{instructions_filename}"
        OS.align(16)

        // Notes on instructions (can be removed in the future)
        // dw      0x0000002D // texture id
        // dw      0x00010022 // second halfword is number of frames
        // dw      0x00000000 // setting to FFFFFFFF makes the gfx stay on screen forever
                              // setting to 11111111 makes it disintegrate and fall to the ground
		                      // setting to 22222222 squishes horizontally and duplicates to the left
		                      // last digit is falling/disintegrating, can be 0-3
		                      // 2nd to last digit mirrors gfx on various axes
		                      // 3rd to last digit pixelizes gfx and makes it stay on the screen forever when 8 or higher
        // dw      0x3F800000 // related to position
        // dw      0x3F800000 // related to position
        // dw      0x00000000 // related to position
        // dw      0x00000000 // related to position
        // dw      0x00000000 // related to position
        // dw      0x00000000 // related to position
        // dw      0x00000000 // related to position?
        // dw      0xBF800000
        // dw      0x43700000 // scale?
        // dw      0xA0004316
        // dw      0x0000A01A // 3rd byte controls translations? animation start or type?
                              // last byte controls how long it takes to grow to the final size
        // dw      0x43AF0000 // 1st byte controls whether it shrinks or grows?
                              // 2nd byte controls final size for growing?
        // dw      0xC700FFFF // last halfword controls color
        // dw      0xFF430043 // this looks like frame data: first byte of each hw is the texture index in the block, the 2nd byte is how long
        // dw      0x01430243 // this looks like frame data: first byte of each hw is the texture index in the block, the 2nd byte is how long
        // dw      0x04eF04eF // this looks like frame data: first byte of each hw is the texture index in the block, the 2nd byte is how long
        // dw      0x05440644 // this looks like frame data: first byte of each hw is the texture index in the block, the 2nd byte is how long
        // dw      0x074208A0 // this looks like frame data: first byte of each hw is the texture index in the block, the 2nd byte is how long
        // dw      0x1B434800 // this looks like frame data: first byte of each hw is the texture index in the block, the 2nd byte is how long
        // dw      0x00FF0000
    }

    // @ Description
    // Clones the ground effect GFX with a new color
    // name - Used for display only
    // color_offset - (byte) offset from built-in palette... only use multiples of 4 for console. Known colors:
    //    0x00 - red, 0x04 - normal (yellow), 0x08 - black/blue, 0x10 - black, 0x20 - blue/black
    macro add_ground_effect_gfx(name, color_offset) {
        global variable new_gfx_count(new_gfx_count + 1) // increment new_gfx_count
        evaluate n(new_gfx_count)
        print " - Added GFX_ID 0x"; OS.print_hex(0x5B + new_gfx_count); print " (Command ID "; OS.print_hex((0x5B + new_gfx_count) * 4); print "): {name}\n"

        // The following lines are from 0x800EB0A4, the original chargeshot ground effect GFX assembly:
        gfx_assembly_{n}:
        // clear out current_gfx_id since no gfx instructions will load
        li      at, current_gfx_id                       // at = current_gfx_id address
        sw      r0, 0x0000(at)                           // clear the value

        lw      t0, 0x0054(sp)                           // original line 1 - t0 = player struct
        or      a0, s0, r0                               // original line 2 - a0 = position array
        lw      t1, 0x014C(t0)                           // original line 3 - t1 = kinetic state
        bnez    t1, _aerial_{n}                          // original line 4, modified for our label
        nop                                              // original line 5
        lw      v0, 0x00EC(t0)                           // original line 6 - v0 = clipping ID of character
        addiu   at, r0, 0xFFFF                           // original line 7 - at = -1
        beq     v0, at, _aerial_{n}                      // original line 8, modified for our label
        addiu   at, r0, 0xFFFE                           // original line 9 - at = -2
        beq     v0, at, _aerial_{n}                      // original line 10, modified for our label
        nop                                              // original line 11
        lwc1    f12, 0x00F8(t0)                          // original line 12 - related to angle of platform
        lwc1    f14, 0x00FC(t0)                          // original line 13 - related to angle of platform
        jal     0x8001863C                               // original line 14 - f0 = atan2(f12,f14)
        neg.s   f12, f12                                 // original line 15
        mfc1    a2, f0                                   // original line 16 - a2 = rotation angle
        or      a0, s0, r0                               // original line 17 - a0 = position array
        jal     0x800FFD58                               // original line 18 - create ground gfx
        addiu   a1, r0, {color_offset}                   // original line 19, modified to use custom color
        b       _size_{n}
        or      v1, v0, r0                               // original line 21 - v1 = gfx object

        _aerial_{n}:
        jal     0x800FFDE8                               // original line 22 - create ground gfx
        addiu   a1, r0, {color_offset}                   // original line 23, modified to use custom color
        or      v1, v0, r0                               // original line 25 - v1 = gfx object

        // This enables us to adjust the size of the gfx object based on character size (see Size.asm)
        _size_{n}:
        beqz    v0, _end_{n}                             // if no gfx object was created, skip
        lw      t0, 0x0054(sp)                           // t0 = player struct

        sw      t0, 0x0040(v0)                           // save reference to player struct in gfx object

        _end_{n}:
        j       0x800EB388                               // original line 20/24
        nop

        // instructions not necessary, but leave in label and variable so write_gfx() doesn't fail
        gfx_instructions_{n}:
        global variable gfx_instructions_id_{n}(0)

        OS.align(16)
    }

    // @ Description
    // Finalizes adding new GFX
    macro write_gfx() {
        extended_gfx_command_jump_table:
        define n(1)
        while {n} <= new_gfx_count {
            dw       gfx_assembly_{n}                    // pointer to gfx_assembly
            evaluate n({n}+1)
        }

        gfx_id_to_gfx_instructions_id_map:
        define n(1)
        while {n} <= new_gfx_count {
            dw       gfx_instructions_id_{n}             // gfx_instructions_id to use for this gfx_id
            evaluate n({n}+1)
        }

        extended_gfx_instructions_map:
        define n(1)
        while {n} <= new_gfx_count {
            dw       gfx_instructions_{n}                // pointer to gfx_instructions
            evaluate n({n}+1)
        }

        extended_gfx_instructions_map_pointer:
        dw      extended_gfx_instructions_map            // pointer to extended gfx instructions table

        extended_gfx_texture_block_map:
        define n(1)
        while {n} <= new_gfx_texture_block_count {
            dw       gfx_texture_block_{n}               // pointer to gfx_texture_block
            evaluate n({n}+1)
        }

        // Increase the size of the GFX command jump table size check
        pushvar base, origin
        origin  0x6669B
        db      0x5C + new_gfx_count
        pullvar origin, base
    }

    scope id {
        constant FLAME(0x4)
        constant FIRE(0x6)
        constant KIRBY_USP_SPARKLES_SECONDARY_A(0xC)
        constant KIRBY_USP_SPARKLES_SECONDARY_B(0xD)
        constant KIRBY_USP_SPARKLES_PRIMARY(0x4A)
	    constant SMOKE_PUFF(0x12)
	    constant FIRE_CROSS(0x13)
	    constant EXPLOSION(0x1C)
	    constant WHITE_SPARK(0x1F)
	    constant WHITE_SPARKLE(0x29)
	    constant NOTE(0x5A)
        constant YOSHI_SHELL_BREAK_PRIMARY(0x5B)
	    constant PINK_BLAST(0x62)
	}

    // ADD NEW GFX TEXTURES HERE
    // Add a texture block and specify the number of textures in the block, then add the textures.

    add_gfx_texture_block(Black and White Explosion, 9, 3, 1, 0x20, 0x20)
    add_gfx_texture(gfx/explosion-bw-1.ia8)
    add_gfx_texture(gfx/explosion-bw-2.ia8)
    add_gfx_texture(gfx/explosion-bw-3.ia8)
    add_gfx_texture(gfx/explosion-bw-4.ia8)
    add_gfx_texture(gfx/explosion-bw-5.ia8)
    add_gfx_texture(gfx/explosion-bw-6.ia8)
    add_gfx_texture(gfx/explosion-bw-7.ia8)
    add_gfx_texture(gfx/explosion-bw-8.ia8)
    add_gfx_texture(gfx/explosion-bw-9.ia8)

    add_gfx_texture_block(Dr. Mario Pill Effect, 3, 0, 2, 0x20, 0x20)
    add_gfx_texture(gfx/dr-mario-effect-1.rgba5551)
    add_gfx_texture(gfx/dr-mario-effect-2.rgba5551)
    add_gfx_texture(gfx/dr-mario-effect-3.rgba5551)

    add_gfx_texture_block(PK Love, 3, 0, 2, 0x20, 0x20)
    add_gfx_texture(gfx/lucas-pk-love-1.rgba5551)
    add_gfx_texture(gfx/lucas-pk-love-2.rgba5551)
    add_gfx_texture(gfx/lucas-pk-love-3.rgba5551)

    add_gfx_texture_block(Dark Cross, 9, 0, 3, 0x20, 0x20)
    add_gfx_texture(gfx/dark_cross-1.rgba8888)
    add_gfx_texture(gfx/dark_cross-2.rgba8888)
    add_gfx_texture(gfx/dark_cross-3.rgba8888)
    add_gfx_texture(gfx/dark_cross-4.rgba8888)
    add_gfx_texture(gfx/dark_cross-5.rgba8888)
    add_gfx_texture(gfx/dark_cross-6.rgba8888)
    add_gfx_texture(gfx/dark_cross-7.rgba8888)
    add_gfx_texture(gfx/dark_cross-8.rgba8888)
    add_gfx_texture(gfx/dark_cross-9.rgba8888)

    add_gfx_texture_block(Dark Flame, 6, 0, 2, 0x20, 0x20)
    add_gfx_texture(gfx/dark_flame-1.rgba5551)
    add_gfx_texture(gfx/dark_flame-2.rgba5551)
    add_gfx_texture(gfx/dark_flame-3.rgba5551)
    add_gfx_texture(gfx/dark_flame-4.rgba5551)
    add_gfx_texture(gfx/dark_flame-5.rgba5551)
    add_gfx_texture(gfx/dark_flame-6.rgba5551)

    add_gfx_texture_block(Mewtwo Jab, 5, 3, 1, 0x20, 0x20)
    add_gfx_texture(gfx/mewtwo-jab-1.ia8)
    add_gfx_texture(gfx/mewtwo-jab-2.ia8)
    add_gfx_texture(gfx/mewtwo-jab-3.ia8)
    add_gfx_texture(gfx/mewtwo-jab-4.ia8)
    add_gfx_texture(gfx/mewtwo-jab-5.ia8)

    add_gfx_texture_block(Orange_Blast, 1, 2, 0, 0x10, 0x8)
    add_gfx_texture(gfx/orange_blast.rgba5551)
    add_gfx_texture(gfx/orange_blast_palette.rgba5551)      // I don't see any other way to add a palette

    add_gfx_texture_block(Feather, 3, 0, 2, 0x10, 0x10)
    add_gfx_texture(gfx/feather-1.rgba5551)
    add_gfx_texture(gfx/feather-2.rgba5551)
    add_gfx_texture(gfx/feather-3.rgba5551)

    // ADD NEW GFX HERE
    add_gfx(Blue Explosion, gfx/blue_explosion_instructions.bin, id.EXPLOSION)
    add_gfx(Blue Bomb Explosion, gfx/blue_bomb_explosion_instructions.bin, id.EXPLOSION)
    add_gfx(Blue Bomb Explosion - Instruction 0x1B replacement, gfx/blue_bomb_explosion_instructions-1B.bin, id.EXPLOSION)
    add_gfx(Blue Bomb Explosion - Instruction 0x1C replacement, gfx/blue_bomb_explosion_instructions-1C.bin, id.EXPLOSION)
    add_gfx(Blue Bomb Explosion - Instruction 0x1D replacement, gfx/blue_bomb_explosion_instructions-1D.bin, id.EXPLOSION)
    add_gfx(Blue Bomb Explosion - Instruction 0x1E replacement, gfx/blue_bomb_explosion_instructions-1E.bin, id.EXPLOSION)
    add_gfx(Blue Bomb Explosion - Instruction 0x1F replacement, gfx/blue_bomb_explosion_instructions-1F.bin, id.EXPLOSION)
    add_gfx(Blue Bomb Explosion - Instruction 0x20 replacement, gfx/blue_bomb_explosion_instructions-20.bin, id.EXPLOSION)

    add_ground_effect_gfx(Blue/Black Ground Effect, 0x20)

    add_gfx(Purple Explosion, gfx/purple_explosion_instructions.bin, id.EXPLOSION)
    add_gfx(Dr Mario Effect, gfx/dr_mario_effect_instructions.bin, id.EXPLOSION)
    add_gfx(PK Love, gfx/pk_love_instructions.bin, id.WHITE_SPARKLE)
    add_gfx(PK Love Rising, gfx/pk_love_rising_instructions.bin, id.NOTE)
    add_gfx(PK Love Rising Small, gfx/pk_love_rising_small_instructions.bin, id.FIRE)
    add_gfx(Purple Spark, gfx/purple_spark_instructions.bin, id.WHITE_SPARK)
    add_gfx(Purple Smoke Puff, gfx/purple_smoke_puff_instructions.bin, id.SMOKE_PUFF)
    add_gfx(Dark Cross, gfx/dark_cross_instructions.bin, id.FIRE_CROSS)
    add_gfx(Dark Flame, gfx/dark_flame_instructions.bin, id.FIRE)
    add_gfx(Mewtwo Jab, gfx/mewtwo_jab_instructions.bin, id.WHITE_SPARKLE)
    add_gfx(Pink Smoke Puff, gfx/pink_smoke_puff_instructions.bin, id.SMOKE_PUFF)
    add_gfx(White Smoke, gfx/white_smoke_instructions.bin, id.SMOKE_PUFF)
    add_gfx(Orange Spark, gfx/orange_spark_instructions.bin, id.WHITE_SPARK)
    add_gfx(Orange Blast, gfx/orange_blast_instructions.bin, id.PINK_BLAST)
    add_gfx(Red Sparkles Secondary A, gfx/red_sparkles_secondary_a_instructions.bin, id.KIRBY_USP_SPARKLES_SECONDARY_A)
    add_gfx(Red Sparkles Secondary B, gfx/red_sparkles_secondary_b_instructions.bin, id.KIRBY_USP_SPARKLES_SECONDARY_B)
    add_gfx(Red Sparkles Primary, gfx/red_sparkles_primary_instructions.bin, id.KIRBY_USP_SPARKLES_PRIMARY)
    add_gfx(Feathers Secondary A, gfx/feather_secondary_a_instructions.bin, id.YOSHI_SHELL_BREAK_PRIMARY)
    add_gfx(Feathers Secondary B, gfx/feather_secondary_b_instructions.bin, id.YOSHI_SHELL_BREAK_PRIMARY)
    add_gfx(Feathers Primary, gfx/feather_primary_instructions.bin, id.YOSHI_SHELL_BREAK_PRIMARY)
    add_gfx(Gold Sparkles Secondary A, gfx/gold_sparkles_secondary_a_instructions.bin, id.KIRBY_USP_SPARKLES_SECONDARY_A)
    add_gfx(Gold Sparkles Secondary B, gfx/gold_sparkles_secondary_b_instructions.bin, id.KIRBY_USP_SPARKLES_SECONDARY_B)
    add_gfx(Gold Sparkles Primary, gfx/gold_sparkles_primary_instructions.bin, id.KIRBY_USP_SPARKLES_PRIMARY)

    // writes new GFX to ROM
    write_gfx()

    // @ Description
    // Modifies the routine that references GFX Instruction IDs within GFX instructions so that we can use an extended table
    // Instructions reference other GFX Instruction IDs via the A5 command
    scope extend_referenced_gfx_instructions_map_: {
        OS.patch_start(0x4F02C, 0x800D364C)
        j       extend_referenced_gfx_instructions_map_
        nop
        _return:
        OS.patch_end()

        OS.patch_start(0x4EFF0, 0x800D3610)
        // slti    at, a3, t6                             // original line
        slti    at, a3, 0x0077 + new_gfx_count            // modify check on max GFX_INSTRUCTIONS_ID
        OS.patch_end()

        // a0 should be a pointer to the address of the original GFX instructions map, so we'll change it if need be
        // a3 is the referenced GFX_INSTRUCTIONS_ID

        slti    at, a3, 0x0077                            // check if this is a new GFX_INSTRUCTIONS_ID
        beqz    at, _new_gfx_instructions_id              // if it is a new GFX_INSTRUCTIONS_ID, then branch
        nop                                               // else use the original table and return to original routine:
        addiu   t7, t7, 0x6400                            // original line 1
        addu    a0, a1, t7                                // original line 2
        j       _return                                   // return to original routine
        nop

        _new_gfx_instructions_id:
        li      a0, extended_gfx_instructions_map_pointer // a0 = pointer to address of extended table
        addiu   a3, a3, -0x0077                           // a3 = slot in extended table
        j       _return                                   // return to original routine
        nop                                               // ~
    }
}

} // __GFX__
