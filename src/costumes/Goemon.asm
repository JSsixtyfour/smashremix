scope goemon_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x20)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(6)

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

    Costumes.define_part(2, 4, Costumes.part_type.PALETTE)                            // part 0x2_0 - torso - ?
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                         // part 0x2_1 - torso - front/lower
    Costumes.add_part_image(2, 2, Costumes.part_type.PRIM_COLOR)                      // part 0x2_2 - torso - upper back
    Costumes.add_part_image(2, 3, Costumes.part_type.PRIM_COLOR)                      // part 0x2_3 - torso - should pads
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)                            // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.PALETTE)                            // part 0x5_0 - left lower arm
    Costumes.define_part(6, 1, Costumes.part_type.PRIM_COLOR)                         // part 0x6_0 - left hand
    Costumes.define_part(8, 3, Costumes.part_type.TEXTURE_ARRAY)                      // part 0x8_0 - head - eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.PRIM_COLOR)                      // part 0x8_1 - head - top hair
    Costumes.add_part_image(8, 2, Costumes.part_type.PRIM_COLOR)                      // part 0x8_2 - head - back hair
    Costumes.define_special_parts_for_part(8, 2)
    Costumes.add_special_part(8, 1, 3, Costumes.part_type.TEXTURE_ARRAY)              // part 0x8_1_0 - impact head - eyes
    Costumes.add_special_part_image(8, 1, 1, Costumes.part_type.PRIM_COLOR)           // part 0x8_1_1 - impact head - back hair
    Costumes.add_special_part_image(8, 1, 2, Costumes.part_type.PRIM_COLOR)           // part 0x8_1_2 - impact head - top hair
    Costumes.define_part(A, 1, Costumes.part_type.PALETTE)                            // part 0xA_0 - right upper arm
    Costumes.define_part(B, 1, Costumes.part_type.PALETTE)                            // part 0xB_0 - right lower arm
    Costumes.define_part(C, 1, Costumes.part_type.PRIM_COLOR)                         // part 0xC_0 - right hand
    Costumes.define_part(17, 1, Costumes.part_type.PRIM_COLOR)                        // part 0x17_0 - left upper leg
    Costumes.define_part(18, 1, Costumes.part_type.PALETTE)                           // part 0x18_0 - left lower leg
    Costumes.define_part(1A, 1, Costumes.part_type.PALETTE)                           // part 0x1A_0 - left foot
    Costumes.define_part(1C, 1, Costumes.part_type.PRIM_COLOR)                        // part 0x1C_0 - right upper leg
    Costumes.define_part(1D, 1, Costumes.part_type.PALETTE)                           // part 0x1D_0 - right lower leg
    Costumes.define_part(1F, 1, Costumes.part_type.PALETTE)                           // part 0x1F_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.GOEMON)

    // Costume 0x6
    // Yellow Team
    // TODO: update!
    scope costume_0x6 {
        palette_1:; insert "Goemon/cos_6_1.bin"
        palette_2:; insert "Goemon/cos_6_2.bin"
        palette_3:; insert "Goemon/cos_6_3.bin"
        constant color_shoulder_pads(0x244ec4FF)
        constant color_shirt(0xffd014FF)
        constant color_pants(0xffd014FF)
        constant color_hands(0xFFD694FF)
        constant color_hair_top(0xffea00FF)
        constant color_hair_back(0x181818FF)
        constant color_impact_hair_top(0xF8F000FF)

        Costumes.set_palette_for_part(0, 2, 0, palette_1)
        Costumes.set_palette_for_part(0, 2, 1, palette_1)
        Costumes.set_prim_color_for_part(0, 2, 2, color_shirt)
        Costumes.set_prim_color_for_part(0, 2, 3, color_shoulder_pads)
        Costumes.set_palette_for_part(0, 4, 0, palette_2)
        Costumes.set_palette_for_part(0, 5, 0, palette_2)
        Costumes.set_prim_color_for_part(0, 6, 0, color_hands)
        Costumes.set_prim_color_for_part(0, 8, 1, color_hair_top)
        Costumes.set_prim_color_for_part(0, 8, 2, color_hair_back)
        Costumes.set_prim_color_for_part_lo(0, 8, 1, color_hair_back)
        Costumes.set_prim_color_for_part_lo(0, 8, 2, color_hair_top)
        Costumes.set_prim_color_for_special_part(0, 8, 1, 1, color_hair_back)
        Costumes.set_prim_color_for_special_part(0, 8, 1, 2, color_impact_hair_top)
        Costumes.set_palette_for_part(0, A, 0, palette_2)
        Costumes.set_palette_for_part(0, B, 0, palette_2)
        Costumes.set_prim_color_for_part(0, C, 0, color_hands)
        Costumes.set_prim_color_for_part(0, 17, 0, color_pants)
        Costumes.set_palette_for_part(0, 18, 0, palette_2)
        Costumes.set_palette_for_part(0, 1A, 0, palette_3)
        Costumes.set_prim_color_for_part(0, 1C, 0, color_pants)
        Costumes.set_palette_for_part(0, 1D, 0, palette_2)
        Costumes.set_palette_for_part(0, 1F, 0, palette_3)

        Costumes.set_stock_icon_palette_for_costume(0, Goemon/cos_6_stock.bin)
    }

}
