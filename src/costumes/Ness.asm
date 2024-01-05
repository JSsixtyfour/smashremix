scope ness_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(3)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1B)

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
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(2, 3, Costumes.part_type.PALETTE)          // part 0x2_0 - torso - front
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)       // part 0x2_1 - torso - back
    Costumes.add_part_image(2, 2, Costumes.part_type.PRIM_COLOR)    // part 0x2_2 - torso - pelvis
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)          // part 0x4_0 - left shoulder / bicep
    Costumes.define_part(8, 3, Costumes.part_type.TEXTURE_ARRAY)    // part 0x8_0 - head - face
    Costumes.add_part_image(8, 1, Costumes.part_type.PRIM_COLOR)    // part 0x8_1 - head - hat
    Costumes.add_part_image(8, 2, Costumes.part_type.PRIM_COLOR)    // part 0x8_2 - head - hat brim
    Costumes.define_part(A, 1, Costumes.part_type.PALETTE)          // part 0xA_0 - right shoulder / bicep
    Costumes.define_part(12, 1, Costumes.part_type.PALETTE)         // part 0x12_0 - left shoe
    Costumes.define_part(13, 1, Costumes.part_type.PRIM_COLOR)      // part 0x13_0 - left pant
    Costumes.define_part(18, 1, Costumes.part_type.PALETTE)         // part 0x18_0 - right shoe
    Costumes.define_part(19, 1, Costumes.part_type.PRIM_COLOR)      // part 0x19_0 - right pant

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.NESS)
    Costumes.register_extra_costumes_for_char(Character.id.JNESS)

    // Costume 0x4
    scope costume_0x4 {
        palette_1:; insert "Ness/cos_4_1.bin"
        palette_2:; insert "Ness/cos_4_2.bin"
        palette_3:; insert "Ness/cos_4_3.bin"
        palette_4:; insert "Ness/cos_4_4.bin"

        Costumes.set_palette_for_part(0, 2, 0, palette_2)
        Costumes.set_palette_for_part(0, 2, 1, palette_1)
        Costumes.set_prim_color_for_part(0, 2, 2, 0xC2C238FF)
        Costumes.set_palette_for_part(0, 4, 0, palette_3)
        Costumes.set_prim_color_for_part(0, 8, 1, 0xDDDDDDFF)
        Costumes.set_prim_color_for_part(0, 8, 2, 0xE8322CFF)
        Costumes.set_palette_for_part(0, A, 0, palette_3)
        Costumes.set_palette_for_part(0, 12, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 13, 0, 0xC2C238FF)
        Costumes.set_palette_for_part(0, 18, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 19, 0, 0xC2C238FF)

        Costumes.set_stock_icon_palette_for_costume(0, Ness/cos_4_stock_icon.bin)
    }

    // Costume 0x5
    scope costume_0x5 {
        palette_1:; insert "Ness/cos_5_1.bin"
        palette_2:; insert "Ness/cos_5_2.bin"
        palette_3:; insert "Ness/cos_5_3.bin"
        palette_4:; insert "Ness/cos_5_4.bin"

        Costumes.set_palette_for_part(1, 2, 0, palette_2)
        Costumes.set_palette_for_part(1, 2, 1, palette_1)
        Costumes.set_prim_color_for_part(1, 2, 2, 0x383458FF)
        Costumes.set_palette_for_part(1, 4, 0, palette_3)
        Costumes.set_prim_color_for_part(1, 8, 1, 0xCE4BB8FF)
        Costumes.set_prim_color_for_part(1, 8, 2, 0x4F3571FF)
        Costumes.set_palette_for_part(1, A, 0, palette_3)
        Costumes.set_palette_for_part(1, 12, 0, palette_4)
        Costumes.set_prim_color_for_part(1, 13, 0, 0x383458FF)
        Costumes.set_palette_for_part(1, 18, 0, palette_4)
        Costumes.set_prim_color_for_part(1, 19, 0, 0x383458FF)

        Costumes.set_stock_icon_palette_for_costume(1, Ness/cos_5_stock_icon.bin)
    }

    // Costume 0x6
    scope costume_0x6 {
        palette_1:; insert "Ness/cos_6_1.bin"
        palette_2:; insert "Ness/cos_6_2.bin"
        palette_3:; insert "Ness/cos_6_3.bin"
        palette_4:; insert "Ness/cos_6_4.bin"

        constant HAT_BRIM(0xF6F6F6FF)
        constant HAT(0x69A6FAFF)
        constant SHORTS(0x69A6FAFF)

        Costumes.set_palette_for_part(2, 2, 0, palette_2)
        Costumes.set_palette_for_part(2, 2, 1, palette_1)
        Costumes.set_prim_color_for_part(2, 2, 2, SHORTS)
        Costumes.set_palette_for_part(2, 4, 0, palette_3)
        Costumes.set_prim_color_for_part(2, 8, 1, HAT)
        Costumes.set_prim_color_for_part(2, 8, 2, HAT_BRIM)
        Costumes.set_palette_for_part(2, A, 0, palette_3)
        Costumes.set_palette_for_part(2, 12, 0, palette_4)
        Costumes.set_prim_color_for_part(2, 13, 0, SHORTS)
        Costumes.set_palette_for_part(2, 18, 0, palette_4)
        Costumes.set_prim_color_for_part(2, 19, 0, SHORTS)

        Costumes.set_stock_icon_palette_for_costume(2, Ness/cos_6_stock_icon.bin)
    }
}
