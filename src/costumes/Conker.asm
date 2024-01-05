scope conker_costumes {
    // @ Description
    // Number of additional costumes
    constant NUM_EXTRA_COSTUMES(1)

    // @ Description
    // Number of parts
    constant NUM_PARTS(0x1A)

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

    Costumes.define_part(1, 2, Costumes.part_type.PRIM_COLOR)                                        // part 0x1_0 - ?pelvis - front
    Costumes.add_part_image(1, 1, Costumes.part_type.PRIM_COLOR)                                     // part 0x1_1 - ?pelvis - back
    Costumes.define_part(2, 3, Costumes.part_type.PALETTE)                                           // part 0x2_0 - torso - front
    Costumes.add_part_image(2, 1, Costumes.part_type.PALETTE)                                        // part 0x2_1 - torso - hoodie
    Costumes.add_part_image(2, 2, Costumes.part_type.PRIM_COLOR)                                     // part 0x2_2 - torso - back
    Costumes.define_part(4, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0x4_0 - left upper arm
    Costumes.define_part(5, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0x5_0 - left lower arm
    Costumes.define_part(6, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0x6_0 - left hand
    Costumes.define_part(7, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0x7_0 - neck
    Costumes.define_part(8, 5, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)        // part 0x8_0 - head - eyes
    Costumes.add_part_image(8, 1, Costumes.part_type.TEXTURE_ARRAY | Costumes.part_type.PALETTE)     // part 0x8_1 - head - mouth
    Costumes.add_part_image(8, 2, Costumes.part_type.PALETTE)                                        // part 0x8_2 - head - top/ears
    Costumes.add_part_image(8, 3, Costumes.part_type.PRIM_COLOR)                                     // part 0x8_3 - head - back/sides
    Costumes.add_part_image(8, 4, Costumes.part_type.PRIM_COLOR)                                     // part 0x8_4 - head - back bottom
    Costumes.define_part(A, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0xA_0 - right upper arm
    Costumes.define_part(B, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0xB_0 - right lower arm
    Costumes.define_part(C, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0xC_0 - right hand
    Costumes.define_special_parts_for_part(D, 6)                                                     // part 0xD_0_0 is catapult, no images
    Costumes.add_special_part(D, 2, 2, Costumes.part_type.PRIM_COLOR)                                // part 0xD_2_0 - chainsaw handle
    Costumes.add_special_part_image(D, 2, 1, Costumes.part_type.PRIM_COLOR)                          // part 0xD_2_1 - chainsaw
    Costumes.add_special_part(D, 3, 2, Costumes.part_type.PRIM_COLOR)                                // part 0xD_3_0 - flamethrowser
    Costumes.add_special_part_image(D, 3, 1, Costumes.part_type.PRIM_COLOR)                          // part 0xD_3_1 - flamethrower can
    Costumes.add_special_part(D, 5, 2, Costumes.part_type.PRIM_COLOR)                                // part 0xD_5_0 - frying pan
    Costumes.add_special_part_image(D, 5, 1, Costumes.part_type.PRIM_COLOR)                          // part 0xD_5_1 - frying pan handle
    Costumes.define_part(F, 1, Costumes.part_type.PRIM_COLOR)                                        // part 0xF_0 - left upper leg
    Costumes.define_part(10, 1, Costumes.part_type.PRIM_COLOR)                                       // part 0x10_0 - left lower leg
    Costumes.define_part(12, 2, Costumes.part_type.PRIM_COLOR)                                       // part 0x12_0 - left foot - heel
    Costumes.add_part_image(12, 1, Costumes.part_type.PRIM_COLOR)                                    // part 0x12_1 - left foot - toes
    Costumes.define_part(14, 1, Costumes.part_type.PRIM_COLOR)                                       // part 0x14_0 - right upper leg
    Costumes.define_part(15, 1, Costumes.part_type.PRIM_COLOR)                                       // part 0x15_0 - right lower leg
    Costumes.define_part(17, 2, Costumes.part_type.PRIM_COLOR)                                       // part 0x17_0 - right foot - heel
    Costumes.add_part_image(17, 1, Costumes.part_type.PRIM_COLOR)                                    // part 0x17_1 - right foot - toes
    Costumes.define_part(18, 1, Costumes.part_type.PRIM_COLOR)                                       // part 0x18_0 - lower tail
    Costumes.define_part(19, 1, Costumes.part_type.PALETTE)                                          // part 0x19_0 - tail tip

    // Register extra costumes
    Costumes.register_extra_costumes_for_char(Character.id.CONKER)

    // Costume 0x6
    // Yellow Team
    // TODO: update!
    scope costume_0x6 {
        chest:; insert "Conker/cos_6_1.bin"
        hood:; insert "Conker/cos_6_2.bin"
        eyes:; insert "Conker/cos_6_3.bin"
        mouth:; insert "Conker/cos_6_4.bin"
        head:; insert "Conker/cos_6_5.bin"
        tail:; insert "Conker/cos_6_6.bin"
		
        constant fur_color(0x484848FF)
        constant hand_color(0xFFFFFFFF)
        constant hoodie_color(0xe5a40000)
        constant sleeve_color(0xf5e10200)
        constant shoes_color_heel(0xFFCF1100)
        constant shoes_color_toes(0xFFFFFFFF)
        constant cheek_color(0xe8e8e8FF)
        constant chainsaw_handle_color(0x363636FF)
        constant chainsaw_color(0xFFD900FF)
        constant flamethrower_color(0xD2F0FFFF)
        constant flamethrower_can_color(0xFF2600FF)
        constant frying_pan_color(0x3F3F3FFF)
        constant frying_pan_handle_color(0x97A3ACFF)

        Costumes.set_prim_color_for_part(0, 1, 0, fur_color)
        Costumes.set_prim_color_for_part(0, 1, 1, fur_color)
        Costumes.set_palette_for_part(0, 2, 0, chest)
        Costumes.set_palette_for_part(0, 2, 1, hood)
        Costumes.set_prim_color_for_part(0, 2, 2, hoodie_color)
        Costumes.set_prim_color_for_part(0, 4, 0, sleeve_color)
        Costumes.set_prim_color_for_part(0, 5, 0, sleeve_color)
        Costumes.set_prim_color_for_part(0, 6, 0, hand_color)
        Costumes.set_prim_color_for_part(0, 7, 0, fur_color)
        Costumes.set_palette_for_part(0, 8, 0, eyes)
        Costumes.set_palette_for_part(0, 8, 1, mouth)
        Costumes.set_palette_for_part(0, 8, 2, head)
        Costumes.set_prim_color_for_part(0, 8, 3, fur_color)
        Costumes.set_prim_color_for_part(0, 8, 4, cheek_color)
        Costumes.set_prim_color_for_part(0, A, 0, sleeve_color)
        Costumes.set_prim_color_for_part(0, B, 0, sleeve_color)
        Costumes.set_prim_color_for_part(0, C, 0, hand_color)
        Costumes.set_prim_color_for_special_part(0, D, 2, 0, chainsaw_handle_color)
        Costumes.set_prim_color_for_special_part(0, D, 2, 1, chainsaw_color)
        Costumes.set_prim_color_for_special_part(0, D, 3, 0, flamethrower_color)
        Costumes.set_prim_color_for_special_part(0, D, 3, 1, flamethrower_can_color)
        Costumes.set_prim_color_for_special_part(0, D, 5, 0, frying_pan_color)
        Costumes.set_prim_color_for_special_part(0, D, 5, 1, frying_pan_handle_color)
        Costumes.set_prim_color_for_part(0, F, 0, fur_color)
        Costumes.set_prim_color_for_part(0, 10, 0, fur_color)
        Costumes.set_prim_color_for_part(0, 12, 0, shoes_color_heel)
        Costumes.set_prim_color_for_part(0, 12, 1, shoes_color_toes)
        Costumes.set_prim_color_for_part(0, 14, 0, fur_color)
        Costumes.set_prim_color_for_part(0, 15, 0, fur_color)
        Costumes.set_prim_color_for_part(0, 17, 0, shoes_color_heel)
        Costumes.set_prim_color_for_part(0, 17, 1, shoes_color_toes)
        Costumes.set_prim_color_for_part(0, 18, 0, fur_color)
        Costumes.set_palette_for_part(0, 19, 0, tail)

        Costumes.set_stock_icon_palette_for_costume(0, Conker/cos_6_stock.bin)
    }
}
