scope link_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(2)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1F)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(4)

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
    db 0x0                         // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(1, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                         // part 0x1_0 - pelvis
    Costumes.define_part(2, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                         // part 0x2_0 - torso
    Costumes.define_part(4, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                         // part 0x4_0 - left upper arm
    Costumes.define_part(9, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                         // part 0x9_0 - right upper arm
    Costumes.define_part(13, 3, Costumes.part_type.TEXTURE_ARRAY)                                 // part 0x13_0 - head - eyes
    Costumes.add_part_image(13, 1, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE) // part 0x13_1 - head - mouth
    Costumes.add_part_image(13, 2, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                     // part 0x13_2 - head - hood front
    Costumes.define_part(14, 1, Costumes.part_type.DIFFUSE_AMBIENT_COLORS)                        // part 0x14_0 - hood back
    Costumes.define_part(16, 1, Costumes.part_type.PALETTE)                                       // part 0x16_0 - left upper leg
    Costumes.define_part(1B, 1, Costumes.part_type.PALETTE)                                       // part 0x1B_0 - right upper leg

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.LINK)
    Costumes.register_extra_costumes_for_char(Character.id.JLINK)
    Costumes.register_extra_costumes_for_char(Character.id.ELINK)

    // Costume 0x4
    // Black Link
    scope costume_0x4 {
        diffuse_ambient_pair:; dw 0x1C1C1C00, 0x1C1C1C00
        palette_1:; insert "Link/cos_4_1.bin"
        palette_2:; insert "Link/cos_4_2.bin"

        Costumes.set_diffuse_ambient_colors_for_part(0, 1, 0, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(0, 2, 0, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(0, 4, 0, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(0, 9, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, 13, 1, palette_2)
        Costumes.set_diffuse_ambient_colors_for_part(0, 13, 2, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(0, 14, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(0, 16, 0, palette_1)
        Costumes.set_palette_for_part(0, 1B, 0, palette_1)

        Costumes.set_stock_icon_palette_for_costume(0, Link/cos_4_stock_icon.bin)
    }
    
    // Costume 0x5
    // Yellow Link
    scope costume_0x5 {
        diffuse_ambient_pair:; dw 0xA0740000, 0xA0740000
        palette_1:; insert "Link/cos_5_1.bin"
        palette_2:; insert "Link/cos_4_2.bin"

        Costumes.set_diffuse_ambient_colors_for_part(1, 1, 0, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(1, 2, 0, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(1, 4, 0, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(1, 9, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, 13, 1, palette_2)
        Costumes.set_diffuse_ambient_colors_for_part(1, 13, 2, diffuse_ambient_pair)
        Costumes.set_diffuse_ambient_colors_for_part(1, 14, 0, diffuse_ambient_pair)
        Costumes.set_palette_for_part(1, 16, 0, palette_1)
        Costumes.set_palette_for_part(1, 1B, 0, palette_1)

        Costumes.set_stock_icon_palette_for_costume(1, Link/cos_5_stock_icon.bin)
    }
}
