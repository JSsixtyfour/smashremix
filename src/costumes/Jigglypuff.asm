scope jigglypuff_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(3)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x19)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(5 + 1) // 1 skipped

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
    // part 0x0 never has images, so we can store extra info here
    db NUM_EXTRA_COSTUMES       // 0x0 - number of extra costumes
    db 0x2                      // 0x1 - special part ID (bow)
    db 0x9                      // 0x2 - special part image index start
    db 0x1                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(2, 11, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY)             // part 0x2_0 - body - left eye
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY)           // part 0x2_1 - body - right eye
    Costumes.add_part_image(2, 2, Costumes.part_type.PALETTE)                                              // part 0x2_2 - body - mouth
    Costumes.add_part_image(2, 3, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR)              // part 0x2_3 - body - body
    Costumes.add_part_image(2, 4, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR)              // part 0x2_4 - body - bangs
    Costumes.add_part_image(2, 5, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR)              // part 0x2_5 - body - left ear
    Costumes.add_part_image(2, 6, Costumes.part_type.PRIM_COLOR)                                           // part 0x2_6 - body - left ear back
    Costumes.add_part_image(2, 7, Costumes.part_type.PALETTE)                                              // part 0x2_7 - body - right ear
    Costumes.add_part_image(2, 8, Costumes.part_type.PRIM_COLOR)                                           // part 0x2_8 - body - right ear back
    Costumes.add_part_image(2, 9, Costumes.part_type.PALETTE)                                              // part 0x2_9 - [special part] body - bow left half
    Costumes.add_part_image(2, A, Costumes.part_type.PALETTE)                                              // part 0x2_A - [special part] body - bow right half
    Costumes.define_part(6, 1, Costumes.part_type.PRIM_COLOR)                                              // part 0x6_0 - left arm
    Costumes.define_part(7, 1, Costumes.part_type.PRIM_COLOR)                                              // part 0x7_0 - left hand
    Costumes.define_part(A, 1, Costumes.part_type.PRIM_COLOR)                                              // part 0xA_0 - left arm
    Costumes.define_part(B, 1, Costumes.part_type.PRIM_COLOR)                                              // part 0xB_0 - left hand
    Costumes.define_part(13, 1, Costumes.part_type.PRIM_COLOR)                                             // part 0x13_0 - left foot
    Costumes.define_part(18, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR) // part 0x18_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.JIGGLYPUFF)
    Costumes.register_extra_costumes_for_char(Character.id.JPUFF)
    Costumes.register_extra_costumes_for_char(Character.id.EPUFF)

    // Costume 0x6
    scope costume_0x6 {
        constant PRIM_COLOR_1(0xFFF7BDFF)
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x80808000
        palette_1:; insert "Jigglypuff/cos_6_1.bin"
        palette_2:; insert "Jigglypuff/cos_6_2.bin"
        palette_3:; insert "Jigglypuff/cos_6_3.bin"
        palette_4:; insert "Jigglypuff/cos_6_4.bin"

        Costumes.set_palette_for_part(0, 2, 0, palette_1)
        Costumes.set_palette_for_part(0, 2, 1, palette_1)
        Costumes.set_palette_for_part(0, 2, 2, palette_2)
        Costumes.set_palette_for_part(0, 2, 3, palette_3)
        Costumes.set_prim_color_for_part(0, 2, 3, PRIM_COLOR_1)
        Costumes.set_palette_for_part(0, 2, 4, palette_3)
        Costumes.set_prim_color_for_part(0, 2, 4, PRIM_COLOR_1)
        Costumes.set_palette_for_part(0, 2, 5, palette_3)
        Costumes.set_prim_color_for_part(0, 2, 5, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(0, 2, 6, PRIM_COLOR_1)
        Costumes.set_palette_for_part(0, 2, 7, palette_3)
        Costumes.set_prim_color_for_part(0, 2, 8, PRIM_COLOR_1)
        Costumes.set_palette_for_part(0, 2, 9, palette_4)
        Costumes.set_palette_for_part(0, 2, A, palette_4)
        Costumes.set_prim_color_for_part(0, 6, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(0, 7, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(0, A, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(0, B, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(0, 13, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(0, 18, 0, PRIM_COLOR_1)
        Costumes.set_diffuse_ambient_colors_for_part(0, 18, 0, diffuse_ambient_pair)

        Costumes.set_stock_icon_palette_for_costume(0, Jigglypuff/cos_6_stock_icon.bin)
    }

    // Costume 0x7
    scope costume_0x7 {
        constant PRIM_COLOR_1(0xFFE9FFFF)
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x80808000
        palette_1:; insert "Jigglypuff/cos_7_1.bin"
        palette_2:; insert "Jigglypuff/cos_7_2.bin"
        palette_3:; insert "Jigglypuff/cos_7_3.bin"
        palette_4:; insert "Jigglypuff/cos_7_4.bin"

        Costumes.set_palette_for_part(1, 2, 0, palette_1)
        Costumes.set_palette_for_part(1, 2, 1, palette_1)
        Costumes.set_palette_for_part(1, 2, 2, palette_2)
        Costumes.set_palette_for_part(1, 2, 3, palette_3)
        Costumes.set_prim_color_for_part(1, 2, 3, PRIM_COLOR_1)
        Costumes.set_palette_for_part(1, 2, 4, palette_3)
        Costumes.set_prim_color_for_part(1, 2, 4, PRIM_COLOR_1)
        Costumes.set_palette_for_part(1, 2, 5, palette_3)
        Costumes.set_prim_color_for_part(1, 2, 5, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(1, 2, 6, PRIM_COLOR_1)
        Costumes.set_palette_for_part(1, 2, 7, palette_3)
        Costumes.set_prim_color_for_part(1, 2, 8, PRIM_COLOR_1)
        Costumes.set_palette_for_part(1, 2, 9, palette_4)
        Costumes.set_palette_for_part(1, 2, A, palette_4)
        Costumes.set_prim_color_for_part(1, 6, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(1, 7, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(1, A, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(1, B, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(1, 13, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(1, 18, 0, PRIM_COLOR_1)
        Costumes.set_diffuse_ambient_colors_for_part(1, 18, 0, diffuse_ambient_pair)

        Costumes.set_stock_icon_palette_for_costume(1, Jigglypuff/cos_7_stock_icon.bin)
    }
    
    // Costume 0x8
    scope costume_0x8 {
        constant PRIM_COLOR_1(0xF4F4F4FF)
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x80808000
        palette_1:; insert "Jigglypuff/cos_8_1.bin"
        palette_2:; insert "Jigglypuff/cos_8_2.bin"
        palette_3:; insert "Jigglypuff/cos_8_3.bin"

        Costumes.set_palette_for_part(2, 2, 0, palette_1)
        Costumes.set_palette_for_part(2, 2, 1, palette_1)
        Costumes.set_palette_for_part(2, 2, 2, palette_2)
        Costumes.set_palette_for_part(2, 2, 3, palette_2)
        Costumes.set_prim_color_for_part(2, 2, 3, PRIM_COLOR_1)
        Costumes.set_palette_for_part(2, 2, 4, palette_2)
        Costumes.set_prim_color_for_part(2, 2, 4, PRIM_COLOR_1)
        Costumes.set_palette_for_part(2, 2, 5, palette_2)
        Costumes.set_prim_color_for_part(2, 2, 5, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(2, 2, 6, PRIM_COLOR_1)
        Costumes.set_palette_for_part(2, 2, 7, palette_2)
        Costumes.set_prim_color_for_part(2, 2, 8, PRIM_COLOR_1)
        Costumes.set_palette_for_part(2, 2, 9, palette_3)
        Costumes.set_palette_for_part(2, 2, A, palette_3)
        Costumes.set_prim_color_for_part(2, 6, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(2, 7, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(2, A, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(2, B, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(2, 13, 0, PRIM_COLOR_1)
        Costumes.set_prim_color_for_part(2, 18, 0, PRIM_COLOR_1)
        Costumes.set_diffuse_ambient_colors_for_part(2, 18, 0, diffuse_ambient_pair)

        Costumes.set_stock_icon_palette_for_costume(2, Jigglypuff/cos_8_stock_icon.bin)
    }
}
