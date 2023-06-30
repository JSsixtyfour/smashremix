// @ Description
// Adds a new translation offset for a Slippy action.
// action - action id to modify, supports menu actions
// value - float32 y translation value
macro add_hip_translation(action, value) {
    pushvar origin,base
    if {action} & 0x10000 == 0x10000 {
        evaluate action({action} & 0xFFFF)
        origin hip_translation_menu_table_origin + ({action} * 4)     
    } else {
        origin hip_translation_table_origin + ({action} * 4)
    }
    float32 {value}
    
    pullvar base,origin
}

// @ Description
// Table of action dependant translation offsets for Slippy's hips
OS.align(16)
hip_translation_table:
constant hip_translation_table_origin(origin())
constant table_end(origin() + (0xF6 * 4))
while origin() < table_end {
    float32 1
}


// @ Description
// Table of menu action dependant translation offsets for Slippy's hips
OS.align(16)
hip_translation_menu_table:
constant hip_translation_menu_table_origin(origin())
constant menu_table_end(origin() + (0x10 * 4))
while origin() < menu_table_end {
    float32 1
}