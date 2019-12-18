// Data.asm
if !{defined __DATA__} {
define __DATA__()
print "included Data.asm\n"

// @ Description
// This file contains binary data such as images and stage files.

include "Texture.asm"

scope Data {
    
    // Menu Textures
    menu_logo_info:
    Texture.info(192,128)
    insert menu_logo, "../textures/menu_remix_logo.rgba5551"

    menu_bg_info:
    //Texture.info(184,74)
    Texture.info(300,220)
    insert menu_bg, "../textures/menu_bg_remix.rgba5551"

    options_text_info:
    Texture.info(80,16)
    insert options_text, "../textures/menu_options_text.rgba5551"

    // VS Mode Textures
    combo_text_b_info:
    Texture.info(64,16)
    insert combo_text_blue, "../textures/combo_text_b.rgba5551"

    combo_text_g_info:
    Texture.info(64,16)
    insert combo_text_green, "../textures/combo_text_g.rgba5551"

    combo_text_r_info:
    Texture.info(64,16)
    insert combo_text_red, "../textures/combo_text_r.rgba5551"

    combo_text_s_info:
    Texture.info(64,16)
    insert combo_text_silver, "../textures/combo_text_s.rgba5551"

    combo_text_y_info:
    Texture.info(64,16)
    insert combo_text_yellow, "../textures/combo_text_y.rgba5551"

    combo_numbers_b_info:
    Texture.info(16, 16)
    insert "../textures/combo_numbers_b.rgba5551"

    combo_numbers_g_info:
    Texture.info(16, 16)
    insert "../textures/combo_numbers_g.rgba5551"

    combo_numbers_r_info:
    Texture.info(16, 16)
    insert "../textures/combo_numbers_r.rgba5551"

    combo_numbers_s_info:
    Texture.info(16, 16)
    insert "../textures/combo_numbers_s.rgba5551"

    combo_numbers_y_info:
    Texture.info(16, 16)
    insert "../textures/combo_numbers_y.rgba5551"

    // Controller textures
    a_button_info:
    Texture.info(16, 16)
    insert "../textures/a_button.rgba5551"

    b_button_info:
    Texture.info(16, 16)
    insert "../textures/b_button.rgba5551"

    r_button_info:
    Texture.info(16, 16)
    insert "../textures/r_button.rgba5551"
}

} // __DATA__
