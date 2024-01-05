scope ganondorf_costumes {
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

    Costumes.define_part(1, 1, Costumes.part_type.PALETTE)                                    // part 0x1_0 - pelvis
    Costumes.define_part(2, 5, Costumes.part_type.PALETTE)                                    // part 0x2_0 - torso - front
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                                 // part 0x2_1 - torso - back
    Costumes.add_part_image(2, 2, Costumes.part_type.PALETTE)                                 // part 0x2_2 - torso - middle inside colloar
    Costumes.add_part_image(2, 3, Costumes.part_type.PALETTE)                                 // part 0x2_3 - torso - left inside collar
    Costumes.add_part_image(2, 4, Costumes.part_type.PALETTE)                                 // part 0x2_4 - torso - right inside collar
    Costumes.define_part(4, 1, Costumes.part_type.PALETTE)                                    // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.PALETTE)                                    // part 0x5_0 - left lower arm
    Costumes.define_part(6, 3, Costumes.part_type.PALETTE)                                    // part 0x6_0 - left hand - thumb
    Costumes.add_part_image(6, 1, Costumes.part_type.PALETTE)                                 // part 0x6_1 - left hand - fingers
    Costumes.add_part_image(6, 2, Costumes.part_type.PALETTE)                                 // part 0x6_2 - left hand - glove
    Costumes.define_part(7, 1, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY) // part 0x7_0 - neck?
    Costumes.define_part(8, 8, Costumes.part_type.PALETTE | Costumes.part_type.TEXTURE_ARRAY) // part 0x8_0 - head - face
    Costumes.add_part_image(8, 1, Costumes.part_type.PALETTE)                                 // part 0x8_1 - head - ears
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE)                                 // part 0x8_2 - head - hair above jewel
    Costumes.add_part_image(8, 3, Costumes.part_type.PALETTE)                                 // part 0x8_3 - head - nose
    Costumes.add_part_image(8, 4, Costumes.part_type.PALETTE)                                 // part 0x8_4 - head - ?
    Costumes.add_part_image(8, 5, Costumes.part_type.PALETTE)                                 // part 0x8_5 - head - hair spikes
    Costumes.add_part_image(8, 6, Costumes.part_type.PALETTE)                                 // part 0x8_6 - head - hair side
    Costumes.add_part_image(8, 7, Costumes.part_type.PALETTE)                                 // part 0x8_7 - head - jewel
    Costumes.define_part(A, 1, Costumes.part_type.PALETTE)                                    // part 0xA_0 - right upper arm
    Costumes.define_part(B, 1, Costumes.part_type.PALETTE)                                    // part 0xB_0 - right lower arm
    Costumes.define_part(C, 3, Costumes.part_type.PALETTE)                                    // part 0xC_0 - right hand - fingers
    Costumes.add_part_image(C, 1, Costumes.part_type.PALETTE)                                 // part 0xC_1 - right hand - thumb
    Costumes.add_part_image(C, 2, Costumes.part_type.PALETTE)                                 // part 0xC_2 - right hand - glove
    Costumes.define_part(10, 1, Costumes.part_type.PALETTE)                                   // part 0x10_0 - left upper leg
    Costumes.define_part(11, 2, Costumes.part_type.PALETTE)                                   // part 0x11_0 - left lower leg - shin
    Costumes.add_part_image(11, 1, Costumes.part_type.PALETTE)                                // part 0x11_1 - left lower leg - knee
    Costumes.define_part(13, 1, Costumes.part_type.PALETTE)                                   // part 0x13_0 - left foot
    Costumes.define_part(15, 1, Costumes.part_type.PALETTE)                                   // part 0x15_0 - right upper leg
    Costumes.define_part(16, 2, Costumes.part_type.PALETTE)                                   // part 0x16_0 - right lower leg - shin
    Costumes.add_part_image(16, 1, Costumes.part_type.PALETTE)                                // part 0x16_1 - right lower leg - knee
    Costumes.define_part(18, 1, Costumes.part_type.PALETTE)                                   // part 0x18_0 - right foot

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.GND)

    // Costume 0x6
    scope costume_0x6 {
        palette_1:; insert "Ganondorf/cos_6_1.bin"
        palette_2:; insert "Ganondorf/cos_6_2.bin"
        palette_3:; insert "Ganondorf/cos_6_3.bin"
        palette_4:; insert "Ganondorf/cos_6_4.bin"
        palette_5:; insert "Ganondorf/cos_6_5.bin"
        palette_6:; insert "Ganondorf/cos_6_6.bin"
        palette_7:; insert "Ganondorf/cos_6_7.bin"
        palette_8:; insert "Ganondorf/cos_6_8.bin"
        palette_9:; insert "Ganondorf/cos_6_9.bin"
        palette_A:; insert "Ganondorf/cos_6_A.bin"
        palette_B:; insert "Ganondorf/cos_6_B.bin"
        palette_C:; insert "Ganondorf/cos_6_C.bin"
        palette_D:; insert "Ganondorf/cos_6_D.bin"
        palette_E:; insert "Ganondorf/cos_6_E.bin"
        palette_F:; insert "Ganondorf/cos_6_F.bin"
        palette_10:;insert "Ganondorf/cos_6_10.bin"
        palette_11:;insert "Ganondorf/cos_6_11.bin"
        palette_12:;insert "Ganondorf/cos_6_12.bin"

        Costumes.set_palette_for_part(0, 1, 0, palette_1)
        Costumes.set_palette_for_part(0, 2, 0, palette_2)
        Costumes.set_palette_for_part(0, 2, 1, palette_3)
        Costumes.set_palette_for_part(0, 2, 2, palette_4)
        Costumes.set_palette_for_part(0, 2, 3, palette_1)
        Costumes.set_palette_for_part(0, 2, 4, palette_5)
        Costumes.set_palette_for_part(0, 4, 0, palette_6)
        Costumes.set_palette_for_part(0, 5, 0, palette_7)
        Costumes.set_palette_for_part(0, 6, 0, palette_8)
        Costumes.set_palette_for_part(0, 6, 1, palette_9)
        Costumes.set_palette_for_part(0, 6, 2, palette_6)
        Costumes.set_palette_for_part(0, 7, 0, palette_A)
        Costumes.set_palette_for_part(0, 8, 0, palette_A)
        Costumes.set_palette_for_part(0, 8, 1, palette_B)
        Costumes.set_palette_for_part(0, 8, 2, palette_C)
        Costumes.set_palette_for_part(0, 8, 3, palette_D)
        Costumes.set_palette_for_part(0, 8, 4, palette_E)
        Costumes.set_palette_for_part(0, 8, 5, palette_F)
        Costumes.set_palette_for_part(0, 8, 6, palette_10)
        Costumes.set_palette_for_part(0, 8, 7, palette_11)
        Costumes.set_palette_for_part(0, A, 0, palette_6)
        Costumes.set_palette_for_part(0, B, 0, palette_7)
        Costumes.set_palette_for_part(0, C, 0, palette_8)
        Costumes.set_palette_for_part(0, C, 1, palette_9)
        Costumes.set_palette_for_part(0, C, 2, palette_6)
        Costumes.set_palette_for_part(0, 10, 0, palette_1)
        Costumes.set_palette_for_part(0, 11, 0, palette_7)
        Costumes.set_palette_for_part(0, 11, 1, palette_2)
        Costumes.set_palette_for_part(0, 13, 0, palette_12)
        Costumes.set_palette_for_part(0, 15, 0, palette_1)
        Costumes.set_palette_for_part(0, 16, 0, palette_7)
        Costumes.set_palette_for_part(0, 16, 1, palette_2)
        Costumes.set_palette_for_part(0, 18, 0, palette_12)

        Costumes.set_stock_icon_palette_for_costume(0, Ganondorf/cos_6_stock_icon.bin)
    }
}
