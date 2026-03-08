scope mewtwo_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x20)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(6)

    parts_table:
    constant PARTS_TABLE_ORIGIN(origin())
    db NUM_EXTRA_COSTUMES       // 0x0 - number of extra costumes
    db 0x0                      // 0x1 - special part ID
    db 0x0                      // 0x2 - special part image index start
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(1, 1, Costumes.part_type.PALETTE)                                               // - Pelvis
    Costumes.define_part(2, 4, Costumes.part_type.PALETTE)                                               // - Chest
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                                            // - Chest
    Costumes.add_part_image(2, 2, Costumes.part_type.PALETTE)                                            // - Chest
    Costumes.add_part_image(2, 3, Costumes.part_type.PRIM_COLOR)                                         // - Chest Prim
    Costumes.define_part(4, 1, Costumes.part_type.PRIM_COLOR)                                            // - L Arm
    Costumes.define_part(5, 1, Costumes.part_type.PRIM_COLOR)                                            // - L Elbow
    Costumes.define_part(6, 2, Costumes.part_type.PALETTE)                                               // - L Finger
    Costumes.add_part_image(6, 1, Costumes.part_type.PRIM_COLOR)                                         // - L Hand
    Costumes.define_part(7, 1, Costumes.part_type.PRIM_COLOR)                                            // - Neck
    Costumes.define_part(8, 3, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)            // - Eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)                                            // - Mouth
    Costumes.add_part_image(8, 2, Costumes.part_type.PRIM_COLOR)                                         // - Head
    Costumes.define_special_parts_for_part(8, 2)                                                         // - DSP head
    Costumes.add_special_part(8, 1, 4, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)    // - DSP head eyes
    Costumes.add_special_part_image(8, 1, 1, Costumes.part_type.PALETTE)                                 // - DSP head mouth
    Costumes.add_special_part_image(8, 1, 2, Costumes.part_type.PALETTE)                                 // - DSP head mouth
    Costumes.add_special_part_image(8, 1, 3, Costumes.part_type.PRIM_COLOR)                              // - DSP head skin
    Costumes.define_part(9, 1, Costumes.part_type.PRIM_COLOR)                                            // - Neck Tube
    Costumes.define_part(A, 1, Costumes.part_type.PRIM_COLOR)                                            // - Neck Tube
    Costumes.define_part(C, 1, Costumes.part_type.PRIM_COLOR)                                            // - R Arm
    Costumes.define_part(D, 1, Costumes.part_type.PRIM_COLOR)                                            // - R Elbow
    Costumes.define_part(E, 2, Costumes.part_type.PALETTE)                                               // - R Finger
    Costumes.add_part_image(E, 1, Costumes.part_type.PRIM_COLOR)                                         // - R Hand
    Costumes.define_part(F, 1, Costumes.part_type.PALETTE)                                               // - Tail
    Costumes.define_part(10, 1, Costumes.part_type.PRIM_COLOR)                                           // - Tail 2
    Costumes.define_part(11, 1, Costumes.part_type.PRIM_COLOR)                                           // - Tail 3
    Costumes.define_part(12, 1, Costumes.part_type.PRIM_COLOR)                                           // - Tail 4
    Costumes.define_part(14, 1, Costumes.part_type.PRIM_COLOR)                                           // - L Thigh
    Costumes.define_part(15, 1, Costumes.part_type.PRIM_COLOR)                                           // - L Thigh knee
    Costumes.define_part(16, 1, Costumes.part_type.PRIM_COLOR)                                           // - L Knee Foot
    Costumes.define_part(18, 1, Costumes.part_type.PRIM_COLOR)                                           // - L Toe
    Costumes.define_part(1A, 1, Costumes.part_type.PRIM_COLOR)                                           // - R Thigh
    Costumes.define_part(1B, 1, Costumes.part_type.PRIM_COLOR)                                           // - R Thigh knee
    Costumes.define_part(1C, 1, Costumes.part_type.PRIM_COLOR)                                           // - R Knee Foot
    Costumes.define_part(1E, 1, Costumes.part_type.PRIM_COLOR)                                           // - R Toe

	 // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.MTWO)

    // Costume 0x6
	// Bling
    scope costume_0x6 {
        belly:; insert "Mewtwo/cos_6_1.bin"
        chest:; insert "Mewtwo/cos_6_2.bin"
        back:; insert "Mewtwo/cos_6_3.bin"
        shoulder:; insert "Mewtwo/cos_6_4.bin"
        finger:; insert "Mewtwo/cos_6_5.bin"
        eye:; insert "Mewtwo/cos_6_6.bin"
        mouth:; insert "Mewtwo/cos_6_7.bin"
        constant color_body(0xffd4f0FF)
        constant color_tail(0xec4f89FF)

		Costumes.set_palette_for_part(0, 1, 0, belly)
		Costumes.set_palette_for_part(0, 2, 0, chest)
		Costumes.set_palette_for_part(0, 2, 1, back)
		Costumes.set_palette_for_part(0, 2, 2, shoulder)
		Costumes.set_prim_color_for_part(0, 2, 3, color_body)
		Costumes.set_prim_color_for_part(0, 4, 0, color_body)
		Costumes.set_prim_color_for_part(0, 5, 0, color_body)
		Costumes.set_palette_for_part(0, 6, 0, finger)
		Costumes.set_prim_color_for_part(0, 6, 1, color_body)
		Costumes.set_prim_color_for_part(0, 7, 0, color_body)
		Costumes.set_palette_for_part(0, 8, 0, eye)
		Costumes.set_palette_for_part(0, 8, 1, mouth)
		Costumes.set_prim_color_for_part(0, 8, 2, color_body)
        Costumes.set_palette_for_special_part(0, 8, 1, 0, eye)
        Costumes.set_palette_for_special_part(0, 8, 1, 1, mouth)
        Costumes.set_palette_for_special_part(0, 8, 1, 2, eye)
		Costumes.set_prim_color_for_special_part(0, 8, 1, 3, color_body)
		Costumes.set_prim_color_for_part(0, 9, 0, color_body)
		Costumes.set_prim_color_for_part(0, A, 0, color_body)
		Costumes.set_prim_color_for_part(0, C, 0, color_body)
		Costumes.set_prim_color_for_part(0, D, 0, color_body)
		Costumes.set_palette_for_part(0, E, 0, finger)
		Costumes.set_prim_color_for_part(0, E, 1, color_body)
		Costumes.set_palette_for_part(0, F, 0, belly)
		Costumes.set_prim_color_for_part(0, 10, 0, color_tail)
		Costumes.set_prim_color_for_part(0, 11, 0, color_tail)
		Costumes.set_prim_color_for_part(0, 12, 0, color_tail)
		Costumes.set_prim_color_for_part(0, 14, 0, color_body)
		Costumes.set_prim_color_for_part(0, 15, 0, color_body)
		Costumes.set_prim_color_for_part(0, 16, 0, color_body)
		Costumes.set_prim_color_for_part(0, 18, 0, color_body)
		Costumes.set_prim_color_for_part(0, 1A, 0, color_body)
		Costumes.set_prim_color_for_part(0, 1B, 0, color_body)
		Costumes.set_prim_color_for_part(0, 1C, 0, color_body)
		Costumes.set_prim_color_for_part(0, 1E, 0, color_body)

        Costumes.set_stock_icon_palette_for_costume(0, Mewtwo/cos_6_stock.bin)
    }

}