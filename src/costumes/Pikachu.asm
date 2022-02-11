scope pikachu_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(3)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1B)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(4 + 2) // 2 skipped

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
    db 0x7                      // 0x1 - special part ID (hat)
    db 0x3                      // 0x2 - special part image index start
    db 0x2                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(1, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE)       // part 0x1_0 - pelvis
    Costumes.define_part(2, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE)       // part 0x2_0 - torso
    Costumes.define_part(5, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)    // part 0x5_0 - left upper arm - bicep
    Costumes.define_part(6, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)    // part 0x6_0 - left hand
    Costumes.define_part(7, 5, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY) // part 0x7_0 - head
    Costumes.add_part_image(7, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PRIM_COLOR) // part 0x7_1 - head
    Costumes.add_part_image(7, 2, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR) // part 0x7_2 - head
    Costumes.add_part_image(7, 3, Costumes.part_type.PALETTE)                                                // part 0x7_3 - [special part] head - hat
    Costumes.add_part_image(7, 4, Costumes.part_type.PRIM_COLOR)                                             // part 0x7_4 - [special part] head - hat ball
    Costumes.define_part(9, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE)       // part 0x9_0 - left ear
    Costumes.define_part(A, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE)       // part 0xA_0 - right ear
    Costumes.define_part(D, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)    // part 0xD_0 - right upper arm - bicep
    Costumes.define_part(E, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)    // part 0xE_0 - right hand
    Costumes.define_part(10, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)   // part 0x10_0 - left thigh
    Costumes.define_part(11, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)   // part 0x11_0 - left calf
    Costumes.define_part(13, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)   // part 0x13_0 - left foot
    Costumes.define_part(15, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)   // part 0x15_0 - right thigh
    Costumes.define_part(16, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)   // part 0x16_0 - right calf
    Costumes.define_part(18, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)   // part 0x18_0 - right foot
    Costumes.define_part(19, 3, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR) // part 0x19_0 - tail
    Costumes.add_part_image(19, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE)   // part 0x19_1 - tail
    Costumes.add_part_image(19, 2, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE)   // part 0x19_2 - tail

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.PIKACHU)
    Costumes.register_extra_costumes_for_char(Character.id.JPIKA)
    Costumes.register_extra_costumes_for_char(Character.id.EPIKA)

    // Costume 0x6
    scope costume_0x6 {
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x80808000
        diffuse_ambient_pair_2:; dw 0xFFFFFF00, 0xCCCCCC00
        palette_1:; insert "Pikachu/cos_6_1.bin"
        palette_2:; insert "Pikachu/cos_6_2.bin"
        palette_3:; insert "Pikachu/cos_6_3.bin"
        palette_4:; insert "Pikachu/cos_6_4.bin"
        palette_5:; insert "Pikachu/cos_6_5.bin"
        palette_6:; insert "Pikachu/cos_6_6.bin"

        Costumes.set_palette_for_part(0, 1, 0, palette_1)
        Costumes.set_diffuse_ambient_colors_for_part(0, 1, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, 2, 0, palette_1)
        Costumes.set_diffuse_ambient_colors_for_part(0, 2, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 5, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 5, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 6, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 6, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, 7, 0, palette_2)
        Costumes.set_diffuse_ambient_colors_for_part(0, 7, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, 7, 1, palette_3)
        Costumes.set_diffuse_ambient_colors_for_part(0, 7, 1, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 7, 2, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 7, 2, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, 7, 3, palette_6)
        Costumes.set_prim_color_for_part(0, 7, 4, 0xFFB700FF)
        Costumes.set_palette_for_part(0, 9, 0, palette_4)
        Costumes.set_diffuse_ambient_colors_for_part(0, 9, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, A, 0, palette_4)
        Costumes.set_diffuse_ambient_colors_for_part(0, A, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, D, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, D, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, E, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, E, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 10, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 10, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 11, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 11, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 13, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 13, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 15, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 15, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 16, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 16, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 18, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 18, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, 19, 0, palette_5)
        Costumes.set_prim_color_for_part(0, 19, 0, 0xFFD933FF)
        Costumes.set_diffuse_ambient_colors_for_part(0, 19, 0, diffuse_ambient_pair_2)
        Costumes.set_palette_for_part(0, 19, 1, palette_5)
        Costumes.set_diffuse_ambient_colors_for_part(0, 19, 1, diffuse_ambient_pair_2)
        Costumes.set_palette_for_part(0, 19, 2, palette_5)
        Costumes.set_diffuse_ambient_colors_for_part(0, 19, 2, diffuse_ambient_pair_2)

        Costumes.set_stock_icon_palette_for_costume(0, Pikachu/cos_6_stock_icon.bin)
    }
    
    // Costume 0x7
    scope costume_0x7 {
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x80808000
        diffuse_ambient_pair_2:; dw 0xFFFFFF00, 0xCCCCCC00
        palette_1:; insert "Pikachu/cos_7_1.bin"
        palette_2:; insert "Pikachu/cos_7_2.bin"
        palette_3:; insert "Pikachu/cos_7_3.bin"
        palette_4:; insert "Pikachu/cos_7_4.bin"
        palette_5:; insert "Pikachu/cos_7_5.bin"
        palette_6:; insert "Pikachu/cos_7_6.bin"

        Costumes.set_palette_for_part(1, 1, 0, palette_1)
        Costumes.set_diffuse_ambient_colors_for_part(1, 1, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, 2, 0, palette_1)
        Costumes.set_diffuse_ambient_colors_for_part(1, 2, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 5, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 5, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 6, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 6, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, 7, 0, palette_2)
        Costumes.set_diffuse_ambient_colors_for_part(1, 7, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, 7, 1, palette_3)
        Costumes.set_diffuse_ambient_colors_for_part(1, 7, 1, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 7, 2, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 7, 2, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, 7, 3, palette_6)
        Costumes.set_prim_color_for_part(1, 7, 4, 0xB6EEFEFF)
        Costumes.set_palette_for_part(1, 9, 0, palette_4)
        Costumes.set_diffuse_ambient_colors_for_part(1, 9, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, A, 0, palette_4)
        Costumes.set_diffuse_ambient_colors_for_part(1, A, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, D, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, D, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, E, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, E, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 10, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 10, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 11, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 11, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 13, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 13, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 15, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 15, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 16, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 16, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 18, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 18, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, 19, 0, palette_5)
        Costumes.set_prim_color_for_part(1, 19, 0, 0xA0F810FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 19, 0, diffuse_ambient_pair_2)
        Costumes.set_palette_for_part(1, 19, 1, palette_5)
        Costumes.set_diffuse_ambient_colors_for_part(1, 19, 1, diffuse_ambient_pair_2)
        Costumes.set_palette_for_part(1, 19, 2, palette_5)
        Costumes.set_diffuse_ambient_colors_for_part(1, 19, 2, diffuse_ambient_pair_2)

        Costumes.set_stock_icon_palette_for_costume(1, Pikachu/cos_7_stock_icon.bin)
    }
    
    // Costume 0x8
    scope costume_0x8 {
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x80808000
        diffuse_ambient_pair_2:; dw 0xFFFFFF00, 0xCCCCCC00
        palette_1:; insert "Pikachu/cos_8_1.bin"
        palette_2:; insert "Pikachu/cos_8_2.bin"
        palette_3:; insert "Pikachu/cos_8_3.bin"
        palette_4:; insert "Pikachu/cos_8_4.bin"
        palette_5:; insert "Pikachu/cos_8_5.bin"
        palette_6:; insert "Pikachu/cos_8_6.bin"

        Costumes.set_palette_for_part(2, 1, 0, palette_1)
        Costumes.set_diffuse_ambient_colors_for_part(2, 1, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(2, 2, 0, palette_1)
        Costumes.set_diffuse_ambient_colors_for_part(2, 2, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 5, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 5, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 6, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 6, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(2, 7, 0, palette_2)
        Costumes.set_diffuse_ambient_colors_for_part(2, 7, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(2, 7, 1, palette_3)
        Costumes.set_diffuse_ambient_colors_for_part(2, 7, 1, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 7, 2, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 7, 2, diffuse_ambient_pair)
        Costumes.set_palette_for_part(2, 7, 3, palette_6)
        Costumes.set_prim_color_for_part(2, 7, 4, 0xFFFFFFFF)
        Costumes.set_palette_for_part(2, 9, 0, palette_4)
        Costumes.set_diffuse_ambient_colors_for_part(2, 9, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(2, A, 0, palette_4)
        Costumes.set_diffuse_ambient_colors_for_part(2, A, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, D, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, D, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, E, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, E, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 10, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 10, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 11, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 11, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 13, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 13, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 15, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 15, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 16, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 16, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(2, 18, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 18, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(2, 19, 0, palette_5)
        Costumes.set_prim_color_for_part(2, 19, 0, 0xfdc543FF)
        Costumes.set_diffuse_ambient_colors_for_part(2, 19, 0, diffuse_ambient_pair_2)
        Costumes.set_palette_for_part(2, 19, 1, palette_5)
        Costumes.set_diffuse_ambient_colors_for_part(2, 19, 1, diffuse_ambient_pair_2)
        Costumes.set_palette_for_part(2, 19, 2, palette_5)
        Costumes.set_diffuse_ambient_colors_for_part(2, 19, 2, diffuse_ambient_pair_2)

        Costumes.set_stock_icon_palette_for_costume(2, Pikachu/cos_8_stock_icon.bin)
    }
}
