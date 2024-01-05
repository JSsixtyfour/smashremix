scope polygon_younglink_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1D)

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

    Costumes.define_part(2, 1, Costumes.part_type.PALETTE)     // part 0x2_0 - torso
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)     // part 0x4_0 - left upper arm
    Costumes.define_part(7, 1, Costumes.part_type.PALETTE)     // part 0x7_0 - sword
    Costumes.define_part(9, 1, Costumes.part_type.PALETTE)     // part 0x9_0 - right upper arm
    Costumes.define_part(F, 1, Costumes.part_type.PALETTE)     // part 0xF_0 - shield
    Costumes.define_part(13, 1, Costumes.part_type.PALETTE)    // part 0x13_0 - head
    Costumes.define_part(17, 1, Costumes.part_type.PALETTE)    // part 0x17_0 - left lower leg
    Costumes.define_part(19, 1, Costumes.part_type.PALETTE)    // part 0x19_0 - left foot
    Costumes.define_part(1C, 1, Costumes.part_type.PALETTE)    // part 0x1C_0 - right lower leg
    Costumes.define_part(1E, 1, Costumes.part_type.PALETTE)    // part 0x1E_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.NYLINK)

    // Costume 0x6
    // Yellow Team
    scope costume_6 {
        palette:; insert "Polygon/yellow.bin"

        Costumes.set_palette_for_part(0, 2, 0, palette)
        Costumes.set_palette_for_part(0, 4, 0, palette)
        Costumes.set_palette_for_part(0, 7, 0, palette)
        Costumes.set_palette_for_part(0, 9, 0, palette)
        Costumes.set_palette_for_part(0, F, 0, palette)
        Costumes.set_palette_for_part(0, 13,0, palette)
        Costumes.set_palette_for_part(0, 17,0, palette)
        Costumes.set_palette_for_part(0, 19,0, palette)
        Costumes.set_palette_for_part(0, 1C,0, palette)
        Costumes.set_palette_for_part(0, 1E,0, palette)

        Costumes.set_stock_icon_palette_for_costume(0, Polygon/yellow_stock_icon.bin)
    }
}
