scope sheik_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x19)

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
    // part 0x0 never has images, so we can store extra info here
    db NUM_EXTRA_COSTUMES       // 0x0 - number of extra costumes
    db 0x0                      // 0x1 - special part ID
    db 0x0                      // 0x2 - special part image index start
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(1, 2, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR)    // part 0x1_0 - frock front bottom (palette hi, prim color lo)
    Costumes.add_part_image(1, 1, Costumes.part_type.PRIM_COLOR)                              // part 0x1_1 - pelvis
    Costumes.define_part(2, 7, Costumes.part_type.PALETTE)                                    // part 0x2_0 - torso - frock front lower symbol
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                                 // part 0x2_1 - torso - frock front upper symbol
    Costumes.add_part_image(2, 2, Costumes.part_type.PALETTE)                                 // part 0x2_2 - torso - frock shoulders
    Costumes.add_part_image(2, 3, Costumes.part_type.PALETTE)                                 // part 0x2_3 - torso - upper front frock
    Costumes.add_part_image(2, 4, Costumes.part_type.PALETTE)                                 // part 0x2_4 - torso - back upper middle frock
    Costumes.add_part_image(2, 5, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR) // part 0x2_5 - torso - ? (palette hi, prim color lo)
    Costumes.add_part_image(2, 6, Costumes.part_type.PRIM_COLOR)                              // part 0x2_6 - (hi) torso - undershirt / (lo) collarbone - frock
    Costumes.define_part(4, 2, Costumes.part_type.PALETTE)                                    // part 0x4_0 - left shoulder
    Costumes.add_part_image(4, 1, Costumes.part_type.PRIM_COLOR)                              // part 0x4_1 - left upper arm
    Costumes.define_part(5, 2, Costumes.part_type.PALETTE)                                    // part 0x5_0 - left lower arm
    Costumes.add_part_image(5, 1, Costumes.part_type.PRIM_COLOR)                              // part 0x5_1 - left elbow
    Costumes.define_part(6, 2, Costumes.part_type.PRIM_COLOR)                                 // part 0x6_0 - left hand - top
    Costumes.add_part_image(6, 1, Costumes.part_type.PRIM_COLOR)                              // part 0x6_1 - left hand - side
    Costumes.define_part(7, 1, Costumes.part_type.PRIM_COLOR)                                 // part 0x7_0 - collar bottom
    Costumes.define_part(8, 5, Costumes.part_type.TEXTURE_ARRAY)                              // part 0x8_0 - head - eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)                                 // part 0x8_1 - collar top
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE)                                 // part 0x8_2 - head - hair
    Costumes.add_part_image(8, 3, Costumes.part_type.PALETTE)                                 // part 0x8_3 - head - cap
    Costumes.add_part_image(8, 4, Costumes.part_type.PRIM_COLOR)                              // part 0x8_4 - head - nose/ears
    Costumes.define_part(A, 2, Costumes.part_type.PALETTE)                                    // part 0xA_0 - right shoulder
    Costumes.add_part_image(A, 1, Costumes.part_type.PRIM_COLOR)                              // part 0xA_1 - right upper arm
    Costumes.define_part(B, 2, Costumes.part_type.PALETTE)                                    // part 0xB_0 - right lower arm
    Costumes.add_part_image(B, 1, Costumes.part_type.PRIM_COLOR)                              // part 0xB_1 - right elbow
    Costumes.define_part(C, 2, Costumes.part_type.PRIM_COLOR)                                 // part 0xC_0 - right hand - top
    Costumes.add_part_image(C, 1, Costumes.part_type.PRIM_COLOR)                              // part 0xC_1 - right hand - side
    Costumes.define_part(10, 2, Costumes.part_type.PALETTE)                                   // part 0x10_0 - left upper leg, bottom
    Costumes.add_part_image(10, 1, Costumes.part_type.PRIM_COLOR)                             // part 0x10_1 - left upper leg, top
    Costumes.define_part(11, 2, Costumes.part_type.PALETTE)                                   // part 0x11_0 - left lower leg - top
    Costumes.add_part_image(11, 1, Costumes.part_type.PRIM_COLOR)                             // part 0x11_1 - left lower leg - bottom
    Costumes.define_part(13, 2, Costumes.part_type.PALETTE)                                   // part 0x13_0 - left foot - inner/toes
    Costumes.add_part_image(13, 1, Costumes.part_type.PRIM_COLOR)                             // part 0x13_1 - left foot - outer/ankle
    Costumes.define_part(15, 2, Costumes.part_type.PALETTE)                                   // part 0x15_0 - right upper leg, bottom
    Costumes.add_part_image(15, 1, Costumes.part_type.PRIM_COLOR)                             // part 0x15_1 - right upper leg, top
    Costumes.define_part(16, 2, Costumes.part_type.PALETTE)                                   // part 0x16_0 - right lower leg - top
    Costumes.add_part_image(16, 1, Costumes.part_type.PRIM_COLOR)                             // part 0x16_1 - right lower leg - bottom
    Costumes.define_part(18, 2, Costumes.part_type.PALETTE)                                   // part 0x18_0 - right foot - inner/toes
    Costumes.add_part_image(18, 1, Costumes.part_type.PRIM_COLOR)                             // part 0x18_1 - right foot - outer/ankle

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.SHEIK)

    // Costume 0x6
    // Yellow Team
    scope costume_0x6 {
        palette_1:; insert "Sheik/cos_6_1.bin"  // Raggy Waist
        palette_2:; insert "Sheik/cos_6_2.bin"  // Front Chest
        palette_3:; insert "Sheik/cos_6_3.bin"  // Bandage/Raggy Chest
        palette_4:; insert "Sheik/cos_6_4.bin"  // Limb Texture
        palette_5:; insert "Sheik/cos_6_5.bin"  // Head wrap
        palette_6:; insert "Sheik/cos_6_6.bin"  // Hair

        constant SUIT_COLOR(0x17140400)
        constant CLOTH_COLOR(0xf5f0ce00)
        constant SKIN_COLOR(0xc59d4aFF)

        Costumes.set_palette_for_part(0, 1, 0, palette_1)     // hi poly only
        Costumes.set_prim_color_for_part(0, 1, 0, SUIT_COLOR) // lo poly only
        Costumes.set_prim_color_for_part(0, 1, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, 2, 0, palette_2)
        Costumes.set_palette_for_part(0, 2, 1, palette_2)
        Costumes.set_palette_for_part(0, 2, 2, palette_3)
        Costumes.set_palette_for_part(0, 2, 3, palette_3)
        Costumes.set_palette_for_part(0, 2, 4, palette_3)
        Costumes.set_palette_for_part(0, 2, 5, palette_3)     // hi poly only
        Costumes.set_prim_color_for_part(0, 2, 5, SUIT_COLOR) // lo poly only
        Costumes.set_prim_color_for_part(0, 2, 6, SUIT_COLOR)
        Costumes.set_prim_color_for_part_lo(0, 2, 6, CLOTH_COLOR)
        Costumes.set_palette_for_part(0, 4, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 4, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, 5, 0, palette_3)
        Costumes.set_prim_color_for_part(0, 5, 1, SUIT_COLOR)
        Costumes.set_prim_color_for_part(0, 6, 0, SUIT_COLOR)
        Costumes.set_prim_color_for_part(0, 6, 1, SKIN_COLOR)
        Costumes.set_prim_color_for_part(0, 7, 0, CLOTH_COLOR)
        Costumes.set_palette_for_part(0, 8, 1, palette_1) // raggy collar
        Costumes.set_palette_for_part(0, 8, 2, palette_6) // hair
        Costumes.set_palette_for_part(0, 8, 3, palette_3) // hat
        Costumes.set_prim_color_for_part(0, 8, 4, SKIN_COLOR)
        Costumes.set_palette_for_part(0, A, 0, palette_4)
        Costumes.set_prim_color_for_part(0, A, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, B, 0, palette_3)
        Costumes.set_prim_color_for_part(0, B, 1, SUIT_COLOR)
        Costumes.set_prim_color_for_part(0, C, 0, SUIT_COLOR)
        Costumes.set_prim_color_for_part(0, C, 1, SKIN_COLOR)
        Costumes.set_palette_for_part(0, 10, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 10, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, 11, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 11, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, 13, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 13, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, 15, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 15, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, 16, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 16, 1, SUIT_COLOR)
        Costumes.set_palette_for_part(0, 18, 0, palette_4)
        Costumes.set_prim_color_for_part(0, 18, 1, SUIT_COLOR)

        Costumes.set_stock_icon_palette_for_costume(0, Sheik/cos_6_stock_icon.bin)
    }
}
