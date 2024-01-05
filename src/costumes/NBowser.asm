scope polygon_bowser_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1C)

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
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(1, 1, Costumes.part_type.PALETTE)     // part 0x1_0 - hindquarters
    Costumes.define_part(2, 1, Costumes.part_type.PALETTE)     // part 0x2_0 - neck
    Costumes.define_part(3, 1, Costumes.part_type.PALETTE)     // part 0x3_0 - head
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)     // part 0x4_0 - jaw
    Costumes.define_part(7, 1, Costumes.part_type.PALETTE)     // part 0x7_0 - left bicep
    Costumes.define_part(8, 1, Costumes.part_type.PALETTE)     // part 0x8_0 - left forearm
    Costumes.define_part(9, 1, Costumes.part_type.PALETTE)     // part 0x9_0 - left hand
    Costumes.define_part(B, 1, Costumes.part_type.PALETTE)     // part 0xB_0 - right bicep
    Costumes.define_part(C, 1, Costumes.part_type.PALETTE)     // part 0xC_0 - right forearm
    Costumes.define_part(D, 1, Costumes.part_type.PALETTE)     // part 0xD_0 - right hand
    Costumes.define_part(F, 1, Costumes.part_type.PALETTE)     // part 0xF_0 - tail anterior
    Costumes.define_part(10, 1, Costumes.part_type.PALETTE)    // part 0x10_0 - tail posterior
    Costumes.define_part(12, 1, Costumes.part_type.PALETTE)    // part 0x12_0 - left thigh
    Costumes.define_part(13, 1, Costumes.part_type.PALETTE)    // part 0x13_0 - left calf
    Costumes.define_part(15, 1, Costumes.part_type.PALETTE)    // part 0x15_0 - left foot
    Costumes.define_part(17, 1, Costumes.part_type.PALETTE)    // part 0x17_0 - right thigh
    Costumes.define_part(18, 1, Costumes.part_type.PALETTE)    // part 0x18_0 - right calf
    Costumes.define_part(1A, 1, Costumes.part_type.PALETTE)    // part 0x1A_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.NBOWSER)

    // Costume 0x6
    // Yellow Team
    scope costume_6 {
        palette:; insert "Polygon/yellow.bin"

        Costumes.set_palette_for_part(0, 1, 0, palette)
        Costumes.set_palette_for_part(0, 2, 0, palette)
        Costumes.set_palette_for_part(0, 3, 0, palette)
        Costumes.set_palette_for_part(0, 4, 0, palette)
        Costumes.set_palette_for_part(0, 7, 0, palette)
        Costumes.set_palette_for_part(0, 8, 0, palette)
        Costumes.set_palette_for_part(0, 9, 0, palette)
        Costumes.set_palette_for_part(0, B, 0, palette)
        Costumes.set_palette_for_part(0, C, 0, palette)
        Costumes.set_palette_for_part(0, D, 0, palette)
        Costumes.set_palette_for_part(0, F, 0, palette)
        Costumes.set_palette_for_part(0, 10, 0, palette)
        Costumes.set_palette_for_part(0, 12, 0, palette)
        Costumes.set_palette_for_part(0, 13, 0, palette)
        Costumes.set_palette_for_part(0, 15, 0, palette)
        Costumes.set_palette_for_part(0, 17, 0, palette)
        Costumes.set_palette_for_part(0, 18, 0, palette)
        Costumes.set_palette_for_part(0, 1A, 0, palette)

        Costumes.set_stock_icon_palette_for_costume(0, Polygon/yellow_stock_icon.bin)
    }
}
