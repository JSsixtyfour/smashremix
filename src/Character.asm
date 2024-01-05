// Character.asm
// By Fray
if !{defined __CHARACTER__} {
define __CHARACTER__()
print "included Character.asm\n"

// @ Description
// This file contains setup, constants, and functions for existing and additional characters.

include "Global.asm"
include "OS.asm"

scope Character {
    // number of character slots to add
    constant ADD_CHARACTERS(61)
    // start and end offset for the main character struct table (RAM 0x80116E10)
    constant STRUCT_TABLE(0x92610)
    variable STRUCT_TABLE_END(STRUCT_TABLE + 0x6C)
    // original action array table
    constant ACTION_ARRAY_TABLE_ORIGINAL(0xA6F40)
    // shared action array
    constant SHARED_ACTION_ARRAY(0xA45D8)

    // total number of character slots (note 0x1B and 0x1C will be unused)
    constant NUM_CHARACTERS(27 + 2 + ADD_CHARACTERS)
	variable NUM_REMIX_FIGHTERS(0)	// Will be updated by define_character
	variable NUM_POLYGONS(0)	    // ~
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// CHARACTER MACRO ///////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // @ Description
    // defines constants for existing characters so we can use macros
    macro define_character(name) {
        read32 {name}_character_struct_ptr, "../roms/original.z64", (STRUCT_TABLE + (id.{name} * 0x4))
        constant {name}_character_struct({name}_character_struct_ptr - 0x80084800)

        read32 {name}_param_array, "../roms/original.z64", ({name}_character_struct + 0x64)
        read32 {name}_param_array_size, "../roms/original.z64", ({name}_character_struct + 0x6C)
        global evaluate {name}_param_array_origin({name}_param_array - 0x80084800)

        read32 {name}_menu_array, "../roms/original.z64", ({name}_character_struct + 0x68)
        global evaluate {name}_menu_array_origin({name}_menu_array - 0x80288A20)

        read32 {name}_action_array, "../roms/original.z64", (ACTION_ARRAY_TABLE_ORIGINAL + (id.{name} * 0x4))
        global evaluate {name}_action_array_origin({name}_action_array - 0x80084800)
    }

    // @ Description
    // adds a new character
    macro define_character(name, parent, file_1, file_2, file_3, file_4, file_5, file_6, file_7, file_8, file_9, attrib_offset, add_actions, bool_jab_3, bool_inhale_copy, btt_stage_id, btp_stage_id, remix_btt_stage_id, remix_btp_stage_id, sound_type, variant_type) {
    if id.{parent} > 0xB {
        print "CHARACTER: {name} NOT CREATED. UNSUPPORTED PARENT. \n"
    } else {
        // CONSTANTS //////////////////////////////////////////////////////////////////////////////
        // Get struct pointer and ROM offset of {parent}
        read32 {name}_parent_struct_ptr, "../roms/original.z64", (STRUCT_TABLE + (id.{parent} * 0x4))
        constant {name}_parent_struct({name}_parent_struct_ptr - 0x80084800)

        // Get parameter array pointer, size, and ROM offset of {parent}
        read32 {name}_parent_param_array_ptr, "../roms/original.z64", ({name}_parent_struct + 0x64)
        read32 {name}_parent_param_array_size, "../roms/original.z64", ({name}_parent_struct + 0x6C)
        constant {name}_parent_param_array({name}_parent_param_array_ptr - 0x80084800)

        // Get menu array pointer and ROM offset of {parent}
        read32 {name}_parent_menu_array_ptr, "../roms/original.z64", ({name}_parent_struct + 0x68)
        constant {name}_parent_menu_array({name}_parent_menu_array_ptr - 0x80288A20)

        // Get action array pointer and ROM offset of {parent}
        read32 {name}_parent_action_array_ptr, "../roms/original.z64", (ACTION_ARRAY_TABLE_ORIGINAL + (id.{parent} * 0x4))
        global evaluate {name}_parent_action_array({name}_parent_action_array_ptr - 0x80084800)

        // Action parameter array size
        constant {name}_param_array_size({name}_parent_param_array_size + {add_actions})

        // CHARACTER ID
        constant id.{name}((STRUCT_TABLE_END - STRUCT_TABLE) / 0x4)

        // Parent character name
        global define {name}_parent({parent})

        // Number of new action slots
        constant {name}_NEW_ACTION_SLOTS({add_actions})

        // Print message
        print "Added Character: {name} \n"
        print "{name} ID: 0x" ; OS.print_hex(id.{name}) ; print "\n"

        // FILE POINTERS //////////////////////////////////////////////////////////////////////////
        OS.align(16)
        {name}_file_table:
        variable file_table_end({name}_file_table)
        dw  OS.NULL
        dw  OS.NULL
        dw  OS.NULL
        dw  OS.NULL
        dw  OS.NULL
        dw  OS.NULL
        dw  OS.NULL
        dw  OS.NULL

        // CHARACTER STRUCT ///////////////////////////////////////////////////////////////////////
        OS.align(16)
        {name}_character_struct:
        global evaluate {name}_character_struct_origin(origin())
        // 0x00 - file 1 ID (main file)
        dw  {file_1}
        // 0x04 - file 2 ID (primary moveset)
        dw  {file_2}
        // 0x08 - file 3 ID (secondary moveset)
        dw  {file_3}
        // 0x0C - file 4 ID (character/model file)
        dw  {file_4}
        // 0x10 - file 5 ID (shield pose)
        dw  {file_5}
        // note: miscellaneous files are used for things like entry animation, projectile data and
        // special graphics, but seemingly not with a fixed structure
        // 0x14 - file 6 ID (miscellaneous)
        dw  {file_6}
        // 0x18 - file 7 ID (miscellaneous)
        dw  {file_7}
        // 0x1C - file 8 ID (miscellaneous)
        dw  {file_8}
        // 0x20 - file 9 ID (miscellaneous)
        dw  {file_9}
        // 0x24 - character segment size (auto generated)
        dw  0
        // 0x28 - file 1 pointer address
        if {file_1} != 0 { ; dw file_table_end ; constant {name}_file_1_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        // 0x2C - file 2 pointer address
        if {file_2} != 0 { ; dw file_table_end ; constant {name}_file_2_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        // 0x30 - file 3 pointer address
        if {file_3} != 0 { ; dw file_table_end ; constant {name}_file_3_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        // 0x34 - file 4 pointer address
        if {file_4} != 0 { ; dw file_table_end ; constant {name}_file_4_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        dw  OS.NULL                         // 0x38 - file 5 pointer (auto generated)
        // 0x3C - file 6 pointer address
        if {file_6} != 0 { ; dw file_table_end ; constant {name}_file_6_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        // 0x40 - file 7 pointer address
        if {file_7} != 0 { ; dw file_table_end ; constant {name}_file_7_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        // 0x44 - file 8 pointer address
        if {file_8} != 0 { ; dw file_table_end ; constant {name}_file_8_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        // 0x48 - file 9 pointer address
        if {file_9} != 0 { ; dw file_table_end ; constant {name}_file_9_ptr(file_table_end) ; variable file_table_end(file_table_end + 0x4)
        } else { ; dw OS.NULL
        }
        // parameter 0x4C is a pointer to the special sprite index related to GFX for Yoshi (egg explosion), Kirby (rock start/end) and Ness (pk fire connect item flame)
        // ...it is safe to be copied from the parent character
        OS.copy_segment(({name}_parent_struct + 0x4C), 0x4)
        // parameters 0x50, 0x54, 0x58 and 0x5C are ROM offsets related to GFX for Yoshi (egg explosion), Kirby (rock start/end) and Ness (pk fire connect item flame)
        // ...they only apply if we are doing a regional variant, otherwise we likely don't use the GFX
        if ({variant_type} == variant_type.J || {variant_type} == variant_type.E) {
            OS.copy_segment(({name}_parent_struct + 0x50), 0x10)
        } else {
            dw 0, 0, 0, 0
        }
        // 0x60 - attribute data offset
        dw  {attrib_offset}
        // 0x64 - action parameter array address
        dw  {name}_param_array
        // 0x68 - menu action array address
        dw  {name}_menu_array
        // 0x6C - action parameter array size
        dw  {name}_param_array_size
        // 0x70 - menu array size address
        dw  {name}_menu_array_size
        // 0x74 - animation segment size (auto generated)
        dw  0
        OS.align(16)

        // DEFINE ACTION PARAMETER ARRAY ////////////////////////////////////////////////////////
        {name}_param_array:
        global evaluate {name}_param_array_origin(origin())
        // copy array from parent character
        OS.copy_segment({name}_parent_param_array, ({name}_parent_param_array_size * 0xC))
        fill ({name}_param_array + ({name}_param_array_size * 0xC)) - pc()
        OS.align(16)

        // DEFINE ACTION ARRAY ////////////////////////////////////////////////////////////////////
        {name}_action_array:
        global evaluate {name}_action_array_origin(origin())
        // copy array from parent character

        OS.copy_segment({{name}_parent_action_array}, action_array_size.{parent})
        fill ({name}_action_array + (action_array_size.{parent} + ({add_actions} * 0x14))) - pc()
        OS.align(16)

        // DEFINE MENU ARRAY //////////////////////////////////////////////////////////////////////
        {name}_menu_array:
        global evaluate {name}_menu_array_origin(origin())
        // copy array from parent character (fixed size of 15 actions)
        OS.copy_segment({name}_parent_menu_array, 0xF * 0xC)
        {name}_menu_array_size:
        dw  0xF

        // ADD CHARACTER //////////////////////////////////////////////////////////////////////////
        pushvar origin, base

        // Add the character to STRUCT_TABLE and update STRUCT_TABLE_END
        origin  STRUCT_TABLE_END
        dw      {name}_character_struct
        global variable STRUCT_TABLE_END(origin())

        // Add {name}_action_array to ACTION_ARRAY_TABLE
        origin  ACTION_ARRAY_TABLE_ORIGIN + (id.{name} * 0x4)
        dw      {name}_action_array

        // JAB 3 AND RAPID JAB ////////////////////////////////////////////////////////////////////
        // Add {name} to new jab_3 and rapid_jab tables
        origin jab_3.TABLE_ORIGIN + (id.{name} * 0x4)
        if id.{parent} == id.MARIO || id.{parent} == id.LUIGI || id.{parent} == id.LINK || id.{parent} == id.CAPTAIN || id.{parent} == id.NESS {
            dw jab_3.ENABLED
        } else {
            dw jab_3.DISABLED
        }
        origin rapid_jab.TABLE_ORIGIN + (id.{name} * 0x4)
        if id.{parent} == id.FOX || id.{parent} == id.LINK || id.{parent} == id.CAPTAIN || id.{parent} == id.KIRBY || id.{parent} == id.JIGGLY {
            dw rapid_jab.ENABLED
        } else {
            dw rapid_jab.DISABLED
        }
        // Copy third jab settings from parent character if {bool_jab_3} = TRUE, disable otherwise
        add_to_jab_3_table(jab_3_timer, id.{name}, id.{parent}, {bool_jab_3})
        add_to_jab_3_table(jab_3_action, id.{name}, id.{parent}, {bool_jab_3})
        add_to_rapid_jab_table(rapid_jab_begin_action, id.{name}, id.{parent}, {bool_jab_3})
        add_to_rapid_jab_table(rapid_jab_loop_action, id.{name}, id.{parent}, {bool_jab_3})
        add_to_rapid_jab_table(rapid_jab_ending_action, id.{name}, id.{parent}, {bool_jab_3})
        add_to_rapid_jab_table(rapid_jab_unknown, id.{name}, id.{parent}, {bool_jab_3})

        // SPECIAL MOVES //////////////////////////////////////////////////////////////////////////
        // Copy special move subroutine pointers from parent character
        add_to_table(kirby_air_nsp, id.{name}, id.{parent}, 0x4)
        add_to_table(air_nsp, id.{name}, id.{parent}, 0x4)
        add_to_table(air_usp, id.{name}, id.{parent}, 0x4)
        add_to_table(air_dsp, id.{name}, id.{parent}, 0x4)
        add_to_table(kirby_ground_nsp, id.{name}, id.{parent}, 0x4)
        add_to_table(ground_nsp, id.{name}, id.{parent}, 0x4)
        add_to_table(ground_usp, id.{name}, id.{parent}, 0x4)
        add_to_table(ground_dsp, id.{name}, id.{parent}, 0x4)

        // ENTRY ANIMATION ////////////////////////////////////////////////////////////////////////
        // Copy entry animation settings from parent character
        add_to_table(entry_script, id.{name}, id.{parent}, 0x4)
        add_to_table(entry_action, id.{name}, id.{parent}, 0x8)

        // OTHER //////////////////////////////////////////////////////////////////////////////////
        // Copy parent character for other tables
        add_to_table(initial_script, id.{name}, id.{parent}, 0x4)
        add_to_table(grounded_script, id.{name}, id.{parent}, 0x4)
        add_to_table(electric_hit, id.{name}, id.{parent}, 0x4)
        add_to_table(down_bound_fgm, id.{name}, id.{parent}, 0x2)
        add_to_table(crowd_chant_fgm, id.{name}, id.{parent}, 0x2)
        add_to_table(yoshi_egg, id.{name}, id.{parent}, 0x1C)
        add_to_table(ai_behaviour, id.{name}, id.{parent}, 0x4)
        add_to_table(ai_attack_prevent, id.{name}, id.{parent}, 0x4)
        add_to_table(ai_aerial_chase, id.{name}, id.{parent}, 0x4)
        add_to_table(ai_long_range, id.{name}, id.{parent}, 0x4)

        // Copy parent character for menu tables
        add_to_table(menu_zoom, id.{name}, id.{parent}, 0x4)
        add_to_table(default_costume, id.{name}, id.{parent}, 0x8)
        add_to_id_table(variant_original, id.{name}, id.{parent})
        add_to_id_table(vs_record, id.{name}, id.{parent})
        add_to_table(winner_fgm, id.{name}, id.{parent}, 0x4)
        add_to_id_table(label_height, id.{name}, id.{parent})
        add_to_table(str_wins_lx, id.{name}, id.{parent}, 0x4)
        add_to_table(str_winner_ptr, id.{name}, id.{parent}, 0x4)
        add_to_table(str_winner_lx, id.{name}, id.{parent}, 0x4)
        add_to_table(str_winner_scale, id.{name}, id.{parent}, 0x4)
        add_to_table(winner_bgm, id.{name}, id.{parent}, 0x4)
        add_to_id_table(singleplayer_vs_preview, id.{name}, id.{parent})
        // gfx routine end table
        origin gfx_routine_end.TABLE_ORIGIN + (id.{name} * 0x4)
        if id.{parent} > id.FOX {
            OS.copy_segment(gfx_routine_end.ORIGINAL_TABLE + ((id.{parent} - 2) * 0x4), 0x4)
        } else {
            dw gfx_routine_end.DISABLED
        }

        // Copy parent character for projectile tables
        add_to_table(fireball, id.{name}, id.{parent}, 0x4)
        add_to_table(kirby_fireball, id.{name}, id.{parent}, 0x4)

        // Add parent ID to ID override tables
        add_to_id_table(thrown_hitbox, id.{name}, id.{parent})
        add_to_id_table(f_thrown_action, id.{name}, id.{parent})
        add_to_id_table(b_thrown_action, id.{name}, id.{parent})
        add_to_id_table(falcon_dive_id, id.{name}, id.{parent})

        // update Kirby inhale table
        origin kirby_inhale_struct.TABLE_ORIGIN + (id.{name} * 0xC)
        if {bool_inhale_copy} == OS.TRUE {
            dh      id.{name}
            dh      kirby_hat_id.{parent}
        } else {
            dh      id.KIRBY                 // KIRBY ID used to disable copy
            dh      kirby_hat_id.NONE
        }
        dw      kirby_inhale_struct.star_scale.{parent}
        dw      kirby_inhale_struct.star_damage.DEFAULT

        // update bonus stage tables
        origin BTT_TABLE_ORIGIN + id.{name}
        db      {btt_stage_id}
        origin BTP_TABLE_ORIGIN + id.{name}
        db      {btp_stage_id}

        // update remix bonus stage tables
        origin REMIX_BTT_TABLE_ORIGIN + id.{name}
        db      {remix_btt_stage_id}
        origin REMIX_BTP_TABLE_ORIGIN + id.{name}
        db      {remix_btp_stage_id}

        // update sound type table
        table_patch_start(sound_type, id.{name}, 0x1)
        db      {sound_type}
        OS.patch_end()

        // update variant type table
        table_patch_start(variant_type, id.{name}, 0x1)
        db      {variant_type}
        OS.patch_end()

        // update shield costume table
        table_patch_start(costume_shield_color, id.{name}, 0x4)
        dw      costume_shield_color.{parent} // default to parent
        OS.patch_end()

		// Handle Polygons
		if {variant_type} == variant_type.POLYGON {
			// Set Kirby hat_id to none
			Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.{name}, 0xC)
			dh 0x08
			OS.patch_end()
			global variable NUM_POLYGONS(NUM_POLYGONS + 1)
		}

		if {variant_type} == variant_type.NA {
			global variable NUM_REMIX_FIGHTERS(NUM_REMIX_FIGHTERS + 1)
		}

        pullvar base, origin
    }
    }

    // @ Description
    // Copies the GFX parameters (0x4C - 0x5C) from a specified parent character.
    macro copy_gfx_parameters(name, parent) {
        if id.{parent} > 0xB {
        print "CHARACTER: {name} NOT CREATED. UNSUPPORTED PARENT. \n"
    } else {
        // Get struct pointer and ROM offset of {parent}
        read32 {name}_gfx_parent_struct_ptr, "../roms/original.z64", (STRUCT_TABLE + (id.{parent} * 0x4))
        constant {name}_gfx_parent_struct({name}_gfx_parent_struct_ptr - 0x80084800)

        // copy parameters from parent
        pushvar origin, base
        origin {{name}_character_struct_origin} + 0x4C
        OS.copy_segment(({name}_gfx_parent_struct + 0x4C), 0x14)
        pullvar base, origin
    }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// OTHER MACROS ////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // @ Description
    // modifies parameters for an action (animation id, command list offset, flags)
    // NOTE: this macro supports use outside of this file.
    macro edit_action_parameters(name, action, animation, command, flags) {
    if {action} >= 0xDC && ({action} - 0xDC) * 0x14 >= Character.action_array_size.{Character.{name}_parent} {
        print "\n\nWARNING: Action 0x" ; OS.print_hex({action}) ; print " does not exist for {{name}_parent}. edit_action_parameters aborted.\n"
    } else {
        // Define {num} (used to avoid constant declaration issues with read16)
        if !{defined num} {
            evaluate num(0)
        }
        // Get ROM offset for parent action struct
        if {action} >= 0xDC {
            variable PARENT_ACTION_STRUCT({Character.{name}_parent_action_array} + (({action} - 0xDC) * 0x14))
        } else {
            variable PARENT_ACTION_STRUCT(Character.SHARED_ACTION_ARRAY + ({action} * 0x14))
        }

        // Get offset for parameter struct
        global evaluate num({num} + 1)
        read16 param_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT
        variable param_offset(param_read_{num} >> 6)

        // Check for no parameters
        if param_offset == 0x3FF {
            print "\n\nWARNING: Action parameters do not exist for character: {name} action: {action} (0x" ; OS.print_hex({action}) ; print "). edit_action_parameters aborted.\n"
        } else {
        // Modify parameter struct
        pushvar origin, base
        origin {Character.{name}_param_array_origin} + (param_offset * 0xC)
        if {animation} != -1 {
            dw {animation}                  // insert animation
        } else {; origin origin() + 0x4; }
        if {command} != -1 {
            dw {command}                    // insert command offset
        } else {; origin origin() + 0x4; }
        if {flags} != -1 {
            dw {flags}                      // insert flags
        }
        pullvar base, origin
        }
    }
    }

    // @ Description
    // modifies parameters for a menu action (animation id, command list offset, flags)
    // NOTE: this macro supports use outside of this file.
    macro edit_menu_action_parameters(name, action, animation, command, flags) {
    if {action} > 0xF {
        print "\n\nWARNING: Menu Action 0x" ; OS.print_hex({action}) ; print " is unsupported. edit_menu_action_parameters aborted.\n"
    } else {
        // Modify menu parameter struct
        pushvar origin, base
        origin {Character.{name}_menu_array_origin} + ({action} * 0xC)
        if {animation} != -1 {
            dw {animation}                  // insert animation
        } else {; origin origin() + 0x4; }
        if {command} != -1 {
            dw {command}                    // insert command offset
        } else {; origin origin() + 0x4; }
        if {flags} != -1 {
            dw {flags}                      // insert flags
        }
        pullvar base, origin
    }
    }

    // @ Description
    // modifies staling ID and assembly subroutines for an action
    // NOTE: this macro supports use outside of this file.
    macro edit_action(name, action, staling, asm1, asm2, asm3, asm4) {
    if {action} < 0xDC {
        print "\n\nWARNING: Action 0x" ; OS.print_hex({action}) ; print " is a shared action and cannot be modified. edit_action aborted.\n"
    } else if {staling} > 0x3F {
        print "\n\n WARNING: UNSUPPORTED STALING ID! Max Staling ID = 0x3F. edit_action aborted.\n"
    } else {
        // Define {num} (used to avoid constant declaration issues with read16)
        if !{defined num} {
            evaluate num(0)
        }
        // Get ROM offset for parent action struct
        variable PARENT_ACTION_STRUCT({Character.{name}_parent_action_array} + (({action} - 0xDC) * 0x14))

        // Get offset for parameter struct
        global evaluate num({num} + 1)
        read16 param_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT
        variable param_offset(param_read_{num} >> 6)

        // Modify action struct
        pushvar origin, base
        origin {Character.{name}_action_array_origin} + (({action} - 0xDC) * 0x14)
        if {staling} != -1 {
            dh (param_offset << 6) | {staling} // insert staling ID
            origin origin() + 0x2
        } else {; origin origin() + 0x4; }
        if {asm1} != -1 {
            dw {asm1}                       // insert subroutine (main)
        } else {; origin origin() + 0x4; }
        if {asm2} != -1 {
            dw {asm2}                       // insert subroutine (interruptibility/other)
        } else {; origin origin() + 0x4; }
        if {asm3} != -1 {
            dw {asm3}                       // insert subroutine (movement/physics)
        } else {; origin origin() + 0x4; }
        if {asm4} != -1 {
            dw {asm4}                       // insert subroutine (collision)
        }
        pullvar base, origin
    }
    }

    // @ Description
    // adds new action parameters for a character
    // NOTE: this macro supports use outside of this file, and use with KIRBY
    macro add_new_action_params(name, action_name, action_copy, animation, command, flags) {
        if !{defined {name}_new_params} {
            global evaluate {name}_new_params(0)
        }
        if Character.{name}_NEW_ACTION_SLOTS <= {{name}_new_params} {
            print "\n\nWARNING: NOT ENOUGH ACTION SLOTS! {name} does not have enough action slots to support adding parameters for {action_name}. Please increase the number of new actions for this character.\n"
        }
        // Copy from base action if one is given
        if {action_copy} != -1 {
            // Define {num} (used to avoid constant declaration issues with read16/read32)
            if !{defined num} {
                evaluate num(0)
            }
            // Get ROM offset for parent action struct
            if Character.id.{name} == Character.id.KIRBY {
                variable PARENT_ACTION_STRUCT({Character.KIRBY_original_action_array} + (({action_copy} - 0xDC) * 0x14))
            } else {
                variable PARENT_ACTION_STRUCT({Character.{name}_parent_action_array} + (({action_copy} - 0xDC) * 0x14))
            }
            // Get param_offset from {action_copy}
            global evaluate num({num} + 1)
            read16 param_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT
            variable param_offset(param_read_{num} >> 6)

            // Get ROM offset for parent parameter struct
            if Character.id.{name} == Character.id.KIRBY {
                variable PARENT_PARAM_STRUCT(Character.KIRBY_original_param_array + (param_offset * 0xC))
            } else {
                variable PARENT_PARAM_STRUCT(Character.{name}_parent_param_array + (param_offset * 0xC))
            }
            // Read values from original struct
            read32 animation_read_{num}, "../roms/original.z64", PARENT_PARAM_STRUCT + 0x0
            read32 command_read_{num}, "../roms/original.z64", PARENT_PARAM_STRUCT + 0x4
            read32 flags_read_{num}, "../roms/original.z64", PARENT_PARAM_STRUCT + 0x8
             // Copy parameters from {action_copy} when not defined
            if {animation} == -1 {
                evaluate animation(animation_read_{num})
            }; if {command} == -1 {
                evaluate command(command_read_{num})
            }; if {flags} == -1 {
                evaluate flags(flags_read_{num})
            }
        }

        // Get original parameter array size.
        if Character.id.{name} == Character.id.KIRBY {
                variable array_size(Character.KIRBY_original_param_array_size)
            } else {
                variable array_size(Character.{name}_parent_param_array_size)
        }

        // Get ID for new parameter struct
        constant ActionParams.{action_name}(array_size + {{name}_new_params})
        // Write new parameter struct
        pushvar origin, base
        origin {Character.{name}_param_array_origin} + (ActionParams.{action_name} * 0xC)
        if {animation} != -1 {
            dw {animation}                  // insert animation
        } else {; origin origin() + 0x4; }
        if {command} != -1 {
            dw {command}                    // insert command offset
        } else {; origin origin() + 0x4; }
        if {flags} != -1 {
            dw {flags}                      // insert flags
        }
        pullvar base, origin

        // Increment {name}_new_params
        global evaluate {name}_new_params({{name}_new_params} + 1)
    }

    // @ Description
    // adds a new action for a character
    // NOTE: this macro supports use outside of this file, and use with KIRBY
    macro add_new_action(name, action_name, action_copy, parameters_id, staling, asm1, asm2, asm3, asm4) {
    if !{defined {name}_new_actions} {
        global evaluate {name}_new_actions(0)
    }
    if {staling} > 0x3F {
        print "\n\n WARNING: UNSUPPORTED STALING ID! Max Staling ID = 0x3F. Error in add_new_action ({action_name}).\n"
    }
    if Character.{name}_NEW_ACTION_SLOTS <= {{name}_new_actions} {
            print "\n\nWARNING: NOT ENOUGH ACTION SLOTS! {name} does not have enough action slots to support adding action {action_name}. Please increase the number of new actions for this character.\n"
    }
        // Copy from base action if one is given
        if {action_copy} != -1 {
            // Define {num} (used to avoid constant declaration issues with read16/read32)
            if !{defined num} {
                evaluate num(0)
            }
            // Get ROM offset for parent action struct
            if Character.id.{name} == Character.id.KIRBY {
                variable PARENT_ACTION_STRUCT({Character.KIRBY_original_action_array} + (({action_copy} - 0xDC) * 0x14))
            } else {
                variable PARENT_ACTION_STRUCT({Character.{name}_parent_action_array} + (({action_copy} - 0xDC) * 0x14))
            }

            // Read values from original struct
            global evaluate num({num} + 1)
            read16 param_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT
            read16 unknown_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT + 0x2
            read32 asm1_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT + 0x4
            read32 asm2_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT + 0x8
            read32 asm3_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT + 0xC
            read32 asm4_read_{num}, "../roms/original.z64", PARENT_ACTION_STRUCT + 0x10

            // Copy param_offset from {action_copy}
            variable param_offset(param_read_{num} >> 6)
            // Copy staling from {action_copy} if not defined
            if {staling} == -1 {
                evaluate staling(param_read_{num} & 0x3F)
            }
            // Copy unknown from {action_copy}
            evaluate unknown(unknown_read_{num})
            // Copy asm from {action_copy} when not defined
            if {asm1} == -1 {
                evaluate asm1(asm1_read_{num})
            }; if {asm2} == -1 {
                evaluate asm2(asm2_read_{num})
            }; if {asm3} == -1 {
                evaluate asm3(asm3_read_{num})
            }; if {asm4} == -1 {
                evaluate asm4(asm4_read_{num})
            }
        } else {
            // Set these values if a base action is not given
            evaluate unknown(0)
            variable param_offset(0x3FF)
        }

        // Get ID for new action.
        if Character.id.{name} == Character.id.KIRBY {
            constant Action.{action_name}((Character.action_array_size.KIRBY / 0x14) + {{name}_new_actions} + 0xDC)
        } else {
            constant Action.{action_name}((Character.action_array_size.{Character.{name}_parent} / 0x14) + {{name}_new_actions} + 0xDC)
        }
        // Set staling ID to 0 if not defined at this point.
        if {staling} == -1 {
            evaluate staling(0)
        }
        // Set param_offset if {parameters_id} is defined.
        if {parameters_id} != -1 {
            variable param_offset({parameters_id})
        }
        // Write new action struct.
        pushvar origin, base
        origin {Character.{name}_action_array_origin} + ((Action.{action_name} - 0xDC) * 0x14)
        dh (param_offset << 6) | {staling}  // insert parameter offset and staling ID
        dh {unknown}                        // insert unknown value
        if {asm1} != -1 {
            dw {asm1}                       // insert subroutine (main)
        } else {; origin origin() + 0x4; }
        if {asm2} != -1 {
            dw {asm2}                       // insert subroutine (interruptibility/other)
        } else {; origin origin() + 0x4; }
        if {asm3} != -1 {
            dw {asm3}                       // insert subroutine (movement/physics)
        } else {; origin origin() + 0x4; }
        if {asm4} != -1 {
            dw {asm4}                       // insert subroutine (collision)
        }
        pullvar base, origin

        // Increment {name}_new_actions
        global evaluate {name}_new_actions({{name}_new_actions} + 1)
    }


    // @ Description
    // Copies menu actions from a base character to a target character.
    // base - character to copy actions from
    // target - character to copy actions to
    // begin_action - action to begin copying from
    // num_actions - number of actions to copy
    macro copy_menu_actions(base, target, begin_action, num_actions) {
        // Get struct pointer and ROM offset of {base}
        if !{defined {base}_struct} {
            read32 {base}_struct_ptr, "../roms/original.z64", (STRUCT_TABLE + (id.{base} * 0x4))
            global evaluate {base}_struct({base}_struct_ptr - 0x80084800)
        }
        // Get menu array pointer and ROM offset of {base}
        if !{defined {base}_menu_array} {
            read32 {base}_menu_array_ptr, "../roms/original.z64", ({{base}_struct} + 0x68)
            global evaluate {base}_menu_array({base}_menu_array_ptr - 0x80288A20)
        }

        // Get struct pointer and ROM offset of {target}
        if !{defined {target}_struct} {
            read32 {target}_struct_ptr, "../roms/original.z64", (STRUCT_TABLE + (id.{target} * 0x4))
            global evaluate {target}_struct({target}_struct_ptr - 0x80084800)
        }
        // Get menu array pointer and ROM offset of {target}
        if !{defined {target}_menu_array} {
            read32 {target}_menu_array_ptr, "../roms/original.z64", ({{target}_struct} + 0x68)
            global evaluate {target}_menu_array({target}_menu_array_ptr - 0x80288A20)
        }

        // Get menu array size of {target}
        if !{defined {target}_menu_array_size} {
            read32 {target}_menu_array_size_ptr, "../roms/original.z64", ({{target}_struct} + 0x70)
            global evaluate {target}_menu_array_size({target}_menu_array_size_ptr - 0x80288A20)
            read32 {target}_menu_array_size_value, "../roms/original.z64", {{target}_menu_array_size}

            if {target}_menu_array_size_value < ({begin_action} + {num_actions})  {
                read32 {target}_menu_array_ptr2, "../roms/original.z64", ({{target}_struct} + 0x68)
                global define {target}_menu_array_vanilla({target}_menu_array_ptr2 - 0x80288A20)

                // We need to create the array
                {target}_menu_array_ptr_new:
                global evaluate {target}_menu_array(origin())
                global evaluate {target}_menu_array_origin(origin()) // need this to override define_character
                OS.copy_segment({{target}_menu_array_vanilla}, {target}_menu_array_size_value * 0xC) // copy all actions from original array
                fill (({begin_action} + {num_actions}) - {target}_menu_array_size_value) * 0xC

                pushvar origin, base
                origin {{target}_struct} + 0x68
                dw {target}_menu_array_ptr_new
                pullvar base, origin
            }
        }

        // Copy actions
        pushvar origin, base
        origin {{target}_menu_array} + ({begin_action} * 0xC)
        OS.copy_segment({{base}_menu_array} + ({begin_action} * 0xC), {num_actions} * 0xC)
        pullvar base, origin
    }

    // @ Description
    // begins a patch in a character id based table, use OS.patch_end() to end
    // NOTE: this macro supports use outside of this file.
    macro table_patch_start(table_name, id, entry_size) {
        pushvar origin, base
        origin  Character.{table_name}.TABLE_ORIGIN + ({id} * {entry_size})
    }

    // @ Description
    // begins a patch in a character id based table, use OS.patch_end() to end
    // NOTE: this macro supports use outside of this file.
    macro table_patch_start(table_name, offset, id, entry_size) {
        pushvar origin, base
        origin  Character.{table_name}.TABLE_ORIGIN + {offset} + ({id} * {entry_size})
    }

    // @ Description
    // adds default costume ids to a character
    // NOTE: this macro supports use outside of this file.
    // @ Arguments
    // id - character id to modify costumes for
    // costume_1 - default costume, c-up
    // costume_2 - second costume, c-right
    // costume_3 - third costume, c-down
    // costume_4 - fourth costume, c-left
    // red_team - red team costume
    // blue_team - blue team costume
    // green_team - green team costume
    macro set_default_costumes(id, costume_1, costume_2, costume_3, costume_4, red_team, blue_team, green_team) {
        Character.table_patch_start(default_costume, {id}, 0x8)
        // write costume ids
        db  {costume_1}
        db  {costume_2}
        db  {costume_3}
        db  {costume_4}
        db  {red_team}
        db  {blue_team}
        db  {green_team}
        OS.patch_end()
    }

    // @ Description
    // adds a character to an extended jab_3 table
    macro add_to_jab_3_table(table_name, id, parent_id, bool_jab_3) {
        origin {table_name}.TABLE_ORIGIN + ({id} * 0x4)
        if {bool_jab_3} == OS.TRUE {
            OS.copy_segment({table_name}.ORIGINAL_TABLE + ({parent_id} * 0x4), 0x4)
        } else {
            dw  {table_name}.DISABLED
        }
    }

    // @ Description
    // adds a character to an extended rapid_jab table
    macro add_to_rapid_jab_table(table_name, id, parent_id, bool_jab_3) {
        origin {table_name}.TABLE_ORIGIN + ({id} * 0x4)
        if {bool_jab_3} == OS.TRUE && {parent_id} != id.MARIO {
            OS.copy_segment({table_name}.ORIGINAL_TABLE + (({parent_id} - 1) * 0x4), 0x4)
        } else {
            dw  {table_name}.DISABLED
        }
    }

    // @ Description
    // adds a character to an extended table
    macro add_to_table(table_name, id, parent_id, entry_size) {
        origin {table_name}.TABLE_ORIGIN + ({id} * {entry_size})
        OS.copy_segment({table_name}.ORIGINAL_TABLE + ({parent_id} * {entry_size}), {entry_size})
    }

    macro add_to_id_table(table_name, id, parent_id) {
        origin {table_name}.TABLE_ORIGIN + ({id} * 0x4)
        dw {parent_id}
    }

    // @ Description
    // moves and extends a jab_3 table, allowing for more characters to be added to it
    macro move_jab_3_table(table_name, original_offset, disabled_ptr) {
        scope {table_name} {
            // this table originally begins with MARIO and ends with NNESS
            constant ORIGINAL_TABLE({original_offset})
            constant DISABLED({disabled_ptr})
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            // copy ORIGINAL_TABLE
            OS.copy_segment(ORIGINAL_TABLE, (26 * 4))
            // add GDONKEY to table
            OS.copy_segment(ORIGINAL_TABLE + (id.DONKEY * 4), 0x4)
            // pad table for new characters
            fill (table + (NUM_CHARACTERS * 0x4)) - pc()
        }
    }

    // @ Description
    // moves and extends a rapid_jab table, allowing for more characters to be added to it
    macro move_rapid_jab_table(table_name, original_offset, disabled_ptr) {
        scope {table_name} {
            // this table originally begins with FOX and ends with NJIGGLY
            constant ORIGINAL_TABLE({original_offset})
            constant DISABLED({disabled_ptr})
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            // add MARIO to table
            dw DISABLED
            // copy ORIGINAL_TABLE
            OS.copy_segment(ORIGINAL_TABLE, (24 * 4))
            // add NNESS and GDONKEY to table
            OS.copy_segment(ORIGINAL_TABLE + ((id.NESS - 1) * 4), 0x4)
            OS.copy_segment(ORIGINAL_TABLE + ((id.DONKEY - 1) * 4), 0x4)
            // pad table for new characters
            fill (table + (NUM_CHARACTERS * 0x4)) - pc()
        }
    }

    // @ Description
    // moves and extends a standard character related table, allowing for more characters to be
    // added to it
    macro move_table(table_name, original_offset, entry_size) {
        scope {table_name} {
            constant ORIGINAL_TABLE({original_offset})
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            // copy ORIGINAL_TABLE
            OS.copy_segment(ORIGINAL_TABLE, (27 * {entry_size}))
            // pad table for new characters
            fill (table + (NUM_CHARACTERS * {entry_size})) - pc()
            OS.align(4)
        }
    }

    // @ Description
    // moves and extends a standard character related table, allowing for more characters to be
    // added to it, used for 12 character tables
    macro move_table_12(table_name, original_offset, entry_size) {
        scope {table_name} {
            constant ORIGINAL_TABLE({original_offset})
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            // copy ORIGINAL_TABLE
            OS.copy_segment(ORIGINAL_TABLE, (12 * {entry_size}))
            // master hand
            OS.copy_segment(ORIGINAL_TABLE, (1 * {entry_size}))
            // metal mario
            OS.copy_segment(ORIGINAL_TABLE, (1 * {entry_size}))
            // polygon fighters
            OS.copy_segment(ORIGINAL_TABLE, (12 * {entry_size}))
            // giant dk
            OS.copy_segment(ORIGINAL_TABLE + (id.DONKEY * {entry_size}), (1 * {entry_size}))
            // pad table for new characters
            fill (table + (NUM_CHARACTERS * {entry_size})) - pc()
            OS.align(4)
        }
    }

    // @ Description
    // moves and extends a standard character related table, allowing for more characters to be
    // added to it, used for 14 character tables
    macro move_table_14(table_name, original_offset, entry_size) {
        scope {table_name} {
            constant ORIGINAL_TABLE({original_offset})
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            // copy ORIGINAL_TABLE
            OS.copy_segment(ORIGINAL_TABLE, (14 * {entry_size}))
            // polygon fighters
            OS.copy_segment(ORIGINAL_TABLE, (12 * {entry_size}))
            // giant dk
            OS.copy_segment(ORIGINAL_TABLE + (id.DONKEY * {entry_size}), (1 * {entry_size}))
            // pad table for new characters
            fill (table + (NUM_CHARACTERS * {entry_size})) - pc()
            OS.align(4)
        }
    }

    // @ Description
    // adds an ID based table which can be used when it isn't feasible to move an original table,
    // and can instead be used to override the character ID before the offset for the original
    // table is calculated
    macro id_table(table_name) {
        scope {table_name} {
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            // add original 27 to table
            dw id.MARIO
            dw id.FOX
            dw id.DONKEY
            dw id.SAMUS
            dw id.LUIGI
            dw id.LINK
            dw id.YOSHI
            dw id.CAPTAIN
            dw id.KIRBY
            dw id.PIKACHU
            dw id.JIGGLY
            dw id.NESS
            dw id.BOSS
            dw id.METAL
            dw id.NMARIO
            dw id.NFOX
            dw id.NDONKEY
            dw id.NSAMUS
            dw id.NLUIGI
            dw id.NLINK
            dw id.NYOSHI
            dw id.NCAPTAIN
            dw id.NKIRBY
            dw id.NPIKACHU
            dw id.NJIGGLY
            dw id.NNESS
            dw id.GDONKEY
            // pad table for new characters
            fill (table + (NUM_CHARACTERS * 0x4)) - pc()
        }
    }

    // @ Description
    // adds an ID based table which can be used when it isn't feasible to move an original table,
    // and can instead be used to override the character ID before the offset for the original
    // table is calculated, use when only the original 12's IDs will work.
    macro id_table_12(table_name) {
        scope {table_name} {
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            // add original 27 to table
            dw id.MARIO
            dw id.FOX
            dw id.DONKEY
            dw id.SAMUS
            dw id.LUIGI
            dw id.LINK
            dw id.YOSHI
            dw id.CAPTAIN
            dw id.KIRBY
            dw id.PIKACHU
            dw id.JIGGLY
            dw id.NESS
            dw id.MARIO
            dw id.MARIO
            dw id.MARIO
            dw id.FOX
            dw id.DONKEY
            dw id.SAMUS
            dw id.LUIGI
            dw id.LINK
            dw id.YOSHI
            dw id.CAPTAIN
            dw id.KIRBY
            dw id.PIKACHU
            dw id.JIGGLY
            dw id.NESS
            dw id.DONKEY
            // pad table for new characters
            fill (table + (NUM_CHARACTERS * 0x4)) - pc()
        }
    }

    // @ Description
    // moves Mario's action parameter array to make room for expanding STRUCT_TABLE
    macro move_mario_parameter_array() {
        OS.align(16)
        mario_parameter_array:
        OS.move_segment(0x92680, 0x990)

        pushvar origin, base
        origin  0x93074
        dw      mario_parameter_array
        pullvar base, origin
    }

    // @ Description
    // moves Kirby's action array/action parameter array to allow for new copy ability actions to be added
    // add_actions - number of new actions to add for Kirby
    macro extend_kirby_arrays(add_actions) {
        // Get struct pointer and ROM offset
        read32 KIRBY_struct_ptr, "../roms/original.z64", (STRUCT_TABLE + (id.KIRBY * 0x4))
        constant KIRBY_struct(KIRBY_struct_ptr - 0x80084800)
        // Fixes conflict with copy_menu_actions
        global evaluate KIRBY_struct(KIRBY_struct)

        // Get parameter array pointer, size, and ROM offset
        read32 KIRBY_original_param_array_ptr, "../roms/original.z64", (KIRBY_struct + 0x64)
        read32 KIRBY_original_param_array_size, "../roms/original.z64", (KIRBY_struct + 0x6C)
        constant KIRBY_original_param_array(KIRBY_original_param_array_ptr - 0x80084800)

        // Get action array pointer and ROM offset
        read32 KIRBY_original_action_array_ptr, "../roms/original.z64", (ACTION_ARRAY_TABLE_ORIGINAL + (id.KIRBY * 0x4))
        global evaluate KIRBY_original_action_array(KIRBY_original_action_array_ptr - 0x80084800)

        // New action parameter array size
        constant KIRBY_param_array_size(KIRBY_original_param_array_size + {add_actions})

        // Number of new action slots
        constant KIRBY_NEW_ACTION_SLOTS({add_actions})

        // Move action parameter array
        KIRBY_param_array:
        global evaluate KIRBY_param_array_origin(origin())
        OS.move_segment(KIRBY_original_param_array, (KIRBY_original_param_array_size * 0xC))
        // Add space for new actions
        fill (KIRBY_param_array + (KIRBY_param_array_size * 0xC)) - pc()
        OS.align(16)

        // Move action array
        KIRBY_action_array:
        global evaluate KIRBY_action_array_origin(origin())
        OS.move_segment({KIRBY_original_action_array}, action_array_size.KIRBY)
        // Add space for new actions
        fill (KIRBY_action_array + (action_array_size.KIRBY + ({add_actions} * 0x14))) - pc()
        OS.align(16)

        // Write new array pointers and size
        pushvar origin, base

        // parameter array
        origin KIRBY_struct + 0x64
        dw KIRBY_param_array
        origin KIRBY_struct + 0x6C
        dw KIRBY_param_array_size

        // action array
        origin  ACTION_ARRAY_TABLE_ORIGIN + (id.KIRBY * 0x4)
        dw KIRBY_action_array
        origin  ACTION_ARRAY_TABLE_ORIGIN + (id.NKIRBY * 0x4)
        dw KIRBY_action_array

        pullvar base, origin
    }

    // @ Description
    // Updates a character's costume shield colors
    macro set_costume_shield_colors(name, costume_0_color, costume_1_color, costume_2_color, costume_3_color, costume_4_color, costume_5_color, costume_6_color, costume_7_color, costume_8_color, costume_9_color, costume_10_color, costume_11_color) {
        scope costume_shield_color: {
            db Shield.color.{costume_0_color}
            db Shield.color.{costume_1_color}
            db Shield.color.{costume_2_color}
            db Shield.color.{costume_3_color}
            db Shield.color.{costume_4_color}
            db Shield.color.{costume_5_color}
            if Shield.color.{costume_6_color} != Shield.color.NA {
                db Shield.color.{costume_6_color}
            }
            if Shield.color.{costume_7_color} != Shield.color.NA {
                db Shield.color.{costume_7_color}
            }
            if Shield.color.{costume_8_color} != Shield.color.NA {
                db Shield.color.{costume_8_color}
            }
            if Shield.color.{costume_9_color} != Shield.color.NA {
                db Shield.color.{costume_9_color}
            }
            if Shield.color.{costume_10_color} != Shield.color.NA {
                db Shield.color.{costume_10_color}
            }
            if Shield.color.{costume_11_color} != Shield.color.NA {
                db Shield.color.{costume_11_color}
            }

            OS.align(4)
        }

        pushvar origin, base

        origin Character.costume_shield_color.TABLE_ORIGIN + (Character.id.{name} * 4)
        dw costume_shield_color

        pullvar base, origin
    }

    // @ Description
    // Updates a character's costume shield colors - 8 costumes
    macro set_costume_shield_colors(name, costume_0_color, costume_1_color, costume_2_color, costume_3_color, costume_4_color, costume_5_color, costume_6_color, costume_7_color) {
        Character.set_costume_shield_colors({name}, {costume_0_color}, {costume_1_color}, {costume_2_color}, {costume_3_color}, {costume_4_color}, {costume_5_color}, {costume_6_color}, {costume_7_color}, NA, NA, NA, NA)
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////////// ASSEMBLY SETUP ///////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    scope setup {
        // @ Description
        // modifies a hard-coded routine which runs on boot and assigns file and animation segment
        // sizes for each character
        // s7 - STRUCT_TABLE_END
        // s5 - STRUCT_TABLE
        // s4 - SEGMENT_SIZE_TABLE
        pushvar origin, base

        scope assign_segments_: {
            origin  0x5284C
            base    0x800D704C
            li      s7, (STRUCT_TABLE + (NUM_CHARACTERS * 0x4) + 0x80084800)
            li      s5, (STRUCT_TABLE + 0x80084800)
            li      s4, SEGMENT_SIZE_TABLE
        }

        // @ Description
        // modifies a hard-coded routine which runs on character load and loads the file and
        // animation segment sizes for each character
        // a2 - STRUCT_TABLE
        // a1 - SEGMENT_SIZE_TABLE
        // a3 - SEGMENT_SIZE_TABLE_END
        scope load_segment_sizes_: {
            origin  0x52CC8
            base    0x800D74C8
            li      a2, (STRUCT_TABLE + 0x80084800)
            li      a1, SEGMENT_SIZE_TABLE
            li      a3, SEGMENT_SIZE_TABLE_END
            lw      t2, 0x0038(sp)
        }

        // @ Description
        // modifies a hard-coded routine which runs on character load and assigns pointers in each character's file table
        // s1 - loop iteration count
        scope assign_file_pointers_: {
            origin  0x53040
            base    0x800D7840
            lli     s1, NUM_CHARACTERS
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses a unique action, and
        // is responsible for loading their unique action array pointer from ACTION_ARRAY_TABLE
        // t9 = upper half of ACTION_ARRAY_TABLE
        scope move_action_array_table_: {
            origin  0x62BD0
            base    0x800E73D0
            // because the lw instruction uses a signed integer for calculating the address, we
            // must add 0x1 to the upper half of ACTION_ARRAY_TABLE if the lower half is greater
            // than 0x7FFF
            constant UPPER(ACTION_ARRAY_TABLE >> 16)
            constant LOWER(ACTION_ARRAY_TABLE & 0xFFFF)
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)
            } else {
                lui     t9, UPPER
            }
            addiu   t0, v0, 0xFF24
            sll     t8, t7, 0x2
            addu    t9, t9, t8
            lw      t9, LOWER(t9)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character is using their second jab,
        // and initiates a frame timer which determines how long the character has to perform
        // their third jab action.
        scope set_jab_3_timer_: {
            constant UPPER(jab_3_timer.table >> 16)
            constant LOWER(jab_3_timer.table & 0xFFFF)
            origin  0xC956C
            base    0x8014EB2C
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            origin  0xC9580
            base    0x8014EB40
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t7
            lw      t7, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses their third jab, and
        // determines which action ID will be loaded (seems redundant, always results in 0xDC)
        scope get_jab_3_action_: {
            constant UPPER(jab_3_action.table >> 16)
            constant LOWER(jab_3_action.table & 0xFFFF)
            origin  0xC9618
            base    0x8014EBD8
            sltiu   at, t6, NUM_CHARACTERS  // modified original character check
            origin  0xC9624
            base    0x8014EBE4
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t6
            lw      t6, LOWER(at)
        }

        // @ Description
        // replaces a hard-coded routine which is responsible for determining whether or not the
        // character is allowed to initiate a jab 3 action.
        scope check_jab_3_: {
            origin  0xC9A20
            base    0x8014EFE0
            addiu   sp, sp, 0xFFE8          // original line 1
            sw      ra, 0x0014(sp)          // original line 2
            lw      v1, 0x0084(a0)          // original line 3
            lw      v0, 0x0008(v1)          // v0 = character id (original line 5)
            li      at, jab_3.table         // at = jab_3.table
            sll     v0, v0, 0x2             // v0 = offset (character id * 4)
            addu    at, at, v0              // at = jab_3.table + offset
            lw      at, 0x0000(at)          // at = jab_3 routine
            jr      at                      // jump to appropriate jab_3 routine
            or      v0, r0, r0
            fill    jab_3.ENABLED - pc()    // nop the rest of the original logic
        }


        // @ Description
        // modifies a hard-coded routine which runs when the character initiates a rapid jab, and
        // determines which action ID will be loaded
        scope get_rapid_jab_begin_action_: {
            constant UPPER(rapid_jab_begin_action.table >> 16)
            constant LOWER(rapid_jab_begin_action.table & 0xFFFF)
            origin  0xC9B58
            base    0x8014F118
            or      t7, t6, r0              // t6 = character id, originally character id - 1
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            origin  0xC9B68
            base    0x8014F128
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t7
            lw      t7, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs when the character transitions into a rapid jab
        // loop, and determines which action ID will be loaded
        scope get_rapid_jab_loop_action_: {
            constant UPPER(rapid_jab_loop_action.table >> 16)
            constant LOWER(rapid_jab_loop_action.table & 0xFFFF)
            origin  0xC9E10
            base    0x8014F3D0
            or      t7, t6, r0              // t6 = character id, originally character id - 1
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            origin  0xC9E20
            base    0x8014F3E0
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t7
            lw      t7, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs when the character transitions into a rapid jab
        // ending, and determines which action ID will be loaded
        scope get_rapid_jab_ending_action_: {
            constant UPPER(rapid_jab_ending_action.table >> 16)
            constant LOWER(rapid_jab_ending_action.table & 0xFFFF)
            origin  0xC9EAC
            base    0x8014F46C
            or      t7, t6, r0              // t6 = character id, originally character id - 1
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            origin  0xC9EBC
            base    0x8014F47C
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t7
            lw      t7, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs at various points during a jab combo and seems
        // to be related to determining whether or not the character is allowed to rapid jab
        scope fix_rapid_jab_unknown_: {
            constant UPPER(rapid_jab_unknown.table >> 16)
            constant LOWER(rapid_jab_unknown.table & 0xFFFF)
            origin  0xC9FC4
            base    0x8014F584
            or      t2, v0, r0              // t2 = character id, originally character id - 1
            sltiu   at, t2, NUM_CHARACTERS  // modified original character check
            origin  0xC9FDC
            base    0x8014F59C
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t2
            lw      t2, LOWER(at)
        }

        // @ Description
        // replaces a hard-coded routine which is responsible for determining whether or not the
        // character is allowed to initiate a rapid jab action. Maybe.
        scope check_rapid_jab_: {
            origin  0xC9F2C
            base    0x8014F4EC
            addiu   sp, sp, 0xFFD8          // original line 1
            sw      ra, 0x0014(sp)          // original line 2
            lw      v1, 0x0084(a0)          // original line 3
            lw      v0, 0x0008(v1)          // v0 = character id (original line 6)
            li      at, rapid_jab.table     // at = rapid_jab.table
            sll     a1, v0, 0x2             // a1 = offset (character id * 4)
            addu    at, at, a1              // at = rapid_jab.table + offset
            lw      at, 0x0000(at)          // at = rapid_jab routine
            jr      at                      // jump to appropriate rapid_jab routine
            or      a1, a0, r0              // original line 5
            fill    rapid_jab.ENABLED - pc()// nop the rest of the original logic
        }

        // @ Description
        // modifies a hard-coded routine which runs when kirby uses a copied neutral special in the
        // air, and is used to load an initial subroutine for that special.
        scope get_kirby_air_nsp_: {
            constant UPPER(kirby_air_nsp.table >> 16)
            constant LOWER(kirby_air_nsp.table & 0xFFFF)
            origin  0xCB91C
            base    0x80150EDC
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            lw      t6, 0x0ADC(v0)          // original line 2
            sll     t7, t6, 0x2             // original line 3
            addu    t9, t9, t7              // original line 4
            lw      t9, LOWER(t9)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses their neutral special in
        // the air, and is used to load an initial subroutine for that special.
        scope get_air_nsp_: {
            constant UPPER(air_nsp.table >> 16)
            constant LOWER(air_nsp.table & 0xFFFF)
            origin  0xCBA64
            base    0x80151024
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            or      a0, a2, r0              // original line 2
            sll     t6, t5, 0x2             // original line 3
            addu    t9, t9, t6              // original line 4
            lw      t9, LOWER(t9)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses their up special in
        // the air, and is used to load an initial subroutine for that special.
        scope get_air_usp_: {
            constant UPPER(air_usp.table >> 16)
            constant LOWER(air_usp.table & 0xFFFF)
            origin  0xCB9B4
            base    0x80150F74
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            or      a0, a2, r0              // original line 2
            sll     t3, t2, 0x2             // original line 3
            addu    t9, t9, t3              // original line 4
            lw      t9, LOWER(t9)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses their down special in
        // the air, and is used to load an initial subroutine for that special.
        scope get_air_dsp_: {
            constant UPPER(air_dsp.table >> 16)
            constant LOWER(air_dsp.table & 0xFFFF)
            origin  0xCB9F8
            base    0x80150FB8
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            or      a0, a2, r0              // original line 2
            sll     t8, t7, 0x2             // original line 3
            addu    t9, t9, t8              // original line 4
            lw      t9, LOWER(t9)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when kirby uses a copied neutral special on the
        // ground, and is used to load an initial subroutine for that special.
        scope get_kirby_ground_nsp_: {
            constant UPPER(kirby_ground_nsp.table >> 16)
            constant LOWER(kirby_ground_nsp.table & 0xFFFF)
            origin  0xCBAAC
            base    0x8015106C
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            lw      t6, 0x0ADC(v0)          // original line 2
            sll     t7, t6, 0x2             // original line 3
            addu    t9, t9, t7              // original line 4
            lw      t9, LOWER(t9)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses their neutral special on
        // the ground, and is used to load an initial subroutine for that special.
        scope get_ground_nsp_: {
            constant UPPER(ground_nsp.table >> 16)
            constant LOWER(ground_nsp.table & 0xFFFF)
            origin  0xCBB60
            base    0x80151120
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            or      a0, a2, r0              // original line 2
            sll     t6, t5, 0x2             // original line 3
            addu    t9, t9, t6              // original line 4
            lw      t9, LOWER(t9)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses their up special on
        // the ground, and is used to load an initial subroutine for that special.
        scope get_ground_usp_: {
            constant UPPER(ground_usp.table >> 16)
            constant LOWER(ground_usp.table & 0xFFFF)
            origin  0xCBBE4
            base    0x801511A4
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            sll     t3, t2, 0x2             // original line 2
            addu    t9, t9, t3              // original line 3
            lw      t9, LOWER(t9)           // original line 4 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character uses their down special on
        // the ground, and is used to load an initial subroutine for that special.
        scope get_ground_dsp_: {
            constant UPPER(ground_dsp.table >> 16)
            constant LOWER(ground_dsp.table & 0xFFFF)
            origin  0xCBC68
            base    0x80151228
            if LOWER > 0x7FFF {
                lui     t9, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t9, UPPER           // original line 1 (modified)
            }
            sll     t4, t3, 0x2             // original line 2
            addu    t9, t9, t4              // original line 3
            lw      t9, LOWER(t9)           // original line 4 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character's entry action is loaded, and
        // determines which action should be used. Also modifies a check for get_entry_script.
        scope get_entry_action_: {
            constant UPPER(entry_action.table >> 16)
            constant LOWER(entry_action.table & 0xFFFF)
            origin  0xB8664
            base    0x8013DC24
            if LOWER > 0x7FFF {
                lui     t5, (UPPER + 0x1)   // original line (modified)
            } else {
                lui     t5, UPPER           // original line (modified)
            }
            origin  0xB86A4
            base    0x8013DC64
            lw      t5, LOWER(t5)           // original line (modified)
            // get_entry_script character id check
            sltiu   at, a1, NUM_CHARACTERS
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character's entry action is loaded, and
        // determines which entry subroutine/script is loaded
        scope get_entry_script_: {
            constant UPPER(entry_script.table >> 16)
            constant LOWER(entry_script.table & 0xFFFF)
            origin  0xB86B8
            base    0x8013DC78
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line (modified)
            } else {
                lui     at, UPPER           // original line (modified)
            }
            addu    at, at, t6
            lw      t6, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character loads/respawns, and determines
        // which initial subroutine/script is loaded
        scope get_initial_script_: {
            constant UPPER(initial_script.table >> 16)
            constant LOWER(initial_script.table & 0xFFFF)
            origin  0x53588
            base    0x800D7D88
            sltiu   at, t4, NUM_CHARACTERS  // modified original character check
            origin  0x535A8
            base    0x800D7DA8
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t4
            lw      t4, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character touches the ground or a ledge,
        // and determines which grounded subroutine/script is loaded
        scope get_grounded_script_: {
            constant UPPER(grounded_script.table >> 16)
            constant LOWER(grounded_script.table & 0xFFFF)
            origin  0x59C08
            base    0x800DE408
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            origin  0x59C14
            base    0x800DE414
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)
            } else {
                lui     at, UPPER
            }
            addu    at, at, t7
            lw      t7, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a gfx routine ends or upon action change,
        // responsible for enabling the "charge flash" effect for samus and dk's neutral specials
        scope get_gfx_routine_end_: {
            origin  0x65148
            base    0x800E9948
            // t6 = character id
            li      at, gfx_routine_end.table // at = gfx_routine_end.table
            sll     t7, t6, 0x2             // ~
            addu    at, at, t7              // at = gfx_routine_end.table + (id * 4)
            lw      t7, 0x0000(at)          // t7 = gfx routine ending jump for {character}
            jr      t7                      // jump
            nop
            nop
            nop
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character is hit by an electric attack,
        // and determines which effect is applied to them
        scope get_electric_hit_effect_: {
            constant UPPER(electric_hit.table >> 16)
            constant LOWER(electric_hit.table & 0xFFFF)
            origin  0x65300
            base    0x800E9B00
            if LOWER > 0x7FFF {
                lui     t8, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t8, UPPER           // original line 1 (modified)
            }
            or      a2, r0, r0              // original line 2
            lw      t6, 0x0008(v0)          // original line 3
            sll     t7, t6, 0x2             // original line 4
            addu    t8, t8, t7              // original line 5
            lw      t8, LOWER(t8)           // original line 6 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a character hits the ground without
        // teching, and determines which FGM is played
        scope get_down_bound_fgm_: {
            constant UPPER(down_bound_fgm.table >> 16)
            constant LOWER(down_bound_fgm.table & 0xFFFF)
            origin  0xBEEA0
            base    0x80144460
            if LOWER > 0x7FFF {
                lui     a0, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     a0, UPPER           // original line 1 (modified)
            }
            lw      t8, 0x0008(t7)          // original line 2
            sll     t9, t8, 0x1             // original line 3
            addu    a0, a0, t9              // original line 4
            jal     0x800269C0              // original line 5 (play fgm)
            lhu     a0, LOWER(a0)           // original line 6 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when the crowd is about to begin chanting for a
        // character, and determines which FGM is played
        scope get_crowd_chant_fgm_: {
            constant UPPER(crowd_chant_fgm.table >> 16)
            constant LOWER(crowd_chant_fgm.table & 0xFFFF)
            origin  0xDF56C
            base    0x80164B2C
            if LOWER > 0x7FFF {
                lui     t2, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     t2, UPPER           // original line 1 (modified)
            }
            lui     at, 0x8019              // original line 2
            sll     t1, t0, 0x1             // original line 3
            addu    t2, t2, t1              // original line 4
            lhu     t2, LOWER(t2)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when Yoshi uses his egg lay on an opponent,
        // and determines the size of the egg's hurtbox, along with two other unknown parameters
        scope get_yoshi_egg_parameters_: {
            origin  0xC7840
            base    0x8014CE00
            li      t8, yoshi_egg.table     // original lines 1/2 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which runs when Yoshi uses his egg lay on an opponent,
        // and determines the size of the egg
        scope get_yoshi_egg_size_: {
            constant UPPER(yoshi_egg.table >> 16)
            constant LOWER(yoshi_egg.table & 0xFFFF)
            origin  0x7E89C
            base    0x8010309C
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line (modified)
            } else {
                lui     at, UPPER           // original line (modified)
            }
            origin  0x7E8E4
            base    0x801030E4
            lwc1    f0, LOWER(at)
        }

        // @ Description
        // modifies a hard-coded routine which runs when a fireball projectile is created, and
        // determines which fireball struct id is loaded
        scope get_fireball_struct_: {
            constant UPPER(fireball.table >> 16)
            constant LOWER(fireball.table & 0xFFFF)

            OS.patch_start(0xD08F4, 0x80155EB4)
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            OS.patch_end()

            OS.patch_start(0xD0900, 0x80155EC0)
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     at, UPPER           // original line 1 (modified)
            }
            addu    at, at, t7              // original line 2
            lw      t7, LOWER(at)           // original line 3
            OS.patch_end()
        }

        // @ Description
        // modifies a hard-coded routine which runs when a fireball projectile is created via kirby copy, and
        // determines which fireball struct id is loaded
        scope get_kirby_fireball_struct_: {
            constant UPPER(kirby_fireball.table >> 16)
            constant LOWER(kirby_fireball.table & 0xFFFF)

            OS.patch_start(0xD1464, 0x80156A24)
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            OS.patch_end()

            OS.patch_start(0xD1470, 0x80156A30)
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     at, UPPER           // original line 1 (modified)
            }
            addu    at, at, t7              // original line 2
            lw      t7, LOWER(at)           // original line 3
            OS.patch_end()
        }


        // @ Description
        // modifies a hard-coded routine which seemingly runs when an AI switches behaviours?
        // the table contains pointers to what seems to be a struct for determining how the AI will
        // behave, depending on which character it uses.
        scope get_ai_behaviour_struct_: {
            constant UPPER(ai_behaviour.table >> 16)
            constant LOWER(ai_behaviour.table & 0xFFFF)
            OS.patch_start(0xADAD0,0x80133090)
            if LOWER > 0x7FFF {
                lui     s2, (UPPER + 0x1)   // original line (modified)
            } else {
                lui     s2, UPPER           // original line (modified)
            }
            OS.patch_end()

            OS.patch_start(0xADB80,0x80133140)
            lw      s2, LOWER(s2)           // original line (modified)
            OS.patch_end()

        }

        // @ Description
        // modifies a hard-coded routine which checks if a character should avoid a potential attack
        scope get_ai_attack_prevent_table_: {
            constant UPPER(ai_attack_prevent.table >> 16)
            constant LOWER(ai_attack_prevent.table & 0xFFFF)
            origin  0xADF10
            base    0x801334D0
            nop                             // original line 1 (does nothing in vanilla) beqz at, 0x80133520
            sll     t9, a1, 2               // original line 2

            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line 3 (
            } else {
                lui     at, UPPER           // original line 3 (modified)
            }
            addu    at, at, t9              // original line 4
            lw      t9, LOWER(at)           // original line 5 (modified)
        }

        // @ Description
        // modifies a hard-coded routine which checks if a character should avoid a potential attack
        scope get_ai_aerial_chase_table_: {
            constant UPPER(ai_aerial_chase.table >> 16)
            constant LOWER(ai_aerial_chase.table & 0xFFFF)
            origin  0xAE2C8
            base    0x80133888

            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line 3 (
            } else {
                lui     at, UPPER           // original line 3 (modified)
            }
            addu    at, at, t8              // original line 4
            lw      t8, LOWER(at)           // original line 5 (modified)

        }

        // @ Description
        // modifies a hard-coded routine which checks if a character should avoid a potential attack
        scope get_ai_long_range_table_: {
            constant UPPER(ai_long_range.table >> 16)
            constant LOWER(ai_long_range.table & 0xFFFF)
            origin  0xB3700
            base    0x80138CC0

            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line 3 (
            } else {
                lui     at, UPPER           // original line 3 (modified)
            }
            addu    at, at, t5              // original line 4
            lw      t5, LOWER(at)           // original line 5 (modified)
			// jr 	t5
        }


        pullvar base, origin

        // @ Description
        // Patches which redirect from the original zoom table to the extended one.
        scope menu_zoom_patches {
            // character select screen (vs)
            OS.patch_start(0x00132E58, 0x80134BD8)
            li      t2, menu_zoom.table     // original line 1/3
            cvt.s.w f10, f8                 // original line 2
            OS.patch_end()
            // character select screen (training)
            OS.patch_start(0x00142F14, 0x80133934)
            li      t8, menu_zoom.table     // original line 1/2
            OS.patch_end()
            // character select screen (1p)
            OS.patch_start(0x0013D364, 0x80135164)
            li      t2, menu_zoom.table     // original line 1/5
            swc1    f8, 0x001C(t7)          // original line 2
            lw      t6, 0x0074(s0)          // original line 3
            lwc1    f10, 0x8eCC(at)         // original line 4
            OS.patch_end()
            // character select screen (btt/btp)
            OS.patch_start(0x0014A23C, 0x8013420C)
            li      t2, menu_zoom.table     // original line 1/5
            swc1    f8, 0x001C(t7)          // original line 2
            lw      t6, 0x0074(s0)          // original line 3
            lwc1    f10, 0x7630(at)         // original line 4
            OS.patch_end()
            // results screen
            OS.patch_start(0x00152A8C, 0x801338EC)
            li      t7, menu_zoom.table     // original line 1/2
            OS.patch_end()
            // game over screen
            OS.patch_start(0x00178AFC, 0x8013209C)
            li      t7, menu_zoom.table     // original line 1/2
            OS.patch_end()
            OS.patch_start(0x00179D10, 0x801332B0)
            li      a2, menu_zoom.table     // original line 1/2
            OS.patch_end()
            // data screen
            OS.patch_start(0x15E4E4, 0x80132494)
            li		t7, menu_zoom.table     // original lines 1/2
            OS.patch_end()
            // challenger approaching screen
            OS.patch_start(0x12A8B0, 0x80131EF0)
            li		t6, menu_zoom.table     // original lines 1/2
            OS.patch_end()
        }

        // @ Description
        // When a character is thrown, the throwing character's ID is used for a redirect table
        // which applies a hitbox to the thrown character. As this redirect table is located in the
        // shared moveset file (0xC9), it cannot be extended to accommodate additional characters
        // through normal means. Instead, a working ID will be substituted using a new table.
        scope thrown_redirect_fix_: {
            OS.patch_start(0x5B67C, 0x800DFE7C)
            j   thrown_redirect_fix_
            nop
            _return:
            OS.patch_end()

            lw      v0, 0x027C(s1)          // original line 1 (load throwing character id)
            addiu   v1, t9, 0x0004          // original line 2
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, thrown_hitbox.table // t0 = table
            sll     v0, v0, 0x2             // v0 = offset (id * 4)
            addu    t0, t0, v0              // t0 = table + offset
            lw      v0, 0x0000(t0)          // v0 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            j       _return                 // return
            nop
        }

        // @ Description
        // When a character is thrown, the thrown character's ID is used for an action table which
        // determines the action ID used for them during the throw (before being released). This
        // table is located in the main file of the throwing character, so it's not possible to
        // extend this table in order to accommodate additional characters through normal means.
        // Instead, a working ID will be substituted using a new table.
        scope f_thrown_action_fix_: {
            OS.patch_start(0xC4CA8, 0x8014A268)
            j   f_thrown_action_fix_
            nop
            _return:
            OS.patch_end()

            lw      t8, 0x0008(t7)          // original line 1 (load thrown character id)
            lw      t6, 0x0338(t5)          // original line 2
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, f_thrown_action.table // t0 = table
            sll     t8, t8, 0x2             // t8 = offset (id * 4)
            addu    t0, t0, t8              // t0 = table + offset
            lw      t8, 0x0000(t0)          // t8 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            j       _return                 // return
            nop
        }

        // @ Description
        // same as f_thrown_action_fix_
        scope b_thrown_action_fix_: {
            OS.patch_start(0xC4CC8, 0x8014A288)
            j   b_thrown_action_fix_
            nop
            _return:
            OS.patch_end()

            lw      t4, 0x0008(t3)          // original line 1 (load thrown character id)
            lw      t2, 0x0338(t1)          // original line 2
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, b_thrown_action.table // t0 = table
            sll     t4, t4, 0x2             // t4 = offset (id * 4)
            addu    t0, t0, t4              // t0 = table + offset
            lw      t4, 0x0000(t0)          // t4 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            j       _return                 // return
            nop
        }

        // @ Description
        // When Captain Falcon grabs an opponent with falcon dive, the opponent's ID is used for
        // a table which holds x/y positions for Falcon to snap to during the grab. This table is
        // located at the beginning of Falcon's moveset file, so it cannot be extended to
        // accommodate additional characters through normal means.
        // Instead, a working ID will be substituted using a new table.
        scope falcon_dive_x_fix_: {
            OS.patch_start(0xC7BC8, 0x8014D188)
            j   falcon_dive_x_fix_
            nop
            _return:
            OS.patch_end()

            lw      t6, 0x0008(v0)          // original line 1 (load grabbed character id)
            lwc1    f8, 0x002C(sp)          // original line 2
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, falcon_dive_id.table// t0 = table
            sll     t6, t6, 0x2             // t6 = offset (id * 4)
            addu    t0, t0, t6              // t0 = table + offset
            lw      t6, 0x0000(t0)          // t6 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            j       _return                 // return
            nop
        }

        // @ Description
        // same as falcon_dive_x_fix_
         scope falcon_dive_y_fix_: {
            OS.patch_start(0xC7C08, 0x8014D1C8)
            j   falcon_dive_y_fix_
           nop
            _return:
            OS.patch_end()

            lw      t3, 0x0008(v0)          // original line 1 (load grabbed character id)
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, falcon_dive_id.table// t0 = table
            sll     t3, t3, 0x2             // t3 = offset (id * 4)
            addu    t0, t0, t3              // t0 = table + offset
            lw      t3, 0x0000(t0)          // t3 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            j       _return                 // return
            sll     t4, t3, 0x2             // original line 2
        }

        // @ Description
        // fixes all hard codes to Kirby's inhale struct to use extended table
        scope get_extended_inhale_struct_: {
            // inhale
            OS.patch_start(0xDCABC, 0x8016207C)
            li      t6, kirby_inhale_struct.table
            OS.patch_end()

            // spit star 1
            OS.patch_start(0xC6F5C, 0x8014C51C)
            li      t7, kirby_inhale_struct.table
            OS.patch_end()

            // spit star 2
            OS.patch_start(0x7F504, 0x80103D04)
            li      t6, kirby_inhale_struct.table
            OS.patch_end()

            // spit star 3
            OS.patch_start(0x7F344, 0x80103B44)
            li      t7, kirby_inhale_struct.table
            OS.patch_end()

            // copy
            OS.patch_start(0xDC960, 0x80161F20)
            li      t7, kirby_inhale_struct.table
            OS.patch_end()

            // initialize character
            OS.patch_start(0x53660, 0x800D7E60)
            jal     get_extended_inhale_struct_._initialize
            addiu   a1, r0, 0x0006          // original line 1
            OS.patch_end()

            _initialize:
            li      t9, kirby_inhale_struct.table
            jr      ra
            nop
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////// TABLE SETUP /////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // jab 3 tables
    move_jab_3_table(jab_3_timer, 0x106C90, 0x8014EBA4)
    move_jab_3_table(jab_3_action, 0x106CF8, 0x8014EC30)
    scope jab_3 {
        constant ENABLED(0x8014F054)
        constant DISABLED(0x8014F0B4)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        dw  ENABLED                         // 0x00 - MARIO
        dw  DISABLED                        // 0x01 - FOX
        dw  DISABLED                        // 0x02 - DONKEY
        dw  DISABLED                        // 0x03 - SAMUS
        dw  ENABLED                         // 0x04 - LUIGI
        dw  ENABLED                         // 0x05 - LINK
        dw  DISABLED                        // 0x06 - YOSHI
        dw  ENABLED                         // 0x07 - CAPTAIN
        dw  DISABLED                        // 0x08 - KIRBY
        dw  DISABLED                        // 0x09 - PIKACHU
        dw  DISABLED                        // 0x0A - JIGGLY
        dw  ENABLED                         // 0x0B - NESS
        dw  DISABLED                        // 0x0C - BOSS
        dw  ENABLED                         // 0x0D - METAL
        dw  ENABLED                         // 0x0E - NMARIO
        dw  DISABLED                        // 0x0F - NFOX
        dw  DISABLED                        // 0x10 - NDONKEY
        dw  DISABLED                        // 0x11 - NSAMUS
        dw  ENABLED                         // 0x12 - NLUIGI
        dw  ENABLED                         // 0x13 - NLINK
        dw  DISABLED                        // 0x14 - NYOSHI
        dw  ENABLED                         // 0x15 - NCAPTAIN
        dw  DISABLED                        // 0x16 - NKIRBY
        dw  DISABLED                        // 0x17 - NPIKACHU
        dw  DISABLED                        // 0x18 - NJIGGLY
        dw  ENABLED                         // 0x19 - NNESS
        dw  DISABLED                        // 0x1A - GDONKEY
        // pad table for new characters
        fill (table + (NUM_CHARACTERS * 0x4)) - pc()
    }

    // rapid jab tables
    move_rapid_jab_table(rapid_jab_begin_action, 0x106D60, 0x8014F174)
    move_rapid_jab_table(rapid_jab_loop_action, 0x106DC0, 0x8014F42C)
    move_rapid_jab_table(rapid_jab_ending_action, 0x106E20, 0x8014F4C8)
    move_rapid_jab_table(rapid_jab_unknown, 0x106E80, 0x8014F610)
    scope rapid_jab {
        constant ENABLED(0x8014F55C)
        constant DISABLED(0x8014F65C)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        dw  DISABLED                        // 0x00 - MARIO
        dw  ENABLED                         // 0x01 - FOX
        dw  DISABLED                        // 0x02 - DONKEY
        dw  DISABLED                        // 0x03 - SAMUS
        dw  DISABLED                        // 0x04 - LUIGI
        dw  ENABLED                         // 0x05 - LINK
        dw  DISABLED                        // 0x06 - YOSHI
        dw  ENABLED                         // 0x07 - CAPTAIN
        dw  ENABLED                         // 0x08 - KIRBY
        dw  DISABLED                        // 0x09 - PIKACHU
        dw  ENABLED                         // 0x0A - JIGGLY
        dw  DISABLED                        // 0x0B - NESS
        dw  DISABLED                        // 0x0C - BOSS
        dw  DISABLED                        // 0x0D - METAL
        dw  DISABLED                        // 0x0E - NMARIO
        dw  ENABLED                         // 0x0F - NFOX
        dw  DISABLED                        // 0x10 - NDONKEY
        dw  DISABLED                        // 0x11 - NSAMUS
        dw  DISABLED                        // 0x12 - NLUIGI
        dw  ENABLED                         // 0x13 - NLINK
        dw  DISABLED                        // 0x14 - NYOSHI
        dw  ENABLED                         // 0x15 - NCAPTAIN
        dw  ENABLED                         // 0x16 - NKIRBY
        dw  DISABLED                        // 0x17 - NPIKACHU
        dw  ENABLED                         // 0x18 - NJIGGLY
        dw  DISABLED                        // 0x19 - NNESS
        dw  DISABLED                        // 0x1A - GDONKEY
        // pad table for new characters
        fill (table + (NUM_CHARACTERS * 0x4)) - pc()
    }

    // special move tables
    move_table(kirby_air_nsp, 0x103490, 0x4)
    move_table(air_nsp, 0x1034FC, 0x4)
    move_table(air_usp, 0x103568, 0x4)
    move_table(air_dsp, 0x1035D4, 0x4)
    move_table(kirby_ground_nsp, 0x103640, 0x4)
    move_table(ground_nsp, 0x1036AC, 0x4)
    move_table(ground_usp, 0x103720, 0x4)
    move_table(ground_dsp, 0x103790, 0x4)

    // entry action tables
    move_table(entry_action, 0x102EE0, 0x8)
    move_table(entry_script, 0x106AA4, 0x4)

    // other tables
    move_table(initial_script, 0xAB294, 0x4)
    scope grounded_script {
        // this table originally begins with MARIO and ends with NJIGGLY
        constant ORIGINAL_TABLE(0xAB304)
        constant DISABLED(0x800DE44C)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        // copy ORIGINAL_TABLE
        OS.copy_segment(ORIGINAL_TABLE, (25 * 4))
        // add NNESS and GDONKEY to table
        OS.copy_segment(ORIGINAL_TABLE + (id.NESS * 4), 0x4)
        OS.copy_segment(ORIGINAL_TABLE + (id.DONKEY * 4), 0x4)
        // pad table for new characters
        fill (table + (NUM_CHARACTERS * 0x4)) - pc()
    }
    scope gfx_routine_end {
        // this table originally begins with DONKEY and ends with GDONKEY
        constant ORIGINAL_TABLE(0xAB6AC)
        constant DISABLED(0x800E9A60)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        // add MARIO and FOX to table
        OS.copy_segment(ORIGINAL_TABLE + ((id.NMARIO - 2) * 4), 0x4)
        OS.copy_segment(ORIGINAL_TABLE + ((id.NFOX - 2) * 4), 0x4)
        // copy ORIGINAL_TABLE
        OS.copy_segment(ORIGINAL_TABLE, (25 * 4))
        // pad table for new characters
        fill (table + (NUM_CHARACTERS * 0x4)) - pc()
    }
    move_table(electric_hit, 0xA6FB4, 0x4)
    move_table(down_bound_fgm, 0xA8170, 0x2)
    move_table(crowd_chant_fgm, 0xA81A8, 0x2)
    move_table(yoshi_egg, 0x103160, 0x1C)

	// ai tables
    move_table(ai_behaviour, 0x102B04, 0x4)

    scope ai_behaviour_heavy_attack {
            OS.align(16)
            table:
            constant TABLE_ORIGIN(origin())
            dw  AI.heavy_attack_arrays.mario
            dw  AI.heavy_attack_arrays.fox
            dw  AI.heavy_attack_arrays.dk
            dw  AI.heavy_attack_arrays.samus
            dw  AI.heavy_attack_arrays.luigi
            dw  AI.heavy_attack_arrays.link
            dw  AI.heavy_attack_arrays.yoshi
            dw  AI.heavy_attack_arrays.captain_falcon
            dw  AI.heavy_attack_arrays.kirby
            dw  AI.heavy_attack_arrays.pikachu
            dw  AI.heavy_attack_arrays.jigglypuff
            dw  AI.heavy_attack_arrays.ness
            dw  0                           // boss
            dw  AI.heavy_attack_arrays.mario// metal mario
            dw  AI.heavy_attack_arrays.mario// polygons
            dw  AI.heavy_attack_arrays.fox
            dw  AI.heavy_attack_arrays.dk
            dw  AI.heavy_attack_arrays.samus
            dw  AI.heavy_attack_arrays.luigi
            dw  AI.heavy_attack_arrays.link
            dw  AI.heavy_attack_arrays.yoshi
            dw  AI.heavy_attack_arrays.captain_falcon
            dw  AI.heavy_attack_arrays.kirby
            dw  AI.heavy_attack_arrays.pikachu
            dw  AI.heavy_attack_arrays.jigglypuff
            dw  AI.heavy_attack_arrays.ness
            dw  AI.heavy_attack_arrays.dk   // giant dk
            dw  0                           // none
            dw  0                           // none

            // pad table for new characters
            fill (table + (NUM_CHARACTERS * 0x4)) - pc()
            OS.align(4)
    }

    move_table(ai_attack_prevent, 0x1065E4, 0x4)
    move_table_14(ai_aerial_chase, 0x1066A4, 0x4)
    move_table_14(ai_long_range, 0x106954, 0x4)

    // menu tables
    move_table_12(menu_zoom, 0x108370, 0x4)
    // character select
    move_table_12(default_costume, 0xA7030, 0x8)
    id_table_12(variant_original)
    // results screen
    id_table_12(vs_record)
    move_table_12(winner_fgm, 0x158148, 0x4)
    id_table_12(label_height)
    move_table_12(str_wins_lx, 0x158654, 0x4)
    move_table_12(str_winner_ptr, 0x158690, 0x4)
    move_table_12(str_winner_lx, 0x1586C0, 0x4)
    move_table_12(str_winner_scale, 0x1586F0, 0x4)
    move_table_12(winner_bgm, 0x158A08, 0x4)
    // 1p
    id_table_12(singleplayer_vs_preview)

    // projectile tables
    move_table(fireball, 0x107070, 0x4)
    move_table(kirby_fireball, 0x1070E0, 0x4)

    // ID override tables
    id_table(thrown_hitbox)
    id_table(f_thrown_action)
    id_table(b_thrown_action)
    id_table(falcon_dive_id)                // TODO: may need to be revisited
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////////////////// CONSTANTS/SUBROUTINES ////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    // @ Description
    // character id constants
    // constant names are loosely based on the debug names for characters
    scope id {
        constant MARIO(0x00)
        constant FOX(0x01)
        constant DONKEY(0x02)
        constant DK(0x02)
        constant DONKEY_KONG(0x02)
        constant SAMUS(0x03)
        constant LUIGI(0x04)
        constant LINK(0x05)
        constant YOSHI(0x06)
        constant CAPTAIN(0x07)
        constant CAPTAIN_FALCON(0x07)
        constant FALCON(0x07)
        constant KIRBY(0x08)
        constant PIKACHU(0x09)
        constant JIGGLY(0x0A)
        constant JIGGLYPUFF(0x0A)
        constant PUFF(0x0A)
        constant NESS(0x0B)
        constant BOSS(0x0C)
        constant METAL(0x0D)
        constant NMARIO(0x0E)
        constant NFOX(0x0F)
        constant NDONKEY(0x10)
        constant NSAMUS(0x11)
        constant NLUIGI(0x12)
        constant NLINK(0x13)
        constant NYOSHI(0x14)
        constant NCAPTAIN(0x15)
        constant NKIRBY(0x16)
        constant NPIKACHU(0x17)
        constant NJIGGLY(0x18)
        constant NPUFF(0x18)
        constant NJIGGLYPUFF(0x18)
        constant NNESS(0x19)
        constant GDONKEY(0x1A)
        constant PLACEHOLDER(0x1B)
        constant NONE(0x1C)
    }

    // @ Description
    // action array size constants
    // action parameter array size for each character (seemingly not present in the original ROM)
    // constant names are loosely based on the debug names for characters
    scope action_array_size {
        constant MARIO(0xB4)
        constant FOX(0x208)
        constant DONKEY(0x258)
        constant DK(0x258)
        constant DONKEY_KONG(0x258)
        constant SAMUS(0xDC)
        constant LUIGI(0xB4)
        constant LINK(0x154)
        constant YOSHI(0x118)
        constant CAPTAIN(0x17C)
        constant CAPTAIN_FALCON(0x17C)
        constant FALCON(0x17C)
        constant KIRBY(0x67C)
        constant PIKACHU(0x168)
        constant JIGGLY(0x140)
        constant JIGGLYPUFF(0x140)
        constant NESS(0x1F4)
    }

    // @ Description
    // This table maps character-specific actions to strings for display in Training mode
    scope action_string {
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        dw  Action.MARIO.action_string_table     // 0x00 - MARIO
        dw  Action.FOX.action_string_table       // 0x01 - FOX
        dw  Action.DK.action_string_table        // 0x02 - DONKEY
        dw  Action.SAMUS.action_string_table     // 0x03 - SAMUS
        dw  Action.LUIGI.action_string_table     // 0x04 - LUIGI
        dw  Action.LINK.action_string_table      // 0x05 - LINK
        dw  Action.YOSHI.action_string_table     // 0x06 - YOSHI
        dw  Action.CAPTAIN.action_string_table   // 0x07 - CAPTAIN
        dw  Action.KIRBY.action_string_table     // 0x08 - KIRBY
        dw  Action.PIKACHU.action_string_table   // 0x09 - PIKACHU
        dw  Action.JIGGLY.action_string_table    // 0x0A - JIGGLY
        dw  Action.NESS.action_string_table      // 0x0B - NESS
        dw  0                                    // 0x0C - BOSS
        dw  Action.MARIO.action_string_table     // 0x0D - METAL
        dw  Action.MARIO.action_string_table     // 0x0E - NMARIO
        dw  Action.FOX.action_string_table       // 0x0F - NFOX
        dw  Action.DK.action_string_table        // 0x10 - NDONKEY
        dw  Action.SAMUS.action_string_table     // 0x11 - NSAMUS
        dw  Action.LUIGI.action_string_table     // 0x12 - NLUIGI
        dw  Action.LINK.action_string_table      // 0x13 - NLINK
        dw  Action.YOSHI.action_string_table     // 0x14 - NYOSHI
        dw  Action.CAPTAIN.action_string_table   // 0x15 - NCAPTAIN
        dw  Action.KIRBY.action_string_table     // 0x16 - NKIRBY
        dw  Action.PIKACHU.action_string_table   // 0x17 - NPIKACHU
        dw  Action.JIGGLY.action_string_table    // 0x18 - NJIGGLY
        dw  Action.NESS.action_string_table      // 0x19 - NNESS
        dw  Action.DK.action_string_table        // 0x1A - GDONKEY
        // pad table for new characters
        fill table + (NUM_CHARACTERS * 4) - pc()
    }

    // @ Description
    // constants and table for sound type
    // sound_type is used to determine which hitbox sound bank to use
    scope sound_type {
        constant U(0x0)
        constant J(0x1)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        db  U                               // 0x00 - MARIO
        db  U                               // 0x01 - FOX
        db  U                               // 0x02 - DONKEY
        db  U                               // 0x03 - SAMUS
        db  U                               // 0x04 - LUIGI
        db  U                               // 0x05 - LINK
        db  U                               // 0x06 - YOSHI
        db  U                               // 0x07 - CAPTAIN
        db  U                               // 0x08 - KIRBY
        db  U                               // 0x09 - PIKACHU
        db  U                               // 0x0A - JIGGLY
        db  U                               // 0x0B - NESS
        db  U                               // 0x0C - BOSS
        db  U                               // 0x0D - METAL
        db  U                               // 0x0E - NMARIO
        db  U                               // 0x0F - NFOX
        db  U                               // 0x10 - NDONKEY
        db  U                               // 0x11 - NSAMUS
        db  U                               // 0x12 - NLUIGI
        db  U                               // 0x13 - NLINK
        db  U                               // 0x14 - NYOSHI
        db  U                               // 0x15 - NCAPTAIN
        db  U                               // 0x16 - NKIRBY
        db  U                               // 0x17 - NPIKACHU
        db  U                               // 0x18 - NJIGGLY
        db  U                               // 0x19 - NNESS
        db  U                               // 0x1A - GDONKEY
        // pad table for new characters
        fill table + NUM_CHARACTERS - pc(), U
    }

    // @ Description
    // Holds the fgm_ids for J hitboxes
    scope sound_type_J: {
        constant ORIGINAL_TABLE(0xA4500)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        // copy ORIGINAL_TABLE
        OS.copy_segment(ORIGINAL_TABLE, 48)
        OS.align(4)
        // update fgm_ids for J sounds
        pushvar base, origin
        origin  TABLE_ORIGIN
        dh      FGM.hit.J_PUNCH_S            // Punch S
        dh      FGM.hit.J_PUNCH_M            // Punch M
        dh      FGM.hit.J_PUNCH_L            // Punch L
        dh      FGM.hit.J_KICK_S             // Kick S
        dh      FGM.hit.J_KICK_M             // Kick M
        dh      FGM.hit.J_KICK_L             // Kick L
        pullvar origin, base

        scope apply_sound_type_: {
            OS.patch_start(0x5E4A0, 0x800E2CA0)
            j       apply_sound_type_
            nop
            _apply_sound_type_return:
            OS.patch_end()

            li      a0, Toggles.entry_japanese_sounds
            lw      a0, 0x0004(a0)              // a0 = 1 if always, 2 if never, 0 if default
            lli     t3, 0x0001                  // t3 = always
            beq     a0, t3, _j_sounds_on        // if set to always, then use j sounds
            lli     t3, 0x0002                  // t3 = never
            beq     a0, t3, _original           // if set to never, then use u sounds
            nop                                 // otherwise, test if player is J player

            // a3 = attacking player struct
            lbu     t3, 0x000B(a3)              // t3 = character_id
            li      a0, sound_type.table        // a0 = address of sound_type table
            addu    t3, a0, t3                  // t3 = address of sound_type
            lbu     t3, 0x0000(t3)              // t3 = sound_type
            addiu   a0, r0, sound_type.U        // a0 = sound_type.U
            beq     t3, a0, _original           // if sound_type is U, then use original sounds
            nop                                 // else use J table
            _j_sounds_on:
            li      a0, sound_type_J.table      // a0 = address of sound_type_J table
            addiu   a0, a0, -0x8D00             // a0 = adjusted address of sound_type_J table (later on is lhu a0, 0x8D00(a0))
            b       _end                        // skip to end
            nop

            _original:
            lui     a0, 0x8013                  // original a0

            _end:
            addu    t3, t0, t2                  // original line 1
            addu    a0, a0, t3                  // original line 2
            j       _apply_sound_type_return    // return
            nop
        }
    }

    // @ Description
    // Holds variant character IDs in an array representing the d-pad directions for each character
    scope variants {
        constant DU(0x0000)
        constant DD(0x0001)
        constant DL(0x0002)
        constant DR(0x0003)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        //  D-UP        //  D-DOWN       //  D-LEFT     //  D-RIGHT
        db  id.METAL;   db  id.NMARIO;   db  id.JMARIO; db  id.NONE        // 0x00 - MARIO
        db  id.PEPPY;   db  id.NFOX;     db  id.JFOX;   db  id.NONE        // 0x01 - FOX
        db  id.GDONKEY; db  id.NDONKEY;  db  id.JDK;    db  id.NONE        // 0x02 - DONKEY
        db  id.NONE;    db  id.NSAMUS;   db  id.JSAMUS; db  id.ESAMUS      // 0x03 - SAMUS
        db  id.MLUIGI;  db  id.NLUIGI;   db  id.JLUIGI; db  id.NONE        // 0x04 - LUIGI
        db  id.BOSS;    db  id.NLINK;    db  id.JLINK;  db  id.ELINK       // 0x05 - LINK
        db  id.NONE;    db  id.NYOSHI;   db  id.JYOSHI; db  id.NONE        // 0x06 - YOSHI
        db  id.NONE;    db  id.NCAPTAIN; db  id.JFALCON;db  id.NONE        // 0x07 - CAPTAIN
        db  id.PIANO;    db  id.NKIRBY;   db  id.JKIRBY; db  id.NONE        // 0x08 - KIRBY
        db  id.NONE;    db  id.NPIKACHU; db  id.JPIKA;  db  id.EPIKA       // 0x09 - PIKACHU
        db  id.NONE;    db  id.NJIGGLY;  db  id.JPUFF;  db  id.EPUFF       // 0x0A - JIGGLY
        db  id.NONE;    db  id.NNESS;    db  id.JNESS;  db  id.NONE        // 0x0B - NESS
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x0C - BOSS
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x0D - METAL
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x0E - NMARIO
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x0F - NFOX
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x10 - NDONKEY
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x11 - NSAMUS
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x12 - NLUIGI
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x13 - NLINK
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x14 - NYOSHI
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x15 - NCAPTAIN
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x16 - NKIRBY
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x17 - NPIKACHU
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x18 - NJIGGLY
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x19 - NNESS
        db  id.NONE;    db  id.NONE;     db  id.NONE;   db  id.NONE        // 0x1A - GDONKEY
        // pad table for new characters
        fill table + (NUM_CHARACTERS * 4) - pc(), id.NONE
    }

    // @ Description
    // Variant type
    scope variant_type {
        constant NA(0x00)
        constant POLYGON(0x01)
        constant J(0x02)
        constant E(0x03)
        constant SPECIAL(0x04)
        constant UNUSED(0xFF)
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        fill 0xC, NA  // MARIO - NESS
        db  SPECIAL   // 0x0C - BOSS
        db  SPECIAL   // 0x0D - METAL
        db  POLYGON   // 0x0E - NMARIO
        db  POLYGON   // 0x0F - NFOX
        db  POLYGON   // 0x10 - NDONKEY
        db  POLYGON   // 0x11 - NSAMUS
        db  POLYGON   // 0x12 - NLUIGI
        db  POLYGON   // 0x13 - NLINK
        db  POLYGON   // 0x14 - NYOSHI
        db  POLYGON   // 0x15 - NCAPTAIN
        db  POLYGON   // 0x16 - NKIRBY
        db  POLYGON   // 0x17 - NPIKACHU
        db  POLYGON   // 0x18 - NJIGGLY
        db  POLYGON   // 0x19 - NNESS
        db  SPECIAL   // 0x1A - GDONKEY
        db  UNUSED    // 0X1B - PLACEHOLDER
        db  UNUSED    // 0X1C - PLACEHOLDER
        // pad table for new characters
        fill table + (NUM_CHARACTERS) - pc(), NA
    }

    // @ Description
    // Kirby hat IDs
    scope kirby_hat_id {
        constant NONE(0x00)
        constant SUCK(0x01)
        constant ROCK(0x02)

        constant MARIO(0x0C)
        constant FOX(0x07)
        constant DONKEY(0x04)
        constant DK(0x04)
        constant DONKEY_KONG(0x04)
        constant SAMUS(0x08)
        constant LUIGI(0x0B)
        constant LINK(0x0A)
        constant YOSHI(0x05)
        constant YOSHI_SWALLOW(0x0E)
        constant CAPTAIN(0x09)
        constant CAPTAIN_FALCON(0x09)
        constant FALCON(0x09)
        constant KIRBY(NONE)
        constant PIKACHU(0x06)
        constant JIGGLY(0x03)
        constant JIGGLYPUFF(0x03)
        constant NESS(0x0D)
        constant BOSS(NONE)
        constant METAL(NONE)
        constant NMARIO(NONE)
        constant NFOX(NONE)
        constant NDONKEY(NONE)
        constant NSAMUS(NONE)
        constant NLUIGI(NONE)
        constant NLINK(NONE)
        constant NYOSHI(NONE)
        constant NCAPTAIN(NONE)
        constant NKIRBY(NONE)
        constant NPIKACHU(NONE)
        constant NJIGGLY(NONE)
        constant NNESS(NONE)
        constant GDONKEY(DK)
    }

    // @ Description
    // Holds data related to Kirby's inhale moveset for added characters.
    // Each entry is 0xC.
    //  - 0x00 = copied power character_id (use Character.id.KIRBY for no copy)
    //  - 0x02 = copied power hat_id (use 0 for no copy)
    //  - 0x04 = scale for star
    //  - 0x08 = damage for star
    scope kirby_inhale_struct {
        scope star_scale {
            constant MARIO(0x3FC00000)
            constant FOX(0x3FC00000)
            constant DONKEY(0x40000000)
            constant DK(0x40000000)
            constant DONKEY_KONG(0x40000000)
            constant SAMUS(0x3FCCCCCD)
            constant LUIGI(0x3FCCCCCD)
            constant LINK(0x3FC00000)
            constant YOSHI(0x3FD9999A)
            constant CAPTAIN(0x3FD9999A)
            constant CAPTAIN_FALCON(0x3FD9999A)
            constant FALCON(0x3FD9999A)
            constant KIRBY(0x3FCCCCCD)
            constant PIKACHU(0x3FC00000)
            constant JIGGLY(0x3FCCCCCD)
            constant JIGGLYPUFF(0x3FCCCCCD)
            constant NESS(0x3FCCCCCD)
            constant BOSS(0x3F800000)
            constant METAL(MARIO)
            constant NMARIO(MARIO)
            constant NFOX(FOX)
            constant NDONKEY(DONKEY)
            constant NSAMUS(SAMUS)
            constant NLUIGI(LUIGI)
            constant NLINK(LINK)
            constant NYOSHI(YOSHI)
            constant NCAPTAIN(CAPTAIN)
            constant NKIRBY(KIRBY)
            constant NPIKACHU(PIKACHU)
            constant NJIGGLY(JIGGLY)
            constant NNESS(NESS)
            constant GDONKEY(DONKEY)
        }

        scope star_damage {
            constant DEFAULT(0x11)

            constant MARIO(DEFAULT)
            constant FOX(DEFAULT)
            constant DONKEY(0x1E)
            constant DK(0x1E)
            constant DONKEY_KONG(0x1E)
            constant SAMUS(DEFAULT)
            constant LUIGI(DEFAULT)
            constant LINK(DEFAULT)
            constant YOSHI(0x19)
            constant CAPTAIN(DEFAULT)
            constant CAPTAIN_FALCON(DEFAULT)
            constant FALCON(DEFAULT)
            constant KIRBY(DEFAULT)
            constant PIKACHU(DEFAULT)
            constant JIGGLY(DEFAULT)
            constant JIGGLYPUFF(DEFAULT)
            constant NESS(DEFAULT)
            constant BOSS(DEFAULT)
            constant METAL(MARIO)
            constant NMARIO(DEFAULT)
            constant NFOX(DEFAULT)
            constant NDONKEY(DONKEY)
            constant NSAMUS(DEFAULT)
            constant NLUIGI(DEFAULT)
            constant NLINK(DEFAULT)
            constant NYOSHI(DEFAULT)
            constant NCAPTAIN(DEFAULT)
            constant NKIRBY(DEFAULT)
            constant NPIKACHU(DEFAULT)
            constant NJIGGLY(DEFAULT)
            constant NNESS(DEFAULT)
            constant GDONKEY(0x32)
        }

        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        // char_id         // hat_id                        // star scale              // star damage
        dh id.MARIO;       dh kirby_hat_id.MARIO;           dw star_scale.MARIO;       dw star_damage.MARIO
        dh id.FOX;         dh kirby_hat_id.FOX;             dw star_scale.FOX;         dw star_damage.FOX
        dh id.DK;          dh kirby_hat_id.DK;              dw star_scale.DK;          dw star_damage.DK
        dh id.SAMUS;       dh kirby_hat_id.SAMUS;           dw star_scale.SAMUS;       dw star_damage.SAMUS
        dh id.LUIGI;       dh kirby_hat_id.LUIGI;           dw star_scale.LUIGI;       dw star_damage.LUIGI
        dh id.LINK;        dh kirby_hat_id.LINK;            dw star_scale.LINK;        dw star_damage.LINK
        dh id.YOSHI;       dh kirby_hat_id.YOSHI;           dw star_scale.YOSHI;       dw star_damage.YOSHI
        dh id.CAPTAIN;     dh kirby_hat_id.CAPTAIN;         dw star_scale.CAPTAIN;     dw star_damage.CAPTAIN
        dh id.KIRBY;       dh kirby_hat_id.KIRBY;           dw star_scale.KIRBY;       dw star_damage.KIRBY
        dh id.PIKACHU;     dh kirby_hat_id.PIKACHU;         dw star_scale.PIKACHU;     dw star_damage.PIKACHU
        dh id.JIGGLY;      dh kirby_hat_id.JIGGLY;          dw star_scale.JIGGLY;      dw star_damage.JIGGLY
        dh id.NESS;        dh kirby_hat_id.NESS;            dw star_scale.NESS;        dw star_damage.NESS
        dh id.KIRBY;       dh kirby_hat_id.BOSS;            dw star_scale.BOSS;        dw star_damage.BOSS
        dh id.KIRBY;       dh kirby_hat_id.METAL;           dw star_scale.METAL;       dw star_damage.METAL
        dh id.KIRBY;       dh kirby_hat_id.NMARIO;          dw star_scale.NMARIO;      dw star_damage.NMARIO
        dh id.KIRBY;       dh kirby_hat_id.NFOX;            dw star_scale.NFOX;        dw star_damage.NFOX
        dh id.KIRBY;       dh kirby_hat_id.NDONKEY;         dw star_scale.NDONKEY;     dw star_damage.NDONKEY
        dh id.KIRBY;       dh kirby_hat_id.NSAMUS;          dw star_scale.NSAMUS;      dw star_damage.NSAMUS
        dh id.KIRBY;       dh kirby_hat_id.NLUIGI;          dw star_scale.NLUIGI;      dw star_damage.NLUIGI
        dh id.KIRBY;       dh kirby_hat_id.NLINK;           dw star_scale.NLINK;       dw star_damage.NLINK
        dh id.KIRBY;       dh kirby_hat_id.NYOSHI;          dw star_scale.NYOSHI;      dw star_damage.NYOSHI
        dh id.KIRBY;       dh kirby_hat_id.NCAPTAIN;        dw star_scale.NCAPTAIN;    dw star_damage.NCAPTAIN
        dh id.KIRBY;       dh kirby_hat_id.NKIRBY;          dw star_scale.NKIRBY;      dw star_damage.NKIRBY
        dh id.KIRBY;       dh kirby_hat_id.NPIKACHU;        dw star_scale.NPIKACHU;    dw star_damage.NPIKACHU
        dh id.KIRBY;       dh kirby_hat_id.NJIGGLY;         dw star_scale.NJIGGLY;     dw star_damage.NJIGGLY
        dh id.KIRBY;       dh kirby_hat_id.NNESS;           dw star_scale.NNESS;       dw star_damage.NNESS
        dh id.DONKEY;      dh kirby_hat_id.GDONKEY;         dw star_scale.GDONKEY;     dw star_damage.GDONKEY
        fill ((2 + ADD_CHARACTERS) * 0xC) // make space for // 0x1B and 0x1C and all added characters
    }

    // @ Description
    // This table holds custom shield colors for each character's costume
    scope costume_shield_color {
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        dw MARIO         // MARIO
        dw FOX           // FOX
        dw DONKEY        // DONKEY
        dw SAMUS         // SAMUS
        dw LUIGI         // LUIGI
        dw LINK          // LINK
        dw YOSHI         // YOSHI
        dw CAPTAIN       // CAPTAIN
        dw KIRBY         // KIRBY
        dw PIKACHU       // PIKACHU
        dw JIGGLYPUFF    // JIGGLYPUFF
        dw NESS          // NESS
        dw 0             // BOSS
        dw METAL         // METAL
        dw POLYGON       // NMARIO
        dw POLYGON       // NFOX
        dw POLYGON       // NDONKEY
        dw POLYGON       // NSAMUS
        dw POLYGON       // NLUIGI
        dw POLYGON       // NLINK
        dw POLYGON       // NYOSHI
        dw POLYGON       // NCAPTAIN
        dw POLYGON       // NKIRBY
        dw POLYGON       // NPIKACHU
        dw POLYGON       // NJIGGLY
        dw POLYGON       // NNESS
        dw DONKEY        // GDONKEY
        // pad table for new characters
        fill table + (NUM_CHARACTERS * 4) - pc()

        MARIO:;     db 0x01, 0x03, 0x0D, 0x09, 0x05, 0x0F, 0x0D, 0x03
        FOX:;       db 0x0D, 0x02, 0x0A, 0x06, 0x0E, 0x07, 0x03, 0x0C
        DONKEY:;    db 0x0D, 0x0E, 0x01, 0x09, 0x06, 0x0C, 0x0F, 0x03
        SAMUS:;     db 0x02, 0x0C, 0x0E, 0x04, 0x09, 0x0F, 0x07, 0x03
        LUIGI:;     db 0x05, 0x0F, 0x07, 0x0C, 0x0A, 0x03, 0x03
        LINK:;      db 0x05, 0x0F, 0x01, 0x08, 0x0E, 0x03, 0x0C
        YOSHI:;     db 0x05, 0x01, 0x07, 0x03, 0x0C, 0x09, 0x0E, 0x0F
        CAPTAIN:;   db 0x01, 0x0A, 0x04, 0x0C, 0x0E, 0x09, 0x02, 0x0F
        KIRBY:;     db 0x0C, 0x03, 0x07, 0x01, 0x05, 0x0F, 0x0A
        PIKACHU:;   db 0x03, 0x01, 0x09, 0x05, 0x06, 0x06, 0x02, 0x04, 0x0A, 0x0C
        JIGGLYPUFF:;db 0x0D, 0x01, 0x09, 0x05, 0x06, 0x04, 0x02, 0x0A, 0x0E
        NESS:;      db 0x01, 0x03, 0x09, 0x05, 0x0F, 0x0A, 0x07
        METAL:;     db 0x0E, 0x01, 0x05, 0x09, 0x03, 0x02
        POLYGON:;   db 0x0A, 0x01, 0x06, 0x09, 0x0E, 0x0F, 0x03
        OS.align(4)
    }

    // @ Description
    // Common functions for when we add in remix polygons
	macro polygon_setup(name, remix_parent) {

		// Set crowd chant FGM to none
		Character.table_patch_start(crowd_chant_fgm, Character.id.{name}, 0x2)
		dh  0x02B7
		OS.patch_end()

        // Set Kirby hat_id
        Character.table_patch_start(kirby_inhale_struct, 0x2, Character.id.{name}, 0xC)
        dh 0x08
        OS.patch_end()

		// Set parent variant
		Character.table_patch_start(variant_original, Character.id.{name}, 0x4)
		dw      Character.id.{remix_parent}
		OS.patch_end()

        // set own variant
        Character.table_patch_start(variants, Character.id.{remix_parent}, 0x4)
        origin (origin() + 1)
        db Character.id.{name}
        OS.patch_end()

        Character.table_patch_start(variant_original, Character.id.{name}, 0x4)
        dw      Character.id.{remix_parent} // set parent character
        OS.patch_end()

		// Copy Parent's CPU behaviour pointer
		Character.table_patch_start(ai_behaviour, Character.id.{name}, 0x4)
		OS.copy_segment(Character.ai_behaviour.TABLE_ORIGIN + (Character.id.{remix_parent} * 0x4), 0x4)
		OS.patch_end()

		// Copy Parent's heavy attack CPU behaviour pointer
		Character.table_patch_start(ai_behaviour_heavy_attack, Character.id.{name}, 0x4)
		OS.copy_segment(Character.ai_behaviour_heavy_attack.TABLE_ORIGIN + (Character.id.{remix_parent} * 0x4), 0x4)
		OS.patch_end()

		// Copy Parent's ai behaviour pointer
		Character.table_patch_start(ai_behaviour, Character.id.{name}, 0x4)
		OS.copy_segment(Character.action_string.TABLE_ORIGIN + (Character.id.{remix_parent} * 0x4), 0x4)
		OS.patch_end()

		// Set default costumes
		Character.set_default_costumes(Character.id.{name}, 0, 1, 4, 5, 1, 3, 2)
        Teams.add_team_costume(YELLOW, {name}, 0x6)

        // Shield colors for costume matching
        Character.set_costume_shield_colors({name}, PURPLE, RED, GREEN, BLUE, BLACK, WHITE, YELLOW, NA)

        // Remove entry script.
        Character.table_patch_start(entry_script, Character.id.{name}, 0x4)
        dw 0x8013DD68                           // skips entry script
        OS.patch_end()

    }


    // @ Description
    // Jump table for Lvl 10 cpus to use instead of rolling
    scope close_quarter_combat {
		OS.align(4)
        table:
        constant TABLE_ORIGIN(origin())
        fill (Character.NUM_CHARACTERS * 0x4)
		OS.align(4)
    }

    // @ Description
    // This will allow us to quickly check if a character is capable of reflecting or absorbing a projectile
	scope fighter_reflect: {
		OS.align(4)
        table:
        constant TABLE_ORIGIN(origin())
		db OS.FALSE				// 0x00 - MARIO
		db OS.TRUE				// 0x01 - FOX
		db OS.FALSE				// 0x02 - DONKEY
		db OS.FALSE				// 0x03 - SAMUS
		db OS.FALSE				// 0x04 - LUIGI
		db OS.FALSE				// 0x05 - LINK
		db OS.FALSE				// 0x06 - YOSHI
		db OS.FALSE				// 0x07 - CAPTAIN
		db OS.FALSE				// 0x08 - KIRBY
		db OS.FALSE				// 0x09 - PIKACHU
		db OS.FALSE				// 0x0A - JIGGLY
		db OS.TRUE				// 0x0B - NESS
		db OS.FALSE				// 0x0C - BOSS
		db OS.FALSE				// 0x0D - METAL
		db OS.FALSE				// 0x0E - NMARIO
		db OS.FALSE				// 0x0F - NFOX
		db OS.FALSE				// 0x10 - NDONKEY
		db OS.FALSE				// 0x11 - NSAMUS
		db OS.FALSE				// 0x12 - NLUIGI
		db OS.FALSE				// 0x13 - NLINK
		db OS.FALSE				// 0x14 - NYOSHI
		db OS.FALSE				// 0x15 - NCAPTAIN
		db OS.FALSE				// 0x16 - NKIRBY
		db OS.FALSE				// 0x17 - NPIKACHU
		db OS.FALSE				// 0x18 - NJIGGLY
		db OS.TRUE				// 0x19 - NNESS
		db OS.FALSE				// 0x1A - GDONKEY
		db OS.FALSE				// 0x1B - None
		db OS.FALSE				// 0x1C - None
		// pad table for new characters
		fill (table + (NUM_CHARACTERS)) - pc()
		OS.align(4)
	}

    // @ Description
    // Magnifying Glass Scale Override
    // Normally, it's 0x91 - setting to above 91 makes it larger, below makes it smaller
    scope magnifying_glass_zoom {
        OS.align(16)
        table:
        constant TABLE_ORIGIN(origin())
        fill 0x1D * 2  // Vanilla chars + 2 unused
        // pad table for new characters
        fill table + (NUM_CHARACTERS * 2) - pc()
        OS.align(4)
    }

    // @ Description
    // Adds a 32-bit signed int to the player's percentage
    // the game will crash if the player's % goes below 0
    // @ Arguments
    // a0 - address of the player struct
    // a1 - percentage to add to the player
    // @ Note
    // This function is not safe by STYLE.md conventions so it has been wrapped
    scope add_percent_: {
        OS.save_registers()
        jal     0x800EA248
        nop
        OS.restore_registers()
        jr      ra
        nop
    }

    // @ Description
    // Returns the address of the player struct for the given port.
    // @ Arguments
    // a0 - player port (p1 = 0, p4 = 3)
    // @ Returns
    // v0 - address of player X struct, or 0 if no struct found for player X
    scope port_to_struct_: {
        constant FIRST_PLAYER_PTR(0x800466FC)

        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0008(sp)              // store t0

        li      v0, FIRST_PLAYER_PTR        // v0 = address of player object list head
        lw      v0, 0x0000(v0)              // v0 = address of first player object

        _loop:
        // a0 = port to check for
        // v0 = player struct to compare against
        beqz    v0, _end                    // exit loop if v0 does not contain an object pointer
        nop
        lw      t0, 0x0084(v0)              // t0 = address of player struct for given object
        lbu     t0, 0x000D(t0)              // t0 = first struct port
        beql    t0, a0, _end                // exit loop if struct port id matches given port id...
        lw      v0, 0x0084(v0)              // ...and return address of player struct for the current object
        b       _loop
        lw      v0, 0x0004(v0)              // v0 = next object

        _end:
        lw      t0, 0x0008(sp)              // load t0
        addiu   sp, sp, 0x0010              // deallocate stack space
        jr      ra                          // return
        nop
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// ADD CHARACTERS ////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////
    print "=============================== CHARACTERS =============================== \n"

    // move mario's action parameter array
    move_mario_parameter_array()

    // add mario clones (for unusable ids 0x1B and 0x1C)
    pushvar origin, base
    origin  STRUCT_TABLE_END
    dw 0x80117810
    dw 0x80117810
    variable STRUCT_TABLE_END(origin())
    pullvar base, origin

    // set up SEGMENT_SIZE_TABLE
    OS.align(16)
    SEGMENT_SIZE_TABLE:
    fill (NUM_CHARACTERS * 0xC)
    SEGMENT_SIZE_TABLE_END:
    OS.align(16)

    // set up ACTION_ARRAY_TABLE
    OS.align(16)
    ACTION_ARRAY_TABLE:
    constant ACTION_ARRAY_TABLE_ORIGIN(origin())
    OS.copy_segment(ACTION_ARRAY_TABLE_ORIGINAL, (27 * 4))
    fill (ACTION_ARRAY_TABLE + (NUM_CHARACTERS * 0x4)) - pc()
    OS.align(16)

    // extend kirby's action arrays
    extend_kirby_arrays(126)

    // set up extended high score table
    OS.align(16)
    EXTENDED_HIGH_SCORE_TABLE_BLOCK:; SRAM.block((NUM_CHARACTERS - 12) * 0x20)   // exclude original 12 characters
    constant EXTENDED_HIGH_SCORE_TABLE(EXTENDED_HIGH_SCORE_TABLE_BLOCK + 0x0010)
    // set up high score table for Remix 1p
    OS.align(16)
    REMIX_1P_HIGH_SCORE_TABLE_BLOCK:; SRAM.block((NUM_CHARACTERS) * 0x20)   // include all characters
    constant REMIX_1P_HIGH_SCORE_TABLE(REMIX_1P_HIGH_SCORE_TABLE_BLOCK + 0x0010)
    // set up high score table for Allstar
    OS.align(16)
    ALLSTAR_HIGH_SCORE_TABLE_BLOCK:; SRAM.block((NUM_CHARACTERS) * 0x20)   // include all characters
    constant ALLSTAR_HIGH_SCORE_TABLE(ALLSTAR_HIGH_SCORE_TABLE_BLOCK + 0x0010)

    // set up custom character bonus stages
    OS.align(16)
    BTT_TABLE:
    constant BTT_TABLE_ORIGIN(origin())
    db Stages.id.BTT_MARIO               // MARIO
    db Stages.id.BTT_FOX                 // FOX
    db Stages.id.BTT_DONKEY_KONG         // DONKEY KONG
    db Stages.id.BTT_SAMUS               // SAMUS
    db Stages.id.BTT_LUIGI               // LUIGI
    db Stages.id.BTT_LINK                // LINK
    db Stages.id.BTT_YOSHI               // YOSHI
    db Stages.id.BTT_FALCON              // CAPTAIN FALCON
    db Stages.id.BTT_KIRBY               // KIRBY
    db Stages.id.BTT_PIKACHU             // PIKACHU
    db Stages.id.BTT_JIGGLYPUFF          // JIGGLYPUFF
    db Stages.id.BTT_NESS                // NESS
    db 0xFF                              // MASTERHAND
    db Stages.id.BTT_MARIO               // METAL MARIO
    db Stages.id.BTT_STG1            // NMARIO
    db Stages.id.BTT_STG1            // NFOX
    db Stages.id.BTT_STG1            // NDONKEY
    db Stages.id.BTT_STG1            // NSAMUS
    db Stages.id.BTT_STG1            // NLUIGI
    db Stages.id.BTT_STG1            // NLINK
    db Stages.id.BTT_STG1            // NYOSHI
    db Stages.id.BTT_STG1            // NCAPTAIN
    db Stages.id.BTT_STG1            // NKIRBY
    db Stages.id.BTT_STG1            // NPIKACHU
    db Stages.id.BTT_STG1            // NJIGGLY
    db Stages.id.BTT_STG1            // NNESS
    db Stages.id.BTT_DONKEY_KONG         // GDONKEY
    db 0xFF                              // PLACEHOLDER
    db 0xFF                              // PLACEHOLDER
    // we'll fill with 0xFF to purposely ignore ones we don't explicitly set
    fill ADD_CHARACTERS, 0xFF
    OS.align(16)
    BTP_TABLE:
    constant BTP_TABLE_ORIGIN(origin())
    db Stages.id.BTP_MARIO               // MARIO
    db Stages.id.BTP_FOX                 // FOX
    db Stages.id.BTP_DONKEY_KONG         // DONKEY KONG
    db Stages.id.BTP_SAMUS               // SAMUS
    db Stages.id.BTP_LUIGI               // LUIGI
    db Stages.id.BTP_LINK                // LINK
    db Stages.id.BTP_YOSHI               // YOSHI
    db Stages.id.BTP_FALCON              // CAPTAIN FALCON
    db Stages.id.BTP_KIRBY               // KIRBY
    db Stages.id.BTP_PIKACHU             // PIKACHU
    db Stages.id.BTP_JIGGLYPUFF          // JIGGLYPUFF
    db Stages.id.BTP_NESS                // NESS
    db 0xFF                              // MASTERHAND
    db Stages.id.BTP_MARIO               // METAL MARIO
    db Stages.id.BTP_POLY                // NMARIO
    db Stages.id.BTP_POLY                // NFOX
    db Stages.id.BTP_POLY                // NDONKEY
    db Stages.id.BTP_POLY                // NSAMUS
    db Stages.id.BTP_POLY                // NLUIGI
    db Stages.id.BTP_POLY                // NLINK
    db Stages.id.BTP_POLY                // NYOSHI
    db Stages.id.BTP_POLY                // NCAPTAIN
    db Stages.id.BTP_POLY                // NKIRBY
    db Stages.id.BTP_POLY                // NPIKACHU
    db Stages.id.BTP_POLY                // NJIGGLY
    db Stages.id.BTP_POLY                // NNESS
    db Stages.id.BTP_DONKEY_KONG         // GDONKEY
    db 0xFF                              // PLACEHOLDER
    db 0xFF                              // PLACEHOLDER
    // we'll fill with 0xFF to purposely ignore ones we don't explicitly set
    fill ADD_CHARACTERS, 0xFF
    OS.align(16)

    // set up alternate bonus stages for Remix 1P
    OS.align(16)
    REMIX_BTT_TABLE:
    constant REMIX_BTT_TABLE_ORIGIN(origin())
    db Stages.id.BTT_DONKEY_KONG         // MARIO
    db Stages.id.BTT_DS                  // FOX
    db Stages.id.BTT_SAMUS               // DONKEY KONG
    db Stages.id.BTT_LUIGI               // SAMUS
    db Stages.id.BTT_BOWSER              // LUIGI
    db Stages.id.BTT_YOSHI               // LINK
    db Stages.id.BTT_LINK                // YOSHI
    db Stages.id.BTT_FALCO               // CAPTAIN FALCON
    db Stages.id.BTT_WARIO               // KIRBY
    db Stages.id.BTT_SAMUS               // PIKACHU
    db Stages.id.BTT_FOX                 // JIGGLYPUFF
    db Stages.id.BTT_YL                  // NESS
    db 0xFF                              // MASTERHAND
    db Stages.id.BTT_MARIO               // METAL MARIO
    db Stages.id.BTT_STG1            // NMARIO
    db Stages.id.BTT_STG1            // NFOX
    db Stages.id.BTT_STG1            // NDONKEY
    db Stages.id.BTT_STG1            // NSAMUS
    db Stages.id.BTT_STG1            // NLUIGI
    db Stages.id.BTT_STG1            // NLINK
    db Stages.id.BTT_STG1            // NYOSHI
    db Stages.id.BTT_STG1            // NCAPTAIN
    db Stages.id.BTT_STG1            // NKIRBY
    db Stages.id.BTT_STG1            // NPIKACHU
    db Stages.id.BTT_STG1            // NJIGGLY
    db Stages.id.BTT_STG1            // NNESS
    db Stages.id.BTT_SAMUS               // GDONKEY
    db 0xFF                              // PLACEHOLDER
    db 0xFF                              // PLACEHOLDER
    // we'll fill with 0xFF to purposely ignore ones we don't explicitly set
    fill ADD_CHARACTERS, 0xFF
    OS.align(16)
    REMIX_BTP_TABLE:
    constant REMIX_BTP_TABLE_ORIGIN(origin())
    db Stages.id.BTP_BOWSER              // MARIO
    db Stages.id.BTP_FALCON              // FOX
    db Stages.id.BTP_LINK                // DONKEY KONG
    db Stages.id.BTP_LUIGI               // SAMUS
    db Stages.id.BTP_LUCAS2              // LUIGI
    db Stages.id.BTP_YOSHI               // LINK
    db Stages.id.BTP_KIRBY               // YOSHI
    db Stages.id.BTP_DS                  // CAPTAIN FALCON
    db Stages.id.BTP_PIKACHU             // KIRBY
    db Stages.id.BTP_NESS                // PIKACHU
    db Stages.id.BTP_WARIO               // JIGGLYPUFF
    db Stages.id.BTP_PIKACHU             // NESS
    db 0xFF                              // MASTERHAND
    db Stages.id.BTP_BOWSER              // METAL MARIO
    db Stages.id.BTP_POLY                // NMARIO
    db Stages.id.BTP_POLY                // NFOX
    db Stages.id.BTP_POLY                // NDONKEY
    db Stages.id.BTP_POLY                // NSAMUS
    db Stages.id.BTP_POLY                // NLUIGI
    db Stages.id.BTP_POLY                // NLINK
    db Stages.id.BTP_POLY                // NYOSHI
    db Stages.id.BTP_POLY                // NCAPTAIN
    db Stages.id.BTP_POLY                // NKIRBY
    db Stages.id.BTP_POLY                // NPIKACHU
    db Stages.id.BTP_POLY                // NJIGGLY
    db Stages.id.BTP_POLY                // NNESS
    db Stages.id.BTP_LINK                // GDONKEY
    db 0xFF                              // PLACEHOLDER
    db 0xFF                              // PLACEHOLDER
    // we'll fill with 0xFF to purposely ignore ones we don't explicitly set
    fill ADD_CHARACTERS, 0xFF
    OS.align(16)

    // set up a high score table for multi-man mode
    MULTIMAN_HIGH_SCORE_TABLE_BLOCK:; SRAM.block((NUM_CHARACTERS) * 0x0004)   //
    constant MULTIMAN_HIGH_SCORE_TABLE(MULTIMAN_HIGH_SCORE_TABLE_BLOCK + 0x0010)
    OS.align(16)

    // set up a high score table for multi-man mode
    CRUEL_HIGH_SCORE_TABLE_BLOCK:; SRAM.block((NUM_CHARACTERS) * 0x0004)   //
    constant CRUEL_HIGH_SCORE_TABLE(CRUEL_HIGH_SCORE_TABLE_BLOCK + 0x0010)
    OS.align(16)

    // set up a high score table for Bonus 3
    BONUS3_HIGH_SCORE_TABLE_BLOCK:; SRAM.block((NUM_CHARACTERS) * 0x0004)   //
    constant BONUS3_HIGH_SCORE_TABLE(BONUS3_HIGH_SCORE_TABLE_BLOCK + 0x0010)
    OS.align(16)

    // set up a high score table for HRC
    HRC_HIGH_SCORE_TABLE_BLOCK:; SRAM.block((NUM_CHARACTERS) * 0x0004)   //
    constant HRC_HIGH_SCORE_TABLE(HRC_HIGH_SCORE_TABLE_BLOCK + 0x0010)
    OS.align(16)

    // set up constants for existing characters
    define_character(METAL)
    define_character(NMARIO)
    define_character(NFOX)
    define_character(NDONKEY)
    define_character(NSAMUS)
    define_character(NLUIGI)
    define_character(NLINK)
    define_character(NYOSHI)
    define_character(NCAPTAIN)
    define_character(NKIRBY)
    define_character(NPIKACHU)
    define_character(NJIGGLY)
    define_character(NNESS)
    define_character(GDONKEY)

    // Fix menu actions for MM, GDK and Polygons by copying them from the base character
    copy_menu_actions(MARIO, METAL, 1, 13)
    copy_menu_actions(MARIO, NMARIO, 1, 13)
    copy_menu_actions(FOX, NFOX, 1, 13)
    copy_menu_actions(DONKEY, NDONKEY, 1, 13)
    copy_menu_actions(SAMUS, NSAMUS, 1, 13)
    copy_menu_actions(LUIGI, NLUIGI, 1, 13)
    copy_menu_actions(LINK, NLINK, 1, 13)
    copy_menu_actions(YOSHI, NYOSHI, 1, 13)
    copy_menu_actions(CAPTAIN, NCAPTAIN, 1, 13)
    copy_menu_actions(KIRBY, NKIRBY, 1, 13)
    copy_menu_actions(PIKACHU, NPIKACHU, 1, 13)
    copy_menu_actions(JIGGLYPUFF, NJIGGLY, 1, 13)
    copy_menu_actions(NESS, NNESS, 1, 13)

    pushvar base, origin

    // NLUIGI, NJIGGLY and GDONKEY do not have full menu arrays.
    // GDK will share the menu array of DK, and the other two get a new array via copy_menu_actions.
    origin  0x97A4C + 0x68; OS.copy_segment(0x9648C + 0x68, 0x4) // GDONKEY

    // Make sure Masterhand appears correctly over Link
    origin variant_original.TABLE_ORIGIN + (id.BOSS * 4)
    dw      id.LINK

    // When no character is hovered on CSS, we want no variant indicators to display
    origin variant_original.TABLE_ORIGIN + (id.NONE * 4)
    dw      id.NONE

    pullvar origin, base

    // Modifies the Various Menu Actions of Polygons to Remove their Noises

    // METAL
    // Modify Menu Action Parameters                    // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(METAL,        0x1,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(METAL,        0x2,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(METAL,        0x3,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(METAL,        0x4,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(METAL,        0xE,                -1,                         0x80000000,                 -1)

    // NMARIO
    // Modify Menu Action Parameters                    // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NMARIO,       0x1,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NMARIO,       0x2,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NMARIO,       0x3,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NMARIO,       0x4,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NMARIO,       0xE,                -1,                         0x80000000,                 -1)

    // NFOX
    Character.edit_menu_action_parameters(NFOX,         0x1,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NFOX,         0x2,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NFOX,         0x3,                -1,                         0x80000000,                 -1)
	Character.edit_menu_action_parameters(NFOX,         0x4,                -1,                         0x80000000,                 -1)

    // NDK
    // Modify Menu Action Parameters                    // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NDONKEY,      0x1,                -1,                         0x80000000,                 -1)

    // NLUIGI
    // Modify Menu Action Parameters                    // Action           // Animation                // Moveset Data             // Flags
    Character.edit_menu_action_parameters(NLUIGI,       0x1,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NLUIGI,       0x2,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NLUIGI,       0x3,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NLUIGI,       0x4,                -1,                         0x80000000,                 -1)
    Character.edit_menu_action_parameters(NLUIGI,       0xE,                -1,                         0x80000000,                 -1)

    // NYOSHI
    Character.edit_menu_action_parameters(NYOSHI,       0x1,               -1,                          0x80000000,                 -1)
    Character.edit_menu_action_parameters(NYOSHI,       0x2,               -1,                          0x80000000,                 -1)
    Character.edit_menu_action_parameters(NYOSHI,       0x3,               -1,                          0x80000000,                 -1)

    // NCAPTAIN
    Character.edit_menu_action_parameters(NCAPTAIN,     0x1,               -1,                          0x80000000,                 -1)
    Character.edit_menu_action_parameters(NCAPTAIN,     0x2,               -1,                          0x80000000,                 -1)
    Character.edit_menu_action_parameters(NCAPTAIN,     0x3,               -1,                          0x80000000,                 -1)
    Character.edit_menu_action_parameters(NCAPTAIN,     0x4,               -1,                          0x80000000,                 -1)

    // set up custom characters
    // define_character(name, parent, file_1, file_2, file_3, file_4, file_5, file_6, file_7, file_8, file_9, attrib_offset, add_actions, bool_jab_3)
    // name - character name
    // parent - parent character name
    // file_1 - File ID (main file)
    // file_2 - File ID (primary moveset)
    // file_3 - File ID (secondary moveset)
    // file_4 - File ID (character/model file)
    // file_5 - File ID (shield pose)
    // note: miscellaneous files are used for things like entry animation, projectile data and
    // special graphics, but seemingly not with a fixed structure
    // file_6 - File ID (miscellaneous)
    // file_7 - File ID (miscellaneous)
    // file_8 - File ID (miscellaneous)
    // file_9 - File ID (miscellaneous)
    // attrib_offset - offset of attributes in file_1
    // add_actions - number of new action slots to add
    // bool_jab_3 - OS.TRUE = inherit jab 3 properties, OS.FALSE = disable jab 3
    // bool_inhale_copy - OS.TRUE = enable Kirby inhale copy, OS.FALSE = disable Kirby inhale copy
    // btt_stage_id - stage_id for btt, or -1 if N/A
    // btp_stage_id - stage_id for btp, or -1 if N/A
    // remix_btt_stage_id - stage_id for btt, or -1 if N/A
    // remix_btp_stage_id - stage_id for btp, or -1 if N/A
    // sound_type - type of sounds to use (see sound_type table)
    // variant_type - type of variant (see variant_type table)

    // 0x1D - FALCO
    define_character(FALCO, FOX, File.FALCO_MAIN, 0x0D0, 0, File.FALCO_CHARACTER, 0x13A, 0x0D2, 0x15A, 0x0A1, 0x013C, 0x474, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_FALCO, Stages.id.BTP_FALCO, Stages.id.BTT_FALCON, Stages.id.BTP_GND, sound_type.U, variant_type.NA)
    // 0x1E - GND
    define_character(GND, CAPTAIN, File.GND_MAIN, 0x0EB, 0, File.GND_CHARACTER, 0x14E, 0, File.GND_ENTRY_KICK, File.GND_PUNCH_GRAPHIC, 0, 0x488, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_GND, Stages.id.BTP_GND, Stages.id.BTT_FALCON, Stages.id.BTP_YOSHI, sound_type.U, variant_type.NA)
    // 0x1F - YLINK
    define_character(YLINK, LINK, File.YLINK_MAIN, 0x0E0, 0, File.YLINK_CHARACTER, 0x147, File.YLINK_BOOMERANG_HITBOX, File.YLINK_SPECIAL_GRAPHIC, 0x145, 0, 0x760, 0, OS.TRUE, OS.TRUE, Stages.id.BTT_YL, Stages.id.BTP_YL, Stages.id.BTT_DRM, Stages.id.BTP_DRM, sound_type.U, variant_type.NA)
    // 0x20 - DRM
    define_character(DRM, MARIO, File.DRM_MAIN, 0x0CA, 0, File.DRM_CHARACTER, 0x12A, File.DRM_PROJECTILE_DATA, 0x164, File.DRM_PROJECTILE_GRAPHIC, 0, 0x454, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_DRM, Stages.id.BTP_DRM, Stages.id.BTT_YL, Stages.id.BTP_YL, sound_type.U, variant_type.NA)
    // 0x21 - WARIO
    define_character(WARIO, MARIO, File.WARIO_MAIN, 0x0CA, 0, File.WARIO_CHARACTER, 0x12A, 0x0CC, 0x164, 0x129, 0, 0x51C, 2, OS.FALSE, OS.TRUE, Stages.id.BTT_WARIO, Stages.id.BTP_WARIO, Stages.id.BTT_JIGGLYPUFF, Stages.id.BTP_JIGGLYPUFF,sound_type.U, variant_type.NA)
    // 0x22 - DSAMUS
    define_character(DSAMUS, SAMUS, File.DSAMUS_MAIN, 0x0D8, 0, File.DSAMUS_CHARACTER, 0x142, 0x15D, File.DSAMUS_SECONDARY, 0, 0, 0x6B4, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_DS, Stages.id.BTP_DS, Stages.id.BTT_LUCAS, Stages.id.BTP_LUCAS2, sound_type.U, variant_type.NA)
    // 0x23 - ELINK
    define_character(ELINK, LINK, File.ELINK_MAIN, 0x0E0, 0, 0x144, 0x147, 0x0E2, 0x161, 0x145, 0, 0x708, 0, OS.TRUE, OS.TRUE, Stages.id.BTT_LINK, Stages.id.BTP_LINK, Stages.id.BTT_YL, Stages.id.BTP_YL, sound_type.U, variant_type.E)
    // 0x24 - JSAMUS
    define_character(JSAMUS, SAMUS, 0x0D9, 0x0D8, 0, 0x140, 0x142, 0x15D, 0x0DA, 0, 0, 0x610, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_SAMUS, Stages.id.BTP_SAMUS, Stages.id.BTT_DS, Stages.id.BTP_DS,sound_type.J, variant_type.J)
    // 0x25 - JNESS
    define_character(JNESS, NESS, File.JNESS_MAIN, 0x0EE, 0, 0x14F, 0x150, 0x160, File.JNESS_PKFIRE, 0x151, 0, 0x5BC, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_NESS, Stages.id.BTP_NESS, Stages.id.BTT_LUCAS, Stages.id.BTP_LUCAS2, sound_type.J, variant_type.J)
    // 0x26 - LUCAS
    define_character(LUCAS, NESS, File.LUCAS_MAIN, 0x0EE, 0, File.LUCAS_CHARACTER, 0x150, 0x160, File.LUCAS_PKFIRE, 0x151, 0, 0x614, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_LUCAS, Stages.id.BTP_LUCAS2, Stages.id.BTT_WARIO, Stages.id.BTP_DS, sound_type.U, variant_type.NA)
    // 0x27 - JLINK
    define_character(JLINK, LINK, File.JLINK_MAIN, 0x0E0, 0, File.JLINK_CHARACTER, 0x147, 0x0E2, 0x161, 0x145, 0, 0x708, 0, OS.TRUE, OS.TRUE, Stages.id.BTT_LINK, Stages.id.BTP_LINK, Stages.id.BTT_YL, Stages.id.BTP_YL, sound_type.J, variant_type.J)
    // 0x28 - JFALCON
    define_character(JFALCON, CAPTAIN, File.JFALCON_MAIN, 0x0EB, 0, 0x14C, 0x14E, 0, 0x15E, 0x14D, 0, 0x488, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_FALCON, Stages.id.BTP_FALCON, Stages.id.BTT_GND, Stages.id.BTP_GND, sound_type.J, variant_type.J)
    // 0x29 - JFOX
    define_character(JFOX, FOX, File.JFOX_MAIN, 0x0D0, 0, 0x139, 0x13A, File.JFOX_PROJECTILE, 0x15A, 0x0A1, 0x013C, 0x46C, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_FOX, Stages.id.BTP_FOX, Stages.id.BTT_FALCO, Stages.id.BTP_FALCO, sound_type.J, variant_type.J)
    // 0x2A - JMARIO
    define_character(JMARIO, MARIO, File.JMARIO_MAIN, 0x0CA, 0, File.JMARIO_CHARACTER, 0x12A, File.JMARIO_PROJECTILE_HITBOX, 0x164, 0x129, 0, 0x428, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_MARIO, Stages.id.BTP_MARIO, Stages.id.BTT_DRM, Stages.id.BTP_DRM, sound_type.J, variant_type.J)
    // 0x2B - JLUIGI
    define_character(JLUIGI, LUIGI, File.JLUIGI_MAIN, 0x0DC, 0, File.JLUIGI_CHARACTER, 0x12A, File.JLUIGI_PROJECTILE_HITBOX, 0x164, 0x129, 0, 0x580, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_LUIGI, Stages.id.BTP_LUIGI, Stages.id.BTT_MARIO, Stages.id.BTP_MARIO, sound_type.J, variant_type.J)
    // 0x2C - JDK
    define_character(JDK, DONKEY, File.JDK_MAIN, 0x0D4, 0, 0x13D, 0x13E, 0, 0x163, 0, 0, 0x4A4, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_DONKEY_KONG, Stages.id.BTP_DONKEY_KONG, Stages.id.BTT_BOWSER, Stages.id.BTP_BOWSER, sound_type.J, variant_type.J)
    // 0x2D - EPIKA
    define_character(EPIKA, PIKACHU, File.EPIKA_MAIN, 0x0F2, 0, 0x155, 0x157, 0x0F4, 0x15B, 0x156, 0, 0x41C, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_PIKACHU, Stages.id.BTP_PIKACHU, Stages.id.BTT_JIGGLYPUFF, Stages.id.BTP_JIGGLYPUFF, sound_type.U, variant_type.E)
    // 0x2E - JPUFF
    define_character(JPUFF, JIGGLYPUFF, File.JPUFF_MAIN, 0x0E8, 0, 0x14A, 0x14B, 0, 0x15F, 0, 0, 0x474, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_JIGGLYPUFF, Stages.id.BTP_JIGGLYPUFF, Stages.id.BTT_FALCO, Stages.id.BTP_MARIO, sound_type.J, variant_type.J)
    // 0x2F - EPUFF
    define_character(EPUFF, JIGGLYPUFF, File.EPUFF_MAIN, 0x0E8, 0, 0x14A, 0x14B, 0, 0x15F, 0, 0, 0x474, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_JIGGLYPUFF, Stages.id.BTP_JIGGLYPUFF, Stages.id.BTT_FALCO, Stages.id.BTP_MARIO, sound_type.U, variant_type.E)
    // 0x30 - JKIRBY
    define_character(JKIRBY, KIRBY, File.JKIRBY_MAIN, 0x0E4, 0, 0x148, 0x149, 0, 0x15C, 0, 0, 0x808, 0x93, OS.TRUE, OS.FALSE, Stages.id.BTT_KIRBY, Stages.id.BTP_KIRBY, Stages.id.BTT_FOX, Stages.id.BTP_FOX, sound_type.J, variant_type.J)
    // 0x31 - JYOSHI
    define_character(JYOSHI, YOSHI, File.JYOSHI_MAIN, 0x0F6, 0, 0x152, 0x154, 0, 0x162, 0x153, 0, 0x47C, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_YOSHI, Stages.id.BTP_YOSHI, Stages.id.BTT_FALCON, Stages.id.BTP_GND, sound_type.J, variant_type.J)
    // 0x32 - JPIKA
    define_character(JPIKA, PIKACHU, File.JPIKA_MAIN, 0x0F2, 0, 0x155, 0x157, File.JPIKA_PROJECTILE, 0x15B, 0x156, 0, 0x41C, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_PIKACHU, Stages.id.BTP_PIKACHU, Stages.id.BTT_JIGGLYPUFF, Stages.id.BTP_JIGGLYPUFF, sound_type.J, variant_type.J)
    // 0x33 - ESAMUS
    define_character(ESAMUS, SAMUS, File.ESAMUS_MAIN, 0x0D8, 0, 0x140, 0x142, 0x15D, 0x0DA, 0, 0, 0x610, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_SAMUS, Stages.id.BTP_SAMUS, Stages.id.BTT_LINK, Stages.id.BTP_MARIO, sound_type.U, variant_type.E)
    // 0x34 - BOWSER
    define_character(BOWSER, YOSHI, File.BOWSER_MAIN, 0x0F6, 0, File.BOWSER_CHARACTER, File.BOWSER_SHIELD_POSE, 0, File.BOWSER_CLOWN_COPTER, 0x153, 0, 0x47C, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_BOWSER, Stages.id.BTP_BOWSER, Stages.id.BTT_DONKEY_KONG, Stages.id.BTP_DONKEY_KONG, sound_type.U, variant_type.NA)
    // 0x35 - GBOWSER
    define_character(GBOWSER, YOSHI, File.GBOWSER_MAIN, 0x0F6, 0, File.GBOWSER_CHARACTER, File.BOWSER_SHIELD_POSE, 0, File.BOWSER_CLOWN_COPTER, 0x153, 0, 0x47C, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_BOWSER, Stages.id.BTP_BOWSER, Stages.id.BTT_DONKEY_KONG, Stages.id.BTP_DONKEY_KONG, sound_type.U, variant_type.SPECIAL)
    // 0x36 - PIANO
    define_character(PIANO, MARIO, File.PIANO_MAIN, 0x0CA, 0, File.PIANO_CHARACTER, 0x12A, File.PIANO_PROJECTILE_HITBOX, 0x164, 0x129, 0, 0x42C, 10, OS.FALSE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.SPECIAL)
    // 0x37 - WOLF
    define_character(WOLF, FOX, File.WOLF_MAIN, 0x0D0, 0, File.WOLF_CHARACTER, File.WOLF_SHIELD_POSE,  File.WOLF_PROJECTILE_HITBOX, File.WOLF_REFLECTOR, File.WOLFEN, File.WOLF_PROJECTILE_GRAPHIC, 0x4C4, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_WOLF, Stages.id.BTP_WOLF, Stages.id.BTT_FALCO, Stages.id.BTP_FALCO, sound_type.U, variant_type.NA)
    // 0x38 - CONKER
    define_character(CONKER, FOX, File.CONKER_MAIN, 0x0D0, 0, File.CONKER_CHARACTER, File.CONKER_SHIELD_POSE, File.CONKER_NUT_PROJECTILE_HITBOX, File.CONKER_GRENADE_PROJECTILE_HITBOX, File.GREGS_HAND, File.CONKER_NUT_PROJECTILE_GRAPHIC, 0x5DC, 6, OS.TRUE, OS.FALSE, Stages.id.BTT_CONKER, Stages.id.BTP_CONKER, Stages.id.BTT_FALCO, Stages.id.BTP_FALCO, sound_type.U, variant_type.NA)
    // 0x39 - MTWO
    define_character(MTWO, YOSHI, File.MTWO_MAIN, 0x0F6, 0, File.MTWO_CHARACTER, File.MTWO_SHIELD_POSE, 0, File.MTWO_USMASH_GRAPHIC, File.MTWO_SBALL_PROJECTILE_HITBOX, 0, 0x548, 6, OS.FALSE, OS.TRUE, Stages.id.BTT_MTWO, Stages.id.BTP_MTWO, Stages.id.BTT_DS, Stages.id.BTP_SAMUS, sound_type.U, variant_type.NA)
    // 0x3A - MARTH
    define_character(MARTH, CAPTAIN, File.MARTH_MAIN, 0x0EB, 0, File.MARTH_CHARACTER, File.MARTH_SHIELD, 0, 0x15E, File.MARTH_ENTRY_EFFECTS, 0, 0x524, 8, OS.FALSE, OS.TRUE, Stages.id.BTT_MARTH, Stages.id.BTP_MARTH, Stages.id.BTT_DRM, Stages.id.BTP_YL, sound_type.U, variant_type.NA)
    // 0x3B - SONIC
    define_character(SONIC, FOX, File.SONIC_MAIN, 0x0D0, 0, File.SONIC_CHARACTER, File.SONIC_SHIELD_POSE, File.SONIC_SPRING_HITBOX, File.CSONIC_MAIN, File.SONIC_ENTRY, File.SONIC_SPRING_GRAPHIC, 0x58C, 18, OS.TRUE, OS.TRUE, Stages.id.BTT_SONIC, Stages.id.BTP_SONIC, Stages.id.BTT_WARIO, Stages.id.BTP_DS, sound_type.U, variant_type.NA)
    // 0x3C - SANDBAG
    define_character(SANDBAG, CAPTAIN, File.SANDBAG_MAIN, 0x0EB, 0, 0x14C, 0x14E, 0, 0x15E, 0x14D, 0, 0x488, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_FALCON, Stages.id.BTP_FALCON, Stages.id.BTT_GND, Stages.id.BTP_GND, sound_type.U, variant_type.SPECIAL)
    // 0x3D - SUPER SONIC
    define_character(SSONIC, FOX, File.SSONIC_MAIN, 0x0D0, 0, File.SSONIC_CHARACTER, File.SONIC_SHIELD_POSE, File.SONIC_SPRING_HITBOX, 0x15A, File.SONIC_ENTRY, File.SONIC_SPRING_GRAPHIC, 0x58C, 18, OS.TRUE, OS.TRUE, Stages.id.BTT_SONIC, Stages.id.BTP_SONIC, Stages.id.BTT_WARIO, Stages.id.BTP_DS, sound_type.U, variant_type.SPECIAL)
    // 0x3E - SHEIK
    define_character(SHEIK, CAPTAIN, File.SHEIK_MAIN, 0x0EB, 0, File.SHEIK_CHARACTER, File.SHEIK_SHIELD_POSE, File.SHEIK_PROJECTILE_HITBOX, 0x15E, 0x14D, 0, 0x4B0, 0x5, OS.TRUE, OS.TRUE, Stages.id.BTT_SHEIK, Stages.id.BTP_SHEIK, Stages.id.BTT_LINK, Stages.id.BTP_LUCAS2, sound_type.U, variant_type.NA)
    // 0x3F - MARINA
    define_character(MARINA, CAPTAIN, File.MARINA_MAIN, 0x0EB, 0, File.MARINA_CHARACTER, File.MARINA_SHIELD_POSE, 0, 0x15E, File.MARINA_GEM_HITBOX, File.MARINA_ENTRY_GFX, 0x560, 30, OS.TRUE, OS.TRUE, Stages.id.BTT_MARINA, Stages.id.BTP_MARINA, Stages.id.BTT_DRM, Stages.id.BTP_SONIC, sound_type.U, variant_type.NA)
    // 0x40 - DEDEDE
    define_character(DEDEDE, CAPTAIN, File.DEDEDE_MAIN, 0x0EB, 0, File.DEDEDE_CHARACTER, File.DEDEDE_SHIELD_POSE, File.WADDLE_DEE_INFO, File.DEDEDE_STAR, 0, 0, 0x5A4, 0x16, OS.TRUE, OS.TRUE, Stages.id.BTT_DEDEDE, Stages.id.BTP_DEDEDE, Stages.id.BTT_MARTH, Stages.id.BTP_YL, sound_type.U, variant_type.NA)
    copy_gfx_parameters(DEDEDE, KIRBY)
    // 0x41 - GOEMON
    define_character(GOEMON, MARIO, File.GOEMON_MAIN, 0x0CA, 0, File.GOEMON_CHARACTER, File.GOEMON_SHIELD_POSE, File.GOEMON_RYO_HITBOX, File.GOEMON_CLOUD_INFO, File.GOEMON_RYO_GRAPHIC, File.GOEMON_ENTRY_GFX, 0x91C, 20, OS.TRUE, OS.TRUE, Stages.id.BTT_GOEMON, Stages.id.BTP_GOEMON, Stages.id.BTT_JIGGLYPUFF, Stages.id.BTP_JIGGLYPUFF,sound_type.U, variant_type.NA)
    // 0x42 - PEPPY
    define_character(PEPPY, FOX, File.PEPPY_MAIN, 0x0D0, 0, File.PEPPY_CHARACTER, 0x13A, File.PEPPY_LASER_HITBOX, 0x15A, 0x0A1, File.PEPPY_LASER_GFX, 0x474, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_FOX, Stages.id.BTP_FOX, Stages.id.BTT_FOX, Stages.id.BTP_FOX, sound_type.U, variant_type.SPECIAL)
    // 0x43 - SLIPPY
    define_character(SLIPPY, FOX, File.SLIPPY_MAIN, 0x0D0, 0, File.SLIPPY_CHARACTER, 0x13A, File.SLIPPY_LASER_HITBOX, File.SLIPPY_REFLECT_GFX, 0x0A1, File.SLIPPY_LASER_GRAPHIC, 0x4AC, 0x0, OS.TRUE, OS.TRUE, Stages.id.BTT_FALCO, Stages.id.BTP_FALCO, Stages.id.BTT_FALCO, Stages.id.BTP_FALCO, sound_type.U, variant_type.SPECIAL)
    // 0x44 - BANJO
    define_character(BANJO, CAPTAIN, File.BANJO_MAIN, 0x0EB, 0, File.BANJO_CHARACTER, 0x14C, File.BANJO_SHIELD_POSE, 0x15E, File.BANJO_ENTRY_EFFECTS, File.KAZOOIE_EGG_INFO, 0x898, 0x5, OS.TRUE, OS.TRUE, Stages.id.BTT_BANJO, Stages.id.BTP_BANJO, Stages.id.BTT_LINK, Stages.id.BTP_LUCAS2, sound_type.U, variant_type.NA)
    // 0x45 - METAL LUIGI
    define_character(MLUIGI, LUIGI, File.METAL_LUIGI_MAIN, 0x0DC, 0, File.METAL_LUIGI_CHARACTER, 0x12A, 0x0DE, 0x164, 0x129, 0, 0x418, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_LUIGI, Stages.id.BTP_LUIGI, Stages.id.BTT_LUIGI, Stages.id.BTP_LUIGI, sound_type.U, variant_type.SPECIAL)
    // 0x46 - EBISUMARU
    define_character(EBI, MARIO, File.EBISUMARU_MAIN, 0x0CA, 0, File.EBISUMARU_CHARACTER, File.GOEMON_SHIELD_POSE, File.GOEMON_RYO_HITBOX, File.GOEMON_CLOUD_INFO, File.GOEMON_RYO_GRAPHIC, File.GOEMON_ENTRY_GFX, 0x9C0, 20, OS.TRUE, OS.TRUE, Stages.id.BTT_GOEMON, Stages.id.BTP_GOEMON, Stages.id.BTT_GOEMON, Stages.id.BTP_GOEMON, sound_type.U, variant_type.SPECIAL)
    // 0x47 - DRAGONKING
    define_character(DRAGONKING, CAPTAIN, File.DRAGONKING_MAIN, 0x0EB, 0, File.DRAGONKING_CHARACTER, File.DRAGONKING_SHIELD_POSE, 0, 0x15B, 0x14D, 0, 0x488, 5, OS.TRUE, OS.TRUE, Stages.id.BTT_FALCON, Stages.id.BTP_FALCON, Stages.id.BTT_GND, Stages.id.BTP_GND, sound_type.J, variant_type.SPECIAL)
    // ADD NEW CHARACTERS HERE

    // REMIX POLYGONS
    // NWARIO
    define_character(NWARIO, MARIO, File.NWARIO_MAIN, 0x0CA, 0, File.NWARIO_CHARACTER, 0x12A, 0x0CC, 0x164, 0x129, 0, 0x2B0, 2, OS.FALSE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NLUCAS
    define_character(NLUCAS, NESS, File.NLUCAS_MAIN, 0x0EE, 0, File.NLUCAS_CHARACTER, 0x150, 0x160, File.LUCAS_PKFIRE, 0x151, 0, 0x308, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NBOWSER
    define_character(NBOWSER, YOSHI, File.NBOWSER_MAIN, 0x0F6, 0, File.NBOWSER_CHARACTER, File.BOWSER_SHIELD_POSE, 0, File.BOWSER_CLOWN_COPTER, 0x153, 0, 0x2D0, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NWOLF
    define_character(NWOLF, FOX, File.NWOLF_MAIN, 0x0D0, 0, File.NWOLF_CHARACTER, File.WOLF_SHIELD_POSE,  File.WOLF_PROJECTILE_HITBOX, File.WOLF_REFLECTOR, File.WOLFEN, File.WOLF_PROJECTILE_GRAPHIC, 0x2BC, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NDRM
    define_character(NDRM, MARIO, File.NDRM_MAIN, 0x0CA, 0, 0x012D, 0x12A, File.DRM_PROJECTILE_DATA, 0x164, File.DRM_PROJECTILE_GRAPHIC, 0, 0x2B0, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NSONIC
    define_character(NSONIC, FOX, File.NSONIC_MAIN, 0x0D0, 0, File.NSONIC_CHARACTER, File.SONIC_SHIELD_POSE, File.SONIC_SPRING_HITBOX, File.CSONIC_MAIN, File.SONIC_ENTRY, File.SONIC_SPRING_GRAPHIC, 0x30C, 18, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NSHEIK
    define_character(NSHEIK, CAPTAIN, File.NSHEIK_MAIN, 0x0EB, 0, File.NSHEIK_CHARACTER, File.SHEIK_SHIELD_POSE, 0, 0x15E, 0x14D, 0, 0x2B4, 0x5, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NMARINA
    define_character(NMARINA, CAPTAIN, File.NMARINA_MAIN, 0x0EB, 0, File.NMARINA_CHARACTER, File.MARINA_SHIELD_POSE, 0, 0x15E, 0, 0, 0x2B8, 30, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NFALCO
    define_character(NFALCO, FOX, File.NFALCO_MAIN, 0x0D0, 0, File.NFALCO_CHARACTER, 0x13A, 0x0D2, 0x15A, 0x0A1, 0x013C, 0x2BC, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NGND
    define_character(NGND, CAPTAIN, File.NGND_MAIN, 0x0EB, 0, File.NGND_CHARACTER, 0x14E, 0, File.GND_ENTRY_KICK, File.GND_PUNCH_GRAPHIC, 0, 0x32C, 0x5, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NDSAMUS
    define_character(NDSAMUS, SAMUS, File.NDSAMUS_MAIN, 0x0D8, 0, 0x135, 0x142, 0x15D, File.DSAMUS_SECONDARY, 0, 0, 0x3D4, 0x0, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NMARTH
    define_character(NMARTH, CAPTAIN, File.NMARTH_MAIN, 0x0EB, 0, File.NMARTH_CHARACTER, File.MARTH_SHIELD, 0, 0x15E, 0, 0, 0x2CC, 8, OS.FALSE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NMTWO
    define_character(NMTWO, YOSHI, File.NMTWO_MAIN, 0x0F6, 0, File.NMTWO_CHARACTER, File.MTWO_SHIELD_POSE, 0, File.MTWO_USMASH_GRAPHIC, 0, 0, 0x2D4, 6, OS.FALSE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NDEDEDE
    define_character(NDEDEDE, CAPTAIN, File.NDEDEDE_MAIN, 0x0EB, 0, File.NDEDEDE_CHARACTER, File.DEDEDE_SHIELD_POSE, 0, 0, 0, 0, 0x2B4, 0x16, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NYLINK
    define_character(NYLINK, LINK, File.NYLINK_MAIN, 0x0E0, 0, File.NYLINK_CHARACTER, 0x147, File.YLINK_BOOMERANG_HITBOX, File.YLINK_SPECIAL_GRAPHIC, 0x145, 0, 0x2F0, 0, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NGOEMON
    define_character(NGOEMON, MARIO, File.NGOEMON_MAIN, 0x0CA, 0, File.NGOEMON_CHARACTER,File.GOEMON_SHIELD_POSE, File.GOEMON_RYO_HITBOX, File.GOEMON_CLOUD_INFO, File.GOEMON_RYO_GRAPHIC, File.GOEMON_ENTRY_GFX, 0x3F0, 30, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NCONKER
    define_character(NCONKER, FOX, File.NCONKER_MAIN, 0x0D0, 0, File.NCONKER_CHARACTER, File.CONKER_SHIELD_POSE, File.CONKER_NUT_PROJECTILE_HITBOX, File.CONKER_GRENADE_PROJECTILE_HITBOX, File.GREGS_HAND, File.CONKER_NUT_PROJECTILE_GRAPHIC, 0x3FC, 6, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)
    // NBANJO
    define_character(NBANJO, CAPTAIN, File.NBANJO_MAIN, 0x0EB, 0, File.NBANJO_CHARACTER, 0x14C, File.BANJO_SHIELD_POSE, 0x15E, File.BANJO_ENTRY_EFFECTS, File.KAZOOIE_EGG_INFO, 0x4A8, 0x5, OS.TRUE, OS.FALSE, Stages.id.BTT_STG1, Stages.id.BTP_POLY, Stages.id.BTT_STG1, Stages.id.BTP_POLY, sound_type.U, variant_type.POLYGON)

    print "========================================================================== \n"
    print "# Remix Fighters = "; print "0x"; OS.print_hex(NUM_REMIX_FIGHTERS); print " \n";
    print "# New Polygons = "; print "0x"; OS.print_hex(NUM_POLYGONS); print " \n";
    print "========================================================================== \n"
}

} // __CHARACTER__
