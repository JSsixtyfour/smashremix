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
    constant ADD_CHARACTERS(4)
    // start and end offset for the main character struct table
    constant STRUCT_TABLE(0x92610)
    variable STRUCT_TABLE_END(STRUCT_TABLE + 0x6C)
    // original action array table
    constant ACTION_ARRAY_TABLE_ORIGINAL(0xA6F40)
    // shared action array
    constant SHARED_ACTION_ARRAY(0xA45D8)

    // total number of character slots (note 0x1B and 0x1C will be unused)
    constant NUM_CHARACTERS(27 + 2 + ADD_CHARACTERS)
    ///////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////// CHARACTER MACRO ///////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // @ Description
    // adds a new character
    macro define_character(name, parent, file_1, file_2, file_3, file_4, file_5, file_6, file_7, file_8, file_9, attrib_offset, add_actions, bool_jab_3) {
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

        // Get action array pointer and Rom offset of {parent}
        read32 {name}_parent_action_array_ptr, "../roms/original.z64", (ACTION_ARRAY_TABLE_ORIGINAL + (id.{parent} * 0x4))
        global evaluate {name}_parent_action_array({name}_parent_action_array_ptr - 0x80084800)
        

        // Action parameter array size
        constant {name}_param_array_size({name}_parent_param_array_size + {add_actions})

        // CHARACTER ID
        constant id.{name}((STRUCT_TABLE_END - STRUCT_TABLE) / 0x4)

        // Parent character name
        global define {name}_parent({parent})
        
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
        // parameters 0x4C - 0x60 are not well understood and are copied from the parent character
        OS.copy_segment(({name}_parent_struct + 0x4C), 0x14)
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
        OS.copy_segment({{name}_parent_action_array}, action_array_size.{parent} + ({add_actions} * 0x14))
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
        // Copy entry animation settings from parent cahracter
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
        
        // Copy parent character for menu tables  
        add_to_table(menu_zoom, id.{name}, id.{parent}, 0x4)
        add_to_table(default_costume, id.{name}, id.{parent}, 0x8)
        add_to_id_table(vs_record, id.{name}, id.{parent})
        add_to_table(winner_fgm, id.{name}, id.{parent}, 0x4)
        add_to_id_table(winner_logo, id.{name}, id.{parent})
        add_to_id_table(label_height, id.{name}, id.{parent})
        add_to_table(str_wins_lx, id.{name}, id.{parent}, 0x4)
        add_to_table(str_winner_ptr, id.{name}, id.{parent}, 0x4)
        add_to_table(str_winner_lx, id.{name}, id.{parent}, 0x4)
        add_to_table(str_winner_scale, id.{name}, id.{parent}, 0x4)
        add_to_table(winner_bgm, id.{name}, id.{parent}, 0x4)
        
        
        // Copy parent character for projectile tables
        add_to_table(fireball, id.{name}, id.{parent}, 0x4)

        // Add parent ID to ID override tables
        add_to_id_table(thrown_hitbox, id.{name}, id.{parent})
        add_to_id_table(f_thrown_action, id.{name}, id.{parent})
        add_to_id_table(b_thrown_action, id.{name}, id.{parent})
        add_to_id_table(falcon_dive_id, id.{name}, id.{parent})
        add_to_id_table(inhale_copy, id.{name}, id.NMARIO)      // NMARIO ID used to disable copy
        add_to_id_table(inhale_star_damage, id.{name}, id.{parent})
        add_to_id_table(inhale_star_size, id.{name}, id.{parent})

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
        print "\n\n WARNING: Action 0x" ; OS.print_hex({action}) ; print " does not exist for {{name}_parent}. edit_action_parameters aborted."
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
    
    // @ Description
    // modifies parameters for a menu action (animation id, command list offset, flags)
    // NOTE: this macro supports use outside of this file.
    macro edit_menu_action_parameters(name, action, animation, command, flags) {
    if {action} > 0xF {
        print "\n\n WARNING: Menu Action 0x" ; OS.print_hex({action}) ; print " is unsupported. edit_menu_action_parameters aborted."
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
        print "\n\n WARNING: Action 0x" OS.print_hex({action}) ; print " is a shared action and cannot be modified. edit_action aborted."
    } else if {staling} > 0x1F {
        print "\n\n WARNING: UNSUPPORTED STALING ID! Max Staling ID = 0x1F. edit_action aborted."
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
    // begins a patch in a character id based table, use OS.patch_end() to end
    // NOTE: this macro supports use outside of this file.
    macro table_patch_start(table_name, id, entry_size) {
        pushvar origin, base
        origin  Character.{table_name}.TABLE_ORIGIN + ({id} * {entry_size})  
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
        // and determines whichgrounded subroutine/script is loaded
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
            origin  0xD08F4
            base    0x80155EB4
            sltiu   at, t7, NUM_CHARACTERS  // modified original character check
            origin  0xD0900
            base    0x80155EC0
            if LOWER > 0x7FFF {
                lui     at, (UPPER + 0x1)   // original line 1 (modified)
            } else {
                lui     at, UPPER           // original line 1 (modified)
            }
            addu    at, at, t7              // original line 2
            lw      t7, LOWER(at)           // original line 3
        }
        
        // @ Description
        // modifies a hard-coded routine which seemingly runs when an AI switches behaviours?
        // the table contains pointers to what seems to be a struct for determining how the AI will
        // behave, depending on which character it uses.
        // TODO: find out more about these supposed AI behaviour structs...
        scope get_ai_behaviour_struct_: {
            constant UPPER(ai_behaviour.table >> 16)
            constant LOWER(ai_behaviour.table & 0xFFFF)
            origin  0xADAD0
            base    0x80133090
            if LOWER > 0x7FFF {
                lui     s2, (UPPER + 0x1)   // original line (modified)
            } else {
                lui     s2, UPPER           // original line (modified)
            }
            origin  0xADB80
            base    0x80133140
            lw      s2, LOWER(s2)           // original line (modified)
        }

        pullvar base, origin

        // @ Description
        // Patches which redirect from the original zoom table to the extended one.
        scope menu_zoom_patches {
            // character select screen
            OS.patch_start(0x00132E58, 0x80134BD8)
            li      t2, menu_zoom.table     // original line 1/3
            cvt.s.w f10, f8                 // original line 2
            OS.patch_end()
            // results screen
            OS.patch_start(0x152A8C, 0x801338EC)
            li      t7, menu_zoom.table     // original line 1/2
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
        // When Kirby inhales an opponent, the opponent's ID is used for a table which holds IDs
        // for the copy ability, a size multiplier for the star, and a damage value for the star.
        // This table is located at the beginning of Kirby's moveset file, so it cannot be extended
        // to accommodate additional characters through normal means.
        // Instead, a working ID will be substituted using a new table.
        scope inhale_copy_fix_: {
            OS.patch_start(0xDCB38, 0x801620F8)
            j   inhale_copy_fix_
            nop
            _return:
            OS.patch_end()

            lw      v1, 0x0008(v0)          // original line 1 (load inhaled character id)
            sh      a0, 0x0B18(v0)          // original line 2
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, inhale_copy.table   // t0 = table
            sll     v1, v1, 0x2             // v1 = offset (id * 4)
            addu    t0, t0, v1              // t0 = table + offset
            lw      v1, 0x0000(t0)          // v1 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            j       _return                 // return
            nop
        }

        // @ Description
        // same as inhale_copy_fix_
        // determines the damage of the star
        scope inhale_star_damage_fix_: {
            OS.patch_start(0xC6FF4, 0x8014C5B4)
            j   inhale_star_damage_fix_
            nop
            _return:
            OS.patch_end()

            lw      t5, 0x0008(s0)          // original line 1 (load inhaled character id)
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, inhale_star_damage.table// t0 = table
            sll     t5, t5, 0x2             // t5 = offset (id * 4)
            addu    t0, t0, t5              // t0 = table + offset
            lw      t5, 0x0000(t0)          // t5 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            multu   t5, a1                  // original line 2
            j       _return                 // return
            nop
        }
        
        // @ Description
        // same as inhale_copy_fix_
        // this determines the size of the star sprite when spitting or swallowing
        scope inhale_star_size_fix_1_: {
            OS.patch_start(0x7F5B8, 0x80103DB8)
            j   inhale_star_size_fix_1_
            nop
            _return:
            OS.patch_end()

            lw      t0, 0x0008(t9)          // original line 1 (load inhaled character id)
            li      t1, inhale_star_size.table// t1 = table
            sll     t0, t0, 0x2             // t0 = offset (id * 4)
            addu    t1, t1, t0              // t1 = table + offset
            lw      t0, 0x0000(t1)          // t0 = new ID
            sll     t1, t0, 0x2             // original line 2
            j       _return                 // return
            nop
        }
        
        // @ Description
        // same as inhale_copy_fix_
        // don't really know what this does but it reads from the size multiplier ¯\_(ツ)_/¯
        scope inhale_star_size_fix_2_: {
            OS.patch_start(0x7F3C4, 0x80103BC4)
            j   inhale_star_size_fix_2_
            nop
            _return:
            OS.patch_end()

            lw      t5, 0x0008(a1)          // original line 1 (load inhaled character id)
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, inhale_star_size.table// t0 = table
            sll     t5, t5, 0x2             // t5 = offset (id * 4)
            addu    t0, t0, t5              // t0 = table + offset
            lw      t5, 0x0000(t0)          // t5 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            sll     t6, t5, 0x2             // original line 2
            j       _return                 // return
            nop
        }
        
        // @ Description
        // same as inhale_copy_fix_
        // don't really know what this does but it reads from the size multiplier ¯\_(ツ)_/¯
        scope inhale_star_size_fix_3_: {
            OS.patch_start(0x7F430, 0x80103C30)
            j   inhale_star_size_fix_3_
            nop
            _return:
            OS.patch_end()

            lw      t9, 0x0008(a1)          // original line 1 (load inhaled character id)
            lui     at, 0x42FA              // original line 2
            addiu   sp, sp,-0x0008          // allocate stack space
            sw      t0, 0x0004(sp)          // store t0
            li      t0, inhale_star_size.table// t0 = table
            sll     t9, t9, 0x2             // t9 = offset (id * 4)
            addu    t0, t0, t9              // t0 = table + offset
            lw      t9, 0x0000(t0)          // t9 = new ID

            lw      t0, 0x0004(sp)          // load t0
            addiu   sp, sp, 0x0008          // deallocate stack space
            j       _return                 // return
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
    move_table(electric_hit, 0xA6FB4, 0x4)
    move_table(down_bound_fgm, 0xA8170, 0x2)
    move_table(crowd_chant_fgm, 0xA81A8, 0x2)
    move_table(yoshi_egg, 0x103160, 0x1C)
    move_table(ai_behaviour, 0x102B04, 0x4)
    
    // menu tables
    move_table_12(menu_zoom, 0x108370, 0x4)
    // character select
    move_table_12(default_costume, 0xA7030, 0x8)
    // results screen
    id_table_12(vs_record)
    move_table_12(winner_fgm, 0x158148, 0x4)
    id_table_12(winner_logo)
    id_table_12(label_height)
    move_table_12(str_wins_lx, 0x158654, 0x4)
    move_table_12(str_winner_ptr, 0x158690, 0x4)
    move_table_12(str_winner_lx, 0x1586C0, 0x4)
    move_table_12(str_winner_scale, 0x1586F0, 0x4)
    move_table_12(winner_bgm, 0x158A08, 0x4)
    
    
    // projectile tables
    move_table(fireball, 0x107070, 0x4)

    // ID override tables
    id_table(thrown_hitbox)
    id_table(f_thrown_action)
    id_table(b_thrown_action)
    id_table(falcon_dive_id)                // TODO: may need to be revisited
    id_table(inhale_copy)
    id_table(inhale_star_damage)
    id_table(inhale_star_size)
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
        constant NNESS(0x19)
        constant GDONKEY(0x1A)
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
    // Returns the address of the player struct for the given player.
    // @ Arguments 
    // a0 - player (p1 = 0, p4 = 3)
    // @ Returns
    // v0 - address of player X struct
    scope get_struct_: {
        addiu   sp, sp,-0x0010              // allocate stack space
        sw      t0, 0x0004(sp)              // ~
        sw      t1, 0x0008(sp)              // save registers

        li      t0, Global.p_struct_head    // t0 = address of player struct list head
        lw      t0, 0x0000(t0)              // t0 = address of player 1 struct
        lli     t1, Global.P_STRUCT_LENGTH  // t1 = player struct length
        mult    a0, t1                      // ~
        mflo    t1                          // t1 = offset = player struct length * player
        addu    v0, t0, t1                  // v0 = ret = address of player struct

        lw      t0, 0x0004(sp)              // ~
        lw      t1, 0x0008(sp)              // restore registers
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

    // 0x1D - FALCO
    define_character(FALCO, FOX, File.FALCO_MAIN, 0x0D0, 0, File.FALCO_CHARACTER, 0x13A, 0x0D2, 0x15A, 0x0A1, 0x013C, 0x46C, 0x0, OS.TRUE)
    // 0x1E - GND
    define_character(GND, CAPTAIN, File.GND_MAIN, 0x0EB, 0, File.GND_CHARACTER, 0x14E, 0, File.GND_ENTRY_KICK, File.GND_PUNCH_GRAPHIC, 0, 0x488, 0x0, OS.TRUE)
    // 0x1F - YLINK
    define_character(YLINK, LINK, File.YLINK_MAIN, 0x0E0, 0, File.YLINK_CHARACTER, 0x147, File.YLINK_BOOMERANG_HITBOX, 0x161, 0x145, 0, 0x708, 0, OS.TRUE)
    // 0x20 - DRM
    define_character(DRM, MARIO, File.DRM_MAIN, 0x0CA, 0, File.DRM_CHARACTER, 0x12A, File.DRM_PROJECTILE_DATA, 0x164, File.DRM_PROJECTILE_DATA, 0, 0x428, 0x0, OS.TRUE)
    print "========================================================================== \n"
}

} // __CHARACTER__