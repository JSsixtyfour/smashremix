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

    // Controller textures
    a_button_info:
    Texture.info(16, 16)
    insert "../textures/a_button.rgba5551"

    b_button_info:
    Texture.info(16, 16)
    insert "../textures/b_button.rgba5551"

    dpad_info:
    Texture.info(16, 16)
    insert "../textures/dpad-16x16.rgba5551"

    l_button_info:
    Texture.info(16, 16)
    insert "../textures/l_button.rgba5551"

    r_button_info:
    Texture.info(16, 16)
    insert "../textures/r_button.rgba5551"

    z_button_info:
    Texture.info(16, 16)
    insert "../textures/z_button.rgba5551"

    // CSS textures
    flag_eu_info:
    Texture.info(16, 16)
    insert "../textures/flag_eu-10x10.rgba5551"

    flag_jp_info:
    Texture.info(16, 16)
    insert "../textures/flag_jp-10x10.rgba5551"

    flag_eu_big_info:
    Texture.info(16, 16)
    insert "../textures/flag_eu.rgba5551"

    flag_jp_big_info:
    Texture.info(16, 16)
    insert "../textures/flag_jp.rgba5551"

    stock_icon_mm_info:
    Texture.info(8, 8)
    insert "../textures/stock-icon-mm.rgba5551"

    stock_icon_gdk_info:
    Texture.info(8, 8)
    insert "../textures/stock-icon-gdk.rgba5551"

    stock_icon_poly_info:
    Texture.info(8, 8)
    insert "../textures/stock-icon-poly.rgba5551"
}

} // __DATA__
