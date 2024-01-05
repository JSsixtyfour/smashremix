scope polygon_jigglypuff_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x19)

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

    Costumes.define_part(2, 1, Costumes.part_type.PALETTE)    // part 0x2_0 - body
    Costumes.define_part(6, 1, Costumes.part_type.PALETTE)    // part 0x6_0 - left arm
    Costumes.define_part(7, 1, Costumes.part_type.PALETTE)    // part 0x7_0 - left hand
    Costumes.define_part(A, 1, Costumes.part_type.PALETTE)    // part 0xA_0 - left arm
    Costumes.define_part(B, 1, Costumes.part_type.PALETTE)    // part 0xB_0 - left hand
    Costumes.define_part(13, 1, Costumes.part_type.PALETTE)   // part 0x13_0 - left foot
    Costumes.define_part(18, 1, Costumes.part_type.PALETTE)   // part 0x18_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.NJIGGLY)

    // Costume 0x6
    // Yellow Team
    scope costume_6 {
        palette:; insert "Polygon/yellow.bin"

        Costumes.set_palette_for_part(0, 2, 0, palette)
        Costumes.set_palette_for_part(0, 6, 0, palette)
        Costumes.set_palette_for_part(0, 7, 0, palette)
        Costumes.set_palette_for_part(0, A, 0, palette)
        Costumes.set_palette_for_part(0, B, 0, palette)
        Costumes.set_palette_for_part(0, 13, 0, palette)
        Costumes.set_palette_for_part(0, 18, 0, palette)

        Costumes.set_stock_icon_palette_for_costume(0, Polygon/yellow_stock_icon.bin)
    }
}
