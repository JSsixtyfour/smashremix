// @ Description
// These constants must be defined for an item.
constant SPAWN_ITEM(Hazards.cacodemon_stage_setting_)
constant SHOW_GFX_WHEN_SPAWNED(OS.FALSE)
constant PICKUP_ITEM_MAIN(0)
constant PICKUP_ITEM_INIT(0)
constant DROP_ITEM(0)
constant PLAYER_COLLISION(0x00000000)
constant THROW_ITEM(0)

// @ Description
// Offset to item in file.
constant FILE_OFFSET(0xE0)

// @ Description
// Item info array
item_info_array:
constant ITEM_INFO_ARRAY_ORIGIN(origin())
dw 0x00000000                           // 0x00 - item ID (will be updated by Item.add_item
dw 0x801313F4                           // 0x04 - address of file pointer (this is a hardcoded address that leads to Japes Header)
dw FILE_OFFSET                          // 0x08 - offset to item footer
dw 0x1B000000                           // 0x0C - ? either 0x1B000000 or 0x1C000000 - possible argument
dw 0x00000000                           // 0x10 - ?
cacodemon_item_states:
// state 0 - main/aerial
dw Hazards.cacodemon_main_              // 0x14 - state 0 main
dw 0x00000000                           // 0x18 - state 0 collision
dw 0x00000000                           // 0x1C - state 0 hitbox collision w/ hurtbox
dw 0x00000000                           // 0x20 - state 0 hitbox collision w/ shield
dw 0x00000000                           // 0x24 - state 0 hitbox collision w/ shield edge
dw 0x00000000                           // 0x28 - state 0 unknown (maybe absorb)
dw 0x00000000                           // 0x2C - state 0 hitbox collision w/ reflector
dw Hazards.cacodemon_destroy_           // 0x30 - state 0 hurtbox collision w/ hitbox
// state 1 - resting
dw Hazards.cacodemon_main_              // 0x34 - state 1 main
dw 0x00000000                           // 0x38 - state 1 collision
dw 0x00000000                           // 0x3C - state 1 hitbox collision w/ hurtbox
dw 0x00000000                           // 0x40 - state 1 hitbox collision w/ shield
dw 0x00000000                           // 0x44 - state 1 hitbox collision w/ shield edge
dw 0x00000000                           // 0x48 - state 1 unknown (maybe absorb)
dw 0x00000000                           // 0x4C - state 1 hitbox collision w/ reflector
dw Hazards.cacodemon_destroy_           // 0x50 - state 1 hurtbox collision w/ hitbox
// state 2 - explosion
dw Hazards.cacodemon_main_                            // 0xD4 - state 2 main
dw 0                                    // 0xD8 - state 2 collision
dw 0                                    // 0xDC - state 2 hitbox collision w/ hurtbox
dw 0                                    // 0xE0 - state 2 hitbox collision w/ shield
dw 0                                    // 0xE4 - state 2 hitbox collision w/ shield edge
dw 0                                    // 0xE8 - state 2 unknown (maybe absorb)
dw 0                                    // 0xEC - state 2 hitbox collision w/ reflector
dw Hazards.cacodemon_destroy_           // 0xF0 - state 2 hurtbox collision w/ hitbox

// 8018A9B0 - plant
// UPDATE - IMPORTANT TO NOTE THAT HEADER STAGE FILE POINTERS WILL PROBABLY NEED UPDATED
