scope marina_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1B)

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

    Costumes.define_part(1, 3, Costumes.part_type.PALETTE)                            // part 0x01_0 - Skirt
    Costumes.add_part_image(1, 1, Costumes.part_type.PRIM_COLOR)                      // part 0x01_1 - Pelvis (hi poly) / Skirt (lo poly)
    Costumes.add_part_image(1, 2, Costumes.part_type.PRIM_COLOR)                      // part 0x01_2 - Skirt (hi poly)
    Costumes.define_part(2, 2, Costumes.part_type.PALETTE)                            // part 0x02_1 - Torso Armour
    Costumes.add_part_image(2, 1, Costumes.part_type.PRIM_COLOR)                      // part 0x02_2 - Torso
    Costumes.define_part(4, 3, Costumes.part_type.PALETTE)                            // part 0x04_0 - L Shoulder
    Costumes.add_part_image(4, 1, Costumes.part_type.PRIM_COLOR)                      // part 0x04_1 - L Arm
    Costumes.add_part_image(4, 2, Costumes.part_type.PRIM_COLOR)                      // part 0x04_2 - L Shoulder Prim
    Costumes.define_part(5, 2, Costumes.part_type.PRIM_COLOR)                         // part 0x05_0 - L Arm Shirt
    Costumes.add_part_image(5, 1, Costumes.part_type.PRIM_COLOR)                      // part 0x05_1 - L Arm
    Costumes.define_part(6, 3, Costumes.part_type.PALETTE)                            // part 0x06_0 - L Fingers
    Costumes.add_part_image(6, 1, Costumes.part_type.PALETTE)                         // part 0x06_1 - L Gem
    Costumes.add_part_image(6, 2, Costumes.part_type.PRIM_COLOR)                      // part 0x06_2 - L Hand
    Costumes.define_special_parts_for_part(6, 2)
    Costumes.add_special_part(6, 1, 3, Costumes.part_type.PALETTE)                    // part 0x06_1_0 - L Gem clapping
    Costumes.add_special_part_image(6, 1, 1, Costumes.part_type.PALETTE)              // part 0x06_1_1 - L Fingers clapping
    Costumes.add_special_part_image(6, 1, 2, Costumes.part_type.PRIM_COLOR)           // part 0x06_1_2 - L Hand clapping
    Costumes.define_part(7, 1, Costumes.part_type.PRIM_COLOR)                         // part 0x07_0 - Neck
    Costumes.define_part(8, 7, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE) // part 0x08_0 - Eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE) // part 0x08_1 - Mouth
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE)                         // part 0x08_2 - Hat
    Costumes.add_part_image(8, 3, Costumes.part_type.PRIM_COLOR)                      // part 0x08_3 - Hair
    Costumes.add_part_image(8, 4, Costumes.part_type.PRIM_COLOR)                      // part 0x08_4 - Hat Inner
    Costumes.add_part_image(8, 5, Costumes.part_type.PRIM_COLOR)                      // part 0x08_5 - Hat Armour color
    Costumes.add_part_image(8, 6, Costumes.part_type.PRIM_COLOR)                      // part 0x08_6 - Face
    Costumes.define_part(9, 1, Costumes.part_type.PALETTE)                            // part 0x09_0 - Ribbon
    Costumes.define_part(B, 3, Costumes.part_type.PALETTE)                            // part 0x0B_0 - R Shoulder
    Costumes.add_part_image(B, 1, Costumes.part_type.PRIM_COLOR)                      // part 0x0B_2 - R Arm
    Costumes.add_part_image(B, 2, Costumes.part_type.PRIM_COLOR)                      // part 0x0B_2 - R Shoulder Prim
    Costumes.define_part(C, 2, Costumes.part_type.PRIM_COLOR)                         // part 0x0C_0 - R Arm Shirt
    Costumes.add_part_image(C, 1, Costumes.part_type.PRIM_COLOR)                      // part 0x0C_1 - R Arm
    Costumes.define_part(D, 3, Costumes.part_type.PALETTE)                            // part 0x0D_0 - R Fingers
    Costumes.add_part_image(D, 1, Costumes.part_type.PALETTE)                         // part 0x0D_1 - R Gem
    Costumes.add_part_image(D, 2, Costumes.part_type.PRIM_COLOR)                      // part 0x0D_2 - R Hand
	Costumes.define_special_parts_for_part(D, 2)
    Costumes.add_special_part(D, 1, 3, Costumes.part_type.PALETTE)                    // part 0x0D_1_0 - R Gem clapping
    Costumes.add_special_part_image(D, 1, 1, Costumes.part_type.PALETTE)              // part 0x0D_1_1 - R Fingers clapping
    Costumes.add_special_part_image(D, 1, 2, Costumes.part_type.PRIM_COLOR)           // part 0x0D_1_2 - R Hand clapping
    Costumes.define_part(F,1, Costumes.part_type.PALETTE)                             // part 0x0D_0 - Thruster (Special Part)
    Costumes.define_part(11, 2, Costumes.part_type.PALETTE)                           // part 0x11_0 - L Thigh
    Costumes.add_part_image(11, 1, Costumes.part_type.PRIM_COLOR)                     // part 0x11_1 - L Thigh Prim
    Costumes.define_part(12, 1, Costumes.part_type.PALETTE)                           // part 0x12_0 - L Calf
    Costumes.define_part(16, 2, Costumes.part_type.PALETTE)                           // part 0x16_0 - R Thigh
    Costumes.add_part_image(16, 1, Costumes.part_type.PRIM_COLOR)                     // part 0x16_1 - R Thigh Prim
    Costumes.define_part(17, 1, Costumes.part_type.PALETTE)                           // part 0x17_0 - R Calf
	Costumes.define_part(1A, 1, Costumes.part_type.PALETTE)                           // part 0x0D_0 - Pot (Special Part)

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.MARINA)

    // Costume 0x6
	// Pumpkin
    scope costume_0x6 {
        palette_1:; insert "Marina/cos_6_1.bin"  //armour
        palette_2:; insert "Marina/cos_6_2.bin"  //fingers
        palette_3:; insert "Marina/cos_6_3.bin"  //gems
        palette_4:; insert "Marina/cos_6_4.bin"  //ribbons
        palette_5:; insert "Marina/cos_6_5.bin"  //hat
        palette_6:; insert "Marina/cos_6_6.bin"  //legs
        palette_7:; insert "Marina/cos_6_7.bin"  //feet
        palette_8:; insert "Marina/cos_6_8.bin"  //eyes
        palette_9:; insert "Marina/cos_6_9.bin"  //Mouth
        constant color_armour(0xfdb300FF)
        constant color_body(0x4d2d88FF)
        constant color_skin(0xffda8bFF)
        constant color_hair(0xef0060FF)

		Costumes.set_palette_for_part(0, 1, 0, palette_1)
        Costumes.set_prim_color_for_part(0, 1, 1, color_body)
        Costumes.set_prim_color_for_part_lo(0, 1, 1, color_armour) // lo poly skirt
        Costumes.set_prim_color_for_part(0, 1, 2, color_armour)
		Costumes.set_palette_for_part(0, 2, 0, palette_1)
        Costumes.set_prim_color_for_part(0, 2, 1, color_body)
		Costumes.set_palette_for_part(0, 4, 0, palette_1)
        Costumes.set_prim_color_for_part(0, 4, 1, color_skin)
        Costumes.set_prim_color_for_part(0, 4, 2, color_armour)
        Costumes.set_prim_color_for_part(0, 5, 0, color_body)
        Costumes.set_prim_color_for_part(0, 5, 1, color_skin)
		Costumes.set_palette_for_part(0, 6, 0, palette_2)
		Costumes.set_palette_for_part(0, 6, 1, palette_3)
        Costumes.set_prim_color_for_part(0, 6, 2, color_armour)
        Costumes.set_palette_for_special_part(0, 6, 1, 0, palette_3)
        Costumes.set_palette_for_special_part(0, 6, 1, 1, palette_2)
        Costumes.set_prim_color_for_special_part(0, 6, 1, 2, color_armour)
        Costumes.set_prim_color_for_part(0, 7, 0, color_skin)
		Costumes.set_palette_for_part(0, 8, 0, palette_8)
		Costumes.set_palette_for_part(0, 8, 1, palette_9)
		Costumes.set_palette_for_part(0, 8, 2, palette_5)
        Costumes.set_prim_color_for_part(0, 8, 3, color_hair)
        Costumes.set_prim_color_for_part(0, 8, 4, color_body)
        Costumes.set_prim_color_for_part(0, 8, 5, color_armour)
        Costumes.set_prim_color_for_part(0, 8, 6, color_skin)
		Costumes.set_palette_for_part(0, 9, 0, palette_4)
		Costumes.set_palette_for_part(0, B, 0, palette_1)
        Costumes.set_prim_color_for_part(0, B, 1, color_skin)
        Costumes.set_prim_color_for_part(0, B, 2, color_armour)
        Costumes.set_prim_color_for_part(0, C, 0, color_body)
        Costumes.set_prim_color_for_part(0, C, 1, color_skin)
		Costumes.set_palette_for_part(0, D, 0, palette_2)
		Costumes.set_palette_for_part(0, D, 1, palette_3)
        Costumes.set_prim_color_for_part(0, D, 2, color_armour)
        Costumes.set_palette_for_special_part(0, D, 1, 0, palette_3)
        Costumes.set_palette_for_special_part(0, D, 1, 1, palette_2)
        Costumes.set_prim_color_for_special_part(0, D, 1, 2, color_armour)
		Costumes.set_palette_for_part(0, 11, 0, palette_6)
        Costumes.set_prim_color_for_part(0, 11, 1, color_body)
		Costumes.set_palette_for_part(0, 12, 0, palette_7)
		Costumes.set_palette_for_part(0, 16, 0, palette_6)
        Costumes.set_prim_color_for_part(0, 16, 1, color_body)
		Costumes.set_palette_for_part(0, 17, 0, palette_7)

        Costumes.set_stock_icon_palette_for_costume(0, Marina/cos_6_stock.bin)
    }

}
