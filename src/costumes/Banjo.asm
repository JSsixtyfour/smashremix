scope banjo_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x21)

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

    Costumes.define_part(1, 3, Costumes.part_type.PALETTE)                             // - shorts front
    Costumes.add_part_image(1, 1, Costumes.part_type.PALETTE)                          // - shorts back
    Costumes.add_part_image(1, 2, Costumes.part_type.PRIM_COLOR)                       // - shorts prim
    Costumes.define_part(2, 3, Costumes.part_type.PALETTE)                             // - chest front
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                          // - chest fur
    Costumes.add_part_image(2, 2, Costumes.part_type.PRIM_COLOR)                       // - chest straps
    Costumes.define_special_parts_for_part(2, 2)                                       // -
    Costumes.add_special_part(2, 1, 2, Costumes.part_type.PALETTE)                     // - (special 1) Chest - No Straps
    Costumes.add_special_part_image(2, 1, 1, Costumes.part_type.PALETTE)               // - (special 1) Chest - No Straps
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)                             // - L Arm
    Costumes.define_part(5, 1, Costumes.part_type.PALETTE)                             // - L Elbow
    Costumes.define_part(6, 1, Costumes.part_type.PRIM_COLOR)                          // - L Hand
    Costumes.define_special_parts_for_part(6, 2)                                       // - (special) Left hand
    Costumes.add_special_part(6, 1, 1, Costumes.part_type.PRIM_COLOR)                  // - L Hand Open
    Costumes.define_part(8, 4, Costumes.part_type.PALETTE)                             // - Eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)                          // - Head Fur
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR) // - Ears
    Costumes.add_part_image(8, 3, Costumes.part_type.PRIM_COLOR)                       // - Mouth Color
    Costumes.define_special_parts_for_part(8, 4)                                       // - (special) Expressions
    Costumes.add_special_part(8, 1, 3, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY)                     // - (special 1) Head Hurt
    Costumes.add_special_part_image(8, 1, 1, Costumes.part_type.PALETTE)               // - (special 1) Head Hurt
    Costumes.add_special_part_image(8, 1, 2, Costumes.part_type.PRIM_COLOR)            // - (special 1) Head Hurt
    Costumes.add_special_part(8, 2, 3, Costumes.part_type.PALETTE)                     // - (special 2) Head Mad
    Costumes.add_special_part_image(8, 2, 1, Costumes.part_type.PALETTE)               // - (special 2) Head Mad
    Costumes.add_special_part_image(8, 2, 2, Costumes.part_type.PRIM_COLOR)            // - (special 2) Head Mad
    Costumes.add_special_part(8, 3, 3, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY)                     // - (special 3) Head CSS
    Costumes.add_special_part_image(8, 3, 1, Costumes.part_type.PALETTE)               // - (special 3) Head CSS
    Costumes.add_special_part_image(8, 3, 2, Costumes.part_type.PRIM_COLOR)            // - (special 3) Head CSS
    Costumes.define_part(A, 1, Costumes.part_type.PALETTE)                             // - R Arm
    Costumes.define_part(B, 1, Costumes.part_type.PALETTE)                             // - R Elbow
    Costumes.define_part(C, 1, Costumes.part_type.PRIM_COLOR)                          // - R Hand
    Costumes.define_special_parts_for_part(C, 4)                                       // - (special) Right hand
    Costumes.add_special_part(C, 1, 1, Costumes.part_type.PRIM_COLOR)                  // - (special 1) R Hand Open
    Costumes.add_special_part(C, 2, 3, Costumes.part_type.PALETTE)                     // - (special 2) Kazooie Feather
    Costumes.add_special_part_image(C, 2, 1, Costumes.part_type.PRIM_COLOR)            // - (special 2) R Hand Breegull Bash
    Costumes.add_special_part_image(C, 2, 2, Costumes.part_type.PRIM_COLOR)            // - (special 2) Kazooie Legs
    Costumes.define_part(E, 2, Costumes.part_type.PALETTE)                             // - Backpack
    Costumes.add_part_image(E, 1, Costumes.part_type.PRIM_COLOR)                       // - Backpack Prim
    Costumes.define_special_parts_for_part(E, 3)                                       // - (special) Backpack
    Costumes.add_special_part(E, 1, 2, Costumes.part_type.PALETTE)                     // - (special 1) Pack Open
    Costumes.add_special_part_image(E, 1, 1, Costumes.part_type.PRIM_COLOR)            // - (special 1) Pack Open prim
    Costumes.add_special_part(E, 2, 2, Costumes.part_type.PALETTE)                     // - (special 1) Disabled Skinning
    Costumes.add_special_part_image(E, 2, 1, Costumes.part_type.PRIM_COLOR)            // - (special 1) Disabled Skinning prim
    Costumes.define_part(F, 2, Costumes.part_type.PALETTE)                             // - Kazooie Chest
    Costumes.define_special_parts_for_part(F, 3)                                       // - (special) Kazooie Chest
    Costumes.add_special_part(F, 1, 2, Costumes.part_type.PALETTE)                     // - (special 1) Kazooie Rear
    Costumes.add_special_part_image(F, 1, 1, Costumes.part_type.PALETTE)               // - (special 1) Kazooie Rear
    Costumes.add_special_part(F, 2, 3, Costumes.part_type.PALETTE)                     // - (special 2) Kazooie added Tail
    Costumes.add_special_part_image(F, 2, 1, Costumes.part_type.PALETTE)               // - (special 2) Kazooie added Tail
    Costumes.add_special_part_image(F, 2, 2, Costumes.part_type.PALETTE)               // - (special 2) Kazooie added Tail
    Costumes.add_part_image(F, 1, Costumes.part_type.PALETTE)                          // - Kazooie Feathers
    Costumes.define_part(10, 1, Costumes.part_type.PALETTE)                            // - Kaz5ooie Neck
    Costumes.define_part(11, 5, Costumes.part_type.PALETTE)                            // - Kazooie Eyes
    Costumes.add_part_image(11, 1, Costumes.part_type.PALETTE)                         // - Kazooie Head Feathers
    Costumes.add_part_image(11, 2, Costumes.part_type.PALETTE)                         // - Kazooie Beak Texture
    Costumes.add_part_image(11, 3, Costumes.part_type.PRIM_COLOR)                      // - Kazooie Mouth Prim
    Costumes.add_part_image(11, 4, Costumes.part_type.PRIM_COLOR)                      // - Kazooie Beak Prim
    Costumes.define_special_parts_for_part(11, 6)                                      // - (special) kazooie expressions
    Costumes.add_special_part(11, 1, 5, Costumes.part_type.PALETTE)                    // - (special 1) Kazooie Shoot
    Costumes.add_special_part_image(11, 1, 1, Costumes.part_type.PALETTE)              // - (special 1) Kazooie Shoot
    Costumes.add_special_part_image(11, 1, 2, Costumes.part_type.PALETTE)              // - (special 1) Kazooie Shoot
    Costumes.add_special_part_image(11, 1, 3, Costumes.part_type.PRIM_COLOR)           // - (special 1) Kazooie Shoot
    Costumes.add_special_part_image(11, 1, 4, Costumes.part_type.PRIM_COLOR)           // - (special 1) Kazooie Shoot
    Costumes.add_special_part(11, 2, 1, Costumes.part_type.PALETTE)                    // - (special 2) Kazooies Tail
    Costumes.add_special_part(11, 3, 5, Costumes.part_type.PALETTE)                    // - (special 3) Kazooie Mad
    Costumes.add_special_part_image(11, 3, 1, Costumes.part_type.PALETTE)              // - (special 3) Kazooie Mad
    Costumes.add_special_part_image(11, 3, 2, Costumes.part_type.PALETTE)              // - (special 3) Kazooie Mad
    Costumes.add_special_part_image(11, 3, 3, Costumes.part_type.PRIM_COLOR)           // - (special 3) Kazooie Mad
    Costumes.add_special_part_image(11, 3, 4, Costumes.part_type.PRIM_COLOR)           // - (special 3) Kazooie Mad
    Costumes.add_special_part(11, 4, 5, Costumes.part_type.PALETTE)                    // - (special 4) Kazooie CSS
    Costumes.add_special_part_image(11, 4, 1, Costumes.part_type.PALETTE)              // - (special 4) Kazooie CSS
    Costumes.add_special_part_image(11, 4, 2, Costumes.part_type.PALETTE)              // - (special 4) Kazooie CSS
    Costumes.add_special_part_image(11, 4, 3, Costumes.part_type.PRIM_COLOR)           // - (special 4) Kazooie CSS
    Costumes.add_special_part_image(11, 4, 4, Costumes.part_type.PRIM_COLOR)           // - (special 4) Kazooie CSS
    Costumes.add_special_part(11, 5, 5, Costumes.part_type.PALETTE)                    // - (special 5) Kazooie Kazoo
    Costumes.add_special_part_image(11, 5, 1, Costumes.part_type.PALETTE)              // - (special 5) Kazooie Kazoo
    Costumes.add_special_part_image(11, 5, 2, Costumes.part_type.PALETTE)              // - (special 5) Kazooie Kazoo
    Costumes.add_special_part_image(11, 5, 3, Costumes.part_type.PRIM_COLOR)           // - (special 5) Kazooie Kazoo
    Costumes.add_special_part_image(11, 5, 4, Costumes.part_type.PRIM_COLOR)           // - (special 5) Kazooie Kazoo
    Costumes.define_part(12, 1, Costumes.part_type.PALETTE)                            // - Kazooie L Wing
    Costumes.define_part(13, 1, Costumes.part_type.PALETTE)                            // - Kazooie L Wing Tip
    Costumes.define_part(14, 1, Costumes.part_type.PALETTE)                            // - Kazooie R Wing
    Costumes.define_part(15, 1, Costumes.part_type.PALETTE)                            // - Kazooie R Wing Tip
    Costumes.define_part(17, 1, Costumes.part_type.PRIM_COLOR)                         // - L Pants Leg
    Costumes.define_part(18, 1, Costumes.part_type.PALETTE)                            // - L Knee
    Costumes.define_part(1A, 1, Costumes.part_type.PRIM_COLOR)                         // - L Foot prim
    Costumes.define_part(1C, 1, Costumes.part_type.PRIM_COLOR)                         // - L Pants Leg
    Costumes.define_part(1D, 1, Costumes.part_type.PALETTE)                            // - L Knee
    Costumes.define_part(1F, 1, Costumes.part_type.PRIM_COLOR)                         // - L Foot prim
    Costumes.define_part(20, 2, Costumes.part_type.PALETTE)                            // - (special 1) Pack Whack
    Costumes.add_part_image(20, 1, Costumes.part_type.PRIM_COLOR)                      // - (special 1) Pack Whack Prim

	 // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.BANJO)

    // Costume 0x7
	// Bling
    scope costume_0x7 {
        fur:; insert "Banjo/cos_7_1.bin"
        shorts:; insert "Banjo/cos_7_2.bin"
        pack:; insert "Banjo/cos_7_3.bin"
        feather:; insert "Banjo/cos_7_4.bin"
        kzstomach:; insert "Banjo/cos_7_5.bin"
        kzbeak:; insert "Banjo/cos_7_6.bin"
        constant color_shorts(0x35dc60FF)
        constant color_pack(0xff0051FF)
        constant color_mouth(0x862d2dFF)
        constant color_beak(0xfff038FF)
        constant color_skin(0xf0a078FF)

		Costumes.set_palette_for_part(0, 1, 0, shorts)
		Costumes.set_palette_for_part(0, 1, 1, shorts)
		Costumes.set_prim_color_for_part(0, 1, 2, color_shorts)
		Costumes.set_palette_for_part(0, 2, 0, fur)
		Costumes.set_palette_for_part(0, 2, 1, fur)
		Costumes.set_prim_color_for_part(0, 2, 2, color_pack)
        Costumes.set_palette_for_special_part(0, 2, 1, 0, fur)
        Costumes.set_palette_for_special_part(0, 2, 1, 1, fur)
		Costumes.set_palette_for_part(0, 4, 0, fur)
		Costumes.set_palette_for_part(0, 5, 0, fur)
		Costumes.set_prim_color_for_part(0, 6, 0, color_skin)
        Costumes.set_prim_color_for_special_part(0, 6, 1, 0, color_skin)
		Costumes.set_palette_for_part(0, 8, 0, fur)
		Costumes.set_palette_for_part(0, 8, 1, fur)
		Costumes.set_palette_for_part(0, 8, 2, fur)
		Costumes.set_prim_color_for_part(0, 8, 2, color_skin)
		Costumes.set_prim_color_for_part(0, 8, 3, color_mouth)
        Costumes.set_palette_for_special_part(0, 8, 1, 0, fur)
        Costumes.set_palette_for_special_part(0, 8, 1, 1, fur)
        Costumes.set_prim_color_for_special_part(0, 8, 1, 2, color_mouth)
        Costumes.set_palette_for_special_part(0, 8, 2, 0, fur)
        Costumes.set_palette_for_special_part(0, 8, 2, 1, fur)
        Costumes.set_prim_color_for_special_part(0, 8, 2, 2, color_skin)
        Costumes.set_palette_for_special_part(0, 8, 3, 0, fur)
        Costumes.set_palette_for_special_part(0, 8, 3, 1, fur)
        Costumes.set_prim_color_for_special_part(0, 8, 3, 2, color_mouth)
		Costumes.set_palette_for_part(0, A, 0, fur)
		Costumes.set_palette_for_part(0, B, 0, fur)
		Costumes.set_prim_color_for_part(0, C, 0, color_skin)
        Costumes.set_prim_color_for_special_part(0, C, 1, 0, color_skin)
        Costumes.set_palette_for_special_part(0, C, 2, 0, feather)
        Costumes.set_prim_color_for_special_part(0, C, 2, 1, color_skin)
        Costumes.set_prim_color_for_special_part(0, C, 2, 2, color_beak)
		Costumes.set_palette_for_part(0, E, 0, pack)
		Costumes.set_prim_color_for_part(0, E, 1, color_pack)
        Costumes.set_palette_for_special_part(0, E, 1, 0, pack)
        Costumes.set_prim_color_for_special_part(0, E, 1, 1, color_pack)
        Costumes.set_palette_for_special_part(0, E, 2, 0, pack)
        Costumes.set_prim_color_for_special_part(0, E, 2, 1, color_pack)
		Costumes.set_palette_for_part(0, F, 0, feather)
		Costumes.set_palette_for_part(0, F, 1, kzstomach)
        Costumes.set_palette_for_special_part(0, F, 1, 0, feather)
        Costumes.set_palette_for_special_part(0, F, 1, 1, kzstomach)
        Costumes.set_palette_for_special_part(0, F, 2, 0, feather)
        Costumes.set_palette_for_special_part(0, F, 2, 1, kzstomach)
        Costumes.set_palette_for_special_part(0, F, 2, 2, feather)
		Costumes.set_palette_for_part(0, 10, 0, feather)
		Costumes.set_palette_for_part(0, 11, 0, feather)
		Costumes.set_palette_for_part(0, 11, 1, feather)
		Costumes.set_palette_for_part(0, 11, 2, kzbeak)
		Costumes.set_prim_color_for_part(0, 11, 3, color_mouth)
		Costumes.set_prim_color_for_part(0, 11, 4, color_beak)
        Costumes.set_palette_for_special_part(0, 11, 1, 0, feather)
        Costumes.set_palette_for_special_part(0, 11, 1, 1, feather)
        Costumes.set_palette_for_special_part(0, 11, 1, 2, kzbeak)
        Costumes.set_prim_color_for_special_part(0, 11, 1, 3, color_mouth)
        Costumes.set_prim_color_for_special_part(0, 11, 1, 4, color_beak)
        Costumes.set_palette_for_special_part(0, 11, 2, 0, feather)
        Costumes.set_palette_for_special_part(0, 11, 3, 0, feather)
        Costumes.set_palette_for_special_part(0, 11, 3, 1, feather)
        Costumes.set_palette_for_special_part(0, 11, 3, 2, kzbeak)
        Costumes.set_prim_color_for_special_part(0, 11, 3, 3, color_mouth)
        Costumes.set_prim_color_for_special_part(0, 11, 3, 4, color_beak)
        Costumes.set_palette_for_special_part(0, 11, 4, 0, feather)
        Costumes.set_palette_for_special_part(0, 11, 4, 1, feather)
        Costumes.set_palette_for_special_part(0, 11, 4, 2, kzbeak)
        Costumes.set_prim_color_for_special_part(0, 11, 4, 3, color_mouth)
        Costumes.set_prim_color_for_special_part(0, 11, 4, 4, color_beak)
        Costumes.set_palette_for_special_part(0, 11, 5, 0, feather)
        Costumes.set_palette_for_special_part(0, 11, 5, 1, feather)
        Costumes.set_palette_for_special_part(0, 11, 5, 2, kzbeak)
        Costumes.set_prim_color_for_special_part(0, 11, 5, 3, color_mouth)
        Costumes.set_prim_color_for_special_part(0, 11, 5, 4, color_beak)
		Costumes.set_palette_for_part(0, 12, 0, feather)
		Costumes.set_palette_for_part(0, 13, 0, feather)
		Costumes.set_palette_for_part(0, 14, 0, feather)
		Costumes.set_palette_for_part(0, 15, 0, feather)
		Costumes.set_prim_color_for_part(0, 17, 0, color_shorts)
		Costumes.set_palette_for_part(0, 18, 0, fur)
		Costumes.set_prim_color_for_part(0, 1A, 0, color_skin)
		Costumes.set_prim_color_for_part(0, 1C, 0, color_shorts)
		Costumes.set_palette_for_part(0, 1D, 0, fur)
		Costumes.set_prim_color_for_part(0, 1F, 0, color_skin)
		Costumes.set_palette_for_part(0, 20, 0, pack)
		Costumes.set_prim_color_for_part(0, 20, 1, color_pack)

        Costumes.set_stock_icon_palette_for_costume(0, Banjo/cos_7_stock.bin)
    }

}