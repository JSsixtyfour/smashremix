scope wolf_costumes {
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
    Costumes.define_part(2, 2, Costumes.part_type.PALETTE)            // part 0x2_0 - torso - front
    Costumes.add_part_image(2, 1, Costumes.part_type.PRIM_COLOR)      // part 0x2_1 - torso - back/sides
    Costumes.define_part(4, 1, Costumes.part_type.PRIM_COLOR)         // part 0x4_0 - left upper arm
    Costumes.define_part(8, 2, Costumes.part_type.TEXTURE_ARRAY)      // part 0x8_0 - head - eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.TEXTURE_ARRAY)   // part 0x8_1 - head - mouth
    Costumes.define_part(A, 1, Costumes.part_type.PRIM_COLOR)         // part 0xA_0 - right upper arm
    Costumes.define_part(F, 1, Costumes.part_type.PRIM_COLOR)         // part 0xF_0 - left upper leg
    Costumes.define_part(14, 1, Costumes.part_type.PRIM_COLOR)        // part 0x14_0 - right upper leg

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.WOLF)

    // Costume 0x6
    scope costume_0x6 {
        palette_1:; insert "Wolf/cos_6_1.bin"
        palette_2:; insert "Wolf/cos_6_2.bin"
        constant pant_color(0x2d262000)
        constant torso_color(0xffe98fFF)

        Costumes.set_palette_for_part(0, 1, 0, palette_1)
        Costumes.set_prim_color_for_part(0, 1, 1, pant_color)
        Costumes.set_palette_for_part(0, 2, 0, palette_2)
        Costumes.set_prim_color_for_part(0, 2, 1, torso_color)
        Costumes.set_prim_color_for_part(0, 4, 0, torso_color)
        Costumes.set_prim_color_for_part(0, A, 0, torso_color)
        Costumes.set_prim_color_for_part(0, F, 0, pant_color)
        Costumes.set_prim_color_for_part(0, 14, 0, pant_color)

        Costumes.set_stock_icon_palette_for_costume(0, Wolf/cos_6_stock.bin)
    }
}
