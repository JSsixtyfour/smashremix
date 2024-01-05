scope young_link_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1F)

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
    db 0x0                         // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(1, 2, Costumes.part_type.PALETTE)                                    // part 0x1_0 - pelvis - tunic
    Costumes.add_part_image(1, 1, Costumes.part_type.PALETTE)                                 // part 0x1_1 - pelvis - belt
    Costumes.define_part(2, 4, Costumes.part_type.PALETTE)                                    // part 0x2_0 - torso - sword hilt
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                                 // part 0x2_1 - torso - front
    Costumes.add_part_image(2, 2, Costumes.part_type.PALETTE)                                 // part 0x2_2 - torso - back
    Costumes.add_part_image(2, 3, Costumes.part_type.PRIM_COLOR)                              // part 0x2_3 - torso - undershirt
    Costumes.define_part(4, 1, Costumes.part_type.PRIM_COLOR)                                 // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.PRIM_COLOR)                                 // part 0x5_0 - left lower arm
    Costumes.define_part(6, 1, Costumes.part_type.PRIM_COLOR)                                 // part 0x6_0 - left hand
    Costumes.define_part(7, 1, Costumes.part_type.PALETTE)                                    // part 0x7_0 - sword
    Costumes.define_part(9, 1, Costumes.part_type.PRIM_COLOR)                                 // part 0x9_0 - right upper arm
    Costumes.define_part(A, 1, Costumes.part_type.PRIM_COLOR)                                 // part 0xA_0 - right lower arm
    Costumes.define_part(B, 1, Costumes.part_type.PRIM_COLOR)                                 // part 0xB_0 - right hand
    Costumes.define_part(F, 3, Costumes.part_type.PALETTE)                                    // part 0xF_0 - shield - face
    Costumes.add_part_image(F, 1, Costumes.part_type.PALETTE)                                 // part 0xF_1 - shield - stripes
    Costumes.add_part_image(F, 2, Costumes.part_type.PALETTE)                                 // part 0xF_2 - shield - rim
    Costumes.define_part(10, 1, Costumes.part_type.PALETTE)                                   // part 0x10_0 - sword, sheathed
    Costumes.define_part(11, 3, Costumes.part_type.PALETTE)                                   // part 0x11_0 - shield on back - face
    Costumes.add_part_image(11, 1, Costumes.part_type.PALETTE)                                // part 0x11_1 - shield on back - stripes
    Costumes.add_part_image(11, 2, Costumes.part_type.PALETTE)                                // part 0x11_2 - shield on back - rim
    Costumes.define_part(12, 1, Costumes.part_type.PRIM_COLOR)                                // part 0x12_0 - neck
    Costumes.define_part(13, 5, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY) // part 0x13_0 - head - eyes
    Costumes.add_part_image(13, 1, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY) // part 0x13_1 - head - mouth
    Costumes.add_part_image(13, 2, Costumes.part_type.PALETTE)                                // part 0x13_2 - head - hair
    Costumes.add_part_image(13, 3, Costumes.part_type.PALETTE)                                // part 0x13_3 - head - hood front
    Costumes.add_part_image(13, 4, Costumes.part_type.PRIM_COLOR)                             // part 0x13_4 - head - ears
    Costumes.define_part(14, 1, Costumes.part_type.PALETTE)                                   // part 0x14_0 - hood tip
    Costumes.define_part(16, 1, Costumes.part_type.PALETTE)                                   // part 0x16_0 - left upper leg
    Costumes.define_part(17, 2, Costumes.part_type.PALETTE)                                   // part 0x17_0 - left lower leg - knee
    Costumes.add_part_image(17, 1, Costumes.part_type.PALETTE)                                // part 0x17_1 - left lower leg - boot
    Costumes.define_part(19, 1, Costumes.part_type.PALETTE)                                   // part 0x19_0 - left foot
    Costumes.define_part(1B, 1, Costumes.part_type.PALETTE)                                   // part 0x1B_0 - right upper leg
    Costumes.define_part(1C, 2, Costumes.part_type.PALETTE)                                   // part 0x1C_0 - right lower leg - knee
    Costumes.add_part_image(1C, 1, Costumes.part_type.PALETTE)                                // part 0x1C_1 - right lower leg - boot
    Costumes.define_part(1E, 1, Costumes.part_type.PALETTE)                                   // part 0x1D_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.YLINK)

	// Costume 0x6
	// Yellow Young Link
    // TODO: update!
    scope costume_0x6 {
        palette_1:; insert "YoungLink/cos_6_1.bin"
        palette_2:; insert "YoungLink/cos_6_2.bin"
        palette_3:; insert "YoungLink/cos_6_3.bin"
        palette_4:; insert "YoungLink/cos_6_4.bin"
        palette_5:; insert "YoungLink/cos_6_5.bin"
        palette_6:; insert "YoungLink/cos_6_6.bin"
        palette_7:; insert "YoungLink/cos_6_7.bin"
        palette_8:; insert "YoungLink/cos_6_8.bin"
        palette_9:; insert "YoungLink/cos_6_9.bin"
        palette_10:; insert "YoungLink/cos_6_10.bin"
        palette_11:; insert "YoungLink/cos_6_11.bin"
        palette_12:; insert "YoungLink/cos_6_12.bin"
        palette_13:; insert "YoungLink/cos_6_13.bin"

        Costumes.set_palette_for_part(0, 1, 0, palette_1)
        Costumes.set_palette_for_part(0, 1, 1, palette_2)
        Costumes.set_palette_for_part(0, 2, 0, palette_3)
        Costumes.set_palette_for_part(0, 2, 1, palette_2)
        Costumes.set_palette_for_part(0, 2, 2, palette_2)
        Costumes.set_prim_color_for_part(0, 2, 3, 0xfff36800)
        Costumes.set_prim_color_for_part(0, 4, 0, 0xfff36800)
        Costumes.set_prim_color_for_part(0, 5, 0, 0xf7d78700)
        Costumes.set_prim_color_for_part(0, 6, 0, 0xf7d78700)
        Costumes.set_palette_for_part(0, 7, 0, palette_3)
        Costumes.set_palette_for_part(0, 10, 0, palette_3)
        Costumes.set_prim_color_for_part(0, 9, 0, 0xfff36800)
        Costumes.set_prim_color_for_part(0, A, 0, 0xf7d78700)
        Costumes.set_prim_color_for_part(0, B, 0, 0xf7d78700)
        Costumes.set_palette_for_part(0, F, 0, palette_4)
        Costumes.set_palette_for_part(0, F, 1, palette_5)
        Costumes.set_palette_for_part(0, F, 2, palette_6)
		Costumes.set_palette_for_part(0, 11, 0, palette_4)
        Costumes.set_palette_for_part(0, 11, 1, palette_5)
        Costumes.set_palette_for_part(0, 11, 2, palette_6)
        Costumes.set_prim_color_for_part(0, 12, 0, 0xf7d78700)
        Costumes.set_palette_for_part(0, 13, 0, palette_7)
        Costumes.set_palette_for_part(0, 13, 1, palette_8)
        Costumes.set_palette_for_part(0, 13, 2, palette_9)
        Costumes.set_palette_for_part(0, 13, 3, palette_2)
        Costumes.set_prim_color_for_part(0, 13, 4, 0xf7d78700)
        Costumes.set_palette_for_part(0, 14, 0, palette_2)
        Costumes.set_palette_for_part(0, 16, 0, palette_11)
        Costumes.set_palette_for_part(0, 17, 0, palette_11)
        Costumes.set_palette_for_part(0, 17, 1, palette_12)
        Costumes.set_palette_for_part(0, 19, 0, palette_13)
        Costumes.set_palette_for_part(0, 1B, 0, palette_11)
        Costumes.set_palette_for_part(0, 1C, 0, palette_11)
        Costumes.set_palette_for_part(0, 1C, 1, palette_12)
        Costumes.set_palette_for_part(0, 1E, 0, palette_13)

        Costumes.set_stock_icon_palette_for_costume(0, YoungLink/cos_6_stock.bin)
    }
}
