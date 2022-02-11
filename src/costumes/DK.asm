scope dk_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(3)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x19)

    // @ Description
    // Number of original costumes
    constant NUM_COSTUMES(5)

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
    db 0x0                         // 0x3 - costumes to skip
    fill 4 + (NUM_PARTS - 1) * 8

    Costumes.define_part(1, 2, Costumes.part_type.PALETTE)                                 // part 0x1_0 - pelvis - rear
    Costumes.add_part_image(1, 1, Costumes.part_type.PALETTE)                              // part 0x1_1 - pelvis - front
    Costumes.define_part(2, 2, Costumes.part_type.PALETTE)                                 // part 0x2_0 - torso - back
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                              // part 0x2_1 - torso - front
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)                                 // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.PALETTE)                                 // part 0x5_0 - left lower arm
    Costumes.define_part(6, 3, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR) // part 0x6_0 - left hand - inside/fingers
    Costumes.add_part_image(6, 1, Costumes.part_type.PALETTE)                              // part 0x6_1 - left hand - back
    Costumes.add_part_image(6, 2, Costumes.part_type.PRIM_COLOR)                           // part 0x6_2 - left hand - palm
    Costumes.define_part(8, 5, Costumes.part_type.PALETTE)                                 // part 0x8_0 - head - hair
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)                              // part 0x8_1 - head - widow's peak
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE)                              // part 0x8_2 - head - mouth
    Costumes.add_part_image(8, 3, Costumes.part_type.PRIM_COLOR)                           // part 0x8_3 - head - cheeks
    Costumes.add_part_image(8, 4, Costumes.part_type.PALETTE)                              // part 0x8_4 - head - sideburns
    Costumes.define_part(A, 1, Costumes.part_type.PALETTE)                                 // part 0xA_0 - right upper arm
    Costumes.define_part(B, 1, Costumes.part_type.PALETTE)                                 // part 0xB_0 - right lower arm
    Costumes.define_part(C, 3, Costumes.part_type.PALETTE | Costumes.part_type.PRIM_COLOR) // part 0xC_0 - right hand - inside/fingers
    Costumes.add_part_image(C, 1, Costumes.part_type.PALETTE)                              // part 0xC_1 - right hand - back
    Costumes.add_part_image(C, 2, Costumes.part_type.PRIM_COLOR)                           // part 0xC_2 - right hand - palm
    Costumes.define_part(10, 1, Costumes.part_type.PALETTE)                                // part 0x10_0 - left upper leg
    Costumes.define_part(11, 1, Costumes.part_type.PALETTE)                                // part 0x11_0 - left lower leg
    Costumes.define_part(13, 2, Costumes.part_type.PALETTE)                                // part 0x13_0 - left foot - heel
    Costumes.add_part_image(13, 1, Costumes.part_type.PALETTE)                             // part 0x13_1 - left foot - toes
    Costumes.define_part(15, 1, Costumes.part_type.PALETTE)                                // part 0x15_0 - right upper leg
    Costumes.define_part(16, 1, Costumes.part_type.PALETTE)                                // part 0x16_0 - right lower leg
    Costumes.define_part(18, 2, Costumes.part_type.PALETTE)                                // part 0x18_0 - right foot - heel
    Costumes.add_part_image(18, 1, Costumes.part_type.PALETTE)                             // part 0x18_1 - right foot - toes

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.DK)
    Costumes.register_extra_costumes_for_char(Character.id.GDONKEY)
    Costumes.register_extra_costumes_for_char(Character.id.JDK)

    // Costume 0x5
    scope costume_5 {
        palette_1:; insert "DK/cos_5_1.bin"
        palette_2:; insert "DK/cos_5_2.bin"
        Costumes.set_palette_for_part(0, 1, 0, palette_1)
        Costumes.set_palette_for_part(0, 1, 1, palette_1)
        Costumes.set_palette_for_part(0, 2, 0, palette_1)
        Costumes.set_palette_for_part(0, 2, 1, palette_1)
        Costumes.set_palette_for_part(0, 4, 0, palette_1)
        Costumes.set_palette_for_part(0, 5, 0, palette_1)
        Costumes.set_palette_for_part(0, 6, 0, palette_2)
        Costumes.set_prim_color_for_part(0, 6, 0, 0xFFA691FF)
        Costumes.set_palette_for_part(0, 6, 1, palette_2)
        Costumes.set_prim_color_for_part(0, 6, 2, 0xFFA691FF)
        Costumes.set_palette_for_part(0, 8, 0, palette_1)
        Costumes.set_palette_for_part(0, 8, 1, palette_1)
        Costumes.set_palette_for_part(0, 8, 2, palette_2)
        Costumes.set_prim_color_for_part(0, 8, 3, 0xFFA691FF)
        Costumes.set_palette_for_part(0, 8, 4, palette_1)
        Costumes.set_palette_for_part(0, A, 0, palette_1)
        Costumes.set_palette_for_part(0, B, 0, palette_1)
        Costumes.set_palette_for_part(0, C, 0, palette_2)
        Costumes.set_prim_color_for_part(0, C, 0, 0xFFA691FF)
        Costumes.set_palette_for_part(0, C, 1, palette_2)
        Costumes.set_prim_color_for_part(0, C, 2, 0xFFA691FF)
        Costumes.set_palette_for_part(0, 10, 0, palette_1)
        Costumes.set_palette_for_part(0, 11, 0, palette_1)
        Costumes.set_palette_for_part(0, 13, 0, palette_2)
        Costumes.set_palette_for_part(0, 13, 1, palette_2)
        Costumes.set_palette_for_part(0, 15, 0, palette_1)
        Costumes.set_palette_for_part(0, 16, 0, palette_1)
        Costumes.set_palette_for_part(0, 18, 0, palette_2)
        Costumes.set_palette_for_part(0, 18, 1, palette_2)

        Costumes.set_stock_icon_palette_for_costume(0, DK/cos_5_stock_icon.bin)
    }
    
    // Costume 0x6
    scope costume_6 {
        palette_1:; insert "DK/cos_6.bin"
        palette_2:; insert "DK/cos_6_2.bin"
        Costumes.set_palette_for_part(1, 1, 0, palette_1)
        Costumes.set_palette_for_part(1, 1, 1, palette_1)
        Costumes.set_palette_for_part(1, 2, 0, palette_1)
        Costumes.set_palette_for_part(1, 2, 1, palette_1)
        Costumes.set_palette_for_part(1, 4, 0, palette_1)
        Costumes.set_palette_for_part(1, 5, 0, palette_1)
        Costumes.set_palette_for_part(1, 6, 0, palette_2)
        Costumes.set_prim_color_for_part(1, 6, 0, 0xF8D898FF)
        Costumes.set_palette_for_part(1, 6, 1, palette_2)
        Costumes.set_prim_color_for_part(1, 6, 2, 0xF8D898FF)
        Costumes.set_palette_for_part(1, 8, 0, palette_1)
        Costumes.set_palette_for_part(1, 8, 1, palette_1)
        Costumes.set_palette_for_part(1, 8, 2, palette_2)
        Costumes.set_prim_color_for_part(1, 8, 3, 0xF8D898FF)
        Costumes.set_palette_for_part(1, 8, 4, palette_1)
        Costumes.set_palette_for_part(1, A, 0, palette_1)
        Costumes.set_palette_for_part(1, B, 0, palette_1)
        Costumes.set_palette_for_part(1, C, 0, palette_2)
        Costumes.set_prim_color_for_part(1, C, 0, 0xF8D898FF)
        Costumes.set_palette_for_part(1, C, 1, palette_2)
        Costumes.set_prim_color_for_part(1, C, 2, 0xF8D898FF)
        Costumes.set_palette_for_part(1, 10, 0, palette_1)
        Costumes.set_palette_for_part(1, 11, 0, palette_1)
        Costumes.set_palette_for_part(1, 13, 0, palette_2)
        Costumes.set_palette_for_part(1, 13, 1, palette_2)
        Costumes.set_palette_for_part(1, 15, 0, palette_1)
        Costumes.set_palette_for_part(1, 16, 0, palette_1)
        Costumes.set_palette_for_part(1, 18, 0, palette_2)
        Costumes.set_palette_for_part(1, 18, 1, palette_2)

        Costumes.set_stock_icon_palette_for_costume(1, DK/cos_6_stock_icon.bin)
    }
 
    // Costume 0x7
    scope costume_7 {
      palette_1:; insert "DK/cos_7.bin"
      palette_2:; insert "DK/cos_7_2.bin"
      Costumes.set_palette_for_part(2, 1, 0, palette_1)
      Costumes.set_palette_for_part(2, 1, 1, palette_1)
      Costumes.set_palette_for_part(2, 2, 0, palette_1)
      Costumes.set_palette_for_part(2, 2, 1, palette_1)
      Costumes.set_palette_for_part(2, 4, 0, palette_1)
      Costumes.set_palette_for_part(2, 5, 0, palette_1)
      Costumes.set_palette_for_part(2, 6, 0, palette_2)
      Costumes.set_prim_color_for_part(2, 6, 0, 0xF7A56BFF)
      Costumes.set_palette_for_part(2, 6, 1, palette_2)
      Costumes.set_prim_color_for_part(2, 6, 2, 0xF7A56BFF)
      Costumes.set_palette_for_part(2, 8, 0, palette_1)
      Costumes.set_palette_for_part(2, 8, 1, palette_1)
      Costumes.set_palette_for_part(2, 8, 2, palette_2)
      Costumes.set_prim_color_for_part(2, 8, 3, 0xF7A56BFF)
      Costumes.set_palette_for_part(2, 8, 4, palette_1)
      Costumes.set_palette_for_part(2, A, 0, palette_1)
      Costumes.set_palette_for_part(2, B, 0, palette_1)
      Costumes.set_palette_for_part(2, C, 0, palette_2)
      Costumes.set_prim_color_for_part(2, C, 0, 0xF7A56BFF)
      Costumes.set_palette_for_part(2, C, 1, palette_2)
      Costumes.set_prim_color_for_part(2, C, 2, 0xF7A56BFF)
      Costumes.set_palette_for_part(2, 10, 0, palette_1)
      Costumes.set_palette_for_part(2, 11, 0, palette_1)
      Costumes.set_palette_for_part(2, 13, 0, palette_2)
      Costumes.set_palette_for_part(2, 13, 1, palette_2)
      Costumes.set_palette_for_part(2, 15, 0, palette_1)
      Costumes.set_palette_for_part(2, 16, 0, palette_1)
      Costumes.set_palette_for_part(2, 18, 0, palette_2)
      Costumes.set_palette_for_part(2, 18, 1, palette_2)
  
      Costumes.set_stock_icon_palette_for_costume(2, DK/cos_7_stock_icon.bin)
    }
}
