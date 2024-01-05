scope slippy_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x18)

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

    Costumes.define_part(1, 2, Costumes.part_type.PALETTE)            // part 0x1_0 - pelvis - front
    Costumes.add_part_image(1, 1, Costumes.part_type.PRIM_COLOR)      // part 0x1_1 - pelvis - back
    Costumes.define_part(2, 3, Costumes.part_type.PALETTE)            // part 0x2_0 - torso - rocket
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)         // part 0x2_1 - torso - front
    Costumes.add_part_image(2, 2, Costumes.part_type.PRIM_COLOR)      // part 0x2_2 - torso - back
    Costumes.define_part(4, 1, Costumes.part_type.PRIM_COLOR)         // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.PRIM_COLOR)         // part 0x5_0 - left lower arm
    Costumes.define_part(6, 1, Costumes.part_type.PRIM_COLOR)         // part 0x6_0 - left hand
    Costumes.define_part(8, 5, Costumes.part_type.TEXTURE_ARRAY)      // part 0x8_0 - head - eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)         // part 0x8_1 - head - hat texture
    Costumes.add_part_image(8, 2, Costumes.part_type.PRIM_COLOR)      // part 0x8_2 - head - skin
    Costumes.add_part_image(8, 3, Costumes.part_type.PRIM_COLOR)      // part 0x8_3 - head - hat
    Costumes.add_part_image(8, 4, Costumes.part_type.PRIM_COLOR)      // part 0x8_4 - head - under chin
    Costumes.define_part(A, 1, Costumes.part_type.PRIM_COLOR)         // part 0xA_0 - right upper arm
    Costumes.define_part(B, 1, Costumes.part_type.PRIM_COLOR)         // part 0xB_0 - right lower arm
    Costumes.define_part(C, 1, Costumes.part_type.PRIM_COLOR)         // part 0xC_0 - right hand
    Costumes.define_part(F, 1, Costumes.part_type.PRIM_COLOR)         // part 0xF_0 - left upper leg
    Costumes.define_part(10, 1, Costumes.part_type.PRIM_COLOR)        // part 0x10_0 - left lower leg
    Costumes.define_part(12, 1, Costumes.part_type.PRIM_COLOR)        // part 0x12_0 - left foot
    Costumes.define_part(14, 1, Costumes.part_type.PRIM_COLOR)        // part 0x14_0 - right upper leg
    Costumes.define_part(15, 1, Costumes.part_type.PRIM_COLOR)        // part 0x15_0 - right lower leg
    Costumes.define_part(17, 1, Costumes.part_type.PRIM_COLOR)        // part 0x17_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.SLIPPY)

    // Costume 0x6
    scope costume_0x6 {
        palette_1:; insert "Slippy/cos_6_1.bin"
        palette_2:; insert "Slippy/cos_6_2.bin"
        palette_3:; insert "Slippy/cos_6_3.bin"
        palette_4:; insert "Slippy/cos_6_4.bin"
        constant pant_color(0xF3D54900)
        constant torso_color(0x74481300)
        constant skin_color(0x01BA45FF)
        constant boot_color(0x684011FF)
        constant hat_color(0xF3D54900)

        Costumes.set_palette_for_part(0, 1, 0, palette_1)
        Costumes.set_prim_color_for_part(0, 1, 1, pant_color)
        Costumes.set_palette_for_part(0, 2, 0, palette_2)
        Costumes.set_palette_for_part(0, 2, 1, palette_3)
        Costumes.set_prim_color_for_part(0, 2, 2, torso_color)
        Costumes.set_prim_color_for_part(0, 4, 0, torso_color)
        Costumes.set_prim_color_for_part(0, 5, 0, torso_color)
        Costumes.set_prim_color_for_part(0, 6, 0, skin_color)
        Costumes.set_palette_for_part(0, 8, 1, palette_4)
        Costumes.set_prim_color_for_part(0, 8, 2, skin_color)
        Costumes.set_prim_color_for_part(0, 8, 3, hat_color)
        Costumes.set_prim_color_for_part(0, 8, 4, skin_color)
        Costumes.set_prim_color_for_part(0, A, 0, torso_color)
        Costumes.set_prim_color_for_part(0, B, 0, torso_color)
        Costumes.set_prim_color_for_part(0, C, 0, skin_color)
        Costumes.set_prim_color_for_part(0, F, 0, pant_color)
        Costumes.set_prim_color_for_part(0, 10, 0, boot_color)
        Costumes.set_prim_color_for_part(0, 12, 0, boot_color)
        Costumes.set_prim_color_for_part(0, 14, 0, pant_color)
        Costumes.set_prim_color_for_part(0, 15, 0, boot_color)
        Costumes.set_prim_color_for_part(0, 17, 0, boot_color)

        Costumes.set_stock_icon_palette_for_costume(0, Slippy/cos_6_stock_icon.bin)
    }
}
