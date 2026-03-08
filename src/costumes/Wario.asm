scope wario_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(2)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x18)

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

    Costumes.define_part(2, 2, Costumes.part_type.PALETTE)                                       // - torso
    Costumes.add_part_image(2, 1, Costumes.part_type.PRIM_COLOR)                                 // - torso pants
    Costumes.define_part(4, 1, Costumes.part_type.PRIM_COLOR)                                       // - L Arm 
    Costumes.define_part(5, 1, Costumes.part_type.PRIM_COLOR)                                       // - L Elbow
    Costumes.define_part(6, 2, Costumes.part_type.PALETTE)                                       // - L Hand
    Costumes.add_part_image(6, 1, Costumes.part_type.PRIM_COLOR)                                 // - L Hand Prim
    Costumes.define_part(8, 7, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)    // part 0x08_0 - Eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)                                    // - Head - Hat
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE)                                    // - Head - Mouth
    Costumes.add_part_image(8, 3, Costumes.part_type.PALETTE)                                    // - Head - Sideburns
    Costumes.add_part_image(8, 4, Costumes.part_type.PRIM_COLOR)                                 // - Head - Hair
    Costumes.add_part_image(8, 5, Costumes.part_type.PRIM_COLOR)                                 // - Head - Nose
    Costumes.add_part_image(8, 6, Costumes.part_type.PRIM_COLOR)                                 // - Head - Hat prim
    Costumes.define_part(A, 1, Costumes.part_type.PRIM_COLOR)                                       // - R Arm 
    Costumes.define_part(B, 1, Costumes.part_type.PRIM_COLOR)                                       // - R Elbow
    Costumes.define_part(C, 2, Costumes.part_type.PALETTE)                                       // - R Hand
    Costumes.add_part_image(C, 1, Costumes.part_type.PRIM_COLOR)                                 // - R Hand Prim
    Costumes.define_part(F, 1, Costumes.part_type.PRIM_COLOR)                                       // - L Leg
    Costumes.define_part(10, 1, Costumes.part_type.PRIM_COLOR)                                      // - L Knee
    Costumes.define_part(12, 2, Costumes.part_type.PRIM_COLOR)                                      // - L Foot
    Costumes.define_part(14, 1, Costumes.part_type.PRIM_COLOR)                                       // - R Leg
    Costumes.define_part(15, 1, Costumes.part_type.PRIM_COLOR)                                      // - R Knee
    Costumes.define_part(17, 2, Costumes.part_type.PRIM_COLOR)                                      // - R Foot

	 // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.WARIO)

    // Costume 0x6
	// 
    scope costume_0x6 {
        torso:; insert "Wario/cos_6_1.bin"
        glove:; insert "Wario/cos_6_2.bin"
        emblem:; insert "Wario/cos_6_3.bin"
        eye:; insert "Wario/cos_6_4.bin"
        mouth:; insert "Wario/cos_6_5.bin"
        burns:; insert "Wario/cos_6_6.bin"
        constant color_hat(0x00b013FF)
        constant color_shirt(0x4a4edcFF)
        constant color_pants(0x00b013FF)
        constant color_shoes(0x633202FF)
        constant color_glove(0xFFFFFFFF)
        constant color_nose(0xff5a7bFF)
        constant color_hair(0x85560aFF)

		Costumes.set_palette_for_part(0, 2, 0, torso)
        Costumes.set_prim_color_for_part(0, 2, 1, color_pants)
        Costumes.set_prim_color_for_part(0, 4, 0, color_shirt)
        Costumes.set_prim_color_for_part(0, 5, 0, color_shirt)
		Costumes.set_palette_for_part(0, 6, 0, glove)
        Costumes.set_prim_color_for_part(0, 6, 1, color_glove)
        Costumes.set_palette_for_part(0, 8, 0, eye)
        Costumes.set_palette_for_part(0, 8, 1, emblem)
        Costumes.set_palette_for_part(0, 8, 2, mouth)
        Costumes.set_palette_for_part(0, 8, 3, burns)
        Costumes.set_prim_color_for_part(0, 8, 4, color_hair)
        Costumes.set_prim_color_for_part(0, 8, 5, color_nose)
        Costumes.set_prim_color_for_part(0, 8, 6, color_hat)
        Costumes.set_prim_color_for_part(0, A, 0, color_shirt)
        Costumes.set_prim_color_for_part(0, B, 0, color_shirt)
		Costumes.set_palette_for_part(0, C, 0, glove)
        Costumes.set_prim_color_for_part(0, C, 1, color_glove)
        Costumes.set_prim_color_for_part(0, F, 0, color_pants)
        Costumes.set_prim_color_for_part(0, 10, 0, color_pants)
        Costumes.set_prim_color_for_part(0, 12, 0, color_shoes)
        Costumes.set_prim_color_for_part(0, 14, 0, color_pants)
        Costumes.set_prim_color_for_part(0, 15, 0, color_pants)
        Costumes.set_prim_color_for_part(0, 17, 0, color_shoes)

        Costumes.set_stock_icon_palette_for_costume(0, Wario/cos_6_stock.bin)
    }
	
    // Costume 0x7
	// 
    scope costume_0x7 {
        torso:; insert "Wario/cos_7_1.bin"
        glove:; insert "Wario/cos_7_2.bin"
        emblem:; insert "Wario/cos_7_3.bin"
        eye:; insert "Wario/cos_6_4.bin"
        mouth:; insert "Wario/cos_6_5.bin"
        burns:; insert "Wario/cos_6_6.bin"
        constant color_hat(0x3b3b3bFF)
        constant color_shirt(0x3b3b3bFF)
        constant color_pants(0xcf1111FF)
        constant color_shoes(0x480800FF)
        constant color_glove(0xFFFFFFFF)
        constant color_nose(0xff5a7bFF)
        constant color_hair(0x85560aFF)

		Costumes.set_palette_for_part(1, 2, 0, torso)
        Costumes.set_prim_color_for_part(1, 2, 1, color_pants)
        Costumes.set_prim_color_for_part(1, 4, 0, color_shirt)
        Costumes.set_prim_color_for_part(1, 5, 0, color_shirt)
		Costumes.set_palette_for_part(1, 6, 0, glove)
        Costumes.set_prim_color_for_part(1, 6, 1, color_glove)
        Costumes.set_palette_for_part(1, 8, 0, eye)
        Costumes.set_palette_for_part(1, 8, 1, emblem)
        Costumes.set_palette_for_part(1, 8, 2, mouth)
        Costumes.set_palette_for_part(1, 8, 3, burns)
        Costumes.set_prim_color_for_part(1, 8, 4, color_hair)
        Costumes.set_prim_color_for_part(1, 8, 5, color_nose)
        Costumes.set_prim_color_for_part(1, 8, 6, color_hat)
        Costumes.set_prim_color_for_part(1, A, 0, color_shirt)
        Costumes.set_prim_color_for_part(1, B, 0, color_shirt)
		Costumes.set_palette_for_part(1, C, 0, glove)
        Costumes.set_prim_color_for_part(1, C, 1, color_glove)
        Costumes.set_prim_color_for_part(1, F, 0, color_pants)
        Costumes.set_prim_color_for_part(1, 10, 0, color_pants)
        Costumes.set_prim_color_for_part(1, 12, 0, color_shoes)
        Costumes.set_prim_color_for_part(1, 14, 0, color_pants)
        Costumes.set_prim_color_for_part(1, 15, 0, color_pants)
        Costumes.set_prim_color_for_part(1, 17, 0, color_shoes)

        Costumes.set_stock_icon_palette_for_costume(1, Wario/cos_7_stock.bin)
    }
}