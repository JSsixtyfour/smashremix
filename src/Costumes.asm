// Costumes.asm
if !{defined __COSTUMES__} {
define __COSTUMES__()
print "included Costumes.asm\n"

// @ Description
// This file makes all SSB costumes usable in versus and training.
// TODO: Shades don't work in 1p, Bonus or Training - once you leave the CSS, the shade resets to default

include "OS.asm"

scope Costumes {

    // @ Description
    // Types of parts
    scope part_type {
        constant PALETTE(0x0004)
        constant PRIM_COLOR(0x0200)
        constant TEXTURE_ARRAY(0x0001)
        constant DIFFUSE_AMBIENT_COLORS(0x3000)
    }

    // @ Description
    // Defines a part of the given type by creating the images array and type array.
    // Should be called within a scope that has the character's parts_table.
    // @ Arguments
    // part_id - part ID
    // num_images - number of images
    // type - type of the first image
    macro define_part(part_id, num_images, type) {
        if ({type} & part_type.PALETTE != 0) {
            part_0x{part_id}_0_palette_array:
            constant PART_0x{part_id}_0_PALETTE_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.PRIM_COLOR != 0) {
            part_0x{part_id}_0_prim_color_array:
            constant PART_0x{part_id}_0_PRIM_COLOR_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.TEXTURE_ARRAY != 0) {
            part_0x{part_id}_0_texture_array_array:
            constant PART_0x{part_id}_0_TEXTURE_ARRAY_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            part_0x{part_id}_0_diffuse_ambient_array:
            constant PART_0x{part_id}_0_DIFFUSE_AMBIENT_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }

        // array pointers for each image:
        // 0x0000 - palette array
        // 0x0004 - prim color array
        // 0x0008 - texture array array
        // 0x000C - diffuse/ambient color array
        part_0x{part_id}_images:
        constant PART_0x{part_id}_IMAGES_ORIGIN(origin())
        if ({type} & Costumes.part_type.PALETTE != 0) {
            dw part_0x{part_id}_0_palette_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.PRIM_COLOR != 0) {
            dw part_0x{part_id}_0_prim_color_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.TEXTURE_ARRAY != 0) {
            dw part_0x{part_id}_0_texture_array_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            dw part_0x{part_id}_0_diffuse_ambient_array
        } else {
            dw 0x0
        }

        fill ({num_images} - 1) * 0x10

        pushvar base, origin

        origin PARTS_TABLE_ORIGIN + (0x{part_id} * 8)
        dw part_0x{part_id}_images
        dw 0x0                                           // special parts array pointer, defined with define_special_parts_for_part

        pullvar origin, base
    }

    // @ Description
    // Sets up special parts for the given part.
    // Should be called within a scope that has the character's parts_table.
    // @ Arguments
    // part_id - part ID
    // num_special_parts - number of special parts that are swappable (not necessary always, even if there are special parts)
    macro define_special_parts_for_part(part_id, num_special_parts) {
        part_0x{part_id}_special_parts:
        constant PART_0x{part_id}_SPECIAL_PARTS_ORIGIN(origin())
        fill {num_special_parts} * 0x4

        pushvar base, origin

        origin PARTS_TABLE_ORIGIN + (0x{part_id} * 8) + 4
        dw part_0x{part_id}_special_parts

        pullvar origin, base
    }

    // @ Description
    // Sets up special parts for the given part.
    // First special part is setup as the given type by creating the images array and type array.
    // Should be called within a scope that has the character's parts_table.
    // @ Arguments
    // part_id - part ID
    // num_special_parts - number of special parts that are swappable (not necessary always, even if there are special parts)
    // num_images - number of images of first special part
    // type - type of the first image
    macro define_special_parts_for_part(part_id, num_special_parts, num_images, type) {
        if ({type} & part_type.PALETTE != 0) {
            part_0x{part_id}_0_0_palette_array:
            constant PART_0x{part_id}_0_0_PALETTE_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.PRIM_COLOR != 0) {
            part_0x{part_id}_0_0_prim_color_array:
            constant PART_0x{part_id}_0_0_PRIM_COLOR_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.TEXTURE_ARRAY != 0) {
            part_0x{part_id}_0_0_texture_array_array:
            constant PART_0x{part_id}_0_0_TEXTURE_ARRAY_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            part_0x{part_id}_0_0_diffuse_ambient_array:
            constant PART_0x{part_id}_0_0_DIFFUSE_AMBIENT_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }

        // array pointers for each image:
        // 0x0000 - palette array
        // 0x0004 - prim color array
        // 0x0008 - texture array array
        // 0x000C - diffuse/ambient color array
        part_0x{part_id}_0_images:
        constant PART_0x{part_id}_0_IMAGES_ORIGIN(origin())
        if ({type} & Costumes.part_type.PALETTE != 0) {
            dw part_0x{part_id}_0_0_palette_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.PRIM_COLOR != 0) {
            dw part_0x{part_id}_0_0_prim_color_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.TEXTURE_ARRAY != 0) {
            dw part_0x{part_id}_0_0_texture_array_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            dw part_0x{part_id}_0_0_diffuse_ambient_array
        } else {
            dw 0x0
        }

        fill ({num_images} - 1) * 0x10

        part_0x{part_id}_special_parts:
        constant PART_0x{part_id}_SPECIAL_PARTS_ORIGIN(origin())
        dw part_0x{part_id}_0_images
        fill ({num_special_parts} - 1) * 0x4

        pushvar base, origin

        origin PARTS_TABLE_ORIGIN + (0x{part_id} * 8) + 4
        dw part_0x{part_id}_special_parts

        pullvar origin, base
    }

    // @ Description
    // Sets up a special part for the given part as the given type by creating the images array and type array.
    // Should be called within a scope that has the character's parts_table.
    // @ Arguments
    // part_id - part ID
    // special_part_index - special part index
    // num_images - number of images
    // type - type of the first image
    macro add_special_part(part_id, special_part_index, num_images, type) {
        if ({type} & part_type.PALETTE != 0) {
            part_0x{part_id}_{special_part_index}_0_palette_array:
            constant PART_0x{part_id}_{special_part_index}_0_PALETTE_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.PRIM_COLOR != 0) {
            part_0x{part_id}_{special_part_index}_0_prim_color_array:
            constant PART_0x{part_id}_{special_part_index}_0_PRIM_COLOR_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.TEXTURE_ARRAY != 0) {
            part_0x{part_id}_{special_part_index}_0_texture_array_array:
            constant PART_0x{part_id}_{special_part_index}_0_TEXTURE_ARRAY_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            part_0x{part_id}_{special_part_index}_0_diffuse_ambient_array:
            constant PART_0x{part_id}_{special_part_index}_0_DIFFUSE_AMBIENT_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }

        // array pointers for each image:
        // 0x0000 - palette array
        // 0x0004 - prim color array
        // 0x0008 - texture array array
        // 0x000C - diffuse/ambient color array
        part_0x{part_id}_{special_part_index}_images:
        constant PART_0x{part_id}_{special_part_index}_IMAGES_ORIGIN(origin())
        if ({type} & Costumes.part_type.PALETTE != 0) {
            dw part_0x{part_id}_{special_part_index}_0_palette_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.PRIM_COLOR != 0) {
            dw part_0x{part_id}_{special_part_index}_0_prim_color_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.TEXTURE_ARRAY != 0) {
            dw part_0x{part_id}_{special_part_index}_0_texture_array_array
        } else {
            dw 0x0
        }
        if ({type} & Costumes.part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            dw part_0x{part_id}_{special_part_index}_0_diffuse_ambient_array
        } else {
            dw 0x0
        }

        fill ({num_images} - 1) * 0x10

        pushvar base, origin

        origin PART_0x{part_id}_SPECIAL_PARTS_ORIGIN + ({special_part_index} * 4)
        dw part_0x{part_id}_{special_part_index}_images

        pullvar origin, base
    }

    // @ Description
    // Adds an image of the given type to the given part by creating the type array.
    // Should be called within a scope that has the character's parts_table.
    // @ Arguments
    // part_id - part ID
    // image_index - image index
    // type - type
    macro add_part_image(part_id, image_index, type) {
        if ({type} & part_type.PALETTE != 0) {
            part_0x{part_id}_{image_index}_palette_array:
            constant PART_0x{part_id}_{image_index}_PALETTE_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.PRIM_COLOR != 0) {
            part_0x{part_id}_{image_index}_prim_color_array:
            constant PART_0x{part_id}_{image_index}_PRIM_COLOR_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.TEXTURE_ARRAY != 0) {
            part_0x{part_id}_{image_index}_texture_array_array:
            constant PART_0x{part_id}_{image_index}_TEXTURE_ARRAY_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            part_0x{part_id}_{image_index}_diffuse_ambient_array:
            constant PART_0x{part_id}_{image_index}_DIFFUSE_AMBIENT_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }

        pushvar base, origin

        origin PART_0x{part_id}_IMAGES_ORIGIN + (0x{image_index} * 0x10)
        if ({type} & part_type.PALETTE != 0) {
            dw part_0x{part_id}_{image_index}_palette_array
        } else {
            dw 0x0
        }
        if ({type} & part_type.PRIM_COLOR != 0) {
            dw part_0x{part_id}_{image_index}_prim_color_array
        } else {
            dw 0x0
        }
        if ({type} & part_type.TEXTURE_ARRAY != 0) {
            dw part_0x{part_id}_{image_index}_texture_array_array
        } else {
            dw 0x0
        }
        if ({type} & part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            dw part_0x{part_id}_{image_index}_diffuse_ambient_array
        } else {
            dw 0x0
        }

        pullvar origin, base
    }

    // @ Description
    // Adds an image of the given type to the given part and special part by creating the type array.
    // Should be called within a scope that has the character's parts_table.
    // @ Arguments
    // part_id - part ID
    // special_part_index - special part index
    // image_index - image index
    // type - type
    macro add_special_part_image(part_id, special_part_index, image_index, type) {
        if ({type} & part_type.PALETTE != 0) {
            part_0x{part_id}_{special_part_index}_{image_index}_palette_array:
            constant PART_0x{part_id}_{special_part_index}_{image_index}_PALETTE_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.PRIM_COLOR != 0) {
            part_0x{part_id}_{special_part_index}_{image_index}_prim_color_array:
            constant PART_0x{part_id}_{special_part_index}_{image_index}_PRIM_COLOR_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.TEXTURE_ARRAY != 0) {
            part_0x{part_id}_{special_part_index}_{image_index}_texture_array_array:
            constant PART_0x{part_id}_{special_part_index}_{image_index}_TEXTURE_ARRAY_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }
        if ({type} & part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            part_0x{part_id}_{special_part_index}_{image_index}_diffuse_ambient_array:
            constant PART_0x{part_id}_{special_part_index}_{image_index}_DIFFUSE_AMBIENT_ARRAY(origin())
            fill NUM_EXTRA_COSTUMES * 4
        }

        pushvar base, origin

        origin PART_0x{part_id}_{special_part_index}_IMAGES_ORIGIN + (0x{image_index} * 0x10)
        if ({type} & part_type.PALETTE != 0) {
            dw part_0x{part_id}_{special_part_index}_{image_index}_palette_array
        } else {
            dw 0x0
        }
        if ({type} & part_type.PRIM_COLOR != 0) {
            dw part_0x{part_id}_{special_part_index}_{image_index}_prim_color_array
        } else {
            dw 0x0
        }
        if ({type} & part_type.TEXTURE_ARRAY != 0) {
            dw part_0x{part_id}_{special_part_index}_{image_index}_texture_array_array
        } else {
            dw 0x0
        }
        if ({type} & part_type.DIFFUSE_AMBIENT_COLORS != 0) {
            dw part_0x{part_id}_{special_part_index}_{image_index}_diffuse_ambient_array
        } else {
            dw 0x0
        }

        pullvar origin, base
    }

    // @ Description
    // Registers extra costumes for the give character in the extra_costumes_table.
    // Should be called within a scope that has the character's parts_table.
    // @ Arguments
    // char_id - character ID
    macro register_extra_costumes_for_char(char_id) {
        pushvar base, origin

        origin EXTRA_COSTUMES_TABLE_ORIGIN + ({char_id} * 4)
        dw parts_table

        pullvar origin, base
    }

    // @ Description
    // Sets a palette for the given costume, part and image index.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // image_index - image index, 0 based
    // color_X - [halfword] color (RGBA5551) for index X in palette
    macro set_palette_for_part(extra_costume_id, part_id, image_index, color_0, color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8, color_9, color_A, color_B, color_C, color_D, color_E, color_F, color_10, color_11, color_12, color_13) {
        part_0x{part_id}_{image_index}_costume_{extra_costume_id}_palette:
        dh {color_0}, {color_1}, {color_2}, {color_3}, {color_4}, {color_5}, {color_6}, {color_7}
        dh {color_8}, {color_9}, {color_A}, {color_B}, {color_C}, {color_D}, {color_E}, {color_F}
        dh {color_10}, {color_11}, {color_12}, {color_13}

        pushvar base, origin

        origin PART_0x{part_id}_{image_index}_PALETTE_ARRAY + ({extra_costume_id} * 4)
        dw part_0x{part_id}_{image_index}_costume_{extra_costume_id}_palette

        pullvar origin, base
    }

    // @ Description
    // Sets a palette for the given costume, part and image index using an existing palette address.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // image_index - image index, 0 based
    // palette_address - address of palette
    macro set_palette_for_part(extra_costume_id, part_id, image_index, palette_address) {
        pushvar base, origin

        origin PART_0x{part_id}_{image_index}_PALETTE_ARRAY + ({extra_costume_id} * 4)
        dw {palette_address}

        pullvar origin, base
    }

    // @ Description
    // Sets prim color for the given costume, part and image index.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // image_index - image index, 0 based
    // prim_color - prim color (0xRRGGBBAA)
    macro set_prim_color_for_part(extra_costume_id, part_id, image_index, prim_color) {
        pushvar base, origin

        origin PART_0x{part_id}_{image_index}_PRIM_COLOR_ARRAY + ({extra_costume_id} * 4)
        dw {prim_color}

        pullvar origin, base
    }

    // @ Description
    // Sets diffuse and ambient colors for the given costume, part and image index.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // image_index - image index, 0 based
    // diffuse_color - diffuse color (0xRRGGBBAA)
    // ambient_color - ambient color (0xRRGGBBAA)
    macro set_diffuse_ambient_colors_for_part(extra_costume_id, part_id, image_index, diffuse_color, ambient_color) {
        part_0x{part_id}_{image_index}_costume_{extra_costume_id}_diffuse_ambient_colors:
        dw {diffuse_color}, {ambient_color}

        pushvar base, origin

        origin PART_0x{part_id}_{image_index}_DIFFUSE_AMBIENT_ARRAY + ({extra_costume_id} * 4)
        dw part_0x{part_id}_{image_index}_costume_{extra_costume_id}_diffuse_ambient_colors

        pullvar origin, base
    }

    // @ Description
    // Sets diffuse and ambient colors for the given costume, part and image index using an existing diffuse/ambient color pair address.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // image_index - image index, 0 based
    // diffuse_ambient_address - diffuse/ambient color pair address
    macro set_diffuse_ambient_colors_for_part(extra_costume_id, part_id, image_index, diffuse_ambient_address) {
        pushvar base, origin

        origin PART_0x{part_id}_{image_index}_DIFFUSE_AMBIENT_ARRAY + ({extra_costume_id} * 4)
        dw {diffuse_ambient_address}

        pullvar origin, base
    }

    // @ Description
    // Sets a palette for the given costume, part, special part and image index.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // special_part_index - special part index, 0 based
    // image_index - image index, 0 based
    // color_X - [halfword] color (RGBA5551) for index X in palette
    macro set_palette_for_special_part(extra_costume_id, part_id, special_part_index, image_index, color_0, color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8, color_9, color_A, color_B, color_C, color_D, color_E, color_F, color_10, color_11, color_12, color_13) {
        part_0x{part_id}_{special_part_index}_{image_index}_costume_{extra_costume_id}_palette:
        dh {color_0}, {color_1}, {color_2}, {color_3}, {color_4}, {color_5}, {color_6}, {color_7}
        dh {color_8}, {color_9}, {color_A}, {color_B}, {color_C}, {color_D}, {color_E}, {color_F}
        dh {color_10}, {color_11}, {color_12}, {color_13}

        pushvar base, origin

        origin PART_0x{part_id}_{special_part_index}_{image_index}_PALETTE_ARRAY + ({extra_costume_id} * 4)
        dw part_0x{part_id}_{special_part_index}_{image_index}_costume_{extra_costume_id}_palette

        pullvar origin, base
    }

    // @ Description
    // Sets a palette for the given costume, part, special part and image index using an existing palette address.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // special_part_index - special part index, 0 based
    // image_index - image index, 0 based
    // palette_address - address of palette
    macro set_palette_for_special_part(extra_costume_id, part_id, special_part_index, image_index, palette_address) {
        pushvar base, origin

        origin PART_0x{part_id}_{special_part_index}_{image_index}_PALETTE_ARRAY + ({extra_costume_id} * 4)
        dw {palette_address}

        pullvar origin, base
    }

    // @ Description
    // Sets prim color for the given costume, part, special part and image index.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // special_part_index - special part index, 0 based
    // image_index - image index, 0 based
    // prim_color - prim color (0xRRGGBBAA)
    macro set_prim_color_for_special_part(extra_costume_id, part_id, special_part_index, image_index, prim_color) {
        pushvar base, origin

        origin PART_0x{part_id}_{special_part_index}_{image_index}_PRIM_COLOR_ARRAY + ({extra_costume_id} * 4)
        dw {prim_color}

        pullvar origin, base
    }

    // @ Description
    // Sets diffuse and ambient colors for the given costume, part, special part and image index.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // special_part_index - special part index, 0 based
    // image_index - image index, 0 based
    // diffuse_color - diffuse color (0xRRGGBBAA)
    // ambient_color - ambient color (0xRRGGBBAA)
    macro set_diffuse_ambient_colors_for_special_part(extra_costume_id, part_id, special_part_index, image_index, diffuse_color, ambient_color) {
        part_0x{part_id}_{special_part_index}_{image_index}_costume_{extra_costume_id}_diffuse_ambient_colors:
        dw {diffuse_color}, {ambient_color}

        pushvar base, origin

        origin PART_0x{part_id}_{special_part_index}_{image_index}_DIFFUSE_AMBIENT_ARRAY + ({extra_costume_id} * 4)
        dw part_0x{part_id}_{special_part_index}_{image_index}_costume_{extra_costume_id}_diffuse_ambient_colors

        pullvar origin, base
    }

    // @ Description
    // Sets diffuse and ambient colors for the given costume, part, special part and image index using an existing diffuse/ambient color pair address.
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // part_id - part ID
    // special_part_index - special part index, 0 based
    // image_index - image index, 0 based
    // diffuse_ambient_address - diffuse/ambient color pair address
    macro set_diffuse_ambient_colors_for_special_part(extra_costume_id, part_id, special_part_index, image_index, diffuse_ambient_address) {
        pushvar base, origin

        origin PART_0x{part_id}_{special_part_index}_{image_index}_DIFFUSE_AMBIENT_ARRAY + ({extra_costume_id} * 4)
        dw {diffuse_ambient_address}

        pullvar origin, base
    }

    // @ Description
    // Sets stock icon palette for the given costume
    // @ Arguments
    // extra_costume_id - extra costume ID, zero-based
    // stock_icon_palette_file - stock icon palette file
    macro set_stock_icon_palette_for_costume(extra_costume_id, stock_icon_palette_file) {
        costume_{extra_costume_id}_stock_icon_palette:; insert "/costumes/{stock_icon_palette_file}"

        pushvar base, origin

        origin EXTRA_STOCK_ICON_PALETTE_ARRAY_ORIGIN + ({extra_costume_id} * 4)
        dw costume_{extra_costume_id}_stock_icon_palette

        pullvar origin, base
    }

    // @ Description
    // This function replaces the original costume selection in favor of the 19XX style selection.
    // CLeft and Cright will now cycle through colors while CUp and CDown cycle through shades.
    // @ Warning
    // This is not a function that should be called. It is a patch/hook.
    scope select_: {
        // vs
        OS.patch_start(0x001361B4, 0x80137F34)
        jal     Costumes.select_
        nop
        OS.patch_end()

        // training
        OS.patch_start(0x00144BF8, 0x80135618)
        jal     Costumes.select_
        nop
        OS.patch_end()

        // 1P
        OS.patch_start(0x13ED5C, 0x80136B5C)
        sw      s0, 0x001C(sp)              // store s0
        jal     Costumes.select_
        addu    s0, v1, r0                  // s0 = player struct
        lw      s0, 0x001C(sp)              // restore s0
        sw      v0, 0x001C(sp)              // original line 2
        nop
        OS.patch_end()

        // Bonus
        OS.patch_start(0x14B628, 0x801355F8)
        li      s0, 0x80137648              // s0 = player struct
        jal     Costumes.select_
        nop
        addu    s0, r0, r0                  // restore s0
        sw      v0, 0x001C(sp)              // original line 2
        OS.patch_end()

        // a0 holds character id (until original line 2)
        // a1 holds direction pressed (up = 0, right = 1, down = 2, left = 3)

        addiu   sp, sp,-0x0030              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // ~
        sw      t2, 0x000C(sp)              // ~
        sw      at, 0x0010(sp)              // ~
        sw      a0, 0x0014(sp)              // ~
        sw      a1, 0x0018(sp)              // ~
        sw      a2, 0x001C(sp)              // ~
        sw      ra, 0x0020(sp)              // ~
        sw      t3, 0x0024(sp)              // ~
        sw      t4, 0x0028(sp)              // save registers

        li      t0, functions               // t0 = functions
        sll     t1, a1, 0x0002              // t1 = action * 4 = offset
        add     t0, t0, t1                  // t0 = functions + offset
        lw      t0, 0x0000(t0)              // t0 = function
        li      t1, num_costumes            // t1 = num_costumes Table
        add     t1, t1, a0                  // t1 = num_costumes + offset
        lb      t1, 0x0000(t1)              // t1 = number of original costumes char has (0-based)
        li      t2, extra_costumes_table    // t2 = extra_costumes_table
        sll     at, a0, 0x0002              // at = offset in extra_costumes_table
        addu    t2, t2, at                  // t2 = extra_costumes_table + offset
        lw      t2, 0x0000(t2)              // t2 = extra costumes table, or 0
        lli     t3, 0x0000                  // t2 = costumes to skip
        beqz    t2, _check_training         // if no extra costumes parts table exists, skip getting number of extra costumes
        or      t4, t1, r0
        lbu     t3, 0x0003(t2)              // t3 = costumes to skip
        lbu     t2, 0x0000(t2)              // t2 = number of extra costumes
        addu    t4, t2, t3                  // t4 = number of extra costumes + costumes to skip
        addu    t4, t1, t4                  // t4 = original max costume ID + number of extra costumes + costumes to skip

        _check_training:
        li      at, 0x80135620              // at = ra for training
        beq     at, ra, _training           // if we're in training, then skip next part
        nop
        lw      t2, 0x0050(s0)              // t2 = current shade_id
        li      at, 0x80136B68              // at = ra for 1p
        beql    at, ra, _1p_or_bonus        // if we're in 1p, then skip next part
        nop
        li      at, 0x80135608              // at = ra for bonus
        beq     at, ra, _1p_or_bonus        // if we're in bonus, then skip next part
        nop
        b       _go_to_function
        nop

        _1p_or_bonus:
        lw      t2, 0x001C(s0)              // t2 = current shade_id
        jr      t0                          // go to function
        lw      v0, 0x0024(s0)              // v0 = current costume_id

        _training:
        lw      at, 0x0008(s0)              // at = player object
        lw      at, 0x0084(at)              // at = player struct
        lb      t2, 0x0011(at)              // t2 = current shade_id

        _go_to_function:
        jr      t0                          // go to function
        lw      v0, 0x004C(s0)              // v0 = current costume_id

        // change costume
        _right:
        or      t2, r0, r0                  // reset shade
        beql    v0, t1, pc() + 8            // if costume is the original max costume ID, add skipped costumes
        addu    v0, v0, t3                  // v0 = costume ID of last costume before first extra costume, if it exists
        sltu    at, v0, t4                  // at = 1 if not the last valid costume
        bnel    at, r0, _end                // if (costume_id < num_costumes)
        addiu   v0, v0, 0x0001              // then, costume_id ++

        or      v0, r0, r0                  // else, v0 = 0

        lw      a0, 0x0008(s0)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a1, 0x0008(a0)              // a1 = char_id
        lli     at, Character.id.SONIC      // at = Character.id.SONIC
        beq     a1, at, _sonic              // branch if Sonic
        nop
        b       _end                        // end
        nop

        _left:
        addu    t2, t1, t3                  // t2 = costume_id of last original costume
        addiu   t2, t2, 0x0001              // t2 = costume_id of first extra costume, if it exists
        beql    v0, t2, pc() + 8            // if this is the first added costume, remove skipped costumes
        subu    v0, v0, t3                  // v0 = costume ID of first skipped costume
        or      t2, r0, r0                  // reset shade
        bgtz    v0, _end                    // if (costume_id > 0)
        addiu   v0, v0,-0x0001              // then, v0--

        or      v0, t4, r0                  // else, v0 = last costume_id

        lw      a0, 0x0008(s0)              // a0 = player object
        lw      a0, 0x0084(a0)              // a0 = player struct
        lw      a1, 0x0008(a0)              // a1 = char_id
        lli     at, Character.id.SONIC      // at = Character.id.SONIC
        beq     a1, at, _sonic              // branch if Sonic
        nop
        b       _end                        // end
        nop

        // change tint
        _up:
        sltiu   at, t2, 0x0002              // ~
        beql    at, r0, _end                // if (shade < 2)
        or      t2, r0, r0                  // then, t2 = 0
        addiu   t2, t2, 0x0001              // else, shade_id++
        b       _end                        // end
        nop

        _down:
        bgtz    t2, _end                    // if (costume_id =)
        addiu   t2, t2,-0x0001              // then, t2--
        li      t2, 0x00000002              // else, t2 = 2
        b       _end                        // end
        nop

        _1p_or_bonus_2:
        sw      v0, 0x0024(s0)              // store updated costume_id
        sw      t2, 0x001C(s0)              // store updated shade_id
        lw      a0, 0x0008(s0)              // a0 = player object
        b       _finish
        nop

        _sonic:
        lbu     a0, 0x000D(a0)              // a0 = player port
        li      a1, Sonic.classic_table     // a1 = classic_table
        addu    a1, a1, a0                  // a1 = classic_table + port
        lbu     at, 0x0000(a1)              // at = px is_classic
        xori    at, at, 0x0001              // ~
        sb      at, 0x0000(a1)              // flip px_is_classic
        li      a1, Sonic.select_anim_frame // a1 = select_anim_frame
        sll     at, a0, 0x2                 // at = port * 4
        addu    a1, a1, at                  // a1 = px select_anim_frame address
        lw      at, 0x0008(s0)              // at = player object
        lw      at, 0x0078(at)              // at = current animation frame

        OS.save_registers()

        li      v0, 0x80136B68              // v0 = ra for 1p
        beq     v0, ra, _sonic_1p           // if we're in 1p, then call right model routine
        nop

        li      v0, 0x80135608              // v0 = ra for bonus
        beq     v0, ra, _sonic_bonus        // if we're in bonus, then call right model routine
        nop

        li      v0, 0x80137F3C              // v0 = ra for vs
        beq     v0, ra, _sonic_vs           // if we're in vs, then call right model routine
        nop

        jal     0x80133E30                  // set up character model (training)
        lw      a0, 0x00C8(sp)              // a0 = panel index
        b       _sonic_end
        nop

        _sonic_1p:
        jal     0x80135804                  // set up character model (1p)
        lli     a0, 0x0000                  // a0 = panel index
        b       _sonic_end
        nop

        _sonic_bonus:
        jal     0x8013476C                  // set up character model (bonus)
        lli     a0, 0x0000                  // a0 = panel index
        b       _sonic_end
        nop

        _sonic_vs:
        jal     0x80136128                  // set up character model (vs)
        nop

        _sonic_end:
        OS.restore_registers()
        beqzl   at, pc() + 8                // if current animation frame = 0...
        // note: hard coded to length of selection animation
        lui     at, 0x4341                  // ...set current animation frame to 193 instead
        sw      at, 0x0000(a1)              // update px select_anim_frame
        lw      a0, 0x0008(s0)              // a0 = player object
        sw      at, 0x0078(a0)              // set current animation frame

        _end:
        lw      a0, 0x0008(s0)              // a0 = player object
        addu    a1, v0, r0                  // a1 = costume_id

        li      at, 0x80136B68              // at = ra for 1p
        beq     at, ra, _1p_or_bonus_2      // if we're in 1p, then skip next part
        nop

        li      at, 0x80135608              // at = ra for bonus
        beq     at, ra, _1p_or_bonus_2      // if we're in bonus, then skip next part
        nop

        li      at, 0x80137F3C              // at = ra for vs
        bne     at, ra, _store_costume      // if we're not in vs, then skip next part
        nop
        lui     at, 0x8014
        lw      at, 0xBDA8(at)              // at = 0 if FFA, 1 for Team Battle
        beqz    at, _store_costume          // if FFA, continue normally
        lw      at, 0x0048(s0)              // at = char_id
        lli     a2, Character.id.SONIC      // a2 = id.SONIC
        bnel    at, a2, _store_costume      // if not Sonic, then don't allow updating the costume
        lw      v0, 0x004C(s0)              // v0 = current costume_id

        // if we're here, we need may need to update the costume
        lw      at, 0x004C(s0)              // at = current costume_id
        beq     v0, at, _store_costume      // if the costumes match, shade was changed, so skip
        or      v0, at, r0                  // v0 = current costume_id
        b       _sonic                      // branch to sonic case to switch models
        lw      a0, 0x0084(a0)              // a0 = player struct

        _store_costume:
        sw      v0, 0x004C(s0)              // store updated costume_id

        li      at, 0x80135620              // at = ra for training
        beq     at, ra, _finish             // if we're in training, then skip next part
        nop

        sw      t2, 0x0050(s0)              // store updated shade_id

        _finish:
        or      a2, t2, r0                  // a2 = shade_id
        addiu   sp, sp,-0x0008              // allocate stack space
        sw      v0, 0x0004(sp)              // save v0
        jal     Costumes.update_            // apply costume
        nop
        lw      v0, 0x0004(sp)              // restore v0
        addiu   sp, sp, 0x0008              // deallocate stack space

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // ~
        lw      t2, 0x000C(sp)              // ~
        lw      at, 0x0010(sp)              // ~
        lw      a0, 0x0014(sp)              // ~
        lw      a1, 0x0018(sp)              // ~
        lw      a2, 0x001C(sp)              // ~
        lw      ra, 0x0020(sp)              // ~
        lw      t3, 0x0024(sp)              // ~
        lw      t4, 0x0028(sp)              // restore registers
        addiu   sp, sp, 0x0030              // deallocate stack space

        sw      v0, 0x0024(sp)              // original line 1
        lw      a0, 0x0048(s0)              // original line 2

        jr      ra                          // return
        nop

        num_costumes:
        db 0x04                             // Mario
        db 0x03                             // Fox
        db 0x04                             // Donkey Kong
        db 0x04                             // Samus
        db 0x03                             // Luigi
        db 0x03                             // Link
        db 0x05                             // Yoshi
        db 0x05                             // Captain Falcon
        db 0x04                             // Kirby
        db 0x03                             // Pikachu
        db 0x04                             // Jigglypuff
        db 0x03                             // Ness
        db 0x00                             // Master Hand
        db 0x05                             // Metal Mario
        db 0x05                             // Polygon Mario
        db 0x05                             // Polygon Fox
        db 0x05                             // Polygon Donkey Kong
        db 0x05                             // Polygon Samus
        db 0x05                             // Polygon Luigi
        db 0x05                             // Polygon Link
        db 0x05                             // Polygon Yoshi
        db 0x05                             // Polygon Captain Falcon
        db 0x05                             // Polygon Kirby
        db 0x05                             // Polygon Pikachu
        db 0x05                             // Polygon Jigglypuff
        db 0x05                             // Polygon Ness
        db 0x04                             // Giant Donkey Kong
        db 0x00                             // (Placeholder)
        db 0x00                             // None (Placeholder)
        db 0x05                             // Falco
        db 0x05                             // Ganondorf
        db 0x05                             // Young Link
        db 0x05                             // Dr. Mario
        db 0x05                             // Wario
        db 0x05                             // Dark Samus
        db 0x03                             // E Link
        db 0x04                             // J Samus
        db 0x03                             // J Ness
        db 0x05                             // Lucas
        db 0x03                             // J Link
        db 0x05                             // J Falcon
        db 0x03                             // J Fox
        db 0x04                             // J Mario
        db 0x03                             // J Luigi
        db 0x04                             // J Donkey Kong
        db 0x03                             // E Pikachu
        db 0x04                             // J Jigglypuff
        db 0x04                             // E Jigglypuff
        db 0x04                             // J Kirby
        db 0x05                             // J Yoshi
        db 0x03                             // J Pikachu
        db 0x04                             // E Samus
		db 0x05                             // Bowser
		db 0x05                             // Giga Bowser
        db 0x05                             // Piano
		db 0x05                             // Wolf
        db 0x05                             // Conker
        db 0x05                             // Mewtwo
        db 0x05                             // Marth
        db 0x05                             // Sonic
        db 0x05                             // Sandbag
        db 0x05                             // Super Sonic
        db 0x05                             // Classic Sonic
        db 0x05                             // Sheik
        db 0x05                             // Marina
        db 0x05                             // Dedede
        
        // Polygons
        db 0x05                             // Polygon Wario
        db 0x05                             // Polygon Lucas
        db 0x05                             // Polygon Bowser
        db 0x05                             // Polygon Wolf
        db 0x05                             // Polygon Dr. Mario
        db 0x05                             // Polygon Sonic
        db 0x05                             // Polygon Sheik
        OS.align(4)

        functions:
        dw _up
        dw _right
        dw _down
        dw _left
    }

    // @ Description
    // These prevent the costume/shade from being overwritten when selecting with C buttons or when in team battle.
    scope disable_update: {
        // vs
        OS.patch_start(0x001361EC, 0x80137F6C)
        nop                                 // sw v0, 0x0050(s0)
        lw      a0, 0x0008(s0)              // original line 2
        lw      a1, 0x0024(sp)              // original line 3
        nop                                 // jal update_
        OS.patch_end()

        // vs team battle - prevent skipping individual C-button checks
        OS.patch_start(0x0013679C, 0x8013851C)
        jal     disable_update
        sw      t8, 0x001C(sp)              // original line 2
        OS.patch_end()
        // vs team battle - prevent updating costume when teammate has same character
        OS.patch_start(0x00137D04, 0x80139A84)
        lw      v0, 0x0050(s0)              // original: sw      v0, 0x0050(s0)
        OS.patch_end()

        // training
        OS.patch_start(0x00144C28, 0x80135648)
        nop                                 // jal update_
        OS.patch_end()

        // original line 1: bnez t9, 0x80138650
        beqz    t9, _end                    // if not teams, go forth normally
        // (use delay slot below)

        // otherwise we'll only check C buttons if character is selected and not holding a CPU token
        lw      t0, 0x0088(t8)              // t0 = 1 if character selected
        beqz    t0, _j_0x80138650           // if character is not selected, skip c button checks
        lw      t0, 0x0080(t8)              // t0 = -1 if not holding a token
        bltz    t0, _end                    // if not holding a token, continue normally
        nop

        _j_0x80138650:
        // if here, then we should skip c button checks
        j       0x80138650
        nop

        _end:
        jr      ra
        nop
    }

    // @ Description
    // Allows CPU costume/shade to be controlled when pressing C buttons while hovering over CPU's panel.
    scope cpu_costumes_: {
        // vs C button check start
        OS.patch_start(0x136770, 0x801384F0)
        jal     cpu_costumes_
        lui     t9, 0x8014                  // original line 1
        OS.patch_end()
        // training C button check start
        OS.patch_start(0x145010, 0x80135A30)
        jal     cpu_costumes_._training
        lhu     t7, 0x522A(t7)              // original line 1
        OS.patch_end()

        // 0x0040(sp) - cursor object
        // a1/0x0028(sp) - panel index

        // Here, we'll check if C buttons are being pressed, and if so, check if the cursor is over a CPU panel.
        // If it is, we'll swap out the port ID with the panel ID.

        lhu     v1, 0x0002(t5)              // v1 = button mask
        andi    t0, v1, 0x000F              // t0 = 0 if no C buttons are pressed
        beqz    t0, _end                    // if no C buttons pressed, skip to end
        nop

        lw      a0, 0x0040(sp)              // a0 = cursor object
        lli     t8, 0x0000                  // t8 = 0 = port 1
        li      t6, CharacterSelect.CSS_PLAYER_STRUCT

        _loop:
        sltiu   t7, t8, 0x0004              // t7 = 0 if we should exit loop
        beqz    t7, _end                    // exit loop if no more ports to check
        nop
        beq     t8, a1, _next               // skip panel check for same port
        nop
        lw      v1, 0x0084(t6)              // v1 = panel type (0=HMN, 1=CPU, 2=N/A)
        addiu   v1, v1, -0x0001             // v1 = 0 if CPU
        bnez    v1, _next                   // skip if not CPU
        nop

        sw      ra, 0x0004(sp)              // save ra in unused stack space
        jal     CharacterSelect.check_image_press_
        lw      a1, 0x0018(t6)              // a1 = panel object
        beqz    v0, _next                   // if not over the panel, skip
        lw      ra, 0x0004(sp)              // restore ra

        // otherwise, use the CPU port index going forward
        sw      t8, 0x0028(sp)              // save port index
        b       _end
        or      a1, t8, r0                  // update port index in a1

        _next:
        lw      a1, 0x0028(sp)              // a1 = panel index
        addiu   t8, t8, 0x0001              // t8++
        b       _loop
        addiu   t6, t6, 0x00BC              // t6 = next panel struct

        _end:
        jr      ra
        sll     t6, a1, 0x0002              // original line 2

        _training:
        // t7 - button mask
        // a0/0x0040(sp) - cursor object
        // s0 - panel index

        andi    t8, t7, 0x000F              // t8 = 0 if no C buttons are pressed
        beqz    t8, _end_training           // if no C buttons pressed, skip to end
        lui     t8, 0x8014
        lw      t8, 0x8898(t8)              // t8 = port index for CPU panel (either 0 or 1)
        li      a1, CharacterSelect.CSS_PLAYER_STRUCT_TRAINING
        bnezl   t8, pc() + 8                // if CPU is port 1, jump to next panel struct
        addiu   a1, a1, 0x00B8              // a1 = CPU panel struct

        sw      ra, 0x0004(sp)              // save ra in unused stack space
        sw      a1, 0x0008(sp)              // save CPU panel struct
        jal     CharacterSelect.check_image_press_
        lw      a1, 0x0018(a1)              // a1 = panel object
        beqz    v0, _end_training           // if not over the panel, skip
        lw      ra, 0x0004(sp)              // restore ra

        // otherwise, use the CPU port index going forward
        or      s0, t8, r0                  // s0 = CPU panel index
        lw      a1, 0x0008(sp)              // a1 = CPU panel struct
        sw      a1, 0x0024(sp)              // use CPU panel struct going forward

        _end_training:
        jr      ra
        or      a1, s0, r0
    }

    // @ Description
    // Holds value of model display per port
    // 0 = default, 1 = high poly, 2 = low poly
    model_display_for_port:
    dw 0, 0, 0, 0                           // set to default for p1 - p4

    // @ Description
    // Provides a way to force high/low poly models.
    scope force_hi_lo_poly_: {
        // character load
        OS.patch_start(0x53850, 0x800D8050)
        jal     force_hi_lo_poly_
        nop
        OS.patch_end()
        // vs pause lo/hi poly swap
        OS.patch_start(0x649C0, 0x800E91C0)
        jal     force_hi_lo_poly_._swap
        andi    a1, a1, 0x00FF              // original line 1
        OS.patch_end()

        // First apply universal model display setting
        li      t9, Toggles.entry_model_display
        lw      t9, 0x0004(t9)              // t9 = 1 if always high, 2 if always low, 0 if default
        bnezl   t9, pc() + 8                // if not set to default, use t9 as a0 (1 = high poly, 2 = low poly)
        or      a0, r0, t9                  // a0 = forced hi/lo

        // Next apply player specific model display setting
        lbu     t9, 0x000D(v0)              // t9 = player port
        li      t2, model_display_for_port
        sll     t9, t9, 0x0002              // t9 = offset to model display
        addu    t9, t2, t9                  // t9 = model display for port address
        lw      t9, 0x0000(t9)              // t9 = 1 if high, 2 if low, 0 if default
        bnezl   t9, pc() + 8                // if not set to default, use t9 as a0 (1 = high poly, 2 = low poly)
        or      a0, r0, t9                  // a0 = forced hi/lo

        sb      a0, 0x000F(v0)              // original line 1
        jr      ra
        sb      a0, 0x000E(v0)              // original line 2

        _swap:
        // First apply universal model display setting
        li      t6, Toggles.entry_model_display
        lw      t6, 0x0004(t6)              // t6 = 1 if always high, 2 if always low, 0 if default
        bnezl   t6, pc() + 8                // if not set to default, use t6 as a0 (1 = high poly, 2 = low poly)
        or      a1, r0, t6                  // a1 = forced hi/lo

        // Next apply player specific model display setting
        lbu     t6, 0x000D(s3)              // t6 = player port
        li      t7, model_display_for_port
        sll     t6, t6, 0x0002              // t6 = offset to model display
        addu    t6, t7, t6                  // t6 = model display for port address
        lw      t6, 0x0000(t6)              // t6 = 1 if high, 2 if low, 0 if default
        bnezl   t6, pc() + 8                // if not set to default, use t6 as a0 (1 = high poly, 2 = low poly)
        or      a1, r0, t6                  // a1 = forced hi/lo

        jr      ra
        or      s5, a0, r0                  // original line 2
    }

    // @ Description
    // Updates costume based on player struct
    // @ Arguments
    // a0 - 0x00008(player struct), ???
    // a1 - costume_id
    // a2 - shade_id
    constant update_(0x800E9248)

    // @ Description
    // Prevents illegal sound from playing when selecting the same costume
    scope prevent_illegal_sound_: {
        // Training - C buttons
        OS.patch_start(0x144C04, 0x80135624)
        // jal 0x80133350                       // original line - returns v0 as 1 if player and costume match
        lli     v0, 0x0000                      // force result to be 0 instead of checking
        OS.patch_end()

        // Training - C buttons
        OS.patch_start(0x141194, 0x80131BB4)
        // jal 0x80133350                       // original line - returns v0 as 1 if player and costume match
        lli     v0, 0x0000                      // force result to be 0 instead of checking
        OS.patch_end()

        // VS - C buttons
        OS.patch_start(0x12FF50, 0x80131CD0)
        // jal 0x80134674                       // original line - returns v0 as 1 if player and costume match
        lli     v0, 0x0000                      // force result to be 0 instead of checking
        OS.patch_end()
    }

    // @ Description
    // This allows multiple players to be the same color by bypassing the check.
    OS.patch_start(0x001361C8, 0x80137F48)
    b       0x80137F60
    OS.patch_end()

    // @ Description
    // Hook which allows for additional costumes by updating the palette array pointer for parts.
    scope check_for_custom_costume_: {
        OS.patch_start(0x44764, 0x800C8D84)
        jal     check_for_custom_costume_
        nop
        OS.patch_end()
        // initialize image index
        OS.patch_start(0x446C0, 0x800C8CE0)
        jal     check_for_custom_costume_._init_image_index
        sw      s0, 0x0028(sp)                   // original line 1
        OS.patch_end()

        // f20 - costume ID (float)
        // 0x0030(sp) or 0x0034(sp) - unique ID
        //   - 0x0030(sp) when 0x0030(sp) is not an address, 0x0034(sp) otherwise
        // s4 - part
        // 0x0004(s4) - player object
        // s0 - part texture info
        // 0x0038(s0) - (hw) bitmask that helps determine if there is a texture or not
        // if texture:
        //   0x0088(s0) - palette index
        //   0x0034(s0) - palette array
        // if no texture:
        //   0x0058(s0) - prim color

        lw      t0, 0x0004(s4)                  // t0 = player object, maybe
        lw      t7, 0x0000(t0)                  // t7 = 0x3E8 if player object
        addiu   t7, t7, -0x03E8                 // t7 = 0 if player object
        beqzl   t7, _get_character_id           // if player object, get player struct
        lw      t1, 0x0084(t0)                  // t1 = player struct

        // otherwise it's probably 0x3E9, and s5 is player struct
        or      t1, s5, r0                      // t1 = player struct

        _get_character_id:
        lw      t2, 0x0008(t1)                  // t2 = character ID

        li      t5, select_.num_costumes        // t5 = num_costumes
        addu    t5, t5, t2                      // t5 = address of character's original costume count
        lbu     t5, 0x0000(t5)                  // t5 = character's original costume count

        sll     t2, t2, 0x0002                  // t2 = offset in extra costume table
        li      t3, extra_costumes_table
        addu    t3, t3, t2                      // t3 = character extra costume table address
        lw      t3, 0x0000(t3)                  // t3 = character extra costume table, or 0 if none defined
        beqz    t3, _original_check             // if no extra costumes, skip
        nop

        trunc.w.s f4, f20                       // f4 = costume ID
        mfc1    t4, f4                          // t4 = costume ID
        lbu     t6, 0x0003(t3)                  // t6 = costumes to skip
        addu    t5, t5, t6                      // t5 = add skipped costumes to costume count
        addiu   t5, t5, 0x0001                  // t5 = index of first extra costume
        sltu    at, t4, t5                      // at = 0 if this is a new costume, 1 if an original
        bnez    at, _original_check             // if an original costume, skip
        lbu     at, 0x0000(t3)                  // at = number of extra costumes for this character
        addu    at, t5, at                      // at = max costume_id + 1
        sltu    at, t4, at                      // at = 1 if this is a valid costume, 0 if not
        beqz    at, _original_check             // if not a valid costume, skip
        nop

        // get the unique ID for this "image"
        lw      at, 0x003C(sp)                  // at = ra for routine hooked into
        li      t6, 0x800C8FD8                  // t6 = ra for when parts array is first initialized
        bnel    at, t6, _get_part_id            // if not initializing, then we can calculate from the array list
        addiu   t6, t1, 0x08F8                  // t6 = part array

        b       _get_images_array               // otherwise, it's in the stack already
        lw      t8, 0x0034(sp)                  // t8 = unique part ID

        _get_part_id:
        beqzl   t7, _loop                       // if not a special part with 0x3E9 as the object ID, skip to looping the parts array
        lli     t8, 0x0000                      // t8 = 0

        // if we're here, we are dealing with a special part
        lbu     t8, 0x0001(t3)                  // t8 = part ID
        lbu     t7, 0x0002(t3)                  // t7 = starting image index
        lw      t6, 0x0080(s4)                  // t6 = special part's first image index
        bnel    t6, s0, pc() + 8                // if the first image is not the special part, then it must be the second image (never more than 2)
        addiu   t7, t7, 0x0001                  // t7 = image index
        li      t6, image_index
        b       _get_images_array
        sh      t7, 0x0000(t6)                  // update image index

        _loop:
        sltiu   at, t8, 0x0025                  // at = 0 if we've gone too far (probably)
        beqz    at, _original_check             // if we can't find the part, let's abort
        lw      t7, 0x0000(t6)                  // t7 = address of part {t8}
        addiu   t6, t6, 0x0004                  // t6 = next part pointer
        bnel    t7, s4, _loop                   // if not the part, keep looping
        addiu   t8, t8, 0x0001                  // t8 = next part ID

        _get_images_array:
        sll     t8, t8, 0x0003                  // t8 = offset in extra costume table to part's images array
        addu    t3, t3, t8                      // t3 = extra costume table images array for part address

        li      t6, special_part_index          // t6 = special_part_index
        lh      t6, 0x0000(t6)                  // t6 = special part index, or -1 if not a special part
        blezl   t6, _get_image_info_array       // if not a special part, then get normal part images array
        lw      t3, 0x0000(t3)                  // t3 = extra costume table images array for part

        lw      t0, 0x0004(t3)                  // t0 = special parts array
        beqzl   t0, _get_image_info_array       // if no special parts array defined, use normal part images array
        lw      t3, 0x0000(t3)                  // t3 = extra costume table images array for part
        sll     t6, t6, 0x0002                  // t6 = offset to special part images array
        addu    t3, t0, t6                      // t3 = address of special part images array
        lw      t3, 0x0000(t3)                  // t3 = special part images array
        beqz    t3, _original_check             // if not defined, abort
        nop

        _get_image_info_array:
        li      t6, image_index                 // t6 = image_index
        lhu     t6, 0x0000(t6)                  // t6 = image index
        sll     t6, t6, 0x0004                  // t6 = offset in images array
        addu    t6, t3, t6                      // t6 = image's info array address

        subu    t5, t4, t5                      // t5 = costume index in extra costume arrays

        lhu     t0, 0x0038(s0)                  // t0 = type bitmask
        andi    at, t0, 0x0004                  // at = 0 if no texture

        beqz    at, _prim_color                 // if no textures, skip updating palette array
        nop

        // SAMUS FRIGGIN ARAN
        // Need to swap her lo poly 0x2_0 and 0x2_1 images
        lw      t2, 0x0008(t1)                  // t2 = character_id
        lli     at, Character.id.SAMUS
        beq     t2, at, _samus                  // if Samus, check if we need to swap with another image
        lli     at, Character.id.ESAMUS
        beq     t2, at, _samus                  // if E Samus, check if we need to swap with another image
        lli     at, Character.id.JSAMUS
        bne     t2, at, _palette                // if not J Samus, skip
        nop
        _samus:
        lbu     t2, 0x000E(t1)                  // t2 = 2 if lo poly
        lli     at, 0x0002                      // at = 2 (lo poly)
        bne     t2, at, _palette                // if not lo poly, skip
        srl     t8, t8, 0x0003                  // t8 = part ID
        bne     t8, at, _palette                // if not part 2, skip
        nop
        li      t2, special_part_index          // t2 = special_part_index
        lh      t2, 0x0000(t2)                  // t2 = special part index, or -1 if not a special part
        bgtz    t2, _palette                    // if a special part, skip
        nop
        li      t2, image_index                 // t2 = image_index
        lhu     t2, 0x0000(t2)                  // t2 = image index
        sltiu   at, t2, 0x0002                  // at = 1 if image 0 or image 1
        beqz    at, _palette                    // if not image 0 or 1, skip
        lli     at, 0x0010                      // at = +0x10
        bnezl   t2, pc() + 8                    // if image 1, then we go back one word instead of forward
        addiu   at, r0, -0x0010                 // at = -0x10
        addu    t6, t6, at                      // t6 = image's info array address, swapped

        _palette:
        mtc1    t5, f4                          // f4 = costume index in extra costume arrays
        cvt.s.w f4, f4                          // f4 = custume index in extra costume arrays (float)
        swc1    f4, 0x0088(s0)                  // update index
        lw      t3, 0x0000(t6)                  // t3 = image's palette array
        sw      t3, 0x0034(s0)                  // update palette array

        _prim_color:
        andi    at, t0, 0x0200                  // at = 0 if prim color
        beqz    at, _diffuse_ambient            // if not prim color, skip updating prim color
        nop

        lw      t3, 0x0004(t6)                  // t3 = image's prim color array
        sll     at, t5, 0x0002                  // at = offset in costume table array for part
        addu    t3, t3, at                      // t3 = part array for costume address
        lw      t3, 0x0000(t3)                  // t3 = part array for costume

        sw      t3, 0x0058(s0)                  //

        _diffuse_ambient:
        andi    at, t0, 0x3000                  // at = 0 if not diffuse/ambient
        beqz    at, _texture_array              // if not diffuse/ambient color, skip updating diffuse/ambient
        nop

        lw      t3, 0x000C(t6)                  // t3 = image's diffuse/ambient color array
        sll     at, t5, 0x0002                  // at = offset in costume table array for part
        addu    t3, t3, at                      // t3 = part array for costume address
        lw      t3, 0x0000(t3)                  // t3 = part array for costume

        // t3 = diffuse/ambient color array
        lw      t4, 0x0000(t3)                  // t4 = diffuse color
        sw      t4, 0x0068(s0)                  // override diffuse color
        lw      t4, 0x0004(t3)                  // t4 = ambient color
        sw      t4, 0x006C(s0)                  // override ambient color

        _texture_array:
        andi    at, t0, 0x0001                  // at = 0 if not texture array
        beqz    at, _original_check             // if not texture array, skip updating texture array
        nop

        lw      t3, 0x0008(t6)                  // t3 = image's texture array array
        sll     at, t5, 0x0002                  // at = offset in costume table array for part
        addu    t3, t3, at                      // t3 = part array for costume address
        lw      t3, 0x0000(t3)                  // t3 = part array for costume

        beqz    t3, _original_check             // if not defined, don't override
        nop
        lw      t4, 0x0000(t3)                  // t4 = texture array
        sw      t4, 0x000C(s0)                  // override texture array

        _original_check:
        beqz    a1, _end                        // modified original line 1 (original: bnez a1, 0x800C8D04)
        nop

        li      t0, image_index                 // t0 = image_index
        lhu     t1, 0x0000(t0)                  // t1 = image index
        addiu   t1, t1, 0x0001                  // image_index++
        sh      t1, 0x0000(t0)                  // update image index

        j       0x800C8D04                      // continue looping
        nop

        _end:
        jr      ra
        nop

        _init_image_index:
        li      t0, image_index                 // t0 = image_index
        sh      r0, 0x0000(t0)                  // reset image_index

        lw      t1, 0x003C(sp)                  // t1 = ra
        li      t0, 0x800E8D7C                  // t0 = ra from special part swap routine
        bnel    t0, t1, _set_special_part_index // if not coming from special part swap routine, then clear special part index
        lli     t2, 0xFFFF                      // t2 = -1 (no special part)

        // if here, then t2 is the special part index!

        _set_special_part_index:
        li      t0, special_part_index          // t0 = special_part_index
        sh      t2, 0x0000(t0)                  // update special part index

        jr      ra
        sdc1    f22, 0x0020(sp)                 // original line 2

        // Each part can have multiple images, so we update this to track it
        image_index:
        dh 0x0

        // Sometimes we'll be updating special parts, so we need this
        // Use -1 when not a special part
        special_part_index:
        dh 0xFFFF
    }

    // @ Description
    // Patch which overrides the icon palette array pointer when the character has additional costumes.
    // Runs when a character finishes loading.
    scope icon_palette_override_: {
        OS.patch_start(0x53090, 0x800D7890)
        sw      a0, 0x0018(sp)                  // store a0 (char_id)
        OS.patch_end()
        OS.patch_start(0x530A8, 0x800D78A8)
        j       icon_palette_override_
        nop
        OS.patch_end()

        lw      a0, 0x0018(sp)                  // a0 = character id
        addiu   sp, sp,-0x0010                  // allocate stack space

        sll     t0, a0, 0x0002                  // t0 = offset in extra costume table
        li      t3, extra_costumes_table
        addu    t3, t3, t0                      // t3 = character extra costume table address
        lw      t3, 0x0000(t3)                  // t3 = character extra costume table, or 0 if none defined
        beqz    t3, _end                        // if no extra costumes, skip
        nop
        li      t1, 0x80116E10                  // t1 = main character struct table
        addu    t1, t1, t0                      // t1 = pointer to character struct
        lw      t1, 0x0000(t1)                  // t1 = character struct
        lw      t2, 0x0028(t1)                  // t2 = main character file address pointer
        lw      t2, 0x0000(t2)                  // t2 = main character file address
        lw      t1, 0x0060(t1)                  // t1 = offset to attribute data
        addu    t1, t2, t1                      // t1 = attribute data address
        lw      t1, 0x0340(t1)                  // t1 = pointer to stock icon info
        lw      t2, 0x0004(t1)                  // t2 = original palette array address

        li      t5, select_.num_costumes        // t5 = num_costumes
        addu    t5, t5, a0                      // t5 = address of character's original costume count
        lbu     t5, 0x0000(t5)                  // t5 = character's original costume count
        lbu     t4, 0x0003(t3)                  // t3 = skipped costumes
        addu    t4, t4, t5                      // t4 = total costumes to copy, 0-based
        lw      t3, -0x0004(t3)                 // t3 = new palette array address
        sw      t3, 0x0004(t1)                  // override palette array address

        _loop:
        lw      t6, 0x0000(t2)                  // t6 = palette X pointer
        sw      t6, 0x0000(t3)                  // save pointer in new array
        addiu   t2, t2, 0x0004                  // t2 = next palette (original)
        addiu   t3, t3, 0x0004                  // t3 = next palette (new)
        bnezl   t4, _loop                       // if not done copying, loop
        addiu   t4, t4, -0x0001                 // t4--

        _end:
        lw      ra, 0x0024(sp)                  // restore ra
        jr      ra                              // original line 2
        addiu   sp, sp, 0x0028                  // deallocate stack space + original line 1
    }

    extra_costumes_table:
    constant EXTRA_COSTUMES_TABLE_ORIGIN(origin())
    fill Character.NUM_CHARACTERS * 4

    include "costumes/Mario.asm"
    include "costumes/Luigi.asm"
    include "costumes/DK.asm"
    include "costumes/Link.asm"
    include "costumes/Samus.asm"
    include "costumes/CaptainFalcon.asm"
    include "costumes/Ness.asm"
    include "costumes/Yoshi.asm"
    include "costumes/Kirby.asm"
    include "costumes/Fox.asm"
    include "costumes/Pikachu.asm"
    include "costumes/Jigglypuff.asm"

    // @ Description
    // Revises attribute location within main file to adjust for Polygon Characters and Metal Mario's new costumes

    // Polygon Mario
    pushvar origin, base
    origin 0x94490
    dw 0x000002B0
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NMARIO, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Fox
    pushvar origin, base
    origin 0x95A14
    dw 0x000002BC
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NFOX, 0, 1, 4, 5, 1, 3, 2)

    // Polygon DK
    pushvar origin, base
    origin 0x96FCC
    dw 0x000002B0
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NDONKEY, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Samus
    pushvar origin, base
    origin 0x98EF8
    dw 0x000003D4
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NSAMUS, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Luigi
    pushvar origin, base
    origin 0x9A310
    dw 0x000002B8
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NLUIGI, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Link
    pushvar origin, base
    origin 0x9B7F0
    dw 0x000002F0
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NLINK, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Yoshi
    pushvar origin, base
    origin 0x9CC70
    dw 0x000002D0
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NYOSHI, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Falcon
    pushvar origin, base
    origin 0x9E178
    dw 0x000002B4
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NCAPTAIN, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Kirby
    pushvar origin, base
    origin 0x9FADC
    dw 0x000002D8
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NKIRBY, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Pikachu
    pushvar origin, base
    origin 0xA0F8C
    dw 0x000002C0
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NPIKACHU, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Jigglypuff
    pushvar origin, base
    origin 0xA242C
    dw 0x000002B8
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NJIGGLY, 0, 1, 4, 5, 1, 3, 2)

    // Polygon Ness
    pushvar origin, base
    origin 0xA39D0
    dw 0x00000308
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.NNESS, 0, 1, 4, 5, 1, 3, 2)

    // Metal Mario
    pushvar origin, base
    origin 0x93A80
    dw 0x000002BC
    pullvar base, origin

    // Set default costumes
    Character.set_default_costumes(Character.id.METAL, 0, 1, 4, 5, 1, 3, 2)



} // __COSTUMES__
