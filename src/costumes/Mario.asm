scope mario_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(2)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x18)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(5)

    stock_icon_palette_array:
    fill NUM_COSTUMES * 4
    constant EXTRA_STOCK_ICON_PALETTE_ARRAY_ORIGIN(origin())
    fill NUM_EXTRA_COSTUMES * 4

    // @ Description
    // Points to array of extra costumes' stock icon palettes
    // NOTE: must be right before parts_table
    stock_icon_palette_array_pointer:
    dw stock_icon_palette_array

    parts_table:
    constant PARTS_TABLE_ORIGIN(origin())
    db NUM_EXTRA_COSTUMES       // 0x0 - number of extra costumes
    db 0x0                      // 0x1 - special part ID
    db 0x0                      // 0x2 - special part image index start
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(2, 1, Costumes.part_type.PALETTE)                                                // part 0x2_0 - torso
    Costumes.define_part(4, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR) // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR) // part 0x5_0 - left lower arm
    Costumes.define_part(8, 3, Costumes.part_type.TEXTURE_ARRAY)                                          // part 0x8_0 - head - eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)                                             // part 0x8_1 - head - hat M texture
    Costumes.add_part_image(8, 2, Costumes.part_type.PRIM_COLOR)                                          // part 0x8_2 - head - hat
    Costumes.define_part(A, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR) // part 0xA_0 - right upper arm
    Costumes.define_part(B, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR) // part 0xB_0 - right lower arm
    Costumes.define_part(F, 1, Costumes.part_type.PRIM_COLOR)                                             // part 0xF_0 - left upper leg
    Costumes.define_part(10, 1, Costumes.part_type.PRIM_COLOR)                                            // part 0x10_0 - left lower leg
    Costumes.define_part(12, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                                // part 0x12_0 - left foot
    Costumes.define_part(14, 1, Costumes.part_type.PRIM_COLOR)                                            // part 0x14_0 - right upper leg
    Costumes.define_part(15, 1, Costumes.part_type.PRIM_COLOR)                                            // part 0x15_0 - right lower leg
    Costumes.define_part(17, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                                // part 0x17_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.MARIO)
    Costumes.register_extra_costumes_for_char(Character.id.JMARIO)

    // Costume 0x5
    scope costume_0x5 {
        diffuse_ambient_pair_1:; dw 0xFFFFFF00, 0x4C4C4C00
        diffuse_ambient_pair_2:; dw 0x83271400, 0x240F1100
        palette_1:; insert "Mario/cos_5_1.bin"
        palette_2:; insert "Mario/cos_5_2.bin"

        Costumes.set_palette_for_part(0, 2, 0, palette_1)
        Costumes.set_palette_for_part(0, 8, 1, palette_2)
        Costumes.set_prim_color_for_part(0, 4, 0, 0xFFFFFFFF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 4, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(0, 5, 0, 0xFFFFFFFF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 5, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(0, 8, 2, 0xFFFFFFFF)
        Costumes.set_prim_color_for_part(0, A, 0, 0xFFFFFFFF)
        Costumes.set_diffuse_ambient_colors_for_part(0, A, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(0, B, 0, 0xFFFFFFFF)
        Costumes.set_diffuse_ambient_colors_for_part(0, B, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(0, F, 0, 0xFF0000FF)
        Costumes.set_prim_color_for_part(0, 10, 0, 0xFF0000FF)
        Costumes.set_prim_color_for_part(0, 14, 0, 0xFF0000FF)
        Costumes.set_prim_color_for_part(0, 15, 0, 0xFF0000FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 12, 0, diffuse_ambient_pair_2)
        Costumes.set_diffuse_ambient_colors_for_part(0, 17, 0, diffuse_ambient_pair_2)

        Costumes.set_stock_icon_palette_for_costume(0, Mario/cos_5_stock_icon.bin)
    }
    
    // Costume 0x6
    scope costume_0x6 {
        diffuse_ambient_pair_1:; dw 0xFFFFFF00, 0x4C4C4C00
        diffuse_ambient_pair_2:; dw 0x542F0000, 0x30250000
        palette_1:; insert "Mario/cos_6_1.bin"
        palette_2:; insert "Mario/cos_6_2.bin"

        Costumes.set_palette_for_part(1, 2, 0, palette_1)
        Costumes.set_palette_for_part(1, 8, 1, palette_2)
        Costumes.set_prim_color_for_part(1, 4, 0, 0x927700FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 4, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(1, 5, 0, 0x927700FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 5, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(1, 8, 2, 0xE30000FF)
        Costumes.set_prim_color_for_part(1, A, 0, 0x927700FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, A, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(1, B, 0, 0x927700FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, B, 0, diffuse_ambient_pair_1)
        Costumes.set_prim_color_for_part(1, F, 0, 0xE30000FF)
        Costumes.set_prim_color_for_part(1, 10, 0, 0xE30000FF)
        Costumes.set_prim_color_for_part(1, 14, 0, 0xE30000FF)
        Costumes.set_prim_color_for_part(1, 15, 0, 0xE30000FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 12, 0, diffuse_ambient_pair_2)
        Costumes.set_diffuse_ambient_colors_for_part(1, 17, 0, diffuse_ambient_pair_2)

        Costumes.set_stock_icon_palette_for_costume(1, Mario/cos_6_stock_icon.bin)
    }
    
}
