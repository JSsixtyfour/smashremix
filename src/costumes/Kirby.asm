scope kirby_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(2)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1A)

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
    // part 0x0 never has images, so we can store extra info here
    db NUM_EXTRA_COSTUMES       // 0x0 - number of extra costumes
    db 0x0                      // 0x1 - special part ID
    db 0x0                      // 0x2 - special part image index start
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(2, 2, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PRIM_COLOR) // part 0x2_0 - body - face
    Costumes.add_part_image(2, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)  // part 0x2_1 - body - back
    Costumes.define_part(3, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)     // part 0x3_0 - lips [special part]
    Costumes.define_part(6, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)     // part 0x6_0 - left arm
    Costumes.define_part(7, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)     // part 0xB_0 - left hand
    Costumes.define_part(B, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)     // part 0xC_0 - left arm
    Costumes.define_part(C, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS | Costumes.part_type.PRIM_COLOR)     // part 0x7_0 - left hand
    Costumes.define_part(F, 1, Costumes.part_type.PALETTE)                                                    // part 0xF_0 - inside mouth? [special part]
    Costumes.define_part(14, 1, Costumes.part_type.PRIM_COLOR)                                                // part 0x14_0 - left foot
    Costumes.define_part(19, 1, Costumes.part_type.PRIM_COLOR)                                                // part 0x19_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.KIRBY)
    Costumes.register_extra_costumes_for_char(Character.id.JKIRBY)



//  // Costume 0x5 - Gray Kirby
//  scope costume_0x5 {
//      diffuse_ambient_pair:; dw 0xFFFFFF00, 0x86868600
//      palette_1:; insert "Kirby/cos_5_1.bin"
//      palette_2:; insert "Kirby/cos_5_2.bin"
//
//      Costumes.set_palette_for_part(0, 2, 0, palette_1)
//      Costumes.set_prim_color_for_part(0, 2, 0, 0xB7B7B700)
//      Costumes.set_diffuse_ambient_colors_for_part(0, 2, 0, diffuse_ambient_pair)
//      Costumes.set_prim_color_for_part(0, 2, 1, 0xB7B7B700)
//      Costumes.set_diffuse_ambient_colors_for_part(0, 2, 1, diffuse_ambient_pair)
//      Costumes.set_prim_color_for_part(0, 3, 0, 0xB7B7B700)
//      Costumes.set_diffuse_ambient_colors_for_part(0, 3, 0, diffuse_ambient_pair)
//      Costumes.set_prim_color_for_part(0, 6, 0, 0xB7B7B700)
//      Costumes.set_diffuse_ambient_colors_for_part(0, 6, 0, diffuse_ambient_pair)
//      Costumes.set_prim_color_for_part(0, 7, 0, 0xB7B7B700)
//      Costumes.set_diffuse_ambient_colors_for_part(0, 7, 0, diffuse_ambient_pair)
//      Costumes.set_prim_color_for_part(0, B, 0, 0xB7B7B700)
//      Costumes.set_diffuse_ambient_colors_for_part(0, B, 0, diffuse_ambient_pair)
//      Costumes.set_prim_color_for_part(0, C, 0, 0xB7B7B700)
//      Costumes.set_diffuse_ambient_colors_for_part(0, C, 0, diffuse_ambient_pair)
//      Costumes.set_palette_for_part(0, F, 0, palette_2)
//      Costumes.set_prim_color_for_part(0, 14, 0, 0x80808000)
//      Costumes.set_prim_color_for_part(0, 19, 0, 0x80808000)
//
//      Costumes.set_stock_icon_palette_for_costume(0, Kirby/cos_5_stock_icon.bin)
//  }
    
    //  // Costume 0x5 - White Kirby
    scope costume_0x5 {
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x86868600
        palette_1:; insert "Kirby/cos_5_1.bin"
        palette_2:; insert "Kirby/cos_5_2.bin"
    
        Costumes.set_palette_for_part(0, 2, 0, palette_1)
        Costumes.set_prim_color_for_part(0, 2, 0, 0xFFFFFF00)
        Costumes.set_diffuse_ambient_colors_for_part(0, 2, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 2, 1, 0xFFFFFF00)
        Costumes.set_diffuse_ambient_colors_for_part(0, 2, 1, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 3, 0, 0xFFFFFF00)
        Costumes.set_diffuse_ambient_colors_for_part(0, 3, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 6, 0, 0xFFFFFF00)
        Costumes.set_diffuse_ambient_colors_for_part(0, 6, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, 7, 0, 0xFFFFFF00)
        Costumes.set_diffuse_ambient_colors_for_part(0, 7, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, B, 0, 0xFFFFFF00)
        Costumes.set_diffuse_ambient_colors_for_part(0, B, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(0, C, 0, 0xFFFFFF00)
        Costumes.set_diffuse_ambient_colors_for_part(0, C, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, F, 0, palette_2)
        Costumes.set_prim_color_for_part(0, 14, 0, 0x80808000)
        Costumes.set_prim_color_for_part(0, 19, 0, 0x80808000)
    
        Costumes.set_stock_icon_palette_for_costume(0, Kirby/cos_5_stock_icon.bin)
    }
    
    // Costume 0x6 - Meta Kirby
    scope costume_0x6 {
        diffuse_ambient_pair:; dw 0xFFFFFF00, 0x66666600
        palette_1:; insert "Kirby/cos_6_1.bin"
        palette_2:; insert "Kirby/cos_6_2.bin"

        Costumes.set_palette_for_part(1, 2, 0, palette_1)
        Costumes.set_prim_color_for_part(1, 2, 0, 0x101868FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 2, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 2, 1, 0x101868FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 2, 1, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 3, 0, 0x101868FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 3, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 6, 0, 0x101868FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 6, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, 7, 0, 0x101868FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, 7, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, B, 0, 0x101868FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, B, 0, diffuse_ambient_pair)
        Costumes.set_prim_color_for_part(1, C, 0, 0x101868FF)
        Costumes.set_diffuse_ambient_colors_for_part(1, C, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, F, 0, palette_2)
        Costumes.set_prim_color_for_part(1, 14, 0, 0x703A94FF)
        Costumes.set_prim_color_for_part(1, 19, 0, 0x703A94FF)

        Costumes.set_stock_icon_palette_for_costume(1, Kirby/cos_6_stock_icon.bin)
    }
}
