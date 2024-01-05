scope polygon_luigi_costumes {
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
    db NUM_EXTRA_COSTUMES       // 0x0 - number of extra costumes
    db 0x0                      // 0x1 - special part ID
    db 0x0                      // 0x2 - special part image index start
    db 0x0                      // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(2, 1, Costumes.part_type.PALETTE)    // part 0x2_0 - torso
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)    // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.PALETTE)    // part 0x5_0 - left lower arm
    Costumes.define_part(6, 1, Costumes.part_type.PALETTE)    // part 0x6_0 - left hand
    Costumes.define_part(8, 1, Costumes.part_type.PALETTE)    // part 0x8_0 - head
    Costumes.define_part(A, 1, Costumes.part_type.PALETTE)    // part 0xA_0 - right upper arm
    Costumes.define_part(B, 1, Costumes.part_type.PALETTE)    // part 0xB_0 - right lower arm
    Costumes.define_part(C, 1, Costumes.part_type.PALETTE)    // part 0xC_0 - right hand
    Costumes.define_part(F, 1, Costumes.part_type.PALETTE)    // part 0xF_0 - left upper leg
    Costumes.define_part(10, 1, Costumes.part_type.PALETTE)   // part 0x10_0 - left lower leg
    Costumes.define_part(12, 1, Costumes.part_type.PALETTE)   // part 0x12_0 - left foot
    Costumes.define_part(14, 1, Costumes.part_type.PALETTE)   // part 0x14_0 - right upper leg
    Costumes.define_part(15, 1, Costumes.part_type.PALETTE)   // part 0x15_0 - right lower leg
    Costumes.define_part(17, 1, Costumes.part_type.PALETTE)   // part 0x17_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.NLUIGI)

    // Costume 0x6
    // Yellow Team
    scope costume_0x6 {
        palette:; insert "Polygon/yellow.bin"

        Costumes.set_palette_for_part(0, 2, 0, palette)
        Costumes.set_palette_for_part(0, 4, 0, palette)
        Costumes.set_palette_for_part(0, 5, 0, palette)
        Costumes.set_palette_for_part(0, 6, 0, palette)
        Costumes.set_palette_for_part(0, 8, 0, palette)
        Costumes.set_palette_for_part(0, A, 0, palette)
        Costumes.set_palette_for_part(0, B, 0, palette)
        Costumes.set_palette_for_part(0, C, 0, palette)
        Costumes.set_palette_for_part(0, F, 0, palette)
        Costumes.set_palette_for_part(0, 10, 0, palette)
        Costumes.set_palette_for_part(0, 12, 0, palette)
        Costumes.set_palette_for_part(0, 14, 0, palette)
        Costumes.set_palette_for_part(0, 15, 0, palette)
        Costumes.set_palette_for_part(0, 17, 0, palette)

        Costumes.set_stock_icon_palette_for_costume(0, Polygon/yellow_stock_icon.bin)
    }

}
