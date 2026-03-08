scope peach_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(2)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1C)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(7)

    parts_table:
    constant PARTS_TABLE_ORIGIN(origin())
    db NUM_EXTRA_COSTUMES       // 0x0 - number of extra costumes
    db 0x0                      // 0x1 - special part ID
    db 0x0                      // 0x2 - special part image index start
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(2, 3, Costumes.part_type.PALETTE)                                                                           // - Broach
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                                                                        // - Waist
    Costumes.add_part_image(2, 2, Costumes.part_type.PRIM_COLOR)                                                                     // - Body Prim
    Costumes.define_part(4, 2, Costumes.part_type.PALETTE)                                                                           // - L Arm
    Costumes.add_part_image(4, 1, Costumes.part_type.PRIM_COLOR)                                                                     // - L Shoulder
    Costumes.define_part(5, 1, Costumes.part_type.PRIM_COLOR)                                                                        // - L Elbow
    Costumes.define_part(6, 1, Costumes.part_type.PRIM_COLOR)                                                                        // - L Hand
    Costumes.define_special_parts_for_part(6, 2)                                     				                                 // -
    Costumes.add_special_part(6, 1, 2, Costumes.part_type.PALETTE)                                                                   // - (special 1) Crown in Hand
    Costumes.add_special_part_image(6, 1, 1, Costumes.part_type.PRIM_COLOR)                                                          // - (special 1) Crown in Hand
    Costumes.define_part(7, 1, Costumes.part_type.PRIM_COLOR)                                                                        // - Neck
    Costumes.define_part(8, 7, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)                                        // - L Eye
    Costumes.add_part_image(8, 1, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)                                     // - R Eye
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE)                                                                        // - Crown
    Costumes.add_part_image(8, 3, Costumes.part_type.PALETTE)                                                                        // - Earrings
    Costumes.add_part_image(8, 4, Costumes.part_type.PALETTE)                                                                        // - Mouth
    Costumes.add_part_image(8, 5, Costumes.part_type.PRIM_COLOR)                                                                     // - Head
    Costumes.add_part_image(8, 6, Costumes.part_type.PRIM_COLOR)                                                                     // - Hair
    Costumes.define_special_parts_for_part(8, 2)                                     				                                 // -
    Costumes.add_special_part(8, 1, 6, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)                                // - (special 1) L Eye
    Costumes.add_special_part_image(8, 1, 1, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)                          // - (special 1) R Eye
    Costumes.add_special_part_image(8, 1, 2, Costumes.part_type.PALETTE)                                                             // - (special 1) Earrings
    Costumes.add_special_part_image(8, 1, 3, Costumes.part_type.PALETTE)                                                             // - (special 1) Mouth
    Costumes.add_special_part_image(8, 1, 4, Costumes.part_type.PRIM_COLOR)                                                          // - (special 1) Head
    Costumes.add_special_part_image(8, 1, 5, Costumes.part_type.PRIM_COLOR)                                                          // - (special 1) Hair
	
	
    Costumes.define_part(9, 1, Costumes.part_type.PRIM_COLOR)                                                                        // - Hair
    Costumes.define_part(B, 2, Costumes.part_type.PALETTE)                                                                           // - R Arm
    Costumes.add_part_image(B, 1, Costumes.part_type.PRIM_COLOR)                                                                     // - R Shoulder
    Costumes.define_part(C, 1, Costumes.part_type.PRIM_COLOR)                                                                        // - R Elbow
    Costumes.define_part(D, 1, Costumes.part_type.PRIM_COLOR)                                                                        // - R Hand
    Costumes.define_part(E, 1, Costumes.part_type.PRIM_COLOR)                                                                        // - Frying Pan
    Costumes.define_special_parts_for_part(E, 3)                                     				                                 // -
    Costumes.add_special_part(E, 1, 1, Costumes.part_type.PRIM_COLOR)                                                                // - (special 1) Racket
    Costumes.add_special_part(E, 2, 1, Costumes.part_type.PRIM_COLOR)                                                                // - (special 1) Club
    Costumes.define_part(11, 1, Costumes.part_type.PRIM_COLOR)                                                                       // - L Leg
    Costumes.define_part(13, 1, Costumes.part_type.PRIM_COLOR)                                                                       // - L Foot
    Costumes.define_part(16, 1, Costumes.part_type.PRIM_COLOR)                                                                       // - L Leg
    Costumes.define_part(18, 1, Costumes.part_type.PRIM_COLOR)                                                                       // - L Foot
    Costumes.define_part(19, 1, Costumes.part_type.PRIM_COLOR)                                                                       // - Dress Top
    Costumes.define_part(1A, 1, Costumes.part_type.PALETTE)                                                                          // - Dress Bot
	
	 // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.PEACH)

    // Costume 0x7
	// 
    scope costume_0x7 {
        broach:; insert "Peach/cos_7_1.bin"
        band:; insert "Peach/cos_7_2.bin"
        dress:; insert "Peach/cos_7_8.bin"
        arm:; insert "Peach/cos_7_3.bin"
        eyes:; insert "Peach/cos_7_4.bin"
        mouth:; insert "Peach/cos_7_5.bin"
        crown:; insert "Peach/cos_7_6.bin"
        earrings:; insert "Peach/cos_7_7.bin"
        constant color_hair(0xffd923FF)
        constant color_dress(0xf6ecfdFF)
        constant color_shoes(0xd8b5f0FF)
        constant color_skin(0xf8e0a0FF)
        constant color_gloves(0xf0f0f0FF)
        constant color_pan(0x3f3f3fFF)
        constant color_racket(0x914b1fFF)
		


		Costumes.set_palette_for_part(0, 2, 0, broach)
		Costumes.set_palette_for_part(0, 2, 1, band)
		Costumes.set_prim_color_for_part(0, 2, 2, color_dress)
		Costumes.set_palette_for_part(0, 4, 0, arm)
		Costumes.set_prim_color_for_part(0, 4, 1, color_dress)
		Costumes.set_prim_color_for_part(0, 5, 0, color_gloves)
		Costumes.set_prim_color_for_part(0, 6, 0, color_gloves)
        Costumes.set_palette_for_special_part(0, 6, 1, 0, crown)
        Costumes.set_prim_color_for_special_part(0, 6, 1, 1, color_gloves)
		Costumes.set_prim_color_for_part(0, 7, 0, color_skin)
		Costumes.set_palette_for_part(0, 8, 0, eyes)
		Costumes.set_palette_for_part(0, 8, 1, eyes)
		Costumes.set_palette_for_part(0, 8, 2, crown)
		Costumes.set_palette_for_part(0, 8, 3, earrings)
		Costumes.set_palette_for_part(0, 8, 4, mouth)
		Costumes.set_prim_color_for_part(0, 8, 5, color_skin)
		Costumes.set_prim_color_for_part(0, 8, 6, color_hair)
        Costumes.set_palette_for_special_part(0, 8, 1, 0, eyes)
        Costumes.set_palette_for_special_part(0, 8, 1, 1, eyes)
        Costumes.set_palette_for_special_part(0, 8, 1, 2, mouth)
        Costumes.set_palette_for_special_part(0, 8, 1, 3, earrings)
        Costumes.set_prim_color_for_special_part(0, 8, 1, 4, color_skin)
        Costumes.set_prim_color_for_special_part(0, 8, 1, 5, color_hair)
		Costumes.set_prim_color_for_part(0, 9, 0, color_hair)
		Costumes.set_palette_for_part(0, B, 0, arm)
		Costumes.set_prim_color_for_part(0, B, 1, color_dress)
		Costumes.set_prim_color_for_part(0, C, 0, color_gloves)
		Costumes.set_prim_color_for_part(0, D, 0, color_gloves)
		Costumes.set_prim_color_for_part(0, E, 0, color_pan)
        Costumes.set_prim_color_for_special_part(0, E, 1, 0, color_racket)
        Costumes.set_prim_color_for_special_part(0, E, 2, 0, color_pan)
		Costumes.set_prim_color_for_part(0, 11, 0, color_skin)
		Costumes.set_prim_color_for_part(0, 13, 0, color_shoes)
		Costumes.set_prim_color_for_part(0, 16, 0, color_skin)
		Costumes.set_prim_color_for_part(0, 18, 0, color_shoes)
		Costumes.set_prim_color_for_part(0, 19, 0, color_dress)
		Costumes.set_palette_for_part(0, 1A, 0, dress)

        Costumes.set_stock_icon_palette_for_costume(0, Peach/cos_7_stock.bin)
    }
 // Costume 0x7
	// 
    scope costume_0x8 {
        broach:; insert "Peach/cos_8_1.bin"
        dress:; insert "Peach/cos_8_2.bin"
        arm:; insert "Peach/cos_7_3.bin"
        eyes:; insert "Peach/cos_7_4.bin"
        mouth:; insert "Peach/cos_7_5.bin"
        crown:; insert "Peach/cos_8_6.bin"
        earrings:; insert "Peach/cos_8_7.bin"
        constant color_hair(0xffd923FF)
        constant color_dress(0x3e3e3eFF)
        constant color_shoes(0x222222FF)
        constant color_skin(0xf8e0a0FF)
        constant color_gloves(0xf0f0f0FF)
        constant color_pan(0x3f3f3fFF)
        constant color_racket(0x914b1fFF)
		


		Costumes.set_palette_for_part(1, 2, 0, broach)
		Costumes.set_palette_for_part(1, 2, 1, dress)
		Costumes.set_prim_color_for_part(1, 2, 2, color_dress)
		Costumes.set_palette_for_part(1, 4, 0, arm)
		Costumes.set_prim_color_for_part(1, 4, 1, color_dress)
		Costumes.set_prim_color_for_part(1, 5, 0, color_gloves)
		Costumes.set_prim_color_for_part(1, 6, 0, color_gloves)
        Costumes.set_palette_for_special_part(1, 6, 1, 0, crown)
        Costumes.set_prim_color_for_special_part(1, 6, 1, 1, color_gloves)
		Costumes.set_prim_color_for_part(1, 7, 0, color_skin)
		Costumes.set_palette_for_part(1, 8, 0, eyes)
		Costumes.set_palette_for_part(1, 8, 1, eyes)
		Costumes.set_palette_for_part(1, 8, 2, crown)
		Costumes.set_palette_for_part(1, 8, 3, earrings)
		Costumes.set_palette_for_part(1, 8, 4, mouth)
		Costumes.set_prim_color_for_part(1, 8, 5, color_skin)
		Costumes.set_prim_color_for_part(1, 8, 6, color_hair)
        Costumes.set_palette_for_special_part(1, 8, 1, 0, eyes)
        Costumes.set_palette_for_special_part(1, 8, 1, 1, eyes)
        Costumes.set_palette_for_special_part(1, 8, 1, 2, mouth)
        Costumes.set_palette_for_special_part(1, 8, 1, 3, earrings)
        Costumes.set_prim_color_for_special_part(1, 8, 1, 4, color_skin)
        Costumes.set_prim_color_for_special_part(1, 8, 1, 5, color_hair)
		Costumes.set_prim_color_for_part(1, 9, 0, color_hair)
		Costumes.set_palette_for_part(1, B, 0, arm)
		Costumes.set_prim_color_for_part(1, B, 1, color_dress)
		Costumes.set_prim_color_for_part(1, C, 0, color_gloves)
		Costumes.set_prim_color_for_part(1, D, 0, color_gloves)
		Costumes.set_prim_color_for_part(1, E, 0, color_pan)
        Costumes.set_prim_color_for_special_part(1, E, 1, 0, color_racket)
        Costumes.set_prim_color_for_special_part(1, E, 2, 0, color_pan)
		Costumes.set_prim_color_for_part(1, 11, 0, color_skin)
		Costumes.set_prim_color_for_part(1, 13, 0, color_shoes)
		Costumes.set_prim_color_for_part(1, 16, 0, color_skin)
		Costumes.set_prim_color_for_part(1, 18, 0, color_shoes)
		Costumes.set_prim_color_for_part(1, 19, 0, color_dress)
		Costumes.set_palette_for_part(1, 1A, 0, dress)

        Costumes.set_stock_icon_palette_for_costume(1, Peach/cos_8_stock.bin)
    }

}