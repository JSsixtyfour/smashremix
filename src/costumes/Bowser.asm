scope bowser_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1C)

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

    Costumes.define_part(1, 2, Costumes.part_type.PALETTE)                                       // - Pelvis
    Costumes.add_part_image(1, 1, Costumes.part_type.PALETTE)                                    // - Shell
    Costumes.define_part(2, 3, Costumes.part_type.PALETTE)                                       // - Chest
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                                    // - Neck
    Costumes.add_part_image(2, 2, Costumes.part_type.PALETTE)                                    // - Shell
    Costumes.define_part(3, 5, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)    // - Eye L
    Costumes.add_part_image(3, 1, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE) // - Eye R
    Costumes.add_part_image(3, 2, Costumes.part_type.PALETTE)                                     // - Horn
    Costumes.add_part_image(3, 3, Costumes.part_type.PALETTE)                                     // - Hair
    Costumes.add_part_image(3, 4, Costumes.part_type.PALETTE)                                     // - Mouth
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)                                        // - Jaw
    Costumes.define_part(7, 2, Costumes.part_type.PALETTE)                                        // - L Shoulder
    Costumes.add_part_image(7, 1, Costumes.part_type.PALETTE)                                     // - L Shoulder
    Costumes.define_part(8, 1, Costumes.part_type.PALETTE)                                        // - L Arm
    Costumes.define_part(9, 2, Costumes.part_type.PALETTE)                                        // - L Hand
    Costumes.add_part_image(9, 1, Costumes.part_type.PALETTE)                                     // - L Hand
    Costumes.define_part(B, 2, Costumes.part_type.PALETTE)                                        // - R Shoulder
    Costumes.add_part_image(B, 1, Costumes.part_type.PALETTE)                                     // - R Shoulder
    Costumes.define_part(C, 1, Costumes.part_type.PALETTE)                                        // - R Arm
    Costumes.define_part(D, 2, Costumes.part_type.PALETTE)                                        // - R Hand
    Costumes.add_part_image(D, 1, Costumes.part_type.PALETTE)                                     // - R Hand
    Costumes.define_part(F, 2, Costumes.part_type.PALETTE)                                        // - Tail top
    Costumes.add_part_image(F, 1, Costumes.part_type.PALETTE)                                     // - Tail bot
    Costumes.define_part(10, 2, Costumes.part_type.PALETTE)                                       // - Tail tip top
    Costumes.add_part_image(10, 1, Costumes.part_type.PALETTE)                                    // - Tail tip bot
    Costumes.define_part(12, 1, Costumes.part_type.PALETTE)                                       // - L Thigh
    Costumes.define_part(13, 1, Costumes.part_type.PALETTE)                                       // - L Calf
    Costumes.define_part(15, 1, Costumes.part_type.PALETTE)                                       // - L Foot
    Costumes.define_part(17, 1, Costumes.part_type.PALETTE)                                       // - R Thigh
    Costumes.define_part(18, 1, Costumes.part_type.PALETTE)                                       // - R Calf
    Costumes.define_part(1A, 1, Costumes.part_type.PALETTE)                                       // - R Foot

	 // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.BOWSER)

    // Costume 0x6
	// Bling
    scope costume_0x6 {
        belly:; insert "Bowser/cos_6_1.bin"    
        shell:; insert "Bowser/cos_6_2.bin"
        collar:; insert "Bowser/cos_6_3.bin"
        eye:; insert "Bowser/cos_6_4.bin"
        claw:; insert "Bowser/cos_6_5.bin"
        hair:; insert "Bowser/cos_6_6.bin"
        mouth:; insert "Bowser/cos_6_7.bin"
        scale:; insert "Bowser/cos_6_8.bin"
        tail:; insert "Bowser/cos_6_9.bin"

		Costumes.set_palette_for_part(0, 1, 0, belly)
		Costumes.set_palette_for_part(0, 1, 1, shell)
		Costumes.set_palette_for_part(0, 2, 0, belly)
		Costumes.set_palette_for_part(0, 2, 1, collar)
		Costumes.set_palette_for_part(0, 2, 2, shell)
		Costumes.set_palette_for_part(0, 3, 0, eye)
		Costumes.set_palette_for_part(0, 3, 1, eye)
		Costumes.set_palette_for_part(0, 3, 2, claw)
		Costumes.set_palette_for_part(0, 3, 3, hair)
		Costumes.set_palette_for_part(0, 3, 4, mouth)
		Costumes.set_palette_for_part(0, 4, 0, mouth)
		Costumes.set_palette_for_part(0, 7, 0, collar)
		Costumes.set_palette_for_part(0, 7, 1, scale)
		Costumes.set_palette_for_part(0, 8, 0, collar)
		Costumes.set_palette_for_part(0, 9, 0, claw)
		Costumes.set_palette_for_part(0, 9, 1, scale)
		Costumes.set_palette_for_part(0, B, 0, collar)
		Costumes.set_palette_for_part(0, B, 1, scale)
		Costumes.set_palette_for_part(0, C, 0, collar)
		Costumes.set_palette_for_part(0, D, 0, claw)
		Costumes.set_palette_for_part(0, D, 1, scale)
		Costumes.set_palette_for_part(0, F, 0, scale)
		Costumes.set_palette_for_part(0, F, 1, tail)
		Costumes.set_palette_for_part(0, 10, 0, scale)
		Costumes.set_palette_for_part(0, 10, 1, tail)
		Costumes.set_palette_for_part(0, 12, 0, scale)
		Costumes.set_palette_for_part(0, 13, 0, scale)
		Costumes.set_palette_for_part(0, 15, 0, claw)
		Costumes.set_palette_for_part(0, 17, 0, scale)
		Costumes.set_palette_for_part(0, 18, 0, scale)
		Costumes.set_palette_for_part(0, 1A, 0, claw)

        Costumes.set_stock_icon_palette_for_costume(0, Bowser/cos_6_stock.bin)
    }

}